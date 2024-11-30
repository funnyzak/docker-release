# CRON

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/cron?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/cron)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)

**CRON** is a lightweight Docker image containing Cron, based on Alpine Linux. It supports multiple architectures, including `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/riscv64`, and `linux/s390x`.

Following packages are installed by default:

- `certificates`
- `bash`
- `curl`
- `wget`
- `rsync`
- `git`
- `zip`
- 
## Pull the Image

```bash
# Docker Hub
docker pull funnyzak/cron:latest
# GitHub Container Registry
docker pull ghcr.io/funnyzak/cron:latest
# Aliyun Registry
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/cron:latest
```

## How to Use

### Environment Variables

- **CRON_STRINGS**: Crontab strings, separated by `\n`.
- **STARTUP_COMMANDS**: Commands to run before starting the cron service.

**CRON_STRINGS** example:

```bash
# Run every minute
* * * * * /scripts/request.sh
# Multiple jobs
* * * * * /scripts/request.sh\n* * * * * /scripts/request2.sh
```

## Crontab Files

crontab files are located in **/etc/cron.d**, you can mount a volume to this directory to add your own crontab files.

config file example `/etc/cron.d/request`:

```bash
* * * * * /scripts/request.sh >> /var/log/cron/request.log 2>&1
* * * * * /scripts/request.sh >> /var/log/cron/request2.log 2>&1
```

> **Note**: Default log file is `/var/log/cron/cron.log`.

## Usage

### Using Crontab Files

```bash
docker run --name="cron" -d \
  -v ./crontabs:/etc/cron.d \
  -v ./scripts:/scripts \
  funnyzak/cron
```

### Using CRON_STRINGS

```bash
docker run --name="cron2" -d \
  -e 'CRON_STRINGS=* * * * * /scripts/echo.sh >> /var/log/cron/cron.log 2>&1' \
  -e 'STARTUP_COMMANDS=echo "Hello, World!"' \
  funnyzak/cron
```

### Fetch Google Homepage Every Minute

```bash
docker run --name="cron3" -d \
  -e 'CRON_STRINGS=* * * * * echo $(date) >> /var/log/cron/cron.log' 2>&1 \
  -e 'STARTUP_COMMANDS=echo "Hello, World!"' \
  funnyzak/cron
```

### Compose Example

```yaml
version: '3'
services:
  cron:
    image: funnyzak/cron
    privileged: true
    container_name: cron
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      - CRON_TAIL=1
      - CRON_STRINGS=* * * * * /scripts/echo.sh >> /var/log/cron/cron.log 2>&1
    restart: on-failure
    volumes:
      - ./cron/scripts:/scripts     # Scripts to execute
      - ./cron/crontabs:/etc/cron.d     # Crontab files
      - ./cron/logs:/var/log/cron     # Log files
```