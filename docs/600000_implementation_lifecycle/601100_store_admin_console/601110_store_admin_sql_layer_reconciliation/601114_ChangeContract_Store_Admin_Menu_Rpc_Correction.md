# 601114_ChangeContract_Store_Admin_Menu_Rpc_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`store_admin_menu_rpc_correction`

## §0 Contract summary

**(2026-07-16 정정, Stage 4 Architecture Verification — Cursor+Codex+안티 삼중 검증에서 발견)** This section originally stated the price boundary as "use `additional_price`, `price_delta` out of scope" — that was inconsistent with `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §1.2/§2.4, which established `price_delta` as the canonical option-item price field (via full read of `0141_hyper_personalization_menu_customization.sql`) and implements `sync_menu_option_items_core()` writing `price_delta`, not `additional_price`. The boundary below is corrected to match Logic. See §2.6 for the updated price-field contract.

This ChangeContract authorizes only the Stage 4 implementation needed to correct the store-admin menu SQL layer described in `601112_Logic_Store_Admin_Menu_Rpc_Correction.md` §0-§6, with the boundary that option item price writes in this workpacket use `price_delta` (canonical), leave `additional_price` untouched, and defer the resulting `get_menu_catalog()` (0044) customer-facing read-path inconsistency to a future workpacket — the broader price-list architecture itself remains out of scope for this contract and lives in `601130_menu_price_list_architecture`.

The public API goal is:

- keep public `catchmenu_store.upsert_menu()` available as the single external store-admin menu write RPC;
- internally split it into `upsert_menu_core()` + `sync_menu_option_groups_core()` + `sync_menu_option_items_core()`;
- keep all three layers in one transaction;
- fix the 0110 phantom column drift and allergen JSONB object handling;
- fix the same `allergen_codes` crash class in `get_menu_admin_list()` and `get_store_admin_dashboard()`;
- do not change price-list architecture, `0141`, `0044`, table CRUD, or Flutter/client code.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file (corrected 2026-07-17, Stage 6 Contract Verification finding)

**This section previously allowed an undefined "new forward migration" alternative to in-place editing, without naming it or adding it to Allowed Files — that was inconsistent with the rest of this contract (Allowed Files names only `0110`) and with §5's live-function synchronization procedure, which is written exclusively for the in-place case. This is now resolved: in-place synchronization of `0110` is the only authorized path. No new migration file is authorized by this contract.**

The only file allowed for this workpacket's SQL body changes is:

- `sql/migrations/0110_create_store_admin_rpc.sql` (in-place synchronization only)

Required procedure: the established live-function synchronization rule in §5 (source file update → CRLF→LF normalized checksum → `migration_history` checksum update → direct live re-execution → `pg_get_functiondef()` verification). No other file, and no new migration number, is authorized.

If Stage 4 determines that in-place synchronization is not viable for a reason not anticipated by this contract, Stage 4 must stop and return to Stage 5 for a new Human-approved boundary that explicitly names the new migration file — not proceed under this contract's existing Allowed Files.

### §1.2 Allowed existing function bodies (reclassified 2026-07-17, Stage 6 Contract Verification finding)

**This section previously listed `set_menu_status()` alongside the three functions this workpacket actually modifies, under one undifferentiated "allowed" label — that blurred a real distinction and left it ambiguous whether `set_menu_status()`'s body may be edited. It is reclassified below into two explicit categories.**

**Allowed existing function bodies — modification authorized:**

- `catchmenu_store.upsert_menu(...)` (§2.1: internal body replaced to delegate to the three-layer structure; public signature unchanged)
- `catchmenu_store.get_menu_admin_list(...)` (§2.3: phantom column corrections; §2.9: Slice 2 `category_summary` nested-aggregate fix, added 2026-07-17)
- `catchmenu_store.get_store_admin_dashboard(...)` (§2.3/§2.4: `allergen_codes` crash fix, menu-summary scope only)

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_store.set_menu_status(...)`

`set_menu_status()` is in scope only as a diff-zero verification target (`601113_TestPlan.md` §10, §11.1's source diff boundary) — Stage 4 must not edit its body. If Stage 4 finds a reason `set_menu_status()` needs to change (e.g. a dependency on a phantom column this contract did not anticipate), that is a Stop Condition (§4), not an in-scope edit — it requires returning to Stage 5 for a new boundary, not proceeding under this contract.

### §1.3 Allowed new internal helper functions

Allowed helper functions:

- `catchmenu_store.upsert_menu_core(...)`
- `catchmenu_store.sync_menu_option_groups_core(...)`
- `catchmenu_store.sync_menu_option_items_core(...)`

These helpers must remain internal implementation structure for `upsert_menu()` and must not expand the public API surface beyond the approved store-admin menu correction scope.

## §2 Required implementation contract (restructured 2026-07-17, Stage 6 Contract Verification finding)

**§2.1-§2.6 below are the detailed technical contract (unchanged in substance). §2.7 restates them as an explicit `Allowed Operations` list of narrow verbs, and §2.8 as a `Forbidden Operations` list — matching the Operation Granularity Rule pattern in `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14 ("the smallest executable operation set that can satisfy the change," not a broad permission like "update the RPC"). This closes a gap Stage 6 found: the contract previously stated intent narratively but never forced it into the narrow-verb form the pipeline's own governance guide requires.**

### §2.1 Public `upsert_menu()` contract preservation

Public `upsert_menu()` must remain the externally callable store-admin menu write RPC.

The existing public compatibility parameter names may remain, including:

- `p_thumbnail_url`
- `p_allergen_codes`
- `p_menu_options`

But these names must be mapped internally to the real current schema:

- `p_thumbnail_url` → `catchmenu_pos.menus.image_url`
- `p_allergen_codes` → `catchmenu_pos.menus.allergen_info`
- `p_menu_options` → relational `catchmenu_pos.menu_option_groups` and `catchmenu_pos.menu_option_items`

### §2.2 Three-layer structure

The implementation must use the approved three-layer structure:

1. `upsert_menu_core()` handles the menu row itself.
2. `sync_menu_option_groups_core()` synchronizes option groups.
3. `sync_menu_option_items_core()` synchronizes option items.

All three layers must execute in the same PostgreSQL transaction when called through `upsert_menu()`.

### §2.3 Phantom column correction

The following physical column drifts must be corrected:

| Old/stale reference | Required correction |
|---|---|
| `thumbnail_url` | `image_url` |
| `allergen_codes` | `allergen_info` |
| `menu_options` | `menu_option_groups` / `menu_option_items` relational tables |
| `pos_sync_at` | remove from returned/admin list logic; no physical column substitute |

### §2.4 Allergen JSONB object handling

`allergen_info` is a JSONB object, not an array.

Therefore:

- `jsonb_array_length()` must not be applied to `allergen_info`.
- count logic must use object-safe logic such as `jsonb_object_keys()` or an equivalent object-aware expression.
- `chk_menu_allergen_object` must remain satisfied.

### §2.5 Full replacement option sync

`p_menu_options` is the final desired state for the menu's option tree.

Required behavior:

- group matching key: `menu_id + group_code`
- item matching key: `option_group_id + item_code`
- groups absent from the latest `p_menu_options` become `is_active=false`
- items absent from the latest `p_menu_options` become `is_active=false`
- no physical DELETE for replacement cleanup

### §2.6 Price field boundary (corrected 2026-07-16)

For this workpacket, option item price sync uses `price_delta` (canonical, per `601112_Logic.md` §1.2/§2.4). `additional_price` is intentionally left unwritten — new option items created through `upsert_menu()` will keep `additional_price` at its schema default (`0`, per `chk_option_item_price`/column default), and existing `additional_price` values are not modified by this workpacket.

Required implementation behavior:

- `sync_menu_option_items_core()` writes `price_delta` from `p_menu_options[].items[].price_delta` on both INSERT and UPDATE (`on conflict ... do update set price_delta = excluded.price_delta`).
- `additional_price` must not appear in the INSERT column list or the `on conflict ... do update` clause of `sync_menu_option_items_core()`.

Known consequence, explicitly accepted by this contract (not something Stage 4 needs to fix): `catchmenu_pos.get_menu_catalog()` (`0044`) still reads `additional_price` for the customer/kiosk-facing option price — since this workpacket does not write `additional_price`, an admin-edited option price will not be reflected in what customers see until the `get_menu_catalog()` read-path fix (carried as a separate Open Item, §6 (a)) lands.

Forbidden in this workpacket:

- changing `0141_hyper_personalization_menu_customization.sql`
- changing the broader price-list model
- adding a write path from `upsert_menu()` to `additional_price` (that would require resolving the `get_menu_catalog()` inconsistency now, which is explicitly deferred)

The broader price architecture remains in `601130_menu_price_list_architecture`.

### §2.7 Allowed Operations (narrow verbs, new 2026-07-17)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule — narrow verbs naming the exact function/line-level action, not a broad permission:

**`catchmenu_store.upsert_menu()`** (public, signature unchanged, §2.1):
- Replace the entire prior body with: a call to `catchmenu_store.upsert_menu_core(...)` (mapping `p_thumbnail_url`→`p_image_url` and `p_allergen_codes`→`p_allergen_info` at the call site), followed by a call to `catchmenu_store.sync_menu_option_groups_core(...)` passing `p_menu_options`, followed by a loop calling `catchmenu_store.sync_menu_option_items_core(...)` once per group returned by `sync_menu_option_groups_core()`. After this refactor, `upsert_menu()` is a thin orchestrator — it contains no menu-row logic of its own.

**`catchmenu_store.upsert_menu_core()`** (new internal helper, §1.3/§2.2):
- Create this function containing the menu-row logic moved from `upsert_menu()`'s prior body — category upsert, `menu_code_duplicate` check, the menu-row INSERT/UPDATE with `thumbnail_url`→`image_url` and `allergen_codes`→`allergen_info` column renames applied (§2.3), the price-change `menu_price_changed` audit event, and the realtime notify call. **(2026-07-17 정정, Stage 6 3차 검증 — Cursor 단독 발견)** This logic — including the audit event — must move into `upsert_menu_core()`, not remain in the thin `upsert_menu()` wrapper described above; a prior draft of this bullet list attributed "do not remove the audit event" to `upsert_menu()` itself, which no longer holds any of this logic after the refactor.
- **(2026-07-17 정정, Human 결정 — Cursor+Codex+안티 조사 일치, 재논의 금지)** While moving the `menu_price_changed` audit event insert into this function, correct `event_domain` from `'menu'` to `'system'`. `'menu'` is not, and never has been, a valid value — `catchmenu_ledger.events.chk_event_domain` (as widened by `sql/migrations/0150_widen_event_domain_constraint.sql`) only allows `'session'`/`'order'`/`'payment'`/`'kds'`/`'delivery'`/`'inventory'`/`'staff'`/`'device'`/`'agent'`/`'recovery'`/`'knowledge'`/`'gateway'`/`'system'`/`'waiting'`. This is a pre-existing defect inherited from the original `0110` body, not something this workpacket introduces — but since the insert statement is already being relocated into `upsert_menu_core()` as part of the approved Slice 1 refactor (§2.2), the value is corrected in the same motion rather than carrying the violation forward unchanged. `'system'` was chosen over `'order'` (the event is catalog/master-data configuration, not an order-lifecycle transaction — using `'order'` would make future `event_domain = 'order'` queries incorrectly include menu price edits) and over `'inventory'` (that domain is used elsewhere for stock/ingredient-level tracking, e.g. `sql/migrations/0054_create_inventory_rpc.sql`, a distinct concept from menu/catalog master data). No other field of the event (`event_type = 'menu_price_changed'`, `subject_type = 'menu'`, payload shape) changes.
- Do not add option-group or option-item logic to this function.
- **(2026-07-17 정정, Slice 3, §2.10.1 — Antigravity 발견)** Run the `menu_not_found` and `menu_code_duplicate` validation checks *before* the category `insert ... on conflict ... do update` block, not after — see §2.10.1 for the full root-cause and boundary. This is a statement reorder only; no validation logic itself changes.

**`catchmenu_store.sync_menu_option_groups_core()`** (new internal helper, §1.3/§2.5):
- Create this function performing `on conflict (menu_id, group_code) do update` upsert into `catchmenu_pos.menu_option_groups` for each array element of the input.
- Add the soft-deactivation step: `update catchmenu_pos.menu_option_groups set is_active = false` for existing groups of this menu whose `group_code` is absent from the input array.
- **(2026-07-17 정정, Slice 3, §2.10.2 — Cursor+Claude Code 공통 발견)** Capture `returning id, group_code` on that soft-deactivation `update`, and append one `{group_id, group_code, items: []}` entry to the returned `v_result` per deactivated group — see §2.10.2. Without this, `upsert_menu()`'s downstream item-sync loop never runs for a fully-omitted group, so its items silently stay active.

**`catchmenu_store.sync_menu_option_items_core()`** (new internal helper, §1.3/§2.5/§2.6):
- Create this function performing `on conflict (option_group_id, item_code) do update` upsert into `catchmenu_pos.menu_option_items`, writing `price_delta` (not `additional_price`) on both the INSERT column list and the `on conflict ... do update` clause.
- Add the soft-deactivation step for items of this group whose `item_code` is absent from the input array.

**`catchmenu_store.get_menu_admin_list()`** (§2.3):
- In the menu-JSON `jsonb_build_object`, remove `'thumbnail_url', m.thumbnail_url` and add `'image_url', m.image_url`.
- Remove `'allergen_codes', m.allergen_codes` and its `jsonb_array_length(coalesce(m.allergen_codes, '[]'::jsonb))` count expression; add `'allergen_info', m.allergen_info` and an object-safe count using `jsonb_object_keys(coalesce(m.allergen_info, '{}'::jsonb))` (§2.4).
- Remove `'menu_options', m.menu_options`; add an `'option_groups'` key populated by a correlated subquery against `catchmenu_pos.menu_option_groups`/`menu_option_items` (per `601112_Logic.md` §3).
- Remove `'pos_sync_at', m.pos_sync_at`. Do not remove or alter the `is_pos_synced` expression — it does not reference a phantom column.
- **(2026-07-17 정정, Slice 2)** Rewrite the `category_summary` query per §2.9's bounded fix (nested-aggregate correction only — see §2.9 for exactly what is/isn't allowed there). Do not touch any other part of this function's body (total/sold-out counts outside `category_summary`).

**`catchmenu_store.get_store_admin_dashboard()`** (§2.3/§2.4):
- In the menu-summary aggregate only, replace the `jsonb_array_length(coalesce(allergen_codes, '[]'::jsonb)) = 0` filter with `coalesce(allergen_info, '{}'::jsonb) = '{}'::jsonb`.
- Do not touch any other section of this function (staff summary, hours, holidays, POS integration, membership).

**`catchmenu_store.set_menu_status()`**:
- No operation is allowed on this function's body — see §1.2. It is a diff-zero verification target only.

### §2.8 Forbidden Operations (new 2026-07-17)

Project-wide defaults plus workpacket-specific prohibitions (mirroring `000701` §9.14's Forbidden Operations pattern):

- Broad refactor of any function beyond the narrow verbs listed in §2.7.
- Introducing a new generic helper, abstraction, or framework not named in §2.7.
- Unrequested renaming of any function, parameter, table, or column beyond the four phantom-column corrections in §2.3.
- Formatting-only diff to any line not otherwise touched by an operation in §2.7.
- Encoding normalization.
- Any edit to `catchmenu_store.set_menu_status()`'s body (§1.2, §2.7).
- Any edit not explicitly covered by §2.7.
- Adding a write path from `upsert_menu()` to `additional_price` (§2.6).
- Creating any new migration file (§1.1) — in-place synchronization of `0110` only.

### §2.9 Slice 2 — `category_summary` correction (new 2026-07-17, Human 결정, ChatGPT+제미나이 교차검증, 재논의 금지)

**Background**: during Stage 8 implementation, `get_menu_admin_list()`'s `category_summary` block was found to crash with `aggregate function calls cannot be nested` — a pre-existing defect that predates this workpacket and is unrelated to the four phantom columns (`thumbnail_url`/`allergen_codes`/`menu_options`/`pos_sync_at`) this contract otherwise governs. Human decision: rather than splitting this into a separate workpacket or fixing it silently under the existing scope, it is added as an explicit, separately-bounded "Slice 2" within this same ChangeContract — see §7 for its own approval checkbox, which is not covered by the existing approval of the original four items.

**Root cause** (verified directly against `sql/migrations/0110_create_store_admin_rpc.sql`, `get_menu_admin_list()`, current `category_summary` block): the query wraps `count(m.id)` (and its two `filter (...)` variants) directly inside `jsonb_build_object(...)`, which is itself an argument to the outer `jsonb_agg(...)`:

```sql
select coalesce(
  jsonb_agg(
    jsonb_build_object(
      'category_code', mc.category_code,
      'category_name', mc.category_name,
      'menu_count', count(m.id),
      'sold_out_count', count(m.id) filter (where m.menu_status = 'SOLD_OUT'),
      'hidden_count', count(m.id) filter (where m.menu_status = 'HIDDEN')
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
group by mc.id, mc.category_code, mc.category_name, mc.display_order;
```

Two aggregate calls (`count(...)` inside, `jsonb_agg(...)` outside) are nested in the same `SELECT` — PostgreSQL rejects this outright, regardless of data present. This is a syntax-level defect, not a data-dependent one; it would have crashed on the very first non-empty call, independent of the phantom-column fixes.

**JOIN-structure investigation (Human 작업 지시 4항, completed)**: checked whether `count(m.id)` risks double-counting a menu due to JOIN fan-out. **Finding: no risk.** `catchmenu_pos.menus.category_id` is declared as a single scalar `uuid references catchmenu_pos.menu_categories(id)` (`sql/migrations/0011_create_pos_menu.sql:55`) — a plain many-to-one foreign key, not a junction table or array. Each menu row can match at most one `menu_categories` row via this JOIN, so `left join ... on m.category_id = mc.id` cannot produce more than one output row per menu. `count(m.id)` and `count(distinct m.id)` are therefore equivalent here; `distinct` is not required.

**Allowed** (Human 결정, ChatGPT 제안 그대로):
- Rewrite the `category_summary` query as a two-stage structure: an inner `GROUP BY` pre-aggregation subquery (computing `menu_count`/`sold_out_count`/`hidden_count` per category, one row per category, no nested aggregates) feeding an outer `jsonb_agg(jsonb_build_object(...))` that only re-shapes already-aggregated scalar values into JSON — no aggregate function may appear inside the outer `jsonb_build_object(...)` call.
- Suggested corrected form (Stage 8 may adjust column list/aliasing as needed, subject to the constraints below):

```sql
select coalesce(
  jsonb_agg(
    jsonb_build_object(
      'category_code', category_code,
      'category_name', category_name,
      'menu_count', menu_count,
      'sold_out_count', sold_out_count,
      'hidden_count', hidden_count
    )
    order by display_order
  ),
  '[]'::jsonb
)
into v_category_summary
from (
  select
    mc.category_code,
    mc.category_name,
    mc.display_order,
    count(m.id) as menu_count,
    count(m.id) filter (where m.menu_status = 'SOLD_OUT') as sold_out_count,
    count(m.id) filter (where m.menu_status = 'HIDDEN') as hidden_count
  from catchmenu_pos.menu_categories mc
  left join catchmenu_pos.menus m
    on m.category_id = mc.id
    and m.is_active = true
  where mc.store_id = p_store_id
    and mc.tenant_id = p_tenant_id
  group by mc.id, mc.category_code, mc.category_name, mc.display_order
) as category_agg;
```

- Returned JSON structure and key names (`category_code`/`category_name`/`menu_count`/`sold_out_count`/`hidden_count`, array under the same `categories` key in the outer response) must stay identical to the original (broken) query's intended shape.
- Aggregate semantics must be reproduced exactly as originally intended: `menu_count` = all active menus in the category, `sold_out_count`/`hidden_count` = the same subsets filtered by `menu_status`. No redefinition of what counts as "sold out" or "hidden."

**Forbidden** (Human 결정, ChatGPT 제안 그대로):
- Changing the returned JSON structure (key names, array vs. object shape, nesting).
- Changing the aggregate definitions themselves (e.g. redefining which `menu_status` values count as sold-out).
- Extending this refactor to any other admin statistics function (e.g. touching `get_store_admin_dashboard()`'s own aggregates beyond what §2.3/§2.4 already authorize).
- Any performance-tuning-motivated change beyond what fixing the nesting error requires (no added indexes, no query restructuring for speed).
- Introducing `count(distinct m.id)` — the investigation above confirms it is unnecessary; using it anyway would be an unrequested, unexplained deviation from the minimal fix.

### §2.10 Slice 3 — category-row leak + item-cascade fix (new 2026-07-17, Human 결정, 안티 발견, Cursor/Codex 검증 대상, 재논의 금지)

**Background**: discovered during Stage 9 independent verification (Antigravity for the category leak; Cursor+Claude Code jointly for the item-cascade gap). Both defects live in the same three-layer `upsert_menu()` machinery this workpacket already owns, and are fixed together as Slice 3 rather than split into another separate workpacket — same reasoning as Slice 2 (§2.9).

#### §2.10.1 Category-row leak on validation failure (primary trigger)

**Root cause** (verified live against `catchmenu_store.upsert_menu_core()`): the category `INSERT ... ON CONFLICT ... DO UPDATE` runs *before* the `menu_not_found` and `menu_code_duplicate` validation checks. Both validations return via `catchmenu_common.build_error_response(...)` — a normal `jsonb` return value, not a raised exception — so when either validation fails, PostgreSQL has no reason to roll back anything that already executed earlier in the same call. The category row (freshly inserted, or its `category_name`/`updated_at` freshly touched via the `ON CONFLICT` branch) commits along with the rest of the (otherwise failed) call. This is a real, reproducible data leak: a caller can create arbitrary orphan/updated category rows purely by supplying an already-used `p_menu_code`, with no menu ever actually being created.

**Allowed**:
- Inside `upsert_menu_core()`, move the `menu_not_found` check (currently gated on `not v_is_new`) and the `menu_code_duplicate` check (currently gated on `v_is_new and p_menu_code is not null and exists(...)`) to run *before* the `if p_category_code is not null then insert into catchmenu_pos.menu_categories ...` block. `v_is_new := p_menu_id is null;` must be computed before these checks, same as today — only its position relative to the category-insert block changes.
- The category insert itself runs only after both validations pass, otherwise unchanged (same `on conflict (store_id, category_code) do update`, same column list, same `returning id into v_category_id`).
- Returned JSON structure, `error.key` values (`menu_not_found`, `menu_code_duplicate`), and all success-path behavior must be byte-identical to today — this is a pure statement-reordering fix, not a behavior change on any path that doesn't already fail.

**Forbidden**:
- Any change to the category upsert logic itself (matching key, `on conflict` target, column list, `do update` clause).
- Reordering anything else in the function — the menu-row INSERT/UPDATE, the price-change audit event, the realtime notify call, and their relative order to each other stay exactly where they are today. Only the two validation checks move, and only relative to the category insert.
- Adding a new error key, changing an existing error key's wording, or changing `p_error_key`/`p_rpc_name` values.

#### §2.10.2 Item cascade on fully-omitted group (companion fix, same function family)

**Root cause** (verified live, Stage 9 finding): `sync_menu_option_groups_core()`'s `v_result` — the value `upsert_menu()`'s downstream loop iterates to call `sync_menu_option_items_core()` once per group — is built only from groups present in the *current* `p_menu_options` input. The trailing `update ... set is_active = false ... where not (group_code = any(v_group_codes))` correctly deactivates omitted groups in the database, but never adds them to `v_result`. Consequence: when a group is dropped entirely from `p_menu_options`, `sync_menu_option_items_core()` is never invoked for it, so its items keep whatever `is_active` value they had before — not cascaded to `false` the way §2.5 requires ("items absent from the latest `p_menu_options` become `is_active=false`"). `sync_menu_option_items_core()`'s own logic is correct and untouched by this fix — the defect is purely that it's never called for these groups.

**Allowed**:
- Change the trailing `update catchmenu_pos.menu_option_groups set is_active = false ...` statement to capture `returning id, group_code`, and for each row it deactivates, append an entry to `v_result`: `jsonb_build_object('group_id', <returned id>, 'group_code', <returned group_code>, 'items', '[]'::jsonb)`.
- This relies entirely on `sync_menu_option_items_core()`'s existing, unmodified "items absent from `p_items` become `is_active=false`" logic — passing it an empty `items` array for a deactivated group causes all of that group's items to be soft-deactivated through the same code path already used for partial item removal within a still-present group.

**Forbidden**:
- Any change to `sync_menu_option_items_core()` itself.
- Any change to how the group-level deactivation `UPDATE` selects its target rows (matching key, `not (group_code = any(v_group_codes))` condition) — only its `RETURNING` clause and the addition of the loop appending to `v_result` are in scope.
- Physically deleting the omitted group's items instead of soft-deactivating them (still full-replacement / soft-deactivation only, per §2.5).

## §3 Forbidden scope

The following are explicitly forbidden:

- `sql/migrations/0044_create_menu_management_rpc.sql`
- `sql/migrations/0141_hyper_personalization_menu_customization.sql`
- price-list / price-table architecture changes
- `601130_menu_price_list_architecture` implementation
- table CRUD work from `601120`
- Flutter/client code
- adding a write path to `additional_price` from `upsert_menu()` (§2.6 — that would require resolving the `get_menu_catalog()` inconsistency, deferred)
- `price_list`-related schemas/functions
- physical deletion of option groups/items as the full-replacement mechanism
- public API breaking changes to `upsert_menu()` unless Human explicitly re-approves a new boundary
- unrelated 0110 functions outside the four allowed function bodies and three approved helpers

## §4 Stop Conditions

Stop immediately and report if any of the following are true:

1. `uq_option_group_menu_code` is missing.
2. `uq_option_item_group_code` is missing.
3. `chk_menu_allergen_object` is missing or no longer enforces JSONB object semantics.
4. `catchmenu_pos.menus.image_url` is missing.
5. `catchmenu_pos.menus.allergen_info` is missing.
6. `catchmenu_pos.menu_option_groups.is_active` is missing.
7. `catchmenu_pos.menu_option_items.is_active` is missing.
8. `catchmenu_pos.menu_option_items.price_delta` is missing (corrected 2026-07-16 — `price_delta`, not `additional_price`, is the column this workpacket writes; see §2.6).
9. The implementation would require modifying `0044`, `0141`, or price-list architecture. (2026-07-16: `price_delta` removed from this stop condition — writing `price_delta` is now required behavior, not a boundary violation; see §2.6.)
10. Full replacement cannot be implemented without physical DELETE.
11. A new schema column is required beyond already-existing relational option/menu columns.
12. The public `upsert_menu()` signature must be changed to complete the task.
13. `get_menu_admin_list()` or `get_store_admin_dashboard()` requires an unrelated redesign rather than the approved allergen/phantom correction.
14. **(new 2026-07-17, Slice 2)** The `category_summary` fix would require anything beyond the two-stage GROUP BY-subquery + outer `jsonb_agg` restructuring in §2.9 — e.g. a returned-JSON structure change, an aggregate-definition change, or extending the fix to another admin statistics function.
15. **(new 2026-07-17, Slice 2)** §7's Slice 2 approval checkbox has not been checked by Human. Stage 8 may proceed with the original four-item scope under the existing approval, but must not touch `category_summary` until this box is separately checked.
16. **(new 2026-07-17, Slice 3)** The category-leak fix (§2.10.1) would require anything beyond reordering the two existing validation checks ahead of the category insert — e.g. a new error key, a change to the category upsert logic itself, or reordering any other statement in `upsert_menu_core()`.
17. **(new 2026-07-17, Slice 3)** The item-cascade fix (§2.10.2) would require any change to `sync_menu_option_items_core()` itself, or any change to the group-deactivation `UPDATE`'s target-row selection beyond adding a `RETURNING` clause.
18. **(new 2026-07-17, Slice 3)** §7's Slice 3 approval checkbox has not been checked by Human. Stage 8 may proceed with the original scope and Slice 2 (if separately approved) under their own approvals, but must not touch the validation order in `upsert_menu_core()` or the return-value construction in `sync_menu_option_groups_core()` until this box is separately checked.

## §5 Required verification

Stage 4 must run `601113_TestPlan_Store_Admin_Menu_Rpc_Correction.md` completely.

Required evidence:

1. Pre-flight schema/constraint checks.
2. `upsert_menu()` new-menu creation with option groups/items.
3. `upsert_menu()` full-replacement update with soft deactivation, including verification that `price_delta` on a retained item was actually updated to the new value (`601113_TestPlan.md` §3.3, added 2026-07-17).
4. `get_menu_admin_list()` execution without phantom/allergen crash, and its `option_groups` JSON has the correct nested `items`/`price_delta` structure (`601113_TestPlan.md` §4.3, added 2026-07-17).
5. `get_store_admin_dashboard()` execution without `allergen_codes` crash.
6. Transaction atomicity failure test.
7. A `menu_price_changed` audit event in `catchmenu_ledger.events` on price change, and confirmed absence of one when price does not change (`601113_TestPlan.md` §7/§9.1, added 2026-07-17).
8. `upsert_menu_core()`/`sync_menu_option_groups_core()`/`sync_menu_option_items_core()` confirmed to exist live as separate `catchmenu_store` functions (`601113_TestPlan.md` §8, added 2026-07-17).
9. Idempotent re-run with identical input produces no duplicate rows and no spurious audit event; `menu_code_duplicate` still returns its friendly error (`601113_TestPlan.md` §9, added 2026-07-17).
10. `set_menu_status()` no-regression check.
11. Boundary diff for `0044` and `0141` equals zero.
12. `price_delta` correctly written by `sync_menu_option_items_core()` on both insert and update (corrected 2026-07-16); `additional_price` confirmed untouched (unchanged on update, at schema default on insert).
13. Live `pg_get_functiondef()` confirms the corrected function bodies are actually active.
14. **(new 2026-07-17, Slice 2)** `category_summary` executes without the `aggregate function calls cannot be nested` error, across the edge cases in `601113_TestPlan.md` §4's Slice 2 test cases (added 2026-07-17), and the returned `categories` JSON structure/key names/aggregate semantics are unchanged from the pre-fix intent.
15. **(new 2026-07-17, Slice 3)** A `menu_code_duplicate` (or `menu_not_found`) failure leaves zero trace in `catchmenu_pos.menu_categories` — no new row, no updated `category_name`/`updated_at` on an existing row (`601113_TestPlan.md`'s new Slice 3 case, added 2026-07-17).
16. **(new 2026-07-17, Slice 3)** An item belonging to a group fully omitted from `p_menu_options` is soft-deactivated (`is_active=false`) along with its group, not left `is_active=true`.

If an already-applied migration file is modified in place, Stage 4 must follow the established live-function synchronization rule:

1. source file update;
2. CRLF→LF normalized checksum calculation;
3. `migration_history` checksum update;
4. direct live re-execution of the function body;
5. `pg_get_functiondef()` verification.

Checksum update alone is not sufficient evidence of live behavior.

## §6 Open Items carried from `601112_Logic.md` §6

The following remain outside this ChangeContract:

(a) `catchmenu_pos.get_menu_catalog()` in `0044` still follows the older option-price read path (`additional_price`). Because this workpacket writes `price_delta`, not `additional_price` (§2.6), admin-edited option prices will not appear in what `get_menu_catalog()` returns to customers until this is fixed. The broader customer-facing/catalog price consistency issue is not fixed here.

(b) **[해소/정정, 2026-07-16 — Stage 4 Architecture Verification]** This item originally read: "The project still needs a separate decision on option price-field policy... across `additional_price`, `price_delta`, and future price-list architecture." That decision has been made — `601112_Logic.md` §1.2/§2.4 established `price_delta` as canonical for option-item price writes, and §2.6 above reflects it. What remains open is narrower and is already tracked as (a): the `get_menu_catalog()` read-side consistency fix.

(c) `menu_code_duplicate` still has a possible race between manual duplicate checking and the final `uq_menu_store_code` database constraint. This workpacket preserves existing behavior and does not introduce a new concurrency solution.

(d) Optimistic concurrency / `menu_version` remains a Human decision item and is not implemented here.

(e) Existing Store Admin Console open items from `601111_Overview.md` remain valid: staff management, business hours, holidays, store settings, POS integration, domain numbering, and `601120` table CRUD work.

(f) Price List architecture was physically separated into `601130_menu_price_list_architecture`; it must not be reintroduced into this workpacket.

(g) **[신규, 2026-07-17, Human 결정 — Cursor+Codex+안티 조사 일치, 재논의 금지]** `catchmenu_store.get_store_admin_dashboard()`'s `store_settings` section references four stale/phantom column names, verified directly against `sql/migrations/0049_create_store_settings_rpc.sql`'s live `catchmenu_store.store_settings` table definition:

| Referenced in `0110` | Live reality |
|---|---|
| `max_waiting_count` | Real column is `max_wait_number` (`0049:41`) — a rename-class phantom, same pattern as this workpacket's `thumbnail_url`/`allergen_codes` fixes. Also referenced incorrectly under the same stale name in `0099_create_realtime_pipeline_rpc.sql`/`0100_create_staff_app_bootstrap_rpc.sql` (not this workpacket's concern — noted only because it shows this specific stale name is not unique to `0110`). |
| `min_order_amount` | No corresponding column exists anywhere in `store_settings` — a pure phantom, same class as this workpacket's `pos_sync_at` finding. |
| `receipt_print_enabled` | No corresponding column exists — pure phantom. |
| `cash_receipt_auto` | No corresponding column exists — pure phantom. |

This is **completely unrelated to this workpacket's scope**: a different table (`catchmenu_store.store_settings`, not `catchmenu_pos.menus`/`menu_option_groups`/`menu_option_items`), a different section of `get_store_admin_dashboard()` (the store-settings summary, not the menu summary this workpacket's §2.3/§2.4 already covers), and touching it would require either `update_store_settings()` (already out of scope, `601111_Overview.md` §6 (c)) or a schema decision (rename `store_settings` to add the three missing columns, or correct the RPC to stop referencing them) that this contract has no mandate to make. It is explicitly carried forward as a new Open Item and flagged as a **separate workpacket candidate** — not folded into this one, and not silently left undocumented.

## §7 Human Approval

Human must check all boxes before Stage 4 implementation:

☑ I approve the 0110 store-admin menu RPC correction scope only.

☑ I approve the three-layer upsert_menu() implementation with
  full-replacement soft deactivation of omitted option groups/
  items, per the narrow-verb Allowed Operations in §2.7.

☑ I approve the price boundary for this workpacket (corrected
  2026-07-16): write price_delta as the canonical option-item
  price field, leave additional_price untouched, accept the
  resulting get_menu_catalog() customer-facing read-path
  inconsistency as a known deferred item (§6 (a)), and defer the
  broader price-list architecture to 601130.

☑ I approve that set_menu_status() is no-regression-only (§1.2)
  — its body may not be edited under this contract.

☑ I approve in-place synchronization of
  sql/migrations/0110_create_store_admin_rpc.sql as the sole
  authorized implementation path (§1.1) — no new migration file
  is authorized. (2026-07-17)

☑ I approve Slice 2 (§2.9, new 2026-07-17): rewriting
  get_menu_admin_list()'s category_summary query as a two-stage
  GROUP BY pre-aggregation subquery + outer jsonb_agg, to fix the
  pre-existing "aggregate function calls cannot be nested" crash
  discovered during Stage 8 — with the returned JSON structure,
  key names, and aggregate semantics (menu_count/sold_out_count/
  hidden_count definitions) held identical to original intent, no
  extension to other admin statistics functions, no performance
  tuning beyond the minimal fix, and no count(distinct m.id)
  (§2.9's JOIN-structure investigation found no row-duplication
  risk, so it is unnecessary). (2026-07-17)

☑ I approve Slice 3 (§2.10, new 2026-07-17): (1) in
  upsert_menu_core(), moving the menu_not_found and
  menu_code_duplicate validation checks to run before the
  category insert, fixing a live data leak where a validation
  failure still committed a new/updated category row — pure
  statement reorder, no new error keys, no change to the category
  upsert logic itself; and (2) in sync_menu_option_groups_core(),
  capturing RETURNING id, group_code on the group-deactivation
  update and appending {group_id, group_code, items: []} entries
  to its return value, so upsert_menu()'s existing item-sync loop
  correctly cascades is_active=false to the items of a fully-
  omitted group — no change to sync_menu_option_items_core()
  itself. (2026-07-17)

## §8 Approval state

NOT APPROVED until §7 is fully checked by Human.

**(2026-07-16 정정 이력)** §0/§2.6/§3/§4/§5/§6이 `additional_price`↔`price_delta` 경계를 뒤집는 정정을 받았다 — 이 문서는 정정 이전에도 §7이 체크된 적 없는 NOT APPROVED 상태였으므로 기존 승인을 무효화하는 것이 아니라, 최초 승인 대상 자체를 올바른 경계로 교정한 것이다. Stage 4는 이 정정된 §7을 기준으로 새로 승인받아야 한다.

**(2026-07-17 정정 이력, Stage 6 Contract Verification 발견)** §2.7/§2.8(narrow-verb Allowed/Forbidden Operations 신설), §1.2(set_menu_status() no-regression-only 재분류), §1.1(forward migration 옵션 제거, in-place 단일 경로 확정)이 추가로 정정됐다 — 마찬가지로 §7이 그 이전에도 체크된 적 없었으므로 기존 승인 무효화가 아니라 최초 승인 대상 자체의 교정이다. 위 두 신규 체크박스도 포함해 Stage 4는 이 정정된 §7 전체를 기준으로 승인받아야 한다.

**(2026-07-17 Slice 2 확장, §2.9)** Slice 2(§2.9, `category_summary` 중첩 집계 교정)는 원래 4개 항목 승인 시점에 존재하지 않았던 신규 범위 확장이므로 별도 체크박스로 분리했다. 2026-07-17 Human이 §7의 Slice 2 전용 체크박스까지 명시적으로 체크했으므로, Stage 8은 원래 4개 항목 범위와 Slice 2를 모두 포함해 진행할 수 있다.

**(2026-07-17 Slice 3 확장, §2.10)** Slice 3(§2.10, `upsert_menu_core()` 카테고리 누수 수정 + `sync_menu_option_groups_core()` 아이템 cascade 수정)는 위 6개 항목 승인 시점에 존재하지 않았던 또 다른 신규 범위 확장이므로 마찬가지로 별도(7번째) 체크박스로 분리했다 — 기존 6개 항목의 승인은 무효화되지 않으며, Stage 8은 그 6개 항목 범위 내에서는 계속 진행할 수 있다. 다만 `upsert_menu_core()`의 검증 순서나 `sync_menu_option_groups_core()`의 반환값 구성을 건드리는 작업은 Slice 3 체크박스가 별도로 체크되기 전까지 금지된다(§4 Stop Condition 18).

**Current approval state: APPROVED for items 1-7 (2026-07-17).**

재도출 확인:
- Slice 1(phantom 4개+3계층 구조): 여러 라운드 검증, 스키마
  네임스페이스 오류/가격필드 3자 모순까지 잡아내고 교정됨
- Slice 2(category_summary 중첩집계): 실제 실행 결과(raw JSON)
  까지 확인됨
- Slice 3(카테고리 누수+cascade): 3자 독립 재현 완전 일치
- 전 과정에서 Human Approval이 매 Slice마다 정확히 분리되어
  체크됨(기존 승인 훼손 없이)
- Open Item들(§5 store_settings, allergen_info 덮어쓰기)이
  투명하게 문서화되고 범위 밖으로 명확히 분리됨 (2026-07-16)

AuditReview: ACCEPT

Open Items (다음 워크패킷 후보로 명확히 이월):
1. [최우선] allergen_info 덮어쓰기 버그(식품안전 인접) -
   601110 완결 직후 즉시 착수 권고
2. get_store_admin_dashboard()의 store_settings stale 컬럼 4개
   (max_waiting_count 등)
3. 0102/0104(POS 동기화)에도 같은 event_domain='menu' 패턴 존재
   (Cursor가 오늘 발견, 아직 미착수) (2026-07-17)
