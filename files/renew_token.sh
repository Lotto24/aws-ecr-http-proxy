#!/bin/sh

set -xe

# update the auth token
CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
AUTH=$(grep  X-Forwarded-User $CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")

# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-login-password)
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done


AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")

sed -i "s|${AUTH%??}|${AUTH_N}|g" $CONFIG

nginx -s reload
