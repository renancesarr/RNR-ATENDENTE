# CLI de Bootstrap da Evolution API

Script: `tools/evolution-bootstrap.py`

## Uso básico

```bash
./tools/evolution-bootstrap.py --instance mvp-bot --qr-output qr.png
```

Parâmetros principais:
- `--instance` (obrigatório): nome da instância.
- `--base-url`: URL do serviço (`http://localhost:<porta>` por padrão).
- `--poll-seconds`: intervalo entre tentativas de obter o QR (default 5s).
- `--max-attempts`: número máximo de polls (default 12 ≈ 1 minuto).
- `--qr-output`: salva QR (base64) como PNG decodificado.
- `--print-only`: mostra payloads sem chamar a API (uso para review).

Requisitos:
- `AUTHENTICATION_API_KEY` definido no `.env` (ou `EVOLUTION_AUTH_KEY`).
- Evolution API ativa (`docker compose up -d`).

Fluxo:
1. Faz `POST /instances/create` para gerar instância (payload inclui `qrcode.generate`).
2. Faz polling `GET /instances/<instance>/qrcode` até receber campo `base64`.
3. Exibe o QR no console e opcionalmente salva em arquivo.

Falhas retornam código ≠ 0 e mensagem detalhada (body HTTP) para diagnóstico.
