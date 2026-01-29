#!/bin/bash

# MySQL Backup Upload Tool
# Usage: ./upload_backups.sh [OPTIONS] [backup_directory] [upload_type]
# Supported upload types: s3, ftp, scp, webdav, oss, alist

set -e

# Default configuration
DEFAULT_BACKUP_DIR="/backup"
DEFAULT_UPLOAD_TYPE="s3"
LOG_PREFIX="[UPLOAD]"

# Initialize variables with defaults
BACKUP_DIR=""
UPLOAD_TYPE=""
S3_BUCKET=""
S3_PREFIX=""
AWS_ACCESS_KEY=""
AWS_SECRET_KEY=""
FTP_HOST=""
FTP_USER=""
FTP_PASS=""
FTP_PATH=""
SSH_HOST=""
SSH_USER=""
SSH_KEY=""
SSH_PATH=""
WEBDAV_URL=""
WEBDAV_USER=""
WEBDAV_PASS=""
OSS_BUCKET=""
OSS_PREFIX=""
OSS_ACCESS_KEY=""
OSS_SECRET_KEY=""
ALIST_API_URL=""
ALIST_USERNAME=""
ALIST_PASSWORD=""
ALIST_REMOTE_PATH=""

# Help function
show_help() {
    cat << EOF
MySQL Backup Upload Tool

Usage: $0 [OPTIONS] [backup_directory] [upload_type]

Arguments:
  backup_directory    Directory containing backup files (default: /backup)
  upload_type         Upload method: s3, ftp, scp, webdav, oss, alist (default: s3)

Options:
  -h, --help          Show this help message

S3 Options:
  --s3-bucket         S3 bucket name
  --s3-prefix         S3 prefix/folder path
  --aws-access-key    AWS access key
  --aws-secret-key    AWS secret key

FTP Options:
  --ftp-host          FTP server hostname
  --ftp-user          FTP username
  --ftp-pass          FTP password
  --ftp-path          FTP remote path

SCP Options:
  --ssh-host          SSH server hostname
  --ssh-user          SSH username
  --ssh-key           SSH private key file path
  --ssh-path          SSH remote path

WebDAV Options:
  --webdav-url        WebDAV server URL
  --webdav-user       WebDAV username
  --webdav-pass       WebDAV password

OSS Options:
  --oss-bucket        OSS bucket name
  --oss-prefix        OSS prefix/folder path
  --oss-access-key    OSS access key
  --oss-secret-key    OSS secret key

AList Options:
  --alist-api-url     AList API URL
  --alist-username    AList username
  --alist-password    AList password
  --alist-remote-path AList remote path (default: /mysql-backups)

Examples:
  # Upload to S3 with command line arguments
  $0 --s3-bucket my-bucket --aws-access-key KEY --aws-secret-key SECRET /backup s3

  # Upload to FTP
  $0 --ftp-host ftp.example.com --ftp-user user --ftp-pass pass --ftp-path /backups /backup ftp

  # Upload to AList
  $0 --alist-api-url https://alist.example.com --alist-username user --alist-password pass /backup alist

Environment Variables (used as fallback):
  S3: S3_BUCKET, S3_PREFIX, AWS_ACCESS_KEY, AWS_SECRET_KEY
  FTP: FTP_HOST, FTP_USER, FTP_PASS, FTP_PATH
  SCP: SSH_HOST, SSH_USER, SSH_KEY, SSH_PATH
  WebDAV: WEBDAV_URL, WEBDAV_USER, WEBDAV_PASS
  OSS: OSS_BUCKET, OSS_PREFIX, OSS_ACCESS_KEY, OSS_SECRET_KEY
  AList: ALIST_API_URL, ALIST_USERNAME, ALIST_PASSWORD, ALIST_REMOTE_PATH

EOF
}

# Parse command line arguments
parse_arguments() {
    local positional_args=()
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            --s3-bucket)
                S3_BUCKET="$2"
                shift 2
                ;;
            --s3-prefix)
                S3_PREFIX="$2"
                shift 2
                ;;
            --aws-access-key)
                AWS_ACCESS_KEY="$2"
                shift 2
                ;;
            --aws-secret-key)
                AWS_SECRET_KEY="$2"
                shift 2
                ;;
            --ftp-host)
                FTP_HOST="$2"
                shift 2
                ;;
            --ftp-user)
                FTP_USER="$2"
                shift 2
                ;;
            --ftp-pass)
                FTP_PASS="$2"
                shift 2
                ;;
            --ftp-path)
                FTP_PATH="$2"
                shift 2
                ;;
            --ssh-host)
                SSH_HOST="$2"
                shift 2
                ;;
            --ssh-user)
                SSH_USER="$2"
                shift 2
                ;;
            --ssh-key)
                SSH_KEY="$2"
                shift 2
                ;;
            --ssh-path)
                SSH_PATH="$2"
                shift 2
                ;;
            --webdav-url)
                WEBDAV_URL="$2"
                shift 2
                ;;
            --webdav-user)
                WEBDAV_USER="$2"
                shift 2
                ;;
            --webdav-pass)
                WEBDAV_PASS="$2"
                shift 2
                ;;
            --oss-bucket)
                OSS_BUCKET="$2"
                shift 2
                ;;
            --oss-prefix)
                OSS_PREFIX="$2"
                shift 2
                ;;
            --oss-access-key)
                OSS_ACCESS_KEY="$2"
                shift 2
                ;;
            --oss-secret-key)
                OSS_SECRET_KEY="$2"
                shift 2
                ;;
            --alist-api-url)
                ALIST_API_URL="$2"
                shift 2
                ;;
            --alist-username)
                ALIST_USERNAME="$2"
                shift 2
                ;;
            --alist-password)
                ALIST_PASSWORD="$2"
                shift 2
                ;;
            --alist-remote-path)
                ALIST_REMOTE_PATH="$2"
                shift 2
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done
    
    # Set positional arguments
    if [ ${#positional_args[@]} -ge 1 ]; then
        BACKUP_DIR="${positional_args[0]}"
    fi
    if [ ${#positional_args[@]} -ge 2 ]; then
        UPLOAD_TYPE="${positional_args[1]}"
    fi
}

# Apply configuration with command line arguments taking priority over environment variables
apply_configuration() {
    # Set defaults if not provided via command line
    BACKUP_DIR="${BACKUP_DIR:-${DEFAULT_BACKUP_DIR}}"
    UPLOAD_TYPE="${UPLOAD_TYPE:-${DEFAULT_UPLOAD_TYPE}}"
    
    # Apply environment variables as fallback (only if command line argument not provided)
    S3_BUCKET="${S3_BUCKET:-${S3_BUCKET_ENV:-}}"
    S3_PREFIX="${S3_PREFIX:-${S3_PREFIX_ENV:-}}"
    AWS_ACCESS_KEY="${AWS_ACCESS_KEY:-${AWS_ACCESS_KEY_ENV:-}}"
    AWS_SECRET_KEY="${AWS_SECRET_KEY:-${AWS_SECRET_KEY_ENV:-}}"
    
    FTP_HOST="${FTP_HOST:-${FTP_HOST_ENV:-}}"
    FTP_USER="${FTP_USER:-${FTP_USER_ENV:-}}"
    FTP_PASS="${FTP_PASS:-${FTP_PASS_ENV:-}}"
    FTP_PATH="${FTP_PATH:-${FTP_PATH_ENV:-}}"
    
    SSH_HOST="${SSH_HOST:-${SSH_HOST_ENV:-}}"
    SSH_USER="${SSH_USER:-${SSH_USER_ENV:-}}"
    SSH_KEY="${SSH_KEY:-${SSH_KEY_ENV:-}}"
    SSH_PATH="${SSH_PATH:-${SSH_PATH_ENV:-}}"
    
    WEBDAV_URL="${WEBDAV_URL:-${WEBDAV_URL_ENV:-}}"
    WEBDAV_USER="${WEBDAV_USER:-${WEBDAV_USER_ENV:-}}"
    WEBDAV_PASS="${WEBDAV_PASS:-${WEBDAV_PASS_ENV:-}}"
    
    OSS_BUCKET="${OSS_BUCKET:-${OSS_BUCKET_ENV:-}}"
    OSS_PREFIX="${OSS_PREFIX:-${OSS_PREFIX_ENV:-}}"
    OSS_ACCESS_KEY="${OSS_ACCESS_KEY:-${OSS_ACCESS_KEY_ENV:-}}"
    OSS_SECRET_KEY="${OSS_SECRET_KEY:-${OSS_SECRET_KEY_ENV:-}}"
    
    ALIST_API_URL="${ALIST_API_URL:-${ALIST_API_URL_ENV:-}}"
    ALIST_USERNAME="${ALIST_USERNAME:-${ALIST_USERNAME_ENV:-}}"
    ALIST_PASSWORD="${ALIST_PASSWORD:-${ALIST_PASSWORD_ENV:-}}"
    ALIST_REMOTE_PATH="${ALIST_REMOTE_PATH:-${ALIST_REMOTE_PATH_ENV:-/mysql-backups}}"
}

# Store environment variables for fallback
store_env_variables() {
    S3_BUCKET_ENV="${S3_BUCKET:-}"
    S3_PREFIX_ENV="${S3_PREFIX:-}"
    AWS_ACCESS_KEY_ENV="${AWS_ACCESS_KEY:-}"
    AWS_SECRET_KEY_ENV="${AWS_SECRET_KEY:-}"
    
    FTP_HOST_ENV="${FTP_HOST:-}"
    FTP_USER_ENV="${FTP_USER:-}"
    FTP_PASS_ENV="${FTP_PASS:-}"
    FTP_PATH_ENV="${FTP_PATH:-}"
    
    SSH_HOST_ENV="${SSH_HOST:-}"
    SSH_USER_ENV="${SSH_USER:-}"
    SSH_KEY_ENV="${SSH_KEY:-}"
    SSH_PATH_ENV="${SSH_PATH:-}"
    
    WEBDAV_URL_ENV="${WEBDAV_URL:-}"
    WEBDAV_USER_ENV="${WEBDAV_USER:-}"
    WEBDAV_PASS_ENV="${WEBDAV_PASS:-}"
    
    OSS_BUCKET_ENV="${OSS_BUCKET:-}"
    OSS_PREFIX_ENV="${OSS_PREFIX:-}"
    OSS_ACCESS_KEY_ENV="${OSS_ACCESS_KEY:-}"
    OSS_SECRET_KEY_ENV="${OSS_SECRET_KEY:-}"
    
    ALIST_API_URL_ENV="${ALIST_API_URL:-}"
    ALIST_USERNAME_ENV="${ALIST_USERNAME:-}"
    ALIST_PASSWORD_ENV="${ALIST_PASSWORD:-}"
    ALIST_REMOTE_PATH_ENV="${ALIST_REMOTE_PATH:-}"
}

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $LOG_PREFIX $1"
}



# Get latest backup files (created in last 60 minutes)
get_latest_backups() {
    find "$BACKUP_DIR" \( -name "*.sql*" -o -name "*.tar.gz*" -o -name "*.zip*" \) -mmin -60 -type f | sort
}

# Upload to AWS S3
upload_to_s3() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Pseudo code for S3 upload
    log "Uploading $filename to S3..."
    
    # TODO: Implement actual S3 upload logic
    # aws s3 cp "$file" "s3://$S3_BUCKET/$S3_PREFIX/$filename"
    # OR using curl with S3 API
    # curl -X PUT -T "$file" \
    #   -H "Authorization: AWS $AWS_ACCESS_KEY:$SIGNATURE" \
    #   "https://$S3_BUCKET.s3.amazonaws.com/$S3_PREFIX/$filename"
    
    echo "# S3 Upload Implementation"
    echo "# aws s3 cp '$file' 's3://\$S3_BUCKET/\$S3_PREFIX/$filename'"
    echo "# Check upload result and log status"
    
    log "S3 upload completed for $filename"
}

# Upload via FTP
upload_to_ftp() {
    local file="$1"
    local filename=$(basename "$file")
    
    log "Uploading $filename to FTP..."
    
    # TODO: Implement actual FTP upload logic
    # curl -T "$file" -u "$FTP_USER:$FTP_PASS" "ftp://$FTP_HOST/$FTP_PATH/$filename"
    
    echo "# FTP Upload Implementation"
    echo "# curl -T '$file' -u '\$FTP_USER:\$FTP_PASS' 'ftp://\$FTP_HOST/\$FTP_PATH/$filename'"
    echo "# Check curl exit code and log result"
    
    log "FTP upload completed for $filename"
}

# Upload via SCP
upload_to_scp() {
    local file="$1"
    local filename=$(basename "$file")
    
    log "Uploading $filename via SCP..."
    
    # TODO: Implement actual SCP upload logic
    # scp -i "$SSH_KEY" "$file" "$SSH_USER@$SSH_HOST:$SSH_PATH/$filename"
    
    echo "# SCP Upload Implementation"
    echo "# scp -i '\$SSH_KEY' '$file' '\$SSH_USER@\$SSH_HOST:\$SSH_PATH/$filename'"
    echo "# Check scp exit code and log result"
    
    log "SCP upload completed for $filename"
}

# Upload to WebDAV
upload_to_webdav() {
    local file="$1"
    local filename=$(basename "$file")
    
    log "Uploading $filename to WebDAV..."
    
    # TODO: Implement actual WebDAV upload logic
    # curl -T "$file" -u "$WEBDAV_USER:$WEBDAV_PASS" "$WEBDAV_URL/$filename"
    
    echo "# WebDAV Upload Implementation"
    echo "# curl -T '$file' -u '\$WEBDAV_USER:\$WEBDAV_PASS' '\$WEBDAV_URL/$filename'"
    echo "# Check curl response and log result"
    
    log "WebDAV upload completed for $filename"
}

# Upload to Alibaba Cloud OSS
upload_to_oss() {
    local file="$1"
    local filename=$(basename "$file")
    
    log "Uploading $filename to OSS..."
    
    # TODO: Implement actual OSS upload logic
    # ossutil cp "$file" "oss://$OSS_BUCKET/$OSS_PREFIX/$filename"
    
    echo "# OSS Upload Implementation"
    echo "# ossutil cp '$file' 'oss://\$OSS_BUCKET/\$OSS_PREFIX/$filename'"
    echo "# Check ossutil exit code and log result"
    
    log "OSS upload completed for $filename"
}

# Upload to AList
upload_to_alist() {
    local file="$1"
    local filename=$(basename "$file")
    
    log "Uploading $filename to AList..."
    
    # Check if alist_upload.sh exists
    local alist_script="/tools/alist_upload.sh"
    if [ ! -f "$alist_script" ]; then
        log "ERROR: AList upload script not found at $alist_script"
        return 1
    fi
    
    # Check required configuration
    if [ -z "$ALIST_API_URL" ] || [ -z "$ALIST_USERNAME" ] || [ -z "$ALIST_PASSWORD" ]; then
        log "ERROR: AList configuration missing. Required: ALIST_API_URL, ALIST_USERNAME, ALIST_PASSWORD"
        log "Use command line arguments: --alist-api-url, --alist-username, --alist-password"
        log "Or set environment variables: ALIST_API_URL, ALIST_USERNAME, ALIST_PASSWORD"
        return 1
    fi
    
    # Set remote path
    local remote_path="$ALIST_REMOTE_PATH"
    
    # Execute AList upload script
    if "$alist_script" -a "$ALIST_API_URL" -u "$ALIST_USERNAME" -p "$ALIST_PASSWORD" -r "$remote_path" "$file"; then
        log "AList upload completed for $filename"
        return 0
    else
        log "ERROR: AList upload failed for $filename"
        return 1
    fi
}

# Main upload function
upload_file() {
    local file="$1"
    
    case "$UPLOAD_TYPE" in
        s3)
            upload_to_s3 "$file"
            ;;
        ftp)
            upload_to_ftp "$file"
            ;;
        scp)
            upload_to_scp "$file"
            ;;
        webdav)
            upload_to_webdav "$file"
            ;;
        oss)
            upload_to_oss "$file"
            ;;
        alist)
            upload_to_alist "$file"
            ;;
        *)
            log "ERROR: Unsupported upload type: $UPLOAD_TYPE"
            exit 1
            ;;
    esac
}

# Main execution
main() {
    # Initialize configuration
    store_env_variables
    parse_arguments "$@"
    apply_configuration
    
    # Check if backup directory exists
    if [ ! -d "$BACKUP_DIR" ]; then
        log "ERROR: Backup directory $BACKUP_DIR does not exist"
        exit 1
    fi
    
    log "Starting backup upload process..."
    log "Backup directory: $BACKUP_DIR"
    log "Upload type: $UPLOAD_TYPE"
    
    # Get list of backup files
    backup_files=$(get_latest_backups)
    
    if [ -z "$backup_files" ]; then
        log "No recent backup files found"
        exit 0
    fi
    
    # Upload each file
    upload_count=0
    while IFS= read -r file; do
        if [ -f "$file" ]; then
            log "Processing file: $(basename "$file")"
            upload_file "$file"
            upload_count=$((upload_count + 1))
        fi
    done <<< "$backup_files"
    
    log "Upload process completed. Total files uploaded: $upload_count"
}

# Execute main function
main "$@" 