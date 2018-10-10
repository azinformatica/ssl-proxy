#!/bin/bash

function start {
    createNoSslNginxConf
    startNginxInBackground
    enableSsl
    createSslNginxConf
    stopNginx
    startNginxInForeground
}

function enableSsl {
    if [[ -d "/etc/letsencrypt/live/${PROXY_DOMAIN}" ]]; then
        renewSslCertificate
    else
        createSslCertificate
        createSslDhparam
    fi
}

function renewSslCertificate {
    echo "Renew SSL certificate with certbot"
    certbot renew --quiet
}

function createSslCertificate {
    if ! [[ -d "/etc/letsencrypt/live/${PROXY_DOMAIN}" ]]; then
        echo "Creating SSL certificate with certbot"
        certbot --nginx certonly -m $PROXY_EMAIL --agree-tos --no-eff-email --redirect --expand -d $PROXY_DOMAIN
    fi
}

function createNoSslNginxConf {
    if [ ! -f /etc/nginx/conf.d/nossl.conf ] && [ ! -f /etc/nginx/conf.d/ssl.conf ]; then
        echo "Creating nginx configuration file (nossl.conf)"
        envsubst '${PROXY_DOMAIN} ${PROXY_PASS}' < /etc/nginx/conf.d/nossl.template > /etc/nginx/conf.d/nossl.conf
        printFile /etc/nginx/conf.d/nossl.conf
    fi
}

function createSslNginxConf {
    if  [ ! -f /etc/nginx/conf.d/ssl.conf ]; then
        echo "Creating nginx configuration file (ssl.conf)"
        envsubst '${PROXY_DOMAIN} ${PROXY_PASS}' < /etc/nginx/conf.d/ssl.template > /etc/nginx/conf.d/ssl.conf
        printFile /etc/nginx/conf.d/ssl.conf
        removeNoSslNginConf
    fi
}

function removeNoSslNginConf {
    if [ -f /etc/nginx/conf.d/nossl.conf ]; then
        rm -f /etc/nginx/conf.d/nossl.conf
    fi
}

function createSslDhparam {
    if ! [[ -f "/etc/ssl/certs/dhparam.pem" ]]; then
        echo "Creating a public key"
        openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
    fi
}

function printFile {
    echo "Created content: "
    echo ""
    cat $1
    echo ""
}

function startNginxInBackground {
    echo "Starting nginx in background"
    nginx -g 'daemon on;'
}

function startNginxInForeground {
    echo "Starting nginx in foreground"
    nginx -g 'daemon off;'
}

function stopNginx {
    echo "Stop nginx"
    nginx -s stop
    sleep 5
}

start