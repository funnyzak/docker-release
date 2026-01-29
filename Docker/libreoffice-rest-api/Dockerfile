FROM linuxserver/libreoffice:latest

ARG GITHUB_REPO="funnyzak/libreoffice-rest-api"
ARG VERSION="latest"
ARG TARGETOS
ARG TARGETARCH
ARG BUILD_DATE
ARG VCS_REF
ARG TARGETPLATFORM

USER root

RUN set -e; \
    apk add --no-cache ca-certificates curl jq tar; \
    if ! apk add --no-cache font-noto-cjk; then \
      apk add --no-cache wqy-zenhei; \
    fi; \
    mkdir -p /app /app/storage /app/logs /app/scripts; \
    os="${TARGETOS:-linux}"; \
    arch="${TARGETARCH:-}"; \
    if [ -z "$arch" ]; then \
      case "$(uname -m)" in \
        x86_64) arch="amd64" ;; \
        aarch64) arch="arm64" ;; \
        *) echo "nsupported architecture: $(uname -m)"; exit 1 ;; \
      esac; \
    fi; \
    if [ "$VERSION" = "latest" ]; then \
      api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"; \
    else \
      api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/tags/${VERSION}"; \
    fi; \
    release_json=$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$api_url" || true); \
    release_obj="$release_json"; \
    tag_name=$(echo "$release_obj" | jq -r '.tag_name' 2>/dev/null || true); \
    if [ "$VERSION" = "latest" ] && { [ -z "$tag_name" ] || [ "$tag_name" = "null" ]; }; then \
      api_url="https://api.github.com/repos/${GITHUB_REPO}/releases"; \
      releases_json=$(curl -fsSL -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" "$api_url" || true); \
      release_obj=$(echo "$releases_json" | jq -c '.[0]' 2>/dev/null || true); \
      tag_name=$(echo "$release_obj" | jq -r '.tag_name' 2>/dev/null || true); \
    fi; \
    if [ -z "$tag_name" ] || [ "$tag_name" = "null" ]; then \
      echo "Could not parse release tag"; \
      echo "$release_json" | head -c 400 || true; \
      exit 1; \
    fi; \
    asset_name="libreoffice-rest-api-${os}-${arch}.tar.gz"; \
    download_url=$(echo "$release_obj" | jq -r --arg name "$asset_name" '.assets[] | select(.name == $name) | .browser_download_url' | head -n 1); \
    if [ -z "$download_url" ] || [ "$download_url" = "null" ]; then \
      download_url="https://github.com/${GITHUB_REPO}/releases/download/${tag_name}/${asset_name}"; \
    fi; \
    curl -fsSL -o "/tmp/${asset_name}" "$download_url"; \
    tar -xzf "/tmp/${asset_name}" -C /app; \
    if [ ! -f /app/libreoffice-rest-api ]; then \
      found_bin=$(find /app -maxdepth 3 -type f -name libreoffice-rest-api | head -n 1); \
      if [ -n "$found_bin" ]; then mv "$found_bin" /app/libreoffice-rest-api; fi; \
    fi; \
    if [ ! -f /app/libreoffice-rest-api ]; then \
      echo "Could not find libreoffice-rest-api"; \
      exit 1; \
    fi; \
    chmod +x /app/libreoffice-rest-api; \
    rm -f "/tmp/${asset_name}"; \
    config_example_url=$(echo "$release_obj" | jq -r '.assets[] | select(.name == "config.yaml.example") | .browser_download_url' | head -n 1); \
    if [ -z "$config_example_url" ] || [ "$config_example_url" = "null" ]; then \
      config_example_url="https://github.com/${GITHUB_REPO}/releases/download/${tag_name}/config.yaml.example"; \
    fi; \
    curl -fsSL -o /app/config.yaml.example "$config_example_url"; \
    cp /app/config.yaml.example /app/config.yaml; \
    uno_convert_url=$(echo "$release_obj" | jq -r '.assets[] | select(.name == "uno_convert.py") | .browser_download_url' | head -n 1); \
    if [ -z "$uno_convert_url" ] || [ "$uno_convert_url" = "null" ]; then \
      uno_convert_url="https://github.com/${GITHUB_REPO}/releases/download/${tag_name}/uno_convert.py"; \
    fi; \
    curl -fsSL -o /app/scripts/uno_convert.py "$uno_convert_url"; \
    chmod +x /app/scripts/uno_convert.py; \
    if id -u abc >/dev/null 2>&1; then \
      chown -R abc:abc /app; \
    fi

WORKDIR /app

EXPOSE 30231

VOLUME ["/app/storage", "/app/logs"]

USER abc

ENTRYPOINT ["/app/libreoffice-rest-api"]
