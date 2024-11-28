FROM scratch

ARG BUILD_DATE
ARG VERSION

LABEL org.label-schema.name="helloworld" \
      org.label-schema.description="helloworld" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

COPY helloworld_amd64 /sayhello
ENTRYPOINT ["/sayhello"]