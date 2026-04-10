# PHASE 0 Release Notes

## Deliverables

- Initial Civitas repository structure.
- `cct.toml` as the project manifest.
- `Makefile` with the official operational flow.
- Base modules in `lib/civitas/core`, `lib/civitas/http`, and `lib/civitas/web`.
- Canonical `Salve, Civitas` example listening on `8080`.
- Unified runner `tests/run_tests.sh`.
- Initial documentation consistent with the implemented code.

## Relevant Decisions

- Automatic compatibility verification uses the version reported by the compiler (`v0.40.0` in the current environment).
- The local functional baseline up to CCT phase 40 matches the minimum version declared for this phase.
- The Civitas `Makefile` uses `cct-host` by default to work around the current failure of the selfhost wrapper in `build --project` outside the CCT repository.
- The canonical example gained explicit `skip` signaling for test environments without `bind` permission, preserving the visible operational contract without forcing a false network positive.
- The canonical example gained minimal operational controls via environment variables to allow end-to-end tests without distorting the standard flow.

## Gate Status

Block 0A-0E is considered closed only when:

- the code compiles;
- the PHASE 0 suite is green;
- the documentation is synchronized with the real behavior.
