# Manual Aprofundado do Sistema — FASE 14

## Visao geral

A FASE 14 consolida a baseline de internacionalizacao e localizacao do Civitas. O bloco `14A-14E` entrega catalogos por locale, fallback de traducao, formatacao localizada de numeros/datas/moedas, resolucao de locale por request, catalogo JSON nativo e formatacoes avancadas para interface como tempo relativo, ordinais e listas com conjuncao.

O bloco entrega:

- `civitas/i18n` para registro de catalogos e traducao com fallback;
- `civitas/l10n` para formatacao canonica de numeros, percentuais, datas e moedas;
- `civitas/locale` para parse, negociacao e injecao do locale no `LocalContext`;
- `civitas/i18n_catalog_json` para round-trip e merge de catalogos JSON;
- `civitas/l10n_fmt` para formatos textuais avancados orientados a interface.

## `civitas/i18n`

O contrato vive em `lib/civitas/i18n/`.

Capacidades estabilizadas:

- `I18nConfig`, `I18nRegistry` e `I18nLocaleEntry`;
- `i18n_config_new(...)`, `i18n_registry_new(...)`, `i18n_registry_add_catalog(...)` e `i18n_registry_load_locale(...)`;
- `i18n_registry_load_all(...)` para carga em lote de arquivos `.po`;
- `i18n_t(...)` e `i18n_t_plural(...)` com fallback para locale padrao;
- `i18n_locale_active(...)` e `i18n_t_ctx(...)` para integracao com `LocalContext`.

Limites operacionais:

- o mecanismo de traducao continua sendo `cct/gettext`; o Civitas so adiciona registry, fallback e integracao com contexto;
- o fallback distingue catalogo ausente de chave ausente por meio da lista de `known_keys`, evitando falsos positivos quando `gettext_translate(...)` retorna a propria chave.

## `civitas/l10n`

O contrato vive em `lib/civitas/l10n/`.

Capacidades estabilizadas:

- `NumberRules`, `DateRules`, `CurrencyRules`, `LocaleRules` e `L10nRulesRegistry`;
- regras embutidas para `pt-BR`, `en-US`, `de-DE` e `fr-FR`;
- `l10n_rules_registry_new(...)`, `l10n_rules_registry_add(...)`, `l10n_rules_registry_get(...)` e `l10n_rules_for_ctx(...)`;
- `l10n_format_int(...)`, `l10n_format_real(...)`, `l10n_format_percent(...)`;
- `l10n_format_date(...)`, `l10n_format_datetime(...)`, `l10n_format_date_str(...)`;
- `l10n_format_currency(...)`, `l10n_format_brl(...)`, `l10n_format_usd(...)` e `l10n_format_eur(...)`.

Limites operacionais:

- a fase cobre regras numericas e de calendario gregoriano, sem calendarios alternativos;
- o formato de moeda desta fase e baseado em prefixo/sufixo, espaco e casas decimais, sem CLDR completo.

## `civitas/locale`

O contrato vive em `lib/civitas/locale/`.

Capacidades estabilizadas:

- tipo `Locale` com `lang`, `regiao` e `script`;
- `locale_parse(...)`, `locale_to_string(...)`, `locale_equals(...)` e `locale_matches_lang(...)`;
- `locale_parse_accept_language(...)` com parse de `q=` e ordenacao por prioridade;
- `locale_negotiate(...)` e `locale_negotiate_from_header(...)`;
- `LocaleConfig`, `locale_config_new(...)`, `locale_config_add(...)` e `locale_supported_match(...)`;
- `locale_from_cookie(...)`, `locale_to_cookie(...)`, `locale_resolve_for_request(...)` e `locale_middleware_apply(...)`.

Limites operacionais:

- a negociacao cobre match exato e match por idioma, sem estrategia mais sofisticada de script/regiao equivalente;
- a preferencia por perfil de usuario nao faz parte desta fase e fica para fases posteriores.

## `civitas/i18n_catalog_json`

O contrato vive em `lib/civitas/i18n_catalog_json/`.

Capacidades estabilizadas:

- `JsonCatalogEntryKind`, `JsonCatalogEntry` e `JsonCatalog`;
- `i18n_json_parse(...)`, `i18n_json_load_file(...)` e `i18n_json_to_catalog(...)`;
- `i18n_json_entry_keys(...)` e `i18n_json_load_into_registry(...)`;
- `i18n_json_catalog_to_json(...)` e `i18n_json_write(...)`;
- `i18n_json_merge(...)` com override por chave.

Limites operacionais:

- o formato JSON e uma representacao alternativa que continua alimentando `Catalog` de `cct/gettext`;
- o namespace de chave usa ponto literal (`nav.home`, `posts.title`) e nao objeto aninhado;
- placeholders como `{n}` continuam sendo responsabilidade do chamador.

## `civitas/l10n_fmt`

O contrato vive em `lib/civitas/l10n_fmt/`.

Capacidades estabilizadas:

- `RelTimeRules`, `MonthNames`, `DayNames`, `OrdinalRules`, `ListRules`, `L10nFmtRules` e `L10nFmtRegistry`;
- regras embutidas para `pt-BR`, `en-US`, `de-DE` e `fr-FR`;
- `l10n_reltime(...)`, `l10n_month_name(...)`, `l10n_format_date_long(...)`, `l10n_format_ordinal(...)` e `l10n_format_list(...)`;
- `l10n_fmt_registry_new(...)`, `l10n_fmt_registry_add(...)`, `l10n_fmt_registry_get(...)` e `l10n_fmt_rules_for_ctx(...)`.

Limites operacionais:

- a fase usa regras explicitamente registradas por locale e nao um banco amplo estilo CLDR;
- por estabilidade do subset executavel, os formatadores avancados recebem `SPECULUM L10nFmtRules` em vez de structs aninhados retornados por valor;
- pluralizacao de tempo relativo e binaria (`singular/plural`) nesta baseline.

## Cobertura de testes

Cobertura da FASE 14:

- `14A`: 6 testes
- `14B`: 5 testes
- `14C`: 5 testes
- `14D`: 5 testes
- `14E`: 5 testes

Total da FASE 14: 26 testes de integracao.
