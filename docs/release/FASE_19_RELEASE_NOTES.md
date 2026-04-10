# FASE 19 Release Notes

## Entregas

- `lib/civitas/api/` com serializers, validacao, envelopes, paginação offset/cursor e negotiation JSON/CSV;
- `lib/civitas/api_views/` com CRUD generico, filtros, ordenacao, auth bearer e versionamento;
- `lib/civitas/openapi/` com derivacao de `OpenAPI 3.1`, cache SQLite e handler de schema;
- `lib/civitas/seo/` com `robots.txt`, `sitemap.xml`, feeds, canonical, hreflang, redirects e paginas estaticas;
- `lib/civitas/embed/` com embed HTML, `oEmbed`, export JSON e export CSV autenticado;
- suporte compartilhado de testes em `tests/integration/fase_19/`;
- expansao do runner unico para cobrir `19A-19E`.

## Decisoes relevantes

- o contrato da API ficou centrado em serializer registry e viewset registry, nao em inferencia de schema por reflexao;
- a spec OpenAPI e derivada do estado real do framework e cacheada em SQLite por TTL curto;
- a publicacao publica foi mantida em torno de dados reais (`civitas_pages`, redirects, static pages), sem criar uma pilha de publicacao paralela;
- embeds e exportacoes usam configuracao explicita por modelo, evitando acesso generico irrestrito ao banco;
- autenticacao de export foi separada em dois trilhos: bearer para API e basic auth simples para admin-lite/export operacional.

## Cobertura de testes

A FASE 19 adiciona:

- 5 testes em `19A`
- 5 testes em `19B`
- 5 testes em `19C`
- 5 testes em `19D`
- 5 testes em `19E`

Total da FASE 19: 25 testes de integracao.

## Estado do gate

O bloco `19A-19E`, fechando a FASE 19, so e considerado concluido com:

- `19A` verde isoladamente;
- `19B` verde isoladamente;
- `19C` verde isoladamente;
- `19D` verde isoladamente;
- `19E` verde isoladamente;
- `tests/run_tests.sh` completo verde sem regressao historica;
- documentacao consolidada sincronizada com o comportamento realmente entregue.
