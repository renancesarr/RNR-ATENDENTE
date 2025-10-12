#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 host:port [-t timeout] [-- command]" >&2
  exit 1
fi

TARGET=""
TIMEOUT=30
CMD=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --)
      shift
      CMD=($@)
      break
      ;;
    -t|--timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    *)
      TARGET="$1"
      shift
      ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "error: host:port must be provided" >&2
  exit 1
fi

HOST="${TARGET%%:*}"
PORT="${TARGET##*:}"

if ! [[ "$PORT" =~ ^[0-9]+$ ]]; then
  echo "error: invalid port '$PORT'" >&2
  exit 1
fi

echo "Waiting for $HOST:$PORT (timeout ${TIMEOUT}s)..."

for ((i=0; i<TIMEOUT; i++)); do
  if timeout 1 bash -c "</dev/tcp/$HOST/$PORT" &>/dev/null; then
    echo "Target available."
    if [[ ${#CMD[@]} -gt 0 ]]; then
      exec "${CMD[@]}"
    fi
    exit 0
  fi
  sleep 1
done

echo "Timeout after ${TIMEOUT}s waiting for $HOST:$PORT" >&2
exit 1
