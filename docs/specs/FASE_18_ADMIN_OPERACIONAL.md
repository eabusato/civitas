# FASE 18 — Admin Operacional

## Escopo consolidado

O bloco `18A-18E` estabiliza a camada administrativa do Civitas em cinco partes integradas:

- registry de modelos, listagem, CRUD, bulk e auditoria;
- edicao inline de relacoes filho;
- extensibilidade com computed fields builtin, acoes customizadas, permissoes, widgets e export CSV;
- moderacao operacional com fila e historico;
- dashboard administrativo com snapshots, filas e falhas recentes.

## Contratos implementados

### `civitas/admin`

- `AdminModelConfig`, `AdminRegistry`, `AdminListQuery`, `AdminListResult`, `AdminLookup`, `AdminBulkResult`;
- `admin_register(...)` com persistencia em `admin_model_registry`;
- `admin_list(...)`, `admin_get_one(...)`, `admin_create(...)`, `admin_update(...)`, `admin_delete(...)`;
- `admin_bulk_action(...)`;
- manifesto de rotas via `admin_model_config_generate_routes(...)` e `admin_register_routes(...)`;
- auditoria em `admin_audit_log`.

Semantica consolidada:

- operacoes usam `DbHandle` e SQL parametrizado;
- filtros, busca e ordenacao respeitam a allowlist do config;
- permissao e resolvida por prefixo de acao do modelo.

### `civitas/admin` inline

- `AdminInlineConfig`;
- schema `admin_inline_registry`;
- `admin_inline_register(...)`, `admin_inline_count(...)`, `admin_inline_list_for_parent(...)`;
- `admin_inline_save_one(...)`, `admin_inline_delete_one(...)` e `admin_inline_submit_all(...)`.

Semantica consolidada:

- o child sempre e reconciliado contra o parent via `fk_field`;
- a submissao completa e transacional no `DbHandle`.

### extensibilidade (`18C`)

- `admin_computed_*`, `admin_permissions_*`, `admin_action_*`, `admin_widget_*`, `admin_export_csv(...)`;
- computed fields persistidos em `admin_computed_fields`;
- permissoes por modelo/acao em `admin_permissions`;
- acoes customizadas em `admin_custom_actions`;
- widgets em `admin_widgets`.

Semantica consolidada:

- o computed field validado na fase usa resolvedor builtin do modulo;
- permissao falha fechada quando nao existe regra positiva;
- export oficial da fase e CSV.

### `civitas/admin_moderation`

- `ModerationItem`, `ModerationDecision`, `ModerationBulkResult`;
- `moderation_item_create(...)`, `moderation_queue_list(...)`, `moderation_history_json(...)`;
- `moderation_decide(...)` e `moderation_bulk_apply(...)`;
- schema `moderation_items` e `moderation_decisions`.

Semantica consolidada:

- fila segmentada por `kind` + `state`;
- decisao persiste historico antes do efeito assíncrono opcional;
- bulk e best-effort com resultado agregado.

### `civitas/admin_dashboard`

- `DashboardSnapshot` e metricas agregadas;
- `admin_dashboard_snapshots`;
- `dashboard_snapshot_compute(...)`, `dashboard_snapshot_save(...)`, `dashboard_latest_snapshot_json(...)`;
- `dashboard_queue_view_json(...)` e `dashboard_recent_failures_json(...)`;
- callback `admin_dashboard.refresh`.

Semantica consolidada:

- snapshot usa tabelas reais do sistema e nao replica dados em schema paralelo;
- refresh recorrente depende de `17A/17B`, nao roda inline no request;
- dashboard mistura leitura persistida e visoes ao vivo de filas/falhas.

## Fluxo canonico integrado

1. a aplicacao registra um modelo com `admin_register(...)`;
2. o registry persiste config e gera manifesto de rotas administrativas;
3. o operador lista, filtra, cria, edita ou deleta registros pelo contrato do admin core;
4. se houver relacionamento filho, a camada inline persiste os children na mesma unidade de trabalho;
5. a camada de extensibilidade aplica campo calculado builtin, permissao por acao, acao customizada, widget ou export CSV;
6. moderacao atua sobre itens pendentes e, quando necessario, enfileira efeito assíncrono;
7. o dashboard consolida o estado operacional a partir das tabelas reais e expõe snapshot, filas e falhas.

## Limites operacionais

- a fase nao entrega uma UI HTML completa e estilizada do admin;
- computed fields nao executam callbacks arbitrarias tipadas nesta materializacao;
- dashboard nao cobre metricas de infraestrutura externa;
- moderacao cobre fila/historico/decisao, nao um policy engine completo.

## Cobertura

O bloco fecha com 25 testes de integracao:

- 5 em `18A`
- 5 em `18B`
- 5 em `18C`
- 5 em `18D`
- 5 em `18E`

## Estado esperado do gate

O bloco `18A-18E` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `18A-18E`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
