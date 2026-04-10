# FASE 6 Release Notes

## Entregas

- `lib/civitas/template/` com lexer, parser, checker, codegen e compiler de templates compilados;
- `bin/cct-template-compile.cct` como CLI oficial de compilação de templates;
- integração do `Makefile` com `template-compile` no fluxo de build;
- `lib/civitas/template/context.cct`, `filters.cct` e `integration.cct` com loop context, filtros canônicos e helpers web;
- `lib/civitas/html.cct` com builder HTML seguro e utilitários de forms/paginação;
- `lib/civitas/template_extras/` com paginação editorial, query string, SEO, assets/mídia e breadcrumbs;
- expansão do runner único para cobrir `6A-6D`.

## Decisões relevantes

- templates são compilados em build e não interpretados em runtime;
- layout pai e blocos do filho são resolvidos antes da geração de código;
- a CLI publica erros em formato estável `arquivo:linha:coluna`;
- templates raiz têm normalização mínima de quebra de linha inicial/final para evitar vazamento estrutural no HTML;
- `civitas/html` complementa templates para casos de lógica imperativa sem abrir mão de escape seguro por padrão.
- `template_extras` foi mantido como camada pré-computada pelo handler, sem acoplar novas tags nativas ao compilador nesta rodada;
- resolução de chaves `VERBUM` em `MAPPA` foi tratada explicitamente em `qs` e `assets` para evitar bugs por identidade interna.

## Cobertura de testes

A FASE 6 adiciona:

- 5 testes em `6A`
- 5 testes em `6B`
- 5 testes em `6C`
- 8 testes em `6D`

Total da FASE 6: 23 testes de integração.

## Estado do gate

O bloco `6A-6D`, fechando a FASE 6, só é considerado concluído com:

- `6A` verde isoladamente;
- `6B` verde isoladamente;
- `6C` verde isoladamente;
- `6D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressão histórica;
- documentação consolidada sincronizada com o comportamento realmente entregue.
