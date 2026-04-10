# Sistema Fase 24

## Escopo

A FASE 24 adiciona a camada de harnesses de integracao do Civitas. O bloco entrega quatro modulos complementares:

- `civitas/test_client` para requests HTTP sem socket, chamando `router_dispatch(...)` diretamente;
- `civitas/test_mail` para captura de emails em memoria sobre `MAIL_BACKEND_MEMORY`;
- `civitas/test_tasks` para fila de tasks em SQLite `:memory:` com flush sincrono no mesmo processo;
- `civitas/test_seo` para sitemap, robots, meta tags, proxy headers, upload e range requests.

O objetivo operacional da fase e transformar testes de integracao em execucoes previsiveis, rapidas e sem infraestrutura auxiliar de rede, SMTP ou worker externo.

## Arquitetura

O bloco nao cria um runtime paralelo. Ele reutiliza os contratos reais do framework e troca apenas a borda operacional:

1. `test_client` monta `HttpRequest` em memoria e converte para `WebRequest`;
2. o router e a pilha de middleware sao exercitados sem abrir socket;
3. `test_mail` injeta `MailClient` com backend memory no mesmo `mail_send(...)` usado em producao;
4. `test_tasks` usa `DbHandle` SQLite em memoria e o mesmo `task_worker_run_once(...)` do worker canonico;
5. `test_seo` compoe asserts de infraestrutura em cima do proprio `test_client`.

## Contratos implementados

### `civitas/test_client`

- `test_client_get/post/put/patch/delete`
- `test_client_post_json`
- `test_client_post_form`
- `test_client_upload`
- jar de cookies persistente entre requests
- headers padrao por cliente
- asserts para status, redirect, header, content-type, body e JSON

### `civitas/test_mail`

- `test_mail_outbox_new`
- `test_mail_client`
- `test_mail_count/get/last/clear`
- `assert_email_sent`
- `assert_email_to`
- `assert_email_subject`
- `assert_email_contains`
- `assert_email_html_contains`

### `civitas/test_tasks`

- `test_tasks_setup`
- `test_tasks_db`
- `test_tasks_config`
- `test_tasks_register`
- `test_tasks_enqueue`
- `test_tasks_flush`
- `test_tasks_flush_one`
- `test_tasks_count/count_name/clear`
- `assert_task_enqueued`
- `assert_task_ran`
- `assert_task_failed`
- `assert_task_count`

### `civitas/test_seo`

- `test_sitemap_fetch`
- `test_robots_fetch`
- `assert_sitemap_contains_url/not_contains_url/count/url_lastmod`
- `assert_robots_contains/not_contains`
- `assert_canonical`
- `assert_hreflang`
- `assert_og_title`
- `assert_proxy_header`
- `test_upload_file`
- `test_range_request`

## Limites operacionais

- `test_client` substitui apenas a camada TCP; parser HTTP, router, middleware e handlers continuam reais;
- `test_mail` captura mensagens em memoria, mas nao simula comportamento SMTP remoto;
- `test_tasks` executa callbacks reais, porem no mesmo processo e sem polling externo;
- `test_seo` usa parse textual previsivel para sitemap e meta tags, sem introduzir parser XML/HTML separado.

## Gate da fase

O bloco fecha quando:

- `24A` cobre GET, redirect, cookie jar, JSON, form-urlencoded e multipart;
- `24B` cobre envio, destinatario, assunto, corpo texto/HTML e limpeza do outbox;
- `24C` cobre enqueue, flush sincrono, retry, erro terminal e fila customizada;
- `24D` cobre sitemap, robots, meta tags, proxy header, upload e range request;
- `tests/run_tests.sh 24A 24B 24C 24D` fica verde.

No estado implementado, a FASE 24 adiciona 21 testes de integracao e passa a servir como base canonica para fases seguintes de DX e testes end-to-end internos.
