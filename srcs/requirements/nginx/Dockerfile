# ============================================
# IMAGE DE BASE
# ============================================
FROM alpine:3.12

# ============================================
# INSTALLATION DES PAQUETS
# ============================================
RUN apk update && apk upgrade && apk add --no-cache \
    openssl \
    nginx

# ============================================
# COPIER LA CONFIGURATION
# ============================================
# Supprimer la config par défaut
RUN rm -f /etc/nginx/http.d/default.conf

# Copier notre config
COPY conf/nginx.conf /etc/nginx/nginx.conf

# ============================================
# COPIER ET RENDRE EXÉCUTABLE LE SCRIPT
# ============================================
COPY tools/setup_nginx.sh /setup_nginx.sh
RUN chmod +x /setup_nginx.sh

# ============================================
# EXPOSER LE PORT
# ============================================
EXPOSE 443

# ============================================
# LANCER LE SCRIPT
# ============================================
ENTRYPOINT ["sh", "/setup_nginx.sh"]