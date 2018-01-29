#!/bin/sh

set -e
set -x

if [ -z "$UPSTREAM" ] ; then
  echo "UPSTREAM not set."
  exit 1
fi

if [ -z "$PORT" ] ; then
  echo "PORT not set."
  exit 1
fi

if [ -z "$RESOLVER" ] ; then
  echo "RESOLVER not set."
  exit 1
fi

if [ -z "$AWS_REGION" ] ; then
  echo "AWS_REGION not set."
  exit 1
fi

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "AWS_ACCESS_KEY_ID or AWS_SECRET_ACCESS_KEY not set."
  exit 1
fi

UPSTREAM_WITHOUT_PORT=$( echo ${UPSTREAM} | sed -r "s/.*:\/\/(.*):.*/\1/g")
echo Using resolver $RESOLVER and $UPSTREAM [$(dig +short  ${UPSTREAM_WITHOUT_PORT})] as upstream.

CACHE_MAX_SIZE=${CACHE_MAX_SIZE:-75g}
echo Using cache max size $CACHE_MAX_SIZE

CONFIG=/usr/local/openresty/nginx/conf/nginx.conf

# Update nginx config
sed -i -e s!UPSTREAM!"$UPSTREAM"!g $CONFIG
sed -i -e s!PORT!"$PORT"!g $CONFIG
sed -i -e s!RESOLVER!"$RESOLVER"!g $CONFIG
sed -i -e s!CACHE_MAX_SIZE!"$CACHE_MAX_SIZE"!g $CONFIG

# setup ~/.aws directory
AWS_FOLDER='/root/.aws'
mkdir -p ${AWS_FOLDER}
echo "[default]" > ${AWS_FOLDER}/config
echo "region = $AWS_REGION" >> ${AWS_FOLDER}/config
echo "[default]" > ${AWS_FOLDER}/credentials
echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> ${AWS_FOLDER}/credentials
echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> ${AWS_FOLDER}/credentials
chmod 600 -R ${AWS_FOLDER}

# add the auth token in default.conf
AUTH=$(grep  X-Forwarded-User $CONFIG | awk '{print $4}'| uniq|tr -d "\n\r")
TOKEN=$(aws ecr get-login --no-include-email | awk '{print $6}')
AUTH_N=$(echo AWS:${TOKEN}  | base64 |tr -d "[:space:]")
sed -i "s|${AUTH%??}|${AUTH_N}|g" $CONFIG

exec "$@"
