# Spec Consolidada — FASE 9

## Escopo implementado

Esta spec consolida o comportamento entregue no bloco `9A-9F`.

## `civitas/upload`

`lib/civitas/upload/` estabiliza o upload multipart do Civitas com dois caminhos de leitura.

Contrato implementado:

- `UploadConfig`, `UploadedFile`, `UploadField`, `MultipartResult` e `UploadError`;
- `upload_parse(...)` como ponto de entrada unico;
- `upload_parse_buffer(...)` para requests ja materializados em `req.body`;
- `upload_parse_stream(...)` para requests com `req.corpo_bruto`;
- `upload_config_new(...)`, `upload_config_allow_type(...)`, `upload_get_file(...)`, `upload_get_field(...)` e `upload_delete(...)`;
- validacao de tipo real via `cct/filetype`;
- nome salvo opaco com extensao canonica.

Contratos operacionais:

- `WebRequest` passa a expor `corpo_bruto` e `corpo_bruto_ativo`;
- requests pequenos continuam buffered, requests acima do limiar entram no caminho streaming;
- limite de campo e de request sao verificados durante o parse;
- o nome original e preservado apenas como metadado, nunca como path salvo;
- magic bytes prevalecem sobre `Content-Type` declarado pelo browser.

## `civitas/static`

`lib/civitas/static/` estabiliza serving e resolucao de assets estaticos.

Contrato implementado:

- `StaticMode`, `StaticConfig`, `StaticFile`, `StaticIndex`, `StaticResult` e `StaticServeResult`;
- `static_config_new(...)`, `static_index_build(...)`, `static_url(...)`, `static_find_by_name(...)`, `static_find_by_url(...)` e `static_serve(...)`;
- ETag e `304 Not Modified`;
- nome com hash curto de conteudo em modo producao;
- fallback de desenvolvimento sem hash no nome;
- integracao com templates via `{% NEXUS %}` e `tpl_static_url(...)`.

Contratos operacionais:

- `SmDesenvolvimento` serve do disco e tolera alteracoes sem rebuild do indice;
- `SmProducao` usa o indice preconstruido e URLs com hash;
- o lookup de assets e textual, nao por identidade interna de `VERBUM`;
- `static_serve(...)` emite `Content-Type`, `ETag`, `Last-Modified` e `Cache-Control` conforme o modo;
- `static_caminho_seguro(...)` impede traversal fora da raiz.

## `civitas/storage`

`lib/civitas/storage/` estabiliza a orquestracao de midia sobre `cct/media_store`.

Contrato implementado:

- `StorageConfig`, `StorageGcReport`, `SignedUrlConfig` e `SignedUrl`;
- `storage_config_from_storage_settings(...)` e `storage_config_from_settings(...)`;
- `storage_open(...)`, `storage_put_tmp(...)`, `storage_promote(...)`, `storage_copy(...)`, `storage_delete(...)`, `storage_exists(...)`, `storage_absolute_path(...)` e `storage_url_for_artifact(...)`;
- `storage_sign_url(...)`, `storage_sign_url_default(...)`, `storage_sign_url_from_registry(...)`, `storage_verify_signed_url(...)` e `storage_verify_signed_url_candidates(...)`;
- `storage_gc_tmp(...)` com callback opaco de verificacao de referencia.

Contratos operacionais:

- o backend atual e local via `MediaStore`;
- o path absoluto nunca e a URL publica; o caller deve usar `storage_url_for_artifact(...)` ou `storage_sign_url(...)`;
- `storage_put_tmp(...)` remove o source original apos ingestao bem-sucedida;
- URLs privadas usam segredo ativo e tambem aceitam grace window via `storage_verify_signed_url_candidates(...)`;
- o GC de tmp nao apaga arquivos dentro da janela configurada de idade.

## `civitas/media_image`

`lib/civitas/media_image/` estabiliza o pipeline de imagem do Civitas.

Contrato implementado:

- `ImageModerationState`, `ImageValidateError`, `ImageRecord`, `ImageDerivativeSpec`, `ImageDerivative` e `ImageProcessConfig`;
- `image_validate(...)`, `image_process(...)`, `image_approve(...)`, `image_reject(...)`, `image_mark_unsafe(...)` e `image_soft_delete(...)`;
- specs canonicias `image_spec_avatar(...)`, `image_spec_thumb(...)` e `image_spec_medium(...)`;
- derivacao via `image_derive_all(...)`;
- strip de EXIF opcional via `image_strip_exif(...)`.

Contratos operacionais:

- apenas imagens reais passam pelo pipeline;
- imagens corrompidas ou com dimensoes absurdas sao rejeitadas;
- `image_process(...)` gera derivados antes de registrar/promover o original;
- o original e promovido para a zona configurada em `auto_promote_zone`;
- o record nasce inativo com `ImsPending` e depende de moderacao explicita para ficar publico.

## `civitas/media_video`

`lib/civitas/media_video/` estabiliza o pipeline de video do Civitas.

Contrato implementado:

- `VideoProcessState`, `VideoModerationState`, `VideoRecord`, `VideoProbe`, `TranscodeSpec` e `VideoProcessConfig`;
- `video_check_deps(...)`, `video_probe(...)`, `video_validate(...)`, `video_ingest(...)`, `video_process_task(...)`;
- specs canonicias `video_spec_sd(...)` e `video_spec_hd(...)`;
- `video_extract_thumb(...)` e `video_transcode_all(...)`;
- transicoes `video_approve(...)`, `video_reject(...)`, `video_mark_unsafe(...)` e `video_soft_delete(...)`.

Contratos operacionais:

- a ingestao e sincrona so ate validacao/probe e registro do original;
- thumb e transcode ficam no caminho de processamento posterior;
- `VideoRecord.process_state` e a fonte de verdade do pipeline;
- a deteccao inicial do filetype combina `file --mime-type` com fallback por header;
- o transcode respeita timeout configurado e watermark opcional.

## `civitas/media_delivery`

`lib/civitas/media_delivery/` estabiliza o serving autenticado de artefatos privados.

Contrato implementado:

- `DeliveryMode`, `DeliveryError`, `DeliveryConfig` e `RangeRequest`;
- `delivery_check_signed_url(...)`, `delivery_parse_range(...)`, `delivery_serve_direct(...)` e `delivery_handler(...)`;
- suporte a `DmDirect`, `DmAccelRedirect` e `DmSendfile`;
- headers auxiliares via `delivery_range_headers(...)`, `delivery_apply_headers(...)`, `delivery_serve_accel(...)` e `delivery_serve_sendfile(...)`.

Contratos operacionais:

- `delivery_handler(...)` extrai `artifact_id` de query ou `path_param`;
- `403` diferencia token expirado/invalido; `404` cobre artefato ausente;
- `DmDirect` suporta `Range: bytes=START-END` e `START-`;
- `416` inclui `Content-Range: bytes */TOTAL`;
- `Cache-Control: private, no-store` e `Accept-Ranges: bytes` sao sempre emitidos no delivery privado.

## Cobertura de testes

A FASE 9 adiciona 40 testes de integracao:

- 6 em `9A`
- 5 em `9B`
- 6 em `9C`
- 7 em `9D`
- 8 em `9E`
- 8 em `9F`
