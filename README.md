# docker-emdash

Docker image for [EmDash](https://github.com/emdash-cms/emdash), the Astro-based CMS. Runs the blog template with Node.js and SQLite -- no Cloudflare account required.

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
    image: jstgnkl/emdash:0.2.0
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

When running behind a TLS-terminating reverse proxy (Traefik, Caddy, nginx, etc.), set the `PUBLIC_ORIGIN` environment variable to your public URL. This configures both Astro's forwarded header trust and WebAuthn passkey origin matching at container startup -- no rebuild needed.

```bash
docker run -d -p 4321:4321 -e PUBLIC_ORIGIN=https://emdash.example.com jstgnkl/emdash:latest
```

Or in Docker Compose:

```bash
PUBLIC_ORIGIN=https://emdash.example.com docker compose up -d
```

Your reverse proxy must forward these headers:

| Header | Value |
|--------|-------|
| `X-Forwarded-Proto` | `https` |
| `X-Forwarded-Host` | your public hostname |

Without `PUBLIC_ORIGIN`, passkey registration/login will fail with origin mismatch errors and Astro may redirect to internal URLs (e.g. `http://localhost:4321`).

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PUBLIC_ORIGIN` | _(unset)_ | Public HTTPS origin for reverse proxy setups (e.g. `https://emdash.example.com`) |
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
