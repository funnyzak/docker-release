#!/bin/sh
set -e

chmod +x -R /scripts

rm -rf /var/spool/cron/crontabs && mkdir -m 0644 -p /var/spool/cron/crontabs

[ "$(ls -A /etc/cron.d)" ] && cp -f /etc/cron.d/* /var/spool/cron/crontabs/ || true

[ ! -z "$CRON_STRINGS" ] && echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/CRON_STRINGS

chmod -R 0644 /var/spool/cron/crontabs

if [ -n "$STARTUP_COMMANDS" ]; then
  echo -e "on startup command do: ${STARTUP_COMMANDS}" 
  (eval "$STARTUP_COMMANDS") || (echo -e "Start Up failed. Aborting;"; exit 1)
else
    echo -e "no startup command. skiped."
fi

exec "$@"