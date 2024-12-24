#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

export PATH=$PATH:/usr/local/bin

VCARD_DIR_PATH="/app/vcards/collection-root/cn"
CURRENT_VERSION=$(cat /app/VERSION)

download_and_sync() {
  local VERSION=$1
  echo -e "Downloading vCards version: ${VERSION}."

  mkdir -p ${DOWNLOAD_DIR}/vcards/${VERSION}

  curl -sSL https://github.com/${REPO_NAME}/releases/download/${VERSION}/archive.zip -o ${DOWNLOAD_DIR}/vcards/archive-${VERSION}.zip
  unzip -o ${DOWNLOAD_DIR}/vcards/archive-${VERSION}.zip -d ${DOWNLOAD_DIR}/vcards/${VERSION}
  if [ -n "$(find ${DOWNLOAD_DIR}/vcards/${VERSION} -name '*.vcf')" ]; then
    rsync -a --update --ignore-existing --exclude='汇总/' ${DOWNLOAD_DIR}/vcards/${VERSION}/* ${VCARD_DIR_PATH}
    echo -e "Sync vCards done, $(find ${VCARD_DIR_PATH} -name '*.vcf' | wc -l) files synced."
  else
    echo -e "${RED}Sync vCards failed, no vcf files found.${NC}"
  fi
}

echo -e "${GREEN}Current vCards: $(find ${VCARD_DIR_PATH} -name '*.vcf' | wc -l) files.${NC}"

echo -e "${GREEN}${REPO_NAME} ${CURRENT_VERSION}, syncing vCards.${NC}"

echo -e "${BLUE}Checking latest version from GitHub.${NC}"
LATEST_VERSION=$(curl -s https://api.github.com/repos/${REPO_NAME}/releases/latest | jq -r '.tag_name')
if [ -z "$LATEST_VERSION" ] || [ "$LATEST_VERSION" == "null" ]; then
  echo -e "${RED}Get latest version failed. Please check network or repository. ${NC}"
else
  if [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
    echo -e "${YELLOW}Current version: ${CURRENT_VERSION} is the latest version, no need to update.${NC}"
  else
    echo -e "${BLUE}Current version: ${CURRENT_VERSION}, latest version: ${LATEST_VERSION}, downloading and syncing.${NC}"
    download_and_sync $LATEST_VERSION
    echo $LATEST_VERSION > /app/VERSION
  fi
fi

