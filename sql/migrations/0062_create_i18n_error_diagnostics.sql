-- 0062_create_i18n_error_diagnostics.sql
-- Purpose: i18n message catalog + Unix-like error diagnostics layer.
--          Stable error codes, structured log records,
--          grep-friendly log files, SOP linkage, recovery hints.
--          모든 RPC의 에러/메시지는 이 레이어를 통해 반환.
-- Depends on: 0061_create_ai_context_advanced_rpc.sql
-- Creates:
--   catchmenu_common.error_codes (table)
--   catchmenu_common.message_catalog (table)
--   catchmenu_common.diagnostic_logs (table)
--   function catchmenu_common.get_message(...)
--   function catchmenu_common.log_diagnostic(...)
--   function catchmenu_common.build_error_response(...)
--   function catchmenu_common.build_success_response(...)

-- =============================================
-- error_codes table
-- 안정적 숫자 코드 — 절대 변경 금지
-- =============================================
create table if not exists catchmenu_common.error_codes (
  code int primary key,
  error_key text not null unique,
  error_domain text not null,
  error_category text not null,
  http_status int not null default 400,
  severity text not null default 'ERROR',
  is_retryable boolean not null default false,
  sop_document_code text,
  runbook_code text,
  deprecated_at timestamptz,
  created_at timestamptz not null default now(),

  constraint chk_error_domain check (
    error_domain in (
      'AUTH', 'SESSION', 'ORDER', 'PAYMENT',
      'KDS', 'INVENTORY', 'STAFF', 'DEVICE',
      'AGENT', 'KNOWLEDGE', 'DELIVERY',
      'CUSTOMER', 'FRANCHISE', 'SYSTEM',
      'GATEWAY', 'INTEGRATION', 'VALIDATION'
    )
  ),
  constraint chk_error_category check (
    error_category in (
      'NOT_FOUND', 'CONFLICT', 'INVALID_INPUT',
      'PERMISSION', 'BUSINESS_RULE', 'TECHNICAL',
      'TIMEOUT', 'CAPACITY', 'FINANCIAL',
      'SECURITY', 'INTEGRATION', 'RECOVERABLE'
    )
  ),
  constraint chk_severity check (
    severity in (
      'DEBUG', 'INFO', 'WARNING', 'ERROR',
      'CRITICAL', 'FATAL'
    )
  )
);

comment on table catchmenu_common.error_codes is
  'Stable numeric error code registry.
   Codes NEVER change once assigned.
   Ranges:
   1000-1999: AUTH/SECURITY
   2000-2999: SESSION/WAITING
   3000-3999: ORDER
   4000-4999: PAYMENT/FINANCIAL
   5000-5999: KDS
   6000-6999: INVENTORY
   7000-7999: STAFF/DEVICE/AGENT
   8000-8999: KNOWLEDGE/AI
   9000-9999: DELIVERY/INTEGRATION
   10000-10999: CUSTOMER/MEMBERSHIP
   11000-11999: FRANCHISE/HQ
   99000-99999: SYSTEM/INTERNAL';


-- =============================================
-- message_catalog table
-- 다국어 메시지 분리
-- =============================================
create table if not exists catchmenu_common.message_catalog (
  id uuid primary key default gen_random_uuid(),
  message_key text not null,
  locale text not null,
  message_text text not null,
  message_template text,
  context_hint text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_message_locale unique (
    message_key, locale
  ),
  constraint chk_locale check (
    locale in ('ko', 'en', 'zh', 'ja', 'vi', 'th')
  )
);

create index if not exists idx_message_catalog_key
  on catchmenu_common.message_catalog(
    message_key, locale
  );

drop trigger if exists trg_message_catalog_updated_at
  on catchmenu_common.message_catalog;
create trigger trg_message_catalog_updated_at
  before update on catchmenu_common.message_catalog
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.message_catalog is
  'i18n message catalog for all user-facing messages.
   message_key: stable identifier (never changes).
   message_template: use {param} for interpolation.
   Supported locales: ko, en, zh, ja, vi, th.
   특허1: 다국어 고객 안내 — 메뉴/대기/알림 메시지 전체 i18n.';


-- =============================================
-- diagnostic_logs table
-- Unix-like structured log records
-- grep-friendly, append-only
-- =============================================
create table if not exists catchmenu_common.diagnostic_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  store_id uuid,

  -- Unix-like log fields
  log_level text not null default 'INFO',
  error_code int,
  error_key text,
  log_domain text not null,
  log_event text not null,

  -- structured payload
  message text not null,
  details jsonb default '{}'::jsonb,

  -- recovery
  recovery_hint text,
  sop_document_code text,
  runbook_code text,
  is_recoverable boolean not null default true,

  -- linkage
  correlation_id text,
  session_id uuid,
  order_id uuid,
  payment_id uuid,
  exception_id uuid,
  audit_id uuid,
  device_id uuid,
  agent_id uuid,
  staff_id uuid,

  -- stack context
  rpc_name text,
  rpc_version text default '1.0',
  caller_type text,
  caller_id uuid,

  -- timing
  business_day date,
  business_timezone text default 'Asia/Seoul',
  occurred_at timestamptz not null default now(),
  created_at timestamptz not null default now(),

  constraint chk_log_level check (
    log_level in (
      'DEBUG', 'INFO', 'WARNING',
      'ERROR', 'CRITICAL', 'FATAL'
    )
  )
);

-- grep-friendly composite indexes
create index if not exists idx_diag_log_level_domain
  on catchmenu_common.diagnostic_logs(
    log_level, log_domain, occurred_at desc
  );
create index if not exists idx_diag_store_day
  on catchmenu_common.diagnostic_logs(
    store_id, business_day, log_level
  ) where store_id is not null;
create index if not exists idx_diag_error_code
  on catchmenu_common.diagnostic_logs(error_code)
  where error_code is not null;
create index if not exists idx_diag_correlation
  on catchmenu_common.diagnostic_logs(correlation_id)
  where correlation_id is not null;
create index if not exists idx_diag_order
  on catchmenu_common.diagnostic_logs(order_id)
  where order_id is not null;

alter table catchmenu_common.diagnostic_logs
  enable row level security;
alter table catchmenu_common.diagnostic_logs
  force row level security;

drop policy if exists diag_logs_isolation
  on catchmenu_common.diagnostic_logs;
create policy diag_logs_isolation
  on catchmenu_common.diagnostic_logs
  for all to authenticated
  using (
    tenant_id is null
    or tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_common.diagnostic_logs is
  'Unix-like structured diagnostic log.
   Append-only — no UPDATE or DELETE.
   grep-friendly: log_level, log_domain, error_code
   are always present.
   Example grep:
     SELECT * FROM diagnostic_logs
     WHERE log_level = ''ERROR''
       AND log_domain = ''PAYMENT''
       AND store_id = $1
       AND occurred_at > now() - interval ''1 hour'';
   SOP/Runbook codes enable incident reconstruction.
   특허4: 감사 추적 가능 진단 원장.';


-- =============================================
-- Seed error codes
-- =============================================
insert into catchmenu_common.error_codes (
  code, error_key, error_domain, error_category,
  http_status, severity, is_retryable,
  sop_document_code
) values
-- AUTH/SECURITY (1000~)
(1001, 'device_not_trusted', 'AUTH', 'SECURITY', 403, 'ERROR', false, null),
(1002, 'device_trust_revoked', 'AUTH', 'SECURITY', 403, 'CRITICAL', false, null),
(1003, 'insufficient_authority', 'AUTH', 'PERMISSION', 403, 'ERROR', false, null),
(1004, 'staff_terminated', 'AUTH', 'PERMISSION', 403, 'ERROR', false, null),
(1005, 'webhook_signature_failed', 'GATEWAY', 'SECURITY', 401, 'CRITICAL', false, null),
(1006, 'kiosk_not_trusted', 'AUTH', 'SECURITY', 403, 'ERROR', false, null),
(1007, 'kiosk_not_online', 'AUTH', 'TECHNICAL', 503, 'WARNING', true, null),

-- SESSION/WAITING (2000~)
(2001, 'session_not_found', 'SESSION', 'NOT_FOUND', 404, 'WARNING', false, null),
(2002, 'session_not_pre_orderable', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2003, 'session_not_cancellable', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2004, 'session_still_active', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2005, 'no_waiting_session_found', 'SESSION', 'NOT_FOUND', 404, 'INFO', false, null),
(2006, 'pre_order_expired', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2007, 'arrival_reliability_too_low', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2008, 'pre_order_disabled', 'SESSION', 'BUSINESS_RULE', 409, 'INFO', false, null),
(2009, 'session_not_ordering', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2010, 'not_a_pre_order_session', 'SESSION', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(2011, 'queue_empty', 'SESSION', 'NOT_FOUND', 404, 'INFO', false, null),

-- ORDER (3000~)
(3001, 'order_not_found', 'ORDER', 'NOT_FOUND', 404, 'WARNING', false, null),
(3002, 'order_not_confirmable', 'ORDER', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(3003, 'order_not_cancellable', 'ORDER', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(3004, 'items_required', 'ORDER', 'INVALID_INPUT', 400, 'WARNING', false, null),
(3005, 'menu_not_found', 'ORDER', 'NOT_FOUND', 404, 'WARNING', false, null),
(3006, 'menu_sold_out', 'ORDER', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(3007, 'duplicate_delivery_order', 'ORDER', 'CONFLICT', 409, 'WARNING', false, null),
(3008, 'menu_not_available', 'ORDER', 'BUSINESS_RULE', 409, 'WARNING', false, null),

-- PAYMENT/FINANCIAL (4000~)
(4001, 'ledger_not_found', 'PAYMENT', 'NOT_FOUND', 404, 'ERROR', false, null),
(4002, 'ledger_not_cancellable', 'PAYMENT', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(4003, 'ledger_not_refundable', 'PAYMENT', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(4004, 'cancel_amount_exceeds_approved', 'PAYMENT', 'FINANCIAL', 400, 'ERROR', false, null),
(4005, 'refund_exceeds_net_amount', 'PAYMENT', 'FINANCIAL', 400, 'ERROR', false, null),
(4006, 'payment_uncertain_active', 'PAYMENT', 'FINANCIAL', 409, 'CRITICAL', false, null),
(4007, 'intent_not_found', 'PAYMENT', 'NOT_FOUND', 404, 'ERROR', false, null),
(4008, 'active_case_exists', 'PAYMENT', 'CONFLICT', 409, 'WARNING', false, null),
(4009, 'case_already_resolved', 'PAYMENT', 'CONFLICT', 409, 'WARNING', false, null),
(4010, 'van_approval_failed', 'PAYMENT', 'INTEGRATION', 502, 'ERROR', true, null),
(4011, 'van_tx_not_cancellable', 'PAYMENT', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(4012, 'cancel_reason_required', 'PAYMENT', 'INVALID_INPUT', 400, 'WARNING', false, null),
(4013, 'kds_release_not_authorized', 'PAYMENT', 'BUSINESS_RULE', 409, 'CRITICAL', false, null),

-- KDS (5000~)
(5001, 'ticket_not_found', 'KDS', 'NOT_FOUND', 404, 'WARNING', false, null),
(5002, 'ticket_not_in_hold', 'KDS', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(5003, 'kds_overloaded', 'KDS', 'CAPACITY', 503, 'WARNING', true, null),
(5004, 'invalid_extend_minutes', 'KDS', 'INVALID_INPUT', 400, 'WARNING', false, null),
(5005, 'no_hold_tickets_found', 'KDS', 'NOT_FOUND', 404, 'INFO', false, null),
(5006, 'conditions_not_met', 'KDS', 'BUSINESS_RULE', 409, 'WARNING', false, null),

-- INVENTORY (6000~)
(6001, 'ingredient_not_found', 'INVENTORY', 'NOT_FOUND', 404, 'WARNING', false, null),
(6002, 'ingredient_code_exists', 'INVENTORY', 'CONFLICT', 409, 'WARNING', false, null),
(6003, 'quantity_change_cannot_be_zero', 'INVENTORY', 'INVALID_INPUT', 400, 'WARNING', false, null),
(6004, 'ingredient_out_of_stock', 'INVENTORY', 'CAPACITY', 409, 'WARNING', false, null),

-- STAFF/DEVICE/AGENT (7000~)
(7001, 'staff_not_found', 'STAFF', 'NOT_FOUND', 404, 'WARNING', false, null),
(7002, 'staff_code_already_exists', 'STAFF', 'CONFLICT', 409, 'WARNING', false, null),
(7003, 'already_clocked_in', 'STAFF', 'CONFLICT', 409, 'WARNING', false, null),
(7004, 'already_clocked_out', 'STAFF', 'CONFLICT', 409, 'WARNING', false, null),
(7005, 'not_clocked_in', 'STAFF', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(7006, 'device_not_found', 'DEVICE', 'NOT_FOUND', 404, 'WARNING', false, null),
(7007, 'device_code_already_exists', 'DEVICE', 'CONFLICT', 409, 'WARNING', false, null),
(7008, 'agent_not_found', 'AGENT', 'NOT_FOUND', 404, 'WARNING', false, null),
(7009, 'agent_already_isolated', 'AGENT', 'CONFLICT', 409, 'WARNING', false, null),
(7010, 'agent_not_recoverable', 'AGENT', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(7011, 'isolation_reason_required', 'AGENT', 'INVALID_INPUT', 400, 'WARNING', false, null),
(7012, 'did_device_not_found', 'DEVICE', 'NOT_FOUND', 404, 'WARNING', false, null),

-- KNOWLEDGE/AI (8000~)
(8001, 'gap_not_found', 'KNOWLEDGE', 'NOT_FOUND', 404, 'WARNING', false, null),
(8002, 'gap_already_resolved', 'KNOWLEDGE', 'CONFLICT', 409, 'INFO', false, null),
(8003, 'version_not_found', 'KNOWLEDGE', 'NOT_FOUND', 404, 'WARNING', false, null),
(8004, 'governance_check_required', 'KNOWLEDGE', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(8005, 'search_query_required', 'KNOWLEDGE', 'INVALID_INPUT', 400, 'WARNING', false, null),
(8006, 'no_knowledge_found', 'KNOWLEDGE', 'NOT_FOUND', 404, 'INFO', false, null),

-- DELIVERY/INTEGRATION (9000~)
(9001, 'baemin_not_configured', 'DELIVERY', 'INTEGRATION', 503, 'ERROR', false, null),
(9002, 'yogiyo_not_configured', 'DELIVERY', 'INTEGRATION', 503, 'ERROR', false, null),
(9003, 'coupang_not_configured', 'DELIVERY', 'INTEGRATION', 503, 'ERROR', false, null),
(9004, 'baemin_platform_suspended', 'DELIVERY', 'INTEGRATION', 503, 'WARNING', false, null),
(9005, 'missing_baemin_order_id', 'DELIVERY', 'INVALID_INPUT', 400, 'ERROR', false, null),
(9006, 'missing_yogiyo_order_id', 'DELIVERY', 'INVALID_INPUT', 400, 'ERROR', false, null),
(9007, 'missing_coupang_order_id', 'DELIVERY', 'INVALID_INPUT', 400, 'ERROR', false, null),
(9008, 'invalid_van_provider', 'INTEGRATION', 'INVALID_INPUT', 400, 'WARNING', false, null),
(9009, 'van_tx_not_found', 'INTEGRATION', 'NOT_FOUND', 404, 'WARNING', false, null),
(9010, 'platform_not_configured', 'DELIVERY', 'INTEGRATION', 503, 'ERROR', false, null),
(9011, 'menu_sync_disabled', 'DELIVERY', 'BUSINESS_RULE', 409, 'INFO', false, null),
(9012, 'signature_verification_failed', 'GATEWAY', 'SECURITY', 401, 'CRITICAL', false, null),
(9013, 'unknown_toss_status', 'INTEGRATION', 'INTEGRATION', 422, 'ERROR', false, null),

-- CUSTOMER/MEMBERSHIP (10000~)
(10001, 'customer_not_found', 'CUSTOMER', 'NOT_FOUND', 404, 'WARNING', false, null),
(10002, 'phone_hash_required', 'CUSTOMER', 'INVALID_INPUT', 400, 'WARNING', false, null),
(10003, 'coupon_not_found', 'CUSTOMER', 'NOT_FOUND', 404, 'WARNING', false, null),
(10004, 'coupon_not_active', 'CUSTOMER', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(10005, 'coupon_exhausted', 'CUSTOMER', 'CAPACITY', 409, 'INFO', false, null),
(10006, 'customer_tier_not_eligible', 'CUSTOMER', 'BUSINESS_RULE', 403, 'INFO', false, null),
(10007, 'customer_issue_limit_reached', 'CUSTOMER', 'BUSINESS_RULE', 409, 'INFO', false, null),
(10008, 'coupon_issue_not_found', 'CUSTOMER', 'NOT_FOUND', 404, 'WARNING', false, null),
(10009, 'coupon_not_redeemable', 'CUSTOMER', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(10010, 'coupon_expired', 'CUSTOMER', 'BUSINESS_RULE', 409, 'INFO', false, null),
(10011, 'order_amount_below_minimum', 'CUSTOMER', 'BUSINESS_RULE', 400, 'WARNING', false, null),
(10012, 'insufficient_points', 'CUSTOMER', 'FINANCIAL', 400, 'WARNING', false, null),
(10013, 'exceeds_max_deduction', 'CUSTOMER', 'FINANCIAL', 400, 'WARNING', false, null),

-- FRANCHISE/HQ (11000~)
(11001, 'store_code_already_exists', 'FRANCHISE', 'CONFLICT', 409, 'WARNING', false, null),
(11002, 'template_not_found', 'FRANCHISE', 'NOT_FOUND', 404, 'WARNING', false, null),
(11003, 'template_not_published', 'FRANCHISE', 'BUSINESS_RULE', 409, 'WARNING', false, null),
(11004, 'store_not_found', 'FRANCHISE', 'NOT_FOUND', 404, 'WARNING', false, null),

-- SYSTEM/INTERNAL (99000~)
(99001, 'internal_error', 'SYSTEM', 'TECHNICAL', 500, 'CRITICAL', true, null),
(99002, 'database_error', 'SYSTEM', 'TECHNICAL', 500, 'CRITICAL', true, null),
(99003, 'timeout', 'SYSTEM', 'TIMEOUT', 504, 'ERROR', true, null),
(99004, 'invalid_input', 'VALIDATION', 'INVALID_INPUT', 400, 'WARNING', false, null),
(99005, 'not_implemented', 'SYSTEM', 'TECHNICAL', 501, 'INFO', false, null)
on conflict (code) do nothing;


-- =============================================
-- Seed message catalog (ko/en)
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text, message_template
) values
-- 공통 성공 메시지
('session_created', 'ko', '세션이 생성되었습니다', null),
('session_created', 'en', 'Session created', null),
('order_confirmed', 'ko', '주문이 확인되었습니다', null),
('order_confirmed', 'en', 'Order confirmed', null),
('order_cancelled', 'ko', '주문이 취소되었습니다', null),
('order_cancelled', 'en', 'Order cancelled', null),
('payment_confirmed', 'ko', '결제가 완료되었습니다', null),
('payment_confirmed', 'en', 'Payment confirmed', null),
('payment_cancelled', 'ko', '결제가 취소되었습니다', null),
('payment_cancelled', 'en', 'Payment cancelled', null),
('order_ready', 'ko', '{order_number}번 주문이 준비되었습니다', ''),
('order_ready', 'en', 'Order {order_number} is ready', ''),
('order_ready', 'zh', '{order_number}号订单已准备好', ''),
('order_ready', 'ja', '{order_number}番のご注文が準備できました', ''),
('waiting_called', 'ko', '{wait_number}번 고객님 입장해 주세요', ''),
('waiting_called', 'en', 'Customer #{wait_number}, please come in', ''),
('waiting_called', 'zh', '{wait_number}号顾客请进', ''),
('waiting_called', 'ja', '{wait_number}番のお客様、どうぞお入りください', ''),
('pre_order_created', 'ko', '사전 주문이 완료되었습니다. 도착 후 자리를 배정받으세요.', null),
('pre_order_created', 'en', 'Pre-order placed. Please wait for table assignment upon arrival.', null),
('pre_order_created', 'zh', '预订已完成。到达后请等待座位安排。', null),
('pre_order_created', 'ja', '事前注文が完了しました。到着後、席のご案内をお待ちください。', null),

-- 에러 메시지 (customer facing)
('menu_sold_out', 'ko', '죄송합니다. {menu_name}은(는) 현재 품절입니다.', ''),
('menu_sold_out', 'en', 'Sorry, {menu_name} is currently sold out.', ''),
('menu_sold_out', 'zh', '抱歉，{menu_name}目前已售完。', ''),
('menu_sold_out', 'ja', '申し訳ございません。{menu_name}は現在売り切れです。', ''),
('arrival_reliability_too_low', 'ko', '노쇼 이력으로 인해 사전 주문이 제한됩니다.', null),
('arrival_reliability_too_low', 'en', 'Pre-order is restricted due to no-show history.', null),
('coupon_expired', 'ko', '쿠폰 유효기간이 만료되었습니다.', null),
('coupon_expired', 'en', 'This coupon has expired.', null),
('coupon_expired', 'zh', '优惠券已过期。', null),
('coupon_expired', 'ja', 'クーポンの有効期限が切れています。', null),
('insufficient_points', 'ko', '포인트가 부족합니다. 현재 잔액: {point_balance}P', ''),
('insufficient_points', 'en', 'Insufficient points. Current balance: {point_balance}P', ''),
('order_amount_below_minimum', 'ko', '최소 주문 금액은 {min_order_amount}원입니다.', ''),
('order_amount_below_minimum', 'en', 'Minimum order amount is ₩{min_order_amount}.', ''),
('kds_overloaded', 'ko', '주방이 바빠 잠시 후 다시 시도해주세요.', null),
('kds_overloaded', 'en', 'Kitchen is busy. Please try again shortly.', null),
('kds_overloaded', 'zh', '厨房繁忙，请稍后再试。', null),
('kds_overloaded', 'ja', 'ただいまキッチンが混み合っています。少し後でお試しください。', null),
('pre_order_expired', 'ko', '사전 주문이 만료되었습니다. 다시 주문해 주세요.', null),
('pre_order_expired', 'en', 'Pre-order has expired. Please order again.', null),

-- 직원용 에러 메시지
('payment_uncertain_active', 'ko', '결제 불확실 상태입니다. 해소 전까지 KDS 조리를 진행할 수 없습니다.', null),
('payment_uncertain_active', 'en', 'Payment uncertain. KDS cooking blocked until resolved.', null),
('kds_release_not_authorized', 'ko', 'KDS 릴리즈 권한이 없습니다. 결제를 먼저 확인하세요.', null),
('kds_release_not_authorized', 'en', 'KDS release not authorized. Confirm payment first.', null),
('device_not_trusted', 'ko', '신뢰되지 않은 디바이스입니다. 관리자에게 문의하세요.', null),
('device_not_trusted', 'en', 'Device not trusted. Please contact your manager.', null),
('webhook_signature_failed', 'ko', '웹훅 서명 검증 실패. 보안 이벤트가 기록되었습니다.', null),
('webhook_signature_failed', 'en', 'Webhook signature verification failed. Security event logged.', null)
on conflict (message_key, locale) do nothing;


-- =============================================
-- Core functions
-- =============================================
create or replace function catchmenu_common.get_message(
  p_message_key text,
  p_locale text default 'ko',
  p_params jsonb default null
)
returns text
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_message text;
  v_param record;
  v_key text;
  v_value text;
begin
  -- try requested locale
  select message_text
  into v_message
  from catchmenu_common.message_catalog
  where message_key = p_message_key
    and locale = p_locale;

  -- fallback to 'ko'
  if v_message is null and p_locale <> 'ko' then
    select message_text
    into v_message
    from catchmenu_common.message_catalog
    where message_key = p_message_key
      and locale = 'ko';
  end if;

  -- fallback to 'en'
  if v_message is null and p_locale <> 'en' then
    select message_text
    into v_message
    from catchmenu_common.message_catalog
    where message_key = p_message_key
      and locale = 'en';
  end if;

  -- last fallback: return key itself
  if v_message is null then
    return p_message_key;
  end if;

  -- parameter interpolation {param_name}
  if p_params is not null then
    for v_key, v_value in
      select key, value::text
      from jsonb_each_text(p_params)
    loop
      v_message := replace(
        v_message,
        '{' || v_key || '}',
        v_value
      );
    end loop;
  end if;

  return v_message;
end;
$$;


create or replace function catchmenu_common.log_diagnostic(
  p_tenant_id uuid,
  p_store_id uuid,
  p_log_level text,
  p_log_domain text,
  p_log_event text,
  p_message text,
  p_error_key text default null,
  p_details jsonb default '{}'::jsonb,
  p_recovery_hint text default null,
  p_rpc_name text default null,
  p_correlation_id text default null,
  p_session_id uuid default null,
  p_order_id uuid default null,
  p_payment_id uuid default null,
  p_exception_id uuid default null,
  p_device_id uuid default null,
  p_agent_id uuid default null,
  p_caller_type text default null,
  p_caller_id uuid default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_log_id uuid;
  v_error_code int;
  v_sop_code text;
  v_runbook_code text;
  v_is_recoverable boolean := true;
begin
  -- lookup error code
  if p_error_key is not null then
    select code, sop_document_code,
           runbook_code,
           severity <> 'FATAL' as is_recoverable
    into v_error_code, v_sop_code,
         v_runbook_code, v_is_recoverable
    from catchmenu_common.error_codes
    where error_key = p_error_key;
  end if;

  insert into catchmenu_common.diagnostic_logs (
    tenant_id, store_id,
    log_level, error_code, error_key,
    log_domain, log_event,
    message, details,
    recovery_hint, sop_document_code, runbook_code,
    is_recoverable,
    correlation_id,
    session_id, order_id, payment_id,
    exception_id, device_id, agent_id,
    rpc_name, caller_type, caller_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    p_log_level, v_error_code, p_error_key,
    p_log_domain, p_log_event,
    p_message, coalesce(p_details, '{}'::jsonb),
    p_recovery_hint, v_sop_code, v_runbook_code,
    v_is_recoverable,
    p_correlation_id,
    p_session_id, p_order_id, p_payment_id,
    p_exception_id, p_device_id, p_agent_id,
    p_rpc_name, p_caller_type, p_caller_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  )
  returning id into v_log_id;

  return v_log_id;
end;
$$;


create or replace function catchmenu_common.build_error_response(
  p_error_key text,
  p_locale text default 'ko',
  p_params jsonb default null,
  p_details jsonb default null,
  p_tenant_id uuid default null,
  p_store_id uuid default null,
  p_correlation_id text default null,
  p_rpc_name text default null,
  p_order_id uuid default null,
  p_payment_id uuid default null,
  p_session_id uuid default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_error_code int;
  v_http_status int;
  v_severity text;
  v_is_retryable boolean;
  v_sop_code text;
  v_runbook_code text;
  v_error_domain text;
  v_error_category text;
  v_message text;
  v_recovery_hint text;
  v_log_id uuid;
begin
  -- get error metadata
  select code, http_status, severity,
         is_retryable, sop_document_code,
         runbook_code, error_domain, error_category
  into v_error_code, v_http_status, v_severity,
       v_is_retryable, v_sop_code, v_runbook_code,
       v_error_domain, v_error_category
  from catchmenu_common.error_codes
  where error_key = p_error_key;

  -- get i18n message
  v_message := catchmenu_common.get_message(
    p_error_key, p_locale, p_params
  );

  -- recovery hint for retryable errors
  v_recovery_hint := case v_is_retryable
    when true then catchmenu_common.get_message(
      'hint_retry_after_moment', p_locale, null
    )
    else null
  end;

  -- log diagnostic entry
  if p_tenant_id is not null then
    v_log_id := catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := coalesce(v_severity, 'ERROR'),
      p_log_domain := coalesce(v_error_domain, 'SYSTEM'),
      p_log_event := p_error_key,
      p_message := v_message,
      p_error_key := p_error_key,
      p_details := p_details,
      p_recovery_hint := v_recovery_hint,
      p_rpc_name := p_rpc_name,
      p_correlation_id := p_correlation_id,
      p_order_id := p_order_id,
      p_payment_id := p_payment_id,
      p_session_id := p_session_id
    );
  end if;

  return jsonb_build_object(
    'success', false,
    'error', jsonb_build_object(
      'code', v_error_code,
      'key', p_error_key,
      'message', v_message,
      'domain', v_error_domain,
      'category', v_error_category,
      'severity', v_severity,
      'http_status', coalesce(v_http_status, 400),
      'is_retryable', coalesce(v_is_retryable, false),
      'sop_code', v_sop_code,
      'runbook_code', v_runbook_code,
      'recovery_hint', v_recovery_hint
    ),
    'meta', jsonb_build_object(
      'correlation_id', p_correlation_id,
      'log_id', v_log_id,
      'occurred_at', now(),
      'locale', p_locale
    )
  );
end;
$$;


create or replace function catchmenu_common.build_success_response(
  p_message_key text,
  p_data jsonb,
  p_locale text default 'ko',
  p_params jsonb default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_message text;
begin
  v_message := catchmenu_common.get_message(
    p_message_key, p_locale, p_params
  );

  return jsonb_build_object(
    'success', true,
    'message', v_message,
    'message_key', p_message_key,
    'data', p_data,
    'meta', jsonb_build_object(
      'correlation_id', p_correlation_id,
      'locale', p_locale,
      'occurred_at', now()
    )
  );
end;
$$;


-- =============================================
-- Diagnostic query helpers (grep-friendly views)
-- =============================================
create or replace view catchmenu_common.v_error_log as
select
  dl.id as log_id,
  dl.occurred_at,
  dl.log_level,
  dl.error_code,
  dl.error_key,
  dl.log_domain,
  dl.log_event,
  dl.message,
  dl.recovery_hint,
  dl.sop_document_code,
  dl.is_recoverable,
  dl.rpc_name,
  dl.correlation_id,
  dl.tenant_id,
  dl.store_id,
  dl.order_id,
  dl.payment_id,
  dl.session_id,
  dl.exception_id,
  -- Unix-like log line format
  -- [LEVEL] DOMAIN.EVENT code=XXXX key=xxx msg="..."
  '[' || dl.log_level || '] '
    || dl.log_domain || '.' || dl.log_event
    || case when dl.error_code is not null
      then ' code=' || dl.error_code
      else ''
    end
    || case when dl.error_key is not null
      then ' key=' || dl.error_key
      else ''
    end
    || ' msg="' || dl.message || '"'
    || case when dl.correlation_id is not null
      then ' correlation_id=' || dl.correlation_id
      else ''
    end as log_line
from catchmenu_common.diagnostic_logs dl
where dl.log_level in (
  'WARNING', 'ERROR', 'CRITICAL', 'FATAL'
);

comment on view catchmenu_common.v_error_log is
  'Unix-like grep-friendly error log view.
   Use log_line column for text-based log analysis.
   Example:
     SELECT log_line FROM v_error_log
     WHERE store_id = $1
       AND occurred_at > now() - interval ''1 hour''
     ORDER BY occurred_at DESC;';


-- grants
do $$
begin
  grant select on catchmenu_common.error_codes
    to authenticated;
  grant select on catchmenu_common.message_catalog
    to authenticated;
  grant select on catchmenu_common.v_error_log
    to authenticated;

  revoke all on function catchmenu_common.get_message(
    text, text, jsonb
  ) from public;
  grant execute on function catchmenu_common.get_message(
    text, text, jsonb
  ) to authenticated;

  revoke all on function catchmenu_common.log_diagnostic(
    uuid, uuid, text, text, text, text,
    text, jsonb, text, text, text, uuid,
    uuid, uuid, uuid, uuid, uuid, text, uuid
  ) from public;
  grant execute on function catchmenu_common.log_diagnostic(
    uuid, uuid, text, text, text, text,
    text, jsonb, text, text, text, uuid,
    uuid, uuid, uuid, uuid, uuid, text, uuid
  ) to authenticated;

  revoke all on function catchmenu_common.build_error_response(
    text, text, jsonb, jsonb, uuid, uuid,
    text, text, uuid, uuid, uuid
  ) from public;
  grant execute on function catchmenu_common.build_error_response(
    text, text, jsonb, jsonb, uuid, uuid,
    text, text, uuid, uuid, uuid
  ) to authenticated;

  revoke all on function catchmenu_common.build_success_response(
    text, jsonb, text, jsonb, text
  ) from public;
  grant execute on function catchmenu_common.build_success_response(
    text, jsonb, text, jsonb, text
  ) to authenticated;
end;
$$;

comment on function catchmenu_common.build_error_response(
  text, text, jsonb, jsonb, uuid, uuid,
  text, text, uuid, uuid, uuid
) is
  'Builds structured error response with i18n message.
   Always includes:
     error.code: stable numeric code (never changes)
     error.key: grep-friendly text key
     error.message: i18n user message
     error.severity: DEBUG/INFO/WARNING/ERROR/CRITICAL/FATAL
     error.is_retryable: client retry guidance
     error.sop_code: linked SOP for staff
     error.recovery_hint: localized recovery guidance
     meta.log_id: diagnostic log entry ID
     meta.correlation_id: request tracing
   Auto-logs to diagnostic_logs table.
   Unix errno 설계 원칙:
     코드는 절대 재사용 금지.
     코드는 절대 변경 금지.
     메시지는 코드와 분리.
     severity는 syslog 수준 호환.';

comment on function catchmenu_common.log_diagnostic(
  uuid, uuid, text, text, text, text,
  text, jsonb, text, text, text, uuid,
  uuid, uuid, uuid, uuid, uuid, text, uuid
) is
  'Structured diagnostic log writer.
   grep-friendly: log_level + log_domain + error_code
   always present.
   Incident reconstruction:
     correlation_id links all log entries for one request.
     order_id links payment, KDS, session logs.
     exception_id links to Exception Ledger.
   특허4: 감사 추적 가능 진단 원장.
   모든 ERROR 이상 이벤트는 diagnostic_logs에 기록.';