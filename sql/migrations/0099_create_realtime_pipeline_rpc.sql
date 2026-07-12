-- 0099_create_realtime_pipeline_rpc.sql
-- Purpose: Realtime pipeline for KDS, waiting,
--          and staff app integration.
--          Supabase Realtime channel management.
--          KDS 실시간 상태 브로드캐스트.
--          대기 현황 실시간 업데이트.
--          직원 앱 알림 파이프라인.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0098_create_payment_confirm_pipeline_rpc.sql
-- Creates:
--   catchmenu_common.realtime_channels (table)
--   function catchmenu_common.get_realtime_config(...)
--   function catchmenu_kds.get_kds_realtime_state(...)
--   function catchmenu_pos.get_waiting_realtime_state(...)
--   function catchmenu_common.broadcast_store_event(...)
--   function catchmenu_common.get_staff_alert_feed(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('realtime_config_loaded', 'ko',
  'Realtime 설정이 로드되었습니다'),
('realtime_config_loaded', 'en',
  'Realtime config loaded'),
('kds_state_loaded', 'ko',
  'KDS 현황이 로드되었습니다'),
('kds_state_loaded', 'en',
  'KDS state loaded'),
('waiting_state_loaded', 'ko',
  '대기 현황이 로드되었습니다'),
('waiting_state_loaded', 'en',
  'Waiting state loaded'),
('staff_alert_feed_loaded', 'ko',
  '직원 알림 피드가 로드되었습니다'),
('staff_alert_feed_loaded', 'en',
  'Staff alert feed loaded'),
('store_event_broadcast', 'ko',
  '매장 이벤트가 브로드캐스트되었습니다'),
('store_event_broadcast', 'en',
  'Store event broadcast'),
('new_order_alert', 'ko',
  '새 주문이 들어왔습니다: {order_number}번'),
('new_order_alert', 'en',
  'New order: #{order_number}'),
('new_order_alert', 'zh',
  '新订单：{order_number}号'),
('new_order_alert', 'ja',
  '新しい注文：{order_number}番'),
('new_order_alert', 'vi',
  'Đơn hàng mới: #{order_number}'),
('new_order_alert', 'th',
  'คำสั่งซื้อใหม่: #{order_number}'),
('kds_ticket_late', 'ko',
  '{menu_name} 조리 지연 중입니다'),
('kds_ticket_late', 'en',
  '{menu_name} cooking delayed'),
('waiting_called', 'ko',
  '{wait_number}번 고객이 호출되었습니다'),
('waiting_called', 'en',
  'Customer #{wait_number} called'),
('store_mode_changed', 'ko',
  '매장 모드가 변경되었습니다: {mode}'),
('store_mode_changed', 'en',
  'Store mode changed: {mode}')
on conflict (message_key, locale) do nothing;


-- DEFERRED: 0068 (already applied, live) established realtime_channels
-- with a Postgres-CDC + role-based-access model (channel_pattern,
-- allowed_roles, requires_store_match), already validated by 0073's
-- passing seed-count assertion. This file's incompatible broadcast-based
-- redesign (subscriber_device_types, subscriber_roles) never took effect
-- because CREATE TABLE IF NOT EXISTS silently kept 0068's version. If
-- device-type targeting is genuinely needed, it requires a new forward
-- migration that extends 0068's actual live schema, not a competing
-- table definition. Not resolved here -- pending future design decision.
-- Commented out below: the redundant table/seed and get_realtime_config
-- (the only function depending on the incompatible columns).
-- -- =============================================
-- -- realtime_channels table
-- -- Realtime 채널 설정 레지스트리
-- -- =============================================
-- create table if not exists
--   catchmenu_common.realtime_channels (
--   id uuid primary key default gen_random_uuid(),
--   tenant_id uuid not null
--     references catchmenu_hq.tenants(id),
--   store_id uuid not null
--     references catchmenu_hq.stores(id),

--   -- 채널 정보
--   channel_code text not null,
--   channel_name text not null,
--   channel_type text not null,

--   -- 구독자 정보
--   subscriber_device_types jsonb
--     not null default '[]'::jsonb,
--   subscriber_roles jsonb
--     not null default '[]'::jsonb,

--   -- 이벤트 목록
--   subscribed_events jsonb
--     not null default '[]'::jsonb,

--   -- 상태
--   is_active boolean not null default true,
--   last_broadcast_at timestamptz,
--   broadcast_count int not null default 0,

--   created_at timestamptz not null default now(),
--   updated_at timestamptz not null default now(),

--   constraint uq_realtime_channel unique (
--     store_id, channel_code
--   ),
--   constraint chk_channel_type check (
--     channel_type in (
--       'KDS_TICKETS',
--       'STAFF_ALERTS',
--       'WAITING_QUEUE',
--       'STORE_MODE',
--       'DID_DISPLAY',
--       'MENU_STATUS',
--       'SYSTEM_EVENTS',
--       'CUSTOMER_APP'
--     )
--   )
-- );

-- create index if not exists idx_realtime_channels
--   on catchmenu_common.realtime_channels(
--     store_id, channel_type
--   ) where is_active = true;

-- alter table catchmenu_common.realtime_channels
--   enable row level security;
-- alter table catchmenu_common.realtime_channels
--   force row level security;

-- drop policy if exists realtime_channels_isolation
--   on catchmenu_common.realtime_channels;
-- create policy realtime_channels_isolation
--   on catchmenu_common.realtime_channels
--   for all to authenticated
--   using (
--     tenant_id = catchmenu_common.current_tenant_id()
--     and store_id =
--       catchmenu_common.current_store_id()
--   );

-- drop trigger if exists trg_realtime_channels_updated
--   on catchmenu_common.realtime_channels;
-- create trigger trg_realtime_channels_updated
--   before update on
--     catchmenu_common.realtime_channels
--   for each row execute function
--     catchmenu_common.set_updated_at();

-- comment on table
--   catchmenu_common.realtime_channels is
--   'Supabase Realtime 채널 레지스트리.
--    채널 목록:
--    KDS_TICKETS: 주방 디스플레이
--    STAFF_ALERTS: 직원 앱 알림
--    WAITING_QUEUE: 대기 현황
--    STORE_MODE: 매장 모드 변경
--    DID_DISPLAY: DID 호출
--    MENU_STATUS: 메뉴 상태 변경
--    SYSTEM_EVENTS: Edge Function 트리거
--    CUSTOMER_APP: 고객 앱 알림
--    Flutter subscribe:
--    supabase.channel(channel_code)
--      .onBroadcast(event, callback)
--      .subscribe()';


-- -- 채널 시드
-- insert into catchmenu_common.realtime_channels (
--   tenant_id, store_id,
--   channel_code, channel_name, channel_type,
--   subscriber_device_types, subscriber_roles,
--   subscribed_events
-- ) values
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'kds:00000000-0000-0000-0000-000000000002',
--   'KDS 채널',
--   'KDS_TICKETS',
--   '["KDS_DISPLAY","STAFF_APP"]'::jsonb,
--   '["KITCHEN","MANAGER","OWNER"]'::jsonb,
--   ('["kds_ticket_created","kds_ticket_updated",'
--   || '"kds_tickets_released","kds_capacity_changed",'
--   || '"kds_ticket_late"]')::jsonb
-- ),
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'staff:00000000-0000-0000-0000-000000000002',
--   '직원 알림 채널',
--   'STAFF_ALERTS',
--   '["STAFF_APP","POS_TERMINAL"]'::jsonb,
--   '["STAFF","MANAGER","OWNER"]'::jsonb,
--   ('["takeout_order_received","payment_confirmed",'
--   || '"waiting_session_created",'
--   || '"delivery_order_cancelled",'
--   || '"kds_overloaded_alert"]')::jsonb
-- ),
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'waiting:00000000-0000-0000-0000-000000000002',
--   '대기 현황 채널',
--   'WAITING_QUEUE',
--   '["MINI_KIOSK","STAFF_APP","DID_DISPLAY"]'::jsonb,
--   '["STAFF","MANAGER","CUSTOMER"]'::jsonb,
--   ('["waiting_session_created",'
--   || '"waiting_session_seated",'
--   || '"waiting_session_cancelled",'
--   || '"waiting_called"]')::jsonb
-- ),
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'store:00000000-0000-0000-0000-000000000002',
--   '매장 모드 채널',
--   'STORE_MODE',
--   ('["STAFF_APP","MINI_KIOSK","KDS_DISPLAY",'
--   || '"DID_DISPLAY"]')::jsonb,
--   '["STAFF","MANAGER","OWNER","SYSTEM"]'::jsonb,
--   ('["store_mode_changed","holiday_mode_changed",'
--   || '"waiting_enabled_changed",'
--   || '"notice_created","cms_content_published"]')::jsonb
-- ),
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'did:00000000-0000-0000-0000-000000000002',
--   'DID 디스플레이 채널',
--   'DID_DISPLAY',
--   '["DID_DISPLAY"]'::jsonb,
--   '["SYSTEM"]'::jsonb,
--   ('["PICKUP_READY","TABLE_READY","WAITING_CALL",'
--   || '"call_dismissed","content_updated"]')::jsonb
-- ),
-- (
--   '00000000-0000-0000-0000-000000000001',
--   '00000000-0000-0000-0000-000000000002',
--   'system:00000000-0000-0000-0000-000000000001',
--   '시스템 이벤트 채널',
--   'SYSTEM_EVENTS',
--   '[]'::jsonb,
--   '["SYSTEM"]'::jsonb,
--   ('["pg_cancel_requested","sms_verify_code_requested",'
--   || '"document_embedding_requested",'
--   || '"sop_draft_ai_requested",'
--   || '"push_notification_queued"]')::jsonb
-- )
-- on conflict (store_id, channel_code) do nothing;


-- -- =============================================
-- -- RPCs
-- -- =============================================
-- create or replace function
--   catchmenu_common.get_realtime_config(
--   p_tenant_id uuid,
--   p_store_id uuid,
--   p_device_type text,
--   p_staff_role text default null,
--   p_locale text default 'ko'
-- )
-- returns jsonb
-- language plpgsql
-- stable
-- security definer
-- set search_path = catchmenu_common,
--                   catchmenu_hq
-- as $$
-- declare
--   v_channels jsonb;
--   v_store record;
-- begin
--   select id, store_name, timezone
--   into v_store
--   from catchmenu_hq.stores
--   where id = p_store_id
--     and tenant_id = p_tenant_id
--     and is_active = true;

--   if v_store.id is null then
--     return catchmenu_common.build_error_response(
--       p_error_key := 'store_not_found',
--       p_locale := p_locale,
--       p_tenant_id := p_tenant_id,
--       p_store_id := p_store_id,
--       p_rpc_name := 'get_realtime_config'
--     );
--   end if;

--   -- 디바이스 타입 + 역할 기반 채널 필터
--   select coalesce(
--     jsonb_agg(
--       jsonb_build_object(
--         'channel_code', channel_code,
--         'channel_name', channel_name,
--         'channel_type', channel_type,
--         'subscribed_events', subscribed_events
--       )
--       order by channel_type
--     ),
--     '[]'::jsonb
--   )
--   into v_channels
--   from catchmenu_common.realtime_channels
--   where store_id = p_store_id
--     and tenant_id = p_tenant_id
--     and is_active = true
--     and (
--       -- 디바이스 타입 매칭
--       subscriber_device_types
--         @> to_jsonb(p_device_type)
--       -- 또는 구독자 제한 없음
--       or jsonb_array_length(
--         subscriber_device_types
--       ) = 0
--       -- 또는 SYSTEM 채널
--       or subscriber_roles
--         @> to_jsonb('SYSTEM'::text)
--     );

--   return catchmenu_common.build_success_response(
--     p_message_key := 'realtime_config_loaded',
--     p_data := jsonb_build_object(
--       'store_id', p_store_id,
--       'store_name', v_store.store_name,
--       'timezone', v_store.timezone,
--       'device_type', p_device_type,
--       'channels', v_channels,
--       'channel_count',
--         jsonb_array_length(v_channels),
--       'flutter_pattern', jsonb_build_object(
--         'subscribe_template',
--           'supabase.channel({channel_code})'
--           || '.onBroadcast('
--           || 'event: {event},'
--           || 'callback: handler'
--           || ').subscribe()',
--         'broadcast_template',
--           'supabase.channel({channel_code})'
--           || '.sendBroadcastMessage('
--           || 'event: {event},'
--           || 'payload: {data}'
--           || ')'
--       )
--     ),
--     p_locale := p_locale
--   );
-- end;
-- $$;


create or replace function
  catchmenu_kds.get_kds_realtime_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_kds,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_store,
                  catchmenu_hq
as $$
declare
  v_business_day date;
  v_timezone text;
  v_store_settings record;
  v_tickets jsonb;
  v_capacity jsonb;
  v_stats jsonb;
  v_late_tickets jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select store_mode,
         kds_capacity_threshold_total,
         kds_capacity_threshold_per_zone
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 활성 KDS 티켓 (HOLD/COMMITTED/COOKING/READY)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', kt.id,
        'order_id', kt.order_id,
        'order_number', o.order_number,
        'order_type', o.order_type,
        'menu_name', kt.menu_name_snapshot,
        'quantity', kt.quantity_snapshot,
        'kitchen_zone', kt.kitchen_zone,
        'kds_status', kt.kds_status,
        'is_late', (
          kt.committed_at is not null
          and kt.estimated_minutes_snapshot is not null
          and kt.committed_at
              + kt.estimated_minutes_snapshot * interval '1 minute'
              < now()
        ),
        'priority', kt.priority,
        'conditions_met', kt.conditions_met,
        'ticket_created_at',
          kt.ticket_created_at,
        'committed_at', kt.committed_at,
        'cooking_started_at',
          kt.cooking_started_at,
        'elapsed_seconds', extract(
          epoch from (
            now() - kt.ticket_created_at
          )
        )::int,
        'cooking_elapsed_seconds', case
          when kt.cooking_started_at is not null
          then extract(
            epoch from (
              now() - kt.cooking_started_at
            )
          )::int
          else null
        end,
        'request_memo', o.request_memo
      )
      order by
        kt.priority asc,
        kt.ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_tickets
  from catchmenu_kds.kds_tickets kt
  join catchmenu_pos.orders o
    on o.id = kt.order_id
  where kt.store_id = p_store_id
    and kt.tenant_id = p_tenant_id
    and kt.business_day = v_business_day
    and kt.kds_status in (
      'HOLD', 'COMMITTED',
      'CAPACITY_CHECKING', 'COOKING', 'READY'
    );

  -- 용량 현황
  v_capacity :=
    catchmenu_kds.check_kds_capacity(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id
    );

  -- 오늘 통계
  select jsonb_build_object(
    'total_today', count(*),
    'completed_today', count(*) filter (
      where kds_status in (
        'SERVED', 'COMPLETED'
      )
    ),
    'cancelled_today', count(*) filter (
      where kds_status = 'CANCELLED'
    ),
    'avg_cooking_seconds', coalesce(
      avg(
        extract(epoch from (
          served_at - cooking_started_at
        ))
      ) filter (
        where served_at is not null
          and cooking_started_at is not null
      )::int, 0
    ),
    'late_count', count(*) filter (
      where committed_at is not null
        and estimated_minutes_snapshot is not null
        and committed_at
            + estimated_minutes_snapshot * interval '1 minute'
            < now()
        and kds_status not in (
          'SERVED', 'COMPLETED', 'CANCELLED'
        )
    )
  )
  into v_stats
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 지연 티켓 (알림용)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'menu_name', menu_name_snapshot,
        'kitchen_zone', kitchen_zone,
        'elapsed_seconds', extract(
          epoch from (
            now() - ticket_created_at
          )
        )::int,
        'alert_message',
          catchmenu_common.get_message(
            'kds_ticket_late', p_locale,
            jsonb_build_object(
              'menu_name', menu_name_snapshot
            )
          )
      )
    ),
    '[]'::jsonb
  )
  into v_late_tickets
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and committed_at is not null
    and estimated_minutes_snapshot is not null
    and committed_at
        + estimated_minutes_snapshot * interval '1 minute'
        < now()
    and kds_status in (
      'COMMITTED', 'COOKING'
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'kds_state_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'store_mode',
        coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
      'active_tickets', v_tickets,
      'active_count',
        jsonb_array_length(v_tickets),
      'capacity', v_capacity->'data',
      'is_overloaded',
        (v_capacity->'data'->>'is_overloaded')
          ::boolean,
      'today_stats', v_stats,
      'late_tickets', v_late_tickets,
      'late_count',
        jsonb_array_length(v_late_tickets),
      'realtime_channel',
        'kds:' || p_store_id,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_pos.get_waiting_realtime_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_business_day date;
  v_timezone text;
  v_store_settings record;
  v_waiting_sessions jsonb;
  v_stats jsonb;
  v_wait_estimate jsonb;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  select store_mode, waiting_enabled,
         max_waiting_count
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 현재 대기 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'queue_position', os.queue_position,
        'guest_locale', os.guest_locale,
        'waited_seconds', extract(
          epoch from (
            now() - os.session_started_at
          )
        )::int,
        'waited_display',
          lpad(
            (extract(
              epoch from (
                now() - os.session_started_at
              )
            )::int / 60)::text,
            2, '0'
          ) || '분',
        'arrival_confirmed_at',
          os.arrival_confirmed_at,
        'pre_order_amount',
          os.pre_order_amount,
        'table_number', os.table_number,
        'memo', os.memo,
        'alert_message', case
          when os.session_status = 'WAITING'
          then catchmenu_common.get_message(
            'waiting_called', p_locale,
            jsonb_build_object(
              'wait_number', os.wait_number
            )
          )
          else null
        end
      )
      order by os.queue_position asc nulls last,
               os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_sessions
  from catchmenu_pos.order_sessions os
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and os.session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 오늘 대기 통계
  select jsonb_build_object(
    'total_today', count(*),
    'completed_today', count(*) filter (
      where session_status = 'COMPLETED'
    ),
    'cancelled_today', count(*) filter (
      where session_status = 'CANCELLED'
    ),
    'no_show_today', count(*) filter (
      where session_status = 'NO_SHOW'
    ),
    'avg_wait_seconds', coalesce(
      avg(
        extract(epoch from (
          coalesce(
            arrival_confirmed_at, now()
          ) - session_started_at
        ))
      ) filter (
        where arrival_confirmed_at is not null
      )::int, 0
    ),
    'current_waiting',
      jsonb_array_length(v_waiting_sessions)
  )
  into v_stats
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_type in (
      'WAITING', 'PRE_ORDER'
    );

  -- 대기 예상 시간
  v_wait_estimate :=
    catchmenu_pos.estimate_wait_time(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_guest_count := 2
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_state_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'store_mode',
        coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
      'waiting_enabled', coalesce(
        v_store_settings.waiting_enabled, true
      ),
      'max_waiting_count', coalesce(
        v_store_settings.max_waiting_count, 30
      ),
      'current_waiting',
        jsonb_array_length(v_waiting_sessions),
      'is_full',
        jsonb_array_length(v_waiting_sessions)
          >= coalesce(
            v_store_settings.max_waiting_count,
            30
          ),
      'waiting_sessions', v_waiting_sessions,
      'today_stats', v_stats,
      'wait_estimate',
        v_wait_estimate->'data',
      'realtime_channel',
        'waiting:' || p_store_id,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.broadcast_store_event(
  p_tenant_id uuid,
  p_store_id uuid,
  p_event_type text,
  p_event_data jsonb,
  p_channel_type text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common
as $$
declare
  v_channel_code text;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 이벤트 타입 → 채널 자동 라우팅
  v_channel_code := case
    when p_channel_type is not null then
      p_channel_type || ':' || p_store_id
    when p_event_type in (
      'kds_ticket_created',
      'kds_ticket_updated',
      'kds_tickets_released',
      'kds_capacity_changed',
      'kds_ticket_late'
    ) then 'kds:' || p_store_id
    when p_event_type in (
      'takeout_order_received',
      'payment_confirmed',
      'delivery_order_cancelled',
      'waiting_session_created',
      'kds_overloaded_alert'
    ) then 'staff:' || p_store_id
    when p_event_type in (
      'waiting_session_created',
      'waiting_session_seated',
      'waiting_session_cancelled',
      'waiting_called'
    ) then 'waiting:' || p_store_id
    when p_event_type in (
      'store_mode_changed',
      'holiday_mode_changed',
      'notice_created',
      'cms_content_published'
    ) then 'store:' || p_store_id
    when p_event_type in (
      'PICKUP_READY', 'TABLE_READY',
      'WAITING_CALL', 'call_dismissed'
    ) then 'did:' || p_store_id
    else 'staff:' || p_store_id
  end;

  -- Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := coalesce(
      p_channel_type, 'STAFF_ALERTS'
    ),
    p_event_type := p_event_type,
    p_payload := p_event_data || jsonb_build_object(
      'broadcast_at', now(),
      'business_day', v_business_day,
      'locale', p_locale
    )
  );

  -- 채널 통계 업데이트
  update catchmenu_common.realtime_channels
  set
    last_broadcast_at = now(),
    broadcast_count = broadcast_count + 1,
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and channel_code = v_channel_code;

  return catchmenu_common.build_success_response(
    p_message_key := 'store_event_broadcast',
    p_data := jsonb_build_object(
      'event_type', p_event_type,
      'channel_code', v_channel_code,
      'broadcast_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_staff_alert_feed(
  p_tenant_id uuid,
  p_store_id uuid,
  p_since timestamptz default null,
  p_limit int default 20,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment
as $$
declare
  v_since timestamptz;
  v_business_day date;
  v_alerts jsonb;
  v_kds_lates jsonb;
  v_pending_orders jsonb;
  v_open_recon int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_since := coalesce(
    p_since,
    now() - interval '1 hour'
  );

  -- 운영 알림
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'alert_id', id,
        'alert_type', alert_type,
        'alert_severity', alert_severity,
        'alert_title', alert_title,
        'sop_runbook_code', sop_runbook_code,
        'occurrence_count', occurrence_count,
        'last_occurred_at', last_occurred_at
      )
      order by
        case alert_severity
          when 'FATAL' then 0
          when 'CRITICAL' then 1
          when 'ERROR' then 2
          else 3
        end,
        last_occurred_at desc
    ),
    '[]'::jsonb
  )
  into v_alerts
  from catchmenu_common.operation_alerts
  where tenant_id = p_tenant_id
    and (
      store_id = p_store_id
      or store_id is null
    )
    and alert_status in (
      'OPEN', 'ACKNOWLEDGED'
    )
  limit 5;

  -- KDS 지연 티켓
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'menu_name', menu_name_snapshot,
        'kitchen_zone', kitchen_zone,
        'elapsed_seconds', extract(
          epoch from (
            now() - ticket_created_at
          )
        )::int,
        'alert_message',
          catchmenu_common.get_message(
            'kds_ticket_late', p_locale,
            jsonb_build_object(
              'menu_name', menu_name_snapshot
            )
          )
      )
      order by ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_kds_lates
  from catchmenu_kds.kds_tickets
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and committed_at is not null
    and estimated_minutes_snapshot is not null
    and committed_at
        + estimated_minutes_snapshot * interval '1 minute'
        < now()
    and kds_status in ('COMMITTED', 'COOKING')
  limit 5;

  -- 처리 대기 주문
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_type', o.order_type,
        'order_status', o.order_status,
        'final_amount', o.final_amount,
        'ordered_at', o.ordered_at,
        'wait_seconds', extract(
          epoch from (now() - o.ordered_at)
        )::int,
        'alert_message',
          catchmenu_common.get_message(
            'new_order_alert', p_locale,
            jsonb_build_object(
              'order_number', o.order_number
            )
          )
      )
      order by o.ordered_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_orders
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.business_day = v_business_day
    and o.order_status in (
      'CONFIRMED', 'READY'
    )
    and o.order_type in (
      'TAKEOUT', 'DELIVERY'
    )
  limit 5;

  -- 미해결 대사 케이스
  select count(*) into v_open_recon
  from catchmenu_payment.reconciliation_cases
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and case_status in ('OPEN', 'INVESTIGATING')
    and case_severity = 'CRITICAL';

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_alert_feed_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'since', v_since,
      'operation_alerts', v_alerts,
      'alert_count',
        jsonb_array_length(v_alerts),
      'kds_late_tickets', v_kds_lates,
      'kds_late_count',
        jsonb_array_length(v_kds_lates),
      'pending_orders', v_pending_orders,
      'pending_order_count',
        jsonb_array_length(v_pending_orders),
      'critical_recon_cases', v_open_recon,
      'has_urgent',
        jsonb_array_length(v_alerts) > 0
        or jsonb_array_length(v_kds_lates) > 0
        or v_open_recon > 0,
      'realtime_channel',
        'staff:' || p_store_id,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- Flutter SDK 패턴: Realtime 통합
-- =============================================
insert into catchmenu_common.flutter_sdk_patterns (
  pattern_code, pattern_name,
  pattern_category, device_types,
  description, dependencies, dart_code
) values
(
  'FLUTTER_REALTIME_FULL',
  'Realtime 전체 통합 패턴',
  'REALTIME',
  '["STAFF_APP","KDS_DISPLAY","MINI_KIOSK"]'::jsonb,
  'KDS + 대기 + 직원 알림 Realtime 통합 구독',
  '["supabase_flutter: ^2.0.0"]'::jsonb,
  $dart$
// lib/services/realtime_manager.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeManager {
  final _sb = Supabase.instance.client;
  final Map<String, RealtimeChannel> _channels = {};

  // 전체 Realtime 초기화
  Future<void> initialize({
    required String tenantId,
    required String storeId,
    required String deviceType,
    required RealtimeHandlers handlers,
  }) async {
    // 1. Realtime 설정 로드
    final config = await _sb.rpc(
      'get_realtime_config',
      params: {
        'p_tenant_id': tenantId,
        'p_store_id': storeId,
        'p_device_type': deviceType,
        'p_locale': 'ko',
      },
    );

    final channels =
      config['data']['channels'] as List;

    // 2. 채널별 구독
    for (final ch in channels) {
      final channelCode =
        ch['channel_code'] as String;
      final events =
        ch['subscribed_events'] as List;

      final channel =
        _sb.channel(channelCode);

      for (final event in events) {
        channel.onBroadcast(
          event: event as String,
          callback: (payload) =>
            _route(
              event, payload, handlers
            ),
        );
      }

      channel.subscribe();
      _channels[channelCode] = channel;
    }
  }

  // 이벤트 라우팅
  void _route(
    String event,
    Map payload,
    RealtimeHandlers handlers,
  ) {
    switch (event) {
      // KDS 이벤트
      case 'kds_ticket_created':
      case 'kds_ticket_updated':
      case 'kds_tickets_released':
        handlers.onKdsUpdate?.call(
          event, payload
        );
        break;
      case 'kds_capacity_changed':
        handlers.onKdsCapacity?.call(payload);
        break;
      case 'kds_ticket_late':
        handlers.onKdsLate?.call(payload);
        break;
      // 직원 알림
      case 'takeout_order_received':
        handlers.onNewOrder?.call(payload);
        break;
      case 'payment_confirmed':
        handlers.onPaymentConfirmed?.call(
          payload
        );
        break;
      case 'delivery_order_cancelled':
        handlers.onDeliveryCancelled?.call(
          payload
        );
        break;
      // 대기 이벤트
      case 'waiting_session_created':
        handlers.onWaitingCreated?.call(
          payload
        );
        break;
      case 'waiting_session_seated':
        handlers.onWaitingSeated?.call(
          payload
        );
        break;
      // 매장 모드
      case 'store_mode_changed':
        handlers.onStoreModeChanged?.call(
          payload
        );
        break;
      // DID 호출
      case 'PICKUP_READY':
      case 'TABLE_READY':
      case 'WAITING_CALL':
        handlers.onDidCall?.call(
          event, payload
        );
        break;
    }
  }

  // 전체 구독 해제
  Future<void> dispose() async {
    for (final ch in _channels.values) {
      await ch.unsubscribe();
    }
    _channels.clear();
  }
}

// 핸들러 정의
class RealtimeHandlers {
  final void Function(String, Map)?
    onKdsUpdate;
  final void Function(Map)? onKdsCapacity;
  final void Function(Map)? onKdsLate;
  final void Function(Map)? onNewOrder;
  final void Function(Map)? onPaymentConfirmed;
  final void Function(Map)? onDeliveryCancelled;
  final void Function(Map)? onWaitingCreated;
  final void Function(Map)? onWaitingSeated;
  final void Function(Map)? onStoreModeChanged;
  final void Function(String, Map)? onDidCall;

  const RealtimeHandlers({
    this.onKdsUpdate,
    this.onKdsCapacity,
    this.onKdsLate,
    this.onNewOrder,
    this.onPaymentConfirmed,
    this.onDeliveryCancelled,
    this.onWaitingCreated,
    this.onWaitingSeated,
    this.onStoreModeChanged,
    this.onDidCall,
  });
}
$dart$
)
on conflict (pattern_code) do update set
  dart_code = excluded.dart_code;


-- grants
do $$
begin
  -- get_realtime_config grants removed: function deferred (see header note)

  revoke all on function
    catchmenu_kds.get_kds_realtime_state(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_kds.get_kds_realtime_state(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_pos.get_waiting_realtime_state(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_pos.get_waiting_realtime_state(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.broadcast_store_event(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_common.broadcast_store_event(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_common.get_staff_alert_feed(
      uuid, uuid, timestamptz, int, text
    ) from public;
  grant execute on function
    catchmenu_common.get_staff_alert_feed(
      uuid, uuid, timestamptz, int, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_kds.get_kds_realtime_state(
    uuid, uuid, text
  ) is
  'KDS Flutter 앱 초기 로드 + 폴링 백업.
   포함 데이터:
   - 활성 티켓 (HOLD/COMMITTED/COOKING/READY)
   - 우선순위 + 경과 시간
   - 용량 현황 (과부하 여부)
   - 오늘 통계
   - 지연 티켓 알림

   Realtime 흐름:
   1. 앱 시작 시 이 RPC 호출 (초기 상태)
   2. Realtime 채널 구독 (kds:{store_id})
   3. 이벤트 수신 시 상태 업데이트
   4. 30초 폴링으로 동기화 보장

   특허2 표시:
   HOLD = 결제 전 (회색/비활성)
   COMMITTED = 결제 완료 (초록/활성)
   KDS 화면에서 HOLD는 조리 시작 불가.';

comment on function
  catchmenu_common.get_staff_alert_feed(
    uuid, uuid, timestamptz, int, text
  ) is
  '직원 앱 알림 피드.
   Flutter 앱 홈 화면 상단 표시.
   포함 항목 (우선순위 순):
   1. CRITICAL/FATAL 운영 알림
   2. KDS 지연 티켓
   3. 처리 대기 포장/배달 주문
   4. CRITICAL 미해결 대사 케이스
   has_urgent = true 시 → 빨간 배지 표시.
   Realtime + 30초 폴링 병행.
   SOP 런북 코드 포함 → 직원이 즉시 조치.';
