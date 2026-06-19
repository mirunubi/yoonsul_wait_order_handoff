-- 0036_create_reconciliation_rpc.sql
-- Purpose: Reconciliation case creation and resolution RPCs.
--          create_reconciliation_case: opens mismatch case.
--          resolve_reconciliation_case: closes with resolution evidence.
--          run_layer1_reconciliation: internal vs PG/VAN comparison.
--          특허1 core: 금융권형 결제 대사 4단계.
-- Depends on: 0035_verify_schema.sql
-- Creates:
--   function catchmenu_payment.create_reconciliation_case(...)
--   function catchmenu_payment.resolve_reconciliation_case(...)
--   function catchmenu_payment.run_layer1_reconciliation(...)

create or replace function catchmenu_payment.create_reconciliation_case(
  p_tenant_id uuid,
  p_store_id uuid,
  p_case_type text,
  p_reconciliation_layer text,
  p_severity text default 'NORMAL',
  p_order_id uuid default null,
  p_ledger_id uuid default null,
  p_intent_id uuid default null,
  p_internal_amount int default null,
  p_provider_amount int default null,
  p_internal_status text default null,
  p_provider_status text default null,
  p_provider_type text default null,
  p_provider_payment_key text default null,
  p_provider_approval_number text default null,
  p_provider_raw_event_id uuid default null,
  p_detection_method text default 'SYSTEM_AUTO',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_ledger,
                  catchmenu_audit, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_case_id uuid;
  v_amount_diff int;
  v_business_day date;
  v_timezone text;
  v_requires_hq boolean;
  v_audit_id uuid;
begin
  -- store timezone
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- check for existing open case
  if exists (
    select 1
    from catchmenu_payment.reconciliation_cases
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and case_type = p_case_type
      and coalesce(order_id::text, '') =
          coalesce(p_order_id::text, '')
      and case_status not in ('RESOLVED', 'CLOSED', 'WRITTEN_OFF')
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'active_case_exists',
      'message', 'Open reconciliation case already exists for this order'
    );
  end if;

  -- calculate amount diff
  v_amount_diff := coalesce(p_internal_amount, 0)
    - coalesce(p_provider_amount, 0);

  -- determine if HQ review required
  v_requires_hq := (
    p_severity in ('CRITICAL')
    or p_case_type = 'TERMINAL_CONTAMINATION_SUSPECT'
    or abs(coalesce(v_amount_diff, 0)) > 100000
  );

  -- create reconciliation case
  insert into catchmenu_payment.reconciliation_cases (
    tenant_id, store_id,
    order_id, ledger_id, intent_id,
    case_type, case_status, severity,
    reconciliation_layer,
    internal_amount, provider_amount, amount_diff,
    internal_status, provider_status,
    provider_type, provider_payment_key,
    provider_approval_number,
    provider_raw_event_id,
    detected_at, detected_by,
    detection_method,
    requires_hq_review,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_order_id, p_ledger_id, p_intent_id,
    p_case_type, 'OPEN', p_severity,
    p_reconciliation_layer,
    p_internal_amount, p_provider_amount, v_amount_diff,
    p_internal_status, p_provider_status,
    p_provider_type, p_provider_payment_key,
    p_provider_approval_number,
    p_provider_raw_event_id,
    now(), 'SYSTEM',
    p_detection_method,
    v_requires_hq,
    p_correlation_id,
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul')
  )
  returning id into v_case_id;

  -- update payment_ledger reconciliation status
  if p_ledger_id is not null then
    update catchmenu_payment.payment_ledger
    set
      reconciliation_status = 'MISMATCH',
      reconciliation_checked_at = now(),
      reconciliation_mismatch_reason = p_case_type,
      updated_at = now()
    where id = p_ledger_id;
  end if;

  -- create exception in ledger
  perform catchmenu_ledger.create_exception(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_exception_domain := 'payment',
    p_exception_type := 'reconciliation_mismatch',
    p_exception_severity := p_severity,
    p_subject_type := 'reconciliation_case',
    p_subject_id := v_case_id,
    p_error_message := p_case_type,
    p_exception_payload := jsonb_build_object(
      'case_type', p_case_type,
      'amount_diff', v_amount_diff,
      'reconciliation_layer', p_reconciliation_layer
    ),
    p_requires_human_approval := v_requires_hq,
    p_correlation_id := p_correlation_id
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
    'payment', 'reconciliation_mismatch_detected', 1,
    'reconciliation_case', v_case_id,
    null, 'OPEN',
    'SYSTEM',
    jsonb_build_object(
      'case_type', p_case_type,
      'severity', p_severity,
      'amount_diff', v_amount_diff,
      'reconciliation_layer', p_reconciliation_layer,
      'requires_hq_review', v_requires_hq
    ),
    p_order_id, p_ledger_id,
    p_correlation_id,
    v_business_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'reconciliation_case_created',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'reconciliation_case',
    p_subject_id := v_case_id,
    p_decision := 'NOTED',
    p_decision_payload := jsonb_build_object(
      'case_type', p_case_type,
      'severity', p_severity,
      'amount_diff', v_amount_diff,
      'requires_hq_review', v_requires_hq
    ),
    p_order_id := p_order_id,
    p_payment_id := p_ledger_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := coalesce(v_timezone, 'Asia/Seoul')
  );

  return jsonb_build_object(
    'success', true,
    'case_id', v_case_id,
    'case_type', p_case_type,
    'case_status', 'OPEN',
    'severity', p_severity,
    'amount_diff', v_amount_diff,
    'requires_hq_review', v_requires_hq,
    'audit_id', v_audit_id,
    'message_code', 'reconciliation_case_created'
  );
end;
$$;


create or replace function catchmenu_payment.resolve_reconciliation_case(
  p_tenant_id uuid,
  p_store_id uuid,
  p_case_id uuid,
  p_resolution_type text,
  p_resolution_note text,
  p_resolved_by_type text,
  p_resolved_by_id uuid,
  p_recovery_amount int default null,
  p_write_off_amount int default null,
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
  v_case record;
  v_audit_id uuid;
begin
  if trim(coalesce(p_resolution_note, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'resolution_note_required'
    );
  end if;

  select id, case_type, case_status, severity,
         order_id, ledger_id, amount_diff,
         requires_hq_review,
         business_day, business_timezone
  into v_case
  from catchmenu_payment.reconciliation_cases
  where id = p_case_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_case.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'case_not_found'
    );
  end if;

  if v_case.case_status in ('RESOLVED', 'CLOSED', 'WRITTEN_OFF') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'case_already_resolved',
      'current_status', v_case.case_status
    );
  end if;

  -- HQ review required check
  if v_case.requires_hq_review
    and p_resolved_by_type not in ('HQ_ADMIN', 'SYSTEM')
  then
    return jsonb_build_object(
      'success', false,
      'error_key', 'hq_review_required',
      'message', 'This case requires HQ admin resolution'
    );
  end if;

  -- resolve case
  update catchmenu_payment.reconciliation_cases
  set
    case_status = case p_resolution_type
      when 'WRITE_OFF_APPROVED' then 'WRITTEN_OFF'
      else 'RESOLVED'
    end,
    resolution_type = p_resolution_type,
    resolution_note = p_resolution_note,
    resolved_by_type = p_resolved_by_type,
    resolved_by_id = p_resolved_by_id,
    resolved_at = now(),
    recovery_amount = p_recovery_amount,
    write_off_amount = p_write_off_amount,
    updated_at = now()
  where id = p_case_id;

  -- update payment_ledger reconciliation status
  if v_case.ledger_id is not null then
    update catchmenu_payment.payment_ledger
    set
      reconciliation_status = 'RESOLVED',
      reconciliation_checked_at = now(),
      updated_at = now()
    where id = v_case.ledger_id;
  end if;

  -- resolve related exception
  update catchmenu_ledger.exceptions
  set
    exception_status = 'RESOLVED',
    resolution_type = 'MANUAL_MANAGER',
    resolution_note = p_resolution_note,
    resolved_by_type = p_resolved_by_type,
    resolved_by_id = p_resolved_by_id,
    resolved_at = now(),
    updated_at = now()
  where subject_type = 'reconciliation_case'
    and subject_id = p_case_id
    and exception_status not in ('RESOLVED', 'CLOSED');

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
    'payment', 'reconciliation_resolved', 1,
    'reconciliation_case', p_case_id,
    v_case.case_status, 'RESOLVED',
    p_resolved_by_type, p_resolved_by_id,
    jsonb_build_object(
      'resolution_type', p_resolution_type,
      'resolution_note', p_resolution_note,
      'recovery_amount', p_recovery_amount,
      'write_off_amount', p_write_off_amount
    ),
    v_case.order_id, v_case.ledger_id,
    p_correlation_id,
    v_case.business_day, v_case.business_timezone, now()
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'reconciliation_case_resolved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_resolved_by_type,
    p_actor_id := p_resolved_by_id,
    p_subject_type := 'reconciliation_case',
    p_subject_id := p_case_id,
    p_decision := 'COMPLETED',
    p_decision_reason := p_resolution_note,
    p_decision_payload := jsonb_build_object(
      'resolution_type', p_resolution_type,
      'recovery_amount', p_recovery_amount,
      'write_off_amount', p_write_off_amount,
      'amount_diff', v_case.amount_diff
    ),
    p_before_state := jsonb_build_object(
      'case_status', v_case.case_status
    ),
    p_after_state := jsonb_build_object(
      'case_status', 'RESOLVED',
      'resolution_type', p_resolution_type
    ),
    p_order_id := v_case.order_id,
    p_payment_id := v_case.ledger_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_case.business_day,
    p_business_timezone := v_case.business_timezone
  );

  return jsonb_build_object(
    'success', true,
    'case_id', p_case_id,
    'case_status', case p_resolution_type
      when 'WRITE_OFF_APPROVED' then 'WRITTEN_OFF'
      else 'RESOLVED'
    end,
    'resolution_type', p_resolution_type,
    'recovery_amount', p_recovery_amount,
    'write_off_amount', p_write_off_amount,
    'audit_id', v_audit_id,
    'message_code', 'reconciliation_case_resolved'
  );
end;
$$;


create or replace function catchmenu_payment.run_layer1_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_integrations,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_timezone text;
  v_target_day date;
  v_matched int := 0;
  v_mismatch int := 0;
  v_missing_provider int := 0;
  v_missing_internal int := 0;
  v_case_id uuid;
  v_rec record;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_day := coalesce(
    p_business_day,
    (timezone(coalesce(v_timezone, 'Asia/Seoul'), now()))::date
  );

  -- Layer 1: Internal ledger vs Toss payments
  -- 특허1: 내부 승인 원장 ↔ 외부 PG/VAN 원장 1차 대사
  for v_rec in
    select
      pl.id as ledger_id,
      pl.order_id,
      pl.approved_amount as internal_amount,
      pl.ledger_status as internal_status,
      pl.provider_payment_key,
      tp.approved_amount as provider_amount,
      tp.toss_status as provider_status,
      tp.id as toss_id
    from catchmenu_payment.payment_ledger pl
    left join catchmenu_integrations.toss_payments tp
      on tp.ledger_id = pl.id
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day = v_target_day
      and pl.reconciliation_status = 'PENDING'
  loop
    if v_rec.toss_id is null then
      -- missing provider record
      v_missing_provider := v_missing_provider + 1;
      perform catchmenu_payment.create_reconciliation_case(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_case_type := 'MISSING_PROVIDER_EVENT',
        p_reconciliation_layer := 'LAYER_1_INTERNAL_VS_PG',
        p_severity := 'HIGH',
        p_order_id := v_rec.order_id,
        p_ledger_id := v_rec.ledger_id,
        p_internal_amount := v_rec.internal_amount,
        p_internal_status := v_rec.internal_status,
        p_provider_type := 'TOSS_PAYMENTS',
        p_provider_payment_key := v_rec.provider_payment_key,
        p_detection_method := 'LAYER_1_AUTO',
        p_correlation_id := p_correlation_id
      );

    elsif v_rec.internal_amount <> coalesce(v_rec.provider_amount, 0) then
      -- amount mismatch
      v_mismatch := v_mismatch + 1;
      perform catchmenu_payment.create_reconciliation_case(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_case_type := 'AMOUNT_MISMATCH',
        p_reconciliation_layer := 'LAYER_1_INTERNAL_VS_PG',
        p_severity := 'CRITICAL',
        p_order_id := v_rec.order_id,
        p_ledger_id := v_rec.ledger_id,
        p_internal_amount := v_rec.internal_amount,
        p_provider_amount := v_rec.provider_amount,
        p_internal_status := v_rec.internal_status,
        p_provider_status := v_rec.provider_status,
        p_provider_type := 'TOSS_PAYMENTS',
        p_provider_payment_key := v_rec.provider_payment_key,
        p_detection_method := 'LAYER_1_AUTO',
        p_correlation_id := p_correlation_id
      );

    else
      -- matched — update ledger
      v_matched := v_matched + 1;
      update catchmenu_payment.payment_ledger
      set
        reconciliation_status = 'MATCHED',
        reconciliation_checked_at = now(),
        updated_at = now()
      where id = v_rec.ledger_id;
    end if;
  end loop;

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
    'payment', 'reconciliation_layer1_completed', 1,
    'store', p_store_id,
    null, 'LAYER_1_COMPLETED',
    'SYSTEM',
    jsonb_build_object(
      'target_day', v_target_day,
      'matched', v_matched,
      'mismatch', v_mismatch,
      'missing_provider', v_missing_provider,
      'missing_internal', v_missing_internal
    ),
    p_correlation_id,
    v_target_day,
    coalesce(v_timezone, 'Asia/Seoul'),
    now()
  );

  return jsonb_build_object(
    'success', true,
    'reconciliation_layer', 'LAYER_1_INTERNAL_VS_PG',
    'target_day', v_target_day,
    'matched', v_matched,
    'mismatch', v_mismatch,
    'missing_provider', v_missing_provider,
    'total_processed', v_matched + v_mismatch + v_missing_provider,
    'cases_created', v_mismatch + v_missing_provider,
    'message_code', 'layer1_reconciliation_completed'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_payment.create_reconciliation_case(
    uuid, uuid, text, text, text, uuid, uuid, uuid,
    int, int, text, text, text, text, text, uuid, text, text
  ) from public;
  grant execute on function catchmenu_payment.create_reconciliation_case(
    uuid, uuid, text, text, text, uuid, uuid, uuid,
    int, int, text, text, text, text, text, uuid, text, text
  ) to authenticated;

  revoke all on function catchmenu_payment.resolve_reconciliation_case(
    uuid, uuid, uuid, text, text, text, uuid, int, int, text
  ) from public;
  grant execute on function catchmenu_payment.resolve_reconciliation_case(
    uuid, uuid, uuid, text, text, text, uuid, int, int, text
  ) to authenticated;

  revoke all on function catchmenu_payment.run_layer1_reconciliation(
    uuid, uuid, date, text
  ) from public;
  grant execute on function catchmenu_payment.run_layer1_reconciliation(
    uuid, uuid, date, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_payment.create_reconciliation_case(
  uuid, uuid, text, text, text, uuid, uuid, uuid,
  int, int, text, text, text, text, text, uuid, text, text
) is
  'Creates payment reconciliation case for detected mismatch.
   Automatically determines HQ review requirement based on severity.
   Updates payment_ledger reconciliation_status to MISMATCH.
   Creates exception in ledger for monitoring and Knowledge Gap detection.
   특허1: 금융권형 결제 대사 — 불일치 케이스 자동 생성.';

comment on function catchmenu_payment.run_layer1_reconciliation(
  uuid, uuid, date, text
) is
  'Runs Layer 1 reconciliation: internal payment_ledger vs Toss payments.
   Detects amount mismatches and missing provider records.
   Updates matched records status to MATCHED.
   Creates reconciliation cases for mismatches.
   특허1 Layer 1: 내부 승인 원장 ↔ 외부 PG/VAN 원장 1차 대사.
   승인 누락 / 중복 승인 / 금액 불일치 자동 탐지.';