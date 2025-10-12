# ADR-20251012: Estratégia de Armazenamento Vetorial para RAG

- **Status**: Accepted
- **Context Timestamp**: 2025-10-12

## Context
O MVP precisa usar RAG para enriquecer respostas do bot OpenAI com base em catálogo, políticas e 3 meses de conversas anteriores. Já teremos PostgreSQL para persistência operacional. Precisamos de um repositório vetorial confiável, com custo acessível, que suporte embeddings diários e consultas de baixa latência para compor prompts. O backlog requer idempotência, versionamento de índices e facilidade de manutenção.

## Decision Drivers
- **Integração com stack existente**: reutilizar infraestrutura sempre que possível.
- **Custo total**: evitar serviços pagos adicionais enquanto o volume for pequeno.
- **Latência de busca**: garantir respostas rápidas para não penalizar TTFR.
- **Operação simplificada**: manter equipe focada em funcionalidades core.

## Considered Options
1. **PostgreSQL + extensão `pgvector` (mesmo cluster do operacional)**  
   - Prós: uma única fonte de dados, transações ACID, backup integrado, curva de aprendizado baixa.  
   - Contras: tuning necessário para índices vetoriais, pode disputar recursos com workload OLTP se não houver otimização.  
   - Impacto: custo ~zero adicional, latência aceitável (ms a dezenas de ms), manutenção média (instalar extensão e gerenciar índices).
2. **Serviço vetorial gerenciado (Pinecone, Weaviate Cloud, etc.)**  
   - Prós: latência otimizada, escalabilidade automática, ferramentas de monitoramento.  
   - Contras: custo recorrente imediato, dependência externa, integrações extra (networking/segurança).  
   - Impacto: custo médio/alto, latência muito baixa, manutenção baixa mas com contratos/SLA.
3. **Redis com módulo RediSearch/VSS**  
   - Prós: já teremos Redis; boa performance em RAM, comandos simples.  
   - Contras: requer habilitar módulos adicionais, risco de perda de dados se não houver persistência, consumo elevado de memória.  
   - Impacto: custo baixo/médio (maior RAM), latência baixa, manutenção média (configuração de módulos, snapshotting).

## Decision
Adotar **PostgreSQL com `pgvector`** no mesmo cluster usado pela Evolution API. Instalar a extensão via migração inicial, criar tabela específica (`knowledge_chunks`) com versão e metadados (fonte, confiança, idioma). Isso mantém custos quase nulos, centraliza backups e permite consultas transacionais combinando dados relacionais e vetoriais. Tuning (ex.: `ivfflat`, `lists`, `ANALYZE`) será aplicado conforme o volume crescer.

## Consequences
- ✅ Sem custo de infraestrutura adicional; backup unificado.  
- ✅ Mantém consistência e permite auditoria completa (linha do tempo do conhecimento).  
- ⚠️ Necessário monitorar impacto de workload vetorial no Postgres; pode demandar separação futura.  
- ⚠️ Escalabilidade limitada se vetor store crescer muito; precisamos de métricas de tamanho/latência.

## Follow-up
- [ ] Incluir migração que habilita `pgvector` e cria tabelas/índices vetoriais iniciais.  
- [ ] Definir job de manutenção (`VACUUM`, `REINDEX`, `ANALYZE`) específico para a tabela de embeddings.  
- [ ] Revisitar decisão quando chegarmos a >1 milhão de chunks ou quando latência ultrapassar 150 ms em média.

