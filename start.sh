#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./start.sh [--with-prod] [--update] [--skip-pull]

Options:
  --with-prod   Inclui serviços opcionais do perfil "prod" (typebot, watchtower).
  --skip-pull   Não executa "docker compose pull" (padrão).
  --no-skip-pull, --update
                Executa "docker compose pull" antes de subir os serviços.
  -h, --help    Mostra esta ajuda.

O script deve ser executado a partir da raiz do repositório. Garante que o
arquivo .env exista, sobe o docker-compose e realiza checagens básicas de saúde.
EOF
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

DEFAULT_ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"
LOCAL_ENV_FILE="$PROJECT_ROOT/.env.local"

if [[ -f "$LOCAL_ENV_FILE" ]]; then
  ENV_FILE="$LOCAL_ENV_FILE"
else
  ENV_FILE="$DEFAULT_ENV_FILE"
fi

GENERATED_COMPOSE="$PROJECT_ROOT/docker-compose.yaml"

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ENV_EXAMPLE" ]]; then
    echo "error: nenhum arquivo de ambiente (.env ou .env.local) encontrado." >&2
    echo "Crie um a partir de .env.example e preencha as credenciais necessárias." >&2
  else
    echo "error: nenhum .env encontrado; gere um antes de continuar." >&2
  fi
  exit 1
fi

# shellcheck disable=SC1090
set +u
set -a
source "$ENV_FILE"
set +a
set -u

INCLUDE_PROD=false
SKIP_PULL=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-prod)
      INCLUDE_PROD=true
      shift
      ;;
    --skip-pull)
      SKIP_PULL=true
      shift
      ;;
    --no-skip-pull|--update)
      SKIP_PULL=false
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

STOP_SCRIPT="$PROJECT_ROOT/stop.sh"
if [[ -x "$STOP_SCRIPT" ]]; then
  "$STOP_SCRIPT" --quiet || true
fi

COMPOSE_ARGS=()
if $INCLUDE_PROD; then
  COMPOSE_ARGS+=(--profile prod)
fi

echo "==> Gerando docker-compose.yaml (resolvido com variáveis)..."
docker compose --project-directory "$PROJECT_ROOT" --env-file "$ENV_FILE" config > "$GENERATED_COMPOSE"
echo "    Arquivo gerado: $GENERATED_COMPOSE"

compose_cmd() {
  docker compose --project-directory "$PROJECT_ROOT" -f "$GENERATED_COMPOSE" "${COMPOSE_ARGS[@]}" "$@"
}

command -v docker >/dev/null 2>&1 || { echo "error: docker não encontrado no PATH." >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "error: curl é necessário para validar o endpoint da Evolution API." >&2; exit 1; }

extract_env_value() {
  local key="$1"
  local value
  local value
  value=""
  if [[ -f "$ENV_FILE" ]]; then
    value="$(grep -E "^$key=" "$ENV_FILE" | tail -n1 | cut -d= -f2-)"
  fi
  echo "$value"
}

attempt_evolution_login() {
  local port="$1"

  if [[ "${EVOLUTION_LOGIN_SKIP_AUTO:-}" == "1" ]]; then
    return
  fi

  local login_script="$PROJECT_ROOT/scripts/evolution-login.sh"
  if [[ ! -x "$login_script" ]]; then
    echo "==> Script de login automático não encontrado (${login_script}); pulando."
    return
  fi

  local auth_key="${EVOLUTION_AUTH_KEY:-${AUTHENTICATION_API_KEY:-}}"
  if [[ -z "$auth_key" ]]; then
    auth_key="$(extract_env_value 'EVOLUTION_AUTH_KEY')"
  fi
  if [[ -z "$auth_key" ]]; then
    auth_key="$(extract_env_value 'AUTHENTICATION_API_KEY')"
  fi
  if [[ -z "$auth_key" ]]; then
    echo "==> Token de autenticação da Evolution API ausente; configure AUTHENTICATION_API_KEY antes de tentar o login automático."
    return
  fi

  local instance_name
  instance_name="${EVOLUTION_INSTANCE_NAME:-$(extract_env_value 'EVOLUTION_INSTANCE_NAME')}"
  if [[ -z "$instance_name" ]]; then
    instance_name="mvp-bot"
  fi

  local base_url="http://localhost:${port}"
  local qr_output
  qr_output="$(mktemp "${TMPDIR:-/tmp}/evolution-qr-XXXX.png")"

  echo "==> Tentando login WhatsApp (instância '${instance_name}')..."
  if "$login_script" --env-file "$ENV_FILE" --base-url "$base_url" --instance "$instance_name" --qr-output "$qr_output"; then
    echo "    Abra o arquivo $qr_output para ler o QR code exibido acima."
    return
  fi

  local status=$?
  case "$status" in
    2)
      echo "    Aviso: token de autenticação não configurado; pulando login automático."
      ;;
    3)
      echo "    Aviso: dependências para obter o QR (curl/jq/base64) não disponíveis; instale-as ou configure EVOLUTION_LOGIN_SKIP_AUTO=1."
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

POSTGRES_DB_VALUE="$(extract_env_value 'POSTGRES_DB')"
if [[ -z "$POSTGRES_DB_VALUE" ]]; then
  POSTGRES_DB_VALUE="evolution"
fi

echo "==> Validando ambiente..."
compose_cmd config >/dev/null

if ! $SKIP_PULL; then
  echo "==> Baixando imagens (docker compose pull)..."
  compose_cmd pull
else
  echo "==> Pulando docker compose pull (flag --skip-pull)."
fi

echo "==> Subindo serviços (docker compose up -d)..."
compose_cmd up -d

echo "==> Status dos serviços:"
compose_cmd ps

run_compose_exec() {
  compose_cmd exec -T "$@"
}

echo "==> Checando Postgres..."
run_compose_exec postgres pg_isready -U postgres -d "$POSTGRES_DB_VALUE"

echo "==> Checando Redis..."
run_compose_exec redis redis-cli ping

echo "==> Checando RabbitMQ..."
run_compose_exec rabbitmq rabbitmq-diagnostics -q status

echo "==> Obtendo porta mapeada do proxy da Evolution API..."
API_PORT_RAW="$(compose_cmd port reverse-proxy 8080 || true)"
if [[ -z "$API_PORT_RAW" ]]; then
  echo "error: não foi possível determinar a porta da Evolution API. Verifique se o serviço está em execução." >&2
  exit 1
fi
API_PORT="$(echo "$API_PORT_RAW" | tail -n1 | awk -F: '{print $NF}')"

if [[ -z "$API_PORT" ]]; then
  echo "error: porta da Evolution API não identificada (saida: $API_PORT_RAW)." >&2
  exit 1
fi

AUTH_KEY="$(extract_env_value 'EVOLUTION_AUTH_KEY')"
if [[ -z "$AUTH_KEY" ]]; then
  AUTH_KEY="$(extract_env_value 'AUTHENTICATION_API_KEY')"
fi

CURL_OPTS=(-sS "http://localhost:${API_PORT}/status")
if [[ -n "$AUTH_KEY" ]]; then
  CURL_OPTS=(-sS -H "Authorization: Bearer ${AUTH_KEY}" "http://localhost:${API_PORT}/status")
fi

HEALTH_PATH="$(extract_env_value 'EVOLUTION_HEALTHCHECK_PATH')"
if [[ -z "$HEALTH_PATH" ]]; then
  HEALTH_PATH="/status"
fi

BASE_URL="http://localhost:${API_PORT}${HEALTH_PATH}"
MAX_ATTEMPTS="${EVOLUTION_HEALTHCHECK_ATTEMPTS:-10}"
SLEEP_SECONDS="${EVOLUTION_HEALTHCHECK_INTERVAL_SECONDS:-60}"

echo "==> Validando endpoint da Evolution API em ${BASE_URL} ..."
SUCCESS=false
for attempt in $(seq 1 "$MAX_ATTEMPTS"); do
  TMP_OUTPUT="$(mktemp)"
  HTTP_CODE=$(curl "${CURL_OPTS[@]/%\/status/${HEALTH_PATH}}" -o "$TMP_OUTPUT" -w "%{http_code}" || echo "000")
  cat "$TMP_OUTPUT"
  echo
  rm -f "$TMP_OUTPUT"

  if [[ "$HTTP_CODE" == "200" ]]; then
    SUCCESS=true
    echo "    ✓ Healthcheck respondeu 200 (tentativa ${attempt}/${MAX_ATTEMPTS})."
    break
  fi

  echo "    Tentativa ${attempt}/${MAX_ATTEMPTS} falhou com HTTP ${HTTP_CODE}. Aguardando ${SLEEP_SECONDS}s..."
  sleep "$SLEEP_SECONDS"
done

if ! $SUCCESS; then
  cat <<EOF >&2
warning: Evolution API não respondeu 200 após ${MAX_ATTEMPTS} tentativas.
Verifique se ${HEALTH_PATH} é o caminho correto ou ajuste EVOLUTION_HEALTHCHECK_PATH no .env.
EOF
else
  attempt_evolution_login "$API_PORT"
fi

echo "==> Logs recentes da Evolution API:"
compose_cmd logs --tail 20 evolution-api || true

cat <<'EOF'

Ambiente iniciado com sucesso.
- Use "docker compose logs -f evolution-api" para acompanhar os logs.
- Quando terminar, execute "docker compose down" (ou "docker compose down -v" se quiser remover volumes).
EOF
