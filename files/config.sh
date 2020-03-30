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

dump
