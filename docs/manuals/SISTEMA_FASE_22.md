# SISTEMA FASE 22

## Visao geral

A FASE 22 fecha o loop de desenvolvimento local do Civitas com tres componentes:

- `lib/civitas/dev_server/dev_server.cct`: watch de arquivos `.cct`, rebuild e reinicio controlado;
- `lib/civitas/debug_toolbar/debug_toolbar.cct`: toolbar HTML injetada em respostas HTML com diagnostico do request;
- `lib/civitas/dev_livereload/dev_livereload.cct`: endpoint de polling por geracao e snippet de reload automatico.

O contrato mais importante da fase e que a UX de diagnostico de trace continua baseada nos **sigilos animados completos do CCT**. A toolbar nao renderiza timeline simplificada: ela embute o SVG real produzido por `trace_render_svg(...)`, com `sigil_view = "routes"` e animacao mantida pelo renderer do CCT.

## 22A — Dev Server

O modulo `dev_server` entrega:

- descoberta recursiva de arquivos `.cct` em um `src_dir`;
- watchers por arquivo usando `cct/fs_watch`;
- deteccao de alteracao por evento e por mudanca de cardinalidade do conjunto observado;
- execucao de `build_cmd`;
- parse de erro de compilacao no formato `arquivo:linha:coluna: erro: ...`;
- pagina HTML de erro de compilacao com contexto de codigo;
- reinicio do processo alvo por `server_cmd`;
- arquivo de geracao `.civitas-gen` atualizado apenas em rebuild bem-sucedido.

O comportamento implementado e:

1. salvar um arquivo `.cct`;
2. `dev_server_watch_once(...)` detecta a alteracao;
3. `dev_server_rebuild(...)` roda `build_cmd`;
4. em sucesso: mata o processo antigo, sobe o novo, grava novo `gen`;
5. em falha: preserva `CompileError` no watcher e nao incrementa geracao.

## 22B — Debug Toolbar

O modulo `debug_toolbar` trabalha sobre `Trace`, `WebRequest` e `WebResponse`.

Ele entrega:

- coleta de spans `db` e `cache` por request;
- contagem de hits/misses de cache;
- deteccao simples de N+1 por SQL normalizado;
- render HTML da toolbar;
- injecao antes de `</body>` apenas em respostas HTML;
- painel de headers do request;
- painel de trace com o **sigilo vivo real** embutido inline.

O painel de trace da toolbar inclui:

- link para `/civitas/traces/<trace_id>`;
- link para `/civitas/traces/<trace_id>/svg`;
- SVG inline vindo de `trace_render_svg(trace, cfg.render_cfg)`.

Isso significa que a toolbar da fase 22 reaproveita diretamente a infraestrutura da fase 21, mas sem rebaixar o visual para barras ou timeline. O diagnostico visual do request continua sendo o sigilo de rotas do CCT.

## 22C — Livereload

O modulo `dev_livereload` entrega:

- `livereload_read_gen(...)`;
- `livereload_write_gen(...)`;
- `livereload_handler(...)` sobre `WebRequest`;
- `livereload_js_snippet(...)`;
- `livereload_inject(...)`;
- `livereload_apply(...)`.

O contrato e baseado em polling de geracao:

- o browser consulta `/civitas/livereload`;
- se `gen` mudou, a resposta retorna `{"reload":true}`;
- o script chama `location.reload()`.

O endpoint responde:

- `503 {"error":"starting"}` quando o arquivo de geracao ainda nao existe;
- `200 {"gen":"...","reload":false}` quando nao houve mudanca;
- `200 {"gen":"...","reload":true}` quando o browser precisa recarregar.

## Limites e wiring

O CCT atual nao expõe um callback factory publico com captura de configuracao equivalente ao pseudo-`callback_new_1(...)` usado em alguns rascunhos de planejamento. Por isso, nesta fase o contrato implementado para livereload e toolbar e de **modulos aplicaveis e handlers reutilizaveis**, enquanto o registro no router da app continua sendo wiring explicito do projeto hospedeiro.

Isso nao reduz o contrato funcional da fase:

- o dev server recompila e reinicia;
- o browser detecta mudanca de geracao;
- a toolbar injeta diagnostico por request;
- o painel de trace continua mostrando o sigilo completo do CCT.

## Gate operacional da fase

- editar um `.cct` observavel dispara rebuild;
- falha de compilacao gera pagina HTML com arquivo, linha, coluna e contexto;
- toolbar injeta em HTML e nao injeta em JSON;
- toolbar detecta N+1 simples e mostra headers/cache/sql;
- toolbar embute `trace-packet` e `animateMotion` do SVG real do CCT;
- endpoint de livereload responde por geracao e faz reload apenas quando o `gen` muda.
