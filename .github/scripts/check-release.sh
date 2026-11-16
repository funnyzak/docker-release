#!/usr/bin/env bash
set -euo pipefail
# VERSION_COMMAND is repository-maintained code, not an untrusted external response.
version=$(bash -eo pipefail -c "$VERSION_COMMAND")
if [[ -z "$version" || "$version" == null || "$version" == no-tags ]]; then
  echo 'No upstream release available.' >&2
  echo 'is_new_release_version=false' >> "$GITHUB_OUTPUT"
  exit 0
fi
if [[ ! "$version" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]]; then
  echo 'Upstream returned an invalid Docker tag.' >&2
  exit 1
fi
body=$(mktemp)
trap 'rm -f "$body"' EXIT
status=$(curl --silent --show-error --location --retry 3 --connect-timeout 15 --max-time 60 \
  -o "$body" -w '%{http_code}' "https://hub.docker.com/v2/repositories/funnyzak/$IMAGE_NAME/tags/$version")
case "$status" in
  200) is_new=false ;;
  404) is_new=true ;;
  *) echo "Docker Hub tag lookup failed: HTTP $status" >&2; exit 1 ;;
esac
{
  echo "new_release_version=$version"
  echo "is_new_release_version=$is_new"
  if [[ "$IS_LATEST_TAG" == true ]]; then
    echo "docker_tags=latest,$version"
  else
    echo "docker_tags=$version"
  fi
} >> "$GITHUB_OUTPUT"
