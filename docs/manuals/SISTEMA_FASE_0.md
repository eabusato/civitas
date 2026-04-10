# Manual Aprofundado do Sistema — FASE 0

## Visão geral

O Civitas nasce nesta fase como um framework web em CCT com bootstrap operacional mínimo e verificável.

O sistema implementado entrega:

- repositório organizado por responsabilidade;
- manifesto do projeto em `cct.toml`;
- fluxo oficial via `Makefile`;
- baseline compilável em `src/main.cct`;
- exemplo HTTP canônico em `examples/salve_civitas/`;
- suíte de integração centralizada em `tests/run_tests.sh`.

## Estrutura física

### `src/`

Contém o entrypoint do projeto raiz. Na fase 0 ele funciona como smoke binary do bootstrap, validando que os módulos-base do framework estão acessíveis e coerentes.

### `lib/civitas/core/`

Concentra o contrato mínimo de identidade do framework:

- nome;
- versão;
- piso de CCT declarado;
- baseline funcional registrada para o ambiente atual.

### `lib/civitas/http/`

Contém a primeira casca HTTP do Civitas sobre `cct/http`, com:

- host padrão `0.0.0.0`;
- porta padrão `8080`;
- helper para resposta `text/plain; charset=utf-8`;
- cabeçalho `X-Civitas-Version`.

### `lib/civitas/web/`

Reserva o namespace da camada web e fixa o banner e o smoke contract do bootstrap.

### `examples/salve_civitas/`

Abriga o primeiro servidor real do projeto. O processo:

1. resolve host, porta e controles operacionais por ambiente;
2. abre listener HTTP;
3. aceita conexões sequenciais;
4. responde `200 OK` com corpo `Salve, Civitas`.

Se o processo for executado com `CIVITAS_READY_FILE` e `CIVITAS_DONE_FILE` definidos em um host que não permite `bind`, o exemplo marca `skip` nesses arquivos. Esse contrato existe para manter a suíte de integração fiel ao comportamento real do runtime sem inventar um falso servidor em ambientes restritos.

## Contrato operacional

### Build

`make build` compila o projeto raiz e gera `dist/civitas`.

Por padrão, o fluxo usa `cct-host` quando `CCT_BIN` não está definido. O binário também pode ser resolvido por `PATH` ou explicitamente por `CCT_BIN`.

### Exemplo

`make examples` compila `examples/salve_civitas` e gera `examples/salve_civitas/dist/salve_civitas`.

### Testes

`make test` delega para `tests/run_tests.sh`, que organiza o bloco 0A-0E por subfase, com filtros e mensagens de regressão.

### Limpeza

`make clean` remove:

- `dist/`
- `examples/salve_civitas/dist/`
- caches `.cct/`
- `tests/tmp/`

## Compatibilidade com CCT

O manifesto declara `cct_min_version = "0.40.0"`, acompanhando o identificador que o compilador local agora reporta em `--version`.

A baseline funcional registrada continua sendo a fase 40 do CCT, agora sem descompasso entre semver reportada e superfície operacional do ambiente.
