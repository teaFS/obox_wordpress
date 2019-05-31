FROM php:7.3-cli-alpine3.9 AS obox_wordpress

LABEL maintainer="Mateusz Piwek <Mateusz @ teaFS.org>" \
      version="1.0 RC2" \
      obox.framework="wordpress"

ENV HTTP_EXP_PORT 8080
ENV HTTP_EXP_ADDR "0.0.0.0:"$HTTP_EXP_PORT

EXPOSE $HTTP_EXP_PORT/tcp

ENV OBOX_DEBUG 1

# -=== BEGIN WP-CLI settings
   # WP-CLI download URL, official dowload (1), and localnetwork source example (2): 
   ENV WPCLI_URL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
   #ENV WPCLI_URL http://bestlocalnetwork/ires/wp-cli.org/wp-cli.phar

   # Full name (path and file name) of WP-CLI executable: 
   ENV WPCLI_NAME /usr/local/bin/wp
# END WP-CLI settings ===-

# -=== BEGIN Alpine settings
   # Base packages
   ENV BASE_PCKGS mariadb-client
   # development packages
   ENV DEV0_PCKGS \
      build-base automake \
      php7-dev \
      # requied by: zip ext
      libzip-dev
   # helper packages
   ENV HELP_PCKGS less
# END Alpine settings ===-

# TODO: longer timeout would be nice, check this out for an elegant solution: 
# Step 22/23 : RUN wp core download --skip-content
# ---> Running in 8362634fa619
# Error: Failed to get url 'https://api.wordpress.org/core/version-check/1.7/?locale=en_US': cURL error 28: Operation timed out after 10000 milliseconds with 0 out of 0 bytes received.
# https://unix.stackexchange.com/questions/148922/set-timeout-for-web-page-response-with-curl

# Let's have a fun to happen

# install WP-CLI
RUN curl    --silent \
            --connect-timeout 60 \
            --output $WPCLI_NAME \
            $WPCLI_URL && \
    chmod +x $WPCLI_NAME

# install base packages
RUN apk upgrade && apk add --no-cache $BASE_PCKGS

# Compile and install ZipArhive which is not avaliable as Alpine's package
# it is requied by 'wp core download' in order to unpack an archive.
RUN apk add --no-cache $DEV0_PCKGS && \
    pecl install zip && \
    docker-php-ext-enable zip && \
# If $OBOX_DEBUG is set, development tools installed for ZipArhive compilation 
# are left unpurged, but also some helpel tools usefull for further play with 
# container are installed, othervise development tools are deleted
    [ $OBOX_DEBUG -ne 1 ] && apk del $DEV0_PCKGS || apk add --no-cache $HELP_PCKGS


# install packeges requied for connecting to database
RUN docker-php-ext-install mysqli pdo_mysql

# Test if $MYSQL_HOST is set to localhost', if so install mariaDB locally
# If variable is empty, assume that database shall be setup locally
RUN [ $(getent hosts $MYSQL_HOST | grep -e "\slocalhost$" | wc -l) -eq '1' ] && apk add --no-cache openrc mariadb 
#&& rc-update add mariadb default
# /etc/init.d/mariadb setup
# rc default

# prepare entrypoint
COPY files/entry.sh /
RUN chmod +x /entry.sh && mkdir /opt/deploy

# setup webserver files
WORKDIR /var/www/html

# install troubleshooting and info scripts: 
RUN mkdir _info
COPY files/info.php _info/index.php

# prepare continer to run: 
USER www-data:www-data
  # download Wordpress
RUN wp core download --skip-content

CMD ["/entry.sh"]
