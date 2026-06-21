# 900131_Logic_Channel_3_Whitelabel_App_Customer_Handoff_And_Session

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-21

---

## 0. Document Purpose

이 Logic 문서는 Channel 3 화이트라벨 캐치메뉴 앱의 세션 생성,
유지, 복구, 소멸 제어 로직과 Handoff 상태 전이를 정의한다.

Channel 2 (캐치메뉴 자체 앱) 와 기본 세션 구조는 동일하다.
추가 복잡성은 두 가지다.

```text
복잡성 1: tenant_id 격리
  가맹점 A 고객이 가맹점 B 데이터에 접근 불가
  앱 빌드 시 tenant_id 고정 또는 첫 실행 시 서버에서 수신

복잡성 2: 멤버십 이관 실패 처리
  FRANCHISE_LINK 모드에서
  외부 멤버십 API 이관 실패 시
  HOLD_INTERNAL 상태 유지 + 재시도 로직
```

Related Overview: 900130_Overview_Channel_3_Whitelabel_App_Customer_Handoff_And_Session.md

---

## 1. 세션 드롭 패턴 (Ch2 공통 + Ch3 추가)

Ch2 에서 정의한 DROP-A ~ DROP-E 는 그대로 적용된다.
900121 Logic 의 방어 로직을 그대로 사용한다.

Ch3 추가 드롭 패턴:

### DROP-F: tenant_id 혼입

```text
문제:
  화이트라벨 앱이 잘못된 tenant_id 로 API 호출
  다른 가맹점 데이터가 보임
  또는 내 가맹점 데이터가 안 보임

원인:
  앱 빌드 시 tenant_id 하드코딩 누락
  또는 개발/운영 환경 테넌트 혼재

방어 로직:

  방법 1 — 빌드 타임 고정 (권장):
    flutter build apk
      --dart-define=TENANT_ID=uuid-here
      --dart-define=BRAND_ID=uuid-here
      --dart-define=SUPABASE_URL=https://xxx.supabase.co
      --dart-define=SUPABASE_ANON_KEY=eyJxxx

    코드에서:
    const tenantId = String.fromEnvironment('TENANT_ID')
    const brandId  = String.fromEnvironment('BRAND_ID')

  방법 2 — 서버 수신:
    앱 첫 실행 시:
    GET /api/app-config?app_bundle_id=com.yoonsul.kimbap
    → 서버에서 tenant_id, brand_id 반환
    → SecureStorage 저장

  검증:
    모든 API 호출에 tenant_id 자동 포함
    RLS: tenant_id = current_tenant_id() 검증
    응답에 tenant_id 확인 로직 추가

  개발/운영 분리:
    dev 빌드:  TENANT_ID = 테스트 테넌트
    prod 빌드: TENANT_ID = 실제 가맹점 테넌트
    절대 혼재 금지
```

### DROP-G: 멤버십 이관 중 세션 분리

```text
문제:
  FRANCHISE_LINK 모드에서
  외부 멤버십 API 이관 요청이 진행 중
  고객이 앱을 닫거나 네트워크 끊김
  → 이관 상태 불명확
  → 고객이 포인트 받았는지 모름

방어 로직:

  이관 상태 조회:
    앱 재진입 시 HOLD_INTERNAL 상태 확인
    SELECT * FROM catchmenu_store.point_transfer_log
    WHERE customer_id = :customer_id
      AND transfer_status IN ('PENDING', 'RETRYING')

    PENDING 있으면 → "포인트 처리 중" UI 표시
    TRANSFERRED 완료 → "포인트 적립 완료" 표시
    FAILED → "포인트 적립에 문제가 발생했습니다.
               고객센터에 문의해 주세요" 표시

  이관 재시도:
    pg_cron POINT_TRANSFER_RETRY 가 자동 재시도
    앱에서는 상태만 표시
    수동 재시도 버튼 제공 (선택)
```

---

## 2. tenant_id 격리 세션 로직

```text
앱 초기화 순서:

  1. flutter_secure_storage 에서 tenant_id 읽기
  2. 없으면 빌드 환경변수에서 읽기
  3. 둘 다 없으면 → 앱 설정 오류 화면

  API 호출 시 tenant_id 자동 포함:
    모든 RPC 파라미터에 p_tenant_id 포함
    또는 Supabase RLS 에서 자동 처리

  RLS 보장:
    current_tenant_id() = JWT claims 의 tenant_id
    또는 앱에서 명시적으로 전달

  테스트 검증:
    가맹점 A 계정으로 가맹점 B 데이터 조회 시도
    → RLS 에 의해 빈 결과 반환 (에러 아님)
    → 앱에서 "해당 매장을 찾을 수 없습니다" 표시
```

---

## 3. 멤버십 모드별 세션 동작

### STANDALONE 모드

```text
Channel 2 와 완전히 동일.
캐치메뉴 원장에만 적립.
외부 이관 없음.

earn_points_after_order():
  membership_mode = 'STANDALONE'
  → point_ledger INSERT
  → Realtime customer_app:{store_id} 알림
  → FCM push
```

### FRANCHISE_LINK 모드

```text
외부 멤버십 시스템으로 포인트 이관.

earn_points_after_order() 흐름:
  1. point_ledger INSERT
     transfer_status = 'HOLD_INTERNAL'
  2. Edge Function 호출
     → 외부 멤버십 API 전송
  3. 성공:
     point_transfer_log: TRANSFERRED
     고객 앱 알림: "포인트 적립 완료"
  4. 실패:
     point_transfer_log: FAILED
     pg_cron 재시도 스케줄링
     고객 앱: "포인트 처리 중 (잠시 후 확인)"

고객 앱 표시:
  HOLD_INTERNAL → 스피너 또는 "처리 중"
  TRANSFERRED  → 포인트 금액 표시
  FAILED       → 고객센터 안내
  (FAILED 는 pg_cron 3회 재시도 후)
```

### HYBRID 모드

```text
일부는 캐치메뉴, 일부는 외부.
membership_configs.hybrid_rules 정책에 따라 분기.

예:
  기본 포인트 → 캐치메뉴 원장
  보너스 포인트 → 외부 이관
```

---

## 4. brand_id 기반 매장 격리

```text
화이트라벨 앱에서 brand_id 는 가맹점 식별자다.

매장 목록 조회:
  brand_id = 빌드 환경변수의 BRAND_ID
  → 해당 브랜드 소속 매장만 표시

메뉴 조회:
  본부 배포 메뉴 템플릿 기반
  또는 매장별 커스터마이징 허용 범위 내

정책 준수:
  run_compliance_check() 백그라운드 실행
  ALLERGEN_COMPLIANCE 위반 → 관리자 알림
  (고객 앱에는 표시 안 함)
```

---

## 5. Ch2 vs Ch3 세션 동작 비교

| 항목 | Ch2 캐치메뉴 앱 | Ch3 화이트라벨 앱 |
|---|---|---|
| tenant_id | 캐치메뉴 단일 | 가맹점별 고정 |
| brand_id | 단일 | 가맹점 브랜드 |
| 멤버십 | STAMP/POINT | FRANCHISE_LINK/STANDALONE |
| 포인트 이관 | 없음 | 외부 API 이관 가능 |
| 이관 실패 처리 | N/A | HOLD_INTERNAL + 재시도 |
| 메뉴 | 직접 관리 | 본부 템플릿 기반 |
| DROP 패턴 | A~E | A~G (F,G 추가) |
| 빌드 설정 | 단일 앱 | 가맹점별 빌드 파라미터 |

---

## 6. 화이트라벨 빌드 파이프라인

```text
가맹점별 앱 빌드 시:

필수 파라미터:
  TENANT_ID     가맹점 UUID
  BRAND_ID      브랜드 UUID
  SUPABASE_URL  Supabase 프로젝트 URL
  SUPABASE_ANON_KEY
  APP_NAME      "김밥나라" 등 브랜드명
  PRIMARY_COLOR 브랜드 색상 (#hex)
  LOGO_URL      브랜드 로고 URL
  MEMBERSHIP_MODE STANDALONE / FRANCHISE_LINK / HYBRID

빌드 검증:
  tenant_id 유효성 서버 확인
  brand_id 와 tenant_id 매핑 확인
  membership_mode 설정 확인
  dev/prod 환경 분리 확인
```

---

## 7. Phase 1 데이터 정합성 검증

```text
캐치메뉴 MVP (웹앱/자체앱) 데이터가
화이트라벨 앱에 정상 반영되는지 검증.

검증 시나리오:

  시나리오 A: 캐치메뉴 웹앱 → 화이트라벨 앱
    1. 웹앱으로 대기 등록 (tenant_id = 윤슬)
    2. 화이트라벨 앱 (윤슬앱) 에서 같은 대기 조회
    3. 동일 데이터 보이는가?

  시나리오 B: 세션 격리
    1. 가맹점 A 화이트라벨 앱 로그인
    2. 가맹점 B 데이터 조회 시도
    3. RLS 에 의해 빈 결과 반환 확인

  시나리오 C: 멤버십 이관
    1. FRANCHISE_LINK 모드 결제 완료
    2. 외부 API 이관 성공 확인
    3. point_transfer_log TRANSFERRED 확인

  시나리오 D: 이관 실패 복구
    1. 외부 API 강제 실패 처리
    2. HOLD_INTERNAL 상태 유지 확인
    3. pg_cron 재시도 후 TRANSFERRED 확인
```

---

## 8. Open Issues

```text
- [ ] 가맹점별 빌드 자동화 파이프라인 구축 방안
  현재: 수동 파라미터 지정
  향후: CI/CD 파이프라인 + 가맹점 설정 포털

- [ ] FRANCHISE_LINK 외부 API 표준 인터페이스
  현재: 가맹점별 커스텀 구현
  향후: 캐치메뉴 표준 이관 API 스펙 정의

- [ ] 이관 실패 고객 알림 정책
  현재: "처리 중" 표시
  향후: 실패 확정 시 고객 SMS 알림 여부 결정
```
