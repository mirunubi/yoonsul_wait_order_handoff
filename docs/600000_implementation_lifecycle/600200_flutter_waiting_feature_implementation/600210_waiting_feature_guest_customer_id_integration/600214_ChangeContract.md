# 600214_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-12
CHANGE_ID: `waiting_feature_guest_customer_id_integration`

## 1. Allowed Files

| 파일 | 동작 |
|---|---|
| `catchmenu_app/lib/main.dart` | **수정** — `MaterialApp` → `MaterialApp.router(routerConfig: router, ...)` 전환 (Human 결정 2, `600212_Logic.md` §5) |
| `catchmenu_app/lib/app/router.dart` | **신규** — `go_router` 배선, `600212_Logic.md` §6의 최소 라우트(`/waiting/register`, `/waiting/status`) |
| `catchmenu_app/lib/features/waiting/**` | **신규** — 대기 등록/상태 조회 화면 및 상태관리, `600212_Logic.md` §3/§7의 RPC 호출 흐름 구현 (`README.md`는 기존 파일, 필요시 갱신 가능) |
| `catchmenu_app/lib/core/storage/**` | **신규** — `SharedPreferences` 래퍼(가칭 `guest_session_store.dart`), `guest_customer_id`/`guest_waiting_session_id` 키 관리(`600212_Logic.md` §4) |
| `catchmenu_app/test/widget_test.dart` | **필요시 수정** — `MaterialApp.router` 전환 후에도 `_BootScreen` 에러 렌더 검증이 유지되도록 갱신(`600213_TestPlan.md` §3), 새 assertion 추가 시 `pumpAndSettle()` 등 router 초기화 대기 반영 |
| `catchmenu_app/lib/core/constants/app_constants.dart` | **수정(최소)** — `schemaStore = 'catchmenu_store'` 상수 추가만(`600212_Logic.md` §8). 기존 `forbiddenClientRpcs` 등 다른 내용 변경 금지 |

## 2. Forbidden Files (명시적 범위 제외)

- `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/600110_order_sessions_customer_id_fk_and_guest_promotion/`, `600120_guest_customer_bootstrap_rpc/` 산하 전체 파일(`600111`~`600127`) — 이미 Audited/ACCEPT된 산출물, 참조만 하고 편집 금지
- `sql/migrations/**` (전체) — 이번 change는 순수 Flutter 클라이언트 작업. `600213_TestPlan.md` §0에서 발견된 `register_waiting()` 응답에 `customer_id`가 없는 문제도, 이 change 범위에서 SQL로 고치지 않는다(별도 결정 필요, §3 Open Items)
- `catchmenu_app/lib/core/supabase/rpc_caller.dart` — **호출 방식(`RpcCaller.call<T>(...)`)만 사용**, 클래스 내부 로직(가드, 감사 로그, correlation_id 생성 등) 변경 금지
- `catchmenu_app/lib/core/supabase/supabase_client.dart` — 편집 금지
- `catchmenu_app/lib/core/errors/app_error.dart` — 편집 금지 (기존 `AppError` 타입 재사용만)
- `catchmenu_app/lib/features/kds/`, `catchmenu_app/lib/features/payment/`, `catchmenu_app/lib/features/staff/` — 전부 범위 밖
- `docs/900000_patent_and_handoff_package/900102_ChangeContract_...md` — 편집 금지, 참조만(`600211_Overview.md`에서 이미 INV-001~006 미접촉 확인 완료)
- `docs/990000_legacy_quarantine/604000_workpackets/604100_flutter_mvp_foundation/**`(604101/604102 등) — §5.10 frozen, 참조만·편집 금지
- 위 목록에 없는 그 외 `catchmenu_app/lib/**`, `catchmenu_app/test/**` 전체

## 3. Open Items

1. **`600213_TestPlan.md` §0의 호출 순서/응답 불일치** — `register_waiting()` 응답에 `customer_id`가 없다는 재확인 결과, `600211_Overview.md`/`600212_Logic.md`가 전제한 "최초 호출 = `register_waiting()`" 순서를 "`bootstrap_customer_app_v2()`가 먼저, `register_waiting()`은 이미 확보된 `customer_id`를 전달"로 바꿀지, 아니면 `register_waiting()` SQL 자체에 `customer_id` 응답 필드를 추가하는 별도 변경을 낼지 — **Stage 3 Human 결정 필요**. 이 문서(600214)는 전자(호출 순서로 대응, SQL 불변)를 전제로 Allowed/Forbidden Files를 작성했다.
2. `catchmenu_app/test/widget_test.dart`가 `MaterialApp.router` 전환 후에도 실제로 통과하는지 — Stage 4 구현 후 `flutter test`로만 확정 가능(`600213_TestPlan.md` §3/§4).
3. `604101`/`604102`(§5.10 frozen)와의 최종 정합성 확인 — 두 문서 모두 `main.dart`를 "router hook"을 갖는 구조로 서술하고 있어 이번 방향과 상충하지는 않는 것으로 보이나, frozen 문서이므로 권위 있는 근거로 쓰지 않고 방향성 참고에만 그친다. Stage 4 구현 완료 후 독립 재검증 필요.
4. `AppConstants.schemaStore` 추가가 이번 change의 Allowed Files(§1)에 포함되어 있으나, `bootstrap_customer_app_v2()`가 사실상 이 change의 진입점(§0 발견에 따라)이 되면서 그 상수가 실제로 필요한 시점이 앞당겨짐 — 순서상 문제는 없으나 Stage 4 구현 시 인지 필요.

## 4. Known Constraint — 완전 익명 게스트 dedupe 없음 (버그 아님, 재논의 금지)

`600212_Logic.md` §9-1에서 이미 기록된 사항의 재확인: `phone_hash` 없는 완전 익명 게스트는 `get_or_create_guest_customer()` 설계 자체(Human 결정 #4)로 인해 앱 재설치 시 이전 `customer_id`를 잃는다. 이는 이번 change의 결함이 아니며 Stage 4 구현자가 임의로 "고치려" 시도해서는 안 된다.

## 5. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (승인일자: 2026-07-11)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

**`000701` §4 Core Rule 준수**: 이 CHANGE_ID에 대해 `catchmenu_app/` 내 어떤 파일도 이번 턴에 생성/수정되지 않았음(이번 턴 `git status`로 재확인, `.dart` 파일 변경 0건). 이 섹션 서명 전까지 생성하지 않는다.
