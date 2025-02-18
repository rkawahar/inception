#!/bin/bash

# 環境変数の確認
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$DOMAIN_NAME" ] || [ -z "$WP_TITLE" ] || [ -z "$WP_ADMIN_USR" ] || [ -z "$WP_ADMIN_PWD" ] || [ -z "$WP_ADMIN_EMAIL" ]; then
    echo "Error: 必要な環境変数が設定されていません。スクリプトを終了します。"
    exit 1
fi

# 必要なディレクトリの作成
mkdir -p /var/www
mkdir -p /var/www/html

# WordPress CLI のインストール
cd /var/www/html
if [ ! -f "/usr/local/bin/wp" ]; then
    echo "Installing WP-CLI..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
else
    echo "WP-CLI is already installed."
fi

# MariaDB が準備完了するまで待機
MAX_RETRIES=30
RETRY_COUNT=0
echo "Waiting for MariaDB to be ready..."
while ! mysqladmin ping -h mariadb --silent; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Error: MariaDB is not ready after $MAX_RETRIES retries. Exiting."
        exit 1
    fi
    echo "MariaDB is not ready yet. Retrying... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done
echo "MariaDB is ready."

# 既存の wp-config.php を削除
if [ -f "/var/www/html/wp-config.php" ]; then
    echo "wp-config.php ファイルが見つかりました。削除します。"
    rm "/var/www/html/wp-config.php"
    sleep 2
else
    echo "wp-config.php ファイルが見つかりませんでした。"
fi

# WordPress ファイルのダウンロード
if [ ! -f "/var/www/html/wp-settings.php" ]; then
    echo "Downloading WordPress core files..."
    wp core download --allow-root
else
    echo "WordPress ファイルは既に存在しています。ダウンロードをスキップします。"
fi

# wp-config.php の作成
echo "Creating wp-config.php..."
wp config create --dbhost=mariadb:3306 --dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" --dbpass="$MYSQL_PASSWORD" --allow-root
if [ $? -ne 0 ]; then
    echo "Error: wp-config.php の作成に失敗しました。スクリプトを終了します。"
    exit 1
fi

# WordPress の初期セットアップ
echo "Running WordPress installation..."
wp core install --url="$DOMAIN_NAME/" --title="$WP_TITLE" --admin_user="$WP_ADMIN_USR" --admin_password="$WP_ADMIN_PWD" --admin_email="$WP_ADMIN_EMAIL" --skip-email --allow-root
if [ $? -ne 0 ]; then
    echo "Error: WordPress の初期セットアップに失敗しました。スクリプトを終了します。"
    exit 1
fi

# PHP-FPM ソケット設定の変更
if [ -f "/etc/php/7.4/fpm/pool.d/www.conf" ]; then
    echo "Modifying PHP-FPM socket settings..."
    sed -i 's@/run/php/php7.4-fpm.sock@9000@' /etc/php/7.4/fpm/pool.d/www.conf
    echo "PHP-FPMの設定を修正しました。"
else
    echo "Warning: PHP-FPMの設定ファイルが見つかりませんでした。スキップします。"
fi

# PHP-FPM のランタイムディレクトリを作成
mkdir -p /run/php

# PHP-FPM をフォアグラウンドで起動
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F