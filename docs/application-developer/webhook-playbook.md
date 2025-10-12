# Webhook Playbook (IA Notifications)

Objetivo: publicar uma notificação sempre que um novo arquivo `*-ia-code.md` for adicionado, alertando revisores humanos.

## Fluxo sugerido
1. Configure um Webhook do GitHub direcionado para uma automação (por exemplo, Slack incoming webhook, Teams ou uma função serverless).
2. Filtre eventos `push` e `pull_request`.
3. No payload, verifique se o diff contém arquivos que casam com `docs/application-developer/[0-9]+-ia-code.md`.
4. Envie mensagem com:
   - Link do commit/PR.
   - Autor.
   - Lista dos relatórios IA adicionados.
   - Call to action para revisão humana.

## Implementação de referência
- GitHub Action custom (future work) que consome `actions/checkout` + script que dispara requisição HTTP.
- Alternativa simples: integrar com Zapier/Make.com escutando RSS de commits ou webhook do GitHub.

## Checklist de segurança
- Armazene URLs de webhook como segredos (`Settings > Secrets and variables > Actions`).
- Limite quem pode aprovar merges sem revisão.
- Audite periodicamente os logs de entrega do webhook.
