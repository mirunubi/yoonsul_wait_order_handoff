# 017050_Support_Console_UI_Composition

## 1 Purpose

Support Console is scoped, time-bounded, audited operational assistance.

Support Console is not approval authority.

Support Console must respect tenant/store scope and sensitive data masking.

This document is UI screen composition projection only.
It does not define UI components, routing, API endpoints, auth implementation, or production support tooling.

## 2 Screen Groups

### 2.1 Scoped Support Session Entry

| field | composition |
| --- | --- |
| primary information | Session request state, approver, tenant/store scope, reason, allowed screens, start/end window. |
| primary action | Enter scoped session when approved and active. |
| secondary action | View pending request, revoke if authorized. |
| visible state | Pending approval, active, expired, revoked. |
| masking note | No standing access; session must be explicit. |

### 2.2 Allowed Tenant / Store Context View

| field | composition |
| --- | --- |
| primary information | Scoped tenant, store, runtime summary within approved context only. |
| primary action | Navigate to allowed operational views. |
| secondary action | Request scope extension through workflow. |
| visible state | Context banner showing scope limits. |
| masking note | Cross-tenant and out-of-scope stores must not appear. |

### 2.3 Session Reason Display

| field | composition |
| --- | --- |
| primary information | Requested_by, approved_by, reason, incident reference, allowed actions. |
| primary action | Acknowledge reason before action. |
| secondary action | Add support note. |
| visible state | Immutable reason record for session. |
| masking note | Reason must not expose unrelated customer data. |

### 2.4 Operational State View

| field | composition |
| --- | --- |
| primary information | Waiting, handoff, Mini Kiosk, order candidate, preorder, recovery summary within scope. |
| primary action | Open item for assistance view. |
| secondary action | Recommend next action without silent mutation. |
| visible state | Operational states needed for support only. |
| masking note | High-sensitivity customer fields masked by default. |

### 2.5 Recovery Item Support View

| field | composition |
| --- | --- |
| primary information | Recovery reason, history, assigned role, available assist actions. |
| primary action | Assist recovery, request escalation. |
| secondary action | Document support action. |
| visible state | Append-only recovery history. |
| masking note | Support assist must not overwrite original event. |

### 2.6 Store Agent / Printer / POS API Troubleshooting View

| field | composition |
| --- | --- |
| primary information | Integration health, last attempts, related recovery items. |
| primary action | Assist retry or escalation request where authorized. |
| secondary action | Open integration profile reference. |
| visible state | Status and attempt history within scope. |
| masking note | POS API success must not be implied without response evidence. |

### 2.7 Support Action Log

| field | composition |
| --- | --- |
| primary information | Chronological support actions, actor, timestamp, scope, outcome. |
| primary action | Review prior actions during session. |
| secondary action | Add structured support note. |
| visible state | Append-only log for session. |
| masking note | Log must be auditable and non-destructive. |

### 2.8 Session Close / Revoke Screen

| field | composition |
| --- | --- |
| primary information | Session duration, actions taken, close reason, revocation state. |
| primary action | Close session with required summary. |
| secondary action | Revoke active session when authorized. |
| visible state | Closed, revoked, expired. |
| masking note | Close must end access immediately. |

## 3 Support Rules

- support action does not equal approval.
- support cannot silently mutate order state.
- support access must be scoped and audited.
- support export is not allowed without approval.
- support session has start/end time.

Additional constraints:

- support operator cannot approve own support action.
- sensitive customer details should be masked by default.
- support assist appends events; it does not erase original operational events.
- break-glass or emergency support must still record scope, reason, and audit trail.

## 4 Cross-References

- `docs/20000_validation_security_audit/020040_Governance_Admin_Access_And_Support_Access.md`
- `docs/20000_validation_security_audit/020070_Audit_Evidence_And_Compliance_Record_Model.md`
- `docs/13000_app_api_projection/013060_Matrix_Surface_State_Visibility_And_Authority.md`
- `docs/13000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md`
- `docs/17000_ui_screen_composition/017040_Admin_Console_UI_Composition.md`

## 5 Open Decisions

- whether support is separate app or admin mode.
- support approval depth.
- break-glass support.
- masking depth.
- support action templates.

## 6 Current Status

Status: active support console UI composition projection. No implementation approval.
