# y-webrtc-signaling

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/y-webrtc-signaling.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling/)


Y-WebRTC is a WebRTC signaling server. More information can be found at [y-webrtc-signaling](https://github.com/lobehub/y-webrtc-signaling).

This image is built with the `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/s390x` architectures.

**Pulling Images:**

You can pull the images using the following commands:

<details>
<summary>Docker Pull Commands</summary>

```bash
docker pull funnyzak/y-webrtc-signaling:latest
# GHCR 
docker pull ghcr.io/funnyzak/y-webrtc-signaling:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/y-webrtc-signaling:latest
```
</details>

**Deployment**:

You can run this image with the following command:

<details>
<summary>Docker Run Commands</summary>

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