-- 0102_create_okpos_integration_pipeline_rpc.sql
-- Purpose: OKpos API real integration pipeline.
--          OKpos 메뉴 동기화, 주문 전송,
--          결제 확인, 취소 파이프라인.
--          1차 MVP 핵심 POS 연동.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0101_create_project_background_docs.sql
-- Creates:
--   catchmenu_integrations.okpos_menu_sync_log (table)
--   catchmenu_integrations.okpos_order_send_log (table)
--   function catchmenu_integrations.sync_okpos_menu(...)
--   function catchmenu_integrations.send_order_to_okpos(...)
--   function catchmenu_integrations.confirm_okpos_payment(...)
--   function catchmenu_integrations.cancel_okpos_order(...)
--   function catchmenu_integrations.get_okpos_health(...)
--   function catchmenu_integrations.get_okpos_dashboard(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('okpos_menu_synced', 'ko',
  'OKpos 메뉴가 동기화되었습니다'),
('okpos_menu_synced', 'en',
  'OKpos menu synced'),
('okpos_order_sent', 'ko',
  'OKpos에 주문이 전송되었습니다'),
('okpos_order_sent', 'en',
  'Order sent to OKpos'),
('okpos_payment_confirmed', 'ko',
  'OKpos 결제가 확인되었습니다'),
('okpos_payment_confirmed', 'en',
  'OKpos payment confirmed'),
('okpos_order_cancelled', 'ko',
  'OKpos 주문이 취소되었습니다'),
('okpos_order_cancelled', 'en',
  'OKpos order cancelled'),
('okpos_health_ok', 'ko',
  'OKpos 연결이 정상입니다'),
('okpos_health_ok', 'en',
  'OKpos connection healthy'),
('okpos_health_error', 'ko',
  'OKpos 연결에 문제가 있습니다'),
('okpos_health_error', 'en',
  'OKpos connection error'),
('okpos_dashboard_loaded', 'ko',
  'OKpos 대시보드가 로드되었습니다'),
('okpos_dashboard_loaded', 'en',
  'OKpos dashboard loaded'),
('okpos_menu_not_found', 'ko',
  'OKpos에서 메뉴를 찾을 수 없습니다'),
('okpos_menu_not_found', 'en',
  'Menu not found in OKpos'),
('okpos_sync_failed', 'ko',
  'OKpos 동기화에 실패했습니다'),
('okpos_sync_failed', 'en',
  'OKpos sync failed'),
('okpos_order_failed', 'ko',
  'OKpos 주문 전송에 실패했습니다'),
('okpos_order_failed', 'en',
  'OKpos order transmission failed')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity,
  sop_document_code
) values
(9010, 'okpos_connection_failed',
  'INTEGRATION', 'TECHNICAL', 503, 'ERROR',
  'SOP-POS-001'),
(9011, 'okpos_menu_sync_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9012, 'okpos_order_send_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'ERROR',
  'SOP-POS-001'),
(9013, 'okpos_payment_confirm_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-001'),
(9014, 'okpos_cancel_failed',
  'INTEGRATION', 'TECHNICAL', 500, 'CRITICAL',
  'SOP-PAY-002'),
(9015, 'okpos_config_not_found',
  'INTEGRATION', 'NOT_FOUND', 404, 'ERROR',
  'SOP-POS-001')
on conflict (code) do nothing;


-- =============================================
-- okpos_menu_sync_log table
-- OKpos 메뉴 동기화 이력
-- =============================================
create table if not exists
  catchmenu_integrations.okpos_menu_sync_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 동기화 정보
  sync_type text not null default 'FULL',
  sync_direction text not null default 'FROM_OKPOS',

  -- 결과
  sync_status text not null default 'PENDING',
  menus_fetched int not null default 0,
  menus_created int not null default 0,
  menus_updated int not null default 0,
  menus_deactivated int not null default 0,
  menus_skipped int not null default 0,

  -- OKpos 응답
  okpos_response jsonb,
  error_detail text,

  -- 성능
  duration_ms int,
  synced_at timestamptz not null default now(),
  completed_at timestamptz,

  constraint chk_sync_type check (
    sync_type in (
      'FULL', 'INCREMENTAL',
      'PRICE_ONLY', 'STATUS_ONLY'
    )
  ),
  constraint chk_sync_direction check (
    sync_direction in (
      'FROM_OKPOS', 'TO_OKPOS', 'BIDIRECTIONAL'
    )
  ),
  constraint chk_sync_status check (
    sync_status in (
      'PENDING', 'IN_PROGRESS',
      'COMPLETED', 'PARTIAL', 'FAILED'
    )
  )
);

create index if not exists idx_okpos_menu_sync
  on catchmenu_integrations.okpos_menu_sync_log(
    store_id, synced_at desc
  );
create index if not exists idx_okpos_sync_failed
  on catchmenu_integrations.okpos_menu_sync_log(
    sync_status, synced_at desc
  ) where sync_status = 'FAILED';

alter table
  catchmenu_integrations.okpos_menu_sync_log
  enable row level security;
alter table
  catchmenu_integrations.okpos_menu_sync_log
  force row level security;

drop policy if exists okpos_menu_sync_isolation
  on catchmenu_integrations.okpos_menu_sync_log;
create policy okpos_menu_sync_isolation
  on catchmenu_integrations.okpos_menu_sync_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.okpos_menu_sync_log is
  'OKpos 메뉴 동기화 이력.
   FROM_OKPOS: OKpos → Catch Menu (기본).
   TO_OKPOS: Catch Menu → OKpos (가격 변경 등).
   FULL: 전체 동기화 (초기 설정).
   INCREMENTAL: 변경분만 (일상).
   특허1: POS 메뉴 = 주문 데이터 근거.
   1차 MVP OKpos 연동 핵심 감사 테이블.';


-- =============================================
-- okpos_order_send_log table
-- OKpos 주문 전송 이력
-- =============================================
create table if not exists
  catchmenu_integrations.okpos_order_send_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 주문 정보
  order_id uuid
    references catchmenu_pos.orders(id),
  okpos_order_id text,

  -- 전송 결과
  send_status text not null default 'PENDING',
  retry_count int not null default 0,

  -- 요청/응답
  request_payload jsonb,
  okpos_response jsonb,
  error_code text,
  error_detail text,

  -- 타임스탬프
  sent_at timestamptz not null default now(),
  confirmed_at timestamptz,
  duration_ms int,

  constraint chk_send_status check (
    send_status in (
      'PENDING', 'SENT', 'CONFIRMED',
      'FAILED', 'CANCELLED', 'TIMEOUT'
    )
  )
);

create index if not exists idx_okpos_order_send
  on catchmenu_integrations.okpos_order_send_log(
    order_id
  ) where order_id is not null;
create index if not exists idx_okpos_send_failed
  on catchmenu_integrations.okpos_order_send_log(
    store_id, send_status, sent_at desc
  ) where send_status in ('FAILED', 'PENDING');

alter table
  catchmenu_integrations.okpos_order_send_log
  enable row level security;
alter table
  catchmenu_integrations.okpos_order_send_log
  force row level security;

drop policy if exists okpos_order_send_isolation
  on catchmenu_integrations.okpos_order_send_log;
create policy okpos_order_send_isolation
  on catchmenu_integrations.okpos_order_send_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_integrations.okpos_order_send_log is
  'OKpos 주문 전송 이력.
   주문 생성 → OKpos 전송 → 확인.
   TIMEOUT: 3~5초 내 응답 없음 → 망취소 시도.
   retry_count: 최대 3회 재시도.
   특허1: POS 주문 전송 = 감사 증빙.
   1차 MVP 핵심 감사 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_integrations.sync_okpos_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_sync_type text default 'FULL',
  p_okpos_menu_data jsonb default null,
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
  v_menu_id uuid;
  v_created int := 0;
  v_updated int := 0;
  v_deactivated int := 0;
  v_skipped int := 0;
  v_fetched int := 0;
  v_okpos_codes jsonb := '[]'::jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- OKpos 설정 조회
  select id, store_code, api_endpoint,
         api_key_hash, pos_terminal_id,
         is_active
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'OKPOS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'okpos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'sync_okpos_menu'
    );
  end if;

  -- 동기화 로그 시작
  insert into
    catchmenu_integrations.okpos_menu_sync_log (
    tenant_id, store_id,
    sync_type, sync_direction,
    sync_status, okpos_response
  ) values (
    p_tenant_id, p_store_id,
    p_sync_type, 'FROM_OKPOS',
    'IN_PROGRESS',
    jsonb_build_object(
      'config_id', v_config.id,
      'sync_type', p_sync_type
    )
  )
  returning id into v_sync_log_id;

  -- =============================================
  -- OKpos API 호출은 Edge Function 담당
  -- 여기서는 Edge Function이 전달한
  -- p_okpos_menu_data를 처리
  -- =============================================
  if p_okpos_menu_data is null then
    -- Edge Function에 메뉴 조회 요청
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type := 'okpos_menu_fetch_requested',
      p_payload := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'config_id', v_config.id,
        'store_code', v_config.store_code,
        'sync_type', p_sync_type,
        'api_endpoint', v_config.api_endpoint,
        'pos_terminal_id',
          v_config.pos_terminal_id,
        'correlation_id', p_correlation_id
      )
    );

    update catchmenu_integrations
      .okpos_menu_sync_log
    set
      sync_status = 'PENDING',
      okpos_response = jsonb_build_object(
        'status', 'waiting_edge_function',
        'note', 'Edge Function will call back'
      )
    where id = v_sync_log_id;

    return catchmenu_common.build_success_response(
      p_message_key := 'okpos_menu_synced',
      p_data := jsonb_build_object(
        'sync_log_id', v_sync_log_id,
        'sync_status', 'PENDING',
        'note',
          'Edge Function okpos-menu-sync 호출됨. '
          || '완료 후 sync_okpos_menu()에 '
          || 'p_okpos_menu_data 전달 필요.'
      ),
      p_locale := p_locale
    );
  end if;

  -- Edge Function이 메뉴 데이터 전달한 경우
  v_fetched := jsonb_array_length(
    coalesce(p_okpos_menu_data, '[]'::jsonb)
  );

  -- OKpos 메뉴 항목 처리
  for v_item in
    select * from jsonb_array_elements(
      p_okpos_menu_data
    )
  loop
    declare
      v_okpos_code text;
      v_menu_name text;
      v_price int;
      v_cat_code text;
      v_cat_name text;
      v_is_available boolean;
      v_existing record;
    begin
      v_okpos_code :=
        'OKPOS_' || (v_item->>'menu_code');
      v_menu_name :=
        coalesce(
          v_item->>'menu_name_ko',
          v_item->>'menu_name'
        );
      v_price := (v_item->>'price')::int;
      v_cat_code :=
        'OKPOS_CAT_'
        || coalesce(
          v_item->>'category_code', 'DEFAULT'
        );
      v_cat_name := coalesce(
        v_item->>'category_name_ko',
        v_item->>'category_name',
        'OKpos 메뉴'
      );
      v_is_available := coalesce(
        (v_item->>'is_available')::boolean,
        true
      );

      -- OKpos 코드 추적
      v_okpos_codes := v_okpos_codes
        || to_jsonb(v_okpos_code);

      -- 카테고리 upsert
      insert into catchmenu_pos.menu_categories (
        tenant_id, store_id,
        category_code, category_name,
        display_order
      ) values (
        p_tenant_id, p_store_id,
        v_cat_code, v_cat_name,
        coalesce(
          (v_item->>'category_order')::int, 0
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
        and menu_code = v_okpos_code;

      if v_existing.id is null then
        -- 신규 메뉴 생성
        insert into catchmenu_pos.menus (
          tenant_id, store_id, category_id,
          menu_code, menu_name,
          price, menu_status,
          is_kds_required,
          display_order, description,
          pos_sync_at
        ) values (
          p_tenant_id, p_store_id, v_category_id,
          v_okpos_code, v_menu_name,
          v_price,
          case v_is_available
            when true then 'AVAILABLE'
            else 'SOLD_OUT'
          end,
          true,
          coalesce(
            (v_item->>'display_order')::int, 0
          ),
          v_item->>'description',
          now()
        )
        returning id into v_menu_id;

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

        if v_existing.price <> v_price then
          -- 가격 변경 이력
          insert into catchmenu_ledger.events (
            tenant_id, store_id,
            event_domain, event_type,
            event_version,
            subject_type, subject_id,
            from_state, to_state,
            caused_by_type, event_payload,
            correlation_id,
            business_day, business_timezone,
            occurred_at
          ) values (
            p_tenant_id, p_store_id,
            'menu', 'menu_price_changed', 1,
            'menu', v_existing.id,
            v_existing.price::text,
            v_price::text,
            'OKPOS_SYNC',
            jsonb_build_object(
              'menu_code', v_okpos_code,
              'old_price', v_existing.price,
              'new_price', v_price,
              'sync_log_id', v_sync_log_id
            ),
            p_correlation_id,
            v_business_day, 'Asia/Seoul', now()
          );
        end if;

        v_updated := v_updated + 1;
      end if;
    end;
  end loop;

  -- FULL SYNC: OKpos에 없는 메뉴 비활성화
  if p_sync_type = 'FULL'
    and jsonb_array_length(v_okpos_codes) > 0
  then
    update catchmenu_pos.menus
    set
      menu_status = 'DISCONTINUED',
      is_active = false,
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_code like 'OKPOS_%'
      and not (
        v_okpos_codes @> to_jsonb(menu_code)
      )
      and menu_status <> 'DISCONTINUED';

    get diagnostics v_deactivated = row_count;
  end if;

  -- 동기화 로그 완료
  update catchmenu_integrations.okpos_menu_sync_log
  set
    sync_status = 'COMPLETED',
    menus_fetched = v_fetched,
    menus_created = v_created,
    menus_updated = v_updated,
    menus_deactivated = v_deactivated,
    menus_skipped = v_skipped,
    duration_ms = extract(
      epoch from (now() - v_start)
    )::int * 1000,
    completed_at = now()
  where id = v_sync_log_id;

  -- 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'INTEGRATION',
    p_log_event := 'okpos_menu_synced',
    p_message :=
      'OKpos 메뉴 동기화 완료'
      || ' | 조회=' || v_fetched
      || ' | 생성=' || v_created
      || ' | 수정=' || v_updated
      || ' | 비활성=' || v_deactivated,
    p_rpc_name := 'sync_okpos_menu',
    p_correlation_id := p_correlation_id,
    p_details := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'sync_type', p_sync_type,
      'created', v_created,
      'updated', v_updated,
      'deactivated', v_deactivated
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'okpos_menu_synced',
    p_data := jsonb_build_object(
      'sync_log_id', v_sync_log_id,
      'sync_type', p_sync_type,
      'sync_status', 'COMPLETED',
      'result', jsonb_build_object(
        'fetched', v_fetched,
        'created', v_created,
        'updated', v_updated,
        'deactivated', v_deactivated,
        'skipped', v_skipped
      ),
      'duration_ms', extract(
        epoch from (now() - v_start)
      )::int * 1000
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.send_order_to_okpos(
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
  v_send_log_id uuid;
  v_request_payload jsonb;
begin
  -- OKpos 설정 조회
  select id, store_code, api_endpoint,
         pos_terminal_id
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'OKPOS'
    and is_active = true;

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'okpos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'send_order_to_okpos'
    );
  end if;

  -- 주문 조회
  select o.id, o.order_number, o.order_type,
         o.order_status, o.final_amount,
         o.total_amount, o.discount_amount,
         o.memo, o.session_id,
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
      p_rpc_name := 'send_order_to_okpos'
    );
  end if;

  -- 주문 항목 조회
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_code', replace(
          m.menu_code, 'OKPOS_', ''
        ),
        'menu_name', oi.menu_name_snapshot,
        'quantity', oi.quantity,
        'unit_price', oi.unit_price,
        'subtotal', oi.subtotal,
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

  -- OKpos 전송 페이로드 구성
  -- OKpos API 규격에 맞게 구성
  v_request_payload := jsonb_build_object(
    'store_code', v_config.store_code,
    'terminal_id', v_config.pos_terminal_id,
    'order_number', v_order.order_number,
    'order_type', case v_order.order_type
      when 'TABLE' then 'DINE_IN'
      when 'TAKEOUT' then 'TAKEOUT'
      when 'DELIVERY' then 'DELIVERY'
      else 'TAKEOUT'
    end,
    'table_number',
      coalesce(v_order.table_number, ''),
    'items', v_items,
    'total_amount', v_order.total_amount,
    'discount_amount', v_order.discount_amount,
    'final_amount', v_order.final_amount,
    'memo', coalesce(v_order.memo, ''),
    'timestamp', now()
  );

  -- 전송 로그 생성
  insert into
    catchmenu_integrations.okpos_order_send_log (
    tenant_id, store_id, order_id,
    send_status, request_payload,
    sent_at
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    'PENDING', v_request_payload,
    now()
  )
  returning id into v_send_log_id;

  -- 주문에 OKpos 연결 정보 기록
  update catchmenu_pos.orders
  set
    provider_type = 'OKPOS',
    updated_at = now()
  where id = p_order_id;

  -- Edge Function에 OKpos 전송 요청
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'SYSTEM_EVENTS',
    p_event_type := 'okpos_order_send_requested',
    p_payload := jsonb_build_object(
      'send_log_id', v_send_log_id,
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
    p_message_key := 'okpos_order_sent',
    p_data := jsonb_build_object(
      'send_log_id', v_send_log_id,
      'order_id', p_order_id,
      'order_number', v_order.order_number,
      'send_status', 'PENDING',
      'items_count',
        jsonb_array_length(v_items),
      'final_amount', v_order.final_amount,
      'note',
        'Edge Function okpos-order-send 처리 중'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_okpos_order_sent(
  p_tenant_id uuid,
  p_store_id uuid,
  p_send_log_id uuid,
  p_okpos_order_id text,
  p_send_result text,
  p_okpos_response jsonb default null,
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
  from catchmenu_integrations.okpos_order_send_log
  where id = p_send_log_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
  for update;

  if v_log.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_okpos_order_sent'
    );
  end if;

  v_new_status := case p_send_result
    when 'SUCCESS' then 'CONFIRMED'
    when 'TIMEOUT' then 'TIMEOUT'
    else 'FAILED'
  end;

  update catchmenu_integrations.okpos_order_send_log
  set
    send_status = v_new_status,
    okpos_order_id = p_okpos_order_id,
    okpos_response = p_okpos_response,
    error_detail = p_error_detail,
    duration_ms = p_duration_ms,
    confirmed_at = case p_send_result
      when 'SUCCESS' then now()
      else null
    end,
    updated_at = now()
  where id = p_send_log_id;

  -- 실패/타임아웃 시 운영 알림
  if v_new_status in ('FAILED', 'TIMEOUT') then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'POS_DISCONNECTED',
      p_alert_severity := case v_new_status
        when 'TIMEOUT' then 'ERROR'
        else 'CRITICAL'
      end,
      p_alert_domain := 'INTEGRATION',
      p_alert_title_key := 'okpos_order_failed',
      p_alert_detail := jsonb_build_object(
        'send_log_id', p_send_log_id,
        'order_id', v_log.order_id,
        'send_result', p_send_result,
        'error_detail', p_error_detail
      ),
      p_store_id := p_store_id,
      p_sop_runbook_code := 'SOP-POS-001'
    );
  end if;

  -- 주문에 OKpos 주문 ID 기록
  if p_send_result = 'SUCCESS'
    and p_okpos_order_id is not null
  then
    update catchmenu_pos.orders
    set
      provider_order_id = p_okpos_order_id,
      updated_at = now()
    where id = v_log.order_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := case p_send_result
      when 'SUCCESS' then 'okpos_order_sent'
      else 'okpos_order_failed'
    end,
    p_data := jsonb_build_object(
      'send_log_id', p_send_log_id,
      'order_id', v_log.order_id,
      'okpos_order_id', p_okpos_order_id,
      'send_status', v_new_status,
      'send_result', p_send_result
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_integrations.confirm_okpos_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_okpos_tx_data jsonb,
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
  v_okpos_tx_id text;
  v_result jsonb;
begin
  -- OKpos 결제 데이터 파싱
  v_approval_number :=
    p_okpos_tx_data->>'approval_number';
  v_approved_amount :=
    (p_okpos_tx_data->>'paid_amount')::int;
  v_payment_method := coalesce(
    p_okpos_tx_data->>'payment_method', 'CARD'
  );
  v_okpos_tx_id :=
    p_okpos_tx_data->>'okpos_tx_id';

  -- OKpos 거래 원장 기록
  insert into
    catchmenu_integrations.okpos_transactions (
    tenant_id, store_id, order_id,
    okpos_order_id, okpos_tx_id,
    okpos_tx_type, processing_status,
    paid_amount, payment_method,
    approval_number,
    raw_request, raw_response,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    p_okpos_tx_data->>'okpos_order_id',
    v_okpos_tx_id,
    'PAYMENT_CONFIRM', 'COMPLETED',
    v_approved_amount, v_payment_method,
    v_approval_number,
    p_okpos_tx_data, p_okpos_tx_data,
    (timezone('Asia/Seoul', now()))::date
  );

  -- 표준 결제 확인 파이프라인 호출
  v_result := catchmenu_payment.confirm_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_provider_type := 'OKPOS',
    p_provider_approval_number :=
      v_approval_number,
    p_provider_tx_id := v_okpos_tx_id,
    p_approved_amount := v_approved_amount,
    p_payment_method := v_payment_method,
    p_provider_response := p_okpos_tx_data,
    p_actor_type := 'POS',
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'okpos_payment_confirmed',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'okpos_tx_id', v_okpos_tx_id,
      'approval_number', v_approval_number,
      'approved_amount', v_approved_amount,
      'payment_result', v_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_integrations.cancel_okpos_order(
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
  v_send_log record;
  v_refund_result jsonb;
begin
  -- OKpos 전송 이력 확인
  select id, okpos_order_id, send_status
  into v_send_log
  from catchmenu_integrations.okpos_order_send_log
  where order_id = p_order_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status = 'CONFIRMED'
  order by confirmed_at desc
  limit 1;

  -- Edge Function에 OKpos 취소 요청
  if v_send_log.id is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS',
      p_event_type :=
        'okpos_order_cancel_requested',
      p_payload := jsonb_build_object(
        'order_id', p_order_id,
        'okpos_order_id',
          v_send_log.okpos_order_id,
        'send_log_id', v_send_log.id,
        'cancel_reason', p_cancel_reason,
        'correlation_id', p_correlation_id
      )
    );
  end if;

  -- 표준 환불 파이프라인 호출
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

  -- OKpos 취소 거래 기록
  insert into
    catchmenu_integrations.okpos_transactions (
    tenant_id, store_id, order_id,
    okpos_order_id,
    okpos_tx_type, processing_status,
    paid_amount,
    raw_request,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_order_id,
    v_send_log.okpos_order_id,
    'PAYMENT_CANCEL', 'COMPLETED',
    0,
    jsonb_build_object(
      'cancel_reason', p_cancel_reason,
      'okpos_order_id',
        v_send_log.okpos_order_id
    ),
    (timezone('Asia/Seoul', now()))::date
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'okpos_order_cancelled',
    p_data := jsonb_build_object(
      'order_id', p_order_id,
      'okpos_order_id',
        v_send_log.okpos_order_id,
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
  catchmenu_integrations.get_okpos_health(
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
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- OKpos 설정
  select id, store_code, api_endpoint,
         is_active, last_heartbeat_at
  into v_config
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and provider_code = 'OKPOS';

  if v_config.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'okpos_config_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_okpos_health'
    );
  end if;

  -- 최근 메뉴 동기화
  select sync_status, synced_at,
         menus_fetched, duration_ms
  into v_last_sync
  from catchmenu_integrations.okpos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by synced_at desc
  limit 1;

  -- 최근 주문 전송
  select send_status, sent_at, duration_ms
  into v_last_order
  from catchmenu_integrations.okpos_order_send_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  order by sent_at desc
  limit 1;

  -- 오늘 실패 건수
  select count(*) into v_failed_count
  from catchmenu_integrations.okpos_order_send_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and send_status in ('FAILED', 'TIMEOUT')
    and sent_at::date = v_business_day;

  -- 연결 상태 판단
  declare
    v_is_connected boolean;
    v_health_status text;
  begin
    v_is_connected := v_config.is_active
      and (
        v_config.last_heartbeat_at is null
        or v_config.last_heartbeat_at
          > now() - interval '10 minutes'
      );

    v_health_status := case
      when not v_config.is_active then 'INACTIVE'
      when v_failed_count >= 3 then 'DEGRADED'
      when v_is_connected then 'HEALTHY'
      else 'UNKNOWN'
    end;

    return catchmenu_common.build_success_response(
      p_message_key := case v_health_status
        when 'HEALTHY' then 'okpos_health_ok'
        else 'okpos_health_error'
      end,
      p_data := jsonb_build_object(
        'config_id', v_config.id,
        'store_code', v_config.store_code,
        'api_endpoint', v_config.api_endpoint,
        'is_active', v_config.is_active,
        'health_status', v_health_status,
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
end;
$$;


create or replace function
  catchmenu_integrations.get_okpos_dashboard(
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

  -- 헬스 상태
  v_health := catchmenu_integrations.get_okpos_health(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_locale := p_locale
  );

  -- 동기화 이력 (최근 7회)
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
  from catchmenu_integrations.okpos_menu_sync_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
  limit 7;

  -- 오늘 주문 전송 요약
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
    'pending', count(*) filter (
      where send_status = 'PENDING'
    ),
    'avg_duration_ms', coalesce(
      avg(duration_ms)::int, 0
    )
  )
  into v_order_summary
  from catchmenu_integrations.okpos_order_send_log
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and sent_at::date = v_business_day;

  -- OKpos 동기화된 메뉴 수
  select count(*) into v_menu_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and menu_code like 'OKPOS_%'
    and is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'okpos_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'health', v_health->'data',
      'synced_menu_count', v_menu_count,
      'today_orders', v_order_summary,
      'sync_history', v_sync_history,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron 업데이트: OKpos 헬스체크 강화
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_registered
) values
(
  'OKPOS_HEARTBEAT',
  'catchmenu_okpos_heartbeat',
  '*/3 * * * *',
  '*/3 * * * * (3분마다)',
  $sql$
-- Edge Function에 OKpos 헬스체크 요청
SELECT catchmenu_common.notify_channel(
  p_tenant_id :=
    '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id :=
    '00000000-0000-0000-0000-000000000002'::uuid,
  p_channel_type := 'SYSTEM_EVENTS',
  p_event_type := 'okpos_heartbeat_requested',
  p_payload := jsonb_build_object(
    'store_id',
      '00000000-0000-0000-0000-000000000002',
    'requested_at', now()
  )
);
$sql$,
  'OKpos 연결 상태 주기적 확인. 3분마다.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.sync_okpos_menu(
      uuid, uuid, text, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_okpos_menu(
      uuid, uuid, text, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.send_order_to_okpos(
      uuid, uuid, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.send_order_to_okpos(
      uuid, uuid, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations
      .confirm_okpos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) from public;
  grant execute on function
    catchmenu_integrations
      .confirm_okpos_order_sent(
      uuid, uuid, uuid, text, text,
      jsonb, text, int, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.confirm_okpos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.confirm_okpos_payment(
      uuid, uuid, uuid, jsonb, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.cancel_okpos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.cancel_okpos_order(
      uuid, uuid, uuid, text, uuid, text, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_okpos_health(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_okpos_health(
      uuid, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.get_okpos_dashboard(
      uuid, uuid, text
    ) from public;
  grant execute on function
    catchmenu_integrations.get_okpos_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.sync_okpos_menu(
    uuid, uuid, text, jsonb, text, text
  ) is
  'OKpos 메뉴 동기화.
   호출 방식 2가지:
   1. p_okpos_menu_data = null:
      Edge Function 트리거 → 비동기 처리.
      Edge Function이 OKpos API 호출 후
      p_okpos_menu_data 채워서 재호출.
   2. p_okpos_menu_data 있음:
      즉시 동기화 처리.

   메뉴 코드 규칙: OKPOS_{okpos_menu_code}
   카테고리 코드 규칙: OKPOS_CAT_{code}
   FULL SYNC: OKpos에 없는 메뉴 비활성화.
   가격 변경 시 ledger event 기록.
   특허1: POS 메뉴 = 주문 데이터 권위 근거.
   1차 MVP 핵심 연동.';

comment on function
  catchmenu_integrations.confirm_okpos_payment(
    uuid, uuid, uuid, jsonb, text, text
  ) is
  'OKpos 결제 확인 → 표준 파이프라인 연동.
   OKpos 결제 데이터 파싱 후
   confirm_payment() 호출 → KDS Late Binding.
   okpos_transactions에 원본 기록.
   Layer 1 대사 자동 포함.
   특허2: OKpos 결제 확인 = KDS HOLD 해제.
   1차 MVP 결제 흐름 핵심.';
