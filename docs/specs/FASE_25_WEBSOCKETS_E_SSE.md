# FASE 25 — WebSockets, SSE e Scaffold Canônico

## Objetivo

Entregar os contratos realtime do Civitas em cima do stack atual: SSE para push unidirecional, WebSocket para bidirecionalidade, presença leve via SSE, estado persistido de salas WS e um scaffold inicial de projeto coerente com o estado real do framework.

## Módulos

- `lib/civitas/sse/sse.cct`
- `lib/civitas/websocket/websocket.cct`
- `lib/civitas/sse_presence/sse_presence.cct`
- `lib/civitas/ws_room/ws_room.cct`
- `lib/civitas/civitas_new/civitas_new.cct`
- `lib/civitas/civitas_generate/civitas_generate.cct`
- `lib/civitas/civitas_config/civitas_config.cct`

## Contratos implementados

### 25A

- `SseEvent`, `SseWriter` e `SseBus`
- serialização `text/event-stream`
- `sse_write`, `sse_keepalive`, `sse_is_connected`
- relay SQLite `sse_bus_events`
- bridge de `NamedSignalRegistry` para SSE
- registro de rota com `router_add_sse(...)`

### 25B

- `WsFrame`, `WsConn`, `WsHandlers` e `WsReadResult`
- `ws_is_upgrade_request(...)`
- `ws_handshake(...)` com `ws_accept_key(...)`
- `ws_frame_encode(...)` e `ws_frame_decode(...)`
- relay SQLite `ws_bus_frames`
- `ws_channel_publish/poll/broadcast`
- registro de rota com `router_add_ws(...)`

### 25C

- schema `sse_presence` e `sse_inbox`
- `join`, `heartbeat`, `leave` e `sweep`
- `count` e `list` por sala
- inbox com push, contagem não lida, listagem e marcação de lido

### 25D

- schema `ws_room_members`, `ws_room_mutes`, `ws_room_bans`, `ws_room_events`
- presença por conexão em sala
- event log auditável com purge por idade
- mute temporário ou permanente com sweep
- ban temporário ou permanente com sweep

### 25E

- `civitas new` e `civitas init` geram `project/main.cct` e `project/urls.cct`
- o projeto nasce com `apps/core`, `settings/`, `tests/`, `data/` e `.civitas/`
- `civitas generate` escreve em `apps/core/models`, `apps/core/views`, `apps/core/routes` e `apps/core/admin`
- `civitas_config` passa a usar `project/main.cct` e `apps/core/*` como defaults do scaffold canônico

## Limites explícitos

- o roteador já distingue SSE/WS, mas o dispatch HTTP comum não executa esses transportes;
- a integração final com accept loop e entrega do socket bruto continua fora deste bloco;
- SQLite é o relay oficial da fase, não há broker externo ou cluster state dedicado.

## Cobertura

Foram adicionados 26 testes de integração:

- `25A`: 5
- `25B`: 6
- `25C`: 5
- `25D`: 5
- `25E`: 5

## Gate

- `cct-host test fase25_25a_ --project .`
- `cct-host test fase25_25b_ --project .`
- `cct-host test fase25_25c_ --project .`
- `cct-host test fase25_25d_ --project .`
- `cct-host test fase25_25e_ --project .`
- `bash tests/run_tests.sh 25A 25B 25C 25D 25E`

Todos precisam ficar verdes antes do gate completo da suíte.
