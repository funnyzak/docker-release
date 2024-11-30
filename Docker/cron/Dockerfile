FROM alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    INSTALL_PACKAGES="dcron ca-certificates curl tar tzdata bash zip unzip rsync"

LABEL org.label-schema.name="Alpine CRON" \
      org.label-schema.description="CRON is a lightweight Docker image containing Cron, based on Alpine Linux. Includes some useful tools for cron jobs. Such as ${INSTALL_PACKAGES}." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apk update && apk upgrade && \
    apk add --no-cache ${INSTALL_PACKAGES} && \
    mkdir -p /var/log/cron /scripts /etc/cron.d /var/spool/cron/crontabs && \
    chmod 0644 /var/spool/cron/crontabs && \
    touch /var/log/cron/cron.log && \
    rm -rf /tmp/* /var/cache/apk/*

COPY entrypoint.sh /
COPY example /example

WORKDIR /

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
