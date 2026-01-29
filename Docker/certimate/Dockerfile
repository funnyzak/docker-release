# Build stage
FROM alpine:3.22 AS server-builder

# Set build arguments
ARG VERSION=latest
ARG BUILD_DATE
ARG VCS_REF
ARG TARGETPLATFORM
ARG TARGETARCH

# Install build dependencies
RUN apk add --no-cache \
    curl \
    unzip \
    ca-certificates

# Determine architecture and download certimate from GitHub releases
RUN ARCH=$(case "${TARGETARCH}" in \
        "amd64") echo "amd64" ;; \
        "arm64") echo "arm64" ;; \
        "arm") echo "armv7" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac) && \
    if [ "${VERSION}" = "latest" ]; then \
        VERSION=$(curl -s https://api.github.com/repos/certimate-go/certimate/releases/latest | grep '"tag_name":' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/') || exit 1; \
        [ -z "${VERSION}" ] && echo "Failed to get latest version from GitHub API" && exit 1; \
        echo "Resolved latest version to: ${VERSION}"; \
    fi && \
    [ -z "${VERSION}" ] && echo "VERSION is empty" && exit 1; \
    echo "Downloading certimate version: ${VERSION} for architecture: ${ARCH}" && \
    curl -sfL "https://github.com/certimate-go/certimate/releases/download/${VERSION}/certimate_${VERSION}_linux_${ARCH}.zip" -o /tmp/certimate.zip || (echo "Failed to download certimate ${VERSION} for ${ARCH}" && exit 1) && \
    mkdir -p /app && \
    cd /tmp && \
    unzip -q certimate.zip || (echo "Failed to extract certimate.zip" && exit 1) && \
    mv /tmp/certimate /app/certimate && \
    chmod +x /app/certimate && \
    rm -f /tmp/certimate.zip

# Runtime stage
FROM alpine:latest

# Set build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

# Set labels
LABEL maintainer="funnyzak <funnyzak@163.com>" \
      org.label-schema.name="Certimate" \
      org.label-schema.description="A powerful HTTP request debugging and proxy tool" \
      org.label-schema.url="https://github.com/certimate-go/certimate" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/funnyzak/docker-release" \
      org.label-schema.vendor="Funnyzak" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.version="${VERSION}"

WORKDIR /app

# Copy binary from builder stage
COPY --from=server-builder /app/certimate .

ENTRYPOINT ["./certimate", "serve", "--http", "0.0.0.0:8090"]