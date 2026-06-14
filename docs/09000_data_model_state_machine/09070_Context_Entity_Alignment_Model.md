# 09070_Context_Entity_Alignment_Model

## 1 Purpose

Conceptual entities must reflect tenant, company, legal_entity, operating_group, and store as distinct context axes.

This document does not define physical tables or columns.

It prevents schema design from collapsing context axes prematurely.

This document is conceptual alignment only.
It does not approve schema, auth, or tenant storage design.

## 2 Conceptual Context Entities

| entity | conceptual meaning | source authority | relationship to other context entities | state ownership relevance | implementation-deferred note |
| --- | --- | --- | --- | --- | --- |
| tenant | SaaS customer and contract boundary. | `03020`, `07070` | Owns stores, policies, and tenant-scoped admin context. | Tenant-scoped configuration and visibility. | No tenant table design in this wave. |
| company | Operating company or brand entity. | `03020` | Parallel to legal_entity; may group stores and operating groups. | Company-scoped governance visibility. | May be optional for single-store MVP. |
| legal_entity | Legal, tax, settlement, or contract entity. | `03020` | Parallel to operating_group; relates to payment/legal review. | Legal/contract context for payment profile. | Not operational runtime owner by default. |
| operating_group | Regional, franchise, or operational grouping. | `03020` | Parallel to company/legal_entity; groups stores. | Operational reporting and grouping context. | Persistence depth open for MVP. |
| store | Operational unit for waiting, handoff, and store runtime. | `03020`, `03030` | Belongs to tenant; uses runtime profiles. | Primary operational state ownership unit. | Not same as tenant or company. |
| admin_context | Active admin navigation and role scope. | `07070`, `07010` | Scoped within tenant/company/store axes. | Governs what admin can view vs mutate. | Visibility does not equal authority. |
| support_context | Time-bounded support session scope. | `07110`, `20040`, `24020` | Scoped within tenant/store; audited separately. | Support action visibility and session lifecycle. | Session concept vs entity open. |
| audit_context | Read-only audit and change history scope. | `07100`, `20070` | Cross-cuts runtime, support, and admin events. | Append-oriented review without mutation. | View-only vs event-family concept open. |

## 3 Context Alignment Rules

- tenant is SaaS customer boundary.
- company/legal_entity is legal/contract context.
- operating_group is operational grouping context.
- store is operational unit.
- operating_group and company/legal_entity are parallel/context axes.
- support_context is scoped, time-bounded, and audited.
- audit_context is read-only and append-oriented.
- visibility does not equal authority.

## 4 Non-Implementation Boundary

- no physical table list.
- no columns.
- no SQL.
- no RLS.
- no tenant schema design.
- no auth implementation.

## 5 Cross-References

- `docs/03000_saas_runtime/03020_Tenant_Company_Legal_Operating_Group_Context_Model.md`
- `docs/07000_admin_console/07070_Admin_Context_Navigation_And_Scope_Model.md`
- `docs/09000_data_model_state_machine/09030_Conceptual_Entity_Master.md`

## 6 Open Decisions

- whether all tenants require company/legal_entity at MVP.
- whether operating_group is persisted in MVP.
- whether support_context is separate entity or session concept.
- whether audit_context is view-only or event-family concept.
- whether context history is append-only.

## 7 Current Status

Status: active context entity alignment model. Not implementation approval.
