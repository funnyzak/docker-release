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
# Git Sync Configuration

# Repository settings
include_forks: false # Include forked repositories
include_wiki: true # Include wiki's
include_repos: [] # Include specific repositories
exclude_repos: [] # Exclude specific repositories
include_orgs: [] # Include repositories from specific organizations
exclude_orgs: [] # Exclude repositories from specific organizations
raw_git_urls: [] # Raw valid git URLs

# Authentication
username: <username>
tokens: [<token 1>]

# Server settings
backup_dir: /path/to/backup
clone_type: bare # Clone type: bare, shallow, mirror or full. Default: bare
cron: 0 0 * * * # run every 24 hours at 00:00
concurrency: 5
retry:
  count: 3
  delay: 10 # in seconds
platform: github
server:
  domain: github.com
  protocol: https
```
More information about the configuration can be found [here](https://github.com/AkashRajpurohit/git-sync/wiki/Configuration).

More Examples can be found [here](https://github.com/AkashRajpurohit/git-sync/wiki/Examples).