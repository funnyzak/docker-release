# Hello World

This is a simple "Hello, World!" program written in Go.

## Files

- `Dockerfile`: Docker configuration file to build the `hello-world` image.
- `helloworld.go`: Go source file that prints "Hello, World!" to the console.
- `helloworld_amd64`: Compiled binary for the `amd64` architecture.

## Docker Run

```bash
docker run --rm funnyzak/hello-world:nightly
```