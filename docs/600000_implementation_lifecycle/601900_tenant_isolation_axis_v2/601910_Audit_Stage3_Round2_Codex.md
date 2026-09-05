# 601910_Audit_Stage3_Round2_Codex.md

DocumentType: Audit
Status: Draft
Lifecycle: Audit
Last Updated: 2026-09-05
Verifier: A — Codex, 실측 축, Round 2

## §0 수행 경계

이 결과는 사용자 Round 2 지시서에 따라 독립 대화에서 수행한 검증이다. 현재 대화에 2단계 작성 및 Round 1 수행 이력·인계 맥락이 없었으며, 다른 대화의 기록을 불러오지 않았다. 세션 분리 요건은 `000701_Guide_Controlled_AI_Development_Pipeline.md` §47.1과 사용자 지시를 적용했다. 외부 세션의 내부 상태를 별도로 증명했다는 뜻은 아니다.

금지 파일 `601906`·`601907`·`601908` 및 `601911`·`601912`, `601800` 대역은 열지 않았다. `601910`은 생성 전 존재 여부만 확인했고 기존 파일은 없었다. 허용된 근거 안의 해당 번호 인용은 읽었지만 그 파일로 이동하지 않았다. `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` §2의 권위보류 경계를 유지했다.

결과 파일 이외 생성·수정·삭제 0건, DB 쓰기 0건, 금지 업무 함수 호출 0건, git write 0건이다. 함수 본문은 `pg_proc.prosrc` 값으로만 조회했다. 검증 등급 및 A0의 닫힘 여부만 기록하며 재설계·대안·Human 처분·Stage 착수 승인 판정을 하지 않는다.

**주요 결과: blocking 3건, informational 6건. A0 15건은 닫힘 13건·부분 2건·안 닫힘 0건이다.** 발견이 0건이 아니므로 `NO CONCERNS FOUND`를 선언하지 않는다. 상세 근거는 §2~§6에 있다.

### §0.1 판정 기준과 계수

blocking은 이번 사용자 지시의 rule 번호를 그대로 사용한다: 1 모델대로 진행하면 선언 위반, 2 모델의 비선언 추가, 3 선언과 원천/601702 충돌, 4 불변조건 강제 실패, 5 601909의 종료 주장 미성립, 6 601901 실측과 불일치. 명시 유보·후속 나선·의도된 부재·표현 개선은 informational로 구별했다.

중복 finding은 한 개의 주축에만 계수했다. A0의 부분 판정과 같은 사실을 §3에서 재계수하지 않는다. A4는 A1의 반례와 A3의 물리 경계를 함께 검토했으며 추가 고유 finding 0건이다.

중요한 기록 차이: `601909_Report_Stage3_Integration.md` §7, §8은 실제로 **blocking 8건 미해소·Human 처분 대기**를 기록한다. ‘전건 처분됐다’는 이번 지시서와 `601902_Register_Stage1_Business_Rules.md` §0 개정 이력의 보강 설명을 A0의 확인 대상으로 삼았다. 601909에 존재하지 않는 ‘전건 닫힘’ 문구를 만들어 rule 5로 등급을 올리지 않았다.

## §1 판본 확인

먼저 `git ls-files --eol`을 실행해 세 파일 모두 `i/lf w/lf`임을 확인한 후 `Get-FileHash -Algorithm SHA256`으로 측정했다. `git rev-parse HEAD`는 지정 커밋 `18ad4a2a31590655d14676c646587066e938d6c8`과 일치했다.

| 문서 | 지시서 SHA-256 | 실측 | 일치 |
|---|---|---|---|
| `601902_Register_Stage1_Business_Rules.md` | `058206F4E2985EAFC8D8853AF81D573916ABF27315459014B88162F0019883B7` | `058206F4E2985EAFC8D8853AF81D573916ABF27315459014B88162F0019883B7`; w/lf | 예 |
| `601905_Diagram_Tenant_Isolation_Axis_Model.md` | `8727F3B79963EFA6FEF17126E9E87ADCC70A25332C80C3079E7BBF47E5985829` | `8727F3B79963EFA6FEF17126E9E87ADCC70A25332C80C3079E7BBF47E5985829`; w/lf | 예 |
| `601901_Register_Stage0_Evidence_Collection.md` | `9C494EA29D02A8445976BF7CF38AE79C1AE71F8F0FEB53FF9EE0F5783F0195BE` | `9C494EA29D02A8445976BF7CF38AE79C1AE71F8F0FEB53FF9EE0F5783F0195BE`; w/lf | 예 |

## §2 Round 1 처분 확인

대상 목록은 `601909_Report_Stage3_Integration.md` §2, §6, 처분 주장은 `601902_Register_Stage1_Business_Rules.md` §0 개정 이력 및 이번 지시서에서 취했다. ‘닫힘’은 원래 누락/상충의 내용 확인이며 구현 완료·Human 승인 의미가 아니다.

| # | 처분 주장 | 실제 | 판정 |
|---|---|---|---|
| T3-1 | TI-13 신설: ISOLATED 효과 선언 | `601902_Register_Stage1_Business_Rules.md` §1.13에서 containment block 및 fail closed 거부를 선언했고 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2에 거부 경로가 있다. 효과 자체의 부재는 닫혔다. 반대 방향의 추가 등치는 B-1로 별도 기록한다. | 닫힘 |
| T3-2 | TI-14 신설: Human Gate A 과금·서비스 결정 | `000221_Guide_Post_0A_Spiral_Sequence.md` §4.1의 질문에 `601902_Register_Stage1_Business_Rules.md` §1.14, §4 HD-0-A-2R-12가 상태 변경의 상업적 자동 파급 금지 및 미결 가격정책을 명시했다. 서비스는 §1.13, 모델은 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1, §5, §0.3에 대응한다. 승인 시점·나선 착수 승인을 대신 판정하지 않는다. | 닫힘 |
| T3-3 | TI-10 cross-scope attempt 복원 | `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` §19 → `601901_Register_Stage0_Evidence_Collection.md` §5.2 → `601902_Register_Stage1_Business_Rules.md` §1.10 → `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5 Q-2에 동일 항목이 있다. | 닫힘 |
| T3-4 | TI-15 신설: 000150·000190 실질 사용 | `601902_Register_Stage1_Business_Rules.md` §1.15가 원천의 역할·scope·명시적 link·경계 비전파·link flow를 선언한다. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §3, §5, §8에 반영된다. 두 문서가 단순 근거 목록에만 있던 결함은 닫혔다. | 닫힘 |
| T3-5 | TI-12 소유와 변경 구분 | `601902_Register_Stage1_Business_Rules.md` §1.12와 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1 모두 tenant_status와 isolation_state를 소유 축으로 기록하고 Subscription Lifecycle의 변경 책임과 구별한다. | 닫힘 |
| T3-6 | TI-2 SCOPE_PARTIAL_VALID 반영 | `601902_Register_Stage1_Business_Rules.md` §1.2와 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1에 해당 상태 및 scoped representation의 유효성 상태 책임이 명시됐다. 물리 값 집합 유보는 같은 절에 명시돼 있다. | 닫힘 |
| T3-7 | TI-3 partial 본문·주석 상충 제거 | `601902_Register_Stage1_Business_Rules.md` §1.3, §6 OQ-1이 네 경우를 열어 partial을 미결로 두고 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §3, §7.4가 무간선 노드로 표현한다. | 닫힘 |
| T3-8 | TI-6 key 이후 중복 판정·결과 반환·이력 보존 | `601902_Register_Stage1_Business_Rules.md` §1.6의 조건부 처리 선언은 생겼다. 그러나 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §4의 재요청=처리 완료 분기가 완료 여부 판정을 보존하지 못한다(B-2). | 부분 |
| N-1 | 모델 입력 TI 범위 갱신 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0, §0.1, §9 모두 TI-1~TI-15다. 개정 이력의 과거 범위는 역사 기록이다. | 닫힘 |
| N-2 | 모델 추적표 셀 수·계수 정정 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §8은 2열·15개 TI 행이며 TI-12도 2셀이다. 본문 계수도 15건이다. | 닫힘 |
| N-3 | Readme File List 선언·HD 계수 갱신 | `601900_Readme_Tenant_Isolation_Axis_V2.md` §9은 11건에서 14건·HD 12건으로 바뀌었으나 `601902_Register_Stage1_Business_Rules.md` §1.15, §4의 15건·HD 13건까지 반영하지 않았다. Readme §3도 TI-12에 머문다(I-1). | 부분 |
| N-4 | Q-P13 처분표 누락 해소 | `601902_Register_Stage1_Business_Rules.md` §3에 Q-P13→§6 OQ-3 행이 있고 `601901_Register_Stage0_Evidence_Collection.md` §14의 anti-pattern 강제 범위 질문과 연결된다. 열린 질문을 해결했다고 판정한 것은 아니다. | 닫힘 |
| N-5 | 601903·601905 근거 목록 추가 | `601902_Register_Stage1_Business_Rules.md` §7에 두 파일이 있다. §1.12는 발견 경로와 선언 근거를 별도로 구분한다. | 닫힘 |
| N-6 | 010640 §41의 근거 지위 구별 | `601902_Register_Stage1_Business_Rules.md` §7은 §41을 A3 발견 경로이며 TI-N 근거가 아니라고 명시한다. `601901_Register_Stage0_Evidence_Collection.md` §3.1′, §3.3과 정합한다. | 닫힘 |
| N-7 | 1단계↔2단계 순환 인용 구분 | `601902_Register_Stage1_Business_Rules.md` §1.12가 실제 근거를 `601702_Register_Stage1_Business_Rules.md` §1.27, §1.28, 601903·601905를 발견 경로로 명시한다. §7의 ‘TI-12 근거’ 축약 표기는 남지만 본문이 권위를 구별하므로 순환 선언은 관측되지 않는다. | 닫힘 |

15건 전부 판정했다. 부분 2건은 T3-8(B-2), N-3(I-1)이다.

## §3 종합

| 축 | 발견 | blocking | informational |
|---|---|---:|---:|
| A0 Round 1 처분 확인 | 1 — I-1; T3-8은 A1 B-2에 단일 계수 | 0 | 1 |
| A1 내부 정합성 | 3 — B-1, B-2, I-6 | 2 | 1 |
| A2 수직 추적성 | 2 — I-2, I-5 | 0 | 2 |
| A3 실제 PostgreSQL 가능성 | 3 — B-3, I-3, I-4 | 1 | 2 |
| A4 외부 타당성 | 추가 고유 발견 0 — B-1/B-2의 실행 반례와 §4의 물리 한계에 귀속 | 0 | 0 |
| 합계 | 9 | 3 | 6 |

### §3.1 Findings

| # | 축 | 지점 | 내용 | blocking | rule 근거 |
|---|---|---|---|---|---|
| B-1 | A1 | 601905 §2 / TI-13 | `containment block 없음 = isolation_state NONE`은 TI-13의 `ISOLATED이면 block 존재`를 역방향까지 등치한다. TI-2는 scoped containment를 별도 책임으로 두며 OQ-4는 그 block 포함 여부를 열어 두었다. tenant NONE + scoped block이라는 아직 배제되지 않은 경우에도 모델의 NONE 분기는 no containment block 조건을 통과시킨다. §7.4의 ‘포함하지 않는다고 선언하지도 않았다’와 실선의 등치가 충돌한다. 이는 scoped 설계를 지금 채우라는 요구가 아니라 열린 질문을 모델이 확정한 결함이다. **근거:** `601902_Register_Stage1_Business_Rules.md` §1.2, §1.13, §6 OQ-4; `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2, §7.4; `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` §7 | 예 | rule 2 (선언에 없는 등치). rule 1/4는 scoped block을 포함하는 경우의 조건부 영향. |
| B-2 | A1 | 601905 §4 파생 이후 / TI-6 | 분기 J는 ‘같은 key로 재요청인가’를 묻고 예이면 곧바로 ‘이미 처리된 요청 / 최초 처리의 결과 반환’으로 간다. TI-6는 먼저 이미 처리됐는지 판정하고 ‘처리됐다면’에만 반환을 요구한다. 첫 요청이 아직 처리 중이거나 transaction 결과가 불명인 재요청에는 반환할 최초 결과가 확정돼 있지 않다. 재요청 여부와 완료 여부를 같게 구현하면 선언의 확인 단계를 생략한다. 아래 읽는 법은 조건부 판정을 설명하므로 다이어그램과도 상충한다. **근거:** `601902_Register_Stage1_Business_Rules.md` §1.6; `601905_Diagram_Tenant_Isolation_Axis_Model.md` §4; `601901_Register_Stage0_Evidence_Collection.md` §9.3.2 (010660 §6·§10 채록); `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` §6, §10 | 예 | rule 1·2. 601909에 종료 기록이 없으므로 rule 5를 소급 적용하지 않음. |
| B-3 | A3 | 601905 §6 TI-13 현재 강제 | ‘격리 상태를 참조하는 함수·뷰·트리거·제약 각 0건’은 제약 실측의 범위를 바꾼다. 601901 §17.2의 0건은 ‘다른 테이블의 관련 제약’이며 §17.1에는 tenants의 chk_tenants_isolation_state가 실재한다. 이번 Q1·Q2도 해당 CHECK 1건을 반환했다. 접근 차단을 강제하는 제약이 없다는 결론과, 상태 참조 제약 자체가 0개라는 측정 주장은 다르다. 같은 모델 §6 TI-2 행의 2값 CHECK 존재와도 맞지 않는다. **근거:** `601901_Register_Stage0_Evidence_Collection.md` §17.1, §17.2; `601904_Evidence_Stage2_ERD_Survey_Codex.md` §3.3; `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6; 본 파일 §6 Q1·Q2 | 예 | rule 6 (601901 실측과 불일치). 접근 차단 구현 불가능이라고 주장하는 finding은 아님. |
| I-1 | A0 | Readme §3·§9 / N-3 | File List가 14개 선언·12개 HD, 현재 위치가 TI-12를 기록한다. 현재 판본은 15개 선언·13개 HD다. N-3의 전면 동기화는 부분 상태다. **근거:** `601900_Readme_Tenant_Isolation_Axis_V2.md` §3, §9; `601902_Register_Stage1_Business_Rules.md` §1, §4; `601909_Report_Stage3_Integration.md` §6, §7, §8 | 아니오 | informational — 계수·주소록 정합. 601909 자체는 미해소로 기록했으므로 rule 5의 ‘닫혔다’ 전제는 없음. |
| I-2 | A2 | 601901 A1′ 전체 절 구조 | 원천의 절 제목을 일부 다르게 등록했다. 예: 010650 §35는 실제 Relationship To Authority Gate인데 §9.2.1은 Manual Containment Actions로, §38은 실제 Anti-Patterns인데 Example Containment Scenarios로 적는다. 010660 §11도 실제 Timeout State Skeleton인데 §9.3.1은 Duplicate Request Handling으로 적는다. 관련 원문 인용 블록은 올바른 내용을 담으므로 이번 TI 도출의 소실로 승격하지 않는다. **근거:** `601901_Register_Stage0_Evidence_Collection.md` §9.2.1, §9.2.2, §9.3.1, §9.3.2; `010650_Policy_Failure_Containment_Circuit_Breaker.md` §35, §38; `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` §11 | 아니오 | informational — 탐색용 목차 정확도. TI와 원천의 내용 충돌 또는 현재 DB 실측 불일치로 판정하지 않음. |
| I-3 | A3 | 현재 deny-by-default 강제 범위 | 현재 isolation_state 소비 함수·policy·view·matview·trigger 정의 참조는 0개다. 대상 5테이블 RLS/FORCE가 true라도 정책은 tenant/store 비교이고 postgres/service_role은 BYPASSRLS다. SECURITY DEFINER의 소유자도 postgres다. 따라서 현재 스키마가 TI-13을 강제한다고 확인할 수 없다. 선언은 이를 현재 완료로 주장하지 않고 실제 판정 위치를 0-C에 유보한다. **근거:** `601901_Register_Stage0_Evidence_Collection.md` §17.2, §18, §20.2; `601904_Evidence_Stage2_ERD_Survey_Codex.md` §4, §5; `601902_Register_Stage1_Business_Rules.md` §1.13, §2 S6-4; `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6; 본 파일 §4.1·§6 | 아니오 | informational — 명시된 현재 간극·후속 경계. 새 모델 위반과 기존 구현 미완을 구별. |
| I-4 | A3 | TI-15.4 link data flow 물리 검증 한계 | 명시한 catalog 이름·컬럼 검색에서 cross-business link/federation 객체는 검출되지 않았다. 기존 tenant/store 식별자와 접근 통제 기능은 있으므로 CatchMenu 내 요청의 상태 기반 거부에 물리적 불가능성은 확인되지 않았다. 그러나 외부 링크, 이미 전달된 데이터, 외부 추론 관계까지 이 DB 조회만으로 중단을 입증하지 못한다. 이름 검색 0건을 모든 간접 경로 부재로 확대하지 않는다. **근거:** `601902_Register_Stage1_Business_Rules.md` §1.15, §5; `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0.3, §5; `601901_Register_Stage0_Evidence_Collection.md` §21.1 (000190 행); `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` §20, §27; 본 파일 §4.2·§6 | 아니오 | informational — 물리 link·federation은 명시 유보. §0.3의 link 노드 부재를 blocking으로 삼지 않음. |
| I-5 | A2 | TI-15.4 원천→Human 선언의 단계 | 000190 §27의 직접 조건은 link 자체가 suspended/invalidated인 경우다. tenant ISOLATED가 연결 link의 flow를 막는다는 연결 전제는 TI-13·TI-15 및 HD-13의 새 Human 적용 판단이다. 원천에서 tenant 상태와 link 상태의 자동 등가관계가 직접 채록된 것은 아니다. 선언은 실제 link status 변경을 요구하지 않으므로 원천 충돌은 확인되지 않는다. **근거:** `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` §27; `601901_Register_Stage0_Evidence_Collection.md` §9.2 (000190 채록); `601902_Register_Stage1_Business_Rules.md` §1.13, §1.15, §4 HD-0-A-2R-13 | 아니오 | informational — 도출의 출처 구별. 원천보다 구체적인 Human 적용 선언 자체를 rule 3 위반으로 보지 않음. |
| I-6 | A1 | 601905 §5 Q-7 | Q-7의 ‘승인 주체와 발동 actor의 비동일성’은 문장만 보면 발동자의 공동 승인 참여까지 제외하는 것처럼 읽힌다. 그러나 §2 note와 TI-4는 ‘자기 단독 승인 금지’를 명시하고 있어, 전체 모델의 새로운 참여 금지 선언으로 단정하지 않는다. **근거:** `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2, §5 Q-7; `601902_Register_Stage1_Business_Rules.md` §1.4; `601903_Evidence_Stage2_ERD_Survey_Cursor.md` §2 TI-4-f | 아니오 | informational — 국소 표현의 강도. 본문의 명시 조건으로 해석 가능. |

### §3.2 반례의 범위

**B-1:** `601902_Register_Stage1_Business_Rules.md` §1.13이 선언한 논리는 `ISOLATED ⇒ containment block`이다. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2는 `NONE = no containment block`을 더한다. `601902_Register_Stage1_Business_Rules.md` §6 OQ-4 및 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §7.4 OQ-4가 scoped block 포함 여부를 미정으로 두므로, 이 등치는 해당 미정을 해결한 것처럼 읽히는 실제 논리 추가다. NONE일 때 최종 접근을 즉시 허용한다고 과장하지 않는다. 모델도 나머지 조건을 검사하지만, containment 조건 자체를 넘겨버리는 지점이 문제다.

**B-2:** 첫 요청 A가 아직 진행 중인데 동일 key의 B가 도착하는 상황은 `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` §6의 `IDEMPOTENCY_DUPLICATE_IN_PROGRESS`가 명시한다. `601901_Register_Stage0_Evidence_Collection.md` §9.3.2도 이를 채록한다. 이때 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §4의 J→DUP 경로는 처리 완료로 분류해 최초 결과 반환을 명시한다. 실제 중복 transaction을 실행한 관측이 아니라, 모델 분기와 `601902_Register_Stage1_Business_Rules.md` §1.6의 조건을 대조한 반례다. 저장 위치·잠금·반환 형식·보존 기간을 지금 확정하라는 지적이 아니다.

**B-3:** `601901_Register_Stage0_Evidence_Collection.md` §17.1의 CHECK 1개와 §17.2의 다른 테이블 관련 제약 0개는 동시에 참이다. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6의 TI-13 행은 후자의 한정을 탈락시켰다. ‘현재 접근 차단 소비자가 없다’는 핵심 관측은 그대로 성립한다. rule 6에 의해 측정 서술 오류를 blocking으로 분류한 것이며, CHECK 하나가 접근 차단을 제공한다고 해석하지 않는다.

## §4 실측 및 외부 타당성

### §4.1 TI-13 — 가능한 것과 현재 강제되는 것

측정 시각은 2026-09-05 13:32:32 UTC(22:32:32 KST), PostgreSQL은 17.6, database/current_user는 postgres다. 두 접속 모두 `default_transaction_read_only=on`을 반환했다. 최신 migration은 `0171_merchant_account_foundation.sql`, success=true, applied_at=`2026-08-30 11:46:47.552241+00`다. 실행 SQL은 §6 Q1·Q2에 전부 기록했다.

| 측정 항목 | 결과 | 대조 |
|---|---|---|
| isolation_state 컬럼 | text, NOT NULL, DEFAULT NONE | `601901_Register_Stage0_Evidence_Collection.md` §17.1 일치 |
| isolation_state CHECK | tenants에 1건, NONE/ISOLATED | `601901_Register_Stage0_Evidence_Collection.md` §17.1, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §3.3 일치 |
| isolation_state 문자열 소비 | catchmenu 함수 0, policy 0, view 0, matview 0, 사용자 trigger 정의 0 | `601901_Register_Stage0_Evidence_Collection.md` §17.2, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §5.1의 소비자 부재와 일치 |
| 대상 5테이블 | RLS=true, FORCE=true; tenant/store policy 각 1개 | `601904_Evidence_Stage2_ERD_Survey_Codex.md` §4.1 일치 |
| 직접 SELECT/UPDATE 권한 | 대상 5테이블에서 postgres=true; anon/authenticated/service_role=false | `601904_Evidence_Stage2_ERD_Survey_Codex.md` §4.2 일치. 이번 측정은 SELECT/UPDATE만 확인 |
| role 특성 | postgres/service_role BYPASSRLS=true; anon/authenticated=false | `601904_Evidence_Stage2_ERD_Survey_Codex.md` §4.2 일치 |
| isolate_tenant | SECURITY DEFINER, owner=postgres, EXECUTE postgres/authenticated, md5 f53ea7f556e89cec883b9ca6b482ca3e | `601901_Register_Stage0_Evidence_Collection.md` §18, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §5.1 일치 |
| 금지 7함수 본문 md5 | 7건 모두 `601901_Register_Stage0_Evidence_Collection.md` §21과 일치 | Q2. 본문 조회만 했고 호출하지 않음 |
| audit | 16컬럼, 자유형 event_detail JSONB, 필수 context key CHECK 없음 | `601901_Register_Stage0_Evidence_Collection.md` §20.1, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §3.3, §5 일치 |
| idempotency | UNIQUE(tenant_id,key_domain,idempotency_key); 처리 상태 CHECK에 PROCESSING/COMPLETED 등 존재; 참조 함수 intake_delivery_order 1건 | `601901_Register_Stage0_Evidence_Collection.md` §20.3, §20.4, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §5.3 일치 |
| provider merchant / SaaS account | pos_store_configs.merchant_id=text; stores.merchant_account_id=uuid | `601904_Evidence_Stage2_ERD_Survey_Codex.md` §2 TI-7의 identity 구별 관측과 일치 |

PostgreSQL 17은 행 접근에 Boolean 정책을 평가하고 다른 행/테이블을 참조할 수 있으므로, tenant 상태를 접근 조건으로 사용하는 것 자체에 기술적 불가능성은 없다. 다만 BYPASSRLS role은 RLS를 우회하므로 현재 FORCE=true만으로 전체 경로 강제를 입증할 수 없다. 이는 [PostgreSQL 17 공식 문서 §5.9 Row Security Policies](https://www.postgresql.org/docs/17/ddl-rowsecurity.html)의 동작과 Q1·Q2 catalog에 근거한 가능성 판단이다. 정책·ACL 설계를 이 결과에서 제안하거나 적용하지 않았다.

현재 `current_tenant_id` 본문은 JWT app_metadata의 tenant_id만 해석하며 isolation_state를 읽지 않는다. `isolate_tenant`는 여전히 tenant_status에 ISOLATED/ACTIVE를 쓰고 isolation_state를 참조하지 않는다. 따라서 **현재 라이브 스키마가 TI-13을 강제한다는 증거는 없고, 강제 수단을 구현하는 것은 PostgreSQL에서 가능하나 그 구현의 충분성은 아직 검증되지 않았다.** 근거: `601901_Register_Stage0_Evidence_Collection.md` §17, §18, `601904_Evidence_Stage2_ERD_Survey_Codex.md` §4, §5, 본 파일 §6.

### §4.2 TI-15.4 — link data flow

`000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` §27은 suspended/invalidated link의 data flow·inferred relationship 지속을 금지한다. `601902_Register_Stage1_Business_Rules.md` §1.15는 tenant 격리 기간에 연결 link의 flow를 차단하되 다른 business 자체 운영은 격리하지 않는다고 적용한다.

Q1·Q2의 명시된 이름 검색은 관련 relation/column을 찾지 못했다. 이는 검색 패턴에 대한 0건이며 동적 SQL·다른 명칭의 간접 구현·외부 시스템 전체의 부재를 증명하지 않는다. `601901_Register_Stage0_Evidence_Collection.md` §21.1도 cross-business 전체 객체를 실측 범위 밖으로 기록했다. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6 TI-15의 전역적 ‘객체 0건’은 이 제한을 넘어 독립 검증된 것으로 승계하지 않았다.

CatchMenu tenant-scoped object에 도달하는 요청의 상태 기반 거부는 §4.1과 같은 기술적 수단으로 표현 가능하다. 그러나 **실제 link의 양 끝, 이미 전달된 projection/cache, 외부에서의 inferred relationship 차단은 이 catalog 검증만으로 입증되지 않는다.** 이를 물리적 불가능이라고도 단정하지 않는다. `601902_Register_Stage1_Business_Rules.md` §1.15, §5가 link 물리 구조·상태값·federation을 유보하고 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0.3이 link 노드의 의도된 부재를 명시했으므로 I-4로 기록했다.

### §4.3 601904와의 차이 및 A4 판단

`601904_Evidence_Stage2_ERD_Survey_Codex.md` §0, §2, §6은 TI-1~TI-11 당시 조사다. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6의 TI-12~TI-15 행까지 원래 조사에서 실측된 것처럼 승계하지 않았다. TI-13의 상태 참조·CHECK는 이번에 재측정했고(B-3), TI-15의 전역 부재는 제한적 검색만으로 확정하지 않았다(I-4).

`manage_subscription`의 SUSPEND/ACTIVATE 분기에는 isolate_tenant 호출이 실제 본문에 남는다. `601901_Register_Stage0_Evidence_Collection.md` §19.2의 잘못된 named argument `p_reason`과 일치한다. 따라서 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6 TI-14의 ‘격리와 과금을 잇는 객체 0건’은 **isolation_state 컬럼과의 연동 0건** 범위에서만 확인 가능하다. 구독 함수와 격리 명칭 함수의 정적 연결 자체가 0건인 것은 아니다. 상업적 결과의 실제 발생을 실행 관측한 것은 아니며, `601902_Register_Stage1_Business_Rules.md` §1.14의 새 선언 위반을 이번 DB 실행으로 판정하지 않았다.

A4에서 ‘모델대로 구현하면 모든 TI를 이미 강제한다’고 결론 내릴 수 없다. B-1·B-2의 실제 조건 불일치가 있으며, TI-13·TI-15의 물리 경로는 명시 유보 상태다. 반대로 현재 구현의 간극을 모델 자체의 새로운 blocking으로 중복 계산하지 않았다. TI-1·TI-11의 문서 게이트, TI-14의 과금 노드 부재, TI-15의 link 노드 부재는 `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0.3, §7, §8의 경계를 적용했다.

## §5 TI-N 추적표

‘완결’은 **원천·증거·선언·모델의 추적**을 뜻하며 runtime 강제 완료를 뜻하지 않는다. 각 행의 선언 연결점은 `601902_Register_Stage1_Business_Rules.md` §1.N이다. 601901 밖에서 새로 들어온 근거는 이를 숨기지 않고 별도 표기했다.

| TI-N | 601901 근거 | 601905 표현 | 완결 |
|---|---|---|---|
| TI-1 | `601901_Register_Stage0_Evidence_Collection.md` §3.1′, §3.3, §14 Q-P6·Q-P12 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6, §7.3 D-1, §8 | 완결 — 정책 채택은 문서 층위. 그리지 않은 사유가 명시됨 |
| TI-2 | `601901_Register_Stage0_Evidence_Collection.md` §6.2 (010640 §6), §9.2.2 (010650 §4·§18·§36), §14 Q-P10 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1, §5 Q-9, §7.4 OQ-4 | 책임·scope 유효성 추적 완결. 접근 등치 관련 B-1 별도 |
| TI-3 | `601901_Register_Stage0_Evidence_Collection.md` §9.1.2 (010630 §2·§6·§9·§28), §9.2.2 (010650 §35), §14 Q-P9 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2, §3, §5 Q-4, §7.4 OQ-1 | 완결 — partial은 미결로 보존 |
| TI-4 | `601901_Register_Stage0_Evidence_Collection.md` §9.1.2 (010630 §18), §9.2.2 (010650 §35·§38) | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2, §5 Q-7 | 완결 — 자기 단독 승인 금지. Q-7 표현 I-6 |
| TI-5 | `601901_Register_Stage0_Evidence_Collection.md` §9.2.2 (010650 §35) | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2 비대칭 | 완결 |
| TI-6 | `601901_Register_Stage0_Evidence_Collection.md` §9.3.2 (010660 §2·§4·§5·§6·§10), §14 Q-P11 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §4, §5 Q-5·Q-6 | 부분 — 선언의 완료 확인 조건이 분기에서 소실(B-2) |
| TI-7 | `601901_Register_Stage0_Evidence_Collection.md` §6.2 (010640 §4), §8.2 (000170 §3·§4), §14 Q-P4 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5 Q-10, §6, §7.2 P-7 | 완결 — 별도 identity·mapping, 물리 구조 유보 |
| TI-8 | `601901_Register_Stage0_Evidence_Collection.md` §6.2 (010640 §2·§42), §6.3, §14 Q-P5 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5 Q-2·Q-3, §7.2 P-8 | 완결 — 필요한 context 묶음. 물리 운반 방식 유보 |
| TI-9 | `601901_Register_Stage0_Evidence_Collection.md` §5.2 (010004 §20) | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5 Q-8·Q-9, §7.4 OQ-2 | 완결 — 인정 사유와 자동 승격 금지 보존 |
| TI-10 | `601901_Register_Stage0_Evidence_Collection.md` §5.2 (010004 §19), §20.1, §21.1 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5 Q-1·Q-2, §6 | 완결 — cross-scope attempt 복원 |
| TI-11 | `601901_Register_Stage0_Evidence_Collection.md` §5.2 (010004 §24·§29), §5.1 (원천 §26 위치) | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §6, §7.2 P-10, §8 | 완결 — Stage 7 전 선언 의무의 추적. 11항 작성 완료 판정 아님 |
| TI-12 | `601901_Register_Stage0_Evidence_Collection.md` §10.1·§10.2 (601702 §1.27·§1.28), §17·§18 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1, §6, §8 | 완결 — 상태축 독립·소유/변경 구별 |
| TI-13 | `601901_Register_Stage0_Evidence_Collection.md` §5.2 (010004 §7), §17.1·§17.2 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §2, §6, §7.4 OQ-4 | 부분 — 효과 거부는 존재. 역방향 등치 B-1·측정 범위 B-3 |
| TI-14 | `601901_Register_Stage0_Evidence_Collection.md` §5.2 (서비스 차단 원천), §17·§19 (상태·구독 기존 경로); Human Gate A는 601901 외 추가 근거 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0.3, §1, §5, §6, §8 | 완결 — 과금 정책은 601902 §1.14·§4 HD-12의 직접 Human 선언; 000221 §4.1 |
| TI-15 | `601901_Register_Stage0_Evidence_Collection.md` §7.2 (000150 §12·§22·§23), §9.2 (000190 §3·§10·§17·§20·§27) | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §0.3, §3, §5, §6, §8 | 완결 — 원천 적용 선언 추적. 물리 강제 미입증 I-4, 도출 구별 I-5 |

15건 전부 기록했다. TI-14의 Human Gate A 직접 근거는 `000221_Guide_Post_0A_Spiral_Sequence.md` §4.1이며, 가격·보상정책의 세부값이 601901에 있다고 주장하지 않는다. `601902_Register_Stage1_Business_Rules.md` §1.14, §4 HD-0-A-2R-12가 독립 Human 결정을 기록했다.

### §5.1 601702 45개 선언 대조 범위

45개 선언은 단순 §1.28 한 곳으로 환원하지 않고 아래 의미군으로 대조했다. 같은 주제의 직접 연결과 이번 모델이 변경하지 않는 축을 구분한다. 새 모델 때문에 원천 선언을 위반하는 별도 사례는 이 대조에서 확인되지 않았다. 이는 후속 구현의 무조건 통과를 의미하지 않는다.

| 601702 선언 | 대조한 경계 | 현재 모델과의 관계 |
|---|---|---|
| `601702_Register_Stage1_Business_Rules.md` §1.1~§1.6 | Person, ownership, LegalEntity·조직역할·가맹계약 독립 | `601902_Register_Stage1_Business_Rules.md` §1.3, §1.8, §1.15가 조직/지분에서 격리 권한을 자동 추론하지 않음. 관계 cardinality 변경 없음 |
| `601702_Register_Stage1_Business_Rules.md` §1.7~§1.14 | 고객 내부/프랜차이즈 횡단, Group·Franchise OS·CatchMenu, Person의 세계별 scope, MerchantAccount 독립 | `601902_Register_Stage1_Business_Rules.md` §1.7, §1.8, §1.15, `601905_Diagram_Tenant_Isolation_Axis_Model.md` §3, §5의 scope·link 경계와 대조 |
| `601702_Register_Stage1_Business_Rules.md` §1.15~§1.21 | JWT 신원, Person/User/Staff, 0-B 인계, Role+Permission+Scope, taxonomy 미결, CatchMenu 내부 조직 | `601902_Register_Stage1_Business_Rules.md` §1.3, §1.8, §1.13, §1.15가 권한을 요구하고 세부 actor/role 구현은 유보. `601905_Diagram_Tenant_Isolation_Axis_Model.md` §3, §7가 새로운 identity 연결을 선언하지 않음 |
| `601702_Register_Stage1_Business_Rules.md` §1.22~§1.26 | Tenant 1:1 MerchantAccount, LegalEntity 독립, Store 구조 부모와 tenant 격리 scope | `601902_Register_Stage1_Business_Rules.md` §1.2, §1.7, §1.8, `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1, §5는 containment 모델이며 구조 부모·cardinality를 새로 만들지 않음 |
| `601702_Register_Stage1_Business_Rules.md` §1.27~§1.30 | Store 3상태축·계층 6상태축, company 정규화, OperatingGroup 미결 | `601902_Register_Stage1_Business_Rules.md` §1.12, `601905_Diagram_Tenant_Isolation_Axis_Model.md` §1의 소유/변경/명시 precondition과 대조 |
| `601702_Register_Stage1_Business_Rules.md` §1.31~§1.36 | 검증된 LegalEntity, operator_type, link 비권한, 시점 관계·snapshot·tenant 이전 | `601902_Register_Stage1_Business_Rules.md` §1.7, §1.8, §1.15의 mapping·scope·비전파와 대조. 격리를 소유자 변경·tenant 이전으로 만들지 않음 |
| `601702_Register_Stage1_Business_Rules.md` §1.37~§1.39 | Person 식별자, 사람 is_active 제거, 역할에서 지분 제거 | `601905_Diagram_Tenant_Isolation_Axis_Model.md` §5의 개념 actor가 이 물리 식별자 변경을 되돌리는 선언 없음 |
| `601702_Register_Stage1_Business_Rules.md` §1.40~§1.43 | SaaS 구조, 플랫폼/tenant 데이터, 네 시스템, provider tenant/store 귀속 | `601902_Register_Stage1_Business_Rules.md` §1.7, §1.8, §1.13, §1.15와 대조. 외부 link 실측 한계는 I-4 |
| `601702_Register_Stage1_Business_Rules.md` §1.44~§1.45 | MerchantAccount canonical 객체·provisioning 1:1·기본 폐쇄·0-C 책임 | `601902_Register_Stage1_Business_Rules.md` §1.7, §1.12, §1.13, §5가 identity를 바꾸거나 app GRANT를 승인하지 않음 |

## §6 실행 쿼리 전문

접속은 지정 명령을 사용했고 `-X`(psql 시작 파일 제외), Q2에는 `-A -t`(출력 서식)만 추가했다. SQL은 PowerShell here-string을 표준입력으로 전달했다. 아래 Q1·Q2는 **실행한 SQL 전체**다. Q1 출력에서 긴 prosrc 표가 잘려 Q2에서 unaligned로 다시 조회했다. SQL 실행 오류는 두 접속 모두 없었다.

```powershell
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -X -A -t -v ON_ERROR_STOP=1 -U postgres -d postgres
```

### §6.1 Q1 — 환경·상태 소비·policy·role·link 후보

```sql
SHOW default_transaction_read_only;
SELECT now(), version(), current_user;
SELECT filename,success,applied_at FROM catchmenu_meta.migration_history ORDER BY applied_at DESC LIMIT 1;
SELECT n.nspname,p.proname,md5(p.prosrc),p.prosecdef,p.proacl,p.proconfig,p.prosrc FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%' AND p.proname IN ('isolate_tenant','manage_subscription','current_tenant_id');
SELECT 'function' AS kind,count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%' AND p.prosrc ILIKE '%isolation_state%'
UNION ALL SELECT 'policy',count(*) FROM pg_policies WHERE schemaname LIKE 'catchmenu%' AND coalesce(qual,'')||coalesce(with_check,'') ILIKE '%isolation_state%'
UNION ALL SELECT 'view',count(*) FROM pg_views WHERE schemaname LIKE 'catchmenu%' AND definition ILIKE '%isolation_state%';
SELECT c.oid::regclass,k.conname,pg_get_constraintdef(k.oid) FROM pg_constraint k JOIN pg_class c ON c.oid=k.conrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname LIKE 'catchmenu%' AND pg_get_constraintdef(k.oid) ILIKE '%isolation_state%';
SELECT schemaname,tablename,policyname,roles,cmd,qual,with_check FROM pg_policies WHERE tablename IN ('tenants','security_audit_log','idempotency_keys','offline_queue','security_threats');
SELECT rolname,rolsuper,rolbypassrls FROM pg_roles WHERE rolname IN ('postgres','authenticated','anon','service_role');
SELECT table_schema,table_name,column_name,data_type,is_nullable,column_default FROM information_schema.columns WHERE (table_schema='catchmenu_hq' AND table_name='tenants' AND column_name IN ('tenant_status','isolation_state')) OR (table_schema LIKE 'catchmenu%' AND (table_name ~* 'cross_business|federation|business_link|containment|quarantine' OR column_name ~* 'business_scope|link_state|isolation_state')) ORDER BY 1,2,3;
```

### §6.2 Q2 — 본문 재조회·잔여 참조·실효권한·제약·identity

```sql
SHOW default_transaction_read_only;
SELECT p.oid::regprocedure,p.proowner::regrole,p.prosecdef,p.proacl,md5(p.prosrc) FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%' AND p.proname IN ('isolate_tenant','manage_subscription','detect_threat','verify_security_token','gateway_audit_entry','record_van_transaction','check_staff_permission');
SELECT proname,prosrc FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='catchmenu_common' AND proname IN ('isolate_tenant','manage_subscription','current_tenant_id');
SELECT 'matview' AS kind,count(*) FROM pg_matviews WHERE schemaname LIKE 'catchmenu%' AND definition ILIKE '%isolation_state%'
UNION ALL SELECT 'trigger',count(*) FROM pg_trigger t JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname LIKE 'catchmenu%' AND NOT t.tgisinternal AND pg_get_triggerdef(t.oid) ILIKE '%isolation_state%';
SELECT c.oid::regclass,c.relrowsecurity,c.relforcerowsecurity,c.relowner::regrole,r.rolname,has_table_privilege(r.rolname,c.oid,'SELECT') AS sel,has_table_privilege(r.rolname,c.oid,'UPDATE') AS upd FROM pg_class c CROSS JOIN pg_roles r WHERE c.oid IN ('catchmenu_hq.tenants'::regclass,'catchmenu_common.security_audit_log'::regclass,'catchmenu_common.idempotency_keys'::regclass,'catchmenu_common.security_threats'::regclass,'catchmenu_common.offline_queue'::regclass) AND r.rolname IN ('postgres','authenticated','anon','service_role') ORDER BY 1,5;
SELECT c.oid::regclass,k.conname,k.contype,pg_get_constraintdef(k.oid) FROM pg_constraint k JOIN pg_class c ON c.oid=k.conrelid WHERE c.oid IN ('catchmenu_hq.tenants'::regclass,'catchmenu_common.security_audit_log'::regclass,'catchmenu_common.idempotency_keys'::regclass,'catchmenu_common.security_threats'::regclass,'catchmenu_common.offline_queue'::regclass) ORDER BY 1,3,2;
SELECT table_schema,table_name,column_name,data_type FROM information_schema.columns WHERE (table_schema='catchmenu_common' AND table_name='security_audit_log') OR (table_schema='catchmenu_integrations' AND table_name='pos_store_configs' AND column_name='merchant_id') OR (table_schema='catchmenu_hq' AND table_name='stores' AND column_name='merchant_account_id') ORDER BY 1,2,3;
SELECT n.nspname,p.proname FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%' AND p.prosrc ILIKE '%idempotency_keys%';
SELECT n.nspname,c.relname,c.relkind FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace WHERE n.nspname LIKE 'catchmenu%' AND c.relname ~* 'cross_business|federation|business_link|containment|quarantine';
```

### §6.3 해석 한계

catalog 및 함수 본문 정적 검색이다. 사용자 업무 함수 실행, 상태 전이, retry 경쟁, 외부 link 송수신은 수행하지 않았다. 따라서 본 파일의 반례는 논리 대조이며 운영 사건 발생 주장과 구별한다. 문자열 검색의 0건은 검색한 schema·객체 종류·표현에 대한 값이다. 실제 함수의 동적 SQL·애플리케이션·외부 시스템 전체에 대한 무경로 증명이 아니다. `601904_Evidence_Stage2_ERD_Survey_Codex.md` §5.5의 미실행 경계 및 `601901_Register_Stage0_Evidence_Collection.md` §21.1의 cross-business 측정 범위와 같은 구별을 유지한다.

## §7 근거 문서 목록

| 파일 | 사용 절 | 역할 |
|---|---|---|
| `600021_Governance_Tenant_Isolation_Axis_Authority_Reset.md` | §1·§2 | 허용된 근거 |
| `601702_Register_Stage1_Business_Rules.md` | §1.1~§1.45·§2 | 허용된 근거 |
| `601900_Readme_Tenant_Isolation_Axis_V2.md` | §3·§9 | 허용된 근거 |
| `601901_Register_Stage0_Evidence_Collection.md` | §3~§10·§14·§16~§21 | 허용된 근거 |
| `601902_Register_Stage1_Business_Rules.md` | §0~§7 | 검증 대상 |
| `601903_Evidence_Stage2_ERD_Survey_Cursor.md` | §2~§6 | 허용된 근거 |
| `601904_Evidence_Stage2_ERD_Survey_Codex.md` | §0~§6 | 허용된 근거 |
| `601905_Diagram_Tenant_Isolation_Axis_Model.md` | §0~§9 | 검증 대상 |
| `601909_Report_Stage3_Integration.md` | §0~§9 | 목록만 취함; 판정 승계 없음 |
| `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | §7·§19·§20·§24·§26·§29 | 허용된 근거 |
| `010640_Policy_Tenant_Scope_Envelope.md` | §2·§4~§6·§42 | 허용된 근거 |
| `010630_Policy_Authority_Capability_Gate.md` | §2·§6·§18·§21·§22·§28 | 허용된 근거 |
| `010650_Policy_Failure_Containment_Circuit_Breaker.md` | §2·§4·§35·§36·§38 | 허용된 근거 |
| `010660_Policy_Idempotency_Retry_Replay_Reconciliation.md` | §2·§4~§6·§10·§11 | 허용된 근거 |
| `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | §12·§22·§23 | 허용된 근거 |
| `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | §3·§4 | 허용된 근거 |
| `000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | §3·§10·§17·§20·§27 | 허용된 근거 |
| `000221_Guide_Post_0A_Spiral_Sequence.md` | §4.1 | 허용된 근거 |
| `600010_Tracker_Spiral_Workpacket_Progress.md` | §0·§1.1 | Human Gate A 역사 기록 확인 |
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §47.1 | 독립 세션·단계 경계 |
| PostgreSQL 17 공식 문서 | §5.9 Row Security Policies | 접근 통제의 가능성·BYPASSRLS 의미 |
| 라이브 PostgreSQL catalog | 본 파일 §6 Q1·Q2 | read-only 재측정 |

최종 결과는 §3의 **blocking 3건·informational 6건**이며, 종료·수정 방법·착수 허가의 처분은 이 Audit에서 내리지 않는다.

