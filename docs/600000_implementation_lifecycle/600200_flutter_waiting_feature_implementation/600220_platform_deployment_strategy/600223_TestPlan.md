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
