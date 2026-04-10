# Consolidated Spec — PHASE 3

## Implemented Scope

This spec consolidates the behavior delivered in block `3A-3C`.

## Signals

`lib/civitas/signals.cct` stabilizes the local framework hooks.

Implemented contract:

- `Signal` with name, error policy, ordered handler registry, and ID counter;
- `signal_connect(...)` and `signal_disconnect(...)`;
- synchronous `signal_send(...)`, in connection order;
- `SignalDispatchReport` with `invoked_count`, `failed_count`, `stopped_early`, and `first_error`;
- `signal_send_async(...)` returning `Err("signal async dispatcher nao configurado")` when no asynchronous backend is configured.

Implemented built-ins:

- `request_started`
- `request_finished`
- `request_failed`
- `post_request`

Lifecycle contracts:

- `request_started` is emitted before router dispatch;
- `request_failed` is emitted when a `fractum` is captured during the HTTP cycle;
- `request_finished` and `post_request` are emitted on successful completion, with the same completion payload;
- `signals_dispatch_router_request(...)` converts unhandled error into `500 internal server error`.

## Events

`lib/civitas/events.cct` stabilizes the local application event bus.

Implemented contract:

- explicit `EventBus` per application or service;
- subscribe and unsubscribe by ID;
- simple equality-based attribute filter;
- local synchronous publish;
- `EventEnvelope` with `event_type`, `event_id`, `occurred_at_iso`, `request_id`, `actor_id`, `attributes`, and `payload_json`;
- `EventDispatchReport` with delivery, filtered, and failed counters.

Parsing and resolution contracts:

- `event_type` is compared by exact textual equality;
- filters do not match when the key does not exist;
- `attributes` use stable textual key lookup before update or read;
- `event_envelope_new(...)` generates `event_id` and timestamp at envelope creation time.

## Outbox

`lib/civitas/outbox.cct` stabilizes reliable post-commit publication.

Implemented contract:

- `OutboxStore` with `fs_json` backend;
- entries persisted in JSON and indexed in `_index.json`;
- direct enqueue and transactional enqueue;
- `claim_batch` with lease;
- `mark_published`, `mark_failed`, and `release_lease`;
- republish to the local `EventBus` through `outbox_publish_claimed(...)`;
- shortcut `outbox_after_commit_publish(...)`;
- explicit transaction with begin, commit, rollback, and commit+publish.

Implemented state machine:

- `PENDING -> LEASED`
- `LEASED -> PUBLISHED`
- `LEASED -> FAILED`
- `FAILED -> PENDING` via re-claim after `available_at_unix_ms`
- `FAILED -> DEAD_LETTER` when policy is exceeded
- `LEASED -> DEAD_LETTER` at publish time when the new failure crosses the attempt limit

Serialization contracts:

- `EventEnvelope` is converted to `OutboxEntry` with `payload_json` and `headers_json`;
- `headers_json` preserves `event_id`, `occurred_at_iso`, `request_id`, `actor_id`, and `attributes`;
- `outbox_entry_to_event(...)` reconstructs the envelope from the persisted entry.

Consistency contracts:

- `outbox_tx_rollback(...)` prevents observable enqueue;
- `outbox_tx_commit(...)` persists all pending entries in the transaction;
- `outbox_tx_commit_and_publish(...)` only publishes after a successful commit;
- semantics are `at-least-once`, not exactly-once.

## Parsing, Context Resolution, and Serialization Contracts

### Parsing

- `signal_connect(...)` and `event_subscribe(...)` reject empty names;
- `event_subscribe_filtered(...)` rejects filters with empty keys;
- `outbox_store_open(...)` rejects empty `root_dir` and `default_max_attempts <= 0`.

### Context Resolution

- `signals_dispatch_router_request(...)` resolves `route_name` from the router to enrich lifecycle payloads;
- `EventBus` is an explicit instance and does not depend on an implicit runtime global;
- `OutboxTransaction` keeps pending entries isolated until commit.

### Serialization

- event and outbox payloads are serialized early as `VERBUM`;
- event attributes are carried in a separate structure and are also serialized into the outbox;
- the `fs_json` backend persists outbox state in an auditable way on disk.

## Test Coverage

PHASE 3 adds 18 integration tests distributed across `3A`, `3B`, and `3C`, under the unified runner in `tests/run_tests.sh`.
