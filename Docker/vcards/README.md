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

## Usage

### Docker Deployment

Use the default contacts data, and map to local 5232 port.
```bash
docker run -d --name vcard \
    -p 5232:5232 \
    funnyzak/vcards:latest
```


## Setup on iOS and Mac

Deploy the vCards service, and add the following information to the CardDAV account:

- Server: `vcards.youdeployed.com`
- User name: `cn`
- Password: `cn` or whatever you want

Steps:
1. [iOS](https://support.apple.com/zh-sg/guide/iphone/ipha0d932e96/ios): `Settings` - `Contacts` - `Accounts` - `Add Account` - `Other` - `Add CardDAV Account`.
2. [Mac](https://support.apple.com/zh-cn/guide/contacts/adrb7e5aaa2a/mac): `Contacts` - `Settings` - `Accounts` - `Other Contacts Accounts`.

When syncing is complete, you can see the contacts in the Contacts app. 

![Contacts](https://github.com/user-attachments/assets/d1557e12-655d-4173-93af-9843e51bf78c)


More information can be found at [vCards](https://github.com/metowolf/vCards).