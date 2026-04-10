# Manual Aprofundado do Sistema — FASE 2

## Visão geral

A FASE 2 transforma o Civitas de servidor HTTP utilizável em framework web com contratos reaproveitáveis.

O bloco `2A-2F` entrega:

- `Request` canônica sobre `HttpRawRequest`;
- `Response` canônica sobre `HttpRawResponse`;
- pipeline oficial de middleware com contexto por request;
- router declarativo com params tipados, grupos, rotas nomeadas e metadados de sigilo;
- política central de visibilidade separada de permissão;
- paginação e query helpers de listagem com allowlist de ordenação.

## Request

O núcleo de request está em `lib/civitas/request_core.cct`, com camadas auxiliares em `request.cct`, `request_http.cct` e `request_server.cct`.

`WebRequest` materializa:

- `method`
- `raw_target`
- `path`
- `version`
- `headers`
- `query_params`
- `path_params`
- `cookies`
- `body`
- `client_ip`
- `scheme`
- `host`
- `request_id`
- `proxy_ip`
- `remote_addr`
- `local_addr`

Contratos operacionais estabilizados:

- headers são acessados de forma case-insensitive;
- query params preservam repetição e ordem;
- `path_params` são mutáveis pelo router;
- cookies são derivados do header `Cookie`;
- metadata de proxy e `request_id` é herdada da FASE 1;
- helpers de auth básica e bearer trabalham sobre a request já elevada.

## Response

O núcleo de response está em `lib/civitas/response.cct`, com serialização HTTP em `response_http.cct`.

`WebResponse` materializa:

- `status`
- `headers`
- `body`
- `body_kind`
- `set_cookies`
- `gzip_enabled`

Contratos estabilizados:

- helpers `ok`, `created`, `no_content`, `bad_request`, `unauthorized`, `not_found`, `internal_error`;
- builders `text`, `html`, `json_text`, `redirect`, `redirect_permanent`;
- mutação estável de headers e `Set-Cookie`;
- `response_fill` preserva mutações acumuladas da pipeline e incorpora a response final;
- política explícita para `204`, `304`, `HEAD` e gzip opcional.

## Middleware

O contrato oficial está em `lib/civitas/middleware.cct`.

O desenho implementado é baseado em registries explícitos e callbacks tardios:

- middlewares registrados como `MiddlewareBinding { name, opaque_ref }`;
- `RequestContext` isolado por request;
- `middleware_chain(...)` e `middleware_chain_with_context(...)` para executar a pipeline;
- `middleware_run(...)` para encaminhamento ao `next`.

`RequestContext` carrega:

- storage opaco `values`;
- estado interno da pipeline;
- metadados de rota expostos pelo router.

Built-ins entregues nesta fase:

- logger mínimo;
- timing;
- recovery;
- CORS básico.

Contratos operacionais:

- ordem de middleware é determinística;
- short-circuit é suportado;
- o contexto não vaza entre requests;
- metadados de rota entram no contexto antes do handler final;
- mutações de response anteriores a `next` sobrevivem ao merge com a response do handler.

## Router

O router está em `lib/civitas/router.cct`.

Capacidades estabilizadas:

- matching por método e pattern;
- params `{nome}`, `{id:int}`, `{slug:slug}`, `{rest:*}`;
- precedência entre rotas estáticas e paramétricas;
- grupos com prefixo e middlewares compartilhados;
- middlewares globais, de grupo e de rota;
- rotas nomeadas com `router_url_for(...)`;
- distinção normativa entre `404` e `405`, com header `Allow`;
- manifesto de sigilo por rota.

Cada `Route` materializa:

- método;
- pattern;
- nome;
- símbolo do handler;
- `handler_ref`;
- middlewares;
- prefixo de grupo;
- `sigilo_id`;
- pattern compilado;
- índice de registro.

## Visibilidade

O contrato central está em `lib/civitas/visibility.cct`.

Vocabulário canônico entregue:

- `public`
- `private`
- `followers`
- `restricted`
- `deleted`
- `moderation`

Tipos principais:

- `VisibilityPolicy`
- `VisibilitySurface`
- `VisibilityDecision`
- `VisibilityContext`

Regras estabilizadas:

- visibilidade não é permissão;
- `public` é aberta;
- `private` exige login e propriedade, salvo contexto administrativo elevado;
- `followers` exige login e relação explícita;
- `restricted` exige acesso elevado;
- `deleted` e `moderation` não entram no fluxo público por padrão;
- `visibility_http_status(...)` fornece baseline HTTP sem montar a response inteira.

## Paginação e listagem

O contrato está em `lib/civitas/pagination.cct`.

Tipos principais:

- `SortDirection`
- `PaginationRequest`
- `PaginationMeta`

Invariantes estabilizadas:

- `page` começa em `1`;
- `offset` e `limit` são derivados;
- `page_size` tem teto explícito;
- `sort_by` só passa por allowlist;
- `dir` só aceita `asc` ou `desc`;
- metadata é a mesma para HTML e JSON.

Helpers principais:

- `pagination_default(...)`
- `pagination_from_request(...)`
- `pagination_offset(...)`
- `pagination_limit(...)`
- `pagination_meta(...)`
- `pagination_meta_unknown_total(...)`
- `pagination_meta_json(...)`

## Testes

O runner único `tests/run_tests.sh` agora cobre a FASE 2 completa por subfase.

Cobertura de integração da fase:

- `2A`: 9 testes
- `2B`: 10 testes
- `2C`: 10 testes
- `2D`: 7 testes
- `2E`: 7 testes
- `2F`: 7 testes

Total da FASE 2: 50 testes de integração.

## Limites operacionais

- body web continua sendo `VERBUM`;
- pipeline de middleware continua baseada em rituales nomeados, sem closures;
- visibilidade não resolve ACL de domínio nem política editorial completa;
- paginação desta fase é offset/limit e não inclui cursor pagination nem query builder.
