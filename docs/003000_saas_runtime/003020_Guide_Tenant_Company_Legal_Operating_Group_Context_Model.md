# 003020_Guide_Tenant_Company_Legal_Operating_Group_Context_Model.md

## 1 Purpose

SaaS runtime needs explicit context axes.

Tenant is the SaaS customer boundary.

Company, legal_entity, operating_group, and store are related but not the same.

This document prevents accidental parent-child simplification.

This document is SaaS runtime consolidation only.
It does not define physical schema, API implementation, or billing implementation.

## 2 Context Axes

| axis | meaning | ownership/context role | what it is not | relationship | MVP requirement |
| --- | --- | --- | --- | --- | --- |
| tenant | SaaS customer boundary and contract scope. | Platform-tenant relationship and isolation boundary. | Not a single store or legal entity by default. | Root SaaS boundary for stores and configuration. | Required. |
| company | Operating company or brand entity within tenant scope. | Business/brand grouping for admin visibility. | Not automatically legal_entity. | May span stores; may relate to operating_group. | May be required depending tenant type. |
| legal_entity | Legal/tax/settlement entity context. | Contract, tax, and settlement authority context. | Not operational store runtime. | Parallel/context axis to operating_group. | May be required depending tenant type. |
| operating_group | Regional, franchise, direct-operated, or tourist-zone operational grouping. | Operational grouping for stores and delegated settings. | Not legal settlement authority by default. | Parallel/context axis to company/legal_entity. | Optional initially; must be modeled as future axis. |
| store | Operational unit where handoff runtime executes. | Waiting, Mini Kiosk, order candidate, and staff confirmation context. | Not tenant, not legal_entity alone. | Belongs to tenant; may link to operating_group and company/legal context. | Required. |

### ⚠️ 2026-08-11 개정 — 이 축 모델의 구현 결과 (0-A `601500`)

본 문서가 규정한 축 분리는 **LegalEntity 중심 모델**로 실현됐다(마이그레이션 `0168`/`0169`, 2026-08-11 완료).

| 축 | 구현체 | 비고 |
|---|---|---|
| `legal_entity` | **`catchmenu_hq.legal_entities`** (신규) | 사업자등록번호 보유 |
| `company` | 기존 `catchmenu_hq.franchise_brands` | **`store_groups`가 아니다** — 두 축은 별개 |
| `operating_group` | 기존 `catchmenu_hq.store_groups` (`group_type='REGION'`만) | |
| `tenant` / `store` | 기존 `catchmenu_hq.tenants` / `stores` | `stores.legal_entity_id` FK 신규 |

#### Store → LegalEntity는 단일 경로다

`stores.legal_entity_id` **하나뿐**이며, `company_id`/`owner_id`로 갈라지는 **두 갈래 FK를 의도적으로
만들지 않았다** — 하나의 사실이 두 곳에 있으면 반드시 갈라지기 때문이다(`601501` §0.1 원칙 2).

`legal_entities`와 `tenants` 사이에는 **직접 관계선이 없다.** LegalEntity의 tenant 소속은
그가 운영하는 Store들을 통해서만 간접적으로 드러나며, **서로 다른 tenant에 걸칠 수 있다.**

> **⚠️ 어휘 함정**: `legal_entities.entity_type = 'CORPORATION'`은 **법인격의 종류(legal form)** 이지,
> 본 문서 §2의 **"company 축"이 아니다.** 위 표대로 company 축은 `franchise_brands`가 담당한다.

#### §6 Open Decisions에 대한 0-A의 답

| 본문 §6 Open Decision | 0-A의 답 |
|---|---|
| *"whether company/legal_entity required for every tenant"* | **MVP에서 LegalEntity를 필수로 둔다**(Store가 법적 주체를 갖도록). 단 `stores.legal_entity_id`는 백필 완료 전까지 **nullable**이다(`601501` §2.5). company 축(`franchise_brands`)은 필수가 아니다 |
| *"whether operating_group exists in MVP data"* | `store_groups`는 존재하나 **`group_type='REGION'`만 사용**하며, 0-A에서 실제 행을 생성하지 않았다 |

본 문서 §3의 **"do not assume one company equals one legal_entity"** 원칙은 구현에서 지켜졌다 —
두 축이 서로 다른 테이블로 분리돼 있다.

근거: `601501_ERD_Tenant_Company_HQ_Store.md` §0.1/§0.3/§2.5, `sql/migrations/0168`.

## 3 Relationship Rules

- tenant is SaaS customer boundary.
- company/legal_entity is legal/contract/settlement context.
- operating_group is operational grouping context.
- store is operational unit.
- operating_group and company/legal_entity are parallel/context axes, not necessarily strict parent-child chain.
- store may belong to operating_group and legal/company context.
- admin visibility does not equal mutation authority.

Additional rules:

- do not collapse tenant into store for multi-store SaaS design.
- do not assume one company equals one legal_entity.
- context changes must be auditable when they affect runtime configuration.

## 4 MVP Simplification Boundary

- MVP may start with minimal tenant/store context.
- company/legal_entity may be required depending tenant type.
- operating_group may be optional initially but must be modeled as a future axis.
- do not hard-code single-company/single-store assumptions.

Aligns with `docs/001000_mvp_scope/001040_Matrix_MVP_Active_Optional_Future_NonGoal.md` Active MVP candidates for tenant/store runtime context.

## 5 Cross-References

- `docs/07000_admin_console/007010_Admin_Console_Context_And_Role_Model.md`
- `docs/09000_data_model_state_machine/009030_Conceptual_Entity_Master.md`
- `docs/03000_saas_runtime/003030_Store_Runtime_Profile_Model.md`

## 6 Open Decisions

- whether company/legal_entity required for every tenant.
- whether operating_group exists in MVP data.
- whether store can move operating_group.
- whether legal_entity changes are versioned.
- whether tenant can have multiple companies.

## 7 Current Status

Status: active SaaS context axes model. Not implementation approval.
