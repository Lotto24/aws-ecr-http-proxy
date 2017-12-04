FROM nginx:1.13.7-alpine
USER root

RUN apk add -v --no-cache \
            bind-tools \
            python \
            py-pip \
            supervisor \
          && mkdir /cache \
          && pip install --upgrade pip awscli==1.11.183 \
          && apk -v --purge del py-pip

COPY files/startup.sh files/renew_token.sh /
COPY files/default.conf /etc/nginx/conf.d/
COPY files/ecr.ini /etc/supervisor.d/ecr.ini
COPY files/root /etc/crontabs/root

ENV PORT 5000

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
