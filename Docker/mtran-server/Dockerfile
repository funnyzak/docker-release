FROM node:22 AS node-builder

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

WORKDIR /app

RUN git clone https://github.com/xxnuo/MTranServer.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=12 HEAD)}-$(git log -1 --format=%cd --date=format:'%y%m%d') > VERSION

FROM oven/bun:1 AS builder

WORKDIR /app

COPY --from=node-builder /app/ /app/

RUN bun install --frozen-lockfile
RUN cd ui && bun install --frozen-lockfile

RUN bun run build:docker

FROM node:22-alpine

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="MTranServer" \
      org.label-schema.description="Offline translation model server with low resource consumption, fast speed, and private deployment capability." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

WORKDIR /app

COPY --from=builder /app/dist ./
COPY --from=builder /app/node_modules ./node_modules

ENV MT_HOST=0.0.0.0 \
    MT_PORT=8989 \
    NODE_ENV=production

EXPOSE 8989

CMD ["node", "main.js"]