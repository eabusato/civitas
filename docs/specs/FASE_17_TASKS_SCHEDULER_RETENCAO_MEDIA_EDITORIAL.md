# FASE 17 — Tasks, Scheduler, Retencao, Midia e Automacao Editorial

## Escopo consolidado

O bloco `17A-17E` estabiliza a camada de execucao em background do Civitas em cinco partes integradas:

- fila persistente com retry, observabilidade e dead letter;
- scheduler recorrente que enfileira trabalho por cron ou intervalo;
- retencao segura de historicos e residuos operacionais;
- pipeline de midia pesado executado fora do request;
- automacoes editoriais para traducao, sitemap, feed, rankings e counters.

O objetivo da fase e retirar trabalho pesado do caminho síncrono sem abrir um segundo sistema operacional paralelo e sem depender de scripts soltos fora do contrato do framework.

## Contratos implementados

### `civitas/tasks`

- `TaskState`, `TaskOutcome`, `TaskError`, `TaskRetryPolicy`, `TaskConfig`, `TaskEnqueueOptions`, `TaskRecord`, `TaskAttemptRecord`, `TaskWorkerRun`;
- fila persistida em `task_queue`;
- historico de tentativas em `task_attempts`;
- dead letter em `task_dead_letters`;
- dedupe por `dedupe_key`;
- callback registry explicito;
- worker unario com `task_worker_run_once(...)`;
- recuperacao de visibility timeout com `task_recover_visible_timeouts(...)`.

Semantica consolidada:

- sucesso persiste `result_json` e fecha em `done`;
- erro recuperavel agenda `retry` com backoff;
- erro terminal ou estouro de tentativas move para dead letter;
- timeout de ritual puro e logico/operacional, nao preemptivo.

### `civitas/scheduled`

- `ScheduleKind`, `SchedulePolicy`, `ScheduleLockScope`, `ScheduledJob`, `ScheduledRun`, `SchedulerConfig`;
- parse de cron de cinco campos e de intervalos `@every`;
- `scheduled_jobs` como fonte de verdade da agenda;
- `scheduled_runs` como trilha de tick e enqueue;
- `scheduler_tick(...)` para decidir quando criar task;
- politicas `skip_if_running`, `enqueue_always` e `replace_pending`.

Semantica consolidada:

- scheduler decide e enfileira; worker executa;
- `next_run_at_unix` e `last_run_at_unix` sao persistidos;
- o lock canônico validado nesta rodada e o caminho local/backend-neutral, mesmo com `lock_scope` exposto no contrato.

### `civitas/retention`

- `RetentionTarget`, `RetentionConfig`, `RetentionReport`, `RetentionRun`;
- `retention_runs` para relatorio persistido;
- purge implementado para `task_attempts`, `task_dead_letters`, `scheduled_runs`, `media_jobs`, `editorial_job_runs` e tmp dir.

Semantica consolidada:

- limpeza sempre por cutoff configuravel e batch;
- so remove itens concluidos/expirados;
- nao tenta deduzir “orfao” por heuristica fraca;
- deixa relatorio com contagens objetivas.

### `civitas/media_jobs`

- `MediaJobState`, `MediaJobKind`, `MediaJobPolicy`, `MediaJobRecord`;
- tabela `media_jobs` com dedupe operacional;
- enqueue para task `media.process`;
- callback que consome `UploadDescriptor`, le origem e escreve derivado;
- `waiting_approval` para fluxo de aprovacao;
- fallback por arquivo alternativo controlado por policy.

Semantica consolidada:

- o original nao e destruido;
- o derivado so e promovido ao estado `done` quando o arquivo final foi escrito;
- a combinacao `descriptor.hash + kind + variant` define idempotencia de intencao de trabalho;
- falha persistida no job e na task continuam observaveis.

### `civitas/editorial_jobs`

- `EditorialJobKind`, `TranslationProviderKind`, `EditorialAutomationConfig`, `EditorialJobRun`;
- tabelas `editorial_job_runs`, `editorial_translations`, `editorial_rankings`, `editorial_counters`;
- traducao por adapter de processo;
- geracao de sitemap XML e feed XML;
- recomputacao de ranking e contadores.

Semantica consolidada:

- traducao usa provider configuravel e nao recurso “magico” embutido;
- `human_locked` impede overwrite automatico;
- sitemap e feed sao inteiramente reproduziveis;
- ranking e counter sao materializados por reload completo.

## Fluxo canonico integrado

Fluxo canônico validado na fase:

1. uma acao do dominio ou agenda cria task via `task_enqueue_json(...)`;
2. o scheduler pode enfileirar automaticamente quando `next_run_at_unix` vence;
3. o worker registra attempt, executa callback e persiste `result_json` ou erro;
4. midia pesada gera derivado fora do request e atualiza `media_jobs`;
5. automacao editorial gera output ou tabela materializada fora do request;
6. historicos antigos podem ser limpos por retention sem afetar o output valido.

Esse fluxo aparece de forma integrada no gate de `17E`, que:

- cria pagina e contadores sociais;
- enfileira e executa derivado de midia;
- agenda sitemap via scheduler;
- executa recomputacao editorial;
- purga `scheduled_runs` antigos por retention.

## Limites operacionais

- o worker e um processo operacional separado do web process;
- `cct/process` e usado apenas para integração com executavel externo, especialmente traducao por adapter;
- nao existe cancelamento preemptivo de ritual CCT puro em andamento;
- a fase nao implementa orquestrador distribuido generico;
- a fase nao fecha um transcode multimidia completo, e sim a infraestrutura assíncrona, auditavel e idempotente para esse trabalho.

## Cobertura

O bloco fecha com 28 testes de integracao:

- 5 em `17A`
- 5 em `17B`
- 6 em `17C`
- 5 em `17D`
- 7 em `17E`

## Estado esperado do gate

O bloco `17A-17E` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `17A-17E`;
- um gate integrado da fase verde em `17E`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
