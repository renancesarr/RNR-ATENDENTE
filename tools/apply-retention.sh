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
  echo "warning: env file '$ENV_FILE' not found; relying on current environment" >&2
fi

SUPERUSER="${POSTGRES_SUPERUSER:-postgres}"
TARGET_DB="${POSTGRES_SUPERUSER_DB:-postgres}"

echo "Applying retention scrub job..."

docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 \
       -U "$SUPERUSER" \
       -d "$TARGET_DB" \
       -c "SELECT * FROM fn_apply_retention_scrub();"

echo "Retention job executed."
