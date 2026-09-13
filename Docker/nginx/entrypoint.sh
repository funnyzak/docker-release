#!/bin/sh

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

die() {
    printf '%bError: %s%b\n' "$RED" "$*" "$NC" >&2
    exit 1
}

directory_is_empty() {
    dir_path="$1"

    [ ! -d "$dir_path" ] && return 0
    [ -z "$(ls -A "$dir_path" 2>/dev/null)" ]
}

copy_dir_contents_if_present() {
    src_dir="$1"
    dest_dir="$2"

    if [ -d "$src_dir" ] && [ -n "$(ls -A "$src_dir" 2>/dev/null)" ]; then
        cp -r "$src_dir"/. "$dest_dir"/
    fi
}

configure_log_output() {
    log_path="$1"
    stream_path="$2"

    if [ -d "$log_path" ]; then
        echo "Error: $log_path is a directory; mount a file at this path or mount the parent log directory." >&2
        return 1
    fi

    if [ -L "$log_path" ]; then
        [ "$(readlink "$log_path")" = "$stream_path" ] || ln -sfn "$stream_path" "$log_path"
    elif [ ! -e "$log_path" ]; then
        ln -s "$stream_path" "$log_path"
    fi
}

# Values interpolated into the nginx configuration must not be able to
# terminate a directive or break out of quoting.
reject_config_metachars() {
    value="$1"
    name="$2"

    if printf '%s' "$value" | grep -qE '[;{}"'"'"']|[[:cntrl:]]'; then
        die "$name must not contain semicolons, braces, quotes or control characters (got '$value')."
    fi
}

validate_format() {
    value="$1"
    name="$2"
    pattern="$3"

    if ! printf '%s' "$value" | grep -qE "$pattern"; then
        die "$name has an invalid format (got '$value')."
    fi
}

validate_listen_port() {
    value="$1"

    case $value in
        ''|*[!0-9]*)
            die "NGINX_LISTEN_PORT must be a number between 1 and 65535 (got '$value')."
            ;;
    esac

    if [ "$value" -lt 1 ] || [ "$value" -gt 65535 ]; then
        die "NGINX_LISTEN_PORT must be a number between 1 and 65535 (got '$value')."
    fi
}

validate_template_variables() {
    validate_listen_port "$NGINX_LISTEN_PORT"
    validate_format "$NGINX_SERVER_NAME" NGINX_SERVER_NAME '^[A-Za-z0-9.*_-]+$'
    validate_format "$NGINX_WEB_ROOT" NGINX_WEB_ROOT '^[/A-Za-z0-9._-]+$'
    validate_format "$NGINX_INDEX_FILES" NGINX_INDEX_FILES '^[A-Za-z0-9._ -]+$'
    reject_config_metachars "$NGINX_SERVER_BUILD" NGINX_SERVER_BUILD
}

available_modules() {
    (cd /etc/nginx/modules-available 2>/dev/null && find . -maxdepth 1 -type f) \
        | sed -e 's|^\./10_||' -e 's/\.conf$//' | tr '\n' ' '
}

# NGINX_ENABLED_MODULES is a comma-separated list of module names as printed by
# available_modules (e.g. "stream,fancyindex"); the matching loader snippet is
# copied from /etc/nginx/modules-available into /etc/nginx/modules.
enable_optional_modules() {
    [ -z "${NGINX_ENABLED_MODULES:-}" ] && return 0

    if [ ! -w /etc/nginx/modules ]; then
        die "/etc/nginx/modules is not writable, cannot enable NGINX_ENABLED_MODULES modules."
    fi

    for module_name in $(printf '%s' "$NGINX_ENABLED_MODULES" | tr ',' ' '); do
        [ -n "$module_name" ] || continue

        case $module_name in
            *[!A-Za-z0-9_-]*)
                die "Invalid module name '$module_name' in NGINX_ENABLED_MODULES. Available: $(available_modules)"
                ;;
        esac

        matches=$(find /etc/nginx/modules-available -maxdepth 1 -name "*_${module_name}.conf" | sort)
        match_count=$(printf '%s\n' "$matches" | grep -c .)

        if [ "$match_count" -eq 0 ]; then
            die "Unknown module '$module_name' in NGINX_ENABLED_MODULES. Available: $(available_modules)"
        fi

        if [ "$match_count" -gt 1 ]; then
            die "Ambiguous module name '$module_name'. Use the full name, e.g. http_geoip or stream_geoip."
        fi

        cp "$matches" /etc/nginx/modules/
        printf '%b\n' "${GREEN}Enabled module: ${BLUE}${module_name}${NC}"
    done
}

render_default_template() {
    template_path=""
    template_vars=""

    if [ -f /etc/nginx/templates/default.conf.template ]; then
        template_path="/etc/nginx/templates/default.conf.template"
    elif [ -f /data/nginx/templates/default.conf.template ]; then
        template_path="/data/nginx/templates/default.conf.template"
    fi

    if [ -n "$template_path" ]; then
        export NGINX_LISTEN_PORT="${NGINX_LISTEN_PORT:-80}"
        export NGINX_SERVER_NAME="${NGINX_SERVER_NAME:-_}"
        export NGINX_WEB_ROOT="${NGINX_WEB_ROOT:-/etc/nginx/html}"
        export NGINX_INDEX_FILES="${NGINX_INDEX_FILES:-index.html index.htm}"
        export NGINX_SERVER_BUILD="${NGINX_SERVER_BUILD:-build via @funnyzak}"

        validate_template_variables

        template_vars="$(
            awk '
                {
                    line = $0
                    while (match(line, /\$\{[A-Za-z_][A-Za-z0-9_]*\}/)) {
                        print substr(line, RSTART, RLENGTH)
                        line = substr(line, RSTART + RLENGTH)
                    }
                }
            ' "$template_path" | sort -u | tr '\n' ' '
        )"

        if [ -n "$template_vars" ]; then
            envsubst "$template_vars" < "$template_path" > /etc/nginx/conf.d/default.conf
        else
            cp "$template_path" /etc/nginx/conf.d/default.conf
        fi
        return 0
    fi

    return 1
}

# A directory where a file is expected usually means Docker auto-created it
# from a wrong mount path.
if [ -d /etc/nginx/nginx.conf ]; then
    die "/etc/nginx/nginx.conf is a directory; mount a file at this path (or the parent directory) instead."
fi

if [ -e /etc/nginx/conf.d ] && [ ! -d /etc/nginx/conf.d ]; then
    die "/etc/nginx/conf.d must be a directory."
fi

[ -s /etc/nginx/nginx.conf ] || cp -f /data/nginx/nginx.conf /etc/nginx/nginx.conf

mkdir -p /etc/nginx/conf.d /etc/nginx/html

if directory_is_empty /etc/nginx/conf.d; then
    render_default_template || copy_dir_contents_if_present /data/nginx/conf.d /etc/nginx/conf.d
fi

if directory_is_empty /etc/nginx/html; then
    copy_dir_contents_if_present /data/nginx/html /etc/nginx/html
fi

enable_optional_modules

configure_log_output /var/log/nginx/access.log /dev/stdout
configure_log_output /var/log/nginx/error.log /dev/stderr

printf '%b\n' "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/nginx${NC}"
printf '%b\n\n' "${GREEN}GitHub: https://github.com/funnyzak/docker-release${NC}"

printf '%b\n' "${GREEN}$(nginx -v 2>&1)${NC}"
printf '\n%b\n' "${YELLOW}Optional modules (enable via NGINX_ENABLED_MODULES):${NC}"
printf '%b\n' "${BLUE}$(available_modules)${NC}"
printf '\n%b\n' "${YELLOW}nginx.conf configuration file path:${NC} ${RED}/etc/nginx/nginx.conf${NC}"
printf '%b\n' "${YELLOW}server configuration file path:${NC} ${RED}/etc/nginx/conf.d${NC}"
printf '%b\n' "${YELLOW}server template file path:${NC} ${RED}/etc/nginx/templates/default.conf.template${NC}"

nginx -t

exec "$@"
