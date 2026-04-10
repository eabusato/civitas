# Manual Aprofundado do Sistema — FASE 17

## Visao geral

A FASE 17 consolida o subsistema de execucao em background do Civitas. O bloco `17A-17E` entrega a camada que retira trabalho pesado do request, torna execucao periodica parte do framework e fecha o ciclo operacional com observabilidade, retencao e efeitos persistidos em banco e filesystem.

O bloco entrega:

- `civitas/tasks` para fila persistente, retry, dead letter e historico de attempts;
- `civitas/scheduled` para decidir quando jobs periodicos devem virar tasks;
- `civitas/retention` para limpar historicos e residuos com criterio verificavel;
- `civitas/media_jobs` para derivar midia fora do request com fallback e aprovacao;
- `civitas/editorial_jobs` para traducao por adapter, sitemap, feed, rankings e counters.

## Modelo operacional da fase

O contrato operacional estabilizado nesta fase e:

1. o processo web persiste estado e enfileira trabalho;
2. o worker roda em processo separado e executa callbacks registradas;
3. o scheduler roda como loop operacional que apenas decide quando enfileirar;
4. jobs de midia e editorial sao consumidores de `17A`, nao um sistema paralelo;
5. a retencao remove so o que ja esta inequivocamente expirado ou concluido.

Limites operacionais explicitos:

- timeout forte por interrupcao de processo vale apenas para subcomandos externos integrados via `cct/process`;
- task CCT pura usa timeout logico por visibilidade/claim/retry, nao interrupcao preemptiva;
- o worker e um executavel ou modo operacional separado, nao uma thread prometida pelo framework;
- o scheduler expoe `ScheduleLockScope`, mas a materializacao validada nesta fase permanece backend-neutral e centrada em coordenacao local/politicas de fila.

## `civitas/tasks`

O contrato vive em `lib/civitas/tasks/tasks.cct`.

Capacidades estabilizadas:

- `TaskState`, `TaskOutcome`, `TaskError`, `TaskRetryPolicy`, `TaskConfig`, `TaskEnqueueOptions`, `TaskRecord`, `TaskAttemptRecord`, `TaskWorkerRun`;
- `task_config_default(...)`, `task_retry_policy_default(...)` e `task_enqueue_options_default(...)`;
- registry de callbacks com `task_registry_new(...)`, `task_register(...)`, `task_registry_find(...)` e `task_registry_free(...)`;
- schema `task_queue`, `task_attempts` e `task_dead_letters` com `tasks_schema_up(...)` e `tasks_schema_down(...)`;
- enfileiramento canonico via `task_enqueue_json(...)`;
- claim, atualizacao e recuperacao operacional via `task_claim_next(...)`, `task_update_state(...)` e `task_recover_visible_timeouts(...)`;
- loop unario de worker via `task_worker_run_once(...)`;
- observabilidade minima via `task_attempt_start(...)`, `task_attempt_finish(...)`, `task_find_by_id(...)` e `task_count_by_state(...)`.

Ciclo de vida efetivo:

- `queued` quando a task entra pronta para claim;
- `running` quando um worker a reivindica;
- `retry` quando o callback falha de forma recuperavel e recebe nova visibilidade futura;
- `done` quando o callback conclui e persiste `result_json`;
- `dead` quando excede tentativas ou falha terminalmente, com espelhamento em `task_dead_letters`;
- `cancelled` como estado reservado para cancelamento explicito.

Limites operacionais:

- o payload canonico desta fase e `VERBUM` serializado, normalmente JSON ou string estruturada por convenio do modulo consumidor;
- timeout de ritual puro e recuperacao por claim/visibilidade, nao kill assíncrono;
- a fila e persistente em banco via `DbHandle`, com backend real resolvido fora do modulo.

## `civitas/scheduled`

O contrato vive em `lib/civitas/scheduled/scheduled.cct`.

Capacidades estabilizadas:

- `ScheduleKind`, `SchedulePolicy`, `ScheduleLockScope`, `ScheduleSpec`, `ScheduledJob`, `ScheduledRun`, `SchedulerConfig`;
- parse de `@every Ns|m|h|d` e cron de cinco campos;
- `scheduled_register_interval(...)` e `scheduled_register_cron(...)`;
- `scheduled_enable(...)`, `scheduled_disable(...)` e `scheduled_set_payload(...)`;
- `schedule_next_run(...)` e `scheduler_tick(...)`;
- historico operacional em `scheduled_runs` com `scheduled_schema_up(...)`.

Politicas estabilizadas:

- `skip_if_running`: nao enfileira nova task se existir task ativa para o job;
- `enqueue_always`: sempre gera nova task quando o job vence;
- `replace_pending`: remove pendencias nao iniciadas antes de enfileirar a nova.

Limites operacionais:

- o scheduler decide quando enfileirar; ele nao executa o trabalho final;
- o schema persiste `next_run_at_unix`, `last_run_at_unix` e `last_result_json`;
- o contrato de `lock_scope` existe, mas o caminho validado e materializado nesta fase para a suite integrada e o fluxo backend-neutral/local.

## `civitas/retention`

O contrato vive em `lib/civitas/retention/retention.cct`.

Capacidades estabilizadas:

- `RetentionTarget`, `RetentionConfig`, `RetentionReport`, `RetentionRun`;
- schema `retention_runs` via `retention_schema_up(...)`;
- relatórios persistidos com `retention_report_write(...)`;
- purge por dominio para:
  - `task_attempts`
  - `task_dead_letters`
  - `scheduled_runs`
  - `media_jobs`
  - `editorial_job_runs`
  - tmp directory por idade

Politica efetiva desta fase:

- cada alvo possui cutoff proprio em segundos no `RetentionConfig`;
- a limpeza e batch-oriented por `batch_size`;
- o relatorio traz `scanned_count`, `deleted_count`, `kept_count`, `error_count` e `details_json`.

Limites operacionais:

- alvos como sessao, auth flow, cache e trace existem no enum/config como superficie de fase, mas a materializacao desta rodada cobre explicitamente os targets exercidos pelos modulos de background e o tmp dir;
- a limpeza nao tenta inferir por suposicao se algo “parece” orfao; ela remove apenas o que o corte configurado e o estado concluido tornam elegivel.

## `civitas/media_jobs`

O contrato vive em `lib/civitas/media_jobs/media_jobs.cct`.

Capacidades estabilizadas:

- `MediaJobState`, `MediaJobKind`, `MediaJobPolicy`, `MediaJobRecord`;
- schema `media_jobs` com dedupe por `input_hash + job_kind + output_variant + state`;
- `media_job_enqueue(...)`, `media_job_find(...)`, `media_job_mark_approved(...)` e `media_jobs_find_active_duplicate(...)`;
- callback canônica `media_jobs_task_callback(...)` registrada como task `media.process`;
- serializacao de resultado via `media_job_result_json(...)`.

Comportamento materializado:

- o job persiste descriptor, source path, variant e target output path;
- o worker copia o original para o derivado de saida como comportamento canonico desta fase;
- `require_approval` move o job para `waiting_approval` ate `media_job_mark_approved(...)`;
- `allow_fallback` permite usar `fallback_path` quando a origem nao estiver disponivel;
- falha sem fallback resulta em `failed` no job e dead letter na task se esgotadas as tentativas.

Limites operacionais:

- esta fase fecha o pipeline assíncrono e o contrato de estado, nao um motor final de transcode multimidia completo;
- `no_upscale` existe no policy como parte da superficie normativa, mas nao altera a callback simplificada desta materializacao;
- o original e preservado; o derivado e escrito em `output_path`.

## `civitas/editorial_jobs`

O contrato vive em `lib/civitas/editorial_jobs/editorial_jobs.cct`.

Capacidades estabilizadas:

- `EditorialJobKind`, `TranslationProviderKind`, `EditorialAutomationConfig`, `EditorialJobRun`;
- schema para `editorial_job_runs`, `editorial_translations`, `editorial_rankings` e `editorial_counters`;
- traducao por adapter com `TRANSLATION_PROVIDER_PROCESS` via `run_with_input(...)`;
- `editorial_enqueue_translate(...)`, `editorial_enqueue_sitemap(...)`, `editorial_enqueue_feed(...)`, `editorial_enqueue_rankings(...)`, `editorial_enqueue_counters(...)`;
- renderizacao deterministica de sitemap e feed;
- recomputacao de rankings a partir de `civitas_view_counters`;
- recomputacao de counters a partir de `civitas_reactions`.

Garantias implementadas:

- traducao respeita `human_locked` e nao sobrescreve revisao humana existente;
- ranking e counters sao recomputados por batch integral, limpando a tabela materializada antes da nova carga;
- sitemap e feed sao reconstruidos integralmente a cada rodada;
- cada callback persiste trilha em `editorial_job_runs`.

Limites operacionais:

- provider de traducao embutido e so `none` ou `process`;
- invalidacao de cache e efeitos SEO externos ficam a cargo da camada chamadora ou de fases posteriores;
- o output desta fase e reproduzivel e auditavel, sem publicacao “parcial” fingida como sucesso global.

## Gate integrado da fase

O gate operacional desta fase precisa demonstrar, no minimo:

1. enqueue de task com dedupe e retry;
2. scheduler disparando task periodica sem executar o trabalho inline;
3. media job produzindo derivado fora do request;
4. editorial job gerando sitemap/feed ou recomputando agregados;
5. retention limpando historicos concluidos sem remover artefato valido.

Na suite atual isso fica coberto por:

- `17A`: 5 testes
- `17B`: 5 testes
- `17C`: 6 testes
- `17D`: 5 testes
- `17E`: 7 testes

Total da FASE 17: 28 testes de integracao.
