# CLI de Ingestão RAG

Script: `tools/rag-ingest-cli.py`

## Uso básico

```bash
./tools/rag-ingest-cli.py \
  --file docs/faq.md \
  --source-name "FAQ Comercial" \
  --description "Perguntas frequentes MVP"
```

Opções principais:
- `--chunk-size` / `--chunk-overlap` (default 500/50 palavras)
- `--model` (default `text-embedding-3-small`)
- `--env` para apontar outro `.env`
- `--skip-embedding` para carregar chunks sem chamar OpenAI (vetor nulo)

## Requisitos
- `OPENAI_API_KEY` definido no `.env` (exceto se usar `--skip-embedding`).
- Serviços do compose ativos (`docker compose up -d`).

O script:
1. Cria/atualiza `rag_sources` conforme `--source-name`.
2. Registra documento (`rag_documents`) com checksum SHA-256 para deduplicação.
3. Gera chunks e produz embeddings via API OpenAI (ou vetor nulo).
4. Insere/atualiza `rag_embeddings` com metadados (`model`).

Erros são exibidos no console; qualquer falha encerra o processo com código ≠ 0.
