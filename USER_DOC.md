*This project has been created as part of the 42 curriculum by camansou*

# User Documentation

## Services provided

The stack runs three services, each in its own container:

- **NGINX**: the only entry point, serves the website over HTTPS (port 443)
- **WordPress**: the website and its administration panel (PHP-FPM)
- **MariaDB**: the database that stores the WordPress content

## Start the project

Before the first start, create the `srcs/.env` file (see the template in [README.md](README.md#configuration)).

```bash
make
```

## Access WordPress

1. Open Firefox **inside the VM**
2. Go to `https://camansou.42.fr`
3. Accept the SSL certificate warning (the certificate is self-signed)
4. Log in with your credentials

## Administration panel

**URL:** https://camansou.42.fr/wp-admin

**Credentials:**
- Administrator: see `WP_ADMIN_USER` in `srcs/.env`
- Password: see `WP_ADMIN_PASSWORD` in `srcs/.env`

## Test access from the command line

```bash
# HTTPS (should work)
curl -k https://camansou.42.fr

# HTTP on port 80 (should NOT work)
curl http://camansou.42.fr
```

## Update the site URL

If the site is accessed through another port (for example `8443`), update the WordPress URL:

```bash
docker exec -it wordpress wp option update home 'https://camansou.42.fr:8443' --allow-root
docker exec -it wordpress wp option update siteurl 'https://camansou.42.fr:8443' --allow-root
```

## Stop the project

```bash
make down
```

The data is kept: the next `make` restarts the site as it was.

## Check the services

```bash
docker ps
# Should list 3 containers: nginx, wordpress, mariadb
```

## Connect to the database

```bash
docker exec -it mariadb mysql -u wp_user -p -D wordpress_db
```

- Enter the password (`MYSQL_PASSWORD` in `srcs/.env`)
- List the tables: `SHOW TABLES;`
- Check the WordPress users: `SELECT user_login FROM wp_users;`
- Quit: `exit`

## View the logs

```bash
make logs
# or
docker compose -f srcs/docker-compose.yml logs
```

For a single service:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

## Manage credentials

The credentials are stored in `srcs/.env`. To change them:

1. Stop the project: `make down`
2. Edit `srcs/.env`
3. Clean everything: `make fclean` (the database must be recreated with the new credentials)
4. Restart: `make`

## Full cleanup

```bash
make fclean
```

**Warning:** this deletes all the data (database and website files).

## Basic checks

**Running services:**
```bash
docker ps
# Should list 3 containers: nginx, wordpress, mariadb
```

**Volumes:**
```bash
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```
