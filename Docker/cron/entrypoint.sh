#!/bin/bash
set -e

chmod +x -R /scripts

rm -rf /var/spool/cron/crontabs && mkdir -m 0644 -p /var/spool/cron/crontabs

[ "$(ls -A /etc/cron.d)" ] && cp -f /etc/cron.d/* /var/spool/cron/crontabs/ || true

[ ! -z "$CRON_STRINGS" ] && echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/CRON_STRINGS

chmod -R 0644 /var/spool/cron/crontabs

if [ -n "$STARTUP_COMMANDS" ]; then
  echo -e "Executing Start Up commands: $STARTUP_COMMANDS"
  (eval "$STARTUP_COMMANDS") || (echo -e "Failed to execute Start Up commands: $STARTUP_COMMANDS" && exit 1)
else
    echo -e "No Start Up commands provided, skipping..."
fi

[ ! "$(ls -A /scripts)" ] && cp -f /example/scripts/* /scripts || true

mkdir -p /var/log/cron

crond -s /var/spool/cron/crontabs -L /var/log/cron/cron.log "$@" &

trap "echo 'Stopping crond...'; kill $!; exit 0" SIGTERM SIGINT

echo "Running crond..."

echo "Current crontab:"
cat /var/spool/cron/crontabs/*

tail -F /var/log/cron/cron.log 2>&1