import fs from 'node:fs';
import path from 'node:path';
import { spawn } from 'node:child_process';
import { dataDir, atomicJson } from './config.mjs';
import { redact, log } from './runner.mjs';

// One optional foreground application, independent of short-lived build commands.
export class Runtime {
  constructor(config) {
    this.config = config;
    this.root = path.join(dataDir, 'runtime');
    this.child = null;
    this.ready = false;
    this.switching = false;
    this.stopping = false;
    fs.mkdirSync(path.join(this.root, 'releases'), { recursive: true });
    const file = path.join(this.root, 'current.json');
    this.current = fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : null;
    if (this.current && !/^[a-f0-9]{64}$/.test(this.current.id)) throw new Error('Invalid runtime release ID');
  }

  healthy() { return !this.current || this.ready; }

  async terminate() {
    const child = this.child;
    this.ready = false;
    if (!child) return;
    await new Promise(resolve => {
      const timer = setTimeout(() => { try { process.kill(-child.pid, 'SIGKILL'); } catch {} }, this.config.stop_timeout_seconds * 1000);
      child.once('close', () => { clearTimeout(timer); resolve(); });
      try { process.kill(-child.pid, 'SIGTERM'); } catch { clearTimeout(timer); resolve(); }
    });
    if (this.child === child) this.child = null;
  }

  async start(release) {
    if (this.stopping) throw new Error('interrupted');
    const directory = path.join(this.root, 'releases', release.id);
    const cwd = fs.realpathSync(path.resolve(directory, this.config.cwd));
    if (cwd !== directory && !cwd.startsWith(directory + path.sep)) throw new Error('Runtime cwd escapes release');
    const env = { ...process.env, BUILD_ID: release.id, BUILD_SHA: release.sha, BUILD_REF: release.ref,
      BUILD_RELEASE_DIR: directory };
    for (const key of Object.keys(env)) if (/^(WEBHOOK_|APPRISE_)/.test(key)) delete env[key];
    const child = spawn('/bin/sh', ['-eu', '-c', this.config.run], { cwd, env, detached: true, stdio: ['ignore', 'pipe', 'pipe'] });
    this.child = child;
    let failure = null;
    child.on('error', () => { failure = new Error('Cannot start runtime process'); });
    child.on('close', (code, signal) => {
      if (this.child === child) { this.ready = false; this.child = null; }
      failure ??= new Error(`Runtime exited with ${code ?? signal}`);
      if (!this.switching && !this.stopping) {
        log('runtime.exited', { job_id: release.id, code, signal });
        this.onFailure?.(release, failure.message);
      }
    });
    const file = path.join(this.root, 'service.log');
    const write = text => {
      if (fs.existsSync(file) && fs.statSync(file).size > 5 * 1024 * 1024) fs.renameSync(file, `${file}.1`);
      fs.appendFileSync(file, redact(text));
    };
    for (const stream of [child.stdout, child.stderr]) {
      let pending = '';
      stream.setEncoding('utf8');
      stream.on('data', chunk => {
        pending += chunk;
        const end = pending.lastIndexOf('\n');
        if (end >= 0) { write(pending.slice(0, end + 1)); pending = pending.slice(end + 1); }
        if (pending.length > 65536) pending = '[oversized line omitted]';
      });
      stream.on('end', () => { if (pending) write(pending + '\n'); });
    }
    const deadline = Date.now() + this.config.start_timeout_seconds * 1000;
    while (Date.now() < deadline) {
      if (this.stopping) throw new Error('interrupted');
      if (failure || this.child !== child) throw failure || new Error('Runtime exited during startup');
      try {
        const response = await fetch(this.config.healthcheck_url, { signal: AbortSignal.timeout(2000), redirect: 'error' });
        await response.body?.cancel();
        if (response.ok && this.child === child) { this.ready = true; return; }
      } catch {}
      await new Promise(resolve => setTimeout(resolve, 500));
    }
    throw new Error('Runtime health check timed out');
  }

  async restore() {
    if (!this.current) return;
    this.switching = true;
    try { await this.start(this.current); }
    finally { this.switching = false; }
  }

  async deploy(job, runner) {
    const previous = this.current;
    let replaced = false;
    const directory = path.join(this.root, 'releases', job.id);
    const archive = path.join(job.artifact_dir, `${this.config.artifact}.tar.gz`);
    try {
      fs.mkdirSync(directory);
      await runner.command('tar', ['-xzf', archive, '-C', directory, '--no-same-owner'], dataDir, 300, job);
      runner.checkDeadline();
      replaced = true;
      this.switching = true;
      await this.terminate();
      const release = { id: job.id, sha: job.sha, ref: job.ref };
      // Startup consumes the remaining job budget, too.
      const savedTimeout = this.config.start_timeout_seconds;
      this.config.start_timeout_seconds = Math.min(savedTimeout, Math.max(1, Math.ceil((runner.deadline - Date.now()) / 1000)));
      try { await this.start(release); runner.checkDeadline(); }
      finally { this.config.start_timeout_seconds = savedTimeout; }
      atomicJson(path.join(this.root, 'current.json'), release);
      this.current = release;
      log('runtime.started', { job_id: job.id });
      try {
        for (const id of fs.readdirSync(path.join(this.root, 'releases'))) {
          if (id !== job.id && id !== previous?.id) fs.rmSync(path.join(this.root, 'releases', id), { recursive: true, force: true });
        }
      } catch { log('runtime.cleanup_failed', { job_id: job.id }); }
    } catch (error) {
      if (!replaced) { fs.rmSync(directory, { recursive: true, force: true }); throw error; }
      await this.terminate();
      if (previous && !this.stopping) {
        try {
          await this.start(previous);
          log('runtime.rollback_succeeded', { job_id: previous.id });
        } catch {
          await this.terminate();
          log('runtime.rollback_failed', { job_id: previous.id });
          error = new Error('New runtime failed and previous runtime could not restart');
        }
      }
      fs.rmSync(directory, { recursive: true, force: true });
      throw error;
    } finally { this.switching = false; }
  }

  async stop() { this.stopping = true; await this.terminate(); }
}
