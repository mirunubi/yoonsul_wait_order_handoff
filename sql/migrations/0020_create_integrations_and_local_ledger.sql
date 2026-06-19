-- 0020_create_integrations_and_local_ledger.sql
-- Purpose: Toss POS payment integration and local temporary ledger.
--          Local temporary ledger stores events during network outage.
--          After recovery, events are replayed to central ledger.
--          특허4 core: Local Temporary Ledger + Event Replay 기반 복구.
-- Depends on: 0014_create_payment_ledger.sql
-- Creates:
--   catchmenu_integrations.toss_payments
--   catchmenu_integrations.toss_webhooks
--   catchmenu_ledger.local_temporary_ledger

create table if not exists catchmenu_integrations.toss_payments (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  intent_id uuid references catchmenu_payment.payment_intents(id),
  ledger_id uuid references catchmenu_payment.payment_ledger(id),

  -- Toss identifiers
  toss_payment_key text unique,
  toss_order_id text not null unique,
  toss_transaction_key text,

  -- payment state (mirrors Toss API status)
  toss_status text not null default 'READY',
  payment_method text,
  payment_type text,

  -- amounts
  requested_amount int not null,
  approved_amount int,
  cancelled_amount int,
  vat_amount int,

  -- card info (masked)
  card_company text,
  card_number_masked text,
  card_installment_plan_months int,
  card_approve_no text,
  card_acquire_status text,

  -- simple pay info
  easy_pay_provider text,
  easy_pay_amount int,
  easy_pay_discount_amount int,

  -- receipt
  receipt_url text,
  checkout_url text,

  -- raw response preservation
  toss_raw_response jsonb,
  toss_raw_cancel_response jsonb,

  -- gateway linkage
  provider_raw_event_id uuid
    references catchmenu_gateway.provider_raw_events(id),

  -- timing
  requested_at timestamptz not null default now(),
  approved_at timestamptz,
  cancelled_at timestamptz,
  failed_at timestamptz,
  last_updated_at timestamptz,

  failure_code text,
  failure_message text,
  cancel_reason text,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_toss_status check (
    toss_status in (
      'READY',
      'IN_PROGRESS',
      'WAITING_FOR_DEPOSIT',
      'DONE',
      'CANCELLED',
      'PARTIAL_CANCELLED',
      'ABORTED',
      'EXPIRED'
    )
  ),
  constraint chk_toss_requested_amount check (requested_amount > 0),
  constraint chk_toss_approved_amount check (
    approved_amount is null or approved_amount >= 0
  ),
  constraint chk_toss_raw_object check (
    toss_raw_response is null
    or jsonb_typeof(toss_raw_response) = 'object'
  ),
  constraint chk_toss_raw_cancel_object check (
    toss_raw_cancel_response is null
    or jsonb_typeof(toss_raw_cancel_response) = 'object'
  )
);

create index if not exists idx_toss_payments_store
  on catchmenu_integrations.toss_payments(store_id, toss_status);

create index if not exists idx_toss_payments_order
  on catchmenu_integrations.toss_payments(order_id);

create index if not exists idx_toss_payments_intent
  on catchmenu_integrations.toss_payments(intent_id)
  where intent_id is not null;

create index if not exists idx_toss_payments_ledger
  on catchmenu_integrations.toss_payments(ledger_id)
  where ledger_id is not null;

create index if not exists idx_toss_payments_business_day
  on catchmenu_integrations.toss_payments(store_id, business_day desc);

create index if not exists idx_toss_payments_provider_event
  on catchmenu_integrations.toss_payments(provider_raw_event_id)
  where provider_raw_event_id is not null;

drop trigger if exists trg_toss_payments_updated_at
  on catchmenu_integrations.toss_payments;
create trigger trg_toss_payments_updated_at
  before update on catchmenu_integrations.toss_payments
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_integrations.toss_payments is
  'Toss Payments integration record.
   Raw provider data preserved exactly as received.
   toss_raw_response is the forensic evidence for any Toss dispute.
   Internal payment truth lives in catchmenu_payment.payment_ledger.
   This table is the bridge between Toss and internal ledger.
   Reconciliation compares toss_status with ledger_status.
   특허1: 외부 PG/VAN 원장 ↔ 내부 승인 원장 1차 대사 데이터.';
comment on column catchmenu_integrations.toss_payments.toss_status is
  'Mirrors Toss API official status values exactly.
   READY = before payment window opens.
   IN_PROGRESS = payment window open.
   WAITING_FOR_DEPOSIT = virtual account issued.
   DONE = approved.
   CANCELLED = fully cancelled.
   PARTIAL_CANCELLED = partially cancelled.
   ABORTED = approval failed.
   EXPIRED = timed out.';
comment on column catchmenu_integrations.toss_payments.toss_raw_response is
  'Complete Toss API response payload preserved as-is.
   Never modified after insert.
   Used for reconciliation, dispute evidence, and audit.';
comment on column catchmenu_integrations.toss_payments.card_number_masked is
  'Masked card number from Toss response. e.g. 4321-12**-****-1234.
   Never store full card number. PCI DSS compliance.';


create table if not exists catchmenu_integrations.toss_webhooks (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- webhook identity
  toss_payment_key text,
  toss_order_id text,
  event_type text not null,

  -- raw webhook payload
  raw_headers jsonb,
  raw_body jsonb not null,
  payload_hash text,

  -- verification
  signature_verified boolean,
  idempotency_checked boolean not null default false,
  is_duplicate boolean not null default false,

  -- processing
  processing_status text not null default 'RECEIVED',
  processed_at timestamptz,
  processing_error text,

  -- linkage
  toss_payment_id uuid references catchmenu_integrations.toss_payments(id),
  provider_raw_event_id uuid
    references catchmenu_gateway.provider_raw_events(id),
  internal_payment_event_id uuid
    references catchmenu_payment.payment_events(id),

  received_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_toss_webhook_status check (
    processing_status in (
      'RECEIVED',
      'VERIFIED',
      'PROCESSED',
      'DUPLICATE_IGNORED',
      'FAILED',
      'QUARANTINED'
    )
  ),
  constraint chk_toss_webhook_body_object check (
    jsonb_typeof(raw_body) = 'object'
  )
);

create index if not exists idx_toss_webhooks_payment_key
  on catchmenu_integrations.toss_webhooks(toss_payment_key)
  where toss_payment_key is not null;

create index if not exists idx_toss_webhooks_order_id
  on catchmenu_integrations.toss_webhooks(toss_order_id)
  where toss_order_id is not null;

create index if not exists idx_toss_webhooks_status
  on catchmenu_integrations.toss_webhooks(processing_status, received_at desc)
  where processing_status in ('RECEIVED', 'VERIFIED', 'QUARANTINED');

create index if not exists idx_toss_webhooks_hash
  on catchmenu_integrations.toss_webhooks(payload_hash)
  where payload_hash is not null;

comment on table catchmenu_integrations.toss_webhooks is
  'Toss Payments webhook receiver log.
   Every webhook is stored as-is before processing.
   Signature verification and idempotency check happen before any state change.
   Duplicate webhooks are ignored and logged as DUPLICATE_IGNORED.
   특허1: 웹훅 서명 검증 + 멱등성 확인 후 내부 상태 반영.';


create table if not exists catchmenu_ledger.local_temporary_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid not null,
  device_id uuid not null,

  -- entry identity
  entry_type text not null,
  entry_domain text not null,
  entry_sequence int not null,

  -- original event data
  original_event_type text not null,
  original_subject_type text,
  original_subject_id uuid,
  entry_payload jsonb not null default '{}'::jsonb,

  -- correlation to central ledger
  central_event_id uuid,
  central_task_id uuid,
  central_audit_id uuid,

  -- replay state
  replay_status text not null default 'PENDING',
  replay_attempted_at timestamptz,
  replay_completed_at timestamptz,
  replay_attempt_count int not null default 0,
  replay_conflict_detected boolean not null default false,
  replay_conflict_detail jsonb,
  replay_approved_by uuid,
  replay_approved_at timestamptz,

  -- timing
  locally_recorded_at timestamptz not null default now(),
  network_restored_at timestamptz,
  created_at timestamptz not null default now(),

  constraint uq_local_ledger_device_sequence
    unique (device_id, entry_sequence),
  constraint chk_local_entry_type check (
    entry_type in (
      'TASK',
      'EVENT',
      'AUDIT',
      'EXCEPTION'
    )
  ),
  constraint chk_local_entry_domain check (
    entry_domain in (
      'order', 'payment', 'kds', 'session',
      'delivery', 'staff', 'device',
      'agent', 'recovery', 'system'
    )
  ),
  constraint chk_local_replay_status check (
    replay_status in (
      'PENDING',
      'IN_PROGRESS',
      'REPLAYED',
      'CONFLICT_DETECTED',
      'CONFLICT_RESOLVED',
      'SKIPPED',
      'FAILED'
    )
  ),
  constraint chk_local_payload_object check (
    jsonb_typeof(entry_payload) = 'object'
  ),
  constraint chk_local_conflict_object check (
    replay_conflict_detail is null
    or jsonb_typeof(replay_conflict_detail) = 'object'
  ),
  constraint chk_replay_attempt_count check (
    replay_attempt_count >= 0
  )
);

create index if not exists idx_local_ledger_device_replay
  on catchmenu_ledger.local_temporary_ledger(device_id, replay_status);

create index if not exists idx_local_ledger_store_pending
  on catchmenu_ledger.local_temporary_ledger(store_id, locally_recorded_at asc)
  where replay_status in ('PENDING', 'CONFLICT_DETECTED');

create index if not exists idx_local_ledger_conflict
  on catchmenu_ledger.local_temporary_ledger(store_id, replay_conflict_detected)
  where replay_conflict_detected = true
    and replay_status = 'CONFLICT_DETECTED';

create index if not exists idx_local_ledger_sequence
  on catchmenu_ledger.local_temporary_ledger(device_id, entry_sequence asc)
  where replay_status = 'PENDING';

comment on table catchmenu_ledger.local_temporary_ledger is
  'Local temporary ledger for offline operation.
   When network is disconnected, all operational events are stored here
   in append-only sequence order per device.
   After network recovery:
     1. Compare local entries with central ledger
     2. Verify each entry for conflicts, duplicates, ordering issues
     3. Safe entries → replay to central ledger
     4. Conflict entries → manual review queue
   특허4: Local Temporary Ledger 및 Event Replay 기반 복구 기술.
   중앙 DB 장애, 메인 서버 장애, 네트워크 장애 발생 시
   Local Temporary Ledger를 사용하여 운영 연속성 유지.';
comment on column catchmenu_ledger.local_temporary_ledger.entry_sequence is
  'Monotonically increasing sequence per device.
   Used to detect gaps or ordering issues during replay.
   Critical for detecting events that were lost during outage.';
comment on column catchmenu_ledger.local_temporary_ledger.replay_conflict_detected is
  'True when this entry conflicts with central ledger state.
   e.g. central ledger shows order CANCELLED but local shows COMPLETED.
   Conflicts require manual manager approval before replay.
   특허4: 충돌 또는 손상 의심 Event는 관리자 승인 대상으로 분리.';
comment on column catchmenu_ledger.local_temporary_ledger.replay_approved_by is
  'Manager who approved replay of a conflicting entry.
   Null for non-conflicting entries that auto-replayed.
   특허4: 안전한 Event만 중앙 원장에 Replay.';