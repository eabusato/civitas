# Manual Aprofundado do Sistema — FASE 19

## Visao geral

A FASE 19 consolida a camada de publicacao programatica e de distribuicao externa do Civitas. O bloco `19A-19E` fecha dois eixos complementares:

- API REST nativa do framework, com contrato declarativo de serializacao, views genericas, versionamento e spec OpenAPI;
- superficie publica de distribuicao e consumo externo, com SEO tecnico, feeds, redirects legados, embeds, oEmbed e exportacoes autenticadas.

O bloco entrega:

- `civitas/api` para serializers, validacao, envelopes, paginacao e content negotiation;
- `civitas/api_views` para list/detail/create/update/delete, filtros, ordenacao e versionamento;
- `civitas/openapi` para derivar e servir `OpenAPI 3.1` a partir dos registries reais do framework;
- `civitas/seo` para `robots.txt`, `sitemap.xml`, feeds RSS/Atom, canonical, hreflang, redirects e paginas estaticas;
- `civitas/embed` para paginas de embed, endpoint `oEmbed` e export CSV/JSON protegido.

## Modelo operacional da fase

O contrato estabilizado nesta fase e:

1. a aplicacao declara `SerializerConfig` por recurso e registra os serializers em `ApiSerializerRegistry`;
2. a aplicacao declara `ApiViewConfig`/`ViewSetConfig`, registra os recursos e delega CRUD, filtros, ordenacao e paginacao para `civitas/api_views`;
3. a spec OpenAPI passa a ser derivada dos registries reais, sem arquivo manual separado;
4. a publicacao publica usa tabelas reais do sistema (`civitas_pages`, redirects, paginas estaticas, embed configs), e nao artefatos paralelos fora do framework;
5. distribuicao externa por feeds, embeds e exports respeita autenticacao, allowlists e contratos de serializacao do Civitas.

Limites operacionais explicitos:

- a fase entrega API REST classica e OpenAPI JSON, nao GraphQL/gRPC;
- `OpenAPI` e derivada dos registries em runtime e cacheada em SQLite por TTL curto;
- SEO e embeds aqui cobrem publicacao e distribuicao, nao analytics pesado, cache HTTP longo ou UI de documentacao Swagger;
- exportacoes sao integrais ate o limite configurado do modelo/export, sem paginacao interativa.

## `civitas/api`

O contrato vive em `lib/civitas/api/api.cct`.

Capacidades estabilizadas:

- `ApiFieldKind`, `SerializerField`, `SerializerConfig`, `ApiSerializerRegistry`;
- `ValidationError`, `ValidationResult`, `ApiPaginationMeta`, `ApiPaginatedResult`;
- `serializer_config_init(...)`, `serializer_config_add_field(...)`;
- `api_serializer_registry_put(...)`, `api_serializer_registry_get(...)`;
- `serializer_to_json(...)`, `serializer_list_to_json(...)`, `serializer_validate(...)`;
- `paginate_offset(...)`, `paginate_cursor(...)`;
- `api_content_format_from_accept(...)`, `api_format_response(...)`;
- `api_response_ok(...)`, `api_response_error(...)`, `api_response_paginated(...)`, `api_response_validation_error(...)`.

Semantica consolidada:

- serializers funcionam como allowlist explicita entre dominio e HTTP;
- `read_only` e `write_only` afetam tanto validacao quanto projecao de schema;
- serializacao aninhada depende de registry real, nao de inferencia magica;
- o envelope canônico `ok/data/error/meta` padroniza resposta de API e falha validada.

## `civitas/api_views`

O contrato vive em `lib/civitas/api_views/api_views.cct`.

Capacidades estabilizadas:

- `ApiViewConfig`, `ViewSetConfig`, `ApiVersionConfig`;
- `api_view_list(...)`, `api_view_detail(...)`, `api_view_create(...)`, `api_view_update(...)`, `api_view_delete(...)`;
- `api_parse_filters(...)`, `api_build_filter_sql(...)`, `api_list_select_sql(...)`, `api_list_count_sql(...)`;
- `api_auth_check(...)`, `api_version_extract(...)`, `api_version_config_for(...)`;
- `api_viewset_register(...)` para registrar o conjunto canonical de rotas REST.

Semantica consolidada:

- filtros e ordenacao usam allowlist declarativa por recurso;
- autenticacao bearer pode ser exigida por recurso de forma uniforme;
- `405` e header `Allow` sao gerados pelo contrato do recurso, nao por handler ad hoc;
- a view lista delega paginacao e serializacao para `civitas/api`, em vez de reimplementar envelopes.

## `civitas/openapi`

O contrato vive em `lib/civitas/openapi/openapi.cct`.

Capacidades estabilizadas:

- mapeamento `ApiFieldKind -> JSON Schema`;
- schema de serializer para leitura e escrita;
- components gerados do registry de serializers;
- paths gerados do registry de viewsets;
- `bearerAuth` para endpoints autenticados;
- cache SQLite em `openapi_cache`;
- handler de `GET /api/schema.json`.

Semantica consolidada:

- a spec e derivada das definicoes reais de API do framework;
- o cache acelera a resposta do endpoint sem tornar a spec manual ou opaca;
- o JSON gerado e imediatamente consumivel por ferramentas externas.

## `civitas/seo`

O contrato vive em `lib/civitas/seo/seo.cct`.

Capacidades estabilizadas:

- `RobotsConfig` e `seo_robots_generate(...)`;
- schema `seo_redirects` e `seo_static_pages`;
- `seo_redirect_upsert(...)`, `seo_redirect_lookup(...)`, `seo_redirect_response_or_empty(...)`;
- `seo_canonical_url(...)`, `seo_hreflang_tags_for_path(...)`;
- `seo_sitemap_xml(...)`, `seo_feed_rss(...)`, `seo_feed_atom(...)`;
- handlers de robots, sitemap, feeds e pagina estatica.

Semantica consolidada:

- redirects legados ficam persistidos em banco e podem ser aplicados antes do router final;
- sitemap e feeds leem `civitas_pages` publicadas e paginas estaticas publicadas;
- canonical/hreflang sao calculados a partir da configuracao publica do site;
- paginas institucionais ficam geridas por tabela, nao por arquivo hardcoded.

## `civitas/embed`

O contrato vive em `lib/civitas/embed/embed.cct`.

Capacidades estabilizadas:

- `EmbedConfig`, `EmbedObject`, `ExportConfig`;
- schema `embed_configs` e `embed_access_log`;
- `embed_config_register(...)`, `embed_config_load(...)`;
- `embed_video_handler(...)`, `embed_content_handler(...)`;
- `oembed_handler(...)`;
- `embed_export_json(...)`, `embed_export_csv(...)`;
- `embed_export_json_handler(...)` com bearer token;
- `embed_export_csv_admin_handler(...)` com basic auth.

Semantica consolidada:

- embeds consultam configuracao persistida por modelo e carregam o objeto real por PK;
- `allowed_origins` protege o uso via iframe de forma simples e previsivel;
- access log de embed e best-effort, mas persistido para auditoria/analytics basicos;
- export CSV/JSON reutiliza tabela/fields configurados e nao abre dump arbitrario do banco.

## Fluxo canonico integrado

1. um recurso e declarado com serializer e viewset em `19A-19B`;
2. clientes HTTP consomem list/detail/create/update/delete usando envelopes e paginacao canonicos;
3. `19C` deriva a spec OpenAPI do mesmo registry que alimenta a API;
4. `19D` publica os artefatos tecnicos que tornam o conteudo rastreavel e migravel publicamente;
5. `19E` abre a camada de distribuicao externa com embed, oEmbed e export autenticado;
6. o resultado e um Civitas que expõe tanto interface web tradicional quanto superficie publica e programatica coerente.

## Cobertura de testes

Cobertura da FASE 19:

- `19A`: 5 testes
- `19B`: 5 testes
- `19C`: 5 testes
- `19D`: 5 testes
- `19E`: 5 testes

Total da FASE 19: 25 testes de integracao.
