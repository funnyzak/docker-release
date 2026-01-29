# MySQL Dump

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/mysql-dump?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/mysql-dump)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/mysql-dump.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/mysql-dump.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump/)

mysql-dump is a professional MySQL backup tool that can backup all databases or specified databases. It supports multiple notification systems (Apprise, Bark), automatic cleanup of expired dump files, custom commands before and after backup, custom mysqldump options, compressed dump files, and crontab scheduling.

The image is available for multiple architectures, including `linux/amd64`, `linux/arm64`.

## Features

- Backup all databases or specified databases
- Multiple notification systems support (Apprise, Bark)
- Automatic cleanup of expired dump files
- Custom commands before and after backup
- Custom mysqldump options
- Compressed dump files support
- Flexible crontab scheduling
- Comprehensive logging and error handling
- Professional backup statistics and reporting
- YAML configuration file support
- Environment variable configuration
- Automatic MySQL client installation
- Cross-platform compatibility

## Configuration

The following environment variables are used to configure the container:

### Required

The following environment variables are required:

- `DB_HOST` - The database host. Required.
- `DB_USER` - The database user. Default: `root`.
- `DB_PASSWORD` - The database password. Required for most setups.

### Basic Options

The following environment variables are commonly used:

- `DB_PORT` - The database port. Default: `3306`.
- `DB_NAMES` - The database names to backup, space-separated (e.g., "dbname1 dbname2"). Leave blank to backup all databases.
- `EXPIRE_DAYS` - The retention time for backup files in days. Default: `180`.
- `DUMP_OPTS` - Custom mysqldump options. Default: `--ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert`.
- `DB_DUMP_CRON` - The crontab rule for backup scheduling. Default: `0 0 * * *` (daily at midnight).
- `DUMP_AT_STARTUP` - Whether to run backup at container startup. Default: `true`.
- `DB_DUMP_TARGET_DIR_PATH` - The directory path to store backup files. Default: `/backup`.
- `DB_FILE_EXTENSION` - The backup file extension. Default: `sql`.
- `ENABLE_COMPRESS` - Enable compression for backup files. Default: `false`.
- `SERVER_NAME` - The server name for notifications. Default: `mysql-backup-server`.

### Advanced Options

Advanced configuration options for power users:

- `LOG_DIR` - Directory for log files. If not specified, logs only to console.
- `VERBOSE` - Enable verbose debug output. Default: `false`.
- `CONFIG_FILE` - Path to YAML configuration file. Optional.
- `PRE_BACKUP_COMMAND` - Command to execute before backup. Optional.
- `POST_BACKUP_COMMAND` - Command to execute after backup. Optional.
- `TMP_DIR_PATH` - The directory path for temporary files. Default: `/tmp/backups`.
- `DB_DUMP_BY_SCHEMA` - Whether to use separate files for each schema. Default: `true`.

### Notifications

The container supports multiple notification systems:

#### Apprise Notifications
- `APPRISE_URL` - Apprise server URL for notifications. Optional.
- `APPRISE_TAGS` - Apprise notification tags. Default: `all`.

#### Bark Notifications  
- `BARK_URL` - Bark server URL for notifications. Optional.
- `BARK_KEY` - Bark device key for notifications. Optional.

### Legacy Environment Variables (Deprecated)

For backward compatibility, the following deprecated variables are still supported:

- `EXPIRE_HOURS` - **Deprecated**: Use `EXPIRE_DAYS` instead. Will be converted to days.
- `COMPRESS_EXTENSION` - **Deprecated**: Use `ENABLE_COMPRESS=true` instead.
- `STARTUP_COMMAND` - **Deprecated**: Use container init scripts instead.
- `BEFORE_DUMP_COMMAND` - **Deprecated**: Use `PRE_BACKUP_COMMAND` instead.
- `AFTER_DUMP_COMMAND` - **Deprecated**: Use `POST_BACKUP_COMMAND` instead.

## Usage

### Simple

Backup specific databases daily at midnight with 180-day retention:

```bash
docker run -d --name mysql-dump \
  -e DB_DUMP_CRON="0 0 * * *" \
  -e DB_HOST="localhost" \
  -e DB_PORT=3306 \
  -e DB_USER="root" \
  -e DB_PASSWORD="root" \
  -e DB_NAMES="dbname1 dbname2" \
  -e DUMP_OPTS="--ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert" \
  -e EXPIRE_DAYS=180 \
  -e ENABLE_COMPRESS=true \
  -v ./backup:/backup \
  funnyzak/mysql-dump
```

### With Notifications

Backup with Bark notifications:

```bash
docker run -d --name mysql-dump \
  -e DB_HOST="localhost" \
  -e DB_USER="root" \
  -e DB_PASSWORD="mypassword" \
  -e DB_NAMES="wordpress nextcloud" \
  -e BARK_URL="https://api.day.app" \
  -e BARK_KEY="your_device_key" \
  -e SERVER_NAME="Production DB Server" \
  -e ENABLE_COMPRESS=true \
  -e EXPIRE_DAYS=30 \
  -v ./backup:/backup \
  funnyzak/mysql-dump
```

### With Post-Backup Tools

Backup with automatic upload to S3 using command line arguments:

```bash
docker run -d --name mysql-dump \
  -e DB_HOST="localhost" \
  -e DB_USER="root" \
  -e DB_PASSWORD="mypassword" \
  -e DB_NAMES="wordpress nextcloud" \
  -e POST_BACKUP_COMMAND="/tools/upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3" \
  -v ./backup:/backup \
  -v ./tools:/tools:ro \
  funnyzak/mysql-dump
```

### Docker Compose

Complete setup with notifications and advanced features:

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      - DB_DUMP_CRON=0 2 * * *  # Run at 2 AM daily
      - DB_HOST=192.168.1.100
      - DB_PORT=3306
      - DB_USER=backup_user
      - DB_PASSWORD=secure_password
      - DB_NAMES=wordpress nextcloud
      - DUMP_OPTS=--ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert
      - EXPIRE_DAYS=180  # 180 days retention
      - ENABLE_COMPRESS=true
      - DB_DUMP_TARGET_DIR_PATH=/backup
      - DB_FILE_EXTENSION=sql
      - DUMP_AT_STARTUP=true
      - SERVER_NAME=production-mysql-server
      # Advanced options
      - LOG_DIR=/var/log/mysql-backup
      - VERBOSE=true
      # Notifications
      - BARK_URL=https://api.day.app
      - BARK_KEY=your_bark_device_key
      - APPRISE_URL=http://apprise:8000/notify/apprise
      - APPRISE_TAGS=mysql,backup
      # Custom commands
      - PRE_BACKUP_COMMAND=echo "Starting backup process"
      - POST_BACKUP_COMMAND=/tools/process_backups.sh --gpg-passphrase "encryption-key" /backup verify && /tools/upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3
    restart: unless-stopped
    volumes:
      - ./backup:/backup
      - ./logs:/var/log/cron
      - ./mysql-backup-logs:/var/log/mysql-backup
      - ./tools:/tools:ro
```

### Advanced Configuration with YAML

For complex setups, you can mount a custom YAML configuration file:

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - TZ=Asia/Shanghai
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - CONFIG_FILE=/config/mysql_backup.yaml
      - SERVER_NAME=production-backup
    volumes:
      - ./backup:/backup
      - ./config/mysql_backup.yaml:/config/mysql_backup.yaml
    restart: unless-stopped
```

Example `mysql_backup.yaml`:

```yaml
# MySQL Backup Configuration File
# Configuration file version: 1.0
# For parameter descriptions, please refer to the script documentation

# General configuration
general:
  # Instance name for notifications (default: hostname)
  name: ""

# MySQL connection configuration
mysql:
  host: "127.0.0.1"
  port: 3306
  user: "root"
  password: "root"
  # Database list for backup, empty string means backup all databases, or specify database names: "db1,db2,db3"
  databases: ""

# Backup configuration
backup:
  output_dir: "./"
  file_suffix: "sql"
  extra_options: "--ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert"
  compress: true
  # Backup retention days, 0 means skip backup file cleanup
  retention_days: 180

# Command execution configuration
commands:
  # Command to execute before backup, e.g.: "echo 'Starting backup...'"
  pre_backup: ""
  # Command to execute after backup, e.g.: "echo 'Backup completed'"
  post_backup: ""

# Logging configuration
logging:
  # Log directory, empty means no log file recording
  log_dir: ""
  # Enable verbose output
  verbose: false

# Notification configuration
notifications:
  apprise:
    # Apprise server URL, e.g.: "http://localhost:8000/notify/wgzryvfbmwoybymj"
    # Leave empty to disable Apprise notifications
    url: ""
    # Notification tags (default: "all")
    tags: "all"
  bark:
    # Bark server URL, e.g.: "https://api.day.app"
    # Leave empty to disable Bark notifications
    url: ""
    # Bark device key (required if bark url is set)
    # Get this from your Bark app
    device_key: ""
```

## Environment Variable Mapping

The container maps environment variables to the underlying `mysql_backup.sh` script:

| Container Variable | Script Parameter | Description |
|-------------------|------------------|-------------|
| `DB_HOST` | `--host` | MySQL server hostname |
| `DB_PORT` | `--port` | MySQL server port |
| `DB_USER` | `--user` | MySQL username |
| `DB_PASSWORD` | `--password` | MySQL password |
| `DB_NAMES` | `--databases` | Comma-separated database list |
| `DB_DUMP_TARGET_DIR_PATH` | `--output` | Backup output directory |
| `DB_FILE_EXTENSION` | `--suffix` | Backup file extension |
| `DUMP_OPTS` | `--extra-opts` | Additional mysqldump options |
| `EXPIRE_DAYS` | `--retention` | Retention period in days |
| `ENABLE_COMPRESS` | `--compress` | Enable compression |
| `SERVER_NAME` | `--name` | Instance name for notifications |
| `LOG_DIR` | `--log-dir` | Log directory path |
| `VERBOSE` | `--verbose` | Enable verbose output |
| `CONFIG_FILE` | `--config` | Configuration file path |
| `PRE_BACKUP_COMMAND` | `--pre-cmd` | Pre-backup command |
| `POST_BACKUP_COMMAND` | `--post-cmd` | Post-backup command |
| `APPRISE_URL` | `--apprise-url` | Apprise notification URL |
| `APPRISE_TAGS` | `--apprise-tags` | Apprise notification tags |
| `BARK_URL` | `--bark-url` | Bark notification URL |
| `BARK_KEY` | `--bark-key` | Bark device key |

## Post-Backup Tools

The container includes a set of optional tools that can be mounted and used with `POST_BACKUP_COMMAND` for advanced backup processing:

### Available Tools

- **upload_backups.sh** - Upload backup files to cloud storage (S3, FTP, SCP, WebDAV, OSS)
- **process_backups.sh** - Process backup files (encrypt, verify, split, convert, analyze)

### Tool Usage Examples

Upload to S3 after backup (using command line arguments):
```yaml
environment:
  - POST_BACKUP_COMMAND=/tools/upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3
volumes:
  - ./tools:/tools:ro
```

Verify and encrypt backups (using command line arguments):
```yaml
environment:
  - POST_BACKUP_COMMAND=/tools/process_backups.sh /backup verify && /tools/process_backups.sh --gpg-passphrase "my-encryption-key" /backup encrypt
volumes:
  - ./tools:/tools:ro
```

Combined operations (using command line arguments):
```yaml
environment:
  - POST_BACKUP_COMMAND=/tools/process_backups.sh /backup verify && /tools/upload_backups.sh --s3-bucket my-s3-bucket --aws-access-key KEY --aws-secret-key SECRET /backup s3 && /tools/upload_backups.sh --ftp-host ftp.example.com --ftp-user user --ftp-pass pass /backup ftp
volumes:
  - ./tools:/tools:ro
```

For detailed tool documentation, see `tools/README.md`.

## Backup Features

- **Automatic Database Discovery**: Backs up all databases if none specified
- **Selective Backup**: Specify individual databases to backup
- **Compression Support**: Automatic compression with tar.gz
- **Retention Management**: Automatic cleanup of old backup files
- **Error Handling**: Comprehensive error handling and logging
- **Notifications**: Real-time backup status notifications
- **Statistics**: Detailed backup statistics and reporting
- **Custom Commands**: Execute custom commands before/after backup
- **Post-Backup Tools**: Optional tools for upload and processing
- **YAML Configuration**: Support for complex configuration files
- **Cross-Platform**: Works on multiple architectures and operating systems
- **Auto-Installation**: Automatically installs MySQL client if needed

## Logging

All backup operations are logged. You can configure logging in several ways:

### Console Logging
By default, all logs are output to the console and captured by Docker.

### File Logging
Set `LOG_DIR` to enable file logging:

```bash
-e LOG_DIR=/var/log/mysql-backup
-v ./logs:/var/log/mysql-backup
```

### Verbose Logging
Enable detailed debug output:

```bash
-e VERBOSE=true
```

### Cron Logs
Cron execution logs are available at `/var/log/cron/cron.log`:

```bash
-v ./cron-logs:/var/log/cron
```

## Migration from Legacy Versions

If you're upgrading from an older version, here's how to migrate:

### Environment Variable Changes

| Old Variable | New Variable | Migration |
|-------------|-------------|-----------|
| `EXPIRE_HOURS` | `EXPIRE_DAYS` | Divide by 24 |
| `COMPRESS_EXTENSION` | `ENABLE_COMPRESS` | Set to `true` if was `zip` or `tar.gz` |
| `BEFORE_DUMP_COMMAND` | `PRE_BACKUP_COMMAND` | Direct replacement |
| `AFTER_DUMP_COMMAND` | `POST_BACKUP_COMMAND` | Direct replacement |

### Example Migration

Old configuration:
```yaml
- EXPIRE_HOURS=4320
- COMPRESS_EXTENSION=zip
- BEFORE_DUMP_COMMAND=echo "starting"
```

New configuration:
```yaml
- EXPIRE_DAYS=180
- ENABLE_COMPRESS=true
- PRE_BACKUP_COMMAND=echo "starting"
```

## Reference

- [MySQL mysqldump Documentation](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html)
- [Apprise Notification Service](https://github.com/caronc/apprise)
- [Bark iOS Notification App](https://github.com/Finb/Bark)
- [mysql_backup.sh Script](https://raw.githubusercontent.com/funnyzak/dotfiles/refs/heads/main/utilities/shell/mysql/mysql_backup.sh)