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
./upload_backups.sh [backup_directory] [upload_type]
```

**环境变量配置：**

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
./process_backups.sh [backup_directory] [operation_type]
```

**环境变量配置：**

加密操作：
```bash
GPG_PASSPHRASE=your_encryption_passphrase
```

## Docker Compose 集成示例

### 上传到 S3

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
      # S3 配置
      - S3_BUCKET=my-backup-bucket
      - S3_PREFIX=mysql-backups
      - AWS_ACCESS_KEY=your_access_key
      - AWS_SECRET_KEY=your_secret_key
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 加密备份文件

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
      - POST_BACKUP_COMMAND=/tools/process_backups.sh /backup encrypt
      - GPG_PASSPHRASE=your_encryption_passphrase
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 上传到 AList

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
      - POST_BACKUP_COMMAND=/tools/upload_backups.sh /backup alist
      # AList 配置
      - ALIST_API_URL=https://alist.example.com
      - ALIST_USERNAME=your_username
      - ALIST_PASSWORD=your_password
      - ALIST_REMOTE_PATH=/mysql-backups
    volumes:
      - ./backup:/backup
      - ./tools:/tools:ro
    restart: unless-stopped
```

### 组合操作

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
      - POST_BACKUP_COMMAND=/tools/process_backups.sh /backup verify && /tools/upload_backups.sh /backup s3
      # S3 配置
      - S3_BUCKET=my-backup-bucket
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

# 2. 加密备份文件
/tools/process_backups.sh /backup encrypt

# 3. 上传到多个位置
/tools/upload_backups.sh /backup s3
/tools/upload_backups.sh /backup ftp
/tools/upload_backups.sh /backup alist

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

## 注意事项

1. **权限设置**：确保脚本有执行权限
   ```bash
   chmod +x tools/*.sh
   ```

2. **环境变量**：根据使用的服务配置相应的环境变量

3. **网络访问**：确保容器能够访问目标上传服务

4. **安全性**：
   - 不要在日志中暴露敏感信息
   - 使用强密码和密钥
   - 定期轮换访问凭证

5. **测试**：在生产环境使用前，先在测试环境验证脚本功能

## 故障排除

- 检查容器日志：`docker logs mysql-dump`
- 验证环境变量配置
- 确认网络连接和权限设置
- 查看工具脚本的输出日志 