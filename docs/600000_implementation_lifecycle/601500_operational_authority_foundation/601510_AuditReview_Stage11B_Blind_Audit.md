# AuditReview — 601500 Operational Authority Foundation
## Stage 11B (완전독립 ChatGPT 블라인드감사) — 2026-08-10

**판정: BLOCK** (전체 재설계 아님, 4개 조건 충족시 즉시
APPROVE_WITH_NOTES 전환 가능한 좁은 범위)

### 1. tenant_status/isolation_state 분리 — ACCEPT
설계 방향 타당. 다만 "서비스가능여부 = lifecycle허용상태 AND
isolation_state=NONE"이라는 공통판정규칙이 시스템 전체에서
일관되게 적용돼야 함(일부RPC가 한쪽만 확인하면 격리가 뚫림).
TERMINATED→ACTIVE 역전이 가능 여부, CANCELLED와 TERMINATED의
차이 명시 필요. 격리해제가 tenant_status를 변경해서는 안 됨
(TERMINATED+ISOLATED에서 isolation만 NONE으로 바꿔서 tenant가
살아나면 안 됨).

### 2. LegalEntity 중심 모델 — APPROVE_WITH_NOTES (확인필요)
Person/Owner→LegalEntity→Store 방향은 단순 User→Company→Store
보다 현실을 잘 반영. Company를 entity_type='CORPORATION'으로
보는 것도 합리적.

다만 핵심 미비점: **대표자(Representative)와 소유자(Owner)는
같은 개념이 아님** - 대표이사가 지분0%일 수 있고 60%주주가
대표가 아닐 수도 있음. legal_entity_representatives의 존재가
공동소유(지분) 표현을 의미하지 않음. 다음 3가지는 각각 독립
개념: Person↔LegalEntity:ownership(지분소유) / :representation
authority(대표권) / :employment role(역할). 현재 소유권(지분)
자체를 모델링하는 구조가 없음.

추가: business_registration_number를 법적주체의 정체성 자체로
보면 위험 - 개인사업자는 사업체와 자연인이 완전히 별개 법인격이
아니고, 하나의 법인이 여러 사업장/등록단위를 가질 수 있음.
Legal Entity와 Business/Tax Registration을 1:1로 가정하지
않는 게 안전. MVP는 1:1로 시작해도, "사업자등록번호는 등록의
식별자이지 법적정체성의 근본 존재론이 아니다"라는 경계를 문서에
남길 것.

### 3. GRANT없음+SECURITY DEFINER — BLOCKER
Base Table=Closed / RPC=Open 구조 자체는 타당. 문제는 함수
소유자가 "시스템의 일부"인데 이걸 문서경고로만 남긴 것.

최소 요구 방어선 5개:
1. SECURITY DEFINER 함수owner를 전용 NOLOGIN owner role로
   명시적 고정
2. 함수생성 후 ALTER FUNCTION...OWNER TO...를 migration에 명시
3. 함수 EXECUTE 권한을 PUBLIC에서 제거, 필요 application role만
4. search_path를 함수별 고정 + 테이블/함수명 schema-qualified
5. CI/migration verification에서 pg_proc.proowner/ACL/prosecdef
   검사 + 실제 application role로 smoke test

**특히 search\_path가 owner보다 더 위험할 수 있음**: SECURITY
DEFINER 함수에 부적절한 search_path가 붙으면 "접근불능"이 아니라
"권한상승 취약점"으로 발전 가능(호출자가 자기 search_path 앞쪽
스키마에 동명 가짜테이블을 만들면 함수가 그걸 참조, postgres
권한으로 실행됨).

추가: SECURITY DEFINER는 RLS를 우회하므로, 이 4개 테이블이
tenant간 공유영역이라면 함수 내부에서 tenant authority를 직접
검증해야 함. base table GRANT 제거가 multi-tenant isolation을
자동보장하지 않음 - 잘못 작성된 SECURITY DEFINER 하나가 "tenant
A가 tenant B의 legal entity를 조회"하는 confused deputy가 될
수 있음(오늘 미확인 위험).

### 4. SOLE대표 2명 문제 — 단독으로는 NOTE 가능, 종합시 BLOCK
"CHECK로 못막는다"≠"DB로 못막는다". partial unique index로
충분히 방어 가능:
UNIQUE (legal_entity_id) WHERE representation_type='SOLE' AND
active=true
(더 복잡한 공동대표 조합-A+B서명/A또는B+C 등-은 MVP범위 밖,
지금은 이미 정의한 SOLE 불변조건만 DB가 보장하면 됨). 시드0건인
지금이 가장 싸게 고칠 시점.

### 추가 발견 위험 4가지

1. **stores.legal\_entity\_id의 시간성**: 운영법인이 A→B로 바뀌면
   단순FK변경이 과거 주문/정산/세금자료까지 B가 운영한 것처럼
   재해석될 위험. effective_from/effective_to 또는 거래시점
   snapshot 필요할 가능성.
2. **삭제정책**: legal_entity가 상위권위객체라면 ON DELETE
   CASCADE는 위험. inactive/dissolved lifecycle이 적절.
3. **기존데이터 backfill**: 기존 tenant에 무조건 ACTIVE/NONE
   default 부여가 "사실상 권한자동승인 migration"이 될 수 있음
   - 별도 검증 필요.
4. **"Owner"라는 이름의 의미 모호성**: SaaS에서 흔한 "tenant
   admin/account owner"와 법적 "beneficial owner/shareholder/
   proprietor"는 다른 의미. 어느 쪽인지 명확히 해야 향후 권한
   시스템에서 혼란 방지.

### 최종 판정

Architecture direction: 대체로 좋음.
1번 ACCEPT / 2번 APPROVE_WITH_NOTES(확인필요) / 3번 BLOCKER /
4번 단독NOTE가능하나 종합시BLOCK. **전체: BLOCK.**

재승인 조건 4가지:
1. SECURITY DEFINER owner를 전용NOLOGIN역할로 고정+CI/migration
   drift검증
2. SECURITY DEFINER의 search_path/PUBLIC EXECUTE/tenant경계
   검증
3. SOLE representative 불변조건을 partial unique index로 DB
   enforcement
4. 문서에서 legal ownership/representation/person role/
   business registration identity가 서로 다른 개념임을 명확히
   선언

재설계 워크패킷 아님 - 보안경계와 법적데이터모델 불변조건을
한단계 더 잠그면 괜찮은 0-A 기반.
