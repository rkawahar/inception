#!/bin/bash

sleep 10

if [ ! -f "/var/www/html/wp-config.php" ]; then
    cd /var/www/html
    
    wp core download --allow-root

    wp config create --dbhost=mariadb:3306 \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --allow-root

    wp core install --url=$DOMAIN_NAME/ \
        --title=Wordpress \
        --admin_user=$WP_SUPERUSER \
        --admin_password=$WP_SUPERUSER_PASSWORD \
        --admin_email=$WP_SUPERUSER_EMAIL \
        --skip-email --allow-root
    
    wp user create $WP_USER $WP_USER_EMAIL \
        --role=author \
        --user_pass=$WP_USER_PASSWORD \
        --allow-root
fi

# If SITE_URL is set (e.g. https://domain:8443 for a custom port), update WordPress URLs
if [ -n "$SITE_URL" ]; then
    cd /var/www/html
    wp option update home "$SITE_URL" --allow-root 2>/dev/null || true
    wp option update siteurl "$SITE_URL" --allow-root 2>/dev/null || true
fi

/usr/sbin/php-fpm8.2 -F
