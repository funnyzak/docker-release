# Alibaba Canal

Alibaba Canal, a component for incremental subscription and consumption of binlogs in MySQL.  Images are built for `linux/amd64` and `linux/arm64` architectures.

The following images are available:

| Image | Tag | Size | Pulls |
|---|---|---|---|
| Canal-Adapter | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/canal-adapter/latest?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter/tags) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-adapter/latest?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter/tags) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-adapter?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter) |
| Canal-Deployer | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/canal-deployer/latest?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer/tags) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-deployer/latest?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer/tags) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-deployer?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer) |
| Canal-Admin | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/canal-admin/latest?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin/tags) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-admin/latest?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin/tags) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-admin?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin) |


All Images are installed under the `/opt/canal` directory.  For example, the `canal-adapter` service is installed under `/opt/canal/canal-adapter`.


## Pulling Images

You can pull the images using the following commands:

```bash
# Docker Hub
docker pull funnyzak/canal-adapter:latest
docker pull funnyzak/canal-deployer:latest
docker pull funnyzak/canal-admin:latest

# GitHub Container Registry (GHCR)
docker pull ghcr.io/funnyzak/canal-adapter:latest
docker pull ghcr.io/funnyzak/canal-deployer:latest
docker pull ghcr.io/funnyzak/canal-admin:latest

# Alibaba Cloud Container Registry
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-adapter:latest
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-deployer:latest # Corrected typo here
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-admin:latest
```

## Build

### canal-adapter

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="adapter" \
  -t funnyzak/canal-adapter:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="adapter" \
  -t funnyzak/canal-adapter:1.1.8-alpha-3 ./canal-adapter
```

### canal-admin

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="admin" \
  -t funnyzak/canal-admin:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="admin" \
  -t funnyzak/canal-admin:1.1.8-alpha-3 ./canal-adapter
```

### canal-deployer

```bash
docker build \
  --build-arg VERSION="1.1.7" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="deployer" \
  -t funnyzak/canal-deployer:1.1.7 ./canal-adapter

# BUild alpha version
docker build \
  --build-arg VERSION="1.1.8-alpha-3" \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg CANAL_NAME="deployer" \
  -t funnyzak/canal-deployer:1.1.8-alpha-3 ./canal-adapter
```

For more information about Canal, please refer to the [official Canal repository](https://github.com/alibaba/canal/releases).
