#!/bin/sh
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}vCards $(cat /app/VERSION)${NC}"
echo -e "${BLUE}Import frequently used contact avatars and optimize iOS caller and message interface experience.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/vcard${NC}"
echo -e "${GREEN}Repository: https://github.com/metowolf/vCards${NC}"
echo -e "${GREEN}Build via: https://github.com/funnyzak/docker-release${NC}\n"

radicale