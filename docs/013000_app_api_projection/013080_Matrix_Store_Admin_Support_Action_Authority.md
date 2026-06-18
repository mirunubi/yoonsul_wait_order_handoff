# 013080_Matrix_Store_Admin_Support_Action_Authority

## 1 Purpose

Operational actions must be separated from configuration actions, support actions, approval actions, and audit visibility.

This document is projection only.

It does not define UI implementation, API endpoint implementation, RLS policy implementation, physical permission schema, database schema, or production authorization behavior.

## 2 Roles

Roles used in this projection:

- `store_staff`.
- `store_manager`.
- `store_owner`.
- `operating_group_manager`.
- `tenant_admin`.
- `company_admin`.
- `legal_admin`.
- `platform_admin`.
- `support_operator`.
- `read_only_auditor`.

## 3 Action Families

Conceptual action families:

- order candidate review.
- preorder confirmation.
- manual POS input marking.
- printer retry.
- Store Agent restart/request support.
- POS API retry/request escalation.
- manual recovery resolution.
- package plan request.
- package plan approval.
- feature flag request.
- feature flag approval.
- payment profile request.
- payment profile approval.
- support scoped access request.
- support action.
- export request.
- export approval.
- audit viewing.
- emergency disable.

## 4 Authority Table

| action | allowed roles | approval required? | audit required? | forbidden roles | notes |
| --- | --- | --- | --- | --- | --- |
| order candidate review | `store_staff`, `store_manager`, `store_owner`, scoped `support_operator` view/assist | Store policy may require manager confirmation. | Yes for review result. | `read_only_auditor`, unrelated admins | Review does not equal POS confirmation. |
| preorder confirmation | `store_staff`, `store_manager`, `store_owner` | Required if store policy or high-risk context applies. | Yes. | `support_operator` alone, `read_only_auditor` | Confirmation must preserve customer wording boundary. |
| manual POS input marking | `store_staff`, `store_manager`, `store_owner` | Usually no, unless correction/recovery is involved. | Yes. | `read_only_auditor`, customer, support alone | Marking does not prove platform financial truth. |
| printer retry | `store_manager`, `store_owner`, scoped `support_operator` assist | May require manager or support approval depending device policy. | Yes. | `read_only_auditor`, customer | Printer retry does not equal POS order creation. |
| Store Agent restart/request support | `store_manager`, `store_owner`, `tenant_admin`, `platform_admin`, scoped `support_operator` assist | Required for restart if policy treats it as high-risk. | Yes. | `store_staff` unless delegated, `read_only_auditor` | Store Agent status does not equal order confirmation. |
| POS API retry/request escalation | `store_manager`, `store_owner`, `tenant_admin`, `platform_admin`, scoped `support_operator` assist | Required for retry/escalation according to integration validation policy. | Yes. | `store_staff` unless delegated, `read_only_auditor` | Must avoid duplicate POS order. |
| manual recovery resolution | `store_manager`, `store_owner`, scoped `support_operator` assist | Required when recovery is high-risk or cross-role. | Yes. | `read_only_auditor`, support alone where approval is required | Recovery appends events and does not overwrite original event. |
| package plan request | `store_owner`, `operating_group_manager`, `tenant_admin`, `company_admin`, `platform_admin` | Approval required before activation. | Yes. | `store_staff`, `read_only_auditor` | Package change does not auto-enable high-risk flags. |
| package plan approval | `tenant_admin`, `platform_admin`, delegated `company_admin` | Yes, by matching authority. | Yes. | `store_staff`, `store_manager`, `support_operator`, `read_only_auditor` | Platform policy may require platform approval. |
| feature flag request | `store_owner`, `operating_group_manager`, `tenant_admin`, `platform_admin`, scoped `support_operator` request | Approval required for high-risk flags. | Yes. | `store_staff` unless delegated, `read_only_auditor` | Future membership/point flags remain reserved. |
| feature flag approval | `tenant_admin`, `platform_admin`, delegated `store_owner` where policy allows | Yes for high-risk flags. | Yes. | `support_operator` alone, `read_only_auditor` | POS API, printer, Store Agent, and payment need validation. |
| payment profile request | `store_owner`, `tenant_admin`, `legal_admin`, `platform_admin` | Yes. | Yes. | `store_staff`, `store_manager`, `support_operator`, `read_only_auditor` | Payment remains separate from order handoff. |
| payment profile approval | `legal_admin`, `platform_admin`, `tenant_admin` where policy permits | Legal/tax/platform approval required. | Yes. | `store_staff`, `store_manager`, `support_operator`, `read_only_auditor` | `payment_by_platform_enabled` remains future unless approved. |
| support scoped access request | `store_manager`, `store_owner`, `tenant_admin`, `platform_admin`, `support_operator` | Approval required unless emergency policy says otherwise. | Yes. | `read_only_auditor` | Scope, reason, time window, and revocation must be recorded. |
| support action | scoped `support_operator`, `platform_admin` | Sensitive support actions require separate approval. | Yes. | `read_only_auditor`, unscoped support | support action does not equal approval. |
| export request | `store_owner`, `operating_group_manager`, `tenant_admin`, `platform_admin`, `read_only_auditor` request where policy allows | Approval required by risk. | Yes. | `store_staff`, unscoped support | Export scope, purpose, and recipient must be recorded. |
| export approval | `tenant_admin`, `platform_admin`, `legal_admin` for sensitive exports | Yes. | Yes. | `store_staff`, `store_manager`, `support_operator`, `read_only_auditor` | export approval is separate from view authority. |
| audit viewing | `store_owner`, `store_manager` limited, `tenant_admin`, `platform_admin`, `support_operator` scoped, `read_only_auditor` | Usually no for view; export requires approval. | Audit access should be logged where sensitive. | `store_staff` unless delegated | Read-only visibility does not permit mutation. |
| emergency disable | `store_owner`, `tenant_admin`, `platform_admin`, delegated `store_manager` for local emergency | Post-action approval/review may be required. | Yes. | `store_staff` unless delegated, `support_operator` alone, `read_only_auditor` | Emergency disable must not delete sessions. |

## 5 Critical Rules

- support action does not equal approval.
- read-only auditor cannot mutate.
- legal_admin reviews legal/tax-sensitive items but does not operate store runtime.
- store_staff cannot change package/payment/integration profile.
- platform_admin actions still require audit.
- emergency disable must not delete sessions.
- export approval is separate from view authority.

## 6 Escalation Rules

- unresolved recovery item may escalate to store_manager.
- repeated printer failure may escalate to support_operator/platform_admin.
- POS API failure may escalate to integration validation.
- payment profile mismatch may require platform/legal review.
- export request may require tenant/platform/legal approval depending risk.
- suspected duplicate order candidate should escalate before retrying POS API or printer output.

## 7 Open Decisions

- whether store_owner can approve feature flags.
- whether support_operator needs dual approval for sensitive actions.
- whether legal_admin exists in MVP.
- emergency disable authority depth.
- export approval chain.

## 8 Current Status

Status: active store/admin/support action authority projection. No implementation approval.
