# Repository Guidelines

Docker Release hosts curated Docker build contexts for dozens of services; use this guide to keep contributions uniform and releasable.

## Project Structure & Module Organization

All service code lives under `Docker/<service-name>/` alongside its `Dockerfile`, optional `docker-compose.yml`, helper scripts, and README. Shared assets must stay inside the same folder to keep build contexts self-contained; stash experiments in `tmp/` and never inside module trees. Document any new module inside its folder README and reference it in the root README catalog.

## Build, Test, and Development Commands

- `docker buildx create --name docker-release --use` (run once) enables multi-architecture builds that match CI.
- `docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/funnyzak/<service>:dev ./Docker/<service>` builds and tags an image locally.
- `docker compose -f Docker/<service>/docker-compose.yml up -d` (where present) starts demo or integration stacks.
- `docker buildx imagetools inspect ghcr.io/funnyzak/<service>:dev` confirms manifest entries before publishing.

Pass secrets and build toggles through `.env` plus `--build-arg`; never embed raw credentials in Dockerfiles.

## Coding Style & Naming Conventions

Use minimal, pinned base images, arrange Dockerfile instructions as `FROM → ARG → LABEL/ENV → RUN → COPY → ENTRYPOINT`, and keep layer count low. Directory names stay lowercase with hyphens; image names mirror the folder. Shell helpers must be executable, POSIX-compliant, and linted with `shellcheck`. Update each service README whenever exposed ports, volumes, or parameters change.

## Testing Guidelines

Every image needs a smoke test documented in its README (for example `docker run --rm <image> --version` or the compose stack reaching healthy status). Prefer module-level tests inside `Docker/<service>/tests` when upstream repos ship suites. Capture logs for CI by running the same command locally before pushing.

## Commit & Pull Request Guidelines

Follow the conventional commit grammar seen in `git log` (`feat:`, `chore:`, `refactor:`). Commit messages should mention the service name (for example `feat: nezha add web assets`). Pull requests must describe the motivation, list build and test commands executed, and note which registries or tags are affected. Attach diffs or screenshots for UI or API-visible changes and ensure the Release Image workflow completes before requesting review.

## Security & Configuration Tips

Reference secrets via environment variables or GitHub Action secrets only; document expected keys in `.env.example`. Verify every Dockerfile exposes only the ports it needs, drop root privileges when upstream binaries allow it, and refresh base images whenever `schedule-watch-offical.yml` reports upstream updates.
