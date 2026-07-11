-- 0115_create_waiting_pipeline_rpc.sql
-- Purpose: Waiting queue pipeline with Late Binding.
--          대기 등록 → 호출 → 착석 → Pre-order
--          → 결제 → KDS Late Binding.
--          QR 대기 등록 (미니키오스크 연동).
--          노쇼/이탈 처리.
--          DID 연동.
--          특허1: Wait/Order Handoff 핵심.
--          특허2: 대기 Pre-order KDS HOLD.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0114_create_mini_kiosk_pipeline_rpc.sql
-- Creates:
--   function catchmenu_pos.register_waiting(...)
--   function catchmenu_pos.call_waiting_customer(...)
--   function catchmenu_pos.confirm_arrival(...)
--   function catchmenu_pos.pre_order_while_waiting(...)
--   function catchmenu_pos.seat_waiting_customer(...)
--   function catchmenu_pos.cancel_waiting(...)
--   function catchmenu_pos.mark_no_show(...)
--   function catchmenu_pos.get_waiting_status(...)
--   function catchmenu_pos.get_waiting_admin_view(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('waiting_registered', 'ko',
  '{wait_number}번으로 대기 등록되었습니다'),
('waiting_registered', 'en',
  'Registered as #{wait_number}'),
('waiting_registered', 'zh',
  '已登记为{wait_number}号'),
('waiting_registered', 'ja',
  '{wait_number}番で受付しました'),
('waiting_registered', 'vi',
  'Đã đăng ký số #{wait_number}'),
('waiting_registered', 'th',
  'ลงทะเบียนหมายเลข #{wait_number} แล้ว'),

('waiting_called_alert', 'ko',
  '{wait_number}번 고객님, 입장해 주세요'),
('waiting_called_alert', 'en',
  'Number #{wait_number}, please come in'),
('waiting_called_alert', 'zh',
  '{wait_number}号，请进'),
('waiting_called_alert', 'ja',
  '{wait_number}番のお客様、どうぞお入りください'),
('waiting_called_alert', 'vi',
  'Số #{wait_number}, mời vào'),
('waiting_called_alert', 'th',
  'หมายเลข #{wait_number} กรุณาเข้ามา'),

('arrival_confirmed', 'ko',
  '도착이 확인되었습니다. 잠시만 기다려 주세요'),
('arrival_confirmed', 'en',
  'Arrival confirmed. Please wait a moment'),
('arrival_confirmed', 'zh',
  '已确认到达，请稍等'),
('arrival_confirmed', 'ja',
  'ご到着を確認しました。少々お待ちください'),
('arrival_confirmed', 'vi',
  'Đã xác nhận đến. Vui lòng chờ'),
('arrival_confirmed', 'th',
  'ยืนยันการมาถึงแล้ว กรุณารอสักครู่'),

('waiting_seated', 'ko',
  '착석 처리되었습니다'),
('waiting_seated', 'en',
  'Customer seated'),
('waiting_seated', 'zh',
  '已就座'),
('waiting_seated', 'ja',
  'ご着席いただきました'),
('waiting_seated', 'vi',
  'Khách đã ngồi'),
('waiting_seated', 'th',
  'ลูกค้านั่งแล้ว'),

('waiting_cancelled', 'ko',
  '대기가 취소되었습니다'),
('waiting_cancelled', 'en',
  'Waiting cancelled'),
('waiting_cancelled', 'zh',
  '等位已取消'),
('waiting_cancelled', 'ja',
  '順番待ちをキャンセルしました'),
('waiting_cancelled', 'vi',
  'Đã hủy chờ'),
('waiting_cancelled', 'th',
  'ยกเลิกการรอแล้ว'),

('waiting_no_show', 'ko',
  '{wait_number}번 노쇼 처리되었습니다'),
('waiting_no_show', 'en',
  'No-show: #{wait_number}'),
('waiting_no_show', 'zh',
  '{wait_number}号未到'),
('waiting_no_show', 'ja',
  '{wait_number}番、ノーショー処理しました'),
('waiting_no_show', 'vi',
  'Vắng mặt: #{wait_number}'),
('waiting_no_show', 'th',
  'ไม่มาตามนัด: #{wait_number}'),

('pre_order_registered', 'ko',
  '사전 주문이 등록되었습니다. 착석 후 조리가 시작됩니다'),
('pre_order_registered', 'en',
  'Pre-order registered. Cooking starts after seating'),
('pre_order_registered', 'zh',
  '预点餐已登记，就座后开始烹饪'),
('pre_order_registered', 'ja',
  '事前注文を受け付けました。着席後に調理が始まります'),
('pre_order_registered', 'vi',
  'Đặt trước đã đăng ký. Nấu sau khi ngồi'),
('pre_order_registered', 'th',
  'สั่งล่วงหน้าแล้ว จะเริ่มปรุงหลังนั่ง'),

('waiting_status_loaded', 'ko',
  '대기 현황이 로드되었습니다'),
('waiting_status_loaded', 'en',
  'Waiting status loaded'),

('waiting_current_position', 'ko',
  '현재 {position}번째 대기 중입니다'),
('waiting_current_position', 'en',
  'Currently #{position} in queue'),
('waiting_current_position', 'zh',
  '当前排队第{position}位'),
('waiting_current_position', 'ja',
  '現在{position}番目でお待ちです'),
('waiting_current_position', 'vi',
  'Đang chờ thứ #{position}'),
('waiting_current_position', 'th',
  'รอคิวที่ #{position}'),

('waiting_est_time', 'ko',
  '예상 대기 시간: 약 {minutes}분'),
('waiting_est_time', 'en',
  'Est. wait: ~{minutes} min'),
('waiting_est_time', 'zh',
  '预计等待：约{minutes}分钟'),
('waiting_est_time', 'ja',
  '予想待ち時間：約{minutes}分'),
('waiting_est_time', 'vi',
  'Dự kiến chờ: ~{minutes} phút'),
('waiting_est_time', 'th',
  'เวลารอโดยประมาณ: ~{minutes} นาที'),

('pre_order_kds_note', 'ko',
  '대기 중 주문은 착석/결제 후 조리됩니다'),
('pre_order_kds_note', 'en',
  'Pre-orders cook after seating/payment'),
('pre_order_kds_note', 'zh',
  '等位期间的预点餐将在就座后烹饪'),
('pre_order_kds_note', 'ja',
  '待機中の注文は着席後に調理されます'),
('pre_order_kds_note', 'vi',
  'Đơn đặt trước nấu sau khi ngồi'),
('pre_order_kds_note', 'th',
  'คำสั่งซื้อล่วงหน้าจะปรุงหลังนั่ง')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(2020, 'waiting_session_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING'),
(2021, 'waiting_already_called',
  'ORDER', 'CONFLICT', 409, 'INFO'),
(2022, 'waiting_already_seated',
  'ORDER', 'CONFLICT', 409, 'INFO'),
(2023, 'waiting_queue_disabled',
  'ORDER', 'BUSINESS_RULE', 503, 'INFO'),
(2024, 'pre_order_requires_waiting',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING'),
(2025, 'waiting_not_callable',
  'ORDER', 'BUSINESS_RULE', 409, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_pos.register_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_guest_count int,
  p_session_type text default 'WAITING',
  p_guest_locale text default 'ko',
  p_phone_hash text default null,
  p_customer_id uuid default null,
  p_memo text default null,
  p_source text default 'STAFF',
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_settings record;
  v_wait_number int;
  v_queue_position int;
  v_session_id uuid;
  v_est_wait_minutes int;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 매장 설정 확인
  select store_mode, waiting_enabled,
         max_wait_number
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 대기 비활성화 확인
  if coalesce(v_settings.store_mode, 'NORMAL')
    in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
    or not coalesce(
      v_settings.waiting_enabled, true
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_queue_disabled',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 현재 대기 인원 확인
  select count(*) into v_queue_position
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

  -- 대기 정원 초과
  if v_queue_position >=
    coalesce(v_settings.max_wait_number, 30)
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'wait_queue_full',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'register_waiting'
    );
  end if;

  -- 오늘 대기 번호 채번
  select coalesce(
    max(wait_number), 0
  ) + 1
  into v_wait_number
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 대기 세션 생성 (특허1 핵심)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    wait_number, queue_position,
    guest_count, guest_locale,
    phone_hash, customer_id,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_type, 'WAITING',
    v_wait_number, v_queue_position + 1,
    p_guest_count, p_guest_locale,
    p_phone_hash, p_customer_id,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 예상 대기 시간 계산
  v_est_wait_minutes :=
    v_queue_position * 10;

  -- Realtime → 대기 화면 + DID 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_created',
    p_payload := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'source', p_source
    )
  );

  -- 고객 앱 푸시 알림 (전화번호 있는 경우)
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash,
        'customer_id', p_customer_id,
        'notification_type', 'WAITING_REGISTERED',
        'wait_number', v_wait_number,
        'queue_position', v_queue_position + 1,
        'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
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
    'waiting', 'waiting_registered', 1,
    'order_session', v_session_id,
    null, 'WAITING',
    p_source,
    jsonb_build_object(
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'session_type', p_session_type,
      'source', p_source
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_registered',
    p_data := jsonb_build_object(
      'session_id', v_session_id,
      'wait_number', v_wait_number,
      'queue_position', v_queue_position + 1,
      'guest_count', p_guest_count,
      'guest_locale', p_guest_locale,
      'est_wait_minutes', v_est_wait_minutes,
      'pre_order_enabled',
        p_session_type = 'PRE_ORDER',
      'position_message',
        catchmenu_common.get_message(
          'waiting_current_position',
          p_guest_locale,
          jsonb_build_object(
            'position', v_queue_position + 1
          )
        ),
      'est_time_message',
        catchmenu_common.get_message(
          'waiting_est_time',
          p_guest_locale,
          jsonb_build_object(
            'minutes', v_est_wait_minutes
          )
        ),
      'registered_message',
        catchmenu_common.get_message(
          'waiting_registered',
          p_guest_locale,
          jsonb_build_object(
            'wait_number', v_wait_number
          )
        )
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_count, guest_locale,
         phone_hash, customer_id,
         pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_waiting_customer'
    );
  end if;

  if v_session.session_status
    not in ('WAITING', 'ARRIVAL_PENDING')
  then
    return catchmenu_common.build_error_response(
      p_error_key := case
        v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 호출 상태로 변경
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    called_at = now(),
    table_number = coalesce(
      p_table_number, table_number
    ),
    call_count = coalesce(call_count, 0) + 1,
    updated_at = now()
  where id = p_session_id;

  -- DID 호출 (콜링 시스템)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_locale', v_session.guest_locale,
      'called_at', now(),
      'message',
        catchmenu_common.get_message(
          'waiting_called_alert',
          v_session.guest_locale,
          jsonb_build_object(
            'wait_number',
              v_session.wait_number
          )
        )
    )
  );

  -- DID 디스플레이 표시
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'display_number', v_session.wait_number,
      'table_number', p_table_number,
      'queue_type', 'WAITING_CALL',
      'guest_locale', v_session.guest_locale
    )
  );

  -- 고객 앱 푸시 알림
  if v_session.phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', v_session.phone_hash,
        'customer_id', v_session.customer_id,
        'notification_type', 'WAITING_CALLED',
        'wait_number', v_session.wait_number,
        'table_number', p_table_number,
        'locale', v_session.guest_locale
      )
    );
  end if;

  -- ledger event (특허1)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_called', 1,
    'order_session', p_session_id,
    'WAITING', 'ARRIVAL_PENDING',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'has_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_locale', v_session.guest_locale,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'did_called', true,
      'push_sent',
        v_session.phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_session.wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.pre_order_while_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cart_items jsonb,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_session record;
  v_order_id uuid;
  v_order_number text;
  v_total_amount int := 0;
  v_item jsonb;
  v_menu record;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 대기 세션 확인
  select id, wait_number, session_status,
         guest_count, guest_locale
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 대기 중 또는 호출 상태에서만 사전 주문 가능
  if v_session.session_status
    not in ('WAITING', 'ARRIVAL_PENDING')
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'pre_order_requires_waiting',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'pre_order_while_waiting'
    );
  end if;

  -- 금액 계산 + 품절 확인
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price, menu_status,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_menu.menu_status = 'SOLD_OUT' then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_sold_out',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'menu_name', v_menu.menu_name
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'pre_order_while_waiting'
      );
    end if;

    v_total_amount := v_total_amount
      + v_menu.price
        * (v_item->>'quantity')::int;
  end loop;

  -- 사전 주문 번호
  v_order_number := 'W' || lpad(
    v_session.wait_number::text, 3, '0'
  );

  -- 주문 생성 (TABLE 타입, PRE_ORDER 소스)
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    p_session_id, v_order_number,
    'TABLE', 'CONFIRMED',
    'PRE_ORDER',
    v_total_amount, v_total_amount,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- 주문 항목 + KDS 티켓 (HOLD = 특허2 핵심)
  for v_item in
    select * from jsonb_array_elements(
      p_cart_items
    )
  loop
    select id, menu_name, price,
           is_kds_required, kitchen_zone
    into v_menu
    from catchmenu_pos.menus
    where id = (v_item->>'menu_id')::uuid
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity, unit_price, subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu.id,
      v_menu.menu_name,
      (v_item->>'quantity')::int,
      v_menu.price,
      v_menu.price * (v_item->>'quantity')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- ==========================================
    -- 특허2 + 특허1 결합 핵심
    -- 대기 중 사전 주문 → KDS HOLD
    -- 착석 확인 후 결제 → COMMITTED
    -- "대기하면서 메뉴 선택,
    --  착석하자마자 신선하게 나오는 시스템"
    -- ==========================================
    if v_menu.is_kds_required then
      insert into catchmenu_kds.kds_tickets (
        tenant_id, store_id,
        order_id, menu_id,
        menu_name_snapshot,
        quantity_snapshot,
        kitchen_zone, kds_status,
        conditions_met,
        ticket_created_at,
        business_day, business_timezone
      ) values (
        p_tenant_id, p_store_id,
        v_order_id, v_menu.id,
        v_menu.menu_name,
        (v_item->>'quantity')::int,
        coalesce(v_menu.kitchen_zone, 'MAIN'),
        'HOLD',
        jsonb_build_object(
          'payment_confirmed', false,
          'kds_release_authorized', false,
          'waiting_session_id', p_session_id,
          'wait_number',
            v_session.wait_number,
          'order_source', 'PRE_ORDER',
          'release_trigger',
            'seat_confirmed_or_payment'
        ),
        now(),
        v_business_day, v_timezone
      );
    end if;
  end loop;

  -- 세션 사전 주문 금액 업데이트
  update catchmenu_pos.order_sessions
  set
    session_type = 'PRE_ORDER',
    pre_order_amount = v_total_amount,
    updated_at = now()
  where id = p_session_id;

  -- ledger event (특허1 + 특허2)
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
    'waiting', 'pre_order_registered', 1,
    'order_session', p_session_id,
    'WAITING', 'PRE_ORDER',
    'CUSTOMER',
    jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'patent_note',
        'Patent1+2: Pre-order HOLD until seated'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'pre_order_registered',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'wait_number', v_session.wait_number,
      'pre_order_amount', v_total_amount,
      'kds_status', 'HOLD',
      'kds_note',
        catchmenu_common.get_message(
          'pre_order_kds_note', p_locale, null
        ),
      'patent_principle', jsonb_build_object(
        'patent1',
          'Wait session tracks full journey',
        'patent2',
          'KDS HOLD until payment confirmed',
        'combined',
          'Pre-order while waiting, fresh food on seat'
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount,
         table_number
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  -- 도착 확인 상태로 변경
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    arrival_confirmed_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- Realtime 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    'WAITING', 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'table_number', v_session.table_number,
      'next_step', case
        when v_session.pre_order_amount > 0
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_pre_order record;
  v_business_day date;
  v_remaining_queue int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_count, guest_locale,
         pre_order_amount, phone_hash,
         customer_id
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 착석 처리
  update catchmenu_pos.order_sessions
  set
    session_status = 'SEATED',
    table_number = coalesce(
      p_table_number, table_number
    ),
    seated_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 있으면 KDS HOLD 유지
  -- 결제 후 confirm_payment() → COMMITTED
  -- 사전 주문 없으면 이제 주문 받으면 됨
  if v_session.pre_order_amount > 0 then
    -- 사전 주문 조회
    select id into v_pre_order
    from catchmenu_pos.orders
    where session_id = p_session_id
      and order_source = 'PRE_ORDER'
      and order_status = 'CONFIRMED'
    limit 1;

    -- KDS는 여전히 HOLD
    -- 결제 확인 후 release_kds_after_payment()
    -- 가 COMMITTED로 변경
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. '
        || 'KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount',
          v_session.pre_order_amount
      )
    );
  end if;

  -- 남은 대기 인원
  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    );

  -- Realtime → 대기 화면 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order',
        v_session.pre_order_amount > 0
    )
  );

  -- DID 호출 해제
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- ledger event (특허1 핵심: 착석 기록)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (
          now() - (
            select session_started_at
            from catchmenu_pos.order_sessions
            where id = p_session_id
          )
        )
      )::int,
      'had_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_amount > 0
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_amount > 0
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note',
              '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment',
              'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  -- 대기 취소
  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    cancel_reason = p_cancel_reason,
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 있으면 KDS 취소
  if v_session.pre_order_amount > 0 then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  -- Realtime 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         guest_locale, pre_order_amount,
         called_at
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'mark_no_show'
    );
  end if;

  -- 노쇼 처리
  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    no_show_at = now(),
    updated_at = now()
  where id = p_session_id;

  -- 사전 주문 KDS 취소
  if v_session.pre_order_amount > 0 then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  -- Realtime 업데이트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'reason', 'NO_SHOW'
    )
  );

  -- ledger event (특허1: 노쇼도 증거)
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'no_show_marked', 1,
    'order_session', p_session_id,
    v_session.session_status, 'NO_SHOW',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'called_at', v_session.called_at,
      'wait_after_call_seconds', case
        when v_session.called_at is not null
        then extract(
          epoch from (
            now() - v_session.called_at
          )
        )::int
        else null
      end,
      'had_pre_order',
        v_session.pre_order_amount > 0
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_no_show',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'no_show_at', now(),
      'pre_order_cancelled',
        v_session.pre_order_amount > 0
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'wait_number', v_session.wait_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, wait_number, session_status,
         session_type, guest_count,
         guest_locale, queue_position,
         pre_order_amount,
         table_number,
         session_started_at,
         called_at, arrival_confirmed_at,
         seated_at
  into v_session
  from catchmenu_pos.order_sessions
  where id = p_session_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  -- 현재 내 앞 대기 인원
  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in (
      'WAITING', 'ARRIVAL_PENDING'
    )
    and wait_number < v_session.wait_number;

  v_est_wait_minutes :=
    v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order',
        v_session.pre_order_amount > 0,
      'pre_order_amount',
        v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at',
          v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at',
          v_session.arrival_confirmed_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position',
          catchmenu_common.get_message(
            'waiting_current_position',
            coalesce(
              p_locale,
              v_session.guest_locale
            ),
            jsonb_build_object(
              'position', v_queue_position
            )
          ),
        'est_time',
          catchmenu_common.get_message(
            'waiting_est_time',
            coalesce(
              p_locale,
              v_session.guest_locale
            ),
            jsonb_build_object(
              'minutes', v_est_wait_minutes
            )
          )
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
  v_avg_wait_minutes int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 현재 대기 목록 (직원 관리 뷰)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', os.table_number,
        'has_pre_order',
          os.pre_order_amount > 0,
        'pre_order_amount',
          os.pre_order_amount,
        'waited_minutes', extract(
          epoch from (
            now() - os.session_started_at
          )
        )::int / 60,
        'called_at', os.called_at,
        'call_count', os.call_count,
        'memo', os.memo,
        'is_foreign',
          os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case
            when os.session_status = 'WAITING'
              then 'CALL'
            else null
          end,
          case
            when os.session_status
              in ('WAITING', 'ARRIVAL_PENDING')
              then 'SEAT'
            else null
          end,
          case
            when os.session_status
              in ('WAITING', 'ARRIVAL_PENDING')
              then 'NO_SHOW'
            else null
          end,
          'CANCEL'
        )
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
    );

  -- 오늘 통계
  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (
      where session_status = 'COMPLETED'
    ),
    'cancelled', count(*) filter (
      where session_status = 'CANCELLED'
    ),
    'no_show', count(*) filter (
      where session_status = 'NO_SHOW'
    ),
    'current_waiting',
      jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (
      where pre_order_amount > 0
    ),
    'total_pre_order_amount', coalesce(
      sum(pre_order_amount) filter (
        where pre_order_amount > 0
      ), 0
    ),
    'foreign_count', count(*) filter (
      where guest_locale <> 'ko'
    ),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (
          coalesce(
            seated_at, now()
          ) - session_started_at
        )) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting',
        jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'patent_note', jsonb_build_object(
        'patent1',
          'Full journey tracked per session',
        'patent2',
          'Pre-order KDS HOLD until payment',
        'handoff_flow',
          'register→call→arrive→seat→pay→cook'
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
  grant execute on function
    catchmenu_pos.register_waiting(
      uuid, uuid, int, text, text, text,
      uuid, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.call_waiting_customer(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.pre_order_while_waiting(
      uuid, uuid, uuid, jsonb, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.confirm_arrival(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.seat_waiting_customer(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.cancel_waiting(
      uuid, uuid, uuid, text, text, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.mark_no_show(
      uuid, uuid, uuid, uuid, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.get_waiting_status(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_pos.get_waiting_admin_view(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_pos.pre_order_while_waiting(
    uuid, uuid, uuid, jsonb, text, text
  ) is
  '대기 중 사전 주문 등록.
   특허1 + 특허2 결합 핵심 함수.

   흐름:
   1. 대기 등록 (register_waiting)
   2. 대기 중 메뉴 선택
      → pre_order_while_waiting()
      → 주문 생성 (PRE_ORDER 소스)
      → KDS = HOLD (조리 금지)
   3. 호출 (call_waiting_customer)
   4. 도착 확인 (confirm_arrival)
   5. 착석 (seat_waiting_customer)
      → KDS 여전히 HOLD
   6. 결제 (confirm_payment)
      → release_kds_after_payment()
      → KDS = COMMITTED (조리 시작!)
   7. 신선한 음식 제공

   고객 경험:
   "대기하면서 메뉴를 골랐는데
    앉자마자 음식이 나왔어요!"
   → 입소문 = 소문의 근거.

   KDS conditions_met 기록:
   waiting_session_id: 추적 가능
   release_trigger: 결제 후 자동 해제
   order_source: PRE_ORDER 구분.

   특허1: 대기 세션 전 여정 추적.
   특허2: KDS HOLD → 결제 후 COMMITTED.';

comment on function
  catchmenu_pos.register_waiting(
    uuid, uuid, int, text, text, text,
    uuid, text, text, text, text
  ) is
  '대기 등록 파이프라인.
   p_source: STAFF/KIOSK/QR/CUSTOMER_APP
   p_session_type: WAITING/PRE_ORDER

   등록 후 자동 처리:
   - Realtime → 대기 화면 + DID 업데이트
   - 전화번호 있으면 푸시 알림 예약
   - 예상 대기 시간 계산 (앞팀 × 10분)
   - 다국어 메시지 반환

   특허1: 대기 등록 = 세션 시작점.
   노쇼/이탈/착석 모두 이 세션으로 추적.
   감사 원장에 전 여정 기록.';
