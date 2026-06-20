# 009040_State_And_Event_Ownership_Model

## 1 Purpose

State changes must be owned by explicit authority.

Visibility does not equal authority.

Events may be observational, request-based, confirmation-based, recovery-based, audit-only, or external truth events.

This document is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, RLS, RPC, API endpoints, payment implementation, POS integration, or printer implementation.

## 2 Truth Families

| truth family | who/what produces it | what it can prove | what it cannot prove | examples |
| --- | --- | --- | --- | --- |
| Customer Intent Truth | Customer webapp, Mini Kiosk, customer session, cart/order candidate submission. | Customer intended to browse, wait, submit cart, or request preorder. | Staff confirmation, POS sale, payment, fulfillment. | cart submitted, order candidate created, preorder request sent. |
| Store Operational Truth | Store staff, store manager, store console, store runtime. | Store reviewed, called, seated, confirmed, cancelled, or recovered an operational state. | POS transaction or platform payment unless separately sourced. | staff confirms order candidate, table assigned, recovery resolved. |
| Handoff Delivery Truth | Store Agent, printer, handoff surface, delivery/status event. | Handoff message/ticket/status was attempted, delivered, failed, or retried. | POS sales creation or staff confirmation. | Store Agent delivery, printer output attempt/result. |
| POS Transaction Truth | External POS API success response or staff-provided manual POS proof. | POS-side order or transaction status within integration boundary. | Platform payment, customer fulfillment, or universal POS success without response. | POS API success, manually entered POS marker with staff proof. |
| Payment Truth | Store POS, approved platform payment future, legal/payment authority. | Payment pending, paid, refunded, or failed where payment authority exists. | Waiting or handoff state by itself. | store POS payment pending, future platform payment approved. |
| Audit Truth | Audit event and evidence record. | What action was recorded, by whom, when, why, and with what result. | Approval or operational mutation by itself. | config change audit, export evidence, support session evidence. |
| Future Intelligence Truth | Governed analytics, sanitized data, future Franchise OS recommendation. | Patterns, recommendations, and outcome measurements under approved policy. | Runtime mutation or direct authority. | package recommendation, recovery rule recommendation. |

## 3 Event Authority Types

- `customer_intent_event`: produced by customer or Mini Kiosk interaction.
- `staff_confirmation_event`: produced by authorized store staff or manager.
- `store_agent_delivery_event`: produced by Store Agent delivery/status observation.
- `printer_delivery_event`: produced by printer attempt/result observation.
- `pos_api_attempt_event`: produced by POS gateway attempt.
- `pos_api_success_event`: produced only after successful POS response.
- `payment_status_event`: produced by store POS or future approved payment authority.
- `admin_config_event`: produced by approved admin configuration action.
- `support_action_event`: produced by scoped support session action.
- `recovery_event`: produced by recovery queue action.
- `audit_evidence_event`: produced by audit/evidence capture.
- `future_recommendation_event`: produced by future intelligence interpretation.

## 4 State Ownership Rules

- customer action can create order candidate but cannot confirm POS order.
- staff confirmation can confirm store-reviewed order but not POS transaction unless POS/manual process confirms it.
- printer output can prove print attempt/result but not POS sales creation.
- POS API success can prove external POS response only within integration boundary.
- platform payment is not MVP default and requires separate authority.
- support action does not equal approval.
- audit evidence does not mutate state.
- recommendation does not equal execution.

## 5 State Families And Owners

| state family | owner | notes |
| --- | --- | --- |
| `customer_session` | Customer-facing session lifecycle. | Customer owns intent actions; store/support may assist only within policy. |
| `waiting_session` | Store waiting operation. | Customer can request/cancel where allowed; staff/store confirms operational state. |
| `handoff_session` | Store/customer handoff bridge. | Customer creates intent; staff owns store confirmation. |
| `mini_kiosk_session` | Current kiosk session context. | Customer/store-assisted surface owns current session visibility. |
| `store_runtime` | Store/admin runtime configuration authority. | Store staff may see state; admin approval controls high-risk config. |
| `order_candidate` | Customer intent until staff confirmation. | Staff can review/confirm/reject; POS truth remains separate. |
| `preorder_request` | Customer pre-confirmation request plus store review. | Not paid or POS-confirmed by default. |
| `manual_recovery_item` | Recovery queue owner assigned by store/admin policy. | Resolution appends events and does not erase original event. |
| `admin_change_request` | Admin approval workflow. | Requester may not be approver for high-risk changes. |
| `export_request` | Export/report approval governance. | View authority does not equal export authority. |
| `future_franchise_recommendation` | Future intelligence review authority. | Recommendation needs admin approval before controlled application. |

## 6 Forbidden Ownership Collapses

- order candidate must not be treated as confirmed order.
- preorder request must not be treated as paid order.
- printer success must not be treated as POS sale.
- POS API attempt must not be treated as POS success.
- Store Agent delivery must not be treated as staff confirmation.
- support action must not be treated as approval.
- analytics recommendation must not be treated as runtime mutation.

## 7 Conceptual Model Consolidation Cross-Reference

- Order candidate/confirmation refinement is defined in `docs/09000_data_model_state_machine/009090_Order_Candidate_And_Confirmation_State_Refinement.md`.
- Runtime profile/change state ownership is defined in `docs/09000_data_model_state_machine/009080_Runtime_Profile_And_Change_Request_Entity_Model.md`.
- Admin/support/audit lineage is defined in `docs/09000_data_model_state_machine/009100_Admin_Support_Audit_Entity_Lineage_Model.md`.
- Future profile/analytics state boundary is defined in `docs/09000_data_model_state_machine/009110_Boundary_Future_Profile_And_Analytics_State.md`.

## 8 Open Decisions

- manual POS input proof.
- POS API idempotency ownership.
- staff confirmation authority depth.
- support operator mutation boundary.
- emergency disable ownership.
- future recommendation approval authority.

## 9 Current Status

Status: active state and event ownership model.
