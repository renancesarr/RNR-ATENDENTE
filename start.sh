#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./start.sh [--with-prod] [--skip-pull]

Options:
  --with-prod   Inclui serviços opcionais do perfil "prod" (typebot, watchtower).
  --skip-pull   Não executa "docker compose pull" antes de subir os serviços.
  -h, --help    Mostra esta ajuda.

O script deve ser executado a partir da raiz do repositório. Garante que o
arquivo .env exista, sobe o docker-compose e realiza checagens básicas de saúde.
EOF
}

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

ENV_FILE="$PROJECT_ROOT/.env"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

if [[ ! -f "$ENV_FILE" ]]; then
  if [[ -f "$ENV_EXAMPLE" ]]; then
    echo "error: arquivo .env não encontrado em $ENV_FILE." >&2
    echo "Crie-o a partir de .env.example e preencha as credenciais necessárias." >&2
  else
    echo "error: nenhum .env encontrado; gere um antes de continuar." >&2
  fi
  exit 1
fi

INCLUDE_PROD=false
SKIP_PULL=false

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

COMPOSE_ARGS=()
if $INCLUDE_PROD; then
  COMPOSE_ARGS+=(--profile prod)
fi

command -v docker >/dev/null 2>&1 || { echo "error: docker não encontrado no PATH." >&2; exit 1; }
command -v curl >/dev/null 2>&1 || { echo "error: curl é necessário para validar o endpoint da Evolution API." >&2; exit 1; }

extract_env_value() {
  local key="$1"
  local value
  value="$(grep -E "^$key=" "$ENV_FILE" | tail -n1 | cut -d= -f2-)"
  echo "$value"
}

POSTGRES_DB_VALUE="$(extract_env_value 'POSTGRES_DB')"
if [[ -z "$POSTGRES_DB_VALUE" ]]; then
  POSTGRES_DB_VALUE="evolution"
fi

echo "==> Validando ambiente..."
docker compose "${COMPOSE_ARGS[@]}" config >/dev/null

if ! $SKIP_PULL; then
  echo "==> Baixando imagens (docker compose pull)..."
  docker compose "${COMPOSE_ARGS[@]}" pull
else
  echo "==> Pulando docker compose pull (flag --skip-pull)."
fi

echo "==> Subindo serviços (docker compose up -d)..."
docker compose "${COMPOSE_ARGS[@]}" up -d

echo "==> Status dos serviços:"
docker compose "${COMPOSE_ARGS[@]}" ps

run_compose_exec() {
  docker compose "${COMPOSE_ARGS[@]}" exec -T "$@"
}

echo "==> Checando Postgres..."
run_compose_exec postgres pg_isready -U postgres -d "$POSTGRES_DB_VALUE"

echo "==> Checando Redis..."
run_compose_exec redis redis-cli ping

echo "==> Checando RabbitMQ..."
run_compose_exec rabbitmq rabbitmq-diagnostics -q status

echo "==> Obtendo porta mapeada da Evolution API..."
API_PORT_RAW="$(docker compose "${COMPOSE_ARGS[@]}" port evolution-api 8080 || true)"
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

CURL_OPTS=(-fsS "http://localhost:${API_PORT}/status")
if [[ -n "$AUTH_KEY" ]]; then
  CURL_OPTS=(-fsS -H "Authorization: Bearer ${AUTH_KEY}" "http://localhost:${API_PORT}/status")
fi

echo "==> Validando endpoint da Evolution API em http://localhost:${API_PORT}/status ..."
curl "${CURL_OPTS[@]}"
echo

echo "==> Logs recentes da Evolution API:"
docker compose "${COMPOSE_ARGS[@]}" logs --tail 20 evolution-api || true

cat <<'EOF'

Ambiente iniciado com sucesso.
- Use "docker compose logs -f evolution-api" para acompanhar os logs.
- Quando terminar, execute "docker compose down" (ou "docker compose down -v" se quiser remover volumes).
EOF
