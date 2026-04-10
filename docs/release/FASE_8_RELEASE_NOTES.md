# FASE 8 Release Notes

## Entregas

- `lib/civitas/session/session.cct` com sessao server-side, assinatura HMAC, expiracao, getters tipados, rotação de ID e remember-me;
- `lib/civitas/session/session_mem.cct`, `session_file.cct`, `session_db.cct` e `session_redis.cct` com os quatro backends suportados;
- `lib/civitas/flash/flash.cct` e `flash_render.cct` com mensagens descartaveis entre requests e render HTML seguro;
- `lib/civitas/auth_context/auth_context.cct` com snapshot autenticado em `LocalContext`;
- `lib/civitas/upload_descriptor/upload_descriptor.cct` e `upload_descriptor_helpers.cct` com o descriptor canonico de arquivo para `FkBlob`, transicoes de estado e roundtrip JSON tolerante;
- integracao do compilador de templates com `{% SIGNA %}`;
- expansao do runner unico para cobrir `8A-8D`.

## Decisoes relevantes

- o cookie de sessao continua opaco e carrega apenas `session_id + hmac`;
- os dados reais da sessao ficam sempre do lado do servidor;
- o backend Redis usa SET por usuario para invalidacao centralizada de sessoes;
- flash messages continuam modeladas como um caso especializado de sessao, sem storage paralelo;
- `LocalContext` passa a ser o meio oficial de propagar identidade autenticada no request;
- os testes Redis usam fake Redis dedicado em CCT, compilado a partir de `tests/integration/fase_8/8c/fixtures/fake_redis_server.cct`, cobrindo o contrato realmente exercido pelo backend sem depender de linguagem auxiliar externa.
- `UploadDescriptor` fixa o contrato semantico de arquivo em modelo agora, mas deixa a forma fisica de `FkBlob` aberta para evolucao futura de storage.

## Cobertura de testes

A FASE 8 adiciona:

- 7 testes em `8A`
- 6 testes em `8B`
- 7 testes em `8C`
- 10 testes em `8D`

Total da FASE 8: 30 testes de integracao.

## Estado do gate

O bloco `8A-8D`, fechando a FASE 8, so e considerado concluido com:

- `8A` verde isoladamente;
- `8B` verde isoladamente;
- `8C` verde isoladamente;
- `8D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
