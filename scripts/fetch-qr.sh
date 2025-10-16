#!/usr/bin/env bash
set -euo pipefail

ENV_SOURCE="${ENV_SOURCE:-.env.local}"
if [[ -f "$ENV_SOURCE" ]]; then
  set +u
  set -a
  source "$ENV_SOURCE"
  set +a
  set -u
fi

BASE_URL="${EVOLUTION_PROXY_BASE_URL:-http://localhost:${EVOLUTION_PROXY_HTTP_PORT:-8088}}"
AUTH_KEY="${EVOLUTION_AUTH_KEY:-${AUTHENTICATION_API_KEY:-}}"
INSTANCE_NAME="${1:-${EVOLUTION_INSTANCE_NAME:-default}}"
QR_OUTPUT="${QR_OUTPUT:-}"  # opcional
INSTANCE_TOKEN="${EVOLUTION_INSTANCE_TOKEN:-${AUTH_KEY:-${INSTANCE_NAME}}}"
INSTANCE_INTEGRATION="${EVOLUTION_INSTANCE_INTEGRATION:-WHATSAPP-BAILEYS}"

for cmd in curl jq base64; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "error: dependência '$cmd' não encontrada no PATH." >&2
    exit 3
  fi
done

if [[ -z "$AUTH_KEY" ]]; then
  echo "error: AUTHENTICATION_API_KEY ou EVOLUTION_AUTH_KEY não definido." >&2
  exit 1
fi

create_payload=$(jq -n \
  --arg name "$INSTANCE_NAME" \
  --arg token "$INSTANCE_TOKEN" \
  --arg integration "$INSTANCE_INTEGRATION" \
  '{
    instanceName: $name,
    token: $token,
    qrcode: true,
    integration: $integration
  }'
)

CREATE_TMP="$(mktemp)"
CREATE_HTTP=$(curl -sS -H "Content-Type: application/json" -H "apikey: $AUTH_KEY" \
  -o "$CREATE_TMP" -w "%{http_code}" \
  -X POST "$BASE_URL/instance/create" \
  --data "$create_payload" || echo "000")

if [[ "$CREATE_HTTP" == "000" ]]; then
  echo "error: falha ao conectar ao endpoint /instance/create." >&2
  rm -f "$CREATE_TMP"
  exit 1
fi

if [[ "$CREATE_HTTP" != "200" && "$CREATE_HTTP" != "201" && "$CREATE_HTTP" != "409" ]]; then
  echo "error: criação da instância retornou HTTP $CREATE_HTTP." >&2
  cat "$CREATE_TMP" >&2
  rm -f "$CREATE_TMP"
  exit 1
fi

if [[ "$CREATE_HTTP" == "409" ]]; then
  echo "==> Instância '$INSTANCE_NAME' já existente; reutilizando..." >&2
else
  echo "==> Instância '$INSTANCE_NAME' criada (HTTP $CREATE_HTTP)." >&2
  cat "$CREATE_TMP" >&2
fi

rm -f "$CREATE_TMP"

CONNECT_TMP="$(mktemp)"
CONNECT_HTTP=$(curl -sS -H "apikey: $AUTH_KEY" \
  -o "$CONNECT_TMP" -w "%{http_code}" \
  "$BASE_URL/instance/connect/$INSTANCE_NAME" || echo "000")

if [[ "$CONNECT_HTTP" != "200" ]]; then
  echo "error: falha ao conectar instância (HTTP $CONNECT_HTTP)." >&2
  cat "$CONNECT_TMP" >&2
  rm -f "$CONNECT_TMP"
  exit 1
fi

qr_base64=$(jq -r '
  .qrcode.base64? //
  .qrcode.qrCode? //
  .qrcode? //
  .qrCode? //
  .qr_code? //
  .base64? //
  empty
' "$CONNECT_TMP")

if [[ -z "$qr_base64" || "$qr_base64" == "null" ]]; then
  echo "error: QR code não retornado. Resposta:" >&2
  cat "$CONNECT_TMP" >&2
  rm -f "$CONNECT_TMP"
  exit 1
fi

echo "QR Code base64:"
echo "$qr_base64"

if [[ -n "$QR_OUTPUT" ]]; then
  echo "$qr_base64" | base64 -d > "$QR_OUTPUT"
  echo "QR salvo em $QR_OUTPUT"
fi

cat "$CONNECT_TMP"
rm -f "$CONNECT_TMP"
