# FASE 14 — i18n e l10n Baseline

## Escopo consolidado

O bloco `14A-14E` estabiliza a baseline multilocale do Civitas em cinco partes:

- registry de catalogos gettext por locale;
- formatacao localizada de numeros, datas, percentuais e moedas;
- resolucao de locale por request via `Accept-Language`, cookie e fallback;
- catalogo JSON nativo com round-trip e merge;
- formatos avancados de interface como tempo relativo, data longa, ordinal e lista com conjuncao.

## Contratos implementados

### `civitas/i18n`

- `I18nConfig`, `I18nRegistry`, `I18nLocaleEntry`;
- carga de catalogos `.po` por locale e carga em lote por diretorio;
- `i18n_t(...)`, `i18n_t_plural(...)`, `i18n_t_ctx(...)` e `i18n_locale_active(...)`;
- fallback para locale padrao quando o locale solicitado nao existe ou nao contem a chave.

Limites operacionais:

- o backend continua sendo `cct/gettext`;
- a distincao entre catalogo ausente e chave ausente depende de `known_keys` capturados na carga do catalogo.

### `civitas/l10n`

- `LocaleRules` e registry por locale;
- regras embutidas para `pt-BR`, `en-US`, `de-DE` e `fr-FR`;
- formatacao de inteiro, real, percentual, data, datetime e moeda.

Limites operacionais:

- somente calendario gregoriano;
- o formato monetario e configurado por regras simples de simbolo, separadores e casas decimais.

### `civitas/locale`

- `Locale`, parse BCP 47 e serializacao canonica;
- parse de `Accept-Language` com `q-values`;
- negociacao por match exato e match por idioma;
- cookie de preferencia de locale;
- middleware que injeta o locale resolvido em `LocalContext`.

Limites operacionais:

- precedencia implementada: cookie, header e locale padrao;
- prefixo de URL nao foi integrado ao router nesta baseline e permanece como ponto de extensao controlado.

### `civitas/i18n_catalog_json`

- parse de catalogo JSON;
- conversao para `Catalog` gettext;
- round-trip de escrita para arquivo;
- merge por override entre dois catalogos JSON;
- integracao direta com `I18nRegistry`.

Limites operacionais:

- `entries` e `plurais` usam chaves planas com ponto, sem nesting real;
- placeholders nao sao interpolados pelo modulo.

### `civitas/l10n_fmt`

- regras avancadas por locale para tempo relativo, nomes de mes, ordinal e lista;
- regras embutidas para `pt-BR`, `en-US`, `de-DE` e `fr-FR`;
- registry por locale com fallback para locale padrao.

Limites operacionais:

- tempo relativo usa singular/plural e janelas simples de segundos/minutos/horas/dias/semanas/meses/anos;
- as APIs avancadas recebem `SPECULUM L10nFmtRules` por restricao operacional do subset executavel atual.

## Cobertura

O bloco fecha com 26 testes de integracao:

- 6 em `14A`
- 5 em `14B`
- 5 em `14C`
- 5 em `14D`
- 5 em `14E`

## Estado esperado do gate

O bloco `14A-14E` so e considerado concluido com:

- todas as subfases verdes isoladamente;
- `tests/run_tests.sh` cobrindo `14A-14E`;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
