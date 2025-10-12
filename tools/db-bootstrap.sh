#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$PROJECT_ROOT/.env}"

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC2046
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "warning: env file '$ENV_FILE' not found; using environment variables already set."
fi

APP_USER="${POSTGRES_APP_USER:-evolution_app}"
APP_PASSWORD="${POSTGRES_APP_PASSWORD:-}"
APP_DB="${POSTGRES_APP_DB:-evolution_app}"
SUPERUSER="${POSTGRES_SUPERUSER:-postgres}"
TARGET_DB="${POSTGRES_SUPERUSER_DB:-postgres}"

if [[ -z "$APP_PASSWORD" ]]; then
  echo "error: POSTGRES_APP_PASSWORD must be set (via env file or environment)." >&2
  exit 1
fi

echo "Applying migration to ensure role '$APP_USER' and database '$APP_DB' exist..."

cat "$PROJECT_ROOT/db/migrations/0001_create_app_role.sql" | \
  docker compose exec -T postgres \
    psql -v ON_ERROR_STOP=1 \
         -v POSTGRES_APP_USER="$APP_USER" \
         -v POSTGRES_APP_PASSWORD="$APP_PASSWORD" \
         -v POSTGRES_APP_DB="$APP_DB" \
         -U "$SUPERUSER" \
         -d "$TARGET_DB"

echo "Migration executed successfully."
