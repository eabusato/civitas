# Spec Consolidada — FASE 10

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `10A-10G`.

## `civitas/model`

`lib/civitas/model/` estabiliza o schema declarativo de tabela do Civitas.

Contrato implementado:

- `FieldKind`, `FieldDef`, `IndexDef`, `ModelDef` e `ModelRegistry`;
- helpers `model_def_new(...)`, `model_def_add_*`, `model_def_add_index(...)` e `model_def_set_storage_policy(...)`;
- geracao de DDL via `model_field_ddl(...)`, `model_def_sql_create(...)` e `model_index_ddl(...)`;
- criacao da tabela e dos indices via `model_def_create_table(...)`;
- registro opaco de modelos por nome de tabela.

Contratos operacionais:

- o backend concreto desta fase e SQLite;
- `FkBlob` e persistido como `TEXT` para carregar JSON de `UploadDescriptor`;
- `ModelRegistry` permite registro, `has` e listagem de nomes;
- hooks de modelo permanecem declarativos nesta fase.

## `civitas/query`

`lib/civitas/query/` estabiliza o query builder explicito do Civitas.

Contrato implementado:

- `Query`, `QueryFilter`, `QueryJoin`, `PrefetchSpec`, `OrderDir`, `JoinKind` e `QueryOp`;
- `query_from(...)`, `query_select(...)`, `query_filter*`, `query_join(...)`, `query_order_by(...)`, `query_set_limit(...)`, `query_set_offset(...)`, `query_set_distinct(...)` e `query_build_sql(...)`;
- `query_all(...)`, `query_first(...)`, `query_count(...)`, `query_exists(...)` e `query_rows_close(...)`;
- mutacoes por `insert_into(...)`, `update_table(...)`, `delete_from(...)` e seus `*_execute(...)`;
- caminho raw via `query_raw(...)` e `query_raw_exec(...)`.

Contratos operacionais:

- `SELECT` parametrizado usa prepared statements do `cct/db_sqlite`;
- leitura de colunas usa `stmt_has_row(...)`, `stmt_get_text(...)`, `stmt_get_int(...)` e `stmt_get_real(...)`;
- `query_all(...)` devolve o statement para iteracao manual;
- o builder nao faz ORM implicito nem hydration automatica.

## `civitas/migrate`

`lib/civitas/migrate/migrate.cct` estabiliza migracoes versionadas.

Contrato implementado:

- `MigrationStep` e `Migrator`;
- `migrator_new(...)`, `migrator_add(...)`, `migrator_run(...)`, `migrator_rollback(...)`, `migrator_status(...)` e `migrator_last_applied_version(...)`;
- tabela `civitas_migrations` com `version`, `name` e `applied_at`.

Contratos operacionais:

- uma migration so roda se ainda nao estiver registrada;
- `rollback` atua apenas sobre a ultima versao aplicada;
- o status retorna pares versionados com flag aplicada/pendente.

## `civitas/taxonomy`

`lib/civitas/taxonomy/` estabiliza slugs, categorias e tags.

Contrato implementado:

- `SlugResolution`, `Category` e `Tag`;
- slug por locale com `taxonomy_slug_reserve(...)`, `taxonomy_slug_register(...)`, `taxonomy_slug_resolve(...)` e `taxonomy_slug_unregister(...)`;
- categorias com busca por id e slug;
- tags com attach/detach e listagem por objeto;
- queries auxiliares `category_list(...)` e `tag_list(...)`.

Contratos operacionais:

- slugs sao reservados e registrados em tabela dedicada;
- tags sao polimorficas por `object_type/object_id`;
- categorias suportam hierarquia por `parent_id`.

## `civitas/social`

`lib/civitas/social/` estabiliza interacoes sociais basicas.

Contrato implementado:

- `Comment`, `CommentState`, `ReactionKind` e `ViewCounter`;
- `comment_create/get/approve/reject/soft_delete/list_approved`;
- `reaction_has/toggle/count`;
- `view_counter_increment/get`.

Contratos operacionais:

- comentarios entram em `pending`;
- reacao e idempotente por ator;
- contadores de view sao materializados em tabela propria.

## `civitas/authorship`

`lib/civitas/authorship/` estabiliza origem, autoria e revisao.

Contrato implementado:

- `ContentOrigin`, `AuthorshipFields`, `ReviewState`, `ReviewRecord` e `AuthorshipConfig`;
- `authorship_origin_from_ctx(...)`, `authorship_populate_create(...)`, `authorship_populate_update(...)`;
- `review_save_state(...)`, `review_approve(...)`, `review_reject(...)`, `review_needs_revision(...)`, `review_get(...)` e `review_list_pending(...)`;
- auditoria via `authorship_emit(...)` e `authorship_emit_review(...)`.

Contratos operacionais:

- a origem e calculada a partir do `LocalContext`;
- revisao e persistida em schema dedicado;
- auditoria usa `cct/audit` sem fila ou outbox adicional nesta fase.

## `civitas/pages`

`lib/civitas/pages/` estabiliza paginas institucionais e landing pages.

Contrato implementado:

- `Page`, `PageSeo`, `MenuSlot` e `PublishState`;
- `page_create/get/update_body/update_seo/update_menu_slot`;
- `page_publish/schedule/unpublish/archive`;
- `page_list_published(...)`, `page_list_scheduled_due(...)` e `page_menu_build(...)`;
- `page_public_title(...)`.

Contratos operacionais:

- paginas operam direto sobre SQLite;
- SEO e menu sao parte do registro da pagina;
- agendamento e comparado por timestamp Unix em milissegundos.

## Cobertura de testes

A FASE 10 adiciona 35 testes de integracao:

- 5 em `10A`
- 5 em `10B`
- 5 em `10C`
- 5 em `10D`
- 5 em `10E`
- 5 em `10F`
- 5 em `10G`
