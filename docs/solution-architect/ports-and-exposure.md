# Portas e Exposição dos Serviços

Mapa das portas configuradas no `docker-compose.yml`, indicando quais devem permanecer internas e quais são expostas externamente via proxy.

## Resumo

| Serviço              | Porta interna | Porta externa (host)                  | Protocolo | Observações                                   |
|----------------------|--------------:|--------------------------------------|-----------|-----------------------------------------------|
| `reverse-proxy`      | 8080 / 8081   | `${EVOLUTION_PROXY_HTTP_PORT:-8088}` / `${EVOLUTION_PROXY_WS_PORT:-8089}` | HTTP / WS | Exige `Authorization: Bearer <EVOLUTION_AUTH_KEY>` antes de encaminhar para a Evolution API. |
| `evolution-api`      | 8080 / 8083   | —                                    | HTTP / WS | Acessível apenas pela rede interna `evolution_net`. Não mapear diretamente para o host.     |
| `rabbitmq`           | 15672 / 5672  | `${RABBITMQ_MANAGEMENT_PORT:-15672}` / `${RABBITMQ_AMQP_PORT:-5672}` | HTTP / AMQP | Interface de gerenciamento (15672) e AMQP (5672). Recomendado restringir acesso externo.     |
| `postgres`           | 5432          | —                                    | TCP       | Usado apenas internamente. Expor apenas sob necessidade e VPN/filtro de IP.                 |
| `redis`              | 6379          | —                                    | TCP       | Cache-only; manter interno.                                                           |
| `typebot-builder`    | 3000          | `${TYPEBOT_BUILDER_PORT:-8081}`      | HTTP      | Perfil `prod`. Considere proxy com autenticação se exposto ao host.                     |
| `typebot-viewer`     | 3000          | `${TYPEBOT_VIEWER_PORT:-8082}`       | HTTP      | Perfil `prod`. Aplicar TLS/restrição conforme ambiente.                                 |
| `watchtower`         | —             | —                                    | —         | Sem portas expostas; monitora containers via Docker socket.                             |

## Recomendações

1. **Produção**  
   - Manter apenas o `reverse-proxy` exposto ao público (idealmente atrás de um balanceador/TLS).  
   - Restringir RabbitMQ, Postgres e Redis a redes internas ou VPN.  
   - Configurar firewalls para permitir apenas IPs autorizados nas portas 15672/5672 (se necessário).

2. **Ambiente de teste/local**  
   - Variáveis em `.env.example` já apontam o proxy para 8088/8089. Ajuste conforme conflito de portas.  
   - Ferramentas como `start.sh` e `start.test.sh` consomem os endpoints via proxy; atualize scripts customizados se referirem às portas antigas (8080/8083).

3. **TLS / HTTPS**  
   - Avaliar terminação TLS no balanceador ou adicionar certificados ao Nginx (`reverse-proxy`) para ambientes públicos.  
   - Configurar HSTS e cabeçalhos de segurança quando HTTPS estiver ativo.

4. **Monitoramento**  
   - Adicionar healthchecks específicos no proxy (`/`) e monitorar logs de requisições não autorizadas.  
   - Registrar métricas de uso por porta/serviço para identificar acessos indevidos.
