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

# Remove slidev from workspace (dir not present in container)
RUN sed -i '/slidev/d' pnpm-workspace.yaml

RUN pnpm install --frozen-lockfile

# ---- Build ----
FROM deps AS build

COPY . .
RUN sed -i '/slidev/d' pnpm-workspace.yaml

# Point SQLite to a data/ subdirectory for clean volume mounting
RUN sed -i 's|file:./data.db|file:./data/data.db|' templates/blog/astro.config.mjs

RUN pnpm build && pnpm --filter @emdash-cms/template-blog build

# ---- Runtime ----
FROM node:22-slim

RUN corepack enable && corepack prepare pnpm@10.28.0 --activate

WORKDIR /app
COPY --from=build /app /app

WORKDIR /app/templates/blog
RUN mkdir -p data uploads

ENV HOST=0.0.0.0
ENV PORT=4321
EXPOSE 4321

CMD ["sh", "-c", "node ../../packages/core/dist/cli/index.mjs init && node ../../packages/core/dist/cli/index.mjs seed && node ./dist/server/entry.mjs"]
