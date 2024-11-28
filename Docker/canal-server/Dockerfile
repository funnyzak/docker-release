FROM alpine:3.20.3 as build

ARG CANAL_COMPONENT_VERSION=1.1.6
ENV CANAL_DOWNLOAD_NAME=canal.server
ENV CANAL_COMPONENT_NAME=canal-server
ENV CANAL_ADAPTER_DOWNLOAD_URL=https://github.com/alibaba/canal/releases/download/canal-${CANAL_COMPONENT_VERSION}/${CANAL_DOWNLOAD_NAME}-${CANAL_COMPONENT_VERSION}.tar.gz

RUN apk add --no-cache curl tar \
    && mkdir -p /opt/canal/${CANAL_COMPONENT_NAME} \
    && curl -fSL "${CANAL_ADAPTER_DOWNLOAD_URL}" -o ${CANAL_DOWNLOAD_NAME}.tar.gz \
    && tar -xzf ${CANAL_DOWNLOAD_NAME}.tar.gz -C /opt/canal/${CANAL_COMPONENT_NAME} \
    && rm ${CANAL_DOWNLOAD_NAME}.tar.gz

# Final stage
FROM openjdk:11-jre-slim

ARG BUILD_DATE
ARG VCS_REF
ARG CANAL_COMPONENT_VERSION=1.1.6
ARG CANAL_COMPONENT_NAME=canal-server

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.name="${CANAL_COMPONENT_NAME}" \
      org.label-schema.description="${CANAL_COMPONENT_NAME}" \
      org.label-schema.url="https://yycc.dev" \
      org.label-schema.schema-version="${CANAL_COMPONENT_VERSION}" \
      org.label-schema.vcs-type="Git" \
      org.label-schema.vcs-ref="${VCS_REF}"

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

COPY --from=build /opt/canal/${CANAL_COMPONENT_NAME} /opt/canal/${CANAL_COMPONENT_NAME}

WORKDIR /opt/canal/${CANAL_COMPONENT_NAME}

COPY entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
