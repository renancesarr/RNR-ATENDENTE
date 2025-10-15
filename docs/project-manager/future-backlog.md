# Backlog Futuro — Retenção e Compliance

Rastreia itens adiados do MVP relacionados a políticas de retenção, anonimização e governança legal. Use este documento para sincronizar próximo ciclo com jurídico, segurança e produto.

- **Revisão jurídica da política de retenção**  
  - Validar premissas do ADR-005 com o departamento jurídico (períodos quente/frio, exceções, LGPD).  
  - Levantar obrigações específicas do país/segmento que possam alterar os parâmetros padrões.  
  - Entregar artefato formal (memorando ou parecer) com aprovação ou ajustes sugeridos.

- **Definição dos parâmetros operacionais**  
  - Consolidar valores definitivos para `scrub_after_days`, `delete_after_months` e exceções por escopo.  
  - Registrar configuração alvo em `audit_retention` apenas após aprovação humana; manter histórico de decisões.

- **Processo de aprovação e auditoria**  
  - Desenhar fluxo humano para autorizar execuções dos jobs (`fn_apply_retention_scrub`, `fn_apply_retention_purge`).  
  - Definir responsáveis por acionar dry-run, analisar relatórios e liberar execução definitiva.  
  - Planejar criação da tabela `audit_retention_log` e relatório periódico de conformidade.

- **Comunicação e alinhamento organizacional**  
  - Preparar briefing para stakeholders (produto, atendimento, dados) explicando impactos de retenção.  
  - Garantir que o board Kanban e as issues correspondentes apontem dependência de decisão humana.  
  - Sinalizar quando o MVP sair do modo experimental para reavaliar prioridade dessas entregas.

- **Gestão de risco técnico**  
  - Mapear impactos de manter dados brutos além da janela prevista (custos, privacidade, incidentes).  
  - Criar plano de rollback caso anonimização/purge gere perda de informação crítica.  
  - Estabelecer monitoramento mínimo (alertas, métricas) a ser ativado quando jobs forem oficializados.
