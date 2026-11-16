#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../../.."
export IMAGE_NAME=funnyzak/snell-server DOCKER_TAG=latest BUILD_FILE=./Docker/snell-server/Dockerfile
export BUILD_PLATFORMS=linux/amd64,linux/arm64,linux/arm/v7,linux/386
check() { BUILD_ARGS="$1" bash .github/scripts/check-snell-latest.sh; }
check 'VERSION=5.0.1,BUILD_DATE=test'
check ''
if check 'VERSION=6.0.0'; then echo 'Beta was allowed' >&2; exit 1; fi
if check 'VERSION=5.0.1,VERSION=6.0.0'; then echo 'Duplicate override was allowed' >&2; exit 1; fi
if BUILD_FILE=Docker/other/Dockerfile check 'VERSION=5.0.1'; then exit 1; fi
if BUILD_PLATFORMS=linux/amd64 check 'VERSION=5.0.1'; then exit 1; fi
BUILD_PLATFORMS=linux/386,linux/arm64,linux/amd64,linux/arm/v7 check 'VERSION=5.0.1'
DOCKER_TAG=6.0.0 check 'VERSION=6.0.0'
IMAGE_NAME=funnyzak/other check 'VERSION=6.0.0'
echo 'PASS: Snell stable latest guard'
