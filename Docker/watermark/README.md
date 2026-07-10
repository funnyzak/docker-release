# Watermark


[![Docker Tags](https://img.shields.io/docker/v/funnyzak/watermark?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/watermark/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/watermark)](https://hub.docker.com/r/funnyzak/watermark/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/watermark.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/watermark/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/watermark.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/watermark/)

Web纯前端图片加水印。用来在各种证件上添加 **“仅用于办理XXXX，他用无效。”**，防止证件被他人盗用！

## Pulling Images

You can pull the images using the following commands:


```bash
docker pull funnyzak/watermark:latest
# GHCR
docker pull ghcr.io/funnyzak/watermark:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/watermark:latest
```

## Deploy Via Docker

```bash
docker run -d -p 3000:80 --name watermark funnyzak/watermark:latest
```

另外也可以使用国内镜像加速：

```bash
docker run -d -p 3000:80 --name watermark registry.cn-beijing.aliyuncs.com/funnyzak/watermark:latest
```

## Preview

在线预览：[https://watermark.yycc.dev](https://watermark.yycc.dev)

![预览](https://cdn.jsdelivr.net/gh/funnyzak/watermark/.github/assets/preview.png)

