# FASE 20 Release Notes

## Entregas

- `lib/civitas/trace_config/` com `TraceConfig`, carga por settings/env e bootstrap de instrumentacao;
- `lib/civitas/trace/` com helpers de spans do framework, drenagem de request, flush para `.ctrace` e captura de sessao para testes;
- `lib/civitas/trace_collector/` com sampling, `trace_id`, header opcional e persistencia ao final do request;
- `lib/civitas/trace_store/` com indice SQLite consultavel e retencao basica;
- wrappers de spans explicitos para SQL, cache, storage, midia, email, i18n, moderacao e enqueue de task;
- suporte compartilhado de testes em `tests/integration/fase_20/`;
- expansao do runner unico para cobrir `20A-20D`.

## Decisoes relevantes

- o Civitas adotou o runtime de instrumentacao do CCT como base, em vez de abrir uma pilha paralela de tracing;
- o collector usa sampling deterministico simples e força persistencia de erros para maximizar utilidade operacional;
- o store indexa apenas metadados e referencia o arquivo `.ctrace`, mantendo o SQLite pequeno e rapido;
- os spans explicitos ficaram concentrados em wrappers pequenos por subsistema, evitando espalhar convencoes de observabilidade pelo resto do framework.

## Cobertura de testes

A FASE 20 adiciona:

- 5 testes em `20A`
- 5 testes em `20B`
- 5 testes em `20C`
- 5 testes em `20D`

Total da FASE 20: 20 testes de integracao.

## Estado do gate

O bloco `20A-20D`, fechando a FASE 20, so e considerado concluido com:

- `20A` verde isoladamente;
- `20B` verde isoladamente;
- `20C` verde isoladamente;
- `20D` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
