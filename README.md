# SSL Proxy

Reverse proxy that allows enabling the HTTPS protocol using the free certificates offered by https://letsencrypt.org/
through its certbot tool.

## Get Started

The easiest way to use this docker image is to set up a docker-compose.
To do this, just enter the following environment variables:

- __PROXY_DOMAIN__ : Enter the domain the proxy will respond to.
- __PROXY_EMAIL__ : Email used in the registry of letsencrypt required to get the free certificate.
- __PROXY_PASS__ : Server to which the proxy will pass the requests.

Then, if you want to save the certificates (highly recommended), simply map the volumes:

- /etc/letsencrypt
- /etc/ssl

#### docker-compose.yml

```yml
version: '3'
services:
  myproxy:
    image: azinformatica/ssl-proxy:latest
    ports:
      - "80:80"
      - "443:443"
    environment:
      - PROXY_DOMAIN=rapizap.com
      - PROXY_EMAIL=myemail@gmail.com
      - PROXY_PASS=myapp
    volumes:
      - "./mybackup/letsencrypt/:/etc/letsencrypt/"
      - "./mybackup/ssl/:/etc/ssl/"
    networks:
      - mynet
  myapp:
    image: nginx:alpine
    networks:
      - mynet
networks:
  mynet:

```

Finally, do not forget to release ports 80 and 443.

