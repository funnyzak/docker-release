FROM python:3.13-slim AS builder

ARG VERSION
ARG BUILD_DATE
ARG VCS_REF

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/funnyzak/weread-bot.git . \
    && git checkout ${VERSION} || git checkout $(git remote show origin | awk '/HEAD branch/ {print $NF}') \
    && echo ${VERSION:-$(git rev-parse --short=8 HEAD)} > VERSION

FROM python:3.13-slim

LABEL org.label-schema.name="weread-bot" \
      org.label-schema.description="An intelligent WeChat Read reading time farming tool that supports humanized configuration and behavior simulation." \
      org.label-schema.version="${VERSION}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vendor="Leon<silenceace@gmail.com>" \
      org.label-schema.url="https://github.com/funnyzak/docker-release"

WORKDIR /app

COPY --from=builder /app/weread-bot.py /app/weread-bot.py
COPY --from=builder /app/requirements.txt /app/requirements.txt
COPY --from=builder /app/VERSION /app/VERSION

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

ENTRYPOINT ["python", "weread-bot.py"]
