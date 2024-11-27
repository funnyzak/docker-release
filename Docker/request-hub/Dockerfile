FROM golang:1.21-alpine AS builder

WORKDIR /build

RUN apk add --no-cache git

RUN go mod init requesthub && \
    go get github.com/kyledayton/requesthub && \
    go build -o requesthub && \
    rm -rf /tmp/* /var/cache/apk/*

FROM alpine:3.19 AS final

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /build/requesthub /usr/local/bin/requesthub

ENV LANG=C.UTF-8 \
    CONFIG_YML= \
    NO_WEB=false \
    PORT=54321 \
    MAX_REQUESTS=512 \
    USER_NAME= \
    PASSWORD=

EXPOSE 54321

CMD requesthub -config "$CONFIG_YML" \
    -noweb="$NO_WEB" \
    -p="$PORT" \
    -password="$PASSWORD" \
    -r="$MAX_REQUESTS" \
    -username="$USER_NAME"
