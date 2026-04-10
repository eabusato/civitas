# Consolidated Spec — PHASE 5

## Implemented Scope

This spec consolidates the behavior delivered in block `5A-5C`.

## Transport and Request Security

`lib/civitas/security.cct` stabilizes the baseline protection layer.

Implemented contract:

- `SecurityConfig`, `HstsPolicy`, `CspPolicy`, `RateLimitBucket`, `RateLimiter`, and `SecurityMetrics`;
- per-request CSP nonce using `csprng_bytes(16)` and hex serialization;
- `security_headers_apply(...)` with `Content-Security-Policy`, `X-Frame-Options`, `X-Content-Type-Options`, and `Referrer-Policy`;
- `Strict-Transport-Security` emitted when `enforce_https=true`;
- host validation against `allowed_hosts`;
- IP rate limiting with in-memory token bucket;
- `path_is_safe(...)` to block traversal outside the root.

Parsing and resolution contracts:

- hosts are normalized to lowercase and stripped of port before comparison;
- file paths pass through `url_decode`, `path_join`, and `normalize`;
- CSP with nonce injects `'nonce-<valor>'` into `script-src` and `style-src` when `use_nonces=true`;
- a present nonce implies `cache-control: no-store`.

## Automatic App Integration

`lib/civitas/core/app.cct` stabilizes the automatic application of these policies in dispatch.

Implemented contract:

- security services are materialized lazily from settings;
- dispatch blocks invalid host with `400`;
- dispatch blocks insecure request with `400` when `enforce_https=true`;
- dispatch blocks IP above burst with `429`;
- dispatch always applies security headers to the final response, including blocked responses.

Observability contracts:

- rejection by host, HTTPS, and rate limit generates warning with method, path, and IP;
- metrics for rejected host, rate limit, and path traversal are maintained in the app runtime.

## CSRF

`lib/civitas/csrf.cct`, `csrf_runtime.cct`, and `csrf_middleware.cct` stabilize stateless CSRF protection.

Implemented contract:

- `CsrfConfig`, `CsrfToken`, and `CsrfError`;
- random 32-byte binding in cookie;
- token derived by `hmac_sha256(secret, binding)`;
- constant-time comparison with `constant_time_compare`;
- explicit bearer-token exclusion when `exclude_bearer=true`;
- use of keyring candidates to support rotation of `csrf_secret`;
- HTML helper `csrf_input_field(...)`;
- binding cookie with `SameSite=Strict`, `HttpOnly`, and `Secure` when applicable.

Context-resolution contracts:

- safe methods do not go through CSRF validation;
- mutating methods validate header `X-CSRF-Token` before falling back to body;
- if the header is missing, the `application/x-www-form-urlencoded` body is inspected using the configured field name;
- missing secret, missing cookie, missing token, and invalid token are distinct errors in runtime and log.

## Complementary Anti-Abuse

`lib/civitas/abuse/abuse.cct` and `abuse_middleware.cct` stabilize the complementary anti-abuse layer.

Implemented contract:

- `RateLimitClass`, `RateLimitRule`, and `RateLimitKey` for granular per-route-class limits;
- `QuotaPolicy` and `QuotaCheckResult` for per-actor upload quota in a fixed window;
- `SpamSignal`, `SpamCheckConfig`, and `SpamCheckResult` for passive abuse signals on submissions;
- preventive moderation hook registry with opaque bridge via `SPECULUM NIHIL`;
- route middleware with `429` and `retry-after` response when the route-specific limit is exceeded.

Context-resolution contracts:

- rate-limit class is assigned explicitly on the route, not inferred from path;
- route-bucket key combines IP, class, and `actor_id` when provided;
- per-route rate limit is a complementary layer and does not replace global IP rate limiting from `security.cct`;
- integration into `Application` is explicit: the route limit only works when store and rules are installed as services and the abuse middleware is registered;
- upload quota checks before and records only after successful persisted upload;
- `spam_check(...)` does not query database or external service and only returns signals/score; final decision remains in the handler or hook.

## Test Coverage

PHASE 5 adds 26 integration tests:

- 8 in `5A`
- 10 in `5B`
- 8 in `5C`
