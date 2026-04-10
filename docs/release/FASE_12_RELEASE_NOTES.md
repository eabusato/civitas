# FASE 12 Release Notes

## Entregas

- `lib/civitas/cache/` com backend unificado de cache em memoria, arquivo e Redis;
- `lib/civitas/cache_view/` com cache de response HTTP, chave por `Vary`, serializacao de response e invalidacao por tag;
- `lib/civitas/cache_query/` com cache de query/contagem e indices por tabela;
- `lib/civitas/cache_invalidation/` com coordenador de invalidação entre 12A/12B/12C e anti-stampede local ou Redis;
- expansao do runner unico para cobrir `12A-12D`.

## Decisoes relevantes

- o handle de cache segue o mesmo padrao de fronteira opaca usado em `DbHandle`;
- TTL e sempre explicito, sem expiração default escondida no backend;
- o indice de tags de `cache_view` local foi mantido no proprio modulo, desacoplado da capacidade LRU do backend;
- o cache de query usa chave deterministica por SQL + parametros serializados, nao heuristica por model;
- a coordenacao de invalidacao usa convencoes de tag (`model:*`, `route:*`, `locale:*`) e handles opcionais por camada;
- o anti-stampede desta fase resolve o caso de claim/wait/release sem introduzir stale serving automatico.

## Cobertura de testes

A FASE 12 adiciona:

- 6 testes em `12A`
- 7 testes em `12B`
- 6 testes em `12C`
- 8 testes em `12D`

Total da FASE 12: 27 testes de integracao.

## Estado do gate

O bloco `12A-12D`, fechando a FASE 12, so e considerado concluido com:

- `12A` verde isoladamente;
- `12B` verde isoladamente;
- `12C` verde isoladamente;
- `12D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
