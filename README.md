### Insomnia Linting Docker Image
### Created for LexisNexis
---

## Descriptions
This repository contains a pure example of one main purpose: to create a Docker image capable of linting an
OpenAPI Specification or RESTful API Modeling Language file within a private virtual machine.


## Dockerfile
The Dockerfile is designed to be built within some sort of Jenkins pipline or simmiliar. Taking a look at that Dockerfile lets break it down:
``` Dockerfile
FROM node:alpine
RUN  apk --no-cache add g++ make curl-dev bash python3 && npm install -g insomnia-inso
ARG SPEC_PATH
ENV INSO_SPEC_PATH=$SPEC_PATH
COPY ./ /usr/local/inso-cli/
WORKDIR /usr/local/inso-cli/
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["inso lint spec $INSO_SPEC_PATH"]
```
Breakdown:
* `FROM` the base image is NODE.JS latest version, we use this base image for npm resources. Our `RUN` command installs necessary complements for runtime.
* `ARG` is used to grab the `--build-arg` flag from the `docker build` command. This is extremely important, please see `Docker Build` below!
* `ENV` is used to pass the `ARG` from the CLI/Host OS to our image's environment.
* `COPY` is important for obtaining the OAS or RAML file from the Host VM to the inside of the Docker image.
* `WORKDIR` is used to set the `PWD` or `CD` to a specific directory for future commands.
* `ENTRYPOINT` is our initial command being executed. In this case, we're wanting to run a shell command.
* `CMD` the Insomnia linting command which will be executed on the underlying Docker image.

## Docker Build
To run this in a PROD environment you will want to generate the image like so:
``` bash
docker build -t inso-cli:latest --build-arg SPEC_PATH=./oas/kong-demo-api.yaml .
```
or an environment variable can be set before the command is executed in the Host OS:
``` bash
export SPEC_PATH=./oas/kong-demo-api.yaml
docker build -t inso-cli:latest --build-arg SPEC_PATH .
```
Docker can automatically find and set the SPEC_PATH [vsupalov.com example](https://vsupalov.com/docker-build-pass-environment-variables/#option-2-5-using-host-environment-variable-values-to-set-args)

## Docker Developer Linting
This repo includes a handly docker-compose file which contains a set set of commented out lines.
Lets take a look at how the docker-compose and Dockerfile go hand and hand in this scenerio:
``` yaml
version: "3.8"

services:
  inso-cli:
    container_name: inso-cli
    image: inso-cli:latest
    build:
      context: ./
      dockerfile: ./Dockerfile
    environment:
      INSO_SPEC_PATH: "/some/path/filename.yaml"
    volumes:
      - ./:/some/path/
```
Breakdown:
* `build` is used to refrence the exact Dockerfile to build when composing up.
* `environment` is used to configure the image's environment variables to override the Dockerfile `ENV` setup.
* `volumes` is used to configure the files to be passed into the image filesystem.

## Docker-Compose Run
To run the docker-compose and build the underlying Docker image can be done by executing the following:
``` bash
docker-compose up -d --build
```
or you can specify the docker-compose file is not in the direct directory with:
``` bash
docker-compose up -f "/path/to/file/docker-compose.yaml" -d --build"
```
