#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$PROJECT_ROOT/.env}"
OUTPUT_DIR="${2:-$PROJECT_ROOT/backups/postgres}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC2046
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "warning: env file '$ENV_FILE' not found; using environment variables already set."
fi

SUPERUSER="${POSTGRES_SUPERUSER:-postgres}"
TARGET_DB="${POSTGRES_APP_DB:-${POSTGRES_DB:-evolution}}"

mkdir -p "$OUTPUT_DIR"
timestamp="$(date +%Y%m%d-%H%M%S)"
backup_path="${OUTPUT_DIR}/postgres-${timestamp}.dump"

echo "Creating Postgres backup at '$backup_path'..."

docker compose exec -T postgres \
  pg_dump -v \
          -Fc \
          -U "$SUPERUSER" \
          -d "$TARGET_DB" \
  > "$backup_path"

echo "Backup completed."
echo "$backup_path"
