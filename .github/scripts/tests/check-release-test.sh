#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cat > "$tmp/curl" <<'MOCK'
#!/usr/bin/env bash
printf '%s' "$MOCK_STATUS"
MOCK
chmod +x "$tmp/curl"
export PATH="$tmp:$PATH" IMAGE_NAME=test IS_LATEST_TAG=true GITHUB_OUTPUT="$tmp/output"
run() {
  : > "$GITHUB_OUTPUT"
  VERSION_COMMAND="$1" MOCK_STATUS="$2" bash "$root/check-release.sh"
}
run 'printf 1.2.3' 404
grep -qx 'is_new_release_version=true' "$GITHUB_OUTPUT"
grep -qx 'docker_tags=latest,1.2.3' "$GITHUB_OUTPUT"
run 'printf 1.2.3' 200
grep -qx 'is_new_release_version=false' "$GITHUB_OUTPUT"
for value in '' null no-tags; do
  run "printf '%s' '$value'" 200
  grep -qx 'is_new_release_version=false' "$GITHUB_OUTPUT"
done
if run 'printf 1.2.3' 429; then exit 1; fi
if run 'printf 1.2.3' 500; then exit 1; fi
if run 'false | cat' 200; then exit 1; fi
if run 'printf "bad tag"' 404; then exit 1; fi
if run 'printf "1.2.3\ninjected=value"' 404; then exit 1; fi
echo 'PASS: release probe cases'
