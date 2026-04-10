# Manual Aprofundado do Sistema — FASE 16

## Visao geral

A FASE 16 consolida os fluxos canonicamente esperados de email transacional no Civitas. O bloco `16A-16D` entrega recuperacao de conta por token TTL, verificacao de email, alteracao de email com confirmacao, um mailer unificado sobre `cct/mail`, templates dual-body e helpers de teste para capturar e validar emails sem infraestrutura externa.

O bloco entrega:

- `civitas/auth_flows` para tokens assinados, TTL, historico de senhas e confirmacoes por email;
- `civitas/mailer` para abrir e enviar via backend memory, file ou SMTP;
- `civitas/mail_templates` para construir emails transacionais em texto puro + HTML;
- `civitas/mail_test` para abrir mailbox em memoria, fazer assertivas declarativas e extrair tokens das URLs.

## `civitas/auth_flows`

O contrato vive em `lib/civitas/auth_flows/`.

Capacidades estabilizadas:

- `FlowConfig`, `FlowError`, `FlowToken` e `FlowTokenResult`;
- `flow_config_default(...)` com TTL de reset, verificacao e alteracao de email;
- `auth_flow_reset_solicitar(...)`, `auth_flow_reset_validar(...)` e `auth_flow_reset_confirmar(...)`;
- `auth_flow_verificar_email_solicitar(...)` e `auth_flow_verificar_email_confirmar(...)`;
- `auth_flow_alterar_email_solicitar(...)` e `auth_flow_alterar_email_confirmar(...)`;
- `auth_history_registrar(...)` e `auth_history_verificar_reuso(...)`;
- `auth_flows_schema_up(...)` e `auth_flows_schema_down(...)` para `auth_flow_tokens` e `senha_historico`.

Limites operacionais:

- o token em claro e composto por token aleatorio + HMAC, e o banco persiste apenas `token_hash`;
- o payload de alteracao de email segue JSON simples com `novo_email`;
- o modulo nao envia email sozinho: ele gera/persiste tokens e deixa a entrega para `civitas/mailer` + `civitas/mail_templates`.

## `civitas/mailer`

O contrato vive em `lib/civitas/mailer/`.

Capacidades estabilizadas:

- `MailerConfig`, `Mailer`, `MailerError`;
- factories `mailer_config_memory(...)`, `mailer_config_file(...)` e `mailer_config_smtp(...)`;
- `mailer_config_from_settings(...)` com leitura da secao `mail.*` de `Settings`;
- `mailer_open(...)`, `mailer_close(...)`, `mailer_send(...)` e `mailer_send_now(...)`;
- `mailer_simple(...)` e `mailer_new_message(...)`;
- inspecao do backend memory com `mailer_memory_count(...)`, `mailer_memory_get(...)` e `mailer_memory_clear(...)`.

Limites operacionais:

- o backend SMTP delega integralmente para `cct/mail`;
- o spool so e aberto quando `spool_opts.root_dir` estiver configurado;
- `mailer_schema_up(...)` e no-op porque a persistencia principal do bloco vive em `auth_flows`.

## `civitas/mail_templates`

O contrato vive em `lib/civitas/mail_templates/`.

Capacidades estabilizadas:

- base HTML com `mail_html_head(...)`, `mail_html_foot(...)`, `mail_html_botao(...)`, `mail_html_aviso(...)` e `mail_html_fallback_link(...)`;
- `mail_tpl_reset_senha(...)`;
- `mail_tpl_verificar_email(...)`;
- `mail_tpl_alterar_email(...)`;
- `mail_tpl_boas_vindas(...)`.

Limites operacionais:

- o HTML e propositalmente simples, inline e autocontido;
- os templates retornam `MailMessage` pronto para envio, sem dependencia do compilador de templates da FASE 6;
- o conteudo textual atual do bloco foi estabilizado em ingles, embora o normativo original esteja descrito em portugues.

## `civitas/mail_test`

O contrato vive em `lib/civitas/mail_test/`.

Capacidades estabilizadas:

- `mailer_test_config(...)`, `mailer_test_open(...)`, `mailer_test_close(...)` e `mailer_test_clear(...)`;
- `mailer_test_count(...)`, `mailer_test_get(...)` e `mailer_test_ultimo(...)`;
- `mail_test_find_by_to(...)`;
- assertivas `mail_test_assert_count(...)`, `mail_test_assert_enviado_para(...)`, `mail_test_assert_subject(...)`, `mail_test_assert_body_contem(...)` e `mail_test_assert_nenhum_enviado(...)`;
- extracao `mail_test_extrair_token_de_url(...)`, `mail_test_extrair_token_reset(...)` e `mail_test_extrair_token_verificacao(...)`;
- helpers de fluxo `mail_test_reset_solicitar_e_extrair(...)` e `mail_test_verificar_email_e_extrair(...)`;
- `mail_test_schema_up(...)` e `mail_test_schema_down(...)`.

Limites operacionais:

- os helpers assumem backend memory para leitura canônica das mensagens;
- a extracao de token depende da convencao de query string usada pelos templates (`t` para reset e `token` para verificacao);
- os helpers de fluxo reutilizam a API real de `16A`, isto e, trabalham sobre `FlowTokenResult` e nao sobre um tipo paralelo so para testes.

## Cobertura de testes

Cobertura da FASE 16:

- `16A`: 6 testes
- `16B`: 6 testes
- `16C`: 5 testes
- `16D`: 6 testes

Total da FASE 16: 23 testes de integracao.
