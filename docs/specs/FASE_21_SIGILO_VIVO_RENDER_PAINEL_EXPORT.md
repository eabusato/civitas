# FASE 21 — Sigilo Vivo: Render, Painel e Export

## Escopo

Esta spec consolida o contrato implementado para a FASE 21:

- renderização de traces em SVG animado;
- painel local de consulta e replay;
- exportação ZIP offline por endpoint observado.

## Módulos

- `lib/civitas/trace_render/trace_render.cct`
- `lib/civitas/trace_panel/trace_panel.cct`
- `lib/civitas/trace_export/trace_export.cct`

## Contrato de `trace_render`

### Entrada

- `Trace`
- `TraceRenderConfig`

### Saída

- SVG completo com cabeçalho, timeline, legenda e controles JS;
- metadados de largura, altura, span count e duração.

### Regras

- barras refletem duração proporcional e respeitam profundidade da árvore;
- animação CSS usa atraso relativo ao `start_time_ms`;
- categorias recebem cores estáveis;
- modo step-by-step injeta JavaScript inline;
- comparação lado a lado é suportada.

## Contrato de `trace_panel`

### Rotas

- `GET /civitas/traces`
- `GET /civitas/traces/{trace_id}`
- `GET /civitas/traces/{trace_id}/svg`
- `POST /civitas/traces/{trace_id}/replay`

### Regras

- a listagem consome o índice do `TraceStore`;
- o detalhe embute o SVG do trace resolvido;
- a rota `/svg` serve `image/svg+xml`;
- replay usa subprocesso local e redireciona ao painel.

## Contrato de `trace_export`

### Entrada

- `TraceStore`
- `TraceRenderConfig`
- diretório de saída
- nome da aplicação

### Saída

- ZIP com `index.html`, CSS compartilhado, SVGs e páginas de detalhe.

### Regras

- agrupamento por `(method, path)` observado;
- um trace representativo por endpoint;
- navegação offline por links relativos;
- pacote íntegro sem dependência de servidor.

## Gate consolidado

- renderer gera SVG válido;
- painel lista, detalha e serve SVG;
- replay redireciona sem quebrar o painel;
- exportação gera ZIP navegável offline.

