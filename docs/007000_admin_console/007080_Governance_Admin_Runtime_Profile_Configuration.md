# 007080_Governance_Admin_Runtime_Profile_Configuration

## 1 Purpose

Admin Console may display and request changes to store runtime profiles.

Runtime profile configuration must follow `03030`, `03040`, and `03050`.

Admin UI does not create activation authority by itself.

This document is Admin Console governance only.
It does not approve implementation or define admin UI code.

## 2 Configurable Profile Areas

| area | admin scope |
| --- | --- |
| store_runtime_status | View and request status transitions per approval workflow. |
| store_package_plan | View and request package plan changes. |
| store_feature_flags | View and request flag changes per `07090`. |
| store_integration_profile | View and request integration profile changes with validation. |
| store_payment_profile | View and request payment profile changes with legal review. |
| store_language_profile | View and request language/menu display configuration. |
| store_menu_profile | View and request menu profile configuration. |
| store_agent_profile | View and request Store Agent profile changes. |
| store_support_profile | View support posture; changes governed by support boundary. |
| store_analytics_profile | View analytics posture placeholders per `26000`; not BI runtime. |
| store_membership_profile | View membership placeholders per `15000`; not ledger runtime. |

## 3 Admin Action Classes

| action class | authority note |
| --- | --- |
| view profile | Read-only visibility within role scope. |
| draft change | Prepare change without activation. |
| request change | Submit change for validation/approval. |
| validate change | Confirm technical/policy prerequisites. |
| approve change | Matching authority approves change. |
| schedule activation | Define activation window if policy requires. |
| activate | Apply approved profile change with audit. |
| emergency disable | Disable risky capability with recorded reason. |
| rollback | Controlled rollback preserving audit history. |
| archive profile | Retire runtime profile from active use. |

## 4 Governance Rules

- admin visibility does not equal activation authority.
- change request does not equal approval.
- approval does not equal activation.
- activation must be auditable.
- rollback does not erase audit.
- emergency disable must be recorded.
- high-risk flags require approval.
- support action does not equal approval.

## 5 Cross-References

- `docs/03000_saas_runtime/003030_Store_Runtime_Profile_Model.md`
- `docs/03000_saas_runtime/003040_Governance_Package_Plan_And_Feature_Flag_Runtime.md`
- `docs/03000_saas_runtime/003050_Governance_Runtime_Profile_Change_And_Audit.md`
- `docs/07000_admin_console/007020_Admin_Store_Runtime_Configuration_Model.md`
- `docs/07000_admin_console/007090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md`

## 6 Open Decisions

- who can activate runtime profile.
- whether tenant admin can approve low-risk changes.
- whether platform approval is required for high-risk flags.
- whether emergency disable bypasses approval but requires audit.
- whether runtime profile snapshots are immutable.

## 7 Current Status

Status: active admin runtime profile configuration governance. Not implementation approval.
