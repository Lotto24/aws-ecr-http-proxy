#!/bin/sh

set -xe

# update the auth token
CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
AUTH=$(grep  X-Forwarded-User $CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")

set +x
# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-authorization-token --query 'authorizationData[*].authorizationToken' --output text)
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done

echo $TOKEN > /usr/local/openresty/nginx/token.txt
set -x

nginx -s reload
