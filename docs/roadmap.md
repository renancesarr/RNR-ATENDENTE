# Roadmap de Releases — MVP → Piloto → Produção

Este documento guia a evolução do chatbot de atendimento com Evolution API e OpenAI. Cada fase descreve objetivos, entregáveis mínimos, critérios de promoção e métricas de sucesso.

## Fase 1 — MVP Interno
- **Objetivo**: validar fluxo automatizado de atendimento e geração de pedidos de orçamento em ambiente controlado.
- **Escopo mínimo**:
  - Infraestrutura containerizada via Docker Compose (`docker-compose.yml`), seguindo ADR-000/004.
  - Persistência Postgres/pgvector com migrações iniciais e política de retenção (ADR-002/005).
  - Orquestrador com debounce adaptativo, RAG e integração básica com Evolution API.
  - Métricas essenciais (TTFR, pedidos qualificados) registradas em RabbitMQ + Postgres (ADR-003).
  - Guia de contribuição e padrões de nomenclatura (`CONTRIBUTING.md`, `docs/standards.md`).
- **Critérios de promoção**:
  - TTFR médio ≤ 3 s em 50 conversas internas.
  - Pelo menos 10 pedidos de orçamento qualificados gerados pela IA (com revisão humana).
  - Incidentes críticos (P0) = 0; backlog de bugs bloqueantes vazio.
  - Rotina de anonimização/retention validada em ambiente dev.
- **Métricas de monitoramento**:
  - `debounce_overrides_total`, `rag_latency_ms_p95`, `ttfr_seconds_p95`.
  - Custo mensal OpenAI ≤ USD 150.

## Fase 2 — Piloto Controlado
- **Objetivo**: testar com um grupo reduzido de clientes reais (até 10 leads ativos) monitorando receita e satisfação.
- **Pré-requisitos**:
  - Scripts de bootstrap e runbooks operacionais publicados (`docs/solution-architect/`).
  - Vault provisionado com AppRoles e rotinas de rotação (ADR-001).
  - Consumidores `insights-kpi` e `rag-ingestor` rodando com DLQ e alertas básicos.
  - Dashboard inicial (Grafana/Metabase) para métricas de conversão e TTFR.
- **Critérios de promoção**:
  - ≥ 30 pedidos de orçamento qualificados no mês com taxa de conversão ≥ 25%.
  - TTFR p95 ≤ 5 s; satisfação média ≥ 4/5 em survey rápido.
  - Nenhum incidente crítico não resolvido em ≤ 4 h.
  - Playbook de suporte 24×7 documentado (`docs/scrum-master/`).
- **Métricas adicionais**:
  - NPS ou CSAT por conversa.
  - Custo por lead atendido versus baseline manual.

## Fase 3 — Produção Ampliada
- **Objetivo**: escalar para toda a carteira de leads, garantindo alta disponibilidade e governança.
- **Pré-requisitos**:
  - Observabilidade completa (logs estruturados, métricas, tracing) com alertas.
  - Estratégia de backup/restauração testada (Postgres, Vault, anexos).
  - Pipeline CI/CD com validações automáticas (lint, testes, IA Guard) e checklist de deploy.
  - Revisão legal/compliance concluída para retenção, consentimento e LGPD.
- **Critérios de promoção**:
  - Disponibilidade ≥ 99% no piloto por 60 dias.
  - Recuperação de desastre validada (RPO ≤ 15 min, RTO ≤ 2 h).
  - Previsão de custos e budget aprovados (infra + OpenAI + manutenção).
  - Aprovação das áreas de vendas, suporte e jurídico.
- **Métricas contínuas**:
  - Receita incremental gerada pelo canal.
  - Precisão do classificador de intenção de orçamento ≥ 92%.
  - Latência média de respostas OpenAI ≤ 1.5 s.

## Gestão de Releases
- **Cadência**: revisar roadmap mensalmente em conjunto com Project Manager e Solution Architect.
- **Backlog**: cada entrega deve mapear para tarefas no `github_issues_backlog_T001-T150` ou issues novas.
- **Change Management**: alterações major devem gerar ADRs adicionais; atualize este roadmap quando marcos mudarem.
- **Checklist de promoção**: documentar em `docs/scrum-master/` os resultados de cada fase, incluindo lições aprendidas e ajustes.
