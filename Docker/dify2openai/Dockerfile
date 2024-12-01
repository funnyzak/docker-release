FROM node:16-alpine AS builder

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git && \
    git clone https://github.com/funnyzak/dify2openai . \
    && git checkout ${VERSION} || git checkout main \
    && echo ${VERSION:-$(git rev-parse --short=8 HEAD)} > VERSION \
    && npm install --production

FROM node:16-alpine

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="dify2openai" \
      org.label-schema.description="dify2open converts the Dify API to the OpenAI API format, giving you access to Dify's LLMs, knowledge base, tools, and workflows within your preferred OpenAI clients." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/VERSION /app/
COPY --from=builder /app/node_modules /app/node_modules
COPY --from=builder /app/app.js /app/
COPY --from=builder /app/package.json /app/
COPY --from=builder /app/package-lock.json /app/

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 CMD wget -qO- http://localhost:3000 || exit 1

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]
