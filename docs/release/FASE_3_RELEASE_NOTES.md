# PHASE 3 Release Notes

## Deliverables

- `lib/civitas/signals.cct` with local signals, error policies, and request-cycle built-ins;
- `lib/civitas/events.cct` with explicit event bus, envelopes, filters, and local synchronous publish;
- `lib/civitas/outbox.cct` with durable `fs_json` backend, explicit transaction, lease, retry, and dead-letter;
- expansion of the unified runner to cover `3A-3C`.

## Relevant Decisions

- `post_request` was stabilized as a compatibility hook in the same window as `request_finished`;
- event publish remains local to the process in this phase;
- the outbox assumes `at-least-once`, not exactly-once;
- `dedupe_key` is persisted, but is not a uniqueness constraint;
- the initial outbox backend is file-backed to close the semantics before the future relational layer.

## Test Coverage

PHASE 3 adds:

- 6 tests in `3A`
- 6 tests in `3B`
- 6 tests in `3C`

Total for PHASE 3: 18 integration tests.

## Gate Status

Block `3A-3C`, closing PHASE 3, is only considered complete when:

- `3A` is green in isolation;
- `3B` is green in isolation;
- `3C` is green in isolation;
- the full `tests/run_tests.sh` run is green with no historical regression;
- the consolidated documentation is synchronized with the behavior actually delivered.
