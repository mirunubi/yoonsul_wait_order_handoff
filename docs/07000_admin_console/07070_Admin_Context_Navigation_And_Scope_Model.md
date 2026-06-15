# 07070_Admin_Context_Navigation_And_Scope_Model

## 1 Purpose

Admin Console must navigate tenant, company, legal_entity, operating_group, and store contexts without collapsing them.

Admin context visibility does not equal mutation authority.

This document defines navigation/scope model only.

This document does not define admin UI implementation, auth schema, or API endpoints.

## 2 Context Navigation Levels

| level | purpose |
| --- | --- |
| platform context | Platform-wide governance and cross-tenant policy visibility within platform policy. |
| tenant context | SaaS customer boundary and tenant-scoped configuration. |
| company context | Operating company or brand entity visibility. |
| legal_entity context | Legal/tax/settlement entity visibility. |
| operating_group context | Regional, franchise, or operational group visibility. |
| store context | Store operational unit for runtime and handoff visibility. |
| support scoped context | Time-bounded support session visibility per `20040`/`24020`. |
| audit read-only context | Audit and change history visibility without mutation authority. |

Aligns with `docs/03000_saas_runtime/03020_Tenant_Company_Legal_Operating_Group_Context_Model.md`.

## 3 Scope Rules

- tenant is SaaS customer boundary.
- company/legal_entity is legal/contract context.
- operating_group is operational grouping context.
- store is operational unit.
- operating_group and company/legal_entity are parallel/context axes.
- support scoped context must be time-bounded and audited.
- audit read-only context must not mutate state.

## 4 Visibility vs Authority

- view authority does not equal mutation authority.
- context switch does not equal approval.
- role label does not equal action permission.
- support visibility does not equal approval.
- audit visibility does not equal export authority.

## 5 Cross-References

- `docs/07000_admin_console/07010_Admin_Console_Context_And_Role_Model.md`
- `docs/07000_admin_console/07040_Admin_Screen_Inventory_And_Navigation_Model.md`
- `docs/13000_app_api_projection/13060_Matrix_Surface_State_Visibility_And_Authority.md`
- `docs/20000_validation_security_audit/20040_Governance_Admin_Access_And_Support_Access.md`

## 6 Open Decisions

- default landing context.
- multi-tenant admin switching.
- tenant admin vs platform admin split.
- legal_entity view depth.
- operating_group navigation naming.
- store context selector behavior.

## 7 Current Status

Status: active admin context navigation and scope model. Not implementation approval.
