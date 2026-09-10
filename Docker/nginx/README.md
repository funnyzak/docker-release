# Nginx

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/nginx?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/nginx)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)

A nginx docker image with secure configurations and some useful modules, such as `ngx_http_geoip_module`, `ngx_http_image_filter_module`, `ngx_http_perl_module`, `ngx_http_xslt_filter_module`, `ngx_mail_module`, `ngx_stream_geoip_module`, `ngx_stream_module`, `ngx-fancyindex`, `headers-more-nginx-module`, etc.

Build with the `linux/arm64`, `linux/386`, `linux/amd64`, `linux/arm/v7` architectures.

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

# Run nginx container with environment-variable-driven default server config
docker run -d -t -i --name nginx4 --restart on-failure \
  -e NGINX_SERVER_NAME=example.com \
  -e NGINX_LISTEN_PORT=8080 \
  -p 18080:8080 \
  funnyzak/nginx
```

### Default Template Variables

On first start, if you do not mount your own `conf.d`, the image renders `/etc/nginx/templates/default.conf.template` into `/etc/nginx/conf.d/default.conf`. The entrypoint checks `/etc/nginx/templates/default.conf.template` first and then falls back to `/data/nginx/templates/default.conf.template`. The built-in static `default.conf` is kept under `/data/nginx/conf.d` as a fallback when template rendering is unavailable.

The built-in template has these defaults:

- `NGINX_LISTEN_PORT`: listen port, default `80`
- `NGINX_SERVER_NAME`: server name, default `_`
- `NGINX_WEB_ROOT`: root path used by `location /`, default `html`
- `NGINX_INDEX_FILES`: index files, default `index.html index.htm`
- `NGINX_SERVER_BUILD`: value used in `Server-Build` response header, default `build via @funnyzak`

For custom mounted templates, the entrypoint will automatically detect and render every placeholder written as `${ENV_NAME}`. This means you can define any container environment variable and reference it directly in your own `default.conf.template` without changing the image script.

Example:

```bash
docker run -d --name nginx-template \
  -e APP_DOMAIN=demo.local \
  -e APP_UPSTREAM=http://host.docker.internal:3000 \
  -v ./default.conf.template:/etc/nginx/templates/default.conf.template \
  -p 8080:80 \
  funnyzak/nginx
```

```nginx
server {
    listen 80;
    server_name ${APP_DOMAIN};

    location / {
        proxy_pass ${APP_UPSTREAM};
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

Use `${ENV_NAME}` for environment placeholders. Nginx runtime variables like `$host` and `$remote_addr` can stay unchanged.

If you mount your own non-empty `/etc/nginx/conf.d`, the container will not overwrite it with the template. If you mount your own `default.conf.template`, it will be rendered only when `/etc/nginx/conf.d` is empty.

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
--build-arg VERSION="1.27.3" \
-t funnyzak/nginx:1.27.3 .
```

## Reference

- [MaxMind (GeoIp Data)](https://www.maxmind.com/en/accounts/288367/geoip/downloads)
- [Nginx Book](https://ericrap.notion.site/Nginx-1c32ea493c134c36977d8fbd14226079)
- [Nginx Help](https://docs.nginx.com/)
