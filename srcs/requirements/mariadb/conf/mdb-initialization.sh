#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# if /var/lib/mysql/wordpress directory does not exist, this is the first run
if [ -d /var/lib/mysql/${MARIADB_DATABASE} ]; then
    echo "Not the first run. Skipping initialization of MariaDB database."
else
    echo "First run detected. Initializing MariaDB database."
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

#     # Create a temporary SQL file
#     temp_sql_file=$(mktemp)

#     cat > "$temp_sql_file" <<-EOSQL
#         -- Set root password
#         ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';

#         -- Create the application database if it doesn't exist
#         CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;

#         -- Create the application user and grant privileges
#         CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';
#         GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';

#         -- Apply the changes
#         FLUSH PRIVILEGES;
# EOSQL

#     # Execute the SQL file
#     mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" < "$temp_sql_file"

#     # Clean up the temp file
#     rm -f "$temp_sql_file"

    # Set root password
    mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIADB_ROOT_PASSWORD}';"

    # Create the application database if it doesn't exist
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${MARIADB_DATABASE}\`;"

    # Create the application user and grant privileges
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS \`${MARIADB_USER}\`@'%' IDENTIFIED BY '${MARIADB_PASSWORD}';"
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${MARIADB_DATABASE}\`.* TO \`${MARIADB_USER}\`@'%';"

    # Apply the changes
    mariadb -u root -p"${MARIADB_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;"

    # Shutdown the MariaDB server (entrypoint will start it again)
    mariadb-admin -u root -p"${MARIADB_ROOT_PASSWORD}" shutdown
fi

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the MariaDB server to run as the main process (PID 1)
exec "$@"
