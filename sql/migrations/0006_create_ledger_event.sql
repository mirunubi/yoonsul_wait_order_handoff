-- 0006_create_ledger_event.sql
-- Purpose: Event ledger. Records all state changes across the operational OS.
--          Current state is NEVER stored directly.
--          It is always derived from this ledger via Projection or View.
--          특허4 core: Event-sourced state management.
-- Depends on: 0005_create_ledger_task.sql
-- Creates:
--   catchmenu_ledger.events

create table if not exists catchmenu_ledger.events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- event identity
  event_domain text not null,
  event_type text not null,
  event_version int not null default 1,

  -- what changed
  subject_type text not null,
  subject_id uuid not null,
  from_state text,
  to_state text,

  -- who/what caused this
  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),
  caused_by_task_id uuid references catchmenu_ledger.tasks(id),

  -- event payload
  event_payload jsonb not null default '{}'::jsonb,

  -- idempotency
  idempotency_key text,
  is_replay boolean not null default false,
  original_event_id uuid references catchmenu_ledger.events(id),

  -- correlation
  session_id uuid,
  order_id uuid,
  payment_id uuid,
  kds_ticket_id uuid,
  correlation_id text,
  provider_event_id text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',
  occurred_at timestamptz not null default now(),
  recorded_at timestamptz not null default now(),

  constraint chk_event_domain check (
    event_domain in (
      'session',
      'order',
      'payment',
      'kds',
      'delivery',
      'inventory',
      'staff',
      'device',
      'agent',
      'recovery',
      'knowledge',
      'gateway',
      'system'
    )
  ),
  constraint chk_event_type_not_blank check (
    length(trim(event_type)) > 0
  ),
  constraint chk_event_caused_by_type check (
    caused_by_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER',
      'REPLAY'
    )
  ),
  constraint chk_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  ),
  constraint chk_event_replay_has_original check (
    is_replay = false
    or original_event_id is not null
  )
);

create index if not exists idx_events_store_domain
  on catchmenu_ledger.events(store_id, event_domain);

create index if not exists idx_events_subject
  on catchmenu_ledger.events(subject_type, subject_id, occurred_at desc);

create index if not exists idx_events_session
  on catchmenu_ledger.events(session_id, occurred_at desc)
  where session_id is not null;

create index if not exists idx_events_order
  on catchmenu_ledger.events(order_id, occurred_at desc)
  where order_id is not null;

create index if not exists idx_events_payment
  on catchmenu_ledger.events(payment_id, occurred_at desc)
  where payment_id is not null;

create index if not exists idx_events_kds_ticket
  on catchmenu_ledger.events(kds_ticket_id, occurred_at desc)
  where kds_ticket_id is not null;

create index if not exists idx_events_store_business_day
  on catchmenu_ledger.events(store_id, business_day desc);

create index if not exists idx_events_correlation
  on catchmenu_ledger.events(correlation_id)
  where correlation_id is not null;

create index if not exists idx_events_provider_event
  on catchmenu_ledger.events(provider_event_id)
  where provider_event_id is not null;

create index if not exists idx_events_occurred_at
  on catchmenu_ledger.events(store_id, occurred_at desc);

comment on table catchmenu_ledger.events is
  'Event ledger. Append-only record of all state changes in the system.
   This is the single source of truth for operational state.
   Current state of any entity (session, order, payment, KDS ticket)
   is ALWAYS derived from this ledger via Projection or View.
   Never store current state directly in a mutable column.
   If state is corrupted or inconsistent, replay this ledger to reconstruct.
   특허4 core: Event/Audit 원장 기반 Projection/View 재생성 기술.';
comment on column catchmenu_ledger.events.event_type is
  'Specific state change that occurred. Examples:
   session: session_created, table_bound, session_completed, session_expired
   order: order_draft_created, order_submitted, order_confirmed, order_cancelled
   payment: payment_requested, payment_confirmed, payment_failed,
            payment_uncertain, payment_cancelled, payment_refunded
   kds: kds_ticket_created, kds_held, kds_capacity_checked,
        kds_committed, kds_cooking_started, kds_ready, kds_completed
   device: device_online, device_offline, device_degraded, device_failed
   agent: agent_started, agent_isolated, agent_recovered, agent_failed';
comment on column catchmenu_ledger.events.from_state is
  'State before this event. Null for creation events.
   Together with to_state, forms the state transition record.';
comment on column catchmenu_ledger.events.to_state is
  'State after this event. Used to rebuild current state via Projection.';
comment on column catchmenu_ledger.events.is_replay is
  'True when this event was created during Event Replay after outage recovery.
   Replay events reference original_event_id from Local Temporary Ledger.
   특허4: Local Temporary Ledger 및 Event Replay 기반 복구 기술.';
comment on column catchmenu_ledger.events.occurred_at is
  'When the state change actually happened in the real world.
   May differ from recorded_at when replaying from Local Temporary Ledger.';
comment on column catchmenu_ledger.events.recorded_at is
  'When this event row was inserted into the central ledger.
   Always now() at insert time.';
comment on column catchmenu_ledger.events.session_id is
  'Denormalized session reference for fast Projection queries.
   The full event chain for a session can be reconstructed by
   querying WHERE session_id = ? ORDER BY occurred_at ASC.';