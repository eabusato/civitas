# Manual Aprofundado do Sistema — FASE 8

## Visao geral

A FASE 8 fecha a camada de estado entre requests no Civitas e firma o tipo semantico canonico para referencias de arquivo em modelos.

O bloco `8A-8D` entrega:

- sessao server-side com cookie assinado por HMAC e dados mantidos no servidor;
- backends de memoria, arquivo, SQLite e Redis para persistencia de sessao;
- expiracao absoluta e por inatividade, rotação de ID e remember-me;
- flash messages de um request com promocao `pending -> current`;
- render HTML de flashes e integracao com templates via `{% SIGNA %}`;
- contexto autenticado por request usando `LocalContext`;
- invalidacao centralizada de todas as sessoes de um usuario via Redis.
- `UploadDescriptor` como valor canonico de campo `FkBlob` para arquivos persistidos em modelo.

## Sessao server-side

O contrato vive em `lib/civitas/session/session.cct`.

Capacidades estabilizadas:

- `SessionBackendKind` com `SbkMemoria`, `SbkArquivo`, `SbkDb` e `SbkRedis`;
- `SessionStore`, `SessionConfig`, `Session`, `SessionError`, `SessionRedisConfig` e `SessionRedisState`;
- `session_store_mem_init(...)`, `session_store_file_init(...)`, `session_store_db_init(...)` e `session_store_redis(...)`;
- `session_id_new(...)`, `session_cookie_sign(...)` e `session_cookie_verify(...)`;
- `session_load(...)`, `session_finalize(...)`, `session_is_expired(...)` e `session_rotate_id(...)`;
- `session_set(...)`, `session_get(...)`, `session_get_or(...)`, `session_delete(...)` e `session_clear(...)`;
- accessors `session_get_verbum(...)`, `session_get_int(...)` e `session_get_bool(...)`;
- `session_invalidate_all_for_user(...)` para backend Redis.

Contratos operacionais:

- o cookie carrega apenas `{session_id}.{hmac}` e os dados reais ficam no backend;
- cookie adulterado ou sessao expirada retornam sessao nova, nunca erro fatal para o handler;
- `session_finalize(...)` persiste a sessao e emite `Set-Cookie` com nome, path, SameSite, HttpOnly e Secure conforme `SessionConfig`;
- `session_rotate_id(...)` salva no novo ID e remove o ID anterior do backend;
- lookup textual de chaves de sessao e atualizado por comparacao sem depender da identidade interna do `map`;
- `session_clear(...)` preserva as chaves reservadas de flash em vez de destruir o contrato de PRG.

## Backends de armazenamento

### Memoria

Capacidade:

- armazenamento em `map` no heap, adequado para teste e desenvolvimento local.

Limites:

- nao sobrevive a restart;
- nao e apropriado para multiplos processos ou balanceamento horizontal.

### Arquivo

Capacidade:

- um arquivo JSON por sessao;
- roundtrip simples e inspecionavel em disco.

Limites:

- exige filesystem compartilhado para multiplas instancias;
- cleanup de expiradas depende do fluxo de `session_backend_cleanup(...)`.

### SQLite

Capacidade:

- persistencia unica com schema canonico;
- roundtrip consistente entre requests.

Limites:

- continua sendo backend de servidor unico na pratica operacional do projeto.

### Redis

O contrato complementar vive em `lib/civitas/session/session_redis.cct` e no ramo Redis de `session.cct`.

Capacidades estabilizadas:

- chave de sessao `prefixo_sessao + session_id`;
- SET por usuario em `prefixo_user_sessions + user_id`;
- TTL automatico no valor da sessao e TTL estendido no indice de usuario;
- `session_redis_handle(...)` e `session_redis_store_config(...)`;
- invalidacao de todas as sessoes do usuario em custo proporcional ao numero de sessoes dele, nao ao keyspace inteiro.

Contratos operacionais:

- `session_finalize(...)` registra a sessao no SET do usuario quando `user_id` esta presente;
- `session_backend_redis_delete(...)` remove a chave individual e tambem retira o `session_id` do SET do usuario;
- `session_invalidate_all_for_user(...)` tolera SET inexistente e retorna sucesso operacional.

## Remember-me

O contrato vive em `lib/civitas/session/session_remember.cct`.

Capacidades estabilizadas:

- `remember_me_generate(...)`;
- `remember_me_verify(...)`.

Contratos operacionais:

- o token e assinado e expira por timestamp;
- token expirado ou adulterado retorna `None`.

## Flash messages

O contrato vive em `lib/civitas/flash/flash.cct` e `lib/civitas/flash/flash_render.cct`.

Capacidades estabilizadas:

- `FlashLevel` com `FlSuccess`, `FlInfo`, `FlWarning` e `FlError`;
- `FlashMessage` com `level` e `texto`;
- `flash_set(...)`, `flash_get_all(...)`, `flash_has(...)`, `flash_get_by_level(...)` e `flash_clear(...)`;
- `flash_to_json(...)` e `flash_from_json(...)`;
- `flash_level_to_class(...)`, `flash_render(...)` e `flash_render_from_session(...)`.

Contratos operacionais:

- `_civitas_flash_pending` recebe as mensagens criadas no request corrente;
- `session_finalize(...)` promove `pending -> current` e limpa `pending`;
- as mensagens de `current` ficam disponiveis no request seguinte e desaparecem no request posterior se nao houver novas pendentes;
- `flash_clear(...)` limpa tanto `current` quanto `pending`, evitando vazamento de mensagem em redirect encadeado;
- o renderer usa `civitas/html`, preservando escaping de texto e classes canonicas.

## Integracao com templates

O compilador de templates passa a entender `{% SIGNA %}`.

Capacidades estabilizadas:

- token `Signa` no lexer;
- node `TnFlash` no AST;
- parser para tag vazia de flash;
- checker que exige `ctx.session: Session`;
- codegen que importa `flash_render.cct` apenas quando a tag aparece.

Contrato operacional:

- `{% SIGNA %}` gera `flash_render_from_session(SPECULUM ctx.session)`;
- templates sem `session` no contexto falham no checker com diagnostico de contrato.

## Contexto autenticado

O contrato vive em `lib/civitas/auth_context/auth_context.cct`.

Capacidades estabilizadas:

- chaves canonicas `auth:user_id`, `auth:session_id`, `auth:locale` e `auth:is_authenticated`;
- `auth_context_populate(...)`;
- `auth_context_user_id(...)`, `auth_context_session_id(...)`, `auth_context_locale(...)` e `auth_context_is_authenticated(...)`;
- `auth_context_require(...)`.

Contratos operacionais:

- `auth_context_populate(...)` grava snapshot do request no `LocalContext`;
- sessao sem `user_id` produz `is_authenticated = FALSUM` e `auth_context_require(...)` retorna erro;
- middlewares e handlers downstream podem depender apenas do `LocalContext`, sem carregar `Session` novamente.

## `civitas/upload_descriptor`

O contrato vive em `lib/civitas/upload_descriptor/upload_descriptor.cct` e `upload_descriptor_helpers.cct`.

Capacidades estabilizadas:

- `UploadState` com `UsTemp`, `UsFinal` e `UsOrphan`;
- `UploadDescriptor` com `path`, `hash`, `size`, `mime`, `original_name` e `state`;
- `upload_descriptor_new(...)`, `upload_descriptor_promote(...)`, `upload_descriptor_orphan(...)` e `upload_descriptor_is_final(...)`;
- `upload_descriptor_state_str(...)` e `upload_descriptor_state_from_str(...)`;
- `upload_descriptor_to_json(...)` e `upload_descriptor_from_json(...)`;
- `upload_descriptor_has_hash(...)` e `upload_descriptor_same_content(...)`.

Contratos operacionais:

- `path` e sempre relativo a media root; nao e URL absoluta nem path absoluto de filesystem;
- `upload_descriptor_new(...)` nasce em `UsTemp`;
- `promote(...)` marca o descriptor como `UsFinal` apos promocao fisica e antes do commit no banco;
- `orphan(...)` marca falha ou delecao logica para coleta posterior;
- `from_json(...)` e defensivo: JSON invalido ou `state` desconhecido produzem descriptor com `UsOrphan`;
- campos desconhecidos no JSON sao ignorados para manter compatibilidade aditiva futura;
- `UploadDescriptor` e o contrato semantico de `FkBlob`; a forma fisica continua sendo JSON em `TEXT` nesta fase, sem fechar a decisao final de persistencia.

## Cobertura de testes

Cobertura da FASE 8:

- `8A`: 7 testes
- `8B`: 6 testes
- `8C`: 7 testes
- `8D`: 10 testes

Total da FASE 8: 30 testes de integracao.
