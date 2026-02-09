*This project has been created as part of the 42 curriculum by camansou*

# Documentation Développeur

## Prérequis

- Debian 11 ou Ubuntu 22.04
- Docker Engine (version 20.10+)
- Docker Compose plugin (version 2.0+)
- Make
- Au moins 2 Go RAM et 30 Go d'espace disque

## Installation de l'environnement

### Installer Docker
```bash
# Dépendances
sudo apt update
sudo apt install -y ca-certificates curl gnupg

# Clé GPG Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Dépôt Docker
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Installation
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Ajouter user au groupe docker
sudo usermod -aG docker $USER
```

### Configuration initiale
```bash
# Créer les répertoires de données
mkdir -p ~/data/mariadb
mkdir -p ~/data/wordpress

# Créer le fichier .env (voir README.md)
```

## Utilisation du Makefile
```bash
make        # Build et start
make build  # Build uniquement
make up     # Start uniquement
make down   # Stop
make clean  # Stop + remove containers et volumes
make fclean # Nettoyage complet
make re     # Rebuild complet
make logs   # Logs en temps réel
make status # État des conteneurs
```

## Commandes Docker Compose
```bash
# Démarrer
docker compose -f srcs/docker-compose.yml up -d

# Arrêter
docker compose -f srcs/docker-compose.yml down

# Logs
docker compose -f srcs/docker-compose.yml logs -f

# Rebuild
docker compose -f srcs/docker-compose.yml build

# Status
docker compose -f srcs/docker-compose.yml ps
```

## Gestion des conteneurs
```bash
# Accéder à un conteneur
docker exec -it nginx sh
docker exec -it wordpress bash
docker exec -it mariadb bash

# Logs d'un service
docker logs nginx
docker logs wordpress  
docker logs mariadb

# Inspecter
docker inspect nginx
docker inspect wordpress
docker inspect mariadb
```

## Persistance des données

### Emplacements

- **MariaDB :** `/home/login/data/mariadb`
- **WordPress :** `/home/login/data/wordpress`

### Stratégie

Les bind mounts lient les chemins des conteneurs aux répertoires hôtes :
```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /home/login/data/mariadb
```

**Cycle de vie :**
- `make down` : données **conservées**
- `make clean` : données **supprimées**
- `make fclean` : données **supprimées** + nettoyage Docker

### Vérification
```bash
# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data

# Contenu des volumes
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

## Débogage

### Conteneur ne démarre pas
```bash
docker logs <container_name>
docker inspect <container_name>
```

### Problèmes réseau
```bash
docker network inspect inception_network
docker exec -it wordpress ping mariadb
docker exec -it nginx ping wordpress
```

### Problèmes volumes
```bash
docker volume ls
ls -la ~/data/mariadb/
ls -la ~/data/wordpress/
```

### Base de données
```bash
# Se connecter à MariaDB
docker exec -it mariadb mysql -u wp_user -p -D wordpress_db

# Vérifier les tables
SHOW TABLES;

# Vérifier les utilisateurs WordPress
SELECT * FROM wp_users;
```

### WordPress
```bash
# WP-CLI info
docker exec -it wordpress wp --info --allow-root

# Lister les utilisateurs
docker exec -it wordpress wp user list --allow-root

# Vérifier la config
docker exec -it wordpress wp config get --allow-root
```

## Structure des Dockerfiles

### NGINX

- **Base :** Alpine Linux
- **Port :** 443 (HTTPS)
- **SSL :** Certificat auto-signé généré au démarrage
- **Config :** Reverse proxy vers WordPress (FastCGI)

### WordPress

- **Base :** Debian Bullseye
- **Port :** 9000 (PHP-FPM)
- **Installation :** WP-CLI automatique
- **Utilisateurs :** 2 créés au démarrage

### MariaDB

- **Base :** Debian Bullseye
- **Port :** 3306 (interne uniquement)
- **Initialisation :** Script bash au premier démarrage
- **Persistance :** Volume bind mount

## Réseau Docker

**Type :** Bridge network (`inception_network`)

**Avantages :**
- Isolation des services
- DNS automatique par nom de conteneur
- Sécurité (pas d'exposition au réseau hôte)

**Vérification :**
```bash
docker network ls
docker network inspect inception_network