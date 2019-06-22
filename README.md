# obox_wordpress
(Docker container compilation of a Wordpress web publishing software) meant for developers

# apk list -I php*

### Database settings

#### MYSQL_HOST
If MYSQL_HOST variable is not set, or set to indicate localhost, Wordpress will be configured for using local (in the same container) MySQL database.
In order to use an external databse, MYSQL_HOST should indicate accesible host, 

#### DB_USER
Database user name if not set default 'mysql' is used

#### DB_PASS
Passowrd for given user name

#### DB_NAME
Name of the MySQL database to be used by Wordpres setup


### Wordpress settings
DOMAIN: localhost

#### WP_PLUGIN_LIST


