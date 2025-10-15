# Backlog T-001 a T-150 (Checklist para GitHub Issues)

- [x] **T-001** — Criar repositório + branches main/develop
  
  Descrição: Criar repo (privado/público), proteger branches main/develop.
CA: Repo criado; branches protegidas.
Dep: —
  
  _Labels:_ `planning,repo`

- [x] **T-002** — Adicionar .gitignore (Node, Python, Docker, logs)
  
  Descrição: Arquivo .gitignore cobrindo artefatos comuns e logs.
CA: Itens indesejados ignorados.
Dep: T-001
  
  _Labels:_ `planning,repo`

- [x] **T-003** — Criar README.md com visão MVP e KPIs
  
  Descrição: Escrever README com objetivo, KPIs, stack e como rodar.
CA: Seções presentes e claras.
Dep: T-001
  
  _Labels:_ `planning,docs`

- [x] **T-004** — Definir LICENSE (MIT/Apache2)
  
  Descrição: Escolher licença (MIT/Apache2) e adicionar arquivo LICENSE.
CA: LICENSE no repo.
Dep: T-001
  
  _Labels:_ `planning,legal`

- [x] **T-005** — Criar templates de Issue e PR
  
  Descrição: Adicionar .github/ISSUE_TEMPLATE e PULL_REQUEST_TEMPLATE.md.
CA: Templates ativos.
Dep: T-001
  
  _Labels:_ `planning,repo`

- [x] **T-006** — ADR-000: Arquitetura geral
  
  Descrição: Documentar arquitetura (Evolution API, Postgres, Redis, RabbitMQ, OpenAI).
CA: docs/decisions/ADR-000.md commitado.
Dep: T-003
  
  _Labels:_ `planning,adr,architecture`

- [x] **T-007** — ADR-001: Política de segredos
  
  Descrição: Definir uso de Vault/GitHub Secrets e proibições.
CA: ADR publicado.
Dep: T-006
  
  _Labels:_ `security,adr`

- [x] **T-008** — ADR-002: Estratégia de RAG
  
  Descrição: Fontes, embeddings, top-k, fallback e custos.
CA: Trade-offs documentados.
Dep: T-006
  
  _Labels:_ `adr,rag`

- [x] **T-009** — ADR-003: Métrica-norte e eventos de conversão
  
  Descrição: Definir 'pedido de orçamento' e TTFR (tempo até 1ª resposta).
CA: Eventos e cálculo definidos.
Dep: T-003
  
  _Labels:_ `adr,metrics`

- [x] **T-010** — ADR-004: Estratégia de debounce (30–120s)
  
  Descrição: Definir janelas por cenário e impacto.
CA: Tabela de cenários e janelas.
Dep: T-006
  
  _Labels:_ `adr,bot`

- [x] **T-011** — ADR-005: Retenção/anonimização
  
  Descrição: Política parametrizável para PII e histórico.
CA: Parâmetros definidos.
Dep: T-007
  
  _Labels:_ `adr,security,privacy`

- [x] **T-012** — Criar CONTRIBUTING.md
  
  Descrição: Guia de contribuição, convenções, testes.
CA: Arquivo presente.
Dep: T-003
  
  _Labels:_ `docs,repo`

- [x] **T-013** — Definir convenções de nomes
  
  Descrição: Padrões para tabelas, filas, exchanges, serviços.
CA: /docs/standards.md.
Dep: T-006
  
  _Labels:_ `architecture,docs`

- [x] **T-014** — Roadmap de releases (MVP → Piloto → Produção)
  
  Descrição: Roadmap e critérios de promoção.
CA: /docs/roadmap.md.
Dep: T-003
  
  _Labels:_ `planning,docs`

- [x] **T-015** — Configurar Kanban no GitHub Projects
  
  Descrição: Criar colunas To do / Doing / Review / Done.
CA: Board ativo.
Dep: T-001
  
  _Labels:_ `planning,repo`

- [x] **T-016** — docker-compose: Postgres e Redis
  
  Descrição: Compose com Postgres e Redis; volumes e network básicos.
CA: docker compose up sobe 2 serviços.
Dep: T-013
  
  _Labels:_ `infra,docker`

- [x] **T-017** — Adicionar RabbitMQ ao compose
  
  Descrição: Serviço RabbitMQ (+ mgmt opcional) com usuários e vhost.
CA: Fila acessível.
Dep: T-016
  
  _Labels:_ `infra,docker,queue`

- [x] **T-018** — Adicionar Evolution API ao compose
  
  Descrição: Serviço evolution com healthcheck e variáveis de ambiente.
CA: Serviço healthy.
Dep: T-017
  
  _Labels:_ `infra,docker,api`

- [x] **T-019** — Volume /evolution/instances
  
  Descrição: Montar volume persistente para sessões WhatsApp.
CA: Volume configurado.
Dep: T-018
  
  _Labels:_ `infra,docker,storage`

- [x] **T-020** — Healthchecks para todos os serviços
  
  Descrição: Adicionar healthchecks consistentes a compose.
CA: Todos healthy após boot.
Dep: T-018
  
  _Labels:_ `infra,observability`

- [x] **T-021** — Criar env/.env.example
  
  Descrição: Placeholders de Postgres, Redis, RabbitMQ, API keys.
CA: Arquivo comentado.
Dep: T-016
  
  _Labels:_ `infra,security`

- [ ] **T-022** — Makefile (up/down/logs)
  
  Descrição: Facilitar ciclo de vida: up, down, logs, e2e.
CA: make up/down/logs funcionando.
Dep: T-016
  
  _Labels:_ `infra,dx`

- [x] **T-023** — Proxy reverso com API key (NGINX/Caddy)
  
  Descrição: Proteger Evolution API com header de autorização.
CA: Requisições sem header falham.
Dep: T-018
  
  _Labels:_ `infra,security,api`

- [x] **T-024** — Rede docker dedicada
  
  Descrição: Criar bridge específica para serviços.
CA: Network nomeada criada.
Dep: T-016
  
  _Labels:_ `infra,docker`

- [x] **T-025** — Criar usuário/DB no Postgres (migração bootstrap)
  
  Descrição: Script/migração para role e database.
CA: DB e role criados.
Dep: T-016
  
  _Labels:_ `db,migrations`

- [x] **T-026** — Backup local do Postgres (pg_dump cron)
  
  Descrição: Script de backup e doc de restore.
CA: Backup e restore testados.
Dep: T-025
  
  _Labels:_ `db,backup`

- [x] **T-027** — Seed de dados mínimos
  
  Descrição: Seed idempotente (admin interno, flags).
CA: Seed reexecutável.
Dep: T-025
  
  _Labels:_ `db,seed`

- [x] **T-028** — Configurar Redis cache-only
  
  Descrição: Desativar persistência (appendonly no).
CA: Redis como cache.
Dep: T-016
  
  _Labels:_ `infra,cache`

- [x] **T-029** — DLQ no RabbitMQ
  
  Descrição: Exchanges/bindings/TTL para dead letters.
CA: DLQ ativo.
Dep: T-017
  
  _Labels:_ `queue,reliability`

- [x] **T-030** — Profiles dev vs prod no compose
  
  Descrição: Alternar serviços extras com --profile.
CA: Perfis funcionando.
Dep: T-016
  
  _Labels:_ `infra,docker`

- [x] **T-031** — Script wait-for-it/dockerize
  
  Descrição: Sincronizar inicialização por dependências.
CA: Ordem robusta.
Dep: T-016
  
  _Labels:_ `infra,dx`

- [x] **T-032** — Documentar portas e exposição
  
  Descrição: Tabela de portas; recomendações de segurança.
CA: README atualizado.
Dep: T-023
  
  _Labels:_ `docs,security`

- [ ] **T-033** — Teste de carga leve no boot
  
  Descrição: Medir latências pós-boot.
CA: Relatório simples.
Dep: T-020
  
  _Labels:_ `infra,performance`

- [x] **T-034** — Configurar GitHub Secrets (placeholders)
  
  Descrição: Nomear todos os secrets exigidos.
CA: Lista completa no repo.
Dep: T-007
  
  _Labels:_ `security,repo`

- [x] **T-035** — ADR-006: Estimativa de custos infra
  
  Descrição: Estimar custos por serviço.
CA: ADR com planilha.
Dep: T-016
  
  _Labels:_ `adr,costs`

- [x] **T-036** — Esquema base: messages/contacts/chats/history
  
  Descrição: Diagrama e migrações para entidades core.
CA: Migrações aplicáveis.
Dep: T-013, T-025
  
  _Labels:_ `db,modeling`

- [x] **T-037** — Tabelas de fatos para KPIs
  
  Descrição: fact_conversation, fact_response, fact_lead.
CA: Chaves/índices/FK.
Dep: T-036
  
  _Labels:_ `db,metrics`

- [x] **T-038** — Tabela event_log (idempotência)
  
  Descrição: Log de eventos com chave natural (event_id).
CA: Unicidade garantida.
Dep: T-037
  
  _Labels:_ `db,reliability`

- [x] **T-039** — Tabela bot_config (debounce, modelos, limites)
  
  Descrição: Configuração dinâmica do bot.
CA: CRUD mínimo.
Dep: T-036
  
  _Labels:_ `db,bot`

- [x] **T-040** — Índices de performance
  
  Descrição: phone, conversation_id, created_at.
CA: EXPLAIN usando índices.
Dep: T-036
  
  _Labels:_ `db,performance`

- [x] **T-041** — Views de métricas (response-rate/TTFR/conversão)
  
  Descrição: 3 views com cálculos validados.
CA: SELECTs retornam valores coerentes.
Dep: T-037
  
  _Labels:_ `db,metrics`

- [x] **T-042** — Função SQL de valor estimado do lead (v1)
  
  Descrição: Heurística parametrizada.
CA: Função e testes.
Dep: T-037
  
  _Labels:_ `db,metrics`

- [x] **T-043** — Habilitar DATABASE_SAVE_DATA_*
  
  Descrição: Flags para persistência total. Documentar.
CA: Flags ativas e auditadas.
Dep: T-036
  
  _Labels:_ `db,config`

- [x] **T-044** — Seed de catálogo de produtos (mock)
  
  Descrição: 5–10 itens representativos.
CA: Dados carregados.
Dep: T-036
  
  _Labels:_ `db,seed`

- [x] **T-045** — Tabela audit_retention (política)
  
  Descrição: scrub_after_days, delete_after_months.
CA: Migração criada.
Dep: T-011
  
  _Labels:_ `db,privacy`

- [x] **T-046** — Job de anonimização PII
  
  Descrição: Mascarar dados sensíveis conforme política.
CA: Relatório de linhas afetadas.
Dep: T-045
  
  _Labels:_ `db,privacy`

- [x] **T-047** — Job de limpeza hard-delete
  
  Descrição: Exclusão definitiva com dry-run.
CA: Execução segura.
Dep: T-045
  
  _Labels:_ `db,privacy`

- [x] **T-048** — Testes SQL de integridade de fatos
  
  Descrição: Asserts de contagem e FK.
CA: Suíte verde.
Dep: T-037
  
  _Labels:_ `db,tests`

- [x] **T-049** — Dicionário de dados
  
  Descrição: Documentar entidades/campos/relacionamentos.
CA: /docs/data_dictionary.md.
Dep: T-036
  
  _Labels:_ `docs,db`

- [x] **T-050** — ADR-007: pgvector vs serviço vetorial
  
  Descrição: Decisão para RAG.
CA: ADR com prós/contras.
Dep: T-008
  
  _Labels:_ `adr,rag`

- [x] **T-051** — Esquema RAG (documents/embeddings)
  
  Descrição: Tabelas e migrações para RAG.
CA: Migrações aplicáveis.
Dep: T-050
  
  _Labels:_ `db,rag`

- [x] **T-052** — CLI de ingestão RAG
  
  Descrição: `ingest --path ...` para catálogo/políticas.
CA: Ingestão com logs.
Dep: T-051
  
  _Labels:_ `rag,cli`

- [x] **T-053** — Versionamento de fontes RAG
  
  Descrição: Campo source_version e política.
CA: Versão atualizada ao reingestar.
Dep: T-051
  
  _Labels:_ `rag,db`

- [x] **T-054** — Atualização de embeddings on-change
  
  Descrição: Trigger/job para reindex.
CA: Atualização automática.
Dep: T-052
  
  _Labels:_ `rag,automation`

- [x] **T-055** — Testes de busca semântica
  
  Descrição: Conjunto de casos com gold set.
CA: Precisão mínima definida.
Dep: T-052
  
  _Labels:_ `rag,tests`

- [x] **T-056** — Criar instância e obter QR
  
  Descrição: Endpoint/script para criar instância e exibir QR.
CA: QR armazenado; doc do fluxo.
Dep: T-018
  
  _Labels:_ `whatsapp,evolution`

- [x] **T-057** — Validar sessão ativa
  
  Descrição: Ping/version para checar sessão.
CA: Status OK/erro claro.
Dep: T-056
  
  _Labels:_ `whatsapp,evolution`

- [ ] **T-058** — Persistir todas as mensagens
  
  Descrição: Armazenar mensagens recebidas/enviadas.
CA: Inserts em messages auditados.
Dep: T-043, T-057
  
  _Labels:_ `whatsapp,db`

- [ ] **T-059** — Tratamento de anexos (imagem/áudio)
  
  Descrição: Webhook/consumer para anexos e metadados.
CA: Blobs/paths registrados.
Dep: T-058
  
  _Labels:_ `whatsapp,storage`

- [x] **T-060** — Normalização de contatos (E.164)
  
  Descrição: Função de normalização e testes.
CA: Telefones uniformizados.
Dep: T-036
  
  _Labels:_ `whatsapp,data`

- [x] **T-061** — Agrupamento de conversas por janela
  
  Descrição: Janela configurável para threads.
CA: Casos de teste.
Dep: T-036
  
  _Labels:_ `whatsapp,logic`

- [ ] **T-062** — Publicar eventos MESSAGES_*
  
  Descrição: Evolution → RabbitMQ (idempotente).
CA: Eventos publicados.
Dep: T-017, T-058
  
  _Labels:_ `queue,whatsapp`

- [ ] **T-063** — Handler de envio SEND_MESSAGE
  
  Descrição: Consumir e enviar respostas, confirmar persistência.
CA: Saída confirmada.
Dep: T-062
  
  _Labels:_ `queue,whatsapp`

- [ ] **T-064** — Retry/backoff no envio
  
  Descrição: 3 tentativas + DLQ.
CA: Falhas roteadas à DLQ.
Dep: T-063
  
  _Labels:_ `queue,reliability`

- [x] **T-065** — Métrica de latência ponta-a-ponta
  
  Descrição: Recebido→respondido em fact_response.
CA: Registros consistentes.
Dep: T-037
  
  _Labels:_ `metrics,observability`

- [ ] **T-066** — Simulador de conversas (CLI)
  
  Descrição: Gerar diálogos sintéticos.
CA: Script envia lote controlado.
Dep: T-063
  
  _Labels:_ `dx,tests`

- [ ] **T-067** — Proteção por API key no proxy
  
  Descrição: Bloquear sem header válido.
CA: Teste negativo/positivo.
Dep: T-023
  
  _Labels:_ `security,api`

- [ ] **T-068** — Rate limit no proxy
  
  Descrição: Limitar requisições por IP/chave.
CA: Threshold testado.
Dep: T-067
  
  _Labels:_ `security,api`

- [x] **T-069** — Documentar endpoints Evolution usados
  
  Descrição: /docs/evolution_endpoints.md.
CA: Doc fechada.
Dep: T-056
  
  _Labels:_ `docs,whatsapp`

- [ ] **T-070** — Testes e2e WhatsApp (RX/TX/DB)
  
  Descrição: Recebimento, armazenamento e envio fim-a-fim.
CA: Relatório verde.
Dep: T-066
  
  _Labels:_ `tests,e2e`

- [x] **T-071** — Configurar credencial OpenAI (placeholders)
  
  Descrição: Variáveis OPENAI_* e sem segredos no repo.
CA: Injeção via secrets.
Dep: T-034
  
  _Labels:_ `ai,security`

- [ ] **T-072** — Criar bot OpenAI triggerType=all
  
  Descrição: Bot ativo na instância Evolution.
CA: Mensagens roteadas ao bot.
Dep: T-071, T-057
  
  _Labels:_ `ai,bot`

- [ ] **T-073** — Implementar debounce 30–120s
  
  Descrição: Ajuste por config; testes com rajadas.
CA: Respostas agrupadas.
Dep: T-072
  
  _Labels:_ `ai,bot`

- [ ] **T-074** — Prompt base com regras do negócio
  
  Descrição: ≤10% desconto; sem prazos; handoff.
CA: Testes de prompt passam.
Dep: T-072
  
  _Labels:_ `ai,prompt`

- [ ] **T-075** — Speech-to-Text (transcrição de áudios)
  
  Descrição: Transcrever e salvar no messages.
CA: Transcrições acuradas.
Dep: T-072, T-059
  
  _Labels:_ `ai,audio`

- [ ] **T-076** — Resposta em áudio (TTS)
  
  Descrição: Geração e envio de áudio.
CA: Cliente recebe áudio + texto.
Dep: T-075, T-063
  
  _Labels:_ `ai,audio`

- [ ] **T-077** — Detecção de intenção de cancelamento
  
  Descrição: Regras/intent classifier.
CA: Casos detectados.
Dep: T-074
  
  _Labels:_ `ai,nlu`

- [ ] **T-078** — Handoff humano (pausar bot/tag conversa)
  
  Descrição: Flag de status + notificação interna.
CA: Handoff acionado.
Dep: T-077
  
  _Labels:_ `ai,ops`

- [ ] **T-079** — Injeção RAG (top-k) no prompt
  
  Descrição: Contexto do catálogo/políticas/conversas.
CA: Acurácia melhora.
Dep: T-055, T-074
  
  _Labels:_ `ai,rag`

- [ ] **T-080** — Memória curta por conversa
  
  Descrição: Buffer da janela recente.
CA: Preserva contexto local.
Dep: T-072
  
  _Labels:_ `ai,context`

- [ ] **T-081** — Espelhar idioma do cliente
  
  Descrição: PT-BR/EN automático.
CA: Teste PT↔EN ok.
Dep: T-074
  
  _Labels:_ `ai,ux`

- [ ] **T-082** — Controle de custo (tokens)
  
  Descrição: Limites, truncamento e logs de custo.
CA: Orçamento respeitado.
Dep: T-072
  
  _Labels:_ `ai,costs`

- [ ] **T-083** — Testes A/B de mensagens-chave
  
  Descrição: Rotas /ab/assign e /ab/report.
CA: Experimentos registrados.
Dep: T-074
  
  _Labels:_ `ai,experiments`

- [ ] **T-084** — Heurística v1 de lead value
  
  Descrição: Prompt + SQL e pesos.
CA: Score por conversa.
Dep: T-042, T-074
  
  _Labels:_ `ai,metrics`

- [ ] **T-085** — Política de escolha da melhor resposta
  
  Descrição: Uplift em KPIs; empate → menor TTFR.
CA: Logs com decisão.
Dep: T-083, T-084
  
  _Labels:_ `ai,policy`

- [ ] **T-086** — Fallback de modelo (erro/custo/latência)
  
  Descrição: Troca automática e telemetria.
CA: Fallback testado.
Dep: T-072
  
  _Labels:_ `ai,reliability`

- [ ] **T-087** — Seed de FAQs + RAG
  
  Descrição: Respostas canônicas integradas.
CA: Cobrir top-20 perguntas.
Dep: T-052
  
  _Labels:_ `ai,content`

- [ ] **T-088** — Sanitização de PII no prompt
  
  Descrição: Remover/mascarar dados sensíveis.
CA: Check antes do LLM.
Dep: T-046
  
  _Labels:_ `ai,privacy`

- [ ] **T-089** — Testes e2e do bot (texto/áudio)
  
  Descrição: Debounce, handoff, memória.
CA: Suíte verde.
Dep: T-073,T-076,T-078
  
  _Labels:_ `tests,e2e`

- [ ] **T-090** — ADR-008: Persona e tom finais
  
  Descrição: Documentar persona e guidelines.
CA: Doc aprovado.
Dep: T-074
  
  _Labels:_ `adr,ux`

- [ ] **T-091** — Consumer MESSAGES_SET → persistir/normalizar
  
  Descrição: Idempotência e normalização de payloads.
CA: Registros consistentes.
Dep: T-062
  
  _Labels:_ `metrics,queue`

- [ ] **T-092** — Consumer MESSAGES_UPSERT → atualizar fatos
  
  Descrição: Atualizar views/fatos em tempo quase real.
CA: KPIs refletem mudanças.
Dep: T-091
  
  _Labels:_ `metrics,queue`

- [ ] **T-093** — Consumer SEND_MESSAGE → latência/status
  
  Descrição: Gravar latência de envio e status.
CA: fact_response populado.
Dep: T-063
  
  _Labels:_ `metrics,queue`

- [ ] **T-094** — Endpoint /metrics/response-rate
  
  Descrição: Retornar taxa de resposta por período.
CA: GET com parâmetros data.
Dep: T-041
  
  _Labels:_ `api,metrics`

- [ ] **T-095** — Endpoint /metrics/ttfr
  
  Descrição: Tempo até primeira resposta.
CA: GET com filtros.
Dep: T-041
  
  _Labels:_ `api,metrics`

- [ ] **T-096** — Endpoint /metrics/conversion-to-proposal
  
  Descrição: % de conversas que chegam a pedido de orçamento.
CA: GET operacional.
Dep: T-041
  
  _Labels:_ `api,metrics`

- [ ] **T-097** — Endpoint /metrics/lead-value
  
  Descrição: Valor estimado do lead (heurística v1).
CA: GET funcional.
Dep: T-042
  
  _Labels:_ `api,metrics`

- [ ] **T-098** — Filtros de métricas (datas/campanha/operador)
  
  Descrição: Query params padronizados.
CA: Filtros aplicados.
Dep: T-094,T-095,T-096,T-097
  
  _Labels:_ `api,metrics`

- [ ] **T-099** — Dashboard HTML simples
  
  Descrição: SSR de cards com 4 KPIs.
CA: Página acessível.
Dep: T-098
  
  _Labels:_ `ui,metrics`

- [ ] **T-100** — Export CSV/JSON de métricas
  
  Descrição: ?format=csv|json.
CA: Arquivo baixável.
Dep: T-098
  
  _Labels:_ `api,metrics`

- [ ] **T-101** — Alertas (TTFR > N) via webhook
  
  Descrição: Gatilho para canal interno.
CA: POST enviado.
Dep: T-095
  
  _Labels:_ `alerts,metrics`

- [ ] **T-102** — Série temporal de KPIs
  
  Descrição: groupBy=hour|day|week.
CA: Agregações corretas.
Dep: T-098
  
  _Labels:_ `api,metrics`

- [ ] **T-103** — Endpoints /health e /version
  
  Descrição: Saúde e info da release.
CA: GETs funcionam.
Dep: T-016
  
  _Labels:_ `api,infra`

- [ ] **T-104** — Paginação e limites nos endpoints
  
  Descrição: limit/offset com caps.
CA: Proteção contra abuso.
Dep: T-098
  
  _Labels:_ `api,security`

- [ ] **T-105** — Cache de métricas quentes (Redis)
  
  Descrição: Cache com invalidação simples.
CA: Hit-rate registrado.
Dep: T-098
  
  _Labels:_ `api,cache`

- [ ] **T-106** — Documentar API (OpenAPI/Swagger)
  
  Descrição: Servir /docs com schema.
CA: Documentação navegável.
Dep: T-094..T-105
  
  _Labels:_ `docs,api`

- [ ] **T-107** — Teste de carga de métricas
  
  Descrição: P95/P99 e throughput.
CA: Relatório com metas.
Dep: T-106
  
  _Labels:_ `performance,tests`

- [ ] **T-108** — ADR-009: Eventos de conversão (final)
  
  Descrição: Formalizar definição final.
CA: ADR fechado.
Dep: T-096
  
  _Labels:_ `adr,metrics`

- [ ] **T-109** — Auditoria de consistência (mensagens ↔ fatos)
  
  Descrição: Reconciliação e relatório.
CA: Diferenças tratadas.
Dep: T-093
  
  _Labels:_ `metrics,quality`

- [ ] **T-110** — Job noturno: recalcular agregados
  
  Descrição: Locks e janela de processamento.
CA: Execução idempotente.
Dep: T-098
  
  _Labels:_ `metrics,automation`

- [ ] **T-111** — Abstração de HTTP clientes
  
  Descrição: Retries, timeouts, circuit breaker.
CA: Wrapper reutilizável.
Dep: T-017
  
  _Labels:_ `integrations,http`

- [ ] **T-112** — Webhook CRM: criar lead
  
  Descrição: POST /integrations/crm/leads.
CA: Payload validado.
Dep: T-111
  
  _Labels:_ `integrations,crm`

- [ ] **T-113** — Webhook ERP: consultar estoque/preço
  
  Descrição: Endpoint + mapeamento de produtos.
CA: Respostas normalizadas.
Dep: T-111
  
  _Labels:_ `integrations,erp`

- [ ] **T-114** — Conector planilha/campanhas (CSV)
  
  Descrição: Importar campanhas.
CA: CSV parseado.
Dep: T-111
  
  _Labels:_ `integrations,campaigns`

- [ ] **T-115** — Roteamento intents → ações (CRM/ERP)
  
  Descrição: Tabela de mapeamento intent→ação.
CA: Ações disparadas.
Dep: T-112, T-113
  
  _Labels:_ `integrations,ai`

- [ ] **T-116** — Assinatura HMAC em integrações
  
  Descrição: Validar X-Signature.
CA: Requisições inválidas rejeitadas.
Dep: T-111
  
  _Labels:_ `security,integrations`

- [ ] **T-117** — Reprocessar DLQ de integrações
  
  Descrição: CLI `replay dlq`.
CA: Eventos reencaminhados.
Dep: T-029
  
  _Labels:_ `integrations,reliability`

- [ ] **T-118** — Observabilidade por integração
  
  Descrição: Latência/erros por destino.
CA: Métricas expostas.
Dep: T-111
  
  _Labels:_ `integrations,observability`

- [ ] **T-119** — Testes e2e de integrações
  
  Descrição: Mocks e suíte verde.
CA: Fluxos cobertos.
Dep: T-112..T-118
  
  _Labels:_ `integrations,tests`

- [ ] **T-120** — ADR-010: SLA e degradação por integração
  
  Descrição: Fallback/limites por parceiro.
CA: ADR aprovado.
Dep: T-111
  
  _Labels:_ `adr,integrations`

- [ ] **T-121** — Catálogo de erros padronizados
  
  Descrição: Enumerar e documentar erros.
CA: Reúso cross-service.
Dep: T-111
  
  _Labels:_ `integrations,quality`

- [ ] **T-122** — Quarentena de eventos suspeitos
  
  Descrição: Fila separada para revisão humana.
CA: Fluxo de liberação.
Dep: T-111
  
  _Labels:_ `integrations,security`

- [ ] **T-123** — Rate limit por integração
  
  Descrição: Throttling configurável por destino.
CA: Testado.
Dep: T-118
  
  _Labels:_ `integrations,security`

- [ ] **T-124** — Alertas por integração (thresholds)
  
  Descrição: Webhooks/Slack com thresholds.
CA: Alerta emitido.
Dep: T-118
  
  _Labels:_ `integrations,alerts`

- [ ] **T-125** — Documentar integrações (diagramas)
  
  Descrição: /docs/integrations.md com diagramas.
CA: Documentação pronta.
Dep: T-119
  
  _Labels:_ `docs,integrations`

- [ ] **T-126** — Configurar linters/formatadores
  
  Descrição: prettier/eslint/black/ruff (conforme stack).
CA: Rodando no CI.
Dep: T-001
  
  _Labels:_ `ci,quality`

- [ ] **T-127** — Testes unitários mínimos
  
  Descrição: Cobrir funções core.
CA: Cobertura básica.
Dep: T-036
  
  _Labels:_ `tests,quality`

- [ ] **T-128** — Testes e2e (WhatsApp → métricas)
  
  Descrição: Fluxo fim-a-fim automatizado.
CA: make e2e verde.
Dep: T-070, T-099
  
  _Labels:_ `tests,e2e`

- [ ] **T-129** — GitHub Actions: build + testes
  
  Descrição: Workflow ci.yml.
CA: PRs executam CI.
Dep: T-126
  
  _Labels:_ `ci,automation`

- [ ] **T-130** — GitHub Actions: lint + SAST
  
  Descrição: security.yml com scanners.
CA: Falhas críticas bloqueiam PR.
Dep: T-126
  
  _Labels:_ `ci,security`

- [ ] **T-131** — Política de branches e reviews
  
  Descrição: Regras de proteção e reviews.
CA: 2 olhos por PR.
Dep: T-001
  
  _Labels:_ `repo,process`

- [ ] **T-132** — Pre-commit hooks
  
  Descrição: Lints/secrets antes do commit.
CA: Pre-commit ativo.
Dep: T-126
  
  _Labels:_ `repo,quality`

- [ ] **T-133** — Scanner de segredos (gitleaks/trufflehog)
  
  Descrição: Bloquear vazamentos.
CA: CI falha se detectar.
Dep: T-126
  
  _Labels:_ `security,ci`

- [ ] **T-134** — Dependabot/Renovate
  
  Descrição: PRs automáticos de dependências.
CA: Bot ativo.
Dep: T-001
  
  _Labels:_ `ci,maintenance`

- [ ] **T-135** — Logs estruturados (JSON)
  
  Descrição: Correlação por conversation_id.
CA: Log com trace.
Dep: T-062
  
  _Labels:_ `observability,logs`

- [ ] **T-136** — Expor métricas estilo Prometheus
  
  Descrição: Endpoint /metrics com contadores/histogramas.
CA: Métricas disponíveis.
Dep: T-103
  
  _Labels:_ `observability,metrics`

- [ ] **T-137** — Alertas de saúde dos serviços
  
  Descrição: Checks e notificações.
CA: Alertas emitidos.
Dep: T-136
  
  _Labels:_ `observability,alerts`

- [ ] **T-138** — Rotação e retenção de logs
  
  Descrição: Política e configuração.
CA: Logs girando e retendo.
Dep: T-136
  
  _Labels:_ `observability,logs`

- [ ] **T-139** — Teste de desastre (falha de um serviço)
  
  Descrição: Plano de recuperação e execução de teste.
CA: Relatório com ações.
Dep: T-016
  
  _Labels:_ `reliability,dr`

- [ ] **T-140** — Stress test (mensagens simultâneas)
  
  Descrição: Picos de tráfego sintéticos.
CA: Relatório P95/P99.
Dep: T-066
  
  _Labels:_ `performance,tests`

- [ ] **T-141** — Performance do bot (latência de resposta)
  
  Descrição: Metas vs medição; profiling.
CA: Relatório e melhorias.
Dep: T-089
  
  _Labels:_ `performance,ai`

- [ ] **T-142** — Budget guard de custo LLM
  
  Descrição: Alertar a 80% do teto.
CA: Alarme e ação.
Dep: T-082
  
  _Labels:_ `ai,costs`

- [ ] **T-143** — Política de rollbacks
  
  Descrição: Script reversível e doc.
CA: Procedimento testado.
Dep: T-129
  
  _Labels:_ `ops,ci`

- [ ] **T-144** — Authn/Z por role nos endpoints
  
  Descrição: Regras de acesso por papel.
CA: Testes positivos/negativos.
Dep: T-103
  
  _Labels:_ `security,api`

- [ ] **T-145** — Pentest básico (OWASP top 10)
  
  Descrição: Checklist e fixes críticos.
CA: Relatório com ações.
Dep: T-144
  
  _Labels:_ `security,tests`

- [ ] **T-146** — Política de privacidade e termos (rascunho)
  
  Descrição: /docs/policy.md.
CA: Documento publicado.
Dep: T-011
  
  _Labels:_ `legal,privacy`

- [ ] **T-147** — Onboarding stakeholders (README + GIFs)
  
  Descrição: 3 GIFs e passo-a-passo.
CA: Material entregue.
Dep: T-099
  
  _Labels:_ `docs,enablement`

- [ ] **T-148** — Release v0.1.0 (tag + changelog)
  
  Descrição: Gerar CHANGELOG e tag.
CA: Release criada.
Dep: T-129
  
  _Labels:_ `release,ops`

- [ ] **T-149** — Plano de piloto (número teste → oficial)
  
  Descrição: Critérios de promoção e reversão.
CA: Plano publicado.
Dep: T-014
  
  _Labels:_ `planning,ops`

- [ ] **T-150** — Retrospectiva do MVP + backlog de melhorias
  
  Descrição: Lições, riscos e próximos passos.
CA: Lista priorizada.
Dep: T-148, T-149
  
  _Labels:_ `planning,process`
