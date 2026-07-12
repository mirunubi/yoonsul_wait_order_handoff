# 900163_Assessment_Prior_Patent_Risk_And_Avoidance_Strategy_Global_Late_Binding

Status: In_Progress
Lifecycle: Assessment
Owner: TBD
Last Updated: 2026-06-26

---

## 0. Document Purpose

이 Assessment 문서는 캐치메뉴 Late Binding 시스템의
글로벌 선행특허 리스크를 분석하고
회피 전략 및 보강 방향을 정의한다.

```text
판단 기준:
  변리사 검토 후 특허 가능 → 유지
  특허 불가 판정 → 해당 섹션 파기

핵심 질문:
  특허를 낼 수 있느냐보다
  서비스를 출시했을 때 기존 특허로
  사용 못 하게 되는가 (FTO) 가 더 중요
```

---

## 1. 글로벌 선행특허 위험도 분석

### 1.1 SpotOn (미국) — 위험도: 높음

```text
특허/제품: Seat & Send 플랫폼
관련 특허: US9,390,424 B2 (Smart Order LLC)

핵심 구조:
  대기 등록 → 모바일 주문 링크 SMS 전송
  사전 주문 → 가상 대기 카트 홀딩
  착석 트리거 → KDS 전송 (Fire)

우리와 겹치는 부분:
  대기 → 사전 주문 → 착석 → KDS
  흐름 자체가 유사

차이점:
  SpotOn: 착석 = KDS 전송
  우리:   착석 ≠ KDS 활성화
          결제 확인 = KDS 활성화 (Patent 2)

판정:
  전체 흐름은 유사하나
  KDS 활성화 트리거가 다름
  결제 분리 구조가 핵심 회피 포인트
```

---

### 1.2 QikServe (유럽) — 위험도: 높음

```text
특허: US9,117,231 B2 (EPO 패밀리 포함)
인수: 2024년 The Access Group

핵심 구조:
  주문 먼저 생성 (테이블 없이)
  → 테이블 NFC/QR 스캔 시 바인딩
  → 이종 EPOS 어댑터로 동적 전송

우리와 겹치는 부분:
  테이블 태그 없이 주문 먼저 생성
  물리 테이블과 후행 바인딩

차이점:
  QikServe: NFC/QR 단일 수단
  우리: NFC + Beacon + GPS 복합 검증
  QikServe: EPOS 어댑터 동적 선택
  우리: KDS HOLD/COMMITTED 분리 제어

판정:
  바인딩 구조 유사하나
  복합 검증 + KDS 분리가 차별점
  EPO 심사에서 기술적 구현 차이 주장 가능
```

---

### 1.3 Visa SNAP (일본/글로벌) — 위험도: 중간

```text
특허: JP4363800B2 및 글로벌 패밀리

핵심 구조:
  매장 진입 시 가상 Late Binding Token 발급
  결제 시점에 POS QR 스캔
  → 토큰 + 정산 계정 + 테이블 거래 키 바인딩

우리와 겹치는 부분:
  가상 토큰 발급
  물리 자원과 런타임 바인딩

결정적 차이:
  Visa SNAP: 토큰 = 결제 계좌 바인딩
             결제가 목적
  우리:      토큰 = 주문 소유권 확정
             결제 완료 → KDS 조리 허가
             결제와 조리 허가를 분리

  즉, Visa 는 "결제 시점 바인딩"
  우리는 "결제 후 KDS 활성화 분리"
  이 개념이 Visa 특허에 없음

판정:
  토큰 구조는 유사하나
  KDS 분리 제어가 핵심 차별점
  회피 가능성 있음
```

---

### 1.4 중국 분산 큐 특허 — 위험도: 낮음 (국내)

```text
특허: CN103765453B 등

핵심 구조:
  분산 MQ + UUID 튜플 상태 유지
  착석 호스트 신호 → 분산 잠금
  → 테이블 소유권 워커에 독점 바인딩

우리와 겹치는 부분:
  UUID 기반 세션 관리
  착석 신호 기반 바인딩

차이점:
  중국: 동시성 처리 중심
        감사 원장 없음
  우리: append-only ledger
        모든 상태 전이 기록
        법적 증거 패킷 생성 가능

판정:
  국내 서비스 기준 직접 침해 없음
  글로벌 확장 시 검토 필요
  감사 원장이 핵심 차별점
```

---

### 1.5 KR102160469B1 (한국) — 위험도: 최고

```text
명칭: 거래 중개 서버 및 거래 정보 등록 방법

핵심 구조:
  구두주문 → POS 거래액 등록
  → 단일 QR 스캔 → 거래 조회 → 결제

국내 서비스 직접 위협
KIPRIS 원문 청구항 확인 필수
```

---

## 2. 글로벌 선행특허 공통 한계

```text
SpotOn / QikServe / Visa SNAP / 중국 특허
모두 공통적으로 없는 것:

1. 결제 완료 → KDS 조리 허가 분리
   모두 착석 또는 결제 = KDS 전송
   결제 전 KDS HOLD 유지 개념 없음

2. append-only 감사 원장
   모든 상태 전이의 법적 증거화
   정산 대사 자동화

3. 운영 이벤트 → KDS 상태 연동
   품절/장애/대기 이벤트와 KDS 연결

4. POS 연동 수준별 KDS 모드 자동 전환
   graceful degradation 구조

이 4가지가 우리의 차별 영역
```

---

## 3. 보강 전략 3개 레이어

### Layer 1: OTP 기반 가상 바인딩 토큰 (Visa SNAP 차별화)

```text
현재 구조:
  order_sessions.customer_token (UUID)
  단순 식별자 역할

보강 구조:
  대기 등록 시 Token Vault 에서
  OTP 기반 가상 바인딩 토큰 발급
  → 모바일 프라이빗 메모리에 해싱 저장

  테이블 NFC 접근 시:
  POS Gateway 가 비대칭 키로 검증
  → 암호학적으로 테이블 소유권 확정

Visa SNAP 과의 차이:
  Visa: 토큰 = 결제 계좌 바인딩
  우리: 토큰 = 주문 소유권 확정
        + 결제 완료 → KDS 별도 활성화

기술 특허 분류:
  네트워크 보안 + 키 교환 프로토콜
  단순 BM 특허 아님
  EPO/JPO 기술 특허 통과 가능성 높음

DB 구현:
  order_sessions.customer_token 확장
  token_vault (별도 서비스 또는 Supabase Vault)
  token_verification_log 테이블 추가
```

---

### Layer 2: KDS 분리 제어 (SpotOn/QikServe 차별화)

```text
현재 구조 (이미 구현):
  kds_tickets.kds_status = HOLD ✓
  release_kds_after_payment() ✓
  conditions_met.payment_confirmed ✓
  Patent 2 핵심 - 가장 강한 증거

핵심 주장:
  착석 이벤트 ≠ KDS 전송
  결제 승인 이벤트 = KDS COMMITTED

SpotOn 대비:
  SpotOn: 착석 트리거 → KDS Fire
  우리:   결제 확인 → KDS COMMITTED
          이 분리가 핵심

특허 문장:
  "대기 세션에서 생성된 KDS 티켓이
   HOLD 상태로 존재하되
   서버 측 결제 승인 이벤트가
   발생하기 전까지 조리 실행이
   시스템에 의해 차단되는 구조"
```

---

### Layer 3: append-only 감사 원장 (중국 특허 차별화)

```text
현재 구조 (이미 구현):
  catchmenu_ledger.events ✓
  append-only 설계 ✓
  correlation_id 추적 ✓
  before_state / after_state ✓

핵심 주장:
  모든 상태 전이가 불변 원장에 기록
  법적 증거 패킷 자동 생성
  정산 대사 근거

중국 특허 대비:
  중국: 동시성 처리만
  우리: 동시성 + 감사 원장 + 법적 증거화

추가 보강:
  Layer 1 토큰 검증 로그도 원장 기록
  Layer 2 KDS 전환도 원장 기록
  전체 파이프라인 단일 원장으로 추적
```

---

### Layer 4: 엣지 오프라인 복구 (전체 글로벌 차별화)

```text
현재 구조:
  pg_cron 오프라인 큐 (부분)
  Store Local Agent (설계 중)

보강 구조:
  매장 엣지 게이트웨이
  클라우드 단선 시 로컬 유지
  → 오프라인에서도 NFC 바인딩 실행
  → 복구 시 자동 배치 업로드

글로벌 선행특허 모두 없는 것:
  오프라인 엣지 복구 + 자동 동기화
  이 구조가 완전한 장치 제어 청구항

일본 특허청(JPO) 심사 기준 충족:
  단거리 무선 통신(NFC/Beacon) +
  통신 단선 시 로컬 상태 영속화 +
  물리 테이블 단위 하드웨어 제어
  → JPO 기술 특허 요건 충족
```

---

## 4. 보강된 특허 핵심 구조

```text
4개 Layer 조합:

  [Layer 1] OTP 토큰
  대기 등록 → Token Vault OTP 발급
  모바일 해싱 저장
  NFC 접근 → 비대칭 키 검증
  → 테이블 소유권 암호학적 확정

       ↓

  [Layer 2] KDS 분리 제어
  결제 완료 → KDS COMMITTED 트리거
  (착석만으로는 KDS 활성화 안 됨)

       ↓

  [Layer 3] 감사 원장
  전 과정 append-only ledger 기록
  법적 증거 패킷 자동 생성

       ↓

  [Layer 4] 엣지 복구
  클라우드 단선 시 로컬 유지
  복구 시 자동 배치 동기화

이 4개 조합 = 글로벌 선행특허 어디에도 없음
```

---

## 5. 변리사 전달 최종 문장

```text
본 발명은 글로벌 선행특허들과
다음 4가지 점에서 구별된다:

1. Visa SNAP 대비:
   가상 바인딩 토큰이 결제 계좌가 아닌
   주문 소유권 확정에 사용되며,
   OTP + 비대칭 키 검증으로
   테이블 점유를 암호학적으로 처리한다.

2. SpotOn/QikServe 대비:
   착석 이벤트가 KDS 전송을 트리거하지 않고,
   서버 측 결제 승인 이벤트만이
   KDS 티켓을 HOLD → COMMITTED 로
   전환하는 분리 제어 구조다.

3. 중국 분산 특허 대비:
   동시성 처리에 더해
   모든 상태 전이가 append-only
   감사 원장에 기록되어
   법적 증거 패킷으로 추출 가능하다.

4. 전체 글로벌 대비:
   클라우드 단선 시 엣지 게이트웨이가
   로컬에서 바인딩을 유지하고
   복구 시 자동 배치 동기화한다.
```

---

## 6. 변리사 면담 제출 자료

```text
DB 증거 (이미 완성):
  [ ] catchmenu_ledger.events 스키마
      append-only 감사 원장 증거

  [ ] kds_tickets HOLD/COMMITTED 구조
      Layer 2 KDS 분리 제어 증거

  [ ] order_sessions customer_token 필드
      Layer 1 OTP 토큰 확장 근거

  [ ] run_integration_test ALL_PASS
      Patent 2 동작 증빙

  [ ] migration 0001~0138 커밋 히스토리
      구현 시점 증빙

추가 준비:
  [ ] KIPRIS KR102160469B1 청구항 원문
      국내 FTO 핵심
  [ ] Token Vault 설계도
      Layer 1 구현 계획
  [ ] 엣지 게이트웨이 아키텍처
      Layer 4 구현 계획
```

---

## 7. 시나리오별 대응

```text
시나리오 A: Layer 2 단독 특허 가능
  Patent 2 (KDS Late Binding) 출원
  가장 빠르고 강한 카드

시나리오 B: Layer 1+2 복합 특허
  OTP 토큰 + KDS 분리 조합
  기술 특허로 분류 가능

시나리오 C: 4개 Layer 전체 출원
  가장 강하나 준비 기간 필요
  Layer 4 엣지 서버 구현 후 출원

시나리오 D: 특허 포기
  구현 속도로 시장 선점
  오픈 소스화로 진입 장벽 역이용
  감사 원장 데이터로 경쟁 우위 유지
```

---

## 8. 파기 조건

```text
아래 중 하나라도 해당하면
900162 + 900163 관련 섹션 파기:

  [ ] KR102160469B1 청구항이
      우리 전체 흐름을 포함
      AND Layer 2 도 종속항으로 포함
  [ ] 변리사가 4개 Layer 모두 신규성 없음 판정
  [ ] 선행특허 추가 발견으로 회피 불가

파기 후에도 보존:
  구현 자체는 유지
  감사 원장 데이터 경쟁력 유지
  캐치메뉴 운영OS 로서의 가치 유지
```

---

## 9. 캐치메뉴 최종 비전과의 연결

```text
특허가 목적이 아니라
서비스가 목적이다.

캐치메뉴 끝:
  POS + KDS + DID + CMS 쿠폰 사업

윤슬OS 끝:
  멀티 브랜드 F&B 그룹 운영 OS
  (윤슬김밥 → 윤슬보울 → 야식 → 음료)
  AI 접목 범용 F&B SaaS

특허는 이 비전을 보호하는 수단
특허 없어도 감사 원장 + 운영 속도로
시장 선점 가능

특허 출원 시 우선순위:
  1순위: Layer 2 (KDS Late Binding)
         서울 1호점 오픈 전 출원
  2순위: Layer 1+2 복합
         Token Vault 구현 후
  3순위: Layer 3+4
         엣지 서버 구현 후
```
