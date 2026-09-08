-- Migration: 0176_payment_approval_binding_all_paths.sql
-- Workpacket: 602020
-- Runtime Gate RG-02 reopening: bind confirm_payment() to an existing,
-- structurally verified TOSS_PAYMENTS provider raw event.
-- Scope: catchmenu_payment.confirm_payment(...) only.

BEGIN;
CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_provider_type text, p_provider_approval_number text, p_provider_tx_id text, p_approved_amount integer, p_payment_method text, p_provider_response jsonb DEFAULT NULL::jsonb, p_actor_type text DEFAULT 'STAFF'::text, p_actor_id uuid DEFAULT NULL::uuid, p_locale text DEFAULT 'ko'::text, p_correlation_id text DEFAULT NULL::text, p_intent_id uuid DEFAULT NULL::uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'catchmenu_payment', 'catchmenu_pos', 'catchmenu_kds', 'catchmenu_ledger', 'catchmenu_audit', 'catchmenu_common', 'catchmenu_hq'
AS $function$
declare
  v_order record;
  v_ledger_id uuid;
  v_kds_result jsonb;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
  v_net_amount int;
  v_fee_amount int;
  v_intent_id uuid;
  v_provider_response_id uuid;
  v_gateway_provider_type text;
  v_actor_type text;
  v_row_count int;
  v_binding_intent record;
  v_raw_event record;
  v_raw_event_count int;
begin
  -- RG-01 tenant gate precedes every tenant-scoped read or mutation.
  perform catchmenu_common.assert_caller_tenant_scope(p_tenant_id);

  if p_intent_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_required'
    );
  end if;

  if p_provider_type <> 'TOSS_PAYMENTS' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_binding_unsupported',
      'provider_type', p_provider_type
    );
  end if;

  if trim(coalesce(p_provider_tx_id, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_payment_key_required'
    );
  end if;

  select id, tenant_id, store_id, order_id, session_id,
         provider_type, provider_order_id, requested_amount,
         payment_method, payment_channel,
         business_day, business_timezone
  into v_binding_intent
  from catchmenu_payment.payment_intents
  where id = p_intent_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and order_id = p_order_id
  for update;

  if v_binding_intent.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'payment_intent_binding_invalid'
    );
  end if;

  if v_binding_intent.provider_type <> 'TOSS_PAYMENTS' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_binding_unsupported',
      'provider_type', v_binding_intent.provider_type
    );
  end if;

  if v_binding_intent.requested_amount <> p_approved_amount then
    return jsonb_build_object(
      'success', false,
      'error_key', 'amount_mismatch',
      'requested_amount', v_binding_intent.requested_amount,
      'approved_amount', p_approved_amount
    );
  end if;

  select count(*)
  into v_raw_event_count
  from catchmenu_gateway.provider_raw_events
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and provider_type = 'TOSS_PAYMENTS'
    and provider_event_id = p_provider_tx_id;

  if v_raw_event_count = 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_scope_mismatch'
    );
  end if;

  if v_raw_event_count <> 1 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_ambiguous',
      'matched_count', v_raw_event_count
    );
  end if;

  select id, tenant_id, store_id,
         provider_type, provider_code,
         provider_event_id, provider_event_type,
         raw_payload, payload_hash,
         signature_verified, signature_verified_at,
         schema_validated, schema_validation_errors,
         processing_status
  into v_raw_event
  from catchmenu_gateway.provider_raw_events
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and provider_type = 'TOSS_PAYMENTS'
    and provider_event_id = p_provider_tx_id
  for share;

  if v_raw_event.provider_event_id is distinct from p_provider_tx_id
     or v_raw_event.signature_verified is distinct from true
     or v_raw_event.signature_verified_at is null
     or v_raw_event.schema_validated is distinct from true
     or v_raw_event.schema_validation_errors is not null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_verification_failed'
    );
  end if;

  if v_raw_event.provider_code <> 'TOSS'
     or v_raw_event.processing_status not in ('VALIDATING', 'ACCEPTED')
     or v_raw_event.raw_payload->>'paymentKey'
          is distinct from p_provider_tx_id
     or v_raw_event.raw_payload->>'orderId'
          is distinct from v_binding_intent.provider_order_id
     or v_raw_event.raw_payload->>'status' is distinct from 'DONE'
     or v_raw_event.raw_payload->>'totalAmount'
          is distinct from p_approved_amount::text
     or v_raw_event.raw_payload->>'approveNo'
          is distinct from p_provider_approval_number
     or v_raw_event.payload_hash is distinct from encode(
          extensions.digest(v_raw_event.raw_payload::text, 'sha256'),
          'hex'
        ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'provider_raw_event_payment_mismatch'
    );
  end if;

  v_provider_response_id := v_raw_event.id;
  v_actor_type := case
    when p_actor_type in (
      'SYSTEM',
      'AGENT',
      'STAFF',
      'MANAGER',
      'OWNER',
      'HQ_ADMIN',
      'CUSTOMER',
      'PROVIDER',
      'SCHEDULER'
    ) then p_actor_type
    when p_actor_type in (
      'PG_WEBHOOK',
      'POS_WEBHOOK',
      'VAN_WEBHOOK',
      'PROVIDER_WEBHOOK'
    ) then 'PROVIDER'
    else 'SYSTEM'
  end;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 멱등성 검사 (correlation_id 기반)
  if p_correlation_id is not null then
    select pl.id
    into v_ledger_id
    from catchmenu_payment.payment_ledger pl
    join catchmenu_pos.orders o
      on o.id = pl.order_id
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.provider_payment_key = p_provider_tx_id
      and pl.provider_type = p_provider_type
      and pl.ledger_status = 'APPROVED'
      and pl.order_id = p_order_id
    order by pl.approved_at desc
    limit 1;

    if v_ledger_id is not null then
      if exists (
        select 1
        from catchmenu_pos.orders
        where id = p_order_id
          and store_id = p_store_id
          and tenant_id = p_tenant_id
          and order_status = 'CONFIRMED'
      ) then
        return catchmenu_common.build_success_response(
          p_message_key := 'payment_already_confirmed_idempotent',
          p_data := jsonb_build_object(
            'ledger_id', v_ledger_id,
            'order_id', p_order_id,
            'already_confirmed', true
          ),
          p_locale := p_locale,
          p_correlation_id := p_correlation_id
        );
      end if;

      perform catchmenu_common.log_diagnostic(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_log_level := 'CRITICAL',
        p_log_domain := 'PAYMENT',
        p_log_event :=
          'payment_idempotency_violation',
        p_message :=
          'Duplicate payment confirmation attempt: '
          || p_provider_tx_id,
        p_rpc_name := 'confirm_payment',
        p_correlation_id := p_correlation_id,
        p_details := jsonb_build_object(
          'provider_tx_id', p_provider_tx_id,
          'provider_type', p_provider_type,
          'order_id', p_order_id,
          'existing_ledger_id', v_ledger_id
        )
      );

      return catchmenu_common.build_error_response(
        p_error_key := 'payment_already_confirmed',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_correlation_id := p_correlation_id,
        p_rpc_name := 'confirm_payment',
        p_order_id := p_order_id,
        p_payment_id := v_ledger_id
      );
    end if;
  end if;

  -- 주문 조회
  select id, order_number, order_status,
         order_type, final_amount, session_id,
         total_amount, discount_amount
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 이미 결제 완료
  if v_order.order_status = 'CONFIRMED' then
    select id
    into v_ledger_id
    from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
    order by approved_at desc
    limit 1;

    if v_ledger_id is not null then
      return catchmenu_common.build_success_response(
        p_message_key := 'payment_already_confirmed_idempotent',
        p_data := jsonb_build_object(
          'ledger_id', v_ledger_id,
          'order_id', p_order_id,
          'already_confirmed', true
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );
    end if;

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status in (
    'COOKING',
    'READY',
    'SERVED',
    'COMPLETED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  elsif v_order.order_status not in (
    'PENDING',
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'current_status', v_order.order_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;

  if v_order.order_status = 'PENDING' and exists (
    select 1 from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and ledger_status = 'APPROVED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id
    );
  end if;
  -- 금액 검증 (±10원 허용 오차)
  if abs(p_approved_amount - v_order.final_amount)
    > 10
  then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'PAYMENT',
      p_log_event := 'payment_amount_mismatch',
      p_message :=
        'Payment amount mismatch'
        || ' | order=' || v_order.final_amount
        || ' | approved=' || p_approved_amount,
      p_rpc_name := 'confirm_payment',
      p_details := jsonb_build_object(
        'order_amount', v_order.final_amount,
        'approved_amount', p_approved_amount,
        'diff', abs(
          p_approved_amount - v_order.final_amount
        )
      )
    );
  end if;

  -- 수수료 추정 (PG사별 기본 요율 적용)
  v_fee_amount := case p_provider_type
    when 'TOSS_PAYMENTS' then
      (p_approved_amount * 0.015)::int
    when 'NICE_VAN' then
      (p_approved_amount * 0.020)::int
    when 'KIS_VAN' then
      (p_approved_amount * 0.018)::int
    else
      (p_approved_amount * 0.015)::int
  end;
  v_net_amount := p_approved_amount;

  v_gateway_provider_type := case
    when p_provider_type in (
      'TOSS_POS',
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'PG_KAKAO',
      'PG_NAVER',
      'ALIPAY',
      'WECHAT_PAY',
      'SAMSUNG_PAY',
      'DELIVERY_BAEMIN',
      'DELIVERY_YOGIYO',
      'DELIVERY_COUPANG',
      'OKPOS',
      'KIOSK_VENDOR',
      'INTERNAL_AGENT',
      'OTHER'
    ) then p_provider_type
    else 'OTHER'
  end;

  -- The provider raw event was selected and structurally bound before any
  -- payment/order mutation. Never synthesize provider evidence from caller JSON.

  v_intent_id :=
    catchmenu_payment.resolve_or_create_payment_intent(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_requested_amount := p_approved_amount,
      p_payment_method := p_payment_method,
      p_payment_channel := 'STAFF_POS',
      p_provider_type := p_provider_type,
      p_intent_origin := case
        when p_intent_id is not null then
          'PREAUTHORIZED'
        else
          'POS_SYNTHESIZED'
      end,
      p_origin_reference := jsonb_build_object(
        'source', 'confirm_payment',
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number
      ),
      p_intent_id := p_intent_id,
      p_session_id := v_order.session_id,
      p_locale := p_locale
    );

  if v_intent_id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_intent_resolution_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;

  -- 결제 원장 기록 (Layer 1)
  if v_order.order_status in (
    'CANCELLED',
    'REFUNDED',
    'PARTIAL_REFUNDED'
  ) then
    insert into catchmenu_payment.payment_ledger (
      tenant_id, store_id,
      order_id, session_id,
      intent_id,
      ledger_entry_type,
      provider_type,
      provider_payment_key,
      provider_approval_number,
      provider_approved_at,
      provider_response_id,
      approved_amount, net_amount,
      ledger_status,
      approved_at,
      reconciliation_status,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      p_order_id, v_order.session_id,
      v_intent_id,
      'APPROVAL',
      p_provider_type,
      p_provider_tx_id,
      p_provider_approval_number,
      now(),
      v_provider_response_id,
      p_approved_amount, v_net_amount,
      'APPROVED',
      now(),
      'MANUAL_REVIEW',
      v_business_day, v_timezone
    )
    returning id into v_ledger_id;

    insert into catchmenu_payment.payment_events (
      tenant_id, store_id, order_id,
      intent_id, ledger_id,
      event_type, from_status, to_status,
      caused_by_type, caused_by_id,
      amount_at_event,
      provider_event_id,
      event_payload, correlation_id, occurred_at
    ) values (
      p_tenant_id, p_store_id, p_order_id,
      v_intent_id, v_ledger_id,
      'payment_approved',
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      p_approved_amount,
      p_provider_tx_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_correlation_id, now()
    );

    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, caused_by_id,
      event_payload,
      order_id, payment_id, correlation_id,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'payment',
      'payment_approved_after_order_cancelled', 1,
      'payment_ledger', v_ledger_id,
      v_order.order_status, 'APPROVED_MANUAL_REVIEW',
      v_actor_type, p_actor_id,
      jsonb_build_object(
        'reason', 'payment_approved_after_order_cancelled',
        'order_status', v_order.order_status,
        'provider_type', p_provider_type,
        'provider_tx_id', p_provider_tx_id,
        'provider_approval_number',
          p_provider_approval_number,
        'approved_amount', p_approved_amount,
        'reconciliation_status', 'MANUAL_REVIEW'
      ),
      p_order_id, v_ledger_id, p_correlation_id,
      v_business_day, v_timezone, now()
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_details := jsonb_build_object(
        'ledger_id', v_ledger_id,
        'order_id', p_order_id,
        'order_status', v_order.order_status,
        'reconciliation_status', 'MANUAL_REVIEW',
        'reason', 'payment_approved_after_order_cancelled'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, session_id,
    intent_id,
    ledger_entry_type,
    provider_type,
    provider_payment_key,
    provider_approval_number,
    provider_approved_at,
    provider_response_id,
    approved_amount, net_amount,
    ledger_status,
    approved_at,
    reconciliation_status,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_order_id, v_order.session_id,
    v_intent_id,
    'APPROVAL',
    p_provider_type,
    p_provider_tx_id,
    p_provider_approval_number,
    now(),
    v_provider_response_id,
    p_approved_amount, v_net_amount,
    'APPROVED',
    now(),
    'PENDING',
    v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- 주문 상태 CONFIRMED → PAID
  update catchmenu_pos.orders
  set
    order_status = case order_type
      when 'TABLE' then 'COOKING'
      else 'CONFIRMED'
    end,
    confirmed_at = now(),
    updated_at = now()
  where id = p_order_id
    and order_status = 'PENDING';

  get diagnostics v_row_count = row_count;

  if v_row_count = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_status_changed_concurrently',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_correlation_id := p_correlation_id,
      p_rpc_name := 'confirm_payment',
      p_order_id := p_order_id,
      p_payment_id := v_ledger_id
    );
  end if;

  -- ==========================================
  -- 특허2 핵심: KDS Late Binding 해제
  -- HOLD → COMMITTED (조리 시작 승인)
  -- ==========================================
  v_kds_result :=
    catchmenu_payment.release_kds_after_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_ledger_id := v_ledger_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'payment_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := v_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'payment_ledger',
    p_subject_id := v_ledger_id,
    p_decision := 'APPROVED',
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_released',
        (v_kds_result->>'success')::boolean
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'payment_confirmed', 1,
    'payment_ledger', v_ledger_id,
    'PENDING', 'APPROVED',
    v_actor_type, p_actor_id,
    jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'approved_amount', p_approved_amount,
      'net_amount', v_net_amount,
      'approval_number',
        p_provider_approval_number,
      'kds_tickets_released',
        v_kds_result->'data'->>'released_count',
      'audit_id', v_audit_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- Realtime → 직원 앱 결제 완료 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'payment_confirmed',
    p_payload := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'approved_amount', p_approved_amount,
      'provider_type', p_provider_type,
      'kds_released',
        (v_kds_result->>'success')::boolean
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'payment_confirmed',
    p_data := jsonb_build_object(
      'ledger_id', v_ledger_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'provider_type', p_provider_type,
      'provider_tx_id', p_provider_tx_id,
      'approval_number',
        p_provider_approval_number,
      'approved_amount', p_approved_amount,
      'fee_amount', v_fee_amount,
      'net_amount', v_net_amount,
      'audit_id', v_audit_id,
      'kds', v_kds_result->'data',
      'late_binding_note',
        catchmenu_common.get_message(
          'kds_late_binding_released',
          p_locale, null
        )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$function$;


COMMIT;
