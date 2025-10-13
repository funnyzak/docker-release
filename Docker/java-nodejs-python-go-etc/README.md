# Java, Node.js, Python, Go and Development Tools

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/java-nodejs-python-go-etc?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/java-nodejs-python-go-etc)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/java-nodejs-python-go-etc.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/java-nodejs-python-go-etc.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/java-nodejs-python-go-etc/

A comprehensive development environment container that includes Java, Node.js, Python, Go, and essential development tools. This container is designed for CI/CD pipelines, development workflows, and deployment automation, providing a complete toolkit for modern software development.

The image is available for multiple architectures, including `linux/amd64`, `linux/arm64`.

## Features

- **Multiple Language Support**: Java 8, Node.js with npm/yarn/pnpm, Python 3 with pip, Go 1.23.2
- **Package Managers**: Maven for Java, npm/yarn/pnpm for Node.js, pip for Python, Go modules
- **Development Tools**: Git, Vim, Curl, Wget, Tree, Rsync, Rclone
- **Cloud Storage Tools**: Minio Client, AliCloud OSSutil
- **Webhook Support**: Go Webhook for automated deployments
- **Notification System**: Apprise for multi-platform notifications
- **Compression Tools**: Zip, Unzip, Gzip, Tar for archive management
- **Font Support**: Microsoft Core Fonts for document processing
- **Security**: SSL certificates and GnuPG for secure operations

## Included Software

### Languages & Runtimes

- **Java 8** (OpenJDK 8u432-b06)
  - Location: `/opt/java/jdk8u432-b06`
  - Environment: `JAVA_HOME`, `JRE_HOME`, `CLASSPATH`

- **Node.js** (latest from Debian repositories)
  - Package managers: npm, yarn, pnpm (globally installed)

- **Python 3** (from Debian repositories)
  - Includes: python3-venv, python3-pip
  - Additional: apprise for notifications

- **Go 1.23.2**
  - Location: `/usr/local/go`
  - Environment: `GOPATH=/go`

### Build Tools

- **Maven 3.9.9**
  - Location: `/opt/maven`
  - Global symlink: `/usr/local/bin/mvn`

### Development Utilities

- **Version Control**: Git
- **Text Editors**: Vim
- **Network Tools**: Curl, Wget
- **File Management**: Tree, Rsync, Rclone
- **Archive Tools**: Zip, Unzip, Gzip, Tar
- **Process Management**: procps (includes ps, top)
- **SSL/TLS**: ca-certificates, OpenSSL

### Cloud & Storage Tools

- **Minio Client** (`mc`)
  - Location: `/opt/minio-binaries/mc`
  - Global symlink: `/usr/local/bin/mc`

- **AliCloud OSSutil** (v2.0.3-beta)
  - Location: `/opt/ossutil`
  - Global symlink: `/usr/local/bin/ossutil`

### Automation & Notification Tools

- **Go Webhook** (v2.8.2)
  - Location: `/opt/webhook`
  - Global symlink: `/usr/local/bin/webhook`

- **Apprise**
  - Multi-platform notification system
  - Supports 80+ notification services

### System Components

- **Base OS**: Debian stable (slim version)
- **Package Management**: apt with custom sources
- **Timezone**: Asia/Shanghai (configurable)
- **Locale**: C.UTF-8
- **Fonts**: Microsoft Core Fonts (ttf-mscorefonts-installer)

## Environment Variables

The container supports the following environment variables for configuration:

### Basic Configuration

- `TZ` - Timezone (default: `Asia/Shanghai`)
- `LANG` - System locale (default: `C.UTF-8`)
- `GO_VERSION` - Go version (default: `1.23.2`)

### Java Environment

- `JAVA_HOME` - Java installation path (default: `/opt/java/jdk8u432-b06`)
- `JRE_HOME` - Java Runtime Environment path (default: `${JAVA_HOME}/jre`)
- `CLASSPATH` - Java classpath (default: `.:${JAVA_HOME}/lib/dt.jar:${JAVA_HOME}/lib/tools.jar:${JRE_HOME}/lib`)

### Go Environment

- `GOPATH` - Go workspace path (default: `/go`)
- `PATH` - Includes `${JAVA_HOME}/bin:/usr/local/go/bin`

## Usage

### Basic Development Environment

Use as a complete development environment:

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  funnyzak/java-nodejs-python-go-etc \
  bash
```

### Java Project Build and Test

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  funnyzak/java-nodejs-python-go-etc \
  mvn clean compile test
```

### Node.js Application

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  funnyzak/java-nodejs-python-go-etc \
  sh -c "npm install && npm run build"
```

### Python Application

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  funnyzak/java-nodejs-python-go-etc \
  sh -c "pip install -r requirements.txt && python app.py"
```

### Go Application

```bash
docker run --rm \
  -v $(pwd):/app \
  -w /app \
  funnyzak/java-nodejs-python-go-etc \
  sh -c "go mod tidy && go build -o app . && ./app"
```

### Multi-Language Project

For projects with multiple language components:

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -w /workspace \
  funnyzak/java-nodejs-python-go-etc \
  sh -c "
    cd backend && mvn clean package &&
    cd ../frontend && npm install && npm run build &&
    cd ../scripts && pip install -r requirements.txt &&
    cd ../tools && go build -o tool . && ./tool
  "
```

## Docker Compose Examples

### Development Environment

```yaml
version: '3.8'
services:
  dev:
    image: funnyzak/java-nodejs-python-go-etc
    container_name: dev-environment
    working_dir: /app
    volumes:
      - .:/app
      - ~/.m2:/root/.m2  # Maven cache
      - ~/.npm:/root/.npm  # npm cache
      - /go/pkg:/go/pkg    # Go package cache
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
    stdin_open: true
    tty: true
```

### CI/CD Pipeline

```yaml
version: '3.8'
services:
  build:
    image: funnyzak/java-nodejs-python-go-etc
    container_name: build-pipeline
    working_dir: /app
    volumes:
      - .:/app
      - build-cache:/root/.cache
    environment:
      - MAVEN_OPTS=-Dmaven.repo.local=/root/.m2/repository
      - npm_config_cache=/root/.npm
    command: |
      sh -c "
        echo 'Building Java backend...' &&
        cd backend && mvn clean package -DskipTests &&
        echo 'Building Node.js frontend...' &&
        cd ../frontend && npm ci && npm run build &&
        echo 'Running Python tests...' &&
        cd ../api && pip install -r requirements.txt && python -m pytest &&
        echo 'Building Go tools...' &&
        cd ../tools && go build -o dist/tool .
      "
volumes:
  build-cache:
```

### Webhook Server

```yaml
version: '3.8'
services:
  webhook:
    image: funnyzak/java-nodejs-python-go-etc
    container_name: webhook-server
    ports:
      - "9000:9000"
    volumes:
      - ./hooks:/etc/webhook
      - ./scripts:/scripts
    command: webhook -hooks /etc/webhook/hooks.json -verbose
    environment:
      - TZ=Asia/Shanghai
    restart: unless-stopped
```

## Tool-Specific Usage

### Maven (Java)

```bash
# Clean and compile
mvn clean compile

# Run tests
mvn test

# Package application
mvn package

# Skip tests during build
mvn package -DskipTests

# Custom Maven repository
mvn -Dmaven.repo.local=/custom/maven/repo package
```

### npm/yarn/pnpm (Node.js)

```bash
# npm
npm install
npm run build
npm test

# yarn
yarn install
yarn build
yarn test

# pnpm
pnpm install
pnpm build
pnpm test
```

### Python pip

```bash
# Install requirements
pip install -r requirements.txt

# Virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Run tests
python -m pytest
```

### Go

```bash
# Initialize module
go mod init example.com/project

# Download dependencies
go mod tidy

# Build application
go build -o app .

# Run tests
go test ./...

# Build for multiple platforms
GOOS=linux GOARCH=amd64 go build -o app-linux-amd64 .
GOOS=windows GOARCH=amd64 go build -o app-windows-amd64.exe .
```

### Minio Client

```bash
# List buckets
mc ls s3

# Sync files
mc mirror ./local-files s3/my-bucket/

# Download files
mc cp s3/my-bucket/file.txt ./local-file.txt
```

### OSSutil

```bash
# Configure
ossutil config

# List buckets
ossutil ls

# Upload file
ossutil cp file.txt oss://my-bucket/

# Download file
ossutil cp oss://my-bucket/file.txt ./file.txt
```

### Apprise Notifications

```bash
# Send simple notification
apprise -t "Title" -b "Message body" "mailto://user:pass@gmail.com"

# Send with configuration file
apprise -c config.ini --body="Build completed successfully"

# Test notification service
apprise -t "Test" -b "Test message" "discord://webhook_id/webhook_token"
```

## Use Cases

### 1. CI/CD Pipelines
- Multi-language project compilation
- Automated testing across different runtimes
- Package building and distribution
- Deployment automation

### 2. Development Environments
- Consistent development setup across teams
- Containerized development workflows
- Quick project initialization
- Environment isolation

### 3. Build Automation
- Scheduled builds and deployments
- Cross-platform compilation
- Dependency management
- Artifact creation

### 4. Cloud Operations
- Multi-cloud file synchronization
- Backup and restore operations
- Infrastructure as Code deployment
- Monitoring and alerting

## Performance Considerations

### Cache Optimization
- Mount Maven repository: `~/.m2:/root/.m2`
- Mount npm cache: `~/.npm:/root/.npm`
- Mount Go package cache: `/go/pkg:/go/pkg`
- Use Docker volumes for persistent caches

### Resource Requirements
- Minimum RAM: 2GB (4GB+ recommended for large projects)
- Minimum Disk: 5GB (10GB+ recommended with caches)
- CPU: 2+ cores recommended for parallel builds

## Security Notes

- Container runs as root by default (standard for build environments)
- Includes SSL certificates for secure communications
- Microsoft Core Fonts may have licensing considerations
- Regular security updates through Debian stable packages

## Troubleshooting

### Common Issues

1. **Out of Memory**: Increase container memory limit or use smaller Maven heap size
2. **Permission Issues**: Ensure proper volume mounting permissions
3. **Network Issues**: Check DNS settings and proxy configuration
4. **Build Failures**: Verify all dependencies are available in repositories

### Debug Mode

Enable verbose output for debugging:

```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  -e DEBUG=true \
  funnyzak/java-nodejs-python-go-etc \
  bash
```

## Version Information

- Base Image: debian:stable-20250929-slim
- Java: OpenJDK 8u432-b06
- Go: 1.23.2
- Maven: 3.9.9
- Node.js: Latest from Debian stable
- Python: 3.x from Debian stable

## Updates and Maintenance

The container is regularly updated with:
- Latest security patches from Debian stable
- Updated language versions when stable releases are available
- New tool versions as they become available
- Performance optimizations and bug fixes

## References

- [Official Java Documentation](https://docs.oracle.com/javase/)
- [Node.js Official Documentation](https://nodejs.org/docs/)
- [Python Official Documentation](https://docs.python.org/3/)
- [Go Official Documentation](https://golang.org/doc/)
- [Maven Official Documentation](https://maven.apache.org/guides/)
- [Minio Client Documentation](https://docs.min.io/docs/minio-client-complete-guide.html)
- [Apprise Notification Documentation](https://github.com/caronc/apprise)
- [Go Webhook Documentation](https://github.com/adnanh/webhook)