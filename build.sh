#!/bin/sh

set -e

docker build -t esailors/aws-ecr-http-proxy:1.13.7-alpine .
docker tag esailors/aws-ecr-http-proxy:1.13.7-alpine esailors/aws-ecr-http-proxy:latest

docker push esailors/aws-ecr-http-proxy:1.13.7-alpine
docker push esailors/aws-ecr-http-proxy:latest
