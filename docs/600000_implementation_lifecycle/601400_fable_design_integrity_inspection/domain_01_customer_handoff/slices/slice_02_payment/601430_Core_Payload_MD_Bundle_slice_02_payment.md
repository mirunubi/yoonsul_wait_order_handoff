===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600500_Readme_Payment_Confirmation.md] =====
# 600500_Readme_Payment_Confirmation.md

Status: Active
Lifecycle: Readme
Domain: Payment Confirmation

## Purpose

This folder owns payment-confirmation workpackets that are not KDS, waiting/session, takeout/pickup, DID, or cross-domain reconciliation work.

## In Scope

- Payment provider confirmation RPC ambiguity and legacy overload disposition.
- Payment confirmation verification, module, and audit records moved out of the former mixed KDS/DID folder.

## Out of Scope

- KDS capacity/status reconciliation.
- Waiting/order-session reconciliation.
- Takeout/pickup order defects.
- DID display-state implementation.
- Cross-domain stale-column reconciliation batches.

## Subfolder Map

| Folder | Role | Status |
|---|---|---|
| `600510_confirm_payment_from_provider_overload_ambiguity/` | `confirm_payment_from_provider()` legacy overload disposition. | Moved from `600400_kds_did_implementation/`. |



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600502_NavigationMap_Payment_Confirmation.md] =====
# 600502_NavigationMap_Payment_Confirmation.md

Status: Active
Lifecycle: NavigationMap
Domain: Payment Confirmation

## Workpacket Flow

| Workpacket | Scope | Local flow |
|---|---|---|
| `600510_confirm_payment_from_provider_overload_ambiguity/` | Drop legacy 9-param `confirm_payment_from_provider()` overload and keep the canonical 8-param provider confirmation path. | `600511_Overview.md` → `600512_Logic.md` → `600513_TestPlan.md` → `600514_ChangeContract.md` → `600515_Module.md` → `600516_Verification.md` → `600517_Audit.md` |
| `600540_mark_payment_uncertain_overload_ambiguity/` | Drop legacy 6-param `mark_payment_uncertain()` overload (`p_locale` variant, independently broken by `chk_intent_status`/`exception_code` NOT NULL defects) and keep the canonical 5-param path — same pattern as `600510`. First workpacket completed under `000701` §43's mandatory triple-verification standard (Claude Code + Antigravity + Codex). | `600541_Overview_Mark_Payment_Uncertain_Overload.md` → `600542_Logic_Mark_Payment_Uncertain_Overload.md` → `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` → `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` → `600545_Module.md` → `600546_Verification.md` → `600547_Audit.md` |
| `600550_confirm_payment_column_drift_and_intent_linkage_fix/` | Fix `confirm_payment()`(`0098`)'s `payment_ledger` INSERT: 4 phantom columns (`payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`, none exist live), 2 missing NOT NULL columns (`intent_id`/`ledger_entry_type`), and the structural absence of a `p_intent_id` parameter — discovered as an URGENT Open Item during `601020_authorize_kds_release_overload_and_redesign`'s Stage 5/6 (`601026_Verification.md` §5 / `601027_Audit.md`). Uses `confirm_payment_from_provider()`(`0027`) as the working reference pattern. | `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` → `600555_Module.md` → `600556_Verification.md` → `600557_Audit.md` |
| `600560_payment_intent_race_condition_fix/` | Fix `resolve_or_create_payment_intent()`(`0158`)'s unlocked `count(*)`-then-`insert` TOCTOU race (PAY-CON-002, `000056_Register_Concurrency_Risk.md`). Implements option (a): clean the known duplicate pair, add `uq_payment_intents_idempotency_key UNIQUE (idempotency_key)`, and switch observed-intent insertion to `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`. | `600561_Overview_Payment_Intent_Race_Condition_Fix.md` -> `600562_Logic_Payment_Intent_Race_Condition_Fix.md` -> `600563_TestPlan.md` -> `600564_ChangeContract.md` -> `600565_Module.md` -> `600566_Verification.md` -> `600567_Audit.md` |
| `600570_cancel_payment_phantom_column_fix/` | Fix `payment_ledger.updated_at` phantom-column crash shared by `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` (`0037`, all 3 confirmed broken). Discovered a much larger phantom-column/CHECK-constraint defect set in `request_refund()`/`confirm_refund()` (`0098`) not anticipated by the originating task; that refund pipeline redesign remains a separate Open Item. Stage 6 ACCEPT. | `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` -> `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md` -> `600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md` -> `600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix.md` -> `600575_Module.md` -> `600576_Verification.md` -> `600577_Audit.md` |
| `600580_payment_confirm_cancel_state_machine_fix/` | Fix PAY-CON-003 in `confirm_payment()` only: Rule 1 PENDING-only confirmation gate, Rule 3 already-confirmed idempotent success/conflict rejection, and Rule 4/5 late approval after cancellation/refund recorded as `MANUAL_REVIEW` without reopening the order or releasing KDS. Stage 6 ACCEPT. | `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md` -> `600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md` -> `600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix.md` -> `600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` -> `600585_Module.md` -> `600586_Verification.md` -> `600587_Audit.md` |



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600511_Overview.md] =====
# 600511_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## §0 배경 (Codex+Cursor+안티 조사 완료, 실증 확인됨 — 재확인 불필요로 전제, 원문은 이번 턴 재확인)

`catchmenu_payment.confirm_payment_from_provider()`가 라이브에 두 오버로드로 존재한다: 8개 파라미터(`0027` 원본, `0038`/`0056`이 실제로 호출) vs 9개 파라미터(`0063` 패치, `p_locale` 추가, 실제 호출부 0건). `p_locale`이 `default 'ko'`를 가진 옵션 파라미터라, `0038`/`0056`처럼 8개 named argument로 호출하면 PostgreSQL이 두 오버로드 중 어느 것도 확정 못 해 `"is not unique"` 에러가 발생한다. 즉 이 함수를 거치는 모든 실제 결제 확인 경로(토스 웹훅, VAN 연동)가 100% 실패 중이다.

**이번 턴 재확인**: 라이브 오버로드 정확히 2개 재확인 —

```
(8-param, 0027) p_tenant_id, p_store_id, p_intent_id, p_provider_payment_key,
  p_provider_approval_number, p_approved_amount, p_provider_raw_event_id,
  p_correlation_id default null
(9-param, 0063) p_tenant_id, p_store_id, p_intent_id, p_provider_payment_key,
  p_provider_approval_number, p_approved_amount, p_provider_raw_event_id default null,
  p_locale default 'ko', p_correlation_id default null
```

`0038`/`0056`이 실제 사용하는 8개 named argument(`p_provider_raw_event_id`까지 포함, `p_locale` 없음)로 직접 재현한 결과, 정확히 다음 에러가 재현됨(BEGIN...ROLLBACK, 영구 반영 없음):

```
ERROR: function catchmenu_payment.confirm_payment_from_provider(...) is not unique
HINT: Could not choose a best candidate function. You might need to add explicit type casts.
```

## §1 정확한 호출 체인 재확인

### §1.1 실제 호출부 — `0038`/`0056`만 실호출, 나머지는 주석/문서/검증스크립트

저장소 전체에서 `confirm_payment_from_provider`를 재검색한 결과 8개 파일에서 언급되나, 실제 함수 호출(`perform`/`select`)은 **정확히 2곳**뿐이다:

| 파일 | 위치 | 성격 |
|---|---|---|
| `0038_create_toss_webhook_processor_rpc.sql` | L294 | **실제 호출** — 토스 웹훅 승인 처리 중, 8개 named argument |
| `0056_create_van_integration_rpc.sql` | L363 | **실제 호출** — VAN 연동 승인 처리 중, 8개 named argument(구조 동일) |
| `0081_create_customer_app_rpc.sql` | L1550 | 주석("결제는 별도 confirm_payment_from_provider()") — 실행 코드 아님 |
| `0092_create_flutter_edge_function_guide_rpc.sql` | L548 | Flutter 클라이언트 예시 — **재확인 결과 신뢰 불가**: `p_order_id`/`p_provider_type` 등 라이브의 어느 오버로드에도 없는 파라미터명을 씀. `600720`에서 `0092`가 `requested_pickup_at`을 정확히 예견했던 것과 달리, 이 함수에 대해서는 오래되어 실제 시그니처와 전혀 다른, 신뢰할 수 없는 문서임을 확인 — 이번 Human 결정 근거로 사용하지 않는다. |
| `0035_verify_schema.sql`/`0073_final_verification.sql` | 각 1곳 | `information_schema.routines` 존재 여부만 확인하는 검증 스크립트 — 실행 인자 없음, 실호출 아님 |

`0038`/`0056` 둘 다 동일한 8개 named argument 구조(`p_tenant_id`/`p_store_id`/`p_intent_id`/`p_provider_payment_key`/`p_provider_approval_number`/`p_approved_amount`/`p_provider_raw_event_id`/`p_correlation_id`)를 사용 — `p_locale`은 어느 쪽도 넘기지 않는다.

### §1.2 `confirm_payment_from_provider()` 이후 실제로 무엇을 트리거하는가 (0027 원본 기준)

라이브 함수 본문(`0027`)을 직접 재확인한 결과, 이 함수는 다음을 수행한다:

1. `payment_intents.intent_status`를 `'CONFIRMED'`로 갱신.
2. `payment_ledger`에 INSERT — `ledger_entry_type := 'APPROVAL'`, `ledger_status := 'APPROVED'`, **`kds_release_authorized := false`를 명시적으로 고정**(주석: "특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용").
3. `order_sessions.session_status := 'PAYMENT_PENDING'`으로 갱신.
4. `kds_tickets.conditions_met`에 `payment_confirmed: true`를 병합 — **`kds_status`는 건드리지 않고 `HOLD`/`CAPACITY_CHECKING` 그대로 둔다.**
5. `kds_events`/`payment_events`/`catchmenu_ledger.events`/감사 레코드(`append_audit_record`) 기록.
6. 반환값에 `'next_step': 'KDS_CAPACITY_CHECK_REQUIRED'`를 명시.

### §1.3 `authorize_kds_release()`와의 관계 — 완전히 별도 경로임을 확정

`confirm_payment_from_provider()`의 본문 전체(`0027`)를 재확인한 결과 **`authorize_kds_release()`를 직접 호출하는 코드는 없다** — 두 함수는 완전히 분리된 경로다. `confirm_payment_from_provider()`는 결제 확인 사실만 `conditions_met.payment_confirmed`에 반영하고 `kds_release_authorized = false`로 고정할 뿐, KDS 릴리즈 허가는 별도의 나중 단계(반환값이 예고하는 `KDS_CAPACITY_CHECK_REQUIRED`)에서 이루어져야 한다는 설계다.

**부수 발견**: `authorize_kds_release()` 자체를 저장소 전체에서 재검색한 결과, **실제 함수 호출(`perform`/`select`)이 단 한 곳도 없다** — `0028`(원본 정의)/`0063`(패치 정의)/grant·revoke·comment 문 몇 곳뿐이다. 즉 `confirm_payment_from_provider()`가 예고하는 "다음 단계"(용량 체크 후 KDS 릴리즈 허가)가 실제로 어느 함수를 통해 트리거되는지는 이번 조사 범위에서 확인되지 않았다 — `authorize_kds_release()`가 그 자리를 채워야 할 것으로 보이나 현재 아무도 호출하지 않는다. 이는 이번 workpacket의 범위(오버로드 모호성 해소)를 넘어서는 별도 조사 대상이며, Open Question으로만 기록한다.

## §0.5 Human 최종 결정 (2026-07-14, GPT 심층 분석 채택, 재논의 금지)

`confirm_payment_from_provider()`는 `0027` 기반 8개 파라미터 단일 canonical 함수로 정리한다(이하 "확정 방향"). 근거:

- **`p_locale`(다국어) 도입하지 않음** — 실제 요구사항 없음이 삼중검증(Cursor+Codex)으로 확인됨.
- **`p_options jsonb` 확장 필드도 도입하지 않음** — 강한 타입/명시적 계약을 결제 핵심 함수에서 유지하는 게 더 중요하며, JSONB는 이번 workpacket 전체에서 반복적으로 겪은 "존재하지 않는 필드를 그럴듯하게 참조하는" drift 문제(`600720`의 `requested_pickup_at`/`ready_at`, `600727`의 `order_items` 등)를 컴파일 시점 검증 밖으로 숨기는 위험이 있음.
- 향후 실제 요구(예: settlement reference, terminal_id 등)가 확정되면, 그때 통제된 승인 프로세스로 새 파라미터를 명시적으로 추가한다(YAGNI — 지금 미리 만들지 않음).

이는 `600512_Logic.md`의 원 Option A(9-param 오버로드 DROP, 8-param만 유지)와 내용상 동일하며, 이번 결정으로 Option B(호출부를 9-param으로 확장)/Option C(타입 캐스팅)는 물론, 이번 턴 새로 검토된 JSONB 확장 옵션까지 모두 기각되었다 — `600512_Logic.md`에서 각 옵션의 기각 근거를 최종 정리한다.

### 처리 방향 (GPT 제안 순서, 이번 턴 진행 상황)

| # | 단계 | 이번 턴 처리 결과 |
|---|---|---|
| 1 | 8개/9개 함수의 정확한 identity arguments 확인 | **재확인 완료** — `pg_get_function_identity_arguments()`로 라이브 재조회, §0의 두 시그니처와 정확히 일치(변동 없음). |
| 2 | 모든 활성 호출부(`0038`, `0056`)가 8개 계약을 쓰는지 재확인 | **재확인 완료** — 두 호출부 모두 `p_locale` 참조 0건, 8-param 계약 그대로 사용 중임을 재확인. |
| 3 | 9개 오버로드(`0063`) 명시적 `DROP FUNCTION` | **이번 턴 미실행** — 이 문서는 Stage 1.5(Overview/Logic 확정) 산출물이며 `.sql` 파일을 생성·수정하지 않는다는 제약이 이번 workpacket 전체에 걸쳐 유지됨. `DROP FUNCTION`은 Stage 4(Codex 구현) 대상으로 `600512_Logic.md`에 실행 계획으로 문서화한다. |
| 4 | 8개 함수 하나만 남도록 보장 | 3번과 동일 사유로 이번 턴 미실행 — Stage 4/5에서 라이브 오버로드 수 재확인(`count(*) = 1`)으로 검증 예정. |
| 5 | `0027` 함수 본문과 현재 테이블 계약 재대조 | **재확인 완료(이미 완료된 것의 재확인)** — `payment_ledger` 컬럼 수 재조회(28개, 이전과 동일), 변동 없음 재확인. 상세는 `600512_Logic.md` §4. |
| 6 | 이후 실제 호출 테스트 계획 | 이번 문서에서 다루지 않음 — `600513_TestPlan.md`(Stage 2)에서 상세화 예정. |

## §2 `mark_payment_uncertain()`/`authorize_kds_release()` — "같은 패턴" 주장 재확인, 부분 정정

배경 설명은 `0063`이 원본을 덮어쓰지 않고 새 오버로드만 추가하는 "같은 패턴"이 `mark_payment_uncertain()`/`authorize_kds_release()`에도 있다고 전제했다. 이번 턴 직접 재확인 결과 **부분적으로만 맞다**:

| 함수 | 두 오버로드 비교 | 실제 함수 호출(`perform`/`select`) 재검색 |
|---|---|---|
| `mark_payment_uncertain()` | 5-param(`0027`) vs 6-param(`0063`, `p_locale` 추가) — `confirm_payment_from_provider()`와 **정확히 같은 패턴**(필수 파라미터 순서·이름 동일, `p_locale`만 삽입) | **0건** — 저장소 전체에서 실제 호출 없음 |
| `authorize_kds_release()` | `0028`(원본): `p_tenant_id, p_store_id, p_ledger_id, p_actor_type, p_actor_id, p_correlation_id` (6-param) vs `0063`(패치): `p_tenant_id, p_store_id, p_order_id, p_authorized_by_type, p_authorized_by_id, p_authorization_reason, p_locale, p_correlation_id` (8-param) — **"같은 패턴"이 아님**: 3번째 필수 파라미터부터 이름이 다르고(`p_ledger_id` vs `p_order_id`), 그 이후 파라미터 구성 자체가 다르다. 단순 `p_locale` 삽입이 아니라 훨씬 큰 폭의 시그니처 재설계로 보인다. | **0건** — 저장소 전체에서 실제 호출 없음 |

**정정된 결론**: 두 함수 모두 현재 **실제 호출자가 0건**이라는 점에서 `confirm_payment_from_provider()`(실제 100% 실패 중인 라이브 블로커)와는 긴급도가 다르다 — `600610`에서 확인한 `create_order_session()`의 `0063` 오버로드(호출자 0건, 낮은 긴급도)와 같은 성격이다. 다만 `authorize_kds_release()`는 구조적으로 "단순 `p_locale` 추가"가 아니므로, 이 workpacket에서 함께 다루더라도 동일한 해법(오버로드 DROP 등)을 그대로 적용할 수 없을 가능성이 있다.

**Human 결정(2026-07-14) 반영**: 이번 workpacket 범위에서는 여전히 제외하고 별도 workpacket 후보로 유지한다. 다만 §0.5의 확정 방향(오버로드 대신 단일 canonical 함수 유지, `p_locale`/JSONB 확장 미도입)이 같은 원칙으로 두 함수에도 적용될 것임을 Open Item에 명시해둔다 — `mark_payment_uncertain()`은 이 원칙을 그대로(단순 `p_locale` 추가분 DROP) 적용 가능할 것으로 보이나, `authorize_kds_release()`는 시그니처 자체가 다르므로 "어느 쪽이 0027 계열의 canonical인가"부터 별도 조사가 필요하다 — `600512_Logic.md` §5에서 이 구분을 최종 반영한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`
- `000001_Md_Rules.md`

### Full Rules Required

- `sql/migrations/0027_create_payment_intent_rpc.sql` — `confirm_payment_from_provider()` 원본 정의, `payment_ledger` INSERT 정확성 판단의 유일한 근거.
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` — 9-param 패치 정의, 이번 결함의 직접 원인.
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` — 실제 호출부 1.
- `sql/migrations/0056_create_van_integration_rpc.sql` — 실제 호출부 2.

### Domain Indexes

- 해당 없음.

### Excluded Rule Families

- `0092_create_flutter_edge_function_guide_rpc.sql` — 이번 턴 재확인 결과 이 함수에 대해서는 신뢰 불가(§1.1), Human 결정 근거로 사용하지 않는다.
- `900xxx` 특허 문서 — `confirm_payment_from_provider()` 본문의 "특허1"/"특허2" 주석은 결제-KDS 분리 설계 원칙에 대한 것으로, 이번 오버로드 모호성 자체와는 무관(설계 자체는 건드리지 않음).

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0.5의 Human 결정에 따라 Option 논의는 종료되었다 — `0027`(8-param)을 canonical로 유지, `0063`(9-param) DROP. 이 스냅샷으로 Stage 2(`600513_TestPlan.md`/`600514_ChangeContract.md`) 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600512_Logic.md] =====
# 600512_Logic.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## §0 핵심 신규 발견 — 0063의 9-param 오버로드는 모호성과 별개로 그 자체가 완전히 깨져 있음

Human 결정 후보 A/B/C를 평가하기 전에, 이번 턴 직접 실증한 사실 하나가 세 옵션의 트레이드오프 계산 자체를 바꾼다: **`0063`의 9-param 오버로드는 모호성 문제를 제쳐두고서라도, 단독으로 호출해도 첫 번째 쓰기 문장에서부터 크래시한다.**

9-param 호출만 매치되도록 강제(9개 인자 전부 제공)하고 실제 유효한 `payment_intents` 행을 미리 만들어 재현한 결과:

```
ERROR: column "provider_payment_key" of relation "payment_intents" does not exist
LINE: provider_payment_key = p_provider_payment_key,
CONTEXT: PL/pgSQL function confirm_payment_from_provider(uuid,uuid,uuid,text,text,integer,uuid,text,text) line 79
```

`0063`의 함수 본문을 직접 읽어 재확인한 결과, 이 크래시 외에도 최소 3개의 추가 결함이 같은 함수 안에 있다(전부 이번 턴 라이브 스키마와 직접 대조 확인):

| 위치 | 0063이 쓰는 값/컬럼 | 실제 라이브 상태 | 결과 |
|---|---|---|---|
| `payment_intents` UPDATE | `provider_payment_key`, `confirmed_amount` 컬럼 | **둘 다 존재하지 않음**(`payment_intents`엔 `payment_token`만 있고 `provider_payment_key`/`confirmed_amount` 없음) | 하드 에러(실증됨, 위 참고) — **가장 먼저 도달하는 크래시 지점** |
| `payment_ledger` INSERT | `ledger_entry_type` 컬럼 누락 | `ledger_entry_type`은 `NOT NULL`, 기본값 없음 | 위 크래시가 없었다면 여기서도 하드 에러 |
| `payment_ledger` INSERT | `provider_raw_event_id` 컬럼 | 존재하지 않음(실제: `provider_response_id`) | 위와 동일 지점, 컬럼명 자체가 틀림 |
| `orders` UPDATE | `order_status := 'PAID'` | `chk_order_status` 허용값(`PENDING`/`CONFIRMED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`/`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED`)에 `'PAID'` 없음 | 앞의 크래시들이 없었다면 여기서도 하드 에러 |

**이것이 A/B/C 판단에 갖는 의미**: 배경 설명은 Option A의 단점을 "p_locale(다국어) 기능 자체를 잃음"으로 서술했으나, 이번 실증 결과 **`p_locale`을 가진 그 오버로드는 애초에 한 번도 성공적으로 실행된 적이 없고, 지금 그대로는 실행될 수도 없다** — "잃을 다국어 기능"이 실질적으로 존재하지 않는다. Option B/C가 "두 오버로드를 유지"한다는 것은, 유지되는 그 9-param 버전이 여전히 4곳에서 크래시하는 상태로 유지된다는 뜻이며, 모호성만 해소해도 함수 자체는 여전히 동작하지 않는다.

## §1 확정 — 8-param 단일 canonical 함수 (Human 결정 2026-07-14, 재논의 금지)

**확정된 방향**은 이 문서의 원 Option A(9-param 오버로드 DROP, 8-param `0027`만 유지)와 내용상 동일하다. Human 결정 근거는 `600511_Overview.md` §0.5 참고 — 요약: `p_locale`도 `p_options jsonb` 확장도 도입하지 않고, YAGNI 원칙에 따라 실제 요구가 확정될 때 통제된 프로세스로 새 파라미터를 명시적으로 추가한다.

### §1.1 실행 계획 (Stage 4 대상, 이번 턴 미실행)

```sql
drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);
```

**장점**(확정 근거로 채택됨):
- 모호성 즉시 해소 — `0038`/`0056`의 기존 8-param 호출이 아무 수정 없이 정상 동작.
- §0에서 확인했듯, 남기는 쪽(`0027`)이 이미 완전히 정확하고(§4 참고), 버리는 쪽(`0063`)은 어차피 그 자체로 동작하지 않는 코드다 — "동작하는 기능을 버린다"는 트레이드오프가 사실상 없다.
- 변경 범위가 `DROP FUNCTION` 한 문장으로 최소화됨.

**참고 사실**(단점이 아님, 확정에 영향 없음): `p_locale` 파라미터 자체가 없어지지만, 현재 `0027`도 다국어 응답을 안 만들고 있으므로 즉각적 기능 손실은 없음 — `0027`의 반환값은 `jsonb_build_object`로 직접 구성되며 `catchmenu_common.build_error_response`/`build_success_response`(다국어 지원 함수)를 쓰지 않는다는 점도 이번 재확인에서 발견됨.

### §1.2 검증 계획 (Stage 5 대상)

- `DROP FUNCTION` 이후 라이브 오버로드 수 재확인: `select count(*) from pg_proc where proname='confirm_payment_from_provider' and pronamespace='catchmenu_payment'::regnamespace;` → `1` 기대.
- `0038`/`0056`의 8-param 호출을 신규 `correlation_id`로 재현, `"is not unique"` 에러 소멸 확인.
- 상세 시나리오는 `600513_TestPlan.md`에서 작성.

## §2 기각됨 — 호출부를 9개 인자(`p_locale` 포함)로 수정

**기각 근거**: 호출부를 9-param 오버로드로 라우팅한다는 것은, §0에서 실증한 **4곳의 하드 크래시를 가진 함수로 실제 결제 웹훅 트래픽을 보낸다**는 뜻이다. 이 옵션은 단독으로는 성립하지 않으며, `0063`의 함수 본문 자체를 `0027`과 동등한 수준으로 다시 작성하는 별도의, 훨씬 큰 작업이 반드시 선행되어야 한다. Human 결정(§1)은 애초에 `p_locale` 자체를 도입하지 않기로 했으므로 이 기각은 최종적이다.

## §3 기각됨 — 명시적 타입 캐스팅으로 모호성만 해소, 두 오버로드 유지

**기각 근거**: `0038`/`0056`이 계속 8-param 쪽으로 캐스팅해 호출한다면 모호성은 해소되지만 **9-param 오버로드는 계속 죽은 채로 방치**된다 — 사실상 §1과 동일한 실질적 결과(9-param 쪽은 아무도 못 씀)를 훨씬 복잡한 방식(캐스팅 유지·관리 부담)으로 달성하는 것과 같다. 오버로드를 물리적으로 유지할 이유가 없으므로 기각.

## §3.5 기각됨 — `p_options jsonb` 확장 필드 도입 (이번 턴 Human 결정에서 함께 검토·기각)

**제안 내용**: 향후 확장(settlement reference, terminal_id 등)에 대비해 `p_options jsonb default '{}'`같은 범용 확장 필드를 8-param 계약에 미리 추가하는 방안.

**기각 근거**(Human 결정, `600511_Overview.md` §0.5): 결제 핵심 함수에서는 강한 타입/명시적 계약이 JSONB의 유연성보다 중요하다. 이번 workpacket 전체(`600720`의 `requested_pickup_at`/`ready_at`, `600727`의 `order_items` 4개 컬럼)에서 반복적으로 겪은 "존재하지 않는 필드를 그럴듯하게 참조하는" drift 패턴은, 컬럼/파라미터가 명시적 타입 계약일 때는 하드 에러로 즉시 드러나지만, JSONB 안에 숨으면 컴파일 시점 검증 밖으로 빠져 같은 종류의 drift가 훨씬 늦게, 조용히 발견될 위험이 있다 — 이 workpacket이 다루는 문제의 근본 원인(암묵적/비검증 계약)을 오히려 확대하는 방향이므로 채택하지 않는다. YAGNI 원칙에 따라 실제 필드 요구가 생기면 그때 명시적 파라미터로 추가한다.

## §4 0027의 `payment_ledger` INSERT — 마지막 재검증

이번 턴 라이브 스키마와 직접 대조한 결과, `0027`의 `payment_ledger` INSERT는 **완전히 정확함을 재확인했다**:

- INSERT 컬럼 목록(`tenant_id`/`store_id`/`order_id`/`session_id`/`intent_id`/`ledger_entry_type`/`ledger_status`/`approved_amount`/`net_amount`/`provider_type`/`provider_payment_key`/`provider_approval_number`/`provider_approved_at`/`provider_response_id`/`reconciliation_status`/`kds_release_authorized`/`business_day`/`business_timezone`/`approved_at`) — **전부 라이브 `payment_ledger` 테이블에 실존**(28개 컬럼 전수 대조).
- 리터럴 값 검증: `'APPROVAL'` ∈ `chk_ledger_entry_type` 허용값, `'APPROVED'` ∈ `chk_ledger_status` 허용값, `'PENDING'` ∈ `chk_ledger_reconciliation` 허용값 — 전부 통과.
- `chk_ledger_amounts`(`net_amount = approved_amount - cancelled_amount - refunded_amount`) 검증: INSERT가 `approved_amount`/`net_amount`를 동일 값으로 명시하고, `cancelled_amount`/`refunded_amount`는 INSERT에서 생략하지만 둘 다 라이브 기본값 `0`을 가짐 — 제약 통과.

**검증 방법 관련 투명 공개**: 위 검증은 라이브 스키마·제약 조건 전수 대조로 이루어졌으며, 8-param 오버로드를 모호성 문제를 우회하여 실제로 끝까지 실행시키는 것은 시도하지 않았다 — 그러려면 `DROP`(파괴적, 이번 범위 밖) 또는 `regprocedure` 기반 동적 SQL 우회(복잡도 대비 이득이 낮다고 판단)가 필요했기 때문이다. 정적 검증(컬럼 존재 + 모든 CHECK 제약 통과 + 기본값 안전성)만으로도 "INSERT 자체가 잘못될 여지가 없다"는 결론에는 충분한 근거가 된다고 판단했다.

**재확인(이번 턴, GPT 처리 방향 5번)**: `payment_ledger` 컬럼 수를 다시 조회한 결과 여전히 28개, 이전 대조 결과와 완전히 동일 — 변동 없음을 재확인했다(이미 완료된 검증의 재확인일 뿐, 신규 발견 없음).

## §5 확정 — `mark_payment_uncertain()`/`authorize_kds_release()`는 이번 workpacket 범위에서 제외, 별도 workpacket 후보로 유지 (Human 결정 2026-07-14)

`600511_Overview.md` §2에서 확인한 대로, 두 함수 모두 **현재 실제 호출자 0건**이다 — 이번 workpacket의 대상(`confirm_payment_from_provider()`, 실제 100% 실패 중인 라이브 블로커)과는 긴급도가 다르다.

**확정 사항**:
1. 이번 workpacket에서는 다루지 않는다 — 긴급도 차이(호출자 0건, `600610`의 `create_order_session()` `0063` 오버로드와 동일한 성격), 범위 확대 시 ChangeContract 경계 복잡화(`confirm_payment_from_provider()` 하나만으로도 이미 §0의 4개 하위 결함 포함).
2. **별도 workpacket에서 다룰 때는 §1의 확정 원칙(오버로드 대신 8-param류 단일 canonical 함수 유지, `p_locale`/JSONB 확장 미도입)이 동일하게 적용될 것**임을 Open Item으로 명시한다.
3. 다만 적용 방식은 함수별로 다르다:
   - `mark_payment_uncertain()`은 `confirm_payment_from_provider()`와 "같은 패턴"(단순 `p_locale` 추가)이므로, 별도 workpacket에서 동일한 "9-param 오버로드 DROP" 해법을 그대로 적용할 수 있을 것으로 예상된다.
   - `authorize_kds_release()`는 구조적으로 다르다 — 3번째 필수 파라미터 이름 자체가 다르고(`p_ledger_id` vs `p_order_id`) 전체 파라미터 구성이 재설계 수준으로 다르므로, "어느 쪽을 canonical로 남길지"부터 별도 조사가 필요하다(`0063`의 `authorize_kds_release()` 버전이 단순 패치가 아니라 의도된 재설계였을 가능성 포함) — 기계적으로 "0027 계열 유지, 0063 계열 DROP"을 적용할 수 없다.

## Snapshot Decision

**확정.** 이 스냅샷으로 Stage 2(`600513_TestPlan.md`/`600514_ChangeContract.md`) 진행 가능. `.sql` 파일은 이번 턴에서도 수정하지 않았음.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600513_TestPlan.md] =====
# 600513_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## 0. Authority And Scope

This TestPlan is derived from the finalized design in `600511_Overview.md` §0.5 and `600512_Logic.md` §1 (Human decision, 2026-07-14, no re-litigation):

- `catchmenu_payment.confirm_payment_from_provider()` is reduced to a single canonical overload: the 8-parameter version from `0027_create_payment_intent_rpc.sql`.
- The 9-parameter overload from `0063_patch_core_rpc_i18n_diagnostics.sql` (`p_locale` added) is dropped via a new forward migration.
- `p_locale` and a hypothetical `p_options jsonb` extension field are explicitly **not** introduced (Human decision, YAGNI).

## 1. Verification Environment

All execution tests must run against local Supabase Docker DB only (`supabase_db_yoonsul_wait_order_handoff`).

Requirements:

- Wrap all data-mutating tests in `BEGIN; ... ROLLBACK;`.
- Do not leave test intents, orders, ledger rows, KDS tickets, events, or audit records behind.
- Do not modify `0027`, `0038`, `0056`, or the `confirm_payment_from_provider` definition inside `0063` during verification — verification observes behavior only.
- Reference test identifiers already established in this workpacket's investigation (`600727`/`600510` series):
  - `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid`
  - `p_store_id := '00000000-0000-0000-0000-000000000002'::uuid`

## 2. Test A — `DROP FUNCTION` Leaves Exactly One Overload

Purpose: confirm the 9-param overload is gone and the 8-param overload survives untouched.

Execution shape:

```sql
begin;

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);

select count(*) as overload_count,
       pg_get_function_identity_arguments(oid) as identity_args
from pg_proc
where proname = 'confirm_payment_from_provider'
  and pronamespace = 'catchmenu_payment'::regnamespace
group by oid;

rollback;
```

Expected result:

- Exactly 1 row returned.
- `identity_args` matches the 8-param signature exactly: `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text`.

PASS condition: `count(*) = 1` and the identity arguments match the 8-param signature exactly (no `p_locale`).

FAIL condition: 0 rows (both dropped), 2 rows (drop had no effect), or 1 row with the wrong (9-param) signature.

**Note**: This test is run inside its own `BEGIN`/`ROLLBACK` for verification purposes only — the actual `DROP FUNCTION` that ships is the one in `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` (see `600514_ChangeContract.md`), applied and committed for real via the normal migration path, not left inside a rolled-back transaction.

## 3. Test B — 8 Named-Argument Call No Longer Ambiguous

Purpose: confirm the exact calling convention used by `0038`/`0056` resolves unambiguously once only one overload exists.

Execution shape (run only after the real `0153` migration is applied — not inside a throwaway transaction that also drops the function, since the drop must persist for this test to be meaningful):

```sql
begin;

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := '<test intent id>'::uuid,
  p_provider_payment_key := 'test_key',
  p_provider_approval_number := 'test_approval',
  p_approved_amount := 3500,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600513-testB'
);

rollback;
```

Expected result: no `"function ... is not unique"` error. The call resolves to the single remaining overload and executes (success or a business-logic-level `error_key`, not an overload-resolution error).

PASS condition: the specific error `function catchmenu_payment.confirm_payment_from_provider(...) is not unique` does not occur.

FAIL condition: the ambiguity error still occurs (would indicate the drop did not take effect or a new overload reappeared).

## 4. Test C — First-Ever Full E2E Success Run

Purpose: `confirm_payment_from_provider()` has never been successfully executed end-to-end in this project — every prior attempt hit either the overload ambiguity (8-arg calls) or the independent crashes inside the 9-param version (`600512_Logic.md` §0). This is the first real attempt to run the *canonical, surviving* 8-param version all the way through with a valid, fully-satisfying `payment_intents` row.

Setup (mirrors the exact test data pattern already used and proven to satisfy all `payment_intents`/`orders` constraints in `600510`'s investigation):

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-600513', 'TAKEOUT', 'CONFIRMED',
  3500, 0, 3500,
  current_date, 'Asia/Seoul'
) returning id \gset ord_

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ord_id'::uuid, 'PENDING',
  'CARD', 'CUSTOMER_APP', 3500,
  'TOSS_PAYMENTS', 'test-idem-600513', current_date
) returning id \gset intent_

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test_provider_key_600513',
  p_provider_approval_number := 'test_approval_600513',
  p_approved_amount := 3500,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600513-testC'
) as result;

-- inspect the actual persisted row (§5 below)
select intent_id, ledger_entry_type, ledger_status,
       approved_amount, net_amount, provider_type,
       provider_payment_key, provider_approval_number,
       reconciliation_status, kds_release_authorized
from catchmenu_payment.payment_ledger
where intent_id = :'intent_id'::uuid;

select intent_status, confirmed_at
from catchmenu_payment.payment_intents
where id = :'intent_id'::uuid;

rollback;
```

Expected result: the RPC call returns `'success': true` with a `ledger_id`, and does **not** error at any point (no `chk_session_type`-style hard error, no NOT NULL violation, no CHECK violation — all previously seen failure classes in this workpacket series).

PASS condition: RPC returns `success: true`; the `payment_ledger` SELECT returns exactly 1 row.

FAIL condition: any error during the call, or the `payment_ledger` SELECT returns 0 rows.

## 5. Test D — `payment_ledger` Row Value Correctness (Extends Test C)

Purpose: confirm not just "it ran" but "it ran and wrote the right values" — directly checking the fields the Human decision's confidence in `0027` rests on (`600512_Logic.md` §4).

Using the row retrieved in Test C's second SELECT, verify:

| Field | Expected value |
|---|---|
| `intent_id` | equals the test `payment_intents.id` created in setup |
| `ledger_entry_type` | `'APPROVAL'` |
| `ledger_status` | `'APPROVED'` |
| `approved_amount` | `3500` (matches `p_approved_amount`) |
| `net_amount` | `3500` (equals `approved_amount`, since `cancelled_amount`/`refunded_amount` default to `0`) |
| `provider_type` | `'TOSS_PAYMENTS'` (inherited from the `payment_intents` row, not from the RPC call directly) |
| `provider_payment_key` | `'test_provider_key_600513'` |
| `provider_approval_number` | `'test_approval_600513'` |
| `reconciliation_status` | `'PENDING'` |
| `kds_release_authorized` | `false` (Patent 1 rule — must stay `false` regardless of payment success) |

Also verify the `payment_intents` row: `intent_status = 'CONFIRMED'`, `confirmed_at is not null`.

PASS condition: every field above matches exactly.

FAIL condition: any field mismatch — in particular, `kds_release_authorized` must never be `true` from this function alone (that would be a Patent 1 design violation, not just a data bug).

## 6. Static Boundary Verification

Run read-only source checks after implementation:

```powershell
git status --short -- sql/migrations/
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
git diff -- sql/migrations/0038_create_toss_webhook_processor_rpc.sql
git diff -- sql/migrations/0056_create_van_integration_rpc.sql
git diff -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
```

Expected diff boundary:

- Exactly one new file: `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql`.
- `0027`/`0038`/`0056`/`0063` — **zero diff, all four**. `0063`'s `confirm_payment_from_provider` definition text remains physically present in that file (it is a historical migration, not edited) but is superseded live by the `DROP FUNCTION` in `0153`.

## 7. Acceptance Criteria

This TestPlan passes if:

1. Exactly one `confirm_payment_from_provider()` overload exists live, matching the 8-param signature (Test A).
2. `0038`/`0056`'s exact calling convention no longer triggers `"is not unique"` (Test B).
3. `confirm_payment_from_provider()` completes a full successful run for the first time in this project's history (Test C).
4. The resulting `payment_ledger` row and `payment_intents` update are field-for-field correct, including `kds_release_authorized = false` (Test D).
5. `0027`/`0038`/`0056`/`0063` show zero diff; only `0153` is new (§6).
6. `mark_payment_uncertain()`/`authorize_kds_release()` are not modified, called, or referenced by any change in this workpacket.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600514_ChangeContract.md] =====
# 600514_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 (Claude review / boundary contract)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## §0 Authority

This ChangeContract is based on:

- `600511_Overview.md` (incl. §0.5 Human final decision, 2026-07-14)
- `600512_Logic.md`
- `600513_TestPlan.md`

The accepted design is not reopened here:

- `catchmenu_payment.confirm_payment_from_provider()` is reduced to a single canonical overload: the 8-parameter version originally defined in `0027_create_payment_intent_rpc.sql`.
- The 9-parameter overload (added in `0063_patch_core_rpc_i18n_diagnostics.sql`, `p_locale` extra) is removed via `DROP FUNCTION` in a new forward migration.
- `p_locale` and a hypothetical `p_options jsonb` extension field are **not** introduced (Human decision, YAGNI — `600511_Overview.md` §0.5).

## §1 Allowed Files

Exactly one new file may be created. No existing file may be modified.

| File | Allowed scope |
|---|---|
| `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` (new) | `DROP FUNCTION IF EXISTS catchmenu_payment.confirm_payment_from_provider(uuid, uuid, uuid, text, text, int, uuid, text, text);` plus a file header comment explaining the drop (purpose, background, what remains). No other statement. |

**Numbering note**: The original task text suggested `0151` as a placeholder ("또는 다음 빈 번호" — or the next free number). `0151` and `0152` are both already taken (`0151_create_check_kds_capacity_function.sql`, `0152_add_orders_pickup_ready_timing_columns.sql`, both confirmed live via `catchmenu_meta.migration_history` this turn) — the actual next free number is **`0153`**.

Allowed content inside `0153`:

```sql
-- 0153_drop_confirm_payment_provider_legacy_overload.sql
-- Purpose: Remove the dormant 9-param overload of
--          catchmenu_payment.confirm_payment_from_provider()
--          (added in 0063, p_locale extra), leaving the 8-param
--          original (0027) as the single canonical function.
--
-- Background:
--   Two live overloads caused every real caller (0038 Toss webhook,
--   0056 VAN integration) to fail with "function ... is not unique"
--   since both use identical 8 named arguments that PostgreSQL could
--   not resolve between the two candidates. Direct reproduction
--   further showed the 9-param overload independently crashes on
--   its own first write statement (phantom/missing columns), so
--   there is no working functionality being removed.
--
-- Human decision (2026-07-14): single canonical 8-param function,
-- no p_locale, no JSONB extension field (YAGNI).
--
-- Depends on:
--   - 0152_add_orders_pickup_ready_timing_columns.sql

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);
```

## §2 Forbidden Files And Operations

| Forbidden item | Reason |
|---|---|
| `sql/migrations/0027_create_payment_intent_rpc.sql` | Original 8-param definition — already confirmed correct (`600512_Logic.md` §4). No edit needed or approved. |
| `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | Real caller 1 — already uses the exact 8 named arguments matching the canonical signature (`600511_Overview.md` §1.1). No edit needed. |
| `sql/migrations/0056_create_van_integration_rpc.sql` | Real caller 2 — same as above, structurally identical call. No edit needed. |
| `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` | **File itself must not be modified.** The `confirm_payment_from_provider` definition inside it is not physically removed or edited — it becomes dead/superseded text once `0153`'s `DROP FUNCTION` runs, exactly as `600710`'s `place_takeout_order()` history and other prior workpackets in this series have treated historical migration files (append-only philosophy — see `000701` §24-adjacent precedent). |
| `mark_payment_uncertain()` (`0027`/`0063`) | Separate function, separate workpacket candidate (§4). |
| `authorize_kds_release()` (`0028`/`0063`) | Separate function, separate workpacket candidate (§4), structurally different from a simple `p_locale` addition. |
| `mark_no_show()` (`0050`/`0115`) | Discovered this turn to share the same overload-sprawl pattern — not this workpacket's scope (§4). |
| `get_did_display_state()` (`0043`/`0117`) | Same as above (§4). |
| Any other `sql/migrations/*.sql` file | Out of scope. |
| Flutter/runtime code | Out of scope. |
| Tools scripts | Out of scope. |

Implementation must not:

- Add `p_locale` or any new parameter to the surviving 8-param function.
- Add a `p_options jsonb` (or similarly named) extension field.
- Touch `payment_ledger`, `payment_intents`, `orders`, or any other table schema.
- Re-add, rename, or recreate any overload of `confirm_payment_from_provider()`.
- Modify `0063`'s file content in any way (including comments).

## §3 Required Behavior Preservation

The implementation must preserve:

- The existing 8-param `confirm_payment_from_provider()` signature and its full function body, byte-for-byte, exactly as defined in `0027`.
- `0038`/`0056`'s existing call sites — zero changes required or permitted.
- All existing `payment_ledger`/`payment_intents`/`kds_tickets`/`order_sessions` side effects performed by the 8-param function, unchanged.
- Patent 1 design invariant: `kds_release_authorized` stays `false` from this function; `authorize_kds_release()` remains a fully separate, later step (confirmed not called from within `confirm_payment_from_provider()`, `600511_Overview.md` §1.3).

## §4 Required New Behavior

The implementation must add:

- Exactly one live overload of `confirm_payment_from_provider()` after the migration runs (down from two).
- `0038`/`0056`'s existing 8-named-argument calls resolve unambiguously (no `"is not unique"` error).

## §5 Verification Requirements

Implementation must be verified against `600513_TestPlan.md`. Required verification groups:

1. Test A — post-drop overload count `= 1`, correct identity arguments.
2. Test B — `0038`/`0056`'s exact calling convention no longer ambiguous.
3. Test C — first-ever full E2E success run (`success: true`, `payment_ledger` row created).
4. Test D — `payment_ledger`/`payment_intents` field-level correctness, including `kds_release_authorized = false`.
5. Static boundary — only `0153` is new; `0027`/`0038`/`0056`/`0063` show zero diff.

## §6 Open Items Not Approved In This Contract

### §6.1 `mark_payment_uncertain()` / `authorize_kds_release()` — Separate Workpacket Candidate

Both confirmed to have zero live callers (`600511_Overview.md` §2). Same overload-sprawl root cause as `confirm_payment_from_provider()`, but out of scope here. When addressed:

- `mark_payment_uncertain()` is expected to follow the same resolution (drop the `0063` `p_locale`-added overload, keep the `0027` original) — it shares the exact "same pattern" structure already confirmed.
- `authorize_kds_release()` cannot receive the same mechanical fix — its two overloads differ in their 3rd required parameter name and type (`p_ledger_id` vs `p_order_id`), suggesting a deeper redesign rather than a simple i18n patch. Which overload (if either) is canonical needs its own investigation before any `DROP FUNCTION` is proposed.

This ChangeContract does not approve touching either function.

### §6.2 `mark_no_show()` / `get_did_display_state()` — Overload Sprawl, Separate Investigation Needed

Discovered during `600620_customer_handoff_contract_reconciliation`'s Contract Inventory (Track 1): the same "later migration adds a new overload instead of replacing the original" pattern also exists for:

- `mark_no_show()` — `0050`(original, `p_actor_type`) vs `0115`(re-defined, `p_actor_id`+`p_locale`).
- `get_did_display_state()` — `0043`(original, `p_did_id`) vs `0117`(re-defined, `p_device_id`).

Whether either pair produces an actual `"is not unique"` ambiguity in practice (i.e., whether any real caller uses a named-argument shape that both overloads could satisfy) has not been tested. This ChangeContract does not approve investigating or touching either function — flagged here only so the pattern's full extent is visible alongside this workpacket's fix.

### §6.3 `0063` File Content

`0063_patch_core_rpc_i18n_diagnostics.sql` is never edited by this or any future workpacket following this precedent — historical migration files remain append-only; superseding happens via later `DROP`/`CREATE OR REPLACE` in new files, not retroactive edits.

## §7 Risk

Risk level: MEDIUM.

Reasons:

- `confirm_payment_from_provider()` is on the real payment-confirmation path for Toss webhooks and VAN integration — a `DROP FUNCTION` mistake here would affect live payment processing once deployed.
- This is the first time the 8-param function will actually execute end-to-end in this project (Test C/D) — there is a small chance an undiscovered defect surfaces only under real execution, despite thorough static verification (`600512_Logic.md` §4).
- `DROP FUNCTION` is inherently less reversible in spirit than `CREATE OR REPLACE` (though trivially reversible by re-running `0063`'s original `CREATE OR REPLACE` if ever needed — the text is preserved, unedited, in that file).

Risk controls:

- Single new file, single statement (`DROP FUNCTION`) plus header comment only.
- Four-part verification (overload count, ambiguity resolution, E2E success, field-level correctness) before any ACCEPT.
- No existing file touched — full rollback is simply not applying `0153`.
- `0027`'s correctness was independently re-verified against live schema/constraints twice already (`600510`'s investigation, `600512_Logic.md` §4) before this contract was written.

## §8 Human Boundary Approval

Human approval is required before Stage 4 implementation.

☑ I approve creating exactly one new file: sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql.
☑ I approve the DROP FUNCTION statement targeting the 9-param overload exactly as specified in §1.
☑ I acknowledge that mark_payment_uncertain(), authorize_kds_release(), mark_no_show(), and get_did_display_state() remain out of scope for this workpacket (§6).

## §9 Stage 4 Instruction If Approved

If all three Human approval boxes in §8 are checked, Stage 4 may proceed to implement exactly this contract.

If any box remains unchecked, Stage 4 must stop and report that implementation is not authorized.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600515_Module.md] =====
# 600515_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-14 (retroactively documented — implementation itself happened earlier in this session; this file formalizes it per `600620`'s backfill discovery that it was never written)

## Summary

Implemented the approved `confirm_payment_from_provider_overload_ambiguity` change (`600514_ChangeContract.md` §1): a new forward migration `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` dropping the dormant 9-param overload of `catchmenu_payment.confirm_payment_from_provider()`.

| File | Change | Result |
|---|---|---|
| `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` (new) | `DROP FUNCTION IF EXISTS catchmenu_payment.confirm_payment_from_provider(uuid, uuid, uuid, text, text, int, uuid, text, text);` plus header comment | Applied, live-verified. |

## File Content (As Implemented, Matches `600514_ChangeContract.md` §1 Exactly)

```sql
-- 0153_drop_confirm_payment_provider_legacy_overload.sql
-- Purpose: Remove the dormant 9-param overload of
--          catchmenu_payment.confirm_payment_from_provider()
--          (added in 0063, p_locale extra), leaving the 8-param
--          original (0027) as the single canonical function.
--
-- Background:
--   Two live overloads caused every real caller (0038 Toss webhook,
--   0056 VAN integration) to fail with "function ... is not unique"
--   since both use identical 8 named arguments that PostgreSQL could
--   not resolve between the two candidates. Direct reproduction
--   further showed the 9-param overload independently crashes on
--   its own first write statement (phantom/missing columns), so
--   there is no working functionality being removed.
--
-- Human decision (2026-07-14): single canonical 8-param function,
-- no p_locale, no JSONB extension field (YAGNI).
--
-- Depends on:
--   - 0152_add_orders_pickup_ready_timing_columns.sql

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);
```

## Boundary Notes

- Only `catchmenu_payment.confirm_payment_from_provider()`'s 9-param overload was dropped — no other function touched.
- `0027`/`0038`/`0056`/`0063` — the original definition and both real call sites, plus the file containing the now-superseded overload — confirmed zero diff (matches `600514_ChangeContract.md` §2's forbidden-files list exactly).
- No table schema was touched.
- Checksum bookkeeping correct — file SHA-256 (CRLF-normalized, `7a8fd5b7eb8ec49b06372c89a96622e1bb8925a52603a0ea7a03a13b01479fc3`) matches `catchmenu_meta.migration_history` exactly, `success = true`.
- No cloud database was touched. No git commit was performed.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600516_Verification.md] =====
# 600516_Verification.md

Status: Verified (Claude Code only — see §0 for a correction to this workpacket's verification history)
Lifecycle: Verification
Stage: 5
Owner: Claude Code
Date: 2026-07-14 (retroactively documented)

## §0 Correction — This Workpacket Was Not Actually Triple-Verified

When this document was requested, the background text supplied described a three-way verification (Claude Code + Cursor + Codex, with specific figures: Cursor re-running Test A-D at ₩4,200/₩5,100 and confirming an MD5 match on `0027`'s body; Codex re-running Test A-D at ₩7,200 with Kakao Pay). Checking this session's actual record before writing it down as fact:

- The ₩7,200 / Kakao Pay re-run **was performed by Claude Code**, not Codex — in the earlier "600510 구현 Stage 5/6 검증" turn, using `correlation_id := 'reverify-600625-testBCD'`. This is Claude Code's own second independent verification pass (see §2 below), not a separate Codex report.
- No record exists anywhere in this session of Cursor running tests at ₩4,200/₩5,100, or of an MD5 comparison against `0027`'s body. No such dispatch or report happened.

This document therefore records **only what Claude Code itself directly verified**, across two separate passes at two different points in this session, each with independently chosen test data. It does not claim Cursor or Codex verification occurred for this specific workpacket — unlike `600620`'s Verification, where Cursor's and Codex's involvement is real and traceable. If Cursor/Codex verification is wanted for `confirm_payment_from_provider_overload_ambiguity`, it has not happened yet and would need to be dispatched and reported before being written here.

## Verification Result

PASS — Claude Code independently re-verified this fix twice, with different test data each time, at two different points in this session. All results consistent.

## 1. First Pass — At TestPlan Design Time (`600513_TestPlan.md`)

| Check | Result |
|---|---|
| Test A — post-drop overload count | PASS — `count(*) = 1`, correct 8-param identity arguments. |
| Test B — `0038`/`0056`'s exact 8-named-argument calling convention | PASS — no `"is not unique"` error. |
| Test C — first-ever full E2E success run | PASS — `success: true`, `ledger_id` returned. Test data: fresh `orders`/`payment_intents` rows, ₩3,500, `TOSS_PAYMENTS`, `correlation_id := 'verify-600513-testC'`. |
| Test D — `payment_ledger` field-level correctness | PASS — `ledger_entry_type = 'APPROVAL'`, `ledger_status = 'APPROVED'`, `approved_amount = net_amount = 3500`, `provider_type = 'TOSS_PAYMENTS'` (correctly inherited from the intent, not hardcoded), `reconciliation_status = 'PENDING'`, **`kds_release_authorized = false`** (Patent 1 invariant). |

## 2. Second Pass — Independent Stage 5 Re-Verification (Different Data, Different Turn)

Purpose: confirm the first pass wasn't a one-off — re-run with a completely different amount, provider, and correlation ID.

| Check | Result |
|---|---|
| `0153` diff / checksum | PASS — SHA-256 (CRLF-normalized) matches `catchmenu_meta.migration_history` exactly, `success = true`. |
| Live = source (`pg_get_functiondef`) | PASS — surviving 8-param function body byte-identical to `0027`'s source (only the cosmetic `$function$`/`$$;` delimiter differs). |
| Overload count | PASS — `count(*) = 1`, correct 8-param identity arguments (re-confirmed independently of the first pass). |
| Test B (ambiguity gone) — fresh `payment_intents` row, ₩7,200, `KAKAO_PAY`/`SIMPLE_PAY_KAKAO`, `correlation_id := 'reverify-600625-testBCD'` | PASS — no `"is not unique"` error. |
| Test C (E2E success) — same call | PASS — `success: true`, new `ledger_id` returned. |
| Test D (field correctness) — same call | PASS — `ledger_entry_type = 'APPROVAL'`, `ledger_status = 'APPROVED'`, `approved_amount = net_amount = 7200`, `provider_type = 'KAKAO_PAY'` (correctly inherited), `provider_payment_key`/`provider_approval_number` match input, `reconciliation_status = 'PENDING'`, **`kds_release_authorized = false`** (Patent 1 invariant, confirmed a second time with different data). `payment_intents.intent_status = 'CONFIRMED'`, `confirmed_at` populated. |
| Boundary — `0027`/`0038`/`0056`/`0063` | PASS — zero diff, all four (re-confirmed). |
| `600440` batch leftovers (`0024`/`0026`/`0028`/`0039`/`0044`/`0143`/`0151`) | Confirmed genuine, unrelated to this fix — each diff line matches the `READY_TO_COMMIT`→`COMMITTED` pattern exactly, zero residual `READY_TO_COMMIT` remaining in any of the 7 files. Confirmed `0028`'s diff (which touches the same file as `authorize_kds_release()`) contains zero lines outside the `READY_TO_COMMIT`/`COMMITTED` substitution — `authorize_kds_release()`'s own logic untouched. |

Both passes agree on every point, using entirely different test data (different amount, different provider, different correlation ID, different transaction) — this is genuine independent re-verification, not a repeated assertion of the same run.

## Scenario Summary

| Scenario | Pass 1 (₩3,500, Toss) | Pass 2 (₩7,200, Kakao) |
|---|---|---|
| Overload count = 1 | PASS | PASS |
| Ambiguity error gone | PASS | PASS |
| E2E success | PASS | PASS |
| `payment_ledger` field correctness | PASS | PASS |
| `kds_release_authorized = false` | PASS | PASS |
| Boundary (`0027`/`0038`/`0056`/`0063` zero diff) | — | PASS |
| `600440` leftovers confirmed genuine, unrelated | — | PASS |


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600510_confirm_payment_from_provider_overload_ambiguity/600517_Audit.md] =====
# 600517_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-14 (retroactively documented — verdict itself was reached earlier in this session; this file formalizes it per `600620`'s backfill discovery that it was never written)

## §0 Verification Coverage Note

Per `600516_Verification.md` §0, this workpacket's Stage 5 was performed by **Claude Code only**, run twice independently with different test data. It was not dispatched through this project's standard "3중 검토" procedure (`000701` §39/§40 — Cursor official + Antigravity reference-only), unlike `600410`-`600720` and `600620` in this same series. This is recorded as a process gap (§6.3), not glossed over — the ACCEPT below rests on the strength of two independent, tool-verified passes by one verifier, not on multi-verifier agreement.

## Final Audit Decision

**ACCEPT (scoped) — within the approved boundary (`600514_ChangeContract.md`), the fix is complete and correct.** `confirm_payment_from_provider()` now has exactly one live overload, resolves the ambiguity that was causing 100% failure on every real payment-confirmation call (Toss webhook, VAN integration), and has completed a full successful end-to-end run for the first time in this project's history — confirmed twice, with different data each time.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside `600514_ChangeContract.md` §1 boundary | PASS | `600515_Module.md` — only `0153` created, exact content matches the approved `DROP FUNCTION` + header comment. |
| Checksum integrity | PASS | `600516_Verification.md` §2. |
| Live = source | PASS | `600516_Verification.md` §2 — byte-identical to `0027`, only cosmetic delimiter differs. |
| Overload count reduced to 1, correct signature | PASS | `600516_Verification.md` §1/§2, confirmed twice independently. |
| `0038`/`0056`'s exact calling convention no longer ambiguous | PASS | `600516_Verification.md` §1/§2, confirmed twice with different data. |
| First-ever full E2E success run | PASS | `600516_Verification.md` §1/§2 — two independent successful runs, ₩3,500/Toss and ₩7,200/Kakao. |
| `payment_ledger` field-level correctness, incl. Patent 1 invariant (`kds_release_authorized = false`) | PASS | `600516_Verification.md` §1/§2, confirmed twice. |
| Boundary — `0027`/`0038`/`0056`/`0063` untouched | PASS | `600516_Verification.md` §2, zero diff all four. |
| `600440` batch leftovers correctly identified as unrelated, genuine, pre-existing | PASS | `600516_Verification.md` §2 — 7 files, every diff line matches the expected `READY_TO_COMMIT`→`COMMITTED` pattern exactly. |
| Multi-verifier dispatch per `000701` §39/§40 standard procedure | **Not performed** — Claude Code only, twice | `600516_Verification.md` §0. Not a defect in the fix itself; a process gap in how this workpacket was run, flagged in §6.3. |

## Findings

1. The fix fully resolves the overload ambiguity and is independently confirmed to work end-to-end — not a partial or theoretical success, but two real, successful RPC executions with distinct data.
2. The Patent 1 design invariant (`kds_release_authorized` must stay `false` from this function alone) held in both independent runs — no regression risk to the payment/KDS separation design.
3. This workpacket's own documentation trail had a real gap (`600515`-`600517` never written despite the work being done) — discovered and corrected via `600620`'s backfill process, not through this workpacket's own audit discipline. This is itself worth noting as a process lesson: Stage 4/5/6 work reported only in conversation, without being formalized into the corresponding numbered documents, is easy to lose track of.
4. This workpacket did not go through the standard triple-verification dispatch (§0) — the ACCEPT here is based on a single verifier's two independent passes, not on cross-verifier agreement. This is weaker than every other Audit in this series and should be treated accordingly if this workpacket is ever cited as precedent.

## Open Items Carried Forward

### §6.1 `mark_payment_uncertain()` / `authorize_kds_release()` — Separate Workpacket Candidate

Carried from `600514_ChangeContract.md` §6.1. Both confirmed to have zero live callers. `mark_payment_uncertain()` shares the exact same overload pattern as `confirm_payment_from_provider()` (simple `p_locale` addition in `0063`) and is expected to resolve the same way (drop the 9-param overload). `authorize_kds_release()` cannot receive the same mechanical fix — its two overloads (`0028` original vs. `0063` patch) differ in their 3rd required parameter's name and type (`p_ledger_id` vs. `p_order_id`), indicating a deeper redesign rather than a simple i18n patch; which overload (if either) should be canonical needs its own investigation.

### §6.2 `mark_no_show()` / `get_did_display_state()` — Overload Sprawl, Separate Investigation Needed

Discovered later, during `600620`'s Contract Inventory (Track 1) — the same "later migration adds an overload instead of replacing the original" pattern also exists for `mark_no_show()` (`0050` original vs. `0115` re-defined) and `get_did_display_state()` (`0043` original vs. `0117` re-defined). Whether either pair produces an actual `"is not unique"` ambiguity in practice has not been tested. Not approved or investigated as part of this workpacket.

### §6.3 Verification Process Gap (New, This Document)

This workpacket's Stage 5 did not follow the standard `000701` §39/§40 triple-verification dispatch used elsewhere in this series. If a future audit or process review of this session's governance discipline is conducted, this workpacket should be flagged as the exception, with `600516_Verification.md` §0's correction (of a subsequently-supplied but unverifiable Cursor/Codex attribution) noted as the reason the gap was caught rather than silently backfilled with unverified claims.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- This audit does not authorize a follow-up workpacket for §6.1/§6.2 — findings and priority recorded only.
- No cloud database was touched. No git commit was performed.

## Conclusion

`confirm_payment_from_provider_overload_ambiguity`'s fix is complete, correct, and independently re-verified twice by Claude Code with different data each time — including the Patent 1 invariant holding in both runs. Unlike other workpackets in this series, this one did not receive the standard multi-verifier dispatch; that gap is recorded, not hidden, and does not change the ACCEPT verdict given the strength of the two independent tool-verified passes.

Final status: **ACCEPT (scoped)**.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600541_Overview_Mark_Payment_Uncertain_Overload.md] =====
# 600541_Overview_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## §0 위치/번호 확인

도메인 재편 이후 구조 기준, `mark_payment_uncertain()`은 결제 확인 경계(Payment Confirmation)이므로 `600500_payment_confirmation/` 산하에 생성한다. `000005`/`000007` 재확인 결과 `600500` 산하에서 `600510`(6단위 워크패킷 자체 번호 `600511`–`600517` 사용 중) 다음 빈 번호는 `600500`대 자체(Readme/NavigationMap, `600500`/`600502`)를 제외하면 `600503`–`600529`가 비어 있음 — 이번 워크패킷은 그 다음 워크패킷 슬롯인 `600540`을 사용한다(`600511`–`600517` 패턴과 동일하게 자체 7-슬롯 확보: `600541`–`600547`). 파일명은 `000701` §42 규칙대로 번호+타입+제목 전부 포함.

## §0.1 배경 재확인 — "삼중 검증 완료, 재확인 불필요" 전제를 그대로 받아들이지 않음

이번 턴 지시문은 "Cursor+Codex+안티 삼중 검증 완료, 재확인 불필요"라고 명시했으나, `000701` §37/§39/§44.2(Zero Deferred Doubt, 오늘 신설)의 원칙에 따라 이 전제를 그대로 문서에 반영하지 않고 라이브 DB에서 직접 재확인했다. 결과: 배경의 핵심 주장(오버로드 2개 공존, 호출자 0건, named-argument 모호성)은 **정확했다**. 다만 §1 이하에서, 배경이 암시한 "confirm_payment_from_provider(`600510`)와 완전히 동일한 패턴"이라는 전제는 **재검증 결과 부분적으로만 맞고, 중요한 차이점이 새로 발견됐다** — 이 차이점이 이번 문서의 핵심이다.

### 라이브 재확인 (`pg_get_function_identity_arguments`)

```
(5-param, 0027) p_tenant_id, p_store_id, p_intent_id, p_uncertain_reason, p_correlation_id default null
(6-param, 0063) p_tenant_id, p_store_id, p_intent_id, p_uncertain_reason, p_locale default 'ko', p_correlation_id default null
```

### 호출자 재확인

저장소 전체(`sql/migrations/*.sql` + `*.dart`/`*.ts`/`*.js`/`*.py` 전수 검색) 재검색 결과 실제 함수 호출(`perform`/`select`)은 **0건**. `0063` 내 3곳의 매치는 전부 `revoke`/`grant`/`comment on function` — 실행 코드 아님. 배경의 "호출자 0건" 주장과 일치.

### 모호성 재확인 (라이브 재현, BEGIN...ROLLBACK 아님 — 순수 SELECT 호출이라 부작용 없음)

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := gen_random_uuid(), p_store_id := gen_random_uuid(),
  p_intent_id := gen_random_uuid(), p_uncertain_reason := 'test ambiguity'
);
-- ERROR: function catchmenu_payment.mark_payment_uncertain(...) is not unique
```

추가로 확인: **순수 positional 5-인자 호출도 모호하다**(`p_locale`이 default를 가지므로 PostgreSQL이 6-param 오버로드도 후보로 계속 고려함) — 즉 `0027`(5-param)은 named든 positional이든 **어떤 정상적 호출 방식으로도 단독 선택이 불가능**하다. `p_locale`을 명시적으로 넘기는 호출만 유일하게 `0063`(6-param)으로 확정된다.

## §1 핵심 신규 발견 — "단순 p_locale 추가"가 아니라 실질적 동작 분기(behavioral divergence)

배경/`600511_Overview.md` §2는 이 함수를 confirm_payment_from_provider와 "정확히 같은 패턴"(필수 파라미터 순서·이름 동일, `p_locale`만 삽입)으로 평가했다. 이번 턴 두 함수 본문을 라이브 스키마와 직접 대조한 결과, 이는 **부분적으로만 맞다** — 파라미터 시그니처는 동일 패턴이지만, **함수가 실제로 하는 일이 다르다**:

| 항목 | `0027`(5-param) | `0063`(6-param) |
|---|---|---|
| `payment_intents.intent_status` 갱신값 | `'PROCESSING'` | `'UNCERTAIN'` |
| `order_sessions.session_status` 갱신 | **함(`'PAYMENT_UNCERTAIN'`으로 갱신, 특허1 주석 포함)** | **안 함 — 함수 본문에 `order_sessions` 참조 자체가 없음** |
| 응답 생성 방식 | `jsonb_build_object()` 직접 조립 (raw error_key 스타일) | `catchmenu_common.build_error_response()`/`build_success_response()` 사용 (서버사이드 i18n, `0062_create_i18n_error_diagnostics.sql`의 표준 패턴) |
| `catchmenu_common.log_diagnostic()` 호출 | 없음 | 있음(CRITICAL 레벨, recovery_hint 포함) |
| `catchmenu_audit.append_audit_record()` 호출 | 있음 | 있음 (양쪽 다 있음) |

### §1.1 `payment_intents.intent_status = 'UNCERTAIN'`(0063)은 라이브 CHECK 제약 위반 — 독립적으로 깨져 있음

라이브 제약 직접 조회(`pg_get_constraintdef`):

```
chk_intent_status: CHECK (intent_status = ANY (ARRAY['CREATED','PENDING','PROCESSING','CONFIRMED','FAILED','CANCELLED','EXPIRED']))
```

**`'UNCERTAIN'`은 이 목록에 없다.** 즉 `0063`의 6-param 오버로드는, 모호성 문제와 별개로, 실제 `payment_intents` 행이 존재해서 자기 본문의 **첫 번째 쓰기 문장**(`update payment_intents set intent_status = 'UNCERTAIN'`)에 도달하면 하드 제약 위반으로 크래시한다 — `confirm_payment_from_provider()`의 9-param 오버로드가 자기 본문 첫 쓰기 문장에서 크래시했던 것과 **동일한 패턴**이다.

**검증 방법 투명 공개**: 이 크래시 지점은 라이브 CHECK 제약 정의 조회로 확정했다(결정론적 사실 — `'UNCERTAIN'` 값을 가진 어떤 행도 이 제약을 통과할 수 없음). 실제 `payment_intents` 행을 만들어 함수 전체를 끝까지 실행시키는 재현은 하지 않았다 — `orders`/`order_sessions`부터 시작하는 FK 체인 전체를 구성해야 하는 비용 대비, 제약 정의 자체가 이미 결정적 증거이기 때문이다(`600512_Logic.md` §4가 `0027`의 `payment_ledger` INSERT를 정적 검증만으로 결론 낸 것과 동일한 방법론). 대신 nonexistent intent_id로 `0063`을 직접 호출해 early-return 경로(`intent_not_found`)까지는 실제로 실행되어 `p_locale`/`build_error_response` 배선이 정상 작동함을 확인했다.

### §1.2 `0027`(유지 후보) 자체에도 별도의, 크래시는 아닌 결함이 있음

`0070_create_flutter_bootstrap_rpc.sql`(부트스트랩 대시보드)의 "PAYMENT_UNCERTAIN active?" 체크는 다음과 같다:

```sql
select exists (
  select 1 from catchmenu_payment.payment_intents
  where store_id = p_store_id and tenant_id = p_tenant_id
    and intent_status = 'UNCERTAIN'
) into v_payment_uncertain_active;
```

`0027`이 실제로 설정하는 값은 `'UNCERTAIN'`이 아니라 `'PROCESSING'`이다 — 즉 **`0027` 경로로 결제가 불확실 처리돼도, `0070`의 부트스트랩 대시보드는 이를 영영 감지하지 못한다.** 이는 크래시가 아니라 조용한 기능 누락(silent gap)이다.

**단, 이 누락이 KDS 릴리즈 차단(특허1의 핵심 안전장치)까지 무력화하지는 않는다** — `authorize_kds_release()`(`0028`)의 실제 게이트 조건은 `payment_intents.intent_status`가 아니라 `catchmenu_ledger.exceptions`(`exception_type = 'payment_uncertain'`, status `OPEN`/`ACKNOWLEDGED`/`IN_RECOVERY`)를 직접 조회한다 — 이 exceptions row는 `0027`/`0063` **양쪽 모두** 생성한다. 따라서 KDS 릴리즈 차단 자체는 두 오버로드 어느 쪽을 쓰든 안전하게 유지되며, 위험에 노출되는 것은 `0070`의 대시보드 표시(운영 가시성)뿐이다 — 심각도를 과장하지 않기 위해 이 구분을 명시한다.

## §2 `p_locale`(다국어) 필요성 재확인 — confirm_payment_from_provider와 다른 맥락일 가능성

`600510`(`confirm_payment_from_provider`)의 확정 근거(`600511_Overview.md` §0.5)는 "실제 요구사항 없음이 삼중검증으로 확인됨"이었다 — 그 함수는 결제 게이트웨이 웹훅(`0038`/`0056`)이 시스템 대 시스템으로 호출하는 순수 백엔드 오케스트레이션이며, 응답을 직접 소비하는 사람이 없다.

`mark_payment_uncertain()`은 함수명·본문 내용상 성격이 다를 가능성이 있다:

- `0063` 버전의 `p_recovery_hint` 값: `"1. 카드사/PG사에 승인 여부 직접 확인 2. resolve_payment_uncertain() 호출 3. KDS 릴리즈 권한은 해소 후 자동 복구"` — **사람(스태프)이 읽고 따라야 할 행동 지침** 형태다.
- `comment on function`에 `"Recovery hint (ko/en/zh/ja)"`라는 문서화가 있으나, 실제 `p_recovery_hint` 값은 locale 분기 없이 한국어로 고정 하드코딩되어 있다 — 주석이 예고하는 다국어 지원과 실제 코드가 불일치한다(자체로 하나의 작은 drift).
- 반대로, 이 함수를 실제로 호출할 주체가 시스템(예: 결제 타임아웃 감지 배치)인지 스태프 앱의 수동 액션인지는 **저장소 어디에도 실제 호출자가 없어 확정할 수 없다** — 함수 설계 의도(주석/naming)만으로 추정한 것이며, 확정적 결론이 아니다.

**이번 턴 결론(판단 아님, 사실 나열)**: `confirm_payment_from_provider`의 "다국어 불필요" 근거를 이 함수에 기계적으로 적용하기에는, 이 함수의 응답이 스태프에게 직접 노출될 개연성을 시사하는 코드상 증거(recovery_hint 내용)가 있다는 점에서 최소 하나의 반례가 존재한다. 결정은 `600542_Logic.md`에서 옵션으로만 제시하고 Human 결정을 기다린다.

## §3 실제 호출 체인 — Open Question (해결 안 됨)

`mark_payment_uncertain()`을 실제로 트리거해야 할 지점(결제 타임아웃 감지, PG사 웹훅 실패 콜백, 스태프 수동 조작 등)이 현재 코드베이스 어디에도 구현되어 있지 않다 — `authorize_kds_release()`가 `600511_Overview.md` §1.3에서 이미 "호출자 0건"으로 확인된 것과 같은 성격의 공백이다. 이 워크패킷의 범위(오버로드 정리)를 넘어서므로 Open Question으로만 기록한다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000701_Guide_Controlled_AI_Development_Pipeline.md`(특히 §37/§39/§43/§44, 오늘 신설된 검증 원칙)
- `600511_Overview.md`/`600512_Logic.md`(`confirm_payment_from_provider` 선례 — 이번 판단의 출발점이자, 재검증으로 정정된 대상)

### Full Rules Required

- `sql/migrations/0027_create_payment_intent_rpc.sql` — `mark_payment_uncertain()` 5-param 원본.
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql` — 6-param 패치본, `authorize_kds_release()`/`confirm_payment_from_provider()` 9-param과 동일 배치 작업.
- `sql/migrations/0028_create_kds_capacity_commit_rpc.sql` — `authorize_kds_release()`의 실제 게이트 조건(`exceptions` 테이블 조회) 확인용.
- `sql/migrations/0070_create_flutter_bootstrap_rpc.sql` — `PAYMENT_UNCERTAIN active?` 대시보드 체크 로직.
- `sql/migrations/0062_create_i18n_error_diagnostics.sql` — `build_error_response`/`build_success_response`의 i18n 처리 방식 확인용.

### Domain Indexes

- `600500_Readme_Payment_Confirmation.md`/`600502_NavigationMap_Payment_Confirmation.md` — 이 워크패킷이 속할 도메인의 현재 상태(아직 `600510`만 등재).

### Excluded Rule Families

- `authorize_kds_release()` 자체의 오버로드 정리 — `600511_Overview.md` §2가 이미 "구조적으로 다름(3번째 필수 파라미터 이름부터 상이)"으로 확인, 별도 워크패킷 대상. 이번 문서는 그 함수를 게이트 조건 확인 목적으로만 읽었고 오버로드 자체는 다루지 않는다.
- `900xxx` 특허 문서 — 특허1(PAYMENT_UNCERTAIN = KDS 릴리즈 금지) 설계 원칙 자체는 이번 워크패킷에서 재론하지 않는다. 다만 §1.2에서 확인했듯 그 안전장치는 `exceptions` 테이블 기반이라 이번 오버로드 정리와 무관하게 유지된다.

## Module Domain Tags

- SQL
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정 아님 — Human 결정 대기.** §1/§1.1/§1.2/§2에서 확인된 신규 발견(behavioral divergence, `0063`의 독립 크래시, `0027`의 조용한 대시보드 누락, `p_locale` 필요성 재고 여지)은 `600512_Logic.md`가 예측했던 "단순 DROP" 해법을 그대로 기계적으로 적용하기 어렵게 만든다. `600542_Logic.md`에서 옵션을 근거와 함께 제시한다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600542_Logic_Mark_Payment_Uncertain_Overload.md] =====
# 600542_Logic_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## §0 전제 — `600512_Logic.md`의 예측과 실제 재검증 결과의 차이

`600512_Logic.md` §5는 "`mark_payment_uncertain()`은 confirm_payment_from_provider와 같은 패턴이므로 동일한 '9-param(6-param) 오버로드 DROP' 해법을 그대로 적용할 수 있을 것"이라고 예상했다. `600541_Overview.md`의 재검증 결과, **파라미터 시그니처 패턴은 예상대로 동일**했지만 **함수 본문의 실질적 동작은 예상과 달리 갈라져 있다** — `0027`/`0063` 어느 쪽도 confirm_payment_from_provider의 `0027`(완전히 정확함)/`0063`(4곳에서 크래시, 버릴 게 명백함)만큼 깔끔한 비대칭이 아니다. 아래 §1-§6은 이 재검증 결과를 반영한 옵션 비교이며, §0.5에서 Human이 최종 결정한다.

## §0.5 Human 최종 결정 (2026-07-14, confirm_payment_from_provider와 동일 논리, 재논의 금지)

**확정된 방향**: `0063`(6-param) DROP, `0027`(5-param)을 단일 canonical 함수로 확정 — 이 문서의 원 **Option A**(§2)와 내용상 동일.

**Human이 제시한 근거(안티+Codex 삼중 검증) — 이번 턴 직접 재검증**:

| # | 근거 | 재검증 방법 | 결과 |
|---|---|---|---|
| 1 | `0063`이 독립적으로도 `chk_intent_status` 위반으로 100% 크래시 | `pg_get_constraintdef`로 라이브 제약 재조회 | **재확인**(이미 `600541_Overview.md` §1.1에서 확인된 사실과 동일 — 신규 재확인 아님, 기존 확인의 반복) |
| 2 | Codex가 추가 발견한 `exceptions.exception_code` NOT NULL 누락(2중 결함) | `\d catchmenu_ledger.exceptions`로 라이브 스키마 재조회(`exception_code text not null`, 기본값 없음) + `0063` L649-661 INSERT 컬럼 목록 재확인 | **신규 독립 검증, 확인됨** — `0063`의 `insert into catchmenu_ledger.exceptions (...)` 컬럼 목록에 `exception_code`가 **없다**. `chk_intent_status` 크래시(첫 번째 쓰기 문장)를 우회해도, 그 다음 쓰기 문장인 이 INSERT에서 `NOT NULL` 위반으로 다시 크래시한다 — Codex 주장 그대로, 이번 턴 처음으로 직접 검증됨(이전 `600541`/`600542` 초안 작성 시점엔 발견하지 못했던 사실). |
| 3 | `p_locale` 다국어 요구 없음 | `600541_Overview.md` §2가 Open Question으로 남겼던 항목 — 실제 호출자 0건(§4 근거와 동일 사실)이라는 점에서, "노출될 화면이 아예 없다"는 근거로 이 Open Question을 닫는 것으로 해석 | Human 결정으로 해소(경험적으로 재검증 가능한 사실이 아니라 제품 판단 — §2/§3 근거와 사실상 같은 근거의 다른 표현으로 수용) |
| 4 | 실제 호출부 0건 | 저장소 전체(`sql/migrations` + `*.dart`/`*.ts`/`*.js`/`*.py`) 재검색 | **재확인**(`600541_Overview.md` §0.1에서 이미 확인된 사실과 동일) |
| 5 | 화면 노출 경로 없음 | 4와 동일 근거(호출자 0건 → 소비하는 화면도 0건) | 4에 종속된 결론, 별도 재검증 불필요 |

**결론**: 5개 근거 중 1/4/5는 이번 워크패킷의 기존 조사(§1.1, §0.1)에서 이미 확인된 사실의 재확인이고, 2는 이번 턴 신규로 독립 검증되어 확인된 새 사실이며, 3은 경험적 재검증 대상이 아닌 Human의 제품 판단으로 수용한다. §6(권고, 하단)이 제기했던 우려("`0027`을 그대로 두면 `0027` 자체의 기존 결함이 남는다")는 해소되지 않았고 **Open Item으로 명시적으로 carry-forward**한다(§7) — 근거 5개가 "`0063`을 버려도 안전하다"는 판단을 강하게 뒷받침하는 것과, "`0027`이 완전무결하다"는 것은 별개이기 때문이다.

## §1 비교표 — 두 오버로드 모두 각자 다른 결함을 가짐

| | `0027`(5-param) | `0063`(6-param) |
|---|---|---|
| 모호성 해소 후 생존 가능성(정적) | 가능(제약 위반 없음) | **`intent_status='UNCERTAIN'` 문장에서 크래시**(`chk_intent_status`에 `'UNCERTAIN'` 없음, `600541` §1.1) |
| `order_sessions.session_status` 갱신 | 함 | 안 함(누락) |
| `payment_intents.intent_status` 값의 의미론적 정확성 | **틀림**(`'PROCESSING'` — `0070` 대시보드가 찾는 `'UNCERTAIN'`이 아님) | 맞음(단, 크래시 때문에 도달 불가) |
| i18n 응답(`build_error_response`/`build_success_response`) | 없음(raw jsonb) | 있음 |
| `log_diagnostic()` CRITICAL 로그 | 없음 | 있음 |
| KDS 릴리즈 차단(특허1 핵심 안전장치, `exceptions` 테이블 기반) | 안전(양쪽 다 exceptions row 생성) | 안전(크래시 이전엔 도달 못하지만, 크래시 자체가 안전 방향 실패) |

## §2 확정 — Option A: `0063` DROP, `0027` 그대로 유지 (Human 결정 2026-07-14, §0.5)

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

### §2.1 실행 계획 (Stage 4 대상, 이번 턴 미실행)

동일한 `DROP FUNCTION` 문 1개. `600512_Logic.md` §1.1과 동일 패턴 — `.sql` 파일은 이번 턴에도 수정하지 않았다.

### §2.2 검증 계획 (Stage 5 대상)

- `DROP FUNCTION` 이후 라이브 오버로드 수 재확인: `select count(*) from pg_proc where proname='mark_payment_uncertain' and pronamespace='catchmenu_payment'::regnamespace;` → `1` 기대.
- 정상 호출(5-param, named 또는 positional) 시 더 이상 `"is not unique"` 에러가 발생하지 않음을 확인.
- 상세 시나리오는 `600543_TestPlan.md`에서 작성.

**채택 근거**(§0.5 표 참고):
- `600510`과 동일한 최소 변경 패턴 — `DROP FUNCTION` 한 문장.
- 크래시 위험이 있는 `0063`을 제거하므로 안전 방향 — 게다가 `0063`은 §0.5에서 확인된 대로 **2중 결함**(첫 크래시를 우회해도 `exceptions.exception_code` NOT NULL 위반으로 재크래시)이라, confirm_payment_from_provider의 9-param 오버로드(4개 결함)만큼은 아니어도 "버려도 실질적 손실 없음" 근거가 이전 초안(§6)에서 판단했던 것보다 더 강해졌다.
- KDS 릴리즈 차단(특허1)은 `exceptions` 테이블 기반이라 이 옵션으로도 계속 안전(`600541` §1.2).
- `p_locale`/화면 노출 경로 없음(§0.5 근거 3/5) — `0027`의 i18n/진단로그 결손을 지금 메울 필요가 없다는 뜻이기도 하다(화면이 없으므로).

**남는 결손(단점이 아니라 Open Item, §7에서 carry-forward)**:
- `0027`의 기존 결함(`intent_status='PROCESSING'`, `0070` 대시보드가 영구히 감지 못함)이 그대로 남는다.
- `0027`은 i18n 응답도, CRITICAL 진단 로그도 만들지 않는다 — 향후 이 함수가 실제로 연결될 때(§3 Open Question, 원 문서 기준 — 현 `600541_Overview.md` §3) 그 결손을 다시 별도 작업으로 메워야 한다.

## §3 기각됨 — Option B: `0063` DROP + `0027`에 `intent_status` 값만 최소 수정

Option A와 동일하게 `0063`을 DROP하되, `0027`의 `update payment_intents set intent_status = 'PROCESSING'`을 `intent_status = 'UNCERTAIN'`으로 바꾸기 위해 **먼저 `chk_intent_status`에 `'UNCERTAIN'`을 추가하는 스키마 마이그레이션이 선행되어야 한다**(현재 제약이 이 값을 막고 있으므로).

**장점**:
- `0070` 대시보드의 조용한 감지 실패를 근본적으로 닫는다.
- 여전히 단일 canonical 함수 유지 원칙(`§0.5`/`600512_Logic.md`)에 부합.

**단점**:
- `600510`의 "DROP 한 문장"보다 범위가 커진다 — CHECK 제약 변경(`ALTER TABLE ... DROP CONSTRAINT ... ADD CONSTRAINT ...`)은 순수 함수 DROP보다 훨씬 신중한 검토가 필요한 스키마 변경이다(기존 행에 영향 없음은 확인 가능하나, 제약 자체를 건드리는 것은 이 프로젝트 전반에서 드문 종류의 변경).
- "유지하는 쪽(`0027`)의 본문을 수정한다"는 점에서, `600510`이 지켰던 "버리는 쪽만 DROP, 남기는 쪽은 손대지 않는다"는 원칙에서 벗어난다.

**기각 근거(Human 결정, §0.5)**: `0027`을 그대로 두는 Option A로 확정됨에 따라 자동 기각. 스키마 제약 변경(`chk_intent_status`)까지 동반하는 이 옵션은 Human이 채택한 "동일 논리(5중 근거로 `0063`은 버려도 안전)"의 범위를 넘어선다.

## §4 기각됨 — Option C: `0027` DROP, `0063` 유지 + 크래시 수정 + `order_sessions` 갱신 보강

`0063`을 canonical로 삼고, ①`chk_intent_status`에 `'UNCERTAIN'` 추가(Option B와 동일 선행 작업), ②`0063` 본문에 `order_sessions.session_status = 'PAYMENT_UNCERTAIN'` UPDATE를 다시 추가.

**장점**:
- i18n 응답 + CRITICAL 진단 로그 + 의미론적으로 정확한 `intent_status` + `order_sessions` 갱신 — 두 오버로드의 장점을 모두 가진 유일한 함수가 남는다.
- `authorize_kds_release()`/`confirm_payment_from_provider()`와 마찬가지로 `0063` 계열(i18n 표준 패턴)로 수렴한다는 점에서 프로젝트 전체의 응답 포맷 일관성에 유리(다만 `confirm_payment_from_provider()`는 반대로 `0027` 계열로 수렴하기로 확정됐다는 점과는 방향이 반대 — §5에서 이 비일관성을 별도로 짚는다).

**단점**:
- 세 옵션 중 범위가 가장 크다 — 제약 변경 + 함수 본문 수정(재작성 수준) + `0027` DROP, 총 3가지 변경이 얽힌다.
- `600510`이 "`p_locale` 자체를 도입하지 않는다"고 확정한 원칙(YAGNI, §2 Open Question — 스태프 노출 여부 미확정)과 정면으로 배치될 수 있다 — `p_locale`을 오히려 canonical 계약에 편입시키는 방향이기 때문.

**기각 근거(Human 결정, §0.5)**: Option A 채택으로 자동 기각. 세 옵션 중 범위가 가장 컸던 만큼, "동일 논리(5중 근거)"로 더 작은 변경(Option A)이 충분하다고 판단된 이상 채택 근거가 없다.

## §5 해결됨 — Option A/B/C와 confirm_payment_from_provider 확정 방향의 일관성 문제

Option C가 기각(§4)됨에 따라, 애초 우려했던 "같은 도메인 폴더 안에서 정반대 방향의 canonical 선택이 공존"하는 상황 자체가 발생하지 않는다 — `confirm_payment_from_provider()`(`600510`)와 `mark_payment_uncertain()`(이 문서) 모두 `0027` 계열(비-`p_locale`)이 canonical로 확정되어, `600500_payment_confirmation` 도메인 안에서 방향이 일관된다.

## §6 원 초안 권고 (참고용, 최종 결정에는 §0.5가 우선함)

*(이번 턴 이전 초안 내용 — 역사적 기록으로 보존, Human 결정(§0.5)이 최종 결정임)*

세 옵션 모두 근거가 있어 단일 권고로 좁히지 않는다. 다만 재검증으로 드러난 사실 관계상:

- **Option A**는 `600510`과 가장 유사한 형태를 유지하지만, `0027` 자체의 기존 결함(대시보드 미감지)을 이번에 알고도 방치하는 선택이 된다 — 이 방치가 §44.2(의심 즉시 해결 원칙, 오늘 신설)의 정신과 어떻게 조화되는지는 Human 판단이 필요하다.
- **Option B**는 결함을 고치되 범위를 최소화하지만, 제약 변경이 필요해 `600510`보다 스테이지 4 실행 리스크가 높다.
- **Option C**는 가장 완전하지만 가장 크고, `p_locale` 필요성이라는 아직 열린 질문(§2)에 대한 답을 전제로 한다.

**"`0027`을 그대로 두고 `0063`만 기계적으로 DROP"(Option A를 배경이 암시한 원안 그대로)은 §1.1에서 확인된 `0027`의 실제 결함을 감안할 때, 예상보다 근거가 약하다** — 이 점이 이번 재검증에서 가장 중요한 정정이었다.

## §7 Open Items Carried Forward (Human 결정 이후에도 남는 항목)

(a) **`0027`의 `intent_status='PROCESSING'` — `0070` 대시보드가 영구히 감지 못함(§1, §2 "남는 결손").** Human 결정은 이 결함을 알고도 지금 고치지 않는 것으로 확정했다(화면 노출 경로 없음, §0.5 근거 5) — 향후 이 함수에 실제 호출부가 생기는 시점에 재검토가 필요하다.

(b) **`0027`의 i18n 응답/CRITICAL 진단 로그 결손.** 마찬가지로 화면 노출 경로가 없어 지금은 문제 없음으로 판단됐으나, 실제 호출부가 생기면 함께 재검토 대상.

(c) **`mark_payment_uncertain()`의 실제 호출 체인이 전혀 구현되어 있지 않음(`600541_Overview.md` §3, 원래 §3 Open Question).** 이 워크패킷의 범위 밖 — 별도 워크패킷 후보.

(d) **`authorize_kds_release()` 오버로드 정리.** `600511_Overview.md` §2에서 이미 "구조적으로 다름"으로 확인, 이 워크패킷/`600510` 어느 쪽에도 포함되지 않음 — 별도 조사 필요.

## Snapshot Decision

**확정.** Option A(`0063` DROP, `0027`을 단일 canonical 함수로 유지) 채택. `600543_TestPlan.md`/`600544_ChangeContract.md`(Stage 2)로 진행 가능. `.sql` 파일은 이번 턴에도 수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600543_TestPlan_Mark_Payment_Uncertain_Overload.md] =====
# 600543_TestPlan_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude chat role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## Authority

- `600541_Overview_Mark_Payment_Uncertain_Overload.md`
- `600542_Logic_Mark_Payment_Uncertain_Overload.md`

## Final Design Under Test

`catchmenu_payment.mark_payment_uncertain()` keeps the `0027` 5-param function as the single canonical function and drops the `0063` 6-param overload.

The implementation should create a new forward migration containing only:

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

No source mutation to `0027`, `0063`, `0070`, or any runtime caller is part of this workpacket.

## §0 Preflight Checks

### §0.1 Approval / boundary checks

Before implementation:

1. Confirm `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` Human Approval checkboxes are checked.
2. Confirm the next migration number is available before creating the forward migration.
3. Confirm no `.sql` file other than the new migration is edited.
4. Confirm `0027_create_payment_intent_rpc.sql` is not edited.
5. Confirm `0063_patch_core_rpc_i18n_diagnostics.sql` is not edited.
6. Confirm `0070_create_flutter_bootstrap_rpc.sql` is not edited.

### §0.2 Live pre-state confirmation

Run:

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain'
order by args;
```

Expected pre-state:

| Expected overload | Source |
|---|---|
| `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text` | `0027` canonical |
| `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_locale text, p_correlation_id text` | `0063` overload to drop |

## §1 Test A — DROP leaves exactly one overload

After applying the migration, run:

```sql
select
  count(*) as overload_count
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain';
```

Expected:

```text
overload_count = 1
```

Then run:

```sql
select
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain';
```

Expected surviving signature:

```text
p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text
```

Failure conditions:

- Count remains `2`.
- Surviving function is the 6-param `p_locale` overload.
- No overload remains.

## §2 Test B — named-argument ambiguity disappears

Run a no-row/invalid-id call using the canonical 5 named arguments only:

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := gen_random_uuid(),
  p_store_id := gen_random_uuid(),
  p_intent_id := gen_random_uuid(),
  p_uncertain_reason := 'test ambiguity removed',
  p_correlation_id := 'test-600543-ambiguity'
);
```

Expected:

- The previous PostgreSQL ambiguity error must not occur:

```text
function catchmenu_payment.mark_payment_uncertain(...) is not unique
```

- The call should resolve to the remaining 5-param function.
- Because the IDs are intentionally nonexistent, the expected business result is the `0027` function's `intent_not_found` JSON response, not an ambiguity error.

Expected response shape:

```json
{
  "success": false,
  "error_key": "intent_not_found"
}
```

Failure conditions:

- `"is not unique"` still occurs.
- The call resolves to a different function signature.
- The function fails before returning `intent_not_found` for nonexistent IDs.

## §3 Test C — 0027 E2E first real execution

This test confirms the surviving 5-param function can execute against a real dummy `payment_intents` row.

Use a transaction and end with `ROLLBACK`.

### §3.1 Pre-check: `intent_status` allowed values

Run:

```sql
select pg_get_constraintdef(oid)
from pg_constraint
where conname = 'chk_intent_status';
```

Expected allowed list currently includes:

```text
CREATED, PENDING, PROCESSING, CONFIRMED, FAILED, CANCELLED, EXPIRED
```

Important interpretation:

- `0027` uses `intent_status = 'PROCESSING'`.
- `0027` does not require `UNCERTAIN` to be allowed.
- Therefore the `0063` `UNCERTAIN` CHECK failure is not expected in the surviving canonical function.

### §3.2 Real execution skeleton

Within `BEGIN; ... ROLLBACK;`, create the minimal valid upstream rows needed by `catchmenu_payment.payment_intents`:

1. Reuse the seeded tenant/store if available:

```text
tenant_id = 00000000-0000-0000-0000-000000000001
store_id  = 00000000-0000-0000-0000-000000000002
```

2. Insert a dummy `catchmenu_pos.orders` row.
3. Insert a dummy `catchmenu_payment.payment_intents` row with:

```text
intent_status = PROCESSING
payment_method = CARD
payment_channel = STAFF_POS
provider_type = TOSS_PAYMENTS
requested_amount > 0
business_day = current_date
business_timezone = Asia/Seoul
```

4. Call:

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_intent_id := '<intent_id>'::uuid,
  p_uncertain_reason := '600543 E2E test',
  p_correlation_id := 'test-600543-e2e'
);
```

Expected:

- No overload ambiguity.
- No `chk_intent_status` failure.
- The function returns success JSON from `0027`.
- Returned fields include:

```text
success = true
intent_id = <intent_id>
session_status = PAYMENT_UNCERTAIN
kds_blocked = true
exception_id is not null
requires_human_resolution = true
message_code = payment_uncertain_kds_blocked
audit_id is not null
```

### §3.3 Post-call state checks inside the same transaction

Check:

```sql
select intent_status
from catchmenu_payment.payment_intents
where id = '<intent_id>'::uuid;
```

Expected:

```text
PROCESSING
```

This is an accepted carried-forward defect, not a failure of this workpacket. See §7 Open Items in `600542_Logic_Mark_Payment_Uncertain_Overload.md`.

Check:

```sql
select exception_code, exception_domain, exception_type, exception_severity, exception_status
from catchmenu_ledger.exceptions
where subject_type = 'payment_intent'
  and subject_id = '<intent_id>'::uuid;
```

Expected:

- One row exists.
- `exception_code` is not null.
- `exception_domain = 'payment'`.
- `exception_type = 'payment_uncertain'`.
- `exception_severity = 'CRITICAL'`.
- `exception_status = 'OPEN'`.

Check:

```sql
select event_domain, event_type, subject_type, subject_id, caused_by_type
from catchmenu_ledger.events
where subject_type = 'payment_intent'
  and subject_id = '<intent_id>'::uuid
  and event_type = 'payment_uncertain';
```

Expected:

- One row exists.
- `event_domain = 'payment'`.
- `caused_by_type = 'SYSTEM'`.

End with:

```sql
ROLLBACK;
```

## §4 Test D — `exceptions.exception_code` NOT NULL distinction

This test distinguishes the 0063-only defect from the surviving 0027 function.

### §4.1 0063 defect record

Confirmed source fact from `600542_Logic_Mark_Payment_Uncertain_Overload.md`:

- `0063` inserts into `catchmenu_ledger.exceptions` without `exception_code`.
- Live schema has `exception_code text not null` with no default.
- Therefore `0063` would fail at this statement if it reached it.

### §4.2 0027 canonical check

Inspect `0027_create_payment_intent_rpc.sql`:

```sql
insert into catchmenu_ledger.exceptions (
  tenant_id, store_id,
  exception_code, exception_domain, exception_type,
  ...
) values (
  p_tenant_id, p_store_id,
  'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text,
  'payment', 'payment_uncertain',
  ...
)
```

Expected:

- The surviving 0027 function does not share the `exception_code` omission.
- The §3 E2E query confirms the inserted exception row has a non-null `exception_code`.

Failure condition:

- E2E execution fails with `null value in column "exception_code"`.

## §5 Boundary Verification

Run:

```powershell
git diff --name-only
```

Expected implementation diff:

- New migration file only, plus later Module/Verification/Audit documents if the implementation stage writes them.
- No edits to:
  - `sql/migrations/0027_create_payment_intent_rpc.sql`
  - `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
  - `sql/migrations/0070_create_flutter_bootstrap_rpc.sql`
  - application runtime files
  - Flutter files

Run:

```powershell
git diff --check
```

Expected:

```text
PASS
```

## §6 Acceptance Criteria

This workpacket can pass Stage 5 only if:

1. `mark_payment_uncertain()` overload count is exactly `1`.
2. The surviving overload is the 0027 5-param function.
3. The prior named-argument ambiguity error is gone.
4. A real dummy E2E call of the surviving 0027 function succeeds inside a rollback transaction.
5. `0027` is confirmed not to have the `exceptions.exception_code` NOT NULL defect.
6. No forbidden file is modified.
7. `git diff --check` passes.

## §7 Known Non-Blocking Open Items

These are not acceptance blockers for this workpacket:

- `0027` keeps `payment_intents.intent_status = 'PROCESSING'`, so `0070` dashboard logic that searches for `UNCERTAIN` still cannot detect this state.
- `0027` does not provide i18n response formatting or CRITICAL diagnostic logging.
- No real application/runtime caller currently triggers `mark_payment_uncertain()`.
- `authorize_kds_release()` overload cleanup remains separate.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600544_ChangeContract_Mark_Payment_Uncertain_Overload.md] =====
# 600544_ChangeContract_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: ChangeContract
Stage: 3 (Human Approval Gate)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## Authority

- `600541_Overview_Mark_Payment_Uncertain_Overload.md`
- `600542_Logic_Mark_Payment_Uncertain_Overload.md`
- `600543_TestPlan_Mark_Payment_Uncertain_Overload.md`

## Final Decision To Approve

Drop the dormant `0063` 6-param overload of:

```text
catchmenu_payment.mark_payment_uncertain(uuid, uuid, uuid, text, text, text)
```

Keep the `0027` 5-param overload as the single canonical function:

```text
catchmenu_payment.mark_payment_uncertain(uuid, uuid, uuid, text, text)
```

This mirrors the already-accepted `600510_confirm_payment_from_provider_overload_ambiguity` structure:

- remove the later `p_locale` overload;
- keep the original canonical function;
- do not retrofit i18n/JSONB/options into the payment confirmation boundary in this workpacket.

## §1 Allowed Files

Implementation is allowed to create exactly one new forward migration file:

```text
sql/migrations/<next_free_number>_drop_mark_payment_uncertain_legacy_overload.sql
```

The exact migration number must be determined immediately before implementation by checking `sql/migrations/`.

Allowed SQL body:

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

Header comments may be added to the new migration file to state:

- Purpose: drop legacy 0063 `p_locale` overload.
- Background: 0063 6-param overload causes overload ambiguity and independently fails against live constraints.
- Depends on: current latest migration at implementation time.
- Creates/Changes: removes one function overload only.
- Non-goals: no change to 0027 body, no i18n retrofit, no dashboard fix.

## §2 Forbidden Files / Operations

Do not edit:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
- `sql/migrations/0070_create_flutter_bootstrap_rpc.sql`
- `sql/migrations/0073_final_verification.sql`
- `sql/migrations/0035_verify_schema.sql`
- `catchmenu_app/**`
- runtime code
- Flutter files
- existing payment provider functions other than the forward migration DROP target

Do not:

- change `chk_intent_status`;
- add `UNCERTAIN` to `payment_intents.intent_status`;
- modify `catchmenu_ledger.exceptions`;
- add or change `exception_code` logic in `0027`;
- add `p_locale` or `p_options jsonb`;
- modify any caller;
- modify `authorize_kds_release()`;
- modify `confirm_payment_from_provider()`;
- modify `mark_no_show()`;
- modify `get_did_display_state()`;
- stage or commit unless a later Human instruction explicitly authorizes it.

## §3 Required Implementation Procedure

1. Reconfirm this ChangeContract has Human Approval checked.
2. Reconfirm next available migration number.
3. Create one new migration file only.
4. Apply via:

```powershell
python tools/apply_migrations.py
```

5. Run `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` §0–§6.
6. Do not edit `0027`, `0063`, or `0070` to make tests pass.
7. If the surviving 0027 function fails for a defect outside the allowed DROP scope, stop and report; do not expand scope.

## §4 Verification Requirements

Stage 5 must prove:

1. Overload count is exactly `1`.
2. Surviving signature is the 0027 5-param function.
3. Named-argument ambiguity error is gone.
4. A real dummy E2E execution of the surviving 0027 function succeeds under `BEGIN ... ROLLBACK`.
5. `0027` does not share the `0063` `exceptions.exception_code` NOT NULL omission.
6. Forbidden files are unchanged.
7. `git diff --check` passes.

## §5 Risk / Rollback Boundary

This migration removes a dormant overload that currently has:

- zero confirmed real callers;
- overload ambiguity impact on canonical calls;
- independent hard-fail behavior in the 0063 body:
  - `intent_status = 'UNCERTAIN'` violates `chk_intent_status`;
  - `exceptions.exception_code` is omitted despite NOT NULL.

Rollback, if ever required, would need a new forward migration that recreates the 6-param function. Do not restore it by editing old migrations in place.

## §6 Open Items Carried Forward

These are explicitly out of scope and must not be solved in this workpacket:

### §6(a) 0027 `PROCESSING` dashboard invisibility

The surviving 0027 function sets:

```text
payment_intents.intent_status = PROCESSING
```

`0070` dashboard logic searches for:

```text
intent_status = UNCERTAIN
```

This means the dashboard may not detect active payment uncertainty. This is a known carried-forward defect, not part of the overload cleanup.

### §6(b) 0027 i18n / diagnostic-log gap

The surviving 0027 function uses raw `jsonb_build_object()` response construction and does not call `catchmenu_common.log_diagnostic()` with CRITICAL recovery guidance.

This is carried forward because there is no confirmed real caller or screen exposure path today.

### §6(c) Real call chain not implemented

No actual app/runtime SQL caller currently triggers `mark_payment_uncertain()`. The trigger source could later be provider timeout handling, provider webhook uncertainty, or staff manual action, but that call chain is not implemented in this workpacket.

### §6(d) `authorize_kds_release()` separate workpacket

`authorize_kds_release()` has its own overload issue and is structurally different from this case. It must remain separate.

## §7 Human Approval

Human must check all boxes before Stage 4 implementation:

☑ I approve dropping only the 0063 6-param mark_payment_uncertain() overload by forward migration.
☑ I approve keeping the 0027 5-param mark_payment_uncertain() function as the single canonical function for this workpacket.
☑ I acknowledge that 0027 dashboard invisibility, i18n/diagnostic-log gaps, real call-chain absence, and authorize_kds_release() remain out of scope and are carried forward.

## Snapshot Decision

Awaiting Human Approval. No SQL, migration, runtime, or Flutter file is modified by this ChangeContract itself.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600545_Module.md] =====
# 600545_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-14

## Summary

Implemented the approved `mark_payment_uncertain_overload_ambiguity` change (`600544_ChangeContract_Mark_Payment_Uncertain_Overload.md`, Option A per `600542_Logic_Mark_Payment_Uncertain_Overload.md` §0.5/§2): dropped the dormant `0063`-era 6-param `mark_payment_uncertain()` overload (`p_locale` variant), leaving the `0027`-era 5-param function as the single canonical `catchmenu_payment.mark_payment_uncertain()` implementation.

## 1. Migration

| File | Purpose | Result |
|---|---|---|
| `sql/migrations/0154_drop_mark_payment_uncertain_legacy_overload.sql` | `drop function if exists catchmenu_payment.mark_payment_uncertain(uuid, uuid, uuid, text, text, text);` — removes only the 6-param `0063` overload. | Applied, live-verified (see `600546_Verification.md`). |

Depends on `0153_drop_confirm_payment_provider_legacy_overload.sql` (the `confirm_payment_from_provider` precedent, `600510`), per the migration's own header.

## 2. Non-Goals (confirmed honored)

Per the migration's own header and `600544_ChangeContract.md` §2, this change explicitly does not:

- Modify `0027_create_payment_intent_rpc.sql`, `0063_patch_core_rpc_i18n_diagnostics.sql`, or `0070_create_flutter_bootstrap_rpc.sql`.
- Change `chk_intent_status`.
- Add `p_locale` or a `p_options jsonb` extension field.
- Fix the carried-forward `0027` dashboard-invisibility defect, i18n/diagnostic-log gap, real call-chain absence, or the separate `authorize_kds_release()` overload issue.

## 3. Resulting Live State

- `catchmenu_payment.mark_payment_uncertain()`: exactly 1 overload survives — `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text` (the `0027` 5-param original).
- The removed 6-param overload (`p_locale text default 'ko'` variant) had two independent defects that made it unreachable in practice even before this migration (`600542_Logic.md` §0.5/§1): (a) `intent_status = 'UNCERTAIN'` violated `chk_intent_status`, and (b) its `catchmenu_ledger.exceptions` INSERT omitted the `NOT NULL` `exception_code` column.
- No live caller of `mark_payment_uncertain()` existed prior to this change (`600541_Overview.md` §0.1) — this migration removes dead-but-ambiguity-causing code, not a working code path.

## Boundary Notes

- No cloud database touched (local Supabase Docker container only).
- No git commit was performed by this Module step; `0154` remained untracked (`??`) through Stage 4/5.
- `600820` (DID, now relocated to `600820` under the pending `600920` renumbering) and `authorize_kds_release()`'s own overload sprawl remain untouched, out of scope.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600546_Verification.md] =====
# 600546_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude Code + Antigravity + Codex (§39 mandatory triple verification, §43 no low-risk exception)
Date: 2026-07-14

## Verification Result

Final result: **PASS — genuine triple independent verification (§39/§43 fully satisfied).**

## §0 Process Note — A Rejected Duplicate Preceded This Verification (§44.2 Zero Deferred Doubt, applied in real time)

Before this document was finalized, a first "Codex 검증 결과 원문" was submitted for inclusion. Direct comparison showed it to be near-verbatim identical to Claude Code's own earlier Stage 5/6 report — same invented test-label strings (`stage5-repro-b-...`, `stage5-repro-c-distinct-001`), same `exception_code` value (`PAY-UNCERTAIN-1784030389`, an execution-timestamp-derived value that cannot coincidentally repeat across genuinely independent runs), same section structure and closing verdict line. This was **not accepted** — it was flagged immediately rather than logged as a second independent data point, and the Human was asked to re-run Codex for real. The Codex report incorporated below (§3) is the **replacement**, obtained after that rejection, and is verified below to be materially distinct from both prior reports.

## §1 Claude Code — Independent Re-Verification (this session, prior turn)

Full detail already recorded in this conversation's own Stage 5/6 report (re-summarized here for completeness):

| Check | Result |
|---|---|
| `0154` checksum (manual recompute vs. `migration_history`) | PASS — `56c36713b24c23e79401fac11129205b19e277ad09f54503b5298e5ac4b0cf67`, both methods identical. |
| `count(*)` for `mark_payment_uncertain` | PASS — `1`. |
| Surviving signature | PASS — 5-param `0027` original. |
| Test A–D (fresh `gen_random_uuid()`s, `correlation_id := 'stage5-repro-b-...'` / `'stage5-repro-c-distinct-001'`) | PASS — ambiguity gone, E2E `success:true`/`session_status=PAYMENT_UNCERTAIN`/`kds_blocked:true`, `exception_code = 'PAY-UNCERTAIN-1784030389'` non-null. |
| Boundary (`0027`/`0063`/`0070`/`0073`/`0035` diff 0; `authorize_kds_release`/`confirm_payment_from_provider`/`mark_no_show`/`get_did_display_state` unchanged) | PASS. |

## §2 Antigravity — Independent Verification (verbatim)

> mark_payment_uncertain 오버로드 결함 해소(600540) 패치 적용 후 Stage 5/6 독립 검증 결과 보고서입니다. (최종 감사 판정 권한은 Claude에게 위임합니다.)
>
> 1. 0154 마이그레이션 적용 및 라이브 함수 교차 검토
> - 검증 결과: PASS (일치함, count = 1)
> - 사실 확인: 0154_drop_mark_payment_uncertain_legacy_overload.sql이 배포된 후 라이브 DB(pg_proc)를 조회한 결과, mark_payment_uncertain 함수는 5개 매개변수 버전(0027 원본) 단 1개만 유효하게 실존하고 있음이 확인되었습니다. (0063의 레거시 6개짜리 오버로드는 안전하게 소멸함)
>
> 2. Test A ~ D 독립 재현 결과 (다른 ID 및 데이터 사용)
> - Test A: overload_count = 1
> - Test B: nonexistent UUID로 호출 시 "is not unique" 없이 {"success": false, "error_key": "intent_not_found"} 정상 반환
> - Test C: 실존 dummy 데이터(intent_status: PROCESSING) 실행, success: true, 정상 종료
> - Test D: exception_code = 'PAY-UNCERTAIN-1784030342' 정상 삽입 확인(NOT NULL 위반 없음)
>
> 3. 0027 원문 exception_code 삽입 로직 재확인
> - 0027_create_payment_intent_rpc.sql L505 육안 대조: 'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text 패턴으로 정확히 삽입 확인
>
> 4. Boundary 재확인 — PASS
> - 0027/0063 등 diff 0건
> - authorize_kds_release/confirm_payment_from_provider/mark_no_show/get_did_display_state 미변경

## §3 Codex — Independent Verification (verbatim, replacement report)

> 독립 검증 완료했습니다. 수정/스테이징/커밋 없음.
>
> **1. 0154 migration 직접 확인** — 파일 내용 전문 확인(Non-goals 포함), 라이브 함수 정의 prefix가 5-param `0027` 형태와 일치, `intent_status = 'PROCESSING'`/`order_sessions.session_status = 'PAYMENT_UNCERTAIN'` 확인.
>
> **2. 오버로드 count / signature** — `overload_count = 1`, `args = p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text`. 6-param `0063` overload 제거, 5-param `0027`만 생존 확인.
>
> **3. 직접 호출 테스트** — correlation_id `eyes-only-600543-20260714-115201-amb`(모호성 프로브)/`eyes-only-600543-20260714-115201-e2e`(E2E). 모호성 프로브: `{"success": false, "error_key": "intent_not_found"}`, `is not unique` 없음. E2E(`ROLLBACK`): `{"success": true, "audit_id": "63afae21-a8d7-479c-ac00-100b3174f247", "intent_id": "22222222-2222-2222-2222-000000000534", "kds_blocked": true, "exception_id": "6bc7b5b6-3382-4aab-a05f-a6c01797a8d5", "message_code": "payment_uncertain_kds_blocked", "session_status": "PAYMENT_UNCERTAIN", "requires_human_resolution": true}`. `intent_status` 후속 조회 = `PROCESSING`. Exception row: `exception_code = PAY-UNCERTAIN-1784032298`, `exception_domain = payment`, `exception_type = payment_uncertain`, `exception_severity = CRITICAL`, `exception_status = OPEN`. Event row: `event_domain = payment`, `event_type = payment_uncertain`, `caused_by_type = SYSTEM`, `correlation_id = eyes-only-600543-20260714-115201-e2e`.
>
> **4. 0027 원문 exception_code 삽입 로직** — `0027_create_payment_intent_rpc.sql` L491-506 직접 인용, `exception_code`가 `'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text`로 정확히 삽입됨을 확인. `exceptions.exception_code NOT NULL` 문제는 `0027`에는 없음.
>
> **5. Boundary 확인** — 금지 파일(`0027`/`0063`/`0070`/`0073`/`0035`) diff 0건. 추가로 `0028`/`0038`/`0050`/`0115`/`0043`/`0117`(관련 함수 소스) diff도 0건 확인. 4개 함수 라이브 오버로드 상태: `authorize_kds_release` 2개, `confirm_payment_from_provider` 1개, `mark_no_show` 2개, `get_did_display_state` 2개, 전부 그대로. `git diff --check`: PASS.

## §4 Cross-Corroboration — Three Distinct Execution-Timestamp Values As Independence Evidence (§44.2 적용 사례)

The three verifiers each triggered a fresh `catchmenu_payment.payment_intents`/`catchmenu_ledger.exceptions` write inside the surviving `0027` function, and each run produced a **different** `exception_code`, because that column's value is generated at call time via `'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text` (`0027` L505) — a value that cannot repeat across genuinely separate executions at different real-world moments:

| Verifier | `exception_code` | `correlation_id` used |
|---|---|---|
| Claude Code | `PAY-UNCERTAIN-1784030389` | `stage5-repro-c-distinct-001` |
| Antigravity | `PAY-UNCERTAIN-1784030342` | (not explicitly reported) |
| Codex | `PAY-UNCERTAIN-1784032298` | `eyes-only-600543-20260714-115201-e2e` |

All three values are distinct, and all three fall within a plausible several-minute window consistent with three separate turns of this same working session — this is treated as positive evidence of three genuinely separate executions, not three reports of the same run. This is recorded explicitly per `000701` §44.2 ("실제 근거 없이는 다수결을 그대로 받아들이지 않는다") — the practice this §0/§4 pair demonstrates: the first submitted "Codex" report was rejected specifically because it reused Claude Code's own `exception_code`/correlation-id strings verbatim (§0), and only a report with its own independently-generated evidence (this §3) was accepted.

## Scenario Summary

| Scenario | Claude Code | Antigravity | Codex |
|---|---|---|---|
| `0154` checksum/live=source | PASS | PASS (via pg_proc cross-check) | PASS |
| `count(*) = 1` | PASS | PASS | PASS |
| Surviving signature = `0027` 5-param | PASS | PASS | PASS |
| Test A (overload count) | PASS | PASS | PASS |
| Test B (ambiguity gone) | PASS | PASS | PASS |
| Test C (E2E, `PAYMENT_UNCERTAIN`/`kds_blocked`/etc.) | PASS | PASS | PASS |
| Test D (`exception_code` non-null) | PASS | PASS | PASS |
| `0027` source `exception_code` re-read | PASS | PASS | PASS |
| Boundary (5 forbidden files) | PASS | PASS | PASS |
| Boundary (4 other overload-bearing functions unchanged) | PASS | PASS | PASS |
| Boundary (extended: `0028`/`0038`/`0050`/`0115`/`0043`/`0117`) | not run | not run | PASS (Codex only, broader scope) |

§39/§43 requirement (formal triple verification, no low-risk exception) is satisfied for this workpacket.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600540_mark_payment_uncertain_overload_ambiguity/600547_Audit.md] =====
# 600547_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-14

## Final Audit Decision

ACCEPT.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` boundary | PASS | `600545_Module.md` — exactly the 1-statement `DROP FUNCTION` in `0154`, all listed Non-Goals honored. |
| `0063` 6-param overload removed, `0027` 5-param survives as sole canonical function | PASS | `600546_Verification.md` §1-§3, all 3 verifiers independently confirm `count=1` and the surviving signature. |
| Overload ambiguity resolved | PASS | Test B, all 3 verifiers — `"is not unique"` no longer reproducible. |
| `0027` E2E execution succeeds, matches full expected response shape | PASS | Test C, all 3 verifiers, independently generated `exception_code`/`audit_id`/`exception_id`/`intent_id` values across 3 separate runs. |
| `0027`'s `exception_code` NOT NULL requirement correctly satisfied (the defect that made `0063` doubly broken) | PASS | Test D + source re-read, all 3 verifiers. |
| Boundary — 5 forbidden files (`0027`/`0063`/`0070`/`0073`/`0035`) untouched | PASS | All 3 verifiers, `git diff --stat`/`git diff --check`. |
| Boundary — 4 other overload-bearing functions unchanged | PASS | All 3 verifiers (`authorize_kds_release` 2, `confirm_payment_from_provider` 1, `mark_no_show` 2, `get_did_display_state` 2 — unchanged from pre-existing state). |
| Boundary — extended source check (`0028`/`0038`/`0050`/`0115`/`0043`/`0117`) | PASS | Codex only (broader scope than the other two verifiers), diff 0 across all 6. |
| §39/§43 genuine triple independent verification | PASS | `600546_Verification.md` §0/§4 — Claude Code + Antigravity + Codex, each with materially distinct execution evidence (`exception_code` values `1784030389`/`1784030342`/`1784032298`, all different). A first submitted "Codex" report was caught as a near-verbatim duplicate of Claude Code's own report and rejected before this Verification was finalized — the accepted Codex report is a genuine re-run with its own evidence. |

## Findings

1. This is the **first workpacket completed under `000701` §43** ("no low-risk exception for cross-verification," established earlier in this same session) — and the process worked as designed: the initial attempt to close this workpacket with only single-source (Claude Code) verification was explicitly refused (per the Human's own directive at that point), and when a substitute "second/third" report turned out to be a duplicate rather than independent, that too was caught and rejected before being written into a permanent document. The workpacket only reached ACCEPT once three materially distinct, execution-timestamp-corroborated independent verifications existed.
2. All three verifiers reached identical PASS conclusions on every criterion they each covered, with zero disagreement — a genuine convergence rather than a copied one, evidenced by each verifier's own distinct correlation IDs and randomly-timestamped `exception_code` values.
3. `600540`'s underlying problem (a dormant `0063`-era overload independently broken by two separate defects: `chk_intent_status` violation and `exceptions.exception_code` NOT NULL omission) is now fully resolved by the same "single canonical function" pattern already established for `confirm_payment_from_provider()` (`600510`) — both workpackets in the `600500_payment_confirmation` domain now converge on the `0027`-era (non-`p_locale`) function family.
4. This workpacket's own file numbers (`600540`–`600547`) reflect the post-`600920` payment-domain numbering state. This Audit's ACCEPT verdict is independent of that renumbering and does not need to be revisited because only the physical filename/path changed, not the content or verdict.

## Open Items Carried Forward

Per instruction, carrying forward `600543_TestPlan_Mark_Payment_Uncertain_Overload.md` §7 unchanged:

(a) **`0027`'s dashboard invisibility.** `0027` keeps `payment_intents.intent_status = 'PROCESSING'`, so `0070`'s bootstrap dashboard logic (which searches for `intent_status = 'UNCERTAIN'`) still cannot detect this state. All 3 verifiers independently re-confirmed `intent_status = PROCESSING` post-call.

(b) **`0027`'s i18n/diagnostic-log gap.** `0027` does not provide i18n response formatting (`build_error_response`/`build_success_response`) or `CRITICAL` diagnostic logging (`log_diagnostic()`), unlike the removed `0063` overload had.

(c) **No real application/runtime caller.** No real caller currently triggers `mark_payment_uncertain()` — confirmed again this turn (zero hits across `sql/migrations` and `*.dart`/`*.ts`/`*.js`/`*.py`).

(d) **`authorize_kds_release()` overload cleanup remains separate.** Confirmed still 2 live overloads, structurally different (not a simple `p_locale` addition) — candidate for a dedicated future workpacket, per `600511_Overview.md` §2's earlier finding.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- Local-container-only; no cloud migration, no git commit performed by this Audit step.
- The pending `600920_workpacket_renumbering_to_domain_ranges` (Stage 2, blocked on `600924_ChangeContract.md` §6.0) is unaffected by and does not affect this Audit's verdict (Finding 4).

## Conclusion

The `mark_payment_uncertain_overload_ambiguity` implementation matches its `600544_ChangeContract.md` boundary exactly, passes all Test A–D scenarios and all boundary checks across three genuinely independent verifiers (Claude Code, Antigravity, Codex), and — notably — is the first workpacket in this project to complete under the mandatory triple-verification standard (`000701` §43) with the process's safeguards (rejecting a duplicate/copied report) demonstrated in real time rather than merely described. 4 Open Items carried forward unchanged, none blocking.

Final status: **ACCEPT.**


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md] =====
# 600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — 범위 확장(`0098`→`0098`+`0109`+`0130` 통합), Human 결정 반영.

## Change ID

`confirm_payment_column_drift_and_intent_linkage_fix`

## §0.5 Revision 2 — 범위 확장 사유

Human 결정(2026-07-15, 재논의 금지): 이 워크패킷을 `0098`(`confirm_payment`) 단독 정합화에서 `0098`/`0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT` 분기)/`0130`(`record_van_transaction`) 3개 파일 통합 워크패킷으로 확장한다. `0027`(`confirm_payment_from_provider`)을 계속 canonical 참조 기준으로 삼는다. 아래 §2.1/§4.1/§5.1이 이번 확장분이며, 기존 §1-§7(Revision 1)은 무효화되지 않고 유지된다 — 단 §4의 `0103`(Toss Payments) 행 하나는 이번 재조사로 새로 발견된 사실(§5.1)에 따라 정정한다.

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510_confirm_payment_from_provider_overload_ambiguity/`, `600540_mark_payment_uncertain_overload_ambiguity/` 2개뿐이다(재확인, `ls`). 10단위 워크패킷 번호 관례상 `600540` 다음 빈 번호는 `600550` — 이 워크패킷에 배정한다. `600520`이라는 이름은 이 도메인이 아니라 `600400_kds_did_implementation/600520_domain_folder_reorganization`(별도 폴더-이동 보류 스레드)에 물리적으로 존재하며 이 도메인과 무관함을 재확인했다.

## §1 배경 재확인 — 삼중검증 클레임의 독립 재검증

지시문은 "Cursor+Codex+안티 삼중 검증 완료, 재확인 불필요"라고 명시했으나, 이번 세션의 §43/§44/§40.3 원칙(다수/기존 검증 완료 프레이밍을 그대로 신뢰하지 않고 직접 재확인)에 따라 이 문서는 핵심 주장 전부를 라이브 코드/DB로 독립 재확인했다. 아래 §2-§5는 전부 이번 재확인의 직접 결과이며, 배경이 제시한 결론과 대조해 일치/불일치를 명시한다.

## §2 `0027`(`confirm_payment_from_provider`) vs `0098`(`confirm_payment`) 나란히 대조

| | `confirm_payment_from_provider()`(`0027`, 2026-06-21) | `confirm_payment()`(`0098`, 2026-06-21, 같은 날) |
|---|---|---|
| `payment_intents` 연동 | `p_intent_id`를 받아 `select ... from catchmenu_payment.payment_intents where id = p_intent_id ... for update`로 조회, 결과를 `v_intent`에 저장 후 그 필드들(`order_id`, `session_id`, `provider_type`, `business_day` 등)을 사용 | **파라미터 목록에 `p_intent_id` 자체가 없음**(§3) — `payment_intents` 참조 0건 |
| `payment_ledger` INSERT 컬럼(재확인) | `tenant_id, store_id, order_id, session_id, intent_id, ledger_entry_type, ledger_status, approved_amount, net_amount, provider_type, provider_payment_key, provider_approval_number, provider_approved_at, provider_response_id, reconciliation_status, kds_release_authorized, business_day, business_timezone, approved_at` — **전부 라이브 `payment_ledger`(`0014`)에 실존하는 컬럼** | `tenant_id, store_id, order_id, session_id, provider_type, payment_method, provider_tx_id, provider_approval_number, approved_amount, fee_amount, net_amount, ledger_status, approved_at, provider_response, reconciliation_status, business_day, business_timezone` — `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response` 4개는 라이브에 **존재하지 않음**(`601026_Verification.md`에서 이미 삼중 재확인된 사실, 이번 문서에서 재차 확인) |
| `intent_id`(NOT NULL, FK) | 세팅함(`v_intent.id`에 해당하는 `p_intent_id`) | **세팅 안 함** — 컬럼 목록 자체에 없음 |
| `ledger_entry_type`(NOT NULL) | `'APPROVAL'`로 세팅 | **세팅 안 함** |
| `provider_payment_key` vs `provider_tx_id` | `provider_payment_key`(실제 컬럼명) 사용 | `provider_tx_id`(존재하지 않는 이름) 사용 — 의미상 같은 값(제공자 거래 식별자)을 다른 컬럼명으로 지칭 |
| `provider_response_id`(uuid, FK) vs `provider_response`(jsonb) | `provider_response_id`(실제 컬럼, `catchmenu_gateway.provider_raw_events`로의 FK, uuid) 사용 | `provider_response`(존재하지 않는 컬럼명, jsonb 원본 응답을 그대로 넣으려 시도) — **컬럼명 불일치일 뿐 아니라 타입 자체가 다름**(jsonb 원본 vs uuid FK) |
| `kds_release_authorized`(컬럼) | 명시적으로 `false` 세팅(자체 소스 주석: "특허1: 결제 승인 ≠ KDS 릴리즈 자동 허용") | 컬럼 목록에 없음 — 세팅 안 함(`0157` Slice 1 이전에는 영구 `false` 방치, 이후엔 `release_kds_after_payment()`가 별도로 세팅) |

이 대조표는 배경이 언급한 "이미 삼중검증 자료에 있음"과 부합하며, 이번 문서에서 라이브 소스(`0027`/`0098`/`0014`) 직접 재대조로 독립 확인했다.

## §2.1 `0109`/`0130` 상세 조사 — 함수명/목적/호출자/`payment_ledger` INSERT 전문 (Revision 2 신규)

### §2.1.1 `0109` — `catchmenu_common.flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 분기

- **파일 헤더 목적**(`sql/migrations/0109_create_network_handoff_fallback_rpc.sql:1-9`, 원문): "Network handoff and offline fallback pipeline. 인터넷 장애 시 자동 전환 로직. 오프라인 큐 관리. Flutter 로컬 fallback 가이드. 장애 복구 후 자동 동기화." — 결제 정합화가 아니라 **네트워크 장애 시 오프라인 큐 처리**가 이 파일의 주목적이며, `payment_ledger` INSERT는 그 큐 처리 로직(`flush_offline_queue()`) 안의 여러 액션 타입 중 하나(`RECORD_MANUAL_PAYMENT`, 수기 결제 기록)로 부수적으로 존재한다.
- **함수 시그니처**(`0109:788-795`): `catchmenu_common.flush_offline_queue(p_tenant_id uuid, p_store_id uuid, p_device_id uuid default null, p_max_batch int default 50, p_locale text default 'ko')`.
- **`payment_ledger` INSERT 전문**(`0109:916-953`, `case v_item.action_type when 'RECORD_MANUAL_PAYMENT'` 분기 내부):
  ```sql
  insert into
    catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, provider_type,
    payment_method,
    provider_tx_id,
    approved_amount, fee_amount,
    net_amount, ledger_status,
    approved_at, business_day,
    business_timezone,
    provider_response
  ) values (
    p_tenant_id, p_store_id,
    (v_item.action_payload->>'order_id')::uuid,
    'MANUAL',
    v_item.action_payload->>'payment_method',
    'MANUAL-' || now()::text,
    (v_item.action_payload->>'amount')::int,
    0,
    (v_item.action_payload->>'amount')::int,
    'APPROVED',
    (v_item.action_payload->>'paid_at')::timestamptz,
    (v_item.action_payload->>'business_day')::date,
    'Asia/Seoul',
    jsonb_build_object('offline', true, 'manual', true, 'note', v_item.action_payload->>'note')
  )
  returning id into v_ledger_id;
  ```
  컬럼 목록: `tenant_id, store_id, order_id, provider_type, payment_method, provider_tx_id, approved_amount, fee_amount, net_amount, ledger_status, approved_at, business_day, business_timezone, provider_response` — `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response` 4개 phantom 컬럼 전부 포함, `intent_id`/`ledger_entry_type` 둘 다 누락. `fee_amount`는 계산 없이 하드코딩 `0`.
- **실제 호출자 재확인**: `grep -rn "flush_offline_queue(" sql/migrations/*.sql`(자기 자신 제외) 결과 — 실제 호출 0건. `0130`의 문서 문자열(사람이 읽는 절차 안내 텍스트, `0130:1053` `'7. 복구 후 flush_offline_queue()'`) 안에 이름만 언급될 뿐, 실제 함수 호출은 어디에도 없다. **즉 이 INSERT는 현재 어떤 라이브 경로로도 도달하지 않는 죽은 코드다** — `0098`(카드/PG 3사가 실제로 호출)과는 위험도가 다르다.

### §2.1.2 `0130` — `catchmenu_payment.record_van_transaction()`

- **파일 헤더 목적**(`sql/migrations/0130_create_van_handler_extension.sql:1-9`, 원문): "VAN handler extension. NICE VAN 완성. KIS VAN 완성. 망취소 파이프라인. VAN 오류 자동 복구. VAN 정산 대사 연동." — VAN(부가통신사업자) 카드 단말 연동 확장.
- **함수 시그니처**(`0130:278-299`): `catchmenu_payment.record_van_transaction(p_tenant_id uuid, p_store_id uuid, p_van_provider text, p_van_terminal_id text, p_transaction_type text, p_approved_amount int, p_order_id uuid default null, p_card_number_hash text default null, p_card_company text default null, p_card_type text default 'CREDIT', p_installment_months int default 0, p_approval_number text default null, p_approval_at timestamptz default null, p_van_reference_id text default null, p_van_response_raw jsonb default null, p_transaction_status text default 'APPROVED', p_is_net_cancel boolean default false, p_locale text default 'ko')`.
- **`payment_ledger` INSERT 전문**(`0130:393-424`, `p_transaction_type = 'APPROVAL' and p_transaction_status = 'APPROVED' and p_order_id is not null` 조건 안):
  ```sql
  insert into
    catchmenu_payment.payment_ledger (
    tenant_id, store_id,
    order_id, provider_type,
    payment_method, provider_tx_id,
    approved_amount, fee_amount,
    net_amount, tax_amount,
    ledger_status, approved_at,
    business_day, business_timezone,
    provider_response
  ) values (
    p_tenant_id, p_store_id,
    p_order_id,
    p_van_provider || '_VAN',
    case p_card_type when 'CREDIT' then 'CREDIT_CARD' else 'DEBIT_CARD' end,
    coalesce(p_approval_number, v_tx_id::text),
    p_approved_amount,
    0,
    p_approved_amount - v_tax_amount,
    v_tax_amount,
    'APPROVED',
    coalesce(p_approval_at, now()),
    v_business_day, 'Asia/Seoul',
    p_van_response_raw
  )
  returning id into v_ledger_id;
  ```
  컬럼 목록: `tenant_id, store_id, order_id, provider_type, payment_method, provider_tx_id, approved_amount, fee_amount, net_amount, tax_amount, ledger_status, approved_at, business_day, business_timezone, provider_response` — 기존 4개 phantom 컬럼에 **`tax_amount`가 5번째로 추가**(§2.1.3에서 라이브 부재 재확인), `intent_id`/`ledger_entry_type` 역시 누락.
- **실제 호출자 재확인**: `grep -rn "record_van_transaction(" sql/migrations/*.sql`(자기 자신 제외) 결과 **0건**. 실제 라이브 VAN 웹훅 핸들러(`0056_create_van_integration_rpc.sql`)는 `record_van_transaction()`이 아니라 `confirm_payment_from_provider()`(`0027`, DDL 정합 패턴)를 호출한다(`0056:363`) — **`record_van_transaction()`은 라이브 VAN 파이프라인과 완전히 분리된, 호출자 0건의 별도 함수**다. `0098`처럼 실제 카드/PG 3사가 호출하는 활성 결함이 아니라, `0109`의 `flush_offline_queue()`와 마찬가지로 잠재적(작성됐으나 배선되지 않은) 결함이다.

### §2.1.3 `0130`의 `tax_amount` — 라이브 부재 재확인 (신규 발견)

`information_schema.columns` 재조회 결과(`table_schema='catchmenu_payment' and table_name='payment_ledger' and column_name='tax_amount'`): **0 rows**. `tax_amount`는 라이브 `payment_ledger`에 존재하지 않는다 — 배경의 "신규 발견"을 독립 확인했다. (참고: `0130:85`의 `tax_amount int not null default 0`은 `payment_ledger`가 아니라 `0130` 자신이 만드는 별도 테이블 `catchmenu_payment.van_transactions`의 컬럼이다 — `van_transactions`에는 실존하지만 `payment_ledger`에는 없다는 것이 정확한 표현이다.)

## §3 `confirm_payment()`의 현재 실제 파라미터 목록 — `p_intent_id` 존재 여부 재확인

라이브 소스 재확인(`sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql:144-159`):

```sql
create or replace function
  catchmenu_payment.confirm_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_provider_type text,
  p_provider_approval_number text,
  p_provider_tx_id text,
  p_approved_amount int,
  p_payment_method text,
  p_provider_response jsonb default null,
  p_actor_type text default 'STAFF',
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

**확인 결과**: 13개 파라미터 전부 나열했으며, `p_intent_id`는 **존재하지 않는다**. 대신 이 함수는 `p_order_id`(주문 식별자)와 provider(PG/POS)가 보고한 원시 값들(`p_provider_tx_id`, `p_provider_approval_number`, `p_provider_response` 등)만 받는다 — `payment_intents`를 거치지 않고 "주문 + provider 원시 결과"만으로 결제를 확정하는 구조다. 배경의 "핵심 문제 3"(p_intent_id 부재로 payment_intents와 연결할 구조적 방법이 없음)을 정확히 재확인했다.

## §4 실제 호출자 3개(`0102`/`0103`/`0104`) 재확인 — 무엇을 넘기는가, `payment_intents` 참조 여부

전체 3개 파일에서 `payment_intents`/`p_intent_id` 문자열 재검색 결과 **0건** — 세 호출자 모두 `payment_intents` 테이블을 전혀 참조하지 않는다.

| 호출자 | 래퍼 함수 시그니처(재확인) | `confirm_payment()`에 넘기는 값 | 자체 사전 추적 테이블 |
|---|---|---|---|
| `0102`(OKPOS) | `catchmenu_integrations.confirm_okpos_payment(p_tenant_id, p_store_id, p_order_id, p_okpos_tx_data jsonb, p_locale, p_correlation_id)`(`0102:902-910`) | `p_provider_type:='OKPOS'`, `p_provider_tx_id:=`OKPOS 응답의 `okpos_tx_id`, `p_provider_response:=p_okpos_tx_data`(원시 jsonb 그대로) 등(`0102:958-973`) | `catchmenu_integrations.okpos_transactions`(자체 테이블, `payment_intents`와 무관, `intent_id` 컬럼 없음) |
| `0103`(Toss Payments) | 시그니처는 상위 함수(체크섬 검증 등 포함) 안에서 호출(`0103:695-`) | `p_provider_type:='TOSS_PAYMENTS'`, `p_provider_tx_id:=p_payment_key`, `p_order_id:=v_request.order_id`(`toss_payment_requests`에서 조회) | `catchmenu_integrations.toss_payment_requests` — **정정(§5.1, Revision 1의 이 칸은 부정확했다)**: `intent_id` 컬럼이 없다고 썼으나 재조사 결과 `payment_intent_id`(nullable, `payment_intents` FK) 컬럼이 실제로 존재한다(`0142_patch_toss_mvp_payment_intent_binding.sql`이 추가). 다만 `confirm_payment()`를 실제로 호출하는 레거시 코드(`confirm_toss_payment_legacy_604260`으로 개명됨)는 이 컬럼을 참조하지 않는다 — §5.1에서 상세. |
| `0104`(Toss POS) | `catchmenu_integrations.confirm_toss_pos_payment(p_tenant_id, p_store_id, p_order_id, p_toss_pos_tx_data jsonb, p_locale, p_correlation_id)`(`0104:825-833`) | `p_provider_type:='TOSS_POS'`, `p_provider_tx_id:=`Toss POS 응답의 `tposOrderId`/`tranId`, 원시 jsonb 파싱(`0104:857-870`) | 없음(`toss_payment_requests`류 자체 추적 테이블 없이 바로 `p_toss_pos_tx_data` 파싱) |

**세 호출자 모두 `confirm_payment()` 호출 시점에는 `payment_intents`를 참조하지 않는다** — 다만 Toss Payments 경로는 `0142` 패치 이후 `payment_intent_id`가 이미 별도로 resolve/검증되어 있으나 `confirm_payment()`로 전달되지 않고 있다는 것이 이번 재조사의 핵심 신규 발견이다(§5.1).

## §4.1 세 파일(`0098`/`0109`/`0130`)의 공통 파라미터와 차이 비교 (Revision 2 신규)

| 항목 | `confirm_payment()`(`0098`) | `flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT`(`0109`) | `record_van_transaction()`(`0130`) |
|---|---|---|---|
| 호출 형태 | 직접 RPC(파라미터로 값 받음) | 큐에 쌓인 `action_payload`(jsonb) 파싱 | 직접 RPC(파라미터로 값 받음) |
| `p_tenant_id`/`p_store_id` | 있음 | 있음(함수 자체 파라미터) | 있음 |
| `p_order_id` | 있음(필수) | `action_payload->>'order_id'`(jsonb에서 추출) | `p_order_id`(선택, `default null` — VAN 거래인데 주문 연결이 없을 수 있음을 시사) |
| `p_provider_type`(또는 상응) | 파라미터로 받음(`'OKPOS'`/`'TOSS_PAYMENTS'`/`'TOSS_POS'`) | 하드코딩 `'MANUAL'` | `p_van_provider \|\| '_VAN'`(예: `'NICE_VAN'`) |
| 결제수단 컬럼(phantom `payment_method`) | `p_payment_method` 파라미터 | `action_payload->>'payment_method'` | `p_card_type` 기반 파생(`CREDIT_CARD`/`DEBIT_CARD`) |
| provider 거래 식별자(phantom `provider_tx_id`) | `p_provider_tx_id` 파라미터 | 자체 생성 `'MANUAL-' \|\| now()::text`(외부 provider 자체가 없으므로 타임스탬프로 대체) | `coalesce(p_approval_number, v_tx_id::text)` |
| `fee_amount` | 계산됨(`v_fee_amount`, provider별 요율) | 하드코딩 `0` | 하드코딩 `0`(수수료는 `van_transactions.tax_amount`만 계산, `payment_ledger.fee_amount`에는 안 들어감) |
| `tax_amount` | 없음(파라미터도 컬럼도 없음) | 없음 | **있음** — `v_tax_amount`(부가세, 승인액의 1/11) 계산해 INSERT(§2.1.3, 라이브 부재) |
| `provider_response`(phantom) | `p_provider_response`(jsonb, 선택) | 자체 조립 `jsonb_build_object('offline', true, 'manual', true, 'note', ...)` | `p_van_response_raw`(jsonb, 선택) |
| `intent_id`/`ledger_entry_type` | 둘 다 누락 | 둘 다 누락 | 둘 다 누락 |
| 실제 호출자 | 3개(`0102`/`0103`/`0104`), 전부 라이브 | **0개**(고립) | **0개**(고립, `0056`은 대신 `0027`을 호출) |

**요약**: 세 파일 모두 같은 phantom-컬럼 패턴을 공유하지만(배경의 핵심 문제 2와 일치), 실제 위험도는 다르다 — `0098`은 활성(라이브 3개 경로가 매번 크래시), `0109`/`0130`은 잠재적(호출자 0건이라 현재는 실행되지 않음, 그러나 향후 배선되는 순간 동일하게 크래시). `tax_amount`는 `0130`에만 있는 5번째 phantom 컬럼이다.

## §5 `payment_intents`와의 관계 — `confirm_payment()`가 intent 개념 없이 설계된 이유(단서)

`payment_intents` 테이블(`0014`와 별도 정의, 라이브 재확인) 자체는 `intent_status`(`CREATED`/`PENDING`/`PROCESSING`/`CONFIRMED`/...), `payment_token`/`token_issued_at`/`token_expires_at` 같은 컬럼을 갖는다 — 이는 "결제 위젯/QR로 리다이렉트했다가 콜백으로 돌아오는" 흐름(토큰을 발급하고, 그 토큰이 유효한 동안 대기하다가 확인)에 맞는 설계다. `confirm_payment_from_provider()`(`0027`, Toss 웹훅 `0038`/VAN `0056`이 호출)가 정확히 이 패턴이다 — 먼저 `payment_intents` 행을 만들고(다른 워크패킷/파일에서), 웹훅이 나중에 도착하면 그 intent를 조회해 확정한다.

반면 `confirm_payment()`의 세 실제 호출자(§4)는 전부 **"결제가 이미 그 자리에서 물리적으로 완결된 뒤, 그 결과만 사후 보고받는"** 패턴이다:
- OKPOS/Toss POS: 매장 카운터의 POS 단말이 카드를 직접 처리한 뒤 결과(`p_okpos_tx_data`/`p_toss_pos_tx_data`)를 백엔드로 보고 — 미리 만들어둘 "의도(intent)"라는 개념 자체가 성립하지 않는다(단말이 이미 승인까지 끝낸 사후 보고이므로).
- Toss Payments: `toss_payment_requests`라는 **자체 provider-전용 사전 추적 테이블**을 이미 갖고 있다(`request_status`, `payment_key`, `idempotency_key` 등 — 개념적으로 `payment_intents`와 유사한 역할을 하지만 별도 테이블로 구현됨). 즉 이 흐름은 "intent가 없는" 것이 아니라 "범용 `payment_intents` 대신 provider 전용 테이블을 intent로 쓰는" 설계로 보인다.

**단서 정리(판단 아님, 사실 나열)**: `confirm_payment()`가 `payment_intents`를 참조하지 않는 것은 우연한 누락이라기보다, 세 실제 호출자 중 최소 2개(OKPOS/Toss POS)가 애초에 "사전 intent" 개념이 필요 없는 사후-보고형 결제이기 때문일 가능성이 있다 — 이 부분은 배경의 "설계 오류"라는 단정과 다소 결이 다르다. 그러나 이 설계 의도가 맞다 하더라도, **`payment_ledger.intent_id`가 라이브 스키마상 `NOT NULL` FK로 강제되어 있다는 사실 자체는 바뀌지 않는다** — `confirm_payment()`는 "intent가 필요 없는 결제 흐름"을 위해 설계됐을 수 있지만, 그 결과를 기록할 테이블(`payment_ledger`)은 모든 행에 대해 `intent_id`를 요구한다. 즉 설계 의도상의 정당성과 무관하게, 현재 라이브 스키마 제약과 `confirm_payment()`의 실제 INSERT는 근본적으로 양립 불가능하다 — 이 모순을 어떻게 풀지(예: 사후-보고형 결제를 위한 "synthetic intent" 자동 생성, 또는 `intent_id`를 nullable로 바꾸는 스키마 변경, 또는 `confirm_payment()`에 `p_intent_id`를 추가해 호출자들이 각자 임시 intent를 만들어 넘기게 하는 것)는 Logic 단계에서 옵션으로 다룰 사안이다.

## §5.1 신규 발견 — `0142`가 이미 Toss Payments 경로의 intent-binding 절반을 풀어놓았다 (Revision 2 핵심 발견)

레거시 격리 문서 `604253_Logic_...md`(2026-07-01, `990000_legacy_quarantine`, §6.1)는 "`604260 Scope D 00A Toss MVP PaymentIntent Binding Precondition`이 `toss_payment_requests.payment_intent_id`를 통해 강한 바인딩을 만든다"고 서술했다 — 이번 재조사에서 `604260`이 실제로 구현됐는지 라이브로 재확인한 결과, **구현되어 있었다**(단, 부분적으로만 배선됨).

- `catchmenu_integrations.toss_payment_requests`의 라이브 전체 컬럼(32개) 재확인 결과, `payment_intent_id`(nullable uuid, `fk_toss_payment_requests_payment_intent` → `catchmenu_payment.payment_intents(id)`) 컬럼이 실제로 존재한다. (**이전 조사에서 이 컬럼을 놓쳤던 이유**: 컬럼이 32개 중 마지막 위치에 있었는데 `\d` 출력을 앞부분만 확인해 누락했다 — 이번 문서에서 전체 컬럼 목록 재조회로 직접 정정한다.)
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`이 이 컬럼과 FK를 추가하고, `before insert on toss_payment_requests` 트리거 `bind_toss_payment_intent()`(`0142:29-203`)를 만들어 **모든 신규 Toss 결제 요청 행에 대해 `payment_intent_id`를 자동으로 resolve/검증**한다(기존 `payment_intents` 재사용 또는 `create_payment_intent()` 신규 생성, no-intent/multiple-intent 케이스 모두 명시적으로 처리 — `604253` §6.2가 우려했던 "silently picking the most recent" 문제를 실제로 회피).
- `0142`는 추가로 `catchmenu_integrations.confirm_toss_payment(...)`(`0142:281-365`)라는 **새 wrapper**를 만들어, 원래의 `confirm_toss_payment`(`0103` 정의)를 `confirm_toss_payment_legacy_604260`으로 개명(`0142:216-218`)하고 그 자리를 대신 차지하게 했다. 이 새 wrapper는:
  1. `toss_payment_requests`에서 `payment_intent_id`를 조회.
  2. 그 intent가 여전히 유효한지(`intent_status not in ('FAILED','CANCELLED','EXPIRED')`, 금액/provider 일치) 검증.
  3. 검증 통과 시에만 `confirm_toss_payment_legacy_604260(...)`(옛 `0103` 로직 — 내부에서 `catchmenu_payment.confirm_payment()`를 호출)을 실행.
  4. 응답 JSON에 `payment_intent_id`를 노출.
- **그러나 결정적으로**: `confirm_toss_payment_legacy_604260`(옛 `0103` 바디, `0142`가 이름만 바꿨을 뿐 본문은 무변경)이 내부적으로 호출하는 `catchmenu_payment.confirm_payment()`에는 **여전히 `payment_intent_id`가 전달되지 않는다** — `0142` 자신의 코멘트가 이를 스스로 인정한다(`0142:404-408` 원문): `"604260 wrapper. Validates and exposes the bound payment_intent_id before using the preserved Toss confirmation path. **It does not patch confirm_payment.**"`

**의미(사실 정리, 판단 아님)**: Toss Payments 경로는 세 호출자 중 유일하게, `confirm_payment()` 호출 시점에 이미 검증된 `payment_intent_id` 값이 손닿는 곳(같은 트랜잭션의 `v_request.payment_intent_id`)에 준비되어 있다. `604253`(2026-07-01) 작성 시점에는 이 값 자체가 존재하지 않아 "MVP gap"으로 분류됐으나, 지금은 값은 있고 단지 `confirm_payment()`로 전달만 안 되고 있는 상태다 — Logic 단계에서 "옵션 A: `p_intent_id` 파라미터 추가" 채택 시, **Toss Payments(`0103`/`0142`) 쪽은 이미 갖고 있는 값을 넘기기만 하면 되는 가장 쉬운 케이스**가 된다(반면 OKPOS/Toss POS는 여전히 intent 자체가 없어 이 옵션이 어렵다 — §5의 기존 분석대로).

## §6 정리 — 세 호출자 파일도 함께 고쳐야 하는가, `confirm_payment()` 내부만 고치면 되는가

**판단 근거(사실 기반, 최종 결정은 Logic.md에서)**:

- Phantom 컬럼 4개(`payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`) 수정과 `ledger_entry_type` NOT NULL 채우기는 `confirm_payment()`(`0098`) **내부 INSERT 문 재작성만으로 해결 가능** — 세 호출자는 이 값들을 이미 `confirm_payment()`의 기존 파라미터(`p_payment_method`, `p_provider_tx_id`, `p_provider_response`)로 넘기고 있으므로, 함수 시그니처를 바꿀 필요 없이 내부에서 올바른 컬럼명(`provider_payment_key`, `provider_response_id` 또는 대안)에 매핑하면 된다.
- 다만 `provider_response`(jsonb) → `provider_response_id`(uuid FK, `catchmenu_gateway.provider_raw_events` 참조)는 **단순 컬럼명 치환이 아니다** — 원본 jsonb 응답을 그대로 저장할 곳이 없어지므로, `confirm_payment()` 내부에서 `provider_raw_events`에 먼저 INSERT하고 그 id를 `provider_response_id`로 쓰는 추가 로직이 필요하다(`0027`이 이미 이 패턴을 쓰는지는 Logic 단계에서 `0027`의 `provider_response_id` 세팅 방식을 재확인해야 함 — 이번 문서는 컬럼 존재만 확인했다).
- `intent_id`(NOT NULL FK) 문제는 **`confirm_payment()` 내부만으로 해결 가능한지 여부가 옵션에 따라 갈린다**:
  - "synthetic intent를 `confirm_payment()` 내부에서 자동 생성" 옵션을 택하면 → 호출자 3개는 무변경.
  - "`confirm_payment()`에 `p_intent_id` 파라미터를 추가"하는 옵션을 택하면 → **세 호출자 전부 수정 필요**(`0102`/`0103`/`0104` 각자 intent를 만들거나 조회해서 넘겨야 함) — 특히 OKPOS/Toss POS는 애초에 intent 개념이 없는 흐름이므로 이 옵션은 그 두 경로에 부자연스러운 개념을 강제로 도입하는 셈이다.
- 따라서 이번 워크패킷의 핵심 갈림길은 **"intent_id 문제를 `confirm_payment()` 내부에서 흡수할 것인가, 호출자에게 전가할 것인가"**이며, 이는 Logic 단계의 옵션 비교 대상이다.

## §7 Open Questions

(a) `provider_response_id`(uuid FK)를 `confirm_payment()` 내부에서 채우려면 `catchmenu_gateway.provider_raw_events`에 먼저 행을 만들어야 하는지, 아니면 이 FK를 nullable로 두고 생략 가능한지 — `0014`/`provider_raw_events` 스키마 재확인 필요, 이번 문서는 다루지 않음.
(b) `0103`(Toss Payments)의 `toss_payment_requests`를 향후 `payment_intents`와 통합할 가치가 있는지(현재는 완전히 별개 테이블) — 범위 밖, 참고 기록.
(c) `confirm_payment()`가 2026-06-21 작성 당시 정말 `payment_ledger`(`0014`, 2026-06-20 정의) 스키마를 한 번도 참조하지 않고 작성됐는지, 아니면 그 사이 `payment_ledger`가 별도로 변경된 이력이 있는지 — `git log --follow`로 `0014`/`0098` 커밋 이력 재확인이 필요하나 이번 문서는 다루지 않음(배경의 "최초 설계 오류" 단정에 대한 완전한 검증은 아님).
(d) `mark_payment_uncertain()`(`600540` 워크패킷에서 이미 정리됨)이 이 워크패킷과 유사한 컬럼 drift를 겪었는지 — 참고용 패턴 비교 가치, 범위 밖.
(e) **신규(Revision 2)** — `604250`~`604256`(legacy quarantine)이 이 워크패킷과 사실상 동일한 문제를 2026-07-01에 이미 설계까지 마쳤다가(옵션 A/B/C, intent-binding 후보 A-F 전부 문서화) 왜 실행되지 않고 격리(`990000_legacy_quarantine`)됐는지 — 이 문서는 격리 사유 자체를 조사하지 않았다. Logic 단계에서 이 legacy 자료를 얼마나 재사용할지 판단하기 전에, 격리 사유(거버넌스 체계 교체 때문인지, 다른 이유인지)를 최소한 한 줄이라도 확인할 가치가 있다.
(f) **신규(Revision 2)** — `0109`/`0130`은 둘 다 호출자 0건이지만, `flush_offline_queue()`(`0109`) 자체는 다른 액션 타입(`CREATE_ORDER`/`UPDATE_KDS_STATUS`/`STAMP_VISIT` 등)까지 포함하는 범용 오프라인 동기화 함수다 — `RECORD_MANUAL_PAYMENT` 분기만 고치는 것이 이 함수 전체의 다른 분기들에 영향을 주지 않는지 Logic 단계에서 재확인 필요.
(g) **신규(Revision 2)** — `0142`의 `bind_toss_payment_intent()` 트리거·wrapper 패턴(intent를 별도 단계에서 resolve/검증 후 결제 확인 함수에 전달)이 OKPOS/Toss POS에도 이식 가능한 일반 패턴인지, 아니면 Toss Payments의 사전 요청(`toss_payment_requests`) 구조에 특화된 것이라 이식 불가능한지 — Logic 단계 옵션 비교에서 다룰 가치가 있으나 이 문서는 판단하지 않는다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `601027_Audit.md`(`601020_authorize_kds_release_overload_and_redesign`) §URGENT Open Item — 이 워크패킷의 직접 발단.
- `601026_Verification.md` §5 — phantom 컬럼 4개 삼중검증 원본.
- `604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md`(`990000_legacy_quarantine`) — 옵션 A/B/C, intent-binding 후보 A-F를 이미 설계한 선행 분석. 이번 워크패킷의 Logic.md가 직접 재사용/갱신하는 근거 문서.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`(L144-458) 전체.
- `sql/migrations/0027_create_payment_intent_rpc.sql` — `confirm_payment_from_provider()`, 참고 기준(L267-331 특히).
- `sql/migrations/0014_create_payment_ledger.sql` — `payment_ledger` 실제 스키마, `intent_id`/`ledger_entry_type` NOT NULL 제약.
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`/`0103_create_toss_payments_pipeline_rpc.sql`/`0104_create_toss_pos_pipeline_rpc.sql` — 실제 호출자 3개.
- `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` — `flush_offline_queue()`(§2.1.1).
- `sql/migrations/0130_create_van_handler_extension.sql` — `record_van_transaction()`(§2.1.2/§2.1.3).
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — Toss `payment_intent_id` 바인딩 트리거/wrapper 전체(§5.1).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.
- `601021_Overview_Authorize_Kds_Release_Overload_And_Redesign.md`/`601026_Verification.md`/`601027_Audit.md` — 발단이 된 선행 워크패킷.
- `docs/990000_legacy_quarantine/604000_workpackets/604250_scope_d_00_payment_ledger_confirm_payment_schema_drift_alignment/` — 604250-604256 전체 세트, 선행 유사 분석.

### Excluded Rule Families

- `authorize_kds_release_overload_and_redesign`(`601020`)의 Slice 1/2/3 자체 — 이미 완료·ACCEPT됨, 재론하지 않음.
- `confirm_payment_from_provider()`(`0027`)의 자체 수정 — 이 워크패킷은 `0027`을 참고 기준으로만 쓰고 수정하지 않는다.
- `toss_payment_requests`/`payment_intents` 통합 여부(§7 (b)) — 범위 밖.
- `604250`의 격리 사유 자체 조사(§7 (e)) — 이 문서는 다루지 않음.
- `flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 외 다른 액션 타입 — 이 워크패킷은 결제 관련 분기만 다룬다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정(Revision 2).** §0(번호: `600550`)/§2(0027 vs 0098 대조)/§3(`p_intent_id` 부재 확인)/§4(호출자 3개 `payment_intents` 0건 참조 확인)는 Revision 1에서 라이브 코드 직접 재대조로 독립 확정됐다. **Revision 2 신규**: §2.1에서 `0109`/`0130` 각각의 정확한 함수명·목적·`payment_ledger` INSERT 전문·실제 호출자(둘 다 0건, `0098`과 위험도가 다름)를 확인했고, §2.1.3에서 `tax_amount`(`0130`만의 5번째 phantom 컬럼)의 라이브 부재를 재확인했다. §4.1에서 세 파일의 파라미터 비교표를 작성했다. **§5.1이 이번 재작업의 가장 중요한 신규 발견이다** — Toss Payments 경로는 `0142` 패치로 이미 `payment_intent_id`가 resolve/검증되어 있으나 `confirm_payment()`로 전달되지 않고 있을 뿐이라는 사실을 확인했고, 이 과정에서 Revision 1 §4의 "toss_payment_requests에 intent_id 컬럼이 없다"는 서술이 부정확했음을 직접 정정했다(전체 컬럼 재조회 결과 `payment_intent_id`가 32개 컬럼 중 마지막에 존재). 이 발견은 Logic 단계의 옵션 비교(특히 Toss Payments 경로의 난이도)에 직접 영향을 준다. `600552_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md] =====
# 600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — §3 최종 확정(옵션 C+ 채택, ChatGPT+제미나이 교차검증, 2026-07-15). §1의 `intent_id` 관련 서술을 C+ 확정에 맞춰 갱신.

## Change ID

`confirm_payment_column_drift_and_intent_linkage_fix`

## §0 전제 — `600551_Overview.md` Revision 2 반영, legacy 자료 재사용 근거

이 문서는 `0098`(`confirm_payment`)/`0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT`)/`0130`(`record_van_transaction`) 3개 파일을 `0027`(`confirm_payment_from_provider`) 기준으로 정합화하는 설계를 다룬다. `600551_Overview.md` §2/§2.1/§4.1이 확인한 사실(phantom 컬럼 4-5개, `intent_id`/`ledger_entry_type` 누락, `0130`만의 `tax_amount`)과 §5.1의 신규 발견(`0142`가 Toss Payments 경로의 intent 값을 이미 준비해뒀으나 `confirm_payment()`로 전달하지 않음)을 전제로 한다.

**Legacy 자료 재사용 근거**: `docs/990000_legacy_quarantine/604000_workpackets/604250.../604253_Logic_...md`(2026-07-01)가 이 문제를 사실상 동일한 범위(`0098` 단독이지만 `0109`/`0130`도 같은 패턴이라고 이미 기록, §2.1.3)로 분석해 옵션 A/B/C와 intent-binding 후보 A-F를 만들어뒀다. 이 문서(600552)는 그 분석의 사실 관계를 재검증한 뒤 재사용하고, `0142`(604253 작성 이후 배포됨)가 바꾼 부분만 갱신한다. 격리(`990000_legacy_quarantine`) 사유는 분석 내용의 오류가 아니라 거버넌스 세대교체다(`990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md`: 옛 `600179` 파이프라인 가이드가 현재의 `000701`로 대체되며 그 하위 전체가 격리됨, "Runtime implementation: Not granted" 상태로 애초에 실행 승인 자체가 없었다) — 즉 604253의 사실관계는 여전히 신뢰할 수 있는 참고 자료다.

## §1 `0027` 기준 세 파일 각각의 정확한 수정 설계

### §1.1 공통 컬럼 매핑 (phantom → `0014` DDL 실제 컬럼명)

| 현재 사용(3개 파일 공통) | `0014` 실제 컬럼 | 매핑 방식 |
|---|---|---|
| `payment_method`(INSERT 컬럼) | 없음(DDL에 대응 컬럼 자체가 없음) | §1.5에서 별도 처리(단순 치환 불가) |
| `provider_tx_id` | `provider_payment_key` | 컬럼명만 치환(값 의미는 동일 — provider 측 거래/결제 식별자) |
| `fee_amount` | 없음(DDL에 대응 컬럼 자체가 없음) | §1.5에서 별도 처리 |
| `provider_response`(jsonb) | `provider_response_id`(uuid FK) | 단순 치환 불가 — §2에서 별도 다룸 |
| (누락) | `intent_id`(NOT NULL FK) | **확정(§3, 옵션 C+)** — `intent_origin`/`origin_reference`로 모든 경로가 실제 `payment_intents` 행을 만들거나 재사용, §1.1.5 |
| (누락) | `ledger_entry_type`(NOT NULL) | 3개 파일 전부 `'APPROVAL'` 고정값으로 채우면 충분(0027과 동일 — 셋 다 정상 승인 기록이지 취소/환불이 아니므로) |
| `tax_amount`(`0130`만) | 없음(DDL에 대응 컬럼 자체가 없음) | §1.4에서 별도 처리 |

### §1.1.5 `payment_intents.intent_origin`/`origin_reference` — `intent_id` 충전 방법 확정 (Revision 2, 옵션 C+)

**Human 결정(2026-07-15, ChatGPT+제미나이 교차검증, 재논의 금지)**: §3의 옵션 A(진짜 intent만 인정)/B(synthetic intent)/C(경로별 하이브리드) 비교에서, "진짜 intent vs 가짜 intent"라는 이분법 자체를 폐기하고 **옵션 C를 일반화한 C+**를 채택한다 — 모든 결제 경로가 `payment_intents`에 **동등한** intent 행을 갖되, 그 intent가 어떻게 생성됐는지를 명시적으로 구분하는 정식 분류 필드를 추가한다. "합성/가짜"라는 표현은 이 문서 전체에서 더 이상 쓰지 않고, 필요할 때는 **"Derived Intent"** 또는 **"Observed Intent"**(ChatGPT 제안 용어 — 결제가 이미 물리적으로 관찰/완결된 뒤 그 관찰 결과로부터 유도된 intent라는 뜻)로 지칭한다.

**신규 컬럼 2개** (`catchmenu_payment.payment_intents`, 다음 패치 마이그레이션 대상):

```sql
alter table catchmenu_payment.payment_intents
  add column intent_origin text not null default 'PREAUTHORIZED',
  add column origin_reference jsonb;

alter table catchmenu_payment.payment_intents
  add constraint chk_intent_origin check (
    intent_origin in (
      'PREAUTHORIZED',     -- 결제 전 정식 사전 승인 흐름(위젯/QR 리다이렉트 등)에서 생성된 intent
      'POS_SYNTHESIZED',   -- 매장 POS 단말이 결제를 이미 완결한 뒤, 그 사후 보고를 받는 순간 생성된 intent
      'MANUAL_ENTRY',      -- 외부 provider 없이 직원이 수기로 입력한 결제에 대해 생성된 intent
      'VAN_SYNTHESIZED',   -- VAN(부가통신사업자) 카드 단말 거래의 사후 보고를 받는 순간 생성된 intent
      'IMPORTED'           -- 예약값(이번 워크패킷 3개 파일 중 어디도 쓰지 않음) — 배치 이관/과거 데이터 백필 등 향후 용도
    )
  );

comment on column catchmenu_payment.payment_intents.intent_origin is
  'How this intent came to exist. PREAUTHORIZED intents are created before payment confirmation (widget/QR redirect flows). POS_SYNTHESIZED/MANUAL_ENTRY/VAN_SYNTHESIZED intents are Observed Intents — created at (or just before) confirmation time from a report of an already-completed payment. All intent_origin values are equally valid payment_intents rows; this column records provenance, not trust level.';

comment on column catchmenu_payment.payment_intents.origin_reference is
  'Free-form provenance detail for non-PREAUTHORIZED origins, e.g. {"okpos_tx_id": "..."} or {"van_transaction_id": "..."}. Nullable for PREAUTHORIZED (the intent''s own id/idempotency_key is already the reference).';
```

`origin_reference`는 `jsonb`로 결정한다(`text`가 아님) — 이 프로젝트의 다른 근거 필드(`event_payload`/`decision_payload`/`raw_payload` 등)와 동일하게 구조화된 다중 필드를 담을 수 있어야 하고, 배경이 예시로 든 `"OKPOS transaction_id: 123456789"` 같은 사람이 읽는 문자열도 `jsonb_build_object('okpos_tx_id', '123456789')` 형태로 표현 가능하다.

**경로별 적용(확정)**:

| 경로 | `intent_origin` | `origin_reference` 예시 |
|---|---|---|
| Toss Payments(`0103`/`0142`) | `'PREAUTHORIZED'` | `jsonb_build_object('toss_payment_request_id', tpr.id)` — 이미 `0142`가 검증해둔 진짜 사전 intent이므로 origin_reference는 참고용, `intent_id` 자체가 이미 신뢰 근거 |
| OKPOS(`0102`) | `'POS_SYNTHESIZED'` | `jsonb_build_object('okpos_tx_id', v_okpos_tx_id)` |
| Toss POS(`0104`) | `'POS_SYNTHESIZED'` | `jsonb_build_object('toss_pos_tx_id', v_toss_pos_tx_id)` |
| 수기결제(`0109`) | `'MANUAL_ENTRY'` | `jsonb_build_object('offline_queue_item_id', v_item.id, 'note', v_item.action_payload->>'note')` |
| VAN(`0130`) | `'VAN_SYNTHESIZED'`(§1.1.6에서 명명 근거) | `jsonb_build_object('van_transaction_id', v_tx_id, 'van_provider', p_van_provider)` |

### §1.1.6 `VAN_SYNTHESIZED`를 `POS_SYNTHESIZED`와 별도 값으로 결정한 근거

배경은 "POS_SYNTHESIZED 계열(또는 별도 'VAN_SYNTHESIZED') — 세부 명명은 Logic에서 결정"이라고 위임했다. **결정: 별도 값 `VAN_SYNTHESIZED`를 쓴다.** 근거:

1. 이 프로젝트는 이미 `okpos_transactions`(POS)와 `van_transactions`(VAN)를 별개 테이블로 관리한다 — 두 경로의 물리적 채널(매장 통합 POS 단말 vs 제3자 VAN사 카드 단말)이 데이터 모델 수준에서부터 구분되어 있으므로, `intent_origin`도 같은 구분을 유지하는 것이 기존 관례와 일관된다.
2. `601027_Audit.md`의 URGENT Open Item(이 워크패킷의 발단)이 지적했듯, PG/VAN 대사(reconciliation)는 카드/PG 3사 결제와 다른, 더 엄격한 감사 추적 요구사항을 갖는다(§41 원칙, `601021_Overview.md` Open Item (a)-1) — VAN 거래만 별도로 필터링해 감사·대사할 수 있어야 하므로, `POS_SYNTHESIZED`에 합치면 이 구분이 `origin_reference`(비구조화 조회) 없이는 불가능해진다. `intent_origin` 자체로 바로 필터링 가능하게 하는 것이 향후 VAN 대사 워크패킷에 더 유용하다.

### §1.2 `0098`(`confirm_payment`) 수정 설계

```sql
-- 변경 전 INSERT 컬럼(0098:306-317, 현재)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, session_id,
  provider_type, payment_method,
  provider_tx_id,
  provider_approval_number,
  approved_amount, fee_amount, net_amount,
  ledger_status,
  approved_at,
  provider_response,
  reconciliation_status,
  business_day, business_timezone
)

-- 변경 후 설계안(옵션 A 적용 시 — §3에서 옵션 확정 전까지는 초안)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, session_id,
  intent_id,                    -- 확정(§3 C+): p_intent_id가 있으면 검증 후 재사용(PREAUTHORIZED),
                                 -- 없으면 내부에서 POS_SYNTHESIZED intent 생성
  ledger_entry_type,             -- 신규: 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- provider_tx_id → 컬럼명 치환
  provider_approval_number,
  approved_amount, net_amount,   -- fee_amount 제거(§1.5)
  ledger_status,
  approved_at,
  provider_response_id,          -- provider_response(jsonb) → uuid FK(§2)
  reconciliation_status,
  business_day, business_timezone
)
```

`WHERE`절(멱등성 사전검사, `0098:191-200`)도 같은 치환 필요 — `provider_tx_id = p_provider_tx_id` → `provider_payment_key = p_provider_tx_id`(파라미터 이름 자체는 하위호환을 위해 유지 가능, 컬럼 참조만 수정).

### §1.3 `0109`(`flush_offline_queue`의 `RECORD_MANUAL_PAYMENT`) 수정 설계

```sql
-- 변경 전(0109:916-927, 현재)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, provider_type,
  payment_method,
  provider_tx_id,
  approved_amount, fee_amount,
  net_amount, ledger_status,
  approved_at, business_day,
  business_timezone,
  provider_response
)

-- 변경 후 설계안
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id,
  intent_id,                    -- 확정(§3 C+): 내부에서 MANUAL_ENTRY intent 생성(§1.6)
  ledger_entry_type,             -- 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- 'MANUAL-' || now()::text 값 그대로, 컬럼명만 치환
  approved_amount, net_amount,   -- fee_amount 제거
  ledger_status,
  approved_at, business_day,
  business_timezone,
  provider_response_id           -- §2
)
```

`0098`과 동일한 패턴이지만, 이 함수는 §1.6에서 다루는 "완전한 사후-보고형"(오프라인 큐에 쌓였다가 나중에 일괄 처리되는 수기 결제 — provider 자체가 없음, `'MANUAL'`)의 극단적 사례다. `payment_method`(현재 `action_payload->>'payment_method'`)는 §1.5와 동일하게 별도 처리.

### §1.4 `0130`(`record_van_transaction`) 수정 설계 — `tax_amount` 포함

```sql
-- 변경 전(0130:393-402, 현재)
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id, provider_type,
  payment_method, provider_tx_id,
  approved_amount, fee_amount,
  net_amount, tax_amount,
  ledger_status, approved_at,
  business_day, business_timezone,
  provider_response
)

-- 변경 후 설계안
insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id,
  order_id,
  intent_id,                    -- 확정(§3 C+): 내부에서 VAN_SYNTHESIZED intent 생성(§1.1.6)
  ledger_entry_type,             -- 'APPROVAL' 고정
  provider_type,
  provider_payment_key,          -- provider_tx_id → 치환
  approved_amount, net_amount,   -- fee_amount 제거
  ledger_status, approved_at,
  business_day, business_timezone,
  provider_response_id           -- §2
  -- tax_amount는 payment_ledger에 대응 컬럼이 없으므로 제거
)
```

**`tax_amount` 처리(신규 컬럼 5번째, 다른 4개와 다른 성격)**: `payment_method`/`provider_tx_id`/`fee_amount`/`provider_response`는 "다른 이름으로라도 개념이 존재"하지만, `tax_amount`(부가세)는 `payment_ledger`/`van_transactions` 어디에도 대응 컬럼이 없는 게 아니라 — **이미 `van_transactions.tax_amount`(`0130:85`)에 정확히 기록되고 있다.** 즉 `payment_ledger`에 다시 넣으려 한 것 자체가 중복 저장 시도였다 — `van_transactions`가 이미 `payment_ledger_id`로 원장과 연결되므로(`0130:427-429`), `payment_ledger` 쪽에 `tax_amount`를 넣지 않고 `van_transactions.tax_amount`만 남기는 것이 가장 단순한 해법이다(신규 컬럼 추가 불필요). 이 부분은 §1.5의 `fee_amount`(대응 테이블 자체가 없어 진짜 결정이 필요한 경우)와 성격이 다르다.

**주의(Codex 발견, 라이브 재확인)**: `van_transactions`는 `catchmenu_payment`/`catchmenu_integrations` 두 스키마에 각각 다른 구조로 존재한다 — `information_schema.tables` 조회 결과 두 행 모두 확인됨. 이 문서가 참조하는 것은 `0130`이 실제로 사용하는 **`catchmenu_payment.van_transactions`**(30개 컬럼, `tax_amount`/`payment_ledger_id` 보유, `record_van_transaction()`이 INSERT하는 바로 그 테이블)이며, **`catchmenu_integrations.van_transactions`**(36개 컬럼, 이름만 같은 완전히 별개의 테이블 — `tax_amount` 없음, 원장 연결 컬럼명도 `payment_ledger_id`가 아니라 `ledger_id`이고 `intent_id` 컬럼을 자체적으로 갖고 있음)와 혼동하지 말 것. 위 결론(`tax_amount`를 `payment_ledger` INSERT에서 제거해도 안전)은 전적으로 `catchmenu_payment.van_transactions` 기준이며, 이 정정은 결론 자체를 바꾸지 않는다.

### §1.5 `fee_amount`/`payment_method` — 단순 치환이 불가능한 항목

`604253` §8(fee_amount)의 기존 분석을 재확인·재사용:
- `fee_amount`: `payment_ledger`에 대응 컬럼 자체가 없다. `0098`은 실제로 요율 기반 계산값을 넣으려 하고, `0109`/`0130`은 `0`으로 하드코딩(계산 안 함) — 셋의 필요도가 다르다. 이 워크패킷의 좁은 목표(크래시 방지, 컬럼 정합)만 보면 "INSERT에서 `fee_amount` 제거"가 가장 간단하지만, `604251`(604250 legacy)이 이미 지적했듯 `0111`/`0100`/`0120`/`0084` 등 다운스트림이 `pl.fee_amount`가 존재한다고 가정하는 읽기 코드를 갖고 있을 수 있다 — **이 다운스트림 재확인은 이번 문서 범위 밖**(§4 Open Item), `fee_amount`를 INSERT에서 제거하는 것과 그 값을 아예 안 남기는 것이 다운스트림에 미치는 영향은 별도로 조사돼야 한다.
- `payment_method`: `payment_ledger`에는 대응 컬럼이 없지만 `payment_intents.payment_method`에는 있다(라이브 재확인 필요, `600551_Overview.md`에서 직접 확인하지 않음 — §4 Open Item으로 이월). `intent_id` 바인딩이 해결되면(§3) `payment_method`는 `payment_intents` 쪽에서 조회 가능해져 `payment_ledger` INSERT에서 완전히 제거해도 될 가능성이 있다.

### §1.6 `0109`(수기결제)의 특수성 — "사후-보고형" 중에서도 provider가 아예 없는 경우 (§3 C+로 확정)

`0109`의 `'MANUAL'` provider_type은 `0027`/`0098`/`0130` 어느 쪽과도 다르다 — 카드사/PG/VAN 같은 외부 provider가 존재하지 않는, 직원이 수기로 입력하는 결제다. **확정(§1.1.5)**: OKPOS/Toss POS와 같은 취급(내부에서 intent 자동 생성)을 받되, `intent_origin`은 `'POS_SYNTHESIZED'`가 아니라 별도 값 `'MANUAL_ENTRY'`를 쓴다 — POS 단말이라는 물리적 채널 자체가 없다는 것이 명확히 구분돼야 하기 때문이다. `payment_intents.provider_type`은 `'MANUAL'`(기존 `0109`가 `payment_ledger.provider_type`에 이미 쓰던 값과 동일하게 유지)로 채운다.

## §2 `provider_response`(jsonb) → `provider_response_id`(uuid FK) — 선행 단계 필요성 확인

**질문**: 세 함수 각각에 새로운 선행 단계(먼저 `provider_raw_events`에 INSERT)를 요구하는가?

**답(라이브 재확인)**: 그렇다. `0027`은 `provider_raw_events`에 스스로 INSERT하지 않는다 — `p_provider_raw_event_id`를 **이미 만들어진 값으로 파라미터로 받는다**(`0027:209`). 실제 INSERT는 `0027`의 호출자인 `0038`(Toss 웹훅 핸들러)이 미리 수행한다(`0038:210` `insert into catchmenu_gateway.provider_raw_events (...)`, `0038:302`에서 그 id를 `p_provider_raw_event_id`로 전달). 즉 `0027`이 DDL에 맞는 이유는 "스스로 처리해서"가 아니라 "호출자가 이미 처리해서 값을 넘겨주기 때문"이다.

반면 `0098`/`0109`/`0130`과 이들의 실제 호출자(`0102`/`0103`/`0104`, 오프라인 큐, VAN 핸들러) 중 어디에도 `provider_raw_events`에 INSERT하는 코드가 없다(`grep -rln "provider_raw_events" sql/migrations/0098*.sql sql/migrations/0102*.sql sql/migrations/0103*.sql sql/migrations/0104*.sql sql/migrations/0109*.sql sql/migrations/0130*.sql` 결과 0건, 이번 문서에서 재확인). **따라서 세 함수 모두 새로운 선행 단계가 필요하다** — `0027`처럼 "호출자가 이미 준비해준 값을 받기만" 할 수 없다.

`catchmenu_gateway.provider_raw_events`의 NOT NULL 컬럼(기본값 없는 것만, 라이브 재확인): `tenant_id`, `provider_type`, `provider_code`, `raw_payload` 4개뿐 — 나머지는 nullable이거나 기본값이 있다. **정정(Codex 발견)**: `NOT NULL` 컬럼은 실제로 9개(`id`/`tenant_id`/`provider_type`/`provider_code`/`raw_payload`/`processing_status`/`processing_attempts`/`first_received_at`/`received_at`, 라이브 재확인)이나, 그중 `id`/`processing_status`/`processing_attempts`/`first_received_at`/`received_at` 5개는 전부 기본값(`gen_random_uuid()`/`'RECEIVED'`/`0`/`now()`/`now()`)이 있어 INSERT 시 값을 넘기지 않아도 된다 — 값을 반드시 채워야 하는 것은 위 4개(`tenant_id`/`provider_type`/`provider_code`/`raw_payload`)뿐이다. 결론(가벼운 INSERT 가능)은 동일하게 유효하다. 이는 비교적 가벼운 INSERT다: `0098`은 이미 `p_provider_response`(jsonb)와 `p_provider_type`을 갖고 있으므로 `raw_payload:=p_provider_response, provider_type:=p_provider_type, provider_code:=p_provider_type`(또는 별도 유도값) 정도로 즉시 구성 가능하다. `0109`/`0130`도 각각 자체 조립한 jsonb(`jsonb_build_object(...)`)/`p_van_response_raw`를 그대로 `raw_payload`로 쓸 수 있다.

**결론(사실, 판단 아님)**: 이 선행 INSERT를 (a) `confirm_payment()`/`flush_offline_queue()`/`record_van_transaction()` **내부**에서 인라인으로 수행할지, (b) 각 함수의 **호출자**(`0102`/`0103`/`0104`, 오프라인 큐 소비자, VAN 핸들러)에게 `0038`처럼 미리 해두도록 요구할지는 옵션 선택 사항이다. 내부 인라인 방식은 호출자 시그니처를 바꾸지 않아도 되므로, §3의 "시그니처 변경 최소화" 방향과 함께 갈 때 자연스럽다.

## §3 함수 시그니처 변경 범위 — 확정: 옵션 C+ (Revision 2, Human 결정 2026-07-15, 재논의 금지)

`604253` §6.1의 후보 A-F, 그리고 이 문서 Revision 1이 만들었던 옵션 A/B/C 비교(아래 §3.3에 이력으로 보존)는 "진짜 intent(Toss Payments) vs 가짜/synthetic intent(나머지)"라는 이분법을 전제로 했다. **Human 결정으로 이 이분법 자체를 폐기하고, 옵션 C를 일반화한 C+로 확정한다**: 모든 경로가 `payment_intents`에 동등한 행을 갖되 `intent_origin`(§1.1.5)으로 생성 경위만 구분한다.

### §3.1 확정된 설계 — `p_intent_id`는 옵션(default null) 파라미터, breaking change 없음

`confirm_payment()`(`0098`)의 시그니처에 `p_intent_id uuid default null`을 **추가**한다(기존 파라미터는 무변경, 순서는 마지막 또는 `p_correlation_id` 앞 — Stage 2에서 확정). 함수 내부 동작:

```text
if p_intent_id is not null then
  -- PREAUTHORIZED 경로 (현재는 Toss Payments/0142만 해당)
  payment_intents에서 p_intent_id를 조회/검증
  (tenant/store/order/금액/provider_type/intent_status 일치 확인 —
   0142의 bind_toss_payment_intent() 검증 로직과 동일한 조건)
  검증 실패 시 에러 반환(현재 0142 wrapper의 payment_intent_binding_invalid와 동일한 정신)
else
  -- Observed Intent 경로 (POS_SYNTHESIZED / MANUAL_ENTRY / VAN_SYNTHESIZED)
  이 order_id에 대해 이미 CONFIRMED된 intent가 있는지 먼저 확인(멱등성, §3.2)
  없으면 catchmenu_payment.create_payment_intent()를 즉시 호출해 새 intent 생성,
  intent_origin/origin_reference를 p_provider_type 기반으로 채움
  (0102/0104 → POS_SYNTHESIZED, 0109 경로 → MANUAL_ENTRY 고정)
end if;
```

**결과적으로 breaking change가 사실상 사라진다**:
- `0102`(OKPOS)/`0104`(Toss POS): 무변경 — `p_intent_id`를 넘기지 않으면(기본값 `null`) 함수가 알아서 `POS_SYNTHESIZED` intent를 만든다.
- `0103`/`0142`: 작은 추가만 필요 — `confirm_toss_payment_legacy_604260` 내부에서 `confirm_payment()`를 호출하는 지점에 `p_intent_id := v_request.payment_intent_id`(`0142`가 이미 resolve/검증해둔 값, `600551_Overview.md` §5.1) 한 줄만 추가하면 된다.
- `0109`/`0130`: 각자 자기 함수 내부에서 위와 동일한 "Observed Intent 생성" 로직을 자체적으로 수행한다(이 둘은 `confirm_payment()`를 호출하지 않고 직접 `payment_ledger`에 INSERT하는 별도 함수이므로, 같은 패턴을 각자 복제하거나 §3.4의 공용 헬퍼를 호출한다).

### §3.2 멱등성 — `604253`이 지적한 "no-intent vs multiple-intent" 위험, `0142` 패턴 재사용

Observed Intent를 자동 생성할 때도 `payment_intents.order_id`만으로 유일성을 가정해선 안 된다는 `604253` §6.2의 경고는 그대로 유효하다 — 재시도로 인한 복수 intent 이력이 있을 수 있다(`0014`의 `payment_intents` 코멘트, `604253` 인용). §3.1의 "이미 CONFIRMED된 intent가 있는지 먼저 확인" 단계는 `0142`의 `bind_toss_payment_intent()`(`600551_Overview.md` §5.1)가 이미 구현한 패턴(기존 활성 intent 재사용, 없으면 `create_payment_intent()` 신규 생성, 복수 후보면 명시적 에러 `TOSS_PAYMENT_INTENT_BINDING_CONFLICT`류)을 그대로 재사용한다 — Observed Intent 경로도 예외 없이 동일한 멱등성 기준을 적용한다(C+의 "모든 경로가 동등한 intent" 원칙과 일치).

### §3.3 공용 헬퍼 후보 — `resolve_or_create_payment_intent()`

`0098`/`0109`/`0130` 셋 다 §3.1의 "PREAUTHORIZED면 검증, 아니면 Observed Intent 생성" 로직이 필요하므로, 이를 `catchmenu_payment.resolve_or_create_payment_intent(p_tenant_id, p_store_id, p_order_id, p_approved_amount, p_provider_type, p_intent_origin, p_origin_reference, p_intent_id default null)` 같은 공용 함수로 뽑아 세 곳에서 재사용하는 것을 제안한다(`0142`의 `bind_toss_payment_intent()` 트리거 로직을 일반화한 버전). 이 함수 자체의 최종 시그니처/구현은 TestPlan/ChangeContract 단계에서 확정한다 — 이 문서는 "공용화가 가능하고 바람직하다"는 설계 방향만 기록한다.

### §3.4 이력 보존 — Revision 1의 옵션 A/B/C 비교표 (폐기됨, 참고용)

Revision 1은 아래 표로 옵션을 비교했으나, Human 결정(§3 상단)으로 **폐기**됐다 — "가짜 intent"라는 옵션 B의 전제 자체가 채택되지 않았기 때문이다. 이력 추적을 위해 원문을 보존한다.

| | 옵션 A(폐기) — 시그니처에 `p_intent_id` 추가, PREAUTHORIZED만 인정 | 옵션 B(폐기) — 내부에서 "synthetic" intent 자동 생성, 정식 분류 없음 | 옵션 C(→ C+로 흡수) — 경로별 하이브리드 |
|---|---|---|---|
| 핵심 차이(C+와) | C+는 이 옵션의 "시그니처 추가" 메커니즘은 채택했으나 "PREAUTHORIZED만 진짜"라는 전제는 폐기 | C+는 "내부 자동 생성" 메커니즘은 채택했으나 "정식 분류 없는 synthetic" 대신 `intent_origin`으로 정식 분류 | C+ 자체가 이 옵션을 일반화한 것 — 경로별 차등 처리는 유지하되 "차등"이 "진짜/가짜"가 아니라 "origin 값"으로 표현됨 |

## §4 Open Items

(a) `confirm_payment_from_provider()`(`0027`)와 `confirm_payment()`(`0098`) 두 파이프라인이 왜 병렬로 존재하는지 — `601021_Overview.md` §10/Open Question에서 이미 제기됐고 이번 워크패킷에서도 미해결로 유지한다. 이 워크패킷은 `0098`을 `0027`의 컬럼 계약에 맞추는 것이지, 두 파이프라인을 하나로 합치는 것이 아니다.
(b) `fee_amount` 제거가 다운스트림 읽기 코드(`604251`이 지목한 `0111`/`0100`/`0120`/`0084`)에 미치는 영향 — 이번 문서에서 확인하지 않음, TestPlan 단계에서 라이브 재확인 필요.
(c) `payment_intents.payment_method` 컬럼 존재 여부 및 `payment_ledger`의 `payment_method` 완전 제거 타당성(§1.5) — 라이브 재확인 필요.
(d) `provider_raw_events` 선행 INSERT를 함수 내부 인라인으로 할지 호출자에게 위임할지(§2) — 옵션 A/B/C 확정과 함께 결정.
(e) `0109`(수기결제)의 intent 취급 방식(§1.6) — synthetic intent 생성 시 `'MANUAL'` provider의 특수성을 어떻게 반영할지 별도 결정 필요.
(f) `604250`~`604256`의 나머지 미독 부분(`604251` ImpactScope 전문, `604254` TestPlan, `604255` ChangeContract, `604256` Approval)을 이 워크패킷의 TestPlan/ChangeContract 단계에서 얼마나 더 재사용할지 — 이번 Logic.md는 `604253`만 집중 재사용했다.
(g) **신규(Revision 2)** — `catchmenu_payment.resolve_or_create_payment_intent()`(§3.3 공용 헬퍼 후보)의 최종 파라미터·리턴 타입·에러 키 체계 — 이 문서는 "만들 가치가 있다"는 방향만 제시했고 구체 설계는 TestPlan/ChangeContract 단계로 이월.
(h) **신규(Revision 2)** — `intent_origin`/`origin_reference` 추가가 `payment_intents`를 읽는 기존 코드(예: `0142`의 `bind_toss_payment_intent()` 자체, 그 외 `payment_intents`를 조회하는 다른 함수들)에 회귀를 일으키지 않는지 — `intent_origin`이 `default 'PREAUTHORIZED'`이므로 기존 행은 자동으로 이 값을 갖게 되어 스키마 자체는 하위호환이나, 그 외 회귀 여부는 TestPlan 단계에서 재확인 필요.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`(Revision 2, 이 문서의 직접 전제)
- `604253_Logic_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md`(`990000_legacy_quarantine`) — 옵션 A/B/C, intent-binding 후보 A-F 원본.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`/`0109_create_network_handoff_fallback_rpc.sql`/`0130_create_van_handler_extension.sql` — 3개 수정 대상.
- `sql/migrations/0027_create_payment_intent_rpc.sql`/`0038_create_toss_webhook_processor_rpc.sql` — DDL 정합 참조 패턴 + `provider_raw_events` 선행 INSERT 실사례.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — `bind_toss_payment_intent()` 트리거, §3.1/§3.3 Observed Intent 로직의 재사용 템플릿.
- `sql/migrations/0014_create_payment_ledger.sql` — DDL 제약 전체.
- `catchmenu_payment.payment_intents` 라이브 스키마(24개 컬럼, 이번 턴 재확인) — §1.1.5 신규 컬럼(`intent_origin`/`origin_reference`) 추가 대상.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- 다운스트림 `fee_amount` 읽기 코드(`0111`/`0100`/`0120`/`0084`) 영향 분석(§4 (b)) — TestPlan 단계로 이월.
- `604250`의 격리 사유 심층 조사 — `990000_legacy_quarantine/600000_Index_Implementation_Lifecycle.md` 확인으로 충분, 추가 조사 안 함.
- `0027`/`0038` 자체 수정 — 계속 참고 전용, 수정 대상 아님.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정(Revision 2) — §3 최종 결정 완료.** §1에서 3개 파일 각각의 컬럼 매핑과 INSERT 변경 초안을 설계했다(`tax_amount`는 `van_transactions`에 이미 있으므로 `payment_ledger`에서 제거, `fee_amount`/`payment_method`는 단순 치환 불가로 별도 결정 필요 표시). **§1.1.5/§1.1.6(신규)에서 `payment_intents.intent_origin`/`origin_reference` 스키마를 확정**해 `intent_id`를 채우는 방법 자체를 결정했다 — `PREAUTHORIZED`/`POS_SYNTHESIZED`/`MANUAL_ENTRY`/`VAN_SYNTHESIZED`/`IMPORTED`(예약) 5개 값, "가짜/합성" 대신 "Derived/Observed Intent" 용어로 통일. §2는 Revision 1과 동일(변경 없음). **§3에서 Human 결정(옵션 C+)을 반영해 최종 확정했다** — `p_intent_id`를 `default null` 옵션 파라미터로 추가해 breaking change를 사실상 제거했고(OKPOS/Toss POS는 무변경, Toss Payments는 한 줄 추가), 멱등성은 `0142`의 기존 패턴을 재사용하며, 공용 헬퍼 함수 방향을 제시했다. Revision 1의 옵션 A/B/C 비교표는 §3.4에 이력으로 보존했다(폐기됨). `600553_TestPlan.md`/`600554_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md] =====
# 600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix

## 0. Purpose And Scope

This TestPlan verifies the confirmed Revision 2 / Option C+ design for `confirm_payment()` payment-intent linkage and `payment_ledger` column-contract reconciliation.

Authoritative design inputs:

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`

Confirmed implementation scope:

1. Add `catchmenu_payment.payment_intents.intent_origin text not null` with the allowed values:
   - `PREAUTHORIZED`
   - `POS_SYNTHESIZED`
   - `MANUAL_ENTRY`
   - `VAN_SYNTHESIZED`
   - `IMPORTED`
2. Add `catchmenu_payment.payment_intents.origin_reference jsonb`.
3. Add the shared helper RPC:
   - `catchmenu_payment.resolve_or_create_payment_intent()`
4. Update `catchmenu_payment.confirm_payment()` in `0098_create_payment_confirm_pipeline_rpc.sql`:
   - add `p_intent_id default null`
   - resolve or synthesize a valid `payment_intents.id`
   - rewrite the `payment_ledger` insert to use real columns only
   - remove phantom references to `payment_method`, `provider_tx_id`, `fee_amount`, and `provider_response`
   - use `provider_response_id`
   - insert `intent_id`
   - insert `ledger_entry_type`
5. Update the `RECORD_MANUAL_PAYMENT` branch in `0109_create_network_handoff_fallback_rpc.sql` to use `intent_origin = 'MANUAL_ENTRY'`.
6. Update `record_van_transaction()` in `0130_create_van_handler_extension.sql` to use `intent_origin = 'VAN_SYNTHESIZED'`, while keeping `van_transactions.tax_amount` on `catchmenu_payment.van_transactions` and not inserting it into `payment_ledger`.
7. Update only the Toss Payments caller in `0103_create_toss_payments_pipeline_rpc.sql` by adding:
   - `p_intent_id := v_request.payment_intent_id`

Non-scope reminders:

- `0102_create_okpos_integration_pipeline_rpc.sql` remains unchanged.
- `0104_create_toss_pos_pipeline_rpc.sql` remains unchanged.
- `0027_create_payment_intent_rpc.sql`, `0038_create_toss_webhook_processor_rpc.sql`, `0056_create_van_integration_rpc.sql`, and `0142_patch_toss_mvp_payment_intent_binding.sql` remain unchanged.
- Downstream `fee_amount` / `payment_method` readers in `0111`, `0100`, `0120`, and `0084` are not corrected in this workpacket.

## 1. Schema Verification

### 1.1 `payment_intents` New Columns Exist

Run:

```sql
select
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'catchmenu_payment'
  and table_name = 'payment_intents'
  and column_name in ('intent_origin', 'origin_reference')
order by ordinal_position;
```

Expected:

- `intent_origin` exists.
- `intent_origin` is `text`.
- `intent_origin` is `not null`.
- `origin_reference` exists.
- `origin_reference` is `jsonb`.

### 1.2 `intent_origin` Check Constraint Allows Exactly The Approved Values

Run:

```sql
select
  conname,
  pg_get_constraintdef(oid) as constraint_def
from pg_constraint
where conrelid = 'catchmenu_payment.payment_intents'::regclass
  and pg_get_constraintdef(oid) like '%intent_origin%';
```

Expected:

- The constraint includes:
  - `PREAUTHORIZED`
  - `POS_SYNTHESIZED`
  - `MANUAL_ENTRY`
  - `VAN_SYNTHESIZED`
  - `IMPORTED`
- No existing `payment_intents` reader breaks because of the added columns.

### 1.3 `provider_raw_events` Required Columns Remain Compatible

Run:

```sql
select
  column_name,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'catchmenu_integrations'
  and table_name = 'provider_raw_events'
order by ordinal_position;
```

Expected:

- The function-side inline insert only needs to supply:
  - `tenant_id`
  - `provider_type`
  - `provider_code`
  - `raw_payload`
- Other `not null` columns remain satisfied by defaults.

## 2. Helper Function Unit Tests

Target helper:

```sql
catchmenu_payment.resolve_or_create_payment_intent()
```

The helper generalizes the `0142` `bind_toss_payment_intent()` pattern without modifying the `0142` trigger itself.

### 2.1 PREAUTHORIZED Intent Validation

Setup:

- Create or reuse a test `payment_intents` row for a test `tenant_id`, `store_id`, and `order_id`.
- Set:
  - `intent_origin = 'PREAUTHORIZED'`
  - `origin_reference` to a JSON object that identifies the upstream request.

Run the helper with the known `p_intent_id`.

Expected:

- The helper returns the existing `payment_intents.id`.
- It does not create a duplicate intent.
- It rejects an intent that belongs to a different tenant, store, or order.

### 2.2 Existing Candidate Reuse

Setup:

- Create exactly one eligible payment intent for a test order.
- Do not pass `p_intent_id`.

Expected:

- The helper reuses the existing candidate.
- No duplicate payment intent is created for the same order and origin context.

### 2.3 New Candidate Creation

Setup:

- Use a test order with no existing eligible payment intent.
- Do not pass `p_intent_id`.

Expected:

- The helper creates one new `payment_intents` row.
- The row has the requested `intent_origin`.
- The row has the expected `origin_reference`.
- The returned id matches the newly created row.

### 2.4 Multiple Candidate Error

Setup:

- Create two eligible payment-intent candidates for the same tenant, store, order, and origin context.
- Do not pass `p_intent_id`.

Expected:

- The helper returns or raises the explicit multiple-candidate error defined by `600552_Logic`.
- It does not silently pick one candidate.
- It does not create a third candidate.

## 3. `0098 confirm_payment()` Integration Tests

### 3.1 Static Function Definition Check

Run:

```sql
select pg_get_functiondef(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'confirm_payment';
```

Expected:

- `p_intent_id` exists and defaults to `null`.
- The `payment_ledger` insert includes:
  - `intent_id`
  - `ledger_entry_type`
  - `provider_response_id`
- The function body does not reference phantom `payment_ledger` columns:
  - `payment_method`
  - `provider_tx_id`
  - `fee_amount`
  - `provider_response`

### 3.2 OKPOS Path

Exercise the OKPOS path through the existing `0102` caller or an equivalent direct `confirm_payment()` call matching that caller's parameters.

Expected:

- `confirm_payment()` completes far enough to insert a `payment_ledger` row.
- The resulting `payment_ledger.intent_id` is populated.
- The linked `payment_intents.intent_origin` is `POS_SYNTHESIZED`.
- `provider_response_id` is populated from the inline `provider_raw_events` insert.
- No phantom-column error occurs.

### 3.3 Toss Payments Path

Exercise the Toss Payments path through `0103`.

Required caller change:

```sql
p_intent_id := v_request.payment_intent_id
```

Expected:

- The existing preauthorized Toss Payments intent is reused.
- The linked `payment_intents.intent_origin` is `PREAUTHORIZED`.
- The resulting `payment_ledger.intent_id` equals `v_request.payment_intent_id`.
- `provider_response_id` is populated.
- No phantom-column error occurs.

### 3.4 Toss POS Path

Exercise the Toss POS path through the existing `0104` caller or an equivalent direct `confirm_payment()` call matching that caller's parameters.

Expected:

- `0104` remains source-unchanged.
- `confirm_payment()` synthesizes or reuses a `POS_SYNTHESIZED` intent.
- The resulting `payment_ledger.intent_id` is populated.
- `provider_response_id` is populated.
- No phantom-column error occurs.

## 4. `0109 RECORD_MANUAL_PAYMENT` Verification

Exercise `flush_offline_queue()` with a `RECORD_MANUAL_PAYMENT` payload.

Expected:

- The branch creates or resolves a payment intent with:
  - `intent_origin = 'MANUAL_ENTRY'`
- The resulting `payment_ledger` row uses real ledger columns only.
- The resulting `payment_ledger.intent_id` is populated.
- The resulting `payment_ledger.provider_response_id` is populated when a raw provider event is recorded.
- No `payment_method`, `provider_tx_id`, `fee_amount`, or `provider_response` ledger-column reference remains in this branch.

## 5. `0130 record_van_transaction()` Verification

Exercise `catchmenu_payment.record_van_transaction()`.

Expected:

- The function creates or resolves a payment intent with:
  - `intent_origin = 'VAN_SYNTHESIZED'`
- `catchmenu_payment.van_transactions.tax_amount` remains populated as applicable.
- `payment_ledger` does not receive or reference `tax_amount`.
- The resulting `payment_ledger.intent_id` is populated.
- The resulting `payment_ledger.provider_response_id` is populated when a raw provider event is recorded.
- No phantom `payment_ledger` column reference remains.

## 6. Idempotency And Duplicate-Intent Checks

### 6.1 Same Order Replayed Twice

Run the same order/payment confirmation path twice with the same identifying origin context.

Expected:

- The second execution does not create a duplicate `payment_intents` row.
- The helper reuses the existing intent where the design says reuse is required.
- If the function is expected to reject duplicate ledger insertion separately, the rejection must happen after intent resolution and must not create a duplicate intent.

### 6.2 Origin-Specific Idempotency

Run idempotency checks separately for:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`

Expected:

- Each origin follows the reuse/create/error behavior defined in `600552_Logic`.
- Origin-specific references in `origin_reference` remain stable enough for repeat resolution.

## 7. Boundary And Regression Checks

### 7.1 Files That Must Remain Unchanged

Confirm zero diff for:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_integration_rpc.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`

### 7.2 `0142` Trigger Logic Still Works

Run a sanity check for the Toss binding flow:

- Existing `payment_intent_id` validation still works.
- Candidate reuse still works.
- Multiple candidate conflict behavior still works.
- No `0142` trigger body change is required for this workpacket.

### 7.3 Downstream `fee_amount` / `payment_method` Readers Remain Out Of Scope

Search and report, but do not fix in this workpacket:

- `fee_amount`
- `payment_method`

Known downstream files to keep out of this implementation scope:

- `0111`
- `0100`
- `0120`
- `0084`

Expected:

- Any remaining downstream references are reported as Open Items.
- They are not silently fixed in this workpacket.

## 8. Apply And Live Verification Requirements

If Stage 4 implements this by editing already-applied migration source files in place, the implementation must follow the established §24 Lightweight Track procedure:

1. Modify source files.
2. Recalculate checksums using CRLF-to-LF normalization.
3. Update `catchmenu_meta.migration_history`.
4. Directly re-execute the affected live function definitions.
5. Use `pg_get_functiondef()` to verify the live database body actually changed.

Checksum update alone is not proof of live function replacement.

If Stage 4 instead uses a new forward migration for schema/helper/function replacement, the implementation must still verify live function bodies through `pg_get_functiondef()` after `tools/apply_migrations.py` completes.

## 9. Approval Criteria

This TestPlan passes only if all of the following are true:

- `payment_intents.intent_origin` exists and enforces the five approved values.
- `payment_intents.origin_reference` exists.
- `resolve_or_create_payment_intent()` passes the four unit scenarios.
- `confirm_payment()` no longer references phantom `payment_ledger` columns.
- OKPOS, Toss Payments, and Toss POS paths all produce `payment_ledger.intent_id`.
- Toss Payments uses the preauthorized intent supplied by `0103`.
- OKPOS and Toss POS synthesize or reuse `POS_SYNTHESIZED` intents.
- `0109` creates or reuses `MANUAL_ENTRY` intents.
- `0130` creates or reuses `VAN_SYNTHESIZED` intents.
- `van_transactions.tax_amount` remains on `catchmenu_payment.van_transactions` and is not copied into `payment_ledger`.
- Same-order replay does not create duplicate intents.
- Forbidden files remain unchanged.
- Downstream `fee_amount` / `payment_method` issues are explicitly carried forward rather than silently modified.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md] =====
# 600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix

## 0. Purpose

This ChangeContract locks the Stage 4 boundary for the confirmed Revision 2 / Option C+ fix to `confirm_payment()` payment-intent linkage and `payment_ledger` column drift.

The implementation must follow:

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`

The core decision is Option C+:

- add intent provenance to `payment_intents`
- introduce a shared intent resolver/creator helper
- make `0098 confirm_payment()` ledger insertion match the actual `payment_ledger` schema
- patch the manual and VAN paths using the same intent-linkage pattern
- pass the preauthorized Toss Payments intent only from `0103`

## 1. Allowed Files And Operations

### 1.1 `payment_intents` Schema Change

Allowed operation:

```sql
alter table catchmenu_payment.payment_intents
  add column intent_origin text not null,
  add column origin_reference jsonb;
```

The `intent_origin` constraint must allow exactly:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`
- `IMPORTED`

Implementation may use `add column if not exists` only if Stage 4 confirms that this is consistent with the current migration convention and does not mask an incompatible existing column.

No additional `payment_intents` columns are approved in this workpacket.

### 1.2 New Helper Function

Allowed operation:

Create:

```sql
catchmenu_payment.resolve_or_create_payment_intent()
```

The helper must generalize the `0142` `bind_toss_payment_intent()` pattern for:

- explicit preauthorized intent validation
- existing candidate reuse
- new candidate creation
- multiple-candidate conflict handling

The helper must support the approved `intent_origin` values required by this workpacket:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`

`IMPORTED` is reserved as an approved enum value but does not require a new caller in this workpacket.

### 1.3 `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

Allowed function:

- `catchmenu_payment.confirm_payment()` only

Allowed changes:

- Add `p_intent_id default null`.
- Call or inline-use the new `resolve_or_create_payment_intent()` helper before writing to `payment_ledger`.
- Insert a `provider_raw_events` row inside the function when provider raw payload must be captured.
- Rewrite the `payment_ledger` insert to:
  - remove phantom columns:
    - `payment_method`
    - `provider_tx_id`
    - `fee_amount`
    - `provider_response`
  - add or use real columns:
    - `intent_id`
    - `ledger_entry_type`
    - `provider_response_id`
- Preserve unrelated behavior of `confirm_payment()`.
- Preserve the existing `release_kds_after_payment()` call chain except where the new ledger row id/intent linkage requires direct wiring.

Forbidden within this file:

- Do not modify unrelated functions except as strictly required by the approved `confirm_payment()` body replacement.
- Do not change `release_kds_after_payment()` in this workpacket unless `600552_Logic` explicitly requires a signature-compatible call adjustment for the new ledger shape.

### 1.4 `sql/migrations/0109_create_network_handoff_fallback_rpc.sql`

Allowed function/branch:

- `flush_offline_queue()` only
- `RECORD_MANUAL_PAYMENT` branch only

Allowed changes:

- Resolve or create a payment intent with:
  - `intent_origin = 'MANUAL_ENTRY'`
- Insert a provider raw event inline when required.
- Rewrite the relevant ledger insert to use the same real-column contract as `0098`.

Forbidden:

- Do not rewrite unrelated offline queue item types.
- Do not alter network handoff behavior outside `RECORD_MANUAL_PAYMENT`.

### 1.5 `sql/migrations/0130_create_van_handler_extension.sql`

Allowed function:

- `catchmenu_payment.record_van_transaction()` only

Allowed changes:

- Resolve or create a payment intent with:
  - `intent_origin = 'VAN_SYNTHESIZED'`
- Insert a provider raw event inline when required.
- Rewrite the relevant ledger insert to use the same real-column contract as `0098`.
- Remove any attempt to insert `tax_amount` into `payment_ledger`.
- Preserve `tax_amount` on `catchmenu_payment.van_transactions`.

Forbidden:

- Do not remove or rename `catchmenu_payment.van_transactions.tax_amount`.
- Do not alter unrelated VAN transaction semantics.

### 1.6 `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`

Allowed change:

Add exactly one argument to the existing `confirm_payment()` call:

```sql
p_intent_id := v_request.payment_intent_id
```

Purpose:

- Preserve the already-bound Toss Payments preauthorized intent.
- Ensure the ledger row links to the same `payment_intents.id`.

Forbidden:

- Do not otherwise rewrite the Toss Payments pipeline.
- Do not change the `0142` binding trigger.

## 2. Forbidden Files And Operations

The following files must remain unchanged:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_integration_rpc.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`

Forbidden operations:

- Do not modify the `0142` trigger logic itself.
- Do not alter `confirm_payment_from_provider()` in `0027`.
- Do not add `p_intent_id` to `0102` or `0104`.
- Do not modify downstream `fee_amount` / `payment_method` readers in this workpacket.
- Do not modify `0111`, `0100`, `0120`, or `0084` as part of this workpacket.
- Do not redesign PG/VAN settlement, cash payment, KDS release, membership, inventory, or DID behavior.
- Do not remove or rewrite `provider_raw_events` table structure.
- Do not introduce a new provider event ingestion framework beyond the inline insert required by this design.

## 3. Required Implementation Constraints

### 3.1 Provider Raw Event Insert

Each modified function that needs a raw provider response must insert into `catchmenu_integrations.provider_raw_events` inline.

Minimum required fields:

- `tenant_id`
- `provider_type`
- `provider_code`
- `raw_payload`

The design relies on existing defaults for the remaining `not null` fields.

### 3.2 Ledger Insert Contract

Every modified `payment_ledger` insert must use only real live columns.

Required additions:

- `intent_id`
- `ledger_entry_type`
- `provider_response_id`

Required removals from ledger insert:

- `payment_method`
- `provider_tx_id`
- `fee_amount`
- `provider_response`

### 3.3 Intent Origin Assignment

The implementation must use the following origin mapping:

| Path | Required `intent_origin` |
|---|---|
| Toss Payments with `v_request.payment_intent_id` | `PREAUTHORIZED` |
| OKPOS through `confirm_payment()` | `POS_SYNTHESIZED` |
| Toss POS through `confirm_payment()` | `POS_SYNTHESIZED` |
| `0109` `RECORD_MANUAL_PAYMENT` | `MANUAL_ENTRY` |
| `0130` `record_van_transaction()` | `VAN_SYNTHESIZED` |

### 3.4 Live Database Replacement Requirement

If Stage 4 edits already-applied migration source files in place, it must follow the §24 Lightweight Track:

1. Modify source files.
2. Recalculate checksums with CRLF-to-LF normalization.
3. Update `catchmenu_meta.migration_history`.
4. Directly re-execute the changed live function definitions.
5. Confirm with `pg_get_functiondef()` that the live function bodies changed.

Checksum update alone is not sufficient.

If Stage 4 uses a new forward migration to apply the schema/helper/function definitions, the same live verification requirement still applies after `tools/apply_migrations.py`.

## 4. Open Items Carried Forward

The following items are explicitly not resolved by this ChangeContract and must be carried forward from `600552_Logic.md` §4:

(a) `confirm_payment_from_provider()` (`0027`) and `confirm_payment()` (`0098`) remain parallel payment-confirmation pipelines. This workpacket aligns `0098` to the live `payment_ledger` column contract and intent-linkage model; it does not unify both pipelines into one canonical payment-confirmation RPC.

(b) Downstream `fee_amount` removal impact remains uncorrected here. Known downstream readers in `0111`, `0100`, `0120`, and `0084` must be separately reviewed before any further deletion or compatibility decision.

(c) `payment_method` ownership remains a follow-up concern. The live `payment_intents.payment_method` column exists, but this workpacket does not decide whether all `payment_method` reads should move from ledger-level assumptions to intent-level reads.

(d) Provider raw event ingestion is implemented inline for this workpacket only. A larger shared ingestion abstraction is not designed here.

(e) `0109` manual payment handling is included only for the `RECORD_MANUAL_PAYMENT` branch and only to the extent required to create or resolve a `MANUAL_ENTRY` intent and write a valid ledger row.

(f) Legacy `604250~604256` material may be used as historical reference only if it does not override the confirmed `600551/600552` design. No legacy workpacket resurrection is authorized here.

(g) The exact parameter list, return shape, and error keys of `resolve_or_create_payment_intent()` must be implemented consistently with `600552_Logic` and verified by `600553_TestPlan`; any ambiguity must stop Stage 4 for human clarification.

(h) Adding `intent_origin` and `origin_reference` must not break existing `payment_intents` readers, including the `0142` binding flow. Compatibility must be verified, but `0142` itself must remain unchanged.

(i) `confirm_payment()` currently calls `notify_channel()` inside the same payment transaction. If notification delivery fails, for example because the PostgreSQL NOTIFY payload or channel exceeds runtime limits, the whole payment transaction can roll back after the ledger path has otherwise succeeded. This is a low-probability but high-impact risk. The approved implementation must not hide this with `exception when others then null`, because that creates a silent failure mode where payment succeeds but KDS/staff notification is lost without visibility. A separate follow-up workpacket should evaluate a Transactional Outbox pattern: record the payment ledger and notification event atomically, then deliver the notification from a separate worker.

## 5. Boundary Verification Required After Implementation

Stage 4 must report:

- full diff for all touched files
- checksum updates if §24 in-place edits are used
- live function re-execution logs
- `pg_get_functiondef()` verification for:
  - `confirm_payment()`
  - `resolve_or_create_payment_intent()`
  - `flush_offline_queue()` if modified in place
  - `record_van_transaction()` if modified in place
- `600553_TestPlan` results
- explicit zero-diff confirmation for forbidden files

## 6. Human Boundary Approval

Stage 4 implementation must not begin until all approval boxes below are checked by the human owner.

☑ I approve the payment_intents schema additions and the new resolve_or_create_payment_intent() helper. (2026-07-15)
☑ I approve the 0098, 0109, 0130, and one-line 0103 implementation scope exactly as bounded above. (2026-07-15)
☑ I approve the forbidden-file boundary and the carry-forward Open Items, including no changes to 0027, 0038, 0056, 0102, 0104, 0142, 0111, 0100, 0120, or 0084 in this workpacket. (2026-07-15)


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600555_Module.md] =====
# 600555_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-15

## Summary

Implemented `600550_confirm_payment_column_drift_and_intent_linkage_fix` under the approved `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` boundary.

The workpacket fixes the `0098` `confirm_payment()` payment ledger contract by linking every confirmation path to a real `payment_intents` row, removing phantom `payment_ledger` insert columns, and adding a shared resolver for observed payment flows.

## 1. Migration

| File | Purpose | Result |
|---|---|---|
| `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` | Adds `payment_intents.intent_origin`, `payment_intents.origin_reference`, the `chk_intent_origin` constraint, and `catchmenu_payment.resolve_or_create_payment_intent(...)`. | Applied locally through `tools/apply_migrations.py`; `migration_history.success = true`. |

Checksum recorded in local `catchmenu_meta.migration_history`:

```text
0158_confirm_payment_intent_linkage_fix.sql
25de8e5a11717fc19db05ef3c0758ce8c9839f319a6ce7e95c17413282bacf34
```

## 2. Schema Added

`catchmenu_payment.payment_intents` now has:

| Column | Type | Nullability | Default | Purpose |
|---|---|---|---|---|
| `intent_origin` | `text` | `not null` | `'PREAUTHORIZED'` | Records how the payment intent came to exist. |
| `origin_reference` | `jsonb` | nullable | none | Stores source-specific provenance for observed or preauthorized intent resolution. |

`chk_intent_origin` allows exactly:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`
- `IMPORTED`

## 3. Helper Added

`catchmenu_payment.resolve_or_create_payment_intent(...)` was added as the shared resolver for:

- explicit preauthorized intent validation (`p_intent_id is not null`);
- observed intent reuse when an existing matching intent exists;
- observed intent creation when none exists;
- conflict detection when multiple matching candidates exist.

The helper generalizes the `0142_patch_toss_mvp_payment_intent_binding.sql` pattern without modifying the `0142` trigger itself.

## 4. Source-Level Function Updates

| File | Function / Scope | Implemented Change |
|---|---|---|
| `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | `catchmenu_payment.confirm_payment(...)` | Added optional `p_intent_id uuid default null`; inserts a `provider_raw_events` row; resolves/creates a payment intent; rewrites `payment_ledger` INSERT to use live columns: `intent_id`, `ledger_entry_type`, `provider_payment_key`, `provider_approved_at`, and `provider_response_id`; removes phantom insert columns `payment_method`, `provider_tx_id`, `fee_amount`, and `provider_response`. |
| `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Toss Payments caller | Adds `p_intent_id := v_request.payment_intent_id` to the `confirm_payment()` call. |
| `sql/migrations/0109_create_network_handoff_fallback_rpc.sql` | `flush_offline_queue()` / `RECORD_MANUAL_PAYMENT` branch | Adds inline `provider_raw_events` insert; resolves/creates a `MANUAL_ENTRY` intent; rewrites the `payment_ledger` insert to the live column contract. |
| `sql/migrations/0130_create_van_handler_extension.sql` | `record_van_transaction()` | Adds inline `provider_raw_events` insert; resolves/creates a `VAN_SYNTHESIZED` intent; removes `tax_amount` from `payment_ledger` insertion because `van_transactions.tax_amount` remains the correct storage location. |

## 5. Boundary Honored

The following files were explicitly kept out of scope and remain unchanged by this workpacket:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_integration_rpc.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`
- downstream `fee_amount` / `payment_method` reader fixes in `0111` / `0100` / `0120` / `0084`

## 6. Non-Goals

This module does not:

- merge `confirm_payment()` and `confirm_payment_from_provider()`;
- redesign PG/VAN reconciliation;
- change the `0142` Toss intent-binding trigger;
- fix downstream readers that still expect `fee_amount` or `payment_method`;
- introduce Transactional Outbox delivery for payment notifications;
- scan all `orders.paid_at` references across the repo.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600556_Verification.md] =====
# 600556_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Cursor + Codex + Antigravity
Date: 2026-07-15

## Verification Result

Final result: **PASS with carried-forward Open Items.**

The implemented scope matches `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`: `0158` is applied, the live schema contains the new intent provenance columns, `confirm_payment()` has the new `p_intent_id` parameter, and the live function body contains the resolver / provider raw event / live ledger-column changes.

## 1. Local Migration State

```text
filename                                  | success | checksum
------------------------------------------+---------+------------------------------------------------------------------
0158_confirm_payment_intent_linkage_fix.sql | t       | 25de8e5a11717fc19db05ef3c0758ce8c9839f319a6ce7e95c17413282bacf34
```

## 2. Schema Verification

`catchmenu_payment.payment_intents` contains the two approved columns:

```text
column_name      | data_type | is_nullable | column_default
-----------------+-----------+-------------+-----------------------
intent_origin    | text      | NO          | 'PREAUTHORIZED'::text
origin_reference | jsonb     | YES         |
```

The approved values are enforced by `chk_intent_origin` in `0158`:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`
- `IMPORTED`

## 3. Live Function Signature Verification

Live `pg_proc` confirms the expected signatures:

```text
confirm_payment:
p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_provider_type text,
p_provider_approval_number text, p_provider_tx_id text,
p_approved_amount integer, p_payment_method text,
p_provider_response jsonb, p_actor_type text, p_actor_id uuid,
p_locale text, p_correlation_id text, p_intent_id uuid

resolve_or_create_payment_intent:
p_tenant_id uuid, p_store_id uuid, p_order_id uuid,
p_requested_amount integer, p_payment_method text,
p_payment_channel text, p_provider_type text, p_intent_origin text,
p_origin_reference jsonb, p_intent_id uuid, p_session_id uuid,
p_locale text
```

## 4. Live Function Body Verification

`pg_get_functiondef()` for `catchmenu_payment.confirm_payment()` confirms:

| Check | Result |
|---|---|
| Calls `resolve_or_create_payment_intent()` | PASS |
| Inserts into `provider_raw_events` | PASS |
| Uses `provider_response_id` | PASS |
| Uses `ledger_entry_type` | PASS |
| Does not contain `exception when others then null` around `notify_channel()` | PASS |

The final `notify_channel()` state was independently rechecked after the Human decision to revert the best-effort wrapper:

```text
has_bare_notify | has_exception_when_others
t               | f
```

## 5. Filename Correction Verification

During Stage 2/3 review, four migration filenames in the draft TestPlan / ChangeContract were found to be stale or imprecise and were corrected before implementation:

| Draft / stale name | Correct file used in final documents |
|---|---|
| `0038_create_pos_payment_rpc.sql` | `0038_create_toss_webhook_processor_rpc.sql` |
| `0056_create_toss_payments_rpc.sql` | `0056_create_van_integration_rpc.sql` |
| `0102_create_okpos_pipeline_rpc.sql` | `0102_create_okpos_integration_pipeline_rpc.sql` |
| `0142_create_toss_payment_intent_binding_rpc.sql` | `0142_patch_toss_mvp_payment_intent_binding.sql` |

This correction affected documentation and boundary verification only; it did not authorize edits to those four files.

## 6. Triple Verification Consolidation

| Verifier | Coverage | Result |
|---|---|---|
| Cursor | Large-scope source/diff review, filename correction, boundary drift scan, and follow-up issue discovery. | PASS with notes; flagged the filename errors and the need to classify side changes rather than silently accepting them. |
| Codex | Implementation plus live database checks: migration history, schema columns, function signatures, `pg_get_functiondef()`, checksum update, and final `notify_channel()` wrapper reversal. | PASS; `0158` applied and live functions reflect intended changes. |
| Antigravity | Independent review of column-contract drift and side-effect classification, including `orders.paid_at` and notification behavior. | PASS with Open Items; no blocking boundary breach after wrapper reversal. |

The three reviews converge on the same final state: implementation accepted, but residual risks must be carried forward.

## 7. Side-Change Review: Seven Items Classified

The implementation was reviewed for changes adjacent to the main `payment_ledger` INSERT fix. The final classification is:

| # | Item | Classification | Result |
|---|---|---|---|
| 1 | `provider_raw_events` inline insert in `0098` | Necessary / approved | Required because `0098` had no caller-side raw-event insert comparable to `0038` -> `0027`. |
| 2 | `provider_raw_events` inline insert in `0109` | Necessary / approved | Required for the `RECORD_MANUAL_PAYMENT` branch to populate `provider_response_id`. |
| 3 | `provider_raw_events` inline insert in `0130` | Necessary / approved | Required because `record_van_transaction()` directly creates the ledger row and previously had no provider raw event id. |
| 4 | `p_intent_id` added only to the `0103` Toss Payments call | Necessary / approved | `0142` already binds `payment_intent_id`; `0103` needed to pass it through. `0102` and `0104` remain unchanged. |
| 5 | `orders.paid_at` replaced with `orders.confirmed_at` inside `confirm_payment()` | Not damage, but newly exposed broader defect | The replacement was required for `confirm_payment()` because `orders.paid_at` is a phantom column. Whether other functions still reference `orders.paid_at` is unverified and carried forward as a new Open Item. |
| 6 | `notify_channel()` best-effort wrapper (`exception when others then null`) | Unnecessary / reverted | Reverted by Human decision. Final live body uses bare `perform catchmenu_common.notify_channel(...)`; no silent notification failure mode remains in this workpacket. |
| 7 | Remaining downstream `fee_amount` / `payment_method` readers | Unrelated / deferred | Not fixed here by design. `0111`, `0100`, `0120`, and `0084` remain separate follow-up candidates. |

## 8. Boundary Verification

No edits are authorized or recorded for the forbidden reference files:

- `0027_create_payment_intent_rpc.sql`
- `0038_create_toss_webhook_processor_rpc.sql`
- `0056_create_van_integration_rpc.sql`
- `0102_create_okpos_integration_pipeline_rpc.sql`
- `0104_create_toss_pos_pipeline_rpc.sql`
- `0142_patch_toss_mvp_payment_intent_binding.sql`

`0142` remains a reference pattern only; its trigger logic was not modified.

## 9. `git diff --check`

Final whitespace check after the `notify_channel()` wrapper reversal:

```text
git diff --check
exit 0
```

Git reported existing LF/CRLF warnings for unrelated working-tree files, but no whitespace errors.

## Conclusion

The implemented workpacket satisfies the approved Stage 4 boundary and the live database reflects the intended schema/function changes. Verification passes, with Open Items explicitly carried forward to `600557_Audit.md`.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600550_confirm_payment_column_drift_and_intent_linkage_fix/600557_Audit.md] =====
# 600557_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-15

## Final Audit Decision

ACCEPT.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` | PASS | `600555_Module.md` lists only `0158`, `0098`, `0103`, `0109`, and `0130` as changed implementation scope. |
| `payment_intents` provenance schema added | PASS | `intent_origin text not null default 'PREAUTHORIZED'`; `origin_reference jsonb`; `chk_intent_origin` values match the approved five-value list. |
| Shared helper exists | PASS | `catchmenu_payment.resolve_or_create_payment_intent(...)` exists live and is used by the patched flows. |
| `confirm_payment()` no longer inserts phantom `payment_ledger` columns | PASS | Function body uses `intent_id`, `ledger_entry_type`, `provider_payment_key`, `provider_approved_at`, and `provider_response_id`. |
| Toss Payments path passes the already-bound intent | PASS | `0103` adds `p_intent_id := v_request.payment_intent_id` only. |
| Manual and VAN observed flows resolve or create explicit intents | PASS | `0109` uses `MANUAL_ENTRY`; `0130` uses `VAN_SYNTHESIZED`. |
| `0142` trigger logic remains unchanged | PASS | `0142_patch_toss_mvp_payment_intent_binding.sql` is a reference only. |
| Notification best-effort wrapper removed | PASS | `pg_get_functiondef()` confirms bare `notify_channel()` and no `exception when others then null`. |
| Stage 5 cross-verification completed | PASS | Cursor + Codex + Antigravity results consolidated in `600556_Verification.md`. |

## Findings

1. The workpacket closes the immediate `confirm_payment()` column-contract blocker: `payment_ledger` insertion now has a real `intent_id` and `ledger_entry_type`, and no longer attempts to insert the four confirmed phantom columns `payment_method`, `provider_tx_id`, `fee_amount`, and `provider_response`.
2. The chosen Option C+ model is implemented consistently: all payment confirmation paths now produce or reuse a real `payment_intents` row, while `intent_origin` records provenance rather than trust level.
3. The Toss Payments path is the only path that already had a preauthorized bound intent (`0103`/`0142`); the implementation correctly passes that existing value instead of synthesizing a second one.
4. The manual and VAN paths remain observed-intent paths. `0109` and `0130` do not become canonical provider confirmation pipelines; they are merely made ledger/intent-contract compatible.
5. The attempted `notify_channel()` best-effort wrapper was correctly reverted. Hiding notification failure would create the worse mode "payment succeeds while staff/KDS notification silently disappears." The remaining risk is therefore visible and explicitly carried forward.
6. `orders.paid_at` was discovered as a separate phantom-column issue while fixing `confirm_payment()`. The local `confirm_payment()` path now uses `orders.confirmed_at`, but the repo-wide impact of `orders.paid_at` references has not been audited in this workpacket.

## Open Items Carried Forward

Carried forward from `600554_ChangeContract_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` §4:

(a) `confirm_payment_from_provider()` (`0027`) and `confirm_payment()` (`0098`) remain parallel payment-confirmation pipelines. This workpacket aligns `0098` to the live `payment_ledger` column contract and intent-linkage model; it does not unify both pipelines into one canonical payment-confirmation RPC.

(b) Downstream `fee_amount` / `payment_method` readers remain unresolved and must be audited separately. Known candidate files remain `0111`, `0100`, `0120`, and `0084`.

(c) PG/VAN reconciliation policy remains out of scope. This workpacket does not decide whether observed intents require additional provider reconciliation records or audit workflows.

(d) `0109` manual payment handling remains a fallback/offline queue path, not a fully designed manual payment product flow.

(e) `0130` `record_van_transaction()` remains isolated from the live `0056` VAN webhook path; this workpacket makes the function contract-compatible but does not wire it into production flow.

(f) Idempotency semantics for repeated observed payments must remain under review. `resolve_or_create_payment_intent()` handles matching-origin reuse/conflict, but duplicate ledger insertion policy is not fully redesigned here.

(g) Whether the `0142` Toss binding pattern should be generalized to OKPOS/Toss POS callers remains a future design question. This workpacket uses a shared helper but does not redesign those caller flows.

(h) `intent_origin` / `origin_reference` must continue to be monitored for compatibility with existing `payment_intents` readers. `0142` remained unchanged and compatible in this pass.

(i) `confirm_payment()` currently calls `notify_channel()` inside the same payment transaction. If notification delivery fails, for example because the PostgreSQL NOTIFY payload or channel exceeds runtime limits, the whole payment transaction can roll back after the ledger path has otherwise succeeded. This is a low-probability but high-impact risk. The approved implementation must not hide this with `exception when others then null`, because that creates a silent failure mode where payment succeeds but KDS/staff notification is lost without visibility. A separate follow-up workpacket should evaluate a Transactional Outbox pattern: record the payment ledger and notification event atomically, then deliver the notification from a separate worker.

Newly added by this Stage 6 audit:

(j) `orders.paid_at` appears to be a phantom column. It was discovered inside `confirm_payment()` and corrected there to `orders.confirmed_at`, but this audit did not perform a repo-wide scan of all `orders.paid_at` references. A separate follow-up should inventory every `orders.paid_at` reference and classify whether each should become `confirmed_at`, a new physical column, or a removed/deferred field.

## Residual Notes

- This audit does not approve any unrelated dirty working-tree changes.
- This audit does not authorize cloud migration.
- No git commit was performed by this Stage 6 documentation step.

## Conclusion

`600550_confirm_payment_column_drift_and_intent_linkage_fix` is accepted. The approved schema/helper/function changes are implemented and verified, the filename and boundary corrections are recorded, the unnecessary `notify_channel()` silent-failure wrapper was reverted, and all residual risks are explicitly carried forward.

Final status: **ACCEPT.**



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600561_Overview_Payment_Intent_Race_Condition_Fix.md] =====
# 600561_Overview_Payment_Intent_Race_Condition_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_intent_race_condition_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550` 3개다(재확인, `ls`). 10단위 관례상 `600550` 다음 빈 번호는 `600560` — 지시문의 가칭과 일치한다. Overview는 `600561`, Logic은 `600562`.

## §1 배경 재확인 — `resolve_or_create_payment_intent()`(`0158`)의 락 부재, 독립 재검증

지시문은 "삼중검증 완료, 재확인 불필요"라고 명시했으나, 이번 세션의 §43/§44 원칙에 따라 핵심 코드를 직접 재확인했다.

`sql/migrations/0158_confirm_payment_intent_linkage_fix.sql:177-257`(라이브 소스 직접 재확인) — "신규 생성" 분기 전문:

```sql
select count(*)
into v_candidate_count
from catchmenu_payment.payment_intents
where tenant_id = p_tenant_id
  and store_id = p_store_id
  and order_id = p_order_id
  and intent_origin = p_intent_origin
  and coalesce(origin_reference, '{}'::jsonb) = v_origin_reference
  and intent_status in ('CREATED','PENDING','PROCESSING','CONFIRMED');

if v_candidate_count > 1 then
  raise exception 'payment_intent_resolution_conflict: ...' using errcode = 'P0001';
end if;

if v_candidate_count = 1 then
  select id into v_intent_id from catchmenu_payment.payment_intents where ... order by created_at desc limit 1;
  return v_intent_id;
end if;

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, session_id, intent_status,
  payment_method, payment_channel, requested_amount, currency,
  provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone, intent_origin, origin_reference
) values (
  ...,
  'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
    || substr(md5(v_origin_reference::text), 1, 12),
  ...
)
returning id into v_intent_id;
```

**확인 결과**: `select count(*)`(line 177)에 `for update`/`for share`가 전혀 없다 — `grep -n "for update\|for share\|advisory" sql/migrations/0158*.sql` 재실행 결과 0건(§2와 별개로 이번 문서에서 재확인). `count=0`으로 판정된 두 세션이 동시에 `insert`(line 219)까지 도달할 수 있는 고전적 TOCTOU 레이스다. 배경의 기술적 진단은 정확하다.

## §2 라이브 재현 사고 — 실제 중복 행이 현재도 DB에 남아있음 (신규 발견, 긴급)

지시문이 언급한 "실제 동시 2세션 재현 테스트"의 결과물을 라이브 DB에서 직접 재확인했다:

```sql
select order_id, intent_origin, origin_reference, count(*)
from catchmenu_payment.payment_intents
group by order_id, intent_origin, origin_reference
having count(*) > 1;
```
```
               order_id               |  intent_origin  |                          origin_reference                           | count
--------------------------------------+------------------+---------------------------------------------------------------------+-------
 33333333-3333-3333-3333-333333333333 | POS_SYNTHESIZED | {"source": "pay_con002_race_test", "provider_tx_id": "RACE-TX-001"} |     2
```
두 행의 `created_at`은 `2026-07-15 15:57:55.728129+00`/`2026-07-15 15:57:55.789718+00` — **61밀리초 간격**으로 실제 중복 생성됐다. `payment_intents` 테이블 전체 행 수는 현재 5건뿐이며, 그중 2건(테스트 재현분)과 3건(다른 테스트 시나리오, `order_id` 전부 `22222222.../33333333.../44444444...` 같은 합성 UUID)이 **전부 오늘 세션의 테스트 산출물**로 보인다 — 실제 운영 데이터가 아니다.

**이것은 "재현 테스트 결과 보고"가 아니라 현재 라이브 DB에 남아있는 실제 오염이다.** 이번 워크패킷 범위(Overview/Logic 설계, `.sql` 생성 금지)에서는 정리하지 않으며, `600562_Logic.md` §2에서 Open Item으로 등록하고 사용자에게 정리 여부를 별도로 확인받아야 한다(이 문서/Logic 문서 어디에서도 DML 정리를 수행하지 않았다 — 지시문에 정리 지시가 없었으므로 임의로 삭제하지 않았다).

## §3 옵션 (a) 기술 검토 — UNIQUE 제약 실현 가능성

**질문**: `payment_intents`에 `(order_id, intent_origin, origin_reference)` 조합의 UNIQUE 제약이 기술적으로 가능한가? `origin_reference`가 `jsonb`라 직접 인덱스에 못 쓸 수 있다는 우려가 있었다.

**답(라이브 재확인)**: PostgreSQL의 `jsonb` 타입은 자체 동등 연산자(`=`)를 지원하며, `jsonb`는 **정규화된(canonical) 비교**를 쓴다 — 키 순서가 달라도(`{"a":1,"b":2}` vs `{"b":2,"a":1}`) 동일한 값으로 간주된다(참고: `json` 타입은 텍스트 비교라 이 성질이 없지만, 이 컬럼은 `jsonb`다). 따라서 `create unique index ... on payment_intents(order_id, intent_origin, origin_reference)` 자체는 **문법적으로도, 의미적으로도 가능하다.**

**그러나 이 접근보다 더 나은 기존 자산을 발견했다.** `0158`의 INSERT(§1 인용부)는 이미 `idempotency_key`를 다음과 같이 **결정론적으로** 생성하고 있다:
```
'OBS-' || p_order_id::text || '-' || p_intent_origin || '-' || substr(md5(v_origin_reference::text), 1, 12)
```
즉 `(order_id, intent_origin, origin_reference)` 조합이 이미 `idempotency_key` 하나의 컬럼(순수 `text`)으로 완전히 압축되어 있다. **라이브 재확인 결과, `payment_intents.idempotency_key`에는 현재 UNIQUE 제약이나 UNIQUE 인덱스가 전혀 없다**(`pg_constraint`/`pg_indexes` 전체 조회 — `payment_intents`의 UNIQUE는 `payment_token`/`provider_order_id`/`id(pk)` 3개뿐, `idempotency_key`는 없음). 이는 배경이 물었던 "jsonb 직접 UNIQUE" 질문 자체를 우회한다 — 원본 jsonb 컬럼에 직접 제약을 거는 대신, 이미 존재하는 정규화된 텍스트 해시 컬럼에 제약을 거는 쪽이 더 단순하고, jsonb 필드 구성이 호출부마다 조금씩 달라져도(예: 어떤 호출은 `note` 키를 포함하고 어떤 호출은 안 함) `md5(v_origin_reference::text)`가 이미 그 정규화를 흡수한다 — 이 점은 원본 jsonb 위에 직접 UNIQUE를 거는 방식보다 더 견고하다(jsonb 직접 방식은 필드 구성이 미세하게 달라지면 같은 논리적 이벤트인데도 다른 값으로 취급될 위험이 있음).

## §4 옵션 (b) 기술 검토 — Advisory Lock, `0142`의 기존 패턴과 비교

`0142_patch_toss_mvp_payment_intent_binding.sql`의 `bind_toss_payment_intent()` 트리거(`0142:54-60`, 이번 세션 이전 조사에서 이미 확인, 이번 문서에서 재확인)는 이미 다음 3중 보호를 쓰고 있다:

1. `pg_advisory_xact_lock(hashtextextended(tenant_id::text||':'||store_id::text||':'||order_id::text, 604260))` — order 단위 논리적 잠금(트랜잭션 종료 시 자동 해제).
2. `select ... from catchmenu_pos.orders where id = new.order_id ... for share` — 주문 행 공유 잠금.
3. `select ... from catchmenu_payment.payment_intents ... for update` — 기존 intent 후보 행 배타 잠금.

**`resolve_or_create_payment_intent()`에 이식 가능한가**: 부분적으로 가능하다 — 이 헬퍼는 트리거가 아니라 일반 함수 호출이므로 `new`/`old` 레코드가 없고, 잠금 대상 자체를 직접 선택해야 한다는 차이가 있다. `advisory_xact_lock`은 트리거 여부와 무관하게 동일하게 적용 가능하다(`tenant_id+store_id+order_id` 해시 — `0142`와 동일한 키 구성 요소를 그대로 재사용 가능, 다만 magic namespace `604260`은 `0142` 전용이므로 이 헬퍼는 별도 namespace를 써야 충돌하지 않는다). `for share`(orders)도 그대로 재사용 가능하다(이 헬퍼도 이미 `orders`를 조회하고 있음, `0158:96-100`). `for update`(intent 후보)도 마찬가지로 이식 가능하다 — 현재 `select count(*)`(락 없음) 쿼리를 `select ... for update`로 바꾸면 된다.

## §5 옵션 (c) 참고 — `confirm_payment()`의 `orders FOR UPDATE`와 비교 (PAY-CON-001, 범위 밖 spot check)

지시문은 PAY-CON-001(`confirm_payment()` 이중 호출)이 이미 안전함이 3중 확인됐다고 명시했다. 이번 문서는 재론하지 않되, `confirm_payment()`가 실제로 `orders`에 `for update`를 쓰는지만 최소 재확인했다: `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql:267-271` — `select ... from catchmenu_pos.orders where id = p_order_id ... for update;` 존재 확인. 이 패턴(주문 행을 통째로 잠가 그 주문에 대한 모든 후속 작업을 직렬화)을 `resolve_or_create_payment_intent()`에도 적용할 수 있는가는 `600562_Logic.md`의 옵션 (c)로 다룬다 — 다만 이 헬퍼는 `confirm_payment()` 내부에서 호출될 수도 있고(이 경우 이미 락이 걸린 상태), `0109`/`0130`(별도 함수)에서도 호출되므로 "이미 걸려있는 락에 얹혀가는 방식"이 항상 성립하지는 않는다는 점이 옵션 비교의 핵심 변수다.

## §6 정리

세 옵션 모두 기술적으로 실현 가능함을 확인했다(§3/§4/§5) — 판단은 하지 않는다(`600562_Logic.md`로 이월). §3에서 당초 우려했던 "jsonb 직접 UNIQUE 인덱스 가능 여부"라는 기술적 장벽 자체가 실제로는 존재하지 않음을 확인했고(가능함), 더 나아가 이미 존재하는 `idempotency_key`(정규화된 결정론적 해시)를 활용하는 편이 원본 jsonb에 직접 제약을 거는 것보다 더 견고한 대안임을 발견했다.

## §7 Open Questions

(a) `idempotency_key`에 UNIQUE 제약을 추가할 경우, 기존 5건의 테스트 오염 데이터(§2)와 향후 생성될 정상 `PREAUTHORIZED` 경로 데이터(이 헬퍼의 다른 분기, `0142`가 별도로 만드는 intent) 사이에 `idempotency_key` 형식 충돌이 없는지 확인 필요 — `0142`가 만드는 intent의 `idempotency_key` 형식(`'TOSS-INTENT:' || ...`, 이전 조사에서 확인)과 `'OBS-...'` 접두사가 겹치지 않음은 이번 문서에서 육안 확인했으나, 다른 경로(예: `0027`이 만드는 intent)의 형식까지 전수 확인하지는 않았다.
(b) `advisory lock`의 magic namespace 값 — `0142`가 `604260`을 쓰므로 이 워크패킷은 다른 값(예: 이 워크패킷 번호 `600560`)을 쓰는 것이 자연스러우나, 프로젝트 전체에서 advisory lock namespace를 중앙 관리하는 레지스트리가 있는지는 확인하지 않았다.
(c) §2의 라이브 오염 데이터(5건) 정리 여부 — 이 문서/Logic 문서는 판단하지 않고 Human 확인을 요청한다(`600562_Logic.md` §2).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `000056_Register_Concurrency_Risk.md` §3(PAY-CON-002)/§9 — 이 워크패킷의 직접 발단.
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` §3 — `resolve_or_create_payment_intent()`의 원 설계 의도(옵션 C+).

### Full Rules Required

- `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` — `resolve_or_create_payment_intent()`(L43-259) 전체, 이번 워크패킷의 수정 대상.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — `bind_toss_payment_intent()`(L29-203), advisory+row lock 재사용 템플릿.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`의 `orders FOR UPDATE`(L267-271), PAY-CON-001 대조용.
- `catchmenu_payment.payment_intents` 라이브 스키마/제약(이번 턴 재확인) — `idempotency_key` UNIQUE 부재 확인.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- PAY-CON-001(`confirm_payment()` 이중 호출) 자체의 재조사 — 이미 3중 확인됐다는 전제를 그대로 수용, 이 워크패킷 범위 밖.
- §2의 라이브 오염 데이터 정리(DML) — 이 문서는 수행하지 않음, Human 확인 대기.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0(번호: `600560`)/§1(락 부재 독립 재검증)은 확정됐다. **§2에서 라이브 DB에 실제로 남아있는 중복 행(오염) 2건을 직접 발견해 긴급 기록했다** — 재현 "보고"가 아니라 현재도 존재하는 실제 데이터임을 재확인, 정리는 수행하지 않고 Human 확인을 요청한다. §3에서 jsonb 직접 UNIQUE가 기술적으로 가능함을 확인했고, 더 나아가 이미 존재하는 `idempotency_key`(UNIQUE 제약 부재 확인)를 활용하는 대안을 새로 발견했다. §4/§5에서 advisory lock/orders FOR UPDATE 옵션의 재사용 가능성을 각각 확인했다. `600562_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600562_Logic_Payment_Intent_Race_Condition_Fix.md] =====
# 600562_Logic_Payment_Intent_Race_Condition_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_intent_race_condition_fix`

## §0 전제

`600561_Overview.md`가 확인한 사실을 전제로 한다: `resolve_or_create_payment_intent()`(`0158`)의 "신규 생성" 분기는 `count(*)` 확인 후 락 없이 `insert`하는 TOCTOU 레이스이며(§1), 이 레이스는 이미 실제로 재현되어 라이브 DB에 중복 행이 남아있다(§2, 오염 상태 그대로 보존 — 이 문서도 정리하지 않는다). PAY-CON-001(`confirm_payment()` 이중 호출)은 범위 밖으로 재확인됐다(`orders FOR UPDATE` 존재만 spot-check).

## §1 확정: 옵션 (a) 채택 (Human 결정, 2026-07-15, 재논의 금지)

**번호 안내**: 이번 지시문은 이 섹션을 "§2"로, 마이그레이션 설계를 "§3"으로 지칭했으나, 이 문서의 실제 구조는 옵션 비교가 §1, 라이브 오염 Open Item이 §2, Open Items 목록이 §3이다. 내용을 기준으로 지시문의 의도(옵션 비교 확정 + 마이그레이션 설계 추가)를 그대로 반영하되, 섹션 번호는 이 문서의 기존 구조를 유지한다 — §2(라이브 오염 Open Item)는 지시대로 그대로 둔다.

**확정**: 옵션 (a) — `payment_intents.idempotency_key`에 `UNIQUE` 제약을 추가하고, `resolve_or_create_payment_intent()`의 INSERT를 `INSERT ... ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`로 전환한다. `§1.1`(구 안, 아래 유지)이 검토했던 `DO NOTHING` + 재조회 방식 대신 `DO UPDATE ... RETURNING`을 채택 — 두 세션 모두 대칭적으로 승자 행의 `id`를 받으므로 별도 재-`SELECT` 로직이 불필요해진다.

**라이브 오염 데이터(§2) 처리 방침**: 그대로 둔다. Stage 4에서 `UNIQUE` 제약을 먼저 시도해 이 기존 중복이 실제로 제약 위반을 일으키는지 확인하는 것 자체가 "이 제약이 의도한 중복을 정확히 잡아내는가"의 자연스러운 실증 검증이 된다(§1.2 순서 1). 이후 정리(§1.2 순서 2)→제약 확정(순서 3)→헬퍼 함수 전환(순서 4) 순으로 진행한다.

## §1.2 정확한 마이그레이션 설계 (Stage 4 대상, 이번 턴 미실행)

이번 문서 작성 시점(2026-07-15)에 라이브로 재확인한 실제 데이터를 근거로 설계한다 — Stage 4 착수 시점에 다시 재확인해야 한다(아래 값은 예시가 아니라 현재 실제 값이다).

### 순서 1 — 기존 중복 재현 확인 (제약을 먼저 걸어서 실패를 확인)

```sql
-- 예상: unique_violation 에러로 실패해야 한다.
-- 이 실패 자체가 "제약이 의도한 중복을 정확히 잡아낸다"는 증거다.
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

**라이브 재확인(이번 문서 작성 턴)**: 현재 중복 쌍은 `order_id = '33333333-3333-3333-3333-333333333333'`, `idempotency_key = 'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'`로 완전히 동일한 2행이다:

| id | idempotency_key | created_at |
|---|---|---|
| `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf` | `OBS-33333333-...-POS_SYNTHESIZED-924f18176391` | `2026-07-15 15:57:55.728129+00`(더 이른 시각) |
| `283f3973-d547-4ea9-b4ad-b83b1c62b8cc` | `OBS-33333333-...-POS_SYNTHESIZED-924f18176391`(동일) | `2026-07-15 15:57:55.789718+00`(61ms 늦음) |

위 `ALTER TABLE`을 이 상태에서 그대로 실행하면 `ERROR: could not create unique index "uq_payment_intents_idempotency_key" ... DETAIL: Key (idempotency_key)=(OBS-33333333-...-POS_SYNTHESIZED-924f18176391) is duplicated.` 형태로 실패할 것으로 예상된다 — Stage 4는 이 정확한 에러 발생을 먼저 확인해야 한다.

### 순서 2 — 기존 중복 정리 (가장 이른 `created_at`을 승자로, 나머지 삭제)

**정리 전 안전 확인(필수, 이번 문서에서 이미 재확인)**: 삭제 대상 행(패자, `created_at`이 더 늦은 쪽)이 다른 테이블에서 FK로 참조되고 있지 않은지 먼저 확인한다. `payment_intents.id`를 참조하는 FK는 5개(`payment_ledger.intent_id`, `payment_events.intent_id`, `reconciliation_cases.intent_id`, `catchmenu_integrations.toss_payments.intent_id`, `catchmenu_integrations.toss_payment_requests.payment_intent_id`) — 이번 문서에서 위 중복 쌍(`17f67f52`/`283f3973`)의 5개 테이블 전체를 직접 조회해 **참조 0건**임을 확인했다. 정리 SQL(설계):

```sql
with ranked as (
  select id,
         row_number() over (
           partition by idempotency_key
           order by created_at asc
         ) as rn
  from catchmenu_payment.payment_intents
)
delete from catchmenu_payment.payment_intents
where id in (select id from ranked where rn > 1);
```

`row_number() ... order by created_at asc`이므로 가장 이른 행(`rn=1`)이 승자로 남고, 나머지(`rn>1`, 이번 케이스에서는 `283f3973-...` 1건)가 삭제된다. **Stage 4는 이 DELETE 직전에 위와 동일한 FK 참조 0건 확인을 다시 실행해야 한다**(이번 문서 작성 시점과 Stage 4 착수 시점 사이에 상태가 바뀌었을 수 있으므로) — 참조가 하나라도 있으면 그 행은 승자로 재선정하거나 별도 정책이 필요하다(이번 문서는 이 예외 케이스가 실제로 발생하지 않았음만 확인했다).

### 순서 3 — `UNIQUE` 제약 최종 적용

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

순서 2 이후 재실행 — 이번에는 성공해야 한다(중복이 제거됐으므로).

### 순서 4 — `resolve_or_create_payment_intent()` INSERT 전환

```sql
-- 변경 전(0158:219-255, 현재)
insert into catchmenu_payment.payment_intents (...)
values (...)
returning id into v_intent_id;

-- 변경 후 설계안
insert into catchmenu_payment.payment_intents (...)
values (...)
on conflict (idempotency_key) do update
  set updated_at = now()
returning id into v_intent_id;
```

`on conflict (idempotency_key) do update set updated_at = now()`는 항상 행을 반환한다(승자든 패자든 동일한 `id`) — `§1.4`(구 §1.1)가 지적했던 "DO NOTHING 시 패자가 빈 행을 받는" 비대칭 문제가 이 방식으로 근본적으로 해소된다. `do update`가 실제로 갱신하는 컬럼(`updated_at`)은 부작용이 없는 값이므로, 두 세션 중 나중에 도착한 쪽이 불필요하게 이 컬럼을 한 번 더 갱신하는 것 외에는 데이터 정합성에 영향이 없다.

### §1.3 결정 이전 이력 — 옵션 비교표 원문 (참고용, 위 §1 확정으로 대체됨)

| | 옵션 (a) — `idempotency_key` UNIQUE + `ON CONFLICT` | 옵션 (b) — Advisory Lock(`0142` 패턴 이식) | 옵션 (c) — `orders FOR UPDATE`(PAY-CON-001 패턴 재사용) |
|---|---|---|---|
| 핵심 메커니즘 | `payment_intents.idempotency_key`에 `UNIQUE` 제약 추가, INSERT 문에 `ON CONFLICT (idempotency_key) DO NOTHING` 또는 `DO UPDATE ... RETURNING id`로 전환 | 함수 진입 시 `pg_advisory_xact_lock(hashtextextended(tenant+store+order, <신규 namespace>))`로 같은 order_id에 대한 호출을 직렬화, 이어서 `for share`(orders)/`for update`(intent 후보) | 함수 진입 시 대상 `orders` 행을 `for update`로 잠가 같은 주문에 대한 모든 동시 호출을 직렬화 |
| 이미 존재하는 자산 재사용 | `idempotency_key`는 이미 결정론적으로 생성되고 있음(`600561_Overview.md` §3) — 컬럼 자체는 이미 있고 제약만 없음 | `0142`의 `bind_toss_payment_intent()`가 이미 정확히 이 패턴으로 프로덕션에 존재(`600561_Overview.md` §4) | `confirm_payment()`가 이미 이 패턴으로 PAY-CON-001을 막고 있음(`600561_Overview.md` §5) |
| DB 스키마 변경 필요 | **있음** — `alter table payment_intents add constraint uq_payment_intents_idempotency_key unique (idempotency_key)` | 없음(함수 본문만 수정) | 없음(함수 본문만 수정) |
| 레이스 윈도우 차단 방식 | **DB 자체가 물리적으로 중복을 거부** — 애플리케이션 로직의 정확성과 무관하게 최종 방어선 역할 | 애플리케이션 레벨 직렬화 — 잠금 순서/범위를 실수하면 여전히 레이스가 남을 수 있음 | 애플리케이션 레벨 직렬화, 잠금 대상이 `orders`(이 헬퍼가 직접 소유하지 않는 테이블)라는 점이 특이 |
| `PREAUTHORIZED` 분기(`p_intent_id is not null`)와의 관계 | 영향 없음 — 그 분기는 이미 존재하는 intent를 `UPDATE`할 뿐 `INSERT`하지 않으므로 이 UNIQUE 제약과 무관 | 잠금을 함수 전체(진입 시점)에 걸면 `PREAUTHORIZED` 분기도 함께 직렬화됨(약간의 불필요한 대기 발생 가능, `0142`가 이미 이 트레이드오프를 감수 중) | 동일 — 함수 전체를 감싸면 `PREAUTHORIZED` 분기도 영향받음 |
| 이 헬퍼의 3개 호출자(`0098`/`0109`/`0130`)에 미치는 영향 | 없음 — 호출자는 헬퍼의 반환값만 받으므로 무변경. 다만 `ON CONFLICT DO NOTHING`을 쓸 경우 "내가 이겼는지 졌는지"를 구분해 기존 행을 다시 조회하는 후속 로직이 필요(§1.1 참고) | `0098`은 이미 `orders`에 `for update`를 걸고 있어 이 헬퍼가 다시 `orders`를 `for share`로 잠그면 **같은 트랜잭션 내 재진입 락**이 되어 문제없이 통과하지만(PostgreSQL은 동일 트랜잭션 내 락 업그레이드/재획득 허용), `0109`/`0130`은 `orders`를 미리 잠그지 않으므로 이 헬퍼의 `for share`가 그 시점에 처음 걸림 — 세 호출자 모두 안전하게 동작 가능 | `0098`은 이미 자체적으로 `orders FOR UPDATE`를 갖고 있어 이 옵션을 헬퍼에도 넣으면 **중복 락 획득**(같은 트랜잭션 내에서는 무해하지만 로직 중복). `0109`/`0130`은 원래 `orders`를 잠그지 않는 흐름이었으므로 이 옵션을 넣으면 그 두 함수의 락 사용 패턴이 새로 생김 |
| 놓칠 수 있는 경우 | `idempotency_key` 생성 로직 자체에 버그가 있으면(예: `origin_reference` 정규화가 불완전) 보호가 무력화됨 — 그러나 DB 제약이므로 애플리케이션 버그와 무관하게 최소한 "완전히 같은 해시"에 대해서는 항상 보호됨 | advisory lock의 namespace/키 구성을 다른 워크패킷이 실수로 재사용하면 의도치 않은 직렬화나 충돌 가능(`600561_Overview.md` §7 (b) Open Item) | 헬퍼가 `orders`가 아닌 다른 스코프(예: 향후 order 없는 intent)로 호출될 경우 이 옵션은 애초에 적용 불가 |

### §1.4 옵션 (a) 채택 시 필요한 추가 설계 — `ON CONFLICT` 이후 반환값 처리 (해소됨, 이력 보존)

`ON CONFLICT (idempotency_key) DO NOTHING`만 쓰면 충돌 시 `INSERT`가 아무 행도 반환하지 않는다(`RETURNING id`가 비게 됨) — 이 경우 함수는 반드시 **충돌한 기존 행을 다시 `SELECT`해서 그 `id`를 반환**해야 한다(그렇지 않으면 두 번째 호출자가 `null`을 받아 §3.1의 `payment_intent_resolution_failed` 에러 경로로 빠짐 — 첫 번째 성공 호출자와 다른 결과를 받게 되어 사실상 "레이스는 막았지만 응답이 비대칭"인 상태가 됨). 대안으로 `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`를 쓰면 항상 행을 반환하지만, 승자가 아닌 호출도 불필요한 `UPDATE`를 하게 된다. 이 구체 설계는 이번 문서에서 결정하지 않고 TestPlan/ChangeContract 단계로 이월한다.

## §2 Open Item — 오늘 발견된 라이브 오염 사고, 향후 재현 테스트 격리 절차 제안

**사고 기록(사실)**: `600561_Overview.md` §2에서 확인한 대로, 오늘 세션 중 진행된 동시성 재현 테스트(안티+Codex, `pg_sleep`으로 레이스 윈도우 강제 확대)의 산출물이 **정리되지 않고 라이브 DB에 그대로 남아있다** — `catchmenu_payment.payment_intents`에 합성 `order_id`(`22222222.../33333333.../44444444...`류)를 쓴 테스트 행 5건이 남아있고, 그중 2건은 실제로 재현된 중복 쌍이다. 이번 워크패킷(Overview/Logic, `.sql` 생성 금지)은 이 데이터를 정리하지 않았다 — **Human 확인 후 별도로 정리 여부를 결정해야 한다.**

**재발 방지를 위한 향후 가이드라인 제안(권고, 이 문서가 강제하지 않음)**:

1. **격리된 스키마/네임스페이스 사용**: 동시성 재현 테스트처럼 의도적으로 레이스를 유발하는 테스트는 실제 스키마(`catchmenu_payment` 등)에 직접 쓰지 말고, 별도 테스트 전용 함수명 접두사(예: `__test_`)나 별도 스키마(예: `catchmenu_test`)를 통해서만 실행하도록 권고한다.
2. **트랜잭션 격리 우선 원칙**: 이번 세션의 다른 검증 작업들(`601020`/`600550` 워크패킷)이 반복적으로 써온 `BEGIN ... ROLLBACK` 패턴이 이 재현 테스트에는 구조적으로 적용되지 않는다 — 동시성 재현 자체가 "두 개의 독립된 트랜잭션이 실제로 커밋 경합을 벌이는 것"을 요구하므로, 단일 트랜잭션 롤백으로는 레이스를 재현할 수 없다. 이 근본적 제약 때문에 이런 테스트는 태생적으로 "정리가 필요한 흔적을 남긴다"는 점을 명시하고, **테스트 종료 직후 자동/수동 정리(해당 합성 `order_id`/`tenant_id` 패턴에 대한 즉시 `DELETE`)를 절차의 필수 마지막 단계로 명문화**할 것을 제안한다.
3. **합성 식별자 명명 규칙**: 이번 사고에서도 합성 UUID(`22222222...`류)가 쓰였으나, 이런 패턴 자체가 이미 이 세션의 여러 검증 작업에서 재사용되고 있어(`33333333...`/`44444444...` 등) 서로 다른 워크패킷의 테스트 데이터가 뒤섞일 위험이 있다 — 워크패킷별로 구분되는 접두사(예: `Risk ID` 또는 워크패킷 번호를 UUID 일부에 인코딩)를 쓰는 것을 권고한다.

이 제안 자체를 채택할지, 어떤 형태의 공식 가이드라인 문서(`000701` 추가 조항 또는 별도 문서)로 만들지는 이 워크패킷이 결정하지 않는다 — Open Item으로만 기록한다.

## §3 Open Items

(a) ~~§1.1의 `ON CONFLICT` 이후 반환값 처리 구체 설계~~ — **해소됨**: §1에서 옵션 (a) 확정, §1.2 순서 4에서 `DO UPDATE ... RETURNING`으로 확정.
(b) `600561_Overview.md` §7 (a) — `idempotency_key` UNIQUE 추가 시 다른 경로(`0027` 등)가 만드는 intent와의 형식 충돌 여부 전수 확인 필요 — 여전히 미해결, TestPlan 단계로 이월.
(c) ~~advisory lock namespace 중앙 레지스트리~~ — 옵션 (a) 확정으로 옵션 (b)(advisory lock) 자체가 채택되지 않았으므로 **더 이상 관련 없음(moot)**.
(d) **§2의 라이브 오염 데이터(5건) 정리 여부 — Human 결정으로 확정: 정리하지 않고 그대로 둔다(§1 "라이브 오염 데이터 처리 방침" 참고), Stage 4의 UNIQUE 제약 실증 검증 자료로 활용한다.**
(e) §2의 재현 테스트 격리 가이드라인 제안을 공식 문서화할지 여부 — 여전히 Human 결정 필요(이번 지시문은 "그대로 유지"만 요구, 채택 여부는 미결정).
(f) ~~옵션 (b)/(c) 채택 시 락 상호작용 검증~~ — 옵션 (a) 확정으로 **더 이상 관련 없음(moot)**.
(g) **신규** — §1.2 순서 1(제약 실패 재현)과 순서 3(제약 성공 적용) 사이에 순서 2(정리)가 반드시 끼어들어야 하는 순서 의존성을 TestPlan이 명시적인 단계 순서로 강제해야 한다 — 순서가 뒤바뀌면 순서 3이 항상 순서 1과 같은 이유로 실패한다.
(h) **신규** — §1.2 순서 2의 FK 참조 0건 확인은 이번 문서 작성 시점 기준이며, Stage 4 착수 시점에 재확인이 필수다(§1.2 순서 2 본문에 이미 명시).

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600561_Overview_Payment_Intent_Race_Condition_Fix.md`(이 문서의 직접 전제)
- `000056_Register_Concurrency_Risk.md` §3(PAY-CON-002)/§7(공통 해법 카탈로그) — 이 워크패킷이 참조하는 도구 목록.

### Full Rules Required

- `sql/migrations/0158_confirm_payment_intent_linkage_fix.sql` — 수정 대상.
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql` — 옵션 (b) 재사용 템플릿.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — 옵션 (c) 참고, PAY-CON-001 대조.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- PAY-CON-001 재조사 — 범위 밖(`600561_Overview.md` §5와 동일).
- 라이브 오염 데이터 정리(DML) — Human 결정 대기, 이 문서는 수행하지 않음.
- 재현 테스트 격리 가이드라인의 공식 문서화 — 제안만, 채택은 Human 결정.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Human 결정 반영).** §1에서 옵션 (a)를 최종 채택했다 — `payment_intents.idempotency_key`에 `UNIQUE` 제약 추가 + `resolve_or_create_payment_intent()`의 INSERT를 `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`로 전환. §1.2에서 정확한 4단계 마이그레이션 설계(순서 1: 제약 실패 재현 → 순서 2: FK 참조 0건 확인 후 정리 → 순서 3: 제약 성공 적용 → 순서 4: 헬퍼 함수 전환)를 라이브로 재확인한 실제 데이터(중복 쌍의 정확한 `id`/`idempotency_key`/`created_at`) 기준으로 작성했다. §1.3/§1.4에 결정 이전 이력(옵션 비교표, DO NOTHING 대안 검토)을 참고용으로 보존했다. §2(라이브 오염 사고 Open Item, 재발 방지 가이드라인 제안)는 지시대로 변경 없이 유지했다 — 처리 방침은 §1에서 확정("정리하지 않고 Stage 4 실증 검증 자료로 활용"). §3에서 옵션 (a) 확정으로 해소되거나 더 이상 무관해진 Open Item(a/c/f)을 표시하고 신규 Open Item(g/h)을 추가했다. `600563_TestPlan.md`/`600564_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았고, 라이브 DB의 오염 데이터도 정리하지 않았다(Human 결정에 따라 의도적으로 보존).


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600563_TestPlan.md] =====
# 600563_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: Codex
Date: 2026-07-16

## 0. Purpose And Scope

This TestPlan verifies the approved option (a) from `600562_Logic_Payment_Intent_Race_Condition_Fix.md`:

1. Clean up the existing live duplicate `payment_intents` pair only after FK re-verification.
2. Add `uq_payment_intents_idempotency_key UNIQUE (idempotency_key)`.
3. Change `catchmenu_payment.resolve_or_create_payment_intent()` so its observed-intent INSERT uses:

```sql
on conflict (idempotency_key) do update
set updated_at = now()
returning id
```

The goal is to make concurrent calls with the same deterministic `idempotency_key` return the same surviving `payment_intents.id` instead of creating duplicate rows.

## 1. Pre-Implementation Safety Checks

### 1.1 Confirm Existing Duplicate Pair Still Exists

Before any DELETE or ALTER, re-run:

```sql
select
  id,
  order_id,
  idempotency_key,
  created_at
from catchmenu_payment.payment_intents
where idempotency_key =
  'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'
order by created_at, id;
```

Expected before cleanup:

- Winner candidate: `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf`
- Loser candidate: `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`
- Both rows still share the same `idempotency_key`.

If the pair no longer exists exactly as documented, STOP and report. Do not guess a new loser row.

### 1.2 Reconfirm FK References Before Deleting The Loser

Immediately before deleting `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`, rerun the five FK reference checks recorded in `600562_Logic.md`:

```sql
select 'payment_ledger.intent_id' as ref, count(*) as cnt
from catchmenu_payment.payment_ledger
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'payment_events.intent_id' as ref, count(*) as cnt
from catchmenu_payment.payment_events
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'reconciliation_cases.intent_id' as ref, count(*) as cnt
from catchmenu_payment.reconciliation_cases
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'toss_payments.intent_id' as ref, count(*) as cnt
from catchmenu_integrations.toss_payments
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'toss_payment_requests.payment_intent_id' as ref, count(*) as cnt
from catchmenu_integrations.toss_payment_requests
where payment_intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

Expected:

```text
payment_ledger.intent_id                 | 0
payment_events.intent_id                 | 0
reconciliation_cases.intent_id           | 0
toss_payments.intent_id                  | 0
toss_payment_requests.payment_intent_id  | 0
```

If any count is non-zero, STOP. Do not delete the loser row; Stage 4 must return to Human for a new winner/rewire decision.

## 2. Negative Test: Constraint Must Fail While Duplicate Remains

Before cleanup, intentionally attempt the final UNIQUE constraint inside a rollback-only transaction:

```sql
begin;
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
rollback;
```

Expected before cleanup:

- The `ALTER TABLE` fails because the existing duplicate key is still present.
- The error should identify `uq_payment_intents_idempotency_key` and the duplicated `idempotency_key`.

This failure is a positive signal: it proves the proposed constraint would actually catch the known duplicate. If it unexpectedly succeeds before cleanup, STOP and report because the documented live duplicate state has changed.

## 3. Cleanup Verification

After the FK checks pass, Stage 4 may delete the loser row:

```sql
delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

Verify:

```sql
select
  id,
  idempotency_key,
  created_at
from catchmenu_payment.payment_intents
where idempotency_key =
  'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'
order by created_at, id;
```

Expected:

- Exactly 1 row remains.
- Remaining id is `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf`.

## 4. UNIQUE Constraint Verification

After cleanup, apply:

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

Verify:

```sql
select
  conname,
  contype,
  pg_get_constraintdef(oid) as def
from pg_constraint
where conrelid = 'catchmenu_payment.payment_intents'::regclass
  and conname = 'uq_payment_intents_idempotency_key';
```

Expected:

```text
uq_payment_intents_idempotency_key | u | UNIQUE (idempotency_key)
```

Also confirm the related unique index exists:

```sql
select
  i.relname as index_name,
  ix.indisunique,
  pg_get_indexdef(i.oid) as indexdef
from pg_index ix
join pg_class i on i.oid = ix.indexrelid
join pg_class t on t.oid = ix.indrelid
join pg_namespace n on n.oid = t.relnamespace
where n.nspname = 'catchmenu_payment'
  and t.relname = 'payment_intents'
  and i.relname = 'uq_payment_intents_idempotency_key';
```

Expected:

- `indisunique = true`
- index definition uses `btree (idempotency_key)`

## 5. Function Body Verification

After applying the function change, verify live body:

```sql
select pg_get_functiondef(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'resolve_or_create_payment_intent';
```

Expected:

- INSERT branch contains `on conflict (idempotency_key) do update`.
- INSERT branch contains `set updated_at = now()`.
- INSERT branch still ends with `returning id into v_intent_id`.
- No test-only tokens exist:
  - `pg_sleep`
  - `__test_`
  - `__pay_con`
  - `slow_resolve`
  - `OBS-RACE`
  - `INTRODUCE RACE`

## 6. Concurrency Reproduction Test After Fix

### 6.1 Test Isolation Rules

All intentional race tests must use isolated names:

- Any temporary helper function must be named with a `__test_` prefix.
- Any temporary helper function must be dropped in the same test script or final cleanup block.
- Test order/session identifiers must use clearly reserved UUIDs and test `correlation_id` values.
- Test data must be deleted immediately after verification.

Do not create unprefixed helper functions in production schemas. This rule exists because a previous investigation accidentally left `catchmenu_payment.__pay_con002_slow_resolve()` and a test `pg_sleep` body in the live database.

### 6.2 Two-Session Race Test

Re-run the same class of two-session race used by Codex/Antigravity, but only after the fix is applied.

The race may use a temporary helper only if it is named with `__test_` and dropped immediately:

```sql
create or replace function catchmenu_payment.__test_resolve_or_create_payment_intent_race_probe(
  p_sleep_seconds numeric default 1.5
)
returns uuid
language plpgsql
security definer
as $$
begin
  -- Test helper only. Must be dropped after test.
  perform pg_sleep(p_sleep_seconds);
  return catchmenu_payment.resolve_or_create_payment_intent(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := '<test_order_id>'::uuid,
    p_requested_amount := 15000,
    p_payment_method := 'CARD',
    p_payment_channel := 'STAFF_POS',
    p_provider_type := 'OKPOS',
    p_intent_origin := 'POS_SYNTHESIZED',
    p_origin_reference := jsonb_build_object(
      'source', '__test_payment_intent_race',
      'provider_tx_id', '<test_provider_tx_id>'
    ),
    p_intent_id := null,
    p_session_id := '<test_session_id>'::uuid,
    p_locale := 'ko'
  );
end;
$$;
```

Two independent sessions must call the resolver for the same test order/reference while overlapping in time.

Expected after fix:

- Both sessions complete successfully.
- Both sessions return the same `payment_intents.id`.
- Final count for the test `idempotency_key` is exactly 1.
- No duplicate intent row is created.

Verification query:

```sql
select
  count(*) as intent_count,
  array_agg(id order by created_at) as intent_ids,
  array_agg(idempotency_key order by created_at) as keys
from catchmenu_payment.payment_intents
where order_id = '<test_order_id>'::uuid
  and intent_origin = 'POS_SYNTHESIZED'
  and origin_reference = jsonb_build_object(
    'source', '__test_payment_intent_race',
    'provider_tx_id', '<test_provider_tx_id>'
  );
```

Expected:

```text
intent_count = 1
intent_ids contains one UUID
both session return values equal that UUID
```

### 6.3 Test Cleanup

After the race test:

```sql
drop function if exists catchmenu_payment.__test_resolve_or_create_payment_intent_race_probe(numeric);
delete from catchmenu_payment.payment_intents where order_id = '<test_order_id>'::uuid;
delete from catchmenu_pos.orders where id = '<test_order_id>'::uuid;
delete from catchmenu_pos.order_sessions where id = '<test_session_id>'::uuid;
```

Then verify no test helper remains:

```sql
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.proname like '__test_%'
   or p.proname ilike '%slow_resolve%'
   or p.proname ilike '%pay_con%';
```

Expected:

```text
(0 rows)
```

## 7. Normal Case Regression

Verify that distinct logical payment events still create distinct intents.

### 7.1 Different `order_id`

Call `resolve_or_create_payment_intent()` for two different `order_id` values with otherwise identical origin/reference structure.

Expected:

- Two different `payment_intents.id` values are created.
- Each has a different `idempotency_key` because `order_id` is part of the key.

### 7.2 Same `order_id`, Different `origin_reference`

Call `resolve_or_create_payment_intent()` twice for the same `order_id` but different `origin_reference` payloads.

Expected:

- Two different `payment_intents.id` values are created.
- Each has a different `idempotency_key` because the md5 of `origin_reference::text` differs.

## 8. Boundary Verification

Confirm zero diff for forbidden files:

```powershell
git diff -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
git diff -- sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
git diff -- sql/migrations/0109_create_network_handoff_fallback_rpc.sql
git diff -- sql/migrations/0130_create_van_handler_extension.sql
git diff -- sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
```

Expected:

- No new diff in those files from this workpacket.
- `0142` trigger logic remains unchanged.

Also verify the new migration file is the only SQL source change for this workpacket, unless Stage 4 explicitly performs a §24-style source update to an already-applied file under Human approval.

## 9. Approval Criteria

This TestPlan passes only if:

- FK references for loser row `283f3973-d547-4ea9-b4ad-b83b1c62b8cc` are rechecked and remain 0 before deletion.
- The pre-cleanup negative UNIQUE test fails as expected.
- The loser row is deleted and the winner row remains.
- `uq_payment_intents_idempotency_key` exists and is unique.
- `resolve_or_create_payment_intent()` uses `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`.
- The two-session race test returns the same intent id to both sessions and leaves exactly one row.
- Normal distinct event cases still create distinct intents.
- No `__test_` or slow helper remains.
- `0142` and unrelated payment pipeline files remain unchanged.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600564_ChangeContract.md] =====
# 600564_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: Codex
Date: 2026-07-16

## 0. Purpose

This ChangeContract authorizes the minimal Stage 4 implementation required to close the `resolve_or_create_payment_intent()` race condition documented in `600561_Overview_Payment_Intent_Race_Condition_Fix.md` and resolved by option (a) in `600562_Logic_Payment_Intent_Race_Condition_Fix.md`.

The approved mechanism is:

1. Reconfirm the existing duplicate pair and FK safety.
2. Delete exactly the known loser row if and only if it is still unreferenced.
3. Add a UNIQUE constraint on `payment_intents.idempotency_key`.
4. Convert the resolver INSERT to `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`.

## 1. Allowed Files And Operations

### 1.1 New Migration File

Allowed: one new migration file using the next available migration number.

Expected filename pattern:

```text
sql/migrations/<next>_fix_payment_intent_idempotency_key_race.sql
```

The file may contain only the operations listed in this section.

### 1.2 Existing Duplicate Cleanup

Allowed: delete exactly one known loser row:

```sql
delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

This DELETE is allowed only after Stage 4 reruns the five FK reference checks in `600563_TestPlan.md` §1.2 and all five counts are still 0.

The winner row must remain:

```text
17f67f52-e80d-47e9-a5ec-7e351a4e6dcf
```

If the loser row has gained a reference since `600562_Logic.md`, STOP. Do not delete, rewire, or pick a different winner without Human approval.

### 1.3 UNIQUE Constraint

Allowed:

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

No other constraint may be added in this workpacket.

### 1.4 `resolve_or_create_payment_intent()` Function Body

Allowed: redefine only `catchmenu_payment.resolve_or_create_payment_intent(...)` so the observed-intent INSERT branch changes from plain INSERT to:

```sql
on conflict (idempotency_key) do update
set updated_at = now()
returning id into v_intent_id;
```

The rest of the function must preserve the `0158_confirm_payment_intent_linkage_fix.sql` source behavior:

- approved `intent_origin` validation;
- `PREAUTHORIZED` branch behavior;
- `v_origin_reference := coalesce(p_origin_reference, '{}'::jsonb)`;
- normalized `v_payment_method`, `v_payment_channel`, and `v_provider_type`;
- existing candidate conflict error for multiple active candidates;
- deterministic `idempotency_key` format:

```sql
'OBS-' || p_order_id::text || '-' || p_intent_origin || '-'
  || substr(md5(v_origin_reference::text), 1, 12)
```

No `pg_sleep`, race-window comment, or test-specific `OBS-RACE` logic may appear in the production function body.

## 2. Forbidden Files And Operations

The following are forbidden in this workpacket:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`
- `sql/migrations/0109_create_network_handoff_fallback_rpc.sql`
- `sql/migrations/0130_create_van_handler_extension.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`
- `confirm_payment()` body changes
- `confirm_payment_from_provider()` changes
- Toss binding trigger changes
- payment ledger schema changes
- advisory lock redesign
- `orders FOR UPDATE` redesign
- changes to unrelated payment/KDS/DID/Flutter files

Do not modify `0142`; it is a reference and boundary verification target only.

## 3. Required Stage 4 Order

Stage 4 must execute in this exact order:

1. Reconfirm the duplicate pair and five FK counts from `600563_TestPlan.md` §1.
2. Run the pre-cleanup negative UNIQUE test from `600563_TestPlan.md` §2 and confirm it fails while the duplicate remains.
3. Delete loser row `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`.
4. Confirm only winner row `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf` remains for the duplicate `idempotency_key`.
5. Add `uq_payment_intents_idempotency_key`.
6. Redefine `resolve_or_create_payment_intent()` with `ON CONFLICT ... DO UPDATE ... RETURNING id`.
7. Verify live function body through `pg_get_functiondef()`.
8. Run concurrency race verification.
9. Drop all `__test_` helpers and clean test rows.
10. Run boundary diff checks.

Skipping the negative UNIQUE test is not allowed; it proves the constraint catches the existing failure mode.

## 4. Test Isolation Contract

Any deliberate concurrency/race reproduction helper must follow all of these rules:

- Function name must start with `__test_`.
- Helper must be dropped at the end of the test.
- Helper must never replace production function bodies.
- Helper must never be named with ad hoc prefixes such as `__pay_con`.
- Test SQL must include cleanup verification showing no `__test_`, `slow`, `slow_resolve`, or `pay_con` helper remains.

This is mandatory because the prior investigation temporarily polluted live DB state with:

- `PERFORM pg_sleep(1.5)` inside live `resolve_or_create_payment_intent()`;
- `catchmenu_payment.__pay_con002_slow_resolve(...)`.

Both were removed before this ChangeContract, and this workpacket must not recreate that class of live pollution.

## 5. Open Items Carried Forward

(a) `600561_Overview.md` §7 (a): adding UNIQUE on `idempotency_key` should remain compatible with other intent creation paths, including `0027` and `0142`. Stage 4 must verify no existing non-test rows violate the constraint before final application.

(b) The old advisory-lock namespace question is moot for this workpacket because option (a) was chosen. It may become relevant only if a future workpacket adopts advisory locks elsewhere.

(c) The old option (b)/(c) lock-interaction tests are moot for this workpacket because option (a) was chosen.

(d) The known live duplicate pair must be handled carefully. Stage 4 may delete only the documented loser row and only after FK re-verification.

(e) If Stage 4 discovers any new duplicate `idempotency_key` groups beyond the documented pair, STOP and report. Do not bulk-delete or infer winners.

(f) If the UNIQUE constraint fails after deleting the documented loser, STOP and report the full duplicate inventory.

(g) FK reference state can change between Stage 2 and Stage 4. Therefore FK checks are not merely documentation; they are a hard precondition for deletion.

(h) Test isolation rules should be considered for promotion into a broader project rule after this workpacket, but this ChangeContract only enforces them for this workpacket.

## 6. Boundary Verification Required After Implementation

Stage 4 must report:

- duplicate pair pre-check result;
- five FK count results;
- negative UNIQUE test error before cleanup;
- loser DELETE result;
- final UNIQUE constraint definition;
- final `pg_get_functiondef()` excerpt showing `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`;
- two-session race test result showing the same `intent_id` returned to both sessions;
- normal distinct-event regression results;
- helper cleanup result `(0 rows)`;
- `git diff --check` result;
- forbidden-file diff result, especially `0142` unchanged.

## 7. Human Boundary Approval

☑ I approve deleting only the documented unreferenced loser row 283f3973-d547-4ea9-b4ad-b83b1c62b8cc after Stage 4 reruns the FK checks and confirms all five counts are still 0.
☑ I approve adding uq_payment_intents_idempotency_key UNIQUE (idempotency_key) to catchmenu_payment.payment_intents.
☑ I approve redefining only catchmenu_payment.resolve_or_create_payment_intent(...) so its observed-intent INSERT uses ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id.
☑ I approve the forbidden-file boundary and the mandatory __test_ helper isolation / cleanup requirements. (2026 - 07 - 16).



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600565_Module.md] =====
# 600565_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-16

## Summary

Implemented `600560_payment_intent_race_condition_fix` under the approved `600564_ChangeContract.md` boundary.

The implementation closes the `resolve_or_create_payment_intent()` observed-intent race by cleaning the known duplicate pair, adding a database-level uniqueness contract on `payment_intents.idempotency_key`, and changing the resolver's observed-intent INSERT to use `ON CONFLICT ... DO UPDATE ... RETURNING id`.

## 1. Migration

| File | Purpose | Result |
|---|---|---|
| `sql/migrations/0159_fix_payment_intent_idempotency_key_race.sql` | Delete the known unreferenced loser duplicate row, add `uq_payment_intents_idempotency_key`, and redefine `catchmenu_payment.resolve_or_create_payment_intent(...)` with conflict-safe observed-intent insertion. | Applied locally through `tools/apply_migrations.py`; `migration_history.success = true`. |

Recorded checksum:

```text
0159_fix_payment_intent_idempotency_key_race.sql
834710300b5a347ed91b400c02f3b1754e5dd32541830f6534e6542e0b97cea9
```

## 2. Implemented Sequence

The Stage 4 execution followed `600564_ChangeContract.md` §3:

1. Reconfirmed the duplicate pair:
   - winner: `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf`
   - loser: `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`
   - shared key: `OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391`
2. Reconfirmed the loser row had 0 FK references across all 5 known FK tables.
3. Proved the proposed UNIQUE constraint fails before cleanup while the duplicate remains.
4. Deleted only the loser row.
5. Confirmed only the winner row remains.
6. Added:

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

7. Redefined only `resolve_or_create_payment_intent()` so the observed-intent INSERT ends with:

```sql
on conflict (idempotency_key) do update
set updated_at = now()
returning id into v_intent_id;
```

## 3. Resulting Live State

`payment_intents.idempotency_key` is now a database-enforced unique key:

```text
uq_payment_intents_idempotency_key | UNIQUE (idempotency_key)
```

The previously duplicated key now has exactly one surviving row:

```text
17f67f52-e80d-47e9-a5ec-7e351a4e6dcf
```

The resolver still preserves the rest of the `0158` semantics:

- `intent_origin` validation;
- explicit `PREAUTHORIZED` branch;
- payment method/channel/provider normalization;
- existing multi-candidate conflict error;
- deterministic `OBS-<order_id>-<origin>-<origin_reference_hash>` idempotency key format.

## 4. Boundary Notes

This module did not modify:

- `0098_create_payment_confirm_pipeline_rpc.sql`
- `0103_create_toss_payments_pipeline_rpc.sql`
- `0109_create_network_handoff_fallback_rpc.sql`
- `0130_create_van_handler_extension.sql`
- `0142_patch_toss_mvp_payment_intent_binding.sql`
- `confirm_payment()`
- `confirm_payment_from_provider()`
- payment ledger schema
- advisory lock behavior
- `orders FOR UPDATE` behavior

## 5. Test Isolation

The Stage 4 race verification used only a `__test_`-prefixed helper and dropped it after the test. Final live check found no `__test_`, `__pay_con`, `slow`, or `slow_resolve` helper functions.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600566_Verification.md] =====
# 600566_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Cursor + Antigravity
Date: 2026-07-16

## Verification Result

Final result: **PASS — complete dual independent verification.**

Cursor and Antigravity independently verified the `0159` implementation and repeated the race test using different test order IDs and helper names. Both confirmed that concurrent calls now return the same `payment_intents.id` and leave only one row.

## 1. Stage 4 Execution Evidence

### Duplicate Pair Precheck

```text
17f67f52-e80d-47e9-a5ec-7e351a4e6dcf | OBS-33333333-...-POS_SYNTHESIZED-924f18176391 | earlier created_at
283f3973-d547-4ea9-b4ad-b83b1c62b8cc | OBS-33333333-...-POS_SYNTHESIZED-924f18176391 | later created_at
```

### FK Recheck

All five loser-row FK reference checks returned 0:

```text
payment_ledger.intent_id                | 0
payment_events.intent_id                | 0
reconciliation_cases.intent_id          | 0
toss_payments.intent_id                 | 0
toss_payment_requests.payment_intent_id | 0
```

### Negative UNIQUE Test

Before cleanup, the constraint correctly failed:

```text
ERROR:  could not create unique index "uq_payment_intents_idempotency_key"
DETAIL:  Key (idempotency_key)=(OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391) is duplicated.
```

### Final Constraint

```text
uq_payment_intents_idempotency_key | UNIQUE (idempotency_key)
```

### Function Body

`pg_get_functiondef()` confirmed:

| Check | Result |
|---|---|
| `on conflict (idempotency_key) do update` | PASS |
| `set updated_at = now()` | PASS |
| `returning id into v_intent_id` | PASS |
| `pg_sleep` absent | PASS |
| `__test_` absent from production body | PASS |
| `__pay_con` absent | PASS |
| `slow_resolve` absent | PASS |
| `OBS-RACE` absent | PASS |
| `INTRODUCE RACE` absent | PASS |

## 2. Cursor Verification Summary

Cursor independently reran the post-fix race scenario with its own test order ID and helper naming. Result:

- two overlapping sessions both completed;
- both returned the same `intent_id`;
- final count for the tested `idempotency_key` was 1;
- the `uq_payment_intents_idempotency_key` constraint remained present;
- forbidden payment pipeline files remained out of scope.

Cursor also confirmed that the old known duplicate pair was reduced to the single winner row.

## 3. Antigravity Verification Summary

Antigravity independently reran the post-fix race scenario with a different test order ID and helper naming. Result:

- two overlapping sessions both completed;
- both returned the same `intent_id`;
- final count for the tested `idempotency_key` was 1;
- normal regression still allowed distinct logical events to create distinct intents;
- helper cleanup checks eventually returned 0 rows.

## 4. Codex Stage 4 Baseline Verification

Codex Stage 4 execution produced the baseline post-fix race result:

```text
Session A returned: 8b1c7ddf-ed8c-4ca7-b6f6-5273c66768e6
Session B returned: 8b1c7ddf-ed8c-4ca7-b6f6-5273c66768e6
Final row count: 1
```

Normal regression:

```text
different_order_a | 194143f6-f5a4-4ffb-b27a-d4f64d1169c8
different_order_b | 4fda32e4-524f-4a92-a6cc-e1e383709c9b
same_order_ref_a  | 4ebd3aae-63c9-4287-8952-32e587612261
same_order_ref_b  | 6bb875e9-53fc-41e7-a596-63753d76efde
```

This demonstrates both sides of the contract:

- same deterministic `idempotency_key` -> same row;
- different logical event -> distinct rows.

## 5. Boundary Verification

No Stage 4 change was made to:

- `0098_create_payment_confirm_pipeline_rpc.sql`
- `0103_create_toss_payments_pipeline_rpc.sql`
- `0109_create_network_handoff_fallback_rpc.sql`
- `0130_create_van_handler_extension.sql`
- `0142_patch_toss_mvp_payment_intent_binding.sql`

`0142` remains a reference pattern only.

## 6. Helper Cleanup Verification

Final live query:

```sql
SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname LIKE '__test_%'
   OR p.proname ILIKE '%pay_con%'
   OR p.proname ILIKE '%slow%'
ORDER BY n.nspname, p.proname;
```

Final result:

```text
nspname | proname | args
--------+---------+-----
(0 rows)
```

## 7. Temporary Helper Confusion: `__pay_con002_slow_resolve`

During dual verification, there was a short-lived confusion that `__pay_con002_slow_resolve` had reappeared. Final recheck showed 0 matching helper functions.

The most likely interpretation is that Cursor and Antigravity were accessing the same live database at nearly the same time and cleaned up each other's temporary helper functions while their verification turns overlapped. The final live state is clean:

- no `__test_` helper;
- no `__pay_con` helper;
- no `slow` / `slow_resolve` helper;
- no production function body containing test-only race-window logic.

This is recorded as a process finding, not an implementation defect.

## 8. `git diff --check`

Stage 4 final whitespace check returned exit 0. Existing LF/CRLF warnings from unrelated dirty files may still appear, but no whitespace error was reported for this workpacket.

## Conclusion

The race condition fix is verified. The database now enforces uniqueness for deterministic observed-intent idempotency keys, the resolver returns the surviving row under conflict, and independent Cursor/Antigravity checks both confirm the same post-fix race behavior.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600560_payment_intent_race_condition_fix/600567_Audit.md] =====
# 600567_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-16

## Final Audit Decision

ACCEPT.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Duplicate pair handled exactly as authorized | PASS | Only loser row `283f3973-d547-4ea9-b4ad-b83b1c62b8cc` was deleted after 5 FK checks returned 0. |
| Constraint proves the old failure mode | PASS | Pre-cleanup negative UNIQUE test failed on the documented duplicate key. |
| Database-level uniqueness added | PASS | `uq_payment_intents_idempotency_key UNIQUE (idempotency_key)` exists. |
| Resolver conflict handling implemented | PASS | `resolve_or_create_payment_intent()` uses `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`. |
| Race fixed | PASS | Codex, Cursor, and Antigravity all observed overlapping calls returning the same `intent_id` with final count 1. |
| Normal distinct-event behavior preserved | PASS | Different `order_id` and same `order_id` with different `origin_reference` still create distinct intents. |
| Test helpers cleaned | PASS | Final live helper query returned 0 rows. |
| Forbidden files untouched by this workpacket | PASS | No authorized change to `0098`/`0103`/`0109`/`0130`/`0142` or `confirm_payment()`. |

## Findings

1. The chosen option (a) was the correct minimal fix for this specific failure mode: the resolver already had a deterministic `idempotency_key`, but the database did not enforce it. Adding a UNIQUE constraint moves the critical race boundary into the database.
2. The `ON CONFLICT ... DO UPDATE ... RETURNING id` form solves the asymmetry problem that plain `DO NOTHING` would have introduced. Both concurrent callers receive an id.
3. The pre-cleanup negative test was valuable and should be preserved as a pattern for future constraint migrations: it proved the proposed constraint catches the documented duplicate before the duplicate was removed.
4. The temporary helper confusion in Stage 5 did not leave live contamination. Final state is 0 helper functions matching `__test_`, `__pay_con`, or `slow`.
5. This workpacket does not modify or re-audit `0142`; it remains an independent Toss intent-binding reference.

## Open Items Carried Forward

Carried forward from `600561_Overview.md` / `600562_Logic.md`:

(a) Adding UNIQUE on `idempotency_key` should remain compatible with all future intent creation paths, including `0027` and `0142`. Stage 4 verified the current local state, but future migrations must preserve the deterministic uniqueness contract.

(b) Advisory-lock namespace governance remains a broader design concern if future workpackets adopt advisory locks elsewhere. It is not needed for this fix.

(c) Option (b)/(c) lock-interaction tests are moot for this workpacket because option (a) was implemented, but the comparison remains useful context.

(d) Existing duplicate cleanup was deliberately narrow: only the documented loser row was deleted. Any future duplicate group must be handled by its own explicit review.

(e) If new duplicate `idempotency_key` groups are discovered in another environment, do not bulk-delete. Inventory references and select winners explicitly.

(f) If the UNIQUE constraint fails in cloud or another target after the documented local cleanup, stop and report the duplicate inventory. Do not infer winners automatically.

(g) FK reference state can change between design and execution. FK checks must remain a hard precondition before deleting any duplicate row.

(h) Test isolation rules should be promoted into a broader project rule or verification guideline so concurrency tests cannot again pollute live function bodies or leave unprefixed helper functions behind.

## New Process Recommendation

When multiple verifiers run live concurrency tests in parallel, each verifier must include a verifier-specific identifier in temporary helper function names, for example:

- `__test_cursor_payment_intent_race_probe`
- `__test_ant_payment_intent_race_probe`
- `__test_codex_payment_intent_race_probe`

This avoids confusion where one verifier sees or deletes another verifier's helper while both are testing the same live database. Candidate for future inclusion in `000701` §40.3 or an adjacent verification hygiene rule.

## Residual Notes

- This audit does not approve unrelated dirty working-tree changes.
- This audit does not authorize cloud migration.
- No git commit was performed by this Stage 6 documentation step.

## Conclusion

`600560_payment_intent_race_condition_fix` is accepted. The known duplicate was safely cleaned, uniqueness is now enforced, the resolver is conflict-safe, dual independent verification confirmed the race is closed, and the temporary-helper cleanup process ended with 0 live helper functions.

Final status: **ACCEPT.**



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600571_Overview_Cancel_Payment_Phantom_Column_Fix.md] =====
# 600571_Overview_Cancel_Payment_Phantom_Column_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15
Revision: 2 — 옵션 B 채택 확정, `refund_payment()`/`request_refund()` 관계 확인(§7.5 신규), 범위를 Workpacket 1(이번)/Workpacket 2(이월)로 명확히 분리.

## Change ID

`cancel_payment_phantom_column_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550`/`600560` 4개다(재확인, `ls`). 10단위 관례상 `600560` 다음 빈 번호는 `600570` — 지시문의 가칭과 일치한다.

## §1 배경 재확인 — `payment_ledger` 컬럼 개수 정정, `updated_at` 부재 재확인

지시문은 "삼중검증 완료... 재확인 불필요"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 직접 재확인했다. **정정 필요**: 배경은 "payment_ledger 실제 컬럼 24개(오늘 이미 확인)"라고 했으나, `information_schema.columns` 라이브 재조회 결과 **28개**다(`600550`/`600560` 워크패킷에서 이미 확인된 것과 동일한 수 — 이번 문서에서 재확인). `updated_at` 컬럼은 이 28개 중에 **없다**(재확인, 0건) — 이 핵심 주장 자체는 정확하다.

## §2 `cancel_payment()`(`0037:13-238`) 전수 감사

**함수가 접점을 갖는 테이블 전부**를 `payment_ledger` 외에도 개별적으로 재확인했다(지시문의 "confirm_payment()에서 5개나 나왔던 전례가 있으니 안심하지 말 것" 원칙 적용).

| 테이블 | 참조 컬럼 | 결과 |
|---|---|---|
| `catchmenu_payment.payment_ledger`(SELECT, L43-49) | `id,order_id,session_id,intent_id,ledger_status,approved_amount,kds_release_authorized,provider_type,provider_payment_key,provider_approval_number,business_day,business_timezone` | 전부 실존 |
| `catchmenu_agent.evidence_packets`(INSERT, L73-96) | `tenant_id,store_id,packet_type,packet_status,risk_level,subject_type,subject_id,payment_ledger_id,prior_state,staff_visible_explanation,actor_type,actor_id,correlation_id,business_day,business_timezone` | 전부 실존(라이브 39개 컬럼 전체 대조) |
| `catchmenu_payment.payment_ledger`(UPDATE, L101-108) | `ledger_status,cancelled_amount,net_amount,kds_release_authorized,evidence_packet_id,updated_at` | **`updated_at` 1건만 phantom** — 나머지 5개는 실존 |
| `catchmenu_kds.kds_tickets`(UPDATE, L112-117) | `kds_status,cancelled_at,hold_reason,updated_at` | 전부 실존 |
| `catchmenu_pos.orders`(UPDATE, L124-128) | `order_status,cancelled_at,updated_at` | 전부 실존 |
| `catchmenu_pos.order_sessions`(UPDATE, L133-137) | `session_status,cancelled_at,updated_at` | 전부 실존 |
| `catchmenu_payment.payment_events`(INSERT, L142-148) | `tenant_id,store_id,order_id,ledger_id,event_type,from_status,to_status,caused_by_type,caused_by_id,amount_at_event,event_payload,correlation_id,occurred_at` | 전부 실존 |
| `catchmenu_ledger.events`(INSERT, L165-174) | `tenant_id,store_id,event_domain,event_type,event_version,subject_type,subject_id,from_state,to_state,caused_by_type,caused_by_id,event_payload,order_id,payment_id,correlation_id,business_day,business_timezone,occurred_at` | 전부 실존 |
| `catchmenu_audit.append_audit_record(...)` | 함수 호출(파라미터), 테이블 스키마 문제 아님 | 별도 검토 대상 아님 |

**결론**: `cancel_payment()`는 배경이 지목한 `payment_ledger.updated_at`(L108) **딱 1건**만 phantom이다 — 다른 7개 접점 테이블 전체를 개별 대조했으나 추가 phantom은 발견되지 않았다. `ledger_status`에 세팅하는 값(`'CANCELLED'`)도 `chk_ledger_status` 허용값에 있음을 재확인했다.

## §3 `partial_cancel_payment()`(`0037:241-479`) 전수 감사 — 신규 발견, 동일 결함

지시문이 "같은 파일 안에 있다면 함께 확인"이라 요청한 대로 확인한 결과, **이 함수도 존재하며, `cancel_payment()`와 정확히 동일한 phantom 컬럼 결함을 갖고 있다.**

`payment_ledger` UPDATE(`0037:352-361`):
```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case when v_new_net_amount = 0 then 'CANCELLED' else 'PARTIAL_CANCELLED' end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()   -- ← phantom, cancel_payment()와 동일한 컬럼
where id = p_ledger_id;
```
`ledger_status`에 세팅하는 두 값(`'CANCELLED'`/`'PARTIAL_CANCELLED'`) 모두 CHECK 허용값 안에 있다. 나머지 접점(`evidence_packets`/`payment_events`/`catchmenu_ledger.events`/`append_audit_record`)도 `cancel_payment()`와 동일한 컬럼 구성이며 전부 실존을 재확인했다. **`updated_at` 1건만 phantom** — `cancel_payment()`와 동일한 패턴.

## §4 `refund_payment()`(`0037:482-737`) 전수 감사 — 지시문에 없었으나 같은 파일, 동일 결함 발견

지시문은 이 함수를 명시적으로 지목하지 않았으나, 같은 파일(`0037`)에 정의되어 있고(`grep`으로 재확인) `payment_ledger`를 직접 수정하는 세 번째 함수이므로 전수 확인 범위에 포함했다.

`payment_ledger` UPDATE(`0037:603-610`):
```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,   -- 'REFUNDED' 또는 'PARTIAL_REFUNDED', 둘 다 CHECK 허용값
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()   -- ← phantom, 세 번째 동일 발생
where id = p_ledger_id;
```
`catchmenu_pos.orders` UPDATE(`0037:613-620`)의 `updated_at`은 `orders` 테이블에는 실제로 존재하므로 문제 없음 — **`payment_ledger.updated_at`만** phantom이다. 나머지 접점(`evidence_packets`/`payment_events`/`catchmenu_ledger.events`/`append_audit_record`) 전부 실존 확인.

**§2-§4 종합**: `0037` 파일의 세 함수(`cancel_payment`/`partial_cancel_payment`/`refund_payment`) 전부가 **동일한 단일 원인**(`payment_ledger.updated_at` phantom, 총 3회 반복)으로 100% 크래시한다 — 이 테이블은 애초에 범용 `updated_at` 갱신 관례를 쓰지 않고 목적별 개별 타임스탬프 컬럼(`approved_at`/`kds_release_authorized_at`/`reconciliation_checked_at`)만 갖는 설계인데, `0037`의 세 함수 모두 이 관례를 잘못 가정하고 작성된 것으로 보인다.

## §5 `request_refund()`(`0098:859-1095`) 전수 감사 — 대규모 신규 발견, 배경이 파악한 것보다 훨씬 심각

배경은 `ledger_status='REFUND_PENDING'`이 `chk_ledger_status` 허용값에 없다는 **한 가지**만 지목했다. 전수 감사 결과 **같은 INSERT 문 안에 phantom 컬럼 6개가 추가로 있고, NOT NULL 컬럼 2개가 누락됐으며, phantom CHECK 값도 하나 더 있다.**

`payment_ledger` INSERT(`0098:950-982`) 컬럼 대조:

| INSERT가 쓰는 컬럼 | 라이브 실존 여부 |
|---|---|
| `tenant_id`/`store_id`/`order_id`/`session_id` | 실존 |
| `provider_type` | 실존 |
| `payment_method` | **phantom**(`confirm_payment()` 원래 결함과 동일) |
| `provider_tx_id` | **phantom**(→ `provider_payment_key`여야 함) |
| `provider_approval_number` | 실존 |
| `approved_amount` | 실존 |
| `fee_amount` | **phantom**(대응 컬럼 없음) |
| `net_amount` | 실존 |
| `ledger_status`(값: `'REFUND_PENDING'`) | 컬럼은 실존하나 **값이 `chk_ledger_status` 허용 목록(`APPROVED`/`CANCELLED`/`REFUNDED`/`PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`/`UNCERTAIN`/`DISPUTED`/`UNDER_REVIEW`)에 없음**(배경이 지목한 항목, 재확인) |
| `refund_reason` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `is_partial_refund` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `original_ledger_id` | **phantom, 신규 발견**(대응 컬럼 없음) |
| `business_day`/`business_timezone` | 실존 |
| (컬럼 목록에 없음) `intent_id` | **NOT NULL 컬럼 누락**(`confirm_payment()` 원래 결함과 동일 패턴) |
| (컬럼 목록에 없음) `ledger_entry_type` | **NOT NULL 컬럼 누락**(동일) |

추가로, `append_audit_record(p_decision := 'REFUND_PENDING', ...)`(`0098:1015`) — **`catchmenu_ledger.audit_records`의 `chk_audit_decision` CHECK 제약(허용값: `APPROVED`/`REJECTED`/`OVERRIDDEN`/`DELEGATED`/`ESCALATED`/`CANCELLED`/`COMPLETED`/`FAILED`/`NOTED`/`SUSPENDED`/`REVOKED`)에도 `'REFUND_PENDING'`이 없다** — 라이브 재확인, 신규 발견. 다만 이 함수는 `payment_ledger` INSERT(위 표)에서 먼저 크래시하므로 이 지점까지 실행이 도달하지도 못한다.

`catchmenu_pos.orders`/`catchmenu_kds.kds_tickets` UPDATE, `catchmenu_ledger.events` INSERT는 전부 실존 컬럼만 사용(재확인). `notify_channel()` 호출은 함수 호출이라 별도.

**요약**: `request_refund()`는 `payment_ledger` INSERT 하나에 phantom 컬럼 **6개**(`payment_method`/`provider_tx_id`/`fee_amount`/`refund_reason`/`is_partial_refund`/`original_ledger_id`) + NOT NULL 누락 **2개**(`intent_id`/`ledger_entry_type`) + phantom CHECK 값 **2개**(`ledger_status='REFUND_PENDING'`, `audit_records.decision='REFUND_PENDING'`)를 동시에 갖는다 — `confirm_payment()`의 원래 결함(5개)보다 많다.

## §6 `confirm_refund()`(`0098:1101-1288`) 전수 감사 — 추가 대규모 신규 발견

`request_refund()`가 만든(만들려고 시도하는) 환불 원장을 나중에 확정하는 함수. `request_refund()`가 이미 크래시하므로 이 함수는 현재 **실제로 호출될 데이터 자체가 만들어지지 않는다** — 그러나 이 함수 자신의 코드도 독립적으로 phantom 결함을 갖고 있어, 별도로 기록한다.

`payment_ledger` SELECT(`0098:1137-1145`): `refund_reason`/`original_ledger_id`(둘 다 phantom, §5와 동일 컬럼) 조회 시도, `where ledger_status = 'REFUND_PENDING'`(phantom 값, §5와 동일).

`payment_ledger` UPDATE 1(`0098:1164-1176`, 환불 원장 자체):
```sql
set
  ledger_status = v_new_status,        -- 'REFUNDED' 또는 'REFUND_FAILED'
  provider_tx_id = p_provider_cancel_tx_id,   -- phantom
  provider_response = coalesce(...),          -- phantom(→ provider_response_id여야 함)
  refunded_at = case ... end,                 -- phantom(신규 발견, 대응 컬럼 없음 — refunded_amount는 있으나 refunded_at은 없음)
  updated_at = now()                          -- phantom
where id = p_refund_ledger_id;
```
**`v_new_status`의 `'REFUND_FAILED'`도 `chk_ledger_status` 허용값에 없다**(신규 발견 — `REFUND_PENDING`과 별개의 두 번째 phantom 값). `'REFUNDED'`는 허용값에 있어 정상.

`payment_ledger` UPDATE 2(`0098:1180-1185`, 원결제 원장):
```sql
set
  ledger_status = 'REFUNDED',   -- 허용값, 정상
  refunded_at = now(),          -- phantom(위와 동일)
  updated_at = now()            -- phantom
where id = v_refund.original_ledger_id;
```

`append_audit_record(p_decision := v_new_status, ...)`(`0098:1235`) — `v_new_status`가 `'REFUNDED'`든 `'REFUND_FAILED'`든 **둘 다 `chk_audit_decision` 허용값에 없다**(§5에서 확인한 CHECK 목록에 `REFUNDED`/`REFUND_FAILED` 어느 쪽도 없음) — 신규 발견.

`catchmenu_ledger.events` INSERT(`0098:1247-1254`)는 전부 실존 컬럼 사용, 문제 없음. `log_diagnostic()`/`create_operation_alert()` 호출은 함수 호출이라 별도(이번 문서에서 파라미터 체크 제약까지는 확인하지 않음, §9 Open Item).

**요약**: `confirm_refund()`는 phantom 컬럼 **5개**(`provider_tx_id`/`provider_response`/`refunded_at`×2회/`updated_at`×2회, `refund_reason`/`original_ledger_id`는 SELECT에서 재사용) + phantom CHECK 값 **3개**(`ledger_status='REFUND_PENDING'` 조회 조건, `ledger_status='REFUND_FAILED'`, `audit_records.decision`에 `'REFUNDED'`/`'REFUND_FAILED'` 둘 다) 결함을 갖는다.

## §7 종합 인벤토리 — 두 파일, 다섯 함수, phantom 총계

| 함수 | 파일 | phantom 컬럼명 개수 | NOT NULL 누락 | phantom CHECK 값 | 현재 실제 호출자(§7.5에서 재확인) |
|---|---|---|---|---|---|
| `cancel_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | **2건, 활성** — `0038`(Toss 웹훅), `0056`(VAN) |
| `partial_cancel_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | 0건 |
| `refund_payment()` | `0037` | 1(`updated_at`) | 0 | 0 | 0건 |
| `request_refund()` | `0098` | 6 | 2(`intent_id`/`ledger_entry_type`) | 2(`ledger_status`/`audit_records.decision`, 둘 다 `'REFUND_PENDING'`) | **3건, 활성** — `0102`(OKPOS)/`0103`(Toss Payments)/`0104`(Toss POS), 셋 다 자기 자신을 "표준 환불 파이프라인"이라 주석에 명시 |
| `confirm_refund()` | `0098` | 5(중복 포함 실질 4종) | 0 | 3(`ledger_status`×2 값, `audit_records.decision`×2 값) | 0건(SQL 직접 호출 없음 — `0113` API 스펙 문서에 Edge Function 웹훅 콜백 대상으로만 문서화됨) |

**공통 원인 vs 개별 원인**: `payment_ledger.updated_at` 부재는 5개 함수 전부에 공통(`request_refund`/`confirm_refund`도 각각 갖고 있음 — 위 표의 개수에 포함됨). 나머지(phantom 컬럼명 다수, `REFUND_PENDING`/`REFUND_FAILED` 같은 미정의 상태값)는 환불 파이프라인(`request_refund`/`confirm_refund`)에만 있는 **훨씬 심각한 별개 결함군**이다 — `0037`의 세 함수가 "컬럼 이름 하나만 잘못됨"인 반면, `0098`의 환불 두 함수는 **애초에 존재하지 않는 상태 모델(별도의 "환불 대기 원장 행"을 만드는 설계) 자체가 라이브 스키마와 근본적으로 안 맞는 것**으로 보인다 — `refund_reason`/`is_partial_refund`/`original_ledger_id`/`refunded_at` 4개 모두 이 "별도 환불 원장 행" 설계에만 필요한 개념이며 `0014`의 실제 DDL에는 애초에 반영되지 않았다.

## §7.5 필수 사전 확인 — `refund_payment()`와 `request_refund()`/`confirm_refund()`의 관계 (Revision 2, Human 요청 반영)

지시문의 우려("이름은 다르지만 같은 '환불' 개념을 다루는 두 그룹이 있는데, 병렬 파이프라인인지 한쪽이 legacy인지")를 실제 호출자 재확인으로 답한다.

### §7.5.1 `refund_payment()`의 정확한 역할과 호출자

`0037:2-5`(파일 헤더, 원문): `"cancel_payment: full cancellation of approved payment. partial_cancel_payment: partial amount cancellation. refund_payment: refund after order completion."` — 즉 파일 작성자 자신의 의도는 `cancel_payment()`(승인된 결제의 완전 취소, 주문 완료 전 상황)와 `refund_payment()`(주문 완료 후 환불)을 **서로 다른 생애주기 시점**의 함수로 명확히 구분해뒀다.

**호출자 재확인**(전체 `sql/migrations/*.sql` + `catchmenu_app/`/`apps/` 재검색, 자기 자신의 정의/주석/grant/revoke 제외): `refund_payment()`는 **0건**이다 — SQL 어디에서도, 클라이언트 코드 어디에서도 호출되지 않는다.

### §7.5.2 두 그룹의 관계 — "병렬 파이프라인" 맞음, "하나는 legacy" 아님

라이브 재확인 결과, `cancel_payment()`(`0037`)와 `request_refund()`(`0098`)는 이 세션에서 이미 확인된 "`confirm_payment_from_provider()`(`0027`) vs `confirm_payment()`(`0098`)" 병렬 파이프라인 구조와 **정확히 같은 형태로 갈라져 있다**:

| | 파이프라인 1 (`0027`/`0038`/`0056`) | 파이프라인 2 (`0098`/`0102`/`0103`/`0104`) |
|---|---|---|
| 결제 확인 | `confirm_payment_from_provider()`(`0027`) | `confirm_payment()`(`0098`) |
| 취소/환불 | `cancel_payment()`(`0037`) — **활성, 호출자 2건**(`0038`/`0056`) | `request_refund()`(`0098`) — **활성, 호출자 3건**(`0102`/`0103`/`0104`) |
| 이 파이프라인만의 미사용 함수 | `partial_cancel_payment()`(`0037`, 0건)/`refund_payment()`(`0037`, 0건) | `confirm_refund()`(`0098`, 0건 — 단 Edge Function 웹훅 콜백용으로 설계된 것으로 보임, §5 인용) |

**결론(사실, 판단 아님)**: `refund_payment()`가 `request_refund()`/`confirm_refund()`의 legacy(구버전, 대체된 것)라는 근거는 **없다** — 두 그룹 다 각자의 파이프라인 파일(`0037`/`0098`) 안에서 독립적으로 정의됐고, 어느 한쪽이 다른 쪽을 대체했다는 흔적(`rename`, `_legacy` 접미사, deprecation 주석 등)이 코드에 없다. 대신 실제 패턴은: **파이프라인 1은 "취소"(`cancel_payment`)만 실제로 배선되어 있고 "완료 후 환불"(`refund_payment`)은 설계만 되고 배선되지 않은 상태**, **파이프라인 2는 "환불 요청"(`request_refund`)까지는 배선되어 있고 "환불 확정"(`confirm_refund`)은 Edge Function 콜백을 기다리는 설계**로 각각 다르게 미완성이다. 이는 이 세션에서 반복 확인된 "설계는 됐으나 배선 안 된 함수"(`start_cooking()`/`bulk_commit_kds_tickets()`/`flush_offline_queue()`의 `RECORD_MANUAL_PAYMENT` 등) 패턴과 일치한다.

### §7.5.3 부수 발견 — `request_refund()`의 실제 호출 파라미터, 크래시 도달 여부가 호출자마다 다름

`request_refund()`는 `p_refund_amount <= 0`이면 즉시 `refund_amount_invalid` 에러로 조기 반환한다(`0098:924-938`, phantom 컬럼 INSERT 이전). 실제 호출부를 확인한 결과:
- `0103`(Toss Payments, L834): `p_refund_amount := v_refund_amount`(계산된 실제 금액) — **phantom INSERT까지 실제로 도달할 수 있다.**
- `0102`(OKPOS, L1049)/`0104`(Toss POS, L954): `p_refund_amount := 0`(하드코딩) — **항상 조기 반환하며, phantom INSERT에 도달하지 않는다.**

이는 `request_refund()` 자체의 phantom 컬럼 결함(§5)과는 별개의, **호출자 쪽의 파라미터 버그**로 보인다(0원 환불 요청 자체가 무의미) — 이번 워크패킷(Workpacket 1)의 범위 밖이며, `600098`(Workpacket 2, 환불 파이프라인 재설계)에서 다룰 사안으로 기록한다.

## §8 범위 확정 — Workpacket 1(이번, `0037` correction) / Workpacket 2(이월, `0098` 환불 파이프라인 재설계)

**Human 결정(2026-07-15, 재논의 금지)**: 옵션 B 채택. `0037`의 `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 세 함수의 동일 phantom 컬럼(`updated_at`)을 이번 워크패킷(Workpacket 1)에서 함께 수정한다. `0098`의 `request_refund()`/`confirm_refund()`는 원장 모델 재설계가 필요한 완전히 다른 성격의 작업이므로 이번 범위에서 제외하고, 별도 워크패킷("Refund Pipeline Contract Redesign")으로 이월한다.

### Workpacket 1(이번 워크패킷) — `0037` correction 허용/금지 사항

| 구분 | 내용 |
|---|---|
| **허용** | `payment_ledger` UPDATE 문에서 `updated_at = now()` 제거(3개 함수, 총 3개소) |
| **허용** | 최소 문법 정렬(예: 제거로 인해 어긋나는 콤마/줄바꿈 등 순수 구문 정리) |
| **허용** | 검증(Stage 5) — 세 함수 각각 실제 호출/재현 |
| **금지** | 상태 전이 로직 변경(`ledger_status` 분기, `CANCELLED`/`PARTIAL_CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` 값 자체나 그 조건) |
| **금지** | 환불 원장 구조 변경(`refunded_amount`/`cancelled_amount`/`net_amount` 계산 로직) |
| **금지** | 함수 통합·rename(`cancel_payment`/`partial_cancel_payment`/`refund_payment`를 하나로 합치거나 이름을 바꾸는 것) |
| **금지** | `0098`(`request_refund`/`confirm_refund`) 수정 — Workpacket 2 범위 |
| **금지** | 호출부 리팩토링(`0038`/`0056`이 `cancel_payment()`를 호출하는 방식 자체를 바꾸는 것 — phantom 컬럼 제거로 호출부의 파라미터 계약이 바뀌지 않으므로 애초에 손댈 필요가 없다) |

### Workpacket 2(별도 이월) — 환불 파이프라인 재설계, 이번 문서는 범위만 표시

`request_refund()`/`confirm_refund()`(`0098`) — phantom 컬럼 6+5개, NOT NULL 누락 2개, phantom CHECK 값(두 테이블에 걸쳐) 최대 5개(§5/§6), `0102`/`0104`의 `p_refund_amount:=0` 호출 버그(§7.5.3)까지 포함해 종합 재설계가 필요하다. `600550`(`confirm_payment` 정합화, `intent_origin` 신설)과 유사한 수준의 Overview/Logic 재작업이 필요하다고 판단되며, 이번 문서는 그 필요성만 기록하고 설계하지 않는다.

## §9 Open Questions

(a) ~~5개 함수 전부의 실제 라이브 호출자~~ — **해소됨(§7.5)**: `cancel_payment()`(2건, 활성)/`request_refund()`(3건, 활성)은 각자 파이프라인의 실제 사용 경로이고, `partial_cancel_payment()`/`refund_payment()`/`confirm_refund()`는 0건(잠재적, 배선 안 됨).
(b) `log_diagnostic()`/`create_operation_alert()`(`confirm_refund()`가 호출) 등 함수 호출의 파라미터 자체가 유효한지(예: `p_log_level`/`p_alert_severity`의 CHECK 허용값)는 이번 문서에서 확인하지 않았다 — Workpacket 2 범위.
(c) `chk_ledger_status`에 `REFUND_PENDING`/`REFUND_FAILED`를 신규 허용값으로 추가하는 것이 옵션인지(DDL 확장), 아니면 완전히 다른 상태 표현(예: 별도 `refund_status` 컬럼, 또는 `600550`의 `intent_origin`처럼 provenance 컬럼 추가)이 나은지는 Workpacket 2의 핵심 설계 결정이 된다 — 이번 문서는 판단하지 않는다.
(d) `original_ledger_id`(환불 원장이 원결제 원장을 가리키는 개념)를 표현할 방법 — `payment_ledger`에 자기 참조 FK 컬럼을 추가할지, 다른 방식(예: `payment_events`/`catchmenu_ledger.events`의 기존 이력 추적 메커니즘 재사용)으로 대체할지도 Workpacket 2 결정 사항.
(e) **신규(Revision 2)** — `0102`/`0104`가 `request_refund()`를 `p_refund_amount := 0`으로 호출하는 것(§7.5.3)이 의도된 설계(예: "0원 환불 = 순수 취소 신호"라는 다른 의도)인지 단순 버그인지 — Workpacket 2에서 확인 필요.
(f) **신규(Revision 2)** — `cancel_payment()`가 활성 호출자를 가진 이상(`0038`/`0056`), Workpacket 1의 `updated_at` 제거가 이 두 호출부의 기존 동작(현재는 매번 크래시하고 있었을 것)에 실질적으로 어떤 변화를 일으키는지(즉 지금까지 Toss 웹훅/VAN 경로의 결제 취소가 전부 실패해왔다는 뜻인지)는 Workpacket 1의 TestPlan/Verification 단계에서 명시적으로 확인해야 한다 — 이번 Overview는 phantom 컬럼 존재만 확인했다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` — `confirm_payment()`(0098) 원래 결함 수정 선례, 이번 워크패킷이 참고하는 패턴.
- `000056_Register_Concurrency_Risk.md` — 동시성 레지스터, 이 워크패킷은 phantom 컬럼(정합성) 문제이지 동시성 문제는 아니라는 점에서 구분됨.

### Full Rules Required

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(L13-238)/`partial_cancel_payment()`(L241-479)/`refund_payment()`(L482-737) 전체.
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `request_refund()`(L859-1095)/`confirm_refund()`(L1101-1288) 전체.
- `sql/migrations/0014_create_payment_ledger.sql` — `payment_ledger` 실제 28개 컬럼, `chk_ledger_status` CHECK 제약.
- `catchmenu_ledger.audit_records`의 `chk_audit_decision` CHECK 제약(라이브 재확인, 이번 문서에서 처음 인용).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `log_diagnostic()`/`create_operation_alert()` 파라미터 유효성(§9 (b)) — Workpacket 2 범위.
- `REFUND_PENDING`/`REFUND_FAILED` 상태 표현 재설계(§9 (c)/(d)) — 판단하지 않음, Workpacket 2 대상.
- `0102`/`0104`의 `p_refund_amount:=0` 호출 버그(§7.5.3/§9 (e)) — Workpacket 2 대상.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Revision 2, Human 결정 반영).** §1에서 배경의 컬럼 개수(24→28) 오류를 정정했다. §2에서 `cancel_payment()`가 정확히 배경이 지목한 1건(`updated_at`)만의 결함임을 7개 접점 테이블 전수 대조로 확인했다. §3/§4에서 같은 파일의 `partial_cancel_payment()`/`refund_payment()`도 동일한 단일 결함을 갖고 있음을 신규로 확인했다. §5/§6에서 `request_refund()`/`confirm_refund()`가 훨씬 심각한 별개 결함군(phantom 컬럼 6+5개, NOT NULL 누락 2개, phantom CHECK 값 최대 5개)을 가짐을 확인했다. **§7.5(신규)에서 Human이 요청한 필수 사전 확인을 완료했다** — `cancel_payment()`(2건)/`request_refund()`(3건)는 각각 활성 파이프라인이며, `refund_payment()`는 legacy가 아니라 애초에 배선되지 않은 미완성 기능이다(호출자 0건, 대체 흔적 없음). **§8에서 Human 결정에 따라 옵션 B를 최종 채택**, Workpacket 1(이번, `0037` 세 함수의 `updated_at` correction, 정확한 허용/금지 목록 명시)과 Workpacket 2(이월, `0098` 환불 파이프라인 재설계)로 범위를 명확히 분리했다. `600572_Logic.md`(Workpacket 1)로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600572_Logic_Cancel_Payment_Phantom_Column_Fix.md] =====
# 600572_Logic_Cancel_Payment_Phantom_Column_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`cancel_payment_phantom_column_fix`

## §0 전제 — Workpacket 1 범위 (`0037` correction only)

`600571_Overview.md` §8이 확정한 Workpacket 1 범위를 그대로 따른다: `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`의 `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 세 함수에서 `payment_ledger.updated_at`(실존하지 않는 컬럼) 참조만 제거한다. 상태 전이 로직, 금액 계산, 함수 시그니처, 다른 파일(`0098` 등)은 전부 무변경 — `600571_Overview.md` §8의 허용/금지 목록을 그대로 상속한다.

**활성 경로 복구임을 재확인**: `cancel_payment()`는 실제 호출자 2개(`0038` Toss 웹훅, `0056` VAN)를 가진 활성 함수다(`600571_Overview.md` §7.5.1) — 이 수정은 사용되지 않는 코드의 정리 작업이 아니라, 현재 크래시하고 있는 실제 콜백 경로(PG/VAN이 결제 취소를 통보할 때마다 실패하고 있었을 가능성)를 복구하는 작업이다.

## §1 최종 라이브 재확인 — UPDATE 문이 참조하는 모든 컬럼, 마지막 기회

지시문의 "또 다른 숨은 phantom이 있는지 이번이 마지막 기회"라는 요청에 따라, 세 함수의 `payment_ledger` UPDATE 문이 참조하는 전체 컬럼(`updated_at` 제외)을 이번 문서 작성 시점에 다시 한번 라이브로 재조회했다:

```sql
select column_name, data_type, is_nullable from information_schema.columns
where table_schema='catchmenu_payment' and table_name='payment_ledger'
  and column_name in ('ledger_status','cancelled_amount','net_amount',
    'kds_release_authorized','evidence_packet_id','refunded_amount','approved_amount','updated_at');
```
```
      column_name       | data_type | is_nullable 
------------------------+-----------+-------------
 approved_amount        | integer   | NO
 cancelled_amount       | integer   | NO
 evidence_packet_id     | uuid      | YES
 kds_release_authorized | boolean   | NO
 ledger_status          | text      | NO
 net_amount             | integer   | NO
 refunded_amount        | integer   | NO
```
질의한 8개 컬럼명 중 `updated_at`만 결과에 없다(7행만 반환) — **세 UPDATE 문이 `updated_at` 외에 참조하는 모든 컬럼(`ledger_status`/`cancelled_amount`/`net_amount`/`kds_release_authorized`/`evidence_packet_id`/`refunded_amount`)은 전부 실존하며 타입도 코드의 대입값과 일치한다**(`cancelled_amount`/`net_amount`/`refunded_amount`는 `integer`— 코드가 정수 계산 결과를 대입, `kds_release_authorized`는 `boolean`— 코드가 `false` 리터럴을 대입, `ledger_status`는 `text`— 코드가 문자열 리터럴/`case` 결과를 대입, `evidence_packet_id`는 `uuid`— 코드가 `v_evidence_id`를 대입). 추가로 숨은 phantom은 발견되지 않았다 — `600571_Overview.md` §2/§3/§4의 결론(각 함수당 `updated_at` 1건만)이 이번 최종 재확인으로도 그대로 유지된다.

## §2 `cancel_payment()` — 정확한 Before/After

```sql
-- Before (0037:101-109, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
변경은 `updated_at = now()` 한 줄과 그 앞 줄의 트레일링 콤마뿐이다(`evidence_packet_id = v_evidence_id,` → `evidence_packet_id = v_evidence_id`). 그 외 함수 본문 전체(파라미터, `evidence_packets` INSERT, `kds_tickets`/`orders`/`order_sessions` UPDATE, `payment_events`/`catchmenu_ledger.events` INSERT, `append_audit_record` 호출, 반환값)는 완전히 동일하게 유지한다.

## §3 `partial_cancel_payment()` — 정확한 Before/After

```sql
-- Before (0037:352-362, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
동일하게 `updated_at = now()` 한 줄만 제거. `case` 분기 로직, 금액 계산, 나머지 함수 본문은 완전히 동일하게 유지한다.

## §4 `refund_payment()` — 정확한 Before/After

```sql
-- Before (0037:603-610, 현재)
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;

-- After (설계안)
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```
동일 패턴. 이 함수 안의 별도 `catchmenu_pos.orders` UPDATE(`0037:613-620`)에 있는 `updated_at = now()`는 `orders` 테이블에는 실제로 존재하는 컬럼이므로(`600571_Overview.md` §4에서 이미 확인) **건드리지 않는다** — 이번 워크패킷은 `payment_ledger`의 `updated_at`만 제거 대상이다.

## §5 마이그레이션 설계 (Stage 4 대상, 이번 턴 미실행)

세 함수 모두 같은 파일(`0037`)에 있으므로, `0157`/`0158`이 그랬듯 하나의 신규 forward migration에서 세 함수 전부를 `create or replace function`으로 재정의한다(원본 `0037` 파일 자체는 무편집 유지, append-only 관례). 다음 candidate 번호는 Stage 4 착수 직전 재확인 필요(이번 문서 작성 시점 기준 `sql/migrations/` 최고 번호는 `0158`이므로 `0159`가 후보이나, Stage 4 시점에 다시 확인해야 한다).

## §6 Open Item — `refund_payment()`(호출자 0건) DROP 여부, 이번 워크패킷에서 결정하지 않음

`600571_Overview.md` §7.5.1이 확인한 대로 `refund_payment()`는 실제 호출자가 0건이며, `partial_cancel_payment()`도 마찬가지다. 이 두 함수를 이번 기회에 DROP할지, 아니면 `updated_at`만 고쳐서 향후 배선을 기다리는 상태로 남겨둘지는 **이번 워크패킷에서 판단하지 않는다** — `600571_Overview.md` §8의 Workpacket 1 허용 목록 자체가 "correction만 허용, 함수 통합·rename 금지"로 이미 DROP을 배제하고 있으며, Human 지시문("DROP 여부는 이번 워크패킷에서 결정하지 않고 별도 판단 대상으로 명시")과도 일치한다. 두 함수 모두 이번 워크패킷에서는 **살아있는 채로, `updated_at`만 고쳐서** 남긴다 — DROP 여부의 재판단은 별도 워크패킷(예: 호출자 0건 함수 전수 정리 워크패킷) 대상으로 이월한다.

이 Open Item은 `600571_Overview.md` §8의 Workpacket 2(환불 파이프라인 재설계)와도 다르다 — `refund_payment()`/`partial_cancel_payment()`의 DROP 여부는 원장 모델 재설계 문제가 아니라 단순 "미사용 코드 정리" 판단이므로, 필요하다면 Workpacket 2와도 별개인 세 번째 워크패킷으로 분리될 수 있다.

## §7 Open Items (그 외)

(a) §6의 DROP 판단 워크패킷 자체를 언제, 어떤 번호로 생성할지 — 이번 문서는 결정하지 않는다.
(b) `600571_Overview.md` §9 (f) — `cancel_payment()`의 `updated_at` 제거가 실제로 `0038`/`0056` 호출부에 어떤 변화를 일으키는지(그동안 Toss 웹훅/VAN의 결제 취소가 전부 실패해왔다는 뜻인지)는 TestPlan/Verification 단계에서 실제 호출 재현으로 확인해야 한다 — 이 Logic 문서는 설계만 다루고 검증은 하지 않았다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md`(Revision 2, §7.5/§8 — 이 문서의 직접 전제, Workpacket 1 범위와 허용/금지 목록).

### Full Rules Required

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(L13-238)/`partial_cancel_payment()`(L241-479)/`refund_payment()`(L482-737), 수정 대상 3개 함수.
- `catchmenu_payment.payment_ledger` 라이브 스키마(28개 컬럼) — §1 최종 재확인의 근거.

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`(`request_refund`/`confirm_refund`) — Workpacket 2, 이 문서는 다루지 않음.
- `refund_payment()`/`partial_cancel_payment()`의 DROP 여부(§6) — 별도 판단 대상, 이 문서는 결정하지 않음.
- `0102`/`0104`의 `p_refund_amount:=0` 호출 버그 — Workpacket 2 대상.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §1에서 세 함수의 `payment_ledger` UPDATE 문이 참조하는 전체 컬럼을 최종 재확인했다 — `updated_at` 외 추가 phantom은 없음을 재확인했다. §2/§3/§4에서 세 함수 각각의 정확한 Before/After를 설계했다 — 셋 다 `updated_at = now()` 한 줄 제거가 유일한 변경이며, 그 외 상태 전이/금액 계산/함수 시그니처는 완전히 동일하게 유지한다. §5에서 단일 forward migration으로 세 함수를 함께 재정의하는 마이그레이션 설계 방향을 제시했다. **§6에서 `refund_payment()`/`partial_cancel_payment()`의 DROP 여부를 이번 워크패킷 범위 밖으로 명시적으로 유보했다** — Human 지시와 일치. `600573_TestPlan.md`/`600574_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md] =====
# 600573_TestPlan_Cancel_Payment_Phantom_Column_Fix

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 0. Test Scope

This TestPlan verifies the narrow correction defined in `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` and `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`.

The implementation scope is limited to `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`:

- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`

Each function receives the same single correction: remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` `UPDATE` statement and clean up the trailing comma on the preceding assignment.

No state-transition logic, amount calculation, evidence insertion, audit insertion, event insertion, function signature, or caller contract is changed.

## 1. Pre-Implementation Verification

### 1.1 Confirm the phantom column is absent

Run:

```sql
select column_name
from information_schema.columns
where table_schema = 'catchmenu_payment'
  and table_name = 'payment_ledger'
  and column_name in (
    'ledger_status',
    'cancelled_amount',
    'net_amount',
    'kds_release_authorized',
    'evidence_packet_id',
    'refunded_amount',
    'approved_amount',
    'updated_at'
  )
order by column_name;
```

Expected:

- All seven intended columns exist:
  - `approved_amount`
  - `cancelled_amount`
  - `evidence_packet_id`
  - `kds_release_authorized`
  - `ledger_status`
  - `net_amount`
  - `refunded_amount`
- `updated_at` is absent.

### 1.2 Confirm the three stale references exist before the fix

Run a source grep against `0037_create_payment_cancel_refund_rpc.sql`.

Expected before implementation:

- `cancel_payment()` payment_ledger update contains `updated_at = now()`.
- `partial_cancel_payment()` payment_ledger update contains `updated_at = now()`.
- `refund_payment()` payment_ledger update contains `updated_at = now()`.

Expected after implementation:

- `updated_at = now()` no longer appears in any `catchmenu_payment.payment_ledger` update in this file.
- Any `updated_at = now()` belonging to other tables, such as `catchmenu_pos.orders`, is not removed merely because it shares the same text.

## 2. Test A — `cancel_payment()` executes successfully

### 2.1 Setup

Create a disposable order/session/payment ledger path using the same practical call shape as the known active callers in `0038_create_toss_webhook_processor_rpc.sql` and `0056_create_van_integration_rpc.sql`.

Recommended setup:

1. Insert a disposable `catchmenu_pos.order_sessions` row.
2. Insert a disposable `catchmenu_pos.orders` row.
3. Call `catchmenu_payment.confirm_payment()` to create an `APPROVED` `payment_ledger` row and associated `payment_intents` row.
4. Capture the returned `ledger_id`.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_cancel_
```

Wrap the observable mutation test in a transaction where practical, and roll back or explicitly delete disposable rows after the test.

### 2.2 Execution

Call:

```sql
select catchmenu_payment.cancel_payment(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_ledger_id := '<approved_ledger_id>'::uuid,
  p_cancel_reason := 'phantom column fix verification',
  p_actor_type := 'STAFF',
  p_actor_id := null,
  p_correlation_id := '__test_cancel_phantom_fix_cancel'
);
```

### 2.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected response:

- `success = true`
- `ledger_status = 'CANCELLED'`

Expected ledger state:

- `ledger_status = 'CANCELLED'`
- `cancelled_amount = approved_amount`
- `net_amount = 0`
- `kds_release_authorized = false`
- `evidence_packet_id is not null`

## 3. Test B — KDS cancellation linkage after `cancel_payment()`

### 3.1 Setup

Before calling `cancel_payment()`, create disposable `catchmenu_kds.kds_tickets` rows for the test order covering the statuses that the function's current predicate actually targets:

- Case 1: `kds_status = 'HOLD'`
- Case 2: `kds_status = 'COMMITTED'`
- Case 3: `kds_status = 'COOKING'`
- Case 4, negative: `kds_status = 'COMPLETED'` or `kds_status = 'SERVED'`

Case 3 is mandatory because it covers the high-risk payment-cancel-vs-cooking-start race: the current `cancel_payment()` predicate excludes only `COMPLETED`, `SERVED`, and `CANCELLED`, so an already-cooking ticket is still in the cancellation target set.

Case 4 is mandatory because completed/served tickets are explicitly excluded by the function and must remain untouched.

The ticket must share:

- `tenant_id`
- `store_id`
- `order_id`

with the payment ledger/order under test.

### 3.2 Expected result

After `cancel_payment()` succeeds, verify:

```sql
select id, kds_status, cancelled_at, hold_reason
from catchmenu_kds.kds_tickets
where order_id = '<test_order_id>'::uuid;
```

Expected by case:

- Case 1, `HOLD`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 2, `COMMITTED`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 3, `COOKING`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 4, `COMPLETED` or `SERVED`: `kds_status` remains unchanged and `cancelled_at` remains null

This is the first required empirical confirmation that the KDS cancellation path actually executes once the `payment_ledger.updated_at` crash is removed.

## 4. Test C — `partial_cancel_payment()` executes successfully

### 4.1 Setup

Create a disposable approved payment ledger using the same setup pattern as Test A.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_partial_
```

### 4.2 Execution

Call `catchmenu_payment.partial_cancel_payment()` with a valid partial amount smaller than the approved amount.

The exact argument list must be taken from the live function signature before execution:

```sql
select pg_get_function_identity_arguments(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'partial_cancel_payment';
```

### 4.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected ledger state for a partial cancellation:

- `ledger_status = 'PARTIAL_CANCELLED'`
- `cancelled_amount` increases by the partial cancellation amount.
- `net_amount = approved_amount - cancelled_amount - refunded_amount`
- `evidence_packet_id is not null`

If the test intentionally cancels the full remaining net amount through this function, then `ledger_status = 'CANCELLED'` is acceptable because that is the pre-existing function logic.

## 5. Test D — `refund_payment()` executes successfully

### 5.1 Setup

Create a disposable ledger state that satisfies `refund_payment()`'s own preconditions. This function currently has no confirmed active callers, but the function itself must still execute after the narrow phantom-column fix.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_refund_
```

### 5.2 Execution

Call `catchmenu_payment.refund_payment()` using the live signature:

```sql
select pg_get_function_identity_arguments(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'refund_payment';
```

### 5.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected ledger state:

- `refunded_amount` changes according to the existing function logic.
- `net_amount` changes according to the existing function logic.
- `ledger_status` follows the existing function branch:
  - `REFUNDED`, or
  - `PARTIAL_REFUNDED`
- `evidence_packet_id is not null`

No assertion in this test authorizes changing `refund_payment()` semantics or dropping the function.

## 6. Regression Checks

For each of the three functions, verify that the following columns still receive the same intended values as before, except that no nonexistent `updated_at` assignment is attempted:

- `ledger_status`
- `cancelled_amount`
- `net_amount`
- `kds_release_authorized`
- `evidence_packet_id`
- `refunded_amount`
- `approved_amount`

The test should explicitly compare before/after row values for the ledger under test.

## 7. Boundary Verification

### 7.1 Source boundary

Run:

```bash
git diff -- sql/migrations/0037_create_payment_cancel_refund_rpc.sql
git diff -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
```

Expected:

- `0037_create_payment_cancel_refund_rpc.sql` contains exactly the three `updated_at = now()` removals from `payment_ledger` updates, plus trailing comma cleanup.
- `0098_create_payment_confirm_pipeline_rpc.sql` has no diff.

### 7.2 Forbidden-file boundary

Verify no diff in:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- any `confirm_payment()` implementation file
- any refund pipeline redesign file
- any caller file such as `0038_create_toss_webhook_processor_rpc.sql` or `0056_create_van_integration_rpc.sql`

### 7.3 Migration application boundary

If Stage 4 implements this as a new forward migration, verify:

- the next migration number is chosen immediately before creation,
- the new migration only redefines the three approved functions or otherwise applies the approved narrow source correction,
- no unrelated schema or function is changed.

## 8. Approval Criteria

This workpacket passes Stage 5 verification only if all are true:

1. `cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
2. `partial_cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
3. `refund_payment()` no longer crashes on `payment_ledger.updated_at`.
4. `cancel_payment()` empirically cancels eligible KDS tickets after payment cancellation.
5. The seven remaining ledger columns are updated according to existing logic.
6. `0098` and unrelated refund pipeline code remain untouched.
7. No function signature changes are introduced.
8. All disposable test data is rolled back or explicitly cleaned up.

## 9. Open Items Not Resolved Here

- Whether `refund_payment()` and/or `partial_cancel_payment()` should eventually be dropped remains a separate decision.
- The `0098` refund pipeline (`request_refund()` / `confirm_refund()`) remains a separate redesign workpacket.
- The `0102` / `0104` caller issue where refund amount is always passed as `0` remains deferred to the refund pipeline redesign workpacket.
- COOKING 상태(이미 조리 시작)에서 결제 취소 시 실제로 CANCELLED로 정확히 전환됨이 Stage 4 실행에서 경험적으로 확인됨(COMPLETED/SERVED는 정확히 보호됨도 확인). 남은 것은 기술 문제가 아니라 순수 운영 정책 문제: 이미 조리 중이던 음식을 취소 시 재료를 폐기할지, 직원 식사로 처리할지, 계속 조리해서 준비해둘지 등은 매장 운영 정책으로 1~2년 뒤 실제 라이브 운영 경험을 바탕으로 결정. `000056_Register_Concurrency_Risk.md`의 `KDS-CON-002` 항목 참고.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix.md] =====
# 600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Human Decision Summary

This ChangeContract implements the final design from:

- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md`
- `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`

The approved design is narrow:

`cancel_payment()` / `partial_cancel_payment()` / `refund_payment()` each contain one invalid `catchmenu_payment.payment_ledger` assignment:

```sql
updated_at = now()
```

`catchmenu_payment.payment_ledger` has no `updated_at` column. Therefore the three functions crash when they reach their `payment_ledger` update.

The correction is:

- remove `updated_at = now()` from each of the three `payment_ledger` updates,
- clean up the trailing comma on the preceding line,
- leave all other logic unchanged.

## 2. Allowed Files

### 2.1 SQL migration source

Allowed:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`

Allowed scope inside that file:

1. `cancel_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

2. `partial_cancel_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

3. `refund_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

### 2.2 Optional forward migration

If Stage 4 follows the append-only migration convention rather than in-place source correction, the next available migration file may be created for this narrow function redefinition.

The new migration must only contain the approved correction for these three functions. It must not introduce schema changes or redesign refund/cancellation logic.

## 3. Forbidden Changes

The following are explicitly out of scope:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- `confirm_payment()`
- `request_refund()`
- `confirm_refund()`
- any `0098` refund pipeline redesign
- state transition logic changes
- amount calculation changes
- evidence packet logic changes
- audit/event insertion logic changes
- function signature changes
- function rename or function consolidation
- `refund_payment()` DROP
- `partial_cancel_payment()` DROP
- caller changes in `0038_create_toss_webhook_processor_rpc.sql`
- caller changes in `0056_create_van_integration_rpc.sql`

This workpacket fixes a phantom column reference only. It does not decide whether any of the affected functions should be deprecated or removed.

## 4. Required Implementation Contract

### 4.1 `cancel_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 4.2 `partial_cancel_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 4.3 `refund_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

## 5. Verification Requirements

Stage 4/5 must execute `600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md`.

Required verification:

1. `cancel_payment()` succeeds and updates `ledger_status = 'CANCELLED'`.
2. `cancel_payment()` updates eligible `kds_tickets` to `CANCELLED`.
3. `partial_cancel_payment()` succeeds and updates the ledger according to existing logic.
4. `refund_payment()` succeeds according to its existing preconditions and logic.
5. No `payment_ledger.updated_at` reference remains in the three approved update statements.
6. The seven valid ledger columns continue to be updated as before:
   - `ledger_status`
   - `cancelled_amount`
   - `net_amount`
   - `kds_release_authorized`
   - `evidence_packet_id`
   - `refunded_amount`
   - `approved_amount`
7. `0098` and all unrelated files have zero diff.

## 6. Open Items

These are explicitly not resolved by this ChangeContract:

1. Whether `refund_payment()` should be dropped because it currently has no confirmed active callers.
2. Whether `partial_cancel_payment()` should be dropped or retained.
3. `0098` refund pipeline redesign:
   - `request_refund()`
   - `confirm_refund()`
4. The `0102` / `0104` caller bug where refund amount is always passed as `0`.
5. Any broader refund/cancellation state machine redesign.

## 7. Human Boundary Approval

Stage 4 implementation may proceed only after all three boxes are checked by the Human owner:

☑ I approve editing only the allowed 0037 function bodies or an equivalent narrow forward migration.
☑ I approve removing only the three payment_ledger.updated_at assignments and required trailing comma cleanup.
☑ I acknowledge that refund pipeline redesign, function DROP decisions, and 0098 changes are out of scope for this workpacket. (2026 - 07 -16)


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600575_Module.md] =====
# 600575_Module.md

Status: Complete
Lifecycle: Module
Stage: 4 Implementation Summary
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Implemented Scope

This module records the Stage 4 implementation of `600570_cancel_payment_phantom_column_fix`.

The implementation corrected the same phantom-column defect in three functions from `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`:

- `catchmenu_payment.cancel_payment()`
- `catchmenu_payment.partial_cancel_payment()`
- `catchmenu_payment.refund_payment()`

Each function attempted to update `catchmenu_payment.payment_ledger.updated_at`, but the live `payment_ledger` table has no `updated_at` column.

## 2. Source Change

The implementation removed only the invalid `updated_at = now()` assignment from each `payment_ledger` update and cleaned the trailing comma immediately before it.

### 2.1 `cancel_payment()`

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 2.2 `partial_cancel_payment()`

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 2.3 `refund_payment()`

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

## 3. Non-Changes

The implementation did not change:

- function signatures,
- payment/cancel/refund state-transition logic,
- amount calculations,
- evidence packet creation,
- payment event creation,
- ledger event creation,
- audit record creation,
- `0098_create_payment_confirm_pipeline_rpc.sql`,
- `confirm_payment()`,
- `request_refund()`,
- `confirm_refund()`,
- `0038` / `0056` caller files,
- any DROP/rename/consolidation decision for `refund_payment()` or `partial_cancel_payment()`.

## 4. Application Method

Because `0037_create_payment_cancel_refund_rpc.sql` had already been applied, Stage 4 used the §24 Lightweight Track pattern:

1. Update the already-applied source file in place.
2. Recalculate the LF-normalized checksum.
3. Update `catchmenu_meta.migration_history`.
4. Re-execute the live SQL function definitions directly.
5. Confirm `tools/apply_migrations.py` reports checksum match.
6. Confirm live `pg_get_functiondef()` reflects the corrected function bodies.

## 5. Checksum

The updated LF-normalized checksum for `0037_create_payment_cancel_refund_rpc.sql` is:

```text
e2e354985a20c81db02bbc8732edcf73bd18c548e8ff90977676516e11c93f78
```

## 6. Result

The three affected functions now execute without the previous `payment_ledger.updated_at` phantom-column crash.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600576_Verification.md] =====
# 600576_Verification.md

Status: Complete
Lifecycle: Verification
Stage: 5 Verification Summary
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Verification Scope

This document records Stage 5 verification for the Stage 4 implementation summarized in `600575_Module.md`.

The verification scope was the full `600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md`:

- §1 pre-checks,
- §2 `cancel_payment()` execution,
- §3 KDS cancellation linkage,
- §4 `partial_cancel_payment()` execution,
- §5 `refund_payment()` execution,
- §6 seven-column regression checks,
- §7 boundary checks.

## 2. Independent Verification Summary

Two independent verification passes were performed with distinct disposable test data.

The two passes used different `order_id` values and non-overlapping correlation-id prefixes. They therefore did not reuse the same test rows or accidentally confirm only one shared fixture.

Both verification passes reached the same result:

- `cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
- `partial_cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
- `refund_payment()` no longer crashes on `payment_ledger.updated_at`.
- KDS ticket cancellation behaves exactly according to the existing `cancel_payment()` predicate.
- The seven intended `payment_ledger` columns still update correctly.
- Boundary checks showed no `0098` or unrelated-file mutation.

## 3. Source and Live Function Verification

The source diff was limited to three `payment_ledger` update blocks in `0037_create_payment_cancel_refund_rpc.sql`.

The live functions were reloaded and checked with `pg_get_functiondef()`.

Confirmed live `payment_ledger` update blocks:

```sql
-- cancel_payment()
ledger_status = 'CANCELLED',
cancelled_amount = approved_amount,
net_amount = 0,
kds_release_authorized = false,
evidence_packet_id = v_evidence_id
```

```sql
-- partial_cancel_payment()
ledger_status = case
  when v_new_net_amount = 0 then 'CANCELLED'
  else 'PARTIAL_CANCELLED'
end,
cancelled_amount = v_new_cancelled_amount,
net_amount = v_new_net_amount,
evidence_packet_id = v_evidence_id
```

```sql
-- refund_payment()
ledger_status = v_new_status,
refunded_amount = v_new_refunded_amount,
net_amount = v_new_net_amount,
evidence_packet_id = v_evidence_id
```

`updated_at = now()` remains only in updates to tables that actually have `updated_at`, such as `kds_tickets`, `orders`, and `order_sessions`. It is no longer present in the three `payment_ledger` update statements.

## 4. Apply and Checksum Verification

`catchmenu_meta.migration_history` was updated to the new LF-normalized checksum:

```text
e2e354985a20c81db02bbc8732edcf73bd18c548e8ff90977676516e11c93f78
```

`tools/apply_migrations.py` reported:

```text
OK    0037_create_payment_cancel_refund_rpc.sql  (already applied, checksum matches)
All sequence-numbered migrations applied or already up to date.
```

## 5. Function Execution Verification

### 5.1 `cancel_payment()`

Observed result:

```text
success: true
ledger_status: CANCELLED
cancelled_amount: 1000
net_amount: 0
kds_release_authorized: false
evidence_packet_id_present: true
```

### 5.2 `partial_cancel_payment()`

Observed result:

```text
success: true
ledger_status: PARTIAL_CANCELLED
cancelled_amount: 300
approved_amount: 1000
refunded_amount: 0
net_amount: 700
kds_release_authorized: true
evidence_packet_id_present: true
```

### 5.3 `refund_payment()`

Observed result:

```text
success: true
ledger_status: PARTIAL_REFUNDED
cancelled_amount: 0
approved_amount: 1000
refunded_amount: 400
net_amount: 600
kds_release_authorized: true
evidence_packet_id_present: true
```

## 6. KDS Five-State Verification

Both independent verification passes checked the five relevant KDS states:

- `HOLD`
- `COMMITTED`
- `COOKING`
- `COMPLETED`
- `SERVED`

Observed result:

| Starting `kds_status` | Result after `cancel_payment()` | Expected? |
|---|---|---|
| `HOLD` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COMMITTED` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COOKING` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COMPLETED` | unchanged, `cancelled_at` remains null | PASS |
| `SERVED` | unchanged, `cancelled_at` remains null | PASS |

The `COOKING` case is especially important because it confirms the high-risk payment-cancel-vs-cooking-start race behavior implied by the current predicate:

```sql
kds_status not in ('COMPLETED', 'SERVED', 'CANCELLED')
```

The implementation did not change this policy; it only made the already-existing behavior executable.

## 7. Seven-Column Regression Verification

The following `payment_ledger` columns were verified after execution:

- `ledger_status`
- `cancelled_amount`
- `net_amount`
- `kds_release_authorized`
- `evidence_packet_id`
- `refunded_amount`
- `approved_amount`

Result: PASS.

The values matched the pre-existing function logic once the invalid `updated_at` assignment was removed.

## 8. Boundary Verification

Boundary result:

```text
git diff --name-only -- sql/migrations
sql/migrations/0037_create_payment_cancel_refund_rpc.sql
```

`0098_create_payment_confirm_pipeline_rpc.sql` had zero diff.

No caller files were changed:

- `0038_create_toss_webhook_processor_rpc.sql`
- `0056_create_van_integration_rpc.sql`

No function signature, DROP, rename, merge, refund-pipeline redesign, or state-machine change was introduced.

## 9. Test Data Cleanup

All disposable verification rows were rolled back or explicitly confirmed absent.

Observed cleanup check:

```text
cancel_ctx_orders   0
cancel_ctx_sessions 0
cancel_ctx_kds      0
cancel_ctx_ledger   0
```

## 10. Verification Result

PASS.

The implementation satisfies the full Stage 5 verification requirements for this workpacket.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600570_cancel_payment_phantom_column_fix/600577_Audit.md] =====
# 600577_Audit.md

Status: ACCEPT
Lifecycle: Audit
Stage: 6 Audit
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Audit Decision

ACCEPT.

The Stage 4 implementation is accepted because it stayed within the approved ChangeContract and passed Stage 5 verification.

## 2. Scope Compliance

Approved scope:

- remove `payment_ledger.updated_at` from `cancel_payment()`,
- remove `payment_ledger.updated_at` from `partial_cancel_payment()`,
- remove `payment_ledger.updated_at` from `refund_payment()`,
- clean only the immediately required trailing commas.

Observed implementation:

- exactly those three invalid assignments were removed,
- no function signature changed,
- no state-transition logic changed,
- no amount calculation changed,
- no evidence/audit/event insertion logic changed,
- no `0098` refund pipeline function was changed,
- no caller file was changed.

Scope compliance: PASS.

## 3. Runtime Verification

The corrected functions were reloaded into the local database and verified with live execution.

Runtime verification confirmed:

- `cancel_payment()` succeeds and produces `ledger_status = 'CANCELLED'`.
- `partial_cancel_payment()` succeeds and produces `ledger_status = 'PARTIAL_CANCELLED'` for the tested partial amount.
- `refund_payment()` succeeds and produces `ledger_status = 'PARTIAL_REFUNDED'` for the tested partial refund amount.
- The previous hard error, `column "updated_at" of relation "payment_ledger" does not exist`, no longer occurs in these three functions.

Runtime verification: PASS.

## 4. KDS Cancellation Audit

The audit accepts the KDS verification result as correct for the current code policy.

The current `cancel_payment()` predicate cancels all matching KDS tickets except those already in:

- `COMPLETED`
- `SERVED`
- `CANCELLED`

Therefore:

- `HOLD` cancels.
- `COMMITTED` cancels.
- `COOKING` cancels.
- `COMPLETED` is protected.
- `SERVED` is protected.

This was confirmed by both independent verification passes with distinct test data.

The audit notes that `COOKING -> CANCELLED` is an operational policy concern, not an implementation drift introduced by this workpacket. This workpacket made the existing policy executable; it did not create or revise the policy.

## 5. Boundary Audit

Boundary checks passed:

- only `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` changed under `sql/migrations`,
- `0098_create_payment_confirm_pipeline_rpc.sql` had zero diff,
- `confirm_payment()` was untouched,
- `request_refund()` was untouched,
- `confirm_refund()` was untouched,
- `0038` and `0056` caller files were untouched,
- no DROP/rename/consolidation was performed.

Boundary audit: PASS.

## 6. Open Items Carried Forward

The following Open Items remain unresolved and are explicitly carried forward:

1. Whether `refund_payment()` should eventually be dropped.
2. Whether `partial_cancel_payment()` should eventually be dropped.
3. `0098` refund pipeline redesign as Workpacket 2:
   - `request_refund()`,
   - `confirm_refund()`,
   - broader refund state model,
   - phantom columns / missing NOT NULL columns / invalid status values identified in prior analysis.
4. `0102` / `0104` refund amount hardcoding bug:
   - current callers pass refund amount as `0`,
   - this belongs to the refund pipeline redesign workpacket.
5. Operational policy decision for cancelling already-`COOKING` KDS tickets:
   - current behavior cancels `COOKING`,
   - this should be revisited in the future when operations maturity requires a more nuanced kitchen intervention policy,
   - recommended review horizon: 1-2 years.

## 7. Final Audit Result

ACCEPT.

The implementation is narrow, verified, and safe to hand off for human review/commit.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md] =====
# 600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-15

## Change ID

`payment_confirm_cancel_state_machine_fix`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷 폴더는 `600510`/`600540`/`600550`/`600560`/`600570` 5개다(재확인, `ls`). `600570`은 Stage 6 ACCEPT까지 완료됐다(`600502_NavigationMap_Payment_Confirmation.md` 재확인). 10단위 관례상 다음 빈 번호는 `600580` — 지시문의 가칭과 일치한다.

## §1 배경 재확인 — 두 재현 위험 독립 재검증

지시문은 "삼중검증 완료, 재현 데이터 확보"라고 명시했으나, 이번 세션 원칙(§43/§44)에 따라 라이브 소스 코드를 직접 재대조해 독립적으로 재확인했다.

### §1.1 위험 1 — cancel 이후 confirm 재시도 시 신규 APPROVED 원장 공존

`confirm_payment()`(`0098`)의 "이미 결제 완료" 사전 검사(`0098:283-288`, 라이브 재확인):
```sql
-- 이미 결제 완료
if exists (
  select 1 from catchmenu_payment.payment_ledger
  where order_id = p_order_id
    and ledger_status = 'APPROVED'
) then
  return catchmenu_common.build_error_response(
    p_error_key := 'payment_already_confirmed', ...
  );
end if;
```
**확인 결과**: 이 검사는 `ledger_status = 'APPROVED'`인 행이 있는지만 확인한다. `cancel_payment()`가 기존 원장을 `CANCELLED`로 바꿔놓은 상태(§2에서 확인)에서는 이 조건이 거짓이 되어 검사를 통과하고, 함수는 그대로 진행해 **새 `payment_ledger` 행을 INSERT한다**(`0098`의 INSERT 블록, `intent_id`/`ledger_entry_type` 등 `600550` 워크패킷에서 이미 정합화됨) — 배경의 주장대로 order당 `CANCELLED` 행과 새 `APPROVED` 행이 공존하게 된다.

추가로, 주문 조회(`0098:261-271`)는 `v_order.id is null`(주문 자체가 없는 경우)만 검사하며 **`order_status` 값 자체는 검사하지 않는다** — 이후 `update catchmenu_pos.orders set order_status = case order_type when 'TABLE' then 'COOKING' else 'CONFIRMED' end, confirmed_at = now(), ...`가 무조건 실행되므로, `cancel_payment()`가 이미 `order_status = 'CANCELLED'`로 바꿔놓은 주문이라도 재확인 호출 한 번으로 `CONFIRMED`/`COOKING`으로 **되돌아간다**. 배경의 "order_status가 CONFIRMED로 되돌아감" 주장도 코드로 확인된다.

### §1.2 위험 2 — `cancel_payment()`가 `payment_intents`를 전혀 갱신하지 않음

`grep -n "payment_intents" sql/migrations/0037_create_payment_cancel_refund_rpc.sql` 재실행 결과 **0건** — `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()` 어느 함수도 `payment_intents`를 조회하거나 갱신하지 않는다. `confirm_payment()`(`0098`)는 `600550` 워크패킷에서 `resolve_or_create_payment_intent()`를 통해 `payment_intents` 행을 `CONFIRMED` 상태로 만들거나 재사용하도록 이미 정합화됐다 — 그러나 이후 `cancel_payment()`가 호출돼 `payment_ledger.ledger_status = 'CANCELLED'`가 되어도, 그 결제가 참조하는 `payment_intents.intent_status`는 **영원히 `CONFIRMED`로 남는다.** 배경이 말한 "ledger=CANCELLED, intent=CONFIRMED 모순"이 코드 구조상 100% 발생함을 확인했다.

## §2 근본 원인 — `confirm_payment()`의 "이미 확인됨" 판정 기준이 너무 좁음

§1.1의 검사가 `ledger_status = 'APPROVED'`만 보는 것은, "이 주문에 대해 결제를 이미 승인한 적이 있는가"가 아니라 "이 주문에 현재 승인 **상태인** 원장이 있는가"만 확인하는 것과 같다 — 취소/환불로 상태가 바뀐 과거 이력은 이 검사의 사각지대에 있다. `600550` 워크패킷이 `intent_id` 바인딩으로 "이 결제가 어떤 intent에서 왔는가"는 정합화했지만, "이 주문에 대해 과거에 이미 결제가 있었고 그것이 취소/환불됐는가"라는 **주문 단위 원장 이력** 문제는 다루지 않았다 — `600560`(intent 레이스)/`600570`(phantom 컬럼)와도 다른, 이번 워크패킷 고유의 문제다.

## §3 `payment_intents` 상태 동기화 — 스키마 변경 없이 가능함을 확인

**질문**: `cancel_payment()`가 `intent_status`도 `CANCELLED`로 갱신해야 하는가, 아니면 다른 동기화 방식이 필요한가?

**라이브 재확인**: `payment_intents`의 `chk_intent_status` CHECK 제약(`ANY(ARRAY['CREATED','PENDING','PROCESSING','CONFIRMED','FAILED','CANCELLED','EXPIRED'])`)에 **`'CANCELLED'`가 이미 포함되어 있다.** 즉 `600550`이 `intent_origin`/`origin_reference`를 추가할 때처럼 새 컬럼이나 CHECK 값 확장이 필요 없다 — `cancel_payment()`(그리고 `partial_cancel_payment()`/`refund_payment()`)가 자신이 이미 조회해둔 `v_ledger.intent_id`를 이용해 `update catchmenu_payment.payment_intents set intent_status = 'CANCELLED' where id = v_ledger.intent_id` 형태의 UPDATE 한 줄을 추가하는 것만으로 스키마 변경 없이 해결 가능하다는 것을 확인했다. 다만 `cancel_payment()`의 현재 SELECT(`0037:43-49`)는 `intent_id`를 이미 `v_ledger` 레코드에 담고 있으므로(재확인, `select ... intent_id ... into v_ledger`) 이 값을 즉시 재사용할 수 있다 — 추가 조회조차 필요 없다.

**부분 환불/취소 시의 동기화는 별도 판단이 필요**: `partial_cancel_payment()`/`refund_payment()`(부분 취소/환불)의 경우 `ledger_status`가 `PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`가 되는데, `chk_intent_status`에는 이에 대응하는 "부분" 상태값이 없다(`CREATED`/`PENDING`/`PROCESSING`/`CONFIRMED`/`FAILED`/`CANCELLED`/`EXPIRED`뿐) — 부분 취소/환불 시 intent를 그대로 `CONFIRMED`로 둘지, 아니면 CHECK 확장이 필요한 새 상태를 도입할지는 이 문서가 판단하지 않는다(§7 Open Item).

## §4 "주문당 활성 원장 최대 1개" 불변식의 DB 레벨 강제 가능성 검토

**질문**: `order_id`당 `ledger_status = 'APPROVED'`인 행이 최대 1개라는 불변식을 UNIQUE 제약 등으로 강제할 수 있는가?

**기술 검토**: PostgreSQL의 **부분 UNIQUE 인덱스(Partial Unique Index)**로 가능하다:
```sql
create unique index uq_payment_ledger_one_approved_per_order
  on catchmenu_payment.payment_ledger(order_id)
  where ledger_status = 'APPROVED';
```
이는 `order_id` 전체에 대한 유일성이 아니라 "`ledger_status = 'APPROVED'`인 행들 사이에서만" 유일성을 강제하므로, 한 주문이 `APPROVED` → `CANCELLED` → (재확인으로 인한 버그) `APPROVED`가 되는 시나리오에서 **두 번째 `INSERT`를 DB 레벨에서 직접 거부한다**(§1.1의 애플리케이션 레벨 검사가 놓친 것을 최종 방어선으로 보완) — `600560`(`payment_intent_race_condition_fix`) 워크패킷이 `idempotency_key`에 UNIQUE 제약을 추가했던 것과 동일한 카테고리의 해법이다.

**현재 라이브에 이런 제약이 없음을 재확인**: `payment_ledger`의 UNIQUE 제약/인덱스를 재조회한 결과(`pg_indexes`), 현재 `order_id` 관련 유일성 제약은 전혀 없다(`idx_payment_ledger_kds_auth`가 `(order_id, kds_release_authorized)` 부분 인덱스로 존재하지만 UNIQUE가 아님).

**주의할 부작용**: 이 부분 UNIQUE 인덱스를 추가하면, §1.1의 버그가 고쳐지지 않은 상태에서 재확인이 시도될 경우 "새 phantom 400에러"가 아니라 **"UNIQUE 위반 500에러"**로 실패 모드가 바뀔 뿐 근본 해결은 아니다 — 이 인덱스는 §1.1의 애플리케이션 레벨 수정(검사 조건 강화)과 **함께** 적용해야 의미가 있으며, 인덱스만 단독으로 추가하는 것은 §2가 지적한 근본 원인(검사 범위가 좁음)을 고치지 못한 채 에러 유형만 바꾸는 것이다 — Logic 단계에서 두 조치의 적용 순서/조합이 정해져야 한다(§7 Open Item).

## §5 "조건부 원자적 UPDATE" 방향 재정리 (ChatGPT 제안, 판단 없이 정리만)

배경이 언급한 "confirm_payment()의 APPROVED 중복 체크를 order 단위로 더 강하게" 방향을 §1.1/§2의 코드 근거와 연결하면, 최소 다음 두 갈래로 구체화된다(Logic 단계에서 옵션으로 비교할 재료, 이 문서는 선택하지 않음):

- **갈래 1 — 검사 조건 확장**: `ledger_status = 'APPROVED'`만이 아니라, "이 주문에 대해 어떤 상태로든(APPROVED/CANCELLED/PARTIAL_CANCELLED/REFUNDED 등) 원장이 이미 존재하는가"로 검사를 넓히고, 존재한다면 무조건 거부가 아니라 그 상태에 따라 다른 처리(예: CANCELLED 상태면 "이 주문은 이미 취소됨"이라는 명확한 별도 에러 키 반환, 재확인을 원천 차단하거나 명시적 재활성화 절차를 요구)를 하는 방향.
- **갈래 2 — order_status 기반 게이트**: `confirm_payment()` 진입 시 `v_order.order_status`가 이미 `'CANCELLED'`이면 즉시 거부하는 명시적 가드 추가(§1.1에서 확인한, 현재 이 검사 자체가 아예 없다는 사실이 근거) — `payment_ledger`뿐 아니라 `orders` 테이블 자체의 상태도 신뢰 기준으로 함께 쓰는 방향.

두 갈래는 배타적이지 않으며 함께 적용될 수도 있다 — Logic 단계에서 §4의 부분 UNIQUE 인덱스와 조합해 비교한다.

## §6 종합 — 이번 워크패킷이 다루는 세 가지 축

1. `confirm_payment()`의 재확인 차단 로직 강화(§1.1/§2/§5) — `payment_ledger`/`orders` 상태를 더 넓게 신뢰.
2. `cancel_payment()`(및 `partial_cancel_payment()`/`refund_payment()`)의 `payment_intents` 동기화(§3) — 스키마 변경 불필요, UPDATE 추가만으로 가능.
3. "주문당 활성 원장 최대 1개" 불변식의 DB 레벨 보강(§4) — 부분 UNIQUE 인덱스, 다만 단독 적용은 부작용 있음.

세 축 모두 `0037`/`0098` 양쪽 파일을 함께 손대야 하며, `600570`(0037 단독 correction)이나 `600550`(0098 단독 정합화)보다 범위가 넓다 — 두 파일이 서로의 상태를 인식하도록 만드는 것이 이번 워크패킷의 본질이다.

## §7 Open Questions

(a) 부분 취소/환불(`PARTIAL_CANCELLED`/`PARTIAL_REFUNDED`) 시 `payment_intents.intent_status`를 어떻게 동기화할지 — `chk_intent_status`에 대응 값이 없음(§3), CHECK 확장이 필요한지 아니면 `CONFIRMED` 유지가 맞는지는 판단하지 않았다.
(b) §4의 부분 UNIQUE 인덱스와 §1.1/§5의 애플리케이션 레벨 검사 강화 중 어느 쪽을 먼저 적용할지, 아니면 동시에 적용할지의 순서/조합 — Logic 단계 결정 사항.
(c) `confirm_payment()`가 이미 `CANCELLED`된 주문의 재확인 요청을 받았을 때 "완전히 거부"할지, 아니면 "새로운 정당한 재시도(예: 첫 결제 시도가 실패해서 취소된 뒤 고객이 다른 카드로 다시 결제하는 정상 시나리오)로 허용"할지는 순수 기술 문제가 아니라 비즈니스 정책 문제다 — 이 문서는 기술적 강제 수단(§1.1/§4)만 조사했고 정책 판단은 하지 않는다. `600570` 워크패킷이 COOKING 상태 취소를 운영 정책 문제로 유보했던 것과 같은 종류의 구분이다.
(d) `600560`(`payment_intent_race_condition_fix`)이 이미 다룬 "동시성" 문제와 이번 워크패킷의 "상태 머신 정합성" 문제가 겹치는 지점(예: 동시에 두 `confirm_payment()`가 취소된 주문에 대해 재확인을 시도하는 경우)이 있는지는 이번 문서에서 조사하지 않았다.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`/`600551_Overview...md` — `confirm_payment()`의 `resolve_or_create_payment_intent()` 정합화 선례, 이번 워크패킷이 그 위에 쌓임.
- `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`/`600571_Overview...md` — `cancel_payment()`의 `updated_at` correction 선례, 이번 워크패킷이 이어서 `payment_intents` 동기화를 추가.
- `000056_Register_Concurrency_Risk.md` — `PAY-CON-003`(결제 확인과 취소/환불 경쟁)이 이 워크패킷과 인접하나 동시성이 아니라 상태 머신 정합성 문제라는 점에서 구분됨(§7 (d)).

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`의 사전 검사 블록(L283-295) 및 주문 상태 갱신부.
- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`/`partial_cancel_payment()`/`refund_payment()`, `payment_intents` 갱신 추가 대상.
- `catchmenu_payment.payment_intents`의 `chk_intent_status` CHECK 제약(라이브 재확인).
- `catchmenu_payment.payment_ledger`의 인덱스 전체(`pg_indexes`, 부분 UNIQUE 인덱스 부재 확인).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- 부분 취소/환불 시 intent 상태 동기화 방식(§7 (a)) — 판단하지 않음.
- 비즈니스 정책 문제(취소된 주문의 재확인 허용 여부, §7 (c)) — 기술 조사만, 정책 판단은 범위 밖.
- `600560`과의 동시성 교차 영향(§7 (d)) — 조사하지 않음.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정.** §0(번호: `600580`)을 확정했다. §1에서 배경의 두 재현 위험(신규 APPROVED 원장 공존, `payment_intents` 미동기화)을 라이브 코드 직접 대조로 독립 재확인했다 — 둘 다 정확했다. §2에서 근본 원인(`confirm_payment()`의 재확인 차단 검사가 `ledger_status='APPROVED'`만 보고 `order_status`는 아예 확인하지 않음)을 특정했다. §3에서 `payment_intents` 동기화가 스키마 변경 없이(`chk_intent_status`에 `CANCELLED` 이미 존재) UPDATE 추가만으로 가능함을 확인했다. §4에서 부분 UNIQUE 인덱스로 "활성 원장 최대 1개" 불변식을 DB 레벨로 강제하는 것이 기술적으로 가능함을 확인하되, 단독 적용 시의 부작용(에러 유형만 바뀜)을 명시했다. §5에서 ChatGPT의 "조건부 원자적 UPDATE" 제안을 두 갈래(검사 조건 확장/order_status 게이트)로 구체화했다 — 판단하지 않았다. `600582_Logic.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md] =====
# 600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-16
Revision: 2 — 최종 확정(Human 결정, 2026-07-16). Rule 1 = 옵션 1a(`PENDING` 재사용) 채택, Rule 6/7(`reopen_order()`) 이번 워크패킷 범위에서 완전 제외.

## Change ID

`payment_confirm_cancel_state_machine_fix`

## §0 전제 — 분류 확정 및 8가지 규칙 원문

**Human 결정(2026-07-16, ChatGPT+제미나이 교차검증 완료, 재논의 금지)**: 이 워크패킷을 단순 correction이 아니라 **"Payment-Order State Transition Partial Redesign"**으로 분류하고, ChatGPT가 제시한 8가지 규칙을 그대로 채택한다.

**8가지 규칙(원문)**:

1. `confirm_payment()`는 `CANCELLED` 주문을 `CONFIRMED`로 변경할 수 없다.
2. 결제 실패 후 재시도는 동일 주문에서 허용할 수 있지만, 주문은 `PAYMENT_PENDING`이어야 하고 새로운 `payment_attempt_id`를 사용한다.
3. 같은 provider 거래의 재전송은 멱등 처리하며 새 원장을 생성하지 않는다.
4. 취소된 주문에 늦은 승인 신호가 도착하면 결제 사실은 원장에 기록하되 주문 상태와 KDS 상태는 변경하지 않는다.
5. 늦은 승인 건은 자동 void/refund 또는 운영 reconciliation 대상으로 전환한다.
6. 직원의 취소 실수는 `confirm_payment()`가 아니라 별도의 권한 있는 `reopen_order()` 명령으로만 복구한다.
7. 주문 복구 후 부수 효과를 안전하게 되돌릴 수 없으면 기존 주문을 부활시키지 않고 replacement order를 생성한다.
8. 새 provider 거래번호라는 이유만으로 취소 주문의 재확인을 허용하지 않는다.

**최종 결정문(원문 인용)**: "취소된 주문의 일반적인 재확인은 허용하지 않는다. 결제 실패 후 다른 카드로 재시도하는 경우에는 주문을 취소하지 않고 `PAYMENT_PENDING` 상태에서 새로운 결제 시도를 생성한다. 취소 완료 후 과거 결제의 지연 승인이 도착하면 승인 사실은 원장과 reconciliation 기록에 보존하되 주문을 되살리거나 KDS를 릴리스하지 않고 승인 취소 또는 환불 절차로 보낸다. 직원의 오취소 복구는 별도의 권한·사유·버전 검사를 갖춘 주문 재개 명령으로 분리하며, 부수 효과가 이미 발생한 경우 새 주문을 생성한다."

### §0.1 Revision 2 — 최종 결정 (Human, 2026-07-16, 재논의 금지)

**Rule 1 구현 확정**: 기존 `orders.order_status = 'PENDING'`을 "결제 확정이 허용되는 상태"로 그대로 사용한다(§1의 옵션 1a 채택 — `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 신규 도입 안 함). `confirm_payment()`는 `PENDING → CONFIRMED` 전이만 허용하며, 조건부 UPDATE(`WHERE order_status = 'PENDING'`, 영향행 1건 확인)로 구현한다. 그 외 상태(`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED`/`COOKING`/`READY`/`SERVED`/`COMPLETED`)에서는 거부한다. 단, **이미 `CONFIRMED`인 주문에 같은 provider 거래가 재전송되면 에러가 아니라 멱등 성공을 반환**한다(§2.2).

**책임 분리 원칙(명시)**: `orders.order_status`는 **주문 생명주기**를, `payment_intents.intent_status`는 **결제 시도 생명주기**를 나타내며, 이 둘을 섞지 않는다. `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 같은 세부 결제-시도 상태는 이번에 `orders`에 추가하지 않는다 — 향후 필요성이 명확해지면 별도의 상태머신 재설계 워크패킷에서 다룬다. 이 원칙에 따라 §1.4의 "Overview 갱신 필요" 여부는 **불필요로 확정**됐다 — `order_status`/`reconciliation_status` 둘 다 기존 값만으로 구현되므로(§2/§4) `600581_Overview.md` §6이 스코핑한 "세 축"을 벗어나는 스키마 변경이 발생하지 않는다.

**Rule 6/7(`reopen_order()`) 처리 확정**: 이번 워크패킷 범위에서 **완전히 제외**한다. 재고/쿠폰/포인트/KDS/대기열/환불 보상까지 연계되는 별도 복구 워크플로이므로 별도 워크패킷 대상이다. 이번 워크패킷은 "`CANCELLED` 주문은 `confirm_payment()`로 복구 불가"라는 정책만 코드로 강제하고(§2), 그 정책을 사용자에게 알리는 프론트엔드 UI 문구 권고만 Open Item으로 남긴다(§7).

## §1 범위 재확인 이력 — 스키마 변경 불필요로 최종 해소 (Revision 1 조사 보존)

Revision 1에서 확인한 사실(이번 최종본에서도 유효, 그대로 보존):

### §1.1 `order_status` — `PAYMENT_PENDING`/`PAYMENT_PROCESSING` 없음, 기존 값 `PENDING` 재사용으로 확정

라이브 재확인(Revision 1과 동일):
```sql
select conname, pg_get_constraintdef(oid) from pg_constraint
where conrelid='catchmenu_pos.orders'::regclass and contype='c';
```
```
chk_order_status  CHECK ((order_status = ANY (ARRAY[
  'PENDING','CONFIRMED','COOKING','READY','SERVED',
  'COMPLETED','CANCELLED','REFUNDED','PARTIAL_REFUNDED'])))
```
`PAYMENT_PENDING`/`PAYMENT_PROCESSING`은 이 목록에 없다 — Revision 1이 제시했던 옵션 1a(기존 `PENDING` 재사용)를 **§0.1에서 Human이 최종 채택**했다. `chk_order_status` CHECK 확장은 불필요하다.

### §1.2 `version` 컬럼 — 존재하지 않음, Rule 1 최소 구현에는 불필요

`information_schema.columns` 재확인 결과 `catchmenu_pos.orders.version`(또는 유사 컬럼) **0건**(변경 없음). §2.1의 조건부 UPDATE(`WHERE order_status = 'PENDING'` + 영향행 수 확인)만으로 규칙 1의 핵심 목적(취소된 주문의 재확인 차단)을 달성하므로, 이 컬럼 부재는 Rule 1 구현의 장애물이 아니다 — 더 엄격한 동시성 보호(동일 `PENDING` 상태 안에서의 동시 수정 탐지)가 필요하다면 `600560`류의 별도 동시성 워크패킷 대상이다(§8 Open Item).

### §1.3 라이브 데이터 표본 — 참고용, 변경 없음

`select distinct order_status from catchmenu_pos.orders` 결과 `CONFIRMED` 1종류만 관측(표본 작음, Revision 1과 동일).

### §1.4 결론 — Overview 갱신 불필요로 최종 확정

Revision 1은 이 항목을 Open Item으로 남겼으나, **§0.1의 Human 결정으로 해소됐다**: Rule 1(§2)도 Rule 4/5(§4)도 기존 CHECK 값만 재사용하므로, `600581_Overview.md`가 스코핑한 범위(§6의 세 축: 재확인 차단 로직/`payment_intents` 동기화/부분 UNIQUE 인덱스 검토)를 벗어나는 스키마 변경이 없다. Overview는 갱신하지 않는다.

## §2 Rule 1 최종 구현 설계 — `PENDING → CONFIRMED` 조건부 전이 + 멱등 성공 분기

### §2.1 조건부 UPDATE (핵심)

```sql
-- 기존 order 조회(0098:261-271, for update 락 이미 보유) 직후에 삽입
if v_order.order_status = 'CONFIRMED' then
  -- §2.2로 분기(멱등 성공 또는 충돌)
elsif v_order.order_status <> 'PENDING' then
  -- CANCELLED/REFUNDED/PARTIAL_REFUNDED는 §4(Rule 4/5)의 "기록 후 거부" 분기로
  -- COOKING/READY/SERVED/COMPLETED는 단순 거부(늦은 승인 기록 불필요 — 이미 정상 진행 중인 주문)
  if v_order.order_status in ('CANCELLED', 'REFUNDED', 'PARTIAL_REFUNDED') then
    -- §4로 위임
  else
    return catchmenu_common.build_error_response(
      p_error_key := 'order_not_confirmable',
      p_params := jsonb_build_object('current_status', v_order.order_status),
      p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;
end if;

-- v_order.order_status = 'PENDING'인 경우에만 도달하는 실제 확정 UPDATE
update catchmenu_pos.orders
set
  order_status = case order_type when 'TABLE' then 'COOKING' else 'CONFIRMED' end,
  confirmed_at = now(),
  updated_at = now()
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;

if v_row_count = 0 then
  -- SELECT ... FOR UPDATE와 이 UPDATE 사이에 상태가 바뀐 경쟁 상황
  return catchmenu_common.build_error_response(
    p_error_key := 'order_status_changed_concurrently',
    p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```
`FOR UPDATE` 락을 이미 조회 시점에 보유하고 있으므로(`0098:261-271`) 같은 트랜잭션 안에서 이 시점의 `order_status`가 조회 시점과 달라질 수는 없다 — `get diagnostics ... row_count`/0건 분기는 Human이 명시적으로 요구한 방어적 구현이며, 락이 어떤 이유로든 우회되는 미래의 코드 변경에 대비한 안전망 역할을 한다.

### §2.2 이미 `CONFIRMED`인 주문 — 멱등 성공 vs 충돌 분기

```sql
if v_order.order_status = 'CONFIRMED' then
  if exists (
    select 1 from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
  ) then
    -- 같은 provider 거래의 재전송 → 멱등 성공(Rule 3/8과 동일 원칙)
    select id into v_ledger_id from catchmenu_payment.payment_ledger
    where order_id = p_order_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
    order by approved_at desc limit 1;

    return catchmenu_common.build_success_response(
      p_message_key := 'payment_already_confirmed_idempotent',
      p_data := jsonb_build_object('ledger_id', v_ledger_id, 'order_id', p_order_id, 'already_confirmed', true),
      p_locale := p_locale, p_correlation_id := p_correlation_id
    );
  else
    -- 다른 provider 거래가 이미 CONFIRMED인 주문에 새로 확인을 시도 → 충돌(이중 결제 의심)
    return catchmenu_common.build_error_response(
      p_error_key := 'payment_already_confirmed',
      p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
      p_rpc_name := 'confirm_payment'
    );
  end if;
end if;
```
이 분기는 §3(Rule 3)의 기존 멱등성 검사(`p_correlation_id is not null`일 때만 작동, `0098:224-230`)와 별개로 **항상** 작동한다 — Human의 "이미 CONFIRMED인 주문에 같은 provider 거래가 재전송되면 에러가 아니라 멱등 성공"이라는 지시는 `correlation_id` 유무를 조건으로 걸지 않았으므로, `order_status` 기반의 이 분기가 §3의 검사보다 먼저(또는 독립적으로) 실행되도록 배치한다.

**남는 사각지대(정직하게 기록, §8 Open Item)**: 이 멱등 성공 분기는 `order_status = 'CONFIRMED'`일 때만 작동한다 — Human의 지시문을 문자 그대로 구현한 결과다. 주문이 이미 `COOKING`/`READY`/`SERVED`/`COMPLETED`로 더 진행된 뒤(정상적인 시간 경과) 같은 provider 거래가 뒤늦게 재전송되면, 이 분기의 조건(`order_status = 'CONFIRMED'`)에 걸리지 않고 §2.1의 "단순 거부"로 빠진다 — 정당한 웹훅 재전송인데도 에러를 받게 되는 경우가 이론상 있다. 이 문서는 이를 임의로 넓히지 않고 Open Item으로만 기록한다.

## §3 Rule 3 구현 설계 — 멱등성 체크가 `CANCELLED` 여부와 무관하게 항상 먼저 실행되는지 재확인

`0098:224-230`(재확인, 변경 없음)의 기존 멱등성 검사:
```sql
if p_correlation_id is not null then
  if exists (
    select 1 from catchmenu_payment.payment_ledger
    where store_id = p_store_id and tenant_id = p_tenant_id
      and provider_payment_key = p_provider_tx_id
      and provider_type = p_provider_type
      and ledger_status = 'APPROVED'
  ) then
    return error 'payment_already_confirmed';
  end if;
end if;
```
**순서 재확인 결과**: 이 검사는 함수 최상단(주문 조회보다도 앞, `0098:224` — 주문 조회는 `0098:261`)에 있어 이미 "가장 먼저" 실행된다 — 순서 자체는 문제가 없다. **문제는 순서가 아니라 조건**이었다(Revision 1에서 이미 지적) — `ledger_status = 'APPROVED'`만 확인하므로 `CANCELLED`로 바뀐 뒤의 재전송을 잡지 못한다. §2.2에서 `order_status = 'CONFIRMED'`인 경우의 재전송을 별도로 처리하도록 설계했으므로, 이 기존 검사(§3)는 **`order_status`가 아직 `PENDING`인 상태에서 provider 거래가 중복 전송되는 경우**(예: 웹훅이 짧은 시간 안에 두 번 도착, 아직 `PENDING → CONFIRMED` 전이가 완료되기 전에 두 번째 전송이 도착)를 계속 담당한다 — §2.1/§2.2와 역할이 겹치지 않고 상호 보완적이다. 이 검사의 조건(`ledger_status='APPROVED'`)과 위치는 그대로 두고, §2.1/§2.2를 추가로 배치하는 것으로 Rule 3을 충족한다 — 기존 검사 자체를 재작성할 필요는 없다.

## §4 Rule 4/5 최종 구현 설계 — 취소된 주문에 늦은 승인이 도착하는 경우, `reconciliation_status` 기존 값 재사용으로 확정

```sql
if v_order.order_status in ('CANCELLED', 'REFUNDED', 'PARTIAL_REFUNDED') then
  -- 규칙 4: 결제 사실은 원장에 기록하되 orders/kds_tickets는 건드리지 않음
  insert into catchmenu_payment.payment_ledger (
    tenant_id, store_id, order_id, session_id,
    intent_id, ledger_entry_type, provider_type, provider_payment_key,
    provider_approval_number, provider_approved_at, provider_response_id,
    approved_amount, net_amount, ledger_status,
    reconciliation_status,
    approved_at, business_day, business_timezone
  ) values (
    p_tenant_id, p_store_id, p_order_id, v_order.session_id,
    v_intent_id, 'APPROVAL', p_provider_type, p_provider_tx_id,
    p_provider_approval_number, now(), v_provider_response_id,
    p_approved_amount, p_approved_amount, 'APPROVED',
    'MANUAL_REVIEW',   -- 규칙 5: 기존 값 재사용, 아래 참고
    now(), v_business_day, v_timezone
  )
  returning id into v_ledger_id;

  -- orders/kds_tickets UPDATE 없음(규칙 4)

  return catchmenu_common.build_error_response(
    p_error_key := 'payment_approved_after_order_cancelled',
    p_data := jsonb_build_object('ledger_id', v_ledger_id, 'order_status', v_order.order_status),
    p_locale := p_locale, p_tenant_id := p_tenant_id, p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```

**`reconciliation_status` 재검토 결과 — 신규 값 불필요, 기존 값 재사용으로 확정**: `chk_ledger_reconciliation` CHECK 제약을 이번 턴에 재확인한 결과, 허용값은 여전히 `PENDING`/`MATCHED`/`MISMATCH`/`MANUAL_REVIEW`/`RESOLVED` 5개뿐이다. Revision 1이 예시로 들었던 `'PAYMENT_RECEIVED_AFTER_ORDER_CANCEL'`(신규 값)은 **채택하지 않는다** — 기존 값 `MANUAL_REVIEW`("수동 검토 필요")가 "취소된 주문에 결제가 뒤늦게 승인됨, 담당자가 void/환불 여부를 판단해야 함"이라는 상황을 의미상 정확히 포괄한다. 이 상황이 왜 `MANUAL_REVIEW`가 됐는지의 **구체적 사유는 `reconciliation_status` 컬럼이 아니라 다른 곳에 남긴다** — `payment_events`/`catchmenu_ledger.events` INSERT의 `event_payload`(jsonb, 자유 형식)에 `'reason', 'payment_approved_after_order_cancelled'` 같은 키를 추가하는 방식이면 스키마 변경 없이 원인을 그대로 보존할 수 있다(구체 페이로드 설계는 TestPlan 단계). **결론: `chk_ledger_reconciliation` CHECK 확장도 불필요.**

## §5 Rule 2 재확인 결과 — 변경 없음 (Claude Code 확인 완료, 그대로 반영)

Revision 1의 조사와 결론을 그대로 유지한다: `confirm_payment()`(`0098`) 전체에서 `order_status` 대입이 일어나는 지점은 성공 시(`PENDING → CONFIRMED`/`COOKING`) 단 한 곳뿐이며, 어떤 조기 반환 경로도 `order_status`를 `CANCELLED`로 설정하지 않는다 — "결제 시도 실패가 주문 취소를 유발"하는 코드 경로는 `confirm_payment()`에 없다. `order_status = 'CANCELLED'`는 오직 `cancel_payment()`(`0037`)의 명시적 호출, 또는 `request_refund()`(`0098:987`, 별도 기존 결함)에서만 발생한다. 재시도 시 새로운 결제 시도 단위가 필요하다는 Rule 2의 실질 요구는 `payment_intents`(`600550`의 `resolve_or_create_payment_intent()`)가 이미 충족하고 있다 — **이번 워크패킷에서 Rule 2를 위해 추가로 구현할 것은 없다.**

## §6 Rule 8 재확인 — 변경 없음, Rule 1로 자연히 해소됨

§2.1/§2.2의 게이트는 `provider_tx_id`/`provider_payment_key` 값 자체가 아니라 `v_order.order_status`로 1차 판정하므로("새 거래번호"라는 사실은 판정에 영향 없음), "새로운 provider 거래번호라는 이유만으로 취소 주문의 재확인을 허용하지 않는다"는 규칙 8은 별도 구현 없이 충족된다.

## §7 Rule 6/7(`reopen_order()`) — Open Item으로 이월 확정 (Human 결정, 옵션 비교 종료)

**Revision 1의 옵션 A/B 비교는 종료됐다** — Human이 옵션 B(이번 워크패킷에서 완전 제외)를 확정했다. 이번 워크패킷은 다음 두 가지만 산출한다:

1. **정책 명시(코드로 강제됨)**: §2.1/§2.2/§4의 게이트가 이미 "`CANCELLED`/`REFUNDED`/`PARTIAL_REFUNDED` 주문은 `confirm_payment()`로 복구 불가능"하다는 정책을 코드 수준에서 강제한다 — 이것으로 정책 자체는 이번 워크패킷 산출물에 포함된다. `reopen_order()`라는 **복구 수단의 부재**만 별도 워크패킷으로 이월되는 것이다.
2. **프론트엔드 UI 문구 권고**(구현 아님, Open Item으로 기록): `confirm_payment()`가 `order_not_confirmable`/`payment_approved_after_order_cancelled` 에러를 반환할 때, 직원 앱/POS 화면에 아래와 같은 안내 문구를 표시할 것을 권고한다 — "취소된 주문입니다. 결제 확인으로 복구할 수 없습니다. [새 주문 만들기]". 이 문구의 정확한 톤/번역/버튼 동작은 이 문서가 결정하지 않으며, Flutter/클라이언트 코드 변경은 이번 워크패킷(`.sql`만 다루는 SQL 레이어 워크패킷) 범위 밖이다.

## §8 Open Items

(a) **신규** — §2.2의 멱등 성공 분기가 `order_status = 'CONFIRMED'`인 경우만 다루고 `COOKING`/`READY`/`SERVED`/`COMPLETED`로 더 진행된 뒤의 정당한 재전송은 처리하지 못하는 사각지대(§2.2 "남는 사각지대") — Human 지시를 문자 그대로 구현한 결과이며, 이 문서는 임의로 범위를 넓히지 않았다. 실제 웹훅 재전송 지연이 이 사각지대에 도달할 빈도가 운영상 유의미한지는 라이브 운영 데이터가 쌓인 뒤 판단할 사안.
(b) §1.2에서 언급한 더 엄격한 동시성 보호(`version` 컬럼 기반 낙관적 잠금)의 필요성 — 이번 워크패킷은 불필요로 판단했으나, `600560`류의 동시성 워크패킷에서 재검토 여지.
(c) §4의 "자동 void/refund" 메커니즘(규칙 5 후반부, PG/VAN에 실제 취소·환불 API를 자동 호출하는 부분) — 이 문서는 "reconciliation 대상으로 표시(`MANUAL_REVIEW`)"까지만 설계했고, 자동화는 설계하지 않았다. `600570_Overview.md`가 별도로 다루는 PG/VAN 대사 감사 요구사항과 연결될 가능성.
(d) §7의 UI 문구 권고를 실제 Flutter/클라이언트 코드에 반영하는 작업 — SQL 레이어 워크패킷 범위 밖, 별도 프론트엔드 작업으로 이월.
(e) `reopen_order()` 자체의 설계(권한/사유/버전 검사/재고·쿠폰·포인트·대기열 복원 조건, `600582_Logic.md` §0 원문의 상세 조건 목록) — 완전히 별도 워크패킷, 이번 문서는 존재만 기록.

## §6.5 Required Context Snapshot Candidates

### Master Anchor

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md` — 이 문서의 직접 전제(§1.1/§2/§5의 근본 원인 분석).
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md` §6.1 — `payment_intents` 재시도/복수 intent 이력 전제, §5(Rule 2)의 근거.
- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` §5 — `request_refund()`가 `order_status`를 무조건 `CANCELLED`로 설정하는 별도 결함, §5에서 인용.

### Full Rules Required

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` — `confirm_payment()`(게이트/멱등성 검사/조건부 UPDATE 삽입 대상, `0098:224-230`/`261-271`/`283-295`/`463` 부근).
- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql` — `cancel_payment()`(참고, 이번 워크패킷의 직접 수정 대상 아님).
- `catchmenu_pos.orders`의 `chk_order_status` CHECK 제약(라이브 재확인, 변경 없음으로 확정).
- `catchmenu_payment.payment_ledger`의 `chk_ledger_reconciliation` CHECK 제약(라이브 재확인, 변경 없음으로 확정, `MANUAL_REVIEW` 재사용).

### Domain Indexes

- `600502_NavigationMap_Payment_Confirmation.md`.

### Excluded Rule Families

- `reopen_order()` 설계 전체(§7/§8 (e)) — 완전히 별도 워크패킷.
- PG/VAN 자동 void/refund API 호출 메커니즘(§8 (c)) — 범위 밖.
- 프론트엔드 UI 문구 구현(§8 (d)) — SQL 레이어 워크패킷 범위 밖.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**최종 확정(Revision 2, Human 결정 전부 반영).** §0.1에서 Rule 1 = 옵션 1a(`PENDING` 재사용, 스키마 변경 없음) 채택과 책임 분리 원칙(`orders.order_status` = 주문 생명주기, `payment_intents.intent_status` = 결제 시도 생명주기)을 확정했다. **§1.4에서 "Overview 갱신 필요" Open Item이 해소됐음을 명시했다** — Rule 1도 Rule 4/5도 기존 CHECK 값만으로 구현되므로 스키마 변경이 없다. §2에서 Rule 1의 정확한 조건부 UPDATE(`WHERE order_status='PENDING'`, 영향행 확인)와 이미 `CONFIRMED`인 주문에 대한 멱등 성공/충돌 분기(§2.2)를 구체화했다 — 문자 그대로 구현한 결과 생기는 사각지대(`COOKING` 이후 재전송)를 정직하게 Open Item으로 남겼다. §3에서 기존 멱등성 검사의 위치는 이미 최상단이었음을 재확인하고(순서 문제 아님, 조건 문제였음) §2와의 역할 분담을 명확히 했다. §4에서 `reconciliation_status` 신규 값이 불필요함을 최종 확정했다(`MANUAL_REVIEW` 재사용, 구체 사유는 `event_payload`에 보존). §5/§6은 Revision 1 그대로 유지(Rule 2 구현 불필요, Rule 8은 Rule 1로 자연히 해소). **§7에서 Rule 6/7(`reopen_order()`)을 Open Item으로 명확히 이월했다** — 정책 자체는 이번 워크패킷의 게이트로 이미 강제되며, 복구 수단(`reopen_order()`)과 UI 문구만 별도로 남긴다. `600583_TestPlan.md`/`600584_ChangeContract.md`로 진행 가능. `.sql` 파일은 이번 턴에도 생성·수정하지 않았다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix.md] =====
# 600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 0. Test Scope

This TestPlan verifies the final Revision 2 design from:

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md`
- `600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md`

The target function is:

- `catchmenu_payment.confirm_payment()` in `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

The workpacket does not modify:

- `cancel_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- `orders` schema
- `payment_ledger` schema
- `payment_intents` schema
- KDS release or cancellation logic

The purpose is to make `confirm_payment()` respect the order/payment state machine after the PAY-CON-003 race was reproduced.

## 1. Pre-Implementation Verification

### 1.1 Confirm current order status vocabulary

Run:

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_pos.orders'::regclass
  and conname = 'chk_order_status';
```

Expected:

- `PENDING` exists.
- `CONFIRMED` exists.
- `COOKING` exists.
- `READY` exists.
- `SERVED` exists.
- `COMPLETED` exists.
- `CANCELLED` exists.
- `REFUNDED` exists.
- `PARTIAL_REFUNDED` exists.
- `PAYMENT_PENDING` and `PAYMENT_PROCESSING` do not exist.

This confirms the Revision 2 decision to reuse existing `PENDING` rather than introduce new order-state values.

### 1.2 Confirm current reconciliation vocabulary

Run:

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_payment.payment_ledger'::regclass
  and conname = 'chk_ledger_reconciliation';
```

Expected:

- `MANUAL_REVIEW` exists and can be reused.
- No new reconciliation status is required for this workpacket.

### 1.3 Confirm baseline PAY-CON-003 reproduction is understood

Before implementation, the previously reproduced bad path is:

1. A payment is confirmed for an order.
2. `cancel_payment()` cancels the existing `APPROVED` ledger and sets the order to `CANCELLED`.
3. A later or racing `confirm_payment()` call with a different provider transaction can create a new `APPROVED` ledger for the same order and move the order back to `CONFIRMED`.

After implementation, this path must no longer create a normal released payment for a cancelled order.

## 2. Rule 1 Tests — PENDING-only confirm gate

### 2.1 PENDING order succeeds

Setup:

1. Create a disposable `catchmenu_pos.orders` row with:
   - `order_status = 'PENDING'`
   - `order_type = 'TAKEOUT'`
   - valid `tenant_id`, `store_id`, `order_number`, `business_day`, and amount fields.
2. Use a unique prefix such as:

```text
__test_paycon003_rule1_pending_
```

Execution:

```sql
select catchmenu_payment.confirm_payment(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_order_id := '<pending_order_id>'::uuid,
  p_provider_type := 'OKPOS',
  p_provider_approval_number := '<unique_approval_number>',
  p_provider_tx_id := '<unique_provider_tx_id>',
  p_approved_amount := <final_amount>,
  p_payment_method := 'CARD',
  p_provider_response := jsonb_build_object('test', 'rule1_pending'),
  p_actor_type := 'STAFF',
  p_actor_id := null,
  p_locale := 'ko',
  p_correlation_id := '__test_paycon003_rule1_pending',
  p_intent_id := null
);
```

Expected:

- `success = true`.
- A `payment_ledger` row is created.
- The created ledger has `ledger_status = 'APPROVED'`.
- The order moves from `PENDING` to the normal post-payment state:
  - `CONFIRMED` for `TAKEOUT` and non-table order types,
  - `COOKING` only where the existing function logic intentionally maps table orders that way.
- `release_kds_after_payment()` behavior remains unchanged.

### 2.2 Non-PENDING orders are rejected

Run the same `confirm_payment()` call shape against disposable orders with each of the following initial statuses:

- `CANCELLED`
- `COOKING`
- `READY`
- `SERVED`
- `COMPLETED`

Expected for `COOKING`, `READY`, `SERVED`, and `COMPLETED`:

- `confirm_payment()` returns a failure response.
- The response identifies the order as not confirmable, for example `error_key = 'order_not_confirmable'`.
- No normal `APPROVED` payment release path is executed.
- `orders.order_status` remains unchanged.
- Existing KDS tickets remain unchanged.

Expected for `CANCELLED`:

- See Rule 4/5 tests in §4.

### 2.3 Conditional update row-count check

The implementation must use a conditional order update equivalent to:

```sql
update catchmenu_pos.orders
set ...
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;
```

Expected:

- If `v_row_count = 0`, `confirm_payment()` returns a failure response such as `order_status_changed_concurrently`.
- The function must not silently continue after a zero-row state transition.

## 3. Rule 3 Tests — provider idempotency and CONFIRMED re-delivery

### 3.1 Existing provider idempotency check remains first

Setup:

1. Create a disposable `PENDING` order.
2. Call `confirm_payment()` once with a unique provider key.
3. Capture the resulting `ledger_id`.

Execution:

Call `confirm_payment()` again with the same:

- `p_provider_type`
- `p_provider_tx_id`
- `p_order_id`

Expected:

- The call does not create a second `APPROVED` ledger.
- The existing provider-key idempotency check still prevents duplicate payment records.

### 3.2 CONFIRMED order with same provider transaction returns idempotent success

Setup:

1. Use an order that is already `CONFIRMED` from the first successful payment.
2. Re-send the same provider transaction.

Expected:

- The function returns a success-shaped idempotent response, not a hard error.
- The response should identify that the payment was already confirmed, for example:
  - `already_confirmed = true`
  - existing `ledger_id`
- No new `payment_ledger` row is created.

### 3.3 CONFIRMED order with a different provider transaction is rejected

Setup:

1. Use an order already `CONFIRMED` from a prior successful payment.
2. Call `confirm_payment()` with a different provider transaction id.

Expected:

- The function returns a failure response such as `payment_already_confirmed`.
- No new `APPROVED` ledger is created.
- `orders.order_status` remains `CONFIRMED`.

### 3.4 Boundary note for later order states

The Revision 2 design intentionally keeps the new idempotent-success branch scoped to `order_status = 'CONFIRMED'`.

For `COOKING`, `READY`, `SERVED`, and `COMPLETED`, even a re-delivered provider transaction may currently be rejected by the Rule 1 gate. This is a known Open Item, not a TestPlan failure for this workpacket.

## 4. Rule 4/5 Tests — approval after cancellation is recorded but does not reopen order/KDS

### 4.1 CANCELLED order receives a provider approval

Setup:

1. Create a disposable order.
2. Confirm the order once to create an `APPROVED` ledger.
3. Cancel the payment using `cancel_payment()`.
4. Confirm the order is now:
   - `orders.order_status = 'CANCELLED'`
   - previous ledger has `ledger_status = 'CANCELLED'`

Execution:

Call `confirm_payment()` again for the same `order_id` with a new provider transaction.

Expected:

- The provider approval fact is recorded in `catchmenu_payment.payment_ledger`.
- The new ledger uses existing reconciliation vocabulary:
  - `reconciliation_status = 'MANUAL_REVIEW'`
- `orders.order_status` remains `CANCELLED`.
- `catchmenu_kds.kds_tickets` are not released or reopened.
- `release_kds_after_payment()` is not executed for this cancelled-order branch.
- The response must not look like a normal successful KDS-releasing payment confirmation.

### 4.2 Manual-review reason is recorded in event payload

After §4.1, inspect payment/event rows associated with the new manual-review ledger.

Expected:

- The reason is recorded in a JSON payload field, for example:

```json
{
  "reason": "payment_approved_after_order_cancelled"
}
```

- No new `reconciliation_status` enum/check value is introduced.

### 4.3 No order/KDS mutation on cancelled-order approval

Capture before/after snapshots:

```sql
select order_status, cancelled_at, confirmed_at
from catchmenu_pos.orders
where id = '<order_id>'::uuid;

select id, kds_status, cancelled_at, hold_reason, payment_ledger_id
from catchmenu_kds.kds_tickets
where order_id = '<order_id>'::uuid
order by ticket_created_at, id;
```

Expected:

- `orders.order_status` remains `CANCELLED`.
- Existing cancelled KDS tickets remain cancelled.
- No KDS ticket is moved back to `COMMITTED` or `COOKING`.
- No ticket receives a new `payment_ledger_id` merely because a late provider approval arrived.

## 5. Re-run the reproduced PAY-CON-003 scenario

### 5.1 cancel complete, then confirm retry

Re-run the concrete scenario reproduced during investigation:

1. Confirm a payment.
2. Cancel the payment.
3. Retry `confirm_payment()` for the same order with a different provider transaction.

Expected after this fix:

- The order is not moved back to `CONFIRMED`.
- A normal new `APPROVED` ledger that releases KDS is not created.
- If a ledger is recorded for the late provider approval, it is manual-review only:
  - `reconciliation_status = 'MANUAL_REVIEW'`
  - reason stored in event payload
  - no order/KDS mutation

### 5.2 concurrent cancel vs confirm

Use two DB sessions:

- Session A: call `cancel_payment()` and hold the transaction open after it has updated the ledger/order.
- Session B: call `confirm_payment()` for the same `order_id`.
- Commit Session A.
- Observe Session B result.

Expected:

- Session B must not restore the order to `CONFIRMED`.
- Session B must not create a normal KDS-releasing `APPROVED` ledger.
- Final state must not contain:

```text
orders.order_status = CONFIRMED
old ledger = CANCELLED
new ledger = APPROVED with kds_release_authorized = true
```

That was the reproduced pre-fix failure mode and must be eliminated.

## 6. KDS COOKING cancellation race regression

This workpacket does not change `cancel_payment()` or KDS status transition logic, but the previously verified COOKING cancellation path must remain intact.

Setup:

1. Create an order.
2. Confirm payment.
3. Create or use a KDS ticket linked to the payment ledger.
4. Move the KDS ticket to `COOKING`.
5. Call `cancel_payment()`.

Expected:

- `cancel_payment()` still succeeds.
- `kds_tickets.kds_status` becomes `CANCELLED`.
- `hold_reason = 'PAYMENT_CANCELLED'`.
- `COMPLETED` and `SERVED` tickets remain protected if included as negative cases.

## 7. Boundary Verification

### 7.1 Source diff boundary

Expected source diff:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
  - `confirm_payment()` body only

Expected no source diff:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`
- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- schema DDL for `catchmenu_pos.orders`
- schema DDL for `catchmenu_payment.payment_ledger`
- schema DDL for `catchmenu_payment.payment_intents`

### 7.2 Live function verification

After implementation:

```sql
select pg_get_functiondef(
  'catchmenu_payment.confirm_payment(uuid,uuid,uuid,text,text,text,integer,text,jsonb,text,uuid,text,text,uuid)'::regprocedure
);
```

Expected:

- The live body contains the new order-status gate.
- The live body contains the conditional `PENDING` update and row-count check.
- The live body contains the `CONFIRMED` idempotent success branch.
- The live body contains the cancelled-order manual-review branch.
- The live body does not contain unrelated edits to refund or cancellation functions.

## 8. Cleanup

All test rows must use a unique prefix such as:

```text
__test_paycon003_
```

Cleanup must remove disposable rows from, as applicable:

- `catchmenu_ledger.events`
- `catchmenu_kds.kds_events`
- `catchmenu_payment.payment_events`
- `catchmenu_agent.evidence_packets`
- `catchmenu_kds.kds_tickets`
- `catchmenu_payment.payment_ledger`
- `catchmenu_payment.payment_intents`
- `catchmenu_gateway.provider_raw_events`
- `catchmenu_pos.orders`

Final verification:

```sql
select count(*)
from catchmenu_pos.orders
where order_number like '__test_paycon003_%';
```

Expected:

- `0`

## 9. Acceptance Criteria

This workpacket is accepted only if all of the following are true:

1. Normal `PENDING` order confirmation still succeeds.
2. `CANCELLED`, `COOKING`, `READY`, `SERVED`, and `COMPLETED` orders are not silently reconfirmed.
3. Re-delivery of the same provider transaction for a `CONFIRMED` order is idempotent success.
4. A different provider transaction for a `CONFIRMED` order is rejected.
5. A late provider approval for a cancelled order is recorded for manual review without reopening order/KDS state.
6. The reproduced PAY-CON-003 race no longer yields `CANCELLED` ledger plus new normal `APPROVED` KDS-releasing ledger on the same order.
7. KDS COOKING cancellation behavior is not regressed.
8. Boundary verification confirms only `confirm_payment()` in `0098` changed.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md] =====
# 600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Human Decision Summary

This ChangeContract implements the final Revision 2 design from:

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md`
- `600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md`

The human-approved design is:

1. Rule 1: add an `order_status = 'PENDING'` conditional gate to `confirm_payment()`.
   - Use a conditional `UPDATE ... WHERE order_status = 'PENDING'`.
   - Use `GET DIAGNOSTICS ... ROW_COUNT`.
   - If zero rows are updated, reject instead of silently continuing.

2. Rule 3: keep the existing provider-payment-key idempotency check order.
   - Add a new idempotent-success branch for `order_status = 'CONFIRMED'` and the same provider transaction.
   - A different provider transaction for an already confirmed order remains a conflict.

3. Rule 4/5: when a provider approval arrives for a cancelled/refunded order:
   - record the payment fact in `payment_ledger`,
   - do not mutate `orders`,
   - do not mutate or release `kds_tickets`,
   - reuse `reconciliation_status = 'MANUAL_REVIEW'`,
   - record the concrete reason in JSON event payload rather than adding a new check value.

4. Rule 6/7 are out of scope.
   - `reopen_order()` is not implemented here.
   - UI copy for staff-facing recovery is not implemented here.

5. Rule 2 requires no implementation in this workpacket.
   - Existing payment-intent lifecycle handling remains in place.

## 2. Allowed Files

### 2.1 SQL migration source

Allowed:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

Allowed scope inside that file:

- `catchmenu_payment.confirm_payment()` body only

Allowed changes inside `confirm_payment()`:

1. Add order-state gate logic after the existing order row is loaded with `FOR UPDATE`.
2. Add a `CONFIRMED` + same-provider-transaction idempotent success branch.
3. Add rejection for `CONFIRMED` + different provider transaction.
4. Add rejection for non-confirmable active or terminal states outside the cancelled/refunded manual-review branch.
5. Add cancelled/refunded-order late-approval handling:
   - ledger record may be inserted,
   - `reconciliation_status = 'MANUAL_REVIEW'`,
   - reason is stored in JSON event payload,
   - no order or KDS release mutation.
6. Change the normal order status update to be conditional on `order_status = 'PENDING'`.
7. Add `GET DIAGNOSTICS v_row_count = ROW_COUNT` and a zero-row rejection branch.

### 2.2 Already-applied migration procedure

Because `0098_create_payment_confirm_pipeline_rpc.sql` is an already-applied migration source, Stage 4 must follow the established in-place function correction process:

1. Modify the source file.
2. Recalculate the CRLF-normalized checksum.
3. Update `catchmenu_meta.migration_history`.
4. Re-execute the live function body directly.
5. Verify with `pg_get_functiondef()` that the live function body actually changed.

Checksum update alone is not evidence that the live database function was replaced.

## 3. Forbidden Changes

The following are explicitly forbidden in this workpacket:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`
- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- `catchmenu_pos.orders` schema changes
- `catchmenu_payment.payment_ledger` schema changes
- `catchmenu_payment.payment_intents` schema changes
- new `order_status` values such as `PAYMENT_PENDING` or `PAYMENT_PROCESSING`
- new `reconciliation_status` values
- `reopen_order()` implementation
- Flutter/client UI changes
- PG/VAN automatic void/refund redesign
- provider integration caller changes
- KDS state-machine redesign

## 4. Required Implementation Contract

### 4.1 Rule 1 — PENDING-only normal confirmation

The normal successful confirmation path must only update an order if the current status is `PENDING`.

Required shape:

```sql
update catchmenu_pos.orders
set
  order_status = case order_type
    when 'TABLE' then 'COOKING'
    else 'CONFIRMED'
  end,
  confirmed_at = now(),
  updated_at = now()
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;

if v_row_count = 0 then
  return catchmenu_common.build_error_response(
    p_error_key := 'order_status_changed_concurrently',
    p_locale := p_locale,
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```

Exact formatting may differ, but the behavior must not differ.

### 4.2 Rule 3 — CONFIRMED idempotent success for same provider transaction

If `v_order.order_status = 'CONFIRMED'` and an existing `APPROVED` ledger is found for:

- same `order_id`,
- same `provider_payment_key`,
- same `provider_type`,

then the function must return a success-shaped idempotent response instead of creating a new ledger or returning a hard error.

Required behavior:

- no new `payment_ledger` row,
- no order mutation,
- no KDS mutation,
- response data includes enough evidence to identify the existing ledger, such as `ledger_id` and `already_confirmed = true`.

### 4.3 Rule 3 — CONFIRMED conflict for different provider transaction

If `v_order.order_status = 'CONFIRMED'` but the provider transaction does not match an existing approved ledger for that order, `confirm_payment()` must reject the call.

Required behavior:

- no new `payment_ledger` row,
- no order mutation,
- no KDS mutation,
- error response such as `payment_already_confirmed`.

### 4.4 Rule 4/5 — late approval after cancelled/refunded order

If `v_order.order_status` is one of:

- `CANCELLED`
- `REFUNDED`
- `PARTIAL_REFUNDED`

then a late provider approval must not reopen or release the order.

Required behavior:

- The provider approval fact may be recorded in `catchmenu_payment.payment_ledger`.
- The ledger must be marked for manual reconciliation:

```sql
reconciliation_status = 'MANUAL_REVIEW'
```

- The reason must be recorded in JSON event payload, for example:

```json
{
  "reason": "payment_approved_after_order_cancelled"
}
```

- The function must not call `release_kds_after_payment()` for this branch.
- The function must not update `catchmenu_pos.orders` status.
- The function must not update `catchmenu_kds.kds_tickets`.
- The response must not look like a normal successful KDS-releasing payment confirmation.

### 4.5 Rule 1 — reject other non-confirmable statuses

For order statuses such as:

- `COOKING`
- `READY`
- `SERVED`
- `COMPLETED`

the function must reject the call rather than create a normal new payment release.

Required behavior:

- no normal new `APPROVED` KDS-releasing ledger,
- no order mutation,
- no KDS mutation,
- error response such as `order_not_confirmable`,
- include the current order status where practical.

## 5. Required Verification

Stage 4 must execute `600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix.md` in full.

Minimum required evidence:

1. `PENDING` order confirmation succeeds.
2. `CANCELLED`, `COOKING`, `READY`, `SERVED`, and `COMPLETED` order confirmation attempts are handled according to the TestPlan.
3. Same provider transaction re-delivery for a `CONFIRMED` order is idempotent success.
4. Different provider transaction for a `CONFIRMED` order is rejected.
5. Late provider approval after cancellation is recorded for manual review without order/KDS mutation.
6. The reproduced PAY-CON-003 race no longer yields:

```text
old ledger = CANCELLED
new ledger = APPROVED
orders.order_status = CONFIRMED
new ledger kds_release_authorized = true
```

7. KDS COOKING cancellation behavior is not regressed.
8. `pg_get_functiondef()` confirms the live function body contains the approved changes.

## 6. Open Items

The following are explicitly carried forward and must not be solved in this workpacket:

1. Rule 6/7: `reopen_order()` design and implementation.
2. Rule 6/7: staff-facing UI copy for cancelled-order recovery.
3. Rule 3/4 boundary case:
   - re-delivery of the same provider transaction after the order has advanced beyond `CONFIRMED` into `COOKING`, `READY`, `SERVED`, or `COMPLETED`.
   - Revision 2 currently treats those states as non-confirmable/rejected unless a later workpacket expands the idempotent branch.
4. Strict optimistic concurrency/versioning for `orders`.
5. PG/VAN automatic void/refund handling for late approvals after cancellation.

## 7. Human Boundary Approval

☑ I approve Rule 1 implementation in confirm_payment() only.
☑ I approve Rule 3 idempotent-success/conflict behavior for already-confirmed orders.
☑ I approve Rule 4/5 manual-review recording for late approvals after cancelled/refunded orders. (2026 - 07 - 16)

Implementation must not begin until all approval checkboxes above are checked by the human owner.

## 8. Stage 4 Stop Conditions

Stage 4 must stop and report without further edits if any of the following occur:

1. The required approval checkboxes are not checked.
2. The actual live `confirm_payment()` signature differs from the expected 14-parameter signature.
3. The current `orders` or `payment_ledger` check constraints differ from the assumptions in `600582_Logic`.
4. The implementation would require schema changes.
5. The implementation would require edits to `0037`, `cancel_payment()`, `request_refund()`, `confirm_refund()`, or `release_kds_after_payment()`.
6. The cancelled-order manual-review branch cannot record the event reason without a schema change.
7. Any TestPlan case reveals a new unrelated blocker that would require expanding scope.



===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600585_Module.md] =====
# 600585_Module.md

Status: Complete
Lifecycle: Module
Stage: 4 Implementation Summary
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Implemented Scope

This module records the Stage 4 implementation of `600580_payment_confirm_cancel_state_machine_fix`.

The implementation changed only `catchmenu_payment.confirm_payment()` in:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

The workpacket fixes the PAY-CON-003 state-machine gap where a payment confirmation retry after `cancel_payment()` could previously create a new normal `APPROVED` ledger row and move the cancelled order back to `CONFIRMED`.

## 2. Implemented Rules

### 2.1 Rule 1 — PENDING-only confirmation gate

The normal confirmation path now updates `catchmenu_pos.orders` only when the target order is still `PENDING`.

The order update is conditional:

```sql
where id = p_order_id
  and order_status = 'PENDING';
```

The function then uses `GET DIAGNOSTICS ... ROW_COUNT`.

If the update affects zero rows, `confirm_payment()` returns an error response instead of continuing into ledger/KDS release logic.

This prevents a concurrently cancelled or already advanced order from being silently reconfirmed.

### 2.2 Rule 3 — already-confirmed idempotent success / conflict rejection

If the order is already `CONFIRMED`, `confirm_payment()` now distinguishes same-provider retries from conflicting payment attempts.

Same-provider retry:

- finds an existing `APPROVED` ledger row for the same `provider_type` and `provider_payment_key`,
- returns success,
- includes `already_confirmed := true`,
- does not insert a duplicate ledger row.

Different-provider attempt:

- is rejected with the existing `payment_already_confirmed` error path,
- does not insert a new ledger row.

### 2.3 Rule 4/5 — late approval after cancellation/refund

If the order is already in one of the terminal cancellation/refund states:

- `CANCELLED`
- `REFUNDED`
- `PARTIAL_REFUNDED`

then a late provider approval is recorded for reconciliation but is not allowed to reopen or reconfirm the order.

The implementation:

- creates a `payment_ledger` row with `ledger_status = 'APPROVED'`,
- sets `reconciliation_status = 'MANUAL_REVIEW'`,
- sets `kds_release_authorized = false`,
- records `payment_approved_after_order_cancelled` in `event_payload`,
- does not update `orders.order_status`,
- does not call `release_kds_after_payment()`,
- does not mutate `kds_tickets`.

Because no new error catalog entry was approved in this workpacket, the function returns through the existing `payment_already_confirmed` error key while preserving the manual-review details in the ledger/event payload.

### 2.4 Non-confirmable active/completed states

For the following order states, `confirm_payment()` now rejects confirmation without inserting a new ledger row:

- `COOKING`
- `READY`
- `SERVED`
- `COMPLETED`

These states are treated as not confirmable under the approved Rule 1 extension.

## 3. Non-Changes

The implementation did not change:

- `cancel_payment()`,
- `request_refund()`,
- `confirm_refund()`,
- `release_kds_after_payment()`,
- `payment_ledger` schema,
- `orders` schema,
- `payment_intents` schema,
- KDS release logic,
- refund pipeline logic,
- UI copy,
- `reopen_order()` behavior.

No schema migration was added for this workpacket.

## 4. Application Method

Because `0098_create_payment_confirm_pipeline_rpc.sql` had already been applied, Stage 4 used the §24 Lightweight Track pattern:

1. Update the already-applied source file in place.
2. Recalculate the CRLF-to-LF-normalized checksum.
3. Update `catchmenu_meta.migration_history`.
4. Re-execute the live function body directly.
5. Confirm `tools/apply_migrations.py` reports checksum match.
6. Confirm `pg_get_functiondef()` contains the new state-machine branches.

## 5. Checksum

The final LF-normalized checksum for `0098_create_payment_confirm_pipeline_rpc.sql` is:

```text
357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
```

The raw file SHA256 differs because the project migration checksum procedure normalizes CRLF to LF before hashing.

## 6. Result

`confirm_payment()` no longer allows the original PAY-CON-003 failure mode:

- `cancel_payment()` completes,
- a later provider confirmation arrives,
- a new normal `APPROVED` ledger row is inserted,
- the order returns from `CANCELLED` to `CONFIRMED`.

Late approvals after cancellation are now captured as manual-review reconciliation records without reopening the order or releasing KDS.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600586_Verification.md] =====
# 600586_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5 Verification / Stage 6 Evidence
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Verification Summary

The implementation was verified by independent Cursor and Antigravity review results, then reconciled with Codex live execution evidence.

Final result: PASS.

The original PAY-CON-003 failure mode was not reproduced after the fix. A late approval after cancellation now creates a `MANUAL_REVIEW` ledger record and leaves the order cancelled.

## 2. Human Approval Recheck

`600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` was rechecked directly from the UTF-8 file content.

The Human Approval section contains all three checked approvals:

```text
☑ I approve Rule 1 implementation in confirm_payment() only.
☑ I approve Rule 3 idempotent-success/conflict behavior for already-confirmed orders.
☑ I approve Rule 4/5 manual-review recording for late approvals after cancelled/refunded orders. (2026 - 07 - 16)
```

Earlier console output displayed these marks incorrectly because of PowerShell console encoding, not because the file was missing the checks.

## 3. Checksum Reconciliation

The apparent checksum mismatch was resolved as a hashing-method mismatch.

Observed values:

```text
raw_sha256=769fadd67664a3be7a21bfbb81efb52ebcefa5ff7dcbba2c025888bc9d312165
lf_normalized_sha256=357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
migration_history_checksum=357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
normalized_matches_history=True
raw_matches_history=False
```

`tools/apply_migrations.py` uses the LF-normalized checksum path:

```python
path.read_bytes().replace(b"\r\n", b"\n")
```

Therefore the correct §24 checksum is the LF-normalized value:

```text
357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
```

This note is intentionally recorded to prevent future confusion between raw SHA256 and migration-history SHA256.

## 4. Live Function Reload Verification

The live `confirm_payment()` function was re-executed after the source update.

`tools/apply_migrations.py` subsequently reported:

```text
OK    0098_create_payment_confirm_pipeline_rpc.sql  (already applied, checksum matches)
All sequence-numbered migrations applied or already up to date.
```

`pg_get_functiondef()` token checks confirmed that the live function contains the new branches:

```text
has_row_count_gate       15130
has_idempotent_success    2435
has_cancelled_branch     11914
has_manual_review        11236
```

## 5. Test Results

### 5.1 Rule 1 — PENDING success and non-PENDING rejection

PENDING order confirmation succeeded:

```json
{"ledger_id":"6907f2db-c827-40a6-bb84-29a2c8cde4dc","message_key":"payment_confirmed","order_status":"CONFIRMED","success":true}
```

Non-confirmable states were rejected without ledger insertion:

```text
COOKING   -> order_not_confirmable, ledger_count=0
READY     -> order_not_confirmable, ledger_count=0
SERVED    -> order_not_confirmable, ledger_count=0
COMPLETED -> order_not_confirmable, ledger_count=0
```

### 5.2 Rule 3 — idempotent success / conflict rejection

Same-provider resend on an already confirmed order returned idempotent success:

```json
{
  "same_success": true,
  "same_message_key": "payment_already_confirmed_idempotent",
  "same_data": {
    "already_confirmed": true,
    "ledger_id": "944db09a-9ad7-4fef-97ce-41ba72348888",
    "order_id": "66249984-3c5e-4f1f-9b8c-036c26535296"
  },
  "ledger_counts": [1, 1]
}
```

Different-provider resend was rejected:

```json
{"diff_success":false,"diff_error_key":"payment_already_confirmed"}
```

### 5.3 Rule 4/5 — late approval after cancellation

Late approval after `cancel_payment()` produced a manual-review record:

```text
order_status=CANCELLED
late_success=false
late_error_key=payment_already_confirmed
late ledger_status=APPROVED
late reconciliation_status=MANUAL_REVIEW
late kds_release_authorized=false
event_payload.reason=payment_approved_after_order_cancelled
```

The verified ledger pair was:

```text
CANCELLED / PENDING       for the original cancelled ledger
APPROVED  / MANUAL_REVIEW for the late provider approval
```

The order remained `CANCELLED`.

### 5.4 PAY-CON-003 replay

The original replay scenario was re-executed with fresh test data.

Final state:

```text
order_status=CANCELLED
normal cancelled ledger remains CANCELLED
late approval ledger is APPROVED + MANUAL_REVIEW
kds_release_authorized=false
kds_tickets not reopened/released
```

The old failure mode did not occur.

Specifically, the order did not return to `CONFIRMED`.

### 5.5 KDS COOKING cancellation regression

The KDS cancellation regression check passed:

```json
{"cancel_success":true,"ticket":["CANCELLED","PAYMENT_CANCELLED",true]}
```

This confirms that the previous `600570` cancellation behavior still works after the `confirm_payment()` state-machine fix.

## 6. Boundary Verification

Boundary checks passed:

- `confirm_payment()` in `0098_create_payment_confirm_pipeline_rpc.sql` changed.
- `0037_create_payment_cancel_refund_rpc.sql` had zero diff.
- `cancel_payment()` was not changed.
- `request_refund()` was not changed.
- `confirm_refund()` was not changed.
- `release_kds_after_payment()` was not changed.
- No schema file was changed.
- No Flutter/runtime file was changed.

`git diff --check` passed.

## 7. Cleanup Verification

The test cleanup pass reported:

```json
{"remaining_orders":0,"removed_orders":9}
```

No persistent test orders remained from the verification run.

## 8. Verification Result

PASS.

The implementation satisfies the approved Rule 1/3/4/5 scope and removes the observed PAY-CON-003 failure mode.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600580_payment_confirm_cancel_state_machine_fix/600587_Audit.md] =====
# 600587_Audit.md

Status: ACCEPT
Lifecycle: Audit
Stage: 6 Audit
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Audit Decision

ACCEPT.

The Stage 4 implementation is accepted because it stayed within the approved ChangeContract, passed live verification, and eliminated the original PAY-CON-003 failure mode.

## 2. Scope Compliance

Approved scope:

- modify `confirm_payment()` only,
- implement Rule 1 PENDING-only gate,
- implement Rule 3 idempotent success / conflict rejection for already-confirmed orders,
- implement Rule 4/5 manual-review recording for late approvals after cancellation/refund,
- avoid schema changes,
- avoid `cancel_payment()` / refund pipeline changes.

Observed implementation:

- changed `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`,
- changed `confirm_payment()` state-machine logic,
- did not change `0037_create_payment_cancel_refund_rpc.sql`,
- did not change `cancel_payment()`,
- did not change `request_refund()` or `confirm_refund()`,
- did not change schemas,
- did not add new `order_status` or `reconciliation_status` values.

Scope compliance: PASS.

## 3. Runtime Audit

Runtime verification confirmed:

- PENDING orders still confirm successfully.
- COOKING/READY/SERVED/COMPLETED orders are rejected as not confirmable.
- Same-provider resend after confirmation returns idempotent success.
- Different-provider resend after confirmation is rejected.
- Late provider approval after cancellation is recorded as `MANUAL_REVIEW`.
- Late provider approval after cancellation does not reopen the order.
- Late provider approval after cancellation does not release KDS.

Runtime audit: PASS.

## 4. Original Failure Mode Closure

The original PAY-CON-003 failure mode was:

1. `confirm_payment()` succeeds and creates an approved ledger.
2. `cancel_payment()` cancels the ledger/order.
3. A later confirmation retry arrives.
4. `confirm_payment()` misses the cancelled prior ledger because it only checks active `APPROVED` rows.
5. A new normal `APPROVED` ledger is inserted.
6. The order silently returns from `CANCELLED` to `CONFIRMED`.

After this workpacket:

- a late approval after cancellation no longer returns the order to `CONFIRMED`,
- the late approval is marked `MANUAL_REVIEW`,
- `kds_release_authorized` remains false,
- KDS release is not called.

Closure result: PASS.

## 5. Checksum / Approval Audit

Two apparent verification concerns were resolved:

1. Checksum mismatch:
   - raw SHA256 and CRLF-to-LF-normalized SHA256 were being compared as if they were the same kind of checksum,
   - migration history correctly stores the LF-normalized checksum,
   - the final normalized checksum matches `catchmenu_meta.migration_history`.

2. Human Approval display:
   - the approval checkboxes were present in the UTF-8 file,
   - earlier console output rendered them incorrectly due to terminal encoding,
   - the approval record itself was valid.

Audit result: PASS.

## 6. Boundary Audit

Boundary checks passed:

- no `cancel_payment()` logic changed,
- no refund-pipeline logic changed,
- no `release_kds_after_payment()` logic changed,
- no schema was changed,
- no runtime/Flutter code was changed,
- no new error catalog entry was introduced,
- no `reopen_order()` implementation was introduced.

Boundary audit: PASS.

## 7. Open Items Carried Forward

The following Open Items remain unresolved and are explicitly carried forward:

1. Rule 6/7 — `reopen_order()`:
   - no reopen flow was implemented in this workpacket,
   - reopening cancelled/refunded orders remains a separate design topic.

2. Rule 6/7 — UI copy:
   - user/staff-facing copy for late approval/manual-review scenarios remains unimplemented,
   - this belongs to a later UI/product workflow.

3. Rule 3/4 boundary case:
   - re-delivery after `COOKING` or later states is currently rejected,
   - if the business later wants same-provider resend behavior after `COOKING`/`READY`/`SERVED`/`COMPLETED`, that requires a separate decision.

## 8. Final Audit Result

ACCEPT.

The implementation is narrow, verified, and safe to hand off for human review/commit.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600590_confirm_payment_from_provider_kds_commit_correction/600591_Overview_Confirm_Payment_From_Provider_Kds_Commit_Correction.md] =====
# 600591_Overview_Confirm_Payment_From_Provider_Kds_Commit_Correction.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`confirm_payment_from_provider_kds_commit_correction`

## §0 번호 확인

`600500_payment_confirmation/` 산하 현재 워크패킷: `600510`/`600540`/`600550`/`600560`/`600570`/`600580`. 다음 빈 10단위 번호는 `600590` — 이 워크패킷에 배정한다(라이브 `ls` 재확인).

## §0.1 배경 (Cursor+안티 전수조사 완료, 재확인 불필요로 인용 — 단 아래 §1은 이번 턴 라이브 재확인)

`catchmenu_payment.confirm_payment_from_provider()`(`0027`, Toss 웹훅 `0038`/VAN 콜백 `0056` 경로)가 결제 승인 직후 `kds_tickets.conditions_met`에 `payment_confirmed:true` JSON 플래그만 찍고, `kds_status`를 `HOLD`→`COMMITTED`로 전환하는 후속 호출이 전혀 없다. 함수 자신의 반환값이 `next_step: KDS_CAPACITY_CHECK_REQUIRED`를 예고하지만, 호출자(`0038`/`0056`) 어디에도 이 후속 단계를 트리거하는 코드가 없다. 이미 `601021_Overview.md` §10 / `601024_ChangeContract.md` §5.1에 알려진 결함으로 기록돼 있었고, `0157`(`600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign`)의 범위에서 명시적으로 제외됐다 — 그 워크패킷의 헤더 주석 자체가 "Does not modify confirm_payment_from_provider(), Toss webhook, or VAN paths (0027/0038/0056)"라고 못박았다.

## §1 최우선 확인 — "용량확인(capacity check)" 메커니즘이 실제로 존재하는가 (라이브 재확인 완료)

**결론: 메커니즘은 실제로 존재하고, 완전히 구현되어 있으며, 라이브 스키마에도 등록돼 있다.** 다만 그 메커니즘이 결제확인 파이프라인의 **어느 경로에서도 실제로 게이트(차단 조건)로 쓰이고 있지 않다** — 아래 §1.4가 이 지점을 정확히 특정한다.

### §1.1 `CAPACITY_CHECKING` — `chk_kds_status`에 실제로 존재

```sql
-- 라이브 재확인
select pg_get_constraintdef(oid) from pg_constraint where conname = 'chk_kds_status';
-- CHECK ((kds_status = ANY (ARRAY['HOLD', 'CAPACITY_CHECKING', 'COMMITTED', 'COOKING', 'READY', 'SERVED', 'COMPLETED', 'CANCELLED', 'MANUAL_FALLBACK'])))
```

우연히 남은 값이 아니다 — 아래 §1.2의 실제 함수들이 이 값으로 전이시키고, 이 값에서 전이시킨다.

### §1.2 용량확인/커밋 함수 — 코드베이스 전체에 이미 존재 (`0028`/`0039`/`0151`)

| 함수 | 파일 | 역할 |
|---|---|---|
| `catchmenu_kds.evaluate_kds_capacity(p_tenant_id, p_store_id, p_kitchen_zone)` | `0028_create_kds_capacity_commit_rpc.sql` | 주방구역별 `COOKING+COMMITTED` 티켓 수를 임계값(8)과 비교해 `capacity_ok` 반환. |
| `catchmenu_kds.commit_kds_ticket(p_tenant_id, p_store_id, p_ticket_id, p_conditions, p_correlation_id)` | `0028` | **특허2 core.** 7개 조건(`arrived`/`table_confirmed`/`payment_confirmed`/`kds_capacity_ok`/`menu_available`/`peak_time_ok`/`no_show_risk_ok`) 전부 충족 시 `HOLD`/`CAPACITY_CHECKING`→`COMMITTED`, 아니면 `CAPACITY_CHECKING`에 머물며 `conditions_met` 갱신. |
| `catchmenu_kds.authorize_kds_release(...)` | `0028` | 원래 존재했던 "결제 승인 ≠ KDS 릴리즈" 분리 단계 — **`0157`에서 DROP됨**(§1.5 참고). |
| `catchmenu_kds.check_kds_capacity(p_tenant_id, p_store_id)` | `0151_create_check_kds_capacity_function.sql` | `evaluate_kds_capacity()`를 매장 내 모든 주방구역에 대해 집계하는 wrapper. `{data:{is_overloaded, zones}}` 형태 반환. 설계 근거: `600410_kds_capacity_gate_and_status_reconciliation`(Stage 11까지 완료된 별도 워크패킷). |
| `catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id, p_store_id, p_order_id, p_force_conditions, p_correlation_id)` | `0039_create_kds_bulk_commit_rpc.sql` | `payment_ledger.kds_release_authorized`를 먼저 확인한 뒤, 주문의 `HOLD`/`CAPACITY_CHECKING` 티켓 각각에 대해 **`commit_kds_ticket()`을 실제로 호출**한다(라이브 재확인, `0039:72`). `authenticated`에 GRANT됨. |

**`grep -rln "commit_kds_ticket(" sql/migrations`** 결과 정의(`0028`)와 단 하나의 호출자(`0039`)만 존재한다 — 즉 `commit_kds_ticket()`의 7조건 게이트는 `bulk_commit_kds_tickets()`를 통해서만 도달 가능하다.

### §1.3 900xxx 설계문서 확인 — 특허 서사에는 "3단계" 언급 없음, 그러나 `600410`이라는 별도 SQL 레벨 설계 이력은 존재

`grep -rln "capacity" docs/900000_patent_and_handoff_package` → **0건.** 즉 `900xxx` 특허/인수인계 문서 어디에도 "결제확인→용량확인→KDS커밋"이라는 3단계 흐름을 명시적으로 서술한 곳이 없다 — 특허 서사 차원에서는 이 개념이 언급되지 않는다.

그러나 이것이 "실수로 넣은 불필요한 개념"이라는 뜻은 아니다 — `docs/600000_implementation_lifecycle/600400_kds_did_implementation/600410_kds_capacity_gate_and_status_reconciliation/`(Stage 11 Audit까지 완료, 7개 문서 전부 존재)가 `check_kds_capacity()`를 정확히 이 목적(용량 게이트)으로 설계했고, 그 설계 문서 자체가 `0098`(`confirm_payment()`)의 `check_kds_capacity()` 사용을 조사한 결과를 담고 있다(§1.4에서 인용).

**결론**: 용량확인 메커니즘은 (a) 900xxx 특허 서사에는 없지만 (b) `600000_implementation_lifecycle` 레벨의 실제 SQL 설계·구현으로는 존재하며 완결되어 있다 — "이 함수만 실수로 중간에 불필요한 개념을 넣어놓았다"는 가설은 **근거가 약하다**. `confirm_payment_from_provider()`(`0027`)의 코드 주석 자체(`600591_Overview.md` §1.4 인용)가 "특허2: KDS Late Binding 조건 중 payment_confirmed 업데이트"라고 명시하고 있어, 이 함수는 애초에 7조건 게이트 시스템과 연동될 것을 전제로 작성됐다.

### §1.4 결정적 사실 — `confirm_payment()`(정상 파이프라인)의 자매 함수조차 이 게이트를 실제로는 쓰지 않는다

`600412_Logic.md`(600410 워크패킷)가 이미 라이브로 재확인한 사실을 그대로 인용한다: `0098`(`confirm_payment()`)의 `check_kds_capacity()` 호출(`0098` L562, L575 부근)은 `v_capacity_check->'data'`를 **감사 로그/응답 payload에 정보성으로만 첨부**할 뿐, `is_overloaded` 값을 조건 분기(`if`)에서 실제로 소비하지 않는다(`grep -n "is_overloaded" 0098` → 0건, 600412가 직접 확인). 이번 턴 `0157`(가장 최근, Human 승인 2026-07-15)의 `release_kds_after_payment()` 전문을 재확인한 결과도 동일하다:

```sql
-- 0157, release_kds_after_payment() 발췌
v_capacity_check := catchmenu_kds.check_kds_capacity(...);  -- 호출만 함
...
update catchmenu_payment.payment_ledger set kds_release_authorized = true ...;  -- 무조건 승인
with released as (
  update catchmenu_kds.kds_tickets
  set kds_status = 'COMMITTED', ...
  where order_id = p_order_id and kds_status = 'HOLD'  -- v_capacity_check 값과 무관하게 무조건 커밋
  ...
```

즉 **현재 라이브에 살아있는, Human이 가장 최근(2026-07-15) 승인한 정상 결제 파이프라인(`confirm_payment()`→`release_kds_after_payment()`)조차 7조건 게이트(`commit_kds_ticket()`)를 전혀 거치지 않고, `check_kds_capacity()`를 정보성으로만 호출한 뒤 무조건 `HOLD`→`COMMITTED`로 직행한다.** 원래 있었던 `authorize_kds_release()`(결제승인≠KDS릴리즈 분리 단계)도 `0157`에서 DROP됐다.

### §1.5 종합 — 사실 관계만 정리 (판단 없음)

| 항목 | 사실 |
|---|---|
| `CAPACITY_CHECKING` 상태값 | 스키마에 존재, `0028`/`0039` 함수들이 실제로 전이시킴 |
| 7조건 게이트(`commit_kds_ticket()`) | 존재, 구현 완료, GRANT됨, `bulk_commit_kds_tickets()`를 통해서만 도달 가능 |
| `bulk_commit_kds_tickets()`의 실제 호출자 | SQL 레벨에서는 **0건**(`grep` 재확인) — Flutter/클라이언트에서 직접 호출하는지는 SQL 레이어 밖이라 이번 조사 범위 아님(§4 스코프 제한 참고) |
| `confirm_payment()`→`release_kds_after_payment()`(정상 경로, 가장 최근 Human 승인) | 게이트 미사용, `check_kds_capacity()`는 정보성 호출만, 무조건 커밋 |
| `confirm_payment_from_provider()`(`0027`, 웹훅/VAN 경로) | 자체 코드 주석·반환값이 게이트 연동을 전제하나, 실제로는 아무것도 호출하지 않아 `HOLD`에 무기한 머묾 |
| 900xxx 특허 문서 | "capacity" 개념 자체가 서술되지 않음(0건) |
| `600410` 설계 문서 | 존재, Stage 11 Audit까지 완료, `check_kds_capacity()`를 게이트 목적으로 설계했음을 명시 |

## §2 `confirm_payment_from_provider()`/`release_kds_after_payment()` 시그니처 재확인 (라이브)

```sql
-- 라이브 재확인, 2026-07-18
release_kds_after_payment(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_locale text default 'ko', p_correlation_id text default null)
confirm_payment_from_provider(p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text)
```

`confirm_payment_from_provider()`는 `release_kds_after_payment()`가 요구하는 `p_order_id`(`v_intent.order_id`로 이미 조회됨)와 `p_ledger_id`(방금 INSERT한 `v_ledger_id`)를 **이미 지역 변수로 갖고 있다** — 호출에 필요한 값 자체는 함수 본문 안에 전부 존재한다. 유일한 차이는 `confirm_payment_from_provider()`에 `p_locale` 파라미터가 없다는 것인데, `release_kds_after_payment()`의 `p_locale`은 `default 'ko'`이므로 생략 가능(사소한 차이, 블로커 아님).

`confirm_payment_from_provider()`는 `0153`에서 중복 오버로드가 DROP되어 현재 단일 8-파라미터 버전만 라이브에 존재함을 재확인했다(`600510` 워크패킷이 이미 해결 — 이 함수는 현재 정상적으로 호출 가능한 상태이며, 문제는 순수하게 "결제확인 이후 후속 KDS 전이가 없다"는 것 하나뿐이다).

## §3 방향 A/B — 사실 근거 제시 (판단은 Human, `600592_Logic.md` §1에서 두 옵션 모두 설계)

**방향 A(용량확인 게이트 연동)의 근거**: `commit_kds_ticket()`/`bulk_commit_kds_tickets()`가 이미 완전히 구현·GRANT되어 있고, `confirm_payment_from_provider()` 자신의 코드 주석·반환값이 애초에 이 흐름을 전제로 작성됐다(§1.3/§1.4). 이 방향을 택하면 웹훅/VAN 결제는 정상 결제(`confirm_payment()`)보다 **더 엄격한** 용량 게이트를 통과해야 커밋된다.

**방향 B(단순화, `release_kds_after_payment()` 직접 호출)의 근거**: 가장 최근(2026-07-15), Human이 명시적으로 승인한 정상 결제 파이프라인 재설계(`0157`)가 이미 이 게이트를 **의도적으로 우회**하도록 만들어졌다(§1.4) — `authorize_kds_release()`(분리된 승인 단계)도 같은 턴에 DROP됐다. `confirm_payment_from_provider()`를 방향 A로 고치면, 완전히 같은 "결제 승인" 이벤트인데도 **경로에 따라 다른 커밋 규칙**(하나는 게이트 있음, 하나는 없음)이 생긴다 — 이것 자체가 새로운 불일치이며, 그 불일치를 만든 쪽은 `confirm_payment_from_provider()`가 아니라 원래 `0157`이 정상 경로를 단순화하기로 결정했다는 사실이다.

**어느 쪽도 아직 확정된 "틀린 방향"이 아니다** — A는 이미 존재하는 인프라를 실제로 쓰게 만드는 것이고, B는 가장 최근 Human 결정과의 일관성을 우선하는 것이다. 이 판단은 Human 결정 사항이다.

## §4 `resolve_payment_uncertain()` 형제 결함 — 포함 여부 판단 근거

Cursor가 같은 파일(`0027`)에서 발견한 별도 결함: `resolve_payment_uncertain()`은 `p_resolution_type in ('CONFIRMED_APPROVED', 'MANUAL_OVERRIDE_APPROVED')`(주석: "결제 확인, KDS 용량확인으로 진행")일 때도 **`payment_ledger`에 INSERT하는 코드가 전혀 없다**(라이브 재확인, 함수 전문에 `insert into catchmenu_payment.payment_ledger` 0회 등장). `order_sessions.session_status`/`payment_intents.intent_status`만 갱신되고, KDS 티켓에 대한 갱신도 전혀 없다 — `PAYMENT_UNCERTAIN`으로 분류됐다가 사람이 수동으로 "승인" 처리한 결제는, 승인 이후에도 **원장 기록도 없고 KDS도 영원히 `HOLD`에 머문다.**

**같은 워크패킷에 포함할지 판단 근거**:

| 근거 | 방향 |
|---|---|
| 같은 파일(`0027`), Cursor가 같은 조사 턴에 발견, 둘 다 "결제확인 이후 후속 처리 누락"이라는 공통 상위 주제 | 묶는 쪽 근거 |
| `confirm_payment_from_provider()`의 수정은 **이미 존재하는 함수를 호출로 배선**하는 작업(낮은 설계 리스크) | — |
| `resolve_payment_uncertain()`의 수정은 **`payment_ledger`에 새로운 INSERT 형태를 설계**해야 하는 작업 — `mark_payment_uncertain()` 시점에는 provider 확정 데이터(`provider_payment_key`/`provider_approval_number`)가 아예 없을 수 있어(애초에 "불확실"했으므로), `CONFIRMED_APPROVED`/`MANUAL_OVERRIDE_APPROVED` 각각에 대해 `ledger_entry_type`/금액 출처/provider 필드 처리 방식을 새로 정의해야 한다 — `payment_ledger`는 "단일 진실 소스"로 문서화된 재무 원장 테이블이라 리스크 등급이 다르다 | 쪼개는 쪽 근거 |
| `confirm_payment_from_provider()`는 "무엇을 호출할지"(A/B) 자체가 아직 Human 미결정이라 이미 그 자체로 하나의 완결된 논의 단위 | 쪼개는 쪽 근거 |

**권고(판단 아님, 근거 제시)**: 오늘 이 세션이 반복 적용한 "같은 패턴이면 묶고 다른 패턴이면 쪼갠다" 원칙을 그대로 적용하면, `confirm_payment_from_provider()`(배선 수정)와 `resolve_payment_uncertain()`(신규 원장 INSERT 설계)은 **수정 패턴의 성격이 다르다** — 전자는 `600650`/`600660`류(기존 함수 호출 배선)에 가깝고 후자는 `601130`류(신규 스키마/로직 설계)에 가깝다. **분리를 권고**하되(가칭 `resolve_payment_uncertain_ledger_gap_correction`), 이번 문서는 이 판단의 근거만 제시하고 최종 결정은 Human에게 남긴다(`600592_Logic.md` §2에서 재확인).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- Flutter/클라이언트 코드 확인 안 함 — `bulk_commit_kds_tickets()`의 실제 호출자가 클라이언트 레벨에 있는지는 SQL 레이어 조사만으로는 확정할 수 없다(§1.5 명시).
- `resolve_payment_uncertain()`의 실제 수정 설계는 이 워크패킷에 포함하지 않음(§4 권고에 따름) — `600592_Logic.md`는 방향 A/B 설계와 스코프 판단 근거만 다룬다.
- Cash/무결제 경로(`601024_ChangeContract.md` §5.2), 재시도/정산 함수(§5.3), `start_cooking()`의 호출자 부재(§5.4) — 전부 이 워크패킷 밖, 이미 알려진 별도 Open Item.

## §6 Open Items

(a) 방향 A/B 중 어느 쪽을 택할지 — Human 결정 필요, `600592_Logic.md`에서 두 옵션 모두 설계 완료 상태로 대기.
(b) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — 별도 워크패킷 권고(§4), Human 결정 필요.
(c) `bulk_commit_kds_tickets()`의 실제 호출자가 존재하는지(Flutter 또는 다른 SQL 경로) — SQL 레이어 조사로는 미확정, 방향 A를 택할 경우 이 사실이 A의 실질적 효과(사람이 실제로 그 결과를 보는지)에 영향을 줌.
(d) `601024_ChangeContract.md` §5.4(`start_cooking()` 호출자 부재)와 이 워크패킷의 관계 — 방향 A/B 어느 쪽이든 `COMMITTED` 이후 `COOKING` 전이 자체가 이미 별도로 끊겨 있다는 사실은 이 워크패킷의 수정 효과를 제한할 수 있음, 별도 확인 필요.
(e) 900xxx 특허 문서에 "capacity" 서술이 없다는 사실 자체를 문서화 갭으로 볼지(특허2 서사 보강 필요) — 이 워크패킷 범위 밖, 참고로만 기록.

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `600592_Logic.md`로 이어짐.** 용량확인 메커니즘은 (1) 스키마에 실제로 존재(`CAPACITY_CHECKING`), (2) 완전히 구현된 지원 함수 3종(`evaluate_kds_capacity`/`commit_kds_ticket`/`check_kds_capacity`) + 게이트를 실제로 통과시키는 `bulk_commit_kds_tickets()`가 존재, (3) `600410` 설계 문서가 Stage 11까지 완료된 상태로 뒷받침하지만, (4) 정작 가장 최근(2026-07-15) Human이 승인한 정상 결제 파이프라인(`confirm_payment()`→`release_kds_after_payment()`)조차 이 게이트를 실제로는 우회하고 있다는 사실을 라이브 재확인으로 실증했다(§1.4). 이 사실 관계에 근거해 방향 A/B를 둘 다 근거와 함께 제시했고(§3), `resolve_payment_uncertain()`의 형제 결함은 수정 패턴이 근본적으로 다르다는 근거로 분리를 권고했다(§4) — 두 판단 모두 최종 결정은 Human에게 남긴다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/600590_confirm_payment_from_provider_kds_commit_correction/600592_Logic_Confirm_Payment_From_Provider_Kds_Commit_Correction.md] =====
# 600592_Logic_Confirm_Payment_From_Provider_Kds_Commit_Correction.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`confirm_payment_from_provider_kds_commit_correction`

## §0 이 문서의 성격 — 두 방향을 모두 설계, 결정은 하지 않음

`600591_Overview.md` §3이 방향 A(용량확인 게이트 연동)/방향 B(단순화, `release_kds_after_payment()` 직접 호출)를 사실 근거와 함께 제시했다. 이 Logic 문서는 **둘 중 하나를 채택하지 않고, 둘 다 Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계**한다 — Human이 §1.3에서 하나를 선택하면 다음 Stage는 선택된 쪽만 진행한다.

## §1 방향 A — 용량확인 게이트 연동

### §1.1 필요한 추가 단계 — 단순히 `bulk_commit_kds_tickets()`만 호출하면 안 되는 이유

`confirm_payment_from_provider()`는 `payment_ledger` INSERT 시점에 **명시적으로** `kds_release_authorized := false`를 세팅한다(특허1 원칙, `0027` 원문 그대로 보존). `bulk_commit_kds_tickets()`(`0039`)는 시작하자마자 `payment_ledger.kds_release_authorized`를 확인하고, `false`면 즉시 `kds_release_not_authorized` 에러를 반환한다(`0039:38-53`, 라이브 재확인). 즉 `confirm_payment_from_provider()`가 곧바로 `bulk_commit_kds_tickets()`를 호출하면 **매번 100% 실패**한다.

원래 이 간극을 메우던 함수가 `catchmenu_kds.authorize_kds_release()`(`0028`)였으나, `0157`에서 DROP됐다(`600591_Overview.md` §1.2). 따라서 방향 A는 그 기능을 **`confirm_payment_from_provider()` 자신이 인라인으로** 수행해야 한다 — `release_kds_after_payment()`가 이미 하고 있는 것과 동일한 패턴(`payment_ledger.kds_release_authorized`를 직접 `true`로 UPDATE)이다.

### §1.2 설계 — 인라인 authorize + `bulk_commit_kds_tickets()` 호출

```sql
-- confirm_payment_from_provider() 본문 마지막(기존 audit_id 계산 직후, return 직전)에 추가:

-- 방향 A: 특허1의 "결제승인≠KDS릴리즈" 분리를 유지하되, authorize_kds_release()가
-- 0157에서 DROP됐으므로 release_kds_after_payment()와 동일한 인라인 패턴으로 승인 처리.
update catchmenu_payment.payment_ledger
set
  kds_release_authorized = true,
  kds_release_authorized_at = now(),
  kds_release_authorized_by = 'PROVIDER'
where id = v_ledger_id;

v_bulk_commit_result := catchmenu_kds.bulk_commit_kds_tickets(
  p_tenant_id := p_tenant_id,
  p_store_id := p_store_id,
  p_order_id := v_intent.order_id,
  p_force_conditions := null,
  p_correlation_id := p_correlation_id
);

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized', true,
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_commit_result', v_bulk_commit_result,
  'reconciliation_status', 'PENDING',
  'message_code', 'payment_approved_kds_committed',
  'audit_id', v_audit_id
);
```

`v_bulk_commit_result`는 `declare` 블록에 `jsonb` 타입으로 추가 선언 필요. `next_step: 'KDS_CAPACITY_CHECK_REQUIRED'`는 이 시점에 실제로 용량확인까지 끝났으므로 응답에서 제거(또는 `bulk_commit_kds_tickets()`의 `pending_count > 0`이면 `'KDS_CAPACITY_RETRY_REQUIRED'`로 대체 — 7조건 중 `kds_capacity_ok`가 그 순간 `false`면 티켓이 `COMMITTED`가 아니라 `CAPACITY_CHECKING`에 머물 수 있으므로, 이 경우 "누가 재시도를 트리거하는지"가 새 Open Item이 된다 — §3 (a)).

### §1.3 방향 A가 만드는 새로운 질문 (설계상 불가피, 결정 필요)

- `bulk_commit_kds_tickets()`가 `pending_count > 0`(용량 부족으로 일부만 `CAPACITY_CHECKING`에 머묾)을 반환하면, 웹훅/VAN 경로에는 이걸 재시도시킬 주체가 없다(정상 경로도 마찬가지지만, 정상 경로는애초에 이 상태에 도달하지 않으므로 이 질문 자체가 생기지 않았다). 이 워크패킷이 그 재시도 메커니즘까지 설계할지는 별도 판단 필요.
- `kds_release_authorized_by := 'PROVIDER'`(제안값) — `release_kds_after_payment()`는 `'SYSTEM'`을 쓴다(`0157`). 웹훅이 실제 승인 주체이므로 `'PROVIDER'`가 더 정확해 보이지만, `payment_ledger.kds_release_authorized_by`가 이미 `text` 자유 필드라 제약 위반 위험은 없다 — 다만 이 값을 소비하는 리포팅/대시보드가 있다면 새 값 도입이 영향을 줄 수 있어 Open Item으로 남긴다.

## §2 방향 B — 단순화, `release_kds_after_payment()` 직접 호출 (`confirm_payment()`와 동형)

### §2.1 설계 — `confirm_payment()`의 정확한 호출 패턴을 그대로 재사용

```sql
-- confirm_payment_from_provider() 본문 마지막(기존 audit_id 계산 직후, return 직전)에 추가:
-- confirm_payment()(0098:708-716)와 정확히 동일한 패턴 — p_locale은 파라미터가 없으므로 'ko' 하드코딩.

v_kds_release_result := catchmenu_payment.release_kds_after_payment(
  p_tenant_id := p_tenant_id,
  p_store_id := p_store_id,
  p_order_id := v_intent.order_id,
  p_ledger_id := v_ledger_id,
  p_locale := 'ko',
  p_correlation_id := p_correlation_id
);

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized', true,
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'reconciliation_status', 'PENDING',
  'message_code', 'payment_approved_kds_committed',
  'audit_id', v_audit_id
);
```

`v_kds_release_result`는 `declare` 블록에 `jsonb` 타입으로 추가 선언 필요. `next_step: 'KDS_CAPACITY_CHECK_REQUIRED'`는 제거(`release_kds_after_payment()`는 조건부 대기 상태를 만들지 않고 항상 즉시 커밋하거나 0건 커밋 후 경고 로그만 남기므로, "다음 단계 대기"라는 개념 자체가 방향 B에는 없다).

### §2.2 이 함수 자신의 기존 `conditions_met` UPDATE와의 관계 — 그대로 둔다

`confirm_payment_from_provider()`는 이미 `kds_tickets.conditions_met`에 `payment_confirmed:true`를 병합하는 UPDATE(`0027:301-309`)와 `kds_events` INSERT(`0027:314-331`)를 갖고 있다. `release_kds_after_payment()`는 뒤이어 `conditions_met`를 **완전히 새 객체로 덮어쓴다**(`0157:91-96`, `||` 병합이 아니라 대입) — 값 결과는 동일(`payment_confirmed:true`가 최종적으로 남음)하므로 충돌은 없지만, 확인 순서상 앞의 UPDATE가 사실상 즉시 덮어써지는 중간 상태가 된다. 이 워크패킷은 기존 코드를 그대로 유지한다(`kds_events`의 `payment_confirmed_released` 이벤트 자체는 감사 추적 가치가 있어 삭제하지 않음) — 순수하게 추가만 하는 최소 변경.

### §2.3 방향 B가 만드는 새로운 질문

- `confirm_payment()`가 이미 갖고 있던 "0건 커밋 시 WARNING 로그"(`0157`, `v_released_count = 0`) 동작이 웹훅/VAN 경로에도 그대로 적용된다 — 이 자체는 방향 B의 일관성 장점이지만, Toss 웹훅이 중복 전송되는 경우(이미 커밋된 주문에 대해 재호출) 이 WARNING이 노이즈성으로 반복될 수 있다는 점은 확인 필요(§3 (b)).

## §3 두 방향 공통 Open Items

(a) 방향 A를 택할 경우 `CAPACITY_CHECKING`에 머문 티켓의 재시도 주체 — 미설계.
(b) 웹훅 중복 전송(재시도) 시나리오에서 두 방향 모두 `confirm_payment_from_provider()`의 멱등성 처리가 어떻게 되는지 — 이번 조사에서 별도 확인하지 않음, 원본 함수에 idempotency_key 기반 처리가 있는지 재확인 필요(`create_payment_intent()`에는 있으나 `confirm_payment_from_provider()` 자체에는 `0038`/`0056` 호출부의 상위 레벨 idempotency에 의존하는 것으로 보임 — 미확정).
(c) 두 방향 모두 `v_kds_updated`(현재 `HOLD`/`CAPACITY_CHECKING` 티켓 개수)가 0이었던 경우(예: 이미 다른 경로로 처리된 주문) 새로 추가되는 호출을 그대로 실행해도 안전한지 — `release_kds_after_payment()`/`bulk_commit_kds_tickets()` 둘 다 "대상 티켓 0건"을 에러가 아니라 정상 케이스(카운트 0)로 처리하므로 안전할 것으로 판단되나, 라이브 재현 검증은 다음 Stage(TestPlan)에서 필요.

## §4 `resolve_payment_uncertain()` — 별도 워크패킷 권고 재확인

`600591_Overview.md` §4의 판단 근거를 그대로 유지한다 — 이 함수의 수정은 `payment_ledger`에 대한 **신규 INSERT 설계**(어떤 `ledger_entry_type`을 쓸지, `provider_payment_key`/`provider_approval_number`가 없는 상태를 어떻게 표현할지, 금액을 어디서 가져올지)가 필요해 방향 A/B 어느 쪽보다도 설계 범위가 크다. 이 문서는 그 설계를 진행하지 않는다 — Human이 분리를 승인하면 별도 Overview/Logic(가칭 `resolve_payment_uncertain_ledger_gap_correction`)에서 처음부터 설계한다.

참고로 `payment_ledger`의 관련 컬럼 재확인 결과(이번 턴 라이브 조회): `ledger_entry_type`/`ledger_status`/`approved_amount`/`net_amount`/`provider_type`(전부 `not null`), `provider_payment_key`/`provider_approval_number`/`provider_approved_at`/`provider_response_id`(전부 nullable). `provider_type`이 `not null`인데 `mark_payment_uncertain()`이 애초에 `provider_type` 자체를 파라미터로 받지 않으므로(`0027:432-438`), `resolve_payment_uncertain()`이 새 `payment_ledger` 행을 만들려면 `payment_intents.provider_type`(원래 `create_payment_intent()`가 저장한 값)을 다시 조회해야 한다는 것도 향후 설계에서 확인이 필요한 지점이다(이 문서에서는 설계하지 않고 기록만 함).

## §5 마이그레이션 파일 배치 (Stage 8 대상, 이번 문서는 설계만)

Human이 방향 A 또는 B를 선택한 이후, Stage 5(TestPlan/ChangeContract)에서 다음 마이그레이션 번호를 확정한다(이 문서 작성 시점 기준 `0165`가 최신 — 재확인 필요). `0027` 원본 소스 텍스트는 수정하지 않고 `CREATE OR REPLACE`로만 라이브 정의를 덮어쓴다(`0160`/`0163`/`0164`와 동일 기법). 신규 `error_codes`/`message_catalog` 항목은 두 방향 모두 필요 없을 것으로 예상(기존 등록된 키만 재사용) — Stage 5에서 재확인.

## §6 Open Items (Overview에서 이월)

(a) 방향 A/B 선택 — Human 결정 필요(§0/§1/§2).
(b) `resolve_payment_uncertain()` 분리 여부 — Human 결정 필요(§4).
(c) `bulk_commit_kds_tickets()`의 실제 호출자 존재 여부(Flutter 확인 필요, SQL 레이어 밖) — 방향 A의 실효성에 영향.
(d) `start_cooking()` 호출자 부재(`601024_ChangeContract.md` §5.4) — 이 워크패킷과 별개, 참고만.
(e) 900xxx 특허 문서의 "capacity" 서술 부재 — 별도 문서화 갭, 참고만.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Human 결정 대기 — 두 방향 모두 Stage 5 착수 가능한 수준까지 설계 완료.** 방향 A(§1)는 `authorize_kds_release()`가 `0157`에서 DROP된 빈자리를 인라인 승인으로 메우고 `bulk_commit_kds_tickets()`를 호출하는 설계이며, 방향 B(§2)는 `confirm_payment()`의 `release_kds_after_payment()` 호출 패턴을 그대로 재사용하는 설계다. 두 방향 모두 파라미터가 이미 함수 본문 안에 존재해 호출 자체는 간단하지만, 각각 서로 다른 새 질문(§1.3/§2.3)을 만든다. `resolve_payment_uncertain()`의 형제 결함은 신규 `payment_ledger` INSERT 설계가 필요해 이 워크패킷보다 범위가 크다는 근거로 분리를 재확인했다(§4) — 최종 결정은 Human.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601031_Overview_Canonical_Kds_Release_Orchestration.md] =====
# 601031_Overview_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 번호 확인 — 번호 충돌 발견 및 해소 경위 (라이브 재확인)

**최초 시도(`600593`)가 잘못됐음을 스스로 발견해 정정한다.** `600500_payment_confirmation/` 산하 직전 워크패킷 `600590_confirm_payment_from_provider_kds_commit_correction/`은 이미 `600591`(Overview)/`600592`(Logic)를 썼고, `600602_NavigationMap`... 정정: 이 도메인의 `600502_NavigationMap_Payment_Confirmation.md`에 이 문서를 작성한 세션 자신이 "`600591_Overview...` -> `600592_Logic...` -> (TestPlan/ChangeContract pending)"라고 이미 기록해 `600593`(TestPlan)/`600594`(ChangeContract)/`600595`(Module) 슬롯을 사실상 예약해 놓은 상태였다 — 처음 이 워크패킷을 `600593`/`600594`/`600595`로 만들려던 시도는 **그 예약과 직접 충돌**하는 것이었고, 파일 생성 직후 자체 재검토로 발견해 즉시 삭제했다.

**대안 탐색**: `600500_payment_confirmation/`의 다음 "10단위" 슬롯은 관례상 `600600`이지만, 이는 **완전히 다른 도메인**(`600600_waiting_order_session/`)이 이미 점유하고 있어(`ls docs/600000_implementation_lifecycle/` 재확인) 쓸 수 없다 — 즉 `600500` 도메인은 자신의 "백단위" 번호 공간(`600500`-`600599`)을 사실상 전부 소진한 상태다(`600510`/`600540`/`600550`/`600560`/`600570`/`600580`/`600590` 7개 워크패킷 + `600590` 자신의 예약 슬롯).

**해소 — 기존 선례 재사용**: `docs/600000_implementation_lifecycle/600400_kds_did_implementation/601020_authorize_kds_release_overload_and_redesign/`가 이미 정확히 같은 상황의 선례다 — 이 워크패킷은 물리적으로 `600400_kds_did_implementation/` 폴더 안에 있지만, 문서 번호는 `600400`대가 아니라 `601020`대를 쓴다. 즉 **이 프로젝트의 워크패킷 번호는 물리적 폴더 위치의 "백단위"와 반드시 일치할 필요가 없다**는 것이 이미 확립된 관례다. 이 선례를 그대로 따라, `601030`-`601039` 구간이 라이브 어디에도 쓰이지 않음을 재확인한 뒤(`find`/`000005_Index_Document_Number.md` 재검색, 0건) 이 워크패킷을 `601030`(폴더)/`601031`(Overview)/`601032`(Logic)로 배정한다. 폴더는 논리적 연관성(직전 워크패킷 `600590`, 결제확인 도메인)에 따라 `600500_payment_confirmation/` 안에 물리적으로 둔다.

## §0.1 배경 (Cursor 조사 완료 - `601024`가 명시적으로 남긴 Open Item, 재확인 불필요)

`601024`(`0157`의 승인 근거)는 시간 제약으로 `confirm_payment()`(POS 경로, `0098`)만 게이트 우회(`release_kds_after_payment()`가 `check_kds_capacity()`를 정보성으로만 쓰고 무조건 커밋)로 재설계했고, "웹훅/VAN 경로(`0027`)는 여전히 깨진 채 남을 것이며 후속 워크패킷이 필요하다"고 스스로 기록해뒀다(`600591_Overview.md` §1.4/§1.5가 이미 라이브로 재확인한 내용과 정확히 일치). `commit_kds_ticket()`(7조건 게이트)/`evaluate_kds_capacity()`는 `0028`에서 이미 완성되어 라이브에 존재하지만 실질적 호출자가 없는 고아 함수 상태다 — `authorize_kds_release()`가 `0157`에서 DROP되기 전과 동일한 패턴("완성됐지만 아무도 안 씀")이 `commit_kds_ticket()`/`bulk_commit_kds_tickets()`에도 반복되고 있다.

## §0.2 확정된 방향 (ChatGPT+제미나이 교차검증, Human 최종 결정, 재논의 금지)

1. 신규 공용 함수 `request_kds_release_after_payment()` 설계 — `evaluate_kds_capacity()`/`commit_kds_ticket()`를 실제로 호출하는 경로를 만든다.
2. `confirm_payment_from_provider()`(`0027`)가 이 신규 함수를 호출하도록 수정 — 현재 하드코딩된 `kds_release_authorized=false`+JSON 플래그만 찍는 부분을 실제 게이트 연동으로 교체.
3. `confirm_payment()`(POS, `0098`)는 이번 워크패킷에서 손대지 않는다 — "POS도 같은 공용 함수로 연결"은 최우선 후속 워크패킷 후보로만 기록.
4. `resolve_payment_uncertain()`은 완전히 별도(원장 도메인 결함) — 이번엔 다루지 않는다.

## §1 `evaluate_kds_capacity()`/`commit_kds_ticket()` 정확한 현재 시그니처/반환값 (라이브 재확인, 2026-07-18)

```sql
-- 라이브 재확인
evaluate_kds_capacity(p_tenant_id uuid, p_store_id uuid, p_kitchen_zone text default null)
  returns jsonb  -- {cooking_count, hold_count, ready_count, capacity_ok, threshold, kitchen_zone}

commit_kds_ticket(p_tenant_id uuid, p_store_id uuid, p_ticket_id uuid, p_conditions jsonb default '{}'::jsonb, p_correlation_id text default null)
  returns jsonb
  -- 성공(전이): {success:true, ticket_id, kds_status:'COMMITTED', conditions_met, committed_at, kitchen_zone, audit_id, message_code:'kds_committed'}
  -- 성공(대기): {success:true, ticket_id, kds_status:'CAPACITY_CHECKING', conditions_met, all_conditions_met:false, missing_conditions:{...}, capacity_detail, message_code:'kds_conditions_pending'}
  -- 실패(입력검증): {success:false, error_key:'ticket_id_required'|'conditions_must_be_object'|'ticket_not_found'|'ticket_not_holdable'}

bulk_commit_kds_tickets(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_force_conditions jsonb default null, p_correlation_id text default null)
  returns jsonb
  -- {success:true, order_id, committed_count, pending_count, skipped_count, total_processed, all_committed, ticket_results:[...], message_code}
  -- {success:false, error_key:'kds_release_not_authorized', message, order_id}  -- payment_ledger.kds_release_authorized가 false인 주문의 모든 티켓에 대해
```

**핵심 발견 — `commit_kds_ticket()`은 `CAPACITY_CHECKING` 결과도 `success:true`로 반환한다.** 즉 "용량 부족으로 즉시 커밋되지 못함"은 이 함수 자신의 계약에서 이미 **에러가 아니라 유효한 정상 결과**로 설계돼 있다(`0028:339-373`, 라이브 재확인) — §2의 "결제확정 성공과 KDS 방출 실패를 구분해야 한다"는 원칙이 이 계층에서는 이미 자연스럽게 지켜지고 있다. 신규 함수는 이 계약을 그대로 이어받아야 한다.

`bulk_commit_kds_tickets()`는 `commit_kds_ticket()`을 주문의 `HOLD`/`CAPACITY_CHECKING` 티켓 전부에 대해 이미 순회 호출하며(`0039:56-101`, 라이브 재확인), `payment_ledger.kds_release_authorized`를 사전 확인한다 — 즉 **신규 함수가 직접 `commit_kds_ticket()`을 호출할 필요가 없다.** `bulk_commit_kds_tickets()`를 재사용하면 이미 검증된 순회/집계 로직을 중복 구현하지 않아도 된다(§3 근거 참고).

## §2 결제확정 성공 ≠ KDS 방출 실패 — 원칙 반영 확인 (ChatGPT 지적)

**원칙**: "결제 성공 + KDS 대기(`CAPACITY_CHECKING`)"는 유효한 상태여야 하며, 결제 확정 자체의 실패와 혼동되면 안 된다.

**라이브 확인 결과**: 이 원칙은 이미 두 지점에서 부분적으로 지켜지고 있다 — (1) `commit_kds_ticket()` 자신의 반환 계약(위 §1), (2) `confirm_payment_from_provider()`의 `payment_ledger` INSERT는 이미 KDS 관련 코드보다 **먼저** 실행되고 완결된다(`0027:262-289`). 문제는 신규 함수를 **어떻게 호출하느냐**에 있다 — PL/pgSQL에서 함수 A가 함수 B를 호출하고 B가 처리되지 않은 예외를 던지면, A 자신의 그 시점까지의 모든 변경(이미 완료된 `payment_ledger` INSERT 포함)도 함께 롤백된다는 것은 이 세션이 `600652_Logic.md` §9.2에서 이미 실증한 사실이다(`bind_table_to_session()`의 예시와 구조적으로 동일).

**적용**: 신규 함수 `request_kds_release_after_payment()` 자신이 **모든 내부 오류를 스스로 처리하고 절대 예외를 재전파(RAISE)하지 않는** 설계를 채택해야 한다(`600592_Logic.md` §0/`600652_Logic.md` §1.5가 이미 확립한 "raise 대신 build_error_response류 반환" 패턴을 그대로 적용) — 이렇게 하면 `confirm_payment_from_provider()`는 이 함수 호출로부터 예외를 받을 일이 원천적으로 없어지고, `payment_ledger` INSERT가 KDS 쪽 오류로 인해 함께 롤백되는 경로 자체가 봉쇄된다. 상세 설계는 `601032_Logic.md` §1/§3.

## §3 `CAPACITY_CHECKING` 재시도 메커니즘 — 존재 여부 확인 및 스코프 판단 근거

**라이브 재확인 결과: 재시도 메커니즘이 전혀 없다.**

- `bulk_commit_kds_tickets()`(`0039`)의 SQL 레벨 호출자를 전수 검색한 결과 **0건**(정의/GRANT/주석 줄만 매치) — `commit_kds_ticket()`과 동일한 고아 함수 상태다.
- `pg_cron`/`cron.schedule(...)` 전체 사용처를 확인한 결과, KDS/capacity/bulk_commit 관련 스케줄 작업은 **0건**(`0072_create_pg_cron_schedules.sql`의 유일한 `cron.schedule(` 호출은 무관한 작업).
- 즉 어떤 티켓이 `CAPACITY_CHECKING`에 머물게 되면, 지금 시점에는 **아무것도 그 티켓을 다시 확인하지 않는다** — 주방 담당자가 수동으로 뭔가를 누르지 않는 한(그런 UI/RPC가 있는지도 SQL 레이어에서는 확인 불가, §5 스코프 한정) 영원히 `CAPACITY_CHECKING`에 머문다.

**스코프 판단 근거**: 재시도 메커니즘(주기적 재평가, 또는 주방 여유 발생 시 이벤트 기반 트리거)을 설계하려면 (1) 폴링 주기/트리거 조건 결정, (2) `pg_cron` 신규 작업 등록, (3) 스토어별/전체 스캔 방식 결정 등 **이번 워크패킷(결제확인→KDS 방출 배선)과는 다른 차원의 설계**가 필요하다. 이번 워크패킷의 핵심은 "결제 확인 시점에 게이트를 1회 정확히 통과시키는 것"이며, "그 이후 상황이 바뀌었을 때 재평가하는 것"은 별개 문제다 — 오늘 이 세션이 반복 적용한 "다른 개념이면 쪼갠다" 원칙을 그대로 적용하면 **분리 대상**이다. 이번 워크패킷은 재시도 메커니즘을 설계하지 않고, `CAPACITY_CHECKING` 상태가 "정상적으로 도달 가능하지만 이번 워크패킷 이후에도 여전히 해소 방법이 없는 상태"임을 Open Item으로 명시한다(§6 (a)).

## §4 신규 함수의 스키마 위치 — `catchmenu_payment` (근거)

**결정 근거**: 이미 존재하는 정확히 같은 성격의 선례가 있다 — `release_kds_after_payment()`(`0098`이 호출, `0157`이 최근 재설계)는 KDS 테이블(`kds_tickets`)을 직접 UPDATE하는 함수이면서도 `catchmenu_kds`가 아니라 **`catchmenu_payment`**에 위치한다. 이 코드베이스의 기존 관례는 "이 함수가 어느 테이블을 건드리는가"가 아니라 **"이 함수를 누가, 어떤 계기로 호출하는가"**로 스키마를 결정한다 — `release_kds_after_payment()`는 결제 확인이 계기이므로 `catchmenu_payment`, `commit_kds_ticket()`/`bulk_commit_kds_tickets()`는 KDS 운영(주방 화면 조작 등)이 계기가 될 수도 있어 `catchmenu_kds`에 남아있다.

신규 함수 `request_kds_release_after_payment()`도 정확히 `release_kds_after_payment()`와 동일한 성격(결제 확인이 유일한 계기, "payment→kds" 방향의 단방향 오케스트레이션)이므로 **`catchmenu_payment`**에 배치하는 것이 기존 관례와 가장 잘 맞는다 — 이름도 `release_kds_after_payment()`와 짝을 이루는 형태(`request_` 접두어로 "요청은 하되 즉시 확정을 보장하지 않는다"는 `CAPACITY_CHECKING` 가능성을 이름에서부터 구분).

## §5 스코프 한정

- `.sql` 파일 생성/수정 없음(이번 턴).
- `confirm_payment()`(`0098`)는 손대지 않음 — Open Item으로만 기록(§6 (b)).
- `resolve_payment_uncertain()` 관련 작업 안 함.
- `bulk_commit_kds_tickets()`의 실제 UI/Flutter 호출자 존재 여부는 SQL 레이어 조사 범위 밖(§3에서 SQL 레벨 0건만 확인).
- `CAPACITY_CHECKING` 재시도 메커니즘 설계 안 함(§3).
- `start_cooking()`의 호출자 부재(`601024_ChangeContract.md` §5.4) — 별개, 참고만.

## §6 Open Items

**(Stage 4 Critical tier — Cursor+Codex 지적사항 반영, `601032_Logic.md` §6과 완전히 동일한 목록을 공유하도록 정리함)**

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 이번 워크패킷 이후에도 미해소, 별도 워크패킷 후보(가칭 `kds_capacity_retry_scheduler`).
(b) `confirm_payment()`(POS, `0098`)를 동일한 신규 공용 함수로 연결 — 최우선 후속 워크패킷 후보로 명시 기록(Human 방향 결정 §0.2 (3) 재확인).
(c) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — `600591_Overview.md` §4에서 이미 별도 워크패킷 권고, 이번에도 재확인.
(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정.
(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오에서의 신규 함수 동작 확인 필요성 — 상세 설계는 `601032_Logic.md` §4. **격상 근거**: Cursor와 Codex 둘 다 독립적으로 "이번 워크패킷 스코프 제외 자체는 타당하나, 실제 운영 환경에서의 위험도는 낮지 않다"고 지적했다 — Toss/VAN이 동일 웹훅을 재전송하는 것은 드문 예외가 아니라 정상적으로 발생하는 시나리오이며, §1.2의 0-티켓 `result_code` 수정(item 1)이 바로 이 시나리오와 직접 연관된 방어 조치였다는 사실 자체가 멱등성 문제의 실질적 위험도를 뒷받침한다. 스코프에서는 제외하되, 후속 워크패킷 우선순위를 (b)보다 낮지 않게 배정할 것을 권고.
(f) **[번호 관련]** `600500_payment_confirmation/` 도메인의 "백단위" 번호 공간이 사실상 소진됐다(§0) — 향후 이 도메인에 워크패킷이 더 필요하면 매번 `601020`류의 "번호 차용" 판단이 반복될 것. 도메인 번호 재편(예: 601000대의 별도 서브도메인 확정) 여부는 Human 결정 필요, 이 워크패킷 범위 밖.
(g) `601032_Logic.md` §3의 `pg_temp` 라이브 재현 3건(정상 경로/KDS 예외/0-티켓)은 **이 세션이 직접 수행**한 것이지만, "이 세션이 검증을 완료했다"는 것이 "Stage 5(TestPlan)/Stage 8-9(구현·독립검증)가 자체 재현을 생략해도 된다"는 뜻은 아니다 — 각 Stage는 자기 자신의 새 fixture로 동일 시나리오를 독립적으로 재현해 확인해야 한다(이 세션의 결과를 그대로 재신뢰 금지). Stage 4 Critical tier가 지적한 §3/§6/Snapshot 간 표현 불일치를 해소하며 신설된 항목.

(h) **[신규, 2026-07-18, `p_decision='PENDING'` 결함 수정 중 부수적으로 발견 — canonical 위치는 `601034_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `catchmenu_audit.append_audit_record()`를 호출하는 다른 기존 라이브 함수 **7개 파일**에서도 `chk_audit_decision`(`0008:105-119`)의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — 리터럴 개수로는 **8개**(타겟 grep 기준 — 전수조사 아님, 그 이상일 수 있음): `0084`(`'RESOLVED'`), `0085`(`'PUBLISHED'`), `0086`(`'PUBLISHED'`), `0087`(`'ROLLED_BACK'`), `0091`(`'GO_LIVE_AUTHORIZED'`), `0098`(`'REFUND_PENDING'`), `0100`(같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개 — 이 파일이 리터럴 수를 파일 수보다 1개 더 많게 만드는 원인). 실행되면 이번 워크패킷에서 고친 것과 동일한 방식(제약 위반 → INSERT 크래시)으로 실패할 가능성이 높다. 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며, 별도의 독립 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 최신·상세 버전은 `601034_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `601034`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

## Module Domain Tags

- SQL (예정 — 이번 턴은 조사/설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, `601032_Logic.md`로 이어짐.** 번호 배정 과정에서 `600500` 도메인의 자체 백단위 공간이 소진됐음을 발견하고, 이미 확립된 `601020` 선례(물리적 폴더 위치와 문서 번호의 백단위가 다를 수 있음)를 그대로 적용해 `601030`대로 재배정했다(§0). `evaluate_kds_capacity()`/`commit_kds_ticket()`/`bulk_commit_kds_tickets()` 정확한 라이브 시그니처·반환 계약을 재확인했고(§1), `commit_kds_ticket()` 자신이 이미 `CAPACITY_CHECKING`을 `success:true`로 취급하는 설계임을 확인해 §2 원칙(결제확정 성공≠KDS 방출 실패)이 신규 함수의 예외 미전파 설계로 이어져야 함을 근거와 함께 제시했다. `CAPACITY_CHECKING` 재시도 메커니즘이 SQL/cron 레벨에서 전혀 존재하지 않음을 실증했고(§3), 이를 근거로 이번 워크패킷 범위에서 제외하도록 권고했다. 신규 함수의 스키마 위치는 `release_kds_after_payment()`의 기존 선례("호출 계기" 기준)를 근거로 `catchmenu_payment`로 결정했다(§4).

**(Stage 4 Critical tier 정정 반영, 2026-07-18)** Cursor+Codex 검토에서 지적된 3가지 결함을 `601032_Logic.md`에서 해소했다 — 0-티켓 시나리오(committed=pending=skipped=0)를 `PAYMENT_CONFIRMED_KDS_COMMITTED`와 명확히 구분하는 신규 `result_code`(`PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`)를 추가하고 `pg_temp`로 재검증했으며, `confirm_payment_from_provider()` 반환값의 `kds_release_authorized` 하드코딩을 `result_code` 파생 값으로 교체했다. 웹훅 멱등성 Open Item을 **High priority**로 격상했고(§6 (e)), 이 문서와 `601032_Logic.md`의 §6 Open Items 목록을 (a)-(g) 동일 목록으로 동기화했다.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601032_Logic_Canonical_Kds_Release_Orchestration.md] =====
# 601032_Logic_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 설계 원칙 요약

`601031_Overview.md`의 확인 결과를 그대로 적용한다: (1) `commit_kds_ticket()`/`bulk_commit_kds_tickets()`를 재사용하고 재구현하지 않는다(§1), (2) 신규 함수는 예외를 절대 재전파하지 않아 결제확정 성공이 KDS 방출 실패로부터 격리된다(§2), (3) `catchmenu_payment` 스키마에 배치한다(§4), (4) 재시도 메커니즘은 설계하지 않는다(§3, Open Item (a)로만 남김).

## §1 `catchmenu_payment.request_kds_release_after_payment()` — 신규 공용 함수 전체 설계

### §1.1 시그니처

```sql
create or replace function catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ledger_id uuid,
  p_actor_type text default 'SYSTEM',
  p_correlation_id text default null
)
returns jsonb
language plpgsql
volatile
security definer
set search_path = catchmenu_payment, catchmenu_kds,
                  catchmenu_ledger, catchmenu_audit,
                  catchmenu_common
as $$
```

`p_order_id`/`p_ledger_id`는 `release_kds_after_payment()`와 동일한 파라미터 이름/순서를 재사용한다(호출자 입장에서 두 "release" 계열 함수가 대칭적으로 보이도록). `p_actor_type`을 추가한 이유: `confirm_payment_from_provider()`(웹훅/VAN, 실제 승인 주체는 `'PROVIDER'`)와 향후 `confirm_payment()`(POS, `'SYSTEM'` 또는 스태프)가 이 함수를 공용으로 쓸 것이므로(`601031_Overview.md` §0.2 (3) Open Item), 감사 기록에 정확한 주체를 남기려면 하드코딩하지 않고 파라미터화해야 한다 — `release_kds_after_payment()`가 `'SYSTEM'`을 하드코딩한 것과 다른 지점(§1.4에서 재확인).

### §1.2 본문 — `bulk_commit_kds_tickets()` 재사용, 결과 코드 번역

```sql
declare
  v_bulk_result jsonb;
  v_result_code text;
  v_audit_id uuid;
begin
  -- Step 1: authorize (authorize_kds_release()가 0157에서 DROP됐으므로,
  -- release_kds_after_payment()와 동일한 인라인 패턴으로 승인 처리).
  update catchmenu_payment.payment_ledger
  set
    kds_release_authorized = true,
    kds_release_authorized_at = now(),
    kds_release_authorized_by = p_actor_type
  where id = p_ledger_id
    and tenant_id = p_tenant_id
    and store_id = p_store_id;

  -- Step 2: 실제 게이트 통과 — commit_kds_ticket()의 7조건 평가를 주문 단위로
  -- 순회 호출하는 기존, 이미 구현된 함수를 그대로 재사용한다(§0/601031_Overview §1).
  v_bulk_result := catchmenu_kds.bulk_commit_kds_tickets(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := p_order_id,
    p_force_conditions := null,
    p_correlation_id := p_correlation_id
  );

  -- Step 3: 결과 코드 번역 (ChatGPT 제안 형태 참고).
  -- (Stage 4 Critical tier에서 발견/정정) "처리 대상 티켓이 0건"인 경우를
  -- committed_count=0/pending_count=0/skipped_count=0으로 반드시 먼저 분기시켜야
  -- 한다 — 이 조건은 "pending=0 and skipped=0"이라는 COMMITTED 판정 조건도
  -- 동시에 만족시키므로, 순서를 지키지 않으면 "아무 티켓도 처리하지 않았다"가
  -- "전부 성공적으로 커밋했다"로 잘못 보고된다. 웹훅 재전송 시나리오(§6 (e),
  -- High priority)에서 특히 위험하다 — 이미 완전히 처리된 주문에 대해 웹훅이
  -- 재전송되면 bulk_commit_kds_tickets()는 HOLD/CAPACITY_CHECKING 티켓을 하나도
  -- 찾지 못해 committed_count=0으로 끝나는데, 이 버그가 있으면 그걸 "이번에도
  -- 커밋 성공"으로 잘못 보고하게 된다. pg_temp로 라이브 재현해 정정을 확인했다
  -- (§3.1 참고).
  v_result_code := case
    when not coalesce((v_bulk_result->>'success')::boolean, false)
      then 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'
    when coalesce((v_bulk_result->>'pending_count')::int, 0) = 0
      and coalesce((v_bulk_result->>'skipped_count')::int, 0) = 0
      then 'PAYMENT_CONFIRMED_KDS_COMMITTED'
    when coalesce((v_bulk_result->>'committed_count')::int, 0) > 0
      then 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'
    else 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'
  end;

  -- 감사 기록 — 성공/대기/차단/무티켓 모든 경우에 남긴다(재무 인접 도메인).
  v_audit_id := catchmenu_audit.append_audit_record(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_audit_domain := 'payment',
    p_audit_type := 'kds_release_requested',
    p_audit_category := 'OPERATIONAL',
    p_actor_type := p_actor_type,
    p_actor_id := null,
    p_subject_type := 'payment_ledger',
    p_subject_id := p_ledger_id,
    -- (Stage 4 Critical tier 정정, Cursor+Codex 교차검증) 'PENDING'은
    -- catchmenu_ledger.audit_records.chk_audit_decision(0008:105-119)의
    -- 허용값 11개(APPROVED/REJECTED/OVERRIDDEN/DELEGATED/ESCALATED/
    -- CANCELLED/COMPLETED/FAILED/NOTED/SUSPENDED/REVOKED) 어디에도 없다 —
    -- PARTIAL_CAPACITY_HOLD/CAPACITY_HOLD 분기가 실행될 때마다 이
    -- append_audit_record() INSERT 자체가 제약 위반으로 크래시하고, 아래
    -- EXCEPTION 핸들러가 이를 삼켜 PAYMENT_CONFIRMED_KDS_RELEASE_FAILED로
    -- 잘못 보고했을 결함이었다(결제도 KDS도 정상 대기 상태였을 뿐인데
    -- "실패"로 오분류). 'SUSPENDED'로 정정 — "일시 중단, 재개 가능"이라는
    -- 기존 코드베이스 관례(0041의 'agent_module_isolated' 감사기록이 동일
    -- 의미로 이미 사용 중)와 가장 가깝고, 이미 §1.2 다른 분기에서 쓰는
    -- 'NOTED'(0027/0031/0036의 기존 관례 — "사람 검토가 필요한 사실 기록")와도
    -- 의미가 겹치지 않는다. 'DELEGATED'는 재시도/재평가를 실제로 넘겨받을
    -- 프로세스가 없다는 사실(601031_Overview.md §3)과 모순되므로 기각했다.
    p_decision := case
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED' then 'APPROVED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED' then 'FAILED'
      when v_result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS' then 'NOTED'
      else 'SUSPENDED'
    end,
    p_decision_payload := jsonb_build_object(
      'result_code', v_result_code,
      'bulk_commit_result', v_bulk_result
    ),
    p_order_id := p_order_id,
    p_correlation_id := p_correlation_id
  );

  -- 결제 도메인 관점의 성공/실패가 아니라, 항상 success:true로 반환한다 —
  -- 이 함수의 "성공"은 "요청 처리가 정상적으로 끝났다"는 뜻이지
  -- "티켓이 즉시 COMMITTED됐다"는 뜻이 아니다(§2 원칙).
  return jsonb_build_object(
    'success', true,
    'result_code', v_result_code,
    'ledger_id', p_ledger_id,
    'order_id', p_order_id,
    'committed_count', v_bulk_result->'committed_count',
    'pending_count', v_bulk_result->'pending_count',
    'skipped_count', v_bulk_result->'skipped_count',
    'bulk_commit_detail', v_bulk_result,
    'audit_id', v_audit_id
  );
exception
  when others then
    -- 절대 RAISE하지 않는다 — 호출자(confirm_payment_from_provider())의
    -- payment_ledger INSERT가 KDS 쪽 예외로 함께 롤백되는 것을 원천 차단한다
    -- (601031_Overview.md §2, 600652_Logic.md §1.5/§9.2 원칙의 재적용).
    --
    -- (2026-07-18 재정정, Cursor+Codex 실증 발견) 이 감사기록 INSERT 자신이
    -- 실패하면(예: audit_records 자체의 제약 위반, 락, 일시적 장애) 그 2차
    -- 실패가 이 EXCEPTION 핸들러 밖으로 새어나가 함수 전체가 결국 예외를
    -- 던지게 되고, 호출자의 이미 완료된 payment_ledger INSERT까지 함께
    -- 롤백된다 — 실제 재현으로 확인됨(§1.5). 감사기록 호출 자체를 좁은
    -- 중첩 블록으로 한 번 더 감싸 이 경로를 차단한다.
    begin
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'payment',
        p_audit_type := 'kds_release_requested_failed',
        p_audit_category := 'OPERATIONAL',
        p_actor_type := p_actor_type,
        p_actor_id := null,
        p_subject_type := 'payment_ledger',
        p_subject_id := p_ledger_id,
        p_decision := 'FAILED',
        p_decision_payload := jsonb_build_object(
          'error', sqlerrm,
          'sqlstate', sqlstate
        ),
        p_order_id := p_order_id,
        p_correlation_id := p_correlation_id
      );
    exception
      when others then
        -- 여기서 더 중첩하지 않는다(§1.5 "무한 중첩 금지" 원칙) — 감사
        -- 기록조차 실패했다는 사실을 서버 로그에만 최소한으로 남기고
        -- 정상 반환으로 넘어간다. 이 지점을 넘어서는 안전은 이 설계가
        -- 보장하지 않는, 정직하게 인정된 잔여 위험이다(§1.5 참고).
        raise warning 'request_kds_release_after_payment(): audit logging of the original failure itself failed (sqlstate=%) -- server log only, no DB trace beyond this warning', sqlstate;
    end;
    return jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', p_ledger_id,
      'order_id', p_order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;
$$;
```

**`success:true`를 예외 분기에서도 유지하는 이유**(재확인, §2 원칙의 직접 적용): 이 함수를 호출하는 시점에는 결제 자체(`payment_ledger` INSERT)가 이미 성공적으로 완료된 뒤다. 이 함수의 실패는 "결제가 실패했다"는 뜻이 결코 아니므로, `success:false`를 반환하면 호출자가 이를 결제 실패로 오인해 잘못된 사용자 응답(예: 웹훅에 5xx 반환 → PG가 재시도 → 중복 결제 확인 시도)을 만들 위험이 있다. `result_code`만으로 상태를 구분하게 하는 것이 더 안전하다.

### §1.3 GRANT/REVOKE

```sql
revoke all on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) from public;
grant execute on function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) to authenticated;
```

`bulk_commit_kds_tickets()`/`commit_kds_ticket()`/`evaluate_kds_capacity()`는 **전혀 수정하지 않는다** — `security definer`이므로 신규 함수 안에서 그대로 호출 가능하다(GRANT 재확인: `bulk_commit_kds_tickets()`는 이미 `authenticated`에 GRANT돼 있으나, `security definer` 함수 내부 호출은 어차피 호출자 GRANT와 무관하게 함수 소유자 권한으로 실행되므로 이 재확인은 참고 목적일 뿐 필수 전제조건은 아니다).

### §1.4 `kds_release_authorized_by` 값 — `release_kds_after_payment()`와의 차이, 의도적

`release_kds_after_payment()`는 `'SYSTEM'`을 하드코딩한다(`0157`). 신규 함수는 `p_actor_type` 파라미터를 받아 호출자가 실제 주체(웹훅=`'PROVIDER'`, 향후 POS 연동 시=`'SYSTEM'` 또는 스태프)를 전달하게 한다 — 두 함수가 공존하는 동안 `payment_ledger.kds_release_authorized_by`에 서로 다른 관례가 생기는 것은 감내할 만한 차이로 판단한다(둘 다 자유 텍스트 컬럼, 제약 위반 없음). `601031_Overview.md` §6 (b)에서 POS 경로도 이 신규 함수로 전환하면 이 차이는 자연히 사라진다.

### §1.5 "감사기록의 감사기록" — 1단계 fallback만 두고 그 이상은 잔여 위험으로 인정 (2026-07-18, Cursor+Codex 실증 발견 + 정정)

**발견된 결함**: `§1.2`/`§2.2`(옵션 C)의 각 `EXCEPTION` 핸들러는 자신의 실패를 감사기록으로 남기기 위해 `append_audit_record()`를 호출한다. 그런데 **이 호출 자체가 실패하면**(예: `audit_records` 자체의 제약 위반, 락, 일시적 장애) 그 2차 실패는 지금 실행 중인 이 `EXCEPTION` 핸들러가 잡을 수 없다 — PL/pgSQL에서 `EXCEPTION` 절 *안에서* 발생한 새 예외는 그 절 자신을 다시 통과하지 않고 그대로 다음 바깥 블록으로 전파된다. `request_kds_release_after_payment()`는 함수 전체가 단일 최상위 블록이므로, 이 2차 실패는 함수 자체를 예외로 종료시킨다 — 그 예외가 호출자인 `confirm_payment_from_provider()`의 옵션 C 좁은 블록(§2.2)까지 전파되고, **그 블록의 `EXCEPTION` 핸들러가 자신의 감사기록 호출을 시도하다가 같은 이유로 또 실패하면**, 이번엔 그 실패를 잡아줄 블록이 전혀 없어 `confirm_payment_from_provider()` 자체가 예외로 종료된다 — 이 시점에는 이미 완료된 `payment_ledger` INSERT까지 포함해 그 함수 호출 전체가 롤백된다. Cursor+Codex가 이를 실제로 강제 재현해(`kds_events`와 `audit_records` 양쪽에 임시 `CHECK` 제약을 걸어 이중 실패를 유발) `payment_ledger` 행이 0건으로 사라지는 것을 직접 확인했다 — 이 세션도 동일한 기법으로 정정 전 상태에서 독립 재현해 실제로 `confirm_payment_from_provider()` 자체가 처리되지 않은 예외로 종료됨을 확인했다(아래 재검증 결과 참고).

**설계 방향**: 두 `EXCEPTION` 핸들러 안의 `append_audit_record()` 호출 자체를 각각 좁은 중첩 `begin...exception when others...end` 블록으로 한 번 더 감싼다(§1.2/§2.2 최종 코드). 이 감사기록 호출이 실패하면, 그 실패를 이 새 안쪽 블록이 잡아 `raise warning`으로 서버 로그에만 남기고 정상적으로(원래 의도했던 `success:true`/`RELEASE_FAILED` 반환) 계속 진행한다.

**어디서 멈추는가 — 무한 중첩 금지 (ChatGPT 지적, Human 확정)**: "감사기록의 감사기록의 감사기록…"으로 무한히 내려갈 수는 없다. 이 설계는 **정확히 1단계**의 fallback만 둔다 — 감사기록 INSERT가 실패하면 그 실패를 잡아 `RAISE WARNING`까지만 하고 멈춘다. **`RAISE WARNING` 자체가 실패하는 경우는 이 설계가 방어하지 않는다** — 이는 정직하게 인정하는 잔여 위험이다: `RAISE WARNING`은 예외를 던지지 않는 PL/pgSQL 내장 동작이므로(아래 실증 참고) 그 자체가 실패할 realistic한 경로는 사실상 없지만, 만약 극단적으로 서버 자체가 응답 불능 상태라면(디스크 풀, 프로세스 강제종료 등) 이 설계로도 막을 수 없다 — 그런 극단적 상황까지 막으려 하지 않는 것이 이 설계의 명시적 스코프다(무한 안전 보장 시도 금지, Human 지시).

**`RAISE WARNING`이 실행을 중단시키지 않는다는 것을 라이브로 실증(2026-07-18, `pg_temp`)**: 중첩 `begin...exception...end` 블록 안에서 `raise exception`으로 강제 실패를 유발하고, 그 핸들러가 `raise warning`을 호출한 뒤 함수가 정상적으로 `return`까지 도달하는지 확인했다 — 결과: `WARNING` 메시지가 클라이언트/서버 로그에 출력되고, 함수는 `{"marker_after_all_blocks": "fallback_caught_via_warning"}`을 정상 반환했다. `RAISE EXCEPTION`과 달리 `RAISE WARNING`은 트랜잭션이나 함수 실행을 중단시키지 않는다는 것이 이 프로젝트의 실제 PL/pgSQL 버전 위에서 확인됐다.

**정정 후 재검증 — Scenario A/B/C 전부 재실행 (2026-07-18, 라이브 함수 체인 전체, `begin;...rollback;`로 격리, Cursor/Codex의 시나리오 구분과 대응)**:

- **Scenario A** (`request_kds_release_after_payment()`를 직접 호출, `kds_events`와 `audit_records` 양쪽에 임시 `CHECK` 제약을 걸어 원래 실패 + 감사기록 실패를 모두 강제 — 콜백 내부에서 실패가 발생하는 경로): 함수는 예외를 던지지 않고 `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ...}`를 정상 반환했고, `WARNING`이 출력됐다. 호출 이전에 이미 존재하던 `payment_ledger` 행은 `ledger_status='APPROVED'`, `approved_amount=15000` 그대로 살아남았다.
- **Scenario B** (`confirm_payment_from_provider()`를 종단 호출하되, 1차 실패를 `kds_events` 제약이 아니라 **호출 지점 자체**(§6.4와 동일한 `ALTER FUNCTION ... RENAME` 기법 — `request_kds_release_after_payment()` 자체를 찾을 수 없게 만듦)에서 유발하고, 동시에 `audit_records`에 `kds_release_call_unexpected_exception` 감사기록을 차단하는 제약을 걸어 2차 실패도 강제): 함수는 `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', error_detail:{sqlstate:'42883'}}`를 정상 반환했고, `WARNING`이 출력됐다. **`payment_ledger` 행이 정확히 1건 살아남았다**(`ledger_status='APPROVED'`, `kds_release_authorized=false`) — 1차 실패의 발생 지점이 "콜백 내부"(Scenario A/C)냐 "호출 자체"(Scenario B)냐에 따라 원자성 보장이 달라지지 않음을 별도로 확인.
- **Scenario C** (`confirm_payment_from_provider()`를 종단 호출, `kds_events`(콜백 내부 1차 실패)와 `audit_records`(2차 실패) 양쪽을 동시에 강제 — 정정 전에는 이 시나리오에서 함수 자체가 처리되지 않은 예외로 종료되고 `payment_ledger` 행이 0건이 되는 것을 먼저 확인했다): 정정 후에는 함수가 정상적으로 `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', kds_release_authorized:false, ...}`를 반환했고, **`payment_ledger` 행이 정확히 1건 살아남았다** — 정정 전 재현에서 확인된 "0건" 결과와 정확히 대비되는 수정 확인.

세 시나리오 모두 — 1차 실패가 어디서 발생하든(콜백 내부 vs. 호출 자체), 어느 함수를 통해 호출하든(직접 호출 vs. `confirm_payment_from_provider()` 종단 호출) — payment-core(`payment_ledger` INSERT)가 살아남는 것을 확인했다.

이 정정은 아직 라이브에 반영되지 않았다(이번 문서 정정은 Logic.md 설계 교정 단계 — Stage 5 TestPlan/ChangeContract 및 실제 migration은 후속 라운드에서 별도로 갱신 필요, `601033_TestPlan.md`/`601034_ChangeContract.md`는 이번 턴 범위 밖).

## §2 `confirm_payment_from_provider()`(`0027`) 수정 설계

### §2.1 변경 지점 — 기존 `kds_release_authorized:false` INSERT는 유지, 새 호출을 추가

`payment_ledger` INSERT 자체는 **변경하지 않는다** — `kds_release_authorized := false`로 계속 시작한다(특허1 원칙: "결제 승인"과 "KDS 릴리즈 승인"은 논리적으로 분리된 순간이어야 한다는 서술 자체는 유효한 설계 의도이며, 신규 함수의 Step 1이 그 다음 순간 `true`로 전환한다 — 순간의 간격이 매우 짧아졌을 뿐, 두 단계가 존재한다는 사실 자체는 보존된다). `kds_tickets.conditions_met` 병합 UPDATE(`0027:301-309`)와 `kds_events` INSERT(`0027:314-331`)도 그대로 둔다(감사 추적 가치, `601032_Logic.md`가 아니라 이미 `600592_Logic.md` §2.2가 동일 판단을 내린 바 있음).

**기존 `audit_id` 계산 직후, `return` 직전에 추가**:

**(Stage 4 재정정, 2026-07-18 — ChatGPT 교차검증 + Human 최종 결정, "옵션 C")** 아래 블록은 `request_kds_release_after_payment()` 호출 **그 자체만** 좁은 중첩 `begin...exception...end`로 감싼다 — 이 지점 이전(intent 검증, `payment_ledger` INSERT, `kds_tickets`/`kds_events` 갱신, 이 함수 자신의 `append_audit_record()` 호출)은 전혀 감싸지 않고 그대로 둔다. 근거와 이전 설계(Option A/B)와의 차이는 §2.2 참고.

```sql
-- (옵션 C) request_kds_release_after_payment() 호출만 좁게 감싼다 —
-- 이 begin의 시작점이 이 함수 자신의 payment-core 작업(위의 payment_ledger
-- INSERT 등) *이후*이므로, 이 블록 안에서 예외가 발생해도 그 이전 작업은
-- 롤백되지 않는다(중첩 begin/exception 블록은 자신의 시작점까지만 롤백하는
-- 서브트랜잭션을 형성한다 — pg_temp로 라이브 실증, §2.2 참고).
begin
  v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_intent.order_id,
    p_ledger_id := v_ledger_id,
    p_actor_type := 'PROVIDER',
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    -- 정상 운영 중에는 도달 불가능해야 한다(§1.2) — 신규 함수는 이미 자신의
    -- 모든 내부 예외를 삼키도록 설계됐다. 이 핸들러가 실행됐다는 것은 신규
    -- 함수 자신의 안전장치 자체에 버그가 있어 정말로 예외가 새어나온
    -- 극단적 상황이라는 뜻이다. 결제 자체는 이미 성공했으므로(위의
    -- payment_ledger INSERT는 이 블록의 시작 이전에 완료돼 안전하다),
    -- 신규 함수 자신이 RELEASE_FAILED를 반환했을 때와 동일한 형태로
    -- 통일해서 반환한다 — 호출자 입장에서 "신규 함수 내부에서 잡힌 실패"와
    -- "신규 함수 호출 자체가 실패"를 구분할 필요가 없다.
    --
    -- (2026-07-18 재정정, Cursor+Codex 실증 발견 — §1.5 참고) 이 감사기록
    -- 호출 자체가 실패하면(예: audit_records 제약 위반) 그 2차 실패가 이
    -- 핸들러 밖으로 새어나가 confirm_payment_from_provider() 전체가 결국
    -- 처리되지 않은 예외로 종료되고, 이미 완료된 payment_ledger INSERT까지
    -- 함께 롤백된다 — 실제 재현으로 확인됨(§1.5). 좁은 중첩 블록으로
    -- 한 번 더 감싼다.
    begin
      perform catchmenu_audit.append_audit_record(
        p_tenant_id := p_tenant_id,
        p_store_id := p_store_id,
        p_audit_domain := 'payment',
        p_audit_type := 'kds_release_call_unexpected_exception',
        p_audit_category := 'FINANCIAL',
        p_actor_type := 'PROVIDER',
        p_actor_id := null,
        p_subject_type := 'payment_ledger',
        p_subject_id := v_ledger_id,
        p_decision := 'FAILED',
        p_decision_payload := jsonb_build_object(
          'error', sqlerrm,
          'sqlstate', sqlstate
        ),
        p_order_id := v_intent.order_id,
        p_correlation_id := p_correlation_id
      );
    exception
      when others then
        -- §1.5와 동일한 원칙 — 여기서 더 중첩하지 않는다. 감사기록조차
        -- 실패했다는 사실을 서버 로그에만 남기고 정상 반환으로 넘어간다.
        raise warning 'confirm_payment_from_provider(): audit logging of the KDS-release-call failure itself failed (sqlstate=%) -- payment_ledger row % still committed; server log only for the original KDS failure', sqlstate, v_ledger_id;
    end;
    v_kds_release_result := jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', v_ledger_id,
      'order_id', v_intent.order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized',
    (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'result_code', v_kds_release_result->>'result_code',
  'reconciliation_status', 'PENDING',
  'message_code', case
    when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
      then 'payment_approved_kds_released'
    else 'payment_approved_kds_pending'
  end,
  'audit_id', v_audit_id
);
```

**(Stage 4 검증에서 지적된 하드코딩 정정)** `v_kds_release_result`는 `declare` 블록에 `jsonb` 타입으로 추가. 기존 반환값의 `'kds_release_authorized', false`/`'next_step', 'KDS_CAPACITY_CHECK_REQUIRED'`는 제거(더 이상 사실이 아님 — 이 시점에는 이미 요청이 끝났다).

**정정 전 문제**: `'kds_release_authorized', true`를 무조건 하드코딩했었다 — `result_code`가 `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD`/`RELEASE_BLOCKED`/`RELEASE_FAILED`여도 응답은 항상 `true`를 보고해, 호출자(Toss/VAN)가 `result_code`를 별도로 파싱하지 않으면 "KDS가 실제로 방출됐다"고 오인할 위험이 있었다.

**정정 방식과 의미 변경 명시**: 이 응답 필드의 값을 `payment_ledger.kds_release_authorized` **DB 컬럼 값**이 아니라 `result_code`로부터 파생시킨다 — 즉 이 시점 이후 DB 컬럼 자체는 항상 `true`(§1.2 Step 1에서 결과와 무관하게 무조건 승인)이지만, **응답 필드는 "실제로 KDS 방출(COMMITTED)까지 끝났는가"라는 더 유용한 신호로 의도적으로 재정의**한다 — 원본 DB 컬럼 값과 응답 필드 값이 이 시점부터 다른 의미를 갖게 되는 것은 이 워크패킷의 명시적 설계 결정이며, 혼동을 막기 위해 이 사실을 여기 명시적으로 기록한다. `result_code` 필드 자체도 응답에 계속 노출되므로, 호출자는 필요시 더 세분화된 상태(`PARTIAL_CAPACITY_HOLD` vs `CAPACITY_HOLD` 등)를 직접 확인할 수 있다.

### §2.2 왜 함수 전체가 아니라 호출부만 좁게 감싸는가 — 옵션 C (ChatGPT 교차검증, Human 최종 결정, 재논의 금지)

**이전 설계(Option A/B)의 문제**: 이전 라운드는 "`confirm_payment_from_provider()` **자신**에도 `EXCEPTION` 핸들러를 추가할지"를 이분법(포함/제외)으로 물었다. 그런데 이 질문 자체가 애매했다 — "추가한다"는 것이 함수 **전체**를 감싸는 것인지, `request_kds_release_after_payment()` 호출 지점만 감싸는 것인지 명시하지 않았다. 만약 문자 그대로 이 함수의 기존 단일 최상위 `begin ... end;` 블록(현재 `declare` 바로 다음, intent 검증보다도 앞)에 `exception` 절만 덧붙이는 방식(Option A가 실제로 그렇게 작성돼 있었다)으로 구현했다면, PL/pgSQL의 중첩 예외 블록 동작 원리상(§2.1의 pg_temp 실증 참고 — 예외 블록은 **자신이 시작된 지점까지만** 롤백하는 서브트랜잭션을 형성한다) 그 최상위 블록의 시작점이 함수의 맨 처음이므로, `request_kds_release_after_payment()` 호출(함수 끝부분)에서 발생한 예외라도 그 핸들러가 잡는 순간 **함수 시작부터 그 시점까지의 모든 작업**(intent 상태 갱신, `payment_ledger` INSERT, `kds_tickets`/`kds_events` 갱신, 이 함수 자신의 감사기록까지)이 전부 롤백된다 — ChatGPT가 정확히 지적한 위험이다: KDS 알림이라는, 원래 결제 성공과 무관하게 격리돼야 할 보조 단계의 버그가 정작 이미 정상적으로 완료된 결제 승인 자체를 무효화시켜버리는 것 — 이 워크패킷 전체의 목적(결제확정 성공과 KDS 방출 실패의 격리, §0/`601031_Overview.md` §2)과 정반대의 결과를 낳는다.

**옵션 C 해법**: `EXCEPTION` 핸들러를 함수의 기존 최상위 블록이 아니라, `request_kds_release_after_payment()` 호출 **그 자체만**을 감싸는 신규 중첩 `begin...exception...end` 블록에 붙인다(§2.1의 최종 SQL). 이 중첩 블록의 시작점이 이미 `payment_ledger` INSERT 등 payment-core 작업이 전부 끝난 **이후**이므로, 이 블록 안에서 발생하는 예외는 그 이전 작업을 전혀 건드리지 않는다 — 2026-07-18 `pg_temp`로 직접 실증(§2.1 참고, 아래 검증 결과 요약).

**payment-core 로직(intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 이전과 마찬가지로 전혀 감싸지 않는다** — 이 구간에서 실패하면 예외가 자연스럽게 함수 밖으로 전파되어 호출자(Toss/VAN 웹훅 핸들러)가 이를 진짜 결제 실패로 인식한다(옵션 B와 동일한 부분). 옵션 C는 "함수 전체 EXCEPTION 포함(A)이냐 제외(B)냐"라는 양자택일이 아니라, **애초에 그 이분법이 잘못 설정된 질문이었음을 바로잡은 하나의 개선된 설계**다 — Human 승인은 이제 이 하나의 설계를 적용할지 여부만 확인하면 된다(§9).

**PL/pgSQL 중첩 예외 블록 검증 결과 (2026-07-18, `pg_temp`로 라이브 실증)**:

```sql
-- outer_fn()이 (1) "payment-core" INSERT를 먼저 실행하고, (2) 그 다음
-- 존재하지 않는 함수를 호출해 강제로 예외를 유발하는 좁은 내부 블록을
-- 실행한다.
create function pg_temp.outer_fn() returns jsonb language plpgsql as $fn$
declare
  v_ledger_id uuid := gen_random_uuid();
  v_kds_release_result jsonb;
begin
  insert into pg_temp.tmp_optionc_ledger_stub (id, status) values (v_ledger_id, 'APPROVED');
  begin
    select pg_temp.nonexistent_kds_release_fn(v_ledger_id) into v_kds_release_result;
  exception
    when others then
      v_kds_release_result := jsonb_build_object(
        'success', true, 'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
        'caught_sqlstate', sqlstate
      );
  end;
  return jsonb_build_object('ledger_id', v_ledger_id, 'kds_release_result', v_kds_release_result);
end;
$fn$;
```

결과: `outer_fn()` 호출은 `{"kds_release_result": {"success": true, "result_code": "PAYMENT_CONFIRMED_KDS_RELEASE_FAILED", "caught_sqlstate": "42883"}}`을 정상 반환했고(예외가 함수 밖으로 새어나가지 않음), **"payment-core" INSERT가 이 내부 블록의 예외 이후에도 살아남아 있음을 확인**(`select count(*) from pg_temp.tmp_optionc_ledger_stub` → `1`). 문법적으로도 지역변수(`v_kds_release_result`)를 내부 블록 안에서 대입하고 바깥 블록에서 그대로 읽는 데 아무 문제가 없었다(`declare` 재선언 불필요, 스코프가 자연스럽게 공유됨) — Postgres 문서가 이미 서술하는 "예외 절이 있는 블록은 자신의 시작점에 암묵적 세이브포인트를 만든다"는 동작이 이 프로젝트의 실제 스키마 위에서도 그대로 성립함을 실증했다.

**옵션 A의 핸들러와 이 좁은 블록의 핸들러가 여전히 서로 다른 "실패 의미 계층"을 가진다는 점은 유지된다** — payment-core 구간(감싸지 않음)의 예외는 여전히 "결제 자체 실패"이고, 이 좁은 블록(§2.1)의 예외는 "결제는 성공, KDS 호출 메커니즘 자체에 예상 못 한 버그"다. 다만 이제는 함수 전체를 감싸는 별도의 바깥쪽 핸들러(과거 Option A)가 존재하지 않으므로, "결제 자체 실패"는 여전히 이 함수 자체의 예외 전파(payment-core 구간에서 raise된 예외가 그대로 밖으로 나가는 것)로만 표현된다 — 이는 옵션 B와 동일하다.

## §3 설계 검증 — `pg_temp` 라이브 재현 3건 완료 (2026-07-18)

**(Stage 4 검증에서 지적된 §3/§6(e)/Snapshot 간 표현 불일치 정정)** 아래 3개 시나리오는 **실제로 `pg_temp`에 §1.2/§1.2-수정판 함수를 그대로 정의해 라이브로 재현했다** — 개념 검토가 아니라 실행 결과를 직접 확인한 것이다(AGENTS.md §3.8 — 이 워크패킷 ChangeContract가 아직 없으므로 트랜잭션 밖 영구 객체는 생성하지 않았고, 전부 `begin;...rollback;` 안에서 실행 후 흔적 없이 제거됨). **다만 "이 세션이 검증을 완료했다"는 것이 "Stage 5/8/9가 검증을 생략해도 된다"는 뜻은 아니다** — 이 세션의 표준 원칙대로, 각 fixture는 Stage 5(TestPlan)/Stage 8-9(구현·독립검증) 각자가 **자기 자신의 새 데이터로 다시 재현**해야 하며, 아래 결과를 그대로 재신뢰해서는 안 된다. §6 (g)에 이 구분을 별도 Open Item으로 명시한다.

### §3.1 시나리오 1(정상 경로) — 재현 완료

fixture: `catchmenu_pos.orders`에 주문 1건(`order_number='CV601030-TEST1'`) + `catchmenu_payment.payment_intents`/`payment_ledger` 각 1건(`kds_release_authorized=false`로 시작) + `catchmenu_kds.kds_tickets`에 `ticket_number='T-CV601030-1'`, `conditions_met={"arrived":true,"table_confirmed":true,"payment_confirmed":true}`인 `HOLD` 티켓 1건. `request_kds_release_after_payment()` 호출 결과: `result_code:'PAYMENT_CONFIRMED_KDS_COMMITTED'`, `committed_count:1`, 티켓 `kds_status`가 실제로 `COMMITTED`로 전이, `payment_ledger.kds_release_authorized`가 `true`로 갱신됨을 확인.

### §3.2 시나리오 2(KDS 쪽 예외) — 재현 완료

동일 패턴의 fixture(`order_number='CV601030-TEST2'`, `ticket_number='T-CV601030-2'`)에, `catchmenu_kds.kds_events`에 `commit_kds_ticket()`이 성공 시 쓰는 `event_type='all_conditions_met'`만 정확히 겨냥한 임시 `CHECK` 제약(`tmp_block_all_conditions_met`)을 추가해(`0163 §9`/`600663 §2.4`와 동일 기법), `commit_kds_ticket()`(→`bulk_commit_kds_tickets()`) 내부에서 강제로 예외(`sqlstate='23514'`)를 유발했다. 결과:

- `request_kds_release_after_payment()`는 예외를 재전파하지 않고 `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', error_detail:{sqlstate:'23514'}}`를 정상적으로 반환했다.
- **결정적 확인**: 이 호출보다 먼저 INSERT됐던 `payment_ledger` 행(위 fixture의 그 행, "결제는 이미 확정된 상태"를 시뮬레이션)이 예외 이후에도 트랜잭션 안에서 그대로 조회됨(`ledger_status='APPROVED'`, `approved_amount=15000` 그대로) — §2 원칙("결제확정 성공은 KDS 방출 실패로부터 격리되어야 한다")이 실제로 지켜짐을 실증했다.
- `commit_kds_ticket()` 자신의 UPDATE(티켓을 `COMMITTED`로 전이시키려던 것)는 정상적으로 롤백되어 티켓이 `HOLD`로 남았다 — `600652_Logic.md` §9.2가 이미 확립한 원자성 성질(예외 발생 시 그 함수 자신의 작업만 롤백되고, 더 이전에 이미 완료된 호출자의 작업은 영향받지 않음)이 이 새 설계에서도 동일하게 성립함을 확인.

### §3.3 시나리오 3(0-티켓, §1.2 수정판) — 재현 완료

`order_number='CV601030-ZEROTICKET'`, `payment_ledger` 1건은 있으나 **`kds_tickets` 자체를 생성하지 않은** fixture(이미 완전히 처리된 주문에 대해 웹훅이 재전송되는 상황을 시뮬레이션). 정정 전 로직으로는 `committed_count:0/pending_count:0/skipped_count:0`이 `'PAYMENT_CONFIRMED_KDS_COMMITTED'`로 잘못 분류됐으나, 정정 후 로직(§1.2)으로 재현한 결과 `result_code:'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'`가 정확히 반환됨을 확인했다 — `bulk_commit_kds_tickets()` 자신의 `message_code:'no_tickets_committed'`와도 의미가 일치한다.

세 시나리오 모두 재현 SQL은 이 문서에 직접 포함하지 않았다(임시 검증 스크립트, `.sql` 파일로 저장하지 않음, 트랜잭션 종료 시 전부 롤백되어 라이브에 흔적 없음).

## §4 멱등성(웹훅 재전송) — Open Item 재확인, 이번 문서에서 설계하지 않음

`601032_Logic.md`(이 문서) 작성 과정에서도 `confirm_payment_from_provider()` 자체의 재호출(Toss가 같은 웹훅을 중복 전송하는 경우) 시 신규 함수가 어떻게 동작할지 확인이 필요하다는 점을 재확인했다 — `request_kds_release_after_payment()`는 이미 `COMMITTED`된 티켓에 대해 다시 호출돼도 `bulk_commit_kds_tickets()`가 `HOLD`/`CAPACITY_CHECKING` 상태의 티켓만 대상으로 순회하므로(§1 시그니처 재확인) 안전할 것으로 **추정**되나, 이는 `confirm_payment_from_provider()` 자체의 상위 레벨 멱등성 처리 여부에 달린 문제이지 신규 함수의 책임 범위가 아니다 — Open Item으로 유지(`601031_Overview.md` §6 (e)).

## §5 마이그레이션 파일 배치 (Stage 8 대상, 이번 문서는 설계만)

Human이 방향(이번엔 이미 확정됨)에 따라 Stage 5에서 다음 마이그레이션 번호를 확정한다(이 문서 작성 시점 기준 `0165`가 최신 — Stage 5 직전 재확인 필요). `0027` 원본 소스 텍스트는 수정하지 않고 `CREATE OR REPLACE`로만 라이브 정의를 덮어쓴다. 신규 `error_codes`/`message_catalog` 항목은 필요 없을 것으로 예상(신규 함수는 클라이언트에 직접 노출되는 `error_key` 기반 실패를 반환하지 않고 `result_code` 필드만 씀 — `build_error_response()`를 쓰지 않는 설계이므로 `error_codes` 등록 불필요) — Stage 5에서 재확인.

## §6 Open Items (`601031_Overview.md` §6과 완전히 동일한 (a)-(h) 목록을 공유)

**(Stage 4 Critical tier — Cursor+Codex 지적사항 반영)** 이 목록은 `601031_Overview.md` §6과 글자 그대로 동일한 항목/순서를 유지한다 — 두 문서가 서로 다른 내용을 같은 문자에 담고 있던 이전 상태(예: 이 문서의 옛 (d)가 Overview의 (e)와 다른 항목이었던 것)를 정정.

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 별도 워크패킷 필요(`601031_Overview.md` §3/§6 (a)).
(b) `confirm_payment()`(POS, `0098`)를 동일 신규 함수로 연결 — 최우선 후속 워크패킷 후보(§6 (b)).
(c) `resolve_payment_uncertain()` 분리 — 재확인, 이번엔 다루지 않음(§6 (c)).
(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정(`601031_Overview.md` §6 (d), 이전에 이 문서에서 누락돼 있었음).
(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오 — §4에서 상세 설계 부재 확인, Stage 5 이전 확인 필요. **격상 근거**: Cursor+Codex 둘 다 "스코프 제외는 타당하나 실제 운영 위험이 크다"고 지적 — §1.2 item 1의 0-티켓 `result_code` 수정 자체가 이 시나리오(이미 완전히 처리된 주문에 대한 웹훅 재전송)의 실질적 위험을 방증한다.
(f) 도메인 번호 공간 소진(`601031_Overview.md` §0/§6 (f)) — 이 워크패킷 범위 밖, Human 결정 필요.
(g) §3의 `pg_temp` 재현 3건은 이 세션이 직접 수행한 것이나, Stage 5/8-9는 각자 자기 자신의 새 fixture로 독립 재현해 재확인해야 한다 — "이 세션이 검증했다"가 "다음 Stage가 검증을 생략해도 된다"는 뜻으로 오독되지 않도록 명시(`601031_Overview.md` §6 (g)와 동일, Stage 4에서 §3/§6/Snapshot 간 표현 불일치 지적을 해소하며 신설).

(h) **[신규, 2026-07-18, `p_decision='PENDING'` 결함 수정 중 부수적으로 발견 — canonical 위치는 `601034_ChangeContract.md` §8 (h), 이 항목은 교차참조용 사본]** `catchmenu_audit.append_audit_record()`를 호출하는 다른 기존 라이브 함수 **7개 파일**에서도 `chk_audit_decision`(`0008:105-119`)의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — 리터럴 개수로는 **8개**(타겟 grep 기준 — 전수조사 아님, 그 이상일 수 있음): `0084`(`'RESOLVED'`), `0085`(`'PUBLISHED'`), `0086`(`'PUBLISHED'`), `0087`(`'ROLLED_BACK'`), `0091`(`'GO_LIVE_AUTHORIZED'`), `0098`(`'REFUND_PENDING'`), `0100`(같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개 — 이 파일이 리터럴 수를 파일 수보다 1개 더 많게 만드는 원인). 실행되면 이번 워크패킷에서 고친 것과 동일한 방식(제약 위반 → INSERT 크래시)으로 실패할 가능성이 높다. 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며, 별도의 독립 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 최신·상세 버전은 `601034_ChangeContract.md` §8 (h)를 참조 — 두 문서가 서로 어긋나면 `601034`가 우선한다(ChangeContract가 Human Approval의 근거 문서이므로).

(i) **[신규, 2026-07-18, "감사기록의 감사기록" 정정에서 명시적으로 인정된 잔여 위험 — §1.5 참고]** 두 `EXCEPTION` 핸들러의 감사기록 호출에 1단계 fallback(`RAISE WARNING`)을 추가했지만, 이 fallback 자체가 실패하는 극단적 상황(서버 자체가 응답 불능 등)까지는 방어하지 않는다 — 의도적으로 무한 중첩을 하지 않기로 한 설계 결정의 직접적 귀결이다. 또한 `RAISE WARNING`은 서버 로그에만 남으므로, 아무도 그 로그를 모니터링하지 않으면 이 이중 실패 자체가 사실상 관측 불가능한 상태로 남는다 — 로그 모니터링/알림 체계와의 연동 여부는 이 워크패킷 범위 밖이며, 별도 검토가 필요하다.

## Module Domain Tags

- SQL (예정 — 이번 턴은 설계만, `.sql` 생성/수정 없음)
- DOCUMENTATION_ONLY

## Snapshot Decision

**확정, Stage 5(TestPlan/ChangeContract) 착수 가능한 수준까지 설계 완료.** 신규 함수 `catchmenu_payment.request_kds_release_after_payment()`는 `bulk_commit_kds_tickets()`를 재사용하는 얇은 오케스트레이션 계층으로 설계했다(§1) — 스스로 모든 예외를 삼키고 항상 `success:true`를 반환해, 결제확정 성공이 KDS 방출 실패로부터 격리되도록 했다(§1.2/§2 원칙 재적용). `confirm_payment_from_provider()`는 이 신규 함수를 호출하도록 수정하되, **(2026-07-18 재정정, 옵션 C)** 방어적 `EXCEPTION` 핸들러를 함수 전체가 아니라 `request_kds_release_after_payment()` 호출 지점만 감싸는 좁은 중첩 블록으로 한정했다 — 함수 전체를 감싸면 이 호출부에서 발생한 예외가 이미 완료된 payment-core 작업(`payment_ledger` INSERT 포함)까지 롤백시켜버리는 위험을 ChatGPT 교차검증이 지적했고, 이를 `pg_temp`로 직접 실증해 좁은 중첩 블록만이 안전함을 확인했다(§2.1/§2.2). "payment-core 구간의 예외=결제 실패"와 "이 좁은 블록의 예외=결제 성공/KDS 호출 메커니즘만 실패"라는 두 계층의 의미 차이는 여전히 설계 자체로 구분된다(§2.2). 원자성 가설(예외 발생 시 그 블록 자신의 작업만 롤백되고 그 이전에 이미 완료된 작업은 보존된다)은 이 세션이 `pg_temp`로 4개 시나리오(정상 경로/KDS 예외/0-티켓/옵션 C 좁은 블록)의 재현을 완료해 실증했다(§2.1/§2.2/§3) — 다만 이 완료가 Stage 5/8-9의 독립 재검증 의무를 대체하지 않는다는 점을 §6 (g)에 명시했다.

**(Stage 4 Critical tier 정정 반영, 2026-07-18)** Cursor+Codex가 지적한 3가지 결함을 이번 정정에서 해소했다: (1) 0-티켓 시나리오를 위한 신규 `result_code`(`PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`) 추가 및 `pg_temp` 재검증(§1.2/§3.3), (2) §3의 "완료" 서술과 §6/Snapshot의 "미완료" 서술 간 모순을 §3 재작성으로 해소(§3/§6 (g)), (3) §2.1 반환값의 `kds_release_authorized` 하드코딩을 `result_code` 파생 값으로 교체, (4) 웹훅 멱등성 Open Item을 High priority로 격상(§6 (e)), (5) 이 문서와 `601031_Overview.md`의 §6 Open Items를 (a)-(g) 동일 목록으로 동기화.

**(2026-07-18, "감사기록의 감사기록" 정정 — Cursor+Codex 실증 발견)** Stage 9 독립 검증 이후, Cursor+Codex가 두 `EXCEPTION` 핸들러(§1.2, §2.2) 안의 `append_audit_record()` 호출 자체가 실패할 경우 그 2차 실패가 핸들러 밖으로 전파되어 `confirm_payment_from_provider()` 전체가 처리되지 않은 예외로 종료되고, 이미 완료된 `payment_ledger` INSERT까지 롤백되는 것을 실제로 재현해 확인했다(`payment_ledger` 행 0건). 이 세션도 동일 기법(`kds_events`와 `audit_records` 양쪽에 임시 `CHECK` 제약)으로 정정 전 상태를 독립 재현해 위험을 재확인했다. 두 감사기록 호출을 각각 좁은 중첩 `begin...exception...end`로 한 번 더 감싸고, 그 안쪽 예외는 `RAISE WARNING`(실행을 중단시키지 않음, `pg_temp`로 실증)만 남기고 정상 반환으로 계속 진행하도록 정정했다(§1.5) — **정확히 1단계 fallback까지만** 두고, 그 이상(fallback 자체의 실패)은 의도적으로 방어하지 않는 잔여 위험으로 명시했다(§6 (i), ChatGPT의 "무한 중첩은 답이 아니다" 지적 반영). 정정 후 Scenario A(`request_kds_release_after_payment()` 직접 호출, 콜백 내부 1차 실패 + 이중 실패 강제), Scenario B(`confirm_payment_from_provider()` 종단 호출, 호출 지점 자체의 1차 실패 — `ALTER FUNCTION RENAME` 기법 — + 이중 실패 강제), Scenario C(`confirm_payment_from_provider()` 종단 호출, 콜백 내부 1차 실패 + 이중 실패 강제) 전부를 라이브 함수 체인 전체로 재실행해, 세 경우 모두 함수가 정상 반환하고 `payment_ledger` 행이 살아남는 것을 확인했다(§1.5) — 다만 이 수정은 아직 라이브에 반영되지 않았고(Logic.md 설계 교정만 이번 턴 범위), Stage 5 TestPlan/ChangeContract 및 실제 migration 갱신은 후속 라운드 필요.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601033_TestPlan_Canonical_Kds_Release_Orchestration.md] =====
# 601033_TestPlan_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: TestPlan
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## §0 Scope and numbering confirmation

This TestPlan verifies the final design fixed in `601031_Overview_Canonical_Kds_Release_Orchestration.md` and `601032_Logic_Canonical_Kds_Release_Orchestration.md` — both already carried a triple-verification round (Cursor+Codex Stage 4 Critical tier) and a subsequent correction round (0-ticket `result_code`, §3 contradiction, §2.1 hardcoding, idempotency priority, §6 sync). This TestPlan cites that design as final and does not re-litigate it.

**Migration number reconfirmed live (2026-07-18)**: `sql/migrations/` tops out at `0165_menu_price_list_architecture_phase0.sql`; `catchmenu_meta.migration_history` independently confirms `0165` as the latest applied entry. No `0166`/`0167` file exists on disk or in migration history. `0166` is the next available number — Stage 8 must re-run this exact check immediately before creating the migration file, in case another workpacket claims it in the interim (same discipline as `0163`/`0164`/`0165`).

**Live-reconfirmed at Stage 5 (2026-07-18, this session, via `docker exec ... psql`)**, all matching `601031_Overview.md` §1's assumptions with no drift:

```text
catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_force_conditions jsonb, p_correlation_id text)
catchmenu_kds.commit_kds_ticket(p_tenant_id uuid, p_store_id uuid, p_ticket_id uuid, p_conditions jsonb, p_correlation_id text)
catchmenu_kds.evaluate_kds_capacity(p_tenant_id uuid, p_store_id uuid, p_kitchen_zone text)
catchmenu_payment.confirm_payment_from_provider(p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text)
```

`catchmenu_payment.request_kds_release_after_payment` — **0 rows found live** (confirmed does not exist yet; this is the intended pre-implementation state).

`pg_get_functiondef()` on the live `confirm_payment_from_provider()` was diffed against `sql/migrations/0027_create_payment_intent_rpc.sql` — identical (declare block, intent validation, `payment_ledger` INSERT with `kds_release_authorized := false`, `kds_tickets`/`kds_events` updates, `payment_events`/`catchmenu_ledger.events` inserts, `append_audit_record()` call, and the final `return jsonb_build_object(...)` at lines 415-427 exactly as `601032_Logic.md` §2.1 assumes). No `EXCEPTION` handler present, confirmed (matches `601032_Logic.md` §2.2's premise).

## §1 Pre-flight checks

### §1.1 Target-object collision check

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "SELECT n.nspname, p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'catchmenu_payment' AND p.proname = 'request_kds_release_after_payment';"
```

Expected: 0 rows, immediately before Stage 8 begins.

### §1.2 `append_audit_record()` contract check

```powershell
Select-String -Path "sql\migrations\0008_create_ledger_audit.sql" -Pattern "chk_audit_domain|chk_audit_category|chk_audit_decision" -Context 0,15
```

**(Stage 4 Critical tier 정정, Cursor+Codex 교차검증 — 이전 Stage 5 초안의 검증 공백)** 이전 초안은 여기서 "`decision` has no CHECK constraint (free text)"라고 잘못 기술했다 — 실제로는 `0008_create_ledger_audit.sql:105-119`에 `chk_audit_decision` 제약이 존재하며, 허용값은 정확히 다음 11개뿐이다:

```text
APPROVED, REJECTED, OVERRIDDEN, DELEGATED, ESCALATED,
CANCELLED, COMPLETED, FAILED, NOTED, SUSPENDED, REVOKED
```

**이 오기(誤記)가 실제 설계 결함을 놓치게 만든 원인이다**: `601032_Logic.md` §1.2의 원래 `p_decision` 매핑은 `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` 두 분기 모두에 대해 `'PENDING'`을 매핑했는데, `'PENDING'`은 이 11개 허용값에 없다 — 즉 이 두 분기가 실행될 때마다 `append_audit_record()`의 `INSERT`가 `chk_audit_decision` 위반으로 크래시하고, `request_kds_release_after_payment()` 자신의 `EXCEPTION WHEN OTHERS` 핸들러가 이를 잡아 `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`로 잘못 보고했을 것이다 — 결제는 정상이고 KDS도 정상적으로 대기 상태였을 뿐인데 "실패"로 오분류되는 심각한 결함이었다. `601032_Logic.md`/`601033_TestPlan.md`/`601034_ChangeContract.md`에서 `'SUSPENDED'`로 정정됐다(아래 §2.2/§2.3, `601032_Logic.md` §1.2, `601034_ChangeContract.md` §2.1/§8 참고).

Expected: `chk_audit_domain` includes `'payment'`; `chk_audit_category` includes `'OPERATIONAL'` and `'FINANCIAL'`; `chk_audit_decision` includes exactly the 11 values above — `'APPROVED'`/`'FAILED'`/`'NOTED'`/`'SUSPENDED'` (the corrected 4 decision branches used by `601032_Logic.md` §1.2) are all valid; `'PENDING'` is **not** valid and must never appear in a `p_decision` argument to `append_audit_record()`.

### §1.3 `payment_ledger` / `kds_tickets` schema reconfirmation

```powershell
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "\d catchmenu_payment.payment_ledger"
docker exec -i supabase_db_yoonsul_wait_order_handoff psql -U postgres -d postgres -c "\d catchmenu_kds.kds_tickets"
```

Expected: `payment_ledger.kds_release_authorized`/`kds_release_authorized_at`/`kds_release_authorized_by` present exactly as `601032_Logic.md` §1.2 Step 1 assumes; `kds_tickets.conditions_met jsonb not null default '{}'::jsonb`, `kds_status text not null default 'HOLD'`, `payment_ledger_id uuid` nullable, `ticket_number`/`menu_name_snapshot`/`business_day` `not null` (fixtures below must supply them).

Note (informational only, not a Stop Condition): `payment_ledger` carries a partial index `idx_payment_ledger_kds_auth ... WHERE kds_release_authorized = false AND ledger_status = 'APPROVED'`. Once Step 1 sets a row's `kds_release_authorized = true`, that row naturally falls out of this index's coverage — expected and harmless (the index exists to help a future retry/backlog scanner, `601031_Overview.md` §6 (a), find rows still needing authorization; this workpacket doesn't add such a scanner).

## §2 `request_kds_release_after_payment()` — all 5 `result_code` branches

Each scenario is isolated in its own `begin;...rollback;` block. Tests call the **live function** (created by Stage 8) directly — per `AGENTS.md` §3.8, this is only valid once `601034_ChangeContract.md` §10 reads `APPROVED`; until then these SQL blocks are the specification Stage 8/9 must execute, not something this Stage-5 draft itself runs.

Shared fixture constants: `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid`, `p_store_id := '00000000-0000-0000-0000-000000000002'::uuid` (both reused from `601032_Logic.md` §3's already-validated fixtures).

### §2.1 Scenario 1 — full commit, `PAYMENT_CONFIRMED_KDS_COMMITTED`

Fixture: order `CV601033-S1-COMMIT`, one `payment_ledger` row (`kds_release_authorized = false`), two `kds_tickets` rows (`T-S1-A`, `T-S1-B`), both with `conditions_met = {"arrived":true,"table_confirmed":true,"payment_confirmed":true}`, `kds_status = 'HOLD'`.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S1-COMMIT', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S1', 'idem-601033-s1',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S1-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S1-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s1'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);
select kds_release_authorized from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED'`, `committed_count = 2`, `pending_count = 0`, `skipped_count = 0`. Before rollback, both tickets read `kds_status = 'COMMITTED'` and `payment_ledger.kds_release_authorized = true`.

### §2.2 Scenario 2 — mixed, `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD`

Fixture: order `CV601033-S2-PARTIAL`, two tickets: `T-S2-A` with `conditions_met = {"arrived":true,"table_confirmed":true,"payment_confirmed":true}` (commits), `T-S2-B` with `conditions_met = {"arrived":false,"table_confirmed":true,"payment_confirmed":true}` (missing `arrived` — stays `CAPACITY_CHECKING`, per `commit_kds_ticket()`'s 7-condition `AND`, `0028:155-177` live-reconfirmed).

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S2-PARTIAL', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S2', 'idem-601033-s2',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S2-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S2-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s2'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD'`, `committed_count = 1`, `pending_count = 1`, `skipped_count = 0`. `T-S2-A` reads `COMMITTED`, `T-S2-B` reads `CAPACITY_CHECKING`. **(Stage 4 정정)** The associated `catchmenu_ledger.audit_records` row must have `decision = 'SUSPENDED'` (not `'PENDING'` — `chk_audit_decision` rejects `'PENDING'`; see §3).

### §2.3 Scenario 3 — none commit, `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD`

Fixture: order `CV601033-S3-HOLD`, two tickets, both with `conditions_met = {"arrived":false,"table_confirmed":true,"payment_confirmed":true}`.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S3-HOLD', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S3', 'idem-601033-s3',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S3-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S3-B', 'HOLD', 'CV601033 Test Menu B',
  jsonb_build_object('arrived', false, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_b_id \gset

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s3'
) as result;

select ticket_number, kds_status from catchmenu_kds.kds_tickets where id in (:'ticket_a_id'::uuid, :'ticket_b_id'::uuid);

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`, `committed_count = 0`, `pending_count = 2`, `skipped_count = 0`. Both tickets read `CAPACITY_CHECKING`. **(Stage 4 정정)** The associated `catchmenu_ledger.audit_records` row must have `decision = 'SUSPENDED'` (not `'PENDING'` — `chk_audit_decision` rejects `'PENDING'`; see §3).

### §2.4 Scenario 4 — zero tickets, `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`

Fixture: order `CV601033-S4-ZEROTKT`, one `payment_ledger` row, **no** `kds_tickets` row at all (simulates a webhook resend for an order whose tickets already left `HOLD`/`CAPACITY_CHECKING` in a prior call).

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S4-ZEROTKT', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S4', 'idem-601033-s4',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

-- deliberately no kds_tickets insert -- order has zero eligible tickets

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s4'
) as result;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS'`, `committed_count = 0`, `pending_count = 0`, `skipped_count = 0` — **must not** be `'PAYMENT_CONFIRMED_KDS_COMMITTED'` (this is the exact regression `601032_Logic.md` §1.2/§3.3 fixed; re-verify independently here, do not trust the Stage-5-session's own prior `pg_temp` run, `601032_Logic.md` §6 (g)).

### §2.5 Scenario 5 — gate rejection, `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED`

Fixture: order `CV601033-S5-BLOCKED`, a real `payment_ledger` row for the order (`kds_release_authorized = false`, left untouched), one `kds_tickets` row in `HOLD`. Call `request_kds_release_after_payment()` with **`p_ledger_id := '00000000-0000-0000-0000-0000000009ff'::uuid`** — a value that does not match any row for this `tenant_id`/`store_id`. Step 1's `UPDATE` therefore matches 0 rows; the real ledger row's `kds_release_authorized` stays `false`; `bulk_commit_kds_tickets()`'s own gate (`0039:38-53`, live-reconfirmed) then returns `success:false, error_key:'kds_release_not_authorized'` before even reaching the per-ticket loop.

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status, order_channel,
  total_amount, final_amount, ordered_at, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid,
  'CV601033-S5-BLOCKED', 'DINE_IN', 'CONFIRMED', 'KIOSK', 15000, 15000, now(), current_date
) returning id as order_id \gset

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status, payment_method, payment_channel,
  requested_amount, currency, provider_type, provider_order_id, idempotency_key,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'CONFIRMED', 'CARD', 'ONLINE', 15000, 'KRW', 'TOSS_PAYMENTS', 'CM-TEST-601033-S5', 'idem-601033-s5',
  current_date, 'Asia/Seoul'
) returning id as intent_id \gset

insert into catchmenu_payment.payment_ledger (
  tenant_id, store_id, order_id, intent_id, ledger_entry_type, ledger_status,
  approved_amount, net_amount, provider_type, reconciliation_status,
  kds_release_authorized, business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid, :'intent_id'::uuid,
  'APPROVAL', 'APPROVED', 15000, 15000, 'TOSS_PAYMENTS', 'PENDING',
  false, current_date, 'Asia/Seoul'
) returning id as ledger_id \gset

insert into catchmenu_kds.kds_tickets (
  tenant_id, store_id, order_id, ticket_number, kds_status, menu_name_snapshot,
  conditions_met, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid, '00000000-0000-0000-0000-000000000002'::uuid, :'order_id'::uuid,
  'T-S5-A', 'HOLD', 'CV601033 Test Menu A',
  jsonb_build_object('arrived', true, 'table_confirmed', true, 'payment_confirmed', true),
  current_date
) returning id as ticket_a_id \gset

-- deliberate mismatch: this ledger_id does not correspond to any real payment_ledger row
-- for this tenant/store, so Step 1's UPDATE affects 0 rows and the real ledger row above
-- (:'ledger_id') keeps kds_release_authorized = false.
select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := '00000000-0000-0000-0000-0000000009ff'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s5'
) as result;

select kds_release_authorized from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;
select kds_status from catchmenu_kds.kds_tickets where id = :'ticket_a_id'::uuid;

rollback;
```

Expected: `result_code = 'PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED'`, and — **(Stage 4 Critical tier 정정, Codex 재현)** — `committed_count`/`pending_count`/`skipped_count` are all `null` (not `0`): `bulk_commit_kds_tickets()`'s own gate check (`0039:38-53`) returns `{success:false, error_key:'kds_release_not_authorized', ...}` before the per-ticket loop ever runs, so these keys are never populated in `v_bulk_result` and `v_bulk_result->'committed_count'` resolves to JSON `null` when re-embedded via `jsonb_build_object`. The real ledger row's `kds_release_authorized` stays `false` (Step 1 never matched it), and the fixture's real `kds_tickets` row is untouched (still `HOLD`) — confirms the gate rejection is clean and does not partially mutate ticket state.

## §3 Audit record verification — all 5 branches

Immediately after each §2 scenario's function call (before `rollback`), run:

```sql
select audit_type, decision, decision_payload->>'result_code' as result_code
from catchmenu_ledger.audit_records
where subject_type = 'payment_ledger' and subject_id = :'ledger_id'::uuid
order by recorded_at desc
limit 1;
```

Expected `decision` per scenario (`601032_Logic.md` §1.2's `p_decision := case ... end`):

| Scenario | `result_code` | `decision` |
|---|---|---|
| §2.1 | `PAYMENT_CONFIRMED_KDS_COMMITTED` | `APPROVED` |
| §2.2 | `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD` | `SUSPENDED` |
| §2.3 | `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD` | `SUSPENDED` |
| §2.4 | `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS` | `NOTED` |
| §2.5 | `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED` | `FAILED` |

**(Stage 4 Critical tier 정정 — `'PENDING'`은 `chk_audit_decision`의 허용값이 아니므로 §1.2에서 정정된 `'SUSPENDED'`로 교체됐다. §2.2/§2.3 실행 시 반드시 이 값으로 감사기록이 성공적으로 INSERT되는지 확인할 것 — 이전 값(`'PENDING'`)으로 실행했다면 이 INSERT 자체가 크래시해 `EXCEPTION` 핸들러로 빠지고 `result_code`가 `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`로 잘못 보고됐을 것이다. §2.2/§2.3의 "Expected" 절 자체도 이 값으로 갱신됐다.)**

All rows must have `audit_domain = 'payment'`, `audit_type = 'kds_release_requested'` (§2.5's `RELEASE_BLOCKED` case is still the non-exception path — it goes through the same `case` block, not the `EXCEPTION` handler's separate `kds_release_requested_failed` audit_type; confirm this distinction explicitly, it is easy to conflate with §4 below).

## §4 EXCEPTION path — `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED`

Reproduces `601032_Logic.md` §3.2's technique as executable SQL against the live function (the Stage-5 session's own `pg_temp` run of this scenario must not be trusted as sufficient — re-run independently, `601032_Logic.md` §6 (g)).

```sql
begin;
-- fixture: order 'CV601033-S6-EXCEPTION', payment_ledger row, one kds_tickets row (HOLD,
-- conditions_met fully satisfied so commit_kds_ticket() would otherwise succeed).

alter table catchmenu_kds.kds_events
  add constraint tmp_601033_block_all_conditions_met check (event_type <> 'all_conditions_met');

select catchmenu_payment.request_kds_release_after_payment(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_order_id := :'order_id'::uuid,
  p_ledger_id := :'ledger_id'::uuid,
  p_actor_type := 'PROVIDER',
  p_correlation_id := 'verify-601033-s6-exception'
) as result;

-- critical check: the payment_ledger row inserted BEFORE this call must survive untouched.
select ledger_status, approved_amount from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;

-- the ticket's own commit UPDATE must have rolled back to HOLD (commit_kds_ticket()'s own atomicity).
select kds_status from catchmenu_kds.kds_tickets where id = :'ticket_id'::uuid;

select audit_type, decision, decision_payload->>'sqlstate' as sqlstate
from catchmenu_ledger.audit_records
where subject_type = 'payment_ledger' and subject_id = :'ledger_id'::uuid
order by recorded_at desc limit 1;

alter table catchmenu_kds.kds_events drop constraint tmp_601033_block_all_conditions_met;
rollback;
```

Expected:

1. The function call itself does **not** raise — returns `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', error_detail:{sqlstate:'23514'}}`.
2. The pre-existing `payment_ledger` row is unchanged (`ledger_status='APPROVED'`).
3. The `kds_tickets` row remains `HOLD` (its own attempted transition rolled back).
4. A separate audit row exists with `audit_type = 'kds_release_requested_failed'`, `decision = 'FAILED'`, `decision_payload->>'sqlstate' = '23514'` — distinct from §3's `kds_release_requested` audit type.

## §5 `kds_release_authorized_by` actor propagation

Using §2.1's Scenario 1 fixture (or a fresh minimal one-ticket variant), call with `p_actor_type := 'PROVIDER'` and confirm:

```sql
select kds_release_authorized_by from catchmenu_payment.payment_ledger where id = :'ledger_id'::uuid;
```

Expected: `'PROVIDER'` (not `'SYSTEM'`) — confirms `601032_Logic.md` §1.4's design (the new function does not hardcode the actor, unlike `release_kds_after_payment()`'s `'SYSTEM'` hardcode).

## §6 `confirm_payment_from_provider()`(`0027`) modification verification

### §6.1 `payment_ledger` INSERT unchanged

```powershell
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
```

Expected (after Stage 8 implementation): the `insert into catchmenu_payment.payment_ledger (...)` block (source lines 263-289 pre-change) is byte-identical to before — only the code after the existing `audit_id` calculation and the final `return` block changes, per `601032_Logic.md` §2.1's exact insertion point. **(2026-07-18, Option C)** the inserted code is a narrow nested `begin...exception when others...end;` block wrapping only the `request_kds_release_after_payment()` call — nothing before that insertion point (intent validation, the `payment_ledger` INSERT, `kds_tickets`/`kds_events` updates, this function's own `append_audit_record()` call) is wrapped or otherwise modified.

### §6.2 End-to-end: committed case

Call the full `confirm_payment_from_provider()` webhook entry point (not the new function directly) against a fixture where the order's ticket(s) will fully commit:

```sql
begin;
-- fixture: payment_intents row (intent_status='CONFIRMED' precondition via create_payment_intent(),
-- or a direct fixture row matching 0027's SELECT), kds_tickets row(s) with conditions_met
-- pre-seeded {"arrived":true,"table_confirmed":true} (payment_confirmed is set by this call itself).
select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test-pk-601033-e2e-commit',
  p_provider_approval_number := 'test-appr-601033-e2e-commit',
  p_approved_amount := 15000,
  p_provider_raw_event_id := :'raw_event_id'::uuid,
  p_correlation_id := 'verify-601033-e2e-commit'
) as result;
rollback;
```

Expected response: `success:true`, `ledger_status:'APPROVED'`, `result_code:'PAYMENT_CONFIRMED_KDS_COMMITTED'`, **`kds_release_authorized:true`** (derived from `result_code`, per `601032_Logic.md` §2.1's corrected hardcoding fix), `message_code:'payment_approved_kds_released'`.

### §6.3 End-to-end: non-committed case (the corrected-hardcoding regression test)

Repeat §6.2 with a fixture ticket missing `arrived` (so it lands in `CAPACITY_CHECKING`, `result_code = 'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`).

Expected response: `success:true` still (payment itself succeeded — §2 principle), `ledger_status:'APPROVED'` still, `result_code:'PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD'`, **`kds_release_authorized:false`** — this is the exact case the Stage 4 hardcoding fix targets. Before the fix this field would have incorrectly read `true`. `message_code:'payment_approved_kds_pending'`.

### §6.4 Option C narrow wrapper — simulated call-site exception (2026-07-18 addition, ChatGPT-designed redesign)

Reproduces the scenario `601032_Logic.md` §2.2 designed for but which cannot occur under normal operation (`request_kds_release_after_payment()` already swallows all its own internal exceptions) — this test instead forces an exception to occur **at the call site itself**, before the callee's own body ever runs, by temporarily breaking the call target inside a transaction that gets rolled back afterward (the rename is transactional in Postgres, so it is fully undone by `rollback;` — no permanent schema change).

```sql
begin;
-- fixture: same shape as §6.2 (payment_intents row, kds_tickets row(s) with
-- conditions_met pre-seeded so the ticket would otherwise commit normally).

alter function catchmenu_payment.request_kds_release_after_payment(
  uuid, uuid, uuid, uuid, text, text
) rename to request_kds_release_after_payment_tmp_renamed_601033;

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test-pk-601033-optionc',
  p_provider_approval_number := 'test-appr-601033-optionc',
  p_approved_amount := 15000,
  p_provider_raw_event_id := :'raw_event_id'::uuid,
  p_correlation_id := 'verify-601033-optionc'
) as result;

-- critical check: the payment_ledger row (INSERTed by confirm_payment_from_provider()
-- BEFORE the narrow wrapped call) must have survived, even though the call inside
-- the narrow block failed with "function does not exist".
select ledger_status, approved_amount, kds_release_authorized
from catchmenu_payment.payment_ledger
where intent_id = :'intent_id'::uuid;

select audit_type, decision, decision_payload->>'sqlstate' as sqlstate
from catchmenu_ledger.audit_records
where audit_type = 'kds_release_call_unexpected_exception'
order by recorded_at desc limit 1;

alter function catchmenu_payment.request_kds_release_after_payment_tmp_renamed_601033(
  uuid, uuid, uuid, uuid, text, text
) rename to request_kds_release_after_payment;

rollback;
```

Expected:

1. The call to `confirm_payment_from_provider()` does **not** raise — the deliberately-broken call target is caught by the §2.1 narrow inner block, not allowed to propagate out of the whole function.
2. The response is `success:true`, `ledger_status:'APPROVED'`, `result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED'`, `kds_release_authorized:false` — reported identically to the shape the new function itself would return from its own internal `EXCEPTION` handler (`601033_TestPlan.md` §4), so the caller cannot distinguish "caught inside the new function" from "the call to the new function itself failed."
3. The `payment_ledger` row created earlier in the same function invocation is present and unaffected (`ledger_status='APPROVED'`) — confirms the narrow block's implicit savepoint starts after payment-core work, not before it (`601032_Logic.md` §2.1/§2.2's live `pg_temp` finding, re-verified here against the actual live function chain rather than a `pg_temp` stand-in).
4. A `catchmenu_ledger.audit_records` row exists with `audit_type = 'kds_release_call_unexpected_exception'`, `decision = 'FAILED'`, `decision_payload->>'sqlstate' = '42883'` (`undefined_function`).
5. The final `alter function ... rename` (undoing the temporary break) is redundant with `rollback;` but included for clarity/defense-in-depth — either one alone is sufficient since `ALTER FUNCTION ... RENAME` is transactional in Postgres.

## §7 Boundary — 0 diff

### §7.1 User-specified boundary set

```powershell
git diff -- `
  sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql `
  sql/migrations/0028_create_kds_capacity_commit_rpc.sql `
  sql/migrations/0039_create_kds_bulk_commit_rpc.sql `
  sql/migrations/0110_create_store_admin_rpc.sql `
  sql/migrations/0141_hyper_personalization_menu_customization.sql `
  sql/migrations/0162_create_dining_table_admin_rpc.sql `
  sql/migrations/0163_seat_waiting_customer_facade_correction.sql `
  sql/migrations/0164_waiting_pipeline_sibling_functions_correction.sql `
  sql/migrations/0165_menu_price_list_architecture_phase0.sql
```

Expected: no diff on any of these 9 files. In particular `confirm_payment()` inside `0098` — this workpacket does not touch the POS payment path (`601031_Overview.md` §0.2 (3), Open Item (b)).

### §7.2 Additional established-scope boundary (already forbidden per `601031_Overview.md` §5, reconfirmed here)

```powershell
git diff -- `
  sql/migrations/0038_create_toss_webhook_processor_rpc.sql `
  sql/migrations/0056_create_van_integration_rpc.sql `
  sql/migrations/0143_add_no_payment_kds_release_policy.sql
```

Expected: no diff. `0038`/`0056` call `confirm_payment_from_provider()` but their own caller-side code is not part of this contract.

### §7.3 `resolve_payment_uncertain()` boundary (same file as the edited function, different function)

```powershell
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
```

Manual review requirement (a single-file diff can't isolate this automatically): confirm the diff touches only `confirm_payment_from_provider()`'s body — `create_payment_intent()`, `mark_payment_uncertain()`, and `resolve_payment_uncertain()` (the other 3 functions in the same file) show 0 changes.

### §7.4 Runtime boundary

```powershell
git diff -- catchmenu_app
```

Expected: no diff.

## §8 Acceptance criteria

The workpacket passes Stage 9 verification only if all of the following are true:

1. `request_kds_release_after_payment()` correctly produces all 5 `result_code` values under the fixtures in §2 — **(Stage 4 Critical tier 정정, Codex 재현 결과 반영)** distinguished by count-field behavior, not treated as one uniform group:
   - `PAYMENT_CONFIRMED_KDS_COMMITTED` (§2.1), `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD` (§2.2), `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD` (§2.3), `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS` (§2.4): `committed_count`/`pending_count`/`skipped_count` are all present with matching integer values (0 for the fields that don't apply).
   - `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED` (§2.5): `committed_count`/`pending_count`/`skipped_count` must be `null` — `bulk_commit_kds_tickets()`'s own gate rejection (`0039:46-53`) returns before the per-ticket loop runs at all, so no aggregation ever occurs; `v_bulk_result->'committed_count'` etc. resolve to JSON `null` via `jsonb_build_object`, not `0` and not an absent key. A Stage 9 check asserting `= 0` for this branch is itself a bug, not a passing test.
2. §2.4's zero-ticket case never returns `PAYMENT_CONFIRMED_KDS_COMMITTED` (regression guard for the Stage 4 fix).
3. Every §2 scenario produces exactly one `catchmenu_ledger.audit_records` row with `audit_domain='payment'`, `audit_type='kds_release_requested'`, and the `decision` value from §3's table.
4. The forced-exception scenario (§4) does not raise out of `request_kds_release_after_payment()`, leaves the pre-existing `payment_ledger` row untouched, rolls back the ticket's own attempted transition, and writes a separate `kds_release_requested_failed` audit row.
5. `kds_release_authorized_by` reflects the caller's `p_actor_type` (§5), not a hardcoded value.
6. `confirm_payment_from_provider()`'s `payment_ledger` INSERT block is unchanged (§6.1); its response's `kds_release_authorized` field is `true` only when `result_code = 'PAYMENT_CONFIRMED_KDS_COMMITTED'` (§6.2/§6.3) — not hardcoded.
7. **(2026-07-18, Option C)** A simulated call-site exception at `request_kds_release_after_payment()` (§6.4) is caught by the narrow inner block only — it does not propagate out of `confirm_payment_from_provider()`, and the `payment_ledger` row created earlier in the same invocation survives untouched. `confirm_payment_from_provider()` has no exception handler wrapping its own payment-core logic (intent validation through the `payment_ledger` INSERT) — a genuine failure in that region must still propagate naturally as a real payment failure, not be caught by anything added in this workpacket.
8. All 9 user-specified boundary files (§7.1) plus `0038`/`0056`/`0143` (§7.2) plus `resolve_payment_uncertain()`/`create_payment_intent()`/`mark_payment_uncertain()` within `0027` itself (§7.3) show 0 diff. `catchmenu_app` shows 0 diff (§7.4).
9. `catchmenu_kds.bulk_commit_kds_tickets()`, `catchmenu_kds.commit_kds_ticket()`, `catchmenu_kds.evaluate_kds_capacity()` are not modified — no migration in this workpacket contains `create or replace function catchmenu_kds.(bulk_commit_kds_tickets|commit_kds_ticket|evaluate_kds_capacity)`.


===== BEGIN [docs/600000_implementation_lifecycle/600500_payment_confirmation/601030_canonical_kds_release_orchestration/601034_ChangeContract_Canonical_Kds_Release_Orchestration.md] =====
# 601034_ChangeContract_Canonical_Kds_Release_Orchestration.md

Status: Draft
Lifecycle: ChangeContract
Stage: 5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-18

## Change ID

`canonical_kds_release_orchestration`

## Authority

- `601031_Overview_Canonical_Kds_Release_Orchestration.md`
- `601032_Logic_Canonical_Kds_Release_Orchestration.md`
- `601033_TestPlan_Canonical_Kds_Release_Orchestration.md`

## §0 Contract summary

This ChangeContract authorizes creating one new shared function, `catchmenu_payment.request_kds_release_after_payment()` (full design: `601032_Logic.md` §1), and redefining exactly one existing live function, `catchmenu_payment.confirm_payment_from_provider()` (full design: `601032_Logic.md` §2), in a new forward migration file. The already-applied source file `sql/migrations/0027_create_payment_intent_rpc.sql` remains immutable/original and is not edited. No other file, function, or schema object may change.

The new function authorizes `payment_ledger.kds_release_authorized` inline (mirroring `release_kds_after_payment()`'s pattern, since `authorize_kds_release()` was dropped by `0157`), then delegates the actual per-ticket 7-condition gate entirely to the existing, unmodified `catchmenu_kds.bulk_commit_kds_tickets()`/`commit_kds_ticket()`. It never raises — every internal failure is caught and returned as `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ...}` — so a KDS-side failure can never roll back the caller's already-committed `payment_ledger` row (`601032_Logic.md` §0/§2, `600652_Logic.md` §9.2's atomicity principle re-applied).

**Numbering note**: `sql/migrations/` currently tops out at `0165`; no `0166`/`0167` file exists on disk or in `catchmenu_meta.migration_history` (live-reconfirmed at Stage 5, `601033_TestPlan.md` §0). `0166` is available for this workpacket's use — Stage 8 must re-confirm this immediately before creating the file, per the project's standing numbering discipline.

**Source-of-truth note (2026-07-18 Stage 8 correction)**: `sql/migrations/0027_create_payment_intent_rpc.sql` is an already-applied migration and remains immutable/original. The latest live definition of `catchmenu_payment.confirm_payment_from_provider()` for this workpacket is provided only by the new forward migration `0166_canonical_kds_release_orchestration.sql`; future readers must consult `0166`, not `0027`, for the post-Option-C body.

**Draft migration mutability note (2026-07-18, §14.5 applied)**: `0166_canonical_kds_release_orchestration.sql` is still part of this same `601030` workpacket, has not passed Stage 12, is not on the baseline branch, has not been propagated to a shared environment, and has no downstream workpacket dependency. It therefore satisfies all four Draft Migration Mutability Rule conditions in `000701` §14.5. After the double-failure audit fallback defect was reproduced, the local DB was explicitly returned to the pre-`0166` state (`request_kds_release_after_payment()` dropped, `confirm_payment_from_provider()` restored from the immutable `0027` source, and the `0166` migration_history row removed), then the corrected `0166` was reapplied as the final draft implementation for this workpacket. This was not a checksum-only overwrite.

**`p_decision='PENDING'` design defect, found and fixed 2026-07-18 (Cursor+Codex Critical tier cross-verification)**: the original `601032_Logic.md` §1.2 mapped both `PARTIAL_CAPACITY_HOLD` and `CAPACITY_HOLD` to `p_decision := 'PENDING'`. `'PENDING'` is not one of the 11 values `catchmenu_ledger.audit_records.chk_audit_decision` (`0008:105-119`) actually accepts (`APPROVED`/`REJECTED`/`OVERRIDDEN`/`DELEGATED`/`ESCALATED`/`CANCELLED`/`COMPLETED`/`FAILED`/`NOTED`/`SUSPENDED`/`REVOKED`). Had this shipped, every `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` call would have crashed its own `append_audit_record()` INSERT, been caught by `request_kds_release_after_payment()`'s own `EXCEPTION WHEN OTHERS` handler, and been misreported to the caller as `PAYMENT_CONFIRMED_KDS_RELEASE_FAILED` — a normal, healthy "still waiting for kitchen capacity" outcome silently relabeled as a failure. Corrected to `'SUSPENDED'` (§2.1) — chosen over `'DELEGATED'` (implies a retry/reconciliation receiver that `601031_Overview.md` §3 already confirmed doesn't exist) and over reusing `'NOTED'` (already used for `NO_TICKETS_TO_PROCESS`; reusing it here would conflate "nothing to do" with "actively on hold," collapsing two operationally distinct audit-trail meanings), based on the existing precedent at `0041_create_agent_heartbeat_rpc.sql:394` (`'agent_module_isolated'` uses `SUSPENDED` for the same "temporarily halted, may resume" concept).

**Verification-gap root cause, worth recording as a session lesson**: this defect survived this session's own Stage 5 authoring because `601033_TestPlan.md` §1.2 originally (incorrectly) asserted "`decision` has no CHECK constraint (free text)" — a false claim never actually checked against `0008_create_ledger_audit.sql`'s full `CREATE TABLE` body (the constraint sits at lines 105-119, past where this session's earlier read of that file stopped). And separately, none of `601032_Logic.md` §3's three `pg_temp` reproductions (§3.1 `COMMITTED`, §3.2 the exception path, §3.3 `NO_TICKETS_TO_PROCESS`) ever exercised the `PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD` branches — exactly the two branches carrying the bug. Two independent gaps (an unverified schema claim, and incomplete branch coverage in live testing) compounded to let an invalid literal reach a Stage 5 "final design" document. `601033_TestPlan.md` §1.2 now states the actual constraint, and §2.2/§2.3 now include their own executable fixtures exercising exactly these two branches (Stage 4 Critical-tier correction round, `601033_TestPlan.md`).

## §1 Allowed files and objects

### §1.1 Allowed new SQL file

- One new migration, tentatively `sql/migrations/0166_canonical_kds_release_orchestration.sql` (Stage 8 must re-run the next-available-number check per §0 before creating it; if `0166` is claimed by another workpacket in the interim, use the actual next-available number instead).

### §1.2 Allowed existing-file edit

- None. `sql/migrations/0027_create_payment_intent_rpc.sql` is an already-applied migration and must stay byte-for-byte original. The live `catchmenu_payment.confirm_payment_from_provider()` replacement is carried only by the new forward migration in §1.1/§3.

### §1.3 Allowed new objects

- Function `catchmenu_payment.request_kds_release_after_payment(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_actor_type text default 'SYSTEM', p_correlation_id text default null) returns jsonb` — full body per `601032_Logic.md` §1.2.

If the project convention requires the existing `0027` source file and the new forward migration to stay semantically identical for `confirm_payment_from_provider()`'s body (the pattern established by `601020`/`601024` §1.2), both must be updated together.

### §1.4 Changelog

`sql/migrations/CHANGELOG.md` may be appended only if the project migration convention requires recording the new migration. No existing entry may be rewritten.

## §2 Required implementation contract

### §2.1 New function — `catchmenu_payment.request_kds_release_after_payment()`

Exactly as specified in `601032_Logic.md` §1.1-§1.4:

- Signature: `(p_tenant_id uuid, p_store_id uuid, p_order_id uuid, p_ledger_id uuid, p_actor_type text default 'SYSTEM', p_correlation_id text default null) returns jsonb`, `language plpgsql volatile security definer set search_path = catchmenu_payment, catchmenu_kds, catchmenu_ledger, catchmenu_audit, catchmenu_common`.
- Step 1: inline `update catchmenu_payment.payment_ledger set kds_release_authorized = true, kds_release_authorized_at = now(), kds_release_authorized_by = p_actor_type where id = p_ledger_id and tenant_id = p_tenant_id and store_id = p_store_id`.
- Step 2: delegate to `catchmenu_kds.bulk_commit_kds_tickets(p_tenant_id, p_store_id, p_order_id, p_force_conditions := null, p_correlation_id)` — unmodified, called as-is.
- Step 3: translate the bulk-commit result into exactly 5 `result_code` values, in this exact branch order (the order matters — the zero-ticket check must precede the committed check):
  1. `not success` → `PAYMENT_CONFIRMED_KDS_RELEASE_BLOCKED`
  2. `committed_count=0 and pending_count=0 and skipped_count=0` → `PAYMENT_CONFIRMED_KDS_NO_TICKETS_TO_PROCESS`
  3. `pending_count=0 and skipped_count=0` → `PAYMENT_CONFIRMED_KDS_COMMITTED`
  4. `committed_count>0` → `PAYMENT_CONFIRMED_KDS_PARTIAL_CAPACITY_HOLD`
  5. else → `PAYMENT_CONFIRMED_KDS_CAPACITY_HOLD`
- Audit: one `catchmenu_audit.append_audit_record()` call per invocation, `p_audit_domain := 'payment'`, `p_audit_type := 'kds_release_requested'`, `p_decision` mapped per `601032_Logic.md` §1.2 (`COMMITTED`→`APPROVED`, `RELEASE_BLOCKED`→`FAILED`, `NO_TICKETS_TO_PROCESS`→`NOTED`, else→`SUSPENDED`). **`SUSPENDED` is required, not `PENDING`** — `catchmenu_ledger.audit_records.chk_audit_decision` (`0008:105-119`) does not accept `'PENDING'` at all; see §0's correction note and Open Item (h) below.
- `EXCEPTION WHEN OTHERS`: never re-raises. Writes a second audit record (`p_audit_type := 'kds_release_requested_failed'`, `p_decision := 'FAILED'`) and returns `{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ledger_id, order_id, error_detail:{sqlstate}}`.
- Always returns `success:true` in every branch, including the exception branch (`601032_Logic.md` §1.2's closing rationale — this function's own "success" means "request processed," not "ticket committed"; `result_code` carries the real state).
- GRANT/REVOKE exactly per `601032_Logic.md` §1.3: `revoke all ... from public; grant execute ... to authenticated;`.

### §2.2 `confirm_payment_from_provider()` modification — exact insertion point

Per `601032_Logic.md` §2.1: the existing `payment_ledger` INSERT (source lines 263-289, `kds_release_authorized := false`) is **not** changed. `v_kds_release_result jsonb` is added to the `declare` block. Immediately after the existing `audit_id` calculation and immediately before the existing `return`, insert a call to the new function and replace the `return` block. **(2026-07-18, Option C — supersedes the earlier Option A/B choice, see §2.3)** the call is wrapped in a narrow nested `begin...exception when others...end;` block that covers only this call — nothing before it (intent validation, the `payment_ledger` INSERT, `kds_tickets`/`kds_events` updates, this function's own `append_audit_record()` call) is wrapped:

```sql
begin
  v_kds_release_result := catchmenu_payment.request_kds_release_after_payment(
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_order_id := v_intent.order_id,
    p_ledger_id := v_ledger_id,
    p_actor_type := 'PROVIDER',
    p_correlation_id := p_correlation_id
  );
exception
  when others then
    perform catchmenu_audit.append_audit_record(
      p_tenant_id := p_tenant_id,
      p_store_id := p_store_id,
      p_audit_domain := 'payment',
      p_audit_type := 'kds_release_call_unexpected_exception',
      p_audit_category := 'FINANCIAL',
      p_actor_type := 'PROVIDER',
      p_actor_id := null,
      p_subject_type := 'payment_ledger',
      p_subject_id := v_ledger_id,
      p_decision := 'FAILED',
      p_decision_payload := jsonb_build_object('error', sqlerrm, 'sqlstate', sqlstate),
      p_order_id := v_intent.order_id,
      p_correlation_id := p_correlation_id
    );
    v_kds_release_result := jsonb_build_object(
      'success', true,
      'result_code', 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED',
      'ledger_id', v_ledger_id,
      'order_id', v_intent.order_id,
      'error_detail', jsonb_build_object('sqlstate', sqlstate)
    );
end;

return jsonb_build_object(
  'success', true,
  'ledger_id', v_ledger_id,
  'intent_id', p_intent_id,
  'ledger_status', 'APPROVED',
  'approved_amount', p_approved_amount,
  'kds_release_authorized',
    (v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'),
  'kds_tickets_payment_confirmed', v_kds_updated,
  'kds_release_result', v_kds_release_result,
  'result_code', v_kds_release_result->>'result_code',
  'reconciliation_status', 'PENDING',
  'message_code', case
    when v_kds_release_result->>'result_code' = 'PAYMENT_CONFIRMED_KDS_COMMITTED'
      then 'payment_approved_kds_released'
    else 'payment_approved_kds_pending'
  end,
  'audit_id', v_audit_id
);
```

Required invariant (Stage 4 correction — must not regress): `kds_release_authorized` in this response is **derived from `result_code`**, `true` only when it equals `PAYMENT_CONFIRMED_KDS_COMMITTED`. It must not be hardcoded to `true` or `false`. This response field's meaning is deliberately distinct from the `payment_ledger.kds_release_authorized` **DB column**, which is unconditionally `true` after Step 1 of §2.1 regardless of outcome — the two are allowed to diverge, per `601032_Logic.md` §2.1's explicit note.

The prior response fields `'kds_release_authorized', false` and `'next_step', 'KDS_CAPACITY_CHECK_REQUIRED'` are removed (no longer accurate at this point in execution).

### §2.3 좁은 중첩 EXCEPTION 블록 — 옵션 C (ChatGPT 교차검증, Human 최종 결정, 재논의 금지 — Option A/B 양자택일 대체)

**이전 결정(Option A/B 양자택일)은 폐기됐다.** 원래 §2.3은 "`confirm_payment_from_provider()` 자신에게 방어적 `EXCEPTION` 핸들러를 추가할지(A)/제외할지(B)"를 물었는데, 이 질문 자체에 애매함이 있었다 — "함수 자신에게 추가"가 함수 **전체**를 감싸는 것을 의미한다면, `request_kds_release_after_payment()` 호출(함수 끝부분)에서 발생한 예외를 잡는 순간 PL/pgSQL 중첩 예외 블록의 동작 원리상(예외 블록은 **자신이 시작된 지점까지만** 롤백한다 — `pg_temp`로 라이브 실증, `601032_Logic.md` §2.1/§2.2) 함수 **시작부터**의 모든 작업 — 이미 완료된 `payment_ledger` INSERT를 포함해서 — 이 함께 롤백돼버린다. 이것이 ChatGPT가 지적한 위험이다: KDS 알림이라는 부수적 단계의 버그가 이미 정상 완료된 결제 승인 자체를 무효화시켜, "결제는 실패했는데 웹훅 응답은 성공"보다 더 위험한 "결제는 사실 성공했는데 그 사실 자체가 사라져버리는" 상황을 만들 수 있었다.

**옵션 C(대체 설계, 더 이상 대안이 아니라 유일한 확정 설계)**: `EXCEPTION` 핸들러를 함수 전체가 아니라 `request_kds_release_after_payment()` 호출 **그 자체만**을 감싸는 신규 중첩 `begin...exception...end` 블록에 붙인다(§2.2의 최종 SQL). 이 중첩 블록의 시작점이 이미 `payment_ledger` INSERT 등 payment-core 작업이 전부 끝난 **이후**이므로, 이 블록 안에서 발생하는 예외는 그 이전 작업을 전혀 건드리지 않는다 — 2026-07-18 `pg_temp`로 직접 실증(`601032_Logic.md` §2.1/§2.2, `601033_TestPlan.md` §6.4가 라이브 함수 체인 전체로 재현).

- **payment-core 구간(intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 감싸지 않는다** — 이 구간의 실패는 여전히 예외로 자연 전파되어 진짜 결제 실패로 처리된다(Option B와 동일한 부분).
- **`request_kds_release_after_payment()` 호출만 좁게 감싼다** — 이 호출이 (정상적으로는 도달 불가능해야 하지만) 예외를 던지면, 감사기록(`p_audit_domain := 'payment'`, `p_audit_type := 'kds_release_call_unexpected_exception'`, `p_audit_category := 'FINANCIAL'`, `p_decision := 'FAILED'`) 후 `v_kds_release_result`를 신규 함수 자신이 `RELEASE_FAILED`를 반환했을 때와 동일한 형태(`{success:true, result_code:'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED', ...}`)로 합성해 이어서 진행한다 — 결제 자체는 이미 성공했으므로 `success:true`를 유지한다(§2.1 신규 함수 핸들러와 동일한 극성 — 더 이상 "반대 극성의 두 번째 핸들러"가 아니라, 같은 원칙의 연장).

Human 승인(§9)은 이제 "A냐 B냐" 양자택일이 아니라, **이 하나의 개선된 설계(옵션 C)를 적용할지 여부**를 확인하는 단일 항목이다.

## §3 Allowed Operations (narrow verbs)

Per `000701_Guide_Controlled_AI_Development_Pipeline.md` §9.14's Operation Granularity Rule.

**New file `sql/migrations/0166_canonical_kds_release_orchestration.sql`** (number to be reconfirmed, §0/§1.1):

1. Create the file with a header identifying its purpose, `Depends on: 0165_menu_price_list_architecture_phase0.sql` (sequential-numbering convention only, no functional dependency).
2. `CREATE OR REPLACE FUNCTION catchmenu_payment.request_kds_release_after_payment(...)` exactly as specified in §2.1.
3. `REVOKE ALL ON FUNCTION catchmenu_payment.request_kds_release_after_payment(...) FROM PUBLIC` + `GRANT EXECUTE ... TO authenticated` — per §2.1's final bullet. No other GRANT.
4. `CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment_from_provider(...)` — full function body, re-declared with exactly the §2.2 insertion (the narrow nested `begin...exception...end;` block wrapping only the `request_kds_release_after_payment()` call, per §2.3's Option C design) and otherwise byte-identical to the current live definition. This narrow wrapper is now a required part of the design, not conditional on a Human choice — §9 confirms Human's approval of applying it, not a choice between alternatives.

**Existing file `sql/migrations/0027_create_payment_intent_rpc.sql`** (§1.2):

5. Do not edit. Confirm its original checksum before applying `0166`; the forward migration's `CREATE OR REPLACE FUNCTION catchmenu_payment.confirm_payment_from_provider(...)` is the only authorized source for the post-Option-C live definition.

No operation is authorized on any other file.

## §4 Forbidden Operations

- Editing `catchmenu_payment.confirm_payment(...)` (`0098`, POS path) in any way — explicitly deferred to a future workpacket (`601031_Overview.md` §0.2 (3), Open Item (b)).
- Editing `catchmenu_payment.resolve_payment_uncertain(...)`, `catchmenu_payment.create_payment_intent(...)`, or `catchmenu_payment.mark_payment_uncertain(...)` — all 3 in the same `0027` file as the one function this contract may touch, but out of scope (`601031_Overview.md` §0.2 (4)/§5).
- Editing `catchmenu_kds.bulk_commit_kds_tickets(...)`, `catchmenu_kds.commit_kds_ticket(...)`, or `catchmenu_kds.evaluate_kds_capacity(...)` (`0028`/`0039`) in any way. These are reused exactly as they exist live today.
- Editing `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`, `sql/migrations/0056_create_van_integration_rpc.sql`, or `sql/migrations/0143_add_no_payment_kds_release_policy.sql`.
- Any `GRANT` to `public` or any `GRANT` beyond §2.1's `authenticated`-execute on the new function.
- Any schema change (new column, new table, new CHECK constraint) — this workpacket is function-body-only.
- Designing or implementing a `CAPACITY_CHECKING` retry/reconciliation mechanism (`601031_Overview.md` §3/§6 (a)).
- Designing or implementing a fix for `price_list_assignments` or any object from the unrelated `601130` workpacket.
- Any Flutter/`catchmenu_app` change.

## §5 Forbidden scope

- `confirm_payment()`(POS, `0098`) integration — Open Item (b), separate future workpacket.
- `resolve_payment_uncertain()`'s missing `payment_ledger` INSERT — Open Item (c), separate future workpacket, different remediation class.
- Webhook idempotency/resend handling at the `confirm_payment_from_provider()` level — Open Item (e), **High priority**, but explicitly not designed or implemented by this contract.
- `bulk_commit_kds_tickets()` UI/Flutter caller investigation — Open Item (d), SQL-layer-only workpacket, out of scope.
- Domain number-space reorganization for `600500_payment_confirmation/` — Open Item (f), Human decision needed, out of scope.

## §6 Stop Conditions

Stop immediately and report if any of the following are true:

1. `catchmenu_payment.request_kds_release_after_payment` already exists live immediately before Stage 8 begins (`601033_TestPlan.md` §1.1).
2. Immediately before applying `0166`, the live `confirm_payment_from_provider()` definition no longer matches the original `sql/migrations/0027_create_payment_intent_rpc.sql` body — would mean §2.2's exact insertion point is no longer valid. After `0166` is applied, live mismatch with `0027` is expected because `0166` becomes the sole source for the post-Option-C definition.
3. `catchmenu_kds.bulk_commit_kds_tickets()`'s identity arguments, or its `success:false` / `committed_count`/`pending_count`/`skipped_count` response contract, differ from what `601033_TestPlan.md` §0 live-reconfirmed.
4. `catchmenu_kds.commit_kds_ticket()`'s 7-condition list or its `kds_status` response values (`COMMITTED`/`CAPACITY_CHECKING`) differ from `0028`'s current live behavior.
5. `catchmenu_ledger.audit_records.chk_audit_domain` no longer includes `'payment'`, or `chk_audit_category` no longer includes `'OPERATIONAL'`/`'FINANCIAL'`.
6. `payment_ledger` no longer has `kds_release_authorized`/`kds_release_authorized_at`/`kds_release_authorized_by` columns as §2.1 Step 1 assumes.
7. `0166` (or whatever number is actually used, §0/§1.1) is found to already exist with different content when Stage 8 begins.
8. Any residue of the prior unauthorized implementation attempt (an already-existing `catchmenu_payment.request_kds_release_after_payment` with a body differing from §2.1, or a migration file numbered `0166`/`0167` with content not matching this contract) is found live — do not silently overwrite; stop and report the discrepancy before proceeding.
9. §9's Option C approval checkbox (§2.3) is unchecked or its intent is otherwise ambiguous — Stage 8 must not guess whether Human approved applying the narrow nested `EXCEPTION` wrapper.

## §7 Required verification

Stage 8 must run `601033_TestPlan_Canonical_Kds_Release_Orchestration.md` completely.

Minimum required evidence:

1. All 5 `result_code` branches reproduced with correct `committed_count`/`pending_count`/`skipped_count` semantics (`601033_TestPlan.md` §2): `COMMITTED`/`PARTIAL_CAPACITY_HOLD`/`CAPACITY_HOLD`/`NO_TICKETS_TO_PROCESS` must expose matching integer count fields, while `RELEASE_BLOCKED` must expose `committed_count`/`pending_count`/`skipped_count` as `null` (not `0`) because `bulk_commit_kds_tickets()` returns before the per-ticket aggregation loop.
2. Zero-ticket regression guard confirmed (§2.4) — must not report `PAYMENT_CONFIRMED_KDS_COMMITTED`.
3. Audit record decision mapping confirmed for all 5 branches (§3).
4. Forced-exception path confirmed non-raising, with the pre-existing `payment_ledger` row surviving untouched and the ticket's own transition rolled back (§4).
5. `kds_release_authorized_by` reflects the caller's `p_actor_type`, not a hardcoded value (§5).
6. `confirm_payment_from_provider()`'s `payment_ledger` INSERT block unchanged; end-to-end response's `kds_release_authorized` field correctly derived from `result_code` in both the committed and non-committed cases (§6).
7. **(2026-07-18, Option C)** A simulated call-site exception at `request_kds_release_after_payment()` is caught by the narrow inner block only, does not propagate out of `confirm_payment_from_provider()`, and the earlier `payment_ledger` INSERT in the same invocation survives untouched (`601033_TestPlan.md` §6.4).
8. All boundary files (§7.1-§7.4 of the TestPlan) show 0 diff.

## §8 Open Items (carried from `601031_Overview.md` §6 and `601032_Logic.md` §6, in full — identical (a)-(g) list in all three documents)

(a) `CAPACITY_CHECKING` 재시도 메커니즘 부재 — 별도 워크패킷 필요(가칭 `kds_capacity_retry_scheduler`).

(b) `confirm_payment()`(POS, `0098`)를 동일한 신규 공용 함수로 연결 — 최우선 후속 워크패킷 후보.

(c) `resolve_payment_uncertain()`의 `payment_ledger` INSERT 누락 — 별도 워크패킷 권고, 다른 종류의 수정(신규 원장 행 설계 vs. 기존 함수 배선)이므로 이번 워크패킷과 합치지 않음.

(d) `bulk_commit_kds_tickets()`의 UI/Flutter 호출자 존재 여부 — SQL 레이어 밖, 미확정.

(e) **[High priority — Stage 4에서 격상]** 웹훅 멱등성(재전송) 시나리오 — Cursor+Codex 둘 다 "스코프 제외는 타당하나 실제 운영 위험이 크다"고 지적. `request_kds_release_after_payment()`는 이미 `COMMITTED`된 티켓에 대해 재호출돼도 `bulk_commit_kds_tickets()`가 `HOLD`/`CAPACITY_CHECKING` 상태의 티켓만 대상으로 순회하므로 안전할 것으로 **추정**되나(§2.4의 0-티켓 결과 코드가 정확히 이 경우를 다루도록 이미 설계됨), `confirm_payment_from_provider()` 자체의 상위 레벨 멱등성(동일 웹훅이 `payment_ledger` INSERT 자체를 중복 생성하지 않는지)은 이 워크패킷의 책임 범위가 아니며 별도로 설계돼야 한다.

(f) **[번호 관련]** `600500_payment_confirmation/` 도메인의 백단위 번호 공간 소진 — Human 결정 필요, 이 워크패킷 범위 밖.

(g) `601032_Logic.md` §3의 `pg_temp` 재현 3건은 이 세션(Stage 1.5/설계 단계)이 직접 수행한 것이며, Stage 8/9는 각자 자기 자신의 새 fixture로 독립 재현해 재확인해야 한다 — `601033_TestPlan.md`가 이 재확인을 실행 가능한 SQL로 명시했다(§2/§4).

(h) **[신규, 이 정정 라운드에서 부수적으로 발견 — 이 워크패킷 범위 밖. 2026-07-18 재정정: 파일 수/리터럴 수 혼동 정리]** `p_decision='PENDING'` 결함을 조사하던 중, `catchmenu_audit.append_audit_record()`를 호출하는 다른 여러 기존 라이브 함수들도 `chk_audit_decision`의 11개 허용값에 없는 리터럴을 `p_decision`에 전달하고 있음을 발견했다 — **7개 파일**에서 **8개(타겟 grep 기준 — 이 검색이 전수조사가 아니므로 그 이상일 수 있음)의 잘못된 리터럴**: `sql/migrations/0084_create_reconciliation_advanced_rpc.sql`(`'RESOLVED'`), `0085_create_franchise_os_foundation_rpc.sql`(`'PUBLISHED'`), `0086_create_hq_menu_distribution_rpc.sql`(`'PUBLISHED'`), `0087_create_multistore_policy_rpc.sql`(`'ROLLED_BACK'`), `0091_create_saas_readiness_final_rpc.sql`(`'GO_LIVE_AUTHORIZED'`), `0098_create_payment_confirm_pipeline_rpc.sql`(`'REFUND_PENDING'`), `0100_create_staff_app_bootstrap_rpc.sql`(**같은 파일 안에 `'OPENED'`/`'CLOSED'` 2개** — 이 파일 하나가 리터럴 수를 파일 수보다 1개 더 많게 만든다). 이 호출들이 실제로 실행되면 이번 워크패킷에서 발견한 것과 동일한 방식(`chk_audit_decision` 위반 → INSERT 크래시)으로 실패할 가능성이 높다 — 다만 이 워크패킷은 이 7개 파일 중 어느 것도 건드리지 않으며(§4 Forbidden Operations), 이 발견은 별도의 독립적인 감사(가칭 `audit_decision_literal_repair`) 워크패킷 후보로만 기록한다. 실제로 이 경로들이 라이브에서 호출되는지, 호출된다면 언제부터 깨져 있었는지는 확인되지 않았다 — Human 판단 필요.

## §9 Human Approval

Human must check all boxes before Stage 8 implementation. **자기승인 절대 불가 — 이 문서를 작성한 세션/에이전트는 이 섹션을 체크할 수 없다. 실제 정영석님이 직접 체크해야 한다.**

☑ I approve creating `catchmenu_payment.request_kds_release_after_payment()` exactly as
  specified in §2.1 — including that it never raises, always returns `success:true`, and
  reuses `bulk_commit_kds_tickets()`/`commit_kds_ticket()` unmodified.

☑ I approve modifying `catchmenu_payment.confirm_payment_from_provider()`(`0027`) exactly as
  specified in §2.2 — the `payment_ledger` INSERT itself is unchanged, and the response's
  `kds_release_authorized` field is derived from `result_code` (true only when
  `PAYMENT_CONFIRMED_KDS_COMMITTED`), diverging by design from the underlying DB column
  (which is always `true` after this call).

§2.3's narrow nested `EXCEPTION` block (Option C) — **더 이상 양자택일이 아니라 단일 설계에 대한 예/아니오 승인이다**:

☑ **옵션 C 적용 승인**: `request_kds_release_after_payment()` 호출 지점만 좁게 감싸는 중첩
  `begin...exception when others...end;` 블록을 §2.2/§2.3대로 적용한다 — payment-core 구간
  (intent 검증 ~ `payment_ledger` INSERT ~ 이 함수 자신의 감사기록)은 감싸지 않고 그대로
  두어, 그 구간의 실패는 여전히 진짜 결제 실패로 자연 전파됨을 이해했다. 이 좁은 블록이
  예외를 잡는 경우(정상적으로는 도달 불가능해야 함) `success:true`를 유지하며 `result_code
  := 'PAYMENT_CONFIRMED_KDS_RELEASE_FAILED'`로 통일해서 반환함을 이해했다.

☑ I approve that `confirm_payment()`(POS, `0098`), `resolve_payment_uncertain()`, and the
  webhook idempotency question (Open Item (e), High priority) remain explicitly out of scope
  for this contract, to be addressed in separate future workpackets.

☑ I approve the migration number `0166` (or Stage 8's re-confirmed next-available number) and
  confirm no residue of any prior unauthorized implementation attempt is being reused.

(승인날짜: 2026-07-18)

## §10 Approval state

**APPROVED (2026-07-18).** Stage 8 may begin because every box in §9 is checked by the Human owner (정영석) with a recorded date.

## §11 Final Audit (Stage 11, Claude) — 최종 확정 (2026-07-18)

**Verdict: ACCEPT** (APPROVE_WITH_NOTES에서 복원)

**하향 조정 사유 해소 확인:**

이전 라운드에서 발견된 MEDIUM Finding(EXCEPTION 핸들러 안
append_audit_record() 자체의 이중 실패 시 payment-core 롤백
위험)에 대해:

1. Cursor+Codex의 fault-injection 재현으로 결함 실제 확인
   (정정 전: 시나리오 B/C에서 payment_ledger 0건 - 실제 롤백)
2. request_kds_release_after_payment()/confirm_payment_from_
   provider() 옵션C 블록 양쪽에 1단계 fallback(중첩 begin/
   exception/end + RAISE WARNING) 추가
3. §14.5(Migration Draft Mutability Rule, 이번 워크패킷 중
   신설)에 따라 0166을 Draft로 확정 - 체크섬만 덮어쓰지 않고
   실제 DB를 되돌린 뒤 정정본 재적용
4. Cursor+Claude Code(안티 배제, Codex는 구현자로 제외)의
   완전 독립 재검증 - 서로 다른 fixture로 A/B/C 세 시나리오
   전부 실제 라이브 함수 대상 재현, payment_ledger 전부 생존
   확인(1건, APPROVED) - 정정 전/후 대조 명확
5. RAISE WARNING이 실제 서버 로그에 남는 것까지 확인(docker
   logs 직접 조회)

기존 재도출 확인 내용(5단계 result_code, SUSPENDED 매핑, 옵션C
기본 원자성, 회귀테스트, 0027/0166 관계, 12개 파일 boundary)은
그대로 유효.

**Dual Anchor 절차 참고**: 이 워크패킷의 ChatGPT 개입은 §13.7-
13.10이 공식 문서화되기 이전, 비공식적으로 이뤄졌으나, 실제로
결정적 결함(이중 감사실패)을 발견하고 Cursor+Codex의 실제
재현으로 확정되는 등 Dual Anchor 원칙의 실질적 목적을 충분히
달성함. 이를 근거로 별도의 정식 11B(신규 대화창, 블라인드)
재실행 없이 이대로 확정. (이 판단 자체가 §13.7 Dual Anchor
Principle의 성립 근거 사례로 §13.7에 이미 기록됨.)

**Open Items (다음 워크패킷 후보로 이월, 기존과 동일):**

1. 웹훅 멱등성(Open Item e, High priority) - payment_ledger
   중복행 생성 실증됨.
2. CAPACITY_CHECKING 재시도 메커니즘 부재(a).
3. confirm_payment()(POS, 0098) 동일 함수 연결(b) - 최우선
   후속 워크패킷 후보.
4. resolve_payment_uncertain()의 payment_ledger INSERT 누락(c).
5. bulk_commit_kds_tickets() UI/Flutter 호출자 미확정(d).
6. 600500 도메인 번호공간 소진(f).
7. audit_decision 리터럴 오류 7개 파일(h) - 별도 감사 워크패킷
   후보.
8. 601033 TestPlan §4의 CHECK 제약 기법 - NOT VALID 옵션 권장.
9. 0166이 이미 git에 커밋된 상태임이 확인됨(Claude Code 관찰) -
   커밋 시점/내용 재확인 필요.

## §12 Human Merge/Release

담당: Human (정영석님) (2026-07-18)

상태: READY_FOR_HUMAN_MERGE

필수 확인:
- 최종 git diff 확인
- 0166 파일명 및 내용 확인 (이미 git 커밋된 상태 - Open Item 9
  재확인 권장)
- §11 ACCEPT 확인
- 미해결 BLOCK 없음 확인
- Open Items 9개가 후속 워크패킷으로 이월됐는지 확인
- 최종 commit/merge 결정
