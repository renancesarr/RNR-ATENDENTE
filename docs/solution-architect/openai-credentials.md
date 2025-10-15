# Credenciais OpenAI

## Fluxo recomendado
1. Armazene a chave real no cofre (Vault) ou GitHub Secret conforme ADR-001.
2. Durante deploy/CI, exporte `OPENAI_API_KEY` para o ambiente antes de executar a aplicação.
3. A CLI `tools/rag-ingest-cli.py` e demais scripts consomem `OPENAI_API_KEY` via `.env` (placeholder) ou variável de ambiente.

### Exemplo (local)
```bash
export OPENAI_API_KEY="sk-..."
./tools/rag-ingest-cli.py --file docs/faq.md --source-name "FAQ"
```

### Exemplo (CI/GitHub Actions)
```yaml
- name: Export OpenAI key
  run: echo "OPENAI_API_KEY=$OPENAI_API_KEY" >> $GITHUB_ENV
  env:
    OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
```

## Boas práticas
- Nunca commit a chave em repositório.
- Rotacione periodicamente no cofre e atualize os secrets.
- Registre uso/custos conforme ADR-006.
- Caso utilize base alternativa (`Azure OpenAI`, etc.), ajuste `OPENAI_API_BASE` no `.env`.
