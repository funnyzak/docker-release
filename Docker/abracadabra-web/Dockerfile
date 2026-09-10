FROM node:23.3.0 AS build

WORKDIR /app
RUN git clone https://github.com/SheepChef/Abracadabra_demo . && \
    npm ci && \
    npx vite build --outDir ./dist && \
    echo $(git rev-parse HEAD) > ./dist/abracadabra-demo-sha

FROM nginx:1.27.3-alpine3.20-slim

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="Abracadabra_demo" \
      org.label-schema.description="Abracadabra (魔曰) is an instant text encryption/de-sensitization tool, which can also be used for file encryption, based on C++ 11." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY --from=build /app/dist /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
