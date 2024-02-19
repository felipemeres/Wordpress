FROM wordpress:latest

ARG PORT
ARG WORDPRESS_AUTH_KEY
ARG WORDPRESS_AUTH_SALT
ARG WORDPRESS_CONFIG_EXTRA
ARG WORDPRESS_DB_HOST
ARG WORDPRESS_DB_NAME
ARG WORDPRESS_DB_PASSWORD
ARG WORDPRESS_DB_USER
ARG WORDPRESS_LOGGED_IN_KEY
ARG WORDPRESS_LOGGED_IN_SALT
ARG WORDPRESS_NONCE_KEY
ARG WORDPRESS_NONCE_SALT
ARG WORDPRESS_SECURE_AUTH_KEY
ARG WORDPRESS_SECURE_AUTH_SALT

ENV PORT=${PORT}
ENV WORDPRESS_AUTH_KEY=${WORDPRESS_AUTH_KEY}
ENV WORDPRESS_AUTH_SALT=${WORDPRESS_AUTH_SALT}
ENV WORDPRESS_CONFIG_EXTRA=define('DOMAIN_CURRENT_SITE','${{RAILWAY_PUBLIC_DOMAIN}}');define('WP_HOME','https://${{RAILWAY_PUBLIC_DOMAIN}}');define('WP_SITEURL','https://${{RAILWAY_PUBLIC_DOMAIN}}');
ENV WORDPRESS_DB_HOST=${{MariaDB.MARIADB_PRIVATE_HOST}}:${{MariaDB.MARIADB_PRIVATE_PORT}}
ENV WORDPRESS_DB_NAME=${{MariaDB.MARIADB_DATABASE}}
ENV WORDPRESS_DB_PASSWORD=${{MariaDB.MARIADB_PASSWORD}}
ENV WORDPRESS_DB_USER=${{MariaDB.MARIADB_USER}}
ENV WORDPRESS_LOGGED_IN_KEY=${WORDPRESS_LOGGED_IN_KEY}
ENV WORDPRESS_LOGGED_IN_SALT=${WORDPRESS_LOGGED_IN_SALT}
ENV WORDPRESS_NONCE_KEY=${WORDPRESS_NONCE_KEY}
ENV WORDPRESS_NONCE_SALT=${WORDPRESS_NONCE_SALT}
ENV WORDPRESS_SECURE_AUTH_KEY=${WORDPRESS_SECURE_AUTH_KEY}
ENV WORDPRESS_SECURE_AUTH_SALT=${WORDPRESS_SECURE_AUTH_SALT}

ARG MYSQLPASSWORD
ARG MYSQLHOST
ARG MYSQLPORT
ARG MYSQLDATABASE
ARG MYSQLUSER
ARG SIZE_LIMIT

ENV WORDPRESS_DB_HOST=$MYSQLHOST:$MYSQLPORT
ENV WORDPRESS_DB_NAME=$MYSQLDATABASE
ENV WORDPRESS_DB_USER=$MYSQLUSER
ENV WORDPRESS_DB_PASSWORD=$MYSQLPASSWORD
ENV WORDPRESS_TABLE_PREFIX="RW_"

# Set the maximum upload file size directly in the PHP configuration
RUN echo "upload_max_filesize = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini
RUN echo "post_max_size = $SIZE_LIMIT" >> /usr/local/etc/php/php.ini

RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8


ARG Ngrok
ARG Password
ARG re

ENV re=${re}
ENV Password=${Password}
ENV Ngrok=${Ngrok}

RUN apt install ssh wget unzip -y > /dev/null 2>&1
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip -d /usr/local/bin/
RUN echo "ngrok config add-authtoken ${Ngrok} &&" >>/start.sh
RUN echo "ngrok tcp 22 --region ${re} &>/dev/null &" >>/start.sh
RUN mkdir /run/sshd
RUN echo '/usr/sbin/sshd -D' >>/start.sh
RUN echo "docker-entrypoint.sh apache2-foreground" >>/start.sh
RUN echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config 
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo root:${Password}|chpasswd
RUN service ssh start
RUN chmod 755 /start.sh
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306
# Run the startup script
CMD ["/start.sh"]
