# OpenJDK

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/openjdk?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/openjdk/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/openjdk)](https://hub.docker.com/r/funnyzak/openjdk/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/openjdk.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/openjdk/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/openjdk.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/openjdk/)

A lightweight OpenJDK Docker image based on Eclipse Temurin distributions. This image provides a reliable, production-ready Java runtime environment with proper UTF-8 locale configuration and comprehensive build metadata.

Built with multiple architectures: `linux/amd64`, `linux/arm64`.

## Available Versions

- **Latest**: Based on Eclipse Temurin 11 JRE (default)
- **11-jre**: Eclipse Temurin 11 JRE
- **17-jre**: Eclipse Temurin 17 JRE
- **21-jre**: Eclipse Temurin 21 JRE
- **11-jdk**: Eclipse Temurin 11 JDK
- **17-jdk**: Eclipse Temurin 17 JDK
- **21-jdk**: Eclipse Temurin 21 JDK

## Pull

```bash
# Pull latest (11-jre)
docker pull funnyzak/openjdk:latest

# Pull specific version
docker pull funnyzak/openjdk:17-jre
docker pull funnyzak/openjdk:21-jdk

# GHCR
docker pull ghcr.io/funnyzak/openjdk:latest

# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/openjdk:latest
```

## Usage

### Docker Run

```bash
# Run Java version check
docker run --rm funnyzak/openjdk:latest

# Run a Java application
docker run --rm -v ./app:/app -w /app funnyzak/openjdk:latest java -jar myapp.jar

# Run with custom Java options
docker run --rm -v ./app:/app -w /app funnyzak/openjdk:latest java -Xmx512m -Xms256m -jar myapp.jar

# Interactive shell for debugging
docker run --rm -it funnyzak/openjdk:latest bash
```

### Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: "3.8"
services:
  java-app:
    image: funnyzak/openjdk:17-jre
    container_name: my-java-app
    environment:
      - TZ=Asia/Shanghai
      - JAVA_OPTS=-Xmx1g -Xms512m
    volumes:
      - ./app:/app
      - ./logs:/app/logs
    working_dir: /app
    command: java $JAVA_OPTS -jar application.jar
    restart: on-failure
```

Then run:

```bash
docker-compose up -d
```

### Dockerfile Example

```dockerfile
FROM funnyzak/openjdk:17-jre

WORKDIR /app

# Copy application files
COPY target/myapp.jar ./myapp.jar

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser
USER appuser

# Expose application port
EXPOSE 8080

# Run the application
CMD ["java", "-jar", "myapp.jar"]
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Timezone | `UTC` |
| `LANG` | System locale | `C.UTF-8` |
| `JAVA_OPTS` | Java runtime options | - |

### Java Version Check

To check the Java version in the container:

```bash
docker run --rm funnyzak/openjdk:latest java -version
```

Example output:
```
openjdk version "11.0.24" 2024-07-16
OpenJDK Runtime Environment Temurin-11.0.24+8 (build 11.0.24+8)
OpenJDK 64-Bit Server VM Temurin-11.0.24+8 (build 11.0.24+8, mixed mode, sharing)
```

## Development

### Building Java Applications

```bash
# Compile Java source files
docker run --rm -v ./src:/src -v ./build:/build funnyzak/openjdk:11-jdk javac -d /build /src/*.java

# Run compiled Java classes
docker run --rm -v ./build:/build funnyzak/openjdk:11-jre java -cp /build com.example.Main
```

### Maven Integration

```bash
# Run Maven commands
docker run --rm -v $(pwd):/app -w /app funnyzak/openjdk:11-jdk mvn clean package

# Run Maven with custom settings
docker run --rm -v $(pwd):/app -v ~/.m2:/root/.m2 -w /app funnyzak/openjdk:11-jdk mvn package
```

### Gradle Integration

```bash
# Run Gradle commands
docker run --rm -v $(pwd):/app -w /app funnyzak/openjdk:11-jdk ./gradlew build

# Run Gradle daemon mode
docker run --rm -v $(pwd):/app -v ~/.gradle:/root/.gradle -w /app funnyzak/openjdk:11-jdk ./gradlew build --daemon
```

## Security

### Non-Root User

For production use, consider running as a non-root user:

```dockerfile
FROM funnyzak/openjdk:17-jre

# Create non-root user
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Switch to non-root user
USER appuser

# Continue with your application setup...
```

### Resource Limits

Set appropriate resource limits:

```yaml
services:
  java-app:
    image: funnyzak/openjdk:17-jre
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
```

## Monitoring and Debugging

### JVM Monitoring

```bash
# Enable JMX monitoring
docker run -d -p 9010:9010 \
  -e JAVA_OPTS="-Dcom.sun.management.jmxremote.port=9010 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false" \
  funnyzak/openjdk:17-jre java -jar app.jar

# Enable debug mode
docker run -d -p 5005:5005 \
  -e JAVA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005" \
  funnyzak/openjdk:17-jre java -jar app.jar
```

### Heap Dump

```bash
# Generate heap dump on OutOfMemoryError
docker run -d \
  -e JAVA_OPTS="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/app/dumps/" \
  -v ./dumps:/app/dumps \
  funnyzak/openjdk:17-jre java -jar app.jar
```

## Performance Tuning

### JVM Options Examples

```bash
# Production settings
JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:+UseStringDeduplication -XX:+OptimizeStringConcat"

# Memory-constrained settings
JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseSerialGC -XX:+UseCompressedOops"

# High-throughput settings
JAVA_OPTS="-Xmx4g -Xms2g -XX:+UseG1GC -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap"
```

## Docker Build

```bash
# Build with specific version
docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION="17-jre" \
  -t funnyzak/openjdk:17-jre .

# Build with custom tag
docker build \
  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
  --build-arg VERSION="21-jdk" \
  -t my-openjdk:latest .
```

## Troubleshooting

### Common Issues

1. **Memory Issues**
   - Increase container memory limit
   - Adjust JVM heap size with `-Xmx` and `-Xms`
   - Monitor memory usage with monitoring tools

2. **File Permission Issues**
   - Ensure proper file permissions on mounted volumes
   - Consider running as non-root user

3. **Timezone Issues**
   - Set appropriate `TZ` environment variable
   - Use `-Duser.timezone=Asia/Shanghai` JVM option

### Logs

View container logs:

```bash
docker logs <container-name>
```

## Reference

- [Eclipse Temurin Documentation](https://adoptium.net/temurin/documentation/)
- [OpenJDK Documentation](https://openjdk.org/)
- [Java Docker Best Practices](https://github.com/docker-library/docs/blob/master/openjdk/README.md)