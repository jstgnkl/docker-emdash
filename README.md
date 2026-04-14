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
    environment:
      - PUBLIC_ORIGIN=${PUBLIC_ORIGIN:-}
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

When running behind a TLS-terminating reverse proxy (Traefik, Caddy, nginx, etc.), set the `PUBLIC_ORIGIN` environment variable to your public URL. The entrypoint exports it to EmDash as `EMDASH_SITE_URL`, which drives WebAuthn passkey origin matching, CSRF, OAuth redirects, and other origin-dependent features at runtime -- no rebuild needed.

```bash
docker run -d -p 4321:4321 -e PUBLIC_ORIGIN=https://emdash.example.com jstgnkl/emdash:latest
```

Or in Docker Compose:

```bash
PUBLIC_ORIGIN=https://emdash.example.com docker compose up -d
```

You can also set `EMDASH_SITE_URL` directly if you prefer EmDash's upstream name.

Forwarding `X-Forwarded-Proto: https` and `X-Forwarded-Host: <your hostname>` from the reverse proxy is recommended for general correctness (logging, third-party middleware) but is not required for passkeys to work -- origin resolution comes from `EMDASH_SITE_URL`, not the forwarded headers.

Without `PUBLIC_ORIGIN` (or `EMDASH_SITE_URL`), passkey registration/login will fail with origin mismatch errors because the container only sees the internal HTTP origin.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PUBLIC_ORIGIN` | _(unset)_ | Public HTTPS origin for reverse proxy setups (e.g. `https://emdash.example.com`). Exported as `EMDASH_SITE_URL` by the entrypoint. |
| `EMDASH_SITE_URL` | _(unset)_ | Upstream EmDash name for the same value; takes precedence if both are set. |
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
- **Auth**: Passkey authentication (WebAuthn), with reverse proxy support
- **Demo content**: Seeded automatically on first start

## Links

- [EmDash source](https://github.com/emdash-cms/emdash)
- [Docker Hub image](https://hub.docker.com/r/jstgnkl/emdash)
