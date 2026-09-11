import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

const scratch = path.resolve('tmp');
fs.mkdirSync(scratch, { recursive: true });
const root = fs.mkdtempSync(path.join(scratch, 'cleanup-test-'));
process.env.DATA_DIR = root;
process.env.CONFIG_FILE = path.join(root, 'pipeline.json');
process.env.WEBHOOK_TOKEN = 'test-token-'.repeat(4);
const { Runner } = await import('../app/runner.mjs');
const { readConfig } = await import('../app/config.mjs');
const id = n => n.toString(16).padStart(64, '0');
const runner = Object.create(Runner.prototype);
function reset(config = {}) {
  fs.rmSync(root, { recursive: true, force: true });
  fs.mkdirSync(root);
  for (const dir of ['jobs', 'logs', 'artifacts', 'cache', 'runtime/releases']) fs.mkdirSync(path.join(root, dir), { recursive: true });
  runner.active = null;
  runner.runtime = null;
  runner.config = { keep_runs: 5, keep_days: 15, cache_max_mb: 0, ...config };
}
function job(n, days = 0, status = 'succeeded') {
  const value = { id: id(n), sequence: n, status, finished_at: new Date(Date.now() - days * 86400000).toISOString() };
  fs.writeFileSync(path.join(root, 'jobs', `${value.id}.json`), JSON.stringify(value));
  fs.mkdirSync(path.join(root, 'artifacts', value.id));
  for (const suffix of ['.log', '.events.jsonl']) fs.writeFileSync(path.join(root, 'logs', value.id + suffix), 'log');
  return value;
}
const exists = n => fs.existsSync(path.join(root, 'jobs', id(n) + '.json'));

test('storage retention', async t => {
  try {
    await t.test('age OR count, active jobs and current/previous/latest protected', async () => {
      reset({ keep_runs: 2 });
      for (let n = 1; n <= 7; n++) job(n, 20);
      job(8, 0, 'running'); job(9, 0, 'queued');
      fs.symlinkSync(id(1), path.join(root, 'artifacts/latest-success'));
      runner.runtime = { current: { id: id(2) } };
      for (const n of [2, 3]) fs.mkdirSync(path.join(root, 'runtime/releases', id(n)));
      await runner.prune();
      for (const n of [1, 2, 3, 8, 9]) assert.ok(exists(n));
      for (const n of [4, 5, 6, 7]) {
        assert.ok(!exists(n));
        assert.ok(!fs.existsSync(path.join(root, 'artifacts', id(n))));
        assert.ok(!fs.existsSync(path.join(root, 'logs', id(n) + '.events.jsonl')));
      }
      reset({ keep_runs: 2, keep_days: 0 });
      for (let n = 1; n <= 3; n++) job(n, 100);
      await runner.prune();
      assert.ok(!exists(1)); assert.ok(exists(2)); assert.ok(exists(3));
    });
    await t.test('under-threshold or disabled caches retained; over threshold reset; unrelated data preserved', async () => {
      reset({ cache_max_mb: 1 });
      for (const name of ['maven', 'npm', 'pnpm', 'custom']) {
        fs.mkdirSync(path.join(root, 'cache', name));
        fs.writeFileSync(path.join(root, 'cache', name, 'data'), Buffer.alloc(400000));
      }
      fs.mkdirSync(path.join(root, 'service')); fs.writeFileSync(path.join(root, 'service/backup'), 'keep');
      await runner.prune();
      for (const name of ['maven', 'npm', 'pnpm']) assert.deepEqual(fs.readdirSync(path.join(root, 'cache', name)), []);
      assert.ok(fs.existsSync(path.join(root, 'cache/custom/data')));
      assert.ok(fs.existsSync(path.join(root, 'service/backup')));
      fs.writeFileSync(path.join(root, 'cache/npm/data'), 'keep');
      await runner.prune(); assert.ok(fs.existsSync(path.join(root, 'cache/npm/data')));
      runner.config.cache_max_mb = 0;
      fs.writeFileSync(path.join(root, 'cache/npm/data'), Buffer.alloc(2000000));
      await runner.prune(); assert.ok(fs.existsSync(path.join(root, 'cache/npm/data')));
    });
    await t.test('active builder skips cleanup and filesystem failures do not escape', async () => {
      reset(); job(1, 20); runner.active = { id: id(2) };
      await runner.prune(); assert.ok(exists(1));
      runner.active = null;
      const rm = fs.promises.rm;
      fs.promises.rm = async () => { throw new Error('simulated read-only storage'); };
      try { await assert.doesNotReject(() => runner.prune()); assert.ok(exists(1)); }
      finally { fs.promises.rm = rm; }
      await runner.prune(); assert.ok(!exists(1));
    });
    await t.test('symlinks do not traverse other storage', async () => {
      reset({ cache_max_mb: 1 });
      fs.mkdirSync(path.join(root, 'service')); fs.writeFileSync(path.join(root, 'service/backup'), Buffer.alloc(2000000));
      fs.symlinkSync('../service', path.join(root, 'cache/npm'));
      fs.mkdirSync(path.join(root, 'cache/maven')); fs.writeFileSync(path.join(root, 'cache/maven/big'), Buffer.alloc(2000000));
      await runner.prune(); assert.ok(fs.existsSync(path.join(root, 'service/backup')));
      job(1, 20);
      fs.rmSync(path.join(root, 'artifacts'), { recursive: true });
      fs.symlinkSync('service', path.join(root, 'artifacts'));
      await runner.prune(); assert.ok(exists(1)); assert.ok(fs.existsSync(path.join(root, 'service/backup')));
    });
    await t.test('config defaults and invalid retention values', () => {
      reset();
      const config = { project: 'test', repository: 'https://example.com/repo.git', repository_name: 'test/repo', refs: ['refs/heads/main'], steps: [{ name: 'build', run: 'true' }], artifacts: [{ name: 'app', path: 'dist' }] };
      const save = value => fs.writeFileSync(process.env.CONFIG_FILE, JSON.stringify(value));
      save(config); const loaded = readConfig();
      assert.equal(loaded.keep_days, 0); assert.equal(loaded.cache_max_mb, 0); assert.equal(loaded.keep_runs, 20);
      for (const key of ['keep_days', 'cache_max_mb']) {
        for (const value of [-1, 1.5, '15', Number.MAX_SAFE_INTEGER + 1]) {
          save({ ...config, [key]: value }); assert.throws(readConfig, new RegExp(`Invalid ${key}`));
        }
      }
    });
  } finally { fs.rmSync(root, { recursive: true, force: true }); }
});
