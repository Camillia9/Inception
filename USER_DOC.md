cat > USER_DOC.md << 'EOF'
# Documentation Utilisateur

## Démarrer le projet
```bash
make
```

## Accéder à WordPress
0. copier coller le .env depuis le nouveau repo de correction: cp /home/camansou/Incept/srcs/.env srcs/.env
1. Ouvrez Firefox **dans la VM**
2. Naviguez vers `https://camansou.42.fr`
3. Acceptez l'avertissement de certificat SSL
4. Connectez-vous avec vos identifiants

## Panneau d'administration

**URL :** https://camansou.42.fr/wp-admin
**CURL :** curl -k https://camansou.42.fr

**Identifiants :**
- Administrateur : (voir fichier .env - WP_ADMIN_USER)
- Mot de passe : (voir fichier .env - WP_ADMIN_PASSWORD)

## Arrêter le projet
```bash
make down
```

## Vérifier l'état des services
```bash
docker ps
```

## Consulter les logs
```bash
make logs
```

## Nettoyage complet
```bash
make fclean
```

**Attention :** Supprime toutes les données.

## Gestion des identifiants

Les identifiants sont stockés dans le fichier `srcs/.env`. Pour les modifier :

1. Arrêtez le projet : `make down`
2. Modifiez `srcs/.env`
3. Nettoyez : `make fclean`
4. Relancez : `make`

## Vérifications de base

**Services actifs :**
```bash
docker ps
# Doit afficher 3 conteneurs : nginx, wordpress, mariadb
```

**Logs :**
```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

**Volumes :**
```bash
docker volume ls
docker volume inspect srcs_mariadb_data
docker volume inspect srcs_wordpress_data
```
EOF