# Manual Aprofundado do Sistema — FASE 12

## Visao geral

A FASE 12 introduz a primeira camada oficial de cache do Civitas. O bloco `12A-12D` entrega uma API unificada de backend, cache de response HTTP, cache de query e uma coordenacao de invalidacao com anti-stampede.

O bloco entrega:

- `CacheHandle` uniforme sobre memoria, arquivo e Redis;
- `cache_view` para responses HTTP completas, com `Vary`, serializacao e invalidacao por tag;
- `cache_query` para resultados de query e contagens, com chave deterministica por SQL + parametros;
- coordenador de invalidacao entre 12A, 12B e 12C;
- anti-stampede por chave com backend local ou Redis.

## `civitas/cache`

O contrato vive em `lib/civitas/cache/`.

Capacidades estabilizadas:

- `CacheHandle`, `CacheBackendKind`, `CacheMaybeText` e `CacheMetrics`;
- factories `cache_mem_new(...)`, `cache_arq_new(...)` e `cache_redis_new(...)`;
- `cache_get(...)`, `cache_set(...)`, `cache_del(...)`, `cache_exists(...)`, `cache_get_ou_set(...)`, `cache_flush(...)` e `cache_flush_namespace(...)`;
- metricas de `acertos`, `falhas`, `evicoes` e `total_entradas`.

Contratos operacionais:

- toda escrita exige TTL explicito; `ttl = 0` significa sem expiracao;
- o namespace e parte do contrato do handle, evitando colisao entre modulos;
- o backend de memoria usa LRU simples com varredura previa de expirados;
- o backend de arquivo persiste por namespace e limpa recursivamente o diretório da camada;
- o backend Redis mantem um indice de chaves por namespace para flush coordenado.

## `civitas/cache_view`

O contrato vive em `lib/civitas/cache_view/`.

Capacidades estabilizadas:

- `CacheViewConfig`, `CacheViewEntry` e `CacheMaybeViewEntry`;
- `cache_view_new(...)`, `cache_view_chave(...)`, `cache_view_get(...)`, `cache_view_set(...)`, `cache_view_invalidar_tag(...)` e `cache_view_tag_count(...)`;
- `cache_view_middleware(...)` para GET e HEAD.

Contratos operacionais:

- a chave inclui metodo, path e os headers declarados em `vary_headers`;
- o cache armazena status, headers e body serializados;
- `HEAD` reaproveita o mesmo cache de `GET`, retornando response sem body;
- o indice de tags em memoria/arquivo fica no proprio modulo, sem disputar capacidade com o backend de dados;
- a invalidação por tag e explicita e previsivel, sem heuristica por template.

## `civitas/cache_query`

O contrato vive em `lib/civitas/cache_query/`.

Capacidades estabilizadas:

- `CacheQuery` como valor com handle opaco, namespace, TTL padrao e indices por tabela;
- `cache_query_new(...)`, `cache_query_chave(...)`, `cache_query_chave_contagem(...)`, `cache_query_get(...)`, `cache_query_set(...)`, `cache_query_invalidar_tabela(...)` e `cache_query_table_count(...)`;
- `query_all_cache(...)`, `query_all_cache_raw(...)` e `query_count_cache(...)`;
- `cache_query_registrar_invalidacao(...)` e `cache_query_signal_apply(...)`.

Contratos operacionais:

- a chave de cache e derivada de SQL gerado e parametros serializados em ordem deterministica;
- o resultado e armazenado em JSON textual, sem esconder a serializacao do caller;
- a granularidade de invalidação e por tabela;
- a integracao com signals nesta fase e por envelope aplicado explicitamente, nao por callback stateful no bus.

## `civitas/cache_invalidation`

O contrato vive em `lib/civitas/cache_invalidation/`.

Capacidades estabilizadas:

- `InvalidationCoord`, `InvalidationScope`, `InvalidationScopeKind` e `InvalidationResult`;
- builders `invalidation_scope_chave(...)`, `invalidation_scope_tag(...)`, `invalidation_scope_modelo(...)`, `invalidation_scope_rota(...)` e `invalidation_scope_locale(...)`;
- `invalidation_exec_one(...)`, `invalidation_exec(...)`, `invalidation_on_model_save(...)`, `invalidation_on_route_change(...)` e `invalidation_on_locale_publish(...)`;
- `invalidation_signal_register(...)` e `invalidation_signal_apply(...)`;
- `StampedeHandle`, `StampedeStatus`, `StampedeResult`, `stampede_handle_mem(...)`, `stampede_handle_redis(...)`, `stampede_try(...)`, `stampede_release(...)` e `stampede_abort(...)`.

Contratos operacionais:

- a coordenacao invalida cada camada apenas quando o handle correspondente existe;
- tags `model:*`, `route:*` e `locale:*` sao a convencao oficial de invalidacao de view;
- invalidação por modelo tambem limpa o indice de query da tabela correspondente;
- o anti-stampede faz `claim -> wait -> hit/timeout -> release`, usando set local em memoria ou claim key no Redis com `INCR + EXPIRE`.

## Cobertura de testes

Cobertura da FASE 12:

- `12A`: 6 testes
- `12B`: 7 testes
- `12C`: 6 testes
- `12D`: 8 testes

Total da FASE 12: 27 testes de integracao.
