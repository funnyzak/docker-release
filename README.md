# Docker 镜像发布

本仓库主要用于发布各种 Docker 镜像。

## 目录

Docker 镜像的构建目录位于 `./Docker`，也可下载相应目录自行构建。

- `./Docker/y-webrtc-signaling`: 构建 `funnyzak/y-webrtc-signaling:latest` 镜像。
- `./Docker/abracadabra-web`: 构建 `funnyzak/abracadabra-web:latest` 镜像。
- `./Docker/libreoffice-server`: 构建 `funnyzak/libreoffice-server:latest` 镜像。
- `./Docker/request-hub`: 构建 `funnyzak/request-hub:latest` 镜像。

## 镜像

镜像已发布至 Docker Hub，并提供国内镜像地址：`registry.cn-beijing.aliyuncs.com`，同时同步至 GitHub Container Registry (`ghcr.io`)。

镜像提供 `latest` 和 `nightly` 标签（如有）。其他版本请参见 Docker Hub 或 GitHub Container Registry 页面。

现有镜像如下：

- `funnyzak/y-webrtc-signaling:latest`: y-webrtc-signaling 信令服务器镜像 ([Hub](https://hub.docker.com/r/funnyzak/y-webrtc-signaling))。
- `funnyzak/abracadabra-web:latest`: Abracadabra_demo 魔曰 Demo 镜像 ([Hub](https://hub.docker.com/r/funnyzak/abracadabra-web))。
- `funnyzak/libreoffice-server:latest`: LibreOffice-Server 镜像 ([Hub](https://hub.docker.com/r/funnyzak/libreoffice-server))。
- `funnyzak/request-hub:latest`: Request-Hub 镜像 ([Hub](https://hub.docker.com/r/funnyzak/request-hub))。

---

### y-webrtc-signaling

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling/latest)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling)
![Docker Version](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling/latest)

拉取镜像：
<details>
  
```bash
docker pull funnyzak/y-webrtc-signaling:latest
# GitHub 
docker pull ghcr.io/funnyzak/y-webrtc-signaling:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/y-webrtc-signaling:latest
```
</details>

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
```
</details>


更多信息请查看 [y-webrtc-signaling](./Docker/y-webrtc-signaling/README.md)。

---

### 魔曰 Demo

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/abracadabra-web/latest)](https://hub.docker.com/r/funnyzak/abracadabra-web/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/abracadabra-web)
![Docker Version](https://img.shields.io/docker/v/funnyzak/abracadabra-web/latest)

拉取镜像：
<details>

```bash
docker pull funnyzak/abracadabra-web:latest
# GitHub
docker pull ghcr.io/funnyzak/abracadabra-web:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/abracadabra-web:latest
```

</details>

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

启动后，如下图：

![Abracadabra_demo](Docker/abracadabra-web/abracadabra-demo.png)

</details>

更多信息请查看 [Abracadabra_demo](Docker/abracadabra-web/README.md)。

---

### LibreOffice-Server

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/libreoffice-server/latest)](https://hub.docker.com/r/funnyzak/libreoffice-server/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/libreoffice-server)
![Docker Version](https://img.shields.io/docker/v/funnyzak/libreoffice-server/latest)

拉取镜像：
<details>

```bash
docker pull funnyzak/libreoffice-server:latest
# GitHub
docker pull ghcr.io/funnyzak/libreoffice-server:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/libreoffice-server:latest
```

</details>

部署示例：

<details>

Docker 部署示例：
```bash
docker run -d --name libreoffice -p 3000:3000 -p 3001:8038 funnyzak/libreoffice-server:latest
```

Docker Compose 部署示例：
```yaml

version: "3.1"
services:
  libreoffice:
    image: funnyzak/libreoffice-server
    container_name: libreoffice
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Asia/Shanghai
    # volumes:
    #   - ./media/fonts:/usr/share/fonts/custom # 自定义字体
    ports:
      - 3000:3000 # libreoffice web editor
      - 3001:8038 # web api
    restart: unless-stopped
```

</details>

更多信息请查看 [LibreOffice-Server](Docker/libreoffice-server/README.md)。

---

### Request-Hub

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/request-hub/latest)](https://hub.docker.com/r/funnyzak/request-hub/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/request-hub)
![Docker Version](https://img.shields.io/docker/v/funnyzak/request-hub/latest)

拉取镜像：
<details>

```bash
docker pull funnyzak/request-hub:latest
# GitHub
docker pull ghcr.io/funnyzak/request-hub:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/request-hub:latest
```

</details>

部署示例：

<details>

Docker 部署示例：
```bash
docker run -d --name request-hub -p 8080:8080 funnyzak/request-hub:latest
```

Docker Compose 部署示例：
```yaml
version: '3.1'
services:
  requesthub:
    image: funnyzak/request-hub
    container_name: requesthub
    restart: always
    environment:
        - TZ=Asia/Shanghai
        - LANG=C.UTF-8
        - CONFIG_YML=/config.yml
        - NO_WEB=false
        - PORT=54321
        - MAX_REQUESTS=1024
        - USER_NAME=hello
        - PASSWORD=world
    volumes:
      - ./config.yml:/config.yml
    ports:
      - 80:54321
```

</details>

更多信息请查看 [Request-Hub](Docker/request-hub/README.md)。

## 贡献

欢迎贡献更多的 Docker 镜像构建目录。
