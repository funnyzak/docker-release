FROM node:16 as builder

ENV WORKDIR=/app
WORKDIR $WORKDIR
RUN apt-get update && apt-get install -y git && \
    git clone --depth=1 https://github.com/lobehub/y-webrtc-signaling.git $WORKDIR
RUN npm install

FROM node:16-slim
ENV WORKDIR=/app
WORKDIR $WORKDIR
COPY --from=builder $WORKDIR .
HEALTHCHECK --interval=5s --timeout=3s --start-period=5s --retries=3 CMD wget -q -O - http://localhost:4444 || exit 1

EXPOSE 4444

CMD ["node", "index.js"]