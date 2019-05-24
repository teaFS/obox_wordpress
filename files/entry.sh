#!/bin/sh

# probe for MariaDB connection over TCP

# If MariaDB is linked from other continer, probe network connection before launching server
# if $MYSQL_HOST is not set, or set as 'localhost', or '127.0.0.1', or '::1' 
mysql  -u root --wait --connect-timeout=1 --reconnect=TRUE -e '\q'

[ $(grep -w $MYSQL_HOST </etc/hosts 2&>/dev/null | grep -w localhost | wc -l) == 0 ] && wait_for_net_maria;

if [ ! -e "./wp-config.php" ]; then 
	echo "First run, deploying Wordpress"

#	export WPCLI='wp'
# check if database is ready

	for SCRIPT in `find /opt/deploy/ -name *.sh | sort`
	do 
		[ -x $SCRIPT ] && echo "Executing: $SCRIPT"; WPCLI=wp $SCRIPT;
	done
fi

echo "Server is running at $HTTP_EXP_PORT, usefull tools can be found under \"/_info\" path"

php -S $HTTP_EXP_ADDR -t .

exit 0
