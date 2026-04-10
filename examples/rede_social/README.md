# rede_social

`rede_social` is a fresh Civitas example built from the current scaffold shape instead of being derived from `mural_expandido`.

It is intentionally small, but it exposes most of the framework surface added between PHASE 20 and PHASE 28:

- request tracing hooks and trace-aware headers
- compiled CCT sigil access plus request-sigil surfaces
- trace panel and trace export
- session + CSRF browser flows
- activity persistence through the example repository itself
- lounge event log through `ws_room`
- memory profiling and perf report generation
- security audit
- dependency review
- backup snapshots
- generated docs and release bundle
- separated project/app layout from the newer scaffolding line

## Project Layout

- `project/`
  - bootstrap and runtime entrypoint
  - route composition root
- `apps/public`
  - feed and profile pages
- `apps/accounts`
  - login/logout
- `apps/social`
  - likes, comments, follows, and lounge log
- `apps/ops`
  - operational pages and sigils
- `apps/shared`
  - state, repository, template contexts, and operational helpers
- `templates/`
  - source HTML templates for public pages, account pages, social pages, and ops pages
- `gen/`
  - generated CCT renderers produced by `build_templates`
- `settings/`
  - placeholders for base/dev/prod project notes
- `data/`
  - sqlite, sessions, traces, media, and backups generated at runtime
- `.civitas/`
  - generated reports, docs, and release artifacts kept outside source control

## Run

```sh
cd examples/rede_social
CCT_BIN="${CCT_BIN:-$(command -v cct-host || command -v cct)}"
"$CCT_BIN" build_templates.cct
./build_templates
"$CCT_BIN" bootstrap_db.cct
"$CCT_BIN" project/main.cct
./bootstrap_db
./project/main
```

Default URL:

- `http://127.0.0.1:18082`

Seed users:

- `luna@rede.social` / `abc123`
- `nora@rede.social` / `abc123`
- `ian@rede.social` / `abc123`

Ops Basic Auth:

- `admin` / value of `REDE_SOCIAL_ADMIN_PASSWORD`

## Main Surfaces

- `/`
- `/entrar`
- `/perfil/luna`
- `/posts/luzes-na-ponte`
- `/lounge`
- `/api/feed`
- `/api/activity`
- `/ops`
- `/ops/traces`
- `/sigilos-vivos`
- `/sigilos-vivos/export.zip`

## What Was Easy in Civitas

- The current scaffold style makes it straightforward to separate bootstrap, domain apps, and runtime state.
- The compiled template pipeline keeps page markup in `templates/` and leaves CCT app views responsible for typed data preparation.
- `router_match` plus explicit route names made it easy to keep hierarchical URLs while still owning the dispatch loop in the example.
- `trace_collector`, `trace_store`, `trace_panel`, `trace_render`, and `trace_export` fit together cleanly once the request loop was under control.
- `security_audit`, `dep_review`, `backup`, `doc_gen`, and `release` are useful as directly callable operational modules, not just hidden internals.
- `session` and `csrf` are already usable without forcing the full application container.

## What Was Harder in Civitas

- Template generation is an explicit step today. If a template or context changes, run `./build_templates` before rebuilding `project/main.cct`.
- The in-process bench/load helpers integrate best with pure router handler references. A stateful custom dispatch loop is more flexible for real examples, but less direct for benchmark tooling.
- Realtime concepts from PHASE 25 are stronger at the persistence/log layer than at browser socket handoff for custom examples. In this example, that becomes an activity lane and a room log, not a full browser WebSocket chat.
- Request-trace persistence is the roughest integration point in this example. The app therefore always exposes the compiled project sigil and treats request-specific sigils as an additional layer when trace files are actually present.
- Operational modules are available, but composing them into a single polished app still requires manual response shaping and permission policy in the example layer.

## Notes

- New application pages should start in `templates/*.html`, then receive data through `apps/shared/template_contexts.cct`. Do not copy old builder-style page construction into new apps.
- `sigilos-vivos` always shows the compiled project sigil and is ready to show persisted request sigils when trace files are available.
- External media is used on purpose to show how a small social app mixes local state with public web media.
- Reports and bundles are written to disk so the user can inspect the generated artifacts after browsing the example.
- Runtime state under `data/` and `.civitas/` is intentionally excluded from git.
