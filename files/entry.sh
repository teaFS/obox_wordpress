#!/bin/sh
set -xe

# Set OBOX_MYSQL_HOST variable with: 
# If $MYSQL_HOST is empty, default to "localhost" 
# else copy settings from $MYSQL_HOST
[ -z "$MYSQL_HOST" ] && OBOX_MYSQL_HOST="localhost" || OBOX_MYSQL_HOST=$MYSQL_HOST;

# MYSQL_HOST_STATUS variable indicates: 
# if '0' - MySQL is set to localhost
# 
# 
MYSQL_HOST_STATUS=$(getent hosts $OBOX_MYSQL_HOST | egrep -q "\slocalhost$"; echo $?)

# install mariaDB locally
if [ $MYSQL_HOST_STATUS -eq '0' ]; then 
	apk add --no-cache mariadb

	# set random root password
	DB_ROOT_PASS=$(dd if=/dev/urandom status=none bs=1024 count=1 | md5sum | cut -c -16)
	DB_USER="mysql"
	DB_PASS=""
	
	mysql_install_db \ 
		--auth-root-authentication-method=socket \ 
		--skip-test-db \ 
		--datadir=${OBOX_LOCAL_DB_DATA_PATH}
fi


# start local mariaDB host
[ -x /etc/init.d/mariadb ] && cd '/usr' ; /usr/bin/mysqld_safe --datadir=${OBOX_LOCAL_DB_DATA_PATH} || true;


# Wait for mysql db first, so further code shall not fail :-)
mysql -u root --wait --connect-timeout=16 --reconnect=TRUE -e '\q'


# wp-config.php is missing, assume it's a first launch, therefore 
# run setup scripts
if [ ! -e "./wp-config.php" ]; then 

	echo "First launch, setting up obox_wordpress ..."

	DB_USER=$(id -un)

	# Create MySQL database for wordpress
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
