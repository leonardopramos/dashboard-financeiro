#!/bin/sh
set -eu

# Railway fornece PORT dinamica; usa 8080 como padrao local
export PORT="${PORT:-8080}"
export VITE_API_BASE_URL="${VITE_API_BASE_URL:-http://localhost:8089/api}"

echo "Rendering nginx config for port ${PORT}"
envsubst '${PORT}' < /etc/nginx/templates/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Rendering runtime config"
envsubst '${VITE_API_BASE_URL}' < /etc/nginx/templates/runtime-config.template.js > /usr/share/nginx/html/runtime-config.js

echo "Starting nginx..."

exec nginx -g 'daemon off;'
