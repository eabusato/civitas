# PHASE 5 Release Notes

## Deliverables

- `lib/civitas/security.cct` with canonical headers, nonce-based CSP, host allowlist, IP rate limiting, and path guard;
- `lib/civitas/csrf.cct`, `csrf_runtime.cct`, and `csrf_middleware.cct` with cookie binding, HMAC derivation, constant-time validation, keyring integration, and explicit bearer-token bypass;
- automatic integration of security and CSRF in the dispatch of `lib/civitas/core/app.cct`;
- `lib/civitas/abuse/abuse.cct` and `abuse_middleware.cct` with rate limiting by route class, per-actor upload quota, spam signals, and preventive moderation hooks;
- optional anti-abuse integration into `Application` through services + explicit middleware;
- expansion of the unified runner to cover `5A-5C`.

## Relevant Decisions

- security protection is applied by default in application dispatch, not as an optional handler responsibility;
- the rate-limiting bucket is intentionally per-process and in-memory in this phase;
- the CSRF token is stateless and uses the keyring secret in the `csrf` domain, including rotation candidates;
- the CSRF binding cookie is emitted with `SameSite=Strict`, `HttpOnly`, and `Secure` when the request or policy requires HTTPS;
- the `abuse` layer is complementary and explicit: it does not replace global IP rate limiting and does not auto-enable in the app without registry/middleware;
- moderation hooks were stabilized with an opaque bridge and reference-based decision, preserving compatibility with the current executable subset of CCT.

## Test Coverage

PHASE 5 adds:

- 8 tests in `5A`
- 10 tests in `5B`
- 8 tests in `5C`

Total for PHASE 5: 26 integration tests.

## Gate Status

Block `5A-5C`, closing PHASE 5, is only considered complete when:

- `5A` is green in isolation;
- `5B` is green in isolation;
- `5C` is green in isolation;
- the full `tests/run_tests.sh` run is green with no historical regression;
- the consolidated documentation is synchronized with the behavior actually delivered.
