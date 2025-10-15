#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${1:-$PROJECT_ROOT/.env}"

if [[ -f "$ENV_FILE" ]]; then
  set +u
  set -a
  source "$ENV_FILE"
  set +a
  set -u
fi

# Evolution API v2 utiliza o superusuário postgres; não precisamos criar role/banco adicional.
echo "Postgres bootstrap skipped (Evolution API usa superuser '${POSTGRES_USER:-postgres}')."
