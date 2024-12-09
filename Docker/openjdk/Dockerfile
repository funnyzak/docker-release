ARG VERSION=11

FROM openjdk:${VERSION}

ARG BUILD_DATE
ARG VERSION
ARG VCS_REF

LABEL org.label-schema.name="java" \
      org.label-schema.description="java" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

ENV LANG=C.UTF-8 \
    TZ=Asia/Shanghai

CMD ["java", "-version"]