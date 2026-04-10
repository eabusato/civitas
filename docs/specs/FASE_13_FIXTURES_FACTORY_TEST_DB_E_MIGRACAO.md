# FASE 13 — Fixtures, Factory, Test DB e Migracao de Dados

## Escopo consolidado

O bloco `13A-13E` estabiliza a infraestrutura de dados auxiliares do Civitas em cinco partes:

- fixtures declarativas;
- factories programaticas para testes;
- banco SQLite de teste com savepoints;
- import/export/backfill de dados;
- toolkit de migracao Django → Civitas.

## Contratos implementados

### `civitas/fixtures`

- `FixtureSuite`, `FixtureEntry` e `FixtureKind`;
- carga de fixture via JSON e TOML;
- instalacao e remocao no banco SQLite;
- indice de referencia por suite para lookup em testes.

Limites operacionais:

- o parser TOML atende o shape canonico usado pelo projeto;
- os campos sao mantidos como `Json`.

### `civitas/factory`

- `FactoryDef`, `FactoryRegistry`, `factory_build`, `factory_build_with`;
- campos constantes, sequenciais, nulos e dependencias entre factories;
- persistencia por `factory_create`, `factory_create_with` e `factory_create_with_deps`.

Limites operacionais:

- as sequencias desta fase sao deterministicas e orientadas a teste;
- o storage de contador fica em `tests/tmp/fase_13/factory_seq`.

### `civitas/test_db`

- `TestDbConfig`, `TestDb`, `test_db_open`, `test_db_open_memory`, `test_db_run_migrations`;
- savepoints por teste com begin/rollback/commit;
- helpers de assertiva por contagem, existencia e leitura de campo.

Limites operacionais:

- a fase e exclusivamente SQLite;
- o setup automatico aplica o schema atual a partir do `ModelRegistry`.

### `civitas/data_io`

- import de JSON, CSV e TOML (`[[rows]]`);
- export de JSON, CSV e TOML;
- mapeamento de colunas CSV por `CsvColMap`;
- backfill de slugs, hash de blob e state de blob.

Limites operacionais:

- o modulo e voltado a scripts administrativos;
- nao ha motor generico de transformacao por pipeline nesta fase.

### `civitas/django_migrate`

- parse de schema Django em JSON;
- mapeamento de tipos Django para `FieldKind`;
- import de fixtures `dumpdata` em JSON;
- copia de midia por subdiretorio;
- parity por contagem e checksum textual.

Limites operacionais:

- migracao one-way;
- suporte centrado nos tipos comuns do ORM Django;
- parity de arquivo binario continua dependente do descriptor e do backfill de blob da `13D`.

## Cobertura

O bloco fecha com 30 testes de integracao:

- 6 em `13A`
- 6 em `13B`
- 6 em `13C`
- 7 em `13D`
- 5 em `13E`

## Estado esperado do gate

O bloco `13A-13E` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
