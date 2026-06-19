-- 0014_create_payment_ledger.sql
-- Purpose: Payment intent and internal payment ledger.
--          payment_ledger is the ONLY source of truth for payment state.
--          External provider responses are never trusted directly.
--          They enter via gateway, are verified, then reflected here.
--          KDS release requires payment_ledger confirmation, not provider response.
--          특허1 core: 내부 승인 원장 = 금융권형 결제 대사의 기준점.
-- Depends on: 0013_create_pos_orders.sql, 0009_create_gateway_provider_events.sql
-- Creates:
--   catchmenu_payment.payment_intents
--   catchmenu_payment.payment_ledger
--   catchmenu_payment.payment_events

create table if not exists catchmenu_payment.payment_intents (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),

  -- intent identity
  intent_status text not null default 'CREATED',
  payment_method text not null,
  payment_channel text not null,

  -- amounts
  requested_amount int not null,
  currency text not null default 'KRW',

  -- provider routing
  provider_type text not null,
  provider_order_id text unique,

  -- token (single-use per 특허1)
  payment_token text unique,
  token_issued_at timestamptz,
  token_expires_at timestamptz,

  -- idempotency
  idempotency_key text not null,
  gateway_session_id uuid references catchmenu_gateway.gateway_sessions(id),

  -- timing
  created_at timestamptz not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  expired_at timestamptz,
  updated_at timestamptz not null default now(),

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  constraint chk_intent_status check (
    intent_status in (
      'CREATED',
      'PENDING',
      'PROCESSING',
      'CONFIRMED',
      'FAILED',
      'CANCELLED',
      'EXPIRED'
    )
  ),
  constraint chk_intent_payment_method check (
    payment_method in (
      'CARD',
      'SIMPLE_PAY_KAKAO',
      'SIMPLE_PAY_NAVER',
      'SIMPLE_PAY_TOSS',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'VOUCHER',
      'MIXED'
    )
  ),
  constraint chk_intent_payment_channel check (
    payment_channel in (
      'KIOSK_CARD',
      'KIOSK_QR',
      'TABLE_QR',
      'CUSTOMER_APP',
      'STAFF_POS',
      'COUNTER_CARD',
      'ONLINE'
    )
  ),
  constraint chk_intent_provider check (
    provider_type in (
      'TOSS_PAYMENTS',
      'VAN_NICE',
      'VAN_KIS',
      'VAN_KICC',
      'KAKAO_PAY',
      'NAVER_PAY',
      'SAMSUNG_PAY',
      'ALIPAY',
      'WECHAT_PAY',
      'CASH',
      'INTERNAL'
    )
  ),
  constraint chk_intent_amount check (requested_amount > 0)
);

create index if not exists idx_payment_intents_order
  on catchmenu_payment.payment_intents(order_id);

create index if not exists idx_payment_intents_session
  on catchmenu_payment.payment_intents(session_id)
  where session_id is not null;

create index if not exists idx_payment_intents_store_status
  on catchmenu_payment.payment_intents(store_id, intent_status);

create index if not exists idx_payment_intents_provider_order
  on catchmenu_payment.payment_intents(provider_order_id)
  where provider_order_id is not null;

create index if not exists idx_payment_intents_token
  on catchmenu_payment.payment_intents(payment_token)
  where payment_token is not null;

drop trigger if exists trg_payment_intents_updated_at
  on catchmenu_payment.payment_intents;
create trigger trg_payment_intents_updated_at
  before update on catchmenu_payment.payment_intents
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_payment.payment_intents is
  'Payment intent. Created before payment window opens.
   Represents a single payment attempt for an order.
   One order may have multiple intents (retry after failure).
   provider_order_id is the ID sent to external provider.
   Internal system uses this ID to correlate provider callbacks.
   특허1: 단회성 비상태형 토큰으로 외부에 내부 원장 키 미노출.';
comment on column catchmenu_payment.payment_intents.payment_token is
  'Single-use token issued to payment provider.
   Never exposes internal order_id or customer identity.
   Expires after single use or token_expires_at.
   특허1: 단회성 비상태형 토큰 발급부.';
comment on column catchmenu_payment.payment_intents.intent_status is
  'CREATED = intent initialized, payment window not yet open.
   PENDING = payment window open, waiting for customer action.
   PROCESSING = customer submitted, provider processing.
   CONFIRMED = reflected in payment_ledger as APPROVED.
   FAILED = provider returned failure.
   CANCELLED = cancelled before processing.
   EXPIRED = timeout without customer action.';


create table if not exists catchmenu_payment.payment_ledger (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  session_id uuid references catchmenu_pos.order_sessions(id),
  intent_id uuid not null references catchmenu_payment.payment_intents(id),

  -- ledger identity
  ledger_entry_type text not null,
  ledger_status text not null,

  -- amounts (KRW integer)
  approved_amount int not null,
  cancelled_amount int not null default 0,
  refunded_amount int not null default 0,
  net_amount int not null,

  -- provider confirmation (from gateway after verification)
  provider_type text not null,
  provider_payment_key text,
  provider_approval_number text,
  provider_approved_at timestamptz,
  provider_response_id uuid references catchmenu_gateway.provider_raw_events(id),

  -- reconciliation state
  reconciliation_status text not null default 'PENDING',
  reconciliation_checked_at timestamptz,
  reconciliation_mismatch_reason text,

  -- KDS release authority
  -- 특허1: 결제 완료 ≠ KDS 릴리즈 자동 허용
  -- KDS release requires this flag = true
  kds_release_authorized boolean not null default false,
  kds_release_authorized_at timestamptz,
  kds_release_authorized_by text,

  -- evidence
  evidence_packet_id uuid,

  -- business day snapshot
  business_day date not null,
  business_timezone text not null default 'Asia/Seoul',

  approved_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_ledger_entry_type check (
    ledger_entry_type in (
      'APPROVAL',
      'PARTIAL_CANCEL',
      'FULL_CANCEL',
      'REFUND',
      'PARTIAL_REFUND',
      'ADJUSTMENT',
      'MANUAL_CORRECTION'
    )
  ),
  constraint chk_ledger_status check (
    ledger_status in (
      'APPROVED',
      'CANCELLED',
      'REFUNDED',
      'PARTIAL_CANCELLED',
      'PARTIAL_REFUNDED',
      'UNCERTAIN',
      'DISPUTED',
      'UNDER_REVIEW'
    )
  ),
  constraint chk_ledger_amounts check (
    approved_amount > 0
    and cancelled_amount >= 0
    and refunded_amount >= 0
    and net_amount = approved_amount - cancelled_amount - refunded_amount
  ),
  constraint chk_ledger_reconciliation check (
    reconciliation_status in (
      'PENDING',
      'MATCHED',
      'MISMATCH',
      'MANUAL_REVIEW',
      'RESOLVED'
    )
  )
);

create index if not exists idx_payment_ledger_order
  on catchmenu_payment.payment_ledger(order_id);

create index if not exists idx_payment_ledger_intent
  on catchmenu_payment.payment_ledger(intent_id);

create index if not exists idx_payment_ledger_store_status
  on catchmenu_payment.payment_ledger(store_id, ledger_status);

create index if not exists idx_payment_ledger_store_business_day
  on catchmenu_payment.payment_ledger(store_id, business_day desc);

create index if not exists idx_payment_ledger_provider_key
  on catchmenu_payment.payment_ledger(provider_payment_key)
  where provider_payment_key is not null;

create index if not exists idx_payment_ledger_reconciliation
  on catchmenu_payment.payment_ledger(store_id, reconciliation_status)
  where reconciliation_status in ('PENDING', 'MISMATCH', 'MANUAL_REVIEW');

create index if not exists idx_payment_ledger_kds_auth
  on catchmenu_payment.payment_ledger(order_id, kds_release_authorized)
  where kds_release_authorized = false
    and ledger_status = 'APPROVED';

comment on table catchmenu_payment.payment_ledger is
  'Internal payment ledger. THE source of truth for payment state.
   External provider response alone is NEVER sufficient to confirm payment.
   Flow: provider_raw_events → gateway verification → payment_ledger entry.
   Only after ledger entry is APPROVED can KDS release be authorized.
   특허1 core: 내부 승인 원장 = 금융권형 결제 대사의 기준점.
   결제 승인 후 내부 서버, 외부 PG/VAN 원장 대사 필수.';
comment on column catchmenu_payment.payment_ledger.kds_release_authorized is
  'FALSE by default even after payment approval.
   KDS Capacity Agent checks this flag before committing tickets.
   Set to TRUE only after:
     1. ledger_status = APPROVED
     2. reconciliation_status = MATCHED or waived
     3. No PAYMENT_UNCERTAIN exception active for this order.
   특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용.
   특허2: KDS Late Binding 조건 중 payment_confirmed 확인.';
comment on column catchmenu_payment.payment_ledger.ledger_status is
  'APPROVED = payment confirmed and ledger entry created.
   CANCELLED = fully cancelled.
   REFUNDED = fully refunded.
   PARTIAL_CANCELLED = partially cancelled.
   PARTIAL_REFUNDED = partially refunded.
   UNCERTAIN = payment attempted but result unknown.
               Triggers PAYMENT_UNCERTAIN session status.
               KDS MUST NOT release until resolved.
   DISPUTED = customer or provider dispute raised.
   UNDER_REVIEW = manual review in progress.';
comment on column catchmenu_payment.payment_ledger.reconciliation_status is
  'PENDING = not yet reconciled with provider ledger.
   MATCHED = internal ledger matches provider ledger.
   MISMATCH = discrepancy detected. Creates reconciliation_case.
   MANUAL_REVIEW = requires human review.
   RESOLVED = mismatch resolved.
   특허1: 내부 승인 원장 ↔ 외부 PG/VAN 원장 1차 대사.';


create table if not exists catchmenu_payment.payment_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  order_id uuid not null references catchmenu_pos.orders(id),
  intent_id uuid references catchmenu_payment.payment_intents(id),
  ledger_id uuid references catchmenu_payment.payment_ledger(id),

  event_type text not null,
  from_status text,
  to_status text,

  caused_by_type text not null default 'SYSTEM',
  caused_by_id uuid,
  caused_by_device_id uuid references catchmenu_store.device_registry(id),
  caused_by_agent_id uuid references catchmenu_store.agent_registry(id),

  amount_at_event int,
  provider_event_id text,
  event_payload jsonb not null default '{}'::jsonb,
  correlation_id text,
  occurred_at timestamptz not null default now(),

  constraint chk_payment_event_type check (
    event_type in (
      'intent_created',
      'payment_window_opened',
      'payment_submitted',
      'provider_callback_received',
      'provider_callback_verified',
      'payment_approved',
      'payment_failed',
      'payment_uncertain',
      'payment_uncertain_resolved',
      'payment_cancelled',
      'payment_refunded',
      'payment_partial_refunded',
      'kds_release_authorized',
      'reconciliation_matched',
      'reconciliation_mismatch_detected',
      'reconciliation_resolved',
      'manual_correction_applied',
      'dispute_raised',
      'dispute_resolved'
    )
  ),
  constraint chk_payment_event_caused_by check (
    caused_by_type in (
      'SYSTEM', 'AGENT', 'STAFF',
      'MANAGER', 'PROVIDER', 'SCHEDULER'
    )
  ),
  constraint chk_payment_event_payload_object check (
    jsonb_typeof(event_payload) = 'object'
  )
);

create index if not exists idx_payment_events_order
  on catchmenu_payment.payment_events(order_id, occurred_at asc);

create index if not exists idx_payment_events_intent
  on catchmenu_payment.payment_events(intent_id, occurred_at asc)
  where intent_id is not null;

create index if not exists idx_payment_events_ledger
  on catchmenu_payment.payment_events(ledger_id, occurred_at asc)
  where ledger_id is not null;

create index if not exists idx_payment_events_store_type
  on catchmenu_payment.payment_events(store_id, event_type, occurred_at desc);

comment on table catchmenu_payment.payment_events is
  'Payment-scoped event log. Domain event trail for payment lifecycle.
   payment_uncertain and payment_uncertain_resolved are critical events.
   When payment_uncertain is recorded:
     - Session status → PAYMENT_UNCERTAIN
     - KDS Agent blocks all ticket commits for this order
     - Exception is created in catchmenu_ledger.exceptions
     - Agent recommends resolution SOP to staff
   When payment_uncertain_resolved:
     - KDS release authorization is re-evaluated
     - Exception is closed
     - Audit record is created with resolution evidence.';