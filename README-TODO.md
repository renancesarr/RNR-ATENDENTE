# README TODO

## Mandato do MVP
- Construir atendimento e qualificação de leads via WhatsApp, automatizando FAQs de pré-venda com base na Evolution API v2, priorizando TTFR e conversões para proposta.
- Entregar trilha completa: ingestão (Evolution API), persistência (PostgreSQL), cache (Redis), eventos (RabbitMQ), IA (OpenAI + RAG + STT/TTS), integrações externas e métricas de funil.
- Aprender com atendentes humanos: reaproveitar respostas existentes, ajustar tom conforme histórico, sem prometer prazos fixos.
- Handoff obrigatório para intenções de cancelamento, conflitos críticos ou pedidos jurídicos.

## Regras Operacionais
- Planejar → Implementar → Auto-revisar → Testar → Registrar decisões (ADRs em `docs/decisions`).
- Mensagens/eventos idempotentes com chaves naturais (`message_id`, `conversation_id`).
- Debounce configurável (30s padrão; até 120s em campanhas).
- Segredos nunca são commitados; usar Vault/GitHub Secrets.
- Observabilidade mínima: logs estruturados, métricas HTTP simples e KPIs expostos via REST.

## KPIs & Métricas-Norte
- Taxa de resposta = mensagens respondidas / recebidas.
- Conversão para proposta = % conversas que chegam em “pedido de orçamento”.
- Valor estimado do lead = heurística inicial com aprendizado incremental.
- TTFR (tempo até 1ª resposta) + % conversas com “pedido de orçamento” são métricas-norte.

## Backlog Inicial (Sprint 0 — 1 a 2 dias)

### Fundação & Governança
- [ ] Criar estrutura `docs/decisions/` + template ADR base (`ADR-YYYYMMDD-template.md`).
- [ ] Levantar alternativas (Docker Compose vs Pods dedicados, banco único vs multi DB) e registrar ADR inicial com decisão provisória para hospedagem local.
- [ ] Configurar `README.md` principal com visão técnica, KPIs, arquitetura lógica e instruções de operação.
- [ ] Definir convenções de nomenclatura (instâncias, filas, coleções) e versionamento de API interna (`docs/standards/naming.md`).

### Ambientes & Segredos
- [ ] Criar `.env.example` com placeholders para Evolution API, Postgres, Redis, RabbitMQ, Typebot, OpenAI (sem segredos reais).
- [ ] Documentar estratégia de segredos (Vault/Secrets) e rotinas de rotação (`docs/security/secrets.md`).
- [ ] Enumerar variáveis de infraestrutura obrigatórias e dependências de rede (Whitelists, portas).

### Infraestrutura Contêinerizada
- [ ] Redigir `docker-compose.yml` com Evolution API, Postgres (persistência), Redis, RabbitMQ, Typebot (builder/viewer/opcional), Watchtower/Autoheal (avaliar necessidade) e volumes nomeados (instâncias, dados, filas).
- [ ] Adicionar healthchecks consistentes para todos os serviços (Postgres, Redis, RabbitMQ, Evolution API, Typebot).
- [ ] Garantir persistência das instâncias WhatsApp (`/evolution/instances`) e bancos (Postgres e Typebot) via volumes.
- [ ] Especificar rede Docker dedicada e políticas de reinício (`restart: always` com backoff quando apropriado).

### Banco de Dados & Migrações
- [ ] Definir modelo lógico (tabelas: `contacts`, `chats`, `messages`, `conversation_metrics`, `lead_facts`, `response_times` etc.).
- [ ] Gerar migrações SQL iniciais (schema + índices + constraints de idempotência).
- [ ] Criar seeds mínimas (estado inicial, status de conversa, motivos de handoff).
- [ ] Documentar convenções de versionamento de migrações e processo de rollback seguro.

### Bootstrap da Evolution API
- [ ] Implementar script/endpoint para criar instância WhatsApp, obter QR code e validar sessão (CLI ou API wrapper em `/scripts/bootstrap-instance.ts`).
- [ ] Codificar rotina de verificação da sessão (status polling + logs amigáveis) e fallback de reconexão.
- [ ] Habilitar flags de persistência no carregamento inicial (database/cache/rabbitmq).
- [ ] Configurar debounce padrão (30s) e parametrização (ENV + API).

### Bots & Inteligência
- [ ] Planejar prompts base com histórico existente (catalogar respostas humanas reutilizáveis).
- [ ] Implementar cadastro de credenciais OpenAI (`/openai/creds`) com armazenamento seguro (referência a cofre).
- [ ] Criar bot OpenAI com `triggerType="all"` + `debounceTime` configurável; expor endpoints para atualizar modelo/limites/token budget.
- [ ] Ativar STT (Whisper) e preparar pipeline opcional de TTS (selecionar motor com orçamento controlado).
- [ ] Mapear fluxos Typebot relevantes (se necessário) e registrar IDs/URLs higienizadas.

### RAG & Conhecimento
- [ ] Definir estratégia de embeddings (OpenAI vs modelo local) e armazenar em `pgvector` ou serviço externo; registrar ADR comparando opções.
- [ ] Implementar pipeline de ingestão: mensagens → fila → consumidor RAG → geração/atualização de índices.
- [ ] Criar camada de busca (`/rag/search`) que retorna trechos canônicos com score/confiança e sinaliza baixa confiança.
- [ ] Integrar resultados do RAG ao prompt do bot OpenAI (template com citações/tags de origem).

### Eventos & Consumers RabbitMQ
- [ ] Declarar trocas/filas globais (ex.: `evolution.exchange`, `events.message.received`, `events.message.sent`).
- [ ] Criar consumer `insights-kpi` consolidando eventos para `fact_conversation`, `fact_lead`, `fact_response_time`.
- [ ] Criar consumer `rag-ingestor` (pré-processador para embeddings) com backoff exponencial e DLQ.
- [ ] Criar consumer `integrations-dispatcher` para webhooks/CRM/ERP (idempotente + retries).
- [ ] Documentar contratos de payload (schemas JSON + versionamento).

### Métricas & Observabilidade
- [ ] Expor endpoint `/metrics/response-rate`, `/metrics/conversion-to-proposal`, `/metrics/lead-value`, `/metrics/ttfr` (usar cache curto via Redis quando aplicável).
- [ ] Implementar logs estruturados (JSON) com correlação (`conversation_id`, `message_id`).
- [ ] Configurar coleta de métricas (Prometheus-style ou simples JSON) e alertas mínimos.
- [ ] Especificar dashboards/base de monitoramento (Grafana ou alternativa) em `docs/observability`.

### Testes & Qualidade
- [ ] Definir framework de testes (ex.: Jest + supertest) e padrão de fixtures.
- [ ] Escrever testes simulando diálogo texto, áudio, desconto, handoff humano e debounce multi-thread.
- [ ] Adicionar testes de migração (rodar & validar schema) e smoke de compose.
- [ ] Implantar lint/format (ESLint/Prettier) e scripts npm correspondentes.
- [ ] Configurar CI inicial (validar lint, testes, migrações, build docker).

### Custos & Governança de Modelos
- [ ] Criar módulo de controle de custos (limites de tokens/mensal, fallback de modelo).
- [ ] Registrar política de downgrade (ex.: GPT-4 → GPT-3.5 → modelo local) em caso de erro/custos.
- [ ] Emitir relatórios de uso por período (histórico no Postgres).

### Integrações Externas
- [ ] Especificar endpoints/webhooks para CRM/ERP (cadastro de lead, consulta estoque/preço) e contratos de auth.
- [ ] Mapear gatilhos/intenções que disparam integrações (ex.: status `pedido_orcamento`).
- [ ] Documentar replays idempotentes e assinatura de mensagens (HMAC).

### Segurança & Compliance
- [ ] Revisar exposição de portas via proxy reverso + API key.
- [ ] Adicionar rate limiting e proteção básica (middleware).
- [ ] Mapear requisitos LGPD (retenção, opt-out, anonimização).

## Próximo Passo Imediato
- Revisar o PDF em detalhes para extrair requisitos implícitos, converter em ADRs iniciais e iniciar a elaboração do `docker-compose.yml` + `.env.example`. Conferir com o usuário priorização entre infraestrutura (compose/env) e documentação (ADRs/README principal) antes de escrever código.

