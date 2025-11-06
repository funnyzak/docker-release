# Build stage
FROM alpine:3.22 AS builder

# Set build arguments
ARG VERSION=latest
ARG BUILD_DATE
ARG VCS_REF
ARG TARGETPLATFORM
ARG TARGETARCH

# Install build dependencies
RUN apk add --no-cache \
    curl \
    tar \
    gzip \
    ca-certificates

# Determine architecture and download reqtap from GitHub releases
RUN ARCH=$(case "${TARGETARCH}" in \
        "amd64") echo "amd64" ;; \
        "arm64") echo "arm64" ;; \
        "arm") echo "arm" ;; \
        "s390x") echo "s390x" ;; \
        "ppc64le") echo "ppc64le" ;; \
        "riscv64") echo "riscv64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac) && \
    if [ "${VERSION}" = "latest" ]; then \
        VERSION=$(curl -s https://api.github.com/repos/funnyzak/reqtap/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/'); \
    fi && \
    echo "Downloading reqtap version: ${VERSION} for architecture: ${ARCH}" && \
    curl -sfL "https://github.com/funnyzak/reqtap/releases/download/${VERSION}/reqtap-linux-${ARCH}.tar.gz" -o /tmp/reqtap.tar.gz && \
    cd /tmp && \
    tar -xzf reqtap.tar.gz && \
    chmod +x /tmp/reqtap && \
    rm -f /tmp/reqtap.tar.gz

# Runtime stage
FROM scratch

# Set build arguments
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

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

# Copy CA certificates from builder (needed for HTTPS requests)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy binary from builder stage
COPY --from=builder /tmp/reqtap /reqtap

# Default command
CMD ["/reqtap"]