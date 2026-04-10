# FASE 27 Release Notes

## Bloco entregue

Este fechamento cobre o bloco `27A-27B` da FASE 27.

## Entrou

- topologia canônica de produção em `civitas/storage`, separada do contrato antigo de `StorageConfig`;
- backup de SQLite por `VACUUM INTO` com verificação de integridade;
- snapshot de mídia para `processed/` e `private/`;
- retenção por quantidade para snapshots de banco e mídia;
- restore validado de banco e mídia com preservação de `pre-restore`;
- swap e rollback simples de binário com `app.prev` e `app.broken`.

## Impacto prático

Um projeto Civitas agora consegue:

- organizar dados persistentes em árvore previsível de produção;
- tirar snapshot local do SQLite sem inventar shell wrapper fora do framework;
- restaurar o último snapshot válido e manter uma cópia do estado anterior;
- recuperar `processed/` e `private/` sem incluir lixo temporário de upload;
- fazer promoção e rollback local de binário em convenção simples de deploy.

## Compatibilidade

- a superfície antiga de storage para mídia continua preservada;
- o bloco novo cresce em torno de `StorageTopology`, não por mutação do contrato antigo;
- não houve regressão no gate histórico do Civitas.

## Validação

- `fase27_27a_` verde
- `fase27_27b_` verde
- `tests/run_tests.sh 27A 27B` verde
- `tests/run_tests.sh` verde
