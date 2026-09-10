import fs from 'node:fs';
import path from 'node:path';
import http from 'node:http';
import { spawn } from 'node:child_process';
import { createHash } from 'node:crypto';
import { readConfig, dataDir, socketPath, appDir, atomicJson, jobFile, jobs } from './config.mjs';
import { Runner, log } from './runner.mjs';
import { Runtime } from './runtime.mjs';

function request(endpoint, payload = {}) {
  return new Promise((resolve, reject) => {
    const req = http.request({ socketPath, path: endpoint, method: 'POST', timeout: 4000,
      headers: { 'Content-Type': 'application/json' } }, res => {
      let data = '';
      res.on('data', chunk => { data += chunk; });
      res.on('end', () => res.statusCode === 200 ? resolve(data) : reject(new Error('Request rejected')));
    });
    req.on('error', reject);
    req.on('timeout', () => req.destroy(new Error('Worker unavailable')));
    req.end(JSON.stringify(payload));
  });
}

function hooks(config) {
  const mode = process.env.WEBHOOK_AUTH_MODE || 'query';
  const token = process.env.WEBHOOK_TOKEN;
  const match = mode === 'github'
    ? { type: 'payload-hmac-sha256', secret: token, parameter: { source: 'header', name: 'X-Hub-Signature-256' } }
    : { type: 'value', value: mode === 'header' ? `Bearer ${token}` : token,
      parameter: { source: mode === 'header' ? 'header' : 'url', name: mode === 'header' ? 'Authorization' : 'token' } };
  const environment = config.provider === 'github' ? [
    { source: 'header', name: 'X-GitHub-Event', envname: 'BUILD_EVENT' },
    { source: 'header', name: 'X-GitHub-Delivery', envname: 'BUILD_DELIVERY' },
  ] : [];
  return [{
    id: 'build', 'execute-command': process.execPath, 'http-methods': ['POST'],
    'pass-arguments-to-command': [{ source: 'string', name: path.join(appDir, 'service.mjs') }, { source: 'string', name: 'submit' }],
    'pass-file-to-command': [{ source: 'entire-payload', envname: 'BUILD_PAYLOAD_FILE' }],
    'pass-environment-to-command': environment,
    'include-command-output-in-response': true,
    'include-command-output-in-response-on-error': false,
    'success-http-response-code': 202,
    'response-headers': [{ name: 'Content-Type', value: 'application/json' }],
    'trigger-rule': { or: [{ match }] },
    'trigger-signature-soft-failures': true,
    'trigger-rule-mismatch-http-response-code': 401,
  }];
}

function normalize(config, incoming) {
  const p = incoming.payload;
  if (!p || typeof p !== 'object' || Array.isArray(p)) throw new Error('Invalid JSON object');
  const github = config.provider === 'github';
  const event = github ? incoming.event : p.event;
  if (github && event === 'ping') return null;
  const repository = github ? p.repository?.full_name : p.repository;
  if (event !== 'push' || repository !== config.repository_name || !config.refs.includes(p.ref) || p.deleted === true) return null;
  const sha = github ? p.after : p.sha;
  if (typeof sha !== 'string' || !/^[a-fA-F0-9]{40}$/.test(sha) || /^0+$/.test(sha)) throw new Error('Invalid commit SHA');
  const delivery = github ? incoming.delivery : p.delivery_id;
  if (typeof delivery !== 'string' || delivery.length < 1 || delivery.length > 256) throw new Error('delivery_id is required');
  const identity = `${config.project}\n${config.repository_name}\n${delivery}`;
  const id = createHash('sha256').update(identity).digest('hex');
  return { id, sha: sha.toLowerCase(), ref: p.ref, created_at: new Date().toISOString(), status: 'queued' };
}

async function serve() {
  const config = readConfig();
  for (const dir of ['jobs', 'work', 'logs', 'artifacts', 'cache']) fs.mkdirSync(path.join(dataDir, dir), { recursive: true });
  const runner = new Runner(config);
  const runtime = config.runtime ? new Runtime(config.runtime) : null;
  runner.runtime = runtime;
  if (runtime) runtime.onFailure = (release, error) => {
    const file = jobFile(release.id);
    const job = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : { ...release };
    runner.event({ ...job, step: 'runtime', error }, 'runtime.failed');
    exitCode = 1;
    stop();
  };
  let sequence = Math.max(0, ...jobs().map(job => job.sequence)) + 1;
  // A data volume is bound to one project/repository. Reconfiguration must not replay old jobs against a different repo.
  const identityFile = path.join(dataDir, 'identity.json');
  const identity = { project: config.project, repository: config.repository, repository_name: config.repository_name };
  if (fs.existsSync(identityFile) && JSON.stringify(JSON.parse(fs.readFileSync(identityFile))) !== JSON.stringify(identity)) {
    throw new Error('Data volume belongs to a different project/repository');
  }
  atomicJson(identityFile, identity);
  for (const job of jobs()) {
    if (job.status === 'running') {
      job.status = 'interrupted';
      job.error = 'Container stopped during execution; manual retry requires a new delivery_id';
      job.finished_at = new Date().toISOString();
      job.build_status ??= 'interrupted';
      job.duration_seconds = Math.round((Date.now() - Date.parse(job.started_at)) / 1000);
      if (!job.artifact_dir) fs.rmSync(path.join(dataDir, 'artifacts', job.id), { recursive: true, force: true });
      atomicJson(jobFile(job.id), job);
      runner.event(job, 'interrupted');
    }
  }
  // Nothing in work is reusable across runs, including a checkout left by SIGKILL.
  for (const name of fs.readdirSync(path.join(dataDir, 'work'))) fs.rmSync(path.join(dataDir, 'work', name), { recursive: true, force: true });
  fs.rmSync(path.join(dataDir, 'artifacts', 'latest-success.tmp'), { force: true });
  runner.prune();
  fs.rmSync(socketPath, { force: true });
  let gateway;
  let ready = false;
  const server = http.createServer(async (req, res) => {
    try {
      if (req.method !== 'POST') { res.writeHead(405).end(); return; }
      if (req.url === '/health') {
        res.writeHead(ready && !runner.stopping && (!runtime || runtime.healthy()) ? 200 : 503).end('{"status":"ok"}'); return;
      }
      if (req.url !== '/enqueue' || runner.stopping) { res.writeHead(503).end(); return; }
      let body = '';
      for await (const chunk of req) {
        body += chunk;
        if (Buffer.byteLength(body) > 2 * 1024 * 1024) { res.writeHead(413).end(); return; }
      }
      const job = normalize(config, JSON.parse(body));
      if (!job) { res.writeHead(200).end(JSON.stringify({ status: 'ignored' })); return; }
      if (fs.existsSync(jobFile(job.id))) {
        const existing = JSON.parse(fs.readFileSync(jobFile(job.id), 'utf8'));
        if (existing.sha !== job.sha || existing.ref !== job.ref) { res.writeHead(409).end(); return; }
        res.writeHead(200).end(JSON.stringify({ status: existing.status, id: job.id, duplicate: true })); return;
      }
      if (jobs().filter(j => j.status === 'queued').length >= config.queue_limit) { res.writeHead(503).end(); return; }
      // Synchronous durable writes serialize admission without a separate database.
      job.sequence = sequence++;
      atomicJson(jobFile(job.id), job);
      runner.event(job, 'queued');
      res.writeHead(200).end(JSON.stringify({ status: 'queued', id: job.id }));
    } catch {
      log('request.rejected');
      if (!res.headersSent) res.writeHead(400);
      res.end();
    }
  });
  await new Promise((resolve, reject) => { server.once('error', reject); server.listen(socketPath, resolve); });
  fs.chmodSync(socketPath, 0o600);
  const hookFile = '/tmp/git-builder-hooks.json';
  atomicJson(hookFile, hooks(config));
  const gatewaySocket = '/tmp/git-builder-webhook.sock';
  fs.rmSync(gatewaySocket, { force: true });
  gateway = spawn('webhook', ['-hooks', hookFile, '-socket', gatewaySocket], { stdio: ['ignore', 'inherit', 'inherit'] });
  // Bound bodies before webhook parses them; preserve exact bytes for GitHub HMAC.
  const ingress = http.createServer({ maxHeaderSize: 8192 }, async (req, res) => {
    const timer = setTimeout(() => req.destroy(), 10000);
    const finish = code => { res.writeHead(code, { Connection: 'close' }); res.end(); };
    try {
      if (req.method !== 'POST') { finish(405); return; }
      if (req.url.split('?')[0] !== '/hooks/build') { finish(404); return; }
      if (!ready || runner.stopping) { finish(503); return; }
      const chunks = [];
      let bytes = 0;
      for await (const chunk of req) {
        bytes += chunk.length;
        if (bytes > 1024 * 1024) { finish(413); return; }
        chunks.push(chunk);
      }
      const headers = { 'content-type': 'application/json', 'content-length': bytes };
      for (const key of ['authorization', 'x-hub-signature-256', 'x-github-event', 'x-github-delivery']) {
        if (req.headers[key]) headers[key] = req.headers[key];
      }
      const upstream = http.request({ socketPath: gatewaySocket, path: req.url, method: 'POST', headers, timeout: 5000 }, response => {
        res.writeHead(response.statusCode, { 'Content-Type': response.headers['content-type'] || 'text/plain' });
        response.pipe(res);
      });
      upstream.on('error', () => { if (!res.headersSent) finish(502); else res.end(); });
      upstream.on('timeout', () => upstream.destroy());
      upstream.end(Buffer.concat(chunks));
    } catch { if (!res.headersSent && !res.destroyed) finish(400); }
    finally { clearTimeout(timer); }
  });
  ingress.maxConnections = 64;
  ingress.requestTimeout = 10000;
  ingress.headersTimeout = 10000;
  let exitCode = 0;
  let runtimeStopped;
  function stop() {
    if (runner.stopping) return;
    runner.stop();
    runtimeStopped = runtime?.stop();
    ready = false;
    gateway.kill('SIGTERM');
    server.close();
    ingress.close();
    ingress.closeAllConnections();
    // A command ignoring TERM must not prevent container shutdown.
    setTimeout(() => {
      if (runner.child) { try { process.kill(-runner.child.pid, 'SIGKILL'); } catch {} }
    }, 2000).unref();
  }
  gateway.on('error', () => { exitCode = 1; stop(); });
  gateway.on('exit', () => { if (!runner.stopping) { exitCode = 1; stop(); } });
  process.on('SIGTERM', stop);
  process.on('SIGINT', stop);
  // Verify the listener, not just the worker process, before advertising health.
  for (let i = 0; i < 30 && !runner.stopping; i++) {
    try {
      const status = await new Promise((resolve, reject) => {
        const probe = http.get({ socketPath: gatewaySocket, path: '/', timeout: 1000 }, response => { response.resume(); resolve(response.statusCode); });
        probe.on('error', reject);
        probe.on('timeout', () => probe.destroy());
      });
      if (status === 200) { ready = true; break; }
    } catch {}
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  if (!ready && !runner.stopping) { exitCode = 1; stop(); }
  if (ready) {
    try {
      await new Promise((resolve, reject) => { ingress.once('error', reject); ingress.listen(Number(process.env.WEBHOOK_PORT || 9000), '0.0.0.0', resolve); });
      log('ready', { project: config.project, port: Number(process.env.WEBHOOK_PORT || 9000) });
    } catch { exitCode = 1; stop(); }
  }
  if (ready && runtime) {
    try { await runtime.restore(); }
    catch { log('runtime.restore_failed'); exitCode = 1; stop(); }
  }
  while (!runner.stopping) {
    try {
      const job = jobs().find(j => j.status === 'queued');
      if (job) await runner.run(job);
      else await new Promise(resolve => setTimeout(resolve, 250));
    } catch {
      log('worker.failed');
      exitCode = 1;
      stop();
    }
  }
  await runner.notifications;
  await runtimeStopped;
  fs.rmSync(socketPath, { force: true });
  fs.rmSync(gatewaySocket, { force: true });
  process.exitCode = exitCode;
}

try {
  const mode = process.argv[2];
  if (mode === 'serve') await serve();
  else if (mode === 'submit') {
    const file = process.env.BUILD_PAYLOAD_FILE;
    if (!file || fs.statSync(file).size > 1024 * 1024) throw new Error('Invalid payload size');
    const payload = JSON.parse(fs.readFileSync(file, 'utf8'));
    console.log(await request('/enqueue', { payload, event: process.env.BUILD_EVENT, delivery: process.env.BUILD_DELIVERY }));
  } else if (mode === 'health') {
    await request('/health');
  } else if (mode === 'status') {
    const id = process.argv[3];
    if (id && !/^[a-f0-9]{64}$/.test(id)) throw new Error('Invalid job ID');
    console.log(JSON.stringify(id ? JSON.parse(fs.readFileSync(jobFile(id))) : jobs(), null, 2));
  } else throw new Error('Use serve, submit, health or status [job-id]');
} catch (error) {
  // No request bodies, credentials, repository URLs or child command strings in admission errors.
  console.error(process.argv[2] === 'submit' ? 'Build request rejected; inspect worker logs/configuration' : error.message);
  process.exitCode = 1;
}
