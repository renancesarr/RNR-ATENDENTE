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
MAX_CONTAINER_ATTEMPTS="${TEST_CONTAINER_ATTEMPTS:-10}"
CONTAINER_SLEEP_SECONDS="${TEST_CONTAINER_INTERVAL_SECONDS:-30}"
ATTEMPT=1
while [[ $ATTEMPT -le $MAX_CONTAINER_ATTEMPTS ]]; do
  echo "   Tentativa ${ATTEMPT}/${MAX_CONTAINER_ATTEMPTS}..."
  FAIL=0
  while IFS= read -r name; do
    [[ -z "$name" || "$name" == \#* ]] && continue
    CID="$(docker ps -aq -f name="^${name}$")"
    if [[ -z "$CID" ]]; then
      echo "     - $name: não encontrado (ok se perfil não foi iniciado)."
      continue
    fi

    STATUS="$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$name" 2>/dev/null || echo "unknown")"
    echo "     - $name -> $STATUS"
    case "$STATUS" in
      healthy|running)
        ;;
      starting)
        FAIL=1
        ;;
      *)
        echo "error: container '$name' reportou status '$STATUS'." >&2
        FAIL=2
        ;;
    esac
  done < "$CONTAINER_LIST"

  if [[ $FAIL -eq 0 ]]; then
    echo "==> Containers validados com sucesso."
    break
  fi

  if [[ $FAIL -eq 2 ]]; then
    echo "==> Falha crítica na validação dos containers." >&2
    if ! $KEEP_RUNNING; then
      "$STOP_SCRIPT" || true
    fi
    exit 1
  fi

  ATTEMPT=$((ATTEMPT + 1))
  if [[ $ATTEMPT -le $MAX_CONTAINER_ATTEMPTS ]]; then
    echo "   Containers ainda inicializando. Aguardando ${CONTAINER_SLEEP_SECONDS}s..."
    sleep "$CONTAINER_SLEEP_SECONDS"
  fi
done

if [[ $FAIL -ne 0 && $FAIL -ne 2 ]]; then
  echo "==> Containers não ficaram saudáveis após ${MAX_CONTAINER_ATTEMPTS} tentativas." >&2
  if ! $KEEP_RUNNING; then
    "$STOP_SCRIPT" || true
  fi
  exit 1
fi

if ! $KEEP_RUNNING; then
  echo "==> Encerrando ambiente (stop.sh)..."
  "$STOP_SCRIPT"
else
  echo "==> Mantendo ambiente em execução conforme solicitado (--keep-running)."
fi

echo "Ciclo de teste concluído com sucesso."
