# Endpoints Evolution API Utilizados

| Método | Endpoint | Descrição | Observações |
| --- | --- | --- | --- |
| `POST` | `/instances/create` | Cria instância WhatsApp, podendo solicitar QR code em base64. | Payload inclui `instanceName`, `cid`, `token`, `qrcode.generate`. Usado por `scripts/evolution-login.sh`. |
| `GET` | `/instances/{instance}/qrcode` | Obtém QR code atual da instância. | Retorna base64 quando sessão não está autenticada. Polling após criação. |
| `GET` | `/instances/{instance}/status` | Consulta estado da sessão (connected/disconnected). | Usado pelo script de verificação `tools/evolution-session-check.py`. |

> **Observação:** tokens são extraídos de `AUTHENTICATION_API_KEY` no `.env`. Atualize este documento quando novos endpoints forem integrados (ex.: webhook de mensagens, envio de mensagens, gerenciamento de templates).
