FROM php:7.3-cli-alpine3.9 AS obox_wordpress

LABEL maintainer="Mateusz Piwek <Mateusz @ teaFS.org>" \
      version="1.0 RC3" \
      obox.framework="wordpress"

ENV HTTP_EXP_PORT=8080
ENV HTTP_EXP_ADDR "0.0.0.0:"$HTTP_EXP_PORT

ENV OBOX_LOCAL_DB_DATA_PATH "/database"

EXPOSE $HTTP_EXP_PORT/tcp

ENV SITETITLE "Obox_wordpress setup"
ENV OBOX_DEBUG 1

# -=== BEGIN WP-CLI settings
   # WP-CLI download URL, default is an official URL: 
   ARG WPCLI_DOWNLOAD_URL='https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'

   # Full name (path and file name) of WP-CLI executable: 
   ENV WPCLI_NAME /usr/local/bin/wp
# END WP-CLI settings ===-

# -=== BEGIN Alpine settings
   # Base packages
   ENV BASE_PCKGS mariadb-client sudo
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

# TODO: in ubuntu /etc/resolv.conf is set to localhost (dns is handled by local instance of dnsmasq)
# it makes docker to set 8.8.8.8 and 8.8.4.4 in containers resovl.conf during build time
# since firewall is strict, deployment within docker fails ...
# therefore, do we really need dnsmasq in client machine? How to swith it off?

# install WP-CLI
RUN curl    --silent \
            --connect-timeout 60 \
            --output $WPCLI_NAME \
            $WPCLI_DOWNLOAD_URL && \
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


ADD --chown=root:root files/sudo_* /etc/sudoers.d/

# issue with: 
# >>> /etc/sudoers.d/sudo_finalize_setup: syntax error near line 1 <<<
# sudo: parse error in /etc/sudoers.d/sudo_finalize_setup near line 1
# sudo: no valid sudoers sources found, quitting
# sudo: unable to initialize policy plugin

# bypass it
RUN apk --no-cache add shadow && usermod -a -G wheel www-data

# prepare entrypoint
COPY files/entry.sh /
RUN chmod +x /entry.sh

ADD files/deploy_*.sh /opt/obox/
RUN chmod +x /opt/obox/deploy_*.sh

# setup webserver files
WORKDIR /var/www/html

# install troubleshooting and info scripts: 
RUN mkdir _info
COPY files/info.php _info/index.php

# prepare continer to run: 
USER www-data:www-data

# Download Wordpress
# if flag --skip-content is used, themes directory is not create leading 
# to an error while instaling theme
RUN wp core download --skip-content && mkdir -p ~/wp-content/themes


CMD ["/entry.sh"]
