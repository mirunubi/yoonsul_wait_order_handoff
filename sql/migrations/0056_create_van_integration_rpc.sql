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