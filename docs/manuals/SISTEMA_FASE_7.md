# Manual Aprofundado do Sistema — FASE 7

## Visao geral

 A FASE 7 fecha o ciclo server-side de formularios no Civitas.

O bloco `7A-7E` entrega:

- parse canonico de `application/x-www-form-urlencoded` e `multipart/form-data`;
- tipo unificado `FormData` com campos simples, multi-value e uploads;
- validacao declarativa por `FormSchema` e `ValidationResult`;
- sanitizacao reutilizavel para trim, normalizacao de email, strip de tags e normalizacao de espacos;
- sanitizacao rica de conteudo com HTML allowlist, politica de embeds, email/telefone e normalizacao textual;
- render HTML consistente com refill seguro, erros inline, sumario de erros, hidden CSRF, atributos extras controlados e contrato explicito de memoria do builder.

## Parse de formularios

O contrato vive em `lib/civitas/forms/forms.cct` e `lib/civitas/forms/multipart.cct`.

Capacidades estabilizadas:

- `FormData` como tipo unico para formularios `urlencoded` e `multipart`;
- `UploadedFile` com `filename`, `content_type`, `data` e `size`;
- `FormParseConfig` com limites de arquivo, payload total e quantidade de campos;
- `form_parse_urlencoded(...)`, `form_parse_multipart(...)` e `form_parse(...)`;
- accessors `form_data_get`, `form_data_get_or`, `form_data_get_int`, `form_data_get_real`, `form_data_get_bool`;
- accessors `form_data_get_multi`, `form_data_get_file`, `form_data_has` e `form_data_has_file`.

Contratos operacionais:

- `multipart` exige `boundary` valido no `Content-Type`;
- uploads acima do limite retornam `FpeFileTooLarge`;
- payload total acima do limite retorna `FpeTotalSizeTooLarge`;
- `form_data_get_bool(...)` reconhece `on/1/true` e `off/0/false`;
- o parser multipart carrega arquivos integralmente em memoria nesta fase.

## Validacao declarativa

O contrato vive em `lib/civitas/validate/validate.cct`.

Capacidades estabilizadas:

- `ValidationRuleKind` com `required`, limites de tamanho, limites numericos, regex, email, URL e `choices`;
- `FieldSchema` com lista de regras e flag `sanitizar`;
- `CrossFieldRule` com operacoes `eq`, `neq`, `gt_int` e `lt_int`;
- `FormSchema` para agregacao de campos e regras cruzadas;
- `ValidationResult` com mapa de `FieldError` por nome de campo;
- helpers `validation_has_error`, `validation_get_errors` e `validation_first_error`.

Contratos operacionais:

- somente `required` falha em campo vazio;
- regras opcionais ignoram string vazia e validam apenas quando o campo foi preenchido;
- `validation_result_add_error(...)` agrega mensagens por campo, preservando o contrato de lista;
- o resultado exposto para render continua organizado por nome textual de campo, nao por identidade de string.

## Sanitizacao

O contrato vive em `lib/civitas/validate/sanitize.cct`.

Capacidades estabilizadas:

- `sanitize_trim(...)`;
- `sanitize_lower(...)` e `sanitize_upper(...)`;
- `sanitize_normalize_email(...)`;
- `sanitize_strip_tags(...)`;
- `sanitize_normalize_spaces(...)`.

Limites operacionais:

- `sanitize_strip_tags(...)` remove tags HTML simples por regex, sem parser de DOM;
- `FieldSchema.sanitizar` aplica apenas trim automatico antes da validacao;
- sanitizadores adicionais continuam explicitos no handler ou no schema construido pela aplicacao.

## Sanitizacao rica de conteudo

O contrato vive em `lib/civitas/sanitize/`.

Capacidades estabilizadas:

- `text.cct`: `normalize_newlines`, `normalize_unicode_spaces`, `collapse_spaces`, `normalize_paragraphs` e `normalize_whitespace`;
- `html.cct`: `HtmlAllowList`, `HtmlSanitizeConfig`, `allowlist_none`, `allowlist_minimal`, `allowlist_rich`, `html_sanitize(...)` e validacao de atributos URL por scheme;
- `url.cct`: `EmbedPolicy`, `embed_policy_default`, `embed_policy_add_host`, `embed_check` e verificacao por hostname exato;
- `contact.cct`: `EmailSanitizeConfig`, `email_sanitize(...)`, `email_sanitize_normalized(...)`, `PhoneConfig` e `phone_normalize(...)`.

Contratos operacionais:

- tags nao permitidas sao removidas e o texto interno e preservado;
- atributos `on*` sao sempre descartados, mesmo quando a tag e aceita;
- `allowlist_minimal` permite marcacao editorial basica e `a[href]` com `http/https/mailto`;
- `allowlist_rich` adiciona `data-*`, `aria-*` e `img[src, alt, width, height]` restrito a `https`;
- `embed_check(...)` compara hostname por igualdade textual, nunca por `contains`;
- `email_sanitize(...)` pode rejeitar dominios descartaveis e `phone_normalize(...)` entrega E.164 e display para `BR`.

## Render HTML de formularios

O contrato vive em `lib/civitas/forms/render.cct`.

Capacidades estabilizadas:

- `InputKind`, `SelectOption`, `FieldDef` e `FormDef`;
- `field_def_new(...)`, `field_def_add_option(...)`, `form_def_new(...)` e `form_def_add_field(...)`;
- `field_def_add_attr(...)`, `field_def_add_wrapper_attr(...)`, `form_def_add_attr(...)` e variantes `*_add_data(...)`;
- `field_def_free(...)` e `form_def_free(...)`;
- `render_field(...)` com variantes para text, password, email, number, textarea, select, checkbox, radio e hidden;
- `render_form(...)` com `action`, `method`, `enctype`, botao submit e hidden CSRF automatico;
- `render_form_errors_summary(...)` para acessibilidade e navegacao para `#campo`.

Contratos operacionais:

- refill automatico usa `FormData`;
- campos password nunca recebem `value` de volta;
- textarea reprime o valor no corpo do elemento;
- select marca `selected="selected"` na opcao atual;
- checkbox renderiza fallback hidden `"0"` mais checkbox `"1"`;
- radio groups usam `fieldset` com `legend` e wrappers `radio-option`;
- wrappers usam `form-group`, `field-error`, `form-group-checkbox` e `error-message`.
- atributos reservados do core (`type`, `name`, `id`, `value`, `checked`, `selected`, `required`, `aria-invalid`, `rows`, `action`, `method`, `enctype`) nao podem ser sobrescritos por atributos extras;
- `class` faz merge: a classe do core entra primeiro e a classe extra e concatenada depois;
- atributos inline `on*` sao bloqueados no escape hatch mesmo quando fornecidos pelo usuario.

## Contrato de memoria do builder HTML

O contrato vive em `lib/civitas/html.cct`.

Capacidades estabilizadas:

- `html_child(...)` e `html_append_child(...)` realizam flattening progressivo do filho no buffer do pai;
- `html_render(...)` serializa sem liberar;
- `html_render_free(...)` serializa e libera a estrutura raiz;
- `html_free(...)` libera attrs, children e o proprio no.

Contratos operacionais:

- o caminho canonico de `render_form(...)` termina em `html_render_free(...)`, sem reter arvore intermediaria apos gerar o `VERBUM` final;
- filhos adicionados ao pai nao formam DOM persistente; o contrato e de composicao e descarte progressivo;
- quem aloca `FieldDef.extra_attrs`, `FieldDef.wrapper_attrs` ou `FormDef.extra_attrs` via helpers deve liberar com `field_def_free(...)` ou `form_def_free(...)`.

## Cobertura de testes

Cobertura da FASE 7:

- `7A`: 6 testes
- `7B`: 6 testes
- `7C`: 5 testes
- `7D`: 8 testes
- `7E`: 8 testes

Total da FASE 7: 33 testes de integracao.
