# FASE 22 — Dev Server, Debug Toolbar e Hot Reload

## Escopo implementado

Esta spec consolida o que foi implementado no bloco `22A-22C`.

### 22A

- watch de arquivos `.cct` via `cct/fs_watch`;
- parse de erro de compilacao e pagina HTML de erro;
- rebuild com `build_cmd`;
- restart do alvo com `server_cmd`;
- controle de geracao em arquivo.

### 22B

- coleta de spans `db` e `cache` sobre `Trace`;
- deteccao de N+1 por SQL normalizado;
- toolbar HTML injetada em respostas HTML;
- painel de trace com SVG inline produzido por `trace_render_svg(...)`;
- links para o painel da FASE 21 (`/civitas/traces/<trace_id>` e `/svg`).

### 22C

- leitura e escrita de geracao;
- endpoint de polling por `gen`;
- injecao do snippet de livereload antes de `</body>`;
- aplicacao apenas em respostas HTML.

## Contrato de sigilo vivo

O contrato valido para a fase e:

- o diagnostico visual do request e um **sigilo animado completo do CCT**;
- nao e valido substituir esse renderer por timeline simplificada, mini barras ou mock visual;
- o HTML gerado pela toolbar precisa conter o SVG real, incluindo marcadores como `trace-packet` e animacao do renderer do CCT.

No codigo isso e garantido por:

- `lib/civitas/debug_toolbar/debug_toolbar.cct`
- `lib/civitas/trace_render/trace_render.cct`

com `TraceRenderConfig` apontando para `sigil_view = "routes"`.

## Contrato de rebuild

`DevWatcher` preserva:

- `has_error = VERUM` quando o build falha;
- `error.raw_output` com a saida original do compilador;
- `reload_count` incrementado apenas em sucesso;
- `gen_file` atualizado apenas em sucesso.

O build e considerado falho quando a saida contem o marcador `: erro:` ou texto equivalente de erro normalizado.

## Contrato de toolbar

`debug_toolbar_collect(...)` produz:

- `sql_count`;
- `cache_hits`;
- `cache_misses`;
- `n_plus_one`;
- `n_plus_one_query`;
- `n_plus_one_count`.

`debug_toolbar_apply(...)`:

- nao altera respostas nao HTML;
- injeta a toolbar apenas uma vez;
- preserva o body original e acrescenta a toolbar antes de `</body>`.

## Contrato de livereload

`livereload_handler(...)`:

- le `gen` atual de `cfg.gen_file`;
- compara com `request_query_first(req, "gen")`;
- retorna JSON com `reload = true` apenas quando os valores diferem e o cliente enviou um `gen` previo.

`livereload_apply(...)`:

- nao altera respostas nao HTML;
- nao injeta duas vezes;
- usa o snippet com `fetch(..., {cache:'no-store'})`.

## Limite operacional conhecido

O registro automatico de handler com captura de configuracao no router nao foi materializado como API generica porque o CCT atual nao fornece um construtor publico de callback equivalente ao pseudo-`callback_new_1(...)`. O wiring do endpoint continua manual no app hospedeiro, mas os handlers e transforms da fase estao completos e testados isoladamente.

## Evidencia de validacao

Cobertura adicionada:

- `tests/integration/fase_22/22a`: 5 testes
- `tests/integration/fase_22/22b`: 5 testes
- `tests/integration/fase_22/22c`: 5 testes

Criticos do contrato:

- `fase22_22b_render_html_includes_real_sigilo.test.cct`
- `fase22_22b_apply_injects_before_body.test.cct`
- `fase22_22c_handler_detects_reload.test.cct`
- `fase22_22a_rebuild_success_and_failure.test.cct`
