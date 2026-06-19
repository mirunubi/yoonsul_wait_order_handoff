-- 0027_create_payment_intent_rpc.sql
-- Purpose: Payment intent creation and KDS release authorization.
--          create_payment_intent: creates payment intent before provider call.
--          confirm_payment_from_provider: records provider confirmation
--            and authorizes KDS release.
--          mark_payment_uncertain: flags uncertain payment state.
--          특허1 core: 결제 의도 → 내부 원장 → KDS 릴리즈 권한 분리.
-- Depends on: 0026_create_order_rpc.sql
-- Creates:
--   function catchmenu_payment.create_payment_intent(...)
--   function catchmenu_payment.confirm_payment_from_provider(...)
--   function catchmenu_payment.mark_payment_uncertain(...)
--   function catchmenu_payment.resolve_payment_uncertain(...)

create or replace function catchmenu_payment.create_payment_intent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_session_id uuid,
  p_payment_method text,
  p_payment_channel text,
  p_provider_type text,
  p_requested_amount int,
  p_idempotency_key text,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_pos,
                  catchmenu_common, catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_intent_id uuid;
  v_provider_order_id text;
  v_order record;
  v_business_day date;
  v_timezone text;
  v_existing_intent_id uuid;
begin
  -- idempotency check
  select id into v_existing_intent_id
  from catchmenu_payment.payment_intents
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and order_id = p_order_id
    and intent_status not in ('FAILED', 'CANCELLED', 'EXPIRED');

  if v_existing_intent_id is not null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'active_intent_exists',
      'existing_intent_id', v_existing_intent_id
    );
  end if;

  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- order validation
  select id, order_status, final_amount
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

  if v_order.order_status not in ('CONFIRMED', 'PENDING') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'order_not_payable',
      'order_status', v_order.order_status
    );
  end if;

  if p_requested_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_amount'
    );
  end if;

  if p_requested_amount <> v_order.final_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'order_amount', v_order.final_amount,
      'requested_amount', p_requested_amount
    );
  end if;

  -- generate provider order id
  -- format: CM-{store_short}-{timestamp}-{random}
  v_provider_order_id := 'CM-' ||
    upper(substr(p_store_id::text, 1, 8)) || '-' ||
    extract(epoch from now())::bigint::text || '-' ||
    upper(substr(gen_random_uuid()::text, 1, 6));

  -- create intent
  insert into catchmenu_payment.payment_intents (
    tenant_id, store_id, order_id, session_id,
    intent_status, payment_method, payment_channel,
    requested_amount, currency,
    provider_type, provider_order_id,
    idempotency_key,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_order_id, p_session_id,
    'CREATED', p_payment_method, p_payment_channel,
    p_requested_amount, 'KRW',
    p_provider_type, v_provider_order_id,
    p_idempotency_key,
    v_business_day, v_timezone
  )
  returning id into v_intent_id;

  -- update session to PAYMENT_PENDING
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_PENDING',
    payment_started_at = now(),
    toss_order_id = case
      when p_provider_type = 'TOSS_PAYMENTS'
      then v_provider_order_id
      else toss_order_id
    end,
    updated_at = now()
  where id = p_session_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, from_status, to_status,
    caused_by_type,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_order_id, v_intent_id,
    'intent_created', null, 'CREATED',
    'SYSTEM',
    jsonb_build_object(
      'payment_method', p_payment_method,
      'payment_channel', p_payment_channel,
      'provider_type', p_provider_type,
      'provider_order_id', v_provider_order_id,
      'requested_amount', p_requested_amount
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
    'payment', 'intent_created', 1,
    'payment_intent', v_intent_id,
    null, 'CREATED',
    'SYSTEM',
    jsonb_build_object(
      'provider_type', p_provider_type,
      'provider_order_id', v_provider_order_id,
      'requested_amount', p_requested_amount
    ),
    p_session_id, p_order_id, v_intent_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', v_intent_id,
    'provider_order_id', v_provider_order_id,
    'intent_status', 'CREATED',
    'requested_amount', p_requested_amount,
    'provider_type', p_provider_type,
    'message_code', 'intent_created'
  );
end;
$$;


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

  return jsonb_build_object(
    'success', true,
    'ledger_id', v_ledger_id,
    'intent_id', p_intent_id,
    'ledger_status', 'APPROVED',
    'approved_amount', p_approved_amount,
    'kds_release_authorized', false,
    'kds_tickets_payment_confirmed', v_kds_updated,
    'reconciliation_status', 'PENDING',
    'next_step', 'KDS_CAPACITY_CHECK_REQUIRED',
    'message_code', 'payment_approved_kds_pending_capacity',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_payment.mark_payment_uncertain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_uncertain_reason text,
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
  v_exception_id uuid;
  v_audit_id uuid;
begin
  select id, order_id, session_id,
         business_day, business_timezone
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

  -- update intent
  update catchmenu_payment.payment_intents
  set intent_status = 'PROCESSING',
      updated_at = now()
  where id = p_intent_id;

  -- update session to PAYMENT_UNCERTAIN
  -- 특허1: PAYMENT_UNCERTAIN = KDS 절대 릴리즈 금지
  update catchmenu_pos.order_sessions
  set
    session_status = 'PAYMENT_UNCERTAIN',
    updated_at = now()
  where id = v_intent.session_id;

  -- ensure all KDS tickets remain in HOLD
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'HOLD',
    hold_reason = 'PAYMENT_UNCERTAIN',
    updated_at = now()
  where order_id = v_intent.order_id
    and kds_status not in ('COMPLETED', 'CANCELLED', 'SERVED');

  -- create exception
  insert into catchmenu_ledger.exceptions (
    tenant_id, store_id,
    exception_code, exception_domain, exception_type,
    exception_severity, exception_status,
    subject_type, subject_id,
    triggered_by_agent_id,
    exception_payload,
    error_message,
    requires_human_approval,
    business_day, business_timezone,
    detected_at
  ) values (
    p_tenant_id, p_store_id,
    'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text,
    'payment', 'payment_uncertain',
    'CRITICAL', 'OPEN',
    'payment_intent', p_intent_id,
    null,
    jsonb_build_object(
      'intent_id', p_intent_id,
      'order_id', v_intent.order_id,
      'uncertain_reason', p_uncertain_reason
    ),
    p_uncertain_reason,
    true,
    v_intent.business_day, v_intent.business_timezone,
    now()
  )
  returning id into v_exception_id;

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, caused_by_type,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, p_intent_id,
    'payment_uncertain', 'SYSTEM',
    jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'kds_blocked', true,
      'exception_id', v_exception_id
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
    'payment', 'payment_uncertain', 1,
    'payment_intent', p_intent_id,
    'PROCESSING', 'UNCERTAIN',
    'SYSTEM',
    jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'kds_blocked', true,
      'exception_id', v_exception_id,
      'requires_human_resolution', true
    ),
    v_intent.session_id, v_intent.order_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_uncertain_flagged',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'payment_intent',
    p_subject_id := p_intent_id,
    p_decision := 'NOTED',
    p_decision_reason := p_uncertain_reason,
    p_decision_payload := jsonb_build_object(
      'kds_blocked', true,
      'exception_id', v_exception_id,
      'requires_human_resolution', true
    ),
    p_exception_id := v_exception_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', p_intent_id,
    'session_status', 'PAYMENT_UNCERTAIN',
    'kds_blocked', true,
    'exception_id', v_exception_id,
    'requires_human_resolution', true,
    'message_code', 'payment_uncertain_kds_blocked',
    'audit_id', v_audit_id
  );
end;
$$;


create or replace function catchmenu_payment.resolve_payment_uncertain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_resolution_type text,
  p_actor_type text,
  p_actor_id uuid,
  p_resolution_note text default null,
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
  v_audit_id uuid;
begin
  if p_resolution_type not in (
    'CONFIRMED_APPROVED',
    'CONFIRMED_FAILED',
    'MANUAL_OVERRIDE_APPROVED',
    'CANCELLED'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution_type'
    );
  end if;

  select id, order_id, session_id,
         business_day, business_timezone
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

  -- update session based on resolution
  update catchmenu_pos.order_sessions
  set
    session_status = case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'PAYMENT_PENDING'
      when 'MANUAL_OVERRIDE_APPROVED' then 'PAYMENT_PENDING'
      when 'CONFIRMED_FAILED' then 'ORDERING'
      when 'CANCELLED' then 'CANCELLED'
    end,
    updated_at = now()
  where id = v_intent.session_id;

  -- update intent
  update catchmenu_payment.payment_intents
  set
    intent_status = case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'CONFIRMED'
      when 'MANUAL_OVERRIDE_APPROVED' then 'CONFIRMED'
      when 'CONFIRMED_FAILED' then 'FAILED'
      when 'CANCELLED' then 'CANCELLED'
    end,
    updated_at = now()
  where id = p_intent_id;

  -- close related exception
  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = 'MANUAL_MANAGER',
    resolution_note = p_resolution_note,
    resolved_by_type = p_actor_type,
    resolved_by_id = p_actor_id,
    resolved_at = now(),
    updated_at = now()
  where subject_type = 'payment_intent'
    and subject_id = p_intent_id
    and exception_status not in ('RESOLVED', 'CLOSED');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id, intent_id,
    event_type, caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, p_intent_id,
    'payment_uncertain_resolved',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note
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
    'payment', 'payment_uncertain_resolved', 1,
    'payment_intent', p_intent_id,
    'UNCERTAIN', p_resolution_type,
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note
    ),
    v_intent.session_id, v_intent.order_id,
    p_correlation_id,
    v_intent.business_day, v_intent.business_timezone, now()
  );

  -- audit record
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_uncertain_resolved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_intent',
    p_subject_id := p_intent_id,
    p_decision := case p_resolution_type
      when 'CONFIRMED_APPROVED' then 'APPROVED'
      when 'MANUAL_OVERRIDE_APPROVED' then 'OVERRIDDEN'
      when 'CONFIRMED_FAILED' then 'REJECTED'
      when 'CANCELLED' then 'CANCELLED'
    end,
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution_type', p_resolution_type
    ),
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_intent.business_day,
    p_business_timezone := v_intent.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'intent_id', p_intent_id,
    'resolution_type', p_resolution_type,
    'audit_id', v_audit_id,
    'message_code', 'payment_uncertain_resolved'
  );
end;
$$;

-- grants
revoke all on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) from public;
grant execute on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) to authenticated;

revoke all on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) from public;
grant execute on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) to authenticated;

revoke all on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) to authenticated;

revoke all on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) from public;
grant execute on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) to authenticated;

comment on function catchmenu_payment.create_payment_intent(
  uuid, uuid, uuid, uuid, text, text, text, int, text, text
) is
  'Creates payment intent before calling external provider.
   Generates provider_order_id to pass to Toss/VAN/PG.
   Internal order_id is never exposed to provider.
   Amount must match order final_amount exactly.
   특허1: 단회성 비상태형 토큰 발급 — 내부 원장 키 미노출.';

comment on function catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text
) is
  'Records provider payment confirmation in internal ledger.
   Creates payment_ledger entry with kds_release_authorized = FALSE.
   Updates KDS ticket conditions_met.payment_confirmed = true.
   KDS tickets still in HOLD — capacity check required separately.
   특허1: 결제 승인 ≠ KDS 자동 릴리즈.
   특허2: KDS Late Binding 조건 중 payment_confirmed 업데이트.';

comment on function catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text
) is
  'Flags payment as uncertain when provider result is unknown.
   Immediately blocks all KDS tickets for this order.
   Creates CRITICAL exception requiring human resolution.
   특허1: PAYMENT_UNCERTAIN 상태 = KDS 절대 릴리즈 금지.
   payment_uncertain ≠ payment_failed.';

comment on function catchmenu_payment.resolve_payment_uncertain(
  uuid, uuid, uuid, text, text, uuid, text, text
) is
  'Resolves payment uncertain state with human decision.
   CONFIRMED_APPROVED: payment confirmed, proceed to KDS capacity check.
   MANUAL_OVERRIDE_APPROVED: manager overrides, with full audit trail.
   CONFIRMED_FAILED: payment failed, return to ordering.
   CANCELLED: cancel order.
   All resolutions require actor_type and actor_id — human accountability.
   특허4: 최종 승인과 책임은 관리자에게 귀속.';