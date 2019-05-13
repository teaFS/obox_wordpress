FROM php:7.3-cli-alpine3.9 AS obox_wordpress

ENV OBOX_DEBUG 1

# -=== BEGIN WP-CLI settings
   # WP-CLI download URL, official dowload (1), and localnetwork source example (2): 
   ENV WPCLI_URL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
   #ENV WPCLI_URL http://bestlocalnetwork/ires/wp-cli.org/wp-cli.phar

   # Full name (path and file name) of WP-CLI executable: 
   ENV WPCLI_NAME /usr/local/bin/wp
# END WP-CLI settings ===-

# -=== BEGIN Alpine settings
   ENV DEV_TOOLS build-base autoconf php7-dev libzip-dev
   ENV BASE_PCKGS mariadb-client
   #php7-zip php7-mysqli php7-pdo_mysql 
   # mariadb-client less
# END Alpine settings ===-

# Let's have a fun to happen

# install WP-CLI
RUN curl    --silent \
            --connect-timeout 60 \
            --output $WPCLI_NAME \
            $WPCLI_URL && \
    chmod +x $WPCLI_NAME

# install base packages
RUN apk upgrade && apk add --no-cache $BASE_PCKGS

# compile and install ZipArhive which is not avaliable as Alpine's package
# it is requied by 'wp core download' to unpack an archive
RUN apk add --no-cache $DEV_TOOLS && \
    pecl install zip && \
    docker-php-ext-enable zip && \
    [ $OBOX_DEBUG -ne 1 ] && apk del $DEV_TOOLS || echo "Obox in DEBUG MODE, leaving development tools unpurged"

# install packeges requied for connecting to database
RUN docker-php-ext-install mysqli pdo pdo_mysql

# install troubleshooting and info scripts: 
RUN mkdir /var/www/html/_info
COPY files/info.php /var/www/html/_info/index.php

USER www-data:www-data
WORKDIR /var/www/html


CMD ["php", "-S", "0.0.0.0:8080", "-t", "."]
