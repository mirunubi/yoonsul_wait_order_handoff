-- 0101_create_project_background_docs.sql
-- Purpose: Project background documentation
--          registration in knowledge base.
--          프로젝트 비전/배경/설계 원칙 문서화.
--          pgvector RAG 검색 가능한 문서로 등록.
--          SaaS 판매 시 투자자/파트너 설명 자료 기반.
-- Depends on: 0100_create_staff_app_bootstrap_rpc.sql

-- =============================================
-- 프로젝트 배경 문서 등록
-- =============================================
insert into catchmenu_knowledge.documents (
  tenant_id, store_id,
  document_code, document_title,
  document_type, domain,
  content_ko, content_en,
  version_number, document_status,
  is_tenant_approved,
  approved_at, effective_from, created_by
) values

-- -----------------------------------------------
-- 1. 프로젝트 비전 문서
-- -----------------------------------------------
(
  '00000000-0000-0000-0000-000000000001',
  null,
  'PROJECT_VISION_001',
  'Catch Menu / Catch & Order — 프로젝트 비전',
  'GUIDE', 'PROJECT',
  $ko$
# Catch Menu / Catch & Order — 프로젝트 비전

## 1. 한 문장 정의

**Catch Menu는 음식점의 고객 진입부터 대기, 메뉴, 주문, 결제, KDS, 직원 회복, 감사 증빙, 정산 대사, AI 고객센터까지 연결하는 감사 우선형 이벤트 기반 F&B 운영 OS다.**

## 2. 이건 단순한 키오스크가 아니다

- 단순 CRUD SaaS가 아니다
- 단순 키오스크가 아니다
- 단순 테이블오더가 아니다
- 단순 모바일 메뉴판이 아니다
- 단순 POS 연동 앱이 아니다

**이것은 운영 사고 방지 시스템이다.**

## 3. 출발점

2009년 중식당 운영 중 아이폰2 출시를 보고 즉시 발견했다.
"전단지 책자는 휴대폰 안으로 들어간다."

사업자금 1~2억이 없어 설계만 하고 배달의민족에 시장을 빼앗겼다.
그로부터 15년 뒤, AI 코딩의 시대가 열렸다.
20여년 현장 갈증을 이제 코드로 꺼낸다.

## 4. 왜 지금인가

AI 시대에 무엇이 살아남는가?
- 현장을 아는 사람의 시스템이 살아남는다
- 배달의민족은 중개만 했다
- 이건 매장 자체를 바꾸는 OS다

## 5. 목표