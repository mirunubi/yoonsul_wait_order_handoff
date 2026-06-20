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
  sop_runbook_code
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
  'INTEGRATION', 'VALIDATION', 400, 'WARNING', null),
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