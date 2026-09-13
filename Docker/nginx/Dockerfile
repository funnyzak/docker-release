# Nginx built from source on a supported Alpine release.
# The VERSION build arg selects the nginx version to compile (the release
# workflow injects it from the image tag). Third-party module tarballs are
# verified by pinned SHA256 checksums, and the whole build happens in a
# single apk world-state so builder/runtime library versions can never drift.
# HTTP/3 (QUIC) is compiled in via the Alpine OpenSSL 3.5 QUIC API.
FROM alpine:3.24.1

ARG VERSION=1.30.4
ARG HEADERS_MORE_NGINX_MODULE=0.37
ARG HEADERS_MORE_NGINX_MODULE_SHA256=cf6e169d6b350c06d0c730b0eaf4973394026ad40094cddd3b3a5b346577019d
ARG FANCY_INDEX=0.5.2
ARG FANCY_INDEX_SHA256=c3dd84d8ba0b8daeace3041ef5987e3fb96e9c7c17df30c9ffe2fe3aa2a0ca31
# google/ngx_brotli has no usable release tag; pin the master commit instead.
ARG BROTLI_NGINX_MODULE=a71f9312c2deb28875acc7bacfdd5695a111aa53
ARG BROTLI_NGINX_MODULE_SHA256=1d21be34f3b7b6d05a8142945e59b3a47665edcdfe0f3ee3d3dbef121f90c08c
# ngx_brotli requires the brotli sources under deps/brotli for its headers;
# linking is done against the Alpine brotli libraries.
ARG BROTLI_LIBRARY_VERSION=1.2.0
ARG BROTLI_LIBRARY_SHA256=816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec
ARG GEOIP2_NGINX_MODULE=3.4
ARG GEOIP2_NGINX_MODULE_SHA256=ad72fc23348d715a330994984531fab9b3606e160483236737f9a4a6957d9452
ARG BUILD_DATE
ARG VCS_REF

ENV TZ=Asia/Shanghai

LABEL org.opencontainers.image.title="nginx" \
      org.opencontainers.image.description="Nginx built from source with hardened defaults, HTTP/3 support and optional dynamic modules: headers-more, fancyindex, brotli, geoip2, image filter, xslt, perl, mail, stream." \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.authors="Leon <silenceace@gmail.com>" \
      org.opencontainers.image.url="https://hub.docker.com/r/funnyzak/nginx" \
      org.opencontainers.image.source="https://github.com/funnyzak/docker-release/tree/main/Docker/nginx" \
      org.opencontainers.image.documentation="https://github.com/funnyzak/docker-release/blob/main/Docker/nginx/README.md"

RUN apk add --no-cache --virtual .nginx-build-deps \
        build-base wget linux-headers \
        openssl-dev pcre-dev zlib-dev gd-dev libxslt-dev libxml2-dev brotli-dev libmaxminddb-dev perl-dev \
    && apk add --no-cache openssl pcre zlib gd libxslt libxml2 brotli-libs libmaxminddb-libs perl tzdata gettext-envsubst \
    && addgroup -S nginx \
    && adduser -D -S -u 100 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx \
    && cd /tmp \
    && wget -q -t 3 -T 30 https://nginx.org/download/nginx-${VERSION}.tar.gz \
    && wget -q -t 3 -T 30 -O headers-more-nginx-module.tar.gz \
        https://github.com/openresty/headers-more-nginx-module/archive/v${HEADERS_MORE_NGINX_MODULE}.tar.gz \
    && echo "${HEADERS_MORE_NGINX_MODULE_SHA256}  headers-more-nginx-module.tar.gz" | sha256sum -c - \
    && wget -q -t 3 -T 30 -O ngx-fancyindex.tar.gz \
        https://github.com/aperezdc/ngx-fancyindex/archive/v${FANCY_INDEX}.tar.gz \
    && echo "${FANCY_INDEX_SHA256}  ngx-fancyindex.tar.gz" | sha256sum -c - \
    && wget -q -t 3 -T 30 -O ngx-brotli-module.tar.gz \
        https://github.com/google/ngx_brotli/archive/${BROTLI_NGINX_MODULE}.tar.gz \
    && echo "${BROTLI_NGINX_MODULE_SHA256}  ngx-brotli-module.tar.gz" | sha256sum -c - \
    && wget -q -t 3 -T 30 -O brotli-library.tar.gz \
        https://github.com/google/brotli/archive/v${BROTLI_LIBRARY_VERSION}.tar.gz \
    && echo "${BROTLI_LIBRARY_SHA256}  brotli-library.tar.gz" | sha256sum -c - \
    && wget -q -t 3 -T 30 -O ngx-http-geoip2-module.tar.gz \
        https://github.com/leev/ngx_http_geoip2_module/archive/${GEOIP2_NGINX_MODULE}.tar.gz \
    && echo "${GEOIP2_NGINX_MODULE_SHA256}  ngx-http-geoip2-module.tar.gz" | sha256sum -c - \
    && tar -xzf nginx-${VERSION}.tar.gz \
    && tar -xzf headers-more-nginx-module.tar.gz \
    && tar -xzf ngx-fancyindex.tar.gz \
    && tar -xzf ngx-brotli-module.tar.gz \
    && tar -xzf brotli-library.tar.gz \
    && tar -xzf ngx-http-geoip2-module.tar.gz \
    && rm -rf ngx_brotli-${BROTLI_NGINX_MODULE}/deps/brotli \
    && mv brotli-${BROTLI_LIBRARY_VERSION} ngx_brotli-${BROTLI_NGINX_MODULE}/deps/brotli \
    && cd nginx-${VERSION} \
    && ./configure \
        --prefix=/etc/nginx \
        --sbin-path=/usr/sbin/nginx \
        --modules-path=/usr/lib/nginx/modules \
        --conf-path=/etc/nginx/nginx.conf \
        --error-log-path=/var/log/nginx/error.log \
        --http-log-path=/var/log/nginx/access.log \
        --pid-path=/run/nginx/nginx.pid \
        --lock-path=/run/nginx/nginx.lock \
        --user=nginx \
        --group=nginx \
        --build=docker-release \
        --add-dynamic-module=/tmp/headers-more-nginx-module-${HEADERS_MORE_NGINX_MODULE} \
        --add-dynamic-module=/tmp/ngx-fancyindex-${FANCY_INDEX} \
        --add-dynamic-module=/tmp/ngx_brotli-${BROTLI_NGINX_MODULE} \
        --add-dynamic-module=/tmp/ngx_http_geoip2_module-${GEOIP2_NGINX_MODULE} \
        --with-select_module \
        --with-poll_module \
        --with-threads \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_v3_module \
        --with-http_realip_module \
        --with-http_addition_module \
        --with-http_xslt_module=dynamic \
        --with-http_image_filter_module=dynamic \
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
        --with-perl_modules_path=/usr/lib/perl5/vendor_perl \
        --with-perl=/usr/bin/perl \
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
        --with-stream_ssl_preread_module \
        --with-compat \
        --with-pcre-jit \
        --with-openssl-opt=no-nextprotoneg \
    && make -j"$(nproc)" \
    && make install \
    # Module loading is handled by the load_module lines at the top of
    # /etc/nginx/nginx.conf (headers-more on, everything else commented).
    && mkdir -p /run/nginx \
    && mkdir -p /data/nginx/html /data/nginx/conf.d /data/nginx/templates /var/cache/nginx /var/log/nginx \
    && cp /etc/nginx/html/index.html /etc/nginx/html/50x.html /data/nginx/html/ \
    && chown -R nginx:nginx /run/nginx /var/cache/nginx /var/log/nginx \
    && apk del .nginx-build-deps \
    && rm -rf /tmp/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/conf.d /etc/nginx/conf.d
COPY conf/templates /etc/nginx/templates
COPY conf/stream.d /etc/nginx/stream.d

RUN cp /etc/nginx/nginx.conf /data/nginx/nginx.conf \
    && cp -r /etc/nginx/templates/. /data/nginx/templates/ \
    && cp -r /etc/nginx/conf.d/. /data/nginx/conf.d/ \
    && rm -rf /etc/nginx/conf.d/* \
    # Directories the entrypoint writes to at runtime run as the nginx user;
    # the rest of /etc/nginx stays root-owned.
    && chown -R nginx:nginx /etc/nginx/conf.d /etc/nginx/html /data/nginx

COPY --chmod=755 entrypoint.sh /entrypoint.sh

EXPOSE 80 443

USER nginx

WORKDIR /etc/nginx

# SIGQUIT is nginx's graceful shutdown signal; combined with `exec` in the
# entrypoint (nginx becomes PID 1) `docker stop` shuts down cleanly.
STOPSIGNAL SIGQUIT

# Process-level check: works regardless of the configured listen port.
# busybox pgrep matches against the full command line, so no -x here.
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD pgrep nginx || exit 1

ENTRYPOINT ["/entrypoint.sh"]

CMD ["nginx", "-g", "daemon off;"]
