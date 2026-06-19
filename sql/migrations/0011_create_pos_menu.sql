-- 0011_create_pos_menu.sql
-- Purpose: Menu catalog per store.
--          Includes categories, items, option groups, and option items.
--          Menu status affects KDS Late Binding availability check.
--          특허2: menu_available condition in KDS capacity check.
-- Depends on: 0002_create_hq_tenant_store.sql
-- Creates:
--   catchmenu_pos.menu_categories
--   catchmenu_pos.menus
--   catchmenu_pos.menu_option_groups
--   catchmenu_pos.menu_option_items

create table if not exists catchmenu_pos.menu_categories (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  parent_category_id uuid references catchmenu_pos.menu_categories(id),

  category_code text not null,
  category_name text not null,
  display_order int not null default 0,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_category_store_code
    unique (store_id, category_code)
);

create index if not exists idx_menu_categories_store
  on catchmenu_pos.menu_categories(store_id)
  where is_active = true;

create index if not exists idx_menu_categories_parent
  on catchmenu_pos.menu_categories(parent_category_id)
  where parent_category_id is not null;

drop trigger if exists trg_menu_categories_updated_at
  on catchmenu_pos.menu_categories;
create trigger trg_menu_categories_updated_at
  before update on catchmenu_pos.menu_categories
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menu_categories is
  'Menu category hierarchy per store.
   Supports parent-child nesting up to 2 levels.
   Used for kiosk and customer app display grouping.';


create table if not exists catchmenu_pos.menus (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  category_id uuid references catchmenu_pos.menu_categories(id),

  menu_code text not null,
  menu_name text not null,
  description text,
  price int not null default 0,
  image_url text,

  -- kitchen control
  menu_status text not null default 'AVAILABLE',
  is_kds_required boolean not null default true,
  kitchen_zone text,
  estimated_minutes int,

  -- KDS Late Binding capacity check
  -- 특허2: 메뉴별 조리 리드타임 기반 KDS 투입 시점 결정
  prep_complexity text not null default 'NORMAL',
  peak_time_restricted boolean not null default false,

  -- i18n
  menu_name_en text,
  menu_name_zh text,
  menu_name_ja text,
  allergen_info jsonb,

  display_order int not null default 0,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_menu_store_code unique (store_id, menu_code),
  constraint chk_menu_price check (price >= 0),
  constraint chk_menu_status check (
    menu_status in (
      'AVAILABLE',
      'SOLD_OUT',
      'HIDDEN',
      'DISCONTINUED'
    )
  ),
  constraint chk_menu_prep_complexity check (
    prep_complexity in (
      'SIMPLE',
      'NORMAL',
      'COMPLEX',
      'LONG_LEAD'
    )
  ),
  constraint chk_menu_estimated_minutes check (
    estimated_minutes is null or estimated_minutes > 0
  ),
  constraint chk_menu_allergen_object check (
    allergen_info is null
    or jsonb_typeof(allergen_info) = 'object'
  )
);

create index if not exists idx_menus_store_status
  on catchmenu_pos.menus(store_id, menu_status)
  where is_active = true;

create index if not exists idx_menus_category
  on catchmenu_pos.menus(category_id)
  where category_id is not null;

create index if not exists idx_menus_kitchen_zone
  on catchmenu_pos.menus(store_id, kitchen_zone)
  where kitchen_zone is not null
    and is_active = true;

create index if not exists idx_menus_kds_required
  on catchmenu_pos.menus(store_id, is_kds_required)
  where is_active = true;

drop trigger if exists trg_menus_updated_at
  on catchmenu_pos.menus;
create trigger trg_menus_updated_at
  before update on catchmenu_pos.menus
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menus is
  'Menu item master per store.
   menu_status feeds directly into KDS Late Binding availability check.
   estimated_minutes is used by KDS Capacity Agent to determine
   whether a pre-order can be committed to cooking queue.
   특허2: 메뉴별 조리 리드타임 기반 KDS Late Binding 조건 판단.';
comment on column catchmenu_pos.menus.menu_status is
  'AVAILABLE = orderable and kitchen-ready.
   SOLD_OUT = temporarily unavailable. Triggers KDS hold.
   HIDDEN = not shown to customers but can be ordered by staff.
   DISCONTINUED = permanently removed from menu.';
comment on column catchmenu_pos.menus.estimated_minutes is
  'Expected preparation time in minutes.
   Used by KDS Capacity Agent for Late Binding timing decision.
   특허2: 메뉴별 조리 리드타임 → KDS 투입 가능 시점 산출.';
comment on column catchmenu_pos.menus.prep_complexity is
  'SIMPLE = under 3 minutes, no special equipment.
   NORMAL = 3-10 minutes, standard kitchen flow.
   COMPLEX = 10-20 minutes, multiple station coordination.
   LONG_LEAD = over 20 minutes, must be pre-authorized by KDS agent.';
comment on column catchmenu_pos.menus.peak_time_restricted is
  'True = this menu is restricted during peak hours.
   KDS Capacity Agent will block pre-orders for this item
   when kitchen load exceeds threshold.
   특허2: 피크타임 또는 KDS 과부하 시 사전 주문 제한.';
comment on column catchmenu_pos.menus.allergen_info is
  'Structured allergen data per 특허1 i18n event 구조화.
   e.g. {"gluten": true, "dairy": false, "nuts": true, "shellfish": false}
   Displayed per customer locale. Evidence of display is recorded in audit ledger.';


create table if not exists catchmenu_pos.menu_option_groups (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  menu_id uuid not null references catchmenu_pos.menus(id),

  group_code text not null,
  group_name text not null,
  is_required boolean not null default false,
  min_select int not null default 0,
  max_select int not null default 1,
  display_order int not null default 0,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_option_group_menu_code unique (menu_id, group_code),
  constraint chk_option_group_select check (
    min_select >= 0
    and max_select >= 1
    and max_select >= min_select
  )
);

create index if not exists idx_option_groups_menu
  on catchmenu_pos.menu_option_groups(menu_id)
  where is_active = true;

drop trigger if exists trg_option_groups_updated_at
  on catchmenu_pos.menu_option_groups;
create trigger trg_option_groups_updated_at
  before update on catchmenu_pos.menu_option_groups
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menu_option_groups is
  'Option group per menu item.
   e.g. 사이즈 선택, 맵기 선택, 추가 토핑.
   min_select and max_select define selection constraints
   enforced at order submission time.';


create table if not exists catchmenu_pos.menu_option_items (
  id uuid primary key default gen_random_uuid(),
  tenant_id uuid not null references catchmenu_hq.tenants(id),
  store_id uuid not null references catchmenu_hq.stores(id),
  option_group_id uuid not null
    references catchmenu_pos.menu_option_groups(id),

  item_code text not null,
  item_name text not null,
  additional_price int not null default 0,
  display_order int not null default 0,
  is_active boolean not null default true,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  constraint uq_option_item_group_code unique (option_group_id, item_code),
  constraint chk_option_item_price check (additional_price >= 0)
);

create index if not exists idx_option_items_group
  on catchmenu_pos.menu_option_items(option_group_id)
  where is_active = true;

drop trigger if exists trg_option_items_updated_at
  on catchmenu_pos.menu_option_items;
create trigger trg_option_items_updated_at
  before update on catchmenu_pos.menu_option_items
  for each row execute function catchmenu_common.set_updated_at();

comment on table catchmenu_pos.menu_option_items is
  'Individual option choice within an option group.
   e.g. 소/중/대, 순한맛/보통/매운맛, 치즈추가.
   additional_price is added to base menu price at order time.
   Price snapshot is captured in order_items at order submission.';