===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600600_Readme_Waiting_Order_Session.md] =====
# 600600_Readme_Waiting_Order_Session.md

Status: Active
Lifecycle: Readme
Domain: Waiting / Order Session

## Purpose

This folder owns waiting and order-session workpackets that were previously mixed into the KDS/DID implementation folder.

## In Scope

- Takeout session-type reconciliation where the defect is rooted in order-session status/session-type contracts.
- Customer handoff contract reconciliation for waiting, pre-order, payment, KDS, and DID boundary facts where the active fix belongs to waiting/order-session contracts.

## Out of Scope

- Payment provider confirmation overload disposition.
- Takeout/pickup order table timing columns.
- DID display-state overload work.
- KDS-only capacity/status work.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600610_takeout_session_type_fix/` | `TAKEOUT` session-type alignment across order-session creation and takeout order flow. | Moved from `600400_kds_did_implementation/`. |
| `600620_customer_handoff_contract_reconciliation/` | Customer handoff contract reconciliation for waiting/order-session flow. | Moved from `600400_kds_did_implementation/`. |



===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600602_NavigationMap_Waiting_Order_Session.md] =====
# 600602_NavigationMap_Waiting_Order_Session.md

Status: Active
Lifecycle: NavigationMap
Domain: Waiting / Order Session

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600610_takeout_session_type_fix/` | `ONLINE` → `TAKEOUT` session-type correction and `TAKEOUT` → `ORDERING` session-status mapping. | `600611_Overview.md` → `600612_Logic.md` → `600613_TestPlan.md` → `600614_ChangeContract.md` → `600615_Module.md` → `600616_Verification.md` → `600617_Audit.md` |
| `600620_customer_handoff_contract_reconciliation/` | Waiting/pre-order customer handoff contract reconciliation, including `kds_tickets` insert and waiting realtime state contract facts. | `600621_Overview.md` → `600622_Logic.md` → `600623_TestPlan.md` → `600624_ChangeContract.md` → `600625_Module.md` → `600626_Verification.md` → `600627_Audit.md` |
| `600630_mark_no_show_overload_and_redesign/` | Implements `0161_mark_no_show_overload_and_redesign.sql`: registers no-show error keys, adds `kds_tickets.hold_expires_at`, creates the shared `apply_no_show_transition()` core plus manual/automatic/KDS grace functions, drops the legacy `0050` `mark_no_show()` overload, and rewrites `0118` `WAITING_SESSION_EXPIRE` to call store-scoped batch functions instead of phantom-column inline updates. Stage 6 ACCEPT after Cursor + 안티 + Claude Code triple independent verification. | `600631_Overview_Mark_No_Show_Overload_And_Redesign.md` → `600632_Logic.md` → `600633_TestPlan.md` → `600634_ChangeContract.md` → `600635_Module.md` → `600636_Verification.md` → `600637_Audit.md` |
| `600640_call_waiting_customer_contract_recovery/` | Fix `catchmenu_pos.call_waiting_customer()`(`0115:419-599`) by replacing phantom `order_sessions` concepts (`called_at`/`table_number`/`call_count`/`pre_order_amount`) with `session_events`, request/response payload, and linked `orders.final_amount`. Implemented `0160_call_waiting_customer_contract_recovery.sql`: internal `_record_waiting_call()`, corrected `call_waiting_customer()`, new `call_next_waiting_customer()` with `SKIP LOCKED`, legacy `call_next_waiting()` DROP, and COMMENT-only deprecation of `no_show_auto_expire_minutes`. Stage 6 ACCEPT; note that `0115` source body remains stale and is carried as a source-sync Open Item. | `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` → `600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` → `600643_TestPlan.md` → `600644_ChangeContract.md` → `600645_Module.md` → `600646_Verification.md` → `600647_Audit.md` |
| `600650_seat_waiting_customer_facade_correction/` | Rewrite `catchmenu_pos.seat_waiting_customer()`(`0115:988-1206`, crashes on phantom `order_sessions.table_number` write) as a thin facade delegating to the canonical `catchmenu_pos.bind_table_to_session()`(`0025`, unmodified) via a new resolver `_resolve_dining_table_by_number()`. Implemented `0163_seat_waiting_customer_facade_correction.sql`. Stage 9 independently re-verified (Claude Code, fresh fixtures) — all `600653_TestPlan.md` §11 acceptance criteria pass; found and worked around a `600653_TestPlan.md` §2.4 fixture defect (`orders.order_source` does not exist, real column is `order_channel`). | `600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` → `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` → `600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` → `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` |
| `600660_waiting_pipeline_sibling_functions_correction/` | Correct the remaining 4 `0115` functions broken by the same phantom-`order_sessions`-column defect class as `600640`/`600650`: `confirm_arrival()` (rewritten as a facade delegating to the previously-orphaned `catchmenu_pos.mark_session_arrived()`, `0025`, unmodified), `get_waiting_status()`/`get_waiting_admin_view()` (LEFT JOIN `orders`/`dining_tables` + `session_events`-derived `called_at`/`call_count`, reusing `0160`'s `_record_waiting_call()` derivation pattern), `cancel_waiting()` (drops the phantom `cancel_reason` write, ledger event remains the sole source of truth for it). `get_waiting_admin_view()`'s phantom `memo` field has no real/derivable substitute and is dropped from scope (candidate for a separate `waiting_session_staff_memo_feature` workpacket); its hardcoded `patent_note` field was also dropped as a separately-Human-approved response-contract change (`600664` §9, all 6 boxes checked). `cancel_waiting()`'s missing status guard / table-release-on-cancel gap is explicitly out of scope (candidate `cancel_waiting_state_guard_and_table_release`). `600664` §10 **APPROVED** (2026-07-18) — Stage 8 implemented as `0164_waiting_pipeline_sibling_functions_correction.sql`; live-reconfirmed (2026-07-18) that all 4 functions run the new design (`mark_session_arrived()` delegation, LEFT JOIN/`session_events` derivation, no `memo`/`patent_note`, `error_codes` 7078/7079 registered) after an out-of-band partial premature deployment (2 of 4 functions applied ahead of approval) was caught, reverted to the exact `0115` original, and then correctly re-applied via `0164` in full. Stage 9 independent re-verification still pending. | `600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` → `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` → `600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` → `600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` (APPROVED) → `0164_waiting_pipeline_sibling_functions_correction.sql` (implemented, live) |


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600611_Overview.md] =====
# 600611_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## §0 배경 (오늘 이미 확정된 조사 결과, 재확인 불필요로 전제 — 원문은 이번 턴 재확인)

`place_takeout_order()`(`0081`)가 `catchmenu_pos.order_sessions` INSERT 시 `session_type = 'ONLINE'`을 쓰는데, 실제 `chk_session_type` 허용값은 `WALK_IN`/`WAITING`/`PRE_ORDER`/`KIOSK`/`TAKEOUT`/`DELIVERY`뿐(`0012` 정의)이다. `'ONLINE'`은 어디에도 허용되지 않아 모든 포장 주문이 이 지점에서 100% 실패한다. `register_waiting()`(`0115`)은 `'WAITING'`을, delivery intake는 `'DELIVERY'`를 정상 사용 — `place_takeout_order()`만 유일하게 어긋난다. `'TAKEOUT'`이 유력 후보(이미 허용값, 같은 함수의 `order_type = 'TAKEOUT'`과도 의미상 일치).

## §1 L826 정확한 위치와 INSERT 문 전체 (이번 턴 원문 재확인)

```sql
  insert into catchmenu_pos.order_sessions (
    tenant_id, store_id,
    session_type, session_status,
    guest_count, guest_locale,
    session_started_at,
    correlation_id,
    business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id,
    'ONLINE', 'ORDER_CONFIRMED',
    1, p_locale,
    now(),
    p_correlation_id,
    v_business_day, v_timezone
  )
  returning id into v_session_id;
```

`'ONLINE'`은 L826에 정확히 위치(`'ONLINE', 'ORDER_CONFIRMED',` 라인). `session_status`는 `'ORDER_CONFIRMED'`로 함께 세팅되며, 이는 `chk_session_type`과 별개의 제약(`session_status` 자체의 허용값)이므로 이번 수정 범위와 무관하다 — `session_type`만 문제다.

`chk_session_type` 라이브 정의(이번 턴 재확인): `CHECK ((session_type = ANY (ARRAY['WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'])))` — `0012_create_pos_order_sessions.sql`에서 정의된 이후 다른 어떤 마이그레이션도 이 제약을 `ALTER`한 적이 없음(전수 재확인, `0097`이 같은 이름의 제약을 갖고 있으나 이는 완전히 다른 테이블 — 로그인/인증 세션 테이블 — 의 동명 제약일 뿐임을 재확인).

## §2 `0063`의 "RPC validation ↔ 테이블 constraint 드리프트" — 이번 workpacket에서 함께 수정 확정

**Human 결정 (2026-07-13, 재논의 금지)**: `0063_patch_core_rpc_i18n_diagnostics.sql`의 `create_order_session()` 두 번째 오버로드 드리프트를 이번 workpacket에서 함께 고친다(이월하지 않음). 근거: "같은 증상, 같은 근본 원인이므로 조사 비용 재사용"이라는 반대 논거를 채택 — 이는 이전 초안(`600612_Logic.md` 초판)의 "이월 권고"를 대체한다.

**투명 공개 — 작업 지시의 파일 번호 참조 정정**: 지시문은 "`0063_create_order_session()`"이라 표현했으나, `catchmenu_pos.create_order_session()`이라는 함수는 실제로 **두 개의 파일에 걸쳐 두 개의 서로 다른 오버로드**로 존재한다 — 함수 이름 자체는 맞으나 파일명은 `0063_patch_core_rpc_i18n_diagnostics.sql`이다(`0063_create_order_session.sql`이라는 파일은 없음).

이번 턴 라이브 재확인 결과 `create_order_session`은 실제로 **2개 오버로드**가 공존한다:

| 오버로드 (파라미터로 식별) | 정의 파일 | `p_session_type` 검증 목록 | 테이블 제약과 일치? |
|---|---|---|---|
| `..., p_wait_number, p_table_id, p_expires_minutes, ...` | `0025_create_session_rpc.sql` | `'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'TAKEOUT', 'DELIVERY'` | **일치** — `chk_session_type`과 정확히 동일. `when 'TAKEOUT' then 'ORDERING'` 같은 상태 매핑도 이미 존재. |
| `..., p_wait_number, p_queue_position, p_pre_order_expires_at, ...` | `0063_patch_core_rpc_i18n_diagnostics.sql` | `'WALK_IN', 'WAITING', 'PRE_ORDER', 'KIOSK', 'DELIVERY', 'ONLINE'` | **불일치** — `'TAKEOUT'`이 빠지고 `'ONLINE'`이 대신 들어가 있다. 이 오버로드도 `p_session_type`을 그대로 `insert`에 전달(L142)하므로, `'ONLINE'`으로 호출하면 이 오버로드도 `chk_session_type` 위반으로 크래시한다 — `place_takeout_order()`와 **같은 증상, 다른 함수**. |

**이 함수(어느 오버로드든)의 실제 호출자는 이번 턴 재확인 결과 0건**이다(Flutter `catchmenu_app/lib` 0건, 다른 SQL 정의부 라이브 `prosrc` 스캔 0건 — `0035`/`0073`은 함수 존재 여부만 확인하는 검증 스크립트일 뿐 실제 호출 아님). 호출자 0건이라는 사실관계 자체는 변하지 않는다 — 다만 Human 결정에 따라 "긴급하지 않으니 이월"이 아니라 "지금 같이 고쳐서 조사 비용을 재사용"하는 쪽으로 범위를 확정한다.

**정확한 위치 재확인 (이번 턴)**: `0063`의 `create_order_session()` 두 번째 오버로드에서 검증 배열은 L44-47:

```sql
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER',
    'KIOSK', 'DELIVERY', 'ONLINE'
  ) then
```

이 배열의 `'ONLINE'`(L46)이 `'TAKEOUT'`으로 바뀌어야 할 대상이다. 같은 함수 L142에서 `p_session_type`이 그대로 `order_sessions` INSERT에 전달되므로(값 자체는 그대로 통과), 이번 배열 수정으로 `'TAKEOUT'` 호출이 처음으로 검증을 통과해 실제 INSERT까지 도달하게 된다 — 상세 Before/After와 하류 영향은 `600612_Logic.md` §2 참조.

## §2.5 Candidate Affected Files — 2개 파일, 2개 함수로 확장

| 파일 | 함수 | 수정 내용 | 위치 |
|---|---|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` | `order_sessions` INSERT의 `session_type` 리터럴 `'ONLINE'` → `'TAKEOUT'` | L826 |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | `catchmenu_pos.create_order_session()` (두 번째 오버로드 — `p_queue_position`/`p_pre_order_expires_at` 시그니처) | (a) `p_session_type not in (...)` 검증 배열의 `'ONLINE'` → `'TAKEOUT'` | L46 |
| 〃 | 〃 | (b) `case p_session_type` 분기 4곳에 `when 'TAKEOUT' then 'ORDERING'` 명시 추가(Human 결정, `0025` L71과 정합) | L143-148, L173-178, L202-206, L244-249 |

두 파일 모두 "허용값/분기 목록에 `'TAKEOUT'`이 빠져 있거나 `'ONLINE'`으로 잘못 들어가 있다"는 동일한 근본 원인 계열을 공유하지만, 서로 다른 함수·다른 시그니처·다른 파일이므로 각각 독립적으로 수정한다. `0081`은 1곳(리터럴 1개), `0063`은 검증 배열 1곳 + `case` 분기 4곳으로 총 5곳(상세 Before/After는 `600612_Logic.md` §2/§2.1 참조). `0025_create_session_rpc.sql`의 `create_order_session()` 첫 번째 오버로드는 이미 정확하므로(§1 표 참조) 수정 대상이 아니다. `0063`의 `case` 분기 4곳 중 L202-206은 `'DELIVERY'` 분기 자체가 원래 없는 별개의 기존 불일치를 이번 턴에 발견했으나, 이번 Human 결정(TAKEOUT 추가)의 범위 밖이므로 손대지 않는다(`600612_Logic.md` §2.1 투명 공개).

## §3 `order_sessions.session_type` 값 참조/기대 전수 확인 — 회귀 위험 없음

**`'ONLINE'`을 읽는(WHERE/필터) 쪽**: `sql/migrations/*.sql` 전체와 `catchmenu_app/lib` 전체를 `session_type.*=.*'ONLINE'` / `session_type.*in.*'ONLINE'` 패턴으로 재검색한 결과 **0건**. `'ONLINE'`이 다른 맥락(예: `device_status`, `agent_status`)에서 널리 쓰이는 리터럴이긴 하나(`0003`/`0041`/`0047`/`0070` 등, 전부 디바이스/에이전트 상태값이지 `session_type`이 아님), `order_sessions.session_type` 필터 조건으로서의 `'ONLINE'` 참조는 어디에도 없다.

**앞으로 쓰일 `'TAKEOUT'`을 읽는(WHERE/필터) 쪽**: 동일하게 `session_type.*'TAKEOUT'` 패턴으로 전수 검색한 결과도 **0건**. 즉 `session_type = 'TAKEOUT'`을 특별 취급하는 기존 로직이 전혀 없으므로, 이번 값 변경으로 새로 생성될 `'TAKEOUT'` 세션이 기존의 어떤 필터링된 조회/집계에 예기치 않게 편입되거나 배제될 위험도 없다.

**결론**: `'ONLINE'` → `'TAKEOUT'` 값 변경은 이 저장소 범위 안에서 회귀 위험이 확인되지 않는, 격리된 단일 지점 수정이다.

## §4 `0081` 자체 내 다른 `'ONLINE'` 언급 — 무관함 확인

`0081` L193(`grep`으로 발견)에도 `'TAKEOUT', 'DELIVERY', 'ONLINE'`이라는 문구가 있으나, 확인 결과 이는 L185-198 범위의 **완전히 주석 처리(비활성)된 `catchmenu_store.customer_order_history` 뷰 정의 초안**의 일부이며, `catchmenu_pos.orders.order_type`(별개 컬럼, `order_sessions.session_type`이 아님) 값 목록을 나열한 것이다. 실행되지 않는 코드이고 다루는 컬럼도 다르므로 이번 수정과 무관하다 — 참고만 하고 손대지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md` — 이번 문서가 따르는 8단계 파이프라인(Stage 1.5) 그 자체.
- `000001_Md_Rules.md` — 문서 작성 규칙 상위 anchor.

### Full Rules Required

- `sql/migrations/0012_create_pos_order_sessions.sql` — `chk_session_type` 제약의 원 정의(전체 허용값 목록의 유일한 출처).
- `sql/migrations/0025_create_session_rpc.sql` — `create_order_session()` 첫 번째(정확한) 오버로드. 이번 수정이 목표로 하는 "정답" 값 목록의 근거.

### Domain Indexes

- 해당 없음 — 본문에 도메인 Index/NavigationMap/Readme 인용은 없다.

### Excluded Rule Families

- 900시리즈(설계/특허 문서군) — 이번 수정은 리터럴 값 하나(그리고 동일 근본 원인의 두 번째 리터럴 값 하나)를 허용값 목록에 맞게 교정하는 단순 정합화이며, 상위 설계/특허 anchor를 참조하지 않는다.
- `600717_Audit.md`의 `point_ledger`/`discount_pct` Open Items — 관련 있으나 이번 workpacket의 수정 범위(§2.5의 2개 파일)와는 완전히 다른 코드 영역이므로 이번 Context Snapshot에 포함하지 않는다.
- 쿠폰 이중 사용 레이스컨디션 — `600712_Logic.md` Open Questions로 이월된 별도 후보, 이번 수정과 무관.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600612_Logic.md` 작성 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600612_Logic.md] =====
# 600612_Logic.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## §1 수정 계획 — Before / After

파일: `sql/migrations/0081_create_customer_app_rpc.sql`
함수: `catchmenu_store.place_takeout_order()`
위치: L826 (`order_sessions` INSERT의 `values` 절, `session_type` 컬럼 값)

**Before**:
```sql
    p_tenant_id, p_store_id,
    'ONLINE', 'ORDER_CONFIRMED',
```

**After**:
```sql
    p_tenant_id, p_store_id,
    'TAKEOUT', 'ORDER_CONFIRMED',
```

변경 범위: 리터럴 문자열 1개, 1개 라인. `session_status`(`'ORDER_CONFIRMED'`)는 변경하지 않는다 — `chk_session_type`과 무관한 별개 컬럼/제약이며 `600611_Overview.md` §1에서 확인했듯 이번 결함과 관계없다.

**근거**: `'TAKEOUT'`은 이미 `chk_session_type`(`0012`) 허용값에 포함되어 있고, 같은 함수 안에서 이미 `orders.order_type := 'TAKEOUT'`로 쓰이고 있어 의미상으로도 일치한다(`600611_Overview.md` §0/§1). `register_waiting()`이 `'WAITING'`을 쓰는 것과 동일한 패턴 — 세션 종류를 나타내는 값은 해당 세션의 실제 유형과 일치시킨다는 기존 코드베이스 관례를 따른다.

## §2 확정 — `0063`의 `create_order_session()` 오버로드 드리프트, Before/After

**Human 결정 (2026-07-13, 재논의 금지)**: 이 항목은 더 이상 Open Question이 아니다. `0063_patch_core_rpc_i18n_diagnostics.sql`의 `create_order_session()` 두 번째 오버로드 드리프트를 이번 workpacket에서 함께 고친다(이월하지 않음). 근거는 "같은 증상, 같은 근본 원인이므로 조사 비용 재사용"이라는 반대 논거 채택 — 이전 초안(§2 초판)의 "이월 권고"를 대체한다.

파일: `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
함수: `catchmenu_pos.create_order_session()` (두 번째 오버로드 — `p_wait_number, p_queue_position, p_pre_order_expires_at, ...` 시그니처)
위치: L44-47 (`p_session_type not in (...)` 검증 배열)

**Before**:
```sql
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER',
    'KIOSK', 'DELIVERY', 'ONLINE'
  ) then
```

**After**:
```sql
  if p_session_type not in (
    'WALK_IN', 'WAITING', 'PRE_ORDER',
    'KIOSK', 'DELIVERY', 'TAKEOUT'
  ) then
```

변경 범위: L46 한 줄, 배열 원소 1개(`'ONLINE'` → `'TAKEOUT'`). 이로써 이 오버로드의 검증 목록이 `0025_create_session_rpc.sql`의 첫 번째(정확한) 오버로드 및 `chk_session_type`과 동일해진다.

### §2.1 L142 전달부 및 `case p_session_type` 분기 — Human 결정으로 `'TAKEOUT'` 분기 명시 추가 확정

**Human 결정 (2026-07-13, 재논의 금지)**: `0063`의 `create_order_session()` 두 번째 오버로드의 `case p_session_type when ...` 분기문에 `when 'TAKEOUT' then 'ORDERING'`을 추가한다 — `0025` 오버로드와 동일한 `session_status` 매핑으로 완전히 정합화한다. 근거: 호출자가 지금 0건이라도 두 오버로드의 동작이 불일치한 채로 남으면 향후 재사용 시 예측 불가능한 버그(포장 주문이 대기 상태로 빠지는 등)의 원인이 되므로, 기술 부채를 남기지 않고 지금 함께 정정한다.

**정합화 기준값 재확인**: `sql/migrations/0025_create_session_rpc.sql` L71 `when 'TAKEOUT' then 'ORDERING'` — 이번 결정이 목표로 하는 정확한 매핑값을 이번 턴 재확인했다.

동일 함수 L142에서 `p_session_type`은 그대로 `order_sessions` INSERT의 `values` 절에 전달된다(치환 없이 파라미터 그대로 삽입, 이 줄 자체는 수정하지 않음). §2의 배열 수정으로 **이전에는 도달 불가능했던 `p_session_type = 'TAKEOUT'` 호출이 처음으로 검증을 통과해 이 INSERT까지 도달**하게 되고, 이제는 이번 §2.1의 `case` 분기 추가로 그 결과값이 `else`(`'WAITING'`)가 아니라 명시적인 `'ORDERING'`이 된다.

**`case p_session_type` 분기 재확인 — 4곳 중 수정 대상은 `session_status` 결정용 4곳**: `0063`에는 `case p_session_type`류 블록이 총 5곳(L143-148, L154-158, L173-178, L202-206, L244-249) 있으나, 이 중 L154-158은 `expires_at` 만료시각 계산용(`WALK_IN`/`KIOSK`만 값 있음, else `null`)으로 `session_status`와 무관하므로 이번 Human 결정(session_status 매핑 정합화)의 대상이 아니다. 나머지 4곳(L143-148/L173-178/L202-206/L244-249)이 `session_status`(또는 그 동의어인 `to_status`/`to_state`) 값을 결정하므로 수정 대상이다.

**Before/After — L143-148 (`order_sessions` INSERT의 `session_status` 컬럼)**:
```sql
-- Before
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
-- After
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'TAKEOUT' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
```

**Before/After — L173-178 (`session_events` INSERT의 `to_status` 컬럼)**: 동일 패턴, 동일 삽입.
```sql
-- Before
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
-- After
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'TAKEOUT' then 'ORDERING'
      when 'DELIVERY' then 'ORDER_CONFIRMED'
      else 'WAITING'
    end,
```

**Before/After — L202-206 (`catchmenu_ledger.events` INSERT의 `to_state` 컬럼)**: 이 블록은 다른 3곳과 달리 원래부터 `'DELIVERY'` 분기 자체가 없다(`WALK_IN`/`KIOSK`/`else`만 존재) — 이번 턴 재확인으로 발견한 **별개의 기존 불일치**이며, 이 Human 결정(TAKEOUT 추가)의 범위가 아니므로 `DELIVERY` 분기를 추가하지 않고 그대로 둔다. `TAKEOUT`만 추가한다.
```sql
-- Before
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      else 'WAITING'
    end,
-- After
    case p_session_type
      when 'WALK_IN' then 'ORDERING'
      when 'KIOSK' then 'ORDERING'
      when 'TAKEOUT' then 'ORDERING'
      else 'WAITING'
    end,
```

**Before/After — L244-249 (RPC 반환 jsonb의 `session_status` 키)**: L143-148/L173-178과 동일 패턴, 동일 삽입.
```sql
-- Before
      'session_status', case p_session_type
        when 'WALK_IN' then 'ORDERING'
        when 'KIOSK' then 'ORDERING'
        when 'DELIVERY' then 'ORDER_CONFIRMED'
        else 'WAITING'
      end,
-- After
      'session_status', case p_session_type
        when 'WALK_IN' then 'ORDERING'
        when 'KIOSK' then 'ORDERING'
        when 'TAKEOUT' then 'ORDERING'
        when 'DELIVERY' then 'ORDER_CONFIRMED'
        else 'WAITING'
      end,
```

**투명 공개 — 이번 결정의 범위를 넘는 추가 발견, 손대지 않음**: (1) 위 L202-206의 `'DELIVERY'` 분기 누락은 TAKEOUT 추가와 무관한 기존 결함이며 이번 Human 결정 범위 밖이므로 수정하지 않는다. (2) `0025`(L67 `when 'WALK_IN' then 'SEATED'`)와 `0063`(L144 `when 'WALK_IN' then 'ORDERING'`)은 `TAKEOUT` 외에도 `WALK_IN`의 매핑값 자체가 서로 다르다 — 두 오버로드가 "완전히 정합"하지는 않는다는 뜻이지만, 이번 Human 결정은 명시적으로 `TAKEOUT` 매핑 추가만을 지시했으므로 `WALK_IN` 불일치는 건드리지 않고 별도 Open Item으로만 남긴다.

## §3 회귀 위험 분석 — `order_sessions`를 조회하는 다른 함수(주문 조회, KDS 실시간 상태 등)에서 `session_type` 필터를 쓰는지

`600611_Overview.md` §3에서 이미 확인한 전수 검색 결과를 그대로 인용한다:

- `session_type = 'ONLINE'` 또는 `session_type in (...'ONLINE'...)` 패턴: SQL 마이그레이션 전체(`sql/migrations/*.sql`) + Flutter(`catchmenu_app/lib`) 전수 검색 **0건**.
- `session_type = 'TAKEOUT'` 또는 `session_type in (...'TAKEOUT'...)` 패턴: 동일 범위 전수 검색 **0건**.

사용자가 명시적으로 예시로 든 "주문 조회", "KDS 실시간 상태" 계열 함수들도 이 전수 검색 범위(`sql/migrations/*.sql` 전체)에 포함되어 있으므로 별도로 파일명을 하나씩 짚어 확인할 필요 없이 이미 커버되었다 — 그런 함수들이 존재한다면 `session_type = '...'` 형태의 리터럴 비교를 코드에 갖고 있을 것이고, 그 패턴이 검색에 걸렸을 것이기 때문이다. 0건이라는 결과는 "그런 필터가 존재하지 않는다"는 뜻이지 "검색을 못 했다"는 뜻이 아니다.

**결론**: `order_sessions.session_type`을 읽어서 특정 값으로 필터링/분기하는 코드는 이 저장소 안에 현재 하나도 없다. 따라서 `'ONLINE'` → `'TAKEOUT'` 변경은 다른 함수의 동작을 바꾸지 않는다 — 회귀 위험 없음.

**`0063` 수정분도 동일 검색 범위에 포함됨**: 위 전수 검색은 `sql/migrations/*.sql` 전체(즉 `0063` 자신도 포함)를 대상으로 했으므로, `0063`의 검증 배열 변경에 대해서도 별도 추가 검색 없이 같은 결론이 적용된다. `0063`의 `create_order_session()` 자체는 `p_session_type`을 테이블 컬럼 값으로 저장·전달만 할 뿐 다른 곳에서 `session_type`으로 조회 필터링을 하지 않으므로(§2.1에서 확인한 `case p_session_type ...`는 파라미터 자체에 대한 분기이지 테이블 읽기가 아님), 이 함수 수정으로 인한 추가 회귀 경로도 없다.

**남은 확인 사항 (구현 후 실증 필요, 이번 문서로는 예측만 가능)**: 이 변경 자체는 `place_takeout_order()`가 `chk_session_type` 벽을 통과하게 만드는 것뿐이다. `600717_Audit.md` Open Items에 따르면 이 함수는 입력 조합에 따라 `point_ledger`(포인트+고객 식별 시) 또는 `discount_pct`(쿠폰 제공 시)에서 여전히 막힐 수 있다 — 이 변경 하나만으로 쿠폰 없음/포인트 없음 경로(가장 흔한 경로)는 세션 INSERT를 통과하지만, 그 이후 나머지 주문 흐름(결제, KDS 티켓 생성 등)까지 끝까지 성공하는지는 구현 후 실제 재실행으로 검증해야 한다 — 이 문서는 그 실증을 포함하지 않는다(`.sql` 파일 수정 금지 지시에 따라 이번 턴에서는 실행하지 않음).

## Open Questions

1. ~~`0063`의 `create_order_session()` 오버로드 드리프트를 이번 workpacket에서 함께 고칠지, 별도로 이월할지~~ — **해결됨.** Human 결정(2026-07-13)으로 함께 수정하는 것으로 확정, §2에 Before/After 반영 완료. 더 이상 Open Question 아님.
2. (참고, 이번 workpacket 범위 밖) `point_ledger`/`discount_pct` 결함의 수정 순서는 `600717_Audit.md` Open Items (a)(b)(c)에서 이미 chk_session_type → point_ledger → discount_pct 순으로 권고됨 — 이번 변경은 그 (a)에 해당.
3. ~~`0063`의 `create_order_session()` `else` 분기가 `'TAKEOUT'`에 대해 `session_status = 'WAITING'`으로 떨어지는 것이 의도된 설계인지~~ — **해결됨.** Human 결정(2026-07-13)으로 `case p_session_type` 분기 4곳(L143-148/L173-178/L202-206/L244-249)에 `when 'TAKEOUT' then 'ORDERING'`을 명시 추가해 `0025`와 완전 정합화(§2.1 Before/After 반영 완료). 더 이상 Open Question 아님.
4. (신규, 이번 workpacket 범위 밖) `0063` L202-206(ledger event `to_state`)에 `'DELIVERY'` 분기 자체가 없다는 것을 이번 턴 발견 — TAKEOUT 추가와 무관한 별개의 기존 결함, 이번 결정 범위 밖이라 손대지 않음(§2.1 투명 공개).
5. (신규, 이번 workpacket 범위 밖) `0025`(`WALK_IN`→`'SEATED'`)와 `0063`(`WALK_IN`→`'ORDERING'`)의 `WALK_IN` 매핑값 자체가 서로 다름을 이번 턴 발견 — 두 오버로드가 `TAKEOUT` 외에는 완전히 정합하지 않는다는 뜻. 이번 Human 결정은 `TAKEOUT` 매핑 추가만 지시했으므로 범위 밖으로 남긴다(§2.1 투명 공개).

## Snapshot Decision

이 스냅샷으로 Stage 2 (TestPlan/ChangeContract) 진행 가능. `.sql` 파일은 이번 턴에서 수정하지 않았음.

**ChangeContract 방향 예고**: 다음 Stage 2에서 작성될 `600614_ChangeContract.md`의 Allowed Files는 이제 2개 파일·2개 함수가 될 것이다:
1. `sql/migrations/0081_create_customer_app_rpc.sql` — `catchmenu_store.place_takeout_order()` 함수 본문만, L826 리터럴 1곳.
2. `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` — `catchmenu_pos.create_order_session()` 두 번째 오버로드(`p_queue_position`/`p_pre_order_expires_at` 시그니처) 본문만, 총 5곳: 검증 배열(L46) `'ONLINE'`→`'TAKEOUT'` 1곳 + `case p_session_type` 분기(L143-148/L173-178/L202-206/L244-249) `when 'TAKEOUT' then 'ORDERING'` 추가 4곳.

두 파일 모두 "`0025`/`chk_session_type`과의 `TAKEOUT` 관련 불일치를 정합화"라는 동일 성격의 범위로 한정되며, 각 파일 내 다른 함수·다른 로직(특히 `0063`의 `DELIVERY` 분기 누락·`WALK_IN` 매핑 불일치 등 §2.1에서 발견한 별개 이슈들)은 이전 `600714_ChangeContract.md`의 단일 함수 경계 관행과 동일하게 Forbidden으로 명시될 것이다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600613_TestPlan.md] =====
# 600613_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## 0. Authority And Scope

This TestPlan is derived from:

- `600611_Overview.md`
- `600612_Logic.md`

Confirmed design, without reopening design judgment:

- `sql/migrations/0081_create_customer_app_rpc.sql`
  - `catchmenu_store.place_takeout_order()` inserts into `catchmenu_pos.order_sessions`.
  - The `session_type` literal at L826 must change from `'ONLINE'` to `'TAKEOUT'`.
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
  - The second overload of `catchmenu_pos.create_order_session()` validates `p_session_type`.
  - Its validation array must change from allowing `'ONLINE'` to allowing `'TAKEOUT'`.
  - Four status/state mapping blocks must explicitly map `TAKEOUT -> ORDERING`, using `0025_create_session_rpc.sql` L71 as the reference value.
- The `0063` L202-206 `DELIVERY` branch omission is a separate defect and is not fixed here.
- The `0025` vs `0063` `WALK_IN` mapping mismatch is a separate defect and is not fixed here.

## 1. Verification Environment

All execution tests must run against local Supabase Docker DB only.

Requirements:

- Wrap data-mutating tests in `BEGIN; ... ROLLBACK;`.
- Do not leave test sessions, orders, ledger events, session events, point rows, coupon rows, payment rows, or KDS rows behind.
- Do not modify `0025`, `point_ledger`, coupon schema, `discount_pct`, `DELIVERY`, or `WALK_IN` logic during verification.
- After implementation, verify the live function bodies with `pg_get_functiondef()` before scenario execution.

Suggested live-body checks:

```sql
select pg_get_functiondef(
  'catchmenu_store.place_takeout_order'::regproc
);
```

The live body must contain the `order_sessions` insert with:

```sql
'TAKEOUT', 'ORDER_CONFIRMED'
```

and must no longer contain the old L826 insert pair:

```sql
'ONLINE', 'ORDER_CONFIRMED'
```

For `0063`, use the exact second overload signature when inspecting `pg_get_functiondef()`. The body must show:

- validation array includes `'TAKEOUT'`
- validation array does not include `'ONLINE'`
- four status/state mapping blocks include `when 'TAKEOUT' then 'ORDERING'`

## 2. Test A — `place_takeout_order()` Reaches Past `chk_session_type`

Purpose:

- Confirm the former `session_type = 'ONLINE'` path no longer violates `chk_session_type`.
- Confirm the function now reaches the next known execution point.

Execution shape:

```sql
begin;

select catchmenu_store.place_takeout_order(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_items := '<valid minimal menu item jsonb>'::jsonb,
  p_customer_id := null,
  p_phone_hash := null,
  p_locale := 'ko',
  p_memo := null,
  p_coupon_issue_id := null,
  p_use_points := 0,
  p_requested_pickup_at := null,
  p_correlation_id := 'verify-600613-place-takeout'
);

rollback;
```

Parameter names re-verified this turn against the live signature (`pg_get_function_arguments` on `catchmenu_store.place_takeout_order`, single overload confirmed — `select count(*) ... = 1`):

| Draft (previous) | Live (confirmed) | Note |
|---|---|---|
| `p_menu_items` | `p_items` | Wrong name in the draft — does not exist on the live function. |
| `p_guest_count` | *(no such parameter)* | Removed — `place_takeout_order()` has no `p_guest_count` parameter at all; `guest_count` is hardcoded to `1` inside the function body's `order_sessions` insert (L297 area), not caller-supplied. Passing `p_guest_count := 1` in named notation would raise "function ... does not have parameter". |
| `p_request_memo` | `p_memo` | Confirmed already renamed (matches `600710` workpacket's earlier `p_request_memo`→`p_memo` rename) — the previous draft's conditional note ("if already renamed, use `p_memo`") is now resolved: it has been renamed, so `p_memo` is used unconditionally. |
| *(not present in draft)* | `p_requested_pickup_at` | Newly discovered this turn — a real parameter (`timestamptz default null`) missing from the draft entirely. Has a default so omitting it would not break the call, but it is included explicitly above for completeness since the draft's coverage of the live signature was otherwise incomplete. |
| `p_tenant_id`/`p_store_id`/`p_customer_id`/`p_phone_hash`/`p_locale`/`p_coupon_issue_id`/`p_use_points`/`p_correlation_id` | (unchanged) | Confirmed correct as drafted. |

Expected result:

- No error from `chk_session_type` rejecting `'ONLINE'`.
- The function either succeeds or reaches the next known unrelated blocker, such as:
  - point ledger path,
  - coupon/`discount_pct` path,
  - another already-known downstream issue depending on the input combination.

PASS condition:

- The error `new row for relation "order_sessions" violates check constraint "chk_session_type"` caused by `session_type = 'ONLINE'` is gone.

FAIL condition:

- Any failure still indicates `session_type = 'ONLINE'` was inserted into `catchmenu_pos.order_sessions`.

## 3. Test B — `create_order_session()` Second Overload Accepts `TAKEOUT`

Purpose:

- Confirm the `0063` second overload accepts `p_session_type := 'TAKEOUT'`.
- Confirm its status/state outputs consistently use `ORDERING`.

The target function is the second overload from `0063_patch_core_rpc_i18n_diagnostics.sql`, identified by parameters including:

- `p_wait_number`
- `p_queue_position`
- `p_pre_order_expires_at`

Execution shape:

```sql
begin;

select catchmenu_pos.create_order_session(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_session_type := 'TAKEOUT',
  p_guest_count := 1,
  p_guest_locale := 'ko',
  p_wait_number := null,
  p_queue_position := null,
  p_pre_order_expires_at := null,
  p_correlation_id := 'verify-600613-create-takeout'
);

-- If the function returns a session id, inspect the rollback-scoped rows:
select id, session_type, session_status
from catchmenu_pos.order_sessions
where correlation_id = 'verify-600613-create-takeout';

select event_type, from_status, to_status
from catchmenu_pos.session_events
where correlation_id = 'verify-600613-create-takeout'
order by created_at desc;

select event_domain, event_type, from_state, to_state
from catchmenu_ledger.events
where correlation_id = 'verify-600613-create-takeout'
order by occurred_at desc;

rollback;
```

Expected result:

- Function call succeeds for `p_session_type := 'TAKEOUT'`.
- `catchmenu_pos.order_sessions.session_type = 'TAKEOUT'`.
- `catchmenu_pos.order_sessions.session_status = 'ORDERING'`.
- `catchmenu_pos.session_events.to_status = 'ORDERING'`.
- `catchmenu_ledger.events.to_state = 'ORDERING'` for the created session event.
- RPC return payload includes `session_status = 'ORDERING'`.

PASS condition:

- All four observable outputs are consistent with `TAKEOUT -> ORDERING`:
  1. `order_sessions.session_status`
  2. `session_events.to_status`
  3. `ledger.events.to_state`
  4. RPC return `data.session_status`

FAIL condition:

- `TAKEOUT` is rejected.
- Any of the four outputs falls through to `WAITING`.
- Any output uses `ONLINE`.

## 4. Test C — `create_order_session()` Rejects `ONLINE` At Function Validation

Purpose:

- Confirm the function's own validation now rejects `ONLINE`.
- Confirm rejection happens at the explicit `p_session_type not in (...)` validation before any table constraint is involved.

Execution shape:

```sql
begin;

select catchmenu_pos.create_order_session(
  p_tenant_id := '<test tenant uuid>'::uuid,
  p_store_id := '<test store uuid>'::uuid,
  p_session_type := 'ONLINE',
  p_guest_count := 1,
  p_guest_locale := 'ko',
  p_wait_number := null,
  p_queue_position := null,
  p_pre_order_expires_at := null,
  p_correlation_id := 'verify-600613-create-online-reject'
);

rollback;
```

Expected result:

- The function rejects `ONLINE`.
- The observed error or failure response must correspond to the function-level invalid `session_type` validation.
- The failure must not be a later `chk_session_type` table constraint error.

PASS condition:

- `ONLINE` is rejected by the explicit function validation at L44-47 equivalent.

FAIL condition:

- `ONLINE` is still accepted by function validation.
- The failure reaches table insert and only then fails by `chk_session_type`.

## 5. Out-Of-Scope Items To Record, Not Test As Fixes

The following are known findings but are not verification targets for this workpacket:

| Item | Reason |
|---|---|
| `0063` L202-206 missing `DELIVERY -> ORDER_CONFIRMED` branch | Separate existing mapping defect; not part of the approved six TAKEOUT/ONLINE corrections |
| `0025` maps `WALK_IN -> SEATED` while `0063` maps `WALK_IN -> ORDERING` | Separate overload alignment issue; changing it would alter WALK_IN semantics |
| `point_ledger` downstream behavior | Separate known downstream blocker candidate |
| `discount_pct` / coupon schema behavior | Separate known downstream blocker candidate |

If any of these appears during execution, record it as a known or newly observed out-of-scope issue. Do not treat it as failure of the TAKEOUT session-type correction unless it prevents confirming that the former `ONLINE` defect is gone.

## 6. Static Boundary Verification

Run read-only source checks after implementation:

```powershell
git diff -- sql/migrations/0081_create_customer_app_rpc.sql
git diff -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
git diff --check
```

Expected diff boundary:

- `0081`: exactly the `place_takeout_order()` L826 literal change from `'ONLINE'` to `'TAKEOUT'`.
- `0063`: exactly:
  - validation array `'ONLINE'` to `'TAKEOUT'`
  - `when 'TAKEOUT' then 'ORDERING'` added in four approved `case p_session_type` blocks.
- No `0025` changes.
- No `DELIVERY` branch addition.
- No `WALK_IN` mapping change.
- No point ledger or coupon schema change.

## 7. Acceptance Criteria

This TestPlan passes if:

1. `place_takeout_order()` no longer fails at `chk_session_type` because of `ONLINE`.
2. `create_order_session()` second overload accepts `TAKEOUT`.
3. The second overload maps `TAKEOUT` to `ORDERING` consistently across insert, session event, ledger event, and RPC response.
4. `ONLINE` is rejected by function-level validation.
5. Known `DELIVERY`, `WALK_IN`, point ledger, and `discount_pct` findings remain out of scope and are not silently fixed.
6. `git diff --check` passes.



===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600614_ChangeContract.md] =====
# 600614_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`takeout_session_type_fix`

## 0. Authority

This ChangeContract is based on:

- `600611_Overview.md`
- `600612_Logic.md`
- `600613_TestPlan.md`

The accepted design is not reopened here.

Confirmed six corrections:

1. `0081` L826: `session_type` literal changes from `'ONLINE'` to `'TAKEOUT'`.
2. `0063` L46: validation array changes from allowing `'ONLINE'` to allowing `'TAKEOUT'`.
3. `0063` L143-148: add `when 'TAKEOUT' then 'ORDERING'`.
4. `0063` L173-178: add `when 'TAKEOUT' then 'ORDERING'`.
5. `0063` L202-206: add `when 'TAKEOUT' then 'ORDERING'`; do not add `DELIVERY`.
6. `0063` L244-249: add `when 'TAKEOUT' then 'ORDERING'`.

Reference value:

- `0025_create_session_rpc.sql` maps `TAKEOUT -> ORDERING`.
- `0025_create_session_rpc.sql` is the reference only and must not be modified.

## 1. Allowed Files

Exactly two migration source files may be modified:

| File | Allowed scope |
|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` function body, L826 `order_sessions.session_type` literal only |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | `catchmenu_pos.create_order_session()` second overload body only, six specified TAKEOUT/ONLINE correction points |

## 2. Allowed Changes In `0081`

Allowed change:

```sql
-- Before
'ONLINE', 'ORDER_CONFIRMED',

-- After
'TAKEOUT', 'ORDER_CONFIRMED',
```

Rules:

- Change only the `session_type` literal in the `order_sessions` insert inside `place_takeout_order()`.
- Preserve `session_status = 'ORDER_CONFIRMED'`.
- Preserve the function signature.
- Preserve all customer, coupon, point, order, payment, KDS, ledger, notification, and response logic.

## 3. Allowed Changes In `0063`

Target function:

- `catchmenu_pos.create_order_session()` second overload from `0063_patch_core_rpc_i18n_diagnostics.sql`.
- This is the overload with parameters including `p_queue_position` and `p_pre_order_expires_at`.

### 3.1 Validation Array

Allowed change:

```sql
-- Before
'KIOSK', 'DELIVERY', 'ONLINE'

-- After
'KIOSK', 'DELIVERY', 'TAKEOUT'
```

Rules:

- Replace `ONLINE` with `TAKEOUT`.
- Preserve existing allowed values other than this one replacement.
- Do not add new session types.
- Do not remove `DELIVERY`.

### 3.2 Status/State Mapping Blocks

Allowed addition in each of the four approved blocks:

```sql
when 'TAKEOUT' then 'ORDERING'
```

Target blocks:

| Line range from design | Semantic target | Allowed change |
|---|---|---|
| L143-148 | `order_sessions.session_status` | Add `TAKEOUT -> ORDERING` |
| L173-178 | `session_events.to_status` | Add `TAKEOUT -> ORDERING` |
| L202-206 | `catchmenu_ledger.events.to_state` | Add `TAKEOUT -> ORDERING` only; do not add `DELIVERY` |
| L244-249 | RPC return `data.session_status` | Add `TAKEOUT -> ORDERING` |

Rules:

- Use the same mapping as `0025` L71: `TAKEOUT -> ORDERING`.
- Preserve `WALK_IN` mapping exactly as it currently exists in `0063`.
- Preserve `KIOSK` mapping exactly as it currently exists.
- Preserve `DELIVERY` mapping where it already exists.
- Do not add `DELIVERY` to L202-206 in this workpacket.
- Preserve `else 'WAITING'`.

## 4. Forbidden Files And Operations

The following are explicitly forbidden:

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0025_create_session_rpc.sql` | Reference baseline only; do not modify |
| Any `0063` overload other than the second `create_order_session()` overload | Out of scope |
| Any `0063` function other than `create_order_session()` | Out of scope |
| Adding `DELIVERY -> ORDER_CONFIRMED` to `0063` L202-206 | Known separate defect, not approved here |
| Changing `WALK_IN -> ORDERING` in `0063` | Known separate mismatch against `0025`, not approved here |
| Any `point_ledger` fix | Separate downstream blocker candidate |
| Any coupon or `discount_pct` fix | Separate downstream blocker candidate |
| Any Flutter/runtime code | Out of scope |
| Any schema/table/constraint rewrite unrelated to this literal correction | Out of scope |
| Any tools script | Out of scope |
| Any docs outside the current workpacket lifecycle unless explicitly requested later | Out of scope |

Implementation must not:

- Convert this into a broader session-state reconciliation.
- Normalize all `create_order_session()` overloads.
- Change `session_status = 'ORDER_CONFIRMED'` in `0081`.
- Change KDS/payment behavior.
- Change payload keys.
- Add compatibility aliases for `ONLINE`.

## 5. Required Behavior Preservation

The implementation must preserve:

- Existing function signatures for `place_takeout_order()` and `create_order_session()`.
- Existing return payload structure.
- Existing `ORDER_CONFIRMED` status for the `place_takeout_order()` session insert.
- Existing `0063` behavior for `WALK_IN`, `WAITING`, `PRE_ORDER`, `KIOSK`, and `DELIVERY`, except where `TAKEOUT` is explicitly added.
- Existing validation error behavior for unsupported session types.
- Existing downstream point/coupon/payment/KDS behavior.

## 6. Required New Behavior

After implementation:

- `place_takeout_order()` must insert `session_type = 'TAKEOUT'` instead of `ONLINE`.
- The second `0063` `create_order_session()` overload must allow `p_session_type = 'TAKEOUT'`.
- That overload must map `TAKEOUT` to `ORDERING` consistently in:
  - `order_sessions.session_status`
  - `session_events.to_status`
  - `catchmenu_ledger.events.to_state`
  - RPC response `data.session_status`
- That overload must reject `p_session_type = 'ONLINE'` through its own validation logic.

## 7. Verification Requirements

Implementation must be verified against `600613_TestPlan.md`.

Required verification groups:

1. `place_takeout_order()` reaches past the former `chk_session_type` failure.
2. `create_order_session()` second overload accepts `TAKEOUT`.
3. `TAKEOUT` maps to `ORDERING` in all four approved outputs.
4. `ONLINE` is rejected by function-level validation.
5. Out-of-scope `DELIVERY` and `WALK_IN` issues remain untouched.
6. Static diff boundary confirms only the approved six correction points changed.
7. `git diff --check` passes.

## 8. Open Items Not Approved In This Contract

### 8.1 `0063` L202-206 Missing `DELIVERY` Branch

The ledger-event `to_state` mapping block at `0063` L202-206 does not include `DELIVERY -> ORDER_CONFIRMED`, unlike other `0063` status mapping blocks.

This is a separate follow-up workpacket candidate.

This ChangeContract does not approve:

- adding `DELIVERY` to L202-206,
- changing delivery behavior,
- broadening the status mapping fix beyond TAKEOUT.

### 8.2 `WALK_IN` Mapping Mismatch Between `0025` And `0063`

`0025_create_session_rpc.sql` maps `WALK_IN -> SEATED`, while `0063_patch_core_rpc_i18n_diagnostics.sql` maps `WALK_IN -> ORDERING`.

This is a separate overload-alignment candidate.

This ChangeContract does not approve:

- changing `0063` `WALK_IN` mapping,
- changing `0025`,
- redefining seated/order lifecycle semantics.

### 8.3 Downstream Point/Coupon Defects

Known downstream point ledger and `discount_pct`/coupon findings remain outside this contract.

This ChangeContract does not approve:

- point ledger fixes,
- coupon schema changes,
- `discount_pct` changes,
- coupon discount policy rewrites.

## 9. Risk

Risk level: HIGH.

Reasons:

- `place_takeout_order()` is a customer-facing order RPC.
- `create_order_session()` affects POS session creation and audit/event evidence.
- The target files are already-applied migration files, so later implementation will likely require checksum and live replay discipline.
- Several adjacent defects are known but intentionally excluded, increasing the risk of accidental scope creep.

Risk controls:

- Six explicit correction points only.
- Two-file boundary.
- No signature changes.
- No schema changes.
- Explicit out-of-scope list for `DELIVERY`, `WALK_IN`, point ledger, and coupon defects.
- Rollback-wrapped verification.

## 10. Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve modifying sql/migrations/0081_create_customer_app_rpc.sql only within catchmenu_store.place_takeout_order() L826.
☑ I approve modifying sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql only within the second catchmenu_pos.create_order_session() overload at the six specified correction points.
☑ I acknowledge that DELIVERY, WALK_IN, point ledger, and discount_pct findings remain out of scope for this workpacket.

## 11. Stage 4 Instruction If Approved

If all three Human approval boxes in §10 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.



===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600615_Module.md] =====
# 600615_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-13

## Summary

Implemented the approved `takeout_session_type_fix` change (`600614_ChangeContract.md`): unified `'TAKEOUT'` handling across two files/two functions that previously used or accepted the non-existent `chk_session_type` value `'ONLINE'`.

| File | Function | Change | Result |
|---|---|---|---|
| `sql/migrations/0081_create_customer_app_rpc.sql` | `catchmenu_store.place_takeout_order()` | `order_sessions` INSERT `session_type` literal: `'ONLINE'` → `'TAKEOUT'` (L826/live L303) | Applied, live-verified. |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | `catchmenu_pos.create_order_session()` (2nd overload, `p_queue_position`/`p_pre_order_expires_at` signature) | (a) validation array `'ONLINE'` → `'TAKEOUT'` (L46/live L18); (b) 4x `case p_session_type` blocks gain `when 'TAKEOUT' then 'ORDERING'` (L143-148/L173-178/L202-206/L244-249, live L118/149/179/222) | Applied, live-verified. |

Total: **6 diff points**, matching `600612_Logic.md` §1/§2/§2.1 exactly.

## `0081` Temporary DROP → Restore

`0081` contains a pre-existing pattern (not introduced by this workpacket) where `place_takeout_order()` is dropped and recreated in the same file:

```sql
drop function if exists catchmenu_store.place_takeout_order(
  uuid, uuid, jsonb, uuid, text, text, text, uuid, integer, timestamptz, text
);

create or replace function
  catchmenu_store.place_takeout_order( ... )
```

Verified this turn:
- The `drop function if exists` signature (11 params, types in order) matches the current `create or replace function` signature exactly — no stale/orphaned overload left behind after the drop-recreate cycle (`select count(*) ... = 1` confirms a single live overload).
- `EXECUTE` grants for `authenticated`/`postgres` are present live after the drop-recreate. No explicit `grant execute` statement exists inside `place_takeout_order()`'s own block — the grant is inherited from schema-level default privileges, not lost and re-added per function. No permission regression from the DROP/CREATE cycle.

## Boundary Notes

- Only the two approved files/functions were touched — `0025_create_session_rpc.sql` (the correct first overload) was not modified, matching `600614_ChangeContract.md` §4.
- `0063`'s L202-206 `DELIVERY` branch omission and the `0025`/`0063` `WALK_IN` mapping mismatch were confirmed still present, unmodified — explicitly out of scope per `600612_Logic.md` §2.1 and `600614_ChangeContract.md` §8.1/§8.2.
- `600710`'s 11-point scalar-variable conversion inside `place_takeout_order()` (`v_customer_id`/`v_customer_display_name`/`v_customer_membership_tier`/`v_customer_point_balance`/`v_coupon_id`/`v_coupon_discount_type`/`v_coupon_discount_value`/`v_coupon_discount_pct`/`v_coupon_min_order_amount`/`v_coupon_max_discount_amount`) confirmed intact — zero live `v_customer.`/`v_coupon.` dot-field-access remains inside `place_takeout_order()`'s function boundary (2 pre-existing comment-only mentions excluded, unchanged from `600716_Verification.md`).
- Checksum bookkeeping correct for both files — current file SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly, `success = true`, no drift.
- No cloud database was touched. No git commit was performed.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600616_Verification.md] =====
# 600616_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude + Cursor (§39/§40 dual verification, Antigravity parallel reference-only per §40.1 "3중 검토")
Date: 2026-07-13

## Verification Result

Final result: PASS for the approved scope (6-point `'ONLINE'`→`'TAKEOUT'` unification, both files). One **separate, newly-discovered, out-of-scope** defect (`requested_pickup_at`) confirmed to block full end-to-end success on the very path this fix was meant to unblock — not a regression from this fix.

## 1. Claude Code Stage 5 — Independent Re-Verification

Nothing below was assumed from Codex's implementation report; each item was independently re-derived against the local Supabase Docker container.

| Check | Result |
|---|---|
| 6-point diff, live vs. source (`pg_get_functiondef`) | PASS — all 6 points present live: `0081` L303 (`'TAKEOUT', 'ORDER_CONFIRMED'`); `0063` L18 (validation array), L118/149/179/222 (4x `when 'TAKEOUT' then 'ORDERING'`). |
| Residual `'ONLINE'` literal count, both live function bodies | PASS — 0 in each. |
| Checksum integrity, both files | PASS — SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly for `0081` and `0063`, `success = true`, no drift. |
| Boundary — only the two approved functions/locations changed | PASS — `0025` unmodified; `0063`'s `DELIVERY`-branch omission and `WALK_IN` mismatch confirmed still present, untouched. |
| `600710` 11-point scalar-variable preservation inside `place_takeout_order()` | PASS — 0 live `v_customer.`/`v_coupon.` dot-access remains inside the function's actual boundary (L504-1026); `v_customer record` found at two OTHER, unrelated functions (`bootstrap_customer_app()` L207-503, `get_customer_home()` L1197-1390) — confirmed out of `600710`'s and this workpacket's scope, not contamination. |
| `0081` DROP→CREATE signature match | PASS — `drop function if exists` signature (11 params) matches the `create or replace` signature exactly; single live overload confirmed (`count(*) = 1`). |
| `EXECUTE` grant survival after DROP→CREATE | PASS — `authenticated`/`postgres` EXECUTE confirmed live via schema default privileges. |
| **Test B** — `create_order_session()` 2nd overload accepts `'TAKEOUT'`, independently re-run (`correlation_id = verify-600615-testB-rerun`) | PASS — `order_sessions.session_status`, `session_events.to_status`, `ledger.events.to_state`, and RPC return `data.session_status` **all four** consistently `'ORDERING'`. |
| **Test C** — `create_order_session()` rejects `'ONLINE'` at function-level validation, independently re-run (`correlation_id = verify-600615-testC-rerun`) | PASS — rejected with `error_key: invalid_input` at the explicit `p_session_type not in (...)` check; not a `chk_session_type` table-constraint error. |
| **Test A** — `place_takeout_order()` reaches past `chk_session_type`, independently re-run (`correlation_id = verify-600615-testA-rerun`) | PASS on the approved PASS condition (no `chk_session_type`/`'ONLINE'` error) — execution reaches the `catchmenu_pos.orders` INSERT that follows the now-fixed session INSERT. **New finding**: that INSERT fails with `column "requested_pickup_at" of relation "orders" does not exist` (§2 below). |

## 2. New Defect Confirmed — `requested_pickup_at` (Urgent, Out Of Scope For This Workpacket)

Not a regression from this fix — an independently pre-existing, previously undiscovered defect, surfaced only now because this fix lets execution reach the code region where it lives (`catchmenu_pos.orders` INSERT, immediately after the session INSERT this workpacket fixed).

- **Exact live columns of `catchmenu_pos.orders`** (`information_schema.columns`, live, full 28-column list captured): no column named `requested_pickup_at`, and no column containing the substring `pickup` anywhere in the entire live schema (cross-schema search, 0 hits).
- **Not a rename/stale-column drift** (different category from `point_type`/`point_amount` or `case_severity`): those had a correctly-named real column under a different name. `requested_pickup_at` has **no equivalent under any name** — confirmed by the zero-hit `pickup` search across all tables. The identifier appears in exactly two places repo-wide: `0081`'s `place_takeout_order()` itself (parameter `p_requested_pickup_at` + the broken INSERT), and `0092` (Flutter client example text, non-executing documentation). Diagnosis: an unmigrated column — the RPC-level parameter and INSERT reference were written for a "customer-requested pickup time" feature, but the corresponding `ALTER TABLE catchmenu_pos.orders ADD COLUMN requested_pickup_at ...` migration was never authored.
- **Blast radius — broader than any single prior defect**: the failing INSERT is unconditional (not gated by any `if`), executing immediately after every successful session creation regardless of coupon/points branch. It therefore blocks **100% of call paths** that get past the session INSERT, unlike `point_ledger`/`discount_pct`, which are each specific to one input branch.
- **Reproduction**: `begin; select catchmenu_store.place_takeout_order(...); rollback;` — hard error, uncaught, transaction-aborting (`ERROR: column "requested_pickup_at" of relation "orders" does not exist`, followed by `current transaction is aborted, commands ignored until end of transaction block`). Same failure class (hard error, not silent undercount) as `chk_session_type`/`discount_pct`/`point_ledger`.

See `600404_PlaceTakeoutOrder_Defect_Roadmap.md` for this defect's position relative to the other three known blockers of `place_takeout_order()`.

## 3. Cursor Independent Verification (§39/§40)

Per `000701` §40.1 standard "3중 검토" procedure, the same verification scope (6-point diff, Test A/B/C, `600710` 11-point preservation check) was dispatched to Cursor (official, binding) in parallel; Antigravity received the same dispatch as reference-only, non-binding. As with prior workpackets in this series (`600446_Verification.md`, `600716_Verification.md`), this document does not have direct access to Cursor's or Antigravity's raw output — only confirmation that the same scope was dispatched under the standard procedure.

## Scenario Summary

| Scenario | Result |
|---|---|
| 6-point diff, live = source | PASS |
| Residual `'ONLINE'` | PASS — 0 |
| Checksum integrity (both files) | PASS |
| Boundary (only approved 2 functions/locations) | PASS |
| `600710` 11-point scalar preservation | PASS |
| DROP→CREATE signature/grant integrity | PASS |
| Test B (`TAKEOUT` accepted, 4-output consistency) | PASS |
| Test C (`ONLINE` rejected at function level) | PASS |
| Test A (`chk_session_type`/`ONLINE` error gone) | PASS |
| `place_takeout_order()` end-to-end completion | Fails — new, out-of-scope `requested_pickup_at` defect |


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600610_takeout_session_type_fix/600617_Audit.md] =====
# 600617_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-13

## Final Audit Decision

**ACCEPT (scoped to the approved `600614_ChangeContract.md` boundary — the 6-point `'ONLINE'`→`'TAKEOUT'` unification only).** `place_takeout_order()` still cannot complete a full end-to-end order today, but for reasons entirely outside this workpacket's approved scope. This is the same scoped-ACCEPT pattern as `600417_Audit.md`/`600917_Audit.md`/`600447_Audit.md`/`600717_Audit.md` in this same series.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside the approved `600614_ChangeContract.md` boundary | PASS | `600615_Module.md` — only `place_takeout_order()` (`0081`, 1 point) and `create_order_session()`'s 2nd overload (`0063`, 5 points) changed; `0025` untouched. |
| All 6 confirmed diff points converted | PASS | `600616_Verification.md` §1 — live `pg_get_functiondef()` shows all 6, 0 residual `'ONLINE'`. |
| Live functions match source | PASS | Checksum (SHA-256, CRLF-normalized) matches `catchmenu_meta.migration_history` exactly for both files, `success = true`. |
| `600710`'s 11-point scalar-variable conversion preserved | PASS | `600616_Verification.md` §1 — 0 live `v_customer.`/`v_coupon.` dot-access inside `place_takeout_order()`'s boundary; unrelated `v_customer record` in two other functions confirmed out of scope, not contamination. |
| `0081` DROP→CREATE cycle did not damage signature or permissions | PASS | `600615_Module.md` — DROP signature matches CREATE signature exactly (single live overload); `EXECUTE` grants intact via schema default privileges. |
| Test B — `TAKEOUT` accepted, 4-output consistency (`order_sessions`/`session_events`/`ledger.events`/RPC response) | PASS | `600616_Verification.md` §1, independently re-run with fresh `correlation_id`. |
| Test C — `ONLINE` rejected at function-level validation, not table constraint | PASS | `600616_Verification.md` §1, independently re-run. |
| Test A — `chk_session_type`/`'ONLINE'` error eliminated | PASS | `600616_Verification.md` §1, independently re-run. Execution now reaches the next code region (`orders` INSERT). |
| Out-of-scope items (`DELIVERY` branch, `WALK_IN` mismatch) left untouched | PASS | `600616_Verification.md` §1 boundary check — both confirmed still present, unmodified. |
| Dual independent verification (§39/§40) | PASS (Claude Code) / dispatched per standard "3중 검토" procedure (Cursor official, Antigravity reference-only) | `600616_Verification.md` §3. |

## Findings

1. The 6-point `'ONLINE'`→`'TAKEOUT'` unification fully closes the defect this workpacket targeted — `place_takeout_order()` no longer fails at `chk_session_type`, and `create_order_session()`'s 2nd overload now both accepts `'TAKEOUT'` and rejects `'ONLINE'` at the correct validation layer, with consistent `'ORDERING'` status mapping across all 4 observable outputs.
2. A new, separate, pre-existing defect was confirmed this turn: `catchmenu_pos.orders` has no `requested_pickup_at` column (and no equivalent under any other name — confirmed via a zero-hit `pickup`-substring search across the entire live schema). This blocks the `orders` INSERT that immediately follows the now-fixed session INSERT, for **every** call path that reaches that point — a broader blast radius than any of the three previously-known blockers (`point_ledger`, `discount_pct` are each branch-specific).
3. This new defect is not a rename/stale-column drift like `point_type`/`point_amount` — it is an unmigrated column: the RPC parameter (`p_requested_pickup_at`) and its INSERT reference exist in code, but no migration ever added the corresponding table column.
4. `place_takeout_order()` still does not complete end-to-end for any input combination today — the simplest path (guest, no coupon, no points) now travels furthest (past `chk_session_type`, previously the first blocker) before stopping at `requested_pickup_at`; the points and coupon paths remain blocked earlier, at `point_ledger`/`discount_pct` respectively, unaffected by this workpacket.
5. See `600404_PlaceTakeoutOrder_Defect_Roadmap.md` (new, cross-workpacket reference) for the full 4-defect map of `place_takeout_order()`, ordered by how far the function's execution actually reaches for each input combination.

## Open Items Carried Forward

(a) **`0063` L202-206 — `DELIVERY` branch missing from the ledger-event `case p_session_type` block.** Newly discovered in `600612_Logic.md` §2.1 while implementing this workpacket's `TAKEOUT` addition. Unrelated to `TAKEOUT`; explicitly out of scope per `600614_ChangeContract.md` §8.1. `create_order_session()` still has zero live callers, so this remains low-urgency.

(b) **`0025` vs `0063` `WALK_IN` mapping mismatch** (`0025`: `'SEATED'`; `0063`: `'ORDERING'`). Newly discovered in `600612_Logic.md` §2.1. The two overloads are not fully aligned even after this workpacket's `TAKEOUT` fix. Out of scope per `600614_ChangeContract.md` §8.2 — fixing it would change existing `WALK_IN` semantics, which was not approved here.

(c) **`requested_pickup_at` missing column on `catchmenu_pos.orders`.** Newly discovered this turn (§2.2 of `600616_Verification.md`, Finding 2/3 above). Blocks the `orders` INSERT unconditionally for every path that reaches it — currently the single blocker for the simplest (guest, no-coupon, no-points) path. Recommended as the **next** fix — see `600404_PlaceTakeoutOrder_Defect_Roadmap.md` for priority ordering versus (d)/(e).

(d) **`point_ledger` stale columns** (`point_type`/`point_amount` → actual `transaction_type`/`points_change`; `'USE'` → actual `'DEDUCT'`) — carried forward from `600717_Audit.md` Open Item (b), unaffected by this workpacket.

(e) **`discount_pct` / `'AMOUNT'`/`'PCT'` literal mismatch** — carried forward from `600717_Audit.md` Open Item (c), unaffected by this workpacket.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- This audit does not authorize a follow-up workpacket for (a)-(e) — it records findings and priority ordering only, per `600404_PlaceTakeoutOrder_Defect_Roadmap.md`, as prep for the next session's Human Approval decision.
- No cloud database was touched. No git commit was performed.

## Conclusion

The `takeout_session_type_fix` implementation satisfies its `600614_ChangeContract.md` boundary exactly, closes the `'ONLINE'`/`chk_session_type` defect across both affected functions, and leaves all explicitly out-of-scope items (`DELIVERY` branch, `WALK_IN` mismatch, `point_ledger`, `discount_pct`) untouched as required. `place_takeout_order()` remains non-functional end-to-end today, but for reasons — now four, one newly discovered this turn — entirely outside this workpacket's scope, not because of anything this fix did or failed to do.

Final status: **ACCEPT (scoped).**


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600621_Overview.md] =====
# 600621_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role) — Track 1 (Contract Inventory)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## §0 배경 (ChatGPT 2차 분석 채택, Human 승인)

`BOUNDED_PARTIAL_REDESIGN_REQUIRED`로 분류 확정. 3개 경계 중 **Payment Confirmation Boundary는 `600510_confirm_payment_from_provider_overload_ambiguity`에서 이미 상세 조사 완료**(payment_ledger 7건 전수 대조, `confirm_payment_from_provider()` 오버로드 모호성, `0027` 정확성 확인 등)했으므로 이번 workpacket에서 제외한다. 이번 워크패킷은 나머지 두 경계만 다룬다:

- **B. Waiting / Order Session Boundary**
- **C. KDS Ticket Boundary**

## Track 0 — 동결 확인

이 문서 작성 기간 중 다음을 수행하지 않았다: 신규 컬럼 추가, 동일이름 함수 오버로드 추가, 상태모델 변경, 범위 밖 리팩토링. 이번 턴에 수행한 작업은 조사(라이브 DB 직접 조회)와 문서 작성뿐이며, `.sql` 파일은 생성·수정하지 않았다.

## §1 Contract Inventory — 테이블 (라이브 DB 직접 추출)

### `catchmenu_pos.order_sessions`

**Columns** (34개, 전수):

| Column | Type | Nullable | Default |
|---|---|---|---|
| id | uuid | NO | gen_random_uuid() |
| tenant_id | uuid | NO | |
| store_id | uuid | NO | |
| session_type | text | NO | |
| session_status | text | NO | 'WAITING' |
| table_id | uuid | YES | |
| order_id | uuid | YES | |
| guest_count | integer | YES | |
| guest_locale | text | NO | 'ko' |
| customer_token | text | YES | |
| wait_number | integer | YES | |
| queue_position | integer | YES | |
| session_started_at | timestamptz | NO | now() |
| arrived_at | timestamptz | YES | |
| seated_at | timestamptz | YES | |
| ordering_started_at | timestamptz | YES | |
| order_confirmed_at | timestamptz | YES | |
| payment_started_at | timestamptz | YES | |
| payment_completed_at | timestamptz | YES | |
| completed_at | timestamptz | YES | |
| cancelled_at | timestamptz | YES | |
| expires_at | timestamptz | YES | |
| pre_order_created_at | timestamptz | YES | |
| pre_order_expires_at | timestamptz | YES | |
| arrival_reliability_score | integer | YES | |
| gateway_session_id | uuid | YES | |
| toss_order_id | text | YES | |
| correlation_id | text | YES | |
| idempotency_key | text | YES | |
| business_day | date | NO | |
| business_timezone | text | NO | 'Asia/Seoul' |
| created_at | timestamptz | NO | now() |
| updated_at | timestamptz | NO | now() |
| customer_id | uuid | YES | |
| phone_hash | text | YES | |

**Constraints**: PK `order_sessions_pkey(id)`. FK → `catchmenu_store.customers(id)` ON DELETE SET NULL, `catchmenu_gateway.gateway_sessions(id)`, `catchmenu_store.dining_tables(id)`, `catchmenu_hq.tenants(id)`, `catchmenu_hq.stores(id)`. UNIQUE `(toss_order_id)`. CHECK: `chk_session_type`(`WALK_IN`/`WAITING`/`PRE_ORDER`/`KIOSK`/`TAKEOUT`/`DELIVERY`), `chk_session_status`(`WAITING`/`ARRIVAL_PENDING`/`SEATED`/`ORDERING`/`ORDER_CONFIRMED`/`PAYMENT_PENDING`/`PAYMENT_UNCERTAIN`/`COMPLETED`/`CANCELLED`/`EXPIRED`/`NO_SHOW`), `chk_session_guest_count`, `chk_session_arrival_reliability`(0-100), `chk_session_seated_after_arrived`, `chk_session_order_after_seated`, `chk_session_payment_after_order`.

**Trigger**: `trg_order_sessions_updated_at` — `BEFORE UPDATE`, calls `catchmenu_common.set_updated_at()`.

**주의 — 이번 워크패킷의 핵심**: 이 34개 컬럼 목록에 `pre_order_amount`/`table_number`/`called_at`/`call_count`/`arrival_confirmed_at`/`cancel_reason`/`no_show_at`/`memo`는 **없다**. `600622_Logic.md`의 드리프트 표 참고.

### `catchmenu_pos.orders`

**Columns** (32개): `id`/`tenant_id`/`store_id`/`session_id`/`table_id`/`order_number`/`order_type`/`order_status`/`total_amount`/`discount_amount`/`final_amount`/`order_channel`/`pos_order_number`/`delivery_order_id`/`guest_count`/`guest_locale`/`memo`/`special_requests`/`kitchen_zone_summary`/`ordered_at`/`confirmed_at`/`cancelled_at`/`completed_at`/`gateway_session_id`/`idempotency_key`/`correlation_id`/`business_day`/`business_timezone`/`created_at`/`updated_at`/`requested_pickup_at`(`600720`에서 추가)/`ready_at`(`600720`에서 추가).

**Constraints**: PK `orders_pkey(id)`. FK → `catchmenu_store.dining_tables`, `catchmenu_gateway.gateway_sessions`, `catchmenu_pos.order_sessions`, `catchmenu_hq.tenants`, `catchmenu_hq.stores`. UNIQUE `(store_id, order_number)`. CHECK: `chk_order_amounts`, `chk_order_channel`, `chk_order_status`(`PENDING`/`CONFIRMED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` — **`'PAID'` 없음**, `600510` 조사에서 이미 확인), `chk_order_type`(`DINE_IN`/`TAKEOUT`/`DELIVERY`/`KIOSK`/`STAFF_ORDER`).

**Trigger**: `trg_orders_updated_at`.

`order_source`/`paid_at`는 이 32개 컬럼에 **없다**. `paid_at`은 이번 턴 재검색 결과 `0098`/`0076`/`0082`/`0105`/`0109`/`0114`/`0116`/`0133` 등 전부 Payment/청구/키오스크 도메인 파일에서만 등장 — `600510`의 Payment Confirmation Boundary 소관으로 확인, 이번 B/C 범위에는 포함하지 않는다.

### `catchmenu_pos.order_items`

**Columns** (28개): `id`/`tenant_id`/`store_id`/`order_id`/`menu_id`/`menu_code_snapshot`/`menu_name_snapshot`/`unit_price_snapshot`/`quantity`/`item_amount`/`selected_options`/`options_amount`/`kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot`/`item_status`/`allergen_displayed`/`allergen_locale_displayed`/`allergen_version_displayed`/`allergen_confirmed_by_customer`/`memo`/`created_at`/`updated_at`/`base_price`/`option_price_delta`/`final_price`/`customization_log`/`customization_allergen_final`/`has_customization`.

**Constraints**: PK `order_items_pkey(id)`. FK → `catchmenu_hq.tenants`, `catchmenu_pos.menus`, `catchmenu_pos.orders`, `catchmenu_hq.stores`. CHECK: `chk_order_item_price`(`unit_price_snapshot >= 0`), `chk_order_item_quantity`(`quantity > 0`), `chk_order_item_amount`(`item_amount = unit_price_snapshot * quantity + options_amount`), `chk_order_item_status`, `chk_selected_options_array`.

**Trigger**: `trg_order_items_updated_at`.

`unit_price`/`subtotal`/`is_kds_required`/`display_order`는 이 28개 컬럼에 **없다** — `600720`/`600727_Audit.md`에서 이미 확인된 별개 결함(이번 B/C 범위와 무관, Payment도 아닌 세 번째 영역이나 이미 조사 완료).

### `catchmenu_kds.kds_tickets`

**Columns** (41개): `id`/`tenant_id`/`store_id`/`order_id`/`order_item_id`/`session_id`/`payment_ledger_id`/`ticket_number`/`kds_status`/`hold_reason`/`kitchen_zone`/`target_device_id`/`priority`/`menu_name_snapshot`/`quantity_snapshot`/`estimated_minutes_snapshot`/`prep_complexity_snapshot`/`conditions_met`/`kds_queue_length_at_check`/`kitchen_load_at_check`/`capacity_check_at`/`ticket_created_at`/`first_hold_at`/`capacity_checking_started_at`/`committed_at`/`cooking_started_at`/`ready_at`/`served_at`/`completed_at`/`cancelled_at`/`manual_fallback_activated`/`manual_fallback_reason`/`manual_fallback_at`/`manual_fallback_by`/`correlation_id`/`idempotency_key`/`business_day`/`business_timezone`/`created_at`/`updated_at`/`customization_display`/`has_customization`.

**주의**: `ticket_number`는 **실존 컬럼**(`text`, `NOT NULL`)이다 — `menu_id`는 없다(`order_items.menu_id`를 통해서만 메뉴와 연결됨, `kds_tickets`는 `order_item_id` FK로 간접 참조). 이 스키마 사실은 이번 재확인에서도 그대로 유지됨 — 정정된 것은 이 사실 자체가 아니라 "어느 함수가 이 두 컬럼을 어떻게 잘못 쓰는가"였다. 정확한 위치와 결함 유형(phantom-column vs NOT NULL 누락)은 `600622_Logic.md` §1.2 참고.

**Constraints**: PK. FK → `catchmenu_pos.order_items`, `catchmenu_pos.orders`, `catchmenu_payment.payment_ledger`, `catchmenu_store.device_registry`, `catchmenu_hq.tenants`, `catchmenu_pos.order_sessions`, `catchmenu_hq.stores`. UNIQUE `(store_id, ticket_number)`. CHECK: `chk_kds_status`(`HOLD`/`CAPACITY_CHECKING`/`COMMITTED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`MANUAL_FALLBACK`), `chk_kds_priority`(1-10), `chk_kds_quantity`, `chk_kds_conditions_object`, `chk_kds_committed_after_created`, `chk_kds_cooking_after_committed`, `chk_kds_ready_after_cooking`.

**Trigger**: `trg_kds_tickets_updated_at`.

### `catchmenu_store.did_display_queue` (참고용 — 오늘 스윕에서 in-scope 함수가 사용하지 않는 것으로 확인됨)

**Columns** (25개): `id`/`tenant_id`/`store_id`/`did_device_id`/`did_zone`/`queue_type`/`priority`/`order_id`/`session_id`/`order_number`/`wait_number`/`display_number`/`display_message`/`display_locale`/`call_count`/`max_call_count`/`last_called_at`/`next_call_at`/`queue_status`/`displayed_at`/`dismissed_at`/`dismissed_by_type`/`auto_dismiss_at`/`business_day`/`created_at`/`updated_at`.

**Constraints**: PK. FK → `did_devices`, `stores`, `tenants`. CHECK: `chk_queue_status`, `chk_queue_type`(`WAITING_CALL`/`PICKUP_READY`/`TABLE_READY`/`DELIVERY_READY`/`CUSTOM_MESSAGE`). **Trigger**: `trg_did_queue_updated`.

**재확인**: `0043`/`0099`/`0115`의 15개 in-scope 함수 본문을 재검색한 결과 이 테이블을 직접 참조하는 곳이 없음을 확인(참고용으로만 포함, 이번 드리프트 조사 대상 아님).

### `catchmenu_store.did_devices` (참고용, 동일)

**Columns** (22개): `id`/`tenant_id`/`store_id`/`device_id`/`did_code`/`did_name`/`zone`/`location_description`/`display_mode`/`orientation`/`resolution`/`refresh_interval_seconds`/`call_sound_enabled`/`call_repeat_count`/`call_interval_seconds`/`call_display_seconds`/`is_online`/`last_ping_at`/`current_content_id`/`brightness`/`is_active`/`created_at`/`updated_at`.

**Constraints**: PK. FK → `device_registry`, `stores`, `tenants`. UNIQUE `(store_id, did_code)`. CHECK: `chk_display_mode`, `chk_orientation`, `chk_did_zone`. **Trigger**: `trg_did_devices_updated`.

### `catchmenu_ledger.events` (이미 컬럼 100% 일치 확인됨 — 재확인)

**Columns** (28개, 이번 턴 재추출): `id`/`tenant_id`/`store_id`/`event_domain`/`event_type`/`event_version`/`subject_type`/`subject_id`/`from_state`/`to_state`/`caused_by_type`/`caused_by_id`/`caused_by_device_id`/`caused_by_agent_id`/`caused_by_task_id`/`event_payload`/`idempotency_key`/`is_replay`/`original_event_id`/`session_id`/`order_id`/`payment_id`/`kds_ticket_id`/`correlation_id`/`provider_event_id`/`business_day`/`business_timezone`/`occurred_at`/`recorded_at`.

**Constraints**: PK. FK → `stores`/`tenants`/`agent_registry`/`device_registry`/`tasks`/자기참조(`original_event_id`). CHECK: `chk_event_domain`(`session`/`order`/`payment`/`kds`/`delivery`/`inventory`/`staff`/`device`/`agent`/`recovery`/`knowledge`/`gateway`/`system`/`waiting` — `'store'` 없음, `600727_Audit.md`에서 이미 확인), `chk_event_payload_object`, `chk_event_replay_has_original`, `chk_event_type_not_blank`, `chk_event_caused_by_type`. **Trigger 없음**(append-only 설계 의도와 일치).

**재확인 결과**: 사용자님이 언급한 "이미 컬럼 100% 일치 확인됨"이 이번 턴 재추출로 그대로 재확인됨 — 새로운 불일치 없음.

## §2 Contract Inventory — 함수 (15개, 라이브 DB 직접 추출)

| 함수 | Schema | Identity Arguments | 주요 Default | Return | Source Migration |
|---|---|---|---|---|---|
| `register_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_guest_count, p_session_type, p_guest_locale, p_phone_hash, p_customer_id, p_memo, p_source, p_locale, p_correlation_id` | `p_session_type='WAITING'`, `p_source='STAFF'`, `p_locale='ko'` | jsonb | `0115` |
| `call_waiting_customer` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_table_number, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `confirm_arrival` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `pre_order_while_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_cart_items, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `seat_waiting_customer` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_table_number, p_actor_id, p_locale, p_correlation_id` | `p_locale='ko'` | jsonb | `0115` |
| `cancel_waiting` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_cancel_reason, p_actor_type, p_actor_id, p_locale, p_correlation_id` | `p_actor_type='CUSTOMER'`, `p_locale='ko'` | jsonb | `0115` |
| `mark_no_show` | `catchmenu_pos` | **2개 오버로드** — (a) `..., p_actor_type, p_actor_id, p_correlation_id` (b) `..., p_actor_id, p_locale, p_correlation_id` | (a) `p_actor_type='STAFF'` (b) `p_locale='ko'` | jsonb | (a) `0050` (b) `0115` — §2.1 참고 |
| `get_waiting_status` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_session_id, p_locale` | `p_locale='ko'` | jsonb | `0115` |
| `get_waiting_admin_view` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0115` |
| `get_did_display_state` | `catchmenu_store` | **2개 오버로드** — (a) `p_tenant_id, p_store_id, p_did_id, p_locale` (b) `p_tenant_id, p_store_id, p_device_id` | (a) `p_locale='ko'` (b) `p_device_id default null` | jsonb | (a) `0043` (b) `0117` — §2.1 참고 |
| `notify_customer_ready` | `catchmenu_store` | `p_tenant_id, p_store_id, p_order_id, p_notification_type, p_display_message, p_sound_alert, p_actor_type, p_actor_id, p_correlation_id` | `p_notification_type='ORDER_READY'`, `p_sound_alert=true`, `p_actor_type='SYSTEM'` | jsonb | `0043` |
| `update_did_display` | `catchmenu_store` | `p_tenant_id, p_store_id, p_device_id, p_display_mode, p_display_content, p_actor_type, p_actor_id, p_correlation_id` | `p_display_content='{}'`, `p_actor_type='STAFF'` | jsonb | `0043` |
| `get_kds_realtime_state` | `catchmenu_kds` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0099` |
| `get_staff_alert_feed` | `catchmenu_common` | `p_tenant_id, p_store_id, p_since, p_limit, p_locale` | `p_limit=20`, `p_locale='ko'` | jsonb | `0099` |
| `get_waiting_realtime_state` | `catchmenu_pos` | `p_tenant_id, p_store_id, p_locale` | `p_locale='ko'` | jsonb | `0099` |

### §2.1 부수 발견 — `mark_no_show()`/`get_did_display_state()` 오버로드 존재, 이번 턴 발견

원래 사용자님이 열거한 15개 함수 목록에는 이 두 함수가 "오버로드가 있다"는 언급이 없었으나, 이번 턴 계약 추출 과정에서 **직접 발견**했다 — `600510`에서 다룬 `confirm_payment_from_provider()`/`mark_payment_uncertain()`/`authorize_kds_release()`와 **같은 계열의 패턴**(원본 함수를 나중 마이그레이션이 DROP 없이 새 시그니처로 추가)이 이 두 함수에도 존재한다:

- **`mark_no_show()`**: `0050_create_waiting_queue_rpc.sql`(원본, `p_actor_type`) vs `0115_create_waiting_pipeline_rpc.sql`(재정의, `p_actor_id`+`p_locale`) — `0063` 패치가 아니라 `0115` 자체가 새 오버로드를 추가한 것으로 확인. `0115` 내부에서 `mark_no_show(...)`를 호출하는 코드 2곳(L1329 인근, L1762 인근)이 있음 — 어느 오버로드를 겨냥하는지, 모호성이 실제로 발생하는지는 이번 Contract Inventory 범위를 넘는 별도 조사가 필요.
- **`get_did_display_state()`**: `0043_create_did_display_rpc.sql`(원본, `p_did_id`) vs `0117_create_did_pipeline_rpc.sql`(재정의, `p_device_id`) — `0117`이 자신의 새 오버로드를 3곳에서 호출.

**투명 공개**: 이 두 발견은 이번 Contract Inventory(Track 1) 작업 중 계약을 추출하다가 우연히 발견한 것이며, 사용자님의 원 배경 설명에는 없었다. 실제 호출 시 모호성이 발생하는지(named argument 겹침 여부)는 이번 문서에서 실증하지 않았다 — Contract Inventory 범위(무엇이 존재하는가)에 한정하고, `600510`과 동일한 심층 재현 조사는 별도 Open Item으로 남긴다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000001_Md_Rules.md`

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` — B 경계(Waiting/Order Session) 9개 함수 중 8개의 소스.
- `sql/migrations/0050_create_waiting_queue_rpc.sql` — `mark_no_show()` 원본 오버로드 소스.
- `sql/migrations/0043_create_did_display_rpc.sql` — DID 관련 3개 함수 소스, `get_did_display_state()` 원본 오버로드.
- `sql/migrations/0117_create_did_pipeline_rpc.sql` — `get_did_display_state()` 재정의 오버로드 소스.
- `sql/migrations/0099_create_realtime_pipeline_rpc.sql` — C 경계(KDS Ticket) 관련 3개 함수 소스.
- `sql/migrations/0016_create_kds_tickets.sql` — `kds_tickets` 원본 DDL.
- `sql/migrations/0012_create_pos_order_sessions.sql` — `order_sessions` 원본 DDL.

### Domain Indexes

- 해당 없음.

### Excluded Rule Families

- Payment Confirmation Boundary 관련 전체(`payment_ledger`/`payment_intents`/`confirm_payment_from_provider` 등) — `600510`에서 이미 완료, 이번 문서는 명시적으로 제외.
- `600720`/`600727_Audit.md`의 `order_items`(`unit_price`/`subtotal`/`is_kds_required`/`display_order`) 결함 — 이미 별도 문서화 완료, 이번 B/C 조사 범위 밖(참고로만 인용).
- `did_display_queue`/`did_devices` — 참고용으로 계약만 추출, 이번 in-scope 15개 함수가 사용하지 않음을 확인했으므로 드리프트 분석 대상에서 제외.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

이 스냅샷으로 `600622_Logic.md`(드리프트 전수 목록 + Source of Truth 후보) 작성 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600622_Logic.md] =====
# 600622_Logic.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role) — Track 1 (Contract Inventory)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## §1 참조 불일치 전수 목록 (통합, 출처 명시, 이번 턴 라이브 재확인)

### §1.1 `order_sessions` — 8건, 전부 확인됨 (phantom, 34개 컬럼 목록에 없음)

| # | 컬럼 | 참조 함수 (읽기/쓰기) | 근거 위치 |
|---|---|---|---|
| 1 | `pre_order_amount` | `call_waiting_customer()`(읽기), `pre_order_while_waiting()`(쓰기) | `0115` L449/571/585-587(읽기), L806/829/845(쓰기) |
| 2 | `table_number` | `call_waiting_customer()`(쓰기), `confirm_arrival()`(읽기) | `0115` L488-489/504/528/546/569/582(쓰기), L894(읽기) |
| 3 | `called_at` | `call_waiting_customer()`(쓰기), `mark_no_show()`(읽기), `get_waiting_status()`(읽기) | `0115` L487/506(쓰기), L1356/1425/1427/1430(읽기), L1491/1541(읽기) |
| 4 | `call_count` | `call_waiting_customer()`(쓰기), `get_waiting_admin_view()`(읽기) | `0115` L491(쓰기), L1622(읽기). 참고: `0117`(DID, 범위 밖)에서도 유사 개념 참조 |
| 5 | `arrival_confirmed_at` | `confirm_arrival()`(쓰기), `get_waiting_status()`(읽기), `get_waiting_realtime_state()`(읽기) | `0115` L916(쓰기), L1491/1543(읽기); `0099` L643-644/693/697(읽기) |
| 6 | `cancel_reason` | `cancel_waiting()`(쓰기/읽기) | `0115` L1254/1280/1302/1317 |
| 7 | `no_show_at` | `mark_no_show()`(쓰기) | `0115` L1378/1447 |
| 8 | `memo` | `get_waiting_admin_view()`(읽기, `os.memo`), `get_waiting_realtime_state()`(읽기, `os.memo`) | `0115` L1623; `0099` L648 (둘 다 alias `os` = `order_sessions`로 이번 턴 직접 확인) |

**`get_waiting_realtime_state()`(`0099`) 관련 신규 확인**: 이 함수는 4개 항목(`arrival_confirmed_at`/`pre_order_amount`/`table_number`/`memo`)을 **한 SELECT 문 안에서 동시에** 참조한다(`600622` 작성 중 직접 소스 대조로 확인) — 즉 이 함수는 현재 어떤 입력으로도 실행 자체가 불가능한 상태로 추정된다(하드 에러 예상, 이번 턴 실제 재현은 하지 않음 — Contract Inventory 범위로 한정).

### §1.2 `kds_tickets` — 정정(이번 턴): 2건 모두 정확한 위치에서 확인됨, 같은 INSERT 문 안에 공존

**정정 배경**: 직전 버전은 "B/C 범위 안에서 위치 확인 불가"로 서술했으나, 이는 검색 방법의 결함이었다 — `kt\.menu_id|kds_tickets.*menu_id`라는 정규식이 "같은 줄"에 두 토큰이 함께 있어야 매치되는데, 실제 코드는 다음처럼 여러 줄에 걸친 컬럼 목록 스타일로 작성되어 있어(이 프로젝트 SQL 전반의 표준 포맷) `grep`의 단일 라인 매칭으로는 잡히지 않았다:

```sql
insert into catchmenu_kds.kds_tickets (          -- L770
  tenant_id, store_id,
  order_id, menu_id,                              -- L771 (menu_id는 여기)
  menu_name_snapshot,
  quantity_snapshot,
  kitchen_zone, kds_status,
  conditions_met,
  ticket_created_at,
  business_day, business_timezone
) values ( ... );
```

`0115_create_waiting_pipeline_rpc.sql`은 검색 **대상 파일 목록에는 포함되어 있었다**(파일 자체가 스캔에서 빠진 것이 아님) — 다만 정규식이 여러 줄에 걸친 참조를 못 잡았을 뿐이다. `pre_order_while_waiting()` 함수(L602-866 범위) 안의 이 **단 하나의 `kds_tickets` INSERT**(B/C 범위 15개 함수 전체에서 `insert into catchmenu_kds.kds_tickets`는 이 한 곳뿐임을 이번 턴 재확인)에 두 결함이 **동시에** 존재한다:

- **`menu_id`(L771)**: `kds_tickets` 테이블에 이 컬럼은 **없다**(라이브 재확인 — 실제 컬럼은 `order_item_id`, 메뉴 연결은 `order_items.menu_id`를 통한 간접 참조만 가능). 이 INSERT는 존재하지 않는 컬럼을 참조하는 phantom-column 유형의 결함 — 실행 시 `column "menu_id" of relation "kds_tickets" does not exist` 하드 에러 예상(`600510`에서 겪은 것과 동일한 실패 유형, 이번 턴 실제 재현은 하지 않음).
- **`ticket_number`**: 컬럼 자체는 **실존한다**(`text`, `NOT NULL`, `uq_kds_ticket_store_number` UNIQUE 제약, 기본값 없음 — 이번 턴 재확인). 그런데 위 INSERT의 컬럼 목록(`tenant_id, store_id, order_id, menu_id, menu_name_snapshot, quantity_snapshot, kitchen_zone, kds_status, conditions_met, ticket_created_at, business_day, business_timezone`)에 **`ticket_number`가 아예 빠져 있다** — `NOT NULL` 컬럼에 기본값도 없이 값을 안 채우는 것이므로, `menu_id` 에러가 없었다면 여기서도 하드 에러가 났을 것이다.

**"실존 컬럼이므로 드리프트 아님"이라는 이전 서술 정정**: 컬럼이 실존한다는 것과 "이 INSERT가 그 컬럼을 올바르게 채운다"는 것은 별개 사실이다. `ticket_number`는 존재하는 컬럼을 이 INSERT가 빠뜨린 경우이지, 애초에 없는 컬럼을 참조하는 `menu_id`와는 결함의 **유형**이 다를 뿐 — 둘 다 이 하나의 INSERT를 하드 실패시키는 실제 결함이라는 점은 동일하다.

**분류 정정 — Correction 유형으로 재분류**: `ticket_number` 누락은 `600512_Logic.md`(§0)에서 확인한 `0063`의 `payment_ledger` INSERT가 `ledger_entry_type`(NOT NULL, 기본값 없음)을 빠뜨린 것과 **완전히 같은 패턴**(NOT NULL 컬럼을 컬럼 목록에서 누락) — 새 컬럼 추가나 재설계가 아니라 단순히 INSERT 컬럼 목록에 `ticket_number` 값을 채워 넣기만 하면 되는 **Correction**(§2 분류 체계 기준)으로 분류한다. `menu_id`는 §2의 8개 `order_sessions` 컬럼과 마찬가지로 phantom-column 유형이며, 올바른 참조 경로(`order_item_id` 경유)로 정정이 필요하다는 점에서 별도로 다룬다(아래 §1.2.1).

#### §1.2.1 `menu_id` 정정 방향 — 후보만 제시 (결정 아님)

- 후보 1: INSERT에서 `menu_id` 컬럼 자체를 제거(애초에 `kds_tickets`가 메뉴를 직접 참조할 필요가 없다는 전제 — `order_item_id`로 이미 간접 참조 가능하다면 중복).
- 후보 2: `order_item_id`를 이 INSERT에 함께 채워, `kds_tickets`가 자신이 속한 `order_items` 행을 통해 메뉴 정보를 조회하도록 정정.
- 최종 선택은 이 문서에서 하지 않는다 — 이 함수(`pre_order_while_waiting()`)의 나머지 `order_items` INSERT 로직(같은 함수 안, L744 부근)과의 관계를 함께 봐야 하므로 다음 Track에서 다룬다.

### §1.3 `store_settings.max_waiting_count`/`max_wait_number` — 확인됨, 함수 간 명명 불일치

| 함수 | 사용하는 컬럼명 | 실제 존재 여부 |
|---|---|---|
| `register_waiting()`(`0115` L230/267) | `max_wait_number` | **존재함**(라이브 확인, `store_settings.max_wait_number`) |
| `get_waiting_realtime_state()`(`0099` L612/732-733/740) | `max_waiting_count` | **존재하지 않음** |

같은 설정값(대기 최대 인원/번호 상한)을 가리키는 것으로 보이나, 함수마다 다른 컬럼명을 참조 — `0115`는 정확, `0099`는 phantom.

### §1.4 `orders.paid_at`/`order_source` — 1건 확인됨(B/C 범위), 1건은 Payment 경계 소관으로 확정

| 컬럼 | B/C 범위(`0115`/`0043`/`0099`) 내 참조 | 실제 존재 여부 | 판정 |
|---|---|---|---|
| `order_source` | `pre_order_while_waiting()`(`0115` L715/792/1062/1808) | 존재하지 않음(`orders` 32개 컬럼에 없음) | **이번 B/C 범위 내 확인된 드리프트** |
| `paid_at` | B/C 범위 15개 함수 어디에도 참조 없음 | 존재하지 않음 | 이번 턴 저장소 전체 재검색 결과 `0098`(Payment 확인 파이프라인)/`0076`/`0082`/`0105`/`0109`/`0114`/`0116`/`0133` 등 **전부 Payment/청구/키오스크 도메인 파일**에서만 등장 — **`600510` Payment Confirmation Boundary 소관으로 확정**, 이번 B/C 문서에서는 참고만 하고 다루지 않는다. |

## §2 `order_sessions` 8개 컬럼 — Source of Truth 후보 (결정 아님, 후보 나열만)

ChatGPT 원칙 적용: 각 컬럼에 대해 3가지 후보 버킷(A: `order_sessions`에 snapshot으로 유지, B: 별도 이벤트 로그로 분리, C: 이미 다른 테이블에 있어 중복 우려) 중 해당하는 것을 제시하고, Correction/Alignment/Redesign 3종으로 분류한다. **최종 선택은 이 문서에서 하지 않는다.**

| # | 컬럼 | 후보 A (snapshot 유지) | 후보 B (이벤트 로그 분리) | 후보 C (중복 우려 — 이미 다른 곳에 있음) | 분류 |
|---|---|---|---|---|---|
| 1 | `pre_order_amount` | 세션 단위 금액 스냅샷으로 `order_sessions`에 유지 — WAITING 단계엔 아직 `orders` 행 자체가 없어 다른 소스가 없음 | 해당 없음(단일 값, 반복 이벤트 아님) | 주문 생성 이후엔 `orders.total_amount`와 중복 우려 — 세션→주문 전환 시점의 관계 정의 필요 | **Redesign** — 컬럼 자체는 필요하나 주문 생성 이후 값의 소유권(세션 vs 주문) 재설계 필요 |
| 2 | `table_number` | (약함) 세션에 텍스트 스냅샷으로 유지 | 해당 없음 | **강함** — `order_sessions.table_id`가 이미 `catchmenu_store.dining_tables(id)`를 FK로 참조하며, `dining_tables`에 `table_code`/`table_name` 컬럼이 실존(이번 턴 확인) — `table_id` FK를 통해 조회하면 되므로 별도 컬럼 자체가 불필요할 가능성 | **Redesign** — 신규 컬럼 추가가 아니라 기존 `table_id` FK를 경유하는 조회로 대체하는 방향이 유력 후보 |
| 3 | `called_at` | (약함) 마지막 호출 시각만 세션에 유지 | **강함** — "호출"은 반복 가능한 이벤트(재호출)이므로 이벤트 로그가 자연스러움 | **강함** — `catchmenu_store.did_display_queue`에 이미 `last_called_at`/`call_count`/`max_call_count` 컬럼이 실존(이번 턴 확인) — DID 큐가 이미 이 개념을 담당하고 있을 가능성 | **Redesign** — `did_display_queue`와의 역할 중복 여부를 먼저 규명해야 함 |
| 4 | `call_count` | (약함) | **강함** — 3번과 동일 이유 | **강함** — `did_display_queue.call_count`/`max_call_count`와 명백히 개념 중복(이번 턴 확인) | **Redesign** — 3번과 함께, `order_sessions`가 아니라 `did_display_queue`가 이미 Source of Truth일 가능성이 높음 |
| 5 | `arrival_confirmed_at` | (약함) | 해당 없음(단일 확정 이벤트) | **매우 강함** — `order_sessions`에 이미 `arrived_at timestamptz`(실존 컬럼, 이번 턴 확인)가 있음 — 이름만 다른 동일 개념일 가능성이 높음 | **Alignment** — 신규 컬럼 후보라기보다, 함수가 기존 `arrived_at`을 다른 이름(`arrival_confirmed_at`)으로 잘못 참조하고 있을 가능성이 가장 유력 |
| 6 | `cancel_reason` | **강함** — 기존 `cancelled_at`(실존)과 짝을 이루는 사유 텍스트, 표준적인 timestamp+reason 패턴 | 해당 없음(단일 취소 이벤트) | 낮음 — 다른 테이블에 유사 컬럼 없음 | **Correction** — `cancelled_at`과 같은 패턴으로 신규 컬럼 추가가 가장 단순하고 타당한 후보 |
| 7 | `no_show_at` | **강함** — 기존 `completed_at`/`cancelled_at`과 동일한 터미널 상태 타임스탬프 패턴, `chk_session_status`에 `'NO_SHOW'`가 이미 허용값으로 존재 | 해당 없음 | 낮음 | **Correction** — 기존 컬럼 패턴과 완전히 일치하는 가장 단순한 후보 |
| 8 | `memo` | (중간) 대기 단계 전용 메모(주문 전 메모)로 `order_sessions`에 유지 | 해당 없음 | **중간** — `catchmenu_pos.orders.memo`가 이미 실존(주문 단계 메모) — 두 메모가 같은 개념인지, 대기 단계/주문 단계로 성격이 다른 별개 개념인지 규명 필요 | **Redesign** — `orders.memo`와의 관계(대체/병행/승계) 정의가 먼저 필요 |

**요약 — Correction/Alignment/Redesign 분포**:
- **Correction**(단순 컬럼 추가로 해결 가능): `cancel_reason`, `no_show_at` — 2건.
- **Alignment**(신규 컬럼이 아니라 기존 컬럼 참조로 정정 가능성): `arrival_confirmed_at` — 1건.
- **Redesign**(다른 테이블/관계와의 역할 재정의 필요): `pre_order_amount`, `table_number`, `called_at`, `call_count`, `memo` — 5건.

## §3 Open Items

(a) ~~`kds_tickets`의 `menu_id`/`ticket_number` — 배경 설명의 "2건" 주장을 이번 B/C 범위 안에서 검증하지 못함~~ — **해결됨(이번 턴 정정)**. 두 건 모두 `0115` `pre_order_while_waiting()`의 `kds_tickets` INSERT(L770-778) 안에서 확인: `menu_id`는 phantom-column, `ticket_number`는 NOT NULL 컬럼 누락(Correction 유형) — §1.2 참고. 이전 "위치 확인 불가"는 `grep` 패턴이 여러 줄에 걸친 참조를 못 잡은 검색 방법 결함이었음을 확인.

(b) `get_waiting_realtime_state()`(`0099`)의 4중 phantom-column 동시 참조(§1.1) — 직접 재현(BEGIN/ROLLBACK)은 이번 Contract Inventory 범위를 넘어서 시도하지 않았다. 다음 단계(Track 2 이후)에서 실증 필요.

(c) `mark_no_show()`(`0050`/`0115`)·`get_did_display_state()`(`0043`/`0117`) 오버로드(`600621_Overview.md` §2.1) — `600510`과 동일한 계열의 모호성 위험이 있는지 별도 조사 필요. 이번 문서는 존재 확인만 했다.

(d) `table_number`/`called_at`/`call_count`가 정말로 `dining_tables`/`did_display_queue`의 기존 컬럼과 개념적으로 동일한지는 **후보로만 제시**했을 뿐 확정하지 않았다 — 실제 업무 흐름(대기 손님 호출이 `did_display_queue`를 통해서만 이루어지는지, `order_sessions`에도 독립적으로 필요한지)에 대한 Human 판단 필요.

(e) `orders.order_source` — B/C 범위 내 확인된 드리프트(§1.4)이나, 이번 문서는 Contract Inventory·드리프트 목록·SoT 후보 나열에 한정하고 수정 설계는 다음 Track으로 이월한다.

## Snapshot Decision

이 스냅샷으로 다음 Track(Correction/Alignment/Redesign 각각에 대한 구체적 설계, 즉 Track 2 이후) 진행 가능. `.sql` 파일은 이번 턴에서 생성·수정하지 않았음. Track 0 동결(신규 컬럼/오버로드/상태모델 변경 금지)을 준수했다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600623_TestPlan.md] =====
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


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600624_ChangeContract.md] =====
# 600624_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`customer_handoff_contract_reconciliation`

## §0 Authority

Based on `600621_Overview.md`, `600622_Logic.md`, `600623_TestPlan.md`. This contract covers only the two items explicitly classified as Correction this turn:

1. `catchmenu_kds.kds_tickets` INSERT inside `catchmenu_pos.pre_order_while_waiting()` (`0115`).
2. `max_waiting_count` → `max_wait_number` inside `catchmenu_pos.get_waiting_realtime_state()` (`0099`).

**Classification note (transparency)**: `600622_Logic.md` §2 originally classified `order_sessions.cancel_reason`/`no_show_at` as **Correction** (simple new-column-add, alongside `arrival_confirmed_at` as Alignment and the other 5 as Redesign). This turn's task text groups `cancel_reason`/`no_show_at` into the **Redesign** bucket instead ("table_number, called_at, call_count, pre_order_amount, cancel_reason/no_show_at/memo 등"). This is a genuine discrepancy between the two documents, not silently resolved here — `cancel_reason`/`no_show_at` are **not** in this contract's Allowed scope either way, so the discrepancy has no effect on what is approved this turn, but it should be reconciled in `600622_Logic.md` before any future workpacket relies on that classification table.

## §1 Allowed Files

Exactly two existing files may be modified. No new file is created.

| File | Allowed scope |
|---|---|
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | **`catchmenu_pos.pre_order_while_waiting()`'s `kds_tickets` INSERT statement only** (`600623_TestPlan.md` §2 Before/After): remove the `menu_id` column/value; add a `ticket_number` column/value generated as `v_order_number \|\| '-' \|\| lpad(v_ticket_count::text, 2, '0')`; add one new loop-scoped counter variable (`v_ticket_count int := 0;`) to the function's existing `declare` block, incremented once per loop iteration immediately before the INSERT. No other statement in `pre_order_while_waiting()`, and no other function in `0115`, may be touched. |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | **`catchmenu_pos.get_waiting_realtime_state()`'s `max_waiting_count` references only** — rename all 4 occurrences (`select ... into v_store_settings` column list, plus 3 later usages of `v_store_settings.max_waiting_count`) to `max_wait_number`. No other function in `0099` (`get_kds_realtime_state()`, `get_staff_alert_feed()`, `broadcast_store_event()`) may be touched. |

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `pre_order_while_waiting()`'s `orders` INSERT (`order_source`, `order_type := 'TABLE'`) | Newly discovered this turn (`600623_TestPlan.md` §0.5/§4), not approved — separate Open Item (§4). |
| `pre_order_while_waiting()`'s `order_items` INSERT (`unit_price`/`subtotal`/`item_options`/missing `menu_code_snapshot`/missing `returning id`) | Newly discovered this turn, not approved — separate Open Item (§4), same class of defect already resolved for `place_takeout_order()` in `600727_Audit.md` but not yet addressed here. |
| `order_sessions.arrival_confirmed_at` ↔ `arrived_at` alignment | Classified Alignment, requires its own Human decision on whether the two are the same concept — not approved this turn (`600622_Logic.md` §2). |
| `order_sessions.table_number`/`called_at`/`call_count`/`pre_order_amount`/`memo` (and `cancel_reason`/`no_show_at` per this turn's Redesign grouping, see §0 classification note) | All 5(+2) Redesign items — Source-of-Truth decisions not made, explicitly out of scope (`600622_Logic.md` §2/§3). |
| `catchmenu_pos.orders.order_source` anywhere else it may be referenced | Confirmed drift (`600622_Logic.md` §1.4) but not approved for correction this turn. |
| `mark_no_show()` (`0050`/`0115`) / `get_did_display_state()` (`0043`/`0117`) overloads | Discovered in `600621_Overview.md` §2.1 — separate investigation needed, not approved. |
| `mark_payment_uncertain()` / `authorize_kds_release()` | Payment Confirmation Boundary territory, `600510`'s scope — explicitly excluded from this workpacket (`600621_Overview.md` §0). |
| Any other `sql/migrations/*.sql` file | Out of scope. |
| Flutter/runtime code, tools scripts | Out of scope. |

Implementation must not:

- Add `order_item_id` to the `kds_tickets` INSERT (would require also fixing the `order_items` INSERT to `returning id into ...`, which is out of scope — `600623_TestPlan.md` §0.5 explains why the simpler `menu_id`-removal design was chosen over the `order_item_id`-based alternative from `600622_Logic.md` §1.2.1).
- Touch `catchmenu_kds.kds_tickets`, `catchmenu_pos.order_items`, `catchmenu_store.store_settings`, or `catchmenu_pos.order_sessions` table schema (DDL) — this is a function-body-only fix, no `ALTER TABLE`.
- Add a `CHECK` constraint, `NOT NULL`, or default value to any column as a side effect of this fix.

## §3 Required Behavior Preservation

- `pre_order_while_waiting()`'s existing signature, `orders`/`order_items` INSERT logic (bugs and all — out of scope), coupon/point logic, and response shape are unchanged except for the one `kds_tickets` INSERT.
- `get_waiting_realtime_state()`'s existing signature, all other jsonb fields it builds, and response shape are unchanged except for the `max_waiting_count`→`max_wait_number` rename.
- `get_kds_realtime_state()`/`get_staff_alert_feed()`/`broadcast_store_event()` (siblings in the same `0099` file) remain byte-identical.

## §4 Required New Behavior

- `pre_order_while_waiting()`'s `kds_tickets` INSERT, when reached (i.e., once the separate, out-of-scope `orders`/`order_items` blockers are independently fixed in a future workpacket), must succeed without a `menu_id`-does-not-exist or `ticket_number`-NOT-NULL error.
- `get_waiting_realtime_state()` must progress past the `store_settings` lookup and fail (if at all) only on the still-open `arrival_confirmed_at`/`table_number`/`memo` drift — not on `max_waiting_count`.

## §5 Verification Requirements

Per `600623_TestPlan.md`:

1. Test A — isolated `kds_tickets` INSERT succeeds with the corrected column list (already verified in the TestPlan itself via a rolled-back transaction; Stage 5 must re-verify against the actually-implemented function body).
2. Test B — `get_waiting_realtime_state()`'s failure point moves from `max_waiting_count` to `arrival_confirmed_at` (already verified in the TestPlan itself; Stage 5 must re-verify against the actually-implemented function body).
3. Test C — the full blocker chain for `pre_order_while_waiting()` is recorded, not silently dropped.
4. Static boundary — only `0115`'s `kds_tickets` INSERT and `0099`'s `max_waiting_count` references differ from current source.

## §6 Open Items Not Approved In This Contract

### §6.1 `pre_order_while_waiting()`'s `orders`/`order_items` Defects — Blocks Any Real E2E Success

Newly discovered this turn (`600623_TestPlan.md` §0.5/§4). Even after this contract's fix lands, calling `pre_order_while_waiting()` end-to-end will still fail immediately at the `orders` INSERT (`order_source` phantom column, then `order_type := 'TABLE'` hidden behind it), before ever reaching the `order_items` INSERT (its own 4-part defect cluster) or the now-fixed `kds_tickets` INSERT. A follow-up workpacket covering both statements is needed before this function can complete end-to-end for the first time.

### §6.2 `get_waiting_realtime_state()`'s Remaining 3 `order_sessions` Phantom Columns

After this contract's fix, the function will still fail on `arrival_confirmed_at` (Alignment — likely the same concept as the existing `arrived_at` column, `600622_Logic.md` §2 row 5), then (once that's resolved) `table_number` and `memo` (both Redesign, SoT undecided). None approved this turn.

### §6.3 5 Redesign-Classified `order_sessions` Columns — SoT Decision Needed

`pre_order_amount`, `table_number`, `called_at`, `call_count`, `memo` (and, per this turn's regrouping — see §0 classification note — possibly `cancel_reason`/`no_show_at` as well, pending reconciliation with `600622_Logic.md`'s original Correction classification for those two). Candidates listed in `600622_Logic.md` §2, no decision made.

### §6.4 `arrival_confirmed_at` ↔ `arrived_at` Alignment Decision

`600622_Logic.md` §2 row 5 — strong candidate that this is the same concept referenced under two different names, not a missing feature. Needs a Human decision (rename the code reference vs. treat as genuinely separate) before implementation.

### §6.5 `mark_no_show()` / `get_did_display_state()` Overload Sprawl

Carried from `600621_Overview.md` §2.1 — same pattern as `600510`'s `confirm_payment_from_provider()`/`mark_payment_uncertain()`/`authorize_kds_release()`, not yet investigated for actual call-site ambiguity.

## §7 Risk

Risk level: LOW-MEDIUM.

Reasons:

- Both target functions (`pre_order_while_waiting()`, `get_waiting_realtime_state()`) are already 100% non-functional today (confirmed via direct reproduction) — this fix cannot make either function "more broken" than its current baseline.
- The `kds_tickets` fix is isolated-tested and confirmed working (`600623_TestPlan.md` §2).
- The `get_waiting_realtime_state()` fix is confirmed to produce forward progress, not silently mask remaining defects (§3 of the TestPlan explicitly moves the failure point, doesn't hide it).
- Neither fix touches any table schema — function-body-only, low blast radius.

Risk controls:

- Two-function, two-statement boundary, no schema changes.
- Isolated pre-verification already completed for both fixes before this contract was written (unusual for this stage, but done here because the fixes are small and the verification transactions were cheap to run).
- Explicit Open Items (§6) prevent this fix from being mistaken for a complete resolution of either function.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve modifying sql/migrations/0115_create_waiting_pipeline_rpc.sql, limited to pre_order_while_waiting()'s kds_tickets INSERT statement exactly as specified in §1.
☑ I approve modifying sql/migrations/0099_create_realtime_pipeline_rpc.sql, limited to the 4 max_waiting_count→max_wait_number renames inside get_waiting_realtime_state() exactly as specified in §1.
☑ I acknowledge that pre_order_while_waiting() will still fail end-to-end after this fix (blocked by order_source/order_type/order_items, §6.1) and that get_waiting_realtime_state() will still fail on arrival_confirmed_at (§6.2) — neither function reaches full success from this contract alone.

## §9 Stage 4 Instruction If Approved

If all three Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600625_Module.md] =====
# 600625_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-14

## Summary

Implemented the two approved Correction items from `600624_ChangeContract.md` §1: the `kds_tickets` INSERT fix inside `catchmenu_pos.pre_order_while_waiting()` (`0115`), and the `max_waiting_count`→`max_wait_number` rename inside `catchmenu_pos.get_waiting_realtime_state()` (`0099`).

| File | Function | Change | Result |
|---|---|---|---|
| `sql/migrations/0115_create_waiting_pipeline_rpc.sql` | `catchmenu_pos.pre_order_while_waiting()` | `kds_tickets` INSERT: `menu_id` column/value removed; `ticket_number` column/value added (generated); one new loop-scoped counter (`v_ticket_count int := 0;`) and one new variable (`v_ticket_number text;`) added to the function's `declare` block. | Applied, live-verified. |
| `sql/migrations/0099_create_realtime_pipeline_rpc.sql` | `catchmenu_pos.get_waiting_realtime_state()` | `max_waiting_count` → `max_wait_number`: 1 occurrence in the `select ... into v_store_settings` column list, 2 occurrences of `v_store_settings.max_waiting_count` → `v_store_settings.max_wait_number`. The JSON output key `'max_waiting_count'` (an API label, not a column reference) was correctly left unchanged. | Applied, live-verified. |

## `ticket_number` Generation Logic — Reuses The Existing `0026` Pattern

The fix does not invent a new numbering scheme. It reuses the exact convention already established in `sql/migrations/0026_create_order_rpc.sql` (L356-357, inside its own `kds_tickets`-creating loop):

```sql
-- 0026 (existing, unmodified)
v_ticket_count := v_ticket_count + 1;
v_ticket_number := v_order.order_number || '-' ||
                   lpad(v_ticket_count::text, 2, '0');
```

`0115`'s new code, inside `pre_order_while_waiting()`'s own per-cart-item loop:

```sql
v_ticket_count := v_ticket_count + 1;
v_ticket_number := v_order_number || '-' || lpad(v_ticket_count::text, 2, '0');
```

Same shape (`<order_number>-<zero-padded 2-digit sequence>`), same increment-then-format order, same `lpad` width. `v_order_number` was already an in-scope variable in `pre_order_while_waiting()` (used earlier in the function for the `orders.order_number` value), so no new dependency was introduced — only the counter (`v_ticket_count`) and the formatted result (`v_ticket_number`) are new.

## Boundary Notes

- Only the two approved statements were touched — `pre_order_while_waiting()`'s `orders` INSERT (`order_source`/`order_type := 'TABLE'`) and `order_items` INSERT (`unit_price`/`subtotal`/`item_options`/missing `menu_code_snapshot`) remain untouched, exactly as `600624_ChangeContract.md` §2 forbade.
- `get_kds_realtime_state()`, `get_staff_alert_feed()`, `broadcast_store_event()` — the three other functions in `0099` — are byte-unchanged (diff hunks confirmed confined to `get_waiting_realtime_state()`'s own line range).
- `600420_kds_status_naming_and_stale_columns`'s prior fix (`is_late`/`kds_capacity_threshold_per_zone` computed expressions, replacing stale `priority_score`/`kds_capacity_threshold_per_station`) confirmed preserved in `0099` — zero occurrences of the old stale names remain.
- No table schema (DDL) was touched — function-body-only fix, matching `600624_ChangeContract.md` §2's explicit prohibition.
- Checksum bookkeeping correct for both files — SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly, `success = true`.
- No cloud database was touched. No git commit was performed.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600626_Verification.md] =====
# 600626_Verification.md

Status: Verified (final — Cursor result received, see §3)
Lifecycle: Verification
Stage: 5
Owner: Claude Code + Antigravity + Codex self-check + Cursor (official, binding)
Date: 2026-07-14

## Verification Result

PASS for the approved scope (both Correction items). Three-way independent verification (Claude Code, Antigravity, Codex self-check) plus Cursor's official, binding result (`000701` §39/§40) all agree: live=source match for both functions, Test A/B PASS, `600420` preservation confirmed, `600624_ChangeContract.md` §6.1's predicted blocker reproduced consistently, boundary clean. `600627_Audit.md`'s status is now final.

## 1. Claude Code Stage 5 — Independent Re-Verification

Nothing below was assumed from Codex's or Antigravity's reports; each item was independently re-derived against the local Supabase Docker container, using fresh test data distinct from what was used when the fix was designed.

| Check | Result |
|---|---|
| `0099`/`0115` checksum integrity | PASS — both SHA-256 (CRLF-normalized) match `catchmenu_meta.migration_history` exactly, `success = true`. |
| `0099`/`0115` live = source (`pg_get_functiondef`) | PASS — both function bodies match source exactly. |
| `0099` boundary — only `get_waiting_realtime_state()` touched | PASS — diff hunks (`@@ -609,7` / `@@ -730,14`) confined to that function's line range (580-756); `get_kds_realtime_state()`/`get_staff_alert_feed()`/`broadcast_store_event()` byte-identical. |
| `0115` boundary — only the `kds_tickets` INSERT touched | PASS — the `orders`/`order_items` INSERTs in the same function are unchanged (confirmed both via diff and via reproduction, see below). |
| `600420`'s prior fix (`is_late`/`kds_capacity_threshold_per_zone`) preserved in `0099` | PASS — 0 occurrences of stale `priority_score`/`kds_capacity_threshold_per_station` remain. |
| Test A — `kds_tickets` INSERT correction, re-run with **new** data (menu `참치김밥`, quantity 2, new order/correlation id) | PASS — succeeded cleanly, returned `ticket_number = 'W-REVERIFY-600625-2-01'`, `kds_status = 'HOLD'`. |
| Test B — `get_waiting_realtime_state()` progress, re-run against the **real, live** function (no simulation/patch needed this time — the fix is now actually implemented) | PASS — `max_wait_number`-related error is gone; function now fails precisely at `os.arrival_confirmed_at` (the next, still-open drift), confirming genuine forward progress, not a full fix. |
| `pre_order_while_waiting()` still fails at `order_source` first (per `600624_ChangeContract.md` §6.1's prediction), re-run with **new** data (different session, menu `051`, quantity 2, new correlation id) | PASS (confirms the predicted, still-open blocker) — identical `column "order_source" of relation "orders" does not exist` error, same statement, unaffected by the `kds_tickets` fix since execution never reaches that code. |

## 2. Antigravity + Codex — Reported Results (Prior To This Turn)

Per this workpacket's dispatch, Antigravity (reference-only observer, `000701` §40) and Codex (self-check on its own implementation) both reported **ACCEPT** before this document was written. This document does not have direct access to their raw output — only confirmation that both were dispatched against the same scope (the two Correction items) and both returned ACCEPT, consistent with Claude Code's independent findings in §1.

## 3. Cursor — Official Result Received, Including One Finding That Did Not Survive Re-Verification

Per `000701` §39/§40, Cursor is the official, binding verifier in this project's standard "3중 검토" procedure. Cursor's report has now been received.

### 3.1 Findings That Agree With §1/§2 (Accepted Without Re-Verification)

Cursor independently confirmed: live=source match for both `0099`/`0115`, Test A/B PASS, `600420`'s prior fix preserved, `pre_order_while_waiting()`'s predicted `order_source` blocker reproduced, boundary clean. These match Claude Code's/Antigravity's/Codex's own findings in §1/§2 exactly — no disagreement, no re-verification performed for these specific items (consistent with this document's original policy: only re-verify where a disagreement or new claim appears).

### 3.2 Checksum Finding — Reported As A Mismatch, Re-Verified As A False Positive

Cursor's report separately flagged `0115`'s `migration_history.checksum` as stale, citing a specific alternate value (`c588014b...`) that allegedly did not match the source file's CRLF-normalized checksum. Per instruction, this specific claim was investigated **before being written into this document as fact** — per `000701` §37/§39's dual-verification principle, a verifier's report is evidence to check, not a conclusion to transcribe.

Three independent methods were used, all agreeing the reported mismatch **does not exist**:

1. **Direct recomputation**: `sed 's/\r$//' sql/migrations/0115_create_waiting_pipeline_rpc.sql | sha256sum` → `7eba4434...`, identical to the value recorded in `catchmenu_meta.migration_history`.
2. **Tool source inspection**: `tools/apply_migrations.py`'s `checksum()` function was read directly — `path.read_bytes().replace(b"\r\n", b"\n")` then `hashlib.sha256` — confirmed to be the exact same normalization method used in method 1, ruling out a normalization-mismatch explanation.
3. **Actual tool execution**: `python tools/apply_migrations.py` was run for real (not simulated) — output: `OK 0115_create_waiting_pipeline_rpc.sql (already applied, checksum matches)`, and all 153 sequence-numbered migrations passed with zero mismatches.

**No `UPDATE` was performed on `migration_history.checksum`** — none was needed, since the recorded value already matched. Had the `UPDATE` been executed on the basis of Cursor's reported value alone, it would have **overwritten a correct checksum with an incorrect one**, introducing the exact kind of drift this project's checksum-tracking system exists to prevent.

**This is recorded here explicitly as a positive case of the `000701` §37/§39 dual-verification principle working as intended**: a verifier (Cursor) flagged a finding, that finding was checked independently rather than transcribed on trust, and the check disproved it before it could cause harm. This is not a criticism of Cursor's overall report — the other findings in §3.1 were all confirmed correct — it is a record that the specific checksum claim, and only that claim, did not survive re-verification.

## Scenario Summary

| Scenario | Result |
|---|---|
| Checksum integrity (both files) | PASS — `0115`'s checksum additionally re-verified 3 independent ways after Cursor's mismatch report; reported mismatch not reproduced (§3.2) |
| Live = source (both functions) | PASS |
| Boundary (only the 2 approved statements) | PASS |
| `600420` preservation | PASS |
| Test A (`kds_tickets` fix, new data) | PASS |
| Test B (`get_waiting_realtime_state()` progress, real function) | PASS |
| `pre_order_while_waiting()` still blocked at `order_source` (expected, not a failure of this fix) | Confirmed, matches prediction |
| Antigravity | ACCEPT (reference-only) |
| Codex self-check | ACCEPT |
| **Cursor (official, binding)** | **ACCEPT** — checksum finding investigated and not confirmed (§3.2), all other findings agree with §1/§2 |


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600620_customer_handoff_contract_reconciliation/600627_Audit.md] =====
# 600627_Audit.md

Status: Audited (final)
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-14

## §0 Triple Verification Complete — Including One Reported Finding That Did Not Survive Re-Verification

Claude Code, Antigravity, Codex self-check, and Cursor (official, binding per `000701` §39/§40) have all reported. Three of the four agree on every point without qualification. Cursor's report additionally flagged a `0115` checksum mismatch (citing a specific alternate value); that specific claim was investigated independently — three separate methods (direct recomputation, `apply_migrations.py` source inspection, actual tool execution) all found the recorded checksum already correct, and no mismatch was reproduced. No `UPDATE` was performed, since none was needed. Full account in `600626_Verification.md` §3.2.

This does not weaken the Audit — it is the dual-verification principle (`000701` §37/§39) functioning as designed: a verifier's report was checked rather than transcribed, and the one claim that didn't hold up was caught before being acted on. Every other finding across all four verifiers is unanimous.

## Final Audit Decision

**ACCEPT (scoped, final) — within the approved 2-item Correction boundary (`600624_ChangeContract.md`), both fixes are complete and correct.** Neither `pre_order_while_waiting()` nor `get_waiting_realtime_state()` reaches full end-to-end success — both were already known, and confirmed again this turn (by Claude Code and independently by Cursor), to be blocked by separate, out-of-scope defects immediately downstream of the fixed code.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside `600624_ChangeContract.md` §1 boundary | PASS | `600625_Module.md` — only the `kds_tickets` INSERT in `pre_order_while_waiting()` and the `max_waiting_count` references in `get_waiting_realtime_state()` changed. |
| `ticket_number` generation reuses the existing `0026` convention, not a new scheme | PASS | `600625_Module.md` — identical shape/order/`lpad` width. |
| Checksum integrity (`0099`/`0115`) | PASS | `600626_Verification.md` §1, re-confirmed via 3 independent methods after Cursor's mismatch report (`600626_Verification.md` §3.2) — reported mismatch not reproduced. |
| Live = source (both functions) | PASS | `600626_Verification.md` §1. |
| Boundary — only the 2 approved statements changed | PASS | `600626_Verification.md` §1, diff hunks confined to the exact approved line ranges. |
| `600420`'s prior fix preserved in `0099` | PASS | `600626_Verification.md` §1, 0 stale-name occurrences. |
| Test A (`kds_tickets` fix) reproduced with new data | PASS | `600626_Verification.md` §1. |
| Test B (`get_waiting_realtime_state()` progress) reproduced against the real live function | PASS | `600626_Verification.md` §1 — genuine progress (new failure point), not full success, and not misrepresented as full success. |
| `pre_order_while_waiting()`'s predicted remaining blocker (`order_source`) reproduced with new data | PASS (confirms prediction, not a defect of this fix) | `600626_Verification.md` §1. |
| Dual/triple independent verification | PASS — Claude Code + Antigravity + Codex self-check + **Cursor (official, binding)** all ACCEPT | `600626_Verification.md` §2/§3. |

## Findings

1. Both approved Correction items are fully and correctly implemented, matching `600623_TestPlan.md`'s designs exactly, with zero scope creep into any of the explicitly forbidden statements/functions/columns.
2. `get_waiting_realtime_state()` demonstrates the "fix reveals the next blocker" pattern seen repeatedly across this session's workpackets (`600610`→`600720`→`600727`, `600510`) — progress is real and independently confirmed, not illusory.
3. `pre_order_while_waiting()` shows **zero** observable progress from this fix, because its blocking defects (`order_source`, `order_type := 'TABLE'`, then the `order_items` INSERT's own cluster) all occur chronologically before the code this fix touches. This is expected and was explicitly predicted in `600624_ChangeContract.md` §6.1 — not a shortfall of this workpacket.
4. This is the first Audit in this series where a verifier's specific finding (Cursor's checksum mismatch claim) was reported, investigated, and found not to hold — logged transparently in §0/`600626_Verification.md` §3.2 as a working example of the dual-verification principle, not silently corrected or silently accepted on trust.

## Open Items Carried Forward (All From `600624_ChangeContract.md` §6, Unaffected By This Fix)

(a) **§6.1 — `pre_order_while_waiting()`'s `orders`/`order_items` defects.** `order_source` (phantom column) and `order_type := 'TABLE'` (not in `chk_order_type`) block the `orders` INSERT; the `order_items` INSERT has its own 4-part cluster (`unit_price`/`subtotal`/`item_options` phantom, `menu_code_snapshot` NOT NULL omitted, no `returning id`). Reconfirmed still blocking this turn (`600626_Verification.md` §1). Highest-priority follow-up — nothing in this function can succeed end-to-end until this is resolved.

(b) **§6.2 — `get_waiting_realtime_state()`'s remaining `order_sessions` phantom columns.** After this fix, the function fails on `arrival_confirmed_at` (Alignment candidate — likely the same concept as the existing `arrived_at` column). `table_number`/`memo` remain hidden behind it, undiscovered by direct reproduction until `arrival_confirmed_at` is also addressed.

(c) **§6.3 — 5(+2) Redesign-classified `order_sessions` columns.** `pre_order_amount`, `table_number`, `called_at`, `call_count`, `memo`, and (per this turn's classification grouping, still unreconciled with `600622_Logic.md`'s original table) `cancel_reason`/`no_show_at`. No Source-of-Truth decision made.

(d) **§6.4 — `arrival_confirmed_at` ↔ `arrived_at` Alignment decision.** Needs explicit Human decision (rename the code reference vs. treat as a genuinely separate concept) before implementation.

(e) **§6.5 — `mark_no_show()`/`get_did_display_state()` overload sprawl.** Same "later migration adds an overload instead of replacing" pattern as `600510`'s payment functions. Not yet investigated for actual call-site ambiguity.

## Open Question — Dedicated Customer Handoff Defect Roadmap?

`600404_PlaceTakeoutOrder_Defect_Roadmap.md` was created as a living document scoped specifically to `place_takeout_order()`. This workpacket (`600710`→`600610`→`600720`→`600620`) has now accumulated a comparably large, distinct cluster of findings across the **Waiting/Order Session** and **KDS Ticket** boundaries — `pre_order_while_waiting()`'s 3-defect chain, `get_waiting_realtime_state()`'s 4-column drift, `track_takeout_order()`'s shared exposure, `call_customer_pickup()`'s `event_domain` issue, the `mark_no_show()`/`get_did_display_state()` overload sprawl — none of which fit naturally under a `place_takeout_order()`-titled roadmap.

**Open Question for Human decision**: should a new `600405_CustomerHandoff_Defect_Roadmap.md` (or similarly-scoped living document) be created to track this cluster the same way `600404` tracks `place_takeout_order()`'s, or should `600404` be broadened/renamed to cover the whole Customer Handoff flow instead of just one function? This document does not create that file — it only raises the question, per this turn's explicit instruction not to expand scope unilaterally.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- This audit does not authorize a follow-up workpacket for (a)-(e) — findings and priority recorded only.
- No cloud database was touched. No git commit was performed.

## Conclusion

Within its approved boundary, `customer_handoff_contract_reconciliation`'s two Correction items are complete, correct, and independently re-verified by Claude Code with fresh data, Antigravity, Codex self-check, and Cursor (official, binding) — full agreement across all four. Cursor's one additional finding (a checksum mismatch) was investigated and found not to reproduce by three independent methods; no correction was needed or made.

Final status: **ACCEPT (scoped, final)**.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600631_Overview_Mark_No_Show_Overload_And_Redesign.md] =====
# 600631_Overview_Mark_No_Show_Overload_And_Redesign.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 번호 확인 — 도메인 재확인 결과: 결제 아님, 대기열 도메인

지시문의 가칭 `600590`은 `600500_payment_confirmation/`(결제) 도메인 번호 대역에 속한다. 그러나 `mark_no_show()`는 대기열/세션 상태(`order_sessions.session_status`, 노쇼 처리)를 다루는 함수이지 결제 개념이 아니다 — 도메인 재확인 결과 `600600_waiting_order_session/`이 정확한 도메인이다(재확인, `600600_Readme_Waiting_Order_Session.md`).

`600600_waiting_order_session/` 산하 현재 워크패킷 폴더는 `600610_takeout_session_type_fix/`/`600620_customer_handoff_contract_reconciliation/` 2개다(재확인, `ls`). 10단위 관례상 다음 빈 번호는 **`600630`**(`find`로 미사용 재확인) — 지시문의 가칭 `600590`을 **`600630`으로 정정**한다. Overview는 `600631`, Logic은 `600632`.

## §1 배경 재확인 — 두 오버로드 전문 재확인

지시문은 "Cursor 삼중 조사 완료, 재확인 불필요"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 라이브 소스 전문을 직접 재대조했다.

### §1.1 `0050`(구) — `catchmenu_pos.mark_no_show(uuid,uuid,uuid,text,uuid,text)`

`0050:445-574` 전문 재확인:
```sql
create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_actor_type text default 'STAFF', p_actor_id uuid default null,
  p_correlation_id text default null
)
...
select id, session_status, wait_number, arrival_reliability_score,
       business_day, business_timezone
into v_session
from catchmenu_pos.order_sessions
where id = p_session_id and store_id = p_store_id and tenant_id = p_tenant_id
for update;

if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
  return jsonb_build_object('success', false, 'error_key', 'session_not_markable', ...);
end if;

-- decrease arrival reliability score (특허2 주석)
v_new_score := greatest(0, coalesce(v_session.arrival_reliability_score, 100) - 20);

update catchmenu_pos.order_sessions
set session_status = 'NO_SHOW', arrival_reliability_score = v_new_score,
    cancelled_at = now(), updated_at = now()
where id = p_session_id;
```
선행 상태: `WAITING` 또는 `ARRIVAL_PENDING` 둘 다 허용. 사용 컬럼(`session_status`/`wait_number`/`arrival_reliability_score`/`business_day`/`business_timezone`/`cancelled_at`/`updated_at`) 전부 라이브 재확인 결과 실존. `session_events`/`catchmenu_ledger.events` INSERT도 전부 실존 컬럼만 사용. **KDS 연동 코드는 이 함수 어디에도 없다.**

### §1.2 `0115`(신) — `catchmenu_pos.mark_no_show(uuid,uuid,uuid,uuid,text,text)`

`0115:1333-1463` 전문 재확인:
```sql
create or replace function
  catchmenu_pos.mark_no_show(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_actor_id uuid default null, p_locale text default 'ko',
  p_correlation_id text default null
)
...
select id, wait_number, session_status, guest_locale, pre_order_amount, called_at
into v_session
from catchmenu_pos.order_sessions
where id = p_session_id and store_id = p_store_id and tenant_id = p_tenant_id
for update;

-- (주문 없음 검사만 있고, session_status 유효성 검사는 없음)

update catchmenu_pos.order_sessions
set session_status = 'NO_SHOW', no_show_at = now(), updated_at = now()
where id = p_session_id;

if v_session.pre_order_amount > 0 then
  update catchmenu_kds.kds_tickets kt
  set kds_status = 'CANCELLED', cancelled_at = now(), updated_at = now()
  from catchmenu_pos.orders o
  where o.session_id = p_session_id and kt.order_id = o.id and kt.kds_status = 'HOLD';
end if;
```

**정정(지시문과 불일치, 코드로 직접 확인)**: 지시문은 "0115가 `ARRIVAL_PENDING`만 허용"이라고 서술했으나, **`0115`의 함수 본문 어디에도 `session_status` 유효성 검사가 없다** — `v_session.id is null`(세션 자체가 없는 경우)만 검사하고, 그 외에는 현재 `session_status` 값과 무관하게 무조건 `NO_SHOW`로 덮어쓴다. `chk_session_status` CHECK 제약이나 트리거로 전이를 제한하는 메커니즘도 라이브에 없음을 재확인했다(`pg_trigger` 조회 결과 `order_sessions`에는 `updated_at` 자동 갱신 트리거 1개뿐). **`0115`는 `0050`이 갖고 있던 상태 검사(`WAITING`/`ARRIVAL_PENDING`만 허용)를 아예 갖고 있지 않다** — "더 좁은 허용"이 아니라 "검사 자체가 없는 회귀"다.

**phantom 컬럼 3개 재확인**: `pre_order_amount`/`called_at`/`no_show_at` 전부 라이브 `order_sessions`(35개 컬럼, 전수 재조회)에 없음을 확인했다.

## §2 900xxx 설계 문서 재확인 — 부분 지지, 부분 내부 모순 발견

전담 조사(별도 서브에이전트, `docs/900000_patent_and_handoff_package/` 전수 검색)로 확인한 결과:

- **선행 상태 제한**: `900101_Logic...md:249-250`("선행: `session_status = 'ARRIVAL_PENDING'`")와 상태-액션 매트릭스(`900101:288-295`, `mark_no_show`는 `ARRIVAL_PENDING`만 ✓, `WAITING`은 ✗)가 `0115`(상태 검사 자체가 없다는 점은 별개로, 의도했던 시맨틱은) `ARRIVAL_PENDING` 전용을 지지한다 — `0050`의 "`WAITING`도 허용"과는 다르다. **지시문의 이 부분은 정확하다(설계 의도 차원에서).**
- **`arrival_reliability_score` 페널티**: 900xxx 전체에서 **0건 언급** — 유지/폐기 어느 쪽도 설계 문서가 결정하지 않았다. 완전한 설계 공백이다.
- **KDS HOLD→CANCELLED 연동 — 내부 모순 발견**: `900101_Logic...md:254-256`("사이드 이펙트: `pre_order_amount > 0`이면 `kds_tickets UPDATE: HOLD → CANCELLED`")는 `0115`의 동작과 일치한다. **그러나 같은 900xxx 패키지 안의 다른 3개 문서(`900102_ChangeContract` F-003, `906010_ChangeContract` §13.3 영문판, `900103_TestPlan` TC-104, `906000_TestPlan` 영문판)는 정반대로 "`KDS HOLD 유지`(사전주문 미조리, 취소하지 않음)"를 명시한다.** 즉 **900xxx 설계 문서 패키지 자체가 이 지점에서 내부적으로 모순**되어 있다 — `900101`(로직 스펙)은 취소를, `900102`/`900103`/`906010`/`906000`(ChangeContract/TestPlan, 한글+영문 양쪽 다)은 HOLD 유지를 각각 명시한다. `0115`의 실제 코드는 `900101` 한 문서만을 따른다.

**결론**: 지시문의 "900100/900101이 0115 시맨틱을 canonical로 명시"는 **선행 상태 제한에 대해서는 정확**하지만, **KDS 연동 부분은 부정확/과장**이다 — 실제로는 설계 문서 패키지 자체가 이 지점에서 다수결로는 오히려 "HOLD 유지" 쪽(4개 문서)이 우세하고 `900101` 1개 문서만 "CANCELLED"를 명시한다. 어느 쪽이 "진짜 canonical"인지는 이 문서가 판단하지 않는다(§9 Open Item) — 이 모순 자체를 발견해 기록하는 것이 이번 조사의 성과다.

## §3 `pre_order_amount`의 실제 출처 — `order_sessions`에는 없음, 항상 boolean 용도로만 쓰임

`0051_create_pre_order_rpc.sql`의 `create_pre_order()`(`0051:15-` 전문 재확인) 패턴: 사전주문은 `catchmenu_pos.orders` 행을 실제로 생성하고(`v_order_id`), 그 금액은 `orders.total_amount`/`orders.final_amount`에 저장한다(`0051:298-304`) — `order_sessions`에는 금액 컬럼이 전혀 없다. 대신 `order_sessions`는 `order_id`(FK)와 `pre_order_created_at`/`pre_order_expires_at`(둘 다 라이브 실존, 재확인)만 갖는다.

**기존에 이미 확립된 대체 패턴 발견**: `0050`/`0051`의 `get_pre_order_status()` 등 여러 곳(`0050:70`/`258`/`284`/`298`, `0051:823-829`)이 이미 `v_session.pre_order_created_at is not null`을 "사전주문 존재 여부" 판정에 일관되게 사용하고 있다 — `pre_order_amount`라는 컬럼이 있었던 적이 없고, 애초에 이 boolean 패턴이 표준이었던 것으로 보인다.

**결정적 확인**: `mark_no_show()`(`0115`)와 `confirm_arrival()`(`0115`, §4에서 별도 발견) 양쪽 모두에서 `pre_order_amount`는 **오직 `> 0` 비교(boolean 게이트)로만 쓰이고, 실제 금액 숫자값 자체는 어디에도 노출되지 않는다**(`mark_no_show()`의 응답 `'pre_order_cancelled', v_session.pre_order_amount > 0`도 boolean). **따라서 `v_session.pre_order_created_at is not null`로 완전히 대체 가능하다 — 추가 JOIN도, 스키마 변경도 필요 없다.** `orders.final_amount`를 실제로 조회해야 하는 경우(예: 응답에 정확한 취소 금액을 포함해야 한다는 새 요구사항이 생긴다면)는 `order_sessions.order_id`를 거쳐 `catchmenu_pos.orders`를 조인해야 하며, 이는 현재 코드가 하지 않는 추가 작업이다.

## §4 신규 발견 — phantom 컬럼이 `mark_no_show()`/`0118` 밖으로도 확장됨 (범위 초과, Open Item)

지시문이 요청한 범위(`mark_no_show()`, `0118` cron)를 조사하는 과정에서, `0115`의 **다른 함수에도 같은 phantom 컬럼이 있음**을 발견했다 — 이 문서는 이를 전수 감사하지는 않았으나(§9 Open Item, 범위 밖) 발견한 것은 기록한다.

`confirm_arrival()`(`0115:872-985`, `mark_no_show()`와 다른 함수)의 SELECT/응답:
```sql
select id, wait_number, session_status, guest_locale, pre_order_amount, table_number
...
'has_pre_order', v_session.pre_order_amount > 0,
'pre_order_amount', v_session.pre_order_amount,
'table_number', v_session.table_number,
```
`pre_order_amount`(§3과 동일 phantom)뿐 아니라 **`table_number`도 phantom**(라이브 재확인 — `order_sessions`에는 `table_id`(uuid)만 있고 `table_number`는 없음). 또한 이 함수의 UPDATE(`0115:918-923`)는 `arrival_confirmed_at`을 세팅하는데 이 컬럼도 **phantom**(라이브 재확인). `confirm_arrival()` 하나에서만 phantom 컬럼이 3개(`pre_order_amount`/`table_number`/`arrival_confirmed_at`) 추가로 발견됐다 — `mark_no_show()`와 무관한 별개 함수이므로 이번 워크패킷 범위에는 포함하지 않되, `0115` 파일 전체가 phantom 컬럼을 광범위하게 갖고 있을 가능성을 시사하는 신호로 기록한다.

## §5 `0050`의 `arrival_reliability_score` 페널티 로직 — 정확한 재확인 (통합 시 반영 방식은 Logic 단계)

`0050:501-507`(재확인, §1.1에 이미 인용) — `v_new_score := greatest(0, coalesce(v_session.arrival_reliability_score, 100) - 20)`. 페널티는 정확히 **20점 고정 감점**, 하한선 0(음수 방지, `greatest`). 기본값 100(NULL일 때). 이 값은 `arrival_reliability_score`(`chk_session_arrival_reliability` CHECK: 0-100 범위, 라이브 재확인)에 직접 반영되며, `create_pre_order()`(`0051:111-124`)의 `arrival_reliability_too_low` 게이트(스토어 설정 `arrival_reliability_threshold`, 기본 60)가 이 점수를 실제로 소비한다 — 즉 이 페널티는 장식이 아니라 "노쇼 이력이 있는 고객은 향후 사전주문이 거부될 수 있다"는 실제 비즈니스 로직에 연결된 살아있는 메커니즘이다. §2에서 확인했듯 900xxx 설계 문서는 이 페널티 자체를 언급하지 않으므로, `0115` 기반 통합본에 이 로직을 그대로 이식할지/조정할지/제거할지는 설계 결정 사항이며 이 문서는 판단하지 않는다(Logic 단계).

## §6 `0118`의 `WAITING_SESSION_EXPIRE` cron job — 정확한 현재 코드 재확인, phantom 컬럼 1개 추가 발견

파일명 정정: 지시문은 "0118의 pg_cron"이라 지칭했으나 실제 파일명은 `0118_create_schema_validation_update.sql`이다(`0118:165-190`에 cron job 정의가 포함되어 있을 뿐, 파일 자체는 스키마 검증 관련 다른 내용도 함께 다룸).

`0118:164-188` 전문 재확인:
```sql
(
  'WAITING_SESSION_EXPIRE',
  'catchmenu_waiting_session_expire',
  '*/10 * * * *', '*/10 * * * * (10분마다)',
  $sql$
-- 호출 후 15분 노응답 → 자동 노쇼
UPDATE catchmenu_pos.order_sessions
SET session_status = 'NO_SHOW', no_show_at = now()
WHERE session_status = 'ARRIVAL_PENDING'
  AND called_at < now() - interval '15 minutes'
  AND no_show_at IS NULL;

-- 대기 등록 후 2시간 미착석 → 자동 취소
UPDATE catchmenu_pos.order_sessions
SET session_status = 'CANCELLED', cancelled_at = now(), cancel_reason = 'AUTO_EXPIRE'
WHERE session_status = 'WAITING'
  AND session_started_at < now() - interval '2 hours';
$sql$,
  '대기 세션 자동 만료. 10분마다.', true
)
```
지시문이 언급한 `called_at`/`no_show_at` phantom은 재확인됐다(첫 번째 UPDATE). **신규 발견**: 같은 cron job의 **두 번째 UPDATE**(대기 2시간 초과 자동 취소, 지시문이 언급하지 않은 부분)가 `cancel_reason`을 세팅하는데, 이 컬럼도 라이브 `order_sessions`에 **존재하지 않는다**(재확인, 0건). 즉 이 cron job은 **두 UPDATE 문 전부**가 각자 다른 phantom 컬럼으로 크래시한다 — 첫 번째는 `called_at`/`no_show_at`(2개), 두 번째는 `cancel_reason`(1개), 총 3개.

## §7 실제 호출자 재확인 — 0건 (SQL/Flutter 전체)

`grep -rn "mark_no_show(" sql/migrations/*.sql`를 grant/revoke/comment/자기 정의 라인 제외하고 재실행한 결과, 유일하게 남는 것은 `0119_create_edge_function_integration.sql:237`의 문서 문자열(`'cancel_waiting() / mark_no_show()'`, 실제 호출 아님)뿐이다. `catchmenu_app/`/`apps/` 재검색 결과도 0건. 지시문의 "실제 호출자 0건" 주장을 정확히 재확인했다 — 두 오버로드 모두, 그리고 `0118`의 cron job도 현재 실행돼도 아무도 그 결과를 소비하지 않는 상태다(다만 cron job 자체는 10분마다 실제로 실행은 시도되어 매번 크래시할 것이라는 점에서 `mark_no_show()` 자체보다 위험도가 약간 높다 — cron은 "호출자"가 pg_cron 스케줄러 자신이므로).

## §8 통합 방향에 대한 함의 (판단 아님, Logic 단계로 이월)

- `0115`를 canonical 베이스로 삼는 것은 §2(선행 상태 제한)/§1.2(KDS 연동 존재 자체)의 설계 의도와 부합하지만, **`0050`이 갖고 있던 상태 검사(`session_status not in (...)`)를 반드시 복원해야 한다** — `0115`는 이 검사가 아예 없는 회귀 상태이므로, 단순히 phantom 컬럼만 고치면 "어떤 상태의 세션이든 무조건 NO_SHOW로 덮어쓸 수 있는" 더 위험한 함수가 배포된다.
- `pre_order_amount > 0` 게이트는 `pre_order_created_at is not null`로 1:1 치환 가능(§3) — 스키마 변경 없이 해결.
- `arrival_reliability_score` 페널티(§5)를 유지할지는 설계 문서가 침묵하므로 Human 결정 필요.
- KDS HOLD→CANCELLED 연동(§2)을 유지할지(900101 근거) 제거할지(900102/900103/906000/906010 근거)는 설계 문서 내부 모순 때문에 이 문서가 판단할 수 없다 — Human 결정 필요.
- `0118` cron job(§6)의 두 UPDATE 문 모두 이번 워크패킷의 수정 범위에 포함해야 자연스럽다 — `mark_no_show()`와 정확히 같은 개념(`ARRIVAL_PENDING`+무응답→`NO_SHOW`)을 자동화한 것이므로, 함수만 고치고 cron을 방치하면 자동화 경로가 여전히 깨진 채로 남는다.
- `confirm_arrival()`(§4)의 phantom 컬럼 3개는 이번 워크패킷 범위 밖으로 유지할지, 함께 묶을지는 Logic 단계에서 옵션으로 다뤄야 한다.

## §9 Open Questions

(a) KDS HOLD→CANCELLED 연동 유지 여부 — 900xxx 설계 문서 내부 모순(§2)으로 이 문서는 판단하지 않는다. Human 결정 필요.
(b) `arrival_reliability_score` -20 페널티를 통합본에 유지/조정/제거할지(§5) — 설계 문서 공백, Human 결정 필요.
(c) `confirm_arrival()`(§4)의 phantom 컬럼 3개를 이번 워크패킷에 포함할지, 별도 워크패킷으로 이월할지 — 범위 옵션, Logic 단계.
(d) `0115`의 나머지 6개 함수(`register_waiting`/`call_waiting_customer`/`pre_order_while_waiting`/`seat_waiting_customer`/`cancel_waiting`/`get_waiting_status`/`get_waiting_admin_view` 등)에도 유사한 phantom 컬럼이 더 있는지는 이번 문서에서 전수 감사하지 않았다 — §4의 발견이 시사하는 것처럼 `0115` 파일 전체의 phantom 컬럼 전수 조사가 별도로 필요할 수 있다.
(e) `0118` cron job의 두 번째 UPDATE(`WAITING`+2시간→`CANCELLED`, `cancel_reason` phantom)를 이번 워크패킷에 포함할지 — §8에서 포함이 자연스럽다고 봤으나 최종 판단은 Human.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` §2.4-2.5 — `mark_no_show()` 선행 상태/KDS 사이드이펙트 명시(단, §2의 내부 모순 발견분과 함께 읽을 것).
- `900102_ChangeContract...md`(F-003)/`900103_TestPlan...md`(TC-104)/`906010`/`906000`(영문판) — `900101`과 모순되는 "HOLD 유지" 명시, §2에서 신규 발견.

### Full Rules Required

- `sql/migrations/0050_create_waiting_queue_rpc.sql` — `mark_no_show()` 구버전(L445-574) 전체, 페널티 로직(L501-507).
- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` — `mark_no_show()` 신버전(L1333-1463), `confirm_arrival()`(L872-985, §4 신규 발견).
- `sql/migrations/0051_create_pre_order_rpc.sql` — `create_pre_order()`(L15-, 사전주문 금액의 실제 저장 위치), `get_pre_order_status()`.
- `sql/migrations/0118_create_schema_validation_update.sql` — `WAITING_SESSION_EXPIRE` cron job(L164-188).
- `catchmenu_pos.order_sessions` 라이브 스키마(35개 컬럼) 및 `chk_session_status`/`chk_session_arrival_reliability` CHECK 제약.

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.

### Excluded Rule Families

- `confirm_arrival()`의 phantom 컬럼 3개 자체 수정(§4/§9 (c)) — 범위 포함 여부만 Open Item, 이번 문서는 수정하지 않음.
- `0115`의 나머지 6개 함수 전수 감사(§9 (d)) — 이번 문서는 하지 않음.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0에서 도메인 오류(결제→대기열)를 정정하고 번호를 `600630`으로 확정했다. §1에서 두 오버로드 전문을 재확인했고, **지시문의 "0115가 ARRIVAL_PENDING만 허용"이 부정확함을 코드로 직접 반박했다** — 0115는 상태 검사 자체가 없는 회귀 상태다. §2에서 900xxx 설계 문서를 전담 조사한 결과, 선행 상태 제한은 0115를 지지하지만 **KDS 연동 부분은 900xxx 패키지 자체가 내부 모순**(900101 vs 900102/900103/906000/906010)임을 발견했다. §3에서 `pre_order_amount`가 boolean 용도로만 쓰인다는 것을 확인해 `pre_order_created_at is not null`로 스키마 변경 없이 대체 가능함을 확정했다. **§4에서 범위 밖(`confirm_arrival()`)의 phantom 컬럼 3개를 추가로 발견**해 별도 Open Item으로 기록했다. §5에서 페널티 로직(고정 -20점, 하한 0)을 정확히 재확인했다. §6에서 `0118` cron job에서 지시문이 언급하지 않은 세 번째 phantom(`cancel_reason`)을 신규 발견했다. §7에서 호출자 0건을 재확인했다. `600632_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600632_Logic.md] =====
# 600632_Logic_Mark_No_Show_Overload_And_Redesign.md

Status: Draft (재개, 600640 ACCEPT 완료로 BLOCKED 해제)
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## §0 이 문서의 작성 경위 — 기존 파일 존재 확인, 독립 재작성

`600632_Logic.md`(제목 없는 파일명)이 이미 존재했다 — Codex가 이전에 작성/중단한 것으로 보인다(Owner: Codex, Stage: "2 Design Logic" 표기). 지시에 따라 그 파일을 그대로 승계하지 않고, 이 문서를 **독립적으로 새로 작성**한다. Codex 버전은 참고 자료로만 취급했다 — 예를 들어 Codex 버전은 KDS 유예 정책을 "Open Decision"으로 남겨뒀으나, 이번 지시문은 그 정책을 6개 항목으로 이미 확정해 제시했으므로, 이 문서는 확정된 정책을 기준으로 처음부터 다시 설계했다. 파일명도 이 프로젝트의 `000002_Naming_Rules.md` §1.2.2 관례(`XXXXXX_DocumentType_Title_In_English_Title_Case.md`)에 맞춰 `600632_Logic_Mark_No_Show_Overload_And_Redesign.md`로 정정했다.

## Provisional Policy Notice — 이 설계는 잠정 정책이다 (Human, 2026-07-16)

**이 문서가 확정하는 KDS 유예 정책(§2)과 그 세부 값(유예 시간 등)은 지금 시점의 최선일 뿐 확정이 아니다.** 실제 라이브 운영 데이터가 쌓인 뒤 1~2년 내에 재검토될 잠정 정책으로 설계한다. 이 전제가 아래 두 원칙(§0.1)의 근거다 — 정책이 바뀔 것을 알고 있으므로 (a) 정책값은 코드가 아니라 조정 가능한 설정으로 두고, (b) 정책이 바뀌기 전 실제로 무슨 일이 일어났는지 완전히 추적 가능한 감사 기록을 남겨, 재조정 판단의 근거 데이터로 쓸 수 있게 한다.

### §0.1 설계 원칙 (Human 결정, 2026-07-16, 재논의 금지)

1. **하드코딩 금지**: 유예 시간(N분) 등 정책적 판단이 들어간 값은 전부 `store_settings` 같은 조정 가능한 설정으로 둔다(§11).
2. **완전한 감사 기록**: `mark_no_show()` 실행 시 `append_audit_record()`로 노쇼 판정 시각·사전주문 존재 여부·KDS 티켓의 유예 진입/만료/취소 각 단계 전이 시각·늦은 도착 시 복구 여부와 사유를 반드시 기록한다(§10).

## Change ID

`mark_no_show_overload_and_redesign`

## 재개 이력 — 이전 BLOCKED 상태와 해제 근거 (2026-07-16)

**이 섹션은 과거형 기록이다 — 아래 블로커는 해소됐고, 이 문서는 재개 가능 상태다.**

§12 (d)에서 이월했던 `call_waiting_customer()` 조사를 완료한 결과, 이 함수가 `mark_no_show()`의 진짜 데이터 선행조건(선행 상태 `ARRIVAL_PENDING`으로의 전이를 담당)임에도 자체적으로 깨져 있음을 확인했었다:

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:484-493`의 UPDATE가 `called_at`/`table_number`/`call_count` 3개 phantom 컬럼을 세팅하려 시도 — 실행 시점에 크래시, 한 번도 성공적으로 실행된 적이 없었다.
- 같은 함수가 `pre_order_amount`(§1.2/§3.4에서 phantom으로 확인된 컬럼)도 함께 참조.

**금지됐던 우회**: 이 phantom 컬럼들을 단순히 스키마에 추가하는 방식은 금지됐다(ChatGPT+제미나이 교차검증, 옵션 C 채택) — 이는 이 세션이 하루 종일 고쳐온 "함수가 기대하는 대로 컬럼을 무작정 맞춰주는" phantom 컬럼 문제를 새로 만드는 것과 동일했기 때문이다.

**채택됐던 방향**: 별도 선행 워크패킷 `600640_call_waiting_customer_contract_recovery`를 신설, `called_at`/`call_count`/`table_number`/`pre_order_amount` 4가지의 생산자 계약을 먼저 확정·검증했다.

### 해제 확인 — `600640` Stage 6 ACCEPT (2026-07-16)

`600640_call_waiting_customer_contract_recovery`가 Stage 6 ACCEPT로 완결·커밋됐다(`0160_call_waiting_customer_contract_recovery.sql`). 이 워크패킷의 실제 채택 결과는 이 문서가 §12 (d)에서 열어뒀던 4가지 질문에 다음과 같이 답했다 — 이 문서(`600632`)가 재개되면서 그대로 승계한다:

1. **`called_at`** → 신규 컬럼을 만들지 않고 `catchmenu_pos.session_events`에 `event_type='customer_called'` 이벤트로 기록(첫 호출 여부는 `from_status='WAITING'`, 재호출은 `from_status='ARRIVAL_PENDING'`으로 구분). "몇 번 호출됐는지"는 `session_events`에서 `count(*)`로 파생.
2. **핵심 발견 — `order_sessions.expires_at`(실존 컬럼) 재사용**: 호출 시점에 `wait_call_expire_minutes`(`store_settings`, canonical로 확정) 기반 만료 시각을 **스냅샷으로 계산해 `expires_at`에 저장**한다(재호출 시 재스냅샷). 이 컬럼이 이번 문서의 §8 재설계(아래)에 직접 쓰인다 — `called_at + N분` 계산을 노쇼 판정 시점에 매번 다시 할 필요 없이, 이미 계산되어 저장된 만료 시각을 그냥 비교만 하면 된다.
3. `table_number` → 세션에 영구 저장하지 않음(추가 보류 확정) — 응답/알림/이벤트 payload에만 `table_suggestion`으로 전달.
4. `pre_order_amount` → `orders.final_amount` 조인으로 계산, 세션에 직접 저장하지 않음.

**참고**: `600640`의 `600602_NavigationMap.md` 등록 기록에 "`0115` 소스 본문은 여전히 stale 상태이며 source-sync Open Item으로 이월됨"이라는 메모가 있다 — `0160`은 새 forward migration으로 라이브 함수를 교체했지만, `0115_create_waiting_pipeline_rpc.sql` 파일 자체의 본문 텍스트는 아직 갱신되지 않았다는 뜻이다. 이 문서(`600632`)가 Stage 4로 진행할 때 `mark_no_show()`도 같은 상황에 놓인다(구버전 본문이 `0115`에 남아있고, 실제 교체는 새 forward migration으로 이뤄질 가능성이 높음) — Stage 4 구현자가 `600640`의 소스 동기화 방식(§1.6 패턴)을 그대로 참고하되, `0115` 소스 동기화 자체는 이 문서의 결정 사항이 아니다.

아래 §1-§11은 이 재개 확정에 맞춰 갱신됐다(특히 §8) — 나머지(노쇼 정책, grace hold 정책, 캐노니컬 함수 설계, 감사 기록, 정책값 설정화)는 블로커와 무관하게 이미 확정돼 있던 내용이므로 그대로 유지한다.

## §1 배경 재확인 — 두 오버로드의 정확한 현재 상태 (`600631_Overview.md`에서 이미 라이브 검증됨, 이 문서는 그 결과를 전제로 인용)

### §1.1 `0050`(구) — `mark_no_show(uuid,uuid,uuid,text,uuid,text)`

선행 상태: `WAITING`/`ARRIVAL_PENDING` 둘 다 허용. `session_status='NO_SHOW'`, `arrival_reliability_score -20`(하한 0), `cancelled_at`/`updated_at` 갱신. KDS 연동 없음. 사용 컬럼 전부 라이브 실존(`600631_Overview.md` §1.1 재확인).

### §1.2 `0115`(신) — `mark_no_show(uuid,uuid,uuid,uuid,text,text)`

**상태 게이트 자체가 없다** — `v_session.id is null`(세션 없음)만 검사하고, 현재 `session_status`가 무엇이든(`SEATED`/`COMPLETED`도 포함) 무조건 `NO_SHOW`로 덮어쓴다. `chk_session_status` CHECK나 트리거로도 이 전이를 막지 않는다(`600631_Overview.md` §1.2에서 라이브로 재확인) — "`ARRIVAL_PENDING`만 허용하는 더 좁은 버전"이 아니라 "검사 자체가 없는 회귀"다. `no_show_at`/`pre_order_amount`/`called_at` 3개 phantom 컬럼 사용, 실행 시 즉시 크래시. `pre_order_amount > 0`이면 해당 주문의 `HOLD` 상태 KDS 티켓을 `CANCELLED`로 전환.

### §1.3 `0118`의 `WAITING_SESSION_EXPIRE` cron — phantom 컬럼 3개

`0118_create_schema_validation_update.sql:164-188`(재확인) — 2개 UPDATE 문으로 구성:
1. `ARRIVAL_PENDING` + `called_at < now()-15분` + `no_show_at IS NULL` → `NO_SHOW`(`called_at`/`no_show_at` phantom).
2. `WAITING` + `session_started_at < now()-2시간` → `CANCELLED`, `cancel_reason='AUTO_EXPIRE'`(`cancel_reason` phantom, `600631_Overview.md` §6에서 신규 발견).

### §1.4 실제 호출자 — 0건 (SQL/Flutter 전체 재확인)

두 오버로드, cron job 전부 실제 호출자 없음(`600631_Overview.md` §7).

## §2 900xxx 설계 문서 내부 모순 + 확정된 KDS 유예 정책 (통합 설계)

### §2.1 모순 재확인

`900101_Logic...md` §2.5는 "노쇼 시 사전주문 KDS 티켓을 즉시 `CANCELLED`"를 명시하는 반면, `900102`(ChangeContract)/`900103`(TestPlan)/`906000`(TestPlan 영문판)/`906010`(ChangeContract 영문판) 4개 문서는 전부 "`HOLD` 상태 그대로 유지, 미조리"를 명시한다 — 1개 문서 vs 4개 문서로 갈리며, 900xxx 패키지 자체가 내부적으로 결론을 내리지 못한 상태다(`600631_Overview.md` §2에서 전담 조사로 확인).

### §2.2 확정된 정책 — 두 문서의 모순을 통합한 제3의 설계 (Human 결정, ChatGPT+제미나이 교차검증, 재논의 금지)

어느 한쪽을 그대로 채택하지 않고, 다음 6개 항목으로 통합한다:

1. 대기 세션은 **즉시** `NO_SHOW`, 좌석/순번 **즉시** 해제.
2. 조리 전(`HOLD`) 사전주문 티켓은 **짧은 유예 상태**로 전환 — 기존 `kds_status` enum을 늘리지 않고 `hold_reason = 'NO_SHOW_GRACE'` + 신규 컬럼 `hold_expires_at`(타임스탬프)으로 표현.
3. 유예 만료 후 **자동 `CANCELLED`** — 조건부 UPDATE(`WHERE hold_reason='NO_SHOW_GRACE' AND hold_expires_at <= now()`)로 동시성 안전하게.
4. 유예 중 늦게 도착 시 **자동 복구 금지** — 직원 확인을 거쳐야 함.
5. `COOKING` 이후 상태는 이 규칙 적용 대상 아님 — 별도 운영 정책(`600570`의 COOKING 취소 정책과 동일한 경계).
6. 유예 시간(N분)은 하드코딩하지 않고 `store_settings` 등 매장 설정값으로(§11).

이 설계는 `900101`(즉시 취소)도 `900102`/`900103`/`906000`/`906010`(무기한 유지)도 그대로 채택하지 않는다 — "짧은 유예 후 자동 취소"라는 제3의 지점이며, §0의 Provisional Policy Notice가 이 타협적 성격을 명시적으로 인정한다.

## §3 `mark_no_show()` 캐노니컬 함수 설계

**[§8 재설계로 슈퍼시드됨, 2026-07-16]** 아래 §3.2-§3.6이 원래 `mark_no_show()` 본문에 직접 넣으려던 로직(세션 조회, 상태 게이트, 페널티 계산, KDS 유예 진입, UPDATE, 감사 기록)은 3계층 구조 재설계(§8)에 따라 공통 코어 `apply_no_show_transition()`(§8.1) 안으로 이전됐다 — `mark_no_show()`(§8.2) 자체는 이제 그 코어를 호출하는 얇은 wrapper다. 아래 §3.2-§3.6은 각 값/판단의 근거 자료로는 여전히 유효하므로 삭제하지 않고 보존한다(§4/§10에서도 계속 인용).

### §3.1 베이스 및 시그니처

`0115`를 시맨틱 베이스로 쓴다(§0.1 원칙과 별개로 이미 확정된 요소) — 신규 `p_actor_id`/`p_locale` 파라미터 구조, `catchmenu_common.build_error_response`/`build_success_response` 사용 관례가 `0050`보다 이 프로젝트의 현재 표준에 가깝다. 시그니처는 `0115`의 것을 그대로 유지: `mark_no_show(p_tenant_id, p_store_id, p_session_id, p_actor_id default null, p_locale default 'ko', p_correlation_id default null)`.

### §3.2 세션 조회 + phantom 컬럼 치환

```sql
select id, wait_number, session_status, guest_locale,
       pre_order_created_at,          -- pre_order_amount 대체(§3.4)
       arrival_reliability_score,      -- 0050 페널티 병합용(§3.5)
       expires_at                      -- 600640이 채운 호출-만료 스냅샷, 감사 기록용(§10.1)
into v_session
from catchmenu_pos.order_sessions
where id = p_session_id and store_id = p_store_id and tenant_id = p_tenant_id
for update;

if v_session.id is null then
  return catchmenu_common.build_error_response(
    p_error_key := 'waiting_session_not_found', ...
  );
end if;
```
`called_at`/`no_show_at`/`pre_order_amount` 전부 제거 — `600631_Overview.md` §1.2에서 확인한 대로 라이브에 존재하지 않는다.

### §3.3 신규 추가 — `ARRIVAL_PENDING` 전용 게이트

`0115`에는 원래 없던 검사다(§1.2에서 확인한 회귀를 여기서 복원 + 900xxx 설계 의도(§2.1, 선행 상태 제한 부분은 모순 없이 일치)에 맞춘다):
```sql
if v_session.session_status <> 'ARRIVAL_PENDING' then
  return catchmenu_common.build_error_response(
    p_error_key := 'session_not_markable',
    p_params := jsonb_build_object('current_status', v_session.session_status),
    ...
  );
end if;
```
`0050`은 `WAITING`도 허용했으나, `900101`의 상태-액션 매트릭스가 `WAITING`에는 `mark_no_show` 부적용(✗)을 명시하므로 채택하지 않는다 — 이 부분은 900xxx 문서 간 모순이 없는 지점이다(§2.1).

### §3.4 사전주문 존재 판정 — `pre_order_amount` → `pre_order_created_at is not null`

`600631_Overview.md` §3에서 이미 확인된 안전한 치환(Cursor 재확인 완료, 이 문서에서도 근거 유지): `mark_no_show()`의 `pre_order_amount` 사용은 전부 `> 0` boolean 게이트 용도뿐이었다(실제 금액 숫자값은 어디에도 노출되지 않음) — `v_session.pre_order_created_at is not null`로 완전 대체 가능, 스키마 변경도 추가 JOIN도 불필요.

### §3.5 `0050`의 `arrival_reliability_score` 페널티 병합

```sql
v_new_score := greatest(0, coalesce(v_session.arrival_reliability_score, 100) - 20);
```
`0050:501-507`(`600631_Overview.md` §5에서 정확히 재확인한 원문)을 그대로 이식 — 900xxx가 이 페널티에 침묵하므로(§2.1) 제거 근거가 없고, `create_pre_order()`의 `arrival_reliability_too_low` 게이트가 이 점수를 실제로 소비하는 살아있는 메커니즘이므로 보존한다.

### §3.6 `order_sessions` UPDATE

```sql
update catchmenu_pos.order_sessions
set
  session_status = 'NO_SHOW',
  arrival_reliability_score = v_new_score,
  cancelled_at = now(),      -- no_show_at 대신 기존 실존 컬럼 재사용
  updated_at = now()
where id = p_session_id;
```
좌석/순번 즉시 해제(§2.2 항목 1)는 `session_status = 'NO_SHOW'`로의 전이 자체가 `get_waiting_queue()`류 조회에서 이 세션을 대기열/좌석 후보에서 자동 제외시키는 방식으로 이미 달성된다고 판단한다(대기열 조회 함수들이 `session_status in ('WAITING','ARRIVAL_PENDING')`으로 필터링하는 기존 패턴, `0050:611-615` 등에서 확인) — 별도의 "해제" 필드나 함수 호출이 추가로 필요한지는 §12 Open Item으로 남긴다.

## §4 KDS 유예 정책 구현

### §4.1 신규 컬럼(스키마 변경, Stage 4 대상)

```sql
alter table catchmenu_kds.kds_tickets
  add column if not exists hold_expires_at timestamptz;
```
라이브 재확인 결과 `hold_expires_at`은 존재하지 않고, `hold_reason`은 이미 존재하는 자유 형식 `text` 컬럼으로 값에 대한 CHECK 제약이 없다(`chk_kds_status`만 존재하며 `hold_reason`은 대상이 아님, 라이브 재확인) — 따라서 `'NO_SHOW_GRACE'`/`'NO_SHOW_GRACE_EXPIRED'` 같은 값을 CHECK 확장 없이 자유롭게 쓸 수 있다. `kds_status`는 계속 `'HOLD'`를 유지하므로(§2.2 항목 2) `chk_kds_status` enum도 확장하지 않는다.

### §4.2 `mark_no_show()` 내 유예 진입 처리

```sql
if v_session.pre_order_created_at is not null then
  with graced as (
    update catchmenu_kds.kds_tickets kt
    set
      hold_reason = 'NO_SHOW_GRACE',
      hold_expires_at = now() + (v_grace_minutes || ' minutes')::interval,
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.tenant_id = p_tenant_id
      and kt.store_id = p_store_id
      and kt.kds_status = 'HOLD'
    returning kt.id, kt.hold_expires_at
  )
  select coalesce(jsonb_agg(id), '[]'::jsonb), count(*), max(hold_expires_at)
  into v_grace_ticket_ids, v_grace_ticket_count, v_grace_expires_at
  from graced;
end if;
```
`kds_status = 'CANCELLED'`로 즉시 전환하지 않는다(`0115`의 기존 동작과 다름, §2.2 항목 2/3의 확정 정책 반영) — `COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED` 상태 티켓은 이 UPDATE의 `kds_status = 'HOLD'` 조건에 의해 자동으로 영향받지 않는다(§2.2 항목 5). `returning`절로 유예 처리된 티켓 목록/개수/만료 시각을 확보해 §10의 감사 기록에 쓴다.

### §4.3 `v_grace_minutes`의 출처

하드코딩하지 않는다(§0.1 원칙 1) — §11에서 설정값으로 설계한다.

## §5 유예 만료 처리 — `expire_no_show_kds_hold()` 확정 (Human 결정, 2026-07-16, ChatGPT+제미나이 교차검증, 재논의 금지)

**확정, 이번 워크패킷에 포함한다.** §8.3의 `process_expired_no_shows()`와 동일한 패턴(`SKIP LOCKED` 배치 선택, 건별 실패 격리, 작은 배치 크기)을 `catchmenu_kds.kds_tickets`에 적용한다.

```sql
create or replace function catchmenu_kds.expire_no_show_kds_hold(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket_id uuid;
  v_order_id uuid;
  v_hold_expires_at timestamptz;
  v_business_day date;
  v_business_timezone text;
  v_audit_id uuid;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_ticket_id, v_order_id, v_hold_expires_at, v_business_day, v_business_timezone in
    select id, order_id, hold_expires_at, business_day, business_timezone
    from catchmenu_kds.kds_tickets
    where tenant_id = p_tenant_id and store_id = p_store_id
      and kds_status = 'HOLD' and hold_reason = 'NO_SHOW_GRACE'
      and hold_expires_at <= now()
    order by hold_expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      update catchmenu_kds.kds_tickets
      set kds_status = 'CANCELLED', cancelled_at = now(),
          hold_reason = 'NO_SHOW_GRACE_EXPIRED', updated_at = now()
      where id = v_ticket_id
        and kds_status = 'HOLD' and hold_reason = 'NO_SHOW_GRACE'
        and hold_expires_at <= now();

      if found then
        v_audit_id := catchmenu_audit.append_audit_record(
          p_tenant_id := p_tenant_id, p_store_id := p_store_id,
          p_audit_domain := 'kds', p_audit_type := 'no_show_grace_expired',
          p_audit_category := 'OPERATIONAL', p_actor_type := 'SYSTEM',
          p_subject_type := 'kds_ticket', p_subject_id := v_ticket_id,
          p_decision := 'CANCELLED',
          p_decision_payload := jsonb_build_object(
            'grace_expires_at', v_hold_expires_at, 'cancelled_at', now()
          ),
          p_before_state := jsonb_build_object('kds_status', 'HOLD', 'hold_reason', 'NO_SHOW_GRACE'),
          p_after_state := jsonb_build_object('kds_status', 'CANCELLED', 'hold_reason', 'NO_SHOW_GRACE_EXPIRED'),
          p_order_id := v_order_id, p_kds_ticket_id := v_ticket_id,
          p_correlation_id := p_correlation_id,
          p_business_day := v_business_day, p_business_timezone := v_business_timezone
        );
        v_processed := v_processed + 1;
      else
        -- 재확인 조건 불충족(동시 복구 등으로 이미 상태가 바뀜) — 실패로 집계, 예외 아님
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
      end if;
    exception when others then
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_ticket_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_ticket_ids', v_failed_ids
  );
end;
$$;
```
`process_expired_no_shows()`(§8.3)와 마찬가지로 `function`이라 내부 `COMMIT`이 불가능하므로 배치 전체의 행 잠금이 함수 호출 전체 동안 유지된다 — `p_batch_size` 기본값 100이 동일한 이유로 락 보유 시간을 제한한다.

### §5.1 `0118` cron 갱신 필요 (§8.4 확장)

§8.4가 `process_expired_no_shows()`를 매장별로 호출하도록 이미 갱신했으므로, 이 함수도 같은 방식으로 추가해야 한다 — `WAITING_SESSION_EXPIRE`와 `NO_SHOW_GRACE`는 서로 다른 테이블(`order_sessions` vs `kds_tickets`)의 서로 다른 타이머이므로 별도 루프로 추가한다(§8.4 diff 참조).

## §6 늦은 도착 복구 — `recover_no_show_grace_ticket()` 확정, 최소 형태 (Human 결정, 2026-07-16, ChatGPT+제미나이 교차검증, 재논의 금지)

**확정, 이번 워크패킷에 포함한다.** "`NO_SHOW_GRACE`는 임시 상태이므로 진입만 있고 빠져나갈 길이 없으면 안 된다"(ChatGPT)는 원칙에 따라, §5와 정확히 대칭적인 단순 조건부 UPDATE 하나로 최소화한다 — 재고/결제/좌석 재검증 같은 Saga 패턴은 채택하지 않는다.

**단위는 세션이 아니라 티켓이다** — 원래(구버전) §6 초안은 `p_session_id` 단위를 제안했으나, §5(`expire_no_show_kds_hold()`)가 티켓 단위로 동작하는 것과 대칭을 맞추기 위해 이 함수도 `p_kds_ticket_id` 단위로 확정한다. 한 세션에 유예 티켓이 여러 장이면 호출자가 티켓마다 반복 호출한다(세션 단위 일괄 wrapper는 "최소 형태" 범위 밖 — 필요해지면 별도 이월).

```sql
create or replace function catchmenu_kds.recover_no_show_grace_ticket(
  p_tenant_id uuid,
  p_store_id uuid,
  p_kds_ticket_id uuid,
  p_actor_id uuid default null,
  p_reason text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_kds, catchmenu_audit, catchmenu_common
as $$
declare
  v_ticket record;
  v_audit_id uuid;
begin
  -- §5의 만료 조건(hold_expires_at<=now())과 정확히 대칭적인 복구 조건
  -- (hold_expires_at>now()). 동시성은 아래 note 참조.
  update catchmenu_kds.kds_tickets
  set kds_status = 'HOLD', hold_reason = null, hold_expires_at = null, updated_at = now()
  where id = p_kds_ticket_id
    and tenant_id = p_tenant_id and store_id = p_store_id
    and kds_status = 'HOLD' and hold_reason = 'NO_SHOW_GRACE'
    and hold_expires_at > now()
  returning id, order_id, business_day, business_timezone
  into v_ticket;

  if v_ticket.id is null then
    -- 조건 불충족: 없는 티켓 / 이미 만료돼 CANCELLED됨 / 애초에 그레이스 상태가 아님을 구분
    select id, kds_status, hold_reason into v_ticket
    from catchmenu_kds.kds_tickets
    where id = p_kds_ticket_id and tenant_id = p_tenant_id and store_id = p_store_id;

    if v_ticket.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'kds_ticket_not_found',
        p_locale := p_locale, p_tenant_id := p_tenant_id,
        p_store_id := p_store_id, p_rpc_name := 'recover_no_show_grace_ticket'
      );
    elsif v_ticket.kds_status = 'CANCELLED' and v_ticket.hold_reason = 'NO_SHOW_GRACE_EXPIRED' then
      return catchmenu_common.build_error_response(
        p_error_key := 'no_show_grace_already_expired',
        p_locale := p_locale, p_tenant_id := p_tenant_id,
        p_store_id := p_store_id, p_rpc_name := 'recover_no_show_grace_ticket'
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'ticket_not_recoverable',
        p_params := jsonb_build_object(
          'current_status', v_ticket.kds_status, 'current_hold_reason', v_ticket.hold_reason
        ),
        p_locale := p_locale, p_tenant_id := p_tenant_id,
        p_store_id := p_store_id, p_rpc_name := 'recover_no_show_grace_ticket'
      );
    end if;
  end if;

  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_audit_domain := 'kds', p_audit_type := 'no_show_grace_recovered',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_subject_type := 'kds_ticket', p_subject_id := p_kds_ticket_id,
    p_decision := 'RECOVERED', p_decision_reason := p_reason,
    p_decision_payload := jsonb_build_object('recovered_at', now()),
    p_before_state := jsonb_build_object('kds_status', 'HOLD', 'hold_reason', 'NO_SHOW_GRACE'),
    p_after_state := jsonb_build_object('kds_status', 'HOLD', 'hold_reason', null),
    p_order_id := v_ticket.order_id, p_kds_ticket_id := p_kds_ticket_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_ticket.business_day, p_business_timezone := v_ticket.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_grace_recovered',
    p_data := jsonb_build_object('kds_ticket_id', p_kds_ticket_id, 'kds_status', 'HOLD'),
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

**직원 권한 검사**: §8.2의 `mark_no_show()`와 동일한 가정 — 게이트웨이 레벨 인증만으로 충분하다고 가정하고, 함수 내부 role 검사 필요 여부는 Stage 4 결정으로 이월한다(§12 (l)과 동일한 성격의 사안, 별도 항목 만들지 않고 (l)에 통합해 참조).

**동시성 재확인 — 자동 만료(§5)와 수동 복구(§6)가 동시 실행돼도 하나만 성공하는 이유**: 두 함수의 시간 조건(`hold_expires_at<=now()` vs `hold_expires_at>now()`)이 논리적으로 상호 배타적이라는 사실만으로는 완전한 증명이 되지 않는다 — 두 트랜잭션이 서로 다른 시점에 `now()`를 스냅샷하므로, `hold_expires_at`이 두 스냅샷 사이에 걸쳐 있는 극히 좁은 경계 순간이면 이론적으로 둘 다 "조건 충족"으로 시작할 수 있다. **실제 배타성을 보장하는 것은 시간 조건이 아니라 행 잠금과 `hold_reason='NO_SHOW_GRACE'`라는 공유 전제조건이다**: 두 UPDATE 모두 같은 티켓 행을 대상으로 하므로 먼저 도달한 트랜잭션이 행 잠금을 얻어 커밋하고, 그 시점에 `hold_reason`이 `'NO_SHOW_GRACE_EXPIRED'`(만료) 또는 `null`(복구)로 바뀐다. 나중에 도달한 트랜잭션은 잠금이 풀리길 기다렸다가 실행되지만, 그 시점엔 이미 `hold_reason <> 'NO_SHOW_GRACE'`이므로 자신의 WHERE 절(시간 조건과 무관하게 `hold_reason='NO_SHOW_GRACE'`를 공통으로 요구) 자체가 더 이상 만족되지 않아 0행에 그친다. 즉 표준 Postgres 행 잠금 직렬화가 실제 보장 메커니즘이고, 시간 조건의 논리적 배타성은 (경계 순간을 제외하면) 대체로 같은 결과를 내는 부가적 사실일 뿐이다 — 이 구분을 명시적으로 문서화한다.

## §7 `0050` 오버로드 DROP

```sql
drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);
```
확정된 요소(§1.2/§3.1이 이미 `0115` 시맨틱을 캐노니컬로 선택했으므로) — `600550`/`600560`/`600570`/`600580`이 반복해온 "구버전 오버로드 DROP" 패턴과 동일하게, 이번 워크패킷의 새 forward migration에 포함한다.

## §8 노쇼 처리 아키텍처 — 3계층 구조로 전면 재설계 (Human 결정, 2026-07-16, ChatGPT+제미나이 교차검증, 재논의 금지)

### §8.0 배경 — 이전 설계의 한계, 재설계 방향

이전 버전의 §8은 `0118` cron의 인라인 UPDATE를 `called_at+15분` 대신 `expires_at<=now()`로 단순화하는 데까지만 다뤘고, 그 과정에서 "cron이 `mark_no_show()`를 호출하지 않아 자동 만료 노쇼가 페널티/KDS 유예/감사 기록을 전혀 받지 못한다"는 구조적 비일관성을 발견해 Open Item으로 이월했었다(구 §8.2). 이 비일관성을 다음 3계층 구조로 **완전히 해소**한다 — 수동/자동 두 경로가 상태전이·KDS유예·감사·멱등성이라는 핵심 불변조건을 공유하는 하나의 내부 코어를 호출하도록 만든다:

1. **공통 내부 코어** `apply_no_show_transition()` — §8.1.
2. **수동 RPC** `mark_no_show()`(기존 이름 유지) — 코어의 얇은 wrapper로 재정의, §8.2.
3. **자동 배치 함수** `process_expired_no_shows()`(신규) — §8.3.
4. `0118` cron은 이 배치 함수 하나만 호출하도록 단순화 — §8.4.

**§3.2-§3.6이 이전에 `mark_no_show()` 본문 안에 직접 넣었던 로직(세션 조회, 상태 게이트, 페널티 계산, KDS 유예 진입, UPDATE, 감사 기록)은 이제 §8.1의 코어 안으로 이전된다.** §3은 그 로직이 어떤 값을 어떻게 계산하는지의 근거 자료로는 유효하지만, 실제 함수 본문의 위치는 §8.1이 최신·확정판이다(§3 상단에 교차 참조 추가).

### §8.1 공통 내부 코어 — `catchmenu_pos.apply_no_show_transition()`

Human 결정문의 파라미터 목록(`p_session_id, p_actor_type, p_actor_id, p_trigger_source, p_reason_code, p_correlation_id`)에 **`p_tenant_id`/`p_store_id`를 추가한다** — "기술적 함정 반영" 항목이 명시한 "tenant/store scope 제한 명시" 요구사항 때문이다. 이 코드베이스의 다른 모든 RPC(`mark_no_show()`/`call_waiting_customer()` 등)가 예외 없이 `p_tenant_id`/`p_store_id`를 명시적 WHERE 조건으로 받는 관례와도 일치한다 — 세션 조회를 통해 간접적으로 스코프를 유추하는 대신, 매 호출마다 명시적으로 스코프를 좁힌다.

**게이트 조건 정정(2026-07-16, Human 결정, 재논의 금지)**: `p_trigger_source`의 값 도메인을 `'STAFF'`/`'SYSTEM'`으로 확정한다 — 이전 초안의 `'MANUAL'`/`'AUTO_EXPIRE'`는 대체됐다(`p_actor_type`과 값이 겹치지만, `p_actor_type`은 감사 기록의 일반 actor 필드이고 `p_trigger_source`는 게이트 분기 자체에 쓰이는 결정적 파라미터라는 역할 차이가 있다 — Human 결정문이 명시한 그대로 유지). 게이트는 더 이상 모든 호출자에 동일하게 적용되지 않는다:
- `p_trigger_source = 'STAFF'` — `session_status='ARRIVAL_PENDING'`만 요구. `expires_at` 조건 없음 — 직원은 현장 판단 근거로 유예시간 전에도 즉시 처리 가능(§3.3의 원래 재량권을 그대로 보존).
- `p_trigger_source = 'SYSTEM'` — `session_status='ARRIVAL_PENDING' AND expires_at<=now()` 둘 다 요구. 자동화는 시간 조건 외엔 판단 근거가 없으므로 반드시 만료돼야 한다.

KDS 유예 진입/감사 기록/멱등성 반환 등 이후 로직은 `p_trigger_source`와 무관하게 완전히 동일하다 — 갈라지는 지점은 이 게이트 조건뿐이다.

**§8.1/§10.1 통합 확정(2026-07-16, Human 결정, ChatGPT "B+ 절충안" 채택, 재논의 금지)**: §8.1(실제 코드)을 canonical로 유지하되, §10.1이 먼저 제안했던 아래 3가지를 §8.1에 통합한다 — 단 "`order_sessions` 전체 행 스냅샷"은 채택하지 않는다(감사 로그가 사실상 두 번째 소스오브트루스가 되는 것을 방지, `append_audit_record()`의 append-only 원칙과도 무관하지만 불필요한 저장 비대화를 피함):
1. `p_before_state`/`p_after_state`에 `session_status` 전이(`'ARRIVAL_PENDING'`→`'NO_SHOW'`)를 명시적으로 포함.
2. 실제로 바뀐 핵심 필드만 diff로 포함 — `arrival_reliability_score`(이전값/이후값), KDS 티켓 `hold_reason`(`null`→`'NO_SHOW_GRACE'`, 해당 시). 전체 행이 아니라 이 필드들만.
3. `p_business_day`/`p_business_timezone`을 `append_audit_record()`에 명시적으로 전달 — **재계산하지 않고 `order_sessions`에 이미 저장된 값을 그대로 재사용**한다(계산 방식 통일 원칙: `business_day`는 세션 생성 시점에 이 프로젝트의 canonical 방식으로 이미 확정된 값이므로, `apply_no_show_transition()`이 `timezone('Asia/Seoul', now())::date` 같은 방식으로 별도 재계산하면 세션 생성 시점과 노쇼 판정 시점 사이에 영업일 경계가 달라질 수 있는 여지가 생긴다 — 저장된 값을 그대로 신뢰하는 것이 유일하게 정확한 방법).

명시적으로 하지 않는 것: `order_sessions` 전체 컬럼 스냅샷, 감사 로그 UPDATE(append-only 재확인), 수동/자동 경로별로 다른 로그 스키마(`actor_type`/`trigger_source`/`reason_code`로만 구분하고 이벤트 구조 자체는 동일하게 유지 — 이미 §8.1의 단일 `apply_no_show_transition()` 코어가 이를 보장한다).

```sql
create or replace function catchmenu_pos.apply_no_show_transition(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_type text,              -- 'STAFF' | 'SYSTEM' (감사 기록용 일반 actor 필드)
  p_actor_id uuid,
  p_trigger_source text,          -- 'STAFF' | 'SYSTEM' (게이트 분기를 직접 결정)
  p_reason_code text default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_store,
                  catchmenu_audit, catchmenu_common
as $$
declare
  v_session record;
  v_old_score int;
  v_grace_minutes int;
  v_grace_ticket_ids jsonb;
  v_grace_ticket_count int;
  v_grace_expires_at timestamptz;
  v_audit_id uuid;
begin
  if p_trigger_source not in ('STAFF', 'SYSTEM') then
    return catchmenu_common.build_error_response(
      p_error_key := 'invalid_trigger_source',
      p_params := jsonb_build_object('trigger_source', p_trigger_source),
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'apply_no_show_transition'
    );
  end if;

  -- before_state용: UPDATE가 덮어쓰기 전의 신뢰도 점수를 확보한다
  -- (RETURNING은 UPDATE *이후* 값만 주므로, 이전 값은 별도로 조회해야 한다).
  select arrival_reliability_score
  into v_old_score
  from catchmenu_pos.order_sessions
  where id = p_session_id and tenant_id = p_tenant_id and store_id = p_store_id;

  -- 조건부 원자적 전이 — 수동/자동 경쟁 방지 + 멱등성의 기반.
  -- 게이트는 trigger_source에 따라 차등 적용된다(Human 결정, §3.3의 직원
  -- 즉시 처리 재량권을 보존): STAFF는 상태만, SYSTEM은 상태+만료시각 둘 다.
  update catchmenu_pos.order_sessions
  set
    session_status = 'NO_SHOW',
    arrival_reliability_score = greatest(0, coalesce(arrival_reliability_score, 100) - 20),
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id
    and session_status = 'ARRIVAL_PENDING'
    and (
      p_trigger_source = 'STAFF'
      or (p_trigger_source = 'SYSTEM' and expires_at <= now())
    )
  returning
    id, wait_number, guest_locale, pre_order_created_at, order_id,
    expires_at as original_call_expires_at,
    arrival_reliability_score as new_score,
    business_day, business_timezone
  into v_session;

  if v_session.id is null then
    -- 조건 불충족: 진짜 오류인지, 멱등 재시도(이미 처리됨)인지 구분한다.
    select id, session_status into v_session
    from catchmenu_pos.order_sessions
    where id = p_session_id and tenant_id = p_tenant_id and store_id = p_store_id;

    if v_session.id is null then
      return catchmenu_common.build_error_response(
        p_error_key := 'waiting_session_not_found',
        p_locale := p_locale, p_tenant_id := p_tenant_id,
        p_store_id := p_store_id, p_rpc_name := 'apply_no_show_transition'
      );
    elsif v_session.session_status = 'NO_SHOW' then
      -- 멱등: 수동/자동 경쟁에서 진 쪽이거나, 재시도(cron 재실행 등) — 오류 아님.
      return catchmenu_common.build_success_response(
        p_message_key := 'no_show_already_applied',
        p_data := jsonb_build_object('session_id', p_session_id, 'idempotent', true),
        p_locale := p_locale, p_correlation_id := p_correlation_id
      );
    else
      return catchmenu_common.build_error_response(
        p_error_key := 'session_not_markable',
        p_params := jsonb_build_object('current_status', v_session.session_status),
        p_locale := p_locale, p_tenant_id := p_tenant_id,
        p_store_id := p_store_id, p_rpc_name := 'apply_no_show_transition'
      );
    end if;
  end if;

  -- KDS 유예 진입 (§4.2와 동일한 로직, 코어로 이전)
  if v_session.pre_order_created_at is not null then
    select coalesce(ss.no_show_kds_grace_minutes, 15)
    into v_grace_minutes
    from catchmenu_store.store_settings ss
    where ss.tenant_id = p_tenant_id and ss.store_id = p_store_id;
    v_grace_minutes := coalesce(v_grace_minutes, 15);

    with graced as (
      update catchmenu_kds.kds_tickets kt
      set
        hold_reason = 'NO_SHOW_GRACE',
        hold_expires_at = now() + (v_grace_minutes || ' minutes')::interval,
        updated_at = now()
      from catchmenu_pos.orders o
      where o.session_id = p_session_id
        and kt.order_id = o.id
        and kt.tenant_id = p_tenant_id
        and kt.store_id = p_store_id
        and kt.kds_status = 'HOLD'
      returning kt.id, kt.hold_expires_at
    )
    select coalesce(jsonb_agg(id), '[]'::jsonb), count(*), max(hold_expires_at)
    into v_grace_ticket_ids, v_grace_ticket_count, v_grace_expires_at
    from graced;
  end if;

  -- 감사 기록 (§10.1 통합 완료 — before/after state + business_day/timezone 포함)
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_audit_domain := 'waiting', p_audit_type := 'no_show_marked',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type, p_actor_id := p_actor_id,
    p_subject_type := 'order_session', p_subject_id := p_session_id,
    p_decision := 'COMPLETED',
    p_decision_payload := jsonb_build_object(
      'trigger_source', p_trigger_source,
      'reason_code', p_reason_code,
      'no_show_determined_at', now(),
      'original_call_expires_at', v_session.original_call_expires_at,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'kds_grace_ticket_ids', v_grace_ticket_ids,
      'kds_grace_ticket_count', v_grace_ticket_count,
      'kds_grace_expires_at', v_grace_expires_at,
      'arrival_reliability_score_new', v_session.new_score
    ),
    p_before_state := jsonb_build_object(
      'session_status', 'ARRIVAL_PENDING',
      'arrival_reliability_score', v_old_score,
      'kds_ticket_hold_reason', null
    ),
    p_after_state := jsonb_build_object(
      'session_status', 'NO_SHOW',
      'arrival_reliability_score', v_session.new_score,
      'kds_ticket_hold_reason', case when v_grace_ticket_count > 0 then 'NO_SHOW_GRACE' else null end
    ),
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id,
    p_business_day := v_session.business_day,
    p_business_timezone := v_session.business_timezone
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'no_show_applied',
    p_data := jsonb_build_object(
      'session_id', p_session_id, 'idempotent', false,
      'arrival_reliability_score', v_session.new_score,
      'kds_grace_ticket_count', v_grace_ticket_count
    ),
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

**§3.3 재량권 보존 확인(§12 (k) 해소, 상세는 §12 (k) 참조)**: 기존 §3.3은 `session_status <> 'ARRIVAL_PENDING'`만 검사했고 타이머 만료 여부는 검사하지 않았다 — 직원이 호출 즉시("고객이 전화로 못 온다고 했다") 바로 노쇼 처리를 할 수 있었다. `p_trigger_source = 'STAFF'` 분기가 정확히 이 재량권을 그대로 보존한다(`expires_at` 조건 없음) — 더 이상 동작 변화가 아니다. 시간 조건이 실제로 추가되는 쪽은 `p_trigger_source = 'SYSTEM'`(§8.3의 자동 배치)뿐이며, 이는 애초에 §3.3 시점에는 존재하지도 않았던 새 자동 경로이므로 "기존 동작 대비 변화"라는 표현 자체가 성립하지 않는다.

### §8.2 수동 RPC — `mark_no_show()` (기존 이름/시그니처 유지, §3.1 슈퍼시드)

```sql
create or replace function catchmenu_pos.mark_no_show(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common
as $$
begin
  -- 직원 권한 검사: 이 RPC 자체가 STAFF 전용 경로(REST/RPC 게이트웨이 레벨에서
  -- 이미 인증된 직원 세션만 호출 가능하다고 가정) — 함수 내부에서의 추가 role
  -- 검사 필요 여부는 Stage 4 결정 사항으로 이월한다(§12 (l)).
  return catchmenu_pos.apply_no_show_transition(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id, p_session_id := p_session_id,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_trigger_source := 'STAFF', p_reason_code := null,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```
**재확인**: `p_trigger_source := 'STAFF'`(구 초안의 `'MANUAL'`에서 정정) — §8.1 게이트가 정확히 이 값을 보고 `expires_at` 조건 없이 즉시 처리 분기를 타도록 만드는 유일한 지점이다. `p_actor_type`도 `'STAFF'`로 별도 전달되지만, 게이트 자체는 `p_trigger_source`만 본다(§8.1). 확정 신뢰도 페널티(-20)는 §8.1의 코어에 이미 내장돼 있으므로 이 wrapper는 별도로 계산하지 않는다.

### §8.3 자동 배치 함수 — `catchmenu_pos.process_expired_no_shows()` (신규)

```sql
create or replace function catchmenu_pos.process_expired_no_shows(
  p_tenant_id uuid,
  p_store_id uuid,
  p_batch_size int default 100,
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common
as $$
declare
  v_session_id uuid;
  v_result jsonb;
  v_processed int := 0;
  v_failed int := 0;
  v_failed_ids jsonb := '[]'::jsonb;
begin
  for v_session_id in
    select id
    from catchmenu_pos.order_sessions
    where tenant_id = p_tenant_id and store_id = p_store_id
      and session_status = 'ARRIVAL_PENDING' and expires_at <= now()
    order by expires_at asc
    limit p_batch_size
    for update skip locked
  loop
    begin
      v_result := catchmenu_pos.apply_no_show_transition(
        p_tenant_id := p_tenant_id, p_store_id := p_store_id, p_session_id := v_session_id,
        p_actor_type := 'SYSTEM', p_actor_id := null,
        p_trigger_source := 'SYSTEM', p_reason_code := 'WAIT_CALL_EXPIRED',
        p_correlation_id := p_correlation_id
      );
      if coalesce((v_result->>'success')::boolean, false) then
        v_processed := v_processed + 1;
      else
        v_failed := v_failed + 1;
        v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
      end if;
    exception when others then
      -- 건별 실패 격리: BEGIN/EXCEPTION 블록이 암묵적 SAVEPOINT를 만들어
      -- 이 행의 실패가 배치의 나머지 행 처리를 막지 않는다.
      v_failed := v_failed + 1;
      v_failed_ids := v_failed_ids || jsonb_build_array(v_session_id);
    end;
  end loop;

  return jsonb_build_object(
    'success', true,
    'processed_count', v_processed,
    'failed_count', v_failed,
    'failed_session_ids', v_failed_ids
  );
end;
$$;
```

**락 보유 범위에 대한 주의(기술적 함정)**: 이 함수는 PL/pgSQL `function`이므로(`procedure`가 아니므로) 내부에서 `COMMIT`을 실행할 수 없다 — 건별 실패 격리는 `EXCEPTION` 블록의 암묵적 SAVEPOINT로만 이뤄지고, `FOR UPDATE SKIP LOCKED`로 잠근 배치 전체의 행 잠금은 이 함수 호출 전체(하나의 트랜잭션)가 끝날 때까지 유지된다 — 건별 커밋이 아니다. `p_batch_size` 기본값 100이 이 락 보유 시간을 짧게 유지하는 실질적 안전장치다(Human 결정문의 "작은 배치로 나누고" 요구사항의 근거).

**크론 중복 실행 방지**: 별도 전역 advisory lock이 필요 없다 — 두 cron 실행이 겹치더라도 `SKIP LOCKED`가 이미 다른 트랜잭션이 잠근 행을 자동으로 건너뛰므로 중복 처리가 발생하지 않는다.

**재확인**: `p_trigger_source := 'SYSTEM'`(구 초안의 `'AUTO_EXPIRE'`에서 정정) — §8.1 게이트가 이 값을 보고 `expires_at<=now()` 조건까지 함께 요구하는 분기를 타도록 만든다. 배치 선택 쿼리(line 461, `and expires_at <= now()`)가 이미 만료된 세션만 골라오므로 대부분의 경우 코어의 재검증은 통과하지만, 이 재검증이 없다면(코어가 `p_trigger_source`를 무시했다면) 이론상 배치 선택과 코어 실행 사이의 극히 짧은 간극에서도 시간 조건이 강제되지 않았을 것이다 — 이중 방어가 의도한 대로 작동한다.

### §8.4 `0118` cron 변경 — `process_expired_no_shows()` + `expire_no_show_kds_hold()` 매장별 호출로 단순화

원래 cron SQL(`0118:164-177`, 첫 번째 UPDATE)은 tenant/store 필터 없이 테이블 전체를 스캔하는 단일 UPDATE였다 — 이 시스템이 멀티테넌트이므로, `process_expired_no_shows()`가 `p_tenant_id`/`p_store_id`를 요구하는 이상 cron 쪽에서 만료 세션이 있는 매장 목록을 먼저 뽑아 매장별로 호출해야 한다. §5 확정에 따라 `expire_no_show_kds_hold()`도 같은 방식으로 추가한다 — 두 함수는 서로 다른 테이블(`order_sessions` vs `kds_tickets`)의 서로 다른 타이머를 처리하므로 별도 루프로 둔다:

```sql
do $$
declare
  r record;
begin
  -- 웨이팅 세션 자동 노쇼 (§8.1-§8.3)
  for r in
    select distinct tenant_id, store_id
    from catchmenu_pos.order_sessions
    where session_status = 'ARRIVAL_PENDING' and expires_at <= now()
  loop
    perform catchmenu_pos.process_expired_no_shows(
      p_tenant_id := r.tenant_id, p_store_id := r.store_id, p_batch_size := 100
    );
  end loop;

  -- KDS 유예 티켓 자동 만료 (§5)
  for r in
    select distinct tenant_id, store_id
    from catchmenu_kds.kds_tickets
    where kds_status = 'HOLD' and hold_reason = 'NO_SHOW_GRACE' and hold_expires_at <= now()
  loop
    perform catchmenu_kds.expire_no_show_kds_hold(
      p_tenant_id := r.tenant_id, p_store_id := r.store_id, p_batch_size := 100
    );
  end loop;
end $$;
```
이 `do` 블록이 `0118`의 `WAITING_SESSION_EXPIRE` cron 정의(`$sql$...$sql$`) 안 첫 번째 UPDATE를 대체한다. `called_at`/`no_show_at` phantom 컬럼은 더 이상 어디에서도 참조되지 않는다 — 두 배치 함수 모두 각자의 실존 타임스탬프 컬럼(`order_sessions.expires_at`, `kds_tickets.hold_expires_at`)만 본다.

### §8.5 해소됨 — cron 인라인 UPDATE와 `mark_no_show()`의 불일치 (구 §8.2)

**§8.0-§8.4의 3계층 구조로 완전히 해소됐다.** 이제 수동 경로(§8.2)와 자동 경로(§8.3)가 동일한 코어(§8.1)를 호출하므로, 트리거 소스와 무관하게 신뢰도 페널티/KDS 유예 진입/감사 기록이 항상 함께 적용된다 — 더 이상 별도의 Open Item이 아니다.

### §8.6 두 번째 UPDATE(순수 `WAITING` 2시간 자동취소) — 변경 없음, 별도 개념

```sql
-- 변경 전(두 번째 UPDATE)
UPDATE catchmenu_pos.order_sessions
SET session_status = 'CANCELLED', cancelled_at = now(), cancel_reason = 'AUTO_EXPIRE'
WHERE session_status = 'WAITING' AND session_started_at < now() - interval '2 hours';
```
이 블록은 **노쇼가 아니다** — 아직 한 번도 호출되지 않은(`WAITING` 상태 그대로인) 세션이 2시간 넘게 방치된 경우의 별도 자동 취소 정책이며, §8.0-§8.5의 3계층 구조(호출 이후의 노쇼 판정)와는 다른 문제다. `cancel_reason`은 대응 컬럼이 없으므로 단순 제거(`session_status`/`cancelled_at`만 남김)가 가장 좁은 수정이다 — `cancel_reason`이라는 개념 자체를 남기고 싶다면 `catchmenu_ledger.events`류 이벤트 테이블에 `event_payload`로 기록하는 방식(`600580_Logic.md` §4가 `reconciliation_status` 신규 값 대신 택했던 것과 동일한 패턴)으로 대체 가능 — 이 문서는 후자를 권고하되 확정하지 않는다.

## §9 `confirm_arrival()` — 이번 범위 밖 확정

`confirm_arrival()`(`0115`)의 phantom 컬럼 3개(`pre_order_amount`/`table_number`/`arrival_confirmed_at`, `600631_Overview.md` §4에서 신규 발견)는 **이번 워크패킷 범위 밖으로 확정**한다 — `mark_no_show()`와 이름은 인접하지만 다른 함수이며, 이 문서가 임의로 범위를 넓히지 않는다(지시문의 명시적 확정 사항). 별도 워크패킷 Open Item으로 이월(§12).

## §10 감사 기록 설계 (§0.1 원칙 2의 구체화)

`append_audit_record()`의 실제 파라미터 목록을 라이브로 재확인했다(`pg_get_function_arguments`) — `p_tenant_id`/`p_store_id`/`p_audit_domain`/`p_audit_type`/`p_audit_category`/`p_actor_type`/`p_actor_id`/`p_subject_type`/`p_subject_id`/`p_decision`/`p_decision_reason`/`p_decision_payload`/`p_before_state`/`p_after_state`/`p_session_id`/`p_order_id`/`p_kds_ticket_id`/`p_correlation_id`/`p_business_day`/`p_business_timezone` 등 — 아래 설계는 전부 실존 파라미터만 사용한다.

### §10.1 [§8.1에 통합 완료, 2026-07-16] — 이 섹션은 통합 이력 기록용으로만 보존

**이 섹션의 감사 기록 설계는 더 이상 별도 구현 대상이 아니다.** Human 결정(ChatGPT "B+ 절충안")에 따라 §8.1의 `apply_no_show_transition()` 코어가 이 섹션이 제안했던 `p_before_state`/`p_after_state`/`p_business_day`/`p_business_timezone`을 전부 흡수했다 — `no_show_determined_at`/`original_call_expires_at`/`had_pre_order`/`kds_grace_ticket_ids`/`kds_grace_ticket_count`/`kds_grace_expires_at`/`arrival_reliability_score_new`는 §8.1의 `p_decision_payload`에, `session_status`/`arrival_reliability_score`/KDS `hold_reason` 전이는 §8.1의 `p_before_state`/`p_after_state`에 그대로 들어 있다. 아래는 원래 제안이었던 원문을 이력으로만 남긴다(Stage 4는 §8.1을 구현하며, 이 섹션을 별도로 구현하지 않는다):

```sql
-- [이력 보존용 원안 — §8.1로 통합 완료, 실제 구현 대상 아님]
v_audit_id := catchmenu_audit.append_audit_record(
  p_tenant_id := p_tenant_id, p_store_id := p_store_id,
  p_audit_domain := 'waiting', p_audit_type := 'no_show_marked',
  p_audit_category := 'OPERATIONAL',
  p_actor_type := 'STAFF', p_actor_id := p_actor_id,
  p_subject_type := 'order_session', p_subject_id := p_session_id,
  p_decision := 'COMPLETED',
  p_decision_payload := jsonb_build_object(
    'no_show_determined_at', now(),
    'original_call_expires_at', v_session.expires_at,
    'had_pre_order', v_session.pre_order_created_at is not null,
    'kds_grace_ticket_ids', v_grace_ticket_ids,
    'kds_grace_ticket_count', v_grace_ticket_count,
    'kds_grace_expires_at', v_grace_expires_at,
    'arrival_reliability_score_new', v_new_score
  ),
  p_before_state := jsonb_build_object(
    'session_status', v_session.session_status,
    'arrival_reliability_score', v_session.arrival_reliability_score
  ),
  p_after_state := jsonb_build_object(
    'session_status', 'NO_SHOW', 'arrival_reliability_score', v_new_score
  ),
  p_session_id := p_session_id,
  p_correlation_id := p_correlation_id,
  p_business_day := v_session.business_day,
  p_business_timezone := v_session.business_timezone
);
```

**§8.1과의 차이(통합 과정에서 정정된 부분)**: 위 원안은 `v_session.session_status`/`v_session.arrival_reliability_score`를 `before_state`에 그대로 쓰려 했으나, 이는 `UPDATE ... RETURNING`이 이미 갱신된 *이후* 값을 담고 있다는 점을 놓친 설계였다 — `v_session`은 UPDATE 이후의 레코드이므로 `session_status`는 이미 `'NO_SHOW'`, `arrival_reliability_score`는 이미 새 점수다. §8.1은 이 오류를 고쳐 (a) `session_status`의 이전 값은 게이트가 항상 `'ARRIVAL_PENDING'`만 통과시킴을 이용해 리터럴로 명시하고, (b) `arrival_reliability_score`의 이전 값은 UPDATE 전에 별도 조회(`v_old_score`)로 확보했다. KDS `hold_reason` before/after도 이번 통합에서 새로 추가됐다(원안에는 없었음).

`no_show_at`이 phantom이라 `order_sessions`에 직접 남길 수 없는 "노쇼 판정 시각"은 §8.1의 감사 기록 `no_show_determined_at`(=`now()`)이 대신 보존한다. `original_call_expires_at`을 남기는 이유는 §0의 Provisional Policy 원칙과 직결된다 — `now() - original_call_expires_at`은 `wait_call_expire_minutes`의 실제 적정 값을 나중에 재조정할 때 필요한 실데이터다.

### §10.2 유예 만료/취소 기록 — §5가 포함될 경우

`expire_no_show_kds_hold()`가 채택되면(§5), 만료 처리된 각 티켓에 대해 개별 감사 기록:
```sql
for v_expired in
  update catchmenu_kds.kds_tickets
  set kds_status = 'CANCELLED', cancelled_at = now(),
      hold_reason = 'NO_SHOW_GRACE_EXPIRED', updated_at = now()
  where tenant_id = p_tenant_id and store_id = p_store_id
    and kds_status = 'HOLD' and hold_reason = 'NO_SHOW_GRACE'
    and hold_expires_at <= now()
  returning id, order_id, hold_expires_at
loop
  perform catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_audit_domain := 'kds', p_audit_type := 'no_show_grace_expired',
    p_audit_category := 'OPERATIONAL', p_actor_type := 'SYSTEM',
    p_subject_type := 'kds_ticket', p_subject_id := v_expired.id,
    p_decision := 'CANCELLED',
    p_decision_payload := jsonb_build_object(
      'grace_expires_at', v_expired.hold_expires_at, 'cancelled_at', now()
    ),
    p_before_state := jsonb_build_object('kds_status', 'HOLD', 'hold_reason', 'NO_SHOW_GRACE'),
    p_after_state := jsonb_build_object('kds_status', 'CANCELLED', 'hold_reason', 'NO_SHOW_GRACE_EXPIRED'),
    p_order_id := v_expired.order_id, p_kds_ticket_id := v_expired.id,
    p_correlation_id := p_correlation_id
  );
end loop;
```
§5가 이월되면 이 감사 기록 설계도 함께 이월된다 — 정책 구현과 감사 요구사항은 분리해서 감사만 먼저 만들지 않는다(구현되지 않은 전이는 기록할 대상 자체가 없으므로).

### §10.3 늦은 도착 복구 기록 — §6이 포함될 경우

복구 RPC가 채택되면, `p_decision`을 `'RECOVERED'`/`'REJECTED'` 등으로, `p_decision_reason`에 직원이 입력한 사유를 남긴다. §6이 이월되면 이 기록도 함께 이월된다.

## §11 정책값 설정화 (§0.1 원칙 1의 구체화)

```sql
alter table catchmenu_store.store_settings
  add column if not exists no_show_kds_grace_minutes int not null default 15;
```
`0049_create_store_settings_rpc.sql`이 이미 `pre_order_lead_minutes`/`pre_order_expire_minutes`(둘 다 `int not null`, `chk_pre_order_minutes` CHECK로 양수 보장) 패턴을 쓰고 있음을 확인했다 — 동일한 명명/타입 관례를 따른다. 기본값 15분은 지시문 예시(§2.2 항목 6 문맥) 참고용 추정치이며, 실제 값은 Human이 최종 결정할 사안이다(§12 Open Item) — §0의 Provisional Policy Notice가 강조하듯 이 값 자체도 잠정적이다.

**재개 시점 재확인 — `wait_call_expire_minutes`와 병합하지 않는다.** `600640`이 `store_settings.wait_call_expire_minutes`(기존 실존 컬럼, `600640`이 canonical로 확정)를 "호출 후 응답 대기 시간" 용도로 채택했다(§8.1의 `expires_at` 스냅샷이 이 값 기반). 이 두 설정값은 서로 다른 국면을 다루므로 하나로 합치지 않는다:
- `wait_call_expire_minutes` — **호출 → 노쇼 판정**까지의 시간(고객이 얼마나 오래 응답하지 않으면 노쇼로 볼지). §8.1의 `expires_at <= now()` 비교가 이 값을 이미 소비한다.
- `no_show_kds_grace_minutes`(이 섹션, 신규) — **노쇼 판정 → KDS 티켓 자동 취소**까지의 시간(§2.2 항목 2/3, 노쇼가 확정된 *이후*의 조리 티켓 유예 기간). `mark_no_show()`가 실행되는 시점, 즉 `wait_call_expire_minutes` 타이머가 이미 만료된 *다음*에 시작되는 완전히 별개의 후속 타이머다.

두 값이 같은 숫자를 쓸 이유가 없다 — "고객이 얼마나 기다리면 노쇼로 볼지"와 "노쇼 이후 조리 중이던 음식을 얼마나 더 붙잡고 있을지"는 서로 다른 운영 판단이며, 900xxx나 이번 워크패킷 어디에도 둘을 연동해야 한다는 근거가 없다.

## §12 Open Items / 범위 결정 필요 항목

(a) **[확정, Human 결정, 2026-07-16]** §5 `expire_no_show_kds_hold()`를 이번 워크패킷에 포함한다 — 더 이상 Open Item 아님. `process_expired_no_shows()`(§8.3)와 동일한 배치 패턴으로 설계 완료(§5), `0118` cron이 매장별로 호출하도록 §8.4도 함께 갱신했다.
(b) **[확정, Human 결정, 2026-07-16]** §6 `recover_no_show_grace_ticket()`을 이번 워크패킷에 포함한다 — 더 이상 Open Item 아님. §5와 대칭적인 단일 조건부 UPDATE로 최소 형태 설계 완료(§6), 단위는 세션이 아니라 티켓으로 확정(§5와의 대칭을 위해 원래 초안에서 변경).
(c) `confirm_arrival()`의 phantom 컬럼 3개(§9) — 이번 범위 밖으로 확정, 별도 워크패킷 이월 확정.
(d) **[해소됨, 600640 Stage 6 ACCEPT, 2026-07-16]** §8의 `call_waiting_customer()` phantom 컬럼(`called_at`/`table_number`/`call_count`/`pre_order_amount`) 문제는 `600640_call_waiting_customer_contract_recovery`가 `0160_call_waiting_customer_contract_recovery.sql`로 해소했다 — `session_events`(`'customer_called'` 이벤트) + `order_sessions.expires_at`(호출-만료 스냅샷, 실존 컬럼) 조합으로 대체됐고, 이 문서 §8.1이 그 결과를 반영해 재설계됐다. 이 문서의 BLOCKED 상태는 해제됐다(재개 이력 섹션 참조).
(e) §3.6에서 "좌석/순번 즉시 해제"가 기존 대기열 조회 필터링만으로 충분한지, 별도 명시적 처리가 필요한지 — 이 문서는 조회 필터링만으로 충분하다고 추정했으나 확정 검증하지 않았다.
(f) `no_show_kds_grace_minutes`의 실제 기본값(§11의 15분은 추정치) — Human 결정 필요.
(g) `0115`의 나머지 함수들(§9 제외 대상 외에도 `register_waiting`/`call_waiting_customer`/`pre_order_while_waiting`/`seat_waiting_customer`/`cancel_waiting`/`get_waiting_status`/`get_waiting_admin_view`)에 유사 phantom 컬럼이 더 있는지 — `600631_Overview.md` §9 (d)에서 이미 이월된 항목, 이 문서도 재확인하지 않았음을 재확인.
(h) `600631_Overview.md`를 이 Logic.md의 확정 사항(6개 정책 항목, ARRIVAL_PENDING 게이트 신규 추가, 감사 기록 설계, §8의 `expires_at` 기반 재설계)에 맞춰 갱신할지 — Overview는 "판단 아님, 옵션만" 서술로 작성됐으나 이번 Logic에서 정책이 실제로 확정됐으므로, Overview §8/§9의 관련 서술을 갱신하는 것이 문서 일관성에 도움될 수 있다. 이 문서는 갱신을 수행하지 않고 필요성만 기록한다.
(i) **[해소됨, §8 3계층 구조 재설계, 2026-07-16]** `0118` cron의 자동 노쇼 처리와 `mark_no_show()`의 부수효과(페널티/KDS 유예/감사) 비일관성 — §8.0-§8.5(공통 코어 `apply_no_show_transition()` + 수동 wrapper `mark_no_show()` + 자동 배치 `process_expired_no_shows()`)로 완전히 해소됐다. 더 이상 열린 항목이 아니다.
(j) **[신규, §8.1]** 자동/수동 노쇼 판정의 신뢰도 페널티(-20) 차등 적용 여부 — 이번 워크패킷은 단순화를 위해 두 경로 모두 동일한 -20을 적용한다(§8.1 코어, 과설계 방지·MVP 단순화 우선). 자동 판정은 직원의 육안 확인 없이 순수 타이머 경과로만 이뤄지므로 상황 파악이 불완전할 수 있다 — 페널티를 낮추거나 유보하는 것이 나은지는 향후(실제 운영 데이터 축적 후) 재검토 대상으로 남긴다. Human 결정 필요, 이번 워크패킷 범위 아님.
(k) **[해소됨, Human 결정, 2026-07-16]** `apply_no_show_transition()`의 게이트를 `p_trigger_source`에 따라 차등화했다(§8.1) — `p_trigger_source='STAFF'`는 `session_status='ARRIVAL_PENDING'`만 요구(`expires_at` 조건 없음, §3.3의 직원 즉시 처리 재량권 그대로 보존), `p_trigger_source='SYSTEM'`(§8.3의 자동 배치)만 `expires_at<=now()`를 추가로 요구한다. 기존 §3.3 대비 동작 변화는 없다 — 시간 조건은 애초에 §3.3 시점에 존재하지 않았던 신규 자동 경로(SYSTEM)에만 적용된다. §8.2/§8.3이 각각 `p_trigger_source := 'STAFF'`/`'SYSTEM'`을 정확히 전달하는지 재확인 완료.
(l) **[신규, §8.2]** `mark_no_show()`가 함수 내부에서 별도 STAFF role 검사를 수행해야 하는지, 아니면 REST/RPC 게이트웨이 레벨의 인증만으로 충분한지 — 이 문서는 후자를 가정했으나 Stage 4 구현 시 재확인 필요.
(m) **[신규, 제미나이 제안, §8.1/§10.1 통합 과정에서 이월]** 감사 로그(`catchmenu_audit`)의 콜드 데이터 아카이빙/파티셔닝 전략 — `apply_no_show_transition()`을 포함해 이 세션 전체가 계속 확장해온 `append_audit_record()` 호출 패턴이 append-only로 무기한 누적되므로, 실제 운영 데이터가 쌓인 뒤(§0의 Provisional Policy 원칙과 동일한 전제) 오래된 감사 레코드를 어떻게 보관·조회 성능을 유지할지(시간 기준 파티셔닝, 콜드 스토리지 이전 등)는 이번 워크패킷 범위가 아니며 별도 검토 대상으로 명시한다. 지금 결정하지 않는다 — 데이터 규모가 실제로 문제가 될 때 재검토.
(n) **[신규, §6 확정 과정에서 분리 이월, Human 결정]** `recover_no_show_grace_ticket()`의 복잡한 예외 처리 — 선결제 환불/재조정 문제(고객이 사전결제했는데 그 사이 취소·환불 처리가 진행됐다면), 재고 충돌(복구 시점에 이미 해당 재료가 다른 주문에 재할당됐다면), 좌석 재배정 문제(복구했지만 테이블이 이미 다른 손님에게 배정됐다면) — 는 이번 "순수 상태 되돌리기"(§6) 범위에 포함하지 않는다. 이런 예외는 정책 설정(예: 복구 시 재고/좌석 가용성을 사전 확인해 차단할지, 확인 없이 무조건 복구부터 하고 후속 조정은 별도 프로세스에 맡길지)으로 향후 별도 워크패킷에서 다룰 대상으로 명시적으로 이월한다 — 이번 워크패킷은 어느 쪽도 판단하지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600631_Overview_Mark_No_Show_Overload_And_Redesign.md` — 이 문서의 직접 전제(§1-§7의 라이브 재검증 결과 전체).
- `600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` / `0160_call_waiting_customer_contract_recovery.sql` — 이 문서의 BLOCKED를 해제한 선행 워크패킷 결과물, §8.1의 `expires_at` 스냅샷 설계 근거.
- `600580_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md` §7 — "정책은 즉시 강제, 복구 수단은 별도 이월" 패턴의 선례(§6에서 참고).
- `600570_Overview_Cancel_Payment_Phantom_Column_Fix.md` §9 (COOKING 취소 정책 유보) — §2.2 항목 5의 경계 판단 선례.

### Full Rules Required

- `sql/migrations/0050_create_waiting_queue_rpc.sql` — `mark_no_show()` 구버전(L445-574), DROP 대상.
- `sql/migrations/0115_create_waiting_pipeline_rpc.sql` — `mark_no_show()`(L1333-1463) 수정 대상, `confirm_arrival()`(L872-985, 범위 밖 참고). 소스 본문이 stale 상태임에 유의(재개 이력 섹션 참고).
- `sql/migrations/0118_create_schema_validation_update.sql` — `WAITING_SESSION_EXPIRE` cron(L164-188) 수정 대상, §8.1 재설계 반영.
- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` — `_record_waiting_call()`/`call_waiting_customer()`/`call_next_waiting_customer()`의 `session_events`/`expires_at` 실사용 패턴, §8.1 설계가 직접 재사용.
- `sql/migrations/0049_create_store_settings_rpc.sql` — `pre_order_lead_minutes`/`pre_order_expire_minutes`/`wait_call_expire_minutes` 명명 관례 참고(§11).
- `catchmenu_kds.kds_tickets`/`catchmenu_pos.order_sessions`/`catchmenu_pos.session_events`/`catchmenu_pos.orders`(`session_id` FK) 라이브 스키마 및 CHECK 제약(라이브 재확인, §4.1/§3/§8 전반).
- `catchmenu_audit.append_audit_record()` 라이브 파라미터 목록(재확인, §10).
- 신규 함수 5종(§8/§5/§6): `catchmenu_pos.apply_no_show_transition()`(공통 코어), `catchmenu_pos.mark_no_show()`(수동 wrapper, 기존 이름 재정의), `catchmenu_pos.process_expired_no_shows()`(자동 배치), `catchmenu_kds.expire_no_show_kds_hold()`(KDS 유예 자동 만료), `catchmenu_kds.recover_no_show_grace_ticket()`(늦은 도착 복구) — Stage 4가 그대로 구현할 확정 시그니처.

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.

### Excluded Rule Families

- `confirm_arrival()` phantom 컬럼 수정(§9) — 범위 밖 확정.
- `0115`의 나머지 6개 함수 전수 감사(§12 (g)) — 범위 밖.
- Flutter/클라이언트 코드 — 이번 워크패킷은 SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**재개 확정 — BLOCKED 해제, Stage 2(TestPlan)로 진행 가능.** Codex의 선행 버전을 참고 자료로만 취급하고 이 문서를 독립적으로 새로 작성한 이력(§0)과, 이후 `call_waiting_customer()` 결함으로 BLOCKED됐던 이력(재개 이력 섹션)을 그대로 보존했다. §2에서 900xxx 내부 모순(1개 문서 vs 4개 문서)을 재확인하고, 그 모순을 그대로 채택하지 않는 제3의 통합 정책(짧은 유예 → 자동 취소) 6개 항목을 확정 반영했다. §3에서 `mark_no_show()`의 정확한 캐노니컬 설계(phantom 3종 치환, `ARRIVAL_PENDING` 게이트 신규 추가, `0050` 페널티 병합, `expires_at` 감사용 조회 추가)를 작성했다. §4에서 `kds_status` enum 확장 없이 `hold_reason`/`hold_expires_at`(신규 컬럼 1개)만으로 유예 상태를 표현하는 설계를 확정했다. §7에서 `0050` DROP, §9에서 `confirm_arrival()`을 범위 밖으로 확정했다.

**§8은 두 차례 재설계됐다.** 1차로 `called_at + 15분` 재계산 방식을 폐기하고 `600640`이 채워두는 `order_sessions.expires_at` 스냅샷과의 단순 비교(`expires_at <= now()`)로 대체해 cron의 phantom 컬럼 2개(`called_at`/`no_show_at`)를 해소했다. 그 과정에서 cron이 `mark_no_show()`를 호출하지 않고 인라인으로만 상태를 바꿔 페널티/유예/감사 부수효과를 건너뛰는 구조적 비일관성을 발견했고, 이번 2차 재설계(Human 결정, ChatGPT+제미나이 교차검증)로 **3계층 구조**(공통 코어 `apply_no_show_transition()` §8.1 + 수동 wrapper `mark_no_show()` §8.2 + 자동 배치 `process_expired_no_shows()` §8.3 + cron이 배치 함수 하나만 호출 §8.4)로 완전히 해소했다(구 §12 (i) 종결). §3.2-§3.6의 로직은 이제 §8.1의 코어로 이전됐고, §3은 근거 자료로 보존하되 슈퍼시드 표시를 추가했다. 이 과정에서 발견한 새 사항 3가지 — 자동/수동 페널티 차등 여부(§12 (j)), 수동 경로도 `expires_at<=now()`를 요구하게 된 동작 변화(§12 (k)), `mark_no_show()`의 함수 내부 role 검사 필요 여부(§12 (l)) — 를 Open Item으로 이월했다. §10에서 감사 기록 설계(§0.1 원칙 2, `original_call_expires_at`/`trigger_source`/`reason_code` 추가)를, §11에서 정책값 설정화 설계(§0.1 원칙 1) 및 `wait_call_expire_minutes`와의 명시적 구분을 완료했다.

**§8.1과 §10.1을 통합했다(Human 결정, ChatGPT "B+ 절충안", 2026-07-16).** §8.1(canonical 코드)에 §10.1이 제안했던 `p_before_state`(`session_status`/`arrival_reliability_score`/KDS `hold_reason`의 이전값)/`p_after_state`(이후값)와 `p_business_day`/`p_business_timezone`(재계산하지 않고 `order_sessions`에 이미 저장된 값 재사용)을 흡수했다 — `order_sessions` 전체 행 스냅샷은 채택하지 않았다. 이 과정에서 §10.1 원안이 `UPDATE...RETURNING` 이후 값을 `before_state`에 잘못 쓰려던 오류를 발견해 정정했다(`v_old_score`를 UPDATE 이전에 별도 조회). §10.1은 이제 통합 이력 기록용으로만 보존되며 별도 구현 대상이 아니다. 감사 로그 콜드 데이터 아카이빙/파티셔닝 전략을 새 Open Item(§12 (m))으로 이월했다.

**§5/§6을 확정했다(Human 결정, ChatGPT+제미나이 교차검증, 2026-07-16).** §5 `expire_no_show_kds_hold()`를 `process_expired_no_shows()`(§8.3)와 동일한 배치 패턴(`SKIP LOCKED`/건별 실패 격리/작은 배치)으로 설계하고, §8.4의 `0118` cron 갱신에 두 번째 매장별 루프로 추가했다. §6 `recover_no_show_grace_ticket()`을 §5와 정확히 대칭적인 단일 조건부 UPDATE(`hold_expires_at>now()`)로 최소 형태 설계했다 — 단위를 원래 초안의 세션에서 티켓으로 변경해 대칭을 맞췄다. 동시 실행 시 하나만 성공하는 이유를 "시간 조건의 논리적 배타성"이 아니라 "행 잠금 + 공유 `hold_reason='NO_SHOW_GRACE'` 전제조건에 의한 직렬화"로 정확히 재정식화해 문서화했다(단순한 시간-배타성 설명은 두 트랜잭션의 `now()` 스냅샷이 다를 수 있다는 점에서 엄밀하지 않음). 복잡한 예외(선결제 재조정/재고 충돌/좌석 재배정)는 새 Open Item(§12 (n))으로 분리 이월했다. §12 (a)/(b)는 확정 완료로 종결됐다.

`.sql` 파일은 이번 확정 턴에도 생성·수정하지 않았다. `600643_TestPlan.md`/`600644_ChangeContract.md`로 진행하기 전 §12의 잔여 Open Item((e)/(f)/(g)/(h)/(j)/(l)/(m)/(n))에 대한 Human 결정이 여전히 필요하다 — (a)/(b)/(c)/(d)/(i)/(k)는 전부 확정/범위 밖 확정/해소 완료로 종결됐다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600633_TestPlan.md] =====
# 600633_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 Test Plan
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 Purpose

This TestPlan verifies the finalized `600632_Logic.md` design for replacing the ambiguous/broken no-show pipeline with five canonical functions:

1. `catchmenu_pos.apply_no_show_transition()`
2. `catchmenu_pos.mark_no_show()`
3. `catchmenu_pos.process_expired_no_shows()`
4. `catchmenu_kds.expire_no_show_kds_hold()`
5. `catchmenu_kds.recover_no_show_grace_ticket()`

The implementation under test must also:

- drop the legacy `0050` `catchmenu_pos.mark_no_show(uuid, uuid, uuid, text, uuid, text)` overload,
- update the `0118` `WAITING_SESSION_EXPIRE` cron job to call `process_expired_no_shows()` and `expire_no_show_kds_hold()` in store-scoped loops,
- avoid modifying `confirm_arrival()`,
- avoid adding schema columns except the explicitly approved `catchmenu_kds.kds_tickets.hold_expires_at` column.

## §1 Preconditions / Stop-Condition Checks

Before Stage 4 implementation, record the following facts. Any mismatch is a STOP condition for implementation and must be reported.

### §1.1 Existing function inventory

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('catchmenu_pos', 'catchmenu_kds')
  and p.proname in (
    'apply_no_show_transition',
    'mark_no_show',
    'process_expired_no_shows',
    'expire_no_show_kds_hold',
    'recover_no_show_grace_ticket'
  )
order by n.nspname, p.proname, args;
```

Expected before implementation:

- legacy `mark_no_show(...)` overloads may exist,
- the five canonical functions are not yet all present.

Expected after implementation:

- exactly one canonical `catchmenu_pos.mark_no_show(...)` remains,
- `apply_no_show_transition(...)` exists,
- `process_expired_no_shows(...)` exists,
- `expire_no_show_kds_hold(...)` exists,
- `recover_no_show_grace_ticket(...)` exists,
- legacy `0050` `mark_no_show(uuid, uuid, uuid, text, uuid, text)` is gone.

### §1.2 Required schema columns and approved `hold_expires_at` addition

```sql
select table_schema, table_name, column_name, data_type, is_nullable
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_pos', 'order_sessions', 'expires_at'),
  ('catchmenu_pos', 'order_sessions', 'session_status'),
  ('catchmenu_pos', 'order_sessions', 'arrival_reliability_score'),
  ('catchmenu_pos', 'order_sessions', 'pre_order_created_at'),
  ('catchmenu_pos', 'order_sessions', 'business_day'),
  ('catchmenu_pos', 'order_sessions', 'business_timezone'),
  ('catchmenu_kds', 'kds_tickets', 'hold_reason'),
  ('catchmenu_kds', 'kds_tickets', 'hold_expires_at')
)
order by table_schema, table_name, column_name;
```

Expected:

- before implementation, every listed column except `hold_expires_at` must already exist.
- before implementation, `hold_expires_at` may be absent; this is the expected state confirmed by `600632_Logic.md` §4.1.
- Stage 4 must add `hold_expires_at` with `ALTER TABLE catchmenu_kds.kds_tickets ADD COLUMN IF NOT EXISTS hold_expires_at timestamptz`.
- after implementation, `hold_expires_at` must exist and must be nullable `timestamp with time zone`.

If `hold_reason` is absent before implementation, Stage 4 must STOP. `hold_expires_at` absence before implementation is not a STOP condition.

### §1.3 Audit function signature

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_audit'
  and p.proname = 'append_audit_record'
order by args;
```

Expected:

- signature matches the call shape required by `600632_Logic.md` §10 / §8.1.
- if the live signature differs, Stage 4 must STOP and report rather than guessing parameter names.

### §1.4 Error catalog / response keys

Confirm all error keys used by the five functions already exist, or the implementation must STOP before adding any new key.

Minimum expected keys include:

- `waiting_session_not_found`
- `session_not_markable`
- `invalid_trigger_source`
- `no_show_grace_already_expired`
- `kds_ticket_not_found`
- `ticket_not_recoverable`

Use the actual implementation’s final key list for the query:

```sql
select error_key, code, error_domain, error_category
from catchmenu_common.error_codes
where error_key in (
  'waiting_session_not_found',
  'session_not_markable',
  'invalid_trigger_source',
  'no_show_grace_already_expired',
  'kds_ticket_not_found',
  'ticket_not_recoverable'
)
order by error_key;
```

## §2 Test A — `apply_no_show_transition()` core behavior

### §2.1 STAFF immediate transition succeeds before `expires_at`

Setup:

1. Create an `ARRIVAL_PENDING` `order_sessions` row with `expires_at > now()`.
2. Include `arrival_reliability_score` and `business_day` / `business_timezone`.
3. Optionally link an order with HOLD KDS tickets for the KDS grace sub-check.

Call:

```sql
select catchmenu_pos.apply_no_show_transition(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<session_id>'::uuid,
  p_trigger_source := 'STAFF',
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-staff-immediate'
);
```

Expected:

- `success = true`.
- `order_sessions.session_status = 'NO_SHOW'`.
- `arrival_reliability_score` is reduced by 20 with lower bound 0.
- `cancelled_at is not null`.
- `expires_at > now()` did not block STAFF transition.
- linked HOLD KDS tickets enter grace state when pre-order exists:
  - `kds_status = 'HOLD'`
  - `hold_reason = 'NO_SHOW_GRACE'`
  - `hold_expires_at is not null`

### §2.2 SYSTEM before expiry is rejected

Setup:

- same as §2.1, but `expires_at > now()`.

Call with:

```sql
p_trigger_source := 'SYSTEM'
```

Expected:

- `success = false`.
- session remains `ARRIVAL_PENDING`.
- no KDS ticket enters `NO_SHOW_GRACE`.
- audit/event rows do not claim a successful no-show transition.

### §2.3 SYSTEM after expiry succeeds

Setup:

- `ARRIVAL_PENDING` session with `expires_at <= now()`.

Call with:

```sql
p_trigger_source := 'SYSTEM'
```

Expected:

- `success = true`.
- session becomes `NO_SHOW`.
- KDS HOLD tickets enter `NO_SHOW_GRACE` if pre-order exists.

### §2.4 Idempotent retry on already `NO_SHOW`

Setup:

- session already has `session_status = 'NO_SHOW'`.

Call `apply_no_show_transition()` again with the same session.

Expected:

- returns a safe/idempotent result according to the final implementation contract.
- does not double-apply `arrival_reliability_score` penalty.
- does not create duplicate KDS grace transitions.
- `600632_Logic.md` §8.1's idempotent branch returns immediately and does not call `append_audit_record()`.
- retry/no-op is distinguished by the response payload field `idempotent: true`.

### §2.5 Invalid trigger source is rejected

Call:

```sql
p_trigger_source := 'INVALID'
```

Expected:

- `success = false`.
- error key is `invalid_trigger_source` or the final approved equivalent.
- no session/KDS mutation occurs.

## §3 Test B — Audit record B+ pattern

For successful STAFF and SYSTEM transitions, verify `catchmenu_audit` records include:

- `before_state.session_status = 'ARRIVAL_PENDING'`,
- `after_state.session_status = 'NO_SHOW'`,
- previous and new `arrival_reliability_score`,
- KDS grace ticket count / ids / expiry when applicable,
- `trigger_source`,
- `reason_code`,
- `business_day`,
- `business_timezone`,
- correlation id.

Use the actual audit table/function output shape from `append_audit_record()`:

```sql
select *
from catchmenu_audit.<audit_table_or_view>
where correlation_id = '<test-correlation-id>'
order by occurred_at desc;
```

Expected:

- before/after state values are not reversed.
- `business_day` / `business_timezone` are copied from `order_sessions`, not recomputed inconsistently.
- full-row snapshots are not adopted and must not be introduced; the approved B+ pattern records only the selected before/after fields from `600632_Logic.md` §8.1.

## §4 Test C — `mark_no_show()` manual wrapper

Setup:

- `ARRIVAL_PENDING` session with `expires_at > now()`.

Call:

```sql
select catchmenu_pos.mark_no_show(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<session_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-mark-no-show'
);
```

Expected:

- success.
- wrapper passes `trigger_source = 'STAFF'`.
- session becomes `NO_SHOW` despite future `expires_at`.
- audit record reports `trigger_source = 'STAFF'`.
- no direct legacy `0050` logic remains active.

## §5 Test D — `process_expired_no_shows()` automatic batch

### §5.1 Normal batch success

Setup:

- create multiple `ARRIVAL_PENDING` sessions:
  - some with `expires_at <= now()`,
  - some with `expires_at > now()`,
  - some not `ARRIVAL_PENDING`.

Call:

```sql
select catchmenu_pos.process_expired_no_shows(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_batch_size := 100,
  p_correlation_id := 'test-600630-process-expired'
);
```

Expected:

- only expired `ARRIVAL_PENDING` sessions become `NO_SHOW`.
- future `expires_at` sessions remain unchanged.
- non-`ARRIVAL_PENDING` sessions remain unchanged.
- each processed row uses `trigger_source = 'SYSTEM'`.
- response reports processed count and failed count.

### §5.2 `SKIP LOCKED` concurrency

Run two concurrent transactions:

1. Session A starts `process_expired_no_shows()` and holds locks on selected rows.
2. Session B starts `process_expired_no_shows()` for the same tenant/store.

Expected:

- the two sessions do not process the same `order_sessions` row.
- locked rows are skipped rather than blocking indefinitely.
- final processed session ids are disjoint.

### §5.3 Per-row failure isolation

Create a batch where one candidate is expected to fail during transition while at least one other candidate should succeed.

Acceptable ways to force the failure must stay within test isolation and must not require schema changes. For example:

- use a row/data condition that causes the core function to return a failure response for one selected candidate, while another remains valid.

Expected:

- one row failure is captured in the batch result.
- other valid rows are still processed.
- the entire batch does not abort because of one failed row.
- audit/error details preserve the failed session id.

Coverage limitation: this test covers the core `success:false` return path and the batch-level per-row failure accounting. It does not force the true `EXCEPTION WHEN OTHERS` / implicit `SAVEPOINT` branch itself, because doing so without schema mutation or artificial fault injection is difficult. If Stage 4 introduces any test-only fault injection, it must use an isolated `__test_` name and be dropped before completion.

## §6 Test E — `expire_no_show_kds_hold()` KDS grace expiry batch

### §6.1 Normal expiry success

Setup:

- create KDS tickets with:
  - `kds_status = 'HOLD'`,
  - `hold_reason = 'NO_SHOW_GRACE'`,
  - `hold_expires_at <= now()`.

Call:

```sql
select catchmenu_kds.expire_no_show_kds_hold(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_batch_size := 100,
  p_correlation_id := 'test-600630-expire-kds-grace'
);
```

Expected:

- matching tickets become `kds_status = 'CANCELLED'`.
- `hold_reason = 'NO_SHOW_GRACE_EXPIRED'`.
- audit record captures before/after KDS state.
- unexpired or non-grace tickets are unchanged.

### §6.2 `SKIP LOCKED` concurrency

Run two concurrent `expire_no_show_kds_hold()` calls against multiple expired grace tickets.

Expected:

- no ticket is expired twice.
- selected ticket ids are disjoint across sessions.
- locked rows are skipped.

### §6.3 Per-row failure isolation

Create a batch with one ticket expected to fail and another expected to succeed.

Expected:

- failed ticket is reported.
- successful tickets still expire.
- function returns a failure count/details without aborting the entire batch.

Coverage limitation: this test covers the expected `success:false` / failure-accounting path for KDS grace expiry. It does not force the true `EXCEPTION WHEN OTHERS` / implicit `SAVEPOINT` branch itself, because doing so without schema mutation or artificial fault injection is difficult. If Stage 4 introduces any test-only fault injection, it must use an isolated `__test_` name and be dropped before completion.

## §7 Test F — `recover_no_show_grace_ticket()` late-arrival recovery

### §7.1 Recovery before grace expiry succeeds

Setup:

- KDS ticket:
  - `kds_status = 'HOLD'`,
  - `hold_reason = 'NO_SHOW_GRACE'`,
  - `hold_expires_at > now()`.

Call:

```sql
select catchmenu_kds.recover_no_show_grace_ticket(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_kds_ticket_id := '<ticket_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-recover-grace'
);
```

Expected:

- success.
- ticket remains/returns to `kds_status = 'HOLD'`.
- `hold_reason` is cleared or set to the final approved recovered value.
- `hold_expires_at` is cleared or otherwise no longer active.
- audit record captures recovery before/after state.

### §7.2 Expired grace recovery is rejected

Setup:

- `hold_reason = 'NO_SHOW_GRACE'`,
- `hold_expires_at <= now()`.

Expected:

- `success = false`.
- error key is `no_show_grace_already_expired`.
- ticket remains unchanged.

### §7.3 Missing ticket is rejected

Call with a non-existing `p_kds_ticket_id`.

Expected:

- `success = false`.
- error key is `kds_ticket_not_found` or final approved equivalent.
- no mutation.

### §7.4 Non-grace ticket is rejected

Setup:

- ticket exists but `hold_reason <> 'NO_SHOW_GRACE'` or `kds_status <> 'HOLD'`.

Expected:

- `success = false`.
- ticket remains unchanged.

## §8 Test G — Expiry vs recovery concurrency

Run two concurrent transactions on the same grace ticket:

1. `expire_no_show_kds_hold()` attempts to expire the ticket.
2. `recover_no_show_grace_ticket()` attempts to recover the same ticket.

Use two timing variants:

- ticket still within grace at the beginning of both transactions,
- ticket expires just before or during the race window.

Expected:

- only one operation succeeds.
- row locking serializes the update.
- no final state exists where both recovery and expiry are reported as successful.
- final row state matches the one successful operation.

## §9 Test H — Legacy `0050` `mark_no_show()` DROP

Before implementation, record the legacy signature:

```sql
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'mark_no_show'
order by args;
```

After implementation:

- legacy `mark_no_show(uuid, uuid, uuid, text, uuid, text)` is absent.
- canonical `0115`-style `mark_no_show(uuid, uuid, uuid, uuid, text, text)` remains.

## §10 Test I — `0118` cron update

Verify `0118_create_schema_validation_update.sql` / live cron body no longer performs inline phantom-column no-show updates.

Expected cron shape:

1. Store loop calls `catchmenu_pos.process_expired_no_shows(...)`.
2. Store loop calls `catchmenu_kds.expire_no_show_kds_hold(...)`.

Verification queries depend on how the cron body is represented live. At minimum:

```sql
select pg_get_functiondef('<cron_function_signature>'::regprocedure);
```

or inspect the relevant cron job command text if implemented as `pg_cron` command rows.

Expected:

- references to phantom `called_at`, `no_show_at`, `cancel_reason` are removed from the no-show expiry path.
- both batch functions are invoked.
- store-scoped loop is preserved.

## §11 Boundary Verification

### §11.1 Forbidden source files/functions

Verify zero diff for:

- `confirm_arrival()` body,
- the other six unrelated functions in `0115_create_waiting_pipeline_rpc.sql`,
- Flutter/runtime files,
- payment/KDS unrelated pipelines.

### §11.2 Schema-change boundary

Verify the single approved schema-column addition and no more:

```sql
select table_schema, table_name, column_name
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_kds', 'kds_tickets', 'hold_reason'),
  ('catchmenu_kds', 'kds_tickets', 'hold_expires_at')
)
order by table_schema, table_name, column_name;
```

Expected:

- `hold_reason` existed before implementation and still exists after.
- `hold_expires_at` may be absent before implementation and must exist after implementation.
- the implementation diff may contain only the approved `ALTER TABLE catchmenu_kds.kds_tickets ADD COLUMN IF NOT EXISTS hold_expires_at timestamptz` schema addition.
- no other `ALTER TABLE ... ADD COLUMN` appears in the implementation diff.

### §11.3 Migration/source boundary

Expected modified scope:

- new forward migration or approved already-applied source synchronization for the five functions,
- `0050` legacy function DROP statement,
- `0118` cron body update.

No unapproved file may be changed.

## §12 Acceptance Criteria

PASS requires all of the following:

1. Five canonical functions exist and execute their success paths.
2. `apply_no_show_transition()` enforces STAFF vs SYSTEM gate differences.
3. KDS HOLD tickets enter `NO_SHOW_GRACE` on no-show transition.
4. KDS grace tickets expire to `CANCELLED` / `NO_SHOW_GRACE_EXPIRED`.
5. Grace tickets can be recovered before expiry and rejected after expiry.
6. Batch functions use `SKIP LOCKED`.
7. Batch functions isolate per-row failures.
8. Audit records include B+ before/after state and business day/timezone.
9. Legacy `0050` `mark_no_show()` overload is dropped.
10. `0118` cron calls both batch functions.
11. Forbidden files/functions remain unchanged.
12. The only schema column added in this workpacket is the approved nullable `catchmenu_kds.kds_tickets.hold_expires_at`; no other schema columns are added.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600634_ChangeContract.md] =====
# 600634_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 Change Contract
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 Approval Basis

This ChangeContract is based on the finalized `600632_Logic.md` design after `600640_call_waiting_customer_contract_recovery` reached Stage 6 ACCEPT.

This document intentionally uses the `600633` / `600634` numbers for the `600630_mark_no_show_overload_and_redesign` workpacket. The `600643` / `600644` numbers are already occupied by `600640_call_waiting_customer_contract_recovery` and must not be overwritten.

## §1 Allowed Changes

Stage 4 may implement only the following changes.

### §1.1 New canonical core function

Allowed:

- create `catchmenu_pos.apply_no_show_transition(...)`.

Required behavior:

- common core for manual and automatic no-show transition,
- `p_trigger_source = 'STAFF'` allows immediate transition when session is `ARRIVAL_PENDING`,
- `p_trigger_source = 'SYSTEM'` requires `session_status = 'ARRIVAL_PENDING'` and `expires_at <= now()`,
- invalid trigger source is rejected,
- already `NO_SHOW` retry is safe/idempotent,
- applies arrival reliability penalty once,
- moves linked HOLD KDS tickets into `NO_SHOW_GRACE`,
- writes B+ audit record with before/after state and business day/timezone.

### §1.2 Manual wrapper

Allowed:

- create or replace `catchmenu_pos.mark_no_show(...)` using the canonical `0115`-style signature.

Required behavior:

- thin wrapper around `apply_no_show_transition()`,
- passes `p_trigger_source := 'STAFF'`,
- preserves public manual no-show RPC semantics.

### §1.3 Automatic no-show batch

Allowed:

- create `catchmenu_pos.process_expired_no_shows(...)`.

Required behavior:

- selects expired `ARRIVAL_PENDING` sessions,
- uses `FOR UPDATE SKIP LOCKED`,
- processes rows through `apply_no_show_transition()` with `p_trigger_source := 'SYSTEM'`,
- isolates per-row failures,
- returns processed/failed counts and details.

### §1.4 KDS grace expiry batch

Allowed:

- create `catchmenu_kds.expire_no_show_kds_hold(...)`.

Required behavior:

- selects `kds_status = 'HOLD'`,
- requires `hold_reason = 'NO_SHOW_GRACE'`,
- requires `hold_expires_at <= now()`,
- uses `FOR UPDATE SKIP LOCKED`,
- updates to `kds_status = 'CANCELLED'` and `hold_reason = 'NO_SHOW_GRACE_EXPIRED'`,
- isolates per-row failures,
- writes audit record.

### §1.5 KDS grace recovery function

Allowed:

- create `catchmenu_kds.recover_no_show_grace_ticket(...)`.

Required behavior:

- ticket-level recovery only,
- requires `kds_status = 'HOLD'`,
- requires `hold_reason = 'NO_SHOW_GRACE'`,
- requires `hold_expires_at > now()`,
- restores the ticket out of grace state through one symmetric conditional UPDATE,
- rejects expired grace with `no_show_grace_already_expired`,
- rejects missing/non-recoverable tickets without mutation,
- writes audit record.

### §1.6 Legacy `0050` overload DROP

Allowed:

```sql
drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);
```

The exact live signature must be rechecked immediately before Stage 4 execution. If it differs, Stage 4 must STOP and report.

### §1.7 `0118` cron update

Allowed:

- update the `0118` `WAITING_SESSION_EXPIRE` cron path so it calls:
  - `catchmenu_pos.process_expired_no_shows(...)`,
  - `catchmenu_kds.expire_no_show_kds_hold(...)`.

Required behavior:

- preserve store-scoped loop behavior,
- remove inline phantom-column updates from the no-show expiry path,
- call both batch functions per store or through an equivalent store-scoped iteration.

### §1.8 Schema-column boundary

Allowed:

- use existing `order_sessions` and `kds_tickets` columns.
- add the single approved KDS grace expiry column:

```sql
alter table catchmenu_kds.kds_tickets
  add column if not exists hold_expires_at timestamptz;
```

Not allowed:

- adding `hold_reason`,
- adding `no_show_at`,
- adding `called_at`,
- adding `cancel_reason`,
- adding any schema column other than the approved nullable `hold_expires_at`.

This ChangeContract assumes `kds_tickets.hold_reason` already exists. `hold_expires_at` may be absent before Stage 4 and must be created by the approved `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` statement.

## §2 Forbidden Changes

The following are forbidden:

1. Editing `confirm_arrival()`.
2. Editing unrelated functions in `0115_create_waiting_pipeline_rpc.sql`.
3. Editing Flutter/runtime code.
4. Adding schema columns other than the approved nullable `kds_tickets.hold_expires_at`.
5. Extending `kds_status` enum or constraint values.
6. Dropping or renaming `hold_reason` / `hold_expires_at`.
7. Implementing complex late-arrival exception policy for:
   - prepaid refund/re-adjustment,
   - inventory conflict,
   - seat/table reallocation.
8. Implementing no-show blacklist policy.
9. Changing payment/refund/KDS cooking pipelines outside the explicitly allowed KDS grace functions.

## §3 Stop Conditions

Stage 4 must stop and report if any of the following are true:

1. `600634_ChangeContract.md` Human Approval checkboxes are not all checked.
2. The live legacy `0050` `mark_no_show()` signature differs from the DROP signature in §1.6.
3. `catchmenu_kds.kds_tickets.hold_reason` is absent.
4. `catchmenu_pos.order_sessions.expires_at` is absent.
5. `catchmenu_pos.order_sessions.business_day` or `business_timezone` is absent.
6. `catchmenu_audit.append_audit_record()` signature differs from the call shape expected by `600632_Logic.md`.
7. Existing error catalog keys required by the implementation are absent and a new key would be needed.
8. `FOR UPDATE SKIP LOCKED` cannot be used in the automatic batch functions.
9. Implementing the design requires modifying `confirm_arrival()` or unrelated `0115` functions.
10. Implementing the design requires schema changes beyond the approved nullable `kds_tickets.hold_expires_at` addition.
11. `0118` cron representation cannot be updated safely without changing unrelated scheduler semantics.

## §4 Required Verification

Stage 4 must execute `600633_TestPlan.md` in full.

Required highlights:

- all five functions success paths,
- STAFF immediate transition before expiry,
- SYSTEM rejection before expiry,
- SYSTEM success after expiry,
- idempotent retry on already `NO_SHOW`,
- invalid trigger source rejection,
- B+ audit before/after state and business day/timezone,
- `process_expired_no_shows()` `SKIP LOCKED` and per-row failure isolation,
- `expire_no_show_kds_hold()` `SKIP LOCKED` and per-row failure isolation,
- `recover_no_show_grace_ticket()` success/rejection paths,
- expiry vs recovery concurrency,
- legacy `0050` `mark_no_show()` DROP,
- `0118` cron calls both batch functions,
- boundary zero diff for forbidden areas.

## §5 Open Items Carried Forward

The following `600632_Logic.md` Open Items are not resolved by this ChangeContract and remain carried forward:

- (e) exact grace duration setting value / operational tuning.
- (f) seat/queue release side effects beyond `session_status = 'NO_SHOW'`.
- (g) user/staff-facing UI messaging.
- (h) reporting/dashboard interpretation of grace, expiry, and recovery.
- (j) whether STAFF/SYSTEM penalty policy should diverge in future operations.
- (l) whether `mark_no_show()` needs explicit role/permission checks inside the function body.
- (m) audit-log cold-data archiving / partitioning strategy.
- (n) complex recovery exceptions: prepaid adjustment, inventory conflict, seat reallocation.
- (o) `log_diagnostic()` currently has a defensive gap when an unregistered `error_key` / NULL severity path causes `diagnostic_logs.is_recoverable` to be computed as NULL and violate its NOT NULL constraint. This workpacket avoids the issue by pre-registering the required no-show error keys, but the generic `log_diagnostic()` hardening remains a separate follow-up candidate.

The following are explicitly no longer Open Items for this ChangeContract:

- including `expire_no_show_kds_hold()` in scope,
- including `recover_no_show_grace_ticket()` in scope,
- unblocking after `600640`,
- resolving the old `0118` / manual-side-effect inconsistency.

## §6 Boundary Reporting Requirements

Stage 4 output must report:

1. full implementation diff,
2. whether a new forward migration or already-applied source sync path was used,
3. live function inventory before/after,
4. legacy overload DROP confirmation,
5. `0118` cron before/after relevant snippet,
6. all TestPlan results,
7. explicit zero-diff confirmation for forbidden files/functions,
8. `git diff --check` result.

## §7 Human Boundary Approval

Stage 4 may proceed only after all three boxes are checked by Human:

☑ I approve the five-function no-show redesign scope (apply_no_show_transition, mark_no_show, process_expired_no_shows, expire_no_show_kds_hold, recover_no_show_grace_ticket).
☑ I approve dropping the legacy 0050 mark_no_show(uuid, uuid, uuid, text, uuid, text) overload.
☑ I approve updating the 0118 cron path to call process_expired_no_shows() and expire_no_show_kds_hold() while making no schema-column changes other than the approved hold_expires_at addition.(2026-07-16)

## §8 Approval State

Current approval state: APPROVED. (2026-07-16)

No implementation may proceed until §7 is checked by Human.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600635_Module.md] =====
# 600635_Module.md

Status: Implemented
Lifecycle: Module
Workpacket: 600630_mark_no_show_overload_and_redesign
Implementation: `0161_mark_no_show_overload_and_redesign.sql`
Date: 2026-07-16

## §1 Implementation Summary

`0161_mark_no_show_overload_and_redesign.sql` implements the approved `600630` Stage 4 scope for no-show handling in the waiting/order-session domain.

The implementation performs four coordinated changes:

| Area | Implemented change |
|---|---|
| Error catalog | Registers five required error keys before function creation: `invalid_trigger_source`, `kds_ticket_not_found`, `no_show_grace_already_expired`, `session_not_markable`, `ticket_not_recoverable`. |
| KDS schema | Adds the single approved column `catchmenu_kds.kds_tickets.hold_expires_at timestamptz`. No other schema column is added. |
| RPC/function layer | Creates/replaces five canonical functions: `apply_no_show_transition()`, `mark_no_show()`, `process_expired_no_shows()`, `expire_no_show_kds_hold()`, `recover_no_show_grace_ticket()`. |
| Legacy/cron cleanup | Drops the legacy `0050` `mark_no_show(uuid, uuid, uuid, text, uuid, text)` overload and updates `WAITING_SESSION_EXPIRE` to call store-scoped batch functions instead of inline phantom-column updates. |

## §2 Function-Level Record

### §2.1 `catchmenu_pos.apply_no_show_transition()`

Implemented as the shared no-show transition core.

- `p_trigger_source='STAFF'`: allows immediate transition from `ARRIVAL_PENDING` to `NO_SHOW`.
- `p_trigger_source='SYSTEM'`: requires `expires_at <= now()`.
- Invalid trigger sources return `invalid_trigger_source`.
- Missing sessions return `waiting_session_not_found`.
- Already `NO_SHOW` sessions return success with `idempotent:true` and do not create another audit record.
- Non-markable sessions return `session_not_markable`.
- `ARRIVAL_PENDING` sessions are updated to `NO_SHOW`, `arrival_reliability_score` is reduced by 20 with floor 0, and `cancelled_at` is set.
- If a pre-order exists, linked `HOLD` KDS tickets enter `NO_SHOW_GRACE` with `hold_expires_at`.
- B+ audit records are written with selected before/after state plus `business_day`/`business_timezone`; full-row snapshots are not used.

Implementation note: the original design wording used the conceptual waiting domain, but the live `catchmenu_ledger.audit_records.chk_audit_domain` constraint permits `session`, not `waiting`. The implementation therefore records the audit domain as `session`, which is the constraint-compatible representation of this waiting-session transition.

### §2.2 `catchmenu_pos.mark_no_show()`

Replaced as a thin manual wrapper around `apply_no_show_transition()`.

- Keeps the current 0115-style public signature.
- Calls the core with `p_actor_type='STAFF'` and `p_trigger_source='STAFF'`.
- Does not implement a new role/permission policy inside the function body; that remains an Open Item.

### §2.3 `catchmenu_pos.process_expired_no_shows()`

Created as the automatic waiting no-show batch.

- Selects expired `ARRIVAL_PENDING` sessions with `FOR UPDATE SKIP LOCKED`.
- Calls `apply_no_show_transition()` with `p_trigger_source='SYSTEM'`.
- Uses per-row `BEGIN/EXCEPTION` isolation.
- Returns `processed_count`, `failed_count`, and `failed_session_ids`.

### §2.4 `catchmenu_kds.expire_no_show_kds_hold()`

Created as the KDS grace-expiry batch.

- Selects `HOLD` tickets with `hold_reason='NO_SHOW_GRACE'` and `hold_expires_at <= now()`.
- Uses `FOR UPDATE SKIP LOCKED`.
- Updates matching tickets to `CANCELLED` and `hold_reason='NO_SHOW_GRACE_EXPIRED'`.
- Writes KDS audit records.
- Uses per-row `BEGIN/EXCEPTION` isolation.

### §2.5 `catchmenu_kds.recover_no_show_grace_ticket()`

Created as the ticket-level late-arrival recovery function.

- Uses the final parameter name `p_kds_ticket_id`.
- Recovers only `HOLD` / `NO_SHOW_GRACE` tickets whose `hold_expires_at > now()`.
- Clears `hold_reason` and `hold_expires_at`.
- Distinguishes `kds_ticket_not_found`, `no_show_grace_already_expired`, and `ticket_not_recoverable`.
- Writes KDS recovery audit records.

## §3 Legacy and Cron Changes

### §3.1 Legacy overload DROP

The legacy 0050 overload was dropped:

```sql
drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);
```

Final live count for that exact legacy signature is 0.

### §3.2 `WAITING_SESSION_EXPIRE` cron

The cron body now delegates to:

- `catchmenu_pos.process_expired_no_shows()`
- `catchmenu_kds.expire_no_show_kds_hold()`

The inline no-show update no longer references `called_at`, `no_show_at`, or `cancel_reason`.

## §4 Error Key Registration

The migration pre-registers:

| code | error_key | domain | category | http_status | severity |
|---:|---|---|---|---:|---|
| 2026 | `invalid_trigger_source` | `ORDER` | `INVALID_INPUT` | 400 | `WARNING` |
| 2027 | `session_not_markable` | `ORDER` | `CONFLICT` | 409 | `INFO` |
| 5008 | `kds_ticket_not_found` | `KDS` | `NOT_FOUND` | 404 | `INFO` |
| 5009 | `no_show_grace_already_expired` | `KDS` | `CONFLICT` | 409 | `INFO` |
| 5016 | `ticket_not_recoverable` | `KDS` | `CONFLICT` | 409 | `INFO` |

`WAITING` was not used as an `error_domain` because the live `chk_error_domain` constraint does not permit it. Existing waiting-session error keys in this range use `ORDER`, so the new waiting-session keys follow that pattern.

## §5 Boundary

No changes were made to:

- `confirm_arrival()`
- unrelated 0115 functions
- Flutter/runtime code
- schemas other than the approved `kds_tickets.hold_expires_at`

The implementation uses a new forward migration rather than modifying older source migrations in place.

## §6 Source/Live Note

As with `0160_call_waiting_customer_contract_recovery.sql`, the live database is updated by the new forward migration. Older source files such as `0115_create_waiting_pipeline_rpc.sql` may still contain historical/stale function bodies and must not be used as the sole source for live behavior without checking later migrations and `pg_get_functiondef()`.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600636_Verification.md] =====
# 600636_Verification.md

Status: Verified
Lifecycle: Verification
Workpacket: 600630_mark_no_show_overload_and_redesign
Implementation: `0161_mark_no_show_overload_and_redesign.sql`
Date: 2026-07-16

## §1 Verification Scope

This document records Stage 5 verification for the `600630` no-show redesign after `0161_mark_no_show_overload_and_redesign.sql`.

The verification is a triple independent verification result, excluding the original implementer Codex under the project’s §37 rule:

- Cursor
- Antigravity / 안티
- Claude Code

Codex performed the Stage 4 implementation and local execution checks, but the final verification judgement recorded here integrates the three independent reviewers above.

## §2 Implementation Presence

The live database shows the expected function inventory:

```text
catchmenu_pos.apply_no_show_transition(...)
catchmenu_pos.mark_no_show(...)
catchmenu_pos.process_expired_no_shows(...)
catchmenu_kds.expire_no_show_kds_hold(...)
catchmenu_kds.recover_no_show_grace_ticket(...)
```

The legacy 0050 overload count is 0:

```text
legacy_0050_count | 0
```

The migration history records:

```text
0161_mark_no_show_overload_and_redesign.sql | success=true
```

## §3 Error Catalog and Schema Verification

The required six error keys are present:

```text
invalid_trigger_source
kds_ticket_not_found
no_show_grace_already_expired
session_not_markable
ticket_not_recoverable
waiting_session_not_found
```

The new KDS column exists:

```text
catchmenu_kds.kds_tickets.hold_expires_at | timestamp with time zone | nullable
```

`hold_reason` pre-existed and remains:

```text
catchmenu_kds.kds_tickets.hold_reason | text | nullable
```

No schema column beyond `hold_expires_at` was introduced by this workpacket.

## §4 Functional Verification Results

The following TestPlan areas passed across independent verification:

| TestPlan area | Result |
|---|---|
| STAFF no-show transition before expiry | PASS |
| SYSTEM no-show transition before expiry | PASS: rejected with `session_not_markable` |
| SYSTEM no-show transition after expiry | PASS |
| Idempotent retry on already `NO_SHOW` | PASS: returns `idempotent:true` without a second audit record |
| Invalid trigger source | PASS: rejected with `invalid_trigger_source` |
| B+ audit record | PASS: before/after state, `business_day`, and `business_timezone` present; full-row snapshot absent |
| `mark_no_show()` wrapper | PASS |
| KDS grace entry | PASS: `HOLD` ticket enters `NO_SHOW_GRACE` and receives `hold_expires_at` |
| `process_expired_no_shows()` | PASS |
| `expire_no_show_kds_hold()` | PASS |
| `recover_no_show_grace_ticket()` success | PASS |
| expired grace recovery rejection | PASS: `no_show_grace_already_expired` |
| missing ticket rejection | PASS: `kds_ticket_not_found` |
| non-grace ticket rejection | PASS: `ticket_not_recoverable` |
| `SKIP LOCKED` behavior | PASS for both waiting-session batch and KDS grace-expiry batch |
| legacy 0050 overload DROP | PASS |
| `WAITING_SESSION_EXPIRE` cron rewrite | PASS |
| forbidden boundary | PASS |

## §5 Codex Stage 4 Execution Findings Preserved for Audit Trail

During Stage 4, Codex found and corrected two implementation-adjacent facts before final verification:

1. `catchmenu_ledger.audit_records.chk_audit_domain` does not permit `waiting`; it permits `session`. The live function was corrected to use `p_audit_domain := 'session'`.
2. `catchmenu_store.store_settings.no_show_kds_grace_minutes` does not currently exist. To avoid an unapproved schema change, `apply_no_show_transition()` uses a dynamic check: if the column exists in a future schema it can be read, otherwise the function falls back to the approved default behavior.

These adjustments preserved the approved scope: only `hold_expires_at` was added as a schema column.

## §6 Triple Verification Notes

### §6.1 Cursor and Antigravity / 안티

Cursor and 안티 independently verified the function inventory, error-key registration, KDS grace state transitions, recovery error paths, cron replacement, and boundary conditions.

Both verified that the old inline `0118` no-show update no longer references the phantom columns:

- `called_at`
- `no_show_at`
- `cancel_reason`

Both also verified the legacy 0050 overload was removed.

### §6.2 Claude Code third independent verification

Claude Code performed a third independent verification run after Cursor and 안티.

Two methodology findings are recorded because they materially improve future verification discipline:

1. **Parallel verifier data intrusion was detected and handled correctly.** Claude Code observed a `processed_count` larger than expected during its own batch verification. Rather than deleting broad data, Claude Code identified the cause as residual test data from other simultaneous reviewers in the same tenant/store scope. Claude Code cleaned only its own test data and did not touch Cursor/안티 data. This is a concrete example of how concurrent verification against the same live database can contaminate aggregate counts.

2. **Claude Code caught its own setup defect in the KDS grace-entry test.** Its first KDS setup omitted the `orders.session_id` reverse link needed by the approved `apply_no_show_transition()` KDS join path. That caused KDS grace entry not to occur. Claude Code recognized the setup error, rebuilt the test with the correct `orders.session_id` relationship, and then confirmed the expected `NO_SHOW_GRACE` transition.

These were verification-methodology corrections, not implementation defects.

## §7 Concurrency Verification

`SKIP LOCKED` was verified with actual row locks:

- A separate interactive transaction locked one `order_sessions` row with `FOR UPDATE`.
- A concurrent `process_expired_no_shows()` call processed only the unlocked row.
- The locked row remained `ARRIVAL_PENDING`; the unlocked row became `NO_SHOW`.

The same pattern was verified for KDS:

- A separate interactive transaction locked one `kds_tickets` row with `FOR UPDATE`.
- A concurrent `expire_no_show_kds_hold()` call processed only the unlocked ticket.
- The locked ticket remained `HOLD/NO_SHOW_GRACE`; the unlocked ticket became `CANCELLED/NO_SHOW_GRACE_EXPIRED`.

## §8 Boundary Verification

Verified unchanged / out of scope:

- `confirm_arrival()`
- unrelated 0115 functions
- Flutter/runtime code
- schemas other than `kds_tickets.hold_expires_at`

The new work is contained in:

- `sql/migrations/0161_mark_no_show_overload_and_redesign.sql`
- Stage 2/6 documentation for the `600630` workpacket

## §9 Open Verification Caveat

The TestPlan-documented limitation remains: the batch functions’ normal `success:false` and per-row failure-accounting paths were covered, but the true `EXCEPTION WHEN OTHERS` branch was not force-triggered with artificial schema breakage or fault injection. This limitation is accepted and documented because forcing that path would require unsafe or test-only mutation outside the normal verification scope.

## §10 New Open Item Candidate

The same class of issue previously observed in `600640` recurred here: when multiple reviewers validate concurrently against the same live DB, their test rows can affect aggregate outputs such as `processed_count`.

Open Item candidate:

> Future §40.3 verification templates should require verifier-specific test-data prefixes, for example `__test_cursor_...`, `__test_ant_...`, `__test_claude_...`, so concurrent live-DB verification does not cross-contaminate aggregate results.

This is a process improvement item only. It is not part of the `0161` implementation scope.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600630_mark_no_show_overload_and_redesign/600637_Audit.md] =====
# 600637_Audit.md

Status: ACCEPT
Lifecycle: Audit
Workpacket: 600630_mark_no_show_overload_and_redesign
Implementation: `0161_mark_no_show_overload_and_redesign.sql`
Date: 2026-07-16

## §1 Audit Decision

Stage 6 audit decision: **ACCEPT**.

The implementation satisfies the approved `600634_ChangeContract.md` scope as corrected and re-approved:

- five-function no-show redesign implemented,
- legacy 0050 `mark_no_show()` overload dropped,
- `0118` cron path updated,
- single approved schema column `kds_tickets.hold_expires_at` added,
- five required error keys pre-registered,
- no unrelated function/runtime scope expanded.

## §2 Acceptance Basis

| Criterion | Audit result |
|---|---|
| Human approval present | ACCEPT |
| Stop Conditions satisfied after error-key expansion | ACCEPT |
| `hold_expires_at` is the only schema addition | ACCEPT |
| Error keys registered before function use | ACCEPT |
| canonical functions exist live | ACCEPT |
| legacy 0050 overload removed | ACCEPT |
| cron no longer uses phantom columns | ACCEPT |
| KDS grace entry/expiry/recovery verified | ACCEPT |
| B+ audit pattern verified | ACCEPT |
| triple independent verification completed | ACCEPT |
| boundary maintained | ACCEPT |

## §3 Material Findings

### §3.1 Error-key prerequisite

Initial Stage 4 execution stopped because five required error keys were absent. The resumed Stage 4 correctly registered those keys before function creation, following the existing 0115-style migration pattern.

### §3.2 Audit domain correction

The conceptual no-show domain is waiting/session, but the live `catchmenu_ledger.audit_records.chk_audit_domain` constraint does not allow `waiting`. The implementation uses `session`, which is live-schema-correct and keeps the audit record within the session/waiting domain.

### §3.3 Store setting column boundary

`store_settings.no_show_kds_grace_minutes` is discussed in design as a future configurable policy value, but it is not part of the approved schema changes in `600634`. The implementation does not add it. It uses a dynamic existence check and falls back to 15 minutes when absent.

### §3.4 Parallel verification data contamination

Claude Code independently observed that concurrent reviewers can contaminate aggregate verification results when using the same tenant/store scope. It diagnosed a larger-than-expected `processed_count` as other verifiers’ residual test data, cleaned only its own data, and did not disturb other reviewers’ rows.

This is accepted as a verification-process finding, not an implementation defect.

### §3.5 Test setup correction

Claude Code also caught its own KDS setup error: without the `orders.session_id` reverse link, the approved KDS grace-entry join path cannot find the order from the session. After correcting the setup, KDS grace entry verified successfully.

This is accepted as a verification-methodology correction, not an implementation defect.

## §4 Boundary Review

No prohibited work was performed:

- `confirm_arrival()` was not modified.
- unrelated 0115 functions were not modified.
- Flutter/runtime code was not modified.
- no schema column other than `kds_tickets.hold_expires_at` was added.
- complex late-arrival exception policy was not implemented.

## §5 Carried Open Items

The following items remain outside this workpacket:

- exact operational tuning for no-show KDS grace duration,
- seat/queue release side effects beyond `session_status='NO_SHOW'`,
- user/staff-facing UI messaging,
- reporting/dashboard interpretation of grace, expiry, and recovery,
- future STAFF/SYSTEM penalty policy divergence,
- explicit role/permission checks inside `mark_no_show()`,
- audit-log cold-data archiving / partitioning,
- complex recovery exceptions such as prepaid adjustment, inventory conflict, or seat reallocation,
- generic `log_diagnostic()` hardening for unregistered error keys / NULL severity leading to `diagnostic_logs.is_recoverable` NOT NULL violations.

## §6 New Process Open Item Candidate

Concurrent live-DB verification should use verifier-specific test-data prefixes.

Recommended future §40.3 template improvement:

```text
Each verifier must use a unique prefix in helper names, correlation IDs,
tenant/store codes, and synthetic rows:
__test_cursor_...
__test_ant_...
__test_claude_...
```

This is the second observed case, after the earlier `600640` verification discussion, where concurrent reviewers could confuse or contaminate one another’s aggregate results.

## §7 Final Decision

`600630_mark_no_show_overload_and_redesign` is accepted as implemented and verified.

Decision: **ACCEPT**.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600641_Overview_Call_Waiting_Customer_Contract_Recovery.md] =====
# 600641_Overview_Call_Waiting_Customer_Contract_Recovery.md

Status: Draft
Lifecycle: Overview
Stage: 1.5
Domain: Waiting / Order Session
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 이 워크패킷의 위치 — 왜 신설됐는가

`600630_mark_no_show_overload_and_redesign`의 `600632_Logic.md`를 작성하던 중, `mark_no_show()`의 진짜 선행조건인 `catchmenu_pos.call_waiting_customer()`(`sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599`)가 실행 시점에 크래시하는 함수임을 확인했다(`600632_Logic.md` 상단 BLOCKED 섹션). Human 결정(ChatGPT+제미나이 교차검증, 옵션 C)에 따라 이 함수의 phantom 컬럼을 "그냥 스키마에 추가"하는 방식은 금지하고, 각 값의 source of truth를 먼저 조사·결정하는 별도 선행 워크패킷으로 이 문서를 신설했다. `600630`은 이 워크패킷의 검증(생산자 복구 PASS) 완료 후 재개한다.

## §1 결함의 정확한 현재 위치 (재확인)

`call_waiting_customer(p_tenant_id, p_store_id, p_session_id, p_table_number default null, p_actor_id default null, p_locale default 'ko', p_correlation_id default null)` — `0115:419-599`.

크래시 지점, `0115:483-493`:
```sql
-- 호출 상태로 변경
update catchmenu_pos.order_sessions
set
  session_status = 'ARRIVAL_PENDING',
  called_at = now(),
  table_number = coalesce(
    p_table_number, table_number
  ),
  call_count = coalesce(call_count, 0) + 1,
  updated_at = now()
where id = p_session_id;
```
`called_at`/`table_number`/`call_count` 3개 모두 라이브 `catchmenu_pos.order_sessions`에 존재하지 않음(재확인, `information_schema.columns` 0 rows). `pre_order_amount`도 앞의 SELECT(`0115:446-449`)와 뒤의 ledger insert/응답(`0115:570-571, 584-587`)에서 참조되나 마찬가지로 phantom.

## §2 (1) `called_at` 조사 결과

**재호출은 설계상 의도된 시나리오다** — `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:291` 상태-액션 매트릭스: `| ARRIVAL_PENDING | ✗ | ✓ 재호출 | ✓ | ✓ | ✓ | ✓ | ✓ |` — 이미 `ARRIVAL_PENDING`인 세션에도 "call" 액션이 "재호출"로 명시 허용된다. `call_count += 1` 서술(`900101...md:183-189`)도 단발성 플래그가 아닌 누적 카운터를 의도한다.

**"최초 호출" vs "최근 호출" 구분은 900xxx 어디에도 없다** — 오직 단일 `called_at` 개념만 쓰이고, 15분 노쇼 타임아웃 조건(`900101...md:261-264`: `session_status='ARRIVAL_PENDING' AND called_at < now() - interval '15 minutes'`)의 기준으로만 쓰인다. 재호출 시 이 타이머가 리셋되어야 하는지는 900xxx 문서 32개 전체에서 논의되지 않은 공백이다(발견, 결정 아님).

**이미 존재하는 정확한 작동 선례 발견 — `0050.call_next_waiting()`**(`0050:151-305`, "call_waiting_customer"와는 다른 이름의 별개 함수, §7 참조). 이 함수는 동일한 "대기 고객 호출" 작업을 phantom 컬럼 없이 정확히 구현하고 있다:
```sql
-- 0050:244-262
insert into catchmenu_pos.session_events (
  tenant_id, store_id, session_id,
  event_type, from_status, to_status,
  caused_by_type, caused_by_id,
  event_payload, correlation_id, occurred_at
) values (
  p_tenant_id, p_store_id, v_session.id,
  'customer_called',
  'WAITING', 'ARRIVAL_PENDING',
  p_actor_type, p_actor_id,
  jsonb_build_object(
    'wait_number', v_session.wait_number,
    'expires_at', v_expire_at,
    'has_pre_order',
      v_session.pre_order_created_at is not null
  ),
  p_correlation_id, now()
);
```
`'customer_called'`는 `session_events`의 CHECK 제약(`chk_session_event_type`) 허용 목록에 실존하는 값이다(라이브 재확인):
```
CHECK (event_type = ANY (ARRAY['session_created','wait_number_assigned','customer_called',
'customer_arrived','table_bound','pre_order_created','pre_order_expired','ordering_started',
'order_confirmed','payment_requested','payment_confirmed','payment_failed','payment_uncertain',
'payment_recovered','session_completed','session_cancelled','session_expired','no_show_marked',
'manual_override','session_reopened']))
```
`order_sessions`에는 `called_at` 대신 `expires_at`(실존 컬럼)을 세팅하는 방식으로 15분 타이머를 표현한다(`0050:237-242`). **`0115`가 처음부터 만들지 말았어야 할 phantom 컬럼을, `0050`은 이미 정확한 방식(이벤트 원장 + 실존 `expires_at`)으로 표현하고 있었다는 뜻이다.**

**옵션(Human 결정 필요, 이 문서는 판단하지 않음)**:
| 옵션 | 내용 |
|---|---|
| A. 이벤트 원장만 | `session_events`에 `'customer_called'` insert(위 패턴 그대로), "언제 호출됐는지"는 `select min/max(occurred_at) where session_id=... and event_type='customer_called'`로 파생. `order_sessions`에 컬럼 추가 없음. |
| B. 캐시 컬럼 병행 | A + `order_sessions.last_called_at`(경량 캐시, 조회 성능용)도 같은 트랜잭션에서 갱신. 이중 저장이지만 `0118` cron 같은 핫패스 쿼리가 조인/서브쿼리 없이 필터링 가능. |

## §3 (2) `call_count` 조사 결과

`0115`의 `coalesce(call_count, 0) + 1`은 **UPDATE의 SET 표현식이 테이블의 현재(락 걸린) 행 값을 직접 참조하므로, 앞선 `for update`(`0115:455`)와 결합하면 이미 원자적이다** — 별도의 원자적 증가 메커니즘을 새로 설계할 필요는 없다(동시 호출 lost update는 행 잠금으로 이미 방지됨). 문제는 원자성이 아니라 `call_count` 컬럼 자체가 라이브에 없다는 것.

`0050.call_next_waiting()`은 애초에 `call_count`라는 개념 자체를 쓰지 않는다 — 호출 횟수가 필요하면 `session_events`에서 `count(*) where session_id=... and event_type='customer_called'`로 완전히 파생 가능하다(중복 저장 회피).

**옵션(Human 결정 필요)**: §2와 동일한 구도 — A) `session_events` COUNT로 파생, B) `order_sessions.call_count int not null default 0`을 캐시 컬럼으로 병행(원자적 증가는 이미 안전한 패턴이므로 그대로 재사용 가능).

## §4 (3) `table_number` 조사 결과

`order_sessions.table_id`(uuid)는 이미 존재하며 `catchmenu_store.dining_tables.id`를 FK로 참조한다(라이브 재확인):
```
order_sessions_table_id_fkey | table_id → catchmenu_store.dining_tables(id)
```
`dining_tables`는 `table_code`(text, not null)/`table_name`/`did_device_id`/`current_session_id` 등 20개 컬럼을 갖는 실제 테이블 마스터다(라이브 재확인). 이미 확립된 조인 패턴(`0025:388-394`, `0048:239-246`)은 표시용 식별자로 `table_code`를 쓴다 — `table_number`라는 이름의 텍스트 컬럼은 이 코드베이스 어디에도(900xxx 포함) `table_id`와 별개 개념으로 정의된 적이 없다.

`900101_Logic...md:189`는 `call_waiting_customer()` 처리에 "table_number 배정 (**선택**)"이라 적고, 같은 문서 `:207`은 `seat_waiting_customer()`에서 "table_number **최종** 배정"이라 적는다 — 즉 900xxx 자체가 "호출 시점 = 선택적 제안, 착석 시점 = 확정"이라는 이분법을 이미 전제하고 있다. 착석 시점의 "확정"은 이미 정상 작동하는 패턴으로 구현돼 있다(`0025:433-453`, `session_events` `'table_bound'` 이벤트에 실제 `table_id`/`table_code` 기록).

호출 시점 쪽은 DID 로직 문서에서 다른 용어를 쓴다 — `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md:112`: `content: {wait_number, table_suggestion}`. **`table_number`가 아니라 `table_suggestion`** — DID 알림 payload 안에만 존재하는 값으로 읽히며, `order_sessions`에 영구 저장해야 한다는 근거가 900xxx 어디에도 없다. TestPlan도 이를 뒷받침한다 — TC-004(호출, `906000...md`)는 "DID가 호출 번호를 표시"/"직원 앱이 호출 상태 표시"만 요구하고, `table_number` 바인딩은 TC-005(착석)에서만 "And `table_number` is bound"로 등장한다.

**"추가 보류"가 유력하다는 원래 가설의 근거가 확인됐다**: `p_table_number` 파라미터는 계속 받되(스태프가 호출 시 "이 테이블로 오세요" 안내를 위해 필요할 수 있음), `notify_channel()` 페이로드(이미 존재하는 코드, `0115:501-531`)에만 전달하고 `order_sessions`에는 영구 저장하지 않는 방향이 900xxx와 라이브 스키마 둘 다와 정합적이다. 다만 이 결정은 이 문서가 최종 확정하지 않는다(Human 결정, §9).

## §5 (4) `pre_order_amount` 조사 결과

`mark_no_show()`와 다르다 — `call_waiting_customer()`는 **불리언뿐 아니라 실제 숫자값을 응답 payload에 그대로 반환**한다:
```sql
-- 0115:583-588
'has_pre_order',
  v_session.pre_order_amount > 0,
'pre_order_amount',
  v_session.pre_order_amount,
```
`pre_order_created_at is not null`로는 불리언(`has_pre_order`)만 대체 가능하고, `pre_order_amount` 자체(스태프가 호출 화면에서 사전주문 금액을 확인하려는 용도로 추정)는 대체되지 않는다. 실제 금액은 `orders.total_amount`/`orders.final_amount`에 존재한다(재확인, `0051_create_pre_order_rpc.sql:300-301`에서 `create_pre_order()`가 설정):
```sql
-- 0051:298-304
update catchmenu_pos.orders
set
  ...
  total_amount = v_total_amount,
  final_amount = v_total_amount,
  ...
```
`call_next_waiting()`(`0050`)은 실제 금액을 아예 응답하지 않고 `has_pre_order` 불리언만 반환한다(`0050:298-299`) — 즉 이 코드베이스에 "호출 시 실제 금액까지 보여주는" 선례는 없다. `call_waiting_customer()`가 실제 금액을 반환하는 것이 진짜 필요(스태프 UX 요구사항)인지, 아니면 `0115` 작성 시점의 과잉 설계인지는 900xxx TestPlan(`906000...md`/`900103...md`)의 픽스처(`pre_order_amount: 18000` 등)에 등장하나 TC-004(호출) 자체의 검증 조건으로 명시되지는 않는다 — 판단 근거가 확정적이지 않다.

**대체 방법(스키마 변경 불필요)**: 필요하다면 `orders o on o.id = v_session.order_id` 조인으로 `o.final_amount`를 읽으면 된다 — `order_sessions.order_id`는 이미 실존 컬럼이고 `create_pre_order()`가 이미 채운다.

## §6 900xxx 서술 + 실제/예정 호출자

**RPC 권한**: `900101_Logic...md:407` — `| call_waiting_customer | OWNER, MANAGER, STAFF | 직원만 |` (staff-only). `900150_Logic_Phase_Validation_Plan_Catch_Menu_To_Yoonsul_Embedded.md:169` — "1. 직원 앱 → call_waiting_customer() 호출".

**실제 호출자: 0건, 예정 호출자만 존재.** `catchmenu_app/lib/features/staff/README.md` 전문 확인:
```
# features/staff — 직원 앱 (Scope B)
900102 ChangeContract 의 waiting_admin Scope 에 해당. Scope D 통과 후 구현.
...
## 예정 파일
- waiting_admin_screen.dart
- waiting_list_tile.dart
- waiting_admin_state_notifier.dart
- waiting_admin_repository.dart
## 허용 동작
- 대기 목록 관리, 호출, 도착 확인, 착석/테이블 배정, 노쇼/호출만료 처리
```
디렉터리 확인 결과 `catchmenu_app/lib/features/staff/`에는 `README.md`만 존재 — `.dart` 파일 0개, "Scope D 통과 후" 구현 예정으로 게이트됨. DID 앱 디렉터리 자체가 리포에 없다. `call_waiting_customer` 문자열이 실제로 등장하는 곳은 이 README(관련 RPC로 언급)뿐, SQL 마이그레이션 외 어디에도 호출 코드가 없다 — `600632_Logic.md`가 이미 확인한 "0건" 결론과 일치.

## §7 구조적 발견 — `call_next_waiting()`과 `call_waiting_customer()`의 중복

이번 조사로 발견된, 원래 지시문에 없던 사실: `0050.call_next_waiting()`(`0050:151-305`)과 `0115.call_waiting_customer()`(`0115:419-599`)는 **이름이 다른 별개 함수**이며(따라서 `mark_no_show()`처럼 Postgres 오버로드 충돌은 아니다), 둘 다 "대기 고객을 호출해 `WAITING`→`ARRIVAL_PENDING` 전환"이라는 같은 목적을 수행하는 중복 구현이다. 기능은 서로의 부분집합이 아니다:

| | `call_next_waiting()` (0050) | `call_waiting_customer()` (0115) |
|---|---|---|
| 컬럼 정합성 | 전부 실존 컬럼 — 정상 작동 | phantom 4종 — 크래시 |
| 대상 선택 | 특정 세션 또는 "큐의 다음 자동 선택"(`p_specific_session_id` 옵션) | 특정 세션만(`p_session_id` 필수) |
| 알림(DID/푸시) | 없음 | `notify_channel()` 3종(WAITING_QUEUE/DID_DISPLAY/SYSTEM_EVENTS) |
| 테이블 제안 | 없음 | `p_table_number` 파라미터 존재 |
| 이벤트 기록 | `session_events` + `catchmenu_ledger.events` 둘 다 | `catchmenu_ledger.events`만(`session_events` insert 없음, `0115` 전체에서 0건) |
| 만료 처리 | `expires_at`(실존) 세팅, `store_settings.no_show_auto_expire_minutes` 사용 | 없음(만료는 별도로 `0118` cron이 `called_at` 기준으로 처리하려 하나 그 자체도 phantom) |

어느 한쪽이 다른 쪽을 완전히 대체할 수 없다 — `0050` 버전은 데이터는 맞지만 알림/테이블 제안 기능이 없고, `0115` 버전은 기능은 맞지만 데이터가 깨져 있다. **이 문서는 병합/폐기/역할 분리 중 어느 방향이 맞는지 판단하지 않는다** — Logic 단계의 Human 결정 사항으로 이월한다(§9).

## §8 부가 발견 — `store_settings`의 이름 불일치

`store_settings`에 만료 관련 컬럼이 2개 존재한다(라이브 재확인): `no_show_auto_expire_minutes`, `wait_call_expire_minutes`. `call_next_waiting()`은 `no_show_auto_expire_minutes`만 사용하고(`0050:222-230`), 이름상 이 시나리오에 더 정확히 맞아 보이는 `wait_call_expire_minutes`는 SQL 전체에서 참조하는 함수가 없다(미사용 컬럼으로 추정, 이번 조사에서 사용처 확인 안 됨). 어느 쪽이 "호출 후 노쇼 타임아웃"의 진짜 설정값인지 Open Item으로 이월한다.

## §9 이 워크패킷의 제안 범위 (Logic 단계에서 확정, 이 문서는 판단하지 않음)

- §2/§3(called_at/call_count)의 옵션 A/B 중 선택.
- §4(table_number) 영구 저장 보류 여부 확정.
- §5(pre_order_amount)의 orders 조인 대체 채택 여부.
- §7(구조적 중복) 처리 방향 — 최소 범위로는 "`call_waiting_customer()`의 데이터 계층만 고치고 `call_next_waiting()`은 그대로 둔다"가 가장 좁지만, 두 함수가 계속 공존/분기하는 것이 맞는지는 별도 판단 필요.
- §8(`wait_call_expire_minutes` 미사용) 처리 여부 — 이번 워크패킷 범위인지 별도 이월인지.
- 이 워크패킷의 산출물이 정확히 무엇인지(예: `call_waiting_customer()`를 `0115`에 새 버전으로 재정의할지, 별도 마이그레이션 파일로 분리할지)도 Logic 단계 결정 사항.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600632_Logic_Mark_No_Show_Overload_And_Redesign.md`(BLOCKED 섹션) — 이 워크패킷을 신설하게 만든 직접 원인.
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md` — 설계 권한 문서, §2-§6 인용 근거.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599` — 수정 대상 `call_waiting_customer()`.
- `sql/migrations/0050_create_waiting_queue_rpc.sql:151-305` — 정상 작동 선례 `call_next_waiting()`, §7의 중복 비교 대상.
- `sql/migrations/0012_create_pos_order_sessions.sql:221-243` — `session_events` `event_type` CHECK 허용 목록.
- `sql/migrations/0025_create_session_rpc.sql:388-453` — `dining_tables` 조인 및 `table_bound` 이벤트 선례.
- `sql/migrations/0051_create_pre_order_rpc.sql:298-304` — `orders.total_amount`/`final_amount` 실제 소스.
- `900101_Logic...md:180-217, 261-264, 291, 407` — 호출/재호출/table_number/권한 서술.
- `900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md:112` — `table_suggestion` DID payload 용어.
- `900103_TestPlan...md` / `906000_TestPlan...md` TC-004/TC-005 — 호출/착석 시점의 검증 조건 구분.
- 라이브 스키마: `catchmenu_pos.order_sessions`/`session_events`, `catchmenu_store.dining_tables`/`store_settings` (본 문서에서 재확인한 컬럼/제약 전체).

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.
- `docs/000053_Matrix_Domain_To_Artifact_Traceability.md:51` — 이 결함을 "미해결"로 이미 등재한 기존 추적 항목.

### Excluded Rule Families

- `0118`의 `WAITING_SESSION_EXPIRE` cron 자체의 수정(§8) — `600630`/`600632` 범위, 이 워크패킷은 생산자 계약만 다룬다.
- `confirm_arrival()`의 phantom 컬럼(`600631_Overview.md` §4) — 범위 밖.
- Flutter/Staff 앱 실제 구현 — Scope D 게이트 이후, 이 워크패킷은 SQL 레이어만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계로 진행 가능 — 단 다수 항목이 Human 결정 대기.** 4가지 조사 사항 전부에 실증적 근거를 확보했다: (1) `called_at`은 이미 정상 작동하는 `session_events`(`'customer_called'`) + `call_next_waiting()`의 `expires_at` 패턴으로 대체 가능(옵션 A/B); (2) `call_count`는 `for update` 락 하에서 이미 원자적이며, 컬럼 자체를 `session_events` COUNT로 파생할 수도 있음(옵션 A/B); (3) `table_number`는 900xxx 자체가 "호출 시 선택적, 착석 시 확정"으로 구분하고 DID 로직 문서는 아예 다른 용어(`table_suggestion`)를 쓰며 TestPlan도 호출 시점 검증에 테이블 바인딩을 요구하지 않아 "영구 저장 보류"가 유력하다는 원래 가설이 뒷받침됨; (4) `pre_order_amount`는 `mark_no_show()`와 달리 실제 숫자 반환이 필요해 보이며 `orders.final_amount` 조인으로 스키마 변경 없이 대체 가능. 예상치 못한 구조적 발견(§7) — `call_next_waiting()`(0050)과 `call_waiting_customer()`(0115)가 서로의 부분집합이 아닌 중복 함수라는 점 — 을 Open Item으로 명시했다. `.sql` 파일은 생성·수정하지 않았다. 다음 단계(`600642_Logic.md`)에서 §9의 각 항목에 대한 Human 결정을 받아 캐노니컬 설계를 확정해야 한다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600642_Logic_Call_Waiting_Customer_Contract_Recovery.md] =====
# 600642_Logic_Call_Waiting_Customer_Contract_Recovery.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Human 결정 요약 (병합 원칙, 재논의 금지)

`call_next_waiting()`(`0050`, 데이터 모델 정확)과 `call_waiting_customer()`(`0115`, 알림/테이블제안 로직 있으나 phantom 컬럼으로 크래시)의 장점을 **합친다** — 둘 중 하나를 골라 버리는 것이 아니다. 이는 오늘 이 세션에서 `600632_Logic.md`가 `0050`의 `arrival_reliability_score -20` 페널티를 `0115` 기반 위에 병합한 것과 동일한 원칙이다. **단, "병합"의 형태는 Q1 결정(§2)에 따라 "하나의 함수로 합치기"가 아니라 "정확한 데이터 계층을 두 함수가 공유하는 하나의 내부 헬퍼로 뽑아내고, 각 함수는 자신의 호출 방식(지정/자동)에 필요한 로직만 유지하기"로 구체화됐다** — 함수는 두 개로 남지만, 정확성(데이터 계층)과 기능(알림/테이블제안)은 중복 없이 한 곳에서 공유된다.

## §1 확정된 4가지 결정 반영 설계

### §1.1 `called_at` → `session_events`의 `'customer_called'` 이벤트로 기록

`call_next_waiting()`(`0050:244-262`)이 이미 쓰는, 라이브 `chk_session_event_type` CHECK 제약에 실존하는 이벤트 타입을 그대로 재사용한다. 신규 컬럼 없음. 실제 INSERT는 §2.1의 공유 헬퍼 안에 위치한다(Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로, 이하 §1.1-§1.4는 개념/근거만 정리하고 구체 SQL은 §2.1에 통합했다).

`from_status`는 하드코딩하지 않고 호출자(§2.2/§2.3)가 넘겨주는 실제 값을 쓴다 — 지정 호출(`call_waiting_customer`)은 재호출 시 `'ARRIVAL_PENDING'`일 수 있고, 자동 호출(`call_next_waiting_customer`)은 큐 선택 조건상 항상 `'WAITING'`이다. `event_payload`에 `table_suggestion` 키를 넣어 §1.3의 "저장은 안 하되 기록/응답에는 남긴다" 요구를 이벤트 원장 레벨에서도 충족시킨다(900161의 DID payload 용어 `table_suggestion`과 일관).

### §1.2 `call_count` → `session_events`에서 `COUNT(*)`로 파생

별도 컬럼 불필요. 공유 헬퍼가 INSERT 직후 같은 트랜잭션에서 집계한다(방금 넣은 행 포함):
```sql
select count(*) into v_call_count
from catchmenu_pos.session_events
where session_id = p_session_id
  and event_type = 'customer_called';
```
호출 경로(지정/자동)에 관계없이 동일 세션에 대한 모든 `'customer_called'` 이벤트를 합산하므로, 두 함수 중 어느 쪽으로 호출됐는지와 무관하게 정확한 누적 횟수가 된다 — 함수를 두 개로 분리하기로 한 Q1 결정과 자연스럽게 맞는다(한쪽 함수만 카운트를 관리했다면 분리 시 카운트가 어긋났을 것). `FOR UPDATE`로 세션 행이 이미 잠겨 있으므로(§2.2/§2.3) 동시 호출 간 이 COUNT 자체에 lost update 문제는 없다.

### §1.3 `table_number` → 저장 보류, 응답/알림에만 포함

`order_sessions`에 대한 UPDATE 문에서 `table_number` 컬럼 자체를 완전히 제거한다(원래 `0115:488-490`에 있던 `table_number = coalesce(p_table_number, table_number)` 절 삭제). `p_table_number`는 지정 호출(§2.2)에만 파라미터로 존재하며 계속 받되:
- `notify_channel()` 3종 호출(원본 `0115:495-532` 로직 그대로 유지)에 그대로 전달.
- §1.1의 `session_events.event_payload.table_suggestion`에 기록.
- 성공 응답 payload에 `table_suggestion`으로 echo.

세션 레코드 자체에는 영구 저장하지 않는다 — 900101이 호출 시점을 "선택사항"으로, TestPlan TC-004가 검증 조건에서 미요구로 명시한 근거를 그대로 따른다. 자동 호출(§2.3)은 애초에 `p_table_number` 파라미터가 없으므로 `null`로 헬퍼에 전달한다(§2.3).

### §1.4 `pre_order_amount` → `orders.final_amount` 조인으로 계산

스키마 변경 없음. `order_sessions.order_id`(실존)를 통해 조인 — 정확한 SELECT는 §2.2/§2.3 각 함수의 세션 조회부에 위치(두 함수 모두 동일 패턴 사용):
```sql
select os.id, os.wait_number, os.session_status,
       os.guest_count, os.guest_locale,
       os.phone_hash, os.customer_id,
       os.pre_order_created_at, os.order_id,
       o.final_amount as pre_order_amount
into v_session
from catchmenu_pos.order_sessions os
left join catchmenu_pos.orders o on o.id = os.order_id
where ...
for update of os;
```
`left join`인 이유: 사전주문 없이 호출되는 세션(`order_id is null`)도 정상 케이스이므로 — 이 경우 `pre_order_amount`는 `null`, `has_pre_order`는 `os.pre_order_created_at is not null`(false)로 자연스럽게 처리된다. `for update of os`로 잠금 대상을 `order_sessions`로 한정(`orders` 잠금 불필요, 락 범위 최소화).

## §2 병합 함수 설계 — 두 함수로 분리 유지, 공통 로직은 내부 헬퍼로 공유 (Human 결정 Q1, 재논의 금지)

**Q1 결정 요약**: 자동 큐 선택 기능은 병합하지 않는다. `call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭)를 별도 함수로 유지하되, 공통 로직(호출 기록/이벤트/알림)은 내부 헬퍼로 공유한다. 이 결정으로 이전 버전 §2.1(함수명 단일화 옵션 비교)과 §2.2(자동 선택 병합 여부 Open Item)는 해소됐다 — 더 이상 "하나로 합칠지" 선택하는 문제가 아니라, "두 함수가 공통 코어를 어떻게 공유하는지" 설계 문제로 바뀌었다.

### §2.1 공유 내부 헬퍼 — `catchmenu_pos._record_waiting_call()`

PL/pgSQL 함수 파라미터는 익명 `record` 타입을 받을 수 없으므로(리턴 타입으로만 가능), 헬퍼는 두 호출자가 이미 조회·검증까지 마친 세션 정보를 개별 스칼라 파라미터로 전달받는 방식으로 설계한다 — 세션 조회/상태 게이트/만료시각 계산은 각 공개 함수(§2.2/§2.3)가 자신의 시나리오에 맞게 수행하고, "호출 확정 이후" 공통 부분(UPDATE, 이벤트 기록, 알림, 응답 조립)만 헬퍼가 담당한다.

```sql
create or replace function catchmenu_pos._record_waiting_call(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_from_status text,
  p_wait_number int,
  p_guest_locale text,
  p_phone_hash text,
  p_customer_id uuid,
  p_has_pre_order boolean,
  p_pre_order_amount int,
  p_table_number text,
  p_expires_at timestamptz,
  p_actor_type text,
  p_actor_id uuid,
  p_locale text,
  p_correlation_id text
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_common, catchmenu_ledger
as $$
declare
  v_call_count int;
begin
  -- 세션 상태 전이 + 만료시각 스냅샷 저장 (§4)
  update catchmenu_pos.order_sessions
  set
    session_status = 'ARRIVAL_PENDING',
    expires_at = p_expires_at,
    updated_at = now()
  where id = p_session_id;

  -- session_events (§1.1)
  insert into catchmenu_pos.session_events (
    tenant_id, store_id, session_id,
    event_type, from_status, to_status,
    caused_by_type, caused_by_id,
    event_payload, correlation_id, occurred_at
  ) values (
    p_tenant_id, p_store_id, p_session_id,
    'customer_called',
    p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number,
      'table_suggestion', p_table_number,
      'expires_at', p_expires_at,
      'has_pre_order', p_has_pre_order
    ),
    p_correlation_id, now()
  );

  -- call_count 파생 (§1.2)
  select count(*) into v_call_count
  from catchmenu_pos.session_events
  where session_id = p_session_id and event_type = 'customer_called';

  -- 알림 3종 (0115:495-532 원문 로직 그대로)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE', p_event_type := 'waiting_called',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_number', p_table_number, 'guest_locale', p_guest_locale,
      'called_at', now(),
      'message', catchmenu_common.get_message(
        'waiting_called_alert', p_guest_locale,
        jsonb_build_object('wait_number', p_wait_number)
      )
    )
  );
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY', p_event_type := 'WAITING_CALL',
    p_payload := jsonb_build_object(
      'session_id', p_session_id, 'display_number', p_wait_number,
      'table_number', p_table_number, 'queue_type', 'WAITING_CALL',
      'guest_locale', p_guest_locale
    )
  );
  if p_phone_hash is not null then
    perform catchmenu_common.notify_channel(
      p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_channel_type := 'SYSTEM_EVENTS', p_event_type := 'push_notification_queued',
      p_payload := jsonb_build_object(
        'phone_hash', p_phone_hash, 'customer_id', p_customer_id,
        'notification_type', 'WAITING_CALLED', 'wait_number', p_wait_number,
        'table_number', p_table_number, 'locale', p_guest_locale
      )
    );
  end if;

  -- ledger event (특허1, 두 원본 함수 모두 이미 쓰던 패턴)
  insert into catchmenu_ledger.events (
    tenant_id, store_id, event_domain, event_type, event_version,
    subject_type, subject_id, from_state, to_state,
    caused_by_type, caused_by_id, event_payload, session_id,
    correlation_id, business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id, 'session', 'customer_called', 1,
    'order_session', p_session_id, p_from_status, 'ARRIVAL_PENDING',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', p_wait_number, 'has_pre_order', p_has_pre_order,
      'pre_order_amount', p_pre_order_amount
    ),
    p_session_id, p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_called_alert',
    p_data := jsonb_build_object(
      'session_id', p_session_id, 'wait_number', p_wait_number,
      'table_suggestion', p_table_number, 'guest_locale', p_guest_locale,
      'has_pre_order', p_has_pre_order, 'pre_order_amount', p_pre_order_amount,
      'call_count', v_call_count, 'expires_at', p_expires_at,
      'did_called', true, 'push_sent', p_phone_hash is not null
    ),
    p_locale := p_locale,
    p_params := jsonb_build_object('wait_number', p_wait_number),
    p_correlation_id := p_correlation_id
  );
end;
$$;
```
헬퍼는 `security definer`이지만 스키마 프리픽스(`_record_waiting_call`, 언더스코어 관례)로 "내부 전용, 직접 호출 대상 아님"을 표시한다 — 실제 접근 제어(권한 REVOKE 등)는 Stage 4 구현 시 프로젝트의 기존 internal-helper 관례를 따른다(이 문서는 명명 관례만 제안, 권한 설계는 범위 밖).

### §2.2 `call_waiting_customer()` — 지정 호출 (기존 `0115` 이름/시그니처 유지, `CREATE OR REPLACE`)

```sql
create or replace function catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 상태 게이트: WAITING/ARRIVAL_PENDING 둘 다 허용 (재호출 지원, 0115:467-481 원문 유지 —
  -- 900101:291 "✓ 재호출"과 정합. 0050의 WAITING-only보다 이쪽이 설계 문서와 일치.
  if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
    return catchmenu_common.build_error_response(
      p_error_key := case v_session.session_status
        when 'SEATED' then 'waiting_already_seated'
        else 'waiting_not_callable'
      end,
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_waiting_customer'
    );
  end if;

  -- 만료시각 스냅샷 계산 (§4 — wait_call_expire_minutes 채택, 매장별 설정)
  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := v_session.session_status,
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := p_table_number, p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

### §2.3 `call_next_waiting_customer()`(가칭) — 자동 다음 호출 (신규 함수, `0050.call_next_waiting()`의 자동 선택 로직 이식)

"가칭"인 이유: Human 결정문이 이 이름을 "(가칭)"으로 명시했다 — 함수를 별도로 유지한다는 것과 그 역할(자동 큐 선택)은 확정이지만, 정확한 최종 명칭은 아직 확정이 아니다.

```sql
create or replace function catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_expire_at timestamptz;
begin
  -- 자동 선택 (0050:194-211 원문 로직 그대로 — WAITING만 대상, 재호출 개념 없음)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.session_status = 'WAITING'
  order by
    coalesce(os.queue_position, os.wait_number) asc nulls last,
    os.session_started_at asc
  limit 1
  for update of os skip locked;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'no_waiting_session_found',
      p_locale := p_locale, p_tenant_id := p_tenant_id,
      p_store_id := p_store_id, p_rpc_name := 'call_next_waiting_customer'
    );
  end if;

  select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
  into v_expire_at
  from catchmenu_store.store_settings ss
  where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
  v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');

  return catchmenu_pos._record_waiting_call(
    p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_session_id := v_session.id, p_from_status := 'WAITING',
    p_wait_number := v_session.wait_number, p_guest_locale := v_session.guest_locale,
    p_phone_hash := v_session.phone_hash, p_customer_id := v_session.customer_id,
    p_has_pre_order := v_session.pre_order_created_at is not null,
    p_pre_order_amount := v_session.pre_order_amount,
    p_table_number := null,  -- 자동 호출 경로는 p_table_number 파라미터 자체가 없음(§1.3)
    p_expires_at := v_expire_at,
    p_actor_type := 'STAFF', p_actor_id := p_actor_id,
    p_locale := p_locale, p_correlation_id := p_correlation_id
  );
end;
$$;
```

### §2.4 DROP / CREATE 대상 — Q1로 확정

| 대상 | 처리 |
|---|---|
| `catchmenu_pos.call_next_waiting(uuid, uuid, text, uuid, uuid, text)`(`0050:151-305`) | **DROP**. 자동 선택 로직은 `call_next_waiting_customer()`로 완전히 이식되므로 대체됨. |
| `catchmenu_pos.call_waiting_customer(...)`(`0115:419-599`) | **DROP하지 않고 `CREATE OR REPLACE`**(시그니처 동일 유지 — 900xxx 21곳 인용과의 정합성, §2.1 옛 버전의 "옵션 A" 방향이 이번 Q1 결정으로 사실상 그대로 확정됨). |
| `catchmenu_pos.call_next_waiting_customer(...)`(가칭) | **신규 CREATE**. |
| `catchmenu_pos._record_waiting_call(...)` | **신규 CREATE**(internal 헬퍼). |

셋 다(DROP 대상 포함) 실호출자 0건이므로 이 변경 자체의 실행 리스크는 없다(재확인, `600631_Overview.md`/`600641_Overview.md`에서 이미 두 함수 모두 SQL/Flutter 어디서도 호출되지 않음을 확인).

## §3 §7 구조적 문제의 완전한 해소

`600641_Overview.md` §7이 지적한 "duplicate, non-overlapping implementations"(데이터는 맞지만 알림이 없는 `0050` vs 알림은 있지만 데이터가 깨진 `0115`) 문제는 이 설계로 완전히 해소된다 — Q1 결정으로 두 함수(지정 호출/자동 호출)가 계속 별도로 존재하게 됐지만, **더 이상 "우연히 중복된 두 구현"이 아니라 "의도적으로 역할이 분리된 두 진입점이 하나의 검증된 공통 코어(`_record_waiting_call()`)를 공유하는" 구조**로 바뀐다. 데이터 계층(§1.1-§1.4)과 알림/이벤트 기록 로직은 정확히 한 곳(헬퍼)에만 존재하므로, "기능은 맞지만 데이터가 깨진 버전"과 "데이터는 맞지만 기능이 없는 버전"이 별도로 존재하던 이전 상태는 사라진다 — 두 진입점 중 어느 쪽으로 호출되든 동일한 정확한 데이터 처리를 보장받는다.

## §4 `store_settings` 설정값 — 최종 확정 (Human 결정 Q2 + 시간 값 원칙, 재논의 금지)

### §4.1 재확인된 사실관계 (변경 없음, 근거로 유지)

```sql
-- 0049:42-43 (테이블 정의, "waiting settings" 섹션에 순서대로 인접)
wait_call_expire_minutes int not null default 5,
no_show_auto_expire_minutes int not null default 10,
```
- `wait_call_expire_minutes`: `0049`에서 정의되고(L42), `get_store_settings()` 응답 JSON에 노출된다(L230-231) — 이전까지는 이 컬럼을 실제로 읽는 함수가 SQL 전체에 0건이었다.
- `no_show_auto_expire_minutes`: `0049`에서 정의되고(L43) `get_store_settings()`에 노출되며(L232-233), `0050.call_next_waiting()`이 유일하게 읽어 `expires_at` 계산에 쓰던 소비처였다(`0050:222-230`).
- `0118`의 `WAITING_SESSION_EXPIRE` cron(`600630`/`600632` 범위)은 이 두 컬럼 중 어느 쪽도 읽지 않고 `interval '15 minutes'`를 하드코딩한다 — 이 워크패킷의 확정 범위 밖이므로 그대로 이월(§7 항목 2).

### §4.2 확정 — `wait_call_expire_minutes`를 canonical로 채택 (Q2)

이름이 실제 의미("호출 후 응답 대기시간")와 정확히 일치하는 `wait_call_expire_minutes`를 canonical 설정으로 확정한다. §2.2/§2.3의 만료 시각 계산은 이미 이 컬럼을 사용하도록 설계했다:
```sql
select now() + (coalesce(ss.wait_call_expire_minutes, 5) || ' minutes')::interval
into v_expire_at
from catchmenu_store.store_settings ss
where ss.store_id = p_store_id and ss.tenant_id = p_tenant_id;
v_expire_at := coalesce(v_expire_at, now() + interval '5 minutes');
```
`no_show_auto_expire_minutes`(`0050.call_next_waiting()`의 옛 소비처)의 이전 사용처는 이번 병합으로 `wait_call_expire_minutes`로 완전히 이전된다 — `call_next_waiting_customer()`(§2.3)도 동일하게 `wait_call_expire_minutes`만 읽는다.

`no_show_auto_expire_minutes`는 **즉시 DROP하지 않는다** — deprecated 표시만 하고 컬럼은 남긴다:
```sql
comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';
```
컬럼 제거 자체는 별도 후속 정리 워크패킷의 범위로 명시적으로 이월한다(§7 항목 1).

### §4.3 만료시각 스냅샷 저장 원칙 (Q2)

`expires_at`은 호출 시점에 **스냅샷으로 고정 저장**한다 — `now() + wait_call_expire_minutes`를 호출 시 1회 계산해 컬럼에 저장하고, 이후 이 값을 다시 계산하지 않는다(§2.1 헬퍼의 `update ... set expires_at = p_expires_at`). 재호출 시(`call_waiting_customer()`를 `ARRIVAL_PENDING` 세션에 다시 호출하는 경우) 헬퍼가 다시 실행되며 `expires_at`도 그 시점 기준으로 재스냅샷된다 — 이는 자연스럽게 "재호출하면 응답 대기시간이 그 시점부터 다시 시작된다"는 동작이 되며, §2 옛 버전에서 미해결로 남겼던 "재호출 시 타이머 리셋 여부"(900xxx 공백 영역)에 대해 이 설계가 실질적인 답을 제공한다 — 다만 이것이 최적의 운영 정책인지는 여전히 실제 데이터로 검증될 사안이다(§4.4).

### §4.4 매장별 설정 가능 원칙 (Human 결정, 재확인 문구)

**`wait_call_expire_minutes`의 정확한 유예 시간(몇 분)은 지금 하나의 값으로 확정하지 않는다.** 이 문서는 `store_settings`의 현재 스키마 기본값(`0049:42`, 5분)을 그대로 default로 유지할 뿐, 이 값이 모든 매장에 적용될 "정답"이라고 주장하지 않는다. `store_settings`는 이미 매장(`store_id`) 단위로 행이 존재하는 구조이므로, **이 값은 매장마다 자유롭게 재설정 가능해야 하며 이미 그렇게 설계되어 있다** — `catchmenu_store.get_store_settings()`/`update_business_hours()` 등 기존 `0049` RPC들이 이미 매장별 조회/수정을 전제로 하는 것과 동일한 구조를 그대로 따른다. 실제 운영 데이터가 쌓이면 매장마다 최적값이 다를 것을 전제로 하며, 이는 `600632_Logic.md`가 이미 확립한 "지금 결정은 확정이 아니다" 원칙의 연장선이다 — 하드코딩 금지, 조정 가능한 설정으로 유지, 향후 데이터 기반 재조정을 전제로 한다.

## §5 범위 경계 — 이 워크패킷이 다루는 "노쇼"의 정의 (제미나이 분류 활용, Human 결정)

이 워크패킷(및 상위 `600630`/`600632`)이 다루는 "노쇼"는 **웨이팅(대기열) 노쇼**로 한정한다 — 순수 대기 노쇼, 사전주문 대기 노쇼(`has_pre_order`로 구분되는 것)만이 범위다. 아래 4개 범주는 완전히 다른 정책(결제/환불 방어, 좌석 점유, 폐기 비용, 블랙리스트)이 필요한 별도 도메인이며, 이번 워크패킷 및 `600630`/`600632`의 설계·구현 범위에 포함되지 않는다:

| 노쇼 유형 | 특징 | 이번 범위 포함 여부 |
|---|---|---|
| **웨이팅(대기열) 노쇼** | 순수 대기 / 사전주문 대기, `has_pre_order`로 구분 | **포함** (`600630`/`600632`/`600640`/`600642`) |
| 포장/픽업 노쇼 | 선결제 미수령(환불 처리 필요) 또는 현장결제 악성 노쇼(조리된 음식 폐기 비용 발생) | 범위 밖 |
| 예약 노쇼 | 전체 노쇼/부분 노쇼(일부 인원만 도착)/지각 — 좌석을 미리 점유해 둔 상태에서의 기회비용 문제 | 범위 밖 |
| 단체·케이터링 노쇼 | 대규모 사전 준비(식자재/인력)가 걸린 고액 리스크 | 범위 밖 |
| 배달 연락두절 | 배달원/고객 연락 두절, 배달 특유의 물류·환불 문제 | 범위 밖 |

이 분류는 향후 각 유형별로 별도 워크패킷이 필요할 수 있음을 명시하기 위한 참고 자료로 기록하며, 이번 워크패킷에서 어떤 설계도 선결정하지 않는다.

## §6 향후 전략 아이디어 — 이번 범위 아님 (기록용)

**노쇼 블랙리스트/페널티 시스템**(제미나이 제안): 반복적으로 악성 노쇼를 저지르는 고객의 계정을 정지하거나 향후 예약/대기 시 선결제를 강제하는 시스템. 이는 개별 세션이 아니라 **고객 계정을 가로지르는 별도 도메인**(현재 `arrival_reliability_score`가 세션 단위로만 존재하는 것과 달리, 고객 단위 누적 이력·정책 집행이 필요)이며, 이번 워크패킷 범위에 포함하지 않는다 — 향후 전략 아이디어로만 기록한다.

## §7 Open Items (Human 결정 필요, 이전 §5의 1-4번은 이번 Q1/Q2 결정으로 해소됨)

1. `no_show_auto_expire_minutes` 컬럼의 실제 DROP 시점 — §4.2에서 deprecated 표시만 하기로 확정했으나, 실제 제거는 별도 후속 정리 워크패킷(가칭 `store_settings_deprecated_column_cleanup`)의 범위로 이월.
2. `0118`의 `WAITING_SESSION_EXPIRE` cron이 여전히 `interval '15 minutes'` 하드코딩(어느 `store_settings` 컬럼도 읽지 않음) — 이 워크패킷이 `wait_call_expire_minutes`를 canonical로 확정했으므로, `600630`/`600632`가 그 cron을 고칠 때 이 컬럼을 반영해야 한다는 점을 교차 참조로 남긴다(`600632_Logic.md`의 §8 갱신 필요 여부는 `600630` 쪽 판단).
3. §1.2의 `call_count` COUNT(*) 방식이 응답 payload 표시 목적 이상(예: N회 이상 재호출 시 자동 알림 등 향후 정책)으로 쓰일 가능성이 있다면 컬럼화가 필요할 수 있음 — 현재는 표시 전용으로 가정, 추가 요구사항 발견 시 재검토.
4. `call_next_waiting_customer()`의 최종 명칭 확정 — "(가칭)" 상태(§2.3).
5. §5/§6에서 범위 밖으로 명시한 4개 노쇼 유형 및 블랙리스트 시스템 — 각각 별도 워크패킷 필요 여부와 우선순위는 이 문서가 판단하지 않음.
6. 이 워크패킷의 Stage 4 구현이 완료·검증(PASS)되어야 `600630`/`600632`의 BLOCKED 상태가 해제된다 — 순서 의존성 재확인.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` — 이 문서의 직접 전제(4가지 결정의 증거 전체).
- `600632_Logic_Mark_No_Show_Overload_And_Redesign.md`(BLOCKED 섹션) — 이 워크패킷의 완료 조건을 요구하는 다운스트림 문서.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:419-599` — 병합 베이스(알림/게이트/시그니처).
- `sql/migrations/0050_create_waiting_queue_rpc.sql:151-305` — 병합 베이스(데이터 계층/이벤트 기록).
- `sql/migrations/0012_create_pos_order_sessions.sql:221-243` — `session_events` `event_type` CHECK 허용 목록.
- `sql/migrations/0049_create_store_settings_rpc.sql:17-60, 220-235` — `store_settings` 두 컬럼 정의/노출부, §4 근거.
- `sql/migrations/0051_create_pre_order_rpc.sql:298-304` — `orders.final_amount` 소스.
- 900xxx 21곳 `call_waiting_customer` 인용(전체 목록은 grep 결과, §2.4의 이름 유지 결정 근거) — 특히 `900161_Logic...md:104`(단일 세션 트리거 서술).

### Domain Indexes

- `600602_NavigationMap_Waiting_Order_Session.md`.

### Excluded Rule Families

- `0118`의 cron 자체 수정 — `600630`/`600632` 범위, 이 문서는 `store_settings` 컬럼 사실관계만 제공(§4).
- `confirm_arrival()` phantom 컬럼 — 범위 밖(기존 확정 유지).
- Flutter Staff 앱 실제 구현 — Scope D 게이트 이후.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**§2/§4 최종 확정 완료 — Q1/Q2 반영, 잔여 Open Item은 부수적 사안으로 축소.** §1의 4가지 결정(called_at→session_events, call_count→COUNT(*), table_number→저장보류, pre_order_amount→orders 조인)을 구체적 SQL로 설계했다. §2는 Human 결정 Q1(자동 큐 선택 기능은 병합하지 않고 별도 함수 유지, 공통 로직은 내부 헬퍼 `_record_waiting_call()`로 공유)을 전면 반영해 재작성했다 — `call_waiting_customer()`(지정 호출, `0115` 이름/시그니처 유지)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭, `0050`의 자동 선택 로직 이식)를 완전한 SQL 본문으로 설계했고, §2.4에서 DROP/CREATE 대상을 확정했다(더 이상 옵션 비교가 아님). §3에서 `600641_Overview.md` §7의 구조적 중복 문제가 "의도적 역할 분리 + 공유 코어" 구조로 완전히 해소됨을 명시했다. §4는 Human 결정 Q2(`wait_call_expire_minutes`를 canonical로 확정, `no_show_auto_expire_minutes`는 deprecated 표시만 하고 즉시 DROP하지 않음, 만료시각은 호출 시점 스냅샷으로 고정 저장)와 "매장별 설정 가능" 원칙(기본값 5분 유지하되 `store_settings`를 통해 매장마다 자유롭게 재설정 가능해야 함을 명시적으로 재확인 — `600632_Logic.md`가 확립한 "지금 결정은 확정이 아니다" 원칙의 연장)을 반영해 확정했다. §5/§6에서 제미나이의 4대 노쇼 유형 분류(포장/픽업, 예약, 단체·케이터링, 배달)와 노쇼 블랙리스트 시스템 아이디어를 이번 범위 밖으로 명시적으로 경계 짓고 향후 참고용으로 기록했다. `.sql` 파일은 생성·수정하지 않았다. §7의 6개 잔여 Open Item(대부분 후속 정리/이월성 사안, Q1/Q2처럼 이 워크패킷의 캐노니컬 설계 자체를 좌우하는 사안은 아님)에 대한 Human 결정 이후 `600643_TestPlan.md`로 진행한다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600643_TestPlan.md] =====
# 600643_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 Test Plan
Owner: Codex
Revision: 2 (Claude Code, 2026-07-16) — added §4.3 (pre_order_amount coverage for call_next_waiting_customer()) and §6.2 (true cross-path call-count accumulation), per independent verification findings
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Purpose

This TestPlan verifies the confirmed `600641` / `600642` design for recovering the waiting-call contract.

The implementation under test is expected to:

- introduce internal helper `catchmenu_pos._record_waiting_call()`,
- redefine `catchmenu_pos.call_waiting_customer()` with the existing `0115` name/signature,
- create public `catchmenu_pos.call_next_waiting_customer()`,
- drop legacy `catchmenu_pos.call_next_waiting()` from `0050`,
- use `catchmenu_store.store_settings.wait_call_expire_minutes` as the canonical call-expiry setting,
- mark `store_settings.no_show_auto_expire_minutes` as deprecated by COMMENT only,
- avoid new schema columns.

The helper is internal and is not tested directly. Its behavior is covered through the two public functions.

## §1 Preconditions

### §1.1 Function inventory before implementation

Before Stage 4 changes, record current function state:

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname in (
    '_record_waiting_call',
    'call_waiting_customer',
    'call_next_waiting',
    'call_next_waiting_customer'
  )
order by p.proname, args;
```

Expected before implementation:

- `call_waiting_customer(...)` exists.
- `call_next_waiting(...)` exists.
- `_record_waiting_call(...)` does not exist.
- `call_next_waiting_customer(...)` does not exist.

Expected after implementation:

- `_record_waiting_call(...)` exists.
- `call_waiting_customer(...)` exists with the existing `0115` signature.
- `call_next_waiting_customer(...)` exists.
- `call_next_waiting(...)` no longer exists.

### §1.2 Store setting inventory

Confirm both setting columns exist before implementation:

```sql
select column_name, data_type, is_nullable, column_default
from information_schema.columns
where table_schema = 'catchmenu_store'
  and table_name = 'store_settings'
  and column_name in (
    'wait_call_expire_minutes',
    'no_show_auto_expire_minutes'
  )
order by column_name;
```

Expected:

- `wait_call_expire_minutes` exists.
- `no_show_auto_expire_minutes` exists.
- no new setting column is required.

### §1.3 Test isolation

All live execution tests must run in transactions and end with `ROLLBACK`, unless the test is only reading metadata.

Any temporary helper used for concurrency orchestration must:

- start with `__test_`,
- include a verifier-specific suffix if multiple verifiers run in parallel,
- be dropped before the test completes.

## §2 Test A — `call_waiting_customer()` state gate and success paths

### §2.1 WAITING succeeds

Setup:

1. Create a test `order_sessions` row in `WAITING`.
2. Ensure the store has a known `wait_call_expire_minutes` value.
3. Call:

```sql
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<waiting_session_id>'::uuid,
  p_table_number := 'T-01',
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := '__test_call_waiting_waiting'
);
```

Expected:

- `success = true`.
- `order_sessions.session_status = 'ARRIVAL_PENDING'`.
- `order_sessions.expires_at` is set.
- `session_events` contains `event_type = 'customer_called'`.
- `catchmenu_ledger.events` contains the corresponding waiting-call event.
- response/event payload may include table suggestion, but `order_sessions` does not store `table_number`.

### §2.2 ARRIVAL_PENDING succeeds as recall

Setup:

1. Use the same session after §2.1 or create a fresh `ARRIVAL_PENDING` test session.
2. Record the previous `expires_at`.
3. Call `call_waiting_customer()` again.

Expected:

- `success = true`.
- status remains `ARRIVAL_PENDING`.
- `expires_at` is re-snapshotted and is later than the previous value.
- `session_events` now has two `customer_called` events for the session.
- `call_count`, derived as `count(*)` from `session_events`, equals 2.

### §2.3 Non-callable states are rejected

Run separate test rows for at least:

- `SEATED`
- `COMPLETED`

Call `call_waiting_customer()` for each.

Expected:

- `success = false`.
- no `customer_called` session event is inserted.
- no waiting-call ledger event is inserted.
- session status does not change.

If additional terminal states are easy to instantiate, include them as regression coverage.

## §3 Test B — `call_waiting_customer()` payload/source-of-truth behavior

### §3.1 `table_number` is not stored on session

Call `call_waiting_customer()` with `p_table_number`.

Verify:

```sql
select *
from information_schema.columns
where table_schema = 'catchmenu_pos'
  and table_name = 'order_sessions'
  and column_name = 'table_number';
```

Expected:

- zero rows.
- implementation must not add `order_sessions.table_number`.

Then verify the table suggestion appears only in allowed places:

- function response payload, if included,
- `session_events.event_payload`,
- `catchmenu_ledger.events.event_payload`,
- notification payloads, if observable in the function output/log.

### §3.2 `pre_order_amount` comes from `orders.final_amount`

Create a session with `pre_order_created_at is not null` and a linked order with known `final_amount`.

Call `call_waiting_customer()`.

Expected:

- `has_pre_order = true`.
- returned/prepared `pre_order_amount` equals linked `orders.final_amount`.
- no reference to `order_sessions.pre_order_amount` remains in the live function definition.

Verification:

```sql
select position('pre_order_amount' in pg_get_functiondef(
  'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)'::regprocedure
));
```

The string may still appear as a response variable/key, but it must not appear as `v_session.pre_order_amount` sourced from `order_sessions`.

## §4 Test C — `call_next_waiting_customer()` automatic selection

### §4.1 Oldest/lowest queue position selected

Setup:

1. Create at least three `WAITING` sessions for the same tenant/store.
2. Give them different `queue_position` / `wait_number` / `session_started_at` values.
3. Call:

```sql
select catchmenu_pos.call_next_waiting_customer(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := '__test_call_next_waiting_1'
);
```

Expected:

- the selected session is the earliest by the confirmed ordering:
  - `coalesce(queue_position, wait_number) asc nulls last`,
  - `session_started_at asc`.
- selected session becomes `ARRIVAL_PENDING`.
- non-selected sessions remain `WAITING`.
- exactly one `customer_called` session event is inserted for the selected session.

### §4.2 No waiting session found

Setup:

- no sessions in `WAITING` for the tenant/store.

Call `call_next_waiting_customer()`.

Expected:

- `success = false`.
- error key is `no_waiting_session_found`.
- no session/event rows are changed.

### §4.3 `pre_order_amount` comes from `orders.final_amount` (auto-selected session)

Same requirement as §3.2, verified for the automatic-selection path — `600642_Logic.md` §1.4 states both public functions use the identical `orders` join, so both must be independently verified.

Setup:

1. Create a `WAITING` session with `pre_order_created_at is not null` and a linked order with a known `final_amount`.
2. Ensure it is the earliest session by the confirmed queue ordering (§4.1), so it is the one auto-selected.
3. Call `call_next_waiting_customer()`.

Expected:

- `success = true`, the session from step 1 is selected.
- `has_pre_order = true`.
- returned/prepared `pre_order_amount` equals the linked `orders.final_amount`.
- no reference to `order_sessions.pre_order_amount` remains in the live function definition:

```sql
select position('pre_order_amount' in pg_get_functiondef(
  'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)'::regprocedure
));
```

The string may still appear as a response variable/key, but it must not appear as `v_session.pre_order_amount` sourced directly from `order_sessions`.

## §5 Test D — `call_next_waiting_customer()` concurrency / `SKIP LOCKED`

### §5.1 Two concurrent calls choose different sessions

Setup:

1. Create at least two `WAITING` sessions for the same tenant/store.
2. Use two independent DB sessions.
3. In both sessions, call `call_next_waiting_customer()` concurrently.

Implementation note:

- If a test helper is needed to hold locks and widen the race window, use `__test_` prefix and drop it immediately after the test.

Expected:

- both calls succeed if two waiting sessions exist.
- each call returns/updates a different session.
- both sessions become `ARRIVAL_PENDING`.
- no duplicate selection occurs.
- `session_events` contains one `customer_called` event per selected session.

### §5.2 Race boundary when only one waiting session exists

Setup:

- create exactly one `WAITING` session.
- run two concurrent calls.

Expected:

- one call succeeds.
- the other returns `no_waiting_session_found` or equivalent no-row result after `SKIP LOCKED`.
- no duplicate event is created for the same automatic selection.

## §6 Test E — cross-path call count accumulation

### §6.1 Same-function accumulation (`call_waiting_customer()` twice)

Setup:

1. Create one `WAITING` session.
2. Call `call_waiting_customer()` once.
3. Call `call_waiting_customer()` again for the same `ARRIVAL_PENDING` session.

Expected:

- `session_events` count for `event_type = 'customer_called'` is 2.
- derived `call_count` is 2.

If Stage 4 exposes `call_count` in either function response, verify it matches the event count.

### §6.2 True cross-path accumulation (`call_next_waiting_customer()` then `call_waiting_customer()` recall)

This is a realistic operational sequence — the system auto-calls the next customer, then staff manually recalls the same customer later — and is the only scenario that actually exercises both public functions writing to the same session's call history through the shared helper. This supersedes the previous (incorrect) "cross-path consistency cannot be tested" note.

Setup:

1. Create one `WAITING` session (only one, or ensure it is the earliest by the confirmed queue ordering so §5's `call_next_waiting_customer()` selects it deterministically).
2. Call `call_next_waiting_customer()` — the session transitions `WAITING` → `ARRIVAL_PENDING`.
3. Call `call_waiting_customer()` with the same `p_session_id` — a recall on the now-`ARRIVAL_PENDING` session.

Expected:

- both calls return `success = true`.
- `session_events` count for `event_type = 'customer_called'` on this session is exactly 2.
- the first `session_events` row (from step 2) has `from_status = 'WAITING'`, `to_status = 'ARRIVAL_PENDING'`.
- the second `session_events` row (from step 3) has `from_status = 'ARRIVAL_PENDING'`, `to_status = 'ARRIVAL_PENDING'`.
- derived `call_count` (via `count(*)` on `session_events`) is 2 immediately after step 3, confirming the two public functions accumulate into the same counter through `_record_waiting_call()`.
- `order_sessions.expires_at` after step 3 reflects the step-3 snapshot (later than the step-2 value), per §2.2's re-snapshot behavior.

## §7 Test F — store-specific `wait_call_expire_minutes`

Setup:

1. Create or update two test stores with different `wait_call_expire_minutes` values.
2. Create one waiting session per store.
3. Call either public function for each store.

Expected:

- each session's `expires_at` reflects that store's configured value.
- `no_show_auto_expire_minutes` is not used for the calculation.
- changing `wait_call_expire_minutes` before a recall causes the next call to snapshot the new configured duration.

### §7.1 Deprecated comment check

After implementation, verify:

```sql
select col_description(
  'catchmenu_store.store_settings'::regclass,
  (
    select ordinal_position
    from information_schema.columns
    where table_schema = 'catchmenu_store'
      and table_name = 'store_settings'
      and column_name = 'no_show_auto_expire_minutes'
  )
);
```

Expected:

- comment contains `DEPRECATED`.
- column still exists.
- column is not dropped.

## §8 Test G — event and ledger consistency

For both public paths:

- `call_waiting_customer()`
- `call_next_waiting_customer()`

Verify:

```sql
select event_type, from_status, to_status, event_payload
from catchmenu_pos.session_events
where session_id = '<session_id>'::uuid
  and event_type = 'customer_called';
```

Expected:

- event type is `customer_called`.
- `from_status` reflects the actual previous state:
  - `WAITING` for first call,
  - `ARRIVAL_PENDING` for recall.
- `to_status = 'ARRIVAL_PENDING'`.
- payload includes `wait_number`, `expires_at`, and `has_pre_order`.

Also verify the corresponding ledger event exists in `catchmenu_ledger.events` with matching tenant/store/session context and correlation id.

## §9 Test H — legacy function dropped

After implementation:

```sql
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'call_next_waiting';
```

Expected:

- zero rows.

Verify replacement exists:

```sql
select
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'call_next_waiting_customer';
```

Expected:

- one row.

## §10 Boundary Verification

### §10.1 Source diff boundary

Verify diff is limited to approved scope:

- `0115_create_waiting_pipeline_rpc.sql` function body for `call_waiting_customer()` if using §24 in-place source sync.
- new forward migration for helper/new public function/drop/comment, if chosen.
- no unapproved files.

Explicit zero-diff checks:

- `sql/migrations/0118_create_schema_validation_update.sql`
- `confirm_arrival()` body in `0115_create_waiting_pipeline_rpc.sql`
- payment confirmation files
- refund/cancel files
- Flutter/runtime files

### §10.2 Schema boundary

Verify no new columns were added:

```sql
select table_schema, table_name, column_name
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_pos', 'order_sessions', 'called_at'),
  ('catchmenu_pos', 'order_sessions', 'call_count'),
  ('catchmenu_pos', 'order_sessions', 'table_number'),
  ('catchmenu_pos', 'order_sessions', 'pre_order_amount')
);
```

Expected:

- zero rows.

Verify `no_show_auto_expire_minutes` still exists and was not dropped.

## §11 Acceptance Criteria

Stage 4 passes this TestPlan only if:

1. `call_waiting_customer()` works for `WAITING` and `ARRIVAL_PENDING`.
2. `call_waiting_customer()` rejects non-callable states.
3. `call_next_waiting_customer()` selects the next waiting session correctly.
4. `call_next_waiting_customer()`'s `pre_order_amount`/`has_pre_order` are correctly sourced from `orders.final_amount`, not `order_sessions.pre_order_amount` (§4.3).
5. concurrent automatic calls do not select the same session.
6. both public paths produce `customer_called` session events.
7. call count is correctly derivable from `session_events`, both within a single path (§6.1) and across paths — `call_next_waiting_customer()` followed by a `call_waiting_customer()` recall on the same session (§6.2).
8. `wait_call_expire_minutes` controls `expires_at`.
9. `no_show_auto_expire_minutes` remains only as deprecated.
10. no phantom `order_sessions` columns are added.
11. `0118` cron and `confirm_arrival()` remain untouched.

## §12 Open Items Carried Forward

The following remain outside this TestPlan:

1. Actual `0118` cron correction.
2. `confirm_arrival()` phantom-column repair.
3. `no_show_auto_expire_minutes` physical DROP.
4. Staff Flutter implementation.
5. Non-waiting no-show types:
   - pickup no-show,
   - reservation no-show,
   - group/catering no-show,
   - delivery contact failure.
6. Customer-level no-show blacklist/penalty system.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600644_ChangeContract.md] =====
# 600644_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 Change Contract
Owner: Codex
Revision: 2 (Claude Code, 2026-07-16) — corrected §1.6's miscited "§24" reference to the actual established in-place-migration precedent, and synced §4 with 600643's added test coverage, per independent verification findings
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Summary

This ChangeContract approves a narrow recovery of the waiting-call contract.

The approved design keeps two public entrypoints:

- `catchmenu_pos.call_waiting_customer()` — designated session call / recall.
- `catchmenu_pos.call_next_waiting_customer()` — automatic next waiting-session selection.

Both public functions share one internal helper:

- `catchmenu_pos._record_waiting_call()`

The legacy `0050` function `catchmenu_pos.call_next_waiting()` is dropped.

The canonical call-expiry setting is:

- `catchmenu_store.store_settings.wait_call_expire_minutes`

The old setting:

- `catchmenu_store.store_settings.no_show_auto_expire_minutes`

is not dropped. It is marked deprecated by COMMENT only.

## §1 Allowed Changes

### §1.1 `0115_create_waiting_pipeline_rpc.sql`

Allowed:

- Modify only the `catchmenu_pos.call_waiting_customer()` function body.
- Preserve the existing `0115` function name and signature:

```sql
catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

Required behavior:

- allow `WAITING`,
- allow `ARRIVAL_PENDING` as recall,
- reject `SEATED`, `COMPLETED`, and other non-callable states,
- compute `expires_at` from `store_settings.wait_call_expire_minutes`,
- call `_record_waiting_call()`,
- do not write `called_at`,
- do not write `call_count`,
- do not write `table_number`,
- do not read `order_sessions.pre_order_amount`.

### §1.2 New internal helper

Allowed:

```sql
catchmenu_pos._record_waiting_call(...)
```

Required role:

- internal shared implementation for waiting-call state update,
- update `order_sessions.session_status` to `ARRIVAL_PENDING`,
- update `order_sessions.expires_at`,
- insert `session_events.event_type = 'customer_called'`,
- insert the corresponding `catchmenu_ledger.events` row,
- preserve notification behavior from the `0115` call path where applicable,
- return a JSON response used by both public functions.

Direct standalone helper testing is not required; public function tests cover it.

### §1.3 New public automatic-call function

Allowed:

```sql
catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

Required behavior:

- select only `WAITING` sessions,
- select the earliest session by the confirmed queue ordering,
- use `FOR UPDATE SKIP LOCKED`,
- call `_record_waiting_call()`,
- return `no_waiting_session_found` when no candidate exists.

### §1.4 Legacy function DROP

Allowed:

```sql
drop function if exists catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
);
```

The exact signature must be rechecked before Stage 4 execution. If the live signature differs, Stage 4 must stop and report rather than guessing.

### §1.5 Store settings COMMENT

Allowed:

```sql
comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';
```

No DROP is allowed for this column.

### §1.6 Forward migration / already-applied source sync

Allowed implementation shape:

- create a new forward migration for new helper/function/drop/comment; and
- if the repository requires already-applied source files to remain canonical, update `0115_create_waiting_pipeline_rpc.sql` with the corrected `call_waiting_customer()` body using the established in-place function correction procedure (precedent: `600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` §2.2 — modify source, recalculate the CRLF-normalized checksum, update `catchmenu_meta.migration_history`, re-execute the live function body, verify with `pg_get_functiondef()` that the live body actually changed). Note: this procedure is established project precedent (also used in `600550`/`600560`/`600570`/`601020`), not a numbered rule in `000701_Guide_Controlled_AI_Development_Pipeline.md` — §24 there is "Lightweight Verification-Bugfix Track," an unrelated track, and must not be cited for this procedure.

Stage 4 must explicitly report which path was used.

## §2 Forbidden Changes

The following are forbidden in this workpacket:

1. Editing `sql/migrations/0118_create_schema_validation_update.sql`.
   - `0118` cron correction belongs to `600630` / `600632`.

2. Editing `confirm_arrival()` in `0115_create_waiting_pipeline_rpc.sql`.
   - Its phantom columns remain a separate Open Item.

3. Adding schema columns.
   - Do not add `order_sessions.called_at`.
   - Do not add `order_sessions.call_count`.
   - Do not add `order_sessions.table_number`.
   - Do not add `order_sessions.pre_order_amount`.

4. Dropping `store_settings.no_show_auto_expire_minutes`.
   - COMMENT-only deprecation is allowed.
   - physical DROP is deferred.

5. Changing KDS no-show grace policy.
   - That belongs to `600630` / `600632`.

6. Editing payment/refund/KDS unrelated workpackets.

7. Editing Flutter/runtime files.

8. Implementing Staff app UI.

9. Implementing no-show blacklist/customer-level penalty system.

## §3 Required Implementation Rules

### §3.1 Source of truth

The implementation must use:

- `session_events` as source of truth for call occurrence and count,
- `order_sessions.expires_at` as call-expiry snapshot,
- `store_settings.wait_call_expire_minutes` as expiry duration source,
- `orders.final_amount` as optional pre-order amount source when needed,
- `p_table_number` only as transient response/event/notification payload value.

### §3.2 State gate

`call_waiting_customer()`:

- must allow `WAITING`,
- must allow `ARRIVAL_PENDING`,
- must reject non-callable states.

`call_next_waiting_customer()`:

- must select only `WAITING`,
- must not select `ARRIVAL_PENDING`.

### §3.3 Concurrency

`call_next_waiting_customer()` must use row locking with `SKIP LOCKED` so concurrent automatic calls do not select the same waiting session.

### §3.4 Event consistency

Both public paths must create the same canonical `customer_called` session event shape through `_record_waiting_call()`.

Derived call count must be based on:

```sql
count(*)
from catchmenu_pos.session_events
where session_id = ...
  and event_type = 'customer_called'
```

No physical `call_count` column may be introduced.

## §4 Test Requirements

Stage 4 must execute `600643_TestPlan.md` in full.

Required coverage includes:

- `call_waiting_customer()` `WAITING` success,
- `call_waiting_customer()` `ARRIVAL_PENDING` recall success,
- rejection for non-callable states,
- re-snapshot of `expires_at` on recall,
- proof that `table_number` is not stored on `order_sessions`,
- `call_next_waiting_customer()` automatic selection,
- `call_next_waiting_customer()` `pre_order_amount`/`has_pre_order` sourced from `orders.final_amount` (not `order_sessions.pre_order_amount`),
- concurrent automatic selection with `SKIP LOCKED`,
- no-waiting-session behavior,
- `session_events` `customer_called` rows from both paths,
- derived `call_count` correctness within a single path AND across paths (`call_next_waiting_customer()` auto-call followed by a `call_waiting_customer()` recall on the same session),
- store-specific `wait_call_expire_minutes`,
- `no_show_auto_expire_minutes` COMMENT deprecation,
- boundary zero diff for `0118`, `confirm_arrival()`, and unrelated files.

## §5 Stop Conditions

Stage 4 must STOP and report if any of the following occur:

1. The live `call_next_waiting()` signature differs from the DROP signature and cannot be safely identified.
2. `session_events` does not allow `customer_called`.
3. `order_sessions.expires_at` is missing.
4. `store_settings.wait_call_expire_minutes` is missing.
5. Implementing the design appears to require a new schema column not listed in §1.
6. Fixing `0118` or `confirm_arrival()` becomes necessary to make this workpacket pass.
7. A new error catalog key is required but not already available.
8. `SKIP LOCKED` cannot be used in the automatic call path.

## §6 Open Items Carried Forward

The following Open Items remain outside this ChangeContract:

1. `0118` cron correction:
   - remove or redesign `called_at`,
   - remove or redesign `no_show_at`,
   - remove or redesign `cancel_reason`,
   - align cron expiry with `wait_call_expire_minutes`.

2. `600630` / `600632` BLOCKED status:
   - this workpacket must pass Stage 4 before no-show redesign proceeds.

3. `confirm_arrival()` phantom columns:
   - `table_number`,
   - `arrival_confirmed_at`,
   - `pre_order_amount`.

4. Physical cleanup of `no_show_auto_expire_minutes`.

5. Final name review for `call_next_waiting_customer()` if Human wants a different public RPC name.

6. Staff app / Flutter implementation.

7. Non-waiting no-show types:
   - pickup,
   - reservation,
   - group/catering,
   - delivery contact failure.

8. Customer-level no-show blacklist/penalty system.

## §7 Human Boundary Approval

Stage 4 may proceed only after all three boxes are checked:

☑ I approve the call_waiting_customer() recovery scope in 0115. (2026-07-16)
☑ I approve creating _record_waiting_call() and call_next_waiting_customer(), and dropping legacy call_next_waiting().
☑ I approve COMMENT-only deprecation of no_show_auto_expire_minutes with no schema-column additions and no physical DROP.

## §8 Approval State

Current approval state: APPROVED (2026-07-16, 삼중검증 통과 확인 후)

No implementation may proceed until §7 is checked by Human.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600645_Module.md] =====
# 600645_Module.md

Status: Complete
Lifecycle: Module
Stage: 4 Implementation Summary
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## 1. Implemented Scope

This module records the Stage 4 implementation of `600640_call_waiting_customer_contract_recovery`.

The implementation was delivered as a new forward migration:

- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`

The workpacket fixes the broken waiting-call contract around `catchmenu_pos.call_waiting_customer()` by replacing direct references to phantom `order_sessions` columns with the approved `session_events` / `orders.final_amount` model.

## 2. Implemented Objects

### 2.1 Internal helper

Created:

- `catchmenu_pos._record_waiting_call(...)`

The helper is internal. It centralizes the shared waiting-call behavior for both public call paths:

- update `order_sessions.session_status` to `ARRIVAL_PENDING`,
- snapshot `order_sessions.expires_at`,
- insert `session_events.event_type = 'customer_called'`,
- derive `call_count` from `session_events`,
- send the existing waiting/DID/push notification payloads,
- insert the corresponding `catchmenu_ledger.events` row,
- return the shared success response.

### 2.2 Public designated-call function

Replaced:

- `catchmenu_pos.call_waiting_customer(...)`

The function keeps the existing `0115` public name and signature.

The new body:

- allows `WAITING` and `ARRIVAL_PENDING`,
- rejects non-callable states with existing error catalog keys,
- reads pre-order amount through the linked `orders.final_amount`,
- snapshots expiry from `store_settings.wait_call_expire_minutes`,
- delegates shared behavior to `_record_waiting_call()`.

### 2.3 Public automatic-call function

Created:

- `catchmenu_pos.call_next_waiting_customer(...)`

The function:

- selects only `WAITING` sessions,
- uses deterministic queue ordering,
- uses `FOR UPDATE SKIP LOCKED`,
- reads pre-order amount through linked `orders.final_amount`,
- delegates shared behavior to `_record_waiting_call()`,
- returns `no_waiting_session_found` when no candidate exists.

### 2.4 Legacy function removal

Dropped:

- `catchmenu_pos.call_next_waiting(uuid, uuid, text, uuid, uuid, text)`

This removes the legacy `0050` automatic-call function after its useful automatic-selection behavior was carried into `call_next_waiting_customer()`.

### 2.5 Store setting comment

Updated COMMENT only:

- `catchmenu_store.store_settings.no_show_auto_expire_minutes`

The column remains physically present. The comment marks it deprecated for this call-expiry use case and points to `wait_call_expire_minutes` as the canonical setting.

## 3. Phantom Column Resolution

The implementation resolves the four confirmed phantom-column issues without adding new columns:

| Old direct concept | Final source |
|---|---|
| `order_sessions.called_at` | `session_events.occurred_at` for `customer_called` events |
| `order_sessions.call_count` | `count(*)` from `session_events` where `event_type = 'customer_called'` |
| `order_sessions.table_number` | request/response/event payload only; not persisted on `order_sessions` |
| `order_sessions.pre_order_amount` | linked `catchmenu_pos.orders.final_amount` |

The final schema boundary remains unchanged: no new `order_sessions` column was added.

## 4. Application Method

Stage 4 used the forward-migration path permitted by `600644_ChangeContract.md` §1.6:

1. Create `0160_call_waiting_customer_contract_recovery.sql`.
2. Apply it through `python tools/apply_migrations.py`.
3. Confirm `catchmenu_meta.migration_history` recorded the new migration.
4. Confirm live function inventory and function-definition tokens.
5. Execute `600643_TestPlan.md` verification scenarios.

The already-applied source file `0115_create_waiting_pipeline_rpc.sql` was not modified in this workpacket.

## 5. Non-Changes

The implementation did not change:

- `sql/migrations/0118_create_schema_validation_update.sql`,
- `confirm_arrival()`,
- `mark_no_show()`,
- `order_sessions` schema,
- `store_settings` schema,
- `no_show_auto_expire_minutes` physical column,
- Flutter/runtime code.

## 6. Result

`call_waiting_customer()` no longer depends on phantom `order_sessions` columns and now executes successfully for both first calls and recalls.

The automatic next-waiting-customer path now has a canonical public replacement, `call_next_waiting_customer()`, with `SKIP LOCKED` concurrency behavior and the same shared event/counter semantics as the designated-call path.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600646_Verification.md] =====
# 600646_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5 Verification / Stage 6 Evidence
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## 1. Verification Summary

The implementation was verified through independent Cursor, Antigravity, and Claude Code review/execution evidence, excluding original Stage 4 author Codex per the project’s independent-verification rule.

Final result: PASS.

All three independent validators reported PASS across the twelve TestPlan areas for `600643_TestPlan.md`, using separate test data and independent execution paths.

Codex additionally confirmed the local live state during Stage 4 handoff:

- `0160_call_waiting_customer_contract_recovery.sql` applied successfully,
- `call_next_waiting()` was dropped,
- `_record_waiting_call()`, `call_waiting_customer()`, and `call_next_waiting_customer()` exist,
- `call_next_waiting_customer()` contains `SKIP LOCKED`,
- no direct `order_sessions.pre_order_amount` reference remains,
- `no_show_auto_expire_minutes` is COMMENT-deprecated but still physically present.

## 2. Application Evidence

`tools/apply_migrations.py` applied the forward migration:

```text
APPLY 0160_call_waiting_customer_contract_recovery.sql ...
OK    0160_call_waiting_customer_contract_recovery.sql  (applied)
All sequence-numbered migrations applied or already up to date.
```

`catchmenu_meta.migration_history` recorded:

```text
filename                                          | success | has_checksum | applied_at
--------------------------------------------------+---------+--------------+-------------------------------
0160_call_waiting_customer_contract_recovery.sql  | t       | t            | 2026-07-16 03:20:38.472951+00
```

## 3. Live Function Inventory

Post-implementation live function inventory:

```text
_record_waiting_call
call_next_waiting_customer
call_waiting_customer
```

Legacy function inventory:

```text
call_next_waiting: zero rows
```

Token checks:

```text
has_skip_locked                 > 0
bad_pre_order_ref               = 0
call_waiting_uses_expire_setting > 0
```

## 4. TestPlan Coverage Result

The twelve TestPlan areas were verified as PASS:

| Area | Result | Evidence summary |
|---|---:|---|
| §1 function/store-setting inventory | PASS | New helper/new public function exist; legacy `call_next_waiting()` absent; settings columns present. |
| §2 designated `call_waiting_customer()` first call / recall / rejection | PASS | `WAITING` and `ARRIVAL_PENDING` succeeded; `SEATED` and `COMPLETED` rejected through existing error keys. |
| §3 table/pre-order handling for designated path | PASS | `table_suggestion` returned in payload only; `pre_order_amount` came from linked `orders.final_amount`. |
| §4 automatic `call_next_waiting_customer()` selection | PASS | Earliest WAITING session selected; no-waiting case returned `no_waiting_session_found`. |
| §4.3 automatic pre-order amount source | PASS | `has_pre_order=true`; `pre_order_amount` matched linked `orders.final_amount`. |
| §5 concurrency / `SKIP LOCKED` | PASS | Two concurrent sessions selected different waiting sessions. |
| §6 call-count derivation | PASS | `call_count` derived from `session_events` count. |
| §6.2 cross-path accumulation | PASS | Auto call followed by designated recall produced two `customer_called` events and `call_count=2`. |
| §7 store-specific `wait_call_expire_minutes` | PASS | Explicit store setting was reflected in `expires_at` snapshot. |
| §7.1 deprecated comment check | PASS | `no_show_auto_expire_minutes` COMMENT contains `DEPRECATED`; column still exists. |
| §8 event and ledger consistency | PASS | `customer_called` event rows carried correct `from_status`/`to_status` and payload. |
| §9-§10 boundary/schema checks | PASS | Legacy function dropped, replacement exists, four phantom columns absent from `order_sessions`. |

## 5. Key Runtime Results

Designated call on `WAITING`:

```text
success=true
session_status=ARRIVAL_PENDING
call_count=1
table_suggestion=T-51
```

Designated recall on `ARRIVAL_PENDING`:

```text
success=true
call_count=1 for the first recall event on that session
```

Rejected states:

```text
SEATED    -> waiting_already_seated
COMPLETED -> waiting_not_callable
```

Automatic pre-order path:

```text
has_pre_order=true
pre_order_amount=12345
source=orders.final_amount
```

Designated pre-order path:

```text
has_pre_order=true
pre_order_amount=7777
source=orders.final_amount
```

Cross-path accumulation:

```text
event 1: WAITING -> ARRIVAL_PENDING
event 2: ARRIVAL_PENDING -> ARRIVAL_PENDING
customer_called_count=2
```

SKIP LOCKED concurrency:

```text
job1 selected session ...661
job2 selected session ...662
```

Schema boundary:

```text
phantom_column_count=0
```

## 6. Methodology Notes from Independent Verification

### 6.1 `now()` fixed within a transaction

Claude Code initially observed an apparent recall `expires_at` issue while testing inside one transaction.

It then identified the PostgreSQL behavior that `now()` is transaction-stable, so multiple calls inside the same transaction can legitimately share the same timestamp. Claude Code reran the expiry re-snapshot check in separate transactions and confirmed the implementation behavior was correct.

This was a verification-methodology correction, not an implementation defect.

### 6.2 `store_settings` had no live row

Claude Code also found that `catchmenu_store.store_settings` had zero live rows for the test store at the start of its independent store-setting verification.

It then inserted an explicit test settings row and verified that a `wait_call_expire_minutes = 42` setting was reflected in the computed `expires_at` snapshot.

This was also a verification-methodology correction, not an implementation defect.

## 7. Boundary Verification

Boundary checks passed:

- `0160_call_waiting_customer_contract_recovery.sql` was added.
- `0115_create_waiting_pipeline_rpc.sql` was not edited in this implementation.
- `0118_create_schema_validation_update.sql` was not edited.
- `confirm_arrival()` was not edited.
- No new schema column was added.
- `no_show_auto_expire_minutes` was not dropped.
- Flutter/runtime files were not edited.

## 8. Cleanup Verification

Stage 4 rollback/cleanup checks confirmed no persistent test rows from Codex’s local verification remained:

```text
remaining_test_sessions=0
remaining_test_orders=0
remaining_store_settings=0
```

Independent validators likewise reported using isolated, separate test data.

## 9. Verification Result

PASS.

The implementation satisfies `600643_TestPlan.md` and the approved `600644_ChangeContract.md` scope.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600640_call_waiting_customer_contract_recovery/600647_Audit.md] =====
# 600647_Audit.md

Status: ACCEPT
Lifecycle: Audit
Stage: 6 Audit
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## 1. Audit Decision

ACCEPT.

The Stage 4 implementation is accepted because it stayed within the approved ChangeContract, applied through a forward migration, and passed independent verification.

## 2. Scope Compliance

Approved scope:

- create internal `_record_waiting_call()`,
- replace `call_waiting_customer()` while preserving its public name/signature,
- create `call_next_waiting_customer()`,
- drop legacy `call_next_waiting(...)`,
- COMMENT-deprecate `no_show_auto_expire_minutes`,
- avoid new schema columns,
- avoid `0118` / `confirm_arrival()` changes.

Observed implementation:

- added `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`,
- created `_record_waiting_call(...)`,
- replaced `call_waiting_customer(...)`,
- created `call_next_waiting_customer(...)`,
- dropped `call_next_waiting(uuid, uuid, text, uuid, uuid, text)`,
- updated only the COMMENT on `store_settings.no_show_auto_expire_minutes`,
- did not add schema columns,
- did not modify `0118`,
- did not modify `confirm_arrival()`.

Scope compliance: PASS.

## 3. Runtime Audit

Runtime verification confirmed:

- `call_waiting_customer()` succeeds for `WAITING`,
- `call_waiting_customer()` succeeds for `ARRIVAL_PENDING` recall,
- non-callable states are rejected,
- `call_next_waiting_customer()` selects the earliest waiting candidate,
- `call_next_waiting_customer()` uses `SKIP LOCKED`,
- both public paths write `customer_called` session events,
- both public paths derive `call_count` from `session_events`,
- cross-path call accumulation works,
- pre-order amount comes from linked `orders.final_amount`,
- expiry comes from `store_settings.wait_call_expire_minutes`,
- no phantom `order_sessions` columns are required.

Runtime audit: PASS.

## 4. Original Failure Mode Closure

The original failure mode was:

1. `call_waiting_customer()` was the semantically correct public RPC name for Staff waiting calls.
2. Its live body referenced phantom `order_sessions` columns such as `called_at`, `table_number`, `call_count`, and `pre_order_amount`.
3. The sibling `call_next_waiting()` had useful real-column waiting-call mechanics but was a separate legacy function with a different name and weaker notification behavior.
4. Downstream workpacket `600630` was blocked because its `mark_no_show()` flow depends on a working waiting-call precondition.

After this workpacket:

- `call_waiting_customer()` uses real columns and `session_events`,
- `call_next_waiting_customer()` replaces the useful automatic-selection behavior,
- the legacy `call_next_waiting()` was dropped,
- `600630` can be unblocked from the specific `call_waiting_customer()` prerequisite once Human chooses to resume it.

Closure result: PASS.

## 5. Independent Verification Audit

Independent verification evidence was supplied by:

- Cursor,
- Antigravity,
- Claude Code.

Per the independent-verification rule, original Stage 4 author Codex is not counted as one of the three independent validators.

All three validators reported PASS across the twelve TestPlan areas.

Two methodology corrections were explicitly reviewed:

1. Claude Code’s recall-expiry test initially misread PostgreSQL’s transaction-stable `now()` behavior. The check was corrected using separate transactions and passed.
2. Claude Code found the test store had no `store_settings` row, then created an explicit test row and verified `wait_call_expire_minutes = 42` was honored.

Both were verifier self-corrections, not implementation defects.

## 6. Boundary Audit

Boundary checks passed:

- no edit to `0118_create_schema_validation_update.sql`,
- no edit to `confirm_arrival()`,
- no new error key required,
- no new schema column added,
- no physical DROP of `no_show_auto_expire_minutes`,
- no Flutter/runtime code changed.

Boundary audit: PASS.

## 7. New Open Item

### 7.1 `0115_create_waiting_pipeline_rpc.sql` source body remains stale

The live database function `catchmenu_pos.call_waiting_customer()` is now correct because `0160` redefined it.

However, the historical source file:

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql`

still contains the older `call_waiting_customer()` body with phantom-column references.

Cursor, Antigravity, and Claude Code all independently flagged this as a source-of-truth risk: a future maintainer who reads only `0115` may incorrectly infer that the live function is still broken, or may copy stale logic into a later migration.

Recommended follow-up: consider a separate source synchronization workpacket that records how already-applied source files should reflect later forward-migration replacements without obscuring migration history.

## 8. Open Items Carried Forward

The existing `600641` / `600642` Open Items remain carried forward:

1. `600630` / `600632` can be resumed because the `call_waiting_customer()` blocker is now cleared by this workpacket.
2. `0118` cron correction remains a separate workpacket scope.
3. `confirm_arrival()` phantom columns remain out of scope.
4. Staff Flutter implementation remains gated behind the broader Staff App scope.
5. `no_show_auto_expire_minutes` physical DROP remains deferred to a separate cleanup decision.
6. No-show recovery / late-arrival restoration policy remains separate from this waiting-call contract recovery.

## 9. Final Audit Result

ACCEPT.

The implementation is narrow, verified, and safe to hand off for human review/commit.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600651_Overview_Seat_Waiting_Customer_Facade_Correction.md] =====
# 600651_Overview_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0.1 원칙 (문서 전체에 적용, 최우선 명시)

**사용자/스태프가 보고 입력하는 것은 번호(`table_number`, 물리적으로 테이블에 인쇄/부착된 라벨) — 시스템 내부의 모든 참조·바인딩·FK는 예외 없이 `table_id`(UUID)를 기준으로 한다.** `p_table_number`는 이 워크패킷이 신설하는 리졸버(§2)를 통해 **한 번만** `table_id`로 변환되고, 그 이후의 모든 처리(`bind_table_to_session()` 호출, `order_sessions.table_id` 저장, `dining_tables` 갱신)는 오직 `table_id`만 사용한다. 이 원칙은 `601121_Overview_Dining_Table_Crud_Creation.md` §0.2가 이미 확립한 것과 동일하며(`table_code`는 표시용 라벨, `table_id`가 유일한 불변 참조), 이 워크패킷은 그 원칙을 대기열 파이프라인 쪽에서 실제로 지키도록 만드는 작업이다.

## §0.2 배경 — 발견 경위

이 워크패킷은 `601121_Overview_Dining_Table_Crud_Creation.md` §6 (f)에서 "Staff Seating And Table Assignment Orchestration Contract" 후속 워크패킷 후보로 이관된 항목의 첫 번째 조각이다. 그 문서가 이미 확인한 사실(재확인 완료, 아래 §1에서 라인 단위로 재검증): `catchmenu_pos.seat_waiting_customer()`(`sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1204`)는 존재하지 않는 `order_sessions.table_number` 컬럼에 쓰기를 시도해 호출할 때마다 크래시한다.

## §1 현황 — 라이브 재확인

### §1.1 `seat_waiting_customer()`의 정확한 크래시 지점과 범위 (재확인)

```sql
-- 0115:1048-1057
update catchmenu_pos.order_sessions
set
  session_status = 'SEATED',
  table_number = coalesce(
    p_table_number, table_number
  ),
  seated_at = now(),
  updated_at = now()
where id = p_session_id;
```

`information_schema.columns` 라이브 재조회 결과, `catchmenu_pos.order_sessions`에 `table_number` 컬럼은 **존재하지 않는다**(존재하는 컬럼: `table_id uuid`뿐). 이 UPDATE 문 하나가 이 함수 전체를 크래시시킨다 — `session_status`/`seated_at` 등 나머지 필드가 정상이어도, 하나의 UPDATE 문에 포함된 이상 전체가 원자적으로 실패한다.

### §1.2 `bind_table_to_session()` — 이미 존재하는 canonical core (전체 정독)

`catchmenu_pos.bind_table_to_session(p_tenant_id, p_store_id, p_session_id, p_table_id, p_actor_type default 'STAFF', p_actor_id default null, p_correlation_id default null)`(`sql/migrations/0025_create_session_rpc.sql:327-`, 라이브 `pg_get_functiondef()`로 전체 재확인) 가 실제로 하는 일:

1. 세션 조회 + `FOR UPDATE` 락.
2. **세션 사전조건**: `session_status in ('WAITING', 'ARRIVAL_PENDING', 'ORDERING')`이 아니면 `session_not_bindable` 에러 — 그 외 상태(`SEATED`/`CANCELLED`/`NO_SHOW`/`COMPLETED` 등)는 전부 거부.
3. **이미 바인딩됨 확인**: `session.table_id is not null`이면 `table_already_bound` 에러.
4. **테이블 조회**: `dining_tables where id = p_table_id and store_id = p_store_id and is_active = true` — 없으면 `table_not_found`.
5. **테이블 가용성 확인**: `table_status in ('AVAILABLE', 'RESERVED')`가 아니면 `table_not_available`(현재 `table_status`/`current_session_id`까지 응답에 포함).
6. **바인딩 실행**: `order_sessions.table_id = p_table_id`, `session_status = 'SEATED'`, `seated_at = now()`, `ordering_started_at = now()`.
7. **테이블 점유 처리**: `dining_tables.table_status = 'OCCUPIED'`, `current_session_id = p_session_id`, `occupied_since = now()`.
8. `session_events` INSERT(`table_bound`) + `catchmenu_ledger.events` INSERT(`session`/`table_bound`) + `catchmenu_audit.append_audit_record()`(`OPERATIONAL`, `COMPLETED`) — 3중 기록.
9. 성공 응답: `{success, session_id, session_status:'SEATED', table_id, table_code, seated_at, late_binding_completed, audit_id, message_code:'late_binding_completed'}`.

### §1.3 `seat_waiting_customer()`가 원래 하려던 것과의 정확한 대조

| 항목 | `seat_waiting_customer()`(0115, 크래시 이전 코드 기준) | `bind_table_to_session()` | 결론 |
|---|---|---|---|
| 세션 존재 확인 | O | O | 동일 |
| "이미 SEATED면 거부" | O(`session_status = 'SEATED'`만 검사) | O, 더 엄격함(`WAITING`/`ARRIVAL_PENDING`/`ORDERING` 화이트리스트 — `CANCELLED`/`NO_SHOW`/`COMPLETED` 세션의 착석 시도도 차단) | **개선** — 원래 설계(`900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:203`, `선행: session_status != 'SEATED'`)보다 `bind_table_to_session()`이 더 엄격하고 정확하다. 결함이 아니라 위임을 통한 자연스러운 보강. |
| `session_status = 'SEATED'` 전이 | O | O | 동일 |
| `seated_at` 기록 | O | O(+ `ordering_started_at`도 추가 기록, 원래 없던 필드) | 동등 이상 |
| **테이블 물리 점유 처리**(`dining_tables.table_status='OCCUPIED'` 등) | **없음** — 원본 설계 자체의 공백 | O | **원본에 없던 기능이 위임으로 새로 생김** — 이 워크패킷의 부수적 개선 |
| **테이블 가용성 검증**(활성/AVAILABLE 여부) | **없음** | O | **원본에 없던 검증이 위임으로 새로 생김** |
| 사전 주문 시 KDS HOLD 유지 안내 | O(`log_diagnostic`) | 없음(테이블-세션 바인딩만 담당, 대기열 도메인 지식 없음) | 파사드가 그대로 보존해야 함(§2) |
| 잔여 대기 인원 계산 + Realtime `waiting_session_seated` | O | 없음 | 파사드가 보존 |
| DID `call_dismissed` Realtime | O | 없음 | 파사드가 보존 |
| `ledger.events`(`waiting`/`customer_seated`, `wait_duration_seconds`) | O | 다른 이벤트(`session`/`table_bound`) — 스키마/목적이 다름, 대체 불가 | 파사드가 **별도로** 계속 기록(§2, 의도적으로 두 이벤트 병존) |

**결론(확인 필요 항목 1에 대한 답)**: `bind_table_to_session()`은 원래 `seat_waiting_customer()`가 하려던 **세션·테이블 상태 전이 불변조건을 전부 커버하며, 그중 두 가지(테이블 가용성 검증, 물리 점유 처리)는 원본에 없던 것까지 보강한다.** 빠진 것은 없다 — 다만 대기열 도메인 고유의 부수 효과(사전주문 안내/Realtime/도메인별 렛저 이벤트)는 `bind_table_to_session()`의 책임이 아니므로 파사드가 그대로 유지해야 한다(§2).

### §1.4 리졸버가 참조할 정확한 테이블 (확인 필요 항목 2에 대한 답)

`dining_tables.table_code`가 맞다 — `uq_dining_table_store_code UNIQUE (store_id, table_code)`(`601121_Overview.md` §1.1에서 이미 확인, 이번 턴 라이브 재확인)가 스토어 내 유일성을 보장하는 실제 제약이다. `dining_tables`에 `table_number`라는 별도 컬럼은 없다 — `p_table_number`(대기열 파이프라인 파라미터명, `0115`부터의 기존 명칭)가 가리키는 대상은 `table_code`다.

**"2건 이상 → `table_number_ambiguous`" 규칙이 현재 스키마에서 발생 가능한가**: `uq_dining_table_store_code`가 `(store_id, table_code)` 조합에 **부분 인덱스가 아닌 전체 UNIQUE**이므로, 리졸버가 `store_id`를 정확히 WHERE 절에 포함하는 한 2건 이상은 구조적으로 불가능하다. 그럼에도 이 분기를 유지하는 이유(`601122_Logic.md`가 이미 확립한 "방어적 코드는 가치가 있다" 원칙과 동일선상): 리졸버 쿼리가 실수로 `store_id` 필터를 빠뜨리면(예: 향후 리팩터링 실수) 같은 테넌트의 다른 스토어에 동일한 `table_code`가 존재할 경우(제약이 `store_id` 단위이지 `tenant_id` 단위가 아니므로 이 시나리오는 실제로 가능) 조용히 엉뚱한 스토어의 테이블에 바인딩되는 대신, 즉시 명시적 에러로 드러난다 — 이 분기는 "일어날 수 없는 경우"가 아니라 "리졸버 자신의 쿼리 정확성을 지키는 회귀 가드"다.

## §2 확정된 설계 방향 (재논의 금지 대상 그대로 반영)

1. **`bind_table_to_session()`은 canonical core로 유지, 수정하지 않는다** — §1.3이 이미 확인했듯 필요한 불변조건을 전부(그 이상까지) 충족한다.
2. **`seat_waiting_customer()`를 얇은 파사드로 재작성** — `p_table_number` → `p_table_id` 리졸버(신설, §1.4/Logic §1) + `bind_table_to_session()` 호출 위임 + 대기열 도메인 고유 부수효과(§1.3 표의 마지막 4행) 보존.
3. **리졸버 규칙**: 정확히 1건(그리고 활성) → `table_id` 반환, 0건 → `waiting_table_not_found`, 2건 이상 → `waiting_table_number_ambiguous`(§1.4의 방어적 근거), 비활성(존재하지만 `is_active=false`) → `waiting_table_inactive`. 에러 키에 `waiting_` 접두어를 붙인 이유는 §6 (a) 참고(기존 `table_not_found` 등과의 충돌 회피).
4. **원칙 문구**(§0.1) 서두 명시 완료.
5. **`pre_order_amount` phantom 제거** — `catchmenu_pos.call_waiting_customer()`(`0160` 복구본, 라이브 재확인)가 이미 쓰는 패턴을 그대로 재사용 가능함을 확인했다:
   ```sql
   -- 0160 복구본, 라이브 확인
   select os.id, ..., os.pre_order_created_at, os.order_id,
          o.final_amount as pre_order_amount
   into v_session
   from catchmenu_pos.order_sessions os
   left join catchmenu_pos.orders o on o.id = os.order_id
   where os.id = p_session_id ...
   ```
   `order_sessions.order_id`(uuid)와 `order_sessions.pre_order_created_at`(timestamptz)은 둘 다 라이브에 실존하는 컬럼이다(재확인). `pre_order_amount`라는 컬럼은 없고, 실제 금액은 `orders.final_amount`를 `order_id`로 LEFT JOIN해 가져온다. `has_pre_order` 판정은 `pre_order_created_at is not null`을 쓴다(`0160`과 동일 관례). 이 패턴을 파사드에 그대로 재사용한다 — 새로 설계할 필요 없이 이미 검증된 패턴을 재사용하는 것이 목표에 정확히 부합한다.
6. **형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`) 범위 제외, Open Item으로 이월** — §4/§6 (b).

## §3 라이브 재확인 (설계 방향 5의 근거 자료)

이번 턴 `information_schema.columns` 직접 재조회:

| 컬럼 | 존재 여부 |
|---|---|
| `order_sessions.table_id` | 존재(uuid) |
| `order_sessions.table_number` | **없음** |
| `order_sessions.order_id` | 존재(uuid) |
| `order_sessions.pre_order_created_at` | 존재(timestamptz) |
| `order_sessions.pre_order_amount` | **없음** |
| `order_sessions.called_at` / `call_count` / `arrival_confirmed_at` / `no_show_at` / `cancel_reason` | **없음**(전부, §4 형제 함수 4개가 참조하는 phantom들) |

## §4 범위 밖 확인

### §4.1 형제 함수 4개 — 지시된 범위 제외, Open Item으로 이월 (§6 (b))

`confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 네 함수의 라이브 본문을 이번 턴 직접 대조했다 — 넷 다 여전히 `table_number`/`pre_order_amount`/`called_at`/`call_count`/`arrival_confirmed_at`/`cancel_reason` 중 하나 이상을 참조하며 크래시 상태다(§3 표). 이번 워크패킷은 손대지 않는다.

### §4.2 **[신규 발견, 지시문의 "형제 함수 4개" 목록에 없던 다섯 번째 후보]** `pre_order_while_waiting()`

지시문은 정확히 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`)를 형제 함수로 지목했으나, 이번 턴 `0115` 전체를 직접 재검토한 결과 **`catchmenu_pos.pre_order_while_waiting()`(`0115:602-869`)도 동일 클래스의 phantom 참조를 갖고 있다**:

```sql
-- 라이브 재확인, 여전히 존재하는 코드
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  pre_order_amount = v_total_amount,
  updated_at = now()
where id = p_session_id;
```

**다만 이 함수가 실제로 "죽은 코드"일 가능성이 있다** — `sql/migrations/0051_create_pre_order_rpc.sql`이 별도로 `catchmenu_pos.create_pre_order()`를 정의하며, 그 함수가 `order_sessions.order_id`/`pre_order_created_at`을 **정확히** 채운다(`0051:311-312`, 라이브 확인). 즉 `call_waiting_customer()`(§2 항목 5)가 실제로 읽는 사전주문 데이터의 진짜 생산자는 `pre_order_while_waiting()`이 아니라 `create_pre_order()`로 보인다 — `pre_order_while_waiting()`이 여전히 호출되는 활성 경로인지, 아니면 `0051`로 대체된 뒤 방치된 죽은 함수인지는 이번 턴에 확인하지 않았다. 어느 쪽이든 크래시 상태인 것은 사실이므로, 이 워크패킷의 범위에는 포함하지 않고 **형제 함수 4개와 별도로, 우선순위 판단이 필요한 다섯 번째 후보**로 Open Item에 추가한다(§6 (c)) — Cursor의 전수조사가 이 함수를 놓친 것인지, 의도적으로 죽은 코드로 판단해 제외한 것인지 확인이 필요하다.

### §4.3 `did_display_queue` 테이블 — 설계 문서에만 있고 구현된 적 없음

`900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:214`("`did_display_queue UPDATE: DISMISSED`")를 참고했으나, 라이브 스키마에 `did_display_queue`라는 테이블 자체가 존재하지 않는다(`information_schema.tables` 확인, 0 rows). 이것은 원본 `seat_waiting_customer()`에도 없던 기능이므로 이 워크패킷이 새로 만들 필요는 없다 — 설계 문서와 구현 사이의 기존 공백을 그대로 기록만 한다(§6 (d)).

### §4.4 기타 범위 밖

- `mark_no_show()` — 이번 턴 확인 결과 phantom 참조가 **없다**(라이브 grep 0건). `600630_mark_no_show_overload_and_redesign` 워크패킷에서 이미 재설계·복구된 것으로 보인다(시그니처는 `0115`와 동일하나 본문이 다름). 이 워크패킷과 무관.
- `register_waiting()` — phantom 참조 없음(라이브 grep 0건), 애초에 문제없는 함수.
- `catchmenu_pos.orders`/`catchmenu_kds.kds_tickets` 스키마 자체 — 변경하지 않음, 읽기만.
- `catchmenu_store.dining_tables`/`bind_table_to_session()` 본문 — 수정하지 않음(§2 항목 1).

## §5 영향 범위 요약

- **결함 클래스**: phantom 컬럼(`table_number`) 참조로 인한 확정적 크래시 — `601140`/`601110`이 다뤄온 것과 동일한 결함 클래스이나, 이번엔 "값을 보존/기본값 처리"가 아니라 "존재 자체가 다른 곳(`table_id`)으로 이미 이관된 개념을 재정렬"하는 문제라 파사드+리졸버 패턴이 필요하다.
- **실호출자**: 0건 — `catchmenu_app/lib/` 전체 재검색(이번 턴), 실제 Dart 코드에서 `seat_waiting_customer`/`bind_table_to_session`을 호출하는 곳 없음(`catchmenu_app/lib/features/waiting/README.md`가 "관련 RPC"로 문서에만 언급).
- **위험**: 리졸버가 `store_id`를 빠뜨리면 크로스-스토어 오탐이 가능(§1.4) — Logic 단계에서 정확한 WHERE 절 명시로 방지.
- **의존 관계**: `bind_table_to_session()`(읽기 전용 의존, 수정 없음), `catchmenu_pos.orders`(읽기 전용, LEFT JOIN), `catchmenu_store.dining_tables`(읽기 전용, 리졸버가 조회만).

## §6 Open Items

(a) 신규 에러 키(`waiting_table_not_found`/`waiting_table_number_ambiguous`/`waiting_table_inactive`)에 `waiting_` 접두어를 붙인 이유: `601122_Logic_Dining_Table_Crud_Creation.md` §5가 이미 `'table_not_found'`를 `STORE` 도메인 코드로 등록했다 — `catchmenu_common.build_error_response()`는 `error_key`만으로 `error_codes`를 조회하므로(`error_domain` 필터 없음), 같은 키를 다른 도메인에 재등록하면 조회가 두 행 중 어느 것을 반환할지 불확실해지는 실질적 충돌이 생긴다. 접두어로 회피했다 — Human이 이 판단을 재검토할 수 있도록 남긴다.
(b) **[이관, `601121_Overview.md` §6 (f)와 동일 근거]** 형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`) — 전부 여전히 크래시 상태(§4.1), 별도 후속 워크패킷 필요. 이 문서는 조사만 하고 수정하지 않는다.
(c) **[신규 발견, §4.2]** `pre_order_while_waiting()`도 동일 클래스 phantom(`pre_order_amount`)을 갖고 있으나 지시문의 "형제 함수 4개" 목록에 없었다 — 죽은 코드인지(`0051.create_pre_order()`로 대체됨) 실제 사용 경로인지 확인 필요. 형제 함수 4개와 함께든, 별도로든 후속 워크패킷 후보.
(d) `did_display_queue` 테이블 자체가 구현된 적이 없다(§4.3) — `900101` 설계 문서와 실제 구현 사이의 기존 공백, 이 워크패킷이 새로 만들지 않는다.
(e) 리졸버가 `p_table_number`를 대소문자/공백 등을 정규화(trim, 대소문자 무시)하지 않고 정확히 일치(`table_code = p_table_number`)만 본다 — 정규화가 필요한지는 실제 스태프 입력 UX(Flutter 클라이언트 미착수)에 달려 있어 이 워크패킷 범위 밖으로 둔다. 정규화를 도입하면 §1.4가 분석한 "2건 이상" 시나리오가 현실적으로 발생 가능해지므로(예: `'A1'`과 `'a1'`이 둘 다 존재), 그때는 `waiting_table_number_ambiguous` 분기가 실제로 도달 가능해진다.
(f) `p_table_number`가 생략되면(`NULL`) 이 워크패킷의 파사드는 `waiting_table_number_required` 에러로 거부한다(Logic §2) — `bind_table_to_session()`이 `p_table_id`를 필수 파라미터로 요구하고, `order_sessions.table_id`가 착석 시점 이전엔 항상 `NULL`이라 "생략 시 기존 값 유지"라는 원본의 `coalesce` 개념 자체가 성립하지 않기 때문이다. 이 동작 변화(원본은 생략을 허용했으나 어차피 크래시했으므로 실질적 동작 차이는 없음)를 Human이 인지해야 한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601121_Overview_Dining_Table_Crud_Creation.md` §6 (f) — 이 워크패킷의 직접 출발점.
- `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md` — 동일 파일(`0115`)의 동일 결함 클래스를 먼저 다룬 선례, 조사/정정 관례의 직접 템플릿.

### Full Rules Required

- `sql/migrations/0115_create_waiting_pipeline_rpc.sql:988-1204`(`seat_waiting_customer()`, 대상) 전체, 그리고 나머지 8개 함수(§4.1/§4.2/§4.4의 근거).
- `sql/migrations/0025_create_session_rpc.sql`(`bind_table_to_session()`, canonical core) — 라이브 `pg_get_functiondef()`로 전체 재확인.
- `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`(재사용할 `orders` LEFT JOIN 패턴의 원본).
- `sql/migrations/0051_create_pre_order_rpc.sql:311-312`(`create_pre_order()`의 `order_id`/`pre_order_created_at` 실제 생산 지점, §4.2 근거).
- `900101_Logic_Customer_Waiting_Handoff_And_Late_Binding_Pipeline.md:202-217`(원본 설계 의도, §1.3 대조표의 비교 대상).

### Domain Indexes

- `600600_Readme_Waiting_Order_Session.md`(이 워크패킷의 번호 등록처 — 이번 문서 자체는 Subfolder Map 갱신을 포함하지 않음).
- `600602_NavigationMap_Waiting_Order_Session.md`(동일).

### Excluded Rule Families

- 형제 함수 4개 + `pre_order_while_waiting()` — §4.1/§4.2에서 명시적으로 제외, Open Item (b)/(c)로 이관.
- `mark_no_show()`/`register_waiting()` — §4.4, 문제없음 확인, 손대지 않음.
- `did_display_queue` — §4.3, 구현된 적 없는 별개 공백.
- `601100_store_admin_console/`의 모든 워크패킷 — 완전히 다른 도메인, `table_code`/`table_id` 원칙(§0.1)만 교차 참조.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Logic 단계(`600652_Logic.md`)로 진행 가능.** §1에서 크래시 지점(§1.1), `bind_table_to_session()`의 전체 커버리지(§1.2/§1.3 대조표 — 원본이 갖지 못했던 테이블 가용성 검증/물리 점유 처리까지 보강됨을 확인), 리졸버 대상(`table_code`, §1.4)을 전부 라이브 재확인했다. 확정된 설계 방향 6개 항목 전부에 근거를 붙여 반영했다(§2) — 특히 `pre_order_amount` 제거는 `0160`이 이미 쓰는 검증된 패턴의 재사용임을 확인했다(§2 항목 5/§3). 형제 함수 4개는 여전히 크래시 상태임을 재확인해 Open Item으로 이관했고(§4.1), 지시문에 없던 다섯 번째 후보(`pre_order_while_waiting()`)를 새로 발견해 별도로 기록했다(§4.2) — 죽은 코드일 가능성이 있다는 단서까지 포함해서. `.sql` 파일은 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600652_Logic_Seat_Waiting_Customer_Facade_Correction.md] =====
# 600652_Logic_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0 설계 원칙 요약 (승계)

`601121_Overview.md` §0.2(`table_id` 불변/`table_code` 표시용) 원칙을 대기열 파이프라인에 적용한다. `bind_table_to_session()`(`0025`)은 수정하지 않는다(`601121_Overview.md` §1.2/§1.3이 이미 필요한 불변조건을 전부 충족함을 확인). `seat_waiting_customer()`(`0115`)를 얇은 파사드로 재작성하고, 신규 리졸버 헬퍼를 하나 추가한다.

## §1 신규 헬퍼 — `catchmenu_pos._resolve_dining_table_by_number()`

```sql
create or replace function catchmenu_pos._resolve_dining_table_by_number(
  p_tenant_id uuid,
  p_store_id uuid,
  p_table_number text
)
returns table (
  v_table_id uuid,
  v_status text
)
language plpgsql
stable
security definer
set search_path = catchmenu_store
as $$
declare
  v_matches uuid[];
begin
  select array_agg(id) into v_matches
  from catchmenu_store.dining_tables
  where tenant_id = p_tenant_id
    and store_id = p_store_id
    and table_code = p_table_number;

  if v_matches is null or array_length(v_matches, 1) = 0 then
    return query select null::uuid, 'NOT_FOUND'::text;
    return;
  end if;

  if array_length(v_matches, 1) > 1 then
    return query select null::uuid, 'AMBIGUOUS'::text;
    return;
  end if;

  if exists (
    select 1 from catchmenu_store.dining_tables
    where id = v_matches[1] and is_active = true
  ) then
    return query select v_matches[1], 'FOUND'::text;
  else
    return query select v_matches[1], 'INACTIVE'::text;
  end if;
end;
$$;
```

**설계 근거**:

- `where table_code = p_table_number`만 두고 `is_active`를 필터에 넣지 않은 이유(`601121_Overview.md` §1.4): 비활성 테이블도 "찾았지만 비활성"임을 구분해 알려야 하기 때문이다 — `is_active`를 WHERE 절에 넣으면 비활성 테이블은 그냥 0건(= `NOT_FOUND`)이 되어 `waiting_table_inactive`라는 더 정확한 신호를 잃는다.
- `array_agg` + 배열 길이로 0/1/2+ 건을 구분한다 — `select ... into` 단일 스칼라로는 2건 이상을 감지할 수 없다(마지막 값만 남거나 에러가 나는 등 신뢰할 수 없는 동작).
- `store_id`를 반드시 WHERE 절에 포함한다 — `uq_dining_table_store_code`가 `(store_id, table_code)` 조합 유니크이므로, 이 조건이 정확한 한 `AMBIGUOUS` 분기는 도달 불가능하지만, 리졸버 자신의 정확성을 지키는 회귀 가드로 유지한다(`601121_Overview.md` §1.4).
- `returns table(...)`(레코드 집합)을 택한 이유: 예외(`raise`)를 던지지 않고 호출자가 `select * into v_resolved from ...`로 받아 `v_status`에 따라 분기하게 한다 — 오늘 이 세션이 반복 확립한 "예상 가능한 조건은 예외가 아니라 값으로 반환" 원칙(`601122_Logic.md` §1.5의 `raise;`→반환 정정과 같은 방향)과 일치한다.

### §1.1 GRANT/REVOKE — 내부 전용, `authenticated`에도 부여하지 않음

```sql
revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;
```

**(중요, 이번 턴 발견)** `authenticated`에도 GRANT하지 않는다 — 이 함수는 순수 내부 헬퍼(`_` 접두어 관례, `catchmenu_pos._record_waiting_call()`과 동일한 명명 패턴)로, `seat_waiting_customer()`(SECURITY DEFINER)의 실행 컨텍스트 안에서만 호출되면 충분하다. 라이브 확인 결과 `catchmenu_pos._record_waiting_call()`의 `proacl`이 **비어 있다**(`REVOKE`조차 없음) — `601142_Logic.md` §1.2/§3(a)가 `upsert_menu_core()`에서 지적한 것과 동일한 패턴(내부 헬퍼가 의도치 않게 PUBLIC 기본 실행 권한에 열려 있는 상태)이 이미 이 코드베이스에 살아있다. 이 워크패킷은 `_record_waiting_call()`을 고치지 않지만(범위 밖, §8 Open Item (d)), 신규로 만드는 헬퍼에서는 이 패턴을 원천적으로 피한다 — `REVOKE ALL FROM PUBLIC`만으로 충분하다(`authenticated`에도 열 필요가 없으므로 `GRANT`문 자체가 없다).

## §2 `catchmenu_pos.seat_waiting_customer()` — 파사드 전체 재작성

시그니처는 기존과 동일하게 유지한다(하위 호환, 실호출자 0건이지만 문서상 계약 유지):

```sql
create or replace function
  catchmenu_pos.seat_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos,
                  catchmenu_store,
                  catchmenu_kds,
                  catchmenu_common,
                  catchmenu_ledger
as $$
declare
  v_session record;
  v_resolved record;
  v_bind_result jsonb;
  v_remaining_queue int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  -- 1. 세션 조회 (사전주문 정보는 0160의 orders LEFT JOIN 패턴 재사용,
  --    §2.1 Overview 항목 5 — pre_order_amount phantom 컬럼 제거)
  select os.id, os.wait_number, os.session_status,
         os.guest_count, os.guest_locale,
         os.phone_hash, os.customer_id,
         os.session_started_at,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 2. 이미 착석했는지 확인 (bind_table_to_session()이 더 엄격한
  --    사전조건을 다시 확인하지만, 여기서 먼저 확인하면 더 정확한
  --    에러 키(waiting_already_seated)를 유지할 수 있다 — 원본 동작 보존.
  if v_session.session_status = 'SEATED' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_already_seated',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 3. p_table_number 필수 확인 (Overview §6 (f)) — bind_table_to_session()이
  --    p_table_id를 필수로 요구하고, order_sessions.table_id는 착석 이전엔
  --    항상 NULL이라 "생략 시 기존 값 유지"가 성립하지 않는다.
  if p_table_number is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_required',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer'
    );
  end if;

  -- 4. table_number -> table_id 리졸버 (§1)
  select * into v_resolved
  from catchmenu_pos._resolve_dining_table_by_number(
    p_tenant_id, p_store_id, p_table_number
  );

  if v_resolved.v_status = 'NOT_FOUND' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'AMBIGUOUS' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_number_ambiguous',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('table_number', p_table_number)
    );
  elsif v_resolved.v_status = 'INACTIVE' then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_table_inactive',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'table_number', p_table_number,
        'table_id', v_resolved.v_table_id
      )
    );
  end if;
  -- v_resolved.v_status = 'FOUND' 부터는 v_resolved.v_table_id가 유효하다.

  -- 5. canonical core에 위임 (Overview §1.2/§1.3 — 수정하지 않음)
  v_bind_result := catchmenu_pos.bind_table_to_session(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_table_id := v_resolved.v_table_id,
    p_actor_type := 'STAFF',
    p_actor_id := p_actor_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_bind_result->>'success')::boolean, false) then
    -- (2026-07-18 정정, Stage 4 검증 — 아래 §2.1 참고) bind_table_to_session()의
    -- 원본 응답을 build_error_response()로 다시 감싸지 않고 그대로 반환한다.
    return v_bind_result;
  end if;

  -- 6. 대기열 도메인 고유 부수효과 (원본 0115 로직 보존, 0160 패턴으로 갱신)
  if v_session.pre_order_created_at is not null then
    perform catchmenu_common.log_diagnostic(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_log_level := 'INFO',
      p_log_domain := 'KDS',
      p_log_event := 'pre_order_seated_waiting_payment',
      p_message :=
        '사전 주문 착석 완료 - 결제 대기 중. KDS HOLD 유지',
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object(
        'session_id', p_session_id,
        'wait_number', v_session.wait_number,
        'pre_order_amount', v_session.pre_order_amount
      )
    );
  end if;

  select count(*) into v_remaining_queue
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING');

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_seated',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null
    )
  );

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'DID_DISPLAY',
    p_event_type := 'call_dismissed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number
    )
  );

  -- 7. 'waiting' 도메인 렛저 이벤트 — bind_table_to_session()의 'session'/
  --    'table_bound' 이벤트와 의도적으로 별도로 기록한다(§3 설계 근거).
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'customer_seated', 1,
    'order_session', p_session_id,
    v_session.session_status, 'SEATED',
    'STAFF', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'wait_duration_seconds', extract(
        epoch from (now() - v_session.session_started_at)
      )::int,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'kds_note', case
        when v_session.pre_order_created_at is not null
          then 'KDS HOLD - 결제 후 COMMITTED'
        else 'No pre-order - normal flow'
      end
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_seated',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'table_id', v_resolved.v_table_id,
      'table_number', p_table_number,
      'guest_count', v_session.guest_count,
      'remaining_queue', v_remaining_queue,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'late_binding_completed', true,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then jsonb_build_object(
            'action', 'PROCEED_TO_PAYMENT',
            'note', '결제 완료 후 KDS 자동 COMMITTED',
            'kds_status_now', 'HOLD',
            'kds_status_after_payment', 'COMMITTED'
          )
        else jsonb_build_object(
          'action', 'TAKE_ORDER',
          'note', '일반 주문 접수'
        )
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'seat_waiting_customer_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'STAFF',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'table_number', p_table_number
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_seat_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'seat_waiting_customer',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**(중요)** `EXCEPTION` 핸들러도 `raise;`가 아니라 `build_error_response()` 반환으로 설계했다 — `601122_Logic.md` §1.5/§8 (h)가 라이브 실증한 "감사 기록 후 `raise;`하면 그 기록까지 롤백된다"는 원칙을 이 워크패킷의 신규 코드에도 처음부터 적용한다(재발견이 아니라 이미 확립된 교훈의 재적용).

**(2026-07-18 정정, Codex+Cursor 검증 — 차단급 결함)** `p_audit_domain`을 최초 `'waiting'`으로 썼으나, 라이브 재확인 결과 `catchmenu_ledger.audit_records.chk_audit_domain`은 `'order'`/`'payment'`/`'kds'`/`'session'`/`'delivery'`/`'inventory'`/`'staff'`/`'device'`/`'agent'`/`'recovery'`/`'knowledge'`/`'gateway'`/`'security'`/`'system'`만 허용하고 **`'waiting'`은 포함하지 않는다**(참고: `catchmenu_ledger.events.chk_event_domain`은 `'waiting'`을 허용하지만, 이는 별개 테이블의 별개 제약이다 — §2 step 7의 렛저 이벤트와 여기 `audit_records`를 혼동해서는 안 된다). `'waiting'`으로 그대로 두면 이 `EXCEPTION` 핸들러 자신의 `append_audit_record()` 호출이 `chk_audit_domain` 위반으로 **다시 크래시**하고, 이 두 번째 예외는 잡아줄 상위 핸들러가 없어 그대로 클라이언트에 원본 Postgres 에러가 전파된다 — `raise;`→반환 정정(§1.5, `601122_Logic.md` §8 (h))이 지키려던 "친절한 에러 응답 + 영구 감사 기록"이 이 두 번째 크래시 때문에 둘 다 무효화되는 셈이었다. `'session'`으로 정정했다 — `0161_mark_no_show_overload_and_redesign.sql:209`가 `order_session` 대상 실패 감사에 동일하게 `p_audit_domain := 'session'`을 쓰는 기존 선례와 일치한다(이 함수의 `p_subject_type := 'order_session'`과도 일관).

### §2.1 `bind_table_to_session()` 실패 응답 — 정정: `build_error_response()`로 감싸지 않고 그대로 반환 (2026-07-18, Stage 4 검증에서 발견된 차단급 결함 정정)

**이전 버전의 결함(라이브 재현으로 확인)**: 이전 초안은 `bind_table_to_session()`이 반환한 `error_key`(`session_not_found`, `session_not_bindable`, `table_already_bound`, `table_not_found`, `table_not_available`)를 그대로 `catchmenu_common.build_error_response()`에 다시 넣어 감쌌다. 이번 턴 라이브로 직접 재현한 결과, `session_not_bindable`/`table_already_bound`는 `catchmenu_common.error_codes`에 **등록돼 있지 않고**, 등록되지 않은 `error_key`로 `build_error_response()`를 호출하면 그 함수가 내부적으로 호출하는 `catchmenu_common.log_diagnostic()`이 `diagnostic_logs.is_recoverable`(NOT NULL) 컬럼에 `NULL`을 넣으려다 제약 위반으로 **크래시한다**:

```
ERROR:  null value in column "is_recoverable" of relation "diagnostic_logs" violates not-null constraint
```

`table_not_found`는 등록은 돼 있지만 `error_domain='STORE'`, `code=7105`(`601122_Logic_Dining_Table_Crud_Creation.md`가 다이닝 테이블 CRUD 전용으로 등록한 것)로, 착석 파이프라인의 바인딩 실패에 이 도메인/코드를 그대로 노출하면 API 소비자 입장에서 오도된 `error.domain`을 받게 된다 — 사람이 읽는 메시지 텍스트 자체는 우연히 통하지만("테이블을 찾을 수 없습니다"), 구조화된 `error.domain`/`error.code` 필드는 실제 실패 맥락(대기열 바인딩)과 무관한 값이 된다.

**정정된 설계**: `bind_table_to_session()`의 실패 응답(`jsonb_build_object('success', false, 'error_key', ...)`)을 **그대로(`return v_bind_result;`) 반환한다** — `build_error_response()`를 다시 씌우지 않는다.

**근거**:

1. **차단급 결함을 원천 차단**: `build_error_response()`를 아예 호출하지 않으므로, 미등록 `error_key`로 인한 크래시(위)와 도메인 오매핑 둘 다 구조적으로 발생할 수 없다.
2. **`0025` 워크패킷 범위 침범 회피**: `session_not_bindable`/`table_already_bound`를 `error_codes`/`message_catalog`에 신규 등록하는 방안(대안)도 검토했으나, 이 두 키는 `bind_table_to_session()`(`0025`, 이 워크패킷이 수정하지 않기로 확정한 canonical core)이 정의한 에러 어휘다 — 그 함수의 에러 계약을 이 워크패킷이 대신 등록하는 것은 `0025`의 소유 경계를 침범하는 일이고, 등록하더라도 근본 해결이 아니라 이 워크패킷의 증상만 가리는 것이다: `bind_table_to_session()`을 직접 호출하는 다른 호출자의 상황은 라이브로 전수 확인한 결과 제각각이다 — `0051.confirm_pre_order_arrival()`은 반환값을 확인해 안전하게 전파하지만(§8 (h)), `0052`의 키오스크 `DINE_IN` 경로는 `perform`으로 반환값 자체를 검사하지 않는다(§8 (h)) — 이런 호출자들의 크래시/침묵 위험은 이 워크패킷이 `error_codes`를 대신 등록해도 전혀 해소되지 않는다.
3. **`bind_table_to_session()`은 이미 `build_error_response()`를 쓰지 않는다** — 원본 자체가 `jsonb_build_object()`로 직접 완결된 응답을 만드는 설계였다(`601121_Overview.md` §1.2). 파사드가 그 응답을 있는 그대로 통과시키는 것은 새로운 관례를 만드는 게 아니라 원본이 이미 쓰던 관례를 그대로 존중하는 것이다.
4. **트레이드오프(정직하게 기록)**: 이 경로의 실패 응답은 `{success:false, error_key:'...'}`(평평한 구조)이고, 이 파사드의 다른 실패 경로(§2 단계 1-4, `EXCEPTION` 핸들러)는 `build_error_response()`의 `{success:false, error:{key, message, domain, code, ...}}`(중첩 구조)를 쓴다 — 같은 함수의 응답 형태가 실패 원인에 따라 두 가지로 갈린다. 현재 실호출자가 0건이라(`601121_Overview.md` §1.6) 이 비일관성의 실질적 비용은 낮지만, Open Item으로 남긴다(§8 (g)).

이전에 계획했던 폴백 키 `waiting_table_bind_failed`(`v_bind_result->>'error_key'`가 `NULL`일 경우 대비)도 `§5`에 등록된 적이 없어 동일한 크래시 위험을 안고 있었다 — 이번 정정으로 `build_error_response()` 호출 자체가 사라지면서 이 잠재적 결함도 함께 해소됐다(부수적으로 발견, 별도 대응 불필요).

## §3 두 렛저 이벤트가 공존하는 이유 (설계 근거, Open Item 아님)

`bind_table_to_session()`은 `event_domain='session', event_type='table_bound'`를 기록하고, 이 파사드는 별도로 `event_domain='waiting', event_type='customer_seated'`를 기록한다 — **의도적 중복이 아니라 서로 다른 분석 축**이다. `session`/`table_bound`는 "테이블-세션 바인딩"이라는 좌석 배정 인프라 관점의 이벤트이고, `waiting`/`customer_seated`는 "대기 고객이 착석까지 도달했다"는 대기열 KPI 관점의 이벤트다(`wait_duration_seconds`는 후자에만 있다). `600641_Overview_Call_Waiting_Customer_Contract_Recovery.md`가 복구한 `call_waiting_customer()`도 동일하게 `session`/`customer_called` 이벤트를 유지하는 관례를 따랐다 — 이 문서는 그 확립된 관례를 그대로 계승한다.

## §4 GRANT/REVOKE — `seat_waiting_customer()`

기존 GRANT(`0115:1756-1759`)를 그대로 유지한다 — 시그니처가 바뀌지 않았으므로 새로 등록할 필요가 없다. 라이브 확인 결과 `proacl`이 이미 `{=X/postgres,postgres=X/postgres,authenticated=X/postgres}`로 정상 설정돼 있다(`PUBLIC` 기본 권한 아님).

## §5 `message_catalog` / `error_codes` — 신규 5개 키

```sql
insert into catchmenu_common.message_catalog (
  message_key, locale, message_text
) values
('waiting_table_not_found', 'ko', '해당 테이블 번호를 찾을 수 없습니다'),
('waiting_table_not_found', 'en', 'Table number not found'),
('waiting_table_number_ambiguous', 'ko', '테이블 번호가 중복되어 특정할 수 없습니다'),
('waiting_table_number_ambiguous', 'en', 'Table number matches more than one table'),
('waiting_table_inactive', 'ko', '비활성화된 테이블입니다'),
('waiting_table_inactive', 'en', 'This table is inactive'),
('waiting_table_number_required', 'ko', '테이블 번호는 필수입니다'),
('waiting_table_number_required', 'en', 'Table number is required'),
('waiting_seat_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
('waiting_seat_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;

insert into catchmenu_common.error_codes (
  code, error_key, error_domain,
  error_category, http_status, severity
) values
(7073, 'waiting_table_not_found',
  'ORDER', 'NOT_FOUND', 404, 'WARNING'),
(7074, 'waiting_table_number_ambiguous',
  'ORDER', 'CONFLICT', 409, 'WARNING'),
(7075, 'waiting_table_inactive',
  'ORDER', 'CONFLICT', 409, 'WARNING'),
(7076, 'waiting_table_number_required',
  'ORDER', 'INVALID_INPUT', 400, 'WARNING'),
(7077, 'waiting_seat_operation_failed',
  'ORDER', 'TECHNICAL', 500, 'ERROR')
on conflict (code) do nothing;
```

**(중요, Stage 5/8 재확인 필요)** `code` 7073-7077은 이번 턴 라이브 확인한 `select max(code) from catchmenu_common.error_codes where error_domain='ORDER'` = `7072`를 기준으로 다음 번호를 잠정 배정했다 — Stage 8 구현 직전 재조회해 확정한다(`601122_Logic.md` §5와 동일한 절차). `error_category`는 `601122_Logic.md`가 정정한 라이브 `chk_error_category` 허용값(`NOT_FOUND`/`CONFLICT`/`INVALID_INPUT`/`PERMISSION`/`BUSINESS_RULE`/`TECHNICAL`/`TIMEOUT`/`CAPACITY`/`FINANCIAL`/`SECURITY`/`INTEGRATION`/`RECOVERABLE`)를 그대로 재사용해 검증했다 — `'TECHNICAL'`(내부 오류)/`'NOT_FOUND'`/`'CONFLICT'`/`'INVALID_INPUT'` 전부 그 목록 안에 있다.

`error_key`에 `table_not_found`/`table_code_duplicate` 같은 기존 `STORE` 도메인 키를 재사용하지 않고 전부 `waiting_` 접두어를 새로 붙인 이유는 `601121_Overview.md` §6 (a) 참고 — `build_error_response()`의 `error_key` 조회가 `error_domain`을 필터링하지 않아 동일 키의 다른 도메인 등록과 충돌할 수 있다.

## §6 마이그레이션 파일 배치

파일: `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`(잠정, Stage 5에서 번호 재확인 — `601121`/`601122`와 동일한 사유).

```sql
-- 0163_seat_waiting_customer_facade_correction.sql
-- Purpose: seat_waiting_customer()를 얇은 파사드로 재작성 —
--          phantom 컬럼(table_number/pre_order_amount) 크래시 제거.
--          bind_table_to_session()(0025)을 canonical core로 위임,
--          신규 리졸버(_resolve_dining_table_by_number)로
--          p_table_number -> table_id 변환.
-- Depends on: 0162_create_dining_table_admin_rpc.sql
-- Creates:
--   function catchmenu_pos._resolve_dining_table_by_number(...)
-- Replaces (create or replace, no signature change):
--   function catchmenu_pos.seat_waiting_customer(...) (원본 0115:988-1204)
```

`Depends on`을 `0162`로 잡은 이유: 리졸버가 `catchmenu_store.dining_tables`를 참조하며, `0162`가 그 테이블의 최신 CRUD 계약(`kds_device_id`/`did_device_id` 포함)을 확정한 가장 최근 워크패킷이기 때문이다 — 실제 스키마 의존은 훨씬 이전 마이그레이션(`0010`)부터지만, 순서상 최신 관련 작업을 명시한다.

### §6.1 파일 내부 문장 순서 (2026-07-18 명시, Codex+Cursor 검증)

파일 내부는 다음 순서로 구성한다 — `0110`/`0115`가 이미 쓰는 관례(i18n 블록 → 함수 정의 → GRANT 블록)를 그대로 따른다:

1. `message_catalog`/`error_codes` INSERT 블록(§5) — **함수 정의보다 먼저.**
2. `catchmenu_pos._resolve_dining_table_by_number(...)` 생성(§1).
3. `catchmenu_pos.seat_waiting_customer(...)` `create or replace`(§2).
4. `_resolve_dining_table_by_number(...)`의 `revoke`(§1.1).

**순서가 중요한 이유**: 이 마이그레이션 파일이 하나의 트랜잭션으로 통째로 적용되는 한(이 프로젝트의 `tools/apply_migrations.py` 관례) 파일 내부 문장 순서 자체는 최종 커밋 결과에 영향을 주지 않는다 — 함수 본문은 `error_codes` 행을 생성 시점이 아니라 **호출 시점**에 조회하기 때문이다. 하지만 이 프로젝트가 반복 확립해 온 "라이브 함수 직접 재실행" 절차(`601114_ChangeContract.md` §1.1/§5 등에 명시된 "source file update → ... → 직접 라이브 재실행 → `pg_get_functiondef()` 검증")에서, 구현자가 파일 전체가 아니라 **함수 정의 부분만** 골라 라이브에 재실행하는 실수를 하면 — INSERT 블록이 아직 라이브에 반영되지 않은 상태로 함수만 살아있는 순간이 생길 수 있다. `error_codes`/`message_catalog` INSERT를 파일 맨 앞에 두는 것은 이 실수를 하더라도 "함수보다 먼저 눈에 띄어 함께 실행될 가능성"을 높이는 방어적 배치다 — 완전한 보장은 아니므로, `600653_TestPlan.md`가 §9.3의 실제 실행 전제로 이를 명시적으로 요구한다.

## §7 TestPlan 영향 확인

- `bind_table_to_session()`/`orders`/`dining_tables` 어디도 본문을 수정하지 않는다 — `0 diff` 경계 대상.
- 최소 커버리지 후보(TestPlan 단계에서 확정): 정상 착석(리졸버 FOUND → bind 성공 → 부수효과 전부 확인), `waiting_table_number_required`(생략), `waiting_table_not_found`(존재하지 않는 코드), `waiting_table_inactive`(비활성 테이블), `waiting_table_number_ambiguous`(방어적 코드라 현재 스키마로는 직접 재현 불가 — 유니크 제약을 우회하는 테스트 방법이 필요, TestPlan 단계에서 설계), `bind_table_to_session()`의 각 실패 케이스(이미 바인딩됨/세션 바인딩 불가 상태/테이블 미가용)가 파사드를 통해 **`bind_table_to_session()`의 원본 평평한 응답 형태(`{success:false, error_key:...}`) 그대로** 노출되는지(§2.1, `build_error_response()`로 감싸지 않음을 확인 — 크래시하지 않는지가 핵심 회귀 테스트), 사전주문 있는 세션의 착석 시 `orders.final_amount` LEFT JOIN이 정확한 금액을 반환하는지, `EXCEPTION` 핸들러의 `waiting_seat_operation_failed` 반환 + 감사 기록 실제 영구 보존 확인(`601122_Logic.md` §5.4와 동일 패턴 재현).

## §8 Open Items

(a) `601121_Overview.md` §6 (f) / `600651_Overview.md` §6 (b) — 형제 함수 4개(`confirm_arrival`/`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`), 이 워크패킷에서 이어받아 그대로 유효, 후속 워크패킷 필요.
(b) `600651_Overview.md` §6 (c) — `pre_order_while_waiting()`도 동일 클래스 phantom을 갖고 있으나 죽은 코드일 가능성(§4.2), 확인 필요.
(c) `600651_Overview.md` §6 (d) — `did_display_queue` 테이블 자체가 구현된 적 없음, 이 워크패킷이 새로 만들지 않음.
(d) **[신규]** `catchmenu_pos._record_waiting_call()`의 `proacl`이 비어 있다(§1.1 발견) — `601142_Logic.md` §1.2/§3(a)와 동일한 클래스의 PUBLIC 기본 실행 권한 노출 위험이나, 이 워크패킷은 그 함수를 건드리지 않는다. `0160` 계열 후속 정리 워크패킷의 후보로 남긴다.
(e) `600651_Overview.md` §6 (a)/(e) — `waiting_` 접두어 명명 판단, `p_table_number` 정규화(trim/대소문자) 여부 — 이 문서에서 이어받아 그대로 유효.
(f) **[해소, 2026-07-18, Stage 4 검증 — §2.1 정정으로 자동 해결]** `bind_table_to_session()`의 5가지 실패 케이스에 대응하는 `error_key`가 `catchmenu_common.error_codes`에 등록돼 있는지 확인이 필요하다고 남겼던 항목 — 이번 정정으로 파사드가 그 키들을 `build_error_response()`에 넣지 않고 그대로 통과시키게 되면서(§2.1), 등록 여부 자체가 더 이상 이 워크패킷의 관심사가 아니게 됐다. 실제로 `session_not_bindable`/`table_already_bound`는 라이브 확인 결과 **등록돼 있지 않았고**(§2.1), 이것이 바로 이전 설계의 크래시 원인이었다.
(g) **[신규, 2026-07-18, §2.1 정정에서 발견]** 이 파사드의 응답 형태가 실패 원인에 따라 두 가지로 갈린다 — 리졸버/필수값 검증/`EXCEPTION` 핸들러 실패는 `build_error_response()`의 중첩 구조(`error.key`/`error.message`/`error.domain` 등)를, `bind_table_to_session()` 위임 실패는 평평한 구조(`error_key`만)를 반환한다(§2.1). 실호출자 0건이라 현재 비용은 낮지만, 향후 실제 클라이언트가 붙을 때 두 형태를 모두 처리해야 한다는 점을 인지해야 한다 — 통일하려면 `bind_table_to_session()` 자체를 `build_error_response()` 관례로 재설계해야 하는데, 그건 이 워크패킷이 명시적으로 범위 밖으로 둔 `0025`의 영역이다(§2.1 근거 2).

(h) **[신규, 2026-07-18, §9.2(TestPlan) 발견 → Codex+Cursor 검증으로 구체화 — canonical 위치는 `600654_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `bind_table_to_session()`이 자체 `EXCEPTION` 핸들러를 갖고 있지 않다는 사실(`600653_TestPlan.md` §9.2)은 이 워크패킷의 파사드에서는 "실패 시 전체 원자성"이라는 바람직한 결과를 낳지만, 다른 호출자에게는 그렇지 않을 수 있다 — 라이브로 전수 확인한 결과:

- `sql/migrations/0051_create_pre_order_rpc.sql:453-465`(`confirm_pre_order_arrival()`) — 반환값을 확인하고(`if not (v_bind_result->>'success')::boolean then return v_bind_result; end if;`) 안전하게 그대로 전파한다. **문제 없음** — 이 워크패킷의 §2.2 설계와 정확히 동일한 기존 패턴.
- `sql/migrations/0052_create_kiosk_session_rpc.sql:226-233`(키오스크 `DINE_IN` 주문 제출 경로) — `perform`으로 호출해 반환값 자체를 검사하지 않는다. `bind_table_to_session()`이 실패해도 호출자가 알아챌 방법이 없다 — "조용히 사라지는" 위험 패턴의 실제 사례.

이 워크패킷은 `bind_table_to_session()`도 `0052`도 수정하지 않으므로(`600654_ChangeContract.md` §8 (h)와 동일한 범위 밖 원칙) 손대지 않지만, `0052` 사례는 향후 `0025` 계열 검토 워크패킷의 최우선 확인 대상으로 격상해 기록한다. 최신·상세 버전은 `600654_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `600654`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, TestPlan/ChangeContract 단계로 진행 가능.** §1에서 리졸버(`_resolve_dining_table_by_number()`)를 실제 SQL 수준으로 설계했다 — 0/1/2+ 건 판정, `is_active` 별도 확인, 방어적 `AMBIGUOUS` 분기의 근거, 내부 전용 GRANT(`authenticated`에도 열지 않음, `_record_waiting_call()`의 기존 `proacl` 공백을 발견하고 이 신규 헬퍼에서는 반복하지 않도록 설계). §2에서 `seat_waiting_customer()` 파사드 전체를 재작성했다 — `bind_table_to_session()` 위임, `0160`의 `orders` LEFT JOIN 패턴 재사용, 대기열 도메인 고유 부수효과 보존, `EXCEPTION` 핸들러의 `raise;`→반환 원칙 선제 적용. 두 렛저 이벤트(`table_bound`/`customer_seated`)가 공존하는 이유를 설계 근거로 명시했다(§3, Open Item 아님). GRANT/REVOKE(§4), i18n 등록(§5, 5개 키, 코드 7073-7077 잠정), 마이그레이션 파일 배치(§6)까지 포함한다.

**(2026-07-18 정정, Stage 4 검증에서 발견된 차단급 결함 2건 해소)** `bind_table_to_session()`의 실패 응답을 `build_error_response()`로 다시 감싸던 이전 설계를 라이브로 재현한 결과, 미등록 `error_key`(`session_not_bindable`/`table_already_bound`) 사용 시 `diagnostic_logs.is_recoverable` NOT NULL 위반으로 크래시함을 확인했다 — `table_not_found` 재사용도 `STORE` 도메인(`601122_Logic.md`의 다이닝 테이블 CRUD 전용 코드 7105)과 오매핑되는 문제가 있었다. `bind_table_to_session()`의 원본 응답을 그대로 반환하는 방식(`return v_bind_result;`)으로 정정해 두 문제를 구조적으로 제거했다(§2.1) — `0025` 워크패킷의 에러 어휘를 대신 등록하지 않는 것이 그 함수의 소유 경계를 지키는 선택이라는 근거도 함께 기록했다. 이 정정으로 응답 형태 비일관성(중첩 vs 평평)이라는 새로운 트레이드오프가 생겼음을 Open Item으로 정직하게 남겼다(§8 (g)).

**(2026-07-18 추가 정정, Codex+Cursor 검증 — 3건 해소)** (1) `EXCEPTION` 핸들러의 `p_audit_domain`을 `'waiting'`에서 `'session'`으로 정정했다 — 라이브 재확인 결과 `chk_audit_domain`이 `'waiting'`을 허용하지 않아, 방치했다면 이 핸들러 자신의 `append_audit_record()` 호출이 다시 크래시하며 상위 핸들러 없이 그대로 전파됐을 차단급 결함이었다(§1.5의 정정 주석). (2) 마이그레이션 파일 내부 문장 순서를 명시했다 — `error_codes`/`message_catalog` INSERT가 함수 정의보다 먼저 오도록(§6.1), 그리고 이 전제를 `600653_TestPlan.md` §9.3에도 명시적으로 추가했다. (3) Open Item (h)가 애초에 막연히 "다른 호출자가 있다면"으로 남겨뒀던 부분을 라이브 검증한 실제 두 사례로 구체화했다 — `0051.confirm_pre_order_arrival()`은 반환값을 확인하고 안전하게 전파함(문제 없음, 이 워크패킷의 설계와 동일 패턴), `0052`의 키오스크 DINE_IN 경로는 `perform`으로 반환값을 버려 바인딩 실패가 완전히 조용히 사라짐(실제 위험 사례, 후속 워크패킷 최우선 확인 대상으로 격상). `.sql` 파일은 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md] =====
# 600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`seat_waiting_customer_facade_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` §1-§6 — the new internal helper `catchmenu_pos._resolve_dining_table_by_number()` and the rewritten `catchmenu_pos.seat_waiting_customer()` facade, in a new migration file (tentatively `sql/migrations/0163_seat_waiting_customer_facade_correction.sql`).

Document number check:

- `600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` exists.
- `600652_Logic_Seat_Waiting_Customer_Facade_Correction.md` exists.
- `600653_TestPlan_Seat_Waiting_Customer_Facade_Correction.md` is the next TestPlan document number for this workpacket.
- `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` is the paired ChangeContract.

Test fixtures use the `__test_dining_table_600653_*` table-code prefix (distinct from every other TestPlan's fixtures in this project) and `<test_tenant_id>`/`<test_store_id>`/`<test_actor_id>` placeholders matching this project's established convention. Every section is a self-contained `begin;...rollback;` block.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md` is hit, stop and report.

### §1.1 Target function does not yet exist; `seat_waiting_customer()` still has the pre-fix signature

```sql
select proname
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname = '_resolve_dining_table_by_number';

select pg_get_function_identity_arguments(oid)
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname = 'seat_waiting_customer';
```

Expected: `_resolve_dining_table_by_number` returns 0 rows (new function, not yet created). `seat_waiting_customer` returns its existing identity arguments unchanged (`p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text, p_actor_id uuid, p_locale text, p_correlation_id text`) — confirms Stage 8 has not already run.

### §1.2 `bind_table_to_session()`, `orders`, `dining_tables` — dependencies exist and are unmodified by this plan

```sql
select proname from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace and proname = 'bind_table_to_session';

select column_name, data_type from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions'
  and column_name in ('order_id', 'pre_order_created_at', 'table_id')
order by column_name;
```

Expected: `bind_table_to_session` exists; `order_sessions.order_id` (uuid), `pre_order_created_at` (timestamptz), `table_id` (uuid) all present — matching `600651_Overview.md` §3's baseline.

### §1.3 `error_codes` ORDER-domain ceiling (baseline for §9)

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'ORDER';
```

Expected (as of this document's writing): `7072`. Record the live value at pre-flight time — input to §9's Stage-8-immediately-before-implementation re-check, not a fixed assumption.

## §2 Test A — normal seating: resolver FOUND → bind success → all four side effects

### §2.1 Setup

```sql
begin;

-- Table to seat at.
select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

-- Waiting session, no pre-order.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING',
  9001, 2, now() - interval '12 minutes'
) returning id as normal_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'normal_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_normal',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as seat_resp \gset
```

### §2.2 Expected result

```sql
select :'seat_resp'::jsonb ->> 'success' as success;
select :'seat_resp'::jsonb -> 'data' ->> 'table_id' as returned_table_id;
select :'seat_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;

-- order_sessions state (bind_table_to_session()'s own writes)
select session_status, table_id, seated_at is not null as has_seated_at
from catchmenu_pos.order_sessions where id = :'normal_session_id'::uuid;

-- dining_tables state (bind_table_to_session()'s own writes)
select table_status, current_session_id, occupied_since is not null as has_occupied_since
from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_600653_normal';

-- side effect 1: no diagnostic log expected (no pre-order) — see §2.4 for the pre-order variant.

-- side effect 2: remaining_queue in the response reflects other WAITING/ARRIVAL_PENDING sessions.
select :'seat_resp'::jsonb -> 'data' ->> 'remaining_queue' as remaining_queue_in_response;

-- side effect 3: two catchmenu_ledger.events rows for this seating — 'session'/'table_bound'
-- (from bind_table_to_session()) and 'waiting'/'customer_seated' (from the facade, §600652 §3).
select event_domain, event_type, event_payload ->> 'wait_duration_seconds' as wait_duration_seconds
from catchmenu_ledger.events
where subject_id = :'normal_session_id'::uuid
  and event_type in ('table_bound', 'customer_seated')
order by event_domain;

rollback;
```

Expected:

- `success = true`; `returned_table_id` = the created table's id; `has_pre_order = false`.
- `session_status = 'SEATED'`, `table_id` = the resolved table id, `has_seated_at = true`.
- `table_status = 'OCCUPIED'`, `current_session_id` = the session id, `has_occupied_since = true` — confirms `bind_table_to_session()`'s physical-occupation side effect actually fires through the facade (`600651_Overview.md` §1.3, the improvement the original broken `seat_waiting_customer()` never had).
- `remaining_queue_in_response` is a non-negative integer (exact value depends on fixture isolation — assert it is present and numeric, not that it equals a specific count, since other `begin;...rollback;` sections do not leak state into this one).
- Exactly two rows: one `event_domain='session', event_type='table_bound'` (no `wait_duration_seconds` key — that field belongs only to the facade's own event); one `event_domain='waiting', event_type='customer_seated'` with a non-null `wait_duration_seconds` roughly matching the ~12-minute gap set up in §2.1 (`600652_Logic.md` §3 — two ledger events by design, not a bug).

### §2.3 Notification side effects — Realtime channel verification

`catchmenu_common.notify_channel()` does not persist to a queryable table in this codebase (it is a pure Realtime broadcast side effect) — this cannot be asserted via SQL after the fact. This TestPlan records the requirement (`600652_Logic.md` §2 steps in the "대기열 도메인 고유 부수효과" block: one `WAITING_QUEUE`/`waiting_session_seated` and one `DID_DISPLAY`/`call_dismissed` notification) as a **code-review-level check at Stage 8/9**, not a SQL-level assertion — confirm both `perform catchmenu_common.notify_channel(...)` calls are present in the live function body via `pg_get_functiondef()` and match the payload shape `600652_Logic.md` §2 specifies.

### §2.4 Pre-order variant — `orders.final_amount` LEFT JOIN returns the correct amount

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_preorder',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', current_date, 'WAITING',
  9002, 2, now() - interval '5 minutes'
) returning id as preorder_session_id \gset

-- Real pre-order row (mirrors 0051.create_pre_order()'s actual writes,
-- 600651_Overview.md §4.2) — order_status must NOT be a value that would
-- itself imply payment, since this is still HOLD/pre-payment.
insert into catchmenu_pos.orders (
  tenant_id, store_id, session_id, order_number,
  order_type, order_status, order_source,
  total_amount, final_amount, ordered_at, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'preorder_session_id'::uuid, 'W9002',
  'TABLE', 'CONFIRMED', 'PRE_ORDER',
  15000, 15000, now(), current_date
) returning id as preorder_order_id \gset

update catchmenu_pos.order_sessions
set order_id = :'preorder_order_id'::uuid, pre_order_created_at = now()
where id = :'preorder_session_id'::uuid;

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'preorder_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_preorder',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as seat_resp \gset

select :'seat_resp'::jsonb ->> 'success' as success;
select :'seat_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'seat_resp'::jsonb -> 'data' ->> 'pre_order_amount' as pre_order_amount;
select :'seat_resp'::jsonb -> 'data' -> 'next_step' ->> 'action' as next_step_action;

select event_payload ->> 'pre_order_amount' as ledger_pre_order_amount,
       event_payload ->> 'had_pre_order' as ledger_had_pre_order
from catchmenu_ledger.events
where subject_id = :'preorder_session_id'::uuid and event_type = 'customer_seated';

rollback;
```

Expected: `success = true`; `has_pre_order = true`; `pre_order_amount = 15000` (from `orders.final_amount` via the LEFT JOIN, not any `order_sessions` column — `600652_Logic.md` §2 step 1); `next_step_action = 'PROCEED_TO_PAYMENT'`; ledger event's `pre_order_amount = 15000`, `had_pre_order = true`. A pre-fix (phantom-column) implementation could not have reached this point at all — this also serves as the primary regression proof that the crash is gone.

## §3 Test B — `waiting_table_number_required` (omitted)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9003, 2
) returning id as no_number_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'no_number_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;
select session_status from catchmenu_pos.order_sessions where id = :'no_number_session_id'::uuid;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_number_required'`; `session_status` unchanged (`'WAITING'`, no partial write — `p_table_number is null` is checked before the resolver or `bind_table_to_session()` run at all, `600652_Logic.md` §2 step 3).

## §4 Test C — `waiting_table_not_found` (nonexistent code)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9004, 2
) returning id as notfound_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'notfound_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_does_not_exist',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;
select session_status, table_id from catchmenu_pos.order_sessions where id = :'notfound_session_id'::uuid;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_not_found'`; session left untouched (`'WAITING'`, `table_id` still `NULL`).

## §5 Test D — `waiting_table_inactive` (table exists, `is_active=false`)

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_inactive',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as inactive_table_id \gset

select catchmenu_store.set_dining_table_active(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := :'inactive_table_id'::uuid, p_is_active := false,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as deact_resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9005, 2
) returning id as inactive_test_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'inactive_test_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_inactive',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_table_inactive'` — distinct from `waiting_table_not_found` (the resolver found the row but flagged it inactive, `_resolve_dining_table_by_number()`'s `INACTIVE` branch, `600652_Logic.md` §1).

## §6 Test E — `waiting_table_number_ambiguous` (defensive branch, constraint temporarily lifted)

**(중요)** `uq_dining_table_store_code` is a full (non-partial) `UNIQUE (store_id, table_code)` constraint — under the live schema, two rows with the same `table_code` in the same store cannot coexist, so this branch cannot be reached by any normal `upsert_dining_table()` call sequence (`600651_Overview.md` §1.4). To exercise the defensive code path itself, this test temporarily drops the constraint **inside a transaction that always rolls back** — the constraint is restored to its live definition either explicitly (below) or automatically by the `rollback;` at the end (DDL is transactional in PostgreSQL; even if the explicit re-`ADD CONSTRAINT` step were omitted, the `rollback;` alone would already undo the `DROP CONSTRAINT`). No permanent schema change occurs.

```sql
begin;

alter table catchmenu_store.dining_tables drop constraint uq_dining_table_store_code;

insert into catchmenu_store.dining_tables (
  tenant_id, store_id, table_code, capacity
) values
  ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous', 4),
  ('<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous', 6);

-- Restore the constraint before exercising the function under test, so the
-- test also confirms the resolver's own defensive check — not just a
-- transient constraint-free window — is what produces the AMBIGUOUS result.
alter table catchmenu_store.dining_tables
  add constraint uq_dining_table_store_code unique (store_id, table_code);
```

This `ADD CONSTRAINT` on already-duplicated data will itself fail with a constraint-violation error — which is expected and fine, since the goal is only to prove the two duplicate rows exist for the resolver to see, not to actually restore uniqueness within this test. If the `ADD CONSTRAINT` step is skipped for that reason, proceed directly to the resolver/facade call below; the `rollback;` at the end restores the schema regardless.

```sql
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9006, 2
) returning id as ambiguous_session_id \gset

select * from catchmenu_pos._resolve_dining_table_by_number(
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, '__test_dining_table_600653_ambiguous'
);

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'ambiguous_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_ambiguous',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: the direct resolver call returns `v_status = 'AMBIGUOUS'`, `v_table_id = NULL`; the facade call returns `success = false`, `error_key = 'waiting_table_number_ambiguous'`. After `rollback;`, `uq_dining_table_store_code` is confirmed still present via §1-style re-query (recommended as an explicit post-rollback pre-flight-style check the first time this test is run, to build confidence in the technique before relying on it repeatedly).

## §7 Test F — `bind_table_to_session()` delegation failures (reachability analysis + reproductions)

`600651_Overview.md` §1.2 lists five `bind_table_to_session()` failure keys. Tracing the facade's own control flow (`600652_Logic.md` §2) against each:

| `error_key` | Reachable via this facade? | Reasoning |
|---|---|---|
| `session_not_found` | **No** | The facade's own step 1 already looks up the session with the same `p_session_id`/`p_store_id`/`p_tenant_id` and holds a row lock (`for update of os`) through the rest of the call — by the time `bind_table_to_session()` re-queries the same row, it is guaranteed to still exist and be visible in the same transaction. |
| `session_not_bindable` | **Yes** | Any `session_status` outside `('WAITING','ARRIVAL_PENDING','ORDERING')` that also isn't `'SEATED'` (already caught earlier by the facade, §2.1) — e.g. `'CANCELLED'`. |
| `table_already_bound` | **Yes** (requires an artificially-constructed fixture state, §7.3) | `bind_table_to_session()`'s own logic only ever sets `table_id` together with `session_status='SEATED'` — so a session with `table_id` already set but a non-`SEATED` status doesn't arise from normal use of this facade. The test constructs this state directly to exercise the defensive check. |
| `table_not_found` (table-side) | **No** | The resolver (`_resolve_dining_table_by_number()`) already requires the row to exist before returning `FOUND`, using the same `store_id`; no physical `DELETE` path exists for `dining_tables` (`601121_Overview.md` §0.2/§3) and nothing can delete the row between the resolver's check and the bind call within one function execution (no yield point). |
| `table_not_available` | **Yes** | The resolver checks only `is_active`, never `table_status` — an active table that is currently `OCCUPIED`/`CLEANING`/`BLOCKED` passes the resolver as `FOUND` but fails `bind_table_to_session()`'s own `table_status in ('AVAILABLE','RESERVED')` check. |

This table itself is the required evidence for the two "No" rows — TestPlan coverage for `session_not_found` and `table_not_found` (table-side) consists of this reachability proof, not a live reproduction, since no live reproduction through this facade is possible. Constructing an artificial call to `bind_table_to_session()` directly (bypassing the facade) to observe those two keys firing is out of scope — `bind_table_to_session()` itself is not modified by or newly tested by this workpacket (`600651_Overview.md` §1.2, no-regression-only).

### §7.1 `session_not_bindable`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_not_bindable',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'CANCELLED', 9007, 2
) returning id as cancelled_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancelled_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_not_bindable',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;

rollback;
```

Expected: `success = false`; **`error_key = 'session_not_bindable'`** (note: flat top-level `error_key`, not `error.key` — `600652_Logic.md` §2.1's raw pass-through, not `build_error_response()`'s nested shape). This is also the primary regression proof for §2.1's correction: the call must complete normally, not crash.

### §7.2 `table_not_available`

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_occupied',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as occupied_table_id \gset

-- Occupy it via a first, unrelated seating.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9008, 2
) returning id as first_party_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'first_party_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_occupied',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as first_seat_resp \gset

-- A second party tries to be seated at the SAME table_number.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9009, 3
) returning id as second_party_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'second_party_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_occupied',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as second_seat_resp \gset

select :'first_seat_resp'::jsonb ->> 'success' as first_seat_ok;
select :'second_seat_resp'::jsonb ->> 'success' as second_seat_ok;
select :'second_seat_resp'::jsonb ->> 'error_key' as second_seat_error_key;

rollback;
```

Expected: `first_seat_ok = true`; `second_seat_ok = false`; `second_seat_error_key = 'table_not_available'` — the resolver found the (still `is_active=true`) table (`FOUND`), but `bind_table_to_session()` correctly rejects binding a second session to an already-`OCCUPIED` table.

### §7.3 `table_already_bound` (artificially constructed fixture state)

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_prebound',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ->> 'table_id' as prebound_table_id \gset

-- Directly construct the edge state bind_table_to_session()'s own logic never
-- produces on its own: table_id already set, but session_status still
-- ARRIVAL_PENDING (not SEATED) — no public RPC creates this combination.
insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status,
  wait_number, guest_count, table_id
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'ARRIVAL_PENDING',
  9010, 2, :'prebound_table_id'::uuid
) returning id as prebound_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'prebound_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_prebound',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'table_already_bound'`.

## §8 Test G — `waiting_already_seated` intercepted before delegation

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, table_id
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'SEATED', 9011, 2, null
) returning id as already_seated_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'already_seated_session_id'::uuid,
  p_table_number := 'anything',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

rollback;
```

Expected: `success = false`; `error_key = 'waiting_already_seated'` (nested `error.key` — this path returns via `build_error_response()`, §600652 §2 step 2, unlike §7's flat delegation-failure responses). The resolver and `bind_table_to_session()` are never reached — `p_table_number := 'anything'` (a table_number that doesn't even resolve to a real table) is deliberately used to prove this, since if the already-seated check were bypassed, the call would instead fail with `waiting_table_not_found`, not `waiting_already_seated`.

## §9 Test H — `EXCEPTION` handler: `waiting_seat_operation_failed` + audit persistence + full-call atomicity

**(2026-07-18 재시도 성공)** §6의 "트랜잭션 안에서 제약을 임시로 조작한다"는 기법을 반대 방향으로 적용해 안전한 트리거를 찾았다 — §6은 제약을 **완화**(UNIQUE 제거)해 정상적으로는 불가능한 상태를 만들었고, 이번엔 제약을 **강화**(파사드 자신의 렛저 이벤트 INSERT 하나만 정확히 겨냥하는 신규 CHECK 추가)해서 원래는 성공했을 쓰기를 실패시킨다. 라이브로 직접 재현해 정확히 의도한 대로 작동함을 확인했다.

### §9.1 트리거 설계 — `catchmenu_ledger.events`에 임시 CHECK 추가

`600652_Logic.md` §2 재확인 결과, 이 파사드가 **직접** 쓰는 테이블은 `catchmenu_ledger.events` 하나뿐이다(`event_type='customer_seated'`, §2 step 7) — `order_sessions`/`dining_tables`에 대한 UPDATE는 전부 `bind_table_to_session()` 내부에서 일어나고, 그 함수는 건드리지 않기로 확정했다(`600654_ChangeContract.md` §4). `catchmenu_ledger.events`의 제약 전수 확인(`pg_constraint`) 결과 CHECK 5개(`chk_event_domain`/`chk_event_caused_by_type`/`chk_event_payload_object`/`chk_event_replay_has_original`/`chk_event_type_not_blank`) + FK 6개 + PK 1개, UNIQUE는 없음 — 파사드의 실제 값(`event_domain='waiting'`, `event_type='customer_seated'`, `caused_by_type='STAFF'`, `event_payload`는 항상 object)은 기존 제약을 전부 통과한다. 그래서 **`event_type = 'customer_seated'`만 정확히 겨냥하는 신규 임시 CHECK**를 추가한다:

```sql
alter table catchmenu_ledger.events
  add constraint tmp_block_customer_seated check (event_type <> 'customer_seated');
```

**정밀성 확인(라이브 재현 완료)**: 이 제약은 `bind_table_to_session()` 자신의 렛저 이벤트(`event_type='table_bound'`, 다른 값)에는 전혀 영향을 주지 않는다 — 직접 재현한 결과 `table_bound` INSERT는 성공하고, `customer_seated` INSERT만 정확히 실패한다:

```
INSERT 0 1                               -- table_bound, 성공
ERROR:  new row for relation "events" violates check constraint "tmp_block_customer_seated"  -- customer_seated, 실패
```

즉 이 기법은 `bind_table_to_session()`의 동작에는 전혀 개입하지 않고, 파사드 자신의 실행 지점(bind 위임이 이미 성공한 **이후**)에서만 정확히 예외를 유발한다.

### §9.2 **중요 발견** — 예외 발생 시 `bind_table_to_session()`의 상태 변경도 전부 롤백된다 (전체 원자성)

이 테스트를 설계하는 과정에서 라이브로 직접 재현해 확인한 핵심 사실: `bind_table_to_session()`은 자체 `EXCEPTION` 핸들러가 없는 평범한 `begin...end` 블록이다(라이브 `pg_get_functiondef()` 재확인, `600651_Overview.md` §1.2) — 즉 이 함수 자신의 실행을 위한 별도의 암묵적 SAVEPOINT가 없다. 파사드가 `bind_table_to_session()`을 호출해 성공한 뒤, **그보다 나중에** 파사드 자신의 코드에서 예외가 발생하고 파사드의 `EXCEPTION WHEN OTHERS`가 그것을 잡으면, 그 SAVEPOINT(파사드 함수 시작 시점에 설정됨)까지 롤백된다 — `bind_table_to_session()`이 이미 커밋한 것처럼 보였던 모든 변경(`order_sessions.table_id`/`session_status='SEATED'`, `dining_tables.table_status='OCCUPIED'`, `bind_table_to_session()` 자신의 `session_events`/`ledger.events`('table_bound')/`audit_records`)이 **전부 함께 롤백된다.** 오직 `EXCEPTION` 핸들러 자체가 실행하는 문장(파사드의 `append_audit_record()` 호출)만 이 롤백에서 제외되고 살아남는다.

이 사실을 최소 재현으로 직접 검증했다(임시 함수 2개, 내부 호출 + 이후 실패 + 상위 예외 핸들러 조합):

```sql
-- inner_call()이 tmp_probe_state를 UPDATE(성공) → outer_facade()가 나중에
-- 실패 → outer_facade()의 EXCEPTION 핸들러가 잡음
select pg_temp.outer_facade();  -- 'caught_and_returned'
select * from tmp_probe_state;  -- val = 'initial' (inner_call()의 UPDATE가 롤백됨!)
select * from tmp_probe_audit;  -- 예외 핸들러의 INSERT는 살아있음
```

**이것은 결함이 아니라 바람직한 원자성이다** — "착석 처리가 도중에 실패하면, 부분적으로 성공한 것처럼 보였던 테이블 점유/세션 전이까지 전부 되돌아간다"는 것을 의미한다. `601122_Logic.md`가 발견한 "예외 핸들러 안의 감사 기록조차 함께 롤백된다"는 문제(§1.5)와는 다른 지점이다 — 거기서는 감사 기록 INSERT **자체가** 실패의 원인이자 롤백 대상이었지만, 여기서는 감사 기록은 **예외 핸들러 안에서** 실행되므로 살아남고, 롤백되는 것은 그 이전에 있었던 (겉보기엔 성공한) 다른 작업들이다.

### §9.3 테스트

**전제(2026-07-18 명시, Codex+Cursor 검증)**: 이 테스트를 포함해 이 문서의 모든 섹션은 Stage 8이 `0163` 마이그레이션 파일 **전체**(§6.1이 명시한 순서 — `error_codes`/`message_catalog` INSERT 블록이 함수 정의보다 먼저)를 이미 적용한 뒤 실행된다고 가정한다. `waiting_seat_operation_failed`(§5, 코드 7077)가 아직 `error_codes`에 등록되지 않은 상태에서 이 테스트를 실행하면, `EXCEPTION` 핸들러의 `build_error_response()` 호출 자체가 (등록되지 않은 `error_key`이므로) `600652_Logic.md` §2.1이 라이브로 실증했던 것과 동일한 방식으로 크래시한다 — 즉 이 테스트가 검증하려는 대상(친절한 에러 응답)과 정확히 같은 실패 모드가, 이번엔 "미등록 `error_key`"라는 다른 원인으로 재현될 수 있다. Stage 8은 라이브 함수 재실행 절차(§6.1) 중 이 INSERT 블록을 누락하지 않았는지 먼저 `select code from catchmenu_common.error_codes where error_key='waiting_seat_operation_failed';`로 확인한 뒤 이 테스트를 실행해야 한다.

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_customer_seated check (event_type <> 'customer_seated');

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_dining_table_600653_exc',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', current_date, 'WAITING', 9012, 2
) returning id as exc_session_id \gset

select catchmenu_pos.seat_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_table_number := '__test_dining_table_600653_exc',
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- §9.2가 확인한 전체 원자성 — bind_table_to_session()의 변경도 전부 롤백됐어야 한다.
select session_status, table_id from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;
select table_status, current_session_id from catchmenu_store.dining_tables
where tenant_id = '<test_tenant_id>'::uuid and store_id = '<test_store_id>'::uuid
  and table_code = '__test_dining_table_600653_exc';

-- bind_table_to_session() 자신의 'table_bound' 이벤트/감사 기록도 함께 사라졌어야 한다.
select count(*) as bind_ledger_event_count from catchmenu_ledger.events
where subject_id = :'exc_session_id'::uuid and event_type = 'table_bound';
select count(*) as bind_audit_count from catchmenu_ledger.audit_records
where subject_id = :'exc_session_id'::uuid and audit_type = 'table_late_binding_completed';

-- 파사드 자신의 실패 감사 기록만 살아남았어야 한다.
select audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'seat_waiting_customer_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_customer_seated;

rollback;
```

Expected:

- `success = false`; `error_key`(중첩) = `'waiting_seat_operation_failed'` — 클라이언트에 원본 Postgres 예외가 그대로 전파되지 않는다.
- `session_status = 'WAITING'`(원래 상태로 되돌아감, `'SEATED'` 아님), `table_id`는 `NULL`.
- `table_status = 'AVAILABLE'`(원래 상태), `current_session_id`는 `NULL`.
- `bind_ledger_event_count = 0`, `bind_audit_count = 0` — `bind_table_to_session()`이 만들었던 모든 기록이 함께 롤백됐다(§9.2).
- **정확히 한 행**: `audit_type = 'seat_waiting_customer_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`(CHECK 위반) — 이 행만 살아남는다. 이것이 `raise;`→`build_error_response()` 반환 정정(`600652_Logic.md` §2)이 실제로 작동함을 보여주는 직접 증거다.
- `alter table ... drop constraint`가 성공(또는 최종 `rollback;`이 이를 대체)해 스키마에 영구적 흔적을 남기지 않는다.

## §10 Boundary — 0 diff

```bash
git status --short sql/migrations/0025_create_session_rpc.sql
git status --short sql/migrations/0048_create_table_management_rpc.sql
git status --short sql/migrations/0050_create_waiting_queue_rpc.sql
git status --short sql/migrations/0110_create_store_admin_rpc.sql
git status --short sql/migrations/0162_create_dining_table_admin_rpc.sql
```

Expected: all empty. In particular, `bind_table_to_session()`'s body (`0025`), `catchmenu_pos.orders`/`catchmenu_store.dining_tables` schema (no migration file in this list touches their `CREATE TABLE` definitions), and the five other domains' RPCs above show zero diff. `0115_create_waiting_pipeline_rpc.sql` is **not** in this zero-diff list — the whole point of this workpacket is that `seat_waiting_customer()`'s live definition changes (via `CREATE OR REPLACE` in the new `0163` file, not by editing `0115` itself) — confirm via `git status --short sql/migrations/0115_create_waiting_pipeline_rpc.sql` that **that source file itself** still shows zero diff (the live function is overridden by the later migration, `0115`'s own text is untouched, matching how `0160` overrode `call_waiting_customer()` without editing `0115`).

## §11 Acceptance criteria

PASS only if all are true:

1. Normal seating succeeds end-to-end: resolver `FOUND` → `bind_table_to_session()` success → session `SEATED`/table `OCCUPIED` (both bind's own writes) → two ledger events (`table_bound` + `customer_seated`, distinct domains) → correct response shape (§2).
2. Pre-order seating correctly reports `has_pre_order`/`pre_order_amount` sourced from `orders.final_amount` via the `order_id` LEFT JOIN, not any phantom column (§2.4) — this is the direct proof the original crash is gone.
3. `waiting_table_number_required`/`waiting_table_not_found`/`waiting_table_inactive` each return the correct friendly error with no partial state change (§3-§5).
4. `waiting_table_number_ambiguous` is reachable via the constraint-lifted test technique and returns correctly (§6).
5. Of `bind_table_to_session()`'s five failure keys, the three reachable via this facade (`session_not_bindable`, `table_already_bound`, `table_not_available`) are reproduced and confirmed to pass through as `bind_table_to_session()`'s original flat JSON, unwrapped — with no crash (§7); the two unreachable ones (`session_not_found`, `table_not_found`) are covered by the reachability proof instead of a live reproduction.
6. `waiting_already_seated` is intercepted by the facade's own check before the resolver or `bind_table_to_session()` ever run (§8).
7. The `EXCEPTION` handler path returns `waiting_seat_operation_failed` with no raw Postgres error reaching the client, the facade's own `FAILED` audit row actually persists, and — the deeper property this test proves — `bind_table_to_session()`'s own state changes (session/table/its own ledger event/its own audit record) are all rolled back together with the exception, since it has no `EXCEPTION` handler of its own to create a separate savepoint boundary (§9, full-call atomicity).
8. `0025`/`0048`/`0050`/`0110`/`0162` all show zero diff; `0115`'s own source text shows zero diff despite `seat_waiting_customer()`'s live behavior changing via the new `0163` migration (§10).


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600650_seat_waiting_customer_facade_correction/600654_ChangeContract_Seat_Waiting_Customer_Facade_Correction.md] =====
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

===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md] =====
# 600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0.1 원칙 (문서 전체에 적용)

`0115_create_waiting_pipeline_rpc.sql`에 원래 작성된 함수들은 라이브 스키마와 어긋나는 `order_sessions`의 phantom 컬럼(존재한 적 없거나, 다른 이름의 실컬럼으로 대체된 컬럼)을 참조해서 호출할 때마다 크래시한다. `0160_call_waiting_customer_contract_recovery.sql`(`call_waiting_customer()`)과 `0163_seat_waiting_customer_facade_correction.sql`(`seat_waiting_customer()`)이 이미 이 문제를 해소한 두 가지 검증된 패턴이 있다:

1. **금액류 phantom 컬럼**(`pre_order_amount`): `order_sessions.order_id` → `catchmenu_pos.orders.final_amount` LEFT JOIN으로 대체.
2. **라벨류 phantom 컬럼**(`table_number`): `order_sessions`에 저장하지 않고, 호출 시점의 `p_table_number`/`dining_tables.table_code` 조회 결과를 응답 payload에만 실어 보낸다.

이 워크패킷은 이 두 패턴(및 §2가 새로 확립하는 세 번째 패턴)을 `0115`에 남은 나머지 4개 함수 — `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` — 에 적용 가능한지 라이브로 재검증하고, 적용 설계를 확정한다.

## §0.2 배경 — 오늘 이전에 이미 확인된 사실 (재확인 없이 인용, §1에서 최신 라이브 상태만 재확인)

`600651_Overview_Seat_Waiting_Customer_Facade_Correction.md` §4.1이 이미 다음을 확인해 스코프 밖으로 남겨두었다: `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 4개 함수 모두 phantom 컬럼(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`) 참조로 크래시하거나 크래시 위험이 있다.

## §1 함수별 라이브 재확인 — 정확한 라인, phantom 컬럼, 그 외 로직

사전 확인: `information_schema.columns`로 `catchmenu_pos.order_sessions`의 라이브 컬럼 전체를 재조회했다(2026-07-18). 존재하는 시간 계열 컬럼은 `session_started_at`/`arrived_at`/`seated_at`/`ordering_started_at`/`order_confirmed_at`/`payment_started_at`/`payment_completed_at`/`completed_at`/`cancelled_at`/`expires_at`/`pre_order_created_at`/`pre_order_expires_at`이 전부다. `queue_position`은 실컬럼이며 `0050_create_waiting_queue_rpc.sql`의 대기열 재정렬 RPC와 `0115`의 `register_waiting()`이 이미 이 컬럼에 쓰고 있어 활성 상태임을 확인했다(§1.3에서 이 사실이 중요해진다). `memo`/`call_count`/`table_number`/`pre_order_amount`/`called_at`/`arrival_confirmed_at`/`cancel_reason`은 **모두 존재하지 않는다.**

### §1.1 `confirm_arrival()` (`0115:872-985`)

**Phantom 컬럼 참조:**

| 라인 | 종류 | 컬럼 | 비고 |
|---|---|---|---|
| 897-899 | SELECT | `pre_order_amount`, `table_number` | `v_session` record에 로드 |
| **921** | **UPDATE (쓰기)** | **`arrival_confirmed_at`** | 이 UPDATE 문 자체가 크래시 지점 — `seat_waiting_customer()`의 `table_number` UPDATE(`600651_Overview.md` §1.1)와 동일한 클래스의 결함이지만, 저 함수와 달리 이건 **쓰기** 시도이므로 SELECT 단계까지 갈 것도 없이(사실 SELECT가 먼저 크래시하지만) 도달했다면 여기서도 별도로 크래시했을 것이다 |
| 934-937, 958-959, 970-973 | 응답/알림/렛저 payload 구성 | `pre_order_amount` | `v_session.pre_order_amount` 읽기 |
| 974 | 응답 payload | `table_number` | `v_session.table_number` |

**그 외 로직(정상, 보존 대상):** `session_status → 'ARRIVAL_PENDING'` 전이, `notify_channel()`(`WAITING_QUEUE`/`waiting_arrival_confirmed`), `catchmenu_ledger.events` 삽입(`waiting`/`arrival_confirmed`), 성공 응답의 `next_step`(사전주문 있으면 `PROCEED_TO_PAYMENT`, 없으면 `WAIT_FOR_SEATING`) 분기.

**phantom 컬럼과 무관한, 추가로 발견된 결함**: 이 함수는 `session_status`에 대한 사전 가드가 전혀 없다 — `v_session.id is null` 체크 다음 곧바로 `UPDATE ... session_status = 'ARRIVAL_PENDING'`을 실행한다. 즉 이미 `SEATED`/`CANCELLED`/`COMPLETED` 상태인 세션도 그대로 `ARRIVAL_PENDING`으로 되돌려버릴 수 있다. `call_waiting_customer()`(`0160`이 이미 수정)는 `session_status not in ('WAITING','ARRIVAL_PENDING')`을 명시적으로 검사하는데, `confirm_arrival()`에는 이 가드가 원래부터 없었다. §1.5에서 이 결함이 자연스럽게 해소되는 설계를 제시한다(범위 확장이 아니라, 이미 존재하는 canonical core에 위임하는 것의 부수 효과).

### §1.2 `get_waiting_status()` (`0115:1466-1579`)

**Phantom 컬럼 참조:**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1490-1497 | SELECT | `pre_order_amount`, `table_number`, `called_at`, `arrival_confirmed_at` (4개) |
| 1536, 1540-1542 | 응답 payload | `table_number`, `pre_order_amount` |
| 1546, 1548 | 응답 `timestamps` payload | `called_at`, `arrival_confirmed_at` |

같은 SELECT가 `queue_position`(1492)과 `seated_at`(1497)도 함께 읽는데, 이 둘은 **실컬럼**이다 — 다만 `queue_position`은 읽고도 이후 전혀 쓰이지 않는 죽은 필드다(대신 라인 1515-1523의 별도 카운트 쿼리로 계산한 지역변수 `v_queue_position`을 응답에 사용). phantom 컬럼 수정과 무관한 사소한 정리 대상으로만 기록한다(§1.5에서 죽은 SELECT 항목 제거 여부 결정).

**그 외 로직(정상, 보존 대상):** `STABLE`(읽기 전용), 세션 존재 확인 후 "내 앞 대기 인원"(`wait_number` 비교 카운트)과 예상 대기시간(10분/인 고정 계수) 계산, `catchmenu_common.get_message()`를 통한 다국어 상태 메시지 조립.

### §1.3 `get_waiting_admin_view()` (`0115:1582-1729`)

**Phantom 컬럼 참조 (기존에 알려진 4개보다 1개 더 많다 — `memo`가 오늘 라이브 재확인에서 추가로 발견됨):**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1616 | jsonb_build_object | `os.table_number` |
| 1618, 1620, 1680-1685 | jsonb_build_object + 통계 집계 | `os.pre_order_amount` / `pre_order_amount` |
| 1626 | jsonb_build_object | `os.called_at` |
| 1627 | jsonb_build_object | `os.call_count` |
| **1628** | jsonb_build_object | **`os.memo`** — 이번 재확인에서 처음 특정됨. `600651_Overview.md`가 나열한 4종(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`)에 없던 5번째 phantom 컬럼 |

**`memo`는 §1.6에서 별도로 다룬다** — 나머지 4종과 달리 대체할 실컬럼이나 파생 가능한 소스가 전혀 없다(스키마 신설이 필요할 수 있는 유일한 케이스).

**그 외 로직(정상, 보존 대상):** `STABLE`(읽기 전용), 오늘 영업일 `WAITING`/`ARRIVAL_PENDING` 세션 목록을 `queue_position asc nulls last, wait_number asc`로 정렬해 배열로 조립, 상태별 `actions`(CALL/SEAT/NO_SHOW/CANCEL) 힌트 배열 생성, 오늘 통계(등록/완료/취소/노쇼/사전주문 건수·금액/외국인 비율/평균 대기시간) 별도 집계.

**phantom 컬럼과 무관하게 발견된 이상 항목**: 응답 payload에 `'patent_note', jsonb_build_object('patent1', 'Full journey tracked per session', 'patent2', 'Pre-order KDS HOLD until payment', ...)`가 하드코딩되어 있다(라인 1716-1723). 대기열 관리 API 응답에 특허 관련 문구를 담아 보내는 것은 이 워크패킷의 phantom 컬럼 교정과는 무관한 별개 사안이므로, §6 Open Item으로만 기록하고 이 문서에서 제거 여부를 판단하지 않는다.

### §1.4 `cancel_waiting()` (`0115:1207-1330`)

**Phantom 컬럼 참조 (2개, 가장 적음):**

| 라인 | 종류 | 컬럼 |
|---|---|---|
| 1235-1236 | SELECT | `pre_order_amount` |
| **1259** | **UPDATE (쓰기)** | **`cancel_reason`** |

**그 외 로직(정상, 보존 대상):** `session_status → 'CANCELLED'`, `cancelled_at = now()`(실컬럼, 정상), 사전주문이 있으면 연결된 `catchmenu_kds.kds_tickets`(HOLD 상태)를 `CANCELLED`로 함께 전이, `notify_channel()`, 렛저 이벤트(`waiting`/`waiting_cancelled`) — `cancel_reason` 값은 이미 렛저 `event_payload`에도 담기고 있다(1307, 1322)는 점이 §1.7의 수정 설계에서 근거가 된다.

**phantom 컬럼과 무관하게 발견된 결함**: `confirm_arrival()`과 마찬가지로 `session_status`에 대한 사전 가드가 없다 — 이미 `SEATED`(테이블 점유 중)인 세션도 그대로 `CANCELLED`로 전이시킬 수 있는데, 이 경우 `dining_tables.table_status`를 `AVAILABLE`로 되돌리는 로직이 이 함수는 물론 코드베이스 전체 어디에도 없다(`table_status = 'AVAILABLE'`을 UPDATE SET 대상으로 쓰는 함수를 전수 검색한 결과 0건, §1.7에서 스코프 제외 근거로 재인용). `confirm_arrival()`과 달리 위임할 수 있는 canonical core(`bind_table_to_session()`에 대응하는 "테이블 반납/세션 취소" 함수)가 존재하지 않아, 이 결함은 이번 워크패킷의 위임 패턴으로 자동 해소되지 않는다 — §6 Open Item으로 명시적으로 남긴다.

### §1.5 `confirm_arrival()`의 위임 대상 — `catchmenu_pos.mark_session_arrived()` (신규 발견, `0025_create_session_rpc.sql:232-324`)

`seat_waiting_customer()`가 `bind_table_to_session()`에 위임하는 것과 정확히 같은 구조의 canonical core 함수가 이미 존재한다. 라이브 `pg_get_functiondef()`로 전문을 재확인했다:

```sql
-- 0025:264-278 (핵심부)
if v_session.session_status not in ('WAITING', 'ARRIVAL_PENDING') then
  return jsonb_build_object(
    'success', false, 'error_key', 'invalid_session_status',
    'current_status', v_session.session_status
  );
end if;

update catchmenu_pos.order_sessions
set
  session_status = 'ARRIVAL_PENDING',
  arrived_at = now(),          -- 실컬럼. confirm_arrival()의 phantom arrival_confirmed_at이 원래 의도했을 대상
  updated_at = now()
where id = p_session_id;
-- + session_events('customer_arrived') 삽입, ledger.events('session'/'customer_arrived') 삽입
-- + return jsonb_build_object('success', true, 'session_id', ..., 'session_status', 'ARRIVAL_PENDING', 'arrived_at', now())
```

라이브 확인 결과:
- `chk_session_seated_after_arrived` 제약(`CHECK (seated_at IS NULL OR arrived_at IS NULL OR seated_at >= arrived_at)`)이 `arrived_at`을 "착석 이전에 채워지는 시각"으로 스키마 레벨에서 이미 규정하고 있다 — `confirm_arrival()`이 원래 쓰려던 `arrival_confirmed_at`의 정확한 실질적 대응물이다.
- `proacl`은 `{postgres=X/postgres, authenticated=X/postgres}` — 이미 `authenticated`에게 GRANT되어 있다.
- 이 함수를 호출하는 곳은 SQL 마이그레이션 전체에 0건이다(`grep -rn mark_session_arrived sql/migrations` 결과 정의·GRANT/REVOKE 줄만 매치) — `bind_table_to_session()`이 `0163` 이전까지 고아 상태였던 것과 동일한 상황.
- 자체 `EXCEPTION` 핸들러 없음(단순 `begin...end` 블록) — `bind_table_to_session()`과 동일한 특성. 즉 `600652_Logic.md` §9.2가 확인한 "호출자의 EXCEPTION 핸들러가 잡으면 이 함수의 변경도 함께 롤백된다"는 원자성 성질이 여기도 그대로 적용된다.

**결론**: `confirm_arrival()`을 `seat_waiting_customer()`와 같은 얇은 파사드로 다시 짜서 `mark_session_arrived()`에 위임하면, phantom 컬럼 문제와 §1.1이 발견한 "상태 가드 없음" 문제가 **동시에** 해소된다 — `mark_session_arrived()`가 이미 `session_status not in ('WAITING','ARRIVAL_PENDING')` 가드를 갖고 있기 때문이다. 이것은 범위 확장이 아니라, `bind_table_to_session()`을 쓸 때와 정확히 같은 이유(이미 존재하는, 더 엄격하고 올바른 core를 그대로 재사용)로 자연스럽게 딸려오는 개선이다.

### §1.6 `called_at`/`arrival_confirmed_at` — 두 컬럼 모두 phantom, 대체 방법 확인 (작업 지시 항목 3)

- **`arrival_confirmed_at`**: phantom. 실컬럼 `arrived_at`으로 직접 대체(파생·JOIN 불필요 — §1.5).
- **`called_at`**: phantom. 그러나 **`0160`이 이미 확립한 파생 패턴**이 정확히 이 정보를 담고 있다: `_record_waiting_call()`(`0160_call_waiting_customer_contract_recovery.sql:37` 함수 정의 시작, `73-88`에서 `catchmenu_pos.session_events`에 `event_type='customer_called'` 행을 `occurred_at=now()`로 삽입)이 매 호출 시 이 행을 삽입하고, 같은 함수의 `92-95`줄이 `select count(*) from session_events where session_id=... and event_type='customer_called'`로 `call_count`(§1.3의 4번째 phantom 컬럼)를 파생시키는 것을 이미 라이브로 확인했다(`600653_TestPlan.md`류 검증 대상은 아니었지만 이번 재확인으로 직접 읽음 — 최초 인용 시 `11-38`/`41-43`으로 잘못 기재했던 것을 Stage 4 검증에서 지적받아 재확인 후 정정). 즉:
  - `called_at` := `select max(occurred_at) from session_events where session_id=<id> and event_type='customer_called'` (재호출 지원 — `call_waiting_customer()`가 여러 번 호출될 수 있으므로 마지막 호출 시각)
  - `call_count` := `select count(*) from session_events where session_id=<id> and event_type='customer_called'` — `_record_waiting_call()` 92-95줄과 동일한 표현식, 새로 발명하지 않고 그대로 재사용

이 두 값은 하나의 `LEFT JOIN LATERAL` 서브쿼리로 한 번에 계산 가능하다(Logic.md §C에서 확정).

### §1.7 `cancel_reason` — 대체 컬럼 없음, 별도 패턴 필요

나머지 phantom 컬럼(`pre_order_amount`/`table_number`/`called_at`/`arrival_confirmed_at`)은 전부 "실컬럼 또는 파생 가능한 소스가 존재"하는 케이스인 반면, `cancel_reason`은 `order_sessions`에도, 다른 어떤 테이블에도 대응하는 컬럼이 없다. 다만 라이브 재확인 결과 `cancel_waiting()`은 이미 `p_cancel_reason` 값을 `catchmenu_ledger.events.event_payload`(1307)와 `notify_channel()` payload(1285)에 담아 보내고 있다 — 즉 **취소 사유 정보 자체는 이미 유실 없이 렛저에 영구 보존된다.** 세션 행 자체에 중복 저장하지 않는 것은 정보 손실이 아니라 단순 중복 제거다. Logic.md §D에서 "phantom 쓰기를 삭제하고 렛저를 단일 진실 소스로 삼는다"는 세 번째 패턴으로 확정한다.

## §2 admin_list 패턴 일관성 검토 (작업 지시 항목 4)

기존 admin_list류 3개 함수의 응답 형태를 라이브로 대조했다:

| 함수 | 응답 형태 | 비고 |
|---|---|---|
| `catchmenu_store.get_staff_admin_list()` | `catchmenu_common.build_success_response()` + `message_catalog` | |
| `catchmenu_pos.get_waiting_admin_view()` | `catchmenu_common.build_success_response()` + `message_catalog` | **이미 이 패턴을 따르고 있음** |
| `catchmenu_store.get_dining_table_admin_list()`(`601120`, 이번 세션에 신설) | 원시 `jsonb_build_object('success', true, 'data', {...}, 'message_code', ...)` | 3개 중 유일하게 `build_success_response()`를 쓰지 않는 예외 |

**결론**: `get_waiting_admin_view()`는 이미 더 오래되고 더 널리 쓰이는 다수 패턴(`build_success_response()`)을 따르고 있다 — 오히려 `601120`의 `get_dining_table_admin_list()` 쪽이 소수/예외 사례다. 따라서 이 워크패킷에서 `get_waiting_admin_view()`의 응답 형태(shape) 자체를 바꿀 필요는 없다 — phantom 컬럼만 교정하면 기존 형태를 그대로 유지할 수 있다. (`601120`의 불일치는 이 워크패킷의 범위가 아니므로 손대지 않는다 — §6 Open Item으로만 기록.)

## §3 워크패킷 분리 여부 판단 (작업 지시 항목 5)

"같은 클래스(phantom 컬럼 치환)면 묶고, 다른 개념이 섞이면 쪼갠다" 원칙 적용:

**같은 워크패킷으로 묶는 근거:**
1. 4개 함수 모두 **동일한 단일 원인**(`0115` 원저작 시점에 실제 스키마와 다른 컬럼명을 가정)에서 비롯된 결함이고, 수정 패턴은 이미 `0160`/`0163`이 확립한 두 가지(orders LEFT JOIN, payload-only) + 이 문서 §1.6/§1.7이 새로 확정한 두 가지(session_events 파생, 렛저-단일-진실-소스)의 조합일 뿐 — 함수마다 처음부터 설계를 새로 하는 게 아니라 기존 패턴을 적용하는 작업이다.
2. `confirm_arrival()`을 제외한 나머지 3개(`get_waiting_status`/`get_waiting_admin_view`/`cancel_waiting`)는 위임 대상 core 함수를 새로 설계할 필요가 없는, 상대적으로 소규모인 SELECT/UPDATE 컬럼 치환이다.
3. `601120_dining_table_crud_creation`이 이미 "성격이 다른 3개 함수(upsert/activate/list)를 하나의 워크패킷으로 묶는" 직접 선례다 — 그 경우도 "다이닝 테이블 CRUD"라는 하나의 일관된 주제 아래 여러 함수를 함께 설계했다.
4. `0160`/`0163`이 각각 별도 워크패킷이었던 것은 "같은 클래스라서 쪼갠 것"이 아니라, 서로 다른 시점에 순차적으로 발견·착수되었기 때문이다(설계 원칙에 따른 의도적 분리가 아님) — 지금은 4개를 동시에 파악한 시점이므로 순차적 발견이라는 분리 사유 자체가 없다.

**다만 완전히 균일하지는 않다** — `confirm_arrival()`만 "파사드 신설 + canonical core 위임"이라는 `0163`과 동형의 설계가 필요하고, 나머지 3개는 위임 없는 단순 컬럼 치환이다. 이 차이는 워크패킷을 쪼갤 정도는 아니지만(모두 "phantom 컬럼 치환"이라는 상위 클래스에 속함), Logic.md 내부에서 **Slice A(confirm_arrival, 위임형) / Slice B(get_waiting_status, 읽기형) / Slice C(get_waiting_admin_view, 읽기형 + memo 결정) / Slice D(cancel_waiting, 쓰기형 + 스코프 제외)**로 명확히 나눠 기술한다 — `601142_Logic.md`가 이미 이 세션에서 Slice 1/Slice 2로 같은 워크패킷 내부를 나눈 선례를 따른다.

**결론: 4개 함수를 `600660_waiting_pipeline_sibling_functions_correction` 하나의 워크패킷으로 묶는다.**

## §4 이번 워크패킷에서 명시적으로 제외하는 항목 (스코프 밖)

1. **`cancel_waiting()`의 상태 가드 부재 + 테이블 반납 로직 부재** (§1.4) — `dining_tables.table_status`를 `AVAILABLE`로 되돌리는 함수가 코드베이스 전체에 0건이라는, 이 워크패킷보다 훨씬 넓은 범위의 시스템 갭이다. 별도 워크패킷 후보(가칭 `cancel_waiting_state_guard_and_table_release`)로 이관.
2. **`get_waiting_admin_view()`의 `patent_note` 하드코딩 문구** (§1.3) — phantom 컬럼과 무관.
3. **`get_dining_table_admin_list()`(`601120`)의 응답 형태 불일치** (§2) — 이 워크패킷의 대상 함수가 아니다.
4. **`get_waiting_admin_view()`의 `memo` phantom 컬럼** (§1.3, §1.6) — 대체 실컬럼이나 파생 소스가 전혀 없어 스키마 신설이 필요할 수 있는 유일한 케이스. 이 워크패킷의 "기존 실컬럼/파생으로 치환" 패턴 범위를 벗어나므로, Logic.md §C에서 "필드를 임시로 제거"와 "새 컬럼 추가(별도 스코프)" 두 옵션을 제시하고 하나를 확정하되, 후자를 선택하더라도 실제 스키마 변경(.sql)은 이번 워크패킷에서 수행하지 않는다.
5. Flutter/클라이언트 통합 — 4개 함수 모두 현재 호출자 0건이므로 범위 밖(작업 지시 명시).

## §5 영향 요약

| 함수 | phantom 컬럼 수 | 수정 패턴 | 위임 대상 |
|---|---|---|---|
| `confirm_arrival()` | 2 read + 1 write | 파사드화 | `mark_session_arrived()` (`0025`, 미변경) |
| `get_waiting_status()` | 4 read | orders LEFT JOIN + dining_tables LEFT JOIN + session_events 파생 | 없음(단일 함수 내 수정) |
| `get_waiting_admin_view()` | 5 read (`memo` 포함) | 동상 + `memo` 별도 결정 | 없음 |
| `cancel_waiting()` | 1 read + 1 write | orders LEFT JOIN + phantom 쓰기 삭제(렛저가 단일 진실 소스) | 없음 |

신규 `error_codes`/`message_catalog` 항목: **잠정 0건**(phantom 컬럼 치환 자체만 놓고 보면 4개 함수 모두 기존에 등록된 `waiting_session_not_found`만 재사용하거나, `mark_session_arrived()`의 미등록 flat key를 `0163` §2.1과 동일하게 재래핑 없이 그대로 통과시킨다). **단, `600662_Logic.md` §0.1이 Slice A(`confirm_arrival`)/Slice D(`cancel_waiting`)에 신규 `EXCEPTION` 핸들러를 추가하기로 결정하면서 신규 키가 2건(`waiting_confirm_arrival_failed`/`waiting_cancel_operation_failed`) 필요해졌다 — 이 문서 작성 시점의 전망이 Logic 설계 단계에서 정정된 것이며, `600662_Logic.md` §E가 최신·확정 값이다.** 그래도 `0163`(5개 신규 키)보다는 가벼운 워크패킷이다.

## §6 Open Items

(a) `cancel_waiting()` 상태 가드 부재 + 테이블 반납 로직 부재 — 별도 워크패킷 후보 (§4-1).
(b) `get_waiting_admin_view()`의 `patent_note` 하드코딩 — 별도 사안 (§4-2).
(c) `get_dining_table_admin_list()`(`601120`) 응답 형태 불일치 — 이 워크패킷 범위 밖 (§4-3).
(d) `get_waiting_admin_view()`의 `memo` — 실컬럼/파생 소스 없음, Logic.md §C에서 임시 제거 vs 신규 컬럼 중 결정 (§4-4).
(e) `get_waiting_status()`의 죽은 `queue_position` SELECT 항목 — phantom은 아니지만 정리 대상 여부 결정 필요 (§1.2).
(f) `_record_waiting_call()`의 `proacl` 공백 — `600652_Logic.md` §8 Open Item (d), 이 워크패킷도 손대지 않음(범위 밖 원칙 동일 적용).
(g) 이 4개 함수 모두 원본에 `EXCEPTION` 핸들러가 없다 — `0160`/`0163`이 신규로 확립한 "raise 대신 build_error_response 반환" 패턴을 추가할지 여부, Logic.md에서 함수별로 결정.

## Module Domain Tags

`waiting-pipeline`, `order-session`, `phantom-column-correction`, `facade-delegation`, `admin-view`, `session-events-derivation`

## Snapshot Decision

이 문서는 `confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()` 4개 함수를 `600660_waiting_pipeline_sibling_functions_correction` 하나의 워크패킷으로 묶기로 결정했다(§3) — `0160`/`0163`이 확립한 2가지 패턴에 더해, `called_at`/`call_count`를 `session_events`에서 파생시키는 패턴(§1.6)과 `cancel_reason`을 렛저 전용으로 남기는 패턴(§1.7)을 새로 확정했고, `confirm_arrival()`은 기존에 고아 상태였던 `mark_session_arrived()`(`0025`)에 위임하는 파사드로 재설계하기로 했다(§1.5). `memo`(§1.3, §1.6)는 대체 소스가 없는 유일한 예외로 남아 Logic.md에서 별도 결정이 필요하다. `cancel_waiting()`의 상태 가드/테이블 반납 갭(§1.4)은 이번 워크패킷보다 넓은 시스템 갭으로 판단해 명시적으로 제외했다(§4-1).


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md] =====
# 600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 2 (Claude Code design draft, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Domain: Waiting / Order Session
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0 설계 원칙 요약

`600661_Overview.md` §1-§3의 재확인 결과를 그대로 적용한다. 4개 함수를 아래 4개 Slice로 나눠 설계한다(`601142_Logic.md`의 Slice 1/Slice 2 선례):

- **Slice A** — `confirm_arrival()`: 파사드화, `catchmenu_pos.mark_session_arrived()`(`0025`, 미변경)에 위임.
- **Slice B** — `get_waiting_status()`: 읽기 전용, LEFT JOIN 3종 + `session_events` 파생.
- **Slice C** — `get_waiting_admin_view()`: Slice B와 동일 패턴 + `memo` 필드 제거 결정.
- **Slice D** — `cancel_waiting()`: orders LEFT JOIN + phantom 쓰기(`cancel_reason`) 삭제, 렛저를 단일 진실 소스로 확정.

공통으로 적용하는 두 가지 교정:
1. **`has_pre_order` 판정 기준 통일**: 원본 4개 함수 모두 `pre_order_amount > 0`(phantom 컬럼 자체 값)로 판정했는데, `orders` LEFT JOIN 이후에는 사전주문이 없으면 `o.final_amount`가 `0`이 아니라 `NULL`이 된다 — `0`이 될 수도 있는 실제 케이스(무료 프로모션 등)와 구분되지 않는 문제도 있다. `0160`/`0163`이 이미 쓰는 `os.pre_order_created_at is not null` 기준으로 4개 함수 전부 통일한다.
2. **`EXCEPTION` 핸들러 추가 여부는 함수별로 결정**(§0.1) — 원본 4개는 전부 핸들러가 없었다.

### §0.1 `EXCEPTION` 핸들러 결정

| 함수 | 결정 | 근거 |
|---|---|---|
| Slice A `confirm_arrival()` | **추가** | `mark_session_arrived()`에 위임하는 새 파사드 — `seat_waiting_customer()`/`bind_table_to_session()`과 동일한 위험(위임 성공 후 파사드 자신의 코드에서 실패하면 원시 Postgres 에러가 클라이언트로 샐 수 있고, `600652_Logic.md` §9.2가 증명한 전체 원자성 때문에 위임된 core의 작업까지 조용히 롤백된다 — 최소한 실패 감사 기록은 남겨야 한다) |
| Slice B `get_waiting_status()` | **추가 안 함** | `STABLE`, 부수효과 없는 단순 조회 — 실패해도 롤백할 상태가 없고, 원본에도 없었다. 없어도 원시 에러가 새는 것 자체는 동일 리스크지만, 이 워크패킷의 핵심 목표(phantom 컬럼 교정)와 무관한 범위 확장으로 판단해 보류 |
| Slice C `get_waiting_admin_view()` | **추가 안 함** | Slice B와 동일 근거 |
| Slice D `cancel_waiting()` | **추가** | 상태 전이 + 조건부 KDS 티켓 UPDATE + 알림 + 렛저까지 여러 단계의 쓰기가 있는 함수 — `confirm_arrival()`과 동일한 근거 |

**결과: `error_codes`/`message_catalog`에 신규 키 2개가 필요하다** — `600661_Overview.md` §5의 "신규 키 0건 예상"은 이 Logic 설계 단계에서 §0.1 결정에 따라 2건으로 정정한다(§E).

## §A Slice A — `confirm_arrival()` 파사드 재작성

### §A.1 위임 대상 재확인 (인용, `600661_Overview.md` §1.5 근거)

`catchmenu_pos.mark_session_arrived(p_tenant_id, p_store_id, p_session_id, p_correlation_id)` — `0025:232-324`, 미변경. 반환 형태는 원시 flat JSON(`build_success_response`/`build_error_response` 아님): 성공 시 `{'success':true,'session_id':...,'session_status':'ARRIVAL_PENDING','arrived_at':...}`, 실패 시 `{'success':false,'error_key':'session_not_found'}` 또는 `{'success':false,'error_key':'invalid_session_status','current_status':...}`.

### §A.2 실패 키 도달 가능성 분석 (`0163` §7과 동일 형식)

| `error_key` | 이 파사드를 통해 도달 가능? | 근거 |
|---|---|---|
| `session_not_found` | **아니오** | 파사드 자신의 §A.3 1단계가 이미 같은 `p_session_id`/`p_store_id`/`p_tenant_id`로 조회하고 `for update of os`로 잠근 뒤에만 위임한다 — 위임 시점에 행이 사라질 수 없다 |
| `invalid_session_status` | **예** | 파사드가 자체적으로 `session_status`를 사전 검사하지 않고 그대로 위임하므로(§A.3 설계 결정), `WAITING`/`ARRIVAL_PENDING`이 아닌 모든 상태(`SEATED`/`CANCELLED`/`COMPLETED`/`NO_SHOW` 등)에서 이 키로 실패한다 |

`session_not_found`가 구조적으로 도달 불가능하다는 것이 이 표 자체가 근거다(`0163` §7과 동일하게, 라이브 재현이 아니라 도달가능성 증명으로 TestPlan 커버리지를 대신한다 — 다음 Stage의 TestPlan에서 재확인).

**설계 결정**: 파사드는 `waiting_already_seated`처럼 더 친절한 별도 에러로 특정 상태를 가로채지 않는다. 원본 `confirm_arrival()`에는애초에 그런 세분화된 에러가 없었고(`600661_Overview.md` §1.1 — 상태 가드 자체가 없었다), 현재 호출자가 0건이므로 과설계할 이유가 없다. `invalid_session_status`를 `0163` §2.1과 동일하게 **재래핑 없이 그대로 반환**한다 — `mark_session_arrived()`의 `error_key`가 `error_codes`에 등록되어 있지 않으므로 `build_error_response()`로 감쌌다면 `600652_Logic.md` §2.1이 실증한 것과 같은 `log_diagnostic()` 크래시가 재발했을 것이다.

### §A.3 전체 함수

**(Stage 4 검증에서 명시 요구)** 이 파사드 호출 1회의 총 이벤트 발자국(event footprint): 위임이 성공하면 `mark_session_arrived()`(`0025:281-295`, `297-315`, 미변경)가 자신의 내부에서 **`session_events` 1건**(`event_type='customer_arrived'`)과 **`catchmenu_ledger.events` 1건**(`event_domain='session'`, `event_type='customer_arrived'`)을 이미 생성한다. 그 위에 파사드 자신이 아래 4단계에서 **`catchmenu_ledger.events` 1건을 추가로**(`event_domain='waiting'`, `event_type='arrival_confirmed'`) 생성한다. 즉 **`confirm_arrival()` 호출 1회 = `session_events` 1건 + `catchmenu_ledger.events` 2건**(`session`/`customer_arrived` + `waiting`/`arrival_confirmed`) — `0163`의 `seat_waiting_customer()`가 `bind_table_to_session()` 위임으로 만드는 "렛저 이벤트 2건, 의도적" 패턴(§A.3 4단계 주석, `0163 §3`)과 정확히 동형이며, 이 문서 §G에 다음 TestPlan의 acceptance criterion으로 포함하도록 명시해 둔다.

```sql
create or replace function catchmenu_pos.confirm_arrival(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_arrival_result jsonb;
begin
  -- 1. 세션 조회 (사전주문 금액은 0160/0163과 동일한 orders LEFT JOIN 패턴)
  select os.id, os.wait_number, os.session_status,
         os.pre_order_created_at, os.order_id,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival'
    );
  end if;

  -- 2. 상태 전이 + arrived_at 기록을 canonical core에 위임 (§A.1/§A.2)
  v_arrival_result := catchmenu_pos.mark_session_arrived(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_session_id := p_session_id,
    p_correlation_id := p_correlation_id
  );

  if not coalesce((v_arrival_result->>'success')::boolean, false) then
    -- mark_session_arrived()의 원시 flat JSON을 그대로 반환 (§A.2 설계 결정,
    -- 0163 §2.1과 동일 이유 — 미등록 error_key 재래핑 크래시 회피)
    return v_arrival_result;
  end if;

  -- 3. 대기열 도메인 고유 부수효과 (원본 로직 보존)
  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_arrival_confirmed',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount
    )
  );

  -- 4. 파사드 자신의 렛저 이벤트 — mark_session_arrived()의 'session'/'customer_arrived'와
  --    별개로 유지 (0163 §3과 동일한 "두 렛저 이벤트, 의도적" 설계 — event_domain='waiting'은
  --    register_waiting/waiting_cancelled/customer_seated와 같은 버킷에 속해야 조회 일관성이 있다).
  --    from_state는 원본의 하드코딩된 'WAITING' 대신 v_session.session_status를 동적으로 사용한다
  --    (원본 결함 수정 — ARRIVAL_PENDING 세션의 재확인 호출에서도 정확한 from_state가 남는다).
  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'arrival_confirmed', 1,
    'order_session', p_session_id,
    v_session.session_status, 'ARRIVAL_PENDING',
    'CUSTOMER', p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    (timezone('Asia/Seoul', now()))::date, 'Asia/Seoul', now()
  );

  -- 5. 응답 — table_number 필드는 삭제 (ARRIVAL_PENDING 단계에서는 아직 테이블이
  --    배정되지 않아 원본에서도 항상 null이었던 무의미한 필드, 호출자 0건이므로
  --    호환성 부담 없이 정리)
  return catchmenu_common.build_success_response(
    p_message_key := 'arrival_confirmed',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'next_step', case
        when v_session.pre_order_created_at is not null
          then 'PROCEED_TO_PAYMENT'
        else 'WAIT_FOR_SEATING'
      end
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session', -- 'waiting'은 chk_audit_domain에 없음 (600652_Logic.md §1.5 근거 재적용)
      p_audit_type := 'confirm_arrival_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := 'CUSTOMER',
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_confirm_arrival_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'confirm_arrival',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

GRANT/REVOKE: 시그니처 불변(`0115`와 동일 파라미터 목록) — 기존 GRANT(`0115:1751-1754`, `authenticated`) 그대로 유지, 신규 GRANT 문 불필요.

## §B Slice B — `get_waiting_status()` 읽기 교정

### §B.1 설계

- `pre_order_amount` → `orders.final_amount` LEFT JOIN.
- `table_number` → `dining_tables.table_code` LEFT JOIN (`os.table_id`가 `null`이면 자연히 `null` — 착석 전에는 원본도 항상 `null`이었으므로 동작 동일).
- `called_at` → `session_events`에서 `event_type='customer_called'`의 최신 `occurred_at`(`600661_Overview.md` §1.6, `_record_waiting_call()`의 기존 파생 로직 재사용).
- `arrival_confirmed_at` → 실컬럼 `os.arrived_at`으로 직접 대체(파생 불필요).
- 죽은 `queue_position` SELECT 항목 삭제(`600661_Overview.md` §6 Open Item (e) 해소 — 실제로 쓰이는 것은 별도 카운트 쿼리로 계산되는 지역변수뿐이었다).

### §B.2 전체 함수

```sql
create or replace function catchmenu_pos.get_waiting_status(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_session record;
  v_queue_position int;
  v_est_wait_minutes int;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.session_type, os.guest_count, os.guest_locale,
         os.pre_order_created_at,
         o.final_amount as pre_order_amount,
         dt.table_code as table_number,
         os.session_started_at,
         call_info.called_at,
         os.arrived_at,
         os.seated_at
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'get_waiting_status'
    );
  end if;

  select count(*) into v_queue_position
  from catchmenu_pos.order_sessions
  where store_id = p_store_id
    and tenant_id = p_tenant_id
    and business_day = v_business_day
    and session_status in ('WAITING', 'ARRIVAL_PENDING')
    and wait_number < v_session.wait_number;

  v_est_wait_minutes := v_queue_position * 10;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'session_status', v_session.session_status,
      'session_type', v_session.session_type,
      'guest_count', v_session.guest_count,
      'table_number', v_session.table_number,
      'queue_position', v_queue_position,
      'est_wait_minutes', v_est_wait_minutes,
      'has_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_amount', v_session.pre_order_amount,
      'timestamps', jsonb_build_object(
        'registered_at', v_session.session_started_at,
        'called_at', v_session.called_at,
        'arrival_at', v_session.arrived_at,
        'seated_at', v_session.seated_at
      ),
      'status_messages', jsonb_build_object(
        'position', catchmenu_common.get_message(
          'waiting_current_position',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('position', v_queue_position)
        ),
        'est_time', catchmenu_common.get_message(
          'waiting_est_time',
          coalesce(p_locale, v_session.guest_locale),
          jsonb_build_object('minutes', v_est_wait_minutes)
        )
      )
    ),
    p_locale := p_locale
  );
end;
$$;
```

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §C Slice C — `get_waiting_admin_view()` 읽기 교정 + `memo` 결정

### §C.1 `memo` 결정 (`600661_Overview.md` §4-4/§6 Open Item (d) 확정)

`memo`는 `order_sessions`에도 다른 어떤 테이블에도 대응하는 실컬럼이나 파생 가능한 소스가 없다. 두 옵션:

- **(옵션 1) 필드를 응답에서 제거** — 이 워크패킷의 범위("기존 실컬럼/파생 소스로 phantom을 치환")를 지키고, 스키마 변경 없이 크래시만 없앤다.
- **(옵션 2) `order_sessions.memo text` 컬럼 신설** — 직원이 대기 손님에 대해 메모(알레르기, VIP 등)를 남기는 기능이 실제로 필요하다면 정당한 요구지만, 새 컬럼 추가는 `.sql` 작성이 필요한 별도 스키마 변경 워크패킷이다(이번 턴은 `.sql` 생성/수정 금지).

**결정: 옵션 1(제거)을 채택한다.** 이 워크패킷은 "phantom 컬럼을 이미 존재하는 것으로 치환"하는 것이 목적이며, 새 기능(직원 메모)을 설계하는 것은 다른 종류의 작업이다(`600661_Overview.md` §3의 "다른 개념이 섞이면 쪼갠다" 원칙과 동일 논리로, 이 필드 하나만 별도 워크패킷 후보로 이관한다 — 가칭 `waiting_session_staff_memo_feature`). 메모 기능이 실제로 필요하다고 확인되면 그때 별도 Overview에서 컬럼 신설부터 다시 설계한다.

### §C.2 전체 함수

```sql
create or replace function catchmenu_pos.get_waiting_admin_view(
  p_tenant_id uuid,
  p_store_id uuid,
  p_locale text default 'ko'
)
returns jsonb
language plpgsql
stable
security definer
set search_path = catchmenu_pos, catchmenu_store, catchmenu_common
as $$
declare
  v_business_day date;
  v_waiting_list jsonb;
  v_today_stats jsonb;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select coalesce(
    jsonb_agg(
      jsonb_build_object(
        'session_id', os.id,
        'wait_number', os.wait_number,
        'queue_position', os.queue_position,
        'session_status', os.session_status,
        'session_type', os.session_type,
        'guest_count', os.guest_count,
        'guest_locale', os.guest_locale,
        'table_number', dt.table_code,
        'has_pre_order', os.pre_order_created_at is not null,
        'pre_order_amount', o.final_amount,
        'waited_minutes', extract(epoch from (now() - os.session_started_at))::int / 60,
        'called_at', call_info.called_at,
        'call_count', coalesce(call_info.call_count, 0),
        'is_foreign', os.guest_locale <> 'ko',
        'actions', jsonb_build_array(
          case when os.session_status = 'WAITING' then 'CALL' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'SEAT' else null end,
          case when os.session_status in ('WAITING', 'ARRIVAL_PENDING') then 'NO_SHOW' else null end,
          'CANCEL'
        )
      )
      order by os.queue_position asc nulls last, os.wait_number asc
    ),
    '[]'::jsonb
  )
  into v_waiting_list
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  left join catchmenu_store.dining_tables dt on dt.id = os.table_id
  left join lateral (
    select count(*) as call_count, max(occurred_at) as called_at
    from catchmenu_pos.session_events se
    where se.session_id = os.id and se.event_type = 'customer_called'
  ) call_info on true
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day
    and os.session_status in ('WAITING', 'ARRIVAL_PENDING');

  select jsonb_build_object(
    'total_registered', count(*),
    'completed', count(*) filter (where os.session_status = 'COMPLETED'),
    'cancelled', count(*) filter (where os.session_status = 'CANCELLED'),
    'no_show', count(*) filter (where os.session_status = 'NO_SHOW'),
    'current_waiting', jsonb_array_length(v_waiting_list),
    'pre_order_count', count(*) filter (where os.pre_order_created_at is not null),
    'total_pre_order_amount', coalesce(
      sum(o.final_amount) filter (where os.pre_order_created_at is not null), 0
    ),
    'foreign_count', count(*) filter (where os.guest_locale <> 'ko'),
    'avg_wait_minutes', coalesce(
      avg(
        extract(epoch from (coalesce(os.seated_at, now()) - os.session_started_at)) / 60
      )::int, 0
    )
  )
  into v_today_stats
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
    and os.business_day = v_business_day;

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_status_loaded',
    p_data := jsonb_build_object(
      'store_id', p_store_id,
      'business_day', v_business_day,
      'current_waiting', jsonb_array_length(v_waiting_list),
      'waiting_list', v_waiting_list,
      'today_stats', v_today_stats,
      'loaded_at', now()
    ),
    p_locale := p_locale
  );
end;
$$;
```

**(Stage 4 검증에서 재분류)** `patent_note`(`600661_Overview.md` §1.3/§6 Open Item (b)) 제거는 이 Slice의 다른 모든 변경(phantom 컬럼 → 실컬럼/파생 치환)과 **같은 종류의 작업이 아니다** — phantom 컬럼 치환은 "크래시하던 것을 크래시하지 않게 만드는" 무결점 교정인 반면, `patent_note` 제거는 이미 정상 동작하던(크래시와 무관한) 응답 필드를 삭제하는 **응답 계약(response contract) 변경**이다. 이 워크패킷 위에서 설계 편의상 함께 처리하지만, 승인 근거는 서로 다르다 — §H에 별도 Open Item으로 명시하고, `600663_ChangeContract.md`(다음 Stage)의 Allowed Operations에도 phantom 컬럼 치환 항목과 분리된 별도 항목으로 기재해 Human이 이 부분만 따로도 판단할 수 있게 한다. 유지할 근거(클라이언트가 실제로 소비)가 없고 호출자 0건이라는 점은 여전히 유효하지만, "무해한 정리"로 뭉뚱그리지 않는다.

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §D Slice D — `cancel_waiting()` 쓰기 교정

### §D.1 `cancel_reason` 설계 (`600661_Overview.md` §1.7 확정)

`cancel_reason`은 대체 실컬럼이 없다. `p_cancel_reason`은 이미 렛저 이벤트(`event_payload.cancel_reason`)와 `notify_channel()` payload에 담겨 영구 보존되므로, `order_sessions.cancel_reason`에 대한 UPDATE SET 절 자체를 삭제한다 — 정보 손실이 아니라 중복 제거다.

**(Stage 4 검증에서 지적된 경계 케이스, §H (i)로도 기록)** §0의 `has_pre_order` 통일 기준(`os.pre_order_created_at is not null`)은 "사전주문이 있으면 `orders`/`kds_tickets` 행도 함께 존재한다"는 암묵적 가정에 기대고 있다. 그러나 `pre_order_created_at`을 세팅하는 쓰기 경로 중 하나인 `pre_order_while_waiting()`이 `600661_Overview.md`가 인용하는 `600651_Overview.md` §4.2에서 이미 "고장 상태이거나 죽은 코드일 가능성"으로 플래그된 바 있다 — 즉 `pre_order_created_at is not null`이지만 실제로는 대응하는 `orders`(또는 `orders`는 있지만 `kds_tickets`는 없는) 행이 없는 비정상 상태가 라이브 데이터에 이미 존재할 가능성을 배제할 수 없다. 이 경우 Slice D의 `update ... from catchmenu_pos.orders o where o.session_id = p_session_id ...`는 매칭되는 행이 없으면 단순히 0행 UPDATE로 끝나 크래시하지는 않을 것으로 판단되지만(`update ... from`은 매칭 실패 시 조용히 no-op), **이 판단 자체가 라이브 재현으로 검증된 적은 없다** — 다음 TestPlan에서 반드시 재현 테스트로 확인해야 한다(§G).

### §D.2 전체 함수

```sql
create or replace function catchmenu_pos.cancel_waiting(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_cancel_reason text default null,
  p_actor_type text default 'CUSTOMER',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_pos, catchmenu_kds, catchmenu_common, catchmenu_ledger
as $$
declare
  v_session record;
  v_business_day date;
begin
  v_business_day := (timezone('Asia/Seoul', now()))::date;

  select os.id, os.wait_number, os.session_status,
         os.guest_locale, os.pre_order_created_at,
         o.final_amount as pre_order_amount
  into v_session
  from catchmenu_pos.order_sessions os
  left join catchmenu_pos.orders o on o.id = os.order_id
  where os.id = p_session_id
    and os.store_id = p_store_id
    and os.tenant_id = p_tenant_id
  for update of os;

  if v_session.id is null then
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_session_not_found',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting'
    );
  end if;

  update catchmenu_pos.order_sessions
  set
    session_status = 'CANCELLED',
    cancelled_at = now(),
    updated_at = now()
  where id = p_session_id;

  if v_session.pre_order_created_at is not null then
    update catchmenu_kds.kds_tickets kt
    set
      kds_status = 'CANCELLED',
      cancelled_at = now(),
      updated_at = now()
    from catchmenu_pos.orders o
    where o.session_id = p_session_id
      and kt.order_id = o.id
      and kt.kds_status = 'HOLD';
  end if;

  perform catchmenu_common.notify_channel(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_channel_type := 'WAITING_QUEUE',
    p_event_type := 'waiting_session_cancelled',
    p_payload := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'cancelled_by', p_actor_type
    )
  );

  insert into catchmenu_ledger.events (
    tenant_id, store_id,
    event_domain, event_type, event_version,
    subject_type, subject_id,
    from_state, to_state,
    caused_by_type, caused_by_id,
    event_payload, correlation_id,
    business_day, business_timezone, occurred_at
  ) values (
    p_tenant_id, p_store_id,
    'waiting', 'waiting_cancelled', 1,
    'order_session', p_session_id,
    v_session.session_status, 'CANCELLED',
    p_actor_type, p_actor_id,
    jsonb_build_object(
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'had_pre_order', v_session.pre_order_created_at is not null,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_correlation_id,
    v_business_day, 'Asia/Seoul', now()
  );

  return catchmenu_common.build_success_response(
    p_message_key := 'waiting_cancelled',
    p_data := jsonb_build_object(
      'session_id', p_session_id,
      'wait_number', v_session.wait_number,
      'cancel_reason', p_cancel_reason,
      'pre_order_cancelled', v_session.pre_order_created_at is not null
    ),
    p_locale := p_locale,
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'session',
      p_audit_type := 'cancel_waiting_failed',
      p_audit_category := 'OPERATIONAL',
      p_actor_type := p_actor_type,
      p_actor_id := p_actor_id,
      p_subject_type := 'order_session',
      p_subject_id := p_session_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object(
        'error', sqlerrm,
        'sqlstate', sqlstate,
        'cancel_reason', p_cancel_reason
      )
    );
    return catchmenu_common.build_error_response(
      p_error_key := 'waiting_cancel_operation_failed',
      p_locale := p_locale,
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_rpc_name := 'cancel_waiting',
      p_details := jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**명시적으로 하지 않는 것** (`600661_Overview.md` §4-1, §1.4): `session_status`에 대한 사전 가드를 추가하지 않는다. 이미 `SEATED`인 세션도 여전히 `CANCELLED`로 전이될 수 있고, 테이블 반납 로직은 여전히 없다 — 이번 워크패킷은 phantom 컬럼만 교정하며, 이 갭은 별도 워크패킷(가칭 `cancel_waiting_state_guard_and_table_release`)으로 이관한다.

GRANT/REVOKE: 시그니처 불변, 기존 GRANT(`authenticated`) 유지.

## §E `message_catalog`/`error_codes` 신규 항목

`§0.1`의 결정에 따라 2개 신규 `error_key`가 필요하다. `error_domain := 'ORDER'`(`0163`과 동일 도메인 — 대기열/세션 관련 사용자 대면 에러가 이미 이 도메인에 모여 있다), 코드는 라이브 재확인 결과(`0163` 적용 이후 ORDER 도메인 상한 `7077`) 다음 값을 임시 배정한다 — **정확한 값은 `0163` §2.5/`600654_ChangeContract.md` §6 Stop Condition #2와 동일하게, Stage 8 직전 라이브 재확인 대상이며 이 문서가 고정하지 않는다.**

| 임시 code | error_key | error_category | http_status | 용도 |
|---|---|---|---|---|
| 7078 | `waiting_confirm_arrival_failed` | `TECHNICAL` | 500 | Slice A `EXCEPTION` 핸들러 |
| 7079 | `waiting_cancel_operation_failed` | `TECHNICAL` | 500 | Slice D `EXCEPTION` 핸들러 |

`message_catalog` (`ko`/`en` 각 1행, 총 4행):

```sql
insert into catchmenu_common.message_catalog (message_key, locale, message_text) values
  ('waiting_confirm_arrival_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_confirm_arrival_failed', 'en', 'A temporary error occurred. Please try again'),
  ('waiting_cancel_operation_failed', 'ko', '일시적인 오류가 발생했습니다. 잠시 후 다시 시도해주세요'),
  ('waiting_cancel_operation_failed', 'en', 'A temporary error occurred. Please try again')
on conflict (message_key, locale) do nothing;
```

## §F 마이그레이션 파일 배치 (Stage 8 대상, 이번 턴은 작성하지 않음)

파일명 잠정: `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`(`600661_Overview.md` 시점 기준 다음 번호 — Stage 8은 `select max(...)` 재확인 후 실제 번호 확정, `0163` §1.1과 동일 절차). `0163` §6.1이 확립한 문 순서를 그대로 따른다:

1. `message_catalog`/`error_codes` INSERT 블록 (§E) — 함수 정의보다 먼저.
2. `catchmenu_pos.confirm_arrival()` `CREATE OR REPLACE` (Slice A).
3. `catchmenu_pos.get_waiting_status()` `CREATE OR REPLACE` (Slice B).
4. `catchmenu_pos.get_waiting_admin_view()` `CREATE OR REPLACE` (Slice C).
5. `catchmenu_pos.cancel_waiting()` `CREATE OR REPLACE` (Slice D).
6. `GRANT`/`REVOKE` — 4개 함수 모두 시그니처 불변이므로 신규 GRANT문 자체는 불필요하지만, 헤더 주석에 "기존 GRANT 유지, 신규 GRANT 없음"을 명시해 Stage 8이 실수로 중복 GRANT를 추가하지 않도록 한다.

`0115` 원본 소스 텍스트는 수정하지 않는다(`CREATE OR REPLACE`로만 라이브 정의를 덮어씀 — `0160`/`0163`과 동일 기법). `mark_session_arrived()`(`0025`)는 이 파일에서 전혀 건드리지 않는다(위임만 함).

## §G TestPlan 영향 (다음 Stage 예고, 이번 턴 범위 아님)

다음 Stage(TestPlan/ChangeContract 작성)에서 `600653_TestPlan.md`와 동형의 구조로 4개 Slice 각각에 대해: 정상 동작(Slice A는 `mark_session_arrived()` 위임 성공 경로, Slice D는 사전주문 있는/없는 취소 양쪽), phantom 컬럼이 실제로 사라졌는지(크래시 없이 완주하는지가 1차 회귀 증거), Slice A의 `invalid_session_status` 도달가능성 재현(§A.2 표), Slice A/D의 `EXCEPTION` 원자성(`600653_TestPlan.md` §9와 동일한 임시 CHECK 제약 기법 재사용 가능), `0025`/`0115`(원본 텍스트)/`0160`/`0163`에 대한 0 diff 경계 확인이 필요할 것으로 예상한다.

**Stage 4 검증에서 명시 요구된 추가 acceptance criteria 2건 (다음 TestPlan에 반드시 포함):**

1. **Slice A 이벤트 개수 검증** — `confirm_arrival()` 정상 호출 1회 후 `session_events`에서 해당 `session_id`/`event_type='customer_arrived'` 행이 정확히 1건, `catchmenu_ledger.events`에서 해당 `subject_id`의 `event_type in ('customer_arrived','arrival_confirmed')` 행이 정확히 2건(`event_domain='session'`인 것 1건 + `event_domain='waiting'`인 것 1건)임을 직접 카운트로 확인 — §A.3의 이벤트 발자국 명시 사항 재확인.
2. **Slice D `has_pre_order` 경계 케이스** — `os.pre_order_created_at is not null`이지만 대응하는 `orders`/`kds_tickets` 행이 실제로는 없는(또는 `orders`는 있지만 `kds_tickets`가 없는) 비정상 상태에서 `cancel_waiting()`을 호출했을 때 크래시 없이 정상 완주하는지 확인 — §0/§D.1 Open Item.

## §H Open Items

(a) `cancel_waiting()` 상태 가드 + 테이블 반납 로직 부재 — 별도 워크패킷 후보 `cancel_waiting_state_guard_and_table_release` (`600661_Overview.md` §4-1, §D.2).
(b) `get_waiting_admin_view()`의 `patent_note` — 이 워크패킷에서 제거하기로 확정(§C.2)했지만, **phantom 컬럼 교정과는 무관한 별개의 응답 계약(response contract) 변경이므로 Human이 이 항목만 따로 명시 승인해야 한다.** 다음 Stage(`600663_TestPlan.md`/`600664_ChangeContract.md`) 작성 시 `600654_ChangeContract.md` 형식의 Allowed Operations 목록에서 phantom 컬럼 치환 항목들과 분리된 별도 줄로 기재할 것 — "무해한 정리"로 다른 phantom 교정 항목들과 뭉뚱그려 일괄 승인받지 않는다. 반론 시 되돌림.
(c) `get_dining_table_admin_list()`(`601120`) 응답 형태 불일치 — 범위 밖, 별도 사안.
(d) `memo` — 옵션 1(제거)로 확정(§C.1), 별도 기능 워크패킷 후보 `waiting_session_staff_memo_feature`.
(e) `get_waiting_status()`의 죽은 `queue_position` SELECT — 이 워크패킷에서 제거하기로 확정(§B.1/§B.2).
(f) `_record_waiting_call()`의 `proacl` 공백 — `600652_Logic.md` §8 Open Item (d), 이 워크패킷도 범위 밖.
(g) `error_codes` code 7078/7079는 임시값 — Stage 8 직전 라이브 재확인 필수(§E).
(h) Slice B/C에 `EXCEPTION` 핸들러를 추가하지 않기로 한 결정(§0.1)은 최종 확정이 아니라 이 Logic 단계의 판단이다 — Stage 6 검증에서 이견이 나오면 재논의 대상.
(i) **(Stage 4 검증에서 신규 추가)** `has_pre_order`(`pre_order_created_at is not null`) 판정 기준이 "사전주문이 있으면 `orders`/`kds_tickets` 행도 함께 존재한다"고 암묵적으로 가정한다 — `pre_order_while_waiting()`이 고장/죽은 코드일 가능성(`600651_Overview.md` §4.2)과 맞물려, `pre_order_created_at`만 세팅되고 실제 `orders`/`kds_tickets` 행이 없는 비정상 상태가 라이브에 존재할 수 있다. Slice D는 크래시하지 않을 것으로 판단되나 라이브 검증되지 않았다 — 다음 TestPlan에서 이 경계 케이스를 반드시 재현 테스트로 확인해야 한다(§D.1, §G).

## Module Domain Tags

`waiting-pipeline`, `order-session`, `phantom-column-correction`, `facade-delegation`, `admin-view`, `session-events-derivation`, `exception-atomicity`

## Snapshot Decision

4개 함수를 4개 Slice로 나눠 설계했다: Slice A(`confirm_arrival`)는 `mark_session_arrived()`(`0025`, 미변경)에 위임하는 파사드로 재작성했고, Slice B/C(`get_waiting_status`/`get_waiting_admin_view`)는 `orders`/`dining_tables` LEFT JOIN과 `session_events` 파생(`called_at`/`call_count`)으로 phantom 컬럼을 치환했으며, Slice D(`cancel_waiting`)는 `cancel_reason`의 phantom 쓰기를 삭제하고 렛저를 단일 진실 소스로 확정했다. `has_pre_order` 판정 기준을 4개 함수 전부 `pre_order_created_at is not null`로 통일했다(§0). Slice A/D에는 `600652_Logic.md`가 확립한 `EXCEPTION` 핸들러 패턴(`audit_domain:='session'`, `raise` 대신 `build_error_response` 반환)을 새로 추가해 신규 `error_key` 2개(`waiting_confirm_arrival_failed`/`waiting_cancel_operation_failed`)가 필요해졌다 — `600661_Overview.md` §5의 "신규 키 0건" 전망을 이 Logic 단계에서 2건으로 정정한다. `memo`(§C.1)는 이번 워크패킷 범위에서 제거하기로 확정했고, `cancel_waiting()`의 상태 가드/테이블 반납 갭(§D.2)은 명시적으로 스코프 밖에 남겼다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md] =====
# 600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code contract drafting, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §3's 13-stage structure)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`waiting_pipeline_sibling_functions_correction`

## §0 Scope and numbering confirmation

This TestPlan covers the Stage 8 implementation of `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` §A-§F — the 4 Slices (`confirm_arrival()`/`get_waiting_status()`/`get_waiting_admin_view()`/`cancel_waiting()`) in a new migration file (tentatively `sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql`).

Document number check:

- `600661_Overview_Waiting_Pipeline_Sibling_Functions_Correction.md` exists.
- `600662_Logic_Waiting_Pipeline_Sibling_Functions_Correction.md` exists.
- `600663_TestPlan_Waiting_Pipeline_Sibling_Functions_Correction.md` is the next TestPlan document number for this workpacket.
- `600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` is the paired ChangeContract.

Test fixtures use the `__test_600663_*` table-code prefix (distinct from `600653_TestPlan.md`'s `__test_dining_table_600653_*` and this session's ad-hoc `__test_dining_table_claudeverify_*`/`__test_600663_*` verification prefixes) and `<test_tenant_id>`/`<test_store_id>`/`<test_actor_id>` placeholders matching this project's established convention. Every section is a self-contained `begin;...rollback;` block.

**Timezone note (discovered empirically at Stage 5, not present in `600653_TestPlan.md`)**: `get_waiting_admin_view()`/`get_waiting_status()`'s queue-membership filters use `business_day := (timezone('Asia/Seoul', now()))::date`, while this DB session's `current_date` reflects the server's own `TIMEZONE` setting (confirmed live: `UTC`). When the UTC date and the Asia/Seoul date diverge (i.e. between 00:00-09:00 UTC, since Korea is UTC+9), inserting fixtures with `business_day := current_date` silently produces a session that the function's own Asia/Seoul-computed `v_business_day` filter does not match — the call still succeeds but returns an empty/short list, which reads as a false negative, not a real defect. **All fixtures below use `business_day := (timezone('Asia/Seoul', now()))::date` explicitly**, not `current_date`, to avoid this trap.

## §1 Pre-flight checks

Run before modifying or applying anything. If any Stop Condition in `600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md` is hit, stop and report.

### §1.1 Target functions still have the pre-fix (phantom-column) signature/behavior; `mark_session_arrived()` unchanged

```sql
select proname, pg_get_function_identity_arguments(oid)
from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace
  and proname in ('confirm_arrival', 'get_waiting_status', 'get_waiting_admin_view', 'cancel_waiting', 'mark_session_arrived');
```

Expected: all 5 rows present, with the 4 target functions' identity arguments unchanged from `0115`'s original signatures (`confirm_arrival`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_actor_id uuid, p_locale text, p_correlation_id text`; `cancel_waiting`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_cancel_reason text, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text`; `get_waiting_status`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_locale text`; `get_waiting_admin_view`: `p_tenant_id uuid, p_store_id uuid, p_locale text`) — confirms Stage 8 has not already run. `mark_session_arrived`: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_correlation_id text` — confirms the delegation target's contract is unchanged from `600662_Logic.md` §A.1's documented shape.

### §1.2 `mark_session_arrived()`'s GRANT and no-caller status re-confirmed

```sql
select proacl from pg_proc
where pronamespace = 'catchmenu_pos'::regnamespace and proname = 'mark_session_arrived';
```

Expected: `{postgres=X/postgres,authenticated=X/postgres}` — already grantable to `authenticated`, matching `600661_Overview.md` §1.5. Re-verified live (2026-07-18) via `pg_proc.proacl` on the local Supabase Postgres instance directly, cross-checked with `aclexplode(proacl)` and `pg_default_acl` for `catchmenu_pos` (no schema-level default granting `supabase_admin` found) — the grantee set is exactly `{postgres, authenticated}`, matching `0025:665-670`'s explicit `revoke all ... from public; grant execute ... to authenticated;` pair. **Could not reproduce a `supabase_admin` entry from this environment** — if Cursor/Codex's verification ran against a different target (e.g. the actual deployed/remote Supabase project rather than this local docker instance) and found `supabase_admin` there, that would indicate an environment-specific difference (possibly `supabase_admin` as the object owner in that environment, which Postgres implicitly grants full rights to without needing an explicit `proacl` entry, or a different migration-apply role) — **Stage 8 must re-run this exact query against its own target environment before relying on this baseline**, since this document's baseline is only confirmed against the local instance.

### §1.3 `order_sessions` — dependency columns exist and are unmodified by this plan

```sql
select column_name, data_type from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions'
  and column_name in ('table_id', 'order_id', 'queue_position', 'arrived_at', 'cancelled_at', 'pre_order_created_at')
order by column_name;
```

Expected: all 6 present (`table_id`/`order_id`/`queue_position` uuid/uuid/int; `arrived_at`/`cancelled_at`/`pre_order_created_at` timestamptz) — matching `600661_Overview.md` §1's baseline.

### §1.4 `error_codes` ORDER-domain ceiling (baseline for §E)

```sql
select max(code) from catchmenu_common.error_codes where error_domain = 'ORDER';
```

Expected (as of this document's writing): `7077` (the ceiling left by `0163`). Record the live value at pre-flight time — input to Stage 8's immediately-before-implementation re-check per `600662_Logic.md` §E, not a fixed assumption.

### §1.5 Server timezone confirmation (basis for §0's timezone note)

```sql
select current_setting('TIMEZONE'), current_date, (timezone('Asia/Seoul', now()))::date;
```

Record both dates at pre-flight time; if they differ, every fixture in this document that depends on `business_day` matching "today" for `get_waiting_status()`/`get_waiting_admin_view()` must use the Asia/Seoul value, not `current_date`.

## §2 Slice A — `confirm_arrival()` facade

### §2.1 Normal delegation success

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_arrival_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94001, 2, now() - interval '9 minutes'
) returning id as normal_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'normal_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as arrival_resp \gset

select :'arrival_resp'::jsonb ->> 'success' as success;
select :'arrival_resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'arrival_resp'::jsonb -> 'data' ->> 'next_step' as next_step;
select :'arrival_resp'::jsonb -> 'data' ? 'table_number' as has_table_number_key;

-- mark_session_arrived()'s own writes
select session_status, arrived_at is not null as has_arrived_at
from catchmenu_pos.order_sessions where id = :'normal_session_id'::uuid;

rollback;
```

Expected: `success = true`; `has_pre_order = false`; `next_step = 'WAIT_FOR_SEATING'`; `has_table_number_key = false` (`600662_Logic.md` §A.3 step 5 — the always-null `table_number` field was deliberately dropped from the response, 0 callers exist so no compatibility concern); `session_status = 'ARRIVAL_PENDING'`, `has_arrived_at = true` — confirms the crash is gone and `mark_session_arrived()`'s real `arrived_at` column is the one actually written, not the phantom `arrival_confirmed_at`.

### §2.2 Event footprint — `session_events` 1건 + `catchmenu_ledger.events` 2건 (`600662_Logic.md` §A.3/§G acceptance criterion 1)

**(실행 순서 주의)** 이 섹션은 반드시 독립된 `begin;...rollback;` 블록으로 끝까지 실행하고 커밋되지 않은 상태를 남기지 않아야 한다. §2.4로 곧바로 이어서 실행하면 안 된다 — 만약 이 섹션의 `rollback;`을 실행하지 않은 채(또는 같은 세션에서 `begin;`이 이미 열려 있는 상태로) §2.4를 이어서 실행하면, §2.4의 `alter table catchmenu_ledger.events add constraint tmp_block_arrival_confirmed check (event_type <> 'arrival_confirmed')`가 **같은(아직 열려 있는) 트랜잭션 안에서** 실행되어 이 섹션이 이미 삽입한 `event_type='arrival_confirmed'` 행까지 함께 검증 대상이 된다 — PostgreSQL의 `ALTER TABLE ... ADD CONSTRAINT`(`NOT VALID` 없이)는 기존 행 전체를 즉시 검증하므로, 그 기존 행이 새 CHECK를 위반해 **`ADD CONSTRAINT` 자체가 실패**하고 §2.4의 트리거 메커니즘 전체가 깨진다. 각 섹션은 psql을 종료하고 새로 접속하거나, 최소한 앞 섹션의 `rollback;`이 실제로 실행된 것을 확인한 뒤에만 다음 섹션을 실행한다.

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_arrival_events',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94002, 2
) returning id as events_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'events_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as arrival_resp \gset

select count(*) as session_events_customer_arrived_count
from catchmenu_pos.session_events
where session_id = :'events_session_id'::uuid and event_type = 'customer_arrived';

select event_domain, event_type
from catchmenu_ledger.events
where subject_id = :'events_session_id'::uuid
  and event_type in ('customer_arrived', 'arrival_confirmed')
order by event_domain;

rollback;
```

Expected: `session_events_customer_arrived_count = 1`. Ledger query returns exactly 2 rows: `event_domain='session', event_type='customer_arrived'` (from `mark_session_arrived()`) and `event_domain='waiting', event_type='arrival_confirmed'` (from the facade itself) — live-verified at Stage 5 via a `pg_temp` reproduction of the exact same insert sequence before this document was written.

### §2.3 `invalid_session_status` — reachability + raw pass-through (`600662_Logic.md` §A.2)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'CANCELLED', 94003, 2
) returning id as cancelled_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancelled_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb ->> 'error_key' as error_key;
select :'resp'::jsonb ->> 'current_status' as current_status;

rollback;
```

Expected: `success = false`; **`error_key = 'invalid_session_status'`** (flat top-level `error_key`, not `error.key` — `mark_session_arrived()`'s raw flat shape passed through unmodified, `600662_Logic.md` §A.2's designed behavior, not `build_error_response()`'s nested shape); `current_status = 'CANCELLED'`. This is also the reachability proof for `600662_Logic.md` §A.2's table — `session_not_found` is structurally unreachable via this facade (the facade's own step 1 already holds the row via `for update of os`) and is not separately reproduced, matching `0163 §7`'s precedent for structurally-unreachable keys.

### §2.4 `EXCEPTION` handler — `waiting_confirm_arrival_failed` + full delegation atomicity

**(2026-07-18, Stage 5 라이브 재현 완료)** `0163 §9`의 기법을 그대로 적용한다 — 파사드 자신이 쓰는 렛저 이벤트(`event_type='arrival_confirmed'`)만 정확히 겨냥하는 임시 `CHECK` 제약을 추가해, `mark_session_arrived()`의 위임이 이미 성공한 **이후** 시점에서만 예외를 유발한다. 이 문서를 작성하기 직전 `pg_temp` 함수로 정확히 동일한 삽입 순서를 재현해 결과를 확인했다.

**(실행 순서 주의, §2.2와 동일 원칙)** 이 섹션도 반드시 독립된 `begin;...rollback;` 블록으로 실행한다. 특히 §2.2를 먼저 실행했다면 그 `rollback;`이 실제로 완료된 뒤에만 이 섹션을 시작한다 — §2.2가 남긴(커밋되지 않았더라도 같은 열린 트랜잭션 안에 존재하는) `event_type='arrival_confirmed'` 행이 있으면, 아래의 `alter table ... add constraint`가 기존 행 검증에서 즉시 실패해 이 섹션 전체가 의도한 대로 동작하지 않는다.

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_arrival_confirmed check (event_type <> 'arrival_confirmed');

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94004, 2
) returning id as exc_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- mark_session_arrived()'s work must be fully rolled back (no savepoint of its own, 600652_Logic.md §9.2's
-- atomicity finding applies to this delegation too, not just bind_table_to_session())
select session_status, arrived_at is null as arrived_at_is_null
from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;
select count(*) as session_events_customer_arrived_count
from catchmenu_pos.session_events where session_id = :'exc_session_id'::uuid and event_type = 'customer_arrived';
select count(*) as ledger_customer_arrived_count
from catchmenu_ledger.events where subject_id = :'exc_session_id'::uuid and event_type = 'customer_arrived';

-- only the facade's own failure audit record survives
select audit_domain, audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'confirm_arrival_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_arrival_confirmed;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로):

- `success = false`; `error_key`(중첩) = `'waiting_confirm_arrival_failed'`.
- `session_status = 'WAITING'`(원래 상태로 롤백, `'ARRIVAL_PENDING'` 아님), `arrived_at_is_null = true`.
- `session_events_customer_arrived_count = 0`, `ledger_customer_arrived_count = 0` — `mark_session_arrived()`이 만들었던 모든 기록이 함께 롤백됐다.
- **정확히 한 행**: `audit_domain = 'session'`(**`'waiting'`이 아님** — `chk_audit_domain`이 `'waiting'`을 허용하지 않는다, `600652_Logic.md` §1.5/`600662_Logic.md` §A.3 EXCEPTION 핸들러 설계와 정확히 일치해야 함 — 만약 `'waiting'`으로 기록됐다면 그 자체가 `append_audit_record()` 호출이 크래시했다는 뜻이므로 이 assertion은 §A.3 설계의 직접적인 회귀 검증이다), `audit_type = 'confirm_arrival_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`(CHECK 위반).
- `drop constraint`로 스키마에 영구적 흔적을 남기지 않는다.

## §3 Slice B — `get_waiting_status()` 읽기 교정

### §3.1 Phantom 컬럼 4종 전부 해소 — 크래시 없이 완주 + 값 정확성

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_status_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94010, 2, now() - interval '20 minutes'
) returning id as status_session_id \gset

select catchmenu_pos.get_waiting_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'status_session_id'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'table_number' as table_number;
select :'resp'::jsonb -> 'data' ->> 'has_pre_order' as has_pre_order;
select :'resp'::jsonb -> 'data' -> 'timestamps' ->> 'called_at' as called_at;
select :'resp'::jsonb -> 'data' -> 'timestamps' ->> 'arrival_at' as arrival_at;
select :'resp'::jsonb -> 'data' ->> 'queue_position' as queue_position_in_response;

rollback;
```

Expected: `success = true`(원본은 여기서 크래시); `table_number = null`(테이블 배정 전이므로 원본 동작과 동일하게 `null`); `has_pre_order = false`; `called_at = null`(아직 호출된 적 없음); `arrival_at = null`(아직 도착 확인 전); `queue_position_in_response`는 숫자(별도 카운트 쿼리로 계산된 지역변수 — `600662_Logic.md` §B.1이 제거한 죽은 SELECT 항목과는 별개).

### §3.2 `called_at`/`arrival_at` 파생 정확성 — 도착 확인 후 재조회

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_status_arrived',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94011, 2
) returning id as arrived_session_id \gset

select catchmenu_pos.confirm_arrival(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'arrived_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as arrival_resp \gset

select catchmenu_pos.get_waiting_status(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'arrived_session_id'::uuid, p_locale := 'ko'
) as status_resp \gset

select :'status_resp'::jsonb -> 'data' -> 'timestamps' ->> 'arrival_at' is not null as has_arrival_at;
select :'status_resp'::jsonb -> 'data' ->> 'session_status' as session_status;

rollback;
```

Expected: `has_arrival_at = true`(§2.1의 `confirm_arrival()` 호출로 `arrived_at`이 세팅된 것을 `get_waiting_status()`가 정확히 읽음 — Slice A/B 교차 검증); `session_status = 'ARRIVAL_PENDING'`.

### §3.3 죽은 `queue_position` SELECT 항목 제거 확인 (`600662_Logic.md` §B.1)

```sql
select pg_get_functiondef('catchmenu_pos.get_waiting_status'::regproc) as func_def \gset
select :'func_def' !~ 'select id, wait_number, session_status,\s*\n\s*session_type, guest_count,\s*\n\s*guest_locale, queue_position,' as dead_select_removed;
```

Expected: 함수 본문에서 `queue_position`을 읽는 SELECT 목록 항목이 더 이상 존재하지 않음(정규식 매치 실패 = 제거 확인) — 완전 자동 정규식 매치가 Stage 8의 실제 포맷팅과 어긋날 수 있으므로, 이 항목은 정규식 결과와 무관하게 **코드 리뷰로도 재확인**해야 한다(`pg_get_functiondef()` 전문을 직접 읽고 SELECT 목록에 `queue_position`이 없는지 확인).

## §4 Slice C — `get_waiting_admin_view()` 읽기 교정 + `memo`/`patent_note` 제거

### §4.1 Phantom 컬럼 5종(`memo` 포함) 전부 해소 — 크래시 없이 완주

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_admin_normal',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, session_started_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94020, 2, now() - interval '6 minutes'
) returning id as admin_session_id \gset

select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select jsonb_array_length(:'resp'::jsonb -> 'data' -> 'waiting_list') >= 1 as has_at_least_one_entry;

-- the fixture session's own entry, by session_id
select entry
from jsonb_array_elements(:'resp'::jsonb -> 'data' -> 'waiting_list') as entry
where entry ->> 'session_id' = :'admin_session_id';

rollback;
```

Expected: `success = true`(원본은 여기서 크래시); `has_at_least_one_entry = true`; 픽스처 세션의 항목이 `table_number`/`pre_order_amount`/`called_at`/`call_count`/`is_foreign`/`waited_minutes`/`actions` 키를 모두 포함하되 **`memo` 키는 없음**(`600662_Logic.md` §C.1 옵션 1 확정) — `entry`를 직접 눈으로 확인해 `? 'memo' = false`임을 별도로 assert.

### §4.2 `called_at`/`call_count` 파생 정확성 — 다회 호출 시나리오

```sql
begin;

select catchmenu_store.upsert_dining_table(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_table_id := null, p_table_code := '__test_600663_admin_called',
  p_capacity := 4, p_actor_id := '<test_actor_id>'::uuid, p_locale := 'ko'
) as resp \gset

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94021, 2
) returning id as called_session_id \gset

-- 0160의 call_waiting_customer()를 두 번 호출 (재호출 지원 확인)
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'called_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as call1_resp \gset

select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'called_session_id'::uuid, p_actor_id := '<test_actor_id>'::uuid
) as call2_resp \gset

select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as admin_resp \gset

select entry -> 'call_count' as call_count, entry -> 'called_at' as called_at
from jsonb_array_elements(:'admin_resp'::jsonb -> 'data' -> 'waiting_list') as entry
where entry ->> 'session_id' = :'called_session_id';

rollback;
```

Expected: `call_count = 2`(`_record_waiting_call()`이 매 호출 시 `session_events`에 `'customer_called'` 행을 쌓고, `600662_Logic.md` §C.2의 `LEFT JOIN LATERAL`이 그걸 정확히 카운트); `called_at`은 두 번째 호출의 `occurred_at`(가장 최근 값, `max(occurred_at)`).

### §4.3 `patent_note` 실제로 응답에서 제거됨 (`600662_Logic.md` §C.2, Human 별도 승인 대상 — `600664_ChangeContract.md` §9)

```sql
select catchmenu_pos.get_waiting_admin_view(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid, p_locale := 'ko'
) as resp \gset
select :'resp'::jsonb -> 'data' ? 'patent_note' as has_patent_note_key;
```

Expected: `has_patent_note_key = false`. **이 항목은 Stage 8이 `600664_ChangeContract.md` §9의 별도 체크박스를 실제로 승인받았는지 먼저 확인한 뒤에만 실행/PASS 처리한다** — phantom 컬럼 치환과 무관한 응답 계약 변경이므로, 다른 항목들과 달리 이 검증 하나만으로 "정상 동작"을 판단하지 않는다.

## §5 Slice D — `cancel_waiting()` 쓰기 교정

### §5.1 `cancel_reason` — 세션 행엔 없지만 렛저/알림에는 있음 (`600662_Logic.md` §D.1)

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94030, 2
) returning id as cancel_session_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'cancel_session_id'::uuid,
  p_cancel_reason := '고객 변심', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'cancel_reason' as cancel_reason_in_response;

select session_status, cancelled_at is not null as has_cancelled_at
from catchmenu_pos.order_sessions where id = :'cancel_session_id'::uuid;

-- order_sessions에 cancel_reason 컬럼 자체가 없으므로, 이 쿼리는 정보 스키마로 직접 재확인
select count(*) as cancel_reason_column_exists
from information_schema.columns
where table_schema = 'catchmenu_pos' and table_name = 'order_sessions' and column_name = 'cancel_reason';

select event_payload ->> 'cancel_reason' as ledger_cancel_reason
from catchmenu_ledger.events
where subject_id = :'cancel_session_id'::uuid and event_type = 'waiting_cancelled';

rollback;
```

Expected: `success = true`; `cancel_reason_in_response = '고객 변심'`(응답 payload에는 그대로 있음, `p_cancel_reason` 파라미터 echo); `session_status = 'CANCELLED'`, `has_cancelled_at = true`; `cancel_reason_column_exists = 0`(스키마에 컬럼 자체가 없음을 재확인 — 정보 손실이 아니라 애초에 저장 대상이 아니었음의 증거); `ledger_cancel_reason = '고객 변심'`(렛저가 단일 진실 소스로서 정확히 보존).

### §5.2 KDS 티켓 취소 로직 보존 — 사전주문 있는 세션

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94031, 2
) returning id as kds_session_id \gset

insert into catchmenu_pos.orders (
  tenant_id, store_id, session_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'kds_session_id'::uuid, 'W94031',
  'DINE_IN', 'CONFIRMED', 'KIOSK', 18000, 18000, now(), (timezone('Asia/Seoul', now()))::date
) returning id as kds_order_id \gset

update catchmenu_pos.order_sessions
set order_id = :'kds_order_id'::uuid, pre_order_created_at = now()
where id = :'kds_session_id'::uuid;

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, kds_status, business_day
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, :'kds_order_id'::uuid, 'HOLD', (timezone('Asia/Seoul', now()))::date
) returning id as kds_ticket_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'kds_session_id'::uuid,
  p_cancel_reason := '사전주문 취소', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'data' ->> 'pre_order_cancelled' as pre_order_cancelled;
select kds_status, cancelled_at is not null as has_cancelled_at
from catchmenu_kds.kds_tickets where id = :'kds_ticket_id'::uuid;

rollback;
```

Expected: `success = true`; `pre_order_cancelled = true`; `kds_status = 'CANCELLED'`, `has_cancelled_at = true` — 사전주문 취소 시 연결된 KDS 티켓도 함께 취소되는 원본 로직이 보존됨을 확인. `kds_tickets` 스키마의 정확한 필수 컬럼은 Stage 8 직전 `\d catchmenu_kds.kds_tickets`로 재확인 필요(이 문서는 `0016_create_kds_tickets.sql` 기준 최소 컬럼만 가정).

### §5.3 `has_pre_order` 경계 케이스 — `pre_order_created_at`만 있고 `orders`/`kds_tickets` 없음 (`600662_Logic.md` §D.1/§H (i))

**(2026-07-18, Stage 5 라이브 재현 완료)** `pre_order_created_at`을 직접 세팅하고 `order_id`는 `null`로 남긴, `pre_order_while_waiting()`이 고장 상태일 경우 발생할 수 있는 비정상 상태를 인위적으로 구성해 재현했다.

```sql
begin;

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count, pre_order_created_at
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'PRE_ORDER', (timezone('Asia/Seoul', now()))::date, 'WAITING',
  94032, 2, now() - interval '3 minutes'
  -- order_id는 의도적으로 세팅하지 않음 -- pre_order_created_at만 있고 orders 행은 없는 비정상 상태
) returning id as edge_session_id \gset

select pre_order_created_at is not null as has_pre_order_created_at, order_id is null as order_id_is_null
from catchmenu_pos.order_sessions where id = :'edge_session_id'::uuid;

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'edge_session_id'::uuid,
  p_cancel_reason := '경계 케이스', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select session_status, cancelled_at is not null as has_cancelled_at
from catchmenu_pos.order_sessions where id = :'edge_session_id'::uuid;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로): `success = true`, `session_status = 'CANCELLED'`, `has_cancelled_at = true` — **크래시하지 않는다.** `update ... from catchmenu_pos.orders o where o.session_id = p_session_id ...`가 매칭되는 `orders` 행이 없어 단순히 0행 UPDATE로 끝나고(PostgreSQL `UPDATE ... FROM`의 no-op 특성), 함수는 정상 완주한다 — `600662_Logic.md` §D.1의 판단(크래시하지 않을 것으로 추정)이 라이브 재현으로 실증되었다.

### §5.4 `EXCEPTION` 핸들러 — `waiting_cancel_operation_failed` + 자체 쓰기 원자성

**(2026-07-18, Stage 5 라이브 재현 완료)** `cancel_waiting()`은 `bind_table_to_session()`/`mark_session_arrived()`처럼 별도 core에 위임하지 않고 **자기 자신이 직접** `order_sessions`를 UPDATE한다 — 그래도 PL/pgSQL 함수 전체가 단일 최상위 문으로 실행되므로, 함수 자신의 이전 UPDATE도 나중의 예외에 의해 함께 롤백되는지 별도로 확인이 필요하다(위임이 없다고 원자성이 자동으로 보장되는 게 아니라는 점을 실증).

```sql
begin;

alter table catchmenu_ledger.events
  add constraint tmp_block_waiting_cancelled check (event_type <> 'waiting_cancelled');

insert into catchmenu_pos.order_sessions (
  tenant_id, store_id, session_type, business_day, session_status, wait_number, guest_count
) values (
  '<test_tenant_id>'::uuid, '<test_store_id>'::uuid, 'WALK_IN', (timezone('Asia/Seoul', now()))::date, 'WAITING', 94033, 2
) returning id as exc_session_id \gset

select catchmenu_pos.cancel_waiting(
  p_tenant_id := '<test_tenant_id>'::uuid, p_store_id := '<test_store_id>'::uuid,
  p_session_id := :'exc_session_id'::uuid,
  p_cancel_reason := 'exc test', p_actor_type := 'CUSTOMER', p_actor_id := '<test_actor_id>'::uuid
) as resp \gset

select :'resp'::jsonb ->> 'success' as success;
select :'resp'::jsonb -> 'error' ->> 'key' as error_key;

-- cancel_waiting() 자신의 UPDATE도 롤백됐어야 한다
select session_status, cancelled_at is null as cancelled_at_is_null
from catchmenu_pos.order_sessions where id = :'exc_session_id'::uuid;

select audit_domain, audit_type, decision, decision_payload ->> 'sqlstate' as recorded_sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'cancel_waiting_failed' and subject_id = :'exc_session_id'::uuid;

alter table catchmenu_ledger.events drop constraint tmp_block_waiting_cancelled;

rollback;
```

Expected (Stage 5 라이브 재현 결과 그대로):

- `success = false`; `error_key`(중첩) = `'waiting_cancel_operation_failed'`.
- `session_status = 'WAITING'`(원래 상태로 롤백, `'CANCELLED'` 아님), `cancelled_at_is_null = true` — **위임이 없는 함수도 자체 쓰기가 함께 롤백된다는 것을 실증** (`600652_Logic.md` §9.2의 원자성 발견이 위임 케이스만이 아니라 PL/pgSQL 함수 일반의 성질임을 확인).
- **정확히 한 행**: `audit_domain = 'session'`(**`'waiting'`이 아님** — `chk_audit_domain`이 `'waiting'`을 허용하지 않는다, `600662_Logic.md` §D.2 EXCEPTION 핸들러 설계와 정확히 일치해야 함 — Slice A와 동일한 회귀 검증), `audit_type = 'cancel_waiting_failed'`, `decision = 'FAILED'`, `recorded_sqlstate = '23514'`.

## §6 Boundary — 0 diff

```bash
git status --short sql/migrations/0025_create_session_rpc.sql
git status --short sql/migrations/0115_create_waiting_pipeline_rpc.sql
git status --short sql/migrations/0160_call_waiting_customer_contract_recovery.sql
git status --short sql/migrations/0163_seat_waiting_customer_facade_correction.sql
```

Expected: all empty. `0025`(`mark_session_arrived()`/`bind_table_to_session()`, both unmodified — this workpacket only calls the former), `0115`(원본 소스 텍스트 — 4개 함수의 라이브 정의는 신규 `0164`의 `CREATE OR REPLACE`로 덮어써지지만 `0115` 파일 자체는 건드리지 않는다, `0160`/`0163`과 동일 기법), `0160`(`call_waiting_customer()`/`_record_waiting_call()`, §4.2에서 호출만 하고 수정하지 않음), `0163`(`seat_waiting_customer()`/`_resolve_dining_table_by_number()`, 완전히 무관) 전부 diff 0이어야 한다.

## §7 Acceptance criteria

PASS only if all are true:

1. Slice A: 정상 위임 성공(session `ARRIVAL_PENDING`, `arrived_at` 세팅 — `mark_session_arrived()`의 실제 쓰기), `table_number` 필드가 응답에서 완전히 빠짐(§2.1).
2. Slice A: 이벤트 발자국이 정확히 `session_events` 1건 + `catchmenu_ledger.events` 2건(도메인 각 1건씩)(§2.2).
3. Slice A: `invalid_session_status`가 `mark_session_arrived()`의 원시 flat JSON 그대로(재래핑 없이) 반환되고, `session_not_found`는 구조적으로 도달 불가능함이 재확인됨(§2.3).
4. Slice A: `EXCEPTION` 핸들러가 `waiting_confirm_arrival_failed`를 반환하고, `mark_session_arrived()`의 모든 상태 변경(세션/`session_events`/자체 렛저)이 함께 롤백되며, 파사드 자신의 실패 감사기록만 생존(§2.4).
5. Slice B: phantom 컬럼 4종이 전부 실컬럼/파생으로 치환되어 크래시 없이 완주하고, `called_at`/`arrival_at`이 실제 이벤트/컬럼 값과 정확히 일치하며, 죽은 `queue_position` SELECT 항목이 제거됨(§3.1-§3.3).
6. Slice C: phantom 컬럼 5종(`memo` 포함)이 전부 해소되어 크래시 없이 완주하고, `call_count`/`called_at`이 다회 호출 시나리오에서 정확히 파생되며, `patent_note`가 실제로 응답에서 빠지되 이 항목만 별도 Human 승인 확인 후 PASS 처리됨(§4.1-§4.3).
7. Slice D: `cancel_reason`이 `order_sessions` 행에는 없지만(스키마 재확인) 렛저 이벤트에는 정확히 보존되고, 사전주문이 있는 세션의 KDS 티켓 취소 로직이 보존되며, `pre_order_created_at`만 있고 `orders`가 없는 경계 케이스에서 크래시 없이 완주하고, `EXCEPTION` 핸들러가 위임 없는 함수에서도 자체 쓰기를 함께 롤백함(§5.1-§5.4).
8. `0025`/`0115`(원본 텍스트)/`0160`/`0163` 전부 0 diff(§6).


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600660_waiting_pipeline_sibling_functions_correction/600664_ChangeContract_Waiting_Pipeline_Sibling_Functions_Correction.md] =====
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

## §11 Final Audit (Stage 11, Claude)

**Verdict: ACCEPT (2026-07-18)**

핵심 주장 재도출 확인 (Stage 9 산출물을 액면 그대로 신뢰하지 않고 직접 재검토):

- Slice A(confirm_arrival 파사드): mark_session_arrived() 위임, 이벤트 발자국(session_events 1건+ledger.events 2건), invalid_session_status 재래핑 없는 통과, EXCEPTION 원자성(mark_session_arrived()의 모든 작업이 함께 롤백) - Cursor+Claude Code+안티 3자 독립 재현 완전 일치.
- Slice B/C: phantom 컬럼(memo 포함) 완전 해소, called_at/call_count 파생 정확성 확인. **안티가 get_waiting_admin_view()의 queue_position을 "제거 안 된 버그"로 오판했으나, Cursor+Claude Code가 이는 Slice B(제거 대상)와 Slice C(정렬/응답에 실제 사용되는 의도된 코드)를 혼동한 것임을 정확히 정정.** Slice B의 죽은 queue_position SELECT는 실제로 제거됨을 3자 모두 확인.
- Slice D: cancel_reason 렛저 보존, KDS 취소 로직 보존, has_pre_order 경계 케이스, 위임 없는 함수의 자체 원자성(cancel_waiting() 직접 쓰기도 함께 롤백) - 3자 일치. Cursor/Claude Code 각각 자신의 테스트 fixture 결함(ticket_number/menu_name_snapshot)을 스스로 발견하고 함수 자체 문제와 구분.
- 검증 방법론(AGENTS.md §3.8): 전 구간 begin/rollback 또는 승인 후 라이브 직접 호출(§10 APPROVED 확인 후)만 사용, 트랜잭션 밖 영구 변경 없음 확인 - 지난 라운드의 거버넌스 위반이 재발하지 않았음을 실증.

Boundary 확인: 0025/0048/0050/0110/0115(원본텍스트)/0160/0162/0163 전부 0 diff (3자 일치), 0164는 커밋 7f616d4f에 정상 포함.

**Open Items (다음 워크패킷 후보로 이월):**

1. cancel_waiting()의 상태가드/테이블반납 로직 부재 - 별도 워크패킷 후보(cancel_waiting_state_guard_and_table_release).
2. get_waiting_admin_view()의 patent_note 제거 - 완료, 이 워크패킷에서 별도 승인받아 해소됨.
3. memo 필드 제거 - 완료, 향후 직원메모 기능 필요시 별도 워크패킷(waiting_session_staff_memo_feature).
4. _record_waiting_call()의 proacl 공백 - 여전히 미해결, 별도 워크패킷 후보.
5. get_dining_table_admin_list()(601120) 응답형태 불일치 - 여전히 범위 밖.
6. error_codes 7078/7079 - 이번 워크패킷에서 정상 확정 등록됨.
7. Slice B/C에 EXCEPTION 핸들러 미추가 결정 - 최종 확정으로 유지(Stage 6에서 이견 없었음).
8. has_pre_order의 암묵 가정(pre_order_created_at이 있으면 orders도 있다) - pre_order_while_waiting() 고장 가능성과 맞물려 여전히 잠재 위험, 이번 워크패킷에서 크래시 없음만 확인됨.


## §12 Human Merge/Release

담당: Human (정영석님) — §9 전체 6개 항목 체크 및 §10 승인 완료(2026-07-18), Stage 8 착수 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600671_Overview_Record_Waiting_Call_Grant_Correction.md] =====
# 600671_Overview_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 번호 확인 (라이브/인덱스 재확인)

`600600_waiting_order_session/` 산하 기존 워크패킷은 `600610`/`600620`/`600630`/`600640`/`600650`/`600660` 6개다 — 다음 "10단위" 슬롯 `600670`이 `docs/000005_Index_Document_Number.md`와 물리적 디렉터리 양쪽에서 미사용임을 재확인했다(`grep`/`ls` 0건). 이 도메인의 자체 백단위 공간(`600600`-`600699`)이 아직 소진되지 않았으므로, 이전 여러 워크패킷(`601020`/`601030`)에서 반복됐던 "다른 백단위 차용" 절차는 이번엔 필요 없다. 폴더 `600670_record_waiting_call_grant_correction/`, Overview `600671`, Logic `600672`로 배정한다.

## §1 배경 (Cursor 전수조사 완료, 재확인 불필요 — 단, GRANT 부재 자체는 정적 재확인함)

`sql/migrations/0160_call_waiting_customer_contract_recovery.sql` 파일 전체를 재확인한 결과(`grep -in "revoke\|grant" 0160...sql` → **0건**), 이 파일은 `REVOKE`/`GRANT` 문을 단 하나도 포함하지 않는다 — Cursor의 전수조사 결과와 일치. 이 파일이 생성/재선언하는 3개 함수의 현재 권한 상태:

| 함수 | 0160 내 REVOKE/GRANT | 현재 권한 상태(§7 (b), 2026-07-18 라이브 재확인 완료) |
|---|---|---|
| `catchmenu_pos._record_waiting_call(...)` | 없음(신규 CREATE) | `proacl` NULL 확정 — 한 번도 명시적 GRANT/REVOKE가 적용된 적 없어 PostgreSQL 스키마 기본 권한(PUBLIC EXECUTE) 그대로다. |
| `catchmenu_pos.call_next_waiting_customer(...)` | 없음(신규 CREATE) | 위와 동일 — `proacl` NULL 확정. |
| `catchmenu_pos.call_waiting_customer(...)` | 없음(`CREATE OR REPLACE`, 시그니처 불변) | **부분적 — `authenticated` GRANT는 있으나 `PUBLIC`이 한 번도 REVOKE된 적 없음**(§4에서 출처를 라이브 마이그레이션 이력으로 역추적 확정, 단 별도 성격의 결함으로 이번 워크패킷 범위 밖). |

**(2026-07-18 갱신 — 해소됨)** 라이브 `pg_proc.proacl` 직접 재확인은 이전 초안 작성 시점에 Docker 연결 실패로 완료하지 못했으나, 이후 Cursor+Codex가 라이브로 확인을 완료했고 이 세션도 Docker 재연결 후 독립적으로 재확인했다 — `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL(추정이 확정으로 전환), `call_waiting_customer()`는 `authenticated` GRANT와 `PUBLIC` EXECUTE 잔존이 동시에 확인됐다(§7 (b) 상세).

## §2 601140의 유사 사례와의 대조 — "proacl NULL이 실제 위험인가"

`601140_allergen_info_and_sibling_overwrite_correction` 워크패킷이 정확히 같은 유형의 문제를 다룬 선례다: Codex가 `upsert_menu_core()`의 `pg_proc.proacl`이 NULL임을 라이브로 확인했고(`601142_Logic.md` §1.2), 그 근거로 "wrapper(`upsert_menu()`)를 우회해 내부 헬퍼를 직접 호출할 수 있다"는 위험을 명시했다. **다만 그 워크패킷은 이 ACL 갭 자체를 닫는 REVOKE/GRANT 문을 실제로 추가하지 않았다** — `601144_ChangeContract.md` §3(Allowed Operations)을 직접 재확인한 결과, 승인된 변경은 `upsert_menu()`/`upsert_menu_core()`의 파라미터 기본값(default) 교정과 카테고리 `display_order` 로직뿐이며, ACL 문 추가는 그 목록 어디에도 없다 — proacl=NULL 사실은 "기본값 교정이 방어적 권장이 아니라 필수"라는 논거로만 쓰였을 뿐, ACL 자체를 닫는 작업은 명시적으로 이 워크패킷의 범위 밖으로 남았다. 이것이 이번 워크패킷의 배경에서 인용한 "601140이 이미 'proacl/REVOKE 추가는 Allowed Operations에 없음'이라고 결정한 사항"의 정확한 근거이며, 이번 워크패킷은 이 결정을 뒤집지 않는다(§6 스코프, §7 Open Item).

## §3 `call_next_waiting_customer()`의 설계 의도 — 순수 내부용이 아니라 "두 번째 공개 진입점"

**결론(라이브 설계문서 확인 완료)**: `call_next_waiting_customer()`는 순수 내부/배치 전용 함수가 아니라, `call_waiting_customer()`와 함께 "의도적으로 역할이 분리된 두 개의 공개(public) 진입점" 중 하나로 Human이 명시적으로 결정한 것이다.

**증거 1 — Human 결정 원문**(`600642_Logic_Call_Waiting_Customer_Contract_Recovery.md` §2, "Q1 결정 요약", 재논의 금지로 이미 확정된 사항): "자동 큐 선택 기능은 병합하지 않는다. `call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출, 가칭)를 **별도 함수로 유지**하되, 공통 로직(호출 기록/이벤트/알림)은 **내부 헬퍼**로 공유한다." 같은 문서 §1.1(L21)은 두 함수를 명시적으로 "두 개의 공개 함수"로 지칭하며("Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로..."), §2.1 도입부(L68)는 이를 "각 공개 함수(§2.2/§2.3)"로 재확인한다 — 오직 `_record_waiting_call()`만 "internal 헬퍼"로 구분된다.

**증거 2 — 레거시 전신의 실제 GRANT**: `call_next_waiting_customer()`는 `0050_create_waiting_queue_rpc.sql`의 `call_next_waiting()`(자동 선택 로직, `0160`에서 DROP됨)을 그대로 계승한다(`0160`의 자체 주석: `"0050:194-211 원문 로직 그대로"`, `600642_Logic.md` §2.3 표: `"0050.call_next_waiting()의 자동 선택 로직 이식"`). 라이브 재확인 결과, `0050:714-719`에서 그 전신 함수는 이미 명시적으로 `revoke all ... from public; grant execute ... to authenticated;`를 받고 있었다 — 즉 원래 설계 의도부터 `authenticated`가 직접 호출 가능한 공개 RPC였다.

**증거 3 — `p_actor_type` 하드코딩**: `call_next_waiting_customer()` 본문(`0160:298`)은 `p_actor_type := 'STAFF'`를 하드코딩한다 — 이 코드베이스 전반에서 `'STAFF'` 액터 타입은 일관되게 "사람(직원)이 직접 트리거한 액션"을 의미하며(예: `mark_no_show()`의 수동 경로 등), 순수 자동/배치 전용 함수라면 `'SYSTEM'`을 쓰는 것이 이 코드베이스의 다른 배치 함수들(`0118` cron 등)과의 관례에 맞다.

**결론에 대한 반대 증거는 없음**: 현재 라이브 SQL/Flutter 어디에도 `call_next_waiting_customer()`의 실제 호출자가 없다(고아 함수 상태, `600642_Logic.md` §2.4가 이미 확인한 사실 — "실호출자 0건"). 하지만 이는 "아직 배선되지 않았다"는 뜻이지 "내부 전용으로 설계됐다"는 뜻이 아니다 — 이 코드베이스에는 `bulk_commit_kds_tickets()`처럼 완성됐지만 아직 호출자가 배선되지 않은 공개 RPC가 이미 여러 건 확인된 바 있다(`601031_Overview.md` §3 등, 다른 워크패킷).

**따라서**: `call_next_waiting_customer()`는 `_resolve_dining_table_by_number()`(순수 내부, REVOKE-only) 패턴이 아니라 공개 진입점으로 취급해야 한다. **다만 이를 "`call_waiting_customer()`와 동일한 패턴을 적용한다"고 표현하는 것도, "`0163`이 확립한 완전한 패턴을 적용한다"고 표현하는 것도 둘 다 부정확하다** — `call_waiting_customer()`의 현재 상태는 §4에서 확인했듯 `GRANT`만 있고 `PUBLIC` `REVOKE`는 없는 **불완전한** 상태다. **`0163`은 REVOKE-only 선례일 뿐이다**(§5 — `_resolve_dining_table_by_number()`에 `GRANT` 문 자체가 없다, 내부 헬퍼용 패턴). 실제로 `REVOKE`+`GRANT`가 둘 다 있는 "완전한 공개 RPC" 선례는 `0050:714-719`(`call_next_waiting()`, §5.2 재확인)다. `call_next_waiting_customer()`에는 두 선례를 결합한 패턴 — `0163`의 REVOKE 문 형태 + `0050`의 공개 RPC용 GRANT 문 — 을 새로 적용한다(§5.1/§5.2/§6).

## §4 `call_waiting_customer()`의 현재 GRANT 출처 — 라이브 이력으로 확정(추정 아님), 그러나 완전히 안전하지는 않음

`call_waiting_customer()`는 `0115_create_waiting_pipeline_rpc.sql`에서 최초 생성됐다(`600642_Logic.md` §2.4 표: `"0115:419-599"`). `0115:1741-1744`를 직접 확인한 결과:

```sql
grant execute on function
  catchmenu_pos.call_waiting_customer(
    uuid, uuid, uuid, text, uuid, text, text
  ) to authenticated;
```

이 시그니처(`uuid, uuid, uuid, text, uuid, text, text` — 7개 파라미터)는 `0160`이 재선언한 `call_waiting_customer()`의 시그니처(`p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text default null, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`)와 타입 순서가 정확히 일치한다 — PostgreSQL은 `CREATE OR REPLACE FUNCTION`이 시그니처(파라미터 타입 목록)를 바꾸지 않는 한 기존 함수의 ACL(`proacl`)을 그대로 보존한다. 즉 `call_waiting_customer()`가 현재 `authenticated` 실행 권한을 갖고 있는 것은 우연이 아니라 `0115`에서 부여된 권한이 이후 모든 `CREATE OR REPLACE`(`0160` 포함, 그 사이 어떤 마이그레이션도 시그니처를 바꾸지 않음)를 통해 그대로 보존되어 온 것이다. **"추정"이 아니라 라이브 마이그레이션 이력으로 확정**된 사실이다.

**(Stage 4 Critical tier 정정)** 다만 이 사실만으로 "이미 안전하다"고 결론짓는 것은 부정확하다 — `0115:1732-1781`의 전체 grants 블록을 재확인한 결과, `call_waiting_customer()`를 포함해 이 블록이 부여하는 9개 함수 전부에 대해 `grant execute` 문만 있을 뿐 **`revoke all ... from public` 문이 단 하나도 없다**(파일 전체 `grep -in "revoke"` 재확인, 0건). 그리고 이 코드베이스 전체에서 `call_waiting_customer()`에 대한 `revoke`가 이후 어떤 마이그레이션에서도 실행된 적이 없다(`grep -rn "call_waiting_customer" sql/migrations/*.sql | grep -i revoke` → 0건). 즉 `call_waiting_customer()`는 `authenticated`에 명시적으로 GRANT돼 있으면서 **동시에 `PUBLIC`도 여전히 EXECUTE 권한을 갖고 있다**(PostgreSQL이 함수 생성 시 기본으로 `PUBLIC`에 EXECUTE를 부여하고, 명시적으로 REVOKE하지 않는 한 그대로 남는다) — 이는 `anon`을 포함한 어떤 역할이든 이 함수를 직접 호출할 수 있다는 뜻이며, 그 자체로 별도의 보안 공백이다.

**이번 워크패킷 범위에서 제외하는 이유**: 이 갭은 `call_next_waiting_customer()`/`_record_waiting_call()`의 결함(애초에 `0160`에서 어떤 GRANT/REVOKE도 없이 신규 생성된, "처음부터 잘못 설계된" 경우)과 성격이 다르다 — `call_waiting_customer()`의 경우는 `0115` 작성 당시 이 코드베이스의 여러 함수에 공통적으로 나타나는 "GRANT는 명시하되 PUBLIC REVOKE는 생략하는" 레거시 관행에 가깝다(같은 grants 블록의 나머지 8개 함수도 동일 패턴). 이는 이번 워크패킷이 다루는 "형제 결함"(같은 파일, 같은 원인)과는 다른 별도 범주의 문제이므로, 이번 워크패킷의 스코프에서 명시적으로 분리하고 별도 hardening 워크패킷 후보로 남긴다(§7 신규 Open Item).

## §5 두 종류의 GRANT/REVOKE 선례 — 각각 정확한 출처로 재확인 (Stage 4 Critical tier 정정)

**(정정, 2026-07-18)** 이전 초안은 "`0163`이 REVOKE+GRANT 완전 패턴을 확립했다"고 잘못 서술했다 — `0163`은 REVOKE-only 선례만 확립했을 뿐, `GRANT` 문 자체가 없다. 완전한 REVOKE+GRANT(공개 RPC용) 선례는 `0050`이다. 두 선례를 각각 정확히 재확인한다.

### §5.1 REVOKE-only 선례 — `0163`(`_resolve_dining_table_by_number()`, 내부 헬퍼용)

`600650_seat_waiting_customer_facade_correction`(`0163`)이 순수 내부 헬퍼 `_resolve_dining_table_by_number()`에 적용한 패턴을 라이브로 재확인했다(`0163:404-406`):

```sql
revoke all on function catchmenu_pos._resolve_dining_table_by_number(
  uuid, uuid, text
) from public;
```

`GRANT`문 없이 `REVOKE ALL ... FROM PUBLIC`만 있다 — 이 패턴은 `REVOKE`/`GRANT` 대상 함수의 파라미터 타입 목록만 정확히 나열하면 되는 순수 문법이며, 파라미터 개수나 타입(스칼라 전용, `record`/복합 타입 없음)에 따른 제약이 전혀 없다. `_record_waiting_call()`의 16개 파라미터(전부 스칼라: `uuid`/`text`/`int`/`boolean`/`timestamptz`)에 그대로 적용 가능함을 확인했다 — 문법적 장애 없음. **`_record_waiting_call()`은 이 REVOKE-only 패턴 그대로를 적용한다 — 정정 대상 아님.**

### §5.2 REVOKE+GRANT 완전 선례 — `0050`(`call_next_waiting()`, 공개 RPC용)

`0050_create_waiting_queue_rpc.sql:714-719`를 직접 재확인했다(원문 그대로):

```sql
revoke all on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) from public;
grant execute on function catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
) to authenticated;
```

`REVOKE ALL FROM PUBLIC` 다음 `GRANT EXECUTE TO authenticated`가 이어지는 완전한 조합이다 — 이 함수가 바로 `call_next_waiting_customer()`의 전신(§3 증거 2)이므로, `call_next_waiting_customer()`에 적용할 정확한 선례는 `0163`이 아니라 이 `0050` 패턴이다(§6).

## §6 확정된 범위

1. `_record_waiting_call()` — `0163`의 `_resolve_dining_table_by_number()` 선례 그대로: `REVOKE ALL ... FROM PUBLIC`만, `authenticated`에도 GRANT하지 않는다(완전 내부 전용 — 실제로 `0160` 파일 내 2곳: `call_waiting_customer()`/`call_next_waiting_customer()`에서만 호출됨을 재확인).
2. `call_next_waiting_customer()` — `0163`의 REVOKE 문 형태(§5.1)와 `0050`의 공개 RPC용 GRANT 선례(§5.2)를 결합한 `REVOKE ALL ... FROM PUBLIC` + `GRANT EXECUTE ... TO authenticated` 패턴을 신규 적용한다(§3의 설계 의도 판단에 따름). `call_waiting_customer()`의 현재 상태(GRANT만 있고 PUBLIC REVOKE 없음, §4)를 그대로 복제하는 것이 **아니다** — 이 함수보다 더 완전한 패턴을 새로 적용하는 것이다.
3. `call_waiting_customer()` — **수정 없음**. `authenticated` GRANT는 정상 존재하나, `PUBLIC`이 한 번도 REVOKE된 적 없는 별도의 보안 공백이 있다(§4) — 이는 "레거시 관행"에 가까운 다른 성격의 문제로 판단해 이번 워크패킷 범위에서 명시적으로 제외한다(§7 신규 Open Item).
4. `upsert_menu_core()`/`sync_menu_option_*_core()` 계열(`0110`) — **함수 자체는 `601140`의 핵심 수정 대상이었다**(파라미터 기본값 교정). 이번 워크패킷이 범위 밖으로 두는 것은 오직 그 함수의 **ACL(REVOKE/GRANT) 교정 작업**뿐이다 — `601140`도 이 ACL 작업은 명시적으로 제외했었다(§2). Open Item으로만 기록(§7 (a)).

## §7 Open Items

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — **정확한 구분**: `upsert_menu_core()` 자체는 `601140`의 핵심 수정 대상이었다(파라미터 기본값 교정, `601142_Logic.md` §1.2). `601140`이 발견했으나 닫지 않고 범위 밖으로 남긴 것은 오직 그 함수의 **ACL(REVOKE/GRANT) 교정 작업**뿐이다(§2). 별도 워크패킷 후보(가칭 `menu_core_grant_correction`)로 기록. 이번 워크패킷이 이 결정을 뒤집지 않는다.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료했고, 이 세션도 Docker 재연결 후 독립적으로 재확인했다:

```text
_record_waiting_call        | proacl = (NULL, 빈 값)
call_next_waiting_customer  | proacl = (NULL, 빈 값)
call_waiting_customer       | proacl = {=X/postgres,postgres=X/postgres,authenticated=X/postgres}
```

`_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL(§1의 추정이 확정으로 전환) — 명시적 GRANT/REVOKE가 한 번도 적용된 적 없다. `call_waiting_customer()`는 `authenticated=X/postgres`(§4의 GRANT 확정)와 함께 `=X/postgres`(역할명 없는 항목 — `PUBLIC`에 대한 `X`=EXECUTE 권한) 항목이 동시에 존재함을 확인했다 — `PUBLIC` EXECUTE가 여전히 잔존한다는 §4/§7 (e)의 결론과 정확히 일치한다.

(c) `call_next_waiting_customer()`의 실호출자가 현재 0건(고아 함수)이라는 사실 자체는 이번 워크패킷이 해소하지 않는다 — GRANT를 부여해도 실제로 호출할 클라이언트/RPC가 배선되기 전까지는 여전히 도달 불가능한 상태로 남는다. `600642_Logic.md` §6이 이미 이 사실을 기록했고, 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 최종 명칭이 아직 "(가칭)" 상태다(`600642_Logic.md` §6 item 4) — 이번 워크패킷은 이 이름을 그대로 사용하며 명칭 확정 여부를 다루지 않는다.

(e) **[신규, Stage 4 Critical tier 지적 반영]** `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE되지 않은 채 남아있다(§4) — `authenticated` GRANT와 별개로, `anon`을 포함한 임의의 역할이 이 함수를 직접 호출할 수 있는 상태다. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 9개 함수 전부가 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보(가칭 `waiting_pipeline_public_revoke_hardening` 또는 더 넓은 범위의 "0115 grants 블록 전체 PUBLIC REVOKE 감사")로 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `600672_Logic.md`로 이어짐.** `0160` 소스 파일 전체에 `REVOKE`/`GRANT` 문이 전혀 없음을 정적으로 재확인했고(§1), 그 결과 세 함수 중 `_record_waiting_call()`/`call_next_waiting_customer()`는 `proacl` NULL 확정(§7 (b), 2026-07-18 라이브 재확인 완료), `call_waiting_customer()`는 부분적(`authenticated` GRANT는 있으나 `PUBLIC` REVOKE 없음, §4)임을 확인했다. `call_next_waiting_customer()`의 설계 의도를 `600642_Logic.md`의 Human 결정(Q1: "두 개의 공개 함수") + `0050` 전신의 실제 GRANT 이력 + `p_actor_type='STAFF'` 하드코딩 3가지 근거로 "공개 진입점"으로 결론지었다(§3) — `_resolve_dining_table_by_number()`식 완전 내부 전용이 아니다. `0163`의 REVOKE-only 패턴(§5.1)과 `0050`의 REVOKE+GRANT 완전 패턴(§5.2)을 각각 정확한 출처로 재확인했다. `601140`이 `upsert_menu_core()` **자체**(파라미터 기본값)를 이미 수정했고, 범위 밖으로 남긴 것은 그 함수의 ACL 교정뿐임을 `601144_ChangeContract.md` 직접 재확인으로 정확히 구분했다(§2/§7 (a)). 라이브 `pg_proc.proacl` 직접 재확인은 Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§7 (b)).

**(Stage 4 Critical tier 정정 반영, 2026-07-18 — 1차 정정. 이 단락은 정정 이력 기록용이며, 아래 "2차 정정" 단락이 이 단락의 오류를 다시 바로잡았다. 최종 정확한 서술은 본문 §3/§5.1/§5.2/§6을 따를 것.)** Cursor+Codex가 지적한 4가지 서술 부정확성을 이 시점에 해소했다고 판단했다: (1) `call_waiting_customer()`의 "이미 안전하다" 서술을 "`authenticated` GRANT는 있으나 `PUBLIC` REVOKE는 없는 별도의 보안 공백"으로 정정하고 신규 Open Item (e)를 추가했다(§4/§7 (e)) — 이 정정은 이후로도 유효, 변경 없음. (2) ~~`call_next_waiting_customer()`의 GRANT 패턴을 "`call_waiting_customer()`와 동일"이 아니라 "`0163`의 완전한 REVOKE+GRANT 패턴을 신규 적용"으로 정정했다~~ **— 이 서술 자체가 오류였다(0163은 REVOKE-only일 뿐 GRANT 문이 없다). 아래 "2차 정정" 단락에서 다시 바로잡았다 — 최종 서술은 §5.1/§5.2/§3/§6 참고.** (3) "601140에서 upsert_menu_core() 제외" 표현을 "함수 자체는 601140의 핵심 수정 대상이었고, 제외된 것은 그 함수의 ACL 교정 작업뿐"으로 명확히 구분했다(§2/§6/§7 (a)) — 이 정정은 이후로도 유효, 변경 없음. (4) `600642_Logic.md`의 "두 개의 공개 함수" 인용 위치를 "§2.1 도입부"에서 실제 위치인 "§1.1(L21)"로 정정했다(§3) — 이 정정은 이후로도 유효, 변경 없음. **다만 "0160:298 → 0160:297" 정정 요청은 이 세션이 직접 재확인(Read 도구 + `grep -n` 독립 확인 2회)한 결과 `p_actor_type := 'STAFF'`가 실제로 298번째 줄에 있음을 확인해 반영하지 않았다** — 원래 인용(`0160:298`)이 정확하며, 이 불일치를 Human에게 투명하게 보고한다(재확인 요청 시 파일을 다시 확인할 것).

**(2차 정정, 2026-07-18, Cursor+Codex 재검증)** 1차 정정 자체에도 4가지 신규/잔존 불일치가 있었다 — (1) [최우선] "`0163`이 완전한 REVOKE+GRANT를 확립했다"는 서술이 여전히 틀렸다: `0163`은 REVOKE-only(내부 헬퍼용)만 확립했고, `GRANT` 문 자체가 없다 — 실제 완전한 REVOKE+GRANT(공개 RPC용) 선례는 `0050:714-719`(`call_next_waiting()`)다. 두 선례를 정확히 분리해 재서술했다(§5.1/§5.2, §3, §6). `_record_waiting_call()`은 여전히 `0163`의 REVOKE-only 패턴 그대로 유지한다(변경 없음, 원래도 맞았음). (2) §1/§2의 "§8 Open Item" 교차참조 오류를 실제 위치인 "§7"로 정정했다. (3) `600672_Logic.md` §2.2의 "600642_Logic.md §2 Q1 결정" 인용을 `600671_Overview.md`와 일치시켜 "§1.1(L21)"로 정정했다. (4) Open Item (b)를 "Docker 연결 실패로 미완료"에서 "해소됨 — Cursor+Codex 라이브 확인 완료, 이 세션도 Docker 재연결 후 `pg_proc.proacl`을 독립적으로 재확인(`_record_waiting_call`/`call_next_waiting_customer` 둘 다 NULL, `call_waiting_customer`는 `authenticated` GRANT+`PUBLIC` EXECUTE 잔존 동시 확인)"으로 갱신했다(§7 (b)).


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600672_Logic_Record_Waiting_Call_Grant_Correction.md] =====
# 600672_Logic_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 설계 원칙 요약

`600671_Overview.md`의 확인 결과를 그대로 적용한다: (1) `_record_waiting_call()`은 완전 내부 전용 — `REVOKE ALL FROM PUBLIC`만, `authenticated`에도 GRANT하지 않는다(§1). (2) `call_next_waiting_customer()`는 역할상 `call_waiting_customer()`와 동등한 공개 진입점이지만, ACL은 `call_waiting_customer()`의 현재(불완전한) 상태를 복제하지 않는다 — `0163`의 REVOKE 문 형태(내부 헬퍼용 선례)와 `0050`의 공개 RPC용 GRANT 선례(`0050:714-719`)를 결합한 `REVOKE ALL FROM PUBLIC` + `GRANT EXECUTE TO authenticated` 패턴을 신규 적용한다(§2) — `0163` 자신은 REVOKE-only이며 `GRANT` 문을 포함하지 않는다. (3) `call_waiting_customer()`는 `authenticated` GRANT는 정상이나 `PUBLIC`이 한 번도 REVOKE된 적 없는 별도 성격의 갭이 있다 — 이번 워크패킷에서는 수정하지 않는다(§3). (4) `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했고, 그 함수의 ACL 교정만 범위 밖이다 — 이번 워크패킷도 손대지 않는다(§5).

## §1 `catchmenu_pos._record_waiting_call(...)` — REVOKE-only (완전 내부 전용)

### §1.1 실제 호출자 재확인 — `0160` 파일 내 정확히 2곳

```sql
-- 0160:226 (call_waiting_customer 내부)
return catchmenu_pos._record_waiting_call(...);

-- 0160:289 (call_next_waiting_customer 내부)
return catchmenu_pos._record_waiting_call(...);
```

파일 전체(`grep -n "_record_waiting_call"`) 재확인 결과 이 2곳 외 다른 호출자는 없다 — `_resolve_dining_table_by_number()`(`0163`)와 정확히 동일한 성격("같은 파일 내 신규 공개 함수 2곳에서만 호출되는 내부 헬퍼")이므로 그 선례를 그대로 적용한다.

### §1.2 GRANT/REVOKE 문 (신규 migration에 추가)

```sql
revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;
```

**파라미터 타입 목록은 `0160:37-54`의 실제 시그니처 순서를 그대로 따른다**: `p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_from_status text, p_wait_number int, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_has_pre_order boolean, p_pre_order_amount int, p_table_number text, p_expires_at timestamptz, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text` — 16개 전부 스칼라 타입, `record`/복합 타입 없음(`600671_Overview.md` §5.1 재확인).

`GRANT EXECUTE ... TO authenticated`는 추가하지 않는다 — `0163`의 `_resolve_dining_table_by_number()` 선례와 동일하게 `REVOKE`만으로 충분하다(`security definer`이므로 내부 호출자는 이 REVOKE와 무관하게 호출 가능).

## §2 `catchmenu_pos.call_next_waiting_customer(...)` — REVOKE + GRANT authenticated (공개 진입점)

### §2.1 GRANT/REVOKE 문 (신규 migration에 추가)

```sql
revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;
```

**파라미터 타입 목록**: `0160:240-246`의 실제 시그니처(`p_tenant_id uuid, p_store_id uuid, p_actor_id uuid default null, p_locale text default 'ko', p_correlation_id text default null`) — 5개, 전부 스칼라. `default` 절은 `REVOKE`/`GRANT` 문에는 영향을 주지 않는다(타입 목록만 일치하면 된다).

### §2.2 설계 근거 재확인 (`600671_Overview.md` §3의 3가지 증거 요약)

1. `600642_Logic.md` §2 Q1 결정 본문: "`call_waiting_customer()`(지정 호출)와 `call_next_waiting_customer()`(자동 다음 호출)를 별도 함수로 유지" — "두 개의 공개 함수"라는 정확한 문구 자체는 같은 문서 **§1.1(L21)**에 있다("Q1 결정으로 두 개의 공개 함수가 이 로직을 공유하게 되었으므로...").
2. 전신 `0050.call_next_waiting()`이 이미 `revoke all ... from public; grant execute ... to authenticated;`를 받고 있었다(`0050:714-719`).
3. `p_actor_type := 'STAFF'` 하드코딩(`0160:298`) — 사람(직원)이 직접 트리거하는 액션을 의미하는 이 코드베이스의 관례.

이 세 근거가 함께 `call_next_waiting_customer()`를 `_record_waiting_call()`과 다른 카테고리(공개 진입점)로 분류한다 — 단순히 "형제 결함이니 같은 패턴"으로 기계적으로 처리하지 않고, 각 함수의 실제 역할을 개별 판단한 결과다(사용자 지시사항 "확정된 범위" §2의 명시적 요구).

## §3 `catchmenu_pos.call_waiting_customer(...)` — 수정 없음(단, 완전히 안전한 상태는 아님)

`0115:1741-1744`에서 부여된 `authenticated` GRANT가 시그니처 불변 덕에 `0160`의 `CREATE OR REPLACE`까지 그대로 보존됐다(`600671_Overview.md` §4, 라이브 마이그레이션 이력으로 확정). **다만 같은 확인 결과, `PUBLIC`에 대한 `REVOKE`는 `0115`를 포함해 어떤 마이그레이션에서도 실행된 적이 없다** — `authenticated` GRANT와 무관하게 `PUBLIC`(및 `anon`)도 여전히 이 함수를 직접 호출할 수 있는 상태다. 이는 `call_next_waiting_customer()`/`_record_waiting_call()`의 결함(애초에 어떤 GRANT/REVOKE도 없이 신규 생성됨)과는 다른 범주 — `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리한다(`600671_Overview.md` §7 (e)). 따라서 이 함수는 이번 워크패킷에서 어떤 SQL 문도 추가/수정하지 않는다 — Stage 8 구현은 이 함수 정의 자체를 다시 선언(`CREATE OR REPLACE`)할 필요조차 없다(신규 migration은 §1.2/§2.1의 GRANT/REVOKE 문만 포함, 기존 함수 재선언 불필요).

## §4 마이그레이션 배치 (Stage 5/8 대상, 이번 문서는 설계만)

- Stage 5에서 `sql/migrations/` 다음 사용 가능 번호를 재확인해 확정한다(이 문서 작성 시점 기준 `0166`이 최신이나, `601034_ChangeContract.md` §14.5 Draft Migration 판단 대상이므로 이 워크패킷의 번호는 그와 무관하게 별도로 다음 순번을 확정해야 한다).
- 신규 migration은 `catchmenu_pos._record_waiting_call(...)`/`catchmenu_pos.call_next_waiting_customer(...)`에 대한 `REVOKE`/`GRANT` 문만 포함한다 — 두 함수의 본문(`CREATE OR REPLACE FUNCTION`)은 재선언하지 않는다(함수 로직 자체는 변경 대상이 아니므로, `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14 Operation Granularity Rule에 따라 GRANT/REVOKE만 최소 범위로 추가).
- `call_waiting_customer(...)`는 신규 migration에 어떤 문도 포함하지 않는다(§3).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`) 자체(파라미터 기본값)는 이미 `601140`이 수정했다 — 이번 워크패킷이 손대지 않는 것은 오직 그 함수의 ACL 교정뿐이며, `601140`이 이미 그 부분을 범위 밖으로 남긴 결정을 뒤집지 않는다(`600671_Overview.md` §2/§7 (a)).
- `call_waiting_customer()`의 `PUBLIC` REVOKE 누락은 별도 성격의 문제로 이번 워크패킷 범위 밖이다(§3, §6 (e)).
- `call_next_waiting_customer()`의 최종 명칭 확정, 실호출자 배선(Flutter/다른 RPC), 재시도/스케줄링 로직 설계는 다루지 않는다.
- 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§6 (b)).

## §6 Open Items (`600671_Overview.md` §7과 동일한 (a)-(e) 목록을 공유)

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — **정확한 구분**: `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했다. 범위 밖으로 남은 것은 오직 그 함수의 ACL(REVOKE/GRANT) 교정뿐이다. 별도 워크패킷 후보(가칭 `menu_core_grant_correction`), 이번 워크패킷 범위 밖.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료: `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL, `call_waiting_customer()`는 `authenticated=X/postgres`(GRANT)와 `=X/postgres`(PUBLIC EXECUTE 잔존)가 동시에 존재. 이 세션도 Docker 재연결 후 동일 쿼리로 독립 재확인해 일치를 확인했다(`600671_Overview.md` §7 (b) 상세).

(c) `call_next_waiting_customer()`의 실호출자 0건(고아 함수) — GRANT 부여 후에도 배선 전까지는 도달 불가능한 상태로 남는다. 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 "(가칭)" 명칭 미확정 — 이번 워크패킷은 다루지 않는다.

(e) **[신규, Stage 4 Critical tier 지적 반영]** `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE된 적 없다(§3) — `authenticated` GRANT와 별개의 보안 공백. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보로 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계 완료.** `_record_waiting_call()`은 `0163`의 `_resolve_dining_table_by_number()` 선례를 그대로 따라 `REVOKE ALL FROM PUBLIC`만 적용한다(§1) — 실제 16개 파라미터 전부가 스칼라 타입이라 문법적 문제가 없음을 확인했다. `call_next_waiting_customer()`는 형제 결함(같은 파일, 같은 원인)이지만 기계적으로 동일 패턴을 적용하지 않고 3가지 독립 근거(Human 결정 Q1, `0050` 전신의 실제 GRANT 이력, `p_actor_type='STAFF'` 하드코딩)로 "공개 진입점"임을 확정해 `0163`의 REVOKE 문 형태와 `0050`의 공개 RPC용 GRANT 선례를 결합한 패턴을 신규 적용하기로 설계했다(§2) — `call_waiting_customer()`의 현재(불완전한) ACL 상태를 복제하는 것도, `0163` 하나만으로 완전한 패턴을 확립하는 것도 아니다. `call_waiting_customer()` 자신은 `0115`에서 부여된 `authenticated` GRANT가 시그니처 불변으로 보존되어 왔음을 라이브 이력으로 확정했으나, 동시에 `PUBLIC`이 한 번도 REVOKE된 적 없다는 별도의 갭도 발견했다 — 이는 "형제 결함"과 다른 범주(레거시 관행)로 판단해 수정 대상에서 명시적으로 제외했다(§3, §6 (e)). `upsert_menu_core()` **자체**(파라미터 기본값)는 `601140`이 이미 수정했고, 범위 밖으로 남은 것은 그 함수의 ACL 교정뿐임을 `601144_ChangeContract.md`를 직접 재확인해 명확히 구분했다(§5, §6 (a)). 라이브 `pg_proc.proacl` 재확인은 Cursor+Codex 및 이 세션의 독립 재확인으로 완료됐다(§6 (b)). `.sql` 파일은 생성·수정하지 않았다.

**(2차 정정, 2026-07-18, Cursor+Codex 재검증)** 4가지 신규/잔존 불일치를 해소했다 — (1) [최우선] "`0163`이 완전한 REVOKE+GRANT를 확립했다"는 서술을 "`0163`의 REVOKE 문 형태 + `0050:714-719`의 공개 RPC용 GRANT 선례를 결합"으로 정정했다(§0/§2) — `_record_waiting_call()`은 여전히 `0163`의 REVOKE-only 패턴 그대로다(변경 없음). (2) `600671_Overview.md` §1.2 재확인 인용 위치를 정확한 하위섹션(`§5.1`)으로 정정했다. (3) §2.2의 "`600642_Logic.md` §2 Q1 결정" 인용에서, Q1 결정 본문은 §2가 맞지만 "두 개의 공개 함수" 정확한 문구는 §1.1(L21)에 있음을 구분해 명시했다. (4) Open Item (b)를 "Docker 연결 실패로 미완료"에서 "해소됨"으로 갱신했다 — Cursor+Codex 라이브 확인 결과를 이 세션도 Docker 재연결 후 독립적으로 재확인했다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600673_TestPlan_Record_Waiting_Call_Grant_Correction.md] =====
# 600673_TestPlan_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## §0 Scope and numbering confirmation

This TestPlan verifies the final design in `600671_Overview_Record_Waiting_Call_Grant_Correction.md` and `600672_Logic_Record_Waiting_Call_Grant_Correction.md` — both carried 4 rounds of Cursor+Codex Critical tier verification (including a live `pg_proc.proacl` re-confirmation, `600671_Overview.md` §7 (b)). This TestPlan cites that design as final and does not re-litigate it.

**Migration number**: `sql/migrations/` tops out at `0166_canonical_kds_release_orchestration.sql` (confirmed via both directory listing and `catchmenu_meta.migration_history`). `0167` is the next available number for this workpacket — Stage 8 must re-run this exact check immediately before creating the file, per the project's standing numbering discipline (`000701_Guide_Controlled_AI_Development_Pipeline.md` §14.5 Migration Draft Mutability Rule also applies once the file exists).

**Live-reconfirmed at Stage 5 (2026-07-18, this session, via `docker exec ... psql`)** — the exact signatures the new migration's `REVOKE`/`GRANT` statements must target:

```text
catchmenu_pos._record_waiting_call(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_from_status text, p_wait_number integer, p_guest_locale text, p_phone_hash text, p_customer_id uuid, p_has_pre_order boolean, p_pre_order_amount integer, p_table_number text, p_expires_at timestamp with time zone, p_actor_type text, p_actor_id uuid, p_locale text, p_correlation_id text)
catchmenu_pos.call_next_waiting_customer(p_tenant_id uuid, p_store_id uuid, p_actor_id uuid, p_locale text, p_correlation_id text)
catchmenu_pos.call_waiting_customer(p_tenant_id uuid, p_store_id uuid, p_session_id uuid, p_table_number text, p_actor_id uuid, p_locale text, p_correlation_id text)
```

All three match exactly what `600672_Logic.md` §1.2/§2.1/§3 assumed — no drift since Stage 1.5.

## §1 Pre-flight checks

### §1.1 Baseline `has_function_privilege()` state (before any change)

```sql
select
  has_function_privilege('anon', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as anon_record_call,
  has_function_privilege('authenticated', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as auth_record_call,
  has_function_privilege('anon', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as anon_next,
  has_function_privilege('authenticated', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as auth_next,
  has_function_privilege('anon', 'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)', 'execute') as anon_cwc,
  has_function_privilege('authenticated', 'catchmenu_pos.call_waiting_customer(uuid,uuid,uuid,text,uuid,text,text)', 'execute') as auth_cwc;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): `anon_record_call=t`, `auth_record_call=t`, `anon_next=t`, `auth_next=t`, `anon_cwc=t`, `auth_cwc=t` — all six `true`. This is the exact vulnerability `600671_Overview.md` §1/§7 documented: `proacl` NULL on the first two functions means PostgreSQL's schema-default PUBLIC EXECUTE applies to every role including `anon`; `call_waiting_customer()`'s own separate gap (`authenticated` GRANT present, `PUBLIC` never revoked) produces the same `anon=t` result via a different mechanism.

### §1.2 Roles exist

```sql
select rolname from pg_roles where rolname in ('anon','authenticated','postgres') order by rolname;
```

Expected: all 3 rows present (live-reconfirmed).

## §2 `_record_waiting_call()` — REVOKE-only, verify anon AND authenticated both lose direct EXECUTE

```sql
begin;

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

select
  has_function_privilege('anon', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as anon_after,
  has_function_privilege('authenticated', 'catchmenu_pos._record_waiting_call(uuid,uuid,uuid,text,int,text,text,uuid,boolean,int,text,timestamptz,text,uuid,text,text)', 'execute') as auth_after;

rollback;
```

Expected (live-reconfirmed at Stage 5): `anon_after=f`, `auth_after=f` — **both** roles lose direct EXECUTE, matching the design intent (`_record_waiting_call()` is never called directly by any client, only internally via `SECURITY DEFINER` from the two public functions — the 2-caller fact is confirmed in `600672_Logic.md` §1.1, and the REVOKE-only precedent it follows is documented in `600671_Overview.md` §5.1).

## §3 `call_next_waiting_customer()` — REVOKE + GRANT authenticated, verify anon loses / authenticated keeps

```sql
begin;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

select
  has_function_privilege('anon', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as anon_after,
  has_function_privilege('authenticated', 'catchmenu_pos.call_next_waiting_customer(uuid,uuid,uuid,text,text)', 'execute') as auth_after;

rollback;
```

Expected (live-reconfirmed at Stage 5): `anon_after=f`, `auth_after=t` — `anon` loses execute, `authenticated` retains it. This is the exact combination `600672_Logic.md` §2 designed (`0163`'s `REVOKE ALL FROM PUBLIC` form + `0050:714-719`'s `GRANT EXECUTE TO authenticated` form for a public RPC).

## §4 Functional continuity — both public functions still work end-to-end after §2/§3's REVOKE

Reproduces the `SECURITY DEFINER` internal-call principle already established by `0163`'s `_resolve_dining_table_by_number()` precedent: revoking direct EXECUTE on an internal helper does not break callers that invoke it from within another `SECURITY DEFINER` function, because the call executes with the definer's rights, not the direct caller's.

```sql
begin;

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

-- Fixture setup must happen BEFORE switching role -- 'authenticated' has no direct table
-- grants in this codebase's access model (no direct table GRANTs, only through
-- SECURITY DEFINER RPCs), so these raw INSERTs would themselves fail as 'authenticated'.
insert into catchmenu_pos.orders (tenant_id, store_id, order_number, order_type, order_status, order_channel, total_amount, final_amount, ordered_at, business_day)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,'S5-GRANT-CWC','TAKEOUT','CONFIRMED','KIOSK',10000,10000,now(),current_date)
returning id as order_id \gset

insert into catchmenu_pos.order_sessions (tenant_id, store_id, order_id, session_type, session_status, wait_number, guest_count, guest_locale, session_started_at, business_day, business_timezone)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,:'order_id'::uuid,'WALK_IN','WAITING',101,2,'ko',now(),current_date,'Asia/Seoul')
returning id as session_id \gset

insert into catchmenu_pos.orders (tenant_id, store_id, order_number, order_type, order_status, order_channel, total_amount, final_amount, ordered_at, business_day)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,'S5-GRANT-CNWC','TAKEOUT','CONFIRMED','KIOSK',10000,10000,now(),current_date)
returning id as order_id2 \gset

insert into catchmenu_pos.order_sessions (tenant_id, store_id, order_id, session_type, session_status, wait_number, guest_count, guest_locale, session_started_at, business_day, business_timezone)
values ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid,:'order_id2'::uuid,'WALK_IN','WAITING',102,2,'ko',now(),current_date,'Asia/Seoul')
returning id as session_id2 \gset

-- (Stage 4 Codex/Cursor 지적 반영) 이 지점부터 실제로 'authenticated' 역할로 전환해
-- 호출한다 -- postgres(슈퍼유저)로 그대로 호출하면 ACL이 전혀 검사되지 않으므로,
-- GRANT가 실제로 이 역할의 호출을 가능하게 하는지 증명하지 못한다. SET LOCAL은
-- 이 트랜잭션(및 마지막의 rollback)에 한정되어 자동으로 원복된다.
set local role authenticated;

-- (Codex 제안 반영) 역할 전환이 실제로 적용됐는지, 그리고 authenticated가
-- superuser가 아니어서 ACL이 실제로 검사되는 컨텍스트인지 직접 확인한다 --
-- current_user만 보고 "authenticated로 전환됐다"고 가정하지 않는다.
select
  session_user,
  current_user,
  (select rolsuper from pg_roles where rolname = current_user) as is_superuser;

-- §4.1: call_waiting_customer() -> _record_waiting_call(), called AS authenticated
select catchmenu_pos.call_waiting_customer(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_session_id := :'session_id'::uuid,
  p_table_number := 'T5',
  p_correlation_id := 'verify-600673-cwc'
) as call_waiting_customer_result;

-- §4.2: call_next_waiting_customer() -> _record_waiting_call(), called AS authenticated
select catchmenu_pos.call_next_waiting_customer(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_correlation_id := 'verify-600673-cnwc'
) as call_next_waiting_customer_result;

rollback;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): the `session_user`/`current_user`/`is_superuser` check returns exactly `session_user=postgres`, `current_user=authenticated`, `is_superuser=false` — confirming both that the role switch actually took effect and that `authenticated` is a genuinely non-superuser role for which ACL checks are enforced (not merely that `current_user` displays a different name). Both calls, executed genuinely as the `authenticated` role (not `postgres`), return `{"success": true, "message_key": "waiting_called_alert", ...}` with correct `wait_number`/`session_id`/`call_count` data — identical shape to pre-REVOKE behavior. This proves the `authenticated` GRANT on `call_next_waiting_customer()` actually enables real invocation by that role through the ACL layer, not merely that `has_function_privilege()` reports `true` in the catalog — `postgres` bypasses ACL checks entirely as a superuser, so testing under `postgres` alone (as the original draft did) cannot distinguish "GRANT present and effective" from "GRANT missing but irrelevant because the caller is a superuser." Confirms the GRANT/REVOKE change is purely a direct-caller privilege restriction; it does not alter any function's logic or break the internal call chain (`_record_waiting_call()` is invoked with `security definer` rights regardless of the direct caller's own grants).

## §5 `call_waiting_customer()` — confirm untouched (byte-identical `proacl` comparison, Stage 4 Codex/Cursor 지적 반영)

**(정정, 2026-07-18)** `has_function_privilege()` t/t 비교만으로는 §7 acceptance criterion 3의 "byte-identical" 요구를 실제로 증명하지 못한다 — `t`/`t`는 `anon`과 `authenticated` 둘 다 실행 가능하다는 것만 확인할 뿐, `proacl` 전체(예: 소유자 항목의 순서, `GRANT OPTION` 플래그, 혹시 모를 제3의 역할 항목)가 마이그레이션 적용 전후로 정말 한 글자도 바뀌지 않았는지는 증명하지 않는다. `pg_proc.proacl::text`를 마이그레이션 적용 **직전**에 캡처해 트랜잭션 변수로 저장한 뒤, 적용 **직후** 값과 문자 그대로(`=`) 비교한다.

```sql
begin;

select proacl::text as before_proacl
from pg_proc
where proname = 'call_waiting_customer' and pronamespace = 'catchmenu_pos'::regnamespace
\gset

\echo 'before_proacl =' :'before_proacl'

revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;

revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;

select
  proacl::text as after_proacl,
  (proacl::text = :'before_proacl') as byte_identical
from pg_proc
where proname = 'call_waiting_customer' and pronamespace = 'catchmenu_pos'::regnamespace;

rollback;
```

Expected (live-reconfirmed at Stage 5, 2026-07-18): `before_proacl` and `after_proacl` are the identical literal string `{=X/postgres,postgres=X/postgres,authenticated=X/postgres}`, and `byte_identical=t`. This function is explicitly out of scope (`600671_Overview.md` §7 (e)); this workpacket's migration touches only `_record_waiting_call()`/`call_next_waiting_customer()`, so `call_waiting_customer()`'s `proacl` must not change by even one character.

## §6 Boundary — 0 diff

### §6.1 Target file itself

```powershell
git diff -- sql/migrations/0160_call_waiting_customer_contract_recovery.sql
```

Expected: no diff. Per `600672_Logic.md` §4, the new migration adds `REVOKE`/`GRANT` statements referencing the two functions by signature — it does not re-declare (`CREATE OR REPLACE`) either function, so `0160` itself is never touched.

### §6.2 Unrelated files

```powershell
git diff -- `
  sql/migrations/0050_create_waiting_queue_rpc.sql `
  sql/migrations/0110_create_store_admin_rpc.sql `
  sql/migrations/0115_create_waiting_pipeline_rpc.sql `
  sql/migrations/0163_seat_waiting_customer_facade_correction.sql `
  sql/migrations/0166_canonical_kds_release_orchestration.sql
```

Expected: no diff on any of these 5 files. `0050`/`0115`/`0163` are cited only as design precedents (§0), never modified. `0110` (`upsert_menu_core()` family) is explicitly out of scope (`600671_Overview.md` §7 (a), `601140`'s prior decision not reversed). `0166` is the most recent unrelated migration, included as a general drift check.

### §6.3 Runtime boundary

```powershell
git diff -- catchmenu_app
```

Expected: no diff.

## §7 Acceptance criteria

The workpacket passes Stage 9 verification only if all of the following are true:

1. `_record_waiting_call()` loses EXECUTE for **both** `anon` and `authenticated` after the migration (§2) — no `GRANT` of any kind remains.
2. `call_next_waiting_customer()` loses EXECUTE for `anon` but retains it for `authenticated` after the migration (§3).
3. `call_waiting_customer()`(`uuid,uuid,uuid,text,uuid,text,text`)'s `pg_proc.proacl::text` is literally byte-identical before and after the migration — not merely `has_function_privilege()` reporting the same `t`/`t` (§5). This is an explicit, deliberate non-fix (`600671_Overview.md` §7 (e)), not an oversight — regression-testing it here guards against silently touching it in Stage 8.
4. Both `call_waiting_customer()` and `call_next_waiting_customer()` continue to complete successfully end-to-end after the REVOKE/GRANT change **when actually invoked as the `authenticated` role via `SET LOCAL ROLE`** (not `postgres`), producing the same response shape as before (§4) — this is the only way to prove the `GRANT` is actually effective for that role rather than merely present in the catalog.
5. `0160_call_waiting_customer_contract_recovery.sql` shows 0 diff (§6.1) — the new migration never re-declares either function.
6. `0050`/`0110`/`0115`/`0163`/`0166` and `catchmenu_app` show 0 diff (§6.2/§6.3).
7. The new migration contains only `REVOKE`/`GRANT` statements for `_record_waiting_call()`/`call_next_waiting_customer()` — no `CREATE OR REPLACE FUNCTION`, no schema change, no statement referencing `call_waiting_customer()` or any `upsert_menu_core()`-family object.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600670_record_waiting_call_grant_correction/600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md] =====
# 600674_ChangeContract_Record_Waiting_Call_Grant_Correction.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`record_waiting_call_grant_correction`

## Authority

- `600671_Overview_Record_Waiting_Call_Grant_Correction.md`
- `600672_Logic_Record_Waiting_Call_Grant_Correction.md`
- `600673_TestPlan_Record_Waiting_Call_Grant_Correction.md`

## §0 Contract summary

This ChangeContract authorizes adding `REVOKE`/`GRANT` statements — and only those statements — for exactly two existing functions in `sql/migrations/0160_call_waiting_customer_contract_recovery.sql`: `catchmenu_pos._record_waiting_call(...)` and `catchmenu_pos.call_next_waiting_customer(...)`. Neither function's body is modified; neither is re-declared (`CREATE OR REPLACE`) at all — the new migration is pure ACL correction on already-existing live objects.

`_record_waiting_call()` gets `REVOKE ALL ... FROM PUBLIC` only (no `GRANT` to any role) — it is called exclusively from within the other two functions via `SECURITY DEFINER`, never directly by a client (`600671_Overview.md` §1.1/§5.1, the `0163`/`_resolve_dining_table_by_number()` precedent). `call_next_waiting_customer()` gets `REVOKE ALL ... FROM PUBLIC` followed by `GRANT EXECUTE ... TO authenticated` — it is a public entry point (Human decision Q1, `600642_Logic.md` §1.1/§2), and this combination follows `0050:714-719`'s precedent for its own predecessor function `call_next_waiting()`.

`call_waiting_customer()` is deliberately **not** touched by this contract — it has its own separate, already-documented gap (`authenticated` GRANT present, `PUBLIC` never revoked, `600671_Overview.md` §4/§7 (e)) that is out of scope here and carried forward as an Open Item for a future hardening workpacket.

**Numbering note**: `sql/migrations/` currently tops out at `0166`; `0167` is available for this workpacket — Stage 8 must re-confirm this immediately before creating the file, per `000701_Guide_Controlled_AI_Development_Pipeline.md` §14.5 (Migration Draft Mutability Rule) and the project's standing numbering discipline.

## §1 Allowed files and objects

### §1.1 Allowed new SQL file

- One new migration, tentatively `sql/migrations/0167_record_waiting_call_grant_correction.sql` (Stage 8 must re-run the next-available-number check per §0 before creating it).

### §1.2 Allowed objects (ACL only — no `CREATE`/`CREATE OR REPLACE`)

- `REVOKE ALL ON FUNCTION catchmenu_pos._record_waiting_call(uuid, uuid, uuid, text, int, text, text, uuid, boolean, int, text, timestamptz, text, uuid, text, text) FROM PUBLIC` — exactly as specified in `600672_Logic.md` §1.2, live-reconfirmed at Stage 5 (`600673_TestPlan.md` §2).
- `REVOKE ALL ON FUNCTION catchmenu_pos.call_next_waiting_customer(uuid, uuid, uuid, text, text) FROM PUBLIC` followed by `GRANT EXECUTE ON FUNCTION catchmenu_pos.call_next_waiting_customer(uuid, uuid, uuid, text, text) TO authenticated` — exactly as specified in `600672_Logic.md` §2.1, live-reconfirmed at Stage 5 (`600673_TestPlan.md` §3).

No existing migration file may be modified. `0160_call_waiting_customer_contract_recovery.sql` is not edited — the target functions already exist live with the signatures above; this contract only changes their ACLs.

### §1.3 Changelog

`sql/migrations/CHANGELOG.md` may be appended only if the project migration convention requires recording the new migration. No existing entry may be rewritten.

## §2 Required implementation contract

### §2.1 `catchmenu_pos._record_waiting_call(...)` — REVOKE-only

```sql
revoke all on function catchmenu_pos._record_waiting_call(
  uuid, uuid, uuid, text, int, text, text, uuid,
  boolean, int, text, timestamptz, text, uuid, text, text
) from public;
```

No `GRANT` statement of any kind for this function is authorized. Required invariant: after this statement runs, `has_function_privilege('anon', ..., 'execute')` and `has_function_privilege('authenticated', ..., 'execute')` must both return `false` (`600673_TestPlan.md` §2).

### §2.2 `catchmenu_pos.call_next_waiting_customer(...)` — REVOKE + GRANT authenticated

```sql
revoke all on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) from public;

grant execute on function catchmenu_pos.call_next_waiting_customer(
  uuid, uuid, uuid, text, text
) to authenticated;
```

Required invariant: after these statements run, `has_function_privilege('anon', ..., 'execute')` must return `false` and `has_function_privilege('authenticated', ..., 'execute')` must return `true` (`600673_TestPlan.md` §3).

### §2.3 Functional continuity requirement

Both `catchmenu_pos.call_waiting_customer(...)` and `catchmenu_pos.call_next_waiting_customer(...)` must continue to complete successfully end-to-end after §2.1/§2.2 apply — the `SECURITY DEFINER` internal call to `_record_waiting_call()` is unaffected by the direct-caller REVOKE (`600673_TestPlan.md` §4, live-reconfirmed at Stage 5 with real fixture data).

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule.

**New file `sql/migrations/0167_record_waiting_call_grant_correction.sql`** (number to be reconfirmed, §0/§1.1):

1. Create the file with a header identifying its purpose, `Depends on: 0166_canonical_kds_release_orchestration.sql` (sequential-numbering convention only, no functional dependency).
2. `REVOKE ALL ON FUNCTION catchmenu_pos._record_waiting_call(...)` exactly as specified in §2.1. No other statement referencing this function.
3. `REVOKE ALL ON FUNCTION catchmenu_pos.call_next_waiting_customer(...)` exactly as specified in §2.2.
4. `GRANT EXECUTE ON FUNCTION catchmenu_pos.call_next_waiting_customer(...) TO authenticated` exactly as specified in §2.2. No other GRANT, and no GRANT of any kind for step 2's function.

No operation is authorized on any other file, including `0160` itself.

## §4 Forbidden Operations

- Modifying `catchmenu_pos.call_waiting_customer(...)` in any way — no ACL change, no body change, no re-declaration. This function's own gap is an explicit, separate Open Item (§8 (e)), not part of this contract.
- Modifying `catchmenu_pos._record_waiting_call(...)`'s or `catchmenu_pos.call_next_waiting_customer(...)`'s function **bodies** — this contract is ACL-only. Any `CREATE OR REPLACE FUNCTION` for either is forbidden.
- Editing `sql/migrations/0160_call_waiting_customer_contract_recovery.sql` in any way (including adding the new `REVOKE`/`GRANT` statements in-place — they belong in the new migration only, per `600672_Logic.md` §4's Operation Granularity reasoning).
- Editing `sql/migrations/0110_create_store_admin_rpc.sql` or any `upsert_menu_core()`/`sync_menu_option_*_core()`-family object — explicitly out of scope, `601140`'s prior decision not to add ACL correction there is not reversed here (`600671_Overview.md` §2/§7 (a)).
- Editing `sql/migrations/0050_create_waiting_queue_rpc.sql`, `sql/migrations/0115_create_waiting_pipeline_rpc.sql`, or `sql/migrations/0163_seat_waiting_customer_facade_correction.sql` — cited only as design precedents, never modified.
- Any `GRANT` to `public` for either target function.
- Any schema change (new column, new table, new CHECK constraint) — this workpacket is ACL-only.
- Any Flutter/`catchmenu_app` change.

## §5 Forbidden scope

- `call_waiting_customer()`'s own `PUBLIC` EXECUTE gap — Open Item (e), separate future hardening workpacket, not designed or implemented here.
- `upsert_menu_core()`/`sync_menu_option_*_core()` ACL correction — Open Item (a), separate future workpacket (`menu_core_grant_correction`), not designed or implemented here.
- `call_next_waiting_customer()`'s orphan-caller status (0 real callers) — Open Item (c), not addressed; granting `authenticated` execute does not itself wire any caller.
- `call_next_waiting_customer()`'s final name confirmation (still "(가칭)") — Open Item (d), not addressed.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_pos._record_waiting_call(...)`'s live identity arguments no longer match the 16-parameter signature in §1.2/§2.1 (a drift since this contract was drafted).
2. `catchmenu_pos.call_next_waiting_customer(...)`'s live identity arguments no longer match the 5-parameter signature in §1.2/§2.2.
3. `catchmenu_pos.call_waiting_customer(...)`'s live `proacl` no longer shows both `authenticated` GRANT and `PUBLIC` EXECUTE present (i.e., someone already partially fixed it since this contract was drafted) — would mean Open Item (e)'s premise has changed and must be reported, not silently absorbed.
4. Either target function already shows an existing explicit `GRANT`/`REVOKE` in its live `proacl` (i.e., `proacl` is not actually `NULL` for both, contradicting `600671_Overview.md` §7 (b)'s live-reconfirmed finding).
5. `0167` (or whatever number is actually used, §0/§1.1) is found to already exist with different content when Stage 8 begins.
6. The functional continuity check (§2.3/`600673_TestPlan.md` §4) fails — either public function stops working end-to-end after the REVOKE/GRANT is applied.

## §7 Required verification

Stage 8 must run `600673_TestPlan_Record_Waiting_Call_Grant_Correction.md` completely.

Minimum required evidence:

1. `_record_waiting_call()` loses EXECUTE for both `anon` and `authenticated` (§2).
2. `call_next_waiting_customer()` loses EXECUTE for `anon`, retains it for `authenticated` (§3).
3. `call_waiting_customer()`'s privilege state is unchanged before/after (§5).
4. Both public functions complete successfully end-to-end after the change (§4).
5. `0160`, `0050`, `0110`, `0115`, `0163`, `0166`, and `catchmenu_app` all show 0 diff (§6.1/§6.2/§6.3).

## §8 Open Items (carried from `600671_Overview.md` §7 / `600672_Logic.md` §6, in full — identical (a)-(e) list in all three documents)

(a) `upsert_menu_core()`/`sync_menu_option_*_core()`(`0110`)의 `proacl` NULL 갭 — `upsert_menu_core()` 자체(파라미터 기본값)는 `601140`이 이미 수정했다. 범위 밖으로 남은 것은 오직 그 함수의 ACL(REVOKE/GRANT) 교정뿐이다. 별도 워크패킷 후보(가칭 `menu_core_grant_correction`), 이번 워크패킷 범위 밖.

(b) **[해소, 2026-07-18]** 라이브 `pg_proc.proacl` 직접 재확인 — Cursor+Codex가 라이브로 확인 완료: `_record_waiting_call()`/`call_next_waiting_customer()` 둘 다 `proacl` NULL, `call_waiting_customer()`는 `authenticated=X/postgres`(GRANT)와 `=X/postgres`(PUBLIC EXECUTE 잔존)가 동시에 존재. 이 세션도 Docker 재연결 후 동일 쿼리로 독립 재확인해 일치를 확인했다(`600671_Overview.md` §7 (b) 상세). Stage 5 TestPlan(§1.1)에서 다시 한번 재확인됨.

(c) `call_next_waiting_customer()`의 실호출자 0건(고아 함수) — GRANT 부여 후에도 배선 전까지는 도달 불가능한 상태로 남는다. 배선 여부는 별도 판단 필요.

(d) `call_next_waiting_customer()`의 "(가칭)" 명칭 미확정 — 이번 워크패킷은 다루지 않는다.

(e) `call_waiting_customer()`의 `PUBLIC` EXECUTE 권한이 한 번도 REVOKE된 적 없다 — `authenticated` GRANT와 별개의 보안 공백. `0115` 작성 당시의 레거시 관행(같은 grants 블록의 다른 8개 함수도 동일 패턴)에 가까운 문제로 판단해 이번 워크패킷 범위에서 명시적으로 분리했다 — 별도 hardening 워크패킷 후보로 기록.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation. **자기승인 절대 불가 — 이 문서를 작성한 세션/에이전트는 이 섹션을 체크할 수 없다. 실제 정영석님이 직접 체크해야 한다.**

☑ I approve `catchmenu_pos._record_waiting_call(...)` receiving `REVOKE ALL FROM PUBLIC`
  only, with no `GRANT` to any role — matching the `0163`/`_resolve_dining_table_by_number()`
  precedent, since this function is called exclusively via internal `SECURITY DEFINER`
  invocation and never directly by a client.

☑ I approve `catchmenu_pos.call_next_waiting_customer(...)` receiving `REVOKE ALL FROM
  PUBLIC` followed by `GRANT EXECUTE TO authenticated` — matching the `0050:714-719`
  precedent for its own predecessor `call_next_waiting()`.

☑ I approve that `catchmenu_pos.call_waiting_customer(...)` is explicitly **not** touched
  by this contract — its own `PUBLIC` EXECUTE gap (Open Item (e)) remains unresolved and
  is deferred to a separate future hardening workpacket.

☑ I approve that `upsert_menu_core()`/`sync_menu_option_*_core()` (Open Item (a)),
  `call_next_waiting_customer()`'s orphan-caller status (Open Item (c)), and its
  unconfirmed final name (Open Item (d)) remain explicitly out of scope for this contract.

☑ I approve the migration number `0167` (or Stage 8's re-confirmed next-available number).

(승인날짜: 2026-07-18)

## §10 Approval state

**APPROVED (2026-07-18).** All five boxes in §9 were checked by the Human owner (정영석) with the approval date recorded. Stage 8 implementation is authorized within this ChangeContract's exact Allowed/Forbidden boundary.

## §11 Final Audit (Stage 11, Claude)

**Implementation Verdict: ACCEPT (2026-07-18)**
**System Security Verdict: ACCEPT_WITH_HIGH_PRIORITY_OPEN_ITEM**

이 ACCEPT는 승인된 함수 실행 권한(ACL) 교정만을 인증한다.
tenant/store 직원 인가(authorization) 문제를 해결하거나
안전하다고 인증하는 것이 아니다.

0167이 승인된 ACL 변경을 정확히 구현했음을 확인한다:
- _record_waiting_call()은 더 이상 PUBLIC이 실행할 수 없다.
- call_next_waiting_customer()는 authenticated는 실행 가능,
  anon은 불가능하다.
- call_waiting_customer()는 승인된 경계대로 무변경이다.

핵심 주장 재도출 확인 (raw 검증 결과에서 직접 재도출):
- ACL 교정이 설계(600671/600672) 그대로 정확히 구현됨 - Cursor+
  Claude Code 독립 재현 완전 일치.
- SECURITY DEFINER 내부호출 원리(0163 선례)가 실제 non-superuser
  authenticated 역할 전환 상태에서 재확인됨.
- call_waiting_customer() 완전 무변경 - proacl::text byte-
  identical 확인.
- boundary - 7개 파일 전부 0 diff.

**Stage 11B(ChatGPT Blind Audit) + 11C(충돌분석) 결론:**
블라인드 역설계와 Claude의 설계/감사는 핵심 사실관계(세 함수의
아키텍처, call_waiting_customer()의 PUBLIC EXECUTE 위험)에서
거의 완전히 일치했다. 유일한 충돌은 판정 범위였다 - Claude는
"승인된 0167 변경이 정확히 구현됐는가"를, ChatGPT는 "세 함수가
구성하는 전체 권한 구조가 안전한가"를 물었다. 두 질문 모두
정당하며, 이번 워크패킷은 전자에 대해서만 답한다.

Cursor의 후속 전수조사(waiting_call_caller_identity_
verification)는 이 문제가 3함수만이 아니라 0115의 6개 mutator
RPC 및 order/payment/admin 도메인 전반에 걸친 구조적 결여임을
확인했다. ChatGPT+제미나이 교차검증 결과, 이번 0167 워크패킷에
이 문제를 섞지 않고 별도 프로그램으로 승격하기로 결정했다.

**Open Items (기존 4개 + 신규 1개, 범위 확장):**

1. upsert_menu_core()/sync_menu_option_*_core() ACL 갭(a) -
   별도 워크패킷(menu_core_grant_correction).
2. call_next_waiting_customer()의 고아 함수 상태(c) - GRANT
   후에도 여전히 실호출자 0건.
3. call_next_waiting_customer()의 "(가칭)" 명칭 미확정(d).
4. call_waiting_customer()의 PUBLIC EXECUTE 잔존(e) - 아래 5번
   프로그램의 파일럿 대상으로 흡수.
5. **[신규, PROGRAM-LEVEL SECURITY FINDING으로 승격]** 호출자-
   tenant/store 소속 인가(authorization) 검증이 이 프로젝트
   전반(waiting 6개 mutator RPC 포함, order/payment/admin
   도메인도 동일 패턴)에 구조적으로 결여됨. 단순 Open Item이
   아니라 별도 프로그램(가칭 caller_authorization_foundation)
   으로 즉시 착수 결정 - waiting 도메인을 첫 파일럿으로 적용
   후 확장.

## §12 Human Merge/Release

담당: Human (정영석님)

상태: READY_FOR_HUMAN_MERGE

===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md] =====
# 600681 Overview — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Domain: `600600_waiting_order_session`
- Stage: 4 (Overview/Logic 설계) — 이 문서에서 `.sql` 생성/수정 없음
- Status: Stage 4 진행 — Stage 5(TestPlan/ChangeContract) 대기
- Owner role: Claude Code (설계), Human 결정 반영
- Created: 2026-07-19

## 1. Background

`catchmenu_pos.pre_order_while_waiting()`(원본 `0115_create_waiting_pipeline_rpc.sql`)은 waiting 파이프라인의 **phantom-column 교정 캠페인(0160/0163/0164)에서 유일하게 제외된 다섯 번째 형제 함수**다. 제외는 우연이 아니라 명시적이었다 — `0163_seat_waiting_customer_facade_correction.sql` 30번째 줄 Non-goals에 `pre_order_while_waiting()`이 "수정하지 않는다"로 적혀 있다.

그 결과 이 함수는 현재 라이브 스키마 기준 **실행 즉시 크래시**하는 상태로 남았다. Fable 블라인드 Pass A(슬라이스04, `601335_..._Slice04.md` §4-1/§4-2)가 이를 독립 발견했고, Cursor가 라이브 스키마 대조로 실증했으며, ChatGPT+제미나이 교차검증으로 처리 방향이 확정됐다. 확인된 결함:

1. **`orders` INSERT — 존재하지 않는 `order_source` 컬럼 참조** → 실행 시 PostgreSQL `42703 undefined_column` 크래시.
2. **`order_type = 'TABLE'`** → `chk_order_type` 허용집합(`DINE_IN`/`TAKEOUT`/`DELIVERY`/`KIOSK`/`STAFF_ORDER`)에 없어 `23514 check_violation`. (1번 크래시가 먼저 나므로 실행상으론 후순위지만, 컬럼 결함을 고쳐도 남는 독립 위반.)
3. **`order_items` INSERT — `unit_price`/`subtotal`/`item_options`** = 실제 컬럼(`unit_price_snapshot`/`item_amount`/`selected_options`) 이름과 불일치. 또한 NOT NULL인 `menu_code_snapshot`을 아예 넣지 않는다.
4. **`order_sessions` UPDATE — `pre_order_amount` 컬럼 참조** = 그 컬럼은 존재하지 않는다. (형제 교정본들은 이 값을 `orders.final_amount` LEFT JOIN으로 파생한다.)
5. **PUBLIC(anon) EXECUTE 노출** — proacl `=X/postgres,...`. 형제 `create_pre_order()`는 `authenticated`로 잠겨 있으나 이 함수만 PUBLIC 잔존.

실호출자 0건(라이브 `orders`/`order_items`/`kds_tickets`에 이 함수가 만든 흔적 없음)이라 운영 사고는 아직 없었으나, MVP 대기-중-사전주문 경로의 정본 함수가 호출 불가 상태다.

## 2. 확정된 방향 (Human 결정 — 재논의 금지)

- **이 함수(A안: "대기 중 즉석 사전주문")를 MVP 정본 경로로 확정**한다.
- `create_pre_order()`/`confirm_pre_order_arrival()`(B안: 예약형)의 상태게이트 모순(§5.4 참조)은 **이번에 손대지 않는다** — 별도 후속 재설계 프로그램(공통 Pre-order Core + 2 facade)으로 이월.
- 이번 워크패킷은 **순수 "phantom 컬럼 제거"만** 수행한다 — 0160/0163/0164와 **동일한 패턴 그대로** 적용. 새 기능·새 상태전이·새 조건 로직을 추가하지 않는다.

## 3. Scope

### In scope (이번 워크패킷)
- `pre_order_while_waiting()` 한 함수의 `orders` INSERT / `order_items` INSERT / `order_sessions` UPDATE에서 phantom 컬럼 제거 및 실제 컬럼으로 정정.
- `order_type = 'TABLE'` → 유효 enum 값으로 정정.
- PUBLIC EXECUTE → `authenticated`로 잠금(REVOKE ALL FROM PUBLIC + GRANT authenticated).
- 함수 시그니처는 **불변**(호출측/기존 grant/향후 core 이관 편의를 위해).

### Out of scope (명시적 비목표)
- `create_pre_order()` / `confirm_pre_order_arrival()` / `bind_table_to_session()` **수정 금지**. 상태게이트 모순은 이번 범위 아님.
- "공통 Pre-order Core" 재설계 **시작 금지**.
- 두 사전주문 경로의 `conditions_met` 조건 개수 차이(A안 6종 vs create_pre_order 7종), `order_status` 차이(A안 `CONFIRMED` vs create_pre_order `PENDING`), 주문번호 스킴 차이(`W###` vs `P-####`) — 전부 **후속 core 재설계로 이월**(§6 Open Items).
- KDS 티켓 INSERT는 이미 실제 컬럼만 쓰므로(§5.3) 손대지 않는다.
- `.sql` 파일 생성/수정(이번은 Stage 4 설계만).

## 4. 확인 완료 사항 (설계 전 검증)

이번 설계 전에 다음을 실제 원문/스키마로 대조 확인했다:

- **4-1. order_type 정정 값 = `'DINE_IN'`.** 0160/0163은 `orders`를 INSERT하지 않으므로 그 자체가 직접 선례는 아니다. 대신 **동일 의미의 형제 `create_pre_order()`(0051)가 `order_type='DINE_IN'`, `order_channel='TABLE_QR'`을 쓴다.** 대기 중 사전주문도 결국 매장 내 식사(dine-in)이므로 `'DINE_IN'`이 문맥상 정확한 값이다. (`order_channel`은 §5.5에서 별도 판단.)
- **4-2. order_items 실제 컬럼명(0051/라이브 스키마 대조):** `menu_code_snapshot`(NOT NULL, 기본값 없음), `menu_name_snapshot`, `unit_price_snapshot`, `quantity`, `item_amount`(= `unit_price_snapshot*quantity + options_amount`, `chk_order_item_amount`), `selected_options`(jsonb 배열), `options_amount`(기본 0), `kitchen_zone_snapshot`, `estimated_minutes_snapshot`, `is_kds_required_snapshot`, `item_status`. → phantom `unit_price`→`unit_price_snapshot`, `subtotal`→`item_amount`, `item_options`→`selected_options`. **추가로 `menu_code_snapshot`을 반드시 채워야 하며**, 이를 위해 함수 내 `menus` SELECT에 `menu_code`(및 KDS 파리티를 위한 `estimated_minutes`)를 포함해야 한다(§5.2).
- **4-3. pre_order_amount 파생 선례 = 0160 LEFT JOIN + 사전주문 판정은 pre_order_created_at.** 형제 교정본(seat_waiting_customer/cancel_waiting)은 `order_sessions os LEFT JOIN orders o ON o.id = os.order_id` 로 `o.final_amount as pre_order_amount`를 파생하고, **사전주문 존재 여부는 `os.pre_order_created_at is not null`로 판정**한다. 그런데 현재 `pre_order_while_waiting()`은 세션 UPDATE에서 **`order_id`도, `pre_order_created_at`도 설정하지 않는다**(§5.1의 핵심 발견). 따라서 "pre_order_amount 참조를 0160 패턴으로 교체"의 필수 귀결로 세션 UPDATE에 **두 컬럼을 함께 추가**한다:
  - **(C1-a) `order_id = v_order_id`** — 없으면 LEFT JOIN이 `os.order_id = null`이라 pre_order_amount를 `null`로 읽는다.
  - **(C1-b) `pre_order_created_at = now()`** — 없으면 `has_pre_order`가 항상 false로 잡혀, (a) seat_waiting_customer의 사전주문 안내 분기, (b) cancel_waiting의 HOLD KDS 티켓 취소 분기가 작동하지 않는다(HOLD 티켓 방치).
  두 값 모두 형제 `create_pre_order()`(0051)가 세션에 세팅하는 값과 일치한다(선례 일치). ※ create_pre_order가 함께 세팅하는 `pre_order_expires_at`/`order_confirmed_at`/`session_status='ORDER_CONFIRMED'`는 예약형(B안)의 만료·확정·상태게이트 개념이므로 A안엔 추가하지 않는다(범위 밖).
- **4-4. grant 선례 = 0167.** `0167_record_waiting_call_grant_correction.sql`이 `revoke all ... from public` + `grant execute ... to authenticated` 패턴을 확립했다. 형제 `create_pre_order()`도 `authenticated`(0051에서 명시 revoke public+grant authenticated). 이 함수는 "고객이 대기 중 직접 메뉴를 담는" 개념이므로 공개용이 맞고, `authenticated` 공개가 정확하다(§5.5).
- **4-5. 시그니처 불변 근거 = 0164.** 0164는 "네 함수의 public 시그니처가 0115와 동일하므로 새 GRANT/REVOKE 불필요"라고 명시했다. 시그니처를 그대로 두면 (a) 호출측 무영향, (b) 향후 공통 core 이관 시 facade 시그니처를 그대로 재사용 가능. 본 워크패킷도 시그니처 불변 원칙을 따른다(단, PUBLIC→authenticated 변경이 목적이므로 GRANT/REVOKE는 이번엔 필요 — 0164와 달리 권한 자체를 바꾸기 때문).

## 5. 설계 요지 (상세는 600682_Logic)

- **§5.1 orders INSERT 정정 + 세션 링크**: `order_source` 컬럼/값 제거, `order_type` `'TABLE'`→`'DINE_IN'`. 세션 UPDATE에 `order_id`/`pre_order_created_at` 추가(§5.3).
- **§5.2 order_items INSERT 정정**: 실제 컬럼명으로 교체 + `menu_code_snapshot` 추가 + SELECT에 `menu_code`/`estimated_minutes` 포함. `item_amount`/`options_amount` 정합성 유지. 카트 키 `v_item->'options'`는 유지(C2, §6-e).
- **§5.3 order_sessions UPDATE 정정**: `pre_order_amount = ...` 라인 삭제(파생으로 대체), `session_type='PRE_ORDER'` 유지, **`order_id = v_order_id`(C1-a)** 및 **`pre_order_created_at = now()`(C1-b)** 추가. `session_status`/`pre_order_expires_at`/`order_confirmed_at`은 미변경.
- **§5.4 (참고, 비수정) 상태게이트 모순**: create_pre_order 경로의 문제는 이월. A안(이 함수)은 세션 status를 바꾸지 않으므로 bind_table_to_session의 게이트와 충돌하지 않는다 — 이것이 A안을 정본으로 택한 실무적 이유 중 하나.
- **§5.5 GRANT/REVOKE**: `revoke all on function ... from public` + `grant execute ... to authenticated`. `order_channel`은 기본값(`KIOSK`) 유지 vs `TABLE_QR` 정렬 — Open Item으로 남김(§6-c).

## 6. Open Items (후속 이월, 이번 미해결)

- **(a) [최우선/후속 프로그램] 공통 Pre-order Core 재설계**: create_pre_order(B: 예약형)와 pre_order_while_waiting(A: 즉석형)을 공통 core + 2 facade로 통합. 그 과정에서 상태게이트 모순(§5.4), conditions_met 조건 개수 차이, order_status/주문번호 스킴 차이를 일괄 정리. 본 워크패킷은 A를 "이관 가능한 최소 정상 함수"로 만들어 두는 것이 목적.
- **(b) create_pre_order→confirm_pre_order_arrival 상태게이트 모순**: `create_pre_order`가 세션을 `ORDER_CONFIRMED`로 두는데 `bind_table_to_session`은 이를 bindable 상태로 인정하지 않음. 별도 워크패킷 필요.
- **(c) order_channel 값 정렬**: 이 함수는 order_channel을 명시하지 않아 기본 `'KIOSK'`가 된다. 형제 create_pre_order는 `'TABLE_QR'`. 대기-중-사전주문의 실제 채널 의미 확정은 (a) core 재설계에서. 이번엔 phantom 결함이 아니므로 기본값 유지(변경 시 behavior change라 범위 밖).
- **(d) conditions_met 형상 통일**: A안(payment_confirmed/kds_release_authorized/waiting_session_id/wait_number/order_source/release_trigger)과 create_pre_order(7-조건 arrived/table_confirmed/... 형상)의 KDS 조건 스키마 차이. core 재설계로 이월.
- **(e) [C2] 카트 JSON 키 불일치**: 두 사전주문 경로의 카트 입력 API 계약이 다르다 — A안 `pre_order_while_waiting()`은 옵션을 `v_item->'options'`로, B안 `create_pre_order()`(0051)는 `v_item->'selected_options'`로 읽는다. 이번 워크패킷은 phantom 제거만이므로 A안의 `'options'` 키를 **그대로 유지**한다(키 변경은 A안 호출측 입력 계약을 깨는 behavior change). 두 경로의 카트 키 통일은 공통 Pre-order Core 재설계(Open Item a)에서 정리 대상. (Cursor 검증 C2로 확인·기록.)

## Snapshot Decision

- 2026-07-19: Fable Pass A(slice04)가 발견하고 Cursor 실증·ChatGPT+제미나이 교차검증으로 확정된 `pre_order_while_waiting()` phantom 결함을, 0160/0163/0164와 동일한 "순수 phantom 제거" 패턴으로 정정하는 워크패킷 `600680`을 개설했다. 설계 전 4가지 사실(order_type='DINE_IN' 선례, order_items 실제 컬럼, pre_order_amount 파생을 위한 order_id 연결 필요, grant=0167 선례)을 원문 대조로 확인했다. 상태게이트 모순과 공통 core 통합은 명시적으로 이월(Open Items a/b). Stage 5(TestPlan/ChangeContract)로 진행 대기.
- 2026-07-19 (정정, Cursor 검증 반영): **C1** — 세션 UPDATE에 `pre_order_created_at = now()`를 추가(§4-3 C1-b, §5.3). `order_id`와 동일 근거 구조의 필수 귀결로, 형제 교정본이 `has_pre_order`를 `pre_order_created_at is not null`로 판정하고 그에 따라 cancel_waiting이 HOLD KDS 티켓을 취소하기 때문 — 없으면 이 함수의 사전주문이 has_pre_order=false로 잡혀 취소 시 HOLD 티켓이 방치된다. **C2** — 두 사전주문 경로의 카트 옵션 키 불일치(A안 `options` vs B안 `selected_options`)를 동작 변경 없이 유지로 확정하고 Open Item e로 추가했다. 두 정정 모두 함수 시그니처·상태전이는 여전히 불변.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md] =====
# 600682 Logic — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 4 (설계) — `.sql` 생성/수정 없음
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

이 문서는 `catchmenu_pos.pre_order_while_waiting()`의 phantom 컬럼을 제거하는 정확한 before→after 매핑을 규정한다. 함수의 **시그니처·제어흐름·검증 로직·알림·ledger 이벤트·KDS 티켓 INSERT는 변경하지 않는다.** 오직 아래 §1~§4의 4개 지점만 정정한다.

대상 함수 시그니처 (불변):
```
catchmenu_pos.pre_order_while_waiting(
  p_tenant_id uuid, p_store_id uuid, p_session_id uuid,
  p_cart_items jsonb, p_locale text default 'ko',
  p_correlation_id text default null
) returns jsonb  -- SECURITY DEFINER, plpgsql, volatile
```

## §1. `menus` SELECT 확장 (order_items 정정의 선행 조건)

현재 두 개의 `menus` SELECT가 `menu_code`/`estimated_minutes`를 뽑지 않는다. order_items 정정(§3)에서 `menu_code_snapshot`(NOT NULL)과 `estimated_minutes_snapshot`이 필요하므로, **두 번째 루프의 SELECT**(order_items를 만드는 루프)에 컬럼을 추가한다.

**Before** (현재):
```sql
select id, menu_name, price,
       is_kds_required, kitchen_zone
into v_menu
from catchmenu_pos.menus
where id = (v_item->>'menu_id')::uuid ...
```
**After**:
```sql
select id, menu_code, menu_name, price,
       is_kds_required, kitchen_zone, estimated_minutes
into v_menu
from catchmenu_pos.menus
where id = (v_item->>'menu_id')::uuid ...
```
- 근거: 형제 `create_pre_order()`(0051)가 동일 SELECT에서 `menu_code`/`estimated_minutes`를 뽑아 order_items 스냅샷에 넣는다.
- 첫 번째 루프(금액 계산/품절 확인)는 `menu_code`가 불필요하므로 변경하지 않는다.

## §2. `orders` INSERT 정정

**Before** (현재 — phantom):
```sql
insert into catchmenu_pos.orders (
  tenant_id, store_id,
  session_id, order_number,
  order_type, order_status,
  order_source,                 -- ❌ 존재하지 않는 컬럼 (42703)
  total_amount, final_amount,
  ordered_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  p_session_id, v_order_number,
  'TABLE', 'CONFIRMED',         -- ❌ 'TABLE'은 chk_order_type 위반 (23514)
  'PRE_ORDER',                  -- ❌ order_source 값
  v_total_amount, v_total_amount,
  now(),
  v_business_day, v_timezone
) returning id into v_order_id;
```
**After** (정정):
```sql
insert into catchmenu_pos.orders (
  tenant_id, store_id,
  session_id, order_number,
  order_type, order_status,
  total_amount, final_amount,
  ordered_at,
  business_day, business_timezone
) values (
  p_tenant_id, p_store_id,
  p_session_id, v_order_number,
  'DINE_IN', 'CONFIRMED',       -- ✅ 'TABLE' → 'DINE_IN' (create_pre_order 선례)
  v_total_amount, v_total_amount,
  now(),
  v_business_day, v_timezone
) returning id into v_order_id;
```
변경 요약:
- `order_source` 컬럼 및 값 `'PRE_ORDER'` **제거**(컬럼 미존재).
- `order_type` `'TABLE'` → **`'DINE_IN'`**(4-1 근거: create_pre_order 0051).
- `order_status = 'CONFIRMED'` **유지**(유효 enum, 상태 의미 변경은 범위 밖 — Overview §6-a로 이월).
- `session_id = p_session_id` 이미 세팅됨(orders→session FK). **유지.**
- `order_channel`은 이 INSERT에 없어 기본 `'KIOSK'`가 된다. 이번 미변경(Overview §6-c). "사전주문 출처=PRE_ORDER"의 의미는 `order_source` 제거로 사라지지만, 그 정보는 세션 `session_type='PRE_ORDER'`(§4)와 KDS `conditions_met.order_source`(기존 유지)에 이미 담겨 있어 손실 없음.

## §3. `order_items` INSERT 정정

**Before** (현재 — phantom):
```sql
insert into catchmenu_pos.order_items (
  tenant_id, store_id,
  order_id, menu_id,
  menu_name_snapshot,
  quantity, unit_price, subtotal,   -- ❌ unit_price/subtotal 미존재
  item_options                      -- ❌ item_options 미존재
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_menu.id,
  v_menu.menu_name,
  (v_item->>'quantity')::int,
  v_menu.price,
  v_menu.price * (v_item->>'quantity')::int,
  coalesce(v_item->'options', '[]'::jsonb)
);
```
**After** (정정):
```sql
insert into catchmenu_pos.order_items (
  tenant_id, store_id,
  order_id, menu_id,
  menu_code_snapshot, menu_name_snapshot,   -- ✅ menu_code_snapshot 추가 (NOT NULL)
  unit_price_snapshot, quantity, item_amount,
  selected_options, options_amount,
  kitchen_zone_snapshot,
  estimated_minutes_snapshot,
  is_kds_required_snapshot
) values (
  p_tenant_id, p_store_id,
  v_order_id, v_menu.id,
  v_menu.menu_code, v_menu.menu_name,
  v_menu.price,
  (v_item->>'quantity')::int,
  v_menu.price * (v_item->>'quantity')::int,  -- item_amount = unit_price_snapshot*quantity + options_amount(0)
  coalesce(v_item->'options', '[]'::jsonb),
  0,                                          -- options_amount
  v_menu.kitchen_zone,
  v_menu.estimated_minutes,
  v_menu.is_kds_required
);
```
컬럼 매핑:
| Phantom (before) | 실제 컬럼 (after) | 비고 |
|---|---|---|
| `unit_price` | `unit_price_snapshot` | |
| `subtotal` | `item_amount` | `chk_order_item_amount`: `item_amount = unit_price_snapshot*quantity + options_amount` |
| `item_options` | `selected_options` | jsonb 배열, `chk_selected_options_array` |
| (없음) | `menu_code_snapshot` | **NOT NULL, 기본값 없음** → 반드시 추가(§1에서 SELECT 확장) |
| (없음) | `options_amount` | `0` 명시(item_amount 정합성) |
| (없음) | `kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` | create_pre_order 파리티. `is_kds_required_snapshot`/`item_status`는 기본값(true/`PENDING`)이 있으나 스냅샷 일관성을 위해 명시 |
- `allergen_displayed`/`item_status` 등 기본값 있는 컬럼은 생략 가능(기본값 사용) — create_pre_order와 동일 최소셋.
- 옵션 금액 계산은 이번 범위 밖(현재 함수는 옵션 금액을 계산하지 않음). `options_amount=0` 유지로 `item_amount` 정합성만 보장. 옵션가 반영은 core 재설계(Open Item a).
- **C2 — 카트 JSON 키 불일치(동작 변경 없이 유지).** `selected_options` 값을 이 함수는 `coalesce(v_item->'options', ...)`로 읽는데(0115 원문), 형제 `create_pre_order()`(0051)는 같은 자리를 `coalesce(v_item->'selected_options', ...)`로 읽는다. 즉 **두 사전주문 경로의 카트 입력 API 계약이 다르다**(A: `options` 키 / B: `selected_options` 키). 이번 워크패킷은 phantom 제거만 하므로 **`v_item->'options'`를 그대로 둔다**(키를 바꾸면 A안 호출측의 입력 계약이 깨지는 behavior change). 두 경로의 카트 키 통일은 공통 Core 재설계로 이월(Overview §6-e).

## §4. `order_sessions` UPDATE 정정 + order_id 연결

**Before** (현재 — phantom):
```sql
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  pre_order_amount = v_total_amount,   -- ❌ 존재하지 않는 컬럼
  updated_at = now()
where id = p_session_id;
```
**After** (정정):
```sql
update catchmenu_pos.order_sessions
set
  session_type = 'PRE_ORDER',
  order_id = v_order_id,               -- ✅ C1과 함께 세션↔주문 연결 (0160 파생 성립 조건)
  pre_order_created_at = now(),        -- ✅ C1: has_pre_order 판정 성립 조건
  updated_at = now()
where id = p_session_id;
```
변경 요약:
- `pre_order_amount = v_total_amount` **제거**(컬럼 미존재). 금액은 저장하지 않고 `orders.final_amount`에서 파생한다(0160 선례: 읽는 쪽이 `order_sessions os LEFT JOIN orders o ON o.id = os.order_id` 로 `o.final_amount as pre_order_amount`).
- **`order_id = v_order_id` 추가 (핵심).** 근거: 현재 함수는 세션에 `order_id`를 세팅하지 않아, phantom을 단순 제거만 하면 형제 교정본(seat_waiting_customer/cancel_waiting)의 LEFT JOIN이 `os.order_id = null`이라 pre_order_amount를 `null`로 읽게 된다. "pre_order_amount 참조를 0160 패턴으로 교체"의 필수 귀결로 세션→주문 링크를 세운다. create_pre_order(0051)도 세션에 `order_id`를 세팅한다(선례 일치).
- **`pre_order_created_at = now()` 추가 (C1, 핵심).** 근거: `order_id`와 **동일한 근거 구조**의 필수 귀결이다. 형제 교정본은 사전주문 여부를 **금액이 아니라 `os.pre_order_created_at is not null`로 판정**한다: (a) `seat_waiting_customer()`는 `has_pre_order := v_session.pre_order_created_at is not null`, (b) `cancel_waiting()`은 `if v_session.pre_order_created_at is not null then` HOLD KDS 티켓을 취소한다. 현재 함수는 이 컬럼을 세팅하지 않으므로, phantom만 제거하면 이 함수로 만든 사전주문은 **has_pre_order가 항상 false로 잡히고 취소 시 HOLD 티켓이 방치**된다. create_pre_order(0051)도 세션에 `pre_order_created_at = now()`를 세팅한다(선례 일치). ※ create_pre_order가 함께 세팅하는 `pre_order_expires_at`/`order_confirmed_at`/`session_status='ORDER_CONFIRMED'`는 **추가하지 않는다** — 그것들은 예약형(B안)의 만료·확정 개념이며, 즉석형(A안)에 도입하면 behavior change이자 §5.4/Open Item b의 상태게이트 영역을 건드리게 되어 범위 밖이다. 오직 `has_pre_order` 판정에 필요한 `pre_order_created_at`만 추가한다.
- `session_status`는 **변경하지 않는다**(현재 함수는 status를 안 바꿈). 이 무변경이 A안을 정본으로 택한 이유 중 하나 — bind_table_to_session의 게이트(WAITING/ARRIVAL_PENDING/ORDERING)와 충돌하지 않는다(Overview §5.4). status를 ORDER_CONFIRMED 등으로 바꾸는 것은 범위 밖(behavior change).

## §5. GRANT / REVOKE

현재 proacl: `=X/postgres,postgres=X/postgres,authenticated=X/postgres`(PUBLIC 포함). 0167 선례에 따라 PUBLIC을 회수하고 `authenticated`만 남긴다.

```sql
revoke all on function catchmenu_pos.pre_order_while_waiting(
  uuid, uuid, uuid, jsonb, text, text
) from public;

grant execute on function catchmenu_pos.pre_order_while_waiting(
  uuid, uuid, uuid, jsonb, text, text
) to authenticated;
```
- 근거: 형제 `create_pre_order()`(0051)가 `authenticated`. 이 함수는 "고객이 대기 중 직접 메뉴를 담는" 공개 개념이므로 `authenticated` 공개가 정확(내부 헬퍼가 아니므로 `_record_waiting_call`식 owner-only는 아님).
- `CREATE OR REPLACE`는 기존 ACL을 보존하므로, PUBLIC 회수를 위해 위 REVOKE를 **명시적으로** 넣어야 한다(0164처럼 "grant 불필요"가 아님 — 이번은 권한 경계 자체를 바꾸는 것이 목적).

## §6. 시그니처 불변 원칙 (향후 core 이관 대비)

- 함수 시그니처 6-파라미터를 그대로 유지한다. 이유:
  1. 호출측(엣지/앱, 있다면) 무영향.
  2. 향후 "공통 Pre-order Core + 2 facade" 재설계 시, 이 함수를 **얇은 facade로 축소**해 core에 위임하기 쉽다(시그니처가 안정적이면 facade 계약이 그대로 유지됨).
  3. 0164가 확립한 "public 시그니처 불변 → 호출 계약 안정" 원칙과 일치.
- 따라서 이번 정정은 `CREATE OR REPLACE FUNCTION`(동일 시그니처) + REVOKE/GRANT 형태가 된다(Stage 8에서 실제 마이그레이션 작성 시).

## §7. Migration placement (Stage 8 참고, 이번 미작성)

- 이번 문서는 설계만. 실제 정정은 Stage 8에서 **다음 순번 forward 마이그레이션**(현재 최신 `0167` 다음, 즉 Stage 8 시점의 최소 미사용 번호)으로 작성한다. 기존 0115/0160/0163/0164 원문은 **수정하지 않는다**(forward-only 원칙; 0163:30이 "0115 source text 수정 금지"를 이미 확립).
- `CREATE OR REPLACE FUNCTION catchmenu_pos.pre_order_while_waiting(...)` 전체 재정의 + §5 REVOKE/GRANT 로, 단일 마이그레이션.
- 새 message_catalog/error_codes 항목 불필요(기존 에러키 재사용, 새 사용자 메시지 없음).

## §8. Non-goals (재확인)

- `create_pre_order()` / `confirm_pre_order_arrival()` / `bind_table_to_session()` 수정 금지.
- 상태게이트 모순 해결 금지(Open Item b).
- 공통 Pre-order Core 재설계 금지.
- KDS 티켓 INSERT 로직·`conditions_met` 형상 변경 금지(이미 실제 컬럼만 사용; 형상 통일은 Open Item d).
- 옵션 금액 계산 추가 금지(`options_amount=0` 유지).
- order_status/order_channel/주문번호 스킴 변경 금지(behavior change, 범위 밖).
- 카트 JSON 키 `v_item->'options'` 변경 금지(C2 — A안 입력 계약 유지, Open Item e).
- `pre_order_expires_at`/`order_confirmed_at`/`session_status` 세팅 금지(C1은 `pre_order_created_at`만; 만료·확정·상태 개념 추가는 범위 밖).

## Snapshot Decision

- 2026-07-19: `pre_order_while_waiting()`의 4개 phantom 지점(orders.order_source, order_type='TABLE', order_items 3컬럼, order_sessions.pre_order_amount)에 대한 정확한 before→after 매핑과 GRANT/REVOKE를 확정했다. 설계 중 발견한 핵심 부수사항 — **현재 함수가 세션에 `order_id`를 세팅하지 않아 pre_order_amount 파생(0160 패턴)이 성립하지 않는다** — 을 §4에 명시하고, phantom 제거의 필수 귀결로 `order_id = v_order_id` 추가를 설계에 포함했다. 시그니처·상태전이·조건 로직은 불변. Stage 5(TestPlan/ChangeContract) 진행 대기.
- 2026-07-19 (정정, Cursor 검증 반영): **C1** — 세션 UPDATE에 `pre_order_created_at = now()` 추가를 §4에 반영했다. `order_id`와 동일한 근거 구조의 필수 귀결로, 형제 교정본이 `has_pre_order`를 `pre_order_created_at is not null`로 판정하고(seat_waiting_customer) 그 값에 따라 HOLD KDS 티켓을 취소(cancel_waiting)하기 때문. 이 컬럼이 없으면 이 함수로 만든 사전주문은 has_pre_order가 항상 false로 잡히고 취소 시 HOLD 티켓이 방치된다. `pre_order_expires_at`/`order_confirmed_at`/`session_status`는 범위 밖으로 추가하지 않음(만료·확정·상태게이트 영역). **C2** — 카트 JSON 키 불일치(A안 `v_item->'options'` vs create_pre_order `v_item->'selected_options'`)를 §3에 동작 변경 없이 유지로 기록하고 Open Item e(Overview §6-e)로 이월했다.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md] =====
# 600683 TestPlan — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 5 (검증 계획)
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md), [600682_Logic](600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

## §0. 전제 / 픽스처

- 테스트 테넌트/매장: `tenant_id = 00000000-0000-0000-0000-000000000001`, `store_id = 00000000-0000-0000-0000-000000000002`(시드 존재).
- 대상 함수: `catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text)`.
- 세션 전제: `pre_order_while_waiting()`은 `session_status in ('WAITING','ARRIVAL_PENDING')`만 허용하므로, 테스트마다 그 상태의 `order_sessions` 픽스처를 새로 만든다(`session_type='WAITING'`, `wait_number` 부여).
- 메뉴 픽스처: `catchmenu_pos.menus`에 최소 1건 — `is_kds_required=true`, `menu_status='AVAILABLE'`, `kitchen_zone` 값 존재, `menu_code`/`price`/`estimated_minutes` 채워짐(order_items 스냅샷 컬럼 검증용).
- 카트 입력: 이 함수는 옵션을 `v_item->'options'`로 읽으므로(C2, 유지), 테스트 카트는 `[{"menu_id":"...","quantity":2,"options":[]}]` 형태.
- 실행 시점 기준: **정정(0168+) 적용 후**의 라이브 함수. §1은 정정 전 크래시를 참조로만 기술(정정 후 재현 안 됨을 확인).
- 격리: 모든 시나리오는 `begin; ... rollback;`으로 감싸 픽스처를 남기지 않는다. ACL(§6)은 `set local role`로 검증.

## §1. 정정 전 크래시 참조 (회귀 방지 기준선)

정정 전 함수는 다음 두 결함으로 실행이 불가능했다(설계 근거, 재현은 정정 전 스냅샷에서만 의미):
- `orders` INSERT의 `order_source` 컬럼 → `42703 undefined_column`.
- `order_type='TABLE'` → `chk_order_type` `23514 check_violation`.
- `order_items` INSERT의 `unit_price`/`subtotal`/`item_options`, `menu_code_snapshot` 누락 → `42703`/`23502`.
- `order_sessions` UPDATE의 `pre_order_amount` → `42703`.

**기대(정정 후):** 위 어떤 SQLSTATE도 발생하지 않는다.

## §2. Happy path — 정상 호출 성공 (크래시 없음 + 컬럼 정합)

절차:
1. WAITING 세션 픽스처 생성(wait_number=901).
2. `select catchmenu_pos.pre_order_while_waiting(tenant, store, :session_id, '[{"menu_id"::menu_id,"quantity":2,"options":[]}]'::jsonb, 'ko', 'test-600683-happy')`.
3. 반환 `success=true`, `order_id`/`order_number`/`kds_status='HOLD'` 확인.

검증(SELECT로 확인):
- `catchmenu_pos.orders`: 신규 1건, `order_type='DINE_IN'`(≠'TABLE'), `order_status='CONFIRMED'`, `session_id=:session_id`, `final_amount = price*2`. **`order_source` 컬럼 참조 없음**(컬럼 자체 부재이므로 INSERT가 성공했다는 것 자체가 증거).
- `catchmenu_pos.order_items`: 신규 1건, `menu_code_snapshot` NOT NULL로 채워짐, `unit_price_snapshot=price`, `item_amount = price*2`(`chk_order_item_amount` 통과), `selected_options='[]'::jsonb`, `options_amount=0`, `kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` 스냅샷 존재.
- `catchmenu_kds.kds_tickets`: 신규 1건, `kds_status='HOLD'`(기존 로직 유지).

기대: 전 항목 통과, SQLSTATE 오류 0건.

## §3. TEST_B / SEAT_PATTERN — order_id + pre_order_created_at 세팅 후 형제 함수 정상 작동

이 시나리오가 C1(order_id + pre_order_created_at)의 핵심 회귀 검증이다.

절차:
1. §2와 동일하게 pre_order_while_waiting 호출로 사전주문 생성.
2. 세션 직접 확인:
   - `order_sessions.order_id = :order_id` (C1-a, 세팅됨).
   - `order_sessions.pre_order_created_at is not null` (C1-b, 세팅됨).
   - `order_sessions.session_type = 'PRE_ORDER'`.
3. **SEAT_PATTERN**: `select catchmenu_pos.seat_waiting_customer(tenant, store, :session_id, 'A01', null, 'ko', 'test-600683-seat')`.
   - 기대: 반환 `data.has_pre_order = true`, `data.pre_order_amount = price*2`(orders.final_amount LEFT JOIN 파생이 `os.order_id` 덕분에 성립).
4. **TEST_B (취소 분기)**: 별도 세션으로 §2 재생성 후 `select catchmenu_pos.cancel_waiting(tenant, store, :session_id2, '테스트 취소', 'STAFF', null, 'ko', 'test-600683-cancel')`.
   - 기대: `pre_order_created_at is not null` 분기 진입 → 해당 주문의 `kds_status='HOLD'` 티켓이 `CANCELLED`로 전이. 반환 `pre_order_cancelled=true`.
   - 검증: `catchmenu_kds.kds_tickets where order_id=:order_id2` 의 `kds_status='CANCELLED'`.

기대: has_pre_order=true, amount 정상 파생, HOLD→CANCELLED 정상.

## §4. TEST_A — 비교군: pre_order_created_at 없는 세션 (C1 필요성 입증)

C1이 없으면(또는 사전주문을 하지 않은 세션이면) 형제 함수가 사전주문을 인식하지 못함을 대조로 확인한다.

절차:
1. `pre_order_while_waiting` 호출 **없이** WAITING 세션만 생성(`pre_order_created_at = null`, `order_id = null`).
2. `seat_waiting_customer(...)` 호출 → 기대: `has_pre_order = false`, `pre_order_amount = null`(order_id null → LEFT JOIN 매칭 없음).
3. 그 세션에 HOLD KDS 티켓이 (다른 경로로) 있다고 가정한 상태에서 `cancel_waiting(...)` → 기대: `pre_order_created_at is not null` 분기 미진입 → HOLD 티켓 **유지**(CANCELLED 안 됨).

기대: has_pre_order=false, HOLD 유지 — §3과의 대비로 "pre_order_created_at 세팅이 필수"임을 실증.

## §5. Non-goals 검증 — 세팅하면 안 되는 컬럼 확인

§2/§3의 사전주문 세션에 대해:
- `order_sessions.pre_order_expires_at IS NULL` (예약형 만료 개념 미도입).
- `order_sessions.order_confirmed_at IS NULL` (주문확정 시각 미세팅).
- `order_sessions.session_status` 가 pre_order_while_waiting 호출 **전 상태와 동일**('WAITING' 또는 'ARRIVAL_PENDING' 유지, `ORDER_CONFIRMED`로 바뀌지 않음).

기대: 세 값 모두 위와 같음. (하나라도 세팅되면 범위 위반 → FAIL.)

## §6. ACL — REVOKE/GRANT 검증

절차(정정 적용 후):
```sql
select
  has_function_privilege('anon',
    'catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text)', 'execute') as anon_exec,
  has_function_privilege('authenticated',
    'catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text)', 'execute') as auth_exec;
```
기대: `anon_exec = false`, `auth_exec = true`.

보강(byte-identical proacl, 0167 검증 방식): 정정 후 `pg_proc.proacl::text`가 `{postgres=X/postgres,authenticated=X/postgres}` 형태(선두 `=X` PUBLIC 엔트리 없음)인지 확인.

## §7. Boundary — 무변경 함수 0 diff

정정 전/후로 다음 함수들의 `pg_get_functiondef()`가 **완전 동일**(0 diff)해야 한다:
- `catchmenu_pos.create_pre_order(uuid,uuid,uuid,jsonb,text,text)`
- `catchmenu_pos.confirm_pre_order_arrival(uuid,uuid,uuid,uuid,text,uuid,text)`
- `catchmenu_pos.bind_table_to_session(uuid,uuid,uuid,uuid,text,uuid,text)`

또한 `pre_order_while_waiting`의 **시그니처(인자 목록·타입·개수)**가 정정 전후 동일해야 한다(6-파라미터 불변). `pg_get_function_identity_arguments()` 비교로 확인.

기대: 세 함수 정의 문자열 동일, pre_order_while_waiting 시그니처 동일(본문만 변경).

## §8. Acceptance Criteria

1. **§1/§2** 정정 후 정상 호출 시 42703/23514/23502 어떤 SQLSTATE도 발생하지 않고 `success=true`.
2. **§2** orders `order_type='DINE_IN'`, order_source 부재, order_items 실제 컬럼 정합(menu_code_snapshot 채워짐, item_amount 정합).
3. **§3(C1-a)** 세션 `order_id` 세팅 → seat_waiting_customer의 `pre_order_amount`가 orders.final_amount로 정상 파생.
4. **§3(C1-b)** 세션 `pre_order_created_at` 세팅 → seat의 `has_pre_order=true`, cancel_waiting의 HOLD→CANCELLED 분기 작동.
5. **§4** 비교군(pre_order_created_at 없음)에서 has_pre_order=false, HOLD 유지 — C1 필요성 대조 입증.
6. **§5** pre_order_expires_at/order_confirmed_at NULL, session_status 미변경(Non-goals 준수).
7. **§6** anon=false, authenticated=true, proacl에 PUBLIC 엔트리 없음.
8. **§7** create_pre_order/confirm_pre_order_arrival/bind_table_to_session 0 diff, pre_order_while_waiting 시그니처 불변.


===== BEGIN [docs/600000_implementation_lifecycle/600600_waiting_order_session/600680_pre_order_while_waiting_phantom_correction/600684_ChangeContract_Pre_Order_While_Waiting_Phantom_Correction.md] =====
# 600684 ChangeContract — Pre-Order While Waiting Phantom Correction

- Workpacket: `600680_pre_order_while_waiting_phantom_correction`
- Stage: 5 (변경 계약)
- Depends on: [600681_Overview](600681_Overview_Pre_Order_While_Waiting_Phantom_Correction.md), [600682_Logic](600682_Logic_Pre_Order_While_Waiting_Phantom_Correction.md), [600683_TestPlan](600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md)
- Created: 2026-07-19

## §0. 개요

`catchmenu_pos.pre_order_while_waiting()` 한 함수의 phantom 컬럼 제거 + 2개 필수 필드 추가 + PUBLIC 권한 회수. 0160/0163/0164/0167과 동일한 "순수 phantom 제거 + 권한 정정" 패턴. 새 기능·상태전이·조건 로직 없음.

## §1. 목적

현재 라이브 스키마 기준 실행 즉시 크래시(`42703`/`23514`)하는 MVP 대기-중-사전주문 정본 함수를, 실제 컬럼으로 정정해 호출 가능 상태로 복구한다. 동시에 형제 교정본(seat_waiting_customer/cancel_waiting)의 `has_pre_order`/HOLD-취소 분기가 작동하도록 세션 링크(order_id + pre_order_created_at)를 세우고, PUBLIC 노출을 authenticated로 잠근다.

## §2. Allowed (허용 변경)

1. `catchmenu_pos.pre_order_while_waiting(uuid, uuid, uuid, jsonb, text, text)` **본문만** `CREATE OR REPLACE`로 재정의:
   - `menus` SELECT(2번째 루프)에 `menu_code`/`estimated_minutes` 추가(600682 §1).
   - `orders` INSERT: `order_source` 컬럼/값 제거, `order_type` `'TABLE'`→`'DINE_IN'`(600682 §2).
   - `order_items` INSERT: `unit_price`→`unit_price_snapshot`, `subtotal`→`item_amount`, `item_options`→`selected_options`, `menu_code_snapshot`/`options_amount(0)`/`kitchen_zone_snapshot`/`estimated_minutes_snapshot`/`is_kds_required_snapshot` 추가(600682 §3).
   - `order_sessions` UPDATE: `pre_order_amount = ...` 제거, `order_id = v_order_id` 추가(C1-a), `pre_order_created_at = now()` 추가(C1-b)(600682 §4).
2. `revoke all on function catchmenu_pos.pre_order_while_waiting(uuid,uuid,uuid,jsonb,text,text) from public;` + `grant execute ... to authenticated;`(600682 §5).

그 외 함수 본문 요소(제어흐름, 검증 로직, notify_channel 알림, ledger 이벤트, KDS 티켓 INSERT, 반환 payload, i18n)는 **변경하지 않는다**.

## §3. Forbidden (금지)

- `catchmenu_pos.create_pre_order()` 수정 금지.
- `catchmenu_pos.confirm_pre_order_arrival()` 수정 금지.
- `catchmenu_pos.bind_table_to_session()` 수정 금지.
- 카트 JSON 키 통일 금지 — `v_item->'options'` 그대로 유지(C2, Open Item e).
- `pre_order_expires_at` / `order_confirmed_at` / `session_status` 세팅 금지(예약형 B안 전용 개념).
- 함수 시그니처(인자 목록·타입·개수·기본값) 변경 금지 — 6-파라미터 불변.
- `order_status`(='CONFIRMED') / `order_channel`(기본 'KIOSK') / 주문번호 스킴('W###') 변경 금지(behavior change).
- 옵션 금액 계산 추가 금지(`options_amount=0` 유지).
- 0115/0160/0163/0164 원문 마이그레이션 파일 수정 금지(forward-only).
- 스키마 컬럼 추가/변경 금지(이번은 함수 정정만).

## §4. 정확한 변경 위치

- 파일: Stage 8에서 신규 forward 마이그레이션(현재 최신 `0167` 다음 최소 미사용 번호, 예: `0168_pre_order_while_waiting_phantom_correction.sql`).
- 단일 마이그레이션 = `CREATE OR REPLACE FUNCTION catchmenu_pos.pre_order_while_waiting(...)` 전체 + §2-2 REVOKE/GRANT.
- 새 message_catalog/error_codes 항목 불필요(기존 에러키 재사용).

## §5. Migration / Rollback

- 적용: 신규 forward 마이그레이션 1건.
- 롤백: 이론상 이전(phantom) 정의로 되돌리는 것이나, 이전 정의는 실행 불가 상태였으므로 실질 롤백 가치 없음. 문제 발생 시 추가 forward 마이그레이션으로 대응(forward-only 원칙).
- Draft Mutability(§14.5): 이 마이그레이션이 Stage 12 Human Merge 전·보호 브랜치 병합 전·공유 환경 적용 전·타 워크패킷 의존 전이면 Draft로 자유 재편집 가능; 그 중 하나라도 발생하면 이후 수정은 새 forward 마이그레이션으로만.

## §6. Stop Conditions (중단 조건)

- 라이브 `pre_order_while_waiting`의 실제 시그니처가 설계 가정(6-파라미터: uuid,uuid,uuid,jsonb,text,text)과 다를 경우 → 중단, 재확인.
- `order_items`/`orders`/`order_sessions`의 실제 컬럼이 600682 §1~§4 가정과 다를 경우(예: `menu_code_snapshot`/`pre_order_created_at`/`order_id` 부재) → 중단, 스키마 재확인.
- `menus`에 `menu_code`/`estimated_minutes` 컬럼이 없을 경우 → 중단(order_items 스냅샷 불가).
- boundary 함수(create_pre_order/confirm_pre_order_arrival/bind_table_to_session) 정의가 정정 과정에서 변경될 경우 → 중단, 롤백.
- TestPlan §3(C1) 또는 §5(Non-goals) 실패 시 → 병합 중단.

## §7. 검증 근거

[600683_TestPlan](600683_TestPlan_Pre_Order_While_Waiting_Phantom_Correction.md) §1~§8. 핵심: §2(크래시 없음), §3(C1 order_id/pre_order_created_at → seat/cancel 정상), §4(비교군 대조), §5(Non-goals), §6(ACL), §7(boundary 0 diff).

## §8. Risk

- 낮음. 실호출자 0건(라이브 흔적 없음)이라 회귀 대상 실사용 트래픽 없음. 변경은 단일 함수 본문 + 권한. boundary 3함수 0 diff로 격리.
- 유일한 신중 지점: `order_id`/`pre_order_created_at` 추가가 형제 함수 분기를 "활성화"하므로, seat/cancel의 사전주문 분기가 이제 실제로 실행된다 — TestPlan §3에서 그 분기의 정상 작동을 명시 검증.

## §9. Human Approval

- [ ] §2 Allowed 범위(pre_order_while_waiting 본문 + REVOKE/GRANT만) 확인
- [ ] §3 Forbidden(3개 boundary 함수 무수정, 카트 키 유지, 3개 컬럼 미세팅) 확인
- [ ] C1(order_id + pre_order_created_at 추가) 필요성 및 근거 동의
- [ ] C2(카트 키 `options` 유지 + Open Item e 이월) 동의
- [ ] PUBLIC → authenticated 권한 정정 동의
- [ ] Open Items(a~e) 후속 이월 확인

## §10. Approval Decision

- 상태: PENDING (Human 승인 대기)
- 승인자:
- 승인일:

## §11. Open Items (이월)

600682 §6/§8 및 600681 §6의 (a)~(e) 전부 이번 범위 밖으로 이월:
- (a) 공통 Pre-order Core + 2 facade 재설계.
- (b) create_pre_order→confirm_pre_order_arrival 상태게이트 모순(ORDER_CONFIRMED vs bind 게이트).
- (c) order_channel 값 정렬(KIOSK vs TABLE_QR).
- (d) conditions_met 형상 통일(A 6종 vs B 7-조건).
- (e) 카트 JSON 키 통일(A `options` vs B `selected_options`).

## §12. Snapshot Decision

- 2026-07-19: 600681/600682(Cursor+Codex 이중 독립검증 완료) 설계를 그대로 인용해 Stage 5 TestPlan/ChangeContract를 작성했다. 허용 변경은 `pre_order_while_waiting()` 본문 정정(phantom 3종 제거 + order_type→DINE_IN + order_id/pre_order_created_at 2필드 추가) + REVOKE/GRANT로 한정. 3개 boundary 함수 무수정·카트 키 유지·3개 예약형 컬럼 미세팅을 금지 항목으로 명문화. Open Items (a)~(e) 이월. Human 승인 대기(§9/§10).
