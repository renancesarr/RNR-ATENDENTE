# Kanban — GitHub Projects Configuration

Use este guia para criar e manter o board Kanban no GitHub Projects, garantindo rastreabilidade do backlog T-001 a T-150.

## Estrutura do Board
- **Nome do projeto**: `Chatbot Evolution API — Kanban`.
- **Tipo**: GitHub Projects (beta) ou clássico, conforme disponibilidade da organização.
- **Colunas padrão**:
  1. `To Do` — itens ainda não iniciados; preencha com issues/tarefas pendentes.
  2. `Doing` — trabalho em andamento (limite recomendado: 5 itens para manter foco).
  3. `Review` — PRs abertos ou workitems esperando validação/revisão técnica.
  4. `Done` — entregas concluídas e mergeadas.

## Cartões e Labels
- Cada cartão deve referenciar uma issue/tarefa (ex.: `T-012 — Criar CONTRIBUTING.md`).
- Utilize labels principais existentes (`planning`, `docs`, `adr`, `security`, etc.) para facilitar filtros.
- Quando usar automações, configure:
  - `To Do` → `Doing`: mover quando issue for atribuída ou tiver branch associado.
  - `Doing` → `Review`: mover quando PR vinculado estiver aberto.
  - `Review` → `Done`: mover após merge/close.

## Regras e Boas Práticas
- **WIP Limit**: manter no máximo 5 itens em `Doing` e 5 em `Review`; sinalize no board quando exceder.
- **Daily Update**: atualizar status durante as dailies; comentar bloqueios diretamente na issue/card.
- **Checkpoints**: ao final de cada release (ver `docs/roadmap.md`), exportar snapshot do board para `docs/project-manager/`.
- **Integração com Backlog**: mantenha o ID da tarefa (`T-XXX`) no título do card para sincronizar com o arquivo `github_issues_backlog_T001-T150.md`.

## Processo de Configuração Inicial
1. Crie o projeto no GitHub e adicione `main` como repositório associado.
2. Adicione colunas `To Do`, `Doing`, `Review`, `Done` (nesta ordem).
3. Importe os itens T-001 a T-015 como cartões iniciais; ajuste conforme evolução.
4. Configure automações básicas:
   - Fechamento de issue move para `Done`.
   - Reabertura move de volta para `To Do`.
5. Conceda acesso de edição ao time completo (dev, PM, IA operators).

## Manutenção
- Revisar automações a cada ciclo mensal; adicionar novas colunas se surgirem etapas específicas (ex.: `Blocked`).
- Registrar mudanças de layout neste arquivo para manter histórico e praticar governança.
