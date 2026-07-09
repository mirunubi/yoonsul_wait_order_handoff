-- 0131_create_advanced_staff_permission.sql
-- Purpose: Advanced staff permission management.
--          역할별 권한 세분화.
--          기능별 권한 매트릭스.
--          임시 권한 승인.
--          권한 감사 로그.
--          PIN 보안 강화.
-- Depends on: 0130_create_van_handler_extension.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('permission_granted', 'ko',
  '권한이 부여되었습니다'),
('permission_granted', 'en',
  'Permission granted'),
('permission_revoked', 'ko',
  '권한이 회수되었습니다'),
('permission_revoked', 'en',
  'Permission revoked'),
('temp_permission_granted', 'ko',
  '임시 권한이 {duration_minutes}분 부여되었습니다'),
('temp_permission_granted', 'en',
  'Temporary permission granted for {duration_minutes} min'),
('permission_check_passed', 'ko',
  '권한이 확인되었습니다'),
('permission_check_passed', 'en',
  'Permission check passed'),
('permission_denied', 'ko',
  '권한이 없습니다'),
('permission_denied', 'en',
  'Permission denied'),
('permission_denied', 'zh',
  '没有权限'),
('permission_denied', 'ja',
  '権限がありません'),
('permission_denied', 'vi',
  'Không có quyền'),
('permission_denied', 'th',
  'ไม่มีสิทธิ์')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7100, 'permission_denied',
  'STORE', 'PERMISSION', 403, 'WARNING'),
(7101, 'temp_permission_expired',
  'STORE', 'PERMISSION', 403, 'INFO'),
(7102, 'permission_not_found',
  'STORE', 'NOT_FOUND', 404, 'WARNING'),
(7103, 'pin_verification_failed',
  'STORE', 'PERMISSION', 401, 'WARNING'),
(7104, 'pin_locked',
  'STORE', 'PERMISSION', 423, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- staff_permission_matrix table
-- 역할별 권한 매트릭스
-- =============================================
create table if not exists
  catchmenu_store.staff_permission_matrix (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 역할 + 기능
  staff_role text not null,
  feature_code text not null,
  is_allowed boolean not null default false,

  -- 조건
  requires_pin_confirm boolean
    not null default false,
  requires_manager_approve boolean
    not null default false,
  max_amount_limit int,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_permission_matrix unique (
    store_id, staff_role, feature_code
  )
);

alter table
  catchmenu_store.staff_permission_matrix
  enable row level security;
alter table
  catchmenu_store.staff_permission_matrix
  force row level security;

drop policy if exists permission_matrix_isolation
  on catchmenu_store.staff_permission_matrix;
create policy permission_matrix_isolation
  on catchmenu_store.staff_permission_matrix
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_permission_matrix_updated
  on catchmenu_store.staff_permission_matrix;
create trigger trg_permission_matrix_updated
  before update on
    catchmenu_store.staff_permission_matrix
  for each row execute function
    catchmenu_common.set_updated_at();

-- 기본 권한 매트릭스 시드
insert into catchmenu_store
  .staff_permission_matrix (
  tenant_id, store_id,
  staff_role, feature_code,
  is_allowed,
  requires_pin_confirm,
  requires_manager_approve,
  max_amount_limit
)
select
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  role, feature, allowed,
  needs_pin, needs_manager, amount_limit
from (values
  -- OWNER: 전체 권한
  ('OWNER', 'VIEW_ORDERS', true, false, false, null),
  ('OWNER', 'PLACE_ORDER', true, false, false, null),
  ('OWNER', 'CANCEL_ORDER', true, false, false, null),
  ('OWNER', 'PROCESS_REFUND', true, true, false, null),
  ('OWNER', 'VIEW_KDS', true, false, false, null),
  ('OWNER', 'UPDATE_KDS', true, false, false, null),
  ('OWNER', 'MANAGE_WAITING', true, false, false, null),
  ('OWNER', 'VIEW_REPORTS', true, false, false, null),
  ('OWNER', 'MANAGE_MENU', true, false, false, null),
  ('OWNER', 'MANAGE_STAFF', true, true, false, null),
  ('OWNER', 'MANAGE_SETTINGS', true, true, false, null),
  ('OWNER', 'OPEN_CLOSE_STORE', true, false, false, null),
  ('OWNER', 'PROCESS_PAYMENT', true, false, false, null),
  ('OWNER', 'VIEW_INVENTORY', true, false, false, null),
  ('OWNER', 'UPDATE_INVENTORY', true, false, false, null),
  ('OWNER', 'VIEW_MEMBERSHIP', true, false, false, null),
  ('OWNER', 'ISSUE_COUPON', true, false, false, null),
  ('OWNER', 'VAN_NET_CANCEL', true, true, false, null),

  -- MANAGER: 설정 제외 전체
  ('MANAGER', 'VIEW_ORDERS', true, false, false, null),
  ('MANAGER', 'PLACE_ORDER', true, false, false, null),
  ('MANAGER', 'CANCEL_ORDER', true, false, false, null),
  ('MANAGER', 'PROCESS_REFUND', true, true, false, 100000),
  ('MANAGER', 'VIEW_KDS', true, false, false, null),
  ('MANAGER', 'UPDATE_KDS', true, false, false, null),
  ('MANAGER', 'MANAGE_WAITING', true, false, false, null),
  ('MANAGER', 'VIEW_REPORTS', true, false, false, null),
  ('MANAGER', 'MANAGE_MENU', true, false, false, null),
  ('MANAGER', 'MANAGE_STAFF', false, false, true, null),
  ('MANAGER', 'MANAGE_SETTINGS', false, false, true, null),
  ('MANAGER', 'OPEN_CLOSE_STORE', true, false, false, null),
  ('MANAGER', 'PROCESS_PAYMENT', true, false, false, null),
  ('MANAGER', 'VIEW_INVENTORY', true, false, false, null),
  ('MANAGER', 'UPDATE_INVENTORY', true, false, false, null),
  ('MANAGER', 'VIEW_MEMBERSHIP', true, false, false, null),
  ('MANAGER', 'ISSUE_COUPON', true, false, false, null),
  ('MANAGER', 'VAN_NET_CANCEL', true, true, true, 50000),

  -- STAFF: 주문/KDS/대기
  ('STAFF', 'VIEW_ORDERS', true, false, false, null),
  ('STAFF', 'PLACE_ORDER', true, false, false, null),
  ('STAFF', 'CANCEL_ORDER', false, false, true, null),
  ('STAFF', 'PROCESS_REFUND', false, false, true, null),
  ('STAFF', 'VIEW_KDS', true, false, false, null),
  ('STAFF', 'UPDATE_KDS', true, false, false, null),
  ('STAFF', 'MANAGE_WAITING', true, false, false, null),
  ('STAFF', 'VIEW_REPORTS', false, false, false, null),
  ('STAFF', 'MANAGE_MENU', false, false, true, null),
  ('STAFF', 'MANAGE_STAFF', false, false, false, null),
  ('STAFF', 'MANAGE_SETTINGS', false, false, false, null),
  ('STAFF', 'OPEN_CLOSE_STORE', false, false, true, null),
  ('STAFF', 'PROCESS_PAYMENT', true, false, false, null),
  ('STAFF', 'VIEW_INVENTORY', true, false, false, null),
  ('STAFF', 'UPDATE_INVENTORY', false, false, true, null),
  ('STAFF', 'VIEW_MEMBERSHIP', false, false, false, null),
  ('STAFF', 'ISSUE_COUPON', false, false, true, null),
  ('STAFF', 'VAN_NET_CANCEL', false, false, true, null),

  -- KITCHEN: KDS만
  ('KITCHEN', 'VIEW_ORDERS', false, false, false, null),
  ('KITCHEN', 'PLACE_ORDER', false, false, false, null),
  ('KITCHEN', 'CANCEL_ORDER', false, false, false, null),
  ('KITCHEN', 'PROCESS_REFUND', false, false, false, null),
  ('KITCHEN', 'VIEW_KDS', true, false, false, null),
  ('KITCHEN', 'UPDATE_KDS', true, false, false, null),
  ('KITCHEN', 'MANAGE_WAITING', false, false, false, null),
  ('KITCHEN', 'VIEW_REPORTS', false, false, false, null),
  ('KITCHEN', 'MANAGE_MENU', false, false, false, null),
  ('KITCHEN', 'MANAGE_STAFF', false, false, false, null),
  ('KITCHEN', 'MANAGE_SETTINGS', false, false, false, null),
  ('KITCHEN', 'OPEN_CLOSE_STORE', false, false, false, null),
  ('KITCHEN', 'PROCESS_PAYMENT', false, false, false, null),
  ('KITCHEN', 'VIEW_INVENTORY', true, false, false, null),
  ('KITCHEN', 'UPDATE_INVENTORY', true, false, false, null),
  ('KITCHEN', 'VIEW_MEMBERSHIP', false, false, false, null),
  ('KITCHEN', 'ISSUE_COUPON', false, false, false, null),
  ('KITCHEN', 'VAN_NET_CANCEL', false, false, false, null),

  -- PART_TIME: 주문 보기/접수
  ('PART_TIME', 'VIEW_ORDERS', true, false, false, null),
  ('PART_TIME', 'PLACE_ORDER', true, false, false, null),
  ('PART_TIME', 'CANCEL_ORDER', false, false, true, null),
  ('PART_TIME', 'PROCESS_REFUND', false, false, true, null),
  ('PART_TIME', 'VIEW_KDS', true, false, false, null),
  ('PART_TIME', 'UPDATE_KDS', false, false, true, null),
  ('PART_TIME', 'MANAGE_WAITING', true, false, false, null),
  ('PART_TIME', 'VIEW_REPORTS', false, false, false, null),
  ('PART_TIME', 'MANAGE_MENU', false, false, false, null),
  ('PART_TIME', 'MANAGE_STAFF', false, false, false, null),
  ('PART_TIME', 'MANAGE_SETTINGS', false, false, false, null),
  ('PART_TIME', 'OPEN_CLOSE_STORE', false, false, false, null),
  ('PART_TIME', 'PROCESS_PAYMENT', true, false, false, null),
  ('PART_TIME', 'VIEW_INVENTORY', false, false, false, null),
  ('PART_TIME', 'UPDATE_INVENTORY', false, false, false, null),
  ('PART_TIME', 'VIEW_MEMBERSHIP', false, false, false, null),
  ('PART_TIME', 'ISSUE_COUPON', false, false, false, null),
  ('PART_TIME', 'VAN_NET_CANCEL', false, false, false, null)
) as t(
  role, feature, allowed,
  needs_pin, needs_manager, amount_limit
)
on conflict (store_id, staff_role, feature_code)
do nothing;

comment on table
  catchmenu_store.staff_permission_matrix is
  '역할별 기능 권한 매트릭스.
   18개 기능 × 5개 역할 = 90개 기본 권한.
   requires_pin_confirm:
     실행 전 PIN 재확인 필요.
     PROCESS_REFUND/VAN_NET_CANCEL 등.
   requires_manager_approve:
     매니저 PIN 승인 필요.
     STAFF의 CANCEL_ORDER 등.
   max_amount_limit:
     금액 제한 (null = 무제한).
     MANAGER PROCESS_REFUND: 10만원.';


-- =============================================
-- staff_permission_logs table
-- 권한 감사 로그
-- =============================================
create table if not exists
  catchmenu_store.staff_permission_logs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 요청자
  staff_id uuid not null
    references catchmenu_store.staff(id),
  staff_role text not null,

  -- 권한 확인
  feature_code text not null,
  check_result text not null,
  denial_reason text,

  -- 승인 정보
  approved_by_id uuid,
  approved_by_role text,
  pin_confirmed boolean not null default false,

  -- 임시 권한
  is_temp_permission boolean
    not null default false,
  temp_expires_at timestamptz,

  -- 연결
  related_resource_type text,
  related_resource_id text,
  related_amount int,

  checked_at timestamptz
    not null default now(),

  constraint chk_check_result check (
    check_result in (
      'ALLOWED',            -- 허용
      'DENIED',             -- 거부
      'TEMP_ALLOWED',       -- 임시 허용
      'PIN_REQUIRED',       -- PIN 필요
      'MANAGER_REQUIRED',   -- 매니저 승인 필요
      'AMOUNT_EXCEEDED'     -- 금액 초과
    )
  )
);

create index if not exists idx_permission_logs
  on catchmenu_store.staff_permission_logs(
    store_id, staff_id, checked_at desc
  );
create index if not exists idx_permission_denied
  on catchmenu_store.staff_permission_logs(
    store_id, check_result, checked_at desc
  ) where check_result = 'DENIED';

alter table catchmenu_store.staff_permission_logs
  enable row level security;
alter table catchmenu_store.staff_permission_logs
  force row level security;

drop policy if exists permission_logs_isolation
  on catchmenu_store.staff_permission_logs;
create policy permission_logs_isolation
  on catchmenu_store.staff_permission_logs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_store.staff_permission_logs is
  '권한 감사 로그.
   모든 권한 확인 기록 (허용/거부 모두).
   DENIED 패턴 → 보안 위협 탐지 연동.
   PIN_REQUIRED: 재확인 후 재시도 필요.
   MANAGER_REQUIRED: 매니저 PIN 필요.
   임시 권한: 매니저가 승인한 1회성 권한.
   특허4: 권한 감사 = 운영 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.check_staff_permission(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_feature_code text,
  p_amount int default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_staff record;
  v_permission record;
  v_check_result text;
  v_denial_reason text;
  v_log_id uuid;
begin
  -- 직원 조회
  select id, staff_role, staff_status,
         allowed_features
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_status = 'ACTIVE';

  if v_staff.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'check_staff_permission'
    );
  end if;

  -- 권한 매트릭스 조회
  select is_allowed, requires_pin_confirm,
         requires_manager_approve,
         max_amount_limit
  into v_permission
  from catchmenu_store.staff_permission_matrix
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_role = v_staff.staff_role
    and feature_code = p_feature_code;

  -- 권한 판정
  if v_permission.is_allowed is null
    or not v_permission.is_allowed
  then
    -- 개인 허용 기능 확인
    if v_staff.allowed_features @>
      to_jsonb(p_feature_code)
    then
      v_check_result := 'ALLOWED';
    else
      v_check_result := 'DENIED';
      v_denial_reason := '역할 권한 없음';
    end if;

  elsif v_permission.requires_pin_confirm then
    v_check_result := 'PIN_REQUIRED';
    v_denial_reason := 'PIN 재확인 필요';

  elsif v_permission.requires_manager_approve
  then
    v_check_result := 'MANAGER_REQUIRED';
    v_denial_reason := '매니저 PIN 승인 필요';

  elsif p_amount is not null
    and v_permission.max_amount_limit is not null
    and p_amount > v_permission.max_amount_limit
  then
    v_check_result := 'AMOUNT_EXCEEDED';
    v_denial_reason := '금액 한도 초과: '
      || v_permission.max_amount_limit
      ::text || '원';

  else
    v_check_result := 'ALLOWED';
  end if;

  -- 감사 로그
  insert into
    catchmenu_store.staff_permission_logs (
    tenant_id, store_id,
    staff_id, staff_role,
    feature_code, check_result,
    denial_reason, related_amount
  ) values (
    p_tenant_id, p_store_id,
    p_staff_id, v_staff.staff_role,
    p_feature_code, v_check_result,
    v_denial_reason, p_amount
  )
  returning id into v_log_id;

  -- DENIED 반복 → 보안 위협 탐지
  declare
    v_denied_count int;
  begin
    select count(*) into v_denied_count
    from catchmenu_store.staff_permission_logs
    where staff_id = p_staff_id
      and check_result = 'DENIED'
      and checked_at > now() - interval '10 minutes';

    if v_denied_count >= 5 then
      perform catchmenu_common.detect_threat(
        p_threat_type := 'RLS_BYPASS_ATTEMPT',
        p_threat_stage := 3,
        p_threat_severity := 'HIGH',
        p_detection_source :=
          'check_staff_permission',
        p_threat_payload := jsonb_build_object(
          'staff_id', p_staff_id,
          'denied_count', v_denied_count,
          'feature_code', p_feature_code
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id
      );
    end if;
  end;

  return jsonb_build_object(
    'success', true,
    'data', jsonb_build_object(
      'staff_id', p_staff_id,
      'staff_role', v_staff.staff_role,
      'feature_code', p_feature_code,
      'check_result', v_check_result,
      'is_allowed',
        v_check_result = 'ALLOWED',
      'denial_reason', v_denial_reason,
      'requires_pin',
        v_check_result = 'PIN_REQUIRED',
      'requires_manager',
        v_check_result = 'MANAGER_REQUIRED',
      'amount_limit',
        v_permission.max_amount_limit,
      'log_id', v_log_id,
      'message',
        catchmenu_common.get_message(
          case v_check_result
            when 'ALLOWED' then
              'permission_check_passed'
            else 'permission_denied'
          end,
          p_locale, null
        )
    )
  );
end;
$$;


create or replace function
  catchmenu_store.grant_temp_permission(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid,
  p_feature_code text,
  p_approver_id uuid,
  p_duration_minutes int default 30,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_approver record;
  v_staff record;
  v_log_id uuid;
  v_expires_at timestamptz;
begin
  -- 승인자 확인 (MANAGER/OWNER만)
  select id, staff_role, staff_status
  into v_approver
  from catchmenu_store.staff
  where id = p_approver_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_status = 'ACTIVE'
    and staff_role in ('OWNER', 'MANAGER');

  if v_approver.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'permission_denied',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'reason',
          'MANAGER 또는 OWNER만 임시 권한 승인 가능'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'grant_temp_permission'
    );
  end if;

  -- 대상 직원 확인
  select id, staff_role
  into v_staff
  from catchmenu_store.staff
  where id = p_staff_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_status = 'ACTIVE';

  if v_staff.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'staff_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'grant_temp_permission'
    );
  end if;

  v_expires_at := now()
    + (p_duration_minutes || ' minutes')
      ::interval;

  -- 임시 권한 로그
  insert into
    catchmenu_store.staff_permission_logs (
    tenant_id, store_id,
    staff_id, staff_role,
    feature_code, check_result,
    approved_by_id, approved_by_role,
    is_temp_permission, temp_expires_at
  ) values (
    p_tenant_id, p_store_id,
    p_staff_id, v_staff.staff_role,
    p_feature_code, 'TEMP_ALLOWED',
    p_approver_id, v_approver.staff_role,
    true, v_expires_at
  )
  returning id into v_log_id;

  -- 직원 allowed_features 임시 추가
  update catchmenu_store.staff
  set
    allowed_features =
      allowed_features || to_jsonb(
        p_feature_code
      ),
    updated_at = now()
  where id = p_staff_id;

  -- Realtime 직원 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'temp_permission_granted',
    p_payload := jsonb_build_object(
      'staff_id', p_staff_id,
      'feature_code', p_feature_code,
      'expires_at', v_expires_at,
      'approved_by', p_approver_id
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'temp_permission_granted',
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'staff_id', p_staff_id,
      'feature_code', p_feature_code,
      'approved_by_id', p_approver_id,
      'duration_minutes', p_duration_minutes,
      'expires_at', v_expires_at
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'duration_minutes', p_duration_minutes
    )
  );
end;
$$;


create or replace function
  catchmenu_store.get_permission_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_denied_summary jsonb;
  v_role_matrix jsonb;
  v_recent_logs jsonb;
  v_temp_permissions jsonb;
begin
  -- 거부 요약 (오늘)
  select jsonb_build_object(
    'total_denied', count(*) filter (
      where check_result = 'DENIED'
    ),
    'total_allowed', count(*) filter (
      where check_result in (
        'ALLOWED', 'TEMP_ALLOWED'
      )
    ),
    'pin_required', count(*) filter (
      where check_result = 'PIN_REQUIRED'
    ),
    'manager_required', count(*) filter (
      where check_result = 'MANAGER_REQUIRED'
    ),
    'amount_exceeded', count(*) filter (
      where check_result = 'AMOUNT_EXCEEDED'
    )
  )
  into v_denied_summary
  from catchmenu_store.staff_permission_logs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and checked_at::date = (timezone(
      'Asia/Seoul', now()
    ))::date;

  -- 역할별 권한 매트릭스 요약
  select coalesce(
    jsonb_object_agg(
      staff_role,
      allowed_count
    ),
    '{}'::jsonb
  )
  into v_role_matrix
  from (
    select staff_role,
           count(*) filter (
             where is_allowed = true
           ) as allowed_count
    from catchmenu_store.staff_permission_matrix
    where store_id = p_store_id
      and tenant_id = p_tenant_id
    group by staff_role
  ) m;

  -- 최근 권한 로그 (20건)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'log_id', spl.id,
        'staff_name', s.staff_name,
        'staff_role', spl.staff_role,
        'feature_code', spl.feature_code,
        'check_result', spl.check_result,
        'denial_reason', spl.denial_reason,
        'is_temp', spl.is_temp_permission,
        'checked_at', spl.checked_at
      )
      order by spl.checked_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_logs
  from catchmenu_store.staff_permission_logs spl
  left join catchmenu_store.staff s
    on s.id = spl.staff_id
  where spl.store_id = p_store_id
    and spl.tenant_id = p_tenant_id
  limit 20;

  -- 활성 임시 권한
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'staff_id', spl.staff_id,
        'staff_name', s.staff_name,
        'feature_code', spl.feature_code,
        'expires_at', spl.temp_expires_at,
        'approved_by', spl.approved_by_id,
        'minutes_remaining', extract(
          epoch from (
            spl.temp_expires_at - now()
          )
        )::int / 60
      )
      order by spl.temp_expires_at asc
    ),
    '[]'::jsonb
  )
  into v_temp_permissions
  from catchmenu_store.staff_permission_logs spl
  left join catchmenu_store.staff s
    on s.id = spl.staff_id
  where spl.store_id = p_store_id
    and spl.tenant_id = p_tenant_id
    and spl.check_result = 'TEMP_ALLOWED'
    and spl.is_temp_permission = true
    and spl.temp_expires_at > now();

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_admin_list_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'today_summary', v_denied_summary,
      'role_matrix_summary', v_role_matrix,
      'recent_logs', v_recent_logs,
      'active_temp_permissions',
        v_temp_permissions,
      'feature_codes', jsonb_build_array(
        'VIEW_ORDERS', 'PLACE_ORDER',
        'CANCEL_ORDER', 'PROCESS_REFUND',
        'VIEW_KDS', 'UPDATE_KDS',
        'MANAGE_WAITING', 'VIEW_REPORTS',
        'MANAGE_MENU', 'MANAGE_STAFF',
        'MANAGE_SETTINGS', 'OPEN_CLOSE_STORE',
        'PROCESS_PAYMENT', 'VIEW_INVENTORY',
        'UPDATE_INVENTORY', 'VIEW_MEMBERSHIP',
        'ISSUE_COUPON', 'VAN_NET_CANCEL'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 임시 권한 만료
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'TEMP_PERMISSION_EXPIRE',
  'catchmenu_temp_permission_expire',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
-- 임시 권한 만료 처리
UPDATE catchmenu_store.staff s
SET
  allowed_features = (
    SELECT jsonb_agg(feature)
    FROM jsonb_array_elements_text(
      s.allowed_features
    ) feature
    WHERE NOT EXISTS (
      SELECT 1
      FROM catchmenu_store.staff_permission_logs l
      WHERE l.staff_id = s.id
        AND l.check_result = 'TEMP_ALLOWED'
        AND l.is_temp_permission = true
        AND l.temp_expires_at < now()
        AND l.feature_code = feature
    )
  )
WHERE EXISTS (
  SELECT 1
  FROM catchmenu_store.staff_permission_logs l
  WHERE l.staff_id = s.id
    AND l.check_result = 'TEMP_ALLOWED'
    AND l.is_temp_permission = true
    AND l.temp_expires_at < now()
);
$sql$,
  '임시 권한 만료 처리. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.check_staff_permission(
      uuid, uuid, uuid, text, int, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.grant_temp_permission(
      uuid, uuid, uuid, text, uuid, int, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_permission_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.check_staff_permission(
    uuid, uuid, uuid, text, int, text
  ) is
  '직원 권한 확인 함수.
   모든 민감 기능 실행 전 호출 권장.

   판정 결과:
   ALLOWED: 즉시 실행 가능
   PIN_REQUIRED: PIN 재확인 후 재시도
   MANAGER_REQUIRED: 매니저 PIN 승인 후 재시도
   AMOUNT_EXCEEDED: 금액 한도 초과
   DENIED: 권한 없음

   Flutter 패턴:
   1. check_staff_permission() 호출
   2. is_allowed = false → 결과별 UI
      PIN_REQUIRED → PIN 입력 다이얼로그
      MANAGER_REQUIRED → 매니저 호출
      DENIED → 접근 거부 메시지
   3. is_allowed = true → 기능 실행

   보안:
   DENIED 5회 이상 (10분 내) → 위협 탐지.
   모든 확인 → staff_permission_logs 기록.';