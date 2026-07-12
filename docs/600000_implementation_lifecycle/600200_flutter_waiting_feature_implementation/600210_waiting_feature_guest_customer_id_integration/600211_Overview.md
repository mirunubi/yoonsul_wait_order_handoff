# 600211_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-12

## Change ID

`waiting_feature_guest_customer_id_integration`

## §0 선행 확인 재검증 결과

`600203_DecisionLog.md` Decision 1이 이 change의 Overview 작성을 `600120_guest_customer_bootstrap_rpc`의 RPC 시그니처 확정 뒤로 미뤄뒀다. 이번 턴에 그 전제 조건을 직접 재확인했다:

- `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600120_guest_customer_bootstrap_rpc/600127_Audit.md` — `## Final Audit Decision` = **ACCEPT** (문서 11번째 줄, 42번째 줄 "Final status: ACCEPT." 재확인)
- `sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql` — 실존 확인 (19,006 bytes), `git show --stat f697e52`로 이 파일과 `0150_widen_event_domain_constraint.sql`이 해당 커밋에 실제 포함됨을 재확인

→ Decision 1의 전제 조건 충족. `600202_NavigationMap.md`의 이 change 상태를 "blocked — 600120 pending"에서 "unblocked — 600120 completed 2026-07-11"로 이번 턴에 갱신함(diff는 이번 턴 Output 참고).

### §0.1 `SharedPreferences`/`session_id` 명칭 충돌 조사 근거 (Human 결정 1의 배경)

```
grep -rn "SharedPreferences" catchmenu_app/lib/      → 0건 (현재 어디서도 미사용)
grep -rn "session_id|sessionId" catchmenu_app/lib/   → 1건: rpc_caller.dart:205  'p_log_session_id': logSessionId
grep -rn "guest_customer_id|customerId|customer_id" catchmenu_app/lib/ → 0건
```

리터럴 키 충돌은 없었으나, `register_waiting()`(`0149`/`0115` 공통)의 응답 JSON이 이미 `'session_id'` 키로 실제 `catchmenu_pos.order_sessions.id` 값을 반환하고 있어, "session_id"라는 이름이 (a) `RpcCaller.logSessionId`(dev audit 로그 그룹핑)와 (b) `order_sessions.id`(실제 대기 세션) 두 가지 무관한 개념으로 이미 쓰이고 있음을 확인했다. **Human 결정 1(2026-07-11)**: 이전 설계의 `guest_session_id`를 **`guest_waiting_session_id`**로 개명, `guest_customer_id`는 유지. 상세는 `600212_Logic.md` §2.1/§4.

### §0.2 `main.dart` 확인 근거 (Human 결정 2의 배경)

`catchmenu_app/lib/main.dart`를 직접 읽어 확인한 결과, `CatchMenuApp.build()`가 `MaterialApp(... home: _BootScreen(...))` 형태로 `MaterialApp`을 직접 사용 중이며 `MaterialApp.router`가 아니었다. `go_router` 배선은 이 생성자 자체를 바꿔야만 성립하므로(`MaterialApp`과 `MaterialApp.router`는 양립 불가능한 별개 진입점), 별도 파일(`lib/app/router.dart`)만으로는 완결되지 않는다. **Human 결정 2(2026-07-11)**: `main.dart` 수정을 이번 change 범위에 포함(분리 불가). 상세는 `600212_Logic.md` §2.2/§5, 부팅 흐름 영향 관련 Open Question은 §7-4.

### §0.3 호출 순서 정정 — `bootstrap_customer_app_v2()`가 먼저 (Human 결정, 2026-07-11, 재논의 금지)

`600213_TestPlan.md` §0 작성 중 `sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql`의 실제 반환 `jsonb_build_object(...)`를 직접 재확인한 결과, 이 문서(§Change Summary 등)와 `600212_Logic.md`가 이전에 전제했던 **"`register_waiting()`이 최초 호출이고 그 응답에서 `customer_id`를 받는다"는 서술은 틀렸다**:

- `register_waiting()`의 실제 반환 `p_data`에는 `session_id`/`wait_number`/`queue_position`/`guest_count`/`guest_locale`/`est_wait_minutes`/`pre_order_enabled`/메시지 필드만 있고 **`customer_id` 키 자체가 없다** (`'customer_id', p_customer_id`가 등장하는 곳은 내부 `notify_channel` 푸시 알림 payload뿐 — 클라이언트 응답 아님).
- `bootstrap_customer_app_v2()`는 `p_customer_id`가 채워진 뒤 `'customer': {'id': v_customer.id, ...}` 형태로 **중첩된 `customer_id`를 실제로 반환한다.**

**Human 결정(2026-07-11)**: 게스트 `customer_id` 획득 순서를 다음으로 확정한다 — **① 앱 부팅 시 `bootstrap_customer_app_v2()` 호출(저장된 `customer_id`가 있으면 전달, 없으면 `null`) → ② 응답의 `data.customer.id`를 `guest_customer_id`로 저장(신규 게스트면 여기서 최초 발급) → ③ 이후 `register_waiting()` 호출 시 그 `guest_customer_id`를 `p_customer_id`로 전달 → ④ `register_waiting()` 응답의 `session_id`를 `guest_waiting_session_id`로 저장(이 필드는 여전히 `register_waiting()`에서만 나옴).** 이 문서와 `600212_Logic.md`의 아래 서술 전체를 이 순서로 소급 정정한다. `600213_TestPlan.md`/`600214_ChangeContract.md`는 이미 이 순서로 작성되어 있어 재정정하지 않는다.

## 이전 Cursor Stage 1 스캔 사실 재검증 (재논의 아님, 유효성만 확인)

| 사실 | 재검증 결과 |
|---|---|
| `catchmenu_app/lib/features/waiting/`에 `.dart` 파일 0개 (README만) | `find catchmenu_app/lib/features/waiting -type f` → `README.md` 1개뿐. 여전히 유효 |
| `register_waiting()`이 `p_customer_id`를 파라미터로 받음 | `0149`의 `create or replace function catchmenu_pos.register_waiting(...)` 시그니처에 `p_customer_id uuid default null` 확인. 추가로, 이번 재검증에서 `p_customer_id is null`이면 함수 내부(L181)가 자동으로 `catchmenu_store.get_or_create_guest_customer(...)`를 호출해 채우는 것도 확인 — 이 사실은 `600203_DecisionLog.md` Decision 3(당시 미확정)이 이제 SQL로 실증된 것 |
| `go_router` 미배선 (pubspec에 선언만) | `pubspec.yaml`에 `go_router: ^13.0.0` 선언 확인. `catchmenu_app/lib/app/` 디렉터리 자체가 아직 존재하지 않음(`find` 결과 없음) — "미배선"보다 더 이전 단계, 즉 배선 파일 자체가 없는 상태 |
| `rpc_caller.dart` 존재, `forbiddenClientRpcs`에 `register_waiting`/`bootstrap_customer_app_v2` 없음 (허용됨) | `catchmenu_app/lib/core/constants/app_constants.dart`의 `forbiddenClientRpcs = {'release_kds_after_payment'}` (1개뿐) 확인. 두 함수 모두 클라이언트 직접 호출 허용 대상 |

## Change Summary

`catchmenu_app`의 waiting(대기 등록) 기능에서, `600120`이 확정한 게스트 `customer_id` 자동 부여 흐름(§Logic 참고)을 실제로 소비하도록 Flutter 측 설계를 만든다. 이번 산출물(Stage 1.5)은 문서만 — `.dart` 파일은 생성하지 않는다.

600120 덕분에 Flutter 쪽 로직이 오히려 단순해졌다: 게스트 upsert 자체는 서버(`get_or_create_guest_customer()`)가 `p_customer_id is null`일 때 자동 처리하므로, 클라이언트는 (1) 앱 부팅 시 `bootstrap_customer_app_v2()`를 `p_customer_id=null`로 호출하고, (2) 응답의 `data.customer.id`를 `customer_id`로 저장했다가, (3) 이후 `register_waiting()` 등 다른 호출부터 그 값을 명시적으로 전달하기만 하면 된다(§0.3 — `register_waiting()` 자체는 응답에 `customer_id`를 주지 않으므로 최초 발급처는 `bootstrap_customer_app_v2()`다).

## Candidate Affected Files (신규 설계 대상 — 이번 턴에 생성하지 않음)

| 파일 | 역할 | 상태 |
|---|---|---|
| `catchmenu_app/lib/features/waiting/` 하위 신규 `.dart` 파일들 (화면/상태관리, 파일 단위는 `600212_Logic.md`에서 구체화) | 대기 등록/상태 조회 UI 및 RPC 호출 | 신규 |
| `catchmenu_app/lib/app/router.dart` | `go_router` 배선 | 신규 (`lib/app/` 디렉터리 자체도 신규) |
| `catchmenu_app/lib/core/storage/` 하위 신규 파일(가칭 `guest_session_store.dart`) | `SharedPreferences` 래퍼 — 게스트 `guest_customer_id`/`guest_waiting_session_id` 저장 (키 이름은 §0.1 조사 근거로 개명됨) | 신규 (`core/storage/`는 현재 존재하지 않음 — `core/`에는 현재 `constants/`, `errors/`, `supabase/`만 있음, 이번 턴에 `find`로 재확인) |
| `catchmenu_app/lib/main.dart` | `MaterialApp` → `MaterialApp.router(routerConfig: router, ...)` 전환 — **Human 결정 2(2026-07-11/12)로 이번 change 범위에 포함**. go_router 배선의 구조적 전제조건이라 분리 불가(§0.2 조사 근거, 상세 설계는 `600212_Logic.md` §5) | 기존 파일 수정 (신규 아님) |

## Direct Dependencies

- `catchmenu_pos.register_waiting(...)`, `catchmenu_store.bootstrap_customer_app_v2(...)` — `0149`가 patch한 최신 시그니처(둘 다 `p_customer_id uuid default null`, null이면 내부에서 `get_or_create_guest_customer()` 자동 호출)
- `catchmenu_app/lib/core/supabase/rpc_caller.dart`의 `RpcCaller.call<T>(...)` — 이 change의 모든 RPC 호출은 이 경유만 사용 (`supabase.rpc()` 직접 호출 금지, 파일 자체 주석의 "원칙 (900102 ChangeContract / INV-001~006)" 재확인)
- `AppConstants.schemaPos = 'catchmenu_pos'`, `AppConstants.pipelineWaiting = 'WAITING_HANDOFF'` — 이미 존재, `register_waiting()` 호출 시 그대로 사용 가능
- **신규 필요 상수**: `AppConstants`에 `catchmenu_store` 스키마 상수가 아직 없음(`schemaPos`/`schemaPayment`/`schemaCommon`/`schemaKds`/`schemaDev`만 확인됨) — `bootstrap_customer_app_v2()` 호출을 위해 `schemaStore = 'catchmenu_store'` 추가 필요 (`600212_Logic.md`에서 구체화, 이번 턴 파일 생성은 안 함)

## Indirect Dependencies

`SharedPreferences` 패키지(pubspec에 이미 있는지는 `600212_Logic.md`에서 확인), `SecureStorage`(JWT 전용, `600203_DecisionLog.md` Decision 2에 의해 게스트 `customer_id`와 분리 유지).

## Database Tables

스키마 변경 없음 — 이 change는 순수 Flutter 클라이언트 작업이며 `sql/migrations/`는 건드리지 않는다. 읽기/쓰기 대상은 이미 `0148`/`0149`로 확정된 `catchmenu_store.customers`(`is_guest`, `customer_id`), `catchmenu_pos.order_sessions`(`customer_id`, `phone_hash`)이다.

## 900102 ChangeContract INV-001~006 재확인 — 결제/KDS 경계 미접촉 확인

`900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` §3의 6개 불변식을 이번 change 범위와 직접 대조:

- **INV-001**(KDS Release Requires Approved Payment), **INV-005**(Release Is Idempotent), **INV-006**(Ledger Evidence Is Required) — `kds_tickets.kds_status`/`payment_ledger` 관련 불변식. 이번 change는 `register_waiting()`/`bootstrap_customer_app_v2()`만 호출하며, 이 두 함수는 `kds_tickets`나 `payment_ledger`를 건드리지 않는다 (0149 함수 본문 재확인 — 대기열/고객 식별 처리만). **미접촉 확인**
- **INV-002**(Seating Is Not Payment), **INV-003**(Calling Is Not Payment) — `order_sessions.status`의 `SEATED`/`ARRIVAL_PENDING` 전환이 결제로 오인되지 않아야 한다는 불변식. 이번 change는 대기 "등록"(waiting queue 진입) 단계만 다루며 좌석/호출 상태 전환 자체를 만들지 않는다. **미접촉 확인**
- **INV-004**(Client Is Not Release Authority) — `release_kds_after_payment()`는 `SYSTEM` 역할 전용, 클라이언트가 직접 호출 불가. `rpc_caller.dart`의 `forbiddenClientRpcs`가 이미 이 함수를 차단 중(재확인 완료, 위 표 참고). 이번 change가 호출하는 두 함수는 애초에 그 차단 목록에 없다. **미접촉 확인**

**결론**: 이번 waiting feature 작업은 900102의 결제/KDS release 경계를 전혀 건드리지 않는다.

## Related Documentation References

- `600120_guest_customer_bootstrap_rpc/600122_Logic.md` §6 — `bootstrap_customer_app_v2()`의 caller-contract 요구사항(원래는 "게스트도 `customer_id`를 명시적으로 넘겨야 함"이었으나, `0149`가 `p_customer_id is null`일 때 자동 헬퍼 호출을 추가하면서 최초 호출 한정으로는 완화됨 — 단, 이미 발급받은 `customer_id`가 있다면 여전히 명시적으로 전달해야 함, `600212_Logic.md` §Open Questions 참고)
- `600100_.../600112_Logic.md` §6 — 동일 caller-contract 논의의 원출처(0115/0116 패치 시점 기준 서술, 참조만·편집 안 함)
- `900102_ChangeContract_...md` — 위 §900102 재확인 근거
- `600203_DecisionLog.md` Decision 1/2/3 — 이번 change의 3대 확정 전제(순서, 저장 방식, go_router 범위 포함)

## Module Domain Tags

- FLUTTER_CLIENT
- DOCUMENTATION_ONLY (이번 턴 자체는 문서만)

## Required Context Snapshot Candidates (§6.5 — Claude Code-Assisted Rule Filtering)

Stage 2(`600212_Logic.md` 상세 설계 및 이후 TestPlan/ChangeContract)가 실제로 필요로 할 최소 컨텍스트만 선별:

### Master Anchor

`000001_Md_Rules.md`(문서 규칙 전반), `000701_Guide_Controlled_AI_Development_Pipeline.md`(8단계 파이프라인, 이번 change는 Stage 1.5)

### Full Rules Required

- `900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` — INV-001~006 전문(이미 위에서 대조 완료, Stage 2 ChangeContract 작성 시 재인용 필요)
- `600122_Logic.md` §6 (caller-contract), `600112_Logic.md` §6 (원출처) — 참조만

### Domain Indexes

`600300_Readme_Cloud_Local_Migration_Sync.md`의 Boundary Reference Documents는 이번 change와 무관(SQL/클라우드 동기화 도메인) — **불필요, 제외**

### Excluded Rule Families

- `005015_Policy_Customer_Account_Guest_Merge...md` — 게스트/계정 병합 정책. 이번 change는 이미 발급된 `customer_id`를 저장/재사용만 하며 병합 로직 자체를 다루지 않으므로 Full Rules로 끌어올 필요 없음(참조 표시만 유지)
- `900160`~`900179` 특허 포트폴리오 문서 — 이번 순수 클라이언트 저장/라우팅 작업과 무관, 제외

## Risk Notes

`0149`가 두 함수 모두에 `if p_customer_id is null then ... get_or_create_guest_customer(...)`를 넣어뒀지만, **완전 익명(phone_hash 없음) 게스트는 호출마다 새 row가 생성되는 설계**(`get_or_create_guest_customer()` 본문의 `else` 분기 주석 "phone_hash 없는 완전 익명: 매번 신규 row" 확인)다. 따라서 Flutter가 저장된 `customer_id`를 재전달하지 않으면 매 호출마다 새 게스트 고객이 만들어진다 — 이게 바로 이번 change(SharedPreferences 저장)가 존재해야 하는 이유다. `600212_Logic.md`에서 이 흐름을 정확히 명세한다.

## Uncertainties

- `SharedPreferences` 패키지가 `pubspec.yaml`에 이미 등록돼 있는지 미확인 (`600212_Logic.md`에서 확인)
- `AppConstants.schemaStore` 상수 부재 확인됨 — 추가 필요 여부/이름은 `600212_Logic.md`에서 확정

## Known Gaps

없음 — 이번 조사는 `600120`/`600203_DecisionLog.md` 대비 새로 필요한 Flutter 측 설계 범위만 다루며, 이미 확정된 배경(Decision 1/2/3, 900102 INV)은 재검증만 하고 재논의하지 않았다.

## Snapshot Decision

이 스냅샷으로 `600212_Logic.md` 작성 진행 가능.
