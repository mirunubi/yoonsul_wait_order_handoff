-- 0117_create_did_pipeline_rpc.sql
-- Purpose: DID display pipeline completion.
--          대기 번호 표시 + 이벤트 배너.
--          호출 큐 관리.
--          다국어 안내 메시지.
--          Flutter DID 앱 부트스트랩.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0116_create_customer_app_bootstrap_rpc.sql
-- Creates:
--   function catchmenu_store.bootstrap_did_app(...)
--   function catchmenu_store.get_did_display_state(...)
--   function catchmenu_store.dismiss_did_call(...)
--   function catchmenu_store.get_did_waiting_numbers(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('did_app_ready', 'ko',
  'DID 디스플레이가 준비되었습니다'),
('did_app_ready', 'en',
  'DID display ready'),
('did_state_loaded', 'ko',
  'DID 상태가 로드되었습니다'),
('did_state_loaded', 'en',
  'DID state loaded'),

-- DID 안내 메시지 (6개 로케일)
('did_welcome_msg', 'ko',
  '어서오세요'),
('did_welcome_msg', 'en', 'Welcome'),
('did_welcome_msg', 'zh', '欢迎光临'),
('did_welcome_msg', 'ja', 'いらっしゃいませ'),
('did_welcome_msg', 'vi', 'Chào mừng'),
('did_welcome_msg', 'th', 'ยินดีต้อนรับ'),

('did_now_calling', 'ko', '호출 중'),
('did_now_calling', 'en', 'Now Calling'),
('did_now_calling', 'zh', '叫号中'),
('did_now_calling', 'ja', 'お呼び出し中'),
('did_now_calling', 'vi', 'Đang gọi'),
('did_now_calling', 'th', 'กำลังเรียก'),

('did_please_proceed', 'ko',
  '입장해 주세요'),
('did_please_proceed', 'en',
  'Please proceed'),
('did_please_proceed', 'zh', '请进'),
('did_please_proceed', 'ja', 'どうぞお入りください'),
('did_please_proceed', 'vi', 'Mời vào'),
('did_please_proceed', 'th', 'กรุณาเข้ามา'),

('did_current_waiting', 'ko',
  '현재 대기'),
('did_current_waiting', 'en',
  'Now Waiting'),
('did_current_waiting', 'zh', '当前候位'),
('did_current_waiting', 'ja', '現在の待ち人数'),
('did_current_waiting', 'vi', 'Đang chờ'),
('did_current_waiting', 'th', 'รอคิว'),

('did_number_unit', 'ko', '번'),
('did_number_unit', 'en', ''),
('did_number_unit', 'zh', '号'),
('did_number_unit', 'ja', '番'),
('did_number_unit', 'vi', ''),
('did_number_unit', 'th', ''),

('did_group_unit', 'ko', '팀'),
('did_group_unit', 'en', 'group(s)'),
('did_group_unit', 'zh', '组'),
('did_group_unit', 'ja', 'グループ'),
('did_group_unit', 'vi', 'nhóm'),
('did_group_unit', 'th', 'กลุ่ม'),

('did_pickup_ready', 'ko',
  '포장 준비 완료'),
('did_pickup_ready', 'en',
  'Ready for Pickup'),
('did_pickup_ready', 'zh', '取餐准备好了'),
('did_pickup_ready', 'ja',
  'お持ち帰りのご準備ができました'),
('did_pickup_ready', 'vi',
  'Sẵn sàng lấy hàng'),
('did_pickup_ready', 'th',
  'พร้อมรับสินค้า'),

('did_call_dismissed', 'ko',
  '호출이 해제되었습니다'),
('did_call_dismissed', 'en',
  'Call dismissed')
on conflict (message_key, locale) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_did_app(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_code text,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_did_device record;
  v_store record;
  v_store_settings record;
  v_display_state jsonb;
  v_waiting_numbers jsonb;
  v_cms_bundle jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- DID 디바이스 조회
  select id, did_code, display_mode,
         zone, call_display_seconds,
         call_repeat_count,
         show_waiting_count,
         show_cms_content,
         supported_locales,
         default_locale
  into v_did_device
  from catchmenu_store.did_devices
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and did_code = p_did_code
    and is_active = true;

  if v_did_device.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'did_device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'bootstrap_did_app'
    );
  end if;

  -- 매장 정보
  select id, store_name, store_type
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  -- 매장 설정
  select store_mode, waiting_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 현재 DID 표시 상태
  v_display_state :=
    catchmenu_store.get_did_display_state(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_did_id := v_did_device.id,
      p_locale := coalesce(
        p_locale, v_did_device.default_locale
      )
    );

  -- 현재 대기 번호 목록
  v_waiting_numbers :=
    catchmenu_store.get_did_waiting_numbers(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := coalesce(
        p_locale, v_did_device.default_locale
      )
    );

  -- CMS 콘텐츠 (배너)
  if v_did_device.show_cms_content then
    v_cms_bundle :=
      catchmenu_store.get_cms_display_bundle(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_display_target := 'DID',
        p_locale := coalesce(
          p_locale, v_did_device.default_locale
        )
      );
  end if;

  -- DID heartbeat
  update catchmenu_store.did_devices
  set
    last_seen_at = now(),
    updated_at = now()
  where id = v_did_device.id;

  return catchmenu_common.build_success_response(
    p_message_key := 'did_app_ready',
    p_data := jsonb_build_object(

      -- DID 설정
      'did_device', jsonb_build_object(
        'id', v_did_device.id,
        'did_code', v_did_device.did_code,
        'display_mode', v_did_device.display_mode,
        'zone', v_did_device.zone,
        'call_display_seconds',
          v_did_device.call_display_seconds,
        'call_repeat_count',
          v_did_device.call_repeat_count,
        'show_waiting_count',
          v_did_device.show_waiting_count,
        'supported_locales',
          v_did_device.supported_locales,
        'default_locale',
          v_did_device.default_locale
      ),

      -- 매장
      'store', jsonb_build_object(
        'store_name', v_store.store_name,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        )
      ),

      -- 안내 메시지 (다국어)
      'display_messages', jsonb_build_object(
        'welcome',
          catchmenu_common.get_message(
            'did_welcome_msg', p_locale, null
          ),
        'now_calling',
          catchmenu_common.get_message(
            'did_now_calling', p_locale, null
          ),
        'please_proceed',
          catchmenu_common.get_message(
            'did_please_proceed', p_locale, null
          ),
        'current_waiting',
          catchmenu_common.get_message(
            'did_current_waiting', p_locale, null
          ),
        'number_unit',
          catchmenu_common.get_message(
            'did_number_unit', p_locale, null
          ),
        'group_unit',
          catchmenu_common.get_message(
            'did_group_unit', p_locale, null
          ),
        'pickup_ready',
          catchmenu_common.get_message(
            'did_pickup_ready', p_locale, null
          )
      ),

      -- 현재 표시 상태
      'display_state',
        v_display_state->'data',

      -- 대기 번호 목록
      'waiting_numbers',
        v_waiting_numbers->'data',

      -- CMS 콘텐츠
      'cms_content', v_cms_bundle->'data',

      -- Realtime 채널
      'realtime_channels', jsonb_build_array(
        'did:' || p_store_id,
        'waiting:' || p_store_id
      ),

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_display_state(
  p_tenant_id uuid,
  p_store_id uuid,
  p_did_id uuid,
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
  v_active_calls jsonb;
  v_current_display jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 표시 중인 호출
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'queue_id', id,
        'queue_type', queue_type,
        'display_number', display_number,
        'display_message', display_message,
        'display_locale', display_locale,
        'queue_status', queue_status,
        'auto_dismiss_at', auto_dismiss_at,
        'max_call_count', max_call_count
      )
      order by
        case queue_type
          when 'WAITING_CALL' then 1
          when 'TABLE_READY' then 2
          when 'PICKUP_READY' then 3
          else 4
        end,
        created_at asc
    ),
    '[]'::jsonb
  )
  into v_active_calls
  from catchmenu_store.did_display_queue
  where did_device_id = p_did_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
    and auto_dismiss_at > now()
    and business_day = v_business_day;

  -- 현재 최우선 표시 항목
  if jsonb_array_length(v_active_calls) > 0 then
    v_current_display := v_active_calls->0;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'did_state_loaded',
    p_data := jsonb_build_object(
      'did_id', p_did_id,
      'has_active_call',
        jsonb_array_length(v_active_calls) > 0,
      'current_display', v_current_display,
      'active_calls', v_active_calls,
      'call_count',
        jsonb_array_length(v_active_calls),
      'business_day', v_business_day
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_did_waiting_numbers(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_waiting_list jsonb;
  v_total_waiting int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 대기 번호 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'guest_count', os.guest_count,
        'is_called',
          os.session_status = 'ARRIVAL_PENDING',
        'called_at', os.called_at
      )
      order by os.queue_position asc nulls last,
               os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
  limit 20;

  v_total_waiting :=
    jsonb_array_length(v_waiting_list);

  return catchmenu_common.build_success_response(
    p_message_key := 'did_state_loaded',
    p_data := jsonb_build_object(
      'waiting_list', v_waiting_list,
      'total_waiting', v_total_waiting,
      'waiting_display',
        v_total_waiting::text
        || catchmenu_common.get_message(
          'did_group_unit', p_locale, null
        ),
      'business_day', v_business_day,
      'updated_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.dismiss_did_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_queue_id uuid,
  p_dismissed_by_type text default 'SYSTEM',
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
  v_queue record;
begin
  select id, did_device_id, queue_type,
         display_number, order_id
  into v_queue
  from catchmenu_store.did_display_queue
  where id = p_queue_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and queue_status = 'DISPLAYING'
  for update;

  if v_queue.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'did_device_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'dismiss_did_call'
    );
  end if;

  update catchmenu_store.did_display_queue
  set
    queue_status = 'DISMISSED',
    dismissed_at = now(),
    dismissed_by_type = p_dismissed_by_type,
    dismissed_by_id = p_actor_id,
    updated_at = now()
  where id = p_queue_id;

  -- Realtime 해제 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'queue_id', p_queue_id,
      'did_device_id', v_queue.did_device_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'did_call_dismissed',
    p_data := jsonb_build_object(
      'queue_id', p_queue_id,
      'queue_type', v_queue.queue_type,
      'display_number', v_queue.display_number,
      'dismissed_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.bootstrap_did_app(
      uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_did_display_state(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_did_waiting_numbers(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.dismiss_did_call(
      uuid, uuid, uuid, text, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_did_app(
    uuid, uuid, text, text
  ) is
  'DID 디스플레이 앱 부트스트랩.
   Flutter DID 앱 시작 시 단일 RPC.

   반환 데이터:
   - DID 디바이스 설정
   - 매장 정보 + 영업 상태
   - 다국어 안내 메시지 (6개 로케일)
   - 현재 호출 중인 큐
   - 대기 번호 목록 (최대 20개)
   - CMS 배너 콘텐츠
   - Realtime 채널 (did + waiting)

   Flutter DID 앱 흐름:
   1. bootstrap_did_app()
   2. Realtime did:{store_id} 구독
   3. WAITING_CALL 이벤트 수신
      → 호출 번호 대형 표시
   4. call_display_seconds 후 자동 해제
   5. 대기 없을 때 CMS 배너 슬라이드

   다국어:
   대기 고객 국적 기반 자동 언어 선택
   supported_locales 순서대로 표시.';