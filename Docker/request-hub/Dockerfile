FROM golang:1.16-alpine AS builder

RUN apk add --no-cache git && \
    go get github.com/kyledayton/requesthub && \
    rm -rf /tmp/* /var/cache/apk/*

FROM scratch AS final

COPY --from=builder /go/bin/requesthub /usr/local/bin/requesthub

ENV LANG=C.UTF-8 \
    CONFIG_YML= \
    NO_WEB=false \
    PORT=54321 \
    MAX_REQUESTS=512 \
    USER_NAME= \
    PASSWORD=

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
