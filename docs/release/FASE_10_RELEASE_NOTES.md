# FASE 10 Release Notes

## Entregas

- `lib/civitas/model/` com schema declarativo, DDL para SQLite e registro opaco de modelos;
- `lib/civitas/query/` com query builder explicito, `SELECT` parametrizado sobre prepared statements e mutacoes parametrizadas;
- `lib/civitas/migrate/migrate.cct` com migracoes versionadas, status e rollback do ultimo passo;
- `lib/civitas/taxonomy/` com slugs por locale, categorias e tags polimorficas;
- `lib/civitas/social/` com comentarios moderaveis, reacoes idempotentes, view counters e soft delete;
- `lib/civitas/authorship/` com origem de conteudo, review state persistido e emissao de auditoria;
- `lib/civitas/pages/` com CRUD de paginas, SEO, menu e agendamento;
- expansao do runner unico para cobrir `10A-10G`.

## Decisoes relevantes

- a fase permanece SQLite-first e explicita; a abstracao multi-backend fica para a fase seguinte;
- o query builder gera SQL visivel e bind parametrizado por construcao, sem esconder o banco atras de ORM magico;
- `query_all(...)` devolve o statement preparado para iteracao manual de rows, preservando controle sobre custo e mapeamento;
- slugs, comentarios, review e paginas sao modulos separados para manter o nucleo pequeno e composicional;
- a documentacao consolidada desta fase descreve apenas o comportamento realmente refletido no codigo entregue.

## Cobertura de testes

A FASE 10 adiciona:

- 5 testes em `10A`
- 5 testes em `10B`
- 5 testes em `10C`
- 5 testes em `10D`
- 5 testes em `10E`
- 5 testes em `10F`
- 5 testes em `10G`

Total da FASE 10: 35 testes de integracao.

## Estado do gate

O bloco `10A-10G`, fechando a FASE 10, so e considerado concluido com:

- `10A` verde isoladamente;
- `10B` verde isoladamente;
- `10C` verde isoladamente;
- `10D` verde isoladamente;
- `10E` verde isoladamente;
- `10F` verde isoladamente;
- `10G` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
