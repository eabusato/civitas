# Manual Aprofundado do Sistema — FASE 13

## Visao geral

A FASE 13 consolida a camada operacional de dados auxiliares do Civitas fora do ciclo normal de request. O bloco `13A-13E` entrega fixtures declarativas, factories programaticas, banco de teste com isolamento por savepoint, import/export/backfill de dados e um toolkit pontual de migracao Django → Civitas.

O bloco entrega:

- `civitas/fixtures` para carga declarativa de dados em JSON e TOML;
- `civitas/factory` para geracao repetivel de registros com sequencias e dependencias;
- `civitas/test_db` para suite SQLite em memoria/arquivo com setup automatico de schema e rollback por savepoint;
- `civitas/data_io` para import, export e backfill fora do pipeline HTTP;
- `civitas/django_migrate` para migracao one-way de schema, fixtures, midia e parity.

## `civitas/fixtures`

O contrato vive em `lib/civitas/fixtures/`.

Capacidades estabilizadas:

- `FixtureEntry`, `FixtureSuite` e `FixtureKind`;
- `fixture_load_json(...)` e `fixture_load_toml(...)`;
- `fixture_install(...)` e `fixture_uninstall(...)`;
- `fixture_ref_build(...)` e `fixture_ref_get(...)`;
- merge de suites preservando ordem de entrada.

Limites operacionais:

- os campos de fixture sao materializados como `Json` objeto no runtime, nao como AST TOML persistida;
- o parser TOML desta fase cobre o shape canonico de tabelas/linhas usado em fixtures e scripts do projeto.

## `civitas/factory`

O contrato vive em `lib/civitas/factory/`.

Capacidades estabilizadas:

- `FactoryDef`, `FactoryField`, `FactoryDep` e `FactoryRegistry`;
- campos constantes, sequenciais e nulos;
- overrides por `Json`;
- `factory_create(...)`, `factory_create_with(...)` e `factory_create_with_deps(...)`;
- sequencias deterministicas persistidas em `tests/tmp/fase_13/factory_seq`.

Limites operacionais:

- a sequencia desta fase e voltada para testes e nao para uso concorrente de producao;
- a persistencia em arquivo foi escolhida para manter previsibilidade no subset atual do CCT.

## `civitas/test_db`

O contrato vive em `lib/civitas/test_db/`.

Capacidades estabilizadas:

- `TestDbConfig` e `TestDb`;
- `test_db_open(...)`, `test_db_open_memory(...)`, `test_db_run_migrations(...)` e `test_db_close(...)`;
- `test_db_begin_test(...)`, `test_db_rollback_test(...)` e `test_db_commit_test(...)`;
- helpers `test_db_count(...)`, `test_db_count_where(...)`, `test_db_exists(...)`, `test_db_exists_id(...)` e `test_db_row_field(...)`.

Limites operacionais:

- a aplicacao de schema nesta fase usa o `ModelRegistry` atual e DDL gerado, sem runner proprio de migrations versionadas;
- o isolamento e por savepoint na mesma conexao SQLite.

## `civitas/data_io`

O contrato vive em `lib/civitas/data_io/`.

Capacidades estabilizadas:

- `ImportSource`, `ExportTarget`, `DataIoResult` e `CsvColMap`;
- `data_import_json(...)`, `data_import_csv(...)`, `data_import_toml(...)` e `data_import(...)`;
- `data_export_json(...)`, `data_export_csv(...)`, `data_export_toml(...)` e `data_export(...)`;
- `data_backfill_slugs(...)`, `data_backfill_blob_hashes(...)` e `data_backfill_blob_state(...)`.

Limites operacionais:

- o modulo e utilitario para scripts; nao foi integrado ao pipeline HTTP;
- o formato TOML implementado para import/export usa blocos `[[rows]]` como contrato canonico desta fase;
- o backfill de blob opera sobre `UploadDescriptor` JSON textual persistido em coluna `FkBlob`.

## `civitas/django_migrate`

O contrato vive em `lib/civitas/django_migrate/`.

Capacidades estabilizadas:

- `DjangoFieldType`, `DjangoField`, `DjangoModel`, `DjangoMigrateConfig` e `DjangoMigrateResult`;
- `django_field_type_parse(...)`, `django_schema_parse(...)`, `django_field_to_civitas(...)` e `django_model_to_civitas(...)`;
- `django_fixture_import(...)` para `dumpdata` JSON;
- `django_media_import(...)` para copia de `MEDIA_ROOT`;
- `django_parity_count(...)`, `django_parity_checksum_field(...)` e `django_parity_report(...)`.

Limites operacionais:

- o toolkit e one-way e orientado a script administrativo, nao a runtime de servidor;
- a importacao de fixture usa mapeamento por `app.model` para `db_table`;
- a copia de midia desta fase cobre o fluxo canonico por subdiretorio e arquivos regulares.

## Cobertura de testes

Cobertura da FASE 13:

- `13A`: 6 testes
- `13B`: 6 testes
- `13C`: 6 testes
- `13D`: 7 testes
- `13E`: 5 testes

Total da FASE 13: 30 testes de integracao.
