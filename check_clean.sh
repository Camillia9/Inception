#!/bin/bash

echo "╔════════════════════════════════════════════════════╗"
echo "║        VÉRIFICATION COMPLÈTE DU NETTOYAGE          ║"
echo "╚════════════════════════════════════════════════════╝"
echo ""

echo "🔍 1. CONTENEURS EN COURS D'EXÉCUTION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
RUNNING=$(docker ps --filter "name=nginx" --filter "name=wordpress" --filter "name=mariadb" --quiet)
if [ -z "$RUNNING" ]; then
  echo "✅ Aucun conteneur inception en cours"
else
  echo "❌ CONTENEURS ACTIFS :"
  echo "$RUNNING"
fi
echo ""

echo "🔍 2. TOUS LES CONTENEURS (arrêtés inclus)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
STOPPED=$(docker ps -a --filter "name=nginx" --filter "name=wordpress" --filter "name=mariadb" --quiet)
if [ -z "$STOPPED" ]; then
  echo "✅ Aucun conteneur inception (même arrêtés)"
else
  echo "❌ CONTENEURS TROUVÉS :"
  echo "$STOPPED"
fi
echo ""

echo "🔍 3. IMAGES DOCKER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
IMAGES=$(docker images my-nginx my-wordpress my-mariadb -q 2>/dev/null)
if [ -z "$IMAGES" ]; then
  echo "✅ Aucune image inception trouvée"
else
  echo "❌ IMAGES TROUVÉES :"
  echo "$IMAGES"
fi
echo ""

echo "🔍 4. RÉSEAUX DOCKER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
NETWORKS=$(docker network ls --filter "name=inception" --quiet)
if [ -z "$NETWORKS" ]; then
  echo "✅ Aucun réseau 'inception' trouvé"
else
  echo "❌ RÉSEAUX TROUVÉS :"
  echo "$NETWORKS"
fi
echo ""

echo "🔍 5. DONNÉES MARIADB (~/data/mariadb/)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "$HOME/data/mariadb" ]; then
  echo "✅ Dossier n'existe pas"
elif [ -z "$(ls -A "$HOME/data/mariadb" 2>/dev/null)" ]; then
  echo "✅ Dossier existe mais vide"
else
  echo "❌ FICHIERS TROUVÉS :"
  ls -la "$HOME/data/mariadb"
fi
echo ""

echo "🔍 6. DONNÉES WORDPRESS (~/data/wordpress/)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ ! -d "$HOME/data/wordpress" ]; then
  echo "✅ Dossier n'existe pas"
elif [ -z "$(ls -A "$HOME/data/wordpress" 2>/dev/null)" ]; then
  echo "✅ Dossier existe mais vide"
else
  echo "❌ FICHIERS TROUVÉS :"
  ls -la "$HOME/data/wordpress"
fi
echo ""

echo "🧹 NETTOYAGE AUTOMATIQUE"

docker stop nginx wordpress mariadb 2>/dev/null
docker rm nginx wordpress mariadb 2>/dev/null
docker rmi my-nginx my-wordpress my-mariadb 2>/dev/null

echo ""
echo "🔍 RÉSUMÉ FINAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LEFT=$(docker ps -a --filter "name=nginx" --filter "name=wordpress" --filter "name=mariadb" -q)

if [ -z "$LEFT" ]; then
  echo "🎉 NETTOYAGE COMPLET ! Tu peux repartir de zéro."
else
  echo "⚠️  Des éléments existent encore :"
  echo "$LEFT"
fi

echo ""
