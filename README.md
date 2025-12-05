# Docker Release 🚀

[![Build Status](https://github.com/funnyzak/docker-release/actions/workflows/release.yml/badge.svg)](https://github.com/funnyzak/docker-release)
[![GitHub Container Registry](https://img.shields.io/badge/GHCR-funnyzak-blue)](https://github.com/funnyzak/docker-release)
[![License](https://img.shields.io/github/license/funnyzak/docker-release)](https://github.com/funnyzak/docker-release)

**Docker Release** is a comprehensive repository that provides optimized Docker images for various services and applications. All images are automatically published to Docker Hub, GitHub Container Registry, and AliCloud Container Registry. The images are built with the latest source code and support multiple architectures including AMD64, ARM64, and more.

## Features

- **Multi-Architecture Support**: All images support `linux/amd64`, `linux/arm64`, and more
- **Automated CI/CD**: GitHub Actions-powered builds and automated releases
- **Multi-Registry Publishing**: Images available on Docker Hub, GHCR, and AliCloud Registry
- **Regular Updates**: Automated monitoring and updates from upstream sources
- **Security Focused**: Minimal base images and regular security updates
- **Production Ready**: Optimized for both development and production environments

## Available Images

### 📱 Applications & Services

- [**AI Goofish Monitor**](https://github.com/funnyzak/docker-release/tree/main/Docker/ai-goofish-monitor): AI-powered marketplace monitoring service for Goofish (闲鱼)
- [**FFmpeg Service**](https://github.com/funnyzak/docker-release/tree/main/Docker/ffmpeg-service): Media processing microservice with HTTP API
- [**One-API**](https://github.com/funnyzak/docker-release/tree/main/Docker/one-api): Unified OpenAI API format for all LLM providers
- [**WeRead Bot**](https://github.com/funnyzak/docker-release/tree/main/Docker/weread-bot): Intelligent WeChat Read automation bot
- [**LibreOffice Server**](https://github.com/funnyzak/docker-release/tree/main/Docker/libreoffice-server): Online document editing and conversion service
- [**Request-Hub**](https://github.com/funnyzak/docker-release/tree/main/Docker/request-hub): HTTP request receiving, recording, and proxy service
- [**NeZha Dashboard**](https://github.com/funnyzak/docker-release/tree/main/Docker/nezha): Server monitoring and management dashboard
- [**vCards**](https://github.com/funnyzak/docker-release/tree/main/Docker/vcards): Virtual business card management service
- [**Dify2OpenAI**](https://github.com/funnyzak/docker-release/tree/main/Docker/dify2openai): Dify to OpenAI API compatibility layer
- [**Certimate**](https://github.com/funnyzak/docker-release/tree/main/Docker/certimate): SSL certificate management service
- [**Watermark**](https://github.com/funnyzak/docker-release/tree/main/Docker/watermark): Image watermarking service
- [**Environment Mock Data**](https://github.com/funnyzak/docker-release/tree/main/Docker/other): Configurable mock data generation service
- [**brt-data-forwarder**](https://github.com/funnyzak/docker-release/tree/main/Docker/brt-data-forwarder): A brt data forward service.
- [**reqtap**](https://github.com/funnyzak/docker-release/tree/main/Docker/reqtap): HTTP request debugging and proxy tool

### 🛠️ Development Tools & Utilities

- [**Java NodeJS Python Go Etc**](https://github.com/funnyzak/docker-release/tree/main/Docker/java-nodejs-python-go-etc): Multi-language development environment
- [**Git Sync**](https://github.com/funnyzak/docker-release/tree/main/Docker/git-sync): Git repository synchronization service
- [**Git Job**](https://github.com/funnyzak/docker-release/tree/main/Docker/git-job): Git-based job automation
- [**Cron**](https://github.com/funnyzak/docker-release/tree/main/Docker/cron): Lightweight cron job scheduler
- [**Hello**](https://github.com/funnyzak/docker-release/tree/main/Docker/hello): Minimal Go application for Docker demonstration

### 🌐 Infrastructure & Networking

- [**Nginx**](https://github.com/funnyzak/docker-release/tree/main/Docker/nginx): Nginx with secure configurations and useful modules
- [**Snell Server**](https://github.com/funnyzak/docker-release/tree/main/Docker/snell-server): Lightweight encrypted proxy protocol server
- [**Y-WebRTC Signaling**](https://github.com/funnyzak/docker-release/tree/main/Docker/y-webrtc-signaling): WebRTC signaling server for real-time communication
- [**Abracadabra Web**](https://github.com/funnyzak/docker-release/tree/main/Docker/abracadabra-web): Instant text encryption/decryption tool

### 🗄️ Database & Data Tools

- [**Canal Suite**](https://github.com/funnyzak/docker-release/tree/main/Docker/canal): Alibaba Canal for MySQL binlog incremental subscription
  - Canal-Adapter: MySQL binlog adapter
  - Canal-Deployer: Canal deployment tool
  - Canal-Admin: Canal management interface
- [**MySQL Dump**](https://github.com/funnyzak/docker-release/tree/main/Docker/mysql-dump): Professional MySQL backup tool with notifications

### ⚙️ Runtime Environments

- [**OpenJDK**](https://github.com/funnyzak/docker-release/tree/main/Docker/openjdk): Eclipse Temurin-based Java runtime environment

## Image Status

| Image | Tag | Size | Pulls |
|---|---|---|---|
| [AI Goofish Monitor](https://github.com/funnyzak/docker-release/tree/main/Docker/ai-goofish-monitor/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/ai-goofish-monitor?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/ai-goofish-monitor)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/ai-goofish-monitor.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor) |
| [FFmpeg Service](https://github.com/funnyzak/docker-release/tree/main/Docker/ffmpeg-service/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/ffmpeg-service?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/ffmpeg-service)](https://hub.docker.com/r/funnyzak/ffmpeg-service) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/ffmpeg-service.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ffmpeg-service) |
| [WeRead Bot](https://github.com/funnyzak/docker-release/tree/main/Docker/weread-bot/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/weread-bot?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/weread-bot) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/weread-bot)](https://hub.docker.com/r/funnyzak/weread-bot) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/weread-bot.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/weread-bot) |
| [Nginx](https://github.com/funnyzak/docker-release/tree/main/Docker/nginx/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/nginx?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nginx) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/nginx)](https://hub.docker.com/r/funnyzak/nginx) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nginx.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nginx) |
| [OpenJDK](https://github.com/funnyzak/docker-release/tree/main/Docker/openjdk/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/openjdk?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/openjdk) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/openjdk)](https://hub.docker.com/r/funnyzak/openjdk) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/openjdk.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/openjdk) |
| [One-API](https://github.com/funnyzak/docker-release/tree/main/Docker/one-api/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/one-api?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/one-api) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/one-api)](https://hub.docker.com/r/funnyzak/one-api) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/one-api.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/one-api) |
| [Snell Server](https://github.com/funnyzak/docker-release/tree/main/Docker/snell-server/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/snell-server?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/snell-server) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/snell-server)](https://hub.docker.com/r/funnyzak/snell-server) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/snell-server.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/snell-server) |
| [Cron](https://github.com/funnyzak/docker-release/tree/main/Docker/cron/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/cron?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/cron) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/cron)](https://hub.docker.com/r/funnyzak/cron) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/cron.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/cron) |
| [Hello](https://github.com/funnyzak/docker-release/tree/main/Docker/hello/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/hello?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/hello) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/hello)](https://hub.docker.com/r/funnyzak/hello) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/hello.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/hello) |
| [reqtap](https://github.com/funnyzak/docker-release/tree/main/Docker/reqtap/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/reqtap?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/reqtap) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/reqtap)](https://hub.docker.com/r/funnyzak/reqtap) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/reqtap.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/reqtap) |

<details>
<summary>View all images status table</summary>

| Image | Tag | Size | Pulls |
|---|---|---|---|
| [Java NodeJS Python Go Etc](https://github.com/funnyzak/docker-release/tree/main/Docker/java-nodejs-python-go-etc/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/java-nodejs-python-go-etc?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/java-nodejs-python-go-etc)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/java-nodejs-python-go-etc.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc) |
| [Git Sync](https://github.com/funnyzak/docker-release/tree/main/Docker/git-sync/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/git-sync?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/git-sync) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/git-sync)](https://hub.docker.com/r/funnyzak/git-sync) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-sync.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-sync) |
| [Git Job](https://github.com/funnyzak/docker-release/tree/main/Docker/git-job/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/git-job?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/git-job) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/git-job)](https://hub.docker.com/r/funnyzak/git-job) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-job.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-job) |
| [LibreOffice Server](https://github.com/funnyzak/docker-release/tree/main/Docker/libreoffice-server/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/libreoffice-server?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/libreoffice-server) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/libreoffice-server)](https://hub.docker.com/r/funnyzak/libreoffice-server) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/libreoffice-server.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/libreoffice-server) |
| [Request Hub](https://github.com/funnyzak/docker-release/tree/main/Docker/request-hub/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/request-hub?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/request-hub) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/request-hub)](https://hub.docker.com/r/funnyzak/request-hub) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/request-hub.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/request-hub) |
| [NeZha Dashboard](https://github.com/funnyzak/docker-release/tree/main/Docker/nezha/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/nezha-dashboard?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/nezha-dashboard) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/nezha-dashboard)](https://hub.docker.com/r/funnyzak/nezha-dashboard) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/nezha-dashboard.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/nezha-dashboard) |
| [Canal Suite](https://github.com/funnyzak/docker-release/tree/main/Docker/canal/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/canal-adapter?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/canal-adapter) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/canal-adapter)](https://hub.docker.com/r/funnyzak/canal-adapter) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/canal-adapter.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/canal-adapter) |
| [Y-WebRTC Signaling](https://github.com/funnyzak/docker-release/tree/main/Docker/y-webrtc-signaling/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/y-webrtc-signaling?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/y-webrtc-signaling)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/y-webrtc-signaling.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/y-webrtc-signaling) |
| [Abracadabra Web](https://github.com/funnyzak/docker-release/tree/main/Docker/abracadabra-web/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/abracadabra-web?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/abracadabra-web) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/abracadabra-web)](https://hub.docker.com/r/funnyzak/abracadabra-web) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/abracadabra-web.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/abracadabra-web) |
| [MySQL Dump](https://github.com/funnyzak/docker-release/tree/main/Docker/mysql-dump/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/mysql-dump?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/mysql-dump)](https://hub.docker.com/r/funnyzak/mysql-dump) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/mysql-dump.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/mysql-dump) |
| [Dify2OpenAI](https://github.com/funnyzak/docker-release/tree/main/Docker/dify2openai/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/dify2openai?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/dify2openai) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/dify2openai)](https://hub.docker.com/r/funnyzak/dify2openai) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/dify2openai.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/dify2openai) |
| [Certimate](https://github.com/funnyzak/docker-release/tree/main/Docker/certimate/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/certimate?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/certimate) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/certimate)](https://hub.docker.com/r/funnyzak/certimate) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/certimate.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/certimate) |
| [Watermark](https://github.com/funnyzak/docker-release/tree/main/Docker/watermark/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/watermark?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/watermark) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/watermark)](https://hub.docker.com/r/funnyzak/watermark) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/watermark.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/watermark) |
| [vCards](https://github.com/funnyzak/docker-release/tree/main/Docker/vcards/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/vcards?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/vcards) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/vcards)](https://hub.docker.com/r/funnyzak/vcards) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/vcards.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/vcards) |
| [brt-data-forwarder](https://github.com/funnyzak/docker-release/tree/main/Docker/brt-data-forwarder/README.md) | [![Docker Tag](https://img.shields.io/docker/v/funnyzak/brt-data-forwarder?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/brt-data-forwarder) | [![Docker Image Size](https://img.shields.io/docker/image-size/funnyzak/brt-data-forwarder)](https://hub.docker.com/r/funnyzak/brt-data-forwarder) | [![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/brt-data-forwarder.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/brt-data-forwarder) |


</details>

## Quick Start

### Docker Pull

You can pull any of the above images from Docker Hub, GitHub Container Registry, or Aliyun Container Registry:

```bash
# Docker Hub
docker pull funnyzak/nginx:latest

# GitHub Container Registry
docker pull ghcr.io/funnyzak/nginx:latest

# Aliyun Container Registry
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/nginx:latest
```

## Documentation

Each service includes comprehensive documentation in its respective README.md file, covering:

- **Installation & Setup**: Step-by-step deployment instructions
- **Configuration**: Environment variables and settings
- **Usage Examples**: Docker run and Docker Compose samples

## Build Directory

All Docker images are built from the `./Docker/` directory structure. Each service has its own subdirectory containing:

- `Dockerfile`: Container build instructions
- `README.md`: Comprehensive service documentation
- `docker-compose.yml`: Local testing configuration (optional)
- Supporting files and configurations

### Key Directories

- `./Docker/ai-goofish-monitor/`: AI-powered marketplace monitoring
- `./Docker/ffmpeg-service/`: Media processing microservice
- `./Docker/nginx/`: Secure Nginx with additional modules
- `./Docker/openjdk/`: Eclipse Temurin Java runtime
- `./Docker/one-api/`: Unified LLM API gateway
- `./Docker/weread-bot/`: WeChat Read automation bot
- And many more services...

## Registry Support

All images are published to three registries for maximum accessibility:

- **Docker Hub**: `docker pull funnyzak/[service]:latest`
- **GitHub Container Registry**: `docker pull ghcr.io/funnyzak/[service]:latest`
- **Aliyun Container Registry**: `docker pull registry.cn-beijing.aliyuncs.com/funnyzak/[service]:latest`
## License

This project is licensed under the [MIT License](https://github.com/funnyzak/docker-release/blob/main/LICENSE).

---

**Built with ❤️ for the container community**
