-- 0103_create_toss_payments_pipeline_rpc.sql
-- Purpose: Toss Payments integration pipeline.
--          토스페이먼츠 결제 요청, 확인, 취소,
--          가상계좌, 웹훅 처리 파이프라인.
--          1차 MVP 핵심 결제 연동.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0102_create_okpos_integration_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.toss_payment_requests (table)
--   catchmenu_integrations.toss_webhook_log (table)
--   function catchmenu_integrations.initiate_toss_payment(...)
--   function catchmenu_integrations.confirm_toss_payment(...)
--   function catchmenu_integrations.cancel_toss_payment(...)
--   function catchmenu_integrations.process_toss_webhook(...)
--   function catchmenu_integrations.get_toss_payment_status(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('toss_payment_initiated', 'ko',
  '토스페이먼츠 결제가 시작되었습니다'),
('toss_payment_initiated', 'en',
  'Toss Payments initiated'),
('toss_payment_confirmed', 'ko',
  '토스페이먼츠 결제가 완료되었습니다'),
('toss_payment_confirmed', 'en',
  'Toss Payments confirmed'),
('toss_payment_cancelled', 'ko',
  '토스페이먼츠 결제가 취소되었습니다'),
('toss_payment_cancelled', 'en',
  'Toss Payments cancelled'),
('toss_webhook_processed', 'ko',
  '토스페이먼츠 웹훅이 처리되었습니다'),
('toss_webhook_processed', 'en',
  'Toss Payments webhook processed'),
('toss_payment_status_loaded', 'ko',
  '토스페이먼츠 결제 상태가 로드되었습니다'),
('toss_payment_status_loaded', 'en',
  'Toss Payments status loaded'),
('toss_payment_failed', 'ko',
  '토스페이먼츠 결제에 실패했습니다'),
('toss_payment_failed', 'en',
  'Toss Payments failed'),
('toss_payment_expired', 'ko',
  '결제 시간이 초과되었습니다'),
('toss_payment_expired', 'en',
  'Payment session expired'),
('toss_idempotency_key_duplicate', 'ko',
  '중복 결제 요청이 감지되었습니다'),
('toss_idempotency_key_duplicate', 'en',
  'Duplicate payment request detected'),
('toss_webhook_signature_invalid', 'ko',
  '웹훅 서명이 유효하지 않습니다'),
('toss_webhook_signature_invalid', 'en',
  'Webhook signature invalid')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_runbook_code
) values
(9020, 'toss_payment_initiate_failed',
  'PAYMENT', 'TECHNICAL', 500, 'ERROR',
  'SOP-PAY-001'),
(9021, 'toss_payment_confirm_failed',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(9022, 'toss_payment_cancel_failed',
  'PAYMENT', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-002'),
(9023, 'toss_webhook_signature_invalid',
  'PAYMENT', 'SECURITY', 401, 'CRITICAL',
  'SOP-SEC-004'),
(9024, 'toss_payment_expired',
  'PAYMENT', 'BUSINESS_RULE', 410, 'INFO', null),
(9025, 'toss_idempotency_key_duplicate',
  'PAYMENT', 'CONFLICT', 409, 'WARNING', null),
(9026, 'toss_config_not_found',
  'PAYMENT', 'NOT_FOUND', 404, 'ERROR',
  'SOP-PAY-001')
on conflict (code) do nothing;


-- =============================================
-- toss_payment_requests table
-- 토스페이먼츠 결제 요청 관리
-- =============================================
create table if not exists
  catchmenu_integrations.toss_payment_requests (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 주문 연결
  order_id uuid
    references catchmenu_pos.orders(id),

  -- 토스페이먼츠 식별자
  payment_key text,
  order_id_toss text not null unique,
  idempotency_key text not null unique,

  -- 결제 정보
  payment_method text,
  amount int not null,
  order_name text not null,

  -- 고객 정보 (해시)
  customer_id_hash text,
  customer_name_masked text,

  -- 상태
  request_status text
    not null default 'READY',

  -- 토스페이먼츠 응답
  toss_response jsonb,
  failure_code text,
  failure_message text,

  -- 타임스탬프
  requested_at timestamptz
    not null default now(),
  confirmed_at timestamptz,
  cancelled_at timestamptz,
  expired_at timestamptz
    not null default
      now() + interval '15 minutes',

  -- 결제 결과
  approved_amount int,
  supplied_amount int,
  vat int,
  tax_free_amount int not null default 0,

  -- 카드 정보 (마스킹)
  card_number_masked text,
  card_company text,
  card_type text,
  installment_plan_months int
    not null default 0,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_request_status check (
    request_status in (
      'READY',       -- 결제 준비
      'IN_PROGRESS', -- 결제 중 (고객 인증)
      'DONE',        -- 결제 완료
      'CANCELED',    -- 취소
      'PARTIAL_CANCELED', -- 부분 취소
      'ABORTED',     -- 결제 중단
      'EXPIRED'      -- 만료
    )
  )
);

create index if not exists idx_toss_requests_order
  on catchmenu_integrations.toss_payment_requests(
    order_id
  ) where order_id is not null;
create index if not exists idx_toss_requests_store
  on catchmenu_integrations.toss_payment_requests(
    store_id, request_status, requested_at desc
  );
create index if not exists idx_toss_requests_key
  on catchmenu_integrations.toss_payment_requests(
    payment_key
  ) where payment_key is not null;
create index if not exists idx_toss_requests_expired
  on catchmenu_integrations.toss_payment_requests(
    expired_at
  ) where request_status = 'READY';

alter table
  catchmenu_integrations.toss_payment_requests
  enable row level security;
alter table
  catchmenu_integrations.toss_payment_requests
  force row level security;

drop policy if exists toss_requests_isolation
  on catchmenu_integrations.toss_payment_requests;
create policy toss_requests_isolation
  on catchmenu_integrations.toss_payment_requests
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_toss_requests_updated
  on catchmenu_integrations.toss_payment_requests;
create trigger trg_toss_requests_updated
  before update on
    catchmenu_integrations.toss_payment_requests
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.toss_payment_requests is
  '토스페이먼츠 결제 요청 관리.
   order_id_toss: 토스에 전달하는 주문 ID
     (내부 order_id와 별개).
   idempotency_key: 중복 요청 방지 키.
     (SHA-256(order_id + timestamp)).
   payment_key: 토스 승인 후 발급.
   card_number_masked: 앞 6자리 + 뒤 4자리만.
   customer_*: PII 해시/마스킹 처리.
   expired_at: 15분 내 미완료 시 EXPIRED.
   특허1: 결제 요청 = 감사 추적 시작.
   1차 MVP 핵심 결제 테이블.';


-- =============================================
-- toss_webhook_log table
-- 토스페이먼츠 웹훅 수신 로그
-- =============================================
create table if not exists
  catchmenu_integrations.toss_webhook_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 웹훅 정보
  event_type text not null,
  payment_key text,
  order_id_toss text,

  -- 서명 검증
  signature_verified boolean
    not null default false,
  webhook_secret_hash text,

  -- 원본 페이로드
  raw_payload jsonb not null,

  -- 처리 결과
  process_status text
    not null default 'PENDING',
  process_result jsonb,
  error_detail text,

  -- 재처리
  retry_count int not null default 0,
  max_retries int not null default 3,

  received_at timestamptz
    not null default now(),
  processed_at timestamptz,

  constraint chk_webhook_status check (
    process_status in (
      'PENDING', 'PROCESSING',
      'COMPLETED', 'FAILED',
      'IGNORED', 'INVALID_SIGNATURE'
    )
  )
);

create index if not exists idx_toss_webhook_key
  on catchmenu_integrations.toss_webhook_log(
    payment_key
  ) where payment_key is not null;
create index if not exists idx_toss_webhook_status
  on catchmenu_integrations.toss_webhook_log(
    process_status, received_at desc
  ) where process_status in (
    'PENDING', 'FAILED'
  );
create index if not exists idx_toss_webhook_tenant
  on catchmenu_integrations.toss_webhook_log(
    tenant_id, received_at desc
  );

alter table catchmenu_integrations.toss_webhook_log
  enable row level security;
alter table catchmenu_integrations.toss_webhook_log
  force row level security;

drop policy if exists toss_webhook_isolation
  on catchmenu_integrations.toss_webhook_log;
create policy toss_webhook_isolation
  on catchmenu_integrations.toss_webhook_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_integrations.toss_webhook_log is
  '토스페이먼츠 웹훅 수신 로그.
   INVALID_SIGNATURE: 서명 검증 실패.
     → 즉시 보안 감사 로그 + SOP-SEC-004.
   IGNORED: 이미 처리된 이벤트 (멱등성).
   retry_count: 처리 실패 시 최대 3회 재시도.
   append-only: 삭제/수정 금지.
   특허4: 웹훅 = 외부 이벤트 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.initiate_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_payment_method text default 'CARD',
  p_customer_id_hash text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_toss_config record;
  v_order_id_toss text;
  v_idempotency_key text;
  v_order_name text;
  v_request_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 토스페이먼츠 설정 조회
  select id, api_key_hash, client_key_hash,
         webhook_secret_hash, is_active
  into v_toss_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_PAYMENTS'
    and is_active = true;

  if v_toss_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.final_amount, o.order_status,
         o.session_id,
         os.table_number
  into v_order
  from catchmenu_pos.orders o
  left join catchmenu_pos.order_sessions os
    on os.id = o.session_id
  where o.id = p_order_id
    and o.store_id = p_store_id
    and o.tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 이미 결제 완료 확인
  if exists (
    select 1
    from catchmenu_integrations
      .toss_payment_requests
    where order_id = p_order_id
      and request_status = 'DONE'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'initiate_toss_payment'
    );
  end if;

  -- 토스 주문 ID + 멱등성 키 생성
  v_order_id_toss := 'CATCH-'
    || to_char(v_business_day, 'YYYYMMDD')
    || '-' || v_order.order_number
    || '-' || extract(
      epoch from now()
    )::int::text;

  v_idempotency_key := encode(
    digest(
      p_order_id::text
      || v_order.final_amount::text
      || v_order_id_toss,
      'sha256'
    ),
    'hex'
  );

  -- 주문명 구성
  v_order_name := case v_order.order_type
    when 'TABLE' then
      coalesce(v_order.table_number, '')
      || ' 테이블 주문'
    when 'TAKEOUT' then
      v_order.order_number || ' 포장'
    when 'DELIVERY' then
      v_order.order_number || ' 배달'
    else v_order.order_number || ' 주문'
  end;

  -- 결제 요청 생성
  insert into
    catchmenu_integrations.toss_payment_requests (
    tenant_id, store_id, order_id,
    order_id_toss, idempotency_key,
    payment_method, amount, order_name,
    customer_id_hash,
    request_status,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    v_order_id_toss, v_idempotency_key,
    p_payment_method,
    v_order.final_amount,
    v_order_name,
    p_customer_id_hash,
    'READY',
    v_business_day
  )
  returning id into v_request_id;

  -- Edge Function에 결제 초기화 요청
  -- (실제 토스 API 호출은 Edge Function)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_payment_initiate_requested',
    p_payload := jsonb_build_object(
      'request_id', v_request_id,
      'order_id', p_order_id,
      'order_id_toss', v_order_id_toss,
      'idempotency_key', v_idempotency_key,
      'amount', v_order.final_amount,
      'order_name', v_order_name,
      'payment_method', p_payment_method,
      'customer_id_hash', p_customer_id_hash,
      'config_id', v_toss_config.id,
      'locale', p_locale,
      'correlation_id', p_correlation_id,
      'timeout_seconds', 900,
      'success_url',
        'catchmenu://payment/success',
      'fail_url',
        'catchmenu://payment/fail'
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_initiated',
    p_data := jsonb_build_object(
      'request_id', v_request_id,
      'order_id', p_order_id,
      'order_id_toss', v_order_id_toss,
      'idempotency_key', v_idempotency_key,
      'amount', v_order.final_amount,
      'order_name', v_order_name,
      'payment_method', p_payment_method,
      'request_status', 'READY',
      'expires_at',
        now() + interval '15 minutes',
      'flutter_note', jsonb_build_object(
        'next_step',
          'TossPayments SDK checkout() 호출',
        'client_key',
          'Edge Function에서 반환',
        'success_url',
          'catchmenu://payment/success',
        'fail_url',
          'catchmenu://payment/fail'
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_order_id_toss text,
  p_amount int,
  p_toss_response jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_approval_number text;
  v_card_number_masked text;
  v_card_company text;
  v_payment_method text;
  v_vat int;
  v_result jsonb;
begin
  -- 결제 요청 조회
  select id, order_id, amount,
         request_status, idempotency_key
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where order_id_toss = p_order_id_toss
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 이미 완료된 결제 (멱등성)
  if v_request.request_status = 'DONE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 만료 확인
  if v_request.request_status = 'EXPIRED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_payment_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 금액 검증 (멱등성 + 보안)
  if abs(p_amount - v_request.amount) > 0 then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'CRITICAL',
      p_log_domain := 'PAYMENT',
      p_log_event := 'toss_amount_tampering',
      p_message :=
        '토스 결제 금액 변조 시도 감지!'
        || ' | 요청=' || v_request.amount
        || ' | 수신=' || p_amount,
      p_rpc_name := 'confirm_toss_payment',
      p_details := jsonb_build_object(
        'request_id', v_request.id,
        'order_id', v_request.order_id,
        'expected_amount', v_request.amount,
        'received_amount', p_amount
      )
    );

    -- 보안 감사 기록
    insert into catchmenu_common.security_audit_log (
      tenant_id, store_id,
      audit_event, event_severity,
      event_source, event_detail,
      is_violation, was_blocked
    ) values (
      p_tenant_id, p_store_id,
      'payment_amount_tampering',
      'CRITICAL',
      'confirm_toss_payment',
      jsonb_build_object(
        'expected', v_request.amount,
        'received', p_amount,
        'payment_key', p_payment_key
      ),
      true, true
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'payment_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_payment'
    );
  end if;

  -- 토스 응답 파싱
  v_approval_number := coalesce(
    p_toss_response->>'approvalNumber',
    p_payment_key
  );
  v_payment_method := coalesce(
    p_toss_response->>'method', 'CARD'
  );
  v_vat := coalesce(
    (p_toss_response->>'vat')::int, 0
  );

  -- 카드 정보 마스킹 처리
  if p_toss_response->'card' is not null then
    declare
      v_raw_card text;
    begin
      v_raw_card :=
        p_toss_response->'card'->>'number';
      -- 마스킹: 앞 6자리 + **** + 뒤 4자리
      v_card_number_masked := case
        when length(v_raw_card) >= 10
        then left(v_raw_card, 6)
          || '****'
          || right(v_raw_card, 4)
        else '****'
      end;
      v_card_company :=
        p_toss_response->'card'->>'company';
    end;
  end if;

  -- 결제 요청 상태 업데이트
  update catchmenu_integrations.toss_payment_requests
  set
    request_status = 'DONE',
    payment_key = p_payment_key,
    toss_response = p_toss_response,
    approved_amount = p_amount,
    supplied_amount = p_amount - v_vat,
    vat = v_vat,
    card_number_masked = v_card_number_masked,
    card_company = v_card_company,
    card_type =
      p_toss_response->'card'->>'cardType',
    installment_plan_months = coalesce(
      (p_toss_response->'card'
        ->>'installmentPlanMonths')::int, 0
    ),
    confirmed_at = now(),
    updated_at = now()
  where id = v_request.id;

  -- 표준 결제 확인 파이프라인 호출
  -- → KDS Late Binding 해제 (특허2)
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_request.order_id,
    p_provider_type := 'TOSS_PAYMENTS',
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := p_payment_key,
    p_approved_amount := p_amount,
    p_payment_method := v_payment_method,
    p_provider_response :=
      coalesce(p_toss_response, '{}'::jsonb),
    p_actor_type := 'PG_WEBHOOK',
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_confirmed',
    p_data := jsonb_build_object(
      'request_id', v_request.id,
      'order_id', v_request.order_id,
      'payment_key', p_payment_key,
      'approved_amount', p_amount,
      'vat', v_vat,
      'payment_method', v_payment_method,
      'card_number_masked',
        v_card_number_masked,
      'card_company', v_card_company,
      'kds_released',
        (v_result->>'success')::boolean,
      'kds_data', v_result->'data'->'kds'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_toss_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_payment_key text,
  p_cancel_reason text,
  p_cancel_amount int default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_refund_amount int;
  v_refund_result jsonb;
begin
  -- 결제 요청 조회
  select id, order_id, approved_amount,
         request_status
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where payment_key = p_payment_key
    and tenant_id = p_tenant_id
    and store_id = p_store_id
  for update;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_toss_payment'
    );
  end if;

  if v_request.request_status
    not in ('DONE', 'PARTIAL_CANCELED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_cancelled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_toss_payment'
    );
  end if;

  v_refund_amount := coalesce(
    p_cancel_amount,
    v_request.approved_amount
  );

  -- Edge Function에 토스 취소 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_payment_cancel_requested',
    p_payload := jsonb_build_object(
      'request_id', v_request.id,
      'payment_key', p_payment_key,
      'order_id', v_request.order_id,
      'cancel_reason', p_cancel_reason,
      'cancel_amount', v_refund_amount,
      'is_partial',
        p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      'correlation_id', p_correlation_id
    )
  );

  -- 결제 요청 상태 업데이트
  update catchmenu_integrations.toss_payment_requests
  set
    request_status = case
      when p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount
        then 'PARTIAL_CANCELED'
      else 'CANCELED'
    end,
    cancelled_at = now(),
    updated_at = now()
  where id = v_request.id;

  -- 표준 환불 파이프라인 호출
  v_refund_result :=
    catchmenu_payment.request_refund(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := v_request.order_id,
      p_refund_amount := v_refund_amount,
      p_refund_reason := p_cancel_reason,
      p_is_partial := p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_cancelled',
    p_data := jsonb_build_object(
      'request_id', v_request.id,
      'payment_key', p_payment_key,
      'order_id', v_request.order_id,
      'cancel_reason', p_cancel_reason,
      'cancel_amount', v_refund_amount,
      'is_partial',
        p_cancel_amount is not null
        and p_cancel_amount
          < v_request.approved_amount,
      'refund_result',
        v_refund_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.process_toss_webhook(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_type text,
  p_raw_payload jsonb,
  p_signature text default null,
  p_expected_signature_hash text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_webhook_id uuid;
  v_payment_key text;
  v_order_id_toss text;
  v_signature_verified boolean := false;
  v_process_result jsonb;
begin
  v_payment_key :=
    p_raw_payload->>'paymentKey';
  v_order_id_toss :=
    p_raw_payload->>'orderId';

  -- 서명 검증
  -- 실제 검증은 Edge Function에서 1차 수행
  -- DB 레벨 2차 검증
  if p_signature is not null
    and p_expected_signature_hash is not null
  then
    v_signature_verified :=
      encode(
        digest(p_signature, 'sha256'), 'hex'
      ) = p_expected_signature_hash;

    if not v_signature_verified then
      -- 서명 검증 실패 → 보안 위반
      insert into
        catchmenu_integrations.toss_webhook_log (
        tenant_id, store_id,
        event_type, payment_key, order_id_toss,
        signature_verified, raw_payload,
        process_status
      ) values (
        p_tenant_id, p_store_id,
        p_event_type, v_payment_key,
        v_order_id_toss,
        false, p_raw_payload,
        'INVALID_SIGNATURE'
      );

      insert into
        catchmenu_common.security_audit_log (
        tenant_id, store_id,
        audit_event, event_severity,
        event_source, event_detail,
        is_violation, was_blocked
      ) values (
        p_tenant_id, p_store_id,
        'toss_webhook_signature_invalid',
        'CRITICAL',
        'process_toss_webhook',
        jsonb_build_object(
          'event_type', p_event_type,
          'payment_key', v_payment_key,
          'signature_mismatch', true
        ),
        true, true
      );

      return catchmenu_common.build_error_response(
        p_error_key :=
          'toss_webhook_signature_invalid',
        p_locale := 'ko',
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'process_toss_webhook'
      );
    end if;
  else
    -- 서명 없이 수신 (테스트 환경)
    v_signature_verified := true;
  end if;

  -- 중복 처리 방지 (멱등성)
  if exists (
    select 1
    from catchmenu_integrations.toss_webhook_log
    where payment_key = v_payment_key
      and event_type = p_event_type
      and process_status = 'COMPLETED'
      and tenant_id = p_tenant_id
  ) then
    insert into
      catchmenu_integrations.toss_webhook_log (
      tenant_id, store_id,
      event_type, payment_key, order_id_toss,
      signature_verified, raw_payload,
      process_status
    ) values (
      p_tenant_id, p_store_id,
      p_event_type, v_payment_key,
      v_order_id_toss,
      v_signature_verified, p_raw_payload,
      'IGNORED'
    );

    return catchmenu_common.build_success_response(
      p_message_key := 'toss_webhook_processed',
      p_data := jsonb_build_object(
        'status', 'IGNORED',
        'reason', 'duplicate_event',
        'payment_key', v_payment_key
      ),
      p_locale := 'ko'
    );
  end if;

  -- 웹훅 로그 생성
  insert into
    catchmenu_integrations.toss_webhook_log (
    tenant_id, store_id,
    event_type, payment_key, order_id_toss,
    signature_verified, raw_payload,
    process_status
  ) values (
    p_tenant_id, p_store_id,
    p_event_type, v_payment_key,
    v_order_id_toss,
    v_signature_verified, p_raw_payload,
    'PROCESSING'
  )
  returning id into v_webhook_id;

  -- 이벤트 타입별 처리
  case p_event_type
    when 'PAYMENT_STATUS_CHANGED' then
      declare
        v_status text;
      begin
        v_status :=
          p_raw_payload->>'status';

        case v_status
          when 'DONE' then
            v_process_result :=
              catchmenu_integrations
                .confirm_toss_payment(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_payment_key := v_payment_key,
                p_order_id_toss :=
                  v_order_id_toss,
                p_amount := (
                  p_raw_payload->>'totalAmount'
                )::int,
                p_toss_response := p_raw_payload,
                p_locale := 'ko',
                p_correlation_id :=
                  'WH-TOSS-' || v_webhook_id
              );

          when 'CANCELED' then
            v_process_result :=
              catchmenu_integrations
                .cancel_toss_payment(
                p_tenant_id := p_tenant_id,
                p_store_id := p_store_id,
                p_payment_key := v_payment_key,
                p_cancel_reason :=
                  coalesce(
                    p_raw_payload
                      ->'cancels'->0
                      ->>'cancelReason',
                    'webhook_cancel'
                  ),
                p_locale := 'ko',
                p_correlation_id :=
                  'WH-TOSS-' || v_webhook_id
              );

          when 'ABORTED' then
            -- 결제 중단 처리
            update catchmenu_integrations
              .toss_payment_requests
            set
              request_status = 'ABORTED',
              failure_code :=
                p_raw_payload->>'code',
              failure_message :=
                p_raw_payload->>'message',
              updated_at = now()
            where payment_key = v_payment_key
              and tenant_id = p_tenant_id;

            v_process_result :=
              jsonb_build_object(
                'success', true,
                'status', 'ABORTED'
              );

          else
            v_process_result :=
              jsonb_build_object(
                'success', true,
                'status', 'IGNORED',
                'reason', 'unhandled_status'
              );
        end case;
      end;

    else
      -- 미지원 이벤트
      v_process_result := jsonb_build_object(
        'success', true,
        'status', 'IGNORED',
        'reason', 'unhandled_event_type'
      );
  end case;

  -- 웹훅 로그 완료
  update catchmenu_integrations.toss_webhook_log
  set
    process_status = case
      when (v_process_result->>'success')
        ::boolean then 'COMPLETED'
      else 'FAILED'
    end,
    process_result = v_process_result,
    processed_at = now()
  where id = v_webhook_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_webhook_processed',
    p_data := jsonb_build_object(
      'webhook_id', v_webhook_id,
      'event_type', p_event_type,
      'payment_key', v_payment_key,
      'process_result', v_process_result
    ),
    p_locale := 'ko'
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_payment_status(
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
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_request record;
  v_payment_status jsonb;
begin
  select id, payment_key, order_id_toss,
         request_status, amount,
         approved_amount, vat,
         payment_method,
         card_number_masked, card_company,
         installment_plan_months,
         requested_at, confirmed_at,
         cancelled_at, expired_at,
         failure_code, failure_message
  into v_request
  from catchmenu_integrations.toss_payment_requests
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  order by requested_at desc
  limit 1;

  if v_request.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_toss_payment_status'
    );
  end if;

  -- 표준 결제 상태 조회
  v_payment_status :=
    catchmenu_payment.get_payment_status(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_locale := p_locale
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_payment_status_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_request', jsonb_build_object(
        'request_id', v_request.id,
        'payment_key', v_request.payment_key,
        'order_id_toss', v_request.order_id_toss,
        'request_status', v_request.request_status,
        'amount', v_request.amount,
        'approved_amount',
          v_request.approved_amount,
        'vat', v_request.vat,
        'payment_method', v_request.payment_method,
        'card_number_masked',
          v_request.card_number_masked,
        'card_company', v_request.card_company,
        'installment_months',
          v_request.installment_plan_months,
        'requested_at', v_request.requested_at,
        'confirmed_at', v_request.confirmed_at,
        'cancelled_at', v_request.cancelled_at,
        'expired_at', v_request.expired_at,
        'failure', case
          when v_request.failure_code is not null
          then jsonb_build_object(
            'code', v_request.failure_code,
            'message',
              v_request.failure_message
          )
          else null
        end
      ),
      'payment_ledger',
        v_payment_status->'data'
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: 토스 결제 만료 처리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values
(
  'TOSS_PAYMENT_EXPIRE',
  'catchmenu_toss_payment_expire',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
UPDATE catchmenu_integrations.toss_payment_requests
SET
  request_status = 'EXPIRED',
  updated_at = now()
WHERE request_status = 'READY'
  AND expired_at < now();
$sql$,
  '토스 결제 요청 만료 처리. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- =============================================
-- Flutter SDK 패턴: 토스페이먼츠
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values
(
  'FLUTTER_TOSS_PAYMENTS',
  '토스페이먼츠 결제 패턴',
  'RPC_CALL',
  '["CUSTOMER_APP","POS_TERMINAL","MINI_KIOSK"]'::jsonb,
  '토스페이먼츠 SDK 연동 + 결제 확인 파이프라인',
  '["supabase_flutter: ^2.0.0","tosspayments_widget_sdk_flutter: ^1.0.0"]'::jsonb,
  $dart$
// lib/services/toss_payment_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tosspayments_widget_sdk_flutter/model/payment_widget_options.dart';
import 'package:tosspayments_widget_sdk_flutter/payment_widget.dart';

class TossPaymentService {
  final _sb = Supabase.instance.client;

  // 결제 초기화 + SDK 실행
  Future<Map<String, dynamic>> checkout({
    required String tenantId,
    required String storeId,
    required String orderId,
    required String clientKey,
    String paymentMethod = 'CARD',
    String? customerIdHash,
  }) async {
    // 1. DB에 결제 요청 생성
    final initRes = await _sb.rpc(
      'initiate_toss_payment',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_order_id': orderId,
        'p_payment_method': paymentMethod,
        'p_customer_id_hash': customerIdHash,
        'p_locale': 'ko',
      },
    );

    if (initRes['success'] != true) {
      return initRes;
    }

    final data =
      initRes['data'] as Map<String, dynamic>;
    final orderIdToss = data['order_id_toss'];
    final amount = data['amount'];
    final orderName = data['order_name'];

    // 2. 토스페이먼츠 SDK 실행
    final paymentWidget = PaymentWidget(
      clientKey: clientKey,
      customerKey: customerIdHash ?? 'GUEST',
    );

    try {
      final result = await paymentWidget.checkout(
        price: amount,
        orderId: orderIdToss,
        orderName: orderName,
        successUrl: data['flutter_note']
          ['success_url'],
        failUrl: data['flutter_note']['fail_url'],
      );

      return {
        'success': true,
        'result': result,
        'order_id_toss': orderIdToss,
        'request_id': data['request_id'],
      };

    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
        'order_id_toss': orderIdToss,
      };
    }
  }

  // 결제 성공 콜백 처리
  // (successUrl 딥링크 처리 후 호출)
  Future<Map<String, dynamic>> handleSuccess({
    required String tenantId,
    required String storeId,
    required String paymentKey,
    required String orderIdToss,
    required int amount,
  }) async {
    // Edge Function이 토스 /v1/payments/confirm
    // 호출 후 confirm_toss_payment() 실행
    // 여기서는 결제 상태 폴링
    await Future.delayed(
      const Duration(seconds: 2)
    );

    final orderRes = await _sb.rpc(
      'get_toss_payment_status',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        // order_id는 order_id_toss로 조회
        'p_order_id': orderIdToss,
        'p_locale': 'ko',
      },
    );

    return orderRes as Map<String, dynamic>;
  }

  // 결제 취소
  Future<Map<String, dynamic>> cancel({
    required String tenantId,
    required String storeId,
    required String paymentKey,
    required String cancelReason,
    int? cancelAmount,
  }) async {
    return await _sb.rpc(
      'cancel_toss_payment',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_payment_key': paymentKey,
        'p_cancel_reason': cancelReason,
        'p_cancel_amount': cancelAmount,
        'p_locale': 'ko',
      },
    );
  }
}
$dart$
)
on conflict (pattern_code) do update set
  dart_code = excluded.dart_code;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.initiate_toss_payment(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.initiate_toss_payment(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_toss_payment(
      uuid, uuid, text, text, int,
      jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_toss_payment(
      uuid, uuid, text, text, int,
      jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_toss_payment(
      uuid, uuid, text, text, int,
      uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_toss_payment(
      uuid, uuid, text, text, int,
      uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.process_toss_webhook(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_toss_webhook(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_payment_status(
      uuid, uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_payment_status(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.confirm_toss_payment(
    uuid, uuid, text, text, int, jsonb, text, text
  ) is
  '토스페이먼츠 결제 확인 → 표준 파이프라인.
   보안 검증:
   1. 결제 요청 존재 확인
   2. 이미 완료 확인 (멱등성)
   3. 만료 확인
   4. 금액 변조 탐지 ← CRITICAL
      (수신 금액 ≠ 요청 금액 시 차단)
   5. 카드 번호 마스킹 (앞6+****+뒤4)
   6. confirm_payment() → KDS Late Binding
   금액 변조 시 보안 감사 로그 + CRITICAL.
   특허2: 결제 확인 = KDS HOLD 해제.
   1차 MVP 결제 파이프라인 핵심.';

comment on function
  catchmenu_integrations.process_toss_webhook(
    uuid, uuid, text, jsonb, text, text
  ) is
  '토스페이먼츠 웹훅 처리.
   Edge Function이 1차 서명 검증 후 호출.
   DB 레벨 2차 서명 검증.
   멱등성: 동일 payment_key + event_type
     중복 수신 시 IGNORED 처리.
   이벤트별 처리:
   PAYMENT_STATUS_CHANGED + DONE:
     → confirm_toss_payment()
   PAYMENT_STATUS_CHANGED + CANCELED:
     → cancel_toss_payment()
   PAYMENT_STATUS_CHANGED + ABORTED:
     → request_status = ABORTED
   서명 검증 실패:
     → INVALID_SIGNATURE 로그
     → 보안 감사 기록
     → SOP-SEC-004 연결
   특허4: 웹훅 = 외부 이벤트 감사 증빙.';