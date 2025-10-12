# Chatbot WhatsApp – Evolution API MVP

## Visão geral
- Automação de atendimento/qualificação via Evolution API v2, focada em TTFR baixo e conversões para “pedido de orçamento”.
- IA generativa (OpenAI) com RAG alimentado por histórico de conversas e catálogo; respostas seguem padrões usados por atendentes humanos.
- Persistência completa em PostgreSQL (dados + embeddings `pgvector`), cache Redis e eventos RabbitMQ para consumidores de KPIs, RAG e integrações externas.
- Observabilidade inicial: logs estruturados e endpoints HTTP de métricas; ADRs documentam decisões arquiteturais em `docs/decisions/`.

## Diretrizes de desenvolvimento
- Adotamos as [Project Guidelines](https://github.com/elsewhencode/project-guidelines) como referência para fluxo de desenvolvimento, revisão de código e boas práticas colaborativas.
- A documentação operacional é distribuída por papéis em `docs/project-manager/`, `docs/scrum-master/`, `docs/solution-architect/`, `docs/business-model/` e `docs/application-developer/` para garantir rastreabilidade das decisões e evolução orientada a responsabilidades.
- Antes de iniciar qualquer trabalho automatizado, a IA deve revisar `docs/application-developer/README.md` e todos os arquivos `docs/application-developer/*-ia-code.md` existentes. Apenas se conseguir usar esses artefatos como contexto válido ela pode alterar o projeto; caso contrário, a execução deve ser interrompida.
- O fluxo IA exige cumprir `docs/application-developer/pre-flight.md`, registrar a entrega com `ia-change-template.md` → `<timestamp>-ia-code.md`, atualizar `changelog.md` e, quando aplicável, seguir o `webhook-playbook.md`. O script `tools/validate-ia-change.sh` e o workflow `IA Guard` validam esses requisitos.

## Estrutura atual
- `docs/decisions/ADR-20251012-containerization-strategy.md` — Compose em host único para o MVP.
- `docs/decisions/ADR-20251012-vector-store-strategy.md` — Armazenamento vetorial usando `pgvector`.
- `docs/decisions/ADR-20251012-observability-stack.md` — Stack leve de logs + métricas HTTP.
- `docker-compose.yml` — Orquestra Evolution API, Postgres, Redis, RabbitMQ, Typebot (opcional) e Watchtower.
- `.env.example` — Placeholder das variáveis obrigatórias; copiar para `.env` antes de subir os serviços.
- `README-TODO.md` — Backlog detalhado de atividades por domínio.

## Como iniciar
1. Copiar `.env.example` para `.env` e preencher segredos fortes (`AUTHENTICATION_API_KEY`, `POSTGRES_PASSWORD`, `TYPEBOT_POSTGRES_PASSWORD`, `SECRET_KEY` etc.).  
   - Fatorar o registro da chave OpenAI via endpoint seguro, nunca no arquivo `.env`.
2. Criar diretórios de decisão/observabilidade extras conforme necessário (`docs/observability`, `docs/security`).  
3. Subir os contêineres: `docker compose up -d`.  
4. Monitorar logs iniciais (`docker compose logs -f evolution-api rabbitmq postgres`) e validar healthchecks.  
5. Executar script/bootstrap (a ser implementado) para gerar instância, QR code e validar sessão.

## Operação & métricas
- Healthchecks ativos para Postgres, Redis, RabbitMQ, Typebot builder/viewer e Evolution API (ajustar endpoint real conforme documentação).  
- Debounce inicial em 30 s (`DEFAULT_DEBOUNCE_TIME_SECONDS`), configurável via API.  
- Endpoints planejados: `/metrics/response-rate`, `/metrics/conversion-to-proposal`, `/metrics/lead-value`, `/metrics/ttfr`.  
- Estruturar consumers RabbitMQ para:  
  - `insights-kpi`: consolidar eventos em fatos (`fact_conversation`, `fact_response_time`).  
  - `rag-ingestor`: gerar embeddings, armazenar em tabelas com `pgvector`.  
  - `integrations-dispatcher`: acionar CRM/ERP com idempotência.
- Logs estruturados devem incluir `conversation_id`, `message_id`, `lead_id` para correlação rápida.

## Próximos passos imediatos
- Implementar migrações SQL (habilitar `pgvector`, tabelas de mensagens/chats/métricas).  
- Construir script/endpoint de bootstrap da Evolution API (instância + QR).  
- Desenvolver consumidores RabbitMQ mínimos e testes E2E (texto + áudio + handoff).  
- Definir formato de log e endpoints de métricas conforme ADR de observabilidade.  
- Registrar decisões adicionais (segredos, backup, estratégia de custos OpenAI) na pasta de ADRs.
