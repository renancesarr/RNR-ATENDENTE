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

if [[ -z "$AUTH_KEY" ]]; then
  echo "error: AUTHENTICATION_API_KEY ou EVOLUTION_AUTH_KEY não definido." >&2
  exit 1
fi

create_payload=$(cat <<JSON
{
  "instanceName": "$INSTANCE_NAME",
  "description": "Instância criada via fetch-qr.sh",
  "qrcode": {"generate": true, "base64": true}
}
JSON
)

response=$(curl -sS -H "Authorization: Bearer $AUTH_KEY" -H "Content-Type: application/json" \
                 -X POST "$BASE_URL/instances/create" --data "$create_payload")

# Se já existir, tentar apenas consultar
if echo "$response" | grep -q 'Cannot POST'; then
  response=$(curl -sS -H "Authorization: Bearer $AUTH_KEY" "$BASE_URL/instances/$INSTANCE_NAME/qrcode")
fi

qr_base64=$(echo "$response" | jq -r '.qrcode.base64 // .base64 // empty')
if [[ -z "$qr_base64" ]]; then
  echo "error: QR code não retornado. Resposta:" >&2
  echo "$response" >&2
  exit 1
fi

echo "QR Code base64:" 
echo "$qr_base64"

if [[ -n "$QR_OUTPUT" ]]; then
  echo "$qr_base64" | base64 -d > "$QR_OUTPUT"
  echo "QR salvo em $QR_OUTPUT"
fi

jq -r '. | {instanceName, status, qrcode}' <<< "$response"
