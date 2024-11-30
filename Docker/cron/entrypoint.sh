#!/bin/bash
set -e

chmod +x -R /scripts

echo -e "cron is a lightweight Docker image containing Cron, based on Alpine Linux. Includes some useful tools for cron jobs."
echo -e "Installed Packages:${INSTALL_PACKAGES}.\n"
echo -e "Docker Hub: https://hub.docker.com/r/funnyzak/cron"
echo -e "GitHub: https://github.com/funnyzak/docker-release\n"

[ ! "$(ls -A /scripts)" ] && cp -f /example/scripts/* /scripts || true

rm -rf /var/spool/cron/crontabs && mkdir -m 0644 -p /var/spool/cron/crontabs

[ "$(ls -A /etc/cron.d)" ] && cp -f /etc/cron.d/* /var/spool/cron/crontabs/ || true

[ ! -z "$CRON_STRINGS" ] && echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/CRON_STRINGS

chmod -R 0644 /var/spool/cron/crontabs

if [ -n "$EXTRA_PACKAGES" ]; then
  echo -e "Installing Extra Packages: $EXTRA_PACKAGES"
  apk add --no-cache $EXTRA_PACKAGES || (echo -e "Failed to install Extra Packages: $EXTRA_PACKAGES")
fi

if [ -n "$STARTUP_COMMANDS" ]; then
  echo -e "Executing Start Up commands: $STARTUP_COMMANDS"
  (eval "$STARTUP_COMMANDS") || (echo -e "Failed to execute Start Up commands: $STARTUP_COMMANDS" && exit 1)
fi

mkdir -p /var/log/cron

crond -s /var/spool/cron/crontabs -L /var/log/cron/cron.log "$@" &

trap "echo 'Stopping crond...'; kill $!; exit 0" SIGTERM SIGINT

echo "Running crond..."

# check  /var/spool/cron/crontabs/ exists crontab
if [ "$(ls -A /var/spool/cron/crontabs/)" ]; then
  echo "Current crontab:"
  cat /var/spool/cron/crontabs/*
else
  echo "No crontab found in /var/spool/cron/crontabs/, Will exit now..."
  echo "Please mount your crontab file to /var/spool/cron/crontabs/ and restart the container."
  exit 1
fi

tail -F /var/log/cron/cron.log 2>&1