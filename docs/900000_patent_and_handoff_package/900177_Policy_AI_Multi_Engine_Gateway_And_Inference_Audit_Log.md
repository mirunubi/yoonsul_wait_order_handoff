# 900177_Policy_AI_Multi_Engine_Gateway_And_Inference_Audit_Log

Status: In_Progress
Lifecycle: Logic
Owner: TBD
Last Updated: 2026-06-26

---

## 0. Document Purpose

이 Policy 문서는 캐치메뉴/윤슬OS 의
멀티엔진 AI Gateway 구조와
AI 추론 감사 원장 설계를 정의한다.

```text
핵심 원칙:
  처음부터 단일 엔진에 종속되지 않는다
  LangGraph/CrewAI 가 오케스트레이터
  각 엔진은 잘하는 것만 담당
  모든 AI 호출은 ai_inference_logs 에 기록
  필요에 따라 3단/4단/5단 체인 구성
```

---

## 1. 전체 아키텍처

```text
[고객 문의 접수]
  키오스크 / 고객앱 / DID / 직원앱
        ↓
[LangGraph / CrewAI] 오케스트레이터
  대화 흐름 제어
  주문/세션 DB 조회 판단
  pgvector SOP/메뉴 검색
  어떤 엔진 쓸지 동적 라우팅
  tool_call_log 자동 생성
        ↓
  ┌──────────────────────────────┐
  │ 한국어 고객                  │
  │ HyperCLOVA X                │
  │ 자연스러운 한국어 답변 생성  │
  └──────────────────────────────┘
  ┌──────────────────────────────┐
  │ 복잡한 추론 / SOP 분석       │
  │ Claude API (Anthropic)       │
  │ 문서 이해 / 운영 이슈 판단   │
  └──────────────────────────────┘
  ┌──────────────────────────────┐
  │ 영어/중국어/일본어 고객      │
  │ Claude / GPT / Gemini        │
  │ 다국어 답변 생성             │
  └──────────────────────────────┘
  ┌──────────────────────────────┐
  │ 메뉴/SOP 유사도 검색         │
  │ pgvector (내장)              │
  │ 비용 없음 / 가장 빠름        │
  └──────────────────────────────┘
        ↓
[고객 답변 전달]
[ai_inference_logs 기록] ← 반드시
```

---

## 2. 엔진별 역할 확정

### LangGraph / CrewAI (오케스트레이터)

```text
역할:
  대화 상태 관리
  멀티스텝 추론 흐름 제어
  DB 조회 / SOP 검색 판단
  어떤 LLM 을 쓸지 동적 결정
  tool_call_log 자동 생성
  fallback 엔진 자동 전환

선택 이유:
  오픈소스 → 비용 없음
  LLM 에 종속되지 않음
  엔진 교체 시 오케스트레이터 코드 유지
  Supabase Edge Function 에서 실행 가능

도구 목록 (tools):
  search_menu_vector()     메뉴 유사도 검색
  search_sop_runbooks()    SOP 검색
  get_waiting_status()     대기 현황 조회
  get_order_status()       주문 현황 조회
  submit_customer_inquiry() 문의 등록
  get_store_info()         매장 정보 조회
```

---

### HyperCLOVA X (한국어 두뇌)

```text
역할:
  한국어 고객 답변 생성
  외국인 문의 → 주방 전달용 한국어 변환
  뉘앙스가 살아있는 안내 문구
  메뉴 설명 한국어 최적화

선택 이유:
  한국어 자연스러움 최강
  한국 문화/외식 문맥 이해
  네이버 데이터 기반
  국내 서비스 최적화

사용 시나리오:
  한국어 고객 일반 문의
  외국인 주문 → 주방 한국어 전달
  메뉴 설명 한국어 생성
  SOP 한국어 안내 문구
  쿠폰/이벤트 한국어 메시지
```

---

### Claude API (복잡한 추론)

```text
역할:
  SOP 문서 분석/생성
  복잡한 운영 이슈 판단
  AI SOP 자가진화 (Patent C)
  영어권 고객 대응
  다국어 복잡 문의 처리
  새로운 SOP 후보 생성

선택 이유:
  문서 이해/생성 최강
  긴 컨텍스트 처리
  운영 로직 추론 강함
  이미 캐치메뉴 전체 맥락 학습 중
```

---

### GPT / Gemini (필요 시)

```text
역할:
  멀티모달 (메뉴 사진 분석)
  특정 언어 특화 (중국어/일본어)
  Claude 장애 시 fallback
  특수 기능 보완

사용 시나리오:
  고객이 음식 사진으로 메뉴 문의
  Gemini Vision → 메뉴 식별
  특정 언어 품질 이슈 시 대체
```

---

### pgvector (내장 검색)

```text
역할:
  메뉴 자연어 검색
  SOP 관련 문서 검색
  FAQ 유사 문의 매칭
  가장 빠르고 비용 없음

사용 시나리오:
  "글루텐 없는 메뉴 뭐 있어요?"
  → pgvector 메뉴 임베딩 검색
  → LLM 없이 즉시 답변 가능
  LLM 호출 전 1차 필터
```

---

## 3. 체인 구조 예시

### 3단 구조 (기본 한국어 문의)

```text
고객: "참치김밥에 뭐 들어가요?"

  1단: LangGraph
       의도 파악 → 메뉴 문의
       pgvector 검색 → 참치김밥 정보

  2단: HyperCLOVA X
       자연스러운 한국어 답변 생성
       "참치김밥에는 참치마요, 시금치,
        계란, 단무지, 어묵, 햄이 들어갑니다"

  3단: 고객 전달

ai_inference_logs: 2개 row (1단/2단)
```

---

### 4단 구조 (복잡한 운영 문의)

```text
고객: "주문했는데 왜 이렇게 오래 걸려요?"

  1단: LangGraph
       의도 파악 → KDS 지연 문의
       get_order_status() 조회
       kds_tickets 지연 확인

  2단: pgvector
       SOP 검색 → SOP-KDS-001 매칭
       조리 지연 대응 절차 검색

  3단: Claude API
       지연 원인 분석
       적절한 보상/안내 판단

  4단: HyperCLOVA X
       자연스러운 한국어 사과 답변
       "현재 주방이 많이 바쁜 상황입니다.
        약 5분 더 기다려 주시면 감사하겠습니다"

ai_inference_logs: 3개 row (1단/3단/4단)
```

---

### 5단 구조 (외국인 고객)

```text
고객 (영어): "Do you have any gluten-free options?"

  1단: LangGraph
       언어 감지 → 영어
       의도 파악 → 알레르겐 문의
       pgvector 검색 → 글루텐 없는 메뉴

  2단: Claude API
       영어 답변 생성
       "We have keto kimbap options
        that are gluten-free..."

  3단: HyperCLOVA X
       주방 전달용 한국어 변환
       "외국인 고객이 글루텐 없는 메뉴 문의"

  4단: 고객에게 영어 답변 전달
       직원에게 한국어 알림 동시

ai_inference_logs: 3개 row
```

---

## 4. ai_inference_logs 스키마

```sql
CREATE TABLE catchmenu_ai.ai_inference_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL,
  store_id uuid,

  -- 체인 추적
  chain_id uuid NOT NULL,
  chain_step int NOT NULL DEFAULT 1,
  chain_total int NOT NULL DEFAULT 1,

  -- AI 엔진 식별
  model_provider text NOT NULL,
  -- LANGGRAPH / CLOVA_X / ANTHROPIC
  -- OPENAI / GEMINI / PGVECTOR / CUSTOM
  model_name text NOT NULL,
  -- clova-x-v2 / claude-sonnet-4-6
  -- gpt-4o / gemini-1.5-pro

  -- 프롬프트 관리
  prompt_version text NOT NULL,
  prompt_template_id uuid,
  system_prompt_hash text,

  -- 언어
  input_language text,   -- ko/en/zh/ja/vi/th
  output_language text,
  translation_required boolean DEFAULT false,

  -- RAG 추적
  rag_source jsonb,
  -- {"sop_ids": [...], "menu_ids": [...]}
  rag_chunk_count int,
  rag_similarity_threshold numeric,

  -- 입출력
  input_tokens int,
  output_tokens int,
  input_summary text,
  output_summary text,
  latency_ms int,

  -- 도구 호출
  tool_call_log jsonb,
  -- [{"tool": "search_menu_vector",
  --   "input": "글루텐",
  --   "result_count": 5,
  --   "latency_ms": 23}]

  -- 사람 확인
  human_approved boolean DEFAULT false,
  human_approved_by uuid,
  human_approved_at timestamptz,
  human_override text,

  -- fallback
  fallback_engine text,
  fallback_reason text,

  -- 비용
  cost_usd numeric(10, 6),
  cost_krw numeric(10, 2),

  -- 연결
  session_id uuid,
  order_id uuid,
  inquiry_id uuid,
  correlation_id uuid,

  -- 결과
  response_status text,
  -- SUCCESS / FALLBACK / ERROR / TIMEOUT
  customer_satisfied boolean,

  created_at timestamptz DEFAULT now(),

  CONSTRAINT chk_provider CHECK (
    model_provider IN (
      'LANGGRAPH', 'CREWAI',
      'CLOVA_X', 'ANTHROPIC',
      'OPENAI', 'GEMINI',
      'PGVECTOR', 'CUSTOM'
    )
  ),
  CONSTRAINT chk_status CHECK (
    response_status IN (
      'SUCCESS', 'FALLBACK',
      'ERROR', 'TIMEOUT', 'HUMAN_ESCALATED'
    )
  )
);

CREATE INDEX idx_ai_chain
  ON catchmenu_ai.ai_inference_logs(
    chain_id, chain_step
  );

CREATE INDEX idx_ai_provider
  ON catchmenu_ai.ai_inference_logs(
    model_provider, model_name,
    prompt_version, created_at DESC
  );

CREATE INDEX idx_ai_cost
  ON catchmenu_ai.ai_inference_logs(
    tenant_id, created_at DESC
  );
```

---

## 5. prompt_version 관리 원칙

```text
버전 형식: v{major}.{minor}
  v1.0: 초기 출시
  v1.1: 오류 수정
  v2.0: 메이저 개선

버전별 성능 비교 쿼리:
  SELECT
    model_provider,
    prompt_version,
    COUNT(*) as total,
    AVG(latency_ms) as avg_latency,
    AVG(cost_usd) as avg_cost,
    SUM(CASE WHEN human_approved
        THEN 1 ELSE 0 END)::float
      / COUNT(*) as approval_rate
  FROM catchmenu_ai.ai_inference_logs
  GROUP BY model_provider, prompt_version
  ORDER BY approval_rate DESC;

원칙:
  approval_rate 높은 버전 → 전체 적용
  새 버전은 A/B 테스트 후 전환
  rollback = prompt_version 변경만으로 가능
```

---

## 6. human_approved 워크플로우

```text
자동 답변 (human_approved = false):
  LangGraph 판단으로 즉시 답변
  일반 메뉴 문의 / FAQ

사람 확인 필요 (human_approved = true):
  환불/취소 관련
  컴플레인 심각한 경우
  법적/의료 관련 문의
  AI 신뢰도 낮은 경우 (threshold 미만)

에스컬레이션 흐름:
  AI 답변 생성
  → 신뢰도 점수 계산
  → 낮으면 직원앱 알림
  → 직원 확인 후 전송
  → human_approved = true 기록

슬롯 컨테이너 연동:
  슬롯 C (AI 고객센터 Agent)
  에스컬레이션 → 배지 + 팝업
  직원 확인 → resolved
```

---

## 7. MVP 도입 순서

```text
Phase 1 (데이터 없을 때):
  pgvector 메뉴 검색만
  LangGraph 없이 단순 규칙
  HyperCLOVA X 연동 준비

Phase 2 (1호점 3개월 후):
  LangGraph 오케스트레이터
  HyperCLOVA X 한국어 답변
  pgvector SOP 검색
  3단 구조 완성

Phase 3 (데이터 6개월 후):
  Claude API SOP 자가진화
  4단/5단 구조
  다국어 고객 대응

Phase 4 (멀티브랜드):
  브랜드별 프롬프트 분리
  크로스 브랜드 AI 인사이트
  자체 파인튜닝 검토
```

---

## 8. 비용 관리

```text
비용 최소화 원칙:
  pgvector 먼저 (무료)
  → 못 찾으면 LLM 호출
  → 가장 저렴한 엔진 우선

엔진별 비용 추정:
  pgvector:     무료
  HyperCLOVA X: 토큰당 과금
  Claude:       입력/출력 토큰 과금
  GPT-4o:       토큰당 과금

cost_usd / cost_krw 기록:
  → 월별 AI 비용 분석
  → 브랜드별 AI 비용 배분
  → SaaS 가격 책정 근거

목표:
  문의 1건당 AI 비용 10원 미만
  (pgvector 1차 필터로 LLM 호출 50% 감소)
```

---

## 9. Related Documents

| 문서 | 역할 |
|---|---|
| 900123 migration | AI 고객센터 기초 테이블 |
| 900160: Patent C | AI SOP 자가진화 |
| 900173: 윤슬OS | AI F&B SaaS |
| 900176: CCP | 위생 AI 연동 |
| 900177: 이 문서 | AI Gateway 설계 |
