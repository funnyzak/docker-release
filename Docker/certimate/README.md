# certmate

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/certmate?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/certmate/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/certmate)](https://hub.docker.com/r/funnyzak/certmate/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/certmate.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/certmate/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/certmate.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/certmate/)

Certimate aims to provide users with a secure and user-friendly SSL certificate management solution. For usage documentation, please visit https://docs.certimate.me.

**Pulling Images:**

You can pull the images using the following commands:

```bash
docker pull funnyzak/certmate:latest
# GHCR 
docker pull ghcr.io/funnyzak/certmate:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/certmate:latest
```

## Usage

### Docker Deployment

```bash
docker run -d --name certimate_server -p 8090:8090 -v $(pwd)/data:/app/pb_data --restart unless-stopped funnyzak/certimate:latest
```

More information can be found at [certmate](https://github.com/usual2970/certimate).