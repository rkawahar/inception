D_C		= docker compose
D_C_FILE	= docker-compose.yml
SRCS		= srcs

all: prepare build up

prepare:
	@if [ -f $(SRCS)/.env ]; then \
		. $(SRCS)/.env 2>/dev/null; \
		mkdir -p "$${HOST_DATA_PATH}/mariadb" "$${HOST_DATA_PATH}/wordpress"; \
		chmod -R 755 "$${HOST_DATA_PATH}/mariadb" "$${HOST_DATA_PATH}/wordpress" 2>/dev/null || true; \
	fi

up: prepare
	cd $(SRCS) && $(D_C) -f $(D_C_FILE) up -d

build:
	cd $(SRCS) && $(D_C) -f $(D_C_FILE) build --no-cache

down:
	cd $(SRCS) && $(D_C) -f $(D_C_FILE) down

clean: down
	cd $(SRCS) && $(D_C) -f $(D_C_FILE) down -v
	docker rmi nginx wordpress mariadb 2>/dev/null || true

re: clean build up

.PHONY: all prepare up build down clean re
