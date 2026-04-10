# FASE 20 — Sigilo Vivo, Instrumentacao e Trace de Request

## Escopo consolidado

O bloco `20A-20D` estabiliza o subsistema de observabilidade de request do Civitas em quatro partes integradas:

- configuracao e bootstrap de instrumentacao sobre `cct/instrument`;
- collector por request com sampling, `trace_id`, `.ctrace` e integracao com logging;
- store SQLite local para indexacao e diagnostico operacional;
- wrappers de spans explicitos para os principais subsistemas do framework.

## Contratos implementados

### `civitas/trace_config` e `civitas/trace`

- `TraceConfig` com carga por settings e variaveis de ambiente;
- `trace_bootstrap(...)` para aplicar `INSTR_MODE_OFF/MINIMAL/FULL`;
- helpers de spans do framework (`router`, `middleware`, `handler`);
- `trace_request_drain(...)`, `trace_request_file_path(...)`, `trace_request_flush_to_disk(...)`;
- captura de sessao para testes via `trace_session_start/flush/stop`.

Semantica consolidada:

- o Civitas assume o runtime do CCT como base do tracing;
- a camada do framework adiciona nomes, ciclo de request e persistencia;
- a escrita em disco continua fora do hot path da chamada instrumentada em si.

### `civitas/trace_collector`

- `TraceCollectorConfig`, `TraceRequestContext`, `TracePersistResult`;
- sampling deterministico por request ordinal;
- bind do contexto de trace no `RequestContext`;
- header `x-trace-id` opcional;
- persistencia de traces amostrados e de erros em `.ctrace`;
- fusao de `trace_id` com payload JSON de log estruturado.

Semantica consolidada:

- o collector decide quando observar e como materializar o trace;
- request nao amostrado nao deixa lixo de buffer nem arquivo parcial;
- erro HTTP continua rastreavel com prioridade operacional.

### `civitas/trace_store`

- schema `trace_index`;
- `trace_store_open/close/schema_up`;
- `trace_store_index_trace(...)`;
- queries `slowest`, `by_path`, `errors`, `recent`;
- carregamento do trace completo por `trace_id`;
- podas por contagem e por janela temporal.

Semantica consolidada:

- o banco e um indice consultavel, nao o payload detalhado dos spans;
- o arquivo `.ctrace` e a fonte de verdade do trace completo;
- retencao preserva coerencia entre indice e arquivo.

### Wrappers de spans de dominio

- `trace_sql_*` para SQLite;
- `trace_cache_*` para cache e resultado/hit;
- `trace_storage_*` para file I/O;
- `trace_media_*` para probe/transcode;
- `trace_mail_*` para envio de email;
- `trace_i18n_*` para lotes de traducao;
- `trace_moderation_*` e `trace_task_*` para fluxo operacional.

Semantica consolidada:

- a fase torna visiveis os principais gargalos reais do framework;
- wrappers preservam o comportamento funcional quando a instrumentacao esta desativada;
- atributos minimos por categoria ficam normalizados.

## Fluxo canonico integrado

1. uma request entra no pipeline HTTP;
2. o collector gera `trace_id`, abre o span raiz e injeta o contexto;
3. o handler e os modulos do framework emitem spans automaticos e explicitos;
4. a resposta fecha o span HTTP, escreve `.ctrace` e opcionalmente retorna `x-trace-id`;
5. o indice SQLite recebe metadados de metodo, path, status, duracao, usuario e arquivo;
6. consultas operacionais encontram rapidamente erros, lentidoes e requests recentes;
7. a leitura detalhada do `.ctrace` explica a arvore de spans daquele request.

## Limites operacionais

- sem OpenTelemetry/OTLP;
- sem UI grafica nativa de traces nesta fase;
- sem tracing distribuido multi-servico;
- sem profiling de CPU ou heap;
- sem parsing semantico avancado do SQL alem dos atributos registrados pelo wrapper.

## Cobertura

O bloco fecha com 20 testes de integracao:

- 5 em `20A`
- 5 em `20B`
- 5 em `20C`
- 5 em `20D`

## Estado esperado do gate

O bloco `20A-20D` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `20A-20D`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
