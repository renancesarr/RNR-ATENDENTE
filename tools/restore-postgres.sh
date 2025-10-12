#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <backup-file> [env-file]" >&2
  exit 1
fi

BACKUP_FILE="$1"
ENV_FILE="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.env}"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ ! -f "$BACKUP_FILE" ]]; then
  echo "error: backup file '$BACKUP_FILE' not found." >&2
  exit 1
fi

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

echo "Restoring database '$TARGET_DB' from '$BACKUP_FILE'..."

cat "$BACKUP_FILE" | \
  docker compose exec -T postgres \
    pg_restore -v \
               -c \
               -U "$SUPERUSER" \
               -d "$TARGET_DB"

echo "Restore finished."
