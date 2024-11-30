# CRON

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/cron?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/cron)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron/)

**CRON** is a lightweight Docker image containing Cron, based on Alpine Linux. It supports multiple architectures, including `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/riscv64`, and `linux/s390x`.

## Pull the Image

```bash
# Docker Hub
docker pull funnyzak/cron:latest
# GitHub Container Registry
docker pull ghcr.io/funnyzak/cron:latest
# Aliyun Registry
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/cron:latest
```

## Environment Variables

- **CRON_STRINGS**: Cron job strings. Use `\n` for newlines. (Default: undefined)
- **CRON_TAIL**: If defined, outputs the cron log file to `stdout` using `tail`. (Default: undefined)

By default, cron runs in the foreground.

## Installed Packages

The following packages are installed by default:

- `certificates`
- `bash`
- `curl`
- `wget`
- `rsync`
- `git`
- `zip`

## Cron Files

**/etc/cron.d**: Directory to mount custom crontab files.

When the image runs, files in `/etc/cron.d` are copied to `/var/spool/cron/crontab`.

If **CRON_STRINGS** is defined, the script creates the file `/var/spool/cron/crontab/CRON_STRINGS`.

## Logs

By default, the log file is located at `/var/log/cron/cron.log`.

## Usage

### Running a Single Cron Job

```bash
docker run --name="cron-sample" -d \
  -v /path/to/app/conf/crontabs:/etc/cron.d \
  -v /path/to/app/scripts:/scripts \
  funnyzak/cron
```

### Using Scripts and CRON_STRINGS

```bash
docker run --name="cron-sample" -d \
  -e 'CRON_STRINGS=* * * * * /scripts/myapp-script.sh' \
  -v /path/to/app/scripts:/scripts \
  funnyzak/cron
```

### Fetching a URL with Cron Every Minute

```bash
docker run --name="cron-sample" -d \
  -e 'CRON_STRINGS=* * * * * wget --spider https://sample.dockerhost/cron-jobs' \
  funnyzak/cron
```

---

### Docker Compose Example

```yaml
version: '3'
services:
  cron:
    image: funnyzak/cron
    privileged: true
    container_name: cron
    logging:
      driver: 'json-file'
      options:
        max-size: '1g'
    tty: true
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      - CRON_TAIL=1  # Tail cron log
      - CRON_STRINGS=* * * * * /scripts/echo.sh
    restart: on-failure
    volumes:
      - ./scripts:/scripts     # Scripts to execute
      - ./cron:/etc/cron.d     # Crontab files
      - ./db:/db               # Log files
```

For more details, please refer to the [docker-compose.yml](example/docker-compose.yml) file.
