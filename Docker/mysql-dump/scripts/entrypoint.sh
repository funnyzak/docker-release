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

# Function to escape shell arguments
escape_arg() {
    local arg="$1"
    # Escape single quotes by replacing ' with '\''
    arg="${arg//\'/\'\\\'\'}"
    echo "'$arg'"
}

# Function to build backup command with all parameters
build_backup_command() {
    local cmd="/run-scripts/mysql_backup.sh"
    
    # Basic connection parameters
    cmd="$cmd --host $(escape_arg "${DB_HOST:-127.0.0.1}")"
    cmd="$cmd --port $(escape_arg "${DB_PORT:-3306}")"
    cmd="$cmd --user $(escape_arg "${DB_USER:-root}")"
    
    # Password (only add if not empty)
    if [[ -n "${DB_PASSWORD}" ]]; then
        cmd="$cmd --password $(escape_arg "${DB_PASSWORD}")"
    fi
    
    # Database names (convert space-separated to comma-separated)
    if [[ -n "${DB_NAMES}" ]]; then
        local databases
        databases=$(echo "${DB_NAMES}" | tr ' ' ',')
        cmd="$cmd --databases $(escape_arg "$databases")"
    fi
    
    # Output directory
    cmd="$cmd --output $(escape_arg "${DB_DUMP_TARGET_DIR_PATH:-/backup}")"
    
    # File suffix
    cmd="$cmd --suffix $(escape_arg "${DB_FILE_EXTENSION:-sql}")"
    
    # Extra mysqldump options
    local extra_opts="${DUMP_OPTS:---ssl-mode=DISABLED --single-transaction --routines --triggers --events --hex-blob --complete-insert}"
    cmd="$cmd --extra-opts $(escape_arg "$extra_opts")"
    
    # Compression
    if [[ "${ENABLE_COMPRESS}" == "true" ]]; then
        cmd="$cmd --compress"
    elif [[ -n "${COMPRESS_EXTENSION}" ]]; then
        # Legacy support
        if [[ "${COMPRESS_EXTENSION}" == "zip" ]] || [[ "${COMPRESS_EXTENSION}" == "tar.gz" ]]; then
            cmd="$cmd --compress"
        fi
    fi
    
    # Retention days (handle backward compatibility)
    local retention_days="${EXPIRE_DAYS:-180}"
    if [[ -n "${EXPIRE_HOURS}" ]]; then
        # Legacy support: convert hours to days
        retention_days=$((EXPIRE_HOURS / 24))
    fi
    cmd="$cmd --retention $(escape_arg "$retention_days")"
    
    # Instance name
    cmd="$cmd --name $(escape_arg "${SERVER_NAME:-mysql-backup-server}")"
    
    # Advanced options
    if [[ -n "${LOG_DIR}" ]]; then
        cmd="$cmd --log-dir $(escape_arg "$LOG_DIR")"
    fi
    
    if [[ "${VERBOSE}" == "true" ]]; then
        cmd="$cmd --verbose"
    fi
    
    if [[ -n "${CONFIG_FILE}" && -f "${CONFIG_FILE}" ]]; then
        cmd="$cmd --config $(escape_arg "$CONFIG_FILE")"
    fi
    
    # Pre/post commands (handle backward compatibility)
    local pre_cmd="${PRE_BACKUP_COMMAND:-${BEFORE_DUMP_COMMAND:-}}"
    local post_cmd="${POST_BACKUP_COMMAND:-${AFTER_DUMP_COMMAND:-}}"
    
    if [[ -n "$pre_cmd" ]]; then
        cmd="$cmd --pre-cmd $(escape_arg "$pre_cmd")"
    fi
    
    if [[ -n "$post_cmd" ]]; then
        cmd="$cmd --post-cmd $(escape_arg "$post_cmd")"
    fi
    
    # Notification parameters
    if [[ -n "${APPRISE_URL}" ]]; then
        cmd="$cmd --apprise-url $(escape_arg "$APPRISE_URL")"
    fi
    
    if [[ -n "${APPRISE_TAGS}" ]]; then
        cmd="$cmd --apprise-tags $(escape_arg "$APPRISE_TAGS")"
    fi
    
    if [[ -n "${BARK_URL}" ]]; then
        cmd="$cmd --bark-url $(escape_arg "$BARK_URL")"
    fi
    
    if [[ -n "${BARK_KEY}" ]]; then
        cmd="$cmd --bark-key $(escape_arg "$BARK_KEY")"
    fi
    
    echo "$cmd"
}

# Create backup script that will be executed by cron
create_backup_script() {
    local backup_cmd
    backup_cmd=$(build_backup_command)
    
    cat > /run-scripts/backup-cron.sh << EOF
#!/bin/bash

# Set minimal environment for cron
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export SHELL="/bin/bash"

# Set timezone to ensure cron runs in system timezone
export TZ=\${TZ:-UTC}

# Log start time
echo "\$(date '+%Y-%m-%d %H:%M:%S') - Starting scheduled backup..."

# Execute backup command
$backup_cmd

# Log completion
echo "\$(date '+%Y-%m-%d %H:%M:%S') - Scheduled backup completed"
EOF

    chmod +x /run-scripts/backup-cron.sh
}

# Create the backup script
create_backup_script

# Configure timezone for the system
if [[ -n "${TZ}" ]]; then
    echo -e "${YELLOW}Setting system timezone to: ${TZ}${NC}"
    ln -snf /usr/share/zoneinfo/"${TZ}" /etc/localtime
    echo "${TZ}" > /etc/timezone
    # Set timezone for cron daemon
    echo "TZ=${TZ}" >> /etc/environment
fi

# Set up cron job with timezone
CRON_STRINGS="${DB_DUMP_CRON:-0 0 * * *} /run-scripts/backup-cron.sh >> /var/log/cron/cron.log 2>&1"

# Create crontab for root user with timezone setting
{
    if [[ -n "${TZ}" ]]; then
        echo "TZ=${TZ}"
    fi
    echo "$CRON_STRINGS"
} | crontab -

# Ensure cron service is configured and restart to pick up timezone changes
service cron stop 2>/dev/null || true
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
    /run-scripts/backup-cron.sh >> /var/log/cron/cron.log 2>&1 &
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
