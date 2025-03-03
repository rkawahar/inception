D_C=docker compose
D_C_FILE = ./srcs/docker-compose.yml

all: build up

up: 
	mkdir -p /home/rkawahar/data/html
	mkdir -p /home/rkawahar/data/mariadb
	chmod -R 755 /home/rkawahar/data/html
	chmod -R 755  /home/rkawahar/data/mariadb
	$(D_C) -f $(D_C_FILE) up

build:
	$(D_C) -f $(D_C_FILE) build --no-cache

down:
	$(D_C) -f $(D_C_FILE) down

clean:
	sudo rm -rf  /home/rkawahar/data/mariadb
	sudo rm -rf /home/rkawahar/data/html
	docker rmi wordpress mariadb nginx

.PHONY: up build down clean
