# dify2openai

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/dify2openai?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/dify2openai/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/dify2openai)](https://hub.docker.com/r/funnyzak/dify2openai/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/dify2openai.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/dify2openai/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/dify2openai.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/dify2openai/)


dify2open converts the Dify API to the OpenAI API format, giving you access to Dify's LLMs, knowledge base, tools, and workflows within your preferred OpenAI clients. More information can be found at [dify2openai](https://github.com/funnyzak/dify2openai).

This image is built with the `linux/amd64`, `linux/arm64`, `linux/arm/v7`, `linux/arm64/v8`, `linux/ppc64le`, `linux/s390x` architectures.

**Pulling Images:**

You can pull the images using the following commands:

<summary>Docker Pull Commands</summary>

```bash
docker pull funnyzak/dify2openai:latest
# GHCR 
docker pull ghcr.io/funnyzak/dify2openai:latest
# Aliyun
docker pull registry.cn-beijing.aliyuncs.com/funnyzak/dify2openai:latest
```
## Environment Variable
This project provides some additional configuration items set with environment variables:

| Environment Variable | Required | Description                                                                                     | Example                        |
| -------------------- | -------- | ----------------------------------------------------------------------------------------------- | ------------------------------ |
| `DIFY_API_URL`       | Yes      | Your Dify API if you self-host it                                                               | `https://api.dify.ai/v1`       |
| `BOT_TYPE`           | Yes      | The type of your Dify bots                                                                      | `Chat,Completion,Workflow`     |
| `INPUT_VARIABLE`     | No       | The name of input variable in your own Dify workflow bot                                        | `query,text`                   |
| `OUTPUT_VARIABLE`    | No       | The name of output variable in your own Dify workflow bot                                       | `text`                         |
| `MODELS_NAME`        | No       | The value is the model name output by the `/v1/models` endpoint. The default value is `dify`.   |                                |

## Deployment

### Docker Deployment

```bash
docker run --name dify2openai -d \
  --network bridge \
  -p 3000:3000 \
  -e DIFY_API_URL=https://api.dify.ai/v1 \
  -e BOT_TYPE=Chat \
  --restart always \
  funnyzak/dify2openai:latest
```

### Docker Compose Deployment
```yaml
version: '3.1'
services:
  dify2openai:
    image: funnyzak/dify2openai:latest
    container_name: dify2openai
    environment:
      - DIFY_API_URL=https://api.dify.ai/v1
      - BOT_TYPE=Chat
    ports:
      - 3000:3000
    restart: always
```

More information can be found at [dify2openai](https://github.com/funnyzak/dify2openai).