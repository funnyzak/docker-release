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

## Volumes

The following volume mounts are available for persistent storage and custom scripts:

### Application Volumes

- `/app/code` - Git repository working directory. Must match `CODE_DIR`.
- `/app/target` - Build output directory. Must match `TARGET_DIR`.
- `/root/.ssh` - SSH keys for Git authentication.

### Script Volumes

- `/app/scripts` - Main container scripts (contains `hook.sh`, `utils.sh`, `entrypoint.sh`).
- `/custom_scripts/on_startup` - Custom scripts executed at container startup.
- `/custom_scripts/before_pull` - Custom scripts executed before code pull.
- `/custom_scripts/after_pull` - Custom scripts executed after code pull.

## Usage

### Docker Command

Basic deployment with minimal configuration:

```bash
docker run -d \
  --name git-job \
  --restart on-failure:5 \
  --privileged=true \
  -e TZ=Asia/Shanghai \
  -e LANG=C.UTF-8 \
  -e USE_HOOK=true \
  -e GIT_USER_NAME=Leon \
  -e GIT_USER_EMAIL=silenceace@gmail.com \
  -e GIT_REPO_URL=git@github.com:funnyzak/git-job.git \
  -e HOOK_TOKEN=your-webhook-token \
  -p 8080:80 \
  -v ./ssh:/root/.ssh \
  funnyzak/git-job:latest
```

### Docker Compose

#### Complete Configuration

Full-featured setup with notifications, build pipeline, and custom scripts:

```yaml
version: '3.8'
services:
  git-job:
    image: funnyzak/git-job:latest
    container_name: git-job
    privileged: false
    working_dir: /app/code
    tty: true
    restart: unless-stopped
    environment:
      # Basic Configuration
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      - USE_HOOK=true
      - GIT_USER_NAME=Leon
      - GIT_USER_EMAIL=silenceace@gmail.com
      - HOOK_TOKEN=${HOOK_TOKEN}
      - GIT_REPO_URL=git@github.com:your-org/your-repo.git
      - GIT_BRANCH=main

      # Custom Commands
      - STARTUP_COMMANDS=echo "Container started at $$(date)"
      - BEFORE_PULL_COMMANDS=echo "Starting code pull..."
      - AFTER_PULL_COMMANDS=echo "Code pull completed"

      # Build Pipeline
      - INSTALL_DEPS_COMMAND=npm install
      - BUILD_COMMAND=npm run build
      - BUILD_OUTPUT_DIR=dist
      - AFTER_BUILD_COMMANDS=echo "Build completed successfully"

      # Notifications
      - SERVER_NAME=Production CI/CD
      - PUSHOO_PUSH_PLATFORMS=dingtalk,bark
      - PUSHOO_PUSH_TOKENS=${DINGTALK_TOKEN}:${BARK_TOKEN}
      - PUSHOO_PUSH_OPTIONS={"dingtalk":{"atMobiles":["13800000000"]},"bark":{"sound":"tink"}}
      - PUSH_MESSAGE_HEAD=🚀 Deployment Update
      - PUSH_MESSAGE_FOOT=## View Details\n* [Dashboard](https://your-dashboard.com)

      # AliCloud OSS (Optional)
      - ALIYUN_OSS_ENDPOINT=oss-cn-beijing.aliyuncs.com
      - ALIYUN_OSS_AK_ID=${OSS_ACCESS_KEY}
      - ALIYUN_OSS_AK_SID=${OSS_SECRET_KEY}

      # Directory Configuration
      - CODE_DIR=/app/code
      - TARGET_DIR=/app/target
    ports:
      - "8080:80"
      - "9000:9000"
    volumes:
      - ./code:/app/code
      - ./target:/app/target
      - ./ssh:/root/.ssh:ro
      - ./scripts/custom_startup.sh:/custom_scripts/on_startup/01-startup.sh
      - ./scripts/custom_build.sh:/custom_scripts/after_pull/02-build.sh
```

#### Simple Configuration

Minimal setup for basic Git operations:

```yaml
version: '3.8'
services:
  git-job:
    image: funnyzak/git-job:latest
    container_name: git-job
    restart: unless-stopped
    environment:
      - GIT_USER_NAME=Leon
      - GIT_USER_EMAIL=silenceace@gmail.com
      - HOOK_TOKEN=${HOOK_TOKEN}
      - GIT_REPO_URL=git@github.com:your-org/your-repo.git
      - GIT_BRANCH=main
      - AFTER_PULL_COMMANDS=npm install && npm run build
    ports:
      - "8080:80"
    volumes:
      - ./code:/app/code
      - ./ssh:/root/.ssh:ro
```

### With SSH Key Authentication

Generate SSH keys and mount them for secure Git operations:

```bash
# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -C "your-email@example.com" -N "" -f ./ssh/id_rsa

# Add the public key to your Git repository's deploy keys
# Then mount the SSH directory
docker run -d \
  --name git-job \
  -e GIT_USER_EMAIL=your-email@example.com \
  -e GIT_REPO_URL=git@github.com:your-org/your-repo.git \
  -e HOOK_TOKEN=your-token \
  -v ./ssh:/root/.ssh:ro \
  -p 8080:80 \
  funnyzak/git-job:latest
```

## Logging and Monitoring

### Application Logs

The container provides comprehensive logging for all operations:

- **Webhook Events**: All incoming webhook requests and processing status
- **Git Operations**: Clone, pull, and checkout operations with detailed output
- **Build Process**: Dependency installation, build execution, and results
- **Custom Scripts**: Execution logs for all custom script stages
- **Notifications**: Status of notification deliveries

### Log Access

View logs in real-time:

```bash
# View all container logs
docker logs -f git-job

# View recent logs
docker logs --tail 100 git-job

# Filter logs by pattern
docker logs git-job | grep "webhook\|build\|error"
```

### Health Monitoring

Monitor container health and webhook functionality:

```bash
# Check container status
docker ps

# Test webhook endpoint
curl "http://localhost:8080/hooks/git-webhook?token=your-token" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"ref":"refs/heads/main"}'
```

## Security Considerations

### SSH Key Management

For secure Git operations using SSH keys:

1. **Generate SSH Keys**:
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your-email@example.com" -N "" -f ./ssh/id_rsa
   ```

2. **Mount SSH Directory**:
   ```yaml
   volumes:
     - ./ssh:/root/.ssh:ro  # Read-only for security
   ```

3. **Add Public Key to Repository**:
   - Add `./ssh/id_rsa.pub` as a deploy key in your Git repository
   - Ensure the key has read access (and write access if needed)

### Webhook Security

- Use strong, randomly generated `HOOK_TOKEN` values
- Consider using GitHub's webhook secret validation
- Limit webhook exposure using firewall rules
- Use HTTPS in production environments

## Troubleshooting

### Common Issues

#### SSH Authentication Failures
- Verify SSH keys are properly mounted
- Check that the public key is added to the repository
- Ensure SSH key has correct permissions (600 for private key)

#### Build Failures
- Check build logs for specific error messages
- Verify all dependencies are available in the base image
- Ensure build commands are compatible with the container environment

#### Webhook Not Triggering
- Verify the webhook URL and token are correct
- Check if the container is receiving network traffic
- Review Nginx logs for webhook processing errors

### Debug Mode

Enable verbose logging for troubleshooting:

```yaml
environment:
  - VERBOSE=true  # Enable detailed debug output
```

## Migration from Legacy Versions

If you're upgrading from version 1.1.0 or earlier, note the following changes:

### Breaking Changes

- **Configuration Structure**: Environment variables have been reorganized
- **Webhook Path**: Standardized to `/hooks/git-webhook`
- **Build Pipeline**: Enhanced with more granular control
- **Notifications**: Moved to Pushoo-based system

### Migration Steps

1. Update your Docker image to the latest version
2. Review and update environment variable names
3. Test webhook configuration with the new endpoint
4. Verify build pipeline configuration

For legacy compatibility, continue using tag `1.1.0`:

```bash
docker pull funnyzak/git-job:1.1.0
```

## Reference and Resources

- **Git Job Repository**: [github.com/funnyzak/git-job](https://github.com/funnyzak/git-job)
- **Base Image**: [java-nodejs-python-go-etc-docker](https://github.com/funnyzak/java-nodejs-python-go-etc-docker)
- **Pushoo Notifications**: [pushoo-cli](https://github.com/funnyzak/pushoo-cli)
- **Docker Hub**: [funnyzak/git-job](https://hub.docker.com/r/funnyzak/git-job)
- **GitHub Container Registry**: [ghcr.io/funnyzak/git-job](https://github.com/funnyzak/git-job/pkgs/container/git-job)

## License

This project is licensed under the MIT License - see the repository for details.