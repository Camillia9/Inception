*This project has been created as part of the 42 curriculum by camansou.*

# Inception

A small web infrastructure built with **Docker Compose**: a WordPress website served over HTTPS by NGINX, backed by a MariaDB database. Each service runs in its own container, built from a custom Dockerfile.

```
                 HTTPS :443
  Browser ─────────────────────► ┌─────────┐
                                 │  NGINX  │  TLS 1.2 / 1.3, self-signed certificate
                                 └────┬────┘
                                      │ FastCGI :9000
                                 ┌────▼──────┐
                                 │ WordPress │  PHP-FPM + WP-CLI
                                 └────┬──────┘
                                      │ SQL :3306
                                 ┌────▼────┐
                                 │ MariaDB │
                                 └─────────┘
        inception_network (bridge) — only port 443 is exposed to the host

  Volumes:  wordpress_data → /home/camansou/data/wordpress  (WordPress + NGINX, read-only)
            mariadb_data   → /home/camansou/data/mariadb    (MariaDB)
```

## Description

The goal of Inception is to set up a small infrastructure of services inside a virtual machine, using Docker. The images are not pulled ready-made from Docker Hub: each one is built from a base OS image (Debian or Alpine) and configured by hand, which forces you to understand how each service works.

### Services

| Container | Base image | Role |
|---|---|---|
| `nginx` | Alpine 3.12 | Single entry point. Serves HTTPS only (port 443, TLS 1.2 and 1.3) and forwards PHP requests to WordPress through FastCGI |
| `wordpress` | Debian Bullseye | Runs PHP-FPM on port 9000. WordPress is installed and configured automatically with WP-CLI, with one administrator and one regular user |
| `mariadb` | Debian Bullseye | Stores the WordPress database. Initialized by a script on the first start only |

### Use of Docker and project sources

```
.
├── Makefile                      # build, up, down, clean, fclean, re, logs, status
├── USER_DOC.md                   # how to use and check the stack
├── DEV_DOC.md                    # how to set up, build and debug the project
└── srcs/
    ├── docker-compose.yml        # services, volumes, network
    ├── .env                      # configuration and credentials (not committed)
    └── requirements/
        ├── mariadb/   Dockerfile, tools/init-db.sh
        ├── nginx/     Dockerfile, conf/nginx.conf, tools/setup_nginx.sh
        └── wordpress/ Dockerfile, conf/www.conf, tools/setup-wp.sh
```

Each Dockerfile installs the service, copies its configuration, and runs a setup script as entry point. The script configures the service from the environment variables, then starts it in the foreground so that it stays the container's main process (PID 1).

### Main design choices

- **Startup order with health checks.** MariaDB reports healthy once its socket exists, WordPress once PHP-FPM is running. `depends_on: condition: service_healthy` makes WordPress wait for the database and NGINX wait for WordPress, instead of relying on fixed delays.
- **One-time initialization.** The database and the WordPress installation are created only on the first start. On later starts, the existing data in the volumes is reused.
- **Automatic restart.** Every container uses `restart: unless-stopped`, so a crashed service comes back on its own.
- **Read-only files for NGINX.** NGINX mounts the WordPress volume in read-only mode: it only needs to serve static files, PHP is executed by WordPress.
- **Self-signed certificate.** The TLS certificate is generated with OpenSSL when the NGINX container starts.

### Virtual Machines vs Docker

A **virtual machine** emulates a complete computer with its own kernel, on top of a hypervisor. It is strongly isolated, but heavy: each VM boots a full OS, takes gigabytes of disk and minutes to start.

A **Docker container** shares the host's kernel and only isolates processes, using Linux namespaces and cgroups. It is light (megabytes), starts in seconds, and is reproducible from a Dockerfile. The trade-off is weaker isolation, since all containers depend on the same kernel.

In this project, both are used together: the VM provides an isolated machine, and Docker splits the services inside it.

### Secrets vs Environment Variables

**Environment variables** are simple to use: they are read from a `.env` file and injected into the containers. However, they are visible to anyone who can run `docker inspect` on the container, and they can appear in logs or crash reports.

**Docker secrets** are mounted as files in `/run/secrets/` inside the container, only for the services that need them. They do not appear in `docker inspect` or in the environment, which makes them the safer option for passwords.

This project uses a `.env` file, kept out of Git with `.gitignore`. For a production setup, the passwords should be moved to Docker secrets.

### Docker Network vs Host Network

With the **host network**, a container uses the host's network directly: no isolation, and every port the service opens is exposed on the machine.

A **Docker bridge network** creates a private network for the containers. They reach each other by name (`wordpress`, `mariadb`) thanks to Docker's internal DNS, and nothing is reachable from outside unless it is published explicitly. Here, only NGINX's port 443 is published: MariaDB and PHP-FPM are not reachable from the host.

### Docker Volumes vs Bind Mounts

A **bind mount** links a precise folder of the host to a folder of the container. It is simple and the files are easy to access, but it depends on the host's folder structure.

A **Docker volume** is managed by Docker (`docker volume ls`, `docker volume inspect`), has a name, and is independent from the container's lifecycle.

The subject requires named volumes whose data is stored in `/home/<login>/data`. This project therefore uses **named volumes** (`mariadb_data`, `wordpress_data`) configured with the `local` driver and the `bind` option, so that Docker manages them while the data stays in a known folder of the host.

## Instructions

### Requirements

- A Linux virtual machine (Debian or Ubuntu)
- Docker Engine and the Docker Compose plugin
- `make`
- The domain name pointing to the VM, in `/etc/hosts`:

```bash
echo "127.0.0.1 camansou.42.fr" | sudo tee -a /etc/hosts
```

The full installation steps are described in [DEV_DOC.md](DEV_DOC.md).

### Configuration

Create `srcs/.env` with the following variables (replace the values):

```env
DOMAIN_NAME=camansou.42.fr

MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
MYSQL_PASSWORD=change_me
MYSQL_ROOT_PASSWORD=change_me_too
MYSQL_HOST=mariadb

WP_TITLE=Inception
WP_ADMIN_USER=change_me          # must not contain "admin"
WP_ADMIN_PASSWORD=change_me
WP_ADMIN_EMAIL=admin@example.com
WP_USER=change_me
WP_USER_PASSWORD=change_me
WP_USER_EMAIL=user@example.com
```

### Build and run

```bash
git clone https://github.com/Camillia9/Inception.git
cd Inception
make
```

Then open `https://camansou.42.fr` in the VM's browser and accept the self-signed certificate warning. The administration panel is at `https://camansou.42.fr/wp-admin`.

### Makefile rules

| Rule | Effect |
|---|---|
| `make` | Creates the data folders, builds the images and starts the containers |
| `make down` | Stops the containers (data is kept) |
| `make clean` | Stops the containers and removes the Docker volumes |
| `make fclean` | Full cleanup: images, volumes and data in `/home/camansou/data` |
| `make re` | Full rebuild from scratch |
| `make logs` | Follows the logs of all services |
| `make status` | Shows the state of the containers |

More details: [USER_DOC.md](USER_DOC.md) for using and checking the stack, [DEV_DOC.md](DEV_DOC.md) for setup, debugging and data persistence.

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose file reference](https://docs.docker.com/reference/compose-file/)
- [Dockerfile best practices](https://docs.docker.com/build/building/best-practices/)
- [NGINX documentation](https://nginx.org/en/docs/) and [configuring HTTPS servers](https://nginx.org/en/docs/http/configuring_https_servers.html)

### AI usage

AI (Claude) was used as a learning aid, not to write the project's configuration:

- **Understanding concepts**: asking for explanations of how containers differ from virtual machines, how Docker networks and volumes work, and why the main process must run in the foreground (PID 1).
- **Understanding the services**: clarifying how NGINX communicates with PHP-FPM through FastCGI, and how TLS is configured.
- **README**: help with structuring this README and with the English wording.

All Dockerfiles, scripts and configuration files were written, tested and debugged by me.
