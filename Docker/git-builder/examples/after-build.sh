#!/bin/sh
set -eu
# Optional SSH/systemd example; other deployment targets can use their own commands.
# Mount this file as /config/after-build.sh:ro and configure after_build to call it.
# The deployment account, host and service are supplied through container environment.
: "${DEPLOY_HOST:?Set DEPLOY_HOST}"
: "${DEPLOY_USER:?Set DEPLOY_USER}"
: "${DEPLOY_SERVICE:?Set DEPLOY_SERVICE}"
: "${BUILD_ARTIFACT_DIR:?Missing build context}"

# SSH executes a remote shell: restrict identifiers before composing its command.
case "$DEPLOY_HOST" in ''|-*|*[!a-zA-Z0-9.-]*) echo 'Invalid DEPLOY_HOST' >&2; exit 1 ;; esac
case "$DEPLOY_USER" in ''|-*|*[!a-zA-Z0-9_-]*) echo 'Invalid DEPLOY_USER' >&2; exit 1 ;; esac
case "$DEPLOY_SERVICE" in ''|-*|*[!a-zA-Z0-9_.@-]*) echo 'Invalid DEPLOY_SERVICE' >&2; exit 1 ;; esac

# This only restarts an existing remote service. Add your reviewed upload/install steps before it.
ssh -o BatchMode=yes -o StrictHostKeyChecking=yes -o ConnectTimeout=10 \
  "${DEPLOY_USER}@${DEPLOY_HOST}" "sudo -n systemctl restart -- ${DEPLOY_SERVICE}"
