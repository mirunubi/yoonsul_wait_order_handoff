# 20080 Access Context And Data Visibility Governance

## 1 Purpose

Access governance must distinguish visibility, request, mutation, approval, support assistance, audit review, and export authority.

UI/API visibility must not imply access authority.

This document defines governance only and does not create auth/RLS implementation.

This document is governance only.
It does not approve role tables, permission matrix code, or access middleware.

## 2 Access Context Families

| context family | governance scope |
| --- | --- |
| customer session context | Customer-facing session and order intent visibility. |
| store staff context | Store operational actions within staff scope. |
| store owner/manager context | Store-level governance within tenant boundary. |
| tenant admin context | Tenant-scoped configuration and policy visibility. |
| platform admin context | Cross-tenant governance within platform policy. |
| support scoped context | Time-bounded support session per `20090`. |
| audit read-only context | Append-oriented audit review without mutation. |
| export approval context | Export request and approval tracking. |
| future analytics context | Aggregate/governed analytics per `26000`. |
| future membership context | Placeholder visibility per `15000`; not ledger authority. |

## 3 Visibility Classes

| visibility class | data scope |
| --- | --- |
| public/store-facing data | Menu, store status, and approved customer-facing content. |
| customer session data | Session-linked waiting, handoff, and order candidate data. |
| store operational data | Staff review, integration operational states, recovery. |
| tenant configuration data | Runtime profile, package, and feature flag posture. |
| integration status data | POS, printer, Store Agent, manual POS status. |
| support session data | Scoped support actions and session lifecycle. |
| audit evidence data | Append-only change, approval, and recovery lineage. |
| export/report data | Governed report and export artifacts. |
| customer-identifiable data | PII and session identity requiring minimization. |
| future benefit/loyalty data | Placeholder membership/benefit visibility; not MVP ledger. |

## 4 Required Rules

- view authority does not equal mutation authority.
- audit visibility does not equal export authority.
- support visibility does not equal approval.
- customer session visibility does not equal tenant admin visibility.
- future analytics visibility does not equal cross-tenant benchmark authority.
- future membership visibility does not equal point ledger or wallet authority.
- integration status visibility does not equal POS/payment authority.

## 5 Non-Implementation Boundary

- no auth implementation.
- no RLS.
- no role table.
- no permission matrix code.
- no access middleware.
- no UI implementation.
- no API implementation.

## 6 Cross-References

- `docs/13000_app_api_projection/13090_Surface_To_Authority_Projection_Model.md`
- `docs/07000_admin_console/07070_Admin_Context_Navigation_And_Scope_Model.md`
- `docs/20000_validation_security_audit/20040_Admin_Access_And_Support_Access_Governance.md`

## 7 Open Decisions

- role naming.
- context propagation model.
- customer identity depth.
- store staff identity depth.
- tenant admin role depth.
- audit viewer role.
- export approver role.

## 8 Current Status

Status: active access context and data visibility governance. Not implementation approval.
