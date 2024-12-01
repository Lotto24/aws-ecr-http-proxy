FROM openresty/openresty:1.21.4.1-0-alpine

USER root

RUN apk add -v --no-cache bind-tools python3 py-pip py3-urllib3 py3-colorama supervisor
RUN mkdir /cache
RUN mkdir /etc/crontab
RUN addgroup -g 110 nginx && adduser -u 110  -D -S -h /cache -s /sbin/nologin -G nginx nginx
RUN pip install --upgrade pip awscli==1.34.21

COPY scripts/startup.sh /
COPY scripts/renew_token.sh /
COPY config/supervisord/programs.ini /etc/supervisor.d/programs.ini

COPY config/nginx/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY config/nginx/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf

ENV PORT 5000
RUN chmod a+x /startup.sh /renew_token.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
