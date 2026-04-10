# Manual Aprofundado do Sistema — FASE 9

## Visao geral

A FASE 9 fecha o primeiro pipeline completo de midia do Civitas: entrada via upload, organizacao em storage por zonas, processamento de imagem e video, serving de assets estaticos e delivery autenticado de artefatos privados.

O bloco `9A-9F` entrega:

- upload multipart buffered e streaming sobre o mesmo contrato de `MultipartResult`;
- extensao de `WebRequest` para corpo bruto opaco quando o servidor entra em streaming;
- static files com hash de conteudo no nome, ETag, `304` e helper `{% NEXUS %}`;
- storage local por zonas `tmp`, `quarantine`, `processed`, `public` e `private`;
- URLs assinadas com candidatos de segredo do keyring;
- pipeline de imagem com validacao, strip de EXIF, derivados e moderacao;
- pipeline de video com probe, thumb, transcode, estados de processamento e moderacao;
- media delivery privado com `206 Partial Content`, `X-Accel-Redirect` e `X-Sendfile`.

## Upload streaming

O contrato vive em `lib/civitas/upload/` e na extensao de `WebRequest` em `lib/civitas/request_core.cct` e `lib/civitas/request.cct`.

Capacidades estabilizadas:

- `corpo_bruto` e `corpo_bruto_ativo` no request;
- parse buffered para corpo ja em memoria;
- parse streaming para multipart lido direto do socket;
- validacao de `boundary`, limites de tamanho e tipos permitidos;
- `UploadedFile` com nome original, nome salvo, path final, mime real e `FileType`.

Contratos operacionais:

- o handler de upload nao precisa saber se o request veio buffered ou streaming;
- o storage de arquivo sempre acontece em disco, nunca como `VERBUM` gigante em memoria;
- validacao de MIME declarado pelo cliente nao e suficiente; o tipo real e decidido por magic bytes;
- `upload_delete(...)` e o caminho oficial para limpeza do arquivo salvo por upload.

## Static files

O contrato vive em `lib/civitas/static/` e na integracao de templates em `lib/civitas/template/integration.cct`.

Capacidades estabilizadas:

- indice de arquivos estaticos construido a partir da raiz configurada;
- URL com hash curto de conteudo em producao;
- serving com `ETag`, `Last-Modified` e `304 Not Modified`;
- helper `{% NEXUS %}` para templates compilados.

Contratos operacionais:

- producao favorece cache forte e URLs imutaveis;
- desenvolvimento continua tolerando alteracoes do disco sem rebuild do indice;
- o browser passa a invalidar cache por mudanca de URL, nao por heuristica externa;
- o indice e a resposta de serving usam lookup textual estavel.

## Storage e URLs assinadas

O contrato vive em `lib/civitas/storage/storage.cct`, `storage_url.cct` e `storage_gc.cct`.

Capacidades estabilizadas:

- abertura do `MediaStore` a partir de settings da aplicacao;
- ingestao em `tmp`, promocao atomica entre zonas e delecao explicita;
- URL publica direta para artefato publico;
- URL privada assinada com HMAC e expira em timestamp Unix;
- verificacao com segredo ativo e candidatos legados;
- GC de tmp com callback opaco de referencia.

Contratos operacionais:

- a aplicacao trabalha sobre zonas e artefatos, nao sobre paths absolutos hardcoded;
- `storage_put_tmp(...)` e o ponto de entrada canonico para arquivos externos;
- links privados dependem do keyring e nao carregam path fisico em si;
- o GC de tmp deve rodar fora do request path para nao impactar latencia.

## Pipeline de imagem

O contrato vive em `lib/civitas/media_image/`.

Capacidades estabilizadas:

- validacao por filetype real e decode efetivo da imagem;
- protecao contra arquivo grande demais, corrupcao e dimensoes absurdas;
- derivados predefinidos `avatar`, `thumb` e `medium`;
- strip de EXIF opcional;
- moderacao com estados `pending`, `approved`, `rejected` e `unsafe`.

Contratos operacionais:

- `image_process(...)` produz derivados e promove o original para a zona final configurada;
- o `ImageRecord` nasce inativo;
- `image_approve(...)` e o momento explicito em que o arquivo se torna ativo;
- delecao na fase continua sendo logica, nao remocao fisica imediata de todos os artefatos.

## Pipeline de video

O contrato vive em `lib/civitas/media_video/`.

Capacidades estabilizadas:

- verificacao de dependencias externas (`ffprobe`, `ffmpeg`);
- probe detalhado de formato, codecs, duracao, dimensoes e fps;
- ingestao com `VideoRecord` em `VpsPending`;
- extracao de thumb;
- transcode multi-spec com timeout e watermark opcional;
- estados de processamento e moderacao separados.

Contratos operacionais:

- o request de upload de video nao executa transcode inline;
- `video_process_task(...)` concentra o trabalho pesado e atualiza o estado do record;
- o frontend deve confiar em `process_state`, nao inferir estado pela existencia de arquivos;
- `video_mark_unsafe(...)` desativa imediatamente o record.

## Media delivery privado

O contrato vive em `lib/civitas/media_delivery/`.

Capacidades estabilizadas:

- verificacao de token assinado com expiração;
- resolucao de `artifact_id` por query ou path param;
- parsing de `Range` com respostas `206` e `416`;
- serving direto para desenvolvimento e modos delegados para proxy.

Contratos operacionais:

- `DmDirect` carrega o slice solicitado e escreve corpo diretamente na response;
- `DmAccelRedirect` e `DmSendfile` fazem o Civitas autenticar e delegar o serving ao servidor HTTP;
- `403` nao mascara expiracao nem token invalido como `404`;
- requests completos e parciais sempre recebem `Cache-Control: private, no-store`.

## Cobertura de testes

Cobertura da FASE 9:

- `9A`: 6 testes
- `9B`: 5 testes
- `9C`: 6 testes
- `9D`: 7 testes
- `9E`: 8 testes
- `9F`: 8 testes

Total da FASE 9: 40 testes de integracao.
