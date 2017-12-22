#!/bin/sh

set -e

# update the auth token
CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
AUTH=$(grep  X-Forwarded-User $CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")
TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")

sed -i "s|${AUTH%??}|${AUTH_N}|g" $CONFIG

nginx -s reload
