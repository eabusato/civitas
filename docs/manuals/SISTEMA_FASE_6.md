# Manual Aprofundado do Sistema — FASE 6

## Visão geral

A FASE 6 transforma renderização HTML em contrato oficial do framework.

O bloco `6A-6D` entrega:

- linguagem de templates compilados em build com contexto tipado;
- herança de layout e inclusão de parciais resolvidas antes do runtime;
- CLI oficial de compilação de templates e integração no `Makefile`;
- `civitas/html` para HTML imperativo com escape seguro e helpers web;
- `template_extras` com paginação, query string, SEO, assets/mídia e breadcrumbs para sites públicos.

## Linguagem de templates

O contrato vive em `lib/civitas/template/lexer.cct`, `parser.cct`, `ast.cct` e `checker.cct`.

Capacidades estabilizadas:

- declaração obrigatória de contexto com `{% EVOCA Contexto %}`;
- expressões `{{ campo }}` com acesso aninhado e escaping HTML default;
- filtros canônicos `upper`, `lower`, `truncate`, `default`, `format`, `length`, `abs` e `safe`;
- controle de fluxo com `{% SI %}`, `{% ALITER %}`, `{% FIN SI %}`, `{% DUM %}` e `{% FIN DUM %}`;
- variáveis de loop `loop.index`, `loop.count`, `loop.length`, `loop.is_first` e `loop.is_last`;
- herança com `{% EXTENDE %}`, `{% SECTIO %}` e `{% FIN SECTIO %}`;
- inclusão com `{% ADVOCARE "parcial.html" %}` e `{% ADVOCARE "parcial.html" AD campo %}`;
- tags de integração `{% CSRF %}`, `{% NEXUS %}`, `{% NONCE %}` e escape literal com `{% LITERAL %}`.

Contratos operacionais:

- variável inexistente, tipo incompatível, parcial com contexto inválido e ausência de `{% EVOCA %}` são erro de build;
- o compilador resolve o contexto a partir de `SIGILLUM` do projeto e usa hints `FLUXUS(...)` para iteração tipada;
- blocos do template filho substituem ou completam o layout pai antes da geração de código;
- templates raiz sofrem normalização mínima de quebra de linha inicial/final para evitar vazamento estrutural de `{% EVOCA %}` e EOF no HTML.

## Compilador e build

O contrato fica em `lib/civitas/template/codegen.cct`, `compiler.cct` e `bin/cct-template-compile.cct`.

Capacidades estabilizadas:

- compilação de um arquivo `.html` para um módulo `.cct` gerado;
- compilação de uma árvore `templates/` inteira para `templates_gen/`;
- comentários de origem `-- gerado de arquivo.html:linha` no código emitido;
- diagnósticos textuais padronizados `arquivo:linha:coluna` para uso em CLI e build;
- geração de imports relativos ao projeto e imports canônicos `cct/...` para a stdlib do compilador.

Contratos observáveis:

- `bin/cct-template-compile --template ... --output ... --root ...`;
- `bin/cct-template-compile --dir ... --out-dir ...`;
- `make build` já executa `template-compile` antes da compilação final do projeto;
- o código gerado produz rituales `render_<template>(Contexto ctx) -> VERBUM`.

## Integração com o framework

O contrato vive em `lib/civitas/template/integration.cct`.

Capacidades estabilizadas:

- `tpl_static_url(...)` para path estático;
- `tpl_nonce()` e `tpl_nonce_attr()` para CSP nonce;
- `tpl_csrf_input()` e `tpl_csrf_input_field(...)` para hidden field CSRF;
- fallback por ambiente para `CIVITAS_TEMPLATE_NONCE` e `CIVITAS_TEMPLATE_CSRF_TOKEN`.

## civitas/html

O contrato está em `lib/civitas/html.cct`.

Capacidades estabilizadas:

- criação de nós e attrs com escape seguro;
- `html_text(...)`, `html_raw(...)` e `html_child(...)`;
- forms com CSRF e attrs seguros;
- paginação renderizada com semântica navegável;
- `html_render_free(...)` para serialização final do nó raiz.

Limites operacionais:

- o builder trabalha como árvore linearizada de fragmentos renderizados, não DOM mutável completo;
- `html_raw(...)` continua sendo via explícita de bypass de escaping e deve ser usado apenas com conteúdo confiável;
- a linguagem de templates continua deliberadamente sem execução arbitrária de lógica, só expressões e controle declarado.

## template_extras

O contrato está em `lib/civitas/template_extras/`.

Capacidades estabilizadas:

- `pagination.cct` para navegação paginada completa, com janela configurável e HTML acessível;
- `qs.cct` para manipular query string sem perder parâmetros existentes nem fragmento;
- `seo.cct` para canonical, hreflang, meta description e `og:*` básicos;
- `assets.cct` para resolver static com registry opaco e mídia pública via `public_base_url`;
- `breadcrumbs.cct` para navegação hierárquica com microdata e JSON-LD.

Contratos operacionais:

- os helpers são pensados para pré-computação no handler e injeção no template via `|safe`;
- paginação continua baseada em `total_pages`, não em cursor;
- query params usam igualdade textual estável nas chaves para evitar inconsistência do `MAPPA` com `VERBUM`;
- `static_url(...)` já aceita registry opaco, mas mantém fallback pragmático de `/static/<path>` antes da fase 9B;
- `static_url_or_passthrough(...)` existe para desenvolvimento e cenários sem registry definitivo;
- `media_url(...)` usa a `public_base_url` já consolidada na fase 4.

## Cobertura de testes

Cobertura da FASE 6:

- `6A`: 5 testes
- `6B`: 5 testes
- `6C`: 5 testes
- `6D`: 8 testes

Total da FASE 6: 23 testes de integração.
