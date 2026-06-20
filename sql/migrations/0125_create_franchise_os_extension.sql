-- 0125_create_franchise_os_extension.sql
-- Purpose: Franchise OS extension.
--          브랜드 정책 관리.
--          메뉴 템플릿 배포.
--          가맹점 KPI 관리.
--          정책 위반 자동 탐지.
--          본부 공지 시스템.
--          i18n: 모든 메시지 = message_catalog.
-- Depends on: 0124_create_inventory_pipeline.sql

insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('franchise_policy_created', 'ko',
  '가맹 정책이 등록되었습니다'),
('franchise_policy_created', 'en',
  'Franchise policy created'),
('menu_template_distributed', 'ko',
  '메뉴 템플릿이 {store_count}개 매장에 배포되었습니다'),
('menu_template_distributed', 'en',
  'Menu template distributed to {store_count} stores'),
('kpi_target_set', 'ko',
  'KPI 목표가 설정되었습니다'),
('kpi_target_set', 'en',
  'KPI target set'),
('violation_detected', 'ko',
  '정책 위반이 탐지되었습니다'),
('violation_detected', 'en',
  'Policy violation detected'),
('hq_notice_sent', 'ko',
  '본부 공지가 발송되었습니다'),
('hq_notice_sent', 'en',
  'HQ notice sent'),
('franchise_dashboard_ready', 'ko',
  '프랜차이즈 OS 대시보드가 로드되었습니다'),
('franchise_dashboard_ready', 'en',
  'Franchise OS dashboard loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(11010, 'franchise_policy_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11011, 'kpi_target_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11012, 'menu_template_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11013, 'violation_already_open',
  'FRANCHISE', 'CONFLICT', 409, 'INFO')
on conflict (code) do nothing;


-- =============================================
-- franchise_menu_templates table
-- 본부 메뉴 템플릿
-- =============================================
create table if not exists
  catchmenu_hq.franchise_menu_templates (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),

  -- 템플릿 정보
  template_code text not null,
  template_name text not null,
  template_version int not null default 1,
  template_status text not null
    default 'DRAFT',

  -- 메뉴 데이터
  categories jsonb not null default '[]',
  menus jsonb not null default '[]',

  -- 배포 설정
  is_mandatory boolean not null default false,
  allow_price_override boolean
    not null default true,
  allow_item_disable boolean
    not null default true,

  -- 이력
  published_at timestamptz,
  published_by uuid,
  distributed_stores int default 0,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_template_code unique (
    brand_id, template_code, template_version
  ),
  constraint chk_template_status check (
    template_status in (
      'DRAFT', 'PUBLISHED',
      'DISTRIBUTED', 'DEPRECATED'
    )
  )
);

alter table catchmenu_hq.franchise_menu_templates
  enable row level security;
alter table catchmenu_hq.franchise_menu_templates
  force row level security;

drop policy if exists menu_template_isolation
  on catchmenu_hq.franchise_menu_templates;
create policy menu_template_isolation
  on catchmenu_hq.franchise_menu_templates
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

drop trigger if exists trg_menu_template_updated
  on catchmenu_hq.franchise_menu_templates;
create trigger trg_menu_template_updated
  before update on
    catchmenu_hq.franchise_menu_templates
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_hq.franchise_menu_templates is
  '본부 메뉴 템플릿.
   is_mandatory: 필수 메뉴 (삭제 불가).
   allow_price_override: 가맹점 가격 변경 허용.
   allow_item_disable: 가맹점 항목 비활성화 허용.
   배포 흐름:
   DRAFT → PUBLISHED → distribute → DISTRIBUTED
   가맹점은 템플릿 기반으로 메뉴 초기화.';


-- =============================================
-- hq_notices table
-- 본부 공지
-- =============================================
create table if not exists
  catchmenu_hq.hq_notices (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid,

  -- 공지 정보
  notice_type text not null,
  notice_title text not null,
  notice_body text not null,
  notice_severity text not null
    default 'INFO',
  notice_status text not null
    default 'DRAFT',

  -- 대상
  target_store_ids jsonb,
  target_all_stores boolean
    not null default true,

  -- 확인 추적
  total_targets int default 0,
  confirmed_count int default 0,
  requires_confirmation boolean
    not null default false,

  -- 첨부
  attachments jsonb default '[]',

  published_at timestamptz,
  published_by uuid,
  expires_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint chk_notice_type check (
    notice_type in (
      'POLICY_UPDATE',   -- 정책 변경
      'MENU_UPDATE',     -- 메뉴 변경
      'OPERATION_GUIDE', -- 운영 지침
      'EMERGENCY',       -- 긴급 공지
      'PROMOTION',       -- 프로모션
      'TRAINING',        -- 교육 자료
      'SYSTEM'           -- 시스템 공지
    )
  ),
  constraint chk_notice_severity check (
    notice_severity in (
      'INFO', 'WARNING',
      'CRITICAL', 'EMERGENCY'
    )
  )
);

alter table catchmenu_hq.hq_notices
  enable row level security;
alter table catchmenu_hq.hq_notices
  force row level security;

drop policy if exists hq_notices_isolation
  on catchmenu_hq.hq_notices;
create policy hq_notices_isolation
  on catchmenu_hq.hq_notices
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table catchmenu_hq.hq_notices is
  '본부 공지 시스템.
   EMERGENCY: 즉시 Realtime 전송.
   requires_confirmation: 확인 필수.
   confirmed_count: 매장별 확인 추적.
   target_store_ids null: 전체 매장.
   CMS broadcast와 별도 운영.
   (CMS = 고객용, HQ Notice = 가맹점용)';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.create_franchise_policy(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_policy_type text,
  p_policy_name text,
  p_policy_rules jsonb,
  p_is_mandatory boolean default true,
  p_violation_severity text default 'WARNING',
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_policy_id uuid;
begin
  insert into catchmenu_hq.franchise_policies (
    tenant_id, brand_id,
    policy_type, policy_name,
    policy_rules, is_mandatory,
    violation_severity, policy_status
  ) values (
    p_tenant_id, p_brand_id,
    p_policy_type, p_policy_name,
    p_policy_rules, p_is_mandatory,
    p_violation_severity, 'ACTIVE'
  )
  returning id into v_policy_id;

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
    'franchise', 'policy_created', 1,
    'franchise_policy', v_policy_id,
    null, 'ACTIVE',
    'FRANCHISE_ADMIN', p_actor_id,
    jsonb_build_object(
      'policy_type', p_policy_type,
      'policy_name', p_policy_name,
      'is_mandatory', p_is_mandatory,
      'brand_id', p_brand_id
    ),
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_policy_created',
    p_data := jsonb_build_object(
      'policy_id', v_policy_id,
      'policy_type', p_policy_type,
      'policy_name', p_policy_name,
      'is_mandatory', p_is_mandatory,
      'violation_severity', p_violation_severity
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.distribute_menu_template(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_template_id uuid,
  p_target_store_ids jsonb default null,
  p_override_existing boolean default false,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_template record;
  v_store record;
  v_success_count int := 0;
  v_fail_count int := 0;
  v_category jsonb;
  v_menu jsonb;
  v_category_id uuid;
begin
  -- 템플릿 조회
  select id, template_code, template_name,
         template_version, categories,
         menus, allow_price_override,
         allow_item_disable
  into v_template
  from catchmenu_hq.franchise_menu_templates
  where id = p_template_id
    and brand_id = p_brand_id
    and tenant_id = p_tenant_id
    and template_status = 'PUBLISHED';

  if v_template.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_template_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'distribute_menu_template'
    );
  end if;

  -- 대상 매장 순회
  for v_store in
    select id as store_id, store_name
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
      -- 카테고리 배포
      for v_category in
        select *
        from jsonb_array_elements(
          v_template.categories
        )
      loop
        insert into catchmenu_pos.menu_categories (
          tenant_id, store_id,
          category_code, category_name,
          display_order, is_active
        ) values (
          p_tenant_id, v_store.store_id,
          v_category->>'category_code',
          v_category->>'category_name',
          (v_category->>'display_order')::int,
          true
        )
        on conflict (store_id, category_code)
        do update set
          category_name = case
            p_override_existing
            when true then excluded.category_name
            else catchmenu_pos.menu_categories
              .category_name
          end,
          updated_at = now()
        returning id into v_category_id;
      end loop;

      -- 메뉴 배포
      for v_menu in
        select *
        from jsonb_array_elements(
          v_template.menus
        )
      loop
        insert into catchmenu_pos.menus (
          tenant_id, store_id,
          menu_code, menu_name,
          menu_name_en, menu_name_zh,
          menu_name_ja,
          price, description,
          is_kds_required, kitchen_zone,
          display_order, menu_status,
          allergen_codes, is_active
        )
        select
          p_tenant_id, v_store.store_id,
          v_menu->>'menu_code',
          v_menu->>'menu_name',
          v_menu->>'menu_name_en',
          v_menu->>'menu_name_zh',
          v_menu->>'menu_name_ja',
          (v_menu->>'price')::int,
          v_menu->>'description',
          coalesce(
            (v_menu->>'is_kds_required')::boolean,
            true
          ),
          coalesce(
            v_menu->>'kitchen_zone', 'MAIN'
          ),
          coalesce(
            (v_menu->>'display_order')::int, 0
          ),
          'AVAILABLE',
          coalesce(
            v_menu->'allergen_codes',
            '[]'::jsonb
          ),
          true
        on conflict (store_id, menu_code)
        do update set
          menu_name = case p_override_existing
            when true then excluded.menu_name
            else catchmenu_pos.menus.menu_name
          end,
          price = case
            when p_override_existing
              and not v_template
                .allow_price_override
            then excluded.price
            else catchmenu_pos.menus.price
          end,
          updated_at = now();
      end loop;

      v_success_count := v_success_count + 1;

    exception when others then
      v_fail_count := v_fail_count + 1;
    end;
  end loop;

  -- 템플릿 배포 수 업데이트
  update catchmenu_hq.franchise_menu_templates
  set
    distributed_stores = v_success_count,
    template_status = 'DISTRIBUTED',
    updated_at = now()
  where id = p_template_id;

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
    'franchise', 'menu_template_distributed', 1,
    'franchise_menu_template', p_template_id,
    'PUBLISHED', 'DISTRIBUTED',
    'FRANCHISE_ADMIN', p_actor_id,
    jsonb_build_object(
      'template_code', v_template.template_code,
      'template_version',
        v_template.template_version,
      'success_count', v_success_count,
      'fail_count', v_fail_count
    ),
    (timezone('Asia/Seoul', now()))::date,
    'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_template_distributed',
    p_data := jsonb_build_object(
      'template_id', p_template_id,
      'template_code', v_template.template_code,
      'success_count', v_success_count,
      'fail_count', v_fail_count,
      'total_stores',
        v_success_count + v_fail_count
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'store_count', v_success_count
    )
  );
end;
$$;


create or replace function
  catchmenu_hq.set_kpi_targets(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid,
  p_target_year int,
  p_target_month int,
  p_monthly_revenue_target bigint,
  p_monthly_order_target int default null,
  p_avg_order_target int default null,
  p_customer_satisfaction_target
    numeric default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_kpi_id uuid;
begin
  insert into catchmenu_hq.franchise_kpi_targets (
    tenant_id, brand_id, store_id,
    target_year, target_month,
    monthly_revenue_target,
    monthly_order_target,
    avg_order_target,
    customer_satisfaction_target
  ) values (
    p_tenant_id, p_brand_id, p_store_id,
    p_target_year, p_target_month,
    p_monthly_revenue_target,
    p_monthly_order_target,
    p_avg_order_target,
    p_customer_satisfaction_target
  )
  on conflict (store_id, target_year, target_month)
  do update set
    monthly_revenue_target =
      excluded.monthly_revenue_target,
    monthly_order_target =
      excluded.monthly_order_target,
    avg_order_target =
      excluded.avg_order_target,
    customer_satisfaction_target =
      excluded.customer_satisfaction_target,
    updated_at = now()
  returning id into v_kpi_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'kpi_target_set',
    p_data := jsonb_build_object(
      'kpi_id', v_kpi_id,
      'store_id', p_store_id,
      'target_year', p_target_year,
      'target_month', p_target_month,
      'monthly_revenue_target',
        p_monthly_revenue_target,
      'monthly_order_target',
        p_monthly_order_target
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.run_compliance_check(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_store record;
  v_policy record;
  v_violation_count int := 0;
  v_violations jsonb := '[]'::jsonb;
  v_violation_id uuid;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 대상 매장 순회
  for v_store in
    select id as store_id, store_name
    from catchmenu_hq.stores
    where tenant_id = p_tenant_id
      and brand_id = p_brand_id
      and is_active = true
      and (
        p_store_id is null
        or id = p_store_id
      )
  loop
    -- 정책별 준수 확인
    for v_policy in
      select id, policy_type, policy_name,
             policy_rules, violation_severity
      from catchmenu_hq.franchise_policies
      where brand_id = p_brand_id
        and tenant_id = p_tenant_id
        and policy_status = 'ACTIVE'
    loop
      -- 정책 타입별 검사
      case v_policy.policy_type

        -- 메뉴 가격 정책
        when 'MENU_PRICE' then
          declare
            v_violation_menus jsonb;
          begin
            select coalesce(
              jsonb_agg(
                jsonb_build_object(
                  'menu_code', menu_code,
                  'menu_name', menu_name,
                  'current_price', price,
                  'max_price',
                    (v_policy.policy_rules
                      ->>'max_price')::int
                )
              ),
              '[]'::jsonb
            )
            into v_violation_menus
            from catchmenu_pos.menus
            where store_id = v_store.store_id
              and tenant_id = p_tenant_id
              and is_active = true
              and price > (
                v_policy.policy_rules
                  ->>'max_price'
              )::int;

            if jsonb_array_length(
              v_violation_menus
            ) > 0 then
              insert into
                catchmenu_hq.policy_violations (
                tenant_id, store_id, policy_id,
                violation_severity,
                violation_detail,
                violation_status,
                detected_at
              ) values (
                p_tenant_id, v_store.store_id,
                v_policy.id,
                v_policy.violation_severity,
                jsonb_build_object(
                  'violation_menus',
                    v_violation_menus,
                  'policy_name',
                    v_policy.policy_name
                ),
                'OPEN',
                now()
              )
              returning id into v_violation_id;

              v_violations := v_violations
                || jsonb_build_object(
                  'violation_id', v_violation_id,
                  'store_name', v_store.store_name,
                  'policy_name', v_policy.policy_name,
                  'type', 'MENU_PRICE',
                  'count',
                    jsonb_array_length(
                      v_violation_menus
                    )
                );

              v_violation_count :=
                v_violation_count + 1;
            end if;
          end;

        -- 운영시간 정책
        when 'OPERATION_HOURS' then
          declare
            v_required_open time;
            v_required_close time;
            v_store_hours record;
          begin
            v_required_open := (
              v_policy.policy_rules
                ->>'required_open_time'
            )::time;
            v_required_close := (
              v_policy.policy_rules
                ->>'required_close_time'
            )::time;

            select open_time, close_time
            into v_store_hours
            from catchmenu_store
              .store_business_hours
            where store_id = v_store.store_id
              and tenant_id = p_tenant_id
              and day_of_week = 1;

            if v_store_hours.open_time
              > v_required_open
              or v_store_hours.close_time
              < v_required_close
            then
              insert into
                catchmenu_hq.policy_violations (
                tenant_id, store_id, policy_id,
                violation_severity,
                violation_detail,
                violation_status, detected_at
              ) values (
                p_tenant_id, v_store.store_id,
                v_policy.id,
                v_policy.violation_severity,
                jsonb_build_object(
                  'required_open',
                    v_required_open,
                  'required_close',
                    v_required_close,
                  'actual_open',
                    v_store_hours.open_time,
                  'actual_close',
                    v_store_hours.close_time
                ),
                'OPEN', now()
              )
              returning id into v_violation_id;

              v_violations := v_violations
                || jsonb_build_object(
                  'violation_id', v_violation_id,
                  'store_name', v_store.store_name,
                  'policy_name', v_policy.policy_name,
                  'type', 'OPERATION_HOURS'
                );

              v_violation_count :=
                v_violation_count + 1;
            end if;
          end;

        -- 알레르겐 표시 의무
        when 'ALLERGEN_COMPLIANCE' then
          declare
            v_missing_count int;
          begin
            select count(*) into v_missing_count
            from catchmenu_pos.menus
            where store_id = v_store.store_id
              and tenant_id = p_tenant_id
              and is_active = true
              and menu_status = 'AVAILABLE'
              and (
                allergen_codes is null
                or jsonb_array_length(
                  allergen_codes
                ) = 0
              );

            if v_missing_count > 0 then
              insert into
                catchmenu_hq.policy_violations (
                tenant_id, store_id, policy_id,
                violation_severity,
                violation_detail,
                violation_status, detected_at
              ) values (
                p_tenant_id, v_store.store_id,
                v_policy.id,
                'ERROR',
                jsonb_build_object(
                  'missing_allergen_count',
                    v_missing_count,
                  'regulation',
                    '식품위생법 제43조'
                ),
                'OPEN', now()
              )
              returning id into v_violation_id;

              v_violations := v_violations
                || jsonb_build_object(
                  'violation_id', v_violation_id,
                  'store_name', v_store.store_name,
                  'type', 'ALLERGEN_COMPLIANCE',
                  'missing_count', v_missing_count,
                  'regulation', '식품위생법'
                );

              v_violation_count :=
                v_violation_count + 1;
            end if;
          end;

        else null;
      end case;
    end loop;
  end loop;

  return catchmenu_common.build_success_response(
    p_message_key := 'compliance_report_loaded',
    p_data := jsonb_build_object(
      'brand_id', p_brand_id,
      'checked_at', now(),
      'violation_count', v_violation_count,
      'violations', v_violations,
      'is_compliant', v_violation_count = 0
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.send_hq_notice(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_notice_type text,
  p_notice_title text,
  p_notice_body text,
  p_notice_severity text default 'INFO',
  p_target_store_ids jsonb default null,
  p_requires_confirmation boolean
    default false,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_notice_id uuid;
  v_target_count int;
begin
  -- 대상 매장 수
  select count(*) into v_target_count
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
    );

  -- 공지 생성
  insert into catchmenu_hq.hq_notices (
    tenant_id, brand_id,
    notice_type, notice_title, notice_body,
    notice_severity, notice_status,
    target_store_ids, target_all_stores,
    total_targets, requires_confirmation,
    published_at, published_by
  ) values (
    p_tenant_id, p_brand_id,
    p_notice_type, p_notice_title,
    p_notice_body,
    p_notice_severity, 'PUBLISHED',
    p_target_store_ids,
    p_target_store_ids is null,
    v_target_count, p_requires_confirmation,
    now(), p_actor_id
  )
  returning id into v_notice_id;

  -- Realtime 전송 (직원 앱)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := null,
    p_channel_type := 'STAFF_ALERTS',
    p_event_type := 'hq_notice_received',
    p_payload := jsonb_build_object(
      'notice_id', v_notice_id,
      'notice_type', p_notice_type,
      'notice_title', p_notice_title,
      'notice_severity', p_notice_severity,
      'requires_confirmation',
        p_requires_confirmation,
      'target_store_ids', p_target_store_ids
    )
  );

  -- EMERGENCY → 운영 알림
  if p_notice_severity = 'EMERGENCY' then
    perform catchmenu_common.create_operation_alert(
      p_tenant_id := p_tenant_id,
      p_alert_type := 'HQ_EMERGENCY_NOTICE',
      p_alert_severity := 'CRITICAL',
      p_alert_domain := 'FRANCHISE',
      p_alert_title_key := 'hq_notice_sent',
      p_alert_detail := jsonb_build_object(
        'notice_id', v_notice_id,
        'notice_title', p_notice_title,
        'target_count', v_target_count
      )
    );
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'hq_notice_sent',
    p_data := jsonb_build_object(
      'notice_id', v_notice_id,
      'notice_type', p_notice_type,
      'notice_severity', p_notice_severity,
      'target_count', v_target_count,
      'requires_confirmation',
        p_requires_confirmation
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_hq.get_franchise_os_dashboard(
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
  v_kpi_summary jsonb;
  v_violation_summary jsonb;
  v_notice_summary jsonb;
  v_template_summary jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  select id, brand_name, brand_code
  into v_brand
  from catchmenu_hq.franchise_brands
  where id = p_brand_id
    and tenant_id = p_tenant_id;

  -- 매장 현황
  select jsonb_build_object(
    'total_stores', count(*),
    'active_stores', count(*) filter (
      where ss.store_mode = 'NORMAL'
    ),
    'stores_with_kpi', count(distinct kpi.store_id)
  )
  into v_store_summary
  from catchmenu_hq.stores s
  left join catchmenu_store.store_settings ss
    on ss.store_id = s.id
  left join catchmenu_hq.franchise_kpi_targets kpi
    on kpi.store_id = s.id
    and kpi.target_year =
      extract(year from now())::int
    and kpi.target_month =
      extract(month from now())::int
  where s.tenant_id = p_tenant_id
    and s.brand_id = p_brand_id
    and s.is_active = true;

  -- KPI 달성 현황
  select jsonb_build_object(
    'total_target', coalesce(
      sum(kpi.monthly_revenue_target), 0
    ),
    'achieved_amount', coalesce(
      sum(revenue.amount), 0
    ),
    'achievement_rate', case
      when sum(kpi.monthly_revenue_target) = 0
        then null
      else round(
        sum(revenue.amount)::numeric
        / sum(kpi.monthly_revenue_target)
        * 100, 1
      )
    end,
    'on_track_stores', count(*) filter (
      where revenue.amount
        >= kpi.monthly_revenue_target * 0.8
    ),
    'behind_stores', count(*) filter (
      where revenue.amount
        < kpi.monthly_revenue_target * 0.8
    )
  )
  into v_kpi_summary
  from catchmenu_hq.franchise_kpi_targets kpi
  join catchmenu_hq.stores s
    on s.id = kpi.store_id
    and s.brand_id = p_brand_id
  left join lateral (
    select coalesce(sum(o.final_amount), 0)
      as amount
    from catchmenu_pos.orders o
    where o.store_id = kpi.store_id
      and o.tenant_id = p_tenant_id
      and o.order_status = 'COMPLETED'
      and o.business_day
        >= date_trunc('month', now())::date
  ) revenue on true
  where kpi.tenant_id = p_tenant_id
    and kpi.target_year =
      extract(year from now())::int
    and kpi.target_month =
      extract(month from now())::int;

  -- 정책 위반 현황
  select jsonb_build_object(
    'total_open', count(*) filter (
      where pv.violation_status = 'OPEN'
    ),
    'critical', count(*) filter (
      where pv.violation_severity
        in ('CRITICAL', 'FATAL')
        and pv.violation_status = 'OPEN'
    ),
    'allergen_violations', count(*) filter (
      where fp.policy_type
        = 'ALLERGEN_COMPLIANCE'
        and pv.violation_status = 'OPEN'
    )
  )
  into v_violation_summary
  from catchmenu_hq.policy_violations pv
  join catchmenu_hq.stores s
    on s.id = pv.store_id
    and s.brand_id = p_brand_id
  join catchmenu_hq.franchise_policies fp
    on fp.id = pv.policy_id
  where pv.tenant_id = p_tenant_id;

  -- 공지 현황
  select jsonb_build_object(
    'total_published', count(*) filter (
      where notice_status = 'PUBLISHED'
    ),
    'unconfirmed', count(*) filter (
      where requires_confirmation = true
        and confirmed_count < total_targets
        and notice_status = 'PUBLISHED'
    ),
    'emergency', count(*) filter (
      where notice_severity = 'EMERGENCY'
        and notice_status = 'PUBLISHED'
    )
  )
  into v_notice_summary
  from catchmenu_hq.hq_notices
  where tenant_id = p_tenant_id
    and (brand_id = p_brand_id
      or brand_id is null);

  -- 메뉴 템플릿 현황
  select jsonb_build_object(
    'total_templates', count(*),
    'published', count(*) filter (
      where template_status = 'PUBLISHED'
    ),
    'distributed', count(*) filter (
      where template_status = 'DISTRIBUTED'
    ),
    'draft', count(*) filter (
      where template_status = 'DRAFT'
    )
  )
  into v_template_summary
  from catchmenu_hq.franchise_menu_templates
  where brand_id = p_brand_id
    and tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'franchise_dashboard_ready',
    p_data := jsonb_build_object(
      'brand', jsonb_build_object(
        'id', v_brand.id,
        'brand_name', v_brand.brand_name,
        'brand_code', v_brand.brand_code
      ),
      'business_day', v_business_day,
      'store_summary', v_store_summary,
      'kpi_summary', v_kpi_summary,
      'violation_summary', v_violation_summary,
      'notice_summary', v_notice_summary,
      'template_summary', v_template_summary,
      'quick_actions', jsonb_build_array(
        jsonb_build_object(
          'action', 'run_compliance',
          'label', '정책 준수 검사',
          'rpc', 'run_compliance_check'
        ),
        jsonb_build_object(
          'action', 'send_notice',
          'label', '공지 발송',
          'rpc', 'send_hq_notice'
        ),
        jsonb_build_object(
          'action', 'distribute_menu',
          'label', '메뉴 템플릿 배포',
          'rpc', 'distribute_menu_template'
        ),
        jsonb_build_object(
          'action', 'compare_revenue',
          'label', '매출 비교',
          'rpc', 'compare_store_revenue'
        )
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
    catchmenu_hq.create_franchise_policy(
      uuid, uuid, text, text, jsonb,
      boolean, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.distribute_menu_template(
      uuid, uuid, uuid, jsonb,
      boolean, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.set_kpi_targets(
      uuid, uuid, uuid, int, int,
      bigint, int, int, numeric, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.run_compliance_check(
      uuid, uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.send_hq_notice(
      uuid, uuid, text, text, text,
      text, jsonb, boolean, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_hq.get_franchise_os_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.run_compliance_check(
    uuid, uuid, uuid, text
  ) is
  '가맹점 정책 준수 자동 검사.
   정책 타입별 자동 탐지:
   MENU_PRICE: 최대 가격 초과 메뉴
   OPERATION_HOURS: 영업시간 미준수
   ALLERGEN_COMPLIANCE: 알레르겐 미표시
     → 식품위생법 제43조 위반 자동 탐지

   위반 탐지 시:
   policy_violations 자동 기록.
   severity별 후속 처리.

   pg_cron 연동:
   DAILY_COMPLIANCE_CHECK 02:00 자동 실행.
   수동 실행도 가능.

   알레르겐 위반 = 식품위생법 위반.
   즉시 시정 조치 필요.';

comment on function
  catchmenu_hq.distribute_menu_template(
    uuid, uuid, uuid, jsonb, boolean, uuid, text
  ) is
  '본부 메뉴 템플릿 가맹점 배포.
   categories + menus jsonb 일괄 upsert.

   allow_price_override = true:
     가맹점이 가격 자체 설정 가능.
   allow_price_override = false:
     본부 가격 강제 적용.
   allow_item_disable = true:
     가맹점이 메뉴 비활성화 가능.

   p_override_existing = true:
     기존 메뉴 이름 덮어쓰기.
   p_override_existing = false:
     기존 유지, 신규만 추가.

   Franchise OS 핵심 기능.
   신 메뉴 출시 → 전 매장 일괄 배포.';