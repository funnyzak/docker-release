#!/bin/sh
set -eu
umask 077
if [ "$#" -gt 0 ]; then
  exec "$@"
fi
mkdir -p "${DATA_DIR:-/data}"
# One worker owns each data volume; a second container must use another volume.
exec flock --no-fork --nonblock "${DATA_DIR:-/data}/worker.lock" node /app/service.mjs serve
