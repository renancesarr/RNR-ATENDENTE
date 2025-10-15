# Docker Compose — Serviços Essenciais (T-016 a T-020)

Este guia resume a configuração atual do `docker-compose.yml` para atender às tarefas T-016 até T-020, garantindo que os serviços fundamentais do MVP subam com persistência adequada e monitoração básica.

## Serviços obrigatórios

- **Postgres (`postgres`)**
  - Imagem `postgres:15-alpine`.
  - Variáveis: `POSTGRES_DB`, `POSTGRES_PASSWORD`.
  - Volume nomeado `evolution_pgdata` garante persistência.
  - Healthcheck: `pg_isready` verificando o banco alvo.

- **Redis (`redis`)**
  - Imagem `redis:7-alpine`.
  - Configurado como cache-only (sem `SAVE`, `appendonly`, dados em `tmpfs`).
  - Healthcheck: `redis-cli ping`.
  - Recarrega limpo a cada reinício, alinhado ao ADR de cache volátil.

- **RabbitMQ (`rabbitmq`)**
  - Imagem `rabbitmq:3.12-management`.
  - Usa `definitions.json` versionado para filas e usuários padrão.
  - Volumes: `evolution_rabbitmq` (dados) + arquivo de definição somente-leitura.
  - Healthcheck: `rabbitmq-diagnostics status`.

- **Evolution API (`evolution-api`)**
  - Imagem `evoapicloud/evolution-api:v2.3.4`.
  - Mantida apenas na rede interna; acesso externo passa pelo proxy.
  - Volume `evolution_instances` preserva sessões WhatsApp (T-019).
  - `depends_on` com condição `service_healthy` para Postgres, Redis e RabbitMQ.
  - Healthcheck interno (placeholder `GET /status`) — ajustar endpoint real conforme documentação oficial.

- **Reverse Proxy (`reverse-proxy`)**
  - Imagem `nginx:1.25-alpine`.
  - Expõe as portas `${EVOLUTION_PROXY_HTTP_PORT:-8088}` e `${EVOLUTION_PROXY_WS_PORT:-8089}` para HTTP/WS.
  - Exige header `Authorization: Bearer <EVOLUTION_AUTH_KEY>` (substituído via `envsubst`) antes de encaminhar ao `evolution-api`.
  - Healthcheck básico (`wget http://localhost:8080/`) garante que a página de boas-vindas esteja disponível.

## Volumes nomeados

```
volumes:
  evolution_instances:
  evolution_pgdata:
  evolution_rabbitmq:
  typebot_pgdata:
```

> `redis` permanece sem volume para reforçar a estratégia cache-only (vide T-028).

## Healthchecks (T-020)

Todos os serviços essenciais possuem healthcheck com intervalos e timeouts razoáveis. O Watchtower (perfil `prod`) também recebeu um check simples (`watchtower --version`) para detectar imagem quebrada.

## Redes

```
networks:
  internal:
    name: evolution_net
```

Rede bridge dedicada garante isolamento entre serviços e facilita integração futura com proxy reverso.

## Como validar

```bash
# Subir serviços padrão (T-016 a T-018) através do Makefile
make up

# Verificar healthchecks
docker compose ps

# Conferir logs específicos
docker compose logs postgres
docker compose logs reverse-proxy
docker compose logs evolution-api
```

- Para conferir persistência de Postgres: `docker compose exec postgres psql -U postgres -d $POSTGRES_DB -c '\dt'`.
- Para validar volume de instâncias: `docker volume inspect evolution_instances`.
- Para testar RabbitMQ: acesse `http://localhost:${RABBITMQ_MANAGEMENT_PORT:-15672}` (credenciais conforme `.env`).

## Próximos passos

1. Confirmar se o caminho de healthcheck (`/`) permanece estável nas próximas versões da Evolution API e refletir no template Nginx.
2. Avaliar healthcheck customizado para RabbitMQ (fila específica) quando os consumidores estiverem ativos.
3. Revisar se endpoints externos devem trafegar via HTTPS (certificados/terminação TLS) em ambientes superiores.
