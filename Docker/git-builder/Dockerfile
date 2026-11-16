# JDK major version bundled in the image: 8, 11, 17 (default) or 25. Only the selected stage is built.
ARG JAVA_VERSION=17
FROM --platform=$BUILDPLATFORM golang:1.25.7-bookworm@sha256:564e366a28ad1d70f460a2b97d1d299a562f08707eb0ecb24b659e5bd6c108e1 AS webhook-build
ARG TARGETOS
ARG TARGETARCH
ARG WEBHOOK_VERSION=2.8.3
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go install github.com/adnanh/webhook@${WEBHOOK_VERSION}

FROM eclipse-temurin:8u502-b07-jdk-jammy@sha256:d57e5d0e3e5dd4cabb74feccfdb36249a58c76a3354a33ee8737813df93b7e0d AS java-8
FROM eclipse-temurin:11.0.32_9-jdk-jammy@sha256:d47c552b2078dcb4d21471c3914194d501f351d7e85ec18a3f2bb1e452adecf9 AS java-11
FROM eclipse-temurin:17.0.20_8-jdk-jammy@sha256:ef4374b4b6b9d813dd3f5b593a35ec9a820cfb64a55994798147cc73435a0208 AS java-17
FROM eclipse-temurin:25.0.4_7-jdk-jammy@sha256:02eecc58b9c7cb20e55765c7bcdcdee0c6d210440aca1b0a1fbd81ecfe8e772e AS java-25
FROM java-${JAVA_VERSION} AS java
# Maven is JDK independent; the same distribution is copied into every Java variant.
FROM maven:3.9.9-eclipse-temurin-17@sha256:f58d59b6273e785ac0a4477f6e9b5ba1d7731c75b906c0f7b34076f1851318cc AS maven
FROM node:24.14.0-bookworm-slim@sha256:d8e448a56fc63242f70026718378bd4b00f8c82e78d20eefb199224a4d8e33d8

ARG PNPM_VERSION=10.18.2
ENV JAVA_HOME=/opt/java/openjdk \
    MAVEN_HOME=/opt/maven \
    PATH=/opt/java/openjdk/bin:/opt/maven/bin:$PATH \
    HOME=/home/node \
    TZ=Asia/Shanghai \
    LANG=C.UTF-8 \
    CONFIG_FILE=/config/pipeline.json \
    DATA_DIR=/data \
    WEBHOOK_PORT=9000 \
    GIT_TERMINAL_PROMPT=0 \
    npm_config_cache=/data/cache/npm
RUN apt-get update && apt-get install -y --no-install-recommends \
      ca-certificates git openssh-client curl tar gzip zip unzip rsync tini util-linux tzdata \
      fontconfig fonts-dejavu-core fonts-noto-cjk \
    && rm -rf /var/lib/apt/lists/* \
    && npm install --global pnpm@${PNPM_VERSION} \
    && npm cache clean --force \
    && mkdir -p /data /config /home/node/.m2 /home/node/.ssh \
    && chown -R node:node /data /home/node
# Build metadata comes after the apt layer so changing BUILD_DATE, VERSION or JAVA_VERSION keeps it cached.
ARG BUILD_DATE
ARG VCS_REF
ARG VERSION=1.0.0
ARG JAVA_VERSION
LABEL org.opencontainers.image.title="git-builder" \
      org.opencontainers.image.description="Configurable Git webhook builds, deployment scripts, managed services and Apprise HTTP notifications for Node.js and Java projects" \
      org.opencontainers.image.source="https://github.com/funnyzak/docker-release" \
      org.opencontainers.image.version=${VERSION} \
      org.opencontainers.image.revision=${VCS_REF} \
      org.opencontainers.image.created=${BUILD_DATE} \
      io.github.funnyzak.git-builder.java=${JAVA_VERSION}
COPY --from=java /opt/java/openjdk /opt/java/openjdk
COPY --from=maven /usr/share/maven /opt/maven
# Cross-compiling go install puts the binary under GOOS_GOARCH; native builds use /go/bin.
COPY --from=webhook-build /go/bin/ /tmp/webhook-bin/
RUN set -eu; binary=$(find /tmp/webhook-bin -type f -name webhook); \
    install -m 755 "$binary" /usr/local/bin/webhook; rm -rf /tmp/webhook-bin
COPY app /app
COPY --chmod=755 scripts /app/scripts
USER node
WORKDIR /data
EXPOSE 9000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
    CMD ["node", "/app/service.mjs", "health"]
ENTRYPOINT ["/usr/bin/tini", "--", "/app/scripts/entrypoint.sh"]
