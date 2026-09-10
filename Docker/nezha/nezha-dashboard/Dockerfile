FROM alpine AS builder

ARG VERSION
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache curl ca-certificates wget jq && \
    LATEST_VERSION=$(curl -s https://api.github.com/repos/nezhahq/nezha/releases/latest | jq -r '.tag_name') && \
    echo "Latest version is $LATEST_VERSION" && \
    DOWNLOAD_VERSION=${VERSION:-$LATEST_VERSION} && \
    echo ${DOWNLOAD_VERSION} > /tmp/version && \
    wget https://github.com/nezhahq/nezha/releases/download/${DOWNLOAD_VERSION}/dashboard-${TARGETOS}-${TARGETARCH}.zip -O /tmp/dashboard.zip

FROM busybox:stable-musl AS final

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

ARG TARGETOS
ARG TARGETARCH

ARG TZ=Asia/Shanghai
ENV TZ=$TZ

LABEL org.label-schema.name="nezha-dashboard" \
    org.label-schema.description="nezha-dashboard" \
    org.label-schema.version="${VERSION}" \
    org.label-schema.vcs-ref="${VCS_REF}" \
    org.label-schema.build-date="${BUILD_DATE}" \
    org.label-schema.vendor="Leon<silenceace@gmail.com>" \
    org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /tmp/dashboard.zip /tmp/dashboard.zip
COPY --from=builder /tmp/version /VERSION
COPY ./entrypoint.sh /entrypoint.sh

RUN mkdir -p /dashboard && \
    unzip /tmp/dashboard.zip -d /tmp && \
    mv /tmp/dashboard-${TARGETOS}-${TARGETARCH} /dashboard/app && \
    rm -rf /tmp/* && \
    chmod +x /dashboard/app && \
    chmod +x /entrypoint.sh
 
WORKDIR /dashboard

VOLUME ["/dashboard/data"]

EXPOSE 80 5555

ENTRYPOINT ["/entrypoint.sh"]