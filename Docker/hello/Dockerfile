FROM golang:1.23.3 AS builder

ARG VERSION
ARG VCS_REF
ARG BUILD_DATE

LABEL org.label-schema.name="helloworld" \
      org.label-schema.description="helloworld" \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

WORKDIR /app

RUN go mod init hello && go mod tidy

COPY hello.go ./
RUN go build -o hello hello.go

FROM scratch
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]