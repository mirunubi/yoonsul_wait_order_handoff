# 03020 Tenant Company Legal Operating Group Context Model

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

Aligns with `docs/01000_mvp_scope/01040_MVP_Active_Optional_Future_NonGoal_Matrix.md` Active MVP candidates for tenant/store runtime context.

## 5 Cross-References

- `docs/07000_admin_console/07010_Admin_Console_Context_And_Role_Model.md`
- `docs/09000_data_model_state_machine/09030_Conceptual_Entity_Master.md`
- `docs/03000_saas_runtime/03030_Store_Runtime_Profile_Model.md`

## 6 Open Decisions

- whether company/legal_entity required for every tenant.
- whether operating_group exists in MVP data.
- whether store can move operating_group.
- whether legal_entity changes are versioned.
- whether tenant can have multiple companies.

## 7 Current Status

Status: active SaaS context axes model. Not implementation approval.
