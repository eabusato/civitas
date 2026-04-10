# FASE 11 Release Notes

## Entregas

- `lib/civitas/db_handle/` com `DbHandle` uniforme sobre SQLite e PostgreSQL;
- `lib/civitas/pool/` com pool por processo, prewarm, timeout, health check, reconexao e metricas;
- `lib/civitas/transaction/transaction.cct` com transacoes aninhadas, savepoints e `com_transacao(...)`;
- `lib/civitas/search/` com registro de indices e geracao de SQL full-text PostgreSQL;
- `lib/civitas/locks/` com advisory locks canonicos, guard idempotente e eventos de lock;
- expansao do runner unico para cobrir `11A-11E`.

## Decisoes relevantes

- a camada de banco passa a ser orientada por `DbHandle`, nao por handles crus do backend;
- o pool continua pequeno e observavel, sem esconder reconexao ou falha de acquire;
- transacoes permanecem explicitas, com nesting controlado por `TxContext`;
- busca full-text desta fase entrega SQL e registro, nao pipeline automatica de indexacao;
- locks usam a infraestrutura PostgreSQL do CCT, sem duplicar o mecanismo no Civitas.

## Cobertura de testes

A FASE 11 adiciona:

- 5 testes em `11A`
- 5 testes em `11B`
- 5 testes em `11C`
- 5 testes em `11D`
- 5 testes em `11E`

Total da FASE 11: 25 testes de integracao.

## Estado do gate

O bloco `11A-11E`, fechando a FASE 11, so e considerado concluido com:

- `11A` verde isoladamente;
- `11B` verde isoladamente;
- `11C` verde isoladamente;
- `11D` verde isoladamente;
- `11E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
