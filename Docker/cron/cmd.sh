#!/bin/sh
set -e

if [ ! -z "$CRON_TAIL" ] 
then
	crond -s /var/spool/cron/crontabs -b -L /var/log/cron/cron.log "$@" && tail -f /var/log/cron/cron.log
else
	crond -s /var/spool/cron/crontabs -f -L /var/log/cron/cron.log "$@"
fi
