# 601914_Audit_Stage3_Round3_Codex.md

Status: Complete
DocumentType: Audit
Lifecycle: Audit
Last Updated: 2026-09-06

## 검증 조건과 판정 범위

수행자: Codex — Verifier A, 실측 축, Round 3.

현재 대화에는 2단계 작성 및 Round 1·2 수행 이력이 없다. 최초의 잘린 Round 3 지시와 이를 대체한 완전한 지시만 전달됐으며, 이전 작업 세션의 기억·대화·검증자 원본을 불러오지 않았다. 세션 분리 확인은 현재 제공된 대화 범위에 근거한다.

601906·601907·601908·601910·601911·601912·다른 Round 3 검증자 문서 및 601800 대역 파일은 열람하지 않았다. 허용된 601901·601902·601903·601904·601905·601909·601913 안의 과거 문서 인용은 해당 허용 문서의 서술로만 읽었다. 통합 보고서 판정을 승계하지 않았다.

검증·근거 문서 수정 0건, git write 0건, DB 쓰기 0건, 금지 함수 호출 0건. 새로 생성한 파일은 이 결과 파일 1개다. 함수 본문의 INSERT/UPDATE/호출문은 pg_proc.prosrc로 읽었으며 실행하지 않았다.

**검증 결과: blocking 2건 / informational 6건. Round 2 처분 13건은 닫힘 12건 / 부분 1건(M-4). 현재 판본을 전건 해소로 판정할 수 없다.** 이는 이번 Verifier A의 검증 결과이며 Human의 통합·승인 판정을 대신하지 않는다.

## 판본 확인

먼저 git ls-files --eol로 세 파일 모두 i/lf, w/lf를 확인한 다음 실제 작업 파일 바이트의 SHA-256을 측정했다. HEAD는 지정 커밋과 일치한다.

| 문서 | 지시서 SHA-256 | 실측 | 일치 |
|---|---|---|---|
| 601901_Register_Stage0_Evidence_Collection.md | 2B15934E53EC3C2CE9CE333CAE9DC1403312F0B437493EDA63D3A3AA1E50FCAD | 2B15934E53EC3C2CE9CE333CAE9DC1403312F0B437493EDA63D3A3AA1E50FCAD | YES — w/lf |
| 601902_Register_Stage1_Business_Rules.md | 07962313E8F92D87D3F5C573989750264D53F52415771D5B57C605529F1B6EE3 | 07962313E8F92D87D3F5C573989750264D53F52415771D5B57C605529F1B6EE3 | YES — w/lf |
| 601905_Diagram_Tenant_Isolation_Axis_Model.md | 2BF8CE4F094CEDAEAAFCD90674A9B9DCDEC5ECC6F423573E66B1B81CF1A4043A | 2BF8CE4F094CEDAEAAFCD90674A9B9DCDEC5ECC6F423573E66B1B81CF1A4043A | YES — w/lf |

커밋: 6fd06fd99d53e7db94a014aba1bc8cacedb4d040. 보고서 생성 직전 재측정에서도 세 해시는 유지됐으며 tracked working-tree 변경은 없었다.

## Round 2 처분 확인

처분 주장은 이번 지시와 현재 대상 문서의 개정·보강 서술을 뜻한다. 601913 자체는 처분 전 INCOMPLETE 기록을 보존하고 있으므로 그 상태표를 현재 판정으로 사용하지 않았다.

| # | 처분 주장 | 실제 | 판정 |
|---|---|---|---|
| R2-1 | TI-13 격리 전이 예외로 해제 자기 차단 해소 | 601902 §1.13, 568행이 격리 상태 관리 전이를 거부 대상에서 제외하고 TI-3·TI-4를 유지한다. 601905 §2 TR→GATE2가 이를 표현한다. 현재 DB에 이를 수행하는 구현은 없지만 개념상 자기 차단은 제거됐다. | 닫힘 — 선언·모델 기준 |
| R2-2 | payload_hash를 key 성분에서 분리하고 conflict 차단 | 601902 §1.6은 5개 파생 입력과 별도 보존 hash를 구분한다. 601905 §4, 392·406행은 별도 보존 및 비교를 명시하고 다르면 미실행으로 흐른다. 010660 §6 및 601901 §9.3.2와 일치한다. | 닫힘 — 물리 강제는 I-4 |
| R2-3 | 15 authority 상태의 누락을 default deny로 해소 | 601902 §1.3과 601905 §3 모두 ALLOWED 외 모든 상태에서 미실행을 명시한다. 601901 §9.1.2의 010630 §6·§28과 일치한다. PARTIAL의 향후 scoped 허용 질문은 유지된다. | 닫힘 |
| R2-4 | §2가 OQ-1을 독자 확정하지 않도록 §3에 위임 | 601905 §2 note는 실행 여부를 §3에 위임한다. 읽는 법의 ALLOWED-only 문장은 현재 보강된 TI-3 default와 일치하므로 과거와 같은 무근거 확정이 아니다. | 닫힘 |
| R2-5 | TI-12 근거와 발견 경로의 순환 분리 | 601902 §1.12 근거는 601702 §1.27·§1.28이고, 601903·601905는 별도 발견 경로다. §7의 601905 행도 발견 경로라고 명시한다. | 닫힘 |
| M-1 | 근거 목록의 TI-13·TI-14·Round 1 보강 근거 누락 보충 | 601902 §7에 010004 §7, 000221, 600010, 601909가 모두 존재하며 601913도 추가됐다. | 닫힘 |
| M-2 | TI-14 착수 문서의 Stage 0 미채록 사유 명시 | 601902 §1.14, 693행 이하가 000221·600010을 원천 정책 아닌 계획·트래커로 구분하고 채록 대상 제외 판단을 명시한다. 000221 §4.1의 착수 게이트 원문도 확인했다. 실제 채록이 생겼다는 뜻은 아니다. | 닫힘 — 제외 판단의 명시 기준 |
| M-3 | 601702 §1.33 채록과 TI-15 인용 보강 | 601901 §10.2, 1862행부터 §1.33 본문이 채록됐다. 원본 601702 §1.33의 link/reference, user authority, source-of-truth 내용과 대조했다. 601902 §1.15와 §7에 근거가 추가됐다. | 닫힘 |
| M-4 | 601905가 인용하는 601910의 provenance 누락 해소 | 601905 §9, 632행에는 601910이 추가됐다. 그러나 §0.1 입력 목록과 개정 이력에는 여전히 없다. 본문 281·437·537행의 직접 인용 3곳은 유지된다. 601913 §4 M-4가 특정한 3지점 중 1지점만 보강됐다. | 부분 — B-1 |
| M-5 | TI-13의 유보 4건을 §5에 반영 | 601902 §5에 containment block 판정 위치, Safe Projection rule, policy permission 모델, surface/device 표현 4건이 모두 있다. | 닫힘 |
| M-6 | 000190 §8을 TI-15 본문에서 사용 | 601902 §1.15 원천 인용 블록에 외부 SaaS merchant가 CatchMenu 고객이며 기본적으로 Franchise OS store가 아니라는 §8의 두 문장이 있다. 601901 §9.2 및 000190 원문과 일치한다. | 닫힘 |
| M-7 | SCOPE_PARTIAL_VALID 외 15개 상태 소관 부재를 명시 | 601902 §1.2가 16개 중 1개만 사용함을 명시하고 §6 OQ-6으로 나머지 15개의 소관을 열었다. 소관이 결정된 것은 아니지만 허용된 열린 질문으로 처분됐다. 모델의 질문 목록 동기화는 I-1이다. | 닫힘 — OQ-6 유보 |
| OQ-5 | §1.33 채록 선행 후 TI-15 근거 편입으로 해소 | 실제 채록과 인용을 모두 확인했다. 다른 미채록 여부는 601901 Q-P14로 분리됐으므로 §1.33의 해소를 전수 채록 완료로 확장하지 않는다. | 닫힘 |

13행 전부 기록. 공란 0건.

601913 §1의 별도 정정 3건도 보조 확인했다. B-1의 NONE 역방향 등치, B-2의 재요청=완료 등치, B-3의 isolation CHECK 누락은 각각 현재 601905 §2·§4·§6에서 정정돼 있다. 이 3건을 위 13건에 중복 계상하지 않았다.

## 종합

축별 수는 주축에만 계상한다. 다른 축과 연결되는 finding을 중복 합산하지 않는다.

| 축 | 발견 | blocking | informational |
|---|---:|---:|---:|
| A0 Round 2 처분 확인 | 1 | 1 | 0 |
| A1 내부 정합성 | 3 | 1 | 2 |
| A2 수직 추적성 | 1 | 0 | 1 |
| A3 실제 PostgreSQL 가능성 | 2 | 0 | 2 |
| A4 외부 타당성 | 1 | 0 | 1 |
| 합계 | 8 | 2 | 6 |

R2-1·R2-2·R2-3의 보강이 각각 해제 자기 차단, payload 변경 우회, 미열거 authority 상태의 실행을 다시 만드는 사례는 이번 범위에서 확인하지 못했다. 아래 B-2는 현재 대상에서 새로 도출한 모델의 규칙 강화이며, Round 2 처분이 만들었다고 단정하지 않는다.

## Findings

rule 번호는 이번 사용자 지시의 finding acceptance rule을 사용한다. 과거 통합 보고서의 rule 번호와 다르다.

| # | 축 | 지점 | 내용 | blocking | rule 근거 |
|---|---|---|---|---|---|
| B-1 | A0 | 601913 §4 M-4 / 601905 §0.1·개정 이력·§9 | M-4의 3개 provenance 지점 중 §9만 보강됐다. 입력 목록과 개정 이력에 601910이 없고 본문 직접 인용은 유지된다. 전체 처분 주장과 달리 부분 처분이다. | YES | rule 5 — 기록된 처분 대상이 실제로 완전히 닫히지 않음 |
| B-2 | A1 | 601905 §5 Q-7, 461행 / 601902 §1.4, 206~207행 | 모델은 “승인 주체와 발동 actor의 비동일성”을 요구한다. TI-4는 수동 발동자가 “자기 단독 승인만으로” 해제하지 못한다고 선언한다. 단독 승인 금지를 모든 승인 주체의 비동일성으로 옮겨 승인 참여 조건을 강화했다. | YES | rule 2 — 601902에 없는 추가 제한을 모델이 생성 |
| I-1 | A1 | 601905 §0.1·§7.1 P-1·§7.4·§9 | 입력/질문 목록은 OQ-1~OQ-4에 머물러 OQ-5 해소·OQ-6 신설을 반영하지 않는다. P-1 설명도 현재 default에 따른 미실행과 향후 scoped 허용 질문의 구분을 §3만큼 담지 못했다. §3의 실제 default는 올바르다. | NO — informational | 현재 선언을 뒤집는 경로나 OQ 강제 확정은 없음. 질문·설명 동기화 |
| I-2 | A1 | 601902 §4 HD-0-A-2R-11, 947행 이하 | 영어 Human Decision은 격리 tenant 접근 거부를 설명하지만 추가된 격리 전이 예외를 요약하지 않는다. §1.13 및 601905 §2에는 예외가 있으므로 실제 예외 부재로 재분류하지 않는다. | NO — informational | 본문 보강은 존재. 과거 요약의 동기화 문제 |
| I-3 | A2 | 601902 §1.12, 489행 / 601901 §10.2의 §1.27 채록 | “한 축의 값으로 다른 축의 상태를 추론하지 않는다”는 인용문은 601702 §1.27 원본에 실제 존재하지만 601901의 해당 발췌에는 없다. Stage 0의 §1.28 채록은 유사한 상태 대체 금지를 담는다. | NO — informational | 원천과 TI-12는 일치하며 모델에서 새 선언을 만들지 않음. Q-P14의 잔여 채록 조사 사례 |
| I-4 | A3 | live idempotency_keys / 601902 TI-6 / 601905 §4 | request_hash text는 nullable, key와 별도 저장 가능하고 text 비교도 가능하다. 그러나 보존·불변성·비교·동시 중복 방지를 격리 전이에 적용하는 현재 함수는 없다. | NO — informational | 현재 구현 간극은 이미 명시됐고 저장 위치·알고리즘·진행 중 처분은 Stage 4 유보. 물리 불가능으로 올리지 않음 |
| I-5 | A3 | live isolate_tenant·RLS / 601901 §17~§19 / 601905 §6 | 현 함수는 isolation_state를 읽거나 쓰지 않고 tenant_status에 ISOLATED/ACTIVE를 쓴다. 격리 발동 값은 status CHECK 밖이다. authenticated EXECUTE 및 definer 경로도 그대로다. 현재 코드로 안전한 TI-13 예외를 실행 검증한 상태가 아니다. | NO — informational | 기존 실측과 일치하는 알려진 구현 간극. 문서가 구현 완료를 주장하지 않음 |
| I-6 | A4 | 601905 §2·§3·§4 / 601902 §2 S6-2·S6-3·S6-4·S6-6·S6-10 | 격리 전이 예외는 업무 객체의 일반 접근 허용이 아니다. 최종 구현에서 권한 판정·필수 context·감사·전이 원자성·공식 해제 경로를 함께 강제해야 한다. 이 연결의 실행 증명은 read-only catalog로 얻지 못했다. | NO — informational | 물리 ACL/RBAC와 atomic transition은 명시된 Stage 4·0-C 책임. 후속 사항을 새 blocking으로 올리지 않음 |

### B-1 판정의 범위

601905의 현재 개정 이력은 Round 1 재동기화와 R2-1~R2-4 보강을 기록한다. 601910 B-1·B-2·B-3 정정 자체를 이력으로 기록하지 않았다. §0.1은 601913을 입력으로 나열하지만 601910은 직접 입력으로 나열하지 않는다. 601910 원본을 읽어야 한다는 요구가 아니다. 금지된 원본은 이번 검증에서도 읽지 않았다.

이 문제 자체는 보안 동작의 실패를 증명하지 않는다. 다만 이번 지시가 rule 5로 “601913이 기록한 처분 대상이 실제로 닫히지 않았다”를 blocking으로 지정했고 M-4를 전수 확인 대상으로 삼았으므로 그 등급을 적용했다.

### B-2 반례와 범위

수동 발동자 A가 독립 승인자 B와 함께 승인에 참여하는 경우를 생각한다. 이 사례는 TI-4의 “A의 자기 단독 승인”과 다르다. 모델의 Q-7을 발동자와 모든 승인 주체의 비동일성 요구로 그대로 구현하면 A의 참여 자체를 거부한다. A의 참여를 허용한다는 새 업무규칙을 여기서 선언하는 것이 아니라, TI-4가 선언한 금지보다 강한 조건을 Q-7이 확정했다는 차이를 지적한다.

601903 TI-4-f에도 비동일성이라는 축약이 있다. 그러나 601905 §0·§9가 유일한 선언 출처를 601902로 한정하므로 조사자의 정보 요소가 제한을 추가할 권위는 없다. 010650 §38의 원문은 “security quarantine released by same actor who triggered it”이고, 601902는 이를 단독 승인 금지로 구체화했다. 원천 anti-pattern의 나머지 적용 범위를 여기서 재결정하지 않는다. OQ-3을 닫는 finding도 아니다.

정확한 role ID와 approver 수를 정하라는 지적이 아니다. 현재 모델이 TI-4의 금지 조건을 그대로 표현하는지에 관한 지적이다.

## 실측 상세 — A3 주축

### 환경

| 항목 | 결과 |
|---|---|
| 컨테이너 | supabase_db_yoonsul_wait_order_handoff |
| DB / version | postgres / PostgreSQL 17.6, x86_64-pc-linux-gnu |
| default_transaction_read_only | on — 모든 DB 호출에 PGOPTIONS 적용 |
| DB 측정 시각 | 2026-09-05 15:32:10.855561+00 = 2026-09-06 00:32:10.855561 KST |
| migration success | 170 |
| latest migration | 0171_merchant_account_foundation.sql / success=true / 2026-08-30 11:46:47.552241+00 |
| 실행 수준 | catalog SELECT와 상수 SELECT. 상태 전이·삽입·임시 테이블·DDL 없음 |

### TI-13 예외의 표현 가능성

tenants.isolation_state는 NOT NULL text이며 NONE/ISOLATED CHECK를 가진다. tenant_status는 독립 CHECK다. 상수 SELECT에서 ACTIVE/SUSPENDED × NONE/ISOLATED 네 조합이 각각의 CHECK 값 집합에 모두 들어감을 확인했다. 이는 허용값 검산이며 실제 행 INSERT 성공이나 전체 runtime 동작을 시험한 것이 아니다.

isolation_state를 prosrc로 참조하는 catchmenu 함수 0건, 관련 view 0건, matview 0건, 이름/정의로 검색한 격리 전이 trigger 0건이다. tenants의 사용자 trigger는 updated_at 갱신 1건이다. 관련 CHECK는 chk_tenants_isolation_state 1건이다. 조회한 RLS에는 isolation_state 조건이 없다.

따라서 현 CHECK가 해제 전이를 금지하거나 TI-13의 플랫폼 전이 예외를 구조적으로 표현 불가능하게 하지는 않는다. 반대로 지금 그 예외가 안전하게 구현됐다는 뜻도 아니다. 현 isolate_tenant는 SECURITY DEFINER, 소유 실행 컨텍스트인 postgres는 BYPASSRLS이며 authenticated에 EXECUTE가 있다. authenticated의 tenants 및 idempotency_keys 직접 SELECT/UPDATE 권한은 false다. 직접 table grant 없음과 definer 함수 진입 가능성을 구분해야 한다.

현 함수의 prosrc MD5는 f53ea7f556e89cec883b9ca6b482ca3e로 601901과 일치한다. manage_subscription 및 detect_threat도 각각 3ceb5089e1c2305628db36e485be9bcd, 992c78c881be2f23bcac8050b60ad2b7로 일치한다. 이 함수들의 기존 잘못된 상태축 쓰기, company_name 참조, p_reason named argument 호출을 정적 원문으로 재확인했다.

**판정: 모델의 예외는 PostgreSQL에서 표현 가능하지만 현 구현에는 없다. R2-1의 선언·모델 처분은 닫혔으며 runtime 강제 확인은 별개다.**

### TI-6 보존·비교의 물리 가능성

| 관측 | 의미 |
|---|---|
| idempotency_key text NOT NULL | canonical key를 저장할 타입 슬롯 존재 |
| request_hash text NULL 허용 | key와 별도 hash 저장 가능. payload_hash라는 새 컬럼명이 반드시 필요하다는 뜻은 아님 |
| UNIQUE (tenant_id, key_domain, idempotency_key) | tenant를 포함한 고유성 자산 존재. 이것만으로 최초 hash 보존이나 payload 비교가 자동 실행되지는 않음 |
| processing_status 5값 CHECK | PROCESSING / COMPLETED / FAILED / EXPIRED / DUPLICATE_REJECTED |
| result_payload jsonb nullable, object CHECK | 최초 결과를 담을 수 있는 슬롯. 결과 필수성은 강제하지 않음 |
| key_domain 11값 CHECK | isolation 전용 literal은 없음. 기존 domain 매핑/확장 여부는 모델이 확정하지 않았음 |
| 격리 함수의 idempotency_keys 참조 | 0건. 참조 함수는 intake_delivery_order 1건 |
| 상수 text 비교 | 동일 hash=true, 다른 hash=false, NULL과 hash의 등가 비교=NULL |

현재 스키마는 TI-6 정보를 담을 재료를 일부 갖는다. nullable request_hash의 NULL 처리, 최초 보존값 변경 방지, key 확보와 전이의 원자성, 경쟁 요청 처리 및 결과 보존은 아직 강제되지 않는다. 이들은 새로 컬럼명을 결정하거나 DB를 수정해야만 판단할 수 있는 사항으로 오인하지 않는다. 601902와 601905가 물리 구현을 유보했고 미강제 상태를 기록했으므로 현 부재를 모델의 불가능성으로 올리지 않는다.

601905 §4의 보존 의무는 392행 산문에도 있으므로 Mermaid LOG 노드에 payload_hash 이름이 별도 없다는 이유만으로 R2-2를 미해소 판정하지 않았다. 재요청 여부와 처리 완료 여부 역시 별도 분기돼 있다.

**판정: hash 보존·비교는 물리적으로 가능하다. 기존 nullable 컬럼과 UNIQUE의 존재만으로 TI-6이 이미 강제된다고 판단할 수 없다.**

### 601904 및 601901과의 정합

이번에 재측정한 상태 CHECK, 핵심 함수 MD5, key/audit 컬럼과 제약, 함수 참조, 관련 RLS·권한·trigger는 기존 실측과 부합했다. 601905 §6의 TI-13 행은 CHECK 1건을 명시하고 함수·뷰·트리거 0건과 구분한다.

다만 601904는 TI-1~TI-11 조사다. 601905 §6의 TI-12~TI-15 모든 주장까지 601904가 직접 측정했다고 확대할 수 없다. 이번 검증도 전체 business 모델·앱 코드·외부 provider 경로의 전수 실행 검증을 수행한 것은 아니다. SQL 함수의 정적 참조와 실제 성공하는 호출 경로도 구별했다.

## TI-N 추적표

완결은 현 단계의 선언→모델 추적 여부를 뜻한다. DB 강제 완료의 뜻이 아니다. 명시된 유보를 미완성 구현 결함으로 계산하지 않는다.

| TI-N | 601901 근거 | 601905 표현 | 완결 |
|---|---|---|---|
| TI-1 | §3.1·§3.1′·§11·§14 Q-P6/Q-P12 — mandatory 5건과 발견 3건 구분 | §0.1·§6·§7.3 D-1·§8, 정책 채택은 도형 밖 | 완결 — 문서상 채택 |
| TI-2 | §6.2의 SCOPE_PARTIAL_VALID, §9.2.2의 010650 §4·§18·§36, Q-P10 | §1·Q-9, tenant-wide 2값과 scoped 별도 책임 | 완결 — OQ-4·OQ-6 유보, I-1 |
| TI-3 | §9.1.2의 010630 §6·§28, §9.2.2 자동 containment | §2 발동·§3 ALLOWED/default 분기·Q-4 | 완결 — 현재 default와 OQ-1 병존 |
| TI-4 | §9.1.2 §18, §9.2.2 §16·§35·§38 | §2 해제 요건과 비대칭, §5 Q-7 | 부분 — Q-7의 추가 제한 B-2 |
| TI-5 | §9.2.2의 010650 §35 | §2 비대칭 및 권한 비상속 | 완결 |
| TI-6 | §9.3.2의 010660 §2·§4·§5·§6·§10·§37, Q-P11, §20 | §4 5항 파생·hash 비교·완료 분기, Q-5·Q-6 | 완결 — 저장·경쟁 처리 등 Stage 4, I-4 |
| TI-7 | §6.2 merchant_id, §8.2의 000170 §3·§4, Q-P4 | §5 Q-10 provider↔내부 context mapping | 완결 — 물리 mapping 유보 |
| TI-8 | §6.2 scope 필수성·차원·전달·불일치 fail closed, Q-P5 | §5 Q-2·Q-3, §6의 누락 시 mutation 금지 요구 | 완결 — context 운반 구현 유보 |
| TI-9 | §5.2의 010004 §20, §9.2.2 최소 안전 scope | Q-8→Q-1, Q-9 점선, §1 OQ-2 | 완결 — escalation 조건 유보 |
| TI-10 | §5.2 §19의 cross-scope attempt 포함 audit, §20·§21.1 현 자산 | §5 Q-1·Q-2의 audit 전항 | 완결 — 저장 방식 유보 |
| TI-11 | §5.2 §24 11항·§29 runtime 유보, §5.1의 §26 구조 | §6·§7.2 P-10·§8, 도형 밖 게이트 | 완결 — Stage 7 전 선언 조건 유지 |
| TI-12 | §10.2의 601702 §1.27·§1.28, §17·§18 상태축 실측 | §1 소유 2축과 다른 4축 precondition, §6 | 부분 — 근거 의미는 일치, 직접 인용의 채록 공백 I-3 |
| TI-13 | §5.2의 010004 §7, §17 CHECK/소비자 실측 | §2 TR 예외와 CHK 거부, §6 | 완결 — 예외는 보강된 TI-13 Human 선언, I-2·I-5·I-6 |
| TI-14 | §5.2 deny-by-default와 §17~§19 상태축; 000221·600010 자체는 채록 제외 | §0.3 의도된 부재·§5 설명·§6·§8 | 완결 — 채록 제외 사유 명시, M-2 |
| TI-15 | §7.2 000150, §9.2 000190, §10.2 보강 §1.33 | §3 SCOPE·§5 link 설명·§0.3 의도된 부재·§8 | 완결 — link 물리 표현 유보 |

15행 전부 기록. 공란 0건. TI-12의 추가 문장 미채록은 원천 불일치와 구별했고, TI-14의 선언 근거 일부가 Stage 0 밖이라는 사실도 숨기지 않았다.

## 실행 쿼리 전문

모든 DB 세션에 아래 접속 설정을 적용했다.

```powershell
docker exec -e PGOPTIONS="-c default_transaction_read_only=on" -i supabase_db_yoonsul_wait_order_handoff psql -v ON_ERROR_STOP=1 -U postgres -d postgres
```

첫 연결에서 다음 쿼리를 1회 실행했으며 아래 묶음에서도 다시 실행했다.

```sql
SELECT current_database(), version(), current_setting('default_transaction_read_only');
```

다음은 실제 실행 SQL 전문이다. 첫 묶음의 넓은 psql 표 출력에서 함수 본문 일부가 표시 한도를 넘었으므로 두 번째 묶음을 -A -t로 재조회해 핵심 함수 본문을 확인했다. 실패한 SQL은 없다.

```sql
SELECT current_database(), version(), current_setting('default_transaction_read_only');
SELECT current_timestamp;
SELECT count(*) FILTER (WHERE success) AS successful, max(applied_at) FROM catchmenu_meta.migration_history;
SELECT filename,success,applied_at FROM catchmenu_meta.migration_history ORDER BY applied_at DESC LIMIT 1;
SELECT table_schema,table_name,column_name,data_type,is_nullable,column_default
FROM information_schema.columns
WHERE (table_schema='catchmenu_hq' AND table_name='tenants')
OR (table_schema='catchmenu_common' AND table_name IN ('idempotency_keys','security_audit_log','security_threats'))
ORDER BY table_schema,table_name,ordinal_position;
SELECT conrelid::regclass,conname,contype,pg_get_constraintdef(oid,true)
FROM pg_constraint WHERE conrelid IN ('catchmenu_hq.tenants'::regclass,'catchmenu_common.idempotency_keys'::regclass,'catchmenu_common.security_audit_log'::regclass,'catchmenu_common.security_threats'::regclass) ORDER BY 1,2;
SELECT schemaname,tablename,policyname,roles,cmd,qual,with_check FROM pg_policies WHERE schemaname LIKE 'catchmenu%' AND (tablename IN ('tenants','idempotency_keys','security_audit_log') OR qual ILIKE '%isolation_state%' OR with_check ILIKE '%isolation_state%') ORDER BY 1,2,3;
SELECT p.oid::regprocedure,p.prosecdef,p.proconfig,p.proacl,md5(p.prosrc),p.prosrc FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='catchmenu_common' AND p.proname IN ('isolate_tenant','manage_subscription','detect_threat') ORDER BY p.proname;
SELECT p.oid::regprocedure,p.prosrc ILIKE '%isolation_state%' AS isolation_ref,p.prosrc ILIKE '%idempotency_keys%' AS key_ref FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%' AND (p.prosrc ILIKE '%isolation_state%' OR p.prosrc ILIKE '%idempotency_keys%');
SELECT tgrelid::regclass,tgname,pg_get_triggerdef(oid,true) FROM pg_trigger WHERE NOT tgisinternal AND (tgrelid IN ('catchmenu_hq.tenants'::regclass,'catchmenu_common.idempotency_keys'::regclass,'catchmenu_common.security_audit_log'::regclass) OR pg_get_triggerdef(oid,true) ILIKE '%isolation_state%');
SELECT schemaname,viewname FROM pg_views WHERE schemaname LIKE 'catchmenu%' AND definition ILIKE '%isolation_state%';
SELECT schemaname,matviewname FROM pg_matviews WHERE schemaname LIKE 'catchmenu%' AND definition ILIKE '%isolation_state%';
SELECT conrelid::regclass,conname,pg_get_constraintdef(oid,true) FROM pg_constraint WHERE pg_get_constraintdef(oid,true) ILIKE '%isolation_state%';
SELECT rolname,rolsuper,rolbypassrls FROM pg_roles WHERE rolname IN ('postgres','authenticated','service_role');
SELECT r.role_name,t.table_name,has_table_privilege(r.role_name,t.table_name,'SELECT') AS sel,has_table_privilege(r.role_name,t.table_name,'UPDATE') AS upd FROM (VALUES ('authenticated'),('service_role'),('postgres')) r(role_name) CROSS JOIN (VALUES ('catchmenu_hq.tenants'),('catchmenu_common.idempotency_keys')) t(table_name);
```

```sql
SELECT p.oid::regprocedure,md5(p.prosrc),p.prosrc FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname='catchmenu_common' AND p.proname IN ('isolate_tenant','manage_subscription','detect_threat') ORDER BY p.proname;
SELECT 'probe'::text = 'probe'::text AS same_hash, 'probe'::text = 'other'::text AS changed_hash, NULL::text = 'probe'::text AS missing_hash;
```

```sql
SELECT tenant_status,isolation_state,
tenant_status IN ('ACTIVE','TRIAL','SUSPENDED','CANCELLED','TERMINATED') AS status_check,
isolation_state IN ('NONE','ISOLATED') AS isolation_check
FROM (VALUES ('ACTIVE','NONE'),('ACTIVE','ISOLATED'),('SUSPENDED','NONE'),('SUSPENDED','ISOLATED')) v(tenant_status,isolation_state);
SELECT p.oid::regprocedure,p.prosecdef,p.proconfig,p.proacl
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE n.nspname='catchmenu_common' AND p.proname='isolate_tenant';
SELECT count(*) FILTER (WHERE p.prosrc ILIKE '%AUTHORITY_ALLOWED%') AS authority_allowed_refs,
count(*) FILTER (WHERE p.prosrc ILIKE '%isolation_state%') AS isolation_refs
FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace WHERE n.nspname LIKE 'catchmenu%';
```

함수 이름을 WHERE 조건으로 조회하거나 prosrc의 호출문을 읽는 것은 해당 함수를 호출한 것이 아니다. 금지 10함수는 모두 미실행이다. hash 및 상태 조합 검산은 상수 SELECT이며 업무 데이터를 생성하지 않았다.

## 근거 입력 목록

| 근거 | 사용 범위 |
|---|---|
| 000701 §47.1 | 새 세션 독립 검증 및 단계 경계 |
| 601901 | 원천 8건 채록, §10.2 상위 선언, Pass 2 실측 |
| 601902 | TI-1~TI-15, §2 S6, §5 유보, §6 OQ, §7 근거 |
| 601903 | 정보 요소 TI-N-x, 자산 조사, 인접 접점 및 P-1~P-13 |
| 601904 | C1~C5 실측과 현재 모델의 비교 범위 |
| 601905 | 검증 대상 모델 전문 |
| 601909 | Round 1 통합의 문제 정의·처분 주장. 판정 승계 없음 |
| 601913 | R2-1~R2-5, M-1~M-7의 문제 정의. 판정 승계 없음 |
| 601702 | 특히 §1.22~§1.28·§1.33·§1.40~§1.43 원문 대조 |
| 600021 | 권위보류 경계·mandatory source 5건·Stage 4 evidence pack 구속 |
| 010004·010630·010640·010650·010660 | 원천의 접근 기본 거부, authority default, scope, release, payload conflict 관련 원문 |
| 000150·000170·000190 | business authority, merchant domain, cross-business link 원문 |
| 000221 §4.1·600010 | TI-14 착수 게이트 및 계획·트래커의 성격 확인 |
| live PostgreSQL catalog | 위 실행 쿼리. runtime 쓰기/호출 검증 제외 |

이 보고서는 검증 대상의 개정안, SQL 설계안 또는 Human 업무규칙을 생성하지 않는다.
