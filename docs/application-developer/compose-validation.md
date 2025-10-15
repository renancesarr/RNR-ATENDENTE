# Execução do Compose e Validação de Endpoints

Guia para subir o ambiente local completo (`docker compose`) e validar a saúde dos serviços e o endpoint principal da Evolution API.

## Pré-requisitos
- Docker e Docker Compose instalados (versão 20.10+ recomendada).
- Arquivo `.env` preenchido a partir de `.env.example` (credenciais mínimas: `POSTGRES_PASSWORD`, `RABBITMQ_DEFAULT_PASS`, `EVOLUTION_AUTH_KEY`, etc.).
- Porta HTTP/WS da Evolution API livres (`8088/8089` por padrão) ou ajustadas no `.env`.

## 1. Preparar ambiente
```bash
cp .env.example .env            # se ainda não existir
docker compose pull             # garante imagens mais recentes
```

> Execute todos os comandos a partir da raiz do repositório para que o Docker Compose carregue o arquivo `.env` automaticamente.  
> Se precisar rodar em outra pasta, especifique o arquivo manualmente: `docker compose --env-file /caminho/para/.env up -d`.

## 2. Subir os serviços essenciais
```bash
docker compose up -d
```

- Para incluir os serviços opcionais (`typebot-*`, `watchtower`), utilize `docker compose --profile prod up -d`.
- Também é possível usar o script automatizado: `./start.sh` (adicionar `--with-prod` para incluir o perfil `prod`). O script gera/atualiza `docker-compose.yaml` com todas as variáveis resolvidas — o arquivo é sobrescrito a cada execução e não deve ser versionado.
- Para encerrar o ambiente manualmente use `./stop.sh`; para smoke test completo (stop ➜ start ➜ validação ➜ stop) utilize `./start.test.sh [--with-prod] [--skip-pull]`. O script tenta novamente o healthcheck da Evolution API por até 10 tentativas (intervalo padrão 60 s) e aguarda containers `starting` estabilizarem.

## 3. Confirmar que tudo está healthy
```bash
docker compose ps
```

- Status esperado: `healthy` para `postgres`, `redis`, `rabbitmq`, `evolution-api` e, se em uso, `watchtower`.
- Caso algum serviço apareça como `unhealthy`, verifique os logs específicos:
  ```bash
  docker compose logs <service> --tail 50
  ```

## 4. Validar dependências internas
- **Postgres**
  ```bash
  docker compose exec postgres pg_isready -U postgres -d "${POSTGRES_DB:-evolution}"
  ```
- **Redis**
  ```bash
  docker compose exec redis redis-cli ping
  ```
- **RabbitMQ**
  ```bash
  docker compose exec rabbitmq rabbitmq-diagnostics -q status
  ```

## 5. Testar endpoint da Evolution API
```bash
curl -fsS http://localhost:${EVOLUTION_API_HTTP_PORT:-8088}/status
```

- Resultado esperado: payload JSON com `success: true` ou status HTTP `200`.  
- Caso a instância exija autenticação (ex.: header `Authorization`), adicione-o conforme documentação da Evolution API:
  ```bash
  curl -H "Authorization: Bearer ${EVOLUTION_AUTH_KEY}" \
       http://localhost:${EVOLUTION_API_HTTP_PORT:-8088}/status
  ```
- Se o endpoint real divergir da raiz `/`, ajuste o comando e atualize `docker-compose.yml` (seção `healthcheck`) para refletir o caminho correto.
- O script `start.sh` permite definir o caminho via variável `EVOLUTION_HEALTHCHECK_PATH` no `.env` (padrão atual: `/`).

## 6. Monitorar logs em tempo real
```bash
docker compose logs -f evolution-api
```

- Útil para acompanhar bootstrap de sessão WhatsApp e erros de conexão com serviços dependentes.

## 7. Encerrar ambiente
```bash
docker compose down            # remove containers e rede
docker compose down -v         # remove também volumes (use com cautela)
```

> Nunca rode `down -v` em ambientes com dados relevantes sem backup (`evolution_pgdata`, `evolution_instances`, `evolution_rabbitmq`).

## Checklist rápido
- [ ] `.env` configurado com credenciais válidas.
- [ ] `docker compose up -d` executado sem erros.
- [ ] `docker compose ps` mostra todos os serviços `healthy`.
- [ ] `curl` no endpoint retorna status `200`.
- [ ] Logs verificam ausência de erros críticos.

Quando o endpoint estiver validado, registre o resultado (screenshot/log) no repositório ou ferramenta de acompanhamento conforme fluxos definidos nas tarefas T-016 a T-020.
