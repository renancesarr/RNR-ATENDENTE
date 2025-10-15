# GitHub Secrets Necessários

Lista de secrets que devem ser configurados no repositório/organização para pipelines e automações futuras. Use valores placeholder até que integrações estejam ativas.

| Secret | Descrição | Placeholder |
| --- | --- | --- |
| `EVOLUTION_AUTH_KEY` | Chave da Evolution API usada por pipelines para chamadas administrativas. | `changeme` |
| `POSTGRES_SUPERUSER_PASSWORD` | Senha do usuário `postgres` usada por scripts de migração/backup. | `changeme` |
| `POSTGRES_APP_PASSWORD` | Senha do usuário de aplicação (`evolution_app`). | `changeme` |
| `REDIS_URL` | URL de conexão Redis (cache-only). | `redis://redis:6379/6` |
| `RABBITMQ_URI` | AMQP URI para filas (inclui usuário/senha). | `amqp://admin:admin@rabbitmq:5672/default` |
| `OPENAI_API_KEY` | Chave utilizada pelos pipelines de teste/validadores. | `sk-placeholder` |
| `VAULT_ADDR` | Endpoint do Vault definido no ADR-001. | `https://vault.example.com` |
| `VAULT_ROLE_ID` | Role ID para autenticação via AppRole. | `placeholder-role-id` |
| `VAULT_SECRET_ID` | Secret ID associado ao Role. | `placeholder-secret-id` |
| `TYPEBOT_ADMIN_EMAIL` | Conta administrativa usada em pipelines para configurar Typebot (profil `prod`). | `dev@example.com` |
| `TYPEBOT_ADMIN_PASSWORD` | Senha correspondente. | `changeme` |
| `WATCHTOWER_NOTIFICATION_URL` | (Opcional) Webhook para alertas de atualização do Watchtower. | `https://hooks.example.com/watchtower` |

> **Observação:** não commit os valores reais. Configure-os em **Settings → Secrets and variables → Actions**. Revise esta lista sempre que novos serviços forem introduzidos.
