-- 0104_create_toss_pos_pipeline_rpc.sql
-- Purpose: Toss POS integration pipeline.
--          토스POS 주문 전송, 결제 확인,
--          메뉴 동기화, 헬스체크 파이프라인.
--          OKpos와 동일한 구조로 표준화.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0103_create_toss_payments_pipeline_rpc.sql
-- Creates:
--   catchmenu_integrations.toss_pos_order_log (table)
--   catchmenu_integrations.toss_pos_menu_sync_log (table)
--   function catchmenu_integrations.sync_toss_pos_menu(...)
--   function catchmenu_integrations.send_order_to_toss_pos(...)
--   function catchmenu_integrations.confirm_toss_pos_payment(...)
--   function catchmenu_integrations.cancel_toss_pos_order(...)
--   function catchmenu_integrations.get_toss_pos_health(...)
--   function catchmenu_integrations.get_toss_pos_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('toss_pos_menu_synced', 'ko',
  '토스POS 메뉴가 동기화되었습니다'),
('toss_pos_menu_synced', 'en',
  'Toss POS menu synced'),
('toss_pos_order_sent', 'ko',
  '토스POS에 주문이 전송되었습니다'),
('toss_pos_order_sent', 'en',
  'Order sent to Toss POS'),
('toss_pos_payment_confirmed', 'ko',
  '토스POS 결제가 확인되었습니다'),
('toss_pos_payment_confirmed', 'en',
  'Toss POS payment confirmed'),
('toss_pos_order_cancelled', 'ko',
  '토스POS 주문이 취소되었습니다'),
('toss_pos_order_cancelled', 'en',
  'Toss POS order cancelled'),
('toss_pos_health_ok', 'ko',
  '토스POS 연결이 정상입니다'),
('toss_pos_health_ok', 'en',
  'Toss POS connection healthy'),
('toss_pos_health_error', 'ko',
  '토스POS 연결에 문제가 있습니다'),
('toss_pos_health_error', 'en',
  'Toss POS connection error'),
('toss_pos_dashboard_loaded', 'ko',
  '토스POS 대시보드가 로드되었습니다'),
('toss_pos_dashboard_loaded', 'en',
  'Toss POS dashboard loaded'),
('toss_pos_order_failed', 'ko',
  '토스POS 주문 전송에 실패했습니다'),
('toss_pos_order_failed', 'en',
  'Toss POS order transmission failed'),
('toss_pos_config_not_found', 'ko',
  '토스POS 설정을 찾을 수 없습니다'),
('toss_pos_config_not_found', 'en',
  'Toss POS config not found')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9030, 'toss_pos_config_not_found',
  'INTEGRATION', 'NOT_FOUND', 404, 'ERROR',
  'SOP-POS-001'),
(9031, 'toss_pos_menu_sync_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9032, 'toss_pos_order_send_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9033, 'toss_pos_payment_confirm_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(9034, 'toss_pos_cancel_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-002')
on conflict (code) do nothing;


-- =============================================
-- toss_pos_menu_sync_log table
-- =============================================
create table if not exists
  catchmenu_integrations.toss_pos_menu_sync_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  sync_type text not null default 'FULL',
  sync_status text not null default 'PENDING',
  menus_fetched int not null default 0,
  menus_created int not null default 0,
  menus_updated int not null default 0,
  menus_deactivated int not null default 0,

  toss_pos_response jsonb,
  error_detail text,
  duration_ms int,

  synced_at timestamptz not null default now(),
  completed_at timestamptz,

  constraint chk_tpos_sync_type check (
    sync_type in (
      'FULL', 'INCREMENTAL',
      'PRICE_ONLY', 'STATUS_ONLY'
    )
  ),
  constraint chk_tpos_sync_status check (
    sync_status in (
      'PENDING', 'IN_PROGRESS',
      'COMPLETED', 'PARTIAL', 'FAILED'
    )
  )
);

create index if not exists idx_toss_pos_sync
  on catchmenu_integrations.toss_pos_menu_sync_log(
    store_id, synced_at desc
  );

alter table
  catchmenu_integrations.toss_pos_menu_sync_log
  enable row level security;
alter table
  catchmenu_integrations.toss_pos_menu_sync_log
  force row level security;

drop policy if exists toss_pos_sync_isolation
  on catchmenu_integrations.toss_pos_menu_sync_log;
create policy toss_pos_sync_isolation
  on catchmenu_integrations.toss_pos_menu_sync_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.toss_pos_menu_sync_log is
  '토스POS 메뉴 동기화 이력.
   OKpos와 동일한 구조 (표준화).
   메뉴 코드 규칙: TPOS_{code}
   카테고리 코드 규칙: TPOS_CAT_{code}
   1차 MVP 토스POS 연동 감사 테이블.';


-- =============================================
-- toss_pos_order_log table
-- =============================================
create table if not exists
  catchmenu_integrations.toss_pos_order_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  order_id uuid
    references catchmenu_pos.orders(id),
  toss_pos_order_id text,

  send_status text not null default 'PENDING',
  retry_count int not null default 0,

  request_payload jsonb,
  toss_pos_response jsonb,
  error_code text,
  error_detail text,

  sent_at timestamptz not null default now(),
  confirmed_at timestamptz,
  duration_ms int,

  constraint chk_tpos_send_status check (
    send_status in (
      'PENDING', 'SENT', 'CONFIRMED',
      'FAILED', 'CANCELLED', 'TIMEOUT'
    )
  )
);

create index if not exists idx_toss_pos_order
  on catchmenu_integrations.toss_pos_order_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_toss_pos_failed
  on catchmenu_integrations.toss_pos_order_log(
    store_id, send_status, sent_at desc
  ) where send_status in ('FAILED', 'PENDING');

alter table
  catchmenu_integrations.toss_pos_order_log
  enable row level security;
alter table
  catchmenu_integrations.toss_pos_order_log
  force row level security;

drop policy if exists toss_pos_order_isolation
  on catchmenu_integrations.toss_pos_order_log;
create policy toss_pos_order_isolation
  on catchmenu_integrations.toss_pos_order_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.toss_pos_order_log is
  '토스POS 주문 전송 이력.
   OKpos와 동일한 구조 (표준화).
   TIMEOUT: 5초 내 응답 없음 → 망취소.
   retry_count: 최대 3회 재시도.
   특허1: POS 주문 전송 = 감사 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.sync_toss_pos_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_sync_type text default 'FULL',
  p_toss_pos_menu_data jsonb default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_start timestamptz := now();
  v_sync_log_id uuid;
  v_config record;
  v_item jsonb;
  v_category_id uuid;
  v_created int := 0;
  v_updated int := 0;
  v_deactivated int := 0;
  v_fetched int := 0;
  v_tpos_codes jsonb := '[]'::jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 토스POS 설정 조회
  select id, store_code, api_endpoint,
         pos_terminal_id, is_active
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'sync_toss_pos_menu'
    );
  end if;

  -- 동기화 로그 시작
  insert into
    catchmenu_integrations.toss_pos_menu_sync_log (
    tenant_id, store_id,
    sync_type, sync_status
  ) values (
    p_tenant_id, p_store_id,
    p_sync_type, 'IN_PROGRESS'
  )
  returning id into v_sync_log_id;

  -- Edge Function 트리거 (데이터 없는 경우)
  if p_toss_pos_menu_data is null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'toss_pos_menu_fetch_requested',
      p_payload := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'config_id', v_config.id,
        'store_code', v_config.store_code,
        'api_endpoint', v_config.api_endpoint,
        'pos_terminal_id',
          v_config.pos_terminal_id,
        'sync_type', p_sync_type,
        'correlation_id', p_correlation_id
      )
    );

    update catchmenu_integrations
      .toss_pos_menu_sync_log
    set sync_status = 'PENDING'
    where id = v_sync_log_id;

    return catchmenu_common.build_success_response(
      p_message_key := 'toss_pos_menu_synced',
      p_data := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'sync_status', 'PENDING',
        'note',
          'Edge Function toss-pos-menu-sync 호출됨'
      ),
      p_locale := p_locale
    );
  end if;

  v_fetched := jsonb_array_length(
    coalesce(p_toss_pos_menu_data, '[]'::jsonb)
  );

  -- 토스POS 메뉴 항목 처리
  -- OKpos와 동일 구조, 코드 규칙만 다름
  for v_item in
    select * from jsonb_array_elements(
      p_toss_pos_menu_data
    )
  loop
    declare
      v_tpos_code text;
      v_menu_name text;
      v_price int;
      v_cat_code text;
      v_cat_name text;
      v_is_available boolean;
      v_existing record;
    begin
      -- 코드 규칙: TPOS_{code}
      v_tpos_code :=
        'TPOS_' || (v_item->>'menuCode');
      v_menu_name := coalesce(
        v_item->>'menuNameKo',
        v_item->>'menuName'
      );
      v_price :=
        (v_item->>'salePrice')::int;
      v_cat_code :=
        'TPOS_CAT_' || coalesce(
          v_item->>'categoryCode', 'DEFAULT'
        );
      v_cat_name := coalesce(
        v_item->>'categoryNameKo',
        v_item->>'categoryName',
        '토스POS 메뉴'
      );
      v_is_available := coalesce(
        (v_item->>'useYn')::boolean, true
      );

      v_tpos_codes := v_tpos_codes
        || to_jsonb(v_tpos_code);

      -- 카테고리 upsert
      insert into catchmenu_pos.menu_categories (
        tenant_id, store_id,
        category_code, category_name,
        display_order
      ) values (
        p_tenant_id, p_store_id,
        v_cat_code, v_cat_name,
        coalesce(
          (v_item->>'categoryOrder')::int, 0
        )
      )
      on conflict (store_id, category_code)
      do update set
        category_name = excluded.category_name,
        updated_at = now()
      returning id into v_category_id;

      -- 기존 메뉴 확인
      select id, price, menu_status
      into v_existing
      from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and menu_code = v_tpos_code;

      if v_existing.id is null then
        -- 신규 메뉴 생성
        insert into catchmenu_pos.menus (
          tenant_id, store_id, category_id,
          menu_code, menu_name,
          price, menu_status,
          is_kds_required,
          display_order,
          pos_sync_at
        ) values (
          p_tenant_id, p_store_id, v_category_id,
          v_tpos_code, v_menu_name,
          v_price,
          case v_is_available
            when true then 'AVAILABLE'
            else 'SOLD_OUT'
          end,
          true,
          coalesce(
            (v_item->>'menuOrder')::int, 0
          ),
          now()
        );
        v_created := v_created + 1;

      else
        -- 기존 메뉴 업데이트
        update catchmenu_pos.menus
        set
          menu_name = v_menu_name,
          price = v_price,
          category_id = v_category_id,
          menu_status = case v_is_available
            when true then 'AVAILABLE'
            else 'SOLD_OUT'
          end,
          is_active = true,
          pos_sync_at = now(),
          updated_at = now()
        where id = v_existing.id;

        -- 가격 변경 이력
        if v_existing.price <> v_price then
          insert into catchmenu_ledger.events (
            tenant_id, store_id,
            event_domain, event_type,
            event_version,
            subject_type, subject_id,
            from_state, to_state,
            caused_by_type, event_payload,
            business_day, business_timezone,
            occurred_at
          ) values (
            p_tenant_id, p_store_id,
            'menu', 'menu_price_changed', 1,
            'menu', v_existing.id,
            v_existing.price::text,
            v_price::text,
            'TOSS_POS_SYNC',
            jsonb_build_object(
              'menu_code', v_tpos_code,
              'old_price', v_existing.price,
              'new_price', v_price,
              'sync_log_id', v_sync_log_id
            ),
            v_business_day, 'Asia/Seoul', now()
          );
        end if;

        v_updated := v_updated + 1;
      end if;
    end;
  end loop;

  -- FULL SYNC: 토스POS에 없는 메뉴 비활성화
  if p_sync_type = 'FULL'
    and jsonb_array_length(v_tpos_codes) > 0
  then
    update catchmenu_pos.menus
    set
      menu_status = 'DISCONTINUED',
      is_active = false,
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_code like 'TPOS_%'
      and not (
        v_tpos_codes @> to_jsonb(menu_code)
      )
      and menu_status <> 'DISCONTINUED';

    get diagnostics v_deactivated = row_count;
  end if;

  -- 동기화 로그 완료
  update catchmenu_integrations
    .toss_pos_menu_sync_log
  set
    sync_status = 'COMPLETED',
    menus_fetched = v_fetched,
    menus_created = v_created,
    menus_updated = v_updated,
    menus_deactivated = v_deactivated,
    duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000,
    completed_at = now()
  where id = v_sync_log_id;

  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'INTEGRATION',
    p_log_event := 'toss_pos_menu_synced',
    p_message :=
      '토스POS 메뉴 동기화 완료'
      || ' | 조회=' || v_fetched
      || ' | 생성=' || v_created
      || ' | 수정=' || v_updated
      || ' | 비활성=' || v_deactivated,
    p_rpc_name := 'sync_toss_pos_menu',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'created', v_created,
      'updated', v_updated,
      'deactivated', v_deactivated
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_menu_synced',
    p_data := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'sync_type', p_sync_type,
      'sync_status', 'COMPLETED',
      'result', jsonb_build_object(
        'fetched', v_fetched,
        'created', v_created,
        'updated', v_updated,
        'deactivated', v_deactivated
      ),
      'menu_code_prefix', 'TPOS_',
      'category_code_prefix', 'TPOS_CAT_'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.send_order_to_toss_pos(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_config record;
  v_order record;
  v_items jsonb;
  v_log_id uuid;
  v_request_payload jsonb;
begin
  select id, store_code, api_endpoint,
         pos_terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'send_order_to_toss_pos'
    );
  end if;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.final_amount, o.memo,
         os.table_number, os.wait_number
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
      p_rpc_name := 'send_order_to_toss_pos'
    );
  end if;

  -- 주문 항목 (TPOS_ 코드 제거)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menuCode', replace(
          m.menu_code, 'TPOS_', ''
        ),
        'menuName', oi.menu_name_snapshot,
        'qty', oi.quantity,
        'salePrice', oi.unit_price,
        'totalPrice', oi.subtotal,
        'options', oi.item_options
      )
      order by oi.display_order
    ),
    '[]'::jsonb
  )
  into v_items
  from catchmenu_pos.order_items oi
  left join catchmenu_pos.menus m
    on m.id = oi.menu_id
  where oi.order_id = p_order_id;

  -- 토스POS API 규격 페이로드
  v_request_payload := jsonb_build_object(
    'storeCode', v_config.store_code,
    'terminalId', v_config.pos_terminal_id,
    'orderNo', v_order.order_number,
    'orderType', case v_order.order_type
      when 'TABLE' then 'DINE_IN'
      when 'TAKEOUT' then 'TAKE_OUT'
      when 'DELIVERY' then 'DELIVERY'
      else 'TAKE_OUT'
    end,
    'tableNo', coalesce(
      v_order.table_number, ''
    ),
    'menuList', v_items,
    'totalAmount', v_order.final_amount,
    'memo', coalesce(
      v_order.memo, ''
    ),
    'orderedAt', now()
  );

  -- 전송 로그 생성
  insert into
    catchmenu_integrations.toss_pos_order_log (
    tenant_id, store_id, order_id,
    send_status, request_payload,
    sent_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'PENDING', v_request_payload, now()
  )
  returning id into v_log_id;

  -- Edge Function에 전송 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type :=
      'toss_pos_order_send_requested',
    p_payload := jsonb_build_object(
      'log_id', v_log_id,
      'order_id', p_order_id,
      'config_id', v_config.id,
      'api_endpoint', v_config.api_endpoint,
      'request_payload', v_request_payload,
      'correlation_id', p_correlation_id,
      'timeout_seconds', 5,
      'on_timeout', 'NET_CANCEL'
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_order_sent',
    p_data := jsonb_build_object(
      'log_id', v_log_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'send_status', 'PENDING',
      'items_count',
        jsonb_array_length(v_items),
      'final_amount', v_order.final_amount
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations
    .confirm_toss_pos_order_sent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_log_id uuid,
  p_toss_pos_order_id text,
  p_send_result text,
  p_toss_pos_response jsonb default null,
  p_error_detail text default null,
  p_duration_ms int default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_common
as $$
declare
  v_log record;
  v_new_status text;
begin
  select id, order_id, send_status
  into v_log
  from catchmenu_integrations.toss_pos_order_log
  where id = p_log_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_log.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_toss_pos_order_sent'
    );
  end if;

  v_new_status := case p_send_result
    when 'SUCCESS' then 'CONFIRMED'
    when 'TIMEOUT' then 'TIMEOUT'
    else 'FAILED'
  end;

  update catchmenu_integrations.toss_pos_order_log
  set
    send_status = v_new_status,
    toss_pos_order_id = p_toss_pos_order_id,
    toss_pos_response = p_toss_pos_response,
    error_detail = p_error_detail,
    duration_ms = p_duration_ms,
    confirmed_at = case p_send_result
      when 'SUCCESS' then now()
      else null
    end,
    updated_at = now()
  where id = p_log_id;

  -- 실패 시 운영 알림
  if v_new_status in ('FAILED', 'TIMEOUT') then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'POS_DISCONNECTED',
      p_alert_severity := 'ERROR',
      p_alert_domain := 'INTEGRATION',
      p_alert_title_key := 'toss_pos_order_failed',
      p_alert_detail := jsonb_build_object(
        'log_id', p_log_id,
        'order_id', v_log.order_id,
        'send_result', p_send_result,
        'error_detail', p_error_detail
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-POS-001'
    );
  end if;

  -- 주문에 토스POS 주문 ID 기록
  if p_send_result = 'SUCCESS'
    and p_toss_pos_order_id is not null
  then
    update catchmenu_pos.orders
    set
      provider_type = 'TOSS_POS',
      provider_order_id = p_toss_pos_order_id,
      updated_at = now()
    where id = v_log.order_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := case p_send_result
      when 'SUCCESS' then 'toss_pos_order_sent'
      else 'toss_pos_order_failed'
    end,
    p_data := jsonb_build_object(
      'log_id', p_log_id,
      'order_id', v_log.order_id,
      'toss_pos_order_id', p_toss_pos_order_id,
      'send_status', v_new_status
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_toss_pos_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_toss_pos_tx_data jsonb,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_approval_number text;
  v_approved_amount int;
  v_payment_method text;
  v_toss_pos_tx_id text;
  v_result jsonb;
begin
  -- 토스POS 결제 데이터 파싱
  -- 토스POS API 응답 필드명 기준
  v_approval_number :=
    p_toss_pos_tx_data->>'approvalNo';
  v_approved_amount :=
    (p_toss_pos_tx_data->>'paidAmt')::int;
  v_payment_method := coalesce(
    p_toss_pos_tx_data->>'payMethod', 'CARD'
  );
  v_toss_pos_tx_id := coalesce(
    p_toss_pos_tx_data->>'tposOrderId',
    p_toss_pos_tx_data->>'tranId'
  );

  -- 표준 결제 확인 파이프라인
  -- → KDS Late Binding 해제 (특허2)
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_provider_type := 'TOSS_POS',
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := v_toss_pos_tx_id,
    p_approved_amount := v_approved_amount,
    p_payment_method := v_payment_method,
    p_provider_response := p_toss_pos_tx_data,
    p_actor_type := 'POS',
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_payment_confirmed',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_pos_tx_id', v_toss_pos_tx_id,
      'approval_number', v_approval_number,
      'approved_amount', v_approved_amount,
      'payment_method', v_payment_method,
      'kds_released',
        (v_result->>'success')::boolean,
      'kds_data', v_result->'data'->'kds'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_toss_pos_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_cancel_reason text,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_log record;
  v_refund_result jsonb;
begin
  -- 토스POS 전송 이력 확인
  select id, toss_pos_order_id, send_status
  into v_log
  from catchmenu_integrations.toss_pos_order_log
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status = 'CONFIRMED'
  order by confirmed_at desc
  limit 1;

  -- Edge Function에 취소 요청
  if v_log.id is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'toss_pos_order_cancel_requested',
      p_payload := jsonb_build_object(
        'order_id', p_order_id,
        'toss_pos_order_id',
          v_log.toss_pos_order_id,
        'log_id', v_log.id,
        'cancel_reason', p_cancel_reason,
        'correlation_id', p_correlation_id
      )
    );
  end if;

  -- 표준 환불 파이프라인
  v_refund_result :=
    catchmenu_payment.request_refund(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_order_id := p_order_id,
      p_refund_amount := 0,
      p_refund_reason := p_cancel_reason,
      p_is_partial := false,
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_locale := p_locale,
      p_correlation_id := p_correlation_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_order_cancelled',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'toss_pos_order_id',
        v_log.toss_pos_order_id,
      'cancel_reason', p_cancel_reason,
      'refund_result',
        v_refund_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_pos_health(
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
  v_config record;
  v_last_sync record;
  v_last_order record;
  v_failed_count int;
  v_business_day date;
  v_health_status text;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, store_code, api_endpoint,
         is_active, last_heartbeat_at
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'TOSS_POS';

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'toss_pos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_toss_pos_health'
    );
  end if;

  select sync_status, synced_at, menus_fetched
  into v_last_sync
  from catchmenu_integrations.toss_pos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by synced_at desc limit 1;

  select send_status, sent_at
  into v_last_order
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by sent_at desc limit 1;

  select count(*) into v_failed_count
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status in ('FAILED', 'TIMEOUT')
    and sent_at::date = v_business_day;

  v_health_status := case
    when not v_config.is_active
      then 'INACTIVE'
    when v_failed_count >= 3
      then 'DEGRADED'
    when v_config.last_heartbeat_at is null
      or v_config.last_heartbeat_at
        > now() - interval '10 minutes'
      then 'HEALTHY'
    else 'UNKNOWN'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := case v_health_status
      when 'HEALTHY' then 'toss_pos_health_ok'
      else 'toss_pos_health_error'
    end,
    p_data := jsonb_build_object(
      'config_id', v_config.id,
      'store_code', v_config.store_code,
      'health_status', v_health_status,
      'is_active', v_config.is_active,
      'last_heartbeat_at',
        v_config.last_heartbeat_at,
      'last_sync', case
        when v_last_sync.synced_at is not null
        then jsonb_build_object(
          'status', v_last_sync.sync_status,
          'synced_at', v_last_sync.synced_at,
          'menus_fetched',
            v_last_sync.menus_fetched
        )
        else null
      end,
      'last_order', case
        when v_last_order.sent_at is not null
        then jsonb_build_object(
          'status', v_last_order.send_status,
          'sent_at', v_last_order.sent_at
        )
        else null
      end,
      'failed_orders_today', v_failed_count,
      'sop_runbook', case
        when v_health_status <> 'HEALTHY'
          then 'SOP-POS-001'
        else null
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.get_toss_pos_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_business_day date;
  v_health jsonb;
  v_sync_history jsonb;
  v_order_summary jsonb;
  v_menu_count int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_health :=
    catchmenu_integrations.get_toss_pos_health(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_locale := p_locale
    );

  -- 동기화 이력 최근 7회
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'sync_log_id', id,
        'sync_type', sync_type,
        'sync_status', sync_status,
        'menus_fetched', menus_fetched,
        'menus_created', menus_created,
        'menus_updated', menus_updated,
        'duration_ms', duration_ms,
        'synced_at', synced_at
      )
      order by synced_at desc
    ),
    '[]'::jsonb
  )
  into v_sync_history
  from catchmenu_integrations.toss_pos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  limit 7;

  -- 오늘 주문 요약
  select jsonb_build_object(
    'total_sent', count(*),
    'confirmed', count(*) filter (
      where send_status = 'CONFIRMED'
    ),
    'failed', count(*) filter (
      where send_status in (
        'FAILED', 'TIMEOUT'
      )
    ),
    'avg_duration_ms', coalesce(
      avg(duration_ms)::int, 0
    )
  )
  into v_order_summary
  from catchmenu_integrations.toss_pos_order_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and sent_at::date = v_business_day;

  -- 토스POS 동기화 메뉴 수
  select count(*) into v_menu_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and menu_code like 'TPOS_%'
    and is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'toss_pos_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'health', v_health->'data',
      'synced_menu_count', v_menu_count,
      'today_orders', v_order_summary,
      'sync_history', v_sync_history,
      'menu_code_prefix', 'TPOS_',
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- =============================================
-- pg_cron: 토스POS 헬스체크
-- =============================================
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'TOSS_POS_HEARTBEAT',
  'catchmenu_toss_pos_heartbeat',
  '*/5 * * * *',
  '*/5 * * * * (5분마다)',
  $sql$
SELECT catchmenu_common.notify_channel(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_channel_type := 'SYSTEM_EVENTS',
  p_event_type :=
    'toss_pos_heartbeat_requested',
  p_payload := jsonb_build_object(
    'store_id',
      '00000000-0000-0000-0000-000000000002',
    'requested_at', now()
  )
);
$sql$,
  '토스POS 연결 상태 확인. 5분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.sync_toss_pos_menu(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_toss_pos_menu(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.send_order_to_toss_pos(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.send_order_to_toss_pos(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations
      .confirm_toss_pos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) from public;
  grant execute on function
    catchmenu_integrations
      .confirm_toss_pos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_toss_pos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_toss_pos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_toss_pos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_toss_pos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_pos_health(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_pos_health(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_toss_pos_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_toss_pos_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.sync_toss_pos_menu(
    uuid, uuid, text, jsonb, text, text
  ) is
  '토스POS 메뉴 동기화.
   OKpos와 동일 구조, 코드 규칙만 다름.
   메뉴 코드: TPOS_{menuCode}
   카테고리 코드: TPOS_CAT_{categoryCode}
   API 필드명: menuCode/salePrice/useYn
     (OKpos: menu_code/price/is_available)
   FULL SYNC: TPOS_ 코드 없는 메뉴 비활성화.
   가격 변경 → ledger event 기록.
   1차 MVP 토스POS 연동 핵심.';

comment on function
  catchmenu_integrations.confirm_toss_pos_payment(
    uuid, uuid, uuid, jsonb, text, text
  ) is
  '토스POS 결제 확인 → 표준 파이프라인.
   API 필드명: approvalNo/paidAmt/payMethod
     (OKpos: approval_number/paid_amount/payment_method)
   confirm_payment() 호출 → KDS Late Binding.
   특허2: 토스POS 결제 = KDS HOLD 해제.
   provider_type = TOSS_POS.
   1차 MVP 결제 흐름 핵심.

   POS별 표준화 원칙:
   OKpos → confirm_okpos_payment()
   Toss POS → confirm_toss_pos_payment()
   모두 confirm_payment()로 수렴.
   단일 감사 원장 = 특허4 핵심.';
