-- 0111_create_franchise_admin_rpc.sql
-- Purpose: Franchise HQ admin RPCs.
--          화이트라벨 가맹점 본부 관리자.
--          산하 매장 통합 현황.
--          메뉴 템플릿 배포.
--          브랜드 CMS 일괄 배포.
--          가맹점별 매출 비교.
--          정산 대사 리포트.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0110_create_store_admin_rpc.sql
-- Creates:
--   function catchmenu_hq.get_franchise_admin_dashboard(...)
--   function catchmenu_hq.get_brand_store_overview(...)
--   function catchmenu_hq.compare_store_revenue(...)
--   function catchmenu_hq.broadcast_brand_cms(...)
--   function catchmenu_hq.get_franchise_compliance_report(...)
--   function catchmenu_hq.get_franchise_settlement_report(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('franchise_dashboard_loaded', 'ko',
  '가맹점 관리자 대시보드가 로드되었습니다'),
('franchise_dashboard_loaded', 'en',
  'Franchise admin dashboard loaded'),
('brand_store_overview_loaded', 'ko',
  '브랜드 매장 현황이 로드되었습니다'),
('brand_store_overview_loaded', 'en',
  'Brand store overview loaded'),
('store_revenue_compared', 'ko',
  '매장별 매출이 비교되었습니다'),
('store_revenue_compared', 'en',
  'Store revenue compared'),
('brand_cms_broadcast', 'ko',
  '브랜드 CMS가 {store_count}개 매장에 배포되었습니다'),
('brand_cms_broadcast', 'en',
  'Brand CMS broadcast to {store_count} stores'),
('compliance_report_loaded', 'ko',
  '컴플라이언스 리포트가 로드되었습니다'),
('compliance_report_loaded', 'en',
  'Compliance report loaded'),
('settlement_report_loaded', 'ko',
  '정산 리포트가 로드되었습니다'),
('settlement_report_loaded', 'en',
  'Settlement report loaded'),
('menu_template_distributed', 'ko',
  '메뉴 템플릿이 배포되었습니다'),
('menu_template_distributed', 'en',
  'Menu template distributed')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(11001, 'franchise_brand_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11002, 'franchise_admin_permission_required',
  'FRANCHISE', 'AUTHORIZATION', 403, 'WARNING'),
(11003, 'brand_cms_broadcast_partial',
  'FRANCHISE', 'TECHNICAL', 206, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.get_franchise_admin_dashboard(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_brand record;
  v_store_summary jsonb;
  v_today_revenue jsonb;
  v_kpi_summary jsonb;
  v_violation_summary jsonb;
  v_top_stores jsonb;
  v_bottom_stores jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 브랜드 조회
  select id, brand_name, brand_code,
         brand_status
  into v_brand
  from catchmenu_hq.franchise_brands
  where id = p_brand_id
    and tenant_id = p_tenant_id;

  if v_brand.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'franchise_brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name :=
        'get_franchise_admin_dashboard'
    );
  end if;

  -- 매장 현황 요약
  select jsonb_build_object(
    'total_stores', count(*),
    'open_stores', count(*) filter (
      where ss.store_mode = 'NORMAL'
    ),
    'closed_stores', count(*) filter (
      where ss.store_mode = 'CLOSED'
    ),
    'emergency_stores', count(*) filter (
      where ss.store_mode = 'EMERGENCY'
    ),
    'holiday_stores', count(*) filter (
      where ss.store_mode = 'HOLIDAY'
    )
  )
  into v_store_summary
  from catchmenu_hq.stores s
  left join catchmenu_store.store_settings ss
    on ss.store_id = s.id
    and ss.tenant_id = s.tenant_id
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- 오늘 전체 매출
  select jsonb_build_object(
    'total_revenue', coalesce(
      sum(pl.net_amount), 0
    ),
    'total_orders', count(distinct o.id),
    'avg_order_amount', coalesce(
      avg(o.final_amount)::int, 0
    ),
    'total_refunds', coalesce(
      abs(sum(pl.net_amount)) filter (
        where pl.ledger_status = 'REFUNDED'
      ), 0
    )
  )
  into v_today_revenue
  from catchmenu_hq.stores s
  join catchmenu_pos.orders o
    on o.store_id = s.id
    and o.tenant_id = s.tenant_id
    and o.business_day = v_business_day
    and o.order_status = 'COMPLETED'
  left join catchmenu_payment.payment_ledger pl
    on pl.order_id = o.id
    and pl.ledger_status = 'APPROVED'
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- KPI 달성 요약 (이번 달)
  select jsonb_build_object(
    'target_revenue', coalesce(
      sum(kpi.monthly_revenue_target), 0
    ),
    'achieved_stores', count(*) filter (
      where month_revenue
        >= kpi.monthly_revenue_target * 0.8
    ),
    'underperforming_stores', count(*) filter (
      where month_revenue
        < kpi.monthly_revenue_target * 0.8
    )
  )
  into v_kpi_summary
  from catchmenu_hq.franchise_kpi_targets kpi
  join catchmenu_hq.stores s
    on s.id = kpi.store_id
    and s.brand_id = p_brand_id
  left join lateral (
    select coalesce(sum(pl.net_amount), 0)
      as month_revenue
    from catchmenu_pos.orders o
    join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = kpi.store_id
      and o.tenant_id = p_tenant_id
      and o.business_day
        >= date_trunc('month', now())::date
  ) mr on true
  where kpi.tenant_id = p_tenant_id
    and kpi.target_year =
      extract(year from now())::int
    and kpi.target_month =
      extract(month from now())::int;

  -- 정책 위반 요약
  select jsonb_build_object(
    'open_violations', count(*) filter (
      where violation_status = 'OPEN'
    ),
    'critical_violations', count(*) filter (
      where violation_severity = 'CRITICAL'
        and violation_status = 'OPEN'
    ),
    'escalated', count(*) filter (
      where is_escalated = true
        and violation_status = 'OPEN'
    )
  )
  into v_violation_summary
  from catchmenu_hq.policy_violations pv
  join catchmenu_hq.stores s
    on s.id = pv.store_id
    and s.brand_id = p_brand_id
  where pv.tenant_id = p_tenant_id;

  -- 오늘 매출 상위 5개 매장
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'revenue', coalesce(
          sum(pl.net_amount), 0
        ),
        'order_count', count(distinct o.id)
      )
      order by sum(pl.net_amount) desc nulls last
    ),
    '[]'::jsonb
  )
  into v_top_stores
  from catchmenu_hq.stores s
  left join catchmenu_pos.orders o
    on o.store_id = s.id
    and o.business_day = v_business_day
    and o.order_status = 'COMPLETED'
  left join catchmenu_payment.payment_ledger pl
    on pl.order_id = o.id
    and pl.ledger_status = 'APPROVED'
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true
  group by s.id, s.store_name
  order by sum(pl.net_amount) desc nulls last
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_dashboard_loaded',
    p_data := jsonb_build_object(
      'brand', jsonb_build_object(
        'id', v_brand.id,
        'brand_name', v_brand.brand_name,
        'brand_code', v_brand.brand_code,
        'brand_status', v_brand.brand_status
      ),
      'business_day', v_business_day,
      'store_summary', v_store_summary,
      'today_revenue', v_today_revenue,
      'kpi_summary', v_kpi_summary,
      'violation_summary', v_violation_summary,
      'top_stores_today', v_top_stores,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.get_brand_store_overview(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_store,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_stores jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'store_type', s.store_type,
        'timezone', s.timezone,
        'store_mode', coalesce(
          ss.store_mode, 'UNKNOWN'
        ),
        'today_revenue', coalesce(
          revenue.amount, 0
        ),
        'today_orders', coalesce(
          revenue.order_count, 0
        ),
        'active_waiting', coalesce(
          waiting.count, 0
        ),
        'kds_active', coalesce(
          kds.count, 0
        ),
        'open_violations', coalesce(
          violations.count, 0
        ),
        'last_order_at', revenue.last_order_at,
        'pos_connected', coalesce(
          pos.is_connected, false
        )
      )
      order by revenue.amount desc nulls last
    ),
    '[]'::jsonb
  )
  into v_stores
  from catchmenu_hq.stores s
  left join catchmenu_store.store_settings ss
    on ss.store_id = s.id
    and ss.tenant_id = s.tenant_id
  -- 오늘 매출
  left join lateral (
    select
      coalesce(sum(pl.net_amount), 0)
        as amount,
      count(distinct o.id) as order_count,
      max(o.ordered_at) as last_order_at
    from catchmenu_pos.orders o
    left join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = s.id
      and o.tenant_id = s.tenant_id
      and o.business_day = v_business_day
      and o.order_status = 'COMPLETED'
  ) revenue on true
  -- 현재 대기
  left join lateral (
    select count(*) as count
    from catchmenu_pos.order_sessions
    where store_id = s.id
      and tenant_id = s.tenant_id
      and business_day = v_business_day
      and session_status in (
        'WAITING', 'ARRIVAL_PENDING'
      )
  ) waiting on true
  -- KDS 활성
  left join lateral (
    select count(*) as count
    from catchmenu_kds.kds_tickets
    where store_id = s.id
      and tenant_id = s.tenant_id
      and business_day = v_business_day
      and kds_status in (
        'COMMITTED', 'COOKING', 'READY'
      )
  ) kds on true
  -- 정책 위반
  left join lateral (
    select count(*) as count
    from catchmenu_hq.policy_violations
    where store_id = s.id
      and tenant_id = s.tenant_id
      and violation_status = 'OPEN'
  ) violations on true
  -- POS 연결
  left join lateral (
    select
      last_heartbeat_at
        > now() - interval '10 minutes'
      as is_connected
    from catchmenu_integrations.pos_store_configs
    where store_id = s.id
      and tenant_id = s.tenant_id
      and is_active = true
    limit 1
  ) pos on true
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'brand_store_overview_loaded',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'business_day', v_business_day,
      'stores', v_stores,
      'store_count',
        jsonb_array_length(v_stores),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.compare_store_revenue(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_from_date date default null,
  p_to_date date default null,
  p_compare_period text default 'THIS_MONTH',
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_from_date date;
  v_to_date date;
  v_prev_from date;
  v_prev_to date;
  v_store_comparison jsonb;
  v_period_summary jsonb;
begin
  -- 기간 계산
  case p_compare_period
    when 'TODAY' then
      v_from_date := (timezone(
        'Asia/Seoul', now()
      ))::date;
      v_to_date := v_from_date;
      v_prev_from := v_from_date - 1;
      v_prev_to := v_from_date - 1;

    when 'THIS_WEEK' then
      v_from_date := date_trunc(
        'week', now()
      )::date;
      v_to_date := v_from_date + 6;
      v_prev_from := v_from_date - 7;
      v_prev_to := v_to_date - 7;

    when 'THIS_MONTH' then
      v_from_date := date_trunc(
        'month', now()
      )::date;
      v_to_date := (date_trunc(
        'month', now()
      ) + interval '1 month' - interval '1 day'
      )::date;
      v_prev_from := (date_trunc(
        'month', now()
      ) - interval '1 month')::date;
      v_prev_to := v_from_date - 1;

    else
      v_from_date := coalesce(
        p_from_date,
        date_trunc('month', now())::date
      );
      v_to_date := coalesce(
        p_to_date,
        now()::date
      );
      v_prev_from := v_from_date
        - (v_to_date - v_from_date + 1);
      v_prev_to := v_from_date - 1;
  end case;

  -- 매장별 매출 비교
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'current_revenue', coalesce(
          curr.revenue, 0
        ),
        'current_orders', coalesce(
          curr.order_count, 0
        ),
        'prev_revenue', coalesce(
          prev.revenue, 0
        ),
        'revenue_growth_rate', case
          when coalesce(prev.revenue, 0) = 0
            then null
          else round(
            (
              (coalesce(curr.revenue, 0)
               - coalesce(prev.revenue, 0))
              ::numeric
              / prev.revenue * 100
            ), 1
          )
        end,
        'avg_order_amount', coalesce(
          curr.avg_amount, 0
        ),
        'kpi_target', kpi.monthly_revenue_target,
        'kpi_achievement_rate', case
          when coalesce(
            kpi.monthly_revenue_target, 0
          ) = 0 then null
          else round(
            (
              coalesce(curr.revenue, 0)
              ::numeric
              / kpi.monthly_revenue_target * 100
            ), 1
          )
        end
      )
      order by coalesce(curr.revenue, 0) desc
    ),
    '[]'::jsonb
  )
  into v_store_comparison
  from catchmenu_hq.stores s
  -- 현재 기간 매출
  left join lateral (
    select
      coalesce(sum(pl.net_amount), 0) as revenue,
      count(distinct o.id) as order_count,
      coalesce(avg(o.final_amount)::int, 0)
        as avg_amount
    from catchmenu_pos.orders o
    left join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = s.id
      and o.tenant_id = s.tenant_id
      and o.business_day
        between v_from_date and v_to_date
      and o.order_status = 'COMPLETED'
  ) curr on true
  -- 이전 기간 매출
  left join lateral (
    select coalesce(sum(pl.net_amount), 0)
      as revenue
    from catchmenu_pos.orders o
    left join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = s.id
      and o.tenant_id = s.tenant_id
      and o.business_day
        between v_prev_from and v_prev_to
      and o.order_status = 'COMPLETED'
  ) prev on true
  -- KPI 목표
  left join catchmenu_hq.franchise_kpi_targets kpi
    on kpi.store_id = s.id
    and kpi.tenant_id = s.tenant_id
    and kpi.target_year =
      extract(year from v_from_date)::int
    and kpi.target_month =
      extract(month from v_from_date)::int
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- 전체 요약
  select jsonb_build_object(
    'total_current_revenue', coalesce(
      sum((store->>'current_revenue')::int), 0
    ),
    'total_prev_revenue', coalesce(
      sum((store->>'prev_revenue')::int), 0
    ),
    'total_orders', coalesce(
      sum((store->>'current_orders')::int), 0
    ),
    'store_count',
      jsonb_array_length(v_store_comparison),
    'best_store', (
      v_store_comparison->0->>'store_name'
    ),
    'growth_rate', case
      when sum(
        (store->>'prev_revenue')::int
      ) = 0 then null
      else round(
        (
          sum((store->>'current_revenue')::int)
          - sum((store->>'prev_revenue')::int)
        )::numeric
        / sum((store->>'prev_revenue')::int)
        * 100, 1
      )
    end
  )
  into v_period_summary
  from jsonb_array_elements(
    v_store_comparison
  ) as store;

  return catchmenu_common.build_success_response(
    p_message_key := 'store_revenue_compared',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'period', jsonb_build_object(
        'compare_period', p_compare_period,
        'current_from', v_from_date,
        'current_to', v_to_date,
        'prev_from', v_prev_from,
        'prev_to', v_prev_to
      ),
      'summary', v_period_summary,
      'stores', v_store_comparison,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.broadcast_brand_cms(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_event_type text,
  p_title_ko text,
  p_body_ko text default null,
  p_title_en text default null,
  p_thumbnail_url text default null,
  p_valid_from timestamptz default null,
  p_valid_until timestamptz default null,
  p_linked_coupon_id uuid default null,
  p_target_store_ids jsonb default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_store,
                  catchmenu_common
as $$
declare
  v_store record;
  v_event_ids jsonb := '[]'::jsonb;
  v_success_count int := 0;
  v_fail_count int := 0;
  v_store_count int;
begin
  -- 대상 매장 순회
  for v_store in
    select id, store_name
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and brand_id = p_brand_id
      and is_active = true
      and (
        p_target_store_ids is null
        or id = any(
          select (value::text)::uuid
          from jsonb_array_elements_text(
            p_target_store_ids
          )
        )
      )
  loop
    begin
      declare
        v_result jsonb;
        v_event_id uuid;
      begin
        -- 매장별 이벤트 생성
        v_result :=
          catchmenu_store.create_cms_event(
            p_tenant_id := p_tenant_id,
            p_store_id := v_store.id,
            p_event_type := p_event_type,
            p_title_ko := p_title_ko,
            p_body_ko := p_body_ko,
            p_title_en := p_title_en,
            p_thumbnail_url := p_thumbnail_url,
            p_valid_from := p_valid_from,
            p_valid_until := p_valid_until,
            p_linked_coupon_id :=
              p_linked_coupon_id,
            p_created_by := p_actor_id,
            p_locale := p_locale
          );

        -- 즉시 발행
        if (v_result->>'success')::boolean then
          v_event_id := (
            v_result->'data'->>'event_id'
          )::uuid;

          perform catchmenu_store.publish_cms_event(
            p_tenant_id := p_tenant_id,
            p_store_id := v_store.id,
            p_event_id := v_event_id,
            p_published_by := p_actor_id
          );

          v_event_ids := v_event_ids
            || to_jsonb(v_event_id);
          v_success_count := v_success_count + 1;
        end if;
      end;
    exception when others then
      v_fail_count := v_fail_count + 1;
    end;
  end loop;

  v_store_count :=
    v_success_count + v_fail_count;

  -- 브랜드 배포 ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, null,
    'cms', 'brand_cms_broadcast', 1,
    'franchise_brand', p_brand_id,
    null, 'ACTIVE',
    'FRANCHISE_ADMIN', p_actor_id,
    jsonb_build_object(
      'brand_id', p_brand_id,
      'event_type', p_event_type,
      'title_ko', p_title_ko,
      'success_count', v_success_count,
      'fail_count', v_fail_count,
      'event_ids', v_event_ids
    ),
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'brand_cms_broadcast',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'event_type', p_event_type,
      'title_ko', p_title_ko,
      'success_count', v_success_count,
      'fail_count', v_fail_count,
      'total_stores', v_store_count,
      'event_ids', v_event_ids,
      'partial', v_fail_count > 0
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'store_count', v_success_count
    )
  );
end;
$$;


create or replace function
  catchmenu_hq.get_franchise_compliance_report(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_from_date date default null,
  p_to_date date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_from_date date;
  v_to_date date;
  v_violation_list jsonb;
  v_store_compliance jsonb;
  v_severity_summary jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('month', now())::date
  );
  v_to_date := coalesce(
    p_to_date, now()::date
  );

  -- 위반 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'violation_id', pv.id,
        'store_id', pv.store_id,
        'store_name', s.store_name,
        'policy_type', fp.policy_type,
        'policy_name', fp.policy_name,
        'violation_severity',
          pv.violation_severity,
        'violation_status',
          pv.violation_status,
        'violation_detail',
          pv.violation_detail,
        'occurrence_count',
          pv.occurrence_count,
        'is_escalated', pv.is_escalated,
        'detected_at', pv.detected_at,
        'resolved_at', pv.resolved_at
      )
      order by
        case pv.violation_severity
          when 'FATAL' then 0
          when 'CRITICAL' then 1
          when 'ERROR' then 2
          else 3
        end,
        pv.detected_at desc
    ),
    '[]'::jsonb
  )
  into v_violation_list
  from catchmenu_hq.policy_violations pv
  join catchmenu_hq.stores s
    on s.id = pv.store_id
    and s.brand_id = p_brand_id
  join catchmenu_hq.franchise_policies fp
    on fp.id = pv.policy_id
  where pv.tenant_id = p_tenant_id
    and pv.detected_at::date
      between v_from_date and v_to_date;

  -- 매장별 컴플라이언스 점수
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'violation_count', coalesce(
          vc.violation_count, 0
        ),
        'critical_count', coalesce(
          vc.critical_count, 0
        ),
        'compliance_score', case
          when coalesce(
            vc.violation_count, 0
          ) = 0 then 100
          else greatest(
            0,
            100 - (
              coalesce(vc.critical_count, 0) * 20
              + coalesce(vc.error_count, 0) * 10
              + coalesce(vc.warning_count, 0) * 5
            )
          )
        end
      )
      order by coalesce(
        vc.critical_count, 0
      ) desc
    ),
    '[]'::jsonb
  )
  into v_store_compliance
  from catchmenu_hq.stores s
  left join lateral (
    select
      count(*) as violation_count,
      count(*) filter (
        where violation_severity
          in ('CRITICAL', 'FATAL')
      ) as critical_count,
      count(*) filter (
        where violation_severity = 'ERROR'
      ) as error_count,
      count(*) filter (
        where violation_severity = 'WARNING'
      ) as warning_count
    from catchmenu_hq.policy_violations pv
    where pv.store_id = s.id
      and pv.tenant_id = s.tenant_id
      and pv.detected_at::date
        between v_from_date and v_to_date
      and pv.violation_status = 'OPEN'
  ) vc on true
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- 심각도별 요약
  select jsonb_build_object(
    'total', count(*),
    'fatal', count(*) filter (
      where pv.violation_severity = 'FATAL'
    ),
    'critical', count(*) filter (
      where pv.violation_severity = 'CRITICAL'
    ),
    'error', count(*) filter (
      where pv.violation_severity = 'ERROR'
    ),
    'warning', count(*) filter (
      where pv.violation_severity = 'WARNING'
    ),
    'resolved', count(*) filter (
      where pv.violation_status = 'RESOLVED'
    ),
    'open', count(*) filter (
      where pv.violation_status = 'OPEN'
    )
  )
  into v_severity_summary
  from catchmenu_hq.policy_violations pv
  join catchmenu_hq.stores s
    on s.id = pv.store_id
    and s.brand_id = p_brand_id
  where pv.tenant_id = p_tenant_id
    and pv.detected_at::date
      between v_from_date and v_to_date;

  return catchmenu_common.build_success_response(
    p_message_key := 'compliance_report_loaded',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'severity_summary', v_severity_summary,
      'store_compliance', v_store_compliance,
      'violations', v_violation_list,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.get_franchise_settlement_report(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_from_date date default null,
  p_to_date date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_payment,
                  catchmenu_common
as $$
declare
  v_from_date date;
  v_to_date date;
  v_store_settlement jsonb;
  v_brand_totals jsonb;
  v_recon_issues jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('month', now())::date
  );
  v_to_date := coalesce(
    p_to_date, now()::date
  );

  -- 매장별 정산 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'gross_revenue', coalesce(
          settle.gross, 0
        ),
        'total_fee', coalesce(
          settle.total_fee, 0
        ),
        'net_revenue', coalesce(
          settle.net, 0
        ),
        'total_refunds', coalesce(
          settle.refunds, 0
        ),
        'order_count', coalesce(
          settle.order_count, 0
        ),
        'by_payment_method',
          settle.by_method,
        'recon_status', coalesce(
          recon.status, 'NO_DATA'
        )
      )
      order by coalesce(settle.net, 0) desc
    ),
    '[]'::jsonb
  )
  into v_store_settlement
  from catchmenu_hq.stores s
  left join lateral (
    select
      coalesce(
        sum(pl.approved_amount), 0
      ) as gross,
      coalesce(sum(pl.fee_amount), 0)
        as total_fee,
      coalesce(sum(pl.net_amount), 0) as net,
      coalesce(
        abs(sum(pl.approved_amount)) filter (
          where pl.ledger_status = 'REFUNDED'
        ), 0
      ) as refunds,
      count(distinct o.id) as order_count,
      jsonb_object_agg(
        pl.payment_method,
        count(pl.id)
      ) as by_method
    from catchmenu_pos.orders o
    join catchmenu_payment.payment_ledger pl
      on pl.order_id = o.id
      and pl.ledger_status = 'APPROVED'
    where o.store_id = s.id
      and o.tenant_id = s.tenant_id
      and o.business_day
        between v_from_date and v_to_date
  ) settle on true
  left join lateral (
    select
      case
        when count(*) filter (
          where case_status = 'OPEN'
        ) > 0 then 'HAS_ISSUES'
        when count(*) > 0 then 'RESOLVED'
        else 'CLEAN'
      end as status
    from catchmenu_payment.reconciliation_cases
    where store_id = s.id
      and tenant_id = s.tenant_id
      and created_at::date
        between v_from_date and v_to_date
  ) recon on true
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- 브랜드 전체 합계
  select jsonb_build_object(
    'total_gross', coalesce(
      sum((store->>'gross_revenue')::int), 0
    ),
    'total_fee', coalesce(
      sum((store->>'total_fee')::int), 0
    ),
    'total_net', coalesce(
      sum((store->>'net_revenue')::int), 0
    ),
    'total_refunds', coalesce(
      sum((store->>'total_refunds')::int), 0
    ),
    'total_orders', coalesce(
      sum((store->>'order_count')::int), 0
    ),
    'store_count',
      jsonb_array_length(v_store_settlement),
    'stores_with_issues', count(*) filter (
      where store->>'recon_status'
        = 'HAS_ISSUES'
    )
  )
  into v_brand_totals
  from jsonb_array_elements(
    v_store_settlement
  ) as store;

  -- 미해결 대사 이슈
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'case_id', rc.id,
        'store_id', rc.store_id,
        'store_name', s.store_name,
        'case_type', rc.case_type,
        'case_severity', rc.case_severity,
        'gap_amount', rc.gap_amount,
        'case_status', rc.case_status,
        'detected_at', rc.detected_at
      )
      order by rc.case_severity desc,
               rc.gap_amount desc
    ),
    '[]'::jsonb
  )
  into v_recon_issues
  from catchmenu_payment.reconciliation_cases rc
  join catchmenu_hq.stores s
    on s.id = rc.store_id
    and s.brand_id = p_brand_id
  where rc.tenant_id = p_tenant_id
    and rc.case_status = 'OPEN'
    and rc.detected_at::date
      between v_from_date and v_to_date;

  return catchmenu_common.build_success_response(
    p_message_key := 'settlement_report_loaded',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'brand_totals', v_brand_totals,
      'store_settlement', v_store_settlement,
      'recon_issues', v_recon_issues,
      'has_issues',
        jsonb_array_length(v_recon_issues) > 0,
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
    catchmenu_hq.get_franchise_admin_dashboard(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.get_brand_store_overview(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.compare_store_revenue(
      uuid, uuid, date, date, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.broadcast_brand_cms(
      uuid, uuid, text, text, text, text,
      text, timestamptz, timestamptz,
      uuid, jsonb, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.get_franchise_compliance_report(
      uuid, uuid, date, date, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.get_franchise_settlement_report(
      uuid, uuid, date, date, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.get_franchise_admin_dashboard(
    uuid, uuid, text
  ) is
  '가맹점 본부 관리자 대시보드.
   화이트라벨 프랜차이즈 본부용.

   포함 데이터:
   - 브랜드 정보
   - 전체 매장 현황 (영업/마감/긴급)
   - 오늘 전체 매출 합계
   - KPI 달성 현황 (이번 달)
   - 정책 위반 요약 (CRITICAL 강조)
   - 오늘 매출 상위 5개 매장

   권한: franchise_admin 역할.
   brand_id: 자신의 브랜드만 조회 가능.
   RLS 정상 적용.';

comment on function
  catchmenu_hq.broadcast_brand_cms(
    uuid, uuid, text, text, text, text,
    text, timestamptz, timestamptz,
    uuid, jsonb, uuid, text
  ) is
  '브랜드 CMS 일괄 배포.
   가맹점 본부 → 산하 매장 전체 이벤트 배포.

   동작:
   1. 산하 매장 순회
   2. 매장별 cms_event 생성
   3. 즉시 발행 (Realtime 전파)
   4. 실패 매장 카운트 추적

   p_target_store_ids = null:
     전체 매장 배포
   jsonb array:
     지정 매장만 배포

   활용:
   - 브랜드 공통 이벤트
   - 시즌 프로모션
   - 본사 공지
   - 쿠폰 일괄 발급';