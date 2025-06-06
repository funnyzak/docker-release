FROM node:20-alpine3.19 AS builder

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/funnyzak/vCards . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse HEAD)} > VERSION

RUN yarn && yarn radicale

FROM alpine:edge

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

LABEL org.label-schema.name="MetoWolf-vCards" \
    org.label-schema.description="MetoWolf-vCards" \
    org.label-schema.version="${VERSION}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.url="https://github.com/funnyzak/docker-release"

RUN apk add --no-cache \
    radicale unzip curl dcron tzdata jq bash rsync && \
  rm -rf /var/cache/apk/* \
  \
  && { \
    echo '[root]'; \
    echo 'user: .+'; \
    echo 'collection:'; \
    echo 'permissions: R'; \
    echo; \
    echo '[principal]'; \
    echo 'user: .+'; \
    echo 'collection: {user}'; \
    echo 'permissions: R'; \
    echo; \
    echo '[collections]'; \
    echo 'user: .+'; \
    echo 'collection: {user}/[^/]+'; \
    echo 'permissions: rR'; \
  } > /etc/radicale/rights \
  \
  && { \
    echo '[server]'; \
    echo 'hosts = 0.0.0.0:5232, [::]:5232'; \
    echo; \
    echo '[web]'; \
    echo 'type = none'; \
    echo; \
    echo '[storage]'; \
    echo 'type = multifilesystem'; \
    echo 'filesystem_folder = /app/vcards'; \
    echo; \
    echo '[rights]'; \
    echo 'type = from_file'; \
    echo 'file = /etc/radicale/rights'; \
  } > /etc/radicale/config


ENV TZ=Asia/Shanghai
ENV DOWNLOAD_DIR="/app/downloads"
ENV REPO_NAME="funnyzak/vCards"
ENV SYNC_ON_STARTUP="true"

COPY --from=builder /app/radicale/ /app/vcards/collection-root/cn/
COPY --from=builder /app/VERSION /app/VERSION
COPY /scripts/* /run-scripts/

RUN chmod +x /run-scripts/*

EXPOSE 5232

ENTRYPOINT ["/run-scripts/entrypoint.sh"]