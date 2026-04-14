#!/bin/sh
set -e

# EmDash resolves the public origin at runtime via EMDASH_SITE_URL (see
# packages/core/src/api/public-url.ts). Map the existing PUBLIC_ORIGIN input
# to it so users don't need to rename their env var.
#
# Usage: docker run -e PUBLIC_ORIGIN=https://emdash.example.com ...

if [ -n "$PUBLIC_ORIGIN" ] && [ -z "$EMDASH_SITE_URL" ]; then
  export EMDASH_SITE_URL="$PUBLIC_ORIGIN"
fi

if [ -n "$EMDASH_SITE_URL" ]; then
  echo "EmDash public origin: $EMDASH_SITE_URL"
fi

exec "$@"
