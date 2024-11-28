FROM alpine:3.20.3 AS build

ARG CANAL_COMPONENT_VERSION=1.1.7
ENV CANAL_DOWNLOAD_NAME=canal.admin
ENV CANAL_COMPONENT_NAME=canal-admin
ENV CANAL_DOWNLOAD_URL=https://github.com/alibaba/canal/releases/download/canal-${CANAL_COMPONENT_VERSION}/${CANAL_DOWNLOAD_NAME}-${CANAL_COMPONENT_VERSION}.tar.gz

RUN apk add --no-cache curl tar \
    && mkdir -p /opt/canal/${CANAL_COMPONENT_NAME} \
    && curl -fSL "${CANAL_DOWNLOAD_URL}" -o ${CANAL_DOWNLOAD_NAME}.tar.gz \
    && tar -xzf ${CANAL_DOWNLOAD_NAME}.tar.gz -C /opt/canal/${CANAL_COMPONENT_NAME} \
    && rm ${CANAL_DOWNLOAD_NAME}.tar.gz

FROM openjdk:11-jre-slim AS runtime

ARG CANAL_COMPONENT_VERSION=1.1.7
ENV CANAL_COMPONENT_NAME=canal-admin

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.name="${CANAL_COMPONENT_NAME}" \
      org.label-schema.version="${CANAL_COMPONENT_VERSION}" \
      org.label-schema.description="${CANAL_COMPONENT_NAME}" \
      org.label-schema.url="https://github.com/funnyzak/docker-publish" \
      org.label-schema.schema-version="${CANAL_COMPONENT_VERSION}"

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y --no-install-recommends file tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /opt/canal/${CANAL_COMPONENT_NAME} /opt/canal/${CANAL_COMPONENT_NAME}

WORKDIR /opt/canal/${CANAL_COMPONENT_NAME}

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]