# 601712_Evidence_Person_Physical_Impact_Scan_Codex.md

> ⚠️ **Person physical impact scan · 사실 조사이며 판정이 아니다**
>
> `owners` → canonical `Person` 교정의 물리 영향 조사다.
> Logic(`601713`) 작성의 입력 자료이며, **조사자와 설계자를 분리**하기 위한 것이다
> (`000001` §5.4.2 저자 분리 원칙 — Overview/Logic 은 Claude Code, TestPlan/ChangeContract 는 별도 행위자가 작성한다).
>
> **교정 방법을 제안하지 않는다.** rename 인지 신규 생성인지는
> ChangeContract(`601715`)가 판정한다.
>
> **같은 작업을 Cursor 도 독립 수행했다 — `601711`**(`000701` §35).
>
> P-1 / P-3 는 2026-08-13 라이브 실측이다.
> 최초 조사 시 Docker daemon 미실행으로 문서 인용으로 대체되었던 것을
> 라이브 결과로 교체했다.
> P-2 / P-4 / P-5 / P-6 은 최초 조사 결과를 유지한다.
>
> 수행: Codex, 2026-08-13.

조사일: 2026-08-13  
성격: 읽기 전용 정적 전수 검색 + 라이브 DB 카탈로그 조회 시도  
제외: `docs/990000_legacy_quarantine/**`, `docs/_migration_history/**`, `archive_duplicate_review/**`, `*_duplicate_review/**`, `*_KO.md`  
독립성: 상대 조사 결과는 읽거나 참조하지 않았다.  
DB 상태: Docker 재가동 후 로컬 `supabase_db_yoonsul_wait_order_handoff`에서 읽기 전용 SELECT 완료. PostgreSQL 17.6.

## P-1. 라이브 DB 의존

| # | 종류 | 실명 | `owners`와의 관계 | 비고 |
|---:|---|---|---|---|
| 1 | TABLE | `catchmenu_hq.owners` | 조사 대상 테이블 | 라이브 존재 확인, 7컬럼 |
| 2 | COLUMN | `catchmenu_hq.owners.id` | 두 하위 테이블 FK의 참조 대상 | uuid NOT NULL, default `gen_random_uuid()`, PK |
| 3 | COLUMN | `catchmenu_hq.owners.owner_name` | 자연인 명칭 컬럼 | text NOT NULL |
| 4 | COLUMN | `catchmenu_hq.owners.contact_phone_hash` | 자연인 연락처 hash 컬럼 | text NULL |
| 5 | COLUMN | `catchmenu_hq.owners.contact_email` | 자연인 연락처 컬럼 | text NULL |
| 6 | COLUMN | `catchmenu_hq.owners.is_active` | 활성 상태 컬럼 | boolean NOT NULL, default true |
| 7 | COLUMN | `catchmenu_hq.owners.created_at` | 생성 시각 | timestamptz NOT NULL, default now() |
| 8 | COLUMN | `catchmenu_hq.owners.updated_at` | 갱신 시각 | timestamptz NOT NULL, default now() |
| 9 | FK | `legal_entity_person_roles_owner_id_fkey` | `legal_entity_person_roles.owner_id → owners.id` | 라이브 정의 확인 |
| 10 | FK | `legal_entity_representatives_owner_id_fkey` | `legal_entity_representatives.owner_id → owners.id` | 라이브 정의 확인 |
| 11 | INDEX | `owners_pkey` | `owners.id` unique btree PK 인덱스 | 라이브 이름·정의 확인 |
| 12 | INDEX | `idx_lepr_owner` | `legal_entity_person_roles.owner_id`, active 부분 인덱스 | 라이브 확인 |
| 13 | INDEX | `uq_lepr_active` | `(legal_entity_id, owner_id, role_type)` active 부분 unique | 라이브 확인 |
| 14 | INDEX | `uq_ler_active` | `(legal_entity_id, owner_id)` active 부분 unique | 라이브 확인 |
| 15 | TRIGGER | `trg_owners_updated_at` | `owners` UPDATE 전 `catchmenu_common.set_updated_at()` 실행 | 라이브 정의 확인 |
| 16 | VIEW | 없음 | `pg_views`/`pg_matviews`에서 owners/owner_id/ownership_percent 참조 0건 | 라이브 확인 |
| 17 | FUNCTION | `catchmenu_common.set_updated_at()` | owners trigger가 호출 | trigger 정의로 확인; 함수 본문 자체의 owners 문자열 참조는 없음 |
| 18 | FUNCTION | owners/owner_id/ownership_percent 직접 참조 함수 | 없음 | `pg_proc.prosrc` 검색 0건 |
| 19 | POLICY | `owners` policy | 없음 | `pg_policies` 0건 |
| 20 | GRANT | `catchmenu_authority_owner` | SELECT/INSERT/UPDATE/DELETE | 4 privilege, 모두 grantable=NO |
| 21 | GRANT | `postgres` | 소유자 기본 7 privilege | DELETE/INSERT/REFERENCES/SELECT/TRIGGER/TRUNCATE/UPDATE, 모두 grantable=YES |
| 22 | RLS | `catchmenu_hq.owners` | ENABLE + FORCE | `relrowsecurity=true`, `relforcerowsecurity=true` |

## P-2. migration 계보

| migration | 라인 | 무엇을 했는가 |
|---|---:|---|
| `0168_create_operational_authority_foundation.sql` | 62-70 | `catchmenu_hq.owners` 7컬럼 테이블 생성 |
| `0168_create_operational_authority_foundation.sql` | 72-101 | `legal_entity_person_roles` 생성; `owner_id` FK와 nullable `ownership_percent`, CHECK 생성 |
| `0168_create_operational_authority_foundation.sql` | 103-117 | `owner_id` 포함 active unique 및 조회 인덱스 생성 |
| `0168_create_operational_authority_foundation.sql` | 119-137 | `legal_entity_representatives` 생성; `owner_id` FK 생성 |
| `0168_create_operational_authority_foundation.sql` | 139-148 | representative의 `owner_id` 포함 active unique·legal entity 인덱스 생성 |
| `0168_create_operational_authority_foundation.sql` | 210-213 | `owners` RLS ENABLE + FORCE |
| `0168_create_operational_authority_foundation.sql` | 227-231 | `trg_owners_updated_at` 생성; `set_updated_at()` 연결 |
| `0168_create_operational_authority_foundation.sql` | 251-252 | `owners` table comment 기록 |
| `0168_create_operational_authority_foundation.sql` | 255-258 | 두 하위 테이블의 owners/representation 의미 comment 기록 |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 24-33 | owner role에 schema USAGE와 `owners` 포함 4테이블 DML GRANT |
| `0169_authority_owner_role_and_sole_representative_uniqueness.sql` | 5-8 | representative SOLE active unique 추가; 직접 owners 식별자는 포함하지 않음 |

정적 `sql/migrations/*.sql` 전수 검색 결과, 객체 의미의 `owners` 직접 생성·변경 계보는 `0168`, 권한 계보는 `0169`에서 발견됐다. `0107`의 “store owners”는 SQL 객체명이 아니라 주석의 일반 명사다.

## P-3. 데이터 현황

| 항목 | 실측 |
|---|---|
| `owners` 행 수 | 0 |
| `legal_entity_person_roles` 행 수 | 0 |
| `legal_entity_representatives` 행 수 | 0 |
| `ownership_percent IS NOT NULL` 행 수 | 0 |
| seed 데이터 | `0168`/`0169`에 INSERT 없음; 저장소 비문서 코드 전수 검색에서 owners seed/test 참조 0건; 라이브 owners 0행 |
| test 데이터 | 앱·패키지·tests 검색에서 owners/owner_id/ownership_percent 참조 0건; 관련 3테이블 모두 0행 |

## P-4. 문서 의존

### P-4.1 객체·개념을 직접 참조하는 문서

| # | 문서 경로 | 어떻게 참조하는가 | 권위 |
|---:|---|---|---|
| 1 | `docs/000100_project_foundation/000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` | `owners`를 자연인 대응물로 기록하고 `ownership_percent` 사용 금지 명시 | ACTIVE |
| 2 | `docs/003000_saas_runtime/003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Store 관계에서 `owner_id` 이중 FK 금지를 언급 | ACTIVE |
| 3 | `docs/009000_data_model_state_machine/009030_Register_Conceptual_Entity_Master.md` | `owners`=자연인, 계정 재활용 금지 기록 | ACTIVE |
| 4 | `docs/010000_runtime_foundation_and_cross_room_architecture/010004_Policy_SaaS_Tenant_Isolation_And_Cross_Tenant_Data_Containment_Beam.md` | `owners`를 전역 4테이블 사례로 기록 | ACTIVE |
| 5 | `docs/600000_implementation_lifecycle/601200_caller_authorization_foundation/601200_Readme_Caller_Authorization_Foundation.md` | owners 접근 SECURITY DEFINER 규칙을 후속 경계로 기록 | 권위보류 |
| 6 | `docs/600000_implementation_lifecycle/600010_Tracker_Spiral_Workpacket_Progress.md` | 0-A 산출물 4테이블 중 owners를 기록 | 권위보류 |
| 7 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601500_Readme_Operational_Authority_Foundation.md` | `0168` 신규 테이블로 owners 기록 | 권위보류 |
| 8 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601501_ERD_Tenant_Company_HQ_Store.md` | owners 물리 구조, 두 FK, ownership_percent 혼재·사용 금지를 상세 기록 | 권위보류 |
| 9 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601502_Overview_Operational_Authority_Foundation_Ddl.md` | owners 신규 DDL 및 CRUD 후속 범위 기록 | 권위보류 |
| 10 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601503_Logic_Operational_Authority_Foundation_Ddl.md` | owners/두 FK/ownership_percent/RLS/GRANT pseudo-DDL과 규칙 기록 | 권위보류 |
| 11 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601504_TestPlan_Operational_Authority_Foundation_Ddl.md` | owners 제약·권한 검증 계약 기록 | 권위보류 |
| 12 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601505_ChangeContract_Operational_Authority_Foundation_Ddl.md` | owners 포함 허용 DDL·금지 범위 기록 | 권위보류 |
| 13 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601506_Verification_Operational_Authority_Foundation_Ddl.md` | owners 구현 검증 결과 기록 | 권위보류 |
| 14 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601507_Verification_Operational_Authority_Foundation_Ddl.md` | owners 독립 검증 결과 기록 | 권위보류 |
| 15 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601508_Audit_Operational_Authority_Foundation_Ddl.md` | owners 관련 감사 결과 기록 | 권위보류 |
| 16 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601509_AuditReview_Operational_Authority_Foundation_Ddl.md` | 법적·운영 권위 반례 기록 | 권위보류 |
| 17 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601510_AuditReview_Stage11B_Blind_Audit.md` | Owner/representative/ownership 개념 분리 결함 기록 | 권위보류 |
| 18 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601511_AuditReview_Stage11A_Final.md` | 이월 조건과 감사 종결 기록 | 권위보류 |
| 19 | `docs/600000_implementation_lifecycle/601500_operational_authority_foundation/601512_Baseline_Summary.md` | owners 물리 기준선과 효력 정지 기록 | 권위보류 |
| 20 | `docs/600000_implementation_lifecycle/601600_upstream_doctrine_backpropagation/601601_Register_Stage1_Business_Rules_And_Revision_Drafts.md` | owners 명칭·4개념 분리 역전파 내용 기록 | 권위보류 |
| 21 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601701_Register_Stage0_Evidence_Collection.md` | owners B~E 증거, 데이터 0행 과거 실측, ownership_percent 혼재 기록 | 본 워크패킷 |
| 22 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601702_Register_Stage1_Business_Rules.md` | owners가 자연인이며 Person으로 명명, ownership_percent 사용 금지 선언 | 본 워크패킷 |
| 23 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601703_Register_Stage0_Evidence_Collection_HQ_HR.md` | owners/HR/Person 경계 증거 기록 | 본 워크패킷 |
| 24 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601704_Register_Stage2_ERD_Relationship_Survey.md` | owners 물리 후보, owner_id 두 관계, ownership_percent 존재 기록 | 본 워크패킷 |
| 25 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601705_Diagram_Operational_Authority_Core_ERD.md` | Person은 owners 테이블이 아니라고 개념·물리명을 분리 | 본 워크패킷 |
| 26 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601706_Audit_Stage3_Adjacent_Domain_Cursor.md` | Person/owners 어휘 충돌과 ownership 경계를 기록 | 본 워크패킷 |
| 27 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601707_Audit_Stage3_Adjacent_Domain_Codex.md` | Person/owners 유사성·차이와 ownership_percent 기록 | 본 워크패킷 |
| 28 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601708_Evidence_Stage4_Overview_Evidence_Pack_Cursor.md` | owners 관련 문서 탐색 증거 기록 | 본 워크패킷 |
| 29 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601709_Evidence_Stage4_Overview_Evidence_Pack_Codex.md` | owners를 Person 물리화 검색어로 기록 | 본 워크패킷 |
| 30 | `docs/600000_implementation_lifecycle/601700_operational_authority_foundation_v2/601710_Overview_Operational_Authority_Foundation_V2.md` | legacy owners 어휘, 두 하위 관계, ownership_percent 혼재를 Overview 입력으로 기록 | 본 워크패킷 |

### P-4.2 일반 `owner_id` 문자열 참조 — 대상 FK와 동일 개념인지 문서만으로 확인되지 않음

| # | 문서 경로 | 어떻게 참조하는가 | 권위 |
|---:|---|---|---|
| 1 | `docs/014000_pos_provider_integration_strategy/014069_Policy_POS_Gateway_Compliance_Readiness.md` | 필드 목록에 `owner_id` | ACTIVE |
| 2 | `docs/014000_pos_provider_integration_strategy/014071_Policy_POS_Gateway_Dispute_Evidence_Packet_Refund_Cancellation_And_Chargeback_Response.md` | 필드 목록에 `owner_id` | ACTIVE |
| 3 | `docs/014000_pos_provider_integration_strategy/014079_Policy_POS_Gateway_Provider_Risk_Register_Known_Limitations_Waiver_And_Deferral.md` | 필드 목록에 `owner_id` | ACTIVE |
| 4 | `docs/014000_pos_provider_integration_strategy/014083_Policy_POS_Gateway_Store_Tenant_Operations_Runbook_Handoff_And_Training_Readiness.md` | 필드 목록에 `owner_id` | ACTIVE |
| 5 | `docs/014000_pos_provider_integration_strategy/014096_Policy_POS_Gateway_Core_Data_Model_Event_Ledger_State_Projection_And_Route_Registry.md` | 필드 목록에 `owner_id` | ACTIVE |
| 6 | `docs/014000_pos_provider_integration_strategy/014106_Policy_POS_Gateway_Reconciliation_Case_Settlement_Matching_Provider_POS_And_Internal_Ledger.md` | 필드 목록에 `owner_id` | ACTIVE |
| 7 | `docs/014000_pos_provider_integration_strategy/014108_Policy_POS_Gateway_Dispute_Case_Evidence_Packet_Generator_Support_And_Chargeback_Export.md` | `owner_id` 2회 | ACTIVE |
| 8 | `docs/014000_pos_provider_integration_strategy/014110_Policy_POS_Gateway_Store_Tenant_Support_UI_Runbook_Action_Binding_And_Operational_Workflow.md` | 필드 목록에 `owner_id` | ACTIVE |

## P-5. 코드 의존

### 검색 경로

| 경로 | 존재 | 검색 결과 |
|---|---|---|
| `apps/` | 예 | 0건 |
| `catchmenu_app/` | 예 | 0건 |
| `packages/` | 예 | 0건 |
| `supabase/` | 예 | 0건 |
| `tests/` | 예 | 0건 |
| `sql/migrations/` | 예 | `0168`, `0169` 의존 발견(P-2) |
| `lib/`, `src/`, `functions/`, `test/` (저장소 루트) | 아니오 | 검색 대상 경로 없음 |

앱·Flutter·패키지·Supabase config/snippet·테스트 코드에서 `catchmenu_hq.owners`, 객체명 `owners`, `owner_id`, `ownership_percent` 참조는 발견되지 않았다. 문서와 SQL migration은 별도 표에 기록했다.

## P-6. `ownership_percent` 현황

| 항목 | 실측 |
|---|---|
| 컬럼 존재 | 라이브 `legal_entity_person_roles.ownership_percent numeric`, nullable=YES |
| NULL 가능 | `0168`에 NOT NULL 없음 |
| CHECK 제약 | `chk_lepr_ownership_percent`: NULL 또는 `0 <= ownership_percent <= 100` (`0168` L94-97) |
| 데이터 | NOT NULL 0행; 테이블 전체 0행 |
| 참조 함수 | 라이브 `pg_proc.prosrc` 검색 0건 |
| seed/test 참조 | 비문서 코드 전수 검색 0건 |
| ACTIVE 문서상 사용 금지 | `000150_Policy_CatchMenu_Company_Business_Unit_And_Legal_Entity.md` L66 |
| 본 워크패킷 사용 금지 | `601702_Register_Stage1_Business_Rules.md` L62; `601701` L454; `601704` L253 |
| 권위보류 문서 사용 금지 | `601501_ERD_Tenant_Company_HQ_Store.md` §2.3.1 L372-382; `601503_Logic_Operational_Authority_Foundation_Ddl.md` open item (q) L721 |
| 문서 내 혼재 | 같은 물리 역할 테이블에 role_type과 ownership_percent가 함께 정의됨 (`0168` L78-97); 문서는 역할과 economic ownership을 별개 개념으로 기록 |

## 종합

| 항목 | 건수 |
|---|---:|
| migration 파일 | 2 |
| `owners` 직접 FK | 2 |
| `owner_id` 포함 migration 인덱스 | 3 |
| `owners` 직접 trigger | 1 |
| 정적 migration의 owners 대상 GRANT role | 1 |
| 정적 migration의 owners RLS policy 생성 | 0 |
| 정적 migration의 owners 전용 view | 0 |
| 정적 migration의 owners 직접 참조 신규 function | 0 |
| 앱·패키지·테스트 코드 참조 | 0 |
| 객체·개념 직접 참조 문서 | 30 |
| 문맥 미확정 일반 `owner_id` 문서 | 8 |
| 본 워크패킷 문서 | 10 |
| 권위보류 직접 참조 문서 | 16 |
| ACTIVE 직접 참조 문서 | 4 |
| 라이브 DB 확인 항목 | columns 10행, constraints 4건, views 0, matviews 0, trigger 1, 직접 참조 functions 0, policies 0, grants 11, indexes 4, 데이터 counts 4개 확인 |

## 12개 조사 항목 완결표

| # | 조사 항목 | 기록 위치 | 상태 |
|---:|---|---|---|
| 1 | `catchmenu_hq.owners` 전체 참조 | P-1, P-2, P-4, P-5 | 정적 전수 + 라이브 카탈로그 확인 |
| 2 | `owner_id` / `owners.id` FK | P-1 #9-10 | 2개 정적 확인 |
| 3 | owners 참조 view | P-1 #16 | 라이브 view/matview 0 |
| 4 | owners trigger | P-1 #15 | 1개 정적 확인 |
| 5 | owners function/RPC | P-1 #17-18 | trigger function 1 연결, 직접 문자열 참조 함수 0 |
| 6 | RLS policy/GRANT | P-1 #19-22 | RLS ENABLE+FORCE, policy 0, grants 11 privilege rows |
| 7 | seed/test data | P-3 | 정적 참조 0, 관련 3테이블 데이터 0행 |
| 8 | docs active runtime dependency | P-4 | 직접 30 + 일반 owner_id 8, 권위 분리 |
| 9 | `0168`/`0169` lineage | P-2 | 2개 migration |
| 10 | `legal_entity_person_roles` 의존 | P-1 #9, #12-13; P-2 | FK·인덱스·ownership_percent |
| 11 | `legal_entity_representatives` 의존 | P-1 #10, #14; P-2 | FK·인덱스 |
| 12 | `ownership_percent` 혼재 | P-6 | 컬럼·CHECK·문서 금지 위치 기록 |

## 실행한 쿼리·검색 명령 전문

### 파일·코드·문서 검색

```powershell
Get-ChildItem -LiteralPath . -Force
@('apps','packages','lib','src','supabase','functions','test','tests','tools','sql') |
  ForEach-Object { Test-Path -LiteralPath $_ }

rg -n -i --glob '!docs/**' \
  '\bcatchmenu_hq\.owners\b|\bowners\b|\bowner_id\b|\bownership_percent\b' .

rg -n -i '\bcatchmenu_hq\.owners\b|\bowners\b|\bowner_id\b|\bownership_percent\b' \
  sql/migrations

rg -n -i --glob '!**/*.md' --glob '!sql/**' --glob '!docs/**' \
  '\bcatchmenu_hq\.owners\b|\bowners\b|\bowner_id\b|\bownership_percent\b' \
  apps catchmenu_app packages supabase tests

rg -n -i --glob '*.md' \
  --glob '!990000_legacy_quarantine/**' \
  --glob '!_migration_history/**' \
  --glob '!**/archive_duplicate_review/**' \
  --glob '!**/*_duplicate_review/**' \
  --glob '!*_KO.md' \
  '\bcatchmenu_hq\.owners\b|\bowner_id\b|\bownership_percent\b|references catchmenu_hq\.owners|\bowners table\b|`owners`' docs
```

### 라이브 DB SELECT 묶음

아래 쿼리를 `docker exec -i supabase_db_yoonsul_wait_order_handoff psql -X -v ON_ERROR_STOP=1 -U postgres -d postgres`로 전달했고 전부 SELECT로 실행됐다.

```sql
SELECT version();

SELECT c.table_schema, c.table_name, c.column_name, c.data_type,
       c.is_nullable, c.column_default
FROM information_schema.columns c
WHERE c.table_schema='catchmenu_hq'
  AND (c.table_name='owners' OR c.column_name IN ('owner_id','ownership_percent'))
ORDER BY c.table_name,c.ordinal_position;

SELECT n.nspname, cl.relname, con.conname, con.contype,
       pg_get_constraintdef(con.oid,true)
FROM pg_constraint con
JOIN pg_class cl ON cl.oid=con.conrelid
JOIN pg_namespace n ON n.oid=cl.relnamespace
WHERE n.nspname='catchmenu_hq'
  AND (cl.relname='owners'
       OR pg_get_constraintdef(con.oid,true) ILIKE '%owners%'
       OR pg_get_constraintdef(con.oid,true) ILIKE '%owner_id%'
       OR pg_get_constraintdef(con.oid,true) ILIKE '%ownership_percent%');

SELECT schemaname, viewname, definition
FROM pg_views
WHERE definition ILIKE '%owners%'
   OR definition ILIKE '%owner_id%'
   OR definition ILIKE '%ownership_percent%';

SELECT schemaname, matviewname, definition
FROM pg_matviews
WHERE definition ILIKE '%owners%'
   OR definition ILIKE '%owner_id%'
   OR definition ILIKE '%ownership_percent%';

SELECT n.nspname, c.relname, t.tgname, pg_get_triggerdef(t.oid,true)
FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND ((n.nspname='catchmenu_hq' AND c.relname='owners')
       OR pg_get_triggerdef(t.oid,true) ILIKE '%owners%');

SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid),
       p.prosecdef, p.proconfig, r.rolname, p.proacl
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
JOIN pg_roles r ON r.oid=p.proowner
WHERE n.nspname NOT IN ('pg_catalog','information_schema')
  AND (p.prosrc ILIKE '%owners%'
       OR p.prosrc ILIKE '%owner_id%'
       OR p.prosrc ILIKE '%ownership_percent%');

SELECT * FROM pg_policies
WHERE schemaname='catchmenu_hq' AND tablename='owners';

SELECT grantor, grantee, table_schema, table_name, privilege_type, is_grantable
FROM information_schema.role_table_grants
WHERE table_schema='catchmenu_hq' AND table_name='owners';

SELECT n.nspname,c.relname,c.relrowsecurity,c.relforcerowsecurity
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='catchmenu_hq' AND c.relname='owners';

SELECT schemaname,tablename,indexname,indexdef
FROM pg_indexes
WHERE schemaname='catchmenu_hq'
  AND (tablename='owners' OR indexdef ILIKE '%owner_id%'
       OR indexdef ILIKE '%ownership_percent%');

SELECT
  (SELECT count(*) FROM catchmenu_hq.owners) AS owners,
  (SELECT count(*) FROM catchmenu_hq.legal_entity_person_roles) AS legal_entity_person_roles,
  (SELECT count(*) FROM catchmenu_hq.legal_entity_representatives) AS legal_entity_representatives,
  (SELECT count(*) FROM catchmenu_hq.legal_entity_person_roles
   WHERE ownership_percent IS NOT NULL) AS ownership_percent_not_null;

SELECT * FROM catchmenu_hq.owners ORDER BY id;
```

### Docker 재가동 후 실행 결과 요약

```text
PostgreSQL: 17.6
COLUMNS: 10 rows
CONSTRAINTS: 4 rows (owners PK, owner FK 2, ownership_percent CHECK 1)
VIEWS: 0 rows
MATVIEWS: 0 rows
TRIGGERS: 1 row
FUNCTIONS (prosrc direct text reference): 0 rows
POLICIES: 0 rows
GRANTS: 11 rows (catchmenu_authority_owner 4, postgres 7)
RLS: relrowsecurity=true, relforcerowsecurity=true
INDEXES: 4 rows
COUNTS: owners=0, legal_entity_person_roles=0,
        legal_entity_representatives=0, ownership_percent_not_null=0
OWNERS_ROWS: 0 rows
```

이 보고서는 교정 방법, rename/신규 생성 선택, 우선순위 또는 정합성 판정을 포함하지 않는다.
