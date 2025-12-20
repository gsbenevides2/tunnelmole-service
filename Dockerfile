# Use Node.js 18 Alpine as base image
FROM node:18-alpine

# Install MySQL client for database initialization
RUN apk add --no-cache mysql-client python3 make g++

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install all dependencies (including dev dependencies for build)
RUN npm ci

# Copy TypeScript config and source files
COPY tsconfig.json ./
COPY babel.config.js ./
COPY . .

# Build TypeScript to JavaScript
RUN npm run build

# Remove dev dependencies to reduce image size
RUN npm prune --production

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Expose HTTP and WebSocket ports
EXPOSE 8000 8080

# Use entrypoint script
ENTRYPOINT ["docker-entrypoint.sh"]

# Use production start command
CMD ["node", "dist/srv/index.js"]

