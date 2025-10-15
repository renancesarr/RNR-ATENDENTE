# Solution Architect Workspace

- Centralize artefatos de arquitetura (diagramas, ADRs complementares, spikes) que sustentam as decisões técnicas.
- Registre trade-offs avaliados e critérios de aceitação antes de promover mudanças estruturais.
- Sempre referencie o status da implementação e links para PRs ou branches relevantes para facilitar revisões cruzadas.
- Consulte:
  - `docker-compose-core.md` — arquitetura dos serviços essenciais do compose.
  - `docker-compose-profiles.md` — perfis `dev`/`prod` e componentes opcionais.
  - `github-secrets.md` — catálogo de segredos e políticas de proteção.
  - `openai-credentials.md` — estratégia de injeção de credenciais OpenAI.
  - `database-save-flags.md` — parâmetros de persistência da Evolution API.
  - `ports-and-exposure.md` — portas expostas, recomendações de segurança e proxy.
  - `postgres-backup.md` — plano de backup/restore do banco principal.
  - `anonymization-job.md` / `retention-hard-delete.md` — políticas de retenção e limpeza.
  - `message-windows.md`, `response-latency.md`, `fact-tests.md` — métricas e validações SQL.
  - `phone-normalization.md` — função de padronização E.164.
  - `rag-embedding-jobs.md`, `rag-ingest-cli.md`, `rag-semantic-tests.md` — arquitetura do pipeline RAG.
