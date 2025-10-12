# Perfis do Docker Compose

O `docker-compose.yml` utiliza perfis para diferenciar ambientes **dev** (padrão) e **prod** (serviços extras).

## Serviços por perfil

- **Padrão (sem perfil)**: `postgres`, `redis`, `rabbitmq`, `evolution-api` — essenciais para desenvolvimento local.
- **Perfil `prod`**: `typebot-db`, `typebot-builder`, `typebot-viewer`, `watchtower` — habilitados apenas com `--profile prod`.

## Como usar

```bash
# Ambiente de desenvolvimento (default)
docker compose up -d

# Ambiente de produção/piloto com serviços extras
docker compose --profile prod up -d

# Derrubar serviços com perfil específico
docker compose --profile prod down
```

Certifique-se de que variáveis adicionais (`TYPEBOT_*`, `WATCHTOWER_*`) estejam definidas antes de iniciar o perfil `prod`.
