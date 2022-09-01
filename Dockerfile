FROM openresty/openresty:1.21.4.1-3-bullseye

USER root

RUN apt-get update && apt-get install -y python3 python3-pip wget supervisor dnsutils cron \
    && pip3 install --upgrade pip \
    && pip3 install awscli \
    && apt-get remove -y python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY files/startup.sh files/renew_token.sh files/health-check.sh /
COPY files/ecr.ini /etc/supervisor/conf.d/ecr.ini
COPY files/root /etc/cron.d/root

COPY files/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY files/ssl.conf /usr/local/openresty/nginx/conf/ssl.conf

ENV PORT 5000
ENV AWS_SDK_LOAD_CONFIG true

RUN useradd --system --user-group --shell /usr/sbin/nologin --create-home --home /cache nginx \
    && chmod a+x /startup.sh /renew_token.sh \
    && chmod 0644 /etc/cron.d/root \
    && crontab /etc/cron.d/root

HEALTHCHECK --interval=5s --timeout=5s --retries=3 CMD /health-check.sh

ENTRYPOINT ["/startup.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/conf.d/ecr.ini"]
