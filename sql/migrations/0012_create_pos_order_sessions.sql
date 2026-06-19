-- 0012_create_pos_order_sessions.sql
-- Purpose: Wait/Order Handoff session.
--          One session connects the entire customer journey:
--          waiting → cart → pre-order → seating → order → payment → completion.
--          table_id and order_id are NULL until Late Binding completes.
--          Current state is derived from catchmenu_ledger.events projection.
--          특허1 core: 세션 분리 + Late Binding 테이블 후매칭부.
-- Depends on: 0010_create_store_dining_tables.sql
-- Creates:
--   catchmenu_pos.order_sessions
--   catchmenu_pos.session_events

create table if not exists catchmenu_pos.order_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  session_type text not null,

  -- current status (projection convenience)
  -- source of truth: catchmenu_ledger.events WHERE session_id = this.id
  session_status text not null default 'WAITING',

  -- Late Binding targets (null until bound)
  -- 특허1: 입장 전 null, 착석 후 연결
  table_id uuid references catchmenu_store.dining_tables(id),
  order_id uuid,

  -- customer context
  guest_count int,
  guest_locale text not null default 'ko',
  customer_token text,

  -- waiting queue
  wait_number int,
  queue_position int,

  -- Late Binding timestamp trail
  -- 특허1: 각 단계 타임스탬프 → AI Agent 학습 데이터
  session_started_at timestamptz not null default now(),
  arrived_at timestamptz,
  seated_at timestamptz,
  ordering_started_at timestamptz,
  order_confirmed_at timestamptz,
  payment_started_at timestamptz,
  payment_completed_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  expires_at timestamptz,

  -- pre-order context (특허2)
  pre_order_created_at timestamptz,
  pre_order_expires_at timestamptz,
  arrival_reliability_score int,

  -- gateway linkage
  gateway_session_id uuid references catchmenu_gateway.gateway_sessions(id),
  toss_order_id text unique,

  -- correlation
  correlation_id text,
  idempotency_key text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_session_type check (
    session_type in (
      'WALK_IN',
      'WAITING',
      'PRE_ORDER',
      'KIOSK',
      'TAKEOUT',
      'DELIVERY'
    )
  ),
  constraint chk_session_status check (
    session_status in (
      'WAITING',
      'ARRIVAL_PENDING',
      'SEATED',
      'ORDERING',
      'ORDER_CONFIRMED',
      'PAYMENT_PENDING',
      'PAYMENT_UNCERTAIN',
      'COMPLETED',
      'CANCELLED',
      'EXPIRED',
      'NO_SHOW'
    )
  ),
  constraint chk_session_guest_count check (
    guest_count is null or guest_count > 0
  ),
  constraint chk_session_seated_after_arrived check (
    seated_at is null
    or arrived_at is null
    or seated_at >= arrived_at
  ),
  constraint chk_session_order_after_seated check (
    order_confirmed_at is null
    or seated_at is null
    or order_confirmed_at >= seated_at
  ),
  constraint chk_session_payment_after_order check (
    payment_started_at is null
    or order_confirmed_at is null
    or payment_started_at >= order_confirmed_at
  ),
  constraint chk_session_arrival_reliability check (
    arrival_reliability_score is null
    or arrival_reliability_score between 0 and 100
  )
);

create index if not exists idx_order_sessions_store_status
  on catchmenu_pos.order_sessions(store_id, session_status);

create index if not exists idx_order_sessions_table
  on catchmenu_pos.order_sessions(table_id)
  where table_id is not null;

create index if not exists idx_order_sessions_store_business_day
  on catchmenu_pos.order_sessions(store_id, business_day desc);

create index if not exists idx_order_sessions_wait_number
  on catchmenu_pos.order_sessions(store_id, wait_number)
  where wait_number is not null
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

create index if not exists idx_order_sessions_toss_order
  on catchmenu_pos.order_sessions(toss_order_id)
  where toss_order_id is not null;

create index if not exists idx_order_sessions_gateway
  on catchmenu_pos.order_sessions(gateway_session_id)
  where gateway_session_id is not null;

create index if not exists idx_order_sessions_expires
  on catchmenu_pos.order_sessions(expires_at)
  where expires_at is not null
    and session_status not in (
      'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
    );

drop trigger if exists trg_order_sessions_updated_at
  on catchmenu_pos.order_sessions;
create trigger trg_order_sessions_updated_at
  before update on catchmenu_pos.order_sessions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.order_sessions is
  'Wait/Order Handoff session. The spine of 특허1.
   One session = one customer journey from arrival to completion.
   Connects: wait_number + cart + pre_order + table + order + payment.
   table_id and order_id start NULL and are bound after seating (Late Binding).
   All timestamp fields are the AI learning data for operational optimization.
   특허3 다이어그램3: 대기/장바구니/선주문/테이블매칭/KDS 이벤트 → AI Agent 학습.';
comment on column catchmenu_pos.order_sessions.session_type is
  'WALK_IN = direct seat without waiting.
   WAITING = joined queue, waiting to be called.
   PRE_ORDER = ordered before arrival. 특허2 핵심.
   KIOSK = initiated from kiosk device.
   TAKEOUT = takeout order, no table binding.
   DELIVERY = delivery order, no table binding.';
comment on column catchmenu_pos.order_sessions.session_status is
  'WAITING = in queue.
   ARRIVAL_PENDING = called but not yet confirmed arrived.
   SEATED = Late Binding complete. table_id is now set.
   ORDERING = customer actively selecting menu.
   ORDER_CONFIRMED = order placed, kitchen notified.
   PAYMENT_PENDING = awaiting payment completion.
   PAYMENT_UNCERTAIN = payment attempted but result unknown.
                       KDS must NOT release until resolved.
   COMPLETED = fully done.
   CANCELLED = cancelled by customer or staff.
   EXPIRED = session TTL passed without completion.
   NO_SHOW = called but customer did not arrive.';
comment on column catchmenu_pos.order_sessions.table_id is
  'NULL until Late Binding. Set when customer is confirmed seated.
   특허1: Late Binding 테이블 후매칭부.
   This is the moment the waiting session becomes an operational session.';
comment on column catchmenu_pos.order_sessions.arrival_reliability_score is
  'Score 0-100 based on customer no-show and late arrival history.
   Used by KDS Capacity Agent to determine whether to pre-commit
   a PRE_ORDER session to cooking queue.
   특허2: 고객 도착 신뢰도 기반 KDS 투입 시점 제어.';
comment on column catchmenu_pos.order_sessions.pre_order_expires_at is
  'When the pre-order candidate expires if customer does not arrive.
   특허2: 주문 후보 자동 만료 시간.';


create table if not exists catchmenu_pos.session_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  session_id uuid not null references catchmenu_pos.order_sessions(id),

  event_type text not null,
  from_status text,
  to_status text,

  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),

  event_payload jsonb not null default '{}'::jsonb,
  correlation_id text,

  -- Late Binding snapshot at event time
  table_id_at_event uuid,
  order_id_at_event uuid,

  occurred_at timestamptz not null default now(),

  constraint chk_session_event_type check (
    event_type in (
      'session_created',
      'wait_number_assigned',
      'customer_called',
      'customer_arrived',
      'table_bound',
      'pre_order_created',
      'pre_order_expired',
      'ordering_started',
      'order_confirmed',
      'payment_requested',
      'payment_confirmed',
      'payment_failed',
      'payment_uncertain',
      'payment_recovered',
      'session_completed',
      'session_cancelled',
      'session_expired',
      'no_show_marked',
      'manual_override',
      'session_reopened'
    )
  ),
  constraint chk_session_event_caused_by check (
    caused_by_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'CUSTOMER', 'PROVIDER', 'SCHEDULER'
    )
  ),
  constraint chk_session_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  )
);

create index if not exists idx_session_events_session
  on catchmenu_pos.session_events(session_id, occurred_at asc);

create index if not exists idx_session_events_store_type
  on catchmenu_pos.session_events(store_id, event_type, occurred_at desc);

create index if not exists idx_session_events_table_bound
  on catchmenu_pos.session_events(table_id_at_event, occurred_at desc)
  where event_type = 'table_bound';

comment on table catchmenu_pos.session_events is
  'Session-scoped event log. Domain-level event trail for order sessions.
   Mirrors the structure of catchmenu_ledger.events but scoped to sessions.
   Used for fast session state reconstruction without scanning full event ledger.
   Full audit reconstruction always uses catchmenu_ledger.events as source of truth.';
comment on column catchmenu_pos.session_events.event_type is
  'table_bound = Late Binding completed. This is the most important event.
   payment_uncertain = payment attempted but result unknown.
                       Triggers PAYMENT_UNCERTAIN status.
                       KDS Agent must block cooking queue until resolved.
   no_show_marked = customer called but did not arrive within timeout.
                    Updates arrival_reliability_score downward.';