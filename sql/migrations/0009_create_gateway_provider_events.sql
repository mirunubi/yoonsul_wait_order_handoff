-- 0009_create_gateway_provider_events.sql
-- Purpose: Gateway sandbox boundary. All external inputs land here first.
--          Raw provider events are stored as-is before verification.
--          Nothing enters internal ledgers without passing gateway validation.
--          특허1 core: Zero Trust external boundary + sandbox interface.
-- Depends on: 0008_create_ledger_audit.sql
-- Creates:
--   catchmenu_gateway.provider_raw_events
--   catchmenu_gateway.gateway_sessions

create table if not exists catchmenu_gateway.provider_raw_events (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- provider identity
  provider_type text not null,
  provider_code text not null,
  provider_event_id text,
  provider_event_type text,

  -- raw payload (preserved exactly as received)
  raw_headers jsonb,
  raw_payload jsonb not null,
  payload_hash text,

  -- signature verification
  signature_header text,
  signature_verified boolean,
  signature_verified_at timestamptz,
  signature_algorithm text,

  -- schema validation
  schema_validated boolean,
  schema_validation_errors jsonb,

  -- processing state
  processing_status text not null default 'RECEIVED',
  processing_attempts int not null default 0,
  first_received_at timestamptz not null default now(),
  last_processed_at timestamptz,

  -- result
  accepted_at timestamptz,
  rejected_at timestamptz,
  rejection_reason text,

  -- internal linkage (set after acceptance)
  internal_event_id uuid references catchmenu_ledger.events(id),
  idempotency_key_id uuid references catchmenu_common.idempotency_keys(id),
  correlation_id text,

  -- source device/channel
  source_ip text,
  source_device_id uuid references catchmenu_store.device_registry(id),
  received_at timestamptz not null default now(),

  constraint chk_provider_type check (
    provider_type in (
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
    )
  ),
  constraint chk_gateway_processing_status check (
    processing_status in (
      'RECEIVED',
      'VALIDATING',
      'ACCEPTED',
      'REJECTED',
      'QUARANTINED',
      'REPLAYED',
      'EXPIRED'
    )
  ),
  constraint chk_raw_payload_object check (
    jsonb_typeof(raw_payload) = 'object'
  ),
  constraint chk_schema_errors_object check (
    schema_validation_errors is null
    or jsonb_typeof(schema_validation_errors) = 'object'
  ),
  constraint chk_processing_attempts check (
    processing_attempts >= 0
  )
);

create index if not exists idx_provider_events_store_provider
  on catchmenu_gateway.provider_raw_events(store_id, provider_type);

create index if not exists idx_provider_events_provider_event_id
  on catchmenu_gateway.provider_raw_events(provider_event_id)
  where provider_event_id is not null;

create index if not exists idx_provider_events_status
  on catchmenu_gateway.provider_raw_events(processing_status, received_at desc)
  where processing_status in ('RECEIVED', 'VALIDATING', 'QUARANTINED');

create index if not exists idx_provider_events_correlation
  on catchmenu_gateway.provider_raw_events(correlation_id)
  where correlation_id is not null;

create index if not exists idx_provider_events_internal_event
  on catchmenu_gateway.provider_raw_events(internal_event_id)
  where internal_event_id is not null;

create index if not exists idx_provider_events_payload_hash
  on catchmenu_gateway.provider_raw_events(payload_hash)
  where payload_hash is not null;

comment on table catchmenu_gateway.provider_raw_events is
  'Gateway sandbox. Every external event lands here before touching internal ledgers.
   Raw payload is stored exactly as received — never modified.
   Processing pipeline:
     RECEIVED → signature verification → schema validation → idempotency check
     → ACCEPTED (internal event created) or REJECTED or QUARANTINED.
   Rejected and quarantined events never reach internal ledgers.
   특허1 core: 외부 POS/PG/VAN/배달앱을 신뢰하지 않는 Zero Trust 구조.
   샌드박스 인터페이스가 외부 요청을 검증한 후에만 내부 서버로 전달.';
comment on column catchmenu_gateway.provider_raw_events.raw_payload is
  'Exact payload received from provider. Never modified after insert.
   This is the forensic evidence for any provider dispute.';
comment on column catchmenu_gateway.provider_raw_events.payload_hash is
  'SHA-256 hash of raw_payload for replay detection.
   If same hash arrives again, it is a duplicate and must be idempotency-checked.';
comment on column catchmenu_gateway.provider_raw_events.signature_verified is
  'True = signature matched provider public key or HMAC secret.
   False = signature mismatch. Event must be REJECTED.
   Null = provider does not use signature verification.';
comment on column catchmenu_gateway.provider_raw_events.processing_status is
  'RECEIVED = just arrived, not yet processed.
   VALIDATING = signature and schema checks in progress.
   ACCEPTED = passed all checks, internal event created.
   REJECTED = failed signature, schema, or idempotency check.
   QUARANTINED = suspicious pattern detected, held for manual review.
   REPLAYED = reprocessed from quarantine after manual approval.
   EXPIRED = TTL passed without processing.';
comment on column catchmenu_gateway.provider_raw_events.internal_event_id is
  'Set after ACCEPTED. Links raw provider event to internal ledger event.
   This is the audit trail connecting external world to internal state.';


create table if not exists catchmenu_gateway.gateway_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),

  -- session identity
  session_type text not null,
  session_status text not null default 'ACTIVE',

  -- provider
  provider_type text not null,
  provider_code text,
  provider_session_id text,

  -- token (single-use stateless token per 특허1)
  session_token text unique,
  token_scope jsonb,
  token_issued_at timestamptz,
  token_expires_at timestamptz,
  token_used_count int not null default 0,
  token_max_use int not null default 1,

  -- linked operational context
  store_id_scope uuid references catchmenu_hq.stores(id),
  table_id_scope uuid,
  order_session_id_scope uuid,
  payment_session_id_scope uuid,

  -- event counts
  events_received int not null default 0,
  events_accepted int not null default 0,
  events_rejected int not null default 0,

  -- timing
  opened_at timestamptz not null default now(),
  last_activity_at timestamptz not null default now(),
  closed_at timestamptz,
  expires_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_gateway_session_type check (
    session_type in (
      'POS_INTEGRATION',
      'PAYMENT_PROCESSING',
      'DELIVERY_INTAKE',
      'WEBHOOK_LISTENER',
      'KIOSK_SESSION',
      'AGENT_SYNC',
      'PROVIDER_CALLBACK'
    )
  ),
  constraint chk_gateway_session_status check (
    session_status in (
      'ACTIVE',
      'SUSPENDED',
      'CLOSED',
      'EXPIRED',
      'REVOKED'
    )
  ),
  constraint chk_token_scope_object check (
    token_scope is null
    or jsonb_typeof(token_scope) = 'object'
  ),
  constraint chk_token_use_count check (
    token_used_count >= 0
    and token_used_count <= token_max_use
  )
);

create index if not exists idx_gateway_sessions_store_type
  on catchmenu_gateway.gateway_sessions(store_id, session_type, session_status);

create index if not exists idx_gateway_sessions_token
  on catchmenu_gateway.gateway_sessions(session_token)
  where session_token is not null;

create index if not exists idx_gateway_sessions_provider
  on catchmenu_gateway.gateway_sessions(provider_type, provider_session_id)
  where provider_session_id is not null;

create index if not exists idx_gateway_sessions_expires
  on catchmenu_gateway.gateway_sessions(expires_at)
  where session_status = 'ACTIVE'
    and expires_at is not null;

drop trigger if exists trg_gateway_sessions_updated_at
  on catchmenu_gateway.gateway_sessions;
create trigger trg_gateway_sessions_updated_at
  before update on catchmenu_gateway.gateway_sessions
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_gateway.gateway_sessions is
  'Gateway session registry. Tracks active integration sessions with external providers.
   특허1 core: 단회성 비상태형 토큰 발급부.
   Each session issues a single-use stateless token scoped to:
   specific store, table, order session, and payment session.
   Token is never reused. Token never exposes internal customer identifiers.
   External POS receives token only — never internal keys or customer PII.';
comment on column catchmenu_gateway.gateway_sessions.session_token is
  'Single-use stateless token issued to external provider.
   Scoped by store, table, order session, time window, and use count.
   특허1: 단회성 비상태형 토큰으로 외부 POS에 실제 고객 식별자 미노출.';
comment on column catchmenu_gateway.gateway_sessions.token_scope is
  'Json object defining what this token is authorized for.
   e.g. {"store_id": "...", "table_id": "...",
         "allowed_operations": ["order_submit", "payment_request"],
         "max_amount": 100000}';
comment on column catchmenu_gateway.gateway_sessions.token_max_use is
  'Default 1 = single use token. Token is invalidated after first use.
   Higher values allowed for specific session types like webhook listeners.';