FROM node:18 as builder

ENV WORKDIR=/app
WORKDIR $WORKDIR
RUN apt-get update && apt-get install -y git && \
    git clone --depth=1 https://github.com/lobehub/y-webrtc-signaling.git $WORKDIR
RUN npm install

FROM node:18-alpine

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="y-webrtc-signaling" \
      org.label-schema.description="y-webrtc-signaling" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

ENV WORKDIR=/app
WORKDIR $WORKDIR
COPY --from=builder $WORKDIR .

EXPOSE 4444

CMD ["node", "index.js"]