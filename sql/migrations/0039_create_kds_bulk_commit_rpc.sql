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

    if (v_commit_result->>'kds_status') = 'READY_TO_COMMIT' then
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
            (v_commit_result->>'kds_status') = 'READY_TO_COMMIT'
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