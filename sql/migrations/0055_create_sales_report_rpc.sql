-- 0055_create_sales_report_rpc.sql
-- Purpose: Sales reporting and food cost analysis RPCs.
--          get_sales_report: revenue breakdown by period/channel/menu.
--          get_food_cost_report: ingredient usage vs revenue analysis.
--          get_menu_performance: per-menu sales KPI.
--          특허3: 매출/원가 데이터 → AI Agent 메뉴 최적화 추천.
-- Depends on: 0054_create_inventory_rpc.sql
-- Creates:
--   function catchmenu_pos.get_sales_report(...)
--   function catchmenu_store.get_food_cost_report(...)
--   function catchmenu_pos.get_menu_performance(...)

create or replace function catchmenu_pos.get_sales_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date,
  p_to_date date,
  p_group_by text default 'DAY'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_payment,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_store record;
  v_timezone text;
  v_period_summary jsonb;
  v_channel_summary jsonb;
  v_hourly_summary jsonb;
  v_total_revenue int;
  v_total_orders int;
  v_total_cancelled int;
begin
  if p_from_date > p_to_date then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_date_range'
    );
  end if;

  if p_to_date - p_from_date > 92 then
    return jsonb_build_object(
      'success', false,
      'error_key', 'date_range_too_wide',
      'max_days', 92
    );
  end if;

  if p_group_by not in ('DAY', 'WEEK', 'MONTH', 'HOUR') then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_group_by',
      'allowed', array['DAY', 'WEEK', 'MONTH', 'HOUR']
    );
  end if;

  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  v_timezone := v_store.timezone;

  -- overall totals
  select
    coalesce(sum(final_amount) filter (
      where order_status = 'COMPLETED'
    ), 0),
    count(*) filter (
      where order_status = 'COMPLETED'
    ),
    count(*) filter (
      where order_status = 'CANCELLED'
    )
  into v_total_revenue, v_total_orders, v_total_cancelled
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day between p_from_date and p_to_date;

  -- period breakdown
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'period', period_label,
        'order_count', order_count,
        'revenue', revenue,
        'avg_order_amount', avg_order_amount,
        'cancelled_count', cancelled_count,
        'cancellation_rate', case order_count + cancelled_count
          when 0 then 0
          else (
            cancelled_count::numeric
            / (order_count + cancelled_count) * 100
          )::numeric(5,1)
        end
      )
      order by period_label
    ),
    '[]'::jsonb
  )
  into v_period_summary
  from (
    select
      case p_group_by
        when 'DAY' then business_day::text
        when 'WEEK' then
          to_char(business_day, 'IYYY-IW')
        when 'MONTH' then
          to_char(business_day, 'YYYY-MM')
        when 'HOUR' then
          to_char(
            timezone(
              v_timezone,
              ordered_at
            ),
            'HH24:00'
          )
      end as period_label,
      count(*) filter (
        where order_status = 'COMPLETED'
      ) as order_count,
      coalesce(sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0) as revenue,
      coalesce(avg(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0)::int as avg_order_amount,
      count(*) filter (
        where order_status = 'CANCELLED'
      ) as cancelled_count
    from catchmenu_pos.orders
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day between p_from_date and p_to_date
    group by period_label
  ) period_data;

  -- channel breakdown
  select coalesce(
    jsonb_object_agg(
      coalesce(order_channel, 'UNKNOWN'),
      jsonb_build_object(
        'order_count', order_count,
        'revenue', revenue,
        'avg_order_amount', avg_order_amount,
        'revenue_share_pct', case v_total_revenue
          when 0 then 0
          else (
            revenue::numeric / v_total_revenue * 100
          )::numeric(5,1)
        end
      )
    ),
    '{}'::jsonb
  )
  into v_channel_summary
  from (
    select
      order_channel,
      count(*) filter (
        where order_status = 'COMPLETED'
      ) as order_count,
      coalesce(sum(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0) as revenue,
      coalesce(avg(final_amount) filter (
        where order_status = 'COMPLETED'
      ), 0)::int as avg_order_amount
    from catchmenu_pos.orders
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and business_day between p_from_date and p_to_date
      and order_status = 'COMPLETED'
    group by order_channel
  ) channel_data;

  -- payment method breakdown
  -- joins with payment_ledger
  with payment_breakdown as (
    select
      pl.provider_type,
      count(*) as tx_count,
      coalesce(sum(pl.net_amount), 0) as net_amount
    from catchmenu_payment.payment_ledger pl
    where pl.store_id = p_store_id
      and pl.tenant_id = p_tenant_id
      and pl.business_day between p_from_date and p_to_date
      and pl.ledger_status = 'APPROVED'
    group by pl.provider_type
  )
  select coalesce(
    jsonb_object_agg(
      coalesce(provider_type, 'UNKNOWN'),
      jsonb_build_object(
        'transaction_count', tx_count,
        'net_amount', net_amount
      )
    ),
    '{}'::jsonb
  )
  into v_hourly_summary
  from payment_breakdown;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'period', jsonb_build_object(
      'from_date', p_from_date,
      'to_date', p_to_date,
      'group_by', p_group_by
    ),
    'totals', jsonb_build_object(
      'total_revenue', v_total_revenue,
      'total_orders', v_total_orders,
      'total_cancelled', v_total_cancelled,
      'avg_daily_revenue', case
        p_to_date - p_from_date + 1
        when 0 then 0
        else (
          v_total_revenue
          / (p_to_date - p_from_date + 1)
        )
      end,
      'currency', 'KRW'
    ),
    'period_breakdown', v_period_summary,
    'channel_breakdown', v_channel_summary,
    'payment_breakdown', v_hourly_summary,
    'generated_at', now(),
    'message_code', 'sales_report_loaded'
  );
end;
$$;


create or replace function catchmenu_store.get_food_cost_report(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date,
  p_to_date date
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store, catchmenu_pos,
                  catchmenu_common, catchmenu_hq
as $$
declare
  v_timezone text;
  v_total_revenue int;
  v_total_cost numeric;
  v_ingredient_usage jsonb;
  v_waste_summary jsonb;
  v_food_cost_rate numeric;
begin
  if p_from_date > p_to_date then
    return jsonb_build_object(
      'success', false,
      'error_key', 'invalid_date_range'
    );
  end if;

  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  -- total revenue for period
  select coalesce(sum(final_amount), 0)
  into v_total_revenue
  from catchmenu_pos.orders
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and order_status = 'COMPLETED'
    and business_day between p_from_date and p_to_date;

  -- ingredient usage (USAGE movements)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ingredient_id', i.id,
        'ingredient_code', i.ingredient_code,
        'ingredient_name', i.ingredient_name,
        'unit', i.unit,
        'total_used', coalesce(
          abs(sum(m.quantity_change)), 0
        ),
        'total_cost', coalesce(
          sum(abs(m.quantity_change) * m.unit_cost), 0
        ),
        'avg_daily_usage', coalesce(
          abs(sum(m.quantity_change))
          / (p_to_date - p_from_date + 1),
          0
        )::numeric(10,3),
        'current_quantity', i.current_quantity,
        'ingredient_status', i.ingredient_status
      )
      order by
        coalesce(
          sum(abs(m.quantity_change) * m.unit_cost), 0
        ) desc nulls last
    ),
    '[]'::jsonb
  )
  into v_ingredient_usage
  from catchmenu_store.ingredients i
  left join catchmenu_store.inventory_movements m
    on m.ingredient_id = i.id
    and m.movement_type = 'USAGE'
    and m.business_day between p_from_date and p_to_date
  where i.store_id = p_store_id
    and i.tenant_id = p_tenant_id
    and i.is_active = true
  group by i.id, i.ingredient_code, i.ingredient_name,
           i.unit, i.current_quantity, i.ingredient_status;

  -- waste summary
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'ingredient_code', i.ingredient_code,
        'ingredient_name', i.ingredient_name,
        'total_wasted', coalesce(
          abs(sum(m.quantity_change)), 0
        ),
        'waste_cost', coalesce(
          sum(abs(m.quantity_change) * m.unit_cost), 0
        )
      )
      order by coalesce(
        sum(abs(m.quantity_change) * m.unit_cost), 0
      ) desc
    ),
    '[]'::jsonb
  )
  into v_waste_summary
  from catchmenu_store.inventory_movements m
  join catchmenu_store.ingredients i
    on i.id = m.ingredient_id
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.movement_type = 'WASTE'
    and m.business_day between p_from_date and p_to_date
  group by i.ingredient_code, i.ingredient_name;

  -- total food cost
  select coalesce(
    sum(abs(m.quantity_change) * m.unit_cost), 0
  )
  into v_total_cost
  from catchmenu_store.inventory_movements m
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.movement_type in ('USAGE', 'WASTE')
    and m.unit_cost is not null
    and m.business_day between p_from_date and p_to_date;

  -- food cost rate
  v_food_cost_rate := case v_total_revenue
    when 0 then 0
    else (v_total_cost / v_total_revenue * 100)
      ::numeric(5,1)
  end;

  return jsonb_build_object(
    'success', true,
    'store_id', p_store_id,
    'period', jsonb_build_object(
      'from_date', p_from_date,
      'to_date', p_to_date,
      'days', p_to_date - p_from_date + 1
    ),
    'summary', jsonb_build_object(
      'total_revenue', v_total_revenue,
      'total_food_cost', v_total_cost,
      'food_cost_rate_pct', v_food_cost_rate,
      'target_food_cost_rate_pct', 30,
      'above_target', v_food_cost_rate > 30,
      'currency', 'KRW'
    ),
    'ingredient_usage', v_ingredient_usage,
    'waste_summary', v_waste_summary,
    'generated_at', now(),
    'message_code', 'food_cost_report_loaded'
  );
end;
$$;


create or replace function catchmenu_pos.get_menu_performance(
  p_tenant_id uuid,
  p_store_id uuid,
  p_from_date date,
  p_to_date date,
  p_category_id uuid default null,
  p_limit int default 20
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_menu_stats jsonb;
  v_top_menus jsonb;
  v_slow_menus jsonb;
begin
  select id, store_name
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  if v_store.id is null then
    return jsonb_build_object(
      'success', false,
      'error_key', 'store_not_found'
    );
  end if;

  if p_limit > 50 then
    p_limit := 50;
  end if;

  -- per-menu performance
  with menu_sales as (
    select
      m.id as menu_id,
      m.menu_code,
      m.menu_name,
      m.category_id,
      mc.category_name,
      m.price,
      m.menu_status,
      m.estimated_minutes,
      count(oi.id) as order_count,
      coalesce(sum(oi.quantity), 0) as total_qty,
      coalesce(sum(oi.item_amount), 0) as total_revenue,
      coalesce(avg(oi.item_amount / nullif(
        oi.quantity, 0
      )), 0)::int as avg_unit_price
    from catchmenu_pos.menus m
    left join catchmenu_pos.menu_categories mc
      on mc.id = m.category_id
    left join catchmenu_pos.order_items oi
      on oi.menu_id = m.id
    left join catchmenu_pos.orders o
      on o.id = oi.order_id
      and o.order_status = 'COMPLETED'
      and o.business_day between p_from_date and p_to_date
    where m.store_id = p_store_id
      and m.tenant_id = p_tenant_id
      and m.is_active = true
      and m.menu_status <> 'DISCONTINUED'
      and (
        p_category_id is null
        or m.category_id = p_category_id
      )
    group by m.id, m.menu_code, m.menu_name,
             m.category_id, mc.category_name,
             m.price, m.menu_status, m.estimated_minutes
  ),
  total_revenue_cte as (
    select coalesce(sum(total_revenue), 1)
      as grand_total
    from menu_sales
  )
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', ms.menu_id,
        'menu_code', ms.menu_code,
        'menu_name', ms.menu_name,
        'category_name', ms.category_name,
        'price', ms.price,
        'menu_status', ms.menu_status,
        'order_count', ms.order_count,
        'total_qty', ms.total_qty,
        'total_revenue', ms.total_revenue,
        'avg_unit_price', ms.avg_unit_price,
        'revenue_share_pct', (
          ms.total_revenue::numeric
          / t.grand_total * 100
        )::numeric(5,1),
        'daily_avg_qty', (
          ms.total_qty::numeric
          / (p_to_date - p_from_date + 1)
        )::numeric(8,2)
      )
      order by ms.total_revenue desc
    ),
    '[]'::jsonb
  )
  into v_menu_stats
  from menu_sales ms
  cross join total_revenue_cte t;

  -- top performers
  select coalesce(
    jsonb_agg(elem order by (elem->>'total_revenue')::int desc),
    '[]'::jsonb
  )
  into v_top_menus
  from jsonb_array_elements(v_menu_stats) elem
  limit p_limit;

  -- slow movers (ordered but low revenue)
  select coalesce(
    jsonb_agg(elem order by (elem->>'total_revenue')::int asc),
    '[]'::jsonb
  )
  into v_slow_menus
  from jsonb_array_elements(v_menu_stats) elem
  where (elem->>'order_count')::int > 0
  limit 10;

  return jsonb_build_object(
    'success', true,
    'store', jsonb_build_object(
      'id', v_store.id,
      'store_name', v_store.store_name
    ),
    'period', jsonb_build_object(
      'from_date', p_from_date,
      'to_date', p_to_date,
      'days', p_to_date - p_from_date + 1
    ),
    'category_filter', p_category_id,
    'total_menu_count', jsonb_array_length(v_menu_stats),
    'top_menus', v_top_menus,
    'slow_movers', v_slow_menus,
    'all_menus', v_menu_stats,
    'generated_at', now(),
    'message_code', 'menu_performance_loaded'
  );
end;
$$;

-- grants
do $$
begin
  revoke all on function catchmenu_pos.get_sales_report(
    uuid, uuid, date, date, text
  ) from public;
  grant execute on function catchmenu_pos.get_sales_report(
    uuid, uuid, date, date, text
  ) to authenticated;

  revoke all on function catchmenu_store.get_food_cost_report(
    uuid, uuid, date, date
  ) from public;
  grant execute on function catchmenu_store.get_food_cost_report(
    uuid, uuid, date, date
  ) to authenticated;

  revoke all on function catchmenu_pos.get_menu_performance(
    uuid, uuid, date, date, uuid, int
  ) from public;
  grant execute on function catchmenu_pos.get_menu_performance(
    uuid, uuid, date, date, uuid, int
  ) to authenticated;
end;
$$;

comment on function catchmenu_pos.get_sales_report(
  uuid, uuid, date, date, text
) is
  'Revenue report by period, channel, and payment method.
   Supports DAY/WEEK/MONTH/HOUR grouping.
   Max date range 92 days per query.
   특허3: 매출 데이터 → AI Agent 매출 패턴 분석 → SOP 개선 추천.
   피크타임/채널별 수익 분석 → 운영 전략 최적화.';

comment on function catchmenu_store.get_food_cost_report(
  uuid, uuid, date, date
) is
  'Food cost analysis: ingredient usage vs revenue.
   Calculates food_cost_rate_pct vs 30% target.
   Shows waste by ingredient for loss control.
   특허3: 원가율 이상 탐지 → Knowledge Gap → SOP 개선.
   food_cost_rate > 30% 지속 시 Agent가 메뉴 가격/원가 조정 추천.';

comment on function catchmenu_pos.get_menu_performance(
  uuid, uuid, date, date, uuid, int
) is
  'Per-menu sales KPI: revenue, qty, daily avg, revenue share.
   Returns top performers and slow movers.
   특허3: 메뉴 성과 데이터 → AI Agent 메뉴 최적화 추천.
   slow_movers + low revenue_share → 메뉴 정리 추천 대상.
   top_menus + 재고 소진 빈도 높음 → 발주량 증가 추천.';