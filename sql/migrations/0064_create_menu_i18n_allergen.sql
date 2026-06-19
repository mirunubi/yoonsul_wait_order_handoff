-- 0064_create_menu_i18n_allergen.sql
-- Purpose: Menu i18n extension and allergen display system.
--          menu_i18n: per-locale menu name/description.
--          allergen_codes: standardized allergen registry.
--          menu_allergen_display: customer-facing allergen info.
--          get_menu_catalog_i18n: i18n-aware menu catalog RPC.
--          특허1: 다국어 메뉴 표시 + 알레르겐 증빙 기록.
-- Depends on: 0063_patch_core_rpc_i18n_diagnostics.sql
-- Creates:
--   catchmenu_pos.menu_i18n (table)
--   catchmenu_pos.allergen_codes (table)
--   catchmenu_pos.menu_allergen_links (table)
--   function catchmenu_pos.upsert_menu_i18n(...)
--   function catchmenu_pos.get_menu_catalog_i18n(...)
--   function catchmenu_pos.record_allergen_display_evidence(...)

-- =============================================
-- allergen_codes table
-- =============================================
create table if not exists catchmenu_pos.allergen_codes (
  id uuid primary key default gen_random_uuid(),
  allergen_code text not null unique,
  display_order int not null default 0,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

comment on table catchmenu_pos.allergen_codes is
  '식품알레르기 표시 기준 (식품위생법 시행규칙 별표14).
   Korea Food Safety Law mandatory allergen codes.
   특허1: 알레르겐 표시 = 법적 의무 + 증빙 보관.';

-- 한국 식품알레르기 표시 대상 (22종)
insert into catchmenu_pos.allergen_codes (
  allergen_code, display_order
) values
('GLUTEN', 1),        -- 밀/보리/호밀 등 글루텐
('CRUSTACEAN', 2),    -- 갑각류 (새우, 게 등)
('EGG', 3),           -- 달걀
('FISH', 4),          -- 생선
('PEANUT', 5),        -- 땅콩
('SOYBEAN', 6),       -- 대두
('DAIRY', 7),         -- 우유
('TREE_NUT', 8),      -- 견과류 (호두, 잣 등)
('CELERY', 9),        -- 셀러리
('MUSTARD', 10),      -- 겨자
('SESAME', 11),       -- 참깨
('SULFITE', 12),      -- 아황산염
('LUPIN', 13),        -- 루핀
('MOLLUSC', 14),      -- 연체류 (굴, 홍합 등)
('PEACH', 15),        -- 복숭아
('TOMATO', 16),       -- 토마토
('CHICKEN', 17),      -- 닭고기
('PORK', 18),         -- 돼지고기
('BEEF', 19),         -- 쇠고기
('BUCKWHEAT', 20),    -- 메밀
('SQUID', 21),        -- 오징어
('ABALONE', 22)       -- 전복
on conflict (allergen_code) do nothing;


-- =============================================
-- allergen_codes i18n
-- =============================================
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
-- 알레르겐 이름 (ko)
('allergen.GLUTEN', 'ko', '글루텐'),
('allergen.CRUSTACEAN', 'ko', '갑각류'),
('allergen.EGG', 'ko', '달걀'),
('allergen.FISH', 'ko', '생선'),
('allergen.PEANUT', 'ko', '땅콩'),
('allergen.SOYBEAN', 'ko', '대두'),
('allergen.DAIRY', 'ko', '우유'),
('allergen.TREE_NUT', 'ko', '견과류'),
('allergen.SESAME', 'ko', '참깨'),
('allergen.SULFITE', 'ko', '아황산염'),
('allergen.LUPIN', 'ko', '루핀'),
('allergen.MOLLUSC', 'ko', '연체류'),
('allergen.PEACH', 'ko', '복숭아'),
('allergen.TOMATO', 'ko', '토마토'),
('allergen.CHICKEN', 'ko', '닭고기'),
('allergen.PORK', 'ko', '돼지고기'),
('allergen.BEEF', 'ko', '쇠고기'),
('allergen.BUCKWHEAT', 'ko', '메밀'),
('allergen.SQUID', 'ko', '오징어'),
('allergen.ABALONE', 'ko', '전복'),
-- 알레르겐 이름 (en)
('allergen.GLUTEN', 'en', 'Gluten'),
('allergen.CRUSTACEAN', 'en', 'Crustacean'),
('allergen.EGG', 'en', 'Egg'),
('allergen.FISH', 'en', 'Fish'),
('allergen.PEANUT', 'en', 'Peanut'),
('allergen.SOYBEAN', 'en', 'Soybean'),
('allergen.DAIRY', 'en', 'Dairy'),
('allergen.TREE_NUT', 'en', 'Tree Nut'),
('allergen.SESAME', 'en', 'Sesame'),
('allergen.SULFITE', 'en', 'Sulfite'),
('allergen.LUPIN', 'en', 'Lupin'),
('allergen.MOLLUSC', 'en', 'Mollusc'),
('allergen.PEACH', 'en', 'Peach'),
('allergen.TOMATO', 'en', 'Tomato'),
('allergen.CHICKEN', 'en', 'Chicken'),
('allergen.PORK', 'en', 'Pork'),
('allergen.BEEF', 'en', 'Beef'),
('allergen.BUCKWHEAT', 'en', 'Buckwheat'),
('allergen.SQUID', 'en', 'Squid'),
('allergen.ABALONE', 'en', 'Abalone'),
-- 알레르겐 이름 (zh)
('allergen.GLUTEN', 'zh', '麸质'),
('allergen.CRUSTACEAN', 'zh', '甲壳类'),
('allergen.EGG', 'zh', '鸡蛋'),
('allergen.FISH', 'zh', '鱼'),
('allergen.PEANUT', 'zh', '花生'),
('allergen.SOYBEAN', 'zh', '大豆'),
('allergen.DAIRY', 'zh', '乳制品'),
('allergen.TREE_NUT', 'zh', '坚果'),
('allergen.SESAME', 'zh', '芝麻'),
('allergen.BEEF', 'zh', '牛肉'),
('allergen.PORK', 'zh', '猪肉'),
('allergen.CHICKEN', 'zh', '鸡肉'),
-- 알레르겐 이름 (ja)
('allergen.GLUTEN', 'ja', 'グルテン'),
('allergen.CRUSTACEAN', 'ja', '甲殻類'),
('allergen.EGG', 'ja', '卵'),
('allergen.FISH', 'ja', '魚'),
('allergen.PEANUT', 'ja', 'ピーナッツ'),
('allergen.SOYBEAN', 'ja', '大豆'),
('allergen.DAIRY', 'ja', '乳製品'),
('allergen.TREE_NUT', 'ja', 'ナッツ類'),
('allergen.SESAME', 'ja', 'ごま'),
('allergen.BEEF', 'ja', '牛肉'),
('allergen.PORK', 'ja', '豚肉'),
('allergen.CHICKEN', 'ja', '鶏肉'),
-- 알레르겐 고지 문구 (법적 안내)
('allergen_notice', 'ko',
  '알레르기 유발 성분: {allergens}'),
('allergen_notice', 'en',
  'Contains allergens: {allergens}'),
('allergen_notice', 'zh',
  '含有过敏原: {allergens}'),
('allergen_notice', 'ja',
  'アレルゲン含有: {allergens}'),
('allergen_none', 'ko',
  '주요 알레르기 유발 성분 없음'),
('allergen_none', 'en',
  'No major allergens'),
('allergen_none', 'zh', '不含主要过敏原'),
('allergen_none', 'ja', '主なアレルゲンなし'),
('allergen_consult_staff', 'ko',
  '알레르기가 있으신 분은 직원에게 문의해 주세요'),
('allergen_consult_staff', 'en',
  'If you have allergies, please consult staff'),
('allergen_consult_staff', 'zh',
  '如有过敏，请咨询工作人员'),
('allergen_consult_staff', 'ja',
  'アレルギーをお持ちの方はスタッフにお申し付けください')
on conflict (message_key, locale) do nothing;


-- =============================================
-- menu_i18n table
-- =============================================
create table if not exists catchmenu_pos.menu_i18n (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  menu_id uuid not null
    references catchmenu_pos.menus(id),

  locale text not null,
  menu_name text not null,
  description text,
  short_description text,
  ingredients_note text,

  -- SEO / search tags
  search_tags jsonb default '[]'::jsonb,

  is_machine_translated boolean not null default false,
  reviewed_by uuid,
  reviewed_at timestamptz,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_i18n unique (menu_id, locale),
  constraint chk_locale check (
    locale in ('ko', 'en', 'zh', 'ja', 'vi', 'th')
  )
);

create index if not exists idx_menu_i18n_menu
  on catchmenu_pos.menu_i18n(menu_id, locale);
create index if not exists idx_menu_i18n_store
  on catchmenu_pos.menu_i18n(store_id, locale);

alter table catchmenu_pos.menu_i18n
  enable row level security;
alter table catchmenu_pos.menu_i18n
  force row level security;

drop policy if exists menu_i18n_isolation
  on catchmenu_pos.menu_i18n;
create policy menu_i18n_isolation
  on catchmenu_pos.menu_i18n
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_menu_i18n_updated_at
  on catchmenu_pos.menu_i18n;
create trigger trg_menu_i18n_updated_at
  before update on catchmenu_pos.menu_i18n
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menu_i18n is
  'Per-locale menu name and description.
   Supports ko/en/zh/ja/vi/th.
   is_machine_translated: flags for human review.
   reviewed_by/at: translation quality control.
   특허1: 다국어 메뉴 표시 — 키오스크/앱/배달앱 공통 소스.';


-- =============================================
-- menu_allergen_links table
-- =============================================
create table if not exists
  catchmenu_pos.menu_allergen_links (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null
    references catchmenu_hq.tenants(id),
  store_id uuid not null
    references catchmenu_hq.stores(id),
  menu_id uuid not null
    references catchmenu_pos.menus(id),
  allergen_code text not null
    references catchmenu_pos.allergen_codes(allergen_code),

  -- 함유/미함유/추적불가
  contains_status text not null default 'CONTAINS',
  contains_note text,

  -- 법적 표시 여부
  legally_required boolean not null default true,
  last_verified_at timestamptz,
  verified_by uuid,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_allergen unique (
    menu_id, allergen_code
  ),
  constraint chk_contains_status check (
    contains_status in (
      'CONTAINS', 'MAY_CONTAIN', 'NOT_PRESENT'
    )
  )
);

create index if not exists idx_menu_allergen_menu
  on catchmenu_pos.menu_allergen_links(menu_id);
create index if not exists idx_menu_allergen_store
  on catchmenu_pos.menu_allergen_links(
    store_id, allergen_code
  );

alter table catchmenu_pos.menu_allergen_links
  enable row level security;
alter table catchmenu_pos.menu_allergen_links
  force row level security;

drop policy if exists menu_allergen_isolation
  on catchmenu_pos.menu_allergen_links;
create policy menu_allergen_isolation
  on catchmenu_pos.menu_allergen_links
  for all to authenticated
  using (
    tenant_id = catchmenu_common.current_tenant_id()
    and store_id = catchmenu_common.current_store_id()
  );

drop trigger if exists trg_menu_allergen_updated_at
  on catchmenu_pos.menu_allergen_links;
create trigger trg_menu_allergen_updated_at
  before update on catchmenu_pos.menu_allergen_links
  for each row execute function
    catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menu_allergen_links is
  'Menu-allergen relationship with contains_status.
   CONTAINS: 해당 알레르겐 함유.
   MAY_CONTAIN: 동일 시설 제조로 교차오염 가능.
   NOT_PRESENT: 알레르겐 없음.
   legally_required: 식품위생법 표시 의무 대상.
   특허1: 알레르겐 표시 = 법적 의무 + 고객 안내 증빙.';


-- =============================================
-- RPCs
-- =============================================
create or replace function catchmenu_pos.upsert_menu_i18n(
  p_tenant_id uuid,
  p_store_id uuid,
  p_menu_id uuid,
  p_locale text,
  p_menu_name text,
  p_description text default null,
  p_short_description text default null,
  p_ingredients_note text default null,
  p_is_machine_translated boolean default false,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common
as $$
declare
  v_i18n_id uuid;
  v_is_new boolean;
begin
  if p_locale not in (
    'ko', 'en', 'zh', 'ja', 'vi', 'th'
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := 'ko',
      p_params := jsonb_build_object(
        'field', 'locale',
        'value', p_locale,
        'allowed', 'ko, en, zh, ja, vi, th'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_menu_i18n',
      p_correlation_id := p_correlation_id
    );
  end if;

  if trim(coalesce(p_menu_name, '')) = '' then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_input',
      p_locale := p_locale,
      p_params := jsonb_build_object(
        'field', 'menu_name'
      ),
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_menu_i18n',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- validate menu exists
  if not exists (
    select 1 from catchmenu_pos.menus
    where id = p_menu_id
      and store_id = p_store_id
      and tenant_id = p_tenant_id
      and is_active = true
  ) then
    return catchmenu_common.build_error_response(
      p_error_key := 'menu_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'upsert_menu_i18n',
      p_correlation_id := p_correlation_id
    );
  end if;

  -- check existing
  v_is_new := not exists (
    select 1 from catchmenu_pos.menu_i18n
    where menu_id = p_menu_id
      and locale = p_locale
  );

  insert into catchmenu_pos.menu_i18n (
    tenant_id, store_id, menu_id,
    locale, menu_name, description,
    short_description, ingredients_note,
    is_machine_translated
  ) values (
    p_tenant_id, p_store_id, p_menu_id,
    p_locale, p_menu_name, p_description,
    p_short_description, p_ingredients_note,
    p_is_machine_translated
  )
  on conflict (menu_id, locale) do update set
    menu_name = excluded.menu_name,
    description = excluded.description,
    short_description = excluded.short_description,
    ingredients_note = excluded.ingredients_note,
    is_machine_translated =
      excluded.is_machine_translated,
    reviewed_by = case
      when not excluded.is_machine_translated
      then p_actor_id
      else catchmenu_pos.menu_i18n.reviewed_by
    end,
    reviewed_at = case
      when not excluded.is_machine_translated
      then now()
      else catchmenu_pos.menu_i18n.reviewed_at
    end,
    updated_at = now()
  returning id into v_i18n_id;

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'i18n_id', v_i18n_id,
      'menu_id', p_menu_id,
      'locale', p_locale,
      'menu_name', p_menu_name,
      'is_new', v_is_new,
      'is_machine_translated', p_is_machine_translated
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;


create or replace function catchmenu_pos.get_menu_catalog_i18n(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko',
  p_include_hidden boolean default false,
  p_include_sold_out boolean default true,
  p_include_allergens boolean default true,
  p_customer_allergen_profile jsonb default null
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
  v_categories jsonb;
  v_menus jsonb;
  v_locale_fallback text;
begin
  -- locale validation
  if p_locale not in (
    'ko', 'en', 'zh', 'ja', 'vi', 'th'
  ) then
    p_locale := 'ko';
  end if;

  -- fallback locale
  v_locale_fallback := case p_locale
    when 'ko' then 'en'
    when 'en' then 'ko'
    else 'en'
  end;

  select id, store_name, timezone
  into v_store
  from catchmenu_hq.stores
  where id = p_store_id
    and tenant_id = p_tenant_id
    and is_active = true;

  if v_store.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'store_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_menu_catalog_i18n'
    );
  end if;

  -- categories with i18n
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'category_code', c.category_code,
        'category_name', c.category_name,
        'parent_category_id', c.parent_category_id,
        'display_order', c.display_order
      )
      order by c.display_order, c.category_name
    ),
    '[]'::jsonb
  )
  into v_categories
  from catchmenu_pos.menu_categories c
  where c.store_id = p_store_id
    and c.tenant_id = p_tenant_id
    and c.is_active = true;

  -- menus with i18n + allergens
  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'id', m.id,
        'category_id', m.category_id,
        'menu_code', m.menu_code,

        -- i18n name with fallback chain
        'menu_name', coalesce(
          mi_req.menu_name,
          mi_fallback.menu_name,
          mi_ko.menu_name,
          m.menu_name
        ),
        'description', coalesce(
          mi_req.description,
          mi_fallback.description,
          mi_ko.description,
          m.description
        ),
        'short_description', coalesce(
          mi_req.short_description,
          mi_fallback.short_description,
          mi_ko.short_description
        ),
        'ingredients_note', coalesce(
          mi_req.ingredients_note,
          mi_fallback.ingredients_note,
          mi_ko.ingredients_note
        ),
        'is_translated',
          mi_req.id is not null,
        'is_machine_translated', coalesce(
          mi_req.is_machine_translated, false
        ),

        -- original Korean name always included
        'menu_name_original', m.menu_name,

        'price', m.price,
        'image_url', m.image_url,
        'menu_status', m.menu_status,
        'is_kds_required', m.is_kds_required,
        'estimated_minutes', m.estimated_minutes,
        'display_order', m.display_order,

        -- allergen info (i18n)
        'allergens', case
          when p_include_allergens then (
            select coalesce(
              jsonb_agg(
                jsonb_build_object(
                  'allergen_code', mal.allergen_code,
                  'allergen_name',
                    catchmenu_common.get_message(
                      'allergen.' || mal.allergen_code,
                      p_locale, null
                    ),
                  'contains_status',
                    mal.contains_status,
                  'legally_required',
                    mal.legally_required
                )
                order by ac.display_order
              ),
              '[]'::jsonb
            )
            from catchmenu_pos.menu_allergen_links mal
            join catchmenu_pos.allergen_codes ac
              on ac.allergen_code = mal.allergen_code
            where mal.menu_id = m.id
              and mal.contains_status in (
                'CONTAINS', 'MAY_CONTAIN'
              )
          )
          else null
        end,

        -- allergen warning for customer profile
        'customer_allergen_warning', case
          when p_customer_allergen_profile is not null
          then exists (
            select 1
            from catchmenu_pos.menu_allergen_links mal
            where mal.menu_id = m.id
              and mal.contains_status = 'CONTAINS'
              and (
                p_customer_allergen_profile
                  @> to_jsonb(mal.allergen_code)
              )
          )
          else null
        end,

        -- allergen notice text (i18n)
        'allergen_notice', case
          when p_include_allergens then (
            select case
              when count(*) = 0 then
                catchmenu_common.get_message(
                  'allergen_none', p_locale, null
                )
              else
                catchmenu_common.get_message(
                  'allergen_notice', p_locale,
                  jsonb_build_object(
                    'allergens',
                    string_agg(
                      catchmenu_common.get_message(
                        'allergen.' || mal.allergen_code,
                        p_locale, null
                      ),
                      ', '
                      order by ac.display_order
                    )
                  )
                )
            end
            from catchmenu_pos.menu_allergen_links mal
            join catchmenu_pos.allergen_codes ac
              on ac.allergen_code = mal.allergen_code
            where mal.menu_id = m.id
              and mal.contains_status = 'CONTAINS'
              and mal.legally_required = true
          )
          else null
        end,

        -- option groups with i18n
        'option_groups', (
          select coalesce(
            jsonb_agg(
              jsonb_build_object(
                'id', og.id,
                'group_code', og.group_code,
                'group_name', og.group_name,
                'is_required', og.is_required,
                'min_select', og.min_select,
                'max_select', og.max_select,
                'display_order', og.display_order,
                'items', (
                  select coalesce(
                    jsonb_agg(
                      jsonb_build_object(
                        'id', oi.id,
                        'item_code', oi.item_code,
                        'item_name', oi.item_name,
                        'additional_price',
                          oi.additional_price,
                        'display_order',
                          oi.display_order
                      )
                      order by oi.display_order
                    ),
                    '[]'::jsonb
                  )
                  from catchmenu_pos.menu_option_items oi
                  where oi.option_group_id = og.id
                    and oi.is_active = true
                )
              )
              order by og.display_order
            ),
            '[]'::jsonb
          )
          from catchmenu_pos.menu_option_groups og
          where og.menu_id = m.id
            and og.is_active = true
        )
      )
      order by m.display_order, m.menu_name
    ),
    '[]'::jsonb
  )
  into v_menus
  from catchmenu_pos.menus m
  -- i18n joins with fallback chain
  left join catchmenu_pos.menu_i18n mi_req
    on mi_req.menu_id = m.id
    and mi_req.locale = p_locale
  left join catchmenu_pos.menu_i18n mi_fallback
    on mi_fallback.menu_id = m.id
    and mi_fallback.locale = v_locale_fallback
  left join catchmenu_pos.menu_i18n mi_ko
    on mi_ko.menu_id = m.id
    and mi_ko.locale = 'ko'
  where m.store_id = p_store_id
    and m.tenant_id = p_tenant_id
    and m.is_active = true
    and (
      p_include_hidden = true
      or m.menu_status <> 'HIDDEN'
    )
    and (
      p_include_sold_out = true
      or m.menu_status = 'AVAILABLE'
    )
    and m.menu_status <> 'DISCONTINUED';

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'store', jsonb_build_object(
        'id', v_store.id,
        'store_name', v_store.store_name
      ),
      'locale', p_locale,
      'categories', v_categories,
      'menus', v_menus,
      'category_count',
        jsonb_array_length(v_categories),
      'menu_count', jsonb_array_length(v_menus),
      'allergen_included', p_include_allergens,
      'allergen_consult_notice',
        catchmenu_common.get_message(
          'allergen_consult_staff', p_locale, null
        ),
      'generated_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;


create or replace function
  catchmenu_pos.record_allergen_display_evidence(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_menu_ids jsonb,
  p_display_locale text,
  p_displayed_allergens jsonb,
  p_customer_confirmed boolean default false,
  p_display_channel text default 'KIOSK',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_agent,
                  catchmenu_ledger,
                  catchmenu_audit,
                  catchmenu_common,
                  catchmenu_hq
as $$
declare
  v_evidence_id uuid;
  v_audit_id uuid;
  v_business_day date;
  v_timezone text;
begin
  select timezone into v_timezone
  from catchmenu_hq.stores
  where id = p_store_id and tenant_id = p_tenant_id;

  v_business_day := (timezone(
    coalesce(v_timezone, 'Asia/Seoul'), now()
  ))::date;

  -- create evidence packet
  -- 특허1: 알레르겐 표시 증빙 = 식품위생법 대응
  insert into catchmenu_agent.evidence_packets (
    tenant_id, store_id,
    packet_type, packet_status, risk_level,
    subject_type, subject_id,
    order_id,
    customer_visible_message,
    actor_type,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'ALLERGEN_DISPLAY_EVIDENCE',
    'CREATED', 'NORMAL',
    'order', p_order_id,
    p_order_id,
    -- 표시된 알레르겐 정보를 증빙으로 저장
    jsonb_build_object(
      'display_locale', p_display_locale,
      'display_channel', p_display_channel,
      'displayed_at', now(),
      'menu_ids', p_menu_ids,
      'displayed_allergens', p_displayed_allergens,
      'customer_confirmed', p_customer_confirmed,
      'allergen_consult_notice',
        catchmenu_common.get_message(
          'allergen_consult_staff',
          p_display_locale, null
        )
    )::text,
    'SYSTEM',
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_evidence_id;

  -- ledger event
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, event_payload,
    order_id, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'order', 'allergen_info_displayed', 1,
    'order', p_order_id,
    null, 'ALLERGEN_DISPLAYED',
    'SYSTEM',
    jsonb_build_object(
      'display_locale', p_display_locale,
      'display_channel', p_display_channel,
      'menu_count',
        jsonb_array_length(
          coalesce(p_menu_ids, '[]'::jsonb)
        ),
      'allergen_count',
        jsonb_array_length(
          coalesce(p_displayed_allergens, '[]'::jsonb)
        ),
      'customer_confirmed', p_customer_confirmed,
      'evidence_id', v_evidence_id
    ),
    p_order_id, p_correlation_id,
    v_business_day, v_timezone, now()
  );

  -- audit record (법적 증빙)
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'order',
    p_audit_type := 'allergen_info_displayed',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'SYSTEM',
    p_actor_id := null,
    p_subject_type := 'order',
    p_subject_id := p_order_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'display_locale', p_display_locale,
      'display_channel', p_display_channel,
      'displayed_allergens', p_displayed_allergens,
      'customer_confirmed', p_customer_confirmed,
      'evidence_id', v_evidence_id
    ),
    p_evidence_packet_id := v_evidence_id,
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_business_day,
    p_business_timezone := v_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'session_created',
    p_data := jsonb_build_object(
      'evidence_id', v_evidence_id,
      'order_id', p_order_id,
      'display_locale', p_display_locale,
      'display_channel', p_display_channel,
      'allergen_count', jsonb_array_length(
        coalesce(p_displayed_allergens, '[]'::jsonb)
      ),
      'customer_confirmed', p_customer_confirmed,
      'audit_id', v_audit_id,
      'legal_compliance', true
    ),
    p_locale := p_display_locale,
    p_correlation_id := p_correlation_id
  );
end;
$$;

-- grants
do $$
begin
  grant select on catchmenu_pos.allergen_codes
    to authenticated;

  revoke all on function catchmenu_pos.upsert_menu_i18n(
    uuid, uuid, uuid, text, text, text, text,
    text, boolean, text, uuid, text
  ) from public;
  grant execute on function catchmenu_pos.upsert_menu_i18n(
    uuid, uuid, uuid, text, text, text, text,
    text, boolean, text, uuid, text
  ) to authenticated;

  revoke all on function catchmenu_pos.get_menu_catalog_i18n(
    uuid, uuid, text, boolean, boolean, boolean, jsonb
  ) from public;
  grant execute on function catchmenu_pos.get_menu_catalog_i18n(
    uuid, uuid, text, boolean, boolean, boolean, jsonb
  ) to authenticated;

  revoke all on function
    catchmenu_pos.record_allergen_display_evidence(
      uuid, uuid, uuid, jsonb, text, jsonb,
      boolean, text, text
    ) from public;
  grant execute on function
    catchmenu_pos.record_allergen_display_evidence(
      uuid, uuid, uuid, jsonb, text, jsonb,
      boolean, text, text
    ) to authenticated;
end;
$$;

comment on function catchmenu_pos.get_menu_catalog_i18n(
  uuid, uuid, text, boolean, boolean, boolean, jsonb
) is
  'i18n-aware menu catalog with allergen information.
   Locale fallback chain:
     requested locale → fallback locale → ko → original.
   Allergen display per menu:
     allergen_notice: localized legal notice text.
     customer_allergen_warning: true if menu contains
       allergen from customer profile.
   특허1: 다국어 메뉴 표시.
   고객 디바이스 locale에 맞는 메뉴판 자동 제공.
   알레르겐 표시: 식품위생법 의무 표시 자동 포함.';

comment on function
  catchmenu_pos.record_allergen_display_evidence(
    uuid, uuid, uuid, jsonb, text, jsonb,
    boolean, text, text
  ) is
  'Records evidence that allergen info was displayed.
   Creates evidence_packet + audit record.
   Used by kiosk and customer app order flow.
   customer_confirmed: customer acknowledged allergen notice.
   법적 근거: 식품위생법 시행규칙 별표14
   (알레르기 유발 물질 표시 의무).
   특허1: 알레르겐 표시 증빙 = 분쟁 시 법적 보호.
   표시 시각, 표시 내용, 고객 확인 여부 모두 기록.';