# Obox_wordpress
(Docker image suited for Wordpress) meant for developers

Wordpres is internet's number one web publishing software originally developed as a blogging platform in 2003, but nowadays being an advanced framework for building a web services.

The Obox_wordpress has been developed to automatize Wordpress deployment. It is Alpine Linux based Docker image holding Wordpres with WP-CLI tool and set of helper scripts. It can be launched as: 
* independent container - which uses local MySQL database
* linked to an external MySQL database

## Quick Wordpress setup
Launching empty Wordpress: 
```
docker run --name "My WP Instance" -d entrproc/obox_wordpress
```
Let's introduce some fun: 
```
docker run --name "My WP Instance" -e WP_PLUGIN_LIST="smart-grid-gallery core-sitemaps" entrproc/obox_wordpress
```


### Wordpress settings

#### WP_THEME_LIST
Space sepearted list of themes

#### WP_THEME_ACTIVATE
Name of the them to be activated

#### WP_PLUGIN_LIST
Space separated list of plugins for installation
#### WP_PLUGIN_LIST_ACTIVATE
Space separated list of plugins for installation and activation

### Site settings
SITETITLE
TAGLINE

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




### build arguments
WPCLI_DOWNLOAD_URL
http://bestlocalnetwork/ires/wp-cli.org/wp-cli.phar

