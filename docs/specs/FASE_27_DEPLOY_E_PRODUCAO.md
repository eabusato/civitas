# FASE 27 — Deploy e Produção

## Objetivo

Entregar a base de operação local de produção do Civitas para o bloco `27A-27B`: topologia persistente de storage, backup verificável, restore seguro e rollback simples de binário.

## Módulos

- `lib/civitas/storage/storage.cct`
- `lib/civitas/backup/backup.cct`
- `lib/civitas/restore/restore.cct`

## Contratos implementados

### 27A

- `StorageTopology`
- `storage_topology_new(...)`
- `storage_topology_from_env(...)`
- `storage_topology_ensure_dirs(...)`
- `storage_topology_db_path(...)`
- `storage_topology_main_db_path(...)`
- `storage_topology_sessions_db_path(...)`
- `storage_topology_media_dir(...)`
- `storage_topology_media_path(...)`
- `storage_topology_promote_tmp(...)`
- `storage_topology_tmp_sweep(...)`
- `storage_dir_size_bytes(...)`
- `BackupConfig`
- `BackupResult`
- `backup_sqlite(...)`
- `backup_verify_sqlite(...)`
- `backup_list_sqlite_paths(...)`
- `backup_latest_sqlite_path(...)`
- `backup_media_snapshot(...)`
- `backup_latest_media_snapshot(...)`

### 27B

- `RestoreConfig`
- `RestoreResult`
- `DeployState`
- `restore_latest_sqlite_path(...)`
- `restore_sqlite(...)`
- `restore_latest_media_snapshot(...)`
- `restore_media_snapshot(...)`
- `restore_media_latest(...)`
- `restore_full(...)`
- `deploy_promote_binary(...)`
- `deploy_rollback(...)`
- `deploy_signal_restart(...)`
- `deploy_wait_ready(...)`

## Contratos operacionais importantes

- `StorageTopology` é um contrato novo e não altera a semântica anterior de `StorageConfig`;
- backup SQLite usa `VACUUM INTO` porque esse é o caminho público disponível no CCT atual;
- todo snapshot SQLite precisa passar `PRAGMA integrity_check`;
- `processed/` e `private/` entram em backup; `tmp/` e `thumbs/` ficam fora por contrato;
- restore sempre preserva uma cópia `pre-restore` do alvo ativo antes da promoção;
- rollback de deploy preserva a versão revertida como `app.broken`.

## Limites explícitos

- não há upload automático para storage remoto neste bloco;
- não há retenção temporal baseada em dias, apenas retenção por quantidade;
- `deploy_wait_ready(...)` é um helper operacional simples e depende de um probe HTTP externo;
- a fase ainda não inclui orquestração completa de processo/host fora do filesystem local.

## Cobertura

Foram adicionados 9 arquivos de teste de integração:

- `27A`: 4 arquivos cobrindo 6 cenários úteis
- `27B`: 5 arquivos cobrindo 5 cenários úteis

## Gate

- `cct-host test fase27_27a_ --project .`
- `cct-host test fase27_27b_ --project .`
- `bash tests/run_tests.sh 27A 27B`

Todos precisam ficar verdes antes do gate completo da suíte.
