#!/bin/bash
set -e

# Update this repo (to get new config defaults/scripts)
echo "Updating labki repo..."
git pull

# Pull the latest images defined in docker-compose.yml
# respect LABKI_VERSION if set in .env
echo "Pulling Docker images..."
docker compose pull

# Recreate containers
echo "Restarting containers..."
docker compose up -d

echo "Update complete! Visit http://localhost:8080"
