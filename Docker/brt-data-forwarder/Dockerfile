FROM python:3.9-slim

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.name="brt-data-forwarder" \
      org.label-schema.description="A lightweight data forwarding server for BRT cloud sensor data with intelligent caching." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        curl \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Create application user
RUN useradd -r -s /bin/false forwarder

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/funnyzak/brt-data-forwarder.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=8 HEAD)} > VERSION

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create necessary directories
RUN mkdir -p /app/data /app/logs && \
    chown -R forwarder:forwarder /app

# Set default environment variables for BRT Data Forwarder
ENV FLASK_HOST="0.0.0.0" \
    FLASK_PORT="8080" \
    FLASK_DEBUG="false"

# Switch to non-root user
USER forwarder

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start command
CMD ["python", "forwarder.py"]
