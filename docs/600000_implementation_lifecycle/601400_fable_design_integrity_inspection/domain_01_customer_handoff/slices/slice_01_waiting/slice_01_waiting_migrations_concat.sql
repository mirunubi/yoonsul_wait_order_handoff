-- slice_01 — Waiting (600600 + waiting SQL)
-- Files: 15


-- ===== BEGIN sql/migrations/0012_create_pos_order_sessions.sql =====

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

-- ===== END sql/migrations/0012_create_pos_order_sessions.sql =====


-- ===== BEGIN sql/migrations/0013_create_pos_orders.sql =====

-- 0013_create_pos_orders.sql
-- Purpose: Order header and order items.
--          Order is created after session reaches ORDER_CONFIRMED status.
--          All amounts are price snapshots at order time.
--          Current order status is derived from catchmenu_ledger.events.
-- Depends on: 0012_create_pos_order_sessions.sql, 0011_create_pos_menu.sql
-- Creates:
--   catchmenu_pos.orders
--   catchmenu_pos.order_items
--   catchmenu_pos.order_events

create table if not exists catchmenu_pos.orders (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  table_id uuid references catchmenu_store.dining_tables(id),

  order_number text not null,
  order_type text not null default 'DINE_IN',

  -- current status (projection convenience)
  -- source of truth: catchmenu_ledger.events WHERE order_id = this.id
  order_status text not null default 'PENDING',

  -- amounts (all KRW integer, snapshot at order time)
  total_amount int not null default 0,
  discount_amount int not null default 0,
  final_amount int not null default 0,

  -- channel
  order_channel text not null default 'KIOSK',
  pos_order_number text,
  delivery_order_id text,

  -- customer context snapshot
  guest_count int,
  guest_locale text not null default 'ko',
  memo text,
  special_requests text,

  -- kitchen routing
  kitchen_zone_summary jsonb,

  -- timing
  ordered_at timestamptz not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  completed_at timestamptz,

  -- gateway linkage
  gateway_session_id uuid references catchmenu_gateway.gateway_sessions(id),
  idempotency_key text,
  correlation_id text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_orders_store_number unique (store_id, order_number),
  constraint chk_order_type check (
    order_type in (
      'DINE_IN',
      'TAKEOUT',
      'DELIVERY',
      'KIOSK',
      'STAFF_ORDER'
    )
  ),
  constraint chk_order_status check (
    order_status in (
      'PENDING',
      'CONFIRMED',
      'COOKING',
      'READY',
      'SERVED',
      'COMPLETED',
      'CANCELLED',
      'REFUNDED',
      'PARTIAL_REFUNDED'
    )
  ),
  constraint chk_order_channel check (
    order_channel in (
      'KIOSK',
      'TABLE_QR',
      'STAFF_POS',
      'CUSTOMER_APP',
      'DELIVERY_BAEMIN',
      'DELIVERY_YOGIYO',
      'DELIVERY_COUPANG',
      'MANUAL'
    )
  ),
  constraint chk_order_amounts check (
    total_amount >= 0
    and discount_amount >= 0
    and final_amount >= 0
    and final_amount = total_amount - discount_amount
  ),
  constraint chk_kitchen_zone_object check (
    kitchen_zone_summary is null
    or jsonb_typeof(kitchen_zone_summary) = 'object'
  )
);

create index if not exists idx_orders_store_status
  on catchmenu_pos.orders(store_id, order_status);

create index if not exists idx_orders_session
  on catchmenu_pos.orders(session_id)
  where session_id is not null;

create index if not exists idx_orders_table
  on catchmenu_pos.orders(table_id)
  where table_id is not null;

create index if not exists idx_orders_store_business_day
  on catchmenu_pos.orders(store_id, business_day desc);

create index if not exists idx_orders_store_ordered_at
  on catchmenu_pos.orders(store_id, ordered_at desc);

create index if not exists idx_orders_channel
  on catchmenu_pos.orders(store_id, order_channel, ordered_at desc);

create index if not exists idx_orders_pos_number
  on catchmenu_pos.orders(pos_order_number)
  where pos_order_number is not null;

create index if not exists idx_orders_delivery
  on catchmenu_pos.orders(delivery_order_id)
  where delivery_order_id is not null;

drop trigger if exists trg_orders_updated_at
  on catchmenu_pos.orders;
create trigger trg_orders_updated_at
  before update on catchmenu_pos.orders
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.orders is
  'Order header. One row per confirmed customer order.
   Created when session transitions to ORDER_CONFIRMED.
   All amounts are snapshots at order time — never recalculated after creation.
   order_status is a projection convenience column.
   Source of truth: catchmenu_ledger.events WHERE order_id = this.id.';
comment on column catchmenu_pos.orders.order_number is
  'Human-readable store-scoped order number.
   Resets daily per business_day.
   Used on KDS tickets, receipts, and DID customer display.';
comment on column catchmenu_pos.orders.order_status is
  'PENDING = created, not yet kitchen-confirmed.
   CONFIRMED = kitchen received and accepted.
   COOKING = at least one KDS ticket in COOKING state.
   READY = all KDS tickets completed, waiting to serve.
   SERVED = delivered to customer.
   COMPLETED = fully done including payment.
   CANCELLED = cancelled before completion.
   REFUNDED = fully refunded after payment.
   PARTIAL_REFUNDED = partially refunded.';
comment on column catchmenu_pos.orders.kitchen_zone_summary is
  'Snapshot of kitchen zone distribution at order time.
   e.g. {"튀김": 2, "면": 1, "음료": 3}
   Used by KDS routing and capacity check.';
comment on column catchmenu_pos.orders.pos_order_number is
  'POS-assigned order number when synced to external POS.
   Used for reconciliation between internal order and POS record.';


create table if not exists catchmenu_pos.order_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  menu_id uuid not null references catchmenu_pos.menus(id),

  -- price snapshots at order time (immutable after creation)
  menu_code_snapshot text not null,
  menu_name_snapshot text not null,
  unit_price_snapshot int not null,
  quantity int not null default 1,
  item_amount int not null,

  -- selected options snapshot
  selected_options jsonb not null default '[]'::jsonb,
  options_amount int not null default 0,

  -- kitchen routing snapshot
  kitchen_zone_snapshot text,
  estimated_minutes_snapshot int,
  is_kds_required_snapshot boolean not null default true,

  -- item status (projection convenience)
  item_status text not null default 'PENDING',

  -- allergen display evidence
  -- 특허1: 알러지 고지 이력 원장 기록
  allergen_displayed boolean not null default false,
  allergen_locale_displayed text,
  allergen_version_displayed text,
  allergen_confirmed_by_customer boolean,

  memo text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_order_item_quantity check (quantity > 0),
  constraint chk_order_item_price check (unit_price_snapshot >= 0),
  constraint chk_order_item_amount check (
    item_amount = unit_price_snapshot * quantity + options_amount
  ),
  constraint chk_order_item_status check (
    item_status in (
      'PENDING',
      'CONFIRMED',
      'COOKING',
      'READY',
      'SERVED',
      'CANCELLED'
    )
  ),
  constraint chk_selected_options_array check (
    jsonb_typeof(selected_options) = 'array'
  )
);

create index if not exists idx_order_items_order
  on catchmenu_pos.order_items(order_id);

create index if not exists idx_order_items_store_status
  on catchmenu_pos.order_items(store_id, item_status);

create index if not exists idx_order_items_kitchen_zone
  on catchmenu_pos.order_items(store_id, kitchen_zone_snapshot)
  where kitchen_zone_snapshot is not null
    and item_status in ('PENDING', 'CONFIRMED', 'COOKING');

drop trigger if exists trg_order_items_updated_at
  on catchmenu_pos.order_items;
create trigger trg_order_items_updated_at
  before update on catchmenu_pos.order_items
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.order_items is
  'Order line items. One row per menu item in an order.
   All price and menu fields are snapshots at order time.
   They never change even if menu price or name changes later.
   kitchen_zone_snapshot drives KDS ticket routing.
   Allergen display evidence is recorded per item per customer.
   특허1: 알러지 고지 이력 — 어떤 언어로 어떤 문구가 표시됐는지 증빙 저장.';
comment on column catchmenu_pos.order_items.selected_options is
  'Array of selected option snapshots at order time.
   e.g. [{"group": "사이즈", "item": "대", "additional_price": 500},
          {"group": "맵기", "item": "매운맛", "additional_price": 0}]';
comment on column catchmenu_pos.order_items.allergen_displayed is
  'True when allergen info was shown to customer before order confirmation.
   Required for allergen evidence compliance.
   특허1: 특정 고객에게 어떤 언어로 어떤 알러지 문구가 표시되었는지 증빙.';
comment on column catchmenu_pos.order_items.allergen_confirmed_by_customer is
  'True when customer explicitly confirmed allergen acknowledgement.
   Null when allergen confirmation was not required for this item.';


create table if not exists catchmenu_pos.order_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),

  event_type text not null,
  from_status text,
  to_status text,

  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),

  event_payload jsonb not null default '{}'::jsonb,
  correlation_id text,
  occurred_at timestamptz not null default now(),

  constraint chk_order_event_type check (
    event_type in (
      'order_created',
      'order_confirmed',
      'order_sent_to_kds',
      'order_cooking_started',
      'order_ready',
      'order_served',
      'order_completed',
      'order_cancelled',
      'order_refunded',
      'order_partial_refunded',
      'order_modified',
      'pos_sync_completed',
      'pos_sync_failed',
      'manual_override',
      'recovery_applied'
    )
  ),
  constraint chk_order_event_caused_by check (
    caused_by_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'CUSTOMER', 'PROVIDER', 'SCHEDULER'
    )
  ),
  constraint chk_order_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  )
);

create index if not exists idx_order_events_order
  on catchmenu_pos.order_events(order_id, occurred_at asc);

create index if not exists idx_order_events_store_type
  on catchmenu_pos.order_events(store_id, event_type, occurred_at desc);

comment on table catchmenu_pos.order_events is
  'Order-scoped event log. Domain event trail for order lifecycle.
   Used for fast order state reconstruction without scanning full event ledger.
   Source of truth for disputes, reconciliation, and support investigation.';

-- ===== END sql/migrations/0013_create_pos_orders.sql =====


-- ===== BEGIN sql/migrations/0025_create_session_rpc.sql =====

-- 0025_create_session_rpc.sql
-- Purpose: Order session lifecycle RPCs.
--          create_order_session: creates new Handoff session.
--          bind_table_to_session: Late Binding — connects table to session.
--          mark_session_arrived: records customer arrival.
--          expire_session: expires timed-out sessions.
--          특허1 core: 세션 분리 + Late Binding 테이블 후매칭부.
-- Depends on: 0024_create_store_bootstrap_rpc.sql
-- Creates:
--   function catchmenu_pos.create_order_session(...)
--   function catchmenu_pos.mark_session_arrived(...)
--   function catchmenu_pos.bind_table_to_session(...)
--   function catchmenu_pos.expire_session(...)

create or replace function catchmenu_pos.create_order_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_type text,
  p_guest_count int default null,
  p_guest_locale text default 'ko',
  p_wait_number int default null,
  p_table_id uuid default null,
  p_expires_minutes int default 120,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_session_id uuid;
  v_initial_status text;
  v_business_day date;
  v_timezone text;
  v_table_status text;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id and is_active = true;

  if v_timezone is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- validate session type
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_session_type'
    );
  end if;

  -- determine initial status
  v_initial_status := case p_session_type
    when 'WALK_IN' then 'SEATED'
    when 'WAITING' then 'WAITING'
    when 'PRE_ORDER' then 'WAITING'
    when 'KIOSK' then 'ORDERING'
    when 'TAKEOUT' then 'ORDERING'
    when 'DELIVERY' then 'ORDER_CONFIRMED'
    else 'WAITING'
  end;

  -- if table_id provided for WALK_IN, validate table availability
  if p_table_id is not null then
    select table_status into v_table_status
    from catchmenu_store.dining_tables
    where id = p_table_id
      and store_id = p_store_id
      and is_active = true;

    if v_table_status is null then
      return jsonb_build_object(
        'success', false,
        'error_key', 'table_not_found'
      );
    end if;

    if v_table_status not in ('AVAILABLE', 'RESERVED') then
      return jsonb_build_object(
        'success', false,
        'error_key', 'table_not_available',
        'table_status', v_table_status
      );
    end if;
  end if;

  -- create session
  insert into catchmenu_pos.order_sessions (
    tenant_id,
    store_id,
    session_type,
    session_status,
    table_id,
    guest_count,
    guest_locale,
    wait_number,
    session_started_at,
    seated_at,
    expires_at,
    correlation_id,
    business_day,
    business_timezone
  ) values (
    p_tenant_id,
    p_store_id,
    p_session_type,
    v_initial_status,
    p_table_id,
    p_guest_count,
    coalesce(p_guest_locale, 'ko'),
    p_wait_number,
    now(),
    case when p_session_type = 'WALK_IN' then now() else null end,
    now() + (p_expires_minutes || ' minutes')::interval,
    p_correlation_id,
    v_business_day,
    v_timezone
  )
  returning id into v_session_id;

  -- if WALK_IN with table, update table status
  if p_table_id is not null and p_session_type = 'WALK_IN' then
    update catchmenu_store.dining_tables
    set
      table_status = 'OCCUPIED',
      current_session_id = v_session_id,
      occupied_since = now(),
      updated_at = now()
    where id = p_table_id;
  end if;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id,
    store_id,
    session_id,
    event_type,
    from_status,
    to_status,
    caused_by_type,
    event_payload,
    correlation_id,
    table_id_at_event,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    v_session_id,
    'session_created',
    null,
    v_initial_status,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'guest_count', p_guest_count,
      'wait_number', p_wait_number,
      'table_id', p_table_id
    ),
    p_correlation_id,
    p_table_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    store_id,
    event_domain,
    event_type,
    event_version,
    subject_type,
    subject_id,
    from_state,
    to_state,
    caused_by_type,
    event_payload,
    session_id,
    correlation_id,
    business_day,
    business_timezone,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    'session',
    'session_created',
    1,
    'order_session',
    v_session_id,
    null,
    v_initial_status,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'table_id', p_table_id,
      'wait_number', p_wait_number
    ),
    v_session_id,
    p_correlation_id,
    v_business_day,
    v_timezone,
    now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session_id,
    'session_type', p_session_type,
    'session_status', v_initial_status,
    'table_id', p_table_id,
    'wait_number', p_wait_number,
    'business_day', v_business_day,
    'expires_at', now() + (p_expires_minutes || ' minutes')::interval
  );
end;
$$;


create or replace function catchmenu_pos.mark_session_arrived(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_session record;
begin
  select id, session_type, session_status,
         table_id, wait_number, business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_session_status',
      'current_status', v_session.session_status
    );
  end if;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    arrived_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'customer_arrived',
    v_session.session_status,
    'ARRIVAL_PENDING',
    'CUSTOMER',
    jsonb_build_object('wait_number', v_session.wait_number),
    p_correlation_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'customer_arrived', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER',
    jsonb_build_object('wait_number', v_session.wait_number),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', 'ARRIVAL_PENDING',
    'arrived_at', now()
  );
end;
$$;


create or replace function catchmenu_pos.bind_table_to_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_session record;
  v_table record;
  v_audit_id uuid;
begin
  -- session validation
  select id, session_type, session_status,
         table_id, business_day, business_timezone,
         wait_number, guest_count
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  -- session must be in pre-binding state
  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING', 'ORDERING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_bindable',
      'current_status', v_session.session_status
    );
  end if;

  -- already bound
  if v_session.table_id is not null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_already_bound',
      'current_table_id', v_session.table_id
    );
  end if;

  -- table validation
  select id, table_code, table_name, table_status, current_session_id
  into v_table
  from catchmenu_store.dining_tables
  where id = p_table_id
    and store_id = p_store_id
    and is_active = true
  for update;

  if v_table.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_found'
    );
  end if;

  if v_table.table_status not in ('AVAILABLE', 'RESERVED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'table_not_available',
      'table_status', v_table.table_status,
      'current_session_id', v_table.current_session_id
    );
  end if;

  -- Late Binding — the core of 특허1
  -- bind table to session
  update catchmenu_pos.order_sessions
  set
    table_id = p_table_id,
    session_status = 'SEATED',
    seated_at = now(),
    ordering_started_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- update table status
  update catchmenu_store.dining_tables
  set
    table_status = 'OCCUPIED',
    current_session_id = p_session_id,
    occupied_since = now(),
    updated_at = now()
  where id = p_table_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    table_id_at_event, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'table_bound',
    v_session.session_status,
    'SEATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'wait_number', v_session.wait_number,
      'guest_count', v_session.guest_count
    ),
    p_correlation_id,
    p_table_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'table_bound', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'late_binding_completed', true
    ),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  -- audit record for Late Binding
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'table_late_binding_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'COMPLETED',
    p_decision_reason := 'Late Binding completed',
    p_decision_payload := jsonb_build_object(
      'table_id', p_table_id,
      'table_code', v_table.table_code,
      'from_status', v_session.session_status,
      'to_status', 'SEATED'
    ),
    p_before_state := jsonb_build_object(
      'session_status', v_session.session_status,
      'table_id', null
    ),
    p_after_state := jsonb_build_object(
      'session_status', 'SEATED',
      'table_id', p_table_id
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', 'SEATED',
    'table_id', p_table_id,
    'table_code', v_table.table_code,
    'seated_at', now(),
    'late_binding_completed', true,
    'audit_id', v_audit_id,
    'message_code', 'late_binding_completed'
  );
end;
$$;


create or replace function catchmenu_pos.expire_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_expire_reason text default 'TTL_EXPIRED',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_session record;
  v_expire_status text;
begin
  select id, session_type, session_status,
         table_id, business_day, business_timezone,
         wait_number
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status in (
    'COMPLETED', 'CANCELLED', 'EXPIRED', 'NO_SHOW'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_already_terminal',
      'current_status', v_session.session_status
    );
  end if;

  -- determine terminal status
  v_expire_status := case p_expire_reason
    when 'NO_SHOW' then 'NO_SHOW'
    else 'EXPIRED'
  end;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = v_expire_status,
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- release table if bound
  if v_session.table_id is not null then
    update catchmenu_store.dining_tables
    set
      table_status = 'CLEANING',
      current_session_id = null,
      updated_at = now()
    where id = v_session.table_id
      and current_session_id = p_session_id;
  end if;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    case p_expire_reason
      when 'NO_SHOW' then 'no_show_marked'
      else 'session_expired'
    end,
    v_session.session_status,
    v_expire_status,
    'SYSTEM',
    jsonb_build_object(
      'expire_reason', p_expire_reason,
      'wait_number', v_session.wait_number
    ),
    p_correlation_id,
    now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session',
    case p_expire_reason
      when 'NO_SHOW' then 'no_show_marked'
      else 'session_expired'
    end,
    1,
    'order_session', p_session_id,
    v_session.session_status, v_expire_status,
    'SYSTEM',
    jsonb_build_object('expire_reason', p_expire_reason),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'session_status', v_expire_status,
    'expire_reason', p_expire_reason,
    'table_released', v_session.table_id is not null
  );
end;
$$;

-- grants
revoke all on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) from public;
grant execute on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) to authenticated;

revoke all on function catchmenu_pos.mark_session_arrived(
  uuid, uuid, uuid, text
) from public;
grant execute on function catchmenu_pos.mark_session_arrived(
  uuid, uuid, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) to authenticated;

comment on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, uuid, int, text
) is
  'Creates a new Wait/Order Handoff session.
   WALK_IN: immediately SEATED with optional table binding.
   WAITING: enters queue with wait_number.
   PRE_ORDER: 특허2 — pre-order before arrival.
   Writes session_events and ledger events on creation.
   특허1: 세션 분리 — 대기/장바구니/주문/결제/테이블 세션 독립 관리.';

comment on function catchmenu_pos.bind_table_to_session(
  uuid, uuid, uuid, uuid, text, uuid, text
) is
  'Late Binding RPC. The core of 특허1.
   Connects a waiting/arrived session to a physical table.
   Before this call: table_id is NULL on the session.
   After this call: table_id is set, session status = SEATED.
   Validates table availability before binding.
   Writes session_events, ledger event, and audit record.
   특허1: Late Binding 테이블 후매칭부 — 입장 후 실제 테이블과 세션 연결.';

comment on function catchmenu_pos.expire_session(
  uuid, uuid, uuid, text, text
) is
  'Expires or marks no-show for a session.
   Releases bound table to CLEANING status.
   NO_SHOW updates arrival_reliability_score downward.
   특허2: 노쇼 이력 기반 KDS 투입 시점 제어 데이터 생성.';

-- ===== END sql/migrations/0025_create_session_rpc.sql =====


-- ===== BEGIN sql/migrations/0026_create_order_rpc.sql =====

-- 0026_create_order_rpc.sql
-- Purpose: Order creation and confirmation RPCs.
--          create_order: creates order from confirmed session cart.
--          confirm_order: confirms order and triggers KDS ticket creation.
--          cancel_order: cancels order with reason and audit trail.
--          특허1: 주문 세션 → 주문 확정 → KDS 전달 경계.
-- Depends on: 0025_create_session_rpc.sql
-- Creates:
--   function catchmenu_pos.create_order(...)
--   function catchmenu_pos.confirm_order(...)
--   function catchmenu_pos.cancel_order(...)

create or replace function catchmenu_pos.create_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_order_type text,
  p_order_channel text,
  p_items jsonb,
  p_memo text default null,
  p_special_requests text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_session record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_final_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_item_amount int;
  v_options_amount int;
  v_kitchen_zone_summary jsonb := '{}'::jsonb;
  v_business_day date;
  v_timezone text;
  v_order_count int;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- session validation
  select id, session_type, session_status,
         table_id, guest_count, guest_locale,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in (
    'SEATED', 'ORDERING', 'WAITING', 'ORDER_CONFIRMED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_orderable',
      'current_status', v_session.session_status
    );
  end if;

  -- items validation
  if p_items is null or jsonb_array_length(p_items) = 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_items_required'
    );
  end if;

  -- generate order number (daily sequential per store)
  select count(*) + 1
  into v_order_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := lpad(v_order_count::text, 4, '0');

  -- create order header
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id, table_id,
    order_number, order_type, order_status,
    order_channel, guest_count, guest_locale,
    memo, special_requests,
    total_amount, discount_amount, final_amount,
    ordered_at, correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    v_session.table_id,
    v_order_number, p_order_type, 'PENDING',
    p_order_channel,
    v_session.guest_count,
    v_session.guest_locale,
    p_memo, p_special_requests,
    0, 0, 0,
    now(), p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- process each order item
  for v_item in select * from jsonb_array_elements(p_items)
  loop
    -- fetch menu
    select id, menu_code, menu_name, price,
           kitchen_zone, estimated_minutes,
           is_kds_required, menu_status, allergen_info
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and is_active = true;

    if v_menu.id is null then
      -- rollback by raising exception
      raise exception 'menu_not_found:% ', v_item->>'menu_id';
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      raise exception 'menu_sold_out:%', v_menu.menu_name;
    end if;

    -- calculate amounts
    v_options_amount := coalesce(
      (v_item->>'options_amount')::int, 0
    );
    v_item_amount := (v_menu.price + v_options_amount)
      * (v_item->>'quantity')::int;
    v_total_amount := v_total_amount + v_item_amount;

    -- track kitchen zones
    if v_menu.kitchen_zone is not null then
      v_kitchen_zone_summary := jsonb_set(
        v_kitchen_zone_summary,
        array[v_menu.kitchen_zone],
        to_jsonb(
          coalesce(
            (v_kitchen_zone_summary->>v_menu.kitchen_zone)::int, 0
          ) + (v_item->>'quantity')::int
        )
      );
    end if;

    -- insert order item
    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id, menu_id,
      menu_code_snapshot, menu_name_snapshot,
      unit_price_snapshot, quantity, item_amount,
      selected_options, options_amount,
      kitchen_zone_snapshot, estimated_minutes_snapshot,
      is_kds_required_snapshot,
      allergen_displayed, allergen_locale_displayed,
      item_status, memo
    ) values (
      p_tenant_id, p_store_id, v_order_id, v_menu.id,
      v_menu.menu_code, v_menu.menu_name,
      v_menu.price,
      (v_item->>'quantity')::int,
      v_item_amount,
      coalesce(v_item->'selected_options', '[]'::jsonb),
      v_options_amount,
      v_menu.kitchen_zone,
      v_menu.estimated_minutes,
      v_menu.is_kds_required,
      coalesce((v_item->>'allergen_displayed')::boolean, false),
      v_item->>'allergen_locale',
      'PENDING',
      v_item->>'memo'
    );
  end loop;

  -- update order totals
  v_final_amount := v_total_amount;
  update catchmenu_pos.orders
  set
    total_amount = v_total_amount,
    final_amount = v_final_amount,
    kitchen_zone_summary = v_kitchen_zone_summary,
    updated_at = now()
  where id = v_order_id;

  -- update session order_id
  update catchmenu_pos.order_sessions
  set
    order_id = v_order_id,
    session_status = 'ORDERING',
    updated_at = now()
  where id = p_session_id;

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_order_id,
    'order_created', null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'item_count', jsonb_array_length(p_items),
      'total_amount', v_total_amount,
      'kitchen_zones', v_kitchen_zone_summary
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'order_created', 1,
    'order', v_order_id,
    null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'total_amount', v_total_amount,
      'item_count', jsonb_array_length(p_items),
      'order_number', v_order_number
    ),
    p_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'order_status', 'PENDING',
    'total_amount', v_total_amount,
    'final_amount', v_final_amount,
    'item_count', jsonb_array_length(p_items),
    'kitchen_zone_summary', v_kitchen_zone_summary
  );

exception
  when others then
    return jsonb_build_object(
      'success', false,
      'error_key', split_part(sqlerrm, ':', 1),
      'error_detail', split_part(sqlerrm, ':', 2)
    );
end;
$$;


create or replace function catchmenu_pos.confirm_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_order record;
  v_item record;
  v_ticket_id uuid;
  v_ticket_number text;
  v_ticket_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_audit_id uuid;
begin
  -- order validation
  select id, order_status, session_id, table_id,
         order_number, total_amount, final_amount,
         order_channel, business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  if v_order.order_status not in ('PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_confirmable',
      'current_status', v_order.order_status
    );
  end if;

  -- confirm order
  update catchmenu_pos.orders
  set
    order_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- update session status
  update catchmenu_pos.order_sessions
  set
    session_status = 'ORDER_CONFIRMED',
    order_confirmed_at = now(),
    updated_at = now()
  where id = v_order.session_id;

  -- create KDS tickets for each item that requires kitchen
  -- tickets start in HOLD state (특허2)
  for v_item in
    select id, menu_name_snapshot, quantity,
           kitchen_zone_snapshot, estimated_minutes_snapshot,
           is_kds_required_snapshot, unit_price_snapshot
    from catchmenu_pos.order_items
    where order_id = p_order_id
      and is_kds_required_snapshot = true
      and item_status = 'PENDING'
  loop
    v_ticket_count := v_ticket_count + 1;
    v_ticket_number := v_order.order_number || '-' ||
                       lpad(v_ticket_count::text, 2, '0');

    insert into catchmenu_kds.kds_tickets (
      tenant_id, store_id,
      order_id, order_item_id, session_id,
      ticket_number,
      kds_status, hold_reason,
      kitchen_zone, priority,
      menu_name_snapshot, quantity_snapshot,
      estimated_minutes_snapshot,
      conditions_met,
      first_hold_at,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      p_order_id, v_item.id, v_order.session_id,
      v_ticket_number,
      -- 특허2: 모든 KDS 티켓은 HOLD 상태로 시작
      'HOLD', 'AWAITING_CONDITIONS',
      v_item.kitchen_zone_snapshot,
      5,
      v_item.menu_name_snapshot,
      v_item.quantity,
      v_item.estimated_minutes_snapshot,
      -- initial conditions: all false
      jsonb_build_object(
        'arrived', v_order.session_id is not null,
        'table_confirmed', v_order.table_id is not null,
        'payment_confirmed', false,
        'kds_capacity_ok', false,
        'menu_available', true,
        'peak_time_ok', true,
        'no_show_risk_ok', true
      ),
      now(),
      v_order.business_day, v_order.business_timezone
    )
    returning id into v_ticket_id;

    v_ticket_ids := v_ticket_ids || to_jsonb(v_ticket_id);

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id,
      ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      conditions_at_event,
      event_payload, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      v_ticket_id, p_order_id,
      'ticket_created', null, 'HOLD',
      'SYSTEM',
      jsonb_build_object(
        'payment_confirmed', false,
        'kds_capacity_ok', false
      ),
      jsonb_build_object(
        'ticket_number', v_ticket_number,
        'kitchen_zone', v_item.kitchen_zone_snapshot,
        'hold_reason', 'AWAITING_CONDITIONS'
      ),
      now()
    );
  end loop;

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_confirmed', 'PENDING', 'CONFIRMED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_created', v_ticket_count,
      'ticket_ids', v_ticket_ids,
      'all_tickets_in_hold', true
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'order_confirmed', 1,
    'order', p_order_id,
    'PENDING', 'CONFIRMED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'payment_required', true
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_confirmed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'total_amount', v_order.total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_tickets_in_hold', true
    ),
    p_before_state := jsonb_build_object('order_status', 'PENDING'),
    p_after_state := jsonb_build_object(
      'order_status', 'CONFIRMED',
      'kds_ticket_count', v_ticket_count
    ),
    p_order_id := p_order_id,
    p_session_id := v_order.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_order.business_day,
    p_business_timezone := v_order.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'order_status', 'CONFIRMED',
    'kds_tickets_created', v_ticket_count,
    'ticket_ids', v_ticket_ids,
    'all_tickets_in_hold', true,
    'next_step', 'PAYMENT_REQUIRED',
    'message_code', 'order_confirmed_payment_required',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_pos.cancel_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_cancel_reason text,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_order record;
  v_cancelled_tickets int;
  v_audit_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select id, order_status, session_id,
         order_number, final_amount,
         business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  if v_order.order_status in (
    'COMPLETED', 'CANCELLED', 'REFUNDED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_already_terminal',
      'current_status', v_order.order_status
    );
  end if;

  -- cancel order
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- cancel all HOLD/CAPACITY_CHECKING KDS tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING', 'COMMITTED');

  get diagnostics v_cancelled_tickets = row_count;

  -- cancel order items
  update catchmenu_pos.order_items
  set
    item_status = 'CANCELLED',
    updated_at = now()
  where order_id = p_order_id
    and item_status not in ('SERVED', 'CANCELLED');

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_cancelled',
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_kds_tickets', v_cancelled_tickets
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'order_cancelled', 1,
    'order', p_order_id,
    v_order.order_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_kds_tickets', v_cancelled_tickets
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_cancelled',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'cancelled_kds_tickets', v_cancelled_tickets
    ),
    p_before_state := jsonb_build_object(
      'order_status', v_order.order_status
    ),
    p_after_state := jsonb_build_object(
      'order_status', 'CANCELLED'
    ),
    p_order_id := p_order_id,
    p_session_id := v_order.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_order.business_day,
    p_business_timezone := v_order.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'order_status', 'CANCELLED',
    'cancelled_kds_tickets', v_cancelled_tickets,
    'cancel_reason', p_cancel_reason,
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
revoke all on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) from public;
grant execute on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) to authenticated;

revoke all on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) to authenticated;

revoke all on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) from public;
grant execute on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) to authenticated;

comment on function catchmenu_pos.create_order(
  uuid, uuid, uuid, text, text, jsonb, text, text, text
) is
  'Creates order from session cart.
   Validates all menu items availability before creating.
   Captures price snapshots at order time — never recalculated.
   Captures allergen display evidence per item.
   특허1: 주문 세션과 주문의 분리 — 세션은 주문 전에 독립 존재.';

comment on function catchmenu_pos.confirm_order(
  uuid, uuid, uuid, text, uuid, text
) is
  'Confirms order and creates KDS tickets in HOLD state.
   All KDS tickets start HOLD — never immediately sent to kitchen.
   payment_confirmed condition starts false.
   KDS tickets only commit after all conditions_met are true.
   특허2: 주문 확정 → KDS 티켓 생성 (HOLD) → 조건 충족 후 조리 큐 투입.
   특허1: 결제 확인 없이 KDS 릴리즈 금지.';

comment on function catchmenu_pos.cancel_order(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Cancels order and all cancellable KDS tickets.
   Tickets in COOKING or READY state are not cancelled — staff must handle.
   Cancel reason is mandatory and recorded in audit ledger.
   특허4: 모든 취소 행위는 감사 원장에 기록.';

-- ===== END sql/migrations/0026_create_order_rpc.sql =====


-- ===== BEGIN sql/migrations/0049_create_store_settings_rpc.sql =====

-- 0049_create_store_settings_rpc.sql
-- Purpose: Store operational settings management RPCs.
--          get_store_settings: returns all operational settings.
--          update_business_hours: updates store operating hours.
--          toggle_store_mode: switches store between operational modes.
--          update_kds_capacity_threshold: adjusts KDS capacity limits.
--          특허2: KDS 수용상태 임계값 관리.
-- Depends on: 0048_create_table_management_rpc.sql
-- Creates:
--   catchmenu_store.store_settings (table)
--   function catchmenu_store.get_store_settings(...)
--   function catchmenu_store.update_business_hours(...)
--   function catchmenu_store.toggle_store_mode(...)
--   function catchmenu_store.update_kds_capacity_threshold(...)

-- store settings table
create table if not exists catchmenu_store.store_settings (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- operational mode
  store_mode text not null default 'NORMAL',
  mode_changed_at timestamptz,
  mode_changed_by uuid,
  mode_change_reason text,

  -- KDS capacity thresholds (특허2)
  kds_capacity_threshold_per_zone int not null default 8,
  kds_capacity_threshold_total int not null default 30,
  kds_peak_time_threshold int not null default 6,

  -- pre-order settings (특허2)
  pre_order_enabled boolean not null default true,
  pre_order_lead_minutes int not null default 15,
  pre_order_expire_minutes int not null default 30,
  arrival_reliability_threshold int not null default 60,

  -- waiting settings
  waiting_enabled boolean not null default true,
  max_wait_number int not null default 999,
  wait_call_expire_minutes int not null default 5,
  no_show_auto_expire_minutes int not null default 10,

  -- payment settings
  payment_uncertain_auto_resolve_minutes int
    not null default 10,
  kds_release_auto_authorize boolean
    not null default false,

  -- peak time definition
  peak_time_ranges jsonb not null default '[]'::jsonb,

  -- notification settings
  did_refresh_interval_seconds int not null default 10,
  staff_alert_enabled boolean not null default true,
  sound_alert_enabled boolean not null default true,

  -- business hours override
  business_hours_override jsonb,
  holiday_mode boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_store_settings unique (store_id),
  constraint chk_store_mode check (
    store_mode in (
      'NORMAL',
      'PEAK',
      'LIMITED',
      'TAKEOUT_ONLY',
      'DELIVERY_ONLY',
      'CLOSING',
      'CLOSED',
      'EMERGENCY'
    )
  ),
  constraint chk_kds_threshold check (
    kds_capacity_threshold_per_zone > 0
    and kds_capacity_threshold_total > 0
    and kds_peak_time_threshold > 0
  ),
  constraint chk_pre_order_minutes check (
    pre_order_lead_minutes > 0
    and pre_order_expire_minutes > 0
  ),
  constraint chk_peak_time_array check (
    jsonb_typeof(peak_time_ranges) = 'array'
  )
);

create index if not exists idx_store_settings_store
  on catchmenu_store.store_settings(store_id);

alter table catchmenu_store.store_settings
  enable row level security;
alter table catchmenu_store.store_settings
  force row level security;

drop policy if exists store_settings_isolation
  on catchmenu_store.store_settings;
create policy store_settings_isolation
  on catchmenu_store.store_settings
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_store_settings_updated_at
  on catchmenu_store.store_settings;
create trigger trg_store_settings_updated_at
  before update on catchmenu_store.store_settings
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.store_settings is
  'Operational settings per store.
   KDS capacity thresholds control Late Binding commit decisions.
   Pre-order settings control waiting session behavior.
   특허2: KDS 수용상태 임계값 — commit_kds_ticket의 판단 기준.';


-- helper: ensure settings row exists
create or replace function catchmenu_store.ensure_store_settings(
  p_tenant_id uuid,
  p_store_id uuid
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_hq
as $$
declare
  v_id uuid;
begin
  select id into v_id
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_id is null then
    insert into catchmenu_store.store_settings (
      tenant_id, store_id
    ) values (
      p_tenant_id, p_store_id
    )
    returning id into v_id;
  end if;

  return v_id;
end;
$$;


create or replace function catchmenu_store.get_store_settings(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_settings record;
  v_store record;
begin
  select id, store_name, timezone, store_status
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  -- ensure settings exist
  perform catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select *
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'timezone', v_store.timezone,
      'store_status', v_store.store_status
    ),
    'operational_mode', jsonb_build_object(
      'store_mode', v_settings.store_mode,
      'mode_changed_at', v_settings.mode_changed_at,
      'mode_change_reason', v_settings.mode_change_reason,
      'holiday_mode', v_settings.holiday_mode
    ),
    'kds_settings', jsonb_build_object(
      'capacity_threshold_per_zone',
        v_settings.kds_capacity_threshold_per_zone,
      'capacity_threshold_total',
        v_settings.kds_capacity_threshold_total,
      'peak_time_threshold',
        v_settings.kds_peak_time_threshold,
      'release_auto_authorize',
        v_settings.kds_release_auto_authorize
    ),
    'pre_order_settings', jsonb_build_object(
      'enabled', v_settings.pre_order_enabled,
      'lead_minutes', v_settings.pre_order_lead_minutes,
      'expire_minutes', v_settings.pre_order_expire_minutes,
      'arrival_reliability_threshold',
        v_settings.arrival_reliability_threshold
    ),
    'waiting_settings', jsonb_build_object(
      'enabled', v_settings.waiting_enabled,
      'max_wait_number', v_settings.max_wait_number,
      'wait_call_expire_minutes',
        v_settings.wait_call_expire_minutes,
      'no_show_auto_expire_minutes',
        v_settings.no_show_auto_expire_minutes
    ),
    'payment_settings', jsonb_build_object(
      'uncertain_auto_resolve_minutes',
        v_settings.payment_uncertain_auto_resolve_minutes
    ),
    'peak_time_ranges', v_settings.peak_time_ranges,
    'notification_settings', jsonb_build_object(
      'did_refresh_interval_seconds',
        v_settings.did_refresh_interval_seconds,
      'staff_alert_enabled',
        v_settings.staff_alert_enabled,
      'sound_alert_enabled',
        v_settings.sound_alert_enabled
    ),
    'business_hours_override',
      v_settings.business_hours_override,
    'updated_at', v_settings.updated_at,
    'message_code', 'store_settings_loaded'
  );
end;
$$;


create or replace function catchmenu_store.update_business_hours(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_hours jsonb,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings_id uuid;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
begin
  if p_business_hours is null
    or jsonb_typeof(p_business_hours) <> 'object'
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'business_hours_must_be_object'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  update catchmenu_store.store_settings
  set
    business_hours_override = p_business_hours,
    updated_at = now()
  where id = v_settings_id;

  -- also update main store record
  update catchmenu_hq.stores
  set
    business_hours = p_business_hours,
    updated_at = now()
  where id = p_store_id
    and tenant_id = p_tenant_id;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'store',
    p_audit_type := 'business_hours_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'business_hours', p_business_hours
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'business_hours', p_business_hours,
    'audit_id', v_audit_id,
    'message_code', 'business_hours_updated'
  );
end;
$$;


create or replace function catchmenu_store.toggle_store_mode(
  p_tenant_id uuid,
  p_store_id uuid,
  p_new_mode text,
  p_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_settings_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_mode not in (
    'NORMAL', 'PEAK', 'LIMITED',
    'TAKEOUT_ONLY', 'DELIVERY_ONLY',
    'CLOSING', 'CLOSED', 'EMERGENCY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_store_mode'
    );
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select store_mode into v_settings
  from catchmenu_store.store_settings
  where id = v_settings_id
  for update;

  -- update mode
  update catchmenu_store.store_settings
  set
    store_mode = p_new_mode,
    mode_changed_at = now(),
    mode_changed_by = p_actor_id,
    mode_change_reason = p_reason,
    -- auto-adjust settings for specific modes
    pre_order_enabled = case p_new_mode
      when 'CLOSING' then false
      when 'CLOSED' then false
      when 'EMERGENCY' then false
      else pre_order_enabled
    end,
    waiting_enabled = case p_new_mode
      when 'TAKEOUT_ONLY' then false
      when 'DELIVERY_ONLY' then false
      when 'CLOSING' then false
      when 'CLOSED' then false
      when 'EMERGENCY' then false
      else waiting_enabled
    end,
    updated_at = now()
  where id = v_settings_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'system', 'store_mode_changed', 1,
    'store', p_store_id,
    v_settings.store_mode, p_new_mode,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'previous_mode', v_settings.store_mode,
      'new_mode', p_new_mode,
      'reason', p_reason
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'system',
    p_audit_type := 'store_mode_changed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store',
    p_subject_id := p_store_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object(
      'previous_mode', v_settings.store_mode,
      'new_mode', p_new_mode
    ),
    p_before_state := jsonb_build_object(
      'store_mode', v_settings.store_mode
    ),
    p_after_state := jsonb_build_object(
      'store_mode', p_new_mode
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'previous_mode', v_settings.store_mode,
    'new_mode', p_new_mode,
    'reason', p_reason,
    'audit_id', v_audit_id,
    'message_code', 'store_mode_changed'
  );
end;
$$;


create or replace function catchmenu_store.update_kds_capacity_threshold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_threshold_per_zone int default null,
  p_threshold_total int default null,
  p_peak_time_threshold int default null,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_settings_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- at least one threshold required
  if p_threshold_per_zone is null
    and p_threshold_total is null
    and p_peak_time_threshold is null
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'at_least_one_threshold_required'
    );
  end if;

  -- validate ranges
  if p_threshold_per_zone is not null
    and p_threshold_per_zone not between 1 and 50
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'threshold_per_zone_out_of_range',
      'allowed_range', '1-50'
    );
  end if;

  if p_threshold_total is not null
    and p_threshold_total not between 1 and 200
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'threshold_total_out_of_range',
      'allowed_range', '1-200'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_settings_id := catchmenu_store.ensure_store_settings(
    p_tenant_id, p_store_id
  );

  select
    kds_capacity_threshold_per_zone,
    kds_capacity_threshold_total,
    kds_peak_time_threshold
  into v_settings
  from catchmenu_store.store_settings
  where id = v_settings_id
  for update;

  update catchmenu_store.store_settings
  set
    kds_capacity_threshold_per_zone = coalesce(
      p_threshold_per_zone,
      kds_capacity_threshold_per_zone
    ),
    kds_capacity_threshold_total = coalesce(
      p_threshold_total,
      kds_capacity_threshold_total
    ),
    kds_peak_time_threshold = coalesce(
      p_peak_time_threshold,
      kds_peak_time_threshold
    ),
    updated_at = now()
  where id = v_settings_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_threshold_updated', 1,
    'store_settings', v_settings_id,
    null, 'UPDATED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'previous', jsonb_build_object(
        'per_zone',
          v_settings.kds_capacity_threshold_per_zone,
        'total',
          v_settings.kds_capacity_threshold_total,
        'peak_time',
          v_settings.kds_peak_time_threshold
      ),
      'new', jsonb_build_object(
        'per_zone', coalesce(
          p_threshold_per_zone,
          v_settings.kds_capacity_threshold_per_zone
        ),
        'total', coalesce(
          p_threshold_total,
          v_settings.kds_capacity_threshold_total
        ),
        'peak_time', coalesce(
          p_peak_time_threshold,
          v_settings.kds_peak_time_threshold
        )
      )
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_threshold_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'store_settings',
    p_subject_id := v_settings_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'threshold_per_zone', coalesce(
        p_threshold_per_zone,
        v_settings.kds_capacity_threshold_per_zone
      ),
      'threshold_total', coalesce(
        p_threshold_total,
        v_settings.kds_capacity_threshold_total
      ),
      'peak_time_threshold', coalesce(
        p_peak_time_threshold,
        v_settings.kds_peak_time_threshold
      )
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'thresholds', jsonb_build_object(
      'per_zone', coalesce(
        p_threshold_per_zone,
        v_settings.kds_capacity_threshold_per_zone
      ),
      'total', coalesce(
        p_threshold_total,
        v_settings.kds_capacity_threshold_total
      ),
      'peak_time', coalesce(
        p_peak_time_threshold,
        v_settings.kds_peak_time_threshold
      )
    ),
    'audit_id', v_audit_id,
    'message_code', 'kds_threshold_updated'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.ensure_store_settings(
    uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.ensure_store_settings(
    uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_store.get_store_settings(
    uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.get_store_settings(
    uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_store.update_business_hours(
    uuid, uuid, jsonb, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_business_hours(
    uuid, uuid, jsonb, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.toggle_store_mode(
    uuid, uuid, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.toggle_store_mode(
    uuid, uuid, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.update_kds_capacity_threshold(
    uuid, uuid, int, int, int, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_kds_capacity_threshold(
    uuid, uuid, int, int, int, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.toggle_store_mode(
  uuid, uuid, text, text, text, uuid, text
) is
  'Switches store between operational modes.
   NORMAL = standard operation.
   PEAK = high demand, KDS thresholds tightened.
   LIMITED = reduced capacity, some features disabled.
   TAKEOUT_ONLY = no dine-in, waiting disabled.
   DELIVERY_ONLY = delivery only.
   CLOSING = approaching close, no new waiting/pre-orders.
   CLOSED = store closed.
   EMERGENCY = emergency closure, all operations suspended.
   특허4: 무장애 운영 — 장애 시 운영 모드 전환 구조.
   Agent SOP Selection이 장애 유형에 따라 이 RPC를 추천.';

comment on function catchmenu_store.update_kds_capacity_threshold(
  uuid, uuid, int, int, int, text, uuid, text
) is
  'Adjusts KDS capacity thresholds used in Late Binding decisions.
   per_zone: max tickets COOKING per kitchen station (default 8).
   total: max tickets across all zones (default 30).
   peak_time: tighter threshold during peak hours (default 6).
   Changes take effect immediately on next commit_kds_ticket call.
   특허2: KDS 수용상태 임계값 동적 조정.
   피크타임/특별이벤트 시 임계값을 낮춰 과부하 방지.';

-- ===== END sql/migrations/0049_create_store_settings_rpc.sql =====


-- ===== BEGIN sql/migrations/0050_create_waiting_queue_rpc.sql =====

-- 0050_create_waiting_queue_rpc.sql
-- Purpose: Waiting queue management RPCs.
--          get_waiting_queue: returns current queue state.
--          call_next_waiting: calls next customer in queue.
--          update_queue_position: reorders queue manually.
--          mark_no_show: marks customer as no-show.
--          estimate_wait_time: estimates wait time for new customer.
--          특허1 core: 대기열 관리 + Late Binding 연결점.
-- Depends on: 0049_create_store_settings_rpc.sql
-- Creates:
--   function catchmenu_pos.get_waiting_queue(...)
--   function catchmenu_pos.call_next_waiting(...)
--   function catchmenu_pos.update_queue_position(...)
--   function catchmenu_pos.mark_no_show(...)
--   function catchmenu_pos.estimate_wait_time(...)

create or replace function catchmenu_pos.get_waiting_queue(
  p_tenant_id uuid,
  p_store_id uuid,
  p_include_arrived boolean default true
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_store record;
  v_queue jsonb;
  v_summary jsonb;
  v_business_day date;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_business_day := (timezone(v_store.timezone, now()))::date;

  -- queue entries
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', s.id,
        'wait_number', s.wait_number,
        'queue_position', s.queue_position,
        'session_status', s.session_status,
        'session_type', s.session_type,
        'guest_count', s.guest_count,
        'guest_locale', s.guest_locale,
        'session_started_at', s.session_started_at,
        'arrived_at', s.arrived_at,
        'pre_order_created_at', s.pre_order_created_at,
        'arrival_reliability_score',
          s.arrival_reliability_score,
        'wait_minutes', extract(
          epoch from (now() - s.session_started_at)
        )::int / 60,
        'has_pre_order', s.pre_order_created_at is not null,
        'order_id', s.order_id,
        'expires_at', s.expires_at
      )
      order by
        case s.session_status
          when 'ARRIVAL_PENDING' then 0
          when 'WAITING' then 1
          else 2
        end,
        coalesce(s.queue_position, s.wait_number) asc nulls last,
        s.session_started_at asc
    ),
    '[]'::jsonb
  )
  into v_queue
  from catchmenu_pos.order_sessions s
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.business_day = v_business_day
    and (
      s.session_status = 'WAITING'
      or (
        p_include_arrived = true
        and s.session_status = 'ARRIVAL_PENDING'
      )
    )
    and s.session_type in ('WAITING', 'PRE_ORDER');

  -- summary
  select jsonb_build_object(
    'total_waiting', count(*) filter (
      where session_status = 'WAITING'
    ),
    'arrival_pending', count(*) filter (
      where session_status = 'ARRIVAL_PENDING'
    ),
    'with_pre_order', count(*) filter (
      where pre_order_created_at is not null
        and session_status in (
          'WAITING', 'ARRIVAL_PENDING'
        )
    ),
    'next_wait_number', coalesce(
      max(wait_number) + 1, 1
    ),
    'avg_wait_minutes', coalesce(
      avg(
        extract(
          epoch from (now() - session_started_at)
        ) / 60
      ) filter (
        where session_status = 'WAITING'
      )::int,
      0
    )
  )
  into v_summary
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and session_type in ('WAITING', 'PRE_ORDER');

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'queue', v_queue,
    'summary', v_summary,
    'business_day', v_business_day,
    'refreshed_at', now(),
    'message_code', 'waiting_queue_loaded'
  );
end;
$$;


create or replace function catchmenu_pos.call_next_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_specific_session_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
  v_expire_at timestamptz;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- find next session to call
  if p_specific_session_id is not null then
    select id, session_status, wait_number,
           guest_count, guest_locale,
           pre_order_created_at, order_id
    into v_session
    from catchmenu_pos.order_sessions
    where id = p_specific_session_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and session_status = 'WAITING'
    for update;
  else
    -- auto-select next in queue
    select id, session_status, wait_number,
           guest_count, guest_locale,
           pre_order_created_at, order_id
    into v_session
    from catchmenu_pos.order_sessions
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and session_status = 'WAITING'
      and session_type in ('WAITING', 'PRE_ORDER')
    order by
      coalesce(queue_position, wait_number) asc nulls last,
      session_started_at asc
    limit 1
    for update skip locked;
  end if;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_waiting_session_found',
      'message_code', 'queue_empty'
    );
  end if;

  -- get no-show expire time from settings
  select now() + (
    coalesce(
      ss.no_show_auto_expire_minutes, 10
    ) || ' minutes'
  )::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id
    and ss.tenant_id = p_tenant_id;

  v_expire_at := coalesce(
    v_expire_at, now() + interval '10 minutes'
  );

  -- update session to ARRIVAL_PENDING
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = v_expire_at,
    updated_at = now()
  where id = v_session.id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_session.id,
    'customer_called',
    'WAITING', 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'expires_at', v_expire_at,
      'has_pre_order',
        v_session.pre_order_created_at is not null
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'customer_called', 1,
    'order_session', v_session.id,
    'WAITING', 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'expires_at', v_expire_at,
      'guest_count', v_session.guest_count,
      'has_pre_order',
        v_session.pre_order_created_at is not null
    ),
    v_session.id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session.id,
    'wait_number', v_session.wait_number,
    'session_status', 'ARRIVAL_PENDING',
    'guest_count', v_session.guest_count,
    'guest_locale', v_session.guest_locale,
    'has_pre_order',
      v_session.pre_order_created_at is not null,
    'order_id', v_session.order_id,
    'expires_at', v_expire_at,
    'message_code', 'customer_called'
  );
end;
$$;


create or replace function catchmenu_pos.update_queue_position(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_new_position int,
  p_reason text,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if p_new_position < 1 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_position',
      'message', 'Position must be >= 1'
    );
  end if;

  if trim(coalesce(p_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, wait_number, queue_position,
         session_status, guest_count
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_status = 'WAITING'
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found_or_not_waiting'
    );
  end if;

  -- update position
  update catchmenu_pos.order_sessions
  set
    queue_position = p_new_position,
    updated_at = now()
  where id = p_session_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'queue_position_updated', 1,
    'order_session', p_session_id,
    coalesce(
      v_session.queue_position::text, 'null'
    ),
    p_new_position::text,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_position', v_session.queue_position,
      'new_position', p_new_position,
      'reason', p_reason
    ),
    p_session_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'queue_position_updated',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'OVERRIDDEN',
    p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_position', v_session.queue_position,
      'new_position', p_new_position
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'wait_number', v_session.wait_number,
    'previous_position', v_session.queue_position,
    'new_position', p_new_position,
    'reason', p_reason,
    'audit_id', v_audit_id,
    'message_code', 'queue_position_updated'
  );
end;
$$;


create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_session record;
  v_business_day date;
  v_timezone text;
  v_new_score int;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, session_status, wait_number,
         arrival_reliability_score,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_markable',
      'current_status', v_session.session_status
    );
  end if;

  -- decrease arrival reliability score
  -- 특허2: 노쇼 이력 → arrival_reliability_score 하락
  -- → KDS no_show_risk_ok 조건 판단에 영향
  v_new_score := greatest(
    0,
    coalesce(v_session.arrival_reliability_score, 100) - 20
  );

  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    arrival_reliability_score = v_new_score,
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'no_show_marked',
    v_session.session_status, 'NO_SHOW',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'previous_score',
        v_session.arrival_reliability_score,
      'new_score', v_new_score,
      'score_penalty', 20
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'no_show_marked', 1,
    'order_session', p_session_id,
    v_session.session_status, 'NO_SHOW',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'arrival_reliability_score_new', v_new_score,
      'score_penalty_applied', 20
    ),
    p_session_id, p_correlation_id,
    v_session.business_day, v_session.business_timezone,
    now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'wait_number', v_session.wait_number,
    'session_status', 'NO_SHOW',
    'arrival_reliability_score', v_new_score,
    'score_penalty', 20,
    'message_code', 'no_show_marked'
  );
end;
$$;


create or replace function catchmenu_pos.estimate_wait_time(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int default 1
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_timezone text;
  v_business_day date;
  v_queue_length int;
  v_avg_session_minutes numeric;
  v_available_tables int;
  v_suitable_tables int;
  v_estimated_minutes int;
  v_next_wait_number int;
  v_settings record;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- current queue length
  select count(*)
  into v_queue_length
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  -- average session duration today (seated to completed)
  select coalesce(
    avg(
      extract(epoch from (
        completed_at - seated_at
      )) / 60
    ) filter (
      where seated_at is not null
        and completed_at is not null
    ),
    45
  )::int
  into v_avg_session_minutes
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status = 'COMPLETED';

  -- available tables that can seat guest_count
  select
    count(*) filter (
      where table_status = 'AVAILABLE'
        and capacity >= p_guest_count
    ),
    count(*) filter (
      where capacity >= p_guest_count
    )
  into v_available_tables, v_suitable_tables
  from catchmenu_store.dining_tables
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- estimate wait time
  v_estimated_minutes := case
    when v_available_tables > 0 then 0
    when v_suitable_tables = 0 then -1 -- no suitable tables
    when v_queue_length = 0 then 5
    else (
      v_queue_length * v_avg_session_minutes
      / greatest(v_suitable_tables, 1)
    )::int
  end;

  -- next wait number
  select coalesce(max(wait_number), 0) + 1
  into v_next_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- get settings
  select waiting_enabled, pre_order_enabled
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'guest_count', p_guest_count,
    'estimated_wait_minutes', v_estimated_minutes,
    'can_seat_immediately', v_available_tables > 0,
    'queue_length', v_queue_length,
    'next_wait_number', v_next_wait_number,
    'available_tables', v_available_tables,
    'avg_session_minutes', v_avg_session_minutes,
    'waiting_enabled', coalesce(
      v_settings.waiting_enabled, true
    ),
    'pre_order_enabled', coalesce(
      v_settings.pre_order_enabled, true
    ),
    'message_code', case
      when v_suitable_tables = 0
      then 'no_suitable_tables'
      when v_available_tables > 0
      then 'table_available_now'
      else 'estimated_wait_time'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.get_waiting_queue(
    uuid, uuid, boolean
  ) from public;
  grant execute on function catchmenu_pos.get_waiting_queue(
    uuid, uuid, boolean
  ) to authenticated;

  revoke all on function catchmenu_pos.call_next_waiting(
    uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.call_next_waiting(
    uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.update_queue_position(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.update_queue_position(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.mark_no_show(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.mark_no_show(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.estimate_wait_time(
    uuid, uuid, int
  ) from public;
  grant execute on function catchmenu_pos.estimate_wait_time(
    uuid, uuid, int
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.get_waiting_queue(
  uuid, uuid, boolean
) is
  'Returns current waiting queue state.
   ARRIVAL_PENDING sessions shown first (already called).
   WAITING sessions follow in queue position order.
   Shows pre-order flag for each session.
   특허1: 대기열 현황 — 대기번호/호출상태/선주문 여부 조회.';

comment on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) is
  'Calls next customer in waiting queue.
   Transitions WAITING → ARRIVAL_PENDING.
   Sets expiry time from store settings no_show_auto_expire_minutes.
   Auto-selects by queue_position or wait_number if not specified.
   특허1: 대기 호출 → ARRIVAL_PENDING → Late Binding 준비 상태.';

comment on function catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
) is
  'Marks called customer as no-show.
   Decreases arrival_reliability_score by 20 points.
   Score affects KDS Late Binding no_show_risk_ok condition.
   특허2: 노쇼 이력 → arrival_reliability_score 하락
          → KDS no_show_risk_ok 조건 판단 강화.';

comment on function catchmenu_pos.estimate_wait_time(
  uuid, uuid, int
) is
  'Estimates wait time for new customer.
   Uses: current queue length + avg session duration + available tables.
   Returns 0 if table immediately available.
   Returns -1 if no suitable tables for guest_count.
   Used by customer app and entrance display.
   특허1: 고객 입장 전 대기 시간 예측 — 선주문 결정 지원.';

-- ===== END sql/migrations/0050_create_waiting_queue_rpc.sql =====


-- ===== BEGIN sql/migrations/0051_create_pre_order_rpc.sql =====

-- 0051_create_pre_order_rpc.sql
-- Purpose: Pre-order management RPCs.
--          create_pre_order: creates order before customer arrives.
--          confirm_pre_order_arrival: confirms arrival and triggers Late Binding.
--          cancel_pre_order: cancels pre-order before arrival.
--          get_pre_order_status: returns pre-order and KDS state.
--          특허2 core: 사전주문 → HOLD → 조건 충족 시 KDS 투입.
-- Depends on: 0050_create_waiting_queue_rpc.sql
-- Creates:
--   function catchmenu_pos.create_pre_order(...)
--   function catchmenu_pos.confirm_pre_order_arrival(...)
--   function catchmenu_pos.cancel_pre_order(...)
--   function catchmenu_pos.get_pre_order_status(...)

create or replace function catchmenu_pos.create_pre_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_items jsonb,
  p_memo text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_settings record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_item_amount int;
  v_ticket_count int := 0;
  v_kitchen_zone_summary jsonb := '{}'::jsonb;
  v_business_day date;
  v_timezone text;
  v_order_count int;
  v_expire_at timestamptz;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- validate session
  select id, session_type, session_status,
         wait_number, guest_count, guest_locale,
         arrival_reliability_score,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_pre_orderable',
      'current_status', v_session.session_status
    );
  end if;

  if v_session.session_type not in (
    'WAITING', 'PRE_ORDER'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_type_not_pre_orderable',
      'session_type', v_session.session_type
    );
  end if;

  -- check pre-order settings
  select pre_order_enabled,
         pre_order_expire_minutes,
         arrival_reliability_threshold
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if coalesce(v_settings.pre_order_enabled, true) = false then
    return jsonb_build_object(
      'success', false,
      'error_key', 'pre_order_disabled'
    );
  end if;

  -- check arrival reliability
  if coalesce(
    v_session.arrival_reliability_score, 100
  ) < coalesce(
    v_settings.arrival_reliability_threshold, 60
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'arrival_reliability_too_low',
      'score', v_session.arrival_reliability_score,
      'threshold', v_settings.arrival_reliability_threshold,
      'message', 'Customer no-show history prevents pre-order'
    );
  end if;

  -- validate items
  if p_items is null
    or jsonb_array_length(p_items) = 0
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'items_required'
    );
  end if;

  -- generate order number
  select count(*) + 1
  into v_order_count
  from catchmenu_pos.orders
  where store_id = p_store_id
    and business_day = v_business_day;

  v_order_number := 'P-' || lpad(
    v_order_count::text, 4, '0'
  );

  v_expire_at := now() + (
    coalesce(
      v_settings.pre_order_expire_minutes, 30
    ) || ' minutes'
  )::interval;

  -- create order
  insert into catchmenu_pos.orders (
    tenant_id, store_id, session_id,
    order_number, order_type,
    order_status, order_channel,
    guest_count, guest_locale,
    memo, ordered_at,
    total_amount, discount_amount, final_amount,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    v_order_number, 'DINE_IN',
    'PENDING', 'TABLE_QR',
    v_session.guest_count,
    v_session.guest_locale,
    p_memo, now(),
    0, 0, 0,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- process items and create HOLD KDS tickets
  for v_item in
    select * from jsonb_array_elements(p_items)
  loop
    select id, menu_code, menu_name, price,
           kitchen_zone, estimated_minutes,
           is_kds_required, menu_status,
           prep_complexity, peak_time_restricted
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and is_active = true;

    if v_menu.id is null then
      raise exception 'menu_not_found:%',
        v_item->>'menu_id';
    end if;

    if v_menu.menu_status = 'SOLD_OUT' then
      raise exception 'menu_sold_out:%',
        v_menu.menu_name;
    end if;

    v_item_amount := coalesce(
      (v_item->>'quantity')::int, 1
    ) * v_menu.price;
    v_total_amount := v_total_amount + v_item_amount;

    -- kitchen zone tracking
    if v_menu.kitchen_zone is not null then
      v_kitchen_zone_summary := jsonb_set(
        v_kitchen_zone_summary,
        array[v_menu.kitchen_zone],
        to_jsonb(
          coalesce(
            (v_kitchen_zone_summary
              ->>v_menu.kitchen_zone)::int,
            0
          ) + coalesce(
            (v_item->>'quantity')::int, 1
          )
        )
      );
    end if;

    -- insert order item
    insert into catchmenu_pos.order_items (
      tenant_id, store_id, order_id, menu_id,
      menu_code_snapshot, menu_name_snapshot,
      unit_price_snapshot, quantity, item_amount,
      selected_options, options_amount,
      kitchen_zone_snapshot,
      estimated_minutes_snapshot,
      is_kds_required_snapshot,
      allergen_displayed, item_status
    ) values (
      p_tenant_id, p_store_id, v_order_id, v_menu.id,
      v_menu.menu_code, v_menu.menu_name,
      v_menu.price,
      coalesce((v_item->>'quantity')::int, 1),
      v_item_amount,
      coalesce(v_item->'selected_options', '[]'::jsonb),
      0,
      v_menu.kitchen_zone,
      v_menu.estimated_minutes,
      v_menu.is_kds_required,
      false, 'PENDING'
    );

    -- create KDS ticket in HOLD
    -- 특허2: 사전주문 티켓 = 모든 조건 false로 시작
    if v_menu.is_kds_required then
      v_ticket_count := v_ticket_count + 1;

      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, session_id,
        ticket_number, kds_status,
        hold_reason, kitchen_zone, priority,
        menu_name_snapshot, quantity_snapshot,
        estimated_minutes_snapshot,
        conditions_met,
        first_hold_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, p_session_id,
        v_order_number || '-' ||
          lpad(v_ticket_count::text, 2, '0'),
        'HOLD',
        'PRE_ORDER_WAITING',
        v_menu.kitchen_zone, 5,
        v_menu.menu_name,
        coalesce((v_item->>'quantity')::int, 1),
        v_menu.estimated_minutes,
        -- 특허2: 7개 조건 모두 false로 시작
        jsonb_build_object(
          'arrived', false,
          'table_confirmed', false,
          'payment_confirmed', false,
          'kds_capacity_ok', false,
          'menu_available',
            v_menu.menu_status = 'AVAILABLE',
          'peak_time_ok',
            not v_menu.peak_time_restricted,
          'no_show_risk_ok',
            coalesce(
              v_session.arrival_reliability_score,
              100
            ) >= coalesce(
              v_settings.arrival_reliability_threshold,
              60
            )
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- update order totals
  update catchmenu_pos.orders
  set
    total_amount = v_total_amount,
    final_amount = v_total_amount,
    kitchen_zone_summary = v_kitchen_zone_summary,
    updated_at = now()
  where id = v_order_id;

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_type = 'PRE_ORDER',
    session_status = 'ORDER_CONFIRMED',
    order_id = v_order_id,
    pre_order_created_at = now(),
    pre_order_expires_at = v_expire_at,
    order_confirmed_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'pre_order_created',
    v_session.session_status, 'ORDER_CONFIRMED',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'expires_at', v_expire_at
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'pre_order_created', 1,
    'order', v_order_id,
    null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'order_number', v_order_number,
      'total_amount', v_total_amount,
      'kds_tickets_created', v_ticket_count,
      'all_in_hold', true,
      'wait_number', v_session.wait_number,
      'arrival_reliability_score',
        v_session.arrival_reliability_score
    ),
    p_session_id, v_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'order_id', v_order_id,
    'order_number', v_order_number,
    'session_id', p_session_id,
    'total_amount', v_total_amount,
    'kds_tickets_created', v_ticket_count,
    'all_tickets_in_hold', true,
    'pre_order_expires_at', v_expire_at,
    'wait_number', v_session.wait_number,
    'next_step', 'AWAIT_ARRIVAL_AND_PAYMENT',
    'message_code', 'pre_order_created'
  );

exception
  when others then
    return jsonb_build_object(
      'success', false,
      'error_key', split_part(sqlerrm, ':', 1),
      'error_detail', split_part(sqlerrm, ':', 2)
    );
end;
$$;


create or replace function catchmenu_pos.confirm_pre_order_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_session record;
  v_bind_result jsonb;
  v_tickets_updated int;
begin
  -- validate session
  select id, session_type, session_status,
         order_id, pre_order_expires_at,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_type <> 'PRE_ORDER' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'not_a_pre_order_session',
      'session_type', v_session.session_type
    );
  end if;

  -- check expiry
  if v_session.pre_order_expires_at < now() then
    return jsonb_build_object(
      'success', false,
      'error_key', 'pre_order_expired',
      'expired_at', v_session.pre_order_expires_at
    );
  end if;

  -- Late Binding: bind table to session
  -- 특허1: 도착 확인 시 테이블 후매칭 실행
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := p_table_id,
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not (v_bind_result->>'success')::boolean then
    return v_bind_result;
  end if;

  -- update KDS tickets: arrived + table_confirmed = true
  -- 특허2: 도착 확인 → arrived + table_confirmed 조건 충족
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met
      || jsonb_build_object(
        'arrived', true,
        'table_confirmed', true
      ),
    updated_at = now()
  where order_id = v_session.order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_tickets_updated = row_count;

  -- KDS events for condition update
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type, caused_by_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  )
  select
    p_tenant_id, p_store_id,
    kt.id, v_session.order_id,
    'condition_updated',
    p_actor_type, p_actor_id,
    kt.conditions_met,
    jsonb_build_object(
      'arrived', true,
      'table_confirmed', true,
      'table_id', p_table_id,
      'late_binding_completed', true
    ),
    p_correlation_id, now()
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_session.order_id
    and kt.store_id = p_store_id
    and kt.kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- update order with table
  update catchmenu_pos.orders
  set
    table_id = p_table_id,
    updated_at = now()
  where id = v_session.order_id;

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_session.order_id,
    'table_id', p_table_id,
    'late_binding_completed', true,
    'kds_tickets_updated', v_tickets_updated,
    'conditions_updated', jsonb_build_object(
      'arrived', true,
      'table_confirmed', true
    ),
    'next_step', 'PAYMENT_REQUIRED_FOR_KDS_RELEASE',
    'message_code', 'pre_order_arrival_confirmed'
  );
end;
$$;


create or replace function catchmenu_pos.cancel_pre_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_session record;
  v_cancelled_tickets int;
  v_audit_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select id, session_type, session_status,
         order_id, wait_number,
         business_day, business_timezone
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  if v_session.session_type <> 'PRE_ORDER' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'not_a_pre_order_session'
    );
  end if;

  if v_session.session_status not in (
    'WAITING', 'ARRIVAL_PENDING', 'ORDER_CONFIRMED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_cancellable',
      'current_status', v_session.session_status
    );
  end if;

  -- cancel session
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- cancel order if exists
  if v_session.order_id is not null then
    update catchmenu_pos.orders
    set
      order_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    where id = v_session.order_id;
  end if;

  -- cancel all KDS tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    hold_reason = 'PRE_ORDER_CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where order_id = v_session.order_id
    and store_id = p_store_id
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  get diagnostics v_cancelled_tickets = row_count;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'session_cancelled',
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'order_id', v_session.order_id,
      'cancelled_tickets', v_cancelled_tickets
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'pre_order_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_tickets', v_cancelled_tickets
    ),
    p_session_id, v_session.order_id,
    p_correlation_id,
    v_session.business_day, v_session.business_timezone,
    now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'pre_order_cancelled',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'wait_number', v_session.wait_number,
      'order_id', v_session.order_id,
      'cancelled_tickets', v_cancelled_tickets
    ),
    p_session_id := p_session_id,
    p_order_id := v_session.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_session.order_id,
    'session_status', 'CANCELLED',
    'cancelled_tickets', v_cancelled_tickets,
    'cancel_reason', p_cancel_reason,
    'audit_id', v_audit_id,
    'message_code', 'pre_order_cancelled'
  );
end;
$$;


create or replace function catchmenu_pos.get_pre_order_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_session record;
  v_order record;
  v_tickets jsonb;
  v_conditions_summary jsonb;
begin
  select id, session_type, session_status,
         wait_number, order_id,
         table_id, arrived_at, seated_at,
         pre_order_created_at, pre_order_expires_at,
         payment_started_at, payment_completed_at,
         arrival_reliability_score
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_session.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_found'
    );
  end if;

  -- order info
  if v_session.order_id is not null then
    select id, order_number, order_status,
           total_amount, final_amount
    into v_order
    from catchmenu_pos.orders
    where id = v_session.order_id;
  end if;

  -- KDS ticket summary
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', kt.id,
        'ticket_number', kt.ticket_number,
        'kds_status', kt.kds_status,
        'kitchen_zone', kt.kitchen_zone,
        'menu_name', kt.menu_name_snapshot,
        'conditions_met', kt.conditions_met,
        'committed_at', kt.committed_at,
        'cooking_started_at', kt.cooking_started_at,
        'ready_at', kt.ready_at
      )
      order by kt.ticket_number
    ),
    '[]'::jsonb
  )
  into v_tickets
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_session.order_id
    and kt.store_id = p_store_id;

  -- conditions summary across tickets
  select jsonb_build_object(
    'arrived', bool_and(
      (conditions_met->>'arrived')::boolean
    ),
    'table_confirmed', bool_and(
      (conditions_met->>'table_confirmed')::boolean
    ),
    'payment_confirmed', bool_and(
      (conditions_met->>'payment_confirmed')::boolean
    ),
    'kds_capacity_ok', bool_and(
      (conditions_met->>'kds_capacity_ok')::boolean
    ),
    'all_conditions_met', bool_and(
      (conditions_met->>'arrived')::boolean
      and (conditions_met->>'table_confirmed')::boolean
      and (conditions_met->>'payment_confirmed')::boolean
      and (conditions_met->>'kds_capacity_ok')::boolean
      and coalesce(
        (conditions_met->>'menu_available')::boolean,
        true
      )
    )
  )
  into v_conditions_summary
  from catchmenu_kds.kds_tickets
  where order_id = v_session.order_id
    and store_id = p_store_id
    and kds_status not in ('CANCELLED', 'COMPLETED');

  return jsonb_build_object(
    'success', true,
    'session', jsonb_build_object(
      'id', v_session.id,
      'session_type', v_session.session_type,
      'session_status', v_session.session_status,
      'wait_number', v_session.wait_number,
      'table_id', v_session.table_id,
      'arrived_at', v_session.arrived_at,
      'seated_at', v_session.seated_at,
      'pre_order_created_at',
        v_session.pre_order_created_at,
      'pre_order_expires_at',
        v_session.pre_order_expires_at,
      'is_expired', v_session.pre_order_expires_at
        is not null
        and v_session.pre_order_expires_at < now(),
      'arrival_reliability_score',
        v_session.arrival_reliability_score
    ),
    'order', case
      when v_order.id is not null
      then jsonb_build_object(
        'id', v_order.id,
        'order_number', v_order.order_number,
        'order_status', v_order.order_status,
        'total_amount', v_order.total_amount,
        'final_amount', v_order.final_amount
      )
      else null
    end,
    'kds_tickets', v_tickets,
    'ticket_count', jsonb_array_length(v_tickets),
    'conditions_summary', v_conditions_summary,
    'message_code', 'pre_order_status_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.create_pre_order(
    uuid, uuid, uuid, jsonb, text, text
  ) from public;
  grant execute on function catchmenu_pos.create_pre_order(
    uuid, uuid, uuid, jsonb, text, text
  ) to authenticated;

  revoke all on function catchmenu_pos.confirm_pre_order_arrival(
    uuid, uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.confirm_pre_order_arrival(
    uuid, uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.cancel_pre_order(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.cancel_pre_order(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.get_pre_order_status(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_pos.get_pre_order_status(
    uuid, uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.create_pre_order(
  uuid, uuid, uuid, jsonb, text, text
) is
  'Creates pre-order for waiting customer before arrival.
   Validates arrival_reliability_score against threshold.
   Creates order and KDS tickets — all tickets in HOLD.
   All 7 conditions start false.
   Sets pre_order_expires_at from store settings.
   특허2 핵심:
   사전주문 → 즉시 KDS 티켓 생성 (HOLD 상태)
   → arrived + table_confirmed + payment_confirmed 모두 충족 후 조리 큐 투입.
   노쇼 이력이 높은 고객은 사전주문 차단.';

comment on function catchmenu_pos.confirm_pre_order_arrival(
  uuid, uuid, uuid, uuid, text, uuid, text
) is
  'Confirms pre-order customer arrival and completes Late Binding.
   1. Validates pre-order not expired.
   2. Calls bind_table_to_session (Late Binding).
   3. Updates KDS conditions: arrived = true, table_confirmed = true.
   4. KDS tickets move from HOLD → CAPACITY_CHECKING.
   Next step: payment → payment_confirmed = true → all conditions met
   → COMMITTED.
   특허1: 도착 확인 = Late Binding 완료 시점.
   특허2: 도착 확인 → KDS 조건 2개 충족 → 결제 대기.';

comment on function catchmenu_pos.cancel_pre_order(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Cancels pre-order before cooking starts.
   Cancels session, order, and all HOLD KDS tickets.
   Requires cancel reason for audit trail.
   특허2: 사전주문 취소 → HOLD 티켓 일괄 취소.';

-- ===== END sql/migrations/0051_create_pre_order_rpc.sql =====


-- ===== BEGIN sql/migrations/0115_create_waiting_pipeline_rpc.sql =====

-- 0115_create_waiting_pipeline_rpc.sql
-- Purpose: Waiting queue pipeline with Late Binding.
--          대기 등록 → 호출 → 착석 → Pre-order
--          → 결제 → KDS Late Binding.
--          QR 대기 등록 (미니키오스크 연동).
--          노쇼/이탈 처리.
--          DID 연동.
--          특허1: Wait/Order Handoff 핵심.
--          특허2: 대기 Pre-order KDS HOLD.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0114_create_mini_kiosk_pipeline_rpc.sql
-- Creates:
--   function catchmenu_pos.register_waiting(...)
--   function catchmenu_pos.call_waiting_customer(...)
--   function catchmenu_pos.confirm_arrival(...)
--   function catchmenu_pos.pre_order_while_waiting(...)
--   function catchmenu_pos.seat_waiting_customer(...)
--   function catchmenu_pos.cancel_waiting(...)
--   function catchmenu_pos.mark_no_show(...)
--   function catchmenu_pos.get_waiting_status(...)
--   function catchmenu_pos.get_waiting_admin_view(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('waiting_registered', 'ko',
  '{wait_number}번으로 대기 등록되었습니다'),
('waiting_registered', 'en',
  'Registered as #{wait_number}'),
('waiting_registered', 'zh',
  '已登记为{wait_number}号'),
('waiting_registered', 'ja',
  '{wait_number}番で受付しました'),
('waiting_registered', 'vi',
  'Đã đăng ký số #{wait_number}'),
('waiting_registered', 'th',
  'ลงทะเบียนหมายเลข #{wait_number} แล้ว'),

('waiting_called_alert', 'ko',
  '{wait_number}번 고객님, 입장해 주세요'),
('waiting_called_alert', 'en',
  'Number #{wait_number}, please come in'),
('waiting_called_alert', 'zh',
  '{wait_number}号，请进'),
('waiting_called_alert', 'ja',
  '{wait_number}番のお客様、どうぞお入りください'),
('waiting_called_alert', 'vi',
  'Số #{wait_number}, mời vào'),
('waiting_called_alert', 'th',
  'หมายเลข #{wait_number} กรุณาเข้ามา'),

('arrival_confirmed', 'ko',
  '도착이 확인되었습니다. 잠시만 기다려 주세요'),
('arrival_confirmed', 'en',
  'Arrival confirmed. Please wait a moment'),
('arrival_confirmed', 'zh',
  '已确认到达，请稍等'),
('arrival_confirmed', 'ja',
  'ご到着を確認しました。少々お待ちください'),
('arrival_confirmed', 'vi',
  'Đã xác nhận đến. Vui lòng chờ'),
('arrival_confirmed', 'th',
  'ยืนยันการมาถึงแล้ว กรุณารอสักครู่'),

('waiting_seated', 'ko',
  '착석 처리되었습니다'),
('waiting_seated', 'en',
  'Customer seated'),
('waiting_seated', 'zh',
  '已就座'),
('waiting_seated', 'ja',
  'ご着席いただきました'),
('waiting_seated', 'vi',
  'Khách đã ngồi'),
('waiting_seated', 'th',
  'ลูกค้านั่งแล้ว'),

('waiting_cancelled', 'ko',
  '대기가 취소되었습니다'),
('waiting_cancelled', 'en',
  'Waiting cancelled'),
('waiting_cancelled', 'zh',
  '等位已取消'),
('waiting_cancelled', 'ja',
  '順番待ちをキャンセルしました'),
('waiting_cancelled', 'vi',
  'Đã hủy chờ'),
('waiting_cancelled', 'th',
  'ยกเลิกการรอแล้ว'),

('waiting_no_show', 'ko',
  '{wait_number}번 노쇼 처리되었습니다'),
('waiting_no_show', 'en',
  'No-show: #{wait_number}'),
('waiting_no_show', 'zh',
  '{wait_number}号未到'),
('waiting_no_show', 'ja',
  '{wait_number}番、ノーショー処理しました'),
('waiting_no_show', 'vi',
  'Vắng mặt: #{wait_number}'),
('waiting_no_show', 'th',
  'ไม่มาตามนัด: #{wait_number}'),

('pre_order_registered', 'ko',
  '사전 주문이 등록되었습니다. 착석 후 조리가 시작됩니다'),
('pre_order_registered', 'en',
  'Pre-order registered. Cooking starts after seating'),
('pre_order_registered', 'zh',
  '预点餐已登记，就座后开始烹饪'),
('pre_order_registered', 'ja',
  '事前注文を受け付けました。着席後に調理が始まります'),
('pre_order_registered', 'vi',
  'Đặt trước đã đăng ký. Nấu sau khi ngồi'),
('pre_order_registered', 'th',
  'สั่งล่วงหน้าแล้ว จะเริ่มปรุงหลังนั่ง'),

('waiting_status_loaded', 'ko',
  '대기 현황이 로드되었습니다'),
('waiting_status_loaded', 'en',
  'Waiting status loaded'),

('waiting_current_position', 'ko',
  '현재 {position}번째 대기 중입니다'),
('waiting_current_position', 'en',
  'Currently #{position} in queue'),
('waiting_current_position', 'zh',
  '当前排队第{position}位'),
('waiting_current_position', 'ja',
  '現在{position}番目でお待ちです'),
('waiting_current_position', 'vi',
  'Đang chờ thứ #{position}'),
('waiting_current_position', 'th',
  'รอคิวที่ #{position}'),

('waiting_est_time', 'ko',
  '예상 대기 시간: 약 {minutes}분'),
('waiting_est_time', 'en',
  'Est. wait: ~{minutes} min'),
('waiting_est_time', 'zh',
  '预计等待：约{minutes}分钟'),
('waiting_est_time', 'ja',
  '予想待ち時間：約{minutes}分'),
('waiting_est_time', 'vi',
  'Dự kiến chờ: ~{minutes} phút'),
('waiting_est_time', 'th',
  'เวลารอโดยประมาณ: ~{minutes} นาที'),

('pre_order_kds_note', 'ko',
  '대기 중 주문은 착석/결제 후 조리됩니다'),
('pre_order_kds_note', 'en',
  'Pre-orders cook after seating/payment'),
('pre_order_kds_note', 'zh',
  '等位期间的预点餐将在就座后烹饪'),
('pre_order_kds_note', 'ja',
  '待機中の注文は着席後に調理されます'),
('pre_order_kds_note', 'vi',
  'Đơn đặt trước nấu sau khi ngồi'),
('pre_order_kds_note', 'th',
  'คำสั่งซื้อล่วงหน้าจะปรุงหลังนั่ง')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(2020, 'waiting_session_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING'),
(2021, 'waiting_already_called',
  'ORDER', 'CONFLICT', 409, 'INFO'),
(2022, 'waiting_already_seated',
  'ORDER', 'CONFLICT', 409, 'INFO'),
(2023, 'waiting_queue_disabled',
  'ORDER', 'BUSINESS_RULE', 503, 'INFO'),
(2024, 'pre_order_requires_waiting',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING'),
(2025, 'waiting_not_callable',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_pos.register_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int,
  p_session_type text default 'WAITING',
  p_guest_locale text default 'ko',
  p_phone_hash text default null,
  p_customer_id uuid default null,
  p_memo text default null,
  p_source text default 'STAFF',
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_wait_number int;
  v_queue_position int;
  v_session_id uuid;
  v_est_wait_minutes int;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode, waiting_enabled,
         max_wait_number
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 대기 비활성화 확인
  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
    or not coalesce(
      v_settings.waiting_enabled, true
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_queue_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 현재 대기 인원 확인
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 대기 정원 초과
  if v_queue_position >=
    coalesce(v_settings.max_wait_number, 30)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'wait_queue_full',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 오늘 대기 번호 채번
  select coalesce(
    max(wait_number), 0
  ) + 1
  into v_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 대기 세션 생성 (특허1 핵심)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    wait_number, queue_position,
    guest_count, guest_locale,
    phone_hash, customer_id,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type, 'WAITING',
    v_wait_number, v_queue_position + 1,
    p_guest_count, p_guest_locale,
    p_phone_hash, p_customer_id,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 예상 대기 시간 계산
  v_est_wait_minutes :=
    v_queue_position * 10;

  -- Realtime → 대기 화면 + DID 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_created',
    p_payload := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'source', p_source
    )
  );

  -- 고객 앱 푸시 알림 (전화번호 있는 경우)
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash,
        'customer_id', p_customer_id,
        'notification_type', 'WAITING_REGISTERED',
        'wait_number', v_wait_number,
        'queue_position', v_queue_position + 1,
        'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_registered', 1,
    'order_session', v_session_id,
    null, 'WAITING',
    p_source,
    jsonb_build_object(
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'session_type', p_session_type,
      'source', p_source
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_registered',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'pre_order_enabled',
        p_session_type = 'PRE_ORDER',
      'position_message',
        catchmenu_common.get_message(
          'waiting_current_position',
          p_guest_locale,
          jsonb_build_object(
            'position', v_queue_position + 1
          )
        ),
      'est_time_message',
        catchmenu_common.get_message(
          'waiting_est_time',
          p_guest_locale,
          jsonb_build_object(
            'minutes', v_est_wait_minutes
          )
        ),
      'registered_message',
        catchmenu_common.get_message(
          'waiting_registered',
          p_guest_locale,
          jsonb_build_object(
            'wait_number', v_wait_number
          )
        )
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_count, guest_locale,
         phone_hash, customer_id,
         pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_waiting_customer'
    );
  end if;

  if v_session.session_status
    not in ('WAITING', 'ARRIVAL_PENDING')
  then
    return catchmenu_common.build_error_response(
      p_error_key := case
        v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 호출 상태로 변경
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    called_at = now(),
    table_number = coalesce(
      p_table_number, table_number
    ),
    call_count = coalesce(call_count, 0) + 1,
    updated_at = now()
  where id = p_session_id;

  -- DID 호출 (콜링 시스템)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_locale', v_session.guest_locale,
      'called_at', now(),
      'message',
        catchmenu_common.get_message(
          'waiting_called_alert',
          v_session.guest_locale,
          jsonb_build_object(
            'wait_number',
              v_session.wait_number
          )
        )
    )
  );

  -- DID 디스플레이 표시
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'display_number', v_session.wait_number,
      'table_number', p_table_number,
      'queue_type', 'WAITING_CALL',
      'guest_locale', v_session.guest_locale
    )
  );

  -- 고객 앱 푸시 알림
  if v_session.phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', v_session.phone_hash,
        'customer_id', v_session.customer_id,
        'notification_type', 'WAITING_CALLED',
        'wait_number', v_session.wait_number,
        'table_number', p_table_number,
        'locale', v_session.guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_called', 1,
    'order_session', p_session_id,
    'WAITING', 'ARRIVAL_PENDING',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'has_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_locale', v_session.guest_locale,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'did_called', true,
      'push_sent',
        v_session.phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_session.wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.pre_order_while_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cart_items jsonb,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_business_day date;
  v_timezone text;
  v_ticket_count int := 0;
  v_ticket_number text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 대기 세션 확인
  select id, wait_number, session_status,
         guest_count, guest_locale
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 대기 중 또는 호출 상태에서만 사전 주문 가능
  if v_session.session_status
    not in ('WAITING', 'ARRIVAL_PENDING')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_requires_waiting',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 금액 계산 + 품절 확인
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price, menu_status,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'pre_order_while_waiting'
      );
    end if;

    v_total_amount := v_total_amount
      + v_menu.price
        * (v_item->>'quantity')::int;
  end loop;

  -- 사전 주문 번호
  v_order_number := 'W' || lpad(
    v_session.wait_number::text, 3, '0'
  );

  -- 주문 생성 (TABLE 타입, PRE_ORDER 소스)
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_id, v_order_number,
    'TABLE', 'CONFIRMED',
    'PRE_ORDER',
    v_total_amount, v_total_amount,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- 주문 항목 + KDS 티켓 (HOLD = 특허2 핵심)
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity, unit_price, subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu.id,
      v_menu.menu_name,
      (v_item->>'quantity')::int,
      v_menu.price,
      v_menu.price * (v_item->>'quantity')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- ==========================================
    -- 특허2 + 특허1 결합 핵심
    -- 대기 중 사전 주문 → KDS HOLD
    -- 착석 확인 후 결제 → COMMITTED
    -- "대기하면서 메뉴 선택,
    --  착석하자마자 신선하게 나오는 시스템"
    -- ==========================================
    if v_menu.is_kds_required then
      v_ticket_count := v_ticket_count + 1;
      v_ticket_number := v_order_number || '-' || lpad(v_ticket_count::text, 2, '0');

      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, ticket_number,
        menu_name_snapshot,
        quantity_snapshot,
        kitchen_zone, kds_status,
        conditions_met,
        ticket_created_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_ticket_number,
        v_menu.menu_name,
        (v_item->>'quantity')::int,
        coalesce(v_menu.kitchen_zone, 'MAIN'),
        'HOLD',
        jsonb_build_object(
          'payment_confirmed', false,
          'kds_release_authorized', false,
          'waiting_session_id', p_session_id,
          'wait_number',
            v_session.wait_number,
          'order_source', 'PRE_ORDER',
          'release_trigger',
            'seat_confirmed_or_payment'
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- 세션 사전 주문 금액 업데이트
  update catchmenu_pos.order_sessions
  set
    session_type = 'PRE_ORDER',
    pre_order_amount = v_total_amount,
    updated_at = now()
  where id = p_session_id;

  -- ledger event (특허1 + 특허2)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'pre_order_registered', 1,
    'order_session', p_session_id,
    'WAITING', 'PRE_ORDER',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'patent_note',
        'Patent1+2: Pre-order HOLD until seated'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'pre_order_registered',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'kds_note',
        catchmenu_common.get_message(
          'pre_order_kds_note', p_locale, null
        ),
      'patent_principle', jsonb_build_object(
        'patent1',
          'Wait session tracks full journey',
        'patent2',
          'KDS HOLD until payment confirmed',
        'combined',
          'Pre-order while waiting, fresh food on seat'
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount,
         table_number
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  -- 도착 확인 상태로 변경
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    arrival_confirmed_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    'WAITING', 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'table_number', v_session.table_number,
      'next_step', case
        when v_session.pre_order_amount > 0
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_pre_order record;
  v_business_day date;
  v_remaining_queue int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_count, guest_locale,
         pre_order_amount, phone_hash,
         customer_id
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 착석 처리
  update catchmenu_pos.order_sessions
  set
    session_status = 'SEATED',
    table_number = coalesce(
      p_table_number, table_number
    ),
    seated_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 있으면 KDS HOLD 유지
  -- 결제 후 confirm_payment() → COMMITTED
  -- 사전 주문 없으면 이제 주문 받으면 됨
  if v_session.pre_order_amount > 0 then
    -- 사전 주문 조회
    select id into v_pre_order
    from catchmenu_pos.orders
    where session_id = p_session_id
      and order_source = 'PRE_ORDER'
      and order_status = 'CONFIRMED'
    limit 1;

    -- KDS는 여전히 HOLD
    -- 결제 확인 후 release_kds_after_payment()
    -- 가 COMMITTED로 변경
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. '
        || 'KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount',
          v_session.pre_order_amount
      )
    );
  end if;

  -- 남은 대기 인원
  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    );

  -- Realtime → 대기 화면 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order',
        v_session.pre_order_amount > 0
    )
  );

  -- DID 호출 해제
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- ledger event (특허1 핵심: 착석 기록)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (
          now() - (
            select session_started_at
            from catchmenu_pos.order_sessions
            where id = p_session_id
          )
        )
      )::int,
      'had_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_amount > 0
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_amount > 0
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note',
              '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment',
              'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  -- 대기 취소
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    cancel_reason = p_cancel_reason,
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 있으면 KDS 취소
  if v_session.pre_order_amount > 0 then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  -- Realtime 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount,
         called_at
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'mark_no_show'
    );
  end if;

  -- 노쇼 처리
  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    no_show_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 KDS 취소
  if v_session.pre_order_amount > 0 then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  -- Realtime 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'reason', 'NO_SHOW'
    )
  );

  -- ledger event (특허1: 노쇼도 증거)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'no_show_marked', 1,
    'order_session', p_session_id,
    v_session.session_status, 'NO_SHOW',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'called_at', v_session.called_at,
      'wait_after_call_seconds', case
        when v_session.called_at is not null
        then extract(
          epoch from (
            now() - v_session.called_at
          )
        )::int
        else null
      end,
      'had_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_no_show',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'no_show_at', now(),
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_session.wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         session_type, guest_count,
         guest_locale, queue_position,
         pre_order_amount,
         table_number,
         session_started_at,
         called_at, arrival_confirmed_at,
         seated_at
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  -- 현재 내 앞 대기 인원
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and wait_number < v_session.wait_number;

  v_est_wait_minutes :=
    v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at',
          v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at',
          v_session.arrival_confirmed_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position',
          catchmenu_common.get_message(
            'waiting_current_position',
            coalesce(
              p_locale,
              v_session.guest_locale
            ),
            jsonb_build_object(
              'position', v_queue_position
            )
          ),
        'est_time',
          catchmenu_common.get_message(
            'waiting_est_time',
            coalesce(
              p_locale,
              v_session.guest_locale
            ),
            jsonb_build_object(
              'minutes', v_est_wait_minutes
            )
          )
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
  v_avg_wait_minutes int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 대기 목록 (직원 관리 뷰)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', os.table_number,
        'has_pre_order',
          os.pre_order_amount > 0,
        'pre_order_amount',
          os.pre_order_amount,
        'waited_minutes', extract(
          epoch from (
            now() - os.session_started_at
          )
        )::int / 60,
        'called_at', os.called_at,
        'call_count', os.call_count,
        'memo', os.memo,
        'is_foreign',
          os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case
            when os.session_status = 'WAITING'
              then 'CALL'
            else null
          end,
          case
            when os.session_status
              in ('WAITING', 'ARRIVAL_PENDING')
              then 'SEAT'
            else null
          end,
          case
            when os.session_status
              in ('WAITING', 'ARRIVAL_PENDING')
              then 'NO_SHOW'
            else null
          end,
          'CANCEL'
        )
      )
      order by os.queue_position asc nulls last,
               os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    );

  -- 오늘 통계
  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (
      where session_status = 'COMPLETED'
    ),
    'cancelled', count(*) filter (
      where session_status = 'CANCELLED'
    ),
    'no_show', count(*) filter (
      where session_status = 'NO_SHOW'
    ),
    'current_waiting',
      jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (
      where pre_order_amount > 0
    ),
    'total_pre_order_amount', coalesce(
      sum(pre_order_amount) filter (
        where pre_order_amount > 0
      ), 0
    ),
    'foreign_count', count(*) filter (
      where guest_locale <> 'ko'
    ),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (
          coalesce(
            seated_at, now()
          ) - session_started_at
        )) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting',
        jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'patent_note', jsonb_build_object(
        'patent1',
          'Full journey tracked per session',
        'patent2',
          'Pre-order KDS HOLD until payment',
        'handoff_flow',
          'register→call→arrive→seat→pay→cook'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_pos.register_waiting(
      uuid, uuid, int, text, text, text,
      uuid, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.call_waiting_customer(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.pre_order_while_waiting(
      uuid, uuid, uuid, jsonb, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.confirm_arrival(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.seat_waiting_customer(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.cancel_waiting(
      uuid, uuid, uuid, text, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.mark_no_show(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.get_waiting_status(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.get_waiting_admin_view(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_pos.pre_order_while_waiting(
    uuid, uuid, uuid, jsonb, text, text
  ) is
  '대기 중 사전 주문 등록.
   특허1 + 특허2 결합 핵심 함수.

   흐름:
   1. 대기 등록 (register_waiting)
   2. 대기 중 메뉴 선택
      → pre_order_while_waiting()
      → 주문 생성 (PRE_ORDER 소스)
      → KDS = HOLD (조리 금지)
   3. 호출 (call_waiting_customer)
   4. 도착 확인 (confirm_arrival)
   5. 착석 (seat_waiting_customer)
      → KDS 여전히 HOLD
   6. 결제 (confirm_payment)
      → release_kds_after_payment()
      → KDS = COMMITTED (조리 시작!)
   7. 신선한 음식 제공

   고객 경험:
   "대기하면서 메뉴를 골랐는데
    앉자마자 음식이 나왔어요!"
   → 입소문 = 소문의 근거.

   KDS conditions_met 기록:
   waiting_session_id: 추적 가능
   release_trigger: 결제 후 자동 해제
   order_source: PRE_ORDER 구분.

   특허1: 대기 세션 전 여정 추적.
   특허2: KDS HOLD → 결제 후 COMMITTED.';

comment on function
  catchmenu_pos.register_waiting(
    uuid, uuid, int, text, text, text,
    uuid, text, text, text, text
  ) is
  '대기 등록 파이프라인.
   p_source: STAFF/KIOSK/QR/CUSTOMER_APP
   p_session_type: WAITING/PRE_ORDER

   등록 후 자동 처리:
   - Realtime → 대기 화면 + DID 업데이트
   - 전화번호 있으면 푸시 알림 예약
   - 예상 대기 시간 계산 (앞팀 × 10분)
   - 다국어 메시지 반환

   특허1: 대기 등록 = 세션 시작점.
   노쇼/이탈/착석 모두 이 세션으로 추적.
   감사 원장에 전 여정 기록.';


-- ===== END sql/migrations/0115_create_waiting_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0148_add_order_sessions_customer_id_and_guest_flag.sql =====

-- 0148_add_order_sessions_customer_id_and_guest_flag.sql
-- Purpose: Add the canonical customer linkage needed by waiting/order sessions
--          and guest promotion: catchmenu_store.customers.is_guest,
--          catchmenu_pos.order_sessions.customer_id, and
--          catchmenu_pos.order_sessions.phone_hash.
-- Depends on: 0147_widen_plan_tier_constraint.sql
-- Creates:
--   catchmenu_store.customers.is_guest
--   catchmenu_pos.order_sessions.customer_id
--   catchmenu_pos.order_sessions.phone_hash
--   catchmenu_pos.order_sessions_customer_id_fkey
--   idx_order_sessions_customer
--
-- Background:
--   The local database had an out-of-band partial application of
--   order_sessions.customer_id, its FK, and idx_order_sessions_customer
--   without a recorded migration_history row. That local FK used
--   ON DELETE NO ACTION, while the approved design requires
--   ON DELETE SET NULL so historical order_sessions rows survive customer
--   deletion/anonymization with only the customer_id pointer cleared.
--   This migration therefore first removes the out-of-band customer_id
--   column/FK/index safely, then recreates the approved specification.
--
-- Human Decision summary from 600112_Logic.md:
--   - Guest sessions are linked to catchmenu_store.customers through
--     order_sessions.customer_id.
--   - Guest promotion is represented by updating the same customers row
--     from is_guest = true to is_guest = false; this is not a separate
--     merge/rewrite flow.
--   - order_sessions.customer_id must use ON DELETE SET NULL.
--   - phone_hash is added because 0115 already assumes it exists on
--     order_sessions, although the 0012 base table did not create it.
--
-- Open Items intentionally not solved by this migration:
--   1. 005015 policy remains unrevised; in-place promotion vs. true merge
--      wording is deferred to a separate documentation decision.
--   2. Anonymous guest dedupe remains absent; device-fingerprint or other
--      dedupe policy is deferred.
--   3. The duplicate 604500 workpacket/folder issue remains deferred; this
--      migration only implements the approved DB forward fix.

alter table catchmenu_pos.order_sessions
  drop constraint if exists order_sessions_customer_id_fkey;

drop index if exists catchmenu_pos.idx_order_sessions_customer;

alter table catchmenu_pos.order_sessions
  drop column if exists customer_id;

alter table catchmenu_store.customers
  add column if not exists is_guest boolean not null default false;

alter table catchmenu_pos.order_sessions
  add column customer_id uuid
    references catchmenu_store.customers(id)
    on delete set null;

alter table catchmenu_pos.order_sessions
  add column if not exists phone_hash text;

create index idx_order_sessions_customer
  on catchmenu_pos.order_sessions(customer_id)
  where customer_id is not null;

comment on column catchmenu_store.customers.is_guest is
  'Flags a customer identity row as a guest-created identity pending in-place promotion to a member/customer account.';

comment on column catchmenu_pos.order_sessions.customer_id is
  'Optional FK linking a wait/order session to catchmenu_store.customers; ON DELETE SET NULL preserves session history when customer identity is removed.';

comment on column catchmenu_pos.order_sessions.phone_hash is
  'Hashed phone identifier used by the waiting pipeline and guest customer promotion flow; nullable for anonymous guests.';


-- ===== END sql/migrations/0148_add_order_sessions_customer_id_and_guest_flag.sql =====


-- ===== BEGIN sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql =====

-- 0149_create_guest_customer_bootstrap_rpc.sql
-- Purpose: Create the guest customer bootstrap helper and patch the two
--          existing customer-entry RPCs so omitted p_customer_id values are
--          filled through catchmenu_store.get_or_create_guest_customer().
-- Depends on: 0148_add_order_sessions_customer_id_and_guest_flag.sql
-- Creates:
--   catchmenu_store.get_or_create_guest_customer(uuid, text)
-- Patches via CREATE OR REPLACE FUNCTION:
--   catchmenu_pos.register_waiting(...)
--   catchmenu_store.bootstrap_customer_app_v2(...)
--
-- Human Boundary Approval: 600124_ChangeContract.md approved Stage 4.
-- Design source: 600122_Logic.md. The helper keeps is_guest out of the
-- ON CONFLICT DO UPDATE SET clause so an already-promoted customer is not
-- reverted to guest status by a later same-phone_hash guest bootstrap call.
-- Direct helper grants are intentionally not given to authenticated; callers
-- reach it only through the patched 0115/0116 SECURITY DEFINER RPCs.

create or replace function catchmenu_store.get_or_create_guest_customer(
  p_tenant_id uuid,
  p_phone_hash text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_store
as $$
declare
  v_customer_id uuid;
  v_customer_code text;
begin
  -- customer_code 생성: 0058 register_customer()의 패턴 재사용
  v_customer_code := 'C' || to_char(now(), 'YYMMDD')
    || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.customers
        where tenant_id = p_tenant_id
      )::text,
      6, '0'
    );

  if p_phone_hash is not null then
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      phone_hash, is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      p_phone_hash, true,
      'ko', true,
      now(), now()
    )
    on conflict (tenant_id, phone_hash)
    do update set updated_at = now()
    returning id into v_customer_id;
  else
    -- phone_hash 없는 완전 익명: 매번 신규 row (Human 결정 #4)
    insert into catchmenu_store.customers (
      tenant_id, customer_code,
      is_guest,
      preferred_locale, is_active,
      first_visit_at, last_visit_at
    ) values (
      p_tenant_id, v_customer_code,
      true,
      'ko', true,
      now(), now()
    )
    returning id into v_customer_id;
  end if;

  return v_customer_id;
end;
$$;

create or replace function
  catchmenu_pos.register_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int,
  p_session_type text default 'WAITING',
  p_guest_locale text default 'ko',
  p_phone_hash text default null,
  p_customer_id uuid default null,
  p_memo text default null,
  p_source text default 'STAFF',
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_wait_number int;
  v_queue_position int;
  v_session_id uuid;
  v_est_wait_minutes int;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode, waiting_enabled,
         max_wait_number
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 대기 비활성화 확인
  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
    or not coalesce(
      v_settings.waiting_enabled, true
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_queue_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 현재 대기 인원 확인
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 대기 정원 초과
  if v_queue_position >=
    coalesce(v_settings.max_wait_number, 30)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'wait_queue_full',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 오늘 대기 번호 채번
  select coalesce(
    max(wait_number), 0
  ) + 1
  into v_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 대기 세션 생성 (특허1 핵심)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    wait_number, queue_position,
    guest_count, guest_locale,
    phone_hash, customer_id,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type, 'WAITING',
    v_wait_number, v_queue_position + 1,
    p_guest_count, p_guest_locale,
    p_phone_hash, p_customer_id,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 예상 대기 시간 계산
  v_est_wait_minutes :=
    v_queue_position * 10;

  -- Realtime → 대기 화면 + DID 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_created',
    p_payload := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'source', p_source
    )
  );

  -- 고객 앱 푸시 알림 (전화번호 있는 경우)
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash,
        'customer_id', p_customer_id,
        'notification_type', 'WAITING_REGISTERED',
        'wait_number', v_wait_number,
        'queue_position', v_queue_position + 1,
        'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_registered', 1,
    'order_session', v_session_id,
    null, 'WAITING',
    p_source,
    jsonb_build_object(
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'session_type', p_session_type,
      'source', p_source
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_registered',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'pre_order_enabled',
        p_session_type = 'PRE_ORDER',
      'position_message',
        catchmenu_common.get_message(
          'waiting_current_position',
          p_guest_locale,
          jsonb_build_object(
            'position', v_queue_position + 1
          )
        ),
      'est_time_message',
        catchmenu_common.get_message(
          'waiting_est_time',
          p_guest_locale,
          jsonb_build_object(
            'minutes', v_est_wait_minutes
          )
        ),
      'registered_message',
        catchmenu_common.get_message(
          'waiting_registered',
          p_guest_locale,
          jsonb_build_object(
            'wait_number', v_wait_number
          )
        )
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function
  catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_push_token text default null,
  p_os_type text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_store_settings record;
  v_customer record;
  v_membership jsonb;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_cms_bundle jsonb;
  v_menu_preview jsonb;
  v_business_day date;
  v_day_of_week int;
  v_business_hours record;
  v_is_open boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 정보
  select id, store_name, store_type, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_customer_app_v2'
    );
  end if;

  -- 매장 설정
  -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was never
  -- a real column on catchmenu_store.store_settings (confirmed via
  -- \d catchmenu_store.store_settings -- no min_order_amount, no
  -- minimum_order_amount, no min_pre_order_amount equivalent). This
  -- SELECT would have failed at runtime with "column does not exist"
  -- on every call. The concept (minimum pre-order amount) was simply
  -- never implemented -- removed from this SELECT rather than mapped
  -- to a nonexistent column.
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    else true
  end;

  -- p_customer_id가 없으면 게스트 헬퍼로 채운다 (600120 patch)
  if p_customer_id is null then
    p_customer_id := catchmenu_store.get_or_create_guest_customer(
      p_tenant_id := p_tenant_id,
      p_phone_hash := p_phone_hash
    );
  end if;

  -- 고객 정보 + 멤버십
  if p_customer_id is not null then
    select id, display_name, membership_tier,
           point_balance, visit_count,
           last_visit_at, preferred_locale
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 멤버십 조회
      v_membership := (
        catchmenu_store.get_customer_membership(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := p_customer_id,
          p_locale := p_locale
        )
      )->'data';

      -- 현재 대기 세션 확인
      select jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'queue_position', (
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and business_day = v_business_day
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
            and wait_number < os.wait_number
        ),
        'has_pre_order',
          false,
        'pre_order_amount',
          0
      )
      into v_active_waiting
      from catchmenu_pos.order_sessions os
      where os.store_id = p_store_id
        and os.tenant_id = p_tenant_id
        and os.customer_id = p_customer_id
        and os.business_day = v_business_day
        and os.session_status in (
          'WAITING', 'ARRIVAL_PENDING', 'SEATED'
        )
      order by os.session_started_at desc
      limit 1;

      -- 현재 진행 중 주문 확인
      select jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'order_type', o.order_type,
        'final_amount', o.final_amount,
        'kds_status', (
          select max(kds_status)
          from catchmenu_kds.kds_tickets
          where order_id = o.id
        ),
        'is_paid', exists (
          select 1
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
        )
      )
      into v_active_order
      from catchmenu_pos.orders o
      where o.store_id = p_store_id
        and o.tenant_id = p_tenant_id
        and o.business_day = v_business_day
        and o.order_status in (
          'CONFIRMED', 'COOKING',
          'READY', 'PAID'
        )
        and exists (
          select 1
          from catchmenu_pos.order_sessions os
          where os.id = o.session_id
            and os.customer_id = p_customer_id
        )
      order by o.ordered_at desc
      limit 1;

      -- 푸시 토큰 업데이트
      if p_push_token is not null then
        update catchmenu_store.customers
        set
          preferred_locale = p_locale,
          updated_at = now()
        where id = p_customer_id;
      end if;
    end if;
  end if;

  -- CMS 번들 (이벤트/배너/팝업)
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  -- 메뉴 미리보기 (인기 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_locale
          when 'en' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'zh' then coalesce(
            m.menu_name_zh, m.menu_name
          )
          when 'ja' then coalesce(
            m.menu_name_ja, m.menu_name
          )
          else m.menu_name
        end,
        'price', m.price,
        'thumbnail_url', m.image_url,
        'menu_status', m.menu_status
      )
      order by m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menu_preview
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_app_ready',
    p_data := jsonb_build_object(

      -- 매장
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_type', v_store.store_type,
        'is_open', v_is_open,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        -- NOTE (§24 lightweight fix, 2026-07-11): min_order_amount was
        -- never implemented on store_settings (see the SELECT above);
        -- hardcoded to 0 rather than referencing a nonexistent field on
        -- v_store_settings, which would itself fail since the record
        -- only carries the columns actually selected into it.
        'min_order_amount', 0,
        'business_hours', case
          when v_business_hours.open_time
            is not null
          then jsonb_build_object(
            'open_time',
              v_business_hours.open_time,
            'close_time',
              v_business_hours.close_time,
            'last_order_time',
              v_business_hours.last_order_time
          )
          else null
        end
      ),

      -- 고객
      'customer', case
        when v_customer.id is not null
        then jsonb_build_object(
          'id', v_customer.id,
          'display_name', v_customer.display_name,
          'membership_tier',
            v_customer.membership_tier,
          'total_points', v_customer.point_balance,
          'visit_count', v_customer.visit_count
        )
        else null
      end,

      -- 멤버십
      'membership', v_membership,

      -- 현재 대기
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,

      -- 진행 중 주문
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,

      -- CMS
      'cms', v_cms_bundle->'data',

      -- 메뉴 미리보기
      'menu_preview', v_menu_preview,

      -- Realtime 채널
      'realtime_channel',
        'customer_app:' || p_store_id,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;

revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from public;
revoke all on function catchmenu_store.get_or_create_guest_customer(uuid, text) from authenticated;

-- Preserve existing RPC execute grants for the patched public entry points.
grant execute on function catchmenu_pos.register_waiting(
  uuid, uuid, int, text, text, text, uuid, text, text, text, text
) to authenticated;

grant execute on function catchmenu_store.bootstrap_customer_app_v2(
  uuid, uuid, uuid, text, text, text, text, text
) to authenticated;


-- ===== END sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql =====


-- ===== BEGIN sql/migrations/0160_call_waiting_customer_contract_recovery.sql =====

-- ============================================================================
-- Migration: 0160_call_waiting_customer_contract_recovery.sql
-- Purpose:
--   Recover the waiting-call contract by replacing phantom order_sessions
--   columns with session_events-derived call history, introducing an internal
--   shared waiting-call helper, adding an automatic next-customer call RPC,
--   dropping the legacy call_next_waiting() overload, and marking
--   no_show_auto_expire_minutes as deprecated by COMMENT only.
--
-- Depends on:
--   0159_fix_payment_intent_idempotency_key_race.sql
--
-- Creates/Changes:
--   - Creates catchmenu_pos._record_waiting_call(...)
--   - Replaces catchmenu_pos.call_waiting_customer(...)
--   - Creates catchmenu_pos.call_next_waiting_customer(...)
--   - Drops legacy catchmenu_pos.call_next_waiting(uuid, uuid, text, uuid, uuid, text)
--   - Comments catchmenu_store.store_settings.no_show_auto_expire_minutes as deprecated
--
-- Background:
--   600640_call_waiting_customer_contract_recovery confirmed that called_at,
--   call_count, table_number, and pre_order_amount must not be stored on
--   order_sessions. call history is recorded in session_events, call_count is
--   derived from session_events, table_number is request/response/event payload
--   only, and pre_order_amount is sourced from linked orders.final_amount.
--
-- Human decision:
--   Approved in 600644_ChangeContract.md §7/§8 on 2026-07-16.
--
-- Non-goals:
--   - Do not modify 0118 cron behavior.
--   - Do not modify confirm_arrival().
--   - Do not add new schema columns.
--   - Do not drop no_show_auto_expire_minutes.
-- ============================================================================

create or replace function catchmenu_pos._record_waiting_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_from_status text,
  p_wait_number int,
  p_guest_locale text,
  p_phone_hash text,
  p_customer_id uuid,
  p_has_pre_order boolean,
  p_pre_order_amount int,
  p_table_number text,
  p_expires_at timestamptz,
  p_actor_type text,
  p_actor_id uuid,
  p_locale text,
  p_correlation_id text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_call_count int;
begin
  -- 세션 상태 전이 + 만료시각 스냅샷 저장 (§4)
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = p_expires_at,
    updated_at = now()
  where id = p_session_id;

  -- session_events (§1.1)
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'customer_called',
    p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number,
      'table_suggestion', p_table_number,
      'expires_at', p_expires_at,
      'has_pre_order', p_has_pre_order
    ),
    p_correlation_id, now()
  );

  -- call_count 파생 (§1.2)
  select count(*) into v_call_count
  from catchmenu_pos.session_events
  where session_id = p_session_id and event_type = 'customer_called';

  -- 알림 3종 (0115:495-532 원문 로직 그대로)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE', p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_number', p_table_number, 'guest_locale', p_guest_locale,
      'called_at', now(),
      'message', catchmenu_common.get_message(
        'waiting_called_alert', p_guest_locale,
        jsonb_build_object('wait_number', p_wait_number)
      )
    )
  );
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY', p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'display_number', p_wait_number,
      'table_number', p_table_number, 'queue_type', 'WAITING_CALL',
      'guest_locale', p_guest_locale
    )
  );
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS', p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash, 'customer_id', p_customer_id,
        'notification_type', 'WAITING_CALLED', 'wait_number', p_wait_number,
        'table_number', p_table_number, 'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1, 두 원본 함수 모두 이미 쓰던 패턴)
  insert into catchmenu_ledger.events (
    tenant_id, store_id, event_domain, event_type, event_version,
    subject_type, subject_id, from_state, to_state,
    caused_by_type, caused_by_id, event_payload, session_id,
    correlation_id, business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, 'session', 'customer_called', 1,
    'order_session', p_session_id, p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number, 'has_pre_order', p_has_pre_order,
      'pre_order_amount', p_pre_order_amount
    ),
    p_session_id, p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_suggestion', p_table_number, 'guest_locale', p_guest_locale,
      'has_pre_order', p_has_pre_order, 'pre_order_amount', p_pre_order_amount,
      'call_count', v_call_count, 'expires_at', p_expires_at,
      'did_called', true, 'push_sent', p_phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object('wait_number', p_wait_number),
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 상태 게이트: WAITING/ARRIVAL_PENDING 둘 다 허용 (재호출 지원, 0115:467-481 원문 유지 —
  -- 900101:291 "✓ 재호출"과 정합. 0050의 WAITING-only보다 이쪽이 설계 문서와 일치.
  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return catchmenu_common.build_error_response(
      p_error_key := case v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 만료시각 스냅샷 계산 (§4 — wait_call_expire_minutes 채택, 매장별 설정)
  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := v_session.session_status,
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := p_table_number, p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  -- 자동 선택 (0050:194-211 원문 로직 그대로 — WAITING만 대상, 재호출 개념 없음)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.session_status = 'WAITING'
  order by
    coalesce(os.queue_position, os.wait_number) asc nulls last,
    os.session_started_at asc
  limit 1
  for update of os skip locked;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'no_waiting_session_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_next_waiting_customer'
    );
  end if;

  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := 'WAITING',
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := null,  -- 자동 호출 경로는 p_table_number 파라미터 자체가 없음(§1.3)
    p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;

drop function if exists catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
);

comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';


-- ===== END sql/migrations/0160_call_waiting_customer_contract_recovery.sql =====


-- ===== BEGIN sql/migrations/0161_mark_no_show_overload_and_redesign.sql =====

-- ============================================================================
-- Migration: 0161_mark_no_show_overload_and_redesign.sql
-- Purpose:
--   Redesign mark_no_show() around a shared no-show transition core, add KDS
--   no-show grace expiry/recovery handling, drop the legacy 0050 overload, and
--   replace the WAITING_SESSION_EXPIRE cron inline phantom-column update with
--   store-scoped batch function calls.
--
-- Depends on:
--   0160_call_waiting_customer_contract_recovery.sql
--
-- Creates/Changes:
--   - Registers five error catalog keys required by the no-show redesign.
--   - Adds catchmenu_kds.kds_tickets.hold_expires_at.
--   - Creates catchmenu_pos.apply_no_show_transition(...).
--   - Replaces catchmenu_pos.mark_no_show(...).
--   - Creates catchmenu_pos.process_expired_no_shows(...).
--   - Creates catchmenu_kds.expire_no_show_kds_hold(...).
--   - Creates catchmenu_kds.recover_no_show_grace_ticket(...).
--   - Drops legacy catchmenu_pos.mark_no_show(uuid, uuid, uuid, text, uuid, text).
--   - Updates catchmenu_common.pg_cron_jobs WAITING_SESSION_EXPIRE sql_command.
--
-- Background:
--   600630_mark_no_show_overload_and_redesign confirmed that the old 0050
--   mark_no_show() overload conflicts with the current 0115 signature and that
--   the 0118 WAITING_SESSION_EXPIRE cron still referenced phantom columns
--   called_at/no_show_at/cancel_reason. 600632_Logic.md finalizes a shared
--   transition core, manual wrapper, automatic no-show batch, KDS grace expiry,
--   and late-arrival KDS ticket recovery.
--
-- Human decision:
--   Approved in 600634_ChangeContract.md §7/§8 on 2026-07-16, including the
--   corrected scope allowing only the hold_expires_at schema addition.
--
-- Non-goals:
--   - Do not modify confirm_arrival().
--   - Do not modify unrelated 0115 functions.
--   - Do not add schema columns other than kds_tickets.hold_expires_at.
--   - Do not implement complex late-arrival exception policy.
--   - Do not change Flutter/runtime code.
-- ============================================================================

insert into catchmenu_common.error_codes (
  code, error_key, error_domain, error_category,
  http_status, severity
) values
  (2026, 'invalid_trigger_source', 'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
  (5008, 'kds_ticket_not_found', 'KDS', 'NOT_FOUND', 404, 'INFO'),
  (5009, 'no_show_grace_already_expired', 'KDS', 'CONFLICT', 409, 'INFO'),
  (2027, 'session_not_markable', 'ORDER', 'CONFLICT', 409, 'INFO'),
  (5016, 'ticket_not_recoverable', 'KDS', 'CONFLICT', 409, 'INFO')
on conflict (code) do nothing;

alter table catchmenu_kds.kds_tickets
  add column if not exists hold_expires_at timestamptz;

create or replace function catchmenu_pos.apply_no_show_transition(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_type text,
  p_actor_id uuid,
  p_trigger_source text,
  p_reason_code text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_store,
                  catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_session record;
  v_existing record;
  v_old_score int;
  v_grace_minutes int := 15;
  v_grace_ticket_ids jsonb := '[]'::jsonb;
  v_grace_ticket_count int := 0;
  v_grace_expires_at timestamptz;
  v_audit_id uuid;
begin
  if p_trigger_source not in ('STAFF', 'SYSTEM') then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_trigger_source',
      p_params := jsonb_build_object('trigger_source', p_trigger_source),
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'apply_no_show_transition',
      p_session_id := p_session_id
    );
  end if;

  select arrival_reliability_score
  into v_old_score
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    arrival_reliability_score = greatest(0, coalesce(arrival_reliability_score, 100) - 20),
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and session_status = 'ARRIVAL_PENDING'
    and (
      p_trigger_source = 'STAFF'
      or (p_trigger_source = 'SYSTEM' and expires_at <= now())
    )
  returning
    id, wait_number, guest_locale, pre_order_created_at, order_id,
    expires_at as original_call_expires_at,
    arrival_reliability_score as new_score,
    business_day, business_timezone
  into v_session;

  if v_session.id is null then
    select id, session_status, expires_at
    into v_existing
    from catchmenu_pos.order_sessions
    where id = p_session_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id;

    if v_existing.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'waiting_session_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'apply_no_show_transition',
        p_session_id := p_session_id
      );
    elsif v_existing.session_status = 'NO_SHOW' then
      return catchmenu_common.build_success_response(
        p_message_key := 'no_show_already_applied',
        p_data := jsonb_build_object('session_id', p_session_id, 'idempotent', true),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'session_not_markable',
        p_params := jsonb_build_object(
          'current_status', v_existing.session_status,
          'expires_at', v_existing.expires_at,
          'trigger_source', p_trigger_source
        ),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'apply_no_show_transition',
        p_session_id := p_session_id
      );
    end if;
  end if;

  if v_session.pre_order_created_at is not null then
    if exists (
      select 1
      from information_schema.columns
      where table_schema = 'catchmenu_store'
        and table_name = 'store_settings'
        and column_name = 'no_show_kds_grace_minutes'
    ) then
      execute
        'select coalesce(no_show_kds_grace_minutes, 15)
           from catchmenu_store.store_settings
          where tenant_id = $1 and store_id = $2'
      into v_grace_minutes
      using p_tenant_id, p_store_id;
    end if;

    v_grace_minutes := coalesce(v_grace_minutes, 15);

    with graced as (
      update catchmenu_kds.kds_tickets kt
      set
        hold_reason = 'NO_SHOW_GRACE',
        hold_expires_at = now() + (v_grace_minutes || ' minutes')::interval,
        updated_at = now()
      from catchmenu_pos.orders o
      where o.session_id = p_session_id
        and kt.order_id = o.id
        and kt.tenant_id = p_tenant_id
        and kt.store_id = p_store_id
        and kt.kds_status = 'HOLD'
      returning kt.id, kt.hold_expires_at
    )
    select coalesce(jsonb_agg(id), '[]'::jsonb), count(*), max(hold_expires_at)
    into v_grace_ticket_ids, v_grace_ticket_count, v_grace_expires_at
    from graced;
  end if;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'no_show_marked',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order_session',
    p_subject_id := p_session_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'trigger_source', p_trigger_source,
      'reason_code', p_reason_code,
      'no_show_determined_at', now(),
      'original_call_expires_at', v_session.original_call_expires_at,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'kds_grace_ticket_ids', v_grace_ticket_ids,
      'kds_grace_ticket_count', v_grace_ticket_count,
      'kds_grace_expires_at', v_grace_expires_at,
      'arrival_reliability_score_new', v_session.new_score
    ),
    p_before_state := jsonb_build_object(
      'session_status', 'ARRIVAL_PENDING',
      'arrival_reliability_score', v_old_score,
      'kds_ticket_hold_reason', null
    ),
    p_after_state := jsonb_build_object(
      'session_status', 'NO_SHOW',
      'arrival_reliability_score', v_session.new_score,
      'kds_ticket_hold_reason', case when v_grace_ticket_count > 0 then 'NO_SHOW_GRACE' else null end
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_applied',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'idempotent', false,
      'audit_id', v_audit_id,
      'arrival_reliability_score', v_session.new_score,
      'kds_grace_ticket_count', v_grace_ticket_count,
      'kds_grace_ticket_ids', v_grace_ticket_ids
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, pg_catalog
as $$
begin
  return catchmenu_pos.apply_no_show_transition(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_trigger_source := 'STAFF',
    p_reason_code := null,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_pos.process_expired_no_shows(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, pg_catalog
as $$
declare
  v_session_id uuid;
  v_result jsonb;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_session_id in
    select id
    from catchmenu_pos.order_sessions
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and session_status = 'ARRIVAL_PENDING'
      and expires_at <= now()
    order by expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      v_result := catchmenu_pos.apply_no_show_transition(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_session_id := v_session_id,
        p_actor_type := 'SYSTEM',
        p_actor_id := null,
        p_trigger_source := 'SYSTEM',
        p_reason_code := 'WAIT_CALL_EXPIRED',
        p_correlation_id := p_correlation_id
      );

      if coalesce((v_result->>'success')::boolean, false) then
        v_processed := v_processed + 1;
      else
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
      end if;
    exception when others then
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_session_ids', v_failed_ids
  );
end;
$$;

create or replace function catchmenu_kds.expire_no_show_kds_hold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_ticket_id uuid;
  v_order_id uuid;
  v_hold_expires_at timestamptz;
  v_business_day date;
  v_business_timezone text;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_ticket_id, v_order_id, v_hold_expires_at, v_business_day, v_business_timezone in
    select id, order_id, hold_expires_at, business_day, business_timezone
    from catchmenu_kds.kds_tickets
    where tenant_id = p_tenant_id
      and store_id = p_store_id
      and kds_status = 'HOLD'
      and hold_reason = 'NO_SHOW_GRACE'
      and hold_expires_at <= now()
    order by hold_expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      update catchmenu_kds.kds_tickets
      set
        kds_status = 'CANCELLED',
        hold_reason = 'NO_SHOW_GRACE_EXPIRED',
        cancelled_at = now(),
        updated_at = now()
      where id = v_ticket_id
        and tenant_id = p_tenant_id
        and store_id = p_store_id
        and kds_status = 'HOLD'
        and hold_reason = 'NO_SHOW_GRACE'
        and hold_expires_at <= now();

      if found then
        perform catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_audit_domain := 'kds',
          p_audit_type := 'no_show_grace_expired',
          p_audit_category := 'OPERATIONAL',
          p_actor_type := 'SYSTEM',
          p_actor_id := null,
          p_subject_type := 'kds_ticket',
          p_subject_id := v_ticket_id,
          p_decision := 'COMPLETED',
          p_decision_payload := jsonb_build_object(
            'grace_expires_at', v_hold_expires_at,
            'cancelled_at', now()
          ),
          p_before_state := jsonb_build_object(
            'kds_status', 'HOLD',
            'hold_reason', 'NO_SHOW_GRACE'
          ),
          p_after_state := jsonb_build_object(
            'kds_status', 'CANCELLED',
            'hold_reason', 'NO_SHOW_GRACE_EXPIRED'
          ),
          p_order_id := v_order_id,
          p_kds_ticket_id := v_ticket_id,
          p_correlation_id := p_correlation_id,
          p_business_day := v_business_day,
          p_business_timezone := v_business_timezone
        );
        v_processed := v_processed + 1;
      else
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
      end if;
    exception when others then
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_ticket_ids', v_failed_ids
  );
end;
$$;

create or replace function catchmenu_kds.recover_no_show_grace_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kds_ticket_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common, pg_catalog
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'HOLD',
    hold_reason = null,
    hold_expires_at = null,
    updated_at = now()
  where id = p_kds_ticket_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and kds_status = 'HOLD'
    and hold_reason = 'NO_SHOW_GRACE'
    and hold_expires_at > now()
  returning *
  into v_ticket;

  if v_ticket.id is null then
    select *
    into v_ticket
    from catchmenu_kds.kds_tickets
    where id = p_kds_ticket_id
      and tenant_id = p_tenant_id
      and store_id = p_store_id;

    if v_ticket.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'kds_ticket_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    elsif v_ticket.kds_status = 'HOLD'
      and v_ticket.hold_reason = 'NO_SHOW_GRACE'
      and v_ticket.hold_expires_at <= now() then
      return catchmenu_common.build_error_response(
        p_error_key := 'no_show_grace_already_expired',
        p_params := jsonb_build_object('hold_expires_at', v_ticket.hold_expires_at),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'ticket_not_recoverable',
        p_params := jsonb_build_object(
          'kds_status', v_ticket.kds_status,
          'hold_reason', v_ticket.hold_reason
        ),
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'recover_no_show_grace_ticket'
      );
    end if;
  end if;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'no_show_grace_recovered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_kds_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'recovered_at', now(),
      'correlation_id', p_correlation_id
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'hold_reason', 'NO_SHOW_GRACE'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'hold_reason', null
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_kds_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_grace_recovered',
    p_data := jsonb_build_object(
      'kds_ticket_id', p_kds_ticket_id,
      'kds_status', 'HOLD',
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);

update catchmenu_common.pg_cron_jobs
set
  sql_command = $sql$
do $$
declare
  r record;
begin
  for r in
    select distinct tenant_id, store_id
    from catchmenu_pos.order_sessions
    where session_status = 'ARRIVAL_PENDING'
      and expires_at <= now()
  loop
    perform catchmenu_pos.process_expired_no_shows(
      p_tenant_id := r.tenant_id,
      p_store_id := r.store_id,
      p_batch_size := 100
    );
  end loop;

  for r in
    select distinct tenant_id, store_id
    from catchmenu_kds.kds_tickets
    where kds_status = 'HOLD'
      and hold_reason = 'NO_SHOW_GRACE'
      and hold_expires_at <= now()
  loop
    perform catchmenu_kds.expire_no_show_kds_hold(
      p_tenant_id := r.tenant_id,
      p_store_id := r.store_id,
      p_batch_size := 100
    );
  end loop;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now()
  where session_status = 'WAITING'
    and session_started_at < now() - interval '2 hours';
end $$;
$sql$,
  notes = 'Waiting no-show expiry now delegates to process_expired_no_shows() and expire_no_show_kds_hold(); WAITING stale-session cancellation remains.'
where job_code = 'WAITING_SESSION_EXPIRE';


-- ===== END sql/migrations/0161_mark_no_show_overload_and_redesign.sql =====


-- ===== BEGIN sql/migrations/0163_seat_waiting_customer_facade_correction.sql =====

-- 0163_seat_waiting_customer_facade_correction.sql
--
-- Purpose:
--   Rewrite catchmenu_pos.seat_waiting_customer() as a thin facade:
--   - remove phantom order_sessions.table_number/pre_order_amount access,
--   - resolve caller-facing table_number/table_code to canonical table_id,
--   - delegate the core late-binding state transition to
--     catchmenu_pos.bind_table_to_session(),
--   - preserve waiting-pipeline-specific diagnostics, realtime notifications,
--     and waiting/customer_seated ledger event.
--
-- Background:
--   docs/600000_implementation_lifecycle/600600_waiting_order_session/
--   600650_seat_waiting_customer_facade_correction/
--   600651_Overview_Seat_Waiting_Customer_Facade_Correction.md
--   600652_Logic_Seat_Waiting_Customer_Facade_Correction.md
--   600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md
--   600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md
--
-- Human decision:
--   600654_ChangeContract §9 all five items checked; §10 APPROVED
--   (2026-07-18).
--
-- Depends on:
--   0162_create_dining_table_admin_rpc.sql
--
-- Non-goals:
--   - Do not modify bind_table_to_session() / 0025.
--   - Do not modify 0115 source text or sibling waiting functions.
--   - Do not modify _record_waiting_call(), pre_order_while_waiting(),
--     dining_tables schema, or orders schema.

insert into catchmenu_common.message_catalog (
  message_key,
  locale,
  message_text
) values
  ('waiting_table_not_found', 'ko', '해당 테이블 번호를 찾을 수 없습니다'),
  ('waiting_table_not_found', 'en', 'Table number not found'),
  ('waiting_table_number_ambiguous', 'ko', '테이블 번호가 중복되어 특정할 수 없습니다'),
  ('waiting_table_number_ambiguous', 'en', 'Table number matches more than one table'),
  ('waiting_table_inactive', 'ko', '비활성화된 테이블입니다'),
  ('waiting_table_inactive', 'en', 'This table is inactive'),
  ('waiting_table_number_required', 'ko', '테이블 번호는 필수입니다'),
  ('waiting_table_number_required', 'en', 'Table number is required'),
  ('waiting_seat_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_seat_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code,
  error_key,
  error_domain,
  error_category,
  http_status,
  severity
) values
  (7073, 'waiting_table_not_found',
    'ORDER', 'NOT_FOUND', 404, 'WARNING'),
  (7074, 'waiting_table_number_ambiguous',
    'ORDER', 'CONFLICT', 409, 'WARNING'),
  (7075, 'waiting_table_inactive',
    'ORDER', 'CONFLICT', 409, 'WARNING'),
  (7076, 'waiting_table_number_required',
    'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
  (7077, 'waiting_seat_operation_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;

create or replace function catchmenu_pos._resolve_dining_table_by_number(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_number text
)
returns table (
  v_table_id uuid,
  v_status text
)
language plpgsql
stable
security definer
set search_path = catchmenu_store
as $$
declare
  v_matches uuid[];
begin
  select array_agg(id) into v_matches
  from catchmenu_store.dining_tables
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and table_code = p_table_number;

  if v_matches is null or array_length(v_matches, 1) = 0 then
    return query select null::uuid, 'NOT_FOUND'::text;
    return;
  end if;

  if array_length(v_matches, 1) > 1 then
    return query select null::uuid, 'AMBIGUOUS'::text;
    return;
  end if;

  if exists (
    select 1
    from catchmenu_store.dining_tables
    where id = v_matches[1]
      and is_active = true
  ) then
    return query select v_matches[1], 'FOUND'::text;
  else
    return query select v_matches[1], 'INACTIVE'::text;
  end if;
end;
$$;

create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_resolved record;
  v_bind_result jsonb;
  v_remaining_queue int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- 1. Session lookup. Pre-order amount is read through the 0160
  --    orders LEFT JOIN pattern; order_sessions.pre_order_amount does not exist.
  select os.id,
         os.wait_number,
         os.session_status,
         os.guest_count,
         os.guest_locale,
         os.phone_hash,
         os.customer_id,
         os.session_started_at,
         os.pre_order_created_at,
         os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 2. Preserve the original, more specific already-seated error before
  --    delegating to the stricter bind_table_to_session() preconditions.
  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 3. table_number is required because bind_table_to_session() requires a
  --    concrete table_id and order_sessions.table_id is null before seating.
  if p_table_number is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 4. Resolve table_number/table_code to canonical table_id.
  select * into v_resolved
  from catchmenu_pos._resolve_dining_table_by_number(
    p_tenant_id, p_store_id, p_table_number
  );

  if v_resolved.v_status = 'NOT_FOUND' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'AMBIGUOUS' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_ambiguous',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'INACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_inactive',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'table_number', p_table_number,
        'table_id', v_resolved.v_table_id
      )
    );
  end if;

  -- 5. Delegate canonical state transition to bind_table_to_session().
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := v_resolved.v_table_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_bind_result->>'success')::boolean, false) then
    -- Return bind_table_to_session()'s original flat error JSON unchanged.
    -- Re-wrapping these keys through build_error_response() is intentionally
    -- forbidden because some bind_table_to_session() keys are not registered
    -- in error_codes and would crash through log_diagnostic().
    return v_bind_result;
  end if;

  -- 6. Waiting-domain side effects preserved from the original facade.
  if v_session.pre_order_created_at is not null then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount', v_session.pre_order_amount
      )
    );
  end if;

  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null
    )
  );

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- 7. Waiting-domain ledger event distinct from bind_table_to_session()'s
  --    session/table_bound event.
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (now() - v_session.session_started_at)
      )::int,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_created_at is not null
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'late_binding_completed', true,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note', '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment', 'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'seat_waiting_customer_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_number', p_table_number
      )
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_seat_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;


-- ===== END sql/migrations/0163_seat_waiting_customer_facade_correction.sql =====


-- ===== BEGIN sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql =====

-- 0164_waiting_pipeline_sibling_functions_correction.sql
--
-- Purpose:
--   Correct the remaining four waiting-pipeline sibling functions from 0115:
--   - confirm_arrival()
--   - get_waiting_status()
--   - get_waiting_admin_view()
--   - cancel_waiting()
--
-- Background:
--   docs/600000_implementation_lifecycle/600600_waiting_order_session/
--   600660_waiting_pipeline_sibling_functions_correction/
--   600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md
--   600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md
--
-- Human decision:
--   600664_ChangeContract §9 all six items checked; §10 APPROVED
--   (2026-07-18).
--
-- Depends on:
--   0163_seat_waiting_customer_facade_correction.sql
--
-- Statement order:
--   1. message_catalog / error_codes INSERT block
--   2. confirm_arrival() CREATE OR REPLACE
--   3. get_waiting_status() CREATE OR REPLACE
--   4. get_waiting_admin_view() CREATE OR REPLACE
--   5. cancel_waiting() CREATE OR REPLACE
--
-- GRANT/REVOKE:
--   No new GRANT/REVOKE statements are needed. All four public signatures are
--   unchanged from 0115, so existing EXECUTE grants remain in effect.
--
-- Non-goals:
--   - Do not modify 0115 source text.
--   - Do not modify mark_session_arrived() / 0025.
--   - Do not modify seat_waiting_customer() / 0163.
--   - Do not add a cancel_waiting() state guard or table-release logic.
--   - Do not add schema columns.

insert into catchmenu_common.message_catalog (
  message_key,
  locale,
  message_text
) values
  ('waiting_confirm_arrival_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_confirm_arrival_failed', 'en', 'A temporary error occurred. Please try again'),
  ('waiting_cancel_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_cancel_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code,
  error_key,
  error_domain,
  error_category,
  http_status,
  severity
) values
  (7078, 'waiting_confirm_arrival_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR'),
  (7079, 'waiting_cancel_operation_failed',
    'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;

create or replace function catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_arrival_result jsonb;
begin
  select os.id, os.wait_number, os.session_status,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  v_arrival_result := catchmenu_pos.mark_session_arrived(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_arrival_result->>'success')::boolean, false) then
    return v_arrival_result;
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount
    )
  );

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'confirm_arrival_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'CUSTOMER',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_confirm_arrival_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

create or replace function catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.session_type, os.guest_count, os.guest_locale,
         os.pre_order_created_at,
         o.final_amount as pre_order_amount,
         dt.table_code as table_number,
         os.session_started_at,
         call_info.called_at,
         os.arrived_at,
         os.seated_at
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and wait_number < v_session.wait_number;

  v_est_wait_minutes := v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at', v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at', v_session.arrived_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position', catchmenu_common.get_message(
          'waiting_current_position',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('position', v_queue_position)
        ),
        'est_time', catchmenu_common.get_message(
          'waiting_est_time',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('minutes', v_est_wait_minutes)
        )
      )
    ),
    p_locale := p_locale
  );
end;
$$;

create or replace function catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', dt.table_code,
        'has_pre_order', os.pre_order_created_at is not null,
        'pre_order_amount', o.final_amount,
        'waited_minutes', extract(epoch from (now() - os.session_started_at))::int / 60,
        'called_at', call_info.called_at,
        'call_count', coalesce(call_info.call_count, 0),
        'is_foreign', os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case when os.session_status = 'WAITING' then 'CALL' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'SEAT' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'NO_SHOW' else null end,
          'CANCEL'
        )
      )
      order by os.queue_position asc nulls last, os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select count(*) as call_count, max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in ('WAITING', 'ARRIVAL_PENDING');

  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (where os.session_status = 'COMPLETED'),
    'cancelled', count(*) filter (where os.session_status = 'CANCELLED'),
    'no_show', count(*) filter (where os.session_status = 'NO_SHOW'),
    'current_waiting', jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (where os.pre_order_created_at is not null),
    'total_pre_order_amount', coalesce(
      sum(o.final_amount) filter (where os.pre_order_created_at is not null), 0
    ),
    'foreign_count', count(*) filter (where os.guest_locale <> 'ko'),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (coalesce(os.seated_at, now()) - os.session_started_at)) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting', jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;

create or replace function catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.guest_locale, os.pre_order_created_at,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  if v_session.pre_order_created_at is not null then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'cancel_waiting_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'cancel_reason', p_cancel_reason
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_cancel_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;


-- ===== END sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql =====


-- ===== BEGIN sql/migrations/0167_record_waiting_call_grant_correction.sql =====

-- 0167_record_waiting_call_grant_correction.sql
--
-- Purpose:
--   Correct EXECUTE privileges for the waiting-call internal helper and
--   automatic next-customer public RPC.
--
-- Depends on: 0166_canonical_kds_release_orchestration.sql
--   Sequential-numbering convention only; no functional dependency.

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;


-- ===== END sql/migrations/0167_record_waiting_call_grant_correction.sql =====
