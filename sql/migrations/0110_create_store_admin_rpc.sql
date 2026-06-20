-- 0110_create_store_admin_rpc.sql
-- Purpose: Small store owner admin RPCs.
--          소형 매장 관리자 페이지용 RPC.
--          메뉴 등록/수정/품절 관리.
--          직원 등록/PIN 설정.
--          영업시간/휴무일 설정.
--          POS/배달앱 연동 설정.
--          i18n: 모든 메시지 = message_catalog 참조.
-- Depends on: 0109_create_network_handoff_fallback_rpc.sql
-- Creates:
--   function catchmenu_store.upsert_menu(...)
--   function catchmenu_store.set_menu_status(...)
--   function catchmenu_store.upsert_staff(...)
--   function catchmenu_store.set_store_hours(...)
--   function catchmenu_store.set_holiday(...)
--   function catchmenu_store.get_store_admin_dashboard(...)
--   function catchmenu_store.get_menu_admin_list(...)
--   function catchmenu_store.get_staff_admin_list(...)
--   function catchmenu_store.update_store_settings(...)
--   function catchmenu_store.setup_pos_integration(...)

-- =============================================
-- i18n 메시지 등록
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('menu_created', 'ko',
  '메뉴가 등록되었습니다'),
('menu_created', 'en',
  'Menu created'),
('menu_updated', 'ko',
  '메뉴가 수정되었습니다'),
('menu_updated', 'en',
  'Menu updated'),
('menu_status_changed', 'ko',
  '메뉴 상태가 변경되었습니다'),
('menu_status_changed', 'en',
  'Menu status changed'),
('staff_created', 'ko',
  '직원이 등록되었습니다'),
('staff_created', 'en',
  'Staff created'),
('staff_updated', 'ko',
  '직원 정보가 수정되었습니다'),
('staff_updated', 'en',
  'Staff updated'),
('staff_pin_changed', 'ko',
  '직원 PIN이 변경되었습니다'),
('staff_pin_changed', 'en',
  'Staff PIN changed'),
('store_hours_updated', 'ko',
  '영업시간이 업데이트되었습니다'),
('store_hours_updated', 'en',
  'Store hours updated'),
('holiday_set', 'ko',
  '휴무일이 설정되었습니다'),
('holiday_set', 'en',
  'Holiday set'),
('store_settings_updated', 'ko',
  '매장 설정이 업데이트되었습니다'),
('store_settings_updated', 'en',
  'Store settings updated'),
('pos_integration_setup', 'ko',
  'POS 연동이 설정되었습니다'),
('pos_integration_setup', 'en',
  'POS integration configured'),
('store_admin_dashboard_loaded', 'ko',
  '매장 관리자 대시보드가 로드되었습니다'),
('store_admin_dashboard_loaded', 'en',
  'Store admin dashboard loaded'),
('menu_admin_list_loaded', 'ko',
  '메뉴 목록이 로드되었습니다'),
('menu_admin_list_loaded', 'en',
  'Menu list loaded'),
('staff_admin_list_loaded', 'ko',
  '직원 목록이 로드되었습니다'),
('staff_admin_list_loaded', 'en',
  'Staff list loaded')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7040, 'menu_code_duplicate',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7041, 'staff_phone_duplicate',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7042, 'invalid_business_hours',
  'STORE', 'VALIDATION', 400, 'WARNING'),
(7043, 'pos_config_duplicate',
  'STORE', 'CONFLICT', 409, 'WARNING'),
(7044, 'owner_permission_required',
  'STORE', 'AUTHORIZATION', 403, 'WARNING')
on conflict (code) do nothing;


-- =============================================
-- store_business_hours table
-- 영업시간 관리
-- =============================================
create table if not exists
  catchmenu_store.store_business_hours (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  -- 요일 (0=일, 1=월, ..., 6=토)
  day_of_week int not null,
  is_open boolean not null default true,

  -- 영업시간
  open_time time,
  close_time time,
  break_start_time time,
  break_end_time time,

  -- 라스트오더
  last_order_time time,

  -- 배달 시간 (다를 경우)
  delivery_open_time time,
  delivery_close_time time,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_store_day unique (
    store_id, day_of_week
  ),
  constraint chk_day_of_week check (
    day_of_week between 0 and 6
  )
);

create index if not exists idx_store_hours
  on catchmenu_store.store_business_hours(
    store_id, day_of_week
  );

alter table catchmenu_store.store_business_hours
  enable row level security;
alter table catchmenu_store.store_business_hours
  force row level security;

drop policy if exists store_hours_isolation
  on catchmenu_store.store_business_hours;
create policy store_hours_isolation
  on catchmenu_store.store_business_hours
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

drop trigger if exists trg_store_hours_updated
  on catchmenu_store.store_business_hours;
create trigger trg_store_hours_updated
  before update on
    catchmenu_store.store_business_hours
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table
  catchmenu_store.store_business_hours is
  '매장 영업시간 설정.
   day_of_week: 0=일 1=월 2=화 3=수
                4=목 5=금 6=토.
   break_start/end: 브레이크 타임.
   last_order_time: 라스트오더.
   delivery_*: 배달 전용 시간대.
   pg_cron open_store/close_store 연동 예정.';


-- =============================================
-- store_holidays table
-- 휴무일 관리
-- =============================================
create table if not exists
  catchmenu_store.store_holidays (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),

  holiday_date date not null,
  holiday_type text not null default 'MANUAL',
  holiday_reason text,
  is_partial_close boolean not null default false,
  partial_open_time time,
  partial_close_time time,

  created_by uuid,
  created_at timestamptz not null default now(),

  constraint uq_store_holiday unique (
    store_id, holiday_date
  ),
  constraint chk_holiday_type check (
    holiday_type in (
      'MANUAL',      -- 수동 설정
      'NATIONAL',    -- 국경일
      'WEEKLY',      -- 정기 휴무
      'EMERGENCY'    -- 긴급 휴무
    )
  )
);

create index if not exists idx_store_holidays
  on catchmenu_store.store_holidays(
    store_id, holiday_date
  ) where holiday_date >= current_date;

alter table catchmenu_store.store_holidays
  enable row level security;
alter table catchmenu_store.store_holidays
  force row level security;

drop policy if exists store_holidays_isolation
  on catchmenu_store.store_holidays;
create policy store_holidays_isolation
  on catchmenu_store.store_holidays
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id =
      catchmenu_common.current_store_id()
  );

comment on table catchmenu_store.store_holidays is
  '매장 휴무일 관리.
   uq_store_holiday: 날짜별 중복 방지.
   is_partial_close: 부분 영업일
     (예: 오전만 영업).
   NATIONAL: 공휴일 자동 등록 (향후).
   pg_cron close_store 연동 예정.';


-- =============================================
-- RPCs
-- =============================================

-- -----------------------------------------------
-- 메뉴 관리
-- -----------------------------------------------
create or replace function
  catchmenu_store.upsert_menu(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid default null,
  p_category_code text default null,
  p_category_name_ko text default null,
  p_menu_code text default null,
  p_menu_name_ko text default null,
  p_menu_name_en text default null,
  p_menu_name_zh text default null,
  p_menu_name_ja text default null,
  p_price int default null,
  p_description_ko text default null,
  p_thumbnail_url text default null,
  p_is_kds_required boolean default true,
  p_kitchen_zone text default 'MAIN',
  p_display_order int default 0,
  p_allergen_codes jsonb default '[]'::jsonb,
  p_menu_options jsonb default '[]'::jsonb,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_category_id uuid;
  v_menu_id uuid;
  v_is_new boolean;
  v_old_price int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  -- 카테고리 upsert
  if p_category_code is not null then
    insert into catchmenu_pos.menu_categories (
      tenant_id, store_id,
      category_code, category_name,
      display_order
    ) values (
      p_tenant_id, p_store_id,
      p_category_code,
      coalesce(
        p_category_name_ko, p_category_code
      ),
      p_display_order
    )
    on conflict (store_id, category_code)
    do update set
      category_name = coalesce(
        excluded.category_name,
        catchmenu_pos.menu_categories
          .category_name
      ),
      updated_at = now()
    returning id into v_category_id;
  end if;

  -- 신규 vs 수정 판단
  v_is_new := p_menu_id is null;

  if not v_is_new then
    -- 기존 가격 조회 (가격 변경 감지)
    select price into v_old_price
    from catchmenu_pos.menus
    where id = p_menu_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    if v_old_price is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'menu_not_found',
        p_locale := p_locale,
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_rpc_name := 'upsert_menu'
      );
    end if;
  end if;

  -- 메뉴 코드 중복 확인 (신규 시)
  if v_is_new
    and p_menu_code is not null
    and exists (
      select 1 from catchmenu_pos.menus
      where store_id = p_store_id
        and tenant_id = p_tenant_id
        and menu_code = p_menu_code
    )
  then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_code_duplicate',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_menu'
    );
  end if;

  if v_is_new then
    -- 메뉴 코드 자동 생성
    declare
      v_auto_code text;
    begin
      v_auto_code := coalesce(
        p_menu_code,
        'MENU-' || lpad(
          (
            select coalesce(count(*), 0) + 1
            from catchmenu_pos.menus
            where store_id = p_store_id
              and tenant_id = p_tenant_id
          )::text, 4, '0'
        )
      );

      insert into catchmenu_pos.menus (
        tenant_id, store_id, category_id,
        menu_code, menu_name,
        menu_name_en, menu_name_zh,
        menu_name_ja,
        price, description,
        thumbnail_url,
        is_kds_required, kitchen_zone,
        display_order,
        allergen_codes, menu_options,
        menu_status, is_active
      ) values (
        p_tenant_id, p_store_id, v_category_id,
        v_auto_code,
        coalesce(p_menu_name_ko, v_auto_code),
        p_menu_name_en, p_menu_name_zh,
        p_menu_name_ja,
        coalesce(p_price, 0),
        p_description_ko,
        p_thumbnail_url,
        coalesce(p_is_kds_required, true),
        coalesce(p_kitchen_zone, 'MAIN'),
        coalesce(p_display_order, 0),
        coalesce(p_allergen_codes, '[]'::jsonb),
        coalesce(p_menu_options, '[]'::jsonb),
        'AVAILABLE', true
      )
      returning id into v_menu_id;
    end;

  else
    -- 메뉴 수정
    update catchmenu_pos.menus
    set
      category_id = coalesce(
        v_category_id, category_id
      ),
      menu_name = coalesce(
        p_menu_name_ko, menu_name
      ),
      menu_name_en = coalesce(
        p_menu_name_en, menu_name_en
      ),
      menu_name_zh = coalesce(
        p_menu_name_zh, menu_name_zh
      ),
      menu_name_ja = coalesce(
        p_menu_name_ja, menu_name_ja
      ),
      price = coalesce(p_price, price),
      description = coalesce(
        p_description_ko, description
      ),
      thumbnail_url = coalesce(
        p_thumbnail_url, thumbnail_url
      ),
      is_kds_required = coalesce(
        p_is_kds_required, is_kds_required
      ),
      kitchen_zone = coalesce(
        p_kitchen_zone, kitchen_zone
      ),
      display_order = coalesce(
        p_display_order, display_order
      ),
      allergen_codes = coalesce(
        p_allergen_codes, allergen_codes
      ),
      menu_options = coalesce(
        p_menu_options, menu_options
      ),
      updated_at = now()
    where id = p_menu_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    v_menu_id := p_menu_id;

    -- 가격 변경 이력
    if p_price is not null
      and p_price <> v_old_price
    then
      insert into catchmenu_ledger.events (
        tenant_id, store_id,
        event_domain, event_type, event_version,
        subject_type, subject_id,
        from_state, to_state,
        caused_by_type, caused_by_id,
        event_payload,
        business_day, business_timezone,
        occurred_at
      ) values (
        p_tenant_id, p_store_id,
        'menu', 'menu_price_changed', 1,
        'menu', v_menu_id,
        v_old_price::text, p_price::text,
        'STAFF', p_actor_id,
        jsonb_build_object(
          'old_price', v_old_price,
          'new_price', p_price,
          'menu_name', p_menu_name_ko
        ),
        v_business_day, 'Asia/Seoul', now()
      );
    end if;
  end if;

  -- Realtime 메뉴 변경 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'menu_updated',
    p_payload := jsonb_build_object(
      'menu_id', v_menu_id,
      'is_new', v_is_new,
      'menu_name', p_menu_name_ko
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := case v_is_new
      when true then 'menu_created'
      else 'menu_updated'
    end,
    p_data := jsonb_build_object(
      'menu_id', v_menu_id,
      'is_new', v_is_new,
      'category_id', v_category_id,
      'menu_name', p_menu_name_ko,
      'price', p_price,
      'price_changed',
        not v_is_new
        and p_price is not null
        and p_price <> coalesce(v_old_price, 0)
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.set_menu_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_ids jsonb,
  p_menu_status text,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_updated_count int;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  if p_menu_status not in (
    'AVAILABLE', 'SOLD_OUT',
    'HIDDEN', 'DISCONTINUED'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'menu_status',
        'value', p_menu_status
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'set_menu_status'
    );
  end if;

  -- 일괄 상태 변경
  update catchmenu_pos.menus
  set
    menu_status = p_menu_status,
    is_active = p_menu_status
      <> 'DISCONTINUED',
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and id = any(
      select (value::text)::uuid
      from jsonb_array_elements_text(
        p_menu_ids
      )
    );

  get diagnostics v_updated_count = row_count;

  -- Realtime 메뉴 상태 변경 알림
  -- (키오스크/고객 앱 즉시 반영)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'menu_status_changed',
    p_payload := jsonb_build_object(
      'menu_ids', p_menu_ids,
      'new_status', p_menu_status,
      'updated_count', v_updated_count,
      'updated_by', p_actor_id
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_status_changed',
    p_data := jsonb_build_object(
      'updated_count', v_updated_count,
      'new_status', p_menu_status,
      'menu_ids', p_menu_ids,
      'realtime_notified', true,
      'note', case p_menu_status
        when 'SOLD_OUT'
          then '고객 앱/키오스크 즉시 반영'
        when 'AVAILABLE'
          then '판매 재개'
        when 'HIDDEN'
          then '메뉴 숨김 (삭제 아님)'
        else '메뉴 종료'
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_menu_admin_list(
  p_tenant_id uuid,
  p_store_id uuid,
  p_category_code text default null,
  p_menu_status text default null,
  p_search_keyword text default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos,
                  catchmenu_common
as $$
declare
  v_menus jsonb;
  v_category_summary jsonb;
  v_total_count int;
  v_sold_out_count int;
begin
  -- 메뉴 목록
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'menu_id', m.id,
        'menu_code', m.menu_code,
        'category_id', m.category_id,
        'category_code', mc.category_code,
        'category_name', mc.category_name,
        'menu_name', m.menu_name,
        'menu_name_en', m.menu_name_en,
        'menu_name_zh', m.menu_name_zh,
        'menu_name_ja', m.menu_name_ja,
        'price', m.price,
        'menu_status', m.menu_status,
        'is_active', m.is_active,
        'is_kds_required', m.is_kds_required,
        'kitchen_zone', m.kitchen_zone,
        'display_order', m.display_order,
        'thumbnail_url', m.thumbnail_url,
        'allergen_codes', m.allergen_codes,
        'allergen_count',
          jsonb_array_length(
            coalesce(m.allergen_codes,
              '[]'::jsonb)
          ),
        'menu_options', m.menu_options,
        'pos_sync_at', m.pos_sync_at,
        'is_pos_synced',
          m.menu_code like 'OKPOS_%'
          or m.menu_code like 'TPOS_%'
      )
      order by
        mc.display_order asc,
        m.display_order asc,
        m.menu_name asc
    ),
    '[]'::jsonb
  )
  into v_menus
  from catchmenu_pos.menus m
  left join catchmenu_pos.menu_categories mc
    on mc.id = m.category_id
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and (
      p_category_code is null
      or mc.category_code = p_category_code
    )
    and (
      p_menu_status is null
      or m.menu_status = p_menu_status
    )
    and (
      p_search_keyword is null
      or m.menu_name ilike
        '%' || p_search_keyword || '%'
    );

  -- 카테고리별 요약
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'category_code', mc.category_code,
        'category_name', mc.category_name,
        'menu_count', count(m.id),
        'sold_out_count', count(m.id) filter (
          where m.menu_status = 'SOLD_OUT'
        ),
        'hidden_count', count(m.id) filter (
          where m.menu_status = 'HIDDEN'
        )
      )
      order by mc.display_order
    ),
    '[]'::jsonb
  )
  into v_category_summary
  from catchmenu_pos.menu_categories mc
  left join catchmenu_pos.menus m
    on m.category_id = mc.id
    and m.is_active = true
  where mc.store_id = p_store_id
    and mc.tenant_id = p_tenant_id
  group by mc.id, mc.category_code,
           mc.category_name, mc.display_order;

  -- 전체/품절 수
  select
    count(*),
    count(*) filter (
      where menu_status = 'SOLD_OUT'
    )
  into v_total_count, v_sold_out_count
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  return catchmenu_common.build_success_response(
    p_message_key := 'menu_admin_list_loaded',
    p_data := jsonb_build_object(
      'menus', v_menus,
      'menu_count',
        jsonb_array_length(v_menus),
      'total_active', v_total_count,
      'sold_out_count', v_sold_out_count,
      'categories', v_category_summary,
      'filters', jsonb_build_object(
        'category_code', p_category_code,
        'menu_status', p_menu_status,
        'search_keyword', p_search_keyword
      )
    ),
    p_locale := p_locale
  );
end;
$$;


-- -----------------------------------------------
-- 직원 관리
-- -----------------------------------------------
create or replace function
  catchmenu_store.upsert_staff(
  p_tenant_id uuid,
  p_store_id uuid,
  p_staff_id uuid default null,
  p_staff_name text default null,
  p_staff_role text default 'STAFF',
  p_pin_hash text default null,
  p_phone_hash text default null,
  p_allowed_features jsonb default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_result_id uuid;
  v_is_new boolean;
  v_business_day date;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;

  v_is_new := p_staff_id is null;

  -- 역할 검증
  if p_staff_role not in (
    'OWNER', 'MANAGER', 'STAFF',
    'KITCHEN', 'PART_TIME'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'staff_role',
        'value', p_staff_role
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_staff'
    );
  end if;

  if v_is_new then
    -- 신규 직원 등록
    insert into catchmenu_store.staff (
      tenant_id, store_id,
      staff_name, staff_role,
      pin_hash, phone_hash,
      allowed_features,
      staff_status
    ) values (
      p_tenant_id, p_store_id,
      coalesce(p_staff_name, '직원'),
      p_staff_role,
      p_pin_hash,
      p_phone_hash,
      coalesce(
        p_allowed_features,
        case p_staff_role
          when 'KITCHEN' then
            '["VIEW_KDS","UPDATE_KDS"]'::jsonb
          when 'PART_TIME' then
            '["VIEW_ORDERS","PLACE_ORDER"]'::jsonb
          when 'MANAGER' then
            '["ALL_EXCEPT_SETTINGS"]'::jsonb
          when 'OWNER' then
            '["ALL"]'::jsonb
          else
            '["VIEW_ORDERS","PLACE_ORDER",'
            || '"VIEW_KDS","UPDATE_KDS"]'::jsonb
        end
      ),
      'ACTIVE'
    )
    returning id into v_result_id;

  else
    -- 직원 정보 수정
    update catchmenu_store.staff
    set
      staff_name = coalesce(
        p_staff_name, staff_name
      ),
      staff_role = coalesce(
        p_staff_role, staff_role
      ),
      phone_hash = coalesce(
        p_phone_hash, phone_hash
      ),
      allowed_features = coalesce(
        p_allowed_features, allowed_features
      ),
      updated_at = now()
    where id = p_staff_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id;

    -- PIN 변경 (별도 처리)
    if p_pin_hash is not null then
      update catchmenu_store.staff
      set
        pin_hash = p_pin_hash,
        pin_changed_at = now(),
        updated_at = now()
      where id = p_staff_id
        and store_id = p_store_id
        and tenant_id = p_tenant_id;
    end if;

    v_result_id := p_staff_id;
  end if;

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
    p_tenant_id, p_store_id,
    'staff',
    case v_is_new
      when true then 'staff_created'
      else 'staff_updated'
    end,
    1,
    'staff', v_result_id,
    null, 'ACTIVE',
    'OWNER', p_actor_id,
    jsonb_build_object(
      'staff_name', p_staff_name,
      'staff_role', p_staff_role,
      'is_new', v_is_new,
      'pin_changed', p_pin_hash is not null
    ),
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := case
      when not v_is_new
        and p_pin_hash is not null
        and p_staff_name is null
        then 'staff_pin_changed'
      when v_is_new then 'staff_created'
      else 'staff_updated'
    end,
    p_data := jsonb_build_object(
      'staff_id', v_result_id,
      'is_new', v_is_new,
      'staff_name', p_staff_name,
      'staff_role', p_staff_role,
      'pin_changed', p_pin_hash is not null,
      'default_features_note', case v_is_new
        when true then
          '역할별 기본 권한이 설정되었습니다'
        else null
      end
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.get_staff_admin_list(
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
  v_staff_list jsonb;
  v_role_summary jsonb;
begin
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'staff_id', id,
        'staff_name', staff_name,
        'staff_role', staff_role,
        'staff_status', staff_status,
        'allowed_features', allowed_features,
        'has_pin', pin_hash is not null,
        'last_login_at', (
          select max(login_at)
          from catchmenu_common.auth_sessions
          where subject_id = s.id
            and session_type = 'STAFF'
        ),
        'created_at', created_at
      )
      order by
        case staff_role
          when 'OWNER' then 0
          when 'MANAGER' then 1
          when 'STAFF' then 2
          when 'KITCHEN' then 3
          else 4
        end,
        staff_name asc
    ),
    '[]'::jsonb
  )
  into v_staff_list
  from catchmenu_store.staff s
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_status <> 'DELETED';

  -- 역할별 요약
  select coalesce(
    jsonb_object_agg(
      staff_role, cnt
    ),
    '{}'::jsonb
  )
  into v_role_summary
  from (
    select staff_role, count(*)::int as cnt
    from catchmenu_store.staff
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and staff_status = 'ACTIVE'
    group by staff_role
  ) r;

  return catchmenu_common.build_success_response(
    p_message_key := 'staff_admin_list_loaded',
    p_data := jsonb_build_object(
      'staff_list', v_staff_list,
      'staff_count',
        jsonb_array_length(v_staff_list),
      'role_summary', v_role_summary,
      'role_guide', jsonb_build_object(
        'OWNER', '전체 권한',
        'MANAGER', '설정 제외 전체',
        'STAFF', '주문/KDS/대기',
        'KITCHEN', 'KDS만',
        'PART_TIME', '주문 보기/접수'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


-- -----------------------------------------------
-- 영업시간/휴무일 설정
-- -----------------------------------------------
create or replace function
  catchmenu_store.set_store_hours(
  p_tenant_id uuid,
  p_store_id uuid,
  p_hours jsonb,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_day jsonb;
  v_upserted_count int := 0;
begin
  -- 요일별 영업시간 일괄 upsert
  -- p_hours 예시:
  -- [{"day_of_week":1,"is_open":true,
  --   "open_time":"09:00","close_time":"22:00",
  --   "break_start_time":"15:00",
  --   "break_end_time":"17:00",
  --   "last_order_time":"21:30"}]

  for v_day in
    select * from jsonb_array_elements(p_hours)
  loop
    insert into
      catchmenu_store.store_business_hours (
      tenant_id, store_id,
      day_of_week, is_open,
      open_time, close_time,
      break_start_time, break_end_time,
      last_order_time,
      delivery_open_time, delivery_close_time
    ) values (
      p_tenant_id, p_store_id,
      (v_day->>'day_of_week')::int,
      coalesce(
        (v_day->>'is_open')::boolean, true
      ),
      (v_day->>'open_time')::time,
      (v_day->>'close_time')::time,
      (v_day->>'break_start_time')::time,
      (v_day->>'break_end_time')::time,
      (v_day->>'last_order_time')::time,
      (v_day->>'delivery_open_time')::time,
      (v_day->>'delivery_close_time')::time
    )
    on conflict (store_id, day_of_week)
    do update set
      is_open = excluded.is_open,
      open_time = excluded.open_time,
      close_time = excluded.close_time,
      break_start_time =
        excluded.break_start_time,
      break_end_time = excluded.break_end_time,
      last_order_time = excluded.last_order_time,
      delivery_open_time =
        excluded.delivery_open_time,
      delivery_close_time =
        excluded.delivery_close_time,
      updated_at = now();

    v_upserted_count := v_upserted_count + 1;
  end loop;

  return catchmenu_common.build_success_response(
    p_message_key := 'store_hours_updated',
    p_data := jsonb_build_object(
      'upserted_count', v_upserted_count,
      'day_names', jsonb_build_object(
        '0', '일요일', '1', '월요일',
        '2', '화요일', '3', '수요일',
        '4', '목요일', '5', '금요일',
        '6', '토요일'
      )
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_store.set_holiday(
  p_tenant_id uuid,
  p_store_id uuid,
  p_holiday_date date,
  p_holiday_type text default 'MANUAL',
  p_holiday_reason text default null,
  p_is_partial_close boolean default false,
  p_partial_open_time time default null,
  p_partial_close_time time default null,
  p_cancel_holiday boolean default false,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_holiday_id uuid;
begin
  -- 휴무 취소
  if p_cancel_holiday then
    delete from catchmenu_store.store_holidays
    where store_id = p_store_id
      and tenant_id = p_tenant_id
      and holiday_date = p_holiday_date;

    return catchmenu_common.build_success_response(
      p_message_key := 'holiday_set',
      p_data := jsonb_build_object(
        'holiday_date', p_holiday_date,
        'cancelled', true
      ),
      p_locale := p_locale
    );
  end if;

  -- 휴무 등록
  insert into catchmenu_store.store_holidays (
    tenant_id, store_id,
    holiday_date, holiday_type,
    holiday_reason,
    is_partial_close,
    partial_open_time, partial_close_time,
    created_by
  ) values (
    p_tenant_id, p_store_id,
    p_holiday_date, p_holiday_type,
    p_holiday_reason,
    p_is_partial_close,
    p_partial_open_time, p_partial_close_time,
    p_actor_id
  )
  on conflict (store_id, holiday_date)
  do update set
    holiday_type = excluded.holiday_type,
    holiday_reason = excluded.holiday_reason,
    is_partial_close = excluded.is_partial_close,
    partial_open_time = excluded.partial_open_time,
    partial_close_time = excluded.partial_close_time
  returning id into v_holiday_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'holiday_set',
    p_data := jsonb_build_object(
      'holiday_id', v_holiday_id,
      'holiday_date', p_holiday_date,
      'holiday_type', p_holiday_type,
      'holiday_reason', p_holiday_reason,
      'is_partial_close', p_is_partial_close
    ),
    p_locale := p_locale
  );
end;
$$;


-- -----------------------------------------------
-- 매장 설정 업데이트
-- -----------------------------------------------
create or replace function
  catchmenu_store.update_store_settings(
  p_tenant_id uuid,
  p_store_id uuid,
  p_waiting_enabled boolean default null,
  p_pre_order_enabled boolean default null,
  p_max_waiting_count int default null,
  p_kds_capacity_threshold_total int
    default null,
  p_min_order_amount int default null,
  p_did_refresh_interval_seconds int
    default null,
  p_receipt_print_enabled boolean default null,
  p_cash_receipt_auto boolean default null,
  p_actor_id uuid default null,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_store,
                  catchmenu_common
as $$
declare
  v_updated jsonb := '{}'::jsonb;
begin
  update catchmenu_store.store_settings
  set
    waiting_enabled = coalesce(
      p_waiting_enabled, waiting_enabled
    ),
    pre_order_enabled = coalesce(
      p_pre_order_enabled, pre_order_enabled
    ),
    max_waiting_count = coalesce(
      p_max_waiting_count, max_waiting_count
    ),
    kds_capacity_threshold_total = coalesce(
      p_kds_capacity_threshold_total,
      kds_capacity_threshold_total
    ),
    min_order_amount = coalesce(
      p_min_order_amount, min_order_amount
    ),
    did_refresh_interval_seconds = coalesce(
      p_did_refresh_interval_seconds,
      did_refresh_interval_seconds
    ),
    receipt_print_enabled = coalesce(
      p_receipt_print_enabled,
      receipt_print_enabled
    ),
    cash_receipt_auto = coalesce(
      p_cash_receipt_auto, cash_receipt_auto
    ),
    updated_at = now()
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 변경된 설정 추적
  if p_waiting_enabled is not null then
    v_updated := v_updated || jsonb_build_object(
      'waiting_enabled', p_waiting_enabled
    );
  end if;
  if p_pre_order_enabled is not null then
    v_updated := v_updated || jsonb_build_object(
      'pre_order_enabled', p_pre_order_enabled
    );
  end if;
  if p_max_waiting_count is not null then
    v_updated := v_updated || jsonb_build_object(
      'max_waiting_count', p_max_waiting_count
    );
  end if;
  if p_kds_capacity_threshold_total is not null
  then
    v_updated := v_updated || jsonb_build_object(
      'kds_capacity_threshold_total',
        p_kds_capacity_threshold_total
    );
  end if;

  -- Realtime 설정 변경 알림
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'STORE_MODE',
    p_event_type := 'store_settings_changed',
    p_payload := jsonb_build_object(
      'updated_settings', v_updated,
      'updated_by', p_actor_id
    )
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'store_settings_updated',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'updated_settings', v_updated,
      'realtime_notified', true
    ),
    p_locale := p_locale
  );
end;
$$;


-- -----------------------------------------------
-- POS 연동 설정
-- -----------------------------------------------
create or replace function
  catchmenu_store.setup_pos_integration(
  p_tenant_id uuid,
  p_store_id uuid,
  p_provider_code text,
  p_store_code text,
  p_api_endpoint text default null,
  p_api_key_hash text default null,
  p_pos_terminal_id text default null,
  p_is_active boolean default true,
  p_actor_id uuid default null,
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
  v_config_id uuid;
begin
  if p_provider_code not in (
    'OKPOS', 'TOSS_POS', 'TOSS_PAYMENTS',
    'NICE_VAN', 'KIS_VAN', 'BAEMIN',
    'YOGIYO', 'COUPANG_EATS'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'provider_code',
        'value', p_provider_code
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'setup_pos_integration'
    );
  end if;

  insert into
    catchmenu_integrations.pos_store_configs (
    tenant_id, store_id,
    provider_code, store_code,
    api_endpoint, api_key_hash,
    pos_terminal_id, is_active
  ) values (
    p_tenant_id, p_store_id,
    p_provider_code, p_store_code,
    p_api_endpoint, p_api_key_hash,
    p_pos_terminal_id, p_is_active
  )
  on conflict (store_id, provider_code)
  do update set
    store_code = excluded.store_code,
    api_endpoint = coalesce(
      excluded.api_endpoint,
      catchmenu_integrations.pos_store_configs
        .api_endpoint
    ),
    api_key_hash = coalesce(
      excluded.api_key_hash,
      catchmenu_integrations.pos_store_configs
        .api_key_hash
    ),
    pos_terminal_id = coalesce(
      excluded.pos_terminal_id,
      catchmenu_integrations.pos_store_configs
        .pos_terminal_id
    ),
    is_active = excluded.is_active,
    updated_at = now()
  returning id into v_config_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'pos_integration_setup',
    p_data := jsonb_build_object(
      'config_id', v_config_id,
      'provider_code', p_provider_code,
      'store_code', p_store_code,
      'is_active', p_is_active,
      'next_step', case p_provider_code
        when 'OKPOS' then
          'sync_okpos_menu() 호출하여 메뉴 동기화'
        when 'TOSS_POS' then
          'sync_toss_pos_menu() 호출하여 메뉴 동기화'
        when 'TOSS_PAYMENTS' then
          'initiate_toss_payment() 테스트 결제 권장'
        else
          '연동 테스트 권장'
      end
    ),
    p_locale := p_locale
  );
end;
$$;


-- -----------------------------------------------
-- 소형 매장 관리자 통합 대시보드
-- -----------------------------------------------
create or replace function
  catchmenu_store.get_store_admin_dashboard(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_store,
                  catchmenu_pos,
                  catchmenu_common,
                  catchmenu_integrations,
                  catchmenu_hq
as $$
declare
  v_store record;
  v_settings record;
  v_menu_summary jsonb;
  v_staff_summary jsonb;
  v_hours_today jsonb;
  v_upcoming_holidays jsonb;
  v_pos_configs jsonb;
  v_membership_config record;
  v_business_day date;
  v_day_of_week int;
begin
  v_business_day := (timezone(
    'Asia/Seoul', now()
  ))::date;
  v_day_of_week := extract(
    dow from v_business_day
  )::int;

  -- 매장 기본 정보
  select id, store_name, store_status,
         store_type, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id;

  -- 설정
  select store_mode, waiting_enabled,
         pre_order_enabled,
         max_waiting_count,
         kds_capacity_threshold_total,
         min_order_amount,
         receipt_print_enabled,
         cash_receipt_auto
  into v_settings
  from catchmenu_store.store_settings
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 메뉴 요약
  select jsonb_build_object(
    'total', count(*),
    'available', count(*) filter (
      where menu_status = 'AVAILABLE'
    ),
    'sold_out', count(*) filter (
      where menu_status = 'SOLD_OUT'
    ),
    'hidden', count(*) filter (
      where menu_status = 'HIDDEN'
    ),
    'no_allergen', count(*) filter (
      where jsonb_array_length(
        coalesce(allergen_codes, '[]'::jsonb)
      ) = 0
      and menu_status = 'AVAILABLE'
    ),
    'pos_synced', count(*) filter (
      where menu_code like 'OKPOS_%'
        or menu_code like 'TPOS_%'
    )
  )
  into v_menu_summary
  from catchmenu_pos.menus
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  -- 직원 요약
  select jsonb_build_object(
    'total', count(*),
    'active', count(*) filter (
      where staff_status = 'ACTIVE'
    ),
    'no_pin', count(*) filter (
      where pin_hash is null
        and staff_status = 'ACTIVE'
    )
  )
  into v_staff_summary
  from catchmenu_store.staff
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and staff_status <> 'DELETED';

  -- 오늘 영업시간
  select jsonb_build_object(
    'day_of_week', day_of_week,
    'is_open', is_open,
    'open_time', open_time,
    'close_time', close_time,
    'break_start_time', break_start_time,
    'break_end_time', break_end_time,
    'last_order_time', last_order_time
  )
  into v_hours_today
  from catchmenu_store.store_business_hours
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and day_of_week = v_day_of_week;

  -- 다가오는 휴무일 (7일 이내)
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'holiday_date', holiday_date,
        'holiday_type', holiday_type,
        'holiday_reason', holiday_reason,
        'is_partial_close', is_partial_close
      )
      order by holiday_date asc
    ),
    '[]'::jsonb
  )
  into v_upcoming_holidays
  from catchmenu_store.store_holidays
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and holiday_date
      between v_business_day
      and v_business_day + interval '7 days';

  -- POS 연동 현황
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'provider_code', provider_code,
        'store_code', store_code,
        'is_active', is_active,
        'last_heartbeat_at', last_heartbeat_at
      )
    ),
    '[]'::jsonb
  )
  into v_pos_configs
  from catchmenu_integrations.pos_store_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  -- 멤버십 설정
  select membership_mode, stamp_enabled,
         tier_enabled
  into v_membership_config
  from catchmenu_store.membership_configs
  where store_id = p_store_id
    and tenant_id = p_tenant_id;

  return catchmenu_common.build_success_response(
    p_message_key :=
      'store_admin_dashboard_loaded',
    p_data := jsonb_build_object(

      -- 매장 기본 정보
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name,
        'store_status', v_store.store_status,
        'store_type', v_store.store_type
      ),

      -- 운영 설정
      'settings', jsonb_build_object(
        'store_mode', coalesce(
          v_settings.store_mode, 'NORMAL'
        ),
        'waiting_enabled', coalesce(
          v_settings.waiting_enabled, true
        ),
        'pre_order_enabled', coalesce(
          v_settings.pre_order_enabled, true
        ),
        'max_waiting_count', coalesce(
          v_settings.max_waiting_count, 30
        ),
        'kds_threshold', coalesce(
          v_settings
            .kds_capacity_threshold_total, 30
        ),
        'min_order_amount', coalesce(
          v_settings.min_order_amount, 0
        ),
        'receipt_print_enabled', coalesce(
          v_settings.receipt_print_enabled, true
        ),
        'cash_receipt_auto', coalesce(
          v_settings.cash_receipt_auto, true
        )
      ),

      -- 메뉴 현황
      'menus', v_menu_summary,
      'menu_warning', case
        when (v_menu_summary->>'no_allergen')
          ::int > 0
        then jsonb_build_object(
          'type', 'allergen_missing',
          'count',
            v_menu_summary->>'no_allergen',
          'message',
            '알레르겐 미등록 메뉴가 있습니다 (식품위생법 위반 주의)'
        )
        else null
      end,

      -- 직원 현황
      'staff', v_staff_summary,
      'staff_warning', case
        when (v_staff_summary->>'no_pin')
          ::int > 0
        then jsonb_build_object(
          'type', 'pin_not_set',
          'count', v_staff_summary->>'no_pin',
          'message',
            'PIN 미설정 직원이 있습니다'
        )
        else null
      end,

      -- 영업시간
      'today_hours', v_hours_today,
      'upcoming_holidays', v_upcoming_holidays,

      -- 연동 현황
      'pos_integrations', v_pos_configs,

      -- 멤버십
      'membership', jsonb_build_object(
        'mode', coalesce(
          v_membership_config.membership_mode,
          'STANDALONE'
        ),
        'stamp_enabled', coalesce(
          v_membership_config.stamp_enabled,
          false
        ),
        'tier_enabled', coalesce(
          v_membership_config.tier_enabled,
          true
        )
      ),

      -- 빠른 액션
      'quick_actions', jsonb_build_array(
        jsonb_build_object(
          'action', 'set_sold_out',
          'label', '품절 처리',
          'rpc', 'set_menu_status'
        ),
        jsonb_build_object(
          'action', 'create_event',
          'label', '이벤트 등록',
          'rpc', 'create_cms_event'
        ),
        jsonb_build_object(
          'action', 'add_staff',
          'label', '직원 추가',
          'rpc', 'upsert_staff'
        ),
        jsonb_build_object(
          'action', 'set_holiday',
          'label', '휴무일 설정',
          'rpc', 'set_holiday'
        ),
        jsonb_build_object(
          'action', 'sync_menu',
          'label', 'POS 메뉴 동기화',
          'rpc', 'sync_okpos_menu'
        )
      ),

      'business_day', v_business_day,
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
    catchmenu_store.upsert_menu(
      uuid, uuid, uuid, text, text, text,
      text, text, text, text, int, text,
      text, boolean, text, int,
      jsonb, jsonb, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.set_menu_status(
      uuid, uuid, jsonb, text, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_menu_admin_list(
      uuid, uuid, text, text, text, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.upsert_staff(
      uuid, uuid, uuid, text, text, text,
      text, jsonb, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_staff_admin_list(
      uuid, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.set_store_hours(
      uuid, uuid, jsonb, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.set_holiday(
      uuid, uuid, date, text, text,
      boolean, time, time, boolean, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.update_store_settings(
      uuid, uuid, boolean, boolean, int,
      int, int, int, boolean, boolean, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.setup_pos_integration(
      uuid, uuid, text, text, text,
      text, text, boolean, uuid, text
    ) to authenticated;

  grant execute on function
    catchmenu_store.get_store_admin_dashboard(
      uuid, uuid, text
    ) to authenticated;
end;
$$;

comment on function
  catchmenu_store.get_store_admin_dashboard(
    uuid, uuid, text
  ) is
  '소형 매장 관리자 통합 대시보드.
   Flutter 직원 앱 설정 탭 메인 화면.

   포함 데이터:
   - 매장 기본 정보 + 운영 설정
   - 메뉴 현황 (품절/알레르겐 경고)
   - 직원 현황 (PIN 미설정 경고)
   - 오늘 영업시간
   - 7일 내 휴무일
   - POS/배달앱 연동 현황
   - 멤버십 설정
   - 빠른 액션 5개

   경고 시스템:
   allergen_missing → 식품위생법 위반 주의
   pin_not_set → 보안 취약 경고

   빠른 액션:
   품절처리/이벤트등록/직원추가/
   휴무설정/POS메뉴동기화

   1호점 업주가 매일 아침 확인하는 화면.';

comment on function
  catchmenu_store.upsert_menu(
    uuid, uuid, uuid, text, text, text,
    text, text, text, text, int, text,
    text, boolean, text, int,
    jsonb, jsonb, uuid, text
  ) is
  '메뉴 등록/수정 통합 함수.
   p_menu_id = null → 신규 등록
   p_menu_id 있음 → 수정

   자동 처리:
   - 카테고리 없으면 자동 생성
   - 메뉴 코드 없으면 자동 생성
   - 가격 변경 시 ledger event 기록
   - Realtime 전 디바이스 알림

   다국어:
   menu_name_ko/en/zh/ja 지원
   고객 앱 locale별 자동 표시

   알레르겐:
   allergen_codes: ["글루텐","우유",...] 형식
   등록 안 하면 → 관리자 대시보드 경고 표시.';