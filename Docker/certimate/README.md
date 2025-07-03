# certimate

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/certimate?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/certimate/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/certimate)](https://hub.docker.com/r/funnyzak/certimate/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/certimate.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/certimate/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/certimate.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/certimate/)

Certimate aims to provide users with a secure and user-friendly SSL certificate management solution. For usage documentation, please visit https://docs.certimate.me.

**Pulling Images:**

You can pull the images using the following commands:

```bash
docker pull funnyzak/certimate:latest
# GHCR 
docker pull ghcr.io/funnyzak/certimate:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/certimate:latest
```

## Usage

### Docker Deployment

```bash
docker run -d --name certimate_server -p 8090:8090 -v $(pwd)/data:/app/pb_data --restart unless-stopped funnyzak/certimate:latest
```

### Docker Compose Deployment

```yaml
version: '3.7'
services:
  certimate:
    image: funnyzak/certimate:latest
    container_name: certimate_server
    ports:
      - "8090:8090"
    volumes:
      - ./data:/app/pb_data
    restart: unless-stopped
```


After completing the installation steps above, you can access the Certimate admin panel at:
http://127.0.0.1:8090

Default credentials:
- Username: admin@certimate.fun
- Password: 1234567890


More information can be found at [certimate](https://github.com/certimate-go/certimate).