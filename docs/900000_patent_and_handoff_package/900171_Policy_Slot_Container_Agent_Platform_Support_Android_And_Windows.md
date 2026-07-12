# 900171_Policy_Slot_Container_Agent_Platform_Support_Android_And_Windows

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Policy 문서는 POS 동적 다중 서비스 슬롯 컨테이너 Agent 시스템이
Android 와 Windows 양 플랫폼에서 동작해야 하는 이유와
각 플랫폼별 구현 전략을 정의한다.

```text
설치 대상:
  POS 단말기    → Android (안드로이드 POS) 또는 Windows (PC POS)
  키오스크      → Android (안드로이드 키오스크) 또는 Windows (PC 키오스크)
  직원 태블릿  → Android
  DID 디스플레이 → Android

결론:
  Android + Windows 양쪽 모두 필요
  Flutter 단일 코드베이스로 양쪽 구현 가능
```

Related Overview:
  900164_Overview_POS_Dynamic_Multi_Service_Slot_Container_Agent_System.md
Related Logic:
  900165_Logic_POS_Dynamic_Multi_Service_Slot_Container_Agent_System.md

---

## 1. 설치 환경 분석

### 1.1 국내 POS 단말기 현황

```text
Android POS:
  PAX A920 / A930
  Sunmi T2 / V2s
  KIOSK Korea 안드로이드 POS
  카운터형 안드로이드 태블릿 POS
  → 점유율 증가 중

Windows POS:
  OKpos (Windows 기반)
  토스POS (Windows 기반)
  포스피아 / 아이포스 (Windows)
  레거시 PC POS (Windows 7/10/11)
  → 국내 대형 프랜차이즈 다수 사용

결론:
  OKpos/토스POS = Windows
  신규 소형 매장 = Android 증가
  양쪽 모두 지원 필수
```

### 1.2 키오스크 환경

```text
Android 키오스크:
  안드로이드 태블릿 (10~15인치)
  Kiosk Mode (앱 고정)
  SUNMI K2 / PAX 키오스크

Windows 키오스크:
  PC 기반 키오스크
  터치스크린 모니터 + 미니 PC
  프랜차이즈 대형 키오스크

결론:
  소형/스타트업 매장 = Android
  대형/프랜차이즈 = Windows 혼재
  둘 다 필요
```

---

## 2. Flutter 플랫폼 지원 전략

```text
Flutter 단일 코드베이스:
  Android → APK / AAB
  Windows → EXE / MSIX
  Web     → 브라우저 (키오스크 웹앱)

하나의 코드로 3개 플랫폼 커버:
  lib/
    features/
      slot_container/       ← 공통 로직
      slot_container_android/ ← Android 전용
      slot_container_windows/ ← Windows 전용
    platform/
      overlay_android.dart
      overlay_windows.dart
      overlay_web.dart
```

---

## 3. Android 구현 전략

### 3.1 System Overlay (POS 위에 올리기)

```text
권한: SYSTEM_ALERT_WINDOW
     (다른 앱 위에 표시)

구현:
  WindowManager.LayoutParams 사용
  POS 앱 위에 슬롯 컨테이너 레이어 추가
  POS 앱 종류 무관하게 동작

Android 버전별:
  Android 6.0+: Settings.canDrawOverlays() 확인
  Android 10+:  권한 요청 팝업 자동
  Android 13+:  권한 강화 → 설정 화면 유도

Flutter 패키지:
  flutter_overlay_window (pub.dev)
  또는 platform channel 직접 구현

장점:
  POS 앱 수정 없음
  모든 Android POS 에 설치 가능
  드래그로 위치 조절

단점:
  권한 요청 필요
  일부 보안 강화 기기에서 제한
```

### 3.2 Kiosk Mode (키오스크 전용)

```text
Android 키오스크:
  Device Owner Mode 또는 Kiosk Mode
  단일 앱 고정 실행

슬롯 컨테이너 적용:
  키오스크 앱 내부에 슬롯 컨테이너 내장
  Overlay 방식 아닌 내부 위젯으로
  화면 일부를 슬롯바로 할당

구현:
  Stack 위젯으로 키오스크 화면 위에
  SlotBarWidget 고정 배치
  이벤트 없으면 최소화 (탭으로 확장)
```

---

## 4. Windows 구현 전략

### 4.1 Windows Overlay

```text
Flutter Windows:
  win32 API 또는 flutter_acrylic 패키지
  Always-on-top 윈도우 생성
  POS 앱 위에 슬롯 컨테이너 윈도우 배치

구현:
  별도 Flutter Windows 앱으로 실행
  Transparent/Layered Window 사용
  POS 화면 우측에 슬롯바 고정

Windows API:
  SetWindowPos(HWND_TOPMOST)
  WS_EX_LAYERED / WS_EX_TRANSPARENT
  Mouse click-through 설정
  (슬롯 클릭만 받고 POS 클릭 통과)

Flutter 패키지:
  window_manager (pub.dev)
  flutter_acrylic (투명 효과)
```

### 4.2 Windows 시스템 트레이 통합

```text
슬롯 컨테이너를 시스템 트레이에도 등록:
  tray_manager 패키지
  트레이 아이콘 → 슬롯 상태 배지 표시
  알림 이벤트 → Windows 알림 팝업

Windows 알림:
  local_notifier 패키지
  배달앱 신규 주문 → Windows 토스트 알림
  소리 + 화면 팝업
```

### 4.3 Windows 자동 시작

```text
POS PC 부팅 시 자동 실행:
  Windows 레지스트리 등록
  HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run

또는:
  시작 프로그램 폴더에 바로가기
  installer 에서 자동 설정
```

---

## 5. 플랫폼별 기능 비교

| 기능 | Android | Windows |
|---|---|---|
| System Overlay | SYSTEM_ALERT_WINDOW | Always-on-top Window |
| 슬롯 위치 | 드래그 자유 | 우측 고정 또는 드래그 |
| 알림 | FCM + 로컬 알림 | Windows 토스트 알림 |
| 자동 시작 | 부팅 수신자 | 레지스트리 등록 |
| 키오스크 모드 | Device Owner | 전체화면 앱 |
| POS 앱 수정 | 불필요 | 불필요 |
| 업데이트 | Play Store 또는 직접 APK | MSIX 또는 직접 EXE |
| Realtime | Supabase 채널 | Supabase 채널 |
| 오프라인 | 로컬 큐 | 로컬 큐 |

---

## 6. 공통 코어 (플랫폼 무관)

```text
플랫폼 공통 로직:
  SlotContainerAgent (Dart)
  Realtime 구독 (Supabase Flutter SDK)
  슬롯 이벤트 처리
  배지 카운트 관리
  팝업 트리거
  감사 로그 (catchmenu_ledger)

플랫폼별 분기:
  if (Platform.isAndroid) → overlay_android.dart
  if (Platform.isWindows) → overlay_windows.dart

Flutter 조건부 임포트:
  import 'overlay_stub.dart'
    if (dart.library.io) 'overlay_native.dart'
```

---

## 7. 설치 패키지 구성

### 7.1 Android 패키지

```text
파일명: catchmenu_slot_agent.apk
        또는 catchmenu_slot_agent.aab

설치 방법:
  A. Google Play Store (향후)
  B. 직접 APK 배포 (MVP)
     설치 → 권한 승인
     (SYSTEM_ALERT_WINDOW, 알림, 인터넷)

최소 요구사항:
  Android 8.0 (API 26) 이상
  RAM 2GB 이상
  저장공간 100MB 이상
```

### 7.2 Windows 패키지

```text
파일명: CatchMenuSlotAgent_Setup.exe
        또는 CatchMenuSlotAgent.msix

설치 방법:
  A. MSIX 패키지 (Microsoft Store 향후)
  B. EXE 인스톨러 (MVP)
     설치 → 자동 시작 등록

최소 요구사항:
  Windows 10 버전 1903 이상
  Windows 11
  RAM 4GB 이상
  .NET Framework 4.8 또는 포함

OKpos/토스POS PC 호환:
  OKpos 운영 PC 에 별도 프로세스로 실행
  POS 앱 간섭 없음
  포트 충돌 없음 (Supabase WebSocket 사용)
```

---

## 8. 키오스크별 슬롯 배치 정책

```text
Android 키오스크:
  슬롯바 위치: 화면 하단 고정 (기본)
  크기: 화면 너비 100% x 60px
  이벤트 없음: 아이콘만 표시
  이벤트 있음: 위로 슬라이딩 팝업 (200px)
  주문 화면 침범 없음

Windows 키오스크:
  슬롯바 위치: 화면 우측 고정 (기본)
  크기: 60px x 화면 높이 100%
  이벤트 없음: 아이콘만 표시
  이벤트 있음: 좌측으로 슬라이딩 팝업 (300px)
  POS/키오스크 화면 침범 없음

공통 원칙:
  이벤트 없으면 화면 안 가림
  이벤트 있으면 최소 팝업만
  확인 후 즉시 원위치
  직원이 위치/크기 조절 가능
```

---

## 9. 오프라인 대응

```text
네트워크 끊김 시:
  로컬 SQLite 큐에 이벤트 임시 저장
  재연결 시 자동 동기화
  배달앱 주문 수신 실패 → 로컬 알림

Flutter 패키지:
  sqflite (Android/Windows SQLite)
  connectivity_plus (네트워크 감지)

오프라인 표시:
  슬롯바에 오프라인 배지 표시
  "네트워크 연결 확인 필요" 안내
```

---

## 10. 구현 우선순위

```text
Phase 1 (MVP):
  [ ] Flutter Android 슬롯 컨테이너 앱
      System Overlay 권한
      슬롯 D (캐치메뉴 운영OS) 우선
      Realtime 구독
      기본 팝업

  [ ] 동일 코드 Windows 빌드 확인
      window_manager 패키지
      Always-on-top 동작 확인

Phase 2:
  [ ] Windows 슬롯 컨테이너 완성
      시스템 트레이 통합
      Windows 알림
      자동 시작 등록
      OKpos/토스POS PC 테스트

  [ ] 슬롯 A (배달앱) Agent 추가

Phase 3:
  [ ] Android 키오스크 모드 통합
  [ ] Windows 키오스크 모드 통합
  [ ] 설치 패키지 자동화
  [ ] 원격 업데이트
```

---

## 11. 관련 문서

| 문서 | 역할 |
|---|---|
| 900164: Overview | 슬롯 컨테이너 전체 구조 |
| 900165: Logic | Agent 동작 로직 |
| 900171: 이 문서 | Android/Windows 플랫폼 정책 |
| 010620 SOP | 기술 운영 기준 |
