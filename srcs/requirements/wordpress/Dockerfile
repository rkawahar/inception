FROM debian:11

RUN apt-get update && apt-get install -y \
    apt-transport-https \
    lsb-release \
    ca-certificates \
    wget \
    gnupg2

RUN wget -qO- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list

RUN apt-get update && apt-get install -y \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    && apt-get clean

RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

RUN mkdir -p /run/php

RUN mkdir -p /var/www/html
RUN chown -R www-data:www-data /var/www/html

COPY ./tools/init.sh ./
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

RUN chmod +x /init.sh

ENTRYPOINT ["sh", "/init.sh"]