# FASE 26 — Profiling e Benchmark

## Objetivo

Entregar ferramentas nativas para medir throughput, localizar hotspots de CPU/query, observar pressão de memória por request e gerar um relatório compartilhável com sigilo animado real do CCT.

## Módulos

- `lib/civitas/bench/bench.cct`
- `lib/civitas/profiler/profiler.cct`
- `lib/civitas/memory_profiler/memory_profiler.cct`
- `lib/civitas/perf_report/perf_report.cct`

## Contratos implementados

### 26A

- `BenchConfig`, `BenchResult`, `BenchComparison` e `BenchHistoryEntry`
- `bench_run_inprocess(...)`
- `bench_compare(...)`
- `bench_result_to_json/from_json`
- `bench_history_insert/latest/count`

### 26B

- `ProfilerState`, `RequestProfile`, `RitualStat`, `QueryStat` e `N1Report`
- middleware de profiling sobre `cct/instrument`
- persistência em `request_profiles`
- `profiler_top_rituals(...)`
- `profiler_read_recent(...)`

### 26C

- `MemSnapshot`, `MemDelta`, `MemReport` e `MemProfilerState`
- `mem_snap_begin()` / `mem_snap_end(...)`
- middleware de memória por request
- persistência em `mem_deltas`
- `mem_profiler_report(...)`

### 26D

- `PerfReport`
- `perf_report_build(...)`
- `perf_report_write_html(...)`
- `perf_report_sigilo_annot(...)`
- `perf_report_sigilo_render(...)`

## Contratos operacionais importantes

- benchmarking é in-process e usa o roteador real, não um mock do handler;
- profiling usa spans reais do runtime CCT;
- memory profiling usa os contadores públicos `mem_instr_*` do runtime do CCT, em vez de estimativa por spans;
- o sigilo do relatório é renderizado pelo `trace_render` do Civitas, que chama `cct sigilo trace render` e produz o SVG animado completo do CCT.

## Limites explícitos

- o benchmark não substitui teste de carga externo com rede real;
- os contadores de memória são globais por processo e precisam de snapshot por request;
- o relatório HTML é estático e não introduz painel interativo novo;
- os hotspots renderizados em `.ctrace` representam os rituais principais do profile selecionado, não uma reconstrução integral do código-fonte da aplicação.

## Cobertura

Foram adicionados 16 testes de integração:

- `26A`: 5
- `26B`: 5
- `26C`: 5
- `26D`: 6

## Gate

- `cct-host test fase26_26a_ --project .`
- `cct-host test fase26_26b_ --project .`
- `cct-host test fase26_26c_ --project .`
- `cct-host test fase26_26d_ --project .`
- `bash tests/run_tests.sh 26A 26B 26C 26D`

Todos precisam ficar verdes antes do gate completo da suíte.
