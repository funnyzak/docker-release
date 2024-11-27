# Docker 镜像发布

项目主要用于发布各种 Docker 镜像。

## 目录

所有 Docker 镜像的构建目录位于 `./Docker` 目录下，也可以下载对应的目录自行构建。

- `./Docker/y-webrtc-signaling`: 构建 `funnyzak/y-webrtc-signaling:latest` Docker 镜像。

## 镜像说明

所有镜像均发布在 Docker Hub 上，并提供国内镜像地址：`registry.cn-beijing.aliyuncs.com`。此外，镜像也同步发布在 GitHub Container Registry (`ghcr.io`) 上。

当前镜像包含：

- `funnyzak/y-webrtc-signaling:latest`: y-webrtc-signaling 信令服务器镜像。
- `funnyzak/abracadabra-web:latest`: Abracadabra_demo 魔曰 Demo 镜像。

### y-webrtc-signaling

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling/latest)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling)
![Docker Version](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling/latest)

拉取镜像：

```bash
docker pull funnyzak/y-webrtc-signaling:latest
# GitHub 
docker pull ghcr.io/funnyzak/y-webrtc-signaling:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/y-webrtc-signaling:latest
```

部署示例：

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





### 魔曰 Demo

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/abracadabra-web/latest)](https://hub.docker.com/r/funnyzak/abracadabra-web/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/abracadabra-web)
![Docker Version](https://img.shields.io/docker/v/funnyzak/abracadabra-web/latest)

拉取镜像：`docker pull funnyzak/abracadabra-web:latest`

```bash
docker pull funnyzak/abracadabra-web:latest
# GitHub
docker pull ghcr.io/funnyzak/abracadabra-web:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/abracadabra-web:latest
```

部署示例：

<details>

Docker 部署示例：
```bash
docker run -d --name abracadabra-web -p 8080:80 funnyzak/abracadabra-web:latest
```

Docker Compose 部署示例：
```yaml
version: '3.1'

services:
  abracadabra-web:
    container_name: abracadabra-web
    image: funnyzak/abracadabra-web:latest
    restart: always
    network_mode: bridge
    ports:
      - "8080:80"
```
</details>

更多信息请查看 [Abracadabra_demo](Docker/abracadabra-web/README.md)。

## 贡献

欢迎贡献更多的 Docker 镜像构建目录。