# Build stage
FROM alpine:3.19 AS builder

# Set build arguments
ARG VERSION=latest
ARG TARGETPLATFORM
ARG TARGETARCH

# Install build dependencies
RUN apk add --no-cache \
    curl \
    tar \
    gzip \
    ca-certificates

# Determine architecture
RUN case "${TARGETARCH}" in \
    "amd64") ARCH="amd64" ;; \
    "arm64") ARCH="arm64" ;; \
    "arm") ARCH="armv7" ;; \
    "s390x") ARCH="s390x" ;; \
    "ppc64le") ARCH="ppc64le" ;; \
    "386") ARCH="i386" ;; \
    "riscv64") ARCH="riscv64" ;; \
    "armv6") ARCH="armv6l" ;; \
    "armv7") ARCH="armv7l" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && echo "ARCH=${ARCH}" > /tmp/arch

# Read architecture
RUN source /tmp/arch

# Download reqtap from GitHub releases
RUN if [ "${VERSION}" = "latest" ]; then \
        VERSION=$(curl -s https://api.github.com/repos/funnyzak/reqtap/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); \
    fi && \
    ARCH=$(cat /tmp/arch | cut -d'=' -f2) && \
    echo "Downloading reqtap version: ${VERSION} for architecture: ${ARCH}" && \
    curl -sL "https://github.com/funnyzak/reqtap/releases/download/${VERSION}/reqtap-linux-${ARCH}.tar.gz" -o /tmp/reqtap.tar.gz && \
    cd /tmp && \
    tar -xzf reqtap.tar.gz && \
    chmod +x /tmp/reqtap

# Runtime stage
FROM alpine:3.19

# Set labels
LABEL maintainer="funnyzak <funnyzak@163.com>" \
      org.label-schema.name="reqtap" \
      org.label-schema.description="A powerful HTTP request debugging and proxy tool" \
      org.label-schema.url="https://github.com/funnyzak/reqtap" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vcs-url="https://github.com/funnyzak/docker-release" \
      org.label-schema.vendor="Funnyzak" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.version="${VERSION}"

# Install runtime dependencies
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    curl \
    && rm -rf /var/cache/apk/*

# Create non-root user
RUN addgroup -g 1000 reqtap && \
    adduser -D -s /bin/sh -u 1000 -G reqtap reqtap

# Create directories
RUN mkdir -p /etc/reqtap /var/log/reqtap /tmp/reqtap && \
    chown -R reqtap:reqtap /etc/reqtap /var/log/reqtap /tmp/reqtap

# Copy binary from builder stage
COPY --from=builder /tmp/reqtap /usr/local/bin/reqtap

# Set ownership
RUN chown reqtap:reqtap /usr/local/bin/reqtap

# Switch to non-root user
USER reqtap

# Set working directory
WORKDIR /app

# Default command
CMD ["/usr/local/bin/reqtap"]