#!/bin/sh

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}dify2open converts the Dify API to the OpenAI API format, giving you access to Dify's LLMs, knowledge base, tools, and workflows within your preferred OpenAI clients.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/dify2openai${NC}"
echo -e "${GREEN}GitHub: https://github.com/funnyzak/docker-release\n"

echo -e "${YELLOW}Environment Variables:${NC}"
echo -e "${BLUE}DIFY_API_URL=${DIFY_API_URL}\nBOT_TYPE=${BOT_TYPE}\nINPUT_VARIABLE=${INPUT_VARIABLE}\nOUTPUT_VARIABLE=${OUTPUT_VARIABLE}\nMODELS_NAME=${MODELS_NAME}${NC}\n"

echo -e "${BLUE}Dify2OpenAI started.${NC}"

node /app/app.js