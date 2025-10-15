# Job de Anonimização PII

Executa a função `fn_apply_retention_scrub()` que aplica as regras definidas em `audit_retention`.

## Como executar

```bash
./tools/apply-retention.sh [.env]
```

- Parâmetro opcional: caminho para `.env`. Se omitido, usa `./.env`.
- O script executa a função no Postgres e retorna um relatório `scope, rows_affected`.

## Comportamento atual

- `contacts`: anonimiza telefones (hash) e remove nome para registros com `created_at` anterior ao `scrub_after_days` configurado.
- `messages`: substitui `content->text` por `"[redacted]"` e remove `raw_payload` para registros antigos.
- Outros escopos retornam `0` linhas até que regras sejam implementadas.

## Boas práticas

- Executar após o job de backup para evitar perda de dados não anonimizada.
- Registrar execuções no `audit_retention_log` (tarefa futura).
- Ajustar pesos/regra da função conforme surgirem novos tipos de dados PII.
