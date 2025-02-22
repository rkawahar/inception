FROM debian:11

RUN apt-get update && apt-get install -y openssl nginx curl vim sudo

# デフォルト設定を削除
# RUN rm -f /etc/nginx/conf.d/default.conf
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -x509 -nodes -days 365 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=JP/ST=Tokyo/L=Shinjuku/O=42/OU=rkawahar/CN=rkawahar.42.fr" \
    -newkey rsa:2048 && \
    ls -l /etc/nginx/ssl 

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

CMD ["nginx", "-g", "daemon off;"]