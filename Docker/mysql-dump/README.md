# MySQL Dump

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/mysql-dump?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/mysql-dump)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/mysql-dump.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/mysql-dump.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)

mysql-dump is a simple MySQL backup tool that can backup all databases or specified databases. It can push message with pushoo and delete expired dump files. It supports custom commands before and after the dump, custom mysqldump options, compressed dump files, and crontab rules. The image is available for multiple architectures, including `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/riscv64`, `linux/s390x`.

## Features

- Backup all databases or specified databases.
- Push message with pushoo.
- Delete expired dump files.
- Support custom commands before and after the dump.
- Support custom mysqldump options.
- Support compressed dump files.
- Support crontab rules.

## Configuration

The following environment variables are used to configure the container:

### Required

The following environment variables are required:

- `DB_DUMP_CRON` - The crontab rule of backup. Default: `0 0 * * *`. Optional.
- `DB_HOST` - The database host. Required.
- `DB_PORT` - The database port. Default: `3306`.
- `DB_USER` - The database user. Required.
- `DB_PASSWORD` - The database password. Required.
- `DB_NAMES` - The database name of the dump.For example: dbname1 dbname2.Leave a blank default to all databases.
- `DUMP_OPTS` - The mysqldump options. Optional. Default: `--single-transaction --quick --lock-tables=false`.
- `EXPIRE_HOURS` - The expired time of the dump files. Default: `4320`.

### Optional

The following environment variables are optional:

- `DUMP_AT_STARTUP` - Whether to dump at startup. Default: `true`.
- `DB_DUMP_TARGET_DIR_PATH` - The directory path to store the dump files. Default: `/backup`.
- `TMP_DIR_PATH` - The directory path to store the temporary files. Default: `/tmp/backups`.
- `DB_DUMP_BY_SCHEMA` - Whether to use separate files for each schema in the compressed file (true), if so, you need to set DB_NAMES. Or single dump file (FALSE). Default: `true`.
- `DB_FILE_EXTENSION` - The dump file extension. Default: `sql`.
- `COMPRESS_EXTENSION` - The compress file extension. Default: `zip`.
- `STARTUP_COMMAND` - The command to execute at startup. Optional.
- `BEFORE_DUMP_COMMAND` - The command to execute before the dump. Optional.
- `AFTER_DUMP_COMMAND` - The command to execute after the dump. Optional.

### Pushoo

If you want to receive message with pushoo, you need to set `PUSHOO_PUSH_PLATFORMS` and `PUSHOO_PUSH_TOKENS`.

- `SERVER_NAME` - The server name, used for pushoo message. Optional.
- `PUSHOO_PUSH_PLATFORMS` - The push platforms, separated by commas. Optional.
- `PUSHOO_PUSH_TOKENS` - The push tokens, separated by commas. Optional.

For more details, please refer to [pushoo-cli](https://github.com/funnyzak/pushoo-cli).

## Usage

### Simple

For example, you want to backup database `dbname1` and `dbname2` every day at 00:00, and delete expired dump files after 180 days.

```bash
docker run -d --name mysql-dump \
  -e DB_DUMP_CRON="0 0 * * *" \
  -e DB_HOST="localhost" \
  -e DB_PORT=3306 \
  -e DB_USER="root" \
  -e DB_PASSWORD="root" \
  -e DB_NAMES="dbname1 dbname2" \
  -e DB_DUMP_OPTS="--single-transaction --quick --lock-tables=false" \
  -e EXPIRE_HOURS=4320 \
  -v ./backup:/backup \
```

### Compose

For example, you want to backup database `cms_new` every day at 00:00, and delete expired dump files after 180 days.

```yaml
version: '3'
services:
  dbback:
    image: funnyzak/mysql-dump
    privileged: false
    container_name: app-db-backup
    tty: true
    mem_limit: 1024m
    environment:
        - TZ=Asia/Shanghai
        - LANG=C.UTF-8
        # Cron
        - DB_DUMP_CRON=0 0 * * *
        # MySQL Connection
        - DB_HOST=192.168.50.21
        - DB_NAMES=cms_new
        - DB_USER=root
        - DB_PASSWORD=helloworld
        - DB_PORT=1009
        - DUMP_OPTS=--single-transaction
        # Expire Hours
        - EXPIRE_HOURS=4320
        # COMMAND
        - STARTUP_COMMAND=echo "startup"
        - BEFORE_DUMP_COMMAND=echo "before dump"
        - AFTER_DUMP_COMMAND=echo "after dump"
        # optional
        - DB_DUMP_TARGET_DIR_PATH=/backup
        - DB_DUMP_BY_SCHEMA=true
        - DB_FILE_EXTENSION=sql
        - COMPRESS_EXTENSION=zip
        - DUMP_AT_STARTUP=true
        # pushoo 
        - SERVER_NAME=app-db-backup
        - PUSHOO_PUSH_PLATFORMS=dingtalk,bark
        - PUSHOO_PUSH_TOKENS=dingtalk:xxxx,bark:xxxx
    restart: on-failure
    volumes:
      - ./bak/mysql_db:/backup
```