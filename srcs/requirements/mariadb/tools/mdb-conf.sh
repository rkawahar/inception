#!/bin/bash


# 必要なディレクトリを確認し、初期化を実行
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mysqld --initialize-insecure --user=mysql --datadir=/var/lib/mysql
    chown -R mysql:mysql /var/lib/mysql
fi

# MariaDBを安全に起動
echo "Starting MariaDB..."
# service mariadb start
exec mysqld_safe --datadir="/var/lib/mysql"
sleep 10
echo "unkoooo\n"
# MariaDBの起動を待機（30秒間リトライ）
MAX_RETRIES=30
RETRY_COUNT=0
until mysqladmin ping --socket=/run/mysqld/mysqld.sock --silent; do
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "Error: MariaDB did not become ready in time. Exiting."
        exit 1
    fi
    echo "Waiting for MariaDB to be ready... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
done

# 初期設定
echo "Configuring MariaDB..."
mysql -u root --skip-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'wordpress.inception' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'wordpress.inception';"
mysql -u root --password="${MYSQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

# MariaDBをフォアグラウンドで起動
exec mysqld_safe --datadir="/var/lib/mysql"