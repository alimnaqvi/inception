#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

DATADIR="/var/lib/mysql"

# if /var/lib/mysql/mysql directory does not exist, this is the first run
if [ -d ${DATADIR}/mysql ]; then
    echo "Not the first run. Skipping initialization of MariaDB database."
else
    echo "First run detected. Initializing MariaDB database."
    echo "Running mariadb-install-db to initialize the MariaDB data directory (${DATADIR}) and create the system tables"
    mariadb-install-db --user=mysql --datadir="${DATADIR}"
    echo "Starting mariadb service"
    service mariadb start

    MARIADB_ROOT_PASSWORD=$(cat ${MARIADB_ROOT_PASSWORD_FILE})
    MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD_FILE})

    if [ -z "${MARIADB_ROOT_PASSWORD}" ] || [ -z "${MARIADB_DATABASE}" ] || [ -z "${MARIADB_USER}" ] || [ -z "${MARIADB_PASSWORD}" ]; then
        echo >&2 'Required environment variables are missing.'
        exit 1
    fi

    # Wait for the server to be ready
    for i in {30..0}; do
        if mariadb-admin ping &> /dev/null; then
            break
        fi
        echo 'MariaDB init process in progress...'
        sleep 1
    done
    if [ "$i" -eq 0 ]; then
        echo >&2 'MariaDB init process failed.'
        exit 1
    fi

    echo "mariadb service successfully started."

    # Set root password
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"

    # Create the application database if it doesn't exist
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"

    # Create the application user and grant privileges
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';"

    # Apply the changes
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

    echo "Shutting down the temporary mariadb server"

    # Shutdown the MariaDB server (CMD will start it again)
    mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
fi

# Create and permission the socket directory for the mysql user
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the MariaDB server to run as the main process (PID 1)
exec "$@"
