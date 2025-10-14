# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive Docker release repository that provides optimized Docker images for various services and applications. All images are automatically published to multiple registries (Docker Hub, GitHub Container Registry, AliCloud Container Registry) with multi-architecture support (linux/amd64, linux/arm64, etc.).

## Architecture

### Directory Structure
- `./Docker/[service-name]/`: Individual service containerizations
  - `Dockerfile`: Container build instructions
  - `README.md`: Service documentation
  - `docker-compose.yml`: Local testing configuration (optional)
  - Supporting configuration files and scripts

### CI/CD Pipeline
The repository uses GitHub Actions with the main workflow in `.github/workflows/release.yml` that:
- Supports workflow calls and manual dispatch
- Builds multi-architecture Docker images
- Publishes to three registries automatically
- Includes build args for VERSION, VCS_REF, BUILD_DATE
- Sends notifications via Apprise

### Common Build Pattern
Most Dockerfiles follow this pattern:
- Multi-stage builds for optimization
- Standardized labels (org.label-schema.*)
- Support for VERSION, VCS_REF, BUILD_DATE build args
- Health checks where applicable
- Security-focused minimal base images

## Common Development Commands

### Build and Test Locally
```bash
# Build a specific service image
docker build -t funnyzak/[service-name] ./Docker/[service-name]/

# Test with docker-compose (if available)
cd ./Docker/[service-name]/
docker-compose up -d

# View logs
docker-compose logs -f
```

### Manual Release (for testing)
```bash
# Trigger release workflow manually
gh workflow run release.yml \
  --field build_context='./Docker/[service-name]' \
  --field docker_tags='latest,test' \
  --field build_platforms='linux/amd64,linux/arm64'
```

### Registry Operations
```bash
# Pull from different registries
docker pull funnyzak/[service-name]:latest
docker pull ghcr.io/funnyzak/[service-name]:latest
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/[service-name]:latest
```

## Key Development Patterns

### Dockerfile Standards
- Use multi-stage builds for size optimization
- Include proper labels with version, build date, VCS ref
- Set appropriate WORKDIR and USER directives
- Add HEALTHCHECK instructions where applicable
- Use specific version tags instead of `latest` for base images

### Service Integration
- Many services clone from upstream Git repositories
- VERSION build argument controls git checkout
- Default to latest stable version if VERSION not specified
- Include VERSION file in container for reference

### Configuration Management
- Environment variables for runtime configuration
- Default values provided in Dockerfile
- Volume mounts for persistent data where needed
- Port exposure documented in README files

## Workflow Parameters

The main release workflow accepts these parameters:
- `build_context`: Path to Docker build directory
- `docker_tags`: Comma-separated list of tags (default: latest)
- `docker_file_name`: Dockerfile name (default: Dockerfile)
- `build_platforms`: Target platforms (default: linux/amd64)
- `docker_image_name`: Override image name (default: directory name)
- `build_args`: Additional build arguments

## Adding New Services

1. Create directory: `./Docker/[service-name]/`
2. Add Dockerfile following project patterns
3. Add comprehensive README.md with usage examples
4. Test locally with docker-compose if needed
5. Update main README.md service list
6. Trigger release workflow for testing

## Multi-Registry Publishing

All images are automatically published to:
- Docker Hub: `funnyzak/[service]:[tag]`
- GitHub Container Registry: `ghcr.io/funnyzak/[service]:[tag]`
- Aliyun Container Registry: `registry.cn-beijing.aliyuncs.com/funnyzak/[service]:[tag]`