# 007040_Admin_Screen_Inventory_And_Navigation_Model

## 1 Purpose

Admin Console is the control and visibility surface for SaaS runtime operations.

It is not a POS.
It is not a payment settlement console.
It is not a membership/point ledger console.

It must expose only screens that match the user's role and context scope.

This document is conceptual only.
It does not define UI implementation, routing code, SQL, migrations, Supabase functions, or final permissions.

## 2 Navigation Groups

Conceptual navigation groups:

- Dashboard
- Tenant / Company / Legal Entity / Operating Group / Store
- Package Plan / Feature Flags
- Integration Profiles
- Payment Profile
- Order Candidate / Preorder Review
- Waiting / Mini Kiosk Monitoring
- Store Agent / Printer Monitoring
- Manual Recovery Queue
- Audit / Change History
- Support Tools
- Reports / Export
- Future Reserved: Membership / Point

## 3 Screen Inventory

| screen | purpose | primary roles | view authority | mutation authority | forbidden actions |
| --- | --- | --- | --- | --- | --- |
| Admin Dashboard | Show scoped operational and configuration overview. | platform_admin, tenant_admin, operating_group_manager, store_owner, store_manager, support_operator | Scoped dashboard by role. | No direct high-risk mutation. | Do not show hidden payment/POS truth beyond configured profiles. |
| Tenant List / Detail | Manage tenant visibility and contract boundary. | platform_admin, tenant_admin | Platform or tenant-scoped. | Platform or tenant authority only. | Do not mutate store runtime without workflow. |
| Company List / Detail | Show operating company or brand entity. | platform_admin, tenant_admin, company_admin | Company-scoped. | Policy-limited company admin changes. | Do not treat company as legal entity automatically. |
| Legal Entity List / Detail | Show legal/tax/settlement entity context. | platform_admin, legal_admin, tenant_admin | Legal-scoped. | Legal/tax approval workflow only. | Do not change operational order state. |
| Operating Group List / Detail | Show region, direct-operated group, franchise group, or tourist-zone group. | platform_admin, tenant_admin, operating_group_manager | Operating-group-scoped. | Delegated operational settings only. | Do not change legal/tax authority. |
| Store List / Detail | Show store-level runtime and operational summary. | platform_admin, tenant_admin, store_owner, store_manager, support_operator | Store-scoped. | Role-limited store settings. | Do not enable high-risk flags silently. |
| Store Runtime Configuration | Show package, feature, integration, payment, language, and recovery settings. | platform_admin, tenant_admin, store_owner | Scoped by approval authority. | Through approval workflow. | Do not bypass validation. |
| Package Plan Change Request | Request package plan change. | tenant_admin, store_owner, platform_admin | Request visibility by context. | Approval roles only. | Do not auto-enable POS API or payment. |
| Feature Flag Change Request | Request runtime feature flag changes. | tenant_admin, store_owner, support_operator | Scoped request visibility. | Approval roles only. | Do not activate future membership/point flags. |
| Integration Profile Detail | Show integration level and validation status. | platform_admin, tenant_admin, store_owner, support_operator | Scoped integration visibility. | Integration-approved roles only. | Do not claim POS API exists before validation. |
| Payment Profile Detail | Show payment profile and approval state. | platform_admin, legal_admin, tenant_admin | Legal/payment scoped. | Legal/tax and platform approval only. | Do not enable platform payment silently. |
| Order Candidate Review | Review customer order candidate. | store_manager, store_staff, store_owner, support_operator | Store-scoped. | Staff confirmation where allowed. | Do not claim POS completion unless POS confirms. |
| Preorder Request Review | Review preorder request before handoff. | store_manager, store_staff, store_owner | Store-scoped. | Staff confirmation where allowed. | Do not apply payment or point deduction. |
| Waiting Session Monitor | Monitor waiting sessions. | store_manager, store_staff, store_owner, operating_group_manager | Store or group scoped. | Staff actions where allowed. | Do not silently cancel without audit. |
| Mini Kiosk Session Monitor | Monitor Mini Kiosk sessions. | store_manager, store_staff, store_owner | Store-scoped. | Staff confirmation/help where allowed. | Do not treat browsing as confirmed order. |
| Store Agent Status | Show Store Agent health and runtime validation. | platform_admin, tenant_admin, store_owner, support_operator | Scoped status visibility. | Activation through workflow. | Do not equate Agent online with order confirmation. |
| Printer Status | Show printer output state. | platform_admin, tenant_admin, store_owner, store_manager, support_operator | Scoped status visibility. | Retry or disable through workflow/policy. | Printer output does not equal POS sales creation. |
| Manual Recovery Queue | Show recovery items requiring action. | platform_admin, tenant_admin, store_owner, store_manager, support_operator | Scoped recovery visibility. | Assigned recovery action only. | Dismiss does not mean resolved. |
| Recovery Item Detail | Show recovery history and available actions. | platform_admin, tenant_admin, store_owner, store_manager, support_operator | Scoped item visibility. | Append recovery action. | Do not overwrite original event. |
| Audit Event List | Show audit events. | platform_admin, tenant_admin, read_only_auditor, support_operator | Scoped audit visibility. | No mutation by default. | Do not delete audit events. |
| Admin Change History | Show configuration and approval changes. | platform_admin, tenant_admin, read_only_auditor | Scoped change visibility. | No direct mutation. | Do not hide rollback history. |
| Support Session View | Show scoped support access session. | support_operator, platform_admin | Support-scoped. | Support actions only. | Support action does not equal approval. |
| Export / Report View | Show scoped exports and reports. | platform_admin, tenant_admin, read_only_auditor | Scoped export visibility. | Export with audit. | Do not export future point data in MVP. |
| Future Membership / Point Placeholder | Reserve future navigation only. | platform_admin, tenant_admin | Placeholder visibility only. | None in MVP. | No active point balance, redemption, wallet, or ledger screens. |

## 4 Role-Based Navigation

- `platform_admin`: may see all groups within platform policy, including support, audit, and future reserved placeholders.
- `tenant_admin`: may see tenant/company/store/package/feature/integration/payment visibility, operational monitoring, audit, and reports within tenant scope.
- `company_admin`: may see company, operating group, store, dashboard, operational monitoring, and reports where delegated.
- `legal_admin`: may see legal entity, payment profile, approval history, and legal/tax-relevant audit.
- `operating_group_manager`: may see operating group, store, dashboard, waiting/Mini Kiosk monitoring, recovery, and reports within group scope.
- `store_owner`: may see store, runtime configuration requests, operational monitoring, recovery, audit, and reports for owned stores.
- `store_manager`: may see operational monitoring, order/preorder review, recovery queue, Store Agent/printer status, and limited audit.
- `store_staff`: may see order/preorder review, waiting/Mini Kiosk monitoring, and assigned recovery prompts if Admin Console access is allowed.
- `support_operator`: may see scoped support session, recovery, status, and audit needed for support.
- `read_only_auditor`: may see audit/change history and reports only.

## 5 Future Membership / Point Placeholder

Membership/point navigation must remain future-reserved unless `docs/15000_membership_loyalty/` docs approve active runtime.

Primary boundary references:

- `docs/15000_membership_loyalty/015010_Boundary_Membership_Loyalty_Product.md`
- `docs/15000_membership_loyalty/015050_Membership_Admin_And_UI_Reserved_Surface.md`

Admin screen placeholders must not imply active point ledger, wallet, or bridge.

Admin Console may show placeholder/reserved navigation only.

It must not expose active point balance, point redemption, wallet, or point ledger screens in MVP.

## 6 Open Decisions

- whether store_staff needs Admin Console access or a separate store console.
- whether support_operator can access tenant/store screens through scoped support session.
- whether legal_admin exists in MVP.
- report/export scope.
- mobile admin vs desktop admin split.

## 7 Admin Console Consolidation Cross-Reference

- Admin context navigation/scope model is defined in `docs/07000_admin_console/007070_Admin_Context_Navigation_And_Scope_Model.md`.
- Runtime profile configuration screens must follow `docs/07000_admin_console/007080_Governance_Admin_Runtime_Profile_Configuration.md`.
- Feature flag approval/emergency disable screens must follow `docs/07000_admin_console/007090_Admin_Feature_Flag_Approval_And_Emergency_Disable_Model.md`.
- Audit/change history screens must follow `docs/07000_admin_console/007100_Admin_Audit_Review_And_Change_History_Model.md`.
- Support/break-glass boundary must follow `docs/07000_admin_console/007110_Boundary_Admin_Support_And_BreakGlass.md`.

## 8 App/API Projection Cross-Reference

Surface state visibility is defined in `docs/13000_app_api_projection/013060_Matrix_Surface_State_Visibility_And_Authority.md`.

Customer wording matrix is defined in `docs/13000_app_api_projection/013070_Matrix_Customer_Surface_State_Wording.md`.

Store/admin/support action authority is defined in `docs/13000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md`.

## 9 Current Status

Status: active admin console governance design.
