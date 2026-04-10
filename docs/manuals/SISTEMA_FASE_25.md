# Sistema Fase 25

## Escopo

A FASE 25 adiciona a base realtime do Civitas em cinco módulos:

- `civitas/sse` para serialização SSE, `SseWriter`, `SseBus` e bridge de named signals;
- `civitas/websocket` para handshake RFC 6455, encode/decode de frame, `WsConn` e relay por canal;
- `civitas/sse_presence` para presença leve e inbox de notificações sobre SQLite;
- `civitas/ws_room` para membros ativos, mute, ban e trilha de eventos de salas WS;
- `25E` para o scaffold canônico de projeto novo, separando bootstrap, apps do usuário e runtime local.

O bloco fecha a modelagem e os contratos de protocolo/estado. Ele não introduz um event loop novo no framework nem converte o servidor HTTP padrão em runtime async.

## Arquitetura

### `civitas/sse`

- `SseEvent` modela `id`, `event`, `data` e `retry`;
- `sse_event_to_string(...)` serializa no formato `text/event-stream`;
- `SseWriter` encapsula o socket bruto e mantém `conectado`, `ultima_id` e controle de keepalive;
- `SseBus` usa SQLite como relay cross-process via `sse_bus_events`;
- `sse_bus_on_signal(...)` conecta `NamedSignalRegistry` ao bus, permitindo broadcast a partir de signals nomeados do próprio Civitas;
- `sse_handler_add(...)` registra a rota no roteador com `ROUTE_TRANSPORT_SSE`.

### `civitas/websocket`

- `ws_is_upgrade_request(...)` valida os headers mínimos de upgrade;
- `ws_handshake(...)` gera `101 Switching Protocols` com `Sec-WebSocket-Accept` calculado por `ws_accept_key(...)` no CCT;
- `ws_frame_encode(...)` e `ws_frame_decode(...)` cobrem frames texto/binário/controle com máscara no caminho cliente→servidor;
- `WsConn` mantém canal, `conn_id`, `user_id`, estado de conexão e cursor de relay;
- `ws_channel_publish(...)` e `ws_channel_poll(...)` usam `ws_bus_frames` em SQLite como barramento;
- `ws_handler_add(...)` registra a rota no roteador com `ROUTE_TRANSPORT_WS`.

### `civitas/sse_presence`

- `sse_presence_join/heartbeat/leave/sweep` mantêm presença por `user_id`, `sala` e `conn_id`;
- `sse_presence_count/list` respondem sobre registros elegíveis por timeout;
- `sse_inbox_*` mantém notificações leves não lidas por usuário;
- os helpers de inbox agora garantem `schema_up` por conta própria, evitando ordem frágil de inicialização.

### `civitas/ws_room`

- `ws_room_join/leave/heartbeat` mantêm membros ativos por conexão;
- `ws_room_member_count/members` aplicam timeout de atividade;
- `ws_room_log/event_list/log_purge_old` mantêm trilha auditável da sala;
- `ws_room_mute_*` e `ws_room_ban_*` implementam registros temporários ou permanentes com sweep de expiração;
- os helpers de log/mute/ban também garantem `schema_up` implícito.

## Contratos implementados

### Transporte

- o roteador conhece três transportes: `HTTP`, `SSE` e `WS`;
- `router_match_route(...)` permite recuperar a rota e inspecionar o `transport_kind`;
- `router_dispatch_with_context(...)` continua recusando rotas SSE/WS quando elas entram no caminho HTTP comum, retornando erro interno de uso incorreto.

### Relay cross-process

- `sse_bus_events` e `ws_bus_frames` são tabelas SQLite simples, append-only no caminho normal;
- polling usa `id > ultimo_id` e lote de até 50 registros por consulta;
- flush/purge são explícitos e ficam sob responsabilidade do código que hospeda os loops de longa duração.

### Determinismo observado

- `sse_inbox_list(...)` ordena por `criado_em DESC, id DESC`;
- `ws_room_event_list(...)` ordena por `criado_em DESC, id DESC`;
- isso elimina empates de timestamp no mesmo milissegundo durante testes e uso real.

## Limites operacionais

- a fase não entrega ainda um handoff automático do socket bruto no `HttpServer` padrão;
- as rotas SSE/WS já podem ser registradas e detectadas no roteador, mas exigem uma borda que leia `transport_kind` e entregue o socket ao runtime correto;
- `ws_conn_run(...)` existe como loop síncrono de conexão, porém o acoplamento completo com o accept loop do servidor principal não foi materializado nesta fase;
- o barramento de broadcast usa SQLite, então o perfil é adequado para realtime administrativo/editorial e salas pequenas ou moderadas, não para workloads massivos tipo broker dedicado.

## Gate da fase

O bloco fecha quando:

- `25A` valida serialização SSE, relay SQLite, flush, bridge por signal e registro de rota SSE;
- `25B` valida upgrade request, handshake RFC 6455, encode/decode de frame, relay de canal e registro de rota WS;
- `25C` valida presença por sala, heartbeat/sweep e inbox não lida;
- `25D` valida membros ativos, event log, mute e ban com sweep;
- `25E` valida `project/`, `apps/core`, `settings/`, `data/` e `.civitas/`, mais generators apontando para a nova árvore;
- `tests/run_tests.sh 25A 25B 25C 25D 25E` fica verde.

No estado implementado, a FASE 25 adiciona 26 testes de integração e consolida a base realtime do framework sem quebrar o modelo síncrono do restante do Civitas, ao mesmo tempo em que fecha o layout inicial de projeto recomendado.
