# Request Hub Docker

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/request-hub?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/request-hub/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/request-hub)](https://hub.docker.com/r/funnyzak/request-hub/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/request-hub.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/request-hub/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/request-hub.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/request-hub/)

[RequestHub](https://github.com/kyledayton/requesthub) is used to receive, record, and proxy HTTP requests. This image supports `linux/386`, `linux/amd64`, `linux/arm/v6`, `linux/arm/v7`, `linux/arm64/v8`, `linux/s390x`.


You can pull the images using the following commands:

```bash
docker pull funnyzak/request-hub:latest
# GHCR
docker pull ghcr.io/funnyzak/request-hub:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/request-hub:latest
```

---

## Environment

The following are the environment variables for a requesthub:

__You should consider the [use of `--env-file=`](https://docs.docker.com/engine/reference/commandline/run/#set-environment-variables--e---env---env-file), [docker secrets](https://docs.docker.com/engine/swarm/secrets/) to keep your secrets out of your shell history__

* **CONFIG_YML**: RequestHub can create default hubs on startup. Simply create a YAML file with the appropriate hub names and forwarding urls, and pass it to the config option. Optional.
* **NO_WEB**: Whether to Disable the web UI. Defaults to false. Optional.
* **PORT**: which port to bind to. Defaults to 54321. Optional.
* **MAX_REQUESTS**: max requests to store. Defaults to 512. Optional.
* **USER_NAME**: HTTP Basic Auth Username for accessing hub. Optional.
* **PASSWORD**: HTTP Basic Auth Password for accessing hub. Optional.

**Config_YML** Demo:

```yaml
hubs:
  test-hub:
    forward_url: 'https://www.example.com/webhook'
  another-hub:
    forward_url: 'https://www.example.com/webhook2'
```

---

## Usage Example

To run a requesthub, launch `requesthub` image as a container with the correct parameters. Everything is controlled by environment variables passed to the container.

For example:

```bash
docker run -d --name request-hub --restart always \
-p 54321:54321 funnyzak/request-hub
```

Or, if you prefer compose:

### Docker-Compose

```docker
version: '3'
services:
  requesthub:
    image: funnyzak/request-hub
    container_name: requesthub
    restart: always
    logging:
      driver: "json-file"
      options:
        max-size: "1g"
    environment:
        - TZ=Asia/Shanghai
        - LANG=C.UTF-8
        - CONFIG_YML=/config.yml
        - NO_WEB=false
        - PORT=54321
        - MAX_REQUESTS=1024
        - USER_NAME=hello
        - PASSWORD=world
    volumes:
      - ./config.yml:/config.yml
    ports:
      - 80:54321
```

---

## Preview

![preview](https://github.com/user-attachments/assets/a4dacbb9-1131-4db9-a5f3-3d477487a070)
