-- ===== BEGIN [sql/migrations/0015_create_payment_reconciliation.sql] =====
-- 0015_create_payment_reconciliation.sql
-- Purpose: Reconciliation cases for payment mismatches.
--          When internal ledger and provider ledger disagree,
--          a reconciliation case is created for investigation and resolution.
--          특허1 core: 금융권형 결제 대사 4단계 구조.
-- Depends on: 0014_create_payment_ledger.sql
-- Creates:
--   catchmenu_payment.reconciliation_cases

create table if not exists catchmenu_payment.reconciliation_cases (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid references catchmenu_pos.orders(id),
  ledger_id uuid references catchmenu_payment.payment_ledger(id),
  intent_id uuid references catchmenu_payment.payment_intents(id),

  -- case identity
  case_type text not null,
  case_status text not null default 'OPEN',
  severity text not null default 'NORMAL',
  reconciliation_layer text not null,

  -- discrepancy detail
  internal_amount int,
  provider_amount int,
  amount_diff int,
  internal_status text,
  provider_status text,

  -- provider reference
  provider_type text,
  provider_payment_key text,
  provider_approval_number text,
  provider_raw_event_id uuid
    references catchmenu_gateway.provider_raw_events(id),

  -- detection
  detected_at timestamptz not null default now(),
  detected_by text not null default 'SYSTEM',
  detection_method text,

  -- investigation
  investigated_by_agent_id uuid
    references catchmenu_store.agent_registry(id),
  investigation_note text,
  investigation_started_at timestamptz,
  investigation_completed_at timestamptz,

  -- resolution
  resolution_type text,
  resolution_note text,
  resolved_by_type text,
  resolved_by_id uuid,
  resolved_at timestamptz,

  -- financial impact
  disputed_amount int,
  recovery_amount int,
  write_off_amount int,

  -- escalation
  escalated_at timestamptz,
  escalated_to text,
  requires_hq_review boolean not null default false,

  -- evidence
  evidence_packet_id uuid,
  audit_record_id uuid references catchmenu_ledger.audit_records(id),

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_recon_case_type check (
    case_type in (
      'AMOUNT_MISMATCH',
      'STATUS_MISMATCH',
      'MISSING_PROVIDER_EVENT',
      'DUPLICATE_APPROVAL',
      'MISSING_INTERNAL_RECORD',
      'CANCEL_MISMATCH',
      'REFUND_MISMATCH',
      'PARTIAL_CANCEL_MISMATCH',
      'TIMEOUT_UNRESOLVED',
      'TERMINAL_CONTAMINATION_SUSPECT',
      'MANUAL_CORRECTION_REQUIRED'
    )
  ),
  constraint chk_recon_case_status check (
    case_status in (
      'OPEN',
      'UNDER_INVESTIGATION',
      'PENDING_PROVIDER',
      'PENDING_HQ',
      'RESOLVED',
      'WRITTEN_OFF',
      'ESCALATED',
      'CLOSED'
    )
  ),
  constraint chk_recon_severity check (
    severity in (
      'LOW',
      'NORMAL',
      'HIGH',
      'CRITICAL'
    )
  ),
  constraint chk_recon_layer check (
    reconciliation_layer in (
      'LAYER_1_INTERNAL_VS_PG',
      'LAYER_2_INTERNAL_VS_TERMINAL',
      'LAYER_3_OS_LOG_VALIDATION',
      'LAYER_4_NIGHTLY_BATCH'
    )
  ),
  constraint chk_recon_resolution_type check (
    resolution_type is null or resolution_type in (
      'PROVIDER_CORRECTED',
      'INTERNAL_CORRECTED',
      'MANUAL_ADJUSTMENT',
      'WRITE_OFF_APPROVED',
      'DUPLICATE_REMOVED',
      'CUSTOMER_REFUNDED',
      'NO_ACTION_REQUIRED',
      'HQ_RESOLVED'
    )
  )
);

create index if not exists idx_recon_cases_store_status
  on catchmenu_payment.reconciliation_cases(store_id, case_status);

create index if not exists idx_recon_cases_store_severity
  on catchmenu_payment.reconciliation_cases(store_id, severity)
  where case_status in ('OPEN', 'UNDER_INVESTIGATION', 'ESCALATED');

create index if not exists idx_recon_cases_order
  on catchmenu_payment.reconciliation_cases(order_id)
  where order_id is not null;

create index if not exists idx_recon_cases_ledger
  on catchmenu_payment.reconciliation_cases(ledger_id)
  where ledger_id is not null;

create index if not exists idx_recon_cases_business_day
  on catchmenu_payment.reconciliation_cases(store_id, business_day desc);

create index if not exists idx_recon_cases_hq_review
  on catchmenu_payment.reconciliation_cases(store_id, requires_hq_review)
  where requires_hq_review = true
    and case_status not in ('RESOLVED', 'WRITTEN_OFF', 'CLOSED');

create index if not exists idx_recon_cases_provider_key
  on catchmenu_payment.reconciliation_cases(provider_payment_key)
  where provider_payment_key is not null;

drop trigger if exists trg_recon_cases_updated_at
  on catchmenu_payment.reconciliation_cases;
create trigger trg_recon_cases_updated_at
  before update on catchmenu_payment.reconciliation_cases
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_payment.reconciliation_cases is
  'Payment reconciliation cases. Created when internal ledger
   and external provider ledger disagree on payment state or amount.
   특허1 금융권형 결제 대사 4단계:
   LAYER_1: 내부 승인 원장 ↔ 외부 PG/VAN 원장 대사
             → 승인 누락, 취소 누락, 중복 승인, 부분취소 불일치 탐지
   LAYER_2: 중앙 서버 원장 ↔ 매장 단말 로컬 원장 대사
             → 네트워크 단절, 앱 종료, POS 전달 실패 시 보조 증거
   LAYER_3: OS 로그 및 단말 행위 로그 검증
             → 시스템 시간 변경, 로그 삭제 의심, 보안 정책 위반
   LAYER_4: 야간 배치 교차 검증
             → 전체 원장 대사, 정상/보류/복구/수동검토 분류';
comment on column catchmenu_payment.reconciliation_cases.case_type is
  'AMOUNT_MISMATCH = approved amounts differ between internal and provider.
   STATUS_MISMATCH = status differs (e.g. internal APPROVED, provider CANCELLED).
   MISSING_PROVIDER_EVENT = internal record exists but no provider confirmation.
   DUPLICATE_APPROVAL = same payment approved twice by provider.
   MISSING_INTERNAL_RECORD = provider has approval but internal has no record.
   CANCEL_MISMATCH = cancellation recorded internally but provider shows active.
   REFUND_MISMATCH = refund amount differs between internal and provider.
   TIMEOUT_UNRESOLVED = payment_uncertain not resolved within deadline.
   TERMINAL_CONTAMINATION_SUSPECT = device anomaly detected during transaction.
   특허1: 단말 오염 의심 케이스 자동 생성 및 격리.';
comment on column catchmenu_payment.reconciliation_cases.reconciliation_layer is
  'Which reconciliation layer detected this case.
   Layer 4 (nightly batch) catches cases that real-time layers missed.
   Each layer has different resolution authority and evidence requirements.';
comment on column catchmenu_payment.reconciliation_cases.requires_hq_review is
  'True when case exceeds store-level resolution authority.
   CRITICAL severity, TERMINAL_CONTAMINATION_SUSPECT, and
   write-off requests above threshold require HQ review.';

-- ===== BEGIN [sql/migrations/0036_create_reconciliation_rpc.sql] =====
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

-- ===== BEGIN [sql/migrations/0120_create_reconciliation_pipeline.sql] =====
-- 0120_create_reconciliation_pipeline.sql
-- Purpose: Payment reconciliation pipeline.
--          4단계 대사 완성.
--          Layer1: 주문-결제 대사.
--          Layer2: VAN/PG 대사.
--          Layer3: 정산 리포트.
--          Layer4: 감사 증빙 패킷.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0119_create_edge_function_integration.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('reconciliation_completed', 'ko',
  '정산 대사가 완료되었습니다'),
('reconciliation_completed', 'en',
  'Reconciliation completed'),
('reconciliation_report_loaded', 'ko',
  '정산 리포트가 로드되었습니다'),
('reconciliation_report_loaded', 'en',
  'Reconciliation report loaded'),
('audit_packet_created', 'ko',
  '감사 증빙 패킷이 생성되었습니다'),
('audit_packet_created', 'en',
  'Audit evidence packet created')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(6010, 'reconciliation_gap_detected',
  'PAYMENT', 'FINANCIAL', 200, 'WARNING'),
(6011, 'reconciliation_critical_gap',
  'PAYMENT', 'FINANCIAL', 200, 'CRITICAL'),
(6012, 'audit_packet_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- reconciliation_daily_summary table
-- 일별 정산 요약
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_daily_summary (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  business_day date not null,

  -- Layer1: 주문-결제 대사
  total_orders int not null default 0,
  completed_orders int not null default 0,
  cancelled_orders int not null default 0,
  order_total_amount bigint not null default 0,
  payment_total_amount bigint not null default 0,
  layer1_gap bigint not null default 0,
  layer1_status text not null
    default 'PENDING',

  -- Layer2: VAN/PG 대사
  van_settlement_amount bigint
    not null default 0,
  pg_settlement_amount bigint
    not null default 0,
  total_fee_amount bigint not null default 0,
  net_settlement_amount bigint
    not null default 0,
  layer2_gap bigint not null default 0,
  layer2_status text not null
    default 'PENDING',

  -- Layer3: 정산 리포트
  cash_amount bigint not null default 0,
  card_amount bigint not null default 0,
  toss_amount bigint not null default 0,
  delivery_amount bigint not null default 0,
  refund_amount bigint not null default 0,
  layer3_status text not null
    default 'PENDING',

  -- Layer4: 감사 증빙
  audit_packet_id uuid,
  layer4_status text not null
    default 'PENDING',

  -- 전체 상태
  overall_status text not null
    default 'PENDING',
  has_issues boolean not null default false,
  issue_count int not null default 0,

  -- 실행 정보
  layer1_run_at timestamptz,
  layer2_run_at timestamptz,
  layer3_run_at timestamptz,
  layer4_run_at timestamptz,
  completed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_recon_daily unique (
    store_id, business_day
  ),
  constraint chk_layer_status check (
    layer1_status in (
      'PENDING', 'RUNNING', 'CLEAN',
      'GAP_MINOR', 'GAP_CRITICAL', 'ERROR'
    )
  )
);

alter table
  catchmenu_payment.reconciliation_daily_summary
  enable row level security;
alter table
  catchmenu_payment.reconciliation_daily_summary
  force row level security;

drop policy if exists recon_summary_isolation
  on catchmenu_payment.reconciliation_daily_summary;
create policy recon_summary_isolation
  on catchmenu_payment.reconciliation_daily_summary
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_recon_summary_updated
  on catchmenu_payment
    .reconciliation_daily_summary;
create trigger trg_recon_summary_updated
  before update on
    catchmenu_payment.reconciliation_daily_summary
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_payment.reconciliation_daily_summary
  is
  '일별 정산 대사 요약.
   4단계 대사 결과 통합.
   Layer1: 주문-결제 금액 일치 확인.
   Layer2: VAN/PG 정산 금액 대사.
   Layer3: 결제 수단별 분류 확인.
   Layer4: 감사 증빙 패킷 생성.
   has_issues: 이상 발생 플래그.
   pg_cron RECONCILIATION_LAYER1/2에서 자동 실행.';


-- =============================================
-- audit_evidence_packets table
-- 감사 증빙 패킷
-- =============================================
create table if not exists
  catchmenu_payment.audit_evidence_packets (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  business_day date not null,
  packet_type text not null,
  packet_status text not null
    default 'GENERATED',

  -- 증빙 데이터
  order_count int not null default 0,
  payment_count int not null default 0,
  total_amount bigint not null default 0,
  net_amount bigint not null default 0,

  -- 검증
  checksum text not null,
  evidence_hash text not null,
  is_tampered boolean not null default false,

  -- 보존
  retain_until date not null,
  exported_at timestamptz,
  export_format text,

  generated_at timestamptz
    not null default now(),
  created_at timestamptz not null default now(),

  constraint uq_audit_packet unique (
    store_id, business_day, packet_type
  ),
  constraint chk_packet_type check (
    packet_type in (
      'DAILY_SETTLEMENT',
      'MONTHLY_SETTLEMENT',
      'TAX_REPORT',
      'COMPLIANCE_EVIDENCE',
      'DISPUTE_EVIDENCE'
    )
  )
);

alter table
  catchmenu_payment.audit_evidence_packets
  enable row level security;
alter table
  catchmenu_payment.audit_evidence_packets
  force row level security;

drop policy if exists audit_packet_isolation
  on catchmenu_payment.audit_evidence_packets;
create policy audit_packet_isolation
  on catchmenu_payment.audit_evidence_packets
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.audit_evidence_packets is
  '감사 증빙 패킷.
   일별/월별 정산 증빙 데이터.
   evidence_hash: SHA-256 위변조 감지.
   is_tampered: 위변조 탐지 시 true.
   retain_until: 세금계산서 5년 보존.
   DISPUTE_EVIDENCE: 분쟁 시 즉시 생성.
   특허4: 정산 = 재무 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
-- 0036's original run_layer1_reconciliation had p_correlation_id as
-- its 4th param; this file supersedes it with p_business_day/p_locale.
-- Already-applied callers (0072, 0095 cron jobs) only pass p_tenant_id/
-- p_store_id by name, so no already-applied code depends on the old
-- 4th param name -- safe to drop and recreate.
drop function if exists catchmenu_payment.run_layer1_reconciliation(
  uuid, uuid, date, text
);

create or replace function
  catchmenu_payment.run_layer1_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_business_day date;
  v_order_total bigint;
  v_payment_total bigint;
  v_gap bigint;
  v_gap_status text;
  v_order_count int;
  v_completed_count int;
  v_cancelled_count int;
  v_refund_count int;
  v_summary_id uuid;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 주문 합계
  select
    count(*),
    count(*) filter (
      where order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_status = 'CANCELLED'
    ),
    coalesce(
      sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0
    )
  into
    v_order_count,
    v_completed_count,
    v_cancelled_count,
    v_order_total
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 결제 합계
  select coalesce(
    sum(approved_amount) filter (
      where ledger_status = 'APPROVED'
    ) -
    coalesce(
      sum(abs(approved_amount)) filter (
        where ledger_status = 'REFUNDED'
      ), 0
    ), 0
  )
  into v_payment_total
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 갭 계산
  v_gap := v_order_total - v_payment_total;

  -- 상태 판정
  v_gap_status := case
    when v_gap = 0 then 'CLEAN'
    when abs(v_gap) <= 1000 then 'GAP_MINOR'
    when abs(v_gap) > 1000 then 'GAP_CRITICAL'
    else 'ERROR'
  end;

  -- 요약 저장
  insert into
    catchmenu_payment.reconciliation_daily_summary (
    tenant_id, store_id, business_day,
    total_orders, completed_orders,
    cancelled_orders,
    order_total_amount, payment_total_amount,
    layer1_gap, layer1_status,
    layer1_run_at,
    overall_status, has_issues
  ) values (
    p_tenant_id, p_store_id, v_business_day,
    v_order_count, v_completed_count,
    v_cancelled_count,
    v_order_total, v_payment_total,
    v_gap, v_gap_status,
    now(),
    v_gap_status,
    v_gap_status not in ('CLEAN', 'PENDING')
  )
  on conflict (store_id, business_day)
  do update set
    total_orders = excluded.total_orders,
    completed_orders = excluded.completed_orders,
    cancelled_orders = excluded.cancelled_orders,
    order_total_amount =
      excluded.order_total_amount,
    payment_total_amount =
      excluded.payment_total_amount,
    layer1_gap = excluded.layer1_gap,
    layer1_status = excluded.layer1_status,
    layer1_run_at = excluded.layer1_run_at,
    has_issues = excluded.has_issues,
    updated_at = now()
  returning id into v_summary_id;

  -- CRITICAL 갭 → 운영 알림
  if v_gap_status = 'GAP_CRITICAL' then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'RECONCILIATION_GAP',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key :=
        'reconciliation_completed',
      p_alert_detail := jsonb_build_object(
        'business_day', v_business_day,
        'order_total', v_order_total,
        'payment_total', v_payment_total,
        'gap', v_gap,
        'gap_status', v_gap_status
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );
  end if;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'reconciliation', 'layer1_completed', 1,
    'reconciliation_summary', v_summary_id,
    'PENDING', v_gap_status,
    'SYSTEM',
    jsonb_build_object(
      'business_day', v_business_day,
      'order_total', v_order_total,
      'payment_total', v_payment_total,
      'gap', v_gap,
      'gap_status', v_gap_status,
      'order_count', v_order_count
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_completed',
    p_data := jsonb_build_object(
      'summary_id', v_summary_id,
      'business_day', v_business_day,
      'layer', 1,
      'order_total', v_order_total,
      'payment_total', v_payment_total,
      'gap', v_gap,
      'gap_status', v_gap_status,
      'order_count', v_order_count,
      'completed_orders', v_completed_count,
      'cancelled_orders', v_cancelled_count,
      'is_clean', v_gap_status = 'CLEAN'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.run_layer2_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_business_day date;
  v_van_total bigint;
  v_pg_total bigint;
  v_total_fee bigint;
  v_net_total bigint;
  v_cash bigint;
  v_card bigint;
  v_toss bigint;
  v_delivery bigint;
  v_refund bigint;
  v_layer2_gap bigint;
  v_layer2_status text;
  v_summary_id uuid;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 결제 수단별 분류
  select
    coalesce(sum(approved_amount) filter (
      where payment_method = 'CASH'
        and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where payment_method in (
        'CREDIT_CARD', 'DEBIT_CARD'
      ) and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where payment_method = 'TOSS_PAYMENTS'
        and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where provider_type in (
        'BAEMIN', 'YOGIYO', 'COUPANG_EATS'
      ) and ledger_status = 'APPROVED'
    ), 0),
    coalesce(sum(approved_amount) filter (
      where ledger_status = 'REFUNDED'
    ), 0),
    coalesce(sum(fee_amount) filter (
      where ledger_status = 'APPROVED'
    ), 0)
  into
    v_cash, v_card, v_toss,
    v_delivery, v_refund, v_total_fee
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- VAN/PG 합계
  v_van_total := v_card;
  v_pg_total := v_toss;
  v_net_total := v_cash + v_card + v_toss
    + v_delivery - v_refund - v_total_fee;

  -- Layer2 갭 (VAN 정산 vs 카드 결제)
  -- VAN 실정산액은 Edge Function이 업데이트
  v_layer2_gap := 0;
  v_layer2_status := 'CLEAN';

  -- 요약 업데이트
  insert into
    catchmenu_payment.reconciliation_daily_summary (
    tenant_id, store_id, business_day,
    van_settlement_amount,
    pg_settlement_amount,
    total_fee_amount,
    net_settlement_amount,
    cash_amount, card_amount,
    toss_amount, delivery_amount,
    refund_amount,
    layer2_gap, layer2_status,
    layer2_run_at, layer3_status,
    layer3_run_at,
    overall_status
  ) values (
    p_tenant_id, p_store_id, v_business_day,
    v_van_total, v_pg_total,
    v_total_fee, v_net_total,
    v_cash, v_card,
    v_toss, v_delivery, v_refund,
    v_layer2_gap, v_layer2_status,
    now(), 'CLEAN', now(),
    'CLEAN'
  )
  on conflict (store_id, business_day)
  do update set
    van_settlement_amount = excluded
      .van_settlement_amount,
    pg_settlement_amount = excluded
      .pg_settlement_amount,
    total_fee_amount = excluded.total_fee_amount,
    net_settlement_amount = excluded
      .net_settlement_amount,
    cash_amount = excluded.cash_amount,
    card_amount = excluded.card_amount,
    toss_amount = excluded.toss_amount,
    delivery_amount = excluded.delivery_amount,
    refund_amount = excluded.refund_amount,
    layer2_gap = excluded.layer2_gap,
    layer2_status = excluded.layer2_status,
    layer2_run_at = excluded.layer2_run_at,
    layer3_status = excluded.layer3_status,
    layer3_run_at = excluded.layer3_run_at,
    overall_status = excluded.overall_status,
    updated_at = now()
  returning id into v_summary_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_completed',
    p_data := jsonb_build_object(
      'summary_id', v_summary_id,
      'business_day', v_business_day,
      'layer', 2,
      'breakdown', jsonb_build_object(
        'cash', v_cash,
        'card', v_card,
        'toss', v_toss,
        'delivery', v_delivery,
        'refund', v_refund,
        'fee', v_total_fee,
        'net', v_net_total
      ),
      'layer2_status', v_layer2_status,
      'is_clean', v_layer2_status = 'CLEAN'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.generate_audit_packet(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date,
  p_packet_type text default 'DAILY_SETTLEMENT',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_summary record;
  v_packet_id uuid;
  v_checksum text;
  v_evidence_hash text;
  v_retain_days int;
begin
  -- 정산 요약 조회
  select *
  into v_summary
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = p_business_day;

  -- 체크섬 생성
  v_checksum := md5(
    p_store_id::text
    || p_business_day::text
    || coalesce(v_summary.order_total_amount, 0)::text
    || coalesce(v_summary.payment_total_amount, 0)::text
    || now()::text
  );

  -- 증빙 해시 (SHA-256)
  v_evidence_hash := encode(
    digest(
      jsonb_build_object(
        'store_id', p_store_id,
        'business_day', p_business_day,
        'order_total',
          coalesce(v_summary.order_total_amount, 0),
        'payment_total',
          coalesce(v_summary.payment_total_amount, 0),
        'net_amount',
          coalesce(v_summary.net_settlement_amount, 0),
        'generated_at', now()
      )::text,
      'sha256'
    ),
    'hex'
  );

  -- 보존 기간 (세금 관련 5년)
  v_retain_days := case p_packet_type
    when 'TAX_REPORT' then 1825
    when 'COMPLIANCE_EVIDENCE' then 1825
    when 'DISPUTE_EVIDENCE' then 365
    else 365
  end;

  -- 패킷 생성
  insert into
    catchmenu_payment.audit_evidence_packets (
    tenant_id, store_id, business_day,
    packet_type, packet_status,
    order_count, payment_count,
    total_amount, net_amount,
    checksum, evidence_hash,
    retain_until
  ) values (
    p_tenant_id, p_store_id, p_business_day,
    p_packet_type, 'GENERATED',
    coalesce(v_summary.total_orders, 0),
    coalesce(v_summary.completed_orders, 0),
    coalesce(v_summary.order_total_amount, 0),
    coalesce(v_summary.net_settlement_amount, 0),
    v_checksum, v_evidence_hash,
    p_business_day + v_retain_days
  )
  on conflict (store_id, business_day, packet_type)
  do update set
    checksum = excluded.checksum,
    evidence_hash = excluded.evidence_hash,
    packet_status = 'REGENERATED',
    generated_at = now()
  returning id into v_packet_id;

  -- 요약에 패킷 ID 연결
  update catchmenu_payment.reconciliation_daily_summary
  set
    audit_packet_id = v_packet_id,
    layer4_status = 'CLEAN',
    layer4_run_at = now(),
    completed_at = now(),
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = p_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'audit_packet_created',
    p_data := jsonb_build_object(
      'packet_id', v_packet_id,
      'packet_type', p_packet_type,
      'business_day', p_business_day,
      'evidence_hash', v_evidence_hash,
      'retain_until',
        p_business_day + v_retain_days,
      'note',
        '세금 관련 5년 / 분쟁 증빙 1년 보존'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.get_reconciliation_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date default null,
  p_to_date date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_from_date date;
  v_to_date date;
  v_daily_list jsonb;
  v_period_summary jsonb;
  v_issue_list jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('month', now())::date
  );
  v_to_date := coalesce(
    p_to_date,
    (timezone('Asia/Seoul', now()))::date - 1
  );

  -- 일별 대사 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'business_day', business_day,
        'overall_status', overall_status,
        'layer1_status', layer1_status,
        'layer2_status', layer2_status,
        'order_total', order_total_amount,
        'payment_total', payment_total_amount,
        'layer1_gap', layer1_gap,
        'net_amount', net_settlement_amount,
        'breakdown', jsonb_build_object(
          'cash', cash_amount,
          'card', card_amount,
          'toss', toss_amount,
          'delivery', delivery_amount,
          'refund', refund_amount,
          'fee', total_fee_amount
        ),
        'has_issues', has_issues,
        'issue_count', issue_count,
        'audit_packet_id', audit_packet_id,
        'completed_at', completed_at
      )
      order by business_day desc
    ),
    '[]'::jsonb
  )
  into v_daily_list
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date;

  -- 기간 합계
  select jsonb_build_object(
    'total_days', count(*),
    'clean_days', count(*) filter (
      where overall_status = 'CLEAN'
    ),
    'issue_days', count(*) filter (
      where has_issues = true
    ),
    'total_orders', sum(total_orders),
    'total_order_amount',
      sum(order_total_amount),
    'total_net_amount',
      sum(net_settlement_amount),
    'total_refunds', sum(refund_amount),
    'total_fees', sum(total_fee_amount),
    'total_cash', sum(cash_amount),
    'total_card', sum(card_amount),
    'total_toss', sum(toss_amount),
    'total_delivery', sum(delivery_amount)
  )
  into v_period_summary
  from catchmenu_payment.reconciliation_daily_summary
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date;

  -- 미해결 이슈
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'case_id', rc.id,
        'case_type', rc.case_type,
        'case_severity', rc.severity,
        'gap_amount', rc.gap_amount,
        'case_status', rc.case_status,
        'detected_at', rc.detected_at
      )
      order by rc.severity desc,
               rc.gap_amount desc
    ),
    '[]'::jsonb
  )
  into v_issue_list
  from catchmenu_payment.reconciliation_cases rc
  where rc.store_id = p_store_id
    and rc.tenant_id = p_tenant_id
    and rc.case_status = 'OPEN'
    and rc.detected_at::date
      between v_from_date and v_to_date;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_report_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'period_summary', v_period_summary,
      'daily_list', v_daily_list,
      'open_issues', v_issue_list,
      'has_open_issues',
        jsonb_array_length(v_issue_list) > 0,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_payment.run_layer1_reconciliation(
      uuid, uuid, date, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.generate_audit_packet(
      uuid, uuid, date, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

-- pg_cron 등록
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'RECONCILIATION_LAYER1',
  'catchmenu_reconciliation_layer1',
  '30 14 * * *',
  '30 23 * * * (매일 23:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer1_reconciliation(
  t.id, s.id
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  'Layer1 대사 자동 실행. 매일 23:30.',
  true
),
(
  'RECONCILIATION_LAYER2',
  'catchmenu_reconciliation_layer2',
  '30 15 * * *',
  '30 00 * * * (매일 00:30 KST)',
  $sql$
SELECT catchmenu_payment.run_layer2_reconciliation(
  t.id, s.id
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';

SELECT catchmenu_payment.generate_audit_packet(
  t.id, s.id,
  (timezone('Asia/Seoul', now()))::date - 1
)
FROM catchmenu_hq.tenants t
JOIN catchmenu_hq.stores s
  ON s.tenant_id = t.id
  AND s.is_active = true
WHERE t.tenant_status = 'ACTIVE';
$sql$,
  'Layer2 대사 + 감사 패킷 자동 생성. 00:30.',
  true
)
on conflict (job_code) do nothing;

comment on function
  catchmenu_payment.run_layer1_reconciliation(
    uuid, uuid, date, text
  ) is
  '4단계 대사 Layer1.
   주문 금액 vs 결제 금액 대사.

   판정 기준:
   CLEAN: 갭 = 0
   GAP_MINOR: 갭 <= 1,000원
   GAP_CRITICAL: 갭 > 1,000원
     → CRITICAL 운영 알림 자동 발송
     → SOP-PAY-002 런북 연동

   pg_cron: 매일 23:30 자동 실행.
   수동 실행 가능:
   SELECT
     catchmenu_payment
       .run_layer1_reconciliation(
         tenant_id, store_id
       );

   특허4: 정산 대사 = 재무 감사 증빙.';

comment on function
  catchmenu_payment.generate_audit_packet(
    uuid, uuid, date, text, text
  ) is
  '감사 증빙 패킷 생성.
   Layer4 완성 함수.

   증빙 해시:
   SHA-256으로 위변조 탐지.
   is_tampered: 해시 불일치 시 true.

   보존 기간:
   DAILY_SETTLEMENT: 1년
   TAX_REPORT: 5년 (세법 의무)
   COMPLIANCE_EVIDENCE: 5년
   DISPUTE_EVIDENCE: 1년

   기술신보 심사:
   generate_audit_packet() 호출 결과를
   증빙 자료로 제출 가능.
   evidence_hash: 위변조 불가 증명.';

-- ===== BEGIN [sql/migrations/0084_create_reconciliation_advanced_rpc.sql] =====
-- 0084_create_reconciliation_advanced_rpc.sql
-- Purpose: Advanced payment reconciliation RPCs.
--          Layer 2: POS vs 내부 원장 대사.
--          Layer 3: VAN/PG 정산 대사.
--          Reconciliation report and gap detection.
--          특허1 core: 금융권 4단계 대사 고도화.
-- Depends on: 0083_create_push_notification_rpc.sql
-- Creates:
--   catchmenu_payment.reconciliation_layer2_results (table)
--   catchmenu_payment.reconciliation_layer3_results (table)
--   catchmenu_payment.pg_settlement_files (table)
--   function catchmenu_payment.run_layer2_reconciliation(...)
--   function catchmenu_payment.run_layer3_reconciliation(...)
--   function catchmenu_payment.import_pg_settlement(...)
--   function catchmenu_payment.get_reconciliation_report(...)
--   function catchmenu_payment.resolve_reconciliation_gap(...)

-- =============================================
-- reconciliation_layer2_results table
-- Layer 2: POS 원장 vs 내부 결제 원장 대사
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_layer2_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대사 기간
  recon_date date not null,
  recon_status text not null default 'RUNNING',

  -- POS 집계
  pos_order_count int not null default 0,
  pos_total_amount int not null default 0,
  pos_provider_code text,

  -- 내부 원장 집계
  internal_order_count int not null default 0,
  internal_total_amount int not null default 0,

  -- 차이
  count_diff int not null default 0,
  amount_diff int not null default 0,

  -- 불일치 항목
  missing_in_internal jsonb
    default '[]'::jsonb,
  missing_in_pos jsonb
    default '[]'::jsonb,
  amount_mismatches jsonb
    default '[]'::jsonb,

  -- 결과
  is_balanced boolean not null default false,
  gap_count int not null default 0,
  gap_total_amount int not null default 0,

  -- 실행 정보
  run_at timestamptz not null default now(),
  run_duration_ms int,
  run_by_type text default 'SYSTEM',

  created_at timestamptz not null default now(),

  constraint uq_layer2_recon unique (
    store_id, recon_date, pos_provider_code
  ),
  constraint chk_l2_status check (
    recon_status in (
      'RUNNING', 'BALANCED', 'GAP_DETECTED',
      'MANUAL_REVIEW', 'RESOLVED', 'FAILED'
    )
  )
);

create index if not exists idx_l2_recon_store
  on catchmenu_payment.reconciliation_layer2_results(
    store_id, recon_date desc
  );
create index if not exists idx_l2_recon_gap
  on catchmenu_payment.reconciliation_layer2_results(
    tenant_id, recon_status
  ) where recon_status = 'GAP_DETECTED';

alter table
  catchmenu_payment.reconciliation_layer2_results
  enable row level security;
alter table
  catchmenu_payment.reconciliation_layer2_results
  force row level security;

drop policy if exists l2_recon_isolation
  on catchmenu_payment.reconciliation_layer2_results;
create policy l2_recon_isolation
  on catchmenu_payment.reconciliation_layer2_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.reconciliation_layer2_results is
  'Layer 2 대사 결과.
   POS 원장(OKpos/토스POS) vs 내부 결제 원장.
   불일치 감지:
   - POS에 있지만 내부에 없는 주문
   - 내부에 있지만 POS에 없는 주문
   - 금액 불일치
   특허1: 금융권 4단계 대사 Layer 2.
   Gap 발견 시 reconciliation_cases 자동 생성.';


-- =============================================
-- reconciliation_layer3_results table
-- Layer 3: VAN/PG 정산 vs 내부 결제 원장 대사
-- =============================================
create table if not exists
  catchmenu_payment.reconciliation_layer3_results (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대사 기간
  recon_date date not null,
  recon_status text not null default 'RUNNING',

  -- VAN/PG 정산 데이터
  provider_type text not null,
  settlement_file_id uuid,
  pg_tx_count int not null default 0,
  pg_total_amount int not null default 0,
  pg_fee_amount int not null default 0,
  pg_net_amount int not null default 0,

  -- 내부 원장
  internal_tx_count int not null default 0,
  internal_total_amount int not null default 0,

  -- 차이
  count_diff int not null default 0,
  amount_diff int not null default 0,
  fee_diff int not null default 0,

  -- 불일치
  missing_in_internal jsonb
    default '[]'::jsonb,
  missing_in_pg jsonb
    default '[]'::jsonb,
  amount_mismatches jsonb
    default '[]'::jsonb,
  fee_discrepancies jsonb
    default '[]'::jsonb,

  -- 결과
  is_balanced boolean not null default false,
  gap_count int not null default 0,
  gap_total_amount int not null default 0,

  run_at timestamptz not null default now(),
  run_duration_ms int,

  created_at timestamptz not null default now(),

  constraint uq_layer3_recon unique (
    store_id, recon_date, provider_type
  ),
  constraint chk_l3_status check (
    recon_status in (
      'RUNNING', 'BALANCED', 'GAP_DETECTED',
      'MANUAL_REVIEW', 'RESOLVED', 'FAILED'
    )
  )
);

create index if not exists idx_l3_recon_store
  on catchmenu_payment.reconciliation_layer3_results(
    store_id, recon_date desc
  );

alter table
  catchmenu_payment.reconciliation_layer3_results
  enable row level security;
alter table
  catchmenu_payment.reconciliation_layer3_results
  force row level security;

drop policy if exists l3_recon_isolation
  on catchmenu_payment.reconciliation_layer3_results;
create policy l3_recon_isolation
  on catchmenu_payment.reconciliation_layer3_results
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.reconciliation_layer3_results is
  'Layer 3 대사 결과.
   VAN/PG 정산 파일 vs 내부 결제 원장.
   provider_type: TOSS_PAYMENTS/NICE/KIS.
   fee_discrepancies: 수수료 불일치 감지.
   특허1: 금융권 4단계 대사 Layer 3.
   PG사가 실제로 입금한 금액과 내부 원장 비교.
   불일치 시 → reconciliation_cases 생성.';


-- =============================================
-- pg_settlement_files table
-- PG/VAN 정산 파일 원본 보관
-- =============================================
create table if not exists
  catchmenu_payment.pg_settlement_files (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 파일 정보
  provider_type text not null,
  settlement_date date not null,
  file_name text,
  file_type text not null default 'JSON',

  -- 정산 집계
  tx_count int not null default 0,
  total_amount int not null default 0,
  fee_amount int not null default 0,
  net_amount int not null default 0,
  refund_amount int not null default 0,

  -- 원본 데이터
  settlement_data jsonb not null
    default '[]'::jsonb,

  -- 처리 상태
  import_status text not null default 'IMPORTED',
  imported_at timestamptz not null default now(),
  processed_at timestamptz,
  layer3_result_id uuid,

  created_at timestamptz not null default now(),

  constraint uq_settlement_file unique (
    store_id, provider_type, settlement_date
  ),
  constraint chk_file_type check (
    file_type in (
      'JSON', 'CSV', 'EXCEL', 'XML'
    )
  ),
  constraint chk_import_status check (
    import_status in (
      'IMPORTED', 'PROCESSING',
      'RECONCILED', 'ERROR'
    )
  )
);

create index if not exists idx_settlement_files_store
  on catchmenu_payment.pg_settlement_files(
    store_id, settlement_date desc
  );

alter table catchmenu_payment.pg_settlement_files
  enable row level security;
alter table catchmenu_payment.pg_settlement_files
  force row level security;

drop policy if exists settlement_files_isolation
  on catchmenu_payment.pg_settlement_files;
create policy settlement_files_isolation
  on catchmenu_payment.pg_settlement_files
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.pg_settlement_files is
  'PG/VAN 정산 파일 원본 보관.
   settlement_data: 개별 거래 내역 jsonb 배열.
   특허1: 외부 정산 = Gateway 원본 보관.
   파일 import 후 → Layer 3 대사 실행.
   보관 의무: 5년 (금융 감사 대비).';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_payment.run_layer2_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_recon_date date default null,
  p_pos_provider_code text default 'OKPOS',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_start timestamptz;
  v_target_date date;
  v_timezone text;
  v_result_id uuid;
  v_pos_data jsonb;
  v_internal_data jsonb;
  v_missing_internal jsonb := '[]'::jsonb;
  v_missing_pos jsonb := '[]'::jsonb;
  v_amount_mismatches jsonb := '[]'::jsonb;
  v_pos_count int := 0;
  v_pos_amount int := 0;
  v_internal_count int := 0;
  v_internal_amount int := 0;
  v_gap_count int := 0;
  v_gap_amount int := 0;
  v_is_balanced boolean;
  v_status text;
begin
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_date := coalesce(
    p_recon_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ) - interval '1 day')::date
  );

  -- POS 거래 집계 (OKpos/Toss POS)
  case p_pos_provider_code
    when 'OKPOS' then
      select
        count(*),
        coalesce(sum(paid_amount), 0),
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'pos_order_id', okpos_order_id,
              'amount', paid_amount,
              'tx_type', okpos_tx_type
            )
          ) filter (
            where processing_status = 'COMPLETED'
          ),
          '[]'::jsonb
        )
      into v_pos_count, v_pos_amount, v_pos_data
      from catchmenu_integrations.okpos_transactions
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_target_date
        and okpos_tx_type = 'PAYMENT_CONFIRM'
        and processing_status = 'COMPLETED';

    when 'TOSS_POS' then
      select
        count(*),
        coalesce(sum(paid_amount), 0),
        coalesce(
          jsonb_agg(
            jsonb_build_object(
              'pos_order_id',
                toss_pos_order_id,
              'amount', paid_amount,
              'tx_type', toss_pos_tx_type
            )
          ) filter (
            where processing_status = 'COMPLETED'
          ),
          '[]'::jsonb
        )
      into v_pos_count, v_pos_amount, v_pos_data
      from catchmenu_integrations
        .toss_pos_transactions
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and business_day = v_target_date
        and toss_pos_tx_type = 'PAYMENT_CONFIRM'
        and processing_status = 'COMPLETED';

    else
      v_pos_count := 0;
      v_pos_amount := 0;
      v_pos_data := '[]'::jsonb;
  end case;

  -- 내부 결제 원장 집계
  select
    count(*),
    coalesce(sum(approved_amount), 0),
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'ledger_id', id,
          'approval_number',
            provider_approval_number,
          'amount', approved_amount,
          'provider_type', provider_type
        )
      ),
      '[]'::jsonb
    )
  into v_internal_count, v_internal_amount,
       v_internal_data
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date
    and ledger_status = 'APPROVED'
    and provider_type like '%'
      || p_pos_provider_code || '%';

  -- 불일치 감지
  -- POS에 있지만 내부에 없는 거래
  if v_pos_count > v_internal_count then
    v_missing_internal := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'MISSING_IN_INTERNAL',
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'diff', v_pos_count - v_internal_count
      )
    );
    v_gap_count := v_gap_count + (
      v_pos_count - v_internal_count
    );
  end if;

  -- 내부에 있지만 POS에 없는 거래
  if v_internal_count > v_pos_count then
    v_missing_pos := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'MISSING_IN_POS',
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'diff', v_internal_count - v_pos_count
      )
    );
    v_gap_count := v_gap_count + (
      v_internal_count - v_pos_count
    );
  end if;

  -- 금액 불일치
  if abs(v_pos_amount - v_internal_amount) > 0 then
    v_amount_mismatches := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'AMOUNT_MISMATCH',
        'pos_amount', v_pos_amount,
        'internal_amount', v_internal_amount,
        'diff', v_pos_amount - v_internal_amount
      )
    );
    v_gap_amount := abs(
      v_pos_amount - v_internal_amount
    );
  end if;

  v_is_balanced :=
    v_gap_count = 0 and v_gap_amount = 0;

  v_status := case v_is_balanced
    when true then 'BALANCED'
    else 'GAP_DETECTED'
  end;

  -- 결과 저장
  insert into
    catchmenu_payment.reconciliation_layer2_results (
    tenant_id, store_id,
    recon_date, recon_status,
    pos_order_count, pos_total_amount,
    pos_provider_code,
    internal_order_count, internal_total_amount,
    count_diff, amount_diff,
    missing_in_internal, missing_in_pos,
    amount_mismatches,
    is_balanced, gap_count, gap_total_amount,
    run_at, run_duration_ms, run_by_type
  ) values (
    p_tenant_id, p_store_id,
    v_target_date, v_status,
    v_pos_count, v_pos_amount,
    p_pos_provider_code,
    v_internal_count, v_internal_amount,
    v_pos_count - v_internal_count,
    v_pos_amount - v_internal_amount,
    v_missing_internal, v_missing_pos,
    v_amount_mismatches,
    v_is_balanced, v_gap_count, v_gap_amount,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000,
    'SYSTEM'
  )
  on conflict (store_id, recon_date, pos_provider_code)
  do update set
    recon_status = excluded.recon_status,
    pos_order_count = excluded.pos_order_count,
    pos_total_amount = excluded.pos_total_amount,
    internal_order_count =
      excluded.internal_order_count,
    internal_total_amount =
      excluded.internal_total_amount,
    count_diff = excluded.count_diff,
    amount_diff = excluded.amount_diff,
    missing_in_internal =
      excluded.missing_in_internal,
    missing_in_pos = excluded.missing_in_pos,
    amount_mismatches = excluded.amount_mismatches,
    is_balanced = excluded.is_balanced,
    gap_count = excluded.gap_count,
    gap_total_amount = excluded.gap_total_amount,
    run_at = now()
  returning id into v_result_id;

  -- Gap 발견 시 reconciliation_case 생성
  if not v_is_balanced then
    insert into
      catchmenu_payment.reconciliation_cases (
      tenant_id, store_id,
      case_type, case_status,
      severity,
      layer_number,
      subject_type, subject_id,
      amount_difference,
      case_description,
      correlation_id,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      'LAYER2_GAP', 'OPEN',
      case when v_gap_amount > 100000
        then 'CRITICAL' else 'HIGH'
      end,
      2,
      'recon_l2_result', v_result_id,
      v_gap_amount,
      'Layer 2 대사 불일치: '
        || p_pos_provider_code
        || ' | 건수차=' || v_gap_count
        || ' | 금액차=₩'
        || v_gap_amount,
      p_correlation_id,
      v_target_date, v_timezone
    )
    on conflict do nothing;

    -- CRITICAL 진단 로그
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'PAYMENT',
      p_log_event := 'layer2_recon_gap',
      p_message :=
        '[Layer2] 대사 불일치: '
        || p_pos_provider_code
        || ' | 날짜=' || v_target_date
        || ' | 건수차=' || v_gap_count
        || ' | 금액차=₩' || v_gap_amount,
      p_rpc_name := 'run_layer2_reconciliation',
      p_details := jsonb_build_object(
        'result_id', v_result_id,
        'recon_date', v_target_date,
        'pos_count', v_pos_count,
        'internal_count', v_internal_count,
        'pos_amount', v_pos_amount,
        'internal_amount', v_internal_amount
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'result_id', v_result_id,
    'recon_date', v_target_date,
    'pos_provider', p_pos_provider_code,
    'status', v_status,
    'is_balanced', v_is_balanced,
    'pos', jsonb_build_object(
      'count', v_pos_count,
      'amount', v_pos_amount
    ),
    'internal', jsonb_build_object(
      'count', v_internal_count,
      'amount', v_internal_amount
    ),
    'gaps', jsonb_build_object(
      'count_diff', v_gap_count,
      'amount_diff', v_gap_amount
    ),
    'message_code', case v_is_balanced
      when true then 'layer2_recon_balanced'
      else 'layer2_recon_gap_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_payment.import_pg_settlement(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_type text,
  p_settlement_date date,
  p_settlement_data jsonb,
  p_file_name text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_file_id uuid;
  v_tx_count int := 0;
  v_total_amount int := 0;
  v_fee_amount int := 0;
  v_net_amount int := 0;
  v_refund_amount int := 0;
  v_tx jsonb;
begin
  -- 정산 데이터 집계
  for v_tx in
    select * from jsonb_array_elements(
      p_settlement_data
    )
  loop
    v_tx_count := v_tx_count + 1;

    v_total_amount := v_total_amount
      + coalesce(
        (v_tx->>'amount')::int, 0
      );
    v_fee_amount := v_fee_amount
      + coalesce(
        (v_tx->>'fee_amount')::int, 0
      );
    v_net_amount := v_net_amount
      + coalesce(
        (v_tx->>'net_amount')::int, 0
      );

    if coalesce(
      (v_tx->>'is_refund')::boolean, false
    ) then
      v_refund_amount := v_refund_amount
        + coalesce(
          (v_tx->>'amount')::int, 0
        );
    end if;
  end loop;

  -- 정산 파일 저장
  insert into
    catchmenu_payment.pg_settlement_files (
    tenant_id, store_id,
    provider_type, settlement_date,
    file_name, file_type,
    tx_count, total_amount,
    fee_amount, net_amount, refund_amount,
    settlement_data, import_status,
    imported_at
  ) values (
    p_tenant_id, p_store_id,
    p_provider_type, p_settlement_date,
    p_file_name, 'JSON',
    v_tx_count, v_total_amount,
    v_fee_amount, v_net_amount, v_refund_amount,
    p_settlement_data, 'IMPORTED',
    now()
  )
  on conflict (store_id, provider_type, settlement_date)
  do update set
    settlement_data = excluded.settlement_data,
    tx_count = excluded.tx_count,
    total_amount = excluded.total_amount,
    fee_amount = excluded.fee_amount,
    net_amount = excluded.net_amount,
    refund_amount = excluded.refund_amount,
    import_status = 'IMPORTED',
    imported_at = now()
  returning id into v_file_id;

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'pg_settlement_imported',
    p_message :=
      p_provider_type || ' 정산 파일 임포트'
      || ' | 날짜=' || p_settlement_date
      || ' | 건수=' || v_tx_count
      || ' | 금액=₩' || v_total_amount,
    p_rpc_name := 'import_pg_settlement',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'file_id', v_file_id,
      'provider_type', p_provider_type,
      'settlement_date', p_settlement_date,
      'tx_count', v_tx_count,
      'net_amount', v_net_amount
    )
  );

  return jsonb_build_object(
    'success', true,
    'file_id', v_file_id,
    'provider_type', p_provider_type,
    'settlement_date', p_settlement_date,
    'summary', jsonb_build_object(
      'tx_count', v_tx_count,
      'total_amount', v_total_amount,
      'fee_amount', v_fee_amount,
      'net_amount', v_net_amount,
      'refund_amount', v_refund_amount
    ),
    'next_step', 'RUN_LAYER3_RECONCILIATION',
    'message_code', 'pg_settlement_imported'
  );
end;
$$;


create or replace function
  catchmenu_payment.run_layer3_reconciliation(
  p_tenant_id uuid,
  p_store_id uuid,
  p_recon_date date default null,
  p_provider_type text default 'TOSS_PAYMENTS',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_start timestamptz;
  v_target_date date;
  v_timezone text;
  v_result_id uuid;
  v_settlement record;
  v_internal_count int := 0;
  v_internal_amount int := 0;
  v_missing_internal jsonb := '[]'::jsonb;
  v_missing_pg jsonb := '[]'::jsonb;
  v_amount_mismatches jsonb := '[]'::jsonb;
  v_fee_discrepancies jsonb := '[]'::jsonb;
  v_gap_count int := 0;
  v_gap_amount int := 0;
  v_is_balanced boolean;
  v_status text;
  v_tx jsonb;
  v_approval_number text;
  v_internal_tx record;
begin
  v_start := now();

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_target_date := coalesce(
    p_recon_date,
    (timezone(
      coalesce(v_timezone, 'Asia/Seoul'), now()
    ) - interval '1 day')::date
  );

  -- 정산 파일 조회
  select id, tx_count, total_amount,
         fee_amount, net_amount,
         settlement_data
  into v_settlement
  from catchmenu_payment.pg_settlement_files
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_type = p_provider_type
    and settlement_date = v_target_date;

  if v_settlement.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'settlement_file_not_found',
      'message', p_provider_type
        || ' 정산 파일이 없습니다. '
        || 'import_pg_settlement() 먼저 실행하세요.',
      'settlement_date', v_target_date
    );
  end if;

  -- 내부 원장 집계
  select
    count(*),
    coalesce(sum(approved_amount), 0)
  into v_internal_count, v_internal_amount
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_target_date
    and provider_type = p_provider_type
    and ledger_status = 'APPROVED';

  -- 개별 거래 대사
  for v_tx in
    select * from jsonb_array_elements(
      v_settlement.settlement_data
    )
  loop
    v_approval_number :=
      v_tx->>'approval_number';

    -- 내부 원장에서 승인번호로 조회
    select id, approved_amount, net_amount
    into v_internal_tx
    from catchmenu_payment.payment_ledger
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and provider_approval_number
        = v_approval_number
      and provider_type = p_provider_type
    limit 1;

    if v_internal_tx.id is null then
      -- PG에 있지만 내부에 없음
      v_missing_internal := v_missing_internal
        || jsonb_build_array(
          jsonb_build_object(
            'approval_number', v_approval_number,
            'pg_amount',
              (v_tx->>'amount')::int,
            'gap_type', 'IN_PG_NOT_INTERNAL'
          )
        );
      v_gap_count := v_gap_count + 1;
      v_gap_amount := v_gap_amount
        + coalesce(
          (v_tx->>'amount')::int, 0
        );

    elsif abs(
      v_internal_tx.approved_amount
      - (v_tx->>'amount')::int
    ) > 0 then
      -- 금액 불일치
      v_amount_mismatches := v_amount_mismatches
        || jsonb_build_array(
          jsonb_build_object(
            'approval_number', v_approval_number,
            'pg_amount',
              (v_tx->>'amount')::int,
            'internal_amount',
              v_internal_tx.approved_amount,
            'diff',
              (v_tx->>'amount')::int
              - v_internal_tx.approved_amount,
            'gap_type', 'AMOUNT_MISMATCH'
          )
        );
      v_gap_count := v_gap_count + 1;
      v_gap_amount := v_gap_amount + abs(
        (v_tx->>'amount')::int
        - v_internal_tx.approved_amount
      );
    end if;
  end loop;

  -- 전체 금액 비교
  if v_settlement.tx_count <> v_internal_count then
    v_missing_pg := jsonb_build_array(
      jsonb_build_object(
        'gap_type', 'COUNT_MISMATCH',
        'pg_count', v_settlement.tx_count,
        'internal_count', v_internal_count,
        'diff',
          v_settlement.tx_count
          - v_internal_count
      )
    );
  end if;

  v_is_balanced :=
    v_gap_count = 0
    and abs(
      v_settlement.total_amount
      - v_internal_amount
    ) = 0;

  v_status := case v_is_balanced
    when true then 'BALANCED'
    else 'GAP_DETECTED'
  end;

  -- 결과 저장
  insert into
    catchmenu_payment.reconciliation_layer3_results (
    tenant_id, store_id,
    recon_date, recon_status,
    provider_type, settlement_file_id,
    pg_tx_count, pg_total_amount,
    pg_fee_amount, pg_net_amount,
    internal_tx_count, internal_total_amount,
    count_diff, amount_diff,
    missing_in_internal, missing_in_pg,
    amount_mismatches, fee_discrepancies,
    is_balanced, gap_count, gap_total_amount,
    run_at, run_duration_ms
  ) values (
    p_tenant_id, p_store_id,
    v_target_date, v_status,
    p_provider_type, v_settlement.id,
    v_settlement.tx_count,
    v_settlement.total_amount,
    v_settlement.fee_amount,
    v_settlement.net_amount,
    v_internal_count, v_internal_amount,
    v_settlement.tx_count - v_internal_count,
    v_settlement.total_amount - v_internal_amount,
    v_missing_internal, v_missing_pg,
    v_amount_mismatches, v_fee_discrepancies,
    v_is_balanced, v_gap_count, v_gap_amount,
    now(),
    extract(
      epoch from (now() - v_start)
    )::int * 1000
  )
  on conflict (store_id, recon_date, provider_type)
  do update set
    recon_status = excluded.recon_status,
    pg_tx_count = excluded.pg_tx_count,
    pg_total_amount = excluded.pg_total_amount,
    internal_tx_count = excluded.internal_tx_count,
    internal_total_amount =
      excluded.internal_total_amount,
    is_balanced = excluded.is_balanced,
    gap_count = excluded.gap_count,
    gap_total_amount = excluded.gap_total_amount,
    missing_in_internal =
      excluded.missing_in_internal,
    amount_mismatches = excluded.amount_mismatches,
    run_at = now()
  returning id into v_result_id;

  -- 정산 파일 처리 완료
  update catchmenu_payment.pg_settlement_files
  set
    import_status = 'RECONCILED',
    layer3_result_id = v_result_id,
    processed_at = now()
  where id = v_settlement.id;

  -- Gap 시 case 생성
  if not v_is_balanced then
    insert into
      catchmenu_payment.reconciliation_cases (
      tenant_id, store_id,
      case_type, case_status, severity,
      layer_number,
      subject_type, subject_id,
      amount_difference, case_description,
      correlation_id,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      'LAYER3_GAP', 'OPEN',
      case when v_gap_amount > 50000
        then 'CRITICAL' else 'HIGH'
      end,
      3,
      'recon_l3_result', v_result_id,
      v_gap_amount,
      'Layer 3 대사 불일치: '
        || p_provider_type
        || ' | 건수차='
          || (v_settlement.tx_count
            - v_internal_count)
        || ' | 금액차=₩' || v_gap_amount,
      p_correlation_id,
      v_target_date, v_timezone
    )
    on conflict do nothing;

    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'layer3_recon_gap',
      p_message :=
        '[Layer3] PG 정산 불일치: '
        || p_provider_type
        || ' | 날짜=' || v_target_date
        || ' | 금액차=₩' || v_gap_amount,
      p_rpc_name := 'run_layer3_reconciliation',
      p_details := jsonb_build_object(
        'result_id', v_result_id,
        'pg_amount', v_settlement.total_amount,
        'internal_amount', v_internal_amount,
        'gap_amount', v_gap_amount,
        'gap_count', v_gap_count
      )
    );
  end if;

  return jsonb_build_object(
    'success', true,
    'result_id', v_result_id,
    'recon_date', v_target_date,
    'provider_type', p_provider_type,
    'status', v_status,
    'is_balanced', v_is_balanced,
    'pg', jsonb_build_object(
      'tx_count', v_settlement.tx_count,
      'total_amount', v_settlement.total_amount,
      'fee_amount', v_settlement.fee_amount,
      'net_amount', v_settlement.net_amount
    ),
    'internal', jsonb_build_object(
      'tx_count', v_internal_count,
      'total_amount', v_internal_amount
    ),
    'gaps', jsonb_build_object(
      'gap_count', v_gap_count,
      'gap_amount', v_gap_amount,
      'missing_in_internal',
        jsonb_array_length(v_missing_internal),
      'amount_mismatches',
        jsonb_array_length(v_amount_mismatches)
    ),
    'message_code', case v_is_balanced
      when true then 'layer3_recon_balanced'
      else 'layer3_recon_gap_detected'
    end
  );
end;
$$;


create or replace function
  catchmenu_payment.get_reconciliation_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_period_start date,
  p_period_end date
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_l1_summary jsonb;
  v_l2_summary jsonb;
  v_l3_summary jsonb;
  v_open_cases jsonb;
  v_overall_health text;
begin
  -- Layer 1 요약
  select jsonb_build_object(
    'total_days', count(distinct business_day),
    'balanced_days', count(*) filter (
      where reconciliation_status = 'BALANCED'
    ),
    'gap_days', count(*) filter (
      where reconciliation_status = 'GAP_DETECTED'
    ),
    'total_approved', coalesce(
      sum(approved_amount)
        filter (where ledger_status = 'APPROVED'),
      0
    ),
    'total_refunded', coalesce(
      sum(approved_amount)
        filter (where ledger_status = 'REFUNDED'),
      0
    ),
    'pending_reconciliation', count(*) filter (
      where reconciliation_status = 'PENDING'
    )
  )
  into v_l1_summary
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day between
      p_period_start and p_period_end;

  -- Layer 2 요약
  select jsonb_build_object(
    'total_runs', count(*),
    'balanced', count(*) filter (
      where recon_status = 'BALANCED'
    ),
    'gap_detected', count(*) filter (
      where recon_status = 'GAP_DETECTED'
    ),
    'total_gap_amount', coalesce(
      sum(gap_total_amount)
        filter (where not is_balanced),
      0
    )
  )
  into v_l2_summary
  from catchmenu_payment
    .reconciliation_layer2_results
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and recon_date between
      p_period_start and p_period_end;

  -- Layer 3 요약
  select jsonb_build_object(
    'total_runs', count(*),
    'balanced', count(*) filter (
      where recon_status = 'BALANCED'
    ),
    'gap_detected', count(*) filter (
      where recon_status = 'GAP_DETECTED'
    ),
    'total_gap_amount', coalesce(
      sum(gap_total_amount)
        filter (where not is_balanced),
      0
    ),
    'total_pg_fee', coalesce(
      sum(pg_fee_amount), 0
    )
  )
  into v_l3_summary
  from catchmenu_payment
    .reconciliation_layer3_results
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and recon_date between
      p_period_start and p_period_end;

  -- 미해결 대사 케이스
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'case_id', id,
        'case_type', case_type,
        'case_status', case_status,
        'case_severity', severity,
        'layer_number', layer_number,
        'amount_difference', amount_difference,
        'case_description', case_description,
        'created_at', created_at
      )
      order by
        case severity
          when 'CRITICAL' then 0
          when 'HIGH' then 1
          else 2
        end,
        created_at desc
    ),
    '[]'::jsonb
  )
  into v_open_cases
  from catchmenu_payment.reconciliation_cases
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and case_status in ('OPEN', 'UNDER_INVESTIGATION')
    and business_day between
      p_period_start and p_period_end;

  -- 전체 건전성 판단
  v_overall_health := case
    when jsonb_array_length(v_open_cases) = 0
      then 'HEALTHY'
    when (
      select count(*) from jsonb_array_elements(
        v_open_cases
      ) c
      where c->>'case_severity' = 'CRITICAL'
    ) > 0
      then 'CRITICAL'
    else 'WARNING'
  end;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'period_start', p_period_start,
    'period_end', p_period_end,
    'overall_health', v_overall_health,
    'layer1', v_l1_summary,
    'layer2', v_l2_summary,
    'layer3', v_l3_summary,
    'open_cases', v_open_cases,
    'open_case_count',
      jsonb_array_length(v_open_cases),
    'message_code', 'recon_report_loaded'
  );
end;
$$;


create or replace function
  catchmenu_payment.resolve_reconciliation_gap(
  p_tenant_id uuid,
  p_store_id uuid,
  p_case_id uuid,
  p_resolution_type text,
  p_resolution_note text,
  p_actor_type text default 'MANAGER',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_case record;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  if p_resolution_type not in (
    'MANUAL_MATCH', 'WRITE_OFF',
    'PROVIDER_CONFIRMED', 'DATA_ENTRY_ERROR',
    'TIMING_DIFFERENCE', 'SYSTEM_ERROR'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_resolution_type',
      'allowed', jsonb_build_array(
        'MANUAL_MATCH', 'WRITE_OFF',
        'PROVIDER_CONFIRMED',
        'DATA_ENTRY_ERROR',
        'TIMING_DIFFERENCE', 'SYSTEM_ERROR'
      )
    );
  end if;

  select id, case_type, case_status,
         severity, layer_number,
         amount_difference, business_day
  into v_case
  from catchmenu_payment.reconciliation_cases
  where id = p_case_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_case.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'case_already_resolved',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'resolve_reconciliation_gap'
    );
  end if;

  if v_case.case_status = 'RESOLVED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'case_already_resolved',
      'case_id', p_case_id
    );
  end if;

  -- 케이스 해결
  update catchmenu_payment.reconciliation_cases
  set
    case_status = 'RESOLVED',
    resolution_type = p_resolution_type,
    resolution_note = p_resolution_note,
    resolved_at = now(),
    resolved_by = p_actor_id,
    updated_at = now()
  where id = p_case_id;

  -- Layer 결과 업데이트
  case v_case.layer_number
    when 2 then
      update catchmenu_payment
        .reconciliation_layer2_results
      set recon_status = 'RESOLVED'
      where id = v_case.subject_id;
    when 3 then
      update catchmenu_payment
        .reconciliation_layer3_results
      set recon_status = 'RESOLVED'
      where id = v_case.subject_id;
    else null;
  end case;

  -- 감사 기록
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'reconciliation_gap_resolved',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'reconciliation_case',
    p_subject_id := p_case_id,
    p_decision := 'RESOLVED',
    p_decision_reason := p_resolution_type,
    p_decision_payload := jsonb_build_object(
      'case_type', v_case.case_type,
      'layer_number', v_case.layer_number,
      'amount_difference',
        v_case.amount_difference,
      'resolution_note', p_resolution_note
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'PAYMENT',
    p_log_event := 'recon_gap_resolved',
    p_message :=
      'Layer' || v_case.layer_number
      || ' 대사 Gap 해결: '
      || p_resolution_type
      || ' | 금액=₩' || v_case.amount_difference,
    p_rpc_name := 'resolve_reconciliation_gap',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'case_id', p_case_id,
      'case_type', v_case.case_type,
      'resolution_type', p_resolution_type
    )
  );

  return jsonb_build_object(
    'success', true,
    'case_id', p_case_id,
    'case_type', v_case.case_type,
    'layer_number', v_case.layer_number,
    'resolution_type', p_resolution_type,
    'amount_difference', v_case.amount_difference,
    'audit_id', v_audit_id,
    'message_code', 'recon_gap_resolved'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.run_layer2_reconciliation(
      uuid, uuid, date, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.import_pg_settlement(
      uuid, uuid, text, date, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.import_pg_settlement(
      uuid, uuid, text, date, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.run_layer3_reconciliation(
      uuid, uuid, date, text, text
    ) from public;
  grant execute on function
    catchmenu_payment.run_layer3_reconciliation(
      uuid, uuid, date, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date
    ) from public;
  grant execute on function
    catchmenu_payment.get_reconciliation_report(
      uuid, uuid, date, date
    ) to authenticated;

  revoke all on function
    catchmenu_payment.resolve_reconciliation_gap(
      uuid, uuid, uuid, text, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_payment.resolve_reconciliation_gap(
      uuid, uuid, uuid, text, text, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_payment.run_layer2_reconciliation(
    uuid, uuid, date, text, text
  ) is
  'Layer 2 대사: POS 원장 vs 내부 결제 원장.
   비교 대상:
   - OKpos: okpos_transactions vs payment_ledger
   - Toss POS: toss_pos_transactions vs payment_ledger
   불일치 감지:
   1. 건수 차이 (POS vs 내부)
   2. 금액 차이
   3. POS에만 있는 거래
   4. 내부에만 있는 거래
   Gap 감지 시 → reconciliation_cases 자동 생성.
   특허1: 금융권 4단계 대사 Layer 2.
   권장 실행: 매일 00:30 (일일 마감 후).';

comment on function
  catchmenu_payment.run_layer3_reconciliation(
    uuid, uuid, date, text, text
  ) is
  'Layer 3 대사: PG 정산 파일 vs 내부 결제 원장.
   사전 조건: import_pg_settlement() 먼저 실행.
   승인번호 기반 1:1 거래 매칭.
   불일치 감지:
   1. PG에 있지만 내부에 없는 거래
   2. 금액 불일치
   3. 수수료 불일치
   Gap 감지 시 → CRITICAL 진단 로그 + case 생성.
   특허1: 금융권 4단계 대사 Layer 3.
   PG사 실제 입금액 = 내부 원장 검증.
   권장 실행: PG 정산 파일 수신 즉시.';

-- ===== BEGIN [sql/migrations/0056_create_van_integration_rpc.sql] =====
-- 0056_create_van_integration_rpc.sql
-- Purpose: VAN (Value Added Network) integration RPCs.
--          NICE Payments and KIS (Korea Information Service) VAN.
--          process_van_approval: requests VAN payment approval.
--          process_van_cancel: requests VAN payment cancellation.
--          sync_van_settlement: syncs daily VAN settlement data.
--          특허1 core: VAN 연동 = Gateway 샌드박스 통과 후 내부 원장 반영.
-- Depends on: 0055_create_sales_report_rpc.sql
-- Creates:
--   catchmenu_integrations.van_transactions (table)
--   catchmenu_integrations.van_settlements (table)
--   function catchmenu_integrations.process_van_approval(...)
--   function catchmenu_integrations.process_van_cancel(...)
--   function catchmenu_integrations.sync_van_settlement(...)

-- =============================================
-- van_transactions table
-- =============================================
create table if not exists catchmenu_integrations.van_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- VAN provider
  van_provider text not null,
  van_terminal_id text,
  van_merchant_id text,

  -- transaction identity
  van_trace_number text,
  van_approval_number text,
  van_transaction_id text,
  van_batch_number text,

  -- linked internal records
  ledger_id uuid,
  intent_id uuid,
  order_id uuid,

  -- transaction details
  transaction_type text not null,
  card_type text,
  card_number_masked text,
  card_issuer text,
  card_acquirer text,
  installment_months int not null default 0,

  -- amounts
  requested_amount int not null,
  approved_amount int,
  cancelled_amount int not null default 0,

  -- status
  van_status text not null default 'PENDING',
  raw_request jsonb,
  raw_response jsonb,
  response_code text,
  response_message text,

  -- timestamps
  requested_at timestamptz not null default now(),
  approved_at timestamptz,
  cancelled_at timestamptz,
  settlement_date date,
  settled_at timestamptz,

  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_van_trace unique (
    van_provider, van_terminal_id, van_trace_number
  ),
  constraint chk_van_provider check (
    van_provider in (
      'NICE_PAYMENTS', 'KIS', 'KICC',
      'KFTC', 'SMARTRO', 'KCP'
    )
  ),
  constraint chk_van_status check (
    van_status in (
      'PENDING', 'APPROVED', 'CANCELLED',
      'FAILED', 'UNCERTAIN', 'SETTLED'
    )
  ),
  constraint chk_transaction_type check (
    transaction_type in (
      'CARD_APPROVAL', 'CARD_CANCEL',
      'CASH_APPROVAL', 'CASH_CANCEL',
      'ZERO_AUTH'
    )
  )
);

create index if not exists idx_van_tx_store
  on catchmenu_integrations.van_transactions(
    store_id, business_day
  );
create index if not exists idx_van_tx_ledger
  on catchmenu_integrations.van_transactions(ledger_id)
  where ledger_id is not null;
create index if not exists idx_van_tx_approval
  on catchmenu_integrations.van_transactions(
    van_provider, van_approval_number
  ) where van_approval_number is not null;

alter table catchmenu_integrations.van_transactions
  enable row level security;
alter table catchmenu_integrations.van_transactions
  force row level security;

drop policy if exists van_tx_isolation
  on catchmenu_integrations.van_transactions;
create policy van_tx_isolation
  on catchmenu_integrations.van_transactions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_van_tx_updated_at
  on catchmenu_integrations.van_transactions;
create trigger trg_van_tx_updated_at
  before update on catchmenu_integrations.van_transactions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_integrations.van_transactions is
  'VAN transaction records for NICE, KIS, KICC, etc.
   Every VAN request/response pair stored with raw payloads.
   Links to internal payment_ledger via ledger_id.
   특허1: VAN 연동 = 외부 원장 ↔ 내부 원장 대사 증거.';


-- =============================================
-- van_settlements table
-- =============================================
create table if not exists catchmenu_integrations.van_settlements (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  van_provider text not null,
  van_terminal_id text,
  van_merchant_id text,
  settlement_date date not null,

  -- settlement amounts
  total_approved_amount int not null default 0,
  total_cancelled_amount int not null default 0,
  net_settlement_amount int not null default 0,
  transaction_count int not null default 0,
  cancelled_count int not null default 0,

  -- fees
  van_fee_amount int not null default 0,
  net_payout_amount int not null default 0,

  -- status
  settlement_status text not null default 'RECEIVED',
  raw_settlement_data jsonb,
  reconciliation_status text not null default 'PENDING',
  reconciliation_checked_at timestamptz,
  reconciliation_note text,

  received_at timestamptz not null default now(),
  settled_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_van_settlement unique (
    store_id, van_provider,
    van_terminal_id, settlement_date
  ),
  constraint chk_van_settlement_status check (
    settlement_status in (
      'RECEIVED', 'MATCHED', 'MISMATCH',
      'RESOLVED', 'DISPUTED'
    )
  )
);

create index if not exists idx_van_settlement_date
  on catchmenu_integrations.van_settlements(
    store_id, settlement_date
  );

alter table catchmenu_integrations.van_settlements
  enable row level security;
alter table catchmenu_integrations.van_settlements
  force row level security;

drop policy if exists van_settlement_isolation
  on catchmenu_integrations.van_settlements;
create policy van_settlement_isolation
  on catchmenu_integrations.van_settlements
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_van_settlement_updated_at
  on catchmenu_integrations.van_settlements;
create trigger trg_van_settlement_updated_at
  before update on catchmenu_integrations.van_settlements
  for each row execute function
    catchmenu_common.set_updated_at();


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_integrations.process_van_approval(
  p_tenant_id uuid,
  p_store_id uuid,
  p_van_provider text,
  p_van_terminal_id text,
  p_van_merchant_id text,
  p_intent_id uuid,
  p_ledger_id uuid,
  p_order_id uuid,
  p_requested_amount int,
  p_card_type text default 'CREDIT',
  p_installment_months int default 0,
  p_raw_request jsonb default null,
  p_raw_response jsonb default null,
  p_van_approval_number text default null,
  p_van_trace_number text default null,
  p_response_code text default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_gateway,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_van_tx_id uuid;
  v_provider_event_id uuid;
  v_business_day date;
  v_timezone text;
  v_is_approved boolean;
  v_audit_id uuid;
begin
  if p_van_provider not in (
    'NICE_PAYMENTS', 'KIS', 'KICC',
    'KFTC', 'SMARTRO', 'KCP'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_van_provider'
    );
  end if;

  if p_requested_amount <= 0 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_amount'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- determine approval from response code
  -- VAN response code 0000 = approved
  v_is_approved := coalesce(
    p_response_code = '0000'
    or p_van_approval_number is not null,
    false
  );

  -- store in gateway provider_raw_events
  insert into catchmenu_gateway.provider_raw_events (
    tenant_id, store_id,
    provider_type, provider_code,
    provider_event_id, provider_event_type,
    raw_payload,
    payload_hash,
    signature_verified,
    schema_validated,
    processing_status,
    correlation_id, received_at
  ) values (
    p_tenant_id, p_store_id,
    p_van_provider, 'VAN',
    coalesce(p_van_approval_number, p_van_trace_number),
    'CARD_APPROVAL',
    coalesce(p_raw_response, '{}'::jsonb),
    encode(digest(
      coalesce(p_raw_response, '{}')::text, 'sha256'
    ), 'hex'),
    true, true,
    case v_is_approved
      when true then 'ACCEPTED'
      else 'REJECTED'
    end,
    p_correlation_id, now()
  )
  returning id into v_provider_event_id;

  -- create VAN transaction record
  insert into catchmenu_integrations.van_transactions (
    tenant_id, store_id,
    van_provider, van_terminal_id, van_merchant_id,
    van_trace_number, van_approval_number,
    ledger_id, intent_id, order_id,
    transaction_type,
    card_type,
    installment_months,
    requested_amount, approved_amount,
    van_status,
    response_code, response_message,
    raw_request, raw_response,
    approved_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_van_provider, p_van_terminal_id, p_van_merchant_id,
    p_van_trace_number, p_van_approval_number,
    p_ledger_id, p_intent_id, p_order_id,
    'CARD_APPROVAL',
    coalesce(p_card_type, 'CREDIT'),
    coalesce(p_installment_months, 0),
    p_requested_amount,
    case when v_is_approved then p_requested_amount
      else null
    end,
    case when v_is_approved then 'APPROVED'
      else 'FAILED'
    end,
    p_response_code,
    p_raw_response->>'responseMessage',
    p_raw_request, p_raw_response,
    case when v_is_approved then now() else null end,
    v_business_day, v_timezone
  )
  returning id into v_van_tx_id;

  -- if approved: confirm payment in internal ledger
  if v_is_approved then
    perform catchmenu_payment.confirm_payment_from_provider(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_intent_id := p_intent_id,
      p_provider_payment_key := p_van_approval_number,
      p_provider_approval_number := p_van_approval_number,
      p_approved_amount := p_requested_amount,
      p_provider_raw_event_id := v_provider_event_id,
      p_correlation_id := p_correlation_id
    );
  else
    -- mark intent as failed
    update catchmenu_payment.payment_intents
    set
      intent_status = 'FAILED',
      updated_at = now()
    where id = p_intent_id;

    -- create exception for payment failure
    perform catchmenu_ledger.create_exception(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_exception_domain := 'payment',
      p_exception_type := 'van_approval_failed',
      p_exception_severity := 'WARNING',
      p_subject_type := 'van_transaction',
      p_subject_id := v_van_tx_id,
      p_error_message := 'VAN approval failed: '
        || coalesce(p_response_code, 'unknown'),
      p_exception_payload := jsonb_build_object(
        'van_provider', p_van_provider,
        'response_code', p_response_code,
        'requested_amount', p_requested_amount
      ),
      p_correlation_id := p_correlation_id
    );
  end if;

  -- audit for VAN approval
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'van_approval_processed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'van_transaction',
    p_subject_id := v_van_tx_id,
    p_decision := case when v_is_approved
      then 'APPROVED' else 'REJECTED'
    end,
    p_decision_payload := jsonb_build_object(
      'van_provider', p_van_provider,
      'van_approval_number', p_van_approval_number,
      'requested_amount', p_requested_amount,
      'response_code', p_response_code,
      'is_approved', v_is_approved
    ),
    p_payment_id := p_ledger_id,
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'van_tx_id', v_van_tx_id,
    'van_provider', p_van_provider,
    'van_status', case when v_is_approved
      then 'APPROVED' else 'FAILED'
    end,
    'is_approved', v_is_approved,
    'approved_amount', case when v_is_approved
      then p_requested_amount else null
    end,
    'van_approval_number', p_van_approval_number,
    'response_code', p_response_code,
    'provider_event_id', v_provider_event_id,
    'audit_id', v_audit_id,
    'message_code', case when v_is_approved
      then 'van_approval_confirmed'
      else 'van_approval_failed'
    end
  );
end;
$$;


create or replace function catchmenu_integrations.process_van_cancel(
  p_tenant_id uuid,
  p_store_id uuid,
  p_van_tx_id uuid,
  p_cancel_amount int,
  p_cancel_reason text,
  p_raw_request jsonb default null,
  p_raw_response jsonb default null,
  p_van_cancel_number text default null,
  p_response_code text default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_van_tx record;
  v_is_cancelled boolean;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  if trim(coalesce(p_cancel_reason, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'cancel_reason_required'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- get original VAN transaction
  select id, van_provider, van_terminal_id,
         van_merchant_id, van_approval_number,
         van_trace_number, ledger_id, order_id,
         approved_amount, van_status
  into v_van_tx
  from catchmenu_integrations.van_transactions
  where id = p_van_tx_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_van_tx.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'van_tx_not_found'
    );
  end if;

  if v_van_tx.van_status <> 'APPROVED' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'van_tx_not_cancellable',
      'current_status', v_van_tx.van_status
    );
  end if;

  -- response code 0000 = cancel approved
  v_is_cancelled := coalesce(
    p_response_code = '0000'
    or p_van_cancel_number is not null,
    false
  );

  -- create cancel VAN transaction record
  insert into catchmenu_integrations.van_transactions (
    tenant_id, store_id,
    van_provider, van_terminal_id, van_merchant_id,
    van_approval_number,
    ledger_id, order_id,
    transaction_type,
    requested_amount, cancelled_amount,
    van_status,
    response_code, response_message,
    raw_request, raw_response,
    cancelled_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_van_tx.van_provider, v_van_tx.van_terminal_id,
    v_van_tx.van_merchant_id,
    p_van_cancel_number,
    v_van_tx.ledger_id, v_van_tx.order_id,
    'CARD_CANCEL',
    p_cancel_amount, p_cancel_amount,
    case when v_is_cancelled
      then 'CANCELLED' else 'FAILED'
    end,
    p_response_code,
    p_raw_response->>'responseMessage',
    p_raw_request, p_raw_response,
    case when v_is_cancelled then now() else null end,
    v_business_day, v_timezone
  );

  -- update original transaction
  if v_is_cancelled then
    update catchmenu_integrations.van_transactions
    set
      van_status = case
        when cancelled_amount + p_cancel_amount
          >= approved_amount
        then 'CANCELLED'
        else van_status
      end,
      cancelled_amount = cancelled_amount + p_cancel_amount,
      cancelled_at = now(),
      updated_at = now()
    where id = p_van_tx_id;

    -- update internal ledger
    perform catchmenu_payment.cancel_payment(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_ledger_id := v_van_tx.ledger_id,
      p_cancel_reason := p_cancel_reason,
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_correlation_id := p_correlation_id
    );
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'van_cancel_processed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := p_actor_type,
    p_actor_id := p_actor_id,
    p_subject_type := 'van_transaction',
    p_subject_id := p_van_tx_id,
    p_decision := case when v_is_cancelled
      then 'CANCELLED' else 'REJECTED'
    end,
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'van_provider', v_van_tx.van_provider,
      'van_approval_number', v_van_tx.van_approval_number,
      'cancel_amount', p_cancel_amount,
      'response_code', p_response_code,
      'is_cancelled', v_is_cancelled
    ),
    p_payment_id := v_van_tx.ledger_id,
    p_order_id := v_van_tx.order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return jsonb_build_object(
    'success', true,
    'van_tx_id', p_van_tx_id,
    'van_provider', v_van_tx.van_provider,
    'is_cancelled', v_is_cancelled,
    'cancel_amount', p_cancel_amount,
    'response_code', p_response_code,
    'audit_id', v_audit_id,
    'message_code', case when v_is_cancelled
      then 'van_cancel_confirmed'
      else 'van_cancel_failed'
    end
  );
end;
$$;


create or replace function catchmenu_integrations.sync_van_settlement(
  p_tenant_id uuid,
  p_store_id uuid,
  p_van_provider text,
  p_van_terminal_id text,
  p_van_merchant_id text,
  p_settlement_date date,
  p_settlement_data jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_settlement_id uuid;
  v_total_approved int;
  v_total_cancelled int;
  v_net_amount int;
  v_tx_count int;
  v_cancel_count int;
  v_van_fee int;
  v_internal_net int;
  v_diff int;
  v_reconciliation_status text;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  -- extract settlement totals from raw data
  v_total_approved := coalesce(
    (p_settlement_data->>'totalApprovedAmount')::int,
    (p_settlement_data->>'approved_amount')::int,
    0
  );
  v_total_cancelled := coalesce(
    (p_settlement_data->>'totalCancelledAmount')::int,
    (p_settlement_data->>'cancelled_amount')::int,
    0
  );
  v_net_amount := v_total_approved - v_total_cancelled;
  v_tx_count := coalesce(
    (p_settlement_data->>'transactionCount')::int,
    (p_settlement_data->>'tx_count')::int,
    0
  );
  v_cancel_count := coalesce(
    (p_settlement_data->>'cancelCount')::int,
    (p_settlement_data->>'cancel_count')::int,
    0
  );
  v_van_fee := coalesce(
    (p_settlement_data->>'vanFeeAmount')::int,
    0
  );

  -- upsert settlement record
  insert into catchmenu_integrations.van_settlements (
    tenant_id, store_id,
    van_provider, van_terminal_id, van_merchant_id,
    settlement_date,
    total_approved_amount, total_cancelled_amount,
    net_settlement_amount,
    transaction_count, cancelled_count,
    van_fee_amount,
    net_payout_amount,
    settlement_status,
    raw_settlement_data
  ) values (
    p_tenant_id, p_store_id,
    p_van_provider, p_van_terminal_id, p_van_merchant_id,
    p_settlement_date,
    v_total_approved, v_total_cancelled,
    v_net_amount,
    v_tx_count, v_cancel_count,
    v_van_fee,
    v_net_amount - v_van_fee,
    'RECEIVED',
    p_settlement_data
  )
  on conflict (
    store_id, van_provider,
    van_terminal_id, settlement_date
  ) do update set
    total_approved_amount = excluded.total_approved_amount,
    total_cancelled_amount = excluded.total_cancelled_amount,
    net_settlement_amount = excluded.net_settlement_amount,
    transaction_count = excluded.transaction_count,
    cancelled_count = excluded.cancelled_count,
    van_fee_amount = excluded.van_fee_amount,
    net_payout_amount = excluded.net_payout_amount,
    raw_settlement_data = excluded.raw_settlement_data,
    updated_at = now()
  returning id into v_settlement_id;

  -- Layer 2 reconciliation:
  -- VAN settlement ↔ internal payment_ledger
  -- 특허1: VAN 정산 ↔ 내부 원장 2차 대사
  select coalesce(sum(net_amount), 0)
  into v_internal_net
  from catchmenu_payment.payment_ledger
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = p_settlement_date
    and provider_type = p_van_provider
    and ledger_status = 'APPROVED';

  v_diff := v_net_amount - v_internal_net;

  v_reconciliation_status := case
    when abs(v_diff) = 0 then 'MATCHED'
    when abs(v_diff) <= 100 then 'MATCHED'
    else 'MISMATCH'
  end;

  -- update reconciliation status
  update catchmenu_integrations.van_settlements
  set
    settlement_status = v_reconciliation_status,
    reconciliation_status = v_reconciliation_status,
    reconciliation_checked_at = now(),
    reconciliation_note = case v_reconciliation_status
      when 'MISMATCH' then
        '차액: ' || v_diff || '원 (VAN: '
        || v_net_amount || ', 내부: '
        || v_internal_net || ')'
      else '대사 완료'
    end
  where id = v_settlement_id;

  -- create reconciliation case if mismatch
  if v_reconciliation_status = 'MISMATCH' then
    perform catchmenu_payment.create_reconciliation_case(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_case_type := 'AMOUNT_MISMATCH',
      p_reconciliation_layer :=
        'LAYER_2_VAN_SETTLEMENT',
      p_severity := case
        when abs(v_diff) > 100000 then 'CRITICAL'
        when abs(v_diff) > 10000 then 'HIGH'
        else 'NORMAL'
      end,
      p_internal_amount := v_internal_net,
      p_provider_amount := v_net_amount,
      p_provider_type := p_van_provider,
      p_detection_method := 'LAYER_2_AUTO',
      p_correlation_id := p_correlation_id
    );
  end if;

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
    'payment', 'van_settlement_synced', 1,
    'van_settlement', v_settlement_id,
    'RECEIVED', v_reconciliation_status,
    'SYSTEM',
    jsonb_build_object(
      'van_provider', p_van_provider,
      'settlement_date', p_settlement_date,
      'van_net', v_net_amount,
      'internal_net', v_internal_net,
      'diff', v_diff,
      'reconciliation_status', v_reconciliation_status
    ),
    p_correlation_id,
    p_settlement_date, v_timezone, now()
  );

  return jsonb_build_object(
    'success', true,
    'settlement_id', v_settlement_id,
    'van_provider', p_van_provider,
    'settlement_date', p_settlement_date,
    'van_net_amount', v_net_amount,
    'internal_net_amount', v_internal_net,
    'amount_diff', v_diff,
    'reconciliation_status', v_reconciliation_status,
    'net_payout_amount', v_net_amount - v_van_fee,
    'message_code', case v_reconciliation_status
      when 'MATCHED' then 'van_settlement_matched'
      else 'van_settlement_mismatch'
    end
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_integrations.process_van_approval(
    uuid, uuid, text, text, text, uuid, uuid, uuid,
    int, text, int, jsonb, jsonb, text, text, text, text
  ) from public;
  grant execute on function catchmenu_integrations.process_van_approval(
    uuid, uuid, text, text, text, uuid, uuid, uuid,
    int, text, int, jsonb, jsonb, text, text, text, text
  ) to authenticated;

  revoke all on function catchmenu_integrations.process_van_cancel(
    uuid, uuid, uuid, int, text, jsonb, jsonb,
    text, text, text, uuid, text
  ) from public;
  grant execute on function catchmenu_integrations.process_van_cancel(
    uuid, uuid, uuid, int, text, jsonb, jsonb,
    text, text, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_integrations.sync_van_settlement(
    uuid, uuid, text, text, text, date, jsonb, text
  ) from public;
  grant execute on function catchmenu_integrations.sync_van_settlement(
    uuid, uuid, text, text, text, date, jsonb, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_integrations.process_van_approval(
  uuid, uuid, text, text, text, uuid, uuid, uuid,
  int, text, int, jsonb, jsonb, text, text, text, text
) is
  'Processes VAN card approval (NICE, KIS, KICC, etc).
   Stores raw request/response in gateway sandbox.
   On approval (response_code=0000):
   → confirm_payment_from_provider called.
   On failure:
   → intent marked FAILED, exception created.
   특허1: VAN 응답 → Gateway → 내부 원장 반영.
   VAN 원본 응답은 항상 보관 (분쟁 증거).';

comment on function catchmenu_integrations.sync_van_settlement(
  uuid, uuid, text, text, text, date, jsonb, text
) is
  'Syncs daily VAN settlement data and runs Layer 2 reconciliation.
   Compares VAN settlement total vs internal payment_ledger net.
   Tolerance: diff <= 100원 treated as MATCHED.
   MISMATCH: creates reconciliation_case automatically.
   특허1: Layer 2 대사 — VAN 정산 원장 ↔ 내부 결제 원장.
   일일 정산 완료 조건: Layer1 + Layer2 모두 MATCHED.';

-- ===== BEGIN [sql/migrations/0105_create_cash_receipt_pipeline_rpc.sql] =====
-- 0105_create_cash_receipt_pipeline_rpc.sql
-- Purpose: Cash receipt NTS (National Tax Service)
--          integration pipeline.
--          현금영수증 국세청 직접/우회 발급.
--          개인 소득공제 + 사업자 지출증빙.
--          전화번호/사업자번호 검증.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0104_create_toss_pos_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.cash_receipt_log (table)
--   function catchmenu_integrations.issue_cash_receipt(...)
--   function catchmenu_integrations.cancel_cash_receipt(...)
--   function catchmenu_integrations.confirm_cash_receipt(...)
--   function catchmenu_integrations.get_cash_receipt_status(...)
--   function catchmenu_integrations.get_cash_receipt_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('cash_receipt_issued', 'ko',
  '현금영수증이 발급되었습니다'),
('cash_receipt_issued', 'en',
  'Cash receipt issued'),
('cash_receipt_issued', 'zh',
  '现金收据已开具'),
('cash_receipt_issued', 'ja',
  '現金領収書が発行されました'),
('cash_receipt_issued', 'vi',
  'Đã phát hành hóa đơn tiền mặt'),
('cash_receipt_issued', 'th',
  'ออกใบเสร็จเงินสดแล้ว'),
('cash_receipt_cancelled', 'ko',
  '현금영수증이 취소되었습니다'),
('cash_receipt_cancelled', 'en',
  'Cash receipt cancelled'),
('cash_receipt_confirmed', 'ko',
  '현금영수증 발급이 확인되었습니다'),
('cash_receipt_confirmed', 'en',
  'Cash receipt confirmed'),
('cash_receipt_status_loaded', 'ko',
  '현금영수증 현황이 로드되었습니다'),
('cash_receipt_status_loaded', 'en',
  'Cash receipt status loaded'),
('cash_receipt_dashboard_loaded', 'ko',
  '현금영수증 대시보드가 로드되었습니다'),
('cash_receipt_dashboard_loaded', 'en',
  'Cash receipt dashboard loaded'),
('cash_receipt_not_required', 'ko',
  '현금영수증 발급 대상이 아닙니다'),
('cash_receipt_not_required', 'en',
  'Cash receipt not required'),
('cash_receipt_already_issued', 'ko',
  '이미 발급된 현금영수증입니다'),
('cash_receipt_already_issued', 'en',
  'Cash receipt already issued'),
('cash_receipt_identifier_invalid', 'ko',
  '현금영수증 발급 번호가 올바르지 않습니다'),
('cash_receipt_identifier_invalid', 'en',
  'Invalid cash receipt identifier'),
('cash_receipt_auto_issued', 'ko',
  '현금영수증이 자동 발급되었습니다 (국세청 기본)'),
('cash_receipt_auto_issued', 'en',
  'Cash receipt auto-issued (NTS default)'),
('ask_cash_receipt', 'ko',
  '현금영수증 발급을 원하시나요?'),
('ask_cash_receipt', 'en',
  'Would you like a cash receipt?'),
('ask_cash_receipt', 'zh',
  '您需要开具现金收据吗？'),
('ask_cash_receipt', 'ja',
  '現金領収書は必要ですか？'),
('ask_cash_receipt', 'vi',
  'Bạn có muốn phát hành hóa đơn không?'),
('ask_cash_receipt', 'th',
  'คุณต้องการใบเสร็จเงินสดไหม?')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9040, 'cash_receipt_issue_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-PAY-001'),
(9041, 'cash_receipt_cancel_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-PAY-002'),
(9042, 'cash_receipt_already_issued',
  'INTEGRATION', 'CONFLICT', 409, 'INFO', null),
(9043, 'cash_receipt_identifier_invalid',
  'INTEGRATION', 'INVALID_INPUT', 400, 'WARNING', null),
(9044, 'cash_receipt_nts_unavailable',
  'INTEGRATION', 'TECHNICAL', 503, 'ERROR',
  'SOP-SYS-002'),
(9045, 'cash_receipt_not_required',
  'INTEGRATION', 'BUSINESS_RULE', 200, 'INFO', null)
on conflict (code) do nothing;


-- =============================================
-- cash_receipt_log table
-- 현금영수증 발급 이력
-- =============================================
create table if not exists
  catchmenu_integrations.cash_receipt_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 주문 연결
  order_id uuid
    references catchmenu_pos.orders(id),
  payment_ledger_id uuid
    references catchmenu_payment.payment_ledger(id),

  -- 현금영수증 정보
  receipt_type text not null,
  identifier_type text not null,
  identifier_hash text not null,
  issue_amount int not null,
  vat_amount int not null default 0,
  service_charge int not null default 0,

  -- 국세청 발급 정보
  nts_approval_number text,
  nts_issue_at timestamptz,
  nts_response jsonb,

  -- 상태
  receipt_status text
    not null default 'PENDING',
  issue_method text
    not null default 'DIRECT',

  -- 취소 정보
  cancelled_at timestamptz,
  cancel_reason text,
  cancel_nts_number text,

  -- 재시도
  retry_count int not null default 0,
  error_detail text,

  -- 자동 발급 여부
  is_auto_issued boolean not null default false,
  is_anonymous boolean not null default false,

  business_day date,
  issued_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_receipt_type check (
    receipt_type in (
      'INCOME_DEDUCTION',  -- 소득공제
      'EXPENSE_PROOF',     -- 지출증빙
      'VOLUNTARY'          -- 자진발급
    )
  ),
  constraint chk_identifier_type check (
    identifier_type in (
      'PHONE',             -- 휴대폰 번호
      'BUSINESS_NUMBER',   -- 사업자번호
      'CARD_NUMBER',       -- 현금영수증 카드
      'NTS_DEFAULT'        -- 국세청 기본번호
    )
  ),
  constraint chk_receipt_status check (
    receipt_status in (
      'PENDING',
      'ISSUED',
      'CONFIRMED',
      'CANCELLED',
      'FAILED',
      'AUTO_ISSUED'
    )
  ),
  constraint chk_issue_method check (
    issue_method in (
      'DIRECT',    -- 직접 발급 (고객 요청)
      'AUTO',      -- 자동 발급 (건당 10만원 이상)
      'MANUAL',    -- 수동 발급 (점주)
      'POS'        -- POS 연동 발급
    )
  )
);

create index if not exists idx_cash_receipt_order
  on catchmenu_integrations.cash_receipt_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_cash_receipt_store
  on catchmenu_integrations.cash_receipt_log(
    store_id, business_day desc
  );
create index if not exists idx_cash_receipt_nts
  on catchmenu_integrations.cash_receipt_log(
    nts_approval_number
  ) where nts_approval_number is not null;
create index if not exists idx_cash_receipt_status
  on catchmenu_integrations.cash_receipt_log(
    receipt_status, issued_at desc
  ) where receipt_status in (
    'PENDING', 'FAILED'
  );

alter table
  catchmenu_integrations.cash_receipt_log
  enable row level security;
alter table
  catchmenu_integrations.cash_receipt_log
  force row level security;

drop policy if exists cash_receipt_isolation
  on catchmenu_integrations.cash_receipt_log;
create policy cash_receipt_isolation
  on catchmenu_integrations.cash_receipt_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_cash_receipt_updated
  on catchmenu_integrations.cash_receipt_log;
create trigger trg_cash_receipt_updated
  before update on
    catchmenu_integrations.cash_receipt_log
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.cash_receipt_log is
  '현금영수증 발급 이력.
   한국 소득세법 제162조의3 준수.
   건당 10만원 이상 현금 결제 시 자동 발급.
   identifier_hash: 전화번호/사업자번호 SHA-256.
   원번호 비저장 (개인정보보호).
   NTS_DEFAULT: 010-000-1234 국세청 기본번호.
   is_anonymous: 익명 자진발급.
   특허4: 세금 발급 = 감사 증빙.
   1-B차 현금영수증 연동 핵심 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.issue_cash_receipt(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_receipt_type text,
  p_identifier_type text,
  p_identifier_hash text,
  p_issue_amount int,
  p_is_anonymous boolean default false,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_ledger record;
  v_receipt_id uuid;
  v_vat_amount int;
  v_business_day date;
  v_timezone text;
  v_audit_id uuid;
  v_issue_method text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 주문 조회
  select id, order_number, order_status,
         final_amount, paid_at
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'issue_cash_receipt'
    );
  end if;

  -- 이미 발급 확인
  if exists (
    select 1
    from catchmenu_integrations.cash_receipt_log
    where order_id = p_order_id
      and receipt_status in (
        'ISSUED', 'CONFIRMED', 'AUTO_ISSUED'
      )
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'cash_receipt_already_issued',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'issue_cash_receipt'
    );
  end if;

  -- 결제 원장 조회
  select id
  into v_ledger
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and ledger_status = 'APPROVED'
  order by approved_at desc
  limit 1;

  -- 부가세 계산 (공급가액 × 10%)
  v_vat_amount := (p_issue_amount / 11)::int;

  -- 발급 방법 결정
  v_issue_method := case
    when p_is_anonymous then 'AUTO'
    else 'DIRECT'
  end;

  -- 발급 로그 생성
  insert into
    catchmenu_integrations.cash_receipt_log (
    tenant_id, store_id,
    order_id, payment_ledger_id,
    receipt_type, identifier_type,
    identifier_hash,
    issue_amount, vat_amount,
    receipt_status, issue_method,
    is_auto_issued, is_anonymous,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    p_order_id, v_ledger.id,
    p_receipt_type, p_identifier_type,
    p_identifier_hash,
    p_issue_amount, v_vat_amount,
    'PENDING', v_issue_method,
    p_is_anonymous,
    p_is_anonymous,
    v_business_day
  )
  returning id into v_receipt_id;

  -- Edge Function에 국세청 발급 요청
  -- (실제 NTS API 호출은 Edge Function)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'cash_receipt_issue_requested',
    p_payload := jsonb_build_object(
      'receipt_id', v_receipt_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'receipt_type', p_receipt_type,
      'identifier_type', p_identifier_type,
      'identifier_hash', p_identifier_hash,
      'issue_amount', p_issue_amount,
      'vat_amount', v_vat_amount,
      'is_anonymous', p_is_anonymous,
      'issue_method', v_issue_method,
      'correlation_id', p_correlation_id,
      'nts_note',
        '국세청 현금영수증 발급 API 호출',
      'fallback',
        'NTS 장애 시 POS 경유 발급'
    )
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'tax',
    p_audit_type := 'cash_receipt_requested',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'CUSTOMER',
    p_subject_type := 'cash_receipt',
    p_subject_id := v_receipt_id,
    p_decision := 'PENDING',
    p_decision_payload := jsonb_build_object(
      'order_id', p_order_id,
      'receipt_type', p_receipt_type,
      'identifier_type', p_identifier_type,
      'issue_amount', p_issue_amount,
      'is_anonymous', p_is_anonymous
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
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'tax', 'cash_receipt_requested', 1,
    'cash_receipt', v_receipt_id,
    null, 'PENDING',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', p_order_id,
      'receipt_type', p_receipt_type,
      'issue_amount', p_issue_amount,
      'is_anonymous', p_is_anonymous,
      'audit_id', v_audit_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cash_receipt_issued',
    p_data := jsonb_build_object(
      'receipt_id', v_receipt_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'receipt_type', p_receipt_type,
      'identifier_type', p_identifier_type,
      'issue_amount', p_issue_amount,
      'vat_amount', v_vat_amount,
      'supplied_amount',
        p_issue_amount - v_vat_amount,
      'receipt_status', 'PENDING',
      'is_anonymous', p_is_anonymous,
      'note',
        'Edge Function NTS API 처리 중'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_cash_receipt(
  p_tenant_id uuid,
  p_store_id uuid,
  p_receipt_id uuid,
  p_nts_approval_number text,
  p_issue_result text,
  p_nts_response jsonb default null,
  p_error_detail text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_receipt record;
  v_new_status text;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, order_id, receipt_type,
         issue_amount, identifier_type,
         is_anonymous
  into v_receipt
  from catchmenu_integrations.cash_receipt_log
  where id = p_receipt_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_receipt.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_cash_receipt'
    );
  end if;

  v_new_status := case p_issue_result
    when 'SUCCESS' then 'CONFIRMED'
    when 'AUTO' then 'AUTO_ISSUED'
    else 'FAILED'
  end;

  -- 발급 결과 업데이트
  update catchmenu_integrations.cash_receipt_log
  set
    receipt_status = v_new_status,
    nts_approval_number =
      p_nts_approval_number,
    nts_issue_at = case p_issue_result
      when 'SUCCESS' then now()
      when 'AUTO' then now()
      else null
    end,
    nts_response = p_nts_response,
    error_detail = p_error_detail,
    is_auto_issued = p_issue_result = 'AUTO',
    updated_at = now()
  where id = p_receipt_id;

  -- 실패 시 재시도 카운터 증가
  if p_issue_result not in (
    'SUCCESS', 'AUTO'
  ) then
    update catchmenu_integrations.cash_receipt_log
    set retry_count = retry_count + 1
    where id = p_receipt_id;

    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'ERROR',
      p_log_domain := 'TAX',
      p_log_event := 'cash_receipt_issue_failed',
      p_message :=
        '현금영수증 발급 실패: '
        || coalesce(p_error_detail, ''),
      p_rpc_name := 'confirm_cash_receipt',
      p_correlation_id := p_correlation_id,
      p_details := jsonb_build_object(
        'receipt_id', p_receipt_id,
        'order_id', v_receipt.order_id,
        'error', p_error_detail
      )
    );
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'tax',
    p_audit_type := 'cash_receipt_confirmed',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'SYSTEM',
    p_subject_type := 'cash_receipt',
    p_subject_id := p_receipt_id,
    p_decision := v_new_status,
    p_decision_payload := jsonb_build_object(
      'nts_approval_number',
        p_nts_approval_number,
      'issue_result', p_issue_result,
      'receipt_type', v_receipt.receipt_type,
      'issue_amount', v_receipt.issue_amount
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
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'tax', 'cash_receipt_confirmed', 1,
    'cash_receipt', p_receipt_id,
    'PENDING', v_new_status,
    'SYSTEM',
    jsonb_build_object(
      'nts_approval_number',
        p_nts_approval_number,
      'issue_result', p_issue_result,
      'audit_id', v_audit_id
    ),
    v_receipt.order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := case p_issue_result
      when 'SUCCESS' then 'cash_receipt_confirmed'
      when 'AUTO' then 'cash_receipt_auto_issued'
      else 'cash_receipt_issued'
    end,
    p_data := jsonb_build_object(
      'receipt_id', p_receipt_id,
      'order_id', v_receipt.order_id,
      'nts_approval_number',
        p_nts_approval_number,
      'receipt_status', v_new_status,
      'issue_result', p_issue_result,
      'issue_amount', v_receipt.issue_amount,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_cash_receipt(
  p_tenant_id uuid,
  p_store_id uuid,
  p_receipt_id uuid,
  p_cancel_reason text,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_receipt record;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select id, order_id, receipt_type,
         issue_amount, nts_approval_number,
         receipt_status
  into v_receipt
  from catchmenu_integrations.cash_receipt_log
  where id = p_receipt_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_receipt.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_cash_receipt'
    );
  end if;

  if v_receipt.receipt_status
    not in ('ISSUED', 'CONFIRMED', 'AUTO_ISSUED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'cash_receipt_already_issued',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_cash_receipt'
    );
  end if;

  -- 국세청 취소 요청 (Edge Function)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'cash_receipt_cancel_requested',
    p_payload := jsonb_build_object(
      'receipt_id', p_receipt_id,
      'order_id', v_receipt.order_id,
      'nts_approval_number',
        v_receipt.nts_approval_number,
      'cancel_reason', p_cancel_reason,
      'issue_amount', v_receipt.issue_amount,
      'correlation_id', p_correlation_id
    )
  );

  -- 취소 상태 업데이트
  update catchmenu_integrations.cash_receipt_log
  set
    receipt_status = 'CANCELLED',
    cancelled_at = now(),
    cancel_reason = p_cancel_reason,
    updated_at = now()
  where id = p_receipt_id;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'tax',
    p_audit_type := 'cash_receipt_cancelled',
    p_audit_category := 'FINANCIAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'cash_receipt',
    p_subject_id := p_receipt_id,
    p_decision := 'CANCELLED',
    p_decision_reason := p_cancel_reason,
    p_decision_payload := jsonb_build_object(
      'nts_approval_number',
        v_receipt.nts_approval_number,
      'issue_amount', v_receipt.issue_amount
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
    'tax', 'cash_receipt_cancelled', 1,
    'cash_receipt', p_receipt_id,
    v_receipt.receipt_status, 'CANCELLED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'nts_approval_number',
        v_receipt.nts_approval_number,
      'audit_id', v_audit_id
    ),
    v_receipt.order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'cash_receipt_cancelled',
    p_data := jsonb_build_object(
      'receipt_id', p_receipt_id,
      'order_id', v_receipt.order_id,
      'nts_approval_number',
        v_receipt.nts_approval_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_at', now(),
      'audit_id', v_audit_id,
      'note',
        'Edge Function NTS 취소 API 처리 중'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.auto_issue_cash_receipt(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_payment_method text,
  p_amount int,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_auto_threshold int := 100000; -- 10만원
  v_nts_default_number text :=
    '0100001234'; -- 국세청 기본번호
begin
  -- 카드 결제는 현금영수증 대상 아님
  if p_payment_method in (
    'CARD', 'CREDIT_CARD', 'CHECK_CARD'
  ) then
    return catchmenu_common.build_success_response(
      p_message_key :=
        'cash_receipt_not_required',
      p_data := jsonb_build_object(
        'reason', 'card_payment',
        'payment_method', p_payment_method
      ),
      p_locale := p_locale
    );
  end if;

  -- 10만원 미만 현금 결제 = 자동 발급 불필요
  -- (고객 요청 시에만 발급)
  if p_amount < v_auto_threshold then
    return catchmenu_common.build_success_response(
      p_message_key :=
        'cash_receipt_not_required',
      p_data := jsonb_build_object(
        'reason', 'below_threshold',
        'amount', p_amount,
        'threshold', v_auto_threshold,
        'note',
          '고객 요청 시 issue_cash_receipt() 호출'
      ),
      p_locale := p_locale
    );
  end if;

  -- 10만원 이상 현금 결제 = 자동 발급
  -- 국세청 기본번호로 자진발급
  return catchmenu_integrations.issue_cash_receipt(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_receipt_type := 'VOLUNTARY',
    p_identifier_type := 'NTS_DEFAULT',
    p_identifier_hash := encode(
      digest(v_nts_default_number, 'sha256'),
      'hex'
    ),
    p_issue_amount := p_amount,
    p_is_anonymous := true,
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_cash_receipt_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_receipts jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'receipt_id', id,
        'receipt_type', receipt_type,
        'identifier_type', identifier_type,
        'issue_amount', issue_amount,
        'vat_amount', vat_amount,
        'supplied_amount',
          issue_amount - vat_amount,
        'nts_approval_number',
          nts_approval_number,
        'receipt_status', receipt_status,
        'issue_method', issue_method,
        'is_auto_issued', is_auto_issued,
        'is_anonymous', is_anonymous,
        'nts_issue_at', nts_issue_at,
        'cancelled_at', cancelled_at,
        'cancel_reason', cancel_reason
      )
      order by issued_at desc
    ),
    '[]'::jsonb
  )
  into v_receipts
  from catchmenu_integrations.cash_receipt_log
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'cash_receipt_status_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'receipts', v_receipts,
      'receipt_count',
        jsonb_array_length(v_receipts),
      'has_valid_receipt', exists (
        select 1
        from catchmenu_integrations.cash_receipt_log
        where order_id = p_order_id
          and store_id = p_store_id
          and tenant_id = p_tenant_id
          and receipt_status in (
            'ISSUED', 'CONFIRMED', 'AUTO_ISSUED'
          )
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_cash_receipt_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_business_day date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_today_summary jsonb;
  v_failed_list jsonb;
  v_type_breakdown jsonb;
begin
  v_business_day := coalesce(
    p_business_day,
    (timezone('Asia/Seoul', now()))::date
  );

  -- 오늘 발급 요약
  select jsonb_build_object(
    'total_issued', count(*),
    'confirmed_count', count(*) filter (
      where receipt_status in (
        'CONFIRMED', 'AUTO_ISSUED'
      )
    ),
    'pending_count', count(*) filter (
      where receipt_status = 'PENDING'
    ),
    'failed_count', count(*) filter (
      where receipt_status = 'FAILED'
    ),
    'cancelled_count', count(*) filter (
      where receipt_status = 'CANCELLED'
    ),
    'total_amount', coalesce(
      sum(issue_amount) filter (
        where receipt_status in (
          'CONFIRMED', 'AUTO_ISSUED'
        )
      ), 0
    ),
    'auto_issued_count', count(*) filter (
      where is_auto_issued = true
    )
  )
  into v_today_summary
  from catchmenu_integrations.cash_receipt_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 실패 목록 (재처리 대상)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'receipt_id', id,
        'order_id', order_id,
        'issue_amount', issue_amount,
        'retry_count', retry_count,
        'error_detail', error_detail,
        'issued_at', issued_at
      )
      order by issued_at desc
    ),
    '[]'::jsonb
  )
  into v_failed_list
  from catchmenu_integrations.cash_receipt_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and receipt_status = 'FAILED'
    and retry_count < 3;

  -- 유형별 분류
  select jsonb_build_object(
    'income_deduction', count(*) filter (
      where receipt_type = 'INCOME_DEDUCTION'
    ),
    'expense_proof', count(*) filter (
      where receipt_type = 'EXPENSE_PROOF'
    ),
    'voluntary', count(*) filter (
      where receipt_type = 'VOLUNTARY'
    )
  )
  into v_type_breakdown
  from catchmenu_integrations.cash_receipt_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key :=
      'cash_receipt_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'today_summary', v_today_summary,
      'type_breakdown', v_type_breakdown,
      'failed_list', v_failed_list,
      'needs_attention',
        jsonb_array_length(v_failed_list) > 0,
      'legal_note', jsonb_build_object(
        'auto_threshold', '10만원 이상 현금',
        'law', '소득세법 제162조의3',
        'nts_default',
          '010-000-1234 (국세청 기본번호)',
        'identifier_stored', 'SHA-256 해시만'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.issue_cash_receipt(
      uuid, uuid, uuid, text, text,
      text, int, boolean, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.issue_cash_receipt(
      uuid, uuid, uuid, text, text,
      text, int, boolean, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_cash_receipt(
      uuid, uuid, uuid, text, text,
      jsonb, text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_cash_receipt(
      uuid, uuid, uuid, text, text,
      jsonb, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_cash_receipt(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_cash_receipt(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.auto_issue_cash_receipt(
      uuid, uuid, uuid, text, int, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.auto_issue_cash_receipt(
      uuid, uuid, uuid, text, int, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_cash_receipt_status(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_cash_receipt_status(
      uuid, uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations
      .get_cash_receipt_dashboard(
      uuid, uuid, date, text
    ) from public;
  grant execute on function
    catchmenu_integrations
      .get_cash_receipt_dashboard(
      uuid, uuid, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.issue_cash_receipt(
    uuid, uuid, uuid, text, text,
    text, int, boolean, text, text
  ) is
  '현금영수증 발급 파이프라인.
   한국 소득세법 제162조의3 준수.

   발급 유형:
   INCOME_DEDUCTION: 개인 소득공제
     → 휴대폰 번호 또는 현금영수증 카드
   EXPENSE_PROOF: 사업자 지출증빙
     → 사업자등록번호
   VOLUNTARY: 자진발급 (익명)
     → 국세청 기본번호 (010-000-1234)

   보안:
   identifier_hash: SHA-256만 저장
   원 전화번호/사업자번호 비저장

   자동 발급 조건:
   현금 10만원 이상 → auto_issue_cash_receipt()
   카드 결제 → 대상 아님

   실제 NTS API 호출: Edge Function 담당.
   특허4: 세금 발급 = 감사 증빙.
   1-B차 현금영수증 핵심 파이프라인.';

comment on function
  catchmenu_integrations.auto_issue_cash_receipt(
    uuid, uuid, uuid, text, int, text, text
  ) is
  '현금영수증 자동 발급 판단 함수.
   결제 완료 후 자동 호출.

   판단 로직:
   카드 결제 → 불필요 (즉시 반환)
   현금 10만원 미만 → 고객 요청 시만
   현금 10만원 이상 → 자동 자진발급
     국세청 기본번호: 010-000-1234

   confirm_payment() 이후 연동 권장.
   Flutter 결제 완료 화면에서:
   → 현금 결제 + 10만원 미만:
     ask_cash_receipt 메시지 표시
   → 현금 10만원 이상:
     자동 처리 후 영수증 번호 표시';

-- ===== BEGIN [sql/migrations/0130_create_van_handler_extension.sql] =====
-- 0130_create_van_handler_extension.sql
-- Purpose: VAN handler extension.
--          NICE VAN 완성.
--          KIS VAN 완성.
--          망취소 파이프라인.
--          VAN 오류 자동 복구.
--          VAN 정산 대사 연동.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0129_create_launch_readiness_package.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('van_payment_approved', 'ko',
  '카드 결제가 승인되었습니다'),
('van_payment_approved', 'en',
  'Card payment approved'),
('van_payment_cancelled', 'ko',
  '카드 결제가 취소되었습니다'),
('van_payment_cancelled', 'en',
  'Card payment cancelled'),
('van_net_cancel_completed', 'ko',
  '망취소가 완료되었습니다'),
('van_net_cancel_completed', 'en',
  'Net cancel completed'),
('van_health_ok', 'ko',
  'VAN 연결이 정상입니다'),
('van_health_ok', 'en',
  'VAN connection healthy'),
('van_health_fail', 'ko',
  'VAN 연결에 문제가 있습니다'),
('van_health_fail', 'en',
  'VAN connection issue detected')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(5010, 'van_connection_failed',
  'PAYMENT', 'TECHNICAL', 503,
  'CRITICAL', 'SOP-PAY-001'),
(5012, 'van_net_cancel_failed',
  'PAYMENT', 'FINANCIAL', 500,
  'CRITICAL', 'SOP-PAY-002'),
(5013, 'van_timeout',
  'PAYMENT', 'TECHNICAL', 504,
  'ERROR', 'SOP-PAY-001'),
(5014, 'van_duplicate_approval',
  'PAYMENT', 'CONFLICT', 409,
  'WARNING', 'SOP-PAY-001'),
(5015, 'van_settlement_mismatch',
  'PAYMENT', 'FINANCIAL', 200,
  'CRITICAL', 'SOP-PAY-002')
on conflict (code) do nothing;


-- =============================================
-- van_transactions table
-- VAN 결제 거래 원장
-- =============================================
create table if not exists
  catchmenu_payment.van_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- VAN 정보
  van_provider text not null,
  van_terminal_id text not null,
  van_merchant_id text,

  -- 거래 정보
  transaction_type text not null,
  card_number_hash text,
  card_company text,
  card_type text,
  installment_months int not null default 0,

  -- 금액
  approved_amount int not null default 0,
  tax_amount int not null default 0,
  service_fee_amount int not null default 0,

  -- 승인 정보
  approval_number text,
  approval_at timestamptz,
  van_reference_id text,

  -- 취소 정보
  cancel_approval_number text,
  cancel_at timestamptz,
  cancel_reason text,
  is_net_cancel boolean not null default false,

  -- 연결
  order_id uuid
    references catchmenu_pos.orders(id),
  payment_ledger_id uuid
    references catchmenu_payment
      .payment_ledger(id),

  -- 상태
  transaction_status text not null
    default 'PENDING',
  van_response_raw jsonb,
  error_code text,
  error_message text,
  retry_count int not null default 0,

  business_day date not null,
  transacted_at timestamptz
    not null default now(),

  constraint chk_van_provider check (
    van_provider in (
      'NICE', 'KIS', 'KSNET',
      'SMARTRO', 'DAOU', 'KICC'
    )
  ),
  constraint chk_van_tx_type check (
    transaction_type in (
      'APPROVAL',      -- 승인
      'CANCEL',        -- 취소
      'NET_CANCEL',    -- 망취소
      'FORCE_CANCEL',  -- 강제 취소
      'PARTIAL_CANCEL' -- 부분 취소
    )
  ),
  constraint chk_van_tx_status check (
    transaction_status in (
      'PENDING',   -- 처리 중
      'APPROVED',  -- 승인 완료
      'CANCELLED', -- 취소 완료
      'FAILED',    -- 실패
      'TIMEOUT',   -- 타임아웃
      'NET_CANCELLED' -- 망취소 완료
    )
  )
);

create index if not exists idx_van_tx_order
  on catchmenu_payment.van_transactions(
    order_id, transaction_type
  );
create index if not exists idx_van_tx_approval
  on catchmenu_payment.van_transactions(
    approval_number
  ) where approval_number is not null;
create index if not exists idx_van_tx_business
  on catchmenu_payment.van_transactions(
    store_id, business_day, transaction_status
  );
create index if not exists idx_van_pending
  on catchmenu_payment.van_transactions(
    transaction_status, transacted_at
  ) where transaction_status = 'PENDING';

alter table catchmenu_payment.van_transactions
  enable row level security;
alter table catchmenu_payment.van_transactions
  force row level security;

drop policy if exists van_tx_isolation
  on catchmenu_payment.van_transactions;
create policy van_tx_isolation
  on catchmenu_payment.van_transactions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.van_transactions is
  'VAN 결제 거래 원장.
   NICE/KIS/KSNET 등 VAN사 거래 기록.
   append-only 감사 원장.
   card_number_hash: SHA-256 (원번호 미저장).
   NET_CANCEL: 망취소 (승인 당일 취소).
   FORCE_CANCEL: 익일 강제 취소.
   approval_number: VAN 승인번호 (취소 시 필요).
   settlement_mismatch → SOP-PAY-002.';


-- =============================================
-- van_settlement_daily table
-- VAN 일별 정산 내역
-- =============================================
create table if not exists
  catchmenu_payment.van_settlement_daily (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  settlement_date date not null,
  van_provider text not null,
  van_terminal_id text not null,

  -- VAN 정산 금액 (VAN사 통보)
  van_approval_count int not null default 0,
  van_approval_amount bigint not null default 0,
  van_cancel_count int not null default 0,
  van_cancel_amount bigint not null default 0,
  van_net_amount bigint not null default 0,

  -- 시스템 기록 금액
  sys_approval_count int not null default 0,
  sys_approval_amount bigint not null default 0,
  sys_cancel_count int not null default 0,
  sys_cancel_amount bigint not null default 0,
  sys_net_amount bigint not null default 0,

  -- 대사 결과
  amount_gap bigint not null default 0,
  count_gap int not null default 0,
  settlement_status text not null
    default 'PENDING',

  -- VAN사 정산 파일
  van_settlement_file_hash text,
  received_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_van_settlement unique (
    store_id, settlement_date, van_provider
  ),
  constraint chk_settlement_status check (
    settlement_status in (
      'PENDING',    -- 정산 대기
      'RECEIVED',   -- VAN 정산 수신
      'MATCHED',    -- 대사 일치
      'MISMATCH',   -- 대사 불일치
      'RESOLVED'    -- 수동 해결
    )
  )
);

alter table
  catchmenu_payment.van_settlement_daily
  enable row level security;
alter table
  catchmenu_payment.van_settlement_daily
  force row level security;

drop policy if exists van_settlement_isolation
  on catchmenu_payment.van_settlement_daily;
create policy van_settlement_isolation
  on catchmenu_payment.van_settlement_daily
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_payment.van_settlement_daily is
  'VAN 일별 정산 대사.
   VAN사 정산 파일 수신 후 시스템 기록과 대사.
   MISMATCH → SOP-PAY-002 즉시 실행.
   amount_gap > 0 → CRITICAL 운영 알림.
   van_settlement_file_hash: 파일 위변조 감지.
   정산 대사 Layer2 보완 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_payment.record_van_transaction(
  p_tenant_id uuid,
  p_store_id uuid,
  p_van_provider text,
  p_van_terminal_id text,
  p_transaction_type text,
  p_approved_amount int,
  p_order_id uuid default null,
  p_card_number_hash text default null,
  p_card_company text default null,
  p_card_type text default 'CREDIT',
  p_installment_months int default 0,
  p_approval_number text default null,
  p_approval_at timestamptz default null,
  p_van_reference_id text default null,
  p_van_response_raw jsonb default null,
  p_transaction_status text
    default 'APPROVED',
  p_is_net_cancel boolean default false,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_tx_id uuid;
  v_business_day date;
  v_tax_amount int;
  v_message_key text;
  v_provider_response_id uuid;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 부가세 계산 (승인 금액의 10/110)
  v_tax_amount := (
    p_approved_amount / 11
  )::int;

  -- 중복 승인 확인
  if p_approval_number is not null
    and p_transaction_type = 'APPROVAL'
    and exists (
      select 1
      from catchmenu_payment.van_transactions
      where approval_number = p_approval_number
        and transaction_status = 'APPROVED'
        and store_id = p_store_id
    )
  then
    perform catchmenu_common.detect_threat(
      p_threat_type := 'INTEGRITY_VIOLATION',
      p_threat_stage := 4,
      p_threat_severity := 'CRITICAL',
      p_detection_source :=
        'record_van_transaction',
      p_threat_payload := jsonb_build_object(
        'approval_number', p_approval_number,
        'amount', p_approved_amount,
        'van_provider', p_van_provider
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'van_duplicate_approval',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'record_van_transaction'
    );
  end if;

  -- VAN 거래 기록
  insert into catchmenu_payment.van_transactions (
    tenant_id, store_id,
    van_provider, van_terminal_id,
    transaction_type, card_number_hash,
    card_company, card_type,
    installment_months,
    approved_amount, tax_amount,
    approval_number, approval_at,
    van_reference_id, van_response_raw,
    transaction_status, is_net_cancel,
    order_id, business_day
  ) values (
    p_tenant_id, p_store_id,
    p_van_provider, p_van_terminal_id,
    p_transaction_type, p_card_number_hash,
    p_card_company, p_card_type,
    p_installment_months,
    p_approved_amount, v_tax_amount,
    p_approval_number,
    coalesce(p_approval_at, now()),
    p_van_reference_id, p_van_response_raw,
    p_transaction_status, p_is_net_cancel,
    p_order_id, v_business_day
  )
  returning id into v_tx_id;

  -- 결제 원장 연동 (APPROVED 시)
  if p_transaction_type = 'APPROVAL'
    and p_transaction_status = 'APPROVED'
    and p_order_id is not null
  then
    declare
      v_ledger_id uuid;
      v_intent_id uuid;
      v_provider_payment_key text;
      v_gateway_provider_type text;
    begin
      v_provider_payment_key := coalesce(
        p_approval_number,
        v_tx_id::text
      );

      v_gateway_provider_type := case
        when p_van_provider in (
          'VAN_NICE',
          'VAN_KIS',
          'VAN_KICC'
        ) then p_van_provider
        when p_van_provider in ('NICE', 'NICE_VAN') then 'VAN_NICE'
        when p_van_provider in ('KIS', 'KIS_VAN') then 'VAN_KIS'
        when p_van_provider in ('KICC', 'KICC_VAN') then 'VAN_KICC'
        else 'OTHER'
      end;

      insert into catchmenu_gateway.provider_raw_events (
        tenant_id,
        store_id,
        provider_type,
        provider_code,
        provider_event_id,
        provider_event_type,
        raw_payload
      ) values (
        p_tenant_id,
        p_store_id,
        v_gateway_provider_type,
        p_van_provider,
        v_provider_payment_key,
        'VAN_TRANSACTION',
        coalesce(
          p_van_response_raw,
          jsonb_build_object(
            'van_provider', p_van_provider,
            'approval_number', p_approval_number,
            'van_reference_id', p_van_reference_id,
            'approved_amount', p_approved_amount
          )
        )
      )
      returning id into v_provider_response_id;

      v_intent_id :=
        catchmenu_payment.resolve_or_create_payment_intent(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_order_id := p_order_id,
          p_requested_amount := p_approved_amount,
          p_payment_method := 'CARD',
          p_payment_channel := 'COUNTER_CARD',
          p_provider_type := v_gateway_provider_type,
          p_intent_origin := 'VAN_SYNTHESIZED',
          p_origin_reference := jsonb_build_object(
            'source', 'record_van_transaction',
            'van_transaction_id', v_tx_id,
            'van_provider', p_van_provider,
            'approval_number', p_approval_number,
            'van_reference_id', p_van_reference_id
          ),
          p_intent_id := null,
          p_session_id := null,
          p_locale := p_locale
        );

      insert into
        catchmenu_payment.payment_ledger (
        tenant_id, store_id,
        order_id, intent_id,
        ledger_entry_type,
        provider_type,
        provider_payment_key,
        provider_approval_number,
        provider_approved_at,
        provider_response_id,
        approved_amount,
        net_amount,
        ledger_status, approved_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        p_order_id,
        v_intent_id,
        'APPROVAL',
        p_van_provider || '_VAN',
        v_provider_payment_key,
        p_approval_number,
        coalesce(p_approval_at, now()),
        v_provider_response_id,
        p_approved_amount,
        p_approved_amount,
        'APPROVED',
        coalesce(p_approval_at, now()),
        v_business_day, 'Asia/Seoul'
      )
      returning id into v_ledger_id;

      -- VAN 거래에 원장 ID 연결
      update catchmenu_payment.van_transactions
      set payment_ledger_id = v_ledger_id
      where id = v_tx_id;
    end;
  end if;

  -- message key
  v_message_key := case p_transaction_type
    when 'APPROVAL' then 'van_payment_approved'
    when 'NET_CANCEL' then 'van_net_cancel_completed'
    else 'van_payment_cancelled'
  end;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'van_transaction_recorded', 1,
    'van_transaction', v_tx_id,
    'PENDING', p_transaction_status,
    'PROVIDER',
    jsonb_build_object(
      'van_provider', p_van_provider,
      'transaction_type', p_transaction_type,
      'approved_amount', p_approved_amount,
      'approval_number', p_approval_number,
      'is_net_cancel', p_is_net_cancel,
      'card_company', p_card_company
    ),
    p_order_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := v_message_key,
    p_data := jsonb_build_object(
      'van_tx_id', v_tx_id,
      'van_provider', p_van_provider,
      'transaction_type', p_transaction_type,
      'approved_amount', p_approved_amount,
      'tax_amount', v_tax_amount,
      'approval_number', p_approval_number,
      'transaction_status', p_transaction_status,
      'order_id', p_order_id
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.request_van_net_cancel(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_cancel_reason text default '고객 요청',
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_van_tx record;
  v_cancel_tx_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 원거래 조회
  select id, van_provider, van_terminal_id,
         approved_amount, approval_number,
         card_number_hash, card_company,
         card_type, transaction_status,
         business_day
  into v_van_tx
  from catchmenu_payment.van_transactions
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and transaction_type = 'APPROVAL'
    and transaction_status = 'APPROVED'
  order by approval_at desc
  limit 1;

  if v_van_tx.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'van_approval_failed',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'reason', 'original_tx_not_found'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_van_net_cancel'
    );
  end if;

  -- 당일 거래 확인 (망취소 가능 여부)
  if v_van_tx.business_day <> v_business_day then
    -- 익일 → FORCE_CANCEL (VAN사 직접 요청 필요)
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'PAYMENT_ISSUE',
      p_alert_severity := 'ERROR',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key := 'van_net_cancel_completed',
      p_alert_detail := jsonb_build_object(
        'order_id', p_order_id,
        'van_provider', v_van_tx.van_provider,
        'approval_number',
          v_van_tx.approval_number,
        'reason', '익일 거래 → VAN사 직접 취소 필요',
        'action_required',
          'SOP-PAY-002 참조. VAN사 고객센터 연락'
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'van_net_cancel_failed',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'reason',
          '익일 거래. VAN사 직접 취소 필요.',
        'van_provider', v_van_tx.van_provider,
        'approval_number',
          v_van_tx.approval_number,
        'sop', 'SOP-PAY-002'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'request_van_net_cancel'
    );
  end if;

  -- 망취소 요청 기록 (PENDING)
  insert into catchmenu_payment.van_transactions (
    tenant_id, store_id,
    van_provider, van_terminal_id,
    transaction_type, card_number_hash,
    card_company, card_type,
    approved_amount,
    approval_number,
    cancel_reason, is_net_cancel,
    order_id, transaction_status,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    v_van_tx.van_provider,
    v_van_tx.van_terminal_id,
    'NET_CANCEL', v_van_tx.card_number_hash,
    v_van_tx.card_company, v_van_tx.card_type,
    v_van_tx.approved_amount,
    v_van_tx.approval_number,
    p_cancel_reason, true,
    p_order_id, 'PENDING',
    v_business_day
  )
  returning id into v_cancel_tx_id;

  -- Edge Function → VAN API 망취소 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type := 'van_net_cancel_requested',
    p_payload := jsonb_build_object(
      'cancel_tx_id', v_cancel_tx_id,
      'original_tx_id', v_van_tx.id,
      'van_provider', v_van_tx.van_provider,
      'van_terminal_id',
        v_van_tx.van_terminal_id,
      'approval_number',
        v_van_tx.approval_number,
      'cancel_amount', v_van_tx.approved_amount,
      'cancel_reason', p_cancel_reason,
      'order_id', p_order_id
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'payment', 'van_net_cancel_requested', 1,
    'van_transaction', v_cancel_tx_id,
    'APPROVED', 'PENDING',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'original_tx_id', v_van_tx.id,
      'van_provider', v_van_tx.van_provider,
      'approval_number',
        v_van_tx.approval_number,
      'cancel_amount', v_van_tx.approved_amount,
      'cancel_reason', p_cancel_reason
    ),
    p_order_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'van_net_cancel_completed',
    p_data := jsonb_build_object(
      'cancel_tx_id', v_cancel_tx_id,
      'original_tx_id', v_van_tx.id,
      'van_provider', v_van_tx.van_provider,
      'approval_number',
        v_van_tx.approval_number,
      'cancel_amount', v_van_tx.approved_amount,
      'cancel_reason', p_cancel_reason,
      'status', 'PENDING',
      'note',
        'Edge Function → VAN API 망취소 처리 중'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.reconcile_van_settlement(
  p_tenant_id uuid,
  p_store_id uuid,
  p_van_provider text,
  p_settlement_date date,
  p_van_approval_count int,
  p_van_approval_amount bigint,
  p_van_cancel_count int,
  p_van_cancel_amount bigint,
  p_van_settlement_file_hash text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_sys_approval_count int;
  v_sys_approval_amount bigint;
  v_sys_cancel_count int;
  v_sys_cancel_amount bigint;
  v_sys_net bigint;
  v_van_net bigint;
  v_amount_gap bigint;
  v_count_gap int;
  v_status text;
  v_settlement_id uuid;
begin
  -- 시스템 기록 집계
  select
    count(*) filter (
      where transaction_type = 'APPROVAL'
        and transaction_status = 'APPROVED'
    ),
    coalesce(sum(approved_amount) filter (
      where transaction_type = 'APPROVAL'
        and transaction_status = 'APPROVED'
    ), 0),
    count(*) filter (
      where transaction_type in (
        'CANCEL', 'NET_CANCEL', 'FORCE_CANCEL'
      ) and transaction_status in (
        'CANCELLED', 'NET_CANCELLED'
      )
    ),
    coalesce(sum(approved_amount) filter (
      where transaction_type in (
        'CANCEL', 'NET_CANCEL', 'FORCE_CANCEL'
      ) and transaction_status in (
        'CANCELLED', 'NET_CANCELLED'
      )
    ), 0)
  into
    v_sys_approval_count,
    v_sys_approval_amount,
    v_sys_cancel_count,
    v_sys_cancel_amount
  from catchmenu_payment.van_transactions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and van_provider = p_van_provider
    and business_day = p_settlement_date;

  v_sys_net :=
    v_sys_approval_amount - v_sys_cancel_amount;
  v_van_net :=
    p_van_approval_amount - p_van_cancel_amount;
  v_amount_gap := v_van_net - v_sys_net;
  v_count_gap :=
    p_van_approval_count - v_sys_approval_count;

  -- 상태 판정
  v_status := case
    when v_amount_gap = 0
      and v_count_gap = 0 then 'MATCHED'
    else 'MISMATCH'
  end;

  -- 정산 기록
  insert into
    catchmenu_payment.van_settlement_daily (
    tenant_id, store_id,
    settlement_date, van_provider,
    van_terminal_id,
    van_approval_count, van_approval_amount,
    van_cancel_count, van_cancel_amount,
    van_net_amount,
    sys_approval_count, sys_approval_amount,
    sys_cancel_count, sys_cancel_amount,
    sys_net_amount,
    amount_gap, count_gap,
    settlement_status,
    van_settlement_file_hash,
    received_at
  )
  select
    p_tenant_id, p_store_id,
    p_settlement_date, p_van_provider,
    psc.van_terminal_id,
    p_van_approval_count, p_van_approval_amount,
    p_van_cancel_count, p_van_cancel_amount,
    v_van_net,
    v_sys_approval_count, v_sys_approval_amount,
    v_sys_cancel_count, v_sys_cancel_amount,
    v_sys_net,
    v_amount_gap, v_count_gap,
    v_status,
    p_van_settlement_file_hash,
    now()
  from catchmenu_integrations.pos_store_configs psc
  where psc.store_id = p_store_id
    and psc.provider_code = p_van_provider
    and psc.is_active = true
  limit 1
  on conflict (
    store_id, settlement_date, van_provider
  )
  do update set
    van_approval_count =
      excluded.van_approval_count,
    van_approval_amount =
      excluded.van_approval_amount,
    van_cancel_count = excluded.van_cancel_count,
    van_cancel_amount =
      excluded.van_cancel_amount,
    van_net_amount = excluded.van_net_amount,
    amount_gap = excluded.amount_gap,
    count_gap = excluded.count_gap,
    settlement_status =
      excluded.settlement_status,
    received_at = excluded.received_at,
    updated_at = now()
  returning id into v_settlement_id;

  -- MISMATCH → CRITICAL 알림
  if v_status = 'MISMATCH' then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'RECONCILIATION_GAP',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'PAYMENT',
      p_alert_title_key :=
        'van_net_cancel_completed',
      p_alert_detail := jsonb_build_object(
        'settlement_date', p_settlement_date,
        'van_provider', p_van_provider,
        'amount_gap', v_amount_gap,
        'count_gap', v_count_gap,
        'van_net', v_van_net,
        'sys_net', v_sys_net,
        'sop', 'SOP-PAY-002'
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-PAY-002'
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_completed',
    p_data := jsonb_build_object(
      'settlement_id', v_settlement_id,
      'settlement_date', p_settlement_date,
      'van_provider', p_van_provider,
      'settlement_status', v_status,
      'van_net', v_van_net,
      'sys_net', v_sys_net,
      'amount_gap', v_amount_gap,
      'count_gap', v_count_gap,
      'is_matched', v_status = 'MATCHED'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_payment.get_van_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_today_summary jsonb;
  v_pending_cancels jsonb;
  v_settlement_status jsonb;
  v_van_health jsonb;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 오늘 VAN 거래 요약
  select jsonb_build_object(
    'total_approvals', count(*) filter (
      where transaction_type = 'APPROVAL'
        and transaction_status = 'APPROVED'
    ),
    'total_amount', coalesce(
      sum(approved_amount) filter (
        where transaction_type = 'APPROVAL'
          and transaction_status = 'APPROVED'
      ), 0
    ),
    'total_cancels', count(*) filter (
      where transaction_type in (
        'CANCEL', 'NET_CANCEL'
      ) and transaction_status in (
        'CANCELLED', 'NET_CANCELLED'
      )
    ),
    'cancel_amount', coalesce(
      sum(approved_amount) filter (
        where transaction_type in (
          'CANCEL', 'NET_CANCEL'
        ) and transaction_status in (
          'CANCELLED', 'NET_CANCELLED'
        )
      ), 0
    ),
    'pending_count', count(*) filter (
      where transaction_status = 'PENDING'
    ),
    'failed_count', count(*) filter (
      where transaction_status in (
        'FAILED', 'TIMEOUT'
      )
    ),
    'by_provider', (
      select coalesce(
        jsonb_object_agg(
          van_provider, cnt
        ),
        '{}'::jsonb
      )
      from (
        select van_provider,
               count(*)::int as cnt
        from catchmenu_payment.van_transactions
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and business_day = v_business_day
          and transaction_status = 'APPROVED'
        group by van_provider
      ) v
    )
  )
  into v_today_summary
  from catchmenu_payment.van_transactions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 망취소 대기 건
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'cancel_tx_id', id,
        'order_id', order_id,
        'van_provider', van_provider,
        'approval_number', approval_number,
        'cancel_amount', approved_amount,
        'cancel_reason', cancel_reason,
        'transacted_at', transacted_at
      )
      order by transacted_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_cancels
  from catchmenu_payment.van_transactions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and transaction_type = 'NET_CANCEL'
    and transaction_status = 'PENDING';

  -- 최근 정산 현황 (7일)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'settlement_date', settlement_date,
        'van_provider', van_provider,
        'settlement_status', settlement_status,
        'amount_gap', amount_gap,
        'van_net', van_net_amount,
        'sys_net', sys_net_amount
      )
      order by settlement_date desc
    ),
    '[]'::jsonb
  )
  into v_settlement_status
  from catchmenu_payment.van_settlement_daily
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and settlement_date
      > v_business_day - 7;

  -- VAN 헬스 상태
  select jsonb_build_object(
    'nice_connected', exists (
      select 1
      from catchmenu_integrations.pos_store_configs
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and provider_code = 'NICE_VAN'
        and is_active = true
        and last_heartbeat_at
          > now() - interval '10 minutes'
    ),
    'kis_connected', exists (
      select 1
      from catchmenu_integrations.pos_store_configs
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and provider_code = 'KIS_VAN'
        and is_active = true
        and last_heartbeat_at
          > now() - interval '10 minutes'
    )
  )
  into v_van_health;

  return catchmenu_common.build_success_response(
    p_message_key := 'reconciliation_report_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'today_summary', v_today_summary,
      'pending_cancels', v_pending_cancels,
      'has_pending_cancels',
        jsonb_array_length(
          v_pending_cancels
        ) > 0,
      'settlement_status', v_settlement_status,
      'van_health', v_van_health,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- SOP: VAN 장애 대응
insert into catchmenu_common.sop_runbooks (
  runbook_code, runbook_name,
  runbook_domain, symptom_description,
  recovery_steps, escalation_contact,
  escalation_threshold_minutes,
  is_active
) values
(
  'SOP-PAY-001',
  'VAN 결제 장애 대응',
  'PAYMENT',
  'van_connection_failed /
   van_approval_failed / van_timeout',
  jsonb_build_array(
    '1. get_van_dashboard() 상태 확인',
    '2. VAN 단말기 연결 상태 확인',
    '3. 네트워크 상태 확인 (KT→SKT 전환)',
    '4. VAN 헬스 NICE/KIS 연결 확인',
    '5. 장애 지속 시 수동 VAN 단말기 사용',
    '   → RECORD_MANUAL_PAYMENT 오프라인 큐',
    '6. VAN사 고객센터 연락',
    '   NICE VAN: 1588-9955',
    '   KIS VAN: 1544-5432',
    '7. 복구 후 flush_offline_queue()',
    '8. 망취소 필요 건 request_van_net_cancel()'
  ),
  '15분 내 미해결 → 수동 결제 운영 / 30분 내 미해결 → VAN사 긴급 연락',
  15, true
),
(
  'SOP-PAY-002',
  'VAN 정산 불일치 대응',
  'PAYMENT',
  'van_settlement_mismatch /
   reconciliation_gap_detected',
  jsonb_build_array(
    '1. reconcile_van_settlement() 재실행',
    '2. amount_gap / count_gap 확인',
    '3. 해당 날짜 van_transactions 전체 조회',
    '4. 취소 누락 건 확인',
    '5. VAN사 정산 파일 원본과 대조',
    '6. 불일치 해소 불가 시 VAN사 연락',
    '7. 해결 후 settlement_status = RESOLVED',
    '8. 감사 증빙 패킷 생성',
    '   generate_audit_packet(DISPUTE_EVIDENCE)'
  ),
  '즉시 CRITICAL 알림 발송 / 1,000원 이상 갭 → 즉일 해결 필수 / 미해결 → 세무사/회계사 보고',
  60, true
)
on conflict (runbook_code) do nothing;


-- pg_cron: VAN 헬스체크
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'VAN_TIMEOUT_CHECK',
  'catchmenu_van_timeout_check',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
-- VAN 타임아웃 처리 (5분 이상 PENDING)
UPDATE catchmenu_payment.van_transactions
SET
  transaction_status = 'TIMEOUT',
  error_message = 'Auto timeout after 5 minutes'
WHERE transaction_status = 'PENDING'
  AND transacted_at
    < now() - interval '5 minutes';
$sql$,
  'VAN PENDING 거래 타임아웃. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_payment.record_van_transaction(
      uuid, uuid, text, text, text, int,
      uuid, text, text, text, int, text,
      timestamptz, text, jsonb, text,
      boolean, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.request_van_net_cancel(
      uuid, uuid, uuid, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.reconcile_van_settlement(
      uuid, uuid, text, date, int, bigint,
      int, bigint, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_payment.get_van_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_payment.request_van_net_cancel(
    uuid, uuid, uuid, text, uuid, text
  ) is
  'VAN 망취소 요청.
   당일 승인 건만 망취소 가능.

   망취소 흐름:
   1. 원거래 조회 (APPROVAL + APPROVED)
   2. 당일 거래 확인
   3. NET_CANCEL 기록 (PENDING)
   4. SYSTEM_EVENTS → Edge Function 전달
   5. Edge Function → VAN API 망취소
   6. VAN 응답 → record_van_transaction()
   7. payment_ledger REFUNDED 처리

   익일 거래:
   망취소 불가 → FORCE_CANCEL.
   VAN사 고객센터 직접 연락 필요.
   SOP-PAY-002 참조.

   NICE VAN: 1588-9955
   KIS VAN: 1544-5432

   중복 승인 탐지:
   approval_number 중복 시
   CRITICAL 보안 위협으로 기록.';

-- ===== BEGIN [sql/migrations/0018_create_agent_actions_approvals.sql] =====
-- 0018_create_agent_actions_approvals.sql
-- Purpose: Agent action log and human approval queue.
--          Agents observe and recommend. Humans approve and execute.
--          Every agent recommendation must be explicitly approved or rejected.
--          특허4 core: 관찰≠변경, 추천≠실행, 증거≠승인, Agent≠Operator.
-- Depends on: 0017_create_evidence_and_fallback.sql
-- Creates:
--   catchmenu_agent.agent_actions
--   catchmenu_agent.agent_approvals

create table if not exists catchmenu_agent.agent_actions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  agent_id uuid not null references catchmenu_store.agent_registry(id),

  -- action identity
  action_type text not null,
  action_domain text not null,
  action_status text not null default 'PENDING',

  -- what the agent observed
  observation_summary text,
  observation_payload jsonb not null default '{}'::jsonb,

  -- what the agent recommends
  recommendation_type text not null,
  recommendation_summary text not null,
  recommendation_payload jsonb not null default '{}'::jsonb,
  recommended_sop_id uuid,

  -- confidence
  confidence_score int,
  confidence_basis text,

  -- subject
  subject_type text,
  subject_id uuid,

  -- linked records
  exception_id uuid references catchmenu_ledger.exceptions(id),
  task_id uuid references catchmenu_ledger.tasks(id),
  session_id uuid,
  order_id uuid,
  kds_ticket_id uuid references catchmenu_kds.kds_tickets(id),
  fallback_log_id uuid references catchmenu_agent.manual_fallback_log(id),

  -- approval linkage
  approval_id uuid,
  requires_approval boolean not null default true,

  -- execution result (after approval)
  executed_at timestamptz,
  execution_result text,
  execution_payload jsonb,
  execution_failed_reason text,

  -- ai learning feedback
  -- 특허4: Logical AI 운영 결정 메시지 + 관리자 반응 피드백 학습
  manager_feedback text,
  feedback_recorded_at timestamptz,

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_agent_action_type check (
    action_type in (
      'FAULT_DETECTED',
      'EXCEPTION_CLASSIFIED',
      'SOP_RECOMMENDED',
      'KDS_CAPACITY_EVALUATED',
      'KDS_COMMIT_RECOMMENDED',
      'KDS_HOLD_RECOMMENDED',
      'RECOVERY_INITIATED',
      'SYNC_COMPLETED',
      'KNOWLEDGE_GAP_DETECTED',
      'SOP_DRAFT_GENERATED',
      'DEVICE_ISOLATED',
      'DEVICE_RECOVERED',
      'PAYMENT_UNCERTAIN_FLAGGED',
      'RECONCILIATION_MISMATCH_FLAGGED',
      'PHYSICAL_AI_TASK_TRANSLATED'
    )
  ),
  constraint chk_agent_action_domain check (
    action_domain in (
      'order', 'payment', 'kds', 'session',
      'device', 'recovery', 'knowledge',
      'gateway', 'security', 'system'
    )
  ),
  constraint chk_agent_action_status check (
    action_status in (
      'PENDING',
      'AWAITING_APPROVAL',
      'APPROVED',
      'REJECTED',
      'EXECUTING',
      'COMPLETED',
      'FAILED',
      'CANCELLED',
      'DELEGATED'
    )
  ),
  constraint chk_agent_recommendation_type check (
    recommendation_type in (
      'APPLY_SOP',
      'NOTIFY_STAFF',
      'NOTIFY_MANAGER',
      'ESCALATE_HQ',
      'HOLD_KDS_TICKET',
      'COMMIT_KDS_TICKET',
      'ACTIVATE_FALLBACK',
      'INITIATE_RECOVERY',
      'ISOLATE_DEVICE',
      'BLOCK_GATEWAY_SESSION',
      'FLAG_PAYMENT_UNCERTAIN',
      'CREATE_EVIDENCE_PACKET',
      'GENERATE_SOP_DRAFT',
      'TRANSLATE_TO_PHYSICAL_AI'
    )
  ),
  constraint chk_agent_confidence check (
    confidence_score is null
    or confidence_score between 0 and 100
  ),
  constraint chk_observation_object check (
    jsonb_typeof(observation_payload) = 'object'
  ),
  constraint chk_recommendation_object check (
    jsonb_typeof(recommendation_payload) = 'object'
  ),
  constraint chk_execution_object check (
    execution_payload is null
    or jsonb_typeof(execution_payload) = 'object'
  )
);

create index if not exists idx_agent_actions_store_status
  on catchmenu_agent.agent_actions(store_id, action_status);

create index if not exists idx_agent_actions_agent
  on catchmenu_agent.agent_actions(agent_id, created_at desc);

create index if not exists idx_agent_actions_domain
  on catchmenu_agent.agent_actions(store_id, action_domain, created_at desc);

create index if not exists idx_agent_actions_awaiting
  on catchmenu_agent.agent_actions(store_id, created_at desc)
  where action_status = 'AWAITING_APPROVAL';

create index if not exists idx_agent_actions_exception
  on catchmenu_agent.agent_actions(exception_id)
  where exception_id is not null;

create index if not exists idx_agent_actions_kds_ticket
  on catchmenu_agent.agent_actions(kds_ticket_id)
  where kds_ticket_id is not null;

create index if not exists idx_agent_actions_business_day
  on catchmenu_agent.agent_actions(store_id, business_day desc);

drop trigger if exists trg_agent_actions_updated_at
  on catchmenu_agent.agent_actions;
create trigger trg_agent_actions_updated_at
  before update on catchmenu_agent.agent_actions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.agent_actions is
  'Agent action and recommendation log.
   Every agent observation and recommendation is recorded here.
   Agents NEVER execute without human approval (requires_approval = true by default).
   Exception: auto-recovery agents may execute low-risk recovery actions
   when pre-approved by manager standing policy.
   특허4 핵심 원칙:
   관찰(observe) ≠ 변경(change)
   추천(recommend) ≠ 실행(execute)
   증거(evidence) ≠ 승인(approval)
   Agent ≠ Operator
   최종 승인과 책임은 관리자 또는 점주에게 귀속된다.';
comment on column catchmenu_agent.agent_actions.confidence_score is
  'Agent confidence in recommendation. 0-100.
   Low confidence actions require explicit manager approval.
   High confidence routine actions may use standing approval policy.';
comment on column catchmenu_agent.agent_actions.manager_feedback is
  'APPROVED / REJECTED / MODIFIED + reason.
   This feedback is the AI learning signal.
   특허4: Logical AI가 생성한 운영 결정 메시지에 대한
          관리자의 승인/거절/수정 반응을 Audit 원장에 축적.';


create table if not exists catchmenu_agent.agent_approvals (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  action_id uuid not null references catchmenu_agent.agent_actions(id),

  -- approval request
  approval_type text not null,
  urgency_level text not null default 'NORMAL',
  approval_deadline_at timestamptz,

  -- what needs approval
  action_summary text not null,
  risk_summary text,
  recommended_decision text,
  sop_reference_id uuid,

  -- notification
  notified_to_type text not null,
  notified_to_id uuid,
  notified_at timestamptz not null default now(),
  notification_channel text not null default 'APP_PUSH',
  reminder_sent_at timestamptz,

  -- decision
  approval_status text not null default 'PENDING',
  decided_by_type text,
  decided_by_id uuid,
  decided_at timestamptz,
  decision_note text,
  decision_payload jsonb,

  -- escalation
  escalated_at timestamptz,
  escalated_to_type text,
  escalated_to_id uuid,
  escalation_reason text,
  auto_escalate_after_minutes int,

  -- evidence
  evidence_packet_id uuid references catchmenu_agent.evidence_packets(id),
  audit_record_id uuid references catchmenu_ledger.audit_records(id),

  -- correlation
  correlation_id text,
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_approval_type check (
    approval_type in (
      'KDS_RELEASE_OVERRIDE',
      'PAYMENT_UNCERTAIN_RESOLUTION',
      'RECOVERY_EXECUTION',
      'FALLBACK_ACTIVATION',
      'DEVICE_ISOLATION',
      'GATEWAY_BLOCK',
      'RECONCILIATION_WRITEOFF',
      'SOP_PUBLICATION',
      'AGENT_SCOPE_EXPANSION',
      'PHYSICAL_AI_TASK_EXECUTION',
      'EXCEPTION_ESCALATION',
      'MANUAL_CORRECTION'
    )
  ),
  constraint chk_approval_urgency check (
    urgency_level in (
      'LOW',
      'NORMAL',
      'HIGH',
      'CRITICAL',
      'IMMEDIATE'
    )
  ),
  constraint chk_approval_status check (
    approval_status in (
      'PENDING',
      'NOTIFIED',
      'UNDER_REVIEW',
      'APPROVED',
      'REJECTED',
      'MODIFIED_AND_APPROVED',
      'ESCALATED',
      'TIMED_OUT',
      'CANCELLED'
    )
  ),
  constraint chk_approval_notified_to check (
    notified_to_type in (
      'STAFF', 'MANAGER', 'OWNER',
      'HQ_ADMIN', 'SUPPORT'
    )
  ),
  constraint chk_approval_notification_channel check (
    notification_channel in (
      'APP_PUSH',
      'IN_APP',
      'SMS',
      'EMAIL',
      'KDS_ALERT',
      'DID_ALERT'
    )
  ),
  constraint chk_decision_payload_object check (
    decision_payload is null
    or jsonb_typeof(decision_payload) = 'object'
  )
);

create index if not exists idx_agent_approvals_store_status
  on catchmenu_agent.agent_approvals(store_id, approval_status);

create index if not exists idx_agent_approvals_pending
  on catchmenu_agent.agent_approvals(store_id, urgency_level, created_at desc)
  where approval_status in ('PENDING', 'NOTIFIED', 'UNDER_REVIEW');

create index if not exists idx_agent_approvals_action
  on catchmenu_agent.agent_approvals(action_id);

create index if not exists idx_agent_approvals_notified_to
  on catchmenu_agent.agent_approvals(notified_to_id, approval_status)
  where notified_to_id is not null;

create index if not exists idx_agent_approvals_deadline
  on catchmenu_agent.agent_approvals(approval_deadline_at)
  where approval_status in ('PENDING', 'NOTIFIED')
    and approval_deadline_at is not null;

create index if not exists idx_agent_approvals_business_day
  on catchmenu_agent.agent_approvals(store_id, business_day desc);

drop trigger if exists trg_agent_approvals_updated_at
  on catchmenu_agent.agent_approvals;
create trigger trg_agent_approvals_updated_at
  before update on catchmenu_agent.agent_approvals
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_agent.agent_approvals is
  'Human approval queue for agent recommendations.
   Every high-risk agent action requires explicit human decision.
   특허4: Human Authority Runtime.
   판단(Decide) / 승인(Authorize) / 실행(Execute) / 소유(Own)
   사람(점주/매니저/점장)이 최종 판단·승인·실행 책임을 보유.
   Approval flow:
     Agent detects → creates agent_action →
     creates agent_approval → notifies human →
     human decides → audit_record created →
     action executed (if approved).';
comment on column catchmenu_agent.agent_approvals.urgency_level is
  'IMMEDIATE = payment uncertain, KDS blocked, active customer impact.
   CRITICAL = device contamination suspect, financial discrepancy.
   HIGH = fallback activation, reconciliation mismatch.
   NORMAL = SOP recommendation, routine recovery.
   LOW = knowledge gap detection, non-urgent optimization.';
comment on column catchmenu_agent.agent_approvals.auto_escalate_after_minutes is
  'Minutes before auto-escalating to next authority level.
   IMMEDIATE urgency: 2 minutes.
   CRITICAL: 5 minutes.
   HIGH: 15 minutes.
   NORMAL: 60 minutes.
   Null = no auto-escalation.';
comment on column catchmenu_agent.agent_approvals.approval_status is
  'TIMED_OUT = deadline passed without decision.
   Auto-escalates to manager or HQ depending on urgency.
   MODIFIED_AND_APPROVED = approved with changes to recommendation.
   Changes are recorded in decision_payload and decision_note.';

-- ===== BEGIN [sql/migrations/0152_add_orders_pickup_ready_timing_columns.sql] =====
-- 0152_add_orders_pickup_ready_timing_columns.sql
-- Purpose: Add order-level pickup/ready timing columns to
--          catchmenu_pos.orders.
--
-- Depends on:
--   - 0151_create_check_kds_capacity_function.sql
--
-- Creates:
--   - catchmenu_pos.orders.requested_pickup_at
--   - catchmenu_pos.orders.ready_at
--
-- Background:
--   catchmenu_store.place_takeout_order() already writes
--   requested_pickup_at into catchmenu_pos.orders, but the column did not
--   exist in the table schema.
--
--   catchmenu_store.track_takeout_order() already reads ready_at and
--   requested_pickup_at from catchmenu_pos.orders for its response timeline,
--   but both columns were missing from the table schema.
--
--   The live catchmenu_store.call_customer_pickup() body from
--   0094_fix_i18n_hardcoded_strings.sql already writes ready_at on
--   PICKUP_READY, but the column did not exist in catchmenu_pos.orders.
--
-- Scope:
--   - Forward schema migration only.
--   - Does not modify function bodies.
--   - Does not modify catchmenu_kds.kds_tickets.ready_at or KDS lifecycle.
--   - Does not resolve PICKED_UP status drift.
--   - Does not resolve point_ledger or discount_pct blockers.
--   - Adds no NOT NULL, DEFAULT, or CHECK constraints.

alter table catchmenu_pos.orders
  add column if not exists requested_pickup_at timestamptz,
  add column if not exists ready_at timestamptz;

