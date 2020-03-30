#!/bin/sh
set -e


[ -f /var/www/theme/theme.env ] && \
	. /var/www/theme/theme.env || \
	echo "Using default theme settings"

#ls /var/www/theme/theme.env && \
#	. /var/www/theme/theme.env || \
#	echo "Using default theme settings"


if [ -z "$WPCLI" ]; then 
	WPCLI=echo
fi

echo "WPCLI set to call '$WPCLI'"

DOMAIN="localhost"
APP_PATH=""
URL=""

ADMIN_USER="admin"
ADMIN_EMAIL="admin@example.com"

MISSING_ENV=0

if [ -z "$DOMAIN" ]; then 
	(>&2 echo "Enviroment variable DOMAIN is not set, while required") 
	MISSING_ENV=1
else
	URL="http://$DOMAIN:$HTTP_EXP_PORT/$APP_PATH"
fi

# checkout if theme is ready to setup
#if [ -z "$WP_THEME_NAME" ]; then 
#	(>&2 echo "Enviroment variable PARENT_THEME_NAME is not set, while required")
#	MISSING_ENV=1
#fi

#if [ -z "$WP_CHILD_THEME_NAME" ]; then 
#	(>&2 echo "Enviroment variable CHILD_THEME_NAME is not set, while required")
#	MISSING_ENV=1
#fi

#if [ -z "$WP_PLUGIN_LIST" ]; then 
#	(>&2 echo "Enviroment variable WP_PLUGIN_LIST is not set, while required")
#	MISSING_ENV=1
#fi

# don't deploy if any required enviromental value is missing
if [ $MISSING_ENV -ne 0 ]; then
	exit 1
fi

echo "Setting up: $URL"

$WPCLI core install \
      --url="$URL" \
      --admin_user=$ADMIN_USER \
      --admin_email=$ADMIN_EMAIL --skip-email \
	  --title="$SITETITLE"

# title is stored in 'blogname' option

# Update blog's description
if [ -n "$TAGLINE" ]; then 
	$WPCLI option update blogdescription "$TAGLINE"
fi

#THEME_TO_ACTIVATE=""

# Prepare and install theme
if [ -n "$WP_THEME_LIST" ]; then
	$WPCLI theme install $WP_THEME_LIST
	#THEME_TO_ACTIVATE="$THEME_NAME"
fi

#if [ -n "$LOCAL_THEME_NAME" ]; then 
#	ln -s /var/www/theme/src ./wp-content/themes/$LOCAL_THEME_NAME
#	THEME_TO_ACTIVATE="$LOCAL_THEME_NAME"
#fi

if [ -n "$WP_THEME_ACTIVATE" ]; then 
	$WPCLI theme activate $WP_THEME_ACTIVATE
fi

# install plugins
if [ -n "$WP_PLUGIN_LIST" ]; then 
	$WPCLI plugin install $WP_PLUGIN_LIST
fi

if [ -n "$WP_PLUGIN_LIST_ACTIVATE" ]; then 
	$WPCLI plugin install $WP_PLUGIN_LIST --activate
fi

exit 0
