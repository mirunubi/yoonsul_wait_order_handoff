# 601701_Register_Stage0_Evidence_Collection.md

Status: Draft
Lifecycle: Register
Last Updated: 2026-08-11

## §0 용도

`000701` §48 증거수집 산출물이다.
새 0-A(`601700`)의 **1단계 업무규칙 선언 직전**에 수행한다(§48.4).

**원칙**: "파일이 존재한다"와 "실제로 작동한다"는 완전히 다른 사실이다.
이 둘을 구분해서 기록하지 않으면 1단계 선언이 근거 없는 전제 위에 서게 된다.

> ⚠️ 이 문서는 **사실 등록부**다. 판단·설계·결론을 쓰지 않는다.
> 재사용 판정 열은 A~E 5단계가 모두 채워진 뒤에만 기입한다.

## §1 분류 기준 (`000701` §48.1)

| 등급 | 의미 |
|---|---|
| **A** 문서만 존재 | 설계/정책문서는 있으나 그 이상의 근거 없음 |
| **B** SQL 객체 존재 | 실제 테이블/함수/제약이 라이브DB 또는 migration에 존재 |
| **C** 문서와 일치 | B의 실제 스키마/함수가 A의 문서 내용과 실제로 부합 |
| **D** 로컬 실행 검증 | 실제로 호출/실행해봤을 때 성공하는지 |
| **E** 호출자·권한 통합 | 실제 호출자가 있는지, 권한검사가 의도대로 작동하는지 |

## §2 금지사항 (`000701` §48.3)

1. **"문서가 존재하므로 구현된 것으로 간주"하는 판단 금지.**
2. **5단계 중 하나라도 건너뛰고 결론(예: "재사용 가능")을 내리는 것 금지.**
3. **대상을 표 없이 산문으로만 설명하는 것 금지.**

추가 제약 (`600020` 권위 판정에 따름):

4. `601500`의 설계 결론을 **정답으로 전제하지 않는다.** `0168`/`0169`는 "현재 DB에 무엇이 있는가"라는 사실로만 기록하고, "이것이 옳다"는 판단을 붙이지 않는다.
5. 문서 자체의 노후·모순을 발견하면 그것도 사실로 기록한다. 원천 설계문서는 검증된 적이 없다(`600020` §2.2).

## §3 대상별 요약표 (`000701` §48.2)

**표 항목 값**
- 문서 / DDL / RPC: `있음` / `없음`
- 호출자·권한검사: `있음` / `없음` / `불완전`
- 로컬검증: `성공` / `실패` / `미확인`
- 재사용 판정: `그대로재사용` / `부분재사용` / `수정후재사용` / `재작성필요`

| 대상 | 문서 | DDL | RPC | 호출자/권한검사 | 로컬검증 | 재사용 판정 |
|---|---|---|---|---|---|---|
| Company |  |  |  |  |  |  |
| Owner |  |  |  |  |  |  |
| Tenant |  |  |  |  |  |  |
| HQ |  |  |  |  |  |  |
| Store |  |  |  |  |  |  |
| User identity |  |  |  |  |  |  |
| Customer identity |  |  |  |  |  |  |
| Staff identity |  |  |  |  |  |  |
| Session |  |  |  |  |  |  |
| Role |  |  |  |  |  |  |
| Permission |  |  |  |  |  |  |
| Membership |  |  |  |  |  |  |
| Menu seed |  |  |  |  |  |  |
| Dining table |  |  |  |  |  |  |

## §4 대상별 상세

각 대상마다 A~E를 빠짐없이 기록한다. 확인하지 못한 항목은 `미확인`으로 적고 비워두지 않는다.

**하위 절 구조 (전 대상 공통)**

- **A. 문서 증거** — A-1 Discovery Inventory / A-2 Concept Source / A-3 Findings·Evidence / A-4 Vocabulary / A-5 Contradictions / A-6 Excluded
- **B~E** — SQL 객체 / 문서-SQL 일치 / 로컬 실행 검증 / 호출자·권한 통합

**A-1 열 값**

- 분류: `Doctrine` / `Design` / `Audit` / `Verification` / `Baseline` / `Scope` / `Template` / `Reference`
- 권위: `ACTIVE` / `SUSPENDED` / `HISTORICAL`
- 처분: `A-2`(개념원천) / `A-3`(발견) / `A-6`(제외)

**A-2 포함 기준**

포함은 (a) 해당 개념의 의미를 직접 정의하거나, (b) 업무규칙 또는 관계를 독립적으로 선언하는 문서로 한정한다.
Readme / Tracker / Template / Baseline Summary, 현 워크패킷(`601700`/`601701`)이 생성한 문서는 A-1에만 남긴다.
TestPlan / Verification / Module / Audit / AuditReview 는 A-3으로 보낸다.
`AUTHORITY SUSPENDED` 블록의 내용도 A-3으로 보낸다 — 감사 finding을 원천정의로 승격시키면 역전파가 반복된다.

**권위 열 표기 규칙**: 그 산출물 자체의 현재 지위를 적는다.
`600020` §1.4에 따라 finding의 증거 가치는 판정의 권위와 별개로 유지되므로, 필요한 경우 발견 내용 칸에 병기한다.

### §4.1 Company

**A. 문서 증거**

**A-1. Discovery Inventory**

| # | 문서 경로 | 분류 | 권위 | 처분 |
|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | Doctrine | ACTIVE | A-2 |
| 2 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | Doctrine | ACTIVE | A-2 |
| 3 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Doctrine | ACTIVE | A-2 |
| 4 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | Doctrine | ACTIVE | A-2 |
| 5 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | Doctrine | ACTIVE | A-2 |
| 6 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Doctrine | ACTIVE | A-2 |
| 7 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | Doctrine | ACTIVE | A-2 |
| 8 | `docs/000100_project_foundation/000140_Guide_Organization_Core.md` | Doctrine | ACTIVE | A-2 |
| 9 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | Doctrine | ACTIVE | A-2 |
| 10 | `docs/000100_project_foundation/000200_Boundary_Organization_Core_MVP_Cutline.md` | Scope | ACTIVE | A-6 |
| 11 | `docs/010000_runtime_foundation_and_cross_room_architecture/010100_foundation_static_catalog_package/010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | Reference | ACTIVE | A-6 |
| 12 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Design | SUSPENDED | A-2 |
| 13 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | Scope | SUSPENDED | A-6 |
| 14 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | Design | SUSPENDED | A-2 |
| 15 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | Scope | SUSPENDED | A-6 |
| 16 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Audit | SUSPENDED | A-3 |
| 17 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | Scope | SUSPENDED | A-6 |
| 18 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Template | SUSPENDED | A-6 |
| 19 | `000150` 2026-08-11 역전파 블록 (동일 파일 내 별도 블록) | Audit | SUSPENDED | A-3 |
| 20 | `003020` 2026-08-11 역전파 블록 (동일 파일 내 별도 블록) | Audit | SUSPENDED | A-3 |
| 21 | `009030` 2026-08-11 역전파 블록 (동일 파일 내 별도 블록) | Audit | SUSPENDED | A-3 |

**파일명 검색 결과**: `*Company*` 4건 — `000150` / `000170` / `003020` / `601501`. 전부 위 표에 포함.

**A-2. Concept Source**

| # | 문서 경로 | 무엇을 정의하는가 | 권위 |
|---|---|---|---|
| 1 | `000150` | CatchMenu 운영 company · business unit · legal entity 경계, 사업부 vs 법인 분리, 외부 SaaS·Franchise OS 격리 | ACTIVE |
| 2 | `000170` §6 | `merchant_company` 정의, merchant_account↔company↔store 3계층 | ACTIVE |
| 3 | `003020` §2 | 5축 중 company = 브랜드·운영 그룹핑, legal_entity와 병렬 축 | ACTIVE |
| 4 | `009030` §2 | 개념 엔터티 `company`: "Not automatically legal entity" | ACTIVE |
| 5 | `009070` §2 | company vs operating_group vs legal_entity 축 정렬 (물리 스키마 비정의) | ACTIVE |
| 6 | `007010` §2 | Admin Console company 축 = operating company or brand entity | ACTIVE |
| 7 | `007040` §3 | Company List/Detail 화면, company ≠ legal_entity 금지 규칙 | ACTIVE |
| 8 | `000140` §23 | platform company context 및 CatchMenu HQ와의 관계 | ACTIVE |
| 9 | `000190` | CatchMenu company 경계 vs Franchise OS 권한 유입 방지 | ACTIVE |
| 10 | `601501` §0.3–§0.6 | company 축 = `franchise_brands`, legal_entity = `legal_entities`, 4개념 분리 | SUSPENDED |
| 11 | `601503` | DDL·접근제어·company/legal_entity 테이블 규칙 | SUSPENDED |

**A-3. Findings / Evidence**

| # | 출처 문서 | 발견 내용 | 권위 |
|---|---|---|---|
| 1 | `600020` §2.2 | `000150` §26의 `companies`/`business_units`가 "Actual schema may be designed later" 상태로 방치 | ACTIVE |
| 2 | `000150` 역전파 블록 층 A | 어휘 함정: `legal_entities.entity_type='CORPORATION'`은 법인격 종류(legal form)이며 company 축(브랜드 그룹핑)과 다른 개념 | 층 A 유효 / 층 B(구현 대응표) 권위 없음 |
| 3 | `003020` 역전파 블록 층 A | company 축과 legal_entity 축 혼동 경고 | 층 A 유효 / 층 B 권위 없음 |
| 4 | `009030` 역전파 블록 층 A | 개념 등록부에 없던 신규 개념(자연인·대표권·조직 역할)이 존재한다는 경고 | 층 A 유효 / 층 B 권위 없음 |
| 5 | `601601` §4.2·§4.3 | 원천 설계문서 노후 사례 기록 | SUSPENDED (finding 증거가치는 `600020` §1.4로 유지) |
| 6 | `601510` Stage 11B 블라인드 감사 | 4개념 분리 문제 finding | 판정 HISTORICAL / finding 증거 유지 (`600020` §1.4) |

**A-4. Vocabulary**

| 어휘 | 출처 | 정의 | 비고 |
|---|---|---|---|
| company | `003020` §2 | Operating company or brand entity; not automatically legal_entity | `TERM_COLLISION` — 아래 3개 항목과 같은 단어, 다른 개념 |
| merchant_company | `000170` §6 | Business entity behind one or more stores; billing/contract/tax reference | `TERM_COLLISION` |
| platform company context | `000140` §23 | CatchMenu HQ가 관리하는 플랫폼 company 맥락 | `TERM_COLLISION` |
| business_unit | `000150` §2 | 사업부·operating division; legal entity와 분리 | |
| legal_entity | `000150`, `003020` §2 | 계약·세무·정산 주체; company와 병렬 축 | |
| operating_group | `003020` §2 | 지역·가맹·직영 그룹; company와 다른 축 | |
| franchise_brands | `601501` §0.3–§0.4 | company 축 구현체로 기술 | 권위보류 |
| legal_entities | `601501` §0.3 | legal_entity 축 구현체; `entity_type='CORPORATION'`은 법인격 종류 | 권위보류 |
| store_groups | `601501` §0.5 | operating_group 축; `group_type='REGION'`만 | 권위보류 |

**A-5. Contradictions**

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `000170` §4: 최상위 `merchant_account` | `003020` §2: 최상위 `tenant` | SaaS 고객 경계 명칭·계층 불일치 |
| 2 | `000170` §6: `merchant_company` | `003020` §2: `company` = brand/operating grouping | 동일 계층에 다른 명칭 |
| 3 | `003020` §2: company ≠ legal_entity (추상 축) | `601501` §0.3: company=`franchise_brands`, legal=`legal_entities` (구체 테이블) | 추상 축 선언 vs 구체 테이블 매핑 |
| 4 | `000150` §2: `business_unit` | `003020` §2: `operating_group` | 유사 역할, 다른 용어 |
| 5 | `000150`·`003020` 본문 | 동일 파일 2026-08-11 역전파 블록 | 본문은 "Actual schema may be designed later" 성격, 블록은 `0168`/`franchise_brands` 매핑 주장 — 동일 파일 내 이중 서술 |
| 6 | `600020` §2.2: 원천 설계문서 검증된 적 없음 | `000150`·`003020` 역전파 블록: 0-A 구현 결과 반영 | 동일 문서군에 "미검증"과 "구현 반영" 공존 |

**A-6. Excluded**

| 문서 경로 | 제외 사유 |
|---|---|
| `000200_Boundary_Organization_Core_MVP_Cutline.md` | MVP 범위 컷라인 선언; company 개념 정의 아님 |
| `010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | company·brand 축 참조만 |
| `601502_Overview_Operational_Authority_Foundation_Ddl.md` | 0-A 범위·맥락 문서 |
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | 허용/금지 계약 문서 |
| `601700_Readme_Operational_Authority_Foundation_V2.md` | 워크패킷 범위 선언 |
| `601701_Register_Stage0_Evidence_Collection.md` | 현 워크패킷 자기참조 (빈 템플릿) |
| `docs/014000_pos_provider_integration_strategy/014690_Template_POS_Provider_Official_Verification_Request.md` | company 필드 언급, 개념 정의 없음 |
| `docs/021000_financial_security_monitoring_catalog/021540_Policy_Universal_Integration_Reconciliation_And_Idempotency_Catalog.md` | tenant/company 교차 참조만 |
| `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010451_Policy_Financial_Risk_Boundary.md` | legal entity 맥락 언급, company 축 미정의 |
| `docs/000005_Index_Document_Number.md` | 인덱스·등록 메타 |
| `docs/000007_Map_Full_Directory.md` | 디렉터리 맵 |
| (기타 114건) | POS/결제/배포/거버넌스 등에서 company·legal_entity 단순 참조 |

**집계**: 본문 키워드 히트 137건 / A-1 등재 21건(문서 18 + 역전파 블록 3) / 단순 참조 제외 119건.

**B. SQL 객체**

**B-1. 라이브 DB 객체**

| 종류 | 스키마 | 실명 | 비고 |
|---|---|---|---|
| TABLE | catchmenu_hq | franchise_brands | 24컬럼, RLS ENABLE+FORCE |
| COLUMN | catchmenu_hq | franchise_brands.id | uuid, PK, default `gen_random_uuid()` |
| COLUMN | catchmenu_hq | franchise_brands.tenant_id | uuid, NOT NULL, FK→tenants |
| COLUMN | catchmenu_hq | franchise_brands.brand_code | text, NOT NULL |
| COLUMN | catchmenu_hq | franchise_brands.brand_name | text, NOT NULL |
| COLUMN | catchmenu_hq | franchise_brands.brand_type | text, NOT NULL, default `FRANCHISE` |
| COLUMN | catchmenu_hq | franchise_brands.parent_brand_id | nullable self-FK |
| COLUMN | catchmenu_hq | franchise_brands.brand_level | integer, default 1 |
| COLUMN | catchmenu_hq | franchise_brands.hq_store_id | nullable FK→stores |
| COLUMN | catchmenu_hq | franchise_brands.hq_contact_name/email/phone | text, nullable |
| COLUMN | catchmenu_hq | franchise_brands.contract_start_date/end_date | date, nullable |
| COLUMN | catchmenu_hq | franchise_brands.royalty_rate_pct | numeric, nullable |
| COLUMN | catchmenu_hq | franchise_brands.brand_color/logo_url/guidelines_url | text, nullable |
| COLUMN | catchmenu_hq | franchise_brands.shared_membership/shared_menu_template | boolean, default false |
| COLUMN | catchmenu_hq | franchise_brands.active_store_count | integer, default 0 |
| COLUMN | catchmenu_hq | franchise_brands.brand_status | text, default `ACTIVE` |
| COLUMN | catchmenu_hq | franchise_brands.is_active | boolean, default true |
| COLUMN | catchmenu_hq | franchise_brands.created_at/updated_at | timestamptz, default `now()` |
| CHECK | catchmenu_hq | chk_brand_type | 허용값 `FRANCHISE` / `CHAIN` / `VIRTUAL_BRAND` / `LICENSE` |
| CHECK | catchmenu_hq | chk_brand_status | 허용값 `ACTIVE` / `SUSPENDED` / `TERMINATED` / `PENDING` |
| UNIQUE | catchmenu_hq | uq_brand_code | `(tenant_id, brand_code)` |
| INDEX | catchmenu_hq | idx_brands_parent | `(parent_brand_id) WHERE parent_brand_id IS NOT NULL` |
| INDEX | catchmenu_hq | idx_brands_tenant | `(tenant_id, brand_type) WHERE is_active=true` |
| FUNCTION | catchmenu_hq | assign_store_to_brand | SECURITY DEFINER · `catchmenu_hq, catchmenu_ledger, catchmenu_common` |
| FUNCTION | catchmenu_hq | bulk_policy_distribution | SECURITY DEFINER · `catchmenu_hq, catchmenu_common, catchmenu_ledger` |
| FUNCTION | catchmenu_hq | create_franchise_brand | SECURITY DEFINER · `catchmenu_hq, catchmenu_ledger, catchmenu_audit, catchmenu_common` |
| FUNCTION | catchmenu_hq | create_menu_template | SECURITY DEFINER · `catchmenu_hq, catchmenu_ledger, catchmenu_audit, catchmenu_common` |
| FUNCTION | catchmenu_hq | get_franchise_admin_dashboard | SECURITY DEFINER · `catchmenu_hq, catchmenu_pos, catchmenu_payment, catchmenu_common` |
| FUNCTION | catchmenu_hq | get_franchise_dashboard | SECURITY DEFINER · `catchmenu_hq, catchmenu_pos, catchmenu_payment, catchmenu_common` |
| FUNCTION | catchmenu_hq | get_franchise_os_dashboard | SECURITY DEFINER · `catchmenu_hq, catchmenu_pos, catchmenu_payment, catchmenu_common` |
| FUNCTION | catchmenu_hq | get_menu_compliance_report | SECURITY DEFINER · `catchmenu_hq, catchmenu_pos, catchmenu_common` |
| FUNCTION | catchmenu_hq | get_policy_compliance_summary | SECURITY DEFINER · `catchmenu_hq, catchmenu_common` |
| FUNCTION | catchmenu_hq | publish_franchise_policy | SECURITY DEFINER · `catchmenu_hq, catchmenu_ledger, catchmenu_audit, catchmenu_common` |
| FUNCTION | catchmenu_hq | request_hq_approval | SECURITY DEFINER · `catchmenu_hq, catchmenu_ledger, catchmenu_common` |

`franchise_brands`를 직접 참조하는 함수는 11개이며 전부 `SECURITY DEFINER`다.

**B-2. migration 출처**

| 객체 | migration 파일 | 라인 |
|---|---|---:|
| franchise_brands | `0085_create_franchise_os_foundation_rpc.sql` | L123 |
| franchise_brands 인덱스 | `0085_create_franchise_os_foundation_rpc.sql` | L186, L190 |
| franchise_brands RLS | `0085_create_franchise_os_foundation_rpc.sql` | L194, L196 |
| 후속 정의/검증 | `0133_create_final_validation_package.sql` | L124, L140–148 |
| create_franchise_brand | `0085_create_franchise_os_foundation_rpc.sql` | L654 |
| assign_store_to_brand | `0085_create_franchise_os_foundation_rpc.sql` | L789 |

**B-3. 라이브 DB ↔ migration 불일치**

| 객체 | 라이브 | migration | 비고 |
|---|---|---|---|
| 조사된 Company 구조 객체 | 있음 | 있음 | 존재 여부 불일치 **없음** |

**B-4. RLS / GRANT**

| 테이블 | RLS | FORCE | 비-postgres GRANT |
|---|---|---|---|
| franchise_brands | true | true | 없음 |

**B-5. SQL 대응물이 없는 문서 어휘**

| 문서 어휘 | 출처(A-4) | SQL 대응물 | 비고 |
|---|---|---|---|
| companies | `000150` §26 (A-4 `business_unit`·`company` 계열) | 없음 | `franchise_brands`·`legal_entities`가 별도로 존재하나 Codex는 동일성 판단 안 함 |
| business_units | `000150` §2 | 없음 | — |
| merchant_companies | `000170` §6 (`merchant_company`) | 없음 | — |

**C. 문서-SQL 일치**

**C-1. 문서 어휘 ↔ SQL 객체 대응**

| A-4 어휘 | 출처 문서 | SQL 객체 | 대응 상태 |
|---|---|---|---|
| company | `003020` §2 | `catchmenu_hq.franchise_brands` (후보) | 판정불가 — Codex 동일성 미판정, `601501` 매핑은 권위보류 |
| merchant_company | `000170` §6 | 없음 | 미구현 |
| platform company context | `000140` §23 | 없음 | 미구현 |
| business_unit | `000150` §2 | 없음 | 미구현 |
| legal_entity | `000150`, `003020` §2 | `catchmenu_hq.legal_entities` | 일치 |
| operating_group | `003020` §2 | `catchmenu_hq.store_groups` | 이름다름 |
| franchise_brands | `601501` §0.3–§0.4 | `catchmenu_hq.franchise_brands` | 일치 |
| legal_entities | `601501` §0.3 | `catchmenu_hq.legal_entities` | 일치 |
| store_groups | `601501` §0.5 | `catchmenu_hq.store_groups` | 일치 |

**C-2. 문서 서술 ↔ SQL 실측 불일치**

| # | 문서 서술 (출처 §) | SQL 실측 | 어긋나는 지점 |
|---|---|---|---|
| 1 | `000150` §26: `companies`/`business_units`가 "Actual schema may be designed later" | 두 이름의 테이블 모두 없음 | 문서가 예고한 스키마가 존재하지 않음 |
| 2 | `600020` §1.1 사유 4: 1차 0-A가 `000150`/`000170`을 인용 0건 | SQL 실명은 `franchise_brands`·`legal_entities`이며 `companies`/`business_units`/`merchant_companies`와 접점 없음 | 원천 문서 어휘와 SQL 실명 사이에 대응 이력이 없다는 사실이 인용 0건과 정합 |
| 3 | `003020` §2: company와 legal_entity는 병렬 축 | `franchise_brands.tenant_id`는 NOT NULL FK→tenants, `legal_entities`에는 tenant 계열 컬럼 없음 | 두 축의 tenant 종속성이 비대칭 |
| 4 | `601501` §0.4: `hq_contact_*`가 사업자축에 중첩 | `franchise_brands.hq_contact_name/email/phone` 실재 | 문서 지적과 실측 부합 |
| 5 | `003020` §2: company ≠ legal_entity | `chk_brand_type` 허용값은 `FRANCHISE`/`CHAIN`/`VIRTUAL_BRAND`/`LICENSE`, `chk_legal_entities_entity_type`은 `SOLE_PROPRIETOR`/`CORPORATION`/`PARTNERSHIP`/`NON_PROFIT` | 두 축의 분류 체계가 겹치지 않음 — 문서의 축 분리 서술과 부합 |

**C-3. 문서에 없는 SQL 객체 (초과구현)**

| SQL 객체 | 어느 문서에도 정의 없음 | 비고 |
|---|---|---|
| `franchise_brands.royalty_rate_pct` | 로열티율 | 계약 조건이 브랜드 테이블에 존재 |
| `franchise_brands.contract_start_date/end_date` | 계약 기간 | 동상 |
| `franchise_brands.shared_membership/shared_menu_template` | 공유 플래그 | |
| `franchise_brands.parent_brand_id`, `brand_level` | 브랜드 계층 | A-4 어휘에 계층 개념 없음 |
| `franchise_brands.active_store_count` | 집계 캐시 컬럼 | |
| `franchise_brands.brand_color/logo_url/guidelines_url` | 브랜드 자산 | |
| `chk_brand_type` 값 `CHAIN`/`VIRTUAL_BRAND`/`LICENSE` | 브랜드 유형 3종 | 문서에 유형 분류 없음 |
| `chk_brand_status` 값 4종 | 브랜드 상태 축 | 문서에 브랜드 상태 축 없음 |
| Company 참조 함수 11개 | 정책 배포·대시보드·승인 | 어느 A 문서에도 함수 계약 정의 없음 |

**D. 로컬 실행 검증**

**D-1. 검증 결과**

| # | 확인 항목 | 실행 쿼리 | 결과 | 판정 |
|---|---|---|---|---|
| 1 | `franchise_brands`가 `company` 축의 구현체인지 (실제 행 의미 확인) | `SELECT id, tenant_id, brand_code, brand_name, brand_type, hq_store_id, brand_status, is_active FROM catchmenu_hq.franchise_brands` | **0행** — 판단 근거가 될 행 데이터 없음. 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님. | 미확인(데이터부재) |
| 2 | RLS ENABLE+FORCE 상태에서 비-postgres 접근이 실제로 차단되는지 | `BEGIN READ ONLY; SET LOCAL ROLE <role>; SELECT count(*) FROM catchmenu_hq.owners; ROLLBACK;` (대조군) | `authenticated`: `ERROR: permission denied for table owners` / `service_role`: `ERROR: permission denied for schema catchmenu_hq` / `catchmenu_authority_owner`: 성공, 0행 | 성공 |
| 3 | 11개 `SECURITY DEFINER` 함수가 실제 호출 시 성공하는지 | 실행하지 않음 | 함수들이 데이터 변경을 수행할 수 있어 쓰기 SQL 금지에 해당 (`601505` §4 금지 조항 계열) | 미확인(금지조항) |

**D-2. 실행하지 못한 항목**

| # | 항목 | 사유 | 대안 확인 방법 |
|---|---|---|---|
| 1 | Company 함수 11개 실제 호출 | 데이터 변경 가능성이 있고 쓰기 SQL이 금지됨 | 별도 허가된 rollback 격리 실행 검증 |

**D-3. 현재 DB 상태 (실측)**

| 대상 | 실측값 | 비고 |
|---|---|---|
| `franchise_brands` 행 수 | 0행 | 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님 |
| `franchise_brands` RLS | ENABLE + FORCE, 비-postgres GRANT 없음 | B-4와 일치 |

**E. 호출자·권한 통합** — 미수행

E단계 확인 항목:

- 11개 함수의 실제 호출자가 존재하는지, 권한검사가 의도대로 작동하는지.
- `franchise_brands.tenant_id`와 `legal_entities`의 tenant 비대칭(C-2 #3)이 런타임 격리에 미치는 영향.

---

### §4.2 Owner

**A. 문서 증거**

**A-1. Discovery Inventory**

| # | 문서 경로 | 분류 | 권위 | 처분 |
|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | Doctrine | ACTIVE | A-2 |
| 2 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` §4.1 판별 기준 | Doctrine | ACTIVE | A-2 |
| 3 | `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | Doctrine | ACTIVE | A-2 |
| 4 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Doctrine | ACTIVE | A-2 |
| 5 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Design | SUSPENDED | A-2 |
| 6 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | Design | SUSPENDED | A-2 |
| 7 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | Scope | SUSPENDED | A-6 |
| 8 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | Scope | SUSPENDED | A-6 |
| 9 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | Verification | SUSPENDED | A-3 |
| 10 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601506_Verification_Operational_Authority_Foundation_Ddl.md` | Verification | SUSPENDED | A-3 |
| 11 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601507_Verification_Operational_Authority_Foundation_Ddl.md` | Verification | SUSPENDED | A-3 |
| 12 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601508_Audit_Operational_Authority_Foundation_Ddl.md` | Audit | SUSPENDED | A-3 |
| 13 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | Audit | SUSPENDED | A-3 |
| 14 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | Audit | SUSPENDED | A-3 |
| 15 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | Audit | SUSPENDED | A-3 |
| 16 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | Scope | SUSPENDED | A-6 |
| 17 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | Baseline | SUSPENDED | A-6 |
| 18 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Audit | SUSPENDED | A-3 |
| 19 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Template | SUSPENDED | A-6 |
| 20 | `009030` 2026-08-11 역전파 블록 (`owners` 신규 개념) | Audit | SUSPENDED | A-3 |
| 21 | `010004` §4.1 "첫 사례" 블록 (전역 4테이블) | Audit | SUSPENDED | A-3 |

**파일명 검색 결과**: `*Owner*` 다수. 그중 `005121`(runtime owner)만 정의 문서로 등재.
`601443_Consolidated_Owner_Decision_Registry_Cross_Domain.md`는 의사결정 등록부 명칭이며 자연인 Owner를 정의하지 않아 A-6.

**A-2. Concept Source**

| # | 문서 경로 | 무엇을 정의하는가 | 권위 |
|---|---|---|---|
| 1 | `000170` §2·§4 | `primary_owner_user_id`, Merchant Account↔owner 관계 필드군 | ACTIVE |
| 2 | `010004` §4.1 판별 기준 | tenant-owned가 아닌 객체의 판별 기준 (하나의 행이 여러 tenant에 걸쳐 동일 실체를 가리키는가) | ACTIVE |
| 3 | `005121` §3–§5 | runtime owner = 구현·증거·릴리즈 책임 주체 (인물/테이블 아님) | ACTIVE |
| 4 | `007010` §3 | Admin Console 역할 `store_owner` | ACTIVE |
| 5 | `601501` §0.6·§2.4·§2.5 | `catchmenu_hq.owners` = 법적 사업주체와 관계 맺는 자연인; 소유권·대표권·역할·BRN 4개념 분리 | SUSPENDED |
| 6 | `601503` §9 | `owners`/`legal_entity_representatives`/`legal_entity_person_roles` DDL 및 SECURITY DEFINER 규칙 | SUSPENDED |

**A-3. Findings / Evidence**

| # | 출처 문서 | 발견 내용 | 권위 |
|---|---|---|---|
| 1 | `601510` Stage 11B 블라인드 감사 | Owner ≠ Representative ≠ shareholder 구분 필요; `SECURITY DEFINER` 보안경계; SOLE 대표 유일성 | 판정 HISTORICAL / finding 증거 유지 (`600020` §1.4) |
| 2 | `601509` Stage 11A 감사 | 0-A 산출물 감사 지적 | 판정 HISTORICAL |
| 3 | `601511` Stage 11A Final | `APPROVE_WITH_NOTES` 판정 | 역사적 판정, 현재 권위 없음 (`600020` §1.4) |
| 4 | `601508` Audit 초안 | 감사 초안 기록 | SUSPENDED |
| 5 | `601504` TestPlan | owners·representatives 검증 케이스 정의 | SUSPENDED |
| 6 | `601506` Verification (Stage 9) | 검증 실행 기록 | SUSPENDED |
| 7 | `601507` Verification (Stage 10) | 검증 정리 기록 | SUSPENDED |
| 8 | `601601` | `owners` 명칭 주의, 4개념 분리 관련 상위 문서 개정 초안 | SUSPENDED |
| 9 | `009030` 역전파 블록 층 A | 개념 등록부에 원래 없던 "자연인"이 신규 등장했다는 경고 | 층 A 유효 / 층 B 권위 없음 |
| 10 | `010004` §4.1 "첫 사례" 블록 | 전역 4테이블(`owners` 등)에 `tenant_id`가 없다는 기술 | 권위 없음 (`600020` §1.1) |

**A-4. Vocabulary**

| 어휘 | 출처 | 정의 | 비고 |
|---|---|---|---|
| owners (table) | `601501` §2.4.1 | 법적 사업주체와 관계 맺는 자연인; tenant admin·지분 보유자 아님 | `TERM_COLLISION` · 권위보류 |
| primary_owner_user_id | `000170` §4 | Merchant Account의 primary owner user (계정) | `TERM_COLLISION` |
| runtime owner | `005121` §3 | 런타임 영역별 책임·증거·릴리즈 담당 주체 | `TERM_COLLISION` |
| store_owner | `007010` §3 | Admin Console 역할 | `TERM_COLLISION` |
| Document Owner (metadata) | 다수 Readme | 문서 메타 `Owner: TBD` | `TERM_COLLISION` — 개념 Owner 아님 |
| owner relationship | `000170` §2 scope | Merchant Account↔owner 관계 필드군 | |
| legal_entity_representatives | `601501` §2.5 | 대표권의 유일한 진실원천 | 권위보류 |
| ownership (economic) | `601501` §0.6 #1 | 지분 — 미모델링 Open Item | 권위보류 |
| role_type OWNER | `601501` §0.6 | 조직 역할이며 economic ownership 아님 | `TERM_COLLISION` — 테이블명 `owners`와 같은 단어이나 다른 개념. B단계 실측: `chk_lepr_role_type` 허용값에 `OWNER` 존재 (2026-08-11 추가) · 권위보류 |
| ownership_percent | `601501` §2.3.1 | 사용 금지 — 소유권 모델 아님 | 권위보류 |

**A-5. Contradictions**

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `000170`: `primary_owner_user_id` (계정·user) | `601501` §2.4.1: `owners` (자연인, 비로그인) | 동일 "Owner" 어휘, 다른 개념 |
| 2 | `005121`: runtime owner (책임 매트릭스) | `601501`: `owners` 테이블 | 동일 영어 Owner, 다른 도메인 |
| 3 | `601501` §0.6: economic ownership 미모델링 | `601501` §2.3: `ownership_percent` 컬럼 존재 | 동일 설계 lineage 내 컬럼 vs 정책 기술 모순 |
| 4 | `009030` §2 본문: owner 개념 없음 | `009030` 역전파 블록: `owners` 신규 | 동일 파일 내 개념 등록부 확장 |
| 5 | `007010`: `store_owner` 역할 | `601501`: owners ≠ SaaS 계정 소유자 | Admin 역할 vs 법적 person |

**A-6. Excluded**

| 문서 경로 | 제외 사유 |
|---|---|
| `601502_Overview_Operational_Authority_Foundation_Ddl.md` | 0-A 범위·접근제어 맥락 문서 |
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | 4테이블 변경 계약·금지 조항 |
| `601500_Readme_Operational_Authority_Foundation.md` | 폴더 진입점 |
| `601512_Baseline_Summary.md` | 진행·복구 기준선 |
| `601701_Register_Stage0_Evidence_Collection.md` | 현 워크패킷 자기참조 |
| `docs/000001_Md_Rules.md` | 문서 Lifecycle `Owner:` 메타필드 |
| `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/601443_Consolidated_Owner_Decision_Registry_Cross_Domain.md` | Owner = 의사결정 등록부 명칭 |
| `docs/014000_pos_provider_integration_strategy/014720_Governance_POS_Provider_Integration_Decision_Gate.md` | decision owner (담당자) |
| `docs/000100_project_foundation/000180_Policy_Operator_Assignment_And_Backup_Responsibility.md` | operator assignment; owners 미정의 |
| `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601311_PassA_Blind_Reverse_Engineering_Common_Auth.md` | catchmenu_hq 스키마 서술; owners 정의 없음 |
| (기타 1,134건) | `Owner: TBD`, workpackage owner, copyright owner 등 메타·책임·일반 영어 |

**집계**: 본문 키워드 히트 1,159건(`owner|representative|ownership|소유|사업주|대표`) / A-1 등재 21건 / 단순 참조 제외 1,139건.

**정정 기록**: Cursor 조사의 "권위보류 14건"은 감사·검증 산출물이 개념원천과 합산된 수치다.
재분류 결과 SUSPENDED 15건 중 A-2는 `601501`·`601503` **2건**뿐이며, A-3이 8건, A-6이 5건이다.

**B. SQL 객체**

**B-1. 라이브 DB 객체**

| 종류 | 스키마 | 실명 | 비고 |
|---|---|---|---|
| TABLE | catchmenu_hq | owners | 7컬럼, RLS ENABLE+FORCE |
| TABLE | catchmenu_hq | legal_entities | 11컬럼, RLS ENABLE+FORCE |
| TABLE | catchmenu_hq | legal_entity_person_roles | 10컬럼, RLS ENABLE+FORCE |
| TABLE | catchmenu_hq | legal_entity_representatives | 9컬럼, RLS ENABLE+FORCE |
| COLUMN | catchmenu_hq | owners.* | `id uuid PK`, `owner_name text NOT NULL`, `contact_phone_hash text NULL`, `contact_email text NULL`, `is_active boolean default true`, `created_at/updated_at timestamptz default now()` |
| COLUMN | catchmenu_hq | legal_entities.* | `id uuid PK`, `entity_type text`, `legal_name text`, `business_registration_number text NULL`, `brn_normalized text GENERATED`, `corporate_registration_number text NULL`, `crn_normalized text GENERATED`, `tax_id text NULL`, `status text default ACTIVE`, `created_at/updated_at` |
| COLUMN | catchmenu_hq | legal_entity_person_roles.* | `id uuid PK`, `legal_entity_id FK`, `owner_id FK`, `role_type text`, `ownership_percent numeric NULL`, `effective_from date default CURRENT_DATE`, `effective_to date NULL`, `is_active boolean default true`, `created_at/updated_at` |
| COLUMN | catchmenu_hq | legal_entity_representatives.* | `id uuid PK`, `legal_entity_id FK`, `owner_id FK`, `representation_mode text`, `effective_from date default CURRENT_DATE`, `effective_to date NULL`, `is_active boolean default true`, `created_at/updated_at` |
| CHECK | catchmenu_hq | chk_legal_entities_entity_type | 허용값 `SOLE_PROPRIETOR` / `CORPORATION` / `PARTNERSHIP` / `NON_PROFIT` |
| CHECK | catchmenu_hq | chk_legal_entities_status | 허용값 `ACTIVE` / `SUSPENDED` / `CLOSED` |
| CHECK | catchmenu_hq | chk_legal_entities_crn_not_for_sole | `entity_type <> 'SOLE_PROPRIETOR' OR corporate_registration_number IS NULL` |
| CHECK | catchmenu_hq | chk_lepr_role_type | 허용값 `OWNER` / `REPRESENTATIVE` / `DIRECTOR` / `EXECUTIVE` / `INVESTOR` |
| CHECK | catchmenu_hq | chk_lepr_ownership_percent | NULL 또는 `0 ≤ ownership_percent ≤ 100` |
| CHECK | catchmenu_hq | chk_lepr_effective_range | `effective_to IS NULL OR effective_to >= effective_from` |
| CHECK | catchmenu_hq | chk_ler_representation_mode | 허용값 `SOLE` / `JOINT` / `INDIVIDUAL` |
| CHECK | catchmenu_hq | chk_ler_effective_range | `effective_to IS NULL OR effective_to >= effective_from` |
| UNIQUE | catchmenu_hq | uq_legal_entities_brn_normalized | `(brn_normalized) WHERE brn_normalized IS NOT NULL` |
| UNIQUE | catchmenu_hq | uq_legal_entities_crn_normalized | `(crn_normalized) WHERE crn_normalized IS NOT NULL` |
| UNIQUE | catchmenu_hq | uq_lepr_active | `(legal_entity_id, owner_id, role_type) WHERE is_active=true` |
| UNIQUE | catchmenu_hq | uq_ler_active | `(legal_entity_id, owner_id) WHERE is_active=true` |
| UNIQUE | catchmenu_hq | uq_ler_sole_active | `(legal_entity_id) WHERE representation_mode='SOLE' AND is_active=true` |
| FUNCTION | — | (없음) | 네 테이블을 직접 참조하는 라이브 함수 **0개** |

**B-2. migration 출처**

| 객체 | migration 파일 | 라인 |
|---|---|---:|
| legal_entities | `0168_create_operational_authority_foundation.sql` | L5 |
| BRN partial UNIQUE | 동일 | L54–56 |
| CRN partial UNIQUE | 동일 | L58–60 |
| owners | 동일 | L62 |
| legal_entity_person_roles | 동일 | L72 |
| uq_lepr_active | 동일 | L104 |
| legal_entity_representatives | 동일 | L119 |
| uq_ler_active | 동일 | L140 |
| RLS ENABLE/FORCE | 동일 | L210–224 |
| uq_ler_sole_active | `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | L5–8 |
| catchmenu_authority_owner role | 동일 | L17 |
| 네 테이블 GRANT | 동일 | L29–32 |

**B-3. 라이브 DB ↔ migration 불일치**

| 객체 | 라이브 | migration | 비고 |
|---|---|---|---|
| 네 테이블 | 있음 | 있음 | **없음** |
| uq_ler_sole_active | 있음 | 있음 | **없음** |
| catchmenu_authority_owner GRANT | 있음 | 있음 | **없음** |
| Owner 관련 함수 | 0개 | `0168`/`0169`에 생성 없음 | **없음** |

**B-4. RLS / GRANT**

| 테이블 | RLS | FORCE | 비-postgres GRANT |
|---|---|---|---|
| owners | true | true | `catchmenu_authority_owner`: SELECT/INSERT/UPDATE/DELETE |
| legal_entities | true | true | `catchmenu_authority_owner`: SELECT/INSERT/UPDATE/DELETE |
| legal_entity_person_roles | true | true | `catchmenu_authority_owner`: SELECT/INSERT/UPDATE/DELETE |
| legal_entity_representatives | true | true | `catchmenu_authority_owner`: SELECT/INSERT/UPDATE/DELETE |

총 16개 grant 행이며 전부 `is_grantable=NO`. `catchmenu_authority_owner`는 `nologin` + `bypassrls`(`0169` L17–19)이며 `postgres`에 부여됨(`0169` L35).

**B-5. SQL 대응물이 없는 문서 어휘**

| 문서 어휘 | 출처(A-4) | SQL 대응물 | 비고 |
|---|---|---|---|
| persons | A-4 미등재 (Codex B단계에서 후보로 제시) | 없음 | `owners`가 존재하나 Codex는 동일성 판단 안 함 |
| primary_owner_user_id | `000170` §4 | 없음 | `tenants` 10컬럼에 해당 컬럼 없음 |
| runtime owner | `005121` §3 | 없음 | 책임 매트릭스 개념이며 SQL 대응물 성격 아님 |
| store_owner | `007010` §3 | 없음 | |
| Document Owner (metadata) | 다수 Readme | 없음 | 문서 메타필드 |

**C. 문서-SQL 일치**

**C-1. 문서 어휘 ↔ SQL 객체 대응**

| A-4 어휘 | 출처 문서 | SQL 객체 | 대응 상태 |
|---|---|---|---|
| owners (table) | `601501` §2.4.1 | `catchmenu_hq.owners` | 일치 |
| legal_entity_representatives | `601501` §2.5 | `catchmenu_hq.legal_entity_representatives` | 일치 |
| role_type OWNER | `601501` §0.6 | `chk_lepr_role_type` 허용값 `OWNER` | 일치 |
| ownership_percent | `601501` §2.3.1 | `legal_entity_person_roles.ownership_percent` + `chk_lepr_ownership_percent` | 초과구현 — 문서는 "사용 금지" 상태로 서술 |
| ownership (economic) | `601501` §0.6 #1 | `legal_entity_person_roles.ownership_percent` | 초과구현 — 문서는 "미모델링 Open Item" |
| primary_owner_user_id | `000170` §4 | 없음 | 미구현 |
| owner relationship | `000170` §2 | 없음 | 미구현 |
| runtime owner | `005121` §3 | 없음 | 미구현 |
| store_owner | `007010` §3 | 없음 | 미구현 |
| Document Owner (metadata) | 다수 Readme | 없음 | 미구현 |
| persons | A-4 미등재 (Codex B-5) | 없음 | 미구현 |

**C-2. 문서 서술 ↔ SQL 실측 불일치**

| # | 문서 서술 (출처 §) | SQL 실측 | 어긋나는 지점 |
|---|---|---|---|
| 1 | `601512` §2.3: 접근은 postgres 소유 `SECURITY DEFINER` 함수 경유만 | 네 테이블 참조 함수 **0개**. 비-postgres GRANT는 `catchmenu_authority_owner` 하나뿐 | 서술된 접근 경로가 SQL에 존재하지 않음. 의도적 미구현인지 미완인지는 **판정하지 않음** |
| 2 | `601501` §2.3.1: `ownership_percent` 사용 금지 | `ownership_percent numeric(5,2)` 및 `chk_lepr_ownership_percent`(0~100) 실재 | 금지 서술과 컬럼·제약 존재가 공존 |
| 3 | `601501` §0.6: `role_type` `OWNER`는 조직 역할이며 economic ownership 아님 | `chk_lepr_role_type`에 `OWNER` 존재. 동일 테이블에 `ownership_percent` 공존 | 역할 축과 지분 축이 같은 테이블에 함께 존재 |
| 4 | `0168` L210–225: RLS ENABLE+FORCE 선언. `0168` 헤더 L3은 "No RPC rewrites, data promotion, grants, or RLS policies" | RLS true / FORCE true이나 **정책 0개**. 유일한 비-postgres GRANT 대상 `catchmenu_authority_owner`는 `bypassrls` | 정책 없는 FORCE RLS와 `bypassrls` 역할의 조합이 실제로 어떤 접근 결과를 내는지 **미확인** |
| 5 | `601510`: Owner ≠ Representative ≠ shareholder 구분 필요 | `owners` / `legal_entity_representatives` / `role_type` / `ownership_percent`로 분리 존재 | 분리 구조는 있으나 shareholder 축은 컬럼 1개뿐이며 그 컬럼이 §2.3.1에서 사용 금지 |
| 6 | `601501` §2.5: 대표권의 유일한 진실원천 | `uq_ler_sole_active` = `(legal_entity_id) WHERE representation_mode='SOLE' AND is_active=true` | SOLE 유일성만 제약. `JOINT`/`INDIVIDUAL`은 `uq_ler_active`로 (법인, 사람) 쌍만 제한 |

**C-3. 문서에 없는 SQL 객체 (초과구현)**

| SQL 객체 | 어느 문서에도 정의 없음 | 비고 |
|---|---|---|
| `legal_entities.tax_id` | 세무 식별자 | A 문서 어휘에 없음 |
| `legal_entities.brn_normalized` / `crn_normalized` | 정규화 생성 컬럼 | GENERATED ALWAYS STORED |
| `chk_legal_entities_crn_not_for_sole` | 개인사업자 법인등록번호 금지 규칙 | 업무규칙이나 문서 선언 없음 |
| `chk_legal_entities_status` 값 3종 | 법인 상태 축 | 문서에 법인 상태 축 없음 |
| `role_type` 값 `DIRECTOR` / `EXECUTIVE` / `INVESTOR` | 조직 역할 3종 | 문서는 OWNER/REPRESENTATIVE만 언급 |
| `representation_mode` 값 `JOINT` / `INDIVIDUAL` | 대표 유형 2종 | 문서는 SOLE 유일성만 서술 |
| `owners.contact_phone_hash` / `contact_email` | 연락처 | 개인정보 취급 규칙 미기술 |
| `effective_from` / `effective_to` 시간 경계 | 역할·대표권 유효기간 | 문서에 시간 축 서술 없음 |
| `catchmenu_authority_owner` 역할 | DB 역할 | `nologin` + `bypassrls` |

**D. 로컬 실행 검증**

**D-1. 검증 결과**

| # | 확인 항목 | 실행 쿼리 | 결과 | 판정 |
|---|---|---|---|---|
| 1 | 정책 0개 + FORCE RLS + `bypassrls` 역할 조합에서 **SELECT**가 누구에게 성공하는지 (C-2 #4) | `BEGIN READ ONLY; SET LOCAL ROLE <role>; SELECT count(*) FROM <4테이블>; ROLLBACK;` | `postgres` 성공 / `catchmenu_authority_owner` 네 테이블 모두 성공, 각 0행 / `authenticated` `permission denied for table owners` / `service_role` `permission denied for schema catchmenu_hq` | 성공 |
| 2 | 같은 조합에서 **INSERT**가 누구에게 성공하는지 (C-2 #4) | 실행하지 않음 | INSERT 명시적 금지 (`601505` §4 금지 조항 계열) | 미확인(금지조항) |
| 3 | `ownership_percent`에 실제 값이 들어 있는지, 사용 금지 서술이 데이터로도 지켜졌는지 (C-2 #2) | `SELECT ownership_percent, count(*) FROM catchmenu_hq.legal_entity_person_roles GROUP BY 1` | 대상 테이블 **0행**. 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님. | 미확인(데이터부재) |
| 4 | `uq_ler_sole_active` 위반 시도가 실제로 거부되는지 (C-2 #6) | 실행하지 않음 | 위반 재현에 INSERT 또는 UPDATE가 필요하며 쓰기 SQL 금지 (`601505` §4 금지 조항 계열) | 미확인(금지조항) |
| 5 | `role_type` 5종·`representation_mode` 3종 중 실제 사용 값 분포 (C-3) | 각 컬럼 `GROUP BY` | 두 테이블 모두 **0행**. 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님. | 미확인(데이터부재) |

**D-2. 실행하지 못한 항목**

| # | 항목 | 사유 | 대안 확인 방법 |
|---|---|---|---|
| 1 | Owner INSERT 성공 주체 | INSERT 명시적 금지 | 별도 허가된 rollback 격리 권한 테스트 |
| 2 | `uq_ler_sole_active` 위반 재현 | INSERT/UPDATE 필요 | 별도 허가된 rollback 격리 제약 테스트 |

**D-3. 현재 DB 상태 (실측)**

| 대상 | 실측값 | 비고 |
|---|---|---|
| `owners` / `legal_entities` / `legal_entity_person_roles` / `legal_entity_representatives` | **각 0행** | 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님 |
| 네 테이블 RLS | `rowsecurity=true`, `relforcerowsecurity=true`, **정책 0개** | C-2 #4가 지적한 조합이 실측으로 확인됨 |
| `catchmenu_authority_owner` 역할 속성 | `rolcanlogin=false`, `rolbypassrls=true`, `rolsuper=false`, `rolinherit=true` | NOLOGIN + BYPASSRLS |
| `catchmenu_authority_owner` 멤버 | `postgres`만 2행 (`admin_option` false 1 / true 1) | 이 역할을 보유한 다른 주체 없음 |
| `catchmenu_authority_owner` → 네 테이블 SELECT | 네 테이블 모두 성공, 각 0행 | |
| `authenticated` → `owners` | `ERROR: permission denied for table owners` | |
| `service_role` → `catchmenu_hq` | `ERROR: permission denied for schema catchmenu_hq` | 스키마 단계에서 차단 |

**E. 호출자·권한 통합** — 미수행

E단계 확인 항목:

- 함수 0개 상태에서 애플리케이션이 네 테이블에 어떤 경로로 접근하는지, 또는 접근하지 않는지 (C-2 #1). D-1 #1에서 `authenticated`·`service_role` 차단은 확인됨 — 남은 질문은 실제 접근 경로의 존재 여부.
- `601512` §2.3이 서술한 함수 경유 접근이 구현 예정인지 폐기됐는지 — 1단계 Human 결정 대상.

---

### §4.3 Tenant

**A. 문서 증거**

**A-1. Discovery Inventory**

| # | 문서 경로 | 분류 | 권위 | 처분 |
|---|---|---|---|---|
| 1 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Doctrine | ACTIVE | A-2 |
| 2 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Doctrine | ACTIVE | A-2 |
| 3 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | Doctrine | ACTIVE | A-2 |
| 4 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | Doctrine | ACTIVE | A-2 |
| 5 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | Doctrine | ACTIVE | A-2 |
| 6 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | Doctrine | ACTIVE | A-2 |
| 7 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Doctrine | ACTIVE | A-2 |
| 8 | `docs/012000_implementation_mapping/012020_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Doctrine | ACTIVE | A-2 |
| 9 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Doctrine | ACTIVE | A-2 |
| 10 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Doctrine | ACTIVE | A-2 |
| 11 | `docs/004900_security_runtime_test_catalog/004920_Policy_Tenant_Store_RLS_Access_Control_Test_Catalog.md` | Verification | ACTIVE | A-3 |
| 12 | `docs/014000_pos_provider_integration_strategy/014097_Policy_SaaS_Admin_Tenant_Store_Directory.md` | Reference | ACTIVE | A-6 |
| 13 | `docs/026000_analytics_reporting_bi/026040_Boundary_Cross_Tenant_Benchmark_And_Data_Sharing.md` | Doctrine | ACTIVE | A-2 |
| 14 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010461_Policy_Multi_Tenant_Finance_SaaS.md` | Doctrine | ACTIVE | A-2 |
| 15 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | Doctrine | ACTIVE | A-2 |
| 16 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Design | SUSPENDED | A-2 |
| 17 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | Design | SUSPENDED | A-2 |
| 18 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | Scope | SUSPENDED | A-6 |
| 19 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Audit | SUSPENDED | A-3 |
| 20 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Template | SUSPENDED | A-6 |
| 21 | `000170` 2026-08-11 역전파 블록 (§14/§15/§16 SUPERSEDED 선언, 이후 철회) | Audit | SUSPENDED | A-3 |
| 22 | `003020` 2026-08-11 역전파 블록 | Audit | SUSPENDED | A-3 |

**파일명 검색 결과**: `*Tenant*` 27건. 그중 정의·규정 문서만 위 표에 등재했고, POS Gateway tenant binding 등 tenant 사용 맥락 문서는 A-6.

**A-2. Concept Source**

| # | 문서 경로 | 무엇을 정의하는가 | 권위 |
|---|---|---|---|
| 1 | `003020` §2–§3 | tenant = SaaS customer boundary·contract scope; store/legal entity와 비동치 | ACTIVE |
| 2 | `003010` §3 | Tenant principle — billing·admin·package는 tenant-level | ACTIVE |
| 3 | `009030` §2 | 개념 `tenant`: SaaS customer or contract boundary | ACTIVE |
| 4 | `009070` §2 | tenant 축 정렬·store 소유 관계 | ACTIVE |
| 5 | `010004` §2–§4 | `tenant_id` 필수·격리 빔·cross-tenant 금지 | ACTIVE |
| 6 | `010640` | Tenant scope envelope·컨텍스트 봉투 | ACTIVE |
| 7 | `007010` §2–§3.2 | Admin tenant 축·`tenant_admin` 역할 | ACTIVE |
| 8 | `012020` / `012021` | Tenant/Store context → RLS 매핑 정책 | ACTIVE |
| 9 | `020170` | Cross-tenant isolation governance | ACTIVE |
| 10 | `026040` | Cross-tenant benchmark 경계 | ACTIVE |
| 11 | `010461` | Multi-tenant finance SaaS 경계 | ACTIVE |
| 12 | `000170` §4 | `merchant_account` = top-level SaaS customer relationship | ACTIVE |
| 13 | `601501` §3 | `tenants` 유지; `tenant_status`/`isolation_state` 2컬럼 분리 | SUSPENDED |
| 14 | `601503` | tenants 상태·격리 DDL | SUSPENDED |

**A-3. Findings / Evidence**

| # | 출처 문서 | 발견 내용 | 권위 |
|---|---|---|---|
| 1 | `004920` | Tenant/Store RLS 접근제어 테스트 카탈로그 | ACTIVE |
| 2 | `601601` §4.2 | `010004` §4가 `tenant-owned` 한정인데 "모든 객체"로 오독되어 왔음 | SUSPENDED (finding 증거가치 유지) |
| 3 | `601601` §4.3 | `000170` §14/§16의 store 서비스상태·체험상태 어휘가 구현된 적 없음 | SUSPENDED (finding 증거가치 유지) |
| 4 | `000170` 역전파 블록 | §14/§15/§16을 SUPERSEDED로 선언했으나 2026-08-10 판정으로 철회됨; 세 절은 미구현 상태의 유효한 정책 의도 | 선언 철회됨 |
| 5 | `003020` 역전파 블록 층 A | tenant 축과 legal_entity 축 혼동 경고 | 층 A 유효 / 층 B 권위 없음 |

**A-4. Vocabulary**

| 어휘 | 출처 | 정의 | 비고 |
|---|---|---|---|
| tenant | `003020` §2 | SaaS customer boundary and contract scope | |
| merchant_account | `000170` §4 | Top-level SaaS customer relationship | tenant와 병기·대체 |
| tenant_id | `010004` §4 | All tenant-owned objects must carry | |
| tenant_status | `601501` §3 | 서비스 가능 여부 축 | 권위보류 |
| isolation_state | `601501` §3 | 격리/차단 축; tenant_status와 분리 | 권위보류 |
| service_status | `000170` §4 | Merchant Account recommended field | `TERM_COLLISION` — `000170` §7은 동일 어휘를 store 범위로 사용 |
| trial_status | `000170` §4 | Trial state on merchant account | |
| tenants (table) | `601501` §0.2 | 기존 `catchmenu_hq.tenants` 유지 | 권위보류 |
| multi-tenant | `010004` §2 | Platform spine isolation model | |

**A-5. Contradictions**

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `003020` §2: tenant 최상위 | `000170` §4: merchant_account 최상위 | SaaS 고객 경계 명칭 |
| 2 | `000170`: `service_status` / `trial_status` | `601501` §3: `tenant_status` / `isolation_state` | 상태 축 이름·개수 |
| 3 | `003020` §6 Open Decisions: company/legal_entity required 미결 | `003020` 역전파 블록: LegalEntity MVP 필수 주장 | 동일 파일 §6 vs 블록 (§6은 2026-08-10 판정으로 다시 열림) |
| 4 | `601501` §0.3: legal_entities↔tenants 직접 FK 없음 | `010004` §4: material objects need `tenant_id` | 전역 legal_entity vs tenant 격리 요건 |
| 5 | `600020` §2.2: `000170`·`003020` 미검증 | `601601`: 1단계 업무규칙·역전파 초안 존재 | 검증 전 문서 vs 후속 등록 |

**A-6. Excluded**

| 문서 경로 | 제외 사유 |
|---|---|
| `601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | tenant_status 관련 금지·호출 금지 계약 |
| `601701_Register_Stage0_Evidence_Collection.md` | 현 워크패킷 자기참조 |
| `docs/014000_pos_provider_integration_strategy/014097_Policy_SaaS_Admin_Tenant_Store_Directory.md` | directory 목록; tenant 축 재정의 없음 |
| `docs/014000_pos_provider_integration_strategy/014153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md` | tenant/store binding 구현; tenant 정의 없음 |
| `docs/600000_implementation_lifecycle/600600_waiting_order_session/600672_Logic_*.md` | RPC에서 `tenant_id` 파라미터만 |
| `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | onboarding 절차; tenant 축 재정의 없음 |
| `docs/000005_Index_Document_Number.md` | 인덱스 |
| `docs/700900_runtime_flow/701030_Flow_POS_Gateway_Store_Offline_Local_Ledger_And_Resync.md` | tenant context 전제만 |
| (기타 679건) | "under tenant", RLS 내 `tenant_id` 등 참조 |

**집계**: 본문 키워드 히트 704건 / A-1 등재 22건 / 단순 참조 제외 684건.

**B. SQL 객체**

**B-1. 라이브 DB 객체**

| 종류 | 스키마 | 실명 | 비고 |
|---|---|---|---|
| TABLE | catchmenu_hq | tenants | 10컬럼, RLS ENABLE+FORCE |
| COLUMN | catchmenu_hq | tenants.id | uuid PK, default `gen_random_uuid()` |
| COLUMN | catchmenu_hq | tenants.tenant_code | text NOT NULL, UNIQUE |
| COLUMN | catchmenu_hq | tenants.tenant_name | text NOT NULL |
| COLUMN | catchmenu_hq | tenants.tenant_type | text NOT NULL, default `BRAND` |
| COLUMN | catchmenu_hq | tenants.plan_tier | text NOT NULL, default `STANDARD` |
| COLUMN | catchmenu_hq | tenants.is_active | boolean NOT NULL, default true |
| COLUMN | catchmenu_hq | tenants.created_at/updated_at | timestamptz NOT NULL, default `now()` |
| COLUMN | catchmenu_hq | tenants.tenant_status | text NOT NULL, default `TRIAL` |
| COLUMN | catchmenu_hq | tenants.isolation_state | text NOT NULL, default `NONE` |
| CHECK | catchmenu_hq | chk_tenants_type | 허용값 `BRAND` / `FRANCHISE` / `INDEPENDENT` / `TEST` |
| CHECK | catchmenu_hq | chk_tenants_plan | 허용값 `LITE` / `STANDARD` / `PRO` / `ENTERPRISE` |
| CHECK | catchmenu_hq | chk_tenants_status | 허용값 `ACTIVE` / `TRIAL` / `SUSPENDED` / `CANCELLED` / `TERMINATED` |
| CHECK | catchmenu_hq | chk_tenants_isolation_state | 허용값 `NONE` / `ISOLATED` |
| FUNCTION | catchmenu_audit | run_isolation_audit | SECURITY DEFINER · `catchmenu_audit, catchmenu_common, catchmenu_hq, catchmenu_pos, catchmenu_payment, catchmenu_kds, catchmenu_store, catchmenu_ledger` |
| FUNCTION | catchmenu_common | get_hq_dashboard | SECURITY DEFINER · `catchmenu_common, catchmenu_hq` |
| FUNCTION | catchmenu_common | get_saas_revenue_report | SECURITY DEFINER · `catchmenu_common, catchmenu_hq` |
| FUNCTION | catchmenu_common | get_store_bootstrap | SECURITY DEFINER · `catchmenu_common, catchmenu_hq, catchmenu_store, catchmenu_pos, catchmenu_kds, catchmenu_agent, catchmenu_ledger` |
| FUNCTION | catchmenu_common | get_system_health_all | SECURITY DEFINER · `catchmenu_common, catchmenu_hq` |
| FUNCTION | catchmenu_common | get_tenant_list | SECURITY DEFINER · `catchmenu_common, catchmenu_hq` |
| FUNCTION | catchmenu_common | isolate_tenant | SECURITY DEFINER · `catchmenu_common, catchmenu_hq, catchmenu_ledger, catchmenu_audit` |
| FUNCTION | catchmenu_common | manage_subscription | SECURITY DEFINER · `catchmenu_common, catchmenu_hq, catchmenu_ledger` |
| FUNCTION | catchmenu_common | onboard_tenant | SECURITY DEFINER · `catchmenu_common, catchmenu_hq, catchmenu_store` |
| FUNCTION | catchmenu_common | provision_tenant | SECURITY DEFINER · `catchmenu_common, catchmenu_hq, catchmenu_store, catchmenu_ledger` |

`catchmenu_hq.tenants`를 직접 참조하는 함수는 10개이며 전부 `SECURITY DEFINER`다.

**B-2. migration 출처**

| 객체 | migration 파일 | 라인 |
|---|---|---:|
| tenants | `0002_create_hq_tenant_store.sql` | L8 |
| 초기 제약/트리거 | 동일 | L8–39 |
| RLS ENABLE/FORCE | `0021_enable_rls.sql` | L10–12 |
| tenant_status | `0168_create_operational_authority_foundation.sql` | L151–152 |
| isolation_state | 동일 | L154–155 |
| 상태 CHECK | 동일 | L165–190 |
| provision_tenant | `0082_create_saas_billing_rpc.sql` | L426 |
| get_tenant_health | `0090_create_multitenant_isolation_rpc.sql` | L1097 |
| isolate_tenant | 동일 | L1257 |
| get_hq_dashboard | `0112_create_hq_admin_rpc.sql` | L75 |
| get_tenant_list | 동일 | L247 |
| onboard_tenant | 동일 | L374 |
| manage_subscription | 동일 | L507 |

**B-3. 라이브 DB ↔ migration 불일치**

| 객체 | 라이브 | migration | 비고 |
|---|---|---|---|
| tenants 구조 | 있음 | 있음 | 존재 여부 불일치 **없음** |
| tenant_status / isolation_state | 있음 | `0168`에 있음 | **없음** |
| 위 10개 함수 | 있음 | 선언/후속 정의 존재 | 존재 여부 불일치 **없음** |

**B-4. RLS / GRANT**

| 테이블 | RLS | FORCE | 비-postgres GRANT |
|---|---|---|---|
| tenants | true | true | 없음 |

**B-5. SQL 대응물이 없는 문서 어휘**

| 문서 어휘 | 출처(A-4) | SQL 대응물 | 비고 |
|---|---|---|---|
| merchant_accounts | `000170` §4 (`merchant_account`) | 없음 | `tenants`가 존재하나 Codex는 동일성 판단 안 함 |
| service_status | `000170` §4 | 없음 | `tenants` 10컬럼에 없음 |
| trial_status | `000170` §4 | 없음 | `tenant_status`의 값 `TRIAL`은 존재하나 별도 컬럼 아님 |

**C. 문서-SQL 일치**

**C-1. 문서 어휘 ↔ SQL 객체 대응**

| A-4 어휘 | 출처 문서 | SQL 객체 | 대응 상태 |
|---|---|---|---|
| tenant | `003020` §2 | `catchmenu_hq.tenants` | 일치 |
| tenants (table) | `601501` §0.2 | `catchmenu_hq.tenants` | 일치 |
| tenant_id | `010004` §4 | `franchise_brands.tenant_id`, `stores.tenant_id`, `store_groups.tenant_id`, `store_group_members.tenant_id` | 일치 |
| tenant_status | `601501` §3 | `tenants.tenant_status` + `chk_tenants_status` | 일치 |
| isolation_state | `601501` §3 | `tenants.isolation_state` + `chk_tenants_isolation_state` | 일치 |
| multi-tenant | `010004` §2 | 조사된 9테이블 전부 RLS ENABLE+FORCE | 일치 |
| merchant_account | `000170` §4 | `catchmenu_hq.tenants` (후보) | 이름다름 |
| service_status | `000170` §4 | 없음 | 미구현 |
| trial_status | `000170` §4 | `tenants.tenant_status` 값 `TRIAL` | 이름다름 |

**C-2. 문서 서술 ↔ SQL 실측 불일치**

| # | 문서 서술 (출처 §) | SQL 실측 | 어긋나는 지점 |
|---|---|---|---|
| 1 | `000170` §4: `service_status`·`trial_status`를 merchant_account의 권장 필드로 기술 | 두 컬럼 없음. `TRIAL`은 `tenant_status`의 허용값 중 하나 | 문서는 독립 상태 축 2개, SQL은 단일 컬럼의 값 |
| 2 | `003020` §2: tenant 최상위 / `000170` §4: merchant_account 최상위 | SQL 최상위는 `tenants`. `merchant_accounts` 없음 | 두 문서 명칭 중 하나만 SQL에 존재. **어느 쪽이 옳은지는 판정하지 않음** |
| 3 | `601501` §3: `tenant_status`와 `isolation_state`는 직교 | 두 컬럼 모두 NOT NULL + 독립 CHECK | 문서 서술과 실측 부합 |
| 4 | `010004` §4: tenant-owned 객체는 `tenant_id` 필수 | `legal_entities`·`owners`·`legal_entity_person_roles`·`legal_entity_representatives`에 `tenant_id` 없음 | `601601` §4.2가 지적한 "모든 객체" 오독 지점과 동일 위치 |
| 5 | `000170` §4: merchant_account에 owner 관계 필드군 | `tenants` 10컬럼에 owner 계열 컬럼 없음 | 문서 필드군이 SQL에 부재 |
| 6 | `010004` §2: multi-tenant 격리 | `tenants` RLS true/FORCE true, 비-postgres GRANT 없음, 참조 함수 10개 전부 SECURITY DEFINER | 접근이 실제로 함수 경유로만 이뤄지는지 **미확인** |

**C-3. 문서에 없는 SQL 객체 (초과구현)**

| SQL 객체 | 어느 문서에도 정의 없음 | 비고 |
|---|---|---|
| `tenants.tenant_type` + `chk_tenants_type` 4종 | tenant 유형 축 | A-4 어휘에 tenant 유형 개념 없음 |
| `tenants.plan_tier` + `chk_tenants_plan` 4종 | 요금제 등급 축 | `003010` §3은 package를 tenant-level로만 서술 |
| `tenants.tenant_code` UNIQUE | 테넌트 코드 | |
| `tenants.is_active` | `tenant_status`와 별개의 활성 플래그 | 상태 축 중복 가능성 |
| 참조 함수 10개 | 프로비저닝·격리·구독관리·대시보드 | 어느 A 문서에도 함수 계약 정의 없음 |

**D. 로컬 실행 검증**

**D-1. 검증 결과**

| # | 확인 항목 | 실행 쿼리 | 결과 | 판정 |
|---|---|---|---|---|
| 1 | `tenants.is_active`와 `tenant_status`가 실제 데이터에서 어떤 관계인지 (C-3, 상태 축 중복 가능성) | `SELECT is_active, tenant_status, isolation_state, count(*) FROM catchmenu_hq.tenants GROUP BY 1,2,3` | `(true, TRIAL, NONE) = 1`. `tenant_status='ACTIVE'` 0행 | 성공 |
| 2 | `isolate_tenant` 호출이 `isolation_state`를 실제로 변경하는지 (C-2 #3) | 실행하지 않음 | `isolate_tenant`는 `601505` §3.1 **호출 금지 함수** | 미확인(금지조항) |
| 3 | 전역 4테이블에 `tenant_id`가 없는 상태에서 cross-tenant 조회가 실제로 발생 가능한지 (C-2 #4) | 실행하지 않음 | 실제 접근 주체·권한·tenant 경계 검증은 E단계 소관 | 범위밖(E) |

**D-2. 실행하지 못한 항목**

| # | 항목 | 사유 | 대안 확인 방법 |
|---|---|---|---|
| 1 | `isolate_tenant` 상태 변경 | 함수 호출 절대 금지 (`601505` §3.1) | 함수 정의 정적 조회만 가능 |
| 2 | 전역 테이블 cross-tenant 접근 | E단계의 호출자·권한·tenant 경계 검증 | E단계에서 실제 application principal과 접근 함수 추적 |

**D-3. 현재 DB 상태 (실측)**

| 대상 | 실측값 | 비고 |
|---|---|---|
| `tenants` | **1행** (`tenant_status=TRIAL`, `isolation_state=NONE`, `is_active=true`) | `ACTIVE` **0행** |
| `manage_subscription` (방벽 ①) | 소스에 `select id, company_name, tenant_status from catchmenu_hq.tenants` 존재. `tenants.company_name` 컬럼은 **0개** | 존재하지 않는 컬럼을 조회하는 함수 |
| `isolate_tenant` 파라미터명 (방벽 ②) | 실제 인자 `p_tenant_id uuid, p_isolation_reason text, p_isolate boolean, p_actor_id uuid, p_locale text`. `manage_subscription` 소스에는 `p_reason := ...` 호출 존재 | 호출부와 정의부의 파라미터명 불일치 |
| `serviceable` 계열 함수 | **0개** (`proname='serviceable'` 및 `%serviceable%` 모두 0행) | `000170` §4/§7의 service_status 어휘에 대응하는 헬퍼 없음 |
| `pg_cron` | extension `1.6.4` 설치. `catchmenu_common.pg_cron_jobs` 존재 | 횡단 항목 |
| `pg_cron_jobs.is_registered` 분포 | `false` 9건 / `true` 38건. 양쪽 모두 `pg_cron_job_id` 전건 NULL | `cron.job` 실제 행 수 **0** |

**E. 호출자·권한 통합** — 미수행

E단계 확인 항목:

- 10개 함수의 실제 호출자와 권한검사 경로.
- 비-postgres GRANT가 없는 상태에서 애플리케이션이 `tenants`를 어떻게 읽는지 (C-2 #6).
- `merchant_account` 어휘를 쓰는 문서(`000170`)가 실제 런타임 어느 지점을 가리키는지 — 1단계 Human 결정 대상.
- 전역 4테이블에 `tenant_id`가 없는 상태에서 cross-tenant 조회가 실제로 발생 가능한지 — D-1 #3에서 **범위밖(E)** 로 이관됨.

---

### §4.4 HQ

**A. 문서 증거**

**A-1. Discovery Inventory**

| # | 문서 경로 | 분류 | 권위 | 처분 |
|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | Doctrine | ACTIVE | A-2 |
| 2 | `docs/000100_project_foundation/000140_Guide_Organization_Core.md` | Doctrine | ACTIVE | A-2 |
| 3 | `docs/014000_pos_provider_integration_strategy/014016_Policy_Franchise_Store_Billing_HQ_SaaS_Fee_Split.md` | Doctrine | ACTIVE | A-2 |
| 4 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Design | SUSPENDED | A-2 |
| 5 | `docs/600000_implementation_lifecycle/601300_fable_blind_reverse_engineering_audit/601310_domain_00_common_auth/601311_PassA_Blind_Reverse_Engineering_Common_Auth.md` | Audit | SUSPENDED | A-3 |
| 6 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | Scope | SUSPENDED | A-6 |
| 7 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Template | SUSPENDED | A-6 |

**파일명 검색 결과**: `*HQ*` / `*Headquarters*` **0건**.
HQ는 본문과 DB 스키마명(`catchmenu_hq`)으로만 등장한다. 이 사실만 기록하며, 결함 여부는 판정하지 않는다.

**A-2. Concept Source**

| # | 문서 경로 | 무엇을 정의하는가 | 권위 |
|---|---|---|---|
| 1 | `000150` (Purpose 영역) | CatchMenu HQ = company model administrative interface | ACTIVE |
| 2 | `000140` §23 | CatchMenu HQ = administrative surface; Organization Core 구조 관리 UI | ACTIVE |
| 3 | `014016` | Franchise HQ vs store billing·SaaS fee split | ACTIVE |
| 4 | `601501` §0.2 #7 | HQ = `catchmenu_hq` 스키마 자체; 변경 없음 | SUSPENDED |

**A-3. Findings / Evidence**

| # | 출처 문서 | 발견 내용 | 권위 |
|---|---|---|---|
| 1 | `601311` PassA 역설계 감사 | `catchmenu_hq` 스키마가 프랜차이즈 본사(HQ)→tenant→store 계층으로 구성되어 있다는 역설계 관찰 | SUSPENDED (finding 증거가치 유지) |
| 2 | `601501` ERD | `store_group_members.member_role` CHECK 값에 `LEADER`/`MEMBER`/`HQ` 존재 | SUSPENDED |
| 3 | `601501` §0.4 | `franchise_brands.hq_contact_*` 컬럼이 사업자축에 중첩되어 있음 | SUSPENDED |

**A-4. Vocabulary**

| 어휘 | 출처 | 정의 | 비고 |
|---|---|---|---|
| HQ | `601501` §0.2 #7 | `catchmenu_hq` schema itself | `TERM_COLLISION` · 권위보류 |
| CatchMenu HQ | `000140` §23, `000150` | Administrative surface/interface | `TERM_COLLISION` |
| 본사 | `900160` 등 patent 대역 | Franchise operations HQ (광고·긴급공지·권한) | `TERM_COLLISION` — 스키마 HQ와 다른 맥락 |
| member_role HQ | `601501` ERD | store group member role 값 | `TERM_COLLISION` |
| franchise_hq | `014016` | Franchise billing HQ | `TERM_COLLISION` |
| catchmenu_hq | `601311`, `601501` §2.7 | DB 스키마명; PostgREST 미노출 | 권위보류 |
| hq_contact_* | `601501` §0.4 | `franchise_brands` 컬럼 | 권위보류 |

**A-5. Contradictions**

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `601501` §0.2: HQ = DB schema | `000140`/`000150`: CatchMenu HQ = admin UI/surface | HQ = 인프라 vs 제품 UI |
| 2 | `601501`: HQ 변경 없음 | `601501` §0.4: `franchise_brands.hq_contact_*` 사업자축 중첩 | HQ 스키마 vs brand 테이블 HQ 필드 |
| 3 | `601501` §0.5: 운영본부 = `store_groups` REGION | `601501` §0.2 #7: HQ = `catchmenu_hq` schema | "본부/HQ" 용어가 schema vs store_groups vs UI에 분산 |
| 4 | `900160` 등: 본사 = franchise ops authority | `601501`: HQ = schema name | 한글 "본사" vs 영문 HQ 스키마 |

**A-6. Excluded**

| 문서 경로 | 제외 사유 |
|---|---|
| `601700_Readme_Operational_Authority_Foundation_V2.md` | 워크패킷 범위 선언 |
| `601701_Register_Stage0_Evidence_Collection.md` | 현 워크패킷 자기참조 |
| `docs/900000_patent_and_handoff_package/900161_Logic_Operation_Event_Based_Kiosk_And_DID_Auto_Control_System.md` | 본사 권한 레벨 언급; HQ 스키마·CatchMenu HQ 미정의 |
| `docs/024000_deployment_operations/024110_Policy_Franchise_SaaS_Pilot_Store_Rollout_And_Evidence_Collection.md` | pilot store; HQ 개념 정의 없음 |
| `docs/600000_implementation_lifecycle/601100_store_admin_console/601131_Overview_Menu_Price_List_Architecture.md` | 본사 템플릿 가격 언급; HQ 스키마 아님 |
| `docs/030000_future_saas_modules/030060_Readme_Billing_Plan_Settlement.md` | HQ fee split 언급 |
| `docs/000800_pos_gateway_and_provider_integration_foundation/000811_Governance_POS_Provider_Support_Status_Versioning_Release_And_Deprecation.md` | `catchmenu_hq` 스키마 언급만 |
| (기타 362건) | `catchmenu_hq.*` 테이블 경로, 본사/가맹점 일반 서술 |

**집계**: 본문 키워드 히트 375건 / A-1 등재 7건 / 단순 참조 제외 367건.

**B. SQL 객체**

**B-1. 라이브 DB 객체**

| 종류 | 스키마 | 실명 | 비고 |
|---|---|---|---|
| SCHEMA | — | catchmenu_hq | 존재 |
| TABLE | catchmenu_hq | store_groups | 16컬럼, RLS ENABLE+FORCE |
| TABLE | catchmenu_hq | store_group_members | 10컬럼, RLS ENABLE+FORCE |
| COLUMN | catchmenu_hq | store_groups.* | `id`, `tenant_id`, `group_code`, `group_name`, `group_type`, `parent_group_id`, `depth`, `group_manager_id`, `group_manager_name`, `shared_menu_enabled`, `shared_inventory_enabled`, `cross_store_transfer_enabled`, `performance_metric`, `is_active`, `created_at`, `updated_at` |
| COLUMN | catchmenu_hq | store_group_members.* | `id`, `tenant_id`, `group_id`, `store_id`, `member_role`, `joined_at`, `joined_by`, `is_active`, `created_at`, `updated_at` |
| CHECK | catchmenu_hq | chk_group_type | 허용값 `REGION` / `BRAND` / `FRANCHISE` / `DISTRICT` / `CUSTOM` |
| CHECK | catchmenu_hq | chk_performance_metric | 허용값 `REVENUE` / `ORDER_COUNT` / `CUSTOMER_COUNT` / `PROFIT` |
| CHECK | catchmenu_hq | chk_member_role | 허용값 `LEADER` / `MEMBER` / `HQ` |
| UNIQUE | catchmenu_hq | uq_store_group_code | `(tenant_id, group_code)` |
| UNIQUE | catchmenu_hq | uq_group_member | `(group_id, store_id)` |
| FUNCTION | catchmenu_hq | (38개) | `add_compliance_check_item`만 SECURITY INVOKER · `proconfig=NULL`. 나머지 37개는 SECURITY DEFINER이며 각 함수에 명시적 `search_path` 존재 |
| FUNCTION | catchmenu_common | get_hq_dashboard | SECURITY DEFINER |
| FUNCTION | catchmenu_store | get_multistore_inventory, request_stock_transfer | SECURITY DEFINER |
| FUNCTION | extensions / graphql_public | grant_pg_graphql_access, set_graphql_placeholder, graphql | 이름에 `hq`가 포함된 extension/graphql 보조 함수 3개 |

HQ 함수 분류 결과 총 **44개**.
`catchmenu_hq` 스키마 38개 실명: `add_compliance_check_item`, `apply_menu_template`, `apply_policy_to_stores`, `assign_store_to_brand`, `broadcast_brand_cms`, `broadcast_hq_notice`, `bulk_policy_distribution`, `compare_store_performance`, `compare_store_revenue`, `create_franchise_brand`, `create_franchise_policy`, `create_franchise_store`, `create_menu_template`, `create_store_group`, `detect_policy_violations`, `distribute_menu_template`, `distribute_menu_to_stores`, `escalate_violation`, `get_brand_store_overview`, `get_franchise_admin_dashboard`, `get_franchise_compliance_report`, `get_franchise_dashboard`(overload 2), `get_franchise_os_dashboard`, `get_franchise_settlement_report`, `get_menu_compliance_report`, `get_policy_compliance_summary`, `get_store_group_dashboard`, `process_hq_approval`, `publish_franchise_policy`, `request_hq_approval`, `request_menu_override`, `rollback_policy`, `run_compliance_check`(overload 2), `send_hq_notice`, `set_kpi_targets`, `sync_hq_menu_template`.

**B-2. migration 출처**

| 객체 | migration 파일 | 라인 |
|---|---|---:|
| catchmenu_hq schema | 선행 schema migration | SQL 검색에서 다수 사용 확인 (단일 출처 미특정) |
| store_groups | `0077_create_multistore_rpc.sql` | L26 |
| store_groups 인덱스 | 동일 | L80, L84 |
| store_groups RLS | 동일 | L88–90 |
| store_group_members | 동일 | L127 |
| store_group_members 인덱스 | 동일 | L158, L162 |
| store_group_members RLS | 동일 | L166–168 |
| create_store_group | 동일 | L363 |
| get_store_group_dashboard | 동일 | L501 |

**B-3. 라이브 DB ↔ migration 불일치**

| 객체 | 라이브 | migration | 비고 |
|---|---|---|---|
| catchmenu_hq schema | 있음 | 있음 | **없음** |
| store_groups | 있음 | 있음 | **없음** |
| store_group_members | 있음 | 있음 | **없음** |
| 조사된 HQ 함수 | 있음 | 관련 migration 정의 있음 | 존재 여부 불일치 **없음** |

**B-4. RLS / GRANT**

| 테이블 | RLS | FORCE | 비-postgres GRANT |
|---|---|---|---|
| store_groups | true | true | 없음 |
| store_group_members | true | true | 없음 |

**B-5. SQL 대응물이 없는 문서 어휘**

| 문서 어휘 | 출처(A-4) | SQL 대응물 | 비고 |
|---|---|---|---|
| HQ라는 단일 테이블 | Codex B단계 후보 | 없음 | `catchmenu_hq` 스키마와 HQ 관련 복수 테이블이 존재 |
| CatchMenu HQ | `000140` §23, `000150` | 없음 | administrative surface/UI 개념 |
| 본사 | `900160` 등 patent 대역 | 없음 | franchise operations 권한 개념 |
| franchise_hq | `014016` | 없음 | |

**C. 문서-SQL 일치**

**C-1. 문서 어휘 ↔ SQL 객체 대응**

| A-4 어휘 | 출처 문서 | SQL 객체 | 대응 상태 |
|---|---|---|---|
| HQ | `601501` §0.2 #7 | SCHEMA `catchmenu_hq` | 일치 |
| catchmenu_hq | `601311`, `601501` §2.7 | SCHEMA `catchmenu_hq` | 일치 |
| member_role HQ | `601501` ERD | `chk_member_role` 허용값 `HQ` | 일치 |
| hq_contact_* | `601501` §0.4 | `franchise_brands.hq_contact_name/email/phone` | 일치 |
| CatchMenu HQ | `000140` §23, `000150` | 없음 | 미구현 |
| 본사 | `900160` 등 | 없음 | 미구현 |
| franchise_hq | `014016` | 없음 | 미구현 |

**C-2. 문서 서술 ↔ SQL 실측 불일치**

| # | 문서 서술 (출처 §) | SQL 실측 | 어긋나는 지점 |
|---|---|---|---|
| 1 | `601501` §0.2 #7: HQ = `catchmenu_hq` 스키마 자체, 변경 없음 | 스키마 존재. 그 아래 HQ 관련 함수 44개, `store_groups`·`store_group_members` 2테이블 존재 | "HQ = 스키마"라는 단일 정의로는 44개 함수와 2테이블의 소속·경계를 설명하지 않음 |
| 2 | A단계 결과: HQ가 스키마 / admin UI / 프랜차이즈 본사 3갈래 | SQL에 존재하는 것은 `catchmenu_hq` 스키마 1개뿐 | 3갈래 중 2갈래는 SQL 대응물 없음 |
| 3 | `601501` §0.5: 0-A에서 `store_groups`는 `group_type='REGION'`만 사용 | `chk_group_type` 허용값은 `REGION`/`BRAND`/`FRANCHISE`/`DISTRICT`/`CUSTOM` 5종 | 문서가 서술한 사용 범위와 제약이 허용하는 범위가 다름 |
| 4 | `601501` §2.7: `catchmenu_hq`는 PostgREST 미노출 | Codex 조사에 노출 여부 항목 없음 | **미확인** |
| 5 | `601501`: HQ 변경 없음 | `franchise_brands.hq_contact_*`, `store_group_members.member_role='HQ'`, `franchise_brands.hq_store_id` 존재 | HQ 개념이 스키마명 외에 컬럼·값 형태로 3곳에 분산 존재 |

**C-3. 문서에 없는 SQL 객체 (초과구현)**

| SQL 객체 | 어느 문서에도 정의 없음 | 비고 |
|---|---|---|
| `store_groups.depth`, `parent_group_id` | 그룹 계층 | A-4 어휘에 계층 개념 없음 |
| `store_groups.group_manager_id/name` | 그룹 관리자 | 권한 축과의 관계 미기술 |
| `store_groups.shared_menu_enabled` / `shared_inventory_enabled` / `cross_store_transfer_enabled` | 그룹 공유 플래그 3종 | |
| `chk_performance_metric` 4종 | 성과 지표 축 | |
| `chk_group_type` 값 `BRAND`/`FRANCHISE`/`DISTRICT`/`CUSTOM` | 그룹 유형 4종 | `601501`은 REGION만 서술 |
| `store_group_members.joined_by`, `joined_at` | 가입 이력 | |
| HQ 함수 44개 | 정책 배포·컴플라이언스·승인·공지·KPI | 어느 A 문서에도 함수 계약 정의 없음 |
| `catchmenu_hq.add_compliance_check_item` | 유일한 SECURITY INVOKER 함수 (`proconfig=NULL`) | 나머지 37개와 보안 속성이 다름 |

**D. 로컬 실행 검증**

**D-1. 검증 결과**

| # | 확인 항목 | 실행 쿼리 | 결과 | 판정 |
|---|---|---|---|---|
| 1 | `catchmenu_hq`의 PostgREST 노출 여부 (C-2 #4) | 실행하지 않음 | DB 카탈로그 SELECT만으로 실제 HTTP 노출 여부를 검증할 수 없음. 접근 경로 검증은 E단계 소관 | 범위밖(E) |
| 2 | `add_compliance_check_item`이 SECURITY INVOKER·`search_path` 미설정 상태에서 실제로 어떻게 동작하는지 (C-3) | 함수 정의만 조회 (`SELECT prosrc FROM pg_proc ...`) | 본문이 `pg_temp.compliance_check_items`에 INSERT함 → 실제 호출은 쓰기 금지에 해당 (`601505` §4 금지 조항 계열) | 미확인(금지조항) |
| 3 | `store_groups.group_type`에 실제로 사용된 값 분포 — REGION 외 값이 쓰이는지 (C-2 #3) | `SELECT group_type, count(*) FROM catchmenu_hq.store_groups GROUP BY 1` | `store_groups` **0행**. 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님. | 미확인(데이터부재) |

**D-2. 실행하지 못한 항목**

| # | 항목 | 사유 | 대안 확인 방법 |
|---|---|---|---|
| 1 | `add_compliance_check_item` 동작 | 함수 내부가 `pg_temp` 테이블에 INSERT | 별도 허가된 임시 테이블 기반 테스트 |
| 2 | PostgREST 노출 | DB 카탈로그 SELECT만으로 실제 HTTP 노출 확인 불가 | E단계에서 PostgREST 설정 및 실제 API 요청 검증 |

**D-3. 현재 DB 상태 (실측)**

| 대상 | 실측값 | 비고 |
|---|---|---|
| `store_groups` / `store_group_members` | **0행** | 운영 데이터 미투입은 의도적 판단(문서 정합성 우선). 결함 아님 |
| `add_compliance_check_item` 본문 | `pg_temp.compliance_check_items`에 INSERT | `catchmenu_hq` 38개 함수 중 유일한 SECURITY INVOKER (`proconfig=NULL`)라는 B단계 관찰과 정합 |
| `catchmenu_hq` 스키마 | 존재 | PostgREST 노출 여부는 미확인 (E) |

**E. 호출자·권한 통합** — 미수행

E단계 확인 항목:

- HQ 함수 44개의 실제 호출자와 권한검사 경로.
- `member_role='HQ'`가 실제 권한 판정에 쓰이는지, 단순 라벨인지. (D-1 #3에서 `store_groups` 0행이므로 데이터로는 판정 불가)
- HQ 3갈래(스키마·admin UI·프랜차이즈 본사) 중 무엇을 이 프로젝트의 HQ로 삼을지 — 1단계 Human 결정 대상 (C-2 #2).
- `catchmenu_hq`의 PostgREST 노출 여부 — D-1 #1에서 **범위밖(E)** 로 이관됨.

---

### §4.5 Store

**A. 문서 증거**

**A-1. Discovery Inventory**

| # | 문서 경로 | 분류 | 권위 | 처분 |
|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | Doctrine | ACTIVE | A-2 |
| 2 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Doctrine | ACTIVE | A-2 |
| 3 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Doctrine | ACTIVE | A-2 |
| 4 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Doctrine | ACTIVE | A-2 |
| 5 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | Doctrine | ACTIVE | A-2 |
| 6 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | Doctrine | ACTIVE | A-2 |
| 7 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Doctrine | ACTIVE | A-2 |
| 8 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | Doctrine | ACTIVE | A-2 |
| 9 | `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | Reference | ACTIVE | A-6 |
| 10 | `docs/000020_Policy_Store_Capability_Stage_0_To_5_Module.md` | Doctrine | ACTIVE | A-2 |
| 11 | `docs/004000_store_runtime_pos_kds_operations/004000_Readme_Store_Runtime_POS_KDS_Operations.md` | Scope | ACTIVE | A-6 |
| 12 | `docs/012000_implementation_mapping/012020_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Doctrine | ACTIVE | A-2 |
| 13 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | Doctrine | ACTIVE | A-2 |
| 14 | `docs/013000_app_api_projection/013030_Store_Console_Projection.md` | Design | ACTIVE | A-2 |
| 15 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | Design | SUSPENDED | A-2 |
| 16 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | Design | SUSPENDED | A-2 |
| 17 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Audit | SUSPENDED | A-3 |
| 18 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Template | SUSPENDED | A-6 |
| 19 | `000170` 2026-08-11 역전파 블록 (§14/§15/§16 상태 어휘) | Audit | SUSPENDED | A-3 |

**파일명 검색 결과**: `*Store*` 30건 이상. 위 표 외 다수(`014580` Store POS Adoption 등)는 store 운영·도입 맥락이며 A-6.

**A-2. Concept Source**

| # | 문서 경로 | 무엇을 정의하는가 | 권위 |
|---|---|---|---|
| 1 | `000170` §7 | `merchant_store` 정의, runtime context, recommended fields | ACTIVE |
| 2 | `003010` §4 | Store = operational unit; waiting/KDS/POS 등 store-level | ACTIVE |
| 3 | `003020` §2 | store 축 = handoff runtime 실행 단위 | ACTIVE |
| 4 | `003030` §2 | `store_runtime` 및 profile components·status | ACTIVE |
| 5 | `009030` §2 | 개념 store: actual operating location | ACTIVE |
| 6 | `009070` §2 | store = primary operational state ownership unit | ACTIVE |
| 7 | `007010` §2 | Admin store 축·store_owner/manager | ACTIVE |
| 8 | `007040` §3 | Store List/Detail·Runtime Configuration 화면 | ACTIVE |
| 9 | `000020` | Store capability stage 0–5 module boundary | ACTIVE |
| 10 | `012020` | Store context RLS mapping | ACTIVE |
| 11 | `020330` | Merchant user store access | ACTIVE |
| 12 | `013030` | Store console API projection | ACTIVE |
| 13 | `601501` §0.1 #2 | `stores` table; `stores.legal_entity_id` 단일 FK | SUSPENDED |
| 14 | `601503` | stores DDL·legal_entity_id | SUSPENDED |

**A-3. Findings / Evidence**

| # | 출처 문서 | 발견 내용 | 권위 |
|---|---|---|---|
| 1 | `601601` §4.3 | `000170` §14/§16의 store 서비스상태·체험상태 어휘가 구현된 적 없음 | SUSPENDED (finding 증거가치 유지) |
| 2 | `000170` 역전파 블록 | store 상태 어휘를 SUPERSEDED로 선언했으나 2026-08-10 판정으로 철회됨; 미구현 상태의 유효한 정책 의도 | 선언 철회됨 |

**A-4. Vocabulary**

| 어휘 | 출처 | 정의 | 비고 |
|---|---|---|---|
| store | `003010` §4 | Operational unit | |
| merchant_store | `000170` §7 | Actual operating location; `merchant_store_id` 등 필드 | |
| stores (table) | `601501` | `catchmenu_hq.stores`; tenant 소속 | 권위보류 |
| store_runtime | `003030` §2 | Active operating mode container | |
| store_id | `010004` §4 | Required for store-scoped objects | |
| store_status | `000170` §7 | merchant_store recommended field | |
| service_status | `000170` §7 | merchant_store recommended field | `TERM_COLLISION` — `000170` §4는 동일 어휘를 merchant_account 범위로 사용 |
| store_groups | `601501` §0.5 | operating_group; 0-A에서는 REGION만 | 권위보류 |
| legal_entity_id | `601501` §0.1 | Store→LegalEntity 단일 FK | 권위보류 |
| store_owner | `007010` §3.5 | Admin role at store scope | `TERM_COLLISION` — §4.2 Owner 어휘와 중복 |

**A-5. Contradictions**

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---|---|---|---|
| 1 | `000170`: `merchant_store` + `merchant_store_id` | `003010`/`003020`: `store` (merchant_ 접두 없음) | 명칭·필드 네이밍 |
| 2 | `000170` §7: `merchant_company_id` on store | `601501` §0.1: `legal_entity_id` only (company_id 분기 없음) | Store→상위 엔티티 FK 모델 |
| 3 | `000170` §8: merchant_company optional (trial) | `601501` §2.5: LegalEntity MVP 필수 (nullable until backfill) | Store 법적 주체 필수성 |
| 4 | `003020` §4: MVP minimal tenant/store | `003030`: full `store_runtime` profile stack | MVP 단순화 vs profile 풍부화 |
| 5 | `009030` §2 open: standalone MVP는 full hierarchy 생략 가능 | `601501`: `stores.legal_entity_id` FK 신규 | MVP hierarchy open vs 0-A FK 추가 |

**A-6. Excluded**

| 문서 경로 | 제외 사유 |
|---|---|
| `010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | onboarding 절차; store 개념 재정의 없음 |
| `004000_Readme_Store_Runtime_POS_KDS_Operations.md` | 폴더 진입점 |
| `601701_Register_Stage0_Evidence_Collection.md` | 현 워크패킷 자기참조 |
| `docs/005000_customer_handoff_and_implementation_readiness/005010_customer_handoff_flow/005016_Policy_Customer_Membership_Loyalty_Coupon_Visit_Count_Store_Benefit_And_Runtime_Control.md` | store benefit 런타임; store 엔티티 정의 없음 |
| `docs/014000_pos_provider_integration_strategy/014585_Policy_First_Store_POS_Equipment_Decision_And_Provider_Procurement_Checklist.md` | first store 장비; 개념 정의 없음 |
| `docs/600000_implementation_lifecycle/601100_store_admin_console/*` | store admin 기능; store 개념 재정의 없음 |
| `docs/024000_deployment_operations/024120_Policy_Pilot_Store_Register_Test_Partner_Selection_And_Scope_Control.md` | pilot store 등록 절차 |
| `docs/001000_mvp_scope/001020_Store_Type_And_Product_Package_Strategy.md` | store type 전략; 엔티티 정의 아님 |
| (기타 1,189건) | `store_id` 파라미터, "at store", POS store 등 참조 |

**집계**: 본문 키워드 히트 1,212건 / A-1 등재 19건 / 단순 참조 제외 1,194건.

**B. SQL 객체**

**B-1. 라이브 DB 객체**

| 종류 | 스키마 | 실명 | 비고 |
|---|---|---|---|
| TABLE | catchmenu_hq | stores | 16컬럼, RLS ENABLE+FORCE |
| COLUMN | catchmenu_hq | stores.id | uuid PK, default `gen_random_uuid()` |
| COLUMN | catchmenu_hq | stores.tenant_id | uuid NOT NULL, FK→tenants |
| COLUMN | catchmenu_hq | stores.store_code | text NOT NULL |
| COLUMN | catchmenu_hq | stores.store_name | text NOT NULL |
| COLUMN | catchmenu_hq | stores.store_type | text NOT NULL, default `DINE_IN` |
| COLUMN | catchmenu_hq | stores.store_status | text NOT NULL, default `PREPARING` |
| COLUMN | catchmenu_hq | stores.address/phone | text nullable |
| COLUMN | catchmenu_hq | stores.timezone | text NOT NULL, default `Asia/Seoul` |
| COLUMN | catchmenu_hq | stores.business_hours | jsonb nullable |
| COLUMN | catchmenu_hq | stores.is_active | boolean default true |
| COLUMN | catchmenu_hq | stores.opened_on/closed_on | date nullable |
| COLUMN | catchmenu_hq | stores.created_at/updated_at | timestamptz default `now()` |
| COLUMN | catchmenu_hq | stores.legal_entity_id | uuid nullable, FK→legal_entities |
| CHECK | catchmenu_hq | chk_stores_type | 허용값 `DINE_IN` / `TAKEOUT` / `HYBRID` / `DELIVERY_ONLY` |
| CHECK | catchmenu_hq | chk_stores_status | 허용값 `PREPARING` / `ACTIVE` / `SUSPENDED` / `CLOSED` |
| CHECK | catchmenu_hq | chk_stores_hours_object | NULL 또는 `jsonb_typeof(business_hours)='object'` |
| UNIQUE | catchmenu_hq | uq_stores_tenant_code | `(tenant_id, store_code)` |
| INDEX | catchmenu_hq | idx_stores_tenant_id | `(tenant_id)` |
| INDEX | catchmenu_hq | idx_stores_tenant_status | `(tenant_id, store_status) WHERE is_active=true` |
| INDEX | catchmenu_hq | idx_stores_legal_entity_id | `(legal_entity_id) WHERE legal_entity_id IS NOT NULL` |
| FK | catchmenu_hq | fk_stores_legal_entity_id | `stores.legal_entity_id` → `legal_entities.id` |
| FUNCTION | (8개 스키마) | `catchmenu_hq.stores` 직접 참조 함수 **151개** | 전부 SECURITY DEFINER. 각 함수에 명시적 `search_path` 존재. **라이브 카탈로그 기준이며 migration 텍스트로는 검증 불가** — 전수 나열은 생략하고 아래 스키마별 집계로 대신함 |

스키마별 집계 (대상별 중복 집계 포함):

| 스키마 | 함수 수 |
|---|---:|
| catchmenu_agent | 3 |
| catchmenu_audit | 2 |
| catchmenu_common | 18 |
| catchmenu_hq | 21 |
| catchmenu_integrations | 17 |
| catchmenu_payment | 8 |
| catchmenu_pos | 19 |
| catchmenu_store | 46 |
| 기타 관련 스키마 | 17 |
| **합계** | **151** |

대표 실명 패턴: `bootstrap_*`, `create_*order*`, `get_*store*`, `open_store`, `close_store`, `register_*`, `update_*` 및 결제·정산·배달·POS 계열 함수.
**전수 나열 생략**: 151개 전건 실명은 본 등록부에 기재하지 않는다. 필요 시 D/E 단계에서 대상을 좁혀 재조회한다.

**B-2. migration 출처**

| 객체 | migration 파일 | 라인 |
|---|---|---:|
| stores | `0002_create_hq_tenant_store.sql` | L43 |
| 초기 인덱스 | 동일 | L78, L81 |
| RLS ENABLE/FORCE | `0021_enable_rls.sql` | L15–17 |
| stores.legal_entity_id | `0168_create_operational_authority_foundation.sql` | L157–158 |
| FK 제약 | 동일 | L195–201 |
| legal_entity_id 인덱스 | 동일 | L206–208 |
| get_store_bootstrap | `0024_create_store_bootstrap_rpc.sql` | L10 |
| create_franchise_store | `0060_create_franchise_hq_rpc.sql` | L166 |
| get_store_settings | `0049_create_store_settings_rpc.sql` | L158 |

`stores`를 참조하는 함수는 다수 RPC migration에 분산되어 있으며, `0024`부터 `0159`까지 선언·후속 패치가 존재한다.

**B-3. 라이브 DB ↔ migration 불일치**

| 객체 | 라이브 | migration | 비고 |
|---|---|---|---|
| stores 구조 | 있음 | 있음 | 존재 여부 불일치 **없음** |
| legal_entity_id / FK / 인덱스 | 있음 | `0168`에 있음 | **없음** |
| 직접 참조 함수 | 151개 | 관련 RPC migration들에 정의/패치 존재 | 존재 여부 기준 불일치 **없음**. 개수 일치 여부는 미대조 |

**B-4. RLS / GRANT**

| 테이블 | RLS | FORCE | 비-postgres GRANT |
|---|---|---|---|
| stores | true | true | 없음 |

**B-5. SQL 대응물이 없는 문서 어휘**

| 문서 어휘 | 출처(A-4) | SQL 대응물 | 비고 |
|---|---|---|---|
| merchant_stores | `000170` §7 (`merchant_store`) | 없음 | `stores`가 존재하나 Codex는 동일성 판단 안 함 |
| store_runtime | `003030` §2 | Codex 조사 9테이블에 없음 | 타 스키마 미조사이므로 부재로 단정하지 않음 |
| service_status (store 범위) | `000170` §7 | 없음 | `store_status`는 존재 |
| store_owner | `007010` §3.5 | 없음 | |

**C. 문서-SQL 일치**

**C-1. 문서 어휘 ↔ SQL 객체 대응**

| A-4 어휘 | 출처 문서 | SQL 객체 | 대응 상태 |
|---|---|---|---|
| store | `003010` §4 | `catchmenu_hq.stores` | 일치 |
| stores (table) | `601501` | `catchmenu_hq.stores` | 일치 |
| store_id | `010004` §4 | `store_group_members.store_id`, `franchise_brands.hq_store_id` | 일치 |
| store_status | `000170` §7 | `stores.store_status` + `chk_stores_status` | 일치 |
| store_groups | `601501` §0.5 | `catchmenu_hq.store_groups` | 일치 |
| legal_entity_id | `601501` §0.1 | `stores.legal_entity_id` + `fk_stores_legal_entity_id` + `idx_stores_legal_entity_id` | 일치 |
| merchant_store | `000170` §7 | `catchmenu_hq.stores` (후보) | 이름다름 |
| service_status | `000170` §7 | 없음 | 미구현 |
| store_owner | `007010` §3.5 | 없음 | 미구현 |
| store_runtime | `003030` §2 | 없음 | 미구현 — D-3 실측(명칭 테이블 0개·함수 0개)으로 확정. C단계 「판정불가」에서 2026-08-11 갱신 |

**C-2. 문서 서술 ↔ SQL 실측 불일치**

| # | 문서 서술 (출처 §) | SQL 실측 | 어긋나는 지점 |
|---|---|---|---|
| 1 | `601501` §0.1 #2: `stores.legal_entity_id` 단일 FK | nullable uuid + FK + 부분 인덱스 실재. **151개 참조 함수 중 `legal_entity_id`를 인식하는 함수는 0개** (D-3 실측, 2026-08-11 확정). 백필된 행도 0 | 구조는 존재하나 이를 읽거나 쓰는 함수가 없음 — C단계 「미확인」에서 갱신 |
| 2 | `000170` §7: `merchant_store` + `merchant_store_id` | SQL은 `stores` + `id`/`store_code` | 명칭 불일치. **어느 쪽이 옳은지는 판정하지 않음** |
| 3 | `000170` §8: merchant_company optional (trial) | `stores`에 company 계열 FK 없음. `legal_entity_id` 1개뿐 | 문서의 2축(company/legal) 중 SQL은 legal 1축만 구현 |
| 4 | `003030`: `store_runtime` profile stack | 전 스키마 대상 이름 검색 결과 테이블 0개·함수 0개 (D-3 실측, 2026-08-11 확정) | 문서가 서술한 profile stack에 대응하는 SQL 객체 없음 — C단계 「미확인」에서 갱신 |
| 5 | `000170` §7: `service_status`를 merchant_store 권장 필드로 기술 | `stores`에 해당 컬럼 없음. `store_status` 1개뿐 | `601601` §4.3이 지적한 "구현된 적 없음"과 동일 지점 |
| 6 | `009030` §2: standalone MVP는 full hierarchy 생략 가능 | `stores.tenant_id`는 NOT NULL, `legal_entity_id`는 nullable | tenant는 필수, legal_entity는 선택 — 계층 생략 가능 범위가 두 축에서 다름 |

**C-3. 문서에 없는 SQL 객체 (초과구현)**

| SQL 객체 | 어느 문서에도 정의 없음 | 비고 |
|---|---|---|
| `stores.business_hours` jsonb + `chk_stores_hours_object` | 영업시간 구조 | jsonb 스키마 계약 미정의 |
| `stores.timezone` default `Asia/Seoul` | 타임존 | 다국가 확장 시 기준 미기술 |
| `stores.opened_on` / `closed_on` | 개폐점 일자 | `store_status`와의 관계 미기술 |
| `chk_stores_type` 값 4종 | 매장 유형 축 | A-4 어휘에 매장 유형 개념 없음 |
| `stores.is_active` | `store_status`와 별개 활성 플래그 | 상태 축 중복 가능성 |
| `stores.address` / `phone` | 매장 연락 정보 | |
| 참조 함수 151개 | 전 도메인 런타임 | 어느 A 문서에도 함수 계약 정의 없음 |

**D. 로컬 실행 검증**

**D-1. 검증 결과**

| # | 확인 항목 | 실행 쿼리 | 결과 | 판정 |
|---|---|---|---|---|
| 1 | `stores.legal_entity_id`를 참조하는 함수가 151개 중 몇 개인지 (C-2 #1) | `pg_proc.prosrc`에서 `catchmenu_hq.stores` 직접 참조 함수를 추출한 뒤 `legal_entity_id` 토큰 검색 | `catchmenu_hq.stores` 직접 참조 **151개**, 그중 `legal_entity_id` 참조 **0개** | 성공 |
| 2 | `store_runtime` 대응물이 존재하는지 (C-2 #4) | `information_schema.tables` 이름 검색 + `pg_proc` 이름 검색 | 테이블 **0개**, 함수 **0개** | 성공 |
| 3 | `stores.is_active`와 `store_status`의 실제 데이터 관계 (C-3, 상태 축 중복 가능성) | `SELECT is_active, store_status, count(*) FROM catchmenu_hq.stores GROUP BY 1,2` | `(true, ACTIVE) = 1` | 성공 |
| 4 | `business_hours` jsonb의 실제 구조가 일관된지 (C-3) | `SELECT business_hours, count(*) FROM catchmenu_hq.stores GROUP BY 1` | 1행. `mon`~`sun` 7개 키, 각 값은 `open`/`close` 객체 | 성공 |

**D-2. 실행하지 못한 항목**

| # | 항목 | 사유 | 대안 확인 방법 |
|---|---|---|---|
| — | 없음 | Store D 항목 4건 전부 읽기 전용 조회로 실행됨 | — |

**D-3. 현재 DB 상태 (실측)**

| 대상 | 실측값 | 비고 |
|---|---|---|
| `stores` | **1행** (`is_active=true`, `store_status=ACTIVE`) | |
| `stores.legal_entity_id` 백필 | total 1 / filled **0** | 0-A가 추가한 FK에 값이 들어간 행 없음 |
| `stores` 참조 함수 151개 중 `legal_entity_id` 참조 | **0개** | C-2 #1의 미확인 항목이 실측으로 확정됨 |
| `store_runtime` 명칭 테이블·함수 | **0개** | C-1·C-2 #4의 판정불가가 실측으로 확정됨 |
| `business_hours` 구조 | `mon`~`sun` 7키, 각 값은 `open`/`close` 객체 | 1행 기준. jsonb 스키마 계약은 여전히 문서 미정의 |

**E. 호출자·권한 통합** — 미수행

E단계 확인 항목:

- 비-postgres GRANT가 없는 상태에서 애플리케이션이 `stores`를 어떻게 읽는지.
- `merchant_store` 어휘를 쓰는 `000170`이 실제 런타임 어느 지점을 가리키는지 — 1단계 Human 결정 대상.

D 결과로 해소되어 E 목록에서 제거한 항목:

- ~~151개 함수 중 `legal_entity_id`를 읽거나 쓰는 함수의 호출자와 권한검사 경로~~ — D-1 #1에서 해당 함수가 **0개**로 확정되어 추적 대상이 존재하지 않음.

---

### §4.6 User identity

(§4.1과 동일 구조)

---

### §4.7 Customer identity

(§4.1과 동일 구조)

---

### §4.8 Staff identity

(§4.1과 동일 구조)

---

### §4.9 Session

(§4.1과 동일 구조)

---

### §4.10 Role

(§4.1과 동일 구조)

---

### §4.11 Permission

(§4.1과 동일 구조)

---

### §4.12 Membership

(§4.1과 동일 구조)

---

### §4.13 Menu seed

(§4.1과 동일 구조)

---

### §4.14 Dining table

(§4.1과 동일 구조)

---

## §5 수행 기록

| 단계 | 수행 주체 | 수행일 | 비고 |
|---|---|---|---|
| A 문서 인벤토리 | Cursor | 2026-08-11 | Company/Owner/Tenant/HQ/Store 5개 |
| A 재분류·기입 | Claude Code | 2026-08-11 | A-1~A-6 구조로 재편 |
| B SQL 객체 탐색 | Codex | 2026-08-11 | 라이브DB + migration, 읽기전용 |
| C 문서-SQL 대조 | Claude Code | 2026-08-11 | A·B 대조 |
| D 로컬 실행 검증 | Codex | 2026-08-11 | 읽기전용, 금지함수 미호출 |
| D 결과 기입 | Claude Code | 2026-08-11 | 미확인 사유 2종 분리 |
| E 호출자·권한 통합 |  |  |  |

**Actor 배정 근거**: `000701` §34(도구별 특성) / §37(원작자 검증 배제).
한글 본문 작성은 Cursor에게 맡기지 않는다(`000001` §1, `000701` §34.1).

## §6 근거 문서 목록 (`000701` §46)

| 문서 | 인용 | 역할 |
|---|---|---|
| `000701_Guide_Controlled_AI_Development_Pipeline.md` | §46, §47.1, §48 | 증거수집 규격 |
| `601700_Readme_Operational_Authority_Foundation_V2.md` | §3, §6 | 착수 순서, Boundary Reference Documents |
| `600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | §1.1, §1.3, §2.2 | 601500 사용 제약, 원천문서 미검증 사실 |

조사 과정에서 실제로 참고한 문서는 §4의 각 A 표에 누적한다.
의도적으로 배제한 문서가 있으면 배제 사유를 한 줄 남긴다(§46).

## §7 완료 조건

- [ ] 14개 대상 전부 A~E가 기록됨 (미확인도 명시적으로 기록)
- [ ] §3 요약표 14행이 전부 채워짐
- [ ] 재사용 판정이 A~E 완료 후에 기입됨
- [ ] §48.3 금지사항 3건 위반 없음
- [ ] §5 수행 기록에 actor와 날짜가 기입됨
