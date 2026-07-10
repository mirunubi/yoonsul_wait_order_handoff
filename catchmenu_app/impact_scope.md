# impact_scope.md — CatchMenu Flutter MVP

> 이 파일은 **작업 단위별로 영향 범위(허용/금지 파일, 관련 RPC/테이블/채널)**를
> 선언한다. 900102 ChangeContract 의 "Required Codex Input Before Work" 요건을
> 각 작업 착수 전에 이 문서에서 충족한다.

Last Updated: 2026-07-01
Status: FOUNDATION (Scope 미착수)

---

## 0. 현재 작업: FOUNDATION — 프로젝트 스캐폴드

> Scope A~E 어디에도 속하지 않는 **기반 골격**. 서버/DB/결제/KDS 런타임 로직
> 미포함. INV-001~006 을 강제할 수 있는 클라이언트 토대만 만든다.

### 생성/수정한 파일

```text
catchmenu_app/                         (flutter create, org=com.yoonsul)
  pubspec.yaml                         supabase_flutter, flutter_secure_storage,
                                       shared_preferences, go_router, riverpod,
                                       flutter_riverpod, uuid 추가
  lib/main.dart                        ProviderScope + Supabase 초기화 + 부팅 화면
  lib/core/constants/app_constants.dart   환경/스키마/파이프라인/금지 RPC 상수
  lib/core/errors/app_error.dart          표준 에러 포맷
  lib/core/supabase/supabase_client.dart  Supabase 초기화 & 전역 접근
  lib/core/supabase/rpc_caller.dart       ★ 모든 RPC 공통 래퍼 (필수)
  lib/features/{waiting,kds,payment,staff}/README.md   Scope 매핑
  lib/shared/{widgets,models}/            placeholder
  test/widget_test.dart                부팅 스모크 테스트
```

### 이번 작업에서 **하지 않은** 것 (경계)

```text
- DB 마이그레이션 추가/수정 없음 (0001~0139 그대로)
- Supabase Edge Function 추가/수정 없음
- 어떤 Scope 화면/리포지토리도 구현하지 않음
- release_kds_after_payment() 등 서버 전용 RPC 미호출 (rpc_caller 가 차단)
- RLS 정책 변경 없음
```

### 불변식 강제 지점 (기반에 내장)

```text
INV-004  rpc_caller.dart : AppConstants.forbiddenClientRpcs 에 등록된
                           RPC(release_kds_after_payment) 직접 호출을 차단하고
                           FORBIDDEN_CLIENT_CALL 에러 + audit 기록.
INV-006  rpc_caller.dart : dev 환경에서 모든 호출을
                           catchmenu_dev.write_audit_log() 로 기록 (증빙).
공통     supabase_client.dart : supabase.rpc() 직접 호출 금지, RpcCaller 강제.
```

### 검증

```bash
flutter analyze          # info 1건(anonKey deprecation, accepted)만, warning/error 0
flutter test             # 부팅 스모크 통과
# INV-004: 클라이언트에 직접 release 호출이 없어야 함
grep -rn "release_kds_after_payment" lib/    # 기대: 차단 상수/주석/README 만, 실제 .rpc() 호출 0건
```

### 실행 (환경변수 주입)

```bash
flutter run \
  --dart-define=APP_ENV=dev \
  --dart-define=SUPABASE_URL=https://<project>.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon_key>
```

---

## 1. rpc_caller 사용 규약 (모든 후속 작업 공통)

```dart
final caller = ref.read(rpcCallerProvider);

final res = await caller.call<Map<String, dynamic>>(
  'register_waiting',
  schema: AppConstants.schemaPos,       // public 아니면 반드시 지정
  params: {'p_store_id': storeId, ...},
  pipeline: AppConstants.pipelineWaiting,
  module: 'waiting_repository',
  flutterScreen: 'waiting_register_screen',
);

if (res.isFailure) { /* res.error: AppError */ }
else { final data = res.data; }
```

- `supabase.rpc()` 직접 호출 금지. 반드시 `RpcCaller.call`.
- correlation_id 는 자동 생성되어 `res.correlationId` 및 audit 로그에 남는다.
- `catchmenu_dev` / non-public 스키마는 Supabase 프로젝트 **Exposed schemas**
  설정에 등록되어 있어야 호출된다. (확인 필요 항목)

---

## 2. Scope 실행 순서 (900102 §12 — 변경 금지)

```text
1순위  Scope D  Server Runtime Guard   supabase/migrations, functions   ← 미착수
2순위  Scope C  KDS HOLD/COMMITTED UI  lib/features/kds/
3순위  Scope A  고객 결제 handoff       lib/features/{waiting,payment}/
4순위  Scope B  직원 대기/착석          lib/features/staff/  (문서상 waiting_admin)
5순위  Scope E  DID 투영               lib/features/did/    (폴더 미생성)
```

각 Scope 착수 전, 아래 항목을 이 문서에 채운 뒤 승인받는다:
승인 Scope / 허용 파일 / 금지 파일 / 관련 테이블 / 관련 RPC·함수 /
관련 Realtime 채널 / 추가·수정 테스트 / 검증 명령어 / 롤백 지시.

---

## 3. 확인/조정 필요 (Open Items)

```text
[ ] 폴더 명명 차이: 900102 문서는 lib/services/supabase/, lib/features/waiting_admin/,
    lib/features/did/ 를 사용. 본 스캐폴드는 핸드오프 지시에 따라
    lib/core/supabase/, lib/features/staff/ 로 통합. Scope 착수 전 명명 확정 필요.
[ ] Supabase Exposed schemas 에 catchmenu_pos/payment/common/kds/dev 등록 여부 확인.
[ ] SUPABASE_URL / SUPABASE_ANON_KEY 값 확보 (--dart-define).
[ ] anonKey deprecation: 신규 publishable key 사용 여부 결정.
[ ] Scope E(DID) 폴더는 착수 시 생성.
```
