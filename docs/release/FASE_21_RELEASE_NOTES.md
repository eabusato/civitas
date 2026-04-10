# FASE 21 Release Notes

## Resumo

A FASE 21 fecha a camada de visualização operacional dos traces do Civitas. O framework passa a transformar os dados capturados na FASE 20 em artefatos úteis para diagnóstico local e documentação offline.

## Entregas

- `trace_render`: renderer SVG animado de traces;
- `trace_panel`: painel local em `/civitas/traces`;
- `trace_export`: pacote ZIP offline por endpoint observado.

## Valor entregue

- leitura visual imediata do fluxo de execução;
- consulta local sem depender de serviços externos;
- replay de requests observados;
- pacote compartilhável com documentação viva dos endpoints observados.

## Cobertura

A fase foi validada com testes de integração para:

- defaults do renderer;
- SVG básico;
- animação e step-by-step;
- renderização em arquivo;
- comparação lado a lado;
- listagem do painel;
- detalhe com SVG embutido;
- rota de SVG puro;
- replay;
- escrita do ZIP;
- conteúdo do ZIP.

## Limites

- a exportação cobre endpoints observados, não todo o espaço teórico de rotas;
- replay é best-effort;
- não há tracing distribuído entre serviços nesta fase.

## Fechamento

A FASE 21 conclui a transição entre coleta de traces e operação visual local, preparando o terreno para uma experiência de desenvolvimento mais iterativa nas fases seguintes.

