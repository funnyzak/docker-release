#!/bin/bash

set -e

echo -e "mysql-dump is a simple MySQL backup tool that can backup all databases or specified databases. It can push message with pushoo and delete expired dump files. It supports custom commands before and after the dump, custom mysqldump options, compressed dump files, and crontab rules."
echo -e "Docker Hub: https://hub.docker.com/r/funnyzak/mysql-dump"
echo -e "GitHub: https://github.com/funnyzak/docker-release\n"

chmod +x /run-scripts/*

CRON_STRINGS="$DB_DUMP_CRON /run-scripts/cron-backup.sh >> /var/log/cron/cron.log 2>&1"

echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/CRON_STRINGS

chmod -R 0644 /var/spool/cron/crontabs

if [ -n "$STARTUP_COMMAND" ]; then
    echo -e "Execute startup command: $STARTUP_COMMAND"
    $STARTUP_COMMAND 2>tmp_error_log || (echo "execute after dump command failed. error message: `cat tmp_error_log`")
fi

if [ -n "$DUMP_AT_STARTUP" -a "$DUMP_AT_STARTUP" = "true" ]; then
    /run-scripts/cron-backup.sh >> /var/log/cron/cron.log 2>&1 &
fi

crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log "$@" && tail -f /var/log/cron/cron.log
