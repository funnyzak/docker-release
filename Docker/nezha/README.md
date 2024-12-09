# NeZha


[![Docker Tags](https://img.shields.io/docker/v/funnyzak/nezha-dashboard?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nezha-dashboard/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/nezha-dashboard)](https://hub.docker.com/r/funnyzak/nezha-dashboard/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/nezha-dashboard.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nezha-dashboard/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nezha-dashboard.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nezha-dashboard/)

A NeZha dashboard docker image.

Build with the  `linux/arm64`, `linux/amd64` architectures.


## Pull

```bash
docker pull funnyzak/nezha-dashboard:latest
# GHCR
docker pull ghcr.io/funnyzak/nezha-dashboard:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/nezha-dashboard:latest
```


## Usage

### Run NeZha Dashboard with Docker

```bash
docker run -d \
  --name nezha-dashboard \
  --restart always \
  -v ./data:/dashboard/data \
  -p 8008:8008 \
  funnyzak/nezha-dashboard
```