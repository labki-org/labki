#!/bin/bash
set -e

cd "$(dirname "$0")"

# Production installs run behind Caddy (SITE_DOMAIN set in .env); include
# its override so the proxy is pulled and recreated along with the wiki.
COMPOSE=(docker compose -f docker-compose.yml)
if [ -f .env ] && grep -qE '^SITE_DOMAIN=.+' .env; then
    COMPOSE+=(-f docker-compose.caddy.yml)
fi

# Update this repo (to get new config defaults/scripts)
echo "Updating labki repo..."
git pull

# Pull the latest images defined in docker-compose.yml
# respect LABKI_VERSION if set in .env
echo "Pulling Docker images..."
"${COMPOSE[@]}" pull

# Recreate containers
echo "Restarting containers..."
"${COMPOSE[@]}" up -d

echo "Update complete!"
