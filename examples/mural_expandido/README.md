# Mural Expandido

`Mural Expandido` is a full Civitas sample application that stays entirely inside `examples/mural_expandido`. It starts from the canonical `Mural` idea, then stretches it into a small creative social product with feed, profiles, reactions, moderation, locale switching, public API, and live ops traces.

## What It Demonstrates

- real HTML pages rendered by the example itself
- static asset serving with a richer visual layer
- SQLite persistence through an explicit repository
- hashed passwords plus signed file-backed sessions
- flash feedback and server-side validation
- profile graph with follows
- social reactions and view counters
- moderated comments
- localized UI in `pt-BR` and `en-US`
- public JSON API
- in-process feed caching
- request tracing with an ops screen

## Runtime Surface

- `GET /`
- `GET /registrar`
- `POST /registrar`
- `GET /entrar`
- `POST /entrar`
- `POST /sair`
- `GET /perfil/{handle}`
- `POST /perfil/{handle}/seguir`
- `GET /posts/{slug}`
- `POST /posts`
- `POST /posts/{slug}/comentarios`
- `POST /posts/{slug}/reagir/{like|love|bookmark}`
- `GET /locale/{locale}`
- `GET /api/posts`
- `GET /api/posts/{slug}`
- `GET /admin-lite`
- `POST /admin-lite/comments/{id}/approve`
- `POST /admin-lite/comments/{id}/reject`
- `POST /admin-lite/cache/flush`
- `GET /ops/traces`
- `GET /ops/traces/{trace_id}`

## Local Structure

- `main.cct`: HTTP bootstrap and server lifecycle
- `bootstrap_db.cct`: schema creation and demo seed
- `lib/config.cct`: example-local config loader
- `lib/state.cct`: session, cache, i18n, l10n, and trace bootstrap
- `lib/repository.cct`: repository and seed data
- `lib/web_runtime.cct`: forms, flash, and session helpers
- `lib/views.cct`: page rendering
- `lib/raw_server.cct`: raw HTTP routing and API surface
- `locales/`: JSON catalogs used by the example
- `static/`: CSS and fallback poster art

## First Run

```bash
cd examples/mural_expandido
CCT_BIN="${CCT_BIN:-$(command -v cct-host || command -v cct)}"
"$CCT_BIN" bootstrap_db.cct
./bootstrap_db
"$CCT_BIN" main.cct
./main
```

Default URL:

- [http://127.0.0.1:8081](http://127.0.0.1:8081)

Seeded demo accounts:

- `admin@mural.expandido` / `abc123`
- `luna@mural.expandido` / `abc123`
- `teo@mural.expandido` / `abc123`

These accounts are for local development and demos only.

Operational fallback for `admin-lite`:

- basic auth user: `admin`
- basic auth password: value of `[mural_expandido].admin_secret` in `civitas.toml`

## Deploying on a Server

1. Edit `civitas.toml`.
2. Set `[app].allowed_hosts` to the public IP or domain.
3. Keep `[http].host = "0.0.0.0"` if the process must listen externally.
4. Change:
   - `[mural_expandido].admin_secret`
   - `[mural_expandido].session_secret`
5. Open the chosen port or place the process behind a reverse proxy.

Example:

```toml
[app]
allowed_hosts = ["203.0.113.10", "social.example.com"]

[http]
host = "0.0.0.0"
port = 8081
```

Environment overrides are also supported:

```bash
export CIVITAS_HTTP__HOST=0.0.0.0
export CIVITAS_HTTP__PORT=8081
export CIVITAS_APP__ALLOWED_HOSTS="203.0.113.10,social.example.com"
export MURAL_EXPANDIDO_ADMIN_SECRET="replace-me"
export MURAL_EXPANDIDO_SESSION_SECRET="replace-me-too"
```

## Storage and Operations

- SQLite database: `var/mural_expandido.db`
- Session files: `var/sessions`
- Trace files: `var/traces`
- Feed cache: in-process memory cache scoped to this example

## Notes

- The example uses remote image and video URLs so the feed looks alive without shipping heavy local media.
- Template compiler artifacts remain in the folder, but the runtime HTML is intentionally produced by `lib/views.cct` so the example stays explicit and inspectable.
- The implementation stays isolated to `mural_expandido`; it does not require changes to the Civitas core.
- Runtime state under `var/` is intentionally excluded from git.
