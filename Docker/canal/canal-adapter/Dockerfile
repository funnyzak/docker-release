FROM alpine:3.20.3 AS build

ARG VERSION=1.1.7
ARG CANAL_NAME=adapter

ENV CANAL_DIR_NAME=canal-${CANAL_NAME}

RUN apk add --no-cache curl tar \
    && mkdir -p /opt/canal/${CANAL_DIR_NAME}

# eg. https://github.com/alibaba/canal/releases/download/canal-1.1.8-alpha-3/canal.adapter-1.1.8-SNAPSHOT.tar.gz
# eg. https://github.com/alibaba/canal/releases/download/canal-1.1.7/canal.adapter-1.1.7.tar.gz

RUN if echo ${VERSION} | grep -q "-"; then \
        DOWNLOAD_NAME=canal.${CANAL_NAME}-$(echo ${VERSION} | awk -F '-' '{print $1}')-SNAPSHOT.tar.gz; \
    else \
        DOWNLOAD_NAME=canal.${CANAL_NAME}-${VERSION}.tar.gz; \
    fi \
    && curl -fSL "https://github.com/alibaba/canal/releases/download/canal-${VERSION}/${DOWNLOAD_NAME}" -o ${DOWNLOAD_NAME} \
    && tar -xzf ${DOWNLOAD_NAME} -C /opt/canal/${CANAL_DIR_NAME} \
    && rm ${DOWNLOAD_NAME}

FROM openjdk:11-jre-slim AS runtime

ARG BUILD_DATE
ARG VERSION=1.1.7
ARG CANAL_NAME=adapter

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.name="canal-${CANAL_NAME}" \
      org.label-schema.description="Alibaba Canal, a component for incremental subscription and consumption of binlogs in MySQL." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.url="https://github.com/funnyzak/docker-release" \
      org.label-schema.build-date="${BUILD_DATE}"

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    VERSION=${VERSION} \
    CANAL_NAME=${CANAL_NAME} \
    CANAL_DIR_NAME=canal-${CANAL_NAME}

RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y --no-install-recommends file tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /opt/canal/${CANAL_DIR_NAME} /opt/canal/${CANAL_DIR_NAME}

WORKDIR /opt/canal/${CANAL_DIR_NAME}
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]