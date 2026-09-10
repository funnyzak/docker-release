# AI Goofish Monitor

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/ai-goofish-monitor?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/ai-goofish-monitor)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/ai-goofish-monitor.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/ai-goofish-monitor.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/ai-goofish-monitor/)

An AI-powered monitoring service for the Goofish marketplace (闲鱼). This service uses Playwright to automate browser interactions and monitor listings, prices, and other marketplace data. Built with Python and designed for automated marketplace intelligence gathering.

Build with the `linux/amd64`, `linux/arm64` architectures.

## Features

- **Automated Marketplace Monitoring**: Continuous monitoring of Goofish marketplace listings
- **AI-Powered Analysis**: Intelligent analysis of marketplace data and trends
- **Browser Automation**: Uses Playwright with Chromium for realistic browser interactions
- **Web Interface**: Built-in web server for monitoring and configuration
- **Multi-Architecture Support**: Supports both AMD64 and ARM64 platforms
- **Network Diagnostics**: Includes network troubleshooting tools for connectivity checks
- **Barcode Support**: Includes libzbar0 for barcode processing capabilities

## Pull

```bash
docker pull funnyzak/ai-goofish-monitor:latest
# GHCR
docker pull ghcr.io/funnyzak/ai-goofish-monitor:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/ai-goofish-monitor:latest
```

## Usage

### Docker Run

```bash
# Run with default settings
docker run -d --name ai-goofish-monitor --restart on-failure \
  -p 8000:8000 \
  funnyzak/ai-goofish-monitor

# Run with data persistence
docker run -d --name ai-goofish-monitor --restart on-failure \
  -p 8000:8000 \
  -v ./data:/app/data \
  -v ./logs:/app/logs \
  funnyzak/ai-goofish-monitor
```

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: "3.8"
services:
  ai-goofish-monitor:
    image: funnyzak/ai-goofish-monitor:latest
    container_name: ai-goofish-monitor
    environment:
      - TZ=Asia/Shanghai
      - RUNNING_IN_DOCKER=true
    ports:
      - "8000:8000"
    restart: on-failure
    volumes:
      - ./data:/app/data
      - ./logs:/app/logs
    # Optional: Add resource limits
    deploy:
      resources:
        limits:
          memory: 1G
        reservations:
          memory: 512M
```

Then run:

```bash
docker-compose up -d
```

### Docker Build

```bash
docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION="latest" \
  -t funnyzak/ai-goofish-monitor:latest .
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Timezone | `UTC` |
| `RUNNING_IN_DOCKER` | Indicates running in Docker environment | `true` |
| `PLAYWRIGHT_BROWSERS_PATH` | Path to Playwright browser installations | `/root/.cache/ms-playwright` |

### Data Persistence

For data persistence, mount the following volumes:

- `/app/data`: Application data and configurations
- `/app/logs`: Application logs

```bash
docker run -d --name ai-goofish-monitor \
  -v ./data:/app/data \
  -v ./logs:/app/logs \
  -p 8000:8000 \
  funnyzak/ai-goofish-monitor
```

## Web Interface

The service provides a web interface accessible at `http://localhost:8000` when running locally, or `http://<host-ip>:8000` when running in Docker.

## System Requirements

- **Memory**: Minimum 512MB, recommended 1GB
- **CPU**: 1+ core recommended
- **Storage**: 500MB+ for application and browser components
- **Network**: Internet connectivity for marketplace access

## Troubleshooting

### Common Issues

1. **Browser Failed to Start**
   - Ensure sufficient memory allocation
   - Check Docker resource limits
   - Verify system dependencies are properly installed

2. **Network Connectivity Issues**
   - Verify internet connectivity from the container
   - Check DNS resolution
   - Ensure firewall allows outbound connections

3. **Performance Issues**
   - Increase memory allocation
   - Monitor CPU usage
   - Check if multiple browser instances are running

### Logs

View container logs:

```bash
docker logs ai-goofish-monitor
```

View logs with follow:

```bash
docker logs -f ai-goofish-monitor
```

### Network Diagnostics

The container includes network diagnostic tools:

```bash
# Test network connectivity
docker exec ai-goofish-monitor ping -c 4 google.com

# Test DNS resolution
docker exec ai-goofish-monitor nslookup google.com

# Test port connectivity
docker exec ai-goofish-monitor nc -zv google.com 80
```

## Development

### Local Development

For local development without Docker:

```bash
# Clone the repository
git clone https://github.com/Usagi-org/ai-goofish-monitor.git
cd ai-goofish-monitor

# Install Python dependencies
pip install -r requirements.txt

# Install Playwright browser
playwright install chromium

# Install system dependencies
playwright install-deps chromium

# Run the web server
python web_server.py
```

### Build Process

The Docker image uses a multi-stage build:

1. **Stage 1**: Clone repository and install Python dependencies
2. **Stage 2**: Install system dependencies and copy application code

This ensures a clean, optimized final image with all necessary components.

## Reference

- [AI Goofish Monitor Repository](https://github.com/Usagi-org/ai-goofish-monitor)
- [Playwright Documentation](https://playwright.dev/)
- [Goofish Marketplace](https://2.taobao.com/)