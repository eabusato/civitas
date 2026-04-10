# Manual Aprofundado do Sistema — FASE 4

## Visão geral

A FASE 4 transforma o Civitas de framework funcional em framework operável.

O bloco `4A-4D` entrega:

- `settings` canônicos carregados de `civitas.toml`, arquivo de ambiente e env override;
- `Application` com lifecycle, módulos, health e integração formal com serviços;
- configuração tipada de storage, Redis, mail, search, proxy e ferramentas externas;
- `secrets` por domínio com rotação, grace window e compatibilidade legada explícita.

## Settings

O contrato está em `lib/civitas/core/settings.cct` e `settings_schema.cct`.

Capacidades estabilizadas:

- `settings_load(...)` e `settings_load_with_env(...)`;
- precedência `default -> file base -> file environment -> env -> test_override`;
- `CIVITAS_ENV` e arquivo `civitas.<env>.toml`;
- modo estrito via `CIVITAS_SETTINGS_STRICT=true`;
- getters tipados para `VERBUM`, `VERUM`, `REX` e `LIST<VERBUM>`;
- origem do valor e dump seguro no formato `key = value (source)`.

Contratos operacionais:

- `civitas.toml` é obrigatório quando o projeto de runtime existe;
- `cct.toml` não é aceito como arquivo de runtime da aplicação;
- chaves desconhecidas viram diagnóstico e falham em modo estrito;
- settings sensíveis continuam observáveis por origem, mas não têm valor bruto exposto no dump seguro;
- normalização de path respeita `project_root` sem duplicar caminhos já resolvidos.

## Application

O contrato está em `lib/civitas/core/app.cct`, `app_module.cct` e `lifecycle.cct`.

Capacidades estabilizadas:

- `app_new(...)`;
- registro e deduplicação de módulos;
- startup e shutdown ordenados;
- rollback parcial quando um módulo falha no startup;
- health report seguro e extensível;
- integração com router, middleware, signals e event bus.

Contratos de lifecycle:

- registro tardio após bootstrap fechado é rejeitado;
- startup falho dispara shutdown dos módulos já iniciados;
- handlers de health podem degradar componentes sem expor segredo ou config sensível.

## Serviços externos e storage

O contrato está em `storage_settings.cct`, `services.cct`, `external_tools.cct` e `app_services.cct`.

Capacidades estabilizadas:

- storage de mídia com `root_dir`, subdirs canônicos e integração com `Application`;
- object storage tipado com falha explícita quando falta credencial obrigatória;
- Redis com parse de DSN e preservação de timeouts configurados no Civitas;
- mail `smtp`, `file` e `memory`, com regras por ambiente;
- search e proxy tipados;
- verificação de `ffmpeg` e `ffprobe` quando marcados como obrigatórios.

Contratos operacionais:

- `media.root_dir` é obrigatório quando a camada de mídia local é usada;
- `mail.memory` é permitido apenas em `test`;
- `mail.file` não deve ser usado em `production`;
- `proxy` e `search` falham cedo em combinação inválida.

## Segredos e rotação

O contrato está em `keyring.cct` e `secrets.cct`.

Domínios estabilizados:

- `session`
- `csrf`
- `signed_cookie`
- `token`
- `temporary_link`

Capacidades estabilizadas:

- `secrets_load(...)`;
- `secrets_active(...)`;
- `secrets_active_key_id(...)`;
- `secrets_rotation_policy(...)`;
- `secrets_lookup(...)`;
- `secrets_verify_candidates(...)`;
- `secrets_safe_dump(...)`.

Contratos de rotação:

- novas assinaturas usam sempre a chave ativa;
- validação tenta ativa e depois legadas elegíveis em ordem declarada;
- `grace_seconds = 0` remove candidatas legadas do conjunto de validação;
- compatibilidade com chave global legada só existe com `secrets.legacy_global_key_enabled = true`;
- ausência de material secreto em env falha cedo no boot.

Contratos de segurança:

- material secreto nunca aparece no dump seguro;
- introspecção expõe apenas domínio, `active_key_id`, contagem de candidatas, `grace_seconds` e uso ou não de legado global.

## Cobertura de testes

Cobertura da FASE 4:

- `4A`: 8 testes
- `4B`: 6 testes
- `4C`: 8 testes
- `4D`: 8 testes

Total da FASE 4: 30 testes de integração.

## Limites operacionais

- a suite usa probes externos em `tests/tmp` para validar env injection e introspecção de settings/secrets sem sair do padrão do projeto;
- arrays vazios em TOML ficaram evitados nos testes de secrets, usando omissão do campo quando semanticamente equivalente a lista vazia;
- a fase ainda não introduz primitives criptográficas nem consumidores finais de sessão/auth; ela entrega o keyring e os contratos de resolução necessários para essas fases futuras.
