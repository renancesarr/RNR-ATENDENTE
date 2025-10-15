# Métrica de Latência Ponta-a-Ponta

Função: `fn_register_response_latency`

## Uso
```sql
SELECT fn_register_response_latency(
  'msg-123',
  'chat-uuid',
  'contact-uuid',
  'bot',
  NOW() - INTERVAL '3 seconds',
  NOW()
);
```

- Calcula `response_time_ms` com base em `p_outbound_at - p_inbound_at`.
- Atualiza/inserte `fact_response` (idempotente via `message_id`).
- View `metrics_response_latency` agrega métricas diárias (média, p50, p95, samples).

## Teste
`db/tests/response_latency.sql` valida comportamento com um caso artificial.

Execução:
```bash
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U ${POSTGRES_SUPERUSER:-postgres} -d ${POSTGRES_SUPERUSER_DB:-postgres} \
  -f /app/db/tests/response_latency.sql
```
