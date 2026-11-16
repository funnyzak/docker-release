FROM alpine:3.22 AS repo-clone

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/Usagi-org/ai-goofish-monitor.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse HEAD)} > VERSION

# Multi-stage build for optimized AI Goofish Monitor Docker image
FROM python:3.11-slim-bookworm AS builder

# Set environment variables to prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Create virtual environment
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

# Install Python dependencies to virtual environment (using Chinese mirror for speed)
COPY --from=repo-clone /app/requirements.txt .

RUN pip install --no-cache-dir -i https://pypi.tuna.tsinghua.edu.cn/simple -r requirements.txt

# Only download Playwright's Chromium browser, system dependencies will be installed in next stage
RUN playwright install chromium

# Stage 2: Create the final, lean image
FROM python:3.11-slim-bookworm

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.name="ai-goofish-monitor" \
      org.label-schema.description="ai-goofish-monitor" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

# Set working directory and environment variables
WORKDIR /app
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"
ENV PYTHONUNBUFFERED=1

# New environment variable to distinguish Docker environment from local environment
ENV RUNNING_IN_DOCKER=true

# Tell Playwright where to find the browser
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

# Copy virtual environment from builder stage, so we can use playwright commands
COPY --from=builder ${VIRTUAL_ENV} ${VIRTUAL_ENV}

# Install all system-level dependencies required to run the browser (including libzbar0) and network diagnostic tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        libzbar0 \
        curl \
        wget \
        iputils-ping \
        dnsutils \
        iproute2 \
        netcat-openbsd \
        telnet \
    && playwright install-deps chromium \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy pre-downloaded browser from builder stage
COPY --from=builder /root/.cache/ms-playwright /root/.cache/ms-playwright

# Copy application code
# .dockerignore file will handle exclusions
COPY --from=repo-clone /app .

# Declare the service running port
EXPOSE 8000

# Command executed when the container starts
CMD ["python", "web_server.py"]