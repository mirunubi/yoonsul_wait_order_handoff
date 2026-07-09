# 604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md

Status: Implemented  
Lifecycle: Module  
Owner: TBD  
Last Updated: 2026-07-01
Gate Classification: Pre-Gate Foundation Bootstrap
Runtime Scope Authorization: Not Granted
Allowed Baseline: Yes
Future Scope Precedent: No

---

## 0. Purpose

### Gate Note

This module is accepted only as a one-time Foundation scaffold baseline.
It must not be used as precedent for implementing runtime scopes before impact scope,
architecture, change contract, human approval, local verification, and audit.

This module records the **FOUNDATION scaffold** implementation of the Catch Menu
Flutter MVP client, reconciled against the reinforced architecture/logic contracts
`604101` and `604102`. It is not a Scope (A~E) implementation. It establishes the
client-side skeleton that will enforce INV-001~006 in later Scopes.

Upstream references:

| Document | Role |
| --- | --- |
| `604101_Overview_Flutter_MVP_Project_Structure.md` | Architecture / folder boundary contract (read-only) |
| `604102_Logic_Flutter_MVP_Core_Implementation.md` | Core runtime logic contract (RpcCaller, DROP-A~E, INV client rules) |
| `900102_ChangeContract_…` | Invariants, scopes, forbidden client actions |
| `900121_Logic_Channel_2_…` | Session lifecycle, DROP-A~E defense |
| `0136_create_dev_audit_log.sql` | `catchmenu_dev.write_audit_log()` contract |

Work living record: `catchmenu_app/impact_scope.md`

**Gate position (Overview §0.1, §2.1):** This scaffold is accepted **only as a
pre-gate Foundation bootstrap baseline**. It is **not** a precedent and does **not**
authorize Scope D/C/A/B/E runtime implementation. Any Scope code change still requires
the Controlled Implementation Gate (`impact_scope → overview/logic/test_plan/change_contract
→ implementation_approval.md → Codex → local gate → audit → human merge`).

Scope of this module: **FOUNDATION only.** No DB migration, no Edge Function,
no Scope A~E screen/repository, no auth/session/realtime runtime. Client toolkit only.

---

## 1. 구현한 파일 전체 목록 (경로 + 역할 + 주요 함수)

Project root: `catchmenu_app/` (created via `flutter create --org com.yoonsul --project-name catchmenu_app`)

| 파일 | 역할 | 주요 함수/심볼 |
| --- | --- | --- |
| `pubspec.yaml` | 의존성 선언 | supabase_flutter ^2.0.0, flutter_secure_storage ^9.0.0, shared_preferences ^2.2.0, go_router ^13.0.0, riverpod ^2.0.0, flutter_riverpod ^2.0.0, uuid ^4.0.0 (correlation_id 생성용) |
| `lib/core/constants/app_constants.dart` | 환경/스키마/파이프라인/금지 RPC 상수 | `appEnv`, `isDev/isProd`, `supabaseUrl/supabaseAnonKey`, `hasSupabaseConfig`, `schemaPublic/Pos/Payment/Common/Kds/Dev`, `pipeline*`, `forbiddenClientRpcs` |
| `lib/core/errors/app_error.dart` | 표준 에러 포맷 | `AppError` + `AppError.network/rpc/forbiddenClientCall/notInitialized/unknown`, 코드 상수 `codeNetwork/codeRpc/codeForbiddenClientCall/codeNotInitialized/codeUnknown`, `toJson()` |
| `lib/core/supabase/supabase_client.dart` | Supabase 초기화 & 전역 접근 | `SupabaseInit.ensureInitialized()`(멱등), `SupabaseInit.client`, `isInitialized` |
| `lib/core/supabase/rpc_caller.dart` | ★ 모든 RPC 공통 래퍼 (단일 게이트) | `RpcResult<T>`, `RpcCaller.call<T>()`, `RpcCaller._rpc()`, `RpcCaller._writeAudit()`, `rpcCallerProvider` |
| `lib/main.dart` | 앱 진입점 | `main()`(WidgetsFlutterBinding + Supabase init), `CatchMenuApp`, `_BootScreen` |
| `lib/features/waiting/README.md` | Scope A(대기) 매핑 | — |
| `lib/features/kds/README.md` | Scope C(KDS) 매핑 | — |
| `lib/features/payment/README.md` | Scope A(결제) 매핑 | — |
| `lib/features/staff/README.md` | Scope B(직원, 900102: waiting_admin) 매핑 | — |
| `lib/shared/widgets/.gitkeep`, `lib/shared/models/.gitkeep` | 공용 계층 placeholder | — |
| `test/widget_test.dart` | 부팅 스모크 테스트 | `부팅 화면 렌더 (초기화 실패 경로)` |
| `catchmenu_app/impact_scope.md` | 작업 영향 범위 선언 (living doc) | — |

이번 정합(alignment) 패스에서 변경된 심볼: `RpcCaller._writeAudit()` 의 audit params
맵 — `if (x != null) 'k': x` 두 항목을 null-aware element(`'k': ?x`)로 정리
(§11 참고). 동작·파라미터 계약 불변.

---

## 2. 핵심 구현 내용 (어떻게 했는지)

### 2.1 RpcCaller — 단일 RPC 진입점 (Logic §2)
- 앱의 모든 Supabase RPC 는 `RpcCaller.call()` 만 통과한다. `supabase.rpc()` 직접
  호출은 금지하고, `SupabaseInit` 은 초기화/접근만 노출한다. (Logic §1.1, §2.10)
- `call<T>(fnName, {schema, params, pipeline, module, flutterScreen, correlationId, injectCorrelationIdAs})`
  — Logic §2.2 public API 와 시그니처 동일.
  - **correlation_id 자동 생성** (uuid v4). 항상 `RpcResult.correlationId` 로 반환. (INV-006)
  - **schema 라우팅**: public 이면 `client.rpc`, 아니면 `client.schema(schema).rpc`.
    클라이언트 RPC 가 `catchmenu_pos`(register/seat/call), `catchmenu_payment`(confirm),
    `catchmenu_common`(integration) 등 다중 스키마에 분산. (Logic §2.6 표)
  - **표준 에러 정규화**: `PostgrestException` → `AppError.rpc`(pg_code/hint/details),
    그 외 → `AppError.network`. 성공/실패 모두 `RpcResult` 로 반환(throw 안 함). (Logic §2.3, §2.4)
- **dev audit 자동 기록**: `isDev` 일 때 매 호출을 `catchmenu_dev.write_audit_log()` 로
  남긴다(Logic §2.5 파라미터 계약과 동일). audit 실패는 조용히 삼켜 **주 흐름을 절대
  깨지 않는다.** prod 에서는 no-op(서버 ledger 가 INV-006 권위).
- `logSessionId` 로 한 앱 세션의 로그를 그룹화(uuid v4 기본).

### 2.2 INV-004 클라이언트 가드 (Logic §2.3, §6 INV-004)
- `AppConstants.forbiddenClientRpcs = {'release_kds_after_payment'}`.
- `RpcCaller.call()` 최상단에서 걸리면 즉시 `AppError.forbiddenClientCall` 반환 +
  `FORBIDDEN_CLIENT_CALL` audit 기록. 네트워크 요청 자체가 나가지 않는다(fail-closed, Logic §6.2).

### 2.3 환경변수 기반 부팅 (Logic §3.1)
- 비밀값은 소스에 없고 컴파일 타임 `--dart-define`(SUPABASE_URL/SUPABASE_ANON_KEY/APP_ENV).
- `main()` → `SupabaseInit.ensureInitialized()`; 설정 누락 시 `AppError.notInitialized`
  → `_BootScreen` 안내. `ProviderScope` 로 Riverpod 활성.

### 2.4 폴더 구조 (Overview §3, §3.1)
- `core/ + feature repository` 패턴 유지(서비스 계층 중복 없음), `waiting_admin`→`staff`.
  각 feature README 에 담당 Scope·허용 파일·관련 RPC·INV 금지사항 기록.
- Overview §3 의 planned 파일(`app/`, `core/session/`, `core/realtime/`, `features/{bootstrap,
  auth,did}` 등)은 **미구현**(승인 게이트 전 확장 금지, Overview §2.2 / Logic §10).

---

## 3. 테스트 실행 결과 (명령어 + 결과)

```bash
$ flutter --version
Flutter 3.41.9 • channel stable • Dart 3.11.5

$ flutter pub get
Changed 81 dependencies!        # supabase_flutter 2.15.2, uuid 4.5.3 포함

$ flutter analyze
1 issue found. (exit 0, blocking 아님)
  # info x1:
  #  - supabase_client.dart:32  anonKey deprecated  → §10 accepted warning 참조
  # error 0, warning 0
  # (직전 use_null_aware_elements info x2 는 이번 패스에서 정리됨)

$ flutter test
00:00 +1: All tests passed!      # 부팅 화면 렌더 (초기화 실패 경로)

# --- 문서 지정 검증 게이트 (Overview §11 / Logic §2.9) ---

$ grep -rn "release_kds_after_payment" lib/
  lib/core/constants/app_constants.dart:57   # 차단 상수 (forbiddenClientRpcs)
  lib/core/supabase/rpc_caller.dart:47       # 주석
  lib/features/kds/README.md:17              # 문서
  lib/features/waiting/README.md:19          # 문서
  # 실행 호출부(call site) 0건 → INV-004 만족 (Logic §2.9 기대와 일치)

$ grep -rn "\.rpc(" lib/
  lib/core/supabase/rpc_caller.dart:178,180,198   # 유일한 실행 Supabase RPC 호출부
  lib/core/supabase/rpc_caller.dart:44            # 주석
  lib/core/supabase/rpc_caller.dart:129           # AppError.rpc(...) 팩토리 (Supabase 호출 아님)
  lib/core/errors/app_error.dart:49               # factory AppError.rpc(...) 정의 (호출 아님)
  lib/core/supabase/supabase_client.dart:11       # 주석
  # 실행 Supabase RPC 호출은 rpc_caller.dart 3곳뿐 → 게이트 의도 충족.
  # AppError.rpc 는 Logic §2.3/§4.2 가 그 이름으로 명시한 에러 팩토리이므로 개명하지 않음.
```

Exit: analyze/test 모두 exit 0. Accepted warning 1건(anonKey, §10).

---

## 4. INV-001~006 준수 확인 (각 항목별 체크) — Logic §6 대응

| 불변식 | 이 스캐폴드에서의 상태 | 판정 |
| --- | --- | --- |
| **INV-001** 결제 없이 KDS COMMITTED 전환 불가 | 클라이언트에 release/commit 로직 없음. 서버(Scope D) 강제 대상. 위반 경로 없음 | ✅ N/A (경로 없음) |
| **INV-002** 착석만으로 KDS release 불가 | seat 클라이언트 로직 미구현. 위반 경로 없음 | ✅ N/A (경로 없음) |
| **INV-003** 호출만으로 KDS release 불가 | call 클라이언트 로직 미구현. 위반 경로 없음 | ✅ N/A (경로 없음) |
| **INV-004** 클라이언트 release 직접 호출 금지 | `forbiddenClientRpcs` + RpcCaller 가드로 **능동 차단**(fail-closed). grep 호출부 0건 | ✅ 강제됨 |
| **INV-005** 결제 이벤트 idempotent | 서버(Scope D) 책임. 클라이언트 결제 로직 미구현. `injectCorrelationIdAs`/correlation_id 로 후속 idempotency 지원 준비 | ✅ N/A (경로 없음) / 준비 |
| **INV-006** 모든 상태 전이 ledger 기록 | 상태 전이 클라이언트 로직 미구현. dev 계층 `write_audit_log()` 자동 기록 배선 완료(운영 ledger 는 서버) | ✅ 배선 완료 |

> Logic §2.1.1 Non-Negotiable rules 대비 현황: (1)직접 rpc 금지 ✅ (2)위젯의 PostgrestException
> import 없음 ✅ (3)에러 문자열 파싱으로 업무판단 없음 ✅ (4)release 직접호출 없음 ✅
> (5)서버 확인 없이 APPROVED/COMMITTED 로컬 마킹 없음 ✅ (6)모든 결과에 correlationId 노출 ✅
> (7)audit 실패가 흐름 안 깸 ✅ (8)prod 에서 catchmenu_dev 미기록 ✅
>
> 본 모듈은 상태전이/결제/KDS 런타임 미구현이라 INV-001/002/003/005 는 **위반 가능 경로 없음**.
> INV-004 만 클라이언트에서 능동 강제.

---

## 5. 알려진 리스크

1. **Exposed schemas 미확인** — `catchmenu_pos/payment/common/kds/dev` 가 Supabase
   PostgREST "Exposed schemas" 에 등록돼야 `.schema(...).rpc()` 동작. 미등록 시 첫 실제
   RPC 실패. (Overview §5.2 — Scope A 전 대시보드 확인 필수)
2. **anonKey deprecation** — §10 Accepted Warnings 로 이관(변경은 Logic §3.6 change-contract 필요).
3. **폴더 명명 open item** — Overview §3.1: `services` vs `core+repository`, `staff` vs
   `waiting_admin` 은 Scope B 착수 전 `impact_scope.md` 에서 확정.
4. **dev audit 의존** — `write_audit_log()` 는 dev 전용(0136). prod 전 `catchmenu_dev`
   DROP 시 RpcCaller 는 `isProd` 로 자동 no-op(안전)하나 배포 절차에서 확인.
5. **라우팅/세션/리얼타임 미구현** — go_router 의존성만 존재. `app/router.dart`,
   `core/session/*`(DROP-A/C), `core/realtime/*`(DROP-B), `payment_result_handler`(DROP-E) 는
   Overview §4.2 planned. Scope 승인 전 미구현.
6. **테스트 커버리지 갭** — 현재 `widget_test.dart` 뿐. `test/core/rpc_caller_test.dart`
   미존재 → §10 Deferred Hardening 참조. (Logic §2.9: feature Scope 는 widget_test 통과만으로
   검증완료 주장 불가)

---

## 6. 롤백 방법

이 모듈은 **신규 파일 추가 + 이번 패스의 null-aware 스타일 편집**만 있고 기존 DB/마이그레이션/
Edge Function 변경이 없다.

**옵션 A — 파일 삭제 / 편집 되돌리기 (미커밋 상태)**
```bash
# Flutter 프로젝트 전체 제거
rm -rf catchmenu_app/
# 이 Module 문서 제거
rm docs/600000_implementation_lifecycle/604000_workpackets/604100_flutter_mvp_foundation/604103_Module_Flutter_MVP_Foundation_Scaffold_Implementation.md
```

**옵션 B — git revert (커밋 이후)**
```bash
git log --oneline -- catchmenu_app/
git revert <commit_sha>
```

null-aware 편집만 되돌리려면 `rpc_caller.dart` 의 `_writeAudit` params 를
`if (flutterScreen != null) 'p_flutter_screen': flutterScreen,` 형태로 환원.
DB/마이그레이션/Edge Function 변경이 없으므로 서버 롤백 불필요.

---

## 7. 다음 Scope 준비사항

실행 순서(900102 §12 / Overview §7, 변경 금지): **D → C → A → B → E**

**Scope D (Server Runtime Guard) 착수 전 체크 (Controlled Implementation Gate):**
```text
[ ] impact_scope.md 에 승인 파일/금지 파일/RPC/테스트/롤백/증빙 기입
[ ] overview / logic / test_plan / change_contract / implementation_approval.md 작성·승인
[ ] Supabase Exposed schemas 등록 확인 (catchmenu_pos/payment/common/kds/dev)
[ ] SUPABASE_URL / SUPABASE_ANON_KEY 확보 (--dart-define)
[ ] 폴더 명명(services vs core, staff vs waiting_admin) 확정
[ ] 마이그레이션 번호: 현재 0139 존재 → 신규는 0140+ (900102 예시의 0136 은 이미
    0136_create_dev_audit_log.sql 로 점유됨. Scope D 착수 시 번호 재지정)
[ ] 900103 TestPlan 확인
```

Scope D 는 서버(SQL/Edge Function) 작업으로 본 Flutter 스캐폴드와 파일 경계가 분리된다
(Overview §3.2: `supabase/`,`sql/`,`functions/` 는 Scope D 승인 전 Flutter 작업 금지).
Scope C/A/B/E 는 각 `lib/features/*/` 아래에서 Repository → `RpcCaller.call()` 로 구현.

---

## 8. Contract Mapping (구현 ↔ 계약 조항)

| 구현 산출물 | 충족한 계약 조항 |
| --- | --- |
| `RpcCaller` 단일 게이트 | Overview §2(원칙 2), §5.3~5.4 / Logic §1.1, §2.1~2.7, §2.10 |
| correlation_id 자동생성·노출 | Logic §2.2, §6 INV-006 |
| INV-004 forbidden RPC 차단 | Overview §5.4 / Logic §2.3, §2.6, §6 INV-004, §6.2 |
| dev audit(write_audit_log) | Logic §2.5, §5.4 / 0136 SQL |
| AppError 정규화 + 코드셋 | Logic §2.3, §5.1 |
| SupabaseInit 부팅/설정가드 | Logic §3.1, §3.5 |
| schema 라우팅(public/named) | Overview §5.2 / Logic §2.6 |
| 폴더 경계(core/feature/shared) | Overview §3, §3.1, §3.2 |
| `--dart-define` 비밀 주입 | Overview §5.1 / Logic §3 |

---

## 9. Baseline Drift Result (Overview §4.4)

**결과: `MATCHES_BASELINE`** (구현된 Foundation 파일이 Overview/Logic 이 명시한 baseline
집합과 일치) **+ `DOC_ONLY_DRIFT`** (Overview §3/§4.2 가 명명한 planned 미래 파일들은 아직
미구현 — 예상된 상태, 승인 전 구현 금지).

`CODE_DRIFT` 없음, `SCOPE_DRIFT` 없음. 스캐폴드는 Scope A~E 런타임 동작을 포함하지 않음.

---

## 10. Accepted Warnings & Deferred Foundation-Hardening

### 10.1 Accepted analyzer warning (Logic §3.6)
| 항목 | 내용 |
| --- | --- |
| Warning | `anonKey` deprecated → `publishableKey` 권장 (supabase_flutter 2.15.2) |
| 위치 | `lib/core/supabase/supabase_client.dart:32` |
| 결정 | **Accepted (non-blocking).** 레거시 anon key 호환 유지. 변경은 Logic §3.6 change-contract 필요(SDK/키유형/PKCE·refresh·persist/마이그레이션 리스크/롤백 기재) |
| Owner / Date | Foundation / 2026-07-01 |
| 재검토 시점 | Scope A(OTP auth) 착수 시 |

### 10.2 Deferred hardening (별도 승인 게이트 필요, Logic §0.1)
```text
[ ] test/core/rpc_caller_test.dart — Logic §2.8/§2.9 의 7개 assertion
    (success/forbidden/postgrest error/network error/dev audit/correlation inject/schema routing)
[ ] mock PostgREST 실패 처리 테스트 (Logic §0.1)
[ ] dev audit 실패 삼킴 테스트 (Logic §0.1)
```
이 항목들은 승인된 Foundation-hardening 게이트 또는 Scope 게이트에서 추가한다. 현재
스캐폴드는 이를 미포함(정직히 gap 으로 기록). widget_test 통과만으로 검증완료 주장하지 않음.

---

## 11. Alignment Pass Change Log (2026-07-01)

강화판 `600001`/`600002` 계약에 맞춘 정합 작업 내역:

| 변경 | 사유 |
| --- | --- |
| `rpc_caller.dart` `_writeAudit` params 의 `if (x != null) 'k': x` 2건 → `'k': ?x` (null-aware element) | analyzer `use_null_aware_elements` info 제거. 동작/파라미터 계약 불변(Logic §2.5) |
| Module(본 문서) 전면 갱신 | 강화판 Overview/Logic 계약 필드(Contract Mapping, Drift Result, Accepted Warnings, Deferred Hardening, Gate position) 반영, 폴더 경로를 `600000_implementation_lifecycle/` 로 정정 |

정합 후 재검증: `flutter analyze` = info 1(anonKey, accepted), error/warning 0 · `flutter test`
통과 · grep 게이트 2종 기대치 충족. 코드 baseline 결론: **MATCHES_BASELINE**.
