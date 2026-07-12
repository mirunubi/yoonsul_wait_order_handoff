# 900178_Policy_Hyper_Personalization_Menu_Customization_And_Pricing

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-07-02

---

## 0. Document Purpose

이 Policy 문서는 윤슬OS / 캐치메뉴의
초개인화 메뉴 커스터마이징 및 가격 정량화 시스템을 정의한다.

```text
핵심 목표:
  "단무지 빼주세요"
  "계란지단 더 넣어주세요"
  "오이 제거하고 참기름 더"

  이 조합의 가격을 자동 계산하고
  KDS 에 정확히 전달하는 시스템

1호점 목표:
  윤슬김밥 서울 1호점에서
  초개인화 주문 검증
  시중 SaaS 에는 미공개
  내부 경쟁력으로 활용
```

---

## 1. 왜 초개인화인가

```text
기존 김밥집:
  메뉴판에 있는 것만 주문
  "단무지 빼달라" = 구두로 전달
  KDS/POS 에 기록 없음
  가격 변동 없음

치폴레/서브웨이 모델:
  재료 하나씩 선택
  추가/제거/증량 가격 정량화
  POS 에 정확히 기록
  조리 화면에 정확히 표시

윤슬OS 차별점:
  한국형 김밥에 이 모델 적용
  키오스크 + 고객앱에서 직접 선택
  KDS 에 커스터마이징 상세 표시
  가격 자동 계산 + 결제 연동
  Patent 2 와 연결
    (커스터마이징 주문 → KDS HOLD
     결제 확인 → KDS COMMITTED)
```

---

## 2. 가격 정량화 모델

### 2.1 기본 구조

```text
최종 가격 = 베이스 가격 + Σ(옵션 단가)

예시: 윤슬김밥 커스터마이징

  기본 윤슬김밥    = 5,300원  (베이스)
  계란지단 추가    =  +500원
  단무지 제거      =     0원  (무료)
  참기름 더        =  +200원
  오이 제거        =     0원  (무료)
  ─────────────────────────
  최종 가격        = 6,000원
```

### 2.2 옵션 유형

```text
ADD (추가):
  기본 재료에 없는 것을 추가
  price_delta >= 0
  예: 계란지단 추가 +500, 치즈 추가 +500

REMOVE (제거):
  기본 재료에서 제거
  price_delta = 0 (기본)
  예: 단무지 제거, 오이 제거, 시금치 제거

EXTRA (증량):
  기본 재료를 더 많이
  price_delta >= 0
  예: 참기름 더 +200, 계란지단 곱빼기 +500

SUBSTITUTE (대체):
  A 재료를 B 재료로 교체
  price_delta = 차액
  예: 햄 → 베이컨 교체 +300

LESS (감량):
  기본 재료를 적게
  price_delta = 0 (기본)
  예: 참기름 적게, 단무지 적게
```

---

## 3. DB 설계

### 3.1 menu_option_groups 확장

```sql
-- 기존 컬럼에 추가
ALTER TABLE catchmenu_pos.menu_option_groups
ADD COLUMN IF NOT EXISTS
  group_type text DEFAULT 'ADD'
  CONSTRAINT chk_group_type CHECK (
    group_type IN (
      'ADD', 'REMOVE', 'EXTRA',
      'SUBSTITUTE', 'LESS'
    )
  ),
ADD COLUMN IF NOT EXISTS
  is_required boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS
  min_select int DEFAULT 0,
ADD COLUMN IF NOT EXISTS
  max_select int DEFAULT 1,
ADD COLUMN IF NOT EXISTS
  display_order int DEFAULT 0;

-- 예시 그룹:
-- "제거할 재료" (group_type=REMOVE, min=0, max=10)
-- "추가 재료"   (group_type=ADD, min=0, max=5)
-- "증량"        (group_type=EXTRA, min=0, max=3)
```

### 3.2 menu_option_items 확장

```sql
-- 기존 컬럼에 추가
ALTER TABLE catchmenu_pos.menu_option_items
ADD COLUMN IF NOT EXISTS
  price_delta int DEFAULT 0,
  -- 양수: 추가금, 음수: 할인, 0: 무료
ADD COLUMN IF NOT EXISTS
  is_default_included boolean DEFAULT false,
  -- 기본 메뉴에 포함된 재료인지
ADD COLUMN IF NOT EXISTS
  is_removable boolean DEFAULT true,
  -- 제거 가능한지
ADD COLUMN IF NOT EXISTS
  max_extra_qty int DEFAULT 1,
  -- 최대 추가 수량
ADD COLUMN IF NOT EXISTS
  allergen_delta jsonb DEFAULT '{}',
  -- 이 옵션 선택 시 알레르겐 변화
  -- {"eggs": true} = 계란 추가됨
  -- {"sesame": false} = 참깨 제거됨
ADD COLUMN IF NOT EXISTS
  kitchen_note text,
  -- KDS 에 표시할 주방 지시사항
  -- "계란지단 2장 추가"
ADD COLUMN IF NOT EXISTS
  display_order int DEFAULT 0;
```

### 3.3 order_items 확장

```sql
-- 기존 컬럼에 추가
ALTER TABLE catchmenu_pos.order_items
ADD COLUMN IF NOT EXISTS
  base_price int,
  -- 베이스 메뉴 가격 스냅샷
ADD COLUMN IF NOT EXISTS
  option_price_delta int DEFAULT 0,
  -- 옵션 합산 가격 변동
ADD COLUMN IF NOT EXISTS
  final_price int,
  -- base_price + option_price_delta
ADD COLUMN IF NOT EXISTS
  customization_log jsonb DEFAULT '[]',
  -- 선택한 옵션 전체 기록
  -- [{"option_item_id": "...",
  --   "option_name": "계란지단 추가",
  --   "option_type": "ADD",
  --   "qty": 1,
  --   "price_delta": 500,
  --   "kitchen_note": "계란지단 2장"}]
ADD COLUMN IF NOT EXISTS
  customization_allergen_final jsonb DEFAULT '{}',
  -- 최종 알레르겐 (베이스 + 옵션 반영)
ADD COLUMN IF NOT EXISTS
  has_customization boolean DEFAULT false;
  -- 커스터마이징 여부 빠른 체크
```

### 3.4 kds_tickets 연동

```sql
-- kds_tickets 에 커스터마이징 표시
ALTER TABLE catchmenu_kds.kds_tickets
ADD COLUMN IF NOT EXISTS
  customization_display text,
  -- KDS 화면 표시용 요약
  -- "▼단무지 ▲계란지단×2 ▲참기름"
ADD COLUMN IF NOT EXISTS
  has_customization boolean DEFAULT false;
```

---

## 4. RPC 설계

### 4.1 get_menu_customization_options()

```sql
-- 메뉴의 커스터마이징 옵션 조회
-- 키오스크/고객앱에서 호출

get_menu_customization_options(
  p_menu_id uuid,
  p_tenant_id uuid,
  p_locale text DEFAULT 'ko'
)

반환:
  {
    "menu_id": "...",
    "menu_name": "윤슬김밥",
    "base_price": 5300,
    "option_groups": [
      {
        "group_id": "...",
        "group_name": "제거할 재료",
        "group_type": "REMOVE",
        "min_select": 0,
        "max_select": 10,
        "items": [
          {
            "item_id": "...",
            "item_name": "단무지",
            "price_delta": 0,
            "is_default_included": true,
            "kitchen_note": "단무지 제외"
          }
        ]
      },
      {
        "group_id": "...",
        "group_name": "추가 재료",
        "group_type": "ADD",
        "items": [
          {
            "item_id": "...",
            "item_name": "계란지단 추가",
            "price_delta": 500,
            "kitchen_note": "계란지단 2장"
          }
        ]
      }
    ]
  }
```

### 4.2 calculate_customization_price()

```sql
-- 커스터마이징 가격 실시간 계산
-- 키오스크/고객앱 UI 에서 즉시 호출

calculate_customization_price(
  p_menu_id uuid,
  p_selected_options jsonb
  -- [{"option_item_id": "...", "qty": 1}]
)

반환:
  {
    "base_price": 5300,
    "option_price_delta": 700,
    "final_price": 6000,
    "price_breakdown": [
      {"name": "계란지단 추가", "delta": 500},
      {"name": "참기름 더", "delta": 200}
    ],
    "allergen_final": {"eggs": true, "sesame": true},
    "customization_display": "▼단무지 ▲계란지단 ▲참기름"
  }
```

### 4.3 create_order_with_customization()

```sql
-- 커스터마이징 주문 생성
-- 기존 create_order 확장

create_order_with_customization(
  p_session_id uuid,
  p_items jsonb
  -- [{
  --   "menu_id": "...",
  --   "qty": 1,
  --   "selected_options": [
  --     {"option_item_id": "...", "qty": 1}
  --   ]
  -- }]
)

처리:
  1. 각 item 의 final_price 계산
  2. order_items.customization_log 저장
  3. order_items.customization_allergen_final 계산
  4. kds_tickets 생성 (HOLD)
  5. kds_tickets.customization_display 생성
  6. ledger 기록
```

---

## 5. KDS 화면 표시

```text
KDS 티켓 커스터마이징 표시 형식:

┌─────────────────────────────┐
│ 테이블 7  │  윤슬김밥 ×1   │
│ 6,000원   │  ★ 커스터마이징 │
│─────────────────────────────│
│ ▼ 단무지 제거               │
│ ▲ 계란지단 추가 (+500)      │
│ ▲ 참기름 더 (+200)          │
│─────────────────────────────│
│ [HOLD]  결제 대기 중        │
└─────────────────────────────┘

결제 완료 후:
┌─────────────────────────────┐
│ 테이블 7  │  윤슬김밥 ×1   │
│ 6,000원   │  ★ 커스터마이징 │
│─────────────────────────────│
│ ▼ 단무지 제거               │
│ ▲ 계란지단 추가             │
│ ▲ 참기름 더                 │
│─────────────────────────────│
│ [COMMITTED]  조리 시작 ▶   │
└─────────────────────────────┘
```

---

## 6. 키오스크 / 고객앱 UI 흐름

```text
1. 메뉴 선택
   윤슬김밥 5,300원 → [주문하기]

2. 커스터마이징 화면
   제거할 재료:
     □ 단무지  □ 오이  □ 시금치
     □ 어묵   □ 햄

   추가 재료:
     □ 계란지단 +500원
     □ 치즈    +500원
     □ 베이컨  +800원

   증량:
     □ 참기름 더 +200원
     □ 밥 더    +300원

3. 실시간 가격 표시
   기본: 5,300원
   옵션: +700원
   합계: 6,000원 ← 즉시 갱신

4. 알레르겐 재계산
   옵션 선택 시 알레르겐 자동 갱신
   "계란 추가됨" 경고

5. 장바구니 담기
   customization_log 저장
   결제로 이동
```

---

## 7. 윤슬김밥 옵션 예시 (시드 데이터)

```text
제거 가능 재료 (price_delta=0):
  단무지, 오이, 시금치, 어묵, 햄
  계란, 부추, 당근, 맛살

추가 가능 재료:
  계란지단 추가    +500원
  치즈 추가        +500원
  베이컨 추가      +800원
  맛살 추가        +300원

증량:
  참기름 더        +200원
  밥 더            +300원
  계란지단 곱빼기  +800원

대체:
  햄 → 베이컨     +300원
  맛살 → 크래미   +200원
```

---

## 8. Patent 연동

```text
Patent 2 (KDS Late Binding) 확장:
  커스터마이징 주문도 KDS HOLD
  결제 완료 → KDS COMMITTED
  커스터마이징 내용 KDS 에 정확히 표시

Patent A (운영 이벤트) 확장:
  특정 재료 품절 →
  해당 옵션 자동 비활성화
  키오스크/고객앱 즉시 반영

AI 연동 (향후):
  고객별 커스터마이징 패턴 학습
  "항상 단무지 제거하시는 분"
  → 다음 방문 시 자동 제안
  pgvector 기반 선호도 검색
```

---

## 9. 1호점 테스트 계획

```text
Phase 1 (MVP):
  제거 옵션만 (price_delta=0)
  단무지/오이/시금치 제거
  KDS 에 "▼단무지" 표시
  가격 변동 없음

Phase 2 (유료 옵션):
  계란지단 추가 +500원
  치즈 추가 +500원
  가격 자동 계산

Phase 3 (전체):
  증량/대체/감량
  AI 선호도 제안
  교차 메뉴 추천

KPI:
  커스터마이징 주문 비율
  평균 옵션 추가 금액
  KDS 오류율 (잘못된 조리)
  고객 재주문율 (개인화 효과)
```

---

## 10. Related Documents

| 문서 | 역할 |
|---|---|
| 900100: Patent 1+2 | KDS Late Binding |
| 900160: Patent A | 운영 이벤트 제어 |
| 900172: 쿠폰 사업 | 커스터마이징 + 쿠폰 연동 |
| 900173: 윤슬OS | 멀티브랜드 확장 |
| 900176: CCP | 알레르겐 자동 재계산 |
| 900178: 이 문서 | 초개인화 가격 정량화 |
