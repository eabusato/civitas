# FASE 7 Release Notes

## Entregas

- `lib/civitas/forms/forms.cct` e `multipart.cct` com parse `urlencoded` e `multipart`, `FormData`, `UploadedFile` e limites de upload;
- `lib/civitas/validate/validate.cct` e `sanitize.cct` com validacao declarativa, regras cruzadas e sanitizadores canônicos;
- `lib/civitas/sanitize/` com sanitizacao HTML por allowlist, normalizacao textual, politica de embed e validacao rica de email/telefone;
- `lib/civitas/forms/render.cct` com `FieldDef`, `FormDef`, render de campos, sumario de erros, hidden CSRF automatico e atributos extras controlados;
- `lib/civitas/html.cct` com contrato formal de `html_child`, `html_append_child`, `html_render_free` e `html_free`;
- expansao do runner unico para cobrir `7A-7E`.

## Decisoes relevantes

- `FormData` e o tipo unificado de entrada para qualquer formulario aceito pelo framework;
- validacao continua separada do parse, com `ValidationResult` pronto para uso em resposta HTML;
- render usa o builder `civitas/html`, mantendo escaping seguro em attrs e texto;
- campos password nao sao reexibidos;
- campos opcionais so sao validados quando preenchidos;
- sanitizacao rica fica separada de `civitas/validate`, compondo com o schema em vez de substitui-lo;
- o escape hatch de atributos extras existe, mas nao pode sobrescrever attrs reservados do core nem injetar `on*`.

## Cobertura de testes

A FASE 7 adiciona:

- 6 testes em `7A`
- 6 testes em `7B`
- 5 testes em `7C`
- 8 testes em `7D`
- 8 testes em `7E`

Total da FASE 7: 33 testes de integracao.

## Estado do gate

O bloco `7A-7E`, fechando a FASE 7, so e considerado concluido com:

- `7A` verde isoladamente;
- `7B` verde isoladamente;
- `7C` verde isoladamente;
- `7D` verde isoladamente;
- `7E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
