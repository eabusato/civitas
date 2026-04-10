# Consolidated Spec — PHASE 0 Bootstrap

## Implemented Scope

This spec describes the behavior actually implemented in block 0A-0E.

## Structure and Namespaces

The repository exposes the following stable axes for growth:

- `lib/civitas/core/`
- `lib/civitas/http/`
- `lib/civitas/web/`
- `examples/`
- `tests/`
- `docs/`

Namespaces effectively materialized:

- `civitas/core/version`
- `civitas/http/server`
- `civitas/web/app`

## Project Manifest

The root `cct.toml` file declares:

- project name;
- Civitas version;
- project entrypoint;
- minimum CCT version;
- recorded functional baseline of the environment;
- build and phase metadata.

## Compatibility Policy

The `make check-cct` target:

1. locates the configured CCT binary;
2. extracts the version reported by `--version`;
3. compares it against `cct_min_version`;
4. fails early with an explicit message when the version is insufficient.

In the current environment, the `Makefile` points to `cct-host` as the stable operational default.

## Minimal Implemented API

### `lib/civitas/core/version.cct`

Delivers:

- `civitas_name()`
- `civitas_version()`
- `civitas_cct_min_version()`
- `civitas_capability_floor()`
- `civitas_banner()`

### `lib/civitas/http/server.cct`

Delivers:

- default host `0.0.0.0`
- default port `8080`
- `listen/accept` wrapper over `cct/http`
- text response with `Content-Type: text/plain; charset=utf-8`
- `X-Civitas-Version` header

### `examples/salve_civitas/main.cct`

Delivers:

- sequential HTTP server;
- `Salve, Civitas` response;
- optional support for `CIVITAS_HOST`, `CIVITAS_PORT`, `CIVITAS_MAX_REQUESTS`, `CIVITAS_READY_FILE`, and `CIVITAS_DONE_FILE`.
- `skip` marking in `ready/done` when the integration environment does not allow `sock_bind`.

## Build Flow

Official targets:

- `make build`
- `make test`
- `make examples`
- `make clean`
- `make run-example`

## Tests

The official runner is `tests/run_tests.sh`.

The PHASE 0 suite covers:

- repository structure;
- manifest and compatibility gate;
- `Makefile` targets;
- documentary artifacts of the phase;
- behavior of the HTTP example.
