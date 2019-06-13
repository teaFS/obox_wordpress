#!/bin/sh
set -xe

# If $MYSQL_HOST is empty, default to "localhost", 
# else use settings from $MYSQL_HOST
[ -z "$MYSQL_HOST" ] && OBOX_MYSQL_HOST="localhost" || OBOX_MYSQL_HOST=$MYSQL_HOST;
MYSQL_HOST_STATUS=$(getent hosts $OBOX_MYSQL_HOST | egrep -q "\slocalhost$"; echo $?)

# && \
        # Just using remote host
#        true;

# install mariaDB locally
[ $MYSQL_HOST_STATUS -eq '0' ] && apk add --no-cache mariadb sudo || true;

# start local mariaDB host
#[ -x /etc/init.d/mariadb ] && /etc/init.d/mariadb start || true
#cd '/usr' ; /usr/bin/mysqld_safe --datadir='/database'

# Wait for mysql db first, so further code shall not fail :-)
mysql -u root --wait --connect-timeout=16 --reconnect=TRUE -e '\q'



if [ ! -e "./wp-config.php" ]; then 


	echo "First launch, setting up obox_wordpress ..."

	DB_USER=$(id -un)
	echo "Creating database: "
    echo "CREATE DATABASE $DB_NAME; CREATE USER $DB_USER;" | mysql -u root

# waive root privilages

	echo "Deploying Wordpress"
	for SCRIPT in `find /opt/deploy/ -name *.sh | sort`
	do 
		[ -x $SCRIPT ] && echo "Executing: $SCRIPT"; WPCLI=wp $SCRIPT;
	done
fi

echo "Server is running at $HTTP_EXP_PORT, usefull tools can be found under \"/_info\" path"

php -S $HTTP_EXP_ADDR -t .

exit 0
