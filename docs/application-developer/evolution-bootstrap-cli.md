# Login automático da Evolution API

Script: `scripts/evolution-login.sh`

## Uso básico

```bash
./scripts/evolution-login.sh --instance mvp-bot --qr-output qr.png
```

Parâmetros principais:
- `--instance`: nome da instância (padrão `EVOLUTION_INSTANCE_NAME` ou `mvp-bot`).
- `--env-file`: arquivo `.env` a ser carregado antes de chamar os endpoints (default `./.env`).
- `--base-url`: URL do serviço (default `http://localhost:<porta>` com porta encontrada no `.env`).
- `--qr-output`: caminho para salvar o PNG gerado a partir do base64 retornado.

Requisitos:
- `AUTHENTICATION_API_KEY` (ou `EVOLUTION_AUTH_KEY`) definido no `.env`/`.env.local`.
- `curl`, `jq` e `base64` disponíveis no PATH.
- Evolution API ativa (`docker compose up -d`).

Fluxo:
1. Garante que o token esteja configurado e resolve parâmetros necessários.
2. Cria (ou reaproveita) a instância via `POST /instance/create` com integração padrão `WHATSAPP-BAILEYS`.
3. Conecta a instância e obtém o QR (`GET /instance/connect/<instance>`), imprimindo o base64 e salvando o PNG quando solicitado.

Códigos de saída:
- `0`: QR obtido com sucesso.
- `2`: token de autenticação ausente.
- `3`: dependências (`curl`, `jq` ou `base64`) ausentes.
- `4`: script auxiliar `scripts/fetch-qr.sh` não encontrado.
