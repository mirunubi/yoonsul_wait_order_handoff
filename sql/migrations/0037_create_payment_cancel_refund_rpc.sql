-- 0037_create_payment_cancel_refund_rpc.sql
-- Purpose: Payment cancellation and refund RPCs.
--          cancel_payment: full cancellation of approved payment.
--          partial_cancel_payment: partial amount cancellation.
--          refund_payment: refund after order completion.
--          특허1 core: 취소/환불도 내부 원장 기준 처리.
-- Depends on: 0036_create_reconciliation_rpc.sql
-- Creates:
--   function catchmenu_payment.cancel_payment(...)
--   function catchmenu_payment.partial_cancel_payment(...)
--   function catchmenu_payment.refund_payment(...)

create or replace function catchmenu_payment.cancel_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_cancel_reason text,
  p_actor_type text,
  p_actor_id uuid,
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
  v_ledger record;
  v_audit_id uuid;
  v_evidence_id uuid;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  -- ledger validation
  select
    id, order_id, session_id, intent_id,
    ledger_status, approved_amount,
    kds_release_authorized,
    provider_type, provider_payment_key,
    provider_approval_number,
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

  if v_ledger.ledger_status not in ('APPROVED', 'UNCERTAIN') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_cancellable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- create evidence packet before mutation
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_CANCELLATION', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_cancel_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = 'CANCELLED',
    cancelled_amount = approved_amount,
    net_amount = 0,
    kds_release_authorized = false,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- block all KDS tickets for this order
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'CANCELLED',
    cancelled_at = now(),
    hold_reason = 'PAYMENT_CANCELLED',
    updated_at = now()
  where order_id = v_ledger.order_id
    and kds_status not in (
      'COMPLETED', 'SERVED', 'CANCELLED'
    );

  -- update order status
  update catchmenu_pos.orders
  set
    order_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = v_ledger.order_id
    and order_status not in ('COMPLETED', 'CANCELLED');

  -- update session
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = v_ledger.session_id
    and session_status not in ('COMPLETED', 'CANCELLED');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    'payment_cancelled',
    v_ledger.ledger_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    v_ledger.approved_amount,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_amount', v_ledger.approved_amount,
      'evidence_id', v_evidence_id
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
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_cancelled', 1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'cancelled_amount', v_ledger.approved_amount,
      'evidence_id', v_evidence_id
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_cancelled',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'cancelled_amount', v_ledger.approved_amount,
      'provider_payment_key', v_ledger.provider_payment_key,
      'evidence_id', v_evidence_id
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', 'CANCELLED',
      'net_amount', 0
    ),
    p_evidence_packet_id := v_evidence_id,
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
    'ledger_status', 'CANCELLED',
    'cancelled_amount', v_ledger.approved_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_CANCEL_API',
    'message_code', 'payment_cancelled'
  );
end;
$$;


create or replace function catchmenu_payment.partial_cancel_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_cancel_amount int,
  p_cancel_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ledger record;
  v_new_cancelled_amount int;
  v_new_net_amount int;
  v_audit_id uuid;
  v_evidence_id uuid;
begin
  if p_cancel_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_cancel_amount'
    );
  end if;

  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select
    id, order_id, session_id,
    ledger_status, approved_amount,
    cancelled_amount, net_amount,
    provider_payment_key,
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

  if v_ledger.ledger_status not in ('APPROVED', 'PARTIAL_CANCELLED') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_partial_cancellable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- validate cancel amount
  v_new_cancelled_amount := v_ledger.cancelled_amount + p_cancel_amount;
  v_new_net_amount := v_ledger.approved_amount - v_new_cancelled_amount;

  if v_new_cancelled_amount > v_ledger.approved_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_amount_exceeds_approved',
      'approved_amount', v_ledger.approved_amount,
      'already_cancelled', v_ledger.cancelled_amount,
      'requested_cancel', p_cancel_amount,
      'max_cancellable', v_ledger.net_amount
    );
  end if;

  -- create evidence
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_CANCELLATION', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'cancelled_amount_before', v_ledger.cancelled_amount,
      'net_amount_before', v_ledger.net_amount
    ),
    p_cancel_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = case
      when v_new_net_amount = 0 then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    cancelled_amount = v_new_cancelled_amount,
    net_amount = v_new_net_amount,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    'payment_partial_refunded',
    v_ledger.ledger_status,
    case when v_new_net_amount = 0
      then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    p_actor_type, p_actor_id,
    p_cancel_amount,
    jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'cancel_reason', p_cancel_reason,
      'new_net_amount', v_new_net_amount,
      'evidence_id', v_evidence_id
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
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_partial_cancelled', 1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status,
    case when v_new_net_amount = 0
      then 'CANCELLED'
      else 'PARTIAL_CANCELLED'
    end,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'cancel_reason', p_cancel_reason,
      'new_cancelled_amount', v_new_cancelled_amount,
      'new_net_amount', v_new_net_amount
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_partial_cancelled',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'cancel_amount', p_cancel_amount,
      'new_cancelled_amount', v_new_cancelled_amount,
      'new_net_amount', v_new_net_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'cancelled_amount', v_ledger.cancelled_amount,
      'net_amount', v_ledger.net_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', case when v_new_net_amount = 0
        then 'CANCELLED' else 'PARTIAL_CANCELLED'
      end,
      'cancelled_amount', v_new_cancelled_amount,
      'net_amount', v_new_net_amount
    ),
    p_evidence_packet_id := v_evidence_id,
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'ledger_status', case when v_new_net_amount = 0
      then 'CANCELLED' else 'PARTIAL_CANCELLED'
    end,
    'cancel_amount', p_cancel_amount,
    'new_cancelled_amount', v_new_cancelled_amount,
    'new_net_amount', v_new_net_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_PARTIAL_CANCEL_API',
    'message_code', 'payment_partial_cancelled'
  );
end;
$$;


create or replace function catchmenu_payment.refund_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_ledger_id uuid,
  p_refund_amount int,
  p_refund_reason text,
  p_actor_type text,
  p_actor_id uuid,
  p_is_partial boolean default false,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_ledger record;
  v_new_refunded_amount int;
  v_new_net_amount int;
  v_audit_id uuid;
  v_evidence_id uuid;
  v_new_status text;
begin
  if p_refund_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_refund_amount'
    );
  end if;

  if trim(coalesce(p_refund_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'refund_reason_required'
    );
  end if;

  select
    id, order_id, session_id,
    ledger_status, approved_amount,
    cancelled_amount, refunded_amount, net_amount,
    provider_payment_key,
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

  if v_ledger.ledger_status not in (
    'APPROVED', 'PARTIAL_CANCELLED', 'PARTIAL_REFUNDED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'ledger_not_refundable',
      'current_status', v_ledger.ledger_status
    );
  end if;

  -- validate refund amount
  v_new_refunded_amount := v_ledger.refunded_amount + p_refund_amount;
  v_new_net_amount := v_ledger.approved_amount
    - v_ledger.cancelled_amount
    - v_new_refunded_amount;

  if v_new_net_amount < 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'refund_exceeds_net_amount',
      'net_amount', v_ledger.net_amount,
      'requested_refund', p_refund_amount
    );
  end if;

  -- determine new status
  v_new_status := case
    when v_new_net_amount = 0 then 'REFUNDED'
    else 'PARTIAL_REFUNDED'
  end;

  -- create evidence
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    payment_ledger_id,
    prior_state,
    staff_visible_explanation,
    actor_type, actor_id,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'PAYMENT_REFUND', 'CREATED', 'HIGH',
    'payment_ledger', p_ledger_id,
    p_ledger_id,
    jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'approved_amount', v_ledger.approved_amount,
      'net_amount_before', v_ledger.net_amount,
      'refunded_amount_before', v_ledger.refunded_amount
    ),
    p_refund_reason,
    p_actor_type, p_actor_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone
  )
  returning id into v_evidence_id;

  -- update ledger
  update catchmenu_payment.payment_ledger
  set
    ledger_status = v_new_status,
    refunded_amount = v_new_refunded_amount,
    net_amount = v_new_net_amount,
    evidence_packet_id = v_evidence_id
  where id = p_ledger_id;

  -- update order status
  update catchmenu_pos.orders
  set
    order_status = case v_new_status
      when 'REFUNDED' then 'REFUNDED'
      else 'PARTIAL_REFUNDED'
    end,
    updated_at = now()
  where id = v_ledger.order_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    amount_at_event,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_ledger.order_id,
    p_ledger_id,
    case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    v_ledger.ledger_status, v_new_status,
    p_actor_type, p_actor_id,
    p_refund_amount,
    jsonb_build_object(
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'new_net_amount', v_new_net_amount,
      'evidence_id', v_evidence_id
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
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment',
    case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    1,
    'payment_ledger', p_ledger_id,
    v_ledger.ledger_status, v_new_status,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'refund_amount', p_refund_amount,
      'refund_reason', p_refund_reason,
      'new_refunded_amount', v_new_refunded_amount,
      'new_net_amount', v_new_net_amount
    ),
    v_ledger.order_id, p_ledger_id,
    p_correlation_id,
    v_ledger.business_day, v_ledger.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := case when p_is_partial
      then 'payment_partial_refunded'
      else 'payment_refunded'
    end,
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_refund_reason,
    p_decision_payload := jsonb_build_object(
      'refund_amount', p_refund_amount,
      'new_refunded_amount', v_new_refunded_amount,
      'new_net_amount', v_new_net_amount,
      'provider_payment_key', v_ledger.provider_payment_key
    ),
    p_before_state := jsonb_build_object(
      'ledger_status', v_ledger.ledger_status,
      'net_amount', v_ledger.net_amount
    ),
    p_after_state := jsonb_build_object(
      'ledger_status', v_new_status,
      'net_amount', v_new_net_amount
    ),
    p_evidence_packet_id := v_evidence_id,
    p_payment_id := p_ledger_id,
    p_order_id := v_ledger.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ledger.business_day,
    p_business_timezone := v_ledger.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'ledger_id', p_ledger_id,
    'ledger_status', v_new_status,
    'refund_amount', p_refund_amount,
    'new_refunded_amount', v_new_refunded_amount,
    'new_net_amount', v_new_net_amount,
    'evidence_id', v_evidence_id,
    'audit_id', v_audit_id,
    'provider_payment_key', v_ledger.provider_payment_key,
    'next_step', 'CALL_PROVIDER_REFUND_API',
    'message_code', case v_new_status
      when 'REFUNDED' then 'payment_fully_refunded'
      else 'payment_partially_refunded'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_payment.cancel_payment(
    uuid, uuid, uuid, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_payment.cancel_payment(
    uuid, uuid, uuid, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_payment.partial_cancel_payment(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_payment.partial_cancel_payment(
    uuid, uuid, uuid, int, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_payment.refund_payment(
    uuid, uuid, uuid, int, text, text, uuid, boolean, text
  ) from public;
  grant execute on function catchmenu_payment.refund_payment(
    uuid, uuid, uuid, int, text, text, uuid, boolean, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_payment.cancel_payment(
  uuid, uuid, uuid, text, text, uuid, text
) is
  'Full payment cancellation.
   Creates evidence packet before any mutation.
   Blocks all KDS tickets for the order.
   Cancels order and session.
   Returns provider_payment_key for caller to invoke provider cancel API.
   특허1: 내부 원장 먼저 취소 → 이후 외부 PG/VAN API 호출.
   취소도 감사 원장에 기록 필수.';

comment on function catchmenu_payment.partial_cancel_payment(
  uuid, uuid, uuid, int, text, text, uuid, text
) is
  'Partial payment cancellation.
   Validates cancel_amount does not exceed net_amount.
   Creates evidence packet for audit trail.
   Returns provider_payment_key for partial cancel API call.
   특허1: 부분취소도 내부 원장 기준 처리 후 PG API 호출.';

comment on function catchmenu_payment.refund_payment(
  uuid, uuid, uuid, int, text, text, uuid, boolean, text
) is
  'Payment refund after order completion.
   Validates refund_amount does not exceed net_amount.
   Creates evidence packet. Updates order status.
   Returns provider_payment_key for refund API call.
   특허1: 환불도 내부 원장에 먼저 기록 후 외부 PG API 호출.
   환불 증빙은 evidence_packet에 보관.';
