#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./start.test.sh [--with-prod] [--skip-pull] [--keep-running]

Executa o ciclo completo de testes locais:
  1. Sobe o ambiente via ./start.sh (com as flags repassadas).
  2. Valida que os containers essenciais estão em execução e saudáveis.
  3. Encerra o ambiente ao final (a menos que --keep-running seja informado).

Opções:
  --with-prod      Passa a flag correspondente ao start.sh (inclui perfil prod).
  --skip-pull      Repasse direto para start.sh (evita baixar imagens).
  --keep-running   Não chama ./stop.sh ao final (útil para inspeções manuais).
  -h, --help       Exibe esta ajuda.
EOF
}

# shellcheck disable=SC2164
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

START_SCRIPT="$PROJECT_ROOT/start.sh"
STOP_SCRIPT="$PROJECT_ROOT/stop.sh"
CONTAINER_LIST="$PROJECT_ROOT/docker/container-names.txt"
GENERATED_COMPOSE="$PROJECT_ROOT/docker-compose.yaml"

if [[ ! -x "$START_SCRIPT" ]]; then
  echo "error: start.sh não encontrado ou sem permissão de execução." >&2
  exit 1
fi
if [[ ! -x "$STOP_SCRIPT" ]]; then
  echo "error: stop.sh não encontrado ou sem permissão de execução." >&2
  exit 1
fi
if [[ ! -f "$CONTAINER_LIST" ]]; then
  echo "error: lista de containers não encontrada em $CONTAINER_LIST." >&2
  exit 1
fi

PASSTHRU_ARGS=()
KEEP_RUNNING=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-prod|--skip-pull)
      PASSTHRU_ARGS+=("$1")
      shift
      ;;
    --keep-running)
      KEEP_RUNNING=true
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

echo "==> Iniciando ciclo de teste..."
"$START_SCRIPT" "${PASSTHRU_ARGS[@]}"

if [[ ! -f "$GENERATED_COMPOSE" ]]; then
  echo "error: arquivo $GENERATED_COMPOSE não encontrado após start.sh." >&2
  exit 1
fi

command -v docker >/dev/null 2>&1 || { echo "error: docker não encontrado no PATH." >&2; exit 1; }

echo "==> Validando estado dos containers..."
FAIL=0
while IFS= read -r name; do
  [[ -z "$name" || "$name" == \#* ]] && continue
  CID="$(docker ps -aq -f name="^${name}$")"
  if [[ -z "$CID" ]]; then
    echo "   - Container '$name' não está em execução (ok se perfil/prod não foi habilitado)."
    continue
  fi

  STATUS="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$name" 2>/dev/null || echo "unknown")"
  echo "   - $name -> $STATUS"
  case "$STATUS" in
    healthy|running)
      ;;
    *)
      echo "error: container '$name' não está saudável (status: $STATUS)." >&2
      FAIL=1
      ;;
  esac
done < "$CONTAINER_LIST"

if [[ $FAIL -ne 0 ]]; then
  echo "==> Falha na validação dos containers." >&2
  if ! $KEEP_RUNNING; then
    "$STOP_SCRIPT" || true
  fi
  exit 1
fi

echo "==> Containers validados com sucesso."

if ! $KEEP_RUNNING; then
  echo "==> Encerrando ambiente (stop.sh)..."
  "$STOP_SCRIPT"
else
  echo "==> Mantendo ambiente em execução conforme solicitado (--keep-running)."
fi

echo "Ciclo de teste concluído com sucesso."
