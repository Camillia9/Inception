*This project has been created as part of the 42 curriculum by camansou*

# Developer Documentation

## Prerequisites

- Debian 11 or Ubuntu 22.04
- Docker Engine (version 20.10+)
- Docker Compose plugin (version 2.0+)
- Make
- At least 2 GB of RAM and 30 GB of disk space

## Setting up the environment

### Install Docker

```bash
# Dependencies
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add the user to the docker group
sudo usermod -aG docker $USER
```

### Initial configuration

```bash
# Create the data directories (also done by `make build`)
mkdir -p ~/data/mariadb
mkdir -p ~/data/wordpress

# Point the domain name to the VM
echo "127.0.0.1 camansou.42.fr" | sudo tee -a /etc/hosts
```

Then create `srcs/.env` with the variables listed in [README.md](README.md#configuration). This file contains the credentials and must never be committed (it is listed in `.gitignore`).

## Using the Makefile

```bash
make        # Build and start
make build  # Build only
make up     # Start only
make down   # Stop
make clean  # Stop + remove containers and Docker volumes
make fclean # Full cleanup (images + data)
make re     # Full rebuild
make logs   # Live logs
make status # Container status
```

## Docker Compose commands

```bash
# Start
docker compose -f srcs/docker-compose.yml up -d

# Stop
docker compose -f srcs/docker-compose.yml down

# Logs
docker compose -f srcs/docker-compose.yml logs -f

# Rebuild
docker compose -f srcs/docker-compose.yml build

# Status
docker compose -f srcs/docker-compose.yml ps
```

## Managing the containers

```bash
# Open a shell in a container
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash

# Logs of a service
docker logs nginx
docker logs wordpress
docker logs mariadb

# Inspect
docker inspect nginx
docker inspect wordpress
docker inspect mariadb
```

## Data persistence

### Locations

- **MariaDB:** `/home/login/data/mariadb`
- **WordPress:** `/home/login/data/wordpress`

### Strategy

The project uses **named volumes** with the `local` driver and the `bind` option: Docker manages the volumes, but their data is stored in a known directory of the host.

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/login/data/mariadb
```

**Lifecycle:**
- `make down`: containers removed, data **kept**
- `make clean`: containers and Docker volumes removed, but the files in `/home/login/data` are **kept** (the volumes are only references to these directories)
- `make fclean`: data **deleted** + images and Docker cache removed

### Checks

```bash
# List the volumes
docker volume ls

# Inspect a volume
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data

# Volume contents
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

## Debugging

### A container does not start

```bash
docker logs <container_name>
docker inspect <container_name>
```

### Network issues

```bash
docker network inspect inception_network
docker exec -it wordpress ping mariadb
docker exec -it nginx ping wordpress
```

### Volume issues

```bash
docker volume ls
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

### Database

```bash
# Connect to MariaDB
docker exec -it mariadb mysql -u wp_user -p -D wordpress_db

# Check the tables
SHOW TABLES;

# Check the WordPress users
SELECT * FROM wp_users;
```

### WordPress

```bash
# WP-CLI info
docker exec -it wordpress wp --info --allow-root

# List the users
docker exec -it wordpress wp user list --allow-root

# Check the configuration
docker exec -it wordpress wp config get --allow-root
```

## Dockerfiles overview

### NGINX

- **Base:** Alpine Linux
- **Port:** 443 (HTTPS)
- **SSL:** self-signed certificate generated at startup
- **Config:** forwards PHP requests to WordPress (FastCGI)

### WordPress

- **Base:** Debian Bullseye
- **Port:** 9000 (PHP-FPM)
- **Installation:** automatic with WP-CLI
- **Users:** 2 created at startup

### MariaDB

- **Base:** Debian Bullseye
- **Port:** 3306 (internal only)
- **Initialization:** bash script on the first start
- **Persistence:** named volume

## Docker network

**Type:** bridge network (`inception_network`)

**Advantages:**
- Isolation of the services
- Automatic DNS by container name
- Security (no exposure on the host network)

**Checks:**
```bash
docker network ls
docker network inspect inception_network
```
