# Mural

`Mural` is the canonical Civitas example after phase 9. It demonstrates:

- HTML page rendering with compiled Civitas templates
- form handling with server-side validation
- one-request flash messages over a short-lived cookie
- explicit SQLite persistence through a repository layer
- static CSS delivery through Civitas static helpers
- a tiny `admin-lite` area protected by HTTP Basic Auth
- real HTTP serving through the Civitas server

## Layout

- `main.cct`: HTTP server bootstrap
- `build_templates.cct`: compiles `templates/*.html` into `gen/*.cct`
- `bootstrap_db.cct`: creates the SQLite schema
- `lib/config.cct`: example-local config/runtime loader
- `lib/repository.cct`: explicit SQLite repository
- `lib/views.cct`: form rendering and page rendering
- `lib/web_runtime.cct`: request handlers
- `lib/raw_server.cct`: raw HTTP integration over the Civitas server

## Features

- `GET /`: renders the page title, form, and latest 20 messages
- `POST /mensagens`: validates input, stores the message, and redirects with flash
- `GET /admin-lite`: protected with HTTP Basic Auth
- `POST /admin-lite/mensagens/{id}/delete`: deletes one message
- `GET /static/app.css`: serves the canonical stylesheet

The example intentionally stays inside the stable Civitas surface up to phase 9 plus closed complements:

- no ORM abstraction
- no session-backed auth
- no uploads
- no features that conceptually belong to later phases

## First Run

Run everything from the example directory:

```bash
cd examples/mural
CCT_BIN="${CCT_BIN:-$(command -v cct-host || command -v cct)}"
"$CCT_BIN" build_templates.cct
./build_templates
"$CCT_BIN" bootstrap_db.cct
./bootstrap_db
"$CCT_BIN" main.cct
./main
```

Then open:

- [http://127.0.0.1:8080](http://127.0.0.1:8080)
- [http://localhost:8080](http://localhost:8080)

Default credentials for `/admin-lite`:

- username: `admin`
- password: value from `[mural].admin_secret`

## Deploying on a Server

1. Edit `civitas.toml`.
2. Set `[app].allowed_hosts` to the real IP or domain you will use.
3. Keep `[http].host = "0.0.0.0"` if you want to accept external traffic.
4. Change `[mural].admin_secret`.
5. Open the port in your firewall and reverse proxy if needed.

Example:

```toml
[app]
allowed_hosts = ["203.0.113.10", "mural.example.com"]

[http]
host = "0.0.0.0"
port = 8080
```

With that, the app can be reached directly by IP:

- `http://203.0.113.10:8080`

If you prefer environment overrides instead of editing `civitas.toml`, the example respects the canonical Civitas settings envs plus local overrides:

```bash
export CIVITAS_HTTP__HOST=0.0.0.0
export CIVITAS_HTTP__PORT=8080
export CIVITAS_APP__ALLOWED_HOSTS="203.0.113.10,mural.example.com"
export MURAL_ADMIN_SECRET="replace-me"
```

Run from `examples/mural`:

```bash
./bootstrap_db
./main
```

Or from the repo root:

```bash
MURAL_PROJECT_ROOT=examples/mural ./examples/mural/main
```

If you skip the `allowed_hosts` change, the process can still bind to `0.0.0.0`, but Civitas will reject requests whose `Host` header is not explicitly allowed.

## Persistence

The example uses a direct SQLite repository and creates this schema:

```sql
CREATE TABLE IF NOT EXISTS mensagens (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL DEFAULT '',
  body TEXT NOT NULL,
  created_at_ms INTEGER NOT NULL
);
```

`bootstrap_db` is the explicit setup step, and `main` also ensures the schema exists on boot.

## Validation Behavior

- `name`: required, max 80 chars
- `email`: optional, but must be valid if present, max 120 chars
- `body`: required, min 3 chars, max 2000 chars

## Notes

- Flash is implemented with a short-lived cookie (`mural_flash`) to keep the example small and phase-appropriate.
- Uploads are intentionally not enabled in this canonical example to keep it focused on the stable Civitas surface up to phase 9.
- Generated template modules are committed in `gen/`, but `build_templates` is kept as the canonical rebuild step.
- Runtime state is written under `var/` and `tests/tmp/`, which are intentionally ignored by git.
