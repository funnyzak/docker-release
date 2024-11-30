#!/bin/bash

set -e

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
