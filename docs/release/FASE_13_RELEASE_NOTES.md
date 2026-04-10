# FASE 13 Release Notes

## Entregas

- `lib/civitas/fixtures/` com suites declarativas, loaders JSON/TOML, instalacao e lookup por referencia;
- `lib/civitas/factory/` com factories deterministicas, overrides e criacao de dependencias;
- `lib/civitas/test_db/` com banco SQLite de suite, setup de schema e isolamento por savepoint;
- `lib/civitas/data_io/` com import/export de JSON, CSV, TOML e backfill de slugs/blob;
- `lib/civitas/django_migrate/` com parse de schema, import de fixture Django, copia de midia e parity;
- expansao do runner unico para cobrir `13A-13E`.

## Decisoes relevantes

- fixtures e import/export TOML usam um shape canonico simples baseado em `[[rows]]`;
- o `ModelRegistry` passou a materializar `ModelDef` por valor em `items`, reduzindo fragilidade de ponteiros no subset executavel;
- `test_db_run_migrations(...)` aplica o schema atual a partir do registry e DDL ja estabilizados na fase 10;
- o toolkit Django foi mantido explicitamente one-way e orientado a script;
- o parity textual usa checksum de concatenacao ordenada por `id`, suficiente para comparacao deterministica de campo.

## Cobertura de testes

A FASE 13 adiciona:

- 6 testes em `13A`
- 6 testes em `13B`
- 6 testes em `13C`
- 7 testes em `13D`
- 5 testes em `13E`

Total da FASE 13: 30 testes de integracao.

## Estado do gate

O bloco `13A-13E`, fechando a FASE 13, so e considerado concluido com:

- `13A` verde isoladamente;
- `13B` verde isoladamente;
- `13C` verde isoladamente;
- `13D` verde isoladamente;
- `13E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
