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
    begin
      insert into
        catchmenu_payment.payment_ledger (
        tenant_id, store_id,
        order_id, provider_type,
        payment_method, provider_tx_id,
        approved_amount, fee_amount,
        net_amount, tax_amount,
        ledger_status, approved_at,
        business_day, business_timezone,
        provider_response
      ) values (
        p_tenant_id, p_store_id,
        p_order_id,
        p_van_provider || '_VAN',
        case p_card_type
          when 'CREDIT' then 'CREDIT_CARD'
          else 'DEBIT_CARD'
        end,
        coalesce(
          p_approval_number,
          v_tx_id::text
        ),
        p_approved_amount,
        0,
        p_approved_amount - v_tax_amount,
        v_tax_amount,
        'APPROVED',
        coalesce(p_approval_at, now()),
        v_business_day, 'Asia/Seoul',
        p_van_response_raw
      )
      returning id into v_ledger_id;

      -- VAN 거래에 원장 ID 연결
      update catchmenu_payment.van_transactions
      set payment_ledger_id = v_ledger_id
      where id = v_tx_id;
    end;
  end if;

  -- 메시지 키
  v_message_key := case
    p_transaction_type
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
    'VAN_' || p_van_provider,
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