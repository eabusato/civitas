# Manual Aprofundado do Sistema — FASE 11

## Visao geral

A FASE 11 move a infraestrutura de dados do Civitas do estado SQLite-first para um nucleo multi-backend mais realista. O bloco `11A-11E` entrega uma camada uniforme de acesso a banco, pool por processo, transacoes aninhadas com savepoints, busca full-text PostgreSQL e locks canonicos para concorrencia segura.

O bloco entrega:

- `DbHandle` e `DbRows` como abstracao uniforme sobre SQLite e PostgreSQL;
- pool de conexoes com prewarm, timeout, health check, reconexao e metricas;
- `TxContext` com profundidade, savepoints e `com_transacao(...)`;
- registro e geracao de SQL para indices de busca full-text PostgreSQL;
- advisory locks com namespaces canonicos e guard idempotente.

## `civitas/db_handle`

O contrato vive em `lib/civitas/db_handle/`.

Capacidades estabilizadas:

- `DbHandle`, `DbRows`, `DbParam`, `DbParams` e `PoolBackendKind`;
- `dbh_exec(...)`, `dbh_query(...)`, `dbh_scalar_int(...)`, `dbh_begin(...)`, `dbh_commit(...)`, `dbh_rollback(...)`;
- `dbh_savepoint(...)`, `dbh_rollback_to(...)` e `dbh_release_savepoint(...)`;
- `dbrows_next(...)`, `dbrows_get_text(...)`, `dbrows_get_int(...)`, `dbrows_get_real(...)`, `dbrows_get_bool(...)` e `dbrows_close(...)`;
- factories `dbh_from_sqlite(...)` e `dbh_from_postgres(...)`.

Contratos operacionais:

- o caller trabalha com `DbHandle` em vez de usar handles brutos do backend;
- leitura de rows continua explicita e iterativa;
- SQLite e PostgreSQL compartilham a mesma superficie do framework, sem esconder diferencas operacionais relevantes.

## `civitas/pool`

O contrato vive em `lib/civitas/pool/`.

Capacidades estabilizadas:

- `PoolConfig`, `Pool`, `PoolMetrics`, `PoolSlot` e `PoolOpenResult`;
- `pool_new(...)`, `pool_new_sqlite(...)`, `pool_acquire(...)`, `pool_release(...)`, `pool_health_check(...)`, `pool_tick(...)` e `com_pool(...)`;
- adaptadores `pool_sqlite_open_handle(...)` e `pool_postgres_open_handle(...)`.

Contratos operacionais:

- o pool e por processo;
- cada slot carrega um `DbHandle` heap-allocated;
- health check e reconexao acontecem no acquire/tick, sem esconder falha de backend;
- as metricas expostas sao de uso real do pool, nao contadores cosmeticos.

## `civitas/transaction`

O contrato vive em `lib/civitas/transaction/transaction.cct`.

Capacidades estabilizadas:

- `TxContext` com `depth` e `savepoint_seq`;
- `tx_begin(...)`, `tx_commit(...)`, `tx_rollback(...)`;
- `com_transacao(...)` com rollback automatico em callback falso;
- savepoints automaticos para nesting.

Contratos operacionais:

- profundidade zero abre transacao real;
- profundidade maior usa savepoints nomeados;
- commit e rollback respeitam o nivel atual do contexto em vez de assumir transacao plana;
- o caller continua no controle do `DbHandle`.

## `civitas/search`

O contrato vive em `lib/civitas/search/`.

Capacidades estabilizadas:

- `SearchField`, `SearchIndex`, `SearchRegistry` e resultados tipados de registro;
- `search_field_new(...)`, `search_index_new(...)`, `search_registry_add(...)`, `search_registry_get(...)`;
- geracao de SQL via `search_index_column_sql(...)`, `search_index_create_sql(...)`, `search_index_update_sql(...)`, `search_index_rebuild_sql(...)`;
- build de SQL agregado para busca multi-tipo com `UNION ALL`.

Contratos operacionais:

- a fase gera SQL e metadados; nao entrega pipeline de indexacao assincrona;
- locale e configurado por indice;
- busca continua explicita e composta sobre PostgreSQL, sem motor proprio no Civitas.

## `civitas/locks`

O contrato vive em `lib/civitas/locks/`.

Capacidades estabilizadas:

- `LockGuard`, `LockEvent`, `JobLockResult` e `LockError`;
- `lock_key_media(...)`, `lock_key_translation(...)`, `lock_key_cron(...)` e `lock_key_model(...)`;
- `lock_guard_acquire(...)`, `lock_guard_try_acquire(...)`, `lock_guard_release(...)`;
- `lock_event_log(...)` e helpers de job lock.

Contratos operacionais:

- locks usam advisory locks PostgreSQL do CCT;
- os namespaces de chave sao canonicos e previsiveis;
- `lock_guard_release(...)` e idempotente;
- eventos de lock podem ser serializados em logger sem acoplar a fila ou scheduler.

## Cobertura de testes

Cobertura da FASE 11:

- `11A`: 5 testes
- `11B`: 5 testes
- `11C`: 5 testes
- `11D`: 5 testes
- `11E`: 5 testes

Total da FASE 11: 25 testes de integracao.
