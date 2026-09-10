# BRT Cloud Data Forwarder Docker

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/brt-data-forwarder?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/brt-data-forwarder/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/brt-data-forwarder)](https://hub.docker.com/r/funnyzak/brt-data-forwarder/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/brt-data-forwarder.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/brt-data-forwarder/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/brt-data-forwarder.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/brt-data-forwarder/)

一个轻量级的数据转发服务器 Docker 镜像，专门设计用于接收专有格式的环境传感器数据，处理特殊指标的智能缓存逻辑，并转发到多个目标服务器。

## 核心特性

- **智能数据转发** - 接收专有格式传感器数据并转发到多个目标服务器
- **智能缓存管理** - 自动处理无效值（FFFF、FFFE），使用上次有效值替换
- **灵活认证机制** - 支持URL参数和HTTP头两种认证方式
- **设备数据查询** - 提供RESTful API查询设备缓存数据
- **完整日志系统** - 支持日志轮转和详细的操作记录
- **高可靠性** - 串行转发、重试机制、异常容错处理
- **零配置启动** - 提供完整的配置示例，开箱即用

## 快速开始

### 基本使用

```bash
# 拉取镜像
docker pull funnyzak/brt-data-forwarder:latest

# 运行容器
docker run -d \
  --name brt-data-forwarder \
  -p 8080:8080 \
  -v $(pwd)/config.yaml:/app/config.yaml:ro \
  -v $(pwd)/data:/app/data \
  -v $(pwd)/logs:/app/logs \
  funnyzak/brt-data-forwarder:latest
```

### 使用 Docker Compose

```yaml
version: '3.8'
services:
  brt-data-forwarder:
    image: funnyzak/brt-data-forwarder:latest
    container_name: brt-data-forwarder
    ports:
      - "8080:8080"
    volumes:
      - ./config.yaml:/app/config.yaml:ro
      - ./data:/app/data
      - ./logs:/app/logs
    environment:
      - AUTH_TOKEN_1=${AUTH_TOKEN_1}
      - AUTH_TOKEN_2=${AUTH_TOKEN_2}
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `FLASK_HOST` | `0.0.0.0` | Flask 服务器监听地址 |
| `FLASK_PORT` | `8080` | Flask 服务器监听端口 |
| `FLASK_DEBUG` | `false` | Flask 调试模式 |

**注意**：日志和缓存配置通过 `config.yaml` 文件管理，不支持环境变量覆盖。

### 配置文件

容器需要挂载配置文件 `config.yaml`，参考以下配置：

```yaml
# 服务器配置
server:
  host: "0.0.0.0"
  port: 8080
  debug: false

# 数据接收配置
receiver:
  path: "/receive_brt_data"
  auth:
    enabled: true
    query_param: "auth_token"
    header: "Authorization"
    valid_tokens:
      - "your-secret-token-123"

# 转发配置
forwarder:
  targets:
    - url: "http://192.168.0.120/post_data"
      timeout: 5
    - url: "http://192.168.0.121/api/data?abc=123"
      timeout: 5
  retry:
    enabled: true
    max_attempts: 1

# 缓存配置
cache:
  file_path: "./data/cache.json"
  special_metrics:
    - co2
    - hcho
    - lux
    - uva_class
    - uva_raw
    - voc
  invalid_patterns:
    - "FFFF"
    - "FFFE"

# 日志配置
logging:
  level: "INFO"
  file_path: "./logs/forwarder.log"
  max_bytes: 10485760
  backup_count: 7
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
```

## API 接口

### 数据接收接口

**POST** `/receive_brt_data`

**认证方式（二选一）：**
- URL参数：`?auth_token=your-secret-token-123`
- HTTP头：`Authorization: your-secret-token-123`

**请求体格式：**
```json
{
  "seq_no": 1,
  "time": 1758615013,
  "cmd": 267,
  "cbid": "F5:73:4A:F5:A8:CC:68:B9:D3:D5:7A:64",
  "devices": [
    {
      "ble_addr": "E7E8F5F8C9A4",
      "addr_type": 0,
      "scan_rssi": -93,
      "scan_time": 1758615011,
      "humi": "013B",
      "temp": "010D",
      "co2": "0234",
      "voc": "FFFF"
    }
  ]
}
```

### 设备数据查询接口

**GET** `/api/device/{ble_addr}`

**示例：**
```bash
curl http://localhost:8080/api/device/E7E8F5F8C9A4 \
  -H "Authorization: your-secret-token-123"
```

### 健康检查接口

**GET** `/health`

**响应：**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "uptime": 3600
}
```

## 测试

### 基本功能测试

```bash
# 健康检查
curl http://localhost:8080/health

# 发送测试数据
curl -X POST http://localhost:8080/receive_brt_data \
  -H "Content-Type: application/json" \
  -H "Authorization: your-secret-token-123" \
  -d '{
    "seq_no": 1,
    "time": 1758615013,
    "cmd": 267,
    "cbid": "F5:73:4A:F5:A8:CC:68:B9:D3:D5:7A:64",
    "devices": [
      {
        "ble_addr": "E7E8F5F8C9A4",
        "addr_type": 0,
        "scan_rssi": -93,
        "scan_time": 1758615011,
        "humi": "013B",
        "temp": "010D",
        "co2": "0234",
        "voc": "FFFF"
      }
    ]
  }'

# 查询设备数据
curl http://localhost:8080/api/device/E7E8F5F8C9A4 \
  -H "Authorization: your-secret-token-123"
```

## 监控和日志

### 查看容器日志

```bash
# 查看实时日志
docker logs -f brt-data-forwarder

# 查看应用日志
docker exec brt-data-forwarder tail -f /app/logs/forwarder.log
```

### 容器健康状态

```bash
# 查看健康状态
docker inspect brt-data-forwarder | grep -A 10 "Health"

# 查看容器状态
docker ps
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 修改端口映射
   docker run -p 8081:8080 funnyzak/brt-data-forwarder:latest
   ```

2. **认证失败 (401)**
   - 检查配置文件中的 token 配置
   - 确认请求中包含正确的认证信息

3. **配置文件错误**
   - 确保配置文件格式正确
   - 检查文件权限和挂载路径

4. **权限问题**
   - 确保数据目录有正确的写权限
   - 检查用户权限设置

## 构建镜像

```bash
# 构建镜像
docker build -t funnyzak/brt-data-forwarder:latest .

# 构建多架构镜像
docker buildx build --platform linux/amd64,linux/arm64 \
  -t funnyzak/brt-data-forwarder:latest .
```

## 许可证

MIT License - 详见 [LICENSE](../../LICENSE) 文件。
