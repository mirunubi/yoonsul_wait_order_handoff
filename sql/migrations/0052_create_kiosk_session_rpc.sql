-- 0052_create_kiosk_session_rpc.sql
-- Purpose: Kiosk-specific session and order RPCs.
--          create_kiosk_session: initializes kiosk order session.
--          submit_kiosk_order: submits order from kiosk with payment.
--          get_kiosk_state: returns kiosk operational state.
--          특허1 core: Kiosk 주문 세션 — 테이블 없는 흐름 처리.
-- Depends on: 0051_create_pre_order_rpc.sql
-- Creates:
--   function catchmenu_pos.create_kiosk_session(...)
--   function catchmenu_pos.submit_kiosk_order(...)
--   function catchmenu_pos.get_kiosk_state(...)

create or replace function catchmenu_pos.create_kiosk_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_device_id uuid,
  p_order_type text default 'DINE_IN',
  p_guest_count int default 1,
  p_guest_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_ledger, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_session_id uuid;
  v_business_day date;
  v_timezone text;
  v_device record;
begin
  -- validate kiosk device
  select id, device_code, trust_level, device_status
  into v_device
  from catchmenu_store.device_registry
  where id = p_kiosk_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and device_type = 'KIOSK'
    and is_active = true;

  if v_device.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kiosk_device_not_found'
    );
  end if;

  if v_device.trust_level <> 'TRUSTED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kiosk_not_trusted',
      'trust_level', v_device.trust_level
    );
  end if;

  if v_device.device_status <> 'ONLINE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'kiosk_not_online',
      'device_status', v_device.device_status
    );
  end if;

  if p_order_type not in (
    'DINE_IN', 'TAKEOUT'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_order_type'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- create kiosk session
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    session_started_at,
    ordering_started_at,
    expires_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'KIOSK', 'ORDERING',
    p_guest_count,
    coalesce(p_guest_locale, 'ko'),
    now(), now(),
    now() + interval '15 minutes',
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_device_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_session_id,
    'session_created', null, 'ORDERING',
    'KIOSK', p_kiosk_device_id,
    jsonb_build_object(
      'order_type', p_order_type,
      'guest_count', p_guest_count,
      'kiosk_device_id', p_kiosk_device_id,
      'device_code', v_device.device_code
    ),
    p_correlation_id, now()
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_device_id,
    event_payload, session_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'kiosk_session_created', 1,
    'order_session', v_session_id,
    null, 'ORDERING',
    'KIOSK', p_kiosk_device_id,
    jsonb_build_object(
      'order_type', p_order_type,
      'guest_count', p_guest_count,
      'kiosk_device_code', v_device.device_code
    ),
    v_session_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'session_id', v_session_id,
    'session_type', 'KIOSK',
    'session_status', 'ORDERING',
    'order_type', p_order_type,
    'guest_count', p_guest_count,
    'guest_locale', p_guest_locale,
    'expires_at', now() + interval '15 minutes',
    'kiosk_device_code', v_device.device_code,
    'message_code', 'kiosk_session_created'
  );
end;
$$;


create or replace function catchmenu_pos.submit_kiosk_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_kiosk_device_id uuid,
  p_order_type text,
  p_items jsonb,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_memo text default null,
  p_table_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds,
                  catchmenu_payment, catchmenu_ledger,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_session record;
  v_create_result jsonb;
  v_confirm_result jsonb;
  v_intent_result jsonb;
  v_idempotency_key text;
  v_order_id uuid;
begin
  -- session validation
  select id, session_status, session_type,
         business_day, business_timezone
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

  if v_session.session_status <> 'ORDERING' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'session_not_ordering',
      'current_status', v_session.session_status
    );
  end if;

  -- WALK_IN Late Binding for DINE_IN
  if p_order_type = 'DINE_IN'
    and p_table_id is not null
  then
    perform catchmenu_pos.bind_table_to_session(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_session_id := p_session_id,
      p_table_id := p_table_id,
      p_actor_type := 'KIOSK',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- step 1: create order
  v_create_result := catchmenu_pos.create_order(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_order_type := p_order_type,
    p_order_channel := 'KIOSK',
    p_items := p_items,
    p_memo := p_memo,
    p_correlation_id := p_correlation_id
  );

  if not (v_create_result->>'success')::boolean then
    return v_create_result;
  end if;

  v_order_id := (v_create_result->>'order_id')::uuid;

  -- step 2: confirm order (creates KDS tickets in HOLD)
  v_confirm_result := catchmenu_pos.confirm_order(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_actor_type := 'KIOSK',
    p_correlation_id := p_correlation_id
  );

  if not (v_confirm_result->>'success')::boolean then
    return v_confirm_result;
  end if;

  -- step 3: create payment intent
  v_idempotency_key := 'KIOSK:' || p_session_id::text
    || ':' || now()::text;

  v_intent_result := catchmenu_payment.create_payment_intent(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_order_id,
    p_session_id := p_session_id,
    p_payment_method := p_payment_method,
    p_payment_channel := p_payment_channel,
    p_provider_type := p_provider_type,
    p_requested_amount :=
      (v_create_result->>'final_amount')::int,
    p_idempotency_key := v_idempotency_key,
    p_correlation_id := p_correlation_id
  );

  if not (v_intent_result->>'success')::boolean then
    return v_intent_result;
  end if;

  return jsonb_build_object(
    'success', true,
    'session_id', p_session_id,
    'order_id', v_order_id,
    'order_number', v_create_result->>'order_number',
    'order_status', 'CONFIRMED',
    'total_amount', v_create_result->>'total_amount',
    'final_amount', v_create_result->>'final_amount',
    'kds_tickets_created',
      v_confirm_result->>'kds_tickets_created',
    'all_tickets_in_hold', true,
    'payment_intent', jsonb_build_object(
      'intent_id', v_intent_result->>'intent_id',
      'provider_order_id',
        v_intent_result->>'provider_order_id',
      'provider_type', p_provider_type
    ),
    'next_step', 'AWAIT_PAYMENT_CONFIRMATION',
    'message_code', 'kiosk_order_submitted'
  );
end;
$$;


create or replace function catchmenu_pos.get_kiosk_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kiosk_device_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store,
                  catchmenu_kds, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_device record;
  v_settings record;
  v_menu_summary jsonb;
  v_kds_summary jsonb;
  v_active_sessions int;
  v_business_day date;
begin
  select id, store_name, store_status, timezone
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

  -- kiosk device state
  select id, device_code, device_status, trust_level,
         app_version, last_heartbeat_at
  into v_device
  from catchmenu_store.device_registry
  where id = p_kiosk_device_id
    and store_id = p_store_id
    and device_type = 'KIOSK'
    and is_active = true;

  -- store settings
  select store_mode, waiting_enabled,
         pre_order_enabled, holiday_mode
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- menu summary
  select jsonb_build_object(
    'available_count', count(*) filter (
      where menu_status = 'AVAILABLE'
    ),
    'sold_out_count', count(*) filter (
      where menu_status = 'SOLD_OUT'
    )
  )
  into v_menu_summary
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and menu_status <> 'DISCONTINUED';

  -- KDS load summary
  select jsonb_build_object(
    'cooking_count', count(*) filter (
      where kds_status = 'COOKING'
    ),
    'hold_count', count(*) filter (
      where kds_status in ('HOLD', 'CAPACITY_CHECKING')
    ),
    'ready_count', count(*) filter (
      where kds_status = 'READY'
    )
  )
  into v_kds_summary
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and kds_status not in (
      'COMPLETED', 'CANCELLED', 'SERVED'
    );

  -- active kiosk sessions
  select count(*)
  into v_active_sessions
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and session_type = 'KIOSK'
    and session_status = 'ORDERING'
    and expires_at > now();

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_status', v_store.store_status
    ),
    'kiosk_device', case
      when v_device.id is not null
      then jsonb_build_object(
        'id', v_device.id,
        'device_code', v_device.device_code,
        'device_status', v_device.device_status,
        'trust_level', v_device.trust_level,
        'app_version', v_device.app_version,
        'last_heartbeat_at', v_device.last_heartbeat_at
      )
      else null
    end,
    'operational', jsonb_build_object(
      'store_mode', coalesce(
        v_settings.store_mode, 'NORMAL'
      ),
      'is_open', v_store.store_status = 'ACTIVE'
        and coalesce(
          v_settings.store_mode, 'NORMAL'
        ) not in ('CLOSED', 'EMERGENCY'),
      'holiday_mode', coalesce(
        v_settings.holiday_mode, false
      ),
      'ordering_available',
        v_store.store_status = 'ACTIVE'
        and coalesce(
          v_settings.store_mode, 'NORMAL'
        ) not in ('CLOSED', 'EMERGENCY')
    ),
    'menu_summary', v_menu_summary,
    'kds_load', v_kds_summary,
    'active_kiosk_sessions', v_active_sessions,
    'business_day', v_business_day,
    'refreshed_at', now(),
    'message_code', 'kiosk_state_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.create_kiosk_session(
    uuid, uuid, uuid, text, int, text, text
  ) from public;
  grant execute on function catchmenu_pos.create_kiosk_session(
    uuid, uuid, uuid, text, int, text, text
  ) to authenticated;

  revoke all on function catchmenu_pos.submit_kiosk_order(
    uuid, uuid, uuid, uuid, text, jsonb,
    text, text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.submit_kiosk_order(
    uuid, uuid, uuid, uuid, text, jsonb,
    text, text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.get_kiosk_state(
    uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_pos.get_kiosk_state(
    uuid, uuid, uuid
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.create_kiosk_session(
  uuid, uuid, uuid, text, int, text, text
) is
  'Creates kiosk order session.
   Validates kiosk device is TRUSTED and ONLINE.
   Session expires in 15 minutes if order not submitted.
   DINE_IN: Late Binding occurs at submit_kiosk_order.
   TAKEOUT: No table binding needed.
   특허1: Kiosk 세션 — 테이블 없이 시작, 주문 시 테이블 바인딩.';

comment on function catchmenu_pos.submit_kiosk_order(
  uuid, uuid, uuid, uuid, text, jsonb,
  text, text, text, text, uuid, text
) is
  'Submits complete kiosk order in one call.
   Executes: create_order → confirm_order → create_payment_intent.
   DINE_IN with table_id: bind_table_to_session called first.
   All KDS tickets created in HOLD.
   Returns payment intent for kiosk payment terminal.
   특허1: Kiosk 주문 → 결제 의도 생성 → KDS HOLD.
   특허2: HOLD 티켓은 결제 확인 후 capacity check 진행.';

comment on function catchmenu_pos.get_kiosk_state(
  uuid, uuid, uuid
) is
  'Returns complete kiosk operational state on startup.
   Checks store status, device trust, menu availability,
   KDS load, and store mode.
   Used by kiosk app on boot and periodic refresh.
   특허4: 디바이스 신뢰 확인 → 운영 가능 여부 판단.';