#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

chmod +x -R /scripts

echo -e "cron is a lightweight Docker image containing Cron, based on Alpine Linux. Includes some useful tools for cron jobs."
echo -e "${YELLOW}Installed Packages:${INSTALL_PACKAGES}.\n${NC}"
echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/cron${NC}"
echo -e "${GREEN}GitHub: https://github.com/funnyzak/docker-release\n"

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
  echo -e "\n${YELLOW}Executing Start Up commands: ${NC}$STARTUP_COMMANDS"
  (eval "$STARTUP_COMMANDS") && echo -e "${GREEN}Start Up commands executed successfully.${NC}\n" || (echo -e "${RED}Failed to execute Start Up commands: $STARTUP_COMMANDS${NC}\n")
fi

mkdir -p /var/log/cron

crond -s /var/spool/cron/crontabs -L /var/log/cron/cron.log "$@" &

trap "echo 'Stopping crond...'; kill $!; exit 0" SIGTERM SIGINT

# check  /var/spool/cron/crontabs/ exists crontab
if [ "$(ls -A /var/spool/cron/crontabs/)" ]; then
  echo -e "${YELLOW}Current crontab:${NC}"
  echo -e "${BLUE}$(cat /var/spool/cron/crontabs/*)${NC}"
  echo -e "${GREEN}Cron jobs are running.${NC}"
else
  echo -e "${RED}No crontab found in /var/spool/cron/crontabs/, will not run any cron jobs.\nlease mount your crontab file to /var/spool/cron/crontabs/ and restart the container.${NC}\n"
  echo -e "${YELLOW}Example:${NC}"
  echo -e "${BLUE}docker run --name=\"cron\" -d -e 'CRON_STRINGS=* * * * * echo \"Hi, i am cron.\" >> /var/log/cron/cron.log 2>&1' funnyzak/cron${NC}"
fi

tail -F /var/log/cron/cron.log 2>&1