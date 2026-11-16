# MySQL Backup Tools

这个目录包含了配合 mysql-dump Docker 镜像使用的工具脚本集合，可以通过 `POST_BACKUP_COMMAND` 环境变量调用。

## 工具列表

### 1. upload_backups.sh - 备份文件上传工具

用于将备份文件上传到各种云存储服务。

**支持的上传方式：**
- `s3` - Amazon S3
- `ftp` - FTP 服务器
- `scp` - SSH/SCP 传输
- `webdav` - WebDAV 服务
- `oss` - 阿里云对象存储
- `alist` - AList 网盘存储

**使用方法：**
```bash
# 基本用法
./upload_backups.sh [OPTIONS] [backup_directory] [upload_type]

# 显示帮助信息
./upload_backups.sh --help
```

**命令行参数（优先于环境变量）：**

通用参数：
- `-h, --help` - 显示帮助信息
- `backup_directory` - 备份文件目录（默认：/backup）
- `upload_type` - 上传方式（默认：s3）

S3 参数：
- `--s3-bucket` - S3 存储桶名称
- `--s3-prefix` - S3 前缀/文件夹路径
- `--aws-access-key` - AWS 访问密钥
- `--aws-secret-key` - AWS 密钥

FTP 参数：
- `--ftp-host` - FTP 服务器地址
- `--ftp-user` - FTP 用户名
- `--ftp-pass` - FTP 密码
- `--ftp-path` - FTP 远程路径

SCP 参数：
- `--ssh-host` - SSH 服务器地址
- `--ssh-user` - SSH 用户名
- `--ssh-key` - SSH 私钥文件路径
- `--ssh-path` - SSH 远程路径

WebDAV 参数：
- `--webdav-url` - WebDAV 服务器 URL
- `--webdav-user` - WebDAV 用户名
- `--webdav-pass` - WebDAV 密码

OSS 参数：
- `--oss-bucket` - OSS 存储桶名称
- `--oss-prefix` - OSS 前缀/文件夹路径
- `--oss-access-key` - OSS 访问密钥
- `--oss-secret-key` - OSS 密钥

AList 参数：
- `--alist-api-url` - AList API URL
- `--alist-username` - AList 用户名
- `--alist-password` - AList 密码
- `--alist-remote-path` - AList 远程路径（默认：/mysql-backups）

**命令行参数示例：**

```bash
# 上传到 S3（使用命令行参数）
./upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3

# 上传到 FTP
./upload_backups.sh --ftp-host ftp.example.com --ftp-user backup_user --ftp-pass secret123 --ftp-path /mysql-backups /backup ftp

# 上传到 AList
./upload_backups.sh --alist-api-url https://alist.example.com --alist-username admin --alist-password admin123 --alist-remote-path /database-backups /backup alist

# 上传到 SCP
./upload_backups.sh --ssh-host backup.example.com --ssh-user backup --ssh-key /path/to/key.pem --ssh-path /home/backup/mysql /backup scp
```

**环境变量配置（作为后备）：**

S3 上传：
```bash
S3_BUCKET=my-backup-bucket
S3_PREFIX=mysql-backups
AWS_ACCESS_KEY=your_access_key
AWS_SECRET_KEY=your_secret_key
```

FTP 上传：
```bash
FTP_HOST=ftp.example.com
FTP_USER=username
FTP_PASS=password
FTP_PATH=/backups
```

SCP 上传：
```bash
SSH_HOST=backup.example.com
SSH_USER=backup
SSH_KEY=/path/to/ssh/key
SSH_PATH=/home/backup/mysql
```

WebDAV 上传：
```bash
WEBDAV_URL=https://webdav.example.com/backups
WEBDAV_USER=username
WEBDAV_PASS=password
```

OSS 上传：
```bash
OSS_BUCKET=my-oss-bucket
OSS_PREFIX=mysql-backups
OSS_ACCESS_KEY=your_access_key
OSS_SECRET_KEY=your_secret_key
```

AList 上传：
```bash
ALIST_API_URL=https://alist.example.com
ALIST_USERNAME=your_username
ALIST_PASSWORD=your_password
ALIST_REMOTE_PATH=/mysql-backups
```

### 2. alist_upload.sh - AList 文件上传脚本

专门用于上传文件到 AList 网盘存储的独立脚本。

**主要特性：**
- API 认证和令牌缓存（24小时有效期）
- 支持命令行参数和环境变量配置
- 自动令牌刷新机制
- 多文件上传支持
- 详细的错误处理和日志记录

**使用方法：**
```bash
./alist_upload.sh [OPTIONS] <file_path> [file_path2] ...
```

**环境变量配置：**
```bash
ALIST_API_URL=https://alist.example.com
ALIST_USERNAME=your_username
ALIST_PASSWORD=your_password
```

### 3. process_backups.sh - 备份文件处理工具

用于对备份文件进行各种处理操作。

**支持的操作：**
- `encrypt` - 加密备份文件
- `verify` - 验证备份文件完整性
- `split` - 分割大型备份文件
- `convert` - 转换备份格式
- `analyze` - 分析备份内容

**使用方法：**
```bash
# 基本用法
./process_backups.sh [OPTIONS] [backup_directory] [operation_type]

# 显示帮助信息
./process_backups.sh --help
```

**命令行参数（优先于环境变量）：**

- `-h, --help` - 显示帮助信息
- `--gpg-passphrase` - GPG 加密密码短语
- `--max-file-size` - 文件分割的最大大小（默认：1G）
- `backup_directory` - 备份文件目录（默认：/backup）
- `operation_type` - 处理操作类型（默认：verify）

**命令行参数示例：**

```bash
# 验证备份文件
./process_backups.sh /backup verify

# 使用命令行参数加密备份文件
./process_backups.sh --gpg-passphrase "my-secret-passphrase" /backup encrypt

# 分割大文件，设置最大大小为 500MB
./process_backups.sh --max-file-size 500M /backup split

# 分析备份内容
./process_backups.sh /backup analyze

# 转换备份格式
./process_backups.sh /backup convert
```

**环境变量配置（作为后备）：**

加密操作：
```bash
GPG_PASSPHRASE=your_encryption_passphrase
MAX_FILE_SIZE=1G
```

## Docker Compose 集成示例

### 使用命令行参数上传到 S3

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - DB_NAMES=wordpress nextcloud
      - POST_BACKUP_COMMAND=/tools/upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 使用命令行参数加密备份文件

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - POST_BACKUP_COMMAND=/tools/process_backups.sh --gpg-passphrase "my-encryption-key" /backup encrypt
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 使用命令行参数上传到 AList

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - DB_NAMES=wordpress nextcloud
      - POST_BACKUP_COMMAND=/tools/upload_backups.sh --alist-api-url https://alist.example.com --alist-username admin --alist-password admin123 --alist-remote-path /mysql-backups /backup alist
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 组合操作（使用命令行参数）

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - POST_BACKUP_COMMAND=/tools/process_backups.sh --gpg-passphrase "secret123" /backup verify && /tools/upload_backups.sh --s3-bucket my-backup-bucket --aws-access-key AKIAIOSFODNN7EXAMPLE --aws-secret-key wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY /backup s3
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 环境变量方式（向后兼容）

```yaml
version: '3'
services:
  mysql-dump:
    image: funnyzak/mysql-dump
    container_name: mysql-dump
    environment:
      - DB_HOST=mysql-server
      - DB_USER=backup_user
      - DB_PASSWORD=backup_password
      - DB_NAMES=wordpress nextcloud
      - POST_BACKUP_COMMAND=/tools/upload_backups.sh /backup s3
      # S3 配置（环境变量方式）
      - S3_BUCKET=my-backup-bucket
      - S3_PREFIX=mysql-backups
      - AWS_ACCESS_KEY=your_access_key
      - AWS_SECRET_KEY=your_secret_key
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

## 自定义脚本

你可以基于这些工具脚本创建自己的自定义脚本：

```bash
#!/bin/bash
# custom_post_backup.sh

# 1. 验证备份文件
/tools/process_backups.sh /backup verify

# 2. 使用命令行参数加密备份文件
/tools/process_backups.sh --gpg-passphrase "my-secret-key" /backup encrypt

# 3. 上传到多个位置（使用命令行参数）
/tools/upload_backups.sh --s3-bucket my-s3-bucket --aws-access-key KEY --aws-secret-key SECRET /backup s3
/tools/upload_backups.sh --ftp-host ftp.example.com --ftp-user user --ftp-pass pass /backup ftp
/tools/upload_backups.sh --alist-api-url https://alist.example.com --alist-username admin --alist-password admin123 /backup alist

# 4. 清理本地未加密文件
find /backup -name "*.sql" -mtime -1 -delete

echo "Custom post-backup processing completed"
```

然后在 Docker Compose 中使用：

```yaml
environment:
  - POST_BACKUP_COMMAND=/tools/custom_post_backup.sh
volumes:
  - ./tools:/tools:ro
```

## 优先级说明

**配置优先级（从高到低）：**
1. **命令行参数** - 最高优先级
2. **环境变量** - 作为后备选项
3. **默认值** - 最低优先级

这种设计确保了：
- 命令行参数始终优先于环境变量
- 环境变量在命令行参数未提供时作为后备
- 向后兼容现有的环境变量配置

## 注意事项

1. **权限设置**：确保脚本有执行权限
   ```bash
   chmod +x tools/*.sh
   ```

2. **参数优先级**：命令行参数优先于环境变量，环境变量优先于默认值

3. **网络访问**：确保容器能够访问目标上传服务

4. **安全性**：
   - 不要在日志中暴露敏感信息
   - 使用强密码和密钥
   - 定期轮换访问凭证
   - 命令行参数中的敏感信息可能在进程列表中可见，生产环境建议使用环境变量

5. **测试**：在生产环境使用前，先在测试环境验证脚本功能

6. **帮助信息**：使用 `--help` 参数查看详细的使用说明

## 故障排除

- 检查容器日志：`docker logs mysql-dump`
- 验证命令行参数和环境变量配置
- 使用 `--help` 参数查看正确的使用方法
- 确认网络连接和权限设置
- 查看工具脚本的输出日志 