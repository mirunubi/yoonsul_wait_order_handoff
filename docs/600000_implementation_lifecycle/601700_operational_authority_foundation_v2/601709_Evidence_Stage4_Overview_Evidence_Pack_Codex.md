# 601709_Evidence_Stage4_Overview_Evidence_Pack_Codex.md

> ⚠️ **§46 Evidence Pack · 조사 결과이며 판정이 아니다**
>
> `000701` §46이 Overview 작성 전에 요구하는 **근거 문서 목록**이다.
>
> > 이 워크패킷을 위해 실제로 찾아낸 관련 MD 파일 **전체**를 경로와 함께 나열한다.
> > 이후 검증·재검토하는 사람이 "이 Overview 가 실제로 존재하는 관련 문서들을
> > 다 살펴보고 작성됐는지"를 **이 목록만으로 확인**할 수 있어야 한다.
>
> **이전 조사와 다르다.** `601701`/`601703`/`601704`/`601706` 은 대조 대상을
> 지시서가 지정했으나, 이 조사는 **지정 목록 없이 스스로 찾은 것**이다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601708`.**
> 합집합 79건 중 한쪽만 찾은 문서가 40건이었다(Cursor 26 / Codex 14).
> Cursor 는 조직·경계·거버넌스 계열을, Codex 는 금융·법무·API 계열을 더 찾았다(`000701` §35).
>
> 수행: Codex, 2026-08-13.

조사일: 2026-08-13  
목적: `601700` 0-A 재수행의 Stage 4 Overview 작성 전 `000701` §46 관련 MD 전수 탐색  
방법: 파일명 검색, 본문 검색, 알려진 11개 문서의 교차참조 재귀 추적, 동일 개념 문서군 검색  
제외: `990000_legacy_quarantine/**`, `_migration_history/**`, `archive_duplicate_review/**`, `*_duplicate_review/**`, `implementation_evidence/**`, `*_KO.md`  
주의: SQL은 문서 존재 확인의 보조 검색어로만 취급했고 설계 정답으로 사용하지 않았다. Cursor 산출물은 열거나 참조하지 않았다.

## E-1. 관련 문서 전체 목록

| # | 문서 경로 | 무엇을 규정하는가 (1줄) | 권위 | 관련 축 | 발견 경로 |
|---:|---|---|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | Company, BusinessUnit, LegalEntity, 브랜드·사업자·소유권 경계를 규정 | ACTIVE | LegalEntity, Company | 알려진 문서 |
| 2 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | merchant_account, merchant_company, merchant_store와 상태축을 규정 | ACTIVE | MerchantAccount, Store | 알려진 문서 |
| 3 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Tenant/Company/LegalEntity/OperatingGroup/Store 축과 관계를 규정 | ACTIVE | Core 5축, OperatingGroup | 알려진 문서 |
| 4 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | SaaS context conceptual entity master와 미결 물리화를 등록 | ACTIVE | Core 5축 | 알려진 문서 |
| 5 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | company/legal_entity/operating_group 병렬축과 정렬 규칙을 규정 | ACTIVE | LegalEntity, Company, OperatingGroup | 알려진 문서 |
| 6 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | tenant-owned/global 객체와 tenant_id·store_id 격리 경계를 규정 | ACTIVE | Tenant, Store, LegalEntity | 알려진 문서 |
| 7 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | tenant/store/legal_entity/operating_group scope envelope와 금전 최종성을 규정 | ACTIVE | Tenant, Store, LegalEntity | 알려진 문서 |
| 8 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | context 축과 admin 역할·scope의 연결을 규정 | ACTIVE | Tenant, Store, Company, 경계 | 알려진 문서 |
| 9 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | context별 관리 화면과 역할 가시성을 규정 | ACTIVE | Core context, 경계 | 알려진 문서 |
| 10 | `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | Person/non-human User Account, login, merchant/store scope 경계를 규정 | ACTIVE | Person, Staff/User 경계 | 알려진 문서 |
| 11 | `docs/020000_validation_security_audit/020320_Policy_Role_Permission_And_Scope.md` | MerchantAccount/Store scope, role/permission 비확장 규칙을 규정 | ACTIVE | MerchantAccount, Store, 경계 | 알려진 문서 |
| 12 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Tenant→Store runtime 구조와 package/profile 경계를 규정 | ACTIVE | Tenant, Store | 파일명 검색; `003020` 교차참조 |
| 13 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store에 종속된 runtime profile과 상태 개념을 분리 | ACTIVE | Store, 상태 경계 | `003020` 교차참조 |
| 14 | `docs/009000_data_model_state_machine/009040_Policy_State_And_Event_Ownership_Model.md` | 상태·이벤트 truth owner와 ownership collapse 금지를 규정 | ACTIVE | Store 상태, 소유 경계 | `009030` 인접 문서; 본문 검색 |
| 15 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Tenant/Company/OperatingGroup/Store navigation scope를 규정 | ACTIVE | Context, 권한 경계 | 파일명·본문 검색 |
| 16 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | merchant user의 account/store 접근과 복수 Store scope를 규정 | ACTIVE | MerchantAccount, Store, User 경계 | `020310`/`020320` 참조 |
| 17 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Tenant·Store·Company·Franchise 간 격리와 누출 방지를 규정 | ACTIVE | Tenant, Store, 외부 경계 | 본문 검색 |
| 18 | `docs/020000_validation_security_audit/020020_Boundary_Cross_Entity_Data_Sharing_And_Privacy.md` | cross-entity 데이터 이동과 Franchise OS 경계를 규정 | ACTIVE | LegalEntity, Franchise 경계 | 본문 검색 |
| 19 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Tenant/Store 및 병렬 context의 RLS·access-control mapping을 규정 | ACTIVE | Tenant, Store, 권한 경계 | 파일명·본문 검색 |
| 20 | `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | tenant candidate, store draft, owner/admin contact, 사업자등록·HQ intake를 규정 | ACTIVE | Person, Tenant, Store, LegalEntity | 본문 검색 |
| 21 | `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md` | store/company/tenant/operating_group 역할별 action authority를 규정 | ACTIVE | Context, Role 경계 | `007040` 참조 |
| 22 | `docs/013000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md` | UI surface에서 authority projection을 분리 | ACTIVE | Role/Permission 경계 | `007040` 교차참조 |
| 23 | `docs/013000_app_api_projection/013100_Boundary_Customer_Store_Admin_Api_Group.md` | Customer/Store/Admin API group 경계를 규정 | ACTIVE | Store, User 경계 | `013090` 인접 문서 |
| 24 | `docs/020000_validation_security_audit/020210_Governance_Payment_Boundary_And_Financial_Authority.md` | 결제·금전 authority와 운영 context 경계를 규정 | ACTIVE | LegalEntity, 과금/금전 경계 | 본문 검색 |
| 25 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010451_Policy_Financial_Risk_Boundary.md` | financial truth와 legal/tenant/store scope 경계를 규정 | ACTIVE | LegalEntity, 금전 경계 | `LegalEntity` 본문 검색 |
| 26 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010458_Policy_External_Network_KYC.md` | KYC natural/legal person 및 외부 신원 경계를 규정 | ACTIVE | Person, LegalEntity | Person/representative 본문 검색 |
| 27 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010461_Policy_Multi_Tenant_Finance_SaaS.md` | multi-tenant 금융 격리와 legal entity context를 규정 | ACTIVE | Tenant, LegalEntity, 과금 경계 | Tenant/LegalEntity 본문 검색 |
| 28 | `docs/010000_runtime_foundation_and_cross_room_architecture/010800_legal_notice_sop_and_regulatory_control/010813_Policy_Legal_Notice_Admin_Checklist_And_Store_Onboarding_Review.md` | 법적 고지의 legal entity/store onboarding 검토를 규정 | ACTIVE | LegalEntity, Store | LegalEntity 파일명·본문 검색 |
| 29 | `docs/040000_menu_taxonomy_and_ai_classification/040018_Policy_Legal_Notice_Master_Data_Usage_Flow_And_Runtime_Retrieval_Governance.md` | legal notice master의 legal/store context 사용 경계를 규정 | ACTIVE | LegalEntity, Store | LegalEntity 본문 검색 |
| 30 | `docs/040000_menu_taxonomy_and_ai_classification/040019_Policy_Legal_Notice_Master_Data_Table_Static_Specification.md` | 법적 고지 master의 business/legal context 필드를 규정 | ACTIVE | LegalEntity, Company | BusinessUnit/LegalEntity 본문 검색 |
| 31 | `docs/026000_analytics_reporting_bi/026040_Boundary_Cross_Tenant_Benchmark_And_Data_Sharing.md` | cross-tenant 집계·공유의 격리 경계를 규정 | ACTIVE | Tenant 경계 | Tenant 파일명 검색 |
| 32 | `docs/000020_Policy_Store_Capability_Stage_0_To_5_Module.md` | Store capability 단계와 Store runtime 범위를 규정 | ACTIVE | Store, 상태 경계 | Store 파일명 검색 |
| 33 | `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | 600000 대역 권위 분류 및 601500 권위보류를 규정 | 권위보류 | 권위 판별 | 권위 규칙 직접 확인 |
| 34 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | 구 0-A 범위·처분·역사적 산출물 경계를 기록 | 권위보류 | Core 5축 | `600020`이 지정 |
| 35 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | 구 0-A ERD와 Person/LegalEntity/Store 관계를 기록 | 권위보류 | Core 5축 | Core 어휘 본문 검색 |
| 36 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | 구 0-A 설계 개요와 DDL 범위를 기록 | 권위보류 | Core 5축 | Core 어휘 본문 검색 |
| 37 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | 구 0-A 제약·권한·관계 logic을 기록 | 권위보류 | Core 5축, 권한 경계 | Core 어휘 본문 검색 |
| 38 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | 구 모델의 제약·권한 검증 항목을 기록 | 권위보류 | 물리 후보, 경계 | `601503` 산출물군 추적 |
| 39 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | 구 DDL 범위와 RPC·ACTIVE 승격 금지를 기록 | 권위보류 | 물리 후보, RPC 경계 | `601503` 산출물군 추적 |
| 40 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | 구 설계의 금융·대표·권한 감사 findings를 기록 | 권위보류 | LegalEntity, 경계 | 감사 산출물 추적 |
| 41 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | Person/ownership/representation과 SECURITY DEFINER 결함을 기록 | 권위보류 | Person, LegalEntity, 권한 경계 | Person/representative 본문 검색 |
| 42 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | 구 0-A 재감사와 이월 항목을 기록 | 권위보류 | 권한·과금 경계 | 감사 산출물 추적 |
| 43 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | 구 기준선과 효력 정지 상태를 기록 | 권위보류 | Core 5축 | `600020`·파일명 검색 |
| 44 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601600_Readme_Upstream_Doctrine_Backpropagation.md` | 구 0-A 결론을 상위 문서에 역전파한 범위를 기록 | 권위보류 | Core 5축 | 권위보류 역전파 추적 |
| 45 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | 000150/000170 등 상위 문서 삽입 내용을 기록 | 권위보류 | Core 5축 | 000150/000170 개정 근거 추적 |
| 46 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | 재수행 범위·비구현 경계·참고문서 진입점을 규정 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |
| 47 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Company/Owner/Tenant/HQ/Store B~E 증거를 기록 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |
| 48 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | Human 업무규칙과 Core 5축·관계를 선언 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |
| 49 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | HQ/HR 및 Person 경계 증거를 기록 | 본 워크패킷 | Person, 경계 | 워크패킷 폴더 전수 |
| 50 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | 관계·cardinality 조사와 미결 항목을 기록 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |
| 51 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | Stage 2 Core ERD와 후보·경계를 기록 | 본 워크패킷 | Core 5축 | 직접 대상 |
| 52 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Stage 3 인접 도메인 대조 findings를 기록 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |
| 53 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | 독립 Stage 3 대조 findings를 기록 | 본 워크패킷 | Core 5축 | 워크패킷 폴더 전수 |

## E-2. 이미 알려진 11개 외 신규 발견

| # | 문서 경로 | 왜 관련 있는가 | 발견 경로 |
|---:|---|---|---|
| 1 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Tenant→Store runtime 관계와 Store 상태 경계를 분리 | `003020` 교차참조 |
| 2 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store runtime/profile이 Core Store와 구별되는 지점 | `003020` 교차참조 |
| 3 | `docs/009000_data_model_state_machine/009040_Policy_State_And_Event_Ownership_Model.md` | ownership이라는 말의 상태 소유 의미와 법적 소유 의미 혼동 경계 | 동일 폴더·본문 검색 |
| 4 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Company/OperatingGroup/Store 축이 UI scope로 소비됨 | 본문 검색 |
| 5 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | MerchantAccount→Store와 User 경계를 직접 규정 | `020310`/`020320` 참조 |
| 6 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Tenant/Store/Company/Franchise 격리 경계 | 본문 검색 |
| 7 | `docs/020000_validation_security_audit/020020_Boundary_Cross_Entity_Data_Sharing_And_Privacy.md` | LegalEntity·Franchise 외부 공유 경계 | 본문 검색 |
| 8 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | 물리화 후보의 tenant/store 필드·RLS 소비 지점 | 파일명 검색 |
| 9 | `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | Person contact, tenant candidate, Store·사업자등록 intake 연결 | 본문 검색 |
| 10 | `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md` | Core context가 권한 행위에 투영되는 경계 | `007040` 참조 |
| 11 | `docs/013000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md` | Role/Permission을 Core ERD 밖에 두는 경계 | `007040` 참조 |
| 12 | `docs/013000_app_api_projection/013100_Boundary_Customer_Store_Admin_Api_Group.md` | Store/Admin API 표면 경계 | 인접 문서 추적 |
| 13 | `docs/020000_validation_security_audit/020210_Governance_Payment_Boundary_And_Financial_Authority.md` | LegalEntity 금전 최종성과 과금 out-of-scope 경계 | 본문 검색 |
| 14 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010451_Policy_Financial_Risk_Boundary.md` | financial truth의 법적·tenant·store scope | 본문 검색 |
| 15 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010458_Policy_External_Network_KYC.md` | canonical Person과 LegalEntity의 KYC 경계 | Person/representative 검색 |
| 16 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010461_Policy_Multi_Tenant_Finance_SaaS.md` | multi-tenant 금융 context 경계 | Tenant/LegalEntity 검색 |
| 17 | `docs/010000_runtime_foundation_and_cross_room_architecture/010800_legal_notice_sop_and_regulatory_control/010813_Policy_Legal_Notice_Admin_Checklist_And_Store_Onboarding_Review.md` | Store와 LegalEntity의 법적 고지 연결 | LegalEntity 검색 |
| 18 | `docs/040000_menu_taxonomy_and_ai_classification/040018_Policy_Legal_Notice_Master_Data_Usage_Flow_And_Runtime_Retrieval_Governance.md` | LegalEntity/Store 법적 master 사용처 | 본문 검색 |
| 19 | `docs/040000_menu_taxonomy_and_ai_classification/040019_Policy_Legal_Notice_Master_Data_Table_Static_Specification.md` | 법적 master의 식별 필드 후보 | 본문 검색 |
| 20 | `docs/026000_analytics_reporting_bi/026040_Boundary_Cross_Tenant_Benchmark_And_Data_Sharing.md` | Tenant 데이터 경계의 downstream 소비 | 파일명 검색 |
| 21 | `docs/000020_Policy_Store_Capability_Stage_0_To_5_Module.md` | Store 상태/역량을 Core 물리화와 분리할 경계 | 파일명 검색 |
| 22 | `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | 목록의 권위 판별 기준 | 권위 규칙 직접 확인 |
| 23 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | 구 0-A의 범위·실패 처분 증거 | `600020` 참조 |
| 24 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | 현재 ERD와 유사한 권위보류 모델 | Core 어휘 검색 |
| 25 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | 구 Overview의 범위와 판단 | 산출물군 추적 |
| 26 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | 구 제약·관계·권한 logic | 산출물군 추적 |
| 27 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | 구 제약의 검증 가능성 | 산출물군 추적 |
| 28 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | RPC·상태·DDL 경계 | 산출물군 추적 |
| 29 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | 금융·대표·권한 반례 | 감사 추적 |
| 30 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | ownership/representation 분리와 보안 findings | 본문 검색 |
| 31 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | 이월된 과금·보안 경계 | 감사 추적 |
| 32 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | 구 기준선과 효력 정지 | 파일명 검색 |
| 33 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601600_Readme_Upstream_Doctrine_Backpropagation.md` | ACTIVE 문서에 삽입된 구 결론의 출처 | 역전파 추적 |
| 34 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | 000150/000170 등 개정 삽입 전문 | 개정 근거 추적 |
| 35 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | 현 워크패킷 경계 | 폴더 전수 |
| 36 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | B~E 증거 | 폴더 전수 |
| 37 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | Human 규칙 | 폴더 전수 |
| 38 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | Person/HQ 경계 증거 | 폴더 전수 |
| 39 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | 관계 조사 | 폴더 전수 |
| 40 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | Stage 2 ERD | 직접 대상 |
| 41 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Stage 3 findings | 폴더 전수 |
| 42 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | 독립 Stage 3 findings | 폴더 전수 |

## E-3. 충돌 가능성이 있는 문서 쌍

| # | 문서 A | 문서 B | 어긋나는 지점 |
|---:|---|---|---|
| 1 | `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | 전자는 MerchantAccount/MerchantCompany/MerchantStore, 후자는 Tenant/Company/LegalEntity/OperatingGroup/Store를 기본 축으로 사용 |
| 2 | `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 Company record/BusinessUnit을 서술하고 후자는 Company/BusinessUnit을 candidate·미결로 둠 |
| 3 | `009030_Register_Conceptual_Entity_Master.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자의 5축은 tenant/company/legal_entity/operating_group/store, 후자는 Person/Tenant/MerchantAccount/Store/LegalEntity |
| 4 | `009070_Matrix_Context_Entity_Alignment_Model.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 company/legal_entity/operating_group 병렬축, 후자는 Company/OperatingGroup을 Core 밖 candidate로 둠 |
| 5 | `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 Store service/operating/trial 상태를 규정하고 후자는 Store 상태값을 out of scope로 둠 |
| 6 | `003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 Store→LegalEntity cardinality를 open으로 둔 원문과 단일 경로라는 역전파 삽입이 공존하고, 후자는 본문 미정과 Mermaid 기호가 공존 |
| 7 | `010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 tenant-owned 객체의 tenant_id 필수를 규정하고 후자는 Core 엔티티 관계 수준이며 물리 필드 적용 범위가 확정되지 않음 |
| 8 | `010640_Policy_Tenant_Scope_Envelope.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 LegalEntity 금전 최종성 scope를 요구하고 후자는 Store–LegalEntity target invariant를 미결로 둠 |
| 9 | `020310_Policy_User_Account_And_Login.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 Person/non-human User Account와 merchant/store 귀속을 규정하고 후자는 Person을 User/Auth와 분리해 직접 scope 관계를 두지 않음 |
| 10 | `007010_Policy_Admin_Console_Context_And_Role_Model.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 company/operating_group 역할 scope를 이미 소비하고 후자는 두 축의 persistence를 미결로 둠 |
| 11 | `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | `601510_AuditReview_Stage11B_Blind_Audit.md` | 전자는 대표·소유 관련 역전파 설명을 포함하고 감사 문서는 ownership/representation/person role을 독립 개념으로 지적 |
| 12 | `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | `010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | 전자는 법적 주체·사업자 축을 개념화하고 후자는 사업자등록과 owner/admin contact를 Store onboarding intake 필드로 취급 |
| 13 | `003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | `000170_Policy_Merchant_Account_Company_And_Store_Context.md` | 전자는 Tenant→Store runtime/package 축, 후자는 MerchantAccount→Store customer/account 축으로 상위 context 어휘가 다름 |
| 14 | `020330_Policy_Merchant_User_And_Store_Access.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 전자는 MerchantAccount scope를 권한 경계로 사용하고 후자는 Staff/User/Role/Permission을 모두 별도 나선으로 제외 |
| 15 | `601501_ERD_Tenant_Company_HQ_Store.md` | `601705_Diagram_Operational_Authority_Core_ERD.md` | 권위보류 ERD와 현 ERD가 Person/LegalEntity/Store 구조 일부에서 유사하나 현 ERD는 MerchantAccount를 별도 Core로 둠 |
| 16 | `601502_Overview_Operational_Authority_Foundation_Ddl.md` | `601702_Register_Stage1_Business_Rules.md` | 구 Overview 결론과 재수행 Human 규칙의 Core 축·범위가 완전히 동일하지 않음 |

## E-4. 경계 문서

| # | 문서 경로 | 어느 경계를 언급하는가 |
|---:|---|---|
| 1 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | Store 서비스·운영·trial 상태값 경계 |
| 2 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Store runtime/package/payment profile 경계 |
| 3 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store runtime profile·상태 경계 |
| 4 | `docs/009000_data_model_state_machine/009040_Policy_State_And_Event_Ownership_Model.md` | 상태·이벤트 ownership 경계 |
| 5 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | OperatingGroup persistence 미결 경계 |
| 6 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Staff/Role/Permission 경계 |
| 7 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | 역할 기반 화면 가시성 경계 |
| 8 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | navigation scope와 authority 분리 경계 |
| 9 | `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | User/Session/Login 경계 |
| 10 | `docs/020000_validation_security_audit/020320_Policy_Role_Permission_And_Scope.md` | Role/Permission/Scope 경계 |
| 11 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | Merchant user·Store access 경계 |
| 12 | `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md` | Admin/Support action authority 경계 |
| 13 | `docs/013000_app_api_projection/013090_Surface_To_Authority_Projection_Model.md` | UI surface와 authority 경계 |
| 14 | `docs/013000_app_api_projection/013100_Boundary_Customer_Store_Admin_Api_Group.md` | Customer/Store/Admin API 경계 |
| 15 | `docs/020000_validation_security_audit/020020_Boundary_Cross_Entity_Data_Sharing_And_Privacy.md` | Franchise OS·cross-entity 공유 경계 |
| 16 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Franchise/Company/Tenant 격리 경계 |
| 17 | `docs/020000_validation_security_audit/020210_Governance_Payment_Boundary_And_Financial_Authority.md` | 결제·과금·financial authority 경계 |
| 18 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010451_Policy_Financial_Risk_Boundary.md` | 금전 truth와 legal context 경계 |
| 19 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010461_Policy_Multi_Tenant_Finance_SaaS.md` | 과금·다중 tenant 금융 경계 |
| 20 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | OperatingGroup·Franchise·Actor·Role·financial ledger 경계 |
| 21 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | RLS/RPC/권한 구현 경계 |
| 22 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | RPC 재작성·tenant ACTIVE 승격 금지의 역사적 경계 |
| 23 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | 현 워크패킷 non-implementation boundary |
| 24 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | HQ/HR/Staff 경계 |

## 종합

| 항목 | 건수 |
|---|---:|
| E-1 전체 | 53 |
| E-2 신규 발견 | 42 |
| E-3 충돌 쌍 | 16 |
| E-4 경계 문서 | 24 |

## 조사에 사용한 검색어

| 범주 | 검색어 |
|---|---|
| Core 명칭 | `Person`, `natural person`, `owner`, `owners`, `Tenant`, `MerchantAccount`, `merchant_account`, `merchant account`, `Store`, `merchant_store`, `stores`, `LegalEntity`, `legal_entity`, `legal entity` |
| 후보 관계 | `Tenant.*Merchant`, `Merchant.*Tenant`, `MerchantAccount.*Store`, `Store.*LegalEntity`, `LegalEntity.*Store`, `1:1`, `1:N`, `cardinality`, `FK`, `foreign key` |
| 인접 조직축 | `Company`, `merchant_company`, `BusinessUnit`, `business_unit`, `OperatingGroup`, `operating_group`, `HQ`, `Franchise`, `FranchiseAgreement` |
| Person 물리화 | `canonical person`, `natural_person`, `representative`, `beneficial owner`, `owner_id`, `user account`, `admin contact`, `KYC` |
| 경계 | `tenant_id`, `scope envelope`, `RLS`, `role`, `permission`, `session`, `staff`, `billing`, `payment`, `financial`, `store_status`, `service_status`, `runtime profile` |
| 발견 방식 | `rg --files` 파일명 필터, `rg -l -i --glob '*.md'` 본문 전수 검색, 각 핵심 문서의 `.md` 참조 및 Cross-Reference 절 추적 |

## 조사 한계 기록

- “전체”는 지정 제외 경로를 적용한 현재 워크트리의 Markdown 문서를 대상으로 한 파일명·본문·교차참조 검색 결과다.
- 일반적인 `store`, `owner`, `tenant` 단어만 우연히 포함한 운영·UI·POS 문서는 Core 5축의 정의·관계·물리 후보·명시적 경계를 규정하지 않으면 목록에서 제외했다.
- `600000_implementation_lifecycle/**`는 설계 권위가 아니라 역사·finding·현 워크패킷 provenance 확인을 위해 포함했으며, `601700/**`만 “본 워크패킷”으로 구분했다.
- 충돌 가능성 표는 어휘·확정 깊이·scope의 차이만 기록한다. 어느 문서가 옳은지는 판정하지 않았다.
