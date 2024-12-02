#!/bin/sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Certimate $(cat /app/VERSION)${NC}"
echo -e "${BLUE}Certimate aims to provide users with a secure and user-friendly SSL certificate management solution.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/certmate${NC}"
echo -e "${GREEN}Repository: https://github.com/usual2970/certimate${NC}"
echo -e "${GREEN}Build via: https://github.com/funnyzak/docker-release${NC}\n"

/app/certimate serve --http 0.0.0.0:${PORT:-8090}