FROM python:3.13-slim

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.name="ffmpeg-service" \
      org.label-schema.description="A lightweight, containerized FFmpeg video processing microservice built with Flask and Python. This service provides HTTP API endpoints for video metadata extraction, screenshot capture, and format conversion." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ffmpeg \
        libmagic1 \
        wget \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/funnyzak/ffmpeg-service.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=8 HEAD)} > VERSION

# Set default environment variables
ENV TEMP_DIR="/tmp/videos" \
    MAX_FILE_SIZE="1048576000" \
    FILE_RETENTION_HOURS="2" \
    CLEANUP_INTERVAL_MINUTES="30" \
    ALLOWED_VIDEO_EXTENSIONS="mp4,avi,mov,mkv,flv,wmv,webm,m4v" \
    SUPPORTED_OUTPUT_FORMATS="mp4,avi,mov,mkv,webm" \
    FLASK_HOST="0.0.0.0" \
    FLASK_PORT="8080" \
    FLASK_DEBUG="false"

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Create temp directory for video processing
RUN mkdir -p /tmp/videos

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${FLASK_PORT}/health || exit 1

CMD ["python", "app.py"]
