# PHASE 2 Release Notes

## Deliverables

- `lib/civitas/request_core.cct` and supporting request layers;
- `lib/civitas/response.cct` and HTTP response serialization;
- `lib/civitas/middleware.cct` with per-request context and minimal built-ins;
- `lib/civitas/router.cct` with typed params, groups, named routes, and sigil support;
- `lib/civitas/visibility.cct` with the canonical visibility policy;
- `lib/civitas/pagination.cct` with offset/limit pagination and sort allowlist;
- expansion of the unified runner to cover `2A-2F`.

## Relevant Decisions

- the web body remains in `VERBUM`;
- middleware remains based on named rituals and explicit registries;
- visibility and permission were kept as separate contracts;
- core pagination is offset/limit, without query builder or cursor pagination;
- the router is already born as a source of sigil metadata, not as a later heuristic.

## Test Coverage

PHASE 2 adds:

- 9 tests in `2A`
- 10 tests in `2B`
- 10 tests in `2C`
- 7 tests in `2D`
- 7 tests in `2E`
- 7 tests in `2F`

Total for PHASE 2: 50 integration tests.

## Gate Status

Block `2E-2F`, closing PHASE 2, is only considered complete when:

- `2E` is green in isolation;
- `2F` is green in isolation;
- the full `tests/run_tests.sh` run is green with no historical regression;
- the consolidated documentation is synchronized with the behavior actually delivered.
