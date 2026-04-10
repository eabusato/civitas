# FASE 24 — Test Harness HTTP, Mail, Tasks e SEO

## Objetivo

Entregar infraestrutura de teste de integracao sem I/O externo, preservando os contratos reais de router, mailer, tasks e endpoints de infraestrutura.

## Módulos

- `lib/civitas/test_client/test_client.cct`
- `lib/civitas/test_mail/test_mail.cct`
- `lib/civitas/test_tasks/test_tasks.cct`
- `lib/civitas/test_seo/test_seo.cct`

## Contratos implementados

### 24A

- `TestClient` com router embutido, cookie jar e headers padrao
- `test_client_get/post/put/patch/delete`
- helpers `post_json`, `post_form` e `upload`
- asserts de status, redirect, headers, body e JSON

### 24B

- outbox sobre `MailClient` com `MAIL_BACKEND_MEMORY`
- leitura por indice e ultimo item
- limpeza de outbox
- asserts de contagem, destinatario, assunto, texto e HTML

### 24C

- fila de tasks sobre SQLite `:memory:`
- schema canonico via `tasks_schema_up`
- registry de callbacks de teste
- flush sincrono via `task_worker_run_once`
- asserts por estado observavel da task

### 24D

- fetch e parse simples de `sitemap.xml`
- fetch de `robots.txt`
- asserts de `canonical`, `hreflang` e `og:title`
- assert de proxy headers ecoados por handler
- wrappers para upload multipart e range request

## Limites operacionais

- `test_mail` trabalha no nivel de `MailClient`, nao substitui o wrapper `Mailer` existente;
- `test_tasks` usa banco em memoria, mas continua exercitando o schema e o worker reais da FASE 17;
- `test_seo` cobre infraestrutura HTTP/SEO observavel, nao um crawler completo.

## Cobertura

Foram adicionados 21 testes de integracao:

- `24A`: 5
- `24B`: 5
- `24C`: 5
- `24D`: 6

## Gate

- `cct-host test fase24_24a_ --project .`
- `cct-host test fase24_24b_ --project .`
- `cct-host test fase24_24c_ --project .`
- `cct-host test fase24_24d_ --project .`
- `bash tests/run_tests.sh 24A 24B 24C 24D`

Todos precisam ficar verdes antes do gate completo da suite.
