# CRON

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/cron?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/cron)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)

cron is a lightweight service that runs in the background and executes scheduled tasks. It builds on the official `alpine` image and includes `dcron` as the cron service. The image is available for multiple architectures, including `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/riscv64`, `linux/s390x`.

Installed packages: `dcron`, `ca-certificates`, `curl`, `tar`, `tzdata`, `bash`, `zip`, `unzip`, `rsync`, `rclone`.

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
- **EXTRA_PACKAGES**: Optional, Specify extra packages to install. Default is empty. e.g. `mysql-client mariadb-connector-c`.

**CRON_STRINGS example**:

Single job:

```bash
# Run every minute
* * * * * /scripts/echo.sh >> /var/log/cron/cron.log 2>&1
```

Multiple jobs:
```bash
# Multiple jobs
* * * * * /scripts/request.sh >> /var/log/cron/cron.log 2>&1\n* * * * * /scripts/echo.sh >> /var/log/cron/cron.log 2>&1
```

### Crontab Files

crontab files are located in **/etc/cron.d**, you can mount a volume to this directory to add your own crontab files.

For example, you can create a file named `my-cron` with the following content:

```bash
* * * * * /scripts/request.sh >> /var/log/cron/cron.log 2>&1
```

> **Note**: Default log file should be `/var/log/cron/cron.log`. You should forward all script output to this file.


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
  -e 'EXTRA_PACKAGES=git' \
  funnyzak/cron

docker run --name="cron5" -d \
  -e 'CRON_STRINGS=* * * * * /scripts/request.sh >> /var/log/cron/cron.log 2>&1' \
  -e 'STARTUP_COMMANDS=/scripts/echo.sh >> /var/log/cron/cron.log 2>&1' \
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
      - ./cron/scripts:/scripts
      - ./cron/crontabs:/etc/cron.d
```