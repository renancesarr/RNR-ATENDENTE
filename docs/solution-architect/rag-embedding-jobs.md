# Jobs de Atualização de Embeddings

Tabela: `rag_embedding_jobs`

## Como funciona
- Trigger `rag_documents_versioning` registra revisões e cria job `pending` com `payload` contendo `reason` e `revision`.
- Workers futuros devem consumir registros `pending`, gerar embeddings atualizados e atualizar `status` para `done` ou `failed`.
- Campos `retries` e timestamps permitem monitorar tentativas.

## Execução manual
Para consultar jobs pendentes:

```sql
SELECT id, document_id, scheduled_at FROM rag_embedding_jobs WHERE status = 'pending' ORDER BY scheduled_at;
```

Para marcar job como concluído após reprocessamento externo:

```sql
UPDATE rag_embedding_jobs
SET status = 'done', finished_at = now()
WHERE id = :id;
```

Recomendado implementar worker (ex.: script Python) que:
1. Busca jobs `pending` ordenados por `scheduled_at`.
2. Gera embeddings (reutilizando `tools/rag-ingest-cli.py` ou lógica equivalente).
3. Atualiza `status`, `finished_at` e limpa `error_message`.

Logs de falha devem ser preenchidos em `error_message` e `retries` incrementados para permitir observabilidade.
