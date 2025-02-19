WP_PATH = /home/rkawahar/data/wp
DB_PATH = /home/rkawahar/data/db

all: up

up:
	@sudo mkdir -p $(WP_PATH)
	@sudo mkdir -p $(DB_PATH)
	@sudo chmod -R 777 $(WP_PATH)
	@sudo chmod -R 777 $(DB_PATH)
	docker-compose -f srcs/docker-compose.yml up

build:
	docker-compose -f srcs/docker-compose.yml build

down:
	docker-compose -f srcs/docker-compose.yml down

stop:
	docker-compose -f srcs/docker-compose.yml stop

volumerm:
	@sudo rm -rf $(WP_PATH)
	@sudo rm -rf $(DB_PATH)
	docker volume rm wordpress
	docker volume rm mariadb

clean:
	docker rmi wordpress mariadb nginx

reset:
	docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null

# docker exec -it mariadb mysql -u root
# show databases;