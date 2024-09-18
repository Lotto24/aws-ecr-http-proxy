#!/bin/sh

set -e
set +x

if [ -z "$ECR" ] ; then
  echo "ECR not set."
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

ECR_WITHOUT_PORT=$( echo ${ECR} | sed -r "s/.*:\/\/(.*):.*/\1/g")
echo Using resolver $RESOLVER and $ECR [$(dig +short  ${ECR_WITHOUT_PORT})] as upstream.

CACHE_MAX_SIZE=${CACHE_MAX_SIZE:-75g}
echo Using cache max size $CACHE_MAX_SIZE

CACHE_KEY=${CACHE_KEY:='$uri'}
echo Using cache key $CACHE_KEY

SCHEME=http
CONFIG=/usr/local/openresty/nginx/conf/nginx.conf
SSL_CONFIG=/usr/local/openresty/nginx/conf/ssl.conf

if [ "$ENABLE_SSL" ] && [ "$ENABLE_SSL" == "true" ]; then
  sed -i -e s!__SSL_KEY__!"$SSL_KEY"!g $SSL_CONFIG
  sed -i -e s!__SSL_CERTIFICATE__!"$SSL_CERT"!g $SSL_CONFIG
  SSL_LISTEN="ssl"
  SSL_INCLUDE="include $SSL_CONFIG;"
  SCHEME="https"
fi

# Update nginx config
sed -i -e s!__ECR__!"$ECR"!g $CONFIG
sed -i -e s!__PORT__!"$PORT"!g $CONFIG
sed -i -e s!__RESOLVER__!"$RESOLVER"!g $CONFIG
sed -i -e s!__CACHE_MAX_SIZE__!"$CACHE_MAX_SIZE"!g $CONFIG
sed -i -e s!__CACHE_KEY__!"$CACHE_KEY"!g $CONFIG
sed -i -e s!__SCHEME__!"$SCHEME"!g $CONFIG
sed -i -e s!__SSL_INCLUDE__!"$SSL_INCLUDE"!g $CONFIG
sed -i -e s!__SSL_LISTEN__!"$SSL_LISTEN"!g $CONFIG


ECR_REGION=$(echo $ECR | sed -r "s/.*:\/\/.*\.(.*)\.amazonaws\.com/\1/g")

if [ -z "$AWS_DEFAULT_REGION" ]; then
    export AWS_DEFAULT_REGION=$ECR_REGION
    echo "AWS_DEFAULT_REGION was not set. Setting it to $ECR_REGION from ECR endpoint"
fi

env |grep AWS > /etc/environment

# get token for the first time
/renew_token.sh

chown -R nginx:nginx /cache

RENEW_INTERVAL_HOURS=${RENEW_INTERVAL_HOURS:-6}

echo "0       */$RENEW_INTERVAL_HOURS     *       *       *       /renew_token.sh reload" > /etc/crontab/root

exec "$@"
