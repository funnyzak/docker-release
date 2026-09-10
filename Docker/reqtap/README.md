# reqtap

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/reqtap?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/reqtap/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/reqtap)](https://hub.docker.com/r/funnyzak/reqtap/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/reqtap.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/reqtap/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/reqtap.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/reqtap/)

ReqTap 是一个强大的、跨平台的、零依赖的命令行工具，用于即时捕获、检查和转发 HTTP 请求。它可以作为您的终极"请求黑洞"和"Webhook 调试器"，用于无缝的 HTTP 请求分析。

**主要特性：**
- **即时响应** - 接收请求后立即返回 200 OK，确保客户端操作不阻塞
- **丰富的可视化输出** - 美观的彩色终端输出，高亮显示 HTTP 方法、请求头和请求体
- **安全优先** - 智能二进制内容检测和自动敏感信息脱敏
- **异步转发** - 高性能异步请求转发到多个目标 URL
- **全面日志** - 双重日志系统，支持控制台输出和结构化文件日志，自动轮转
- **灵活配置** - 支持命令行参数、YAML 配置文件和环境变量
- **跨平台** - 单一可执行文件，原生支持 Windows、macOS 和 Linux
- **零依赖** - 自包含二进制文件，无需外部运行时要求

**Pulling Images:**

您可以使用以下命令拉取镜像：

```bash
docker pull funnyzak/reqtap:latest
# GHCR 
docker pull ghcr.io/funnyzak/reqtap:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/reqtap:latest
```

## Usage

### Docker Deployment

#### 基本使用

```bash
docker run -d --name reqtap_server -p 38888:38888 --restart unless-stopped funnyzak/reqtap:latest
```

#### 自定义端口

```bash
docker run -d --name reqtap_server -p 8080:38888 --restart unless-stopped funnyzak/reqtap:latest --port 38888
```

#### 启用文件日志

```bash
docker run -d --name reqtap_server \
  -p 38888:38888 \
  -v $(pwd)/logs:/var/log/reqtap \
  --restart unless-stopped \
  funnyzak/reqtap:latest \
  --log-file-enable \
  --log-file-path /var/log/reqtap/reqtap.log
```

#### 使用配置文件

```bash
docker run -d --name reqtap_server \
  -p 38888:38888 \
  -v $(pwd)/config.yaml:/etc/reqtap/config.yaml \
  -v $(pwd)/logs:/var/log/reqtap \
  --restart unless-stopped \
  funnyzak/reqtap:latest \
  --config /etc/reqtap/config.yaml
```

#### 转发到多个目标

```bash
docker run -d --name reqtap_server \
  -p 38888:38888 \
  --restart unless-stopped \
  funnyzak/reqtap:latest \
  --forward-url http://localhost:3000/webhook \
  --forward-url https://api.example.com/ingest
```

#### 自定义监听路径

```bash
docker run -d --name reqtap_server \
  -p 38888:38888 \
  --restart unless-stopped \
  funnyzak/reqtap:latest \
  --path /webhook/
```

### Docker Compose Deployment

#### 基本配置

```yaml
version: '3.7'
services:
  reqtap:
    image: funnyzak/reqtap:latest
    container_name: reqtap_server
    ports:
      - "38888:38888"
    restart: unless-stopped
```

#### 完整配置（包含日志和配置）

```yaml
version: '3.7'
services:
  reqtap:
    image: funnyzak/reqtap:latest
    container_name: reqtap_server
    ports:
      - "38888:38888"
    volumes:
      - ./config.yaml:/etc/reqtap/config.yaml
      - ./logs:/var/log/reqtap
    command:
      - --config
      - /etc/reqtap/config.yaml
      - --log-file-enable
      - --log-file-path
      - /var/log/reqtap/reqtap.log
    restart: unless-stopped
```

#### 带转发目标的配置

```yaml
version: '3.7'
services:
  reqtap:
    image: funnyzak/reqtap:latest
    container_name: reqtap_server
    ports:
      - "38888:38888"
    command:
      - --forward-url
      - http://localhost:3000/webhook
      - --forward-url
      - https://api.example.com/ingest
      - --log-level
      - debug
    restart: unless-stopped
```

## Configuration

### 配置文件示例

创建 `config.yaml` 文件：

```yaml
# 服务器配置
server:
  port: 38888
  path: "/"

# 日志配置
log:
  level: "info"  # trace, debug, info, warn, error, fatal, panic
  file_logging:
    enable: true
    path: "/var/log/reqtap/reqtap.log"
    max_size_mb: 10      # 单个文件最大大小（MB）
    max_backups: 5       # 保留的旧日志文件数量
    max_age_days: 30     # 最大保留天数
    compress: true       # 压缩旧日志文件

# 转发配置
forward:
  urls:
    - "http://localhost:3000/webhook"
    - "https://api.example.com/ingest"
  timeout: 30           # 请求超时时间（秒）
  max_retries: 3        # 最大重试次数
  max_concurrent: 10    # 最大并发转发数
```

### 环境变量配置

所有配置选项都可以通过带有 `REQTAP_` 前缀的环境变量设置：

```bash
docker run -d --name reqtap_server \
  -p 38888:38888 \
  -e REQTAP_SERVER_PORT=38888 \
  -e REQTAP_SERVER_PATH="/webhook" \
  -e REQTAP_LOG_LEVEL=debug \
  -e REQTAP_FORWARD_URLS="http://localhost:3000/webhook,https://api.example.com/ingest" \
  --restart unless-stopped \
  funnyzak/reqtap:latest
```

## 测试

完成安装后，您可以使用以下命令测试 ReqTap：

```bash
# 发送测试请求
curl -X POST http://localhost:38888/webhook \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello, ReqTap!"}'

# 查看日志
docker logs -f reqtap_server
```

## 主要命令参数

- `-p, --port int` - 监听端口（默认 38888）
- `--path string` - URL 路径前缀（默认 "/"）
- `-l, --log-level string` - 日志级别：trace, debug, info, warn, error, fatal, panic（默认 "info"）
- `--log-file-enable` - 启用文件日志
- `--log-file-path string` - 日志文件路径（默认 "./reqtap.log"）
- `-f, --forward-url stringSlice` - 要转发请求到的目标 URL
- `-c, --config string` - 配置文件路径（默认 "config.yaml"）
- `-h, --help` - 显示帮助信息
- `-v, --version` - 显示版本信息

更多信息请访问 [reqtap](https://github.com/funnyzak/reqtap)。

