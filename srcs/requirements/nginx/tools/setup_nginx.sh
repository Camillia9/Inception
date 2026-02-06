#!/bin/sh
# ============================================
# SCRIPT DE CONFIGURATION NGINX
# ============================================

echo "Configuration de NGINX..."

# ============================================
# 1. CRÉER LES CERTIFICATS SSL
# ============================================
echo "Génération des certificats SSL..."

mkdir -p /etc/nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FR/ST=Paris/L=Paris/O=42/OU=42/CN=localhost"

echo "Certificats SSL créés"

# ============================================
# 2. CRÉER LES DOSSIERS NÉCESSAIRES
# ============================================
mkdir -p /var/www/html
mkdir -p /run/nginx

# ============================================
# 3. ATTENDRE QUE WORDPRESS SOIT DISPONIBLE
# ============================================
echo "Attente de WordPress..."

# Attendre que WordPress réponde sur le port 9000
while ! nc -z wordpress 9000 2>/dev/null; do
    echo "WordPress pas encore prêt..."
    sleep 2
done

echo "WordPress est prêt !"

# ============================================
# 4. VÉRIFIER LA CONFIGURATION NGINX
# ============================================
echo "Vérification de la configuration NGINX..."
nginx -t

if [ $? -ne 0 ]; then
    echo "Erreur dans la configuration NGINX !"
    exit 1
fi

echo "Configuration NGINX valide"

# ============================================
# 5. LANCER NGINX
# ============================================
echo "Démarrage de NGINX..."

# Lancer NGINX en premier plan
exec nginx -g "daemon off;"