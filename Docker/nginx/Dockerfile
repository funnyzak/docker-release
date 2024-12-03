FROM alpine:3.20.3 AS builder

ARG BUILD_DATE
ARG VERSION

ENV TZ=Asia/Shanghai
ENV TMP_PATH=/tmp
ENV HEADERS_MORE_NGINX_MODULE=0.37
ENV FANCY_INDEX=0.5.2

RUN apk --no-cache add wget openssl-dev pcre-dev zlib-dev build-base \
    gd gd-dev perl perl-dev libxslt libxslt-dev libxml2 libxml2-dev geoip geoip-dev && \
    LATEST_VERSION=$(wget -qO- https://nginx.org/en/download.html | grep -oE "nginx-[0-9]+\.[0-9]+\.[0-9]+" | head -n 1 | cut -d- -f2) && \
    NGINX_VERSION=nginx-${VERSION:-$LATEST_VERSION} && \
    echo "Latest version is $NGINX_VERSION" && \
    mkdir -p ${TMP_PATH} && \
    wget http://nginx.org/download/${NGINX_VERSION}.tar.gz -O ${TMP_PATH}/${NGINX_VERSION}.tar.gz && \
    wget https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_NGINX_MODULE}.tar.gz -O ${TMP_PATH}/headers-more-nginx-module.tar.gz && \
    wget http://github.com/aperezdc/ngx-fancyindex/archive/v${FANCY_INDEX}.tar.gz -O ${TMP_PATH}/ngx-fancyindex.tar.gz && \
    cd ${TMP_PATH} && \
    tar -zxvf ${NGINX_VERSION}.tar.gz && \
    tar -zxvf headers-more-nginx-module.tar.gz && \
    tar -zxvf ngx-fancyindex.tar.gz && \
    cd ${NGINX_VERSION} && \
    ./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --pid-path=/var/run/nginx/nginx.pid \
    --lock-path=/var/run/nginx/nginx.lock \
    --user=nginx \
    --group=nginx \
    --build=Alpine \
    --add-module=${TMP_PATH}/headers-more-nginx-module-${HEADERS_MORE_NGINX_MODULE} \
    --add-module=${TMP_PATH}/ngx-fancyindex-${FANCY_INDEX} \
    --with-select_module \
    --with-poll_module \
    --with-threads \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-http_perl_module=dynamic \
    --with-perl_modules_path=/usr/lib64/perl5 \
    --with-perl=/usr/bin/perl \
    --http-log-path=/var/log/nginx/access.log \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-mail=dynamic \
    --with-mail_ssl_module \
    --with-stream=dynamic \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_geoip_module=dynamic \
    --with-stream_ssl_preread_module \
    --with-compat \
    --with-pcre-jit \
    --with-openssl-opt=no-nextprotoneg && \
    make && make install

FROM alpine:3.20.3

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="nginx" \
      org.label-schema.description="A nginx docker image with secure configurations and some useful modules, such as ngx_http_geoip_module, ngx_http_image_filter_module, ngx_http_perl_module, ngx_http_xslt_filter_module, ngx_mail_module, ngx_stream_geoip_module, ngx_stream_module, ngx-fancyindex, headers-more-nginx-module, etc." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

ENV TZ=Asia/Shanghai

RUN apk --no-cache add pcre zlib gd libxslt libxml2 geoip perl tzdata && \
    addgroup -S nginx && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx && \
    mkdir -p /var/log/nginx /var/cache/nginx /var/run/nginx && \
    chown -R nginx:nginx /var/log/nginx /var/cache/nginx /var/run/nginx

COPY --from=builder /etc/nginx /etc/nginx
COPY --from=builder /usr/sbin/nginx /usr/sbin/nginx
COPY --from=builder /usr/lib64/nginx /usr/lib64/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/conf.d /etc/nginx/conf.d

RUN mkdir -p /data/nginx/html /data/nginx/conf.d && \
    cp -r /etc/nginx/html /data/nginx && \
    cp -r /etc/nginx/conf.d /data/nginx && \
    cp /etc/nginx/nginx.conf /data/nginx/nginx.conf

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80 443

USER nginx

WORKDIR /etc/nginx

ENTRYPOINT ["/entrypoint.sh"]
