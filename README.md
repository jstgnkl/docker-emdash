# docker-emdash

[![Build and Push Docker Image](https://github.com/jstgnkl/docker-emdash/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/jstgnkl/docker-emdash/actions/workflows/build-and-push.yml)

Docker image for [EmDash](https://github.com/emdash-cms/emdash), the Astro-based CMS. Runs the blog template with Node.js and SQLite -- no Cloudflare account required.

## Image tags

| Tag | Description |
|-----|-------------|
| `latest` | Nightly build from the latest upstream source |
| `x.y.z` (e.g. `1.0.0`) | Verified working release, manually checked |

## Quick start

```bash
docker run -d -p 4321:4321 jstgnkl/emdash:latest
```

Open http://localhost:4321 for the site and http://localhost:4321/_emdash/admin for the admin panel.

## Docker Compose (recommended)

```yaml
name: emdash

services:
  emdash:
    image: jstgnkl/emdash:latest
    container_name: emdash
    ports:
      - "4321:4321"
    volumes:
      - emdash-data:/app/data
      - emdash-uploads:/app/uploads
    restart: unless-stopped

volumes:
  emdash-data:
  emdash-uploads:
```

```bash
docker compose up -d
docker compose down      # stop
docker compose logs -f   # tail logs
docker compose down -v   # stop and delete all data
```

## Reverse proxy setup

When running behind a TLS-terminating reverse proxy (Traefik, Caddy, nginx, etc.), configure `security.allowedDomains` and `passkeyPublicOrigin` in `astro.config.mjs` before building the image. See the [EmDash configuration docs](https://emdash.dev/reference/configuration/) for details.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST` | `0.0.0.0` | Address to bind |
| `PORT` | `4321` | Port to listen on |

To change the port mapping:

```yaml
ports:
  - "8080:4321"
```

## Volumes

| Volume | Container path | Purpose |
|--------|---------------|---------|
| `emdash-data` | `/app/data` | SQLite database |
| `emdash-uploads` | `/app/uploads` | Uploaded media files |

## Building from source

To build the image yourself from the [emdash source](https://github.com/emdash-cms/emdash):

```bash
git clone https://github.com/emdash-cms/emdash.git
docker build -f Dockerfile ../emdash -t emdash
```

## What's included

- **Runtime**: Node.js 22
- **Database**: SQLite (via better-sqlite3)
- **Storage**: Local filesystem
- **Auth**: Passkey authentication (WebAuthn)
- **Demo content**: Seeded automatically on first start

## Links

- [EmDash source](https://github.com/emdash-cms/emdash)
- [Docker Hub image](https://hub.docker.com/r/jstgnkl/emdash)
