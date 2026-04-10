# Manual Aprofundado do Sistema — FASE 3

## Visão geral

A FASE 3 adiciona ao Civitas a primeira infraestrutura explícita de desacoplamento interno do framework.

O bloco `3A-3C` entrega:

- `signals` locais para hooks do ciclo do framework;
- `events` locais para fatos semânticos de aplicação;
- `outbox` durável para publicação confiável apenas após commit.

As três camadas foram mantidas separadas:

- `signal`: hook local do framework, geralmente síncrono;
- `event`: fato nomeado com identidade, atributos e payload serializável;
- `outbox entry`: persistência durável de evento para publicação pós-commit.

## Signals

O contrato está em `lib/civitas/signals.cct`.

Tipos centrais:

- `Signal`
- `SignalHandlerBinding`
- `SignalEnvelope`
- `SignalDispatchReport`
- `RequestSignals`

Capacidades estabilizadas:

- `signal_new(...)` e `signal_init(...)`;
- `signal_connect(...)` com ID estável;
- `signal_disconnect(...)`;
- `signal_send(...)` síncrono e ordenado;
- `signal_send_async(...)` como ponte explícita, retornando `Err` quando não há dispatcher assíncrono configurado.

Políticas de erro:

- `SIGNAL_STOP_ON_ERROR`: a primeira falha interrompe o dispatch;
- `SIGNAL_CONTINUE_ON_ERROR`: continua, contabiliza falhas e preserva a primeira mensagem de erro no relatório.

Built-ins do ciclo de request:

- `request_started`
- `request_finished`
- `request_failed`
- `post_request`

`post_request` foi implementado como hook público na mesma janela temporal de `request_finished`, para manter compatibilidade com o gate da fase sem criar uma semântica concorrente.

`signals_dispatch_router_request(...)` integra signals ao ciclo HTTP:

- emite `request_started` antes do dispatch;
- resolve a rota para extrair `route_name` quando disponível;
- converte `fractum` não tratado em `500 internal server error`;
- emite `request_failed` no caminho excepcional;
- emite `request_finished` e `post_request` no fechamento com `status_code` e `duration_ms`.

## Events

O contrato está em `lib/civitas/events.cct`.

Tipos centrais:

- `EventBus`
- `EventEnvelope`
- `EventFilter`
- `EventSubscriberBinding`
- `EventDispatchReport`

Capacidades estabilizadas:

- `event_bus_new(...)`;
- `event_subscribe(...)`;
- `event_subscribe_filtered(...)`;
- `event_unsubscribe(...)`;
- `event_publish(...)`;
- `event_bus_has_subscribers(...)`.

Contrato operacional:

- o bus é serviço explícito, não singleton implícito do processo;
- publish é local e síncrono;
- entrega é por igualdade exata de `event_type`;
- filtro é apenas igualdade de atributo;
- envelope já nasce com `event_id` e `occurred_at_iso`;
- atributos ficam separados de `payload_json` para observabilidade, filtro e persistência futura.

`event_attributes_set(...)` e `event_attribute_or(...)` fazem lookup textual estável da chave antes de ler ou sobrescrever o valor, evitando depender de identidade interna do `VERBUM` usado como chave do mapa.

## Outbox

O contrato está em `lib/civitas/outbox.cct`.

Tipos centrais:

- `OutboxStore`
- `OutboxEntry`
- `OutboxClaimBatch`
- `OutboxPublishReport`
- `OutboxTransaction`

Backend implementado nesta fase:

- `backend_name = "fs_json"`
- persistência em diretório com entries JSON individuais e índice `_index.json`

Capacidades estabilizadas:

- `outbox_store_open(...)`;
- `outbox_enqueue(...)`;
- `outbox_claim_batch(...)`;
- `outbox_mark_published(...)`;
- `outbox_mark_failed(...)`;
- `outbox_release_lease(...)`;
- `outbox_publish_claimed(...)`;
- `outbox_after_commit_publish(...)`;
- transação explícita com `outbox_tx_begin(...)`, `outbox_tx_enqueue(...)`, `outbox_tx_commit(...)`, `outbox_tx_rollback(...)` e `outbox_tx_commit_and_publish(...)`.

State machine efetiva:

- `OUTBOX_PENDING`
- `OUTBOX_LEASED`
- `OUTBOX_PUBLISHED`
- `OUTBOX_FAILED`
- `OUTBOX_DEAD_LETTER`

Semântica operacional:

- publicação antes do commit não ocorre;
- lease controla concorrência entre publicadores;
- falha incrementa `attempts`, registra `last_error` e agenda `available_at_unix_ms`;
- ao exceder a política, a entry vai para `DEAD_LETTER`;
- a semântica é `at-least-once`.

`dedupe_key` foi estabilizada como metadado persistido e útil para operação e idempotência do consumidor, mas não é tratada como constraint de unicidade nesta fase.

## Cobertura de testes

Cobertura da FASE 3:

- `3A`: 6 testes
- `3B`: 6 testes
- `3C`: 6 testes

Total da FASE 3: 18 testes de integração.

## Limites operacionais

- `signal_send_async(...)` não entrega execução assíncrona real nesta fase;
- `events` continuam restritos ao processo local;
- o outbox atual é file-backed (`fs_json`), não banco relacional;
- consumidores do outbox precisam ser idempotentes;
- `dedupe_key` não impede gravações duplicadas por si só.
