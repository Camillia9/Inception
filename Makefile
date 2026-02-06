# ============================================
# MAKEFILE INCEPTION
# ============================================

# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/camansou/data

# ============================================
# RÈGLES PRINCIPALES
# ============================================

all: build up

# Construire les images
build:
	@echo " Construction des images Docker..."
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

# Lancer les conteneurs
up:
	@echo " Démarrage des conteneurs..."
	docker compose -f $(COMPOSE_FILE) up -d

# Arrêter les conteneurs
down:
	@echo " Arrêt des conteneurs..."
	docker compose -f $(COMPOSE_FILE) down

# Arrêter et supprimer tout (volumes inclus)
clean: down
	@echo "Nettoyage des conteneurs et volumes..."
	docker compose -f $(COMPOSE_FILE) down -v

# Nettoyage complet (images + volumes + données)
fclean: clean
	@echo " Nettoyage complet..."
	docker system prune -af
	@if [ -d "$(DATA_DIR)/mariadb" ]; then \
		echo "Suppression des données MariaDB..."; \
		sudo rm -rf $(DATA_DIR)/mariadb/*; \
		sudo rm -rf $(DATA_DIR)/mariadb/.initialized; \
	fi
	@if [ -d "$(DATA_DIR)/wordpress" ]; then \
		echo "Suppression des données WordPress..."; \
		sudo rm -rf $(DATA_DIR)/wordpress/*; \
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