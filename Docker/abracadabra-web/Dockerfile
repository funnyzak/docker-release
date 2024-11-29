FROM node:23.3.0 AS build

ARG BUILD_DATE
ARG VERSION=

RUN apk add --no-cache git
      
WORKDIR /app
RUN git clone https://github.com/SheepChef/Abracadabra_demo .
RUN npm ci 
RUN npx vite build --outDir ./dist

FROM nginx:1.27.3-alpine3.20-slim

LABEL org.label-schema.name="Abracadabra_demo" \
      org.label-schema.description="Abracadabra_demo" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY --from=build /app/dist /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
