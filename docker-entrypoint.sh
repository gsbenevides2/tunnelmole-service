#!/bin/sh
set -e

# Generate config-instance.toml from environment variables
cat > config-instance.toml <<EOF
environment = "${ENVIRONMENT:-production}"

[server]
httpPort = ${HTTP_PORT:-8000}
websocketPort = ${WEBSOCKET_PORT:-8080}
domain = '${DOMAIN:-localhost}'
password = '${SERVER_PASSWORD:-changeme}'

bannedIps = []

bannedClientIds = []

bannedHostnames = []

[mysql]
host = '${DATABASE_HOST:-mysql}'
user = '${DATABASE_USER:-tunnelmole}'
password = '${DATABASE_PASSWORD:-tunnelmole}'
database = '${DATABASE_NAME:-tunnelmole}'

[runtime]
debug = ${DEBUG:-false}
enableLogging = ${ENABLE_LOGGING:-false}
connectionTimeout = ${CONNECTION_TIMEOUT:-43200}
timeoutCheckFrequency = ${TIMEOUT_CHECK_FREQUENCY:-5000}
EOF

# Wait for MySQL to be ready
echo "Waiting for MySQL to be ready..."
until mysql -h"${DATABASE_HOST:-mysql}" -u"${DATABASE_USER:-tunnelmole}" -p"${DATABASE_PASSWORD:-tunnelmole}" -e "SELECT 1" &> /dev/null; do
  sleep 1
done

echo "MySQL is ready!"

# Execute the main command
exec "$@"

