# 900172_Policy_Coupon_Business_Model_And_CMS_Integration

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-26

---

## 0. Document Purpose

이 Policy 문서는 캐치메뉴의 최종 수익 모델인
POS + KDS + DID + CMS 연동 쿠폰 사업 구조를 정의한다.

```text
캐치메뉴의 끝:
  단순 운영OS 가 아니라
  POS + KDS + DID + CMS 를 연결한
  쿠폰 사업 플랫폼

핵심 원리:
  운영OS 가 매장 데이터를 가지고 있기 때문에
  가장 정확한 타겟 쿠폰 발행이 가능하다
  광고비를 받는 게 아니라
  쿠폰 수수료로 수익을 낸다
```

---

## 1. 쿠폰 사업 구조

### 1.1 데이터 흐름

```text
[고객 행동 데이터]
  대기 등록 → 체류 시간
  메뉴 탐색 → 관심 메뉴
  주문 내역 → 선호 패턴
  결제 금액 → 객단가
  방문 횟수 → 충성도
  알레르겐 → 제외 메뉴
        ↓
[캐치메뉴 운영OS]
  실시간 분석
  패턴 감지
  쿠폰 대상 선정
        ↓
[쿠폰 발행]
  개인화 쿠폰
  시간대별 쿠폰
  재방문 쿠폰
  교차 메뉴 쿠폰
        ↓
[멀티 채널 발행]
  DID: 대기 중 화면 표시
  키오스크: 주문 중 팝업
  고객앱: 푸시 알림
  직원앱: 직원 안내
        ↓
[쿠폰 사용]
  결제 시 자동 적용
  KDS 확인 (Patent 2)
  사용 결과 → 원장 기록
        ↓
[효과 측정]
  발행 대비 사용률
  매출 기여도
  재방문율 변화
  CMS 피드백 자동화
```

---

### 1.2 쿠폰 유형

```text
즉시 쿠폰:
  대기 중 발행 → 오늘만 사용
  "대기 감사 쿠폰 500원 할인"
  DID 와 고객앱 동시 표시

재방문 쿠폰:
  결제 완료 후 발행
  "다음 방문 시 음료 무료"
  유효기간 7일

교차 메뉴 쿠폰:
  주문 패턴 분석
  "참치김밥 주문하셨네요.
   다음엔 와사비참치김밥 어떠세요? 500원 할인"

시간대 쿠폰:
  피크타임 외 방문 유도
  "평일 오후 2~5시 방문 시 10% 할인"
  DID 와 키오스크 자동 표시

단체 쿠폰:
  party_size >= 4 감지
  "4인 이상 방문 시 음료 1개 무료"

재고 소진 쿠폰:
  특정 메뉴 재고 부족 감지
  "오늘의 특가: 불고기김밥 500원 할인"
  자동 발행 → 자동 소멸 (품절 시)
```

---

## 2. POS + KDS + DID + CMS 연동 구조

```text
[CMS]
  쿠폰 정책 설정
  발행 조건 설정
  효과 대시보드
        ↓
[POS]
  주문/결제 데이터 수신
  쿠폰 적용 금액 계산
  영수증 쿠폰 표시
        ↓
[KDS]
  쿠폰 적용 주문 표시
  쿠폰 사용 확인 (Patent 2 연동)
  "쿠폰 할인 적용됨" 표시
        ↓
[DID]
  대기 중 쿠폰 화면 표시
  호출 시 쿠폰 안내 동시 표시
  "W-007번 고객님 쿠폰 적용 가능"
        ↓
[슬롯 컨테이너]
  쿠폰 슬롯 (SlotContainerAgent)
  새 쿠폰 발행 → 배지 표시
  직원 안내 팝업
```

---

## 3. 수익 모델

```text
수익원 1: SaaS 구독료 (기본)
  매장당 월정액
  쿠폰 기능 포함 플랜

수익원 2: 쿠폰 발행 수수료
  쿠폰 발행 건당 소액
  또는 월 발행 한도 초과 시

수익원 3: 쿠폰 사용 수수료
  쿠폰 사용 건당 수수료
  (결제 금액의 0.5~1%)

수익원 4: 외부 브랜드 쿠폰
  외부 광고주 → 캐치메뉴 플랫폼에 쿠폰 등록
  특정 메뉴 구매 시 음료 브랜드 쿠폰 발행
  광고비 수취

수익원 5: 데이터 인사이트
  쿠폰 효과 분석 리포트
  업종별 벤치마크
  유료 구독

비교:
  배달앱: 매출의 10~15% 수수료
  캐치메뉴: 쿠폰 수수료 1% 미만
  → 매장 입장에서 훨씬 저렴
  → 직접 고객 관계 구축 가능
```

---

## 4. DB 구현

```text
기존 테이블 활용:
  catchmenu_store.coupons
  catchmenu_store.coupon_usage_log
  catchmenu_store.stamp_cards
  catchmenu_store.point_ledger
  catchmenu_ledger.events

추가 필요 테이블:
  catchmenu_store.coupon_campaigns
    캠페인 단위 쿠폰 관리
    발행 조건 / 유효기간 / 예산

  catchmenu_store.coupon_analytics
    발행 수 / 사용 수 / 매출 기여
    일별 / 주별 / 월별

  catchmenu_cms.cms_coupon_configs
    CMS 에서 쿠폰 정책 설정
    자동 발행 조건
    채널별 표시 설정

RPC:
  issue_coupon_auto(p_trigger_event, p_session_id)
    운영 이벤트 기반 자동 발행
  apply_coupon_to_order(p_coupon_code, p_order_id)
    결제 시 자동 적용
  get_coupon_analytics(p_store_id, p_period)
    효과 분석 조회
```

---

## 5. Patent 연동

```text
Patent 2 (KDS Late Binding) 확장:
  쿠폰 적용 주문도 KDS HOLD 유지
  결제 + 쿠폰 확인 → KDS COMMITTED
  쿠폰 미확인 시 KDS 활성화 차단 가능

Patent A (운영 이벤트 → 화면) 확장:
  재고 소진 이벤트 → 재고 소진 쿠폰 자동 발행
  대기 이벤트 → 대기 감사 쿠폰 자동 발행
  피크타임 이벤트 → 비피크 할인 쿠폰 자동 발행

슬롯 컨테이너 연동:
  쿠폰 Agent 슬롯 추가
  새 쿠폰 발행 → 슬롯 배지
  직원 안내 팝업 자동화
```

---

## 6. 로드맵

```text
Phase 1 (서울 1호점 MVP):
  기본 스탬프 쿠폰
  재방문 쿠폰
  고객앱 발행

Phase 2 (멤버십 통합):
  개인화 쿠폰
  DID 연동 쿠폰
  키오스크 팝업 쿠폰

Phase 3 (쿠폰 플랫폼):
  외부 브랜드 쿠폰
  교차 매장 쿠폰
  쿠폰 수수료 수익화

Phase 4 (AI 쿠폰):
  실시간 개인화
  예측 기반 발행 타이밍
  효과 자동 최적화
```
