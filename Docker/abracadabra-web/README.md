# Abracadabra_demo


[![Docker Tags](https://img.shields.io/docker/v/funnyzak/abracadabra-web?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/abracadabra-web/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/abracadabra-web)](https://hub.docker.com/r/funnyzak/abracadabra-web/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/abracadabra-web.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/abracadabra-web/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/abracadabra-web.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/abracadabra-web/)

Abracadabra (魔曰) is an instant text encryption/de-sensitization tool, which can also be used for file encryption, based on C++ 11. More information can be found at [Abracadabra_demo](https://github.com/SheepChef/Abracadabra_demo).

This image is built with the `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm64/v8`, `inux/ppc64le`, `linux/s390x` architectures.

**Pulling Images:**

You can pull the images using the following commands:


```bash
docker pull funnyzak/abracadabra-web:latest
# GHCR
docker pull ghcr.io/funnyzak/abracadabra-web:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/abracadabra-web:latest
```

**Deployment**:

You can run this image with the following command:

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

![Abracadabra_demo](https://cdn.jsdelivr.net/gh/funnyzak/docker-release@main/Docker/abracadabra-web/abracadabra-demo.png)
