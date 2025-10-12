# Teste de Busca Semântica RAG

Arquivo: `db/tests/rag_semantic.sql`

## O que valida
- Inserção de dados mock (`rag_sources`, `rag_documents`, `rag_embeddings`).
- Execução de consulta ordenada por distância vetorial (`<->`).
- Garante que o documento com vetor mais alinhado seja retornado.
- Remove registros de teste ao final.

## Execução

```bash
docker compose exec -T postgres \
  psql -v ON_ERROR_STOP=1 -U ${POSTGRES_SUPERUSER:-postgres} -d ${POSTGRES_SUPERUSER_DB:-postgres} \
  -f /app/db/tests/rag_semantic.sql
```

Se a busca não retornar o item esperado, o script levanta erro (`RAISE EXCEPTION`). Utilize após rodar migrações pgvector/RAG.
