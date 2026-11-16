FROM node:16 AS node-builder

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

WORKDIR /app

RUN git clone https://github.com/songquanpeng/one-api.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=12 HEAD)}-$(git log -1 --format=%cd --date=format:'%y%m%d') > VERSION

WORKDIR /app/web

WORKDIR /app/web/default
RUN npm install && DISABLE_ESLINT_PLUGIN='true' REACT_APP_VERSION=$(cat /app/VERSION) npm run build

WORKDIR /app/web/berry
RUN npm install && DISABLE_ESLINT_PLUGIN='true' REACT_APP_VERSION=$(cat /app/VERSION) npm run build

WORKDIR /app/web/air
RUN npm install && DISABLE_ESLINT_PLUGIN='true' REACT_APP_VERSION=$(cat /app/VERSION) npm run build

FROM golang:alpine AS go-builder

ARG VERSION

RUN apk add --no-cache g++ git

ENV GO111MODULE=on \
    CGO_ENABLED=1 \
    GOOS=linux

WORKDIR /build

RUN git clone https://github.com/songquanpeng/one-api.git . \
    && git checkout ${VERSION} || git checkout main \
    && echo ${VERSION:-$(git rev-parse --short=12 HEAD)}-$(git log -1 --format=%cd --date=format:'%y%m%d') > VERSION

RUN go mod download
COPY --from=node-builder /app/web/build ./web/build
RUN go build -trimpath -ldflags "-s -w -X 'github.com/songquanpeng/one-api/common.Version=$(cat VERSION)' -extldflags '-static'" -o one-api

FROM alpine

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

COPY --from=go-builder /build/one-api /
COPY --from=go-builder /build/VERSION /

LABEL org.label-schema.name="one-api" \
      org.label-schema.description="Access all LLM through the standard OpenAI API format, easy to deploy & use." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"
      
RUN apk update \
    && apk upgrade \
    && apk add --no-cache ca-certificates tzdata \
    && update-ca-certificates 2>/dev/null || true

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 CMD wget -qO- http://localhost:3000/api/status || exit 1

EXPOSE 3000

WORKDIR /data
ENTRYPOINT ["/one-api"]
