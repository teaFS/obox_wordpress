#!/bin/sh
set -xe

# Set OBOX_MYSQL_HOST variable with: 
# If $MYSQL_HOST is empty, default to "localhost" 
# else copy settings from $MYSQL_HOST
[ -z "$MYSQL_HOST" ] && OBOX_MYSQL_HOST="localhost" || OBOX_MYSQL_HOST=$MYSQL_HOST;

# MYSQL_HOST_STATUS variable indicates: 
# if '0' - MySQL is set to localhost
# if '1' - MySQL is set at an external server
# 
MYSQL_HOST_STATUS=$(getent hosts $OBOX_MYSQL_HOST | egrep -q "\slocalhost$"; echo $?)
# Regular launch is not a first launchl - first continer's launch shall 
# REGULAR_LAUNCH env is empty, following runs shall hold no-zero 
# value
REGULAR_LAUNCH=$([ -e "./wp-config.php" ] && echo 'y' || true)

# install mariaDB locally - if it's not a regular launch
if [ $MYSQL_HOST_STATUS -eq '0' ] && [ -z $REGULAR_LAUNCH ]; then 
	sudo apk add --no-cache mariadb

	# set random root password
	DB_ROOT_PASS=$(dd if=/dev/urandom status=none bs=1024 count=1 | md5sum | cut -c -16)
	DB_PASS=""

	#sudo apk add --no-cache expect
	#sudo /usr/bin/mysql_secure_installation 
	# sudo apk del expect
	# https://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script
	# https://gist.github.com/Mins/4602864

	sudo mysql_install_db \
		--auth-root-authentication-method=socket \
		--skip-test-db \
		--user=mysql \
		--datadir='${OBOX_LOCAL_DB_DATA_PATH}/data'
fi


#You can test the MariaDB daemon with mysql-test-run.pl
#cd '/usr/mysql-test' ; perl mysql-test-run.pl

# start local mariaDB host - if continer is configured for a local database
if [ $MYSQL_HOST_STATUS -eq '0' ]; then 
	# launch local mysql server
	cd '/usr' ; \
	sudo /usr/bin/mysqld_safe \
			--nowatch \
			--datadir=${OBOX_LOCAL_DB_DATA_PATH}/data
else
	# Wait for mysql server to ensure that database is up and available
	mysql -u root \
		--wait \
		--connect-timeout=16 \
		--reconnect=TRUE \
		-e '\q'
fi

# wp-config.php is missing, assume it's a first launch, therefore 
# run setup scripts
if [ -z $REGULAR_LAUNCH ]; then 
	echo "Setting up obox_wordpress ..."

	DB_USER=$(id -un)
	DB_USER_PASS=$(dd if=/dev/urandom status=none bs=1024 count=1 | md5sum | cut -c -12)

	# Create MySQL database for wordpress
	# if database name is not provided, set default value
	[ -z $DB_NAME ] && DB_NAME='wp' || true;

	echo "Creating database: "
    sudo mysql -e "CREATE DATABASE $DB_NAME; CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_USER_PASS'; GRANT ALL PRIVILEGES ON *.$DB_NAME TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"

	# waive root privilages

	echo "Deploying Wordpress"
#	for SCRIPT in `find /opt/deploy/ -name *.sh | sort`
#	do 
#		[ -x $SCRIPT ] && echo "Executing: $SCRIPT"; WPCLI=wp $SCRIPT;
#	done
fi

echo "Server is running at $HTTP_EXP_PORT, usefull tools can be found under \"/_info\" path"

php -S $HTTP_EXP_ADDR -t .

exit 0
