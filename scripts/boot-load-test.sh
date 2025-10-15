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

START_FLAGS="${START_FLAGS:-}"   # permite START_FLAGS="--skip-pull"
RETRY_ATTEMPTS=${RETRY_ATTEMPTS:-10}
RETRY_INTERVAL=${RETRY_INTERVAL:-60}
HEALTH_URL="http://localhost:${EVOLUTION_PROXY_HTTP_PORT:-8088}/"
AUTH_HEADER="Authorization: Bearer ${EVOLUTION_AUTH_KEY:-}"

log() { printf '[boot-load] %s\n' "$*"; }

start_epoch=$(date +%s)
log "Iniciando stack com ./start.sh ${START_FLAGS}" 
./start.sh ${START_FLAGS}
end_epoch=$(date +%s)
startup_sec=$(( end_epoch - start_epoch ))
log "Stack iniciada em ${startup_sec}s"

i=1
status_code=""
body=""
while [[ $i -le $RETRY_ATTEMPTS ]]; do
  log "Tentativa ${i}/${RETRY_ATTEMPTS} — verificando ${HEALTH_URL}" 
  if command -v curl >/dev/null 2>&1; then
    body=$(curl -fsS -H "$AUTH_HEADER" -o - -w "\n%{http_code}" "$HEALTH_URL" || true)
    status_code=$(printf '%s' "$body" | tail -n1)
  else
    log "curl não encontrado; abortando" >&2
    exit 1
  fi
  if [[ "$status_code" == "200" ]]; then
    log "Healthcheck OK (HTTP 200) na tentativa ${i}" 
    break
  fi
  log "Healthcheck ainda não respondeu 200 (status atual: ${status_code:-N/A}). Aguardando ${RETRY_INTERVAL}s..."
  sleep "$RETRY_INTERVAL"
  i=$(( i + 1 ))
done

echo "--- Boot Load Test ---"
echo "Tempo para iniciar containers : ${startup_sec}s"
echo "Tentativas saúde realizadas : ${i}"
echo "Status final healthcheck   : ${status_code:-N/A}"
echo "-------------------------"
