# Naming Standards

Este documento consolida convenções de nomenclatura para garantir consistência entre componentes da plataforma. Sempre valide se o identificador proposto está de acordo antes de criar novas tabelas, filas ou serviços.

## Banco de Dados (PostgreSQL)
- **Esquemas**: minúsculo com underscore. Ex.: `public`, `analytics`.
- **Tabelas**: `snake_case` no singular para entidades (`conversation`, `message`) e plural para coleções analíticas (`fact_conversation`, `dim_agent`).
- **Colunas**: `snake_case`; campos booleanos com prefixo `is_` ou `has_` (ex.: `is_active`).
- **Chaves primárias**: `id` com tipo UUID (`uuid_generate_v7()` quando disponível). Chaves compostas seguem `entity_id`.
- **Índices**: `idx_<tabela>_<coluna>` ou `idx_<tabela>_<colunas>`; índices únicos com prefixo `uidx_`.
- **Constraints**: `fk_<tabela>_<tabela_ref>`, `chk_<tabela>_<campo>`.
- **Funções**: `fn_<domínio>_<ação>` (ex.: `fn_retention_apply_anonymization`).

## Mensageria (RabbitMQ)
- **Exchanges**: `ex.<domínio>.<propósito>` (ex.: `ex.metrics.events`, `ex.rag.ingest`).
- **Filas**: `q.<serviço>.<evento>` (ex.: `q.insights-kpi.quote`, `q.rag.ingest`).
- **Dead-letter queues**: adicionar sufixo `.dlq` (ex.: `q.insights-kpi.quote.dlq`).
- **Routing keys**: `event.<categoria>.<ação>` (ex.: `event.conversation.created`).

## Serviços e containers
- **Serviços compose**: `kebab-case` curto (ex.: `evolution-api`, `rag-worker`, `insights-kpi`).
- **Imagens Docker internas**: `registry/org/<serviço>:<tag>`, tags sem espaços (`v1.0.0`, `sha-<hash>`).
- **Scripts utilitários**: `kebab-case` (ex.: `bootstrap-session.sh`).

## Código e pacotes
- **Namespaces/pacotes**: seguir convenções da linguagem (Node.js: `kebab-case` para pacotes, Python: `snake_case`).
- **Variáveis ambiente**: `UPPER_SNAKE_CASE`; prefixar por domínio (`RABBITMQ_URL`, `RAG_TOP_K`).
- **Feature flags**: `FF_<DOMÍNIO>_<DESCRICAO>` (ex.: `FF_RAG_FALLBACK_ENABLED`).

## Logging e Métricas
- **Nomes de logger**: `app.<contexto>` (ex.: `app.rag.ingestion`).
- **Métricas Prometheus**: `snake_case`; contadores com sufixo `_total` (ex.: `debounce_overrides_total`), histograms com `_seconds` ou `_milliseconds`.
- **Campos de log**: `snake_case`; IDs padronizados (`conversation_id`, `lead_id`, `message_id`).

## Git e Branches
- **Branches**: `feature/T-XXX-descricao`, `fix/T-XXX`, `chore/T-XXX`.
- **Tags Git**: `v<major>.<minor>.<patch>` (ex.: `v0.1.0`).

## Outros
- **Dashboards**: `<domínio> - <foco>` (ex.: `Conver-são - Pedidos de Orçamento`). Evite caracteres especiais não suportados.
- **Secrets no Vault**: hierarquia `kv/<ambiente>/<serviço>/<nome>` (ex.: `kv/prod/rag/openai_api_key`).

Atualize este documento sempre que novas convenções forem aprovadas via ADR.
