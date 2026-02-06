#!/bin/bash
# ============================================
# SCRIPT DE CONFIGURATION WORDPRESS
# ============================================

set -eu

echo "Démarrage de la configuration WordPress..."

# ============================================
# 1. VÉRIFIER LES VARIABLES D'ENVIRONNEMENT
# ============================================
if [ -z "${MYSQL_DATABASE}" ] || \
   [ -z "${MYSQL_USER}" ] || \
   [ -z "${MYSQL_PASSWORD}" ] || \
   [ -z "${MYSQL_HOST}" ] || \
   [ -z "${WP_TITLE}" ] || \
   [ -z "${WP_ADMIN_USER}" ] || \
   [ -z "${WP_ADMIN_PASSWORD}" ] || \
   [ -z "${WP_ADMIN_EMAIL}" ] || \
   [ -z "${WP_USER}" ] || \
   [ -z "${WP_USER_PASSWORD}" ] || \
   [ -z "${WP_USER_EMAIL}" ]; then
    echo "Erreur : Variables d'environnement manquantes !"
    exit 1
fi

echo "Variables d'environnement OK"

# ============================================
# 2. ATTENDRE QUE MARIADB SOIT PRÊT
# ============================================
echo "Attente de MariaDB..."

while ! mysqladmin ping -h"${MYSQL_HOST}" --silent; do
    echo "MariaDB n'est pas encore prêt, attente..."
    sleep 2
done

echo "MariaDB est prêt !"

# ============================================
# 3. TÉLÉCHARGER WORDPRESS (si pas déjà fait)
# ============================================
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Téléchargement de WordPress..."
    
    wp core download --allow-root --locale=fr_FR
    
    echo "WordPress téléchargé"
    
    # ============================================
    # 4. CRÉER LE FICHIER DE CONFIGURATION
    # ============================================
    echo "Création du fichier wp-config.php..."
    
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${MYSQL_PASSWORD}" \
        --dbhost="${MYSQL_HOST}" \
        --dbcharset="utf8" \
        --dbcollate=""
    
    echo "Fichier wp-config.php créé"
    
    # ============================================
    # 5. INSTALLER WORDPRESS
    # ============================================
    echo "Installation de WordPress..."
    
    wp core install \
        --allow-root \
        --url="${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"
    
    echo "WordPress installé"
    
    # ============================================
    # 6. CRÉER LE DEUXIÈME UTILISATEUR
    # ============================================
    echo "Création du deuxième utilisateur..."

    wp user create \
        --allow-root \
        "${WP_USER}" \
        "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author || echo "Utilisateur existe déjà"

    echo "Utilisateur vérifié"
fi

# ============================================
# 7. CONFIGURER PHP-FPM
# ============================================
echo "Configuration de PHP-FPM..."

sed -i 's|listen = /run/php/php7.4-fpm.sock|listen = 9000|g' /etc/php/7.4/fpm/pool.d/www.conf

echo "PHP-FPM configuré pour écouter sur le port 9000"

# ============================================
# 8. DÉMARRER PHP-FPM
# ============================================
echo "Démarrage de PHP-FPM..."

exec /usr/sbin/php-fpm7.4 -F -R