#!/bin/bash

#===============================================================================
# AList File Upload Script
#===============================================================================
# Description: A comprehensive shell script for uploading files to AList via API
# Author: funnyzak
# Version: 1.1.0
# Repository: https://github.com/funnyzak/dotfiles
# Dependencies: curl, jq (optional for better JSON parsing)
#
# Features:
# - API authentication with token caching (24h validity)
# - Command line parameter support
# - Environment variable configuration
# - Automatic token refresh on 401 errors
# - Multiple file upload support
# - Option to disable token caching
# - File upload with custom remote paths
# - Comprehensive error handling and logging
#
# Usage Examples:
#   # Basic usage - single file
#   ./alist_upload.sh file1.txt
#
#   # Upload multiple files
#   ./alist_upload.sh file1.txt file2.pdf ./path/file3.jpg
#
#   # Specify remote path
#   ./alist_upload.sh -r /documents file1.txt file2.pdf
#
#   # Disable token caching
#   ./alist_upload.sh --no-cache file1.txt
#
#   # Specify full parameters
#   ./alist_upload.sh -a https://api.example.com -u username -p password -r /backup file1.txt
#
#   # Using environment variables
#   export ALIST_API_URL="https://api.example.com"
#   export ALIST_USERNAME="myuser"
#   export ALIST_PASSWORD="mypass"
#   ./alist_upload.sh file1.txt file2.pdf
#
# Remote Execution Examples:
#   # Direct remote execution - single file
#   curl -fsSL https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh | bash -s -- file1.txt
#
#   # Direct remote execution - multiple files
#   curl -fsSL https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh | bash -s -- file1.txt file2.pdf
#
#   # Download and execute
#   curl -fsSL -o alist_upload.sh https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh
#   chmod +x alist_upload.sh
#   ./alist_upload.sh file1.txt file2.pdf
#
# Environment Variables:
#   ALIST_API_URL     - API base URL (e.g., http://prod-cn.your-api-server.com)
#   ALIST_USERNAME    - Username for authentication
#   ALIST_PASSWORD    - Password for authentication
#   ALIST_TOKEN       - Pre-existing token (optional)
#
# Command Line Parameters:
#   -a, --api-url     API base URL
#   -u, --username    Username for authentication
#   -p, --password    Password for authentication
#   -t, --token       Pre-existing token
#   -r, --remote-path Remote upload path (default: /)
#   --no-cache        Disable token caching (login for each upload)
#   -v, --verbose     Enable verbose output
#   -h, --help        Show this help message
#
#===============================================================================

# Enable strict mode for better error handling
set -euo pipefail

# Script metadata
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.1.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default configuration
readonly DEFAULT_REMOTE_PATH="/"
readonly TOKEN_CACHE_DIR="${HOME}/.cache/alist"
readonly TOKEN_CACHE_FILE="${TOKEN_CACHE_DIR}/token"
readonly TOKEN_VALIDITY_HOURS=24

# Global variables
API_URL=""
USERNAME=""
PASSWORD=""
TOKEN=""
REMOTE_PATH="${DEFAULT_REMOTE_PATH}"
UPLOAD_FILES=()
VERBOSE=false
NO_CACHE=false

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

#===============================================================================
# Utility Functions
#===============================================================================

# Print colored output
print_color() {
    local color="$1"
    local message="$2"
    printf "${color}%s${NC}\n" "$message"
}

# Logging functions
log_info() {
    print_color "$BLUE" "[INFO] $1"
}

log_success() {
    print_color "$GREEN" "[SUCCESS] $1"
}

log_warning() {
    print_color "$YELLOW" "[WARNING] $1"
}

log_error() {
    print_color "$RED" "[ERROR] $1" >&2
}

log_verbose() {
    if [[ "$VERBOSE" == true ]]; then
        print_color "$BLUE" "[VERBOSE] $1"
    fi
}

# Exit with error message
die() {
    log_error "$1"
    exit 1
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate required dependencies
check_dependencies() {
    local missing_deps=()

    if ! command_exists curl; then
        missing_deps+=("curl")
    fi

    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        die "Missing required dependencies: ${missing_deps[*]}"
    fi

    log_verbose "All dependencies are available"
}

#===============================================================================
# Configuration Management
#===============================================================================

# Load configuration from environment variables
load_env_config() {
    API_URL="${ALIST_API_URL:-}"
    USERNAME="${ALIST_USERNAME:-}"
    PASSWORD="${ALIST_PASSWORD:-}"
    TOKEN="${ALIST_TOKEN:-}"

    log_verbose "Loaded configuration from environment variables"
}

# Show help message
show_help() {
    cat << EOF
${SCRIPT_NAME} v${SCRIPT_VERSION} - AList File Upload Script

DESCRIPTION:
    Upload files to AList storage via API with automatic authentication
    and token caching for improved performance.

USAGE:
    ${SCRIPT_NAME} [OPTIONS] <file_path> [file_path2] [file_path3] ...

OPTIONS:
    -a, --api-url URL       API base URL (e.g., http://prod-cn.your-api-server.com)
    -u, --username USER     Username for authentication
    -p, --password PASS     Password for authentication
    -t, --token TOKEN       Pre-existing authentication token
    -r, --remote-path PATH  Remote upload path (default: /)
    --no-cache              Disable token caching (login for each upload)
    -v, --verbose           Enable verbose output
    -h, --help              Show this help message

ENVIRONMENT VARIABLES:
    ALIST_API_URL          API base URL
    ALIST_USERNAME         Username for authentication
    ALIST_PASSWORD         Password for authentication
    ALIST_TOKEN            Pre-existing token

EXAMPLES:
    # Basic upload to root directory - single file
    ${SCRIPT_NAME} document.pdf

    # Upload multiple files to root directory
    ${SCRIPT_NAME} document.pdf image.jpg archive.zip

    # Upload to specific remote directory
    ${SCRIPT_NAME} -r /documents document.pdf image.jpg

    # Upload with disabled token caching
    ${SCRIPT_NAME} --no-cache document.pdf

    # Upload with custom API endpoint
    ${SCRIPT_NAME} -a https://my-alist.com -u myuser -p mypass document.pdf

    # Using environment variables
    export ALIST_API_URL="https://my-alist.com"
    export ALIST_USERNAME="myuser"
    export ALIST_PASSWORD="mypass"
    ${SCRIPT_NAME} document.pdf image.jpg

REMOTE EXECUTION:
    # Direct execution from repository - single file
    curl -fsSL https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh | bash -s -- document.pdf

    # Direct execution from repository - multiple files
    curl -fsSL https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh | bash -s -- document.pdf image.jpg

    # Download and execute
    curl -fsSL -o alist_upload.sh https://gitee.com/funnyzak/dotfiles/raw/main/utilities/shell/alist/alist_upload.sh
    chmod +x alist_upload.sh
    ./alist_upload.sh document.pdf image.jpg

EOF
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -a|--api-url)
                API_URL="$2"
                shift 2
                ;;
            -u|--username)
                USERNAME="$2"
                shift 2
                ;;
            -p|--password)
                PASSWORD="$2"
                shift 2
                ;;
            -t|--token)
                TOKEN="$2"
                shift 2
                ;;
            -r|--remote-path)
                REMOTE_PATH="$2"
                shift 2
                ;;
            --no-cache)
                NO_CACHE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                die "Unknown option: $1. Use -h for help."
                ;;
            *)
                UPLOAD_FILES+=("$1")
                shift
                ;;
        esac
    done
}

# Validate configuration
validate_config() {
    # Check if files are specified
    if [[ ${#UPLOAD_FILES[@]} -eq 0 ]]; then
        die "No files specified for upload. Use -h for help."
    fi

    # Check if files exist and are readable
    for file in "${UPLOAD_FILES[@]}"; do
        if [[ ! -f "$file" ]]; then
            die "File not found: $file"
        fi
        if [[ ! -r "$file" ]]; then
            die "File is not readable: $file"
        fi
    done

    # Check required parameters (if token is not provided)
    if [[ -z "$TOKEN" ]]; then
        if [[ -z "$API_URL" ]]; then
            die "API URL is required. Set via -a option or ALIST_API_URL environment variable."
        fi

        if [[ -z "$USERNAME" ]]; then
            die "Username is required. Set via -u option or ALIST_USERNAME environment variable."
        fi

        if [[ -z "$PASSWORD" ]]; then
            die "Password is required. Set via -p option or ALIST_PASSWORD environment variable."
        fi
    fi

    # Normalize remote path
    if [[ ! "$REMOTE_PATH" =~ ^/ ]]; then
        REMOTE_PATH="/$REMOTE_PATH"
    fi

    # Remove trailing slash except for root
    if [[ "$REMOTE_PATH" != "/" && "$REMOTE_PATH" =~ /$ ]]; then
        REMOTE_PATH="${REMOTE_PATH%/}"
    fi

    log_verbose "Configuration validation completed"
}

#===============================================================================
# Token Management
#===============================================================================

# Create cache directory if it doesn't exist
ensure_cache_dir() {
    if [[ ! -d "$TOKEN_CACHE_DIR" ]]; then
        mkdir -p "$TOKEN_CACHE_DIR"
        log_verbose "Created cache directory: $TOKEN_CACHE_DIR"
    fi
}

# Get current timestamp
get_timestamp() {
    date +%s
}

# Check if token is valid (not expired)
is_token_valid() {
    local token_file="$1"

    if [[ ! -f "$token_file" ]]; then
        return 1
    fi

    local current_time
    current_time=$(get_timestamp)

    local token_data
    if ! token_data=$(cat "$token_file" 2>/dev/null); then
        return 1
    fi

    local cached_token
    local expiry_time

    # Parse token file (format: token:expiry_timestamp)
    if [[ "$token_data" =~ ^([^:]+):([0-9]+)$ ]]; then
        cached_token="${BASH_REMATCH[1]}"
        expiry_time="${BASH_REMATCH[2]}"
    else
        log_verbose "Invalid token cache format"
        return 1
    fi

    if [[ "$current_time" -lt "$expiry_time" ]]; then
        TOKEN="$cached_token"
        log_verbose "Using cached token (expires in $(( (expiry_time - current_time) / 3600 )) hours)"
        return 0
    else
        log_verbose "Cached token has expired"
        return 1
    fi
}

# Save token to cache
save_token_cache() {
    local token="$1"
    local current_time
    current_time=$(get_timestamp)
    local expiry_time=$((current_time + TOKEN_VALIDITY_HOURS * 3600))

    ensure_cache_dir

    echo "${token}:${expiry_time}" > "$TOKEN_CACHE_FILE"
    chmod 600 "$TOKEN_CACHE_FILE"

    log_verbose "Token cached until $(date -d "@$expiry_time" 2>/dev/null || date -r "$expiry_time" 2>/dev/null || echo "timestamp: $expiry_time")"
}

# Clear token cache
clear_token_cache() {
    if [[ -f "$TOKEN_CACHE_FILE" ]]; then
        rm -f "$TOKEN_CACHE_FILE"
        log_verbose "Token cache cleared"
    fi
}

#===============================================================================
# API Functions
#===============================================================================

# Perform login and get authentication token
login_and_get_token() {
    log_info "Authenticating with AList API..."

    local login_url="${API_URL}/api/auth/login"
    local login_data
    login_data=$(cat << EOF
{
    "username": "$USERNAME",
    "password": "$PASSWORD"
}
EOF
)

    log_verbose "Sending login request to: $login_url"

    local response
    local http_code

    # Perform login request
    if ! response=$(curl -s -w "\n%{http_code}" \
        --location \
        --request POST "$login_url" \
        --header 'Content-Type: application/json' \
        --data-raw "$login_data" 2>/dev/null); then
        die "Failed to connect to AList API. Please check your network connection and API URL."
    fi

    # Extract HTTP status code and response body
    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')

    log_verbose "HTTP Status Code: $http_code"
    log_verbose "Response: $response"

    # Check HTTP status
    if [[ "$http_code" != "200" ]]; then
        die "Login failed with HTTP status $http_code. Please check your credentials and API URL."
    fi

    # Parse JSON response
    local token
    if command_exists jq; then
        # Use jq for robust JSON parsing if available
        local code
        code=$(echo "$response" | jq -r '.code // empty' 2>/dev/null)

        if [[ "$code" != "200" ]]; then
            local message
            message=$(echo "$response" | jq -r '.message // "Unknown error"' 2>/dev/null)
            die "Login failed: $message"
        fi

        token=$(echo "$response" | jq -r '.data.token // empty' 2>/dev/null)
    else
        # Fallback to basic pattern matching
        if [[ "$response" =~ \"code\":200 ]]; then
            if [[ "$response" =~ \"token\":\"([^\"]+)\" ]]; then
                token="${BASH_REMATCH[1]}"
            fi
        else
            die "Login failed. Please check your credentials."
        fi
    fi

    if [[ -z "$token" ]]; then
        die "Failed to extract token from login response"
    fi

    TOKEN="$token"

    # Only save token to cache if caching is enabled
    if [[ "$NO_CACHE" != true ]]; then
        save_token_cache "$token"
    fi

    log_success "Authentication successful"
}

# Get valid authentication token
get_auth_token() {
    # If token is provided via parameter or environment, use it
    if [[ -n "$TOKEN" ]]; then
        log_verbose "Using provided token"
        return 0
    fi

    # If no-cache is enabled, always login
    if [[ "$NO_CACHE" == true ]]; then
        log_verbose "Token caching disabled, performing fresh login"
        login_and_get_token
        return 0
    fi

    # Try to use cached token
    if is_token_valid "$TOKEN_CACHE_FILE"; then
        log_verbose "Using cached token"
        return 0
    fi

    # Clear expired cache and login
    clear_token_cache
    login_and_get_token
}

# Upload file to AList
upload_file() {
    local file_path="$1"
    local remote_path="$2"

    # Get file basename
    local filename
    filename=$(basename "$file_path")

    # Construct File-Path header (remote_path + filename)
    local file_path_header
    if [[ "$remote_path" == "/" ]]; then
        file_path_header="/$filename"
    else
        file_path_header="$remote_path/$filename"
    fi

    local upload_url="${API_URL}/api/fs/form"

    log_info "Uploading file: $filename"
    log_info "Remote path: $file_path_header"

    log_verbose "Upload URL: $upload_url"
    log_verbose "Local file: $file_path"

    local response
    local http_code

    # Perform upload request
    if ! response=$(curl -s -w "\n%{http_code}" \
        -X PUT "$upload_url" \
        -H "Authorization: $TOKEN" \
        -H "File-Path: $file_path_header" \
        -H "As-Task: true" \
        -F "file=@$file_path" 2>/dev/null); then
        log_error "Failed to upload file. Please check your network connection."
        return 1
    fi

    # Extract HTTP status code and response body
    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')

    log_verbose "HTTP Status Code: $http_code"
    log_verbose "Response: $response"

    # Check HTTP status and JSON response code
    local needs_retry=false
    local json_code=""

    # Parse JSON response code first
    if command_exists jq; then
        json_code=$(echo "$response" | jq -r '.code // empty' 2>/dev/null)
    else
        # Fallback to basic pattern matching for JSON code
        if [[ "$response" =~ \"code\":([0-9]+) ]]; then
            json_code="${BASH_REMATCH[1]}"
        fi
    fi

    # Check for authentication errors (HTTP 401 or JSON code 401)
    if [[ "$http_code" == "401" ]] || [[ "$json_code" == "401" ]]; then
        needs_retry=true
        log_warning "Authentication failed (HTTP: $http_code, JSON code: $json_code), refreshing token..."
    elif [[ "$http_code" != "200" ]]; then
        log_error "Upload failed with HTTP status $http_code."
        return 1
    elif [[ -n "$json_code" && "$json_code" != "200" ]]; then
        local message=""
        if command_exists jq; then
            message=$(echo "$response" | jq -r '.message // "Unknown error"' 2>/dev/null)
        else
            # Try to extract message with basic pattern matching
            if [[ "$response" =~ \"message\":\"([^\"]+)\" ]]; then
                message="${BASH_REMATCH[1]}"
            else
                message="Unknown error"
            fi
        fi
        log_error "Upload failed with JSON code $json_code: $message"
        return 1
    fi

    # Retry upload if authentication failed
    if [[ "$needs_retry" == true ]]; then
        clear_token_cache
        login_and_get_token

                # Retry upload with new token
        log_info "Retrying upload with refreshed token..."
        if ! response=$(curl -s -w "\n%{http_code}" \
            -X PUT "$upload_url" \
            -H "Authorization: $TOKEN" \
            -H "File-Path: $file_path_header" \
            -H "As-Task: true" \
            -F "file=@$file_path" 2>/dev/null); then
            log_error "Failed to upload file after token refresh."
            return 1
        fi

        http_code=$(echo "$response" | tail -n1)
        response=$(echo "$response" | sed '$d')

        # Check retry response
        if [[ "$http_code" != "200" ]]; then
            log_error "Upload failed with HTTP status $http_code after token refresh."
            return 1
        fi

        # Check JSON code in retry response
        if command_exists jq; then
            json_code=$(echo "$response" | jq -r '.code // empty' 2>/dev/null)
            if [[ "$json_code" != "200" ]]; then
                local message
                message=$(echo "$response" | jq -r '.message // "Unknown error"' 2>/dev/null)
                log_error "Upload failed after retry with JSON code $json_code: $message"
                return 1
            fi
        else
            if [[ "$response" =~ \"code\":([0-9]+) ]]; then
                json_code="${BASH_REMATCH[1]}"
                if [[ "$json_code" != "200" ]]; then
                    log_error "Upload failed after retry with JSON code $json_code"
                    return 1
                fi
            fi
        fi
    fi

    # Parse successful upload response
    if command_exists jq; then
        local task_id
        task_id=$(echo "$response" | jq -r '.data.task.id // empty' 2>/dev/null)

        if [[ -n "$task_id" ]]; then
            log_success "Upload initiated successfully (Task ID: $task_id)"
        else
            log_success "Upload completed successfully"
        fi
    else
        log_success "Upload completed successfully"
    fi

    log_success "File uploaded: $filename → $file_path_header"
}

#===============================================================================
# Main Function
#===============================================================================

main() {
    # Check dependencies
    check_dependencies

    # Load environment configuration
    load_env_config

    # Parse command line arguments
    parse_arguments "$@"

    # Validate configuration
    validate_config

    # Get authentication token
    get_auth_token

    # Upload all files
    local total_files=${#UPLOAD_FILES[@]}
    local current_file=0
    local failed_files=()
    local successful_files=()

    log_info "Starting upload of $total_files file(s)..."

    for file in "${UPLOAD_FILES[@]}"; do
        current_file=$((current_file + 1))
        log_info "Processing file $current_file/$total_files: $(basename "$file")"

        # Convert relative path to absolute path
        local abs_file_path
        abs_file_path=$(realpath "$file")

        # Upload file with error handling
        if upload_file "$abs_file_path" "$REMOTE_PATH"; then
            successful_files+=("$file")
        else
            failed_files+=("$file")
            log_error "Failed to upload: $file"
        fi

        # Add a small delay between uploads to avoid overwhelming the server
        if [[ $current_file -lt $total_files ]]; then
            sleep 0.5
        fi
    done

    # Report final results
    echo ""
    log_info "Upload Summary:"
    log_success "Successfully uploaded: ${#successful_files[@]} file(s)"

    if [[ ${#failed_files[@]} -gt 0 ]]; then
        log_error "Failed to upload: ${#failed_files[@]} file(s)"
        for failed_file in "${failed_files[@]}"; do
            log_error "  - $failed_file"
        done
        exit 1
    else
        log_success "All files uploaded successfully!"
    fi
}

#===============================================================================
# Script Entry Point
#===============================================================================

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
