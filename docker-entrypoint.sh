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
MAX_RETRIES=60
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  # Use a simple TCP connection test as a fallback, or try mysql connection
  if nc -z "${DATABASE_HOST:-mysql}" 3306 2>/dev/null || mysql -h"${DATABASE_HOST:-mysql}" -u"${DATABASE_USER:-tunnelmole}" -p"${DATABASE_PASSWORD:-tunnelmole}" -e "SELECT 1" 2>/dev/null; then
    echo "MySQL is ready!"
    break
  fi
  RETRY_COUNT=$((RETRY_COUNT + 1))
  if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
    echo "Warning: MySQL connection check timed out after $MAX_RETRIES attempts. Continuing anyway..."
    break
  fi
  echo "MySQL not ready yet, retrying... ($RETRY_COUNT/$MAX_RETRIES)"
  sleep 2
done

# Execute the main command
exec "$@"

