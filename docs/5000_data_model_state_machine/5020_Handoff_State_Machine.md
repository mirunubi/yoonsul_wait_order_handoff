# 5020 Handoff State Machine

## 1 Purpose

This document defines the first conceptual handoff state machine for `yoonsul_wait_order_handoff`.

It is conceptual only.
It does not define SQL, migrations, app code, Supabase functions, final schema, or implementation behavior.

## 2 State Ownership Principle

Each state belongs to the actor or runtime surface that can truthfully observe or decide it.

- `customer_session` state belongs to the customer-facing session lifecycle.
- `waiting_session` state belongs to the store waiting lifecycle.
- `handoff_session` state belongs to the bridge between customer order intent and store confirmation.
- `mini_kiosk_session` state belongs to the lightweight no-waiting ordering path.
- `store_runtime` visibility state belongs to store operation visibility.

No state should silently imply payment completion, POS submission, KDS automation, or kitchen execution.

## 3 customer_session State

Required states:

- `CREATED`
- `ACTIVE`
- `LINKED_TO_WAITING`
- `LINKED_TO_HANDOFF`
- `COMPLETED`
- `CANCELLED`
- `EXPIRED`

Allowed transitions:

| from | to | meaning |
| --- | --- | --- |
| `CREATED` | `ACTIVE` | Customer opens store context and session becomes usable. |
| `ACTIVE` | `LINKED_TO_WAITING` | Customer registers or joins waiting. |
| `ACTIVE` | `LINKED_TO_HANDOFF` | Customer starts direct handoff or Mini Kiosk order intent. |
| `LINKED_TO_WAITING` | `LINKED_TO_HANDOFF` | Waiting customer creates order intent or is seated for handoff. |
| `LINKED_TO_HANDOFF` | `COMPLETED` | Handoff flow completes. |
| `ACTIVE` | `CANCELLED` | Customer cancels before linkage. |
| `LINKED_TO_WAITING` | `CANCELLED` | Waiting flow is cancelled. |
| `LINKED_TO_HANDOFF` | `CANCELLED` | Handoff flow is cancelled before completion. |
| `CREATED` | `EXPIRED` | Session expires before activation. |
| `ACTIVE` | `EXPIRED` | Session times out without completion. |

## 4 waiting_session State

Required states:

- `WAITING_REGISTERED`
- `WAITING_CONFIRMED`
- `PREORDER_AVAILABLE`
- `PREORDER_INTENT_CAPTURED`
- `CALLED`
- `ARRIVED`
- `NO_SHOW_CANDIDATE`
- `CANCELLED`
- `EXPIRED`
- `HANDED_OFF`

Allowed transitions:

| from | to | meaning |
| --- | --- | --- |
| `WAITING_REGISTERED` | `WAITING_CONFIRMED` | Store accepts or confirms the waiting entry. |
| `WAITING_CONFIRMED` | `PREORDER_AVAILABLE` | Menu browsing or preorder intent becomes available. |
| `PREORDER_AVAILABLE` | `PREORDER_INTENT_CAPTURED` | Customer captures order intent before handoff. |
| `WAITING_CONFIRMED` | `CALLED` | Store calls the customer. |
| `PREORDER_INTENT_CAPTURED` | `CALLED` | Store calls a customer who already prepared order intent. |
| `CALLED` | `ARRIVED` | Customer arrives after call. |
| `CALLED` | `NO_SHOW_CANDIDATE` | Customer does not respond within store-defined window. |
| `ARRIVED` | `HANDED_OFF` | Customer is seated or moved into handoff flow. |
| `PREORDER_INTENT_CAPTURED` | `HANDED_OFF` | Order intent is handed to store review. |
| `WAITING_REGISTERED` | `CANCELLED` | Waiting is cancelled before confirmation. |
| `WAITING_CONFIRMED` | `CANCELLED` | Waiting is cancelled after confirmation. |
| `NO_SHOW_CANDIDATE` | `CANCELLED` | Staff confirms final cancellation. |
| `WAITING_REGISTERED` | `EXPIRED` | Waiting request expires before confirmation. |

## 5 handoff_session State

Required states:

- `CREATED`
- `MENU_BROWSING`
- `ORDER_INTENT_CAPTURED`
- `STORE_REVIEW_REQUIRED`
- `READY_FOR_STORE_CONFIRMATION`
- `STORE_CONFIRMED`
- `SENT_TO_PREP`
- `CUSTOMER_NOTIFIED`
- `COMPLETED`
- `CANCELLED`
- `RECOVERY_REQUIRED`

Allowed transitions:

| from | to | meaning |
| --- | --- | --- |
| `CREATED` | `MENU_BROWSING` | Customer enters handoff menu flow. |
| `MENU_BROWSING` | `ORDER_INTENT_CAPTURED` | Customer creates order intent. |
| `ORDER_INTENT_CAPTURED` | `STORE_REVIEW_REQUIRED` | Store review is required before confirmation. |
| `STORE_REVIEW_REQUIRED` | `READY_FOR_STORE_CONFIRMATION` | Staff can confirm after table, pickup, or context check. |
| `READY_FOR_STORE_CONFIRMATION` | `STORE_CONFIRMED` | Staff confirms order handoff. |
| `STORE_CONFIRMED` | `SENT_TO_PREP` | Store marks the handoff as sent to preparation or manual POS process. |
| `SENT_TO_PREP` | `CUSTOMER_NOTIFIED` | Customer receives preparation or confirmation status. |
| `CUSTOMER_NOTIFIED` | `COMPLETED` | Handoff is completed. |
| `CREATED` | `CANCELLED` | Handoff is cancelled before browsing. |
| `MENU_BROWSING` | `CANCELLED` | Customer cancels during browsing. |
| `ORDER_INTENT_CAPTURED` | `CANCELLED` | Customer or staff cancels before review. |
| `STORE_REVIEW_REQUIRED` | `RECOVERY_REQUIRED` | Review cannot continue without staff recovery. |
| `READY_FOR_STORE_CONFIRMATION` | `RECOVERY_REQUIRED` | Confirmation conflict requires recovery. |
| `STORE_CONFIRMED` | `RECOVERY_REQUIRED` | Confirmed handoff encounters operational exception. |

## 6 mini_kiosk_session State

Required states:

- `STARTED`
- `LANGUAGE_SELECTED`
- `MENU_BROWSING`
- `ORDER_INTENT_CAPTURED`
- `STAFF_HELP_REQUESTED`
- `CONFIRMED`
- `CANCELLED`
- `EXPIRED`

Allowed transitions:

| from | to | meaning |
| --- | --- | --- |
| `STARTED` | `LANGUAGE_SELECTED` | Customer selects or accepts display language. |
| `LANGUAGE_SELECTED` | `MENU_BROWSING` | Customer browses menu. |
| `STARTED` | `MENU_BROWSING` | Store default language is used. |
| `MENU_BROWSING` | `ORDER_INTENT_CAPTURED` | Customer captures order intent. |
| `MENU_BROWSING` | `STAFF_HELP_REQUESTED` | Customer asks for staff help. |
| `STAFF_HELP_REQUESTED` | `MENU_BROWSING` | Staff resolves help request and browsing continues. |
| `ORDER_INTENT_CAPTURED` | `CONFIRMED` | Staff confirms Mini Kiosk order intent. |
| `STARTED` | `CANCELLED` | Customer cancels early. |
| `MENU_BROWSING` | `CANCELLED` | Customer cancels during browsing. |
| `ORDER_INTENT_CAPTURED` | `CANCELLED` | Order intent is cancelled before confirmation. |
| `STARTED` | `EXPIRED` | Session times out before use. |
| `MENU_BROWSING` | `EXPIRED` | Browsing session times out. |

## 7 store_runtime Visibility State

Required states:

- `NORMAL`
- `BUSY`
- `DELAYED`
- `DEGRADED`
- `MANUAL_RECOVERY_REQUIRED`

Allowed transitions:

| from | to | meaning |
| --- | --- | --- |
| `NORMAL` | `BUSY` | Store is operating but wait or order pressure is high. |
| `BUSY` | `DELAYED` | Customer handoff or preparation delay is visible. |
| `DELAYED` | `NORMAL` | Delay clears. |
| `NORMAL` | `DEGRADED` | Store runtime has limited visibility or degraded operation. |
| `BUSY` | `DEGRADED` | Busy state becomes operationally degraded. |
| `DELAYED` | `DEGRADED` | Delay becomes degraded operation. |
| `DEGRADED` | `MANUAL_RECOVERY_REQUIRED` | Staff intervention is required. |
| `MANUAL_RECOVERY_REQUIRED` | `NORMAL` | Staff resolves recovery and normal visibility resumes. |
| `MANUAL_RECOVERY_REQUIRED` | `BUSY` | Recovery completes but store remains busy. |

## 8 Forbidden Transitions

- `customer_session` must not move from `COMPLETED` back to `ACTIVE`.
- `waiting_session` must not move from `CANCELLED` to `HANDED_OFF`.
- `waiting_session` must not move from `EXPIRED` to `HANDED_OFF` without a new waiting session.
- `handoff_session` must not move from `CREATED` directly to `STORE_CONFIRMED` without order intent and store review.
- `handoff_session` must not move from `ORDER_INTENT_CAPTURED` directly to `SENT_TO_PREP`.
- `handoff_session` must not move from `CANCELLED` to `STORE_CONFIRMED`.
- `mini_kiosk_session` must not move from `STARTED` directly to `CONFIRMED` without order intent.
- `store_runtime` visibility must not hide `MANUAL_RECOVERY_REQUIRED` as `NORMAL` without a staff action.

## 9 Recovery Rules

- Missing customer session linkage creates recovery review, not silent deletion.
- Menu unavailable after order intent requires customer adjustment, staff substitution, cancellation, or recovery.
- No-show handling should pass through `NO_SHOW_CANDIDATE` before final cancellation where possible.
- Conflicting table or pickup context requires `RECOVERY_REQUIRED`.
- Store runtime degradation should reduce promise language shown to customers.
- Manual recovery should record staff action and audit event conceptually.

## 10 Audit Principle

Important state transitions should produce audit-visible events at the design level.

Audit-worthy moments include:

- waiting confirmation.
- preorder intent capture.
- customer call.
- arrival or no-show candidate marking.
- table or pickup assignment.
- store confirmation.
- cancellation.
- recovery requirement.
- recovery completion.

Audit does not imply final database schema in this document.

## 11 Open Decisions

- Whether no-show timing is global, tenant-level, store-level, or staff-selected.
- Whether `SENT_TO_PREP` means manual POS entry, kitchen note, or future integration event.
- Whether customer notification state belongs inside handoff session or separate notification history.
- Whether Mini Kiosk confirmation can be customer-only in later phases or always staff-confirmed.
- Whether store runtime visibility is staff-set, system-derived, or hybrid.

## 12 Consolidation Cross-References

Entity definitions are consolidated in `docs/5000_data_model_state_machine/5030_Conceptual_Entity_Master.md`.

State/event ownership is defined in `docs/5000_data_model_state_machine/5040_State_And_Event_Ownership_Model.md`.

Audit/recovery lineage is defined in `docs/5000_data_model_state_machine/5050_Audit_Recovery_Event_Lineage_Model.md`.

Implementation is deferred by `docs/5000_data_model_state_machine/5060_Implementation_Deferred_Data_Model_Boundary.md`.
