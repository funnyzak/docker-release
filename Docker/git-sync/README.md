# git-sync

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/git-sync?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/git-sync/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/git-sync)](https://hub.docker.com/r/funnyzak/git-sync/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/git-sync.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-sync/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/git-sync.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/git-sync/)

`git-sync` is a CLI tool designed to help you back up your Git repositories. This tool ensures you have a local copy of your repositories, safeguarding against potential issues such as account bans or data loss.
. This image supports `linux/amd64`,`linux/arm/v7`, `linux/arm64`.

You can pull the images using the following commands:

```bash
docker pull funnyzak/git-sync:latest
# GHCR
docker pull ghcr.io/funnyzak/git-sync:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/git-sync:latest
```

---

## Usage Example

### Docker run

```bash
docker run \
  --name=git-sync \
  -e PUID=1000 \
  -e PGID=1000 \
  -v ./git-sync/config.yaml:/git-sync/config.yaml \
  -v ./git-backups:/backups \
  funnyzak/git-sync:latest
```

### Docker Compose

```yaml
version: '3'
services:
  git-sync:
    image: funnyzak/git-sync:latest
    container_name: git-sync
    environment:
      - PUID=1000
      - PGID=1000
    volumes:
      - ./git-sync/config.yaml:/git-sync/config.yaml
      - ./git-backups:/backups
```

### Configuration

Here is an example of a `config.yaml` file:

```yaml
backup_dir: /backups
clone_type: full
concurrency: 5
exclude_orgs: []
exclude_repos: []
include_forks: false
include_orgs: []
include_repos: []
include_wiki: true
platform: github
raw_git_urls: []
retry:
    count: 3
    delay: 5
server:
    domain: github.com
    protocol: https
tokens:
    - github_pat_your_token
username: "your_username"
workspace: ""

```
More information about the configuration can be found [here](https://github.com/AkashRajpurohit/git-sync/wiki/Configuration).

More Examples can be found [here](https://github.com/AkashRajpurohit/git-sync/wiki/Examples).