FROM		debian:bullseye

RUN			apt-get update && \
    		apt-get install -y mariadb-server && \
  			rm -rf /var/lib/apt/lists/*

RUN			rm -rf /var/lib/mysql/*

RUN			mkdir -p /var/run/mysqld && \
    		chown -R mysql:mysql /var/run/mysqld && \
    		chmod 777 /var/run/mysqld

COPY		tools/init-db.sh /usr/local/bin/

RUN			chmod +x /usr/local/bin/init-db.sh

EXPOSE		3306

ENTRYPOINT	["/usr/local/bin/init-db.sh"]