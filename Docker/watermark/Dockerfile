FROM node:14-alpine AS build

ARG VERSION

WORKDIR /app

RUN apk add --no-cache git \
    && git clone https://github.com/funnyzak/watermark . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=8 HEAD)} > VERSION \
    && yarn && yarn build

FROM nginx:1.27.3-alpine3.20-slim

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="Watermark" \
      org.label-schema.description="Web纯前端图片加水印。用来在各种证件上添加 “仅用于办理XXXX，他用无效。”，防止证件被他人盗用！" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY --from=build /app/dist /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
