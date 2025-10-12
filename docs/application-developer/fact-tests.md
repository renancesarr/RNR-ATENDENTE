# Testes de Integridade das Tabelas de Fatos

Arquivo: `db/tests/fact_integrity.sql`

O script valida:
- `fact_conversation` possui `contact_id` e `chat_id` válidos.
- `fact_response` referencia chats existentes.
- `fact_lead` não registra `quote_sent_at` sem `quote_request_at`.
- `inbound/outbound_messages` não são negativos.

## Execução

```bash
./tools/test-facts.sh [--env path]
```

Se qualquer verificação falhar, o `psql` retorna erro com mensagem explicando o problema.

Execute após carregar dados de teste ou seeds para garantir consistência antes de liberar deploy.
