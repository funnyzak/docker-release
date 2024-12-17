# Private

## env-mock-data

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/env-mock-data?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/env-mock-data/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/env-mock-data)](https://hub.docker.com/r/funnyzak/env-mock-data/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/env-mock-data.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/env-mock-data/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/env-mock-data.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/env-mock-data/)

Used to generate mock data for the environment.

### Usage

```bash
docker run -d --name env-mock-data -v ./config.json:/app/config.json funnyzak/env-mock-data
```

> Note: The `config.json` file should be in the same directory as the command above.