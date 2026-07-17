# 600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0 Contract summary

This ChangeContract authorizes only the Stage 8 implementation described in `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` §A-§F: `CREATE OR REPLACE` of 4 existing functions (`catchmenu_pos.confirm_arrival()`, `catchmenu_pos.get_waiting_status()`, `catchmenu_pos.get_waiting_admin_view()`, `catchmenu_pos.cancel_waiting()`, all originally defined in `0115`) plus 2 new `error_codes`/`message_catalog` rows, in a new migration file (tentatively `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`). Like `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md`, this is a pure-addition workpacket at the file level — no existing migration file is edited — and like that contract, it does `CREATE OR REPLACE` existing, currently-broken functions rather than only adding brand-new ones. Unlike `600654`, this contract creates **no new function** — all 4 signatures are preserved exactly, and the only "new" callee is `catchmenu_pos.mark_session_arrived()`, which already exists (`0025`, unmodified) and is only *called*, never modified.

The goal: eliminate the confirmed live crash in all 4 functions (`600661_Overview.md` §1.1-§1.4 — each references at least one nonexistent `order_sessions` column) by (a) rewriting `confirm_arrival()` as a thin facade delegating to the already-correct `catchmenu_pos.mark_session_arrived()` (`0025`, not modified), (b) replacing phantom-column reads in `get_waiting_status()`/`get_waiting_admin_view()` with `orders`/`dining_tables` LEFT JOINs and a `session_events`-derived `called_at`/`call_count`, and (c) dropping the phantom `cancel_reason` write in `cancel_waiting()` in favor of the ledger event that already carries it — without touching `mark_session_arrived()`, `bind_table_to_session()`, `_resolve_dining_table_by_number()`, `_record_waiting_call()`, `catchmenu_pos.orders`, `catchmenu_store.dining_tables`, or `catchmenu_pos.order_sessions`'s schema.

**This contract also separately authorizes one response-contract change that is not a phantom-column fix**: removing the hardcoded `patent_note` field from `get_waiting_admin_view()`'s response (`600662_Logic.md` §C.2, §H (b)). Per `600662_Logic.md`'s explicit Stage 4 reclassification, this is kept as its own line item throughout this contract (§2.2, §3, §9) rather than bundled into the phantom-column-correction approval, since it removes a currently-working (non-crashing) response field rather than fixing a crash.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file

- `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql` (tentative number — `600662_Logic.md` §F flags this as provisional; Stage 8 must re-run `select max(...)` against `sql/migrations/` filenames immediately before creating the file and use the actual next-available number if `0164` has been claimed by another workpacket in the interim)

No existing migration file may be modified by this contract. `0115_create_waiting_pipeline_rpc.sql` (the file all 4 target functions were originally defined in) is explicitly **not** edited — the new file overrides the 4 live function bodies via `CREATE OR REPLACE`, the same technique `0160`/`0163` already used without touching `0115`'s own text.

### §1.2 Allowed functions

**Replaced (`CREATE OR REPLACE`, all 4 signatures unchanged from `0115`):**

- `catchmenu_pos.confirm_arrival(...)` (§2.1 — Slice A)
- `catchmenu_pos.get_waiting_status(...)` (§2.2a — Slice B)
- `catchmenu_pos.get_waiting_admin_view(...)` (§2.2b — Slice C, includes the separately-tracked `patent_note` removal)
- `catchmenu_pos.cancel_waiting(...)` (§2.3 — Slice D)

**No new function is created by this contract** — unlike `600654`, there is no resolver-style helper; the only callee outside the 4 replaced functions is `mark_session_arrived()`, already live.

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_pos.mark_session_arrived(...)` (`0025`) — canonical core for Slice A's delegation, `600661_Overview.md` §1.5 confirmed it already has the state-transition guard this workpacket needs; not touched.
- `catchmenu_pos.bind_table_to_session(...)`, `catchmenu_pos._resolve_dining_table_by_number(...)` (`0025`/`0163`) — unrelated to this workpacket's 4 target functions, zero-diff verification targets.
- `catchmenu_pos.seat_waiting_customer(...)` (`0163`) — the sibling facade this workpacket's design pattern mirrors; not touched.
- `catchmenu_pos.call_waiting_customer(...)`, `catchmenu_pos._record_waiting_call(...)` (`0160`) — Slice C's TestPlan calls `call_waiting_customer()` as a fixture-setup step (`600663_TestPlan.md` §4.2) but does not modify it; `_record_waiting_call()`'s own empty-`proacl` gap (`600652_Logic.md` §8 (d)) remains unfixed, out of scope here too.
- `catchmenu_pos.register_waiting(...)`, `catchmenu_pos.mark_no_show(...)`, `catchmenu_pos.pre_order_while_waiting(...)` (all `0115`) — confirmed unaffected/already-fixed or separately flagged as possibly-dead code (`600661_Overview.md` §1.4/§H (a)), not touched.
- `catchmenu_store.dining_tables`, `catchmenu_pos.orders`, `catchmenu_kds.kds_tickets`, `catchmenu_pos.order_sessions` — schema, read/write dependencies but no schema changes authorized.

All of the above are diff-zero verification targets (`600663_TestPlan.md` §6) — Stage 8 must not edit any of their bodies or schemas.

## §2 Required implementation contract

### §2.1 `confirm_arrival()` — full replacement per `600662_Logic.md` §A

Exact control flow, in order: (1) session lookup with the `0160`/`0163`-pattern `orders` LEFT JOIN for pre-order info; (2) `waiting_session_not_found` if no row; (3) delegate to `mark_session_arrived()` — **on failure, return its raw flat JSON unmodified, do not re-wrap via `build_error_response()`** (`600662_Logic.md` §A.2, mirroring `0163`'s `600652_Logic.md` §2.1 correction); (4) waiting-domain side effect (`notify_channel()`) on success; (5) the facade's own `catchmenu_ledger.events` insert (`event_domain='waiting'`, `event_type='arrival_confirmed'`, `from_state` set dynamically from `v_session.session_status`, not hardcoded) — distinct from `mark_session_arrived()`'s own `session`/`customer_arrived` event, by design (§2.4 of this contract); (6) success response, with the `table_number` field dropped (always-null pre-seating, 0 callers exist). `EXCEPTION` handler logs to `catchmenu_audit.append_audit_record()` with `p_audit_domain := 'session'` (**not** `'waiting'` — `chk_audit_domain` does not allow it, `600652_Logic.md` §1.5's precedent applied proactively) and **returns** `build_error_response('waiting_confirm_arrival_failed', ...)` — must not `RAISE`.

### §2.2a `get_waiting_status()` — full replacement per `600662_Logic.md` §B

Phantom `pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at` replaced with: `orders.final_amount` LEFT JOIN, `dining_tables.table_code` LEFT JOIN, a `LEFT JOIN LATERAL` on `session_events` (`event_type='customer_called'`, `max(occurred_at)`), and the real `arrived_at` column directly. The dead `queue_position` SELECT item (read but never used — the response uses a separately-computed local variable) is dropped.

### §2.2b `get_waiting_admin_view()` — full replacement per `600662_Logic.md` §C

Same 3 LEFT JOIN patterns as §2.2a, plus a `LEFT JOIN LATERAL` on `session_events` computing both `call_count` (`count(*)`) and `called_at` (`max(occurred_at)`) together — reusing `_record_waiting_call()`'s own `call_count` derivation expression verbatim (`0160:92-95`). The phantom `memo` field (no substitute source exists anywhere) is dropped from the response entirely — **this is authorized as part of the phantom-column-correction scope** (§C.1's Option 1, no schema change). **The `patent_note` field removal is authorized separately** (§0, §9) — it is not a phantom-column fix and Human must approve it as its own item.

### §2.3 `cancel_waiting()` — full replacement per `600662_Logic.md` §D

Phantom `pre_order_amount` replaced via the same `orders` LEFT JOIN pattern. The phantom `cancel_reason` UPDATE SET clause is dropped entirely — the value remains fully preserved in the `catchmenu_ledger.events` payload and `notify_channel()` payload, which already carried it. `EXCEPTION` handler added (`p_audit_domain := 'session'`, returns `build_error_response('waiting_cancel_operation_failed', ...)`), matching Slice A's pattern. **Not authorized under this contract** (explicitly out of scope, `600661_Overview.md` §4-1, `600662_Logic.md` §D.2): any `session_status` pre-transition guard, or any logic that releases `dining_tables.table_status` back to `'AVAILABLE'` on cancellation of an already-`SEATED` session.

### §2.4 `has_pre_order` criterion unified across all 4 Slices

Per `600662_Logic.md` §0: all 4 functions' `has_pre_order`-equivalent computation must use `os.pre_order_created_at is not null`, not `pre_order_amount > 0` (the LEFT JOIN makes a no-pre-order case `NULL`, not `0`, and `0` is itself a valid non-null amount in edge cases like free promotions).

### §2.5 Two ledger events for `confirm_arrival()`, deliberately

Per `600662_Logic.md` §A.3: `mark_session_arrived()`'s `session`/`customer_arrived` event and this facade's own `waiting`/`arrival_confirmed` event (both persist on success) is a documented design decision mirroring `0163`'s `session`/`table_bound` + `waiting`/`customer_seated` precedent, not a defect. Stage 8 must not deduplicate or remove either event. Total footprint per successful call: 1 `session_events` row + 2 `catchmenu_ledger.events` rows (`600663_TestPlan.md` §2.2).

### §2.6 GRANT/REVOKE

All 4 functions' existing GRANTs (`authenticated`, unchanged since `0115`) are left as-is — no signature changes mean no new GRANT statements are required or authorized.

### §2.7 `message_catalog`/`error_codes` — per `600662_Logic.md` §E

Two new `error_key`s, `ORDER`-domain (matching `0163`'s domain choice): `waiting_confirm_arrival_failed`, `waiting_cancel_operation_failed`. The specific `code` values (`7078`/`7079` as drafted) are **not** fixed by this contract — §6 Stop Condition #2 governs the required live re-check immediately before Stage 8 runs the migration.

### §2.8 Migration file header and statement order

Per `600662_Logic.md` §F — header identifying this file's purpose (4-function phantom-column correction, no new functions) distinct from `0115`'s original scope and from `0163`'s facade-plus-resolver shape, `Depends on: 0163_seat_waiting_customer_facade_correction.sql`. Statement order within the file: (1) `message_catalog`/`error_codes` INSERT block first, (2)-(5) the 4 `CREATE OR REPLACE` statements in the order `confirm_arrival` → `get_waiting_status` → `get_waiting_admin_view` → `cancel_waiting`, (6) no trailing GRANT/REVOKE block needed (§2.6) but the file header must say so explicitly to prevent Stage 8 from adding a redundant one.

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule, matching `600654_ChangeContract.md` §3's format:

**New file `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`** (number to be reconfirmed, §1.1), operations in the file-statement order §2.8 requires:

1. Create the file with the header described in §2.8.
2. Add the `message_catalog`/`error_codes` INSERT blocks exactly as specified in §2.7/`600662_Logic.md` §E, with `code` values re-checked per §6 Stop Condition #2 before use — first, before any function definition.
3. `CREATE OR REPLACE` `catchmenu_pos.confirm_arrival(...)` exactly as specified in §2.1/`600662_Logic.md` §A.3 — preserving the existing signature exactly (no parameter added, removed, renamed, or reordered).
4. `CREATE OR REPLACE` `catchmenu_pos.get_waiting_status(...)` exactly as specified in §2.2a/`600662_Logic.md` §B.2.
5. `CREATE OR REPLACE` `catchmenu_pos.get_waiting_admin_view(...)` exactly as specified in §2.2b/`600662_Logic.md` §C.2 — **including, as a distinct, separately-approved sub-operation, the removal of the `patent_note` field from the response** (§0, §9 — this sub-operation must be traceable in the implementation diff as its own reviewable hunk, not silently folded into the phantom-column edits of the same function body).
6. `CREATE OR REPLACE` `catchmenu_pos.cancel_waiting(...)` exactly as specified in §2.3/`600662_Logic.md` §D.2.

No operation is authorized on any other file. No new function-creation operation is authorized (contrast with `600654_ChangeContract.md` §3 step 3, which did authorize a new resolver function — this contract has no equivalent step).

## §4 Forbidden Operations

- Any change to `sql/migrations/0025_create_session_rpc.sql` (`mark_session_arrived()`/`bind_table_to_session()`), `0048_create_table_management_rpc.sql`, `0050_create_waiting_queue_rpc.sql`, `0110_create_store_admin_rpc.sql`, `0115_create_waiting_pipeline_rpc.sql`, `0160_call_waiting_customer_contract_recovery.sql`, `0162_create_dining_table_admin_rpc.sql`, or `0163_seat_waiting_customer_facade_correction.sql`.
- Adding a `session_status` pre-transition guard or a `dining_tables.table_status` release/table-reclaim step to `cancel_waiting()` — explicitly deferred to a future workpacket (`600661_Overview.md` §4-1, `600662_Logic.md` §D.2, §H (a)). This is a **forbidden addition**, not merely an unimplemented one — Stage 8 must not "helpfully" close this gap while touching the function body.
- Adding a `session_status` pre-transition guard to `confirm_arrival()` beyond what `mark_session_arrived()` already enforces internally (i.e., no new guard logic in the facade itself, §A.2's designed decision not to intercept `invalid_session_status` with a friendlier key).
- Re-wrapping `mark_session_arrived()`'s failure response in `build_error_response()` — the exact `0163`-precedent defect class (§2.1); the raw response must pass through unmodified.
- Registering `session_not_found`/`invalid_session_status` (`mark_session_arrived()`'s own error vocabulary) in `error_codes`/`message_catalog` under this contract — out of this workpacket's ownership boundary, same reasoning as `600654_ChangeContract.md` §4.
- Adding an `order_sessions.memo` column (or any other schema change) to preserve `get_waiting_admin_view()`'s `memo` field — Option 2 of `600662_Logic.md` §C.1 was explicitly not chosen; any schema addition requires a new workpacket.
- Creating any migration file other than the one named in §1.1.
- Adding, removing, or reordering parameters on any of the 4 target functions' public signatures.

## §5 Forbidden scope

- `cancel_waiting_state_guard_and_table_release` (candidate future workpacket, §4/`600661_Overview.md` §4-1) — cross-referenced only.
- `waiting_session_staff_memo_feature` (candidate future workpacket, `600662_Logic.md` §C.1) — cross-referenced only, not created here.
- `get_dining_table_admin_list()`(`601120`) response-shape inconsistency — different function, different domain boundary, not this contract's concern.
- `_record_waiting_call()`'s empty `proacl` — cross-referenced only, not fixed here.
- Flutter/client code — 0 callers confirmed for all 4 target functions (`600661_Overview.md` §4-5).

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_pos.mark_session_arrived()`'s live signature, its `arrived_at`/`session_status` write behavior, or its two documented flat error keys (`session_not_found`/`invalid_session_status`) differ from what `600661_Overview.md` §1.5/`600662_Logic.md` §A.1 document (`600663_TestPlan.md` §1.1/§1.2).
2. `select max(code) from catchmenu_common.error_codes where error_domain='ORDER'` returns anything other than `7077` immediately before Stage 8 runs the migration — the two `error_codes` rows (§2.7) must be renumbered starting one above the actual live max, not inserted as originally drafted (`600663_TestPlan.md` §1.4).
3. Either new `error_key` value already exists in `catchmenu_common.error_codes` or `catchmenu_common.message_catalog` under a different, conflicting definition.
4. `catchmenu_pos.order_sessions`'s live schema no longer has `table_id`/`order_id`/`queue_position`/`arrived_at`/`cancelled_at`/`pre_order_created_at` as documented (`600661_Overview.md` §1, `600663_TestPlan.md` §1.3).
5. Completing this implementation would require modifying any file or function named in §1.2's no-regression list.
6. The public parameter set of any of the 4 target functions would need to change from its existing signature to complete this task — that would mean a `600661_Overview.md`/`600662_Logic.md` design decision was wrong and requires returning to Stage 5 for a new boundary.
7. `600663_TestPlan.md` §2.3's reachability analysis is found to be wrong at Stage 8 — i.e. `session_not_found` from `mark_session_arrived()` turns out to be reachable through `confirm_arrival()` after all.
8. `600663_TestPlan.md` §5.3's `has_pre_order` edge-case behavior (no crash when `pre_order_created_at` is set but no `orders` row exists) is found to actually crash at Stage 8 — this would mean the `UPDATE ... FROM` no-op assumption (`600662_Logic.md` §D.1) was wrong and `cancel_waiting()` needs a null-check guard before that block, requiring a return to Stage 5.
9. `sql/migrations/0164_...` (or whatever number is actually used, §1.1) is found to already exist with different content when Stage 8 begins.
10. **Human has not separately checked the `patent_note`-removal box in §9** — Stage 8 must not implement §2.2b's `patent_note` removal (though it may still implement the rest of `get_waiting_admin_view()`'s phantom-column fixes) if only the phantom-column-correction boxes are checked.

## §7 Required verification

Stage 8 must run `600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` completely.

Required evidence:

1. Pre-flight function/schema/error-code baseline checks, including the timezone note (§1).
2. Slice A: normal delegation success (`ARRIVAL_PENDING`, `arrived_at` set, `table_number` absent from response), exact event footprint (1 `session_events` + 2 `catchmenu_ledger.events`), `invalid_session_status` reachability with raw pass-through, `EXCEPTION` atomicity with `mark_session_arrived()`'s work fully rolled back (§2).
3. Slice B: all 4 phantom columns resolved with no crash, `called_at`/`arrival_at` cross-verified against a real `confirm_arrival()` call, dead `queue_position` SELECT confirmed removed (§3).
4. Slice C: all 5 phantom columns (including `memo`) resolved with no crash, `call_count`/`called_at` derivation verified against a real 2-call `call_waiting_customer()` sequence, `patent_note` confirmed absent **only after** confirming the separate Human approval box was checked (§4).
5. Slice D: `cancel_reason` confirmed absent from the `order_sessions` schema but present in the ledger event, KDS ticket cancellation preserved for pre-order sessions, the `has_pre_order` edge case (no `orders` row) completing without a crash, `EXCEPTION` atomicity with `cancel_waiting()`'s own (non-delegated) writes rolled back (§5).
6. Zero diff on all 4 no-regression files (`0025`/`0115`/`0160`/`0163`) — the file-level list is in `600663_TestPlan.md` §6, not this contract's §1.1 (which only names the one *new* allowed file); the function/schema-level no-regression list this contract itself defines is §1.2 (§6 of this document).

## §8 Open Items (carried from `600662_Logic.md` §H in full)

(a) `cancel_waiting()` state guard + table-release logic absent — future workpacket candidate `cancel_waiting_state_guard_and_table_release` (`600661_Overview.md` §4-1, `600662_Logic.md` §D.2).

(b) `get_waiting_admin_view()`'s `patent_note` removal — confirmed as a response-contract change separate from phantom-column correction, requiring its own Human approval (§9), tracked as its own Allowed Operations sub-item (§3 step 5).

(c) `get_dining_table_admin_list()`(`601120`) response-shape inconsistency vs. `build_success_response()` — out of scope, different function.

(d) `memo` — Option 1 (removal) confirmed, future feature workpacket candidate `waiting_session_staff_memo_feature` if the staff-note capability is actually needed.

(e) `get_waiting_status()`'s dead `queue_position` SELECT — removed under this contract (§2.2a).

(f) `_record_waiting_call()`'s empty `proacl` — `600652_Logic.md` §8 (d), still out of scope here.

(g) `error_codes` codes `7078`/`7079` are provisional — Stage 8 must re-verify per §6 Stop Condition #2.

(h) Slice B/C not getting `EXCEPTION` handlers is a Stage-2 Logic judgment, not final — open to Stage 6 reconsideration.

(i) `has_pre_order`'s implicit assumption (a `pre_order_created_at`-set session always has a matching `orders`/`kds_tickets` row) can break if `pre_order_while_waiting()` is confirmed broken/dead-code — `600663_TestPlan.md` §5.3 reproduces the resulting edge case and confirms no crash results, but the underlying data-integrity question (how such a session could arise in the first place) is not resolved by this contract.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation. **The phantom-column-correction boxes and the `patent_note` box are independent — checking one does not imply the other.**

☑ I approve `CREATE OR REPLACE` of `confirm_arrival()` as a facade delegating
  to `mark_session_arrived()` (`0025`, unmodified), including the raw
  (non-re-wrapped) pass-through of its failure responses and the dropped
  `table_number` response field (§2.1).

☑ I approve `CREATE OR REPLACE` of `get_waiting_status()` and
  `get_waiting_admin_view()` with the `orders`/`dining_tables` LEFT JOIN and
  `session_events`-derived `called_at`/`call_count` pattern, including the
  removal of the phantom `memo` field with no schema change (§2.2a/§2.2b).

☑ I approve `CREATE OR REPLACE` of `cancel_waiting()` with the phantom
  `cancel_reason` write removed (ledger remains the sole source of truth),
  the new `EXCEPTION` handler, and explicit confirmation that no
  `session_status` guard or table-release logic is added in this same change
  (§2.3, §4).

☑ **I separately approve removing the hardcoded `patent_note` field from
  `get_waiting_admin_view()`'s response** — this is a response-contract
  change unrelated to phantom-column correction (§0, §2.2b, §H (b)). If this
  box is left unchecked, Stage 8 must still implement `get_waiting_admin_view()`'s
  phantom-column fixes but must leave `patent_note` in place.

☑ I approve the 2 new `error_key`s (`waiting_confirm_arrival_failed`/
  `waiting_cancel_operation_failed`, `error_domain='ORDER'`) and the
  `has_pre_order` criterion unification (`pre_order_created_at is not null`)
  across all 4 functions (§2.4/§2.7).

☑ I approve that `cancel_waiting_state_guard_and_table_release`,
  `waiting_session_staff_memo_feature`, `_record_waiting_call()`'s empty
  `proacl`, and `get_dining_table_admin_list()`'s response-shape
  inconsistency are entirely out of scope under this contract (§5/§8) — none
  of these are fixed by this workpacket. (2026-07-18)

## §10 Approval state

APPROVED (2026-07-18) — all 6 Human Approval boxes in §9 are checked.

## §12 Human Merge/Release

담당: Human (정영석님) — §9 전체 6개 항목 체크 및 §10 승인 완료(2026-07-18), Stage 8 착수 가능.
