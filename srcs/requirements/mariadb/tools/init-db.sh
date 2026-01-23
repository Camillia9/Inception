#!/bin/bash
set -eu

echo "🚀 Démarrage de l'initialisation de MariaDB..."

# Vérifier les variables d'environnement
if [ -z "${MYSQL_DATABASE}" ] || \
   [ -z "${MYSQL_USER}" ] || \
   [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    echo "❌ Erreur : Variables d'environnement manquantes !"
    exit 1
fi

echo "✅ Variables d'environnement OK"

# Créer le fichier marker pour vérifier si c'est la première initialisation
MARKER_FILE="/var/lib/mysql/.initialized"

if [ ! -f "$MARKER_FILE" ]; then
    echo "📦 Première initialisation détectée..."
    
    # Arrêter MariaDB s'il tourne déjà
    service mariadb stop 2>/dev/null || true
    
    # Nettoyer les fichiers existants
    rm -rf /var/lib/mysql/*
    
    # Initialiser la structure de base de MariaDB
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    
    echo "✅ Structure de base créée"
    
    # Démarrer MariaDB temporairement
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
    MYSQL_PID=$!
    
    echo "⏳ Attente du démarrage de MariaDB..."
    
    # Attendre que MariaDB soit prêt
    for i in {30..0}; do
        if mysqladmin ping --silent 2>/dev/null; then
            break
        fi
        sleep 1
    done
    
    if [ "$i" = 0 ]; then
        echo "❌ Erreur : MariaDB n'a pas démarré à temps"
        exit 1
    fi
    
    echo "✅ MariaDB démarré temporairement"
    
    # Exécuter les commandes SQL d'initialisation
    mysql << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF
    
    echo "✅ Configuration de la base de données terminée"
    
    # Arrêter MariaDB temporaire
    mysqladmin shutdown 2>/dev/null || kill "$MYSQL_PID"
    wait "$MYSQL_PID" 2>/dev/null || true
    
    # Créer le fichier marker
    touch "$MARKER_FILE"
    
    echo "✅ Base de données initialisée avec succès !"
else
    echo "✅ Base de données déjà initialisée"
fi

echo "🚀 Démarrage de MariaDB en mode production..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0