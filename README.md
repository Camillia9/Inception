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


Faire fonctionner WordPress AVEC MariaDB

1. Créer les dossiers pour stocker les données
mkdir -p ~/data/mariadb
mkdir -p ~/data/wordpress
--> + Donner les bonnes permissions
chmod 777 ~/data/mariadb
chmod 777 ~/data/wordpress

2. Cree un reseau Docker
docker network create inception-net
**Qu'est-ce que c'est ?**
Un *réseau Docker* = un "câble virtuel" qui relie les conteneurs. (MariaDB et WordPress pour qu'ils puissent communiquer).
--VERIFICATION--
docker network ls

3. Construire l'image mariaDB, lancer, verifier les logs
cd ../Inception/srcs/requirements/mariadb
docker build -t my-mariadb .
docker run -d \
  --name mariadb \
  --network inception-net \
  --env MYSQL_DATABASE=wordpress_db \
  --env MYSQL_USER=wp_user \
  --env MYSQL_PASSWORD=secure_password_123 \
  --env MYSQL_ROOT_PASSWORD=root_password_456 \
  -v ~/data/mariadb:/var/lib/mysql \
  my-mariadb
  docker logs mariadb

  4. Construire l'image WordPress
  cd ../Inception/srcs/requirements/wordpress
  docker build -t my-wordpress .

  5. Lancer WordPress
  docker run -d \
  --name wordpress \
  --network inception-net \
  --env MYSQL_DATABASE=wordpress_db \
  --env MYSQL_USER=wp_user \
  --env MYSQL_PASSWORD=secure_password_123 \
  --env MYSQL_HOST=mariadb \
  --env DOMAIN_NAME=camansou.42.fr \
  --env WP_TITLE="Mon Site WordPress" \
  --env WP_ADMIN_USER=camansou_admin \
  --env WP_ADMIN_PASSWORD=admin_pass_secure_789 \
  --env WP_ADMIN_EMAIL=camansou@student.42.fr \
  --env WP_USER=camansou_author \
  --env WP_USER_PASSWORD=user_pass_secure_456 \
  --env WP_USER_EMAIL=author@student.42.fr \
  -v ~/data/wordpress:/var/www/html \
  my-wordpress

  6. Verifier logs
  docker logs -f wordpress
   -- A voir a la fin: 🚀 Démarrage de PHP-FPM... --

  7. docker ps
   -- Devrais voir :
CONTAINER ID   IMAGE          STATUS
xxx            my-wordpress   Up X minutes
xxx            my-mariadb     Up X minutes

8. Verifier que WordPress a bien etait installe
ls -la ~/data/wordpress/

9. Verification que les tables ont bien etait cree dans MariaDB
# Entre dans MariaDB
docker exec -it mariadb bash
# Connecte-toi à la base
mysql -u wp_user -p
# Mot de passe : 
secure_password_123
# Dans mySQL : 
USE wordpress_db; SHOW TABLES;
# Verifier les utilisateurs :
SELECT user_login FROM wp_users;


**TOUT REFAIRE PROPREMENT**
# Supressions conteneurs
docker stop nginx wordpress mariadb 2>/dev/null
docker rm nginx wordpress mariadb 2>/dev/null
# Supressions images
docker rmi my-nginx my-wordpress my-mariadb 2>/dev/null
# Supressions reseau
docker network rm inception-net 2>/dev/null
# Supressions donnees
rm -rf ~/data/mariadb/*
rm -rf ~/data/wordpress/*
# Verifier que tout est vide
**Aucun conteneur**
docker ps -a
**Aucune image inception**
docker images | grep -E "my-nginx|my-wordpress|my-mariadb"
**Aucun réseau inception**
docker network ls | grep inception
**Dossiers vides** (rien ne doit s'afficher)
ls ~/data/mariadb/
ls ~/data/wordpress/
-- SI NON : -- 
rm -rf ~/data/mariadb/*
OU
docker run --rm -v ~/data/mariadb:/data alpine sh -c "rm -rf /data/*"
-- VERIFICATION -- (rien ne doit s'afficher)
ls ~/data/mariadb/
ls ~/data/wordpress/

1. MARIADB: docker build -t my-mariadb .
2. WORDPRESS: docker build -t my-wordpress .
3. NGINX: docker build -t my-nginx .

4. Verifier les images: docker images | grep -E "my-nginx|my-wordpress|my-mariadb"

5. Cree le reseau : docker network create inception-net
6. Verifiction: docker network ls | grep inception

7. Preparation des dossiers
# Créer les dossiers
mkdir -p ~/data/mariadb
mkdir -p ~/data/wordpress
# Donner les permissions
sudo chmod 777 ~/data/mariadb
sudo chmod 777 ~/data/wordpress
OU
docker run --rm -v ~/data/mariadb:/data alpine chmod 777 /data && docker run --rm -v ~/data/wordpress:/data alpine chmod 777 /data

8. Lancer les Conteneurs dans le bon ordre:
**mariaDB**
docker run -d \
  --name mariadb \
  --network inception-net \
  --restart unless-stopped \
  --env MYSQL_DATABASE=wordpress_db \
  --env MYSQL_USER=wp_user \
  --env MYSQL_PASSWORD=secure_password_123 \
  --env MYSQL_ROOT_PASSWORD=root_password_456 \
  -v ~/data/mariadb:/var/lib/mysql \
  my-mariadb
# verifier les logs : 
docker logs mariadb

**WordPress**
docker run -d \
  --name wordpress \
  --network inception-net \
  --restart unless-stopped \
  --env MYSQL_DATABASE=wordpress_db \
  --env MYSQL_USER=wp_user \
  --env MYSQL_PASSWORD=secure_password_123 \
  --env MYSQL_HOST=mariadb \
  --env DOMAIN_NAME=camansou.42.fr \
  --env WP_TITLE="Mon Site WordPress" \
  --env WP_ADMIN_USER=camansou_admin \
  --env WP_ADMIN_PASSWORD=admin_pass_secure_789 \
  --env WP_ADMIN_EMAIL=camansou@student.42.fr \
  --env WP_USER=camansou_author \
  --env WP_USER_PASSWORD=user_pass_secure_456 \
  --env WP_USER_EMAIL=author@student.42.fr \
  -v ~/data/wordpress:/var/www/html \
  my-wordpress
  # verifier les logs : 
docker logs wordpress

**NGINX** 
docker run -d \
  --name nginx \
  --network inception-net \
  --restart unless-stopped \
  -v ~/data/wordpress:/var/www/html:ro \
  -p 8443:443 \
  my-nginx
   # verifier les logs : 
docker logs nginx

9. Verifier que les 3 conteneurs tournent: 
   docker ps

10. Verifier que les fichiers WordPress sont toujours la: 
  ls -la ~/data/wordpress/ | head -20


11. Verifier que les tables WordPress ont ete cree
  docker exec -it mariadb bash -c "mysql -u wp_user -psecure_password_123 -e 'USE wordpress_db; SHOW TABLES;'"

  