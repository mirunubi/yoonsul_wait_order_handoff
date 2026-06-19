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