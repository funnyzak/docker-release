#!/bin/sh

if [ ! -f /etc/nginx/nginx.conf ]; then
    cp /data/conf/nginx.conf /etc/nginx/nginx.conf
fi

if [ ! "$(ls -A /etc/nginx/conf.d)" ]; then
    cp -r /data/conf/conf.d/* /etc/nginx/conf.d/
fi

ln -sf /dev/stdout /var/log/nginx/access.log && ln -sf /dev/stderr /var/log/nginx/error.log

nginx -g "daemon off;"