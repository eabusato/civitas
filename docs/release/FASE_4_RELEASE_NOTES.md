# PHASE 4 Release Notes

## Deliverables

- `lib/civitas/core/settings.cct`, `settings_schema.cct`, and `settings_env.cct` with canonical TOML loader, env override, strict mode, and safe dump;
- `lib/civitas/core/app.cct`, `app_module.cct`, `lifecycle.cct`, and `app_services.cct` with `Application`, modules, lifecycle, health, and service materialization;
- `lib/civitas/core/storage_settings.cct`, `services.cct`, and `external_tools.cct` with storage, Redis, mail, search, proxy, and binary verification;
- `lib/civitas/core/keyring.cct` and `secrets.cct` with per-domain keyrings, rotation, lookup, and explicit legacy compatibility;
- expansion of the unified runner to cover `4A-4D`.

## Relevant Decisions

- `civitas.toml` is the runtime contract; `cct.toml` does not replace application settings;
- env override remains disciplined by the framework schema;
- external services fail early when required credentials, paths, or binaries are missing;
- parsing of secret lists avoids direct unwrap of `Result<SPECULUM NIHIL, SettingsError>` in the loader, using the supported path through `SettingsValue.serialized`;
- empty TOML arrays were avoided in secrets tests when they were semantically equivalent to field omission.

## Test Coverage

PHASE 4 adds:

- 8 tests in `4A`
- 6 tests in `4B`
- 8 tests in `4C`
- 8 tests in `4D`

Total for PHASE 4: 30 integration tests.

## Gate Status

Block `4A-4D`, closing PHASE 4, is only considered complete when:

- `4A` is green in isolation;
- `4B` is green in isolation;
- `4C` is green in isolation;
- `4D` is green in isolation;
- the full `tests/run_tests.sh` run is green with no historical regression;
- the consolidated documentation is synchronized with the behavior actually delivered.
