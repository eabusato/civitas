# FASE 25 Release Notes

## Entregue

- `civitas/sse` com eventos SSE, writer, keepalive, relay SQLite e bridge de signals
- `civitas/websocket` com upgrade RFC 6455, frames, `WsConn` e relay de canal
- `civitas/sse_presence` com presença leve e inbox não lida
- `civitas/ws_room` com membros ativos, mute, ban e event log persistido
- scaffold canônico de projeto com `project/`, `apps/core`, `settings/`, `data/` e `.civitas/`

## Ajustes estruturais

- o roteador passa a conhecer `ROUTE_TRANSPORT_SSE` e `ROUTE_TRANSPORT_WS`
- a fase reforça o contrato de módulos realtime sem forçar o servidor HTTP padrão a virar runtime async
- inbox SSE e room state WS passaram a garantir `schema_up` implícito
- listagens de inbox e event log passam a ordenar de forma determinística por timestamp e `id`

## Cobertura

Foram adicionados 26 testes de integração:

- `25A`: 5
- `25B`: 6
- `25C`: 5
- `25D`: 5
- `25E`: 5

## Impacto

A FASE 25 fecha a primeira camada realtime nativa do Civitas. O framework passa a ter primitives formais para SSE e WebSocket, mais os módulos de presença e sala que crescem sobre SQLite e o roteador existente, preservando o restante do runtime síncrono do projeto. Com a `25E`, o bloco também passa a entregar um layout inicial de projeto alinhado ao estado real do framework.
