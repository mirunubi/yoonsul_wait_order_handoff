# 601722_Module_Operational_Authority_Foundation_V2.md

Status: Active
Lifecycle: Module
Last Updated: 2026-08-24

## Change ID

Workpacket: 601700

## §1 구현 범위

| 대상 | 역할 | 커밋 |
|---|---|---|
| `sql/migrations/0170_person_vocabulary_normalization.sql` | Person canonical vocabulary normalization | `b657ec2` |
| `sql/migrations/0171_merchant_account_foundation.sql` | MerchantAccount foundation and Store linkage | `bc4cd14` |
| `601717_ChangeContract_Operational_Authority_Foundation_V2.md` | Stage 8 승인 계약 기준 | `01cfd45b` |

## §2 수행한 조작

### §2.1 `0170_person_vocabulary_normalization.sql`

| 계약 ID | 수행한 조작 |
|---|---|
| D-1 | `catchmenu_hq.owners`를 `catchmenu_hq.persons`로 rename |
| D-2 | `legal_entity_person_roles.owner_id`를 `person_id`로 rename |
| D-3 | `legal_entity_representatives.owner_id`를 `person_id`로 rename |
| D-4 | `persons.owner_name`을 `person_name`으로 rename |
| D-5 | `trg_owners_updated_at`을 `trg_persons_updated_at`으로 rename |
| D-6 | `legal_entity_person_roles_owner_id_fkey`를 `legal_entity_person_roles_person_id_fkey`로 rename |
| D-7 | `legal_entity_representatives_owner_id_fkey`를 `legal_entity_representatives_person_id_fkey`로 rename |
| D-8 | `owners_pkey`를 `persons_pkey`로 rename |
| D-9 | `idx_lepr_owner`를 `idx_lepr_person`으로 rename |
| D-10 | `persons.is_active` 제거 |
| D-11 | `chk_lepr_ownership_percent` 제거 |
| D-12 | `legal_entity_person_roles.ownership_percent` 제거 |
| D-13 | `persons` 테이블 comment를 계약의 exact literal로 기록 |

### §2.2 `0171_merchant_account_foundation.sql`

| 계약 ID | 수행한 조작 |
|---|---|
| D-14 | `catchmenu_hq.merchant_accounts` 5컬럼과 명명된 PK·Tenant FK 생성 |
| D-15 | `uq_merchant_accounts_tenant` UNIQUE 제약 생성 |
| D-16 | `trg_merchant_accounts_updated_at` 트리거 생성 |
| D-17 | `merchant_accounts`에 RLS ENABLE + FORCE 적용 |
| D-18 | nullable `stores.merchant_account_id` 컬럼 추가 |
| D-19 | `fk_stores_merchant_account_id` FK 생성 |
| D-20 | `idx_stores_merchant_account_id` 인덱스 생성 |
| D-21 | `merchant_accounts`, `merchant_accounts.tenant_id`, `stores.merchant_account_id` comment를 계약의 exact literal로 기록 |
| M-1 | 기존 `tenants` 전 행에서 `merchant_accounts` 행 생성 |
| M-2 | `stores.tenant_id`와 `merchant_accounts.tenant_id`를 통해 `stores.merchant_account_id` backfill |

## §3 적용 후 관측 상태

> ⚠️ 아래 값은 Stage 9 live DB verification(`601740`)에 의해 독립 재확인된 post-implementation 상태다.
> Codex가 이 문서에서 새로 판정한 값이 아니다.

| 항목 | 적용 후 관측값 |
|---|---:|
| `catchmenu_hq` BASE TABLE | 20 → 21 |
| `stores` 컬럼 | 16 → 17 |
| `persons` 컬럼 | 6 (`is_active` 제거) |
| `merchant_accounts` | 5컬럼 · 1행 |
| `stores.merchant_account_id IS NULL` | 0건 |

## §4 하지 않은 것

| 항목 | 상태 · 근거 |
|---|---|
| `stores.merchant_account_id`에 `NOT NULL` 적용 | 미수행 — C-1 이월 |
| `stores.legal_entity_id` backfill | 미수행 — C-2 이월 |
| 네 RPC 수정 | 없음 — FO-A~FO-D |
| RLS policy 생성 | 없음 — fail-closed baseline |
| provider mapping | 없음 — `601702` §1.43 Deferred |

## §5 Pre-existing known defects / implementation-time observations

### §5.1 Stage 8 착수 전에 이미 알려진 기존 결함

| 대상 | 기존 결함 | 이번 구현 |
|---|---|---|
| `provision_tenant` | `tenants` phantom column 참조 3건 | 수정하지 않음 — FO-A |
| `create_franchise_store` | `stores.extra_metadata` phantom column 참조 | 수정하지 않음 — FO-B |
| `onboard_tenant` | phantom column 참조 + 인자명 불일치 | 수정하지 않음 — FO-C |
| `provision_tenant` | `store_type='RESTAURANT'`가 CHECK 허용값 밖 | 수정하지 않음 — FO-D |

### §5.2 Stage 8 구현 중 신규로 발견한 결함

신규 관측 없음.

## §6 이 문서의 지위

이 문서는 Codex가 작성한 Stage 8 구현 self-report 및 traceability 문서다.
완료 증명이 아니며, Stage 9 결과는 `601740`과 `601742`에 기록되어 있다.
Stage 11 감사가 남아 있다.

Stage 9의 FAIL 8건에 대한 통합 내용은 `601742` §5를 참조한다.
이 문서는 어느 쪽의 문면이 옳은지 판정하지 않는다.

## §7 근거 문서 목록

| 문서 | 사용 위치 |
|---|---|
| `601702_Register_Stage1_Business_Rules.md` | §1.43 Deferred 경계 |
| `601716_TestPlan_Operational_Authority_Foundation_V2.md` | Stage 9 검증 기준 |
| `601717_ChangeContract_Operational_Authority_Foundation_V2.md` | 허용 D-1~D-21 · M-1 · M-2 및 FO-A~FO-D |
| `601740_VerificationResult_Stage9_Implementation_Verification_ClaudeCode.md` | 적용 후 live DB 관측값 |
| `601742_Report_Stage9_Verification_Integration.md` | Stage 9 통합 상태와 FAIL 8건의 이관 |
| `sql/migrations/0170_person_vocabulary_normalization.sql` | 0170 실제 수행문 |
| `sql/migrations/0171_merchant_account_foundation.sql` | 0171 실제 수행문 |
