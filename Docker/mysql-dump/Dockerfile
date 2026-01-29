FROM ubuntu:latest

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION

ENV TZ=Asia/Shanghai \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

LABEL org.label-schema.name="mysql-dump" \
    org.label-schema.description="mysql-dump" \
    org.label-schema.version="${VERSION}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        mysql-client \
        curl \
        tar \
        gzip \
        cron \
        ca-certificates \
        bash \
        zip \
        unzip \
        rsync \
        tzdata \
        procps && \
    mkdir -p /var/log/cron /run-scripts /etc/cron.d /var/spool/cron/crontabs && \
    touch /var/log/cron/cron.log && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Download mysql_backup.sh script from remote repository
RUN curl -fsSL https://raw.githubusercontent.com/funnyzak/dotfiles/refs/heads/main/utilities/shell/mysql/mysql_backup.sh \
    -o /run-scripts/mysql_backup.sh && \
    chmod +x /run-scripts/mysql_backup.sh

# Environment variables with defaults
ENV TMP_DIR_PATH=/tmp/backups
ENV SERVER_NAME=mysql-backup-server
ENV DB_DUMP_TARGET_DIR_PATH=/backup
ENV DB_DUMP_BY_SCHEMA=true
ENV DB_FILE_EXTENSION=sql
ENV ENABLE_COMPRESS=false
ENV EXPIRE_DAYS=180
ENV DUMP_AT_STARTUP=true
ENV DB_DUMP_CRON="0 0 * * *"
ENV DB_HOST=""
ENV DB_PORT=3306
ENV DB_USER=root
ENV DB_PASSWORD=""
ENV DB_NAMES=""
ENV DUMP_OPTS="--ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert"

# Advanced backup options
ENV LOG_DIR=""
ENV VERBOSE=false
ENV CONFIG_FILE=""
ENV PRE_BACKUP_COMMAND=""
ENV POST_BACKUP_COMMAND=""

# Notification environment variables
ENV APPRISE_URL=""
ENV APPRISE_TAGS="all"
ENV BARK_URL=""
ENV BARK_KEY=""

# Legacy environment variables for backward compatibility
ENV EXPIRE_HOURS=""
ENV COMPRESS_EXTENSION=""
ENV STARTUP_COMMAND=""
ENV BEFORE_DUMP_COMMAND=""
ENV AFTER_DUMP_COMMAND=""

COPY /scripts/entrypoint.sh /run-scripts/
RUN chmod +x /run-scripts/entrypoint.sh

WORKDIR $DB_DUMP_TARGET_DIR_PATH

ENTRYPOINT ["/bin/bash", "/run-scripts/entrypoint.sh"]
