-- 0016_create_kds_tickets.sql
-- Purpose: KDS tickets with Late Binding hold control.
--          Tickets start in HOLD state until all conditions are met.
--          payment_confirmed is a required condition for KDS release.
--          KDS release and payment approval are always separated.
--          특허2 core: KDS 수용상태 기반 Late Binding 조리 실행 큐 제어.
-- Depends on: 0014_create_payment_ledger.sql, 0013_create_pos_orders.sql
-- Creates:
--   catchmenu_kds.kds_tickets
--   catchmenu_kds.kds_events

create table if not exists catchmenu_kds.kds_tickets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  order_item_id uuid references catchmenu_pos.order_items(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  payment_ledger_id uuid references catchmenu_payment.payment_ledger(id),

  -- ticket identity
  ticket_number text not null,
  kds_status text not null default 'HOLD',
  hold_reason text,

  -- kitchen routing
  kitchen_zone text,
  target_device_id uuid references catchmenu_store.device_registry(id),
  priority int not null default 5,

  -- menu snapshot at ticket creation
  menu_name_snapshot text not null,
  quantity_snapshot int not null default 1,
  estimated_minutes_snapshot int,
  prep_complexity_snapshot text,

  -- Late Binding condition tracking
  -- 특허2: 18개 조건 중 핵심 조건 추적
  conditions_met jsonb not null default '{}'::jsonb,
  -- expected structure:
  -- {
  --   "arrived": false,
  --   "table_confirmed": false,
  --   "payment_confirmed": false,
  --   "kds_capacity_ok": false,
  --   "menu_available": true,
  --   "peak_time_ok": true,
  --   "no_show_risk_ok": true
  -- }

  -- capacity check context
  kds_queue_length_at_check int,
  kitchen_load_at_check int,
  capacity_check_at timestamptz,

  -- timestamp trail (Late Binding lifecycle)
  -- 특허2: 각 단계 타임스탬프 → KPI 측정
  ticket_created_at timestamptz not null default now(),
  first_hold_at timestamptz,
  capacity_checking_started_at timestamptz,
  committed_at timestamptz,
  cooking_started_at timestamptz,
  ready_at timestamptz,
  served_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,

  -- manual fallback
  manual_fallback_activated boolean not null default false,
  manual_fallback_reason text,
  manual_fallback_at timestamptz,
  manual_fallback_by uuid,

  -- correlation
  correlation_id text,
  idempotency_key text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_kds_ticket_store_number unique (store_id, ticket_number),
  constraint chk_kds_status check (
    kds_status in (
      'HOLD',
      'CAPACITY_CHECKING',
      'READY_TO_COMMIT',
      'COOKING',
      'READY',
      'SERVED',
      'COMPLETED',
      'CANCELLED',
      'MANUAL_FALLBACK'
    )
  ),
  constraint chk_kds_priority check (priority between 1 and 10),
  constraint chk_kds_conditions_object check (
    jsonb_typeof(conditions_met) = 'object'
  ),
  constraint chk_kds_quantity check (quantity_snapshot > 0),
  constraint chk_kds_committed_after_created check (
    committed_at is null
    or committed_at >= ticket_created_at
  ),
  constraint chk_kds_cooking_after_committed check (
    cooking_started_at is null
    or committed_at is null
    or cooking_started_at >= committed_at
  ),
  constraint chk_kds_ready_after_cooking check (
    ready_at is null
    or cooking_started_at is null
    or ready_at >= cooking_started_at
  )
);

create index if not exists idx_kds_tickets_store_status
  on catchmenu_kds.kds_tickets(store_id, kds_status);

create index if not exists idx_kds_tickets_order
  on catchmenu_kds.kds_tickets(order_id);

create index if not exists idx_kds_tickets_store_zone
  on catchmenu_kds.kds_tickets(store_id, kitchen_zone, kds_status)
  where kitchen_zone is not null
    and kds_status in ('READY_TO_COMMIT', 'COOKING');

create index if not exists idx_kds_tickets_session
  on catchmenu_kds.kds_tickets(session_id)
  where session_id is not null;

create index if not exists idx_kds_tickets_payment_ledger
  on catchmenu_kds.kds_tickets(payment_ledger_id)
  where payment_ledger_id is not null;

create index if not exists idx_kds_tickets_hold
  on catchmenu_kds.kds_tickets(store_id, ticket_created_at desc)
  where kds_status in ('HOLD', 'CAPACITY_CHECKING');

create index if not exists idx_kds_tickets_device
  on catchmenu_kds.kds_tickets(target_device_id, kds_status)
  where target_device_id is not null
    and kds_status in ('READY_TO_COMMIT', 'COOKING', 'READY');

create index if not exists idx_kds_tickets_business_day
  on catchmenu_kds.kds_tickets(store_id, business_day desc);

create index if not exists idx_kds_tickets_manual_fallback
  on catchmenu_kds.kds_tickets(store_id, manual_fallback_activated)
  where manual_fallback_activated = true;

drop trigger if exists trg_kds_tickets_updated_at
  on catchmenu_kds.kds_tickets;
create trigger trg_kds_tickets_updated_at
  before update on catchmenu_kds.kds_tickets
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_kds.kds_tickets is
  'KDS kitchen tickets with Late Binding hold control.
   Core implementation of 특허2.
   All tickets start in HOLD state.
   Transition to READY_TO_COMMIT only when all conditions_met are true.
   KDS release ALWAYS requires payment_confirmed = true in conditions_met.
   Payment approval alone is NOT sufficient — kds_release_authorized in
   payment_ledger must also be true.
   특허2 원칙: 사전 주문 후보를 즉시 KDS 티켓으로 생성하지 않는다.';
comment on column catchmenu_kds.kds_tickets.kds_status is
  'HOLD = all or some conditions not yet met. Kitchen does not see this ticket.
   CAPACITY_CHECKING = KDS Capacity Agent is evaluating kitchen load.
   READY_TO_COMMIT = all conditions met, ready to send to kitchen display.
   COOKING = ticket visible on KDS, cooking in progress.
   READY = cooking complete, waiting to serve.
   SERVED = delivered to customer.
   COMPLETED = fully done.
   CANCELLED = cancelled before cooking.
   MANUAL_FALLBACK = staff handling manually, KDS bypassed.';
comment on column catchmenu_kds.kds_tickets.conditions_met is
  'Tracks which Late Binding conditions are satisfied.
   All must be true before HOLD → READY_TO_COMMIT transition.
   arrived: customer physically arrived at store.
   table_confirmed: table assignment completed (Late Binding).
   payment_confirmed: payment_ledger.kds_release_authorized = true.
   kds_capacity_ok: kitchen load within acceptable threshold.
   menu_available: menu item not sold out.
   peak_time_ok: not in restricted peak period for this menu.
   no_show_risk_ok: customer arrival reliability score acceptable.
   특허2: 7개 핵심 조건 모두 충족 시 조리 실행 큐 투입.';
comment on column catchmenu_kds.kds_tickets.committed_at is
  'Timestamp when HOLD → READY_TO_COMMIT transition occurred.
   This is the Late Binding commit point.
   Time between ticket_created_at and committed_at = hold duration.
   Used by AI Agent to optimize pre-order timing recommendations.
   특허2: KDS Late Binding 완료 시점.';
comment on column catchmenu_kds.kds_tickets.manual_fallback_activated is
  'True when KDS system failed and staff is handling manually.
   All manual fallback actions must be recorded in audit ledger.
   특허2: Manual Fallback 구조 — POS/KDS 장애 시 운영 연속성 유지.';
comment on column catchmenu_kds.kds_tickets.payment_ledger_id is
  'Links to payment_ledger record that authorized KDS release.
   Must be set before kds_status can transition past HOLD.
   Null = payment not yet confirmed = KDS release blocked.
   특허1: 결제 승인 원장 확인 후 KDS 릴리즈 허용.';


create table if not exists catchmenu_kds.kds_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  ticket_id uuid not null references catchmenu_kds.kds_tickets(id),
  order_id uuid not null references catchmenu_pos.orders(id),

  event_type text not null,
  from_status text,
  to_status text,

  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),

  -- condition snapshot at event time
  conditions_at_event jsonb,

  event_payload jsonb not null default '{}'::jsonb,
  correlation_id text,
  occurred_at timestamptz not null default now(),

  constraint chk_kds_event_type check (
    event_type in (
      'ticket_created',
      'hold_started',
      'capacity_check_started',
      'condition_updated',
      'all_conditions_met',
      'committed_to_queue',
      'sent_to_kds_display',
      'cooking_started',
      'cooking_completed',
      'ready_to_serve',
      'served',
      'ticket_completed',
      'ticket_cancelled',
      'hold_extended',
      'pre_order_expired',
      'manual_fallback_activated',
      'manual_fallback_completed',
      'kds_device_failed',
      'kds_device_recovered',
      'peak_time_restricted',
      'capacity_exceeded',
      'payment_confirmation_waited',
      'payment_confirmed_released'
    )
  ),
  constraint chk_kds_event_caused_by check (
    caused_by_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'CUSTOMER', 'SCHEDULER'
    )
  ),
  constraint chk_kds_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  ),
  constraint chk_kds_event_conditions_object check (
    conditions_at_event is null
    or jsonb_typeof(conditions_at_event) = 'object'
  )
);

create index if not exists idx_kds_events_ticket
  on catchmenu_kds.kds_events(ticket_id, occurred_at asc);

create index if not exists idx_kds_events_order
  on catchmenu_kds.kds_events(order_id, occurred_at asc);

create index if not exists idx_kds_events_store_type
  on catchmenu_kds.kds_events(store_id, event_type, occurred_at desc);

create index if not exists idx_kds_events_store_business_day
  on catchmenu_kds.kds_events(store_id, occurred_at desc);

comment on table catchmenu_kds.kds_events is
  'KDS-scoped event log. Complete state transition trail for every KDS ticket.
   condition_updated events record which specific condition changed and to what value.
   This event trail is the primary data source for:
   - KDS hold duration analysis (AI learning data)
   - Kitchen capacity optimization (특허2 KDS Capacity Agent)
   - Pre-order timing recommendations (특허3 SOP Evolution)
   - Manual fallback frequency analysis (operational resilience KPI)
   특허3 다이어그램3: KDS/조리 Event → Task/Event 운영 원장 → AI Agent 학습.';
comment on column catchmenu_kds.kds_events.event_type is
  'payment_confirmation_waited = ticket in HOLD waiting for payment_confirmed.
   payment_confirmed_released = payment confirmed, condition updated, ready to proceed.
   capacity_exceeded = KDS load too high, ticket remains in HOLD.
   pre_order_expired = PRE_ORDER session timed out, ticket cancelled.
   peak_time_restricted = menu restricted during peak, ticket held longer.';