# Git Job Docker Image

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/git-job?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/git-job/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/git-job)](https://hub.docker.com/r/funnyzak/git-job/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/git-job.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-job/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-job.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-job/)

Git Job is a professional webhook-based automation tool that triggers source code pulls and executes custom commands when receiving Git webhook events. Built on [funnyzak/java-nodejs-python-go-etc-docker](https://github.com/funnyzak/java-nodejs-python-go-etc-docker), it provides a complete CI/CD automation solution with build capabilities, notifications, and multi-platform support.

The image is available for multiple architectures, including `linux/amd64`, `linux/arm64`, and `linux/arm/v7`.

## Quick Start

**Docker Pull Command**: `docker pull funnyzak/git-job:latest`

**China Mirror**: `docker pull registry.cn-beijing.aliyuncs.com/funnyzak/git-job:latest`

## Features

- **Webhook Automation**: Trigger automated workflows via Git webhooks
- **Multi-Platform Support**: Build and deploy on amd64, arm64, and arm/v7 architectures
- **Build Pipeline**: Complete build automation with dependency installation and compilation
- **Custom Scripts**: Execute custom scripts at various stages (startup, before/after pull, after build)
- **Multi-Registry Publishing**: Built-in support for AliCloud OSS uploads
- **Notification System**: Real-time notifications via Pushoo integration (DingTalk, Bark, etc.)
- **SSH Key Support**: Secure Git operations with SSH key authentication
- **Flexible Configuration**: Extensive environment variable configuration
- **Volume Management**: Persistent storage for code, build outputs, and custom scripts
- **Web Server**: Built-in Nginx proxy on ports 80 and 9000
- **Comprehensive Logging**: Detailed operation logs and error handling

## Webhook Configuration

The container includes a built-in Nginx web server that listens for webhook events:

- **Webhook URL**: `/hooks/git-webhook`
- **Authentication**: URL parameter `?token=HOOK_TOKEN`
- **Default Event**: `push` events
- **Available Ports**: 80 and 9000

**Example URLs**:
- `http://hostname:80/hooks/git-webhook?token=HOOK_TOKEN`
- `http://hostname:9000/hooks/git-webhook?token=HOOK_TOKEN`

## Version Compatibility

**⚠️ Important Version Notice**: The current version is not compatible with versions prior to 2.0.0. If you need to use the legacy version, please use tag `1.1.0`:

```bash
docker pull funnyzak/git-job:1.1.0
```

## Configuration

The following environment variables are used to configure the container:

### Required

The following environment variables are required for basic operation:

- `GIT_USER_EMAIL` - The email of the git committer. Required.
- `GIT_REPO_URL` - The remote URL of the git repository. Required. Example: `git@github.com:funnyzak/vp-starter.git`.
- `HOOK_TOKEN` - The authentication token for the webhook. Required.

### Basic Options

Commonly used configuration options:

- `USE_HOOK` - Enable or disable the webhook listener. Default: `true`.
- `GIT_USER_NAME` - The username of the git committer. Optional.
- `GIT_BRANCH` - The branch to pull from the repository. Default: the repository's main branch.
- `CODE_DIR` - The directory where git repository will be cloned. Default: `/app/code`.
- `TARGET_DIR` - The directory for build outputs and deployment. Default: `/app/target`.

### Build Pipeline

Configure the automated build process:

- `INSTALL_DEPS_COMMAND` - Command to install dependencies after pulling code. Example: `npm install`, `pip install -r requirements.txt`.
- `BUILD_COMMAND` - Command to build the project after installing dependencies. Example: `npm run build`, `mvn package`.
- `BUILD_OUTPUT_DIR` - Build output directory relative to `CODE_DIR`. Example: `dist`, `build`, `target`.
- `AFTER_BUILD_COMMANDS` - Commands to execute after successful build. Example: `npm run deploy`, `docker-compose up -d`.

### Custom Scripts

Execute custom commands at different stages:

- `STARTUP_COMMANDS` - Commands executed when container starts.
- `BEFORE_PULL_COMMANDS` - Commands executed before pulling code from repository.
- `AFTER_PULL_COMMANDS` - Commands executed after pulling code from repository.

### Notifications

Configure notification system using Pushoo:

- `SERVER_NAME` - Server name displayed in notification messages. Optional.
- `PUSHOO_PUSH_PLATFORMS` - Notification platforms, separated by commas. Example: `dingtalk,bark,wechat`.
- `PUSHOO_PUSH_TOKENS` - Authentication tokens for notification platforms, separated by commas.
- `PUSHOO_PUSH_OPTIONS` - JSON object with platform-specific options. Example: `{"dingtalk":{"atMobiles":["13800000000"]},"bark":{"sound":"tink"}}`.
- `PUSH_MESSAGE_HEAD` - Custom header text for notification messages.
- `PUSH_MESSAGE_FOOT` - Custom footer text for notification messages.

For more details about Pushoo configuration, please refer to [pushoo-cli](https://github.com/funnyzak/pushoo-cli).

### AliCloud OSS

Configure automatic upload to AliCloud Object Storage Service:

- `ALIYUN_OSS_ENDPOINT` - AliCloud OSS endpoint. Example: `oss-cn-beijing-internal.aliyuncs.com`.
- `ALIYUN_OSS_AK_ID` - AliCloud Access Key ID.
- `ALIYUN_OSS_AK_SID` - AliCloud Access Key Secret.

## Volume

- `/app/code` - Git code folder. Must same as `CODE_DIR`. For example: `./code:/app/code`.
- `/root/.ssh` - Git ssh key folder. For example: `./ssh:/root/.ssh`.
- `/app/target` - The target of the code build. Must same as `TARGET_DIR`. For example: `./target:/app/target`.
- `/app/scripts` - The main scripts folder. contains `hook.sh`, `utils.sh`, `entrypoint.sh`.
- `/custom_scripts/on_startup` - which the scripts are executed at startup. For example: `./scripts/on_startup:/custom_scripts/on_startup`.
- `/custom_scripts/before_pull` - which the scripts are executed at before pull. Same as `/custom_scripts/on_startup`.
- `/custom_scripts/after_pull` - which the scripts are executed at after pull. Same as `/custom_scripts/on_startup`.

## Usage

### Command

Follow the example below to use docker to start the container, you should acdjust the environment variables according to your needs.

```bash
docker run -d -t -i --name git-job --restart on-failure:5 --privileged=true \
-e TZ=Asia/Shanghai \
-e LANG=C.UTF-8 \
-e USE_HOOK=true \
-e GIT_USER_NAME=Leon \
-e GIT_USER_EMAIL=silenceace@gmail.com \
-e GIT_REPO_URL=git@github.com:funnyzak/git-job.git \
-p 81:80 funnyzak/git-job
```

### Compose

#### Full configuration

Follow the example below to use docker-compose to start the container, and the environment variables are fully configured.

 ```yaml
version: '3'
services:
  app:
    image: funnyzak/git-job
    privileged: false
    container_name: gitjob
    working_dir: /app/code
    tty: true
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      # repo config
      - USE_HOOK=true
      - GIT_USER_NAME=Leon
      - GIT_USER_EMAIL=silenceace@gmail.com
      - HOOK_TOKEN=XqMWRndVuxXQDNzbE9Z
      - GIT_REPO_URL=git@github.com:funnyzak/git-job.git
      - GIT_BRANCH=main
      # commands
      - STARTUP_COMMANDS=echo start time:$$(date)
      - BEFORE_PULL_COMMANDS=echo before pull time:$$(date)
      - AFTER_PULL_COMMANDS=echo after pull time:$$(date)
      # pushoo 
      - SERVER_NAME=demo server
      - PUSHOO_PUSH_PLATFORMS=dingtalk,bark
      - PUSHOO_PUSH_TOKENS=dingtalktoken:barktoken
      - PUSHOO_PUSH_OPTIONS={"dingtalk":{"atMobiles":["13800000000"]},"bark":{"sound":"tink"}}
      - PUSH_MESSAGE_HEAD=This is a message head
      - PUSH_MESSAGE_FOOT=## Other

          * Click Here：[Home Page](https://www.domain.com/)
      # custom environment for build
      - INSTALL_DEPS_COMMAND=echo install deps time:$$(date)
      - BUILD_COMMAND=mkdir target && zip -r ./target/release.zip ./*
      - BUILD_OUTPUT_DIR=./dist
      - AFTER_BUILD_COMMANDS=echo after build time:$$(date)
      # custom environment for aliyun oss
      - ALIYUN_OSS_ENDPOINT=oss-cn-beijing-internal.aliyuncs.com
      - ALIYUN_OSS_AK_ID=123456789
      - ALIYUN_OSS_AK_SID=sxgh645etrdgfjh4635wer
      # optional
      - CODE_DIR=/app/code
      - TARGET_DIR=/app/target
    restart: on-failure
    ports:
      - 1038:80
    volumes:
      - ./target:/app/target
      - ./ssh:/root/.ssh
      - ./scripts/after_pull/after_pull_build_app.sh:/custom_scripts/after_pull/3.sh

 ```

#### Simple configuration

Follow the example below to use docker-compose to start the container, and the environment variables are not fully configured.

 ```yaml
version: '3'
services:
  app:
    image: funnyzak/git-job
    privileged: false
    container_name: gitjob
    tty: true
    environment:
      - GIT_USER_NAME=Leon
      - GIT_USER_EMAIL=silenceace@gmail.com
      - HOOK_TOKEN=XqMWRndVuxXQDNzbE9Z
      - GIT_REPO_URL=git@github.com:funnyzak/git-job.git
      - GIT_BRANCH=main
      # pushoo 
      - SERVER_NAME=demo server
      - PUSHOO_PUSH_PLATFORMS=dingtalk,bark
      - PUSHOO_PUSH_TOKENS=dingtalk:xxxx,bark:xxxx
      # custom environment for build
      - INSTALL_DEPS_COMMAND=echo install deps time:$$(date)
      - BUILD_COMMAND=mkdir target && zip -r ./target/release.zip ./*
      - BUILD_OUTPUT_DIR=./dist
    restart: on-failure
    ports:
      - 1038:80
    volumes:
      - ./target:/app/target
      - ./ssh:/root/.ssh
      - ./scripts/after_pull/after_pull_build_app.sh:/custom_scripts/after_pull/3.sh
 ```

## Other

### SSH Key

If you want to use ssh-key, you need to mount the ssh-key folder to `/root/.ssh`. Generally, you need to mount the `id_rsa` and `id_rsa.pub` files. For example:

 ```yaml
volumes:
  - ./ssh:/root/.ssh
 ```

 Your can use `ssh-keygen` to generate the ssh-key.For example:

 ```bash
ssh-keygen -t rsa -b 4096 -C "youremail@gmail.com" -N "" -f ./id_rsa
```