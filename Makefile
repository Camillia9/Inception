# ============================================
# MAKEFILE INCEPTION
# ============================================

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /media/camansou/6A4CBABE4CBA847B/INCEPTION/data

# ============================================
# RÈGLES PRINCIPALES
# ============================================

all: build up

# Construire les images
build:
	@echo "🔨 Construction des images Docker..."
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

# Lancer les conteneurs
up:
	@echo "🚀 Démarrage des conteneurs..."
	docker compose -f $(COMPOSE_FILE) up -d

# Arrêter les conteneurs
down:
	@echo "🛑 Arrêt des conteneurs..."
	docker compose -f $(COMPOSE_FILE) down

# Arrêter et supprimer tout (volumes inclus)
clean: down
	@echo "🧹 Nettoyage des conteneurs et volumes..."
	docker compose -f $(COMPOSE_FILE) down -v

# Nettoyage complet (images + volumes + données)
fclean: clean
	@echo "🗑️  Nettoyage complet..."
	docker system prune -af
	@if [ -d "$(DATA_DIR)/mariadb" ]; then \
		echo "Suppression des données MariaDB..."; \
		rm -rf $(DATA_DIR)/mariadb/*; \
	fi
	@if [ -d "$(DATA_DIR)/wordpress" ]; then \
		echo "Suppression des données WordPress..."; \
		rm -rf $(DATA_DIR)/wordpress/*; \
	fi

# Reconstruire tout depuis zéro
re: fclean all

# Afficher les logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Afficher le status
status:
	docker compose -f $(COMPOSE_FILE) ps

# Redémarrer
restart: down up

.PHONY: all build up down clean fclean re logs status restart


## ============================================
## MAKEFILE INCEPTION
## ============================================

#COMPOSE_FILE = srcs/docker-compose.yml
#DATA_DIR = /media/camansou/6A4CBABE4CBA847B/INCEPTION/data

## ============================================
## RÈGLES PRINCIPALES
## ============================================

#all: up

## Construire et démarrer
#up:
#	@echo "🚀 Démarrage de l'infrastructure..."
#	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
#	docker compose -f $(COMPOSE_FILE) up --build -d

## Arrêter
#down:
#	@echo "🛑 Arrêt de l'infrastructure..."
#	docker compose -f $(COMPOSE_FILE) down

## Redémarrer
#restart: down up

## Voir les logs
#logs:
#	docker compose -f $(COMPOSE_FILE) logs -f

## Nettoyer tout
#clean: down
#	@echo "🧹 Nettoyage des volumes..."
#	docker compose -f $(COMPOSE_FILE) down -v
#	@echo "🧹 Nettoyage des données..."
#	sudo rm -rf $(DATA_PATH)/mariadb/* $(DATA_PATH)/wordpress/*

## Nettoyer complètement (images aussi)
#fclean: clean
#	@echo "🧹 Nettoyage des images..."
#	docker rmi mariadb wordpress nginx 2>/dev/null || true

## Tout reconstruire
#re: fclean all

## ============================================
## RÈGLES UTILITAIRES
## ============================================

## Voir l'état des conteneurs
#ps:
#	docker compose -f $(COMPOSE_FILE) ps

## Entrer dans un conteneur
#shell-nginx:
#	docker exec -it nginx sh

#shell-wordpress:
#	docker exec -it wordpress bash

#shell-mariadb:
#	docker exec -it mariadb bash

#.PHONY: all up down restart logs clean fclean re ps shell-nginx shell-wordpress shell-mariadb