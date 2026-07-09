-- 0121_create_security_pipeline.sql
-- Purpose: Security pipeline.
--          샌드박스 격리 레이어.
--          Gateway 단일 진입점 강제.
--          1회성 시크릿 토큰 관리.
--          외부 오염 탐지 4단계.
--          자동 차단 파이프라인.
--          보안 위협 자동 에스컬레이션.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0120_create_reconciliation_pipeline.sql
-- Creates:
--   catchmenu_common.security_tokens (table)
--   catchmenu_common.security_threats (table)
--   catchmenu_common.gateway_audit_log (table)
--   catchmenu_common.sandbox_violations (table)
--   function catchmenu_common.issue_security_token(...)
--   function catchmenu_common.verify_security_token(...)
--   function catchmenu_common.consume_security_token(...)
--   function catchmenu_common.detect_threat(...)
--   function catchmenu_common.auto_block_threat(...)
--   function catchmenu_common.gateway_audit_entry(...)
--   function catchmenu_common.run_security_scan(...)
--   function catchmenu_common.get_security_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('security_token_issued', 'ko',
  '보안 토큰이 발급되었습니다'),
('security_token_issued', 'en',
  'Security token issued'),
('security_token_valid', 'ko',
  '토큰이 유효합니다'),
('security_token_valid', 'en',
  'Token valid'),
('security_token_consumed', 'ko',
  '토큰이 사용되었습니다'),
('security_token_consumed', 'en',
  'Token consumed'),
('threat_detected', 'ko',
  '보안 위협이 탐지되었습니다'),
('threat_detected', 'en',
  'Security threat detected'),
('access_blocked', 'ko',
  '보안 정책에 의해 차단되었습니다'),
('access_blocked', 'en',
  'Access blocked by security policy'),
('access_blocked', 'zh',
  '已被安全策略阻止'),
('access_blocked', 'ja',
  'セキュリティポリシーによりブロックされました'),
('access_blocked', 'vi',
  'Bị chặn bởi chính sách bảo mật'),
('access_blocked', 'th',
  'ถูกบล็อกโดยนโยบายความปลอดภัย'),
('security_dashboard_loaded', 'ko',
  '보안 대시보드가 로드되었습니다'),
('security_dashboard_loaded', 'en',
  'Security dashboard loaded'),
('sandbox_violation_detected', 'ko',
  '샌드박스 위반이 탐지되었습니다'),
('sandbox_violation_detected', 'en',
  'Sandbox violation detected')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9001, 'security_token_invalid',
  'SECURITY', 'PERMISSION', 401,
  'ERROR', 'SOP-SEC-001'),
(9002, 'security_token_expired',
  'SECURITY', 'PERMISSION', 401,
  'ERROR', 'SOP-SEC-001'),
(9003, 'security_token_already_used',
  'SECURITY', 'PERMISSION', 401,
  'ERROR', 'SOP-SEC-001'),
(9004, 'access_blocked_threat',
  'SECURITY', 'PERMISSION', 403,
  'CRITICAL', 'SOP-SEC-002'),
(9005, 'sandbox_boundary_violated',
  'SECURITY', 'PERMISSION', 403,
  'CRITICAL', 'SOP-SEC-003'),
(9006, 'gateway_bypass_detected',
  'SECURITY', 'PERMISSION', 403,
  'FATAL', 'SOP-SEC-003'),
(9007, 'external_contamination_detected',
  'SECURITY', 'SECURITY', 403,
  'FATAL', 'SOP-SEC-004'),
(9008, 'secret_exposure_detected',
  'SECURITY', 'SECURITY', 500,
  'FATAL', 'SOP-SEC-004'),
(9009, 'threat_auto_blocked',
  'SECURITY', 'PERMISSION', 403,
  'ERROR', 'SOP-SEC-002'),
(9010, 'rate_limit_exceeded',
  'SECURITY', 'CAPACITY', 429,
  'WARNING', 'SOP-SEC-001')
on conflict (code) do nothing;


-- =============================================
-- security_tokens table
-- 1회성 보안 토큰
-- =============================================
create table if not exists
  catchmenu_common.security_tokens (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null,
  store_id uuid,

  -- 토큰 정보
  token_hash text not null unique,
  token_type text not null,
  token_purpose text not null,

  -- 연결 정보
  subject_type text not null,
  subject_id text not null,
  device_id uuid,

  -- 메타데이터
  scope jsonb default '{}'::jsonb,
  context_hash text,

  -- 상태 (1회성 핵심)
  token_status text not null default 'ACTIVE',
  used_at timestamptz,
  used_by_ip_hash text,

  -- 만료
  expires_at timestamptz not null,
  max_uses int not null default 1,
  use_count int not null default 0,

  -- 감사
  issued_at timestamptz not null default now(),
  issued_by text default 'SYSTEM',

  constraint chk_token_type check (
    token_type in (
      'PAYMENT_INTENT',    -- 결제 의도 토큰
      'KDS_RELEASE',       -- KDS 해제 토큰
      'REFUND_APPROVE',    -- 환불 승인 토큰
      'WEBHOOK_VERIFY',    -- 웹훅 검증 토큰
      'EXPORT_PERMIT',     -- 데이터 내보내기
      'ADMIN_ACTION',      -- 관리자 위험 액션
      'DEVICE_TRUST',      -- 디바이스 신뢰 승인
      'SECRET_ACCESS'      -- 시크릿 일회성 접근
    )
  ),
  constraint chk_token_status check (
    token_status in (
      'ACTIVE',    -- 사용 가능
      'USED',      -- 사용됨 (1회성)
      'EXPIRED',   -- 만료됨
      'REVOKED',   -- 강제 취소
      'BLOCKED'    -- 위협으로 차단
    )
  )
);

create index if not exists idx_security_tokens_hash
  on catchmenu_common.security_tokens(
    token_hash
  ) where token_status = 'ACTIVE';

create index if not exists idx_security_tokens_expire
  on catchmenu_common.security_tokens(
    expires_at
  ) where token_status = 'ACTIVE';

alter table catchmenu_common.security_tokens
  enable row level security;
alter table catchmenu_common.security_tokens
  force row level security;

drop policy if exists security_tokens_isolation
  on catchmenu_common.security_tokens;
create policy security_tokens_isolation
  on catchmenu_common.security_tokens
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_common.security_tokens is
  '1회성 보안 토큰.
   핵심 원칙:
   max_uses = 1: 한 번만 사용 가능.
   사용 즉시 USED → 재사용 불가.
   만료 시 EXPIRED → 자동 무효화.
   token_hash: SHA-256 (원본 미저장).
   PAYMENT_INTENT: 결제 시작 전 발급.
   → 결제 확인 시 소비 → 중복결제 방지.
   KDS_RELEASE: KDS 해제 전 발급.
   → 특허2 Late Binding 보안 강화.
   시크릿 코딩 원칙:
   실제 토큰값은 Edge Function에만 존재.
   DB에는 SHA-256 해시만 저장.';


-- =============================================
-- security_threats table
-- 보안 위협 탐지 로그
-- =============================================
create table if not exists
  catchmenu_common.security_threats (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  store_id uuid,
  device_id uuid,

  -- 위협 분류 (4단계)
  threat_stage int not null,
  threat_type text not null,
  threat_severity text not null,

  -- 탐지 정보
  detected_at timestamptz
    not null default now(),
  detection_source text not null,
  threat_vector text,
  threat_payload jsonb,

  -- 영향
  affected_resource text,
  affected_resource_id text,

  -- 자동 대응
  auto_blocked boolean not null default false,
  block_applied_at timestamptz,
  block_duration_minutes int,
  block_scope text,

  -- 처리
  threat_status text not null default 'OPEN',
  resolved_at timestamptz,
  resolved_by uuid,
  resolution_note text,

  -- 에스컬레이션
  is_escalated boolean not null default false,
  escalated_at timestamptz,
  escalation_level int default 0,

  constraint chk_threat_stage check (
    threat_stage between 1 and 4
  ),
  constraint chk_threat_type check (
    threat_type in (
      -- Stage 1: 입력 위협
      'SQL_INJECTION_ATTEMPT',
      'XSS_ATTEMPT',
      'INVALID_INPUT_PATTERN',
      'SCHEMA_PROBE',
      -- Stage 2: 인증 위협
      'BRUTE_FORCE',
      'TOKEN_REPLAY',
      'SESSION_HIJACK',
      'DEVICE_SPOOF',
      -- Stage 3: 권한 위협
      'RLS_BYPASS_ATTEMPT',
      'TENANT_BOUNDARY_VIOLATION',
      'SANDBOX_ESCAPE',
      'GATEWAY_BYPASS',
      -- Stage 4: 데이터 위협
      'DATA_EXFILTRATION',
      'SECRET_PROBE',
      'EXTERNAL_CONTAMINATION',
      'INTEGRITY_VIOLATION'
    )
  ),
  constraint chk_threat_severity check (
    threat_severity in (
      'LOW', 'MEDIUM', 'HIGH',
      'CRITICAL', 'FATAL'
    )
  ),
  constraint chk_threat_status check (
    threat_status in (
      'OPEN', 'INVESTIGATING',
      'BLOCKED', 'RESOLVED', 'FALSE_POSITIVE'
    )
  )
);

create index if not exists idx_threats_open
  on catchmenu_common.security_threats(
    tenant_id, threat_status, detected_at desc
  ) where threat_status = 'OPEN';

create index if not exists idx_threats_fatal
  on catchmenu_common.security_threats(
    threat_severity, detected_at desc
  ) where threat_severity in (
    'CRITICAL', 'FATAL'
  );

alter table catchmenu_common.security_threats
  enable row level security;
alter table catchmenu_common.security_threats
  force row level security;

drop policy if exists threats_hq_read
  on catchmenu_common.security_threats;
create policy threats_hq_read
  on catchmenu_common.security_threats
  for select to authenticated
  using (
    tenant_id is null
    or tenant_id =
      catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_common.security_threats is
  '보안 위협 탐지 로그.
   4단계 탐지 체계:
   Stage 1: 입력 검증 (SQL injection / XSS)
   Stage 2: 인증 공격 (브루트포스 / 토큰 재사용)
   Stage 3: 권한 침해 (RLS 우회 / 테넌트 경계)
   Stage 4: 데이터 무결성 (유출 / 시크릿 탐색)
   auto_blocked: 자동 차단 적용 여부.
   FATAL → 즉시 자동 차단 + HQ 에스컬레이션.
   append-only 감사 원장.';


-- =============================================
-- gateway_audit_log table
-- Gateway 진입점 감사 로그
-- =============================================
create table if not exists
  catchmenu_common.gateway_audit_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  store_id uuid,
  device_id uuid,

  -- 요청 정보
  request_id text not null unique
    default gen_random_uuid()::text,
  rpc_name text not null,
  rpc_schema text not null,

  -- Gateway 검증
  gateway_passed boolean not null default false,
  gateway_check_ms int,
  sandbox_validated boolean not null default false,
  token_verified boolean not null default false,

  -- 요청자
  caller_type text not null,
  caller_id text,
  caller_ip_hash text,

  -- 결과
  response_status text not null,
  error_code int,
  duration_ms int,

  -- 보안 플래그
  is_suspicious boolean not null default false,
  threat_id uuid
    references catchmenu_common
      .security_threats(id),

  logged_at timestamptz not null default now(),

  constraint chk_caller_type check (
    caller_type in (
      'STAFF_APP',
      'CUSTOMER_APP',
      'KIOSK',
      'DID',
      'EDGE_FUNCTION',
      'PG_CRON',
      'ADMIN_WEB',
      'EXTERNAL_WEBHOOK',
      'UNKNOWN'
    )
  ),
  constraint chk_response_status check (
    response_status in (
      'SUCCESS', 'ERROR',
      'BLOCKED', 'RATE_LIMITED',
      'SANDBOX_VIOLATION'
    )
  )
);

create index if not exists idx_gateway_audit
  on catchmenu_common.gateway_audit_log(
    tenant_id, logged_at desc
  );
create index if not exists idx_gateway_suspicious
  on catchmenu_common.gateway_audit_log(
    is_suspicious, logged_at desc
  ) where is_suspicious = true;

alter table catchmenu_common.gateway_audit_log
  enable row level security;
alter table catchmenu_common.gateway_audit_log
  force row level security;

drop policy if exists gateway_log_isolation
  on catchmenu_common.gateway_audit_log;
create policy gateway_log_isolation
  on catchmenu_common.gateway_audit_log
  for all to authenticated
  using (
    tenant_id is null
    or tenant_id =
      catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_common.gateway_audit_log
  is
  'Gateway 단일 진입점 감사 로그.
   모든 RPC 호출은 Gateway를 통과해야 함.
   gateway_passed = false → 차단.
   sandbox_validated: 샌드박스 경계 확인.
   token_verified: 1회성 토큰 확인.
   EXTERNAL_WEBHOOK: 외부 웹훅 별도 추적.
   is_suspicious → 위협 탐지 연결.
   append-only. 삭제 불가.';


-- =============================================
-- sandbox_violations table
-- 샌드박스 위반 로그
-- =============================================
create table if not exists
  catchmenu_common.sandbox_violations (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid,
  store_id uuid,

  -- 위반 정보
  violation_type text not null,
  violation_source text not null,
  violation_target text,

  -- 샌드박스 경계
  expected_boundary text not null,
  actual_boundary text,
  boundary_gap text,

  -- 자동 차단
  auto_blocked boolean not null default true,
  blocked_at timestamptz default now(),

  -- 연결
  threat_id uuid
    references catchmenu_common
      .security_threats(id),
  gateway_log_id uuid
    references catchmenu_common
      .gateway_audit_log(id),

  detected_at timestamptz
    not null default now(),

  constraint chk_violation_type check (
    violation_type in (
      'CROSS_TENANT_ACCESS',    -- 타 테넌트 접근
      'CROSS_STORE_ACCESS',     -- 타 매장 접근
      'SCHEMA_CROSS_CALL',      -- 스키마 경계 침해
      'RLS_BYPASS',             -- RLS 우회
      'SERVICE_ROLE_ABUSE',     -- 서비스 롤 남용
      'DATA_BOUNDARY_EXCEED',   -- 데이터 경계 초과
      'EXTERNAL_INJECT'         -- 외부 주입
    )
  )
);

alter table catchmenu_common.sandbox_violations
  enable row level security;
alter table catchmenu_common.sandbox_violations
  force row level security;

drop policy if exists sandbox_violations_hq
  on catchmenu_common.sandbox_violations;
create policy sandbox_violations_hq
  on catchmenu_common.sandbox_violations
  for select to authenticated
  using (true);

comment on table
  catchmenu_common.sandbox_violations is
  '샌드박스 위반 로그.
   CROSS_TENANT_ACCESS: 가장 심각.
     다른 테넌트 데이터 접근 시도.
     → 즉시 FATAL 위협 + 자동 차단.
   RLS_BYPASS: service_role 남용.
   EXTERNAL_INJECT: 외부 오염 주입 시도.
   auto_blocked: 기본 true (위반 즉시 차단).
   append-only 감사 원장.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.issue_security_token(
  p_tenant_id uuid,
  p_token_type text,
  p_token_purpose text,
  p_subject_type text,
  p_subject_id text,
  p_store_id uuid default null,
  p_device_id uuid default null,
  p_scope jsonb default '{}'::jsonb,
  p_expires_minutes int default 15,
  p_max_uses int default 1
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_raw_token text;
  v_token_hash text;
  v_token_id uuid;
  v_expires_at timestamptz;
begin
  -- 원시 토큰 생성 (UUID + 타임스탬프)
  v_raw_token := encode(
    digest(
      gen_random_uuid()::text
      || now()::text
      || p_subject_id
      || p_token_type,
      'sha256'
    ),
    'hex'
  );

  -- DB에는 해시만 저장 (시크릿 코딩 원칙)
  v_token_hash := encode(
    digest(v_raw_token, 'sha256'),
    'hex'
  );

  v_expires_at := now()
    + (p_expires_minutes || ' minutes')
      ::interval;

  insert into catchmenu_common.security_tokens (
    tenant_id, store_id, device_id,
    token_hash, token_type, token_purpose,
    subject_type, subject_id,
    scope, expires_at, max_uses,
    token_status
  ) values (
    p_tenant_id, p_store_id, p_device_id,
    v_token_hash, p_token_type, p_token_purpose,
    p_subject_type, p_subject_id,
    p_scope, v_expires_at, p_max_uses,
    'ACTIVE'
  )
  returning id into v_token_id;

  -- 원시 토큰은 응답에만 포함
  -- DB에는 해시만 저장됨
  return jsonb_build_object(
    'success', true,
    'message', catchmenu_common.get_message(
      'security_token_issued', 'ko', null
    ),
    'data', jsonb_build_object(
      'token_id', v_token_id,
      'token', v_raw_token,
      'token_type', p_token_type,
      'expires_at', v_expires_at,
      'max_uses', p_max_uses,
      'security_note',
        'Token stored as SHA-256 hash only. Raw token returned once.'
    )
  );
end;
$$;


create or replace function
  catchmenu_common.verify_security_token(
  p_raw_token text,
  p_token_type text,
  p_subject_id text default null,
  p_consume boolean default false
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_token_hash text;
  v_token record;
  v_error_key text;
begin
  -- 입력 토큰 해시
  v_token_hash := encode(
    digest(p_raw_token, 'sha256'),
    'hex'
  );

  -- 토큰 조회
  select id, token_type, token_purpose,
         subject_id, token_status,
         expires_at, max_uses, use_count,
         tenant_id, store_id
  into v_token
  from catchmenu_common.security_tokens
  where token_hash = v_token_hash
    and token_type = p_token_type
  for update;

  -- 토큰 없음
  if v_token.id is null then
    perform catchmenu_common.detect_threat(
      p_threat_type := 'TOKEN_REPLAY',
      p_threat_stage := 2,
      p_threat_severity := 'HIGH',
      p_detection_source := 'verify_security_token',
      p_threat_payload := jsonb_build_object(
        'token_type', p_token_type,
        'reason', 'token_not_found'
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'security_token_invalid',
      p_locale := 'ko',
      p_rpc_name := 'verify_security_token'
    );
  end if;

  -- 만료 확인
  if v_token.expires_at < now() then
    update catchmenu_common.security_tokens
    set token_status = 'EXPIRED'
    where id = v_token.id;

    return catchmenu_common.build_error_response(
      p_error_key := 'security_token_expired',
      p_locale := 'ko',
      p_rpc_name := 'verify_security_token'
    );
  end if;

  -- 상태 확인
  if v_token.token_status <> 'ACTIVE' then
    -- 이미 사용된 토큰 재사용 시도 → 위협
    if v_token.token_status = 'USED' then
      perform catchmenu_common.detect_threat(
        p_threat_type := 'TOKEN_REPLAY',
        p_threat_stage := 2,
        p_threat_severity := 'CRITICAL',
        p_detection_source :=
          'verify_security_token',
        p_threat_payload := jsonb_build_object(
          'token_id', v_token.id,
          'token_type', p_token_type,
          'reason', 'token_replay_attack'
        )
      );
    end if;

    return catchmenu_common.build_error_response(
      p_error_key := 'security_token_already_used',
      p_locale := 'ko',
      p_rpc_name := 'verify_security_token'
    );
  end if;

  -- 사용 횟수 초과
  if v_token.use_count >= v_token.max_uses then
    update catchmenu_common.security_tokens
    set token_status = 'USED'
    where id = v_token.id;

    return catchmenu_common.build_error_response(
      p_error_key := 'security_token_already_used',
      p_locale := 'ko',
      p_rpc_name := 'verify_security_token'
    );
  end if;

  -- subject_id 일치 확인
  if p_subject_id is not null
    and v_token.subject_id <> p_subject_id
  then
    perform catchmenu_common.detect_threat(
      p_threat_type := 'SESSION_HIJACK',
      p_threat_stage := 2,
      p_threat_severity := 'CRITICAL',
      p_detection_source :=
        'verify_security_token',
      p_threat_payload := jsonb_build_object(
        'token_id', v_token.id,
        'expected_subject', p_subject_id,
        'actual_subject', v_token.subject_id
      )
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'security_token_invalid',
      p_locale := 'ko',
      p_rpc_name := 'verify_security_token'
    );
  end if;

  -- p_consume = true → 즉시 소비 (1회성)
  if p_consume then
    update catchmenu_common.security_tokens
    set
      token_status = case
        when use_count + 1 >= max_uses
          then 'USED'
        else 'ACTIVE'
      end,
      use_count = use_count + 1,
      used_at = now()
    where id = v_token.id;
  end if;

  return jsonb_build_object(
    'success', true,
    'message', catchmenu_common.get_message(
      'security_token_valid', 'ko', null
    ),
    'data', jsonb_build_object(
      'token_id', v_token.id,
      'token_type', v_token.token_type,
      'token_purpose', v_token.token_purpose,
      'subject_id', v_token.subject_id,
      'tenant_id', v_token.tenant_id,
      'store_id', v_token.store_id,
      'is_valid', true,
      'consumed', p_consume,
      'remaining_uses', case p_consume
        when true then
          greatest(0, v_token.max_uses
            - v_token.use_count - 1)
        else
          greatest(0, v_token.max_uses
            - v_token.use_count)
      end
    )
  );
end;
$$;


create or replace function
  catchmenu_common.detect_threat(
  p_threat_type text,
  p_threat_stage int,
  p_threat_severity text,
  p_detection_source text,
  p_threat_payload jsonb default null,
  p_tenant_id uuid default null,
  p_store_id uuid default null,
  p_device_id uuid default null,
  p_affected_resource text default null,
  p_affected_resource_id text default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_threat_id uuid;
  v_auto_block boolean;
  v_block_minutes int;
  v_block_scope text;
begin
  -- 심각도별 자동 차단 정책
  v_auto_block := p_threat_severity in (
    'CRITICAL', 'FATAL'
  );

  v_block_minutes := case p_threat_severity
    when 'FATAL' then 1440     -- 24시간
    when 'CRITICAL' then 60    -- 1시간
    when 'HIGH' then 15        -- 15분
    else 0
  end;

  v_block_scope := case p_threat_severity
    when 'FATAL' then 'TENANT'
    when 'CRITICAL' then 'DEVICE'
    when 'HIGH' then 'SESSION'
    else 'NONE'
  end;

  -- 위협 기록
  insert into catchmenu_common.security_threats (
    tenant_id, store_id, device_id,
    threat_stage, threat_type, threat_severity,
    detection_source, threat_payload,
    affected_resource, affected_resource_id,
    auto_blocked, block_applied_at,
    block_duration_minutes, block_scope,
    threat_status,
    is_escalated, escalation_level
  ) values (
    p_tenant_id, p_store_id, p_device_id,
    p_threat_stage, p_threat_type,
    p_threat_severity,
    p_detection_source, p_threat_payload,
    p_affected_resource, p_affected_resource_id,
    v_auto_block,
    case v_auto_block when true then now()
    else null end,
    case v_auto_block
      when true then v_block_minutes
      else null
    end,
    v_block_scope,
    case v_auto_block
      when true then 'BLOCKED'
      else 'OPEN'
    end,
    p_threat_severity = 'FATAL',
    case p_threat_severity
      when 'FATAL' then 3
      when 'CRITICAL' then 2
      when 'HIGH' then 1
      else 0
    end
  )
  returning id into v_threat_id;

  -- CRITICAL/FATAL → 운영 알림
  if p_threat_severity in ('CRITICAL', 'FATAL')
  then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'SECURITY_THREAT',
      p_alert_severity := p_threat_severity,
      p_alert_domain := 'SECURITY',
      p_alert_title_key := 'threat_detected',
      p_alert_detail := jsonb_build_object(
        'threat_id', v_threat_id,
        'threat_type', p_threat_type,
        'threat_stage', p_threat_stage,
        'auto_blocked', v_auto_block,
        'block_minutes', v_block_minutes,
        'detection_source', p_detection_source,
        'payload', p_threat_payload
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := case
        p_threat_stage
        when 4 then 'SOP-SEC-004'
        when 3 then 'SOP-SEC-003'
        else 'SOP-SEC-002'
      end
    );
  end if;

  -- FATAL → 테넌트 즉시 격리
  if p_threat_severity = 'FATAL'
    and p_tenant_id is not null
  then
    perform catchmenu_common.isolate_tenant(
      p_tenant_id := p_tenant_id,
      p_isolate := true,
      p_reason :=
        'SECURITY_THREAT_AUTO_BLOCK: '
        || p_threat_type
    );
  end if;

  -- 샌드박스 위반인 경우 별도 기록
  if p_threat_type in (
    'RLS_BYPASS_ATTEMPT',
    'TENANT_BOUNDARY_VIOLATION',
    'SANDBOX_ESCAPE',
    'GATEWAY_BYPASS',
    'EXTERNAL_CONTAMINATION_DETECTED'
  ) then
    insert into
      catchmenu_common.sandbox_violations (
      tenant_id, store_id,
      violation_type, violation_source,
      expected_boundary,
      auto_blocked, blocked_at,
      threat_id
    ) values (
      p_tenant_id, p_store_id,
      case p_threat_type
        when 'TENANT_BOUNDARY_VIOLATION'
          then 'CROSS_TENANT_ACCESS'
        when 'RLS_BYPASS_ATTEMPT'
          then 'RLS_BYPASS'
        when 'GATEWAY_BYPASS'
          then 'SERVICE_ROLE_ABUSE'
        when 'EXTERNAL_CONTAMINATION_DETECTED'
          then 'EXTERNAL_INJECT'
        else 'SCHEMA_CROSS_CALL'
      end,
      p_detection_source,
      'tenant_id isolation',
      true, now(),
      v_threat_id
    );
  end if;

  return v_threat_id;
end;
$$;


create or replace function
  catchmenu_common.gateway_audit_entry(
  p_rpc_name text,
  p_rpc_schema text,
  p_caller_type text,
  p_response_status text,
  p_tenant_id uuid default null,
  p_store_id uuid default null,
  p_device_id uuid default null,
  p_caller_id text default null,
  p_gateway_passed boolean default true,
  p_sandbox_validated boolean default true,
  p_token_verified boolean default false,
  p_error_code int default null,
  p_duration_ms int default null,
  p_is_suspicious boolean default false,
  p_threat_id uuid default null
)
returns uuid
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_log_id uuid;
begin
  insert into catchmenu_common.gateway_audit_log (
    tenant_id, store_id, device_id,
    rpc_name, rpc_schema, caller_type,
    gateway_passed, sandbox_validated,
    token_verified, caller_id,
    response_status, error_code,
    duration_ms, is_suspicious, threat_id
  ) values (
    p_tenant_id, p_store_id, p_device_id,
    p_rpc_name, p_rpc_schema, p_caller_type,
    p_gateway_passed, p_sandbox_validated,
    p_token_verified, p_caller_id,
    p_response_status, p_error_code,
    p_duration_ms, p_is_suspicious, p_threat_id
  )
  returning id into v_log_id;

  -- 게이트웨이 우회 탐지
  if not p_gateway_passed then
    perform catchmenu_common.detect_threat(
      p_threat_type := 'GATEWAY_BYPASS',
      p_threat_stage := 3,
      p_threat_severity := 'FATAL',
      p_detection_source := 'gateway_audit',
      p_threat_payload := jsonb_build_object(
        'rpc_name', p_rpc_name,
        'caller_type', p_caller_type,
        'caller_id', p_caller_id
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_device_id := p_device_id
    );
  end if;

  -- 샌드박스 위반 탐지
  if not p_sandbox_validated then
    perform catchmenu_common.detect_threat(
      p_threat_type := 'SANDBOX_ESCAPE',
      p_threat_stage := 3,
      p_threat_severity := 'CRITICAL',
      p_detection_source := 'gateway_audit',
      p_threat_payload := jsonb_build_object(
        'rpc_name', p_rpc_name,
        'caller_type', p_caller_type
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );
  end if;

  return v_log_id;
end;
$$;


create or replace function
  catchmenu_common.run_security_scan(
  p_tenant_id uuid default null,
  p_scan_depth text default 'STANDARD'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_findings jsonb := '[]'::jsonb;
  v_threat_count int;
  v_critical_count int;
  v_token_anomaly int;
  v_sandbox_violation_count int;
  v_gateway_bypass_count int;
  v_scan_id uuid := gen_random_uuid();
  v_overall text := 'CLEAN';
begin
  -- 1단계: 만료 토큰 정리
  update catchmenu_common.security_tokens
  set token_status = 'EXPIRED'
  where token_status = 'ACTIVE'
    and expires_at < now()
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  -- 2단계: 열린 위협 확인
  select
    count(*),
    count(*) filter (
      where threat_severity in (
        'CRITICAL', 'FATAL'
      )
    )
  into v_threat_count, v_critical_count
  from catchmenu_common.security_threats
  where threat_status = 'OPEN'
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  if v_threat_count > 0 then
    v_findings := v_findings || jsonb_build_object(
      'finding', 'OPEN_THREATS',
      'count', v_threat_count,
      'critical', v_critical_count,
      'severity', case
        when v_critical_count > 0
          then 'CRITICAL'
        else 'WARNING'
      end
    );
    if v_critical_count > 0 then
      v_overall := 'CRITICAL';
    elsif v_overall = 'CLEAN' then
      v_overall := 'WARNING';
    end if;
  end if;

  -- 3단계: 토큰 이상 확인
  -- (단시간에 많은 토큰 사용 실패)
  select count(*) into v_token_anomaly
  from catchmenu_common.security_threats
  where threat_type in (
    'TOKEN_REPLAY', 'SESSION_HIJACK'
  )
  and detected_at > now() - interval '1 hour'
  and (
    p_tenant_id is null
    or tenant_id = p_tenant_id
  );

  if v_token_anomaly > 5 then
    v_findings := v_findings || jsonb_build_object(
      'finding', 'TOKEN_ANOMALY',
      'count', v_token_anomaly,
      'window', '1h',
      'severity', 'HIGH'
    );
    if v_overall = 'CLEAN' then
      v_overall := 'WARNING';
    end if;
  end if;

  -- 4단계: 샌드박스 위반 확인
  select count(*) into v_sandbox_violation_count
  from catchmenu_common.sandbox_violations
  where detected_at > now() - interval '24 hours'
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  if v_sandbox_violation_count > 0 then
    v_findings := v_findings || jsonb_build_object(
      'finding', 'SANDBOX_VIOLATIONS',
      'count', v_sandbox_violation_count,
      'window', '24h',
      'severity', 'CRITICAL'
    );
    v_overall := 'CRITICAL';
  end if;

  -- 5단계: 게이트웨이 우회 시도 확인
  select count(*) into v_gateway_bypass_count
  from catchmenu_common.gateway_audit_log
  where gateway_passed = false
    and logged_at > now() - interval '24 hours'
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  if v_gateway_bypass_count > 0 then
    v_findings := v_findings || jsonb_build_object(
      'finding', 'GATEWAY_BYPASS_ATTEMPTS',
      'count', v_gateway_bypass_count,
      'window', '24h',
      'severity', 'FATAL'
    );
    v_overall := 'CRITICAL';
  end if;

  -- 결과 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := null,
    p_log_level := case v_overall
      when 'CRITICAL' then 'ERROR'
      when 'WARNING' then 'WARN'
      else 'INFO'
    end,
    p_log_domain := 'SECURITY',
    p_log_event := 'security_scan_completed',
    p_message :=
      '보안 스캔 완료: ' || v_overall,
    p_rpc_name := 'run_security_scan',
    p_details := jsonb_build_object(
      'scan_id', v_scan_id,
      'overall', v_overall,
      'findings', v_findings
    )
  );

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'scan_id', v_scan_id,
      'overall', v_overall,
      'tenant_id', p_tenant_id,
      'findings', v_findings,
      'finding_count',
        jsonb_array_length(v_findings),
      'summary', jsonb_build_object(
        'open_threats', v_threat_count,
        'critical_threats', v_critical_count,
        'token_anomalies_1h', v_token_anomaly,
        'sandbox_violations_24h',
          v_sandbox_violation_count,
        'gateway_bypasses_24h',
          v_gateway_bypass_count
      ),
      'scanned_at', now()
    )
  );
end;
$$;


create or replace function
  catchmenu_common.get_security_dashboard(
  p_tenant_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common
as $$
declare
  v_threat_summary jsonb;
  v_token_summary jsonb;
  v_gateway_summary jsonb;
  v_sandbox_summary jsonb;
  v_recent_threats jsonb;
  v_auto_blocks jsonb;
begin
  -- 위협 요약
  select jsonb_build_object(
    'total_open', count(*) filter (
      where threat_status = 'OPEN'
    ),
    'fatal', count(*) filter (
      where threat_severity = 'FATAL'
        and threat_status = 'OPEN'
    ),
    'critical', count(*) filter (
      where threat_severity = 'CRITICAL'
        and threat_status = 'OPEN'
    ),
    'high', count(*) filter (
      where threat_severity = 'HIGH'
        and threat_status = 'OPEN'
    ),
    'auto_blocked', count(*) filter (
      where auto_blocked = true
    ),
    'by_type', (
      select coalesce(
        jsonb_object_agg(
          threat_type, cnt
        ),
        '{}'::jsonb
      )
      from (
        select threat_type,
               count(*)::int as cnt
        from catchmenu_common.security_threats
        where threat_status = 'OPEN'
          and (
            p_tenant_id is null
            or tenant_id = p_tenant_id
          )
        group by threat_type
      ) t
    )
  )
  into v_threat_summary
  from catchmenu_common.security_threats
  where (
    p_tenant_id is null
    or tenant_id = p_tenant_id
  );

  -- 토큰 요약
  select jsonb_build_object(
    'active_tokens', count(*) filter (
      where token_status = 'ACTIVE'
    ),
    'used_today', count(*) filter (
      where token_status = 'USED'
        and used_at::date =
          (timezone('Asia/Seoul', now()))::date
    ),
    'expired', count(*) filter (
      where token_status = 'EXPIRED'
    ),
    'revoked', count(*) filter (
      where token_status = 'REVOKED'
    ),
    'blocked', count(*) filter (
      where token_status = 'BLOCKED'
    )
  )
  into v_token_summary
  from catchmenu_common.security_tokens
  where (
    p_tenant_id is null
    or tenant_id = p_tenant_id
  );

  -- Gateway 요약 (24시간)
  select jsonb_build_object(
    'total_requests', count(*),
    'blocked', count(*) filter (
      where response_status = 'BLOCKED'
    ),
    'sandbox_violations', count(*) filter (
      where response_status = 'SANDBOX_VIOLATION'
    ),
    'suspicious', count(*) filter (
      where is_suspicious = true
    ),
    'gateway_bypass_attempts', count(*) filter (
      where gateway_passed = false
    )
  )
  into v_gateway_summary
  from catchmenu_common.gateway_audit_log
  where logged_at > now() - interval '24 hours'
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  -- 샌드박스 위반 요약 (24시간)
  select jsonb_build_object(
    'total_violations', count(*),
    'cross_tenant', count(*) filter (
      where violation_type = 'CROSS_TENANT_ACCESS'
    ),
    'rls_bypass', count(*) filter (
      where violation_type = 'RLS_BYPASS'
    ),
    'external_inject', count(*) filter (
      where violation_type = 'EXTERNAL_INJECT'
    )
  )
  into v_sandbox_summary
  from catchmenu_common.sandbox_violations
  where detected_at > now() - interval '24 hours'
    and (
      p_tenant_id is null
      or tenant_id = p_tenant_id
    );

  -- 최근 위협 10건
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'threat_id', id,
        'threat_type', threat_type,
        'threat_stage', threat_stage,
        'threat_severity', threat_severity,
        'auto_blocked', auto_blocked,
        'threat_status', threat_status,
        'detected_at', detected_at
      )
      order by detected_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_threats
  from catchmenu_common.security_threats
  where (
    p_tenant_id is null
    or tenant_id = p_tenant_id
  )
  limit 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'security_dashboard_loaded',
    p_data := jsonb_build_object(
      'overall_status', case
        when (
          v_threat_summary->>'fatal'
        )::int > 0 then 'CRITICAL'
        when (
          v_threat_summary->>'critical'
        )::int > 0 then 'HIGH'
        when (
          v_threat_summary->>'high'
        )::int > 0 then 'MEDIUM'
        else 'CLEAN'
      end,
      'threat_summary', v_threat_summary,
      'token_summary', v_token_summary,
      'gateway_summary', v_gateway_summary,
      'sandbox_summary', v_sandbox_summary,
      'recent_threats', v_recent_threats,
      'security_principles', jsonb_build_object(
        '1_sandbox',
          'All tenant data isolated by RLS',
        '2_gateway',
          'Single entry point enforced',
        '3_token',
          'One-time tokens, hash-only storage',
        '4_threat',
          '4-stage detection + auto-block',
        '5_secret',
          'No secrets in DB, Edge Fn only'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- SOP 런북 (보안)
-- =============================================
insert into catchmenu_common.sop_runbooks (
  runbook_code, runbook_name,
  runbook_domain, symptom_description,
  recovery_steps, escalation_contact,
  escalation_threshold_minutes,
  is_active
) values
(
  'SOP-SEC-001',
  '인증 공격 대응 (브루트포스/토큰 재사용)',
  'SECURITY',
  'BRUTE_FORCE / TOKEN_REPLAY / SESSION_HIJACK',
  jsonb_build_array(
    '1. detect_threat() 자동 기록 확인',
    '2. 해당 device_id 세션 강제 만료',
    '3. security_tokens 전체 REVOKED 처리',
    '4. 영향 받은 계정 PIN 초기화 알림',
    '5. 30분간 해당 디바이스 재로그인 차단',
    '6. 고객사에 보안 알림 발송',
    '7. gateway_audit_log 패턴 분석'
  ),
  '15분 내 미해결 → HQ 에스컬레이션 / 30분 내 미해결 → 테넌트 일시 정지 검토',
  15, true
),
(
  'SOP-SEC-002',
  '권한 침해 자동 차단 대응',
  'SECURITY',
  'RLS_BYPASS / TENANT_BOUNDARY_VIOLATION
   / SANDBOX_ESCAPE',
  jsonb_build_array(
    '1. sandbox_violations 기록 즉시 확인',
    '2. 자동 차단 적용 확인 (auto_blocked=true)',
    '3. 영향 테넌트 격리 확인',
    '4. 위반 경로 분석 (gateway_audit_log)',
    '5. RLS 정책 무결성 재검증',
    '6. 법적 보존 증빙 패킷 생성',
    '7. 테넌트에 보안 사고 통보'
  ),
  '즉시 자동 차단 적용 / 5분 내 → HQ 긴급 대응 / 법적 조치 필요 시 → 증빙 패킷 내보내기',
  5, true
),
(
  'SOP-SEC-003',
  'Gateway 우회 / 샌드박스 탈출 대응',
  'SECURITY',
  'GATEWAY_BYPASS / SANDBOX_ESCAPE',
  jsonb_build_array(
    '1. FATAL 위협 자동 테넌트 격리 확인',
    '2. 우회 경로 즉시 차단',
    '3. 모든 활성 세션 강제 만료',
    '4. gateway_audit_log 전체 분석',
    '5. 취약점 패치 계획 수립',
    '6. 보안 스캔 재실행: run_security_scan()',
    '7. 외부 보안 감사 요청 검토'
  ),
  '즉시 FATAL → 자동 테넌트 격리 / 즉시 → HQ 보안팀 연락 / 외부 침해 확인 시 → 법적 대응 절차',
  0, true
),
(
  'SOP-SEC-004',
  '데이터 무결성 / 외부 오염 대응',
  'SECURITY',
  'EXTERNAL_CONTAMINATION / SECRET_PROBE
   / DATA_EXFILTRATION / INTEGRITY_VIOLATION',
  jsonb_build_array(
    '1. 오염 경로 즉시 격리',
    '2. 영향 데이터 범위 파악',
    '3. audit_evidence_packets 즉시 생성',
    '4. 시크릿 토큰 전체 REVOKED',
    '5. Edge Function 시크릿 즉시 교체',
    '6. DB 무결성 검증 실행',
    '7. 개인정보 침해 여부 확인 → 72시간 내 신고'
  ),
  '즉시 자동 격리 / 개인정보 침해 → GDPR/개인정보보호법 72시간 신고 / 외부 감사 필수',
  0, true
)
on conflict (runbook_code) do nothing;


-- =============================================
-- pg_cron: 보안 자동 스캔
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'SECURITY_SCAN',
  'catchmenu_security_scan',
  '0 */4 * * *',
  '0 */4 * * * (4시간마다)',
  $sql$
SELECT catchmenu_common.run_security_scan();
$sql$,
  '전체 보안 스캔. 4시간마다.
   만료 토큰 정리.
   위협 패턴 분석.
   CRITICAL 발견 시 자동 알림.',
  true
),
(
  'TOKEN_CLEANUP',
  'catchmenu_token_cleanup',
  '0 */1 * * *',
  '0 */1 * * * (1시간마다)',
  $sql$
UPDATE catchmenu_common.security_tokens
SET token_status = 'EXPIRED'
WHERE token_status = 'ACTIVE'
  AND expires_at < now();
$sql$,
  '만료 토큰 정리. 1시간마다.',
  true
),
(
  'WEEKLY_SECURITY_AUDIT',
  'catchmenu_weekly_security_audit',
  '0 4 * * 1',
  '0 13 * * 1 (매주 월요일 13:00 KST)',
  $sql$
-- 주간 보안 감사
SELECT catchmenu_common.run_security_scan(
  null, 'DEEP'
);

-- 오래된 위협 아카이브
UPDATE catchmenu_common.security_threats
SET threat_status = 'RESOLVED'
WHERE threat_status = 'OPEN'
  AND threat_severity IN ('LOW', 'MEDIUM')
  AND detected_at < now() - interval '7 days'
  AND auto_blocked = true;
$sql$,
  '주간 심층 보안 감사.
   매주 월요일 13:00 KST.
   낮은 심각도 위협 자동 아카이브.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_common.issue_security_token(
      uuid, text, text, text, text,
      uuid, uuid, jsonb, int, int
    ) to authenticated;

  grant execute on function
    catchmenu_common.verify_security_token(
      text, text, text, boolean
    ) to authenticated;

  grant execute on function
    catchmenu_common.detect_threat(
      text, int, text, text, jsonb,
      uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_common.gateway_audit_entry(
      text, text, text, text, uuid, uuid,
      uuid, text, boolean, boolean, boolean,
      int, int, boolean, uuid
    ) to authenticated;

  grant execute on function
    catchmenu_common.run_security_scan(
      uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_common.get_security_dashboard(
      uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.detect_threat(
    text, int, text, text, jsonb,
    uuid, uuid, uuid, text, text
  ) is
  '보안 위협 탐지 + 자동 대응.
   4단계 탐지 체계:
   Stage1: 입력 검증 위협
   Stage2: 인증 공격
   Stage3: 권한/샌드박스 침해
   Stage4: 데이터 무결성 위협

   자동 차단 정책:
   FATAL: 즉시 테넌트 격리 + 24시간 차단
   CRITICAL: 60분 디바이스 차단
   HIGH: 15분 세션 차단

   자동 에스컬레이션:
   CRITICAL/FATAL → 운영 알림 자동 발송
   FATAL → isolate_tenant() 즉시 실행
   Stage3+ → 샌드박스 위반 로그 생성

   SOP 연동:
   Stage4 → SOP-SEC-004
   Stage3 → SOP-SEC-003
   Stage2 → SOP-SEC-002';

comment on function
  catchmenu_common.issue_security_token(
    uuid, text, text, text, text,
    uuid, uuid, jsonb, int, int
  ) is
  '1회성 보안 토큰 발급.
   시크릿 코딩 원칙:
   - 원시 토큰: 응답에만 포함 (1회)
   - DB 저장: SHA-256 해시만
   - Edge Function에서 검증
   - 원시 토큰 재발급 불가

   PAYMENT_INTENT 흐름:
   1. initiate_toss_payment() 호출
   2. issue_security_token(PAYMENT_INTENT)
   3. Flutter → 토큰 보관
   4. confirm_payment() 시 토큰 제출
   5. verify_security_token(consume=true)
   6. 중복 결제 100% 방지

   KDS_RELEASE 흐름:
   1. confirm_payment() 성공
   2. issue_security_token(KDS_RELEASE)
   3. release_kds_after_payment()
   4. 특허2 Late Binding 보안 강화';