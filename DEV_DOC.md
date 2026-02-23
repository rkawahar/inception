# Inception — Developer documentation

This document describes how to set up the development environment, build and run the project, and manage containers and data.

## Prerequisites

- **Docker** and **Docker Compose** installed.
- A 42 intra **login** (used for domain and host paths).
- (Optional) A VM or machine where `/home/<login>/data` can be used for volume storage.

## Environment setup from scratch

### 1. Repository and directory layout

- Project root contains: `Makefile`, `README.md`, `USER_DOC.md`, `DEV_DOC.md`.
- **`srcs/`**: `docker-compose.yml`, `.env` (created by you), `env.example`, and `requirements/`.
- **`srcs/requirements/`**: One folder per service:
  - **`nginx/`**: `Dockerfile`, `conf/nginx.conf`, `tools/` if any.
  - **`wordpress/`**: `Dockerfile`, `conf/`, `tools/init.sh`.
  - **`mariadb/`**: `Dockerfile`, `conf/`, `tools/init.sh`.

### 2. Configuration and secrets

- **`srcs/.env`** (required): Copy from `srcs/env.example` and fill in every value.
  - **DOMAIN_NAME**: Your domain, e.g. `yourlogin.42.fr`.
  - **HOST_DATA_PATH**: Host path for volume data, e.g. `/home/yourlogin/data`.
  - **MariaDB**: `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`.
  - **WordPress**: `WP_SUPERUSER`, `WP_SUPERUSER_PASSWORD`, `WP_SUPERUSER_EMAIL` (admin; username must not contain "admin" or "administrator"), and `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL` (second user).

- **Secrets**: Do not put credentials in Dockerfiles or in the repo. Use only `srcs/.env` (and optionally local files under a `secrets/` directory that is gitignored). Public credentials = project failure.

### 3. Host preparation

- Create the directories used by the named volumes (or let `make prepare` do it using `HOST_DATA_PATH` from `.env`):
  ```bash
  mkdir -p /home/yourlogin/data/mariadb /home/yourlogin/data/wordpress
  chmod -R 755 /home/yourlogin/data
  ```
- Add your domain to `/etc/hosts`, e.g.:
  ```text
  127.0.0.1   yourlogin.42.fr
  ```

## Building and running with Makefile and Docker Compose

All commands below are run from the **project root** unless stated otherwise.

- **Full run** (prepare dirs, build, start):
  ```bash
  make
  ```

- **Build only** (no cache):
  ```bash
  make build
  ```
  This runs `docker compose build --no-cache` inside `srcs/`, so images `nginx`, `wordpress`, and `mariadb` are built from the Dockerfiles in `srcs/requirements/`.

- **Start containers**:
  ```bash
  make up
  ```
  Runs `docker compose up -d` in `srcs/`, so `srcs/.env` is loaded automatically.

- **Stop**:
  ```bash
  make down
  ```

- **Clean** (stop, remove containers, remove volumes, remove built images):
  ```bash
  make clean
  ```

- **Rebuild from zero and start**:
  ```bash
  make re
  ```

Docker Compose is always run from **`srcs/`** so that `docker-compose.yml` and `.env` are in the same directory.

## Managing containers and volumes

- **List containers**:
  ```bash
  docker ps -a
  ```

- **Logs** (from project root):
  ```bash
  cd srcs && docker compose logs -f
  ```
  Or: `docker compose -f srcs/docker-compose.yml logs -f` from root.

- **Restart a service** (from `srcs/`):
  ```bash
  cd srcs && docker compose restart nginx
  ```

- **Remove only containers** (keep volumes):
  ```bash
  cd srcs && docker compose down
  ```

- **Remove containers and volumes** (data under `HOST_DATA_PATH` is removed if those dirs are the volume targets):
  ```bash
  cd srcs && docker compose down -v
  ```

- **Rebuild one image** (e.g. nginx):
  ```bash
  cd srcs && docker compose build --no-cache nginx && docker compose up -d nginx
  ```

## Where project data is stored and how it is persisted

- **WordPress database**: Stored in the **mariadb_data** volume. On the host, data is under **`$HOST_DATA_PATH/mariadb`** (e.g. `/home/yourlogin/data/mariadb`) because the volume is defined with `driver_opts` and `device: ${HOST_DATA_PATH}/mariadb`.

- **WordPress files** (themes, uploads, etc.): Stored in the **wordpress_data** volume. On the host, data is under **`$HOST_DATA_PATH/wordpress`** (e.g. `/home/yourlogin/data/wordpress`).

- **Persistence**: As long as you do not run `make clean` (or `docker compose down -v`), the data in those directories remains. After `make clean` or `down -v`, the volume bindings are removed and the data in those paths may be left as-is or removed depending on how you clean; treat `make clean` as destructive for volume data.

- **Networking**: The three containers are on the same Docker network `inception`. Only the **nginx** container exposes port **443** to the host; WordPress and MariaDB are not published and are reached only via the internal network.
