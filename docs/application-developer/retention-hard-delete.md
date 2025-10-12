# Job de Limpeza (Hard Delete)

Executa remoção definitiva de dados conforme regras de `audit_retention`, com suporte a dry-run para auditoria.

## Execução

Dry-run (padrão):

```bash
./tools/purge-retention.sh --dry-run
```

Aplicar efetivamente a remoção (sem dry-run):

```bash
./tools/purge-retention.sh --apply
```

Parâmetro `--env <arquivo>` permite especificar outro arquivo `.env`.

## Comportamento

- Seleciona políticas ativas em `audit_retention`.
- Para escopo `contacts`, calcula cutoff `delete_after_months` e remove dados correlatos (`messages`, `chat_history`, `fact_*`, `event_log`, `chats`, `contacts`).
- Em modo dry-run, apenas reporta número de registros afetados.

## Recomendações

- Executar apenas após confirmação de anonimização (`fn_apply_retention_scrub`).
- Registrar resultados em `audit_retention_log` (tarefa futura) e manter log de execuções.
- Garantir backup recente antes de rodar em modo `--apply`.
