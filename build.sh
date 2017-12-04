#!/bin/sh

set -e

docker build -t esailors/aws-ecr-http-proxy:1.13.7-alpine .

docker push esailors/aws-ecr-http-proxy:1.13.7-alpine
