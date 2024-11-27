# Docker 镜像发布

此项目主要用于发布各种 Docker 镜像。

所有 Docker 镜像均包含中国镜像地址，前缀为：`registry.cn-beijing.aliyuncs.com`。

## 目录

所有 Docker 镜像的构建目录位于 `./Docker` 目录下。

- `./Docker/y-webrtc-signaling`: 构建 `funnyzak/y-webrtc-signaling:latest` Docker 镜像。

## 镜像

### y-webrtc-signaling

![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling/latest)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling)
![Docker Version](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling/latest)

拉取镜像：

```bash
docker pull funnyzak/y-webrtc-signaling:latest
# 中国镜像地址
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/y-webrtc-signaling:latest
```

部署示例
<details>

Docker 部署示例：
```bash
docker run -d --name y-webrtc-signaling -p 4444:4444 funnyzak/y-webrtc-signaling:latest
```

Docker Compose 部署示例：
```yaml
version: '3.1'
services:
  y-webrtc-signaling:
    container_name: y-webrtc-signaling
    image: funnyzak/y-webrtc-signaling:latest
    restart: always
    network_mode: bridge
    ports:
      - "4444:4444"
    environment:
      - PORT=4444
```
</details>

更多信息请查看 [y-webrtc-signaling](./Docker/y-webrtc-signaling/README.md)。

## 贡献

欢迎贡献更多的 Docker 镜像构建目录。