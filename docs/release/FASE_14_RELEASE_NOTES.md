# FASE 14 Release Notes

## Entregas

- `lib/civitas/i18n/` com registry de catalogos, carga `.po`, fallback por locale e integracao com `LocalContext`;
- `lib/civitas/l10n/` com regras por locale e formatacao de numeros, datas, percentuais e moedas;
- `lib/civitas/locale/` com parse BCP 47, parse de `Accept-Language`, negociacao, cookie de preferencia e middleware;
- `lib/civitas/i18n_catalog_json/` com catalogo JSON nativo, round-trip e merge;
- `lib/civitas/l10n_fmt/` com tempo relativo, data longa, ordinal e lista com conjuncao;
- expansao do runner unico para cobrir `14A-14E`.

## Decisoes relevantes

- o mecanismo de traducao continua centralizado em `cct/gettext`; o JSON de `14D` nao cria um runtime paralelo;
- o registry de i18n persiste `known_keys` por locale para diferenciar chave ausente de traducao igual ao `msgid`;
- a negociacao de locale desta fase privilegia cookie e `Accept-Language`, com fallback para o locale padrao configurado;
- os formatadores avancados de `14E` operam sobre `SPECULUM L10nFmtRules` para manter estabilidade no subset executavel do CCT;
- as regras embutidas cobrem quatro locales canonicamente testados: `pt-BR`, `en-US`, `de-DE` e `fr-FR`.

## Cobertura de testes

A FASE 14 adiciona:

- 6 testes em `14A`
- 5 testes em `14B`
- 5 testes em `14C`
- 5 testes em `14D`
- 5 testes em `14E`

Total da FASE 14: 26 testes de integracao.

## Estado do gate

O bloco `14A-14E`, fechando a FASE 14, so e considerado concluido com:

- `14A` verde isoladamente;
- `14B` verde isoladamente;
- `14C` verde isoladamente;
- `14D` verde isoladamente;
- `14E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
