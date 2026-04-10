# FASE 18 Release Notes

## Entregas

- `lib/civitas/admin/` com registry de modelos, listagem, CRUD, bulk, auditoria, inlines, computed fields builtin, permissoes, acoes customizadas, widgets e export CSV;
- `lib/civitas/admin_moderation/` com filas de moderacao, decisoes auditaveis e bulk best-effort;
- `lib/civitas/admin_dashboard/` com snapshots operacionais, visao de filas, falhas recentes e task agendada de refresh;
- suporte compartilhado de testes em `tests/integration/fase_18/`;
- expansao do runner unico para cobrir `18A-18E`.

## Decisoes relevantes

- o admin materializado nesta fase e registry-driven e persiste configuracao em tabelas canonicas, sem prometer uma interface reflexiva/magica fora desses contratos;
- os inlines foram fechados em torno de ownership por `fk_field` e submissao transacional;
- campos calculados ficaram deliberadamente controlados por resolvedor builtin para manter o subset executavel estavel;
- a moderacao foi conectada ao subsistema de tasks apenas quando ha efeito assíncrono claro;
- o dashboard operacional mistura snapshot persistido e consultas ao vivo para reduzir custo sem esconder filas e falhas recentes.

## Cobertura de testes

A FASE 18 adiciona:

- 5 testes em `18A`
- 5 testes em `18B`
- 5 testes em `18C`
- 5 testes em `18D`
- 5 testes em `18E`

Total da FASE 18: 25 testes de integracao.

## Estado do gate

O bloco `18A-18E`, fechando a FASE 18, so e considerado concluido com:

- `18A` verde isoladamente;
- `18B` verde isoladamente;
- `18C` verde isoladamente;
- `18D` verde isoladamente;
- `18E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
