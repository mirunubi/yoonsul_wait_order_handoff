-- 0116_create_customer_app_bootstrap_rpc.sql
-- Purpose: Customer app bootstrap enhancement.
--          대기 연동 + 멤버십 통합 + CMS.
--          고객 앱 단일 RPC 전체 초기화.
--          QR 스캔 → 대기 등록 흐름.
--          주문 추적 실시간 연동.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0115_create_waiting_pipeline_rpc.sql
-- Creates:
--   function catchmenu_store.bootstrap_customer_app_v2(...)
--   function catchmenu_store.get_customer_home(...)
--   function catchmenu_store.qr_scan_action(...)
--   function catchmenu_store.get_order_tracking(...)
--   function catchmenu_store.get_customer_history(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('customer_app_ready', 'ko',
  '앱이 준비되었습니다'),
('customer_app_ready', 'en',
  'App ready'),
('customer_app_ready', 'zh', '应用已准备好'),
('customer_app_ready', 'ja', 'アプリの準備ができました'),
('customer_app_ready', 'vi', 'Ứng dụng sẵn sàng'),
('customer_app_ready', 'th', 'แอปพร้อมแล้ว'),

('customer_home_ready', 'ko',
  '홈이 로드되었습니다'),
('customer_home_ready', 'en',
  'Home loaded'),

('qr_scan_processed', 'ko',
  'QR 스캔이 처리되었습니다'),
('qr_scan_processed', 'en',
  'QR scan processed'),

('order_tracking_loaded', 'ko',
  '주문 현황이 로드되었습니다'),
('order_tracking_loaded', 'en',
  'Order tracking loaded'),

('customer_history_loaded', 'ko',
  '주문 내역이 로드되었습니다'),
('customer_history_loaded', 'en',
  'Order history loaded'),

('qr_waiting_register', 'ko',
  'QR로 대기 등록이 완료되었습니다'),
('qr_waiting_register', 'en',
  'Waiting registered via QR'),
('qr_waiting_register', 'zh',
  '已通过QR码登记候位'),
('qr_waiting_register', 'ja',
  'QRコードで順番待ちを登録しました'),
('qr_waiting_register', 'vi',
  'Đã đăng ký chờ qua QR'),
('qr_waiting_register', 'th',
  'ลงทะเบียนรอผ่าน QR แล้ว'),

('qr_table_order', 'ko',
  '테이블 주문 모드로 전환됩니다'),
('qr_table_order', 'en',
  'Switching to table order mode'),
('qr_table_order', 'zh',
  '切换至桌台点餐模式'),
('qr_table_order', 'ja',
  'テーブル注文モードに切り替えます'),
('qr_table_order', 'vi',
  'Chuyển sang chế độ đặt bàn'),
('qr_table_order', 'th',
  'สลับไปโหมดสั่งอาหารที่โต๊ะ'),

('order_cooking', 'ko', '조리 중입니다'),
('order_cooking', 'en', 'Cooking'),
('order_cooking', 'zh', '烹饪中'),
('order_cooking', 'ja', '調理中'),
('order_cooking', 'vi', 'Đang nấu'),
('order_cooking', 'th', 'กำลังปรุง'),

('order_completed_msg', 'ko',
  '주문이 완료되었습니다'),
('order_completed_msg', 'en',
  'Order completed'),
('order_completed_msg', 'zh', '订单已完成'),
('order_completed_msg', 'ja', 'ご注文が完了しました'),
('order_completed_msg', 'vi', 'Đơn hàng hoàn thành'),
('order_completed_msg', 'th', 'คำสั่งซื้อเสร็จสิ้น')
on conflict (message_key, locale) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.bootstrap_customer_app_v2(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid default null,
  p_phone_hash text default null,
  p_locale text default 'ko',
  p_app_version text default null,
  p_push_token text default null,
  p_os_type text default null
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
  v_store record;
  v_store_settings record;
  v_customer record;
  v_membership jsonb;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_cms_bundle jsonb;
  v_menu_preview jsonb;
  v_business_day date;
  v_day_of_week int;
  v_business_hours record;
  v_is_open boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 정보
  select id, store_name, store_type, timezone
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
      p_rpc_name := 'bootstrap_customer_app_v2'
    );
  end if;

  -- 매장 설정
  select store_mode, waiting_enabled,
         pre_order_enabled, min_order_amount
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 영업시간 확인
  select is_open, open_time, close_time,
         last_order_time
  into v_business_hours
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  v_is_open := case
    when coalesce(
      v_store_settings.store_mode, 'NORMAL'
    ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY')
      then false
    when v_business_hours.is_open = false
      then false
    else true
  end;

  -- 고객 정보 + 멤버십
  if p_customer_id is not null then
    select id, display_name, membership_tier,
           total_points, visit_count,
           last_visit_at, locale
    into v_customer
    from catchmenu_store.customers
    where id = p_customer_id
      and tenant_id = p_tenant_id
      and is_active = true;

    if v_customer.id is not null then
      -- 멤버십 조회
      v_membership := (
        catchmenu_store.get_customer_membership(
          p_tenant_id := p_tenant_id,
          p_store_id := p_store_id,
          p_customer_id := p_customer_id,
          p_locale := p_locale
        )
      )->'data';

      -- 현재 대기 세션 확인
      select jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'session_status', os.session_status,
        'queue_position', (
          select count(*)
          from catchmenu_pos.order_sessions
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and business_day = v_business_day
            and session_status in (
              'WAITING', 'ARRIVAL_PENDING'
            )
            and wait_number < os.wait_number
        ),
        'has_pre_order',
          os.pre_order_amount > 0,
        'pre_order_amount',
          os.pre_order_amount
      )
      into v_active_waiting
      from catchmenu_pos.order_sessions os
      where os.store_id = p_store_id
        and os.tenant_id = p_tenant_id
        and os.customer_id = p_customer_id
        and os.business_day = v_business_day
        and os.session_status in (
          'WAITING', 'ARRIVAL_PENDING', 'SEATED'
        )
      order by os.session_started_at desc
      limit 1;

      -- 현재 진행 중 주문 확인
      select jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_status', o.order_status,
        'order_type', o.order_type,
        'final_amount', o.final_amount,
        'kds_status', (
          select max(kds_status)
          from catchmenu_kds.kds_tickets
          where order_id = o.id
        ),
        'is_paid', exists (
          select 1
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
        )
      )
      into v_active_order
      from catchmenu_pos.orders o
      where o.store_id = p_store_id
        and o.tenant_id = p_tenant_id
        and o.business_day = v_business_day
        and o.order_status in (
          'CONFIRMED', 'COOKING',
          'READY', 'PAID'
        )
        and exists (
          select 1
          from catchmenu_pos.order_sessions os
          where os.id = o.session_id
            and os.customer_id = p_customer_id
        )
      order by o.ordered_at desc
      limit 1;

      -- 푸시 토큰 업데이트
      if p_push_token is not null then
        update catchmenu_store.customers
        set
          locale = p_locale,
          updated_at = now()
        where id = p_customer_id;
      end if;
    end if;
  end if;

  -- CMS 번들 (이벤트/배너/팝업)
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  -- 메뉴 미리보기 (인기 5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', case p_locale
          when 'en' then coalesce(
            m.menu_name_en, m.menu_name
          )
          when 'zh' then coalesce(
            m.menu_name_zh, m.menu_name
          )
          when 'ja' then coalesce(
            m.menu_name_ja, m.menu_name
          )
          else m.menu_name
        end,
        'price', m.price,
        'thumbnail_url', m.thumbnail_url,
        'menu_status', m.menu_status
      )
      order by m.display_order asc
    ),
    '[]'::jsonb
  )
  into v_menu_preview
  from catchmenu_pos.menus m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and m.menu_status = 'AVAILABLE'
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_app_ready',
    p_data := jsonb_build_object(

      -- 매장
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_type', v_store.store_type,
        'is_open', v_is_open,
        'store_mode', coalesce(
          v_store_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_store_settings.waiting_enabled, true
        ),
        'min_order_amount', coalesce(
          v_store_settings.min_order_amount, 0
        ),
        'business_hours', case
          when v_business_hours.open_time
            is not null
          then jsonb_build_object(
            'open_time',
              v_business_hours.open_time,
            'close_time',
              v_business_hours.close_time,
            'last_order_time',
              v_business_hours.last_order_time
          )
          else null
        end
      ),

      -- 고객
      'customer', case
        when v_customer.id is not null
        then jsonb_build_object(
          'id', v_customer.id,
          'display_name', v_customer.display_name,
          'membership_tier',
            v_customer.membership_tier,
          'total_points', v_customer.total_points,
          'visit_count', v_customer.visit_count
        )
        else null
      end,

      -- 멤버십
      'membership', v_membership,

      -- 현재 대기
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,

      -- 진행 중 주문
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,

      -- CMS
      'cms', v_cms_bundle->'data',

      -- 메뉴 미리보기
      'menu_preview', v_menu_preview,

      -- Realtime 채널
      'realtime_channel',
        'customer_app:' || p_store_id,

      'business_day', v_business_day,
      'bootstrapped_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.qr_scan_action(
  p_tenant_id uuid,
  p_store_id uuid,
  p_qr_type text,
  p_qr_data text,
  p_customer_id uuid default null,
  p_guest_count int default 1,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_result jsonb;
  v_table_number text;
  v_kiosk_id uuid;
begin
  case p_qr_type

    -- 대기 QR 스캔 → 대기 등록
    when 'WAITING_REGISTER' then
      v_result := catchmenu_pos.register_waiting(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_guest_count := p_guest_count,
        p_session_type := 'WAITING',
        p_guest_locale := p_locale,
        p_customer_id := p_customer_id,
        p_source := 'QR',
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_waiting_register',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'action_result', v_result->'data'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    -- 테이블 QR 스캔 → 테이블 주문 모드
    when 'TABLE_ORDER' then
      v_table_number := p_qr_data;

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_table_order',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'table_number', v_table_number,
          'action', 'SWITCH_TO_TABLE_ORDER',
          'next_screen', 'MENU_CATALOG',
          'order_type', 'TABLE'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    -- 키오스크 QR → 키오스크 세션 연결
    when 'KIOSK_SESSION' then
      v_kiosk_id := p_qr_data::uuid;

      return catchmenu_common
        .build_success_response(
        p_message_key := 'qr_scan_processed',
        p_data := jsonb_build_object(
          'qr_type', p_qr_type,
          'kiosk_id', v_kiosk_id,
          'action', 'LINK_KIOSK_SESSION',
          'next_screen', 'KIOSK_MENU'
        ),
        p_locale := p_locale,
        p_correlation_id := p_correlation_id
      );

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'field', 'qr_type',
          'value', p_qr_type
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'qr_scan_action'
      );
  end case;
end;
$$;


create or replace function
  catchmenu_store.get_order_tracking(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_order record;
  v_kds_tickets jsonb;
  v_payment record;
  v_tracking_status text;
  v_tracking_message text;
begin
  select id, order_number, order_status,
         order_type, order_source,
         final_amount, ordered_at,
         paid_at, session_id
  into v_order
  from catchmenu_pos.orders
  where id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id;

  if v_order.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_order_tracking'
    );
  end if;

  -- KDS 티켓 상태
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ticket_id', id,
        'menu_name', menu_name_snapshot,
        'quantity', quantity_snapshot,
        'kds_status', kds_status,
        'kitchen_zone', kitchen_zone,
        'is_late', is_late,
        'committed_at', committed_at,
        'cooking_started_at',
          cooking_started_at,
        'served_at', served_at
      )
      order by ticket_created_at asc
    ),
    '[]'::jsonb
  )
  into v_kds_tickets
  from catchmenu_kds.kds_tickets
  where order_id = p_order_id
    and store_id = p_store_id;

  -- 결제 정보
  select id, ledger_status, approved_amount,
         approved_at, payment_method
  into v_payment
  from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and ledger_status = 'APPROVED'
  order by approved_at desc
  limit 1;

  -- 추적 상태 + 메시지
  v_tracking_status := case
    when v_payment.id is null
      then 'WAITING_PAYMENT'
    when v_order.order_status = 'READY'
      then 'READY'
    when exists (
      select 1 from catchmenu_kds.kds_tickets
      where order_id = p_order_id
        and kds_status = 'COOKING'
    ) then 'COOKING'
    when exists (
      select 1 from catchmenu_kds.kds_tickets
      where order_id = p_order_id
        and kds_status = 'COMMITTED'
    ) then 'CONFIRMED'
    when v_order.order_status = 'COMPLETED'
      then 'COMPLETED'
    else 'PROCESSING'
  end;

  v_tracking_message :=
    catchmenu_common.get_message(
      case v_tracking_status
        when 'COOKING'
          then 'order_cooking'
        when 'READY'
          then 'order_ready'
        when 'COMPLETED'
          then 'order_completed_msg'
        else 'order_confirmed'
      end,
      p_locale,
      jsonb_build_object(
        'order_number', v_order.order_number
      )
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'order_tracking_loaded',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'order_type', v_order.order_type,
      'order_source', v_order.order_source,
      'tracking_status', v_tracking_status,
      'tracking_message', v_tracking_message,
      'is_paid', v_payment.id is not null,
      'payment', case
        when v_payment.id is not null
        then jsonb_build_object(
          'amount', v_payment.approved_amount,
          'method', v_payment.payment_method,
          'approved_at', v_payment.approved_at
        )
        else null
      end,
      'kds_tickets', v_kds_tickets,
      'final_amount', v_order.final_amount,
      'ordered_at', v_order.ordered_at,
      'paid_at', v_order.paid_at,
      'realtime_channel',
        'customer_app:' || p_store_id
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_customer_history(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
  p_limit int default 20,
  p_offset int default 0,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_orders jsonb;
  v_total_count int;
  v_total_spent int;
begin
  select count(*) into v_total_count
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    )
    and o.order_status in (
      'COMPLETED', 'CANCELLED'
    );

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'order_id', o.id,
        'order_number', o.order_number,
        'order_type', o.order_type,
        'order_status', o.order_status,
        'final_amount', o.final_amount,
        'ordered_at', o.ordered_at,
        'items', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'menu_name',
                  oi.menu_name_snapshot,
                'quantity', oi.quantity,
                'subtotal', oi.subtotal
              )
            ),
            '[]'::jsonb
          )
          from catchmenu_pos.order_items oi
          where oi.order_id = o.id
        ),
        'payment_method', (
          select payment_method
          from catchmenu_payment.payment_ledger
          where order_id = o.id
            and ledger_status = 'APPROVED'
          limit 1
        ),
        'earned_points', coalesce(
          (
            select points
            from catchmenu_store.point_ledger
            where order_id = o.id
              and point_type = 'EARN'
              and customer_id = p_customer_id
            limit 1
          ), 0
        )
      )
      order by o.ordered_at desc
    ),
    '[]'::jsonb
  )
  into v_orders
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    )
    and o.order_status in (
      'COMPLETED', 'CANCELLED'
    )
  order by o.ordered_at desc
  limit p_limit
  offset p_offset;

  -- 총 사용 금액
  select coalesce(sum(o.final_amount), 0)
  into v_total_spent
  from catchmenu_pos.orders o
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.order_status = 'COMPLETED'
    and exists (
      select 1
      from catchmenu_pos.order_sessions os
      where os.id = o.session_id
        and os.customer_id = p_customer_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_history_loaded',
    p_data := jsonb_build_object(
      'orders', v_orders,
      'total_count', v_total_count,
      'page_count',
        jsonb_array_length(v_orders),
      'total_spent', v_total_spent,
      'limit', p_limit,
      'offset', p_offset
    ),
    p_locale := p_locale
  );
end;
$$;


-- 0081's original get_customer_home used a different parameter
-- order/defaults (p_customer_id before p_store_id, p_store_id
-- optional). This file supersedes it with a more complete, dedicated
-- implementation; no already-applied code depends on the old
-- signature, so the old function is dropped first.
drop function if exists catchmenu_store.get_customer_home(
  uuid, uuid, uuid, text
);

create or replace function
  catchmenu_store.get_customer_home(
  p_tenant_id uuid,
  p_store_id uuid,
  p_customer_id uuid,
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
  v_customer record;
  v_active_waiting jsonb;
  v_active_order jsonb;
  v_stamp_card jsonb;
  v_available_coupons jsonb;
  v_cms_bundle jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, display_name, membership_tier,
         total_points
  into v_customer
  from catchmenu_store.customers
  where id = p_customer_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 현재 대기 세션
  select jsonb_build_object(
    'session_id', os.id,
    'wait_number', os.wait_number,
    'session_status', os.session_status,
    'has_pre_order',
      os.pre_order_amount > 0,
    'queue_position', (
      select count(*)
      from catchmenu_pos.order_sessions w
      where w.store_id = p_store_id
        and w.tenant_id = p_tenant_id
        and w.business_day = v_business_day
        and w.session_status in (
          'WAITING', 'ARRIVAL_PENDING'
        )
        and w.wait_number < os.wait_number
    )
  )
  into v_active_waiting
  from catchmenu_pos.order_sessions os
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.customer_id = p_customer_id
    and os.business_day = v_business_day
    and os.session_status in (
      'WAITING', 'ARRIVAL_PENDING', 'SEATED'
    )
  order by os.session_started_at desc
  limit 1;

  -- 진행 중 주문
  select jsonb_build_object(
    'order_id', o.id,
    'order_number', o.order_number,
    'order_status', o.order_status,
    'final_amount', o.final_amount
  )
  into v_active_order
  from catchmenu_pos.orders o
  join catchmenu_pos.order_sessions os
    on os.id = o.session_id
    and os.customer_id = p_customer_id
  where o.store_id = p_store_id
    and o.tenant_id = p_tenant_id
    and o.business_day = v_business_day
    and o.order_status in (
      'CONFIRMED', 'COOKING', 'READY'
    )
  order by o.ordered_at desc
  limit 1;

  -- 스탬프 카드
  select jsonb_build_object(
    'current_stamps', current_stamps,
    'stamp_goal', stamp_goal,
    'remaining_stamps',
      greatest(0, stamp_goal - current_stamps)
  )
  into v_stamp_card
  from catchmenu_store.stamp_cards
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and customer_id = p_customer_id
    and card_status = 'ACTIVE';

  -- 사용 가능 쿠폰
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'coupon_issue_id', ci.id,
        'coupon_name', c.coupon_name,
        'discount_type', c.discount_type,
        'discount_value', c.discount_value,
        'valid_until', ci.valid_until
      )
      order by ci.valid_until asc
    ),
    '[]'::jsonb
  )
  into v_available_coupons
  from catchmenu_store.coupon_issues ci
  join catchmenu_store.coupons c
    on c.id = ci.coupon_id
  where ci.store_id = p_store_id
    and ci.tenant_id = p_tenant_id
    and ci.customer_id = p_customer_id
    and ci.is_used = false
    and ci.valid_until > now()
  limit 5;

  -- CMS 번들
  v_cms_bundle :=
    catchmenu_store.get_cms_display_bundle(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_display_target := 'CUSTOMER_APP',
      p_trigger_event := 'APP_OPEN',
      p_locale := p_locale
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'customer_home_ready',
    p_data := jsonb_build_object(
      'customer', jsonb_build_object(
        'id', v_customer.id,
        'display_name', v_customer.display_name,
        'membership_tier',
          v_customer.membership_tier,
        'total_points', v_customer.total_points
      ),
      'active_waiting', v_active_waiting,
      'has_active_waiting',
        v_active_waiting is not null,
      'active_order', v_active_order,
      'has_active_order',
        v_active_order is not null,
      'stamp_card', v_stamp_card,
      'available_coupons', v_available_coupons,
      'coupon_count',
        jsonb_array_length(
          coalesce(
            v_available_coupons, '[]'::jsonb
          )
        ),
      'cms', v_cms_bundle->'data',
      'business_day', v_business_day,
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
    catchmenu_store.bootstrap_customer_app_v2(
      uuid, uuid, uuid, text, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.qr_scan_action(
      uuid, uuid, text, text, uuid, int, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_order_tracking(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_customer_history(
      uuid, uuid, uuid, int, int, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_customer_home(
      uuid, uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.bootstrap_customer_app_v2(
    uuid, uuid, uuid, text, text, text, text, text
  ) is
  '고객 앱 부트스트랩 v2.
   단일 RPC 전체 초기화.

   반환 데이터:
   - 매장 정보 + 영업 여부
   - 고객 정보 + 멤버십
   - 현재 대기 세션 (있으면)
   - 진행 중 주문 (있으면)
   - CMS 이벤트/배너/팝업
   - 메뉴 미리보기 5개
   - Realtime 채널

   특허1 연동:
   active_waiting → 대기 현황 즉시 표시
   has_pre_order → 사전 주문 여부

   Flutter 앱 시작 흐름:
   1. bootstrap_customer_app_v2()
   2. has_active_waiting → 대기 화면
   3. has_active_order → 주문 추적
   4. cms popups → 팝업 표시
   5. Realtime 구독';

comment on function
  catchmenu_store.qr_scan_action(
    uuid, uuid, text, text, uuid, int, text, text
  ) is
  'QR 스캔 액션 라우터.
   QR 타입별 자동 처리.

   WAITING_REGISTER:
     register_waiting() 자동 호출
     → 대기 등록 완료
   TABLE_ORDER:
     table_number 반환
     → 테이블 주문 모드 전환
   KIOSK_SESSION:
     kiosk_id 반환
     → 키오스크 세션 연결

   Flutter QR 스캔:
   camera 패키지 → qr_code_scanner
   → qr_scan_action() 호출
   → next_screen 기반 라우팅.';