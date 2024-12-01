#!/bin/sh

set -e
set +x

source /etc/environment

echo 'Using identity:'
aws sts get-caller-identity

# update the auth token
CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
AUTH=$(grep  X-Forwarded-User $CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")

# retry till new get new token
while true; do
  TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
  [ ! -z "${TOKEN}" ] && break
  echo "Warn: Unable to get new token, wait and retry!"
  sleep 30
done

AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")
sed -i "s|${AUTH%??}|${AUTH_N}|g" $CONFIG

if [ "$1" == "reload" ]; then
  echo "Reloading nginx"
  nginx -s reload
fi
