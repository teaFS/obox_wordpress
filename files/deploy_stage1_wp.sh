#!/bin/sh
set -e

#function validate_pluginname() {
#	sed $1
#}

if [ -z "$WPCLI" ]; then 
	WPCLI=echo
fi

echo "WPCLI set to call '$WPCLI'"

DOMAIN="localhost"
APP_PATH=""
URL=""

ADMIN_USER=""
ADMIN_EMAIL="admin@example.com"

MISSING_ENV=0
INVALID_ENV=0

if [ -z "$DOMAIN" ]; then 
	(>&2 echo "Enviroment variable DOMAIN is not set, while required") 
	MISSING_ENV=1
else
	URL="http://$DOMAIN:$HTTP_EXP_PORT/$APP_PATH"
fi

# Test variables for source theme configuration
if [ -f /var/www/theme/theme.env ]; then 
	# load configuration for custom theme
	. /var/www/theme/theme.env
	echo "Using source theme"

	# checkout if theme is ready to setup
	if [ -z "$THEME_NAME" ]; then 
		(>&2 echo "Enviroment variable THEME_NAME is not set, while required")
		MISSING_ENV=1
	fi

	if [ -z "$TEMPL_NAME" ]; then 
		(>&2 echo "Enviroment variable TEMPL_NAME is not set, while required")
		MISSING_ENV=1
	fi
fi

# ensure that WP_PLUGIN_LIST variable is set
if ! echo "$WP_PLUGIN_LIST" | grep -e '^[A-Za-z0-9|\-|\ ]*$' ; then 
	(>&2 echo "Enviroment variable WP_PLUGIN_LIST is not valid")
	INVALID_ENV=1
fi

# don't deploy if any required enviromental value is missing
if [ $MISSING_ENV -ne 0 ]; then
	exit 1
fi

if [ $INVALID_ENV -ne 0 ]; then
	exit 2
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

# Insatll and activate theme
for p in $(echo $WP_THEME_LIST $TEMPL_NAME | sed 's/^\s*//;s/\s*$//;s/\s\s*/\n/g')
do
	$WPCLI theme install $p
done

# If theme's source is set, make this very theme as an active
if [ -n "$THEME_NAME" ]; then 
	mkdir -p ./wp-content/themes
	ln -s /var/www/theme/src ./wp-content/themes/$THEME_NAME
	THEME_TO_ACTIVATE=$THEME_NAME
fi

if [ -n "$THEME_TO_ACTIVATE" ]; then 
	$WPCLI theme is-installed $THEME_TO_ACTIVATE || \
		$WPCLI theme install $THEME_TO_ACTIVATE
	
	$WPCLI theme is-active $THEME_TO_ACTIVATE || \
		echo "Theme $THEME_TO_ACTIVATE is aready active" && \
		$WPCLI theme activate $THEME_TO_ACTIVATE
fi

# install and activate plugins
for p in $(echo $WP_PLUGIN_LIST | sed 's/^\s*//;s/\s*$//;s/\s\s*/\n/g')
do
	$WPCLI plugin install $p
done

for p in $(echo $WP_PLUGIN_LIST_ACTIVATE | sed 's/^\s*//;s/\s*$//;s/\s\s*/\n/g')
do
	$WPCLI plugin install $p --activate
done

### setup upload_path
#wp media import $(find ~/data/datmar/uploads/ -type f | egrep -v "\-[0-9]+x[0-9]+.[a-Z]+")
#wp option get upload_path
#media

#wp option get upload_url_path
#https://example.com/media


exit 0

