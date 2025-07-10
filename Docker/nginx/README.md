# Nginx

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/nginx?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/nginx)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)

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


More modules can be found in [Dockerfile](https://github.com/funnyzak/docker-release/blob/main/Docker/nginx/Dockerfile).

## Pull

```bash
docker pull funnyzak/nginx:latest
# GHCR
docker pull ghcr.io/funnyzak/nginx:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/nginx:latest
```

## Usage

### Docker Run

First, create a `nginx.conf` file in your project directory, and then run the following command:

```bash
# Run nginx container with default settings
docker run -d -t -i --name nginx --restart on-failure \
  -p 1697:80 \
  funnyzak/nginx

# Run nginx container with custom configuration directory
docker run -d -t -i --name nginx2 --restart on-failure \
  -v ./nginx/conf.d:/etc/nginx/conf.d \
  -p 1688:80 \
  funnyzak/nginx

# Run nginx container with custom HTML directory
docker run -d -t -i --name nginx3 --restart on-failure \
  -v ./nginx/html:/etc/nginx/html \
  -p 1690:80 \
  funnyzak/nginx
```

### Docker Compose

First, create a `docker-compose.yml` file in your project directory:

```yaml
version: “3.3”
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
      - “1688:80” 
```
  
  Then, run the following command:
  
  ```bash
  docker-compose up -d
  ```

### Docker Build

```bash
docker build \
--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
--build-arg VERSION="1.27.3"
-t funnyzak/nginx:1.27.3 .
```

## Reference

- [MaxMind (GeoIp Data)](https://www.maxmind.com/en/accounts/288367/geoip/downloads)
- [Nginx Book](https://ericrap.notion.site/Nginx-1c32ea493c134c36977d8fbd14226079)
- [Nginx Help](https://docs.nginx.com/)
