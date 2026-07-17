# 600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0 Contract summary

This ChangeContract authorizes only the Stage 8 implementation described in `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` §1-§6: creating a new internal helper `catchmenu_pos._resolve_dining_table_by_number()` and replacing `catchmenu_pos.seat_waiting_customer()`'s body (`CREATE OR REPLACE`, same signature, no public API change) in a new migration file (tentatively `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`). Like `601124_ChangeContract_Dining_Table_Crud_Creation.md`, this is a pure-addition workpacket at the file level — no existing migration file is edited — but unlike that one, it does `CREATE OR REPLACE` an existing, currently-broken function (`seat_waiting_customer()`, originally defined in `0115`) rather than only adding brand-new functions.

The goal: eliminate the confirmed live crash in `seat_waiting_customer()` (`600651_Overview.md` §1.1 — writes to a nonexistent `order_sessions.table_number` column on every call) by delegating the core session/table state transition to the already-correct `catchmenu_pos.bind_table_to_session()` (`0025`, not modified), resolving the caller-facing `table_number` to the canonical `table_id` via a new resolver helper, and preserving the waiting-pipeline-specific side effects the original function had — without touching `bind_table_to_session()`, `catchmenu_pos.orders`, `catchmenu_store.dining_tables`, or any of the four sibling waiting-pipeline functions that are also still broken but out of scope.

## §1 Allowed files and objects

### §1.1 Allowed SQL source file

- `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` (tentative number — `600652_Logic.md` §6 flags this as provisional; Stage 8 must re-run `select max(...)` against `sql/migrations/` filenames immediately before creating the file and use the actual next-available number if `0163` has been claimed by another workpacket in the interim)

No existing migration file may be modified by this contract. `0115_create_waiting_pipeline_rpc.sql` (the file `seat_waiting_customer()` was originally defined in) is explicitly **not** edited — the new file overrides the live function via `CREATE OR REPLACE`, the same technique `0160` already used for `call_waiting_customer()` without touching `0115`'s own text (`600651_Overview.md` §6.5, `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` precedent).

### §1.2 Allowed functions

**New:**

- `catchmenu_pos._resolve_dining_table_by_number(...)` (§2.1)

**Replaced (`CREATE OR REPLACE`, signature unchanged):**

- `catchmenu_pos.seat_waiting_customer(...)` (§2.2)

**No-regression preservation only — modification NOT authorized:**

- `catchmenu_pos.bind_table_to_session(...)` (`0025`) — canonical core, `600651_Overview.md` §1.2/§1.3 confirmed it already covers every invariant this workpacket needs.
- `catchmenu_pos.confirm_arrival(...)`, `catchmenu_pos.get_waiting_status(...)`, `catchmenu_pos.get_waiting_admin_view(...)`, `catchmenu_pos.cancel_waiting(...)` (all `0115`) — the four sibling functions, still confirmed broken (`600651_Overview.md` §4.1), explicitly out of scope.
- `catchmenu_pos.pre_order_while_waiting(...)` (`0115`) — also confirmed broken, possibly dead code (`600651_Overview.md` §4.2), out of scope.
- `catchmenu_pos.register_waiting(...)`, `catchmenu_pos.mark_no_show(...)` (`0115`) — confirmed unaffected/already-fixed, not touched.
- `catchmenu_pos.call_waiting_customer(...)`, `catchmenu_pos._record_waiting_call(...)` (`0160`) — including `_record_waiting_call()`'s own empty-`proacl` gap (`600652_Logic.md` §1.1), which this workpacket does not fix.
- `catchmenu_store.dining_tables`, `catchmenu_pos.orders`, `catchmenu_pos.order_sessions` — schema, read-only dependencies for this workpacket.

All of the above are diff-zero verification targets (`600653_TestPlan.md` §10) — Stage 8 must not edit any of their bodies or schemas.

## §2 Required implementation contract

### §2.1 `_resolve_dining_table_by_number()` — full function per `600652_Logic.md` §1

0/1/2+ match resolution against `catchmenu_store.dining_tables.table_code`, scoped by `tenant_id`+`store_id`; `is_active` checked separately from existence so `NOT_FOUND` and `INACTIVE` remain distinguishable; `returns table(v_table_id uuid, v_status text)` with `v_status` in `('FOUND','NOT_FOUND','AMBIGUOUS','INACTIVE')`. `REVOKE ALL FROM PUBLIC`, no `GRANT` to `authenticated` (internal-only, §2.1's own GRANT/REVOKE per `600652_Logic.md` §1.1).

### §2.2 `seat_waiting_customer()` — full replacement per `600652_Logic.md` §2

Exact control flow, in order: (1) session lookup with the `0160`-pattern `orders` LEFT JOIN for pre-order info (`order_id`/`pre_order_created_at`, never a phantom `pre_order_amount` column); (2) `waiting_session_not_found` if no row; (3) `waiting_already_seated` if `session_status = 'SEATED'` (original error key preserved, checked before any delegation); (4) `waiting_table_number_required` if `p_table_number is null`; (5) resolver call, branching on `NOT_FOUND`/`AMBIGUOUS`/`INACTIVE` to the matching `build_error_response()` call; (6) `bind_table_to_session()` delegation — **on failure, return `v_bind_result` unmodified, do not re-wrap via `build_error_response()`** (`600652_Logic.md` §2.1, the Stage 4 correction); (7) waiting-domain side effects on success (conditional diagnostic log, remaining-queue count, two `notify_channel()` calls, the `waiting`/`customer_seated` ledger event distinct from `bind_table_to_session()`'s own `session`/`table_bound` event); (8) success response. `EXCEPTION` handler logs to `catchmenu_audit.append_audit_record()` — with `p_audit_domain := 'session'` (**not** `'waiting'`: `catchmenu_ledger.audit_records.chk_audit_domain` does not allow `'waiting'`, confirmed live; using it would make this exact `append_audit_record()` call itself crash with no handler above it, propagating a raw error to the client — `600652_Logic.md` §1.5's 2026-07-18 correction) — and **returns** `build_error_response('waiting_seat_operation_failed', ...)` — must not `RAISE`.

### §2.3 Two ledger events, deliberately

Per `600652_Logic.md` §3: `bind_table_to_session()`'s `session`/`table_bound` event and this facade's own `waiting`/`customer_seated` event (carrying `wait_duration_seconds`, which the former does not have) both persist on a successful seating. This is a documented design decision, not a defect — Stage 8 must not deduplicate or remove either event.

### §2.4 GRANT/REVOKE

`seat_waiting_customer()`'s existing GRANT (`0115:1756-1759`, already `{postgres,authenticated}`, no bare `PUBLIC`) is left as-is — the signature does not change, so no new GRANT statement is required. `_resolve_dining_table_by_number()` gets the internal-only treatment in §2.1.

### §2.5 `message_catalog`/`error_codes` — per `600652_Logic.md` §5

Five new `error_key`s, all `waiting_`-prefixed to avoid colliding with `601122_Logic.md`'s `STORE`-domain keys (`table_not_found` etc. — `build_error_response()`'s lookup is not domain-scoped, so a bare reuse would be ambiguous): `waiting_table_not_found`, `waiting_table_number_ambiguous`, `waiting_table_inactive`, `waiting_table_number_required`, `waiting_seat_operation_failed`. `error_domain := 'ORDER'`. The specific `code` values (`7073`-`7077` as drafted) are **not** fixed by this contract — §6 Stop Condition #2 and `600653_TestPlan.md` §1.3/§9(procedure referenced in Logic) govern the required live re-check immediately before Stage 8 runs the migration.

### §2.6 Migration file header

Per `600652_Logic.md` §6 — header distinguishing this file's purpose (facade rewrite + new resolver) from `0115`'s original scope, `Depends on: 0162_create_dining_table_admin_rpc.sql`.

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule, matching `601114_ChangeContract.md` §2.7 / `601144_ChangeContract.md` §3 / `601124_ChangeContract.md` §3:

**New file `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`** (number to be reconfirmed, §1.1), operations listed in the exact file-statement order `600652_Logic.md` §6.1 requires:
1. Create the file with the header described in §2.6.
2. Add the `message_catalog`/`error_codes` INSERT blocks exactly as specified in §2.5/`600652_Logic.md` §5, with `code` values re-checked per §6 Stop Condition #2 before use — **first**, before either function definition (§6.1's ordering rationale: defensive against a Stage 8 "live re-execute just the function" mistake skipping this block).
3. Create `catchmenu_pos._resolve_dining_table_by_number(...)` exactly as specified in §2.1/`600652_Logic.md` §1.
4. `CREATE OR REPLACE` `catchmenu_pos.seat_waiting_customer(...)` exactly as specified in §2.2/`600652_Logic.md` §2 — including the `EXCEPTION` handler's `p_audit_domain := 'session'` (not `'waiting'`, which `chk_audit_domain` rejects — `600652_Logic.md` §1.5's 2026-07-18 correction) — preserving the existing signature exactly (no parameter added, removed, renamed, or reordered).
5. Add the `REVOKE`-only block for `_resolve_dining_table_by_number()` exactly as specified in §2.1/`600652_Logic.md` §1.1 — **last**, after both function bodies exist (matching `0110`/`0115`'s own established convention of a trailing GRANT/REVOKE block).

No operation is authorized on any other file.

## §4 Forbidden Operations

- Any change to `sql/migrations/0025_create_session_rpc.sql` (`bind_table_to_session()`, `_record_waiting_call()`-adjacent — not present here but same file family caution), `0048_create_table_management_rpc.sql`, `0050_create_waiting_queue_rpc.sql`, `0110_create_store_admin_rpc.sql`, `0115_create_waiting_pipeline_rpc.sql`, `0160_call_waiting_customer_contract_recovery.sql`, or `0162_create_dining_table_admin_rpc.sql`.
- Any change to the four sibling waiting-pipeline functions (`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`) or `pre_order_while_waiting()` — all confirmed still broken (`600651_Overview.md` §4.1/§4.2), explicitly deferred to a future workpacket.
- Any change to `catchmenu_pos._record_waiting_call()`, including its confirmed-empty `proacl` (`600652_Logic.md` §1.1/§8 (d)) — a related but separate finding, not fixed here.
- Any schema change to `catchmenu_store.dining_tables`, `catchmenu_pos.orders`, or `catchmenu_pos.order_sessions`.
- Adding a parameter to `seat_waiting_customer()`'s public signature, or changing parameter names/order/types.
- Re-wrapping `bind_table_to_session()`'s failure response in `build_error_response()` — this is the exact Stage 4 defect (§2.2); the raw response must pass through unmodified.
- Registering `session_not_bindable`/`table_already_bound`/`table_not_found`(bind's own)/`table_not_available` in `error_codes`/`message_catalog` under this contract — that would be registering `bind_table_to_session()`'s (`0025`'s) error vocabulary, out of this workpacket's ownership boundary (`600652_Logic.md` §2.1 reasoning #2).
- Creating any migration file other than the one named in §1.1.

## §5 Forbidden scope

- The four sibling waiting-pipeline functions + `pre_order_while_waiting()` — cross-referenced only, carried as Open Items (§8).
- `did_display_queue` — never implemented, not created by this contract (`600651_Overview.md` §4.3).
- `_record_waiting_call()`'s empty `proacl` — cross-referenced only, not fixed here.
- `601100_store_admin_console/` — different domain, zero-diff boundary already covered via `0162`.
- Flutter/client code.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_pos.bind_table_to_session()`'s live signature or its five documented failure `error_key`s (`session_not_found`/`session_not_bindable`/`table_already_bound`/`table_not_found`/`table_not_available`) differ from what `600651_Overview.md` §1.2 documents (`600653_TestPlan.md` §1.2).
2. `select max(code) from catchmenu_common.error_codes where error_domain='ORDER'` returns anything other than `7072` immediately before Stage 8 runs the migration — the five `error_codes` rows (§2.5) must be renumbered starting one above the actual live max, not inserted as originally drafted (`600653_TestPlan.md` §1.3).
3. Any of the five new `error_key` values already exists in `catchmenu_common.error_codes` or `catchmenu_common.message_catalog` under a different, conflicting definition.
4. `catchmenu_pos.order_sessions`'s live schema no longer has `order_id`/`pre_order_created_at`/`table_id` as documented (`600651_Overview.md` §3, `600653_TestPlan.md` §1.2).
5. `catchmenu_store.dining_tables.uq_dining_table_store_code` is no longer a full (non-partial) `UNIQUE (store_id, table_code)` constraint — this would change both the resolver's correctness assumptions (§2.1) and invalidate `600653_TestPlan.md` §6's `AMBIGUOUS` test technique.
6. Completing this implementation would require modifying any file or function named in §1.2's no-regression list.
7. The public parameter set of `seat_waiting_customer()` would need to change from its existing signature to complete this task — that would mean a `600651_Overview.md`/`600652_Logic.md` design decision was wrong and requires returning to Stage 5 for a new boundary.
8. `600653_TestPlan.md` §7's reachability analysis is found to be wrong at Stage 8 — i.e. `session_not_found` or `table_not_found` (table-side) from `bind_table_to_session()` turns out to be reachable through the facade after all (would indicate a control-flow bug in the implementation relative to `600652_Logic.md` §2's specified order).
9. `sql/migrations/0163_...` (or whatever number is actually used, §1.1) is found to already exist with different content when Stage 8 begins.

## §7 Required verification

Stage 8 must run `600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` completely.

Required evidence:

1. Pre-flight function/schema/error-code baseline checks (§1).
2. Normal seating end-to-end: session `SEATED`, table `OCCUPIED` (both via `bind_table_to_session()`), two distinct ledger events, correct response shape (§2).
3. Pre-order seating correctly sources `pre_order_amount` from `orders.final_amount` via the `order_id` LEFT JOIN — the direct proof the original crash is gone (§2.4).
4. `waiting_table_number_required`/`waiting_table_not_found`/`waiting_table_inactive`/`waiting_table_number_ambiguous` all correctly returned, including the `AMBIGUOUS` case via the constraint-lifted test technique with the constraint confirmed restored afterward (§3-§6).
5. Of `bind_table_to_session()`'s five failure keys, the three reachable ones (`session_not_bindable`, `table_already_bound`, `table_not_available`) reproduced with the raw flat JSON passed through unmodified and no crash; the two unreachable ones documented via the reachability table, not a forced live reproduction (§7).
6. `waiting_already_seated` intercepted before the resolver or `bind_table_to_session()` ever run (§8).
7. `EXCEPTION` handler path: `waiting_seat_operation_failed` returned with no raw error reaching the client, the facade's own `FAILED` audit row persists, and `bind_table_to_session()`'s state changes (session/table/its own ledger event/its own audit record) are all rolled back together with the exception — the trigger technique (a transaction-scoped temporary `CHECK` constraint on `catchmenu_ledger.events` targeting only `event_type='customer_seated'`) was found and live-verified at Stage 5 (`600653_TestPlan.md` §9).
8. Zero diff on all seven no-regression files listed in §1.2, confirmed via `git status --short` on each (§10).

## §8 Open Items (carried from `600652_Logic.md` §8, plus one new item from TestPlan authoring)

(a) `601121_Overview.md` §6 (f) / `600651_Overview.md` §6 (b) / `600652_Logic.md` §8 (a) — the four sibling waiting-pipeline functions (`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`), still confirmed broken, need a future workpacket.

(b) `600651_Overview.md` §6 (c) / `600652_Logic.md` §8 (b) — `pre_order_while_waiting()` also broken, possibly dead code (superseded by `0051.create_pre_order()`), needs confirmation.

(c) `600651_Overview.md` §6 (d) / `600652_Logic.md` §8 (c) — `did_display_queue` never implemented, a pre-existing design-doc/implementation gap, not created here.

(d) `600652_Logic.md` §8 (d) — `catchmenu_pos._record_waiting_call()`'s `proacl` is empty (no `REVOKE`, same bypass-risk class as `upsert_menu_core()`'s pre-`601140` state) — a candidate for a future `0160`-family cleanup workpacket, not fixed here.

(e) `600651_Overview.md` §6 (a)/(e) / `600652_Logic.md` §8 (e) — the `waiting_` error-key prefix naming choice, and whether `p_table_number` should be normalized (trim/case-fold) before resolver lookup — both carried forward for Human review.

(f) `600652_Logic.md` §8 (g) — this facade's failure responses have two different shapes depending on cause (nested `error.key` via `build_error_response()` for validation/resolver/exception failures, flat `error_key` for `bind_table_to_session()` delegation failures) — a deliberate, documented tradeoff (§2.2), not resolved, since unifying it would require changing `bind_table_to_session()` itself (out of `0025`'s boundary, §4).

(g) **[해소, 2026-07-18, `600653_TestPlan.md` §9 재시도 성공]** `seat_waiting_customer()`의 `EXCEPTION` 핸들러 테스트 트리거를 확정하지 못했다고 남겼던 항목 — §6의 "트랜잭션 내 제약 임시 조작" 기법을 반대 방향(완화 대신 강화)으로 적용해 해결했다. `catchmenu_ledger.events`에 `event_type='customer_seated'`만 정확히 겨냥하는 임시 `CHECK` 제약을 추가하면 `bind_table_to_session()` 자신의 `'table_bound'` 이벤트에는 영향을 주지 않으면서 파사드 자신의 이벤트 INSERT만 실패시킬 수 있음을 라이브로 확인했다(`600653_TestPlan.md` §9.1). 이 과정에서 발견한 부가 사실(§9.2): `bind_table_to_session()`은 자체 `EXCEPTION` 핸들러가 없어 별도 SAVEPOINT 경계가 없으므로, 파사드가 나중에 예외를 잡으면 `bind_table_to_session()`의 상태 변경까지 전부 함께 롤백된다 — 이는 결함이 아니라 바람직한 전체 원자성이며, 최소 재현(임시 함수 2개)으로 별도 검증까지 마쳤다.

(h) **[정정, 2026-07-18, Codex+Cursor 검증 — "미확인 호출자"를 실제 두 사례로 구체화]** `bind_table_to_session()`이 자체 `EXCEPTION` 핸들러를 갖고 있지 않다는 사실(§9.2)은 이 워크패킷의 파사드에서는 "실패 시 전체 원자성"이라는 바람직한 결과를 낳지만, `bind_table_to_session()`의 다른 호출자에게는 그렇지 않을 수 있다 — 이번 턴 라이브로 전수 확인한 결과:

- `sql/migrations/0051_create_pre_order_rpc.sql:453-465`(`confirm_pre_order_arrival()`) — `v_bind_result := catchmenu_pos.bind_table_to_session(...)`로 반환값을 받아 `if not (v_bind_result->>'success')::boolean then return v_bind_result; end if;`로 명시적으로 확인하고 안전하게 그대로 전파한다. **문제 없음** — 이 워크패킷의 §2.2 설계(`return v_bind_result;`, 재래핑 없이 그대로 반환)와 정확히 동일한 기존 패턴이며, 이 워크패킷의 설계가 이미 검증된 관례를 따르고 있음을 보여주는 추가 근거이기도 하다.
- `sql/migrations/0052_create_kiosk_session_rpc.sql:226-233`(키오스크 `DINE_IN` 주문 제출 경로) — `perform catchmenu_pos.bind_table_to_session(...)`로 호출하고 **반환값 자체를 전혀 검사하지 않는다**(`perform`은 반환값을 버리는 구문). `bind_table_to_session()`이 `table_not_available`/`session_not_bindable` 등으로 실패해도, 이 호출자는 그것을 알아챌 방법이 없다 — 키오스크 주문 제출이 테이블 바인딩 실패를 완전히 무시하고 계속 진행된다는 뜻이다. 이것이 바로 "조용히 사라지는" 위험 패턴의 **실제 사례**다.

이 워크패킷은 `bind_table_to_session()`도 `0052`도 수정하지 않으므로(§4) 범위 밖이지만, `0052`의 사례는 실제 데이터 정합성 위험(키오스크 손님이 테이블에 실제로는 바인딩되지 않았는데도 주문이 정상 진행되는 경우)을 시사하므로 — 향후 `0025` 계열 검토 워크패킷의 **최우선 확인 대상**으로 격상한다.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation:

☑ I approve creating a new migration file (tentative `0163`, exact number
  reconfirmed live immediately before Stage 8 runs, §1.1) containing the new
  helper `_resolve_dining_table_by_number()` and the `CREATE OR REPLACE` of
  `seat_waiting_customer()` exactly as specified in §2/`600652_Logic.md`
  §1-§2, with no modification to any existing migration file including
  `0115` (the file `seat_waiting_customer()` was originally defined in).

☑ I approve the resolver design (§2.1) — 0/1/2+ match handling against
  `dining_tables.table_code`, `is_active` checked separately from existence,
  and internal-only GRANT (not even `authenticated`).

☑ I approve the facade's control flow (§2.2) — in particular, that
  `bind_table_to_session()`'s failure response is returned **unmodified**
  (not re-wrapped via `build_error_response()`), and that this means the
  facade's error responses have two different shapes depending on failure
  cause (§8 (f), an accepted tradeoff, not a defect to fix here).

☑ I approve that two ledger events (`session`/`table_bound` from
  `bind_table_to_session()`, `waiting`/`customer_seated` from this facade)
  persist per successful seating, by design (§2.3).

☑ I approve that the four sibling waiting-pipeline functions,
  `pre_order_while_waiting()`, `did_display_queue`, and
  `_record_waiting_call()`'s empty `proacl` are entirely out of scope and
  no-regression-only under this contract (§1.2/§4/§5/§8) — none of these are
  fixed by this workpacket. (2026-07-18)

## §10 Approval state

APPROVED (2026-07-18).

## §11 Final Audit (Stage 11, Claude)

**Verdict: ACCEPT (2026-07-18)**

핵심 주장 재도출 확인 (Stage 9 산출물을 액면 그대로 신뢰하지 않고 직접 재검토):

- 리졸버(_resolve_dining_table_by_number, 0/1/2+ 판정)와 파사드(seat_waiting_customer, bind_table_to_session() 위임) 설계를 Cursor+Claude Code+안티 3자 독립 재현으로 확인.
- audit_domain='waiting'→'session' 정정: Codex+Cursor가 실제 크래시 재현으로 발견, 정정 후 해소 확인.
- error_key 도메인 오매핑(table_not_found STORE↔ORDER 충돌) 해소.
- Stage 4에서 발견된 미등록 에러키 크래시(session_not_bindable/table_already_bound)를 "재래핑 없이 원본 응답 그대로 반환"하는 방식으로 근본 해결, 응답 형태 불일치는 의식적 트레이드오프로 정확히 기록.
- EXCEPTION 원자성(bind_table_to_session()의 세션/테이블/자체렛저/자체감사 전체가 파사드 실패 시 함께 롤백, facade 자체 감사기록만 생존) - 설계 의도대로 정확히 작동 확인, 3자 일치.
- Open Item (h): "미확인 호출자"를 0051(안전, return v_bind_result 동일 패턴)/0052(위험, perform으로 반환값 미검사)로 구체화, 실제 파일/라인 인용 확인.

Stage 9에서 발견된 부가 사항(구현 결함 아님, 기록만):
- 600653_TestPlan.md §2.4가 orders.order_source(실제 없음)를 참조 - 실제 컬럼명 order_channel로 문서 정정 필요(구현 0163은 무관, TestPlan 오타).
- seat_waiting_customer()의 proacl에 PUBLIC EXECUTE 잔존 - 0115 원본부터의 기존 상태(형제 함수 4개 동일), 0163의 회귀 아님, 600654 §2.4 범위와 일치.

Boundary 확인: 0025/0048/0050/0110/0115/0160/0162 전부 0 diff (3자 일치).

**Open Items (다음 워크패킷 후보로 이월):**

1. 형제 함수 4개(confirm_arrival/get_waiting_status/get_waiting_admin_view/cancel_waiting) - 여전히 살아있는 크래시 결함.
2. pre_order_while_waiting() - 죽은 코드일 가능성, 확인 필요.
3. did_display_queue - 설계문서에만 있고 구현 자체가 없음.
4. _record_waiting_call()의 proacl 공백 - upsert_menu_core() 이전 상태와 동일 클래스의 보안 위험.
5. **[신규, 우선순위 높음]** 0052_create_kiosk_session_rpc.sql의 bind_table_to_session() 호출이 반환값을 검사 안 함 - 실제 "조용히 사라지는" 위험 사례.
6. 600653_TestPlan.md §2.4의 order_source→order_channel 오타 정정 필요(경미, 문서만).
7. seat_waiting_customer()의 PUBLIC EXECUTE 잔존 - 0115 계열 전체(형제 함수 4개 포함)의 GRANT 정리 후보.

## §12 Human Merge/Release

담당: Human (정영석님)