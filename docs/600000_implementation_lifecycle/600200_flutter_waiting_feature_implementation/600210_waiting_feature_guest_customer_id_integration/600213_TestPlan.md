# 600213_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Owner: TBD
Last Updated: 2026-07-12

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 명령/코드다. 작성 전 `register_waiting()`/`bootstrap_customer_app_v2()`의 실제 응답 payload를 SQL 재확인했고, 그 결과 `600212_Logic.md`가 전제한 호출 순서에 **불일치가 발견되어 §0에 우선 기록한다**.

## §0. 중요 발견 — 응답 payload 재확인 결과, 호출 순서 전제 정정 필요 (Stage 3 확인 요망)

`sql/migrations/0149_create_guest_customer_bootstrap_rpc.sql`을 직접 읽어 두 함수의 **실제 반환 JSON**을 확인했다:

| 함수 | 반환 payload에 `customer_id` 포함? | 반환 payload에 `session_id` 포함? |
|---|---|---|
| `register_waiting()` (L273-306의 `return catchmenu_common.build_success_response(...)`) | **아니오** — `p_customer_id`는 함수 내부에서 자동 채워지지만, 최종 `p_data`에는 `session_id`/`wait_number`/`queue_position`/`guest_count`/`guest_locale`/`est_wait_minutes`/`pre_order_enabled`/메시지 필드만 있고 `customer_id` 키 자체가 없다. (`'customer_id', p_customer_id`가 등장하는 곳은 L238 근처의 `notify_channel` 푸시 알림 내부 payload뿐이며, 이는 클라이언트에게 반환되는 RPC 응답이 아니다.) | 예 — `'session_id', v_session_id` |
| `bootstrap_customer_app_v2()` (L565- 이하) | **예, 단 중첩** — `p_customer_id`가 채워진 뒤(`v_customer.id is not null`이면) `'customer': {'id': v_customer.id, 'display_name': ..., ...}` 형태로 중첩 반환 | 별도 최상위 `session_id` 없음(대기 세션이 있을 때만 `'customer'` 하위가 아닌 다른 위치에 `session_id`가 중첩될 수 있음 — 이번 change의 관심 대상은 아님) |

`600212_Logic.md`는 "`register_waiting()` 최초 호출 → 응답의 `customer_id`를 저장"이라고 서술했는데, **실제로는 `register_waiting()` 응답에 `customer_id`가 없다.** 이 문서(TestPlan)는 아래 §1/§2를 **실제 응답 구조에 맞춰** 다음 순서로 재설계한다:

1. **`bootstrap_customer_app_v2()`가 앱 부팅 시 먼저 호출되어 `customer_id`를 확보한다** (함수명 자체가 "app bootstrap"이므로 이 순서가 자연스럽다).
2. **`register_waiting()`은 이미 확보된 `customer_id`를 `p_customer_id`로 전달**하며, 응답의 `session_id`만 별도로 저장한다.

**Stage 3에서 결정 필요**: (a) 이 발견대로 `600211_Overview.md`/`600212_Logic.md`의 호출 순서 서술을 정정할지, 아니면 (b) `register_waiting()` 자체에 `customer_id`를 응답 필드로 추가하는 별도 SQL 변경(§24 후보)을 낼지. 이 TestPlan은 (a) 전제(현재 SQL을 그대로 두고 호출 순서로 대응)로 작성하되, 이 자체가 Open Item(§6-1)이다.

## §1. 게스트 최초 진입 시나리오 (부팅 시 `bootstrap_customer_app_v2()` → 이후 `register_waiting()`)

### 1.1 앱 최초 부팅 — `bootstrap_customer_app_v2()` 호출, `customer_id` 저장 확인

```dart
// 의사 코드 — 실제 .dart 파일은 Stage 4에서 작성
final result = await rpcCaller.call<Map<String, dynamic>>(
  'bootstrap_customer_app_v2',
  schema: AppConstants.schemaStore,
  pipeline: AppConstants.pipelineSession,
  module: 'guest_bootstrap',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    'p_customer_id': null,   // 저장된 값 없음 — 최초 부팅
    'p_phone_hash': null,
  },
);

final customerId = result.requireData['customer']['id'] as String;
await guestSessionStore.saveGuestCustomerId(customerId);

// 기대: customerId가 null이 아닌 uuid 문자열
// 기대: SharedPreferences.getString('guest_customer_id') == customerId (저장 직후 재조회로 검증)
```

**서버 측 대조 확인**(SQL, Stage 3 승인 후 로컬 DB에서 직접 실행 가능):

```sql
select id, is_guest, phone_hash from catchmenu_store.customers where id = '<위에서 받은 customerId>';
-- 기대: is_guest = true, phone_hash is null (전화번호 미입력 시나리오)
```

### 1.2 이어서 `register_waiting()` 호출 — 저장된 `customer_id` 전달, `session_id` 저장 확인

```dart
final storedCustomerId = await guestSessionStore.getGuestCustomerId(); // 1.1에서 저장한 값
final result = await rpcCaller.call<Map<String, dynamic>>(
  'register_waiting',
  schema: AppConstants.schemaPos,
  pipeline: AppConstants.pipelineWaiting,
  module: 'waiting_register',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    'p_guest_count': 2,
    'p_customer_id': storedCustomerId,  // null 아님 — 1.1에서 이미 확보
    'p_phone_hash': null,
    'p_source': 'CUSTOMER',
  },
);

final sessionId = result.requireData['session_id'] as String;
await guestSessionStore.saveGuestWaitingSessionId(sessionId);

// 기대: sessionId가 null이 아닌 uuid 문자열
```

**서버 측 대조 확인**:

```sql
select id, customer_id from catchmenu_pos.order_sessions where id = '<위 sessionId>';
-- 기대: customer_id 컬럼 값이 1.1의 customerId와 정확히 일치
```

## §2. 재진입 시나리오 — 저장된 `customer_id`가 동일하게 이어지는지

### 2.1 앱 재시작(SharedPreferences 유지) 후 재호출

```dart
final storedCustomerId = await guestSessionStore.getGuestCustomerId(); // 1.1에서 저장된 값, 재시작 후에도 유지
final result = await rpcCaller.call<Map<String, dynamic>>(
  'bootstrap_customer_app_v2',
  schema: AppConstants.schemaStore,
  pipeline: AppConstants.pipelineSession,
  module: 'guest_bootstrap',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    'p_customer_id': storedCustomerId,  // null 아님 — 저장된 값 재전달
    'p_phone_hash': null,
  },
);

final customerIdAgain = result.requireData['customer']['id'] as String;
// 기대: customerIdAgain == storedCustomerId (완전히 동일, 새 row 아님)
```

**`0149`의 `get_or_create_guest_customer()` upsert 동작과의 일치 확인**: `p_customer_id`가 이미 non-null이면 `bootstrap_customer_app_v2()`의 `if p_customer_id is null then ...` 분기 자체를 타지 않으므로 `get_or_create_guest_customer()`가 **아예 호출되지 않는다** — 즉 "매번 신규 row" 분기(완전 익명, `phone_hash` 없음)에 걸릴 위험이 없다. 이는 §2.1 테스트가 통과해야 하는 이유의 근거이며, `600212_Logic.md`의 Risk Notes("저장된 customer_id를 재전달하지 않으면 매 호출마다 새 게스트 고객이 생김")와 정합적이다.

**서버 측 직접 검증(회귀 대조)**:

```sql
select count(*) from catchmenu_store.customers where id = '<storedCustomerId>';
-- 기대: 1 (재호출로 새 row가 추가되지 않았음)
```

## §3. `go_router` 배선 후 기존 `widget_test.dart` 통과 여부

`catchmenu_app/test/widget_test.dart`는 현재 `pumpWidget(CatchMenuApp(initError: ...))` 후 텍스트 `'초기화 실패'`를 검증한다(`_BootScreen`의 에러 분기). `main.dart`가 `MaterialApp.router`로 바뀌면 이 테스트는 **그대로는 통과하지 않을 가능성이 높다** — `MaterialApp.router`는 `home`이 아니라 `routerConfig`로 초기 화면을 결정하므로, `_BootScreen`이 에러 상태에서도 라우터의 초기 경로로 실제로 렌더되는지 확인이 필요하다.

```dart
// Stage 4 구현 후 실행할 갱신된 테스트 형태 (의사 코드)
testWidgets('부팅 화면 렌더 (초기화 실패 경로, router 경유)', (WidgetTester tester) async {
  await tester.pumpWidget(
    CatchMenuApp(initError: AppError.notInitialized('테스트: Supabase 설정 없음')),
  );
  await tester.pumpAndSettle(); // GoRouter의 초기 redirect/네비게이션이 완료될 시간 확보

  expect(find.text('초기화 실패'), findsOneWidget);
});
```

```bash
cd catchmenu_app
flutter test test/widget_test.dart
```

기대 결과: 위 갱신된 형태로 테스트를 고치면 PASS. **원래 형태 그대로 두면 FAIL 가능성이 있다는 점을 Known Gap으로 기록** — 실제 PASS/FAIL은 Stage 4에서 `main.dart`/`router.dart`가 실제로 작성된 뒤에만 확정 가능하다(이 문서 작성 시점엔 `.dart` 파일이 없어 직접 실행 불가).

## §4. `main.dart` 전환 후 정적 분석 수준 확인 (에뮬레이터/디바이스 불필요)

```bash
cd catchmenu_app
flutter analyze
```
기대 결과: 에러 0건(경고는 `flutter_lints`의 기존 룰셋 기준으로 신규 코드가 위반하지 않는지만 확인 — 이번 change로 새로 추가되는 `lib/app/router.dart`, `lib/core/storage/*`, `lib/features/waiting/*` 전체 대상).

```bash
flutter test
```
기대 결과: `test/widget_test.dart`(§3의 갱신 형태) PASS. 이번 change로 신규 테스트가 추가된다면 그것도 함께 PASS.

**현재 상태 확인(이번 Stage 2에서 재확인 완료)**: `catchmenu_app/test/` 전체를 `find`로 재확인한 결과 `widget_test.dart` 1개뿐이다 — 이번 change 전 기준선(baseline)은 "테스트 1개, PASS"이며, Stage 4 이후에도 최소 이 상태 이상을 유지해야 한다.

## §5. INV-001~006 회귀 없음 재확인

`catchmenu_app/test/` 전체를 재확인한 결과 **결제/KDS(INV-001~006) 관련 기존 테스트는 존재하지 않는다**(`grep -rn "forbiddenClientRpcs|forbiddenClientCall|release_kds_after_payment" catchmenu_app/test/` → 0건). 따라서 "기존 테스트가 통과하는지" 확인할 대상 자체가 없다 — 이는 이번 change의 결함이 아니라 이 프로젝트 Flutter 클라이언트의 기존 테스트 커버리지 공백이며, 이번 change의 책임 범위 밖이다(신규 INV 가드 테스트 추가는 별도 workpacket 대상, 이 change에서 임의로 추가하지 않는다 — §24/§28 범위 확대 없이 지시된 것만 수행).

대신 **정적 확인**으로 회귀 없음을 검증한다:

```bash
grep -n "supabase.rpc(" catchmenu_app/lib/features/waiting/**/*.dart catchmenu_app/lib/app/router.dart catchmenu_app/lib/core/storage/*.dart
```
기대 결과: 매치 0건 — 이번 change의 어떤 신규 파일도 `rpc_caller.dart`를 우회해 `supabase.rpc()`를 직접 호출하지 않는다.

```bash
grep -n "release_kds_after_payment" catchmenu_app/lib/features/waiting/**/*.dart
```
기대 결과: 매치 0건 — 이번 change가 결제/KDS release 관련 RPC를 호출하지 않음을 정적으로 재확인.

## §6. Open Items (→ `600214_ChangeContract.md`로 이월)

1. **§0의 호출 순서 불일치** — `600211_Overview.md`/`600212_Logic.md`를 정정할지, `register_waiting()` 응답에 `customer_id`를 추가하는 별도 SQL 변경을 낼지 Stage 3 결정 필요.
2. `catchmenu_app/test/widget_test.dart`의 `MaterialApp.router` 전환 후 통과 여부 — Stage 4 구현 후 실제 실행으로만 확정 가능.
3. INV-001~006 관련 Flutter 테스트 커버리지 공백 — 이번 change 책임 범위 밖이나, 기록으로 남김.
