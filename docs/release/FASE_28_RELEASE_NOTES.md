# FASE 28 Release Notes

## Bloco entregue

Este fechamento cobre o bloco `28A-28D` da FASE 28 e encerra o Civitas 1.0.

## Entrou

- auditoria estrutural local de segurança para headers, rotas mutáveis e static traversal;
- fuzzing HTTP determinístico sobre o parser real do CCT;
- carga in-process com percentis e comparação de regressão;
- watch de memória baseado no `memory_profiler`;
- inventário local de dependências com base offline de CVEs;
- bundle final de documentação, changelog e release notes versionadas.

## Impacto prático

Um projeto Civitas agora consegue:

- auditar sua superfície mais crítica sem sair do próprio framework;
- medir regressão de latência e falha em rotas reais via `Router` + `TestClient`;
- inspecionar tendência de leak com contratos simples de deltas de memória;
- revisar dependências relevantes mesmo em ambiente sem acesso externo;
- publicar uma base mínima de documentação e release para onboarding e operação.

## Compatibilidade

- o bloco cresce sobre os módulos existentes de segurança, benchmark, profiler e CLI;
- não houve mudança de contrato que quebre fases anteriores;
- a linha funcional documentada da release 1.0 termina na FASE 28;
- fases `29-31` deixam de ser parte do roadmap executável desta linha.

## Validação

- `fase28_28a_` verde
- `fase28_28b_` verde
- `fase28_28c_` verde
- `fase28_28d_` verde
- `tests/run_tests.sh 28A 28B 28C 28D` verde
- `tests/run_tests.sh` verde
