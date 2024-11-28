FROM linuxserver/libreoffice:7.6.7

ARG BUILD_DATE
ARG VERSION=

LABEL org.label-schema.name="libreoffice-server" \
      org.label-schema.description="libreoffice-server" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

ENV LANG=C.UTF-8
ENV TZ Asia/Shanghai
      
RUN \
    apk add --no-cache nodejs npm git cups-libs fontconfig ttf-dejavu && \
    rm -rf /tmp/*

RUN mkdir -p /app && chmod -R 777 /app

VOLUME /app

RUN git clone https://github.com/funnyzak/libreoffice-server.git /app/nodeapp && \
    npm ci --prefix /app/nodeapp

WORKDIR /app/nodeapp

COPY ./cmd.sh /

EXPOSE 3000 8038

CMD ["/bin/bash", "/cmd.sh"]
