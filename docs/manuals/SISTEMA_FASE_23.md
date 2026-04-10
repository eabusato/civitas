# Sistema Fase 23

## Escopo

A FASE 23 transforma o Civitas em um framework que ja nasce com tooling proprio de projeto. O bloco entrega:

- `civitas new` para scaffolding inicial;
- `civitas generate` para model, migration, API e admin;
- `civitas_management` para `migrate`, `rollback`, `seed`, `shell`, `test`, `collect_static` e `create_superuser`;
- `civitas_config` para leitura compartilhada de `civitas.toml`, defaults, expansao de ambiente, validacao e `doctor`.

O objetivo operacional da fase e reduzir bootstrap manual, manter codigo gerado deterministico e centralizar configuracao de projeto em um contrato unico. No estado atual do framework, o scaffold canonico separa explicitamente `project/` e `apps/` do runtime local em `data/` e `.civitas/`.

No estado atual do Civitas, esse scaffold tambem oferece estilos de crescimento:

- `starter`: arvore minima e direta para equipes pequenas ou prototipos serios;
- `layered`: adiciona `services/`, `queries/`, `policies/`, `jobs/`, `contracts/`, `docs/adr/` e `docs/runbooks/` para times que querem uma disciplina mais explicita;
- `domain`: nasce com `apps/public`, `apps/accounts`, `apps/backoffice` e `apps/shared`, deixando `project/` como ponto de composicao raiz.

## Arquitetura

`civitas_new` cria a arvore base do projeto. `civitas_generate` escreve os artefatos incrementais dentro dessa arvore. `civitas_config` resolve o manifesto de runtime e `civitas_management` usa essa mesma resolucao para executar operacoes de banco, assets e testes.

Fluxo canonico:

1. `civitas new meu_app --template web --style layered`
2. `civitas generate model Post title:VERBUM published:VERUM`
3. `civitas generate api Post`
4. `civitas migrate`
5. `civitas create_superuser`
6. `civitas doctor`

## Contrato de `civitas.toml`

O manifest compartilha estes grupos:

- `[project]`: `name`, `version`, `entry`
- `[server]`: `host`, `port`
- `[database]`: `driver`, `url`
- `[dev]`: `src_dir`, `poll_ms`, `build_cmd`, `server_cmd`
- `[static]`: `src_dir`, `out_dir`, `url_prefix`
- `[admin]`: `prefix`
- `[dirs]`: `migrations`, `templates`, `tests`, `models`, `handlers`

Regras normativas:

- `database.driver` aceita apenas `sqlite` ou `postgres`
- `database.url` e expandido quando usa `${VAR}`
- caminhos relativos do manifesto sao resolvidos a partir do diretorio do proprio `civitas.toml`
- `project.entry` deve apontar para um arquivo real quando o projeto passa em `doctor`

## Geração e management

O gerador de model produz:

- `apps/core/models/<nome>.cct`
- `migrations/NNNN_create_<nome>.sql`

O gerador de API produz:

- `apps/core/views/<nome>.cct`
- `apps/core/routes/<nome>.cct`
- atualizacao de `apps/core/urls.cct`

Quando o projeto usa o estilo `domain` ou quando a equipe decide dividir o codigo em apps explicitamente, os generators tambem podem mirar uma app nomeada, por exemplo `accounts`, preservando a mesma estrutura em `apps/<app>/...`.

O management opera sobre SQL real:

- `migrate`: aplica `-- UP` das migrations pendentes e registra em `_civitas_migrations`
- `rollback N`: executa `-- DOWN` das ultimas `N`
- `seed`: executa `seed.sql` ou `seeds/seed.sql`
- `collect_static`: copia a arvore de static e registra hash curto por arquivo
- `create_superuser`: garante tabela `usuarios` e grava hash PBKDF2

## Doctor

`civitas_doctor_run(...)` verifica:

- existencia de `civitas.toml`
- `project.name`
- existencia do `entry`
- validade de `database.driver`
- presenca de `database.url`
- existencia de `migrations/`
- existencia de `tests/`
- existencia do diretório de static source
- formato do `admin.prefix`

O resultado sai como `DoctorReport`, com `ok`, `errors`, `warnings` e uma lista tipada de `DoctorCheck`.

## Gate da fase

O bloco fecha quando:

- `23A` cria templates `minimal`, `web` e `api`
- `23B` gera codigo CCT/SQL deterministico, atualiza `apps/core/urls.cct` e suporta escrita em apps nomeadas sem quebrar o layout canonico
- `23C` aplica migration, rollback, seed, collect static, parseia resultado de testes e cria superuser
- `23D` carrega `civitas.toml`, valida o manifesto e diagnostica projeto com `doctor`
- `tests/run_tests.sh 23A 23B 23C 23D` fica verde

No estado implementado, a fase adiciona tooling de projeto sem introduzir runtime paralelo nem depender de Python para a logica principal.
