# PHASE 1 Release Notes

## Deliverables

- usable synchronous HTTP/1.1 server in `lib/civitas/http/server.cct`;
- `lib/civitas/url.cct` library;
- `lib/civitas/cookie.cct` library;
- `lib/civitas/mime.cct` library;
- parser and connection hardening with explicit timeouts and limits;
- safe proxy awareness with `trusted_proxies`;
- automatic `request_id` and minimal access log;
- expansion of the unified suite to cover PHASE 0 and PHASE 1.

## Relevant Decisions

- the PHASE 1 server remains synchronous and blocking by architectural decision;
- `X-Forwarded-*` is honored only when the immediate peer is in `trusted_proxies`;
- the default `request_id` uses UUIDv7;
- a received `X-Request-Id` is reused only when explicitly authorized;
- keep-alive idle timeout closes the connection without an extra response;
- the canonical access log records only minimal fields and does not include body/cookies.

## Test Coverage

In addition to the historical PHASE 0 tests, PHASE 1 adds:

- 9 tests in `1A`
- 8 tests in `1B`
- 9 tests in `1C`
- 9 tests in `1D`
- 9 tests in `1E`
- 8 tests in `1F`

Total for PHASE 1: 52 integration tests.

## Gate Status

Block 1A-1F closes only when:

- subphases 1A-1F are green in isolation;
- the full `tests/run_tests.sh` run is green;
- the documentation is synchronized with the contract actually delivered.
