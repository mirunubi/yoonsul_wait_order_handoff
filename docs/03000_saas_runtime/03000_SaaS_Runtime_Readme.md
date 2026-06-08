# 03000 SaaS Runtime Readme

## 1 Purpose

This folder defines SaaS tenant, context axes, store runtime, package plans, feature flags, runtime profiles, and runtime governance boundaries.

This wave consolidates the SaaS runtime model after MVP scope consolidation in `01000`.

## 2 In Scope

- SaaS tenant and context axis model.
- Store runtime profile model.
- Package plan and feature flag runtime governance.
- Runtime profile change and audit governance.
- Non-MVP and future runtime profile boundaries.
- Initial tenant/store runtime model in `03010`.

## 3 Document List

| document | description |
| --- | --- |
| `03010_Tenant_Store_Runtime_And_Package_Model.md` | Initial tenant/store runtime separation, package plans, feature flags, integration profiles, payment profiles, customer wording, and runtime change rules. |
| `03020_Tenant_Company_Legal_Operating_Group_Context_Model.md` | Context axes for tenant, company, legal_entity, operating_group, and store without hierarchy collapse. |
| `03030_Store_Runtime_Profile_Model.md` | store_runtime components, status concepts, and profile truth rules. |
| `03040_Package_Plan_And_Feature_Flag_Runtime_Governance.md` | Package plans, feature flag categories, and runtime governance rules aligned with `01050`. |
| `03050_Runtime_Profile_Change_And_Audit_Governance.md` | Change types, lifecycle, and audit rules for runtime profile changes. |
| `03060_Runtime_Profile_Non_MVP_And_Future_Flag_Boundary.md` | Non-MVP runtime profiles and future activation preconditions. |

`03010` remains the initial tenant/store runtime model.

`03020`~`03060` consolidate context axes, runtime profiles, package/flag governance, change/audit governance, and non-MVP future profile boundaries.

## 4 Out Of Scope

- Implementation, billing code, authentication code, database schema, payment logic, POS/printer integration, membership runtime, analytics runtime, and production tenant architecture.

## 5 Current Status

Status: SaaS runtime consolidation wave complete. Runtime governance only. Not implementation approval.
