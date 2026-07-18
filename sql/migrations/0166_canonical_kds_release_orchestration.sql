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
