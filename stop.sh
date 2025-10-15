#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./stop.sh [--keep-compose] [--quiet]

Options:
  --keep-compose   Mantém o arquivo docker-compose.yaml gerado pelo start.sh.
  --quiet          Reduz a verbosidade (ideal para chamadas internas).
  -h, --help       Exibe esta ajuda.

Encerra e remove os containers definidos em docker/container-names.txt,
limpando o ambiente local antes de uma nova execução.
EOF
}

# shellcheck disable=SC2164
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

CONTAINER_LIST="$PROJECT_ROOT/docker/container-names.txt"
GENERATED_COMPOSE="$PROJECT_ROOT/docker-compose.yaml"

if [[ ! -f "$CONTAINER_LIST" ]]; then
  echo "error: lista de containers não encontrada em $CONTAINER_LIST" >&2
  exit 1
fi

KEEP_COMPOSE=false
QUIET=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --keep-compose)
      KEEP_COMPOSE=true
      shift
      ;;
    --quiet)
      QUIET=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "error: opção desconhecida '$1'." >&2
      usage
      exit 1
      ;;
  esac
done

log() {
  if ! $QUIET; then
    echo "$@"
  fi
}

command -v docker >/dev/null 2>&1 || { echo "error: docker não encontrado no PATH." >&2; exit 1; }

if [[ -f "$GENERATED_COMPOSE" ]]; then
  log "==> Derrubando stack via docker compose..."
  docker compose --project-directory "$PROJECT_ROOT" -f "$GENERATED_COMPOSE" down --remove-orphans || true
fi

log "==> Conferindo containers individuais..."
while IFS= read -r name; do
  # Ignora linhas vazias ou comentários
  [[ -z "$name" || "$name" == \#* ]] && continue

  CID="$(docker ps -aq -f name="^${name}$")"
  if [[ -n "$CID" ]]; then
    log "   - Removendo container '$name'..."
    docker rm -f "$CID" >/dev/null 2>&1 || docker rm -f "$name" >/dev/null 2>&1 || true
  else
    log "   - Container '$name' não encontrado (ok)."
  fi
done < "$CONTAINER_LIST"

if [[ -f "$GENERATED_COMPOSE" && $KEEP_COMPOSE == false ]]; then
  log "==> Removendo compose gerado em $GENERATED_COMPOSE"
  rm -f "$GENERATED_COMPOSE"
fi

log "Ambiente parado."
