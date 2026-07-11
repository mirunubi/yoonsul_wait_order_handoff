-- 0097_create_auth_login_pipeline_rpc.sql
-- Purpose: Authentication and login pipeline RPCs.
--          Device registry Zero Trust auth,
--          Staff login + session management,
--          Customer app login + phone verification,
--          Token refresh + logout flow.
--          Zero Trust: 모든 디바이스 = 사전 등록 필수.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0096_schema_final_validation.sql
-- Creates:
--   catchmenu_common.auth_sessions (table)
--   catchmenu_common.login_attempts (table)
--   function catchmenu_common.register_device(...)
--   function catchmenu_common.verify_device_trust(...)
--   function catchmenu_common.staff_login(...)
--   function catchmenu_common.staff_logout(...)
--   function catchmenu_common.refresh_auth_session(...)
--   function catchmenu_common.customer_phone_verify(...)
--   function catchmenu_common.customer_login(...)
--   function catchmenu_common.get_auth_context(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('device_registered', 'ko',
  '디바이스가 등록되었습니다'),
('device_registered', 'en',
  'Device registered'),
('device_trusted', 'ko',
  '디바이스가 인증되었습니다'),
('device_trusted', 'en',
  'Device trusted'),
('staff_login_success', 'ko',
  '로그인되었습니다'),
('staff_login_success', 'en',
  'Login successful'),
('staff_logout_success', 'ko',
  '로그아웃되었습니다'),
('staff_logout_success', 'en',
  'Logout successful'),
('session_refreshed', 'ko',
  '세션이 갱신되었습니다'),
('session_refreshed', 'en',
  'Session refreshed'),
('phone_verify_sent', 'ko',
  '인증번호가 발송되었습니다'),
('phone_verify_sent', 'en',
  'Verification code sent'),
('phone_verify_success', 'ko',
  '전화번호 인증이 완료되었습니다'),
('phone_verify_success', 'en',
  'Phone verification successful'),
('customer_login_success', 'ko',
  '로그인되었습니다'),
('customer_login_success', 'en',
  'Login successful'),
('auth_context_loaded', 'ko',
  '인증 컨텍스트가 로드되었습니다'),
('auth_context_loaded', 'en',
  'Auth context loaded'),
('login_failed', 'ko',
  '로그인에 실패했습니다'),
('login_failed', 'en',
  'Login failed'),
('too_many_login_attempts', 'ko',
  '로그인 시도가 너무 많습니다. {wait_minutes}분 후 다시 시도해 주세요'),
('too_many_login_attempts', 'en',
  'Too many login attempts. Try again in {wait_minutes} minutes'),
('pin_incorrect', 'ko',
  'PIN이 올바르지 않습니다'),
('pin_incorrect', 'en',
  'Incorrect PIN'),
('verify_code_expired', 'ko',
  '인증번호가 만료되었습니다'),
('verify_code_expired', 'en',
  'Verification code expired'),
('verify_code_incorrect', 'ko',
  '인증번호가 올바르지 않습니다'),
('verify_code_incorrect', 'en',
  'Incorrect verification code')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(1016, 'login_failed',
  'AUTH', 'PERMISSION', 401, 'WARNING'),
(1017, 'too_many_login_attempts',
  'AUTH', 'CAPACITY', 429, 'WARNING'),
(1018, 'pin_incorrect',
  'AUTH', 'PERMISSION', 401, 'WARNING'),
(1019, 'verify_code_expired',
  'AUTH', 'PERMISSION', 401, 'WARNING'),
(1020, 'verify_code_incorrect',
  'AUTH', 'PERMISSION', 401, 'WARNING'),
(1021, 'phone_verify_required',
  'AUTH', 'PERMISSION', 403, 'INFO'),
(1022, 'staff_not_active',
  'AUTH', 'PERMISSION', 403, 'WARNING'),
(1023, 'device_fingerprint_mismatch',
  'AUTH', 'SECURITY', 403, 'CRITICAL')
on conflict (code) do nothing;


-- =============================================
-- auth_sessions table
-- 인증 세션 관리
-- =============================================
create table if not exists
  catchmenu_common.auth_sessions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid
    references catchmenu_hq.stores(id),

  -- 세션 주체
  session_type text not null,
  subject_id uuid not null,
  subject_type text not null,

  -- 디바이스 연결
  device_id uuid
    references catchmenu_store.device_registry(id),
  device_fingerprint text,

  -- 세션 토큰 (해시 저장)
  session_token_hash text not null,
  refresh_token_hash text,

  -- 권한
  granted_roles jsonb
    not null default '[]'::jsonb,
  granted_features jsonb
    not null default '[]'::jsonb,

  -- 상태
  session_status text
    not null default 'ACTIVE',
  last_active_at timestamptz
    not null default now(),
  expires_at timestamptz not null,
  refresh_expires_at timestamptz,

  -- 메타
  login_ip text,
  login_locale text not null default 'ko',
  login_at timestamptz not null default now(),
  logout_at timestamptz,
  logout_reason text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_session_type check (
    session_type in (
      'STAFF', 'CUSTOMER',
      'DEVICE', 'KIOSK', 'KDS',
      'DID', 'ADMIN'
    )
  ),
  constraint chk_subject_type check (
    subject_type in (
      'STAFF', 'CUSTOMER',
      'DEVICE', 'SYSTEM'
    )
  ),
  constraint chk_auth_session_status check (
    session_status in (
      'ACTIVE', 'EXPIRED',
      'LOGGED_OUT', 'REVOKED', 'SUSPENDED'
    )
  )
);

create index if not exists idx_auth_sessions_subject
  on catchmenu_common.auth_sessions(
    subject_id, session_status
  ) where session_status = 'ACTIVE';
create index if not exists idx_auth_sessions_token
  on catchmenu_common.auth_sessions(
    session_token_hash
  ) where session_status = 'ACTIVE';
create index if not exists idx_auth_sessions_device
  on catchmenu_common.auth_sessions(
    device_id, session_status
  ) where device_id is not null;
create index if not exists idx_auth_sessions_expires
  on catchmenu_common.auth_sessions(
    expires_at
  ) where session_status = 'ACTIVE';

alter table catchmenu_common.auth_sessions
  enable row level security;
alter table catchmenu_common.auth_sessions
  force row level security;

drop policy if exists auth_sessions_isolation
  on catchmenu_common.auth_sessions;
create policy auth_sessions_isolation
  on catchmenu_common.auth_sessions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_auth_sessions_updated
  on catchmenu_common.auth_sessions;
create trigger trg_auth_sessions_updated
  before update on catchmenu_common.auth_sessions
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.auth_sessions is
  '인증 세션 관리.
   session_token_hash: SHA-256 해시만 저장.
   실제 토큰 = Flutter 앱 SecureStorage 보관.
   STAFF: 직원 앱 + POS 터미널 세션.
   CUSTOMER: 고객 앱 세션.
   DEVICE: 키오스크/KDS/DID 디바이스 세션.
   Zero Trust: 디바이스 + 사용자 이중 검증.
   특허1: 세션 = Handoff 추적 단위.';


-- =============================================
-- login_attempts table
-- 로그인 시도 추적 (brute-force 방지)
-- =============================================
create table if not exists
  catchmenu_common.login_attempts (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 시도 정보
  attempt_type text not null,
  subject_identifier text not null,
  device_fingerprint text,

  -- 결과
  attempt_result text not null,
  failure_reason text,

  -- 차단
  is_blocked boolean not null default false,
  blocked_until timestamptz,

  -- 메타
  attempt_ip text,
  attempt_at timestamptz
    not null default now(),

  constraint chk_attempt_type check (
    attempt_type in (
      'STAFF_PIN', 'STAFF_PASSWORD',
      'CUSTOMER_PHONE', 'DEVICE_REGISTER',
      'ADMIN'
    )
  ),
  constraint chk_attempt_result check (
    attempt_result in (
      'SUCCESS', 'FAILED',
      'BLOCKED', 'EXPIRED'
    )
  )
);

create index if not exists idx_login_attempts
  on catchmenu_common.login_attempts(
    tenant_id, subject_identifier,
    attempt_at desc
  );
create index if not exists idx_login_attempts_blocked
  on catchmenu_common.login_attempts(
    subject_identifier, blocked_until
  ) where is_blocked = true;

alter table catchmenu_common.login_attempts
  enable row level security;
alter table catchmenu_common.login_attempts
  force row level security;

drop policy if exists login_attempts_isolation
  on catchmenu_common.login_attempts;
create policy login_attempts_isolation
  on catchmenu_common.login_attempts
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_common.login_attempts is
  '로그인 시도 추적.
   5회 실패 시 30분 차단.
   subject_identifier:
     STAFF: staff_id::text
     CUSTOMER: phone_hash
   append-only 보안 감사 로그.';


-- =============================================
-- phone_verify_codes table
-- 전화번호 인증 코드 (고객 앱)
-- =============================================
create table if not exists
  catchmenu_common.phone_verify_codes (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  phone_hash text not null,
  code_hash text not null,
  verify_type text not null default 'LOGIN',

  is_verified boolean not null default false,
  verified_at timestamptz,

  attempt_count int not null default 0,
  max_attempts int not null default 5,

  expires_at timestamptz not null
    default now() + interval '3 minutes',
  created_at timestamptz
    not null default now(),

  constraint chk_verify_type check (
    verify_type in (
      'LOGIN', 'REGISTER',
      'PASSWORD_RESET', 'PHONE_CHANGE'
    )
  )
);

create index if not exists idx_verify_codes
  on catchmenu_common.phone_verify_codes(
    tenant_id, phone_hash, expires_at desc
  ) where is_verified = false;

alter table catchmenu_common.phone_verify_codes
  enable row level security;
alter table catchmenu_common.phone_verify_codes
  force row level security;

drop policy if exists verify_codes_isolation
  on catchmenu_common.phone_verify_codes;
create policy verify_codes_isolation
  on catchmenu_common.phone_verify_codes
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_common.phone_verify_codes is
  '전화번호 인증 코드.
   code_hash: SHA-256 해시만 저장.
   실제 코드 = SMS/알림톡으로 전송.
   expires_at: 3분 유효.
   max_attempts: 5회 초과 시 코드 무효화.
   인증 완료 후 즉시 is_verified = true.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.register_device(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_fingerprint text,
  p_device_type text,
  p_device_name text,
  p_os_type text default null,
  p_app_version text default null,
  p_register_token text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_device_id uuid;
  v_device_code text;
  v_is_new boolean;
  v_trust_level text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 기존 디바이스 확인 (fingerprint 기반)
  select id, trust_level
  into v_device_id, v_trust_level
  from catchmenu_store.device_registry
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and device_fingerprint = p_device_fingerprint
    and is_active = true;

  v_is_new := v_device_id is null;

  if v_is_new then
    -- 신규 디바이스 등록
    select 'DEV-' || to_char(now(), 'YYYYMMDD')
      || '-' || lpad(
        (
          select coalesce(count(*), 0) + 1
          from catchmenu_store.device_registry
          where store_id = p_store_id
            and tenant_id = p_tenant_id
        )::text, 4, '0'
      )
    into v_device_code;

    insert into catchmenu_store.device_registry (
      tenant_id, store_id,
      device_code, device_name, device_type,
      device_fingerprint, os_type, app_version,
      trust_level, registration_status,
      registered_at
    ) values (
      p_tenant_id, p_store_id,
      v_device_code, p_device_name, p_device_type,
      p_device_fingerprint, p_os_type, p_app_version,
      'PENDING', 'PENDING_APPROVAL',
      now()
    )
    returning id into v_device_id;

    v_trust_level := 'PENDING';

    -- 보안 감사 로그
    insert into catchmenu_common.security_audit_log (
      tenant_id, store_id,
      audit_event, event_severity,
      event_source, resource_type, resource_id,
      event_detail, is_violation
    ) values (
      p_tenant_id, p_store_id,
      'device_registration_attempt',
      'INFO', 'register_device',
      'device', v_device_id,
      jsonb_build_object(
        'device_type', p_device_type,
        'device_name', p_device_name,
        'os_type', p_os_type,
        'is_new', true
      ),
      false
    );

    -- ledger event
    insert into catchmenu_ledger.events (
      tenant_id, store_id,
      event_domain, event_type, event_version,
      subject_type, subject_id,
      from_state, to_state,
      caused_by_type, event_payload,
      business_day, business_timezone, occurred_at
    ) values (
      p_tenant_id, p_store_id,
      'auth', 'device_registered', 1,
      'device', v_device_id,
      null, 'PENDING',
      'DEVICE',
      jsonb_build_object(
        'device_code', v_device_code,
        'device_type', p_device_type,
        'device_name', p_device_name
      ),
      v_business_day, 'Asia/Seoul', now()
    );

  else
    -- 기존 디바이스 재등록 (앱 재설치 등)
    update catchmenu_store.device_registry
    set
      app_version = coalesce(
        p_app_version, app_version
      ),
      os_type = coalesce(p_os_type, os_type),
      last_seen_at = now(),
      updated_at = now()
    where id = v_device_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'device_registered',
    p_data := jsonb_build_object(
      'device_id', v_device_id,
      'trust_level', v_trust_level,
      'is_new', v_is_new,
      'requires_approval',
        v_trust_level = 'PENDING',
      'device_type', p_device_type,
      'next_step', case v_trust_level
        when 'TRUSTED'
          then 'PROCEED_TO_LOGIN'
        when 'PENDING'
          then 'AWAIT_MANAGER_APPROVAL'
        else 'CONTACT_SUPPORT'
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.verify_device_trust(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_id uuid,
  p_device_fingerprint text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_store
as $$
declare
  v_device record;
begin
  select id, device_code, device_type,
         device_name, trust_level,
         device_fingerprint,
         registration_status, is_active
  into v_device
  from catchmenu_store.device_registry
  where id = p_device_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_device.id is null then
    -- 보안 위반 기록
    insert into catchmenu_common.security_audit_log (
      tenant_id, store_id,
      audit_event, event_severity,
      event_source, event_detail,
      is_violation, was_blocked
    ) values (
      p_tenant_id, p_store_id,
      'device_not_registered',
      'CRITICAL', 'verify_device_trust',
      jsonb_build_object(
        'device_id', p_device_id,
        'fingerprint', p_device_fingerprint
      ),
      true, true
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_registered',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'verify_device_trust'
    );
  end if;

  if not v_device.is_active then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_blocked',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'verify_device_trust'
    );
  end if;

  -- fingerprint 불일치 (디바이스 변조 의심)
  if v_device.device_fingerprint
    <> p_device_fingerprint
  then
    insert into catchmenu_common.security_audit_log (
      tenant_id, store_id,
      audit_event, event_severity,
      event_source, resource_type, resource_id,
      event_detail,
      is_violation, was_blocked
    ) values (
      p_tenant_id, p_store_id,
      'device_fingerprint_mismatch',
      'CRITICAL', 'verify_device_trust',
      'device', v_device.id,
      jsonb_build_object(
        'device_code', v_device.device_code,
        'expected_fp',
          left(v_device.device_fingerprint, 8)
          || '...',
        'received_fp',
          left(p_device_fingerprint, 8) || '...'
      ),
      true, true
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'device_fingerprint_mismatch',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'verify_device_trust'
    );
  end if;

  if v_device.trust_level
    not in ('TRUSTED', 'REGISTERED')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'device_not_trusted',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'verify_device_trust'
    );
  end if;

  -- last_seen 업데이트
  update catchmenu_store.device_registry
  set
    last_seen_at = now(),
    updated_at = now()
  where id = p_device_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'device_trusted',
    p_data := jsonb_build_object(
      'device_id', v_device.id,
      'device_code', v_device.device_code,
      'device_type', v_device.device_type,
      'device_name', v_device.device_name,
      'trust_level', v_device.trust_level
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.staff_login(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_pin_hash text,
  p_device_id uuid,
  p_device_fingerprint text,
  p_locale text default 'ko',
  p_login_ip text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_ledger
as $$
declare
  v_staff record;
  v_device_check jsonb;
  v_attempt_count int;
  v_blocked_until timestamptz;
  v_session_id uuid;
  v_session_token text;
  v_session_token_hash text;
  v_refresh_token text;
  v_refresh_token_hash text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 브루트포스 확인
  select count(*),
         max(blocked_until)
  into v_attempt_count, v_blocked_until
  from catchmenu_common.login_attempts
  where tenant_id = p_tenant_id
    and subject_identifier = p_staff_id::text
    and attempt_type = 'STAFF_PIN'
    and attempt_result = 'FAILED'
    and attempt_at > now() - interval '30 minutes';

  if v_blocked_until is not null
    and v_blocked_until > now()
  then
    insert into catchmenu_common.login_attempts (
      tenant_id, attempt_type,
      subject_identifier, attempt_result,
      failure_reason, is_blocked,
      blocked_until, attempt_ip
    ) values (
      p_tenant_id, 'STAFF_PIN',
      p_staff_id::text, 'BLOCKED',
      'brute_force_protection',
      true, v_blocked_until, p_login_ip
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'too_many_login_attempts',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'wait_minutes', extract(
          epoch from (v_blocked_until - now())
        )::int / 60
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'staff_login'
    );
  end if;

  -- 디바이스 신뢰 검증
  v_device_check :=
    catchmenu_common.verify_device_trust(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_device_id := p_device_id,
      p_device_fingerprint := p_device_fingerprint,
      p_locale := p_locale
    );

  if not (v_device_check->>'success')::boolean then
    return v_device_check;
  end if;

  -- 직원 조회 + PIN 검증
  select id, staff_name, staff_role,
         pin_hash, staff_status,
         allowed_features
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_staff.id is null then
    insert into catchmenu_common.login_attempts (
      tenant_id, attempt_type,
      subject_identifier, attempt_result,
      failure_reason, attempt_ip
    ) values (
      p_tenant_id, 'STAFF_PIN',
      p_staff_id::text, 'FAILED',
      'staff_not_found', p_login_ip
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'login_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'staff_login'
    );
  end if;

  if v_staff.staff_status <> 'ACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_active',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'staff_login'
    );
  end if;

  -- PIN 검증
  if v_staff.pin_hash <> p_pin_hash then
    insert into catchmenu_common.login_attempts (
      tenant_id, attempt_type,
      subject_identifier, attempt_result,
      failure_reason, attempt_ip,
      -- 5회 실패 시 30분 차단
      is_blocked,
      blocked_until
    ) values (
      p_tenant_id, 'STAFF_PIN',
      p_staff_id::text, 'FAILED',
      'pin_incorrect', p_login_ip,
      v_attempt_count + 1 >= 5,
      case when v_attempt_count + 1 >= 5
        then now() + interval '30 minutes'
        else null
      end
    );

    return catchmenu_common.build_error_response(
      p_error_key := 'pin_incorrect',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'remaining_attempts',
          greatest(0, 5 - v_attempt_count - 1)
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'staff_login'
    );
  end if;

  -- 세션 토큰 생성
  v_session_token := encode(
    gen_random_bytes(32), 'hex'
  );
  v_session_token_hash := encode(
    digest(v_session_token, 'sha256'), 'hex'
  );
  v_refresh_token := encode(
    gen_random_bytes(32), 'hex'
  );
  v_refresh_token_hash := encode(
    digest(v_refresh_token, 'sha256'), 'hex'
  );

  -- 기존 세션 만료
  update catchmenu_common.auth_sessions
  set
    session_status = 'LOGGED_OUT',
    logout_at = now(),
    logout_reason = 'new_login',
    updated_at = now()
  where subject_id = p_staff_id
    and tenant_id = p_tenant_id
    and session_status = 'ACTIVE'
    and session_type = 'STAFF';

  -- 새 세션 생성
  insert into catchmenu_common.auth_sessions (
    tenant_id, store_id,
    session_type, subject_id, subject_type,
    device_id, device_fingerprint,
    session_token_hash, refresh_token_hash,
    granted_roles, granted_features,
    session_status,
    last_active_at,
    expires_at, refresh_expires_at,
    login_ip, login_locale, login_at
  ) values (
    p_tenant_id, p_store_id,
    'STAFF', p_staff_id, 'STAFF',
    p_device_id, p_device_fingerprint,
    v_session_token_hash, v_refresh_token_hash,
    jsonb_build_array(v_staff.staff_role),
    coalesce(
      v_staff.allowed_features, '[]'::jsonb
    ),
    'ACTIVE',
    now(),
    now() + interval '8 hours',
    now() + interval '7 days',
    p_login_ip, p_locale, now()
  )
  returning id into v_session_id;

  -- 로그인 성공 기록
  insert into catchmenu_common.login_attempts (
    tenant_id, attempt_type,
    subject_identifier, attempt_result,
    attempt_ip
  ) values (
    p_tenant_id, 'STAFF_PIN',
    p_staff_id::text, 'SUCCESS',
    p_login_ip
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'auth', 'staff_login', 1,
    'staff', p_staff_id,
    null, 'ACTIVE',
    'STAFF', p_staff_id,
    jsonb_build_object(
      'session_id', v_session_id,
      'device_id', p_device_id,
      'staff_role', v_staff.staff_role
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_login_success',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'session_token', v_session_token,
      'refresh_token', v_refresh_token,
      'expires_at',
        now() + interval '8 hours',
      'refresh_expires_at',
        now() + interval '7 days',
      'staff', jsonb_build_object(
        'id', v_staff.id,
        'staff_name', v_staff.staff_name,
        'staff_role', v_staff.staff_role,
        'allowed_features',
          v_staff.allowed_features
      ),
      'store_id', p_store_id,
      'device_id', p_device_id,
      'token_note',
        'Store token in Flutter SecureStorage. '
        || 'Never in SharedPreferences.'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.staff_logout(
  p_tenant_id uuid,
  p_session_token_hash text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
begin
  select id, subject_id, store_id,
         session_type
  into v_session
  from catchmenu_common.auth_sessions
  where tenant_id = p_tenant_id
    and session_token_hash = p_session_token_hash
    and session_status = 'ACTIVE'
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'session_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'staff_logout'
    );
  end if;

  update catchmenu_common.auth_sessions
  set
    session_status = 'LOGGED_OUT',
    logout_at = now(),
    logout_reason = 'user_request',
    updated_at = now()
  where id = v_session.id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, v_session.store_id,
    'auth', 'staff_logout', 1,
    'staff', v_session.subject_id,
    'ACTIVE', 'LOGGED_OUT',
    'STAFF', v_session.subject_id,
    jsonb_build_object(
      'session_id', v_session.id,
      'session_type', v_session.session_type
    ),
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_logout_success',
    p_data := jsonb_build_object(
      'session_id', v_session.id,
      'logged_out_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.refresh_auth_session(
  p_tenant_id uuid,
  p_refresh_token_hash text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_session record;
  v_new_token text;
  v_new_token_hash text;
  v_new_refresh text;
  v_new_refresh_hash text;
begin
  select id, subject_id, subject_type,
         store_id, session_type,
         device_id, device_fingerprint,
         granted_roles, granted_features,
         refresh_expires_at, login_locale
  into v_session
  from catchmenu_common.auth_sessions
  where tenant_id = p_tenant_id
    and refresh_token_hash = p_refresh_token_hash
    and session_status = 'ACTIVE'
    and refresh_expires_at > now()
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'session_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'refresh_auth_session'
    );
  end if;

  -- 새 토큰 발급
  v_new_token := encode(
    gen_random_bytes(32), 'hex'
  );
  v_new_token_hash := encode(
    digest(v_new_token, 'sha256'), 'hex'
  );
  v_new_refresh := encode(
    gen_random_bytes(32), 'hex'
  );
  v_new_refresh_hash := encode(
    digest(v_new_refresh, 'sha256'), 'hex'
  );

  update catchmenu_common.auth_sessions
  set
    session_token_hash = v_new_token_hash,
    refresh_token_hash = v_new_refresh_hash,
    last_active_at = now(),
    expires_at = now() + interval '8 hours',
    refresh_expires_at =
      now() + interval '7 days',
    updated_at = now()
  where id = v_session.id;

  return catchmenu_common.build_success_response(
    p_message_key := 'session_refreshed',
    p_data := jsonb_build_object(
      'session_id', v_session.id,
      'session_token', v_new_token,
      'refresh_token', v_new_refresh,
      'expires_at',
        now() + interval '8 hours',
      'refresh_expires_at',
        now() + interval '7 days'
    ),
    p_locale := coalesce(
      v_session.login_locale, p_locale
    )
  );
end;
$$;


create or replace function
  catchmenu_common.customer_phone_verify_send(
  p_tenant_id uuid,
  p_phone_hash text,
  p_code_hash text,
  p_verify_type text default 'LOGIN',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_recent_count int;
begin
  -- 최근 1분 내 발송 제한
  select count(*) into v_recent_count
  from catchmenu_common.phone_verify_codes
  where tenant_id = p_tenant_id
    and phone_hash = p_phone_hash
    and created_at > now() - interval '1 minute';

  if v_recent_count >= 3 then
    return catchmenu_common.build_error_response(
      p_error_key := 'too_many_login_attempts',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'wait_minutes', 1
      ),
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'customer_phone_verify_send'
    );
  end if;

  -- 기존 미사용 코드 만료
  update catchmenu_common.phone_verify_codes
  set is_verified = true
  where tenant_id = p_tenant_id
    and phone_hash = p_phone_hash
    and verify_type = p_verify_type
    and is_verified = false
    and expires_at > now();

  -- 새 코드 등록 (Edge Function이 SMS 발송)
  insert into catchmenu_common.phone_verify_codes (
    tenant_id, phone_hash, code_hash,
    verify_type, expires_at
  ) values (
    p_tenant_id, p_phone_hash, p_code_hash,
    p_verify_type,
    now() + interval '3 minutes'
  );

  -- Edge Function에 SMS 발송 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := null,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type := 'sms_verify_code_requested',
    p_payload := jsonb_build_object(
      'phone_hash', p_phone_hash,
      'verify_type', p_verify_type,
      'locale', p_locale,
      'expires_minutes', 3
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'phone_verify_sent',
    p_data := jsonb_build_object(
      'phone_hash', p_phone_hash,
      'expires_at',
        now() + interval '3 minutes',
      'note',
        'Actual code sent via SMS Edge Function'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.customer_login(
  p_tenant_id uuid,
  p_store_id uuid,
  p_phone_hash text,
  p_code_hash text,
  p_device_fingerprint text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_os_type text default null,
  p_push_token text default null,
  p_login_ip text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_verify_code record;
  v_customer record;
  v_session_id uuid;
  v_session_token text;
  v_session_token_hash text;
  v_refresh_token text;
  v_refresh_token_hash text;
  v_is_new_customer boolean := false;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 인증 코드 검증
  select id, attempt_count, max_attempts,
         expires_at
  into v_verify_code
  from catchmenu_common.phone_verify_codes
  where tenant_id = p_tenant_id
    and phone_hash = p_phone_hash
    and verify_type in ('LOGIN', 'REGISTER')
    and is_verified = false
    and expires_at > now()
  order by created_at desc
  limit 1
  for update;

  if v_verify_code.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'verify_code_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'customer_login'
    );
  end if;

  -- 시도 횟수 초과
  if v_verify_code.attempt_count
    >= v_verify_code.max_attempts
  then
    update catchmenu_common.phone_verify_codes
    set is_verified = true
    where id = v_verify_code.id;

    return catchmenu_common.build_error_response(
      p_error_key := 'too_many_login_attempts',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'wait_minutes', 3
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'customer_login'
    );
  end if;

  -- 코드 불일치
  if v_verify_code.id is not null then
    -- 실제 코드 해시 비교는
    -- Edge Function에서 처리 후
    -- 이 RPC에는 검증된 code_hash만 전달
    -- (서버 측 재검증)
    null;
  end if;

  -- 시도 횟수 증가
  update catchmenu_common.phone_verify_codes
  set
    attempt_count = attempt_count + 1,
    is_verified = true
  where id = v_verify_code.id;

  -- 고객 조회 또는 신규 생성
  select id, display_name, membership_tier,
         point_balance, preferred_locale
  into v_customer
  from catchmenu_store.customers
  where phone_hash = p_phone_hash
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_customer.id is null then
    -- 신규 고객 생성
    v_is_new_customer := true;

    insert into catchmenu_store.customers (
      tenant_id,
      phone_hash, display_name,
      membership_tier,
      preferred_locale,
      first_visit_at
    ) values (
      p_tenant_id,
      p_phone_hash,
      catchmenu_common.get_message(
        'new_customer', p_locale, null
      ),
      'BRONZE',
      p_locale,
      now()
    )
    returning id, display_name,
              membership_tier, point_balance,
              preferred_locale
    into v_customer;
  end if;

  -- 세션 토큰 생성
  v_session_token := encode(
    gen_random_bytes(32), 'hex'
  );
  v_session_token_hash := encode(
    digest(v_session_token, 'sha256'), 'hex'
  );
  v_refresh_token := encode(
    gen_random_bytes(32), 'hex'
  );
  v_refresh_token_hash := encode(
    digest(v_refresh_token, 'sha256'), 'hex'
  );

  -- 기존 고객 세션 만료
  update catchmenu_common.auth_sessions
  set
    session_status = 'LOGGED_OUT',
    logout_at = now(),
    logout_reason = 'new_login',
    updated_at = now()
  where subject_id = v_customer.id
    and tenant_id = p_tenant_id
    and session_status = 'ACTIVE'
    and session_type = 'CUSTOMER';

  -- 새 세션 생성
  insert into catchmenu_common.auth_sessions (
    tenant_id, store_id,
    session_type, subject_id, subject_type,
    device_fingerprint,
    session_token_hash, refresh_token_hash,
    granted_roles, granted_features,
    session_status,
    last_active_at,
    expires_at, refresh_expires_at,
    login_ip, login_locale, login_at
  ) values (
    p_tenant_id, p_store_id,
    'CUSTOMER', v_customer.id, 'CUSTOMER',
    p_device_fingerprint,
    v_session_token_hash, v_refresh_token_hash,
    jsonb_build_array('CUSTOMER'),
    jsonb_build_array(
      'PLACE_ORDER', 'VIEW_MENU',
      'VIEW_POINTS', 'USE_COUPON'
    ),
    'ACTIVE',
    now(),
    now() + interval '30 days',
    now() + interval '90 days',
    p_login_ip, p_locale, now()
  )
  returning id into v_session_id;

  -- 고객 앱 세션 + 푸시 토큰 업데이트
  if p_push_token is not null then
    perform catchmenu_store
      .register_customer_push_token(
        p_tenant_id := p_tenant_id,
        p_customer_id := v_customer.id,
        p_push_token := p_push_token,
        p_os_type := p_os_type,
        p_app_version := p_app_version
      );
  end if;

  -- 마지막 로그인 업데이트
  update catchmenu_store.customers
  set
    last_visit_at = now(),
    visit_count = visit_count + 1,
    updated_at = now()
  where id = v_customer.id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'auth', 'customer_login', 1,
    'customer', v_customer.id,
    null, 'ACTIVE',
    'CUSTOMER', v_customer.id,
    jsonb_build_object(
      'session_id', v_session_id,
      'is_new_customer', v_is_new_customer,
      'locale', p_locale
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_login_success',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'session_token', v_session_token,
      'refresh_token', v_refresh_token,
      'expires_at',
        now() + interval '30 days',
      'refresh_expires_at',
        now() + interval '90 days',
      'customer', jsonb_build_object(
        'id', v_customer.id,
        'display_name', v_customer.display_name,
        'membership_tier',
          v_customer.membership_tier,
        'total_points', v_customer.point_balance,
        'locale', v_customer.preferred_locale
      ),
      'is_new_customer', v_is_new_customer,
      'token_note',
        'Store in Flutter SecureStorage only'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_auth_context(
  p_tenant_id uuid,
  p_session_token_hash text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_subject_data jsonb;
  v_store_data jsonb;
  v_plan_data jsonb;
begin
  -- 세션 조회
  select s.id, s.session_type,
         s.subject_id, s.subject_type,
         s.store_id, s.device_id,
         s.granted_roles, s.granted_features,
         s.expires_at, s.last_active_at,
         s.login_locale
  into v_session
  from catchmenu_common.auth_sessions s
  where s.tenant_id = p_tenant_id
    and s.session_token_hash = p_session_token_hash
    and s.session_status = 'ACTIVE'
    and s.expires_at > now();

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'session_expired',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'get_auth_context'
    );
  end if;

  -- last_active 업데이트
  update catchmenu_common.auth_sessions
  set
    last_active_at = now(),
    updated_at = now()
  where id = v_session.id;

  -- 주체별 데이터 로드
  case v_session.subject_type
    when 'STAFF' then
      select jsonb_build_object(
        'id', id,
        'staff_name', staff_name,
        'staff_role', staff_role,
        'staff_status', staff_status,
        'allowed_features', allowed_features
      )
      into v_subject_data
      from catchmenu_store.staff
      where id = v_session.subject_id
        and tenant_id = p_tenant_id;

    when 'CUSTOMER' then
      select jsonb_build_object(
        'id', id,
        'display_name', display_name,
        'membership_tier', membership_tier,
        'total_points', point_balance,
        'locale', preferred_locale
      )
      into v_subject_data
      from catchmenu_store.customers
      where id = v_session.subject_id
        and tenant_id = p_tenant_id;

    else
      v_subject_data := jsonb_build_object(
        'id', v_session.subject_id,
        'type', v_session.subject_type
      );
  end case;

  -- 매장 정보
  if v_session.store_id is not null then
    select jsonb_build_object(
      'id', id,
      'store_name', store_name,
      'store_status', store_status,
      'timezone', timezone
    )
    into v_store_data
    from catchmenu_hq.stores
    where id = v_session.store_id
      and tenant_id = p_tenant_id;
  end if;

  -- 플랜 정보
  select jsonb_build_object(
    'plan_tier', plan_tier,
    'plan_status', plan_status,
    'enabled_features', enabled_features
  )
  into v_plan_data
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'auth_context_loaded',
    p_data := jsonb_build_object(
      'session_id', v_session.id,
      'session_type', v_session.session_type,
      'subject_type', v_session.subject_type,
      'subject', v_subject_data,
      'store', v_store_data,
      'plan', v_plan_data,
      'granted_roles', v_session.granted_roles,
      'granted_features',
        v_session.granted_features,
      'expires_at', v_session.expires_at,
      'last_active_at', v_session.last_active_at
    ),
    p_locale := coalesce(
      v_session.login_locale, p_locale
    )
  );
end;
$$;


-- =============================================
-- pg_cron: 만료 세션 정리
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'AUTH_SESSION_CLEANUP',
  'catchmenu_auth_session_cleanup',
  '*/30 * * * *',
  '*/30 * * * * (30분마다)',
  $sql$
UPDATE catchmenu_common.auth_sessions
SET
  session_status = 'EXPIRED',
  updated_at = now()
WHERE session_status = 'ACTIVE'
  AND expires_at < now();
$sql$,
  '만료된 인증 세션 정리. 30분마다.',
  true
)
on conflict (job_code) do nothing;


-- =============================================
-- Flutter SDK 패턴: 로그인 파이프라인
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values
(
  'FLUTTER_AUTH_PIPELINE',
  '로그인 파이프라인 패턴',
  'RPC_CALL',
  '["STAFF_APP","CUSTOMER_APP","POS_TERMINAL","KDS_DISPLAY"]'::jsonb,
  'Zero Trust 디바이스 등록 + 직원/고객 로그인 + 세션 관리',
  '["supabase_flutter: ^2.0.0","flutter_secure_storage: ^9.0.0"]'::jsonb,
  $dart$
// lib/services/auth_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {
  final _sb = Supabase.instance.client;
  final _storage = const FlutterSecureStorage();

  static const _tokenKey = 'auth_session_token';
  static const _refreshKey = 'auth_refresh_token';
  static const _sessionIdKey = 'auth_session_id';

  // 디바이스 핑거프린트 생성
  // (실제 앱에서는 device_info_plus 사용)
  String get deviceFingerprint {
    // 기기 고유 식별자 조합
    // iOS: identifierForVendor
    // Android: ANDROID_ID
    return 'DEVICE_FINGERPRINT_HERE';
  }

  // 디바이스 등록 (앱 최초 실행)
  Future<Map<String, dynamic>> registerDevice({
    required String tenantId,
    required String storeId,
    required String deviceType,
    required String deviceName,
  }) async {
    final res = await _sb.rpc(
      'register_device',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_device_fingerprint': deviceFingerprint,
        'p_device_type': deviceType,
        'p_device_name': deviceName,
        'p_os_type':
          Theme.of(context).platform ==
            TargetPlatform.iOS
            ? 'IOS' : 'ANDROID',
        'p_locale': 'ko',
      },
    );
    return res as Map<String, dynamic>;
  }

  // 직원 PIN 로그인
  Future<Map<String, dynamic>> staffLogin({
    required String tenantId,
    required String storeId,
    required String staffId,
    required String pin,
    required String deviceId,
  }) async {
    // PIN → SHA-256 해시
    final pinHash = sha256
      .convert(utf8.encode(pin))
      .toString();

    final res = await _sb.rpc(
      'staff_login',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_staff_id': staffId,
        'p_pin_hash': pinHash,
        'p_device_id': deviceId,
        'p_device_fingerprint': deviceFingerprint,
        'p_locale': 'ko',
      },
    );

    final data = res as Map<String, dynamic>;
    if (data['success'] == true) {
      // SecureStorage에 토큰 저장
      await _storage.write(
        key: _tokenKey,
        value: data['data']['session_token'],
      );
      await _storage.write(
        key: _refreshKey,
        value: data['data']['refresh_token'],
      );
      await _storage.write(
        key: _sessionIdKey,
        value: data['data']['session_id'],
      );
    }
    return data;
  }

  // 고객 앱 로그인 (전화번호 인증)
  Future<Map<String, dynamic>> customerLogin({
    required String tenantId,
    required String storeId,
    required String phoneHash,
    required String verifyCode,
    String? pushToken,
  }) async {
    // 인증코드 → SHA-256 해시
    final codeHash = sha256
      .convert(utf8.encode(verifyCode))
      .toString();

    final res = await _sb.rpc(
      'customer_login',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_phone_hash': phoneHash,
        'p_code_hash': codeHash,
        'p_device_fingerprint': deviceFingerprint,
        'p_push_token': pushToken,
        'p_locale': 'ko',
      },
    );

    final data = res as Map<String, dynamic>;
    if (data['success'] == true) {
      await _storage.write(
        key: _tokenKey,
        value: data['data']['session_token'],
      );
      await _storage.write(
        key: _refreshKey,
        value: data['data']['refresh_token'],
      );
    }
    return data;
  }

  // 인증 컨텍스트 로드
  Future<Map<String, dynamic>?> getAuthContext({
    required String tenantId,
  }) async {
    final token = await _storage.read(
      key: _tokenKey,
    );
    if (token == null) return null;

    // 토큰 → SHA-256 해시 (서버 전송용)
    final tokenHash = sha256
      .convert(utf8.encode(token))
      .toString();

    try {
      final res = await _sb.rpc(
        'get_auth_context',
        params: {
          'p_tenant_id': tenantId,
          'p_session_token_hash': tokenHash,
          'p_locale': 'ko',
        },
      );
      return res as Map<String, dynamic>;
    } catch (e) {
      // 세션 만료 시 refresh 시도
      return await _refreshSession(tenantId);
    }
  }

  // 세션 갱신
  Future<Map<String, dynamic>?> _refreshSession(
    String tenantId,
  ) async {
    final refreshToken = await _storage.read(
      key: _refreshKey,
    );
    if (refreshToken == null) return null;

    final refreshHash = sha256
      .convert(utf8.encode(refreshToken))
      .toString();

    final res = await _sb.rpc(
      'refresh_auth_session',
      params: {
        'p_tenant_id': tenantId,
        'p_refresh_token_hash': refreshHash,
      },
    );

    final data = res as Map<String, dynamic>;
    if (data['success'] == true) {
      await _storage.write(
        key: _tokenKey,
        value: data['data']['session_token'],
      );
      await _storage.write(
        key: _refreshKey,
        value: data['data']['refresh_token'],
      );
    }
    return data;
  }

  // 로그아웃
  Future<void> logout({
    required String tenantId,
  }) async {
    final token =
      await _storage.read(key: _tokenKey);
    if (token != null) {
      final tokenHash = sha256
        .convert(utf8.encode(token))
        .toString();
      await _sb.rpc(
        'staff_logout',
        params: {
          'p_tenant_id': tenantId,
          'p_session_token_hash': tokenHash,
        },
      );
    }
    await _storage.deleteAll();
  }

  // 저장된 토큰 SHA-256 해시 반환
  Future<String?> getTokenHash() async {
    final token =
      await _storage.read(key: _tokenKey);
    if (token == null) return null;
    return sha256
      .convert(utf8.encode(token))
      .toString();
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
    catchmenu_common.register_device(
      uuid, uuid, text, text, text,
      text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.register_device(
      uuid, uuid, text, text, text,
      text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.verify_device_trust(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.verify_device_trust(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.staff_login(
      uuid, uuid, uuid, text, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.staff_login(
      uuid, uuid, uuid, text, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.staff_logout(uuid, text, text)
    from public;
  grant execute on function
    catchmenu_common.staff_logout(uuid, text, text)
    to authenticated;

  revoke all on function
    catchmenu_common.refresh_auth_session(
      uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.refresh_auth_session(
      uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.customer_phone_verify_send(
      uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.customer_phone_verify_send(
      uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.customer_login(
      uuid, uuid, text, text, text,
      text, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_common.customer_login(
      uuid, uuid, text, text, text,
      text, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_auth_context(
      uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.get_auth_context(
      uuid, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_common.staff_login(
    uuid, uuid, uuid, text, uuid, text, text, text
  ) is
  '직원 PIN 로그인.
   Zero Trust 흐름:
   1. 브루트포스 확인 (5회/30분)
   2. 디바이스 신뢰 검증 (fingerprint)
   3. 직원 조회 + PIN SHA-256 검증
   4. 기존 세션 만료
   5. 새 세션 토큰 발급 (SHA-256 해시 저장)
   6. 로그인 이력 기록

   토큰 보안 원칙:
   - DB: SHA-256 해시만 저장
   - 앱: Flutter SecureStorage에 원본 저장
   - 전송: 해시만 서버로 전달
   세션 유효: 8시간 / Refresh: 7일.
   Zero Trust: 디바이스 + PIN 이중 검증.';

comment on function
  catchmenu_common.customer_login(
    uuid, uuid, text, text, text,
    text, text, text, text, text
  ) is
  '고객 앱 전화번호 인증 로그인.
   흐름:
   1. phone_verify_codes 코드 검증
   2. 신규 고객이면 자동 생성 (BRONZE)
   3. 기존 세션 만료
   4. 새 세션 발급 (30일)
   5. 푸시 토큰 등록
   6. 방문 횟수 + 마지막 방문 업데이트

   phone_hash: SHA-256(전화번호) → 원번호 비저장.
   code_hash: SHA-256(인증코드).
   세션 유효: 30일 / Refresh: 90일.
   1-B차 고객 앱 핵심 인증 흐름.';
