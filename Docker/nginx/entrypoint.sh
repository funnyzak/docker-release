#!/bin/sh

set -eu

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
        export NGINX_WEB_ROOT="${NGINX_WEB_ROOT:-html}"
        export NGINX_INDEX_FILES="${NGINX_INDEX_FILES:-index.html index.htm}"
        export NGINX_SERVER_BUILD="${NGINX_SERVER_BUILD:-build via @funnyzak}"

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

[ -s /etc/nginx/nginx.conf ] || cp -f /data/nginx/nginx.conf /etc/nginx/nginx.conf

mkdir -p /etc/nginx/conf.d /etc/nginx/html

if directory_is_empty /etc/nginx/conf.d; then
    render_default_template || copy_dir_contents_if_present /data/nginx/conf.d /etc/nginx/conf.d
fi

if directory_is_empty /etc/nginx/html; then
    copy_dir_contents_if_present /data/nginx/html /etc/nginx/html
fi

configure_log_output /var/log/nginx/access.log /dev/stdout
configure_log_output /var/log/nginx/error.log /dev/stderr

printf '%b\n' "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/nginx${NC}"
printf '%b\n\n' "${GREEN}GitHub: https://github.com/funnyzak/docker-release${NC}"

printf '%b\n' "${GREEN}$(nginx -v 2>&1)${NC}"
printf '\n%b\n' "${YELLOW}Installed extra modules:${NC}"
printf '%b\n' "${BLUE}ngx_http_geoip_module${NC}, ${BLUE}ngx_http_image_filter_module${NC}, ${BLUE}ngx_http_perl_module${NC}, ${BLUE}ngx_http_xslt_filter_module${NC}, ${BLUE}ngx_mail_module${NC}, ${BLUE}ngx_stream_geoip_module${NC}, ${BLUE}ngx_stream_module${NC}, ${BLUE}ngx-fancyindex${NC}, ${BLUE}headers-more-nginx-module${NC}, etc."
printf '\n%b\n' "${YELLOW}nginx.conf configuration file path:${NC} ${RED}/etc/nginx/nginx.conf${NC}"
printf '%b\n' "${YELLOW}server configuration file path:${NC} ${RED}/etc/nginx/conf.d${NC}"
printf '%b\n' "${YELLOW}server template file path:${NC} ${RED}/etc/nginx/templates/default.conf.template${NC}"

nginx -t
nginx -g "daemon off;"
