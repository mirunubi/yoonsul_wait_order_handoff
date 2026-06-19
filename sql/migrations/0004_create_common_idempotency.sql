-- 0004_create_common_idempotency.sql
-- Purpose: Idempotency key registry for all external and high-risk internal operations.
--          Prevents duplicate orders, duplicate payments, duplicate KDS tickets,
--          and duplicate provider callbacks from causing state corruption.
-- Depends on: 0001_create_schemas.sql
-- Creates:
--   catchmenu_common.idempotency_keys

create table if not exists catchmenu_common.idempotency_keys (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid references catchmenu_hq.stores(id),

  -- key identity
  idempotency_key text not null,
  key_domain text not null,
  key_scope text not null default 'STORE',

  -- operation info
  operation_type text not null,
  request_hash text,

  -- result
  processing_status text not null default 'PROCESSING',
  result_payload jsonb,
  error_payload jsonb,

  -- replay tracking
  first_received_at timestamptz not null default now(),
  last_received_at timestamptz not null default now(),
  completed_at timestamptz,
  replay_count int not null default 0,
  max_replay_allowed int not null default 3,

  -- correlation
  source_device_id uuid references catchmenu_store.device_registry(id),
  provider_event_id text,
  correlation_id text,

  expires_at timestamptz,
  created_at timestamptz not null default now(),

  constraint uq_idempotency_key unique (tenant_id, key_domain, idempotency_key),
  constraint chk_idempotency_domain check (
    key_domain in (
      'order',
      'payment',
      'payment_cancel',
      'payment_refund',
      'kds_commit',
      'kds_release',
      'provider_callback',
      'webhook',
      'agent_action',
      'recovery',
      'sync'
    )
  ),
  constraint chk_idempotency_scope check (
    key_scope in ('GLOBAL', 'TENANT', 'STORE', 'SESSION')
  ),
  constraint chk_idempotency_status check (
    processing_status in (
      'PROCESSING',
      'COMPLETED',
      'FAILED',
      'EXPIRED',
      'DUPLICATE_REJECTED'
    )
  ),
  constraint chk_idempotency_result_object check (
    result_payload is null
    or jsonb_typeof(result_payload) = 'object'
  ),
  constraint chk_idempotency_error_object check (
    error_payload is null
    or jsonb_typeof(error_payload) = 'object'
  ),
  constraint chk_replay_count check (replay_count >= 0),
  constraint chk_max_replay check (max_replay_allowed >= 0)
);

create index if not exists idx_idempotency_tenant_domain
  on catchmenu_common.idempotency_keys(tenant_id, key_domain);

create index if not exists idx_idempotency_provider_event
  on catchmenu_common.idempotency_keys(provider_event_id)
  where provider_event_id is not null;

create index if not exists idx_idempotency_correlation
  on catchmenu_common.idempotency_keys(correlation_id)
  where correlation_id is not null;

create index if not exists idx_idempotency_expires
  on catchmenu_common.idempotency_keys(expires_at)
  where expires_at is not null
    and processing_status not in ('COMPLETED', 'EXPIRED');

comment on table catchmenu_common.idempotency_keys is
  'Central idempotency registry for all external and high-risk internal operations.
   Every payment, order, KDS commit, provider callback, and webhook
   must register an idempotency key before processing.
   If the same key is received again, return the stored result without reprocessing.
   This prevents duplicate orders, payments, KDS tickets from provider replay,
   network retry, or malicious re-submission.';
comment on column catchmenu_common.idempotency_keys.idempotency_key is
  'Opaque unique key per operation attempt.
   Format depends on domain:
   order: session_id + timestamp hash
   payment: toss_order_id or pg_transaction_id
   provider_callback: provider_event_id + signature hash
   webhook: webhook_id + delivery_attempt';
comment on column catchmenu_common.idempotency_keys.key_domain is
  'Business domain of the operation.
   Used to scope uniqueness and determine replay behavior.';
comment on column catchmenu_common.idempotency_keys.processing_status is
  'PROCESSING = operation started, not yet complete.
   COMPLETED = operation finished successfully, result cached.
   FAILED = operation failed, error cached.
   EXPIRED = key TTL passed, operation may be retried with new key.
   DUPLICATE_REJECTED = key seen again while PROCESSING, rejected.';
comment on column catchmenu_common.idempotency_keys.replay_count is
  'Number of times this key was received after first_received_at.
   Exceeding max_replay_allowed triggers DUPLICATE_REJECTED.';
comment on column catchmenu_common.idempotency_keys.request_hash is
  'Hash of the original request payload.
   If a replay arrives with a different hash, it is a request mismatch
   and must be rejected even if the key matches.';
comment on column catchmenu_common.idempotency_keys.provider_event_id is
  'External provider event identifier (e.g. Toss paymentKey, VAN approval number).
   Used to correlate idempotency key with raw provider event in gateway tables.';