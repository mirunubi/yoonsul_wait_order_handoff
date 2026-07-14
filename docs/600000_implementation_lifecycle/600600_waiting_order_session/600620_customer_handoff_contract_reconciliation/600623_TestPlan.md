# 600623_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## 0. Authority And Scope

Derived from `600621_Overview.md`/`600622_Logic.md` (finalized) plus this turn's Correction-scope decision:

- **Correction 1** — `catchmenu_kds.kds_tickets` INSERT inside `catchmenu_pos.pre_order_while_waiting()` (`0115`): remove the phantom `menu_id` column reference, add a generated `ticket_number` value.
- **Correction 2** — `catchmenu_pos.get_waiting_realtime_state()` (`0099`): rename all `max_waiting_count` references to the real column `max_wait_number`.
- Alignment (`arrival_confirmed_at`) and the 5 Redesign items are explicitly **not** touched this turn.

## 0.5 Critical Finding This Turn — `pre_order_while_waiting()` Cannot Be Fully E2E-Tested Yet

Before designing Test A, direct reproduction revealed that `pre_order_while_waiting()`'s **first** write statement (the `catchmenu_pos.orders` INSERT, which runs *before* the `order_items` INSERT, which runs *before* the `kds_tickets` INSERT this Correction targets) already fails on its own, unrelated defects:

```
ERROR: column "order_source" of relation "orders" does not exist
```

Reproduced live (`BEGIN`/`ROLLBACK`, no permanent change) by calling `register_waiting()` then `pre_order_while_waiting()` with a minimal cart. Static inspection of the same INSERT additionally found `order_type := 'TABLE'`, which is **not** in `chk_order_type`'s allowed list (`DINE_IN`/`TAKEOUT`/`DELIVERY`/`KIOSK`/`STAFF_ORDER`) — a second, independent blocker hidden behind the first (Postgres reports only the first error encountered; `order_source`'s phantom-column error is a parse-time failure that occurs before the `order_type` CHECK constraint is ever evaluated).

Beyond that, the `order_items` INSERT (between the `orders` INSERT and the `kds_tickets` INSERT) was found to reference three more phantom columns not in scope for this Correction: `unit_price`(real: `unit_price_snapshot`), `subtotal`(real: `item_amount`), `item_options`(real: `selected_options`) — plus it omits the required `menu_code_snapshot` (`NOT NULL`, no default) entirely, and has no `returning id into ...` clause to capture the new `order_items.id` for later use.

**Consequence for this TestPlan**: fixing only the approved Correction 1 (`kds_tickets`) does **not** let `pre_order_while_waiting()` progress any further than it currently does — the function still dies at the very first statement (`orders` INSERT, `order_source`), which is chronologically far upstream of the `kds_tickets` INSERT this Correction touches. A true call-the-whole-function E2E test would be misleading here; instead, Test A below verifies the `kds_tickets` fix **in isolation** (valid prerequisite rows constructed directly, not via the buggy upstream code), and Test C documents the full blocker chain as a new Open Item.

## 1. Verification Environment

- Local Supabase Docker DB only (`supabase_db_yoonsul_wait_order_handoff`).
- All tests wrapped in `BEGIN; ... ROLLBACK;` — no permanent data or function-definition changes.
- Test identifiers: `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid`, `p_store_id := '00000000-0000-0000-0000-000000000002'::uuid`.

## 2. Test A — `kds_tickets` Correction, Isolated (Not Via `pre_order_while_waiting()`)

Purpose: confirm the specific fix (remove `menu_id`, add generated `ticket_number`) is itself correct, independent of the two unrelated upstream blockers documented in §0.5.

Fix design (exact Before/After for `600624_ChangeContract.md` §1):

```sql
-- Before
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id,
  order_id, menu_id,
  menu_name_snapshot,
  quantity_snapshot,
  kitchen_zone, kds_status,
  conditions_met,
  ticket_created_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_menu.id,
  v_menu.menu_name,
  (v_item->>'quantity')::int,
  coalesce(v_menu.kitchen_zone, 'MAIN'),
  'HOLD',
  jsonb_build_object( ... ),
  now(),
  v_business_day, v_timezone
);

-- After
insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id,
  order_id, ticket_number,
  menu_name_snapshot,
  quantity_snapshot,
  kitchen_zone, kds_status,
  conditions_met,
  ticket_created_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_ticket_number,
  v_menu.menu_name,
  (v_item->>'quantity')::int,
  coalesce(v_menu.kitchen_zone, 'MAIN'),
  'HOLD',
  jsonb_build_object( ... ),
  now(),
  v_business_day, v_timezone
);
```

Requires a new loop-scoped counter (declared alongside the function's existing `declare` block) and, immediately before the INSERT:

```sql
v_ticket_count := v_ticket_count + 1;
v_ticket_number := v_order_number || '-' || lpad(v_ticket_count::text, 2, '0');
```

(Pattern matches the existing `ticket_number` generation convention already used elsewhere in the codebase — `0026_create_order_rpc.sql` L356-357, `v_ticket_number := v_order.order_number || '-' || lpad(v_ticket_count::text, 2, '0')`.)

Execution shape (isolated — manually constructs a valid `orders` row directly, bypassing the two unrelated upstream defects documented in §0.5, so only the `kds_tickets` fix itself is under test):

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'W-TEST-600623', 'DINE_IN', 'CONFIRMED',
  3500, 0, 3500, current_date, 'Asia/Seoul'
) returning id as ordid \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id,
  order_id, ticket_number,
  menu_name_snapshot,
  quantity_snapshot,
  kitchen_zone, kds_status,
  conditions_met,
  ticket_created_at,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ordid'::uuid, 'W-TEST-600623-01',
  '기본김밥', 1,
  'MAIN', 'HOLD',
  jsonb_build_object('payment_confirmed', false, 'kds_release_authorized', false),
  now(), current_date, 'Asia/Seoul'
) returning id, ticket_number, kds_status;

rollback;
```

**Result — already executed this turn (`BEGIN`/`ROLLBACK`, no permanent change)**:

```
INSERT 0 1
                  id                  |  ticket_number   | kds_status
--------------------------------------+------------------+------------
 310973f4-bebb-4206-ab31-b5e66d23b84a | W-TEST-600623-01 | HOLD
(1 row)
INSERT 0 1
ROLLBACK
```

PASS condition: the corrected `kds_tickets` INSERT succeeds and returns a row with the expected `ticket_number`/`kds_status`. **Already met** — recorded above.

FAIL condition: any error (would indicate the fix design itself is still wrong, not just blocked by upstream issues).

## 3. Test B — `get_waiting_realtime_state()` Correction, Progress Confirmation

Purpose: confirm the `max_waiting_count`→`max_wait_number` rename lets the function progress past its current first blocker, and identify precisely what the *new* first blocker becomes (this function has 4 separate phantom-column references — fixing one reveals the next, not full success).

Fix design: 4 occurrences of `max_waiting_count` → `max_wait_number` inside `get_waiting_realtime_state()` — the `select ... into v_store_settings` column list, and 3 later usages of `v_store_settings.max_waiting_count`.

Execution shape (patch tested in a transaction via `CREATE OR REPLACE FUNCTION` with the live body, `max_waiting_count` replaced, then rolled back — the live function was **not** permanently changed):

```sql
begin;
create or replace function catchmenu_pos.get_waiting_realtime_state( ... )
-- (identical to live body, with all 4 max_waiting_count -> max_wait_number)
as $$ ... $$;

select catchmenu_pos.get_waiting_realtime_state(
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid
);
rollback;
```

**Result — already executed this turn**:

```
BEGIN
CREATE FUNCTION
ERROR: column os.arrival_confirmed_at does not exist
LINE 26:           os.arrival_confirmed_at,
CONTEXT: PL/pgSQL function get_waiting_realtime_state(uuid,uuid,text) line 26 at SQL statement
ROLLBACK
```

Confirms exactly the expected outcome: the function **progresses past** the (now-fixed) `store_settings` SELECT and reaches the `order_sessions` query, where it fails on `arrival_confirmed_at` — the first of the three remaining phantom columns (`arrival_confirmed_at`/`table_number`/`memo`) encountered in evaluation order within that `jsonb_build_object`. `table_number`/`memo` remain hidden behind `arrival_confirmed_at` — they will not surface as errors until `arrival_confirmed_at` is also addressed (out of scope, Alignment item).

PASS condition: the specific error changes from `column "max_waiting_count" does not exist` (old) to `column os.arrival_confirmed_at does not exist` (new) — proving forward progress without claiming full success. **Already met** — recorded above.

FAIL condition: the function either still fails on `max_waiting_count`/`max_wait_number` (fix ineffective) or succeeds completely (would mean the 8-column drift list in `600622_Logic.md` §1.1 is stale and needs re-verification).

## 4. Test C — Full Blocker Chain Documentation For `pre_order_while_waiting()` (Not A Pass/Fail Test)

This is a documentation checkpoint, not a test with a PASS/FAIL condition — it records what must additionally be fixed (in future, separately-approved workpackets) before `pre_order_while_waiting()` can ever complete end-to-end:

| Order | Blocker | Statement | In this workpacket's scope? |
|---|---|---|---|
| 1 | `order_source` phantom column | `orders` INSERT | No — newly discovered this turn, not approved |
| 2 | `order_type := 'TABLE'` not in `chk_order_type` | `orders` INSERT (same statement, hidden behind #1) | No — newly discovered this turn, not approved |
| 3 | `unit_price`/`subtotal`/`item_options` phantom, `menu_code_snapshot` NOT NULL omitted, no `returning id` | `order_items` INSERT | No — newly discovered this turn, not approved |
| 4 | `menu_id` phantom, `ticket_number` NOT NULL omitted | `kds_tickets` INSERT | **Yes — this workpacket's Correction 1** |

Even after Correction 1 lands, calling `pre_order_while_waiting()` end-to-end will still fail at blocker #1 — this must be communicated clearly so the fix is not mistaken for resolving the function's overall failure.

## 5. Static Boundary Verification

```powershell
git diff -- sql/migrations/0115_create_waiting_pipeline_rpc.sql
git diff -- sql/migrations/0099_create_realtime_pipeline_rpc.sql
git status --short -- sql/migrations/
```

Expected diff boundary:

- `0115`: exactly the `kds_tickets` INSERT inside `pre_order_while_waiting()` (menu_id removed, ticket_number generation added, one new declared variable). No change to the `orders` or `order_items` INSERTs in the same function.
- `0099`: exactly 4 occurrences of `max_waiting_count` → `max_wait_number` inside `get_waiting_realtime_state()`. No other function in `0099` touched.
- No other file changed.

## 6. Acceptance Criteria

1. Test A's corrected `kds_tickets` INSERT succeeds in isolation (already verified).
2. Test B's corrected `get_waiting_realtime_state()` progresses past `max_wait_number` to a new, different failure point (already verified).
3. Test C's blocker chain is recorded as an Open Item in `600624_ChangeContract.md`, not silently left implicit.
4. Static boundary matches §5 exactly — no scope creep into `order_source`/`order_type`/`order_items`/the 5 Redesign columns/`arrival_confirmed_at`.
