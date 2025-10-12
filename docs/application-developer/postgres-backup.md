# Backup e Restore do Postgres

Scripts utilitários para salvar e restaurar o banco principal da Evolution API usando `pg_dump`.

## Pré-requisitos
- Serviços Docker em execução (`docker compose up -d`).
- Variáveis definidas em `.env` (`POSTGRES_DB`, `POSTGRES_APP_DB`, `POSTGRES_APP_USER`, `POSTGRES_APP_PASSWORD`, `POSTGRES_PASSWORD`).
- Usuário superuser `postgres` disponível (padrão da imagem oficial).

## Backup (`tools/backup-postgres.sh`)
```bash
./tools/backup-postgres.sh [.env] [diretorio-saida]
```

- Primeiro parâmetro opcional: caminho para o arquivo `.env` (padrão: `./.env`).
- Segundo parâmetro opcional: diretório onde o backup será salvo (padrão: `./backups/postgres`).
- O script gera arquivo `postgres-YYYYMMDD-HHMMSS.dump` em formato custom (`pg_dump -Fc`).

## Restore (`tools/restore-postgres.sh`)
```bash
./tools/restore-postgres.sh <arquivo.dump> [.env]
```

- `arquivo.dump`: caminho para o backup gerado anteriormente.
- Segundo parâmetro opcional: arquivo `.env` a carregar (padrão: `./.env`).
- O script executa `pg_restore -c` (drop/create objetos) no database definido por `POSTGRES_APP_DB` (fallback para `POSTGRES_DB`).
- Recomenda-se executar em ambiente vazio; confirme que nenhum dado crítico está sendo sobrescrito.

## Boas práticas
- Armazene os dumps em diretório seguro e versionado fora do Git (`backups/` é ignorado).
- Teste o restore em ambiente separado após gerar o backup.
- Automatize execuções (cron/CI) integrando o script e monitore tamanho/tempo.
- Combine com a política de retenção (ADR-005) para garantir remoção de dumps antigos.
