#!/bin/sh

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

[ ! -f /etc/nginx/nginx.conf ] && cp /data/conf/nginx.conf /etc/nginx/nginx.conf
[ -z "$(ls -A /etc/nginx/conf.d)" ] && cp -r /data/conf/conf.d/* /etc/nginx/conf.d/

ln -sf /dev/stdout /var/log/nginx/access.log
ln -sf /dev/stderr /var/log/nginx/error.log

echo -e "${GREEN}Contact: funnyzak${NC}"
echo -e "${GREEN}$(nginx -v 2>&1)${NC}"
echo -e "\n${YELLOW}Installed extra modules:${NC}"
echo -e "${BLUE}ngx_http_geoip_module${NC}, ${BLUE}ngx_http_image_filter_module${NC}, ${BLUE}ngx_http_perl_module${NC}, ${BLUE}ngx_http_xslt_filter_module${NC}, ${BLUE}ngx_mail_module${NC}, ${BLUE}ngx_stream_geoip_module${NC}, ${BLUE}ngx_stream_module${NC}, ${BLUE}ngx-fancyindex${NC}, ${BLUE}headers-more-nginx-module${NC}, etc."
echo -e "\n${YELLOW}nginx.conf configuration file path:${NC} ${RED}/etc/nginx/nginx.conf${NC}"
echo -e "${YELLOW}conf.d configuration file path:${NC} ${RED}/etc/nginx/conf.d${NC}"

nginx -g "daemon off;"