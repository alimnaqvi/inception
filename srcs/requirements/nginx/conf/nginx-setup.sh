#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

if [ -z "${MARIADB_DATABASE}" ] || [ -z "${SSL_CERTIFICATE_FILE}" ] || [ -z "${SSL_PRIVATE_KEY_FILE}" ]; then
    echo >&2 'Required environment variables are missing.'
    exit 1
fi

# Change nginx config file placeholders to the correct values from environment variables
sed --in-place \
-e "s#server_name <domain_name>#server_name ${MARIADB_DATABASE}#g" \
-e "s#ssl_certificate <ssl_certificate_file>#ssl_certificate ${SSL_CERTIFICATE_FILE}#g" \
-e "s#ssl_certificate_key <ssl_private_key_file>#ssl_certificate_key ${SSL_PRIVATE_KEY_FILE}#g" \
/etc/nginx/sites-available/default

# Pass execution to the command specified in the Dockerfile's CMD
# This allows the nginx server to run as the main process (PID 1)
exec "$@"
