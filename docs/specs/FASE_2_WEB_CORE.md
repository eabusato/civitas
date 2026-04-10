# Consolidated Spec — PHASE 2

## Implemented Scope

This spec consolidates the behavior delivered in block `2A-2F`.

## Request

`lib/civitas/request_core.cct` stabilizes `WebRequest` as the elevation of the HTTP transport already materialized in PHASE 1.

Implemented contract:

- case-insensitive headers;
- simple and repeated query params;
- mutable path params;
- cookies derived from the `Cookie` header;
- raw body in `VERBUM`;
- proxy metadata, `host`, `scheme`, and `request_id`;
- bearer and basic-auth helpers;
- body-parsing helpers via adjacent modules of the phase.

## Response

`lib/civitas/response.cct` stabilizes `WebResponse`.

Implemented contract:

- status helpers and text, HTML, JSON, and redirect builders;
- safe mutation of headers and `Set-Cookie`;
- `Allow` header for `405`;
- optional gzip;
- explicit body policy for `204`, `304`, and `HEAD`;
- response merge preserving headers, cookies, and gzip accumulated by the pipeline.

## Middleware

`lib/civitas/middleware.cct` defines:

- `RequestContext`;
- `MiddlewareBinding`;
- ordered execution via registry and deferred callback;
- `middleware_chain(...)` and `middleware_chain_with_context(...)`.

Operational contracts:

- predictable order;
- short-circuit allowed;
- canonical recovery and timing;
- per-request context with opaque storage;
- route metadata exposed in the context.

## Router

`lib/civitas/router.cct` defines declarative dispatch.

Implemented contract:

- method + path pattern;
- params `{nome}`, `{id:int}`, `{slug:slug}`, `{rest:*}`;
- static > parametric precedence when applicable;
- groups with shared prefix and middlewares;
- global, group, and route middlewares;
- `404` and `405` fallback;
- reverse routing by name;
- per-route sigil manifest with method, pattern, name, handler, and middleware chain.

## Visibility

`lib/civitas/visibility.cct` defines:

- `VisibilityPolicy`
- `VisibilitySurface`
- `VisibilityDecision`
- `VisibilityContext`

Implemented contract:

- `visibility_parse(...)` and `visibility_name(...)`;
- `visibility_decide(...)` separated from permission;
- `visibility_is_public(...)`;
- `visibility_is_hidden_from_public(...)`;
- `visibility_http_status(...)`;
- `visibility_filter_public_only(...)`.

Baseline semantics:

- `public`: allow;
- `private`: requires login and owner, with elevated admin exception;
- `followers`: requires login and relationship;
- `restricted`: requires elevated access;
- `deleted`: denied outside admin;
- `moderation`: denied to the public flow, visible to author/moderation depending on context.

## Pagination

`lib/civitas/pagination.cct` defines:

- `PaginationRequest`
- `PaginationMeta`
- `SortDirection`

Implemented contract:

- parse of `page`, `page_size`, `sort`, and `dir` from `Request`;
- mandatory allowlist for `sort`;
- clamping of `page` and `page_size`;
- derived `offset` and `limit`;
- metadata with known and unknown total;
- JSON serialization of metadata via `pagination_meta_json(...)`.

## Parsing, Context Resolution, and Serialization Contracts

### Parsing

- `visibility_parse(...)` accepts only the canonical vocabulary of the phase;
- `pagination_from_request(...)` rejects sort outside the allowlist and invalid direction;
- invalid pagination numbers return `Err`.

### Context Resolution

- `RequestContext` supports opaque per-request storage;
- the router populates route name, pattern, `sigilo_id`, and handler symbol in the context;
- visibility uses `VisibilityContext` separated from any domain ACL.

### Serialization

- `WebResponse` continues to be serialized to HTTP by the PHASE 2B modules;
- `PaginationMeta` can be shared between HTML and JSON, including direct JSON serialization.

## Test Coverage

PHASE 2 adds 50 integration tests distributed across `2A` and `2F`, under the unified runner in `tests/run_tests.sh`.
