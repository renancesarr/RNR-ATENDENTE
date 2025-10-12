# Guia de Contribuição

Este repositório sustenta o MVP de atendimento via Evolution API + OpenAI. Siga estas orientações para garantir entregas consistentes, auditáveis e alinhadas às decisões já tomadas.

## Pré-requisitos
- Node.js 20+, Docker/Docker Compose e `make` instalados.
- Copie `.env.example` para `.env` e preencha as variáveis obrigatórias (nunca versione segredos).
- Leia os ADRs em `docs/decisions/` e os papéis em `docs/*/` (project manager, solution architect, etc.) antes de alterar o escopo.

## Fluxo de trabalho
1. **Issue/Task**: escolha itens do backlog em `docs/project-manager/github_issues_backlog_T001-T150.md`. Respeite dependências marcadas como `Dep`.
2. **Branching**: crie branches a partir de `main` usando o padrão `feature/<id-da-task>-descricao-curta` ou `fix/...`.
3. **Commits**: mensagens no formato `<tipo>: <resumo>` (ex.: `feat: add session bootstrap endpoint`). Evite commits com arquivos não relacionados.
4. **Pull Requests**:
   - Use o template `.github/PULL_REQUEST_TEMPLATE.md`.
   - Vincule a issue ou tarefa (`Closes T-0XX`).
   - Liste testes executados e atualizações de documentação.

## Qualidade de código
- Siga as convenções definidas no README e futuros padrões em `docs/standards.md`.
- Inclua testes automatizados sempre que possível (unit, integração, E2E). Utilize `npm run test`, `pytest`, etc., conforme o módulo tocado.
- Rode linters/formatters (`npm run lint`, `black`, `ruff`, etc.) antes de abrir PR.
- Não force push em branches compartilhadas sem alinhamento prévio.

## Documentação e ADRs
- Atualize ADRs existentes ou crie novos em `docs/decisions/` quando a mudança alterar arquitetura, processos ou segurança. Use o template `ADR-YYYYMMDD-template.md`.
- Atualize `README.md`, `docs/application-developer/changelog.md` e outros guias relevantes quando novas funcionalidades ou fluxos forem introduzidos.
- Inteligências artificiais devem cumprir o fluxo descrito em `docs/application-developer/` (pre-flight, relatórios e changelog por timestamp).

## Segurança e segredos
- Nunca versione arquivos `.env`, credenciais ou chaves privadas. O `.gitignore` já cobre diretórios sensíveis; revise antes de subir novos arquivos.
- Use HashiCorp Vault (ADR-001) ou GitHub Secrets para distribuir segredos. Compartilhamentos temporários devem ocorrer apenas em canais criptografados aprovados.
- Ao manipular dados com PII, respeite a política de retenção/anonimização definida no ADR-005.

## Execução local
- Suba os serviços com `docker compose up -d`.
- Monitore logs via `docker compose logs -f evolution-api postgres redis rabbitmq`.
- Utilize scripts utilitários em `tools/` (ex.: `tools/validate-ia-change.sh`) para verificar requisitos antes de abrir PR.

## Revisões e aprovação
- Solicite reviewers alinhados ao domínio (aplicação, arquitetura, product).
- Responda comentários com clareza e aplique alterações complementares via commits adicionais (evite amend em commits já revisados).
- Atualize o backlog/projetos (GitHub Projects) ao finalizar uma entrega.

## Comunicação
- Registre decisões relevantes em ADRs ou nos diretórios por papel.
- Em caso de impedimentos, documente em `docs/scrum-master/`.
- Para novos fluxos ou automações, abra primeiro uma issue discutindo escopo, riscos e impacto em custos.
