# Normalização de Telefones (E.164)

Função: `fn_normalize_phone(p_input text, p_default_country_code text DEFAULT '55')`

## Regras
- Remove caracteres não numéricos (mantém `+`).
- Se iniciar com `+`, retorna sem alterações.
- Se iniciar com `00`, converte para `+` (ex.: `00 1 999` → `+1999`).
- Caso contrário, remove zeros à esquerda e prefixa com `+<country_code>` (default `55`).
- Entrada nula ou vazia retorna `NULL`.

## Exemplos
```sql
SELECT fn_normalize_phone('+5511999999999'); -- +5511999999999
SELECT fn_normalize_phone('011 99999-9999'); -- +550119999999999 (padrão CC=55)
SELECT fn_normalize_phone('202-555-0123', '1'); -- +12025550123
```

## Testes
Execute `db/tests/phone_normalization.sql`:

```bash
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U ${POSTGRES_SUPERUSER:-postgres} -d ${POSTGRES_SUPERUSER_DB:-postgres} \
  -f /app/db/tests/phone_normalization.sql
```

Caso haja divergências, o script lança exceções detalhando o valor inesperado.
