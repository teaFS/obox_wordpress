#!/bin/sh

if [ ! -e "./wp-config.php" ]; then 
	echo "First run, deploying Wordpress"

#	export WPCLI='wp'

	for SCRIPT in `find /opt/deploy/ -name *.sh | sort`
	do 
		[ -x $SCRIPT ] && echo "Executing: $SCRIPT"; WPCLI=wp $SCRIPT;
	done
fi

echo "Server is running at $HTTP_EXP_PORT, usefull tools can be found under \"/_info\" path"

php -S $HTTP_EXP_ADDR -t .

exit 0
