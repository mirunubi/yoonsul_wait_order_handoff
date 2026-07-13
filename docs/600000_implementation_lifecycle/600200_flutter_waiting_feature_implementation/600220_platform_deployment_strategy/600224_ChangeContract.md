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
