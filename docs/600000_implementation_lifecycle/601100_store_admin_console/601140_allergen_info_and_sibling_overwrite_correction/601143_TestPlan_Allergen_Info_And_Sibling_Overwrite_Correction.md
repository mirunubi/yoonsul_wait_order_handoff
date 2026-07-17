# 601143_TestPlan_Allergen_Info_And_Sibling_Overwrite_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`allergen_info_and_sibling_overwrite_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `601142_Logic_Allergen_Info_And_Sibling_Overwrite_Correction.md` §1-§3 only — the `default null` signature change on `catchmenu_store.upsert_menu()`/`upsert_menu_core()` for `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`/`p_allergen_codes`(`p_allergen_info`), and the `v_clean_allergen_info` NULL-vs-explicit-object-vs-defensive redesign. It does **not** re-derive `601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md`'s own coverage — §6 below only adds an incremental regression assertion on top of that document's existing test blocks, pointed to by reference.

Document number check:

- `601141_Overview_Allergen_Info_And_Sibling_Overwrite_Correction.md` exists.
- `601142_Logic_Allergen_Info_And_Sibling_Overwrite_Correction.md` exists.
- `601143_TestPlan_Allergen_Info_And_Sibling_Overwrite_Correction.md` is the next TestPlan document number for this workpacket.
- `601144_ChangeContract_Allergen_Info_And_Sibling_Overwrite_Correction.md` is the paired ChangeContract.

Test menu rows in this document use the `__test_admin_menu_601143_*` prefix — distinct from `601113_TestPlan.md`'s `__test_admin_menu_601113_*` prefix — so the two TestPlans' fixture data never collides even if run against the same `<test_tenant_id>`/`<test_store_id>`. Every section below is a self-contained `begin;...rollback;` block, matching the isolation convention established in `601113_TestPlan.md` §4.3's correction note — no section depends on another section's (already-rolled-back) data.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `601144_ChangeContract_Allergen_Info_And_Sibling_Overwrite_Correction.md` is hit, stop and report.

### §1.1 Target functions exist

```sql
select
  n.nspname as schema_name,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as identity_arguments
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_store'
  and p.proname in ('upsert_menu', 'upsert_menu_core')
order by p.proname;
```

Expected:

- `catchmenu_store.upsert_menu(...)` exists.
- `catchmenu_store.upsert_menu_core(...)` exists (internal helper, per `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` §1.3 — already live from the `601110` workpacket).

### §1.2 `chk_menu_allergen_object` constraint exists and still enforces object-or-null

```sql
select conname, pg_get_constraintdef(oid) as constraint_def
from pg_constraint
where conname = 'chk_menu_allergen_object';
```

Expected:

- `chk_menu_allergen_object` exists and requires `allergen_info` to be either `null` or a JSONB object. If missing or no longer describing this contract, Stop Condition (`601144_ChangeContract.md` §6 #1).

### §1.3 Baseline — confirm the four defaults are still the pre-fix (buggy) values

```sql
select prosrc from pg_proc where proname = 'upsert_menu' and pronamespace = 'catchmenu_store'::regnamespace::oid;
```

Or, simpler, confirm directly against source (`sql/migrations/0110_create_store_admin_rpc.sql:266-269` for `upsert_menu()`, `:354-357` for `upsert_menu_core()`) that the four parameters still default to `true`/`'MAIN'`/`0`/`'[]'::jsonb` (or `'{}'::jsonb`) rather than `null`. This confirms Stage 8 has not already run when this pre-flight executes — if the defaults are already `null`, this workpacket's implementation step is already done and Stage 8 must not re-apply it blindly (re-verify via `pg_get_functiondef()` instead of re-editing source).

## §2 Test A — sibling field preservation on partial update (`is_kds_required`/`kitchen_zone`/`display_order`)

This is the core regression test — the exact reproduction from `601141_Overview.md` §0, now asserted formally.

### §2.1 Setup

```sql
begin;

-- Step 1: create a menu with non-default values for the three sibling fields.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SIBLING',
  p_category_name_ko := '형제 필드 테스트',
  p_menu_code := '__test_admin_menu_601143_sibling',
  p_menu_name_ko := '601143 형제 필드 메뉴',
  p_price := 5000,
  p_is_kds_required := false,
  p_kitchen_zone := 'GRILL',
  p_display_order := 42,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id> from the result for use below.

-- Step 2: update the same menu, changing only price. is_kds_required/kitchen_zone/
-- display_order/p_allergen_codes are all omitted (not passed at all) — this is
-- exactly the call shape that reproduces the bug pre-fix.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_price := 5500,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
```

### §2.2 Expected result

```sql
select is_kds_required, kitchen_zone, display_order, price
from catchmenu_pos.menus
where id = '<test_menu_id>'::uuid;
```

Expected (post-fix):

- `is_kds_required = false` — preserved from Step 1, **not** reset to the hardcoded default `true`.
- `kitchen_zone = 'GRILL'` — preserved, **not** reset to `'MAIN'`.
- `display_order = 42` — preserved, **not** reset to `0`.
- `price = 5500` — the field actually targeted by Step 2's call did update.

This is the workpacket's primary "did the bug actually go away" assertion — pre-fix, all three would incorrectly read `true`/`'MAIN'`/`0` after Step 2.

Finish:

```sql
rollback;
```

## §3 Test B — `allergen_info` three-case behavior

Per `601142_Logic.md` §1.3, `allergen_info` needs a three-way distinction that the three simple sibling fields don't: omission (NULL) preserves, an explicit object updates, and an explicit non-object value is defensively neutralized to `{}` — which is **not** the same as "preserved" and must be verified as its own, distinct outcome.

### §3.1 Case 1 — omission preserves the existing value

```sql
begin;

-- Step 1: create a menu with a known non-empty allergen_info object.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-ALLERGEN',
  p_category_name_ko := '알레르겐 테스트',
  p_menu_code := '__test_admin_menu_601143_allergen_omit',
  p_menu_name_ko := '601143 알레르겐 생략 메뉴',
  p_price := 4000,
  p_allergen_codes := '{"eggs": true, "milk": true}'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id>.

-- Step 2: update, omitting p_allergen_codes entirely.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_price := 4200,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select allergen_info, jsonb_typeof(allergen_info) as allergen_type
from catchmenu_pos.menus
where id = '<test_menu_id>'::uuid;

rollback;
```

Expected:

- `allergen_info = {"eggs": true, "milk": true}` — **preserved** from Step 1. Pre-fix, this would incorrectly read `{}` (wiped).
- `allergen_type = 'object'`.

### §3.2 Case 2 — explicit object updates the value

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-ALLERGEN',
  p_category_name_ko := '알레르겐 테스트',
  p_menu_code := '__test_admin_menu_601143_allergen_update',
  p_menu_name_ko := '601143 알레르겐 갱신 메뉴',
  p_price := 4000,
  p_allergen_codes := '{"eggs": true}'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id>.

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_allergen_codes := '{"peanuts": true, "shellfish": true}'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select allergen_info, jsonb_typeof(allergen_info) as allergen_type
from catchmenu_pos.menus
where id = '<test_menu_id>'::uuid;

rollback;
```

Expected:

- `allergen_info = {"peanuts": true, "shellfish": true}` — **replaced** by the explicit value from Step 2, not merged with Step 1's value and not preserved as Step 1's value.
- `allergen_type = 'object'`.

### §3.3 Case 3 — explicit non-object value is defensively neutralized (not preserved)

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-ALLERGEN',
  p_category_name_ko := '알레르겐 테스트',
  p_menu_code := '__test_admin_menu_601143_allergen_defensive',
  p_menu_name_ko := '601143 알레르겐 방어 메뉴',
  p_price := 4000,
  p_allergen_codes := '{"eggs": true}'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Record <test_menu_id>.

-- Step 2: pass a JSON array instead of an object — an abnormal/malformed caller input,
-- not an omission.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<test_menu_id>'::uuid,
  p_allergen_codes := '["eggs", "milk"]'::jsonb,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select allergen_info, jsonb_typeof(allergen_info) as allergen_type
from catchmenu_pos.menus
where id = '<test_menu_id>'::uuid;

rollback;
```

Expected:

- `allergen_info = {}` — the array input is defensively neutralized to an empty object. **This is not "preserved"** — Step 1's `{"eggs": true}` is gone. This is the correct, intentional behavior for malformed non-omission input (`601142_Logic.md` §1.3's `else '{}'::jsonb` branch), and must be verified as distinct from §3.1's omission-preserves case — a test that asserted "value unchanged" here would be asserting the wrong thing.
- `allergen_type = 'object'` — still a valid object, satisfying `chk_menu_allergen_object`.
- The call itself returns `success:true` — a non-object `p_allergen_codes` is neutralized, not rejected as an error.

### §3.4 `chk_menu_allergen_object` satisfied across all three cases

No dedicated new query is needed beyond §3.1-§3.3 — each of those three sections' setup and update calls only succeeds (no constraint-violation exception) if `chk_menu_allergen_object` accepts the resulting value. This subsection records the explicit cross-reference:

- §3.1's preserved object, §3.2's replaced object, and §3.3's defensively-neutralized `{}` must each pass `chk_menu_allergen_object` — confirmed implicitly by all three `upsert_menu()` calls returning `success:true` with no unhandled exception, and explicitly by each section's `jsonb_typeof(allergen_info) = 'object'` assertion (the constraint's `object or null` requirement, verified never null in these three cases since a value is always resolved before write).
- If any of §3.1-§3.3 instead fails with a constraint violation, that is a Stop Condition (`601144_ChangeContract.md` §6 #1) — it would mean the three-way redesign in `601142_Logic.md` §1.3 produces a value the constraint rejects, which the Logic-stage line-level review did not anticipate.

## §4 Test C — new menu creation (INSERT path) with all four fields omitted

Confirms `601142_Logic.md` §1 point 4 — the INSERT-path `coalesce(p_x, <generation default>)` logic is unchanged and still produces sane creation-time defaults when a caller omits all four fields on a brand-new menu.

### §4.1 Setup

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-INSERT-DEFAULT',
  p_category_name_ko := '생성 기본값 테스트',
  p_menu_code := '__test_admin_menu_601143_insert_default',
  p_menu_name_ko := '601143 생성 기본값 메뉴',
  p_price := 3000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
-- p_is_kds_required / p_kitchen_zone / p_display_order / p_allergen_codes all omitted.
```

### §4.2 Expected result

```sql
select is_kds_required, kitchen_zone, display_order, allergen_info, jsonb_typeof(allergen_info) as allergen_type
from catchmenu_pos.menus
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and menu_code = '__test_admin_menu_601143_insert_default';
```

Expected — identical to pre-fix behavior, no regression:

- `is_kds_required = true`
- `kitchen_zone = 'MAIN'`
- `display_order = 0`
- `allergen_info = {}`
- `allergen_type = 'object'`

Finish:

```sql
rollback;
```

## §5 601113_TestPlan.md existing UPDATE-path no-regression re-confirmation

`601141_Overview.md` §4 already confirmed statically that none of `601113_TestPlan.md`'s four existing UPDATE-path call sites (§3 Step 2, §7 Step 2, §9.1 Step 2, §10.2 Step 2) assert on the four target fields, so the signature-default change cannot break an existing assertion. This section adds the missing dynamic confirmation: run each of those four blocks unmodified and add one incremental assertion per block that the four fields still hold their **INSERT-path generation defaults** (`true`/`'MAIN'`/`0`/`{}`) after the block's UPDATE step — i.e. genuinely untouched, not silently changed to some other value by the redesign.

For each of the four blocks below: run the referenced `601113_TestPlan.md` section's SQL exactly as written there, then run the added query in this section against the same `<test_menu_id>` (or `<slice3_cascade_menu_id>` for §10.2) before that section's own `rollback;`.

### §5.1 `601113_TestPlan.md` §3 (full-replacement update)

Added assertion, run after §3's Step 2, before its `rollback;`:

```sql
select is_kds_required, kitchen_zone, display_order, allergen_info
from catchmenu_pos.menus
where id = '<test_menu_id>'::uuid;
```

Expected: `is_kds_required = true`, `kitchen_zone = 'MAIN'`, `display_order = 0`, `allergen_info = {}` — §3's Step 1 never set these fields explicitly, so they hold the INSERT-path generation defaults; §3's Step 2 (which also never sets them) must not have changed them.

### §5.2 `601113_TestPlan.md` §7 (`menu_price_changed` audit event)

Same added assertion pattern, run after §7's Step 2, before its `rollback;`, against `<test_menu_id>` from that section. Same expected values.

### §5.3 `601113_TestPlan.md` §9.1 (idempotent re-run)

Same added assertion pattern, run after §9.1's Step 2, before its `rollback;`, against `<test_menu_id>` from that section. Same expected values.

### §5.4 `601113_TestPlan.md` §10.2 (item cascade on fully-omitted group)

Same added assertion pattern, run after §10.2's Step 2, before its `rollback;`, against `<slice3_cascade_menu_id>` from that section. Same expected values.

### §5.5 Expected result (all four)

- All four blocks' original assertions (as written in `601113_TestPlan.md`) still pass unmodified.
- All four blocks' added assertion in this section passes: the four sibling fields hold `true`/`'MAIN'`/`0`/`{}` after each block's final UPDATE step, with no error.
- If any of the four instead show a different value or an error, that is a Stop Condition (`601144_ChangeContract.md` §6 #4) — it would mean the signature-default change had an effect on `601113_TestPlan.md`'s existing coverage beyond what `601141_Overview.md` §4 predicted.

## §6 Boundary — `menu_options` / `sync_menu_option_*_core()` zero diff

```bash
git diff -- sql/migrations/0110_create_store_admin_rpc.sql
```

Expected:

- The diff shows changes only within the `catchmenu_store.upsert_menu()` and `catchmenu_store.upsert_menu_core()` function bodies (signature default-value lines; for `upsert_menu_core()` only, also the `v_clean_allergen_info` declaration/assignment block and its two use sites; and — Slice 2, `601144_ChangeContract.md` §2.5 — the category upsert block's `display_order` VALUES entry and its new line in the `on conflict ... do update set` clause, per §7 below).
- `catchmenu_store.sync_menu_option_groups_core()` (source lines 597-686) shows **zero** diff.
- `catchmenu_store.sync_menu_option_items_core()` (source lines 689-762) shows **zero** diff.
- `catchmenu_store.get_menu_admin_list()`, `catchmenu_store.get_store_admin_dashboard()`, `catchmenu_store.set_menu_status()` all show **zero** diff.
- No other 0110 function (staff, hours, holidays, store settings, POS integration) appears in this diff.

If any of the zero-diff functions above shows a change, that is a Stop Condition (`601144_ChangeContract.md` §6 #6) — this workpacket's approved scope is limited to `upsert_menu()`/`upsert_menu_core()` signatures and `upsert_menu_core()`'s `v_clean_allergen_info` body only.

## §7 Slice 2 — category upsert `display_order` safety (new 2026-07-17, `601144_ChangeContract.md` §2.5)

`601142_Logic.md` §4 documents a side effect of §2.2's `upsert_menu_core()` default-null change: it reuses the menu's `p_display_order` parameter as the value for `catchmenu_pos.menu_categories.display_order` (`NOT NULL DEFAULT 0`), so a caller that passes `p_category_code` while omitting `p_display_order` now crashes with a NOT NULL violation — on both the true-INSERT (new category) path and, live-confirmed, the `ON CONFLICT ... DO UPDATE` (existing category) path, since PostgreSQL checks the NOT NULL constraint while constructing the candidate row, before conflict resolution is determined. `601144_ChangeContract.md` §2.5 authorizes a fix with two distinct behaviors: the true-INSERT path defaults to `0` on omission, while the existing-category `DO UPDATE` path preserves the current value on omission — this section verifies both, plus the "emergency-fix trap" ChatGPT flagged (a bare `coalesce(p_display_order, 0)` applied everywhere would silently reset an existing category's `display_order` to `0` on every menu upsert that omits it, recreating this exact workpacket's bug class one resource over).

Test category codes in this section use the `TEST-SLICE2-*` prefix and menu codes use the `__test_admin_menu_601143_slice2_*` prefix — distinct from every other section's fixtures in this document.

### §7.1 New category creation with `p_display_order` omitted — defaults to `0`, no crash

```sql
begin;

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-NEWCAT',
  p_category_name_ko := 'Slice2 신규 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_newcat',
  p_menu_name_ko := '601143 Slice2 신규 카테고리 메뉴',
  p_price := 3000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
-- p_display_order omitted entirely.

select display_order
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-NEWCAT';

rollback;
```

Expected:

- The call returns `success:true` — no `null value in column "display_order"` error (the pre-Slice-2 crash).
- `display_order = 0`.

### §7.2 Existing category preserves `display_order` when a later menu upsert omits it (core fix assertion)

This is the "emergency-fix trap" test — the scenario a bare `coalesce(p_display_order, 0)` applied everywhere would get wrong.

```sql
begin;

-- Step 1: create the category via a first menu, explicit display_order = 7.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-PRESERVE',
  p_category_name_ko := 'Slice2 보존 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_preserve_a',
  p_menu_name_ko := '601143 Slice2 보존 메뉴 A',
  p_price := 3000,
  p_display_order := 7,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select display_order as category_display_order_after_step1
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-PRESERVE';

-- Step 2: a second, unrelated menu upsert referencing the SAME category_code,
-- p_display_order omitted this time.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-PRESERVE',
  p_category_name_ko := 'Slice2 보존 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_preserve_b',
  p_menu_name_ko := '601143 Slice2 보존 메뉴 B',
  p_price := 4000,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select display_order as category_display_order_after_step2
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid
  and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-PRESERVE';

rollback;
```

Expected:

- `category_display_order_after_step1 = 7`.
- Step 2's call returns `success:true` — no crash (this alone would have failed before Slice 2).
- **`category_display_order_after_step2 = 7`** — the core assertion. Not silently reset to `0`. A fix that coalesced to `0` in the `ON CONFLICT ... DO UPDATE` branch (instead of preserving via the original `p_display_order` parameter, per `601142_Logic.md` §4.2) would incorrectly show `0` here.

### §7.3 Explicit `p_display_order` updates both new and existing categories

```sql
begin;

-- Case A: new category, explicit p_display_order = 5.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-EXPLICIT-NEW',
  p_category_name_ko := 'Slice2 명시 신규 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_explicit_new',
  p_menu_name_ko := '601143 Slice2 명시 신규 메뉴',
  p_price := 3000,
  p_display_order := 5,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select display_order as new_category_display_order
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-EXPLICIT-NEW';

-- Case B: existing category, created with display_order = 1, then explicitly changed to 5
-- by a second menu upsert referencing the same category_code.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-EXPLICIT-EXISTING',
  p_category_name_ko := 'Slice2 명시 기존 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_explicit_existing_a',
  p_menu_name_ko := '601143 Slice2 명시 기존 메뉴 A',
  p_price := 3000,
  p_display_order := 1,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-EXPLICIT-EXISTING',
  p_category_name_ko := 'Slice2 명시 기존 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_explicit_existing_b',
  p_menu_name_ko := '601143 Slice2 명시 기존 메뉴 B',
  p_price := 4000,
  p_display_order := 5,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select display_order as existing_category_display_order
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-EXPLICIT-EXISTING';

rollback;
```

Expected:

- `new_category_display_order = 5`.
- `existing_category_display_order = 5` — updated from its initial `1`, confirming an explicit value is not blocked by the preserve-on-omission logic (the `coalesce(p_display_order, ...)` only falls back when `p_display_order` is actually NULL).

### §7.4 Cross scenario — menu's own `display_order` and its category's `display_order` are independently controlled

Confirms the parameter-reuse defect class (`601142_Logic.md` §3 Open Item (e)) is fully closed for the write path: the same textual parameter (`p_display_order`) can still end up controlling two different physical columns (`catchmenu_pos.menus.display_order` vs. `catchmenu_pos.menu_categories.display_order`) at two different values, with neither write leaking into the other, as long as a caller omits `p_category_code` on a menu-only update (the existing, established pattern for partial menu updates — `601113_TestPlan.md`'s update-path tests never pass `p_category_code` either).

```sql
begin;

-- Step 1: create category + menu together, both display_order = 9 (same call, same param).
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-CROSS',
  p_category_name_ko := 'Slice2 교차 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_cross_a',
  p_menu_name_ko := '601143 Slice2 교차 메뉴 A',
  p_price := 3000,
  p_display_order := 9,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

-- Step 2: a second, new menu in the SAME category, p_display_order omitted —
-- category.display_order stays 9 (§7.2's assertion again); this menu's own
-- display_order takes the unrelated INSERT-path generation default (0, §4).
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := null,
  p_category_code := 'TEST-SLICE2-CROSS',
  p_category_name_ko := 'Slice2 교차 카테고리',
  p_menu_code := '__test_admin_menu_601143_slice2_cross_b',
  p_menu_name_ko := '601143 Slice2 교차 메뉴 B',
  p_price := 3500,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);
-- Record <slice2_cross_menu_b_id> from the result.

-- Step 3: partial UPDATE of menu B only — p_category_code omitted (standard
-- partial-update shape), p_display_order := 42 targets ONLY the menu row.
select catchmenu_store.upsert_menu(
  p_tenant_id := '<test_tenant_id>'::uuid,
  p_store_id := '<test_store_id>'::uuid,
  p_menu_id := '<slice2_cross_menu_b_id>'::uuid,
  p_display_order := 42,
  p_actor_id := '<test_actor_id>'::uuid,
  p_locale := 'ko'
);

select display_order as menu_b_display_order
from catchmenu_pos.menus
where id = '<slice2_cross_menu_b_id>'::uuid;

select display_order as category_display_order
from catchmenu_pos.menu_categories
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and category_code = 'TEST-SLICE2-CROSS';

rollback;
```

Expected:

- `menu_b_display_order = 42` — Step 3's menu-only update took effect on the menu row.
- **`category_display_order = 9`** — untouched by Step 3, because Step 3 omits `p_category_code`, so the category upsert block never runs at all for that call. Menu and category `display_order` values now genuinely diverge (`42` vs. `9`) and neither write affected the other — confirming the parameter-overloading defect class this whole workpacket targets is closed for both resources, even though `p_display_order` is still, textually, one shared parameter name.

### §7.5 Expected result (all four subsections)

- §7.1: new category creation with `p_display_order` omitted succeeds and defaults to `0`.
- §7.2: an existing category's `display_order` survives an unrelated menu upsert that omits `p_display_order`, without crashing and without silently resetting to `0`.
- §7.3: an explicit `p_display_order` value correctly reaches both new and existing categories.
- §7.4: a menu's own `display_order` and its category's `display_order` can hold different values simultaneously and be updated independently, with no cross-contamination in either direction.
- If any of the above instead crashes, or shows category `display_order` silently reset to `0` where the value should have been preserved, that is a Stop Condition (`601144_ChangeContract.md` §6 #8) — it would mean Slice 2's implementation deviated from the two-branch design in `601142_Logic.md` §4.2 (e.g. by referencing `excluded.display_order` instead of the raw `p_display_order` parameter in the `DO UPDATE SET` clause).

## §8 Acceptance criteria

PASS only if all are true:

1. `is_kds_required`/`kitchen_zone`/`display_order` are preserved (not reset) on a partial update that omits them, after previously being set to non-default values (§2).
2. `allergen_info` is preserved on omission (§3.1), correctly replaced on an explicit object (§3.2), and defensively neutralized to `{}` — verified as distinct from "preserved" — on an explicit non-object value (§3.3); all three satisfy `chk_menu_allergen_object` (§3.4).
3. A brand-new menu created with all four fields omitted still receives the same generation-time defaults as before the fix: `true`/`'MAIN'`/`0`/`{}` (§4).
4. `601113_TestPlan.md`'s four existing UPDATE-path blocks (§3, §7, §9.1, §10.2) still pass their own original assertions unmodified, and additionally show the four sibling fields unchanged at their generation defaults (§5).
5. `sql/migrations/0110_create_store_admin_rpc.sql`'s diff touches only `upsert_menu()`/`upsert_menu_core()`; `menu_options`-related functions (`sync_menu_option_groups_core()`, `sync_menu_option_items_core()`) and all other 0110 functions show zero diff (§6).
6. **(new 2026-07-17, Slice 2)** A new category defaults its `display_order` to `0` on omission and never crashes; an existing category's `display_order` survives a later menu upsert that omits `p_display_order` (not silently reset to `0`); an explicit `p_display_order` correctly updates both new and existing categories; and a menu's own `display_order` and its category's `display_order` can be set to different values and updated independently of each other (§7).
