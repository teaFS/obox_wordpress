#!/bin/sh
set -xe

[ -x /etc/init.d/mariadb ] && /etc/init.d/mariadb start || true
cd '/usr' ; /usr/bin/mysqld_safe --datadir='/database'

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
