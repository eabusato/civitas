# FASE 23 — Scaffolding e CLI

## Objetivo

Entregar a primeira CLI nativa do Civitas para ciclo de vida de projeto: criacao, geracao incremental, operacao basica e diagnostico.

## Módulos

- `lib/civitas/civitas_new/civitas_new.cct`
- `lib/civitas/civitas_generate/civitas_generate.cct`
- `lib/civitas/civitas_management/civitas_management.cct`
- `lib/civitas/civitas_config/civitas_config.cct`

## Contratos implementados

### 23A

- `civitas_new_create_minimal`
- `civitas_new_create_web`
- `civitas_new_create_api`
- `--style starter|layered|domain`
- recusa destino existente sem `force`
- scaffolds gerados compilam dentro do contrato atual do repositório

### 23B

- parse de campos `name:TYPE` com nullable por `?`
- mapeamento CCT/SQL para `VERBUM`, `REX`, `UMBRA`, `VERUM`, `DATE`, `DATETIME`
- migrations numeradas sequencialmente
- `generate api` escreve handler/route em `apps/core` e atualiza `apps/core/urls.cct`
- generators tambem podem escrever em `apps/<app>` quando o projeto cresce para multiplas apps
- `generate admin` exige modelo alvo

### 23C

- `migrate` aplica apenas migrations pendentes
- `rollback` usa a secao `-- DOWN`
- `seed` executa `seed.sql` ou `seeds/seed.sql`
- `test` parseia resumo padrao do runner
- `collect_static` copia a arvore para `public/static`
- `create_superuser` cria ou atualiza `usuarios` com hash PBKDF2

### 23D

- `civitas_project_load` aplica defaults e expansao de ambiente
- `civitas_project_validate` rejeita driver invalido, URL vazia e porta invalida
- `civitas_doctor_run` produz checklist tipado de saude do projeto
- `civitas_management_load_project` passou a delegar para o loader compartilhado

## Limites operacionais

- o scaffolding gerado e propositalmente seguro para compilar no estado atual do Civitas; ele prepara `project/`, `apps/`, `settings/`, `data/` e `.civitas/`, mas nao promete bootstrap HTTP completo por si so
- `starter` prioriza simplicidade, `layered` prioriza separacao interna da app e `domain` prioriza composicao de multiplas apps desde o primeiro commit
- o management trabalha sobre SQL explicito e manifesto do projeto; nao existe ORM oculto nesse bloco
- o doctor diagnostica pre-requisitos locais do projeto, nao executa deploy nem health check remoto

## Gate

- `cct-host test fase23_23a_ --project .`
- `cct-host test fase23_23b_ --project .`
- `cct-host test fase23_23c_ --project .`
- `cct-host test fase23_23d_ --project .`
- `bash tests/run_tests.sh 23A 23B 23C 23D`

Todos precisam ficar verdes antes do gate completo da suite.
