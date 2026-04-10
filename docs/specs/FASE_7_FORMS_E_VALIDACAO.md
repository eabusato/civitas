# Spec Consolidada — FASE 7

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `7A-7E`.

## `civitas/forms` parse

`lib/civitas/forms/forms.cct` e `lib/civitas/forms/multipart.cct` estabilizam o parse de formulario no Civitas.

Contrato implementado:

- `FormData` unifica campos de texto, campos multi-value e arquivos enviados;
- `form_parse_urlencoded(...)` delega a `cct/form_codec`;
- `form_parse_multipart(...)` resolve `boundary`, separa partes, extrai `Content-Disposition` e popula `UploadedFile` quando `filename` esta presente;
- `form_parse(...)` escolhe o parser por `Content-Type`;
- `FormParseConfig` protege o runtime com limites de tamanho e contagem;
- accessors tipados retornam `Option` compativel com o restante do framework.

Contratos de parsing:

- `FpeMissingBoundary`, `FpeMalformedBoundary`, `FpeFileTooLarge`, `FpeTotalSizeTooLarge`, `FpeInvalidEncoding` e `FpeUnsupportedContentType` ficam expostos como diagnostico canonico;
- `multipart` finaliza partes no proximo `--boundary` ou `--boundary--`;
- `FormData` preserva o primeiro valor bruto e tambem a visao multi-value para campos repetidos;
- arquivos ficam em memoria como `VERBUM` nesta fase, sem streaming.

## `civitas/validate`

`lib/civitas/validate/validate.cct` estabiliza a validacao declarativa.

Contrato implementado:

- regras canonicas `required`, `min_len`, `max_len`, `min_val`, `max_val`, `regex`, `email`, `url` e `choices`;
- mensagens default estaveis e mensagem customizada via `rule_required_msg(...)`;
- `FieldSchema` com `sanitizar` default em `VERUM`;
- `validate_field(...)` retorna `FLUXUS VERBUM` por campo;
- `validate_form(...)` agrega tudo em `ValidationResult`;
- regras cruzadas suportam `eq`, `neq`, `gt_int` e `lt_int`.

Contratos de validacao:

- apenas `VrkRequired` avalia string vazia;
- demais regras ignoram campo em branco;
- `choices` faz comparacao textual contra `FLUXUS VERBUM`;
- `ValidationResult.errors` expõe `MAPPA(VERBUM, FieldError)` com lista de mensagens por campo;
- lookup de erro e agregacao usam chave textual estavel, nao identidade de ponteiro.

## Sanitizacao

`lib/civitas/validate/sanitize.cct` estabiliza sanitizadores reutilizaveis.

Contrato implementado:

- trim simples;
- lower/upper;
- normalizacao de email com trim + lowercase;
- strip de tags HTML por regex;
- normalizacao de espacos em branco para um unico espaco.

## `civitas/sanitize`

`lib/civitas/sanitize/` estabiliza a sanitizacao rica de conteudo externo.

Contrato implementado:

- `text.cct` normaliza CRLF/CR para LF, whitespace Unicode nao-ASCII, espacos repetidos e blocos de paragrafo;
- `html.cct` oferece `allowlist_none`, `allowlist_minimal`, `allowlist_rich`, `HtmlSanitizeConfig` e `html_sanitize(...)`;
- `url.cct` oferece `EmbedPolicy` com hosts exatos permitidos e `embed_check(...)`;
- `contact.cct` oferece normalizacao/validacao de email com dominio descartavel e normalizacao de telefone por pais.

Contratos de sanitizacao rica:

- tags nao listadas sao removidas enquanto o texto interno e preservado;
- atributos `on*` e URLs com `javascript:`, `vbscript:` ou `data:` sao removidos;
- `allowlist_rich` aceita `data-*` e `aria-*`, mas restringe `img[src]` a `https`;
- host de embed e comparado por igualdade textual de hostname, sem `contains`;
- `email_sanitize(...)` separa formato invalido, dominio invalido e dominio descartavel;
- `phone_normalize(...)` entrega `PhoneNormalized` com `result`, `e164` e `display`.

## Render de formularios

`lib/civitas/forms/render.cct` estabiliza a camada de apresentacao do formulario.

Contrato implementado:

- `FieldDef` e `FormDef` como definicao canonica de render;
- `extra_attrs` e `wrapper_attrs` em `FieldDef`, mais `extra_attrs` em `FormDef`;
- helpers `field_def_add_attr`, `field_def_add_wrapper_attr`, `form_def_add_attr` e variantes `*_add_data`;
- helpers de liberacao `field_def_free(...)` e `form_def_free(...)`;
- render de `input`, `textarea`, `select`, `checkbox`, `radio` e `hidden`;
- sumario de erros com links `#campo`;
- injecao automatica do hidden CSRF usando `csrf_config_default().field_name`;
- uso do builder `civitas/html` para escaping de attrs e texto.

Contratos de render:

- refill automatico ocorre para text, email, number, textarea, select, checkbox e radio;
- password nunca reusa o valor submetido;
- wrappers usam `form-group` e recebem `field-error` quando o campo tem erro;
- mensagens inline usam `span.error-message`;
- checkbox sempre emite hidden fallback com mesmo nome e valor `0`.
- atributos reservados do core nao sao sobrescritos por atributos extras;
- `class` faz merge com a classe estrutural do renderer;
- atributos inline `on*` sao descartados pelo renderer;
- wrappers e `<form>` aceitam atributos extras proprios, separados do elemento principal do campo.

## Contrato de memoria de `civitas/html`

`lib/civitas/html.cct` passa a ter contrato explicito para o caminho de renderizacao usado por formularios.

Contrato implementado:

- `html_child(...)`/`html_append_child(...)` serializam o filho e liberam sua estrutura intermediaria;
- `html_render_free(...)` serializa e chama `html_free(...)` na raiz;
- o builder nao funciona como DOM persistente; funciona como arvore transitória com flattening progressivo.

## Cobertura de testes

A FASE 7 adiciona 33 testes de integracao:

- 6 em `7A`
- 6 em `7B`
- 5 em `7C`
- 8 em `7D`
- 8 em `7E`
