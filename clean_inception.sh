#!/bin/bash

echo "╔════════════════════════════════════════════════════╗"
echo "║           NETTOYAGE TOTAL INCEPTION               ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

echo "🛑 Arrêt de TOUS les conteneurs..."
docker stop $(docker ps -aq) 2>/dev/null

echo "🗑️ Suppression de TOUS les conteneurs..."
docker rm $(docker ps -aq) 2>/dev/null

echo "🗑️ Suppression des images Inception..."
for img in my-nginx my-wordpress my-mariadb; do
    docker rmi $(docker images "$img" -q) 2>/dev/null
done

echo "🗑️ Suppression des réseaux Docker personnalisés..."
docker network prune -f

echo "🗑️ Suppression des données locales..."

docker run --rm -v ~/data/mariadb:/data alpine sh -c "rm -rf /data/*"
rm -rf "$HOME/data/mariadb"
rm -rf "$HOME/data/wordpress"

echo ""
echo "🔍 Vérification finale"

docker ps -a
docker images | grep my-
docker network ls

echo ""
echo "✅ Nettoyage terminé"

