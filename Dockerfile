FROM node:22-slim AS base

RUN corepack enable && corepack prepare pnpm@10.28.0 --activate
WORKDIR /app

# ---- Install dependencies ----
FROM base AS deps

COPY pnpm-lock.yaml pnpm-workspace.yaml package.json ./
COPY packages/ packages/
COPY templates/ templates/
COPY demos/ demos/
COPY docs/package.json docs/package.json
COPY e2e/fixture/package.json e2e/fixture/package.json

RUN sed -i '/slidev/d' pnpm-workspace.yaml
RUN pnpm install --frozen-lockfile

# ---- Build ----
FROM deps AS build

COPY . .
RUN sed -i '/slidev/d' pnpm-workspace.yaml
RUN sed -i 's|file:./data.db|file:./data/data.db|' templates/blog/astro.config.mjs

RUN pnpm build && pnpm --filter @emdash-cms/template-blog build

# Bundle the blog template into a standalone deployment
RUN pnpm --filter @emdash-cms/template-blog deploy /deploy --prod --legacy

# Copy build output and seed data into the deploy directory
RUN cp -r /app/templates/blog/dist /deploy/dist
RUN cp -r /app/templates/blog/seed /deploy/seed
RUN cp /app/templates/blog/astro.config.mjs /deploy/astro.config.mjs

# ---- Runtime ----
FROM node:22-slim

WORKDIR /app
COPY --from=build /deploy .

RUN mkdir -p data uploads \
    && ln -s /app/node_modules/.pnpm/node_modules/kysely /app/node_modules/kysely

# Entrypoint patches built JS at startup to trust forwarded headers for PUBLIC_ORIGIN
COPY <<'ENTRYPOINT' /app/entrypoint.sh
#!/bin/sh
set -e
if [ -n "$PUBLIC_ORIGIN" ]; then
  HOST=$(echo "$PUBLIC_ORIGIN" | sed 's|.*://||' | sed 's|/.*||' | sed 's|:.*||')
  echo "Configuring for public origin: $PUBLIC_ORIGIN (host: $HOST)"
  DOMAINS="[{\"hostname\":\"$HOST\",\"protocol\":\"https\"},{\"hostname\":\"$HOST\",\"protocol\":\"http\"}]"
  # Patch passkeyPublicOrigin in emdash virtual config
  CONFIG_FILE=$(grep -rl 'const virtualConfig' /app/dist/server/chunks/ | head -1)
  if [ -n "$CONFIG_FILE" ]; then
    if grep -q '"passkeyPublicOrigin"' "$CONFIG_FILE"; then
      sed -i "s|\"passkeyPublicOrigin\":\"[^\"]*\"|\"passkeyPublicOrigin\":\"$PUBLIC_ORIGIN\"|" "$CONFIG_FILE"
    else
      sed -i "s|\"}}};|\"}},\"passkeyPublicOrigin\":\"$PUBLIC_ORIGIN\"};|" "$CONFIG_FILE"
    fi
  fi
  # Patch allowedDomains in Astro manifest
  MANIFEST_FILE=$(grep -rl 'deserializeManifest' /app/dist/server/chunks/ | head -1)
  if [ -n "$MANIFEST_FILE" ]; then
    sed -i "s|\"allowedDomains\":\[[^]]*\]|\"allowedDomains\":$DOMAINS|g" "$MANIFEST_FILE"
  fi
fi
exec "$@"
ENTRYPOINT
RUN chmod +x /app/entrypoint.sh

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["node", "./dist/server/entry.mjs"]
