# Civitas

Web framework in CCT, built and organized in phases.

## What Exists Up to PHASE 28

The project already delivers twenty-eight consolidated blocks:

- PHASE 0: operational repository bootstrap, manifest, `Makefile`, canonical example, and baseline documentation;
- PHASE 1: a usable synchronous HTTP/1.1 server, URL handling, cookies, MIME, parser/connection hardening, `request_id`, `trusted_proxies`, and a minimal access log.
- PHASE 2: web core with `Request`, `Response`, middleware, router, visibility policy, and list pagination.
- PHASE 3: local signals, an explicit per-application event bus, and a durable file-backed outbox with post-commit semantics.
- PHASE 4: canonical settings via TOML and environment, `Application` with lifecycle and health, typed external-service configuration, and rotating domain secrets.
- PHASE 5: baseline security with canonical headers, per-request CSP nonce, host validation, IP rate limiting, path guard, CSRF protection with rotating secret, and complementary anti-abuse by route, quota, and heuristic spam detection.
- PHASE 6: build-time compiled templates with typed context, layout inheritance, partial inclusion, compilation CLI, `civitas/html` for imperative HTML, and `template_extras` for pagination, SEO, breadcrumbs, and public URLs.
- PHASE 7: the full forms cycle with `application/x-www-form-urlencoded` and `multipart/form-data` parsing, declarative validation, rich content sanitization, HTML rendering with safe refill, a controlled attribute escape hatch, and an explicit memory contract.
- PHASE 8: server-side session support with memory, file, SQLite, and Redis backends, HMAC-signed cookies, remember-me, flash messages across requests, the `{% SIGNA %}` tag in templates, authenticated request context, and a canonical `UploadDescriptor` for `FkBlob` fields.
- PHASE 9: multipart upload streaming with magic-byte validation, static files with ETag and hashed names, zoned local storage with signed URLs, image pipeline, video pipeline with probe/transcode/thumb, and private media delivery with range-request support, `X-Accel-Redirect`, and `X-Sendfile`.
- PHASE 10: declarative schema with `ModelDef`, explicit query builder over prepared SQLite, versioned migrations, and content modules for taxonomy, social, authorship/moderation, and institutional pages.
- PHASE 11: uniform `DbHandle` over SQLite/PostgreSQL, per-process connection pooling, nested transactions with savepoints, PostgreSQL full-text search, and canonical advisory locks for concurrent jobs.
- PHASE 12: multi-layer cache with unified memory/file/Redis backend, HTTP response caching with `Vary` and tags, query cache over `civitas/query`, and an invalidation coordinator with in-process or Redis anti-stampede control.
- PHASE 13: declarative fixtures, deterministic factories, SQLite test database with savepoints, administrative import/export/backfill, and a Django → Civitas migration toolkit.
- PHASE 14: i18n and l10n baseline with locale catalogs, canonical fallback, localized formatting of numbers/dates/currencies, request locale resolution, native JSON catalogs, and advanced formats such as relative time, long date, ordinals, and conjunction-based lists.
- PHASE 15: full authentication with PBKDF2 users, HMAC tokens with rotating refresh, explicit permissions, server-side session integration into the request, unified middleware, brute-force login rate limiting, and auth testing helpers.
- PHASE 16: account recovery and email verification with signed TTL tokens, password history, Civitas mailer over `cct/mail`, dual-body transactional templates, and testing helpers for token capture and extraction.
- PHASE 17: background execution with persistent queue, canonical worker, recurring scheduler, safe retention, asynchronous media pipeline, and editorial automations for translation, sitemap, feed, rankings, and counters.
- PHASE 18: operational admin panel with model registry, list/CRUD/bulk actions, inlines, custom actions, per-action permissions, auditable moderation, and an operations dashboard with snapshots, queues, and failures.
- PHASE 19: native REST API with serializers and viewsets, derived `OpenAPI 3.1`, `robots.txt`, `sitemap.xml`, RSS/Atom feeds, canonical/hreflang, legacy redirects, static pages, embeds, `oEmbed`, and protected CSV/JSON exports.
- PHASE 20: request observability with live instrumentation over `cct/instrument`, per-request collector, `.ctrace` traces, local SQLite index, and explicit spans for SQL, cache, storage, media, email, i18n, moderation, and tasks.
- PHASE 21: live trace visualization with animated SVG renderer, HTML diagnostics panel at `/civitas/traces`, local request replay, and offline ZIP export per observed endpoint.
- PHASE 22: dev server with watch/rebuild/restart, browser compilation error page, HTML debug toolbar, and generation-based livereload, preserving the full animated CCT sigil as the trace visualization.
- PHASE 23: native project CLI with `civitas new`/`init`, scaffold organized into `project/`, `apps/`, `settings/`, `data/`, and `.civitas/`, `starter`, `layered`, and `domain` styles, `civitas generate` with named-app support, management commands (`migrate`, `rollback`, `seed`, `test`, `collect_static`, `create_superuser`, `shell`), and shared `civitas.toml` loading through `civitas doctor`.
- PHASE 24: socket-free integration harnesses for HTTP, email, tasks, and SEO, with `test_client`, `test_mail`, `test_tasks`, and `test_seo`.
- PHASE 25: realtime protocols with `civitas/sse`, `civitas/websocket`, `civitas/sse_presence`, and `civitas/ws_room`, including SQLite relay, RFC 6455 handshake, lightweight SSE presence, persistent WS room trails, and `25E` with the canonical project scaffold.
- PHASE 26: in-process benchmark support with `civitas/bench`, per-request profiler with N+1 detection, memory profiler with allocation/live-byte deltas, and `civitas/perf_report` for HTML + `hotspots.ctrace` + the real animated CCT sigil.
- PHASE 27: operational storage topology in `StorageTopology`, verifiable backup for SQLite and media, safe restore with `pre-restore`, and local binary rollback for file-backed environments.
- PHASE 28: final hardening for the 1.0 line with `security_audit`, `fuzz_http`, `load_test`, `mem_watch`, `dep_review`, local CVE base, and generation of the final documentation and release bundle.

Civitas now exposes the compositional core of the web framework, the formal infrastructure for internal decoupling, the operational configuration base for real applications, the first active security layer of the framework, the official HTML rendering layer via compiled templates or a programmatic builder, the canonical server-side forms cycle, the cross-request state layer, the canonical user-media pipeline, the first structured data/content layer, the multi-backend database infrastructure for concurrent workloads, the first official coordinated cache layer, the data/testing utilities for safe schema evolution, the multi-locale i18n/l10n baseline, the full authentication and authorization layer of the framework, the canonical account-recovery-by-email flows, the first operational background-work subsystem of the framework, the first native operational administrative layer of Civitas, the programmatic/public API layer with technical SEO and external distribution, the first native request observability layer of the framework, the first live visualization layer for those traces, the first native hot-reload development loop, and the final audit/benchmark/release layer that closes the 1.0 line. Sessions, auth, tokens, permissions, identity middleware, login rate limiting, password reset, email verification, mailer, transactional templates, uploads, static files, storage, images, video, private delivery, taxonomy, comments, editorial moderation, pages, pooling, transactions, search, locks, caches, fixtures, factories, import/export, internationalization, asynchronous tasks, recurring scheduler, safe retention, media jobs, editorial automations, admin registry, administrative CRUD, inlines, moderation, operational dashboard, REST API, OpenAPI, sitemap, feeds, redirects, embeds, exports, trace collector, trace store, explicit subsystem spans, SVG trace renderer, local diagnostics panel, offline endpoint export, watch-based automatic rebuild, HTML toolbar, livereload, structural security audit, HTTP fuzzing, in-process load, memory watch, local dependency review, and release bundling now grow on top of stable contracts for request, response, context, routing, lifecycle, settings, services, reliable post-commit publication, default transport/request protection, typed rendering, declarative form processing, identity persistence, explicit query/migration behavior, backend-decoupled database infrastructure, predictable read invalidation, off-request execution, deterministic request locale resolution, and local request traceability.

The planned Civitas 1.0 line ends at PHASE 28. Phases `29`, `30`, and `31` are no longer part of the executable roadmap for this version.

## Known Issues

- The current HTTP runtime is synchronous and process-local. In practice, the web loop is `accept -> dispatch -> respond`, so one slow or stuck request can stall other requests handled by the same process.
- Civitas does not currently promise internal multithreading or preemptive cancellation in the web runtime. The operational model documented by the framework is still `web process + worker process + scheduler process`, not a threaded application server.
- This means a single Civitas web process is not a robust production topology for hostile or bursty public traffic. Health checks, home pages, and user requests still contend for the same request loop when they hit the same process.
- Reverse proxying with `nginx` improves buffering and connection handling, but it does not change the execution model of the Civitas application process itself.
- File-backed sessions, local trace persistence, and SQLite as the primary production database amplify the impact of this limitation because they keep more work and more contention inside the same process and host-local state.
- Civitas should not currently be presented as suitable for real production deployment. Until the framework has a formal serving model with real concurrency guarantees, the current web runtime should be treated as development-grade and operationally fragile under public traffic.

## Relationship to CCT

Civitas is a web framework for CCT. The CCT compiler remains a separate project and must be installed externally to compile, test, and run this repository.

This repository does not embed the compiler. The public contract is:

- Civitas declares the minimum supported version in `cct.toml`;
- build and tests discover the compiler through `CCT_BIN` or `PATH`;
- current expected compatibility is `CCT >= 0.40.0`.

## Requirements

- CCT reporting `>= 0.40.0`
- `cct-host` or `cct` available in `PATH`, or `CCT_BIN` pointing to the correct binary
- `make`
- POSIX environment

## Official Commands

```bash
make build
make test
make examples
make clean
```

If the compiler is not on `PATH`, use:

```bash
CCT_BIN=/path/to/cct-host make build
```

## First Example

The canonical example lives in `examples/salve_civitas/`.

```bash
make examples
./examples/salve_civitas/dist/salve_civitas
```

By default, the server listens on `0.0.0.0:8080` and responds with:

```text
Salve, Civitas
```

Operational controls accepted by the example:

- `CIVITAS_HOST`
- `CIVITAS_PORT`
- `CIVITAS_MAX_REQUESTS`
- `CIVITAS_READY_FILE`
- `CIVITAS_DONE_FILE`

The `Makefile` resolves the compiler through `CCT_BIN` or `PATH`, trying `cct-host` first and then `cct`. The same contract applies to `tests/run_tests.sh`.

When `CIVITAS_READY_FILE` and `CIVITAS_DONE_FILE` are used in integration and the environment does not allow `bind`, the process marks `skip` in those files to signal host network unavailability instead of masking the failure as a valid HTTP response.

## Repository Structure

```text
civitas/
├── cct.toml
├── Makefile
├── src/
│   └── main.cct
├── lib/
│   └── civitas/
│       ├── core/
│       ├── http/
│       └── web/
├── examples/
│   └── salve_civitas/
├── tests/
│   └── integration/
└── docs/
```

## Publication

- [CONTRIBUTING.md](CONTRIBUTING.md) describes the contribution flow.
- [SECURITY.md](SECURITY.md) describes the responsible disclosure process.
- [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) describes the project conduct standard.

## Core Through PHASE 28

The PHASE 1 HTTP base remains in `lib/civitas/http/server.cct` and supporting modules. On top of it, PHASE 2 adds:

- `lib/civitas/request_core.cct`: `WebRequest` with case-insensitive headers, query params, cookies, path params, and operational metadata;
- `lib/civitas/response.cct`: `WebResponse` with text, HTML, JSON, redirect, cookie, `405`, and optional gzip helpers;
- `lib/civitas/middleware.cct`: ordered pipeline with per-request context, timing, recovery, and basic CORS;
- `lib/civitas/router.cct`: groups, typed params, named routes, `404/405`, and sigil manifest;
- `lib/civitas/visibility.cct`: canonical `public/private/followers/restricted/deleted/moderation` policy;
- `lib/civitas/pagination.cct`: `page/page_size`, `offset/limit`, sort allowlist, and shareable pagination metadata.

PHASE 3 adds the explicit decoupling infrastructure:

- `lib/civitas/signals.cct`: `Signal`, `SignalEnvelope`, `stop/continue` policies, built-ins `request_started`, `request_finished`, `request_failed`, and `post_request`;
- `lib/civitas/events.cct`: `EventBus`, `EventEnvelope`, subscribe by `event_type`, simple attribute filter, and local synchronous publish;
- `lib/civitas/outbox.cct`: durable `fs_json` outbox, explicit transaction, `claim_batch`, lease, retry, dead-letter, and republish to the local bus only after commit.

PHASE 4 adds the canonical operations and bootstrap layer:

- `lib/civitas/core/settings.cct`: `civitas.toml` loader, per-environment files, env override, value source tracking, strict mode, and safe dump;
- `lib/civitas/core/app.cct`, `app_module.cct`, and `lifecycle.cct`: `Application`, module registry, ordered startup/shutdown, health, and integration with router/middleware/signals/events;
- `lib/civitas/core/storage_settings.cct`, `services.cct`, and `external_tools.cct`: media storage, Redis, mail, search, proxy, and operational prerequisite verification;
- `lib/civitas/core/keyring.cct` and `secrets.cct`: domain secrets, `active_key_id`, deterministic verify candidates, explicit legacy compatibility, and leak-free dump.

PHASE 5 adds the baseline security layer:

- `lib/civitas/security.cct`: `SecurityConfig`, HSTS, per-request CSP nonce, host allowlist, IP token bucket, and path-traversal protection;
- `lib/civitas/csrf.cct`: cookie binding, HMAC derivation, constant-time validation, hidden-field helper, and failure serialization;
- `lib/civitas/csrf_runtime.cct` and `csrf_middleware.cct`: validation with keyring candidates, contextual logging, and automatic integration in application dispatch.
- `lib/civitas/abuse/abuse.cct` and `abuse/abuse_middleware.cct`: route-specific rate-limit classes, per-actor upload quota, spam signals, preventive moderation hooks, and complementary `429/retry-after` middleware.

PHASE 6 adds the compiled rendering layer and HTML builder:

- `lib/civitas/template/lexer.cct`, `parser.cct`, `ast.cct`, `checker.cct`, `codegen.cct`, and `compiler.cct`: template language with `EVOCA`, expressions, filters, `SI`, `DUM`, `EXTENDE`, `SECTIO`, `ADVOCARE`, `CSRF`, `NEXUS`, `NONCE`, and `LITERAL`, all verified at build time;
- `bin/cct-template-compile.cct`: official CLI to compile one file or a `templates/` tree into generated CCT modules;
- `lib/civitas/template/context.cct`, `filters.cct`, and `integration.cct`: `LoopContext`, canonical filters, static/nonce/CSRF integration helpers, and render contracts;
- `lib/civitas/html.cct`: programmatic builder with tags, attrs, safe escaping, controlled raw output, forms, and navigable pagination;
- `lib/civitas/template_extras/`: editorial pagination, query string, SEO, asset/media, and breadcrumb helpers for public sites;
- `Makefile`: `template-compile` target and automatic integration of template compilation into `build`.

PHASE 7 adds the full forms cycle:

- `lib/civitas/forms/forms.cct` and `lib/civitas/forms/multipart.cct`: `FormData`, `UploadedFile`, `urlencoded` and `multipart` parsing, upload limits, and typed accessors;
- `lib/civitas/validate/validate.cct` and `lib/civitas/validate/sanitize.cct`: declarative rules (`required`, size, numeric range, regex, email, URL, choices), cross-field validation, and canonical sanitization;
- `lib/civitas/sanitize/text.cct`, `sanitize/html.cct`, `sanitize/url.cct`, and `sanitize/contact.cct`: whitespace normalization, allowlist-based HTML sanitization, embed policy, and rich email/phone validation;
- `lib/civitas/forms/render.cct`: `FieldDef`, `FormDef`, field rendering, error summary, safe refill, no password replay, automatic hidden CSRF, and controlled extra attributes per field, wrapper, and form;
- `lib/civitas/html.cct`: formal contract for `html_child`, `html_append_child`, `html_render`, `html_render_free`, and `html_free` for rendering with progressive flattening and predictable cleanup.

PHASE 8 adds cross-request state, the identity base, and the semantic file-reference type:

- `lib/civitas/session/session.cct`: `SessionStore`, `SessionConfig`, `Session`, HMAC-signed cookie, typed getters, expiration, ID rotation, memory/file/SQLite/Redis backends, and per-user invalidation in Redis backend;
- `lib/civitas/session/session_mem.cct`, `session_file.cct`, `session_db.cct`, `session_redis.cct`, and `session_remember.cct`: backend-specific initialization and helpers, remember-me, and Redis handle access;
- `lib/civitas/flash/flash.cct` and `flash_render.cct`: `FlashLevel`, `FlashMessage`, `pending -> current` promotion, HTML render with escaping, and session integration;
- `lib/civitas/auth_context/auth_context.cct`: population of `LocalContext` with `user_id`, `session_id`, `locale`, and per-request auth helpers;
- `lib/civitas/upload_descriptor/upload_descriptor.cct` and `upload_descriptor/upload_descriptor_helpers.cct`: `UploadState`, `UploadDescriptor`, `temp/final/orphan` transitions, tolerant JSON serialization, and hash-based comparison for file fields in `FkBlob`;
- `lib/civitas/template/ast.cct`, `lexer.cct`, `parser.cct`, `checker.cct`, and `codegen.cct`: support for the `{% SIGNA %}` tag with `session`-context checking.

PHASE 9 adds the canonical upload, storage, and media-delivery pipeline:

- `lib/civitas/request_core.cct`, `request.cct`, `request_http.cct`, and `request_server.cct`: `WebRequest` with `corpo_bruto`/`corpo_bruto_ativo` for streaming uploads directly from the server socket;
- `lib/civitas/upload/upload_types.cct`, `upload.cct`, `upload_buffer.cct`, `upload_stream.cct`, and `upload_save.cct`: `UploadConfig`, `UploadedFile`, `MultipartResult`, buffered/streaming parse, magic-byte validation, and save with canonical naming;
- `lib/civitas/static/static_index.cct`, `static_headers.cct`, and `static.cct`: `StaticIndex`, `StaticFile`, content hash in name, ETag, `304 Not Modified`, and serving in development/production mode;
- `lib/civitas/storage/storage.cct`, `storage_url.cct`, and `storage_gc.cct`: `MediaStore` configuration, zoned promotion, public URL, signed URLs with secret rotation, and orphan tmp GC;
- `lib/civitas/media_image/image_types.cct`, `image_exif.cct`, `image_derive.cct`, and `image.cct`: image validation, EXIF stripping, predefined derivatives, moderation state, and soft delete;
- `lib/civitas/media_video/video_types.cct`, `video_thumb.cct`, `video_transcode.cct`, and `video.cct`: `ffprobe`-based probing, video validation, `sd/hd` specs, thumb extraction, transcode, processing/moderation states, and soft delete;
- `lib/civitas/media_delivery/delivery_range.cct`, `delivery_accel.cct`, and `delivery.cct`: signed-link verification, range-request parsing, direct `206` serving, `X-Accel-Redirect`, and `X-Sendfile`;
- `lib/civitas/template/integration.cct`: `{% NEXUS %}` helper integrated with the static-file index.

PHASE 10 adds the first explicit data and content layer:

- `lib/civitas/model/model.cct`, `model_ddl.cct`, `model_hooks.cct`, and `model_registry.cct`: `FieldKind`, `FieldDef`, `IndexDef`, `ModelDef`, DDL generation for SQLite, named hooks, and opaque model registration by table;
- `lib/civitas/query/query.cct`, `query_exec.cct`, `query_mut.cct`, `query_raw.cct`, and `query_prefetch.cct`: inspectable query builder with `SELECT`, filters, `JOIN`, `ORDER`, `LIMIT/OFFSET`, `COUNT`, `EXISTS`, parameterized mutations, and row iteration via prepared statement;
- `lib/civitas/migrate/migrate.cct`: versioned migrations with canonical table, `run`, rollback of the last step, and `status`;
- `lib/civitas/taxonomy/`: locale-aware slugs, categories, tags, and polymorphic tag linking to objects;
- `lib/civitas/social/`: comments with states, idempotent reactions, materialized view counters, and soft delete;
- `lib/civitas/authorship/`: content origin by context, authorship population, persisted review state, and audit-trail emission;
- `lib/civitas/pages/`: CRUD for institutional pages, SEO, menu, scheduling, and listing of published pages.

PHASE 11 adds the canonical multi-backend database layer and safe concurrency:

- `lib/civitas/db_handle/db_handle.cct`, `db_handle_sqlite.cct`, and `db_handle_postgres.cct`: uniform `DbHandle` and `DbRows` over SQLite and PostgreSQL, with `exec`, `query`, `scalar`, begin/commit/rollback, savepoints, and typed row reading;
- `lib/civitas/query/query_exec.cct`, `query_mut.cct`, and `lib/civitas/migrate/migrate.cct`: migration of the query builder and migrator to `DbHandle`, preserving explicit SQL while hiding the concrete backend only in the handle;
- `lib/civitas/pool/pool.cct`, `pool_sqlite.cct`, and `pool_postgres.cct`: per-process pool with prewarm, acquire timeout, health check, reconnection, metrics, and `com_pool(...)`;
- `lib/civitas/transaction/transaction.cct`: `TxContext`, nesting depth, automatic savepoints, and `com_transacao(...)` with predictable rollback/commit;
- `lib/civitas/search/search.cct`, `search_registry.cct`, `search_schema.cct`, and `search_build.cct`: PostgreSQL full-text index registry, DDL/SQL generation, and multi-type search composition;
- `lib/civitas/locks/locks.cct`, `locks_keys.cct`, `locks_guard.cct`, `locks_job.cct`, and `locks_log.cct`: PostgreSQL advisory locks, canonical namespaces by resource, idempotent guard, and event trail for concurrent jobs.

PHASE 12 adds the canonical multi-layer cache layer:

- `lib/civitas/cache/cache.cct`, `cache_api.cct`, `cache_mem.cct`, `cache_arq.cct`, and `cache_redis.cct`: `CacheHandle`, unified memory/file/Redis backend, explicit TTL, namespace flush, and hit/miss/eviction metrics;
- `lib/civitas/cache_view/cache_view.cct`, `cache_view_chave.cct`, `cache_view_serial.cct`, `cache_view_tags.cct`, `cache_view_ops.cct`, and `cache_view_middleware.cct`: HTTP response cache with key derived from method/path/`Vary`, response serialization, tag-based invalidation, and GET/HEAD middleware;
- `lib/civitas/cache_query/cache_query.cct`, `cache_query_serial.cct`, `cache_query_exec.cct`, and `cache_query_signal.cct`: query-result cache in JSON, deterministic key by SQL + parameters, and coordinated invalidation by table/signal;
- `lib/civitas/cache_invalidation/invalidation.cct`, `invalidation_scope.cct`, `invalidation_exec.cct`, `invalidation_signal.cct`, `stampede.cct`, `stampede_mem.cct`, and `stampede_redis.cct`: invalidation coordination across 12A/12B/12C and anti-stampede via claim/wait/release with local or Redis backend.

PHASE 13 adds the auxiliary data and migration layer:

- `lib/civitas/fixtures/fixture.cct`, `fixture_loader.cct`, `fixture_exec.cct`, and `fixture_ref.cct`: declarative fixtures in JSON/TOML, installation into the database, and lookup by reference;
- `lib/civitas/factory/factory.cct`, `factory_seq.cct`, `factory_build.cct`, `factory_exec.cct`, and `factory_rel.cct`: deterministic factories, overrides, dependencies, and persistence for test suites;
- `lib/civitas/test_db/test_db.cct`, `test_db_setup.cct`, `test_db_tx.cct`, and `test_db_assert.cct`: SQLite test database, automatic schema from registry, and savepoint-based isolation;
- `lib/civitas/data_io/data_io.cct`, `data_import.cct`, `data_export.cct`, and `data_backfill.cct`: administrative import/export of JSON, CSV, TOML, and slug/blob backfill;
- `lib/civitas/django_migrate/django_migrate.cct`, `django_schema_map.cct`, `django_fixture_import.cct`, `django_media_import.cct`, and `django_parity.cct`: one-way toolkit for Django → Civitas migration with count and checksum parity.

PHASE 14 adds the baseline for internationalization and localization:

- `lib/civitas/i18n/i18n.cct`, `i18n_registry.cct`, `i18n_translate.cct`, and `i18n_context.cct`: `I18nConfig`, `I18nRegistry`, loading of `.po` catalogs, locale lookup, fallback to default locale, and reading the active locale from `LocalContext`;
- `lib/civitas/l10n/l10n.cct`, `l10n_rules.cct`, `l10n_number.cct`, `l10n_date.cct`, and `l10n_currency.cct`: `LocaleRules`, per-locale rule registry, and localized formatting of integers, decimals, percentages, dates, datetimes, and currencies;
- `lib/civitas/locale/locale.cct`, `locale_accept.cct`, `locale_negotiate.cct`, `locale_cookie.cct`, and `locale_middleware.cct`: `Locale` type, BCP 47 parsing, `Accept-Language` parsing, exact/language-match negotiation, cookie-based preference, and locale injection into `LocalContext`;
- `lib/civitas/i18n_catalog_json/i18n_catalog_json.cct`, `i18n_catalog_json_loader.cct`, `i18n_catalog_json_writer.cct`, and `i18n_catalog_json_merge.cct`: native JSON catalog format, round-trip to file, merge, and integration with the registry without opening a parallel translation engine to `cct/gettext`;
- `lib/civitas/l10n_fmt/l10n_fmt.cct`, `l10n_fmt_rules.cct`, `l10n_fmt_reltime.cct`, `l10n_fmt_date_long.cct`, `l10n_fmt_ordinal.cct`, and `l10n_fmt_list.cct`: relative time, month names, long date, ordinals, and conjunction-based lists per locale.

PHASE 15 adds the full authentication and identity layer:

- `lib/civitas/auth/auth.cct`, `auth_hash.cct`, `auth_users.cct`, `auth_login.cct`, `auth_decorators.cct`, and `auth_schema.cct`: `User`, `AuthError`, `AuthConfig`, portable PBKDF2-SHA256 hashing, signup, login, deactivation, and login/permission decorators;
- `lib/civitas/auth_token/auth_token.cct`, `auth_token_issue.cct`, `auth_token_verify.cct`, `auth_token_revoke.cct`, `auth_token_refresh.cct`, and `auth_token_schema.cct`: stateless HMAC tokens, bearer parsing, `jti` blacklist, persisted refresh token, and rotation with reuse detection;
- `lib/civitas/permissions/permissions.cct`, `permissions_db.cct`, `permissions_assign.cct`, `permissions_check.cct`, `permissions_object.cct`, and `permissions_schema.cct`: explicit permissions by code, groups, deduplication of effective permissions, and object scope;
- `lib/civitas/session/session.cct`, `session_store.cct`, `session_data.cct`, `session_cookie.cct`, `session_middleware.cct`, and `session_schema.cct`: server-side session integrated with the request, JSON data, canonical cookie, destruction by user, and purge of expired sessions;
- `lib/civitas/auth_middleware/auth_context.cct`, `auth_bearer.cct`, `auth_session_resolve.cct`, `auth_middleware.cct`, and `auth_guards.cct`: `AuthContext`, bearer/session/anonymous resolution, and standard guards for web and API;
- `lib/civitas/auth_rate_limit/auth_rate_limit.cct`, `auth_rate_limit_check.cct`, and `auth_rate_limit_schema.cct`: sliding-window logic in SQLite, key by email/IP, temporary block, and `429` response;
- `lib/civitas/auth_test/auth_test.cct`, `auth_test_user.cct`, `auth_test_token.cct`, `auth_test_session.cct`, and `auth_test_request.cct`: schema setup, identity factories, and authenticated request builders for tests.

PHASE 16 adds the canonical email and account-recovery flows:

- `lib/civitas/auth_flows/auth_flows.cct`, `auth_flows_schema.cct`, `auth_flows_history.cct`, `auth_flows_reset.cct`, and `auth_flows_email.cct`: signed TTL tokens, password reset, password history, email verification, and email change with confirmation;
- `lib/civitas/mailer/mailer.cct`, `mailer_settings.cct`, `mailer_send.cct`, and `mailer_schema.cct`: Civitas wrapper over `cct/mail` and `cct/mail_spool`, with memory/file/SMTP backend and settings-derived configuration;
- `lib/civitas/mail_templates/mail_tpl_base.cct`, `mail_tpl_reset.cct`, `mail_tpl_verificar.cct`, `mail_tpl_alterar_email.cct`, and `mail_tpl_boas_vindas.cct`: dual-body transactional emails with simple HTML and text fallback;
- `lib/civitas/mail_test/mail_test.cct`, `mail_test_assert.cct`, `mail_test_extract.cct`, and `mail_test_flow.cct`: in-memory email capture, declarative assertions, token extraction by URL, and full-flow helpers for integration suites.

PHASE 17 adds the canonical background execution and operational automation layer:

- `lib/civitas/tasks/tasks.cct`: persistent queue, retry/backoff, attempts, dead letter, callback registry, and unary worker over `DbHandle`;
- `lib/civitas/scheduled/scheduled.cct`: cron/interval, scheduling policies, `scheduled_jobs`, `scheduled_runs`, and a tick that only enqueues work;
- `lib/civitas/retention/retention.cct`: cutoff-based cleanup of task/scheduler history, completed jobs, and tmp dir with persistable report;
- `lib/civitas/media_jobs/media_jobs.cct`: asynchronous media derivation by descriptor, hash/variant dedupe, fallback, and approval;
- `lib/civitas/editorial_jobs/editorial_jobs.cct`: translation via external process, sitemap, feed, rankings, counters, and editorial run trail.

PHASE 18 adds the operational admin layer:

- `lib/civitas/admin/`: model registry, admin schema, listing, single-item lookup, CRUD, bulk operations, auditing, inlines, per-action permission, custom actions, widgets, and CSV export;
- `lib/civitas/admin_moderation/`: moderation queues, decision history, and best-effort bulk handling of pending items;
- `lib/civitas/admin_dashboard/`: persisted metric snapshots, task-queue views, recent failures, and scheduled dashboard refresh task.

PHASE 19 adds the programmatic and public layer:

- `lib/civitas/api/api.cct`: serializers, validation, envelopes, and pagination for REST API;
- `lib/civitas/api_views/api_views.cct`: generic CRUD, viewsets, filters, ordering, bearer auth, and versioning;
- `lib/civitas/openapi/openapi.cct`: `OpenAPI 3.1` spec derived from real registries and cached in SQLite;
- `lib/civitas/seo/seo.cct`: `robots.txt`, sitemap, feeds, canonical/hreflang, legacy redirects, and public static pages;
- `lib/civitas/embed/embed.cct`: HTML embed, `oEmbed`, bearer-protected JSON export, and CSV export with administrative basic auth.

PHASE 20 adds the request observability layer:

- `lib/civitas/trace_config/trace_config.cct` and `trace_bootstrap.cct`: per-app tracing configuration, env override, and bootstrap of the CCT instrumentation mode;
- `lib/civitas/trace/trace_spans.cct`, `trace_request.cct`, `trace_session.cct`, and `trace_capture_flush.cct`: framework span helpers, per-request drain, trace flush, and session capture for tests;
- `lib/civitas/trace_collector/trace_collector.cct`: sampling, `trace_id`, integration with `RequestContext`, `x-trace-id` header, and persistence in `.ctrace`;
- `lib/civitas/trace_store/trace_store.cct`: local SQLite trace index, operational queries, and retention;
- `lib/civitas/trace/trace_sql.cct`, `trace_cache.cct`, `trace_storage.cct`, `trace_media.cct`, `trace_mail.cct`, `trace_i18n.cct`, `trace_moderation.cct`, and `trace_task.cct`: explicit spans for the framework’s main subsystems.

PHASE 21 adds the trace visualization and operation layer:

- `lib/civitas/trace_render/trace_render.cct`: animated SVG renderer with timeline, legend, step-by-step view, configurable theme, and side-by-side comparison;
- `lib/civitas/trace_panel/trace_panel.cct`: HTML panel at `/civitas/traces`, operational filters, detail view with embedded SVG, pure SVG per route, and replay via `curl`;
- `lib/civitas/trace_export/trace_export.cct`: grouping by observed endpoint and offline ZIP package with `index.html`, HTML detail pages, and representative SVGs.

PHASE 22 adds the iterative developer feedback layer:

- `lib/civitas/dev_server/dev_server.cct`: watch of `.cct`, rebuild, error parsing, and target restart;
- `lib/civitas/debug_toolbar/debug_toolbar.cct`: HTML toolbar with SQL, cache, headers, and the real embedded request sigil;
- `lib/civitas/dev_livereload/dev_livereload.cct`: generation-based polling, reload endpoint, and snippet injection into HTML.

PHASE 23 adds the native project scaffolding and CLI layer:

- `lib/civitas/civitas_new/civitas_new.cct`: generation of the initial tree for `minimal`, `web`, and `api` templates, with `civitas.toml`, `src/`, `static/`, `templates/`, and README;
- `lib/civitas/civitas_generate/civitas_generate.cct`: model, migration, API, and admin generators with deterministic CCT/SQL output;
- `lib/civitas/civitas_management/civitas_management.cct`: management commands for migrations, rollback, seed, shell, test, collect static, and superuser;
- `lib/civitas/civitas_config/civitas_config.cct`: shared `civitas.toml` loader, environment expansion, canonical defaults, validation, and project `doctor`.

PHASE 24 adds the canonical integration-harness layer:

- `lib/civitas/test_client/test_client.cct`: socket-free HTTP client over `router_dispatch`, with cookie jar, default headers, and response/JSON assertions;
- `lib/civitas/test_mail/test_mail.cct`: in-memory email outbox over `MailClient`, with declarative assertions for delivery and content;
- `lib/civitas/test_tasks/test_tasks.cct`: SQLite `:memory:` task queue with real schema, local registry, and synchronous flush in the same process;
- `lib/civitas/test_seo/test_seo.cct`: helpers for sitemap, robots, meta tags, proxy headers, multipart upload, and range requests.

PHASE 25 adds the framework’s realtime base:

- `lib/civitas/sse/sse.cct`: `SseEvent`, `SseWriter`, `SseBus`, `text/event-stream` serialization, keepalive, and bridge from named signals to SQLite broadcast;
- `lib/civitas/websocket/websocket.cct`: upgrade detection, RFC 6455 handshake with `ws_accept_key(...)`, frame encode/decode, `WsConn`, polling/publication in channel, and WS route registration;
- `lib/civitas/sse_presence/sse_presence.cct`: lightweight room presence with `join/heartbeat/leave/sweep` and unread-notification inbox in SQLite;
- `lib/civitas/ws_room/ws_room.cct`: active members, auditable event log, temporary mute, persisted ban, and expiration sweeps for WebSocket rooms.

Important operational limit of the current implementation:

- `router_add_sse(...)` and `router_add_ws(...)` already register the raw transport in the router;
- the default HTTP dispatch still rejects those routes with an internal error if they are treated as ordinary HTTP routes;
- the protocol and state modules are closed and tested, but final delivery of the raw socket to a dedicated runtime is still the responsibility of the edge that hosts those routes.

PHASE 26 adds the canonical performance diagnostics layer:

- `lib/civitas/bench/bench.cct`: in-process benchmark over `test_client`, with `BenchConfig`, `BenchResult`, percentiles, throughput, JSON roundtrip, and SQLite history;
- `lib/civitas/profiler/profiler.cct`: per-request span middleware, top rituals, query grouping, N+1 detection, persistence in `request_profiles`, and profile reconstruction with `profiler_read_recent(...)`;
- `lib/civitas/memory_profiler/memory_profiler.cct`: snapshots of `mem_instr_*`, persistence of `mem_deltas`, aggregate report, and `x-civitas-mem-leak` header on suspicious requests;
- `lib/civitas/perf_report/perf_report.cct`: self-contained HTML report, emission of `hotspots.ctrace`, and rendering of the full animated CCT sigil from those hotspots.

Supporting HTTP libraries delivered earlier and still in use:

- `lib/civitas/url.cct`
- `lib/civitas/cookie.cct`
- `lib/civitas/mime.cct`

## Tests

The unified runner remains `tests/run_tests.sh`.

The suite now validates:

- the historical baseline of PHASE 0;
- subphases 1A-1F of PHASE 1;
- subphases 2A-2F of PHASE 2;
- subphases 3A-3C of PHASE 3;
- subphases 4A-4D of PHASE 4;
- subphases 5A-5C of PHASE 5;
- subphases 6A-6D of PHASE 6;
- subphases 7A-7E of PHASE 7;
- subphases 8A-8D of PHASE 8;
- subphases 9A-9F of PHASE 9;
- subphases 10A-10G of PHASE 10;
- subphases 11A-11E of PHASE 11;
- subphases 12A-12D of PHASE 12;
- subphases 13A-13E of PHASE 13;
- subphases 14A-14E of PHASE 14;
- subphases 15A-15G of PHASE 15;
- subphases 16A-16D of PHASE 16;
- subphases 17A-17E of PHASE 17;
- subphases 18A-18E of PHASE 18;
- subphases 19A-19E of PHASE 19;
- subphases 20A-20D of PHASE 20;
- subphases 21A-21C of PHASE 21;
- subphases 22A-22C of PHASE 22;
- subphases 23A-23D of PHASE 23;
- subphases 24A-24D of PHASE 24;
- subphases 25A-25E of PHASE 25;
- subphases 26A-26D of PHASE 26;
- subphases 27A-27B of PHASE 27;
- subphases 28A-28D of PHASE 28;
- 783 real integration tests across bootstrap, HTTP server, web core, lifecycle, settings, external services, secrets, signals, events, outbox, baseline security, complementary anti-abuse, compiled templates, HTML builder, editorial/public helpers, rich content sanitization, forms cycle, server-side session/auth layer, canonical upload descriptor, media pipeline, first data/content layer with schema, query builder, migrations, taxonomy, social, authorship, pages, `DbHandle`, pool, transactions, search, locks, multi-layer cache, coordinated invalidation, anti-stampede, fixtures, factory, test database, administrative data IO, Django migration toolkit, i18n/l10n baseline, full authentication with tokens/permissions/rate limit, transactional email flows with reset and verification, the background subsystem with tasks/scheduler/retention/media/editorial jobs, the operational admin layer, the REST/OpenAPI/SEO/embed surface, the tracing layer, collector and local request diagnostics, the live sigil renderer/panel/export layer, the local development loop with watch/toolbar/livereload, the native project scaffolding/configuration CLI with separation between bootstrap, user apps, and runtime artifacts, the socket-free integration harnesses, the realtime base with SSE/WebSocket/presence, the local benchmark/profiler/memory profiler/perf report layer with the real CCT sigil, the production-oriented operational base for storage, backup, restore, and local binary rollback, and the final audit, fuzzing, load, and release block of the 1.0 line.

## Additional Documentation

- `docs/INDEX.md`
- `docs/manuals/SISTEMA_FASE_0.md`
- `docs/manuals/SISTEMA_FASE_1.md`
- `docs/manuals/SISTEMA_FASE_2.md`
- `docs/manuals/SISTEMA_FASE_3.md`
- `docs/manuals/SISTEMA_FASE_4.md`
- `docs/manuals/SISTEMA_FASE_5.md`
- `docs/manuals/SISTEMA_FASE_6.md`
- `docs/manuals/SISTEMA_FASE_7.md`
- `docs/manuals/SISTEMA_FASE_8.md`
- `docs/manuals/SISTEMA_FASE_9.md`
- `docs/manuals/SISTEMA_FASE_10.md`
- `docs/manuals/SISTEMA_FASE_11.md`
- `docs/manuals/SISTEMA_FASE_12.md`
- `docs/manuals/SISTEMA_FASE_13.md`
- `docs/manuals/SISTEMA_FASE_14.md`
- `docs/manuals/SISTEMA_FASE_15.md`
- `docs/manuals/SISTEMA_FASE_16.md`
- `docs/manuals/SISTEMA_FASE_17.md`
- `docs/manuals/SISTEMA_FASE_18.md`
- `docs/manuals/SISTEMA_FASE_19.md`
- `docs/manuals/SISTEMA_FASE_20.md`
- `docs/manuals/SISTEMA_FASE_21.md`
- `docs/manuals/SISTEMA_FASE_22.md`
- `docs/manuals/SISTEMA_FASE_23.md`
- `docs/manuals/SISTEMA_FASE_24.md`
- `docs/manuals/SISTEMA_FASE_25.md`
- `docs/manuals/SISTEMA_FASE_26.md`
- `docs/manuals/SISTEMA_FASE_27.md`
- `docs/manuals/SISTEMA_FASE_28.md`
- `docs/specs/FASE_0_BOOTSTRAP.md`
- `docs/specs/FASE_1_SERVIDOR_HTTP_UTILIZAVEL.md`
- `docs/specs/FASE_2_WEB_CORE.md`
- `docs/specs/FASE_3_SIGNALS_EVENTS_OUTBOX.md`
- `docs/specs/FASE_4_CONFIGURACAO_E_AMBIENTES.md`
- `docs/specs/FASE_5_SEGURANCA_BASE.md`
- `docs/specs/FASE_6_TEMPLATES_E_HTML.md`
- `docs/specs/FASE_7_FORMS_E_VALIDACAO.md`
- `docs/specs/FASE_8_SESSAO_E_FLASH.md`
- `docs/specs/FASE_9_UPLOAD_STATIC_E_MEDIA.md`
- `docs/specs/FASE_10_ORM_E_MIGRATIONS.md`
- `docs/specs/FASE_11_POSTGRES_POOL_TRANSACOES_SEARCH_E_LOCKS.md`
- `docs/specs/FASE_12_CACHE_MULTICAMADA.md`
- `docs/specs/FASE_13_FIXTURES_FACTORY_TEST_DB_E_MIGRACAO.md`
- `docs/specs/FASE_14_I18N_E_L10N_BASELINE.md`
- `docs/specs/FASE_15_AUTENTICACAO_COMPLETA.md`
- `docs/specs/FASE_16_RECUPERACAO_E_EMAIL.md`
- `docs/specs/FASE_17_TASKS_SCHEDULER_RETENCAO_MEDIA_EDITORIAL.md`
- `docs/specs/FASE_18_ADMIN_OPERACIONAL.md`
- `docs/specs/FASE_19_API_REST_PUBLICACAO_E_EMBEDS.md`
- `docs/specs/FASE_20_SIGILO_VIVO_INSTRUMENTACAO_DE_REQUEST.md`
- `docs/specs/FASE_21_SIGILO_VIVO_RENDER_PAINEL_EXPORT.md`
- `docs/specs/FASE_22_DEV_SERVER_E_HOT_RELOAD.md`
- `docs/specs/FASE_23_SCAFFOLDING_E_CLI.md`
- `docs/specs/FASE_24_TEST_HARNESS_HTTP_MAIL_TASKS_SEO.md`
- `docs/specs/FASE_25_WEBSOCKETS_E_SSE.md`
- `docs/specs/FASE_26_PROFILING_E_BENCHMARK.md`
- `docs/specs/FASE_27_DEPLOY_E_PRODUCAO.md`
- `docs/specs/FASE_28_HARDENING_FINAL_E_AUDITORIA.md`
- `docs/release/FASE_0_RELEASE_NOTES.md`
- `docs/release/FASE_1_RELEASE_NOTES.md`
- `docs/release/FASE_2_RELEASE_NOTES.md`
- `docs/release/FASE_3_RELEASE_NOTES.md`
- `docs/release/FASE_4_RELEASE_NOTES.md`
- `docs/release/FASE_5_RELEASE_NOTES.md`
- `docs/release/FASE_6_RELEASE_NOTES.md`
- `docs/release/FASE_7_RELEASE_NOTES.md`
- `docs/release/FASE_8_RELEASE_NOTES.md`
- `docs/release/FASE_9_RELEASE_NOTES.md`
- `docs/release/FASE_10_RELEASE_NOTES.md`
- `docs/release/FASE_11_RELEASE_NOTES.md`
- `docs/release/FASE_12_RELEASE_NOTES.md`
- `docs/release/FASE_13_RELEASE_NOTES.md`
- `docs/release/FASE_14_RELEASE_NOTES.md`
- `docs/release/FASE_15_RELEASE_NOTES.md`
- `docs/release/FASE_16_RELEASE_NOTES.md`
- `docs/release/FASE_17_RELEASE_NOTES.md`
- `docs/release/FASE_18_RELEASE_NOTES.md`
- `docs/release/FASE_19_RELEASE_NOTES.md`
- `docs/release/FASE_20_RELEASE_NOTES.md`
- `docs/release/FASE_21_RELEASE_NOTES.md`
- `docs/release/FASE_22_RELEASE_NOTES.md`
- `docs/release/FASE_23_RELEASE_NOTES.md`
- `docs/release/FASE_24_RELEASE_NOTES.md`
- `docs/release/FASE_25_RELEASE_NOTES.md`
- `docs/release/FASE_26_RELEASE_NOTES.md`
- `docs/release/FASE_27_RELEASE_NOTES.md`
- `docs/release/FASE_28_RELEASE_NOTES.md`
- `docs/phase_map.md`

## License

MIT.
