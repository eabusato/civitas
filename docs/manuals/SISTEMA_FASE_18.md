# Manual Aprofundado do Sistema — FASE 18

## Visao geral

A FASE 18 consolida a camada administrativa do Civitas. O bloco `18A-18E` entrega operacao sobre modelos, relacoes, moderacao e estado operacional sem obrigar cada aplicacao a reescrever listagem, CRUD, acoes em lote e consultas administrativas do zero.

O bloco entrega:

- `civitas/admin` para registry de modelos, listagem, CRUD, bulk e auditoria;
- `civitas/admin` inline para edicao de relacionamentos filho;
- `civitas/admin` extensivel com computed fields builtin, acoes customizadas, permissoes, widgets e CSV;
- `civitas/admin_moderation` para filas de revisao e historico de decisoes;
- `civitas/admin_dashboard` para snapshots operacionais, visao de filas e falhas recentes.

## Modelo operacional da fase

O contrato estabilizado nesta fase e:

1. a aplicacao registra modelos administrativos em um `AdminRegistry`;
2. a configuracao do painel e persistida em tabelas canonicas de registry;
3. listagem, create, update, delete e bulk operam sobre `DbHandle` e SQL parametrizado;
4. relacoes inline sao reconciliadas por `fk_field` e podem ser submetidas na mesma unidade transacional do parent;
5. moderacao e dashboard leem e escrevem sobre tabelas reais do sistema, nao sobre um schema paralelo.

Limites operacionais explicitos:

- a fase fecha o contrato de dados, registry e rotas stub do admin; ela nao entrega uma UI HTML completa do painel;
- campos calculados usam resolvedor builtin do modulo, em vez de callback arbitraria aberta;
- export oficial materializado no bloco e CSV;
- o dashboard mistura snapshot persistido e consultas ao vivo para filas/falhas.

## `civitas/admin`

O contrato vive em `lib/civitas/admin/`.

Capacidades estabilizadas:

- `AdminModelConfig`, `AdminRegistry`, `AdminListQuery`, `AdminListResult`, `AdminLookup`, `AdminBulkResult` e `AdminAuditEntry`;
- `admin_register(...)` e `admin_registry_find(...)`;
- `admin_list(...)`, `admin_list_count(...)` e `admin_get_one(...)`;
- `admin_create(...)`, `admin_update(...)` e `admin_delete(...)`;
- `admin_bulk_action(...)`;
- `admin_register_routes(...)` e `admin_model_config_generate_routes(...)`;
- `admin_audit_write(...)` e `admin_audit_count(...)`;
- `admin_user_has_permission(...)` por prefixo de permissao do modelo.

Comportamento materializado:

- configuracoes ficam em `admin_model_registry`;
- filtros, busca e ordenacao respeitam allowlist do config;
- CRUD grava trilha de auditoria e usa bind parametrizado;
- bulk opera sobre IDs explicitamente fornecidos, sem heuristica implícita.

## Inlines

O contrato vive em:

- `admin_inline.cct`
- `admin_inline_schema.cct`
- `admin_inline_query.cct`
- `admin_inline_save.cct`
- `admin_inline_submit.cct`
- `admin_inline_routes.cct`

Capacidades estabilizadas:

- `AdminInlineConfig` e `InlineSubmit`;
- registry persistido em `admin_inline_registry`;
- `admin_inline_count(...)` e `admin_inline_list_for_parent(...)`;
- `admin_inline_save_one(...)`, `admin_inline_delete_one(...)` e `admin_inline_submit_all(...)`.

Limites operacionais:

- a propriedade do child e sempre validada contra o parent antes de update/delete;
- a fase fecha o contrato de dados e persistencia inline, nao um renderer completo de formulario inline.

## Extensibilidade administrativa

O contrato vive em:

- `admin_computed.cct`
- `admin_permissions.cct`
- `admin_actions.cct`
- `admin_dashboard.cct`
- `admin_export.cct`

Capacidades estabilizadas:

- registry de computed fields em `admin_computed_fields`;
- permissoes por modelo/acao em `admin_permissions`;
- acoes customizadas em `admin_custom_actions`;
- widgets administrativos em `admin_widgets`;
- export `admin_export_csv(...)`.

Limites operacionais:

- o resolvedor de campo calculado validado nesta fase e builtin;
- a invocacao de acao customizada retorna JSON agregado simples;
- widgets materializados na fase sao de contagem e recentes.

## `civitas/admin_moderation`

O contrato vive em `lib/civitas/admin_moderation/`.

Capacidades estabilizadas:

- `ModerationItem`, `ModerationDecision` e `ModerationBulkResult`;
- `moderation_item_create(...)`;
- `moderation_queue_list(...)` e `moderation_history_json(...)`;
- `moderation_decide(...)` e `moderation_bulk_apply(...)`;
- schema `moderation_items` e `moderation_decisions`.

Comportamento materializado:

- filas sao segmentadas por `kind` e `state`;
- decisoes ficam auditadas em tabela propria;
- certos outcomes podem enfileirar notificacao assíncrona em `task_queue`.

## `civitas/admin_dashboard`

O contrato vive em `lib/civitas/admin_dashboard/`.

Capacidades estabilizadas:

- `DashboardSnapshot` e metricas de content/users/uploads/tasks/moderation;
- schema `admin_dashboard_snapshots`;
- `dashboard_snapshot_compute(...)`, `dashboard_snapshot_save(...)` e `dashboard_latest_snapshot_json(...)`;
- `dashboard_queue_view_json(...)`;
- `dashboard_recent_failures_json(...)`;
- task `admin_dashboard.refresh` registrada no scheduler.

Comportamento materializado:

- o snapshot e calculado sobre tabelas reais de pages, auth/session, media jobs, task queue e moderacao;
- o painel serve leitura rapida do ultimo snapshot persistido;
- filas e falhas permanecem ao vivo porque mudam em granularidade mais alta;
- o refresh periodico e `@every 10m`.

## Cobertura de testes

Cobertura da FASE 18:

- `18A`: 5 testes
- `18B`: 5 testes
- `18C`: 5 testes
- `18D`: 5 testes
- `18E`: 5 testes

Total da FASE 18: 25 testes de integracao.
