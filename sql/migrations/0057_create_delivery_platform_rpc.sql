-- 0057_create_delivery_platform_rpc.sql
-- Purpose: Detailed delivery platform integration RPCs.
--          Baemin, Yogiyo, Coupang Eats specific handlers.
--          Normalizes platform-specific payloads to internal format.
--          특허1 core: 배달 플랫폼별 페이로드 정규화 → 공통 Gateway 진입.
-- Depends on: 0056_create_van_integration_rpc.sql
-- Creates:
--   catchmenu_integrations.delivery_platform_configs (table)
--   function catchmenu_integrations.process_baemin_order(...)
--   function catchmenu_integrations.process_yogiyo_order(...)
--   function catchmenu_integrations.process_coupang_order(...)
--   function catchmenu_integrations.sync_delivery_menu(...)

-- =============================================
-- delivery_platform_configs table
-- =============================================
create table if not exists
  catchmenu_integrations.delivery_platform_configs (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  platform_type text not null,
  platform_store_id text,
  platform_store_name text,

  -- API credentials (encrypted at app layer)
  api_key_hint text,
  webhook_secret_hint text,
  is_webhook_enabled boolean not null default true,

  -- auto-accept settings
  auto_accept_enabled boolean not null default true,
  auto_accept_delay_seconds int not null default 30,
  reject_if_kds_overloaded boolean not null default true,
  kds_overload_threshold int not null default 20,

  -- menu sync settings
  menu_sync_enabled boolean not null default true,
  last_menu_synced_at timestamptz,

  -- status
  platform_status text not null default 'ACTIVE',
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_platform_store unique (
    store_id, platform_type
  ),
  constraint chk_platform_type check (
    platform_type in (
      'DELIVERY_BAEMIN',
      'DELIVERY_YOGIYO',
      'DELIVERY_COUPANG'
    )
  ),
  constraint chk_platform_status check (
    platform_status in (
      'ACTIVE', 'SUSPENDED', 'DISCONNECTED'
    )
  )
);

create index if not exists idx_delivery_config_store
  on catchmenu_integrations.delivery_platform_configs(
    store_id
  );

alter table
  catchmenu_integrations.delivery_platform_configs
  enable row level security;
alter table
  catchmenu_integrations.delivery_platform_configs
  force row level security;

drop policy if exists delivery_config_isolation
  on catchmenu_integrations.delivery_platform_configs;
create policy delivery_config_isolation
  on catchmenu_integrations.delivery_platform_configs
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_delivery_config_updated_at
  on catchmenu_integrations.delivery_platform_configs;
create trigger trg_delivery_config_updated_at
  before update on
    catchmenu_integrations.delivery_platform_configs
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_integrations.delivery_platform_configs is
  'Per-store delivery platform configuration.
   Controls auto-accept, KDS overload rejection, menu sync.
   특허2: KDS 과부하 시 배달 주문 자동 거절 설정.
   reject_if_kds_overloaded = true →
   kds_overload_threshold 초과 시 신규 배달 주문 자동 거절.';


-- =============================================
-- Baemin order processor
-- =============================================
create or replace function
  catchmenu_integrations.process_baemin_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_payload jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  -- get platform config
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_BAEMIN'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'baemin_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'baemin_platform_suspended',
      'platform_status', v_config.platform_status
    );
  end if;

  -- 특허2: KDS 과부하 체크
  -- COOKING 중인 티켓이 threshold 초과 시 거절
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      -- auto reject
      perform catchmenu_ledger.create_exception(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_exception_domain := 'delivery',
        p_exception_type := 'delivery_rejected_kds_overload',
        p_exception_severity := 'WARNING',
        p_subject_type := 'delivery_order',
        p_subject_id := null,
        p_error_message :=
          'Baemin order rejected: KDS overloaded ('
          || v_kds_load || '/'
          || v_config.kds_overload_threshold || ')',
        p_exception_payload := jsonb_build_object(
          'platform', 'DELIVERY_BAEMIN',
          'kds_load', v_kds_load,
          'threshold', v_config.kds_overload_threshold
        ),
        p_correlation_id := p_correlation_id
      );

      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code', 'baemin_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- extract Baemin order ID
  -- Baemin payload structure: orderId at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'orderId',
    p_raw_payload->>'order_id',
    p_raw_payload->>'id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_baemin_order_id'
    );
  end if;

  -- Baemin-specific normalization
  -- Baemin uses: orderItems array with
  -- menuId, menuName, count, unitPrice
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'payAmount',
      p_raw_payload->>'totalAmount',
      '0'
    ),
    'orderItems', coalesce(
      p_raw_payload->'orderItems',
      p_raw_payload->'menus',
      '[]'::jsonb
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'requestMsg',
      p_raw_payload->>'memo',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'estimatedPickupTime',
    'platform', 'DELIVERY_BAEMIN',
    'baemin_store_id',
      p_raw_payload->>'storeId',
    'order_type',
      coalesce(p_raw_payload->>'orderType', 'DELIVERY')
  );

  -- route to common intake RPC
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_BAEMIN',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_BAEMIN',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$$;


-- =============================================
-- Yogiyo order processor
-- =============================================
create or replace function
  catchmenu_integrations.process_yogiyo_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_payload jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_YOGIYO'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'yogiyo_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'yogiyo_platform_suspended'
    );
  end if;

  -- KDS overload check
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code',
          'yogiyo_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- Yogiyo-specific order ID extraction
  -- Yogiyo payload: order_number at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'order_number',
    p_raw_payload->>'orderId',
    p_raw_payload->>'id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_yogiyo_order_id'
    );
  end if;

  -- Yogiyo-specific normalization
  -- Yogiyo uses: items array with
  -- product_id, product_name, quantity, product_price
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'total_price',
      p_raw_payload->>'totalPrice',
      '0'
    ),
    'orderItems', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menuId', item->>'product_id',
            'menuName', item->>'product_name',
            'count', item->>'quantity',
            'unitPrice', item->>'product_price'
          )
        ),
        '[]'::jsonb
      )
      from jsonb_array_elements(
        coalesce(
          p_raw_payload->'items',
          p_raw_payload->'order_items',
          '[]'::jsonb
        )
      ) item
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'request_message',
      p_raw_payload->>'memo',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'pickup_time',
    'platform', 'DELIVERY_YOGIYO',
    'yogiyo_store_id',
      p_raw_payload->>'store_id'
  );

  -- route to common intake
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_YOGIYO',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_YOGIYO',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$$;


-- =============================================
-- Coupang Eats order processor
-- =============================================
create or replace function
  catchmenu_integrations.process_coupang_order(
  p_tenant_id uuid,
  p_store_id uuid,
  p_raw_payload jsonb,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_kds,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_config record;
  v_kds_load int;
  v_provider_order_id text;
  v_normalized jsonb;
  v_intake_result jsonb;
begin
  select id, auto_accept_enabled,
         auto_accept_delay_seconds,
         reject_if_kds_overloaded,
         kds_overload_threshold,
         platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = 'DELIVERY_COUPANG'
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupang_not_configured'
    );
  end if;

  if v_config.platform_status <> 'ACTIVE' then
    return jsonb_build_object(
      'success', false,
      'error_key', 'coupang_platform_suspended'
    );
  end if;

  -- KDS overload check
  if v_config.reject_if_kds_overloaded then
    select count(*)
    into v_kds_load
    from catchmenu_kds.kds_tickets
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and kds_status = 'COOKING';

    if v_kds_load >= v_config.kds_overload_threshold then
      return jsonb_build_object(
        'success', false,
        'error_key', 'kds_overloaded',
        'kds_current_load', v_kds_load,
        'threshold', v_config.kds_overload_threshold,
        'action', 'AUTO_REJECTED',
        'message_code',
          'coupang_order_rejected_kds_overload'
      );
    end if;
  end if;

  -- Coupang Eats payload: orderNo at root
  v_provider_order_id := coalesce(
    p_raw_payload->>'orderNo',
    p_raw_payload->>'orderId',
    p_raw_payload->>'order_id'
  );

  if v_provider_order_id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'missing_coupang_order_id'
    );
  end if;

  -- Coupang-specific normalization
  -- Coupang uses: cartItems array with
  -- productId, productName, quantity, unitPrice
  v_normalized := jsonb_build_object(
    'orderId', v_provider_order_id,
    'totalAmount', coalesce(
      p_raw_payload->>'totalPrice',
      p_raw_payload->>'orderAmount',
      '0'
    ),
    'orderItems', (
      select coalesce(
        jsonb_agg(
          jsonb_build_object(
            'menuId', item->>'productId',
            'menuName', item->>'productName',
            'count', item->>'quantity',
            'unitPrice', item->>'unitPrice',
            'options', item->'options'
          )
        ),
        '[]'::jsonb
      )
      from jsonb_array_elements(
        coalesce(
          p_raw_payload->'cartItems',
          p_raw_payload->'items',
          '[]'::jsonb
        )
      ) item
    ),
    'requestMsg', coalesce(
      p_raw_payload->>'storeRequest',
      p_raw_payload->>'requestMsg',
      ''
    ),
    'estimatedPickupTime',
      p_raw_payload->>'estimatedPickupAt',
    'platform', 'DELIVERY_COUPANG',
    'coupang_vendor_id',
      p_raw_payload->>'vendorId'
  );

  -- route to common intake
  v_intake_result :=
    catchmenu_integrations.intake_delivery_order(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_provider_type := 'DELIVERY_COUPANG',
      p_provider_order_id := v_provider_order_id,
      p_provider_raw_payload := v_normalized,
      p_correlation_id := p_correlation_id
    );

  return v_intake_result || jsonb_build_object(
    'platform', 'DELIVERY_COUPANG',
    'auto_accept_delay_seconds',
      v_config.auto_accept_delay_seconds
  );
end;
$$;


-- =============================================
-- Menu sync to delivery platforms
-- =============================================
create or replace function
  catchmenu_integrations.sync_delivery_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_platform_type text,
  p_sync_type text default 'FULL',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_integrations,
                  catchmenu_pos,
                  catchmenu_ledger,
                  catchmenu_common
as $$
declare
  v_config record;
  v_menu_catalog jsonb;
  v_sync_payload jsonb;
  v_menu_count int;
  v_sold_out_count int;
begin
  if p_platform_type not in (
    'DELIVERY_BAEMIN',
    'DELIVERY_YOGIYO',
    'DELIVERY_COUPANG'
  ) then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_platform_type'
    );
  end if;

  if p_sync_type not in ('FULL', 'STATUS_ONLY') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_sync_type'
    );
  end if;

  select id, platform_store_id,
         menu_sync_enabled, platform_status
  into v_config
  from catchmenu_integrations.delivery_platform_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and platform_type = p_platform_type
    and is_active = true;

  if v_config.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'platform_not_configured'
    );
  end if;

  if not v_config.menu_sync_enabled then
    return jsonb_build_object(
      'success', false,
      'error_key', 'menu_sync_disabled'
    );
  end if;

  -- get current menu catalog
  v_menu_catalog := catchmenu_pos.get_menu_catalog(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_locale := 'ko',
    p_include_hidden := false,
    p_include_sold_out := true
  );

  if not (v_menu_catalog->>'success')::boolean then
    return v_menu_catalog;
  end if;

  v_menu_count := (
    v_menu_catalog->>'menu_count'
  )::int;

  -- count sold out menus
  select count(*)
  into v_sold_out_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and menu_status = 'SOLD_OUT';

  -- build sync payload
  -- platform-specific format adaptation
  v_sync_payload := case p_platform_type
    when 'DELIVERY_BAEMIN' then
      jsonb_build_object(
        'storeId', v_config.platform_store_id,
        'syncType', p_sync_type,
        'menuCount', v_menu_count,
        'menus', v_menu_catalog->'menus',
        'categories', v_menu_catalog->'categories',
        'syncedAt', now()
      )
    when 'DELIVERY_YOGIYO' then
      jsonb_build_object(
        'store_id', v_config.platform_store_id,
        'sync_type', p_sync_type,
        'menu_count', v_menu_count,
        'items', v_menu_catalog->'menus',
        'categories', v_menu_catalog->'categories',
        'synced_at', now()
      )
    when 'DELIVERY_COUPANG' then
      jsonb_build_object(
        'vendorId', v_config.platform_store_id,
        'syncType', p_sync_type,
        'productCount', v_menu_count,
        'products', v_menu_catalog->'menus',
        'categories', v_menu_catalog->'categories',
        'syncedAt', now()
      )
    else '{}'::jsonb
  end;

  -- update last sync time
  update catchmenu_integrations.delivery_platform_configs
  set
    last_menu_synced_at = now(),
    updated_at = now()
  where id = v_config.id;

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
    'delivery', 'delivery_menu_synced', 1,
    'delivery_platform_config', v_config.id,
    null, 'SYNCED',
    'SYSTEM',
    jsonb_build_object(
      'platform_type', p_platform_type,
      'sync_type', p_sync_type,
      'menu_count', v_menu_count,
      'sold_out_count', v_sold_out_count
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return jsonb_build_object(
    'success', true,
    'platform_type', p_platform_type,
    'sync_type', p_sync_type,
    'menu_count', v_menu_count,
    'sold_out_count', v_sold_out_count,
    'sync_payload', v_sync_payload,
    'synced_at', now(),
    'message_code', 'delivery_menu_synced'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function
    catchmenu_integrations.process_baemin_order(
      uuid, uuid, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_baemin_order(
      uuid, uuid, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.process_yogiyo_order(
      uuid, uuid, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_yogiyo_order(
      uuid, uuid, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.process_coupang_order(
      uuid, uuid, jsonb, text
    ) from public;
  grant execute on function
    catchmenu_integrations.process_coupang_order(
      uuid, uuid, jsonb, text
    ) to authenticated;

  revoke all on function
    catchmenu_integrations.sync_delivery_menu(
      uuid, uuid, text, text, text
    ) from public;
  grant execute on function
    catchmenu_integrations.sync_delivery_menu(
      uuid, uuid, text, text, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_integrations.process_baemin_order(
    uuid, uuid, jsonb, text
  ) is
  'Baemin-specific order processor.
   1. Checks platform config and status.
   2. KDS overload check (특허2):
      cooking tickets >= threshold → auto reject.
   3. Normalizes Baemin payload to internal format.
   4. Routes to intake_delivery_order.
   Baemin payload: orderId, orderItems[], payAmount,
   requestMsg, estimatedPickupTime.';

comment on function
  catchmenu_integrations.process_yogiyo_order(
    uuid, uuid, jsonb, text
  ) is
  'Yogiyo-specific order processor.
   Normalizes Yogiyo payload format:
   order_number → orderId
   items[].product_id → menuId
   items[].product_name → menuName
   items[].quantity → count
   특허2: KDS 과부하 시 자동 거절.';

comment on function
  catchmenu_integrations.process_coupang_order(
    uuid, uuid, jsonb, text
  ) is
  'Coupang Eats specific order processor.
   Normalizes Coupang payload format:
   orderNo → orderId
   cartItems[].productId → menuId
   cartItems[].productName → menuName
   특허2: KDS 과부하 시 자동 거절.';

comment on function
  catchmenu_integrations.sync_delivery_menu(
    uuid, uuid, text, text, text
  ) is
  'Syncs current menu catalog to delivery platform.
   FULL: syncs all menus and categories.
   STATUS_ONLY: syncs only sold_out/available status.
   Builds platform-specific payload format for each provider.
   Result payload passed to app layer for actual API call.
   특허3: 메뉴 상태 변경 → 배달 플랫폼 자동 동기화.
   품절 정보 실시간 반영 → 플랫폼 내 품절 표시 자동화.';