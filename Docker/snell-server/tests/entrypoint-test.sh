#!/usr/bin/env bash
# Usage: bash Docker/snell-server/tests/entrypoint-test.sh snell:test [linux/arm64]
set -euo pipefail
image=${1:?image is required}
platform=${2:-linux/amd64}
tmp=$(mktemp -d)
name="snell-entrypoint-test-$$"
cleanup() { docker rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$tmp"; }
trap cleanup EXIT
wait_running() {
  for _ in {1..20}; do
    if docker logs "$name" 2>&1 | grep -q 'Start snell server on'; then return; fi
    if [[ $(docker inspect -f '{{.State.Running}}' "$name") != true ]]; then
      echo 'Server exited before listening' >&2; return 1
    fi
    sleep 0.5
  done
  echo 'Server did not start listening' >&2; return 1
}
check_logs() {
  docker logs "$name" > "$tmp/log" 2>&1
  if grep -Ei 'snell-test-secret|psk[[:space:]]*=|Using PSK|\[snell-server\]' "$tmp/log"; then
    echo 'Credentials/configuration leaked into logs' >&2; return 1
  fi
  test "$(docker exec "$name" cat /proc/1/comm)" = tini
}
stop_cleanly() {
  docker stop -t 5 "$name" >/dev/null
  test "$(docker inspect -f '{{.State.ExitCode}}' "$name")" != 137
  docker rm "$name" >/dev/null
}
# Explicit PSK, private generated config, init signal forwarding and graceful shutdown.
docker run -d --platform "$platform" --name "$name" -e PSK=snell-test-secret-explicit "$image" >/dev/null
wait_running
check_logs
docker exec "$name" sh -c 'test "$(stat -c %a /etc/snell-server.conf)" = 600 && grep -q "^psk = snell-test-secret-explicit$" /etc/snell-server.conf'
stop_cleanly
# Generated PSK must be nonempty and absent from log output.
docker run -d --platform "$platform" --name "$name" "$image" >/dev/null
wait_running
check_logs
generated=$(docker exec "$name" sed -n 's/^psk = //p' /etc/snell-server.conf)
[[ "$generated" =~ ^[0-9a-f]{32}$ ]]
if grep -Fq "$generated" "$tmp/log"; then echo 'Generated PSK leaked' >&2; exit 1; fi
stop_cleanly
# Read-only user configuration takes precedence and is not modified or printed.
cat > "$tmp/server.conf" <<'CONF'
[snell-server]
listen = 0.0.0.0:6180
psk = snell-test-secret-mounted
ipv6 = false
CONF
cp "$tmp/server.conf" "$tmp/original.conf"
docker run -d --platform "$platform" --name "$name" -e PSK=ignored-environment-secret -v "$tmp/server.conf:/etc/snell-server.conf:ro" "$image" >/dev/null
wait_running
check_logs
cmp "$tmp/server.conf" "$tmp/original.conf"
stop_cleanly
echo "PASS: Snell entrypoint ($platform)"
