# Hello

[![Docker Tags](https://img.shields.io/docker/v/funnyzak/hello?sort=semver&style=flat-square)](https://hub.docker.com/r/funnyzak/hello/)
[![Image Size](https://img.shields.io/docker/image-size/funnyzak/hello)](https://hub.docker.com/r/funnyzak/hello/)
[![Docker Stars](https://img.shields.io/docker/stars/funnyzak/hello.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/hello/)
[![Docker Pulls](https://img.shields.io/docker/pulls/funnyzak/hello.svg?style=flat-square)](https://hub.docker.com/r/funnyzak/hello/)


This is a simple "Hello, World!" program written in Go. Used to demonstrate how to build a Docker image.

## Docker Run

```bash
docker run --rm funnyzak/hello:latest
```

## Docker Build

```bash
docker build -t funnyzak/hello:latest .
```

## Code

### hello.go

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, I am Leo. Contact me at https://github.com/funnyzak")
}
```

## Dockerfile

```Dockerfile
FROM golang:1.23.3 AS builder
WORKDIR /app
RUN go mod init hello && go mod tidy
COPY hello.go ./
RUN go build -o hello hello.go
FROM scratch
COPY --from=builder /app/hello /hello
ENTRYPOINT ["/hello"]
```