#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$PROJECT_ROOT/.env"
DRY_RUN=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env)
      ENV_FILE="$2"
      shift 2
      ;;
    --apply)
      DRY_RUN=false
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
  esac
done

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

if $DRY_RUN; then
  echo "Running retention purge in DRY RUN mode..."
else
  echo "Running retention purge (APPLY mode)..."
fi

docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 \
       -U "$SUPERUSER" \
       -d "$TARGET_DB" \
       -c "SELECT * FROM fn_apply_retention_purge($DRY_RUN);"

echo "Retention purge completed."
