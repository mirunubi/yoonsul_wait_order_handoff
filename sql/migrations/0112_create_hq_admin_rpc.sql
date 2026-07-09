-- 0112_create_hq_admin_rpc.sql
-- Purpose: HQ admin RPCs for SaaS operator.
--          캐치메뉴 SaaS 운영자 관리자 페이지.
--          전체 테넌트 관리.
--          구독 청구 관리.
--          테넌트 온보딩.
--          전체 운영 모니터링.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0111_create_franchise_admin_rpc.sql
-- Creates:
--   function catchmenu_common.get_hq_dashboard(...)
--   function catchmenu_common.get_tenant_list(...)
--   function catchmenu_common.onboard_tenant(...)
--   function catchmenu_common.manage_subscription(...)
--   function catchmenu_common.get_saas_revenue_report(...)
--   function catchmenu_common.get_system_health_all(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('hq_dashboard_loaded', 'ko',
  'HQ 대시보드가 로드되었습니다'),
('hq_dashboard_loaded', 'en',
  'HQ dashboard loaded'),
('tenant_list_loaded', 'ko',
  '테넌트 목록이 로드되었습니다'),
('tenant_list_loaded', 'en',
  'Tenant list loaded'),
('tenant_onboarded', 'ko',
  '테넌트 온보딩이 완료되었습니다'),
('tenant_onboarded', 'en',
  'Tenant onboarded'),
('subscription_managed', 'ko',
  '구독이 관리되었습니다'),
('subscription_managed', 'en',
  'Subscription managed'),
('saas_revenue_loaded', 'ko',
  'SaaS 매출 리포트가 로드되었습니다'),
('saas_revenue_loaded', 'en',
  'SaaS revenue report loaded'),
('system_health_loaded', 'ko',
  '전체 시스템 헬스가 로드되었습니다'),
('system_health_loaded', 'en',
  'System health loaded'),
('tenant_suspended_msg', 'ko',
  '테넌트가 정지되었습니다'),
('tenant_suspended_msg', 'en',
  'Tenant suspended'),
('tenant_activated', 'ko',
  '테넌트가 활성화되었습니다'),
('tenant_activated', 'en',
  'Tenant activated')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(3040, 'hq_admin_permission_required',
  'SYSTEM', 'PERMISSION', 403, 'ERROR'),
(3041, 'tenant_already_exists',
  'SYSTEM', 'CONFLICT', 409, 'WARNING'),
(3042, 'subscription_not_found',
  'SYSTEM', 'NOT_FOUND', 404, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_common.get_hq_dashboard(
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_tenant_summary jsonb;
  v_revenue_summary jsonb;
  v_plan_breakdown jsonb;
  v_health_summary jsonb;
  v_recent_onboarding jsonb;
  v_alert_summary jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 테넌트 현황
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where tenant_status = 'ACTIVE'
    ),
    'trial', count(*) filter (
      where tenant_status = 'TRIAL'
    ),
    'suspended', count(*) filter (
      where tenant_status = 'SUSPENDED'
    ),
    'new_this_month', count(*) filter (
      where created_at
        >= date_trunc('month', now())
    )
  )
  into v_tenant_summary
  from catchmenu_hq.tenants;

  -- SaaS 구독 매출 (이번 달)
  select jsonb_build_object(
    'monthly_revenue', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'PAID'
          and billing_period_start
            >= date_trunc('month', now())
      ), 0
    ),
    'pending_revenue', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'PENDING'
      ), 0
    ),
    'overdue_count', count(*) filter (
      where invoice_status = 'OVERDUE'
    ),
    'total_arr', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'PAID'
          and billing_period_start
            >= date_trunc('year', now())
      ), 0
    )
  )
  into v_revenue_summary
  from catchmenu_common.subscription_invoices;

  -- 플랜별 분포
  select coalesce(
    jsonb_object_agg(
      plan_tier, cnt
    ),
    '{}'::jsonb
  )
  into v_plan_breakdown
  from (
    select tpc.plan_tier,
           count(*)::int as cnt
    from catchmenu_common.tenant_plan_configs tpc
    join catchmenu_hq.tenants t
      on t.id = tpc.tenant_id
      and t.tenant_status = 'ACTIVE'
    group by tpc.plan_tier
  ) p;

  -- 전체 시스템 알림 요약
  select jsonb_build_object(
    'total_open', count(*) filter (
      where alert_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    'critical', count(*) filter (
      where alert_severity in (
        'CRITICAL', 'FATAL'
      )
      and alert_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    'pgcron_failed_today', count(*) filter (
      where alert_type = 'PGCRON_FAILED'
        and created_at::date = v_business_day
    )
  )
  into v_alert_summary
  from catchmenu_common.operation_alerts;

  -- 최근 온보딩 테넌트 (5개)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'tenant_id', t.id,
        'company_name', t.company_name,
        'plan_tier', tpc.plan_tier,
        'tenant_status', t.tenant_status,
        'created_at', t.created_at
      )
      order by t.created_at desc
    ),
    '[]'::jsonb
  )
  into v_recent_onboarding
  from catchmenu_hq.tenants t
  left join catchmenu_common.tenant_plan_configs
    tpc on tpc.tenant_id = t.id
  limit 5;

  return catchmenu_common.build_success_response(
    p_message_key := 'hq_dashboard_loaded',
    p_data := jsonb_build_object(
      'business_day', v_business_day,
      'tenant_summary', v_tenant_summary,
      'revenue_summary', v_revenue_summary,
      'plan_breakdown', v_plan_breakdown,
      'alert_summary', v_alert_summary,
      'recent_onboarding', v_recent_onboarding,
      'quick_actions', jsonb_build_array(
        jsonb_build_object(
          'action', 'onboard_tenant',
          'label', '신규 테넌트 온보딩',
          'rpc', 'onboard_tenant'
        ),
        jsonb_build_object(
          'action', 'check_system_health',
          'label', '시스템 헬스 확인',
          'rpc', 'get_system_health_all'
        ),
        jsonb_build_object(
          'action', 'saas_checklist',
          'label', 'SaaS 출시 체크리스트',
          'rpc', 'run_saas_launch_checklist'
        ),
        jsonb_build_object(
          'action', 'view_alerts',
          'label', '전체 운영 알림',
          'rpc', 'get_operation_dashboard'
        )
      ),
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_tenant_list(
  p_tenant_status text default null,
  p_plan_tier text default null,
  p_search_keyword text default null,
  p_limit int default 50,
  p_offset int default 0,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_tenants jsonb;
  v_total_count int;
begin
  select count(*) into v_total_count
  from catchmenu_hq.tenants t
  left join catchmenu_common.tenant_plan_configs
    tpc on tpc.tenant_id = t.id
  where (
    p_tenant_status is null
    or t.tenant_status = p_tenant_status
  )
  and (
    p_plan_tier is null
    or tpc.plan_tier = p_plan_tier
  )
  and (
    p_search_keyword is null
    or t.company_name ilike
      '%' || p_search_keyword || '%'
  );

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'tenant_id', t.id,
        'company_name', t.company_name,
        'business_number', t.business_number,
        'ceo_name', t.ceo_name,
        'tenant_status', t.tenant_status,
        'plan_tier', tpc.plan_tier,
        'plan_status', tpc.plan_status,
        'store_count', (
          select count(*)
          from catchmenu_hq.stores s
          where s.tenant_id = t.id
            and s.is_active = true
        ),
        'monthly_invoice', (
          select coalesce(
            sum(invoice_amount), 0
          )
          from catchmenu_common
            .subscription_invoices si
          where si.tenant_id = t.id
            and si.invoice_status = 'PAID'
            and si.billing_period_start
              >= date_trunc('month', now())
        ),
        'last_active_at', (
          select max(last_active_at)
          from catchmenu_common.auth_sessions
          where tenant_id = t.id
            and session_status = 'ACTIVE'
        ),
        'created_at', t.created_at,
        'has_alerts', exists (
          select 1
          from catchmenu_common.operation_alerts
          where tenant_id = t.id
            and alert_severity in (
              'CRITICAL', 'FATAL'
            )
            and alert_status = 'OPEN'
        )
      )
      order by t.created_at desc
    ),
    '[]'::jsonb
  )
  into v_tenants
  from catchmenu_hq.tenants t
  left join catchmenu_common.tenant_plan_configs
    tpc on tpc.tenant_id = t.id
  where (
    p_tenant_status is null
    or t.tenant_status = p_tenant_status
  )
  and (
    p_plan_tier is null
    or tpc.plan_tier = p_plan_tier
  )
  and (
    p_search_keyword is null
    or t.company_name ilike
      '%' || p_search_keyword || '%'
  )
  limit p_limit
  offset p_offset;

  return catchmenu_common.build_success_response(
    p_message_key := 'tenant_list_loaded',
    p_data := jsonb_build_object(
      'tenants', v_tenants,
      'total_count', v_total_count,
      'page_count',
        jsonb_array_length(v_tenants),
      'limit', p_limit,
      'offset', p_offset,
      'filters', jsonb_build_object(
        'tenant_status', p_tenant_status,
        'plan_tier', p_plan_tier,
        'search', p_search_keyword
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.onboard_tenant(
  p_company_name text,
  p_business_number text,
  p_ceo_name text,
  p_ceo_phone_hash text,
  p_plan_tier text default 'TRIAL_30',
  p_store_name text default null,
  p_store_timezone text default 'Asia/Seoul',
  p_brand_name text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_store
as $$
declare
  v_tenant_id uuid;
  v_store_id uuid;
  v_brand_id uuid;
  v_result jsonb;
begin
  -- 사업자번호 중복 확인
  if exists (
    select 1
    from catchmenu_hq.tenants
    where business_number = p_business_number
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'tenant_already_exists',
      p_locale := p_locale,
      p_rpc_name := 'onboard_tenant'
    );
  end if;

  -- 테넌트 생성 (기존 provision_tenant 활용)
  v_result := catchmenu_common.provision_tenant(
    p_company_name := p_company_name,
    p_business_number := p_business_number,
    p_ceo_name := p_ceo_name,
    p_ceo_phone_hash := p_ceo_phone_hash,
    p_plan_tier := p_plan_tier,
    p_store_name := coalesce(
      p_store_name, p_company_name || ' 1호점'
    ),
    p_store_timezone := p_store_timezone,
    p_locale := p_locale
  );

  if not (v_result->>'success')::boolean then
    return v_result;
  end if;

  v_tenant_id := (
    v_result->'data'->>'tenant_id'
  )::uuid;
  v_store_id := (
    v_result->'data'->>'store_id'
  )::uuid;

  -- 브랜드 생성 (요청 시)
  if p_brand_name is not null then
    v_result :=
      catchmenu_hq.create_franchise_brand(
        p_tenant_id := v_tenant_id,
        p_brand_name := p_brand_name,
        p_brand_code := regexp_replace(
          upper(p_brand_name), '\s+', '_', 'g'
        ),
        p_locale := p_locale
      );

    if (v_result->>'success')::boolean then
      v_brand_id := (
        v_result->'data'->>'brand_id'
      )::uuid;

      -- 브랜드에 매장 연결
      update catchmenu_hq.stores
      set brand_id = v_brand_id
      where id = v_store_id;
    end if;
  end if;

  -- 온보딩 진단 로그
  perform catchmenu_common.log_diagnostic(
    p_tenant_id := v_tenant_id,
    p_store_id := v_store_id,
    p_log_level := 'INFO',
    p_log_domain := 'SYSTEM',
    p_log_event := 'tenant_onboarded',
    p_message :=
      '신규 테넌트 온보딩 완료: '
      || p_company_name,
    p_rpc_name := 'onboard_tenant',
    p_details := jsonb_build_object(
      'tenant_id', v_tenant_id,
      'store_id', v_store_id,
      'brand_id', v_brand_id,
      'plan_tier', p_plan_tier,
      'has_brand', p_brand_name is not null
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'tenant_onboarded',
    p_data := jsonb_build_object(
      'tenant_id', v_tenant_id,
      'store_id', v_store_id,
      'brand_id', v_brand_id,
      'company_name', p_company_name,
      'plan_tier', p_plan_tier,
      'has_brand', p_brand_name is not null,
      'next_steps', jsonb_build_array(
        '1. 매장 설정: update_store_settings()',
        '2. 메뉴 등록: upsert_menu()',
        '3. 직원 등록: upsert_staff()',
        '4. POS 연동: setup_pos_integration()',
        '5. 영업시간: set_store_hours()',
        '6. 테스트 주문 실행'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.manage_subscription(
  p_tenant_id uuid,
  p_action text,
  p_plan_tier text default null,
  p_reason text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_common,
                  catchmenu_hq,
                  catchmenu_ledger
as $$
declare
  v_tenant record;
  v_plan record;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 테넌트 조회
  select id, company_name, tenant_status
  into v_tenant
  from catchmenu_hq.tenants
  where id = p_tenant_id;

  if v_tenant.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'tenant_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'manage_subscription'
    );
  end if;

  -- 액션별 처리
  case p_action
    when 'UPGRADE', 'DOWNGRADE',
         'CHANGE_PLAN' then
      if p_plan_tier is null then
        return catchmenu_common.build_error_response(
          p_error_key := 'invalid_input',
          p_locale := p_locale,
          p_params := jsonb_build_object(
            'field', 'plan_tier'
          ),
          p_tenant_id := p_tenant_id,
          p_rpc_name := 'manage_subscription'
        );
      end if;

      -- 플랜 변경
      update catchmenu_common.tenant_plan_configs
      set
        plan_tier = p_plan_tier,
        plan_status = 'ACTIVE',
        plan_started_at = now(),
        updated_at = now()
      where tenant_id = p_tenant_id;

      -- 구독 인보이스 생성
      insert into
        catchmenu_common.subscription_invoices (
        tenant_id, plan_tier,
        invoice_amount,
        billing_period_start,
        billing_period_end,
        invoice_status
      )
      select
        p_tenant_id, p_plan_tier,
        sp.monthly_price_krw,
        date_trunc('month', now())::date,
        (date_trunc('month', now())
          + interval '1 month'
          - interval '1 day')::date,
        'PENDING'
      from catchmenu_common.subscription_plans sp
      where sp.plan_code = p_plan_tier;

    when 'SUSPEND' then
      update catchmenu_hq.tenants
      set
        tenant_status = 'SUSPENDED',
        updated_at = now()
      where id = p_tenant_id;

      -- 테넌트 격리
      perform catchmenu_common.isolate_tenant(
        p_tenant_id := p_tenant_id,
        p_isolate := true,
        p_reason := coalesce(
          p_reason, '구독 정지'
        )
      );

    when 'ACTIVATE' then
      update catchmenu_hq.tenants
      set
        tenant_status = 'ACTIVE',
        updated_at = now()
      where id = p_tenant_id;

      -- 격리 해제
      perform catchmenu_common.isolate_tenant(
        p_tenant_id := p_tenant_id,
        p_isolate := false,
        p_reason := '구독 복구'
      );

    when 'CANCEL' then
      update catchmenu_hq.tenants
      set
        tenant_status = 'CANCELLED',
        updated_at = now()
      where id = p_tenant_id;

      update catchmenu_common.tenant_plan_configs
      set
        plan_status = 'CANCELLED',
        plan_ended_at = now(),
        updated_at = now()
      where tenant_id = p_tenant_id;

    else
      return catchmenu_common.build_error_response(
        p_error_key := 'invalid_input',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'field', 'action',
          'value', p_action,
          'allowed',
            'UPGRADE/DOWNGRADE/SUSPEND/'
            || 'ACTIVATE/CANCEL'
        ),
        p_tenant_id := p_tenant_id,
        p_rpc_name := 'manage_subscription'
      );
  end case;

  -- ledger event
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
    'saas', 'subscription_managed', 1,
    'tenant', p_tenant_id,
    v_tenant.tenant_status,
    case p_action
      when 'SUSPEND' then 'SUSPENDED'
      when 'ACTIVATE' then 'ACTIVE'
      when 'CANCEL' then 'CANCELLED'
      else v_tenant.tenant_status
    end,
    'HQ_ADMIN', p_actor_id,
    jsonb_build_object(
      'action', p_action,
      'plan_tier', p_plan_tier,
      'reason', p_reason,
      'company_name', v_tenant.company_name
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := case p_action
      when 'SUSPEND' then 'tenant_suspended_msg'
      when 'ACTIVATE' then 'tenant_activated'
      else 'subscription_managed'
    end,
    p_data := jsonb_build_object(
      'tenant_id', p_tenant_id,
      'company_name', v_tenant.company_name,
      'action', p_action,
      'plan_tier', p_plan_tier,
      'reason', p_reason
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_saas_revenue_report(
  p_from_date date default null,
  p_to_date date default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_from_date date;
  v_to_date date;
  v_revenue_summary jsonb;
  v_plan_revenue jsonb;
  v_monthly_trend jsonb;
  v_churn_summary jsonb;
begin
  v_from_date := coalesce(
    p_from_date,
    date_trunc('year', now())::date
  );
  v_to_date := coalesce(
    p_to_date, now()::date
  );

  -- 전체 SaaS 매출 요약
  select jsonb_build_object(
    'total_paid', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'PAID'
      ), 0
    ),
    'total_pending', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'PENDING'
      ), 0
    ),
    'total_overdue', coalesce(
      sum(invoice_amount) filter (
        where invoice_status = 'OVERDUE'
      ), 0
    ),
    'paid_count', count(*) filter (
      where invoice_status = 'PAID'
    ),
    'pending_count', count(*) filter (
      where invoice_status = 'PENDING'
    ),
    'overdue_count', count(*) filter (
      where invoice_status = 'OVERDUE'
    ),
    'avg_monthly_revenue', coalesce(
      avg(invoice_amount) filter (
        where invoice_status = 'PAID'
      )::int, 0
    )
  )
  into v_revenue_summary
  from catchmenu_common.subscription_invoices
  where billing_period_start
    between v_from_date and v_to_date;

  -- 플랜별 매출
  select coalesce(
    jsonb_object_agg(
      plan_tier,
      jsonb_build_object(
        'revenue', revenue,
        'tenant_count', tenant_count
      )
    ),
    '{}'::jsonb
  )
  into v_plan_revenue
  from (
    select
      si.plan_tier,
      coalesce(sum(si.invoice_amount), 0)
        as revenue,
      count(distinct si.tenant_id)
        as tenant_count
    from catchmenu_common.subscription_invoices si
    where si.billing_period_start
      between v_from_date and v_to_date
      and si.invoice_status = 'PAID'
    group by si.plan_tier
  ) p;

  -- 월별 매출 트렌드
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'month', month,
        'revenue', revenue,
        'tenant_count', tenant_count
      )
      order by month
    ),
    '[]'::jsonb
  )
  into v_monthly_trend
  from (
    select
      to_char(billing_period_start, 'YYYY-MM')
        as month,
      coalesce(sum(invoice_amount), 0) as revenue,
      count(distinct tenant_id) as tenant_count
    from catchmenu_common.subscription_invoices
    where billing_period_start
      between v_from_date and v_to_date
      and invoice_status = 'PAID'
    group by
      to_char(billing_period_start, 'YYYY-MM')
  ) t;

  -- 이탈 현황
  select jsonb_build_object(
    'cancelled_this_month', count(*) filter (
      where tenant_status = 'CANCELLED'
        and updated_at
          >= date_trunc('month', now())
    ),
    'suspended_count', count(*) filter (
      where tenant_status = 'SUSPENDED'
    ),
    'trial_not_converted', count(*) filter (
      where tenant_status = 'TRIAL'
        and created_at
          < now() - interval '30 days'
    )
  )
  into v_churn_summary
  from catchmenu_hq.tenants;

  return catchmenu_common.build_success_response(
    p_message_key := 'saas_revenue_loaded',
    p_data := jsonb_build_object(
      'period', jsonb_build_object(
        'from_date', v_from_date,
        'to_date', v_to_date
      ),
      'revenue_summary', v_revenue_summary,
      'plan_revenue', v_plan_revenue,
      'monthly_trend', v_monthly_trend,
      'churn_summary', v_churn_summary,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_common.get_system_health_all(
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_tenant_health jsonb;
  v_pgcron_health jsonb;
  v_alert_health jsonb;
  v_db_health jsonb;
  v_overall text;
begin
  -- 테넌트별 헬스 요약
  select jsonb_build_object(
    'total_tenants', count(*),
    'healthy', count(*) filter (
      where not exists (
        select 1
        from catchmenu_common.operation_alerts oa
        where oa.tenant_id = t.id
          and oa.alert_severity in (
            'CRITICAL', 'FATAL'
          )
          and oa.alert_status = 'OPEN'
      )
    ),
    'has_critical', count(*) filter (
      where exists (
        select 1
        from catchmenu_common.operation_alerts oa
        where oa.tenant_id = t.id
          and oa.alert_severity in (
            'CRITICAL', 'FATAL'
          )
          and oa.alert_status = 'OPEN'
      )
    )
  )
  into v_tenant_health
  from catchmenu_hq.tenants t
  where t.tenant_status = 'ACTIVE';

  -- pg_cron 헬스
  select jsonb_build_object(
    'total_jobs', count(*),
    'active_jobs', count(*) filter (
      where is_active = true
    ),
    'failed_today', (
      select count(*)
      from catchmenu_common.pgcron_execution_log
      where execution_status = 'FAILED'
        and execution_start::date = (
          timezone('Asia/Seoul', now())
        )::date
    ),
    'last_execution', (
      select max(execution_start)
      from catchmenu_common.pgcron_execution_log
    )
  )
  into v_pgcron_health
  from catchmenu_common.pg_cron_jobs;

  -- 운영 알림 헬스
  select jsonb_build_object(
    'total_open', count(*) filter (
      where alert_status in (
        'OPEN', 'ACKNOWLEDGED'
      )
    ),
    'critical_count', count(*) filter (
      where alert_severity in (
        'CRITICAL', 'FATAL'
      )
      and alert_status = 'OPEN'
    ),
    'oldest_open_hours', coalesce(
      extract(
        epoch from (
          now() - min(created_at)
        )
      )::int / 3600,
      0
    )
  )
  into v_alert_health
  from catchmenu_common.operation_alerts
  where alert_status = 'OPEN';

  -- DB 헬스 (스키마 검증 최근 결과)
  select jsonb_build_object(
    'schema_version', version_code,
    'last_validated', (
      validation_result->>'validated_at'
    ),
    'validation_status', (
      validation_result->>'overall_status'
    ),
    'table_count', (
      validation_result->>'table_count'
    ),
    'function_count', (
      validation_result->>'function_count'
    )
  )
  into v_db_health
  from catchmenu_common.schema_versions
  where is_current = true;

  -- 전체 상태 판단
  v_overall := case
    when (v_alert_health->>'critical_count')
      ::int > 0 then 'CRITICAL'
    when (v_pgcron_health->>'failed_today')
      ::int > 3 then 'DEGRADED'
    when (v_tenant_health->>'has_critical')
      ::int > 0 then 'DEGRADED'
    else 'HEALTHY'
  end;

  return catchmenu_common.build_success_response(
    p_message_key := 'system_health_loaded',
    p_data := jsonb_build_object(
      'overall', v_overall,
      'tenant_health', v_tenant_health,
      'pgcron_health', v_pgcron_health,
      'alert_health', v_alert_health,
      'db_health', v_db_health,
      'checked_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


-- grants
-- HQ 관리자 RPC는 service_role로만 호출
-- (authenticated 사용자 직접 호출 금지)
do $$
begin
  -- HQ 전용: service_role만 허용
  revoke all on function
    catchmenu_common.get_hq_dashboard(text)
    from public, authenticated;
  grant execute on function
    catchmenu_common.get_hq_dashboard(text)
    to service_role;

  revoke all on function
    catchmenu_common.get_tenant_list(
      text, text, text, int, int, text
    ) from public, authenticated;
  grant execute on function
    catchmenu_common.get_tenant_list(
      text, text, text, int, int, text
    ) to service_role;

  revoke all on function
    catchmenu_common.onboard_tenant(
      text, text, text, text, text,
      text, text, text, uuid, text
    ) from public, authenticated;
  grant execute on function
    catchmenu_common.onboard_tenant(
      text, text, text, text, text,
      text, text, text, uuid, text
    ) to service_role;

  revoke all on function
    catchmenu_common.manage_subscription(
      uuid, text, text, text, uuid, text
    ) from public, authenticated;
  grant execute on function
    catchmenu_common.manage_subscription(
      uuid, text, text, text, uuid, text
    ) to service_role;

  revoke all on function
    catchmenu_common.get_saas_revenue_report(
      date, date, text
    ) from public, authenticated;
  grant execute on function
    catchmenu_common.get_saas_revenue_report(
      date, date, text
    ) to service_role;

  revoke all on function
    catchmenu_common.get_system_health_all(text)
    from public, authenticated;
  grant execute on function
    catchmenu_common.get_system_health_all(text)
    to service_role;
end;
$$;

comment on function
  catchmenu_common.get_hq_dashboard(text) is
  'HQ 관리자 대시보드.
   캐치메뉴 SaaS 운영자 전용.
   권한: service_role만 호출 가능.
   authenticated 직접 호출 불가.

   포함 데이터:
   - 전체 테넌트 현황 (ACTIVE/TRIAL/SUSPENDED)
   - 이번 달 SaaS 구독 매출
   - 플랜별 분포
   - 전체 운영 알림 요약
   - 최근 온보딩 테넌트 5개
   - 빠른 액션 4개

   접근 방식:
   Supabase Service Role Key 사용.
   Flutter HQ 관리자 앱 전용.
   일반 가맹점/고객 앱 접근 불가.';

comment on function
  catchmenu_common.manage_subscription(
    uuid, text, text, text, uuid, text
  ) is
  'SaaS 구독 관리.
   HQ 관리자 전용 (service_role).

   액션:
   UPGRADE/DOWNGRADE/CHANGE_PLAN:
     플랜 변경 + 인보이스 생성
   SUSPEND:
     테넌트 정지 + isolate_tenant(true)
     → 매장 앱 로그인 차단
   ACTIVATE:
     테넌트 복구 + isolate_tenant(false)
   CANCEL:
     구독 해지 + 플랜 종료

   SUSPEND 시:
   → 해당 테넌트 직원 로그인 불가
   → 고객 앱 주문 불가
   → 즉시 영향 (Realtime)
   모든 액션 = ledger event 기록.';