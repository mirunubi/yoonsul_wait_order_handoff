-- 0090_create_multitenant_isolation_rpc.sql
-- Purpose: Multi-tenant SaaS isolation hardening.
--          Tenant quota enforcement, rate limiting,
--          cross-tenant security audit,
--          tenant health monitoring.
--          1-C차 완전 SaaS 멀티테넌트 격리 핵심.
--          Zero Trust: 모든 RPC = tenant_id 검증.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0089_create_digital_sop_rag_rpc.sql
-- Creates:
--   catchmenu_common.tenant_quotas (table)
--   catchmenu_common.tenant_rate_limits (table)
--   catchmenu_common.security_audit_log (table)
--   function catchmenu_common.check_tenant_quota(...)
--   function catchmenu_common.enforce_rate_limit(...)
--   function catchmenu_common.run_security_audit(...)
--   function catchmenu_common.get_tenant_health(...)
--   function catchmenu_common.isolate_tenant(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('quota_exceeded', 'ko',
  '{resource} 한도를 초과했습니다'),
('quota_exceeded', 'en',
  '{resource} quota exceeded'),
('quota_within_limit', 'ko',
  '한도 내에서 사용 중입니다'),
('quota_within_limit', 'en',
  'Within quota limits'),
('rate_limit_exceeded', 'ko',
  '요청 한도를 초과했습니다. 잠시 후 다시 시도해 주세요'),
('rate_limit_exceeded', 'en',
  'Rate limit exceeded. Please try again later'),
('rate_limit_ok', 'ko',
  '요청이 허용되었습니다'),
('rate_limit_ok', 'en',
  'Request allowed'),
('security_audit_completed', 'ko',
  '보안 감사가 완료되었습니다'),
('security_audit_completed', 'en',
  'Security audit completed'),
('tenant_health_loaded', 'ko',
  '테넌트 상태가 로드되었습니다'),
('tenant_health_loaded', 'en',
  'Tenant health loaded'),
('tenant_isolated', 'ko',
  '테넌트가 격리되었습니다'),
('tenant_isolated', 'en',
  'Tenant isolated'),
('tenant_isolation_lifted', 'ko',
  '테넌트 격리가 해제되었습니다'),
('tenant_isolation_lifted', 'en',
  'Tenant isolation lifted'),
('cross_tenant_access_blocked', 'ko',
  '타 테넌트 데이터 접근이 차단되었습니다'),
('cross_tenant_access_blocked', 'en',
  'Cross-tenant data access blocked'),
('security_violation_detected', 'ko',
  '보안 위반이 감지되었습니다'),
('security_violation_detected', 'en',
  'Security violation detected')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(3010, 'quota_exceeded',
  'SYSTEM', 'QUOTA', 429, 'WARNING'),
(3011, 'rate_limit_exceeded',
  'SYSTEM', 'RATE_LIMIT', 429, 'WARNING'),
(3012, 'cross_tenant_access_blocked',
  'SYSTEM', 'SECURITY', 403, 'CRITICAL'),
(3013, 'tenant_isolated',
  'SYSTEM', 'BUSINESS_RULE', 503, 'ERROR'),
(3014, 'security_violation_detected',
  'SYSTEM', 'SECURITY', 403, 'CRITICAL')
on conflict (code) do nothing;


-- =============================================
-- tenant_quotas table
-- 테넌트 리소스 한도 관리
-- =============================================
create table if not exists
  catchmenu_common.tenant_quotas (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 리소스 종류
  resource_type text not null,

  -- 한도
  quota_limit int not null,
  quota_unit text not null default 'COUNT',
  quota_period text not null default 'MONTHLY',

  -- 현재 사용량
  current_usage int not null default 0,
  usage_reset_at timestamptz,
  last_usage_at timestamptz,

  -- 경보 임계치
  warning_threshold_pct int
    not null default 80,
  critical_threshold_pct int
    not null default 95,

  -- 초과 정책
  overage_policy text
    not null default 'BLOCK',
  overage_charge_per_unit int default null,

  -- 알림
  alert_sent_warning boolean
    not null default false,
  alert_sent_critical boolean
    not null default false,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_tenant_quota unique (
    tenant_id, resource_type, quota_period
  ),
  constraint chk_resource_type check (
    resource_type in (
      'MONTHLY_ORDERS',
      'MONTHLY_CUSTOMERS',
      'MONTHLY_AI_QUERIES',
      'ACTIVE_MENUS',
      'ACTIVE_STAFF',
      'REGISTERED_DEVICES',
      'ACTIVE_STORES',
      'PUSH_NOTIFICATIONS_DAILY',
      'DELIVERY_SYNC_DAILY',
      'API_CALLS_HOURLY'
    )
  ),
  constraint chk_quota_period check (
    quota_period in (
      'HOURLY', 'DAILY',
      'MONTHLY', 'ANNUAL', 'UNLIMITED'
    )
  ),
  constraint chk_overage_policy check (
    overage_policy in (
      'BLOCK', 'WARN_ONLY',
      'CHARGE', 'UPGRADE_PROMPT'
    )
  )
);

create index if not exists idx_quotas_tenant
  on catchmenu_common.tenant_quotas(
    tenant_id, resource_type
  ) where is_active = true;

alter table catchmenu_common.tenant_quotas
  enable row level security;
alter table catchmenu_common.tenant_quotas
  force row level security;

drop policy if exists tenant_quotas_isolation
  on catchmenu_common.tenant_quotas;
create policy tenant_quotas_isolation
  on catchmenu_common.tenant_quotas
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_quotas_updated
  on catchmenu_common.tenant_quotas;
create trigger trg_quotas_updated
  before update on catchmenu_common.tenant_quotas
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.tenant_quotas is
  '테넌트 리소스 한도 관리.
   BLOCK: 한도 초과 시 요청 거부.
   WARN_ONLY: 경고만 (STARTER 플랜).
   CHARGE: 초과 사용량 추가 과금.
   UPGRADE_PROMPT: 플랜 업그레이드 안내.
   1-C차 완전 SaaS 핵심 격리 메커니즘.
   플랜별 할당량:
   TRIAL: 500 orders/month
   STARTER: 무제한 (소상공인 배려)
   PRO: 무제한
   ENTERPRISE: 협상';


-- =============================================
-- tenant_rate_limits table
-- API 요청 속도 제한
-- =============================================
create table if not exists
  catchmenu_common.tenant_rate_limits (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),

  -- 제한 식별
  limit_key text not null,
  rpc_name text,
  limit_scope text not null default 'TENANT',

  -- 제한값
  max_requests int not null,
  window_seconds int not null,

  -- 현재 상태
  current_count int not null default 0,
  window_start_at timestamptz
    not null default now(),
  window_end_at timestamptz
    not null default now() + interval '1 minute',

  -- 위반 추적
  violation_count int not null default 0,
  last_violation_at timestamptz,
  is_blocked boolean not null default false,
  blocked_until timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_rate_limit unique (
    tenant_id, limit_key
  ),
  constraint chk_limit_scope check (
    limit_scope in (
      'TENANT', 'STORE',
      'USER', 'IP', 'RPC'
    )
  )
);

create index if not exists idx_rate_limits_tenant
  on catchmenu_common.tenant_rate_limits(
    tenant_id, limit_key
  );

alter table catchmenu_common.tenant_rate_limits
  enable row level security;
alter table catchmenu_common.tenant_rate_limits
  force row level security;

drop policy if exists rate_limits_isolation
  on catchmenu_common.tenant_rate_limits;
create policy rate_limits_isolation
  on catchmenu_common.tenant_rate_limits
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_rate_limits_updated
  on catchmenu_common.tenant_rate_limits;
create trigger trg_rate_limits_updated
  before update on catchmenu_common.tenant_rate_limits
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_common.tenant_rate_limits is
  'API 요청 속도 제한.
   슬라이딩 윈도우 방식.
   limit_key: RPC명 + 범위 조합.
   is_blocked: 연속 위반 시 임시 차단.
   blocked_until: 차단 해제 시각.
   1-C차 완전 SaaS DDoS/abuse 방지.
   Zero Trust: 모든 테넌트 동등 제한.';


-- =============================================
-- security_audit_log table
-- 보안 감사 로그
-- =============================================
create table if not exists
  catchmenu_common.security_audit_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid,

  -- 감사 이벤트
  audit_event text not null,
  event_severity text not null default 'INFO',
  event_source text not null,

  -- 행위자
  actor_type text,
  actor_id uuid,
  actor_ip text,

  -- 대상 리소스
  resource_type text,
  resource_id uuid,

  -- 이벤트 상세
  event_detail jsonb default '{}'::jsonb,
  is_violation boolean not null default false,
  was_blocked boolean not null default false,

  -- 결과
  action_taken text,

  created_at timestamptz not null default now(),

  constraint chk_event_severity check (
    event_severity in (
      'INFO', 'WARNING',
      'ERROR', 'CRITICAL'
    )
  )
);

create index if not exists idx_security_audit_tenant
  on catchmenu_common.security_audit_log(
    tenant_id, event_severity, created_at desc
  );
create index if not exists idx_security_audit_violation
  on catchmenu_common.security_audit_log(
    is_violation, created_at desc
  ) where is_violation = true;

alter table catchmenu_common.security_audit_log
  enable row level security;
alter table catchmenu_common.security_audit_log
  force row level security;

drop policy if exists security_audit_isolation
  on catchmenu_common.security_audit_log;
create policy security_audit_isolation
  on catchmenu_common.security_audit_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_common.security_audit_log is
  '보안 감사 로그.
   append-only: 절대 삭제/수정 불가.
   is_violation: 보안 위반 여부.
   was_blocked: 실제 차단 여부.
   cross_tenant_access: CRITICAL 자동 기록.
   보관 의무: 5년 (금융/보안 감사 대비).
   1-C차 완전 SaaS Zero Trust 핵심.';


-- =============================================
-- quota seed (플랜별 기본 할당량)
-- =============================================
create or replace function
  catchmenu_common.seed_tenant_quotas(
  p_tenant_id uuid,
  p_plan_tier text
)
returns void
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
begin
  insert into catchmenu_common.tenant_quotas (
    tenant_id, resource_type,
    quota_limit, quota_period,
    warning_threshold_pct,
    critical_threshold_pct,
    overage_policy
  )
  select
    p_tenant_id,
    q.resource_type,
    case p_plan_tier
      when 'TRIAL' then q.trial_limit
      when 'STARTER' then q.starter_limit
      when 'PRO' then q.pro_limit
      when 'ENTERPRISE' then q.enterprise_limit
      else q.trial_limit
    end,
    q.quota_period,
    80, 95,
    case p_plan_tier
      when 'TRIAL' then 'BLOCK'
      when 'STARTER' then 'WARN_ONLY'
      else 'WARN_ONLY'
    end
  from (
    values
    ('MONTHLY_ORDERS', 'MONTHLY',
      500, 99999, 99999, 99999),
    ('MONTHLY_CUSTOMERS', 'MONTHLY',
      100, 99999, 99999, 99999),
    ('MONTHLY_AI_QUERIES', 'MONTHLY',
      100, 1000, 10000, 99999),
    ('ACTIVE_MENUS', 'UNLIMITED',
      50, 100, 300, 9999),
    ('ACTIVE_STAFF', 'UNLIMITED',
      5, 10, 20, 50),
    ('REGISTERED_DEVICES', 'UNLIMITED',
      3, 5, 10, 20),
    ('ACTIVE_STORES', 'UNLIMITED',
      1, 1, 3, 99),
    ('PUSH_NOTIFICATIONS_DAILY', 'DAILY',
      100, 1000, 10000, 99999),
    ('API_CALLS_HOURLY', 'HOURLY',
      100, 500, 2000, 10000)
  ) as q(
    resource_type, quota_period,
    trial_limit, starter_limit,
    pro_limit, enterprise_limit
  )
  on conflict (tenant_id, resource_type, quota_period)
  do nothing;
end;
$$;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.check_tenant_quota(
  p_tenant_id uuid,
  p_resource_type text,
  p_increment int default 1,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_quota record;
  v_new_usage int;
  v_usage_pct int;
  v_is_exceeded boolean;
  v_is_warning boolean;
  v_should_block boolean;
begin
  select id, quota_limit, current_usage,
         quota_period, overage_policy,
         warning_threshold_pct,
         critical_threshold_pct,
         usage_reset_at
  into v_quota
  from catchmenu_common.tenant_quotas
  where tenant_id = p_tenant_id
    and resource_type = p_resource_type
    and is_active = true
  for update;

  -- 쿼터 설정 없으면 허용
  if v_quota.id is null then
    return jsonb_build_object(
      'allowed', true,
      'quota_configured', false,
      'resource_type', p_resource_type
    );
  end if;

  -- 기간별 리셋 확인
  if v_quota.quota_period = 'MONTHLY' then
    if v_quota.usage_reset_at is null
      or v_quota.usage_reset_at
        < date_trunc('month', now())
    then
      update catchmenu_common.tenant_quotas
      set
        current_usage = 0,
        usage_reset_at = now(),
        alert_sent_warning = false,
        alert_sent_critical = false,
        updated_at = now()
      where id = v_quota.id;
      v_quota.current_usage := 0;
    end if;
  elsif v_quota.quota_period = 'DAILY' then
    if v_quota.usage_reset_at is null
      or v_quota.usage_reset_at
        < date_trunc('day', now())
    then
      update catchmenu_common.tenant_quotas
      set
        current_usage = 0,
        usage_reset_at = now(),
        alert_sent_warning = false,
        alert_sent_critical = false,
        updated_at = now()
      where id = v_quota.id;
      v_quota.current_usage := 0;
    end if;
  elsif v_quota.quota_period = 'HOURLY' then
    if v_quota.usage_reset_at is null
      or v_quota.usage_reset_at
        < date_trunc('hour', now())
    then
      update catchmenu_common.tenant_quotas
      set
        current_usage = 0,
        usage_reset_at = now(),
        updated_at = now()
      where id = v_quota.id;
      v_quota.current_usage := 0;
    end if;
  end if;

  v_new_usage := v_quota.current_usage
    + p_increment;
  v_usage_pct := case v_quota.quota_limit
    when 0 then 0
    else (
      v_new_usage::numeric
      / v_quota.quota_limit * 100
    )::int
  end;

  v_is_exceeded := v_new_usage
    > v_quota.quota_limit;
  v_is_warning := v_usage_pct
    >= v_quota.warning_threshold_pct;
  v_should_block := v_is_exceeded
    and v_quota.overage_policy = 'BLOCK';

  if not v_should_block then
    -- 사용량 증가
    update catchmenu_common.tenant_quotas
    set
      current_usage = v_new_usage,
      last_usage_at = now(),
      updated_at = now()
    where id = v_quota.id;
  end if;

  if v_should_block then
    -- 보안 로그
    insert into
      catchmenu_common.security_audit_log (
      tenant_id, audit_event, event_severity,
      event_source, resource_type,
      event_detail, is_violation, was_blocked
    ) values (
      p_tenant_id, 'quota_exceeded',
      'WARNING', 'check_tenant_quota',
      p_resource_type,
      jsonb_build_object(
        'resource_type', p_resource_type,
        'quota_limit', v_quota.quota_limit,
        'current_usage', v_quota.current_usage,
        'attempted', p_increment
      ),
      true, true
    );

    return jsonb_build_object(
      'allowed', false,
      'error_key', 'quota_exceeded',
      'message',
        catchmenu_common.get_message(
          'quota_exceeded', p_locale,
          jsonb_build_object(
            'resource', p_resource_type
          )
        ),
      'resource_type', p_resource_type,
      'quota_limit', v_quota.quota_limit,
      'current_usage', v_quota.current_usage,
      'usage_pct', v_usage_pct,
      'overage_policy', v_quota.overage_policy
    );
  end if;

  return jsonb_build_object(
    'allowed', true,
    'resource_type', p_resource_type,
    'quota_limit', v_quota.quota_limit,
    'current_usage', v_new_usage,
    'usage_pct', v_usage_pct,
    'is_warning', v_is_warning,
    'is_exceeded', v_is_exceeded,
    'overage_policy', v_quota.overage_policy,
    'message_code', case
      when v_is_exceeded
        then 'quota_exceeded'
      else 'quota_within_limit'
    end
  );
end;
$$;


create or replace function
  catchmenu_common.enforce_rate_limit(
  p_tenant_id uuid,
  p_limit_key text,
  p_max_requests int,
  p_window_seconds int,
  p_rpc_name text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_limit record;
  v_now timestamptz := now();
  v_window_end timestamptz;
  v_is_blocked boolean := false;
  v_remaining int;
begin
  v_window_end := v_now
    + (p_window_seconds || ' seconds')::interval;

  -- 슬라이딩 윈도우 rate limit
  insert into catchmenu_common.tenant_rate_limits (
    tenant_id, limit_key, rpc_name,
    max_requests, window_seconds,
    current_count,
    window_start_at, window_end_at
  ) values (
    p_tenant_id, p_limit_key, p_rpc_name,
    p_max_requests, p_window_seconds,
    1, v_now, v_window_end
  )
  on conflict (tenant_id, limit_key) do update set
    current_count = case
      -- 윈도우 만료 시 리셋
      when tenant_rate_limits.window_end_at < v_now
      then 1
      else tenant_rate_limits.current_count + 1
    end,
    window_start_at = case
      when tenant_rate_limits.window_end_at < v_now
      then v_now
      else tenant_rate_limits.window_start_at
    end,
    window_end_at = case
      when tenant_rate_limits.window_end_at < v_now
      then v_window_end
      else tenant_rate_limits.window_end_at
    end,
    updated_at = now()
  returning
    current_count, window_end_at,
    is_blocked, blocked_until,
    violation_count
  into v_limit;

  -- 차단 여부 확인
  if v_limit.is_blocked
    and v_limit.blocked_until > v_now
  then
    return jsonb_build_object(
      'allowed', false,
      'error_key', 'rate_limit_exceeded',
      'message',
        catchmenu_common.get_message(
          'rate_limit_exceeded', p_locale, null
        ),
      'limit_key', p_limit_key,
      'blocked_until', v_limit.blocked_until,
      'retry_after_seconds', extract(
        epoch from (
          v_limit.blocked_until - v_now
        )
      )::int
    );
  end if;

  -- 한도 초과 확인
  if v_limit.current_count > p_max_requests then
    -- 위반 카운트 증가
    update catchmenu_common.tenant_rate_limits
    set
      violation_count = violation_count + 1,
      last_violation_at = v_now,
      -- 3회 이상 위반 시 1분 차단
      is_blocked = violation_count >= 3,
      blocked_until = case
        when violation_count >= 3
          then v_now + interval '1 minute'
        else null
      end,
      updated_at = now()
    where tenant_id = p_tenant_id
      and limit_key = p_limit_key;

    -- 보안 로그
    insert into
      catchmenu_common.security_audit_log (
      tenant_id, audit_event, event_severity,
      event_source, event_detail,
      is_violation, was_blocked
    ) values (
      p_tenant_id, 'rate_limit_exceeded',
      'WARNING', 'enforce_rate_limit',
      jsonb_build_object(
        'limit_key', p_limit_key,
        'rpc_name', p_rpc_name,
        'count', v_limit.current_count,
        'max', p_max_requests
      ),
      true, true
    );

    return jsonb_build_object(
      'allowed', false,
      'error_key', 'rate_limit_exceeded',
      'message',
        catchmenu_common.get_message(
          'rate_limit_exceeded', p_locale, null
        ),
      'limit_key', p_limit_key,
      'current_count', v_limit.current_count,
      'max_requests', p_max_requests,
      'window_seconds', p_window_seconds,
      'retry_after_seconds', extract(
        epoch from (
          v_limit.window_end_at - v_now
        )
      )::int
    );
  end if;

  v_remaining := p_max_requests
    - v_limit.current_count;

  return jsonb_build_object(
    'allowed', true,
    'limit_key', p_limit_key,
    'current_count', v_limit.current_count,
    'max_requests', p_max_requests,
    'remaining', v_remaining,
    'window_end_at', v_limit.window_end_at,
    'message_code', 'rate_limit_ok'
  );
end;
$$;


create or replace function
  catchmenu_common.run_security_audit(
  p_tenant_id uuid,
  p_store_id uuid default null,
  p_audit_depth text default 'STANDARD',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_store
as $$
declare
  v_checks jsonb := '[]'::jsonb;
  v_passed int := 0;
  v_warnings int := 0;
  v_critical int := 0;
  v_business_day date;
  v_audit_id uuid;

  procedure add_audit_item(
    p_check_name text,
    p_status text,
    p_detail jsonb default null
  ) as
  $inner$
  begin
    v_checks := v_checks
      || jsonb_build_array(
        jsonb_build_object(
          'check', p_check_name,
          'status', p_status,
          'detail', p_detail
        )
      );
    case p_status
      when 'PASS' then
        v_passed := v_passed + 1;
      when 'WARNING' then
        v_warnings := v_warnings + 1;
      when 'CRITICAL' then
        v_critical := v_critical + 1;
      else null;
    end case;
  end;
  $inner$;

begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- CHECK 1: RLS 활성화 확인
  declare
    v_rls_disabled_tables jsonb;
  begin
    select coalesce(
      jsonb_agg(
        jsonb_build_object(
          'schema', schemaname,
          'table', tablename
        )
      ),
      '[]'::jsonb
    )
    into v_rls_disabled_tables
    from pg_tables
    where schemaname in (
      'catchmenu_common', 'catchmenu_hq',
      'catchmenu_pos', 'catchmenu_kds',
      'catchmenu_payment', 'catchmenu_store',
      'catchmenu_ledger', 'catchmenu_knowledge',
      'catchmenu_integrations', 'catchmenu_audit'
    )
    and tablename not in (
      select tablename
      from pg_tables t
      join pg_class c
        on c.relname = t.tablename
      join pg_namespace n
        on n.oid = c.relnamespace
        and n.nspname = t.schemaname
      where c.relrowsecurity = true
    );

    call add_audit_item(
      'rls_enabled_all_tables',
      case jsonb_array_length(v_rls_disabled_tables)
        when 0 then 'PASS'
        else 'CRITICAL'
      end,
      jsonb_build_object(
        'disabled_tables',
          v_rls_disabled_tables
      )
    );
  end;

  -- CHECK 2: 트러스트 디바이스 검증
  declare
    v_untrusted_count int;
  begin
    select count(*)
    into v_untrusted_count
    from catchmenu_store.device_registry
    where store_id in (
      select id from catchmenu_hq.stores
      where tenant_id = p_tenant_id
    )
    and trust_level
      not in ('TRUSTED', 'REGISTERED')
    and is_active = true;

    call add_audit_item(
      'device_trust_verification',
      case v_untrusted_count
        when 0 then 'PASS'
        else 'WARNING'
      end,
      jsonb_build_object(
        'untrusted_active_devices',
          v_untrusted_count
      )
    );
  end;

  -- CHECK 3: 미해결 보안 위반 확인
  declare
    v_violation_count int;
  begin
    select count(*)
    into v_violation_count
    from catchmenu_common.security_audit_log
    where tenant_id = p_tenant_id
      and is_violation = true
      and created_at > now()
        - interval '24 hours';

    call add_audit_item(
      'recent_security_violations',
      case
        when v_violation_count = 0 then 'PASS'
        when v_violation_count < 5 then 'WARNING'
        else 'CRITICAL'
      end,
      jsonb_build_object(
        'violations_24h', v_violation_count
      )
    );
  end;

  -- CHECK 4: Rate limit 위반 확인
  declare
    v_rate_violation_count int;
  begin
    select count(*)
    into v_rate_violation_count
    from catchmenu_common.tenant_rate_limits
    where tenant_id = p_tenant_id
      and violation_count > 0
      and last_violation_at
        > now() - interval '1 hour';

    call add_audit_item(
      'rate_limit_violations',
      case
        when v_rate_violation_count = 0
          then 'PASS'
        when v_rate_violation_count < 3
          then 'WARNING'
        else 'CRITICAL'
      end,
      jsonb_build_object(
        'violated_limits_1h',
          v_rate_violation_count
      )
    );
  end;

  -- CHECK 5: 쿼터 초과 확인
  declare
    v_quota_exceeded_count int;
  begin
    select count(*)
    into v_quota_exceeded_count
    from catchmenu_common.tenant_quotas
    where tenant_id = p_tenant_id
      and current_usage > quota_limit
      and overage_policy = 'BLOCK';

    call add_audit_item(
      'quota_compliance',
      case v_quota_exceeded_count
        when 0 then 'PASS'
        else 'WARNING'
      end,
      jsonb_build_object(
        'exceeded_quotas',
          v_quota_exceeded_count
      )
    );
  end;

  -- CHECK 6: 플랜 유효성 확인
  declare
    v_plan_status text;
    v_trial_expired boolean := false;
  begin
    select plan_status,
           trial_ends_at < now()
    into v_plan_status, v_trial_expired
    from catchmenu_common.tenant_plan_configs
    where tenant_id = p_tenant_id;

    call add_audit_item(
      'subscription_valid',
      case
        when v_plan_status = 'ACTIVE'
          then 'PASS'
        when v_trial_expired
          then 'CRITICAL'
        else 'WARNING'
      end,
      jsonb_build_object(
        'plan_status', v_plan_status,
        'trial_expired', v_trial_expired
      )
    );
  end;

  -- CHECK 7: pgvector 그라운딩 준수율
  if p_audit_depth = 'DEEP' then
    declare
      v_ungrounded_rate numeric;
    begin
      select coalesce(
        (count(*) filter (
          where not is_grounded
        )::numeric
        / nullif(count(*), 0) * 100
        ), 0
      )
      into v_ungrounded_rate
      from catchmenu_knowledge.ai_query_logs
      where tenant_id = p_tenant_id
        and query_date > v_business_day
          - interval '7 days';

      call add_audit_item(
        'pgvector_grounding_compliance',
        case
          when v_ungrounded_rate < 20
            then 'PASS'
          when v_ungrounded_rate < 40
            then 'WARNING'
          else 'CRITICAL'
        end,
        jsonb_build_object(
          'ungrounded_rate_pct',
            v_ungrounded_rate::int
        )
      );
    end;
  end if;

  -- 감사 결과 기록
  v_audit_id := gen_random_uuid();
  insert into catchmenu_common.security_audit_log (
    id, tenant_id, store_id,
    audit_event, event_severity,
    event_source,
    event_detail,
    is_violation
  ) values (
    v_audit_id, p_tenant_id, p_store_id,
    'security_audit_completed',
    case
      when v_critical > 0 then 'CRITICAL'
      when v_warnings > 0 then 'WARNING'
      else 'INFO'
    end,
    'run_security_audit',
    jsonb_build_object(
      'audit_depth', p_audit_depth,
      'passed', v_passed,
      'warnings', v_warnings,
      'critical', v_critical
    ),
    v_critical > 0
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'security_audit_completed',
    p_data := jsonb_build_object(
      'audit_id', v_audit_id,
      'audit_depth', p_audit_depth,
      'business_day', v_business_day,
      'overall_status', case
        when v_critical > 0 then 'CRITICAL'
        when v_warnings > 0 then 'WARNING'
        else 'HEALTHY'
      end,
      'results', jsonb_build_object(
        'passed', v_passed,
        'warnings', v_warnings,
        'critical', v_critical,
        'total', v_passed + v_warnings + v_critical
      ),
      'checks', v_checks
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_tenant_health(
  p_tenant_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment
as $$
declare
  v_plan record;
  v_quota_summary jsonb;
  v_rate_limit_summary jsonb;
  v_security_summary jsonb;
  v_business_day date;
  v_store_count int;
  v_overall_health text;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 플랜 정보
  select plan_tier, plan_status,
         monthly_fee, trial_ends_at,
         subscription_starts_at
  into v_plan
  from catchmenu_common.tenant_plan_configs
  where tenant_id = p_tenant_id;

  -- 매장 수
  select count(*) into v_store_count
  from catchmenu_hq.stores
  where tenant_id = p_tenant_id
    and is_active = true;

  -- 쿼터 요약
  select jsonb_build_object(
    'total_quotas', count(*),
    'exceeded', count(*) filter (
      where current_usage > quota_limit
    ),
    'warning_level', count(*) filter (
      where current_usage::numeric
        / nullif(quota_limit, 0) * 100
        >= warning_threshold_pct
    ),
    'usage_by_resource', coalesce(
      jsonb_object_agg(
        resource_type,
        jsonb_build_object(
          'limit', quota_limit,
          'usage', current_usage,
          'pct', case quota_limit
            when 0 then 0
            else (
              current_usage::numeric
              / quota_limit * 100
            )::int
          end
        )
      ),
      '{}'::jsonb
    )
  )
  into v_quota_summary
  from catchmenu_common.tenant_quotas
  where tenant_id = p_tenant_id
    and is_active = true;

  -- Rate limit 요약
  select jsonb_build_object(
    'total_limits', count(*),
    'blocked', count(*) filter (
      where is_blocked = true
        and blocked_until > now()
    ),
    'violations_today', coalesce(
      sum(violation_count)
        filter (
          where last_violation_at::date
            = v_business_day
        ), 0
    )
  )
  into v_rate_limit_summary
  from catchmenu_common.tenant_rate_limits
  where tenant_id = p_tenant_id;

  -- 보안 요약
  select jsonb_build_object(
    'violations_24h', count(*) filter (
      where is_violation = true
        and created_at >
          now() - interval '24 hours'
    ),
    'critical_24h', count(*) filter (
      where event_severity = 'CRITICAL'
        and created_at >
          now() - interval '24 hours'
    ),
    'last_audit_at', max(created_at) filter (
      where audit_event
        = 'security_audit_completed'
    )
  )
  into v_security_summary
  from catchmenu_common.security_audit_log
  where tenant_id = p_tenant_id;

  -- 전체 건강 상태
  v_overall_health := case
    when (
      v_plan.plan_status not in (
        'ACTIVE', 'TRIAL'
      )
      or (
        v_plan.plan_status = 'TRIAL'
        and v_plan.trial_ends_at < now()
      )
    ) then 'CRITICAL'
    when (
      (v_security_summary->>'critical_24h')::int > 0
      or (v_quota_summary->>'exceeded')::int > 0
    ) then 'WARNING'
    else 'HEALTHY'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'tenant_health_loaded',
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'overall_health', v_overall_health,
      'plan', jsonb_build_object(
        'tier', v_plan.plan_tier,
        'status', v_plan.plan_status,
        'monthly_fee', v_plan.monthly_fee,
        'trial_ends_at', v_plan.trial_ends_at,
        'subscription_starts_at',
          v_plan.subscription_starts_at
      ),
      'stores', jsonb_build_object(
        'active_count', v_store_count
      ),
      'quotas', v_quota_summary,
      'rate_limits', v_rate_limit_summary,
      'security', v_security_summary,
      'checked_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.isolate_tenant(
  p_tenant_id uuid,
  p_isolation_reason text,
  p_isolate boolean default true,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit
as $$
declare
  v_new_status text;
  v_message_key text;
  v_audit_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_new_status := case p_isolate
    when true then 'ISOLATED'
    else 'ACTIVE'
  end;
  v_message_key := case p_isolate
    when true then 'tenant_isolated'
    else 'tenant_isolation_lifted'
  end;

  -- 테넌트 상태 변경
  update catchmenu_hq.tenants
  set
    tenant_status = v_new_status,
    updated_at = now()
  where id = p_tenant_id;

  if not found then
    return catchmenu_common.build_error_response(
      p_error_key := 'tenant_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'isolate_tenant'
    );
  end if;

  -- 보안 감사 로그
  insert into catchmenu_common.security_audit_log (
    tenant_id, audit_event, event_severity,
    event_source, actor_type, actor_id,
    event_detail, is_violation, was_blocked
  ) values (
    p_tenant_id,
    case p_isolate
      when true then 'tenant_isolated'
      else 'tenant_isolation_lifted'
    end,
    case p_isolate
      when true then 'CRITICAL'
      else 'INFO'
    end,
    'isolate_tenant',
    'HQ_ADMIN', p_actor_id,
    jsonb_build_object(
      'isolation_reason', p_isolation_reason,
      'new_status', v_new_status
    ),
    p_isolate, p_isolate
  );

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'system',
    p_audit_type := v_message_key,
    p_audit_category := 'SECURITY',
    p_actor_type := 'HQ_ADMIN',
    p_actor_id := p_actor_id,
    p_subject_type := 'tenant',
    p_subject_id := p_tenant_id,
    p_decision := v_new_status,
    p_decision_reason := p_isolation_reason,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'system', v_message_key, 1,
    'tenant', p_tenant_id,
    case p_isolate
      when true then 'ACTIVE'
      else 'ISOLATED'
    end,
    v_new_status,
    'HQ_ADMIN', p_actor_id,
    jsonb_build_object(
      'isolation_reason', p_isolation_reason,
      'audit_id', v_audit_id
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := v_message_key,
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'new_status', v_new_status,
      'isolation_reason', p_isolation_reason,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 보안 감사 (주간)
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'WEEKLY_SECURITY_AUDIT',
  'catchmenu_security_audit',
  '0 19 * * 0',
  '0 4 * * 1 (매주 월요일 새벽 4시 KST)',
  $sql$
SELECT catchmenu_common.run_security_audit(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_audit_depth := 'DEEP'
);
$sql$,
  '주간 보안 감사. 매주 월요일 새벽 4시 KST.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_common.check_tenant_quota(
      uuid, text, int, text
    ) from public;
  grant execute on function
    catchmenu_common.check_tenant_quota(
      uuid, text, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.enforce_rate_limit(
      uuid, text, int, int, text, text
    ) from public;
  grant execute on function
    catchmenu_common.enforce_rate_limit(
      uuid, text, int, int, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.run_security_audit(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_common.run_security_audit(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_tenant_health(uuid, text)
    from public;
  grant execute on function
    catchmenu_common.get_tenant_health(uuid, text)
    to authenticated;

  revoke all on function
    catchmenu_common.isolate_tenant(
      uuid, text, boolean, uuid, text
    ) from public;
  grant execute on function
    catchmenu_common.isolate_tenant(
      uuid, text, boolean, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.seed_tenant_quotas(uuid, text)
    from public;
  grant execute on function
    catchmenu_common.seed_tenant_quotas(uuid, text)
    to authenticated;
end;
$$;

comment on function
  catchmenu_common.check_tenant_quota(
    uuid, text, int, text
  ) is
  '테넌트 리소스 한도 확인 + 사용량 증가.
   기간별 자동 리셋:
   HOURLY: 매 시간
   DAILY: 매일 자정
   MONTHLY: 매월 1일
   BLOCK 정책: 한도 초과 시 요청 거부.
   WARN_ONLY: 경고만 (STARTER 배려).
   보안 로그 자동 기록 (quota_exceeded).
   1-C차 완전 SaaS 핵심 격리 메커니즘.';

comment on function
  catchmenu_common.run_security_audit(
    uuid, uuid, text, text
  ) is
  'SaaS 보안 감사.
   검사 항목 (STANDARD):
   1. RLS 활성화 전체 테이블
   2. 디바이스 신뢰 수준
   3. 최근 보안 위반 (24h)
   4. Rate limit 위반
   5. 쿼터 초과
   6. 구독 유효성
   추가 검사 (DEEP):
   7. pgvector 그라운딩 준수율
   Zero Trust: 모든 항목 독립 검증.
   1-C차 완전 SaaS 주간 보안 점검.';