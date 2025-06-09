#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

set -e

echo -e "${BLUE}mysql-dump is a professional MySQL backup tool that can backup all databases or specified databases. It supports notifications, automatic cleanup, and crontab scheduling.${NC}\n"

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/mysql-dump${NC}"
echo -e "${GREEN}GitHub: https://github.com/funnyzak/docker-release\n${NC}"

chmod +x /run-scripts/*

# Create backup script wrapper
cat > /run-scripts/backup-wrapper.sh << 'EOF'
#!/bin/bash

# Set up environment variables for mysql_backup.sh
export MYSQL_HOST="${DB_HOST:-127.0.0.1}"
export MYSQL_PORT="${DB_PORT:-3306}"
export MYSQL_USER="${DB_USER:-root}"
export MYSQL_PASSWORD="${DB_PASSWORD:-}"

# Map database names (comma-separated)
if [[ -n "${DB_NAMES}" ]]; then
    # Convert space-separated to comma-separated
    DATABASES=$(echo "${DB_NAMES}" | tr ' ' ',')
else
    DATABASES=""
fi

# Set backup options
OUTPUT_DIR="${DB_DUMP_TARGET_DIR_PATH:-/backup}"

# Handle retention days with backward compatibility
RETENTION_DAYS="${EXPIRE_DAYS:-180}"
if [[ -n "${EXPIRE_HOURS}" ]]; then
    # Legacy support: convert hours to days
    RETENTION_DAYS=$((EXPIRE_HOURS / 24))
    echo "Warning: EXPIRE_HOURS is deprecated, please use EXPIRE_DAYS instead"
fi

# Handle compression with backward compatibility
COMPRESS_FLAG=""
if [[ "${ENABLE_COMPRESS}" == "true" ]]; then
    COMPRESS_FLAG="--compress"
elif [[ -n "${COMPRESS_EXTENSION}" ]]; then
    # Legacy support
    if [[ "${COMPRESS_EXTENSION}" == "zip" ]] || [[ "${COMPRESS_EXTENSION}" == "tar.gz" ]]; then
        COMPRESS_FLAG="--compress"
        echo "Warning: COMPRESS_EXTENSION is deprecated, please use ENABLE_COMPRESS=true instead"
    fi
fi

# Set file suffix
FILE_SUFFIX="${DB_FILE_EXTENSION:-sql}"

# Set extra mysqldump options
EXTRA_OPTS="${DUMP_OPTS:---ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert}"

# Set instance name
INSTANCE_NAME="${SERVER_NAME:-mysql-backup-server}"

# Set notification variables
export APPRISE_URL="${APPRISE_URL:-}"
export APPRISE_TAGS="${APPRISE_TAGS:-all}"
export BARK_URL="${BARK_URL:-}"
export BARK_KEY="${BARK_KEY:-}"

# Set advanced options
LOG_DIR_OPTION=""
if [[ -n "${LOG_DIR}" ]]; then
    LOG_DIR_OPTION="--log-dir \"$LOG_DIR\""
fi

VERBOSE_FLAG=""
if [[ "${VERBOSE}" == "true" ]]; then
    VERBOSE_FLAG="--verbose"
fi

CONFIG_FILE_OPTION=""
if [[ -n "${CONFIG_FILE}" && -f "${CONFIG_FILE}" ]]; then
    CONFIG_FILE_OPTION="--config \"$CONFIG_FILE\""
fi

# Handle pre/post commands with backward compatibility
PRE_CMD="${PRE_BACKUP_COMMAND:-${BEFORE_DUMP_COMMAND:-}}"
POST_CMD="${POST_BACKUP_COMMAND:-${AFTER_DUMP_COMMAND:-}}"

# Execute pre-backup command if specified
if [[ -n "${PRE_CMD}" ]]; then
    echo "Executing pre-backup command: ${PRE_CMD}"
    eval "${PRE_CMD}"
fi

# Build mysql_backup.sh command
BACKUP_CMD="/run-scripts/mysql_backup.sh"
BACKUP_CMD="$BACKUP_CMD --name \"$INSTANCE_NAME\""
BACKUP_CMD="$BACKUP_CMD --host \"$MYSQL_HOST\""
BACKUP_CMD="$BACKUP_CMD --port \"$MYSQL_PORT\""
BACKUP_CMD="$BACKUP_CMD --user \"$MYSQL_USER\""
if [[ -n "$MYSQL_PASSWORD" ]]; then
    BACKUP_CMD="$BACKUP_CMD --password \"$MYSQL_PASSWORD\""
fi
if [[ -n "$DATABASES" ]]; then
    BACKUP_CMD="$BACKUP_CMD --databases \"$DATABASES\""
fi
BACKUP_CMD="$BACKUP_CMD --output \"$OUTPUT_DIR\""
BACKUP_CMD="$BACKUP_CMD --suffix \"$FILE_SUFFIX\""
BACKUP_CMD="$BACKUP_CMD --extra-opts \"$EXTRA_OPTS\""
if [[ -n "$COMPRESS_FLAG" ]]; then
    BACKUP_CMD="$BACKUP_CMD $COMPRESS_FLAG"
fi
BACKUP_CMD="$BACKUP_CMD --retention \"$RETENTION_DAYS\""

# Add advanced options
if [[ -n "$LOG_DIR_OPTION" ]]; then
    BACKUP_CMD="$BACKUP_CMD $LOG_DIR_OPTION"
fi
if [[ -n "$VERBOSE_FLAG" ]]; then
    BACKUP_CMD="$BACKUP_CMD $VERBOSE_FLAG"
fi
if [[ -n "$CONFIG_FILE_OPTION" ]]; then
    BACKUP_CMD="$BACKUP_CMD $CONFIG_FILE_OPTION"
fi

# Add pre/post commands
if [[ -n "$PRE_CMD" ]]; then
    BACKUP_CMD="$BACKUP_CMD --pre-cmd \"$PRE_CMD\""
fi
if [[ -n "$POST_CMD" ]]; then
    BACKUP_CMD="$BACKUP_CMD --post-cmd \"$POST_CMD\""
fi

# Add notification parameters if configured
if [[ -n "$APPRISE_URL" ]]; then
    BACKUP_CMD="$BACKUP_CMD --apprise-url \"$APPRISE_URL\""
fi
if [[ -n "$APPRISE_TAGS" ]]; then
    BACKUP_CMD="$BACKUP_CMD --apprise-tags \"$APPRISE_TAGS\""
fi
if [[ -n "$BARK_URL" ]]; then
    BACKUP_CMD="$BACKUP_CMD --bark-url \"$BARK_URL\""
fi
if [[ -n "$BARK_KEY" ]]; then
    BACKUP_CMD="$BACKUP_CMD --bark-key \"$BARK_KEY\""
fi

# Execute backup
echo "Executing backup command..."
eval "$BACKUP_CMD"

# Execute post-backup command if specified (legacy support)
if [[ -n "${POST_CMD}" && -z "${PRE_BACKUP_COMMAND}" ]]; then
    echo "Executing post-backup command: ${POST_CMD}"
    eval "${POST_CMD}"
fi
EOF

chmod +x /run-scripts/backup-wrapper.sh

# Set up cron job
CRON_STRINGS="${DB_DUMP_CRON:-0 0 * * *} /run-scripts/backup-wrapper.sh >> /var/log/cron/cron.log 2>&1"

# Create crontab for root user
echo "$CRON_STRINGS" | crontab -

# Ensure cron service is configured
service cron start

# Execute startup command if specified (backward compatibility)
STARTUP_CMD="${STARTUP_COMMAND:-}"
if [[ -n "$STARTUP_CMD" ]]; then
    echo -e "\n${YELLOW}Executing startup command: ${NC}$STARTUP_CMD"
    (eval "$STARTUP_CMD") && echo -e "${GREEN}Startup command executed successfully.${NC}\n" || (echo -e "${RED}Failed to execute startup command: $STARTUP_CMD${NC}\n")
fi

# Run backup at startup if enabled
if [[ -n "$DUMP_AT_STARTUP" && "$DUMP_AT_STARTUP" = "true" ]]; then
    echo -e "${YELLOW}Running backup at startup...${NC}"
    /run-scripts/backup-wrapper.sh >> /var/log/cron/cron.log 2>&1 &
fi

# Keep cron running and tail logs
tail -f /var/log/cron/cron.log &

# Keep the container running
while true; do
    sleep 60
    # Check if cron is still running, restart if needed
    if ! pgrep cron > /dev/null; then
        echo "Cron service stopped, restarting..."
        service cron start
    fi
done
