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