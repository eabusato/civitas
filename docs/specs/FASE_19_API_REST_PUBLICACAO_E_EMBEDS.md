# FASE 19 — API REST, OpenAPI, Publicação e Embeds

## Escopo consolidado

O bloco `19A-19E` estabiliza a fronteira programatica e publica do Civitas em cinco partes integradas:

- serializers, validacao, envelopes, paginação e negotiation de formato;
- views REST genericas com viewset, filtros, ordenacao e versionamento;
- geracao e servico de spec `OpenAPI 3.1`;
- artefatos de publicacao publica e SEO tecnico;
- embeds, `oEmbed` e exportacoes protegidas.

## Contratos implementados

### `civitas/api`

- `ApiFieldKind`, `SerializerField`, `SerializerConfig`, `ApiSerializerRegistry`;
- `ValidationResult` e erros por campo;
- `serializer_to_json(...)`, `serializer_validate(...)`, `serializer_nested(...)`;
- `paginate_offset(...)` e `paginate_cursor(...)`;
- `api_content_format_from_accept(...)`, `api_json_array_to_csv(...)`;
- envelopes `api_response_ok/error/paginated/validation_error/not_found/internal_error`.

Semantica consolidada:

- a allowlist do serializer define explicitamente o shape do contrato HTTP;
- o registry e a fonte de verdade para serializacao aninhada;
- JSON e CSV coexistem por `Accept`, sem duplicar a fonte de dados.

### `civitas/api_views`

- `ApiViewConfig`, `ViewSetConfig`, `ApiVersionConfig`;
- list/detail/create/update/delete genericos;
- parse de filtros e guard de ordenacao;
- versionamento por prefixo de path ou `Accept`;
- autenticacao bearer integrada;
- registro canonico das rotas do recurso.

Semantica consolidada:

- recursos CRUD deixam de depender de handlers manuais repetitivos;
- autenticacao e metodo permitido sao verificados antes da operacao de dominio;
- SQL dinamico de listagem continua explicitamente parametrizado.

### `civitas/openapi`

- `openapi_field_kind_to_type(...)` e `openapi_field_kind_to_format(...)`;
- schema de leitura e escrita por serializer;
- paths por collection/detail gerados de `ViewSetConfig`;
- components e `securitySchemes.bearerAuth`;
- cache SQLite em `openapi_cache`;
- `openapi_handler(...)`.

Semantica consolidada:

- a documentacao externa deixa de ser um artefato manual separado do contrato real da API;
- o cache e curto e invalida por tempo, nao por arquivo estatico versionado.

### `civitas/seo`

- schema `seo_redirects` e `seo_static_pages`;
- `seo_robots_generate(...)`;
- `seo_redirect_upsert/lookup/response_or_empty(...)`;
- `seo_canonical_url(...)`, `seo_hreflang_tags_for_path(...)`;
- `seo_sitemap_xml(...)`, `seo_feed_rss(...)`, `seo_feed_atom(...)`;
- handlers de publicacao.

Semantica consolidada:

- `robots.txt` e sitemap/feed podem ser servidos pelo proprio framework;
- redirects legados ficam trataveis como dado operacional;
- paginas estaticas publicadas entram no mesmo circuito de SEO do conteudo.

### `civitas/embed`

- schema `embed_configs` e `embed_access_log`;
- configuracao persistida por modelo;
- handlers HTML para embed de video e conteudo;
- `oEmbed` JSON a partir de URL embedavel;
- export CSV e JSON com autenticacao.

Semantica consolidada:

- embed e distribuicao externa deixam de depender de HTML montado fora do framework;
- export administrativo e export programatico compartilham a mesma configuracao de campos.

## Fluxo canonico integrado

1. um recurso `posts` registra serializer e viewset;
2. a API passa a responder CRUD, filtros, ordenacao e paginacao sob contrato uniforme;
3. a spec `OpenAPI` do recurso e derivada do mesmo registry e servida pelo framework;
4. o mesmo conteudo publicado entra em `robots`, `sitemap`, `feed`, canonical e hreflang;
5. quando necessario, o recurso tambem pode ser distribuido como embed ou exportado com autenticacao.

## Limites operacionais

- sem GraphQL, SDK generator ou Swagger UI embutido;
- sem feeds especializados de podcast ou sitemap index multiarquivo;
- sem export arbitrario de campos fora da configuracao declarada;
- sem embeds autenticados ou privados nesta materializacao.

## Cobertura

O bloco fecha com 25 testes de integracao:

- 5 em `19A`
- 5 em `19B`
- 5 em `19C`
- 5 em `19D`
- 5 em `19E`

## Estado esperado do gate

O bloco `19A-19E` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `19A-19E`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
