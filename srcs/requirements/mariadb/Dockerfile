FROM debian:11

RUN apt-get update && apt-get install -y mariadb-server mariadb-client

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/init.sh ./

RUN chmod +x ./init.sh

ENTRYPOINT ["sh", "/init.sh"]
