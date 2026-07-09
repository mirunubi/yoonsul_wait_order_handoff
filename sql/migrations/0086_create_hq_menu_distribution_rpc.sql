-- 0086_create_hq_menu_distribution_rpc.sql
-- Purpose: HQ menu template distribution RPCs.
--          Menu template creation, versioning,
--          store-level menu sync from HQ template,
--          local override management.
--          3차 Franchise_OS 사전 작업.
--          공통 모듈: 1-C차 완전 SaaS에서 재사용.
-- Depends on: 0085_create_franchise_os_foundation_rpc.sql
-- Creates:
--   catchmenu_hq.menu_distribution_log (table)
--   function catchmenu_hq.create_menu_template(...)
--   function catchmenu_hq.distribute_menu_to_stores(...)
--   function catchmenu_hq.apply_menu_template(...)
--   function catchmenu_hq.request_menu_override(...)
--   function catchmenu_hq.get_menu_compliance_report(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('menu_template_created', 'ko',
  '메뉴 템플릿이 생성되었습니다'),
('menu_template_created', 'en',
  'Menu template created'),
('menu_distributed', 'ko',
  '{store_count}개 매장에 메뉴가 배포되었습니다'),
('menu_distributed', 'en',
  'Menu distributed to {store_count} stores'),
('menu_template_applied', 'ko',
  '메뉴 템플릿이 매장에 적용되었습니다'),
('menu_template_applied', 'en',
  'Menu template applied to store'),
('menu_override_requested', 'ko',
  '메뉴 예외 요청이 접수되었습니다'),
('menu_override_requested', 'en',
  'Menu exception request submitted'),
('menu_compliance_loaded', 'ko',
  '메뉴 준수 현황이 로드되었습니다'),
('menu_compliance_loaded', 'en',
  'Menu compliance report loaded'),
('menu_template_not_found', 'ko',
  '메뉴 템플릿을 찾을 수 없습니다'),
('menu_template_not_found', 'en',
  'Menu template not found'),
('menu_already_synced', 'ko',
  '이미 최신 버전으로 동기화되어 있습니다'),
('menu_already_synced', 'en',
  'Already synced to latest version')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(11012, 'menu_template_not_found',
  'FRANCHISE', 'NOT_FOUND', 404, 'WARNING'),
(11013, 'menu_already_synced',
  'FRANCHISE', 'CONFLICT', 409, 'INFO'),
(11014, 'menu_distribution_failed',
  'FRANCHISE', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;


-- =============================================
-- hq_menu_templates 확장
-- 기존 테이블에 컬럼 추가
-- =============================================
alter table catchmenu_hq.menu_templates
  add column if not exists brand_id uuid
    references catchmenu_hq.franchise_brands(id),
  add column if not exists version_number int
    not null default 1,
  add column if not exists supersedes uuid,
  add column if not exists superseded_by uuid,
  add column if not exists template_scope text
    not null default 'BRAND',
  add column if not exists is_mandatory boolean
    not null default false,
  add column if not exists allows_local_add boolean
    not null default true,
  add column if not exists allows_local_remove boolean
    not null default false,
  add column if not exists allows_price_override boolean
    not null default false,
  add column if not exists max_price_override_pct
    numeric(5,2) default null,
  add column if not exists distribution_count int
    not null default 0,
  add column if not exists last_distributed_at
    timestamptz;

comment on table catchmenu_hq.menu_templates is
  '본사 메뉴 템플릿.
   brand_id: 연결된 프랜차이즈 브랜드.
   is_mandatory: 가맹점 강제 적용.
   allows_local_add: 로컬 메뉴 추가 허용.
   allows_local_remove: 본사 메뉴 삭제 허용.
   allows_price_override: 가격 변경 허용.
   max_price_override_pct: 최대 가격 변동 허용%.
   3차 Franchise_OS 메뉴 배포 기반.
   1-C차 완전 SaaS에서 멀티테넌트 확장.';


-- =============================================
-- menu_distribution_log table
-- 메뉴 배포 이력
-- =============================================
create table if not exists
  catchmenu_hq.menu_distribution_log (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  brand_id uuid not null
    references catchmenu_hq.franchise_brands(id),
  template_id uuid not null
    references catchmenu_hq.menu_templates(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 배포 정보
  distribution_type text
    not null default 'FULL_SYNC',
  template_version int not null,
  distribution_status text
    not null default 'PENDING',

  -- 결과
  menus_created int not null default 0,
  menus_updated int not null default 0,
  menus_deactivated int not null default 0,
  menus_skipped int not null default 0,

  -- 로컬 오버라이드
  has_local_overrides boolean
    not null default false,
  override_count int not null default 0,

  -- 오류
  error_detail text,

  -- 타임스탬프
  distributed_at timestamptz
    not null default now(),
  completed_at timestamptz,

  created_at timestamptz not null default now(),

  constraint chk_distribution_type check (
    distribution_type in (
      'FULL_SYNC',      -- 전체 동기화
      'INCREMENTAL',    -- 변경분만
      'PRICE_ONLY',     -- 가격만
      'STATUS_ONLY',    -- 상태만
      'ROLLBACK'        -- 이전 버전 복구
    )
  ),
  constraint chk_distribution_status check (
    distribution_status in (
      'PENDING', 'IN_PROGRESS',
      'COMPLETED', 'PARTIAL', 'FAILED'
    )
  )
);

create index if not exists idx_dist_log_store
  on catchmenu_hq.menu_distribution_log(
    store_id, distributed_at desc
  );
create index if not exists idx_dist_log_template
  on catchmenu_hq.menu_distribution_log(
    template_id, distribution_status
  );
create index if not exists idx_dist_log_brand
  on catchmenu_hq.menu_distribution_log(
    brand_id, distributed_at desc
  );

alter table catchmenu_hq.menu_distribution_log
  enable row level security;
alter table catchmenu_hq.menu_distribution_log
  force row level security;

drop policy if exists dist_log_isolation
  on catchmenu_hq.menu_distribution_log;
create policy dist_log_isolation
  on catchmenu_hq.menu_distribution_log
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
  );

comment on table
  catchmenu_hq.menu_distribution_log is
  '메뉴 배포 이력.
   FULL_SYNC: 전체 메뉴 동기화 (최초 배포).
   INCREMENTAL: 변경분만 배포 (일상 업데이트).
   ROLLBACK: 이전 버전 복구.
   특허4: 메뉴 배포 = 감사 추적 가능.
   3차 Franchise_OS 핵심 감사 테이블.';


-- =============================================
-- RPCs
-- =============================================
create or replace function
  catchmenu_hq.create_menu_template(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_template_code text,
  p_template_name text,
  p_menu_items jsonb,
  p_is_mandatory boolean default false,
  p_allows_local_add boolean default true,
  p_allows_local_remove boolean default false,
  p_allows_price_override boolean default false,
  p_max_price_override_pct numeric default null,
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common
as $$
declare
  v_template_id uuid;
  v_old_template_id uuid;
  v_version_number int := 1;
  v_audit_id uuid;
  v_business_day date;
  v_item_count int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 브랜드 확인
  if not exists (
    select 1 from catchmenu_hq.franchise_brands
    where id = p_brand_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'create_menu_template'
    );
  end if;

  v_item_count := jsonb_array_length(
    coalesce(p_menu_items, '[]'::jsonb)
  );

  if v_item_count = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'items_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'create_menu_template'
    );
  end if;

  -- 기존 버전 확인
  select id, version_number
  into v_old_template_id, v_version_number
  from catchmenu_hq.menu_templates
  where tenant_id = p_tenant_id
    and brand_id = p_brand_id
    and template_code = p_template_code
    and template_status = 'PUBLISHED'
    and is_active = true
  order by version_number desc
  limit 1;

  if v_old_template_id is not null then
    v_version_number := v_version_number + 1;
    -- 이전 버전 SUPERSEDED
    update catchmenu_hq.menu_templates
    set
      template_status = 'SUPERSEDED',
      superseded_by = null,
      updated_at = now()
    where id = v_old_template_id;
  end if;

  -- 새 템플릿 생성
  insert into catchmenu_hq.menu_templates (
    tenant_id, brand_id,
    template_code, template_name,
    template_data,
    version_number, supersedes,
    template_scope,
    is_mandatory,
    allows_local_add,
    allows_local_remove,
    allows_price_override,
    max_price_override_pct,
    template_status,
    created_by
  ) values (
    p_tenant_id, p_brand_id,
    p_template_code, p_template_name,
    jsonb_build_object(
      'items', p_menu_items,
      'item_count', v_item_count,
      'version', v_version_number,
      'created_at', now()
    ),
    v_version_number, v_old_template_id,
    'BRAND',
    p_is_mandatory,
    p_allows_local_add,
    p_allows_local_remove,
    p_allows_price_override,
    p_max_price_override_pct,
    'PUBLISHED',
    p_actor_id
  )
  returning id into v_template_id;

  -- 이전 버전 superseded_by 연결
  if v_old_template_id is not null then
    update catchmenu_hq.menu_templates
    set superseded_by = v_template_id
    where id = v_old_template_id;
  end if;

  -- audit
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_audit_domain := 'franchise',
    p_audit_type := 'menu_template_created',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_subject_type := 'menu_template',
    p_subject_id := v_template_id,
    p_decision := 'PUBLISHED',
    p_decision_payload := jsonb_build_object(
      'template_code', p_template_code,
      'version', v_version_number,
      'item_count', v_item_count,
      'is_mandatory', p_is_mandatory
    ),
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := 'Asia/Seoul'
  );

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'franchise', 'menu_template_created', 1,
    'menu_template', v_template_id,
    null, 'PUBLISHED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'template_code', p_template_code,
      'brand_id', p_brand_id,
      'version', v_version_number,
      'item_count', v_item_count,
      'is_mandatory', p_is_mandatory,
      'supersedes', v_old_template_id
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_template_created',
    p_data := jsonb_build_object(
      'template_id', v_template_id,
      'template_code', p_template_code,
      'version_number', v_version_number,
      'item_count', v_item_count,
      'is_mandatory', p_is_mandatory,
      'allows_local_add', p_allows_local_add,
      'allows_price_override',
        p_allows_price_override,
      'supersedes', v_old_template_id,
      'audit_id', v_audit_id
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.distribute_menu_to_stores(
  p_tenant_id uuid,
  p_template_id uuid,
  p_target_store_ids jsonb default null,
  p_distribution_type text default 'FULL_SYNC',
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
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
  v_template record;
  v_store_ids jsonb;
  v_store_id uuid;
  v_log_id uuid;
  v_distributed int := 0;
  v_failed int := 0;
  v_apply_result jsonb;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 템플릿 조회
  select id, template_code, template_name,
         brand_id, version_number,
         template_data, is_mandatory,
         template_status
  into v_template
  from catchmenu_hq.menu_templates
  where id = p_template_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_template.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_template_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'distribute_menu_to_stores'
    );
  end if;

  if v_template.template_status <> 'PUBLISHED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_template_not_found',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'status', v_template.template_status
      ),
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'distribute_menu_to_stores'
    );
  end if;

  -- 대상 매장 결정
  if p_target_store_ids is not null
    and jsonb_array_length(
      p_target_store_ids
    ) > 0
  then
    v_store_ids := p_target_store_ids;
  else
    -- 브랜드 전체 매장
    select coalesce(
      jsonb_agg(store_id), '[]'::jsonb
    )
    into v_store_ids
    from catchmenu_hq.store_group_members
    where group_id = v_template.brand_id
      and tenant_id = p_tenant_id
      and is_active = true;
  end if;

  if jsonb_array_length(v_store_ids) = 0 then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'distribute_menu_to_stores'
    );
  end if;

  -- 매장별 배포
  for v_store_id in
    select jsonb_array_elements_text(
      v_store_ids
    )::uuid
  loop
    begin
      -- 배포 로그 생성
      insert into
        catchmenu_hq.menu_distribution_log (
        tenant_id, brand_id, template_id,
        store_id, distribution_type,
        template_version, distribution_status
      ) values (
        p_tenant_id, v_template.brand_id,
        p_template_id, v_store_id,
        p_distribution_type,
        v_template.version_number,
        'IN_PROGRESS'
      )
      returning id into v_log_id;

      -- 템플릿 적용
      v_apply_result :=
        catchmenu_hq.apply_menu_template(
          p_tenant_id := p_tenant_id,
          p_template_id := p_template_id,
          p_store_id := v_store_id,
          p_distribution_log_id := v_log_id,
          p_distribution_type :=
            p_distribution_type,
          p_locale := p_locale,
          p_actor_id := p_actor_id,
          p_correlation_id := p_correlation_id
        );

      if (v_apply_result->>'success')::boolean then
        v_distributed := v_distributed + 1;
      else
        v_failed := v_failed + 1;
        update catchmenu_hq.menu_distribution_log
        set
          distribution_status = 'FAILED',
          error_detail =
            v_apply_result->>'error_key',
          completed_at = now()
        where id = v_log_id;
      end if;

    exception when others then
      v_failed := v_failed + 1;
      update catchmenu_hq.menu_distribution_log
      set
        distribution_status = 'FAILED',
        error_detail = sqlerrm,
        completed_at = now()
      where id = v_log_id;
    end;
  end loop;

  -- 템플릿 배포 카운트 업데이트
  update catchmenu_hq.menu_templates
  set
    distribution_count =
      distribution_count + v_distributed,
    last_distributed_at = now(),
    updated_at = now()
  where id = p_template_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id,
    'franchise', 'menu_distributed', 1,
    'menu_template', p_template_id,
    null, 'DISTRIBUTED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'template_code', v_template.template_code,
      'template_version',
        v_template.version_number,
      'total_stores',
        jsonb_array_length(v_store_ids),
      'distributed', v_distributed,
      'failed', v_failed,
      'distribution_type', p_distribution_type
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_distributed',
    p_data := jsonb_build_object(
      'template_id', p_template_id,
      'template_code', v_template.template_code,
      'template_version',
        v_template.version_number,
      'distribution_type', p_distribution_type,
      'total_stores',
        jsonb_array_length(v_store_ids),
      'distributed', v_distributed,
      'failed', v_failed,
      'success_rate_pct', case
        when jsonb_array_length(v_store_ids) > 0
        then (
          v_distributed::numeric
          / jsonb_array_length(v_store_ids) * 100
        )::int
        else 0
      end
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object(
      'store_count', v_distributed
    ),
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.apply_menu_template(
  p_tenant_id uuid,
  p_template_id uuid,
  p_store_id uuid,
  p_distribution_log_id uuid default null,
  p_distribution_type text default 'FULL_SYNC',
  p_locale text default 'ko',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_template record;
  v_item jsonb;
  v_existing_menu record;
  v_category_id uuid;
  v_menu_id uuid;
  v_created int := 0;
  v_updated int := 0;
  v_deactivated int := 0;
  v_skipped int := 0;
  v_template_menu_codes jsonb := '[]'::jsonb;
  v_is_new boolean;
begin
  -- 템플릿 조회
  select id, template_code, brand_id,
         version_number, template_data,
         allows_price_override,
         max_price_override_pct,
         allows_local_remove
  into v_template
  from catchmenu_hq.menu_templates
  where id = p_template_id
    and tenant_id = p_tenant_id
    and template_status = 'PUBLISHED'
    and is_active = true;

  if v_template.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_template_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'apply_menu_template'
    );
  end if;

  -- 템플릿 항목별 처리
  for v_item in
    select *
    from jsonb_array_elements(
      v_template.template_data->'items'
    )
  loop
    declare
      v_menu_code text;
      v_menu_name text;
      v_price int;
      v_cat_code text;
    begin
      v_menu_code := 'HQ_'
        || v_template.template_code
        || '_'
        || (v_item->>'item_code');
      v_menu_name := v_item->>'menu_name';
      v_price := (v_item->>'price')::int;
      v_cat_code := v_item->>'category_code';

      -- 템플릿 메뉴 코드 추적
      v_template_menu_codes :=
        v_template_menu_codes
        || to_jsonb(v_menu_code);

      -- 카테고리 처리
      if v_cat_code is not null then
        insert into catchmenu_pos.menu_categories (
          tenant_id, store_id,
          category_code, category_name,
          display_order
        ) values (
          p_tenant_id, p_store_id,
          'HQ_' || v_cat_code,
          coalesce(
            v_item->>'category_name',
            v_cat_code
          ),
          coalesce(
            (v_item->>'category_order')::int, 0
          )
        )
        on conflict (store_id, category_code)
        do update set
          category_name = excluded.category_name,
          updated_at = now()
        returning id into v_category_id;
      end if;

      -- 기존 메뉴 조회
      select id, price, menu_status
      into v_existing_menu
      from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and menu_code = v_menu_code;

      v_is_new := v_existing_menu.id is null;

      if v_is_new then
        -- 신규 생성
        insert into catchmenu_pos.menus (
          tenant_id, store_id,
          category_id, menu_code, menu_name,
          price, menu_status,
          is_kds_required, display_order,
          description
        ) values (
          p_tenant_id, p_store_id,
          v_category_id, v_menu_code, v_menu_name,
          v_price,
          coalesce(
            v_item->>'menu_status', 'AVAILABLE'
          ),
          coalesce(
            (v_item->>'is_kds_required')::boolean,
            true
          ),
          coalesce(
            (v_item->>'display_order')::int, 0
          ),
          v_item->>'description'
        )
        returning id into v_menu_id;

        v_created := v_created + 1;

      else
        -- 업데이트 (가격 오버라이드 확인)
        declare
          v_final_price int;
          v_existing_price int :=
            v_existing_menu.price;
        begin
          if v_template.allows_price_override
            and v_existing_price <> v_price
          then
            -- 오버라이드 허용: 최대 변동폭 확인
            if v_template.max_price_override_pct
              is not null
            then
              declare
                v_pct_diff numeric;
              begin
                v_pct_diff := abs(
                  v_existing_price - v_price
                )::numeric / v_price * 100;

                v_final_price := case
                  when v_pct_diff <=
                    v_template.max_price_override_pct
                    then v_existing_price
                  else v_price
                end;
              end;
            else
              v_final_price := v_existing_price;
            end if;
          else
            v_final_price := v_price;
          end if;

          update catchmenu_pos.menus
          set
            menu_name = v_menu_name,
            price = v_final_price,
            category_id = coalesce(
              v_category_id, category_id
            ),
            is_active = true,
            updated_at = now()
          where id = v_existing_menu.id;

          v_updated := v_updated + 1;
        end;
      end if;
    end;
  end loop;

  -- 본사 메뉴이지만 템플릿에 없는 항목 처리
  if p_distribution_type = 'FULL_SYNC'
    and v_template.allows_local_remove = false
  then
    -- 본사 메뉴 코드로 시작하지만
    -- 현재 템플릿에 없는 메뉴 비활성화
    update catchmenu_pos.menus
    set
      menu_status = 'DISCONTINUED',
      is_active = false,
      updated_at = now()
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and menu_code like 'HQ_'
        || v_template.template_code || '_%'
      and not (
        v_template_menu_codes
          @> to_jsonb(menu_code)
      )
      and menu_status <> 'DISCONTINUED';

    get diagnostics v_deactivated = row_count;
  end if;

  -- 배포 로그 완료 업데이트
  if p_distribution_log_id is not null then
    update catchmenu_hq.menu_distribution_log
    set
      distribution_status = 'COMPLETED',
      menus_created = v_created,
      menus_updated = v_updated,
      menus_deactivated = v_deactivated,
      menus_skipped = v_skipped,
      completed_at = now()
    where id = p_distribution_log_id;
  end if;

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_template_applied',
    p_data := jsonb_build_object(
      'template_id', p_template_id,
      'store_id', p_store_id,
      'template_version',
        v_template.version_number,
      'distribution_type', p_distribution_type,
      'result', jsonb_build_object(
        'created', v_created,
        'updated', v_updated,
        'deactivated', v_deactivated,
        'skipped', v_skipped
      )
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.request_menu_override(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_store_id uuid,
  p_override_type text,
  p_menu_code text,
  p_override_data jsonb,
  p_reason text,
  p_locale text default 'ko',
  p_requested_by uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_hq,
                  catchmenu_common
as $$
declare
  v_template record;
  v_request_result jsonb;
begin
  -- 현재 적용된 템플릿 확인
  select mt.id, mt.template_code,
         mt.allows_local_add,
         mt.allows_local_remove,
         mt.allows_price_override,
         mt.max_price_override_pct,
         mt.is_mandatory
  into v_template
  from catchmenu_hq.menu_templates mt
  join catchmenu_hq.menu_distribution_log dl
    on dl.template_id = mt.id
  where dl.store_id = p_store_id
    and mt.tenant_id = p_tenant_id
    and mt.brand_id = p_brand_id
    and dl.distribution_status = 'COMPLETED'
    and mt.is_active = true
  order by dl.distributed_at desc
  limit 1;

  -- 정책 위반 여부 사전 확인
  if v_template.id is not null then
    if p_override_type = 'LOCAL_ADD'
      and not v_template.allows_local_add
    then
      return catchmenu_common.build_error_response(
        p_error_key := 'policy_conflict_detected',
        p_locale := p_locale,
        p_params := jsonb_build_object(
          'policy', 'allows_local_add=false'
        ),
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'request_menu_override'
      );
    end if;
  end if;

  -- HQ 승인 요청 생성
  v_request_result :=
    catchmenu_hq.request_hq_approval(
      p_tenant_id := p_tenant_id,
      p_brand_id := p_brand_id,
      p_from_store_id := p_store_id,
      p_request_type := 'MENU_EXCEPTION',
      p_request_title := p_override_type
        || ': ' || p_menu_code,
      p_request_body := jsonb_build_object(
        'override_type', p_override_type,
        'menu_code', p_menu_code,
        'override_data', p_override_data,
        'reason', p_reason,
        'template_code',
          coalesce(v_template.template_code, 'N/A')
      ),
      p_priority := 'NORMAL',
      p_locale := p_locale,
      p_requested_by := p_requested_by,
      p_correlation_id := p_correlation_id
    );

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_override_requested',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'override_type', p_override_type,
      'menu_code', p_menu_code,
      'approval_request',
        v_request_result->'data'
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function
  catchmenu_hq.get_menu_compliance_report(
  p_tenant_id uuid,
  p_brand_id uuid,
  p_template_id uuid default null
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_hq,
                  catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_brand record;
  v_template record;
  v_store_compliance jsonb;
  v_summary jsonb;
begin
  select id, brand_code, brand_name
  into v_brand
  from catchmenu_hq.franchise_brands
  where id = p_brand_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_brand.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'brand_not_found',
      p_locale := 'ko',
      p_tenant_id := p_tenant_id,
      p_rpc_name := 'get_menu_compliance_report'
    );
  end if;

  -- 최신 배포 템플릿
  if p_template_id is null then
    select id, template_code, version_number,
           template_data
    into v_template
    from catchmenu_hq.menu_templates
    where brand_id = p_brand_id
      and tenant_id = p_tenant_id
      and template_status = 'PUBLISHED'
      and is_active = true
    order by version_number desc
    limit 1;
  else
    select id, template_code, version_number,
           template_data
    into v_template
    from catchmenu_hq.menu_templates
    where id = p_template_id
      and tenant_id = p_tenant_id;
  end if;

  -- 매장별 준수 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'store_id', s.id,
        'store_name', s.store_name,
        'last_distributed_at',
          dl.distributed_at,
        'distribution_version',
          dl.template_version,
        'is_latest_version',
          dl.template_version
            = v_template.version_number,
        'menus_created', dl.menus_created,
        'menus_updated', dl.menus_updated,
        'has_local_overrides',
          dl.has_local_overrides,
        'override_count', dl.override_count,
        'distribution_status',
          dl.distribution_status,
        'hq_menu_count', (
          select count(*)
          from catchmenu_pos.menus m
          where m.store_id = s.id
            and m.tenant_id = p_tenant_id
            and m.menu_code like 'HQ_'
              || v_template.template_code || '_%'
            and m.is_active = true
        ),
        'pending_overrides', (
          select count(*)
          from catchmenu_hq
            .franchise_approval_requests
          where from_store_id = s.id
            and request_type = 'MENU_EXCEPTION'
            and approval_status = 'PENDING'
        )
      )
      order by s.store_name
    ),
    '[]'::jsonb
  )
  into v_store_compliance
  from catchmenu_hq.store_group_members sgm
  join catchmenu_hq.stores s
    on s.id = sgm.store_id
  left join lateral (
    select *
    from catchmenu_hq.menu_distribution_log
    where store_id = s.id
      and template_id = v_template.id
    order by distributed_at desc
    limit 1
  ) dl on true
  where sgm.group_id = p_brand_id
    and sgm.tenant_id = p_tenant_id
    and sgm.is_active = true
    and s.is_active = true;

  -- 전체 요약
  select jsonb_build_object(
    'total_stores', count(*),
    'synced_stores', count(*) filter (
      where (c->>'distribution_status')
        = 'COMPLETED'
    ),
    'latest_version_stores', count(*) filter (
      where (c->>'is_latest_version')::boolean
    ),
    'stores_with_overrides', count(*) filter (
      where (c->>'has_local_overrides')::boolean
    ),
    'template_version',
      v_template.version_number,
    'template_code', v_template.template_code
  )
  into v_summary
  from jsonb_array_elements(
    v_store_compliance
  ) c;

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_compliance_loaded',
    p_data := jsonb_build_object(
      'brand', jsonb_build_object(
        'id', v_brand.id,
        'brand_code', v_brand.brand_code,
        'brand_name', v_brand.brand_name
      ),
      'template', case
        when v_template.id is not null
        then jsonb_build_object(
          'id', v_template.id,
          'template_code',
            v_template.template_code,
          'version_number',
            v_template.version_number
        )
        else null
      end,
      'summary', v_summary,
      'store_compliance', v_store_compliance
    ),
    p_locale := 'ko'
  );
end;
$$;


-- grants
do $$
begin
  revoke all on function
    catchmenu_hq.create_menu_template(
      uuid, uuid, text, text, jsonb,
      boolean, boolean, boolean, boolean,
      numeric, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.create_menu_template(
      uuid, uuid, text, text, jsonb,
      boolean, boolean, boolean, boolean,
      numeric, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.distribute_menu_to_stores(
      uuid, uuid, jsonb, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.distribute_menu_to_stores(
      uuid, uuid, jsonb, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.apply_menu_template(
      uuid, uuid, uuid, uuid, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.apply_menu_template(
      uuid, uuid, uuid, uuid, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.request_menu_override(
      uuid, uuid, uuid, text, text,
      jsonb, text, text, uuid, text
    ) from public;
  grant execute on function
    catchmenu_hq.request_menu_override(
      uuid, uuid, uuid, text, text,
      jsonb, text, text, uuid, text
    ) to authenticated;

  revoke all on function
    catchmenu_hq.get_menu_compliance_report(
      uuid, uuid, uuid
    ) from public;
  grant execute on function
    catchmenu_hq.get_menu_compliance_report(
      uuid, uuid, uuid
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_hq.distribute_menu_to_stores(
    uuid, uuid, jsonb, text, text, uuid, text
  ) is
  '본사 메뉴 템플릿 → 가맹점 배포.
   distribution_type:
   FULL_SYNC: 전체 동기화 (최초 배포).
   INCREMENTAL: 변경분만 (일상 업데이트).
   PRICE_ONLY: 가격만 배포.
   ROLLBACK: 이전 버전 복구.
   매장별 apply_menu_template() 호출.
   배포 결과 menu_distribution_log 기록.
   3차 Franchise_OS 메뉴 배포 기반.
   1-C차 완전 SaaS에서 자동화 배포 확장.';

comment on function
  catchmenu_hq.apply_menu_template(
    uuid, uuid, uuid, uuid, text, text, uuid, text
  ) is
  '단일 매장에 메뉴 템플릿 적용.
   메뉴 코드: HQ_{template_code}_{item_code}.
   가격 오버라이드:
     allows_price_override = true 이면
     max_price_override_pct 내 로컬 가격 유지.
   FULL_SYNC 시 템플릿에 없는 HQ 메뉴 비활성화.
   allows_local_remove = false:
     로컬 추가 메뉴는 유지 (삭제 안 함).
   3차 Franchise_OS + 1-C차 공통 모듈.';