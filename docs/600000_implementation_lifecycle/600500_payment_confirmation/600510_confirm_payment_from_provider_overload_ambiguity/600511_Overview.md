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
