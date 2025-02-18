FROM debian:bullseye

RUN apt update -y && apt upgrade -y
RUN apt-get install -y curl php php7.4-fpm php-mysql php-curl php-gd php-mbstring php-xml php-zip default-mysql-client

COPY ./conf/script.sh /

RUN chmod +x /script.sh

ENTRYPOINT ["/script.sh"]