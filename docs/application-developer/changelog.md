# IA Activity Changelog

Use este documento para consolidar entregas por período. Cada entrada deve linkar para o arquivo `<timestamp>-ia-code.md` correspondente.

## 2025-05
- Adicionada licença MIT ao repositório — [1760268592-ia-code.md](1760268592-ia-code.md)
- Ampliado `.gitignore` para cobrir artefatos sensíveis de credenciais — [1760268860-ia-code.md](1760268860-ia-code.md)
- Habilitados templates de Issue/PR e versionamento de `.github/` — [1760269187-ia-code.md](1760269187-ia-code.md)
- ADR-000 documenta arquitetura geral do MVP — [1760269685-ia-code.md](1760269685-ia-code.md)
- ADR-001 define política de segredos — [1760270176-ia-code.md](1760270176-ia-code.md)
- ADR-002 define estratégia de RAG — [1760270378-ia-code.md](1760270378-ia-code.md)
- ADR-003 define métrica-norte e eventos de conversão — [1760271409-ia-code.md](1760271409-ia-code.md)
- ADR-004 define estratégia de debounce — [1760277510-ia-code.md](1760277510-ia-code.md)
- ADR-005 define política de retenção e anonimização — [1760285497-ia-code.md](1760285497-ia-code.md)
- Criado guia de contribuição — [1760285658-ia-code.md](1760285658-ia-code.md)
- Definidas convenções de nomenclatura — [1760286707-ia-code.md](1760286707-ia-code.md)
- Roadmap MVP → Piloto → Produção documentado — [1760286974-ia-code.md](1760286974-ia-code.md)
- Configuração do board Kanban no GitHub Projects — [1760287092-ia-code.md](1760287092-ia-code.md)
- Migração bootstrap de role e banco no Postgres — [1760287092-ia-code.md](1760287092-ia-code.md)
- Scripts de backup/restore do Postgres — [1760287801-ia-code.md](1760287801-ia-code.md)
- Redis configurado como cache-only — [1760288050-ia-code.md](1760288050-ia-code.md)
- DLQ configurado no RabbitMQ — [1760288183-ia-code.md](1760288183-ia-code.md)
- Perfis dev/prod no docker-compose — [1760288357-ia-code.md](1760288357-ia-code.md)
- Script wait-for para dependências — [1760288465-ia-code.md](1760288465-ia-code.md)
- Lista de GitHub Secrets — [1760288586-ia-code.md](1760288586-ia-code.md)
- ADR-006 estimativa de custos — [1760288660-ia-code.md](1760288660-ia-code.md)
- Migração base de contacts/chats/messages/history — [1760288751-ia-code.md](1760288751-ia-code.md)
- Tabelas de fatos de conversa/resposta/lead — [1760288851-ia-code.md](1760288851-ia-code.md)
- Tabela event_log para idempotência — [1760288960-ia-code.md](1760288960-ia-code.md)
- Tabela bot_config para parâmetros do bot — [1760289033-ia-code.md](1760289033-ia-code.md)
- Índices de performance (phone/conversation/created_at) — [1760289111-ia-code.md](1760289111-ia-code.md)
- Views de métricas (response-rate, TTFR, conversão) — [1760289215-ia-code.md](1760289215-ia-code.md)
- Função SQL de valor estimado do lead — [1760289306-ia-code.md](1760289306-ia-code.md)
- Flags `DATABASE_SAVE_DATA_*` documentadas — [1760289510-ia-code.md](1760289510-ia-code.md)
- Seed de catálogo de produtos (mock) — [1760289605-ia-code.md](1760289605-ia-code.md)
- Tabela audit_retention (política) — [1760289717-ia-code.md](1760289717-ia-code.md)
- Job de anonimização PII — [1760289822-ia-code.md](1760289822-ia-code.md)
- Job de limpeza hard-delete — [1760289956-ia-code.md](1760289956-ia-code.md)
- Testes SQL de integridade dos fatos — [1760290109-ia-code.md](1760290109-ia-code.md)
- Dicionário de dados — [1760290239-ia-code.md](1760290239-ia-code.md)
- ADR-007 pgvector vs serviço vetorial — [1760290496-ia-code.md](1760290496-ia-code.md)
- Esquema RAG (sources/documents/embeddings) — [1760290707-ia-code.md](1760290707-ia-code.md)
- CLI de ingestão RAG — [1760290829-ia-code.md](1760290829-ia-code.md)
- Versionamento de documentos RAG — [1760290998-ia-code.md](1760290998-ia-code.md)

## Como atualizar
1. Adicione uma nova seção mensal (`## AAAA-MM`) quando iniciar atividades no período.
2. Liste cada entrega no formato `- <breve descrição> — [timestamp-ia-code.md](timestamp-ia-code.md)`.
3. Inclua observações sobre revisões humanas ou ajustes pós-merge quando aplicável.
