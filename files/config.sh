#!/bin/sh
[ $OBOX_DEBUG -ne 0 ] && set -xe || set -e

if [ -z "$WPCLI" ]; then 
	WPCLI=echo
fi

# https://en.wikipedia.org/wiki/YAML
# Non-hierarchical data models

#-e "WP_THEME_ACTIVATE=twentytwenty"
#-e "WP_PLUGIN_LIST_ACTIVATE=all-in-one-seo-pack google-sitemap-generator wp-sitemap-page"

function dump() {
    $WPCLI theme list --format=yaml
    $WPCLI plugin list --format=yaml
}

function resetpwd() {
    echo "************************* ..."
    echo "* Login credentials: "
    for LOGIN in $(wp user list --role=administrator --field=login | sort)
    do
	    LOGIN_PASS=$(dd if=/dev/urandom status=none bs=1024 count=1 | md5sum | cut -c -8)

	    wp user update $LOGIN --user_pass=$LOGIN_PASS --skip-email
	    echo "$LOGIN/$LOGIN_PASS"
    done
    echo "************************* ..."
}

case "$1" in 
  dump)
    dump
  ;;

  resetpwd)
    resetpwd
  ;;

  *)
    echo "Usage: config.sh {dump|load <config>.yml|resetpwd}"
  ;;
esac