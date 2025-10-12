# Flags `DATABASE_SAVE_DATA_*`

As configurações da Evolution API controlam quais entidades são persistidas no Postgres. Para o MVP, todos os dados relevantes devem ser armazenados para analytics, RAG e auditoria.

## Valores recomendados

No arquivo `.env.example`, todas as flags já estão definidas como `true`:

```
DATABASE_SAVE_DATA_INSTANCE=true
DATABASE_SAVE_DATA_NEW_MESSAGE=true
DATABASE_SAVE_MESSAGE_UPDATE=true
DATABASE_SAVE_DATA_CONTACTS=true
DATABASE_SAVE_DATA_CHATS=true
DATABASE_SAVE_DATA_LABELS=true
DATABASE_SAVE_DATA_HISTORIC=true
```

Garanta que o ambiente real (`.env`) mantenha esses valores habilitados antes de iniciar a Evolution API.

## Auditoria

1. Após subir o compose, execute `docker compose exec evolution-api env | grep DATABASE_SAVE_DATA` para verificar os valores aplicados.
2. Confira se as tabelas correspondentes (`contacts`, `chats`, `messages`, etc.) estão recebendo dados (consultas simples/contagem).
3. Registre qualquer alteração nessas flags em ADR ou playbook, pois impacta métricas e RAG.

Desabilitar alguma flag deve ser tratado como exceção documentada (ex.: ambiente de teste com dados sintéticos).
