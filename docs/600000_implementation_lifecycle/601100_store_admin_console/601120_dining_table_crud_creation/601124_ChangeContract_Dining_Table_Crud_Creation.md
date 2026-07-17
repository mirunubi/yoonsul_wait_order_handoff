# 601124_ChangeContract_Dining_Table_Crud_Creation.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5
Owner: TBD
Last Updated: 2026-07-17

## Change ID

`dining_table_crud_creation`

## §0 Contract summary

This ChangeContract authorizes only the Stage 8 implementation described in `601122_Logic_Dining_Table_Crud_Creation.md` §1-§6: creating three new functions — `catchmenu_store.upsert_dining_table()`, `catchmenu_store.set_dining_table_active()`, `catchmenu_store.get_dining_table_admin_list()` — in a new migration file (tentatively `sql/migrations/0162_create_dining_table_admin_rpc.sql`, §1.1). Unlike every other workpacket in this domain so far (`601110`, `601140`), this one creates new functions in a new file rather than modifying an existing one — there is no existing `dining_tables` CRUD to regress against (`601121_Overview.md` §4/§5).

The goal: fill the CRUD gap `601111_Overview_Store_Admin_Sql_Layer_Reconciliation.md` §4 first identified — `dining_tables` has 5 existing operational RPCs (`update_table_status()`/`get_table_floor_map()`/`register_table_qr()`/`release_table()` in `0048`, `estimate_wait_time()` in `0050`) but no way to create, edit, list-including-inactive, or logically delete a table record — without touching any of those five, without touching `table_status`/QR/NFC (all owned elsewhere), and without touching any other domain's files.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file

The only file allowed for this workpacket's SQL body is a **new** migration file:

- `sql/migrations/0162_create_dining_table_admin_rpc.sql` (tentative number — `601121_Overview.md` §6 (b)/`601122_Logic.md` §8 (d) both flag this as provisional; Stage 8 must re-run `select max(...)` against `sql/migrations/` filenames immediately before creating the file and use the actual next-available number if `0162` has been claimed by another workpacket in the interim)

No existing migration file may be modified by this contract — this is a pure-addition workpacket. If Stage 8 finds any reason an existing file needs to change to complete this work, that is a Stop Condition (§6), not an in-scope edit.

### §1.2 Allowed new functions

- `catchmenu_store.upsert_dining_table(...)` (§2.1)
- `catchmenu_store.set_dining_table_active(...)` (§2.2)
- `catchmenu_store.get_dining_table_admin_list(...)` (§2.3)

No other function may be created under this contract. In particular, **no fix to `catchmenu_pos.seat_waiting_customer()`** (`601121_Overview.md` §6 (f) — the confirmed live crash where it writes to a nonexistent `order_sessions.table_number` column) is authorized here; that is explicitly a separate, later workpacket's responsibility ("Staff Seating And Table Assignment Orchestration Contract", not yet started).

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_store.update_table_status(...)`, `catchmenu_store.get_table_floor_map(...)`, `catchmenu_store.register_table_qr(...)`, `catchmenu_store.release_table(...)` (all `0048`)
- `catchmenu_pos.estimate_wait_time(...)` (`0050`)
- `catchmenu_pos.bind_table_to_session(...)` (`0025`)
- `catchmenu_pos.seat_waiting_customer(...)`, `catchmenu_pos.call_waiting_customer(...)` (`0115`/`0160`)

All eight are diff-zero verification targets (`601123_TestPlan.md` §1.4/§10) — Stage 8 must not edit any of their bodies, even ones already confirmed broken (`seat_waiting_customer()`).

## §2 Required implementation contract

### §2.1 `upsert_dining_table()` — full function per `601122_Logic.md` §1

Signature, validation order (existence → `table_code` required-on-create → `table_code` duplicate → active-session capacity-reduction guard, all before any DML — `601122_Logic.md` §1.2), INSERT clause (§1.3), UPDATE clause including the success-path preventive audit on active-session name changes (§1.4), and `EXCEPTION` handler (§1.5) — implemented exactly as `601122_Logic.md` §1 specifies, including the `v_has_active_session` double-check (`current_session_id is not null` **and** a live `catchmenu_pos.order_sessions.session_status` re-check excluding `'COMPLETED'`/`'CANCELLED'`/`'EXPIRED'`/`'NO_SHOW'`). The `EXCEPTION` handler logs to `catchmenu_audit.append_audit_record()` and **returns** `catchmenu_common.build_error_response('dining_table_operation_failed', ...)` — it must not `RAISE` the caught exception, since a live-verified atomicity issue means a bare `RAISE` after the audit call rolls the audit record back along with everything else in the same statement (§8 (h)).

Eight resource-attribute parameters, all `default null`, all `coalesce(p_x, x)` on the UPDATE path: `p_table_code`, `p_table_name`, `p_capacity`, `p_floor_zone`, `p_table_section`, `p_display_order`, `p_kds_device_id`, `p_did_device_id`. No parameter for `table_status`, `qr_code`, `nfc_tag_id`, `current_session_id`, `occupied_since`, or `last_cleaned_at`.

### §2.2 `set_dining_table_active()` — full function per `601122_Logic.md` §2

Bidirectional (`p_is_active boolean`, required — not defaulted), same `v_has_active_session` double-check pattern, blocks only the `false` direction while a genuinely active session exists, idempotent short-circuit (`message_code = 'table_active_unchanged'`) when the requested state already matches, `EXCEPTION` handler per §1.5's pattern.

### §2.3 `get_dining_table_admin_list()` — full function per `601122_Logic.md` §3

No `is_active` filter (the defining difference from `get_table_floor_map()`). Returns `id`, `table_code`, `table_name`, `capacity`, `floor_zone`, `table_section`, `display_order`, `table_status`, `qr_code`, `nfc_tag_id`, `kds_device_id`, `did_device_id`, `is_active`, `created_at`, `updated_at` per table, plus `active_count`/`inactive_count` summary fields. `stable`, no `EXCEPTION` handler (§8 Open Item (c) — this deviation from `000701` §41.1's literal "모든 RPC 함수" wording is intentional, matching this codebase's existing read-only-function convention, and is flagged rather than silently resolved).

### §2.4 GRANT/REVOKE — per `601122_Logic.md` §4

All three new functions get an explicit `REVOKE ALL ... FROM PUBLIC` followed by `GRANT EXECUTE ... TO authenticated` — no function may be left with a NULL/empty `proacl` (the exact gap `601142_Logic.md` §1.2/§3(a) found and fixed reactively in `upsert_menu_core()`; this contract requires it be done correctly from creation, not retrofitted).

### §2.5 `message_catalog`/`error_codes` — per `601122_Logic.md` §5

`ko`/`en` message_catalog rows for the 5 success `message_code`s and 6 error keys (the sixth, `dining_table_operation_failed`, added when §2.1/§2.2's `EXCEPTION` handlers were corrected to return instead of `RAISE` — §8 (h)); `error_codes` rows for the 6 error keys under `error_domain := 'STORE'`. The specific numeric `code` values (`7105`-`7110` as drafted) are **not** fixed by this contract — §6 Stop Condition #2 and `601123_TestPlan.md` §9 govern the required live re-check immediately before Stage 8 runs the migration.

### §2.6 Migration file header — per `601122_Logic.md` §6

Header comment distinguishing this file's purpose from `0048`'s (operational RPCs) — table master-data CRUD only. `Depends on` line naming the actual immediately-prior migration file at implementation time (tentatively `0161`, re-check per §1.1).

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule, matching the pattern in `601114_ChangeContract.md` §2.7 / `601144_ChangeContract.md` §3:

**New file `sql/migrations/0162_create_dining_table_admin_rpc.sql`** (number to be reconfirmed, §1.1):
- Create the file with the header described in §2.6.
- Create `catchmenu_store.upsert_dining_table(...)` exactly as specified in §2.1/`601122_Logic.md` §1.1-§1.5.
- Create `catchmenu_store.set_dining_table_active(...)` exactly as specified in §2.2/`601122_Logic.md` §2.
- Create `catchmenu_store.get_dining_table_admin_list(...)` exactly as specified in §2.3/`601122_Logic.md` §3.
- Add the `REVOKE`/`GRANT` block exactly as specified in §2.4/`601122_Logic.md` §4.
- Add the `message_catalog`/`error_codes` INSERT blocks exactly as specified in §2.5/`601122_Logic.md` §5, with the `code` values re-checked per §6 Stop Condition #2 before use.

No operation is authorized on any other file.

## §4 Forbidden Operations

- Any change to `sql/migrations/0048_create_table_management_rpc.sql`, `0025_create_session_rpc.sql`, `0050_create_waiting_queue_rpc.sql`, `0110_create_store_admin_rpc.sql`, or `0115_create_waiting_pipeline_rpc.sql` — including the confirmed-broken `seat_waiting_customer()` in `0115` (§1.2).
- Adding a `table_status`, `qr_code`, `nfc_tag_id`, `current_session_id`, `occupied_since`, or `last_cleaned_at` parameter to any of the three new functions.
- Any physical `DELETE` statement against `catchmenu_store.dining_tables` in any new function body — `is_active = false` is the only authorized logical-delete path (`601121_Overview.md` §0.2/§3).
- Any new function beyond the three named in §1.2.
- Any change to `601110_store_admin_sql_layer_reconciliation/` or `601130_menu_price_list_architecture/` — different sub-workpackets, zero-diff boundary (`601123_TestPlan.md` §10).
- Leaving any of the three new functions with a NULL/empty `proacl` (§2.4).
- Creating any migration file other than the single one named in §1.1.

## §5 Forbidden scope

- `seat_waiting_customer()`'s `table_number` phantom-column crash (`0115`, `601121_Overview.md` §6 (f)) — confirmed real, out of scope, carried as an Open Item for a future workpacket.
- "Staff Seating And Table Assignment Orchestration Contract" (가칭, not started) — cross-referenced only.
- QR/NFC assignment logic (`register_table_qr()`) — untouched (`601121_Overview.md` §2.5).
- Table operational status transitions (`update_table_status()`) — untouched (`601121_Overview.md` §3).
- Any device-registry schema change — `kds_device_id`/`did_device_id` are consumed as opaque `uuid` FK values only, no new validation logic beyond what the existing FK constraint already enforces (`601121_Overview.md` §6 (k), Open Item, not resolved here).
- Flutter/client code.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_store.dining_tables`'s live schema differs from the 20-column table in `601121_Overview.md` §1.1 in any column, type, nullability, default, or constraint (`601123_TestPlan.md` §1.2).
2. `select max(code) from catchmenu_common.error_codes where error_domain='STORE'` returns anything other than `7104` immediately before Stage 8 runs the migration — the six `error_codes` rows (§2.5) must be renumbered starting one above the actual live max, not inserted as originally drafted (`601123_TestPlan.md` §9).
3. Any of the six new `error_key` values (`table_not_found`, `table_code_required`, `table_code_duplicate`, `table_has_active_session`, `capacity_reduction_blocked_active_session`, `dining_table_operation_failed`) already exists in `catchmenu_common.error_codes` or `catchmenu_common.message_catalog` under a different, conflicting definition.
4. `601123_TestPlan.md` §5.5 (the projection-drift case — `current_session_id` populated but the referenced session already terminal) shows either guard incorrectly firing — this would mean the double-check design (`601122_Logic.md` §1.2/§2) was not implemented as specified, and the guards are trusting the stale projection column alone.
5. `601123_TestPlan.md` §5.4 (the `capacity <= 0` companion failure-path audit test) shows either the `EXCEPTION` handler raising a client-level Postgres error instead of returning `dining_table_operation_failed`, or the corresponding `catchmenu_ledger.audit_records` `FAILED` row failing to persist — this would mean the `raise;`→`build_error_response()` correction (`601122_Logic.md` §1.5/§2, §8 (h)) was not implemented as specified, reintroducing the exact defect that correction fixed.
6. Either `upsert_dining_table()`, `set_dining_table_active()`, or `get_dining_table_admin_list()` shows a NULL/empty `proacl` after the `GRANT`/`REVOKE` block runs (`601123_TestPlan.md` §8).
7. Completing this implementation would require modifying any file named in §1.2's no-regression list, or would require a schema change to `dining_tables`, `order_sessions`, or `orders`.
8. The public parameter set of any of the three functions would need to change from what `601122_Logic.md` §1.1/§2/§3 specifies to complete this task (e.g. needing a `table_status` or QR/NFC parameter after all) — that would mean an `601121_Overview.md` §2 design decision was wrong and requires returning to Stage 5 for a new boundary, not silently adding scope here.
9. `sql/migrations/0162_...` (or whatever number is actually used, §1.1) is found to already exist with different content when Stage 8 begins.

## §7 Required verification

Stage 8 must run `601123_TestPlan_Dining_Table_Crud_Creation.md` completely.

Required evidence:

1. Pre-flight schema/function/error-code baseline checks (§1).
2. New-table creation with all 8 fields correctly stored; omitted fields on a brand-new table receive correct generation defaults (§2).
3. Partial update preserves every omitted field's existing value exactly — the direct, from-scratch application of the `601140` lesson (§3).
4. `table_code_required`/`table_not_found` friendly validation errors, and `table_code` duplicate detection (friendly error on both paths, correct self-exclusion on update, still blocks genuine cross-table collision) (§4).
5. All three active-session guards behave correctly, including the projection-drift negative case (§5.1-§5.3/§5.5).
6. The `capacity <= 0` genuine exception is caught, returns `dining_table_operation_failed` (not a raised client-level error), and — the specific evidence this correction requires — the corresponding `catchmenu_ledger.audit_records` `FAILED` row is confirmed to actually persist (§5.4).
7. `set_dining_table_active()` bidirectional + idempotent (§6).
8. `get_dining_table_admin_list()` includes inactive tables with `is_active` correctly reflected (§7).
9. All three functions' `proacl` is non-empty with `authenticated` granted (§8).
10. The `error_codes` live re-check procedure was actually executed before migration, with evidence of the query result recorded (§9).
11. Zero diff on all five no-regression files plus `601110`/`601130` docs (§10).

If the new migration file is applied for the first time (not an in-place edit of an already-applied file, since this is a pure-addition workpacket), Stage 8 must still follow the established live-verification discipline: apply, then confirm via `pg_get_functiondef()` that all three functions' live bodies match this contract exactly.

## §8 Open Items (carried from `601121_Overview.md` §6 and `601122_Logic.md` §8)

(a) `601121_Overview.md` §6 (a) / `601122_Logic.md` §8 (a) — `set_dining_table_active()` bidirectional (as implemented here) vs. a unidirectional `deactivate_dining_table()` — final naming/direction decision remains Human's; if reversed, the change is structurally minor (§2.2).

(b) `601121_Overview.md` §6 (b)/(g) — the `table_code` UPDATE-path editability decision (a deliberate divergence from `menu_code`'s immutable-after-creation precedent), and the underlying premise that `table_code` is never used as a join/lookup key anywhere in the codebase — the latter was only checked against `order_sessions`/`orders`/`bind_table_to_session()`, not exhaustively searched. Both remain open for Human review before this becomes load-bearing elsewhere.

(c) `601121_Overview.md` §6 (c) / `601122_Logic.md` §8 (c) — whether `get_dining_table_admin_list()`'s lack of an `EXCEPTION`+`append_audit_record()` block is an acceptable, precedented deviation from `000701` §41.1's literal "모든 RPC 함수," or needs to be added anyway. Not resolved by this contract; §2.3 implements it without the handler, matching existing read-only-function precedent, pending Human/future-audit clarification.

(d) **[정정, 2026-07-17, Stage 6 Critical tier(Cursor+Codex) 지적 — 이전 버전이 601121 §6 (d)와 601122 §8 (d)를 같은 항목으로 잘못 병합했다]** `601122_Logic.md` §8 (d) — the `error_codes` code range (`7105`-`7110`, six keys including `dining_table_operation_failed`) and migration file number (`0162`) are provisional; §6 Stop Conditions #2/#9 are the enforcement mechanism, not a one-time check at Logic-authoring time. (`601121_Overview.md` §6 (d)는 별개 내용이므로 아래 (m)으로 분리했다.)

(e) `601121_Overview.md` §6 (e) — whether `capacity`'s schema default (`4`) matching the "no explicit value" UX is actually correct for the eventual admin UI; not verifiable without a Flutter client, out of scope here.

(f) `601121_Overview.md` §6 (f) / `601122_Logic.md` §8 (f) — **[재확인, 크래시 확정]** "Staff Seating And Table Assignment Orchestration Contract" (미착수) — `seat_waiting_customer()`(`0115:988-1006`, 실존) writes to a nonexistent `order_sessions.table_number` column (§1.2, `601121_Overview.md` §6 (f)) and has no lookup step converting a table code into the real `table_id` FK. This is a confirmed, currently-crashing defect, independently prioritizable ahead of or alongside future seating-orchestration work — not fixed by this contract (§1.2/§4/§5).

(g) `601121_Overview.md` §6 (g) — the `table_code`-as-lookup-key claim was not exhaustively re-searched across the whole repository; carried forward from (b).

(h) `601121_Overview.md` §6 (h) — response JSON field-name inconsistency: `upsert_dining_table()`/`set_dining_table_active()` return `'table_id'`; `get_dining_table_admin_list()`'s per-row objects use `'id'` (matching `get_table_floor_map()`'s existing convention). Not unified by this contract.

(i) `601121_Overview.md` §6 (i) — the success-path preventive audit (§2.1/`601122_Logic.md` §1.4) covers `table_name` changes during an active session but not `table_code` changes, despite `table_code` being editable and arguably more consequential to change mid-session. Not added by this contract.

(j) `601121_Overview.md` §6 (j) — the active-session guards (§2.1/§2.2) check `order_sessions` via `current_session_id` only; they do not separately check whether `orders.table_id` references this table directly without a corresponding active `order_sessions` row. Whether such a case exists in practice was not investigated.

(k) `601121_Overview.md` §6 (k) — `p_kds_device_id`/`p_did_device_id` are accepted as opaque FK values with no user-friendly pre-validation (`exists(...)` check against `device_registry`) — a genuinely invalid ID relies on the raw FK constraint violation, caught only by the generic `EXCEPTION` handler (§2.1/§1.5), not a friendly `error_key`. Not added by this contract.

(l) `601122_Logic.md` §8 (g) — the `capacity`-reduction guard compares against the table's stored `capacity` value, not the active session's actual `guest_count` — a simpler, more conservative policy than a guest-count-aware one. `601123_TestPlan.md` §5.2 verifies the design as specified; whether to refine it toward `guest_count` is a future decision.

(m) **[신규, 2026-07-17, Stage 6 Critical tier(Cursor+Codex) 지적 — 이전 버전에서 누락됨]** `601121_Overview.md` §6 (d) — `sql/migrations/0044_create_menu_management_rpc.sql`류의 고객/키오스크 대면 읽기 경로가 `dining_tables`를 참조하는지는 이 워크패킷의 조사에서 확인하지 않았다. 이 워크패킷은 쓰기 경로(CRUD 3개 함수)만 다루므로 착수 자체를 막지는 않지만, 만약 `0044`류가 `dining_tables`의 특정 컬럼 형태를 가정하고 있다면(예: 이번에 추가한 `kds_device_id`/`did_device_id` 노출 방식과 무관하게, 기존 컬럼에 대한 가정) 향후 이 CRUD의 동작이 그 가정과 충돌할 가능성을 배제할 수 없다. Stage 8 착수 전 또는 Stage 9 검증 시 확인 권장 — 이번 계약의 Stop Condition으로 격상하지는 않는다(현재까지 증거 없음).

(n) `601122_Logic.md` §8 (h) — `EXCEPTION` 핸들러를 `raise;`에서 `build_error_response()` 반환으로 정정(§2.1/§6 Stop Condition #5)한 것이, 이 세션의 다른 워크패킷(`601140` 등)이 사용한 동일 `EXCEPTION`+`RAISE` 조합에도 잠재하는 문제인지는 이번 턴에 조사하지 않았다 — `601140`의 `upsert_menu_core()`는 애초에 `EXCEPTION` 핸들러가 없어 이 특정 문제와 무관함을 확인했으나(§1.5 인용), 다른 워크패킷까지 전수 조사가 필요한지는 별도 판단 대상.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation:

☑ I approve creating a new migration file (tentative `0162`, exact number
  reconfirmed live immediately before Stage 8 runs, §1.1) containing the
  three new functions `upsert_dining_table()`/`set_dining_table_active()`/
  `get_dining_table_admin_list()` exactly as specified in §2/`601122_Logic.md`
  §1-§3, with no modification to any existing migration file.

☑ I approve the 8-parameter resource-attribute design for
  `upsert_dining_table()` (`table_code`/`table_name`/`capacity`/`floor_zone`/
  `table_section`/`display_order`/`kds_device_id`/`did_device_id`, all
  `default null` + `coalesce(p_x, x)` on update), explicitly excluding
  `table_status`/QR/NFC/session-runtime columns (§2.1).

☑ I approve the three active-session guards as specified: deactivation
  blocked, capacity-reduction blocked (increase allowed, compared against
  stored `capacity` not `guest_count` — §8 (l)), and `table_name` changes
  allowed with a mandatory preventive audit record when an active session
  exists — all gated on the double-check (`current_session_id` +  live
  `order_sessions.session_status`) rather than the projection column alone
  (§2.1).

☑ I approve `set_dining_table_active()` as bidirectional (§2.2, §8 (a) notes
  the alternative unidirectional naming remains open for reconsideration
  without blocking this approval).

☑ I approve that `0048`/`0025`/`0050`/`0110`/`0115` (including the confirmed
  `seat_waiting_customer()` crash) are entirely out of scope and
  no-regression-only under this contract (§1.2/§4/§5) — this workpacket does
  not fix that crash. (2026-07-17)

## §10 Approval state

APPROVED (2026-07-17)

## §11 Final Audit (Stage 11, Claude)

**Verdict: ACCEPT (2026-07-17)**

핵심 주장 재도출 확인 (Stage 9 산출물을 액면 그대로 신뢰하지 않고 직접 재검토):

- Open Item (f) 자기 정정: "seat_waiting_customer() 미존재"라는 최초 오판을 Cursor+Codex가 독립적으로 잡아내고, 실제로는 존재하되 order_sessions.table_number(실재하지 않는 컬럼)에 쓰기를 시도해 매 호출 크래시난다는 사실로 정정. 이 워크패킷의 Open Item (f)로 정확히 재정의됨.
- kds_device_id/did_device_id 포함 여부의 문서 내부 모순(여러 곳에 "포함"과 "제외"가 공존) 정정 완료.
- capacity 축소 가드의 서술(guest_count 기준처럼 읽힘)과 실제 SQL(stored capacity 기준) 불일치 정정 완료.
- **EXCEPTION 핸들러의 감사기록 유실 결함**: Stage 5에서 raise; 뒤에 append_audit_record()가 같은 최상위 문 안에서 함께 롤백된다는 것을 실제 라이브 재현으로 발견, build_error_response() 반환으로 재설계. Stage 9에서 3자 모두 audit_records FAILED 행이 실제로 영속됨을 재확인.
- error_category='INTERNAL_ERROR'(미허용값) → 'TECHNICAL'로 정정, 라이브 제약 재확인.
- Stage 8 구현 중 v_existing record 미할당 런타임 버그 발견 및 제어흐름 수정으로 해소, Stage 9에서 생성/수정 양쪽 경로 정상 작동 재확인.

Boundary 확인: 0048/0025/0050/0110/0115 전부 0 diff, seat_waiting_customer() 크래시는 의도대로 미수정 확인(3자 일치).

**Open Items (다음 워크패킷 후보로 이월):**

1. **[우선순위 재평가 필요]** seat_waiting_customer()(0115) 크래시 — 이번 워크패킷보다 시급할 수 있음(살아있는 결함이지 단순 공백이 아님). "Staff Seating And Table Assignment Orchestration Contract" 워크패킷에서 다룰 것.
2. table_code 조회키 사용 여부 전수 검색 미완, 수정 가능성 최종 결정 필요.
3. 응답 필드명 불일치(table_id vs id).
4. table_code 변경 시 감사기록 누락(table_name만 커버됨).
5. orders.table_id 직접참조 케이스가 가드 범위 밖.
6. 디바이스 FK 사전검증(친절한 에러) 없음.
7. capacity vs guest_count 정교화 여부.
8. 0044류 읽기 경로가 dining_tables 특정 컬럼 형태를 가정하는지 미확인.
9. 601140 외 다른 워크패킷의 EXCEPTION 패턴에 동일 감사유실 결함이 있는지 전수 확인 안 됨.

## §12 Human Merge/Release

담당: Human (정영석님)