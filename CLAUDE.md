# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Docker release repository that builds and publishes Docker images for various services to multiple registries (Docker Hub, GitHub Container Registry, and AliCloud Container Registry). The repository contains a monorepo structure with each service having its own directory under `./Docker/`.

## Architecture

- **Docker Images**: Each service has its own directory under `./Docker/` containing a Dockerfile and associated files
- **GitHub Actions**: Automated CI/CD workflows for building and publishing images
- **Multi-Platform Support**: Images are built for multiple architectures (amd64, arm64, arm/v7, etc.)
- **Multi-Registry Publishing**: Images are published to Docker Hub, GHCR, and AliCloud registries

## Common Development Commands

### Building Images Locally

To build any Docker image locally:

```bash
# Navigate to the service directory
cd ./Docker/[service-name]

# Build the image
docker build -t [service-name]:latest .
```

### Testing Images

Most services include docker-compose.yml files for local testing:

```bash
# Navigate to service directory
cd ./Docker/[service-name]

# Start with docker-compose
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down
```

### GitHub Actions Workflows

The repository uses several GitHub Actions workflows:

- **release.yml**: Main workflow for building and publishing Docker images
- **dispatch-*.yml**: Workflows for specific service releases
- **schedule-watch-offical.yml**: Scheduled workflow to watch for upstream updates
- **check-offical-release.yml**: Workflow to check for new official releases

### Service-Specific Operations

Each service directory contains:
- `Dockerfile`: Container build instructions
- `README.md`: Service-specific documentation and deployment instructions
- `docker-compose.yml` (optional): Local testing configuration
- `entrypoint.sh` (optional): Custom container entrypoint scripts

## Working with Services

### Adding New Services

1. Create a new directory under `./Docker/[service-name]`
2. Add a Dockerfile following the repository's conventions
3. Add a README.md with deployment instructions
4. Update the main README.md to include the new service
5. Create a dispatch workflow if needed

### Updating Existing Services

1. Modify the Dockerfile or related files in the service directory
2. Test locally using docker-compose if available
3. Update README.md if necessary
4. The automated workflows will handle building and publishing

## Key Files and Directories

- `./Docker/`: Contains all service directories
- `.github/workflows/`: CI/CD workflows
- `README.md`: Main repository documentation with service list and deployment examples

## Build Args and Environment Variables

The build system automatically injects these build args:
- `BUILD_DATE`: Build timestamp
- `VCS_REF`: Git commit SHA
- `VERSION`: Image version (inferred from tag when not "latest")

Additional build args can be specified through workflow inputs.

## Multi-Registry Support

Images are automatically tagged and published to:
- Docker Hub: `funnyzak/[service-name]:[tag]`
- GitHub Container Registry: `ghcr.io/funnyzak/[service-name]:[tag]`
- AliCloud Container Registry: `registry.cn-beijing.aliyuncs.com/funnyzak/[service-name]:[tag]`