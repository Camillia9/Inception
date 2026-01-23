MARIADB: 
Dockerfile:
apt-get update"Vérifie quels logiciels sont disponibles"
apt-get install -y mariadb-server"Installe MariaDB" (-y = répond automatiquement "oui")
rm -rf /var/lib/apt/lists/*Nettoie le cache (rend l'image plus petite)
mkdir -p /var/run/mysqld Crée le dossier où MariaDB stocke son fichier de socket
chown -R mysql:mysql Donne la propriété du dossier à l'utilisateur mysql
chmod 777 Donne tous les droits sur ce dossier
COPY tools/init-db.sh Copie notre script d'initialisation
chmod +x Rend le script exécutable
EXPOSE 3306 Déclare que MariaDB utilise le port 3306
ENTRYPOINT Lance notre script au démarrage du conteneur

Ce qui se passe au demarage:
1. Docker lit le Dockerfile
2. Installe MariaDB dans le conteneur
3. Lance le script init-db.sh
4. Le script :
   ✓ Vérifie que les variables existent
   ✓ Crée la base de données "wordpress_db"
   ✓ Crée l'utilisateur "wp_user"
   ✓ Démarre MariaDB en écoute sur le port 3306


WordPress
Dockerfile:
///// a ecrire

Ce qui se passe au demarage:
1. Docker lit le Dockerfile
2. Installe PHP et WordPress
3. Lance le script setup-wp.sh
4. Le script :
   ✓ Attend que MariaDB soit prêt
   ✓ Télécharge WordPress
   ✓ Crée le fichier wp-config.php (connexion à la base)
   ✓ Installe WordPress
   ✓ Crée les 2 utilisateurs
   ✓ Lance PHP-FPM en écoute sur le port 9000


Fichier .env:
# Pour MariaDB
MYSQL_DATABASE=wordpress_db          ← Nom de la base
MYSQL_USER=wp_user                   ← Utilisateur pour se connecter
MYSQL_PASSWORD=secure_password_123   ← Mot de passe
MYSQL_ROOT_PASSWORD=root_password_456 ← Mot de passe admin

# Pour WordPress
MYSQL_HOST=mariadb                   ← "Va parler au conteneur 'mariadb'"
WP_ADMIN_USER=camillia_admin         ← Ton compte admin
WP_USER=camillia_author              ← Le 2ème utilisateur


Les commandes: 

1.
docker build -t my-mariadb .
**Ce que fait cette commande :**
- `docker build` : construire une image
- `-t test-mariadb` : donner le nom "test-mariadb" à l'image
- `.` : utiliser le Dockerfile du dossier actuel

2.
docker run -d \
--name my-mariadb \
--env-file ../../.env \
-p 3306:3306 \
my-mariadb
**Explications :**
- `docker run` : lancer un conteneur
- `-d` : en arrière-plan (detached)
- `--name test-mariadb` : donner un nom au conteneur
- `--env-file ../../.env` : charger les variables depuis le fichier .env
- `-p 3306:3306` : exposer le port 3306 (pour se connecter depuis l'extérieur)
- `test-mariadb` : le nom de l'image à utiliser

3.
docker ps
**verifie que le conteneur est bien actif**
Si STATUS Up ok

4.
docker logs my-mariadb
**Verification des logs, ce qu'il s'est passe durant le demarage**

5.
docker exec -it my-mariadb bash
**Explication :** Tu es maintenant "à l'intérieur" du conteneur, comme si tu étais dans un ordinateur virtuel.

6.
mysql -u wp_user -psecure_password_123 wordpress_db
**Explication :**
Se connecter a mariaDB
syntaxe : mysql -u [UTILISATEUR] -p[MOT_DE_PASSE] [BASE_DE_DONNÉES]
- `-u wp_user` : se connecter avec l'utilisateur wpuser : u:username
- `-psecure_password_123` : avec ce mot de passe        : p:password
- `wordpress_db` : à la base de données wordpress


Pour effacer: 
# Sortir du conteneur d'abord
exit
# Arrêter le conteneur
docker stop test-mariadb
# Supprimer le conteneur
docker rm test-mariadb
# Supprimer l'image (pour être sûr de repartir à zéro)
docker rmi test-mariadb

FACULTATIF:
# Supprimer TOUS les volumes (c'est là que les données persistent)
docker volume prune -f
# Vérifier qu'il n'y a plus de volumes
docker volume ls
# SUPPRIMER TOUT LE CACHE
docker builder prune -af
# Rebuild en forçant tout à se refaire
docker build --no-cache -t test-mariadb .