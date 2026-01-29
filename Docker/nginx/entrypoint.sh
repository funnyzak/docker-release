#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

[ ! -s /etc/nginx/nginx.conf ] && cp -f /data/nginx/nginx.conf /etc/nginx/nginx.conf
[ ! -d /etc/nginx/conf.d ] || [ -z "$(ls -A /etc/nginx/conf.d)" ] && cp -r /data/nginx/conf.d/* /etc/nginx/conf.d/
[ -z "$(ls -A /etc/nginx/html)" ] && cp -r /data/nginx/html/* /etc/nginx/html/

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

echo -e "${GREEN}Docker Hub: https://hub.docker.com/r/funnyzak/nginx${NC}"
echo -e "${GREEN}GitHub: https://github.com/funnyzak/docker-release\n"

echo -e "${GREEN}$(nginx -v 2>&1)${NC}"
echo -e "\n${YELLOW}Installed extra modules:${NC}"
echo -e "${BLUE}ngx_http_geoip_module${NC}, ${BLUE}ngx_http_image_filter_module${NC}, ${BLUE}ngx_http_perl_module${NC}, ${BLUE}ngx_http_xslt_filter_module${NC}, ${BLUE}ngx_mail_module${NC}, ${BLUE}ngx_stream_geoip_module${NC}, ${BLUE}ngx_stream_module${NC}, ${BLUE}ngx-fancyindex${NC}, ${BLUE}headers-more-nginx-module${NC}, etc."
echo -e "\n${YELLOW}nginx.conf configuration file path:${NC} ${RED}/etc/nginx/nginx.conf${NC}"
echo -e "${YELLOW}server configuration file path:${NC} ${RED}/etc/nginx/conf.d${NC}"

nginx -g "daemon off;"