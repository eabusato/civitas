# Manual Aprofundado do Sistema — FASE 5

## Visão geral

A FASE 5 transforma a segurança base do Civitas em contrato do framework.

O bloco `5A-5C` entrega:

- headers canônicos de segurança aplicados no dispatch da aplicação;
- CSP com nonce aleatório por request;
- validação de `Host` contra allowlist do settings;
- enforcement opcional de HTTPS e rate limiting por IP em memória;
- proteção contra path traversal para serving de arquivos;
- CSRF stateless com HMAC, segredo rotativo do keyring e exclusão explícita para bearer token;
- anti-abuso complementar com rate limiting por classe de rota, quota de upload por ator, sinais de spam e hooks de moderação preventiva.

## Security

O contrato está em `lib/civitas/security.cct`.

Capacidades estabilizadas:

- `security_config_default()` com `X-Frame-Options`, `X-Content-Type-Options`, `Referrer-Policy` e CSP default;
- `csp_nonce_generate()` e `csp_build(...)` para serialização de CSP com nonce por request;
- `security_headers_apply(...)` para aplicar headers diretamente na response final;
- `security_host_is_allowed(...)` com normalização de host e remoção de porta;
- `rate_limiter_new(...)`, `rate_limiter_check(...)` e `rate_bucket_consume(...)` para token bucket por IP;
- `path_is_safe(...)` com `url_decode`, `normalize` e verificação de prefixo dentro da raiz.

Contratos operacionais:

- `allowed_hosts` vazio bloqueia a request inteira; o app registra warning explícito ao materializar os serviços de segurança;
- HSTS só é emitido quando `enforce_https` está ativo;
- CSP com nonce também força `cache-control: no-store` na response;
- rate limiting é por processo e não é distribuído entre workers;
- a checagem de path considera path decodificado e normalizado, não regex.

## Integração com Application

O contrato fica em `lib/civitas/core/app.cct`.

Capacidades estabilizadas:

- `app_ensure_security_services(...)` materializa `SecurityConfig`, `RateLimiter`, métricas e logger a partir de settings;
- `app_dispatch_fill(...)` aplica a ordem de proteção antes do dispatch:
  1. valida host;
  2. valida HTTPS quando exigido;
  3. aplica rate limiting;
  4. executa o gate CSRF;
  5. despacha health ou router;
  6. emite cookie CSRF ausente;
  7. aplica headers de segurança.

Contratos observáveis:

- host inválido retorna `400`;
- HTTPS ausente com enforcement retorna `400`;
- bucket esgotado retorna `429`;
- todas essas rejeições são logadas com método, path e IP.

## CSRF

O contrato está em `lib/civitas/csrf.cct`, `csrf_runtime.cct` e `csrf_middleware.cct`.

Capacidades estabilizadas:

- `csrf_binding_generate()` gera binding de 32 bytes em hex;
- `csrf_token_derive(secret, binding)` usa `hmac_sha256`;
- `csrf_token_validate(...)` usa `constant_time_compare`;
- `csrf_validate_request(...)` lê cookie, header ou campo hidden e retorna erro tipado;
- `csrf_validate_with_candidates(...)` aceita chave ativa e chaves legadas elegíveis do keyring;
- `csrf_input_field(...)` serializa `<input type="hidden">` sanitizado;
- `csrf_binding_cookie(...)` emite cookie `SameSite=Strict`, `HttpOnly` e `Secure` quando a request ou a política exigem HTTPS.

Contratos operacionais:

- métodos `GET`, `HEAD`, `OPTIONS` e `TRACE` não exigem CSRF;
- `Authorization: Bearer` com `exclude_bearer=true` dispensa a validação;
- ausência de `csrf_secret` retorna `403` e gera log de falha;
- falha de token retorna `403` e registra motivo, método, path e IP;
- validação tenta chave ativa e depois candidatas legadas em ordem determinística.

## Anti-abuso complementar

O contrato está em `lib/civitas/abuse/abuse.cct` e `lib/civitas/abuse/abuse_middleware.cct`.

Capacidades estabilizadas:

- `RateLimitClass` canônica (`default`, `auth`, `upload`, `public_form`, `api`);
- `rate_limit_check_route(...)` e `rate_limit_retry_after(...)` para limite específico por classe de rota;
- `quota_check(...)` e `quota_record_upload(...)` para controlar bytes e quantidade de arquivos por ator;
- `spam_check(...)` com sinais de honeypot preenchido, submissão rápida demais, conteúdo repetido, alta densidade de URL e user-agent suspeito;
- hooks de moderação preventiva registrados por `event_type` e executados em ordem de registro;
- `abuse_route_middleware(...)` com resposta `429` e header `retry-after`.

Contratos operacionais:

- o módulo não substitui o rate limiter global por IP; ele acrescenta uma segunda camada por rota/classe;
- classes são definidas explicitamente na rota via APIs específicas do router/app;
- `Application` só injeta o anti-abuso de rota quando existem services para store e rules e o middleware foi registrado;
- `actor_id` para quota é decidido pelo chamador; usuário autenticado e IP anônimo podem coexistir como estratégias de chave;
- hooks de moderação param na primeira rejeição e devolvem o motivo ao chamador;
- `spam_check(...)` é puramente em memória e em-request.

## Cobertura de testes

Cobertura da FASE 5:

- `5A`: 8 testes
- `5B`: 10 testes
- `5C`: 8 testes

Total da FASE 5: 26 testes de integração.

## Limites operacionais

- o rate limiting continua em memória e por processo;
- o rate limiting por rota e as quotas de upload também continuam em memória e por processo;
- a validação de path não resolve symlink real em disco nesta fase, apenas path lógico normalizado;
- a exclusão por bearer é baseada na presença do header Authorization, não em convenção de rota;
- o middleware CSRF existe como módulo próprio, mas o dispatch automático do `Application` já aplica o gate CSRF sem exigir registro manual do chamador;
- os sinais de spam são heurísticos locais e não substituem moderação humana nem reputação externa.
