FROM node:alpine3.22 AS builder

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git

WORKDIR /app

RUN git clone https://github.com/metowolf/vCards . \
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
    radicale \
  && rm -rf /var/cache/apk/* \
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
    echo '[auth]'; \
    echo 'type = none'; \
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

COPY --from=builder /app/radicale/ios/ /app/vcards/collection-root/cn/
COPY --from=builder /app/radicale/macos/ /app/vcards/collection-root/cnmacos/
COPY --from=builder /app/VERSION /app/VERSION

EXPOSE 5232

CMD ["radicale"]