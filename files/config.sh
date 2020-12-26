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

function load() {
    echo "To be implemented"
}

# Reset password to random one for wordpress users 
# function is expecting a string argument 
# defining user's wordpress role: 
# ANYROLE - reset password for all users (assigned to any role)
# administrator
# editor
# author
# contributor
# subscriber - reset the password for user set assigned to a 
# specified wordpress role, e.g. 'administrator' - reset 
# password for all administrarors
# 
function resetpwd() {

    if [ -z $1 ]; then 
      echo "Plese provide argument: "
      echo "    ANYROLE, administrator, editor, author, contributor, subscriber"
      return 1
    fi

    ROLE=$([ "$1" = "ANYROLE" ] && echo "" || echo "--role=$1")

    echo "************************* ..."
    echo "* Login credentials: "
    for LOGIN in $(wp user list $ROLE --field=login | sort)
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
    resetpwd 'administrator'
  ;;

  *)
    echo "Usage: config.sh {dump <file name>|load <config>.yml|resetpwd}"
    echo ""
    echo ""
  ;;
esac

exit 0
