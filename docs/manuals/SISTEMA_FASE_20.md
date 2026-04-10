# Manual Aprofundado do Sistema — FASE 20

## Visao geral

A FASE 20 fecha a primeira camada de observabilidade operacional do Civitas. O bloco `20A-20D` transforma a instrumentacao do CCT em um subsistema de diagnostico de request do framework:

- bootstrap e configuracao de instrumentacao por aplicacao;
- coleta por request com `trace_id` estavel e sampling controlado;
- persistencia local de traces em `.ctrace` e indexacao em SQLite;
- spans explicitos para SQL, cache, storage, midia, email, i18n, moderacao e tasks.

O resultado e um Civitas capaz de responder "o que aconteceu dentro deste request?" sem depender de APM externo, sem bloquear o hot path com I/O e sem adotar um protocolo de telemetria de terceiros.

## Modelo operacional da fase

O contrato estabilizado nesta fase e:

1. a aplicacao carrega `TraceConfig` a partir de settings e ambiente;
2. `trace_bootstrap(...)` aplica o modo de instrumentacao do CCT no processo atual;
3. `trace_collector_begin(...)` decide sampling, gera `trace_id`, limpa o buffer e abre o span raiz HTTP;
4. o request executa normalmente, com spans automaticos do runtime e spans explicitos dos modulos do Civitas;
5. `trace_collector_end(...)` fecha o span raiz, drena o buffer, escreve o `.ctrace` e opcionalmente responde com `x-trace-id`;
6. `trace_store` indexa os metadados do trace para consulta posterior por path, status, duracao e recencia.

Limites operacionais explicitos:

- a fase cobre tracing local por processo, nao distributed tracing entre servicos;
- o payload detalhado continua em arquivo `.ctrace`; o SQLite guarda apenas o indice;
- sampling reduz volume de escrita, mas requests com erro podem ser persistidos mesmo quando nao amostrados;
- a fase mede latencia e sequencia de spans, nao profiling de CPU ou heap.

## `civitas/trace_config` e `civitas/trace`

O contrato vive em `lib/civitas/trace_config/` e `lib/civitas/trace/`.

Capacidades estabilizadas:

- `TraceConfig` com `enabled`, `mode`, `sample_rate` e `trace_dir`;
- carga via config + env override;
- `trace_bootstrap(...)` para ligar/desligar a instrumentacao do CCT;
- helpers `civitas_span_router(...)`, `civitas_span_middleware(...)`, `civitas_span_handler(...)`;
- `trace_request_new_id(...)`, `trace_request_drain(...)`, `trace_request_flush_to_disk(...)`;
- captura em janela de testes via `trace_session_start/flush/stop`.

Semantica consolidada:

- o Civitas nao reimplementa o tracer do CCT; ele aplica semantica de framework sobre o runtime instrumentado;
- span helpers nomeiam as camadas do framework de forma consistente;
- o modo `full/minimal/off` e decidido no bootstrap da app, nao em cada handler.

## `civitas/trace_collector`

O contrato vive em `lib/civitas/trace_collector/trace_collector.cct`.

Capacidades estabilizadas:

- `TraceCollectorConfig`, `TraceRequestContext` e `TracePersistResult`;
- sampling deterministico por ordinal de request;
- bind do contexto de trace ao `RequestContext` por chave canônica;
- injecao opcional de header `x-trace-id`;
- persistencia em `.ctrace` por data;
- merge de `trace_id` em campos JSON para integracao com logging estruturado.

Semantica consolidada:

- `trace_collector` e a fronteira entre request HTTP e tracing do processo;
- requests bem-sucedidos nao amostrados podem sair sem arquivo, mas ainda sem corromper o buffer;
- erro HTTP continua observavel mesmo com sampling conservador.

## `civitas/trace_store`

O contrato vive em `lib/civitas/trace_store/trace_store.cct`.

Capacidades estabilizadas:

- `TraceStore`, `TraceRow`, `TraceResultSet`;
- schema `trace_index` com indices por duracao, status, path e created_at;
- `trace_store_index_trace(...)`;
- consultas `query_slowest`, `query_by_path`, `query_errors`, `query_recent`;
- `trace_store_load_trace(...)` para abrir o `.ctrace` real;
- poda por contagem maxima e por janela de horas.

Semantica consolidada:

- o store indexa metadados operacionais, nao duplica o trace completo no banco;
- a consulta de detalhe le o arquivo apenas sob demanda;
- retencao apaga indice e arquivo de forma coordenada.

## Spans explicitos de dominio

O contrato vive em `lib/civitas/trace/trace_sql.cct`, `trace_cache.cct`, `trace_storage.cct`, `trace_media.cct`, `trace_mail.cct`, `trace_i18n.cct`, `trace_moderation.cct` e `trace_task.cct`.

Capacidades estabilizadas:

- spans de SQL para exec, scalar e statement preparado;
- spans de cache com hit/miss e resultado;
- spans de storage com path, tipo e bytes;
- spans de FFmpeg/probe para pipeline de midia;
- spans de mailer por template e destinatario;
- spans de batch i18n;
- spans de moderacao e enqueue de task.

Semantica consolidada:

- cada subsistema relevante do framework passa a deixar trilha visivel dentro do trace da request;
- spans explicitam atributos operacionais minimos sem depender de parsing posterior do SQL ou de logs textuais;
- o contrato continua seguro quando a instrumentacao esta desligada, porque `instrument_*` vira no-op.

## Fluxo canonico integrado

1. `POST /admin/rebuild-homepage` entra no servidor;
2. `trace_collector_begin(...)` abre o span raiz `POST /admin/rebuild-homepage`, gera `trace_id` e prende o contexto no request;
3. o handler consulta SQLite com `trace_sql_prepare(...)`, tenta cache com `trace_cache_begin(...)`, grava artefato temporario com `trace_storage_write(...)` e enfileira uma task com `trace_task_enqueue_begin(...)`;
4. se o fluxo dispara midia, email ou lote editorial, os wrappers especificos deixam spans filhos adicionais no mesmo trace;
5. `trace_collector_end(...)` fecha o span HTTP, persiste o `.ctrace` e devolve `x-trace-id`;
6. `trace_store_index_trace(...)` permite encontrar depois esse request entre os mais lentos ou os que falharam;
7. o operador abre o `.ctrace` correspondente para ver a arvore completa de spans.

## Cobertura de testes

Cobertura da FASE 20:

- `20A`: 5 testes
- `20B`: 5 testes
- `20C`: 5 testes
- `20D`: 5 testes

Total da FASE 20: 20 testes de integracao.
