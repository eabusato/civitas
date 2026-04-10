# Manual Aprofundado do Sistema — FASE 1

## Visão geral

A FASE 1 transforma o Civitas em um servidor HTTP/1.1 síncrono utilizável, com parsing auxiliar e hardening operacional mínimo.

O bloco 1A-1F implementa:

- transporte HTTP/1.1 host-only e bloqueante;
- parsing de request line, headers, `Content-Length` e `Transfer-Encoding: chunked`;
- keep-alive e shutdown previsível;
- módulos auxiliares `url`, `cookie` e `mime`;
- limites e timeouts configuráveis de parser e conexão;
- resolução segura de `X-Forwarded-*` sob política explícita de proxy confiável;
- `request_id` automático e access log canônico.

## Transporte HTTP

O servidor atual é deliberadamente simples:

- um processo;
- um worker por processo;
- sem TLS interno;
- sem cluster interno;
- operação pensada para uso atrás de reverse proxy.

O módulo central é `lib/civitas/http/server.cct`.

Os tipos públicos relevantes incluem:

- `HttpServerOptions`
- `HttpRawRequest`
- `HttpRawResponse`
- `HttpServerError`
- `HttpParseError`
- `HttpConnectionPolicy`
- `TrustedProxyPolicy`
- `ForwardedRequestInfo`
- `AccessLogEntry`

## Contrato de parsing e serialização

### Requests

O parser aceita:

- request line `METHOD target HTTP/x.y`;
- headers normalizados para chave minúscula;
- body por `Content-Length`;
- body por `Transfer-Encoding: chunked`;
- keep-alive em HTTP/1.1, com `Connection: close` respeitado.

Campos principais de `HttpRawRequest` após a FASE 1:

- `method`
- `target`
- `version`
- `headers`
- `body`
- `request_id`
- `client_ip`
- `scheme`
- `original_host`
- `proxy_addr`
- `remote_addr`
- `local_addr`
- `keep_alive`
- `started_ms`

### Responses

`HttpRawResponse` continua sendo serializado pelo servidor com:

- status line HTTP/1.1;
- `Content-Type` default `text/plain; charset=utf-8` quando ausente;
- `Content-Length` calculado quando ausente;
- `Connection: keep-alive` ou `Connection: close` conforme o ciclo atual.

## Contrato de hardening

`HttpServerOptions` expõe:

- `read_header_timeout_ms`
- `read_body_timeout_ms`
- `idle_timeout_ms`
- `max_header_bytes`
- `max_header_count`
- `max_body_bytes`
- `max_request_bytes`

Erros de parser são classificados em:

- `ParseErrMalformedRequestLine`
- `ParseErrMalformedHeader`
- `ParseErrHeaderOverflow`
- `ParseErrBodyOverflow`
- `ParseErrTimeout`
- `ParseErrTruncatedBody`
- `ParseErrInvalidChunked`

Mapeamento operacional implementado:

- overflow de header: `431`
- overflow de body: `413`
- timeout de leitura ativa: `408`
- request line/header/body/chunked inválidos: `400`

Política de conexão:

- erros de request ativa usam `ConnPolicyRespondAndClose`;
- timeout de idle em keep-alive usa `ConnPolicyCloseImmediate`;
- keep-alive só continua quando o request foi parseado com segurança.

## URL, cookies e MIME

### `lib/civitas/url.cct`

Entrega:

- parse de URL absoluta e relativa;
- query string simples e multivalorada;
- build determinístico de query;
- normalização de path;
- helpers de junção e porta default por scheme.

### `lib/civitas/cookie.cct`

Entrega:

- parse de header `Cookie`;
- build e parse de `Set-Cookie`;
- atributos principais (`Path`, `Domain`, `Expires`, `Max-Age`, `Secure`, `HttpOnly`, `SameSite`);
- cookies assinados;
- cookies protegidos por cifra simétrica baseada em keystream derivado por HMAC.

### `lib/civitas/mime.cct`

Entrega:

- registry canônico com mais de 200 extensões;
- fallback explícito para `application/octet-stream`;
- parse de `Content-Type` em `ContentType` com `MimeType` e mapa de parâmetros;
- helpers `mime_is_text`, `mime_is_json`, `mime_is_binary`, `mime_charset`;
- negotiation simples de `Accept`.

## Proxy awareness

`HttpServerOptions` agora inclui:

- `trusted_proxies`
- `enable_request_id`
- `enable_access_log`
- `honor_x_forwarded_for`
- `honor_x_forwarded_proto`
- `honor_x_forwarded_host`
- `allow_proxy_request_id`

Política implementada:

- `X-Forwarded-For`, `X-Forwarded-Proto` e `X-Forwarded-Host` só são honrados quando o peer imediato da conexão está na lista explícita `trusted_proxies`;
- a cadeia de `X-Forwarded-For` usa o primeiro valor não vazio;
- fora desse contexto, o Civitas usa o peer real da conexão e scheme `http`;
- `X-Request-Id` recebido só é reaproveitado quando o peer é confiável e `allow_proxy_request_id = true`;
- no fluxo padrão, o servidor gera `request_id` novo via UUIDv7.

## Access log

O formato canônico produzido pelos helpers da FASE 1 é linha única com:

- `request_id`
- `client_ip`
- `scheme`
- `method`
- `path`
- `status`
- `duration_ms`
- `response_bytes`

O formato não inclui:

- corpo da request;
- cookies;
- headers sensíveis.

## Testes

`tests/run_tests.sh` agora cobre:

- FASE 0 inteira como baseline histórico;
- FASE 1A-1F com filtros por subfase.

A FASE 1 adiciona 52 testes de integração reais distribuídos em:

- `tests/integration/fase_1/1a/`
- `tests/integration/fase_1/1b/`
- `tests/integration/fase_1/1c/`
- `tests/integration/fase_1/1d/`
- `tests/integration/fase_1/1e/`
- `tests/integration/fase_1/1f/`
