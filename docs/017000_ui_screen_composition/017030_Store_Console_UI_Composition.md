# 017030_Store_Console_UI_Composition

## 1 Purpose

Store Console helps store staff operate waiting, order candidate review, preorder requests, Mini Kiosk sessions, Store Agent/printer/POS API visibility, and manual recovery.

Store Console is not POS.

Store Console is not financial truth.

This document is UI screen composition projection only.
It does not define UI components, routing, API endpoints, POS integration, printer driver, or production store app behavior.

## 2 Screen Groups

### 2.1 Store Dashboard

| field | composition |
| --- | --- |
| primary information | Waiting count, order candidate queue count, recovery count, Mini Kiosk active sessions, integration health summary. |
| primary action | Open highest-priority queue. |
| secondary action | View Store Agent, printer, POS API status. |
| visible state | Operational summary scoped to store. |
| prohibited implication | Dashboard totals are not financial truth. |

### 2.2 Waiting Session List / Detail

| field | composition |
| --- | --- |
| primary information | Session state, party context, call/arrival state, linked order candidate if any. |
| primary action | Call customer, mark arrival, open linked candidate. |
| secondary action | Cancel, flag recovery, request support. |
| visible state | Registered, confirmed, called, arrived, no-show candidate, cancelled, expired. |
| prohibited implication | Waiting state does not imply order confirmation. |

### 2.3 Order Candidate Queue / Detail

| field | composition |
| --- | --- |
| primary information | Candidate items, options, notes, submission time, review state, duplicate hint. |
| primary action | Open staff confirmation screen. |
| secondary action | Reject/cancel, flag duplicate, request support. |
| visible state | Pending, staff-confirmed, recovery required, rejected, cancelled. |
| prohibited implication | Candidate detail is not POS sales record. |

### 2.4 Preorder Request Queue / Detail

| field | composition |
| --- | --- |
| primary information | Preorder summary, waiting/handoff link, review state. |
| primary action | Review and confirm or reject preorder request. |
| secondary action | Link to waiting session, open recovery. |
| visible state | Submitted, staff review pending, staff-confirmed, recovery required. |
| prohibited implication | Preorder request is not paid order. |

### 2.5 Staff Confirmation Screen

| field | composition |
| --- | --- |
| primary information | Full candidate summary, customer wording level, integration level, required next steps. |
| primary action | Confirm staff-reviewed order, reject/cancel candidate. |
| secondary action | Mark manual POS input needed, flag duplicate. |
| visible state | Review in progress, confirmation result, audit note prompt. |
| prohibited implication | Staff confirmation does not equal platform payment or POS success. |

### 2.6 Mini Kiosk Session Monitor

| field | composition |
| --- | --- |
| primary information | Active kiosk sessions, cart/candidate state, language, staff help requests. |
| primary action | Assist session, open candidate for review. |
| secondary action | End session, flag recovery. |
| visible state | Active, staff-assisted, candidate submitted, recovery required. |
| prohibited implication | Browsing or cart activity is not confirmed order. |

### 2.7 Store Agent Status

| field | composition |
| --- | --- |
| primary information | Agent health, runtime validation, last heartbeat, activation state. |
| primary action | Request support, view related recovery items. |
| secondary action | Open integration profile reference. |
| visible state | Online, degraded, offline, validation pending. |
| prohibited implication | Agent online does not equal order confirmation. |

### 2.8 Printer Status

| field | composition |
| --- | --- |
| primary information | Last print attempt, success/failure, retry eligibility, related candidate. |
| primary action | Retry printer output where authorized. |
| secondary action | Open recovery item, request support. |
| visible state | Print pending, print succeeded, print failed, retry in progress. |
| prohibited implication | Printer retry does not imply POS sales creation. |

### 2.9 POS API Status

| field | composition |
| --- | --- |
| primary information | Last API attempt, response state, duplicate prevention hint, related candidate. |
| primary action | Retry or request escalation where authorized. |
| secondary action | Mark manual POS input needed or completed. |
| visible state | Not configured, attempt pending, success, failure, manual fallback required. |
| prohibited implication | POS API attempt must not be shown as success until success response. |

### 2.10 Manual Recovery Queue / Detail

| field | composition |
| --- | --- |
| primary information | Recovery reason, original event reference, assigned role, available actions, history. |
| primary action | Resolve recovery item with append-only action. |
| secondary action | Request support, escalate. |
| visible state | Open, in progress, resolved, dismissed with audit note. |
| prohibited implication | Recovery action must not appear to erase original event. |

### 2.11 Audit / Change Visibility

| field | composition |
| --- | --- |
| primary information | Limited audit events for store-scoped confirmation, recovery, printer, POS API, and support requests. |
| primary action | View event detail. |
| secondary action | Filter by session, candidate, or recovery item. |
| visible state | Event list, append-only history. |
| prohibited implication | Audit visibility does not grant mutation authority. |

## 3 Action Buttons / Controls

Conceptual store console controls:

| control | purpose | audit note |
| --- | --- | --- |
| review candidate | Open candidate for staff review. | Review start should be auditable where policy requires. |
| confirm staff-reviewed order | Confirm handoff after staff review. | Required audit; does not equal POS confirmation. |
| reject/cancel candidate | Reject or cancel candidate with reason. | Required audit. |
| mark manual POS input needed | Indicate staff must enter order into existing POS manually. | Required audit; not financial truth. |
| mark POS input completed | Record that manual POS entry was performed. | Required audit; does not prove platform financial truth. |
| retry printer output | Retry print for authorized roles. | Required audit; not POS sales creation. |
| flag duplicate candidate | Mark suspected duplicate for review. | Required audit. |
| request support | Open scoped support request. | Required audit. |
| resolve recovery item | Append recovery resolution action. | Required audit; must not overwrite original event. |

## 4 Forbidden UI Implications

- confirmation button must not imply platform payment.
- printer retry must not imply POS sales creation.
- POS API attempt must not be shown as success until success response.
- recovery action must not appear to erase original event.
- store console must not display financial truth unless sourced from proper POS/payment authority.

## 5 Cross-References

- `docs/013000_app_api_projection/013030_Store_Console_Projection.md`
- `docs/013000_app_api_projection/013060_Matrix_Surface_State_Visibility_And_Authority.md`
- `docs/013000_app_api_projection/013080_Matrix_Store_Admin_Support_Action_Authority.md`
- `docs/011000_integration_boundary/011010_Boundary_POS_Payment_Printer_Integration.md`
- `docs/017000_ui_screen_composition/017060_Guide_UI_State_Wording_And_Empty_State_Guideline.md`

## 6 Open Decisions

- mobile/tablet layout.
- sound/notification UX.
- duplicate prevention UX.
- POS manual input checklist.
- store staff permission tiers.

## 7 Current Status

Status: active store console UI composition projection. No implementation approval.
