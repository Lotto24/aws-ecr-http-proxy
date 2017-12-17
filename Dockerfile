FROM openresty/openresty:1.13.6.1-alpine
USER root

RUN apk add -v --no-cache bind-tools python py-pip supervisor \
 && mkdir /cache \
 && addgroup -g 101 nginx \
 && adduser -u 100  -D -S -h /cache -s /sbin/nologin -G nginx nginx \
 && pip install --upgrade pip awscli==1.11.183 \
 && apk -v --purge del py-pip

COPY files/startup.sh files/renew_token.sh /
COPY files/ecr.ini /etc/supervisor.d/ecr.ini
COPY files/root /etc/crontabs/root

COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

ENV PORT 5000

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
