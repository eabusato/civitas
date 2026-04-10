# FASE 28 — Hardening Final e Auditoria

## Objetivo

Fechar a linha Civitas 1.0 no bloco `28A-28D` com instrumentos locais de auditoria, carga, profiling operacional final de memória/dependências e materialização de documentação/release.

## Módulos

- `lib/civitas/security_audit/security_audit.cct`
- `lib/civitas/fuzz_http/fuzz_http.cct`
- `lib/civitas/load_test/load_test.cct`
- `lib/civitas/mem_watch/mem_watch.cct`
- `lib/civitas/dep_review/dep_review.cct`
- `lib/civitas/doc_gen/doc_gen.cct`
- `lib/civitas/release/release.cct`
- `security/known_cves.json`

## Contratos implementados

### 28A

- auditoria de headers obrigatórios de segurança;
- varredura de rotas mutáveis sem middleware `csrf`;
- validação de traversal sobre static roots com o guard oficial;
- fuzzing HTTP determinístico sobre o parser do CCT para request e response.

### 28B

- execução de carga in-process sobre `Router`;
- percentis de latência e contagem de falhas;
- comparação baseline vs. atual por `load_compare(...)`;
- `mem_watch` sobre `memory_profiler`, com suspeita de leak por limiar configurável.

### 28C

- inventário local de dependências relevantes para a superfície do framework;
- comparação de versões por partes numéricas;
- aplicação de ranges simples de vulnerabilidade;
- relatório JSON reproduzível sem feed online.

### 28D

- geração de `quickstart.md`, `user-guide.md`, `api-reference.md`, `production.md`, `security.md`, `contributing.md` e `index.md`;
- geração de `CHANGELOG.md`;
- geração de `release-notes-v<version>.md`;
- fechamento da release 1.0 sem dependência de fases futuras.

## Contratos operacionais importantes

- a FASE 28 registra o Civitas 1.0 como encerrado em `28D`;
- fases `29`, `30` e `31` não entram na linha 1.0 deste repositório;
- os sigilos continuam sendo os SVGs animados completos do CCT sempre que uma superfície visual de trace é exposta;
- a auditoria de dependência é offline por contrato, para manter reprodutibilidade em CI e em ambientes isolados.

## Cobertura

Foram adicionados 20 testes de integração:

- `28A`: 5
- `28B`: 5
- `28C`: 5
- `28D`: 5

## Gate

- `cct-host test fase28_28a_ --project .`
- `cct-host test fase28_28b_ --project .`
- `cct-host test fase28_28c_ --project .`
- `cct-host test fase28_28d_ --project .`
- `bash tests/run_tests.sh 28A 28B 28C 28D`

Todos precisam ficar verdes antes do gate completo da suíte.
