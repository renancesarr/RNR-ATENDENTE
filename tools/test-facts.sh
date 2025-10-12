#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_FILE="$2"
      shift 2
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 1
  esac
done

if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC2046
  set -a
  source "$ENV_FILE"
  set +a
else
  echo "warning: env file '$ENV_FILE' not found; relying on environment" >&2
fi

SUPERUSER="${POSTGRES_SUPERUSER:-postgres}"
TARGET_DB="${POSTGRES_SUPERUSER_DB:-postgres}"

echo "Running fact integrity tests..."

docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 \
       -U "$SUPERUSER" \
       -d "$TARGET_DB" \
       -f /app/db/tests/fact_integrity.sql

echo "All fact integrity checks passed."
