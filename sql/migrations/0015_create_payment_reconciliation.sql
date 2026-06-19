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