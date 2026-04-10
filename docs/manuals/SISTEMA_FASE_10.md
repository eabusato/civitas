# Manual Aprofundado do Sistema — FASE 10

## Visao geral

A FASE 10 adiciona a primeira camada explicita de dados do Civitas. O foco do bloco `10A-10G` e manter a persistencia visivel, pequena e inspecionavel: schema declarado em CCT, SQL gerado pelo framework, migracoes versionadas e modulos de conteudo editoriais construidos sobre SQLite preparado.

O bloco entrega:

- schema declarativo com `ModelDef`, `FieldDef`, indices e DDL para SQLite;
- query builder explicito com SQL gerado de forma previsivel e bind parametrizado;
- migracoes versionadas com tabela canonica e rollback do ultimo passo;
- taxonomia com slugs por locale, categorias e tags polimorficas;
- comentarios, reacoes, contadores de view e soft delete;
- autoria, origem de conteudo, review state e auditoria;
- paginas institucionais com SEO, menu, agendamento e publicacao.

## Schema declarativo

O contrato vive em `lib/civitas/model/`.

Capacidades estabilizadas:

- `FieldKind`, `FieldDef`, `IndexDef` e `ModelDef`;
- helpers `model_def_add_int/text/real/bool/date/datetime/uuid/blob/fk`;
- indices simples ou compostos;
- `storage_policy` como metadado associado ao modelo;
- geracao de SQL via `model_def_sql_create(...)` e criacao efetiva via `model_def_create_table(...)`;
- registro de modelos por nome de tabela em `ModelRegistry`.

Contratos operacionais:

- o schema e declarado em CCT, nao em strings SQL espalhadas pelo projeto;
- `FkBlob` continua semantico, mesmo sendo persistido como `TEXT` nesta fase;
- o `ModelRegistry` guarda referencias opacas a `ModelDef` heap-allocated;
- hooks de modelo nesta fase sao nomes declarados no `ModelDef`, ainda sem pipeline ORM automatica sobre `signals`.

## Query builder explicito

O contrato vive em `lib/civitas/query/`.

Capacidades estabilizadas:

- `Query`, `QueryFilter`, `QueryJoin`, `PrefetchSpec` e enums de operador/ordem/join;
- composicao de `SELECT`, filtros textuais/inteiros/reais, `JOIN`, `ORDER`, `LIMIT`, `OFFSET` e `DISTINCT`;
- `query_build_sql(...)` para inspecao do SQL gerado;
- `query_all(...)`, `query_first(...)`, `query_count(...)`, `query_exists(...)`;
- mutacoes parametrizadas com `InsertQuery`, `UpdateQuery` e `DeleteQuery`;
- `query_raw(...)` e `query_raw_exec(...)` para SQL explicito fora do builder.

Contratos operacionais:

- o backend desta fase e SQLite explicito via `cct/db_sqlite`;
- leitura de `SELECT` parametrizado acontece por `db_prepare + stmt_bind_* + stmt_step + stmt_get_*`;
- `query_all(...)` devolve o statement preparado para iteracao do caller; `query_rows_close(...)` fecha o handle;
- o builder nao tenta esconder SQL nem mapear rows automaticamente em structs de dominio.

## Migracoes versionadas

O contrato vive em `lib/civitas/migrate/migrate.cct`.

Capacidades estabilizadas:

- tabela canonica `civitas_migrations`;
- registro de versao, nome e timestamp aplicado;
- `migrator_add(...)`, `migrator_run(...)`, `migrator_rollback(...)` e `migrator_status(...)`;
- consulta da ultima versao aplicada.

Contratos operacionais:

- cada migration registra `up` e `down` como callbacks opacos;
- `rollback` atua apenas no ultimo passo aplicado;
- o estado do migrator e persistido no proprio banco;
- a fase permanece SQLite-first e nao introduz abstracao multi-backend ainda.

## Taxonomia e slugs

O contrato vive em `lib/civitas/taxonomy/`.

Capacidades estabilizadas:

- `taxonomy_slug_from_title(...)`, `taxonomy_slug_reserve(...)`, `taxonomy_slug_register(...)` e `taxonomy_slug_resolve(...)`;
- categorias com `title`, `description`, `locale`, `parent_id` e `slug`;
- tags com vinculo polimorfico a qualquer `object_type/object_id`;
- consultas de categorias e tags por id, slug e objeto.

Contratos operacionais:

- slugs sao unicos por `locale`;
- categorias e tags usam schema proprio criado por `taxonomy_ensure_schema(...)`;
- o modulo trabalha direto no banco, sem depender de ORM implicito.

## Social

O contrato vive em `lib/civitas/social/`.

Capacidades estabilizadas:

- comentarios com estados `pending`, `approved`, `rejected` e `deleted`;
- reacoes com toggle idempotente por ator;
- contador materializado de views;
- soft delete de comentarios.

Contratos operacionais:

- comentarios novos entram em `pending`;
- listagem publica usa `comment_list_approved(...)`;
- reacoes e views operam sobre pares `object_type/object_id`.

## Autoria e moderacao

O contrato vive em `lib/civitas/authorship/`.

Capacidades estabilizadas:

- `ContentOrigin` preenchido a partir de `LocalContext`;
- `AuthorshipFields` para create/update;
- `ReviewRecord` persistido com estado, reviewer e notas;
- emissao de auditoria por `cct/audit`.

Contratos operacionais:

- a origem do conteudo continua explicita e pequena;
- a trilha de auditoria e append-only no logger configurado;
- review state e separado do schema de pagina ou comentario.

## Paginas institucionais

O contrato vive em `lib/civitas/pages/`.

Capacidades estabilizadas:

- CRUD de pagina com `slug`, `locale`, `title`, `body_html` e `PageSeo`;
- estados `draft`, `published`, `scheduled` e `archived`;
- atualizacao de SEO e posicao em menu;
- listagem de publicadas e de agendadas vencidas;
- render helpers simples como `page_public_title(...)`.

Contratos operacionais:

- `pages_ensure_schema(...)` cria a tabela base da fase;
- menu e construido por consulta ordenada via `page_menu_build(...)`;
- a fase nao introduz CMS visual, workflow multi-etapa ou cache de render.

## Cobertura de testes

Cobertura da FASE 10:

- `10A`: 5 testes
- `10B`: 5 testes
- `10C`: 5 testes
- `10D`: 5 testes
- `10E`: 5 testes
- `10F`: 5 testes
- `10G`: 5 testes

Total da FASE 10: 35 testes de integracao.
