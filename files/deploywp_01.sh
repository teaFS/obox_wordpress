#!/bin/sh
set -e

# SetenaSpace shop wp_cli deployment script
# 
# 

. /var/www/theme/theme.env


if [ -z "$WPCLI" ]; then 
	WPCLI=echo
fi

echo "WPCLI set to call '$WPCLI'"

DOMAIN="localhost"
APP_PATH="/"
URL=""

MISSING_ENV=0

if [ -z "$DOMAIN" ]; then 
	(>&2 echo "Enviroment variable DOMAIN is not set, while required") 
	MISSING_ENV=1
else
	if [ -z "$APP_PATH" ]; then 
		URL="http://$DOMAIN:$HTTP_EXP_PORT/"
	else
		URL="http://$DOMAIN:$HTTP_EXP_PORT/$APP_PATH/"
	fi
fi

# checkout if theme is ready to setup
if [ -z "$WP_THEME_NAME" ]; then 
	(>&2 echo "Enviroment variable PARENT_THEME_NAME is not set, while required")
	MISSING_ENV=1
fi

if [ -z "$WP_CHILD_THEME_NAME" ]; then 
	(>&2 echo "Enviroment variable CHILD_THEME_NAME is not set, while required")
	MISSING_ENV=1
fi

if [ -z "$WP_PLUGIN_LIST" ]; then 
	(>&2 echo "Enviroment variable WP_PLUGIN_LIST is not set, while required")
	MISSING_ENV=1
fi

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
$WPCLI option update blogdescription "$TAGLINE"

# Prepare and install theme
$WPCLI theme install $PARENT_THEME_NAME
ln -s /var/www/theme/src ./wp-content/themes/$CHILD_THEME_NAME
$WPCLI theme activate $CHILD_THEME_NAME

# install plugins
$WPCLI plugin install $WP_PLUGIN_LIST

exit 0
