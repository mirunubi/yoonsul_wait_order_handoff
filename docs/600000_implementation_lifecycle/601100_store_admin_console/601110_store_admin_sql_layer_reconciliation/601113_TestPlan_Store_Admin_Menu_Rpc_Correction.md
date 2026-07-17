# 601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`store_admin_menu_rpc_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 4 implementation of `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §0-§6 only.

Document number check:

- `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` exists.
- `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` exists.
- `601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md` is the next TestPlan document number for this workpacket.
- `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` is the paired ChangeContract.

The target is the store-admin menu SQL layer in `sql/migrations/0110_create_store_admin_rpc.sql`. The implementation must preserve the public `upsert_menu()` contract while internally splitting the work into:

1. `upsert_menu_core()`
2. `sync_menu_option_groups_core()`
3. `sync_menu_option_items_core()`

The three-layer flow must run as one PostgreSQL transaction when called through public `upsert_menu()`.

## §1 Pre-flight checks

Run all checks before modifying or applying anything. If any Stop Condition in `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` is hit, stop and report.

### §1.1 Target functions exist

Confirm the 0110 target functions are present in source and live DB:

```sql
select
  n.nspname as schema_name,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as identity_arguments
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname in (
    'upsert_menu',
    'set_menu_status',
    'get_menu_admin_list',
    'get_store_admin_dashboard'
  )
order by p.proname, identity_arguments;
```

Expected:

- `catchmenu_store.upsert_menu(...)` exists.
- `catchmenu_store.set_menu_status(...)` exists.
- `catchmenu_store.get_menu_admin_list(...)` exists.
- `catchmenu_store.get_store_admin_dashboard(...)` exists.

### §1.2 Required relational option constraints exist

```sql
select conname, pg_get_constraintdef(oid) as constraint_def
from pg_constraint
where conname in (
  'uq_option_group_menu_code',
  'uq_option_item_group_code'
)
order by conname;
```

Expected:

- `uq_option_group_menu_code` enforces uniqueness for the group matching key: `menu_id + group_code`.
- `uq_option_item_group_code` enforces uniqueness for the item matching key: `option_group_id + item_code`.

If either constraint is missing, Stop Condition.

### §1.3 Required allergen object constraint exists

```sql
select conname, pg_get_constraintdef(oid) as constraint_def
from pg_constraint
where conname = 'chk_menu_allergen_object';
```

Expected:

- `chk_menu_allergen_object` exists.
- It requires `allergen_info` to be either null or a JSONB object.

If this constraint is missing or no longer describes the object contract, Stop Condition.

### §1.4 Actual menu and option columns

```sql
select table_schema, table_name, column_name, data_type, udt_name, is_nullable
from information_schema.columns
where table_schema = 'catchmenu_pos'
  and table_name in ('menus', 'menu_option_groups', 'menu_option_items')
order by table_name, ordinal_position;
```

Expected for this workpacket:

- `catchmenu_pos.menus.image_url` exists.
- `catchmenu_pos.menus.allergen_info` exists.
- `catchmenu_pos.menus.thumbnail_url` does not exist.
- `catchmenu_pos.menus.allergen_codes` does not exist.
- `catchmenu_pos.menus.menu_options` does not exist.
- `catchmenu_pos.menus.pos_sync_at` does not exist.
- `catchmenu_pos.menu_option_groups.menu_id`, `group_code`, `is_active` exist.
- `catchmenu_pos.menu_option_items.option_group_id`, `item_code`, `price_delta`, `is_active` exist.

**(2026-07-16 정정, Stage 4 재검증(2차) — Cursor+Codex 공통 발견)** This TestPlan follows the corrected Human-confirmed boundary for this workpacket (`601114_ChangeContract.md` §2.6): option item price writing uses `price_delta` (canonical). The pre-`0141` option-price column (named in `601112_Logic.md` §1.2 and `601114_ChangeContract.md` §2.6) is intentionally left untouched by this workpacket — it stays at its schema default/existing value. The resulting `catchmenu_pos.get_menu_catalog()` (`0044`) customer-facing read-path inconsistency (admin-edited `price_delta` not reflected in what `0044` returns to customers) is a known deferred item (`601112_Logic.md` §6 (a)), not something this TestPlan's tests need to fix.

## §2 Test A — `upsert_menu()` creates a new menu with option groups/items

### §2.1 Setup

Use a transaction and roll it back:

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-KIMBAP',
  p_category_name_ko := '테스트 김밥',
  p_menu_code := '__test_admin_menu_601113_new',
  p_menu_name_ko := '601113 신규 메뉴',
  p_menu_name_en := '601113 New Menu',
  p_menu_name_zh := null,
  p_menu_name_ja := null,
  p_price := 7000,
  p_description_ko := '601113 Test A',
  p_thumbnail_url := 'https://example.invalid/601113-new.png',
  p_is_kds_required := true,
  p_kitchen_zone := 'MAIN',
  p_display_order := 10,
  p_allergen_codes := '{"eggs": true, "milk": true}'::jsonb,
  p_menu_options := '[
    {
      "group_code": "EGG",
      "group_name": "계란 옵션",
      "min_select": 0,
      "max_select": 1,
      "display_order": 1,
      "items": [
        {
          "item_code": "ADD_EGG",
          "item_name": "계란 추가",
          "price_delta": 500,
          "display_order": 1
        },
        {
          "item_code": "NO_EGG",
          "item_name": "계란 제외",
          "price_delta": 0,
          "display_order": 2
        }
      ]
    }
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §2.2 Expected result

The call returns `success:true`.

Verify the stored menu row:

```sql
select
  menu_code,
  menu_name,
  image_url,
  allergen_info,
  jsonb_typeof(allergen_info) as allergen_type,
  menu_status,
  is_active
from catchmenu_pos.menus
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and menu_code = '__test_admin_menu_601113_new';
```

Expected:

- `image_url = 'https://example.invalid/601113-new.png'`
- `allergen_info = {"eggs": true, "milk": true}` or semantically equivalent JSONB object.
- `allergen_type = 'object'`
- no reference to physical `thumbnail_url`, `allergen_codes`, `menu_options`, or `pos_sync_at` columns is required.

Verify option groups/items:

```sql
select
  g.group_code,
  g.is_active as group_active,
  i.item_code,
  i.price_delta,
  i.is_active as item_active
from catchmenu_pos.menus m
join catchmenu_pos.menu_option_groups g on g.menu_id = m.id
join catchmenu_pos.menu_option_items i on i.option_group_id = g.id
where m.tenant_id = '<test_tenant_id>'::uuid
  and m.store_id = '<test_store_id>'::uuid
  and m.menu_code = '__test_admin_menu_601113_new'
order by g.group_code, i.item_code;
```

Expected:

- One active group: `EGG`.
- Two active items: `ADD_EGG`, `NO_EGG`.
- `price_delta` values match the input JSON. The pre-`0141` option-price column (§1.4/§11.2) is not asserted here — this workpacket does not write it.

Finish:

```sql
rollback;
```

## §3 Test B — existing menu update uses full replacement with soft deactivation

### §3.1 Setup

Within one transaction:

1. Create a menu with two groups (`GROUP_A`, `GROUP_B`) and multiple items, including a known `price_delta`.
2. Call `upsert_menu()` again for the same `p_menu_id`, with `GROUP_B` and one of `GROUP_A`'s previous items omitted, and `GROUP_A`'s remaining item's `price_delta` changed to a different value.

```sql
begin;

-- Step 1: create menu with GROUP_A (KEEP_ITEM, DROP_ITEM) and GROUP_B (B_ITEM).
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-KIMBAP',
  p_category_name_ko := '테스트 김밥',
  p_menu_code := '__test_admin_menu_601113_update',
  p_menu_name_ko := '601113 갱신 메뉴',
  p_price := 6000,
  p_thumbnail_url := 'https://example.invalid/601113-update.png',
  p_allergen_codes := '{}'::jsonb,
  p_menu_options := '[
    {
      "group_code": "GROUP_A",
      "group_name": "그룹 A",
      "min_select": 0,
      "max_select": 2,
      "display_order": 1,
      "items": [
        {"item_code": "KEEP_ITEM", "item_name": "유지 항목", "price_delta": 300, "display_order": 1},
        {"item_code": "DROP_ITEM", "item_name": "제거 항목", "price_delta": 100, "display_order": 2}
      ]
    },
    {
      "group_code": "GROUP_B",
      "group_name": "그룹 B",
      "min_select": 0,
      "max_select": 1,
      "display_order": 2,
      "items": [
        {"item_code": "B_ITEM", "item_name": "B 항목", "price_delta": 200, "display_order": 1}
      ]
    }
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id> from the result for use below.

-- Step 2: call upsert_menu() again for the same menu — GROUP_B and DROP_ITEM omitted,
-- KEEP_ITEM's price_delta changed from 300 to 450.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_menu_options := '[
    {
      "group_code": "GROUP_A",
      "group_name": "그룹 A",
      "min_select": 0,
      "max_select": 2,
      "display_order": 1,
      "items": [
        {"item_code": "KEEP_ITEM", "item_name": "유지 항목", "price_delta": 450, "display_order": 1}
      ]
    }
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §3.2 Expected result — full replacement semantics

```sql
select
  g.group_code,
  g.is_active as group_active,
  i.item_code,
  i.price_delta,
  i.is_active as item_active
from catchmenu_pos.menus m
left join catchmenu_pos.menu_option_groups g on g.menu_id = m.id
left join catchmenu_pos.menu_option_items i on i.option_group_id = g.id
where m.id = '<test_menu_id>'::uuid
order by g.group_code, i.item_code;
```

Expected:

- `GROUP_B` remains physically present but `group_active = false` (omitted from the second call's `p_menu_options`).
- `DROP_ITEM` remains physically present but `item_active = false` (omitted from `GROUP_A`'s second-call item list).
- `GROUP_A` and `KEEP_ITEM` are `group_active = true` / `item_active = true` (still present in the second call).
- No physical DELETE is used as the synchronization mechanism — row counts before and after are unchanged, only `is_active` flips.

### §3.3 Expected result — `price_delta` update, pre-`0141` column untouched (2026-07-17, Stage 6 Contract Verification finding)

```sql
select item_code, price_delta
from catchmenu_pos.menu_option_items
where option_group_id = (
  select id from catchmenu_pos.menu_option_groups
  where menu_id = '<test_menu_id>'::uuid and group_code = 'GROUP_A'
)
and item_code = 'KEEP_ITEM';
```

Expected:

- `price_delta = 450` — the second call's changed value was actually written to the live row, not just accepted by the RPC without persisting.
- The pre-`0141` option-price column on this same row (named in `601112_Logic.md` §1.2 / `601114_ChangeContract.md` §2.6) is unchanged from whatever value it held before Step 2 (this workpacket's `sync_menu_option_items_core()` must not include it in the `on conflict ... do update` clause — §2.6/§2.1 of the ChangeContract) — confirm this by reading that column's value immediately after Step 1 and again after Step 2 and asserting equality.

Finish:

```sql
rollback;
```

## §4 Test C — `get_menu_admin_list()` no longer crashes on phantom columns or allergen array assumption

### §4.1 Execute

```sql
select catchmenu_store.get_menu_admin_list(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_locale := 'ko'
);
```

### §4.2 Expected result

Expected:

- Function executes without errors related to `thumbnail_url`, `allergen_codes`, `menu_options`, or `pos_sync_at`.
- Returned menu JSON uses the real menu image/allergen fields.
- `allergen_info` is returned as a JSONB object.
- Any allergen count logic treats `allergen_info` as an object, not as an array. It must not call `jsonb_array_length()` on `allergen_info`.

Confirm the live function body:

```sql
select pg_get_functiondef('catchmenu_store.get_menu_admin_list(uuid, uuid, text)'::regprocedure);
```

Expected source evidence:

- no `m.thumbnail_url`
- no `m.allergen_codes`
- no `m.menu_options`
- no `m.pos_sync_at`
- no `jsonb_array_length(coalesce(m.allergen_info`

### §4.3 `option_groups` JSON structure verification (2026-07-17, Stage 6 Contract Verification finding)

§4.2 only asserted that the crash is gone — it did not verify the actual shape of the replacement `option_groups` structure (`601112_Logic.md` §3).

**(2026-07-17 정정, Stage 6 3차 검증 — Cursor 단독 발견)** This subsection originally reused the menu created in §2 (`__test_admin_menu_601113_new`) — but §2 rolls back at the end of its own `begin;...rollback;` block, so that row would already be gone by the time §4 runs. Every other test section in this TestPlan (§2, §3, §6, §7, §9) is a self-contained `begin;...rollback;` block that does not depend on another section's data still being present — moving §2's rollback later would break that isolation model and make §4 silently order-dependent on §2 having just run. §4.3 is corrected to match the established pattern instead: it creates its own menu independently.

#### §4.3.1 Setup

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-JSON-STRUCT',
  p_category_name_ko := 'JSON 구조 테스트',
  p_menu_code := '__test_admin_menu_601113_json_structure',
  p_menu_name_ko := '601113 JSON 구조 메뉴',
  p_price := 6500,
  p_menu_options := '[
    {
      "group_code": "EGG",
      "group_name": "계란 옵션",
      "min_select": 0,
      "max_select": 1,
      "display_order": 1,
      "items": [
        {"item_code": "ADD_EGG", "item_name": "계란 추가", "price_delta": 500, "display_order": 1},
        {"item_code": "NO_EGG", "item_name": "계란 제외", "price_delta": 0, "display_order": 2}
      ]
    }
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

#### §4.3.2 Expected result

```sql
select
  menu->>'menu_code' as menu_code,
  menu->'option_groups' as option_groups,
  jsonb_array_length(menu->'option_groups') as group_count,
  (menu->'option_groups'->0->>'group_code') as first_group_code,
  jsonb_array_length(menu->'option_groups'->0->'items') as first_group_item_count,
  (menu->'option_groups'->0->'items'->0 ? 'price_delta') as first_item_has_price_delta,
  (menu->'option_groups'->0->'items'->0->>'price_delta')::int as first_item_price_delta
from jsonb_array_elements(
  (catchmenu_store.get_menu_admin_list(
    p_tenant_id := '<test_tenant_id>'::uuid,
    p_store_id := '<test_store_id>'::uuid,
    p_locale := 'ko'
  )->'data'->'menus')
) as menu
where menu->>'menu_code' = '__test_admin_menu_601113_json_structure';
```

Expected:

- `option_groups` is present and is a JSON array (not `null`, not the removed `menu_options` phantom key).
- `group_count = 1` (`EGG`).
- `first_group_code = 'EGG'`.
- `first_group_item_count = 2` (`ADD_EGG`, `NO_EGG`) — confirms `items` is actually nested inside each group element, not a flat sibling array.
- `first_item_has_price_delta = true` — the `price_delta` key is present on the nested item object (`601112_Logic.md` §3's `jsonb_build_object` for items).
- `first_item_price_delta = 500` — `ADD_EGG` sorts first by `display_order`, matching this setup's input.

Finish:

```sql
rollback;
```

### §4.4 Slice 2 — `category_summary` edge cases (new 2026-07-17, per `601114_ChangeContract.md` §2.9)

`601114_ChangeContract.md` §2.9 authorizes a bounded fix to the pre-existing `aggregate function calls cannot be nested` crash in `get_menu_admin_list()`'s `category_summary` query. This subsection covers the minimum edge cases required before that fix can be trusted: zero categories, a category with zero menus, a category with exactly one menu, a category with a mix of normal/sold-out/hidden menus, and whether inactive menus are correctly excluded.

#### §4.4.1 Setup

```sql
begin;

-- Case: zero categories — <test_empty_store_id> is a fixture store/tenant pair
-- with no rows in catchmenu_pos.menu_categories at all (not the shared
-- <test_tenant_id>/<test_store_id> fixture, which already has categories
-- from other tests in this plan).

-- Case: category with zero menus.
insert into catchmenu_pos.menu_categories (tenant_id, store_id, category_code, category_name, display_order)
values ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'CAT_EMPTY', '빈 카테고리', 90)
returning id; -- record as <cat_empty_id>

-- Case: category with exactly one menu.
insert into catchmenu_pos.menu_categories (tenant_id, store_id, category_code, category_name, display_order)
values ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'CAT_ONE', '메뉴 1개 카테고리', 91)
returning id; -- record as <cat_one_id>

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'CAT_ONE', p_category_name_ko := '메뉴 1개 카테고리',
  p_menu_code := '__test_admin_menu_601113_cat_one', p_menu_name_ko := '카테고리 1개 메뉴',
  p_price := 3000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

-- Case: mixed AVAILABLE/SOLD_OUT/HIDDEN in one category.
insert into catchmenu_pos.menu_categories (tenant_id, store_id, category_code, category_name, display_order)
values ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'CAT_MIXED', '혼합 카테고리', 92)
returning id; -- record as <cat_mixed_id>

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'CAT_MIXED', p_category_name_ko := '혼합 카테고리',
  p_menu_code := '__test_admin_menu_601113_mixed_available', p_menu_name_ko := '혼합 정상 메뉴',
  p_price := 3000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
); -- default menu_status = 'AVAILABLE'

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'CAT_MIXED', p_category_name_ko := '혼합 카테고리',
  p_menu_code := '__test_admin_menu_601113_mixed_soldout', p_menu_name_ko := '혼합 품절 메뉴',
  p_price := 3000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);
-- then transition the above menu to SOLD_OUT via set_menu_status()
-- (record its <menu_id> from the upsert_menu() result first)
select catchmenu_store.set_menu_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<mixed_soldout_menu_id>'::uuid, p_menu_status := 'SOLD_OUT',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'CAT_MIXED', p_category_name_ko := '혼합 카테고리',
  p_menu_code := '__test_admin_menu_601113_mixed_hidden', p_menu_name_ko := '혼합 숨김 메뉴',
  p_price := 3000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);
-- then transition the above menu to HIDDEN via set_menu_status(), same pattern as SOLD_OUT above.
select catchmenu_store.set_menu_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<mixed_hidden_menu_id>'::uuid, p_menu_status := 'HIDDEN',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

-- Case: inactive menu must be excluded from menu_count.
insert into catchmenu_pos.menu_categories (tenant_id, store_id, category_code, category_name, display_order)
values ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'CAT_INACTIVE', '비활성 포함 카테고리', 93)
returning id; -- record as <cat_inactive_id>

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'CAT_INACTIVE', p_category_name_ko := '비활성 포함 카테고리',
  p_menu_code := '__test_admin_menu_601113_inactive_active', p_menu_name_ko := '활성 메뉴',
  p_price := 3000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

-- Directly flip a second menu's is_active to false — no public RPC does this
-- for menus (unlike dining_tables' deactivate pattern); this test flips it
-- directly against the table for setup purposes only.
insert into catchmenu_pos.menus (tenant_id, store_id, category_id, menu_code, menu_name, price, menu_status, is_active)
values ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '<cat_inactive_id>'::uuid, '__test_admin_menu_601113_inactive_deleted', '비활성 메뉴', 3000, 'AVAILABLE', false);
```

#### §4.4.2 Expected result

```sql
select
  cat->>'category_code' as category_code,
  (cat->>'menu_count')::int as menu_count,
  (cat->>'sold_out_count')::int as sold_out_count,
  (cat->>'hidden_count')::int as hidden_count
from jsonb_array_elements(
  (catchmenu_store.get_menu_admin_list(
    p_tenant_id := '<test_tenant_id>'::uuid,
    p_store_id := '<test_store_id>'::uuid,
    p_locale := 'ko'
  )->'data'->'categories')
) as cat
where cat->>'category_code' in ('CAT_EMPTY', 'CAT_ONE', 'CAT_MIXED', 'CAT_INACTIVE')
order by cat->>'category_code';

-- Separately, for the zero-categories case:
select catchmenu_store.get_menu_admin_list(
  p_tenant_id := '<test_empty_store_id>'::uuid,
  p_store_id := '<test_empty_store_id>'::uuid,
  p_locale := 'ko'
)->'data'->'categories';
```

Expected (no crash for any case — the primary regression this Slice 2 fix targets):

- **Zero categories**: `categories` is `[]` (empty JSON array), not `null`, not an error.
- **`CAT_EMPTY`** (category with zero menus): row is present in the result (the `LEFT JOIN` includes categories with no matching menus); `menu_count = 0`, `sold_out_count = 0`, `hidden_count = 0`.
- **`CAT_ONE`** (exactly one menu): `menu_count = 1`, `sold_out_count = 0`, `hidden_count = 0`.
- **`CAT_MIXED`** (one `AVAILABLE` + one `SOLD_OUT` + one `HIDDEN`): `menu_count = 3` (all active menus regardless of status), `sold_out_count = 1`, `hidden_count = 1`.
- **`CAT_INACTIVE`** (one active menu + one `is_active=false` menu): `menu_count = 1` — the inactive menu is excluded (per the `and m.is_active = true` JOIN condition, which §2.9 does not change).
- Returned JSON key names (`category_code`/`category_name`/`menu_count`/`sold_out_count`/`hidden_count`) and the `categories` array shape are unchanged from what §2.9 documents as the original (broken) query's intended structure.

Finish:

```sql
rollback;
```

## §5 Test D — `get_store_admin_dashboard()` no longer crashes on shared `allergen_codes` defect

### §5.1 Execute

```sql
select catchmenu_store.get_store_admin_dashboard(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_locale := 'ko'
);
```

### §5.2 Expected result

Expected:

- Function executes without `allergen_codes` errors.
- Menu summary logic treats `allergen_info` as an object, not as an array.
- Function body no longer references `allergen_codes`.

Confirm the live function body:

```sql
select pg_get_functiondef('catchmenu_store.get_store_admin_dashboard(uuid, uuid, text)'::regprocedure);
```

Expected source evidence:

- no `allergen_codes`
- no `jsonb_array_length(coalesce(allergen_info`

## §6 Test E — transaction atomicity across the three core layers

### §6.1 Execute

**(2026-07-17 정정, Human 결정 — Claude Code가 Stage 9 독립 검증에서 확인)** This test previously used "an option item without `item_code`" as the deliberate failure trigger. That no longer produces a failure: `sync_menu_option_items_core()` has a defensive `if coalesce(v_item->>'item_code', '') = '' then continue;` guard that silently *skips* such an item instead of raising an error — confirmed live (the call returns `success:true`, the group is created with zero items). The technique below uses a genuine, still-reproducible failure instead: a non-numeric `price_delta` value, which fails the `(v_item->>'price_delta')::int` cast inside `sync_menu_option_items_core()` with a real, unhandled `invalid input syntax for type integer` error.

Run `upsert_menu()` with valid menu body and valid option group data, but a deliberately malformed option item price that fails a type cast.

Use a transaction and roll it back:

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-ATOMIC',
  p_category_name_ko := '원자성 테스트',
  p_menu_code := '__test_admin_menu_601113_atomic',
  p_menu_name_ko := '601113 원자성 메뉴',
  p_price := 8000,
  p_allergen_codes := '{"soy": true}'::jsonb,
  p_menu_options := '[
    {
      "group_code": "BAD_GROUP",
      "group_name": "실패 그룹",
      "items": [
        {
          "item_code": "BAD_ITEM",
          "item_name": "잘못된 가격",
          "price_delta": "not_a_number"
        }
      ]
    }
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §6.2 Expected result

Expected:

- The call fails at the item sync layer with `invalid input syntax for type integer: "not_a_number"`.
- The menu body insert/update and option group insert/update are rolled back with the failing call.
- No partial menu, category, or option group remains for `menu_code='__test_admin_menu_601113_atomic'` / `category_code='TEST-ATOMIC'` — the category check is a secondary confirmation of §10.1's leak fix using this same atomicity scenario.

Verify:

```sql
select count(*) as menu_count
from catchmenu_pos.menus
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and menu_code = '__test_admin_menu_601113_atomic';

select count(*) as category_count
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-ATOMIC';
```

Expected:

- `menu_count = 0`
- `category_count = 0` (this failure occurs after Slice 3's reordered validation — §10.1 — so no category row is created in the first place; this is a different code path than §10.1's own test, which uses an *existing* category to trigger `menu_code_duplicate` specifically)

Finish:

```sql
rollback;
```

## §7 Test G — `menu_price_changed` audit event (2026-07-17, Stage 6 Contract Verification finding)

`601112_Logic.md` §2.2's `upsert_menu_core()` design inserts a `catchmenu_ledger.events` row (`event_type = 'menu_price_changed'`) whenever an existing menu's price actually changes. No prior test in this TestPlan verified that insert actually happens.

### §7.1 Setup

Within one transaction:

```sql
begin;

-- Step 1: create a menu with a known price.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-PRICE-EVT',
  p_category_name_ko := '가격 이벤트 테스트',
  p_menu_code := '__test_admin_menu_601113_price_evt',
  p_menu_name_ko := '601113 가격 이벤트 메뉴',
  p_price := 5000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id> from the result for use below.

-- Step 2: update the same menu with a different price.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_price := 5500,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §7.2 Expected result

```sql
select event_type, event_domain, subject_type, subject_id, from_state, to_state,
       caused_by_type, caused_by_id, event_payload
from catchmenu_ledger.events
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and event_type = 'menu_price_changed'
  and subject_id = '<test_menu_id>'::uuid
order by occurred_at desc
limit 1;
```

Expected:

- Exactly one `menu_price_changed` event row exists for `<test_menu_id>` within this transaction (Step 1's initial creation must not have produced one — the event only fires on the update branch, per `601112_Logic.md` §2.2).
- `event_domain = 'system'` (corrected 2026-07-17, `601114_ChangeContract.md` §2.7 — the original `0110` body used `'menu'`, which is not a valid `chk_event_domain` value and would insert-fail; this assertion is the regression guard for that fix, moved into `upsert_menu_core()` as part of Slice 1).
- `subject_type = 'menu'`, `from_state = '5000'`, `to_state = '5500'`.
- `caused_by_type = 'STAFF'`, `caused_by_id = '<test_actor_id>'`.
- `event_payload` contains `old_price: 5000`, `new_price: 5500`.

Finish:

```sql
rollback;
```

## §8 Test H — helper functions exist live after implementation (2026-07-17, Stage 6 Contract Verification finding)

This check is deliberately not part of §1 (Pre-flight checks) — `upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()` are new functions per `601112_Logic.md` §2.2-§2.4 and do not exist before Stage 4 implements them. This is a post-implementation check, run after live re-execution and before Stage 6/9 sign-off.

### §8.1 Execute

```sql
select
  n.nspname as schema_name,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as identity_arguments
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname in (
    'upsert_menu_core',
    'sync_menu_option_groups_core',
    'sync_menu_option_items_core'
  )
order by p.proname;
```

### §8.2 Expected result

- `catchmenu_store.upsert_menu_core(...)` exists.
- `catchmenu_store.sync_menu_option_groups_core(...)` exists.
- `catchmenu_store.sync_menu_option_items_core(...)` exists.
- All three are in `catchmenu_store`, not `catchmenu_pos` (`601112_Logic.md` §2, schema correction).

If any of the three is missing, Stop Condition — the three-layer structure required by `601114_ChangeContract.md` §2.2/§1.3 was not actually implemented as separate callable functions.

## §9 Test I — idempotent re-run and `menu_code_duplicate` no-regression (2026-07-17, Stage 6 Contract Verification finding)

### §9.1 Idempotent re-run

Call `upsert_menu()` twice with byte-identical input (same `p_menu_id`, same `p_menu_options`) and confirm the second call is a no-op in effect:

```sql
begin;

-- Step 1: create a menu with one group/item.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-IDEMPOTENT',
  p_category_name_ko := '멱등성 테스트',
  p_menu_code := '__test_admin_menu_601113_idempotent',
  p_menu_name_ko := '601113 멱등성 메뉴',
  p_price := 4500,
  p_menu_options := '[{"group_code": "G1", "group_name": "G1", "items": [{"item_code": "I1", "item_name": "I1", "price_delta": 100}]}]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id>.

-- Step 2: call again with identical p_menu_id and identical p_menu_options/p_price.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_price := 4500,
  p_menu_options := '[{"group_code": "G1", "group_name": "G1", "items": [{"item_code": "I1", "item_name": "I1", "price_delta": 100}]}]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select count(*) as group_count from catchmenu_pos.menu_option_groups where menu_id = '<test_menu_id>'::uuid;
select count(*) as item_count from catchmenu_pos.menu_option_items i
  join catchmenu_pos.menu_option_groups g on g.id = i.option_group_id
  where g.menu_id = '<test_menu_id>'::uuid;
select count(*) as price_event_count from catchmenu_ledger.events
  where subject_id = '<test_menu_id>'::uuid and event_type = 'menu_price_changed';

rollback;
```

Expected:

- Both calls return `success:true`.
- `group_count = 1`, `item_count = 1` — the identical second call does not create a duplicate group/item row (matched via `on conflict (menu_id, group_code)` / `on conflict (option_group_id, item_code)`, `601112_Logic.md` §2.3/§2.4).
- No group/item flips to `is_active=false` — both calls' `p_menu_options` contain the same `group_code`/`item_code`.
- `price_event_count = 0` — since `p_price` did not change between the two calls, no `menu_price_changed` event fires on the second call (§7 verified the event fires when price *does* change; this confirms it correctly does not fire when it doesn't).

### §9.2 `menu_code_duplicate` no-regression

`601112_Logic.md` §1.1 confirms `upsert_menu()`'s pre-existing manual duplicate check is unchanged behavior — this test confirms it after Stage 4's changes:

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-DUP',
  p_category_name_ko := '중복 테스트',
  p_menu_code := '__test_admin_menu_601113_dup',
  p_menu_name_ko := '601113 중복 메뉴 A',
  p_price := 1000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Second call: same store, same menu_code, p_menu_id still null (new-menu path).
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-DUP',
  p_category_name_ko := '중복 테스트',
  p_menu_code := '__test_admin_menu_601113_dup',
  p_menu_name_ko := '601113 중복 메뉴 B',
  p_price := 2000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

rollback;
```

Expected:

- The first call returns `success:true`.
- The second call returns `success:false` with error key `menu_code_duplicate` (per `601112_Logic.md` §2.2's pre-existing manual check, unmodified by this workpacket) — it must not instead surface a raw, unfriendly DB constraint violation from `uq_menu_store_code`.
- This confirms `601114_ChangeContract.md` §6 (c)'s "preserves existing behavior" claim rather than assuming it.

## §10 Test J — Slice 3: category-row leak + item cascade (new 2026-07-17, `601114_ChangeContract.md` §2.10)

### §10.1 Category-row leak on validation failure (§2.10.1, Antigravity 발견 시나리오 그대로 재현)

Before the fix, `upsert_menu_core()` ran the category `INSERT ... ON CONFLICT ... DO UPDATE` before the `menu_not_found`/`menu_code_duplicate` checks — so a call that fails validation still permanently commits a category row, because `build_error_response(...)` is a normal return value, not an exception, and nothing rolls back. This test reproduces the exact duplicate-code scenario and asserts the category count is unchanged after the failing call.

#### §10.1.1 Setup

```sql
begin;

select
  (select count(*) from catchmenu_pos.menu_categories
   where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
     and category_code = 'V9-SLICE3-CAT') as category_count_before;

-- First call: succeeds, creates the category and the menu.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'V9-SLICE3-CAT', p_category_name_ko := 'Slice3 카테고리 누수 테스트',
  p_menu_code := '__test_admin_menu_601113_slice3_leak', p_menu_name_ko := 'Slice3 누수 메뉴 A',
  p_price := 1000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

select count(*) as category_count_after_success
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid and category_code = 'V9-SLICE3-CAT';

-- Second call: same menu_code (still p_menu_id := null, i.e. the new-menu path),
-- deliberately triggering menu_code_duplicate. Also passes a category_code that
-- did NOT exist before this call, to catch a leak on the create-new-category path too.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'V9-SLICE3-CAT-NEW', p_category_name_ko := 'Slice3 신규 카테고리(누수 시도)',
  p_menu_code := '__test_admin_menu_601113_slice3_leak', p_menu_name_ko := 'Slice3 누수 메뉴 B',
  p_price := 2000, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);
```

#### §10.1.2 Expected result

```sql
select
  (select count(*) from catchmenu_pos.menu_categories
   where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
     and category_code = 'V9-SLICE3-CAT-NEW') as category_count_after_failure;

rollback;
```

Expected:

- The first `upsert_menu()` call returns `success:true`; `category_count_after_success = 1`.
- The second `upsert_menu()` call returns `success:false` with `error.key = 'menu_code_duplicate'`.
- **`category_count_after_failure = 0`** — the fix's core assertion. Before the fix this would be `1` (the leaked category row, created and committed despite the call failing).
- The existing `V9-SLICE3-CAT` category (from the first, successful call) is untouched — this test isolates the leak specifically to the category named in the *failing* call.

### §10.2 Item cascade on fully-omitted group (§2.10.2, Cursor+Claude Code 공통 발견 시나리오 그대로 재현)

Before the fix, an item belonging to a group entirely omitted from `p_menu_options` stayed `is_active=true` even though its parent group correctly flipped to `is_active=false` — because `sync_menu_option_groups_core()`'s return value never included omitted groups, so `upsert_menu()`'s item-sync loop never ran for them.

#### §10.2.1 Setup

```sql
begin;

-- Step 1: create a menu with GROUP_KEEP (one item) and GROUP_DROP (one item).
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null, p_category_code := 'V9-SLICE3-CASCADE', p_category_name_ko := 'Slice3 cascade 테스트',
  p_menu_code := '__test_admin_menu_601113_slice3_cascade', p_menu_name_ko := 'Slice3 cascade 메뉴',
  p_price := 3000,
  p_menu_options := '[
    {"group_code": "V9_S3_KEEP", "group_name": "유지 그룹", "items": [{"item_code": "V9_S3_KEEP_ITEM", "item_name": "유지 항목", "price_delta": 100}]},
    {"group_code": "V9_S3_DROP", "group_name": "제거될 그룹", "items": [{"item_code": "V9_S3_DROP_ITEM", "item_name": "제거될 항목", "price_delta": 200}]}
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);

-- Record <slice3_cascade_menu_id> from the result.

-- Step 2: call again, omitting GROUP_DROP entirely.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<slice3_cascade_menu_id>'::uuid,
  p_menu_options := '[
    {"group_code": "V9_S3_KEEP", "group_name": "유지 그룹", "items": [{"item_code": "V9_S3_KEEP_ITEM", "item_name": "유지 항목", "price_delta": 100}]}
  ]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
);
```

#### §10.2.2 Expected result

```sql
select g.group_code, g.is_active as group_active, i.item_code, i.is_active as item_active
from catchmenu_pos.menus m
left join catchmenu_pos.menu_option_groups g on g.menu_id = m.id
left join catchmenu_pos.menu_option_items i on i.option_group_id = g.id
where m.id = '<slice3_cascade_menu_id>'::uuid
order by g.group_code, i.item_code;

rollback;
```

Expected:

- `V9_S3_KEEP`: `group_active = true`, `V9_S3_KEEP_ITEM`: `item_active = true` (unchanged, still present in the second call).
- `V9_S3_DROP`: `group_active = false` (correctly deactivated — this part already worked before the fix).
- **`V9_S3_DROP_ITEM`: `item_active = false`** — the fix's core assertion. Before the fix this would be `true` (the item silently stayed active because `sync_menu_option_items_core()` was never invoked for the omitted group).

## §11 Test F — `set_menu_status()` no-regression check

`set_menu_status()` is a No-Regression-Only function body under the ChangeContract (`601114_ChangeContract.md` §1.2) — it lives in the same 0110 store-admin menu surface but is not modified by this workpacket. This test verifies it was not regressed.

### §11.1 Execute

**(2026-07-17 정정, Stage 9 독립 검증 — Claude Code 발견)** The example below previously called `set_menu_status()` with `p_menu_id := '<test_menu_id>'::uuid` (singular). Its actual live signature is `set_menu_status(p_tenant_id uuid, p_store_id uuid, p_menu_ids jsonb, p_menu_status text, p_actor_id uuid, p_locale text)` — `p_menu_ids` is a batch JSON array, not a single UUID. As literally written, the prior example would fail with a type error before this function was ever exercised. Corrected below.

Within a transaction, create or identify a test menu and call:

```sql
select catchmenu_store.set_menu_status(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_ids := jsonb_build_array('<test_menu_id>'::uuid),
  p_menu_status := 'SOLD_OUT',
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §11.2 Expected result

Expected:

- Function returns `success:true`, with `data.updated_count = 1` (batch signature — even a single-menu call reports a count, not just a bare success flag).
- The target menu status changes as requested.
- No phantom field introduced by the upsert fix is referenced.
- The function body is byte-identical to its pre-Stage-4 source (§12.1's diff boundary check covers this at the file level; per `601114_ChangeContract.md` §1.2, any edit here beyond no-regression preservation is out of scope).

Finish:

```sql
rollback;
```

## §12 Boundary checks

### §12.1 Source diff boundary

Run:

```bash
git diff -- sql/migrations/0044_create_menu_management_rpc.sql
git diff -- sql/migrations/0141_hyper_personalization_menu_customization.sql
```

Expected:

- both diffs are empty.

Run:

```bash
git diff -- sql/migrations/0110_create_store_admin_rpc.sql
```

Expected (2026-07-17 정정, Stage 6 3차 검증 — Cursor 단독 발견: 이전 서술 "approved 0110 menu-admin functions and internal helper functions are changed"은 `set_menu_status()`가 마치 수정 허용 대상인 것처럼 읽혔다 — `601114_ChangeContract.md` §1.2/§2.7/§2.8의 no-regression-only 분류와 정확히 일치하도록 아래로 재작성):

- The diff shows changes to exactly these bodies: `catchmenu_store.upsert_menu()`, `catchmenu_store.get_menu_admin_list()`, `catchmenu_store.get_store_admin_dashboard()` (all three modification-authorized per `601114_ChangeContract.md` §1.2/§2.7), plus the three newly-created helper functions `catchmenu_store.upsert_menu_core()`, `catchmenu_store.sync_menu_option_groups_core()`, `catchmenu_store.sync_menu_option_items_core()`.
- `catchmenu_store.set_menu_status()` shows **zero** diff — it is no-regression-preservation-only (`601114_ChangeContract.md` §1.2) and must not appear in this diff at all. If it does, that is a Stop Condition, not an approved change.
- No other 0110 function (staff, hours, holidays, store settings, POS integration) appears in this diff.

### §12.2 Price boundary (corrected 2026-07-16, per `601114_ChangeContract.md` §2.6)

Expected:

- Stage 4 does not modify `0141_hyper_personalization_menu_customization.sql`.
- Stage 4 writes option item price data through `price_delta` (canonical) — `sync_menu_option_items_core()` must set `price_delta` on both insert and the `on conflict ... do update` branch.
- Stage 4 does not write the pre-`0141` option-price column (its literal name is defined in `601112_Logic.md` §1.2 and `601114_ChangeContract.md` §2.6) — it must not appear in the insert column list or the `on conflict ... do update` clause of `sync_menu_option_items_core()`. Its existing values are left unchanged; new items keep it at its schema default (`0`).
- The resulting `get_menu_catalog()` (`0044`) customer-facing inconsistency (still reads the pre-`0141` column, so admin-edited prices via `price_delta` are not reflected there) is accepted as a known deferred item (`601112_Logic.md` §6 (a)) — not a Stop Condition, not something this TestPlan requires fixing.
- Any broader price-list reconciliation is deferred to `601130_menu_price_list_architecture`.

### §12.3 Phantom string boundary

After live re-execution, inspect relevant live function definitions:

```sql
select pg_get_functiondef('catchmenu_store.upsert_menu(uuid, uuid, uuid, text, text, text, text, text, text, text, integer, text, text, boolean, text, integer, jsonb, jsonb, uuid, text)'::regprocedure);
select pg_get_functiondef('catchmenu_store.get_menu_admin_list(uuid, uuid, text)'::regprocedure);
select pg_get_functiondef('catchmenu_store.get_store_admin_dashboard(uuid, uuid, text)'::regprocedure);
```

Expected:

- physical column references to `thumbnail_url`, `allergen_codes`, `menu_options`, and `pos_sync_at` are gone from SQL that touches `catchmenu_pos.menus`.
- public parameter names such as `p_thumbnail_url` and `p_allergen_codes` may remain only as compatibility input names and must be mapped to real columns internally.

## §13 Acceptance criteria

PASS only if all are true:

1. `upsert_menu()` creates a new menu and relational option groups/items successfully (§2).
2. `upsert_menu()` update path performs full replacement by soft-deactivating omitted groups/items, and correctly updates `price_delta` on items that remain (§3, corrected 2026-07-17 to actually assert the updated value rather than only the deactivation flags).
3. `get_menu_admin_list()` executes without phantom column or allergen array/object crashes, and its `option_groups` JSON has the correct nested `items`/`price_delta` structure, not just an absence of errors (§4, structure check added 2026-07-17). Its `category_summary` block no longer raises `aggregate function calls cannot be nested`, across zero-categories, empty-category, single-menu, mixed-status, and inactive-menu edge cases, with unchanged JSON structure and aggregate semantics (§4.4, Slice 2, `601114_ChangeContract.md` §2.9, added 2026-07-17 — gated on its own separate Human approval checkbox, not covered by the original four-item approval).
4. `get_store_admin_dashboard()` executes without `allergen_codes` crash (§5).
5. Transaction atomicity is proven: a failure in one core layer rolls back all prior layers (§6).
6. A `menu_price_changed` audit event is inserted into `catchmenu_ledger.events` when price actually changes, and only then (§7, added 2026-07-17).
7. `upsert_menu_core()`, `sync_menu_option_groups_core()`, and `sync_menu_option_items_core()` exist live in `catchmenu_store` as three separate callable functions (§8, added 2026-07-17).
8. Re-running `upsert_menu()` with identical input is idempotent (no duplicate rows, no spurious audit event), and `menu_code_duplicate` still returns its existing friendly error rather than a raw constraint violation (§9, added 2026-07-17).
9. **(new 2026-07-17, Slice 3, `601114_ChangeContract.md` §2.10)** A failing `upsert_menu()` call (`menu_not_found` or `menu_code_duplicate`) leaves zero trace in `catchmenu_pos.menu_categories` — no leaked/updated category row (§10.1). An item belonging to a group fully omitted from `p_menu_options` is soft-deactivated along with its group, not left `is_active=true` (§10.2). Both gated on Slice 3's own separate Human approval checkbox, not covered by the original six-item approval.
10. `set_menu_status()` has no regression, using its actual live `p_menu_ids` batch-array signature, not the singular `p_menu_id` the example previously (incorrectly) showed (§11, corrected 2026-07-17).
11. `0044`, `0141`, price-list work, and table CRUD work remain untouched. The pre-`0141` option-price column remains untouched (Stage 4 writes `price_delta` instead — §12.2, corrected 2026-07-16).
12. Live function definitions match the corrected source after re-execution (§12.3).

