FROM debian:12

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssl \
    nginx \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ARG DOMAIN_NAME=localhost
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=JP/ST=Tokyo/L=Tokyo/O=42/OU=inception/CN=${DOMAIN_NAME}" \
    -newkey rsa:2048

COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./tools/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/entrypoint.sh"]