# ADR-20251012: Estratégia de Observabilidade para o MVP

- **Status**: Accepted
- **Context Timestamp**: 2025-10-12

## Context
O MVP precisa oferecer logs estruturados, métricas HTTP simples e registrar decisões operacionais. Os requisitos incluem monitorar TTFR, taxa de resposta, consumo de tokens OpenAI e saúde das filas RabbitMQ, mantendo custos enxutos. Ainda não temos stack de observabilidade existente nem orçamento para SaaS completo.

## Decision Drivers
- **Visibilidade rápida**: precisamos de indicadores básicos desde o primeiro deploy.
- **Custo reduzido**: evitar ferramentas pagas até validar o produto.
- **Facilidade de implementação**: equipe enxuta, foco em funcionalidades core.
- **Evolução futura**: permitir expansão para uma stack mais robusta sem rework total.

## Considered Options
1. **Stack leve: logs estruturados + endpoints HTTP de métricas + dashboards simples (ex.: JSON + Grafana Lite futuramente)**  
   - Prós: implementação imediata, sem dependências externas, alinhado ao backlog (endpoints `/metrics/*`).  
   - Contras: dashboards limitados, alertas manuais, escalabilidade básica.  
   - Impacto: custo praticamente nulo, latência irrelevante, manutenção baixa.
2. **Prometheus + Grafana auto-hospedados desde o início**  
   - Prós: métricas ricas, alerting, visualização avançada.  
   - Contras: setup mais demorado, consumo adicional de recursos, necessidade de manutenção contínua.  
   - Impacto: custo médio (infra + tempo), latência baixa, manutenção média/alta.
3. **SaaS completo (Datadog, New Relic, etc.)**  
   - Prós: funcionalidades avançadas, alertas prontos, suporte.  
   - Contras: custo elevado logo no MVP, dependência externa, possível restrição de dados sensíveis.  
   - Impacto: custo alto, latência baixa, manutenção baixa mas com contratos/licenças.

## Decision
Implementar **stack leve com logs estruturados (JSON) e endpoints de métricas HTTP** no próprio serviço de backend. As métricas solicitadas (response-rate, conversion-to-proposal, lead-value, ttfr) serão expostas via REST e enriquecidas com dados do PostgreSQL/Redis. Logs terão campos de correlação (`conversation_id`, `message_id`) e serão integrados à fila de eventos. Documentaremos como conectar futuramente a Prometheus/Grafana caso surjam necessidades avançadas.

## Consequences
- ✅ Entregamos visibilidade mínima rapidamente e cumprimos requisito do backlog.  
- ✅ Sem custos adicionais; fácil de rodar em ambientes locais e CI.  
- ⚠️ Alertas manuais; risco de reagir tardiamente a incidentes até adicionar ferramenta mais robusta.  
- ⚠️ Necessário planejar evolução para Prometheus/Grafana ou SaaS conforme a equipe cresce.

## Follow-up
- [ ] Definir formato de log estruturado e centralizá-lo em documento `docs/observability/log-format.md`.  
- [ ] Criar endpoints `/metrics/*` e testes cobrindo cálculo dos KPIs.  
- [ ] Avaliar integração com Prometheus quando volume de conversas justificar alertas automáticos.

