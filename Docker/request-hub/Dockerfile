FROM golang:1.16-alpine AS builder

WORKDIR /build

RUN apk add --no-cache git

RUN apk add --no-cache git && \
    go get github.com/kyledayton/requesthub && \
    rm -rf /tmp/* /var/cache/apk/*


FROM alpine:3.19 AS final

ARG BUILD_DATE
ARG VERSION=

LABEL org.label-schema.name="requesthub" \
      org.label-schema.description="requesthub" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"
      
      
RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

COPY --from=builder /go/bin/requesthub /usr/local/bin/requesthub

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
