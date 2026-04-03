# docker-emdash

Docker image for [EmDash](https://github.com/emdash-cms/emdash), the Astro-based CMS. Runs the blog template with Node.js and SQLite — no Cloudflare account required.

## Quick start

```bash
docker run -d -p 4321:4321 jstgnkl/emdash:latest
```

Open http://localhost:4321 for the site and http://localhost:4321/_emdash/admin for the admin panel.

## Docker Compose (recommended)

Download the `docker-compose.yml` from this repo, then:

```bash
docker compose up -d
```

This persists the SQLite database and uploaded media in named volumes so your content survives container restarts.

```bash
docker compose down      # stop
docker compose logs -f   # tail logs
docker compose down -v   # stop and delete all data
```

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `HOST`   | `0.0.0.0` | Address to bind |
| `PORT`   | `4321` | Port to listen on |

To change the port mapping:

```yaml
ports:
  - "8080:4321"
```

## Volumes

| Volume | Container path | Purpose |
|--------|---------------|---------|
| `emdash-data` | `/app/templates/blog/data` | SQLite database |
| `emdash-uploads` | `/app/templates/blog/uploads` | Uploaded media files |

## Building from source

To build the image yourself from the [emdash source](https://github.com/emdash-cms/emdash):

```bash
git clone https://github.com/emdash-cms/emdash.git && cd emdash
# copy Dockerfile and .dockerignore from this repo into the clone
docker build -t emdash .
```

## What's included

The image runs the EmDash blog template with:

- **Runtime**: Node.js 22
- **Database**: SQLite (via better-sqlite3)
- **Storage**: Local filesystem
- **Demo content**: Seeded automatically on first start

## Links

- [EmDash source](https://github.com/emdash-cms/emdash)
- [Docker Hub image](https://hub.docker.com/r/jstgnkl/emdash)
