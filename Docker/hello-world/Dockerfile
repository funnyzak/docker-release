FROM --platform=$BUILDPLATFORM scratch

ARG TARGETPLATFORM
ARG BUILDPLATFORM

COPY helloworld_amd64 /helloworld_amd64
COPY helloworld_arm64 /helloworld_arm64

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
        cp /helloworld_amd64 /helloworld; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
        cp /helloworld_arm64 /helloworld; \
    else \
        echo "Unsupported platform: $TARGETPLATFORM"; \
        exit 1; \
    fi

RUN chmod +x /helloworld

ENTRYPOINT ["/helloworld"]