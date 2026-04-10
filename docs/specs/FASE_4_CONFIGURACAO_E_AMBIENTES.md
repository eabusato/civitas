# Consolidated Spec — PHASE 4

## Implemented Scope

This spec consolidates the behavior delivered in block `4A-4D`.

## Settings and Environment

`lib/civitas/core/settings.cct` and `settings_schema.cct` stabilize the canonical configuration layer.

Implemented contract:

- mandatory `civitas.toml` file;
- optional selection of `civitas.<env>.toml`;
- `CIVITAS_ENV` as the environment selector;
- env override through names defined in the schema;
- strict mode that fails on unknown keys;
- typed getters and value source tracking;
- safe dump with no secret leakage.

Parsing and precedence contracts:

- precedence is `default -> file_base -> file_environment -> env -> test_override`;
- list values `LIST<VERBUM>` are serialized internally and deserialized for typed use;
- `normalize_path` resolves relative paths against `project_root`;
- paths already under `project_root` are not duplicated.

## Application and Lifecycle

`lib/civitas/core/app.cct`, `app_module.cct`, and `lifecycle.cct` stabilize application bootstrap.

Implemented contract:

- `Application` with settings, router, middleware, signals, event bus, and service registry;
- module registration by name with duplicate rejection;
- ordered startup and ordered shutdown;
- partial rollback if a module fails during startup;
- health endpoint/state with degraded component marking.

## Storage and External Services

`storage_settings.cct`, `services.cct`, `external_tools.cct`, and `app_services.cct` stabilize typed integrations.

Implemented contract:

- local media storage with canonical directories;
- object storage with validation of required credentials;
- Redis with DSN parsing and preserved Civitas timeouts;
- `smtp`, `file`, and `memory` mail backends;
- typed search and proxy configuration;
- verification of `ffmpeg`/`ffprobe` executables.

Operational contracts:

- missing `media.root_dir` fails early;
- `mail.memory` is only accepted in `test`;
- `mail.file` is not accepted in `production`;
- proxy and search settings have explicit validation.

## Secrets and Rotation

`keyring.cct` and `secrets.cct` stabilize the domain keyring.

Implemented domains:

- `session`
- `csrf`
- `signed_cookie`
- `token`
- `temporary_link`

Implemented contract:

- `SecretDomain`, `SecretKey`, `SecretKeyRing`, `SecretRotationPolicy`, `SecretLookupResult`, and `SecretRegistry`;
- active key per domain;
- grace policy with eligible legacy keys;
- deterministic validation-candidate order;
- lookup by `key_id`;
- global legacy compatibility only under explicit flag;
- safe dump with operational metadata.

Context-resolution contracts:

- `active_key_id` identifies the key used for new signatures;
- `verify_candidates` returns the active key followed by eligible legacy keys in declared order;
- disabled domain does not block boot and appears as `enabled=false` in the safe dump;
- absence of secret material in env fails early during registry loading.

Security and serialization contracts:

- raw secret material is read from env and is never emitted in `safe_dump`;
- `safe_dump` exposes only domain, status, `active_key_id`, candidate count, `grace_seconds`, and global-legacy usage;
- global legacy migration only occurs when `legacy_global_key_enabled=true`.

## Test Coverage

PHASE 4 adds 30 integration tests:

- 8 in `4A`
- 6 in `4B`
- 8 in `4C`
- 8 in `4D`
