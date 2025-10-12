# Agrupamento de Conversas por Janela

Função: `fn_message_windows(p_window_minutes integer DEFAULT 30)`

## Descrição
- Agrupa mensagens de `messages` por `chat_id`, criando janelas sempre que o intervalo entre mensagens excede `p_window_minutes`.
- Retorna `chat_id`, `window_index`, `start_at`, `end_at`.
- View `chat_windows` usa o valor padrão de 30 minutos.

## Exemplo
```sql
SELECT * FROM fn_message_windows(30) WHERE chat_id = '...';
```

## Testes
- Script `db/tests/chat_windows.sql` insere mensagens artificiais e valida que duas janelas são criadas quando há intervalo > 30min.

Executar:
```bash
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U ${POSTGRES_SUPERUSER:-postgres} -d ${POSTGRES_SUPERUSER_DB:-postgres} \
  -f /app/db/tests/chat_windows.sql
```
