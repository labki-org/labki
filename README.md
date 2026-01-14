# Labki Runtime

[![CI](https://github.com/labki-org/labki/actions/workflows/ci.yml/badge.svg)](https://github.com/labki-org/labki/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/labki-org/labki)](LICENSE)

Welcome to the Labki MediaWiki runtime repository. This repository allows you to run a production-ready MediaWiki instance using the Labki Platform Docker images.

**Core Philosophy:**
- **Immutable Image**: The platform code is in the Docker image and is read-only.
- **Mutable Instance**: Your configuration, data, and added extensions survive upgrades.

## Quick Start

### 1. Configure Secrets

> [!CAUTION]
> **Never commit secrets.env to git!** It contains passwords and is gitignored by default.

```bash
cp config/secrets.env.example config/secrets.env
```

Edit `config/secrets.env` and **change all passwords**:
- `MW_ADMIN_PASS` - Your wiki admin password
- `MW_DB_PASSWORD` and `MARIADB_PASSWORD` - Database access password (must match!)
- `MARIADB_ROOT_PASSWORD` - Database root password

Generate secure passwords with: `openssl rand -base64 24`

### 2. Start the Wiki (Local Development)

```bash
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d
```

### 3. Access

Open [http://localhost:8080](http://localhost:8080) in your browser.

> [!NOTE]
> The base `docker-compose.yml` does not expose any ports (production-safe). Use `docker-compose.dev.yml` for local development or `docker-compose.caddy.yml` for production HTTPS.

## Production Deployment with HTTPS

For production deployments, use the included Caddy reverse proxy for automatic HTTPS:

### 1. Configure Your Domain

Set your domain in the `.env` file:
```bash
cp .env.example .env
# Edit .env and set:
SITE_DOMAIN=labki.org
```

Also update `config/secrets.env` to set `MW_SERVER` to your full URL:
```bash
MW_SERVER=https://labki.org
```

### 2. Start with Caddy

```bash
docker compose -f docker-compose.yml -f docker-compose.caddy.yml up -d
```

Caddy will automatically:
- Obtain a Let's Encrypt TLS certificate for your domain
- Redirect HTTP → HTTPS
- Renew certificates before expiry

> [!IMPORTANT]
> Ensure your domain's DNS A record points to your server's IP address, and that ports 80 and 443 are open in your firewall.

### 3. DNS & Firewall Checklist

- [ ] DNS A record for `your-domain.com` → `<your-server-ip>`
- [ ] Firewall allows inbound TCP 80 (HTTP) and 443 (HTTPS)
- [ ] If using a cloud provider, security group allows 80/443

## Configuration

> [!CAUTION]
> **Never edit `/var/www/html/LocalSettings.php` inside the container!** This file is auto-generated and will be overwritten on restart. Always edit `config/LocalSettings.user.php` instead.

### File Overview

| File | Purpose | Edit This? |
|------|---------|------------|
| `config/secrets.env` | Passwords, DB credentials, site identity | ✅ Yes |
| `config/LocalSettings.user.php` | MediaWiki settings, extensions, overrides | ✅ Yes |
| `LocalSettings.php` (in container) | Auto-generated loader | ❌ Never |

### Site & Database

Edit `config/secrets.env` to change:
- Site Name and Language
- Database credentials
- Admin account initial password

### MediaWiki Settings

Edit `config/LocalSettings.user.php` to customize MediaWiki. This file is loaded **last**, giving it the highest precedence to override any platform defaults.

```php
<?php
// Example: Allow logged-in users to edit
$wgGroupPermissions['user']['edit'] = true;

// Example: Change the logo
$wgLogo = "/images/my-logo.png";
```

Most changes take effect immediately. Restart only if loading new extensions:
```bash
docker compose restart wiki
```

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
## Versioning

This project follows [Semantic Versioning](https://semver.org/).
- **Releases**: Created automatically when a `vX.Y.Z` tag is pushed.
- **Compatibility**: The runtime version is independent of the `labki-platform` image version.

## Upgrading

To upgrade the Labki Platform (get new MediaWiki versions, security fixes, and bundled extension updates):

Run the automated update script:
```bash
./update.sh
```

Or manually:
```bash
# 1. Update this repository (for new config defaults)
git pull

# 2. Pull the latest Docker images
docker compose pull

# 3. Recreate containers (your data is safe!)
docker compose up -d
```

## Version Pinning

To pin your wiki to a specific version of the Labki Platform (e.g., for stability):

1.  Copy `.env.example` to `.env`.
2.  Set your desired version and domain (if using Caddy):
    ```ini
    LABKI_VERSION=1.39.5
    SITE_DOMAIN=labki.org
    ```
3.  Restart containers: `./update.sh`


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

### Windows Line Endings (CRLF)
If containers crash with `command not found` or `\r` errors in logs:
Run `dos2unix config/secrets.env` or `sed -i 's/\r$//' config/secrets.env` to fix Windows line endings.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Resources

- [Changelog](CHANGELOG.md) - Release history
- [Labki Platform](https://github.com/labki-org/labki-platform) - Source for the Docker image
