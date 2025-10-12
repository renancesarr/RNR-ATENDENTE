# Verificação de Sessão Evolution API

Script: `tools/evolution-session-check.py`

## Uso

```bash
./tools/evolution-session-check.py --instance mvp-bot
```

Opções:
- `--base-url`: URL customizada (default `http://localhost:<porta>`).
- `--expect`: `connected` (default) ou `disconnected`.
- `--env`: caminho para `.env`.

O script chama `GET /instances/<instance>/status` e verifica o campo `connectionStatus` (ou `state`/`status`).

Retornos:
- `0`: estado corresponde ao esperado.
- `2`: sessão não está ativa quando o esperado era `connected`.
- `3`: sessão ativa quando esperado `disconnected`.
- `1`: erro de requisição ou campo ausente.

Útil para healthcheck pós-bootstrap (T-056) e pipelines de monitoração.
