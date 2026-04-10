# FASE 23 Release Notes

## Entregue

- CLI de scaffolding com templates `minimal`, `web` e `api`
- estilos de scaffold `starter`, `layered` e `domain`
- geradores para model, migration, API e admin
- generators agora podem escrever em apps nomeadas alem de `apps/core`
- management commands para migration, rollback, seed, shell, test, collect static e superuser
- loader compartilhado de `civitas.toml`
- `doctor` com diagnostico tipado de projeto

## Ajustes estruturais

- `apps/core/urls.cct` virou o ponto canonico de agregacao de rotas dos projetos scaffoldados
- `project/main.cct` e `project/urls.cct` passaram a separar bootstrap raiz da arvore de apps do usuario
- `data/` e `.civitas/` passaram a delimitar artefatos de runtime e cache fora do codigo versionado
- o scaffold passou a acomodar tres propostas de crescimento profissional sem quebrar o layout existente: `starter`, `layered` e `domain`
- migrations geradas passaram a incluir `-- UP` e `-- DOWN`, permitindo rollback util
- `civitas_management` deixou de carregar configuracao propria e passou a consumir `civitas_config`

## Cobertura

Foram adicionados 20 testes de integracao:

- `23A`: 5
- `23B`: 5
- `23C`: 5
- `23D`: 5

## Impacto

A FASE 23 fecha o primeiro ciclo de DX do framework. A partir daqui, um projeto pode nascer, ganhar codigo inicial, executar migrations e ser diagnosticado por tooling nativo do proprio Civitas.
