# vCards

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/vcards?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/vcards/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/vcards)](https://hub.docker.com/r/funnyzak/vcards/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/vcards.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/vcards/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/vcards.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/vcards/)

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
- `/app/vcards/collection-root/cn/`: The root folder of the contacts.

## Usage

### Docker Deployment

Use the default contacts data, and map to local 5232 port.
```bash
docker run -d --name vcard \
    -p 5232:5232 \
    funnyzak/vcards:latest
```

Use custom contacts data, and map to local 5232 port.
```bash
docker run -d --name vcard \
    -p 5232:5232 \
    -v ./vcards:/app/vcards/collection-root/cn/ \
    funnyzak/vcards:latest
```

Sync every day at 00:00, and download new data to `./downloads` folder.
```bash
docker run -d --name vcard \
    -p 5232:5232 \
    -e SYNC_CRON="0 0 * * *" \
    -v ./downloads:/app/downloads \
    funnyzak/vcards:latest
```

Sync every day at 00:00, and download new data to `./downloads` folder, and add custom contacts data to `vcards` folder.
```bash
docker run -d --name vcard \
    -p 5232:5232 \
    -e SYNC_CRON="0 0 * * *" \
    -v ./downloads:/app/downloads \
    -v ./vcards:/app/vcards/collection-root/cn/ \
    funnyzak/vcards:latest
```
**Note**: You must download the contacts data from [vCards](https://github.com/metowolf/vCards) and put it in the `vcards` folder.


### Docker Compose Deployment

```yaml
version: '3.7'

services:
  vcard:
    image: funnyzak/vcards:latest
    container_name: vcard
    ports:
      - 5232:5232
    environment:
      - SYNC_CRON=0 0 * * *
    volumes:
      - ./downloads:/app/downloads
```

## Setup on iOS and Mac

Deploy the vCards service, and add the following information to the CardDAV account:

- Server: `vcards.youdeployed.com`
- User name: `cn`
- Password: `cn` or whatever you want

Steps:
1. [iOS](https://support.apple.com/zh-sg/guide/iphone/ipha0d932e96/ios): `Settings` - `Contacts` - `Accounts` - `Add Account` - `Other` - `Add CardDAV Account`.
2. [Mac](https://support.apple.com/zh-cn/guide/contacts/adrb7e5aaa2a/mac): `Contacts` - `Settings` - `Accounts` - `Other Contacts Accounts`.


More information can be found at [vCards](https://github.com/metowolf/vCards).