# FASE 9 Release Notes

## Entregas

- `lib/civitas/upload/` com upload multipart buffered/streaming, validacao por magic bytes e naming canonico;
- extensao de `WebRequest` com `corpo_bruto` e `corpo_bruto_ativo` para upload streaming;
- `lib/civitas/static/` com indice de assets, hash de conteudo, ETag, `304` e helper `{% NEXUS %}`;
- `lib/civitas/storage/` com abertura do `MediaStore`, URLs assinadas, verificacao por candidatos de segredo e GC de tmp;
- `lib/civitas/media_image/` com validacao, derivados, strip de EXIF e estados de moderacao;
- `lib/civitas/media_video/` com probe via `ffprobe`, transcode via `ffmpeg`, thumb e estados de processamento/moderacao;
- `lib/civitas/media_delivery/` com delivery privado autenticado, `206 Partial Content`, `X-Accel-Redirect` e `X-Sendfile`;
- expansao do runner unico para cobrir `9A-9F`.

## Decisoes relevantes

- o contrato externo de upload e unico; a escolha buffered/streaming e interna ao request e ao parser;
- assets estaticos passam a usar URL com hash curto em producao para invalidacao de cache por conteudo;
- o storage segue apoiado em `cct/media_store`, sem reimplementar primitives de filesystem no Civitas;
- links privados usam segredo ativo e grace window do keyring via verificacao por candidatos;
- imagem e video permanecem com moderacao explicita e soft delete;
- media delivery privilegia compatibilidade com players de video por suporte a `Range`.

## Cobertura de testes

A FASE 9 adiciona:

- 6 testes em `9A`
- 5 testes em `9B`
- 6 testes em `9C`
- 7 testes em `9D`
- 8 testes em `9E`
- 8 testes em `9F`

Total da FASE 9: 40 testes de integracao.

## Estado do gate

O bloco `9A-9F`, fechando a FASE 9, so e considerado concluido com:

- `9A` verde isoladamente;
- `9B` verde isoladamente;
- `9C` verde isoladamente;
- `9D` verde isoladamente;
- `9E` verde isoladamente;
- `9F` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
