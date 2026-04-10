# FASE 26 Release Notes

## Entregue

- `civitas/bench` com benchmark in-process, percentis, export/import JSON e histórico SQLite
- `civitas/profiler` com middleware por request, top rituais, detecção de N+1, persistência e leitura recente de profiles
- `civitas/memory_profiler` com snapshots de contadores do runtime CCT, deltas por request e suspeita de leak
- `civitas/perf_report` com HTML auto-contido, `hotspots.ctrace` e renderização do sigilo animado real do CCT

## Ajustes estruturais

- o `middleware` continua compatível com callbacks existentes, mas agora suporta `ctx_ref` por binding para profiler e memory profiler
- o relatório deixa de depender só de dados sintéticos e passa a aceitar profiles reconstruídos do SQLite
- o caminho de sigilo da fase usa o renderer real do CCT, preservando `trace-packet` e `animateMotion`

## Cobertura

Foram adicionados 16 testes de integração:

- `26A`: 5
- `26B`: 5
- `26C`: 5
- `26D`: 6

## Impacto

A FASE 26 fecha a primeira camada operacional de performance do Civitas. O framework passa a conseguir medir request real no roteador, persistir profiles úteis, detectar suspeita de vazamento de memória e materializar um relatório compartilhável com sigilo animado completo para análise local.
