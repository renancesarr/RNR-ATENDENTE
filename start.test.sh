#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./start.test.sh [--with-prod] [--update] [--no-keep-running]

Executa o ciclo completo de testes locais:
  1. Sobe o ambiente via ./start.sh (com as flags repassadas).
  2. Valida que os containers essenciais estão em execução e saudáveis.
  3. Mantém o ambiente disponível para inspeção (use --no-keep-running para encerrar automaticamente).

Opções:
  --with-prod      Passa a flag correspondente ao start.sh (inclui perfil prod).
  --skip-pull      Repasse direto para start.sh (não baixa imagens, padrão).
  --no-skip-pull, --update
                   Repasse para start.sh forçando docker compose pull.
  --keep-running   Mantém os containers após o teste (padrão).
  --no-keep-running
                   Executa ./stop.sh ao final do ciclo.
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
DEFAULT_ENV_FILE="$PROJECT_ROOT/.env"
LOCAL_ENV_FILE="$PROJECT_ROOT/.env.local"

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  ENV_FILE="$LOCAL_ENV_FILE"
else
  ENV_FILE="$DEFAULT_ENV_FILE"
fi

extract_env_value() {
  local key="$1"
  if [[ -f "$ENV_FILE" ]]; then
    grep -E "^$key=" "$ENV_FILE" | tail -n1 | cut -d= -f2-
  else
    echo ""
  fi
}

attempt_evolution_login_test() {
  local login_script="$PROJECT_ROOT/scripts/evolution-login.sh"
  if [[ ! -x "$login_script" ]]; then
    echo "==> Script de login automático não encontrado (${login_script}); pulando exibição do QR."
    return
  fi

  local port_raw
  port_raw="$(docker compose --project-directory "$PROJECT_ROOT" -f "$GENERATED_COMPOSE" port reverse-proxy 8080 2>/dev/null || true)"
  if [[ -z "$port_raw" ]]; then
    echo "==> Porta do proxy não identificada; pulando login automático."
    return
  fi

  local api_port
  api_port="$(echo "$port_raw" | tail -n1 | awk -F: '{print $NF}')"
  if [[ -z "$api_port" ]]; then
    echo "==> Porta da Evolution API não identificada; pulando login automático."
    return
  fi

  local instance_name="${EVOLUTION_INSTANCE_NAME:-$(extract_env_value 'EVOLUTION_INSTANCE_NAME')}"
  if [[ -z "$instance_name" ]]; then
    instance_name="mvp-bot"
  fi

  local qr_output
  qr_output="$(mktemp "${TMPDIR:-/tmp}/evolution-qr-XXXX.png")"

  echo "==> Tentando login WhatsApp (instância '${instance_name}')..."
  if "$login_script" --env-file "$ENV_FILE" --base-url "http://localhost:${api_port}" --instance "$instance_name" --qr-output "$qr_output"; then
    echo "    Abra o arquivo $qr_output para ler o QR code exibido acima."
    if ! $KEEP_RUNNING; then
      echo "    Observação: use --no-keep-running se quiser que o ciclo encerre automaticamente."
    fi
    return
  fi

  local status=$?
  case "$status" in
    2)
      echo "    Aviso: token de autenticação não configurado; pulando login automático."
      ;;
    3)
      echo "    Aviso: dependências para obter o QR (curl/jq/base64) não disponíveis; instale-as ou mantenha EVOLUTION_LOGIN_SKIP_AUTO=1."
      ;;
    4)
      echo "    Aviso: utilitário scripts/fetch-qr.sh não encontrado; verifique o repositório."
      ;;
    *)
      echo "    warning: falha ao obter o QR code (status ${status})."
      ;;
  esac
  rm -f "$qr_output"
}

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
KEEP_RUNNING=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-prod|--skip-pull|--update|--no-skip-pull)
      PASSTHRU_ARGS+=("$1")
      shift
      ;;
    --keep-running)
      KEEP_RUNNING=true
      shift
      ;;
    --no-keep-running)
      KEEP_RUNNING=false
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
EVOLUTION_LOGIN_SKIP_AUTO=1 "$START_SCRIPT" "${PASSTHRU_ARGS[@]}"

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

if [[ ${FAIL:-0} -eq 0 ]]; then
  attempt_evolution_login_test
fi

if ! $KEEP_RUNNING; then
  echo "==> Encerrando ambiente (stop.sh)..."
  "$STOP_SCRIPT"
else
  echo "==> Mantendo ambiente em execução. Use --no-keep-running para encerrar automaticamente após os testes."
fi

echo "Ciclo de teste concluído com sucesso."
