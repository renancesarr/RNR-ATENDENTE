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

if ! command -v curl >/dev/null 2>&1; then
  echo "error: curl não encontrado" >&2
  exit 1
fi

# Verifica se o stack está de pé
if ! docker compose ps evolution-api >/dev/null 2>&1; then
  echo "warning: stack não está ativo. Rode './start.sh' primeiro." >&2
  exit 1
fi

SAMPLES=${SAMPLES:-5}
CONCURRENT=${CONCURRENT:-1}
OUTPUT_FILE="${OUTPUT_FILE:-messages_load_test.csv}"
AUTH_HEADER="Authorization: Bearer ${EVOLUTION_AUTH_KEY:-}" 
BASE_URL="http://localhost:${EVOLUTION_PROXY_HTTP_PORT:-8088}"

rm -f "$OUTPUT_FILE"
echo "sample,elapsed_ms,status" >> "$OUTPUT_FILE"

send_message() {
  local idx="$1"
  local start
  local end
  local elapsed
  local status

  start=$(date +%s%3N)
  status=$(curl -fsS -o /tmp/resp-$$.json -w "%{http_code}" \
    -H "$AUTH_HEADER" \
    -H "Content-Type: application/json" \
    -X POST "$BASE_URL/messages" \
    --data @- <<JSON
{
  "chatId": "test-chat-$idx",
  "messageId": "auto-$idx-$(date +%s%N)",
  "direction": "inbound",
  "channel": "whatsapp",
  "sender": {"id": "+551199999000$idx"},
  "content": {"type": "text","text": "mensagem teste $idx"}
}
JSON
  ) || true

  end=$(date +%s%3N)
  elapsed=$((end - start))
  echo "$idx,$elapsed,$status" >> "$OUTPUT_FILE"
  rm -f /tmp/resp-$$.json
}

export -f send_message

if [[ "$CONCURRENT" -le 1 ]]; then
  for i in $(seq 1 "$SAMPLES"); do
    send_message "$i"
  done
else
  seq 1 "$SAMPLES" | xargs -n1 -P "$CONCURRENT" bash -c 'send_message "$@"' _
fi

echo "Resultados em $OUTPUT_FILE"
