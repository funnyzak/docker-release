FROM node:22-alpine3.22 AS builder

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git

RUN git init . \
    && git remote add origin https://github.com/metowolf/vCards.git \
    && if [ -n "${VERSION}" ]; then \
      git fetch --depth 1 origin "${VERSION}"; \
    else \
      git fetch --depth 1 origin master; \
    fi \
    && git checkout --detach FETCH_HEAD \
    && echo "${VERSION:-$(git rev-parse HEAD)}" > VERSION

RUN npm ci && npm run radicale

FROM alpine:3.22

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
    py3-six \
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
