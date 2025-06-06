FROM funnyzak/cron:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

LABEL org.label-schema.name="mysql-dump" \
    org.label-schema.description="mysql-dump" \
    org.label-schema.version="${VERSION}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apk update && apk upgrade && \
    apk add --no-cache mysql-client mariadb-connector-c npm && \
    rm  -rf /tmp/* /var/cache/apk/*

RUN npm install -g pushoo-cli

ENV TMP_DIR_PATH /tmp/backups

ENV SERVER_NAME=mysql-backup-server
ENV DB_DUMP_TARGET_DIR_PATH /backup
ENV DB_DUMP_BY_SCHEMA=true
ENV DB_FILE_EXTENSION=sql
ENV COMPRESS_EXTENSION=zip
ENV EXPIRE_HOURS=4320
ENV DUMP_AT_STARTUP=true

COPY /scripts/* /run-scripts/
RUN chmod +x /run-scripts/*

WORKDIR $DB_DUMP_TARGET_DIR_PATH

ENTRYPOINT ["/bin/bash", "/run-scripts/entrypoint.sh"]
