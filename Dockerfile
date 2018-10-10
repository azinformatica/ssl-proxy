FROM nginx:alpine

RUN apk add --update --no-cache \
    curl \
    bash \
    openssl \
    certbot \
    python \
    py-pip \
    && pip install --upgrade pip \
    && pip install 'certbot-nginx' \
    && pip install 'pyopenssl'

RUN mkdir -p /opt/proxy /etc/letsencrypt/live /etc/ssl/certs \
    && rm -f /etc/nginx/conf.d/default.conf

COPY files/index.html /usr/share/nginx/html/index.html
COPY files/ssl.template /etc/nginx/conf.d/ssl.template
COPY files/nossl.template /etc/nginx/conf.d/nossl.template

COPY files/startup.sh /opt/proxy/startup.sh
RUN chmod +x /opt/proxy/startup.sh

# adds certbot cert renewal job to cron
COPY files/crontab /tmp/crontab-certbot
RUN (crontab -l; cat /tmp/crontab-certbot) | crontab -

WORKDIR /opt/proxy
CMD ./startup.sh
