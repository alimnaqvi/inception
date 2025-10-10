#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

service mariadb start

# Read secrets from mounted files
# echo MARIADB_ROOT_PASSWORD_FILE: ${MARIADB_ROOT_PASSWORD_FILE} MARIADB_PASSWORD_FILE: ${MARIADB_PASSWORD_FILE}
# MARIADB_ROOT_PASSWORD=$(cat ${MARIADB_ROOT_PASSWORD_FILE})
# MARIADB_PASSWORD=$(cat ${MARIADB_PASSWORD_FILE})

# # Check if the data directory is empty (i.e., first run)
# # if [ -z "$(ls -A /var/lib/mysql)" ]; then
#     echo "First run detected - initializing database..."

#     # Initialize the MariaDB data directory
#     mariadb-install-db --user=mysql --datadir=/var/lib/mysql

#     # Start MariaDB in the background
#     mariadbd --user=mysql --datadir=/var/lib/mysql &
#     pid="$!"

#     # Wait for MariaDB to be ready
#     for i in {30..0}; do
#         if mariadb-admin ping >/dev/null 2>&1; then
#             break
#         fi
#         echo 'MariaDB initialization in progress...'
#         sleep 1
#     done
#     if [ "$i" = 0 ]; then
#         echo >&2 'MariaDB initialization failed.'
#         exit 1
#     fi

# echo MARIADB_ROOT_PASSWORD: "${MARIADB_ROOT_PASSWORD}" MARIADB_DATABASE: "${MARIADB_DATABASE}" MARIADB_USER: "${MARIADB_USER}" MARIADB_PASSWORD: "${MARIADB_PASSWORD}"
# Ensure environment variables are available
if [ -z "${MARIADB_ROOT_PASSWORD}" ] || [ -z "${MARIADB_DATABASE}" ] || [ -z "${MARIADB_USER}" ] || [ -z "${MARIADB_PASSWORD}" ]; then
    echo >&2 'Required environment variables are missing.'
    exit 1
fi

# Create a temporary SQL file
temp_sql_file=$(mktemp)

cat > "$temp_sql_file" <<-EOSQL
    -- Set root password
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';

    -- Create the application database if it doesn't exist
    CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;

    -- Create the application user and grant privileges
    CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';

    -- Apply the changes
    FLUSH PRIVILEGES;
EOSQL

# Execute the SQL file
mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" < "$temp_sql_file"

# Clean up the temp file
rm -f "$temp_sql_file"

#     # Shut down the temporary MariaDB server
#     if ! mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown; then
#         echo >&2 'MariaDB temporary server shutdown failed.'
#         exit 1
#     fi

#     # Wait for the server process to exit
#     wait "$pid"
#     echo "Database initialization complete."
# # fi

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the MariaDB server to run as the main process (PID 1)
# exec "$@"
