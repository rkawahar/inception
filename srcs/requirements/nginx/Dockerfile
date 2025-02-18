FROM debian:bullseye

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y nginx openssl curl

RUN mkdir -p /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=JP/ST=Tokyo/L=Shinjuku/O=42Tokyo/OU=42Student/CN=rkawahar.42.jp/UID=rkawahar"

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

ENTRYPOINT ["nginx", "-g", "daemon off;"]