# Docker Release 🚀

Build images and publish to Docker Hub, GitHub Container Registry, and AliCloud Image Service.

Aliyun mirror: `registry.cn-beijing.aliyuncs.com`.

## Images

Images are provided with the `latest` and `nightly` tags (if available). For other versions, please refer to the Docker Hub or GHCR Container Registry pages.

Current images are as follows:

- `funnyzak/nginx:latest`: The Nginx image ([Hub](https://hub.docker.com/r/funnyzak/nginx)).
- `funnyzak/y-webrtc-signaling:latest`: The y-webrtc-signaling signaling server image ([Hub](https://hub.docker.com/r/funnyzak/y-webrtc-signaling)).
- `funnyzak/abracadabra-web:latest`: The Abracadabra_demo magic demo image ([Hub](https://hub.docker.com/r/funnyzak/abracadabra-web)).
- `funnyzak/libreoffice-server:latest`: The LibreOffice-Server image ([Hub](https://hub.docker.com/r/funnyzak/libreoffice-server)).
- `funnyzak/request-hub:latest`: The Request-Hub image ([Hub](https://hub.docker.com/r/funnyzak/request-hub)).
- `funnyzak/canal-adapter:latest`: The Canal-Adaptor image ([Hub](https://hub.docker.com/r/funnyzak/canal-adapter)).
- `funnyzak/canal-deployer:latest`: The Canal-Deployer image ([Hub](https://hub.docker.com/r/funnyzak/canal-deployer)).
- `funnyzak/canal-admin:latest`: The Canal-Admin image ([Hub](https://hub.docker.com/r/funnyzak/canal-admin)).
- `funnyzak/hello-world:latest`: The Hello-World image ([Hub](https://hub.docker.com/r/funnyzak/hello-world)).


## Directories

Images build directory is located at ./Docker. You can also download the directory to build the images yourself.

- `./Docker/nginx`: Build the [Nginx](https://nginx.org) service image.
- `./Docker/y-webrtc-signaling`: Build the [y-webrtc-signaling](https://github.com/lobehub/y-webrtc-signaling) service image.
- `./Docker/abracadabra-web`: Build the [Abracadabra_demo](https://github.com/SheepChef/Abracadabra_demo) service image.
- `./Docker/libreoffice-server`: Build the [LibreOffice-Server](https://github.com/funnyzak/libreoffice-server) service image.
- `./Docker/request-hub`: Build the [Request-Hub](https://github.com/kyledayton/requesthub) service image.
- `./Docker/canal`: Build the [Alibaba Canal](https://github.com/alibaba/canal) service images.

## Services

### nginx

[![Image Size](https://img.shields.io/docker/image-size/funnyzak/nginx/latest)](https://hub.docker.com/r/funnyzak/nginx/tags)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx)](https://hub.docker.com/r/funnyzak/nginx)
[![Docker Version](https://img.shields.io/docker/v/funnyzak/nginx/latest)](https://hub.docker.com/r/funnyzak/nginx/tags)

A nginx docker image with secure configurations and some useful modules, such as `ngx_http_geoip_module`, `ngx_http_image_filter_module`, `ngx_http_perl_module`, `ngx_http_xslt_filter_module`, `ngx_mail_module`, `ngx_stream_geoip_module`, `ngx_stream_module`, `ngx-fancyindex`, `headers-more-nginx-module`, etc.

Build with the  `linux/arm64`, `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8` architectures.

Already installed modules:

- [ngx_http_geoip_module.so](https://nginx.org/en/docs/http/ngx_http_geoip_module.html)
- [ngx_http_image_filter_module.so](https://nginx.org/en/docs/http/ngx_http_image_filter_module.html)
- ngx_http_perl_module.so
- ngx_http_xslt_filter_module.so
- ngx_mail_module.so
- ngx_stream_geoip_module.so
- ngx_stream_module.so
- [ngx-fancyindex](https://github.com/aperezdc/ngx-fancyindex)
- [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module)
- ...


**Pulling the Image**:

<details>

```bash
docker pull funnyzak/nginx:latest
# GHCR
docker pull ghcr.io/funnyzak/nginx:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/nginx:latest
```

</details>

**Deployment**:

<details>

**Docker Deployment**:
```bash
docker run -d -t -i --name nginx --restart on-failure \
  -v /path/to/conf.d:/etc/nginx/conf.d \
  -p 1688:80 \
  funnyzak/nginx
```

**Docker Compose Deployment**:
```yaml

version: "3.3"

services:
  nginx:
    image: funnyzak/nginx
    container_name: nginx
    environment:
      - TZ=Asia/Shanghai
    volumes:
      - ./nginx/conf.d:/etc/nginx/conf.d
    restart: on-failure
    ports:
      - 1688:80
```

</details>

For more information, please check [Nginx](https://github.com/funnyzak/docker-release/tree/main/Docker/nginx/README.md).

### y-webrtc-signaling

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling/latest)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling)
![Docker Version](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling/latest)

Y-WebRTC is a WebRTC signaling server. More information can be found at [y-webrtc-signaling](https://github.com/lobehub/y-webrtc-signaling).

This image is built with the `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/s390x` architectures.

**Pulling the Image**:
<details>

```bash
docker pull funnyzak/y-webrtc-signaling:latest
# GHCR 
docker pull ghcr.io/funnyzak/y-webrtc-signaling:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/y-webrtc-signaling:latest
```
</details>

**Deployment**:
<details>

**Docker Deployment**:
```bash
docker run -d --name y-webrtc-signaling -p 4444:4444 funnyzak/y-webrtc-signaling:latest
```

**Docker Compose Deployment**:
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

For more information, please check [y-webrtc-signaling](https://github.com/funnyzak/docker-release/tree/main/Docker/y-webrtc-signaling/README.md).

---

### Abracadabra Demo

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/abracadabra-web/latest)](https://hub.docker.com/r/funnyzak/abracadabra-web/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/abracadabra-web)
![Docker Version](https://img.shields.io/docker/v/funnyzak/abracadabra-web/latest)

Abracadabra (魔曰) is an instant text encryption/de-sensitization tool, which can also be used for file encryption, based on C++ 11. More information can be found at [Abracadabra_demo](https://github.com/SheepChef/Abracadabra_demo).

This image is built with the `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm64/v8`, `inux/ppc64le`, `linux/s390x` architectures.

**Pulling the Image**:
<details>

```bash
docker pull funnyzak/abracadabra-web:latest
# GHCR
docker pull ghcr.io/funnyzak/abracadabra-web:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/abracadabra-web:latest
```
</details>

**Deployment**:
<details>

**Docker Deployment**:
```bash

docker run -d --name abracadabra-web -p 8080:80 funnyzak/abracadabra-web:latest
# ghcr
docker run -d --name abracadabra-web -p 8080:80 ghcr.io/funnyzak/abracadabra-web:latest
# aliyun
docker run -d --name abracadabra-web -p 8080:80 registry.cn-beijing.aliyuncs.com/funnyzak/abracadabra-web:latest
```

**Docker Compose Deployment**:
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

**After Startup**:

![Abracadabra_demo](https://github.com/funnyzak/docker-release/tree/main/Docker/abracadabra-web/abracadabra-demo.png)

</details>

For more information, please check [Abracadabra_demo](https://github.com/funnyzak/docker-release/tree/main/Docker/abracadabra-web/README.md).

---

### LibreOffice-Server

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/libreoffice-server/latest)](https://hub.docker.com/r/funnyzak/libreoffice-server/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/libreoffice-server)
![Docker Version](https://img.shields.io/docker/v/funnyzak/libreoffice-server/latest)

LibreOffice Service service for editing documents online and converting Word to PDF via Web API. This service contains a Web API based on [LibreOffice service App](https://github.com/funnyzak/libreoffice-server).

This image is built with the `linux/amd64`, `linux/arm64` architectures.

**Pulling the Image**:
<details>

```bash
docker pull funnyzak/libreoffice-server:latest
# GHCR
docker pull ghcr.io/funnyzak/libreoffice-server:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/libreoffice-server:latest
```
</details>

**Deployment**:
<details>

**Docker Deployment**:
```bash
docker run -d --name libreoffice -p 3000:3000 -p 3001:8038 funnyzak/libreoffice-server:latest
```

**Docker Compose Deployment**:
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
    #   -./media/fonts:/usr/share/fonts/custom # 自定义字体
    ports:
      - 3000:3000 # libreoffice web editor
      - 3001:8038 # web api
    restart: unless-stopped
```
</details>

For more information, please check [LibreOffice-Server](https://github.com/funnyzak/docker-release/tree/main/Docker/libreoffice-server/README.md).

---

### Request-Hub

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/request-hub/latest)](https://hub.docker.com/r/funnyzak/request-hub/tags)
![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/request-hub)
![Docker Version](https://img.shields.io/docker/v/funnyzak/request-hub/latest)

[RequestHub](https://github.com/kyledayton/requesthub) is used to receive, record, and proxy HTTP requests. This image supports `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/s390x`.

**Pulling the Image**:
<details>

```bash
docker pull funnyzak/request-hub:latest
# GHCR
docker pull ghcr.io/funnyzak/request-hub:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/request-hub:latest
```
</details>

**Deployment**:
<details>

**Docker Deployment**:
```bash
docker run -d --name request-hub -p 8080:8080 funnyzak/request-hub:latest
```

**Docker Compose Deployment**:
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
      -./config.yml:/config.yml
    ports:
      - 80:54321
```

**After Deployment**:

![Request-Hub](https://github.com/funnyzak/docker-release/tree/main/Docker/request-hub/request-hub-demo.jpg)

</details>

For more information, please check [Request-Hub](https://github.com/funnyzak/docker-release/tree/main/Docker/request-hub/README.md).

---

### Canal

Canal is a component for incremental subscription and consumption of binlogs in Alibaba's MySQL database.

These images are built with the `linux/amd64`, `linux/arm64` architectures.

Currently, three images are provided:

[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-adapter/latest?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-deployer/latest?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer/tags)
[![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-admin/latest?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin/tags)

[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-adapter?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-deployer?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-admin?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin)

[![Docker Version](https://img.shields.io/docker/v/funnyzak/canal-adapter/latest?label=Canal-Adapter)](https://hub.docker.com/r/funnyzak/canal-adapter/tags)
[![Docker Version](https://img.shields.io/docker/v/funnyzak/canal-deployer/latest?label=Canal-Deployer)](https://hub.docker.com/r/funnyzak/canal-deployer/tags)
[![Docker Version](https://img.shields.io/docker/v/funnyzak/canal-admin/latest?label=Canal-Admin)](https://hub.docker.com/r/funnyzak/canal-admin)

All are installed under the `/opt/canal` directory. For, the installation directory of the `canal-adapter` service is under `/opt/canal/canal-adapter`.

**Pulling the Images**:

<details>

```bash
docker pull funnyzak/canal-adapter:latest
docker pull funnyzak/canal-deployer:latest
docker pull funnyzak/canal-admin:latest
# GHCR
docker pull ghcr.io/funnyzak/canal-adapter:latest
docker pull ghcr.io/funnyzak/canal-deployer:latest
docker pull ghcr.io/funnyzak/canal-admin:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-adapter:latest
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-deDeployer:latest
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/canal-admin:latest
```
</details>

For more information, please refer to the [Canal official repository](https://github.com/alibaba/canal/releases).

## Contributions

If you have any questions or suggestions, please feel free to open an issue or pull request.