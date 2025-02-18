FROM debian:bullseye

RUN apt update -y && apt upgrade -y
RUN apt install mariadb-server -y
RUN mkdir -p /var/log/mysql

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/mdb-conf.sh /mdb-conf.sh
RUN chmod +x /mdb-conf.sh
RUN mkdir -p /run/mysqld
RUN chown -R mysql:mysql /run/mysqld && chmod 777 /run/mysqld

CMD ["/mdb-conf.sh"]