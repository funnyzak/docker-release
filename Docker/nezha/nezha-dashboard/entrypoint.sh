#!/bin/sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}NeZha-Dashboard $(cat /VERSION)${NC}"
echo -e "${BLUE}NeZha-Dashboard Open-source, lightweight, and easy-to-use server monitoring and operation tool.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/nezha-dashboard${NC}"
echo -e "${GREEN}Repository: https://github.com/nezhahq/nezha${NC}"
echo -e "${GREEN}Build via: https://github.com/funnyzak/docker-release${NC}\n"

printf "nameserver 127.0.0.11\nnameserver 8.8.4.4\nnameserver 223.5.5.5\n" > /etc/resolv.conf
exec /dashboard/app