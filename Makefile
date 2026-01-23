# ============================================
# MAKEFILE INCEPTION
# ============================================

COMPOSE_FILE = srcs/docker-compose.yml
DATA_PATH = $(HOME)/data

# ============================================
# RÈGLES PRINCIPALES
# ============================================

all: up

# Construire et démarrer
up:
	@echo "🚀 Démarrage de l'infrastructure..."
	@mkdir -p $(DATA_PATH)/mariadb $(DATA_PATH)/wordpress
	docker compose -f $(COMPOSE_FILE) up --build -d

# Arrêter
down:
	@echo "🛑 Arrêt de l'infrastructure..."
	docker compose -f $(COMPOSE_FILE) down

# Redémarrer
restart: down up

# Voir les logs
logs:
	docker compose -f $(COMPOSE_FILE) logs -f

# Nettoyer tout
clean: down
	@echo "🧹 Nettoyage des volumes..."
	docker compose -f $(COMPOSE_FILE) down -v
	@echo "🧹 Nettoyage des données..."
	sudo rm -rf $(DATA_PATH)/mariadb/* $(DATA_PATH)/wordpress/*

# Nettoyer complètement (images aussi)
fclean: clean
	@echo "🧹 Nettoyage des images..."
	docker rmi mariadb wordpress nginx 2>/dev/null || true

# Tout reconstruire
re: fclean all

# ============================================
# RÈGLES UTILITAIRES
# ============================================

# Voir l'état des conteneurs
ps:
	docker compose -f $(COMPOSE_FILE) ps

# Entrer dans un conteneur
shell-nginx:
	docker exec -it nginx sh

shell-wordpress:
	docker exec -it wordpress bash

shell-mariadb:
	docker exec -it mariadb bash

.PHONY: all up down restart logs clean fclean re ps shell-nginx shell-wordpress shell-mariadb