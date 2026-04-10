# FASE 15 Release Notes

## Entregas

- `lib/civitas/auth/` com usuarios, hashing PBKDF2, login e decoradores de autenticacao/permissao;
- `lib/civitas/auth_token/` com access token HMAC, blacklist, refresh token e rotacao de familia;
- `lib/civitas/permissions/` com permissoes explicitas, grupos e controle por objeto;
- expansao de `lib/civitas/session/` para sessao server-side integrada ao fluxo de auth, incluindo store SQLite, cookie e middleware;
- `lib/civitas/auth_middleware/` com resolucao unificada bearer/sessao/anonimo e guards padrao;
- `lib/civitas/auth_rate_limit/` com janela deslizante persistida e resposta HTTP `429`;
- `lib/civitas/auth_test/` com setup de schema, fabricas de identidade e builders de request para testes;
- expansao do runner unico para cobrir `15A-15G`.

## Decisoes relevantes

- o hash de senha de producao permanece em PBKDF2-SHA256 com formato portavel e iteracoes altas via `auth_config_default(...)`;
- a auth web e a auth API compartilham `LocalContext` por meio de `AuthContext`, evitando duplicacao de contrato entre middleware e handlers;
- a verificacao de permissao nos decoradores consulta o banco quando `db != NIHIL`, preservando fallback para contexto local quando o chamador quer operar sem persistencia;
- os helpers de `auth_test` passaram a privilegiar saidas primitivas e variantes `*_into`/`*_id` para manter estabilidade no subset executavel atual do CCT;
- a config de teste de auth foi alinhada ao piso atual do runtime PBKDF2 com `iteracoes = 100000`.

## Cobertura de testes

A FASE 15 adiciona:

- 7 testes em `15A`
- 5 testes em `15B`
- 5 testes em `15C`
- 5 testes em `15D`
- 5 testes em `15E`
- 5 testes em `15F`
- 5 testes em `15G`

Total da FASE 15: 37 testes de integracao.

## Estado do gate

O bloco `15A-15G`, fechando a FASE 15, so e considerado concluido com:

- `15A` verde isoladamente;
- `15B` verde isoladamente;
- `15C` verde isoladamente;
- `15D` verde isoladamente;
- `15E` verde isoladamente;
- `15F` verde isoladamente;
- `15G` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
