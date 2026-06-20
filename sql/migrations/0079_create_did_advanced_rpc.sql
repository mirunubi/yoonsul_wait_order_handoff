-- 0079_create_did_advanced_rpc.sql
-- Purpose: DID display advanced management RPCs.
--          Customer pickup call, waiting display,
--          multi-zone DID management,
--          DID content scheduling (CMS basic).
--          1-B차 DID/CMS 고도화 기반.
-- Depends on: 0078_create_delivery_sync_rpc.sql
-- Creates:
--   catchmenu_store.did_devices (table)
--   catchmenu_store.did_display_queue (table)
--   catchmenu_store.did_content_schedule (table)
--   function catchmenu_store.register_did_device(...)
--   function catchmenu_store.call_customer_pickup(...)
--   function catchmenu_store.get_did_waiting_display(...)
--   function catchmenu_store.push_did_content(...)
--   function catchmenu_store.get_did_zone_state(...)
--   function catchmenu_store.dismiss_did_call(...)

-- =============================================
-- did_devices table
-- DID 디스플레이 디바이스 등록
-- =============================================
create table if not exists
  catchmenu_store.did_devices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 디바이스 정보
  device_id uuid
    references catchmenu_store.device_registry(id),
  did_code text not null,
  did_name text not null,

  -- 설치 위치
  zone text not null default 'MAIN',
  location_description text,

  -- 표시 설정
  display_mode text not null default 'WAITING',
  orientation text not null default 'LANDSCAPE',
  resolution text default '1920x1080',
  refresh_interval_seconds int
    not null default 10,

  -- 호출 설정
  call_sound_enabled boolean
    not null default true,
  call_repeat_count int not null default 3,
  call_interval_seconds int not null default 5,
  call_display_seconds int not null default 30,

  -- 현재 상태
  is_online boolean not null default false,
  last_ping_at timestamptz,
  current_content_id uuid,
  brightness int not null default 80,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_did_code unique (
    store_id, did_code
  ),
  constraint chk_did_zone check (
    zone in (
      'MAIN', 'ENTRANCE', 'COUNTER',
      'KITCHEN', 'WAITING_AREA',
      'PICKUP_COUNTER', 'OUTDOOR', 'CUSTOM'
    )
  ),
  constraint chk_display_mode check (
    display_mode in (
      'WAITING',        -- 대기번호 표시
      'PICKUP',         -- 픽업 호출
      'MENU',           -- 메뉴 표시
      'PROMOTION',      -- 프로모션
      'MIXED',          -- 혼합
      'SLIDESHOW'       -- 슬라이드쇼
    )
  ),
  constraint chk_orientation check (
    orientation in ('LANDSCAPE', 'PORTRAIT')
  )
);

create index if not exists idx_did_devices_store
  on catchmenu_store.did_devices(
    store_id, zone, is_active
  ) where is_active = true;

alter table catchmenu_store.did_devices
  enable row level security;
alter table catchmenu_store.did_devices
  force row level security;

drop policy if exists did_devices_isolation
  on catchmenu_store.did_devices;
create policy did_devices_isolation
  on catchmenu_store.did_devices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_devices_updated
  on catchmenu_store.did_devices;
create trigger trg_did_devices_updated
  before update on catchmenu_store.did_devices
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.did_devices is
  'DID 디스플레이 디바이스 등록.
   zone: 설치 위치 (메인/입구/카운터 등).
   display_mode:
     WAITING: 대기번호 + 호출 표시
     PICKUP: 포장 픽업 호출 전용
     MENU: 메뉴판 표시 (영업 중)
     MIXED: 대기 + 메뉴 혼합
   call_display_seconds: 호출 표시 유지 시간.
   1-B차 DID/CMS 고도화 핵심 테이블.
   특허1: DID = 고객 안내 출력 채널.';


-- seed DID devices
insert into catchmenu_store.did_devices (
  tenant_id, store_id,
  did_code, did_name, zone,
  display_mode, orientation,
  refresh_interval_seconds,
  call_sound_enabled, call_repeat_count
) values
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DID_MAIN_01', '메인 DID', 'MAIN',
  'MIXED', 'LANDSCAPE', 10, true, 3
),
(
  '00000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000002',
  'DID_PICKUP_01', '픽업 카운터 DID',
  'PICKUP_COUNTER',
  'PICKUP', 'LANDSCAPE', 5, true, 5
)
on conflict (store_id, did_code) do nothing;


-- =============================================
-- did_display_queue table
-- DID 표시 큐 (호출/픽업 알림)
-- =============================================
create table if not exists
  catchmenu_store.did_display_queue (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 대상 DID
  did_device_id uuid
    references catchmenu_store.did_devices(id),
  did_zone text not null default 'MAIN',

  -- 큐 항목
  queue_type text not null,
  priority int not null default 5,

  -- 연결 주문/세션
  order_id uuid,
  session_id uuid,
  order_number text,
  wait_number int,

  -- 표시 내용
  display_number text not null,
  display_message jsonb not null
    default '{}'::jsonb,
  display_locale text not null default 'ko',

  -- 호출 설정
  call_count int not null default 0,
  max_call_count int not null default 3,
  last_called_at timestamptz,
  next_call_at timestamptz,

  -- 상태
  queue_status text not null default 'PENDING',
  displayed_at timestamptz,
  dismissed_at timestamptz,
  dismissed_by_type text,
  auto_dismiss_at timestamptz,

  business_day date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_queue_type check (
    queue_type in (
      'WAITING_CALL',   -- 대기 호출
      'PICKUP_READY',   -- 포장 픽업 준비
      'TABLE_READY',    -- 테이블 착석 안내
      'DELIVERY_READY', -- 배달 픽업 준비
      'CUSTOM_MESSAGE'  -- 커스텀 메시지
    )
  ),
  constraint chk_queue_status check (
    queue_status in (
      'PENDING', 'DISPLAYING',
      'DISMISSED', 'EXPIRED', 'CANCELLED'
    )
  )
);

create index if not exists idx_did_queue_store
  on catchmenu_store.did_display_queue(
    store_id, queue_status, priority desc
  ) where queue_status in (
    'PENDING', 'DISPLAYING'
  );
create index if not exists idx_did_queue_order
  on catchmenu_store.did_display_queue(
    order_id
  ) where order_id is not null;
create index if not exists idx_did_queue_session
  on catchmenu_store.did_display_queue(
    session_id
  ) where session_id is not null;

alter table catchmenu_store.did_display_queue
  enable row level security;
alter table catchmenu_store.did_display_queue
  force row level security;

drop policy if exists did_queue_isolation
  on catchmenu_store.did_display_queue;
create policy did_queue_isolation
  on catchmenu_store.did_display_queue
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_queue_updated
  on catchmenu_store.did_display_queue;
create trigger trg_did_queue_updated
  before update on catchmenu_store.did_display_queue
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.did_display_queue is
  'DID 표시 큐.
   priority: 숫자 낮을수록 높은 우선순위.
   WAITING_CALL: 대기번호 호출 (1번 먼저).
   PICKUP_READY: 포장 완료 픽업 호출.
   TABLE_READY: 착석 가능 안내.
   call_count: 호출 횟수 (max_call_count까지).
   auto_dismiss_at: 자동 해제 시각.
   특허1: DID 표시 = 고객 안내 증빙.';


-- =============================================
-- did_content_schedule table
-- DID 콘텐츠 스케줄 (CMS 기초)
-- =============================================
create table if not exists
  catchmenu_store.did_content_schedule (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  did_device_id uuid
    references catchmenu_store.did_devices(id),

  -- 콘텐츠 정보
  content_code text not null,
  content_name text not null,
  content_type text not null,

  -- 콘텐츠 데이터
  content_data jsonb not null
    default '{}'::jsonb,
  image_url text,
  video_url text,

  -- 표시 설정
  display_order int not null default 0,
  display_duration_seconds int
    not null default 10,

  -- 스케줄
  schedule_type text not null default 'ALWAYS',
  schedule_days jsonb,
  schedule_start_time time,
  schedule_end_time time,
  valid_from date,
  valid_until date,

  -- 조건부 표시
  show_when_waiting boolean
    not null default true,
  show_when_idle boolean not null default true,
  hide_during_call boolean not null default false,

  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_did_content unique (
    store_id, did_device_id, content_code
  ),
  constraint chk_content_type check (
    content_type in (
      'MENU_BOARD',     -- 메뉴판
      'PROMOTION',      -- 프로모션 이미지
      'NOTICE',         -- 공지사항
      'WAITING_INFO',   -- 대기 안내
      'WEATHER',        -- 날씨 (외부 API)
      'CUSTOM_HTML',    -- 커스텀 HTML
      'VIDEO'           -- 영상
    )
  ),
  constraint chk_schedule_type check (
    schedule_type in (
      'ALWAYS', 'TIME_RANGE',
      'DAYS_OF_WEEK', 'DATE_RANGE'
    )
  )
);

create index if not exists idx_did_content_store
  on catchmenu_store.did_content_schedule(
    store_id, display_order
  ) where is_active = true;

alter table catchmenu_store.did_content_schedule
  enable row level security;
alter table catchmenu_store.did_content_schedule
  force row level security;

drop policy if exists did_content_isolation
  on catchmenu_store.did_content_schedule;
create policy did_content_isolation
  on catchmenu_store.did_content_schedule
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_did_content_updated
  on catchmenu_store.did_content_schedule;
create trigger trg_did_content_updated
  before update on
    catchmenu_store.did_content_schedule
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.did_content_schedule is
  'DID 콘텐츠 스케줄 (CMS 기초).
   1-B차 CMS 메뉴/콘텐츠 관리 기반.
   content_type:
     MENU_BOARD: 메뉴판 자동 표시
     PROMOTION: 이미지 프로모션
     WAITING_INFO: 현재 대기 인원 표시
   hide_during_call: 호출 중 콘텐츠 숨김.
   schedule_type ALWAYS: 항상 표시.
   특허1: DID 콘텐츠 = 고객 안내 채널.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.register_did_device(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text,
  p_did_name text,
  p_zone text default 'MAIN',
  p_display_mode text default 'MIXED',
  p_device_id uuid default null,
  p_refresh_interval_seconds int default 10,
  p_call_sound_enabled boolean default true,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_did_id uuid;
  v_is_new boolean;
begin
  v_is_new := not exists (
    select 1 from catchmenu_store.did_devices
    where store_id = p_store_id
      and did_code = p_did_code
  );

  insert into catchmenu_store.did_devices (
    tenant_id, store_id,
    device_id, did_code, did_name, zone,
    display_mode,
    refresh_interval_seconds,
    call_sound_enabled
  ) values (
    p_tenant_id, p_store_id,
    p_device_id, p_did_code, p_did_name,
    p_zone, p_display_mode,
    p_refresh_interval_seconds,
    p_call_sound_enabled
  )
  on conflict (store_id, did_code) do update set
    did_name = excluded.did_name,
    zone = excluded.zone,
    display_mode = excluded.display_mode,
    device_id = coalesce(
      excluded.device_id,
      catchmenu_store.did_devices.device_id
    ),
    refresh_interval_seconds =
      excluded.refresh_interval_seconds,
    call_sound_enabled =
      excluded.call_sound_enabled,
    is_active = true,
    updated_at = now()
  returning id into v_did_id;

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
    'store', 'did_device_registered', 1,
    'did_device', v_did_id,
    null, 'ACTIVE',
    'SYSTEM',
    jsonb_build_object(
      'did_code', p_did_code,
      'zone', p_zone,
      'display_mode', p_display_mode,
      'is_new', v_is_new
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'did_id', v_did_id,
    'did_code', p_did_code,
    'zone', p_zone,
    'display_mode', p_display_mode,
    'is_new', v_is_new,
    'message_code', 'did_device_registered'
  );
end;
$$;


create or replace function
  catchmenu_store.call_customer_pickup(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_queue_type text default 'PICKUP_READY',
  p_target_zone text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_order record;
  v_did_device record;
  v_queue_id uuid;
  v_display_number text;
  v_display_message jsonb;
  v_auto_dismiss_at timestamptz;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.order_status, o.final_amount,
         o.session_id,
         os.wait_number
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
      p_rpc_name := 'call_customer_pickup'
    );
  end if;

  -- 표시 번호 결정
  v_display_number := coalesce(
    v_order.order_number,
    v_order.wait_number::text,
    v_order.id::text
  );

  -- DID 대상 결정
  select id, did_code, call_display_seconds,
         call_repeat_count, call_interval_seconds
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and (
      p_target_zone is null
      or zone = p_target_zone
      or (
        p_target_zone is null
        and display_mode in ('PICKUP', 'MIXED')
      )
    )
  order by
    case display_mode
      when 'PICKUP' then 0
      when 'MIXED' then 1
      else 2
    end
  limit 1;

  -- i18n 표시 메시지
  v_display_message := jsonb_build_object(
    'ko', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then '포장 준비 완료'
        when 'DELIVERY_READY' then '배달 픽업 준비'
        when 'TABLE_READY' then '자리 안내'
        when 'WAITING_CALL' then '대기 호출'
        else '호출'
      end,
      'body',
        v_display_number || '번 '
        || case p_queue_type
          when 'PICKUP_READY'
            then '포장 준비되었습니다. 카운터로 와주세요.'
          when 'TABLE_READY'
            then '자리가 준비되었습니다.'
          when 'WAITING_CALL'
            then '입장해 주세요.'
          else '준비되었습니다.'
        end
    ),
    'en', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then 'Order Ready'
        when 'TABLE_READY' then 'Table Ready'
        when 'WAITING_CALL' then 'Now Calling'
        else 'Ready'
      end,
      'body',
        'Order #' || v_display_number
        || case p_queue_type
          when 'PICKUP_READY'
            then ' is ready for pickup.'
          when 'TABLE_READY'
            then ' your table is ready.'
          when 'WAITING_CALL'
            then ' please come in.'
          else ' is ready.'
        end
    ),
    'zh', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY' then '取餐准备好了'
        when 'TABLE_READY' then '座位准备好了'
        else '准备好了'
      end,
      'body',
        v_display_number || '号'
        || case p_queue_type
          when 'PICKUP_READY'
            then '，请到柜台取餐'
          when 'TABLE_READY'
            then '，请就座'
          else '，请到柜台'
        end
    ),
    'ja', jsonb_build_object(
      'title', case p_queue_type
        when 'PICKUP_READY'
          then 'お持ち帰りのご準備ができました'
        when 'TABLE_READY'
          then 'お席のご準備ができました'
        else 'ご準備ができました'
      end,
      'body',
        v_display_number || '番'
        || case p_queue_type
          when 'PICKUP_READY'
            then 'のお客様、カウンターへどうぞ'
          when 'TABLE_READY'
            then 'のお客様、お席へどうぞ'
          else 'のお客様、どうぞ'
        end
    )
  );

  -- 자동 해제 시각
  v_auto_dismiss_at := now() + interval '1 second'
    * coalesce(
      v_did_device.call_display_seconds, 30
    );

  -- DID 큐 추가
  insert into catchmenu_store.did_display_queue (
    tenant_id, store_id,
    did_device_id, did_zone,
    queue_type, priority,
    order_id, session_id,
    order_number, wait_number,
    display_number, display_message,
    display_locale,
    max_call_count,
    next_call_at,
    queue_status,
    auto_dismiss_at,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    v_did_device.id,
    coalesce(p_target_zone, 'MAIN'),
    p_queue_type,
    case p_queue_type
      when 'WAITING_CALL' then 1
      when 'TABLE_READY' then 2
      when 'PICKUP_READY' then 3
      else 5
    end,
    p_order_id, v_order.session_id,
    v_order.order_number, v_order.wait_number,
    v_display_number, v_display_message,
    p_locale,
    coalesce(
      v_did_device.call_repeat_count, 3
    ),
    now(),
    'DISPLAYING',
    v_auto_dismiss_at,
    v_business_day
  )
  returning id into v_queue_id;

  -- Realtime broadcast → DID Flutter 앱
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := p_queue_type,
    p_payload := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'display_message', v_display_message,
      'locale', p_locale,
      'did_zone', coalesce(
        p_target_zone, 'MAIN'
      ),
      'auto_dismiss_at', v_auto_dismiss_at,
      'called_at', now()
    )
  );

  -- 주문 상태 업데이트
  -- PICKUP_READY → 픽업 대기 중
  if p_queue_type = 'PICKUP_READY'
    and v_order.order_status
      not in ('COMPLETED', 'CANCELLED')
  then
    update catchmenu_pos.orders
    set
      order_status = 'READY',
      ready_at = coalesce(ready_at, now()),
      updated_at = now()
    where id = p_order_id
      and order_status not in (
        'READY', 'PICKED_UP',
        'COMPLETED', 'CANCELLED'
      );
  end if;

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
    'store', 'did_customer_called', 1,
    'did_queue', v_queue_id,
    null, 'DISPLAYING',
    'SYSTEM',
    jsonb_build_object(
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        v_did_device.did_code,
      'locale', p_locale
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_ready',
    p_data := jsonb_build_object(
      'queue_id', v_queue_id,
      'queue_type', p_queue_type,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'display_number', v_display_number,
      'did_device_code',
        coalesce(v_did_device.did_code, 'N/A'),
      'auto_dismiss_at', v_auto_dismiss_at,
      'display_message', v_display_message
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'order_number', v_display_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_waiting_display(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_business_day date;
  v_timezone text;
  v_waiting_list jsonb;
  v_active_calls jsonb;
  v_store_settings record;
  v_did_device record;
begin
  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_did_waiting_display'
    );
  end if;

  v_timezone := v_store.timezone;
  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- DID 디바이스 정보
  select id, did_code, zone, display_mode,
         refresh_interval_seconds,
         call_sound_enabled
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and (
      p_did_code is null
      or did_code = p_did_code
    )
  order by
    case display_mode
      when 'WAITING' then 0
      when 'MIXED' then 1
      else 2
    end
  limit 1;

  -- 매장 설정
  select store_mode, waiting_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 현재 대기 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'wait_number', wait_number,
        'session_status', session_status,
        'guest_count', guest_count,
        'queue_position', queue_position,
        'waited_minutes', extract(
          epoch from (
            now() - session_started_at
          )
        )::int / 60
      )
      order by queue_position nulls last,
               wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 현재 표시 중인 호출
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'queue_id', id,
        'queue_type', queue_type,
        'display_number', display_number,
        'display_message',
          display_message->p_locale,
        'call_count', call_count,
        'max_call_count', max_call_count,
        'auto_dismiss_at', auto_dismiss_at,
        'displayed_at', displayed_at
      )
      order by priority asc,
               created_at asc
    ),
    '[]'::jsonb
  )
  into v_active_calls
  from catchmenu_store.did_display_queue
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
    and (
      auto_dismiss_at is null
      or auto_dismiss_at > now()
    )
    and (
      v_did_device.id is null
      or did_device_id = v_did_device.id
    );

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name,
      'store_mode', coalesce(
        v_store_settings.store_mode, 'NORMAL'
      ),
      'waiting_enabled', coalesce(
        v_store_settings.waiting_enabled, true
      )
    ),
    'did_device', case
      when v_did_device.id is not null
      then jsonb_build_object(
        'id', v_did_device.id,
        'did_code', v_did_device.did_code,
        'zone', v_did_device.zone,
        'display_mode', v_did_device.display_mode,
        'refresh_interval_seconds',
          v_did_device.refresh_interval_seconds,
        'call_sound_enabled',
          v_did_device.call_sound_enabled
      )
      else null
    end,
    'business_day', v_business_day,
    'locale', p_locale,
    'waiting_queue', jsonb_build_object(
      'total_waiting',
        jsonb_array_length(v_waiting_list),
      'sessions', v_waiting_list
    ),
    'active_calls', v_active_calls,
    'active_call_count',
      jsonb_array_length(v_active_calls),
    'has_active_calls',
      jsonb_array_length(v_active_calls) > 0,
    'refresh_interval_seconds', coalesce(
      v_did_device.refresh_interval_seconds, 10
    ),
    'generated_at', now(),
    'message_code', 'did_display_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_zone_state(
  p_tenant_id uuid,
  p_store_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_zones jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'did_id', d.id,
        'did_code', d.did_code,
        'did_name', d.did_name,
        'zone', d.zone,
        'display_mode', d.display_mode,
        'is_online', d.is_online,
        'last_ping_at', d.last_ping_at,
        'minutes_since_ping', case
          when d.last_ping_at is not null
          then extract(epoch from (
            now() - d.last_ping_at
          ))::int / 60
          else null
        end,
        'is_stale',
          d.last_ping_at is null
          or d.last_ping_at
            < now() - interval '2 minutes',
        'active_call_count', (
          select count(*)
          from catchmenu_store.did_display_queue q
          where q.did_device_id = d.id
            and q.queue_status = 'DISPLAYING'
            and (
              q.auto_dismiss_at is null
              or q.auto_dismiss_at > now()
            )
        ),
        'today_call_count', (
          select count(*)
          from catchmenu_store.did_display_queue q
          where q.did_device_id = d.id
            and q.business_day = v_business_day
        )
      )
      order by
        case d.zone
          when 'MAIN' then 0
          when 'ENTRANCE' then 1
          when 'COUNTER' then 2
          when 'PICKUP_COUNTER' then 3
          else 9
        end
    ),
    '[]'::jsonb
  )
  into v_zones
  from catchmenu_store.did_devices d
  where d.store_id = p_store_id
    and d.tenant_id = p_tenant_id
    and d.is_active = true;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'did_devices', v_zones,
    'total_count', jsonb_array_length(v_zones),
    'online_count', (
      select count(*)
      from jsonb_array_elements(v_zones) z
      where (z->>'is_online')::boolean = true
    ),
    'stale_count', (
      select count(*)
      from jsonb_array_elements(v_zones) z
      where (z->>'is_stale')::boolean = true
    ),
    'checked_at', now(),
    'message_code', 'did_zone_state_loaded'
  );
end;
$$;


create or replace function
  catchmenu_store.dismiss_did_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_queue_id uuid,
  p_dismissed_by_type text default 'STAFF',
  p_dismissed_by_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_queue record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, queue_type, display_number,
         order_id, queue_status
  into v_queue
  from catchmenu_store.did_display_queue
  where id = p_queue_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_queue.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'dismiss_did_call'
    );
  end if;

  if v_queue.queue_status not in (
    'PENDING', 'DISPLAYING'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'call_already_dismissed',
      'current_status', v_queue.queue_status
    );
  end if;

  -- 큐 해제
  update catchmenu_store.did_display_queue
  set
    queue_status = 'DISMISSED',
    dismissed_at = now(),
    dismissed_by_type = p_dismissed_by_type,
    updated_at = now()
  where id = p_queue_id;

  -- Realtime → DID 해제 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_by', p_dismissed_by_type,
      'dismissed_at', now()
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, order_id,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'store', 'did_call_dismissed', 1,
    'did_queue', p_queue_id,
    'DISPLAYING', 'DISMISSED',
    p_dismissed_by_type, p_dismissed_by_id,
    jsonb_build_object(
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number
    ),
    v_queue.order_id, p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_cancelled',
    p_data := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_store.push_did_content(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_device_id uuid,
  p_content_code text,
  p_content_name text,
  p_content_type text,
  p_content_data jsonb,
  p_display_duration_seconds int default 10,
  p_display_order int default 0,
  p_show_when_waiting boolean default true,
  p_hide_during_call boolean default false,
  p_valid_from date default null,
  p_valid_until date default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_content_id uuid;
  v_is_new boolean;
begin
  v_is_new := not exists (
    select 1
    from catchmenu_store.did_content_schedule
    where store_id = p_store_id
      and did_device_id = p_did_device_id
      and content_code = p_content_code
  );

  insert into catchmenu_store.did_content_schedule (
    tenant_id, store_id, did_device_id,
    content_code, content_name, content_type,
    content_data,
    display_order, display_duration_seconds,
    schedule_type,
    show_when_waiting, show_when_idle,
    hide_during_call,
    valid_from, valid_until
  ) values (
    p_tenant_id, p_store_id, p_did_device_id,
    p_content_code, p_content_name, p_content_type,
    p_content_data,
    p_display_order, p_display_duration_seconds,
    case
      when p_valid_from is not null
        or p_valid_until is not null
        then 'DATE_RANGE'
      else 'ALWAYS'
    end,
    p_show_when_waiting, true,
    p_hide_during_call,
    p_valid_from, p_valid_until
  )
  on conflict (store_id, did_device_id, content_code)
  do update set
    content_name = excluded.content_name,
    content_type = excluded.content_type,
    content_data = excluded.content_data,
    display_order = excluded.display_order,
    display_duration_seconds =
      excluded.display_duration_seconds,
    show_when_waiting = excluded.show_when_waiting,
    hide_during_call = excluded.hide_during_call,
    valid_from = excluded.valid_from,
    valid_until = excluded.valid_until,
    is_active = true,
    updated_at = now()
  returning id into v_content_id;

  -- Realtime → DID 콘텐츠 업데이트 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'content_updated',
    p_payload := jsonb_build_object(
      'content_id', v_content_id,
      'did_device_id', p_did_device_id,
      'content_code', p_content_code,
      'content_type', p_content_type,
      'is_new', v_is_new
    )
  );

  return jsonb_build_object(
    'success', true,
    'content_id', v_content_id,
    'content_code', p_content_code,
    'content_type', p_content_type,
    'is_new', v_is_new,
    'message_code', 'did_content_pushed'
  );
end;
$$;


-- pg_cron: DID 큐 자동 해제 (만료된 호출)
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes
) values
(
  'DID_QUEUE_CLEANUP',
  'catchmenu_did_queue_cleanup',
  '*/1 * * * *',
  '*/1 * * * * (1분마다)',
  $sql$
UPDATE catchmenu_store.did_display_queue
SET
  queue_status = 'EXPIRED',
  dismissed_at = now(),
  dismissed_by_type = 'SYSTEM',
  updated_at = now()
WHERE queue_status = 'DISPLAYING'
  AND auto_dismiss_at < now();
$sql$,
  'DID 호출 만료 자동 해제. 1분마다.'
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_store.register_did_device(
      uuid, uuid, text, text, text, text,
      uuid, int, boolean, text
    ) from public;
  grant execute on function
    catchmenu_store.register_did_device(
      uuid, uuid, text, text, text, text,
      uuid, int, boolean, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.call_customer_pickup(
      uuid, uuid, uuid, text, text, text, text
    ) from public;
  grant execute on function
    catchmenu_store.call_customer_pickup(
      uuid, uuid, uuid, text, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_did_waiting_display(
      uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.get_did_waiting_display(
      uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.get_did_zone_state(uuid, uuid)
    from public;
  grant execute on function
    catchmenu_store.get_did_zone_state(uuid, uuid)
    to authenticated;

  revoke all on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_store.push_did_content(
      uuid, uuid, uuid, text, text, text,
      jsonb, int, int, boolean, boolean,
      date, date, text
    ) from public;
  grant execute on function
    catchmenu_store.push_did_content(
      uuid, uuid, uuid, text, text, text,
      jsonb, int, int, boolean, boolean,
      date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.call_customer_pickup(
    uuid, uuid, uuid, text, text, text, text
  ) is
  '고객 픽업 호출 → DID 표시 + Realtime broadcast.
   queue_type:
     PICKUP_READY: 포장 완료 픽업 호출
     TABLE_READY: 테이블 착석 안내
     WAITING_CALL: 대기 호출
   i18n 메시지: ko/en/zh/ja 자동 생성.
   Realtime broadcast → DID Flutter 앱 즉시 표시.
   auto_dismiss_at: 설정 시간 후 자동 해제.
   특허1: DID = 고객 안내 채널.
   1-B차 DID/픽업 표시 핵심 기능.';

comment on function
  catchmenu_store.get_did_waiting_display(
    uuid, uuid, text, text
  ) is
  'DID Flutter 앱 폴링용 데이터.
   DID 앱이 refresh_interval_seconds마다 호출.
   포함 데이터:
   - 현재 대기 목록 (번호/인원/대기시간)
   - 활성 호출 목록 (queue_type/번호/메시지)
   - 매장 운영 상태
   - DID 디바이스 설정
   locale: DID 설치 언어 기준 메시지 선택.
   1-B차 DID 고도화 핵심 RPC.';