# FASE 12 — Cache Multicamada

## Escopo consolidado

O bloco `12A-12D` estabiliza a camada de cache do Civitas em quatro partes:

- backend unificado de cache com memoria, arquivo e Redis;
- cache de response HTTP com serializacao de response, `Vary` e invalidacao por tag;
- cache de query e contagem sobre `civitas/query`;
- coordenacao de invalidacao e anti-stampede.

## Contratos implementados

### `civitas/cache`

- `CacheHandle` com `kind` e ponteiro opaco para backend concreto;
- `cache_get`, `cache_set`, `cache_del`, `cache_exists`, `cache_get_ou_set`, `cache_flush`, `cache_flush_namespace` e `cache_metrics`;
- TTL explicito e namespace por handle;
- backend de memoria com LRU simples;
- backend de arquivo persistente por namespace;
- backend Redis com indice de chaves para flush.

### `civitas/cache_view`

- `CacheViewConfig` com `namespace`, `ttl_padrao` e `vary_headers`;
- `cache_view_chave` baseada em metodo, path e headers declarados;
- `cache_view_get` e `cache_view_set` sobre `WebRequest`/`WebResponse`;
- `cache_view_invalidar_tag` e `cache_view_tag_count`;
- middleware de cache para GET e HEAD.

Limites operacionais:

- o indice de tags local vive em memoria do processo, mesmo quando o payload vai para backend arquivo;
- o cache de view nao interpreta template, model ou locale por inferencia; depende das tags passadas pelo caller.

### `civitas/cache_query`

- `cache_query_new`, `cache_query_get`, `cache_query_set`, `cache_query_invalidar_tabela`;
- `cache_query_chave` e `cache_query_chave_contagem`;
- `query_all_cache`, `query_all_cache_raw` e `query_count_cache`;
- serializacao textual em JSON;
- invalidacao por tabela registrada.

Limites operacionais:

- a integracao com signals nesta fase e feita por `cache_query_signal_apply(...)` sobre `SignalEnvelope`;
- a invalidacao e por tabela inteira, nao por row.

### `civitas/cache_invalidation`

- `InvalidationCoord` com handles opcionais para 12A, 12B e 12C;
- escopos `IskChave`, `IskTag`, `IskModelo`, `IskRota` e `IskLocale`;
- atalhos `invalidation_on_model_save`, `invalidation_on_route_change` e `invalidation_on_locale_publish`;
- `invalidation_signal_register` e `invalidation_signal_apply`;
- `stampede_handle_mem`, `stampede_handle_redis`, `stampede_try`, `stampede_release` e `stampede_abort`.

Limites operacionais:

- o backend local de anti-stampede coordena apenas dentro do processo atual;
- o backend Redis depende de `INCR` e `EXPIRE` no servidor Redis, sem fila nem lease renovavel;
- `StampedeStatus` cobre `claimed`, `hit`, `waiting` e `timeout`; stale fallback nao foi introduzido nesta fase.

## Cobertura

O bloco fecha com 27 testes de integracao:

- 6 em `12A`
- 7 em `12B`
- 6 em `12C`
- 8 em `12D`

## Estado esperado do gate

O bloco `12A-12D` so e considerado concluido com:

- `12A` verde isoladamente;
- `12B` verde isoladamente;
- `12C` verde isoladamente;
- `12D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
