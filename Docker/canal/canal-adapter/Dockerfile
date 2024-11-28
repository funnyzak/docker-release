FROM alpine:3.20.3 AS build

ARG VERSION=1.1.7
ENV DOWNLOAD_NAME=canal.adapter
ENV COMPONENT_NAME=canal-adapter
ENV DOWNLOAD_LINK=https://github.com/alibaba/canal/releases/download/canal-${VERSION}/${DOWNLOAD_NAME}-${VERSION}.tar.gz

RUN apk add --no-cache curl tar \
    && mkdir -p /opt/canal/${COMPONENT_NAME} \
    && curl -fSL "${DOWNLOAD_LINK}" -o ${DOWNLOAD_NAME}.tar.gz \
    && tar -xzf ${DOWNLOAD_NAME}.tar.gz -C /opt/canal/${COMPONENT_NAME} \
    && rm ${DOWNLOAD_NAME}.tar.gz

FROM openjdk:11-jre-slim AS runtime

ARG BUILD_DATE
ARG VERSION=1.1.7
ENV COMPONENT_NAME=canal-adapter

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.name="${COMPONENT_NAME}" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.description="${COMPONENT_NAME}" \
      org.label-schema.url="https://github.com/funnyzak/docker-publish" \
      org.label-schema.build-date="${BUILD_DATE}"

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    VERSION=${VERSION}

RUN set -eux \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y --no-install-recommends file tzdata \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=build /opt/canal/${COMPONENT_NAME} /opt/canal/${COMPONENT_NAME}

WORKDIR /opt/canal/${COMPONENT_NAME}

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]