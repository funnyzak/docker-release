#!/bin/bash

export PATH=$PATH:/usr/local/bin

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}${REPO_NAME} $(cat /app/VERSION)${NC}"
echo -e "${BLUE}Import frequently used contact avatars and optimize iOS caller and message interface experience.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/vcards${NC}"
echo -e "${GREEN}Repository: https://github.com/${REPO_NAME}${NC}"
echo -e "${GREEN}Build via: https://github.com/funnyzak/docker-release${NC}\n"

echo -e "${GREEN}Has vCards: $(find /app/vcards/collection-root/cn -name '*.vcf' | wc -l) files.${NC}\n"

chmod +x /run-scripts/*

mkdir -p /var/log/radicale /var/log/cron
touch /var/log/radicale/radicale.log /var/log/cron/cron.log

if [ -n "$SYNC_CRON" ]; then
  radicale >> /var/log/radicale/radicale.log 2>&1 &
  echo -e "${GREEN}Radicale is running.${NC}"

  echo -e "\n${GREEN}The vCard will be synchronized according to the following cron expression: ${SYNC_CRON}${NC}"
  echo -e "${YELLOW}Note: fetch the latest vCards from the repo: https://github.com/${REPO_NAME}${NC}\n"

  CRON_STRINGS="$SYNC_CRON /run-scripts/cron-vcard.sh >> /var/log/cron/cron.log 2>&1"
  echo -e "$CRON_STRINGS\n" > /var/spool/cron/crontabs/root
  chmod 0644 /var/spool/cron/crontabs/root

  crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log "$@" && tail -f /var/log/cron/cron.log
else 
  echo -e "${RED}Sync vCard cron is empty, data will not be synchronized.${NC}"
  radicale
fi