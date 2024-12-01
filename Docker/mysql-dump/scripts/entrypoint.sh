#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

echo -e "${BLUE}mysql-dump is a simple MySQL backup tool that can backup all databases or specified databases. It can push message with pushoo and delete expired dump files. It supports custom commands before and after the dump, custom mysqldump options, compressed dump files, and crontab rules.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/mysql-dump${NC}"
echo -e "${GREEN}GitHub: https://github.com/funnyzak/docker-release\n"

chmod +x /run-scripts/*

CRON_STRINGS="$DB_DUMP_CRON /run-scripts/cron-backup.sh >> /var/log/cron/cron.log 2>&1"

echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/CRON_STRINGS

chmod -R 0644 /var/spool/cron/crontabs

if [ -n "$STARTUP_COMMAND" ]; then
  echo -e "\n${YELLOW}Executing Start Up commands: ${NC}$STARTUP_COMMAND"
  (eval "$STARTUP_COMMAND") && echo -e "${GREEN}Start Up commands executed successfully.${NC}\n" || (echo -e "${RED}Failed to execute Start Up commands: $STARTUP_COMMAND${NC}\n")
fi

if [ -n "$DUMP_AT_STARTUP" -a "$DUMP_AT_STARTUP" = "true" ]; then
  /run-scripts/cron-backup.sh >> /var/log/cron/cron.log 2>&1 &
fi

crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log "$@" && tail -f /var/log/cron/cron.log
