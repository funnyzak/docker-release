FROM node:20-alpine3.19 AS front-builder

WORKDIR /app

RUN apk add --no-cache git

ARG VERSION

RUN git clone https://github.com/usual2970/certimate . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse HEAD)} > VERSION

RUN \
  cd /app/ui && \
  npm install && \
  npm run build

FROM golang:1.24-alpine AS builder

WORKDIR /app

COPY --from=front-builder /app /app

RUN rm -rf /app/ui/dist && \
    mkdir -p /app/ui/dist

COPY --from=front-builder /app/ui/dist /app/ui/dist

ENV CGO_ENABLED=0
RUN go build -ldflags="-s -w" -o certimate

FROM alpine:latest

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF
ENV PORT=8090

LABEL org.label-schema.name="certimate" \
      org.label-schema.description="Certimate aims to provide users with a secure and user-friendly SSL certificate management solution." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.url="https://github.com/usual2970/certimate"

WORKDIR /app

COPY --from=builder /app/certimate /app/certimate
COPY --from=builder /app/VERSION /app/VERSION

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD wget -qO- http://localhost:${PORT} || exit 1

EXPOSE ${PORT}

ENTRYPOINT ["/entrypoint.sh"]