# Snell Server

[![Image Size](https://img.shields.io/docker/image-size/funnyzak/snell-server)](https://hub.docker.com/r/funnyzak/snell-server/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/snell-server.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/snell-server/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/snell-server.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/snell-server/)
[![Docker Tags](https://img.shields.io/docker/v/funnyzak/snell-server?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/snell-server/)

Snell Server is a lean encrypted proxy protocol. It is designed to be simple, lightweight.

## Release channels

`latest` tracks the reviewed stable **5.0.1** release, supporting `linux/amd64`,
`linux/arm64`, `linux/arm/v7` and `linux/386`. The explicit `6.0.0` tag is retained
for opt-in testing: [upstream release notes](https://kb.nssurge.com/surge-knowledge-base/zh/release-notes/snell)
currently describe v6 as **Beta**. Its image supports amd64, arm64 and 386 only.

Do not infer stability from a numeric download filename. The scheduled job uses
`stable-release.json`, not the first download link. Update that allowlist only
after reviewing upstream release status, available architectures and image smoke
tests. The shared release workflow refuses to publish Snell `latest` with an
unreviewed VERSION. Stable channel promotion uses the **Promote Snell Stable**
manual workflow to copy the exact reviewed digest in Docker Hub and GHCR; it does
not rebuild or modify the version tag. Update the Dockerfile default and scheduled
platform list together when changing the stable version.

Moving `latest` from v6 Beta back to v5 changes the protocol generation. Existing
containers are not changed automatically. Before recreating a container, check
client settings; upstream documents v5 compatibility with v4 clients. Users who
need v6 must explicitly pin `6.0.0`. Recreate/restart is required to use a newly
pulled image.

## Credential handling

The entrypoint does not print the PSK or configuration. Newly generated
configuration files have mode `0600`; mounted configurations are used unchanged,
including read-only mounts. A minimal init (`tini`) forwards stop signals to the server and reaps children.
When no PSK is supplied, a random 32-character hexadecimal PSK is generated. Use a
secret/configuration management process to retrieve or distribute it privately,
not centralized container logs. Environment variables remain visible to users
with Docker administration privileges; use a protected mounted configuration if
that is unsuitable.

Existing logs and previously published images are not retroactively cleaned.
Rotate any PSK that was exposed outside its intended administrators. After pulling
a repaired image, recreate the container to activate the fix. The explicit v6
Beta `6.0.0` image has not been republished by this stable-channel repair.

Regression test (build a local image first):

```bash
bash Docker/snell-server/tests/entrypoint-test.sh snell:test linux/amd64
```

## Docker Pull

```bash
docker pull funnyzak/snell-server
# GHCR
docker pull ghcr.io/funnyzak/snell-server
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/snell-server
```

## Deployment

Your can run this image with the following command:

```bash
docker run -d --name snell-server --restart always -p 12303:6180 -e PSK="5G0H4qdf32mEZx32t" funnyzak/snell-server

# With more options
docker run -d --name snell-server --restart always \
  -e PSK="5G0H4qdf32mEZx32t" \
  -e TZ="Asia/Shanghai" \
  -e IPV6="false" \
  -e PORT=6180 \
  -e EGRESS_INTERFACE="eth0" \
  -p 12303:6180 funnyzak/snell-server:latest

# Check the server version (does not print credentials)
docker exec snell-server /opt/snell-server/snell-server --version
```

## Docker Compose

```yaml
version: '3'
services:
  snell:
    image: funnyzak/snell-server
    container_name: snell-server
    environment:
      PSK: 5G0H4qdf32mEZx32t
      TZ: Asia/Shanghai
      IPV6: false
      PORT: 6180
      EGRESS_INTERFACE: eth0  # Optional: specify network interface for outbound connections
    restart: always
    ports:
      - 12303:6180
```


## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PSK` | Auto-generated | Pre-shared key for authentication |
| `PORT` | `6180` | Port number for the server to listen on |
| `IPV6` | `false` | Enable IPv6 support |
| `EGRESS_INTERFACE` | - | Network interface name for outbound connections (e.g., `eth0`, `wlan0`) |

## Surge Configuration

```ini
[Proxy]
Proxy = snell, 1.2.3.4, 6333, psk=RANDOM_KEY_HERE, version=4
```

## Reference

- [Snell Knowledge](https://kb.nssurge.com/surge-knowledge-base/zh/release-notes/snell)
## Build verification

```bash
docker buildx build --platform linux/amd64,linux/arm64,linux/386 --build-arg VERSION=6.0.0 .
docker run --rm --entrypoint /opt/snell-server/snell-server <image> --version
```
