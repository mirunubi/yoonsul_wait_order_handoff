# 900176_Policy_CCP_Mini_HACCP_Food_Safety_Auto_Management

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-26

---

## 0. Document Purpose

이 Policy 문서는 윤슬OS 의 CCP 미니버전
(HACCP 경량화 자동 관리 시스템) 을 정의한다.

```text
목표:
  중소 F&B 매장이 현실적으로 적용 가능한
  디지털 HACCP 자동화 시스템

기존 HACCP 의 문제:
  종이 체크리스트 / 수동 기록
  전담 인력 필요
  사후 감사 중심
  중소 매장 적용 어려움

윤슬OS CCP 미니버전:
  KDS + 운영 이벤트 자동 연동
  실시간 모니터링
  AI 이상 감지
  감사 원장 자동 생성
  소규모 매장도 적용 가능
```

---

## 1. HACCP vs CCP 미니버전

```text
HACCP (풀버전):
  7원칙 12절차 전체 적용
  전문 컨설턴트 필요
  연 수백만원 비용
  대형 식품 제조업체 중심

CCP 미니버전 (우리):
  핵심 관리점만 디지털화
  자동 기록 / AI 감지
  월 SaaS 구독으로 적용
  소규모 F&B 매장 타겟

법적 근거:
  식품위생법 제48조 (식품안전관리인증기준)
  소규모 업체 HACCP 적용 확대 정책
  식약처 스마트 HACCP 추진 방향과 일치
```

---

## 2. CCP 관리 항목

### CCP-001: 조리 온도 관리

```text
위해요소:
  불충분한 가열로 인한 식중독균 생존

관리 기준:
  중심 온도 75도 이상 (닭고기 85도)
  조리 시간 KDS 기준치 준수

자동화:
  KDS 조리 시작 → 타이머 시작
  estimated_minutes 초과 → 경고
  조리 완료 → 온도 확인 체크 팝업
  직원 확인 → CCP 로그 자동 기록

향후:
  IoT 온도 센서 연동
  실시간 온도 자동 기록
  임계값 이탈 → 즉시 알림
```

---

### CCP-002: 냉장/냉동 보관 온도

```text
위해요소:
  부적절한 보관 온도로 인한 세균 증식

관리 기준:
  냉장: 0~5도
  냉동: -18도 이하

자동화:
  IoT 센서 → 윤슬OS 수신
  1시간마다 자동 로그
  임계값 이탈 → 즉시 슬롯 컨테이너 알림
  SOP 자동 발동 (SOP-FOOD-001)

기록:
  ccp_temperature_logs 테이블
  날짜/시간/온도/담당자
  자동 이상 플래그
```

---

### CCP-003: 유통기한 관리

```text
위해요소:
  유통기한 초과 재료 사용

관리 기준:
  유통기한 D-2 → 경고
  유통기한 D-0 → 사용 차단

자동화:
  inventory_items.expiry_date 기반
  pg_cron 매일 새벽 자동 체크
  D-2 → 슬롯 컨테이너 배지 알림
  D-0 → 해당 재료 포함 메뉴 자동 SOLD_OUT
  직원 확인 없이 시스템 자동 차단

기록:
  inventory_expiry_log
  폐기 수량 / 금액 자동 집계
  원가 손실 분석 연동
```

---

### CCP-004: 교차 오염 방지

```text
위해요소:
  생식/조리 재료 교차 오염

관리 기준:
  kitchen_zone 구역별 분리
  생식 재료 = RAW 구역
  조리 재료 = COOKED 구역
  알레르겐 재료 = 별도 보관

자동화:
  kitchen_zone 이미 구현 (MAIN/SIDE/BAR)
  메뉴별 kitchen_zone 지정
  KDS 에 구역별 티켓 분리 표시
  알레르겐 메뉴 → KDS 경고 표시

기록:
  kds_tickets.kitchen_zone 자동 로그
  구역 이탈 이벤트 감지
  감사 원장 기록
```

---

### CCP-005: 직원 위생 관리

```text
위해요소:
  불결한 직원 위생으로 인한 오염

관리 기준:
  위생 교육 이수 확인
  건강 진단서 유효기간
  조리 전 손 세척 확인

자동화:
  Workforce 연동
  위생 교육 이수 여부 staff 테이블
  미이수 직원 → KDS 조리 권한 제한
  건강 진단서 만료 → 직원 앱 알림
  출근 체크 → 위생 수칙 팝업 표시

기록:
  staff_hygiene_log
  교육 이수 날짜/항목
  위반 이벤트 감사 원장
```

---

### CCP-006: 알레르겐 관리

```text
위해요소:
  알레르겐 미고지로 인한 고객 사고

관리 기준:
  식품위생법 알레르겐 표시 의무
  18가지 주요 알레르겐 관리

자동화:
  menus.allergen_info (이미 구현) ✓
  키오스크 알레르겐 필터 표시
  다국어 알레르겐 안내
  주문 시 알레르겐 자동 경고

기록:
  알레르겐 표시 이력 자동 보존
  개정 시 변경 이력 관리
  식약처 감사 대비 리포트 자동 생성
```

---

## 3. CCP 대시보드

```text
본사 CCP 대시보드:
  전 가맹점 CCP 현황 실시간
  이상 발생 매장 즉시 표시
  CCP 준수율 브랜드별 비교
  위반 이력 + SOP 실행 기록

매장 CCP 화면:
  오늘의 CCP 체크 현황
  미완료 항목 강조
  직원별 담당 항목

자동 리포트:
  일간/주간/월간 CCP 리포트
  식약처 제출용 포맷 자동 생성
  이상 발생 → 조치 결과 포함
```

---

## 4. DB 테이블

```text
신규 테이블:
  catchmenu_store.ccp_configs
    매장별 CCP 항목 설정
    임계값 / 측정 주기

  catchmenu_store.ccp_logs
    자동 측정 로그
    수동 확인 로그

  catchmenu_store.ccp_temperature_logs
    온도 센서 자동 기록

  catchmenu_store.ccp_violations
    위반 이벤트
    조치 사항
    재발 방지 계획

기존 연동:
  catchmenu_pos.menus.allergen_info ✓
  catchmenu_store.inventory_items ✓
  catchmenu_kds.kds_tickets ✓
  catchmenu_store.staff ✓
  catchmenu_ledger.events ✓
```

---

## 5. 사업적 가치

```text
매장 입장:
  HACCP 준비 비용 90% 절감
  전담 인력 불필요
  식약처 감사 자동 대비
  위생 사고 예방

본사 입장:
  전 가맹점 위생 통합 관리
  브랜드 신뢰도 보호
  위생 사고 시 법적 책임 방어

SaaS 수익:
  CCP 기능 = 프리미엄 플랜
  기본 플랜 + 3만원/월 추가
  식약처 리포트 = 추가 옵션

법적 가치:
  감사 원장 = 법적 증거
  위반 → 조치 기록 자동 보존
  식중독 사고 시 면책 근거
```

---

## 6. 로드맵

```text
Phase 1 (MVP):
  CCP-003 유통기한 자동 관리
  CCP-006 알레르겐 자동 표시
  기존 DB 활용, 추가 개발 최소

Phase 2:
  CCP-001 조리 온도 (KDS 연동)
  CCP-004 교차 오염 (kitchen_zone)
  CCP-005 직원 위생 (Workforce 연동)

Phase 3:
  CCP-002 냉장 온도 (IoT 센서)
  본사 CCP 대시보드
  식약처 리포트 자동 생성
  스마트 HACCP 인증 신청
```

---

## 7. Related Documents

| 문서 | 역할 |
|---|---|
| 900160: Patent A | 운영 이벤트 → 화면 제어 |
| 900173: 윤슬OS | AI F&B SaaS |
| 900175: Workforce | 직원 위생 연동 |
| 900176: 이 문서 | CCP 미니버전 |
