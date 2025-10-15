# Impedimentos — Política de Retenção e Anonimização

Situação atual: o MVP permanece em caráter experimental e não possui obrigação legal imediata de anonimização ou deleção automática. Entretanto, os jobs já implementados (`fn_apply_retention_scrub`, `fn_apply_retention_purge`) dependem de validações humanas antes de serem ativados.

## Bloqueios identificados

1. **Ausência de diretriz jurídica aprovada**
   - O ADR-005 apresenta proposta preliminar (retention quente/frio), mas falta validação do departamento jurídico.
   - Sem essa sinalização, as execuções automáticas podem violar políticas internas ou requisitos específicos do país.

2. **Parâmetros operacionais indefinidos**
   - `audit_retention` ainda não recebeu valores definitivos (`scrub_after_days`, `delete_after_months`, exceções por escopo).
   - Executar os jobs com placeholders coloca em risco métricas e investigações futuras.

3. **Processo humano não estabelecido**
   - Não há checklist sobre quem autoriza rodar `apply-retention.sh` / `purge-retention.sh`, nem como registrar cada execução.
   - Falta canal de comunicação para avisar stakeholders (dados, atendimento, produto) antes e depois das execuções.

## Exemplos de ações para discussão

- **Workshop jurídico-produto**  
  - Objetivo: entender obrigações reais para MVP experimental.  
  - Resultado esperado: documento com faixas de retenção aceitáveis, exceções e requisitos de auditoria.

- **Definição de Owner operacional**  
  - Escolher responsável humano (ex.: Data Lead) para manter `audit_retention` atualizado e aprovar execuções.  
  - Criar playbook com passos: rodar dry-run, revisar contagens, aprovar/negado, agendar próxima rodada.

- **Fluxo de comunicação e logging**  
  - Configurar canal (Slack/Email) para publicar relatório das execuções e manter histórico em `audit_retention_log` (quando criado).  
  - Garantir que bloqueios sejam visíveis no board Kanban com tag `blocked-retention`.

- **Critérios para sair do modo experimental**  
  - Mapear sinais de maturidade (ex.: onboarding de clientes reais, revisão de políticas internas).  
  - Assim que um critério for atingido, reavaliar prioridade do backlog futuro e acionar jurídico automaticamente.

- **Plano de mitigação de risco**  
  - Documentar procedimentos caso execuções erradas removam dados necessários (backup, restore, comunicação com times).  
  - Avaliar custo de manter dados brutos por mais tempo versus esforço de anonimizar sem diretriz.

## Próximos passos sugeridos

- Registrar este impedimento na daily/kanban como dependência de decisão humana.
- Agendar reunião com jurídico e segurança da informação para tratar os pontos acima.
- Atualizar este arquivo após cada decisão ou movimento relevante; manter histórico datado das conclusões.
