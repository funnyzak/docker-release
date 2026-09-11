import fs from 'node:fs';
import path from 'node:path';
import { spawn, spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { dataDir, atomicJson, jobFile, jobs } from './config.mjs';

const secrets = Object.entries(process.env)
  .filter(([key, value]) => /TOKEN|SECRET|PASSWORD|AUTHORIZATION|APPRISE_NOTIFY_URL/.test(key) && value)
  .map(([, value]) => value);
export function redact(text) {
  let result = String(text);
  for (const secret of secrets) result = result.split(secret).join('[REDACTED]');
  return result.replace(/(https?:\/\/)[^\s/@]+:[^\s/@]+@/g, '$1[REDACTED]@');
}
export function log(event, values = {}) {
  console.log(JSON.stringify({ time: new Date().toISOString(), event, ...values }));
}

export class Runner {
  constructor(config) {
    this.config = config;
    this.stopping = false;
    this.active = null;
    this.child = null;
    this.notifications = Promise.resolve();
    this.toolchain = { node: process.version };
    for (const [name, args] of [['npm', ['--version']], ['pnpm', ['--version']], ['java', ['-version']], ['mvn', ['--version']]]) {
      const result = spawnSync(name, args, { encoding: 'utf8', timeout: 10000 });
      if (result.status !== 0) throw new Error(`Toolchain unavailable: ${name}`);
      this.toolchain[name] = (result.stdout + result.stderr).trim().split('\n')[0].replace(/\u001b\[[0-9;]*m/g, '');
    }
  }

  event(job, event) {
    const values = { project: this.config.project, job_id: job.id, ref: job.ref, sha: job.sha,
      event, step: job.step || '', status: job.status, error: job.error || '',
      artifact_dir: job.artifact_dir || '', duration_seconds: job.duration_seconds ?? '',
      time: new Date().toISOString() };
    fs.appendFileSync(path.join(dataDir, 'logs', `${job.id}.events.jsonl`), JSON.stringify(values) + '\n');
    log(event, { job_id: job.id, step: values.step });
    const rule = this.config.notifications[event] || {};
    const enabled = rule.enabled ?? !['checkout.succeeded', 'step.started', 'step.succeeded', 'after_build.started', 'after_build.succeeded', 'artifacts.succeeded'].includes(event);
    if (!enabled || !process.env.APPRISE_NOTIFY_URL) return;
    const render = template => redact(template.replace(/\{([a-z_]+)\}/g, (match, key) => String(values[key] ?? match)));
    const defaultBody = [
      ['Task', values.job_id], ['Ref', values.ref], ['Commit', values.sha],
      ['Step', values.step], ['Duration', values.duration_seconds === '' ? '' : `${values.duration_seconds}s`],
      ['Artifacts', values.artifact_dir], ['Error', values.error],
    ].filter(([, value]) => value !== '' && value !== undefined && value !== null)
      .map(([label, value]) => `${label}: ${value}`).join('\n');
    const body = {
      title: render(rule.title || '[{project}] {event}'),
      body: rule.body ? render(rule.body) : redact(defaultBody),
      type: ['failed', 'timed_out', 'interrupted', 'runtime.failed'].includes(event) ? 'failure' : event === 'succeeded' ? 'success' : 'info',
      format: 'text',
    };
    const tag = rule.tag ?? process.env.APPRISE_TAG;
    if (tag) body.tag = tag;
    // Notifications are ordered but never hold up queue admission or builds.
    this.notifications = this.notifications.then(() => this.notify(body, job.id, event))
      .catch(() => log('notification.failed', { job_id: job.id, stage: event }));
  }

  async notify(body, id, event) {
    const quote = value => '"' + String(value).replaceAll('\\', '\\\\').replaceAll('"', '\\"').replaceAll('\r', '\\r').replaceAll('\n', '\\n') + '"';
    const lines = [`url = ${quote(process.env.APPRISE_NOTIFY_URL)}`, 'header = "Content-Type: application/json"', `data = ${quote(JSON.stringify(body))}`];
    if (process.env.APPRISE_AUTHORIZATION) lines.push(`header = ${quote('Authorization: ' + process.env.APPRISE_AUTHORIZATION)}`);
    for (let attempt = 0; attempt < 2; attempt++) {
      const result = await new Promise(resolve => {
        const child = spawn('curl', ['--silent', '--output', '/dev/null', '--write-out', '%{http_code}',
          '--connect-timeout', '5', '--max-time', '15', '--config', '-'], { stdio: ['pipe', 'pipe', 'ignore'] });
        let status = '';
        child.stdout.on('data', chunk => { status += chunk; });
        child.stdin.on('error', () => {});
        child.on('error', () => resolve({ code: -1, status: 0 }));
        child.on('close', code => resolve({ code, status: Number(status) }));
        child.stdin.end(lines.join('\n') + '\n');
      });
      if (result.code === 0 && result.status === 200) return;
      if (attempt === 0 && (result.code !== 0 || result.status === 429 || result.status >= 500)) {
        await new Promise(resolve => setTimeout(resolve, 1000));
        continue;
      }
      log('notification.failed', { job_id: id, stage: event, http_status: result.status });
      return;
    }
  }

  stop() {
    this.stopping = true;
    if (this.child) this.kill(this.child);
  }
  kill(child) {
    try { process.kill(-child.pid, 'SIGTERM'); } catch { /* Already exited. */ }
  }

  checkDeadline() {
    if (this.stopping) throw new Error('interrupted');
    if (Date.now() >= this.deadline) throw new Error('timed_out');
  }

  async command(program, args, cwd, seconds, job, extraEnv = {}) {
    this.checkDeadline();
    const env = { ...process.env, ...extraEnv };
    for (const key of Object.keys(env)) if (/^(WEBHOOK_|APPRISE_)/.test(key)) delete env[key];
    env.MAVEN_OPTS = `${env.MAVEN_OPTS || ''} -Dmaven.repo.local=${path.join(dataDir, 'cache', 'maven')}`;
    env.npm_config_cache = path.join(dataDir, 'cache', 'npm');
    env.npm_config_store_dir = path.join(dataDir, 'cache', 'pnpm');
    env.CI = 'true';
    const remaining = Math.ceil((this.deadline - Date.now()) / 1000);
    if (remaining <= 0) throw new Error('timed_out');
    return new Promise((resolve, reject) => {
      const child = spawn(program, args, { cwd, env, detached: true, stdio: ['ignore', 'pipe', 'pipe'] });
      this.child = child;
      let expired = false;
      const buffers = { stdout: '', stderr: '' };
      const write = text => {
        const safe = redact(text);
        const size = Buffer.byteLength(safe);
        if (this.logBytes + size <= this.config.max_log_bytes) {
          fs.appendFileSync(path.join(dataDir, 'logs', `${job.id}.log`), safe);
          this.logBytes += size;
        } else if (!this.logTruncated) {
          fs.appendFileSync(path.join(dataDir, 'logs', `${job.id}.log`), '\n[log limit reached; further output omitted]\n');
          this.logTruncated = true;
        }
      };
      for (const name of ['stdout', 'stderr']) {
        child[name].setEncoding('utf8');
        child[name].on('data', chunk => {
          buffers[name] += chunk;
          const last = buffers[name].lastIndexOf('\n');
          if (last >= 0) { write(buffers[name].slice(0, last + 1)); buffers[name] = buffers[name].slice(last + 1); }
          // Drop pathological unbroken lines instead of leaking split secrets or growing without limit.
          if (buffers[name].length > 65536) buffers[name] = '[oversized line omitted]';
        });
      }
      let force;
      const timer = setTimeout(() => {
        expired = true;
        this.kill(child);
        force = setTimeout(() => { try { process.kill(-child.pid, 'SIGKILL'); } catch {} }, 2000);
      }, Math.min(seconds, remaining) * 1000);
      child.on('error', () => { clearTimeout(timer); this.child = null; reject(new Error(`Cannot start ${program}`)); });
      child.on('close', (code, signal) => {
        clearTimeout(timer);
        clearTimeout(force);
        // Build commands must not leave background daemons holding the job workspace.
        try { process.kill(-child.pid, 'SIGKILL'); } catch {}
        this.child = null;
        for (const value of Object.values(buffers)) if (value) write(value + '\n');
        if (this.stopping) reject(new Error('interrupted'));
        else if (expired) reject(new Error('timed_out'));
        else if (code !== 0) reject(new Error(`${program} exited with ${code ?? signal}`));
        else resolve();
      });
    });
  }

  inside(root, relative) {
    const target = fs.realpathSync(path.resolve(root, relative));
    if (target !== root && !target.startsWith(root + path.sep)) throw new Error('Path escapes checkout');
    return target;
  }

  async run(job) {
    this.active = job;
    this.deadline = Date.now() + this.config.timeout_seconds * 1000;
    this.logBytes = 0;
    this.logTruncated = false;
    const workspace = path.join(dataDir, 'work', job.id);
    const output = path.join(dataDir, 'artifacts', job.id);
    job.status = 'running';
    job.started_at = new Date().toISOString();
    atomicJson(jobFile(job.id), job);
    this.event(job, 'started');
    try {
      job.step = 'checkout';
      atomicJson(jobFile(job.id), job);
      fs.mkdirSync(workspace);
      await this.command('git', ['init', '--quiet', workspace], dataDir, 60, job);
      await this.command('git', ['remote', 'add', 'origin', this.config.repository], workspace, 60, job);
      await this.command('git', ['fetch', '--no-tags', '--depth=1', 'origin', job.sha], workspace, 300, job);
      await this.command('git', ['checkout', '--detach', job.sha], workspace, 60, job);
      // Fail closed if the Git server cannot fetch this exact SHA; never fall back to branch HEAD.
      this.event(job, 'checkout.succeeded');
      const env = { BUILD_ID: job.id, BUILD_SHA: job.sha, BUILD_REF: job.ref, BUILD_PROJECT: this.config.project,
        BUILD_WORKSPACE: workspace, BUILD_ARTIFACT_DIR: output };
      for (const step of this.config.steps) {
        job.step = step.name;
        atomicJson(jobFile(job.id), job);
        this.event(job, 'step.started');
        await this.command('/bin/sh', ['-eu', '-c', step.run], this.inside(workspace, step.cwd), step.timeout_seconds, job, env);
        this.event(job, 'step.succeeded');
      }
      job.step = 'artifacts';
      atomicJson(jobFile(job.id), job);
      fs.mkdirSync(output);
      const manifest = { project: this.config.project, id: job.id, sha: job.sha, ref: job.ref,
        architecture: process.arch, toolchain: this.toolchain, created_at: new Date().toISOString(), artifacts: [] };
      for (const artifact of this.config.artifacts) {
        const source = this.inside(workspace, artifact.path);
        const stat = fs.statSync(source);
        if ((stat.isFile() && stat.size === 0) || (stat.isDirectory() && fs.readdirSync(source).length === 0)) throw new Error(`Empty artifact: ${artifact.name}`);
        const archive = path.join(output, `${artifact.name}.tar.gz`);
        await this.command('tar', ['-czf', archive, '-C', workspace, '--', artifact.path], workspace, 300, job);
        const hash = createHash('sha256');
        for await (const chunk of fs.createReadStream(archive)) { this.checkDeadline(); hash.update(chunk); }
        manifest.artifacts.push({ name: path.basename(archive), sha256: hash.digest('hex'), bytes: fs.statSync(archive).size });
      }
      atomicJson(path.join(output, 'manifest.json'), manifest);
      job.artifact_dir = output;
      job.build_status = 'succeeded';
      atomicJson(jobFile(job.id), job);
      this.event(job, 'artifacts.succeeded');
      for (const step of this.config.after_build) {
        job.step = step.name;
        atomicJson(jobFile(job.id), job);
        this.event(job, 'after_build.started');
        await this.command('/bin/sh', ['-eu', '-c', step.run], this.inside(workspace, step.cwd), step.timeout_seconds, job, env);
        this.event(job, 'after_build.succeeded');
      }
      if (this.runtime) {
        job.step = 'runtime';
        atomicJson(jobFile(job.id), job);
        await this.runtime.deploy(job, this);
        this.event(job, 'runtime.started');
      }
      this.checkDeadline();
      job.status = 'succeeded';
    } catch (error) {
      job.status = ['timed_out', 'interrupted'].includes(error.message) ? error.message : 'failed';
      job.error = redact(error.message);
      job.build_status ??= job.status;
      if (!job.artifact_dir) fs.rmSync(output, { recursive: true, force: true });
    } finally {
      job.finished_at = new Date().toISOString();
      job.duration_seconds = Math.round((Date.now() - Date.parse(job.started_at)) / 1000);
      atomicJson(jobFile(job.id), job);
      if (job.status === 'succeeded') {
        // Persist terminal success before publishing its pointer; a crash may leave the older pointer, never a running job.
        const latest = path.join(dataDir, 'artifacts', 'latest-success');
        try {
          fs.symlinkSync(job.id, `${latest}.tmp`);
          fs.renameSync(`${latest}.tmp`, latest);
        } catch {
          job.status = 'failed';
          job.error = 'Cannot update latest-success';
          atomicJson(jobFile(job.id), job);
        }
      }
      this.event(job, job.status);
      fs.rmSync(workspace, { recursive: true, force: true });
      this.active = null;
    }
    await this.prune();
  }

  async prune() {
    if (this.active) return;
    let removed = 0;
    let freed = 0;
    let cacheReset = false;
    const size = async file => {
      const stat = await fs.promises.lstat(file).catch(error => {
        if (error.code === 'ENOENT') return null;
        throw error;
      });
      if (!stat) return 0;
      if (!stat.isDirectory()) return stat.size;
      let bytes = 0;
      for (const name of await fs.promises.readdir(file)) bytes += await size(path.join(file, name));
      return bytes;
    };
    try {
      // Never traverse a substituted storage root while deleting managed data.
      for (const name of ['artifacts', 'logs', 'jobs', 'runtime', 'cache']) {
        const stat = await fs.promises.lstat(path.join(dataDir, name)).catch(error => {
          if (error.code === 'ENOENT') return null;
          throw error;
        });
        if (stat && !stat.isDirectory()) throw new Error(`Invalid cleanup directory: ${name}`);
      }
      const protectedIds = new Set();
      const latestPath = path.join(dataDir, 'artifacts', 'latest-success');
      try { protectedIds.add(await fs.promises.readlink(latestPath)); }
      catch (error) { if (error.code !== 'ENOENT') throw error; }
      if (this.runtime) {
        if (this.runtime.current) protectedIds.add(this.runtime.current.id);
        // Runtime keeps current and previous releases, including pre-upgrade volumes.
        const releases = path.join(dataDir, 'runtime', 'releases');
        if (!(await fs.promises.lstat(releases)).isDirectory()) throw new Error('Invalid runtime releases directory');
        for (const id of await fs.promises.readdir(releases)) protectedIds.add(id);
      }
      const finished = jobs().filter(job => !['queued', 'running'].includes(job.status));
      const cutoff = Date.now() - (this.config.keep_days || 0) * 86400000;
      for (const [index, job] of finished.entries()) {
        const expired = this.config.keep_days > 0 && Date.parse(job.finished_at) < cutoff;
        if ((!expired && index >= finished.length - this.config.keep_runs) || protectedIds.has(job.id)) continue;
        if (!/^[a-f0-9]{64}$/.test(job.id)) throw new Error('Invalid cleanup job ID');
        const files = [path.join(dataDir, 'artifacts', job.id),
          ...['.log', '.events.jsonl'].map(suffix => path.join(dataDir, 'logs', job.id + suffix)), jobFile(job.id)];
        for (const file of files) {
          const bytes = await size(file);
          await fs.promises.rm(file, { recursive: true, force: true });
          freed += bytes;
        }
        removed++;
      }
      if (this.config.cache_max_mb > 0) {
        const caches = ['maven', 'npm', 'pnpm'].map(name => path.join(dataDir, 'cache', name));
        let bytes = 0;
        for (const directory of caches) bytes += await size(directory);
        if (bytes > this.config.cache_max_mb * 1024 * 1024) {
          for (const directory of caches) {
            const bytes = await size(directory);
            await fs.promises.rm(directory, { recursive: true, force: true });
            freed += bytes;
            await fs.promises.mkdir(directory, { recursive: true });
          }
          cacheReset = true;
        }
      }
      log('cleanup.succeeded', { removed_jobs: removed, freed_bytes: freed, cache_reset: cacheReset });
    } catch (error) {
      log('cleanup.failed', { removed_jobs: removed, freed_bytes: freed, error: redact(error.message) });
    }
  }
}
