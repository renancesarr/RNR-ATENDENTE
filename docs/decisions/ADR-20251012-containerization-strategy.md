# ADR-20251012: Estratégia de Contêinerização para o MVP

- **Status**: Accepted
- **Context Timestamp**: 2025-10-12

## Context
A plataforma de atendimento via WhatsApp precisa iniciar como um MVP com entrega rápida, envolvendo Evolution API v2, PostgreSQL, Redis, RabbitMQ, Typebot opcional e integrações com OpenAI. O artigo de referência e o backlog determinam o uso de Docker Compose com volumes persistentes, healthchecks obrigatórios e serviços auxiliares (Watchtower/Autoheal). Também precisamos manter custos baixos, minimizar complexidade operacional e garantir que TTFR e disponibilidade básica não sejam prejudicados.

## Decision Drivers
- **Velocidade de implementação**: precisamos colocar o stack no ar em 1–2 dias.
- **Custo operacional**: focar em infraestrutura de baixo custo até validar o funil.
- **Manutenibilidade**: permitir ajustes rápidos (composição/volumes) sem equipe DevOps dedicada.
- **Escalabilidade razoável**: manter caminho claro para expansão futura sem reescrever tudo.

## Considered Options
1. **Docker Compose em host único (volumes persistentes)**  
   - Prós: setup rápido, menor custo, alinhado à documentação do PDF, fácil debug local.  
   - Contras: sem auto-escalonamento, pontos únicos de falha, gestão manual de atualizações.  
   - Impacto: custo baixo (apenas host), latência mínima (serviços co-localizados), manutenção simples para MVP.
2. **Orquestração Kubernetes (K3s/EKS/GKE)**  
   - Prós: escalabilidade e resiliência elevadas, auto-healing nativo, upgrades controlados.  
   - Contras: alto tempo de setup, curva de aprendizado, custos maiores (control plane + nodes), exige DevOps.  
   - Impacto: custo alto, latência similar, manutenção complexa para MVP.
3. **Serviços Gerenciados + Evolution Cloud (SaaS)**  
   - Prós: delega gestão da API, SLAs de uptime, menor responsabilidade operacional.  
   - Contras: dependência de terceiros, custo recorrente, menos controle sobre integrações/customizações e eventos RabbitMQ.  
   - Impacto: custo médio/alto, latência dependente do provedor, manutenção baixa mas com menor flexibilidade.

## Decision
Adotar **Docker Compose em host único** para o MVP, alinhando-se à referência do PDF e possibilitando entrega imediata. A proximidade dos serviços reduz latência, simplifica troubleshooting e mantém investimentos enxutos. Registraremos práticas para migração futura (ex.: separar bancos em managed services) caso o volume ou necessidades de SLA justifiquem.

## Consequences
- ✅ Implantação rápida com infraestrutura conhecida pela equipe.  
- ✅ Facilita testes end-to-end e seeds locais dentro do Compose.  
- ⚠️ Single point of failure; mitigaremos com backups, volumes persistentes e monitoramento básico.  
- ⚠️ Escalabilidade limitada; precisaremos planejar migração para Kubernetes ou serviços gerenciados quando a base de usuários crescer.

## Follow-up
- [ ] Definir política de backup/restauração dos volumes nomeados (Postgres, Redis dumps, instâncias WhatsApp).  
- [ ] Avaliar requisitos de SLA após o primeiro ciclo de vendas para decidir sobre migração para ambiente distribuído.  
- [ ] Documentar pré-requisitos do host (CPU/RAM/armazenamento) no README operacional.

