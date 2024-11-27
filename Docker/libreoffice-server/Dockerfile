FROM linuxserver/libreoffice:7.6.7

ENV LANG=C.UTF-8
ENV TZ Asia/Shanghai

RUN \
    apk add nodejs npm git && \
    apk add cups-libs fontconfig ttf-dejavu && \
    apk del --purge \
    rm -rf \
    /tmp/*

RUN mkdir -p /app
RUN chmod -R 777 /app
VOLUME /app

RUN git clone https://github.com/funnyzak/libreoffice-server.git /app/nodeapp
RUN npm ci --prefix /app/nodeapp

WORKDIR /app/nodeapp

COPY ./cmd.sh /

EXPOSE 3000 8038

CMD ["/bin/bash", "/cmd.sh"]
