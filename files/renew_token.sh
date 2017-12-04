#!/bin/sh

set -e

# update the auth token
AUTH=$(grep  X-Forwarded-User /etc/nginx/conf.d/default.conf | awk '{print $4}'| uniq|tr -d "\n\r")
TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")

sed -i "s|${AUTH%??}|${AUTH_N}|g" /etc/nginx/conf.d/default.conf

nginx -s reload
