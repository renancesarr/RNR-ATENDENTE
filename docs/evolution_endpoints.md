# Endpoints Evolution API Utilizados

| Método | Endpoint | Descrição | Observações |
| --- | --- | --- | --- |
| `POST` | `/instance/create` | Cria instância WhatsApp e opcionalmente gera QR code. | Payload inclui `instanceName`, `token`, `integration`, `qrcode`. Usado por `scripts/evolution-login.sh`. |
| `GET` | `/instance/connect/{instance}` | Conecta instância e retorna QR code atual. | Retorna base64 quando sessão não está autenticada. |
| `GET` | `/instances/{instance}/status` | Consulta estado da sessão (connected/disconnected). | Usado pelo script de verificação `tools/evolution-session-check.py`. |

> **Observação:** tokens são extraídos de `AUTHENTICATION_API_KEY` no `.env`. Atualize este documento quando novos endpoints forem integrados (ex.: webhook de mensagens, envio de mensagens, gerenciamento de templates).
