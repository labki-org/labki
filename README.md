# Labki Runtime

Welcome to the Labki MediaWiki runtime repository. This repository allows you to run a production-ready MediaWiki instance using the Labki Platform Docker images.

**Core Philosophy:**
- **Immutable Image**: The platform code is in the Docker image and is read-only.
- **Mutable Instance**: Your configuration, data, and added extensions survive upgrades.

## Quick Start

1. **Configure Secrets**
   Copy the example secrets file and edit it to set your admin password and site name.
   ```bash
   cp config/secrets.env.example config/secrets.env
   # Edit the file with your favorite editor
   # nano config/secrets.env
   ```

2. **Start the Wiki**
   Run the following command to start MediaWiki and the bundled MariaDB database.
   ```bash
   docker compose up -d
   ```

3. **Access**
   Open [http://localhost:8080](http://localhost:8080) in your browser.

## Configuration

### Site & Database
Edit `config/secrets.env` to change:
- Site Name and Language
- Database credentials
- Admin account initial password

### MediaWiki Settings
Edit `config/LocalSettings.user.php` to add custom MediaWiki configuration. This file is loaded *after* the platform defaults, allowing you to override almost anything.

## Managing Extensions

The Labki Platform comes with many bundled extensions. To add your own:

1. **Download/Clone the Extension**
   Place the extension code in the `mw-user-extensions` directory.
   ```bash
   cd mw-user-extensions
   git clone https://github.com/wikimedia/mediawiki-extensions-MyExtension MyExtension
   ```

2. **Enable the Extension**
   Edit `config/LocalSettings.user.php` and add the load command:
   ```php
   wfLoadExtension( 'MyExtension', '/mw-user-extensions/MyExtension/extension.json' );
   ```

3. **Apply Changes**
   Restart the containers to ensure any new PHP classes are picked up (though often immediate for config changes).
   ```bash
   docker compose restart wiki
   ```

## Upgrading

To upgrade the Labki Platform (get new MediaWiki versions, security fixes, and bundled extension updates):

```bash
# 1. Update this repository (for new config defaults)
git pull

# 2. Pull the latest Docker images
docker compose pull

# 3. Recreate containers (your data is safe!)
docker compose up -d
```

## Advanced: External Database

To use an external database (e.g., AWS RDS) instead of the bundled MariaDB container:

1. Edit `config/secrets.env` with your external DB credentials.
2. Run docker-compose with the external-db override:
   ```bash
   docker compose -f docker-compose.yml -f docker-compose.external-db.yml up -d
   ```

## Troubleshooting & Maintenance

### Resetting the Database
**WARNING: THIS WILL DELETE ALL WIKI PAGES AND USERS.**

To completely wipe the database and start fresh:
```bash
docker compose down -v
```

### Logs
View logs for debugging:
```bash
docker compose logs -f wiki
```
