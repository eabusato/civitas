# Manual Aprofundado do Sistema — FASE 15

## Visao geral

A FASE 15 consolida a camada completa de autenticacao do Civitas. O bloco `15A-15G` entrega usuarios com hash PBKDF2, tokens HMAC stateless com refresh rotativo, permissoes por codigo e por objeto, sessao server-side integrada ao request, middleware unificado de identidade, rate limit para tentativas de login e helpers de teste para suites de integracao.

O bloco entrega:

- `civitas/auth` para identidade basica, hashing de senha, cadastro, login e decoradores;
- `civitas/auth_token` para access token HMAC, blacklist e refresh token com deteccao de reuse;
- `civitas/permissions` para permissoes explicitas, grupos e escopo por objeto;
- `civitas/session` para sessao persistida, cookie canonico e dados por sessao;
- `civitas/auth_middleware` para resolver bearer, sessao ou anonimo em `LocalContext`;
- `civitas/auth_rate_limit` para bloqueio de forca bruta com janela deslizante;
- `civitas/auth_test` para setup de schema e fabricas de identidade em testes.

## `civitas/auth`

O contrato vive em `lib/civitas/auth/`.

Capacidades estabilizadas:

- `User`, `AuthError` e `AuthConfig`;
- `auth_config_default(...)`, `auth_hash_senha(...)` e `auth_verificar_senha(...)`;
- `auth_criar_usuario(...)`, `auth_buscar_por_email(...)`, `auth_buscar_por_id(...)`, `auth_atualizar_senha(...)`, `auth_usuario_ativo(...)`, `auth_marcar_inativo(...)` e `auth_deletar_usuario(...)`;
- `auth_login(...)`, `auth_logout(...)` e `auth_usuario_atual(...)`;
- chaves e helpers de contexto `auth_ctx_*` para ler `user_id`, `via`, `escopos` e flag autenticada;
- `auth_schema_up(...)` e `auth_schema_down(...)` para a tabela `usuarios`.

Limites operacionais:

- o hash segue o formato portavel `pbkdf2:sha256:<iteracoes>:<salt_hex>:<hash_hex>`;
- o subsistema trata autenticacao por email/senha, sem login social ou MFA nesta fase;
- os decoradores de permissao operam sobre `LocalContext` ou, quando recebem `db`, fazem lookup explicito em `civitas/permissions`.

## `civitas/auth_token`

O contrato vive em `lib/civitas/auth_token/`.

Capacidades estabilizadas:

- `TokenConfig`, `TokenPayload`, `TokenError` e `RefreshToken`;
- `token_config_new(...)`, `token_issue(...)`, `token_parse_payload(...)`, `token_verify(...)`, `token_tem_escopo(...)` e `token_from_bearer_header(...)`;
- `refresh_token_issue(...)` e rotacao por familia em `auth_token_refresh.cct`;
- blacklist e revogacao via `token_revoke(...)`, `token_is_revoked(...)`, `token_blacklist_purge(...)` e `refresh_token_revogar_usuario(...)`;
- `auth_token_schema_up(...)` e `auth_token_schema_down(...)` para `token_blacklist` e `refresh_tokens`.

Limites operacionais:

- o formato e inspirado em JWT, mas implementado diretamente em CCT com JSON + base64url + HMAC;
- os escopos permanecem como `VERBUM` separado por espaco, sem tipo estruturado especifico;
- a persistencia cobre refresh token e blacklist; access token continua stateless.

## `civitas/permissions`

O contrato vive em `lib/civitas/permissions/`.

Capacidades estabilizadas:

- `Permission` e `Group`;
- registro/listagem/lookup de permissoes e grupos;
- atribuicao direta ao usuario e via grupo com `user_perm_conceder(...)`, `user_perm_revogar(...)`, `user_group_adicionar(...)` e `user_group_remover(...)`;
- verificacoes `usuario_tem_permissao(...)`, `usuario_tem_alguma_permissao(...)`, `usuario_listar_permissoes(...)` e variantes por objeto;
- cleanup por objeto via `obj_perm_revogar_objeto(...)`;
- `permissions_schema_up(...)` e `permissions_schema_down(...)`.

Limites operacionais:

- as permissoes sao registradas explicitamente por codigo; nao existe geracao automatica a partir de `ModelDef` nesta fase;
- a permissao por objeto cobre lookup por `(modelo, objeto_id)`, sem mecanismo adicional de heranca entre objetos.

## `civitas/session`

O contrato vive em `lib/civitas/session/`.

Capacidades estabilizadas:

- `SessionStore`, `SessionConfig`, `Session`, `SessionBackendKind` e `SessionError`;
- backends memoria, arquivo, SQLite e Redis ja existentes, preservados e integrados ao contrato de auth;
- `session_create(...)`, `session_lookup(...)`, `session_touch(...)`, `session_destroy(...)`, `session_destroy_user(...)` e `session_purge_expiradas(...)`;
- dados de sessao via `session_dados_get(...)`, `session_dados_set(...)` e `session_dados_del(...)`;
- cookie de sessao via `session_cookie_sign(...)`, `session_cookie_verify(...)` e `session_cookie_header(...)`;
- middleware `session_middleware_apply(...)` e accessors de contexto `session_ctx_id(...)` / `session_ctx_user_id(...)`;
- suporte adicional a remember-me em `session_remember.cct`.

Limites operacionais:

- a camada server-side de `15D` usa explicitamente schema SQLite para a parte canonica de auth, mesmo com `SessionStore` suportando outros backends historicos;
- o payload de `dados` permanece string JSON simples com helpers de chave/valor, sem schema declarativo de sessao.

## `civitas/auth_middleware`

O contrato vive em `lib/civitas/auth_middleware/`.

Capacidades estabilizadas:

- `AuthContext` e `AuthMiddlewareConfig`;
- `auth_context_escrever(...)`, `auth_context_ler(...)` e `auth_context_empty(...)`;
- resolucao de bearer em `auth_resolve_bearer(...)`;
- resolucao de sessao em `auth_resolve_session(...)`;
- pipeline `auth_middleware_apply(...)` com prioridade configuravel entre bearer e sessao;
- guards `auth_guard_login(...)`, `auth_guard_escopo(...)`, `auth_guard_permissao(...)` e respostas padrao de `401/403`.

Limites operacionais:

- a ordem canonica continua bearer, depois sessao, depois anonimo;
- a integracao do middleware popula `LocalContext`, nao um objeto request mutavel adicional.

## `civitas/auth_rate_limit`

O contrato vive em `lib/civitas/auth_rate_limit/`.

Capacidades estabilizadas:

- `RateLimitConfig` e `RateLimitResult`;
- helpers de chave `rate_limit_chave_email(...)`, `rate_limit_chave_ip(...)` e `rate_limit_chave_ip_email(...)`;
- `rate_limit_check(...)`, `rate_limit_check_ok(...)`, `rate_limit_record(...)`, `rate_limit_clear(...)`, `rate_limit_purge_antigas(...)`, `rate_limit_contagem_por_chave(...)` e `rate_limit_chaves_bloqueadas(...)`;
- wrapper `auth_login_com_rate_limit(...)` para aplicar login com bloqueio e limpeza em caso de sucesso;
- `rate_limit_resposta_429(...)` para resposta HTTP canonica de lockout.

Limites operacionais:

- a janela deslizante e persistida em SQLite, sem dependencia obrigatoria de Redis;
- a granularidade desta fase cobre chave textual composta, nao um sistema mais amplo de reputacao ou device fingerprint.

## `civitas/auth_test`

O contrato vive em `lib/civitas/auth_test/` e no facade `lib/civitas/auth_test.cct`.

Capacidades estabilizadas:

- setup/teardown completo de schema de auth em `TestDb`;
- `auth_test_config(...)` com parametros deterministas e `min_senha` reduzido para teste;
- assercoes `auth_test_assert_autenticado(...)`, `auth_test_assert_anonimo(...)`, `auth_test_assert_user_id(...)` e `auth_test_assert_via(...)`;
- `AuthTestUser` e fabricas de usuario/admin/permissoes, inclusive variantes `*_id` e `*_into`;
- helpers de token, refresh e payload;
- helpers de sessao e login que retornam `Session` ou `session_id`;
- `AuthTestRequest` e builders para bearer, sessao e request autenticado.

Limites operacionais:

- a config de hash em teste continua mais leve que a producao, mas respeita o piso atual do runtime PBKDF2 com `iteracoes = 100000`;
- os helpers privilegiam caminhos primitivos (`VERBUM`, `REX`, headers) para manter estabilidade no subset executavel atual do CCT.

## Cobertura de testes

Cobertura da FASE 15:

- `15A`: 7 testes
- `15B`: 5 testes
- `15C`: 5 testes
- `15D`: 5 testes
- `15E`: 5 testes
- `15F`: 5 testes
- `15G`: 5 testes

Total da FASE 15: 37 testes de integracao.
