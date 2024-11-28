FROM linuxserver/libreoffice:7.6.7

ENV LANG=C.UTF-8
ENV TZ Asia/Shanghai

LABEL org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://yycc.dev"

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
