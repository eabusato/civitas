# Spec Consolidada — FASE 11

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `11A-11E`.

## `civitas/db_handle`

`lib/civitas/db_handle/` estabiliza a camada uniforme de banco do Civitas.

Contrato implementado:

- `DbHandle`, `DbRows`, `DbParam`, `DbParams` e `PoolBackendKind`;
- `dbh_from_sqlite(...)` e `dbh_from_postgres(...)`;
- `dbh_exec(...)`, `dbh_query(...)`, `dbh_scalar_int(...)`, `dbh_begin(...)`, `dbh_commit(...)`, `dbh_rollback(...)`;
- savepoints via `dbh_savepoint(...)`, `dbh_rollback_to(...)` e `dbh_release_savepoint(...)`;
- leitura tipada de rows via `dbrows_next/get_text/get_int/get_real/get_bool`.

Contratos operacionais:

- o backend concreto fica encapsulado no handle;
- query e mutacao seguem explicitas;
- rows continuam iteradas manualmente pelo caller.

## `civitas/pool`

`lib/civitas/pool/` estabiliza pool de conexoes por processo.

Contrato implementado:

- `PoolConfig`, `Pool`, `PoolMetrics`, `PoolSlot`, `PoolOpenResult` e `PoolError`;
- `pool_new(...)`, `pool_new_sqlite(...)`, `pool_acquire(...)`, `pool_release(...)`, `pool_health_check(...)`, `pool_tick(...)` e `com_pool(...)`;
- adaptadores SQLite e PostgreSQL para abrir `DbHandle`.

Contratos operacionais:

- acquire respeita timeout;
- slots ociosos passam por health check e reconexao;
- metricas rastreiam aquisicoes, reconexoes, timeouts, slots ativos/ociosos/mortos;
- o pool nao esconde falha de abertura de conexao.

## `civitas/transaction`

`lib/civitas/transaction/transaction.cct` estabiliza transacoes aninhadas.

Contrato implementado:

- `TxContext` com `depth` e `savepoint_seq`;
- `tx_begin(...)`, `tx_commit(...)`, `tx_rollback(...)` e `com_transacao(...)`.

Contratos operacionais:

- profundidade zero usa begin/commit/rollback reais;
- profundidade maior usa savepoints;
- rollback automatico acontece quando o callback de `com_transacao(...)` devolve `FALSUM`.

## `civitas/search`

`lib/civitas/search/` estabiliza o contrato de busca full-text PostgreSQL.

Contrato implementado:

- `SearchField`, `SearchIndex`, `SearchRegistry`;
- registro de indices com validacao de duplicidade;
- geracao de coluna `tsvector`, indice `GIN`, SQL de rebuild e SQL de update;
- build de SQL de busca simples e multi-tipo com locale.

Contratos operacionais:

- a fase entrega registro e SQL gerado, nao engine propria de indexacao;
- cada indice declara tabela, coluna primaria e locale;
- a composicao multi-tipo usa `UNION ALL` explicito.

## `civitas/locks`

`lib/civitas/locks/` estabiliza locks concorrentes baseados em advisory locks PostgreSQL.

Contrato implementado:

- chaves canonicas para media, traducao, cron e registro de modelo;
- `LockGuard` com release idempotente;
- `LockEvent` serializavel em logger;
- helpers de acquire/try-acquire/release.

Contratos operacionais:

- o lock guarda `PgLockHandle` opaco;
- soltar duas vezes o mesmo guard nao e erro;
- o modulo trabalha sobre `cct/db_postgres_lock`, sem inventar um servidor de locks proprio.

## Cobertura de testes

A FASE 11 adiciona 25 testes de integracao:

- 5 em `11A`
- 5 em `11B`
- 5 em `11C`
- 5 em `11D`
- 5 em `11E`
