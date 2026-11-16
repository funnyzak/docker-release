#!/bin/bash
# Author: Leon<silenceace at gmail.com>

HEALTHCHECK_URL="http://127.0.0.1:80"
if [ -n "$HEALTHCHECK_URL" ]; then
  curl -s -f $HEALTHCHECK_URL > /dev/null
  if [ $? -ne 0 ]; then
    echo "Health check failed. Please check your nginx config."
    exit 1
  fi
fi