# FASE 17 Release Notes

## Entregas

- `lib/civitas/tasks/` com fila persistente, registry de callbacks, attempts, retry, dead letter e worker unario;
- `lib/civitas/scheduled/` com cron/interval, politicas de enqueue e historico de `scheduled_runs`;
- `lib/civitas/retention/` com purge por dominio, relatórios de limpeza e batch size configuravel;
- `lib/civitas/media_jobs/` com derivacao assíncrona, dedupe por hash/variant, aprovacao e fallback controlado;
- `lib/civitas/editorial_jobs/` com traducao por adapter, sitemap, feed, rankings, counters e trilha de execucao;
- suporte compartilhado de testes em `tests/integration/fase_17/support/`;
- expansao do runner unico para cobrir `17A-17E`.

## Decisoes relevantes

- o modelo operacional foi estabilizado em torno de web process + worker process + scheduler process logico, sem prometer threads internas ou cancelamento preemptivo que o CCT nao expoe;
- o scheduler materializado e validado nesta rodada usa coordenacao backend-neutral/local e politicas de fila; `ScheduleLockScope` permanece na superficie da API, mas o caminho coberto pela suite nao depende de advisory lock PostgreSQL direto;
- `media_jobs` fecha a infraestrutura assíncrona e os estados operacionais do pipeline, mantendo callback de derivacao propositalmente simples para nao antecipar um motor de transcode completo fora do escopo;
- `editorial_jobs` trata traducao como adapter externo via processo, respeitando `human_locked` e evitando fingir automacao “inteligente” nativa onde o framework so deve coordenar trabalho e persistencia;
- `retention` foi limitada aos alvos realmente materializados pela fase e ao tmp dir, evitando apagar por suposicao dados de outros dominios ainda sem criterio operacional suficientemente forte.

## Cobertura de testes

A FASE 17 adiciona:

- 5 testes em `17A`
- 5 testes em `17B`
- 6 testes em `17C`
- 5 testes em `17D`
- 7 testes em `17E`

Total da FASE 17: 28 testes de integracao.

## Estado do gate

O bloco `17A-17E`, fechando a FASE 17, so e considerado concluido com:

- `17A` verde isoladamente;
- `17B` verde isoladamente;
- `17C` verde isoladamente;
- `17D` verde isoladamente;
- `17E` verde isoladamente, incluindo o gate integrado da fase;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
