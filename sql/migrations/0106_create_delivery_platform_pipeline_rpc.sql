-- 0106_create_delivery_platform_pipeline_rpc.sql
-- Purpose: Delivery platform integration pipeline.
--          배달의민족 / 요기요 / 쿠팡이츠 연동.
--          주문 수신, 상태 업데이트, 자동 거절.
--          KDS Late Binding 연동 (특허2).
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0105_create_cash_receipt_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.delivery_intake_log (table)
--   function catchmenu_integrations.receive_delivery_order(...)
--   function catchmenu_integrations.accept_delivery_order(...)
--   function catchmenu_integrations.reject_delivery_order(...)
--   function catchmenu_integrations.update_delivery_status(...)
--   function catchmenu_integrations.get_delivery_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('delivery_order_received', 'ko',
  '배달 주문이 접수되었습니다: {order_number}번'),
('delivery_order_received', 'en',
  'Delivery order received: #{order_number}'),
('delivery_order_received', 'zh',
  '收到外卖订单：{order_number}号'),
('delivery_order_received', 'ja',
  'デリバリー注文を受け付けました：{order_number}番'),
('delivery_order_received', 'vi',
  'Nhận đơn giao hàng: #{order_number}'),
('delivery_order_received', 'th',
  'รับคำสั่งซื้อจัดส่ง: #{order_number}'),
('delivery_order_accepted', 'ko',
  '배달 주문이 수락되었습니다'),
('delivery_order_accepted', 'en',
  'Delivery order accepted'),
('delivery_order_rejected', 'ko',
  '배달 주문이 거절되었습니다'),
('delivery_order_rejected', 'en',
  'Delivery order rejected'),
('delivery_status_updated', 'ko',
  '배달 상태가 업데이트되었습니다'),
('delivery_status_updated', 'en',
  'Delivery status updated'),
('delivery_dashboard_loaded', 'ko',
  '배달 대시보드가 로드되었습니다'),
('delivery_dashboard_loaded', 'en',
  'Delivery dashboard loaded'),
('delivery_order_duplicate', 'ko',
  '이미 접수된 배달 주문입니다'),
('delivery_order_duplicate', 'en',
  'Duplicate delivery order'),
('delivery_auto_rejected', 'ko',
  '매장 상황으로 배달 주문이 자동 거절되었습니다'),
('delivery_auto_rejected', 'en',
  'Delivery order auto-rejected'),
('delivery_cooking_started', 'ko',
  '조리가 시작되었습니다'),
('delivery_cooking_started', 'en',
  'Cooking started'),
('delivery_ready_for_pickup', 'ko',
  '배달 픽업 준비가 완료되었습니다'),
('delivery_ready_for_pickup', 'en',
  'Ready for pickup'),
('delivery_picked_up', 'ko',
  '배달 기사가 픽업했습니다'),
('delivery_picked_up', 'en',
  'Picked up by rider')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_runbook_code
) values
(9050, 'delivery_order_duplicate',
  'DELIVERY', 'CONFLICT', 409, 'INFO', null),
(9051, 'delivery_platform_not_configured',
  'DELIVERY', 'NOT_FOUND', 404, 'ERROR',
  'SOP-DEL-001'),
(9052, 'delivery_order_accept_failed',
  'DELIVERY', 'TECHNICAL', 500, 'ERROR',
  'SOP-DEL-001'),
(9053, 'delivery_order_reject_failed',
  'DELIVERY', 'TECHNICAL', 500, 'ERROR',
  'SOP-DEL-001'),
(9054, 'delivery_status_update_failed',
  'DELIVERY', 'TECHNICAL', 500, 'ERROR',
  'SOP-DEL-001')
on conflict (code) do nothing;


-- =============================================
-- delivery_intake_log table
-- 배달 주문 수신 이력
-- =============================================
create table if not exists
  catchmenu_integrations.delivery_intake_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 플랫폼 정보
  platform_code text not null,
  platform_order_id text not null,
  platform_order_number text,

  -- 내부 주문 연결
  order_id uuid
    references catchmenu_pos.orders(id),

  -- 수신 페이로드
  raw_payload jsonb not null,
  parsed_items jsonb,

  -- 금액
  item_amount int not null default 0,
  delivery_fee int not null default 0,
  discount_amount int not null default 0,
  final_amount int not null default 0,

  -- 처리 상태
  intake_status text not null default 'RECEIVED',
  reject_reason text,
  reject_message text,

  -- 타임스탬프
  platform_ordered_at timestamptz,
  received_at timestamptz
    not null default now(),
  accepted_at timestamptz,
  rejected_at timestamptz,

  -- 자동 처리
  is_auto_rejected boolean
    not null default false,
  auto_reject_reason text,

  business_day date,
  updated_at timestamptz not null default now(),

  constraint uq_delivery_platform_order unique (
    store_id, platform_code, platform_order_id
  ),
  constraint chk_platform_code check (
    platform_code in (
      'BAEMIN',      -- 배달의민족
      'YOGIYO',      -- 요기요
      'COUPANG_EATS' -- 쿠팡이츠
    )
  ),
  constraint chk_intake_status check (
    intake_status in (
      'RECEIVED',    -- 수신
      'ACCEPTED',    -- 수락
      'REJECTED',    -- 거절
      'CANCELLED',   -- 취소 (플랫폼)
      'COMPLETED',   -- 완료
      'ERROR'        -- 오류
    )
  )
);

create index if not exists idx_delivery_intake
  on catchmenu_integrations.delivery_intake_log(
    store_id, platform_code,
    received_at desc
  );
create index if not exists idx_delivery_intake_order
  on catchmenu_integrations.delivery_intake_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_delivery_intake_pending
  on catchmenu_integrations.delivery_intake_log(
    store_id, intake_status, received_at
  ) where intake_status = 'RECEIVED';

alter table
  catchmenu_integrations.delivery_intake_log
  enable row level security;
alter table
  catchmenu_integrations.delivery_intake_log
  force row level security;

drop policy if exists delivery_intake_isolation
  on catchmenu_integrations.delivery_intake_log;
create policy delivery_intake_isolation
  on catchmenu_integrations.delivery_intake_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_delivery_intake_updated
  on catchmenu_integrations.delivery_intake_log;
create trigger trg_delivery_intake_updated
  before update on
    catchmenu_integrations.delivery_intake_log
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.delivery_intake_log is
  '배달 주문 수신 이력.
   3대 플랫폼: BAEMIN/YOGIYO/COUPANG_EATS.
   uq_delivery_platform_order: 중복 수신 방지.
   is_auto_rejected: KDS 과부하 시 자동 거절.
   raw_payload: 플랫폼 원본 데이터 보관.
   특허2: 배달 주문도 KDS Late Binding 적용.
   특허4: 배달 주문 = 감사 증빙.
   1-B차 배달 연동 핵심 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.receive_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_platform_code text,
  p_platform_order_id text,
  p_raw_payload jsonb,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_intake_id uuid;
  v_order_id uuid;
  v_order_number text;
  v_store_settings record;
  v_platform_rules record;
  v_kds_capacity jsonb;
  v_parsed_items jsonb;
  v_item jsonb;
  v_item_amount int := 0;
  v_delivery_fee int := 0;
  v_discount_amount int := 0;
  v_final_amount int := 0;
  v_platform_ordered_at timestamptz;
  v_platform_order_number text;
  v_auto_reject boolean := false;
  v_auto_reject_reason text;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 중복 수신 방지
  if exists (
    select 1
    from catchmenu_integrations.delivery_intake_log
    where store_id = p_store_id
      and platform_code = p_platform_code
      and platform_order_id = p_platform_order_id
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'delivery_order_duplicate',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'receive_delivery_order'
    );
  end if;

  -- 매장 설정 조회
  select store_mode, waiting_enabled,
         pre_order_enabled
  into v_store_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 플랫폼별 규칙 조회
  select auto_accept_enabled,
         auto_reject_when_busy,
         auto_reject_when_closed,
         max_concurrent_delivery_orders,
         reject_message_overloaded,
         reject_message_closed
  into v_platform_rules
  from catchmenu_integrations.delivery_platform_rules
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_code = p_platform_code
    and is_active = true;

  -- 자동 거절 판단
  -- 1. 매장 CLOSED/HOLIDAY/EMERGENCY
  if coalesce(
    v_store_settings.store_mode, 'NORMAL'
  ) in ('CLOSED', 'HOLIDAY', 'EMERGENCY') then
    v_auto_reject := true;
    v_auto_reject_reason := 'store_closed';
  end if;

  -- 2. KDS 과부하
  if not v_auto_reject then
    v_kds_capacity :=
      catchmenu_kds.check_kds_capacity(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id
      );

    if (v_kds_capacity->'data'
      ->>'is_overloaded')::boolean
    then
      v_auto_reject := true;
      v_auto_reject_reason := 'kds_overloaded';
    end if;
  end if;

  -- 플랫폼별 페이로드 파싱
  case p_platform_code
    when 'BAEMIN' then
      v_platform_order_number :=
        p_raw_payload->>'orderNo';
      v_platform_ordered_at := (
        p_raw_payload->>'orderTime'
      )::timestamptz;
      v_item_amount := coalesce(
        (p_raw_payload->>'foodTotalPrice')::int,
        0
      );
      v_delivery_fee := coalesce(
        (p_raw_payload->>'deliveryTip')::int, 0
      );
      v_discount_amount := coalesce(
        (p_raw_payload->>'discountPrice')::int, 0
      );
      v_final_amount :=
        v_item_amount + v_delivery_fee
        - v_discount_amount;

      -- 배민 메뉴 항목 파싱
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menu_name',
              item->>'menuName',
            'quantity',
              (item->>'count')::int,
            'unit_price',
              (item->>'price')::int,
            'subtotal',
              (item->>'totalPrice')::int,
            'options',
              item->'optionGroups'
          )
        ),
        '[]'::jsonb
      )
      into v_parsed_items
      from jsonb_array_elements(
        p_raw_payload->'orderItems'
      ) as item;

    when 'YOGIYO' then
      v_platform_order_number :=
        p_raw_payload->>'order_number';
      v_platform_ordered_at := (
        p_raw_payload->>'ordered_at'
      )::timestamptz;
      v_item_amount := coalesce(
        (p_raw_payload->>'total_price')::int, 0
      );
      v_delivery_fee := coalesce(
        (p_raw_payload->>'delivery_fee')::int, 0
      );
      v_discount_amount := coalesce(
        (p_raw_payload->>'discount')::int, 0
      );
      v_final_amount :=
        v_item_amount + v_delivery_fee
        - v_discount_amount;

      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menu_name',
              item->>'name',
            'quantity',
              (item->>'quantity')::int,
            'unit_price',
              (item->>'price')::int,
            'subtotal',
              (
                (item->>'price')::int
                * (item->>'quantity')::int
              ),
            'options',
              item->'options'
          )
        ),
        '[]'::jsonb
      )
      into v_parsed_items
      from jsonb_array_elements(
        p_raw_payload->'order_items'
      ) as item;

    when 'COUPANG_EATS' then
      v_platform_order_number :=
        p_raw_payload->>'vendorOrderKey';
      v_platform_ordered_at := (
        p_raw_payload->>'orderedAt'
      )::timestamptz;
      v_item_amount := coalesce(
        (p_raw_payload->>'itemsTotalPrice')
          ::int, 0
      );
      v_delivery_fee := coalesce(
        (p_raw_payload->>'deliveryFee')::int, 0
      );
      v_discount_amount := coalesce(
        (p_raw_payload->>'discountAmount')::int, 0
      );
      v_final_amount :=
        v_item_amount + v_delivery_fee
        - v_discount_amount;

      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menu_name',
              item->>'menuName',
            'quantity',
              (item->>'quantity')::int,
            'unit_price',
              (item->>'unitPrice')::int,
            'subtotal',
              (item->>'totalPrice')::int,
            'options',
              item->'options'
          )
        ),
        '[]'::jsonb
      )
      into v_parsed_items
      from jsonb_array_elements(
        p_raw_payload->'orderItems'
      ) as item;

    else
      v_parsed_items := '[]'::jsonb;
      v_final_amount := 0;
  end case;

  -- 수신 로그 생성
  insert into
    catchmenu_integrations.delivery_intake_log (
    tenant_id, store_id,
    platform_code, platform_order_id,
    platform_order_number,
    raw_payload, parsed_items,
    item_amount, delivery_fee,
    discount_amount, final_amount,
    platform_ordered_at,
    intake_status,
    is_auto_rejected,
    auto_reject_reason,
    business_day
  ) values (
    p_tenant_id, p_store_id,
    p_platform_code, p_platform_order_id,
    v_platform_order_number,
    p_raw_payload, v_parsed_items,
    v_item_amount, v_delivery_fee,
    v_discount_amount, v_final_amount,
    v_platform_ordered_at,
    case v_auto_reject
      when true then 'REJECTED'
      else 'RECEIVED'
    end,
    v_auto_reject,
    v_auto_reject_reason,
    v_business_day
  )
  returning id into v_intake_id;

  -- 자동 거절 처리
  if v_auto_reject then
    -- Edge Function에 거절 응답 요청
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'delivery_order_reject_requested',
      p_payload := jsonb_build_object(
        'intake_id', v_intake_id,
        'platform_code', p_platform_code,
        'platform_order_id',
          p_platform_order_id,
        'reject_reason', v_auto_reject_reason,
        'reject_message', case v_auto_reject_reason
          when 'kds_overloaded' then
            catchmenu_common.get_message(
              'reject_message_overloaded',
              p_locale, null
            )
          else
            catchmenu_common.get_message(
              'reject_message_closed',
              p_locale, null
            )
        end,
        'correlation_id', p_correlation_id
      )
    );

    -- 직원 알림
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'STAFF_ALERTS',
      p_event_type := 'delivery_auto_rejected',
      p_payload := jsonb_build_object(
        'platform_code', p_platform_code,
        'platform_order_number',
          v_platform_order_number,
        'auto_reject_reason',
          v_auto_reject_reason,
        'final_amount', v_final_amount
      )
    );

    return catchmenu_common.build_success_response(
      p_message_key := 'delivery_auto_rejected',
      p_data := jsonb_build_object(
        'intake_id', v_intake_id,
        'platform_code', p_platform_code,
        'platform_order_id',
          p_platform_order_id,
        'auto_reject_reason',
          v_auto_reject_reason,
        'intake_status', 'REJECTED'
      ),
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );
  end if;

  -- 정상 수신 → 직원 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type :=
      'takeout_order_received',
    p_payload := jsonb_build_object(
      'intake_id', v_intake_id,
      'platform_code', p_platform_code,
      'platform_order_number',
        v_platform_order_number,
      'final_amount', v_final_amount,
      'items_count',
        jsonb_array_length(v_parsed_items),
      'received_at', now(),
      'alert_message',
        catchmenu_common.get_message(
          'delivery_order_received',
          p_locale,
          jsonb_build_object(
            'order_number',
              v_platform_order_number
          )
        )
    )
  );

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
    'delivery', 'delivery_order_received', 1,
    'delivery_intake', v_intake_id,
    null, 'RECEIVED',
    'PLATFORM',
    jsonb_build_object(
      'platform_code', p_platform_code,
      'platform_order_id', p_platform_order_id,
      'platform_order_number',
        v_platform_order_number,
      'final_amount', v_final_amount
    ),
    p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'delivery_order_received',
    p_data := jsonb_build_object(
      'intake_id', v_intake_id,
      'platform_code', p_platform_code,
      'platform_order_id', p_platform_order_id,
      'platform_order_number',
        v_platform_order_number,
      'parsed_items', v_parsed_items,
      'amounts', jsonb_build_object(
        'item_amount', v_item_amount,
        'delivery_fee', v_delivery_fee,
        'discount_amount', v_discount_amount,
        'final_amount', v_final_amount
      ),
      'intake_status', 'RECEIVED',
      'next_step',
        'accept_delivery_order() 또는 '
        || 'reject_delivery_order() 호출'
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'order_number', v_platform_order_number
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.accept_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intake_id uuid,
  p_estimated_minutes int default 20,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger,
                  catchmenu_hq
as $$
declare
  v_intake record;
  v_order_id uuid;
  v_order_number text;
  v_kds_ticket_id uuid;
  v_business_day date;
  v_timezone text;
  v_item jsonb;
  v_menu_id uuid;
  v_session_id uuid;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- 수신 로그 조회
  select id, platform_code,
         platform_order_id,
         platform_order_number,
         parsed_items, final_amount,
         intake_status
  into v_intake
  from catchmenu_integrations.delivery_intake_log
  where id = p_intake_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intake.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'delivery_order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'accept_delivery_order'
    );
  end if;

  if v_intake.intake_status <> 'RECEIVED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'accept_delivery_order'
    );
  end if;

  -- 주문 번호 생성
  v_order_number := v_intake.platform_code
    || '-' || v_intake.platform_order_number;

  -- 세션 생성 (배달 = 별도 세션)
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count,
    session_started_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'DELIVERY', 'SEATED',
    1, now(),
    v_business_day, v_timezone
  )
  returning id into v_session_id;

  -- 내부 주문 생성
  insert into catchmenu_pos.orders (
    tenant_id, store_id,
    session_id, order_number,
    order_type, order_status,
    order_source,
    platform_code,
    platform_order_id,
    total_amount, final_amount,
    ordered_at,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    v_session_id, v_order_number,
    'DELIVERY', 'CONFIRMED',
    v_intake.platform_code,
    v_intake.platform_code,
    v_intake.platform_order_id,
    v_intake.final_amount,
    v_intake.final_amount,
    now(),
    v_business_day, v_timezone
  )
  returning id into v_order_id;

  -- 주문 항목 생성
  for v_item in
    select * from jsonb_array_elements(
      v_intake.parsed_items
    )
  loop
    -- 메뉴 매칭 시도 (메뉴명 기반)
    select id into v_menu_id
    from catchmenu_pos.menus
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_name = v_item->>'menu_name'
      and is_active = true
    limit 1;

    insert into catchmenu_pos.order_items (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity,
      unit_price,
      subtotal,
      item_options
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu_id,
      v_item->>'menu_name',
      (v_item->>'quantity')::int,
      (v_item->>'unit_price')::int,
      (v_item->>'subtotal')::int,
      coalesce(
        v_item->'options', '[]'::jsonb
      )
    );

    -- KDS 티켓 생성 (HOLD 상태 = 특허2)
    -- 배달 주문 = 결제 이미 완료
    -- → 즉시 COMMITTED 처리
    insert into catchmenu_kds.kds_tickets (
      tenant_id, store_id,
      order_id, menu_id,
      menu_name_snapshot,
      quantity_snapshot,
      kitchen_zone,
      kds_status,
      conditions_met,
      ticket_created_at,
      committed_at,
      business_day, business_timezone
    ) values (
      p_tenant_id, p_store_id,
      v_order_id, v_menu_id,
      v_item->>'menu_name',
      (v_item->>'quantity')::int,
      'MAIN',
      -- 배달 = 선결제 완료 → COMMITTED
      'COMMITTED',
      jsonb_build_object(
        'payment_confirmed', true,
        'kds_release_authorized', true,
        'delivery_pre_paid', true,
        'platform', v_intake.platform_code
      ),
      now(), now(),
      v_business_day, v_timezone
    )
    returning id into v_kds_ticket_id;
  end loop;

  -- 수신 로그 업데이트
  update catchmenu_integrations.delivery_intake_log
  set
    order_id = v_order_id,
    intake_status = 'ACCEPTED',
    accepted_at = now(),
    updated_at = now()
  where id = p_intake_id;

  -- Edge Function에 배달앱 수락 응답 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'delivery_order_accept_requested',
    p_payload := jsonb_build_object(
      'intake_id', p_intake_id,
      'order_id', v_order_id,
      'platform_code', v_intake.platform_code,
      'platform_order_id',
        v_intake.platform_order_id,
      'estimated_minutes', p_estimated_minutes,
      'correlation_id', p_correlation_id
    )
  );

  -- KDS Realtime 브로드캐스트
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'KDS_TICKETS',
    p_event_type := 'kds_ticket_created',
    p_payload := jsonb_build_object(
      'order_id', v_order_id,
      'order_number', v_order_number,
      'order_type', 'DELIVERY',
      'platform_code', v_intake.platform_code,
      'kds_status', 'COMMITTED',
      'items_count',
        jsonb_array_length(v_intake.parsed_items)
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'delivery', 'delivery_order_accepted', 1,
    'delivery_intake', p_intake_id,
    'RECEIVED', 'ACCEPTED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'platform_code', v_intake.platform_code,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'estimated_minutes', p_estimated_minutes,
      'kds_status', 'COMMITTED'
    ),
    v_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'delivery_order_accepted',
    p_data := jsonb_build_object(
      'intake_id', p_intake_id,
      'order_id', v_order_id,
      'order_number', v_order_number,
      'platform_code', v_intake.platform_code,
      'estimated_minutes', p_estimated_minutes,
      'kds_status', 'COMMITTED',
      'kds_note',
        '배달 선결제 → COMMITTED 즉시 처리',
      'items_count',
        jsonb_array_length(v_intake.parsed_items)
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.reject_delivery_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intake_id uuid,
  p_reject_reason text,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_intake record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, platform_code,
         platform_order_id,
         platform_order_number,
         intake_status, final_amount
  into v_intake
  from catchmenu_integrations.delivery_intake_log
  where id = p_intake_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intake.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'delivery_order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'reject_delivery_order'
    );
  end if;

  if v_intake.intake_status <> 'RECEIVED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'reject_delivery_order'
    );
  end if;

  -- 거절 상태 업데이트
  update catchmenu_integrations.delivery_intake_log
  set
    intake_status = 'REJECTED',
    rejected_at = now(),
    reject_reason = p_reject_reason,
    reject_message :=
      catchmenu_common.get_message(
        case p_reject_reason
          when 'kds_overloaded'
            then 'reject_message_overloaded'
          else 'reject_message_closed'
        end,
        p_locale, null
      ),
    updated_at = now()
  where id = p_intake_id;

  -- Edge Function에 거절 응답 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'delivery_order_reject_requested',
    p_payload := jsonb_build_object(
      'intake_id', p_intake_id,
      'platform_code', v_intake.platform_code,
      'platform_order_id',
        v_intake.platform_order_id,
      'reject_reason', p_reject_reason,
      'correlation_id', p_correlation_id
    )
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'delivery', 'delivery_order_rejected', 1,
    'delivery_intake', p_intake_id,
    'RECEIVED', 'REJECTED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'platform_code', v_intake.platform_code,
      'platform_order_number',
        v_intake.platform_order_number,
      'reject_reason', p_reject_reason
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'delivery_order_rejected',
    p_data := jsonb_build_object(
      'intake_id', p_intake_id,
      'platform_code', v_intake.platform_code,
      'platform_order_number',
        v_intake.platform_order_number,
      'reject_reason', p_reject_reason,
      'intake_status', 'REJECTED'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.update_delivery_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_intake_id uuid,
  p_new_status text,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_kds,
                  catchmenu_common
as $$
declare
  v_intake record;
  v_message_key text;
begin
  select id, order_id, platform_code,
         platform_order_number, intake_status
  into v_intake
  from catchmenu_integrations.delivery_intake_log
  where id = p_intake_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_intake.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'delivery_order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'update_delivery_status'
    );
  end if;

  -- 상태별 처리
  case p_new_status
    when 'COOKING' then
      v_message_key := 'delivery_cooking_started';
      -- 주문 상태 업데이트
      if v_intake.order_id is not null then
        update catchmenu_pos.orders
        set
          order_status = 'COOKING',
          updated_at = now()
        where id = v_intake.order_id;
      end if;

    when 'READY' then
      v_message_key :=
        'delivery_ready_for_pickup';
      -- KDS 완료 + 주문 READY
      if v_intake.order_id is not null then
        update catchmenu_kds.kds_tickets
        set
          kds_status = 'READY',
          ready_at = now(),
          updated_at = now()
        where order_id = v_intake.order_id
          and kds_status in (
            'COMMITTED', 'COOKING'
          );

        update catchmenu_pos.orders
        set
          order_status = 'READY',
          updated_at = now()
        where id = v_intake.order_id;
      end if;

      -- Edge Function에 배달앱 픽업 준비 알림
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'SYSTEM_EVENTS',
        p_event_type :=
          'delivery_ready_notify_requested',
        p_payload := jsonb_build_object(
          'intake_id', p_intake_id,
          'platform_code', v_intake.platform_code,
          'order_id', v_intake.order_id,
          'correlation_id', p_correlation_id
        )
      );

    when 'PICKED_UP' then
      v_message_key := 'delivery_picked_up';
      if v_intake.order_id is not null then
        update catchmenu_pos.orders
        set
          order_status = 'COMPLETED',
          completed_at = now(),
          updated_at = now()
        where id = v_intake.order_id;

        update catchmenu_kds.kds_tickets
        set
          kds_status = 'COMPLETED',
          completed_at = now(),
          updated_at = now()
        where order_id = v_intake.order_id;
      end if;

    when 'CANCELLED' then
      v_message_key := 'delivery_order_cancelled';
      update catchmenu_integrations.delivery_intake_log
      set
        intake_status = 'CANCELLED',
        updated_at = now()
      where id = p_intake_id;

      if v_intake.order_id is not null then
        update catchmenu_pos.orders
        set
          order_status = 'CANCELLED',
          cancelled_at = now(),
          updated_at = now()
        where id = v_intake.order_id;

        update catchmenu_kds.kds_tickets
        set
          kds_status = 'CANCELLED',
          cancelled_at = now(),
          updated_at = now()
        where order_id = v_intake.order_id
          and kds_status not in (
            'SERVED', 'COMPLETED', 'CANCELLED'
          );
      end if;

      -- 직원 알림
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'STAFF_ALERTS',
        p_event_type :=
          'delivery_order_cancelled',
        p_payload := jsonb_build_object(
          'platform_code', v_intake.platform_code,
          'platform_order_number',
            v_intake.platform_order_number,
          'order_id', v_intake.order_id,
          'alert_message',
            catchmenu_common.get_message(
              'delivery_order_cancelled_alert',
              p_locale,
              jsonb_build_object(
                'order_number',
                  v_intake.platform_order_number
              )
            )
        )
      );

    else
      v_message_key := 'delivery_status_updated';
  end case;

  return catchmenu_common.build_success_response(
    p_message_key := v_message_key,
    p_data := jsonb_build_object(
      'intake_id', p_intake_id,
      'platform_code', v_intake.platform_code,
      'platform_order_number',
        v_intake.platform_order_number,
      'order_id', v_intake.order_id,
      'new_status', p_new_status,
      'updated_at', now()
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_delivery_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_today_summary jsonb;
  v_pending_orders jsonb;
  v_platform_breakdown jsonb;
  v_hourly_orders jsonb;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 오늘 요약
  select jsonb_build_object(
    'total_received', count(*),
    'accepted', count(*) filter (
      where intake_status in (
        'ACCEPTED', 'COMPLETED'
      )
    ),
    'rejected', count(*) filter (
      where intake_status = 'REJECTED'
    ),
    'auto_rejected', count(*) filter (
      where is_auto_rejected = true
    ),
    'cancelled', count(*) filter (
      where intake_status = 'CANCELLED'
    ),
    'total_revenue', coalesce(
      sum(final_amount) filter (
        where intake_status = 'COMPLETED'
      ), 0
    ),
    'avg_amount', coalesce(
      avg(final_amount) filter (
        where intake_status in (
          'ACCEPTED', 'COMPLETED'
        )
      )::int, 0
    )
  )
  into v_today_summary
  from catchmenu_integrations.delivery_intake_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 처리 대기 주문
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'intake_id', id,
        'platform_code', platform_code,
        'platform_order_number',
          platform_order_number,
        'final_amount', final_amount,
        'received_at', received_at,
        'waited_seconds', extract(
          epoch from (now() - received_at)
        )::int
      )
      order by received_at asc
    ),
    '[]'::jsonb
  )
  into v_pending_orders
  from catchmenu_integrations.delivery_intake_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and intake_status = 'RECEIVED';

  -- 플랫폼별 분류
  select jsonb_build_object(
    'baemin', jsonb_build_object(
      'count', count(*) filter (
        where platform_code = 'BAEMIN'
      ),
      'revenue', coalesce(
        sum(final_amount) filter (
          where platform_code = 'BAEMIN'
            and intake_status = 'COMPLETED'
        ), 0
      )
    ),
    'yogiyo', jsonb_build_object(
      'count', count(*) filter (
        where platform_code = 'YOGIYO'
      ),
      'revenue', coalesce(
        sum(final_amount) filter (
          where platform_code = 'YOGIYO'
            and intake_status = 'COMPLETED'
        ), 0
      )
    ),
    'coupang_eats', jsonb_build_object(
      'count', count(*) filter (
        where platform_code = 'COUPANG_EATS'
      ),
      'revenue', coalesce(
        sum(final_amount) filter (
          where platform_code = 'COUPANG_EATS'
            and intake_status = 'COMPLETED'
        ), 0
      )
    )
  )
  into v_platform_breakdown
  from catchmenu_integrations.delivery_intake_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day;

  -- 시간대별 주문
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'hour', hour,
        'count', cnt,
        'revenue', revenue
      )
      order by hour
    ),
    '[]'::jsonb
  )
  into v_hourly_orders
  from (
    select
      extract(hour from
        timezone('Asia/Seoul', received_at)
      )::int as hour,
      count(*) as cnt,
      coalesce(sum(final_amount), 0) as revenue
    from catchmenu_integrations.delivery_intake_log
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day = v_business_day
      and intake_status in (
        'ACCEPTED', 'COMPLETED'
      )
    group by hour
  ) h;

  return catchmenu_common.build_success_response(
    p_message_key := 'delivery_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'today_summary', v_today_summary,
      'pending_orders', v_pending_orders,
      'pending_count',
        jsonb_array_length(v_pending_orders),
      'platform_breakdown', v_platform_breakdown,
      'hourly_orders', v_hourly_orders,
      'has_pending',
        jsonb_array_length(v_pending_orders) > 0,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.receive_delivery_order(
      uuid, uuid, text, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.receive_delivery_order(
      uuid, uuid, text, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.accept_delivery_order(
      uuid, uuid, uuid, int, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.accept_delivery_order(
      uuid, uuid, uuid, int, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.reject_delivery_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.reject_delivery_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.update_delivery_status(
      uuid, uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.update_delivery_status(
      uuid, uuid, uuid, text, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_delivery_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_delivery_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.receive_delivery_order(
    uuid, uuid, text, text, jsonb, text, text
  ) is
  '배달 주문 수신 파이프라인.
   3대 플랫폼 지원:
   BAEMIN: orderNo/orderTime/foodTotalPrice
   YOGIYO: order_number/ordered_at/total_price
   COUPANG_EATS: vendorOrderKey/orderedAt
   
   자동 거절 조건:
   1. 매장 CLOSED/HOLIDAY/EMERGENCY
   2. KDS 과부하 (check_kds_capacity)
   
   정상 수신 시:
   → 직원 앱 Realtime 알림
   → accept/reject 선택 대기
   
   중복 수신 방지:
   uq_delivery_platform_order 유니크 제약.
   특허2: KDS 과부하 = 배달 자동 거절.
   1-B차 배달 연동 핵심 함수.';

comment on function
  catchmenu_integrations.accept_delivery_order(
    uuid, uuid, uuid, int, uuid, text, text
  ) is
  '배달 주문 수락 파이프라인.
   처리 순서:
   1. 내부 세션 생성 (DELIVERY)
   2. 내부 주문 생성 (CONFIRMED)
   3. 주문 항목 생성 + 메뉴 매칭
   4. KDS 티켓 생성 → COMMITTED 즉시
      (배달 = 선결제 완료이므로 HOLD 불필요)
   5. 배달앱에 수락 응답 (Edge Function)
   6. KDS Realtime 브로드캐스트
   
   특허2 배달 예외:
   배달 주문 = 플랫폼에서 선결제 완료.
   → HOLD 불필요 → 즉시 COMMITTED.
   홀/포장 = HOLD → 결제 후 COMMITTED.
   동일 원칙, 결제 시점만 다름.';