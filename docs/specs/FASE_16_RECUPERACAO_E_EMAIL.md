# FASE 16 — Recuperacao de Conta e Email Transacional

## Escopo consolidado

O bloco `16A-16D` estabiliza a camada de email transacional e recuperacao de conta do Civitas em quatro partes:

- tokens TTL assinados para reset de senha, verificacao de email e alteracao de email;
- historico de senhas para evitar reuso recente;
- mailer unificado sobre `cct/mail` com backends memory, file e SMTP;
- templates dual-body e helpers de teste para captura e extracao de token.

## Contratos implementados

### `civitas/auth_flows`

- `FlowConfig`, `FlowError`, `FlowToken`, `FlowTokenResult`;
- emissao e persistencia de tokens com `token_hash` em SQLite;
- reset de senha com validacao, expiracao, marcacao de uso e invalidacao de outros tokens do mesmo tipo;
- verificacao de email com flag `email_verificado` e limpeza de `email_verificacao_pendente`;
- alteracao de email com payload JSON e confirmacao explicita;
- historico de senhas por usuario.

Limites operacionais:

- `payload` e string JSON simples;
- o modulo retorna resultados/erros tipados, mas nao faz transporte HTTP nem entrega de email sozinho.

### `civitas/mailer`

- `MailerConfig`, `Mailer`, `MailerError`;
- abertura via memory/file/SMTP;
- envio e validacao de `MailMessage`;
- leitura e limpeza da caixa memory para testes;
- configuracao derivada de `Settings`.

Limites operacionais:

- spool opcional, ativado apenas quando configurado;
- sem schema proprio persistido nesta fase.

### `civitas/mail_templates`

- helpers HTML estruturais;
- emails de reset de senha, verificacao, alteracao de email e boas-vindas;
- montagem de `MailMessage` com `from`, `to`, `subject`, `text_body` e `html_body`.

Limites operacionais:

- sem assets externos, sem CSS externo e sem pipeline separado de email rendering.

### `civitas/mail_test`

- mailbox memory pronta para teste;
- assertivas declarativas de contagem, destinatario, assunto e trecho de corpo;
- extracao de token por query string;
- helpers de fluxo completo para reset e verificacao;
- schema helper sobre `TestDb`.

Limites operacionais:

- orientado a backend memory;
- convencoes de parametro de URL ficam acopladas aos templates oficiais do bloco.

## Cobertura

O bloco fecha com 23 testes de integracao:

- 6 em `16A`
- 6 em `16B`
- 5 em `16C`
- 6 em `16D`

## Estado esperado do gate

O bloco `16A-16D` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `16A-16D`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
