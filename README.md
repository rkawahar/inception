*This project has been created as part of the 42 curriculum by \<login\>.*

# Inception

## Description

Inception is a system administration and DevOps project that introduces Docker and Docker Compose. The goal is to set up a small infrastructure made of several services under specific rules: each service runs in its own container, each image is built from a Dockerfile (no pre-made images from Docker Hub except the base OS), and the stack is orchestrated with Docker Compose.

The stack consists of:

- **NGINX**: TLS termination only (port 443), supporting TLSv1.2 and TLSv1.3. It is the single entry point to the infrastructure.
- **WordPress + php-fpm**: WordPress with PHP-FPM, no NGINX inside this container. Serves the application to NGINX over port 9000.
- **MariaDB**: Database only, no NGINX. Listens on 3306 inside the Docker network.

Two named volumes persist the WordPress database and website files; both store data on the host under `/home/<login>/data` as required. A custom bridge network connects the three containers.

## Instructions

### Prerequisites

- Docker and Docker Compose installed on the machine (or VM).
- Your 42 intra login for domain and paths.

### Setup

1. **Clone the repository** and go to the project root.

2. **Configure environment variables**
   - Copy the example env file: `cp srcs/env.example srcs/.env`
   - Edit `srcs/.env` and set:
     - `DOMAIN_NAME` to your `login.42.fr`
     - `HOST_DATA_PATH` to `/home/<your_login>/data`
     - All passwords and the WordPress administrator username (must not contain "admin" or "administrator").

3. **Prepare host directories**  
   Running `make` will create the volume directories from `HOST_DATA_PATH` in `.env`. Alternatively create them manually:
   ```bash
   mkdir -p /home/<your_login>/data/mariadb /home/<your_login>/data/wordpress
   chmod -R 755 /home/<your_login>/data
   ```

4. **Hosts file**  
   Point your domain to the machine:
   - Add a line such as: `127.0.0.1   <your_login>.42.fr` in `/etc/hosts` (or use your VM’s IP instead of 127.0.0.1).

5. **Build and run**
   ```bash
   make
   ```
   Or step by step: `make build` then `make up`.

6. **Access**
   - Website: `https://<your_login>.42.fr` (accept the self-signed certificate in the browser).
   - Containers run in the background; use `make down` to stop them.

### Makefile targets

| Target   | Description                    |
|----------|--------------------------------|
| `make`   | prepare, build, then up        |
| `make up`| Start containers (after build) |
| `make build` | Build all images (no cache) |
| `make down`  | Stop and remove containers |
| `make clean` | down, remove volumes, remove built images |
| `make re`    | clean, then build, then up  |

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX](https://nginx.org/en/docs/)
- [WordPress](https://wordpress.org/support/)
- [MariaDB](https://mariadb.com/kb/en/documentation/)

### AI usage

AI was used to structure the README, align the project with the subject (e.g. volume paths, image names, restart policy), and draft USER_DOC.md and DEV_DOC.md. Implementation and design choices (Dockerfiles, nginx/php/mariadb config, Makefile) were done to match the Inception subject and PDF requirements.

---

## Project description (Docker)

The project uses Docker and Docker Compose to run NGINX, WordPress (with PHP-FPM), and MariaDB in separate containers. Each service has its own Dockerfile under `srcs/requirements/<service>/`. The Makefile invokes `docker compose` in `srcs/` so that `docker-compose.yml` and `.env` are used from there. No pre-built application images are used; only the base image (e.g. Debian) is pulled, and the rest is built locally.

### Design choices and comparisons

**Virtual Machines vs Docker**  
Virtual machines run a full OS on a hypervisor and are heavier and slower to start. Docker containers share the host kernel and use namespaces and cgroups for isolation; they start quickly and use fewer resources. For this project, containers are enough to isolate each service (NGINX, WordPress, MariaDB) and are easier to rebuild and replicate than VMs.

**Secrets vs Environment Variables**  
Environment variables are required by the subject and are used via a `.env` file (not committed). They are suitable for this scope. Docker Secrets would be preferable in production: they are stored in the swarm and mounted as files in the container, reducing exposure in process lists and logs. For Inception, `.env` is the mandatory mechanism; storing credentials only in `.env` (and optionally in local files under `secrets/` ignored by git) avoids failure due to publicly stored credentials.

**Docker Network vs Host Network**  
The project uses a user-defined bridge network (`inception`). Containers resolve each other by service name (e.g. `wordpress`, `mariadb`) and only NGINX exposes port 443 to the host. Using `network_mode: host` would remove network isolation and make services listen directly on the host; it is forbidden by the subject. The bridge network keeps isolation and predictable service discovery.

**Docker Volumes vs Bind Mounts**  
The subject requires *named* Docker volumes for the WordPress database and website files. Here, those named volumes are configured with `driver_opts` so that data is stored on the host under `/home/<login>/data` (mariadb and wordpress subdirs), as specified. So we use named volumes that bind to a fixed host path for persistence and compliance. Plain bind mounts (e.g. `volumes: - /path/on/host:/path/in/container`) are not used for these two volumes, in line with the requirement.
