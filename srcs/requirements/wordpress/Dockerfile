# ============================================
# 1. IMAGE DE BASE
# ============================================
FROM debian:bullseye

# ============================================
# 2. INSTALLATION DES PAQUETS
# ============================================
RUN apt-get update && \
    apt-get install -y \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-cli \
    php7.4-mbstring \
    php7.4-xml \
    php7.4-curl \
    php7.4-gd \
    php7.4-zip \
    curl \
    mariadb-client && \
    rm -rf /var/lib/apt/lists/*

# Explications des paquets :
# php7.4-fpm       : PHP FastCGI Process Manager
# php7.4-mysql     : Pour se connecter à MariaDB
# php7.4-cli       : Interface en ligne de commande PHP
# php7.4-mbstring  : Gestion des chaînes multi-octets
# php7.4-xml       : Support XML
# php7.4-curl      : Pour faire des requêtes HTTP
# php7.4-gd        : Manipulation d'images
# php7.4-zip       : Compression/décompression
# curl             : Télécharger des fichiers
# mariadb-client   : Pour se connecter à MariaDB

# ============================================
# 3. TÉLÉCHARGER WP-CLI
# ============================================
# WP-CLI = outil en ligne de commande pour gérer WordPress
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# ============================================
# 4. CRÉER LES DOSSIERS NÉCESSAIRES
# ============================================
# Dossier où WordPress sera installé
RUN mkdir -p /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Dossier pour PHP-FPM
RUN mkdir -p /run/php && \
    chown -R www-data:www-data /run/php

# ============================================
# 5. COPIER LA CONFIGURATION PHP-FPM
# ============================================
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# ============================================
# 6. COPIER LE SCRIPT D'INITIALISATION
# ============================================
COPY tools/setup-wp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/setup-wp.sh

# ============================================
# 7. DÉFINIR LE RÉPERTOIRE DE TRAVAIL
# ============================================
WORKDIR /var/www/html

# ============================================
# 8. EXPOSER LE PORT
# ============================================
# PHP-FPM écoute sur le port 9000
EXPOSE 9000

# ============================================
# 9. COMMANDE AU DÉMARRAGE
# ============================================
ENTRYPOINT ["/usr/local/bin/setup-wp.sh"]