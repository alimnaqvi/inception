#!/bin/bash
set -e

ROOT_DIR="/var/www/html"
WP_DOWNLOAD="/wordpress-download/wordpress.tar.gz"

# Add logic to wait for MariaDB to be ready? (should be handled by depends_on in compose)

if [ -f ${ROOT_DIR}/wp-config.php ]; then
    echo "Not the first run. Skipping WordPress setup."
else
    echo "First run detected. Installing and setting up WordPress."

    # if [ -z ${WORDPRESS_VERSION} ] || [ -z ${WORDPRESS_SHA1} ]; then
    #     echo "WORDPRESS_VERSION or WORDPRESS_SHA1 environment variable is NOT set."
    #     exit 1
    # fi

    if [ -z ${WORDPRESS_SHA1} ]; then
        echo "WORDPRESS_SHA1 environment variable is NOT set."
        exit 1
    fi

    # Download and install WordPress
    # echo "making dir"
    mkdir -p ${ROOT_DIR}
    # echo "changing dir"
    cd ${ROOT_DIR}
    # curl -o wordpress.tar.gz https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz
    # echo "verifying checksum"
    echo "${WORDPRESS_SHA1} ${WP_DOWNLOAD}" | sha1sum -c -
    # echo "extracting files"
    tar -xzf ${WP_DOWNLOAD} --strip-components=1 --directory ${ROOT_DIR}
    # echo "removing download"
    rm ${WP_DOWNLOAD}

    # Generate WordPress salts
    # echo "getting salt"
    SALT=$(curl -s https://api.wordpress.org/secret-key/1.1/salt/)
    MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD_FILE})

    # echo "starting heredoc"
    cat > ${ROOT_DIR}/wp-config.php <<-EOWP

<?php

/** The name of the database for WordPress */
define( 'DB_NAME', '${MARIADB_DATABASE}' );

/** Database username */
define( 'DB_USER', '${MARIADB_USER}' );

/** Database password */
define( 'DB_PASSWORD', '${MARIADB_PASSWORD}' );

/** Database hostname */
define( 'DB_HOST', 'localhost' );

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



/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
        define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';

EOWP

    # echo "heredoc complete"

fi

# Ensure proper permissions?

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the php-fpm to run as the main process (PID 1)
# echo "passing execution to main process"
exec "$@"
