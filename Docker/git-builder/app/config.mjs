import fs from 'node:fs';
import path from 'node:path';

export const dataDir = path.resolve(process.env.DATA_DIR || '/data');
export const socketPath = '/tmp/git-builder.sock';
export const appDir = path.dirname(new URL(import.meta.url).pathname);
export const events = ['queued', 'started', 'checkout.succeeded', 'step.started', 'step.succeeded',
  'artifacts.succeeded', 'after_build.started', 'after_build.succeeded', 'runtime.started', 'runtime.failed', 'succeeded', 'failed', 'timed_out', 'interrupted'];

function requireValue(condition, message) {
  if (!condition) throw new Error(message);
}
function relative(value) {
  return typeof value === 'string' && value.length > 0 && !path.isAbsolute(value)
    && !value.split('/').includes('..') && !value.includes('\0');
}
function positive(value) { return Number.isInteger(value) && value > 0; }

export function readConfig() {
  const c = JSON.parse(fs.readFileSync(process.env.CONFIG_FILE || '/config/pipeline.json', 'utf8'));
  c.repository = process.env.GIT_REPO_URL || c.repository;
  c.repository_name = process.env.GIT_REPO_NAME || c.repository_name;
  requireValue(typeof c.project === 'string' && /^[a-zA-Z0-9_-]{1,64}$/.test(c.project), 'Invalid project');
  requireValue(typeof c.repository === 'string' && c.repository.length > 0 && !c.repository.startsWith('-'), 'GIT_REPO_URL is required');
  requireValue(typeof c.repository_name === 'string' && c.repository_name.length > 0, 'GIT_REPO_NAME is required');
  c.provider ??= 'generic';
  requireValue(['generic', 'github'].includes(c.provider), 'provider must be generic or github');
  requireValue(Array.isArray(c.refs) && c.refs.length > 0 && c.refs.every(r => typeof r === 'string' && /^refs\/(heads|tags)\//.test(r)), 'refs must contain full Git refs');
  c.queue_limit ??= 20;
  c.timeout_seconds ??= 1800;
  c.keep_runs ??= 20;
  c.max_log_bytes ??= 10485760;
  for (const key of ['queue_limit', 'timeout_seconds', 'keep_runs', 'max_log_bytes']) requireValue(positive(c[key]), `Invalid ${key}`);
  c.after_build ??= [];
  requireValue(Array.isArray(c.steps) && c.steps.length > 0 && Array.isArray(c.after_build), 'steps must be nonempty; after_build must be an array');
  for (const step of [...c.steps, ...c.after_build]) {
    requireValue(typeof step.name === 'string' && /^[a-zA-Z0-9_.-]{1,64}$/.test(step.name), 'Invalid step name');
    step.cwd ??= '.';
    requireValue(relative(step.cwd), 'Step cwd must stay inside checkout');
    requireValue(typeof step.run === 'string' && step.run.trim().length > 0, 'Step run is required');
    step.timeout_seconds ??= c.timeout_seconds;
    requireValue(positive(step.timeout_seconds), 'Invalid step timeout');
  }
  requireValue(Array.isArray(c.artifacts) && c.artifacts.length > 0, 'artifacts must be nonempty');
  const names = new Set();
  for (const a of c.artifacts) {
    requireValue(typeof a.name === 'string' && /^[a-zA-Z0-9_-]{1,64}$/.test(a.name) && !names.has(a.name), 'Invalid or duplicate artifact name');
    requireValue(relative(a.path), 'Artifact path must stay inside checkout');
    names.add(a.name);
  }
  c.notifications ??= {};
  if (c.runtime !== undefined) {
    const r = c.runtime;
    requireValue(r && typeof r === 'object' && !Array.isArray(r), 'runtime must be an object');
    requireValue(names.has(r.artifact), 'runtime.artifact must name a configured artifact');
    r.cwd ??= '.';
    requireValue(relative(r.cwd), 'Runtime cwd must stay inside release');
    requireValue(typeof r.run === 'string' && r.run.trim().length > 0, 'Runtime run is required');
    const url = new URL(r.healthcheck_url);
    requireValue(['http:', 'https:'].includes(url.protocol) && ['127.0.0.1', 'localhost', '[::1]'].includes(url.hostname), 'Runtime health URL must be loopback HTTP(S)');
    r.start_timeout_seconds ??= 60;
    r.stop_timeout_seconds ??= 20;
    requireValue(positive(r.start_timeout_seconds) && positive(r.stop_timeout_seconds), 'Invalid runtime timeout');
  }
  for (const [event, rule] of Object.entries(c.notifications)) {
    requireValue(events.includes(event), `Unknown notification event: ${event}`);
    requireValue(rule && typeof rule === 'object' && !Array.isArray(rule), 'Notification must be an object');
    if (rule.enabled !== undefined) requireValue(typeof rule.enabled === 'boolean', 'Notification enabled must be boolean');
    for (const key of ['title', 'body', 'tag']) if (rule[key] !== undefined) requireValue(typeof rule[key] === 'string', `Notification ${key} must be text`);
  }
  const mode = process.env.WEBHOOK_AUTH_MODE || 'query';
  requireValue(['query', 'header', 'github'].includes(mode), 'Invalid WEBHOOK_AUTH_MODE');
  requireValue(mode !== 'github' || c.provider === 'github', 'github auth requires github provider');
  requireValue(typeof process.env.WEBHOOK_TOKEN === 'string' && process.env.WEBHOOK_TOKEN.length >= 32, 'WEBHOOK_TOKEN must contain at least 32 characters');
  requireValue(positive(Number(process.env.WEBHOOK_PORT || 9000)) && Number(process.env.WEBHOOK_PORT || 9000) <= 65535, 'Invalid WEBHOOK_PORT');
  if (process.env.APPRISE_NOTIFY_URL) {
    requireValue(['http:', 'https:'].includes(new URL(process.env.APPRISE_NOTIFY_URL).protocol), 'Apprise URL must use HTTP(S)');
  }
  return c;
}

export function atomicJson(file, value) {
  const temp = `${file}.${process.pid}.tmp`;
  const fd = fs.openSync(temp, 'w', 0o600);
  try { fs.writeFileSync(fd, JSON.stringify(value, null, 2) + '\n'); fs.fsyncSync(fd); }
  finally { fs.closeSync(fd); }
  fs.renameSync(temp, file);
  const parent = fs.openSync(path.dirname(file), 'r');
  try { fs.fsyncSync(parent); } finally { fs.closeSync(parent); }
}

export function jobFile(id) { return path.join(dataDir, 'jobs', `${id}.json`); }
export function jobs() {
  return fs.readdirSync(path.join(dataDir, 'jobs')).filter(f => f.endsWith('.json'))
    .map(f => JSON.parse(fs.readFileSync(path.join(dataDir, 'jobs', f), 'utf8')))
    .sort((a, b) => a.sequence - b.sequence);
}
