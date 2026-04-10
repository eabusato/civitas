# FASE 16 Release Notes

## Entregas

- `lib/civitas/auth_flows/` com reset de senha, verificacao de email, alteracao de email e historico de senhas;
- evolucao de `lib/civitas/auth/` para persistir `email_verificado` e `email_verificacao_pendente`;
- `lib/civitas/mailer/` com configuracao, envio e backends memory/file/SMTP;
- `lib/civitas/mail_templates/` com templates dual-body para reset, verificacao, alteracao de email e boas-vindas;
- `lib/civitas/mail_test/` com mailbox memory, assertivas declarativas, extracao de token e helpers de fluxo;
- expansao do runner unico para cobrir `16A-16D`.

## Decisoes relevantes

- o contrato real de `16A` foi preservado em torno de `FlowTokenResult`, e `mail_test` foi construido sobre essa API em vez de criar uma segunda variante artificial so para testes;
- os templates de email foram estabilizados com texto e assunto em ingles, mantendo a estrutura funcional do normativo e simplificando consistencia de mensagens;
- o backend memory do mailer virou a via canonica de teste para fluxos de email, evitando dependencia de SMTP externo na suite;
- `auth_schema_up(...)` passou a tolerar bancos existentes, adicionando as colunas de verificacao de email via `ALTER TABLE` seguro.

## Cobertura de testes

A FASE 16 adiciona:

- 6 testes em `16A`
- 6 testes em `16B`
- 5 testes em `16C`
- 6 testes em `16D`

Total da FASE 16: 23 testes de integracao.

## Estado do gate

O bloco `16A-16D`, fechando a FASE 16, so e considerado concluido com:

- `16A` verde isoladamente;
- `16B` verde isoladamente;
- `16C` verde isoladamente;
- `16D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
