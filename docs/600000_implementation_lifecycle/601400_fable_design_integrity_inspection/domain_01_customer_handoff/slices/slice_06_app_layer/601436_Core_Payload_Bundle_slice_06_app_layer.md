===== BEGIN [catchmenu_app/lib/features/kds/README.md] =====
# features/kds — KDS 화면 (Scope C)

900102 ChangeContract 기준. **Scope D 통과 후** 구현.

## 예정 파일
- `kds_screen.dart`
- `kds_ticket_card.dart`
- `kds_state_notifier.dart`
- `kds_repository.dart`

## 표시 규칙
- `HOLD`: 회색 배경 + 조리 버튼 disabled + 타이머 미표시 → "결제 대기 중 / Payment Pending"
- `COMMITTED`: Realtime 수신 후 녹색 + 버튼 활성 + 타이머 시작
- `COOKING/READY/SERVED`: `transition_kds_ticket()` 전환 버튼

## 금지 (INV)
- KDS UI 에서 `release_kds_after_payment()` 호출 금지 (INV-004)
- `HOLD → COOKING` 직접 전환 금지 (INV-001)
- `kds_status` 를 로컬 상태로 임의 변경 금지 (INV-006)
- HOLD 티켓에 "강제 해제"/"시작" 버튼 없음


===== BEGIN [catchmenu_app/lib/features/payment/README.md] =====
# features/payment — 결제 (Scope A: 고객 앱)

900102 ChangeContract 기준. **Scope D 통과 후** 구현.

## 예정 파일
- `payment_screen.dart`
- `toss_payment_widget.dart`
- `payment_result_handler.dart`
- `payment_repository.dart` — RpcCaller 경유 (`schema: catchmenu_payment`)

## 흐름
1. 토스 결제 위젯 `onSuccess`
2. 서버 `confirm_payment()` 호출 (catchmenu_payment)
3. 서버 응답 전까지 "결제 확인 중..." 표시
4. 서버 `payment_ledger.status = APPROVED` 확인 후에만 완료 UI

## 핵심 (INV)
- 클라이언트 결제 성공 화면 ≠ 결제 완료. 서버 APPROVED 만이 완료 (INV-001)
- KDS release 는 서버 `confirm_payment()` 내부에서만 (INV-004)
- 결제 이벤트 idempotent (INV-005): 중복 confirm/webhook → release 재실행 없음


===== BEGIN [catchmenu_app/lib/features/waiting/README.md] =====
# features/waiting — 대기 관리 (Scope A: 고객 앱)

900102 ChangeContract 기준. **Scope D(서버 Guard) 통과 후** 구현.

## 예정 파일
- `waiting_register_screen.dart` — 대기 등록
- `waiting_status_screen.dart` — 대기 현황
- `pre_order_screen.dart` — 사전 주문
- `pre_order_state_notifier.dart`
- `waiting_repository.dart` — RpcCaller 경유 (`schema: catchmenu_pos`)

## 관련 RPC
- `register_waiting` (catchmenu_pos)
- `seat_waiting_customer` (catchmenu_pos)
- `call_waiting_customer` (catchmenu_pos)

## 금지 (INV)
- onSuccess 직후 완료 UI 표시 금지 → 서버 APPROVED 확인 후에만 (INV-001)
- `release_kds_after_payment()` 직접 호출 금지 (INV-004)
- SEATED 이벤트만으로 결제 완료 처리 금지 (INV-002)


===== BEGIN [catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart] =====
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/guest_session_storage.dart';
import '../../../core/supabase/rpc_caller.dart';

class WaitingRegisterScreen extends ConsumerStatefulWidget {
  const WaitingRegisterScreen({super.key});

  @override
  ConsumerState<WaitingRegisterScreen> createState() =>
      _WaitingRegisterScreenState();
}

class _WaitingRegisterScreenState extends ConsumerState<WaitingRegisterScreen> {
  static const _defaultTenantId = '00000000-0000-0000-0000-000000000001';
  static const _defaultStoreId = '00000000-0000-0000-0000-000000000002';

  final _storage = const GuestSessionStorage();
  final _tenantController = TextEditingController(text: _defaultTenantId);
  final _storeController = TextEditingController(text: _defaultStoreId);
  final _phoneHashController = TextEditingController();

  int _guestCount = 2;
  bool _isLoading = false;
  String? _customerId;
  String? _sessionId;
  String? _message;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStoredIds();
  }

  @override
  void dispose() {
    _tenantController.dispose();
    _storeController.dispose();
    _phoneHashController.dispose();
    super.dispose();
  }

  Future<void> _loadStoredIds() async {
    final customerId = await _storage.getGuestCustomerId();
    final sessionId = await _storage.getGuestWaitingSessionId();
    if (!mounted) return;
    setState(() {
      _customerId = customerId;
      _sessionId = sessionId;
    });
  }

  Future<String> _ensureGuestCustomerId() async {
    final storedCustomerId = await _storage.getGuestCustomerId();
    if (storedCustomerId != null && storedCustomerId.isNotEmpty) {
      return storedCustomerId;
    }

    final rpcCaller = ref.read(rpcCallerProvider);
    final result = await rpcCaller.call<Map<String, dynamic>>(
      'bootstrap_customer_app_v2',
      schema: AppConstants.schemaStore,
      pipeline: AppConstants.pipelineSession,
      module: 'guest_bootstrap',
      flutterScreen: 'waiting_register',
      params: {
        'p_tenant_id': _tenantController.text.trim(),
        'p_store_id': _storeController.text.trim(),
        'p_customer_id': null,
        'p_phone_hash': _nullableText(_phoneHashController.text),
      },
    );

    final response = _asStringMap(result.requireData);
    final data = _asStringMap(response['data']);
    final customer = _asStringMap(data['customer']);
    final customerId = customer['id'] as String?;
    if (customerId == null || customerId.isEmpty) {
      throw StateError(
        'bootstrap_customer_app_v2 did not return data.customer.id',
      );
    }

    await _storage.saveGuestCustomerId(customerId);
    return customerId;
  }

  Future<void> _registerWaiting() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _error = null;
    });

    try {
      final customerId = await _ensureGuestCustomerId();
      final rpcCaller = ref.read(rpcCallerProvider);
      final result = await rpcCaller.call<Map<String, dynamic>>(
        'register_waiting',
        schema: AppConstants.schemaPos,
        pipeline: AppConstants.pipelineWaiting,
        module: 'waiting_register',
        flutterScreen: 'waiting_register',
        params: {
          'p_tenant_id': _tenantController.text.trim(),
          'p_store_id': _storeController.text.trim(),
          'p_session_type': 'WAITING',
          'p_guest_count': _guestCount,
          'p_guest_locale': 'ko',
          'p_phone_hash': _nullableText(_phoneHashController.text),
          'p_customer_id': customerId,
          'p_memo': null,
          'p_source': 'CUSTOMER',
          'p_locale': 'ko',
        },
      );

      final response = _asStringMap(result.requireData);
      final data = _asStringMap(response['data']);
      final sessionId = data['session_id'] as String?;
      if (sessionId == null || sessionId.isEmpty) {
        throw StateError('register_waiting did not return data.session_id');
      }

      await _storage.saveGuestCustomerId(customerId);
      await _storage.saveGuestWaitingSessionId(sessionId);

      if (!mounted) return;
      setState(() {
        _customerId = customerId;
        _sessionId = sessionId;
        _message = 'Waiting registered. Session: $sessionId';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting registration')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _tenantController,
            decoration: const InputDecoration(labelText: 'Tenant ID'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _storeController,
            decoration: const InputDecoration(labelText: 'Store ID'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _phoneHashController,
            decoration: const InputDecoration(
              labelText: 'Phone hash (optional)',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Guest count'),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _guestCount,
                items: const [1, 2, 3, 4, 5, 6]
                    .map(
                      (value) => DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value'),
                      ),
                    )
                    .toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        if (value == null) return;
                        setState(() {
                          _guestCount = value;
                        });
                      },
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _isLoading ? null : _registerWaiting,
            child: Text(_isLoading ? 'Registering...' : 'Register waiting'),
          ),
          const SizedBox(height: 24),
          _ValueTile(label: 'guest_customer_id', value: _customerId),
          _ValueTile(label: 'guest_waiting_session_id', value: _sessionId),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, style: const TextStyle(color: Colors.green)),
          ],
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.label, required this.value});

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value ?? '(not stored)'),
    );
  }
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return <String, dynamic>{};
}

String? _nullableText(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}


===== BEGIN [catchmenu_app/lib/features/waiting/screens/waiting_status_screen.dart] =====
import 'package:flutter/material.dart';

import '../../../core/storage/guest_session_storage.dart';

class WaitingStatusScreen extends StatefulWidget {
  const WaitingStatusScreen({super.key});

  @override
  State<WaitingStatusScreen> createState() => _WaitingStatusScreenState();
}

class _WaitingStatusScreenState extends State<WaitingStatusScreen> {
  final _storage = const GuestSessionStorage();
  String? _customerId;
  String? _waitingSessionId;

  @override
  void initState() {
    super.initState();
    _loadStoredValues();
  }

  Future<void> _loadStoredValues() async {
    final customerId = await _storage.getGuestCustomerId();
    final waitingSessionId = await _storage.getGuestWaitingSessionId();
    if (!mounted) return;
    setState(() {
      _customerId = customerId;
      _waitingSessionId = waitingSessionId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting status')),
      body: RefreshIndicator(
        onRefresh: _loadStoredValues,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Stored guest waiting state',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('guest_customer_id'),
              subtitle: Text(_customerId ?? '(not stored)'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('guest_waiting_session_id'),
              subtitle: Text(_waitingSessionId ?? '(not stored)'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Status lookup RPC integration is intentionally not invented in '
              'this change. This screen verifies the persisted ids used by the '
              'waiting status flow boundary.',
            ),
          ],
        ),
      ),
    );
  }
}


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600200_Readme_Flutter_Waiting_Feature_Implementation.md] =====
# 600200_Readme_Flutter_Waiting_Feature_Implementation.md

Status: Draft  
Lifecycle: Readme  
Owner: TBD  
Last Updated: 2026-07-11

## Purpose

This folder owns controlled implementation lifecycle documentation for **Flutter waiting feature implementation** in the CatchMenu customer handoff lane, including integration with guest `customer_id` linkage after `0148`.

## In Scope

- Workpacket subfolders for waiting-feature changes (starting with `600210_waiting_feature_guest_customer_id_integration/`)
- Stage 1 (Eyes Only) raw scope and inventory reports
- Future Overview / Logic / TestPlan / ChangeContract / Module documents when authorized
- `ChangeHistory.md`, `NavigationMap.md`, and `DecisionLog.md` at this folder level

## Out of Scope

- Runtime implementation (Flutter/Dart, SQL migrations, RLS edits, Supabase Edge) unless explicitly authorized via Controlled Implementation Gate
- Architecture or client state-management standard decisions in Stage 1
- Treating quarantined `604101`–`604103` as authoritative without independent re-verification against current `catchmenu_app/`

## Owned Number Band

- Folder band: `600200`–`600299`
- Parent: `docs/600000_implementation_lifecycle/`
- Related upstream SQL lane: `docs/600000_implementation_lifecycle/600100_customer_identity_and_guest_promotion/`

## Subfolder Map

| Folder | CHANGE_ID / Topic | Status |
| --- | --- | --- |
| `600210_waiting_feature_guest_customer_id_integration/` | `waiting_feature_guest_customer_id_integration` | Draft / Stage 1 |

## Boundary Reference Documents

`000001_Md_Rules.md` §5.2.1 — 이 모듈 산하 모든 변경건(`600210` 등)이 Stage 1 스캔 시 반드시 대조해야 하는 경계 정의 문서. 각 변경건의 `Overview.md`가 갖는 "Required Context Snapshot Candidates"(1회성 스냅샷)와 달리, 이 표는 모듈 전체에 걸쳐 영구 누적된다.

| 문서 | 필요한 이유 |
| --- | --- |
| `docs/990000_legacy_quarantine/604000_workpackets/604100_flutter_mvp_foundation/604101_Overview_Flutter_MVP_Project_Structure.md` | Flutter 프로젝트 구조 baseline (§5.10 frozen, 재검증 필요 — Out of Scope 항목 참고) |
| `docs/990000_legacy_quarantine/604000_workpackets/604100_flutter_mvp_foundation/604102_Logic_Flutter_MVP_Core_Implementation.md` | `rpc_caller.dart` 설계 근거, INV 규칙 반영 방식 |
| `docs/900000_patent_and_handoff_package/900102_ChangeContract_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md` | 클라이언트 RPC 호출 경계 (`rpc_caller.dart` 필수 경유 원칙) |

## File List

| Number | File | Status |
| --- | --- | --- |
| 600200 | `600200_Readme_Flutter_Waiting_Feature_Implementation.md` | Draft |
| 600201 | `600201_ChangeHistory.md` | Draft (skeleton) |
| 600202 | `600202_NavigationMap.md` | Draft (skeleton) |
| 600203 | `600203_DecisionLog.md` | Draft (skeleton) |

## Add / Move Rule

1. New workpacket subfolders use `{6-digit-band}_{snake_case_topic}/` under this folder.
2. The first official document in each new workpacket subfolder should use that subfolder's number band; add a subfolder Readme when the subfolder receives its first governed document.
3. Any create, rename, or move must update **this Readme**, `docs/000005_Index_Document_Number.md`, and `docs/000007_Map_Full_Directory.md` in the same batch (per `docs/000001_Md_Rules.md` §5.11).
4. Also update `600000_Readme_Implementation_Lifecycle.md` when this folder's role or membership changes.

## Non-Implementation Boundary

This folder does not grant Codex, Cursor, or Claude permission to modify SQL, migrations, application code, or runtime configuration. Human Approval and ChangeContract are required before any implementation stage.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600201_ChangeHistory.md] =====
# 600201_ChangeHistory.md

Per `000701` §30 — single running file, append-only. One row per change.

| Date | Change Description | Reason/Evidence | Outcome | Linked Audit/Test |
|---|---|---|---|---|
| 2026-07-11/12 | `waiting_feature_guest_customer_id_integration`: `go_router` wiring (`main.dart`/`app/router.dart`), guest `customer_id`/`session_id` persistence (`core/storage/guest_session_storage.dart`), and two waiting screens (`register`/`status`) consuming `600120`'s guest bootstrap RPCs in the corrected call order (`bootstrap_customer_app_v2()` first, `register_waiting()` second) | `600203_DecisionLog.md` Decision 1 unblocked by `600120` ACCEPT (`f697e52`); `600213_TestPlan.md` §0 discovered `register_waiting()` does not return `customer_id`, requiring the call-order correction recorded in `600211_Overview.md` §0.3 | ACCEPT — `600215_Module.md`(Stage 4)/`600216_Verification.md`(Stage 5, `flutter analyze`+`flutter test` PASS)/`600217_Audit.md`(Stage 6) all complete | `600215_Module.md`, `600216_Verification.md`, `600217_Audit.md` |
| 2026-07-13 | `platform_deployment_strategy`: platform strategy confirmed (STAFF/KDS/DID→Android, customer-facing→web+mobile, MINI_KIOSK deferred), and `flutter build web` executed for the first time in this project's history against the unmodified `catchmenu_app` codebase | `600222_Logic.md` §3.1 had explicitly left "folder exists" (fact) separate from "build actually works" (unverified) — this change closes that gap with a real, evidenced run rather than an assumption | ACCEPT, web-build scope only — `600221`–`600224`(Overview/Logic/TestPlan/ChangeContract)/`600225_Module.md`(Stage 4)/`600226_Verification.md`(Stage 5, Human execution + Claude Code independent live-browser/static-file/`flutter analyze` verification, all PASS, screenshot-tool failure transparently recorded and worked around via `zoom`)/`600227_Audit.md`(Stage 6) all complete. 4 Open Items carried forward: (a) `flutter_secure_storage_web` WASM incompatibility (new, relevant only if a future WASM build target is adopted), (b) Android APK compile-only test not yet run, (c) MINI_KIOSK platform conflict (`900161`/`900171`) still undecided, (d) Channel 1/2 relationship + STAFF/KDS/DID flavor split still undecided | `600220_platform_deployment_strategy/600221`–`600227` |


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600202_NavigationMap.md] =====
# 600202_NavigationMap.md

Per `000701` §32 — single structured index, not a narrative log (`600201_ChangeHistory.md` owns "why"; this owns "what exists and what state"). One row per change.

| Change ID | Date | Tier | Status | Links |
|---|---|---|---|---|
| `waiting_feature_guest_customer_id_integration` | 2026-07-11/12 | Full (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit, 7 separate files) | **audited** (progression this session: unblocked → drafted (1.5/2) → implemented (4) → verified (5, `flutter analyze`+`flutter test` PASS) → audited (6, ACCEPT), see `600201_ChangeHistory.md` 2026-07-11/12 항목) | `600210_waiting_feature_guest_customer_id_integration/600211_Overview.md`, `600212_Logic.md`, `600213_TestPlan.md`, `600214_ChangeContract.md`, `600215_Module.md`, `600216_Verification.md`, `600217_Audit.md` |
| `platform_deployment_strategy` (platform strategy confirmed + `flutter build web` first-ever execution, web scope only — Android APK compile test still pending) | 2026-07-13 | Full (Overview/Logic/TestPlan/ChangeContract/Module/Verification/Audit, 7 separate files) | **audited** (progression: drafted(1.5/2) → approved(3) → implemented(4, Human execution) → verified(5, Human + Claude Code independent live-browser/static/analyze verification) → audited(6, ACCEPT — web scope only), see `600201_ChangeHistory.md` 2026-07-13 항목) | `600220_platform_deployment_strategy/600221_Overview.md`, `600222_Logic.md`, `600223_TestPlan.md`, `600224_ChangeContract.md`, `600225_Module.md`, `600226_Verification.md`, `600227_Audit.md` |


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600203_DecisionLog.md] =====
# 600203_DecisionLog.md

Recorded Human decisions for the `600200_flutter_waiting_feature_implementation` module. 재논의 대상 아님 — 향후 세션은 이 로그를 먼저 읽고 이미 결정된 사항을 재검토하지 않는다.

## Decision 1 — 게스트 customer_id 생성 로직은 600120에서 먼저 처리, 600210은 그 이후 설계

게스트 `customer_id` 생성 로직(SQL, 신규)은 `600100_customer_identity_and_guest_promotion/600120_guest_customer_bootstrap_rpc/`에서 먼저 처리한다. `600210_waiting_feature_guest_customer_id_integration/`(Flutter 측)의 `Overview.md` 작성은 `600120`의 RPC 시그니처가 확정된 뒤, 그 RPC를 소비하는 형태로 설계한다 — 순서를 바꾸지 않는다.

## Decision 2 — 게스트 customer_id는 SharedPreferences에 session_id와 함께 저장, SecureStorage와 분리

게스트 `customer_id`는 `session_id`와 함께 `SharedPreferences`에 저장하여 기기 재시작 후에도 유지한다. `SecureStorage`는 JWT 전용으로 분리하고, 게스트 `customer_id`는 그쪽에 저장하지 않는다.

## Decision 3 — go_router 배선을 이번 waiting feature 작업 범위에 포함

`go_router` 배선(`lib/app/router.dart` 생성 및 배선 포함)을 이번 waiting feature 작업 범위에 포함한다.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600211_Overview.md] =====
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


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600212_Logic.md] =====
# 600212_Logic.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-12

## 1. Purpose

`600211_Overview.md`의 스냅샷을 바탕으로, 게스트 `customer_id`를 Flutter 클라이언트가 실제로 어떻게 획득·저장·재사용하는지 상세 설계한다. 문서만 — `.dart` 파일은 이번 턴에도 생성하지 않는다.

## 2. 조사 근거 — Human 결정 2건의 배경 (2026-07-11/12 재확인)

### 2.1 `SharedPreferences`/`session_id` 명칭 충돌 조사

```
grep -rn "SharedPreferences" catchmenu_app/lib/      → 0건 (현재 어디서도 미사용)
grep -rn "session_id|sessionId" catchmenu_app/lib/   → 1건: rpc_caller.dart:205  'p_log_session_id': logSessionId
grep -rn "guest_customer_id|customerId|customer_id" catchmenu_app/lib/ → 0건
```

리터럴 키 충돌은 없었으나, `register_waiting()`/`0115` 응답 JSON이 이미 `jsonb_build_object('session_id', v_session_id, ...)` 형태로 실제 `catchmenu_pos.order_sessions.id` 값을 `'session_id'`라는 키로 반환하고 있음을 SQL 재확인으로 추가 발견했다(`0149` 패치본 및 `0115` 원본 공통). 즉 이 프로젝트에는 이미 "session_id"라는 이름이 (a) `RpcCaller.logSessionId`(dev audit 로그 그룹핑, `p_log_session_id`로 전송)와 (b) `order_sessions.id`(실제 대기/주문 세션) — 서로 무관한 두 개념으로 쓰이고 있어 개념 충돌 위험이 있었다.

**Human 결정 1 (2026-07-11, 재논의 금지)**: `SharedPreferences` 키 이름을 `guest_session_id` → **`guest_waiting_session_id`**로 변경. `guest_customer_id`는 그대로 유지. 저장 대상은 `register_waiting()`/`get_or_create_guest_customer()` 응답의 `'session_id'` 필드 값, 즉 `order_sessions.id`임을 명확히 한다.

### 2.2 `main.dart` 확인

```dart
// catchmenu_app/lib/main.dart 현재 33행
return MaterialApp(
  ...
  home: _BootScreen(initError: initError),
);
```

`main.dart`는 `MaterialApp`을 직접 사용하며(`MaterialApp.router`가 아님), `_BootScreen`을 `home:`에 고정 배치한다. `go_router`를 실제로 배선하려면 이 위젯 생성자 자체를 `MaterialApp.router(routerConfig: router, ...)`로 바꿔야 한다 — `MaterialApp`과 `MaterialApp.router`는 양립 불가능한 서로 다른 진입점이므로, `lib/app/router.dart`를 아무리 잘 만들어도 `main.dart`를 바꾸지 않으면 실제로 연결되지 않는다.

**Human 결정 2 (2026-07-11, 재논의 금지)**: `catchmenu_app/lib/main.dart` 수정(`MaterialApp` → `MaterialApp.router` 전환)을 이번 `600210` 작업 범위에 포함한다. go_router 배선의 구조적 전제조건이므로 별도 분리 불가.

## 3. Guest `customer_id` 처리 흐름

**정정 이력**: 이전 버전은 "`register_waiting()`이 최초 호출이고 그 응답에서 `customer_id`를 받는다"고 전제했으나, `600213_TestPlan.md` §0에서 `0149`의 실제 반환 `jsonb_build_object(...)`를 재확인한 결과 **`register_waiting()` 응답에는 `customer_id`가 없음**(`session_id`만 있음)을 발견했다. `600211_Overview.md` §0.3의 Human 결정(2026-07-11)에 따라 아래 순서로 소급 정정한다.

### 3.1 앱 부팅 시 `bootstrap_customer_app_v2()` 호출 — `customer_id` 확보

1. **부팅 호출**: `p_customer_id =` 저장된 값이 있으면 그 값, 없으면(최초 실행) `null`. `p_phone_hash =` 사용자가 입력했다면 그 값(해시 처리는 서버 측 기존 관례 그대로 — `600112_Logic.md`/`0148` 설계 범위, 이번 change에서 재논의하지 않음), 미입력이면 `null`.
2. `bootstrap_customer_app_v2()`는 `p_customer_id is null`이면 내부적으로 `catchmenu_store.get_or_create_guest_customer(p_tenant_id, p_phone_hash)`를 호출해 채운 뒤(`0149` L413 확인) 그 `customer_id`로 고객 정보를 조회하고, 응답에 `data.customer.id`(= `v_customer.id`, 곧 이 호출로 확보/재확인된 `customer_id`)를 중첩 반환한다.
3. **클라이언트는 응답의 `data.customer.id`를 즉시 `guest_customer_id` 키로 `SharedPreferences`에 저장한다** (§4). 신규 게스트라면 이 시점이 **최초 발급**이다.

**왜 3번이 필수인가 (Risk Notes 재확인)**: `get_or_create_guest_customer()`의 `phone_hash`가 없는 분기(완전 익명)는 호출마다 새 `customers` row를 생성하도록 설계되어 있다(SQL 주석 "phone_hash 없는 완전 익명: 매번 신규 row (Human 결정 #4)"). 저장된 `customer_id`를 재전달하지 않으면 다음 부팅 시에도 새 게스트 고객이 생기고, 대기열/주문 이력이 고객 단위로 이어지지 않는다.

### 3.2 `register_waiting()` 호출 — 저장된 `customer_id` 전달, `session_id` 확보

1. 사용자가 실제로 대기 등록을 요청하면, **§3.1에서 저장된 `guest_customer_id`를 `p_customer_id`로 명시적으로 전달**한다(이 시점에는 이미 non-null 값이 있으므로 `null`을 보내지 않는다).
2. `register_waiting()`도 `0149`에서 동일 패턴(`p_customer_id is null`이면 헬퍼 자동 호출, L181)을 갖지만, §3.1을 먼저 거쳤다면 이 분기는 타지 않는다. 응답에는 `customer_id`가 없고 **`session_id`(= `order_sessions.id`)만 있다.**
3. **클라이언트는 응답의 `session_id`를 `guest_waiting_session_id` 키로 `SharedPreferences`에 저장한다** (§4). 이 필드는 여전히 `register_waiting()`에서만 나온다 — 이 부분은 정정 대상이 아니다.

**`600112_Logic.md` §6 caller-contract 요구사항과의 관계**: 원래 §6은 "`bootstrap_customer_app_v2()`의 `if p_customer_id is not null then` 게이트가 있으므로, 게스트도 실제 `customer_id`를 명시적으로 넘겨야만 정상 동작하고, 안 넘기면 조용히 빈 결과가 나온다"고 경고했다. §3.1의 정정된 흐름에서는 **`bootstrap_customer_app_v2()` 자체가 `customer_id`의 최초 발급처**이므로, 이 caller-contract 우려는 §3.1의 "저장된 값이 있으면 전달, 없으면 null" 절차로 정확히 이행된다(최초 부팅은 `null`이 허용되고, 이후 모든 재부팅은 저장된 값을 명시적으로 넘겨야 한다는 점은 동일).

## 4. `SharedPreferences` 키 설계

`600203_DecisionLog.md` Decision 2에 따라 `SecureStorage`(JWT 전용)와 완전히 분리된 저장소를 사용한다. `pubspec.yaml`에 `shared_preferences: ^2.2.0`이 이미 등록되어 있음을 확인했다(신규 의존성 추가 불필요).

| 키 | 타입 | 설명 |
|---|---|---|
| `guest_customer_id` | `String` (uuid 문자열) | **`bootstrap_customer_app_v2()` 응답의 `data.customer.id`에서만 받는다** (§3.1 정정 — `register_waiting()` 응답에는 `customer_id`가 없음). 앱 재시작 후에도 유지. |
| `guest_waiting_session_id` | `String` (uuid 문자열) | **Human 결정(2026-07-11)으로 `guest_session_id`에서 개명** (§2.1 조사 근거). **`register_waiting()` 응답의 `'session_id'` 필드 값에서만 받는다**(`bootstrap_customer_app_v2()`는 이 필드를 반환하지 않음), 즉 실제 `catchmenu_pos.order_sessions.id`. **`RpcCaller.logSessionId`(dev audit 로그 그룹핑용, `p_log_session_id`로 전송되는 완전히 별개 개념)와 절대 혼동하지 말 것.** `guest_customer_id`와 함께 저장해 두 값이 어긋나지 않게 한다. |

두 키 모두 `catchmenu_app/lib/core/storage/` 하위 신규 파일(가칭 `guest_session_store.dart`)에서 읽기/쓰기 메서드로 감싸고, 화면 코드가 `SharedPreferences`를 직접 호출하지 않도록 한다(`rpc_caller.dart`가 `supabase.rpc()` 직접 호출을 막는 것과 같은 원칙 — 단일 경유 지점).

## 5. `main.dart` 전환 (`MaterialApp` → `MaterialApp.router`)

Human 결정 2(§2.2)에 따라 이 전환을 이번 change 범위에 포함한다.

- **현재 상태**: `CatchMenuApp.build()`가 `MaterialApp(... home: _BootScreen(initError: initError))`를 직접 반환.
- **전환 필요**: `MaterialApp.router(routerConfig: router, title: ..., theme: ..., debugShowCheckedModeBanner: false)` 형태로 변경. `router`는 `lib/app/router.dart`(§6)에서 정의하는 `GoRouter` 인스턴스.
- **`_BootScreen` 재배치 방안**: 현재 `_BootScreen`은 "Scope D 통과 후 연결한다"는 주석의 플레이스홀더이며 `initError` 유무에 따라 성공/실패 UI를 그린다. `MaterialApp.router` 전환 후에도 이 역할(초기화 실패 표시)은 유지되어야 하므로, 라우트 트리의 최초 진입 경로(예: `/`)에서 `_BootScreen` 역할을 하는 위젯으로 리다이렉트하거나, `GoRouter`의 `initialLocation`/`redirect` 콜백에서 `initError` 상태를 검사해 동일 화면으로 보내는 설계가 필요하다 (구체적 라우트 이름/파일 분리 여부는 Stage 2에서 확정).
- **§3.1(`bootstrap_customer_app_v2()`) 호출 시점**: `initError`가 없으면(Supabase 초기화 성공) 바로 이 최초 진입 경로에서 §3.1을 호출해 `guest_customer_id`를 확보한 뒤 `/waiting/register` 등 실제 화면으로 넘어가는 것이 자연스럽다 — 정확한 트리거 위치(부팅 위젯 내부 vs. 별도 리다이렉트 단계)는 Stage 2에서 확정.
- **기존 부팅 흐름에 미치는 영향 — Open Question (아래 §7-4 참고)**: `catchmenu_app/test/widget_test.dart`가 `CatchMenuApp(initError: ...)`을 직접 `pumpWidget`하고 `_BootScreen`의 에러 텍스트("초기화 실패")를 검증하고 있음을 확인했다(`grep -rn "_BootScreen|CatchMenuApp" catchmenu_app/lib/ catchmenu_app/test/` 결과, `main.dart` 외 유일한 참조). `MaterialApp.router` 전환 시 이 테스트가 여전히 통과하는지는 이번 턴에 조사만 하고 설계 확정은 다음 검증 라운드로 넘긴다. 참고로 (§5.10 frozen 상태인) `604101_Overview_Flutter_MVP_Project_Structure.md`도 `main.dart`를 "Boot: SupabaseInit, ProviderScope, placeholder home"으로, 장래에는 "router hook"을 갖는 것으로 서술하고 있어 이번 방향과 상충하지 않는다(단, 그 문서는 재검증 필요 상태이므로 권위 있는 근거로 인용하지 않는다).

## 6. `go_router` 라우트 구조 초안

`lib/app/router.dart`(신규)에서 최소 단위로 다음 두 화면만 정의한다(그 이상은 이번 change 범위 밖 — `600203_DecisionLog.md` Decision 3은 "배선 포함"만 확정했지, 전체 화면 세트를 확정한 것은 아님):

```text
GoRoute(path: '/waiting/register', ...)   // 대기 등록 화면
GoRoute(path: '/waiting/status', ...)     // 대기 상태 조회 화면
```

- `/waiting/register` 진입 시점에는 앱 부팅 단계(§3.1, `main.dart`/`_BootScreen` 경로)에서 이미 `bootstrap_customer_app_v2()`가 호출되어 `guest_customer_id`가 `guest_session_store`에 저장되어 있어야 한다 — 이 라우트 자체는 §3.1을 다시 수행하지 않고, **저장된 `guest_customer_id`를 그대로 `register_waiting()`의 `p_customer_id`로 전달**한다(§3.2).
- `/waiting/status`는 저장된 `guest_customer_id`/`guest_waiting_session_id`를 그대로 사용해 상태 조회 RPC(구체적 함수명은 `600120`/기존 `0115` 계열의 `get_waiting_status` 등 — 이번 change에서 새 RPC를 만들지 않음, 기존 함수 재확인은 Stage 2 범위)를 호출한다.
- `main.dart`/`_BootScreen`과의 실제 연결 지점(초기 라우트 지정, `bootstrap_customer_app_v2()`를 언제 호출할지)은 §5에서 다룬다.

## 7. `rpc_caller.dart`를 통한 호출 방식

모든 호출은 `RpcCaller.call<T>(...)`를 통해서만 이뤄진다. 직접 `supabase.rpc()`를 호출하는 코드는 어떤 화면/서비스에도 작성하지 않는다(`rpc_caller.dart` 자체 주석 "원칙 (900102 ChangeContract / INV-001~006): 앱의 어떤 코드도 `supabase.rpc()`를 직접 호출하지 않는다. 이 클래스만 사용." 재확인).

예시 호출 형태(실제 코드 아님, 설계 참고용) — §3.1/§3.2 순서대로:

```dart
// §3.1 — 앱 부팅 시 먼저 호출, customer_id 확보
final storedCustomerId = await guestSessionStore.getGuestCustomerId(); // 없으면 null
final bootResult = await rpcCaller.call<Map<String, dynamic>>(
  'bootstrap_customer_app_v2',
  schema: AppConstants.schemaStore,     // 'catchmenu_store' — 신규 상수 필요 (§8)
  pipeline: AppConstants.pipelineSession, // 'SESSION_MGMT' — 기존 상수 사용
  module: 'guest_bootstrap',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    'p_customer_id': storedCustomerId,  // null이면 최초 부팅, 있으면 재전달
    'p_phone_hash': phoneHashOrNull,
  },
);
final customerId = bootResult.requireData['customer']['id'] as String;
await guestSessionStore.saveGuestCustomerId(customerId);
```

```dart
// §3.2 — 사용자가 대기 등록을 요청할 때, 위에서 확보된 customer_id를 전달
final result = await rpcCaller.call<Map<String, dynamic>>(
  'register_waiting',
  schema: AppConstants.schemaPos,       // 'catchmenu_pos' — 기존 상수 사용
  pipeline: AppConstants.pipelineWaiting, // 'WAITING_HANDOFF' — 기존 상수 사용
  module: 'waiting_register',
  params: {
    'p_tenant_id': tenantId,
    'p_store_id': storeId,
    'p_guest_count': guestCount,
    'p_customer_id': customerId,        // 이미 §3.1에서 확보됨 — null을 다시 보내지 않는다
    'p_phone_hash': phoneHashOrNull,
    'p_source': 'CUSTOMER',             // register_waiting 기본값은 'STAFF' — 고객 앱에서는 명시 필요 (Open Question, 아래 참고)
  },
);
final sessionId = result.requireData['session_id'] as String; // register_waiting()에만 있는 필드
await guestSessionStore.saveGuestWaitingSessionId(sessionId);
```

## 8. 신규 상수 필요 사항

`AppConstants`에 `catchmenu_store` 스키마 상수가 없음을 재확인했다(`schemaPos`/`schemaPayment`/`schemaCommon`/`schemaKds`/`schemaDev`만 존재). `bootstrap_customer_app_v2()` 호출을 위해 `schemaStore = 'catchmenu_store'` 추가가 필요하다 — 이 change의 Stage 4(Codex 구현) 범위에 포함되어야 하며, 이번 Stage 1.5 문서 작성 자체는 파일을 만들지 않는다.

## 9. Open Questions

1. **완전 익명 게스트의 앱 재설치 시 `customer_id` 유실** — `phone_hash` 없이 등록한 게스트는 `SharedPreferences`가 앱 삭제/재설치로 초기화되면 이전 `customer_id`를 잃고, 다음 호출이 새 게스트 row를 만든다. 이는 이미 `get_or_create_guest_customer()`의 설계 자체(SQL 주석 "Human 결정 #4" — 익명 게스트는 dedupe하지 않음)에서 알려진 제약의 클라이언트 측 귀결이다. **재논의 대상 아님** — 이 문서는 사실만 명시한다.
2. `register_waiting()`의 `p_source` 기본값은 `'STAFF'`이다. 고객 앱에서 호출할 때는 `'CUSTOMER'` 등 별도 값을 명시해야 하는지, 아니면 기존 `chk_event_caused_by_type` 제약이 허용하는 값 목록에 고객-앱 전용 값이 이미 있는지 확인 필요 — Stage 2(TestPlan/ChangeContract)에서 확정.
3. ~~`guest_session_id`의 정확한 발급 주체~~ — **해결됨**: §2.1 재확인으로 `register_waiting()`/`get_or_create_guest_customer()` 응답의 `'session_id'` 필드(= `order_sessions.id`)에서 옴을 확정. 클라이언트 자체 생성 uuid가 아니다.
4. **(신규) `main.dart`/`MaterialApp.router` 전환이 기존 부팅 흐름에 미치는 영향** — `catchmenu_app/test/widget_test.dart`가 현재 `MaterialApp`(non-router) 구조를 전제로 `_BootScreen`의 에러 텍스트를 직접 검증 중. 전환 후에도 이 테스트가 유효한지, 다른 곳에서 `CatchMenuApp`/`_BootScreen`에 암묵적으로 의존하는 부분이 있는지는 이번 턴에 조사만 완료했고(§5 참고), 설계 확정과 실제 `.dart` 수정은 Stage 2 이후로 넘긴다.
5. **(신규, Stage 4 구현 후 Cursor 재검증에서 발견 — `600217_Audit.md` Open Item (d) 참고) 하드코딩된 `tenant_id`/`store_id` 교체** — `waiting_register_screen.dart`의 `_defaultTenantId`/`_defaultStoreId`가 MVP 단일 매장(윤슬김밥) 값으로 고정되어 있다. Human 결정(2026-07-11)으로 현재 MVP 단계에서는 유지하되, 실제 인증/설정 컨텍스트에서 `tenant_id`/`store_id`를 받아오도록 교체하는 작업은 다국점/멀티테넌트 전환 전 필수 — **`600200` 모듈의 다음 변경건 후보**로 남긴다(이번 change의 범위 재확대 아님, 새 workpacket 번호는 착수 시점에 확정).

## 10. Snapshot Decision

이 스냅샷으로 Stage 2(`600213_TestPlan.md`/`600214_ChangeContract.md`, 다음 번호는 Stage 3 승인 시점 재확인) 작성 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600213_TestPlan.md] =====
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


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600214_ChangeContract.md] =====
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


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600215_Module.md] =====
# 600215_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Codex
Date: 2026-07-12

## Summary

Implemented the approved `waiting_feature_guest_customer_id_integration` change (`600214_ChangeContract.md`) within the corrected call order confirmed in `600213_TestPlan.md` §0 / `600211_Overview.md` §0.3: `bootstrap_customer_app_v2()` obtains `customer_id` at app boot; `register_waiting()` receives that stored `customer_id` and returns `session_id`.

## File-by-File Summary (7 files, `git diff --cached --stat`: 417 insertions(+), 33 deletions(-))

| File | Change | Role |
|---|---|---|
| `catchmenu_app/lib/main.dart` | Modified (35 lines changed) | `CatchMenuApp.build()` converted from `MaterialApp(home: _BootScreen(...))` to `MaterialApp.router(routerConfig: router, ...)`, where `router` comes from the new `createAppRouter(bootScreen: _BootScreen(...))`. `_BootScreen` itself unchanged (still shows the same success/error UI based on `initError`). |
| `catchmenu_app/lib/app/router.dart` | New (22 lines) | `createAppRouter({required Widget bootScreen})` returns a `GoRouter` with `initialLocation: '/'` and three routes: `/` → `bootScreen`, `/waiting/register` → `WaitingRegisterScreen`, `/waiting/status` → `WaitingStatusScreen`. All three `builder`s are synchronous — no `FutureBuilder`, no `redirect` callback. |
| `catchmenu_app/lib/core/storage/guest_session_storage.dart` | New (29 lines) | `GuestSessionStorage` wraps `SharedPreferences` with exactly the two keys decided in `600212_Logic.md` §4: `guest_customer_id`, `guest_waiting_session_id` (matches the Human-decided rename from `guest_session_id`). Four methods: get/save for each key. No direct `SharedPreferences` calls exist elsewhere in `lib/`. |
| `catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart` | New (250 lines) | Implements the corrected order: `_ensureGuestCustomerId()` reads stored `customer_id` first, and only if absent calls `bootstrap_customer_app_v2()` (via `rpcCaller.call<T>`, schema `catchmenu_store`) and stores `data.customer.id`. `_registerWaiting()` then calls `register_waiting()` (schema `catchmenu_pos`) with that `customer_id` and `p_source: 'CUSTOMER'`, and stores the returned `data.session_id`. Both RPC calls are gated behind a `FilledButton.onPressed` — nothing fires at build/mount time. |
| `catchmenu_app/lib/features/waiting/screens/waiting_status_screen.dart` | New (68 lines) | Read-only display of the two stored ids via `GuestSessionStorage`. Deliberately does **not** invent a status-lookup RPC call (source comment: "Status lookup RPC integration is intentionally not invented in this change") — matches `600213_TestPlan.md`/`600214_ChangeContract.md`'s instruction not to design a new RPC in this change. |
| `catchmenu_app/lib/core/constants/app_constants.dart` | Modified (19 lines changed) | Adds `schemaStore = 'catchmenu_store'` as instructed (`600214_ChangeContract.md` §1, minimal addition). Remaining diff lines are `dart format`-style re-wrapping of pre-existing declarations (`appEnv`, `supabaseAnonKey`, `schemaPos` line-break, `forbiddenClientRpcs` collapsed to one line) — no logic change; `forbiddenClientRpcs` set contents unchanged (`{'release_kds_after_payment'}`). |
| `catchmenu_app/test/widget_test.dart` | Modified (27 lines changed) | Kept a single `testWidgets` case. Uses a **fixed `tester.pump(Duration(milliseconds: 100))`**, not `pumpAndSettle()` — avoids the indefinite-wait hang risk `600213_TestPlan.md` §3 flagged for a `MaterialApp.router` conversion. Assertion changed from the static label `'초기화 실패'` to the dynamic `initError!.message` text (`'test Supabase config missing'`) — still verifies the same error-branch render, just via the message text instead of the label. |

## Boundary Compliance Check (`600214_ChangeContract.md` §1/§2)

- `git diff --cached --stat` re-confirmed: exactly these 7 files, all inside `catchmenu_app/lib/**` or `catchmenu_app/test/**`. No other path touched.
- **`sql/migrations/**`**: 0 changes (`git diff --cached --stat -- sql/migrations/` empty).
- **`catchmenu_app/lib/core/supabase/rpc_caller.dart`**: 0 changes. Both screens call it only via `rpcCaller.call<Map<String, dynamic>>(...)` — `grep -rn "supabase.rpc(" catchmenu_app/lib/features/waiting/` returns 0 matches.
- **`catchmenu_app/lib/core/supabase/supabase_client.dart`**, **`catchmenu_app/lib/core/errors/app_error.dart`**: 0 changes.
- **`600110_.../600120_.../` (600111–600127)**: 0 changes.
- All 7 files are currently **staged** (`git status --short` shows `A`/`M`, not committed) — no commit was made.

## Deviations From `600212_Logic.md` (Recorded, Not Defects)

- §7's illustrative code used `AppConstants.pipelineSession` for `bootstrap_customer_app_v2`; the implementation matches this exactly (`pipeline: AppConstants.pipelineSession`).
- `waiting_status_screen.dart` goes further than §6's draft by explicitly documenting (in-code comment) why it does not call a status RPC, rather than silently omitting it — a clarity improvement, not a scope deviation.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600216_Verification.md] =====
# 600216_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Claude
Date: 2026-07-12

## Verification Result

Final result: PASS.

## 1. `flutter analyze`

```
$ flutter analyze
Analyzing catchmenu_app...
   info - 'anonKey' is deprecated and shouldn't be used. Use publishableKey instead.
          anonKey will be removed in a future major version -
          lib\core\supabase\supabase_client.dart:32:7 - deprecated_member_use
1 issue found. (ran in 3.7s)
```

**1 issue, out of scope.** `supabase_client.dart` is not one of the 7 files this change touches (`600215_Module.md` boundary check confirms 0 diff on this file) — the `anonKey`/`publishableKey` deprecation predates this change and is not this change's responsibility to fix.

## 2. `flutter test` — Initial Hang, Retest, Root-Cause Investigation

A prior session turn reported `flutter test` appearing to hang. This turn re-ran the full diagnostic sequence before accepting PASS as final:

### 2.1 Retest with bounded timeout

```
$ flutter test --timeout 60s
00:00 +0: loading D:/workspace/yoonsul_wait_order_handoff/catchmenu_app/test/widget_test.dart
00:00 +0: bootstrap screen renders initialization failure through router
00:00 +1: All tests passed!
EXIT_CODE=0
```

Completed in well under 1 second of test-framework time, far short of the 60s cap. **Did not reproduce the hang.**

### 2.2 Code-level hang-risk check (3 locations)

| Location | Checked for | Finding |
|---|---|---|
| `catchmenu_app/test/widget_test.dart` | Use of `pumpAndSettle()` (which waits indefinitely and would hang on any unresolved animation/timer/Future) | **Not used.** Implementation uses a fixed `tester.pump(Duration(milliseconds: 100))` instead — the exact hang vector `600213_TestPlan.md` §3 flagged was avoided by this design choice. |
| `catchmenu_app/lib/app/router.dart` | Async initialization in route `builder`s (`FutureBuilder`, `redirect` callback awaiting network) | **None found.** All three `builder`s (`/`, `/waiting/register`, `/waiting/status`) are synchronous widget constructors. |
| `catchmenu_app/lib/features/waiting/screens/waiting_register_screen.dart` | RPC calls fired at build/mount time rather than on user action | **Not found at mount time.** `initState()` → `_loadStoredIds()` only reads `SharedPreferences` (local, not network). The actual RPC calls (`bootstrap_customer_app_v2`, `register_waiting`) are inside `_ensureGuestCustomerId()`/`_registerWaiting()`, both reachable only via `FilledButton.onPressed`. The current test does not even navigate to this screen, so this path is not exercised by `widget_test.dart` regardless. |

### 2.3 Conclusion on the hang

No structural hang-cause was found in the current code, and the retest passed cleanly. The most plausible explanations for the originally reported hang are (a) a one-time slow first run (dependency resolution / build cache warm-up, not a code defect) or (b) the hang risk was already avoided by the implementation's choice of a bounded `pump()` over `pumpAndSettle()`. This is not asserted as a certainty — it is not reproducible with the current code, and is recorded as such rather than as a confirmed root cause.

## 3. Coverage Gap (Open Item, Not a Blocker)

`catchmenu_app/test/widget_test.dart` renders only the `/` (boot) route. **It does not render or exercise `/waiting/register` (`WaitingRegisterScreen`) or `/waiting/status` (`WaitingStatusScreen`)** — neither the RPC call flow (`bootstrap_customer_app_v2` → `register_waiting`) nor the `GuestSessionStorage` read/write paths have any automated test coverage. This is a real gap, not something this change is required to close per `600214_ChangeContract.md` (which did not mandate new screen tests), but it is recorded here so it is not silently lost. Recommend a follow-up workpacket to add widget tests for both screens (mocking `RpcCaller`/`SharedPreferences`).

## Scenario Summary

| Scenario | Result |
|---|---|
| `flutter analyze` — 0 new issues introduced by this change | PASS |
| `flutter test` — full suite | PASS |
| `flutter test` hang — reproduced this turn | NOT REPRODUCED |
| Hang-risk code patterns (pumpAndSettle, async router builder, build-time RPC) | NONE FOUND |
| `/waiting/register`, `/waiting/status` screen test coverage | **GAP — carried to Open Items** |


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600210_waiting_feature_guest_customer_id_integration/600217_Audit.md] =====
# 600217_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-12

## Final Audit Decision

ACCEPT.

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside the approved `600214_ChangeContract.md` boundary | PASS | `600215_Module.md` boundary check: exactly the 7 allowed files touched (`main.dart`, `router.dart`, `guest_session_storage.dart`, both `waiting/screens/*.dart`, `app_constants.dart`, `widget_test.dart`); `sql/migrations/**`, `rpc_caller.dart` internals, `supabase_client.dart`, `app_error.dart`, `600110`/`600120` outputs all confirmed untouched (`git diff --cached --stat`). |
| Implementation matches the 4 design documents | PASS | Call order matches `600211_Overview.md` §0.3 / `600212_Logic.md` §3 (`bootstrap_customer_app_v2()` first, `register_waiting()` second); `SharedPreferences` key names match `600212_Logic.md` §4 exactly (`guest_customer_id`, `guest_waiting_session_id`); router routes match `600212_Logic.md` §6 (`/`, `/waiting/register`, `/waiting/status`); RPC calls route only through `rpcCaller.call<T>(...)` per §7. |
| `flutter analyze` / `flutter test` pass | PASS | `600216_Verification.md` §1/§2: 1 pre-existing out-of-scope issue (`supabase_client.dart:32`, unrelated file), 0 issues in this change's files; `flutter test` — 1/1 passed. |
| No boundary violation (payment/KDS, SQL, rpc_caller internals) | PASS | `600211_Overview.md`'s INV-001~006 non-contact finding still holds — this change calls only `bootstrap_customer_app_v2`/`register_waiting`, neither of which touch `kds_tickets`/`payment_ledger`; confirmed no `release_kds_after_payment` reference in the new screens. |

## Findings

1. `guest_session_storage.dart` correctly implements both keys with the Human-decided rename (`guest_waiting_session_id`, not the earlier `guest_session_id`) and does not collide with `RpcCaller.logSessionId`.
2. `waiting_register_screen.dart` correctly gates both RPC calls behind explicit user action (button press), not build/mount — this independently confirms `600216_Verification.md` §2.2's finding that no RPC fires automatically during widget construction.
3. `waiting_status_screen.dart` deliberately avoids inventing a status-lookup RPC, correctly honoring `600214_ChangeContract.md`'s scope (no new RPC in this change).
4. `widget_test.dart`'s use of a bounded `pump()` instead of `pumpAndSettle()` is consistent with — and appears to have already addressed — the hang risk `600213_TestPlan.md` §3 raised before implementation.
5. The originally reported `flutter test` hang could not be reproduced in this audit pass; see `600216_Verification.md` §2 for the full investigation. Recorded as unresolved-but-not-blocking rather than closed with certainty.

## Open Items Carried Forward

(a) **`widget_test.dart` coverage gap** — `/waiting/register` and `/waiting/status` are not exercised by any automated test (`600216_Verification.md` §3). Not a blocker for this ACCEPT; recommend a follow-up workpacket.

(b) **Complete-anonymous-guest dedupe** (pre-existing Known Constraint, `600214_ChangeContract.md` §4) — a guest with no `phone_hash` loses continuity on app reinstall, by original design (Human 결정 #4 in `get_or_create_guest_customer()`). Not this change's defect; not open for re-litigation.

(c) **`604101`/`604102` (§5.10 frozen) boot-flow alignment** — `600214_ChangeContract.md` §3-3 had left this as "needs independent re-verification after Stage 4." That re-verification has now effectively happened through this change's actual `flutter test` execution against the real `MaterialApp.router`/`_BootScreen` structure (`600216_Verification.md` §2.1 PASS) — the boot flow works as implemented, independent of whatever those frozen documents describe. No further separate re-check against `604101`/`604102` is needed; those documents remain frozen/non-authoritative regardless.

(d) **(신규 — Cursor 재검증 발견, Known Limitation) 하드코딩된 `tenant_id`/`store_id`** — `waiting_register_screen.dart`의 `_defaultTenantId = '00000000-0000-0000-0000-000000000001'`, `_defaultStoreId = '00000000-0000-0000-0000-000000000002'`(`TextEditingController`의 초기값으로 사용, 화면에서 직접 수정은 가능). 재확인 결과 이 값은 오늘 세션의 클라우드 마이그레이션 검증(`600126_Verification.md`의 `register_waiting()` 호출 예시, `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid` 등)에 쓰인 것과 정확히 동일한 값이다. **`waiting_status_screen.dart`에는 애초에 `tenant_id`/`store_id` 파라미터 자체가 없다**(이 화면은 어떤 RPC도 호출하지 않고 저장된 값만 표시하므로 — 지시 원문의 "두 화면 모두 하드코딩"이라는 전제는 `waiting_register_screen.dart`에만 해당함을 확인 후 정정해 기록한다). **Human 결정(2026-07-11)**: 현재 MVP 단계(윤슬김밥 단일 매장)에서는 이 하드코딩 값을 그대로 유지한다. 실제 인증/설정 컨텍스트에서 `tenant_id`/`store_id`를 받아오도록 교체하는 작업은 다국점/멀티테넌트 전환 전에 반드시 필요한 Known Limitation으로 기록하며, 이번 change의 결함으로 취급하지 않는다.

(e) **(기존 확인, Known Limitation) RPC 실패 시 에러 표시만, 별도 재시도/오프라인 큐 없음** — `waiting_register_screen.dart`의 `_registerWaiting()`은 실패 시 `catch (e) { setState(() { _error = e.toString(); }); }`로 에러 텍스트만 표시한다. 전용 "재시도" 버튼이나 오프라인 큐는 없으며, `finally`에서 `_isLoading`이 해제되므로 사용자가 동일한 "Register waiting" 버튼을 다시 누르는 것으로만 재시도가 가능하다. `604102_Logic_Flutter_MVP_Core_Implementation.md`(§5.10 frozen)는 "No silent offline mode for MVP"를 명시하면서도 `NETWORK_ERROR` 등에 대해 전용 재시도 버튼 UI를 서술하고 있어(예: "Retry button; no state mutation"), 이번 구현의 단순 에러 텍스트 표시와 완전히 같은 수준은 아니다 — 이 화면 구현이 그 원칙과 정합한지는 후속 검토가 필요한 사항으로 기록한다(이번 change의 승인 범위 밖).

(f) **(기존 확인, Known Limitation) 완전 익명 게스트가 매 세션 새 `customer_id`를 받는 것에 대한 UI 안내 부재** — `waiting_register_screen.dart`/`waiting_status_screen.dart` 어디에도 "전화번호 없이 등록하면 재설치 시 이전 대기 이력을 잃는다"는 안내 문구가 없다. 이는 Human 결정 #4(익명 게스트 dedupe 없음)의 UX상 자연스러운 귀결이며 **재논의 대상이 아니지만**, 사용자 경험 개선 여지(예: 전화번호 미입력 시 안내 문구 추가)로 기록한다.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- This audit does not touch cloud or `sql/migrations/`.
- The 7 files remain staged, not committed, per this turn's instruction.

## Conclusion

The `waiting_feature_guest_customer_id_integration` implementation satisfies its ChangeContract boundary, matches its 4 design documents, passes static analysis and the test suite, and introduces no payment/KDS boundary contact. The two carried-forward Open Items (a, b) are informational, not blocking.

Final status: ACCEPT.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600221_Overview.md] =====
# 600221_Overview.md

Status: Draft
Lifecycle: Overview
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## Change ID

`platform_deployment_strategy`

## Change Summary

플랫폼별(STAFF_APP/KDS_DISPLAY/DID_DISPLAY vs 고객용) 배포 전략을 확정한다. 이번 산출물(Stage 1.5)은 문서만 — 실제 빌드 설정 파일은 생성/수정하지 않는다.

## §0 Human 결정 재확인 (2026-07-11, 재논의 금지)

1. **STAFF_APP, KDS_DISPLAY, DID_DISPLAY**: Android 태블릿 우선(네이티브 앱, 매장 내 고정 디바이스 전제).
2. **고객용**(멤버십 대시보드, 대기 상태 조회 등): 웹 + 모바일 둘 다 지원(Flutter Web + Android/iOS 앱 양쪽).
3. **MINI_KIOSK**: MVP 범위 밖(Kiosk/POS 실하드웨어 연동은 후순위로 이미 확정). `900161`(Flutter Web)과 `900171`(Android/Windows)의 문서 간 충돌은 지금 해결 불필요 — Open Item(§Logic.md)으로만 기록.
4. `catchmenu_app`은 이미 6개 플랫폼(web/android/ios/linux/macos/windows) 폴더를 가진 상태로 생성돼 있음(이번 턴 `ls catchmenu_app/` 재확인) — 플랫폼 추가 작업 불필요, 각 플랫폼별 실제 빌드/배포 설정만 필요.

## 오늘 전수 검색 결과 요약 (Cursor, 인용)

문서 간 플랫폼 언급이 서로 다른 곳들을 재확인했다:

| 문서 | 플랫폼 관련 언급 |
|---|---|
| `900161_Logic_...md` §6(L526-560) "Flutter 구현 바인딩" | "**키오스크 앱 (Flutter Web)**"으로 명시. "직원앱 (Flutter)"/"DID 앱 (Flutter)"는 플랫폼(웹 vs 네이티브)을 특정하지 않고 일반 "Flutter"로만 서술 — **STAFF/DID를 Android 네이티브로 확정하는 이번 결정과 상충하지 않으나, 900161 자체가 Android를 명시적으로 확인해주는 것도 아니다**(생략일 뿐). 키오스크만 "Flutter Web"으로 명확히 못박혀 있어, 이번 결정(§0-3, MINI_KIOSK 범위 밖)과는 무관하되 `900171`과의 충돌 당사자다. |
| `900171_Policy_Slot_Container_Agent_Platform_Support_Android_And_Windows.md` §0 | "설치 대상: ... 키오스크 → Android (안드로이드 키오스크) 또는 Windows (PC 키오스크)" — **`900161`의 "키오스크 = Flutter Web"과 정면으로 다른 플랫폼을 전제**. 이번 턴 원문 재확인. |
| `900110_Overview_Channel_1_Web_App_Customer_Handoff_And_Session.md` §1 | "채널명: Web App, 접근 방법: QR 스캔 → 브라우저 자동 실행, 설치 요구: 없음, 인증 요구: 없음(anon), 멤버십: 없음(게스트 세션)" — 완전 익명/무설치 웹 채널. |
| `900120_Overview_Channel_2_Catch_Menu_Native_App_Customer_Handoff_And_Session.md` §1 | "채널명: Catch Menu Native App, 접근 방법: App Store/Play Store 설치 후 실행, 인증 요구: 전화번호 OTP 로그인, 멤버십: STAMP/POINT" — 로그인 기반 네이티브 채널. **`catchmenu_app`이 바로 이 Channel 2에 해당한다.** |
| `604101_Overview_Flutter_MVP_Project_Structure.md`(§5.10 frozen, 참조만) §8.2 | "Same binary or flavor TBD" — 직원 앱이 별도 바이너리인지 같은 코드베이스의 flavor(빌드 변형)인지 미확정 상태로 남아있음, 이번 턴 원문 재확인. |
| `0135_create_flutter_mvp_start_package.sql` | MINI_KIOSK를 "Phase 3(3 weeks)"로 별도 단계 취급 — 이번 결정(§0-3, MVP 범위 밖)과 시점상 방향은 일치(후순위). |

`900111`/`900121`(각 Channel의 Logic 문서)은 이번 배치에서 직접 인용하지 않음 — §0 defect/decision-based document-linking 원칙에 따라, 이번 결정과 직접 관련된 §0 항목의 근거만 링크한다.

## 이번 결정과 기존 문서의 일치/불일치 명시

- **일치**: `900110`(Channel 1, Web, 무설치/게스트)과 `900120`(Channel 2, Native, OTP/멤버십)의 이미 확정된 이원 채널 설계는, 이번 결정 §0-2("고객용: 웹+모바일 둘 다")의 방향과 일치한다 — 다만 이게 "하나의 Flutter 코드베이스를 web/android/ios로 각각 빌드"를 뜻하는지, 아니면 "Channel 1(웹)과 Channel 2(네이티브)가 애초에 서로 다른 구현체"를 뜻하는지는 **아직 확정되지 않았다**(`600222_Logic.md` Open Item).
- **불일치(이번 결정 범위 밖으로 명시적으로 제외됨)**: `900161`(키오스크=Flutter Web) vs `900171`(키오스크=Android/Windows)의 MINI_KIOSK 플랫폼 충돌. §0-3 Human 결정에 따라 지금 해결하지 않는다.
- **부분 확인 불가**: `900161` §6은 STAFF/DID 앱을 "Flutter"로만 서술하고 Android/웹 여부를 특정하지 않으므로, 이번 결정(§0-1, Android 우선)과 "상충하지는 않지만 명시적으로 확인해주지도 않는다" — 단순 일치로 단정하지 않는다.

## Candidate Affected Files (신규 설계 대상 — 이번 턴에 생성하지 않음)

이번 문서는 순수 전략 확정이며 구체적 파일 변경 대상은 `600222_Logic.md`에서 다룬다(빌드 설정 자체는 이번 워크패킷에서도 생성/수정하지 않음 — 지시 사항).

## Module Domain Tags

- FLUTTER_CLIENT
- DOCUMENTATION_ONLY

## Uncertainties

- Channel 1 웹앱과 `catchmenu_app`(Channel 2)의 관계(동일 repo 멀티타겟 vs 별도 프로젝트) — `600222_Logic.md` Open Item.
- MINI_KIOSK 플랫폼(`900161` vs `900171`) — 이번 범위 밖, Open Item으로만 유지.
- "Same binary or flavor TBD"(`604101` §8.2)의 최종 결정 — 이번 결정 시점에서도 미확정, `600222_Logic.md` Open Question.

## Known Gaps

없음 — 이번 조사는 §0 Human 결정과 직접 관련된 문서(900161/900171/900110/900120/604101/0135)만 다뤘다.

## Snapshot Decision

이 스냅샷으로 `600222_Logic.md` 작성 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600222_Logic.md] =====
# 600222_Logic.md

Status: Draft
Lifecycle: Logic
Stage: 1.5 (Claude Code role)
Owner: TBD
Last Updated: 2026-07-13

## 1. Purpose

`600221_Overview.md`의 스냅샷을 바탕으로 플랫폼별 빌드 타겟 전략을 설계한다. 문서만 — 실제 빌드 설정 파일(`android/`, `ios/`, `web/` 등 하위 설정)은 이번 턴에 생성/수정하지 않는다.

## 2. STAFF_APP / KDS_DISPLAY / DID_DISPLAY — Android 태블릿 우선

`catchmenu_app/android/`가 이미 존재한다(이번 턴 `ls catchmenu_app/` 재확인 — `flutter create`가 6개 플랫폼 폴더를 이미 생성해둔 상태). **별도 프로젝트 분리 불필요** — 기존 `catchmenu_app/android/`를 그대로 빌드 타겟으로 사용한다.

```bash
# 참고용 빌드 명령(설계 문서 기록, 이번 턴 실행하지 않음)
flutter build apk --target=lib/main_staff.dart   # 예시 — 실제 entry point 분리 여부는 §4 Open Question
```

세 화면(직원/KDS/DID)이 하나의 Android APK 안에서 라우트로만 구분되는지, 아니면 별도 entry point(`main_staff.dart` 등)로 분리되는지는 `604101` §8.2("Same binary or flavor TBD")가 이미 미확정으로 남겨둔 사항과 동일한 질문이다 — 이번 결정(§0-1)은 "Android 태블릿"이라는 **플랫폼**만 확정했을 뿐, 코드베이스 분리 방식(같은 바이너리 vs flavor vs 별도 entry point)까지 확정하지 않았다(§4 Open Question 유지).

## 3. 고객용 — 웹 + 모바일 양쪽

### 3.1 웹 빌드 타겟

```bash
# 참고용, 이번 턴 실행하지 않음
flutter build web
```

**정정(2026-07-13, Human 결정 — "폴더 존재"와 "실제 빌드 작동"은 서로 다른 사실이다)**: 이전 버전은 이 둘을 구분 없이 섞어 서술했다. 아래와 같이 명확히 분리한다.

- **확인된 사실 — 폴더 존재**: `catchmenu_app/web/` 폴더가 실제로 존재하며(이번 턴 `ls catchmenu_app/web/` 재확인), 그 안에 `favicon.png`, `icons/`, `index.html`, `manifest.json`이라는 표준 Flutter web 스캐폴드 파일들이 들어있다. 이건 `flutter create` 시점에 자동 생성된 것으로 보인다.
- **미검증 사실 — 실제 빌드 작동 여부**: `flutter build web` 명령이 실제로 에러 없이 완료되는지는 **이번 세션 전체 히스토리를 통틀어 한 번도 실행된 적이 없다.** 확인 근거: `catchmenu_app/build/` 폴더를 직접 확인한 결과 `native_assets/`, `test_cache/`, `unit_test_assets/`만 있고(전부 이전 세션의 `flutter test` 실행이 남긴 산출물) `build/web/` 디렉터리 자체가 존재하지 않는다 — `flutter build web`이 실행됐다면 반드시 생겼을 산출물이 없다는 뜻이다. `git log --all --grep="build web"`도 매치 0건. **따라서 "폴더가 존재한다"는 사실로부터 "웹 빌드가 실제로 작동한다"를 추론할 수 없다 — 완전히 별개의, 아직 검증되지 않은 질문이다.**

### 3.2 모바일(android/ios) 빌드 타겟

`catchmenu_app/android/`, `catchmenu_app/ios/` 모두 이미 존재 — 기존 폴더 재사용, 신규 생성 불필요.

### 3.3 §0-2 결정과 기존 채널 설계(900110/900120)의 관계 — 명확히 구분 필요

`600221_Overview.md`에서 확인했듯, 이 프로젝트는 이미 "고객용"을 두 개의 **서로 다른 채널**로 설계해뒀다:

- **Channel 1**(`900110`/`900111`, Web App): QR 스캔, 무설치, 익명(anon) 게스트 세션, 멤버십 없음.
- **Channel 2**(`900120`/`900121`, Native App): App Store/Play Store 설치, 전화번호 OTP 로그인, STAMP/POINT 멤버십. **`catchmenu_app`이 바로 이 Channel 2다.**

이번 §0-2 결정("고객용: 웹+모바일 둘 다 지원, Flutter Web + Android/iOS 앱 양쪽")이 **어느 쪽을 의미하는지 이번 결정 자체에서는 명확히 하지 않았다** — 두 가지로 해석 가능하다:

(a) `catchmenu_app`(Channel 2) **하나의 Flutter 코드베이스**를 `flutter build web`으로도 빌드해서, 로그인/멤버십 기능을 웹에서도 그대로 제공한다 — 이 경우 Channel 1(익명/무설치)의 존재 의미와 정확히 어떻게 공존하는지 불명확(Channel 1은 "설치 없이 접근"이 핵심 가치인데, Channel 2를 웹으로 빌드해도 로그인 절차 자체는 남는다).

(b) Channel 1(웹, 익명)과 Channel 2(네이티브, 멤버십)는 **원래 설계대로 계속 별개**이며, 이번 §0-2는 단순히 "고객 접점이 웹과 모바일 둘 다 있다"는 사실을 재확인한 것일 뿐, `catchmenu_app` 하나를 멀티타겟으로 만들라는 지시가 아니다.

**이번 문서는 (a)/(b) 중 하나를 선택하지 않는다** — Stage 3에서 확정 필요(§4 Open Item).

## 4. Open Questions / Open Items

1. **("Same binary or flavor TBD", §2 참고) STAFF_APP/KDS_DISPLAY/DID_DISPLAY의 코드베이스 분리 방식** — 같은 `catchmenu_app` 바이너리 안에서 라우트로만 구분할지, Flutter flavor로 분리할지, 아예 별도 entry point(`main_staff.dart` 등)로 분리할지 미확정. `604101`(§5.10 frozen)이 이미 이 질문을 미결로 남겨뒀고, 이번 결정도 이를 해소하지 않는다.
2. **(§3.3) Channel 1 웹앱과 `catchmenu_app`의 관계** — 동일 repo 멀티타겟(하나의 Flutter 코드베이스가 web/android/ios 전부 빌드)인지, 아니면 Channel 1이 애초에 별도 프로젝트(예: 별도 웹 전용 구현체)인지 이전 조사에서도 미확인이었고 이번에도 확정되지 않았다. `900110`/`900120`이 서로 다른 인증/멤버십 모델을 전제하고 있어, 단순히 "같은 코드를 웹으로도 빌드하면 된다"고 가정하기 어렵다 — Stage 3 확정 필요.
3. **MINI_KIOSK 플랫폼 충돌(`900161` Flutter Web vs `900171` Android/Windows)** — §0-3 Human 결정에 따라 이번 범위 밖, 지금 해결하지 않음. 기록만 유지.
4. **STAFF_APP/KDS_DISPLAY/DID_DISPLAY의 실제 배포 방식(MDM, 사이드로드, Play Store 비공개 배포 등)** — 이번 결정은 "Android 태블릿 우선"이라는 플랫폼만 확정했을 뿐, 매장 내 고정 디바이스에 실제로 어떻게 앱을 설치/갱신할지는 다루지 않았다 — 향후 별도 결정 필요(이번 change 범위 밖으로 신규 기록).
5. **(신규, 2026-07-13) `flutter build web`이 실제로 에러 없이 완료되는지 확인 필요** — `catchmenu_app/web/` 폴더와 스캐폴드 파일의 존재는 확인됐으나(§3.1), 빌드 명령 자체가 성공하는지는 이번 문서 작성 범위에서는 **미실행**이다. 별도 워크패킷/Stage 2 TestPlan 단계에서 실제로 `flutter build web`을 실행해 에러 유무를 확인해야 한다 — 이번 문서는 그 실행을 하지 않는다.

## 5. Snapshot Decision

이 스냅샷으로 Stage 2(TestPlan/ChangeContract, 다음 번호는 Stage 3 승인 시점 재확인) 작성 진행 가능.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600223_TestPlan.md] =====
# 600223_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude role)
Last Updated: 2026-07-13

## 0. Scope and Attitude

Per §28, prose 설명만으로는 불충분 — 아래 모든 단계는 실제 실행 가능한 명령어다. 이 문서는 이번 턴에 실행하지 않는다 — Stage 3 승인 이후 Stage 4/5에서 실행할 절차를 설계하는 것이 이번(Stage 2) 산출물이다.

**태도 원칙(반복 강조, `600222_Logic.md` §4 Open Item 5 직접 대응)**: `flutter build web`은 이번 세션 전체를 통틀어 한 번도 실행된 적이 없다(확인 근거: `catchmenu_app/build/`에 `native_assets/`/`test_cache/`/`unit_test_assets/`만 있고 `build/web/`가 없음 — `600222_Logic.md` §3.1). 따라서 이 TestPlan의 목적은 **"빌드가 성공해야 한다"가 아니라 "실행해서 결과를 있는 그대로 기록한다"**다. 실패도 유효한 결과다 — 실패 시 에러를 고치려 시도하지 않고, Stage 1.5(`600221_Overview.md`/`600222_Logic.md`)로의 롤백 신호로만 취급한다(`600224_ChangeContract.md` §4).

이번 턴(Stage 2 문서 작성) 배경 확인 — `flutter --version`(3.41.9, 설치 확인됨), `flutter devices`(`Windows (desktop)`/`Chrome (web)`/`Edge (web)` 3개 감지, **연결된 디바이스 0개(`flutter devices` 기준), 미기동 AVD 1개(`Pixel_6`, `flutter emulators` 기준) 존재** — 이는 §5의 "컴파일 여부만" 범위 축소가 임의 축소가 아니라 실제 환경 제약에 따른 것임을 뒷받침한다(AVD가 있어도 기동되어 있지 않으므로 `flutter build apk --debug`의 컴파일-only 범위는 그대로 유효하다).

## 1. Pre-flight Checks

```powershell
cd D:\workspace\yoonsul_wait_order_handoff\catchmenu_app
flutter --version
flutter devices
Get-ChildItem build -ErrorAction SilentlyContinue
git status --short
```

기대/기록 대상:
- `flutter --version` 출력 그대로 기록(버전 드리프트 가능성 대비).
- `flutter devices`가 이번 Stage 2 조사 시점과 동일하게 연결된 디바이스 0개(AVD `Pixel_6`는 미기동 상태이므로 `flutter devices`에는 잡히지 않음, `flutter emulators`로만 확인됨)인지 재확인 — 만약 AVD가 기동되어 `flutter devices`에 잡히는 상태라면 §5의 "컴파일 여부만" 범위를 재검토해야 함(Open Item으로 승격).
- `Get-ChildItem build`로 `build/web`이 여전히 존재하지 않는 베이스라인 재확인(사전 실행 흔적이 이번 실행 전에 이미 있었는지 구분하기 위함).
- `git status --short`로 실행 전 작업 트리 상태를 기록해두어, 빌드 실행 후 diff와 비교할 기준선을 남긴다.

## 2. `flutter build web` — First-Ever Execution

```powershell
flutter pub get
flutter build web 2>&1 | Tee-Object -FilePath ..\docs\600000_implementation_lifecycle\600200_flutter_waiting_feature_implementation\600220_platform_deployment_strategy\_flutter_build_web_output.txt
echo "exit code: $LASTEXITCODE"
```

`flutter pub get`은 빌드의 정상적 선행 단계이며(의존성 잠금 확인/갱신), 소스 코드가 아닌 `pubspec.lock`만 갱신할 수 있다 — 이 자체는 기능 코드 변경이 아니므로 `600224_ChangeContract.md` §1의 "실질적 코드 변경 없음" 원칙과 상충하지 않는다.

**두 갈래 결과, 둘 다 유효한 기록 대상:**

### 2.1 성공 시

```powershell
Get-ChildItem build\web
Get-Content build\web\index.html -TotalCount 20
```

- `build/web/index.html`, `main.dart.js` (또는 `flutter.js` 로더 구조), `assets/`, `manifest.json` 등 표준 산출물 존재 확인.
- **실제 렌더링 확인** (둘 중 하나, 둘 다 하면 더 좋음):
  - (a) `flutter run -d chrome` — Chrome이 `flutter devices`에서 확인된 디바이스이므로 직접 디버그 세션으로 실행, 실제 화면이 뜨는지 눈으로 확인.
  - (b) 정적 산출물 서빙(Codex 제안, 명령 블록으로 명시):
    ```powershell
    flutter build web
    Set-Location build\web
    python -m http.server 8080
    # browser: http://localhost:8080
    ```
    `http://localhost:8080`을 브라우저로 열어 확인. Claude Code가 직접 실행하는 경우 Browser 도구(`preview_start`/`navigate`)로 렌더링 스크린샷을 남긴다. (b)의 `flutter build web`은 §2 상단에서 이미 실행한 것과 동일 명령이지만, 이 블록만 따로 복사해 실행해도 되도록 자기완결적으로 남겨둔다.
- 콘솔/네트워크 에러(404, JS 예외 등) 유무도 함께 기록 — "페이지가 뜬다"와 "에러 없이 뜬다"는 다른 확인 항목이다.

### 2.2 실패 시

- `_flutter_build_web_output.txt`에 저장된 에러 메시지**전문을 그대로** 다음 문서(향후 워크패킷의 `Overview.md`/이 문서의 후속 기록)에 인용한다 — 요약하거나 의역하지 않는다.
- 원인 분류(다음 중 하나로, 근거와 함께):
  - **플랫폼 미지원 패키지**: 특정 dependency가 web 플랫폼을 지원하지 않는다는 에러(`flutter_secure_storage` 등 web 지원 이력이 복잡한 패키지가 유력 후보 — 이번 Stage 2 조사에서 `pubspec.yaml`을 읽고 확인한 사실이며, 실제로 이게 원인인지는 실행 후에만 알 수 있다).
  - **설정 누락**: `web/index.html`의 `base href`, `manifest.json` 등 web 스캐폴드 설정 문제.
  - **기타**: 위 두 범주에 속하지 않는 에러(Dart SDK 버전 불일치, 빌드 캐시 문제 등).
- **절대 하지 말 것**: 에러를 보고 즉석에서 `pubspec.yaml`/`lib/**`/`web/**`를 수정해 재시도하지 않는다. 이 TestPlan의 산출물은 "현재 상태에서의 빌드 가능 여부 사실"이지 "빌드를 되게 만드는 것"이 아니다 — 수정이 필요하다고 판단되면 그 자체를 Stage 1.5 롤백 신호로 기록하고 별도 변경건으로 분리한다(`600224_ChangeContract.md` §4).

## 2.5 Android Toolchain 상태 (§3 실행 전 사전 확인)

- **Android SDK 설치 확인됨** — 경로 `C:\Users\charl\AppData\Local\Android\Sdk\`, `platform-tools\adb.exe`와 `cmdline-tools\latest\bin\sdkmanager.bat` 실행파일 존재를 이번 턴 직접 확인.
- **`flutter doctor -v` 판정 — 이력이 엇갈림, 둘 다 기록**:
  - 이전 세션 시도: hang으로 판정 미확인(완료되지 않음).
  - **이번 턴 재시도(25초 bounded timeout)에서는 hang 없이 정상 완료됨** — `[√] Android toolchain - develop for Android devices (Android SDK version 36.1.0)`, `All Android licenses accepted.`, `• No issues found!`, exit code 0. Java는 Android Studio 번들 JDK(`C:\Program Files\Android\Android Studio\jbr\bin\java`, OpenJDK 21.0.10) 사용 중.
  - 두 결과가 상충하므로 원인을 단정하지 않는다(최초 실행 시 백그라운드 다운로드/분석으로 시간이 오래 걸려 hang처럼 보였을 가능성, 또는 실행 도구/셸 차이 가능성 — 확정 근거 없음).
- **§3 실행 시 지침**: `flutter doctor -v`(또는 `flutter build apk --debug` 자체)가 hang/fail하면 **"toolchain 확인 실패"로 기록**하고, 이것이 **앱 코드 자체의 실패가 아님을 명확히 구분해서 보고**할 것 — §2.2와 동일하게 원인 규명 없이 임의로 우회/재시도 반복하지 않는다. 이번 턴 재확인 결과(정상 완료)가 있다고 해서 §4/§3에서 다시 hang이 발생하지 않으리라고 단정하지 않는다.

## 3. `flutter build apk --debug` — 컴파일 여부만 (완전한 배포 테스트 아님)

```powershell
flutter build apk --debug 2>&1 | Tee-Object -FilePath ..\docs\600000_implementation_lifecycle\600200_flutter_waiting_feature_implementation\600220_platform_deployment_strategy\_flutter_build_apk_debug_output.txt
echo "exit code: $LASTEXITCODE"
Get-ChildItem build\app\outputs\flutter-apk -ErrorAction SilentlyContinue
```

**범위를 명확히 좁힌다**: `flutter devices`에서 확인했듯 이번 환경에는 Android 디바이스/에뮬레이터가 연결되어 있지 않다 — 따라서 이 테스트는 **"컴파일이 에러 없이 끝나는지"만** 확인하며, 다음은 확인하지 **않는다**:
- 실제 디바이스/에뮬레이터에 설치되는지
- 앱이 실제로 기동/렌더링되는지
- STAFF/KDS/DID 화면별 실제 동작

성공 시 `build/app/outputs/flutter-apk/app-debug.apk` 파일 존재만 확인한다. 실패 시 §2.2와 동일한 태도(에러 전문 기록, 원인 분류, 임의 수정 금지)를 적용한다.

## 4. Explicitly Out of Scope (이번 TestPlan에서 시도하지 않음)

- **iOS 빌드**: macOS 툴체인이 필요하며 이 Windows 환경에서는 원천적으로 시도 불가능 — "실패"가 아니라 "이 환경에서 검증 불가능"으로 별도 기록(Open Item).
- **macOS/Windows 데스크톱 빌드**: `600221_Overview.md`/`600222_Logic.md` 어느 곳에서도 데스크톱 배포가 확정 전략에 포함되지 않았으므로, `flutter devices`에 `Windows (desktop)`가 있다고 해서 이번 TestPlan 범위에 임의로 추가하지 않는다.
- **실제 디바이스/에뮬레이터 설치 테스트, MDM/사이드로드 배포 검증**: `600222_Logic.md` §4 Open Item 4(배포 방식 미확정)와 동일 사유로 범위 밖.
- **MINI_KIOSK 관련 어떤 빌드/설정도**: §0-3 Human 결정(MVP 범위 밖)에 따라 다루지 않는다.

## 5. Post-Run Boundary / Regression Check

```powershell
git status --short
git diff --stat -- catchmenu_app/lib
```

기대 결과:
- `catchmenu_app/lib/**` 전체가 diff 0건 — 빌드 명령은 소스를 읽기만 하며 쓰지 않는다.
- 변경이 생겨도 되는 파일: `catchmenu_app/build/**`(신규 산출물, 대부분 `.gitignore` 대상일 가능성 높음 — 실제 추적 여부 이번 실행 후 확인), `catchmenu_app/pubspec.lock`(`flutter pub get`으로 갱신 가능, 기능 코드 아님), `catchmenu_app/.dart_tool/**`(빌드 캐시).
- 그 외 파일(특히 `lib/features/**`, `lib/app/**`, `lib/core/**`, `lib/shared/**`, `lib/main.dart`)에 diff가 있다면 이 TestPlan/ChangeContract의 경계를 벗어난 것이므로 즉시 중단하고 원인을 규명한다.

## 6. Open Items (→ `600224_ChangeContract.md`로 이월)

전부 `600222_Logic.md` §4에서 그대로 이월 — 이 TestPlan 작성 과정에서 새로 발견된 항목 없음:

1. STAFF_APP/KDS_DISPLAY/DID_DISPLAY 코드베이스 분리 방식(같은 바이너리 vs flavor vs 별도 entry point) 미확정.
2. Channel 1(웹, 900110) / Channel 2(`catchmenu_app`, 900120) 관계 — (a) 동일 코드베이스 멀티타겟 vs (b) 원래부터 별개, 미확정.
3. MINI_KIOSK 플랫폼 충돌(`900161` Flutter Web vs `900171` Android/Windows) — 범위 밖, 기록만.
4. STAFF/KDS/DID 실제 배포 방식(MDM/사이드로드/Play Store 비공개 배포 등) 미확정.
5. `flutter build web` 실제 실행 결과 — 이 TestPlan 자체가 다루는 항목이지만, 실행이 Stage 2(이번 턴)가 아니라 Stage 4/5로 이월되므로 "미실행" 상태 자체도 Open Item으로 유지.

## 7. Additional Note — 빌드 실패가 이번 배치를 blocking하는지 여부

`flutter build web` 또는 `flutter build apk --debug`가 실패하더라도, 그 자체는 이 TestPlan/ChangeContract를 "REJECT"로 만들지 않는다 — 이 워크패킷의 목적이 애초에 "현재 상태의 사실 확인"이기 때문이다. 실패는 Stage 6 Audit에서 "정직하게 기록된 사실"로 ACCEPT될 수 있다(단, 그 실패를 원인 규명 없이 방치하거나 임의로 우회하면 그건 ACCEPT 대상이 아니다).


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600224_ChangeContract.md] =====
# 600224_ChangeContract.md

Status: Draft — requires Stage 3 Human approval before binding
Lifecycle: ChangeContract
Stage: 2 (Claude role)
Last Updated: 2026-07-13
CHANGE_ID: `platform_deployment_strategy`

## 1. Allowed Actions (실질적 "코드 변경 없음" — 이번 change의 성격)

이번 change의 목적은 "빌드 가능 여부 확인"이지 기능 구현이 아니다 — 따라서 소스 코드 Allowed Files는 없음. 다음만 허용된다:

| 동작 | 허용 범위 |
|---|---|
| `flutter pub get` | `catchmenu_app/pubspec.lock` 갱신만 허용(의존성 잠금 파일, 기능 코드 아님). |
| `flutter build web` | `catchmenu_app/build/web/**` 생성만 — 빌드 산출물, 소스 아님. |
| `flutter build apk --debug` | `catchmenu_app/build/app/outputs/flutter-apk/**` 생성만 — 빌드 산출물, 소스 아님. |
| `600223_TestPlan.md`의 출력 로그 파일(`_flutter_build_web_output.txt`, `_flutter_build_apk_debug_output.txt`) | `600220_platform_deployment_strategy/` 폴더 안에 생성 허용 — 실행 기록 보존 목적. |
| `catchmenu_app/.dart_tool/**` | 빌드 실행 시 자동 생성/갱신되는 Dart/Flutter 툴 캐시 — 소스 아님, 생성/갱신 허용. |
| `catchmenu_app/.flutter-plugins-dependencies` | `flutter pub get`/빌드 시 자동 생성/갱신되는 플러그인 의존성 메타파일 — 소스 아님, 생성/갱신 허용. |
| `catchmenu_app/android/local.properties` | Android 빌드 시 로컬 SDK 경로 등을 기록하는 자동 생성 파일(머신별로 다름, 커밋 대상 아님) — 생성/갱신 허용. |

**`catchmenu_app/pubspec.lock` 관련 — 혼동 방지 문구**: 위 §1 표에서 `pubspec.lock` 갱신을 "허용"이라고 적었지만, 이 파일은 애초에 루트 `.gitignore`의 `*.lock` 패턴(L47)에 걸려 **git 추적 대상이 아니다**(`git check-ignore -v catchmenu_app/pubspec.lock` → `.gitignore:47:*.lock`으로 이번 턴 직접 재확인). 즉 이 파일의 변경은 허용/금지 판단 이전에 애초에 `git status`에 잡히지 않는다 — §5(Post-Run Boundary Check)에서 "변경돼도 되는 파일" 목록에 넣는 것은 안전을 위한 명시일 뿐, 실질적으로는 이 파일에 대해 boundary 위반이라는 개념 자체가 성립하지 않는다.

**빌드 에러 수정은 이 ChangeContract의 범위가 아니다.** `600223_TestPlan.md` 실행 중 에러가 발견되어 `pubspec.yaml`/`lib/**`/`web/**`/`android/**` 등의 실제 수정이 필요하다고 판단되면, 그 수정은 이 ChangeContract 하에서 진행하지 않는다 — Open Item으로 기록하고 별도의 새 Stage 1.5/2/3 사이클(새 ChangeContract)로 분리한다.

## 2. Explicitly Forbidden Files

- `catchmenu_app/lib/features/**` (`waiting/`, `kds/`, `payment/`, `staff/` 전부) — 기존 기능 코드, 이번 change와 무관.
- `catchmenu_app/lib/app/**` (라우터 등), `catchmenu_app/lib/core/**`, `catchmenu_app/lib/shared/**`, `catchmenu_app/lib/main.dart` — 기존 앱 골격 코드.
- `catchmenu_app/android/**`, `catchmenu_app/ios/**`, `catchmenu_app/web/**`, `catchmenu_app/linux/**`, `catchmenu_app/macos/**`, `catchmenu_app/windows/**`의 **설정 파일**(빌드 명령이 자동 생성하는 `build/` 하위 산출물은 예외) — 이번 change는 "현재 설정 그대로" 빌드가 되는지만 확인하며, 설정을 고쳐서 되게 만드는 것이 아니다.
- `catchmenu_app/pubspec.yaml` — 의존성 추가/변경 금지(`pubspec.lock` 갱신은 §1에서 별도 허용).
- `sql/migrations/**`, `docs/600000_implementation_lifecycle/` 내 이 워크패킷(`600220`) 외 다른 폴더 전체 — 무관, 편집 금지.
- `900161_Logic_...md`, `900171_Policy_...md`, `900110_...md`, `900120_...md`, `604101_...md` — `600221_Overview.md`/`600222_Logic.md`에서 인용만 했을 뿐, 이번 change에서 수정하지 않는다(문서 간 충돌은 Open Item으로만 유지, §3).

## 3. Open Items (전부 `600222_Logic.md` §4 / `600223_TestPlan.md` §6에서 이월, 재논의 금지)

1. **STAFF_APP/KDS_DISPLAY/DID_DISPLAY 코드베이스 분리 방식** — 같은 `catchmenu_app` 바이너리 안에서 라우트로만 구분할지, Flutter flavor로 분리할지, 별도 entry point(`main_staff.dart` 등)로 분리할지 미확정(`604101` §8.2 "Same binary or flavor TBD"가 이미 미결로 남긴 것과 동일 질문). 이번 change는 해소하지 않는다.
2. **Channel 1(`900110`, 웹, 무설치/익명)과 Channel 2(`900120`, `catchmenu_app`, 네이티브/OTP/멤버십)의 관계** — (a) `catchmenu_app` 하나의 코드베이스를 웹으로도 빌드해 로그인/멤버십 기능을 웹에서 제공하는 것인지, (b) Channel 1/2가 원래 설계대로 계속 별개인지 미확정. Stage 3 확정 필요.
3. **MINI_KIOSK 플랫폼 충돌** — `900161`(Flutter Web) vs `900171`(Android/Windows). `600221_Overview.md` §0-3 Human 결정에 따라 MVP 범위 밖, 지금 해결하지 않는다.
4. **STAFF_APP/KDS_DISPLAY/DID_DISPLAY의 실제 배포 방식**(MDM, 사이드로드, Play Store 비공개 배포 등) — "Android 태블릿 우선"이라는 플랫폼만 확정됐을 뿐, 배포 방식은 별도 결정 필요.
5. **`flutter build web`/`flutter build apk --debug`의 실제 실행 결과** — 이 ChangeContract가 승인된 이후 Stage 4/5에서 처음 실행된다. 성공/실패 어느 쪽이든, 그 결과 자체가 이 workpacket의 핵심 산출물이다.

## 4. Required Constraint — "기록하되 고치지 않는다" (Stage 4/5 실행자 반드시 준수)

`600223_TestPlan.md` §2.2/§3에서 이미 명시했듯, 빌드 실패는 이 ChangeContract 위반이 아니다. 실행자가 실패를 보고 임의로 `pubspec.yaml`/소스를 고쳐서 재시도하는 것이 위반이다. 실패 시 유일하게 허용된 행동은: (a) 에러 전문 그대로 기록, (b) 원인 분류(플랫폼 미지원 패키지/설정 누락/기타), (c) Stage 1.5 롤백 신호로 취급하여 별도 변경건으로 분리 제안. 그 이상은 하지 않는다.

## 5. Human Boundary Approval (Pending — Stage 3, 미승인)

☑ Approved — proceed to Stage 4 (Codex implementation within the file boundary above) (승인일자: 2026-07-11)
☐ Approved with modifications — see notes: _______________
☐ Not approved — blocked pending: _______________

이 섹션의 체크박스가 Human에 의해 명시적으로 체크되기 전까지, `flutter build web`/`flutter build apk --debug`를 포함한 어떤 명령도 이 ChangeContract 하에서 실행되지 않는다.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600225_Module.md] =====
# 600225_Module.md

Status: Implemented
Lifecycle: Module
Stage: 4
Owner: Human (direct execution)
Date: 2026-07-13

## Summary

Executed `600223_TestPlan.md` §2 (`flutter build web`) for the first time in this session's history, per the approved `600224_ChangeContract.md`. No source code was changed — this is a build-execution-and-record change, not a feature implementation (`600224_ChangeContract.md` §1).

| Action | Result |
|---|---|
| `flutter build web` | **Success** — `√ Built build\web`, exit code 0. First-ever execution this session; `600222_Logic.md` §3.1's "미검증 사실" (build/web absent, never run) is now resolved with a positive result. |
| `catchmenu_app/build/web/**` artifacts | Confirmed complete: `index.html`, `flutter.js`, `flutter_bootstrap.js`, `flutter_service_worker.js`, `manifest.json`, `favicon.png`, `icons/`, `assets/`, `canvaskit/`, `version.json`. `main.dart.js` = 2,647,711 bytes (not 0/truncated — a real compiled bundle). |
| Boundary | `catchmenu_app/lib/**` diff: 0 (confirmed via `git status --short`/`git diff --stat`). Only `catchmenu_app/build/**` (gitignored, `catchmenu_app/.gitignore` L33 `/build/`) was produced. |

## WASM Dry-Run Warning — Not Applicable to This (Non-WASM) Build

`flutter build web`'s output includes a `Wasm dry run findings` block:

```
Found incompatibilities with WebAssembly.
package:flutter_secure_storage_web/flutter_secure_storage_web.dart 5:1 - dart:html unsupported (0)
package:flutter_secure_storage_web/flutter_secure_storage_web.dart 6:1 - dart:js_util unsupported (15)
package:flutter_secure_storage_web/src/subtle.dart 21:1 - dart:html unsupported (0)
package:flutter_secure_storage_web/src/subtle.dart 22:1 - dart:js_util unsupported (15)
package:flutter_secure_storage_web/src/subtle.dart 26:1 - package:js/js.dart unsupported (14)
Consider addressing these issues to enable wasm builds. ...
Use --no-wasm-dry-run to disable these warnings.
```

This is an advisory-only check that Flutter's tooling runs by default alongside every `flutter build web` invocation, regardless of which compile target (JS vs WASM) is actually being produced — it does not gate or fail the build. Confirmed empirically: the build completed with exit code 0 and produced a complete `build/web/` despite this warning block, because the actual compile target here is the default JS target, not `--wasm`. The warning is real and correctly attributable to `flutter_secure_storage_web`'s use of `dart:html`/`dart:js_util`/`package:js`, none of which are supported under `dart2wasm` — but it has zero effect on the JS build this change actually produced.

**Open Item**: if this project ever migrates to a WASM web build target (`flutter build web --wasm`) in the future, `flutter_secure_storage_web`'s incompatibility would become a real blocker at that time and would need to be addressed (e.g., package upgrade, or a WASM-compatible secure-storage alternative for web). Not relevant to the current JS-target build; carried to `600227_Audit.md` Open Items.

## Boundary Notes

- No `lib/**`, `pubspec.yaml`, or platform config files were modified — only `flutter build web` was run, as authorized.
- `flutter build apk --debug` (`600223_TestPlan.md` §3) was **not** executed this turn — web build verification was the only action taken. See `600227_Audit.md` Open Items.
- No git commit was performed.


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600226_Verification.md] =====
# 600226_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Human (build execution) + Claude Code (independent browser/static/analyze verification)
Date: 2026-07-13

## Verification Result

Final result: PASS (3 independent confirmation methods, all in agreement).

## 1. Human Direct Execution

`flutter build web` run directly by Human, per `600223_TestPlan.md` §2. Result: success, `build/web/` produced, `_BootScreen`'s "초기화 실패" (initialization failed — `SUPABASE_URL`/`SUPABASE_ANON_KEY` not injected via `--dart-define`) screen observed when serving the output — this is the designed, correct behavior for a build with no Supabase config injected, not a defect.

## 2. Claude Code Independent Browser Verification (`600223_TestPlan.md` §2.1(b) equivalent)

Per `600223_TestPlan.md` §2.1(b), served `build/web/` via `python -m http.server 8080` and connected directly with the session's Browser tool (`mcp__Claude_Browser__*`) — not relying on Human's or Codex's description of what the page shows.

| Check | Method | Result |
|---|---|---|
| Actual rendering | `computer{action:"screenshot"}` | **Tool failure, transparently recorded**: timed out (30s) on every direct `screenshot` attempt this session — a limitation of the screenshot action in this Browser pane context, not a symptom of the page being stuck. Confirmed not page-related because `computer{action:"zoom"}` (which this tool falls back to a full-frame capture for) succeeded and returned the actual rendered page: the `_BootScreen` "초기화 실패" message with the exact `SUPABASE_URL`/`SUPABASE_ANON_KEY` guidance text, matching Human's description exactly. |
| Console messages | `read_console_messages` (no filter, then `onlyErrors: true`) | No filter: 2 `[debug] Injecting <script> tag. Using callback.` lines only (Flutter's own bootstrap loader debug output). `onlyErrors: true`: **"No console logs."** — zero error/warning-level entries. |
| Network requests | `read_network_requests` | 4 requests captured (`main.dart.js`, `FontManifest.json`, `MaterialIcons-Regular.otf`, `CupertinoIcons.ttf`), all `200 OK`. No 404s or failures. |

**Screenshot tool failure — full transparency**: the `screenshot` action itself never succeeded in this session against this page, despite multiple retries and waits. This was not silently worked around or hidden — it is recorded here as a genuine tool limitation encountered, with `zoom`'s full-frame fallback used and explicitly noted as the actual source of the visual confirmation, not `screenshot`.

## 3. Static File Inspection (`600223_TestPlan.md` §2.1(b) supplement, independently reproduced)

| Check | Result |
|---|---|
| `index.html` structure | `<base href="/">` correctly resolved (not left as an unreplaced template placeholder); `<script src="flutter_bootstrap.js" async>` present. |
| `main.dart.js` size | 2,647,711 bytes — not 0 or anomalously small; consistent with a real compiled bundle. |
| Required files present | `flutter.js`, `flutter_bootstrap.js`, `flutter_service_worker.js`, `manifest.json`, `favicon.png`, `icons/`, `assets/`, `canvaskit/`, `version.json` — all present. |
| CORS/base-href conflict with `python -m http.server` | None — `base href="/"` matches the serving root exactly; confirmed empirically via the 4 successful 200 OK network requests above (not merely inferred from the HTML). |

## 4. `flutter analyze` Re-Run

```
Analyzing catchmenu_app...
info - 'anonKey' is deprecated and shouldn't be used. Use publishableKey instead. ... - lib\core\supabase\supabase_client.dart:32:7 - deprecated_member_use
1 issue found. (ran in 2.8s)
```

Same single pre-existing issue as before this session's build verification (`anonKey` deprecated) — no new warnings or errors introduced by the build.

## Scenario Summary

| Scenario | Human | Claude Code (independent) |
|---|---|---|
| `flutter build web` succeeds | PASS | — |
| Actual page renders correctly (`_BootScreen` as designed) | reported | PASS — visually confirmed via `zoom` fallback after `screenshot` tool failure (transparently recorded) |
| Console clean of unexpected errors/warnings | — | PASS — 0 error/warning-level entries |
| Network requests all succeed | — | PASS — 4/4 `200 OK` |
| Static build artifacts complete and correctly sized | — | PASS |
| `flutter analyze` — no new issues | — | PASS — same 1 pre-existing issue only |
| WASM dry-run warning does not block this (JS-target) build | — | PASS — build succeeded despite the warning; confirmed advisory-only |


===== BEGIN [docs/600000_implementation_lifecycle/600200_flutter_waiting_feature_implementation/600220_platform_deployment_strategy/600227_Audit.md] =====
# 600227_Audit.md

Status: Audited
Lifecycle: Audit
Stage: 6
Owner: Claude
Date: 2026-07-13

## Final Audit Decision

**ACCEPT (이번 범위 한정 — `flutter build web` 검증에 한함).** Android APK 컴파일 테스트(`600223_TestPlan.md` §3)는 이번 세션에서 실행되지 않았으며, 별도 후속 확인이 필요하다(Open Items).

## Audit Criteria

| Criterion | Result | Evidence |
|---|---|---|
| Implementation stayed inside the approved `600224_ChangeContract.md` boundary | PASS | `600225_Module.md`: only `flutter build web` executed; `catchmenu_app/lib/**` diff 0; only `catchmenu_app/build/**`(gitignored) produced. |
| `flutter build web` first-ever execution result recorded honestly (`600222_Logic.md` §4 Item 5 / `600223_TestPlan.md` §6 Item 5) | PASS | Result: success. `600222_Logic.md`'s "미검증 사실" status is now resolved with a positive, evidenced outcome — not assumed, not asserted without a real run. |
| Actual rendering confirmed, not merely assumed from build exit code | PASS | `600226_Verification.md` §2 — Claude Code independently connected via the Browser tool and visually confirmed the `_BootScreen` "초기화 실패" screen renders exactly as designed. |
| Console/network clean of unexpected errors | PASS | 0 console error/warning entries beyond Flutter's own bootstrap debug log; 4/4 network requests `200 OK`. |
| Static artifact integrity | PASS | `main.dart.js` correctly sized (2.6MB, not 0/truncated); all required `build/web/` files present; `base href` correctly resolved. |
| `flutter analyze` shows no new regressions | PASS | Same single pre-existing `anonKey` deprecation notice, no new issues. |
| WASM dry-run warning correctly scoped as non-blocking for this build | PASS | `600225_Module.md` — warning is advisory-only for the default JS target; build succeeded with exit code 0 despite it. |
| Tool-failure transparency (screenshot timeout) | PASS | `600226_Verification.md` §2 explicitly records the `screenshot` action's repeated timeout and the `zoom`-fallback workaround, rather than silently omitting the failure or claiming `screenshot` itself worked. |

## Findings

1. `flutter build web` succeeds on the current, unmodified `catchmenu_app` codebase — closing `600222_Logic.md` §4 Item 5, which had explicitly left this as an unexecuted, unverified fact pending this exact test.
2. Three independent confirmation methods (Human's direct run, Claude Code's live browser connection, static file inspection) converge on the same conclusion with no contradicting evidence — a stronger basis than any single method alone.
3. The WASM dry-run warning naming `flutter_secure_storage_web`'s `dart:html`/`dart:js_util`/`package:js` usage is real and correctly attributed, but does not affect the JS-target build this workpacket verifies. It is a legitimate forward-looking concern only if a WASM build target is adopted later.
4. Android APK compilation (`600223_TestPlan.md` §3) remains untested this session — this Audit's ACCEPT is explicitly scoped to the web build only, matching the precedent set in `600423_Audit.md` (scoped ACCEPT with an explicit blocking-scope caveat) rather than treating partial TestPlan execution as full closure.

## Open Items Carried Forward

(a) **`flutter_secure_storage_web` WASM incompatibility (`dart:html`/`dart:js_util`/`package:js` unsupported under `dart2wasm`) — newly discovered this workpacket.** No impact on the current JS-target build. Relevant only if/when this project adopts `flutter build web --wasm`; candidate for re-evaluation at that time (package upgrade or a WASM-compatible secure-storage alternative for web).

(b) **`flutter build apk --debug` (`600223_TestPlan.md` §3) was not executed this session.** Only the web build path was verified. A separate follow-up must run and record the Android compile-only test before this workpacket's TestPlan can be considered fully closed.

(c) **MINI_KIOSK platform conflict (`900161` Flutter Web vs `900171` Android/Windows)** — carried forward from `600221_Overview.md` §0-3 / `600224_ChangeContract.md` §3 Item 3, MVP 범위 밖, still unresolved by Human decision.

(d) **Channel 1(`900110`)/Channel 2(`900120`, `catchmenu_app`) relationship and STAFF/KDS/DID flavor-vs-entry-point split** — carried forward from `600224_ChangeContract.md` §3 Items 1-2, both still undecided, requiring Stage 3-level confirmation in a future workpacket.

## Residual Notes

- This audit does not approve any other uncommitted change in the working tree.
- This audit does not extend to Android, iOS, macOS, or Windows desktop build verification — web only.
- No git commit was performed as part of this audit.

## Conclusion

`flutter build web`'s first-ever execution in this project succeeds, and its output renders, behaves, and logs exactly as designed — independently confirmed via live browser connection, static artifact inspection, and static analysis, with no contradicting evidence across the three methods. The WASM dry-run warning is real but immaterial to this (JS-target) build. This ACCEPT is scoped to the web build path only; the Android compile-only test from the same TestPlan remains open and must be completed in a follow-up before the full `600220` TestPlan can be considered closed.

Final status: **ACCEPT (web build scope only).**
