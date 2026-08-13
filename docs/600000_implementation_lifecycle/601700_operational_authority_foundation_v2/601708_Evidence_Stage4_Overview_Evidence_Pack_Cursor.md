# 601708_Evidence_Stage4_Overview_Evidence_Pack_Cursor.md

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
> **같은 작업을 Codex 도 독립 수행했다 — `601709`.**
> 합집합 79건 중 **한쪽만 찾은 문서가 40건**이었다(Cursor 26 / Codex 14).
> Cursor 는 조직·경계·거버넌스 계열을, Codex 는 금융·법무·API 계열을 더 찾았다(`000701` §35).
>
> 수행: Cursor, 2026-08-13.

**Purpose**: `000701` §46 — pre-Overview Evidence Pack so reviewers can verify an Overview was written against **all related MD**, not a fixed shortlist.  
**Scope**: Core 5 axes (`Person` / `Tenant` / `MerchantAccount` / `Store` / `LegalEntity`) and Stage 4 implementation candidates:

1. canonical Person physical representation  
2. persistent MerchantAccount foundation  
3. Tenant ↔ MerchantAccount, MerchantAccount → Store relationships  
4. Store–LegalEntity target invariant  

**Out of scope (but boundary docs captured in E-4)**: Store status values, OperatingGroup persistence, Staff·Session·Role·Permission, billing, RPC rewrite, FranchiseAgreement internals.  
**Verifier**: Cursor  
**Date**: 2026-08-13  
**Output**: `tools/_evidence_pack_stage4_cursor.md`

---

## Search methodology

1. **Broad scan** — all `docs/**/*.md` excluding quarantine/migration/duplicate_review/implementation_evidence/`_KO.md`: **1,035** files matched Core-5-related keywords (`Person`, `Tenant`, `MerchantAccount`, `legal_entity`, `merchant_account`, `owners`, etc.).  
2. **Materiality filter** — scored by Core-5 term density, path domain, seed membership, and 1-hop cross-reference expansion from seeds (`601700` pack, known 11, `601701` A-1 list).  
3. **Curated E-1 set** — **64** documents below: every file that **defines, implements, audits, or materially constrains** the Core 5 axes or the four implementation candidates. Files with only passing `tenant`/`store` mentions (POS gateway, migration manifests, etc.) are **excluded** from E-1 but counted in the broad scan.  
4. **Recursive trace** — followed `docs/...` links and explicit citations in `601700`/`601701`/`601702`/`601705`/`601706`/`000701`/`600020`.

### Search terms used

`Person`, `MerchantAccount`, `Merchant Account`, `merchant_account`, `merchant_accounts`, `LegalEntity`, `legal_entity`, `legal_entity_id`, `Tenant`, `tenant_id`, `Store`, `merchant_store`, `Merchant Company`, `merchant_company`, `owners`, `catchmenu_hq.owners`, `legal_entity_representatives`, `legal_entity_person_roles`, `Representative`, `PersonRole`, `operating_group`, `franchise_brands`, `store_groups`, `601700`, `601705`, `601702`, `601501`, `operational authority`, `0-A`, `cross_business`, `primary_owner_user_id`, `SECURITY DEFINER`, `tenant-owned`, `company homonym`, `Merchant Company`

---

## E-1. Related document full list

| # | Document path | What it governs (1 line) | Authority | Related axes | Discovery path |
|---:|---|---|---|---|---|
| 1 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601700_Readme_Operational_Authority_Foundation_V2.md` | 0-A v2 workpacket scope, failure of 1st 0-A, upstream doc list | 본 워크패킷 | All | Seed / workpacket root |
| 2 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | Stage 0 evidence: SQL drift, vocabulary collisions, A-1/A-2/A-3 registers | 본 워크패킷 | All | Seed |
| 3 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | Human business rules: Person, Tenant↔MA 1:1, MA–LE independence, boundaries | 본 워크패킷 | All | Seed |
| 4 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | Stage 0 HQ/HR/Staff boundary evidence (0-B scope separation) | 본 워크패킷 | Person (boundary) | Filename + 601700 |
| 5 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | Q1–Q8 cardinality survey for Core 5 relationships | 본 워크패킷 | All | Seed |
| 6 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | Stage 2 Core ERD: Formal relationships, candidates, external boundaries | 본 워크패킷 | All | Seed |
| 7 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Stage 3 adjacent-domain conflict audit (V1–V5) | 본 워크패킷 | All | Seed |
| 8 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | Stage 3 adjacent-domain audit (independent verifier) | 본 워크패킷 | All | Seed |
| 9 | `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | `601500` AUTHORITY SUSPENDED; 600000 non-authoritative; backprop block rules | ACTIVE | Governance | `601700` §refs, body search |
| 10 | `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | Spiral progress tracker for 601700/601500 status | ACTIVE | Meta | Body search `601700` |
| 11 | `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §46 Evidence Pack, §47 spiral stages, §48 evidence, multi-verifier rule | ACTIVE | Process | `601702` §4, `601700` |
| 12 | `docs/000700_ai_agent_prelearning_and_project_context/000717_Guide_Pipeline_Rules_Summary.md` | Pipeline rules summary for session start | ACTIVE | Process | `601700` readme |
| 13 | `docs/000100_project_foundation/000140_Guide_Organization_Core.md` | Organization core guide; tenant/store/company context entry | ACTIVE | Tenant, Store, company | `601701` A-1 #8 |
| 14 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | CatchMenu platform company/business_unit/legal_entity; Franchise OS separation | ACTIVE | LegalEntity, company, Person (owners warning) | Known 11 / seed |
| 15 | `docs/000100_project_foundation/000170_Policy_Merchant_Account_Company_And_Store_Context.md` | MerchantAccount, MerchantCompany, MerchantStore; store status §14–§16 | ACTIVE | MerchantAccount, Store, Merchant Company | Known 11 / seed |
| 16 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | Cross-business / Franchise OS vs CatchMenu boundary | ACTIVE | Boundary (Franchise) | `601701` A-1 #9 |
| 17 | `docs/000100_project_foundation/000200_Boundary_Organization_Core_MVP_Cutline.md` | MVP cutline for organization core entities | ACTIVE | All (scope) | `601701` A-1 #10 |
| 18 | `docs/000100_project_foundation/000210_Index_Organization_Core_And_Readiness_Check.md` | Index/readiness for organization core docs | ACTIVE | All (index) | `000140` cross-ref |
| 19 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Tenant/store runtime and package model | ACTIVE | Tenant, Store | `003020` §5 cross-ref |
| 20 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Five context axes: tenant, company, legal_entity, operating_group, store | ACTIVE | All | Known 11 / seed |
| 21 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store runtime profile (operational vs legal context) | ACTIVE | Store | `009070` cross-ref |
| 22 | `docs/001000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` | MVP Active: tenant/store runtime context | ACTIVE | Tenant, Store | `003020` §4 |
| 23 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | Conceptual entity master: tenant, company, legal_entity, store, owners | ACTIVE | All | Known 11 / seed |
| 24 | `docs/009000_data_model_state_machine/009060_Boundary_Implementation_Deferred_Data_Model.md` | Deferred data-model implementation boundary | ACTIVE | Meta / scope | Body search `legal_entity` |
| 25 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` | Parallel axes: company ≠ operating_group ≠ legal_entity; store belongs to tenant | ACTIVE | All + OG | Known 11 / seed |
| 26 | `docs/007000_admin_console/007010_Policy_Admin_Console_Context_And_Role_Model.md` | Admin five context axes and role types | ACTIVE | Tenant, company, LE, Store | Known 11 / seed |
| 27 | `docs/007000_admin_console/007040_Policy_Admin_Screen_Inventory_And_Navigation_Model.md` | Admin screens per axis; company ≠ legal_entity rule | ACTIVE | company, LE, Store | Known 11 / seed |
| 28 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Admin navigation and scope model across context axes | ACTIVE | Tenant, company, OG, Store | `009070` §5 cross-ref |
| 29 | `docs/007000_admin_console/007020_Policy_Admin_Store_Runtime_Configuration_Model.md` | Store runtime configuration admin model | ACTIVE | Store, Tenant | Path + body `store` |
| 30 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | Tenant isolation; §4 mandatory context fields; §4.1 global vs tenant-owned | ACTIVE | Tenant, LE, Person/owners | Known 11 / seed |
| 31 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010640_Policy_Tenant_Scope_Envelope.md` | Scope envelope dimensions; §9 LE financial finality; franchise_hq_id | ACTIVE | Tenant, LE, Store | Known 11 / seed |
| 32 | `docs/010000_runtime_foundation_and_cross_room_architecture/010600_cross_room_plumbing_wiring_insulation/010630_Policy_Authority_Capability_Gate.md` | Authority capability gate; tenant/legal scope on mutations | ACTIVE | Tenant, LE (boundary) | Body `legal_entity_id` |
| 33 | `docs/010000_runtime_foundation_and_cross_room_architecture/010100_foundation_static_catalog_package/010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | Franchise OS capability inheritance; tenant/store assembly | ACTIVE | Tenant, Store, company | `601701` A-1 #11 |
| 34 | `docs/010000_runtime_foundation_and_cross_room_architecture/010900_store_onboarding_and_sales_setup_axis/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | Store sales intake; tenant/store profile setup | ACTIVE | Tenant, Store | Body search `tenant`+`store` |
| 35 | `docs/010000_runtime_foundation_and_cross_room_architecture/010400_financial_trust_room/010416_Policy_Financial_Evidence_Audit_And_Export_Boundary.md` | Financial evidence/export; legal_entity scope on financial objects | ACTIVE | LegalEntity | Body `legal_entity` |
| 36 | `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | User account categories; merchant user ↔ merchant_account_id | ACTIVE | MerchantAccount (boundary User) | Known 11 / seed |
| 37 | `docs/020000_validation_security_audit/020320_Policy_Role_Permission_And_Scope.md` | Role+permission+scope; MERCHANT_ACCOUNT scope; company scope types | ACTIVE | MerchantAccount, Store (boundary Role) | Known 11 / seed |
| 38 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | Merchant user store access boundary | ACTIVE | Store, MerchantAccount (boundary) | Path domain 0203 |
| 39 | `docs/020000_validation_security_audit/020400_foundation_security/020450_Policy_Foundation_Security_Access_Control_RBAC_ABAC_And_Least_Privilege.md` | RBAC/ABAC foundation; tenant/store scope enforcement | ACTIVE | Tenant, Store (boundary auth) | Body search |
| 40 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Cross-tenant isolation governance | ACTIVE | Tenant | `010004` ecosystem |
| 41 | `docs/020000_validation_security_audit/020040_Governance_Admin_Access_And_Support_Access.md` | Admin/support access governance across tenant/store | ACTIVE | Tenant, Store (boundary) | `007010` ecosystem |
| 42 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Tenant/store context RLS and access-control mapping (implementation) | ACTIVE | Tenant, Store, LE | Body `tenant_id`, `601501` refs |
| 43 | `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | Runtime owner registry; implementation responsibility (Owner vocabulary) | ACTIVE | Person/Owner (boundary) | `601701` A-2 #3 |
| 44 | `docs/014000_pos_provider_integration_strategy/014097_Policy_SaaS_Admin_Tenant_Store_Directory.md` | SaaS admin tenant/store directory model | ACTIVE | Tenant, Store | Filename search |
| 45 | `docs/014000_pos_provider_integration_strategy/014153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md` | POS gateway tenant/store registry binding (physical registry) | ACTIVE | Tenant, Store | Body `merchant_id`, tenant registry |
| 46 | `docs/028000_future_expansion/028050_Boundary_Franchise_OS_Data_Handoff_Future.md` | Future Franchise OS data handoff boundary | ACTIVE | Boundary (Franchise) | Body `Franchise OS` |
| 47 | `docs/030000_future_saas_modules/030040_Policy_Franchise_Store_Billing_Responsibility_And_HQ_Store_SaaS_Fee_Split.md` | Franchise store billing split (out-of-scope billing boundary) | ACTIVE | Store, LE (boundary billing) | Body search |
| 48 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | 1st 0-A readme; suspended workpacket narrative | 권위보류 | All | Body `601501` |
| 49 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | 1st 0-A ERD: owners, legal_entities, stores, store_groups; Store→1 LE | 권위보류 | All | `601701` A-1 #12 |
| 50 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | 1st 0-A Overview (DDL scope) | 권위보류 | All | `601701` A-1 #13 |
| 51 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | 1st 0-A DDL logic; SECURITY DEFINER access to global tables | 권위보류 | Person, LE | `601701` A-1 #14 |
| 52 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | 1st 0-A test plan for authority DDL | 권위보류 | All | `601701` A-1 |
| 53 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | 1st 0-A change contract (migrations 0168/0169) | 권위보류 | All | `601701` A-1 |
| 54 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601506_Verification_Operational_Authority_Foundation_Ddl.md` | 1st 0-A verification register | 권위보류 | All | `601701` A-1 |
| 55 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601507_Verification_Operational_Authority_Foundation_Ddl.md` | 1st 0-A verification (duplicate lane) | 권위보류 | All | `601701` A-1 |
| 56 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601508_Audit_Operational_Authority_Foundation_Ddl.md` | 1st 0-A audit | 권위보류 | All | `601701` A-1 |
| 57 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | 1st 0-A audit review | 권위보류 | All | Path 601500 |
| 58 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | Blind audit BLOCK conditions for 601501/601503 | 권위보류 | Person, LE | `601701` A-1 #14 |
| 59 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | Stage 11A final audit | 권위보류 | All | Path 601500 |
| 60 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | SQL baseline summary for 0-A tables | 권위보류 | Person, LE, Store | Body `owners`, `legal_entities` |
| 61 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601600_Readme_Upstream_Doctrine_Backpropagation.md` | Upstream doctrine backpropagation workpacket | 권위보류 | Meta | Body `601500` |
| 62 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | Revision drafts touching 000150/003020/601501 vocabulary | 권위보류 | company, LE | `601701` A-1 #16 |
| 63 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | Caller authorization (0-C adjacent); tenant scope in RPC callers | 권위보류 | Tenant (boundary RPC) | Body search |
| 64 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/domain_03_waiting_call_no_show/slice_B_store_legal_boundary/601453_Core_Payload_MD_Bundle_slice_B_store_legal_boundary.md` | Design-integrity bundle: store vs legal boundary slice | ACTIVE | Store, LegalEntity | Filename `store_legal` |
| 65 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/601443_Consolidated_Owner_Decision_Registry_Cross_Domain.md` | Cross-domain Owner terminology decisions (not Person entity) | ACTIVE | Person/Owner (vocabulary) | Body `owner` + legal |

**Broad-scan note**: **971** additional MD files under `docs/` matched keywords but were excluded from E-1 as **incidental references** (POS gateway, payment catalogs, migration manifests, link-update matrices, etc.). They do not define Core 5 axes or the four implementation candidates.

---

## E-2. New discoveries beyond the known 11

Known 11 (prior fixed list): `000150`, `000170`, `003020`, `009030`, `009070`, `010004`, `010640`, `007010`, `007040`, `020310`, `020320`.

| # | Document path | Why relevant | Discovery path |
|---:|---|---|---|
| 1 | `docs/000100_project_foundation/000140_Guide_Organization_Core.md` | Entry guide for organization/tenant/store context stack | `601701` A-1 explicit register |
| 2 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | Franchise OS external boundary for Core ERD §7 | `601701` A-1 #9 |
| 3 | `docs/000100_project_foundation/000200_Boundary_Organization_Core_MVP_Cutline.md` | MVP scope cut for organization core — constrains Stage 4 persistence depth | `601701` A-1 #10 |
| 4 | `docs/000100_project_foundation/000210_Index_Organization_Core_And_Readiness_Check.md` | Index linking all organization-core policies | `000140` / org-core trace |
| 5 | `docs/003000_saas_runtime/003010_Guide_Tenant_Store_Runtime_And_Package_Model.md` | Tenant/store runtime model adjacent to 003020 five-axis guide | `003020` §5 cross-ref |
| 6 | `docs/003000_saas_runtime/003030_Guide_Store_Runtime_Profile_Model.md` | Store operational profile vs legal/settlement context separation | `009070` §5 |
| 7 | `docs/001000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` | MVP Active flag for tenant/store runtime — limits Stage 4 scope | `003020` §4 citation |
| 8 | `docs/007000_admin_console/007070_Policy_Admin_Context_Navigation_And_Scope_Model.md` | Admin scope navigation across tenant/company/OG/store | `009070` §5 |
| 9 | `docs/007000_admin_console/007020_Policy_Admin_Store_Runtime_Configuration_Model.md` | Store-side admin config — Store axis operational layer | Path domain + body |
| 10 | `docs/009000_data_model_state_machine/009060_Boundary_Implementation_Deferred_Data_Model.md` | Explicit deferral of physical schema — Stage 4 must not over-implement | Body search |
| 11 | `docs/010000_runtime_foundation_and_cross_room_architecture/010630_Policy_Authority_Capability_Gate.md` | Mutation authority gate with tenant/legal scope | Body `legal_entity_id` |
| 12 | `docs/010000_runtime_foundation_and_cross_room_architecture/010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | Tenant/store assembly with franchise inheritance rules | `601701` A-1 #11 |
| 13 | `docs/010000_runtime_foundation_and_cross_room_architecture/010901_Policy_Store_Sales_Intake_And_Tenant_Store_Profile_Setup.md` | Tenant+store profile creation at onboarding | Body search |
| 14 | `docs/010000_runtime_foundation_and_cross_room_architecture/010416_Policy_Financial_Evidence_Audit_And_Export_Boundary.md` | LegalEntity required on financial evidence exports | Body `legal entity` |
| 15 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | Physical RLS mapping for tenant/store context — affects Person/LE global table access pattern | Body + `601501` refs |
| 16 | `docs/005000_customer_handoff_and_implementation_readiness/005100_implementation_readiness_and_provider_verification/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | "Owner" registry — vocabulary collision with Person/owners | `601701` A-2 |
| 17 | `docs/014000_pos_provider_integration_strategy/014097_Policy_SaaS_Admin_Tenant_Store_Directory.md` | Admin directory model for tenant/store entities | Filename search |
| 18 | `docs/014000_pos_provider_integration_strategy/014153_WorkPackage_POS_Gateway_Core_Registry_Tenant_Store_Provider_Capability_And_Environment_Binding_Implementation.md` | Concrete tenant/store registry binding workpackage | Body search |
| 19 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | Merchant user ↔ store scope (0-B boundary) | Domain trace from 020310 |
| 20 | `docs/020000_validation_security_audit/020450_Policy_Foundation_Security_Access_Control_RBAC_ABAC_And_Least_Privilege.md` | Foundation RBAC — constrains how MA/store scopes attach to users | Body search |
| 21 | `docs/020000_validation_security_audit/020170_Governance_Cross_Tenant_Isolation_And_Data_Leakage_Prevention.md` | Tenant isolation governance complement to 010004 | Ecosystem trace |
| 22 | `docs/020000_validation_security_audit/020040_Governance_Admin_Access_And_Support_Access.md` | Admin access scoped by tenant/store context | `007010` ecosystem |
| 23 | `docs/028000_future_expansion/028050_Boundary_Franchise_OS_Data_Handoff_Future.md` | Future franchise data handoff — ERD external boundary evidence | Body search |
| 24 | `docs/030000_future_saas_modules/030040_Policy_Franchise_Store_Billing_Responsibility_And_HQ_Store_SaaS_Fee_Split.md` | Billing at store/HQ — out of scope but LE/store money boundary | Body search |
| 25 | `docs/600000_implementation_lifecycle/600020_Governance_Implementation_Lifecycle_Authority_Reset.md` | Defines which 601500 blocks are invalid vs which warnings remain valid | `601700` mandatory |
| 26 | `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | Current spiral stage status for 601700 | Body search |
| 27 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/*` (8 files) | Entire current workpacket artifact set (stages 0–3) | Workpacket root |
| 28 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/*` (13 files) | Prior 0-A full artifact chain — similarity/conflict check only (권위보류) | `601701` A-1 |
| 29 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/*` (2 files) | Documents intended to revise upstream after failed 0-A | Body `601501` |
| 30 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | 0-C caller auth — RPC/scope boundary for global LE access | Body search |
| 31 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/.../601453_*.md` | Store–legal boundary design-integrity slice | Filename `store_legal` |
| 32 | `docs/600000_implementation_lifecycle/601400_fable_design_integrity_inspection/601443_Consolidated_Owner_Decision_Registry_Cross_Domain.md` | Cross-domain "Owner" decision registry — Person naming risk | Body search |
| 33 | `docs/000700_ai_agent_prelearning_and_project_context/000701_Guide_Controlled_AI_Development_Pipeline.md` | §46 Evidence Pack obligation; §47 stage gates | `601702` §4 |
| 34 | `docs/000700_ai_agent_prelearning_and_project_context/000717_Guide_Pipeline_Rules_Summary.md` | Condensed pipeline rules for 601700 sessions | `601700` readme |

---

## E-3. Document pairs with conflict potential

Independent documents regulating the **same concept differently** (CH-F04 pattern). No adjudication.

| # | Document A | Document B | Divergence point |
|---:|---|---|---|
| 1 | `000170` §4 (Merchant Account = top-level customer) | `003020` §2 (`tenant` = root SaaS boundary; no MerchantAccount entity) | Top-level customer axis naming and count |
| 2 | `000170` §6–§9 (`Merchant Company` intermediate layer) | `601705` §3 / `601702` §1.25 (Merchant Company not canonical; LE+MA+Store) | Three-layer vs two-layer merchant hierarchy |
| 3 | `000150` §4 (`company` = CatchMenu platform operator) | `003020` §2 / `007010` §2 (`company` = tenant-scoped brand/operating entity) | **`company` homonym** — same token, different meaning |
| 4 | `000150` §6 (`business_unit`) | `003020` §2 (`operating_group`) | Similar grouping role, different vocabulary |
| 5 | `601705` §3 (Tenant↔MerchantAccount **1:1**; dual paths to Store) | `601501` §0.1 / §1 (no MerchantAccount; Tenant→Store only; Store→exactly 1 LE) | Cardinality and entity set (권위보류 B — similarity check) |
| 6 | `601705` §5.2 U1 (Store→LE count **open**) | `601501` §0.1 principle 2 (Store→**exactly 1** LE) | Store–LegalEntity invariant strength |
| 7 | `003020` ACTIVE §2–§3 (abstract axes; schema open) | `003020` 2026-08-11 backprop block (maps company→`franchise_brands`, LE→`legal_entities`) | **Same file** dual narrative — conceptual vs claimed impl |
| 8 | `000150` ACTIVE §26 ("schema may be designed later") | `000150` backprop block (0168 table mapping) | **Same file** dual narrative |
| 9 | `000150` §11 (Franchise HQ governance = Franchise OS) | `010640` §4·§11 (`franchise_hq_id` in CatchMenu scope envelope) | Where franchise HQ lives in CatchMenu model |
| 10 | `010640` §4 (`company_id` wording) | `003020` §2 (`company` axis = brand grouping) | `company_id` field vs abstract company axis |
| 11 | `000170` §4 `primary_owner_user_id` (login user) | `009030` / `010004` / `601702` §1.1 `Person` (natural person, not account) | **Owner** vocabulary — user vs natural person |
| 12 | `020320` §10 (`COMPANY`/`BUSINESS_UNIT` scope types) | `000150` §4·§6 (CatchMenu internal org axes) | Scope-type labels vs organization entity definitions |
| 13 | `601702` §1.22 (Tenant↔MA 1:1 Human rule) | `000170` + `003020` (neither defines this relationship) | Human rule vs silent adjacent doctrine |
| 14 | `601706` / `601707` (Stage 3 audits) | `601705` (Stage 2 ERD) | Documented Blockers B1–B6 vs ERD as drawn |
| 15 | `601512` / `601503` (SECURITY DEFINER access path for global tables) | `601701` C-2 (0 referencing functions for owners/LE tables) | Described access path vs current SQL emptiness |

---

## E-4. Boundary documents (out of scope but cite limits)

Overview must explain **why excluded** using these.

| # | Document path | Boundary mentioned |
|---|---|---|
| 1 | `docs/020000_validation_security_audit/020310_Policy_User_Account_And_Login.md` | User/Auth Identity, sessions, merchant user accounts — **0-B** |
| 2 | `docs/020000_validation_security_audit/020320_Policy_Role_Permission_And_Scope.md` | Role, Permission, Scope taxonomy — **0-C** |
| 3 | `docs/020000_validation_security_audit/020330_Policy_Merchant_User_And_Store_Access.md` | Merchant user store access — **0-B/0-C** |
| 4 | `docs/020000_validation_security_audit/020450_Policy_Foundation_Security_Access_Control_RBAC_ABAC_And_Least_Privilege.md` | RBAC/ABAC implementation — **0-C** |
| 5 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | HQ, Staff identity, Session — **0-B** |
| 6 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | Caller authorization / RPC scope — **0-C**; RPC rewrite out of scope |
| 7 | `docs/012000_implementation_mapping/012021_Policy_Tenant_Store_Context_RLS_And_Access_Control_Implementation_Mapping.md` | RLS/RPC implementation mapping — physical access layer deferred |
| 8 | `docs/000100_project_foundation/000190_Policy_Cross_Business_Franchise_OS_And_CatchMenu_Boundary.md` | Franchise OS / cross-business — external; not Core entities |
| 9 | `docs/010000_runtime_foundation_and_cross_room_architecture/010145_Policy_Franchise_OS_Capability_Inheritance_And_Tenant_Store_Assembly.md` | Franchise OS capability — external assembly |
| 10 | `docs/028000_future_expansion/028050_Boundary_Franchise_OS_Data_Handoff_Future.md` | Franchise OS data handoff — future / external |
| 11 | `docs/030000_future_saas_modules/030040_Policy_Franchise_Store_Billing_Responsibility_And_HQ_Store_SaaS_Fee_Split.md` | Billing / fee split — **billing out of scope** |
| 12 | `docs/000170_Policy_Merchant_Account_Company_And_Store_Context.md` §14–§16 | Store service/operating/trial **status values** — axes noted in `601702` §1.27 but values deferred |
| 13 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` §6 | `operating_group` persistence depth open — **OG persistence out of scope** |
| 14 | `docs/009000_data_model_state_machine/009070_Matrix_Context_Entity_Alignment_Model.md` §2 | operating_group persistence open for MVP |
| 15 | `docs/600000_implementation_lifecycle/601702_Register_Stage1_Business_Rules.md` §1.6·§1.10 | FranchiseAgreement internal structure — Franchise OS source of truth |
| 16 | `docs/600000_implementation_lifecycle/601705_Diagram_Operational_Authority_Core_ERD.md` §7 | User·Staff·Session·Role·Permission external boundary box |
| 17 | `docs/005000_customer_handoff_and_implementation_readiness/005121_Policy_Runtime_Owner_Registry_And_Implementation_Responsibility_Matrix.md` | "Owner" as implementation responsibility label — not Person entity |

---

## Summary

| Item | Count |
|---|---:|
| E-1 full list (curated material set) | **65** |
| E-1 broad keyword scan (excluded incidental) | 1,035 scanned → **971 incidental** |
| E-2 new beyond known 11 | **34** rows (incl. workpacket bundles) |
| E-3 conflict pairs | **15** |
| E-4 boundary documents | **17** |

---

## Implementation-candidate → primary E-1 anchors

| Candidate | Primary documents (minimum read set) |
|---|---|
| 1. Canonical Person physical representation | `601702` §1.1–§1.2, `601705` §4.1, `009030` §2, `010004` §4.1, `601501`/`601503` (권위보류 drift), `601701` C-2 |
| 2. Persistent MerchantAccount foundation | `000170` §4, `601702` §1.14·§1.22, `601705` §4.4·§8, `601704` Q2, `020320` §40 |
| 3. Tenant↔MA & MA→Store relationships | `601702` §1.22–§1.23, `601705` §3·§5, `003020` §2, `000170` §7, `601704` Q1–Q2, `601706` B3–B4 |
| 4. Store–LegalEntity target invariant | `601702` §1.24·§1.26, `601705` §5 U1·I1, `003020` §2, `010640` §9, `601501` §0.1 (권위보류 contrast), `601453` |

---

## Exclusions applied

- `docs/990000_legacy_quarantine/**`
- `docs/_migration_history/**`
- `**/archive_duplicate_review/**`, `**/*_duplicate_review/**`
- `docs/implementation_evidence/**`
- `*_KO.md`

---

## Method note for Overview author

An Overview is **not** complete if it only cites the original 11. Minimum additional reads from E-2: **`000140`, `000190`, `000200`, `600020`, `000701`, `012021`, `007070`, `010901`, `005121`, full `601700` stage artifacts, and conflict pairs in E-3.** Treat `601500/**` as **권위보류** — use for drift/similarity only, not as alignment proof (`600020` §1.1, §2).
