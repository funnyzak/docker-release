#!/usr/bin/env bash
# Fail closed: floating Snell latest requires the reviewed stable version.
set -euo pipefail
[[ "${IMAGE_NAME##*/}" == snell-server && "$DOCKER_TAG" == latest ]] || exit 0
stable=$(jq -er '.version' Docker/snell-server/stable-release.json)
[[ "$BUILD_FILE" == './Docker/snell-server/Dockerfile' || "$BUILD_FILE" == 'Docker/snell-server/Dockerfile' ]] || {
  echo 'Snell latest requires the canonical Dockerfile.' >&2; exit 1;
}
versions=$(printf '%s' "$BUILD_ARGS" | tr ',' '\n' | sed -n 's/^VERSION=//p')
if [[ -z "$versions" ]]; then
  versions=$(sed -n 's/^ARG VERSION=//p' "$BUILD_FILE" | sort -u)
fi
[[ "$versions" == "$stable" ]] || {
  echo "Snell latest only permits reviewed stable $stable; use an explicit version tag for prereleases." >&2
  exit 1
}
expected=$(jq -c '.platforms | sort' Docker/snell-server/stable-release.json)
actual=$(printf '%s' "$BUILD_PLATFORMS" | jq -Rc 'split(",") | map(gsub("\\s"; "")) | sort')
[[ "$actual" == "$expected" ]] || {
  echo 'Snell latest requires all reviewed stable platforms.' >&2; exit 1;
}
