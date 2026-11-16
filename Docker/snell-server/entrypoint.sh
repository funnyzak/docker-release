#!/bin/bash
set -eu

BIN="/opt/snell-server/snell-server"
CONF="/etc/snell-server.conf"

printf 'Starting snell-server %s...\n' "${VERSION:-unknown}"

if [ ! -f "$CONF" ]; then
  # A generated configuration contains credentials; never print it or its PSK.
  umask 077
  PSK=${PSK:-$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')}
  PORT=${PORT:-6180}
  IPV6=${IPV6:-false}
  EGRESS_INTERFACE=${EGRESS_INTERFACE:-}

  cat > "$CONF" <<EOF_CONFIG
[snell-server]
listen = 0.0.0.0:${PORT}
psk = ${PSK}
ipv6 = ${IPV6}
EOF_CONFIG

  if [ -n "$EGRESS_INTERFACE" ]; then
    printf 'egress-interface = %s\n' "$EGRESS_INTERFACE" >> "$CONF"
  fi
  echo 'Created server configuration. Credentials are not logged.'
fi

# Preserve mounted configurations and let the server receive container signals.
exec "$BIN" -c "$CONF"
