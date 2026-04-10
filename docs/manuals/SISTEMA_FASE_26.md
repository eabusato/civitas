# Sistema Fase 26

## Escopo

A FASE 26 adiciona a camada de diagnóstico de performance do Civitas em quatro módulos complementares:

- `civitas/bench` para benchmark in-process sem socket, reaproveitando `test_client` e `router_dispatch(...)`;
- `civitas/profiler` para análise de spans de CPU/cache/DB, detecção de N+1 e persistência de profiles por request;
- `civitas/memory_profiler` para snapshots de contadores globais de memória do runtime CCT e deltas por request;
- `civitas/perf_report` para relatório HTML auto-contido, emissão de `.ctrace` de hotspots e renderização do sigilo animado real do CCT.

O bloco fecha o ciclo local de diagnóstico: medir latência, localizar hotspots, verificar pressão de memória e materializar tudo num artefato compartilhável.

## Arquitetura

### `civitas/bench`

- `BenchConfig` modela rota, método, body, headers, `n_requests`, timeout, warmup e concorrência declarada;
- `bench_run_inprocess(...)` executa requests reais no roteador, sem abrir socket e sem engine externa;
- `BenchResult` consolida `min`, `max`, média, `p50`, `p95`, `p99`, throughput e contagem de erro;
- `bench_compare(...)` produz delta de throughput e percentis entre duas execuções;
- `bench_history_*` persiste baselines em SQLite.

### `civitas/profiler`

- o middleware liga `cct/instrument` em `INSTR_MODE_FULL`, abre `LocalContext`, emite span HTTP raiz e drena o buffer ao fim da request;
- `profiler_analyze(...)` agrupa spans por ritual e por template SQL;
- `N1Report` marca queries repetidas acima do limiar configurado;
- `profiler_persist(...)` grava `request_profiles` com `rituals_json`, `queries_json` e `n1_json`;
- `profiler_read_recent(...)` reconstrói os profiles persistidos para consumo posterior pelo relatório.

### `civitas/memory_profiler`

- `mem_snap_begin()` e `mem_snap_end(...)` leem `mem_instr_alloc_count`, `mem_instr_alloc_bytes`, `mem_instr_free_count`, `mem_instr_live_count` e `mem_instr_live_bytes`;
- o middleware envolve a request inteira e persiste `mem_deltas` com rota, `request_id`, alloc/free delta, live delta e suspeita de leak;
- `mem_profiler_report(...)` agrega média de alocações por request, média de bytes por request, pico de `live_bytes_delta` e número de suspeitas.

### `civitas/perf_report`

- `perf_report_build(...)` consolida benchmark, profiles e memória num artefato único;
- `perf_report_write_html(...)` produz HTML auto-contido, sem JS externo ou assets separados;
- `perf_report_sigilo_annot(...)` escreve `hotspots.ctrace`;
- `perf_report_sigilo_render(...)` usa `trace_render_to_file(...)` e, portanto, gera o sigilo animado completo do CCT, com `trace-packet`, `animateMotion` e a visualização de rotas, não uma timeline simplificada.

## Contratos implementados

### Benchmark

- benchmark in-process baseado no roteador real;
- JSON export/import de `BenchResult`;
- histórico SQLite por label;
- comparação antes/depois com delta percentual.

### CPU/query profiling

- persistência de profile por request em `request_profiles`;
- top rituais por tempo total;
- detecção de N+1 por repetição de template SQL;
- reconstrução dos profiles persistidos via `profiler_read_recent(...)`.

### Memory profiling

- leitura dos contadores públicos de memória expostos pelo runtime do CCT;
- relatório por delta de request, não por estimativa textual;
- alerta e header `x-civitas-mem-leak` quando o `live_count_delta` fica acima do limiar;
- agregação SQLite em `mem_deltas`.

### Perf report e sigilo

- relatório HTML auto-contido com seções de benchmark, rituais, N+1, memória e recomendações;
- comparação opcional com benchmark anterior;
- geração de `.ctrace` sintético de hotspots;
- renderização do sigilo real do CCT sobre esse `.ctrace`.

## Limites operacionais

- os contadores de memória são globais por processo; o contrato por request é obtido por snapshot antes/depois do handler;
- `realloc` segue a semântica atual do runtime do CCT: conta como uma nova alocação e um free lógico, preservando `live_count` e ajustando `live_bytes`;
- o benchmark atual é in-process; ele mede o custo do framework e do código do usuário sem incluir latência de rede real;
- o relatório HTML usa o primeiro profile carregado como amostra principal da seção de rituais/N+1, sem agregar múltiplas rotas numa tabela única.

## Gate da fase

O bloco fecha quando:

- `26A` valida benchmark in-process, headers, export/import JSON, comparação e histórico SQLite;
- `26B` valida análise de spans, persistência de profile, middleware real e header de N+1;
- `26C` valida snapshots de memória, suspeita de leak, persistência SQLite, agregação e middleware real por request;
- `26D` valida HTML, comparação, reconstrução de profiles persistidos, emissão de `hotspots.ctrace` e renderização do sigilo animado real do CCT;
- `tests/run_tests.sh 26A 26B 26C 26D` fica verde.

No estado implementado, a FASE 26 acrescenta 16 testes de integração e fecha a primeira camada canônica de profiling e benchmark do Civitas sem exigir infraestrutura externa.
