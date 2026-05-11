#!/usr/bin/env bash
set -euo pipefail

# Migrate the database from the DigitalOcean droplet to local Postgres.
#
# Usage:
#   ./scripts/migrate-from-droplet.sh <droplet-ip>
#
# Prerequisites:
#   - SSH access to the droplet
#   - Local docker compose stack running (postgres must be up)

DROPLET_IP="${1:?Usage: migrate-from-droplet.sh <droplet-ip>}"
DUMP_FILE="liftiq-dump-$(date +%Y%m%d-%H%M%S).sql"

echo "==> Dumping database from droplet ${DROPLET_IP}..."
ssh "root@${DROPLET_IP}" \
  "docker exec liftiq-postgres pg_dump -U liftiq -d liftiq --clean --if-exists" \
  > "${DUMP_FILE}"

echo "==> Dump saved to ${DUMP_FILE} ($(wc -c < "${DUMP_FILE}") bytes)"

echo "==> Restoring into local Postgres container..."
docker exec -i liftiq-postgres psql -U liftiq -d liftiq < "${DUMP_FILE}"

echo "==> Done. Database migrated successfully."
