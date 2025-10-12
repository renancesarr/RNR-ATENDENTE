# Script `wait-for`

Utilitário Bash para aguardar disponibilidade de serviços TCP antes de executar comandos dependentes.

## Uso

```bash
./tools/wait-for.sh host:port [-t timeout] [-- comando]

# Exemplo: aguardar Postgres e iniciar serviço custom
./tools/wait-for.sh postgres:5432 -- ./start-service.sh

# Exemplo: aguardar Redis com timeout de 60s
./tools/wait-for.sh redis:6379 -t 60
```

O script tenta estabelecer conexão `TCP` a cada segundo até atingir o timeout (padrão 30s). Caso seja fornecido comando após `--`, ele será executado assim que o destino estiver acessível.

Integre-o em serviços customizados adicionando `command: ["/bin/sh", "-c", "./tools/wait-for.sh postgres:5432 -- npm start"]` ou em scripts de bootstrap para garantir ordem de inicialização.
