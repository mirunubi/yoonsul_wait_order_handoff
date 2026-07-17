# 601144_ChangeContract_Allergen_Info_And_Sibling_Overwrite_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`allergen_info_and_sibling_overwrite_correction`

## §0 Contract summary

This ChangeContract authorizes only the Stage 8 implementation described in `601142_Logic_Allergen_Info_And_Sibling_Overwrite_Correction.md` §1-§3: changing the parameter defaults of `catchmenu_store.upsert_menu()` and `catchmenu_store.upsert_menu_core()` for `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`/`p_allergen_codes`(`p_allergen_info`) from hardcoded non-null values to `default null`, and redesigning `upsert_menu_core()`'s `v_clean_allergen_info` logic to distinguish omission (NULL) from an explicit object from an explicit non-object value.

The goal is narrow: fix the "sibling overwrite" bug (`601141_Overview.md` §0/§1) where a partial update that omits these four parameters silently resets them to hardcoded defaults instead of preserving the existing row values — without touching `menu_options`/relational option sync, without touching any other `0110` function, and without changing `upsert_menu()`'s public parameter names, order, count, or types (only default *values* change).

Both `upsert_menu()`'s and `upsert_menu_core()`'s signatures are in scope — not `upsert_menu()` alone — per `601142_Logic.md` §1.2/§3(a): `upsert_menu_core()`'s live `pg_proc.proacl` is `NULL` (no explicit ACL was ever set), meaning PostgreSQL's default PUBLIC-EXECUTE privilege applies and any `authenticated`-or-higher caller can invoke it directly, bypassing `upsert_menu()`'s parameter forwarding entirely. Fixing only `upsert_menu()` would leave that direct-call path exposed to the same bug.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file

The only file allowed for this workpacket's SQL body changes is:

- `sql/migrations/0110_create_store_admin_rpc.sql` (in-place synchronization only)

Required procedure: the established live-function synchronization rule (source file update → CRLF→LF normalized checksum → `migration_history` checksum update → direct live re-execution → `pg_get_functiondef()` verification), same as `601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md` §1.1/§5. No other file, and no new migration number, is authorized.

If Stage 8 determines in-place synchronization is not viable for a reason not anticipated by this contract, Stage 8 must stop and return to Stage 5 for a new Human-approved boundary — not proceed under this contract's existing Allowed Files.

### §1.2 Allowed existing function bodies

**Allowed — modification authorized:**

- `catchmenu_store.upsert_menu(...)` — signature only (§2.1). Public parameter names, order, count, and types unchanged; only the default values of the four named parameters change. No change to this function's body/logic beyond that.
- `catchmenu_store.upsert_menu_core(...)` — signature (§2.2) and the `v_clean_allergen_info` declaration/assignment block plus its two use sites in the INSERT and UPDATE clauses (§2.3). No other part of this function's body changes.

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_store.sync_menu_option_groups_core(...)`
- `catchmenu_store.sync_menu_option_items_core(...)`
- `catchmenu_store.get_menu_admin_list(...)`
- `catchmenu_store.get_store_admin_dashboard(...)`
- `catchmenu_store.set_menu_status(...)`

These five are in scope only as diff-zero verification targets (`601143_TestPlan.md` §6) — Stage 8 must not edit any of their bodies. If Stage 8 finds a reason one of them needs to change, that is a Stop Condition (§6), not an in-scope edit — it requires returning to Stage 5 for a new boundary.

`p_menu_options` and the relational option-group/option-item synchronization it drives are explicitly out of scope in their entirety (`601141_Overview.md` §2 / `601142_Logic.md` §2) — the full-replacement contract they implement (`601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §2.5) is the opposite semantic ("omission = delete") from the preserve-on-omission fix this contract authorizes, and applying this fix's pattern there would break an already-approved contract rather than fix a bug.

## §2 Required implementation contract

### §2.1 `upsert_menu()` signature change

Per `601142_Logic.md` §1.1:

```sql
-- before (0110:266-269)
p_is_kds_required boolean default true,
p_kitchen_zone text default 'MAIN',
p_display_order int default 0,
p_allergen_codes jsonb default '[]'::jsonb,

-- after
p_is_kds_required boolean default null,
p_kitchen_zone text default null,
p_display_order int default null,
p_allergen_codes jsonb default null,
```

The call site forwarding these four parameters to `upsert_menu_core()` (0110:302-305) is unchanged — it already forwards whatever value it received, explicit or not.

### §2.2 `upsert_menu_core()` signature change (mandatory, not optional)

Per `601142_Logic.md` §1.2/§3(a):

```sql
-- before (0110:354-357)
p_is_kds_required boolean default true,
p_kitchen_zone text default 'MAIN',
p_display_order int default 0,
p_allergen_info jsonb default '{}'::jsonb,

-- after
p_is_kds_required boolean default null,
p_kitchen_zone text default null,
p_display_order int default null,
p_allergen_info jsonb default null,
```

This change is mandatory, not defensive-only: `upsert_menu_core()`'s live `pg_proc.proacl` is `NULL` (`601142_Logic.md` §1.2's live-verified query), meaning no explicit `GRANT`/`REVOKE` was ever applied and PostgreSQL's schema-default PUBLIC-EXECUTE privilege applies. Combined with `prosecdef = 't'`, any `authenticated`-or-higher role can call `upsert_menu_core()` directly with definer privileges, bypassing `upsert_menu()` entirely — on that path, `upsert_menu_core()`'s own defaults are what actually apply. §2.1 alone does not close this path.

### §2.3 `allergen_info` — NULL / explicit-object / defensive redesign

Per `601142_Logic.md` §1.3:

```sql
-- before (0110:375, 380-384)
declare
  ...
  v_clean_allergen_info jsonb;
begin
  ...
  v_clean_allergen_info := case
    when jsonb_typeof(coalesce(p_allergen_info, '{}'::jsonb)) = 'object'
      then coalesce(p_allergen_info, '{}'::jsonb)
    else '{}'::jsonb
  end;

-- after
declare
  ...
  v_clean_allergen_info jsonb;
begin
  ...
  v_clean_allergen_info := case
    when p_allergen_info is null then null
    when jsonb_typeof(p_allergen_info) = 'object' then p_allergen_info
    else '{}'::jsonb
  end;
```

Use sites (0110:487 INSERT, 0110:527 UPDATE):

```sql
-- INSERT clause, before: v_clean_allergen_info
-- INSERT clause, after:
coalesce(v_clean_allergen_info, '{}'::jsonb),

-- UPDATE clause, before: allergen_info = v_clean_allergen_info
-- UPDATE clause, after:
allergen_info = coalesce(v_clean_allergen_info, allergen_info),
```

### §2.4 No-change confirmation (informational, not an authorization to edit)

The following are confirmed by `601142_Logic.md` §1 points 2 and 4 to require **no code change** — listed here so Stage 8 does not treat their absence from §2.1-§2.3 as an oversight:

- The UPDATE clause for `is_kds_required`/`kitchen_zone`/`display_order` (0110:518-525) is already `coalesce(p_x, x)` and works correctly once §2.1/§2.2 let NULL actually reach it.
- The INSERT clause for all four fields (0110:484-487) is already `coalesce(p_x, <generation default>)` and is unaffected by this fix.

### §2.5 Slice 2 — category upsert `display_order` safety (new 2026-07-17, Human 결정 — ChatGPT+제미나이 교차검증, 재논의 금지)

**Background**: §2.2's `p_display_order default null` change on `upsert_menu_core()` has a live-reproduced side effect on the category upsert block (0110:424-446, unrelated to §2.1-§2.4's target fields' own logic) — that block reuses the menu's `p_display_order` parameter as the value for `catchmenu_pos.menu_categories.display_order`, a `NOT NULL DEFAULT 0` column. Confirmed live this turn (temporary transaction, rolled back): an `INSERT ... ON CONFLICT ... DO UPDATE` matching the live category-upsert structure with `p_display_order := NULL` raises `null value in column "display_order" of relation "menu_categories" violates not-null constraint` — and this fires even when the row already exists and the statement would otherwise resolve via the `DO UPDATE` branch, because PostgreSQL validates NOT NULL constraints while constructing the candidate row, before conflict resolution is determined. Full root cause and the "why not just `coalesce(p_display_order, 0)` everywhere" reasoning are in `601142_Logic.md` §4.

**Allowed** (per `601142_Logic.md` §4.2):

```sql
-- before (0110:424-446)
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

-- after
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
      coalesce(p_display_order, 0)
    )
    on conflict (store_id, category_code)
    do update set
      category_name = coalesce(
        excluded.category_name,
        catchmenu_pos.menu_categories
          .category_name
      ),
      display_order = coalesce(
        p_display_order,
        catchmenu_pos.menu_categories.display_order
      ),
      updated_at = now()
    returning id into v_category_id;
  end if;
```

Two changes only, both inside this same block:

1. VALUES clause: `p_display_order` → `coalesce(p_display_order, 0)` (prevents the NOT NULL crash on the true-INSERT path).
2. `do update set`: add `display_order = coalesce(p_display_order, catchmenu_pos.menu_categories.display_order)` (preserves the existing category's `display_order` on omission, instead of silently resetting it — the `on conflict` path must reference the **original `p_display_order` parameter**, not `excluded.display_order`, since the latter is already coalesced to `0` in the VALUES clause and would defeat the preserve-on-omission behavior).

**Forbidden** (within this same category upsert block):

- Changing the `on conflict (store_id, category_code)` matching target.
- Changing the `category_name` coalesce logic or which value (`excluded.category_name` vs. current row) wins.
- Changing the `updated_at = now()` assignment.
- Changing the surrounding `if p_category_code is not null then ... end if;` conditional structure, or anything about *when* this block runs.
- Any change outside this named block — this Slice touches nothing else in `upsert_menu_core()` (§4.3 of `601142_Logic.md`: no interaction with `chk_menu_allergen_object`, `v_clean_allergen_info`, validation order, audit event, or realtime notify logic).

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule, matching the pattern in `601114_ChangeContract.md` §2.7:

**`catchmenu_store.upsert_menu()`**:
- Change the `default` clause of `p_is_kds_required`, `p_kitchen_zone`, `p_display_order`, `p_allergen_codes` from their current hardcoded values to `null` (§2.1). No other line of this function changes.

**`catchmenu_store.upsert_menu_core()`**:
- Change the `default` clause of `p_is_kds_required`, `p_kitchen_zone`, `p_display_order`, `p_allergen_info` from their current hardcoded values to `null` (§2.2).
- Replace the `v_clean_allergen_info` assignment (0110:380-384) with the three-branch `case` in §2.3.
- Change the INSERT clause's `v_clean_allergen_info` reference (0110:487) to `coalesce(v_clean_allergen_info, '{}'::jsonb)` (§2.3).
- Change the UPDATE clause's `allergen_info = v_clean_allergen_info` (0110:527) to `allergen_info = coalesce(v_clean_allergen_info, allergen_info)` (§2.3).
- **(Slice 2, 신규 2026-07-17)** In the category upsert block only (0110:424-446), change the VALUES clause's `display_order` value from `p_display_order` to `coalesce(p_display_order, 0)`, and add `display_order = coalesce(p_display_order, catchmenu_pos.menu_categories.display_order)` to the `on conflict ... do update set` clause (§2.5). No other line of the category upsert block changes — matching key, `category_name` coalesce, `updated_at`, and the surrounding conditional structure stay exactly as-is.
- No other line of this function changes — the `menu_not_found`/`menu_code_duplicate` validation order (Slice 3, `601114_ChangeContract.md` §2.10.1), the `menu_price_changed` audit event, and the realtime notify call are all untouched. (Prior to Slice 2, this bullet also named "the category upsert" as untouched — that blanket statement is now narrowed by the Slice 2 exception immediately above; the category upsert's `display_order` handling is in scope, everything else about it remains out of scope.)

## §4 Forbidden Operations

- Any change to `catchmenu_store.sync_menu_option_groups_core()` or `catchmenu_store.sync_menu_option_items_core()` (§1.2).
- Any change to `catchmenu_store.get_menu_admin_list()`, `catchmenu_store.get_store_admin_dashboard()`, or `catchmenu_store.set_menu_status()` (§1.2).
- Any change to `upsert_menu()`'s or `upsert_menu_core()`'s parameter names, order, count, or types — only the four named parameters' default *values* may change.
- Any change to `upsert_menu_core()`'s UPDATE clause for `is_kds_required`/`kitchen_zone`/`display_order` — it is already correct and out of scope (§2.4).
- Any change to `upsert_menu_core()`'s INSERT clause beyond the single `v_clean_allergen_info` reference named in §3.
- **(Slice 2로 예외 범위 확정, 2026-07-17)** Any change to the category upsert block inside `upsert_menu_core()` (0110:424-446) beyond the two `display_order`-only edits named in §2.5/§3's Slice 2 entry (VALUES clause coalesce-to-0, and the new `display_order` line in `do update set`) — the matching key (`on conflict (store_id, category_code)`), the `category_name` coalesce logic, and the `updated_at` assignment must not change. Any change to validation order (`menu_not_found`/`menu_code_duplicate`), the audit event, or the realtime notify logic inside `upsert_menu_core()` remains forbidden without exception — Slice 2 does not touch any of those.
- Applying the `coalesce(p_x, x)` preserve-on-omission pattern to `p_menu_options` or anything inside `sync_menu_option_groups_core()`/`sync_menu_option_items_core()` — that would break the approved full-replacement contract (`601112_Logic.md` §2.5).
- Creating any new migration file (§1.1) — in-place synchronization of `0110` only.
- Broad refactor of `upsert_menu()` or `upsert_menu_core()` beyond the narrow verbs in §3.
- Introducing a new generic helper, abstraction, or framework not named in §3.

## §5 Forbidden scope

- `601120_dining_table_crud_creation` — cross-reference only (`601141_Overview.md` §3), no function exists yet, not implemented here.
- `601130_menu_price_list_architecture` — unrelated.
- `sql/migrations/0044_create_menu_management_rpc.sql`, `0141_hyper_personalization_menu_customization.sql` — untouched.
- Flutter/client code.
- `menu_options` / relational option-group/option-item logic in its entirety (§1.2).
- Any `0110` function other than `upsert_menu()`/`upsert_menu_core()`.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `chk_menu_allergen_object` is missing or no longer enforces JSONB object-or-null semantics.
2. `upsert_menu_core()`'s live UPDATE clause for `is_kds_required`/`kitchen_zone`/`display_order` is not already in the `coalesce(p_x, x)` shape `601142_Logic.md` §1 documents — i.e. the "no change needed" assumption in §2.4 does not hold against the live source.
3. Completing this fix would require changing `upsert_menu()`'s or `upsert_menu_core()`'s parameter names, order, count, or types (not just default values).
4. `601143_TestPlan.md` §5's re-run of `601113_TestPlan.md`'s four existing UPDATE-path blocks (§3/§7/§9.1/§10.2) shows a value or error different from what `601141_Overview.md` §4 predicted (no regression).
5. Any of §2.3's three `v_clean_allergen_info` branches produces a value that fails `chk_menu_allergen_object` (`601143_TestPlan.md` §3.4).
6. `sql/migrations/0110_create_store_admin_rpc.sql`'s diff touches `sync_menu_option_groups_core()`, `sync_menu_option_items_core()`, `get_menu_admin_list()`, `get_store_admin_dashboard()`, or `set_menu_status()` (`601143_TestPlan.md` §6).
7. `upsert_menu_core()`'s live `pg_proc.proacl` is found to no longer be `NULL` at implementation time (i.e. an explicit ACL now exists) — this would not block the fix itself (the default-null change remains correct and safe either way), but it changes the mandatory-vs-defensive justification recorded in `601142_Logic.md` §1.2/§3(a) and must be reported, not silently absorbed.
8. **(new 2026-07-17, Slice 2)** Completing §2.5 would require changing the category upsert block's `on conflict (store_id, category_code)` matching target, its `category_name` coalesce logic, or its `updated_at` assignment — Slice 2 authorizes only the two `display_order`-scoped edits named in §2.5/§3.
9. **(new 2026-07-17, Slice 2)** §9's Slice 2 approval checkbox has not been checked by Human. Stage 8 may proceed with the original four-item scope under the existing approval, but must not touch the category upsert block in `upsert_menu_core()` until this box is separately checked.

## §7 Required verification

Stage 8 must run `601143_TestPlan_Allergen_Info_And_Sibling_Overwrite_Correction.md` completely.

Required evidence:

1. Pre-flight function/constraint existence and baseline-default checks (§1).
2. `is_kds_required`/`kitchen_zone`/`display_order` preserved (not reset) on a partial update omitting them, after being set to non-default values (§2).
3. `allergen_info` preserved on omission, correctly replaced on an explicit object, and defensively neutralized to `{}` (verified distinct from "preserved") on an explicit non-object value — all three satisfying `chk_menu_allergen_object` (§3).
4. New-menu creation with all four fields omitted still produces `true`/`'MAIN'`/`0`/`{}` (§4).
5. `601113_TestPlan.md`'s four existing UPDATE-path blocks (§3/§7/§9.1/§10.2) re-run unmodified, pass their own original assertions, and additionally show the four sibling fields unchanged at their generation defaults (§5).
6. Source diff boundary: only `upsert_menu()`/`upsert_menu_core()` show changes; `sync_menu_option_groups_core()`/`sync_menu_option_items_core()`/`get_menu_admin_list()`/`get_store_admin_dashboard()`/`set_menu_status()` show zero diff (§6).
7. Live `pg_get_functiondef()` confirms the corrected function bodies are actually active, following the established live-function synchronization procedure (§1.1).
8. **(new 2026-07-17, Slice 2)** A category referenced by an already-existing `category_code` retains its `display_order` when a subsequent `upsert_menu()` call omits `p_display_order`; a brand-new category still gets `0` when `p_display_order` is omitted; an explicit value updates both new and existing categories; and a menu's own `display_order` and its category's `display_order` can diverge and be updated independently, with no `null value in column "display_order"` error on any path (`601143_TestPlan.md` §7, added 2026-07-17).

## §8 Open Items (carried from `601141_Overview.md` §6 and `601142_Logic.md` §3)

(a) **[해소]** Whether §2.2 (`upsert_menu_core()`'s own default change) is mandatory or merely defensive — resolved as mandatory per `601142_Logic.md` §1.2/§3(a) (proacl=NULL evidence) and included in this contract's Allowed Operations (§3).

(b) Whether any hidden caller has always sent full explicit values for the four fields (making the bug currently unobservable to them) — `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` §1 already confirmed zero Flutter callers; not re-confirmed in this workpacket (same-fact-once principle). If a store-admin console or other client begins calling `upsert_menu()` with partial updates before this fix ships, it would be exposed to the bug in the interim — not a blocker for this contract, noted for awareness.

(c) `601120_dining_table_crud_creation` — when actually started, its design should use `default null` + `coalesce(p_x, x)` from the outset to avoid this same defect class (`601141_Overview.md` §3). Cross-reference only; not implemented here.

(d) `catchmenu_pos.get_menu_catalog()` (`0044`) and other read paths consuming these four fields were not investigated for indirect effects of this fix — this workpacket only touches the write path (`601141_Overview.md` §6 (d)). Since this fix only changes *when* a value is preserved vs. reset (never changes what a successfully-written value looks like), no read-path impact is expected, but it was not verified.

(e) **[신규, 2026-07-17, Slice 2에서 발견]** `p_display_order`가 메뉴(`catchmenu_pos.menus.display_order`)와 카테고리(`catchmenu_pos.menu_categories.display_order`) 두 리소스에 재사용(오버로딩)되는 근본 설계 문제는 Slice 2(§2.5)로 "당장의 NOT NULL 크래시"만 해소됐을 뿐 해결되지 않았다. 근본 해결(`p_menu_display_order`/`p_category_display_order` 파라미터 분리)은 `upsert_menu()` 공개 시그니처 변경이 필요해 별도 워크패킷 후보(가칭 "Menu/Category Display Order Parameter Contract Separation")로 남긴다 — 착수 시 확인할 파급효과는 `601142_Logic.md` §3 (e)에 기록됨. 지금은 조사·구현하지 않는다.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation:

☑ I approve the `upsert_menu()`/`upsert_menu_core()` default-value-only signature
  change for `p_is_kds_required`/`p_kitchen_zone`/`p_display_order`/
  `p_allergen_codes`(`p_allergen_info`) from hardcoded non-null values to
  `default null` (§2.1/§2.2), including the mandatory (not merely defensive)
  scope of `upsert_menu_core()`'s own signature per the `proacl=NULL`
  direct-call-bypass evidence (§0/§2.2).

☑ I approve the `v_clean_allergen_info` NULL/explicit-object/defensive-neutralize
  three-way redesign in `upsert_menu_core()`, including its INSERT and UPDATE
  clause use sites (§2.3), on the understanding that a non-object input is
  neutralized to `{}` and is explicitly NOT preserved (distinct from omission).

☑ I approve that `menu_options`/`sync_menu_option_groups_core()`/
  `sync_menu_option_items_core()`/`get_menu_admin_list()`/
  `get_store_admin_dashboard()`/`set_menu_status()` are entirely out of scope
  and no-regression-only under this contract (§1.2/§4).

☑ I approve in-place synchronization of
  `sql/migrations/0110_create_store_admin_rpc.sql` as the sole authorized
  implementation path (§1.1) — no new migration file is authorized. (2026-07-17)

☑ **(Slice 2, new 2026-07-17 — added after the four boxes above were checked,
  not covered by that approval)** I approve Slice 2 (§2.5): in the category
  upsert block inside `upsert_menu_core()` only (0110:424-446), coalescing the
  `display_order` VALUES-clause entry to `0` on the true-INSERT path, and
  adding `display_order = coalesce(p_display_order,
  catchmenu_pos.menu_categories.display_order)` to the `on conflict ... do
  update set` clause on the existing-category path — fixing a live-reproduced
  NOT NULL crash that the already-approved §2.2 (`p_display_order default
  null`) change otherwise introduces, without creating a new silent-reset bug
  on the update path. No change to the category matching key, `category_name`
  logic, or `updated_at` assignment. The underlying `p_display_order`
  menu/category parameter-reuse design issue is not fixed here — carried as a
  new Open Item (§8 (e)) for a future, separately-scoped workpacket. (2026-07-17)

## §10 Approval state

**Current approval state: APPROVED for all items 1-5 (2026-07-17).**

Stage 8 may proceed with the original four-item scope plus Slice 2 (§2.5). `601143_TestPlan.md` §7 carries the required Slice 2 test coverage.
