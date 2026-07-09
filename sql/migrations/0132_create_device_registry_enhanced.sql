-- 0132_create_device_registry_enhanced.sql
-- Purpose: Multi-device registry enhancement.
--          디바이스 등록 고도화.
--          1호점 완전 시드 패키지.
--          디바이스 그룹 관리.
--          원격 디바이스 제어.
--          설치 가이드 문서 등록.
-- Depends on: 0131_create_advanced_staff_permission.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('device_registered', 'ko',
  '디바이스가 등록되었습니다'),
('device_registered', 'en',
  'Device registered'),
('device_deactivated', 'ko',
  '디바이스가 비활성화되었습니다'),
('device_deactivated', 'en',
  'Device deactivated'),
('device_command_sent', 'ko',
  '디바이스 명령이 전송되었습니다'),
('device_command_sent', 'en',
  'Device command sent'),
('device_dashboard_loaded', 'ko',
  '디바이스 대시보드가 로드되었습니다'),
('device_dashboard_loaded', 'en',
  'Device dashboard loaded')
on conflict (message_key, locale) do nothing;


-- =============================================
-- device_groups table
-- 디바이스 그룹 관리
-- =============================================
create table if not exists
  catchmenu_store.device_groups (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  group_code text not null,
  group_name text not null,
  group_type text not null,

  -- 그룹 설정
  default_locale text default 'ko',
  auto_update_enabled boolean
    not null default true,
  restart_schedule text,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_device_group unique (
    store_id, group_code
  ),
  constraint chk_group_type check (
    group_type in (
      'STAFF_APP',
      'KDS_DISPLAY',
      'MINI_KIOSK',
      'DID_DISPLAY',
      'CUSTOMER_APP',
      'ADMIN_WEB'
    )
  )
);

alter table catchmenu_store.device_groups
  enable row level security;
alter table catchmenu_store.device_groups
  force row level security;

drop policy if exists device_groups_isolation
  on catchmenu_store.device_groups;
create policy device_groups_isolation
  on catchmenu_store.device_groups
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

-- 1호점 디바이스 그룹 시드
insert into catchmenu_store.device_groups (
  tenant_id, store_id,
  group_code, group_name, group_type,
  default_locale
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'GRP-STAFF', '직원 앱 그룹',
  'STAFF_APP', 'ko'
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'GRP-KDS', 'KDS 디스플레이 그룹',
  'KDS_DISPLAY', 'ko'
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'GRP-KIOSK', '미니 키오스크 그룹',
  'MINI_KIOSK', 'en'
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'GRP-DID', 'DID 디스플레이 그룹',
  'DID_DISPLAY', 'ko'
)
on conflict (store_id, group_code) do nothing;

comment on table catchmenu_store.device_groups is
  '디바이스 그룹 관리.
   1호점 기본 4그룹:
   GRP-STAFF: 직원 앱 (태블릿/폰)
   GRP-KDS: KDS 디스플레이 (주방 태블릿)
   GRP-KIOSK: 미니 키오스크 (외국인 전용)
   GRP-DID: DID 디스플레이 (입구 모니터)
   auto_update_enabled: OTA 업데이트 허용.';


-- =============================================
-- device_commands table
-- 원격 디바이스 명령
-- =============================================
create table if not exists
  catchmenu_store.device_commands (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  device_id uuid,
  group_id uuid
    references catchmenu_store.device_groups(id),

  -- 명령
  command_type text not null,
  command_payload jsonb,

  -- 상태
  command_status text not null
    default 'PENDING',
  issued_by uuid,

  sent_at timestamptz,
  executed_at timestamptz,
  result_payload jsonb,

  expires_at timestamptz not null
    default now() + interval '5 minutes',
  created_at timestamptz not null default now(),

  constraint chk_command_type check (
    command_type in (
      'RESTART_APP',     -- 앱 재시작
      'RELOAD_CONFIG',   -- 설정 재로드
      'CLEAR_CACHE',     -- 캐시 초기화
      'UPDATE_APP',      -- 앱 업데이트
      'CHANGE_LOCALE',   -- 언어 변경
      'FORCE_LOGOUT',    -- 강제 로그아웃
      'SCREEN_OFF',      -- 화면 끄기
      'PING'             -- 헬스체크
    )
  ),
  constraint chk_command_status check (
    command_status in (
      'PENDING', 'SENT',
      'EXECUTED', 'FAILED', 'EXPIRED'
    )
  )
);

alter table catchmenu_store.device_commands
  enable row level security;
alter table catchmenu_store.device_commands
  force row level security;

drop policy if exists device_commands_isolation
  on catchmenu_store.device_commands;
create policy device_commands_isolation
  on catchmenu_store.device_commands
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.device_commands is
  '원격 디바이스 명령.
   Realtime → Flutter 앱 수신.
   RESTART_APP: 앱 강제 재시작.
   RELOAD_CONFIG: 설정 변경 즉시 반영.
   FORCE_LOGOUT: 보안 이슈 시 즉시 로그아웃.
   CHANGE_LOCALE: 외국인 전환 즉시 적용.
   expires_at: 5분 내 미실행 시 EXPIRED.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.register_device_enhanced(
  p_tenant_id uuid,
  p_store_id uuid,
  p_device_type text,
  p_device_name text,
  p_device_fingerprint text,
  p_os_type text default null,
  p_os_version text default null,
  p_app_version text default null,
  p_group_code text default null,
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
  v_device_id uuid;
  v_group_id uuid;
  v_fingerprint_hash text;
  v_is_new boolean;
begin
  -- 핑거프린트 해시
  v_fingerprint_hash := encode(
    digest(p_device_fingerprint, 'sha256'),
    'hex'
  );

  -- 그룹 조회
  if p_group_code is not null then
    select id into v_group_id
    from catchmenu_store.device_groups
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and group_code = p_group_code
      and is_active = true;
  end if;

  -- 기존 디바이스 확인
  select id into v_device_id
  from catchmenu_store.device_registry
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and device_fingerprint_hash =
      v_fingerprint_hash;

  v_is_new := v_device_id is null;

  if v_is_new then
    -- 신규 등록
    insert into catchmenu_store.device_registry (
      tenant_id, store_id,
      device_type, device_name,
      device_fingerprint_hash,
      os_type, os_version, app_version,
      trust_status, registered_at
    ) values (
      p_tenant_id, p_store_id,
      p_device_type, p_device_name,
      v_fingerprint_hash,
      p_os_type, p_os_version, p_app_version,
      'PENDING', now()
    )
    returning id into v_device_id;
  else
    -- 헬스 업데이트
    update catchmenu_store.device_registry
    set
      app_version = coalesce(
        p_app_version, app_version
      ),
      last_seen_at = now(),
      updated_at = now()
    where id = v_device_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'device_registered',
    p_data := jsonb_build_object(
      'device_id', v_device_id,
      'device_type', p_device_type,
      'device_name', p_device_name,
      'is_new', v_is_new,
      'group_id', v_group_id,
      'trust_status', case v_is_new
        when true then 'PENDING'
        else 'TRUSTED'
      end,
      'realtime_channel',
        'device:' || v_device_id
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.send_device_command(
  p_tenant_id uuid,
  p_store_id uuid,
  p_command_type text,
  p_device_id uuid default null,
  p_group_code text default null,
  p_command_payload jsonb default null,
  p_actor_id uuid default null,
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
  v_command_id uuid;
  v_group_id uuid;
begin
  -- 그룹 조회
  if p_group_code is not null then
    select id into v_group_id
    from catchmenu_store.device_groups
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and group_code = p_group_code;
  end if;

  -- 명령 기록
  insert into catchmenu_store.device_commands (
    tenant_id, store_id,
    device_id, group_id,
    command_type, command_payload,
    issued_by, command_status
  ) values (
    p_tenant_id, p_store_id,
    p_device_id, v_group_id,
    p_command_type, p_command_payload,
    p_actor_id, 'PENDING'
  )
  returning id into v_command_id;

  -- Realtime → 디바이스 전송
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'device_command',
    p_payload := jsonb_build_object(
      'command_id', v_command_id,
      'command_type', p_command_type,
      'device_id', p_device_id,
      'group_code', p_group_code,
      'payload', p_command_payload
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'device_command_sent',
    p_data := jsonb_build_object(
      'command_id', v_command_id,
      'command_type', p_command_type,
      'device_id', p_device_id,
      'group_code', p_group_code,
      'expires_at',
        now() + interval '5 minutes'
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_device_dashboard(
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
  v_device_list jsonb;
  v_group_summary jsonb;
  v_pending_commands jsonb;
  v_device_summary jsonb;
begin
  -- 디바이스 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'device_id', dr.id,
        'device_type', dr.device_type,
        'device_name', dr.device_name,
        'os_type', dr.os_type,
        'app_version', dr.app_version,
        'trust_status', dr.trust_status,
        'is_online', coalesce(
          dr.last_seen_at
            > now() - interval '5 minutes',
          false
        ),
        'last_seen_at', dr.last_seen_at,
        'registered_at', dr.registered_at
      )
      order by dr.device_type,
               dr.registered_at desc
    ),
    '[]'::jsonb
  )
  into v_device_list
  from catchmenu_store.device_registry dr
  where dr.store_id = p_store_id
    and dr.tenant_id = p_tenant_id
    and dr.trust_status <> 'REVOKED';

  -- 그룹 요약
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'group_id', dg.id,
        'group_code', dg.group_code,
        'group_name', dg.group_name,
        'group_type', dg.group_type,
        'default_locale', dg.default_locale,
        'is_active', dg.is_active
      )
    ),
    '[]'::jsonb
  )
  into v_group_summary
  from catchmenu_store.device_groups dg
  where dg.store_id = p_store_id
    and dg.tenant_id = p_tenant_id;

  -- 전체 요약
  select jsonb_build_object(
    'total', count(*),
    'online', count(*) filter (
      where last_seen_at
        > now() - interval '5 minutes'
    ),
    'trusted', count(*) filter (
      where trust_status = 'TRUSTED'
    ),
    'pending', count(*) filter (
      where trust_status = 'PENDING'
    ),
    'by_type', (
      select coalesce(
        jsonb_object_agg(
          device_type, cnt
        ),
        '{}'::jsonb
      )
      from (
        select device_type,
               count(*)::int as cnt
        from catchmenu_store.device_registry
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and trust_status <> 'REVOKED'
        group by device_type
      ) t
    )
  )
  into v_device_summary
  from catchmenu_store.device_registry
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and trust_status <> 'REVOKED';

  -- 대기 중인 명령
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'command_id', id,
        'command_type', command_type,
        'device_id', device_id,
        'command_status', command_status,
        'expires_at', expires_at,
        'created_at', created_at
      )
      order by created_at desc
    ),
    '[]'::jsonb
  )
  into v_pending_commands
  from catchmenu_store.device_commands
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and command_status = 'PENDING'
    and expires_at > now();

  return catchmenu_common.build_success_response(
    p_message_key := 'device_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'device_summary', v_device_summary,
      'devices', v_device_list,
      'groups', v_group_summary,
      'pending_commands', v_pending_commands,
      '1st_store_setup', jsonb_build_object(
        'step1',
          '직원 앱 설치 → register_device_enhanced(STAFF_APP)',
        'step2',
          'KDS 태블릿 설치 → register_device_enhanced(KDS_DISPLAY)',
        'step3',
          '키오스크 설치 → register_device_enhanced(MINI_KIOSK)',
        'step4',
          'DID 연결 → register_device_enhanced(DID_DISPLAY)',
        'step5',
          '각 앱 bootstrap RPC 호출',
        'step6',
          'run_opening_checklist() 최종 확인'
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- 1호점 완전 시드 패키지
-- =============================================
do $$
declare
  v_tenant_id uuid :=
    '00000000-0000-0000-0000-000000000001';
  v_store_id uuid :=
    '00000000-0000-0000-0000-000000000002';
begin
  -- 매장 설정 확인/업데이트
  update catchmenu_store.store_settings
  set
    store_mode = 'NORMAL',
    waiting_enabled = true,
    pre_order_enabled = true,
    max_wait_number = 30,
    kds_capacity_threshold_total = 30,
    did_refresh_interval_seconds = 5,
    updated_at = now()
  where store_id = v_store_id
    and tenant_id = v_tenant_id;

  -- 영업시간 기본값 (월~금 09:00~21:00)
  insert into catchmenu_store.store_business_hours (
    tenant_id, store_id,
    day_of_week, is_open,
    open_time, close_time,
    last_order_time
  )
  select
    v_tenant_id, v_store_id,
    dow, true,
    '09:00'::time, '21:00'::time,
    '20:30'::time
  from generate_series(1, 5) as dow
  on conflict (store_id, day_of_week)
  do nothing;

  -- 토요일 (단축)
  insert into catchmenu_store.store_business_hours (
    tenant_id, store_id,
    day_of_week, is_open,
    open_time, close_time,
    last_order_time
  ) values (
    v_tenant_id, v_store_id,
    6, true,
    '10:00', '18:00', '17:30'
  )
  on conflict (store_id, day_of_week) do nothing;

  -- 일요일 (휴무)
  insert into catchmenu_store.store_business_hours (
    tenant_id, store_id,
    day_of_week, is_open
  ) values (
    v_tenant_id, v_store_id,
    0, false
  )
  on conflict (store_id, day_of_week) do nothing;

  -- 멤버십 기본 설정 (STAMP 모드)
  insert into catchmenu_store.membership_configs (
    tenant_id, store_id,
    membership_mode, stamp_enabled,
    stamp_goal, point_earn_rate,
    tier_enabled, transfer_fail_policy
  ) values (
    v_tenant_id, v_store_id,
    'STAMP', true, 10, 1.0,
    true, 'HOLD_INTERNAL'
  )
  on conflict (store_id) do nothing;

  -- 지식 문서: 설치 가이드
  insert into catchmenu_knowledge.documents (
    tenant_id, store_id,
    document_code, title,
    document_type, domain,
    content, content_locale,
    document_status, approved_at, published_at
  ) values (
    v_tenant_id, null,
    'INSTALL_GUIDE_001_KO',
    '1호점 설치 및 초기 설정 가이드',
    'GUIDE', 'operation',
    $ko$
# 1호점 설치 및 초기 설정 가이드

## 1. 필요 기기 목록

| 기기 | 용도 | 수량 |
|------|------|------|
| 태블릿 (10인치+) | 직원 앱 | 1~2대 |
| 태블릿 (주방용) | KDS 디스플레이 | 1대 |
| 태블릿 (입구) | 미니 키오스크 | 1대 |
| 모니터/TV | DID 디스플레이 | 1대 |
| Android TV Stick | DID 연결 | 1개 |

## 2. Flutter 앱 설치 순서

1. 직원 앱 설치
   - register_device_enhanced(STAFF_APP)
   - bootstrap_staff_app() 실행
   - 직원 로그인 테스트

2. KDS 앱 설치 (주방)
   - register_device_enhanced(KDS_DISPLAY)
   - get_kds_realtime_state() 실행
   - Realtime kds:{store_id} 구독 확인

3. 미니 키오스크 설치 (입구)
   - register_device_enhanced(MINI_KIOSK)
   - bootstrap_kiosk(KIOSK-01) 실행
   - 외국인 언어 전환 테스트

4. DID 설치 (입구 모니터)
   - register_device_enhanced(DID_DISPLAY)
   - bootstrap_did_app(DID-01) 실행
   - 대기 호출 테스트

## 3. 오픈 전 체크리스트

run_opening_checklist() 실행 후
READY 판정 확인 필수.

FAIL 항목:
  알레르겐 미등록 → 식품위생법 위반
  직원 미등록 → 운영 불가

## 4. 특허 기능 테스트

특허1 테스트:
  register_waiting() → call_waiting_customer()
  → pre_order_while_waiting() → seat_waiting_customer()
  → confirm_payment() → KDS COMMITTED 확인

특허2 테스트:
  주문 후 KDS = HOLD 확인
  결제 후 KDS = COMMITTED 확인
  "착석 즉시 음식" 경험 확인

## 5. Edge Function 확인

P1 필수:
  okpos-order-send: OKpos 주문 전송
  toss-payments-confirm: 결제 확인
  okpos-heartbeat: 연결 상태

미구현 시:
  수동 VAN 단말기 결제 병행 운영 가능
  RECORD_MANUAL_PAYMENT 오프라인 큐 활용
$ko$,
    'ko',
    'PUBLISHED', now(), current_date
  ),
  (
    v_tenant_id, null,
    'INSTALL_GUIDE_001_EN',
    '1호점 설치 및 초기 설정 가이드',
    'GUIDE', 'operation',
    $en$
# First Store Installation Guide
See Korean version for full guide.
$en$,
    'en',
    'PUBLISHED', now(), current_date
  )
  on conflict (tenant_id, document_code)
  do update set
    content = excluded.content;

end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.register_device_enhanced(
      uuid, uuid, text, text, text,
      text, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.send_device_command(
      uuid, uuid, text, uuid, text,
      jsonb, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_device_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

-- pg_cron: 디바이스 명령 만료
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'DEVICE_CMD_EXPIRE',
  'catchmenu_device_cmd_expire',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
UPDATE catchmenu_store.device_commands
SET command_status = 'EXPIRED'
WHERE command_status = 'PENDING'
  AND expires_at < now();
$sql$,
  '디바이스 명령 만료 처리. 5분마다.',
  true
)
on conflict (job_code) do nothing;

comment on function
  catchmenu_store.send_device_command(
    uuid, uuid, text, uuid, text, jsonb, uuid, text
  ) is
  '원격 디바이스 명령 전송.
   Realtime으로 Flutter 앱에 즉시 전달.

   RESTART_APP: 앱 강제 재시작.
     → KDS/키오스크 장애 시 원격 재시작.
   RELOAD_CONFIG: 메뉴/설정 변경 즉시 반영.
   FORCE_LOGOUT: 보안 이슈 시 강제 로그아웃.
   CHANGE_LOCALE: 외국인 고객 언어 즉시 전환.
   PING: 디바이스 온라인 확인.

   그룹 명령:
   p_group_code = GRP-KIOSK
   → 키오스크 전체에 동시 전달.

   Flutter 수신:
   supabase.channel(store:{store_id})
   .onBroadcast(event: device_command)
   → command_type 기반 처리.';