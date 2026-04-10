# Sistema Fase 28

## Escopo

O bloco implementado da FASE 28 cobre `28A-28D` e fecha a linha Civitas 1.0 com hardening final, auditoria local e material de release reproduzível:

- auditoria estrutural de headers, rotas mutáveis sem CSRF e guard de static traversal;
- fuzzing HTTP determinístico sobre o parser real do CCT;
- carga in-process sobre `Router` via `TestClient`, com percentis e comparação entre execuções;
- watch de memória sobre o `memory_profiler` existente;
- revisão local de dependências e CVEs a partir de inventário explícito e base offline;
- geração de bundle de documentação e release notes versionadas.

O corte não tenta inventar SAST externo, benchmark distribuído nem feed online de vulnerabilidades. A fase fecha a superfície que o próprio Civitas controla em CCT puro.

## Arquitetura

### `civitas/security_audit`

`security_audit` executa auditoria local sobre três superfícies:

- headers de resposta esperados para baseline de segurança;
- manifesto do `Router`, procurando rotas `POST/PUT/PATCH/DELETE` sem middleware chamado `csrf`;
- roots de static, validando traversal com `static_caminho_seguro(...)`.

O resultado é modelado por `ScanResult`, com lista de `Vuln` contendo severidade, tipo e localização.

### `civitas/fuzz_http`

`fuzz_http` exercita `http_parse_request(...)` e `http_parse_response(...)` do CCT com corpus determinístico de requests/responses válidos e de borda. O módulo não promete random fuzzing infinito; ele entrega gate reproduzível e rápido para regressão do parser.

### `civitas/load_test`

`load_test` usa `TestClient` e `Router` in-process para medir latência e taxa de erro sem abrir socket. O contrato é deliberadamente local:

- rotas são cadastradas com peso;
- a execução percorre amostras determinísticas;
- p50/p95/p99 são derivados da infraestrutura de `bench`;
- `load_compare(...)` identifica regressão entre baseline e execução atual.

### `civitas/mem_watch`

`mem_watch` não reinventa profiler. Ele encapsula `memory_profiler` e expõe leitura operacional curta para:

- total de requests observados;
- maior delta de bytes vivos;
- suspeita de leak por limiar;
- export simplificado para o bloco 28.

### `civitas/dep_review`

`dep_review` inventaria dependências concretas do ambiente local e cruza esse inventário com `security/known_cves.json`. O contrato é offline, reproduzível e explícito:

- `libsqlite3`, `libpq`, `openssl`, `zlib` e `ffprobe` entram no inventário padrão;
- versões são detectadas localmente ou marcadas como `unknown`;
- ranges semver simples são comparados sem feed remoto;
- o relatório pode ser emitido em JSON.

### `civitas/doc_gen` e `civitas/release`

Esses dois módulos fecham a camada de materialização final:

- `doc_gen` gera bundle mínimo de onboarding, uso, API, produção, segurança e contribuição;
- `release` gera `CHANGELOG.md`, release notes versionadas e um pacote de docs no diretório de saída;
- a release da FASE 28 registra explicitamente que a linha 1.0 encerra em `28D` e não prossegue para as fases `29-31`.

## Contratos implementados

### 28A

- `ScanConfig`
- `ScanResult`
- `Vuln`
- `security_audit_scan_headers(...)`
- `security_audit_scan_router(...)`
- `security_audit_scan_static_root(...)`
- `security_audit_scan_all(...)`
- `FuzzConfig`
- `FuzzResult`
- `fuzz_http_run(...)`

### 28B

- `LoadRoute`
- `LoadConfig`
- `LoadResult`
- `LoadComparison`
- `load_test_run_inprocess(...)`
- `load_compare(...)`
- `MemWatchConfig`
- `MemWatchResult`
- `mem_watch_fill_from_report(...)`
- `mem_watch_fill_from_state(...)`

### 28C

- `DepType`
- `CveSeverity`
- `CveEntry`
- `DepInfo`
- `DepReport`
- `dep_review_inventory_civitas()`
- `dep_review_apply_db(...)`
- `dep_review_run(...)`
- `dep_review_report_json(...)`

### 28D

- `DocConfig`
- `doc_gen_build(...)`
- `doc_gen_quickstart(...)`
- `doc_gen_user_guide(...)`
- `doc_gen_api_reference(...)`
- `doc_gen_production(...)`
- `doc_gen_security(...)`
- `doc_gen_contributing(...)`
- `doc_gen_index(...)`
- `ReleaseConfig`
- `release_build_changelog(...)`
- `release_build_notes(...)`
- `release_finalize(...)`

## Limites explícitos

- `security_audit` faz auditoria estrutural do que o framework expõe localmente; não substitui pentest externo;
- `fuzz_http` é corpus determinístico, não engine randômica contínua;
- `load_test` mede caminho in-process, não throughput real de rede/múltiplos workers;
- `dep_review` não baixa CVE remoto e depende da base local versionada com o repositório;
- `doc_gen` gera bundle curado para 1.0, não documentação introspectiva completa de todos os símbolos internos.

## Gate do bloco

O bloco `28A-28D` fecha quando:

- `28A` valida audit de headers, rotas, static traversal e fuzzing HTTP;
- `28B` valida carga in-process, comparação de regressão e watch de memória;
- `28C` valida comparação de versões, aplicação de ranges e emissão JSON do review de dependências;
- `28D` valida geração do bundle de docs, changelog e release notes versionadas;
- `tests/run_tests.sh 28A 28B 28C 28D` fica verde;
- o gate completo histórico permanece verde;
- a documentação consolidada passa a registrar a FASE 28 como encerramento da linha Civitas 1.0.
