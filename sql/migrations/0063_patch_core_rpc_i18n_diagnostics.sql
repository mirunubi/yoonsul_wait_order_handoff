-- 0063_patch_core_rpc_i18n_diagnostics.sql
-- Purpose: Patches core RPCs to use i18n error responses
--          and diagnostic logging.
--          Replaces raw jsonb error returns with
--          build_error_response() + build_success_response().
--          Patches: create_order_session, confirm_order,
--          confirm_payment_from_provider,
--          mark_payment_uncertain, commit_kds_ticket,
--          bind_table_to_session.
--          특허4: 모든 에러 = 감사 추적 가능 진단 원장 기록.
-- Depends on: 0062_create_i18n_error_diagnostics.sql

-- =============================================
-- patch: create_order_session
-- =============================================
create or replace function catchmenu_pos.create_order_session(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_type text,
  p_guest_count int default 1,
  p_guest_locale text default 'ko',
  p_wait_number int default null,
  p_queue_position int default null,
  p_pre_order_expires_at timestamptz default null,
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
  v_settings record;
  v_wait_number int;
  v_next_wait int;
begin
  -- validate session type
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER',
    'KIOSK', 'DELIVERY', 'ONLINE'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := coalesce(p_guest_locale, 'ko'),
      p_params := jsonb_build_object(
        'field', 'session_type',
        'value', p_session_type
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_order_session',
      p_correlation_id := p_correlation_id
    );
  end if;

  if coalesce(p_guest_count, 0) < 1 then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := coalesce(p_guest_locale, 'ko'),
      p_params := jsonb_build_object(
        'field', 'guest_count'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_order_session',
      p_correlation_id := p_correlation_id
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  if v_timezone is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := coalesce(p_guest_locale, 'ko'),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_order_session',
      p_correlation_id := p_correlation_id
    );
  end if;

  v_business_day := (timezone(v_timezone, now()))::date;

  -- get store settings
  select waiting_enabled
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- check waiting enabled
  if p_session_type in ('WAITING', 'PRE_ORDER')
    and coalesce(v_settings.waiting_enabled, true) = false
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_disabled',
      p_locale := coalesce(p_guest_locale, 'ko'),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'create_order_session',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- auto-assign wait number for WAITING sessions
  if p_session_type in ('WAITING', 'PRE_ORDER') then
    if p_wait_number is not null then
      v_wait_number := p_wait_number;
    else
      select coalesce(max(wait_number), 0) + 1
      into v_next_wait
      from catchmenu_pos.order_sessions
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_business_day;
      v_wait_number := v_next_wait;
    end if;
  end if;

  -- create session
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    wait_number, queue_position,
    session_started_at,
    pre_order_expires_at,
    expires_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type,
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
    coalesce(p_guest_count, 1),
    coalesce(p_guest_locale, 'ko'),
    v_wait_number, p_queue_position,
    now(),
    p_pre_order_expires_at,
    case p_session_type
      when 'KIOSK' then now() + interval '15 minutes'
      when 'WALK_IN' then now() + interval '60 minutes'
      else null
    end,
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- session event
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_session_id,
    'session_created', null,
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'guest_count', p_guest_count,
      'wait_number', v_wait_number
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
    session_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'session', 'session_created', 1,
    'order_session', v_session_id,
    null,
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      else 'WAITING'
    end,
    'SYSTEM',
    jsonb_build_object(
      'session_type', p_session_type,
      'guest_count', p_guest_count,
      'wait_number', v_wait_number
    ),
    v_session_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- diagnostic log: INFO
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SESSION',
    p_log_event := 'session_created',
    p_message := 'Session created: ' || p_session_type
      || ' wait=' || coalesce(
        v_wait_number::text, 'N/A'
      ),
    p_rpc_name := 'create_order_session',
    p_correlation_id := p_correlation_id,
    p_session_id := v_session_id,
    p_details := jsonb_build_object(
      'session_type', p_session_type,
      'guest_count', p_guest_count,
      'wait_number', v_wait_number,
      'guest_locale', p_guest_locale
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'session_type', p_session_type,
      'session_status', case p_session_type
        when 'WALK_IN' then 'ORDERING'
        when 'KIOSK' then 'ORDERING'
        when 'DELIVERY' then 'ORDER_CONFIRMED'
        else 'WAITING'
      end,
      'wait_number', v_wait_number,
      'guest_count', p_guest_count,
      'business_day', v_business_day
    ),
    p_locale := coalesce(p_guest_locale, 'ko'),
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- patch: confirm_payment_from_provider
-- =============================================
create or replace function
  catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_provider_payment_key text,
  p_provider_approval_number text,
  p_approved_amount int,
  p_provider_raw_event_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_intent record;
  v_ledger_id uuid;
  v_order_id uuid;
  v_session_id uuid;
  v_amount_diff int;
  v_audit_id uuid;
  v_log_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- get intent
  select pi.id, pi.order_id, pi.session_id,
         pi.intent_status, pi.requested_amount,
         pi.provider_type, pi.provider_order_id,
         pi.idempotency_key
  into v_intent
  from catchmenu_payment.payment_intents pi
  where pi.id = p_intent_id
    and pi.store_id = p_store_id
    and pi.tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'intent_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment_from_provider',
      p_correlation_id := p_correlation_id
    );
  end if;

  if v_intent.intent_status not in (
    'PENDING', 'PROCESSING'
  ) then
    -- already confirmed or failed
    if v_intent.intent_status = 'CONFIRMED' then
      -- idempotent success
      return catchmenu_common.build_success_response(
        p_message_key := 'payment_confirmed',
        p_data := jsonb_build_object(
          'intent_id', p_intent_id,
          'intent_status', 'CONFIRMED',
          'idempotent', true
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    end if;

    return catchmenu_common.build_error_response(
      p_error_key := 'intent_not_found',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_intent.intent_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment_from_provider',
      p_correlation_id := p_correlation_id
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  v_amount_diff := p_approved_amount
    - v_intent.requested_amount;

  -- update intent to CONFIRMED
  update catchmenu_payment.payment_intents
  set
    intent_status = 'CONFIRMED',
    provider_payment_key := p_provider_payment_key,
    confirmed_amount := p_approved_amount,
    confirmed_at := now(),
    updated_at := now()
  where id = p_intent_id;

  -- create payment ledger entry
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id, intent_id,
    ledger_status,
    provider_type, provider_payment_key,
    provider_approval_number,
    provider_raw_event_id,
    approved_amount, net_amount,
    kds_release_authorized,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_intent.order_id, v_intent.session_id,
    p_intent_id,
    'APPROVED',
    v_intent.provider_type,
    p_provider_payment_key,
    p_provider_approval_number,
    p_provider_raw_event_id,
    p_approved_amount, p_approved_amount,
    -- 특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용
    false,
    v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- update order
  update catchmenu_pos.orders
  set
    order_status = 'PAID',
    payment_completed_at := now(),
    updated_at := now()
  where id = v_intent.order_id;

  -- update session
  update catchmenu_pos.order_sessions
  set
    payment_completed_at := now(),
    updated_at := now()
  where id = v_intent.session_id;

  -- update KDS conditions: payment_confirmed = true
  -- 특허2: 결제 확인 → conditions_met.payment_confirmed
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met
      || jsonb_build_object('payment_confirmed', true),
    updated_at := now()
  where order_id = v_intent.order_id
    and store_id = p_store_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  -- payment event
  insert into catchmenu_payment.payment_events (
    tenant_id, store_id, order_id,
    ledger_id, event_type,
    from_status, to_status,
    caused_by_type,
    amount_at_event, event_payload,
    correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, v_intent.order_id,
    v_ledger_id, 'payment_confirmed',
    'PENDING', 'APPROVED',
    'PROVIDER',
    p_approved_amount,
    jsonb_build_object(
      'provider_payment_key', p_provider_payment_key,
      'provider_approval_number',
        p_provider_approval_number,
      'amount_diff', v_amount_diff,
      'kds_release_authorized', false
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
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_confirmed', 1,
    'payment_ledger', v_ledger_id,
    'PENDING', 'APPROVED',
    'PROVIDER',
    jsonb_build_object(
      'approved_amount', p_approved_amount,
      'requested_amount', v_intent.requested_amount,
      'amount_diff', v_amount_diff,
      'kds_release_authorized', false,
      'provider_payment_key', p_provider_payment_key
    ),
    v_intent.order_id, v_ledger_id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'PROVIDER',
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'amount_diff', v_amount_diff,
      'provider_payment_key', p_provider_payment_key,
      'kds_release_authorized', false
    ),
    p_payment_id := v_ledger_id,
    p_order_id := v_intent.order_id,
    p_session_id := v_intent.session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- diagnostic log
  v_log_id := catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'payment_confirmed',
    p_message := 'Payment confirmed: '
      || p_approved_amount || 'KRW'
      || ' approval=' || p_provider_approval_number,
    p_rpc_name := 'confirm_payment_from_provider',
    p_correlation_id := p_correlation_id,
    p_order_id := v_intent.order_id,
    p_payment_id := v_ledger_id,
    p_details := jsonb_build_object(
      'approved_amount', p_approved_amount,
      'amount_diff', v_amount_diff,
      'provider_type', v_intent.provider_type,
      'kds_release_authorized', false
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_confirmed',
    p_data := jsonb_build_object(
      'ledger_id', v_ledger_id,
      'intent_id', p_intent_id,
      'order_id', v_intent.order_id,
      'ledger_status', 'APPROVED',
      'approved_amount', p_approved_amount,
      'amount_diff', v_amount_diff,
      'kds_release_authorized', false,
      'next_step', 'AUTHORIZE_KDS_RELEASE_MANUALLY',
      'audit_id', v_audit_id,
      'log_id', v_log_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- patch: mark_payment_uncertain
-- =============================================
create or replace function
  catchmenu_payment.mark_payment_uncertain(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intent_id uuid,
  p_uncertain_reason text,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_intent record;
  v_exception_id uuid;
  v_audit_id uuid;
  v_log_id uuid;
  v_business_day date;
  v_timezone text;
  v_held_tickets int;
begin
  if trim(coalesce(p_uncertain_reason, '')) = '' then
    return catchmenu_common.build_error_response(
      p_error_key := 'cancel_reason_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'mark_payment_uncertain',
      p_correlation_id := p_correlation_id
    );
  end if;

  select pi.id, pi.order_id, pi.session_id,
         pi.intent_status, pi.requested_amount,
         pi.provider_type
  into v_intent
  from catchmenu_payment.payment_intents pi
  where pi.id = p_intent_id
    and pi.store_id = p_store_id
    and pi.tenant_id = p_tenant_id
  for update;

  if v_intent.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'intent_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'mark_payment_uncertain',
      p_correlation_id := p_correlation_id
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- mark intent uncertain
  update catchmenu_payment.payment_intents
  set
    intent_status = 'UNCERTAIN',
    updated_at := now()
  where id = p_intent_id;

  -- CRITICAL: HOLD all KDS tickets
  -- 특허1: PAYMENT_UNCERTAIN = KDS 전체 HOLD
  update catchmenu_kds.kds_tickets
  set
    kds_status = 'HOLD',
    hold_reason = 'PAYMENT_UNCERTAIN',
    conditions_met = conditions_met
      || jsonb_build_object('payment_confirmed', false),
    updated_at := now()
  where order_id = v_intent.order_id
    and store_id = p_store_id
    and kds_status not in (
      'COMPLETED', 'SERVED', 'CANCELLED'
    );

  get diagnostics v_held_tickets = row_count;

  -- create CRITICAL exception
  insert into catchmenu_ledger.exceptions (
    tenant_id, store_id,
    exception_domain, exception_type,
    exception_severity, exception_status,
    subject_type, subject_id,
    error_message, exception_payload,
    requires_human_approval,
    detected_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_uncertain',
    'CRITICAL', 'OPEN',
    'payment_intent', p_intent_id,
    p_uncertain_reason,
    jsonb_build_object(
      'intent_id', p_intent_id,
      'order_id', v_intent.order_id,
      'provider_type', v_intent.provider_type,
      'requested_amount', v_intent.requested_amount,
      'held_kds_tickets', v_held_tickets
    ),
    true,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_exception_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, payment_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_uncertain', 1,
    'payment_intent', p_intent_id,
    v_intent.intent_status, 'UNCERTAIN',
    'SYSTEM',
    jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'held_kds_tickets', v_held_tickets,
      'exception_id', v_exception_id
    ),
    v_intent.order_id, null,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- CRITICAL audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_uncertain',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'payment_intent',
    p_subject_id := p_intent_id,
    p_decision := 'NOTED',
    p_decision_reason := p_uncertain_reason,
    p_decision_payload := jsonb_build_object(
      'held_kds_tickets', v_held_tickets,
      'exception_id', v_exception_id,
      'requires_human_resolution', true
    ),
    p_order_id := v_intent.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- CRITICAL diagnostic log
  v_log_id := catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'CRITICAL',
    p_log_domain := 'PAYMENT',
    p_log_event := 'payment_uncertain',
    p_message := '[CRITICAL] Payment uncertain: '
      || p_uncertain_reason
      || ' | KDS tickets held: ' || v_held_tickets,
    p_error_key := 'payment_uncertain_active',
    p_recovery_hint :=
      '1. 카드사/PG사에 승인 여부 직접 확인'
      || ' 2. resolve_payment_uncertain() 호출'
      || ' 3. KDS 릴리즈 권한은 해소 후 자동 복구',
    p_rpc_name := 'mark_payment_uncertain',
    p_correlation_id := p_correlation_id,
    p_order_id := v_intent.order_id,
    p_exception_id := v_exception_id,
    p_details := jsonb_build_object(
      'uncertain_reason', p_uncertain_reason,
      'held_kds_tickets', v_held_tickets,
      'provider_type', v_intent.provider_type,
      'requested_amount', v_intent.requested_amount
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_uncertain_active',
    p_data := jsonb_build_object(
      'intent_id', p_intent_id,
      'order_id', v_intent.order_id,
      'intent_status', 'UNCERTAIN',
      'held_kds_tickets', v_held_tickets,
      'exception_id', v_exception_id,
      'audit_id', v_audit_id,
      'log_id', v_log_id,
      'requires_human_resolution', true,
      'next_step', 'CALL_PROVIDER_VERIFY_AND_RESOLVE'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- patch: authorize_kds_release
-- =============================================
create or replace function
  catchmenu_kds.authorize_kds_release(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_authorized_by_type text,
  p_authorized_by_id uuid,
  p_authorization_reason text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_ledger record;
  v_updated_tickets int;
  v_audit_id uuid;
  v_log_id uuid;
  v_business_day date;
  v_timezone text;
begin
  -- authorizer must be MANAGER or above
  if p_authorized_by_type not in (
    'MANAGER', 'OWNER', 'SYSTEM', 'HQ_ADMIN'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'insufficient_authority',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'required_role', 'MANAGER or above'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'authorize_kds_release',
      p_correlation_id := p_correlation_id,
      p_order_id := p_order_id
    );
  end if;

  -- validate payment ledger
  select id, ledger_status, approved_amount,
         kds_release_authorized
  into v_ledger
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and ledger_status = 'APPROVED'
  for update;

  if v_ledger.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'kds_release_not_authorized',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'authorize_kds_release',
      p_correlation_id := p_correlation_id,
      p_order_id := p_order_id
    );
  end if;

  if v_ledger.kds_release_authorized then
    -- already authorized, idempotent
    return catchmenu_common.build_success_response(
      p_message_key := 'payment_confirmed',
      p_data := jsonb_build_object(
        'ledger_id', v_ledger.id,
        'order_id', p_order_id,
        'kds_release_authorized', true,
        'idempotent', true
      ),
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 특허1: 결제 승인 후 별도 KDS 릴리즈 권한 부여
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_by := p_authorized_by_id,
    kds_release_authorized_at := now(),
    updated_at := now()
  where id = v_ledger.id;

  -- update KDS conditions: payment_confirmed = true
  update catchmenu_kds.kds_tickets
  set
    conditions_met = conditions_met
      || jsonb_build_object('payment_confirmed', true),
    updated_at := now()
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and kds_status in ('HOLD', 'CAPACITY_CHECKING');

  get diagnostics v_updated_tickets = row_count;

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
    'payment', 'kds_release_authorized', 1,
    'payment_ledger', v_ledger.id,
    'APPROVED_HOLD', 'APPROVED_KDS_RELEASED',
    p_authorized_by_type, p_authorized_by_id,
    jsonb_build_object(
      'authorization_reason', p_authorization_reason,
      'approved_amount', v_ledger.approved_amount,
      'updated_kds_tickets', v_updated_tickets
    ),
    p_order_id, v_ledger.id,
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_authorized',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_authorized_by_type,
    p_actor_id := p_authorized_by_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger.id,
    p_decision := 'APPROVED',
    p_decision_reason := p_authorization_reason,
    p_decision_payload := jsonb_build_object(
      'kds_release_authorized', true,
      'updated_kds_tickets', v_updated_tickets,
      'approved_amount', v_ledger.approved_amount
    ),
    p_payment_id := v_ledger.id,
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- INFO diagnostic log
  v_log_id := catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'kds_release_authorized',
    p_message := 'KDS release authorized by '
      || p_authorized_by_type
      || ' | tickets updated: '
      || v_updated_tickets,
    p_rpc_name := 'authorize_kds_release',
    p_correlation_id := p_correlation_id,
    p_order_id := p_order_id,
    p_payment_id := v_ledger.id,
    p_details := jsonb_build_object(
      'authorized_by_type', p_authorized_by_type,
      'updated_kds_tickets', v_updated_tickets,
      'authorization_reason', p_authorization_reason
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_confirmed',
    p_data := jsonb_build_object(
      'ledger_id', v_ledger.id,
      'order_id', p_order_id,
      'kds_release_authorized', true,
      'updated_kds_tickets', v_updated_tickets,
      'audit_id', v_audit_id,
      'log_id', v_log_id,
      'next_step', 'RUN_BULK_COMMIT_KDS_TICKETS'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


-- =============================================
-- Additional message catalog entries
-- (staff/system messages)
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('payment_uncertain_active', 'ko',
  '[주의] 결제 불확실 상태 — KDS 조리 중단'),
('payment_uncertain_active', 'en',
  '[ALERT] Payment uncertain — KDS cooking halted'),
('hint_retry_after_moment', 'ko',
  '잠시 후 다시 시도해 주세요'),
('hint_retry_after_moment', 'en',
  'Please try again in a moment'),
('hint_retry_after_moment', 'zh',
  '请稍后重试'),
('hint_retry_after_moment', 'ja',
  '少し後でもう一度お試しください'),
('invalid_input', 'ko', '입력값이 올바르지 않습니다'),
('invalid_input', 'en', 'Invalid input'),
('invalid_input', 'zh', '输入无效'),
('invalid_input', 'ja', '入力値が正しくありません'),
('store_not_found', 'ko', '매장을 찾을 수 없습니다'),
('store_not_found', 'en', 'Store not found'),
('session_created', 'zh', '会话已创建'),
('session_created', 'ja', 'セッションが作成されました'),
('payment_confirmed', 'ko', '결제가 확인되었습니다'),
('payment_confirmed', 'en', 'Payment confirmed'),
('payment_confirmed', 'zh', '付款已确认'),
('payment_confirmed', 'ja', 'お支払いが確認されました')
on conflict (message_key, locale) do nothing;


-- grants
do $$
begin
  revoke all on function catchmenu_pos.create_order_session(
    uuid, uuid, text, int, text, int, int, timestamptz, text
  ) from public;
  grant execute on function catchmenu_pos.create_order_session(
    uuid, uuid, text, int, text, int, int, timestamptz, text
  ) to authenticated;

  revoke all on function
    catchmenu_payment.confirm_payment_from_provider(
      uuid, uuid, uuid, text, text, int, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.confirm_payment_from_provider(
      uuid, uuid, uuid, text, text, int, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.mark_payment_uncertain(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.mark_payment_uncertain(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_kds.authorize_kds_release(
      uuid, uuid, uuid, text, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_kds.authorize_kds_release(
      uuid, uuid, uuid, text, uuid, text, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_pos.create_order_session(
  uuid, uuid, text, int, text, int, int, timestamptz, text
) is
  'Creates order session with i18n response and diagnostic logging.
   All errors: build_error_response() → stable code + i18n message.
   All success: build_success_response() → i18n message + data.
   INFO log written on success.
   특허1: 세션 생성 = 고객 journey 시작점.
   locale 파라미터로 고객 언어 결정.';

comment on function
  catchmenu_payment.mark_payment_uncertain(
    uuid, uuid, uuid, text, text, text
  ) is
  'Marks payment as uncertain and halts all KDS tickets.
   Writes CRITICAL diagnostic log with recovery_hint.
   Recovery hint (ko/en/zh/ja):
     1. 카드사/PG사 직접 확인
     2. resolve_payment_uncertain() 호출
     3. KDS 릴리즈는 해소 후 자동 복구
   특허1: PAYMENT_UNCERTAIN = KDS 전체 HOLD.
   CRITICAL 이벤트 = 감사 원장 + 진단 원장 동시 기록.';