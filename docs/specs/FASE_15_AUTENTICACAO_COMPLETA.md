# FASE 15 — Autenticacao Completa

## Escopo consolidado

O bloco `15A-15G` estabiliza a camada completa de identidade do Civitas em sete partes:

- usuarios com hash PBKDF2-SHA256, cadastro, login e decoradores;
- tokens de API stateless assinados com HMAC e refresh token com rotacao;
- permissoes por codigo, grupos e permissao por objeto;
- sessao server-side persistida com cookie canonico e dados por sessao;
- middleware unificado de autenticacao por bearer, sessao ou anonimo;
- rate limit para tentativas de login com janela deslizante;
- helpers de teste para montar usuarios, sessao, token e request autenticado.

## Contratos implementados

### `civitas/auth`

- `User`, `AuthError`, `AuthConfig`;
- `auth_hash_senha(...)` e `auth_verificar_senha(...)` com formato portavel de PBKDF2;
- CRUD basico de usuario e marcacao de inatividade;
- `auth_login(...)` com atualizacao de `ultimo_login`;
- leitura do estado autenticado em `LocalContext` via `auth_ctx_*`.

Limites operacionais:

- autenticacao por email/senha apenas;
- sem MFA, sem provedores externos e sem federacao nesta fase.

### `civitas/auth_token`

- `TokenConfig`, `TokenPayload`, `TokenError`, `RefreshToken`;
- emissao/verificacao de token HMAC;
- parse de bearer header;
- refresh token persistido com familia de rotacao e revogacao;
- blacklist de access token por `jti`.

Limites operacionais:

- o token e canonicamente um payload JSON assinado, nao um wrapper JWT de terceiros;
- os escopos seguem como string separada por espaco.

### `civitas/permissions`

- registry explicito de permissoes e grupos;
- atribuicao direta e por grupo;
- verificacao por codigo e verificacao por objeto;
- listagem deduplicada de permissoes efetivas do usuario.

Limites operacionais:

- nenhuma integracao automatica com metadata de modelos;
- o escopo por objeto e baseado em chave textual `(modelo, objeto_id)`.

### `civitas/session`

- `SessionConfig`, `Session` e operacoes de CRUD em sessao;
- dados de sessao em JSON simples;
- cookie assinado e middleware de resolucao;
- destruicao por usuario e purge de expiradas.

Limites operacionais:

- a parte canonica de auth de `15D` fecha sobre SQLite;
- `dados` permanece key-value textual, sem schema tipado de sessao.

### `civitas/auth_middleware`

- `AuthContext` persistido em `LocalContext`;
- resolucao de bearer e sessao;
- prioridade configuravel, com ordem padrao bearer → sessao → anonimo;
- guards de login, escopo e permissao.

Limites operacionais:

- o middleware nao executa refresh transparente;
- a fonte de verdade da identidade continua sendo token valido ou sessao valida.

### `civitas/auth_rate_limit`

- janela deslizante por chave textual;
- helpers de chave por email, IP ou combinacao;
- resposta HTTP `429` canonica;
- wrapper `auth_login_com_rate_limit(...)`.

Limites operacionais:

- sem reputacao distribuida e sem armazenamento obrigatorio fora de SQLite;
- orientado a login/credenciais, nao a um sistema amplo de abuse scoring.

### `civitas/auth_test`

- schema completo de auth para `TestDb`;
- fabricas de usuario/admin/permissoes;
- emissao de token/refresh para testes;
- criacao de sessao e construcao de request autenticado;
- assercoes de contexto autenticado/anonimo.

Limites operacionais:

- os helpers adotam formas primitivas quando necessario para contornar limites do subset executavel;
- a config de hash de teste usa `iteracoes = 100000` como piso operacional atual.

## Cobertura

O bloco fecha com 37 testes de integracao:

- 7 em `15A`
- 5 em `15B`
- 5 em `15C`
- 5 em `15D`
- 5 em `15E`
- 5 em `15F`
- 5 em `15G`

## Estado esperado do gate

O bloco `15A-15G` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `15A-15G`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
