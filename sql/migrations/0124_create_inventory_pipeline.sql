-- 0124_create_inventory_pipeline.sql
-- Purpose: Basic inventory and cost management.
--          식재료 재고 추적.
--          메뉴-재고 연결.
--          원가 계산.
--          재고 부족 알림.
--          자동 품절 처리.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0123_create_ai_customer_center_v2.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('inventory_updated', 'ko',
  '재고가 업데이트되었습니다'),
('inventory_updated', 'en',
  'Inventory updated'),
('inventory_low_alert', 'ko',
  '{item_name} 재고가 부족합니다 ({current_qty}{unit} 남음)'),
('inventory_low_alert', 'en',
  '{item_name} running low ({current_qty}{unit} left)'),
('inventory_out_alert', 'ko',
  '{item_name} 재고가 소진되었습니다'),
('inventory_out_alert', 'en',
  '{item_name} is out of stock'),
('inventory_dashboard_loaded', 'ko',
  '재고 현황이 로드되었습니다'),
('inventory_dashboard_loaded', 'en',
  'Inventory dashboard loaded'),
('cost_report_loaded', 'ko',
  '원가 리포트가 로드되었습니다'),
('cost_report_loaded', 'en',
  'Cost report loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(8010, 'inventory_item_not_found',
  'INVENTORY', 'NOT_FOUND', 404, 'WARNING'),
(8011, 'inventory_insufficient',
  'INVENTORY', 'BUSINESS_RULE', 409, 'WARNING'),
(8012, 'inventory_out_of_stock',
  'INVENTORY', 'BUSINESS_RULE', 409, 'INFO')
on conflict (code) do nothing;


-- =============================================
-- inventory_items table
-- 식재료/원재료 관리
-- =============================================
create table if not exists
  catchmenu_store.inventory_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 기본 정보
  item_code text not null,
  item_name text not null,
  item_name_en text,
  item_category text not null
    default 'INGREDIENT',
  unit text not null default 'g',

  -- 재고
  current_qty numeric(12,3) not null default 0,
  min_qty numeric(12,3) not null default 0,
  max_qty numeric(12,3),
  reorder_qty numeric(12,3),

  -- 원가
  unit_cost int not null default 0,
  last_purchase_cost int,
  avg_cost int,

  -- 공급업체
  supplier_name text,
  supplier_contact text,

  -- 자동화
  auto_soldout_enabled boolean
    not null default false,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_inventory_code unique (
    store_id, item_code
  ),
  constraint chk_item_category check (
    item_category in (
      'INGREDIENT',  -- 식재료
      'PACKAGING',   -- 포장재
      'BEVERAGE',    -- 음료
      'CONSUMABLE',  -- 소모품
      'SAUCE'        -- 소스/양념
    )
  ),
  constraint chk_unit check (
    unit in (
      'g', 'kg', 'ml', 'l',
      'ea', 'box', 'bag', 'bottle'
    )
  )
);

create index if not exists idx_inventory_store
  on catchmenu_store.inventory_items(
    store_id, is_active
  );
create index if not exists idx_inventory_low
  on catchmenu_store.inventory_items(
    store_id, current_qty, min_qty
  ) where is_active = true;

alter table catchmenu_store.inventory_items
  enable row level security;
alter table catchmenu_store.inventory_items
  force row level security;

drop policy if exists inventory_items_isolation
  on catchmenu_store.inventory_items;
create policy inventory_items_isolation
  on catchmenu_store.inventory_items
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_inventory_updated
  on catchmenu_store.inventory_items;
create trigger trg_inventory_updated
  before update on catchmenu_store.inventory_items
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_store.inventory_items is
  '식재료/원재료 재고 관리.
   current_qty < min_qty → 부족 알림.
   current_qty = 0 → 소진 알림.
   auto_soldout_enabled:
     연결된 메뉴 자동 품절 처리.
   unit_cost: 단위당 원가.
   avg_cost: 이동평균 원가.';


-- =============================================
-- inventory_transactions table
-- 재고 변동 이력
-- =============================================
create table if not exists
  catchmenu_store.inventory_transactions (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  item_id uuid not null
    references catchmenu_store.inventory_items(id),

  -- 변동 정보
  transaction_type text not null,
  qty_change numeric(12,3) not null,
  qty_before numeric(12,3) not null,
  qty_after numeric(12,3) not null,

  -- 연결
  order_id uuid,
  menu_id uuid,

  -- 원가
  unit_cost int,
  total_cost int,

  -- 비고
  memo text,
  actor_type text default 'SYSTEM',
  actor_id uuid,

  business_day date not null,
  transacted_at timestamptz
    not null default now(),

  constraint chk_tx_type check (
    transaction_type in (
      'PURCHASE',    -- 입고
      'USE',         -- 사용 (주문)
      'WASTE',       -- 폐기
      'ADJUST',      -- 재고 조정
      'RETURN',      -- 반품
      'TRANSFER_IN', -- 이관 입고
      'TRANSFER_OUT' -- 이관 출고
    )
  )
);

create index if not exists idx_inv_tx_item
  on catchmenu_store.inventory_transactions(
    item_id, transacted_at desc
  );
create index if not exists idx_inv_tx_business
  on catchmenu_store.inventory_transactions(
    store_id, business_day desc
  );

alter table
  catchmenu_store.inventory_transactions
  enable row level security;
alter table
  catchmenu_store.inventory_transactions
  force row level security;

drop policy if exists inv_tx_isolation
  on catchmenu_store.inventory_transactions;
create policy inv_tx_isolation
  on catchmenu_store.inventory_transactions
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_store.inventory_transactions is
  '재고 변동 이력.
   append-only 원장.
   PURCHASE: 납품업체 입고.
   USE: 주문 처리 시 차감.
   WASTE: 폐기 처리.
   ADJUST: 실사 후 조정.
   qty_before/after: 변동 전후 수량.
   total_cost: 원가 × 수량.';


-- =============================================
-- menu_inventory_links table
-- 메뉴-재고 연결
-- =============================================
create table if not exists
  catchmenu_store.menu_inventory_links (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  menu_id uuid not null
    references catchmenu_pos.menus(id),
  item_id uuid not null
    references catchmenu_store.inventory_items(id),

  -- 1인분 소모량
  qty_per_serving numeric(10,3) not null,
  is_critical boolean not null default false,

  created_at timestamptz not null default now(),

  constraint uq_menu_item_link unique (
    menu_id, item_id
  )
);

alter table catchmenu_store.menu_inventory_links
  enable row level security;
alter table catchmenu_store.menu_inventory_links
  force row level security;

drop policy if exists menu_inv_link_isolation
  on catchmenu_store.menu_inventory_links;
create policy menu_inv_link_isolation
  on catchmenu_store.menu_inventory_links
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table
  catchmenu_store.menu_inventory_links is
  '메뉴-재고 연결.
   qty_per_serving: 1인분 소모량.
   is_critical: 핵심 재료 여부.
   핵심 재료 소진 시 → 자동 품절 처리.
   원가 계산: 연결 재료 × qty_per_serving 합산.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_store.update_inventory(
  p_tenant_id uuid,
  p_store_id uuid,
  p_item_id uuid,
  p_transaction_type text,
  p_qty_change numeric,
  p_unit_cost int default null,
  p_memo text default null,
  p_order_id uuid default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_pos
as $$
declare
  v_item record;
  v_qty_before numeric;
  v_qty_after numeric;
  v_total_cost int;
  v_business_day date;
  v_was_sufficient boolean;
  v_is_now_low boolean;
  v_is_now_out boolean;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 재고 아이템 조회 + 잠금
  select id, item_name, item_code,
         current_qty, min_qty, unit,
         unit_cost, auto_soldout_enabled
  into v_item
  from catchmenu_store.inventory_items
  where id = p_item_id
    and store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
  for update;

  if v_item.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'inventory_item_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'update_inventory'
    );
  end if;

  v_qty_before := v_item.current_qty;
  v_qty_after := v_qty_before + p_qty_change;
  v_was_sufficient :=
    v_qty_before > v_item.min_qty;

  -- 재고 부족 방지 (USE 타입)
  if p_transaction_type = 'USE'
    and v_qty_after < 0
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'inventory_insufficient',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'item_name', v_item.item_name,
        'current_qty', v_qty_before,
        'required_qty', abs(p_qty_change)
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'update_inventory'
    );
  end if;

  -- 원가 계산
  v_total_cost := (
    coalesce(p_unit_cost, v_item.unit_cost, 0)
    * abs(p_qty_change)
  )::int;

  -- 재고 업데이트
  update catchmenu_store.inventory_items
  set
    current_qty = v_qty_after,
    last_purchase_cost = case
      p_transaction_type
      when 'PURCHASE' then p_unit_cost
      else last_purchase_cost
    end,
    avg_cost = case
      p_transaction_type
      when 'PURCHASE' then
        case when current_qty + p_qty_change > 0
        then (
          (current_qty * coalesce(avg_cost, 0)
           + p_qty_change
             * coalesce(p_unit_cost, unit_cost, 0)
          ) / (current_qty + p_qty_change)
        )::int
        else coalesce(p_unit_cost, avg_cost)
        end
      else avg_cost
    end,
    updated_at = now()
  where id = p_item_id;

  -- 변동 이력 기록
  insert into
    catchmenu_store.inventory_transactions (
    tenant_id, store_id, item_id,
    transaction_type, qty_change,
    qty_before, qty_after,
    unit_cost, total_cost,
    order_id, memo,
    actor_type, actor_id,
    business_day
  ) values (
    p_tenant_id, p_store_id, p_item_id,
    p_transaction_type, p_qty_change,
    v_qty_before, v_qty_after,
    coalesce(p_unit_cost, v_item.unit_cost),
    v_total_cost,
    p_order_id, p_memo,
    case when p_actor_id is null
      then 'SYSTEM' else 'STAFF' end,
    p_actor_id,
    v_business_day
  );

  -- 재고 상태 변화 감지
  v_is_now_low := v_qty_after <= v_item.min_qty
    and v_qty_after > 0;
  v_is_now_out := v_qty_after <= 0;

  -- 부족 알림
  if v_is_now_low and v_was_sufficient then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'STAFF_ALERTS',
      p_event_type := 'inventory_low',
      p_payload := jsonb_build_object(
        'item_id', p_item_id,
        'item_name', v_item.item_name,
        'current_qty', v_qty_after,
        'min_qty', v_item.min_qty,
        'unit', v_item.unit,
        'message',
          catchmenu_common.get_message(
            'inventory_low_alert', p_locale,
            jsonb_build_object(
              'item_name', v_item.item_name,
              'current_qty', v_qty_after,
              'unit', v_item.unit
            )
          )
      )
    );

    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'INVENTORY_LOW',
      p_alert_severity := 'WARNING',
      p_alert_domain := 'INVENTORY',
      p_alert_title_key := 'inventory_low_alert',
      p_alert_detail := jsonb_build_object(
        'item_id', p_item_id,
        'item_name', v_item.item_name,
        'current_qty', v_qty_after,
        'min_qty', v_item.min_qty
      ),
      p_store_id := p_store_id
    );
  end if;

  -- 소진 알림 + 자동 품절
  if v_is_now_out then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_channel_type := 'STAFF_ALERTS',
      p_event_type := 'inventory_out',
      p_payload := jsonb_build_object(
        'item_id', p_item_id,
        'item_name', v_item.item_name,
        'message',
          catchmenu_common.get_message(
            'inventory_out_alert', p_locale,
            jsonb_build_object(
              'item_name', v_item.item_name
            )
          )
      )
    );

    -- 자동 품절 처리
    if v_item.auto_soldout_enabled then
      update catchmenu_pos.menus m
      set
        menu_status = 'SOLD_OUT',
        updated_at = now()
      from catchmenu_store.menu_inventory_links l
      where l.item_id = p_item_id
        and l.menu_id = m.id
        and l.is_critical = true
        and m.menu_status = 'AVAILABLE';

      -- 키오스크/고객 앱 즉시 반영
      perform catchmenu_common.notify_channel(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_channel_type := 'STORE_MODE',
        p_event_type := 'menu_status_changed',
        p_payload := jsonb_build_object(
          'reason', 'INVENTORY_OUT',
          'item_name', v_item.item_name,
          'auto_soldout', true
        )
      );
    end if;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'inventory_updated',
    p_data := jsonb_build_object(
      'item_id', p_item_id,
      'item_name', v_item.item_name,
      'transaction_type', p_transaction_type,
      'qty_change', p_qty_change,
      'qty_before', v_qty_before,
      'qty_after', v_qty_after,
      'unit', v_item.unit,
      'total_cost', v_total_cost,
      'is_low', v_is_now_low,
      'is_out', v_is_now_out,
      'auto_soldout_triggered',
        v_is_now_out
        and v_item.auto_soldout_enabled
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_inventory_dashboard(
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
  v_inventory_list jsonb;
  v_summary jsonb;
  v_low_items jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 전체 재고 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'item_id', id,
        'item_code', item_code,
        'item_name', item_name,
        'item_category', item_category,
        'current_qty', current_qty,
        'min_qty', min_qty,
        'unit', unit,
        'unit_cost', unit_cost,
        'avg_cost', avg_cost,
        'stock_value',
          (current_qty * coalesce(
            avg_cost, unit_cost, 0
          ))::int,
        'status', case
          when current_qty <= 0 then 'OUT'
          when current_qty <= min_qty
            then 'LOW'
          else 'OK'
        end,
        'supplier_name', supplier_name,
        'auto_soldout_enabled',
          auto_soldout_enabled
      )
      order by
        case
          when current_qty <= 0 then 0
          when current_qty <= min_qty then 1
          else 2
        end,
        item_name asc
    ),
    '[]'::jsonb
  )
  into v_inventory_list
  from catchmenu_store.inventory_items
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 요약
  select jsonb_build_object(
    'total_items', count(*),
    'ok_count', count(*) filter (
      where current_qty > min_qty
    ),
    'low_count', count(*) filter (
      where current_qty <= min_qty
        and current_qty > 0
    ),
    'out_count', count(*) filter (
      where current_qty <= 0
    ),
    'total_stock_value', coalesce(
      sum(
        (current_qty
          * coalesce(avg_cost, unit_cost, 0)
        )::int
      ), 0
    ),
    'today_usage_cost', coalesce(
      (
        select sum(total_cost)
        from catchmenu_store.inventory_transactions
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and transaction_type = 'USE'
          and business_day = v_business_day
      ), 0
    )
  )
  into v_summary
  from catchmenu_store.inventory_items
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 부족 아이템 (긴급)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'item_id', id,
        'item_name', item_name,
        'current_qty', current_qty,
        'min_qty', min_qty,
        'unit', unit,
        'status', case
          when current_qty <= 0
            then 'OUT' else 'LOW'
        end,
        'supplier_name', supplier_name
      )
      order by current_qty asc
    ),
    '[]'::jsonb
  )
  into v_low_items
  from catchmenu_store.inventory_items
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true
    and current_qty <= min_qty;

  return catchmenu_common.build_success_response(
    p_message_key := 'inventory_dashboard_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'summary', v_summary,
      'urgent_items', v_low_items,
      'has_urgent',
        jsonb_array_length(v_low_items) > 0,
      'inventory', v_inventory_list,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_cost_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date default null,
  p_to_date date default null,
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
  v_from_date date;
  v_to_date date;
  v_cost_summary jsonb;
  v_menu_cost_list jsonb;
  v_daily_cost jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('month', now())::date
  );
  v_to_date := coalesce(
    p_to_date,
    (timezone('Asia/Seoul', now()))::date
  );

  -- 기간별 원가 요약
  select jsonb_build_object(
    'total_purchase_cost', coalesce(
      sum(total_cost) filter (
        where transaction_type = 'PURCHASE'
      ), 0
    ),
    'total_usage_cost', coalesce(
      sum(total_cost) filter (
        where transaction_type = 'USE'
      ), 0
    ),
    'total_waste_cost', coalesce(
      sum(total_cost) filter (
        where transaction_type = 'WASTE'
      ), 0
    ),
    'total_revenue', (
      select coalesce(sum(final_amount), 0)
      from catchmenu_pos.orders
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and order_status = 'COMPLETED'
        and business_day
          between v_from_date and v_to_date
    ),
    'cost_ratio', case
      when (
        select coalesce(sum(final_amount), 0)
        from catchmenu_pos.orders
        where store_id = p_store_id
          and tenant_id = p_tenant_id
          and order_status = 'COMPLETED'
          and business_day
            between v_from_date and v_to_date
      ) = 0 then null
      else round(
        coalesce(
          sum(total_cost) filter (
            where transaction_type = 'USE'
          ), 0
        )::numeric /
        (
          select sum(final_amount)
          from catchmenu_pos.orders
          where store_id = p_store_id
            and tenant_id = p_tenant_id
            and order_status = 'COMPLETED'
            and business_day
              between v_from_date and v_to_date
        ) * 100, 1
      )
    end
  )
  into v_cost_summary
  from catchmenu_store.inventory_transactions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date;

  -- 메뉴별 원가
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_name', m.menu_name,
        'price', m.price,
        'estimated_cost', coalesce(
          menu_cost.total_cost, 0
        ),
        'cost_ratio', case
          when m.price = 0 then null
          else round(
            coalesce(
              menu_cost.total_cost, 0
            )::numeric / m.price * 100, 1
          )
        end
      )
      order by coalesce(
        menu_cost.total_cost, 0
      ) desc
    ),
    '[]'::jsonb
  )
  into v_menu_cost_list
  from catchmenu_pos.menus m
  left join lateral (
    select sum(
      l.qty_per_serving
      * coalesce(i.avg_cost, i.unit_cost, 0)
    )::int as total_cost
    from catchmenu_store.menu_inventory_links l
    join catchmenu_store.inventory_items i
      on i.id = l.item_id
    where l.menu_id = m.id
  ) menu_cost on true
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true;

  -- 일별 원가 추이
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'business_day', business_day,
        'usage_cost', coalesce(
          sum(total_cost) filter (
            where transaction_type = 'USE'
          ), 0
        ),
        'waste_cost', coalesce(
          sum(total_cost) filter (
            where transaction_type = 'WASTE'
          ), 0
        )
      )
      order by business_day asc
    ),
    '[]'::jsonb
  )
  into v_daily_cost
  from catchmenu_store.inventory_transactions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day
      between v_from_date and v_to_date
  group by business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'cost_report_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'cost_summary', v_cost_summary,
      'menu_cost_list', v_menu_cost_list,
      'daily_cost', v_daily_cost,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- pg_cron: 재고 부족 일일 체크
insert into catchmenu_common.pg_cron_jobs (
  job_code, pg_cron_job_name,
  schedule_cron_utc, schedule_cron_kst,
  sql_command, notes, is_active
) values
(
  'INVENTORY_DAILY_CHECK',
  'catchmenu_inventory_daily_check',
  '30 22 * * *',
  '30 7 * * * (매일 07:30 KST)',
  $sql$
-- 재고 부족 아이템 알림
INSERT INTO catchmenu_common.operation_alerts (
  tenant_id, store_id,
  alert_type, alert_severity, alert_domain,
  alert_title_key, alert_detail, alert_status
)
SELECT
  i.tenant_id, i.store_id,
  'INVENTORY_LOW', 'WARNING', 'INVENTORY',
  'inventory_low_alert',
  jsonb_build_object(
    'item_name', i.item_name,
    'current_qty', i.current_qty,
    'min_qty', i.min_qty,
    'unit', i.unit
  ),
  'OPEN'
FROM catchmenu_store.inventory_items i
WHERE i.is_active = true
  AND i.current_qty <= i.min_qty
  AND NOT EXISTS (
    SELECT 1
    FROM catchmenu_common.operation_alerts oa
    WHERE oa.store_id = i.store_id
      AND oa.alert_type = 'INVENTORY_LOW'
      AND oa.alert_status = 'OPEN'
      AND oa.alert_detail->>'item_name'
        = i.item_name
  );
$sql$,
  '재고 부족 일일 체크. 07:30 KST.',
  true
)
on conflict (job_code) do nothing;


-- grants
do $$
begin
  grant execute on function
    catchmenu_store.update_inventory(
      uuid, uuid, uuid, text, numeric,
      int, text, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_inventory_dashboard(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_cost_report(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.update_inventory(
    uuid, uuid, uuid, text, numeric,
    int, text, uuid, uuid, text
  ) is
  '재고 변동 처리.
   자동화 흐름:
   주문 완료 → USE 트랜잭션 자동 기록
   재고 <= min_qty → LOW 알림 + 운영 알림
   재고 <= 0 → OUT 알림
     + auto_soldout_enabled 시 자동 품절
     + Realtime 키오스크/고객 앱 반영

   이동평균 원가:
   PURCHASE 시 avg_cost 자동 재계산.
   원가 = (기존 재고 × 기존 원가
           + 입고량 × 입고 단가)
          / (기존 + 입고)

   자동 품절 연동:
   is_critical = true 링크된 메뉴만 품절.
   is_critical = false: 대체 재료 있음.';