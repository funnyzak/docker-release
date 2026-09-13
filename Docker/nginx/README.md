# Nginx

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/nginx?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/nginx)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx/)

A nginx docker image **built from source** on Alpine Linux with hardened defaults, **HTTP/3 (QUIC)** support and optional dynamic modules. The `VERSION` build arg selects the compiled nginx version (the release workflow injects it from the image tag), so any published nginx release — stable or mainline — can be shipped. Default: `1.30.4`.

Build with the `linux/arm64`, `linux/386`, `linux/amd64`, `linux/arm/v7` architectures.

### Version pinning

- All third-party module tarballs (headers-more, ngx-fancyindex, ngx_brotli + its bundled brotli sources, ngx_http_geoip2_module) are verified by pinned SHA256 checksums. To build with a different module version, pass both the version and its matching checksum build args, e.g. `--build-arg HEADERS_MORE_NGINX_MODULE=0.38 --build-arg HEADERS_MORE_NGINX_MODULE_SHA256=<sha256 of the v0.38 tarball>`.
- Build and runtime libraries come from one single `apk` install, so the "built with OpenSSL X / running with OpenSSL Y" drift of the old two-stage build is impossible.

### Modules

All modules below are **compiled as dynamic modules**, but only `headers-more` is **loaded** by default (the built-in configuration uses it to hide the `Server` header). Enable the others per deployment:

```bash
docker run -e NGINX_ENABLED_MODULES="stream,http_fancyindex" ... funnyzak/nginx
```

or by mounting loader snippets into `/etc/nginx/modules/*.conf` (see `/etc/nginx/modules-available` inside the image for the available snippets).

| Module | Name for `NGINX_ENABLED_MODULES` | Docs |
| --- | --- | --- |
| headers-more | `http_headers_more` (loaded by default) | [headers-more-nginx-module](https://github.com/openresty/headers-more-nginx-module) |
| brotli | `http_brotli` (dynamic + static) | [ngx_brotli](https://github.com/google/ngx_brotli) |
| fancyindex | `http_fancyindex` | [ngx-fancyindex](https://github.com/aperezdc/ngx-fancyindex) |
| geoip2 | `http_geoip2` | [ngx_http_geoip2_module](https://github.com/leev/ngx_http_geoip2_module) |
| image filter | `http_image_filter` | [ngx_http_image_filter_module](https://nginx.org/en/docs/http/ngx_http_image_filter_module.html) |
| xslt filter | `http_xslt_filter` | [ngx_http_xslt_module](https://nginx.org/en/docs/http/ngx_http_xslt_module.html) |
| perl | `http_perl` | [ngx_http_perl_module](https://nginx.org/en/docs/http/ngx_http_perl_module.html) |
| mail | `mail` | [ngx_mail_core_module](https://nginx.org/en/docs/mail/ngx_mail_core_module.html) |
| stream (incl. ssl/realip/ssl_preread) | `stream` | [ngx_stream_core_module](https://nginx.org/en/docs/stream/ngx_stream_core_module.html) |

HTTP/3 (QUIC) is compiled into the binary itself — no module enabling needed; serve it with `listen 443 quic;` plus an `Alt-Svc` header. The `geoip2` module needs a MaxMind mmdb database mounted into the container and registered via the `geoip2` directive.

Every optional module ships with a commented, ready-to-uncomment example: http-level blocks (brotli/gzip, geoip2 with a China-only access map, headers-more) in the built-in [`nginx.conf`](./conf/nginx.conf), server-level blocks (fancyindex, image filter, xslt, perl, real_ip, stub_status, "allow access from China only") plus a full HTTPS + HTTP/3 server in [`default.conf.template`](./conf/templates/default.conf.template), and TCP/UDP/mail proxying in [`conf/stream.d/stream.conf.example`](./conf/stream.d/stream.conf.example). Uncomment what you need and enable the matching module.

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
docker run -d --name nginx --restart on-failure \
  -p 1697:80 \
  funnyzak/nginx

# Run nginx container with custom configuration directory
docker run -d --name nginx2 --restart on-failure \
  -v ./nginx/conf.d:/etc/nginx/conf.d \
  -p 1688:80 \
  funnyzak/nginx

# Run nginx container with custom HTML directory
docker run -d --name nginx3 --restart on-failure \
  -v ./nginx/html:/etc/nginx/html \
  -p 1690:80 \
  funnyzak/nginx

# Run nginx container with environment-variable-driven default server config
docker run -d --name nginx4 --restart on-failure \
  -e NGINX_SERVER_NAME=example.com \
  -e NGINX_LISTEN_PORT=8080 \
  -p 18080:8080 \
  funnyzak/nginx
```

Notes on runtime behavior:

- The entrypoint `exec`s nginx, so **nginx runs as PID 1** and the image declares `STOPSIGNAL SIGQUIT`; `docker stop` performs a graceful shutdown (exit code `0`) instead of being killed after the timeout.
- The image ships a process-level `HEALTHCHECK` (`pgrep nginx`) that works regardless of the configured listen port.
- The container runs as the unprivileged `nginx` user (uid 100). On hosts where unprivileged ports are restricted, use `NGINX_LISTEN_PORT` with a port ≥ 1024 or grant `CAP_NET_BIND_SERVICE`.
- Identifying response headers are stripped by default: no `Server` header at all, `server_tokens off`, and upstream `Server`/`X-Powered-By` are hidden on proxied responses (see the commented `proxy_hide_header` lines in `nginx.conf` for hiding framework headers such as `X-AspNet-Version` or `X-Runtime`).

### Default Template Variables

On first start, if you do not mount your own `conf.d`, the image renders `/etc/nginx/templates/default.conf.template` into `/etc/nginx/conf.d/default.conf`. The entrypoint checks `/etc/nginx/templates/default.conf.template` first and then falls back to `/data/nginx/templates/default.conf.template`. The built-in static `default.conf` is kept under `/data/nginx/conf.d` as a fallback when template rendering is unavailable.

The built-in template has these defaults:

- `NGINX_LISTEN_PORT`: listen port, default `80` (validated: integer `1`–`65535`)
- `NGINX_SERVER_NAME`: server name, default `_` (validated: hostnames, wildcards, underscores)
- `NGINX_WEB_ROOT`: root path used by `location /`, default `/etc/nginx/html` (validated: path characters only)
- `NGINX_INDEX_FILES`: index files, default `index.html index.htm` (validated: file-name tokens)
- `NGINX_SERVER_BUILD`: value for the optional `Server-Build` response header, default `build via @funnyzak` (no quotes, semicolons or control characters). The header itself is commented out by default — it fingerprints the image — uncomment the `more_set_headers` line in the template to enable it.

Values that could break out of the rendered configuration (semicolons, braces, quotes, newlines) or malformed ports make the entrypoint exit with a clear error **before** nginx starts.

`NGINX_ENABLED_MODULES` (comma-separated, see [Modules](#modules)) is validated the same way: unknown or ambiguous names fail fast with the list of available names.

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

### Log Output

By default, `/var/log/nginx/access.log` and `/var/log/nginx/error.log` point to container stdout and stderr. You can bind-mount regular files at either path; the entrypoint preserves mounted files instead of replacing them with symbolic links. Do not mount a directory at an individual log-file path. To persist the complete log directory, mount the directory at `/var/log/nginx`.

### Docker Compose

See [docker-compose.yml](./docker-compose.yml) for a working stack (read-only config mounts, `cap_drop: ALL`, `no-new-privileges`, pinned image tag):

```yaml
name: nginx-server

services:
  nginx:
    image: funnyzak/nginx:1.30.4
    restart: on-failure
    ports:
      - "1000:8080"
    environment:
      TZ: Asia/Shanghai
      NGINX_LISTEN_PORT: "8080"
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    volumes:
      - ./conf/nginx.conf:/etc/nginx/nginx.conf:ro
      - ./conf/templates:/etc/nginx/templates:ro
      - ./log/nginx:/var/log/nginx
```

Run it from this directory with:

```bash
docker compose -f Docker/nginx/docker-compose.yml up -d
```

### Docker Build

The `VERSION` build arg selects the nginx release to compile (defaults to the version pinned in the [Dockerfile](./Dockerfile)). When releasing through the `Release Choice Image` workflow, the image tag is injected as `VERSION` automatically — dispatch with `docker_tags: 1.31.5` to publish a nginx `1.31.5` image, exactly like before.

```bash
docker build \
  --build-arg BUILD_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --build-arg VERSION="1.30.4" \
  -t funnyzak/nginx:1.30.4 .
```

## Reference

- [MaxMind GeoLite2 Databases (for the geoip2 module)](https://www.maxmind.com/en/accounts/288367/geoip/downloads)
- [Nginx Book](https://ericrap.notion.site/Nginx-1c32ea493c134c36977d8fbd14226079)
- [Nginx Help](https://docs.nginx.com/)
