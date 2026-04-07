#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ENV_FILE:-$ROOT_DIR/.env.production}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Missing env file: $ENV_FILE" >&2
  exit 1
fi

cd "$ROOT_DIR"

docker compose \
  --env-file "$ENV_FILE" \
  -f docker-compose.prod.yml \
  -f docker-compose.ghcr.yml \
  -f docker-compose.cloudflare.yml \
  logs -f "$@"
