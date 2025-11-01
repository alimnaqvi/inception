#!/bin/bash
set -e

ROOT_DIR="/var/www/html"
WP_DOWNLOAD="/wordpress-download/wordpress.tar.gz"
DB_SERVICE_NAME="mariadb"
PHP_FPM_CONF_FILE_PATH="/etc/php/8.2/fpm/pool.d/www.conf"

cat_then_grep() {
    cat $1 | grep $2
}

# Ensure php-fpm listens on port 9000
if [[ $(cat_then_grep ${PHP_FPM_CONF_FILE_PATH} "listen") == *"listen = 9000"* ]]; then
    echo "php-fpm configuration is already set to listen on port 9000."
else
    echo "Setting php-fpm configuration to listen on port 9000."
    echo "listen = 9000" >> ${PHP_FPM_CONF_FILE_PATH}
fi

if [ -f ${ROOT_DIR}/wp-config.php ]; then
    echo "Not the first run. Skipping WordPress setup."
else
    echo "First run detected. Installing and setting up WordPress."

    if [ -z ${WORDPRESS_SHA1} ]; then
        echo "WORDPRESS_SHA1 environment variable is NOT set."
        exit 1
    fi

    # Download and install WordPress
    mkdir -p ${ROOT_DIR}
    cd ${ROOT_DIR}
    # curl -o wordpress.tar.gz https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz
    echo "${WORDPRESS_SHA1} ${WP_DOWNLOAD}" | sha1sum -c -
    tar -xzf ${WP_DOWNLOAD} --strip-components=1 --directory ${ROOT_DIR}
    rm ${WP_DOWNLOAD}

    # Ensure proper permissions before creating config
    chown -R www-data:www-data ${ROOT_DIR}

    # Generate WordPress salts
    SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD_FILE})

    cat > ${ROOT_DIR}/wp-config.php <<-EOWP

<?php

/** The name of the database for WordPress */
define( 'DB_NAME', '${MARIADB_DATABASE}' );

/** Database username */
define( 'DB_USER', '${MARIADB_USER}' );

/** Database password */
define( 'DB_PASSWORD', '${MARIADB_PASSWORD}' );

/** Database hostname */
define( 'DB_HOST', '${DB_SERVICE_NAME}' );

/** Database charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The database collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

${SALT}

/**#@-*/

\$table_prefix = 'wp_';

/**
* For developers: WordPress debugging mode.
*
* Change this to true to enable the display of notices during development.
* It is strongly recommended that plugin and theme developers use WP_DEBUG
* in their development environments.
*
* For information on other constants that can be used for debugging,
* visit the documentation.
*
* @link https://developer.wordpress.org/advanced-administration/debug/debug-wordpress/
*/
define( 'WP_DEBUG', false );

/* Add any custom values between this line and the "stop editing" line. */

if (isset(\$_SERVER['HTTP_X_FORWARDED_PROTO']) && \$_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https') {
    \$_SERVER['HTTPS'] = 'on';
}

if (isset(\$_SERVER['HTTP_HOST'])) {
    define('WP_HOME', 'https://' . \$_SERVER['HTTP_HOST']);
    define('WP_SITEURL', 'https://' . \$_SERVER['HTTP_HOST']);
}

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

EOWP

    # # Wait for the database to be ready
    # echo "Waiting for MariaDB..."
    # until runuser -u www-data -- wp db query 'SELECT 1;' --path=${ROOT_DIR} --quiet; do
    #     sleep 1
    # done
    # echo "MariaDB is ready."
    sleep 5

    MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD_FILE})
    WORDPRESS_ADMIN_PASSWORD=$(cat ${WORDPRESS_ADMIN_PASSWORD_FILE})
    WORDPRESS_USER_PASSWORD=$(cat ${WORDPRESS_USER_PASSWORD_FILE})

    # Install WordPress and create users
    echo "Installing WordPress and creating users"
    runuser -u www-data -- wp core install --url="${DOMAIN_NAME}" --title="${WORDPRESS_TITLE}" --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_EMAIL} --path=${ROOT_DIR}
    runuser -u www-data -- wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} --role=author --user_pass=${WORDPRESS_USER_PASSWORD} --path=${ROOT_DIR}

fi

# Ensure proper permissions
chown -R www-data:www-data /var/www/html

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the php-fpm to run as the main process (PID 1)
exec "$@"
