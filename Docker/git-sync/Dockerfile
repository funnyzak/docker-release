FROM golang:1.24.4-alpine AS builder

WORKDIR /go/src/app

RUN apk add --no-cache upx ca-certificates tzdata git

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

ENV GO111MODULE=on \
  CGO_ENABLED=0 \
  GOOS=linux

RUN git clone https://github.com/AkashRajpurohit/git-sync.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=12 HEAD)}-$(git log -1 --format=%cd --date=format:'%y%m%d') > VERSION

RUN go mod download \
  && go mod tidy

RUN go build -a -installsuffix cgo -ldflags="-w -s -X github.com/AkashRajpurohit/git-sync/pkg/version.Version=${VERSION} -X github.com/AkashRajpurohit/git-sync/pkg/version.Build=${BUILD_DATE}" -o git-sync . \
  && upx -q git-sync

FROM alpine:latest
WORKDIR /opt/go

LABEL org.label-schema.name="git-sync" \
      org.label-schema.description="A simple tool to backup and sync your git repositories." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

# Install git since it's required for the application
RUN apk add --no-cache git su-exec

RUN mkdir -p /git-sync /backups

COPY --from=builder /go/src/app/git-sync /opt/go/git-sync
COPY --from=builder /go/src/app/VERSION /opt/go/VERSION
COPY --from=builder /go/src/app/entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "/opt/go/git-sync"]
CMD ["--config", "/git-sync/config.yaml", "--backup-dir", "/backups"]

