# Spec Consolidada — FASE 8

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `8A-8D`.

## `civitas/session`

`lib/civitas/session/session.cct` estabiliza a sessao server-side do Civitas.

Contrato implementado:

- `SessionStore`, `SessionConfig`, `Session`, `SessionError`, `SessionRedisConfig` e `SessionRedisState`;
- backends `SbkMemoria`, `SbkArquivo`, `SbkDb` e `SbkRedis`;
- `session_load(...)` e `session_finalize(...)` como ciclo canonico do request;
- cookie de sessao com HMAC-SHA256;
- expiracao por idade absoluta e por inatividade;
- rotação de ID com remocao do ID anterior no backend;
- getters tipados para `VERBUM`, `REX` e `VERUM`;
- remember-me por token assinado.

Contratos de estado:

- cookie adulterado ou sessao ausente retornam sessao nova;
- serializacao continua flat em JSON com `dados: MAPPA(VERBUM, VERBUM)`;
- atualizacao e remocao de chaves da sessao usam comparacao textual estavel, nao identidade de ponteiro do `map`;
- `session_clear(...)` preserva `_civitas_flash` e `_civitas_flash_pending`.

## Backend Redis de sessao

`lib/civitas/session/session.cct` e `session_redis.cct` estabilizam o backend Redis.

Contrato implementado:

- chave de sessao `prefixo_sessao + session_id`;
- SET de sessoes por usuario em `prefixo_user_sessions + user_id`;
- TTL da sessao baseado em `SessionConfig`;
- TTL do SET de usuario baseado em `ttl_user_sessions_extra`;
- `session_redis_handle(...)` e `session_redis_store_config(...)`;
- `session_invalidate_all_for_user(...)` com remocao das chaves individuais.

Contratos de transporte/armazenamento:

- `session_backend_redis_load(...)` trata chave ausente como `None`;
- `session_backend_redis_save(...)` salva JSON da sessao com `SETEX`;
- quando `user_id` existe, o `session_id` entra no SET do usuario com `SADD`;
- `session_rotate_id(...)` combinado com Redis atualiza o indice do usuario para o novo ID.

## `civitas/flash`

`lib/civitas/flash/flash.cct` e `flash_render.cct` estabilizam flash messages baseadas em sessao.

Contrato implementado:

- `FlashLevel` e `FlashMessage`;
- `flash_set(...)`, `flash_get_all(...)`, `flash_has(...)`, `flash_get_by_level(...)` e `flash_clear(...)`;
- serializacao em JSON array;
- render HTML com classes `flash-success`, `flash-info`, `flash-warning` e `flash-error`.

Contratos operacionais:

- `flash_set(...)` sempre grava em `_civitas_flash_pending`;
- `session_finalize(...)` promove `pending -> current` e zera `pending`;
- `flash_get_all(...)` le o estado atual do request;
- `flash_clear(...)` limpa `current` e `pending`;
- `flash_render(...)` escapa o texto e retorna string vazia quando nao ha mensagens.

## Templates com `{% SIGNA %}`

`lib/civitas/template/` estabiliza a integracao de flash com o compilador.

Contrato implementado:

- token `Signa`;
- node `TnFlash`;
- checagem de contexto exigindo `session: Session`;
- codegen sob demanda com import de `flash_render.cct`.

Contrato operacional:

- `{% SIGNA %}` renderiza todas as flashes atuais da sessao do contexto;
- se o contexto nao expuser `session`, o template falha em tempo de compilacao.

## `civitas/auth_context`

`lib/civitas/auth_context/auth_context.cct` estabiliza o snapshot autenticado no `LocalContext`.

Contrato implementado:

- `auth_context_populate(...)`;
- helpers `auth_context_user_id(...)`, `auth_context_session_id(...)`, `auth_context_locale(...)`, `auth_context_is_authenticated(...)` e `auth_context_require(...)`;
- chaves canonicas `auth:*`.

Contrato operacional:

- `user_id == ""` significa request anonimo;
- `auth_context_require(...)` retorna erro quando o request nao esta autenticado;
- o modulo nao depende de backend especifico de sessao, apenas do `Session` carregado.

## `civitas/upload_descriptor`

`lib/civitas/upload_descriptor/upload_descriptor.cct` e `upload_descriptor_helpers.cct` estabilizam o descritor canonico de arquivo para campos `FkBlob`.

Contrato implementado:

- `UploadState` com `UsTemp`, `UsFinal` e `UsOrphan`;
- `UploadDescriptor` com `path`, `hash`, `size`, `mime`, `original_name` e `state`;
- criacao inicial em `UsTemp`;
- transicoes explicitas `promote(...)` e `orphan(...)`;
- serializacao JSON com seis campos canonicos;
- desserializacao tolerante a campos extras;
- fallback defensivo para `UsOrphan` em JSON invalido ou `state` desconhecido;
- comparacao de conteudo por hash com `upload_descriptor_same_content(...)`.

Contrato operacional:

- `path` armazenado no descriptor e sempre relativo a media root;
- `UploadDescriptor` e o unico tipo semantico previsto para persistencia de referencia de arquivo em `FkBlob`;
- `FkText` com path cru continua proibido por contrato de arquitetura;
- a forma fisica atual de persistencia e JSON, mas a decisao final de `TEXT`/`JSONB`/colunas separadas permanece aberta.

## Cobertura de testes

A FASE 8 adiciona 30 testes de integracao:

- 7 em `8A`
- 6 em `8B`
- 7 em `8C`
- 10 em `8D`
