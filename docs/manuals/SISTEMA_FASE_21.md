# Sistema Fase 21

## Visão geral

A FASE 21 adiciona ao Civitas a camada de visualização e operação dos traces coletados na FASE 20. O foco da fase é permitir que um trace real de request deixe de ser apenas artefato de coleta e passe a ser:

1. visualizável como SVG animado;
2. navegável em um painel HTML local;
3. exportável como pacote offline por endpoint observado.

A fase é composta por três módulos:

- `trace_render`
- `trace_panel`
- `trace_export`

## Papel de cada módulo

### `trace_render`

Recebe um `Trace`, normaliza seus spans, calcula profundidade e duração relativa e produz um SVG autônomo com:

- cabeçalho;
- timeline;
- legenda;
- paleta por categoria;
- step-by-step;
- comparação lado a lado.

### `trace_panel`

Expõe o diagnóstico local via HTTP:

- lista traces recentes;
- filtra por path, status e duração;
- mostra detalhe com SVG embutido;
- oferece SVG puro;
- permite replay via `curl`.

### `trace_export`

Materializa uma documentação offline do que foi observado na aplicação:

- um SVG por endpoint;
- um HTML por endpoint;
- um índice navegável;
- um ZIP único compartilhável.

## Fluxo operacional

1. Um request real gera `.ctrace` e linha no índice SQLite.
2. O painel usa o índice para listar traces.
3. O detalhe resolve o `.ctrace` correspondente e renderiza o SVG.
4. A exportação percorre o store, agrupa por endpoint e escreve o ZIP.

## Contratos centrais

- o renderer não cria traces; ele apenas consome traces válidos;
- o painel lê o `TraceStore`, não varre arbitrariamente o disco;
- o ZIP exportado deve abrir offline;
- replay nunca muta o trace original;
- listagem, detalhe e exportação devem convergir para o mesmo dado de origem.

## Dados mostrados ao operador

O operador visualiza:

- `trace_id`
- método
- path
- status HTTP
- duração total
- quantidade de spans
- distribuição temporal dos spans
- categorias de subsistema

## Limites

- a fase não resolve tracing distribuído multi-serviço;
- a exportação não enumera endpoints nunca executados;
- replay é best-effort e não reproduz casos arbitrários de upload complexo.

## Saída material da fase

- `lib/civitas/trace_render/trace_render.cct`
- `lib/civitas/trace_panel/trace_panel.cct`
- `lib/civitas/trace_export/trace_export.cct`
- testes de integração em `tests/integration/fase_21`
- documentação desta fase em `docs/manuals`, `docs/specs` e `docs/release`

