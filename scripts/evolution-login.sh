#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./scripts/evolution-login.sh [--env-file PATH] [--base-url URL] [--instance NAME] [--qr-output PATH]

Obtém o QR code de autenticação da Evolution API utilizando o helper scripts/fetch-qr.sh.

Options:
  --env-file PATH   Arquivo .env a ser utilizado (default: .env).
  --base-url URL    URL base da Evolution API (default: http://localhost:<porta>).
  --instance NAME   Nome da instância (default: EVOLUTION_INSTANCE_NAME ou mvp-bot).
  --qr-output PATH  Caminho do arquivo PNG que receberá o QR code (criado se ausente).
  -h, --help        Exibe esta ajuda.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FETCH_QR_SCRIPT="$PROJECT_ROOT/scripts/fetch-qr.sh"

extract_env_value() {
  local key="$1"
  local file="$2"
  if [[ -f "$file" ]]; then
    grep -E "^${key}=" "$file" | tail -n1 | cut -d= -f2-
  else
    echo ""
  fi
}

ENV_FILE="${EVOLUTION_LOGIN_ENV_FILE:-.env}"
BASE_URL="${EVOLUTION_LOGIN_BASE_URL:-}"
INSTANCE_NAME="${EVOLUTION_LOGIN_INSTANCE:-${EVOLUTION_INSTANCE_NAME:-}}"
QR_OUTPUT="${EVOLUTION_LOGIN_QR_OUTPUT:-}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --env-file)
      ENV_FILE="$2"
      shift 2
      ;;
    --base-url)
      BASE_URL="$2"
      shift 2
      ;;
    --instance)
      INSTANCE_NAME="$2"
      shift 2
      ;;
    --qr-output)
      QR_OUTPUT="$2"
      shift 2
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

if [[ ! -f "$ENV_FILE" ]]; then
  echo "warning: arquivo de ambiente '$ENV_FILE' não encontrado." >&2
fi

if [[ -z "$INSTANCE_NAME" ]]; then
  INSTANCE_NAME="$(extract_env_value 'EVOLUTION_INSTANCE_NAME' "$ENV_FILE")"
fi
if [[ -z "$INSTANCE_NAME" ]]; then
  INSTANCE_NAME="mvp-bot"
fi

if [[ -z "$BASE_URL" ]]; then
  PORT_VALUE="${EVOLUTION_API_HTTP_PORT:-}"
  if [[ -z "$PORT_VALUE" ]]; then
    PORT_VALUE="$(extract_env_value 'EVOLUTION_API_HTTP_PORT' "$ENV_FILE")"
  fi
  if [[ -z "$PORT_VALUE" ]]; then
    PORT_VALUE="8088"
  fi
  BASE_URL="http://localhost:${PORT_VALUE}"
fi

AUTH_KEY="${EVOLUTION_AUTH_KEY:-${AUTHENTICATION_API_KEY:-}}"
if [[ -z "$AUTH_KEY" ]]; then
  AUTH_KEY="$(extract_env_value 'EVOLUTION_AUTH_KEY' "$ENV_FILE")"
fi
if [[ -z "$AUTH_KEY" ]]; then
  AUTH_KEY="$(extract_env_value 'AUTHENTICATION_API_KEY' "$ENV_FILE")"
fi
if [[ -z "$AUTH_KEY" ]]; then
  echo "warning: AUTHENTICATION_API_KEY/EVOLUTION_AUTH_KEY não configurado. Configure o token antes de solicitar o QR code." >&2
  exit 2
fi

for bin in curl jq base64; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "warning: dependência '$bin' não encontrada no PATH; instale-a para obter o QR automaticamente." >&2
    exit 3
  fi
done

if [[ ! -x "$FETCH_QR_SCRIPT" ]]; then
  echo "warning: utilitário '$FETCH_QR_SCRIPT' não encontrado ou sem permissão de execução." >&2
  exit 4
fi

OUTPUT_PATH="$QR_OUTPUT"
OUTPUT_CREATED=false
if [[ -z "$OUTPUT_PATH" ]]; then
  OUTPUT_PATH="$(mktemp "${TMPDIR:-/tmp}/evolution-qr-XXXX.png")"
  OUTPUT_CREATED=true
fi

ENV_SOURCE="$ENV_FILE" \
EVOLUTION_PROXY_BASE_URL="$BASE_URL" \
EVOLUTION_AUTH_KEY="$AUTH_KEY" \
EVOLUTION_INSTANCE_NAME="$INSTANCE_NAME" \
QR_OUTPUT="$OUTPUT_PATH" \
"$FETCH_QR_SCRIPT"
STATUS=$?

if [[ $STATUS -ne 0 ]] && $OUTPUT_CREATED; then
  rm -f "$OUTPUT_PATH"
fi

exit "$STATUS"
