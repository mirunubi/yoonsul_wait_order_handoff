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
