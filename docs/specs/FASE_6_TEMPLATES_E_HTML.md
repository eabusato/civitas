# Spec Consolidada — FASE 6

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `6A-6D`.

## Templates compilados

`lib/civitas/template/` estabiliza a linguagem e o compilador de templates do Civitas.

Contrato implementado:

- lexer para `{{ }}`, `{% %}` e comentários de template;
- AST tipada com nós para texto, expressão, contexto, condicionais, loops, blocos, extends, include, CSRF, static, nonce e literal;
- checker com resolução de `SIGILLUM`, hints de `FLUXUS(...)`, verificação de filtros e compatibilidade de contexto;
- geração de módulos CCT com `render_<template>(ctx) -> VERBUM`;
- resolução de layout pai e blocos em build, sem lookup de template em runtime;
- inclusão de parcial com contexto atual ou campo explícito compatível.

Contratos de parsing e resolução:

- `{% EVOCA %}` é obrigatório e dirige toda a resolução de contexto;
- `{% DUM item IN lista %}` exige campo iterável anotado no schema do projeto;
- `{% EXTENDE %}` mais `{% SECTIO %}` gera uma única função final com o layout inlineado;
- `{% ADVOCARE %}` gera chamada para módulo compilado do parcial;
- diagnóstico de checker e CLI usa `template:linha:coluna`.

## CLI e integração de build

`bin/cct-template-compile.cct` e `Makefile` estabilizam o fluxo operacional.

Contrato implementado:

- compilação individual com `--template/--output/--root`;
- compilação recursiva com `--dir/--out-dir`;
- mensagens de ajuda e erro adequadas ao uso no build;
- alvo `template-compile` integrado ao `build`.

## Integrações de template

`lib/civitas/template/integration.cct` estabiliza os helpers web canônicos.

Contrato implementado:

- `tpl_static_url(...)` para assets;
- `tpl_nonce()` e `tpl_nonce_attr()` para CSP nonce;
- `tpl_csrf_input()` e `tpl_csrf_input_field(...)` para hidden field CSRF;
- fallback por variável de ambiente para probes e execução fora do request real.

## Builder HTML

`lib/civitas/html.cct` estabiliza a via imperativa para geração de HTML.

Contrato implementado:

- `HtmlNode`, `HtmlAttr` e helpers de construção;
- attrs com escape de texto e suporte a valores booleanos/voids;
- texto escapado por padrão e raw explícito;
- composição de children e serialização final;
- helpers de form com CSRF e paginação HTML sobre `PaginationResult`.

## Helpers editoriais e públicos

`lib/civitas/template_extras/` estabiliza os helpers canônicos para sites públicos orientados a conteúdo.

Contrato implementado:

- `pagination.cct` com `PaginationConfig`, `pagination_page_url(...)` e `pagination_html(...)`;
- `qs.cct` com `qs_set`, `qs_remove`, `qs_merge` e `qs_get` preservando path e fragment;
- `seo.cct` com canonical, hreflang, meta description e Open Graph básicos;
- `assets.cct` com resolução de static por registry opaco e `media_url(...)` sobre `StorageSettings.public_base_url`;
- `breadcrumbs.cct` com HTML navegável e JSON-LD `BreadcrumbList`.

Contratos de parsing e resolução:

- paginação usa `aria-current="page"`, omite links inválidos de anterior/próximo e insere reticências quando a janela não toca os extremos;
- helpers de query string resolvem chaves `VERBUM` por igualdade textual estável, sem depender de identidade interna do `MAPPA`;
- tags SEO escapam todos os valores dinâmicos em atributos HTML;
- `breadcrumbs_html(...)` aplica microdata schema.org no markup e `breadcrumbs_json_ld(...)` produz script JSON-LD compacto;
- `static_url_or_passthrough(...)` preserva o path original quando o asset ainda não está no registry, preparando a integração futura com a fase 9B sem quebrar desenvolvimento.

## Cobertura de testes

A FASE 6 adiciona 23 testes de integração:

- 5 em `6A`
- 5 em `6B`
- 5 em `6C`
- 8 em `6D`
