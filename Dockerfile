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

WORKDIR /opt/proxy
CMD ./startup.sh
