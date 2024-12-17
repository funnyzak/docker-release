# vCards

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/vCards?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/vCards/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/vCards)](https://hub.docker.com/r/funnyzak/vCards/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/vCards.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/vCards/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/vCards.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/vCards/)

导入常用联系人头像，优化 iOS 来电、信息界面体验。更多信息请访问 [vCards](https://github.com/metowolf/vCards)。

## Pulling Images

You can pull the images using the following commands:

```bash
docker pull funnyzak/vcards:latest
# GHCR 
docker pull ghcr.io/funnyzak/vcards:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/vcards:latest
```

## Environment Variables

- `SYNC_CRON`: Sync schedule, default is `0 0 * * *`, which means sync every day at 00:00. More information can be found at [crontab.guru](https://crontab.guru/).

## Volumes

- `/app/downloads`: New data will be downloaded to this folder.

## Usage

### Docker Deployment

```bash
docker run -d --name vcard \
    -p 5232:5232 \
    -e SYNC_CRON="0 0 * * *" \
    -v ./downloads:/app/downloads \
    funnyzak/vcards:latest
```

More information can be found at [vCards](https://github.com/metowolf/vCards).