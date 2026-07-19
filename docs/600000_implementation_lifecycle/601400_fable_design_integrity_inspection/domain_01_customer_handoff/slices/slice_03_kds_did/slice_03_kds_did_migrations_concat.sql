-- slice_03 — KDS/DID (600400 + 600800 + kds/did SQL)
-- Files: 16


-- ===== BEGIN sql/migrations/0016_create_kds_tickets.sql =====

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
      'COMMITTED',
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
    and kds_status in ('COMMITTED', 'COOKING');

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
    and kds_status in ('COMMITTED', 'COOKING', 'READY');

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
   Transition to COMMITTED only when all conditions_met are true.
   KDS release ALWAYS requires payment_confirmed = true in conditions_met.
   Payment approval alone is NOT sufficient — kds_release_authorized in
   payment_ledger must also be true.
   특허2 원칙: 사전 주문 후보를 즉시 KDS 티켓으로 생성하지 않는다.';
comment on column catchmenu_kds.kds_tickets.kds_status is
  'HOLD = all or some conditions not yet met. Kitchen does not see this ticket.
   CAPACITY_CHECKING = KDS Capacity Agent is evaluating kitchen load.
   COMMITTED = all conditions met, ready to send to kitchen display.
   COOKING = ticket visible on KDS, cooking in progress.
   READY = cooking complete, waiting to serve.
   SERVED = delivered to customer.
   COMPLETED = fully done.
   CANCELLED = cancelled before cooking.
   MANUAL_FALLBACK = staff handling manually, KDS bypassed.';
comment on column catchmenu_kds.kds_tickets.conditions_met is
  'Tracks which Late Binding conditions are satisfied.
   All must be true before HOLD → COMMITTED transition.
   arrived: customer physically arrived at store.
   table_confirmed: table assignment completed (Late Binding).
   payment_confirmed: payment_ledger.kds_release_authorized = true.
   kds_capacity_ok: kitchen load within acceptable threshold.
   menu_available: menu item not sold out.
   peak_time_ok: not in restricted peak period for this menu.
   no_show_risk_ok: customer arrival reliability score acceptable.
   특허2: 7개 핵심 조건 모두 충족 시 조리 실행 큐 투입.';
comment on column catchmenu_kds.kds_tickets.committed_at is
  'Timestamp when HOLD → COMMITTED transition occurred.
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

-- ===== END sql/migrations/0016_create_kds_tickets.sql =====


-- ===== BEGIN sql/migrations/0028_create_kds_capacity_commit_rpc.sql =====

-- 0028_create_kds_capacity_commit_rpc.sql
-- Purpose: KDS capacity evaluation and Late Binding commit RPC.
--          Evaluates all 7 conditions for each KDS ticket.
--          When all conditions met: HOLD → COMMITTED.
--          When conditions not met: updates conditions_met and stays HOLD.
--          특허2 core: KDS 수용상태 기반 Late Binding 조리 실행 큐 제어.
-- Depends on: 0027_create_payment_intent_rpc.sql
-- Creates:
--   function catchmenu_kds.evaluate_kds_capacity(...)
--   function catchmenu_kds.commit_kds_ticket(...)
--   function catchmenu_kds.authorize_kds_release(...)

create or replace function catchmenu_kds.evaluate_kds_capacity(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kitchen_zone text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_cooking_count int;
  v_hold_count int;
  v_ready_count int;
  v_capacity_ok boolean;
  v_threshold int := 8;
begin
  -- count active tickets per kitchen zone
  select
    count(*) filter (
      where kds_status in ('COOKING', 'COMMITTED')
    ),
    count(*) filter (
      where kds_status in ('HOLD', 'CAPACITY_CHECKING')
    ),
    count(*) filter (
      where kds_status = 'READY'
    )
  into v_cooking_count, v_hold_count, v_ready_count
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED')
    and (
      p_kitchen_zone is null
      or kitchen_zone = p_kitchen_zone
    );

  -- capacity ok if cooking + ready_to_commit below threshold
  v_capacity_ok := v_cooking_count < v_threshold;

  return jsonb_build_object(
    'cooking_count', v_cooking_count,
    'hold_count', v_hold_count,
    'ready_count', v_ready_count,
    'capacity_ok', v_capacity_ok,
    'threshold', v_threshold,
    'kitchen_zone', p_kitchen_zone
  );
end;
$$;


create or replace function catchmenu_kds.commit_kds_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_conditions jsonb default '{}'::jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_merged_conditions jsonb;
  v_all_met boolean;
  v_capacity jsonb;
  v_audit_id uuid;
begin
  -- input validation
  if p_ticket_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_id_required'
    );
  end if;

  if jsonb_typeof(coalesce(p_conditions, '{}'::jsonb)) <> 'object' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'conditions_must_be_object'
    );
  end if;

  -- ticket validation with lock
  select
    kt.id, kt.store_id, kt.tenant_id,
    kt.order_id, kt.order_item_id, kt.session_id,
    kt.kds_status, kt.conditions_met,
    kt.kitchen_zone, kt.priority,
    kt.estimated_minutes_snapshot,
    kt.business_day, kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  -- ticket must be in holdable state
  if v_ticket.kds_status not in ('HOLD', 'CAPACITY_CHECKING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- merge incoming conditions with existing
  v_merged_conditions :=
    coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || coalesce(p_conditions, '{}'::jsonb);

  -- evaluate KDS capacity for this kitchen zone
  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  -- update kds_capacity_ok from real-time evaluation
  v_merged_conditions := v_merged_conditions || jsonb_build_object(
    'kds_capacity_ok',
    (v_capacity->>'capacity_ok')::boolean
  );

  -- check all 7 conditions
  -- 특허2: 7개 조건 모두 true일 때만 COMMITTED 전환
  v_all_met := (
    coalesce(
      (v_merged_conditions->>'arrived')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'table_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'payment_confirmed')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'kds_capacity_ok')::boolean, false
    )
    and coalesce(
      (v_merged_conditions->>'menu_available')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'peak_time_ok')::boolean, true
    )
    and coalesce(
      (v_merged_conditions->>'no_show_risk_ok')::boolean, true
    )
  );

  if v_all_met then
    -- all conditions met → COMMITTED
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = v_merged_conditions,
      committed_at = now(),
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type,
      conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'all_conditions_met',
      v_ticket.kds_status, 'COMMITTED',
      'SYSTEM',
      v_merged_conditions,
      jsonb_build_object(
        'kitchen_zone', v_ticket.kitchen_zone,
        'kds_queue_length', v_capacity->>'cooking_count',
        'committed_at', now()
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
      order_id, kds_ticket_id,
      correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'kds', 'kds_committed', 1,
      'kds_ticket', p_ticket_id,
      v_ticket.kds_status, 'COMMITTED',
      'SYSTEM',
      jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'late_binding_commit', true
      ),
      v_ticket.order_id, p_ticket_id,
      p_correlation_id,
      v_ticket.business_day, v_ticket.business_timezone, now()
    );

    -- audit record for KDS commit
    v_audit_id := catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'kds',
      p_audit_type := 'kds_committed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'SYSTEM',
      p_actor_id := null,
      p_subject_type := 'kds_ticket',
      p_subject_id := p_ticket_id,
      p_decision := 'APPROVED',
      p_decision_payload := jsonb_build_object(
        'conditions_met', v_merged_conditions,
        'kitchen_zone', v_ticket.kitchen_zone,
        'committed_at', now()
      ),
      p_before_state := jsonb_build_object(
        'kds_status', v_ticket.kds_status,
        'conditions_met', v_ticket.conditions_met
      ),
      p_after_state := jsonb_build_object(
        'kds_status', 'COMMITTED',
        'conditions_met', v_merged_conditions
      ),
      p_order_id := v_ticket.order_id,
      p_kds_ticket_id := p_ticket_id,
      p_correlation_id := p_correlation_id,
      p_business_day := v_ticket.business_day,
      p_business_timezone := v_ticket.business_timezone
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'COMMITTED',
      'conditions_met', v_merged_conditions,
      'committed_at', now(),
      'kitchen_zone', v_ticket.kitchen_zone,
      'audit_id', v_audit_id,
      'message_code', 'kds_committed'
    );

  else
    -- conditions not all met → CAPACITY_CHECKING
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'CAPACITY_CHECKING',
      conditions_met = v_merged_conditions,
      capacity_check_at = now(),
      kds_queue_length_at_check =
        (v_capacity->>'cooking_count')::int,
      updated_at = now()
    where id = p_ticket_id;

    -- KDS event
    insert into catchmenu_kds.kds_events (
      tenant_id, store_id, ticket_id, order_id,
      event_type, from_status, to_status,
      caused_by_type, conditions_at_event,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      p_ticket_id, v_ticket.order_id,
      'condition_updated',
      v_ticket.kds_status, 'CAPACITY_CHECKING',
      'SYSTEM', v_merged_conditions,
      jsonb_build_object(
        'missing_conditions', jsonb_build_object(
          'arrived',
            coalesce(
              (v_merged_conditions->>'arrived')::boolean, false
            ),
          'table_confirmed',
            coalesce(
              (v_merged_conditions->>'table_confirmed')::boolean,
              false
            ),
          'payment_confirmed',
            coalesce(
              (v_merged_conditions->>'payment_confirmed')::boolean,
              false
            ),
          'kds_capacity_ok',
            coalesce(
              (v_merged_conditions->>'kds_capacity_ok')::boolean,
              false
            ),
          'menu_available',
            coalesce(
              (v_merged_conditions->>'menu_available')::boolean,
              true
            )
        ),
        'kitchen_zone', v_ticket.kitchen_zone
      ),
      p_correlation_id, now()
    );

    return jsonb_build_object(
      'success', true,
      'ticket_id', p_ticket_id,
      'kds_status', 'CAPACITY_CHECKING',
      'conditions_met', v_merged_conditions,
      'all_conditions_met', false,
      'missing_conditions', jsonb_build_object(
        'arrived',
          coalesce(
            (v_merged_conditions->>'arrived')::boolean, false
          ),
        'table_confirmed',
          coalesce(
            (v_merged_conditions->>'table_confirmed')::boolean,
            false
          ),
        'payment_confirmed',
          coalesce(
            (v_merged_conditions->>'payment_confirmed')::boolean,
            false
          ),
        'kds_capacity_ok',
          coalesce(
            (v_merged_conditions->>'kds_capacity_ok')::boolean,
            false
          ),
        'menu_available',
          coalesce(
            (v_merged_conditions->>'menu_available')::boolean,
            true
          )
      ),
      'capacity_detail', v_capacity,
      'message_code', 'kds_conditions_pending'
    );
  end if;
end;
$$;


create or replace function catchmenu_kds.authorize_kds_release(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_ledger record;
  v_audit_id uuid;
  v_tickets_ready int;
begin
  -- ledger validation
  select id, order_id, session_id,
         ledger_status, reconciliation_status,
         kds_release_authorized,
         business_day, business_timezone
  into v_ledger
  from catchmenu_payment.payment_ledger
  where id = p_ledger_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ledger.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_found'
    );
  end if;

  if v_ledger.kds_release_authorized then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_already_authorized'
    );
  end if;

  if v_ledger.ledger_status <> 'APPROVED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_approved',
      'ledger_status', v_ledger.ledger_status
    );
  end if;

  -- check no active PAYMENT_UNCERTAIN exception
  if exists (
    select 1
    from catchmenu_ledger.exceptions
    where subject_type = 'payment_intent'
      and store_id = p_store_id
      and exception_type = 'payment_uncertain'
      and exception_status in (
        'OPEN', 'ACKNOWLEDGED', 'IN_RECOVERY'
      )
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_uncertain_active',
      'message', 'Cannot authorize KDS release while PAYMENT_UNCERTAIN is open'
    );
  end if;

  -- authorize KDS release
  -- 특허1: 결제 원장 확인 + 불확실 예외 없음 → KDS 릴리즈 허용
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type,
    updated_at = now()
  where id = p_ledger_id;

  -- count tickets that become releasable
  select count(*)
  into v_tickets_ready
  from catchmenu_kds.kds_tickets
  where order_id = v_ledger.order_id
    and kds_status in ('COMMITTED', 'CAPACITY_CHECKING')
    and (conditions_met->>'payment_confirmed')::boolean = true;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_ledger.order_id, p_ledger_id,
    'kds_release_authorized',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
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
    event_payload, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'kds_release_authorized', 1,
    'payment_ledger', p_ledger_id,
    'APPROVED_NO_KDS_RELEASE', 'APPROVED_KDS_AUTHORIZED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_authorized',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'kds_release_authorized', true,
      'kds_tickets_releasable', v_tickets_ready,
      'authorized_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_release_authorized', false
    ),
    p_after_state := jsonb_build_object(
      'kds_release_authorized', true
    ),
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_session_id := v_ledger.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'kds_release_authorized', true,
    'kds_tickets_releasable', v_tickets_ready,
    'authorized_at', now(),
    'next_step', 'RUN_KDS_COMMIT_FOR_EACH_TICKET',
    'message_code', 'kds_release_authorized',
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
revoke all on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) from public;
grant execute on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) to authenticated;

revoke all on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) from public;
grant execute on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) to authenticated;

revoke all on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) from public;
grant execute on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) to authenticated;

comment on function catchmenu_kds.evaluate_kds_capacity(
  uuid, uuid, text
) is
  'Evaluates current KDS kitchen load per zone.
   Returns capacity_ok = true when cooking count below threshold.
   Called by commit_kds_ticket to check kds_capacity_ok condition.
   특허2: KDS 수용상태 실시간 판단 — 조리 큐 투입 가능 여부 결정.';

comment on function catchmenu_kds.commit_kds_ticket(
  uuid, uuid, uuid, jsonb, text
) is
  'KDS Late Binding commit RPC. Core of 특허2.
   Merges incoming conditions with existing conditions_met.
   Evaluates real-time KDS capacity for kitchen zone.
   When all 7 conditions true → HOLD/CAPACITY_CHECKING → COMMITTED.
   Otherwise → stays CAPACITY_CHECKING with updated conditions.
   Conditions: arrived, table_confirmed, payment_confirmed,
               kds_capacity_ok, menu_available,
               peak_time_ok, no_show_risk_ok.
   특허2: 7개 조건 모두 충족 시 조리 실행 큐 투입.';

comment on function catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
) is
  'Authorizes KDS release for a payment ledger entry.
   Sets kds_release_authorized = TRUE on payment_ledger.
   Requires ledger_status = APPROVED AND no active PAYMENT_UNCERTAIN.
   This is a separate step from payment approval.
   특허1: 결제 승인 ≠ KDS 자동 릴리즈.
          별도 authorize 단계 필수.
   After this: run commit_kds_ticket for each ticket in COMMITTED.';

-- ===== END sql/migrations/0028_create_kds_capacity_commit_rpc.sql =====


-- ===== BEGIN sql/migrations/0029_create_kds_cooking_rpc.sql =====

-- 0029_create_kds_cooking_rpc.sql
-- Purpose: KDS cooking lifecycle RPCs.
--          start_cooking: COMMITTED → COOKING.
--          complete_cooking: COOKING → READY.
--          serve_ticket: READY → SERVED.
--          complete_order_kds: all tickets done → order COMPLETED.
--          특허2: 조리 실행 큐 투입 후 완료까지 상태 전이 추적.
-- Depends on: 0028_create_kds_capacity_commit_rpc.sql
-- Creates:
--   function catchmenu_kds.start_cooking(...)
--   function catchmenu_kds.complete_cooking(...)
--   function catchmenu_kds.serve_ticket(...)
--   function catchmenu_kds.complete_order_kds(...)

create or replace function catchmenu_kds.start_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    estimated_minutes_snapshot,
    payment_ledger_id,
    conditions_met,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COMMITTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready_to_commit',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- verify payment_ledger kds_release_authorized
  if v_ticket.payment_ledger_id is not null then
    if not exists (
      select 1
      from catchmenu_payment.payment_ledger
      where id = v_ticket.payment_ledger_id
        and kds_release_authorized = true
    ) then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_release_not_authorized',
        'message', 'payment_ledger.kds_release_authorized must be true'
      );
    end if;
  end if;

  -- COMMITTED → COOKING
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COOKING',
    cooking_started_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item status
  update catchmenu_pos.order_items
  set
    item_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_item_id;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_started',
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    v_ticket.conditions_met,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'menu_name', v_ticket.menu_name_snapshot,
      'estimated_minutes', v_ticket.estimated_minutes_snapshot
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_cooking_started', 1,
    'kds_ticket', p_ticket_id,
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'ticket_number', v_ticket.ticket_number
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_started',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'cooking_started_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COMMITTED'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  -- update order status to COOKING if not already
  update catchmenu_pos.orders
  set
    order_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_id
    and order_status = 'CONFIRMED';

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'COOKING',
    'kitchen_zone', v_ticket.kitchen_zone,
    'cooking_started_at', now(),
    'estimated_minutes', v_ticket.estimated_minutes_snapshot,
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_kds.complete_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_ticket record;
  v_all_ready boolean;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COOKING' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_cooking',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- COOKING → READY
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'READY',
    ready_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item
  update catchmenu_pos.order_items
  set
    item_status = 'READY',
    updated_at = now()
  where id = (
    select order_item_id
    from catchmenu_kds.kds_tickets
    where id = p_ticket_id
  );

  -- check if all tickets for this order are READY/SERVED/COMPLETED
  select not exists (
    select 1
    from catchmenu_kds.kds_tickets
    where order_id = v_ticket.order_id
      and kds_status not in (
        'READY', 'SERVED', 'COMPLETED', 'CANCELLED'
      )
      and id <> p_ticket_id
  )
  into v_all_ready;

  -- if all ready, update order status
  if v_all_ready then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      updated_at = now()
    where id = v_ticket.order_id
      and order_status in ('CONFIRMED', 'COOKING');
  end if;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_completed',
    'COOKING', 'READY',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_ready', 1,
    'kds_ticket', p_ticket_id,
    'COOKING', 'READY',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'all_tickets_ready', v_all_ready,
      'ready_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'READY',
      'all_tickets_ready', v_all_ready
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'READY',
    'kitchen_zone', v_ticket.kitchen_zone,
    'ready_at', now(),
    'all_tickets_ready', v_all_ready,
    'order_status', case when v_all_ready then 'READY' else 'COOKING' end,
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_kds.serve_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_ticket record;
begin
  select id, order_id, kds_status,
         ticket_number, kitchen_zone,
         business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'READY' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- READY → SERVED
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'SERVED',
    served_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item
  update catchmenu_pos.order_items
  set
    item_status = 'SERVED',
    updated_at = now()
  where id = (
    select order_item_id
    from catchmenu_kds.kds_tickets
    where id = p_ticket_id
  );

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'served',
    'READY', 'SERVED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'served_at', now()
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
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_served', 1,
    'kds_ticket', p_ticket_id,
    'READY', 'SERVED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'SERVED',
    'served_at', now()
  );
end;
$$;


create or replace function catchmenu_kds.complete_order_kds(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_order record;
  v_incomplete_count int;
  v_audit_id uuid;
begin
  select id, order_status, session_id,
         order_number, business_day, business_timezone
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

  -- check all KDS tickets completed/served/cancelled
  select count(*)
  into v_incomplete_count
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and kds_status not in (
      'COMPLETED', 'SERVED', 'CANCELLED', 'READY'
    );

  if v_incomplete_count > 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'tickets_still_active',
      'incomplete_count', v_incomplete_count
    );
  end if;

  -- mark all SERVED/READY tickets as COMPLETED
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and kds_status in ('SERVED', 'READY');

  -- complete order
  update catchmenu_pos.orders
  set
    order_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where id = p_order_id;

  -- complete session
  update catchmenu_pos.order_sessions
  set
    session_status = 'COMPLETED',
    completed_at = now(),
    updated_at = now()
  where id = v_order.session_id
    and session_status not in ('COMPLETED', 'CANCELLED');

  -- order event
  insert into catchmenu_pos.order_events (
    tenant_id, store_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'order_completed',
    v_order.order_status, 'COMPLETED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
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
    event_payload,
    session_id, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'order_completed', 1,
    'order', p_order_id,
    v_order.order_status, 'COMPLETED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
    ),
    v_order.session_id, p_order_id,
    p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'order_completed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'order_number', v_order.order_number,
      'completed_at', now()
    ),
    p_before_state := jsonb_build_object(
      'order_status', v_order.order_status
    ),
    p_after_state := jsonb_build_object(
      'order_status', 'COMPLETED'
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
    'order_status', 'COMPLETED',
    'session_status', 'COMPLETED',
    'completed_at', now(),
    'audit_id', v_audit_id
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_kds.start_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.start_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.complete_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.complete_cooking(
    uuid, uuid, uuid, text, uuid, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.serve_ticket(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.serve_ticket(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.complete_order_kds(
    uuid, uuid, uuid, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.complete_order_kds(
    uuid, uuid, uuid, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_kds.start_cooking(
  uuid, uuid, uuid, text, uuid, uuid, text
) is
  'Transitions KDS ticket COMMITTED → COOKING.
   Verifies payment_ledger.kds_release_authorized = true before allowing.
   Updates order_item status to COOKING.
   Updates order status to COOKING if first ticket to start.
   특허1: KDS 릴리즈 권한 재확인 — 릴리즈 직전 최종 검증.
   특허2: 조리 시작 타임스탬프 → KPI 데이터.';

comment on function catchmenu_kds.complete_cooking(
  uuid, uuid, uuid, text, uuid, uuid, text
) is
  'Transitions KDS ticket COOKING → READY.
   Checks if all order tickets are ready → updates order to READY.
   특허2: 조리 완료 타임스탬프 → KDS 처리시간 KPI.
   특허3: 조리 완료 이벤트 → AI Agent 학습 데이터.';

comment on function catchmenu_kds.complete_order_kds(
  uuid, uuid, uuid, text, uuid, text
) is
  'Completes entire order after all KDS tickets served.
   Marks all SERVED/READY tickets as COMPLETED.
   Updates order and session to COMPLETED.
   특허3 다이어그램3: 완료 이벤트 → Task/Event 운영 원장 → AI Agent 학습.';

-- ===== END sql/migrations/0029_create_kds_cooking_rpc.sql =====


-- ===== BEGIN sql/migrations/0039_create_kds_bulk_commit_rpc.sql =====

-- 0039_create_kds_bulk_commit_rpc.sql
-- Purpose: KDS bulk commit and hold extension RPCs.
--          bulk_commit_kds_tickets: commits all eligible tickets for an order.
--          extend_kds_hold: extends hold timeout for pre-order tickets.
--          cancel_kds_hold: cancels all HOLD tickets for an order.
--          특허2 core: 주문 단위 일괄 KDS 커밋 + HOLD 연장 제어.
-- Depends on: 0038_create_toss_webhook_processor_rpc.sql
-- Creates:
--   function catchmenu_kds.bulk_commit_kds_tickets(...)
--   function catchmenu_kds.extend_kds_hold(...)
--   function catchmenu_kds.cancel_kds_hold(...)

create or replace function catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_force_conditions jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_payment,
                  catchmenu_ledger, catchmenu_common
as $$
declare
  v_ticket record;
  v_committed_count int := 0;
  v_pending_count int := 0;
  v_skipped_count int := 0;
  v_commit_result jsonb;
  v_ticket_results jsonb := '[]'::jsonb;
  v_payment_authorized boolean;
  v_merged_conditions jsonb;
begin
  -- check payment ledger kds_release_authorized
  select coalesce(bool_or(kds_release_authorized), false)
  into v_payment_authorized
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'APPROVED';

  if not v_payment_authorized then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_not_authorized',
      'message', 'payment_ledger.kds_release_authorized must be true for all tickets',
      'order_id', p_order_id
    );
  end if;

  -- process each holdable ticket for this order
  for v_ticket in
    select id, kds_status, conditions_met,
           kitchen_zone, ticket_number
    from catchmenu_kds.kds_tickets
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status in ('HOLD', 'CAPACITY_CHECKING')
    order by priority asc, ticket_created_at asc
  loop
    -- merge force_conditions if provided
    v_merged_conditions := coalesce(
      v_ticket.conditions_met, '{}'::jsonb
    ) || coalesce(p_force_conditions, '{}'::jsonb);

    -- attempt commit
    v_commit_result := catchmenu_kds.commit_kds_ticket(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_ticket_id := v_ticket.id,
      p_conditions := v_merged_conditions,
      p_correlation_id := p_correlation_id
    );

    if (v_commit_result->>'kds_status') = 'COMMITTED' then
      v_committed_count := v_committed_count + 1;
    elsif (v_commit_result->>'kds_status') = 'CAPACITY_CHECKING' then
      v_pending_count := v_pending_count + 1;
    else
      v_skipped_count := v_skipped_count + 1;
    end if;

    v_ticket_results := v_ticket_results || jsonb_build_array(
      jsonb_build_object(
        'ticket_id', v_ticket.id,
        'ticket_number', v_ticket.ticket_number,
        'kitchen_zone', v_ticket.kitchen_zone,
        'kds_status', v_commit_result->>'kds_status',
        'all_conditions_met',
          coalesce(
            (v_commit_result->>'all_conditions_met')::boolean,
            (v_commit_result->>'kds_status') = 'COMMITTED'
          )
      )
    );
  end loop;

  -- ledger event for bulk commit
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  )
  select
    p_tenant_id, p_store_id,
    'kds', 'kds_bulk_commit_attempted', 1,
    'order', p_order_id,
    'HOLD_OR_CHECKING', 'BULK_COMMIT_ATTEMPTED',
    'SYSTEM',
    jsonb_build_object(
      'committed_count', v_committed_count,
      'pending_count', v_pending_count,
      'skipped_count', v_skipped_count,
      'ticket_results', v_ticket_results
    ),
    p_order_id, p_correlation_id,
    business_day, business_timezone, now()
  from catchmenu_pos.orders
  where id = p_order_id;

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'committed_count', v_committed_count,
    'pending_count', v_pending_count,
    'skipped_count', v_skipped_count,
    'total_processed',
      v_committed_count + v_pending_count + v_skipped_count,
    'all_committed', v_pending_count = 0 and v_skipped_count = 0,
    'ticket_results', v_ticket_results,
    'message_code', case
      when v_committed_count > 0 and v_pending_count = 0
      then 'all_tickets_committed'
      when v_committed_count > 0 and v_pending_count > 0
      then 'partial_tickets_committed'
      else 'no_tickets_committed'
    end
  );
end;
$$;


create or replace function catchmenu_kds.extend_kds_hold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_extend_minutes int,
  p_extend_reason text,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_ticket record;
begin
  if p_extend_minutes <= 0 or p_extend_minutes > 120 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_extend_minutes',
      'message', 'extend_minutes must be between 1 and 120'
    );
  end if;

  if trim(coalesce(p_extend_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'extend_reason_required'
    );
  end if;

  select id, order_id, kds_status,
         ticket_number, kitchen_zone,
         pre_order_expires_at,
         business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  join catchmenu_pos.order_sessions os
    on os.id = kt.session_id
  where kt.id = p_ticket_id
    and kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
  for update of kt;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status not in ('HOLD', 'CAPACITY_CHECKING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_in_hold',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- extend pre_order_expires_at on session
  update catchmenu_pos.order_sessions
  set
    pre_order_expires_at = coalesce(
      pre_order_expires_at, now()
    ) + (p_extend_minutes || ' minutes')::interval,
    updated_at = now()
  where id = (
    select session_id
    from catchmenu_kds.kds_tickets
    where id = p_ticket_id
  );

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'hold_extended',
    v_ticket.kds_status, v_ticket.kds_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'extend_minutes', p_extend_minutes,
      'extend_reason', p_extend_reason,
      'ticket_number', v_ticket.ticket_number
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
    event_payload, order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_hold_extended', 1,
    'kds_ticket', p_ticket_id,
    v_ticket.kds_status, v_ticket.kds_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'extend_minutes', p_extend_minutes,
      'extend_reason', p_extend_reason,
      'kitchen_zone', v_ticket.kitchen_zone
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', v_ticket.kds_status,
    'extended_minutes', p_extend_minutes,
    'extend_reason', p_extend_reason,
    'message_code', 'kds_hold_extended'
  );
end;
$$;


create or replace function catchmenu_kds.cancel_kds_hold(
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
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_cancelled_count int;
  v_order record;
  v_audit_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select id, order_number, business_day, business_timezone
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  -- cancel all HOLD/CAPACITY_CHECKING tickets
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    hold_reason = p_cancel_reason,
    cancelled_at = now(),
    updated_at = now()
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_cancelled_count = row_count;

  -- KDS events for each cancelled ticket
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  )
  select
    p_tenant_id, p_store_id, id, p_order_id,
    'ticket_cancelled', kds_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_via', 'cancel_kds_hold'
    ),
    p_correlation_id, now()
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and store_id = p_store_id
    and kds_status = 'CANCELLED'
    and cancelled_at >= now() - interval '5 seconds';

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_hold_cancelled', 1,
    'order', p_order_id,
    'HOLD', 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancelled_tickets', v_cancelled_count,
      'cancel_reason', p_cancel_reason,
      'order_number', v_order.order_number
    ),
    p_order_id, p_correlation_id,
    v_order.business_day, v_order.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_hold_cancelled',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'cancelled_tickets', v_cancelled_count,
      'order_number', v_order.order_number
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_order.business_day,
    p_business_timezone := v_order.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'cancelled_tickets', v_cancelled_count,
    'cancel_reason', p_cancel_reason,
    'audit_id', v_audit_id,
    'message_code', case v_cancelled_count
      when 0 then 'no_hold_tickets_found'
      else 'kds_hold_cancelled'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_kds.bulk_commit_kds_tickets(
    uuid, uuid, uuid, jsonb, text
  ) from public;
  grant execute on function catchmenu_kds.bulk_commit_kds_tickets(
    uuid, uuid, uuid, jsonb, text
  ) to authenticated;

  revoke all on function catchmenu_kds.extend_kds_hold(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.extend_kds_hold(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_kds.cancel_kds_hold(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_kds.cancel_kds_hold(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_kds.bulk_commit_kds_tickets(
  uuid, uuid, uuid, jsonb, text
) is
  'Bulk commits all eligible KDS tickets for an order.
   Checks payment_ledger.kds_release_authorized before processing.
   Calls commit_kds_ticket for each HOLD/CAPACITY_CHECKING ticket.
   Returns per-ticket results including commit status.
   특허2: 결제 확인 후 주문 단위 일괄 KDS 커밋.
   force_conditions can override specific conditions for staff use.';

comment on function catchmenu_kds.extend_kds_hold(
  uuid, uuid, uuid, int, text, text, uuid, text
) is
  'Extends KDS HOLD timeout for a pre-order ticket.
   Updates session pre_order_expires_at.
   Used when customer arrival is delayed but order should be kept.
   특허2: 사전주문 HOLD 연장 — 고객 도착 지연 시 티켓 유지.
   Max extension 120 minutes per call.';

comment on function catchmenu_kds.cancel_kds_hold(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Cancels all HOLD and CAPACITY_CHECKING KDS tickets for an order.
   Used when order is cancelled or customer no-show confirmed.
   Writes audit record for all cancellations.
   특허2: 노쇼 또는 주문 취소 시 HOLD 티켓 일괄 취소.';

-- ===== END sql/migrations/0039_create_kds_bulk_commit_rpc.sql =====


-- ===== BEGIN sql/migrations/0043_create_did_display_rpc.sql =====

-- 0043_create_did_display_rpc.sql
-- Purpose: DID (Digital Information Display) customer display RPCs.
--          get_did_display_state: returns current display state for DID.
--          update_did_display: updates customer-facing display content.
--          notify_customer_ready: triggers pickup notification on DID.
--          특허1: DID/CMS 고객 안내 표시 + 증빙 기록.
-- Depends on: 0042_create_delivery_order_intake_rpc.sql
-- Creates:
--   function catchmenu_store.get_did_display_state(...)
--   function catchmenu_store.notify_customer_ready(...)
--   function catchmenu_store.update_did_display(...)

create or replace function catchmenu_store.get_did_display_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_kds, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_waiting_sessions jsonb;
  v_ready_orders jsonb;
  v_cooking_summary jsonb;
  v_called_sessions jsonb;
  v_business_day date;
begin
  -- store info
  select id, store_name, store_type, timezone
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

  -- waiting queue (WAITING/ARRIVAL_PENDING sessions)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', s.id,
        'wait_number', s.wait_number,
        'queue_position', s.queue_position,
        'session_status', s.session_status,
        'guest_count', s.guest_count,
        'wait_since', s.session_started_at,
        'session_type', s.session_type
      )
      order by s.wait_number asc nulls last,
               s.session_started_at asc
    ),
    '[]'::jsonb
  )
  into v_waiting_sessions
  from catchmenu_pos.order_sessions s
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.session_status in ('WAITING', 'ARRIVAL_PENDING')
    and s.business_day = v_business_day;

  -- called/ready sessions (for DID customer notification)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'wait_number', s.wait_number,
        'session_status', s.session_status,
        'called_at', s.arrived_at
      )
      order by s.arrived_at desc
    ),
    '[]'::jsonb
  )
  into v_called_sessions
  from catchmenu_pos.order_sessions s
  where s.store_id = p_store_id
    and s.tenant_id = p_tenant_id
    and s.session_status = 'ARRIVAL_PENDING'
    and s.arrived_at >= now() - interval '10 minutes'
    and s.business_day = v_business_day;

  -- ready orders for pickup notification
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_type', o.order_type,
        'ready_at', kt.ready_at
      )
      order by kt.ready_at asc
    ),
    '[]'::jsonb
  )
  into v_ready_orders
  from catchmenu_pos.orders o
  join (
    select order_id, max(ready_at) as ready_at
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and kds_status = 'READY'
    group by order_id
    having count(*) filter (
      where kds_status not in ('READY', 'SERVED', 'COMPLETED', 'CANCELLED')
    ) = 0
  ) kt on kt.order_id = o.id
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.order_status = 'READY'
    and o.business_day = v_business_day;

  -- cooking summary by kitchen zone
  select coalesce(
    jsonb_object_agg(
      coalesce(kt.kitchen_zone, 'GENERAL'),
      jsonb_build_object(
        'cooking_count', count(*) filter (
          where kt.kds_status = 'COOKING'
        ),
        'ready_count', count(*) filter (
          where kt.kds_status = 'READY'
        ),
        'hold_count', count(*) filter (
          where kt.kds_status in ('HOLD', 'CAPACITY_CHECKING')
        )
      )
    ),
    '{}'::jsonb
  )
  into v_cooking_summary
  from catchmenu_kds.kds_tickets kt
  where kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
    and kt.business_day = v_business_day
    and kt.kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type
    ),
    'display', jsonb_build_object(
      'waiting_sessions', v_waiting_sessions,
      'called_sessions', v_called_sessions,
      'ready_orders', v_ready_orders,
      'cooking_summary', v_cooking_summary,
      'waiting_count',
        jsonb_array_length(v_waiting_sessions),
      'ready_count',
        jsonb_array_length(v_ready_orders)
    ),
    'business_day', v_business_day,
    'refreshed_at', now(),
    'message_code', 'did_display_state_loaded'
  );
end;
$$;


create or replace function catchmenu_store.notify_customer_ready(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_notification_type text default 'ORDER_READY',
  p_display_message text default null,
  p_sound_alert boolean default true,
  p_actor_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_order record;
  v_session record;
  v_notification_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_display_text text;
begin
  if p_notification_type not in (
    'ORDER_READY',
    'WAITING_CALLED',
    'TABLE_READY',
    'ORDER_DELAYED',
    'CUSTOM'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_notification_type'
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- order validation
  select
    o.id, o.order_number, o.order_status,
    o.order_type, o.session_id,
    o.business_day, o.business_timezone
  into v_order
  from catchmenu_pos.orders o
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_found'
    );
  end if;

  -- get session for wait number
  if v_order.session_id is not null then
    select id, wait_number, guest_locale
    into v_session
    from catchmenu_pos.order_sessions
    where id = v_order.session_id;
  end if;

  -- build display message
  v_display_text := coalesce(
    p_display_message,
    case p_notification_type
      when 'ORDER_READY' then
        v_order.order_number || '번 주문이 준비되었습니다'
      when 'WAITING_CALLED' then
        coalesce(
          v_session.wait_number::text, ''
        ) || '번 고객님 입장해 주세요'
      when 'TABLE_READY' then
        '테이블이 준비되었습니다'
      when 'ORDER_DELAYED' then
        v_order.order_number || '번 주문이 조금 늦어지고 있습니다'
      else p_display_message
    end
  );

  -- create evidence of customer notification
  -- 특허1: 고객 안내 메시지 증빙 보관
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    order_id,
    customer_visible_message,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'ALLERGEN_DISPLAY_EVIDENCE',
    'CREATED', 'LOW',
    'order', p_order_id,
    p_order_id,
    v_display_text,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_notification_id;

  -- update order status to READY if ORDER_READY
  if p_notification_type = 'ORDER_READY'
    and v_order.order_status in ('COOKING', 'CONFIRMED')
  then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      updated_at = now()
    where id = p_order_id;
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'customer_notified', 1,
    'order', p_order_id,
    v_order.order_status,
    case p_notification_type
      when 'ORDER_READY' then 'READY'
      else v_order.order_status
    end,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'notification_type', p_notification_type,
      'display_message', v_display_text,
      'sound_alert', p_sound_alert,
      'order_number', v_order.order_number,
      'wait_number', v_session.wait_number
    ),
    p_order_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit record for customer notification evidence
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'session',
    p_audit_type := 'customer_notified',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'notification_type', p_notification_type,
      'display_message', v_display_text,
      'sound_alert', p_sound_alert,
      'order_number', v_order.order_number,
      'evidence_id', v_notification_id
    ),
    p_evidence_packet_id := v_notification_id,
    p_order_id := p_order_id,
    p_session_id := v_order.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'order_id', p_order_id,
    'order_number', v_order.order_number,
    'notification_type', p_notification_type,
    'display_message', v_display_text,
    'sound_alert', p_sound_alert,
    'wait_number', v_session.wait_number,
    'evidence_id', v_notification_id,
    'audit_id', v_audit_id,
    'message_code', 'customer_notified'
  );
end;
$$;


create or replace function catchmenu_store.update_did_display(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_display_mode text,
  p_display_content jsonb default '{}'::jsonb,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_device record;
  v_business_day date;
  v_timezone text;
begin
  if p_display_mode not in (
    'NORMAL',
    'WAITING_QUEUE',
    'ORDER_READY',
    'PROMOTION',
    'NOTICE',
    'CLOSED',
    'EMERGENCY'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_display_mode'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- device validation
  select id, device_code, device_name,
         device_type, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and device_type in ('DID', 'CMS')
    and is_active = true;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'did_device_not_found'
    );
  end if;

  -- ledger event for display update
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'device', 'did_display_updated', 1,
    'device', p_device_id,
    null, p_display_mode,
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'display_mode', p_display_mode,
      'display_content', p_display_content,
      'device_code', v_device.device_code
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'device_code', v_device.device_code,
    'display_mode', p_display_mode,
    'display_content', p_display_content,
    'updated_at', now(),
    'message_code', 'did_display_updated'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_store.get_did_display_state(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_store.get_did_display_state(
    uuid, uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_store.notify_customer_ready(
    uuid, uuid, uuid, text, text, boolean, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.notify_customer_ready(
    uuid, uuid, uuid, text, text, boolean, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_store.update_did_display(
    uuid, uuid, uuid, text, jsonb, text, uuid, text
  ) from public;
  grant execute on function catchmenu_store.update_did_display(
    uuid, uuid, uuid, text, jsonb, text, uuid, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_store.get_did_display_state(
  uuid, uuid, uuid
) is
  'Returns current DID display state for customer-facing screens.
   Includes: waiting queue, called sessions, ready orders,
   cooking summary by kitchen zone.
   Called by DID device on polling interval.
   특허1: DID 고객 대기 표시 — 대기번호/주문준비 실시간 표출.';

comment on function catchmenu_store.notify_customer_ready(
  uuid, uuid, uuid, text, text, boolean, text, uuid, text
) is
  'Triggers customer pickup notification on DID.
   Creates evidence packet preserving customer-visible message.
   Supports ORDER_READY, WAITING_CALLED, TABLE_READY, CUSTOM.
   Evidence is required for customer dispute resolution.
   특허1: 고객 안내 메시지 증빙 보관.
   어떤 메시지가 어느 시점에 표시되었는지 audit trail 유지.';

comment on function catchmenu_store.update_did_display(
  uuid, uuid, uuid, text, jsonb, text, uuid, text
) is
  'Updates DID device display mode and content.
   NORMAL = standard operation view.
   WAITING_QUEUE = queue display.
   ORDER_READY = pickup notification.
   PROMOTION = promotional content.
   NOTICE = staff notice.
   CLOSED = store closed message.
   EMERGENCY = emergency announcement.';

-- ===== END sql/migrations/0043_create_did_display_rpc.sql =====


-- ===== BEGIN sql/migrations/0070_create_flutter_bootstrap_rpc.sql =====

-- 0070_create_flutter_bootstrap_rpc.sql
-- Purpose: Flutter app bootstrap and device initialization RPCs.
--          Single RPC call on app startup returns everything
--          Flutter needs: store config, menus, realtime channels,
--          device trust status, KDS state, staff permissions.
--          특허4: Zero Trust 디바이스 초기화 + 앱 부트스트랩.
-- Depends on: 0069_create_pgvector_knowledge_rpc.sql
-- Creates:
--   function catchmenu_common.bootstrap_app(...)
--   function catchmenu_common.bootstrap_kds_app(...)
--   function catchmenu_common.bootstrap_kiosk_app(...)
--   function catchmenu_common.bootstrap_staff_app(...)
--   function catchmenu_common.heartbeat(...)

-- =============================================
-- bootstrap_app: Universal entry point
-- Flutter 앱 시작 시 단일 RPC 호출
-- =============================================
create or replace function
  catchmenu_common.bootstrap_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_device_type text,
  p_app_version text default null,
  p_locale text default 'ko',
  p_os_type text default null,
  p_ip_address text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_device record;
  v_settings record;
  v_business_day date;
  v_bootstrap_id uuid;
  v_realtime_config jsonb;
  v_menu_catalog jsonb;
  v_floor_map jsonb;
  v_store_notices jsonb;
  v_kds_state jsonb;
  v_payment_uncertain_active boolean := false;
  v_manual_fallback_active boolean := false;
begin
  v_bootstrap_id := gen_random_uuid();

  -- STEP 1: Validate store
  select id, store_name, store_type,
         store_status, timezone
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
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id
    );
  end if;

  v_business_day := (timezone(
    v_store.timezone, now()
  ))::date;

  -- STEP 2: Validate and update device
  -- Zero Trust: UNTRUSTED devices get minimal config
  select id, device_code, device_name,
         device_type, device_role,
         trust_level, device_status,
         app_version
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- update device heartbeat and version
  update catchmenu_store.device_registry
  set
    device_status = case trust_level
      when 'TRUSTED' then 'ONLINE'
      when 'PENDING' then 'OFFLINE'
      else 'OFFLINE'
    end,
    last_seen_at = now(),
    last_heartbeat_at = now(),
    app_version = coalesce(
      p_app_version, app_version
    ),
    ip_address = coalesce(p_ip_address, ip_address),
    updated_at = now()
  where id = p_device_id;

  -- UNTRUSTED device: return minimal config
  if v_device.trust_level in (
    'UNTRUSTED', 'REVOKED'
  ) then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'AUTH',
      p_log_event := 'untrusted_device_bootstrap',
      p_message :=
        'Bootstrap attempted by '
        || v_device.trust_level
        || ' device: ' || v_device.device_code,
      p_error_key := 'device_not_trusted',
      p_rpc_name := 'bootstrap_app',
      p_correlation_id := p_correlation_id,
      p_device_id := p_device_id,
      p_details := jsonb_build_object(
        'device_code', v_device.device_code,
        'trust_level', v_device.trust_level,
        'app_version', p_app_version
      )
    );

    return jsonb_build_object(
      'success', false,
      'bootstrap_id', v_bootstrap_id,
      'trust_status', v_device.trust_level,
      'error', jsonb_build_object(
        'code', 1001,
        'key', 'device_not_trusted',
        'message', catchmenu_common.get_message(
          'device_not_trusted', p_locale, null
        ),
        'action', 'CONTACT_MANAGER_FOR_TRUST'
      ),
      'device', jsonb_build_object(
        'id', v_device.id,
        'device_code', v_device.device_code,
        'trust_level', v_device.trust_level
      )
    );
  end if;

  -- STEP 3: Get store settings
  select store_mode, waiting_enabled,
         pre_order_enabled, holiday_mode,
         kds_capacity_threshold_per_zone,
         kds_capacity_threshold_total,
         sound_alert_enabled,
         did_refresh_interval_seconds
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- STEP 4: Get realtime config for device
  v_realtime_config :=
    catchmenu_common.get_realtime_config(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_device_type := p_device_type
    );

  -- STEP 5: Check critical operational state
  -- PAYMENT_UNCERTAIN active?
  select exists (
    select 1
    from catchmenu_payment.payment_intents
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and intent_status = 'UNCERTAIN'
  ) into v_payment_uncertain_active;

  -- Manual fallback active?
  select exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and fallback_status in (
        'ACTIVE', 'RECOVERING'
      )
  ) into v_manual_fallback_active;

  -- STEP 6: HQ notices for store
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'notice_id', id,
        'notice_code', notice_code,
        'notice_type', notice_type,
        'title', title,
        'body', body,
        'priority', priority,
        'read_required', read_required,
        'valid_until', valid_until
      )
      order by
        case priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          when 'NORMAL' then 2
          else 3
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_store_notices
  from catchmenu_hq.hq_notices
  where tenant_id = p_tenant_id
    and notice_status = 'ACTIVE'
    and (
      valid_until is null
      or valid_until > now()
    )
    and (
      target_all_stores = true
      or target_store_ids @>
        to_jsonb(p_store_id)
    )
  limit 10;

  -- STEP 7: Device-specific data
  -- POS/STAFF: floor map
  if p_device_type in ('POS', 'STAFF_APP') then
    v_floor_map :=
      catchmenu_store.get_table_floor_map(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id
      );
  end if;

  -- KDS: current ticket state
  if p_device_type = 'KDS' then
    select jsonb_build_object(
      'hold_count', count(*) filter (
        where kds_status = 'HOLD'
      ),
      'capacity_checking', count(*) filter (
        where kds_status = 'CAPACITY_CHECKING'
      ),
      'cooking_count', count(*) filter (
        where kds_status = 'COOKING'
      ),
      'ready_count', count(*) filter (
        where kds_status = 'READY'
      ),
      'active_tickets', coalesce(
        jsonb_agg(
          jsonb_build_object(
            'ticket_id', id,
            'ticket_number', ticket_number,
            'kds_status', kds_status,
            'kitchen_zone', kitchen_zone,
            'menu_name', menu_name_snapshot,
            'quantity', quantity_snapshot,
            'estimated_minutes',
              estimated_minutes_snapshot,
            'cooking_started_at',
              cooking_started_at,
            'conditions_met', conditions_met
          )
          order by
            case kds_status
              when 'COOKING' then 0
              when 'COMMITTED' then 1
              when 'CAPACITY_CHECKING' then 2
              when 'HOLD' then 3
              else 4
            end,
            ticket_created_at asc
        ) filter (
          where kds_status in (
            'COOKING', 'READY',
            'COMMITTED',
            'CAPACITY_CHECKING'
          )
        ),
        '[]'::jsonb
      )
    )
    into v_kds_state
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and kds_status not in (
        'COMPLETED', 'CANCELLED', 'SERVED'
      );
  end if;

  -- KIOSK/DID: menu catalog with i18n
  if p_device_type in ('KIOSK', 'DID') then
    v_menu_catalog :=
      catchmenu_pos.get_menu_catalog_i18n(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_locale := p_locale,
        p_include_hidden := false,
        p_include_sold_out := true,
        p_include_allergens := true
      );
  end if;

  -- diagnostic log
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'app_bootstrapped',
    p_message :=
      'App bootstrap: ' || p_device_type
      || ' device=' || v_device.device_code
      || ' v=' || coalesce(p_app_version, 'N/A')
      || ' trust=' || v_device.trust_level,
    p_rpc_name := 'bootstrap_app',
    p_correlation_id := p_correlation_id,
    p_device_id := p_device_id,
    p_details := jsonb_build_object(
      'bootstrap_id', v_bootstrap_id,
      'device_type', p_device_type,
      'device_code', v_device.device_code,
      'app_version', p_app_version,
      'store_mode',
        coalesce(v_settings.store_mode, 'NORMAL'),
      'payment_uncertain_active',
        v_payment_uncertain_active,
      'manual_fallback_active',
        v_manual_fallback_active
    )
  );

  return jsonb_build_object(
    'success', true,
    'bootstrap_id', v_bootstrap_id,

    -- store info
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_type', v_store.store_type,
      'store_status', v_store.store_status,
      'timezone', v_store.timezone,
      'business_day', v_business_day
    ),

    -- device info
    'device', jsonb_build_object(
      'id', v_device.id,
      'device_code', v_device.device_code,
      'device_name', v_device.device_name,
      'device_type', v_device.device_type,
      'device_role', v_device.device_role,
      'trust_level', v_device.trust_level,
      'device_status', 'ONLINE'
    ),

    -- operational settings
    'settings', jsonb_build_object(
      'store_mode', coalesce(
        v_settings.store_mode, 'NORMAL'
      ),
      'waiting_enabled', coalesce(
        v_settings.waiting_enabled, true
      ),
      'pre_order_enabled', coalesce(
        v_settings.pre_order_enabled, true
      ),
      'holiday_mode', coalesce(
        v_settings.holiday_mode, false
      ),
      'kds_threshold_per_zone', coalesce(
        v_settings.kds_capacity_threshold_per_zone,
        8
      ),
      'kds_threshold_total', coalesce(
        v_settings.kds_capacity_threshold_total, 30
      ),
      'sound_alert_enabled', coalesce(
        v_settings.sound_alert_enabled, true
      ),
      'did_refresh_interval_seconds', coalesce(
        v_settings.did_refresh_interval_seconds, 10
      )
    ),

    -- critical operational alerts
    'alerts', jsonb_build_object(
      'payment_uncertain_active',
        v_payment_uncertain_active,
      'manual_fallback_active',
        v_manual_fallback_active,
      'has_critical_alerts',
        v_payment_uncertain_active
        or v_manual_fallback_active,
      'alert_messages', (
        select coalesce(
          jsonb_agg(msg), '[]'::jsonb
        )
        from (
          select jsonb_build_object(
            'type', 'PAYMENT_UNCERTAIN',
            'severity', 'CRITICAL',
            'message', catchmenu_common.get_message(
              'payment_uncertain_active',
              p_locale, null
            )
          ) as msg
          where v_payment_uncertain_active
          union all
          select jsonb_build_object(
            'type', 'MANUAL_FALLBACK',
            'severity', 'WARNING',
            'message', '수동 대체 운영 모드 활성화됨'
          )
          where v_manual_fallback_active
        ) alerts_data
      )
    ),

    -- realtime channels
    'realtime', v_realtime_config->'data',

    -- device-specific data
    'kds_state', v_kds_state,
    'floor_map', case
      when p_device_type in ('POS', 'STAFF_APP')
      then v_floor_map->'data'
      else null
    end,
    'menu_catalog', case
      when p_device_type in ('KIOSK', 'DID')
      then v_menu_catalog->'data'
      else null
    end,

    -- HQ notices
    'notices', v_store_notices,
    'unread_notice_count',
      jsonb_array_length(v_store_notices),

    -- locale
    'locale', p_locale,

    'bootstrapped_at', now(),
    'message_code', 'app_bootstrapped'
  );
end;
$$;


-- =============================================
-- bootstrap_kds_app: KDS 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_kds_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_kitchen_zone text default null,
  p_app_version text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_business_day date;
  v_timezone text;
  v_zone_tickets jsonb;
  v_zones jsonb;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'KDS',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get available kitchen zones
  select coalesce(
    jsonb_agg(
      distinct kitchen_zone
      order by kitchen_zone
    ),
    '[]'::jsonb
  )
  into v_zones
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and kitchen_zone is not null;

  -- zone-filtered active tickets
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'ticket_number', ticket_number,
        'order_id', order_id,
        'kds_status', kds_status,
        'kitchen_zone', kitchen_zone,
        'priority', priority,
        'menu_name', menu_name_snapshot,
        'quantity', quantity_snapshot,
        'estimated_minutes',
          estimated_minutes_snapshot,
        'conditions_met', conditions_met,
        'hold_reason', hold_reason,
        'ticket_created_at', ticket_created_at,
        'committed_at', committed_at,
        'cooking_started_at', cooking_started_at,
        'ready_at', ready_at,
        'elapsed_minutes', extract(
          epoch from (
            now() - coalesce(
              cooking_started_at,
              committed_at,
              ticket_created_at
            )
          )
        )::int / 60,
        'is_overdue',
          cooking_started_at is not null
          and extract(
            epoch from (now() - cooking_started_at)
          ) / 60 > coalesce(
            estimated_minutes_snapshot, 999
          )
      )
      order by
        case kds_status
          when 'COOKING' then 0
          when 'COMMITTED' then 1
          when 'CAPACITY_CHECKING' then 2
          when 'HOLD' then 3
          else 4
        end,
        priority asc,
        ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_zone_tickets
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and (
      p_kitchen_zone is null
      or kitchen_zone = p_kitchen_zone
    )
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  return v_base || jsonb_build_object(
    'kds', jsonb_build_object(
      'kitchen_zone_filter', p_kitchen_zone,
      'available_zones', v_zones,
      'active_tickets', v_zone_tickets,
      'ticket_count',
        jsonb_array_length(v_zone_tickets),
      'overdue_count', (
        select count(*)
        from jsonb_array_elements(v_zone_tickets) t
        where (t->>'is_overdue')::boolean = true
      ),
      'cooking_count', (
        select count(*)
        from jsonb_array_elements(v_zone_tickets) t
        where t->>'kds_status' = 'COOKING'
      )
    )
  );
end;
$$;


-- =============================================
-- bootstrap_kiosk_app: 키오스크 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_kiosk_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_locale text default 'ko',
  p_app_version text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_wait_estimate jsonb;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'KIOSK',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  -- wait time estimate
  v_wait_estimate :=
    catchmenu_pos.estimate_wait_time(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_guest_count := 2
    );

  -- available tables count
  return v_base || jsonb_build_object(
    'kiosk', jsonb_build_object(
      'ordering_available',
        v_base->'settings'->>'store_mode'
          not in ('CLOSED', 'EMERGENCY')
        and (
          v_base->'store'->>'store_status' = 'ACTIVE'
        ),
      'wait_estimate', jsonb_build_object(
        'estimated_wait_minutes',
          v_wait_estimate->>'estimated_wait_minutes',
        'can_seat_immediately',
          v_wait_estimate->>'can_seat_immediately',
        'queue_length',
          v_wait_estimate->>'queue_length',
        'next_wait_number',
          v_wait_estimate->>'next_wait_number'
      ),
      'waiting_enabled',
        (v_base->'settings'->>'waiting_enabled')
          ::boolean,
      'pre_order_enabled',
        (v_base->'settings'->>'pre_order_enabled')
          ::boolean,
      'allergen_consult_notice',
        catchmenu_common.get_message(
          'allergen_consult_staff', p_locale, null
        )
    )
  );
end;
$$;


-- =============================================
-- bootstrap_staff_app: 직원 앱 전용 부트스트랩
-- =============================================
create or replace function
  catchmenu_common.bootstrap_staff_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_staff_id uuid default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_base jsonb;
  v_staff record;
  v_waiting_queue jsonb;
  v_open_exceptions jsonb;
  v_today_summary jsonb;
  v_business_day date;
  v_timezone text;
begin
  -- base bootstrap
  v_base := catchmenu_common.bootstrap_app(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_device_id := p_device_id,
    p_device_type := 'STAFF_APP',
    p_app_version := p_app_version,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  if not (v_base->>'success')::boolean then
    return v_base;
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- staff info and permissions
  if p_staff_id is not null then
    select id, staff_code, display_name,
           staff_role, authority_level,
           can_observe, can_override_kds,
           can_approve_refund, can_manage_menu,
           can_manage_staff, can_view_reports,
           can_change_store_mode
    into v_staff
    from catchmenu_store.staff
    where id = p_staff_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
      and staff_status = 'ACTIVE';
  end if;

  -- current waiting queue
  v_waiting_queue :=
    catchmenu_pos.get_waiting_queue(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- open exceptions (staff must see)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'exception_id', id,
        'exception_type', exception_type,
        'exception_domain', exception_domain,
        'exception_severity', exception_severity,
        'exception_status', exception_status,
        'error_message', error_message,
        'occurrence_count', occurrence_count,
        'detected_at', detected_at,
        'requires_human_approval',
          requires_human_approval
      )
      order by
        case exception_severity
          when 'FATAL' then 0
          when 'CRITICAL' then 1
          when 'ERROR' then 2
          when 'WARNING' then 3
          else 4
        end,
        detected_at desc
    ),
    '[]'::jsonb
  )
  into v_open_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and exception_status in (
      'OPEN', 'ACKNOWLEDGED'
    )
    and business_day = v_business_day
  limit 20;

  -- today's summary (lightweight)
  select jsonb_build_object(
    'total_orders', count(*),
    'completed_orders', count(*) filter (
      where order_status = 'COMPLETED'
    ),
    'total_revenue', coalesce(
      sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0
    ),
    'cancelled_orders', count(*) filter (
      where order_status = 'CANCELLED'
    )
  )
  into v_today_summary
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return v_base || jsonb_build_object(
    'staff', case
      when v_staff.id is not null
      then jsonb_build_object(
        'id', v_staff.id,
        'staff_code', v_staff.staff_code,
        'display_name', v_staff.display_name,
        'staff_role', v_staff.staff_role,
        'authority_level', v_staff.authority_level,
        'permissions', jsonb_build_object(
          'can_observe', v_staff.can_observe,
          'can_override_kds',
            v_staff.can_override_kds,
          'can_approve_refund',
            v_staff.can_approve_refund,
          'can_manage_menu',
            v_staff.can_manage_menu,
          'can_manage_staff',
            v_staff.can_manage_staff,
          'can_view_reports',
            v_staff.can_view_reports,
          'can_change_store_mode',
            v_staff.can_change_store_mode
        )
      )
      else null
    end,
    'waiting_queue',
      v_waiting_queue->'data',
    'open_exceptions', v_open_exceptions,
    'exception_count',
      jsonb_array_length(v_open_exceptions),
    'today_summary', v_today_summary
  );
end;
$$;


-- =============================================
-- heartbeat: 앱 주기적 상태 확인
-- 30초마다 Flutter가 호출
-- =============================================
create or replace function
  catchmenu_common.heartbeat(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_app_version text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_device record;
  v_settings record;
  v_payment_uncertain boolean := false;
  v_manual_fallback boolean := false;
  v_open_exceptions int := 0;
  v_critical_exceptions int := 0;
  v_store_mode text;
  v_business_day date;
  v_timezone text;
begin
  -- minimal device validation
  select id, trust_level, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'heartbeat'
    );
  end if;

  if v_device.trust_level in (
    'UNTRUSTED', 'REVOKED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_trusted',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'heartbeat'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- update heartbeat
  update catchmenu_store.device_registry
  set
    last_heartbeat_at = now(),
    last_seen_at = now(),
    updated_at = now()
  where id = p_device_id;

  -- store mode
  select store_mode
  into v_store_mode
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- critical state checks (fast)
  select exists (
    select 1
    from catchmenu_payment.payment_intents
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and intent_status = 'UNCERTAIN'
  ) into v_payment_uncertain;

  select exists (
    select 1
    from catchmenu_agent.manual_fallback_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and fallback_status in (
        'ACTIVE', 'RECOVERING'
      )
  ) into v_manual_fallback;

  select
    count(*) filter (
      where exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    count(*) filter (
      where exception_severity in (
        'CRITICAL', 'FATAL'
      )
      and exception_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    )
  into v_open_exceptions, v_critical_exceptions
  from catchmenu_ledger.exceptions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return jsonb_build_object(
    'success', true,
    'device_id', p_device_id,
    'trust_level', v_device.trust_level,
    'store_mode', coalesce(v_store_mode, 'NORMAL'),
    'business_day', v_business_day,

    -- delta alerts (only send changes)
    'alerts', jsonb_build_object(
      'payment_uncertain', v_payment_uncertain,
      'manual_fallback', v_manual_fallback,
      'open_exceptions', v_open_exceptions,
      'critical_exceptions', v_critical_exceptions,
      'has_critical_alerts',
        v_payment_uncertain
        or v_manual_fallback
        or v_critical_exceptions > 0
    ),

    -- server time for Flutter clock sync
    'server_time', now(),
    'server_timezone', v_timezone,

    -- next heartbeat interval
    -- faster during critical alerts
    'next_heartbeat_seconds', case
      when v_payment_uncertain
        or v_critical_exceptions > 0
      then 10
      when v_manual_fallback
        or v_open_exceptions > 0
      then 20
      else 30
    end,

    'message_code', 'heartbeat_ok'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.bootstrap_app(
      uuid, uuid, uuid, text, text,
      text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_app(
      uuid, uuid, uuid, text, text,
      text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_kds_app(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_kds_app(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_kiosk_app(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_kiosk_app(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.bootstrap_staff_app(
      uuid, uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.heartbeat(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.heartbeat(
      uuid, uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_common.bootstrap_app(
  uuid, uuid, uuid, text, text,
  text, text, text, text
) is
  'Universal Flutter app bootstrap.
   Single RPC call on app startup.
   Returns everything Flutter needs to render:
   - store config + settings
   - device trust status
   - realtime channel config
   - critical operational alerts
   - device-specific data (KDS/kiosk/floor map)
   - HQ notices

   UNTRUSTED device: returns error immediately.
   No data leak to untrusted devices.

   Flutter 사용 예시:
   final bootstrap = await supabase.rpc(
     "bootstrap_app",
     params: {
       "p_tenant_id": tenantId,
       "p_store_id": storeId,
       "p_device_id": deviceId,
       "p_device_type": "KDS",
       "p_app_version": "1.0.0",
       "p_locale": "ko"
     }
   );

   특허4: Zero Trust 앱 초기화.
   UNTRUSTED 디바이스 = 즉시 차단.
   trust_level = TRUSTED 후에만 운영 데이터 전달.';

comment on function catchmenu_common.heartbeat(
  uuid, uuid, uuid, text, text
) is
  'Lightweight periodic heartbeat (30s interval).
   Updates device last_heartbeat_at.
   Returns delta alerts only (changed states).
   Adaptive interval:
     PAYMENT_UNCERTAIN → 10s
     OPEN_EXCEPTIONS → 20s
     NORMAL → 30s
   Server time included for Flutter clock sync.

   Flutter 사용:
   Timer.periodic(
     Duration(seconds: lastHeartbeatSeconds),
     (_) => supabase.rpc("heartbeat", params: {...})
   );

   특허4: 디바이스 생존 확인 + 상태 변경 푸시.
   heartbeat 누락 3회 → agent가 device OFFLINE 감지.';

-- ===== END sql/migrations/0070_create_flutter_bootstrap_rpc.sql =====


-- ===== BEGIN sql/migrations/0079_create_did_advanced_rpc.sql =====

-- 0079_create_did_advanced_rpc.sql
-- Purpose: DID display advanced management RPCs.
--          Customer pickup call, waiting display,
--          multi-zone DID management,
--          DID content scheduling (CMS basic).
--          1-B차 DID/CMS 고도화 기반.
-- Depends on: 0078_create_delivery_sync_rpc.sql
-- Creates:
--   catchmenu_store.did_devices (table)
--   catchmenu_store.did_display_queue (table)
--   catchmenu_store.did_content_schedule (table)
--   function catchmenu_store.register_did_device(...)
--   function catchmenu_store.call_customer_pickup(...)
--   function catchmenu_store.get_did_waiting_display(...)
--   function catchmenu_store.push_did_content(...)
--   function catchmenu_store.get_did_zone_state(...)
--   function catchmenu_store.dismiss_did_call(...)

-- =============================================
-- did_devices table
-- DID 디스플레이 디바이스 등록
-- =============================================
create table if not exists
  catchmenu_store.did_devices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 디바이스 정보
  device_id uuid
    references catchmenu_store.device_registry(id),
  did_code text not null,
  did_name text not null,

  -- 설치 위치
  zone text not null default 'MAIN',
  location_description text,

  -- 표시 설정
  display_mode text not null default 'WAITING',
  orientation text not null default 'LANDSCAPE',
  resolution text default '1920x1080',
  refresh_interval_seconds int
    not null default 10,

  -- 호출 설정
  call_sound_enabled boolean
    not null default true,
  call_repeat_count int not null default 3,
  call_interval_seconds int not null default 5,
  call_display_seconds int not null default 30,

  -- 현재 상태
  is_online boolean not null default false,
  last_ping_at timestamptz,
  current_content_id uuid,
  brightness int not null default 80,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_did_code unique (
    store_id, did_code
  ),
  constraint chk_did_zone check (
    zone in (
      'MAIN', 'ENTRANCE', 'COUNTER',
      'KITCHEN', 'WAITING_AREA',
      'PICKUP_COUNTER', 'OUTDOOR', 'CUSTOM'
    )
  ),
  constraint chk_display_mode check (
    display_mode in (
      'WAITING',        -- 대기번호 표시
      'PICKUP',         -- 픽업 호출
      'MENU',           -- 메뉴 표시
      'PROMOTION',      -- 프로모션
      'MIXED',          -- 혼합
      'SLIDESHOW'       -- 슬라이드쇼
    )
  ),
  constraint chk_orientation check (
    orientation in ('LANDSCAPE', 'PORTRAIT')
  )
);

create index if not exists idx_did_devices_store
  on catchmenu_store.did_devices(
    store_id, zone, is_active
  ) where is_active = true;

alter table catchmenu_store.did_devices
  enable row level security;
alter table catchmenu_store.did_devices
  force row level security;

drop policy if exists did_devices_isolation
  on catchmenu_store.did_devices;
create policy did_devices_isolation
  on catchmenu_store.did_devices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_devices_updated
  on catchmenu_store.did_devices;
create trigger trg_did_devices_updated
  before update on catchmenu_store.did_devices
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.did_devices is
  'DID 디스플레이 디바이스 등록.
   zone: 설치 위치 (메인/입구/카운터 등).
   display_mode:
     WAITING: 대기번호 + 호출 표시
     PICKUP: 포장 픽업 호출 전용
     MENU: 메뉴판 표시 (영업 중)
     MIXED: 대기 + 메뉴 혼합
   call_display_seconds: 호출 표시 유지 시간.
   1-B차 DID/CMS 고도화 핵심 테이블.
   특허1: DID = 고객 안내 출력 채널.';


-- seed DID devices
insert into catchmenu_store.did_devices (
  tenant_id, store_id,
  did_code, did_name, zone,
  display_mode, orientation,
  refresh_interval_seconds,
  call_sound_enabled, call_repeat_count
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DID_MAIN_01', '메인 DID', 'MAIN',
  'MIXED', 'LANDSCAPE', 10, true, 3
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DID_PICKUP_01', '픽업 카운터 DID',
  'PICKUP_COUNTER',
  'PICKUP', 'LANDSCAPE', 5, true, 5
)
on conflict (store_id, did_code) do nothing;


-- =============================================
-- did_display_queue table
-- DID 표시 큐 (호출/픽업 알림)
-- =============================================
create table if not exists
  catchmenu_store.did_display_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대상 DID
  did_device_id uuid
    references catchmenu_store.did_devices(id),
  did_zone text not null default 'MAIN',

  -- 큐 항목
  queue_type text not null,
  priority int not null default 5,

  -- 연결 주문/세션
  order_id uuid,
  session_id uuid,
  order_number text,
  wait_number int,

  -- 표시 내용
  display_number text not null,
  display_message jsonb not null
    default '{}'::jsonb,
  display_locale text not null default 'ko',

  -- 호출 설정
  call_count int not null default 0,
  max_call_count int not null default 3,
  last_called_at timestamptz,
  next_call_at timestamptz,

  -- 상태
  queue_status text not null default 'PENDING',
  displayed_at timestamptz,
  dismissed_at timestamptz,
  dismissed_by_type text,
  auto_dismiss_at timestamptz,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_queue_type check (
    queue_type in (
      'WAITING_CALL',   -- 대기 호출
      'PICKUP_READY',   -- 포장 픽업 준비
      'TABLE_READY',    -- 테이블 착석 안내
      'DELIVERY_READY', -- 배달 픽업 준비
      'CUSTOM_MESSAGE'  -- 커스텀 메시지
    )
  ),
  constraint chk_queue_status check (
    queue_status in (
      'PENDING', 'DISPLAYING',
      'DISMISSED', 'EXPIRED', 'CANCELLED'
    )
  )
);

create index if not exists idx_did_queue_store
  on catchmenu_store.did_display_queue(
    store_id, queue_status, priority desc
  ) where queue_status in (
    'PENDING', 'DISPLAYING'
  );
create index if not exists idx_did_queue_order
  on catchmenu_store.did_display_queue(
    order_id
  ) where order_id is not null;
create index if not exists idx_did_queue_session
  on catchmenu_store.did_display_queue(
    session_id
  ) where session_id is not null;

alter table catchmenu_store.did_display_queue
  enable row level security;
alter table catchmenu_store.did_display_queue
  force row level security;

drop policy if exists did_queue_isolation
  on catchmenu_store.did_display_queue;
create policy did_queue_isolation
  on catchmenu_store.did_display_queue
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_queue_updated
  on catchmenu_store.did_display_queue;
create trigger trg_did_queue_updated
  before update on catchmenu_store.did_display_queue
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.did_display_queue is
  'DID 표시 큐.
   priority: 숫자 낮을수록 높은 우선순위.
   WAITING_CALL: 대기번호 호출 (1번 먼저).
   PICKUP_READY: 포장 완료 픽업 호출.
   TABLE_READY: 착석 가능 안내.
   call_count: 호출 횟수 (max_call_count까지).
   auto_dismiss_at: 자동 해제 시각.
   특허1: DID 표시 = 고객 안내 증빙.';


-- =============================================
-- did_content_schedule table
-- DID 콘텐츠 스케줄 (CMS 기초)
-- =============================================
create table if not exists
  catchmenu_store.did_content_schedule (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  did_device_id uuid
    references catchmenu_store.did_devices(id),

  -- 콘텐츠 정보
  content_code text not null,
  content_name text not null,
  content_type text not null,

  -- 콘텐츠 데이터
  content_data jsonb not null
    default '{}'::jsonb,
  image_url text,
  video_url text,

  -- 표시 설정
  display_order int not null default 0,
  display_duration_seconds int
    not null default 10,

  -- 스케줄
  schedule_type text not null default 'ALWAYS',
  schedule_days jsonb,
  schedule_start_time time,
  schedule_end_time time,
  valid_from date,
  valid_until date,

  -- 조건부 표시
  show_when_waiting boolean
    not null default true,
  show_when_idle boolean not null default true,
  hide_during_call boolean not null default false,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_did_content unique (
    store_id, did_device_id, content_code
  ),
  constraint chk_content_type check (
    content_type in (
      'MENU_BOARD',     -- 메뉴판
      'PROMOTION',      -- 프로모션 이미지
      'NOTICE',         -- 공지사항
      'WAITING_INFO',   -- 대기 안내
      'WEATHER',        -- 날씨 (외부 API)
      'CUSTOM_HTML',    -- 커스텀 HTML
      'VIDEO'           -- 영상
    )
  ),
  constraint chk_schedule_type check (
    schedule_type in (
      'ALWAYS', 'TIME_RANGE',
      'DAYS_OF_WEEK', 'DATE_RANGE'
    )
  )
);

create index if not exists idx_did_content_store
  on catchmenu_store.did_content_schedule(
    store_id, display_order
  ) where is_active = true;

alter table catchmenu_store.did_content_schedule
  enable row level security;
alter table catchmenu_store.did_content_schedule
  force row level security;

drop policy if exists did_content_isolation
  on catchmenu_store.did_content_schedule;
create policy did_content_isolation
  on catchmenu_store.did_content_schedule
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_content_updated
  on catchmenu_store.did_content_schedule;
create trigger trg_did_content_updated
  before update on
    catchmenu_store.did_content_schedule
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.did_content_schedule is
  'DID 콘텐츠 스케줄 (CMS 기초).
   1-B차 CMS 메뉴/콘텐츠 관리 기반.
   content_type:
     MENU_BOARD: 메뉴판 자동 표시
     PROMOTION: 이미지 프로모션
     WAITING_INFO: 현재 대기 인원 표시
   hide_during_call: 호출 중 콘텐츠 숨김.
   schedule_type ALWAYS: 항상 표시.
   특허1: DID 콘텐츠 = 고객 안내 채널.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.register_did_device(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text,
  p_did_name text,
  p_zone text default 'MAIN',
  p_display_mode text default 'MIXED',
  p_device_id uuid default null,
  p_refresh_interval_seconds int default 10,
  p_call_sound_enabled boolean default true,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_did_id uuid;
  v_is_new boolean;
begin
  v_is_new := not exists (
    select 1 from catchmenu_store.did_devices
    where store_id = p_store_id
      and did_code = p_did_code
  );

  insert into catchmenu_store.did_devices (
    tenant_id, store_id,
    device_id, did_code, did_name, zone,
    display_mode,
    refresh_interval_seconds,
    call_sound_enabled
  ) values (
    p_tenant_id, p_store_id,
    p_device_id, p_did_code, p_did_name,
    p_zone, p_display_mode,
    p_refresh_interval_seconds,
    p_call_sound_enabled
  )
  on conflict (store_id, did_code) do update set
    did_name = excluded.did_name,
    zone = excluded.zone,
    display_mode = excluded.display_mode,
    device_id = coalesce(
      excluded.device_id,
      catchmenu_store.did_devices.device_id
    ),
    refresh_interval_seconds =
      excluded.refresh_interval_seconds,
    call_sound_enabled =
      excluded.call_sound_enabled,
    is_active = true,
    updated_at = now()
  returning id into v_did_id;

  -- ledger event
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
    'store', 'did_device_registered', 1,
    'did_device', v_did_id,
    null, 'ACTIVE',
    'SYSTEM',
    jsonb_build_object(
      'did_code', p_did_code,
      'zone', p_zone,
      'display_mode', p_display_mode,
      'is_new', v_is_new
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'did_id', v_did_id,
    'did_code', p_did_code,
    'zone', p_zone,
    'display_mode', p_display_mode,
    'is_new', v_is_new,
    'message_code', 'did_device_registered'
  );
end;
$$;


create or replace function
  catchmenu_store.call_customer_pickup(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_queue_type text default 'PICKUP_READY',
  p_target_zone text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_did_device record;
  v_queue_id uuid;
  v_display_number text;
  v_display_message jsonb;
  v_auto_dismiss_at timestamptz;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.order_status, o.final_amount,
         o.session_id,
         os.wait_number
  into v_order
  from catchmenu_pos.orders o
  left join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_customer_pickup'
    );
  end if;

  -- 표시 번호 결정
  v_display_number := coalesce(
    v_order.order_number,
    v_order.wait_number::text,
    v_order.id::text
  );

  -- DID 대상 결정
  select id, did_code, call_display_seconds,
         call_repeat_count, call_interval_seconds
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and (
      p_target_zone is null
      or zone = p_target_zone
      or (
        p_target_zone is null
        and display_mode in ('PICKUP', 'MIXED')
      )
    )
  order by
    case display_mode
      when 'PICKUP' then 0
      when 'MIXED' then 1
      else 2
    end
  limit 1;

  -- i18n 표시 메시지
  v_display_message := jsonb_build_object(
    'ko', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then '포장 준비 완료'
        when 'DELIVERY_READY' then '배달 픽업 준비'
        when 'TABLE_READY' then '자리 안내'
        when 'WAITING_CALL' then '대기 호출'
        else '호출'
      end,
      'body',
        v_display_number || '번 '
        || case p_queue_type
          when 'PICKUP_READY'
            then '포장 준비되었습니다. 카운터로 와주세요.'
          when 'TABLE_READY'
            then '자리가 준비되었습니다.'
          when 'WAITING_CALL'
            then '입장해 주세요.'
          else '준비되었습니다.'
        end
    ),
    'en', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then 'Order Ready'
        when 'TABLE_READY' then 'Table Ready'
        when 'WAITING_CALL' then 'Now Calling'
        else 'Ready'
      end,
      'body',
        'Order #' || v_display_number
        || case p_queue_type
          when 'PICKUP_READY'
            then ' is ready for pickup.'
          when 'TABLE_READY'
            then ' your table is ready.'
          when 'WAITING_CALL'
            then ' please come in.'
          else ' is ready.'
        end
    ),
    'zh', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then '取餐准备好了'
        when 'TABLE_READY' then '座位准备好了'
        else '准备好了'
      end,
      'body',
        v_display_number || '号'
        || case p_queue_type
          when 'PICKUP_READY'
            then '，请到柜台取餐'
          when 'TABLE_READY'
            then '，请就座'
          else '，请到柜台'
        end
    ),
    'ja', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY'
          then 'お持ち帰りのご準備ができました'
        when 'TABLE_READY'
          then 'お席のご準備ができました'
        else 'ご準備ができました'
      end,
      'body',
        v_display_number || '番'
        || case p_queue_type
          when 'PICKUP_READY'
            then 'のお客様、カウンターへどうぞ'
          when 'TABLE_READY'
            then 'のお客様、お席へどうぞ'
          else 'のお客様、どうぞ'
        end
    )
  );

  -- 자동 해제 시각
  v_auto_dismiss_at := now() + interval '1 second'
    * coalesce(
      v_did_device.call_display_seconds, 30
    );

  -- DID 큐 추가
  insert into catchmenu_store.did_display_queue (
    tenant_id, store_id,
    did_device_id, did_zone,
    queue_type, priority,
    order_id, session_id,
    order_number, wait_number,
    display_number, display_message,
    display_locale,
    max_call_count,
    next_call_at,
    queue_status,
    auto_dismiss_at,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    v_did_device.id,
    coalesce(p_target_zone, 'MAIN'),
    p_queue_type,
    case p_queue_type
      when 'WAITING_CALL' then 1
      when 'TABLE_READY' then 2
      when 'PICKUP_READY' then 3
      else 5
    end,
    p_order_id, v_order.session_id,
    v_order.order_number, v_order.wait_number,
    v_display_number, v_display_message,
    p_locale,
    coalesce(
      v_did_device.call_repeat_count, 3
    ),
    now(),
    'DISPLAYING',
    v_auto_dismiss_at,
    v_business_day
  )
  returning id into v_queue_id;

  -- Realtime broadcast → DID Flutter 앱
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := p_queue_type,
    p_payload := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'display_message', v_display_message,
      'locale', p_locale,
      'did_zone', coalesce(
        p_target_zone, 'MAIN'
      ),
      'auto_dismiss_at', v_auto_dismiss_at,
      'called_at', now()
    )
  );

  -- 주문 상태 업데이트
  -- PICKUP_READY → 픽업 대기 중
  if p_queue_type = 'PICKUP_READY'
    and v_order.order_status
      not in ('COMPLETED', 'CANCELLED')
  then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      ready_at = coalesce(ready_at, now()),
      updated_at = now()
    where id = p_order_id
      and order_status not in (
        'READY', 'PICKED_UP',
        'COMPLETED', 'CANCELLED'
      );
  end if;

  -- ledger event
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
    'store', 'did_customer_called', 1,
    'did_queue', v_queue_id,
    null, 'DISPLAYING',
    'SYSTEM',
    jsonb_build_object(
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        v_did_device.did_code,
      'locale', p_locale
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_ready',
    p_data := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        coalesce(v_did_device.did_code, 'N/A'),
      'auto_dismiss_at', v_auto_dismiss_at,
      'display_message', v_display_message
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'order_number', v_display_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_waiting_display(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_business_day date;
  v_timezone text;
  v_waiting_list jsonb;
  v_active_calls jsonb;
  v_store_settings record;
  v_did_device record;
begin
  select id, store_name, timezone
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
      p_rpc_name := 'get_did_waiting_display'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- DID 디바이스 정보
  select id, did_code, zone, display_mode,
         refresh_interval_seconds,
         call_sound_enabled
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and (
      p_did_code is null
      or did_code = p_did_code
    )
  order by
    case display_mode
      when 'WAITING' then 0
      when 'MIXED' then 1
      else 2
    end
  limit 1;

  -- 매장 설정
  select store_mode, waiting_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 현재 대기 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'wait_number', wait_number,
        'session_status', session_status,
        'guest_count', guest_count,
        'queue_position', queue_position,
        'waited_minutes', extract(
          epoch from (
            now() - session_started_at
          )
        )::int / 60
      )
      order by queue_position nulls last,
               wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
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

  -- 현재 표시 중인 호출
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'queue_id', id,
        'queue_type', queue_type,
        'display_number', display_number,
        'display_message',
          display_message->p_locale,
        'call_count', call_count,
        'max_call_count', max_call_count,
        'auto_dismiss_at', auto_dismiss_at,
        'displayed_at', displayed_at
      )
      order by priority asc,
               created_at asc
    ),
    '[]'::jsonb
  )
  into v_active_calls
  from catchmenu_store.did_display_queue
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
    and (
      auto_dismiss_at is null
      or auto_dismiss_at > now()
    )
    and (
      v_did_device.id is null
      or did_device_id = v_did_device.id
    );

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_mode', coalesce(
        v_store_settings.store_mode, 'NORMAL'
      ),
      'waiting_enabled', coalesce(
        v_store_settings.waiting_enabled, true
      )
    ),
    'did_device', case
      when v_did_device.id is not null
      then jsonb_build_object(
        'id', v_did_device.id,
        'did_code', v_did_device.did_code,
        'zone', v_did_device.zone,
        'display_mode', v_did_device.display_mode,
        'refresh_interval_seconds',
          v_did_device.refresh_interval_seconds,
        'call_sound_enabled',
          v_did_device.call_sound_enabled
      )
      else null
    end,
    'business_day', v_business_day,
    'locale', p_locale,
    'waiting_queue', jsonb_build_object(
      'total_waiting',
        jsonb_array_length(v_waiting_list),
      'sessions', v_waiting_list
    ),
    'active_calls', v_active_calls,
    'active_call_count',
      jsonb_array_length(v_active_calls),
    'has_active_calls',
      jsonb_array_length(v_active_calls) > 0,
    'refresh_interval_seconds', coalesce(
      v_did_device.refresh_interval_seconds, 10
    ),
    'generated_at', now(),
    'message_code', 'did_display_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_zone_state(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_zones jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'did_id', d.id,
        'did_code', d.did_code,
        'did_name', d.did_name,
        'zone', d.zone,
        'display_mode', d.display_mode,
        'is_online', d.is_online,
        'last_ping_at', d.last_ping_at,
        'minutes_since_ping', case
          when d.last_ping_at is not null
          then extract(epoch from (
            now() - d.last_ping_at
          ))::int / 60
          else null
        end,
        'is_stale',
          d.last_ping_at is null
          or d.last_ping_at
            < now() - interval '2 minutes',
        'active_call_count', (
          select count(*)
          from catchmenu_store.did_display_queue q
          where q.did_device_id = d.id
            and q.queue_status = 'DISPLAYING'
            and (
              q.auto_dismiss_at is null
              or q.auto_dismiss_at > now()
            )
        ),
        'today_call_count', (
          select count(*)
          from catchmenu_store.did_display_queue q
          where q.did_device_id = d.id
            and q.business_day = v_business_day
        )
      )
      order by
        case d.zone
          when 'MAIN' then 0
          when 'ENTRANCE' then 1
          when 'COUNTER' then 2
          when 'PICKUP_COUNTER' then 3
          else 9
        end
    ),
    '[]'::jsonb
  )
  into v_zones
  from catchmenu_store.did_devices d
  where d.store_id = p_store_id
    and d.tenant_id = p_tenant_id
    and d.is_active = true;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'did_devices', v_zones,
    'total_count', jsonb_array_length(v_zones),
    'online_count', (
      select count(*)
      from jsonb_array_elements(v_zones) z
      where (z->>'is_online')::boolean = true
    ),
    'stale_count', (
      select count(*)
      from jsonb_array_elements(v_zones) z
      where (z->>'is_stale')::boolean = true
    ),
    'checked_at', now(),
    'message_code', 'did_zone_state_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.dismiss_did_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_queue_id uuid,
  p_dismissed_by_type text default 'STAFF',
  p_dismissed_by_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_queue record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, queue_type, display_number,
         order_id, queue_status
  into v_queue
  from catchmenu_store.did_display_queue
  where id = p_queue_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_queue.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'dismiss_did_call'
    );
  end if;

  if v_queue.queue_status not in (
    'PENDING', 'DISPLAYING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'call_already_dismissed',
      'current_status', v_queue.queue_status
    );
  end if;

  -- 큐 해제
  update catchmenu_store.did_display_queue
  set
    queue_status = 'DISMISSED',
    dismissed_at = now(),
    dismissed_by_type = p_dismissed_by_type,
    updated_at = now()
  where id = p_queue_id;

  -- Realtime → DID 해제 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_by', p_dismissed_by_type,
      'dismissed_at', now()
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'store', 'did_call_dismissed', 1,
    'did_queue', p_queue_id,
    'DISPLAYING', 'DISMISSED',
    p_dismissed_by_type, p_dismissed_by_id,
    jsonb_build_object(
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number
    ),
    v_queue.order_id, p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_cancelled',
    p_data := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.push_did_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_device_id uuid,
  p_content_code text,
  p_content_name text,
  p_content_type text,
  p_content_data jsonb,
  p_display_duration_seconds int default 10,
  p_display_order int default 0,
  p_show_when_waiting boolean default true,
  p_hide_during_call boolean default false,
  p_valid_from date default null,
  p_valid_until date default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_content_id uuid;
  v_is_new boolean;
begin
  v_is_new := not exists (
    select 1
    from catchmenu_store.did_content_schedule
    where store_id = p_store_id
      and did_device_id = p_did_device_id
      and content_code = p_content_code
  );

  insert into catchmenu_store.did_content_schedule (
    tenant_id, store_id, did_device_id,
    content_code, content_name, content_type,
    content_data,
    display_order, display_duration_seconds,
    schedule_type,
    show_when_waiting, show_when_idle,
    hide_during_call,
    valid_from, valid_until
  ) values (
    p_tenant_id, p_store_id, p_did_device_id,
    p_content_code, p_content_name, p_content_type,
    p_content_data,
    p_display_order, p_display_duration_seconds,
    case
      when p_valid_from is not null
        or p_valid_until is not null
        then 'DATE_RANGE'
      else 'ALWAYS'
    end,
    p_show_when_waiting, true,
    p_hide_during_call,
    p_valid_from, p_valid_until
  )
  on conflict (store_id, did_device_id, content_code)
  do update set
    content_name = excluded.content_name,
    content_type = excluded.content_type,
    content_data = excluded.content_data,
    display_order = excluded.display_order,
    display_duration_seconds =
      excluded.display_duration_seconds,
    show_when_waiting = excluded.show_when_waiting,
    hide_during_call = excluded.hide_during_call,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    is_active = true,
    updated_at = now()
  returning id into v_content_id;

  -- Realtime → DID 콘텐츠 업데이트 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'content_updated',
    p_payload := jsonb_build_object(
      'content_id', v_content_id,
      'did_device_id', p_did_device_id,
      'content_code', p_content_code,
      'content_type', p_content_type,
      'is_new', v_is_new
    )
  );

  return jsonb_build_object(
    'success', true,
    'content_id', v_content_id,
    'content_code', p_content_code,
    'content_type', p_content_type,
    'is_new', v_is_new,
    'message_code', 'did_content_pushed'
  );
end;
$$;


-- pg_cron: DID 큐 자동 해제 (만료된 호출)
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'DID_QUEUE_CLEANUP',
  'catchmenu_did_queue_cleanup',
  '*/1 * * * *',
  '*/1 * * * * (1분마다)',
  $sql$
UPDATE catchmenu_store.did_display_queue
SET
  queue_status = 'EXPIRED',
  dismissed_at = now(),
  dismissed_by_type = 'SYSTEM',
  updated_at = now()
WHERE queue_status = 'DISPLAYING'
  AND auto_dismiss_at < now();
$sql$,
  'DID 호출 만료 자동 해제. 1분마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.register_did_device(
      uuid, uuid, text, text, text, text,
      uuid, int, boolean, text
    ) from public;
  grant execute on function
    catchmenu_store.register_did_device(
      uuid, uuid, text, text, text, text,
      uuid, int, boolean, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.call_customer_pickup(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.call_customer_pickup(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_did_waiting_display(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_did_waiting_display(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_did_zone_state(uuid, uuid)
    from public;
  grant execute on function
    catchmenu_store.get_did_zone_state(uuid, uuid)
    to authenticated;

  revoke all on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.push_did_content(
      uuid, uuid, uuid, text, text, text,
      jsonb, int, int, boolean, boolean,
      date, date, text
    ) from public;
  grant execute on function
    catchmenu_store.push_did_content(
      uuid, uuid, uuid, text, text, text,
      jsonb, int, int, boolean, boolean,
      date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.call_customer_pickup(
    uuid, uuid, uuid, text, text, text, text
  ) is
  '고객 픽업 호출 → DID 표시 + Realtime broadcast.
   queue_type:
     PICKUP_READY: 포장 완료 픽업 호출
     TABLE_READY: 테이블 착석 안내
     WAITING_CALL: 대기 호출
   i18n 메시지: ko/en/zh/ja 자동 생성.
   Realtime broadcast → DID Flutter 앱 즉시 표시.
   auto_dismiss_at: 설정 시간 후 자동 해제.
   특허1: DID = 고객 안내 채널.
   1-B차 DID/픽업 표시 핵심 기능.';

comment on function
  catchmenu_store.get_did_waiting_display(
    uuid, uuid, text, text
  ) is
  'DID Flutter 앱 폴링용 데이터.
   DID 앱이 refresh_interval_seconds마다 호출.
   포함 데이터:
   - 현재 대기 목록 (번호/인원/대기시간)
   - 활성 호출 목록 (queue_type/번호/메시지)
   - 매장 운영 상태
   - DID 디바이스 설정
   locale: DID 설치 언어 기준 메시지 선택.
   1-B차 DID 고도화 핵심 RPC.';

-- ===== END sql/migrations/0079_create_did_advanced_rpc.sql =====


-- ===== BEGIN sql/migrations/0080_create_cms_content_rpc.sql =====

-- 0080_create_cms_content_rpc.sql
-- Purpose: CMS content management RPCs.
--          Menu content, store notices, promotions,
--          banner management, content versioning.
--          1-B차 CMS 메뉴/콘텐츠 관리 기반.
-- Depends on: 0079_create_did_advanced_rpc.sql
-- Creates:
--   catchmenu_store.cms_contents (table)
--   catchmenu_store.cms_content_versions (table)
--   catchmenu_store.store_notices (table)
--   catchmenu_store.promotions (table)
--   function catchmenu_store.publish_cms_content(...)
--   function catchmenu_store.get_cms_content(...)
--   function catchmenu_store.create_store_notice(...)
--   function catchmenu_store.get_active_notices(...)
--   function catchmenu_store.create_promotion(...)
--   function catchmenu_store.get_active_promotions(...)
--   function catchmenu_store.get_store_cms_bundle(...)

-- =============================================
-- cms_contents table
-- CMS 콘텐츠 마스터
-- =============================================
create table if not exists
  catchmenu_store.cms_contents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 콘텐츠 식별
  content_code text not null,
  content_name text not null,
  content_type text not null,
  content_category text not null
    default 'GENERAL',

  -- 현재 버전
  current_version_id uuid,
  current_version_number int
    not null default 0,

  -- 상태
  content_status text not null default 'DRAFT',
  published_at timestamptz,
  published_by uuid,

  -- 표시 설정
  display_channels jsonb
    default '["APP","KIOSK","DID"]'::jsonb,
  target_locales jsonb
    default '["ko"]'::jsonb,

  -- 유효 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 다국어 지원
  is_i18n boolean not null default false,

  -- 통계
  view_count int not null default 0,
  last_viewed_at timestamptz,

  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_content unique (
    tenant_id, store_id, content_code
  ),
  constraint chk_content_type check (
    content_type in (
      'MENU_BOARD',     -- 메뉴판
      'BANNER',         -- 배너
      'NOTICE',         -- 공지
      'PROMOTION',      -- 프로모션
      'EVENT',          -- 이벤트
      'GUIDE',          -- 안내
      'ALLERGEN_INFO',  -- 알레르겐 안내
      'OPERATING_HOURS',-- 영업시간
      'CUSTOM'          -- 커스텀
    )
  ),
  constraint chk_content_status check (
    content_status in (
      'DRAFT', 'REVIEW', 'PUBLISHED',
      'SCHEDULED', 'EXPIRED', 'ARCHIVED'
    )
  )
);

create index if not exists idx_cms_contents_store
  on catchmenu_store.cms_contents(
    store_id, content_type, content_status
  ) where is_active = true;
create index if not exists idx_cms_contents_tenant
  on catchmenu_store.cms_contents(
    tenant_id, content_type
  ) where store_id is null;

alter table catchmenu_store.cms_contents
  enable row level security;
alter table catchmenu_store.cms_contents
  force row level security;

drop policy if exists cms_contents_isolation
  on catchmenu_store.cms_contents;
create policy cms_contents_isolation
  on catchmenu_store.cms_contents
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and (
      store_id is null
      or store_id = catchmenu_common.current_store_id()
    )
  );

drop trigger if exists trg_cms_contents_updated
  on catchmenu_store.cms_contents;
create trigger trg_cms_contents_updated
  before update on catchmenu_store.cms_contents
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_contents is
  'CMS 콘텐츠 마스터.
   store_id = null: 테넌트 전체 공통 콘텐츠.
   store_id 있음: 매장별 콘텐츠.
   display_channels: 표시 채널 (APP/KIOSK/DID).
   content_type:
     MENU_BOARD: Flutter 메뉴판 콘텐츠
     BANNER: 앱/키오스크 배너
     PROMOTION: 할인/이벤트 프로모션
   1-B차 CMS 메뉴/콘텐츠 관리 기반.';


-- =============================================
-- cms_content_versions table
-- 콘텐츠 버전 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_content_versions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  content_id uuid not null
    references catchmenu_store.cms_contents(id),

  version_number int not null,
  version_status text not null default 'DRAFT',

  -- 콘텐츠 데이터 (i18n 포함)
  content_data jsonb not null default '{}'::jsonb,
  content_data_ko jsonb,
  content_data_en jsonb,
  content_data_zh jsonb,
  content_data_ja jsonb,

  -- 미디어
  image_urls jsonb default '[]'::jsonb,
  video_url text,
  thumbnail_url text,

  -- 변경 정보
  change_summary text,
  created_by uuid,
  reviewed_by uuid,
  reviewed_at timestamptz,
  published_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_content_version unique (
    content_id, version_number
  ),
  constraint chk_version_status check (
    version_status in (
      'DRAFT', 'REVIEW', 'PUBLISHED',
      'SUPERSEDED', 'ARCHIVED'
    )
  )
);

create index if not exists idx_cms_versions_content
  on catchmenu_store.cms_content_versions(
    content_id, version_number desc
  );

alter table catchmenu_store.cms_content_versions
  enable row level security;
alter table catchmenu_store.cms_content_versions
  force row level security;

drop policy if exists cms_versions_isolation
  on catchmenu_store.cms_content_versions;
create policy cms_versions_isolation
  on catchmenu_store.cms_content_versions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_cms_versions_updated
  on catchmenu_store.cms_content_versions;
create trigger trg_cms_versions_updated
  before update on
    catchmenu_store.cms_content_versions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.cms_content_versions is
  '콘텐츠 버전 관리.
   version_number: 자동 증가.
   content_data: 기본 데이터.
   content_data_ko/en/zh/ja: 다국어 데이터.
   SUPERSEDED: 이전 버전 (조회 가능, 복원 가능).
   특허4: 콘텐츠 버전 = 감사 추적 가능.';


-- =============================================
-- store_notices table
-- 매장 공지사항
-- =============================================
create table if not exists
  catchmenu_store.store_notices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 공지 정보
  notice_code text not null,
  notice_type text not null,
  priority text not null default 'NORMAL',

  -- 내용 (다국어)
  title jsonb not null
    default '{}'::jsonb,
  body jsonb not null
    default '{}'::jsonb,

  -- 표시 설정
  display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  show_on_main boolean not null default false,
  show_on_did boolean not null default false,
  requires_confirm boolean not null default false,

  -- 유효 기간
  valid_from timestamptz not null default now(),
  valid_until timestamptz,

  -- 상태
  notice_status text not null default 'ACTIVE',
  created_by uuid,
  confirmed_count int not null default 0,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_notice_code unique (
    store_id, notice_code
  ),
  constraint chk_notice_type check (
    notice_type in (
      'OPERATING_HOURS_CHANGE',
      'MENU_CHANGE',
      'TEMPORARY_CLOSURE',
      'HOLIDAY_NOTICE',
      'PROMOTION_START',
      'ALLERGY_WARNING',
      'SYSTEM_MAINTENANCE',
      'GENERAL'
    )
  ),
  constraint chk_notice_priority check (
    priority in (
      'URGENT', 'HIGH', 'NORMAL', 'LOW'
    )
  ),
  constraint chk_notice_status check (
    notice_status in (
      'ACTIVE', 'EXPIRED',
      'CANCELLED', 'SCHEDULED'
    )
  )
);

create index if not exists idx_store_notices_active
  on catchmenu_store.store_notices(
    store_id, priority, valid_from desc
  )
  where notice_status = 'ACTIVE'
    and is_active = true;

alter table catchmenu_store.store_notices
  enable row level security;
alter table catchmenu_store.store_notices
  force row level security;

drop policy if exists store_notices_isolation
  on catchmenu_store.store_notices;
create policy store_notices_isolation
  on catchmenu_store.store_notices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_store_notices_updated
  on catchmenu_store.store_notices;
create trigger trg_store_notices_updated
  before update on catchmenu_store.store_notices
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.store_notices is
  '매장 공지사항.
   title/body: jsonb i18n 구조
   {"ko": "내용", "en": "Content"}.
   show_on_main: 앱 메인 화면 표시.
   show_on_did: DID 표시 여부.
   requires_confirm: 고객 확인 필요.
   ALLERGY_WARNING: 식품위생법 알레르겐 경고.
   1-B차 매장별 설정/공지 관리 기반.';


-- =============================================
-- promotions table
-- 프로모션/이벤트 관리
-- =============================================
create table if not exists
  catchmenu_store.promotions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 프로모션 정보
  promotion_code text not null,
  promotion_name text not null,
  promotion_type text not null,

  -- 내용 (다국어)
  title jsonb not null default '{}'::jsonb,
  description jsonb not null
    default '{}'::jsonb,

  -- 혜택 정보
  benefit_type text not null,
  discount_type text,
  discount_value int,
  discount_pct numeric(5,2),
  min_order_amount int,
  max_discount_amount int,

  -- 대상 메뉴 (빈 배열 = 전체)
  target_menu_ids jsonb default '[]'::jsonb,
  target_category_ids jsonb default '[]'::jsonb,

  -- 쿠폰 연결
  coupon_id uuid,

  -- 유효 기간
  valid_from timestamptz not null,
  valid_until timestamptz,

  -- 사용 제한
  max_uses int,
  current_uses int not null default 0,
  max_uses_per_customer int default 1,

  -- 표시
  banner_image_url text,
  display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  display_order int not null default 0,

  -- 상태
  promotion_status text
    not null default 'SCHEDULED',
  is_active boolean not null default true,
  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_promotion_code unique (
    store_id, promotion_code
  ),
  constraint chk_promotion_type check (
    promotion_type in (
      'DISCOUNT',       -- 할인
      'FREE_ITEM',      -- 무료 증정
      'BUNDLE',         -- 묶음 할인
      'HAPPY_HOUR',     -- 해피아워
      'FIRST_ORDER',    -- 첫 주문 혜택
      'LOYALTY',        -- 단골 혜택
      'SEASONAL',       -- 시즌 이벤트
      'CUSTOM'
    )
  ),
  constraint chk_benefit_type check (
    benefit_type in (
      'AMOUNT_DISCOUNT',  -- 금액 할인
      'PCT_DISCOUNT',     -- % 할인
      'FREE_ITEM',        -- 무료 제공
      'POINT_BONUS',      -- 포인트 보너스
      'COUPON_ISSUE'      -- 쿠폰 발급
    )
  ),
  constraint chk_promotion_status check (
    promotion_status in (
      'SCHEDULED', 'ACTIVE',
      'PAUSED', 'ENDED', 'CANCELLED'
    )
  )
);

create index if not exists idx_promotions_active
  on catchmenu_store.promotions(
    store_id, promotion_status,
    valid_from, valid_until
  ) where promotion_status in (
    'SCHEDULED', 'ACTIVE'
  ) and is_active = true;

alter table catchmenu_store.promotions
  enable row level security;
alter table catchmenu_store.promotions
  force row level security;

drop policy if exists promotions_isolation
  on catchmenu_store.promotions;
create policy promotions_isolation
  on catchmenu_store.promotions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_promotions_updated
  on catchmenu_store.promotions;
create trigger trg_promotions_updated
  before update on catchmenu_store.promotions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.promotions is
  '프로모션/이벤트 관리.
   benefit_type:
     AMOUNT_DISCOUNT: 금액 할인 (discount_value원)
     PCT_DISCOUNT: % 할인 (discount_pct%)
     FREE_ITEM: 무료 증정 (target_menu_ids)
     POINT_BONUS: 포인트 N배 적립
     COUPON_ISSUE: 쿠폰 자동 발급
   max_uses: 전체 사용 한도.
   max_uses_per_customer: 1인당 사용 한도.
   1-B차 고객 멤버십 앱 + 포장 앱 연동 핵심.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.publish_cms_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_content_code text,
  p_content_name text,
  p_content_type text,
  p_content_data jsonb,
  p_content_data_ko jsonb default null,
  p_content_data_en jsonb default null,
  p_content_data_zh jsonb default null,
  p_content_data_ja jsonb default null,
  p_display_channels jsonb
    default '["APP","KIOSK","DID"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_change_summary text default null,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_content_id uuid;
  v_version_id uuid;
  v_version_number int;
  v_is_new boolean;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 콘텐츠 마스터 upsert
  v_is_new := not exists (
    select 1 from catchmenu_store.cms_contents
    where tenant_id = p_tenant_id
      and coalesce(store_id::text, 'NULL')
        = coalesce(p_store_id::text, 'NULL')
      and content_code = p_content_code
  );

  insert into catchmenu_store.cms_contents (
    tenant_id, store_id,
    content_code, content_name, content_type,
    content_category, content_status,
    display_channels,
    valid_from, valid_until,
    is_i18n,
    published_at, published_by,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    p_content_code, p_content_name,
    p_content_type, 'GENERAL', 'PUBLISHED',
    p_display_channels,
    p_valid_from, p_valid_until,
    p_content_data_ko is not null
      or p_content_data_en is not null,
    now(), p_actor_id,
    p_actor_id
  )
  on conflict (tenant_id, store_id, content_code)
  do update set
    content_name = excluded.content_name,
    content_status = 'PUBLISHED',
    display_channels = excluded.display_channels,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    is_i18n = excluded.is_i18n,
    published_at = now(),
    published_by = p_actor_id,
    updated_at = now()
  returning id, current_version_number
  into v_content_id, v_version_number;

  -- 버전 번호 결정
  v_version_number := coalesce(v_version_number, 0) + 1;

  -- 이전 버전 SUPERSEDED 처리
  update catchmenu_store.cms_content_versions
  set
    version_status = 'SUPERSEDED',
    updated_at = now()
  where content_id = v_content_id
    and version_status = 'PUBLISHED';

  -- 새 버전 생성
  insert into catchmenu_store.cms_content_versions (
    tenant_id, content_id,
    version_number, version_status,
    content_data,
    content_data_ko, content_data_en,
    content_data_zh, content_data_ja,
    change_summary,
    created_by, published_at
  ) values (
    p_tenant_id, v_content_id,
    v_version_number, 'PUBLISHED',
    p_content_data,
    p_content_data_ko, p_content_data_en,
    p_content_data_zh, p_content_data_ja,
    p_change_summary,
    p_actor_id, now()
  )
  returning id into v_version_id;

  -- 마스터 현재 버전 업데이트
  update catchmenu_store.cms_contents
  set
    current_version_id = v_version_id,
    current_version_number = v_version_number
  where id = v_content_id;

  -- Realtime → 앱/키오스크/DID 콘텐츠 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'MENU_STATUS',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_id', v_content_id,
      'content_code', p_content_code,
      'content_type', p_content_type,
      'version_number', v_version_number,
      'is_new', v_is_new
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
    'store', 'cms_content_published', 1,
    'cms_content', v_content_id,
    case when v_is_new then null else 'PUBLISHED' end,
    'PUBLISHED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'content_code', p_content_code,
      'content_type', p_content_type,
      'version_number', v_version_number,
      'is_new', v_is_new,
      'change_summary', p_change_summary
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'content_id', v_content_id,
    'version_id', v_version_id,
    'version_number', v_version_number,
    'content_code', p_content_code,
    'content_type', p_content_type,
    'is_new', v_is_new,
    'message_code', 'cms_content_published'
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_content_code text,
  p_locale text default 'ko',
  p_channel text default 'APP'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_content record;
  v_version record;
  v_localized_data jsonb;
begin
  -- 콘텐츠 조회
  select cc.id, cc.content_code,
         cc.content_name, cc.content_type,
         cc.content_status, cc.display_channels,
         cc.valid_from, cc.valid_until,
         cc.current_version_id,
         cc.current_version_number
  into v_content
  from catchmenu_store.cms_contents cc
  where cc.tenant_id = p_tenant_id
    and (
      cc.store_id = p_store_id
      or cc.store_id is null
    )
    and cc.content_code = p_content_code
    and cc.content_status = 'PUBLISHED'
    and cc.is_active = true
    and (
      cc.valid_from is null
      or cc.valid_from <= now()
    )
    and (
      cc.valid_until is null
      or cc.valid_until >= now()
    )
    and cc.display_channels @>
      to_jsonb(p_channel)
  order by
    case when cc.store_id = p_store_id
      then 0 else 1
    end
  limit 1;

  if v_content.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_knowledge_found',
      'content_code', p_content_code
    );
  end if;

  -- 현재 버전 데이터
  select cv.id, cv.version_number,
         cv.content_data,
         cv.content_data_ko, cv.content_data_en,
         cv.content_data_zh, cv.content_data_ja,
         cv.image_urls, cv.thumbnail_url,
         cv.published_at
  into v_version
  from catchmenu_store.cms_content_versions cv
  where cv.id = v_content.current_version_id;

  -- locale 기반 데이터 선택
  v_localized_data := coalesce(
    case p_locale
      when 'ko' then v_version.content_data_ko
      when 'en' then v_version.content_data_en
      when 'zh' then v_version.content_data_zh
      when 'ja' then v_version.content_data_ja
      else null
    end,
    v_version.content_data_ko,
    v_version.content_data
  );

  -- 조회수 증가
  update catchmenu_store.cms_contents
  set
    view_count = view_count + 1,
    last_viewed_at = now(),
    updated_at = now()
  where id = v_content.id;

  return jsonb_build_object(
    'success', true,
    'content_id', v_content.id,
    'content_code', v_content.content_code,
    'content_name', v_content.content_name,
    'content_type', v_content.content_type,
    'version_number', v_version.version_number,
    'locale', p_locale,
    'data', v_localized_data,
    'raw_data', v_version.content_data,
    'image_urls', v_version.image_urls,
    'thumbnail_url', v_version.thumbnail_url,
    'valid_until', v_content.valid_until,
    'published_at', v_version.published_at,
    'message_code', 'cms_content_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.create_store_notice(
  p_tenant_id uuid,
  p_store_id uuid,
  p_notice_code text,
  p_notice_type text,
  p_title_ko text,
  p_body_ko text,
  p_title_en text default null,
  p_body_en text default null,
  p_priority text default 'NORMAL',
  p_show_on_main boolean default false,
  p_show_on_did boolean default false,
  p_requires_confirm boolean default false,
  p_valid_until timestamptz default null,
  p_display_channels jsonb
    default '["APP","KIOSK"]'::jsonb,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_notice_id uuid;
  v_is_new boolean;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_is_new := not exists (
    select 1 from catchmenu_store.store_notices
    where store_id = p_store_id
      and notice_code = p_notice_code
  );

  insert into catchmenu_store.store_notices (
    tenant_id, store_id,
    notice_code, notice_type, priority,
    title, body,
    display_channels,
    show_on_main, show_on_did,
    requires_confirm,
    valid_from, valid_until,
    notice_status, created_by
  ) values (
    p_tenant_id, p_store_id,
    p_notice_code, p_notice_type, p_priority,
    jsonb_build_object(
      'ko', p_title_ko,
      'en', coalesce(p_title_en, p_title_ko)
    ),
    jsonb_build_object(
      'ko', p_body_ko,
      'en', coalesce(p_body_en, p_body_ko)
    ),
    p_display_channels,
    p_show_on_main, p_show_on_did,
    p_requires_confirm,
    now(), p_valid_until,
    'ACTIVE', p_actor_id
  )
  on conflict (store_id, notice_code) do update set
    notice_type = excluded.notice_type,
    priority = excluded.priority,
    title = excluded.title,
    body = excluded.body,
    show_on_main = excluded.show_on_main,
    show_on_did = excluded.show_on_did,
    valid_until = excluded.valid_until,
    notice_status = 'ACTIVE',
    is_active = true,
    updated_at = now()
  returning id into v_notice_id;

  -- Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'notice_created',
    p_payload := jsonb_build_object(
      'notice_id', v_notice_id,
      'notice_type', p_notice_type,
      'priority', p_priority,
      'show_on_main', p_show_on_main,
      'show_on_did', p_show_on_did
    )
  );

  -- ledger event (URGENT/HIGH만)
  if p_priority in ('URGENT', 'HIGH') then
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
      'store', 'urgent_notice_created', 1,
      'store_notice', v_notice_id,
      null, 'ACTIVE',
      'STAFF', p_actor_id,
      jsonb_build_object(
        'notice_code', p_notice_code,
        'notice_type', p_notice_type,
        'priority', p_priority
      ),
      p_correlation_id,
      v_business_day, 'Asia/Seoul', now()
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'notice_id', v_notice_id,
    'notice_code', p_notice_code,
    'notice_type', p_notice_type,
    'priority', p_priority,
    'is_new', v_is_new,
    'message_code', 'notice_created'
  );
end;
$$;


create or replace function
  catchmenu_store.get_active_notices(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_notices jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'notice_id', id,
        'notice_code', notice_code,
        'notice_type', notice_type,
        'priority', priority,
        'title', coalesce(
          title->>p_locale,
          title->>'ko'
        ),
        'body', coalesce(
          body->>p_locale,
          body->>'ko'
        ),
        'show_on_main', show_on_main,
        'show_on_did', show_on_did,
        'requires_confirm', requires_confirm,
        'valid_until', valid_until,
        'created_at', created_at
      )
      order by
        case priority
          when 'URGENT' then 0
          when 'HIGH' then 1
          when 'NORMAL' then 2
          else 3
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_notices
  from catchmenu_store.store_notices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and notice_status = 'ACTIVE'
    and is_active = true
    and valid_from <= now()
    and (
      valid_until is null
      or valid_until >= now()
    )
    and display_channels @> to_jsonb(p_channel);

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'channel', p_channel,
    'locale', p_locale,
    'notices', v_notices,
    'notice_count', jsonb_array_length(v_notices),
    'has_urgent',
      exists (
        select 1
        from jsonb_array_elements(v_notices) n
        where n->>'priority' = 'URGENT'
      ),
    'message_code', 'notices_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.create_promotion(
  p_tenant_id uuid,
  p_store_id uuid,
  p_promotion_code text,
  p_promotion_name text,
  p_promotion_type text,
  p_benefit_type text,
  p_title_ko text,
  p_description_ko text,
  p_valid_from timestamptz,
  p_valid_until timestamptz default null,
  p_discount_value int default null,
  p_discount_pct numeric default null,
  p_min_order_amount int default null,
  p_max_discount_amount int default null,
  p_target_menu_ids jsonb default '[]'::jsonb,
  p_max_uses int default null,
  p_max_uses_per_customer int default 1,
  p_banner_image_url text default null,
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_promotion_id uuid;
  v_is_new boolean;
  v_initial_status text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 시작 시각 기준 상태 결정
  v_initial_status := case
    when p_valid_from <= now() then 'ACTIVE'
    else 'SCHEDULED'
  end;

  v_is_new := not exists (
    select 1 from catchmenu_store.promotions
    where store_id = p_store_id
      and promotion_code = p_promotion_code
  );

  insert into catchmenu_store.promotions (
    tenant_id, store_id,
    promotion_code, promotion_name,
    promotion_type, benefit_type,
    title, description,
    valid_from, valid_until,
    discount_value, discount_pct,
    min_order_amount, max_discount_amount,
    target_menu_ids,
    max_uses, max_uses_per_customer,
    banner_image_url,
    display_channels,
    promotion_status, created_by
  ) values (
    p_tenant_id, p_store_id,
    p_promotion_code, p_promotion_name,
    p_promotion_type, p_benefit_type,
    jsonb_build_object('ko', p_title_ko),
    jsonb_build_object('ko', p_description_ko),
    p_valid_from, p_valid_until,
    p_discount_value, p_discount_pct,
    p_min_order_amount, p_max_discount_amount,
    coalesce(p_target_menu_ids, '[]'::jsonb),
    p_max_uses, p_max_uses_per_customer,
    p_banner_image_url,
    '["APP","KIOSK"]'::jsonb,
    v_initial_status, p_actor_id
  )
  on conflict (store_id, promotion_code)
  do update set
    promotion_name = excluded.promotion_name,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    discount_value = excluded.discount_value,
    discount_pct = excluded.discount_pct,
    promotion_status = v_initial_status,
    is_active = true,
    updated_at = now()
  returning id into v_promotion_id;

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
    'store', 'promotion_created', 1,
    'promotion', v_promotion_id,
    null, v_initial_status,
    'STAFF', p_actor_id,
    jsonb_build_object(
      'promotion_code', p_promotion_code,
      'promotion_type', p_promotion_type,
      'benefit_type', p_benefit_type,
      'valid_from', p_valid_from,
      'valid_until', p_valid_until
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'promotion_id', v_promotion_id,
    'promotion_code', p_promotion_code,
    'promotion_type', p_promotion_type,
    'promotion_status', v_initial_status,
    'is_new', v_is_new,
    'message_code', 'promotion_created'
  );
end;
$$;


create or replace function
  catchmenu_store.get_active_promotions(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko',
  p_menu_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_promotions jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'promotion_id', id,
        'promotion_code', promotion_code,
        'promotion_name', promotion_name,
        'promotion_type', promotion_type,
        'benefit_type', benefit_type,
        'title', coalesce(
          title->>p_locale, title->>'ko'
        ),
        'description', coalesce(
          description->>p_locale,
          description->>'ko'
        ),
        'discount_value', discount_value,
        'discount_pct', discount_pct,
        'min_order_amount', min_order_amount,
        'max_discount_amount',
          max_discount_amount,
        'target_menu_ids', target_menu_ids,
        'valid_until', valid_until,
        'remaining_uses', case
          when max_uses is not null
          then max_uses - current_uses
          else null
        end,
        'banner_image_url', banner_image_url,
        'display_order', display_order
      )
      order by display_order asc,
               valid_from desc
    ),
    '[]'::jsonb
  )
  into v_promotions
  from catchmenu_store.promotions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and promotion_status = 'ACTIVE'
    and is_active = true
    and valid_from <= now()
    and (
      valid_until is null
      or valid_until >= now()
    )
    and (
      max_uses is null
      or current_uses < max_uses
    )
    and display_channels @> to_jsonb(p_channel)
    and (
      p_menu_id is null
      or jsonb_array_length(target_menu_ids) = 0
      or target_menu_ids @>
        to_jsonb(p_menu_id)
    );

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'channel', p_channel,
    'locale', p_locale,
    'promotions', v_promotions,
    'promotion_count',
      jsonb_array_length(v_promotions),
    'message_code', 'promotions_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.get_store_cms_bundle(
  p_tenant_id uuid,
  p_store_id uuid,
  p_channel text default 'APP',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_notices jsonb;
  v_promotions jsonb;
  v_cms_contents jsonb;
  v_business_day date;
  v_timezone text;
begin
  select id, store_name, timezone
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
      p_rpc_name := 'get_store_cms_bundle'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 공지사항
  v_notices := (
    catchmenu_store.get_active_notices(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel := p_channel,
      p_locale := p_locale
    )
  )->'notices';

  -- 프로모션
  v_promotions := (
    catchmenu_store.get_active_promotions(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel := p_channel,
      p_locale := p_locale
    )
  )->'promotions';

  -- CMS 콘텐츠 (배너/메뉴판 등)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'content_id', cc.id,
        'content_code', cc.content_code,
        'content_name', cc.content_name,
        'content_type', cc.content_type,
        'version_number',
          cc.current_version_number,
        'data', coalesce(
          case p_locale
            when 'ko' then cv.content_data_ko
            when 'en' then cv.content_data_en
            when 'zh' then cv.content_data_zh
            when 'ja' then cv.content_data_ja
            else null
          end,
          cv.content_data_ko,
          cv.content_data
        ),
        'image_urls', cv.image_urls,
        'thumbnail_url', cv.thumbnail_url
      )
      order by cc.content_type, cc.content_code
    ),
    '[]'::jsonb
  )
  into v_cms_contents
  from catchmenu_store.cms_contents cc
  left join catchmenu_store.cms_content_versions cv
    on cv.id = cc.current_version_id
  where cc.tenant_id = p_tenant_id
    and (
      cc.store_id = p_store_id
      or cc.store_id is null
    )
    and cc.content_status = 'PUBLISHED'
    and cc.is_active = true
    and (
      cc.valid_from is null
      or cc.valid_from <= now()
    )
    and (
      cc.valid_until is null
      or cc.valid_until >= now()
    )
    and cc.display_channels @>
      to_jsonb(p_channel);

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'channel', p_channel,
    'locale', p_locale,
    'business_day', v_business_day,
    'notices', coalesce(v_notices, '[]'::jsonb),
    'notice_count',
      jsonb_array_length(
        coalesce(v_notices, '[]'::jsonb)
      ),
    'promotions',
      coalesce(v_promotions, '[]'::jsonb),
    'promotion_count',
      jsonb_array_length(
        coalesce(v_promotions, '[]'::jsonb)
      ),
    'cms_contents',
      coalesce(v_cms_contents, '[]'::jsonb),
    'cms_count',
      jsonb_array_length(
        coalesce(v_cms_contents, '[]'::jsonb)
      ),
    'has_urgent_notice', exists (
      select 1
      from jsonb_array_elements(
        coalesce(v_notices, '[]'::jsonb)
      ) n
      where n->>'priority' = 'URGENT'
    ),
    'generated_at', now(),
    'message_code', 'cms_bundle_loaded'
  );
end;
$$;


-- pg_cron: 프로모션 상태 자동 업데이트
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'PROMOTION_STATUS_UPDATE',
  'catchmenu_promotion_status',
  '*/10 * * * *',
  '*/10 * * * * (10분마다)',
  $sql$
-- 시작된 프로모션 활성화
UPDATE catchmenu_store.promotions
SET promotion_status = 'ACTIVE', updated_at = now()
WHERE promotion_status = 'SCHEDULED'
  AND valid_from <= now()
  AND (valid_until IS NULL OR valid_until >= now());

-- 종료된 프로모션 만료
UPDATE catchmenu_store.promotions
SET promotion_status = 'ENDED', updated_at = now()
WHERE promotion_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 만료된 공지 처리
UPDATE catchmenu_store.store_notices
SET notice_status = 'EXPIRED', updated_at = now()
WHERE notice_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  '프로모션 상태 자동 전환 + 공지 만료 처리. 10분마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.publish_cms_content(
      uuid, uuid, text, text, text,
      jsonb, jsonb, jsonb, jsonb, jsonb,
      jsonb, timestamptz, timestamptz,
      text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.publish_cms_content(
      uuid, uuid, text, text, text,
      jsonb, jsonb, jsonb, jsonb, jsonb,
      jsonb, timestamptz, timestamptz,
      text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_content(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_content(
      uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_store_notice(
      uuid, uuid, text, text, text, text,
      text, text, text, boolean, boolean,
      boolean, timestamptz, jsonb, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_store_notice(
      uuid, uuid, text, text, text, text,
      text, text, text, boolean, boolean,
      boolean, timestamptz, jsonb, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_active_notices(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_active_notices(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_promotion(
      uuid, uuid, text, text, text, text,
      text, text, timestamptz, timestamptz,
      int, numeric, int, int, jsonb,
      int, int, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_promotion(
      uuid, uuid, text, text, text, text,
      text, text, timestamptz, timestamptz,
      int, numeric, int, int, jsonb,
      int, int, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_active_promotions(
      uuid, uuid, text, text, uuid
    ) from public;
  grant execute on function
    catchmenu_store.get_active_promotions(
      uuid, uuid, text, text, uuid
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_store_cms_bundle(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_store_cms_bundle(
      uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_store_cms_bundle(
    uuid, uuid, text, text
  ) is
  '앱/키오스크 시작 시 CMS 전체 번들 로드.
   단일 RPC 호출로:
   - 활성 공지사항 (긴급/높음/일반 순)
   - 활성 프로모션 (display_order 순)
   - 발행된 CMS 콘텐츠 (배너/메뉴판 등)
   channel: APP/KIOSK/DID 별 필터링.
   locale: 다국어 콘텐츠 자동 선택.
   has_urgent_notice: 긴급 공지 존재 여부.
   Flutter bootstrap_app 이후 별도 호출.
   1-B차 CMS 고도화 핵심 번들 RPC.';

comment on function
  catchmenu_store.publish_cms_content(
    uuid, uuid, text, text, text,
    jsonb, jsonb, jsonb, jsonb, jsonb,
    jsonb, timestamptz, timestamptz,
    text, uuid, text
  ) is
  'CMS 콘텐츠 발행 + 버전 관리.
   기존 PUBLISHED 버전 → SUPERSEDED 처리.
   새 버전 생성 → 마스터 버전 업데이트.
   Realtime → 앱/키오스크/DID 즉시 반영.
   i18n: content_data_ko/en/zh/ja 분리 저장.
   특허4: CMS 콘텐츠 = 버전 감사 추적.
   1-B차 CMS 메뉴/콘텐츠 관리 기반.';

-- ===== END sql/migrations/0080_create_cms_content_rpc.sql =====


-- ===== BEGIN sql/migrations/0107_create_mini_cms_pipeline_rpc.sql =====

-- 0107_create_mini_cms_pipeline_rpc.sql
-- Purpose: Mini CMS pipeline for store owners.
--          업주 앱에서 이벤트/배너/쿠폰 등록.
--          고객 앱 + 키오스크 + DID 동시 반영.
--          3차 키오스크 개발 시 재사용 설계.
--          향후 쿠폰 사업 플랫폼 기반.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0106_create_delivery_platform_pipeline_rpc.sql
-- Creates:
--   catchmenu_store.cms_events (table)
--   catchmenu_store.cms_banners (table)
--   catchmenu_store.cms_popups (table)
--   catchmenu_store.cms_publish_log (table)
--   function catchmenu_store.create_cms_event(...)
--   function catchmenu_store.publish_cms_event(...)
--   function catchmenu_store.create_cms_banner(...)
--   function catchmenu_store.create_cms_popup(...)
--   function catchmenu_store.get_cms_dashboard(...)
--   function catchmenu_store.get_cms_display_bundle(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('cms_event_created', 'ko',
  '이벤트가 등록되었습니다'),
('cms_event_created', 'en',
  'Event created'),
('cms_event_published', 'ko',
  '이벤트가 발행되었습니다'),
('cms_event_published', 'en',
  'Event published'),
('cms_event_ended', 'ko',
  '이벤트가 종료되었습니다'),
('cms_event_ended', 'en',
  'Event ended'),
('cms_banner_created', 'ko',
  '배너가 등록되었습니다'),
('cms_banner_created', 'en',
  'Banner created'),
('cms_popup_created', 'ko',
  '팝업이 등록되었습니다'),
('cms_popup_created', 'en',
  'Popup created'),
('cms_dashboard_loaded', 'ko',
  'CMS 대시보드가 로드되었습니다'),
('cms_dashboard_loaded', 'en',
  'CMS dashboard loaded'),
('cms_display_bundle_loaded', 'ko',
  'CMS 표시 데이터가 로드되었습니다'),
('cms_display_bundle_loaded', 'en',
  'CMS display bundle loaded'),
('cms_event_not_found', 'ko',
  '이벤트를 찾을 수 없습니다'),
('cms_event_not_found', 'en',
  'Event not found'),
('cms_coupon_linked', 'ko',
  '이벤트에 쿠폰이 연결되었습니다'),
('cms_coupon_linked', 'en',
  'Coupon linked to event'),

-- 고객 앱 표시용 (6개 로케일)
('event_ongoing', 'ko', '진행 중'),
('event_ongoing', 'en', 'Ongoing'),
('event_ongoing', 'zh', '进行中'),
('event_ongoing', 'ja', '開催中'),
('event_ongoing', 'vi', 'Đang diễn ra'),
('event_ongoing', 'th', 'กำลังดำเนินการ'),

('event_dday', 'ko', '오늘 마감'),
('event_dday', 'en', 'Ends Today'),
('event_dday', 'zh', '今日截止'),
('event_dday', 'ja', '本日終了'),
('event_dday', 'vi', 'Kết thúc hôm nay'),
('event_dday', 'th', 'สิ้นสุดวันนี้'),

('event_new', 'ko', '새 이벤트'),
('event_new', 'en', 'New Event'),
('event_new', 'zh', '新活动'),
('event_new', 'ja', '新しいイベント'),
('event_new', 'vi', 'Sự kiện mới'),
('event_new', 'th', 'กิจกรรมใหม่'),

('tap_for_coupon', 'ko', '탭해서 쿠폰받기'),
('tap_for_coupon', 'en', 'Tap for coupon'),
('tap_for_coupon', 'zh', '点击领取优惠券'),
('tap_for_coupon', 'ja', 'タップしてクーポンをゲット'),
('tap_for_coupon', 'vi', 'Nhấn để nhận phiếu'),
('tap_for_coupon', 'th', 'แตะเพื่อรับคูปอง')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7030, 'cms_event_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7031, 'cms_event_not_publishable',
  'STORE', 'BUSINESS_RULE', 409, 'WARNING'),
(7032, 'cms_banner_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7033, 'cms_display_limit_exceeded',
  'STORE', 'CAPACITY', 429, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- cms_events table
-- 업주 이벤트 (할인/특가/기념일 등)
-- =============================================
create table if not exists
  catchmenu_store.cms_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 이벤트 기본 정보
  event_code text not null,
  event_type text not null,
  event_status text not null default 'DRAFT',

  -- 다국어 제목/내용
  title_ko text not null,
  title_en text,
  title_zh text,
  title_ja text,
  title_vi text,
  title_th text,

  body_ko text,
  body_en text,
  body_zh text,
  body_ja text,
  body_vi text,
  body_th text,

  -- 이미지
  thumbnail_url text,
  banner_image_url text,
  detail_image_urls jsonb default '[]'::jsonb,

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 대상
  display_targets jsonb
    not null default
      '["CUSTOMER_APP","KIOSK","DID"]'::jsonb,
  target_membership_tiers jsonb
    default '["ALL"]'::jsonb,

  -- 연결 쿠폰
  linked_coupon_id uuid
    references catchmenu_store.coupons(id),
  coupon_auto_issue boolean
    not null default false,

  -- 표시 설정
  display_order int not null default 0,
  is_featured boolean not null default false,
  badge_text_key text,

  -- 통계
  view_count int not null default 0,
  coupon_claim_count int not null default 0,
  tap_count int not null default 0,

  -- 발행 정보
  published_at timestamptz,
  published_by uuid,
  ended_at timestamptz,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_event_code unique (
    store_id, event_code
  ),
  constraint chk_event_type check (
    event_type in (
      'DISCOUNT',       -- 할인 이벤트
      'SPECIAL_PRICE',  -- 특가
      'NEW_MENU',       -- 신메뉴
      'ANNIVERSARY',    -- 기념일
      'SEASONAL',       -- 시즌
      'HAPPY_HOUR',     -- 해피아워
      'COMBO',          -- 세트/콤보
      'COUPON',         -- 쿠폰 이벤트
      'NOTICE',         -- 공지
      'CUSTOM'          -- 직접 작성
    )
  ),
  constraint chk_event_status check (
    event_status in (
      'DRAFT',
      'SCHEDULED',
      'ACTIVE',
      'ENDED',
      'CANCELLED'
    )
  )
);

create index if not exists idx_cms_events_store
  on catchmenu_store.cms_events(
    store_id, event_status,
    display_order, valid_from
  ) where event_status = 'ACTIVE';
create index if not exists idx_cms_events_valid
  on catchmenu_store.cms_events(
    store_id, valid_from, valid_until
  ) where event_status in (
    'SCHEDULED', 'ACTIVE'
  );

alter table catchmenu_store.cms_events
  enable row level security;
alter table catchmenu_store.cms_events
  force row level security;

drop policy if exists cms_events_isolation
  on catchmenu_store.cms_events;
create policy cms_events_isolation
  on catchmenu_store.cms_events
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_events_updated
  on catchmenu_store.cms_events;
create trigger trg_cms_events_updated
  before update on catchmenu_store.cms_events
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_events is
  '업주 이벤트 관리.
   Mini CMS 핵심 테이블.
   display_targets: CUSTOMER_APP/KIOSK/DID
   linked_coupon_id: 쿠폰 이벤트 연결.
   coupon_auto_issue: 탭 시 자동 쿠폰 발급.
   badge_text_key: event_new/event_dday 등.
   3차 키오스크 개발 시 그대로 재사용.
   DID 연동 시 이벤트 배너 자동 표시.
   향후 쿠폰 사업 플랫폼 기반.';


-- =============================================
-- cms_banners table
-- 배너 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_banners (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 배너 정보
  banner_code text not null,
  banner_type text not null,
  banner_status text not null default 'DRAFT',

  -- 다국어 텍스트
  title_ko text not null,
  title_en text,
  subtitle_ko text,
  subtitle_en text,

  -- 이미지
  image_url text,
  background_color text default '#FFFFFF',
  text_color text default '#000000',

  -- 링크
  link_type text default 'NONE',
  link_target text,
  linked_event_id uuid
    references catchmenu_store.cms_events(id),

  -- 표시 위치
  display_position text not null default 'TOP',
  display_targets jsonb
    not null default
      '["CUSTOMER_APP","KIOSK"]'::jsonb,
  display_order int not null default 0,

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 통계
  view_count int not null default 0,
  tap_count int not null default 0,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_banner_code unique (
    store_id, banner_code
  ),
  constraint chk_banner_type check (
    banner_type in (
      'MAIN_TOP',    -- 메인 상단
      'MAIN_MIDDLE', -- 메인 중단
      'POPUP',       -- 팝업
      'FLOATING',    -- 플로팅
      'DID_FULL',    -- DID 전체 화면
      'DID_SIDE'     -- DID 사이드
    )
  ),
  constraint chk_banner_status check (
    banner_status in (
      'DRAFT', 'ACTIVE',
      'INACTIVE', 'EXPIRED'
    )
  ),
  constraint chk_display_position check (
    display_position in (
      'TOP', 'MIDDLE', 'BOTTOM',
      'FULL', 'FLOATING'
    )
  )
);

create index if not exists idx_cms_banners_store
  on catchmenu_store.cms_banners(
    store_id, banner_status,
    display_order
  ) where banner_status = 'ACTIVE';

alter table catchmenu_store.cms_banners
  enable row level security;
alter table catchmenu_store.cms_banners
  force row level security;

drop policy if exists cms_banners_isolation
  on catchmenu_store.cms_banners;
create policy cms_banners_isolation
  on catchmenu_store.cms_banners
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_banners_updated
  on catchmenu_store.cms_banners;
create trigger trg_cms_banners_updated
  before update on catchmenu_store.cms_banners
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_banners is
  '배너 관리.
   Mini CMS 배너 모듈.
   display_targets: CUSTOMER_APP/KIOSK/DID.
   DID_FULL: DID 전체 화면 광고 배너.
   linked_event_id: 이벤트 연결.
   3차 키오스크 재사용.
   향후 외부 광고주 배너 삽입 포인트.';


-- =============================================
-- cms_popups table
-- 팝업 관리
-- =============================================
create table if not exists
  catchmenu_store.cms_popups (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  popup_code text not null,
  popup_type text not null,
  popup_status text not null default 'DRAFT',

  -- 다국어 내용
  title_ko text not null,
  title_en text,
  body_ko text,
  body_en text,
  cta_text_key text,

  -- 이미지
  image_url text,

  -- 버튼
  primary_button_text_key text,
  primary_button_action text,
  secondary_button_text_key text,

  -- 표시 조건
  display_targets jsonb
    not null default
      '["CUSTOMER_APP"]'::jsonb,
  trigger_event text default 'APP_OPEN',
  show_once_per_session boolean
    not null default true,

  -- 연결
  linked_event_id uuid
    references catchmenu_store.cms_events(id),
  linked_coupon_id uuid
    references catchmenu_store.coupons(id),

  -- 기간
  valid_from timestamptz,
  valid_until timestamptz,

  -- 통계
  view_count int not null default 0,
  cta_click_count int not null default 0,
  dismiss_count int not null default 0,

  created_by uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_cms_popup_code unique (
    store_id, popup_code
  ),
  constraint chk_popup_type check (
    popup_type in (
      'EVENT',      -- 이벤트 알림
      'COUPON',     -- 쿠폰 증정
      'NOTICE',     -- 공지
      'SURVEY',     -- 설문
      'RATING'      -- 평가 요청
    )
  ),
  constraint chk_popup_status check (
    popup_status in (
      'DRAFT', 'ACTIVE',
      'INACTIVE', 'EXPIRED'
    )
  ),
  constraint chk_trigger_event check (
    trigger_event in (
      'APP_OPEN',
      'ORDER_COMPLETE',
      'MENU_VIEW',
      'COUPON_PAGE',
      'CUSTOM'
    )
  )
);

create index if not exists idx_cms_popups_store
  on catchmenu_store.cms_popups(
    store_id, popup_status, valid_until
  ) where popup_status = 'ACTIVE';

alter table catchmenu_store.cms_popups
  enable row level security;
alter table catchmenu_store.cms_popups
  force row level security;

drop policy if exists cms_popups_isolation
  on catchmenu_store.cms_popups;
create policy cms_popups_isolation
  on catchmenu_store.cms_popups
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cms_popups_updated
  on catchmenu_store.cms_popups;
create trigger trg_cms_popups_updated
  before update on catchmenu_store.cms_popups
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.cms_popups is
  '팝업 관리.
   trigger_event: APP_OPEN/ORDER_COMPLETE.
   show_once_per_session: 세션당 1회.
   linked_coupon_id: 팝업 쿠폰 자동 발급 연결.
   RATING 팝업: 주문 완료 후 평가 요청.
   3차 키오스크 재사용.';


-- =============================================
-- cms_publish_log table
-- CMS 발행 이력
-- =============================================
create table if not exists
  catchmenu_store.cms_publish_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  content_type text not null,
  content_id uuid not null,
  content_code text,

  action text not null,
  action_by uuid,
  action_reason text,

  before_status text,
  after_status text,

  display_targets jsonb,
  realtime_notified boolean
    not null default false,

  actioned_at timestamptz
    not null default now(),

  constraint chk_content_type check (
    content_type in (
      'EVENT', 'BANNER', 'POPUP',
      'NOTICE', 'PROMOTION'
    )
  ),
  constraint chk_cms_action check (
    action in (
      'CREATED', 'PUBLISHED',
      'UPDATED', 'ENDED',
      'CANCELLED', 'DELETED'
    )
  )
);

create index if not exists idx_cms_publish_log
  on catchmenu_store.cms_publish_log(
    store_id, content_type, actioned_at desc
  );

alter table catchmenu_store.cms_publish_log
  enable row level security;
alter table catchmenu_store.cms_publish_log
  force row level security;

drop policy if exists cms_publish_log_isolation
  on catchmenu_store.cms_publish_log;
create policy cms_publish_log_isolation
  on catchmenu_store.cms_publish_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.cms_publish_log is
  'CMS 발행 이력.
   append-only 감사 로그.
   업주가 언제 무엇을 발행/수정/종료했는지 추적.
   특허4: CMS 발행 = 운영 이벤트 감사.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.create_cms_event(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_type text,
  p_title_ko text,
  p_body_ko text default null,
  p_title_en text default null,
  p_body_en text default null,
  p_thumbnail_url text default null,
  p_banner_image_url text default null,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_display_targets jsonb
    default '["CUSTOMER_APP","KIOSK","DID"]'::jsonb,
  p_linked_coupon_id uuid default null,
  p_coupon_auto_issue boolean default false,
  p_is_featured boolean default false,
  p_created_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_event_id uuid;
  v_event_code text;
  v_badge_key text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 이벤트 코드 생성
  v_event_code := 'EVT-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_events
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  -- 배지 텍스트 결정
  v_badge_key := case
    when p_valid_from is not null
      and p_valid_from > now()
      then 'event_new'
    when p_valid_until is not null
      and p_valid_until::date = v_business_day
      then 'event_dday'
    else 'event_ongoing'
  end;

  insert into catchmenu_store.cms_events (
    tenant_id, store_id,
    event_code, event_type,
    event_status,
    title_ko, title_en,
    body_ko, body_en,
    thumbnail_url, banner_image_url,
    valid_from, valid_until,
    display_targets,
    target_membership_tiers,
    linked_coupon_id,
    coupon_auto_issue,
    is_featured, badge_text_key,
    display_order,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_event_code, p_event_type,
    case
      when p_valid_from is not null
        and p_valid_from > now()
        then 'SCHEDULED'
      else 'DRAFT'
    end,
    p_title_ko, p_title_en,
    p_body_ko, p_body_en,
    p_thumbnail_url, p_banner_image_url,
    p_valid_from, p_valid_until,
    p_display_targets,
    '["ALL"]'::jsonb,
    p_linked_coupon_id,
    p_coupon_auto_issue,
    p_is_featured, v_badge_key,
    0,
    p_created_by
  )
  returning id into v_event_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets
  ) values (
    p_tenant_id, p_store_id,
    'EVENT', v_event_id, v_event_code,
    'CREATED', p_created_by,
    null, 'DRAFT',
    p_display_targets
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'cms', 'cms_event_created', 1,
    'cms_event', v_event_id,
    null, 'DRAFT',
    'STAFF', p_created_by,
    jsonb_build_object(
      'event_code', v_event_code,
      'event_type', p_event_type,
      'title_ko', p_title_ko,
      'has_coupon',
        p_linked_coupon_id is not null,
      'display_targets', p_display_targets
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_event_created',
    p_data := jsonb_build_object(
      'event_id', v_event_id,
      'event_code', v_event_code,
      'event_type', p_event_type,
      'event_status', 'DRAFT',
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'has_coupon',
        p_linked_coupon_id is not null,
      'coupon_auto_issue', p_coupon_auto_issue,
      'next_step',
        'publish_cms_event() 호출로 발행'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.publish_cms_event(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_id uuid,
  p_published_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_event record;
begin
  select id, event_code, event_type,
         event_status, title_ko,
         display_targets, valid_from,
         valid_until, linked_coupon_id
  into v_event
  from catchmenu_store.cms_events
  where id = p_event_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_event.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'cms_event_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'publish_cms_event'
    );
  end if;

  if v_event.event_status
    not in ('DRAFT', 'SCHEDULED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'cms_event_not_publishable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'publish_cms_event'
    );
  end if;

  -- 이벤트 활성화
  update catchmenu_store.cms_events
  set
    event_status = 'ACTIVE',
    published_at = now(),
    published_by = p_published_by,
    badge_text_key = case
      when valid_until::date
        = (timezone('Asia/Seoul', now()))::date
        then 'event_dday'
      else 'event_ongoing'
    end,
    updated_at = now()
  where id = p_event_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'EVENT', v_event.id, v_event.event_code,
    'PUBLISHED', p_published_by,
    v_event.event_status, 'ACTIVE',
    v_event.display_targets, true
  );

  -- Realtime 브로드캐스트 → 전 디바이스
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_type', 'EVENT',
      'event_id', v_event.id,
      'event_code', v_event.event_code,
      'event_type', v_event.event_type,
      'title_ko', v_event.title_ko,
      'display_targets', v_event.display_targets,
      'has_coupon',
        v_event.linked_coupon_id is not null,
      'published_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_event_published',
    p_data := jsonb_build_object(
      'event_id', v_event.id,
      'event_code', v_event.event_code,
      'event_type', v_event.event_type,
      'event_status', 'ACTIVE',
      'title_ko', v_event.title_ko,
      'display_targets', v_event.display_targets,
      'published_at', now(),
      'realtime_notified', true,
      'targets_note', jsonb_build_object(
        'CUSTOMER_APP', '고객 앱 즉시 반영',
        'KIOSK', '키오스크 즉시 반영',
        'DID', 'DID 디스플레이 즉시 반영'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.create_cms_banner(
  p_tenant_id uuid,
  p_store_id uuid,
  p_banner_type text,
  p_title_ko text,
  p_subtitle_ko text default null,
  p_title_en text default null,
  p_image_url text default null,
  p_background_color text default '#FFFFFF',
  p_text_color text default '#000000',
  p_link_type text default 'NONE',
  p_link_target text default null,
  p_linked_event_id uuid default null,
  p_display_position text default 'TOP',
  p_display_targets jsonb
    default '["CUSTOMER_APP","KIOSK"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_display_order int default 0,
  p_created_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_banner_id uuid;
  v_banner_code text;
begin
  v_banner_code := 'BNR-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_banners
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  insert into catchmenu_store.cms_banners (
    tenant_id, store_id,
    banner_code, banner_type,
    banner_status,
    title_ko, title_en,
    subtitle_ko,
    image_url,
    background_color, text_color,
    link_type, link_target,
    linked_event_id,
    display_position,
    display_targets, display_order,
    valid_from, valid_until,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_banner_code, p_banner_type,
    'ACTIVE',
    p_title_ko, p_title_en,
    p_subtitle_ko,
    p_image_url,
    p_background_color, p_text_color,
    p_link_type, p_link_target,
    p_linked_event_id,
    p_display_position,
    p_display_targets, p_display_order,
    p_valid_from, p_valid_until,
    p_created_by
  )
  returning id into v_banner_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'BANNER', v_banner_id, v_banner_code,
    'PUBLISHED', p_created_by,
    null, 'ACTIVE',
    p_display_targets, true
  );

  -- Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'cms_content_published',
    p_payload := jsonb_build_object(
      'content_type', 'BANNER',
      'banner_id', v_banner_id,
      'banner_code', v_banner_code,
      'banner_type', p_banner_type,
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'display_position', p_display_position
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_banner_created',
    p_data := jsonb_build_object(
      'banner_id', v_banner_id,
      'banner_code', v_banner_code,
      'banner_type', p_banner_type,
      'banner_status', 'ACTIVE',
      'title_ko', p_title_ko,
      'display_targets', p_display_targets,
      'realtime_notified', true
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.create_cms_popup(
  p_tenant_id uuid,
  p_store_id uuid,
  p_popup_type text,
  p_title_ko text,
  p_body_ko text default null,
  p_title_en text default null,
  p_body_en text default null,
  p_image_url text default null,
  p_cta_text_key text default null,
  p_trigger_event text default 'APP_OPEN',
  p_linked_event_id uuid default null,
  p_linked_coupon_id uuid default null,
  p_display_targets jsonb
    default '["CUSTOMER_APP"]'::jsonb,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_show_once_per_session boolean default true,
  p_created_by uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_popup_id uuid;
  v_popup_code text;
begin
  v_popup_code := 'POP-'
    || to_char(now(), 'YYYYMMDD')
    || '-' || lpad(
      (
        select coalesce(count(*), 0) + 1
        from catchmenu_store.cms_popups
        where store_id = p_store_id
          and tenant_id = p_tenant_id
      )::text, 4, '0'
    );

  insert into catchmenu_store.cms_popups (
    tenant_id, store_id,
    popup_code, popup_type,
    popup_status,
    title_ko, title_en,
    body_ko, body_en,
    image_url,
    cta_text_key,
    trigger_event,
    linked_event_id, linked_coupon_id,
    display_targets,
    valid_from, valid_until,
    show_once_per_session,
    primary_button_text_key,
    primary_button_action,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    v_popup_code, p_popup_type,
    'ACTIVE',
    p_title_ko, p_title_en,
    p_body_ko, p_body_en,
    p_image_url,
    p_cta_text_key,
    p_trigger_event,
    p_linked_event_id, p_linked_coupon_id,
    p_display_targets,
    p_valid_from, p_valid_until,
    p_show_once_per_session,
    coalesce(p_cta_text_key, 'tap_for_coupon'),
    case p_popup_type
      when 'COUPON' then 'ISSUE_COUPON'
      when 'EVENT' then 'VIEW_EVENT'
      else 'DISMISS'
    end,
    p_created_by
  )
  returning id into v_popup_id;

  -- 발행 로그
  insert into catchmenu_store.cms_publish_log (
    tenant_id, store_id,
    content_type, content_id, content_code,
    action, action_by,
    before_status, after_status,
    display_targets, realtime_notified
  ) values (
    p_tenant_id, p_store_id,
    'POPUP', v_popup_id, v_popup_code,
    'PUBLISHED', p_created_by,
    null, 'ACTIVE',
    p_display_targets, true
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_popup_created',
    p_data := jsonb_build_object(
      'popup_id', v_popup_id,
      'popup_code', v_popup_code,
      'popup_type', p_popup_type,
      'popup_status', 'ACTIVE',
      'title_ko', p_title_ko,
      'trigger_event', p_trigger_event,
      'has_coupon',
        p_linked_coupon_id is not null,
      'display_targets', p_display_targets
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_display_bundle(
  p_tenant_id uuid,
  p_store_id uuid,
  p_display_target text,
  p_trigger_event text default 'APP_OPEN',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_events jsonb;
  v_banners jsonb;
  v_popups jsonb;
  v_now timestamptz := now();
begin
  -- 활성 이벤트
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'event_id', id,
        'event_code', event_code,
        'event_type', event_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          when 'zh' then coalesce(title_zh, title_ko)
          when 'ja' then coalesce(title_ja, title_ko)
          when 'vi' then coalesce(title_vi, title_ko)
          when 'th' then coalesce(title_th, title_ko)
          else title_ko
        end,
        'body', case p_locale
          when 'ko' then body_ko
          when 'en' then coalesce(body_en, body_ko)
          else body_ko
        end,
        'thumbnail_url', thumbnail_url,
        'banner_image_url', banner_image_url,
        'valid_from', valid_from,
        'valid_until', valid_until,
        'is_featured', is_featured,
        'badge_text',
          catchmenu_common.get_message(
            coalesce(
              badge_text_key, 'event_ongoing'
            ),
            p_locale, null
          ),
        'has_coupon',
          linked_coupon_id is not null,
        'coupon_auto_issue', coupon_auto_issue,
        'tap_text', case
          when linked_coupon_id is not null
          then catchmenu_common.get_message(
            'tap_for_coupon', p_locale, null
          )
          else null
        end,
        'view_count', view_count
      )
      order by
        is_featured desc,
        display_order asc,
        published_at desc
    ),
    '[]'::jsonb
  )
  into v_events
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and event_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  -- 활성 배너
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'banner_id', id,
        'banner_code', banner_code,
        'banner_type', banner_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          else title_ko
        end,
        'subtitle', subtitle_ko,
        'image_url', image_url,
        'background_color', background_color,
        'text_color', text_color,
        'link_type', link_type,
        'link_target', link_target,
        'display_position', display_position,
        'view_count', view_count
      )
      order by display_order asc
    ),
    '[]'::jsonb
  )
  into v_banners
  from catchmenu_store.cms_banners
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and banner_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  -- 활성 팝업
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'popup_id', id,
        'popup_code', popup_code,
        'popup_type', popup_type,
        'title', case p_locale
          when 'ko' then title_ko
          when 'en' then coalesce(title_en, title_ko)
          else title_ko
        end,
        'body', case p_locale
          when 'ko' then body_ko
          when 'en' then coalesce(body_en, body_ko)
          else body_ko
        end,
        'image_url', image_url,
        'cta_text',
          catchmenu_common.get_message(
            coalesce(
              cta_text_key, 'tap_for_coupon'
            ),
            p_locale, null
          ),
        'primary_button_text',
          catchmenu_common.get_message(
            coalesce(
              primary_button_text_key,
              'tap_for_coupon'
            ),
            p_locale, null
          ),
        'primary_button_action',
          primary_button_action,
        'trigger_event', trigger_event,
        'show_once_per_session',
          show_once_per_session,
        'has_coupon',
          linked_coupon_id is not null,
        'linked_coupon_id', linked_coupon_id,
        'view_count', view_count
      )
    ),
    '[]'::jsonb
  )
  into v_popups
  from catchmenu_store.cms_popups
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and popup_status = 'ACTIVE'
    and display_targets
      @> to_jsonb(p_display_target)
    and trigger_event = p_trigger_event
    and (
      valid_from is null
      or valid_from <= v_now
    )
    and (
      valid_until is null
      or valid_until >= v_now
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_display_bundle_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'display_target', p_display_target,
      'locale', p_locale,
      'events', v_events,
      'event_count',
        jsonb_array_length(v_events),
      'banners', v_banners,
      'banner_count',
        jsonb_array_length(v_banners),
      'popups', v_popups,
      'popup_count',
        jsonb_array_length(v_popups),
      'has_content',
        jsonb_array_length(v_events) > 0
        or jsonb_array_length(v_banners) > 0,
      'loaded_at', v_now
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_cms_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_event_summary jsonb;
  v_banner_summary jsonb;
  v_popup_summary jsonb;
  v_recent_logs jsonb;
  v_coupon_event_count int;
begin
  -- 이벤트 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where event_status = 'ACTIVE'
    ),
    'scheduled', count(*) filter (
      where event_status = 'SCHEDULED'
    ),
    'draft', count(*) filter (
      where event_status = 'DRAFT'
    ),
    'ended', count(*) filter (
      where event_status = 'ENDED'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'total_coupon_claims', coalesce(
      sum(coupon_claim_count), 0
    ),
    'total_taps', coalesce(
      sum(tap_count), 0
    )
  )
  into v_event_summary
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 배너 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where banner_status = 'ACTIVE'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'total_taps', coalesce(
      sum(tap_count), 0
    )
  )
  into v_banner_summary
  from catchmenu_store.cms_banners
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 팝업 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where popup_status = 'ACTIVE'
    ),
    'total_views', coalesce(
      sum(view_count), 0
    ),
    'cta_clicks', coalesce(
      sum(cta_click_count), 0
    )
  )
  into v_popup_summary
  from catchmenu_store.cms_popups
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 쿠폰 연결 이벤트 수
  select count(*) into v_coupon_event_count
  from catchmenu_store.cms_events
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and event_status = 'ACTIVE'
    and linked_coupon_id is not null;

  -- 최근 발행 이력
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'content_type', content_type,
        'content_code', content_code,
        'action', action,
        'before_status', before_status,
        'after_status', after_status,
        'actioned_at', actioned_at
      )
      order by actioned_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_logs
  from catchmenu_store.cms_publish_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  limit 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'cms_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'events', v_event_summary,
      'banners', v_banner_summary,
      'popups', v_popup_summary,
      'coupon_event_count',
        v_coupon_event_count,
      'recent_logs', v_recent_logs,
      'reuse_note', jsonb_build_object(
        'CUSTOMER_APP', '고객 앱 반영',
        'KIOSK', '3차 키오스크 재사용',
        'DID', 'DID 배너 표시',
        'coupon_business',
          '쿠폰 이벤트 = 향후 쿠폰 사업 기반'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: CMS 콘텐츠 만료 처리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'CMS_CONTENT_EXPIRE',
  'catchmenu_cms_content_expire',
  '*/10 * * * *',
  '*/10 * * * * (10분마다)',
  $sql$
-- 이벤트 만료
UPDATE catchmenu_store.cms_events
SET event_status = 'ENDED', updated_at = now()
WHERE event_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 이벤트 자동 시작 (SCHEDULED → ACTIVE)
UPDATE catchmenu_store.cms_events
SET event_status = 'ACTIVE', updated_at = now()
WHERE event_status = 'SCHEDULED'
  AND valid_from IS NOT NULL
  AND valid_from <= now();

-- 배너 만료
UPDATE catchmenu_store.cms_banners
SET banner_status = 'EXPIRED', updated_at = now()
WHERE banner_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();

-- 팝업 만료
UPDATE catchmenu_store.cms_popups
SET popup_status = 'EXPIRED', updated_at = now()
WHERE popup_status = 'ACTIVE'
  AND valid_until IS NOT NULL
  AND valid_until < now();
$sql$,
  'CMS 콘텐츠 자동 만료/시작. 10분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.create_cms_event(
      uuid, uuid, text, text, text, text,
      text, text, text, timestamptz,
      timestamptz, jsonb, uuid, boolean,
      boolean, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_event(
      uuid, uuid, text, text, text, text,
      text, text, text, timestamptz,
      timestamptz, jsonb, uuid, boolean,
      boolean, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.publish_cms_event(
      uuid, uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.publish_cms_event(
      uuid, uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_cms_banner(
      uuid, uuid, text, text, text, text,
      text, text, text, text, text,
      uuid, text, jsonb, timestamptz,
      timestamptz, int, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_banner(
      uuid, uuid, text, text, text, text,
      text, text, text, text, text,
      uuid, text, jsonb, timestamptz,
      timestamptz, int, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.create_cms_popup(
      uuid, uuid, text, text, text, text,
      text, text, text, text, uuid,
      uuid, jsonb, timestamptz, timestamptz,
      boolean, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.create_cms_popup(
      uuid, uuid, text, text, text, text,
      text, text, text, text, uuid,
      uuid, jsonb, timestamptz, timestamptz,
      boolean, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_display_bundle(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_display_bundle(
      uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_cms_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_store.get_cms_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_cms_display_bundle(
    uuid, uuid, text, text, text
  ) is
  'CMS 표시 데이터 통합 번들.
   단일 RPC로 이벤트 + 배너 + 팝업 전체 반환.

   display_target별 용도:
   CUSTOMER_APP → 고객 앱 홈 화면
   KIOSK → 3차 키오스크 메인 화면
   DID → DID 디스플레이 배너

   다국어 자동 처리:
   locale 파라미터로 언어 선택.
   미번역 시 한국어 fallback.

   쿠폰 연결:
   has_coupon = true 시 tap_text 표시.
   coupon_auto_issue = true 시 탭 즉시 발급.

   재사용 설계:
   1-B차: 고객 앱
   3차: 키오스크 (그대로 사용)
   DID: 배너 채널 (이미 연동됨)
   향후: 쿠폰 사업 플랫폼 기반.';

comment on function
  catchmenu_store.create_cms_event(
    uuid, uuid, text, text, text, text,
    text, text, text, timestamptz,
    timestamptz, jsonb, uuid, boolean,
    boolean, uuid, text
  ) is
  '업주 이벤트 생성.
   이벤트 유형:
   DISCOUNT: 할인 (예: 런치 20% 할인)
   SPECIAL_PRICE: 특가 (예: 오늘의 특가)
   NEW_MENU: 신메뉴 출시
   ANNIVERSARY: 기념일 (개업 n주년)
   SEASONAL: 시즌 (여름 냉면 특가)
   HAPPY_HOUR: 해피아워
   COMBO: 세트메뉴 이벤트
   COUPON: 쿠폰 이벤트
   NOTICE: 공지
   CUSTOM: 자유 형식

   linked_coupon_id: 쿠폰 연결.
   coupon_auto_issue: 탭 즉시 쿠폰 발급.

   발행 2단계:
   1. create_cms_event() → DRAFT
   2. publish_cms_event() → ACTIVE + Realtime.

   Realtime 발행 → 고객앱/키오스크/DID 즉시 반영.';

-- ===== END sql/migrations/0107_create_mini_cms_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0117_create_did_pipeline_rpc.sql =====

-- 0117_create_did_pipeline_rpc.sql
-- Purpose: DID display pipeline completion.
--          대기 번호 표시 + 이벤트 배너.
--          호출 큐 관리.
--          다국어 안내 메시지.
--          Flutter DID 앱 부트스트랩.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0116_create_customer_app_bootstrap_rpc.sql
-- Creates:
--   function catchmenu_store.bootstrap_did_app(...)
--   function catchmenu_store.get_did_display_state(...)
--   function catchmenu_store.dismiss_did_call(...)
--   function catchmenu_store.get_did_waiting_numbers(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('did_app_ready', 'ko',
  'DID 디스플레이가 준비되었습니다'),
('did_app_ready', 'en',
  'DID display ready'),
('did_state_loaded', 'ko',
  'DID 상태가 로드되었습니다'),
('did_state_loaded', 'en',
  'DID state loaded'),

-- DID 안내 메시지 (6개 로케일)
('did_welcome_msg', 'ko',
  '어서오세요'),
('did_welcome_msg', 'en', 'Welcome'),
('did_welcome_msg', 'zh', '欢迎光临'),
('did_welcome_msg', 'ja', 'いらっしゃいませ'),
('did_welcome_msg', 'vi', 'Chào mừng'),
('did_welcome_msg', 'th', 'ยินดีต้อนรับ'),

('did_now_calling', 'ko', '호출 중'),
('did_now_calling', 'en', 'Now Calling'),
('did_now_calling', 'zh', '叫号中'),
('did_now_calling', 'ja', 'お呼び出し中'),
('did_now_calling', 'vi', 'Đang gọi'),
('did_now_calling', 'th', 'กำลังเรียก'),

('did_please_proceed', 'ko',
  '입장해 주세요'),
('did_please_proceed', 'en',
  'Please proceed'),
('did_please_proceed', 'zh', '请进'),
('did_please_proceed', 'ja', 'どうぞお入りください'),
('did_please_proceed', 'vi', 'Mời vào'),
('did_please_proceed', 'th', 'กรุณาเข้ามา'),

('did_current_waiting', 'ko',
  '현재 대기'),
('did_current_waiting', 'en',
  'Now Waiting'),
('did_current_waiting', 'zh', '当前候位'),
('did_current_waiting', 'ja', '現在の待ち人数'),
('did_current_waiting', 'vi', 'Đang chờ'),
('did_current_waiting', 'th', 'รอคิว'),

('did_number_unit', 'ko', '번'),
('did_number_unit', 'en', ''),
('did_number_unit', 'zh', '号'),
('did_number_unit', 'ja', '番'),
('did_number_unit', 'vi', ''),
('did_number_unit', 'th', ''),

('did_group_unit', 'ko', '팀'),
('did_group_unit', 'en', 'group(s)'),
('did_group_unit', 'zh', '组'),
('did_group_unit', 'ja', 'グループ'),
('did_group_unit', 'vi', 'nhóm'),
('did_group_unit', 'th', 'กลุ่ม'),

('did_pickup_ready', 'ko',
  '포장 준비 완료'),
('did_pickup_ready', 'en',
  'Ready for Pickup'),
('did_pickup_ready', 'zh', '取餐准备好了'),
('did_pickup_ready', 'ja',
  'お持ち帰りのご準備ができました'),
('did_pickup_ready', 'vi',
  'Sẵn sàng lấy hàng'),
('did_pickup_ready', 'th',
  'พร้อมรับสินค้า'),

('did_call_dismissed', 'ko',
  '호출이 해제되었습니다'),
('did_call_dismissed', 'en',
  'Call dismissed')
on conflict (message_key, locale) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_did_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text,
  p_locale text default 'ko'
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
  v_did_device record;
  v_store record;
  v_store_settings record;
  v_display_state jsonb;
  v_waiting_numbers jsonb;
  v_cms_bundle jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- DID 디바이스 조회
  select id, did_code, display_mode,
         zone, call_display_seconds,
         call_repeat_count,
         show_waiting_count,
         show_cms_content,
         supported_locales,
         default_locale
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and did_code = p_did_code
    and is_active = true;

  if v_did_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'did_device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_did_app'
    );
  end if;

  -- 매장 정보
  select id, store_name, store_type
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  -- 매장 설정
  select store_mode, waiting_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 현재 DID 표시 상태
  v_display_state :=
    catchmenu_store.get_did_display_state(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_did_id := v_did_device.id,
      p_locale := coalesce(
        p_locale, v_did_device.default_locale
      )
    );

  -- 현재 대기 번호 목록
  v_waiting_numbers :=
    catchmenu_store.get_did_waiting_numbers(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := coalesce(
        p_locale, v_did_device.default_locale
      )
    );

  -- CMS 콘텐츠 (배너)
  if v_did_device.show_cms_content then
    v_cms_bundle :=
      catchmenu_store.get_cms_display_bundle(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_display_target := 'DID',
        p_locale := coalesce(
          p_locale, v_did_device.default_locale
        )
      );
  end if;

  -- DID heartbeat
  update catchmenu_store.did_devices
  set
    last_seen_at = now(),
    updated_at = now()
  where id = v_did_device.id;

  return catchmenu_common.build_success_response(
    p_message_key := 'did_app_ready',
    p_data := jsonb_build_object(

      -- DID 설정
      'did_device', jsonb_build_object(
        'id', v_did_device.id,
        'did_code', v_did_device.did_code,
        'display_mode', v_did_device.display_mode,
        'zone', v_did_device.zone,
        'call_display_seconds',
          v_did_device.call_display_seconds,
        'call_repeat_count',
          v_did_device.call_repeat_count,
        'show_waiting_count',
          v_did_device.show_waiting_count,
        'supported_locales',
          v_did_device.supported_locales,
        'default_locale',
          v_did_device.default_locale
      ),

      -- 매장
      'store', jsonb_build_object(
        'store_name', v_store.store_name,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        )
      ),

      -- 안내 메시지 (다국어)
      'display_messages', jsonb_build_object(
        'welcome',
          catchmenu_common.get_message(
            'did_welcome_msg', p_locale, null
          ),
        'now_calling',
          catchmenu_common.get_message(
            'did_now_calling', p_locale, null
          ),
        'please_proceed',
          catchmenu_common.get_message(
            'did_please_proceed', p_locale, null
          ),
        'current_waiting',
          catchmenu_common.get_message(
            'did_current_waiting', p_locale, null
          ),
        'number_unit',
          catchmenu_common.get_message(
            'did_number_unit', p_locale, null
          ),
        'group_unit',
          catchmenu_common.get_message(
            'did_group_unit', p_locale, null
          ),
        'pickup_ready',
          catchmenu_common.get_message(
            'did_pickup_ready', p_locale, null
          )
      ),

      -- 현재 표시 상태
      'display_state',
        v_display_state->'data',

      -- 대기 번호 목록
      'waiting_numbers',
        v_waiting_numbers->'data',

      -- CMS 콘텐츠
      'cms_content', v_cms_bundle->'data',

      -- Realtime 채널
      'realtime_channels', jsonb_build_array(
        'did:' || p_store_id,
        'waiting:' || p_store_id
      ),

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_display_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_active_calls jsonb;
  v_current_display jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 표시 중인 호출
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'queue_id', id,
        'queue_type', queue_type,
        'display_number', display_number,
        'display_message', display_message,
        'display_locale', display_locale,
        'queue_status', queue_status,
        'auto_dismiss_at', auto_dismiss_at,
        'max_call_count', max_call_count
      )
      order by
        case queue_type
          when 'WAITING_CALL' then 1
          when 'TABLE_READY' then 2
          when 'PICKUP_READY' then 3
          else 4
        end,
        created_at asc
    ),
    '[]'::jsonb
  )
  into v_active_calls
  from catchmenu_store.did_display_queue
  where did_device_id = p_did_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
    and auto_dismiss_at > now()
    and business_day = v_business_day;

  -- 현재 최우선 표시 항목
  if jsonb_array_length(v_active_calls) > 0 then
    v_current_display := v_active_calls->0;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'did_state_loaded',
    p_data := jsonb_build_object(
      'did_id', p_did_id,
      'has_active_call',
        jsonb_array_length(v_active_calls) > 0,
      'current_display', v_current_display,
      'active_calls', v_active_calls,
      'call_count',
        jsonb_array_length(v_active_calls),
      'business_day', v_business_day
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_waiting_numbers(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_waiting_list jsonb;
  v_total_waiting int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 대기 번호 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'guest_count', os.guest_count,
        'is_called',
          os.session_status = 'ARRIVAL_PENDING',
        'called_at', os.called_at
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
    )
  limit 20;

  v_total_waiting :=
    jsonb_array_length(v_waiting_list);

  return catchmenu_common.build_success_response(
    p_message_key := 'did_state_loaded',
    p_data := jsonb_build_object(
      'waiting_list', v_waiting_list,
      'total_waiting', v_total_waiting,
      'waiting_display',
        v_total_waiting::text
        || catchmenu_common.get_message(
          'did_group_unit', p_locale, null
        ),
      'business_day', v_business_day,
      'updated_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.dismiss_did_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_queue_id uuid,
  p_dismissed_by_type text default 'SYSTEM',
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_queue record;
begin
  select id, did_device_id, queue_type,
         display_number, order_id
  into v_queue
  from catchmenu_store.did_display_queue
  where id = p_queue_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
  for update;

  if v_queue.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'did_device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'dismiss_did_call'
    );
  end if;

  update catchmenu_store.did_display_queue
  set
    queue_status = 'DISMISSED',
    dismissed_at = now(),
    dismissed_by_type = p_dismissed_by_type,
    dismissed_by_id = p_actor_id,
    updated_at = now()
  where id = p_queue_id;

  -- Realtime 해제 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'queue_id', p_queue_id,
      'did_device_id', v_queue.did_device_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'did_call_dismissed',
    p_data := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.bootstrap_did_app(
      uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_did_display_state(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_did_waiting_numbers(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_did_app(
    uuid, uuid, text, text
  ) is
  'DID 디스플레이 앱 부트스트랩.
   Flutter DID 앱 시작 시 단일 RPC.

   반환 데이터:
   - DID 디바이스 설정
   - 매장 정보 + 영업 상태
   - 다국어 안내 메시지 (6개 로케일)
   - 현재 호출 중인 큐
   - 대기 번호 목록 (최대 20개)
   - CMS 배너 콘텐츠
   - Realtime 채널 (did + waiting)

   Flutter DID 앱 흐름:
   1. bootstrap_did_app()
   2. Realtime did:{store_id} 구독
   3. WAITING_CALL 이벤트 수신
      → 호출 번호 대형 표시
   4. call_display_seconds 후 자동 해제
   5. 대기 없을 때 CMS 배너 슬라이드

   다국어:
   대기 고객 국적 기반 자동 언어 선택
   supported_locales 순서대로 표시.';

-- ===== END sql/migrations/0117_create_did_pipeline_rpc.sql =====


-- ===== BEGIN sql/migrations/0143_add_no_payment_kds_release_policy.sql =====

-- 0143_add_no_payment_kds_release_policy.sql
-- Purpose: Store-scoped no-payment pilot release from KDS HOLD.
-- Boundary: This policy is independent from manual fallback and preserves
--           the existing payment-confirmed release path.
-- Depends on: 0049_create_store_settings_rpc.sql,
--             0053_create_staff_management_rpc.sql

alter table catchmenu_store.store_settings
  add column if not exists payment_required_for_kds_release boolean
  not null default true;

comment on column
  catchmenu_store.store_settings.payment_required_for_kds_release is
  'Store-scoped KDS payment policy. TRUE preserves the normal payment-required '
  'release path. FALSE enables the explicitly authorized NO_PAYMENT_PILOT RPC. '
  'This setting is unrelated to manual_fallback_activated.';

create or replace function catchmenu_kds.release_kds_ticket_no_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ticket_id uuid,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = pg_catalog
as $$
declare
  v_ticket record;
  v_staff record;
  v_capacity jsonb;
  v_conditions jsonb;
  v_remaining_conditions_met boolean;
  v_audit_id uuid;
begin
  if p_tenant_id is null
     or p_store_id is null
     or p_order_id is null
     or p_ticket_id is null
     or p_actor_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_scope_required'
    );
  end if;

  if catchmenu_common.current_tenant_id() is distinct from p_tenant_id
     or catchmenu_common.current_store_id() is distinct from p_store_id
     or catchmenu_common.current_actor_id() is distinct from p_actor_id then
    return jsonb_build_object(
      'success', false,
      'error_key', 'release_context_mismatch'
    );
  end if;

  select
    s.id,
    s.staff_role,
    s.authority_level,
    s.can_override_kds
  into v_staff
  from catchmenu_store.staff s
  where s.id = p_actor_id
    and s.tenant_id = p_tenant_id
    and s.store_id = p_store_id
    and s.staff_status = 'ACTIVE'
    and s.is_active = true;

  if v_staff.id is null or not coalesce(v_staff.can_override_kds, false) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'unauthorized_release'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_store.store_settings ss
    where ss.tenant_id = p_tenant_id
      and ss.store_id = p_store_id
      and ss.payment_required_for_kds_release = false
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'no_payment_policy_not_active'
    );
  end if;

  select
    kt.id,
    kt.tenant_id,
    kt.store_id,
    kt.order_id,
    kt.session_id,
    kt.kds_status,
    kt.conditions_met,
    kt.kitchen_zone,
    kt.business_day,
    kt.business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets kt
  where kt.id = p_ticket_id
    and kt.tenant_id = p_tenant_id
    and kt.store_id = p_store_id
    and kt.order_id = p_order_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_scope_mismatch'
    );
  end if;

  if v_ticket.kds_status = 'COMMITTED'
     and coalesce(
       (v_ticket.conditions_met->>'no_payment_policy_released')::boolean,
       false
     ) then
    return jsonb_build_object(
      'success', true,
      'already_released', true,
      'ticket_id', p_ticket_id,
      'kds_status', v_ticket.kds_status,
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'message_code', 'kds_no_payment_policy_already_released'
    );
  end if;

  if v_ticket.kds_status <> 'HOLD' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_holdable',
      'current_status', v_ticket.kds_status
    );
  end if;

  v_capacity := catchmenu_kds.evaluate_kds_capacity(
    p_tenant_id,
    p_store_id,
    v_ticket.kitchen_zone
  );

  v_conditions := coalesce(v_ticket.conditions_met, '{}'::jsonb)
    || jsonb_build_object(
      'kds_capacity_ok',
      coalesce((v_capacity->>'capacity_ok')::boolean, false)
    );

  v_remaining_conditions_met := (
    coalesce((v_conditions->>'arrived')::boolean, false)
    and coalesce((v_conditions->>'table_confirmed')::boolean, false)
    and coalesce((v_conditions->>'kds_capacity_ok')::boolean, false)
    and coalesce((v_conditions->>'menu_available')::boolean, true)
    and coalesce((v_conditions->>'peak_time_ok')::boolean, true)
    and coalesce((v_conditions->>'no_show_risk_ok')::boolean, true)
  );

  if not v_remaining_conditions_met then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_conditions_not_met',
      'ticket_id', p_ticket_id,
      'conditions_met', v_conditions
    );
  end if;

  v_conditions := v_conditions || jsonb_build_object(
    'no_payment_policy_released', true,
    'no_payment_policy_release_source', 'STORE_NO_PAYMENT_POLICY',
    'no_payment_policy_authorized_by', p_actor_id
  );

  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COMMITTED',
    conditions_met = v_conditions,
    committed_at = now(),
    capacity_check_at = now(),
    kds_queue_length_at_check =
      (v_capacity->>'cooking_count')::int,
    updated_at = now()
  where id = p_ticket_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
    and kds_status = 'HOLD';

  if not found then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_release_conflict'
    );
  end if;

  insert into catchmenu_kds.kds_events (
    tenant_id,
    store_id,
    ticket_id,
    order_id,
    event_type,
    from_status,
    to_status,
    caused_by_type,
    caused_by_id,
    conditions_at_event,
    event_payload,
    correlation_id,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    p_ticket_id,
    p_order_id,
    'all_conditions_met',
    'HOLD',
    'COMMITTED',
    'STAFF',
    p_actor_id,
    v_conditions,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false),
      'staff_role', v_staff.staff_role,
      'authority_level', v_staff.authority_level
    ),
    p_correlation_id,
    now()
  );

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
    caused_by_id,
    event_payload,
    session_id,
    order_id,
    kds_ticket_id,
    correlation_id,
    business_day,
    business_timezone,
    occurred_at
  ) values (
    p_tenant_id,
    p_store_id,
    'kds',
    'kds_no_payment_policy_released',
    1,
    'kds_ticket',
    p_ticket_id,
    'HOLD',
    'COMMITTED',
    'STAFF',
    p_actor_id,
    jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'payment_confirmed',
        coalesce((v_conditions->>'payment_confirmed')::boolean, false)
    ),
    v_ticket.session_id,
    p_order_id,
    p_ticket_id,
    p_correlation_id,
    v_ticket.business_day,
    v_ticket.business_timezone,
    now()
  );

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_no_payment_policy_released',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'APPROVED',
    p_decision_reason := 'STORE_NO_PAYMENT_POLICY',
    p_decision_payload := jsonb_build_object(
      'release_source', 'STORE_NO_PAYMENT_POLICY',
      'release_reason', 'NO_PAYMENT_PILOT',
      'payment_required_for_kds_release', false,
      'authorizing_actor_id', p_actor_id
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'HOLD',
      'conditions_met', v_ticket.conditions_met
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COMMITTED',
      'conditions_met', v_conditions
    ),
    p_session_id := v_ticket.session_id,
    p_order_id := p_order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'already_released', false,
    'ticket_id', p_ticket_id,
    'order_id', p_order_id,
    'kds_status', 'COMMITTED',
    'release_source', 'STORE_NO_PAYMENT_POLICY',
    'authorized_by', p_actor_id,
    'audit_id', v_audit_id,
    'message_code', 'kds_no_payment_policy_released'
  );
end;
$$;

revoke all on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) from public;

grant execute on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) to authenticated;

comment on function catchmenu_kds.release_kds_ticket_no_payment(
  uuid, uuid, uuid, uuid, uuid, text
) is
  'Releases one HOLD ticket to COMMITTED only when the exact tenant/store '
  'has payment_required_for_kds_release = FALSE and the authenticated active '
  'staff actor has can_override_kds. The RPC preserves payment_confirmed and '
  'does not read or use manual_fallback_activated.';


-- ===== END sql/migrations/0143_add_no_payment_kds_release_policy.sql =====


-- ===== BEGIN sql/migrations/0151_create_check_kds_capacity_function.sql =====

-- 0151_create_check_kds_capacity_function.sql
-- Purpose: Create catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id).
--
-- Background:
--   The live KDS/payment/realtime pipeline references
--   catchmenu_kds.check_kds_capacity(...) from multiple later RPCs, including
--   release_kds_after_payment(), get_kds_realtime_state(), and delivery
--   platform flow code, but the function itself was not defined in prior
--   migrations. This caused runtime failures before those callers could reach
--   their next validation step.
--
-- Design authority:
--   docs/600000_implementation_lifecycle/600400_kds_did_implementation/
--     600410_kds_capacity_gate_and_status_reconciliation/
--       600411_Overview.md
--       600412_Logic.md
--       600413_TestPlan.md
--       600414_ChangeContract.md
--
-- Creates:
--   - catchmenu_kds.check_kds_capacity(p_tenant_id uuid, p_store_id uuid)
--
-- Notes:
--   - Reuses catchmenu_kds.evaluate_kds_capacity(...) for real kitchen zones.
--   - Builds the zone list from distinct kitchen_zone values already present
--     in catchmenu_kds.kds_tickets for the tenant/store. No business_day filter
--     is applied here.
--   - NULL kitchen_zone tickets are reported as a virtual UNASSIGNED group, but
--     UNASSIGNED is not passed to evaluate_kds_capacity(). NULL comparisons
--     would otherwise count zero rows. The wrapper counts NULL-zone tickets
--     directly, using the same threshold value (8) as evaluate_kds_capacity().
--   - Returns the nested shape expected by existing callers:
--       { "data": { "is_overloaded": boolean, "zones": [...] } }

create or replace function catchmenu_kds.check_kds_capacity(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds, catchmenu_common
as $$
declare
  v_zone text;
  v_zone_result jsonb;
  v_zone_results jsonb := '[]'::jsonb;
  v_all_ok boolean := true;
  v_zones text[];
  v_unassigned_cooking int := 0;
  v_unassigned_hold int := 0;
  v_unassigned_ready int := 0;
  v_unassigned_ok boolean := true;
  v_threshold int := 8;
begin
  select array_agg(
    distinct coalesce(kitchen_zone, 'UNASSIGNED')
    order by coalesce(kitchen_zone, 'UNASSIGNED')
  )
  into v_zones
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_zones is null then
    v_zones := array[]::text[];
  end if;

  foreach v_zone in array v_zones loop
    if v_zone = 'UNASSIGNED' then
      select
        count(*) filter (
          where kds_status in ('COOKING', 'COMMITTED')
        ),
        count(*) filter (
          where kds_status in ('HOLD', 'CAPACITY_CHECKING')
        ),
        count(*) filter (
          where kds_status = 'READY'
        )
      into
        v_unassigned_cooking,
        v_unassigned_hold,
        v_unassigned_ready
      from catchmenu_kds.kds_tickets
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED')
        and kitchen_zone is null;

      v_unassigned_ok := v_unassigned_cooking < v_threshold;
      v_zone_result := jsonb_build_object(
        'cooking_count', v_unassigned_cooking,
        'hold_count', v_unassigned_hold,
        'ready_count', v_unassigned_ready,
        'capacity_ok', v_unassigned_ok,
        'threshold', v_threshold,
        'kitchen_zone', 'UNASSIGNED'
      );
    else
      v_zone_result := catchmenu_kds.evaluate_kds_capacity(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_kitchen_zone := v_zone
      );
    end if;

    v_zone_results := v_zone_results || jsonb_build_array(v_zone_result);
    if not coalesce((v_zone_result->>'capacity_ok')::boolean, false) then
      v_all_ok := false;
    end if;
  end loop;

  return jsonb_build_object(
    'data', jsonb_build_object(
      'is_overloaded', not v_all_ok,
      'zones', v_zone_results
    )
  );
end;
$$;

comment on function catchmenu_kds.check_kds_capacity(uuid, uuid) is
  'Aggregates per-zone KDS capacity results into the {data:{is_overloaded,zones}} shape expected by payment, realtime, and delivery RPC callers. Created by migration 0151.';


-- ===== END sql/migrations/0151_create_check_kds_capacity_function.sql =====


-- ===== BEGIN sql/migrations/0155_drop_get_did_display_state_legacy_overload.sql =====

-- Migration: 0155_drop_get_did_display_state_legacy_overload.sql
-- Purpose:
--   Drop the legacy 3-param catchmenu_store.get_did_display_state(uuid, uuid, uuid)
--   overload and leave the 0117 4-param p_did_id/p_locale implementation as the
--   single canonical DID display state function.
--
-- Background:
--   The legacy 0043 overload has three independent defects/evidence points:
--   1. Its body contains a nested aggregate pattern that fails at runtime
--      ("aggregate function calls cannot be nested").
--   2. Its p_device_id parameter is not used by the function body.
--   3. Repository/live-call inspection found no actual caller for the 3-param
--      overload, while bootstrap_did_app() calls the 0117 4-param overload by
--      named arguments (p_did_id, p_locale).
--
-- Human decision:
--   2026-07-14 Option A approved for 600820_did_display_state_overload_and_legacy_defect:
--   drop only the legacy 0043 3-param overload and keep 0117 canonical.
--
-- Depends on:
--   0154_drop_mark_payment_uncertain_legacy_overload.sql
--
-- Creates/Changes:
--   Removes catchmenu_store.get_did_display_state(uuid, uuid, uuid).
--
-- Scope exclusions:
--   Does not edit 0043_create_did_display_rpc.sql.
--   Does not edit 0117_create_did_pipeline_rpc.sql.
--   Does not modify bootstrap_did_app().
--   Does not repair the old 0043 nested aggregate body.
--   Does not touch mark_payment_uncertain(), authorize_kds_release(), or mark_no_show().

drop function if exists catchmenu_store.get_did_display_state(
  uuid, uuid, uuid
);


-- ===== END sql/migrations/0155_drop_get_did_display_state_legacy_overload.sql =====


-- ===== BEGIN sql/migrations/0156_add_did_device_edid_mapping.sql =====

-- Migration: 0156_add_did_device_edid_mapping.sql
-- Purpose:
--   Add EDID-based physical display identity fields to catchmenu_store.did_devices
--   and create the Stage-A registry RPCs needed by the CMS/DID device routing
--   architecture.
--
-- Background:
--   601010_cms_device_content_routing_architecture confirmed that physical DID
--   and signage devices should be identified by EDID rather than by fixed port
--   number. The chosen Option 3 keeps the existing device_registry and
--   update_did_display() behavior untouched, while adding a new lightweight
--   lookup/reporting layer on top of did_devices.
--
-- Human decision:
--   2026-07-15 Human Boundary Approval approved:
--   - four nullable did_devices columns;
--   - get_did_device_by_edid();
--   - report_did_device_edid_scan();
--   - no changes to 0043_create_did_display_rpc.sql.
--
-- Depends on:
--   0155_drop_get_did_display_state_legacy_overload.sql
--
-- Non-goals:
--   Does not modify 0043_create_did_display_rpc.sql.
--   Does not modify catchmenu_store.device_registry.
--   Does not implement the CMS content delivery engine.
--   Does not decide the final EDID normalization format.
--   Does not implement mismatch notification or mismatch history tracking.

alter table catchmenu_store.did_devices
  add column if not exists edid_serial text,
  add column if not exists last_detected_edid text,
  add column if not exists last_edid_check_at timestamptz,
  add column if not exists physical_position_label text;

create or replace function catchmenu_store.get_did_device_by_edid(
  p_tenant_id uuid,
  p_store_id uuid,
  p_edid_serial text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_device record;
begin
  select
    id,
    did_code,
    did_name,
    device_id,
    display_mode,
    zone,
    orientation,
    resolution,
    edid_serial,
    last_detected_edid,
    last_edid_check_at,
    physical_position_label
  into v_device
  from catchmenu_store.did_devices
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and edid_serial = p_edid_serial
    and is_active = true
  order by updated_at desc, created_at desc
  limit 1;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'edid_not_registered',
      'data', jsonb_build_object(
        'edid_serial', p_edid_serial
      ),
      'meta', jsonb_build_object(
        'locale', p_locale,
        'occurred_at', now()
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'device_id', v_device.id,
      'registry_device_id', v_device.device_id,
      'did_code', v_device.did_code,
      'did_name', v_device.did_name,
      'display_mode', v_device.display_mode,
      'zone', v_device.zone,
      'orientation', v_device.orientation,
      'resolution', v_device.resolution,
      'edid_serial', v_device.edid_serial,
      'last_detected_edid', v_device.last_detected_edid,
      'last_edid_check_at', v_device.last_edid_check_at,
      'physical_position_label', v_device.physical_position_label
    ),
    'meta', jsonb_build_object(
      'locale', p_locale,
      'occurred_at', now()
    )
  );
end;
$$;

create or replace function catchmenu_store.report_did_device_edid_scan(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_detected_edid text,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store, catchmenu_common
as $$
declare
  v_device record;
  v_is_mismatch boolean;
begin
  select
    id,
    did_code,
    did_name,
    edid_serial
  into v_device
  from catchmenu_store.did_devices
  where id = p_device_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and is_active = true
  for update;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'did_device_not_found',
      'data', jsonb_build_object(
        'device_id', p_device_id,
        'detected_edid', p_detected_edid
      ),
      'meta', jsonb_build_object(
        'correlation_id', p_correlation_id,
        'occurred_at', now()
      )
    );
  end if;

  update catchmenu_store.did_devices
  set
    last_detected_edid = p_detected_edid,
    last_edid_check_at = now(),
    updated_at = now()
  where id = v_device.id;

  v_is_mismatch := v_device.edid_serial is distinct from p_detected_edid;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'device_id', v_device.id,
      'did_code', v_device.did_code,
      'did_name', v_device.did_name,
      'edid_serial', v_device.edid_serial,
      'last_detected_edid', p_detected_edid,
      'last_edid_check_at', now(),
      'is_mismatch', v_is_mismatch
    ),
    'meta', jsonb_build_object(
      'correlation_id', p_correlation_id,
      'occurred_at', now()
    )
  );
end;
$$;

do $$
begin
  grant execute on function
    catchmenu_store.get_did_device_by_edid(
      uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.report_did_device_edid_scan(
      uuid, uuid, uuid, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_store.get_did_device_by_edid(
  uuid, uuid, text, text
) is
  'Looks up an active DID/signage device by normalized EDID serial within tenant/store scope.';

comment on function catchmenu_store.report_did_device_edid_scan(
  uuid, uuid, uuid, text, text
) is
  'Records the latest detected EDID for a DID/signage device and returns whether it differs from the registered EDID.';


-- ===== END sql/migrations/0156_add_did_device_edid_mapping.sql =====


-- ===== BEGIN sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql =====

-- 0157_authorize_kds_release_overload_and_redesign.sql
-- Purpose:
--   Restore the payment-ledger KDS release authorization contract for the
--   normal confirm_payment() path, make start_cooking() fail closed when a
--   committed ticket has no linked payment ledger, and remove the legacy
--   authorize_kds_release() overloads.
--
-- Background:
--   Defect 1: release_kds_after_payment() committed KDS tickets but only wrote
--             kds_release_authorized into kds_tickets.conditions_met JSON; it
--             did not set payment_ledger.kds_release_authorized.
--   Defect 2: bulk_commit_kds_tickets() already gates on the payment_ledger
--             column. It should remain unchanged and pass naturally once
--             Defect 1 is fixed.
--   Defect 3: start_cooking() was fail-open when payment_ledger_id was null.
--             It must fail closed with kds_release_ledger_missing.
--
-- Human decision:
--   601024_ChangeContract.md approved Slice 1, Slice 2, and Slice 3
--   on 2026-07-15.
--
-- Depends on:
--   0156_add_did_device_edid_mapping.sql
--   0098_create_payment_confirm_pipeline_rpc.sql
--   0029_create_kds_cooking_rpc.sql
--   0028_create_kds_capacity_commit_rpc.sql
--   0063_patch_core_rpc_i18n_diagnostics.sql
--
-- Non-goals:
--   Does not modify confirm_payment() body.
--   Does not modify bulk_commit_kds_tickets().
--   Does not modify confirm_payment_from_provider(), Toss webhook, or VAN
--   paths (0027/0038/0056).
--   Does not modify release_kds_ticket_no_payment() (0143).
--   Does not design cash payment, retry, reconciliation, or PG/VAN audit flow.

create or replace function
  catchmenu_payment.release_kds_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_released_count int := 0;
  v_ticket_ids jsonb := '[]'::jsonb;
  v_capacity_check jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- Recheck KDS capacity at the payment-complete late-binding point.
  v_capacity_check :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- Slice 1: create the table-level KDS release authorization before
  -- committing KDS tickets. This aligns the payment_ledger column with the
  -- existing kds_tickets.conditions_met JSON evidence.
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = 'SYSTEM'
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- HOLD tickets -> COMMITTED.
  -- conditions_met JSON evidence:
  --   payment_confirmed = true
  --   kds_release_authorized = true
  with released as (
    update catchmenu_kds.kds_tickets
    set
      kds_status = 'COMMITTED',
      conditions_met = jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'payment_ledger_id', p_ledger_id,
        'released_at', now()
      ),
      committed_at = now(),
      updated_at = now()
    where order_id = p_order_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'HOLD'
    returning id
  )
  select
    count(*),
    coalesce(
      jsonb_agg(to_jsonb(id)), '[]'::jsonb
    )
  into v_released_count, v_ticket_ids
  from released;

  if v_released_count = 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'WARNING',
      p_log_domain := 'KDS',
      p_log_event := 'kds_no_hold_tickets',
      p_message :=
        'KDS HOLD tickets not found for order_id='
        || p_order_id,
      p_rpc_name := 'release_kds_after_payment',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'order_id', p_order_id,
        'ledger_id', p_ledger_id
      )
    );
  end if;

  -- KDS realtime broadcast.
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_tickets_released',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'ledger_id', p_ledger_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'capacity', v_capacity_check->'data',
      'released_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_released',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'released_count', v_released_count,
      'ticket_ids', v_ticket_ids,
      'kds_status', 'COMMITTED',
      'capacity_after',
        v_capacity_check->'data',
      'late_binding_principle',
        'HOLD -> COMMITTED after payment only'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

create or replace function catchmenu_kds.start_cooking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ticket_id uuid,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_device_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  select
    id, order_id, session_id, order_item_id, kds_status,
    kitchen_zone, ticket_number,
    menu_name_snapshot, quantity_snapshot,
    estimated_minutes_snapshot,
    payment_ledger_id,
    conditions_met,
    business_day, business_timezone
  into v_ticket
  from catchmenu_kds.kds_tickets
  where id = p_ticket_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_ticket.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_found'
    );
  end if;

  if v_ticket.kds_status <> 'COMMITTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ticket_not_ready_to_commit',
      'current_status', v_ticket.kds_status
    );
  end if;

  -- Slice 2: fail closed when the ticket has no linked payment ledger.
  if v_ticket.payment_ledger_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_ledger_missing',
      'message', 'payment_ledger_id is null; ticket has no linked payment record'
    );
  end if;

  if not exists (
    select 1
    from catchmenu_payment.payment_ledger
    where id = v_ticket.payment_ledger_id
      and kds_release_authorized = true
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kds_release_not_authorized',
      'message', 'payment_ledger.kds_release_authorized must be true'
    );
  end if;

  -- COMMITTED -> COOKING
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'COOKING',
    cooking_started_at = now(),
    updated_at = now()
  where id = p_ticket_id;

  -- update order item status
  update catchmenu_pos.order_items
  set
    item_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_item_id;

  -- KDS event
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    caused_by_device_id,
    conditions_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_ticket_id, v_ticket.order_id,
    'cooking_started',
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    v_ticket.conditions_met,
    jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'menu_name', v_ticket.menu_name_snapshot,
      'estimated_minutes', v_ticket.estimated_minutes_snapshot
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
    caused_by_device_id,
    event_payload,
    order_id, kds_ticket_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'kds', 'kds_cooking_started', 1,
    'kds_ticket', p_ticket_id,
    'COMMITTED', 'COOKING',
    p_actor_type, p_actor_id,
    p_device_id,
    jsonb_build_object(
      'kitchen_zone', v_ticket.kitchen_zone,
      'ticket_number', v_ticket.ticket_number
    ),
    v_ticket.order_id, p_ticket_id,
    p_correlation_id,
    v_ticket.business_day, v_ticket.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'kds',
    p_audit_type := 'kds_cooking_started',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket',
    p_subject_id := p_ticket_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'ticket_number', v_ticket.ticket_number,
      'kitchen_zone', v_ticket.kitchen_zone,
      'cooking_started_at', now()
    ),
    p_before_state := jsonb_build_object(
      'kds_status', 'COMMITTED'
    ),
    p_after_state := jsonb_build_object(
      'kds_status', 'COOKING'
    ),
    p_order_id := v_ticket.order_id,
    p_kds_ticket_id := p_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day,
    p_business_timezone := v_ticket.business_timezone
  );

  -- update order status to COOKING if not already
  update catchmenu_pos.orders
  set
    order_status = 'COOKING',
    updated_at = now()
  where id = v_ticket.order_id
    and order_status = 'CONFIRMED';

  return jsonb_build_object(
    'success', true,
    'ticket_id', p_ticket_id,
    'ticket_number', v_ticket.ticket_number,
    'kds_status', 'COOKING',
    'kitchen_zone', v_ticket.kitchen_zone,
    'cooking_started_at', now(),
    'estimated_minutes', v_ticket.estimated_minutes_snapshot,
    'audit_id', v_audit_id
  );
end;
$$;

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text
);

drop function if exists catchmenu_kds.authorize_kds_release(
  uuid, uuid, uuid, text, uuid, text, text, text
);


-- ===== END sql/migrations/0157_authorize_kds_release_overload_and_redesign.sql =====


-- ===== BEGIN sql/migrations/0166_canonical_kds_release_orchestration.sql =====

-- Migration: 0166_canonical_kds_release_orchestration.sql
-- Purpose: Canonical KDS release orchestration after provider payment confirmation.
-- Depends on: 0165_menu_price_list_architecture_phase0.sql
-- Creates: catchmenu_payment.request_kds_release_after_payment()
-- Changes: catchmenu_payment.confirm_payment_from_provider() response/KDS release orchestration only.
-- Non-goals: confirm_payment()(0098), resolve_payment_uncertain(), bulk_commit_kds_tickets(),
--            commit_kds_ticket(), evaluate_kds_capacity(), webhook idempotency.

create or replace function catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_bulk_result jsonb;
  v_result_code text;
  v_audit_id uuid;
begin
  -- Step 1: authorize the payment ledger row for KDS release.
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- Step 2: delegate the actual ticket gate to the existing KDS bulk commit function.
  v_bulk_result := catchmenu_kds.bulk_commit_kds_tickets(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_force_conditions := null,
    p_correlation_id := p_correlation_id
  );

  -- Step 3: translate the bulk-commit result.
  -- Order matters: zero-ticket 0/0/0 must be classified before COMMITTED.
  v_result_code := case
    when not coalesce((v_bulk_result->>'success')::boolean, false)
      then 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'
    when coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_COMMITTED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) > 0
      then 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'
    else 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'
  end;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_requested',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := case
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED' then 'APPROVED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED' then 'FAILED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS' then 'NOTED'
      else 'SUSPENDED'
    end,
    p_decision_payload := jsonb_build_object(
      'result_code', v_result_code,
      'bulk_commit_result', v_bulk_result
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id
  );

  return jsonb_build_object(
    'success', true,
    'result_code', v_result_code,
    'ledger_id', p_ledger_id,
    'order_id', p_order_id,
    'committed_count', v_bulk_result->'committed_count',
    'pending_count', v_bulk_result->'pending_count',
    'skipped_count', v_bulk_result->'skipped_count',
    'bulk_commit_detail', v_bulk_result,
    'audit_id', v_audit_id
  );
exception
  when others then
    begin
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'payment',
        p_audit_type := 'kds_release_requested_failed',
        p_audit_category := 'OPERATIONAL',
        p_actor_type := p_actor_type,
        p_actor_id := null,
        p_subject_type := 'payment_ledger',
        p_subject_id := p_ledger_id,
        p_decision := 'FAILED',
        p_decision_payload := jsonb_build_object(
          'error', sqlerrm,
          'sqlstate', sqlstate
        ),
        p_order_id := p_order_id,
        p_correlation_id := p_correlation_id
      );
    exception
      when others then
        raise warning 'request_kds_release_after_payment(): audit logging of the original failure itself failed (sqlstate=%) -- server log only, no DB trace beyond this warning', sqlstate;
    end;

    return jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', p_ledger_id,
      'order_id', p_order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;

revoke all on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) to authenticated;

create or replace function catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_provider_payment_key text,
  p_provider_approval_number text,
  p_approved_amount int,
  p_provider_raw_event_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_kds, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_intent record;
  v_ledger_id uuid;
  v_audit_id uuid;
  v_kds_release_result jsonb;
  v_kds_updated int;
begin
  -- intent validation
  select id, order_id, session_id, provider_type,
         requested_amount, payment_method, payment_channel,
         business_day, business_timezone, provider_order_id
  into v_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'intent_not_found'
    );
  end if;

  if v_intent.requested_amount <> p_approved_amount then
    -- amount mismatch — create reconciliation case (handled separately)
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'requested_amount', v_intent.requested_amount,
      'approved_amount', p_approved_amount
    );
  end if;

  -- update intent status
  update catchmenu_payment.payment_intents
  set
    intent_status = 'CONFIRMED',
    confirmed_at = now(),
    updated_at = now()
  where id = p_intent_id;

  -- create payment ledger entry (internal source of truth)
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id, intent_id,
    ledger_entry_type, ledger_status,
    approved_amount, net_amount,
    provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at,
    provider_response_id,
    reconciliation_status,
    -- 특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용
    -- kds_release_authorized starts FALSE
    kds_release_authorized,
    business_day, business_timezone,
    approved_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, v_intent.session_id, p_intent_id,
    'APPROVAL', 'APPROVED',
    p_approved_amount, p_approved_amount,
    v_intent.provider_type, p_provider_payment_key,
    p_provider_approval_number, now(),
    p_provider_raw_event_id,
    'PENDING',
    false,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  returning id into v_ledger_id;

  -- update session payment status
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_PENDING',
    payment_completed_at = now(),
    updated_at = now()
  where id = v_intent.session_id;

  -- update KDS tickets: set payment_confirmed = true in conditions_met
  -- but kds_status stays HOLD until capacity check
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met || jsonb_build_object(
      'payment_confirmed', true
    ),
    payment_ledger_id = v_ledger_id,
    updated_at = now()
  where order_id = v_intent.order_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_kds_updated = row_count;

  -- KDS events for condition update
  insert into catchmenu_kds.kds_events (
    tenant_id, store_id, ticket_id, order_id,
    event_type, caused_by_type,
    conditions_at_event, event_payload, occurred_at
  )
  select
    p_tenant_id, p_store_id, kt.id, v_intent.order_id,
    'payment_confirmed_released',
    'SYSTEM',
    kt.conditions_met,
    jsonb_build_object(
      'payment_ledger_id', v_ledger_id,
      'approved_amount', p_approved_amount
    ),
    now()
  from catchmenu_kds.kds_tickets kt
  where kt.order_id = v_intent.order_id
    and kt.kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    intent_id, ledger_id,
    event_type, from_status, to_status,
    caused_by_type, amount_at_event,
    provider_event_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_intent.order_id,
    p_intent_id, v_ledger_id,
    'payment_approved', 'PROCESSING', 'APPROVED',
    'PROVIDER', p_approved_amount,
    p_provider_payment_key,
    jsonb_build_object(
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_tickets_updated', v_kds_updated,
      'kds_release_authorized', false,
      'kds_release_pending_capacity_check', true
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
    session_id, order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_approved', 1,
    'payment_ledger', v_ledger_id,
    'PROCESSING', 'APPROVED',
    'PROVIDER',
    jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'kds_release_authorized', false,
      'reconciliation_required', true
    ),
    v_intent.session_id, v_intent.order_id, v_ledger_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_approved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number', p_provider_approval_number,
      'kds_release_authorized', false,
      'reconciliation_status', 'PENDING'
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'APPROVED',
      'kds_release_authorized', false
    ),
    p_payment_id := v_ledger_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  -- KDS release orchestration (Option C): only the release call is wrapped.
  -- Payment-core work above (intent validation, ledger insert, ticket/event updates,
  -- and this function's own audit record) remains outside this nested exception block.
  begin
    v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := v_intent.order_id,
      p_ledger_id := v_ledger_id,
      p_actor_type := 'PROVIDER',
      p_correlation_id := p_correlation_id
    );
  exception
    when others then
      begin
        perform catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_audit_domain := 'payment',
          p_audit_type := 'kds_release_call_unexpected_exception',
          p_audit_category := 'FINANCIAL',
          p_actor_type := 'PROVIDER',
          p_actor_id := null,
          p_subject_type := 'payment_ledger',
          p_subject_id := v_ledger_id,
          p_decision := 'FAILED',
          p_decision_payload := jsonb_build_object(
            'error', sqlerrm,
            'sqlstate', sqlstate
          ),
          p_order_id := v_intent.order_id,
          p_correlation_id := p_correlation_id
        );
      exception
        when others then
          raise warning 'confirm_payment_from_provider(): audit logging of the KDS-release-call failure itself failed (sqlstate=%) -- payment_ledger row % still committed; server log only for the original KDS failure', sqlstate, v_ledger_id;
      end;

      v_kds_release_result := jsonb_build_object(
        'success', true,
        'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
        'ledger_id', v_ledger_id,
        'order_id', v_intent.order_id,
        'error_detail', jsonb_build_object('sqlstate', sqlstate)
      );
  end;

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'intent_id', p_intent_id,
    'ledger_status', 'APPROVED',
    'approved_amount', p_approved_amount,
    'kds_release_authorized',
      (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
    'kds_tickets_payment_confirmed', v_kds_updated,
    'kds_release_result', v_kds_release_result,
    'result_code', v_kds_release_result->>'result_code',
    'reconciliation_status', 'PENDING',
    'message_code', case
      when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
        then 'payment_approved_kds_released'
      else 'payment_approved_kds_pending'
    end,
    'audit_id', v_audit_id
  );
end;
$$;


-- ===== END sql/migrations/0166_canonical_kds_release_orchestration.sql =====
