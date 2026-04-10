# Sistema Fase 27

## Escopo

O bloco implementado da FASE 27 cobre `27A-27B` e fecha a base operacional de deploy e produção do Civitas em ambiente file-backed:

- topologia canônica de diretórios persistentes para banco, mídia, cache, logs, backups e runtime;
- backup verificável de SQLite com `VACUUM INTO` e checagem por `PRAGMA integrity_check`;
- snapshot de mídia para `processed/` e `private/`, com exclusão explícita de `tmp/` e `thumbs/`;
- restore validado de banco e mídia, preservando cópias `pre-restore`;
- promoção e rollback de binário com convenção `app`, `app.prev` e `app.broken`.

O corte não tenta substituir orquestração externa. O Civitas passa a oferecer primitivas nativas de storage, backup e restore que um projeto pode chamar diretamente ou integrar em CLI/management command posterior.

## Arquitetura

### `civitas/storage`

O módulo existente de storage local continua responsável pelo `MediaStore` canônico do framework. A FASE 27 adiciona, no mesmo módulo, uma camada de topologia operacional separada:

- `StorageTopology` modela `base_dir`, `db_dir`, `media_dir`, `cache_dir`, `backups_dir`, `logs_dir` e `run_dir`;
- `storage_topology_from_env(...)` resolve `CIVITAS_DATA_DIR` / `DATA_DIR` e `CIVITAS_LOG_DIR` / `LOG_DIR`;
- `storage_topology_ensure_dirs(...)` cria a árvore inteira sem alterar o contrato antigo de `StorageConfig`;
- `storage_topology_*_path(...)` resolve caminhos de `main.db`, `sessions.db` e arquivos de mídia;
- `storage_topology_tmp_sweep(...)` remove temporários antigos via `fs` e `modified_time`, sem depender de `find`.

Isso preserva compatibilidade com a superfície de storage da FASE 9 e introduz um contrato novo para produção.

### `civitas/backup`

O módulo de backup trabalha sobre `StorageTopology`:

- `backup_sqlite(...)` executa `VACUUM INTO` no banco ativo, grava snapshot em `backups/db/` e valida o resultado;
- `backup_verify_sqlite(...)` abre o snapshot e exige `PRAGMA integrity_check = ok`;
- `backup_list_sqlite_paths(...)` e `backup_latest_sqlite_path(...)` expõem inventário e último snapshot;
- `backup_prune_old_sqlite(...)` aplica retenção por quantidade;
- `backup_media_snapshot(...)` cria snapshot por diretório em `backups/media/<subdir>/<stamp>/`;
- `backup_latest_media_snapshot(...)` e `backup_prune_old_media(...)` fazem lookup e retenção da mídia.

O contrato de mídia é deliberadamente restrito:

- `processed/` entra em backup;
- `private/` entra em backup;
- `thumbs/` fica fora porque é derivável;
- `tmp/` fica fora porque é descartável.

### `civitas/restore`

O módulo de restore fecha a contraparte operacional:

- `restore_sqlite(...)` valida o snapshot, copia para `*.restoring`, revalida, guarda `*.pre-restore` e promove o banco restaurado;
- `restore_media_snapshot(...)` restaura uma snapshot inteira de mídia sobre `processed/` ou `private/`, também com cópia `pre-restore`;
- `restore_latest_sqlite_path(...)` e `restore_latest_media_snapshot(...)` apoiam recuperação rápida do snapshot mais recente;
- `restore_full(...)` compõe parada opcional, restore de banco, restore de mídia e reinício opcional;
- `deploy_promote_binary(...)` e `deploy_rollback(...)` implementam swap simples de binário com `app.prev`.

## Contratos implementados

### Topologia

- layout persistente novo sem quebrar `StorageConfig`;
- resolução de caminhos canônicos para `db/main.db`, `db/sessions.db`, `media/tmp`, `media/processed`, `media/thumbs`, `media/private`, `cache`, `backups`, `logs` e `run`;
- criação idempotente da árvore de diretórios;
- cópia e remoção recursiva em CCT puro para fluxos de backup/restore.

### Backup

- backup SQLite a quente por `VACUUM INTO`, usando apenas a API pública atual de `db_sqlite`;
- verificação explícita de integridade do snapshot;
- retenção por quantidade para banco e mídia;
- snapshot separado por domínio operacional, em vez de backup monolítico do `base_dir`;
- cálculo de tamanho por recursão sobre `fs`, sem depender de `du`.

### Restore e rollback

- restore de SQLite só promove snapshot que passa em duas validações: arquivo original e cópia temporária;
- restore de mídia só aceita `processed` e `private`;
- toda promoção de restore preserva uma cópia `pre-restore` do estado ativo anterior;
- rollback de binário promove `app.prev` para `app` e preserva a versão substituída como `app.broken`.

## Limites operacionais

- o módulo atual não implementa backup remoto nem object storage; o foco do bloco é storage local persistente;
- `deploy_wait_ready(...)` usa polling externo por `curl`, adequado para runbook e automação local, mas não substitui integration test de socket real;
- retenção é por quantidade de snapshots, não por política baseada em idade/calendário;
- o contrato atual assume paths locais em filesystem POSIX.

## Gate do bloco

O bloco `27A-27B` fecha quando:

- `27A` valida topologia, criação de diretórios, paths de banco, sweep de `tmp`, backup SQLite, lookup do snapshot mais recente e prune de mídia;
- `27B` valida restore do snapshot mais recente, restore seguro de SQLite, rejeição de backup inválido, restore de mídia e rollback de binário;
- `tests/run_tests.sh 27A 27B` fica verde;
- o gate completo da suíte continua verde sem regressão histórica.

No estado implementado, a FASE 27 adiciona 9 arquivos de teste de integração ao repositório e fecha a primeira camada operacional de produção para storage, backup e disaster recovery local do Civitas.
