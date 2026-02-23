# Inception — User documentation

This document explains how to use the Inception stack as an end user or administrator.

## Services provided by the stack

The stack exposes a single service to you:

- **Website**: A WordPress site served over HTTPS. You can browse pages and, if you have an account, log in to create and manage content.

Behind the scenes, three containers run:

- **NGINX**: Handles HTTPS (port 443) and forwards requests to WordPress.
- **WordPress + PHP-FPM**: Runs the WordPress application.
- **MariaDB**: Stores the WordPress database (posts, users, settings).

You do not need to manage these containers directly; the Makefile and Docker Compose do that.

---

## Starting and stopping the project

- **Start the stack** (after a first-time setup; see DEV_DOC.md):
  ```bash
  make up
  ```
  Or, from scratch: `make` (prepare, build, then up).

- **Stop the stack**:
  ```bash
  make down
  ```
  This stops and removes the containers. Your data (database and WordPress files) stays in the host directories under `/home/<your_login>/data/`.

---

## Accessing the website and admin panel

1. Ensure your domain (e.g. `yourlogin.42.fr`) points to the machine (e.g. in `/etc/hosts`: `127.0.0.1 yourlogin.42.fr`).

2. Open in a browser: **https://yourlogin.42.fr**  
   (Use your actual domain from `srcs/.env`.)

3. Accept the self-signed certificate warning if your browser shows it.

4. **Public site**: The homepage and public pages are at that URL.

5. **WordPress admin panel**:  
   - URL: **https://yourlogin.42.fr/wp-admin**  
   - Log in with the **administrator** account (username and password set in `srcs/.env`: `WP_SUPERUSER`, `WP_SUPERUSER_PASSWORD`).  
   - The second user (e.g. author) is defined by `WP_USER` and `WP_USER_PASSWORD` in `.env`.

---

## Identifying and managing credentials

- All credentials and paths are in **`srcs/.env`** (do not commit this file).

- Main values you may need:
  - **Domain**: `DOMAIN_NAME` (e.g. `yourlogin.42.fr`).
  - **WordPress administrator**: `WP_SUPERUSER`, `WP_SUPERUSER_PASSWORD`, `WP_SUPERUSER_EMAIL`.
  - **WordPress second user**: `WP_USER`, `WP_USER_PASSWORD`, `WP_USER_EMAIL`.
  - **Database**: `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `MYSQL_DATABASE`.

- To change passwords or users: edit `srcs/.env`, then recreate the containers (and if needed re-run WordPress setup). For a full reset you can use `make re` (see DEV_DOC.md).

- Keep `.env` only on your machine and never commit it. Credentials stored in the repo lead to project failure.

---

## Checking that services are running correctly

1. **Containers**
   ```bash
   docker ps
   ```
   You should see three running containers: `nginx`, `wordpress`, `mariadb`.

2. **Website**
   - Open **https://yourlogin.42.fr** in a browser. The WordPress site should load (or the WordPress install wizard on first run).

3. **Logs** (if something is wrong)
   ```bash
   cd srcs && docker compose logs -f
   ```
   Or per service: `docker compose logs -f nginx`, `wordpress`, `mariadb`.

4. **Stopped or exited containers**
   ```bash
   docker ps -a
   ```
   If a container is Exited, check logs and `srcs/.env` (e.g. wrong password or path).
