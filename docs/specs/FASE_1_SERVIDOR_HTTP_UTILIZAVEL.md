# Consolidated Spec — PHASE 1

## Implemented Scope

This spec consolidates the behavior materialized in block 1A-1F.

## HTTP Server

The implemented server is:

- synchronous;
- blocking;
- host-only;
- oriented toward deployment behind a reverse proxy.

Capabilities effectively delivered:

- accept loop;
- request-line parsing;
- header parsing;
- body via `Content-Length`;
- body via `Transfer-Encoding: chunked`;
- keep-alive;
- response serialization;
- signal-based shutdown;
- statistics snapshot.

## Supporting Contracts

### URL

- absolute and relative parsing;
- simple and multi-valued query parsing;
- URL/query building;
- path normalization.

### Cookie

- `Cookie` parsing;
- `Set-Cookie` build/parse;
- cookie signing and protection.

### MIME

- broad extension registry;
- explicit binary fallback;
- `Content-Type` parsing with parameters;
- simple selection via `Accept`.

## Hardening

`HttpServerOptions` exposes configurable limits and timeouts.

Implemented error classes:

- `ParseErrMalformedRequestLine`
- `ParseErrMalformedHeader`
- `ParseErrHeaderOverflow`
- `ParseErrBodyOverflow`
- `ParseErrTimeout`
- `ParseErrTruncatedBody`
- `ParseErrInvalidChunked`

Status mapping:

- `431` for header overflow;
- `413` for body overflow;
- `408` for timeout;
- `400` for invalid, truncated, or invalid-chunked requests.

## Proxy Awareness

Implemented contract:

- `trusted_proxies` is an explicit list of trusted hosts/IPs;
- `X-Forwarded-*` is ignored outside that list;
- `X-Forwarded-For` uses the first item in the chain when authorized;
- `X-Forwarded-Proto` and `X-Forwarded-Host` only alter context when the peer is trusted;
- `X-Request-Id` is only reused when authorized by configuration.

## Request ID

Effective policy:

- default: generate UUIDv7;
- if `allow_proxy_request_id = true` and the peer is trusted, use the received `X-Request-Id`;
- the final id is stored in `HttpRawRequest.request_id`;
- the suite probe returns it in `x-request-id`.

## Access Log

The materialized canonical line contains:

- `request_id`
- `client_ip`
- `scheme`
- `method`
- `path`
- `status`
- `duration_ms`
- `response_bytes`

The current contract avoids exposing body content and sensitive headers.

## Compatibility Notes

- the project continues using `cct-host` as the operational default compiler;
- the documented minimum compatibility remains aligned with the `v0.40.0` environment.
