D_C=docker compose
D_C_FILE = ./srcs/docker-compose.yml

all: build up

up: 
	mkdir -p /Users/kawaharadaryou/Documents/c/rkawahar/data/html
	mkdir -p /Users/kawaharadaryou/Documents/c/rkawahar/data/mariadb
	chmod -R 755 /Users/kawaharadaryou/Documents/c/rkawahar/data/html
	chmod -R 755 /Users/kawaharadaryou/Documents/c/rkawahar/data/mariadb
	$(D_C) -f $(D_C_FILE) up

build:
	$(D_C) -f $(D_C_FILE) build --no-cache

down:
	$(D_C) -f $(D_C_FILE) down

clean:
	rm -rf ~/data/html
	rm -rf ~/data/mariadb
	docker rmi wordpress mariadb nginx

.PHONY: up build down clean
