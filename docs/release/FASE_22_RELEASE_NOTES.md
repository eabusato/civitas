# FASE 22 Release Notes

## Resumo

A FASE 22 entrega a primeira camada completa de DX iterativa do Civitas:

- rebuild local por watch de `.cct`;
- pagina de erro de compilacao no browser;
- toolbar HTML com diagnostico do request;
- livereload baseado em geracao.

## O que entrou

- `lib/civitas/dev_server/dev_server.cct`
- `lib/civitas/debug_toolbar/debug_toolbar.cct`
- `lib/civitas/dev_livereload/dev_livereload.cct`

## O que ficou importante nesta fase

O contrato visual do sigilo foi preservado explicitamente:

- a toolbar da 22 usa o renderer real do CCT;
- o painel embute o SVG animado completo;
- a fase nao rebaixa o trace para uma timeline simplificada.

## Ajuste de contrato em relacao a rascunhos

Alguns rascunhos da fase assumiam um registro de rota com callback capturando configuracao. O CCT publico atual nao expõe esse construtor de callback. A implementacao final fechou a parte funcional da fase com handlers reutilizaveis e injecao/aplicacao desacopladas, deixando o wiring de router como integracao explicita da aplicacao.

## Cobertura

Foram adicionados 15 testes de integracao reais:

- 5 para `22A`
- 5 para `22B`
- 5 para `22C`

## Resultado

A FASE 22 fecha o caminho:

`editar -> salvar -> rebuild -> novo gen -> reload automatico -> diagnostico com sigilo real`

sem trocar o renderer do CCT por representacoes simplificadas.
