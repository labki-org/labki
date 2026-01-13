# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CONTRIBUTING.md with contributor guidelines
- CHANGELOG.md for tracking releases
- CI badges in README

## [0.1.0] - 2026-01-13

### Added
- Initial runtime distribution
- Docker Compose setup with MariaDB and wiki services
- Jobrunner service for background jobs
- Configuration examples (`secrets.env.example`, `LocalSettings.user.php.example`)
- External database support (`docker-compose.external-db.yml`)
- Automated update script (`update.sh`)
- CI workflow with structure validation and smoke test
- Automatic GitHub releases on version tags
