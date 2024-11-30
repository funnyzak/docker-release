FROM alpine

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

LABEL org.label-schema.name="Alpine CRON" \
      org.label-schema.description="Alpine CRON" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apk update && apk upgrade && \
    apk add --no-cache dcron ca-certificates curl tar tzdata bash zip unzip rsync && \
    mkdir -p /var/log/cron /scripts /etc/cron.d /var/spool/cron/crontabs && \
    chmod 0644 /var/spool/cron/crontabs && \
    touch /var/log/cron/cron.log && \
    rm -rf /tmp/* /var/cache/apk/*

COPY cmd.sh entrypoint.sh /run_scripts/
RUN chmod +x /run_scripts/*.sh

ENTRYPOINT ["/run_scripts/entrypoint.sh"]
CMD ["/run_scripts/cmd.sh"]