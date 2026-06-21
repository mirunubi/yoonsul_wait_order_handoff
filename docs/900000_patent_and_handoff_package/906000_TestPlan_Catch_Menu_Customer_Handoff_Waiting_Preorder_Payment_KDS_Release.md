# 906000_TestPlan_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md

## 1. Purpose

This test plan verifies the Catch Menu customer handoff journey from store entry to served order, with special focus on waiting-session preorder, payment-confirmed KDS release, and immutable audit evidence.

The purpose is not to test generic ordering only. The purpose is to prove the business-critical handoff claim:

> Waiting time becomes order-preparation time, while kitchen execution remains blocked until payment confirmation.

## 2. Test Scope

### 2.1 In Scope

- Customer QR entry and store context bootstrap
- Customer language selection
- Waiting registration
- Waiting number issuance
- DID waiting display update
- Staff waiting-list update
- Preorder while waiting
- KDS ticket creation in HOLD status
- Staff call of waiting customer
- Customer arrival pending state
- Seat assignment and table binding
- Payment confirmation through server-side payment confirmation flow
- KDS ticket release from HOLD to COMMITTED after approved payment
- KDS transitions from COMMITTED to COOKING, READY, and SERVED
- Ledger/audit/event recording across all handoff points
- Realtime update projection to customer app, staff app, DID, and KDS
- Idempotency and duplicate-event prevention for payment and KDS release

### 2.2 Out of Scope

- Runtime implementation outside approved files
- POS provider settlement reconciliation
- Refund policy implementation beyond payment-failure safety checks
- Menu administration screens
- Full kitchen production optimization
- Franchise HQ analytics dashboard
- AI customer center behavior

## 3. Actors and Devices

| Actor | Device / Surface | Responsibility |
|---|---|---|
| Customer | Customer web app or mobile app | Entry, waiting registration, preorder, payment status confirmation |
| Staff | Staff app or admin console | Waiting call, arrival confirmation, seating, manual exception handling |
| Kitchen staff | KDS | Receives HOLD/COMMITTED/COOKING/READY/SERVED ticket state |
| Store display | DID | Shows waiting/call status only, not payment details |
| Server runtime | API, DB, Realtime, Ledger | Owns state transitions, audit records, idempotency, and release authority |

## 4. State Model Under Test

### 4.1 Waiting / Order Session States

```text
null → WAITING → ARRIVAL_PENDING → SEATED → COMPLETED
```

Allowed exception states must be tested separately:

```text
WAITING → CANCELLED
ARRIVAL_PENDING → NO_SHOW / CALL_EXPIRED
SEATED → PAYMENT_PENDING / CANCELLED / COMPLETED
```

### 4.2 KDS Ticket States

```text
HOLD → COMMITTED → COOKING → READY → SERVED
```

Forbidden direct transitions:

```text
HOLD → COOKING
HOLD → READY
HOLD → SERVED
COMMITTED → HOLD
READY → COOKING, unless explicit rollback rule exists and is approved
```

## 5. Core Invariant

The following invariant must never be broken:

```text
A preorder created during waiting may create a KDS ticket,
but the ticket must remain HOLD and non-actionable until server-confirmed payment approval.
```

KDS release must require all of the following:

```text
payment_ledger.status = APPROVED
payment_ledger.order_id = kds_tickets.order_id
payment confirmation is server-side verified
release operation is idempotent
ledger event is written
conditions_met.payment_confirmed = true
```

## 6. Normal Path Test Cases

### TC-001 — QR Entry and Store Context Bootstrap

**Given** a valid store QR code exists  
**When** the customer scans the QR code  
**Then** `qr_scan_action()` records the scan event  
**And** `bootstrap_customer_app_v2()` loads store context  
**And** language options are available  
**And** no order is created yet.

Expected ledger events:

```text
CUSTOMER_QR_SCANNED
CUSTOMER_APP_BOOTSTRAPPED
LANGUAGE_SELECTED
```

### TC-002 — Waiting Registration

**Given** the customer app is bootstrapped  
**When** the customer enters party size and registers waiting  
**Then** `register_waiting()` creates an order session  
**And** the session state becomes `WAITING`  
**And** a waiting number such as `W-007` is issued  
**And** DID and staff app projections are updated.

Expected state:

```text
order_sessions.status = WAITING
order_sessions.waiting_number = W-007
orders.id = null, unless preorder is created later
```

### TC-003 — Preorder While Waiting Creates KDS HOLD

**Given** the session is in `WAITING` state  
**When** the customer selects menu items and submits preorder  
**Then** `pre_order_while_waiting()` creates an order  
**And** `orders.order_source = PRE_ORDER`  
**And** `orders.order_number` is linked to the waiting number  
**And** one or more KDS tickets are created in `HOLD` state  
**And** kitchen action buttons are disabled.

Expected KDS state:

```text
kds_tickets.kds_status = HOLD
kds_tickets.conditions_met.payment_confirmed = false
kds_tickets.committed_at = null
```

### TC-004 — Staff Calls Waiting Customer

**Given** the session is `WAITING`  
**When** staff calls the waiting customer  
**Then** `call_waiting_customer()` changes the session to `ARRIVAL_PENDING`  
**And** DID displays the call number  
**And** customer app receives push or realtime notification  
**And** staff app shows called state  
**And** KDS remains `HOLD`.

Expected invariant:

```text
Calling the customer must not release KDS.
```

### TC-005 — Seat Assignment

**Given** the session is `ARRIVAL_PENDING`  
**When** staff confirms arrival and assigns a table  
**Then** `seat_waiting_customer()` changes the session to `SEATED`  
**And** `table_number` is bound  
**And** DID removes the call number  
**And** customer app receives `next_step = PROCEED_TO_PAYMENT`  
**And** KDS remains `HOLD`.

Expected invariant:

```text
Seating the customer must not release KDS.
```

### TC-006 — Payment Approval Releases KDS

**Given** the session is `SEATED`  
**And** the preorder has KDS tickets in `HOLD`  
**When** server-side payment confirmation succeeds  
**Then** `confirm_payment()` writes `payment_ledger.status = APPROVED`  
**And** `release_kds_after_payment()` is called server-side  
**And** KDS ticket state changes from `HOLD` to `COMMITTED`  
**And** `committed_at` is set  
**And** kitchen action buttons become active  
**And** the KDS timer starts.

Expected KDS state:

```text
kds_tickets.kds_status = COMMITTED
kds_tickets.conditions_met.payment_confirmed = true
kds_tickets.committed_at IS NOT NULL
```

### TC-007 — Kitchen Flow

**Given** the KDS ticket is `COMMITTED`  
**When** kitchen staff starts cooking  
**Then** the ticket changes to `COOKING`  
**When** kitchen marks ready  
**Then** the ticket changes to `READY`  
**When** staff serves the item  
**Then** the ticket changes to `SERVED`.

Expected transitions:

```text
COMMITTED → COOKING → READY → SERVED
```

### TC-008 — Order Completion and Ledger Evidence

**Given** all required KDS tickets are `SERVED`  
**When** completion criteria are satisfied  
**Then** order status becomes `COMPLETED` or an approved equivalent terminal state  
**And** the full handoff path is present in `catchmenu_ledger.events`  
**And** operation metrics are updated.

Expected evidence chain:

```text
QR scanned
App bootstrapped
Waiting registered
Preorder submitted
KDS HOLD created
Customer called
Customer seated
Payment approved
KDS released
Cooking started
Food ready
Food served
Order completed
```

## 7. Failure and Edge Case Test Cases

### TC-101 — Payment Failure Does Not Release KDS

**Given** KDS ticket is `HOLD`  
**When** payment confirmation fails  
**Then** payment ledger records failure  
**And** KDS remains `HOLD`  
**And** kitchen actions remain disabled.

Forbidden result:

```text
payment failed + kds_status = COMMITTED
```

### TC-102 — Duplicate Payment Confirmation Is Idempotent

**Given** payment confirmation already approved and KDS already released  
**When** duplicate confirm callback or webhook arrives  
**Then** no duplicate KDS release occurs  
**And** `committed_at` is not overwritten  
**And** duplicate event is recorded as idempotent duplicate.

Expected result:

```text
one payment approval
one KDS release
multiple duplicate events allowed only as audit evidence
```

### TC-103 — Client Cannot Directly Release KDS

**Given** a customer or staff client attempts to call a direct KDS release endpoint  
**When** payment is not server-confirmed  
**Then** the request is rejected  
**And** KDS remains `HOLD`.

Expected rule:

```text
KDS release authority belongs to trusted server-side payment confirmation flow only.
```

### TC-104 — Customer No-Show After Call

**Given** the session is `ARRIVAL_PENDING`  
**When** the call expires or staff marks no-show  
**Then** session changes to `CALL_EXPIRED` or `NO_SHOW`  
**And** DID removes or deprioritizes the number according to policy  
**And** KDS remains `HOLD`  
**And** preorder is not cooked.

### TC-105 — Seat Assignment Without Preorder

**Given** the customer registered waiting but did not preorder  
**When** staff seats the customer  
**Then** no KDS ticket exists  
**And** customer app proceeds to normal order/payment flow.

### TC-106 — Menu Item Sold Out During Waiting

**Given** the customer has a preorder in waiting state  
**When** an item becomes sold out before payment  
**Then** payment must be blocked or recalculated according to policy  
**And** KDS must remain `HOLD`  
**And** the customer must receive a clear correction flow.

### TC-107 — Table Change Before Payment

**Given** the customer is seated at table A  
**When** staff changes the table to table B before payment  
**Then** order session table binding updates  
**And** the KDS ticket remains `HOLD`  
**And** payment amount and order identity do not change.

### TC-108 — Table Change After KDS Release

**Given** payment is approved and KDS is `COMMITTED`  
**When** staff changes the table  
**Then** KDS display must update table assignment  
**And** the KDS status must not regress to `HOLD`.

### TC-109 — Staff Attempts to Start HOLD Ticket

**Given** KDS ticket is `HOLD`  
**When** kitchen staff attempts to start cooking  
**Then** the action is disabled in UI  
**And** server rejects direct transition attempt  
**And** a blocked transition event is logged.

### TC-110 — Partial Payment or Amount Mismatch

**Given** preorder amount is 18,000 KRW  
**When** payment approval amount differs from expected amount  
**Then** KDS must not release  
**And** the payment event is flagged for review or rejected by policy.

## 8. Realtime Projection Tests

| Test | Trigger | Expected Projection |
|---|---|---|
| RT-001 | Waiting registered | DID and staff list update |
| RT-002 | Preorder submitted | KDS shows HOLD ticket only |
| RT-003 | Customer called | DID call screen and customer push/realtime update |
| RT-004 | Customer seated | DID removes called number; customer sees payment step |
| RT-005 | Payment approved | KDS HOLD changes to COMMITTED |
| RT-006 | KDS COOKING/READY/SERVED | Staff app updates state |

## 9. Security / Permission Tests

| Test | Actor | Forbidden Action | Expected Result |
|---|---|---|---|
| SEC-001 | Customer | Change waiting state directly | Rejected |
| SEC-002 | Customer | Release KDS directly | Rejected |
| SEC-003 | Staff | Release KDS without approved payment | Rejected |
| SEC-004 | Kitchen | Start HOLD ticket | Rejected |
| SEC-005 | Anonymous user | Access another session | Rejected |
| SEC-006 | Client app | Forge payment-approved flag | Rejected |

## 10. Audit Evidence Tests

Every state-changing action must write an event with minimum fields:

```text
event_id
store_id
session_id
order_id nullable
kds_ticket_id nullable
actor_type
actor_id nullable
device_surface
event_type
before_state
after_state
idempotency_key nullable
correlation_id
timestamp
result
failure_reason nullable
```

Required audit checks:

- Event order must match the actual handoff timeline.
- No KDS `COMMITTED` event may exist before payment `APPROVED` event.
- Duplicate payment callbacks must not create duplicate release events.
- Blocked transition attempts must be logged.
- Ledger must be append-only or protected by approved audit policy.

## 11. Performance Acceptance Criteria

| Area | Acceptance Criteria |
|---|---|
| QR bootstrap | Store context loads within approved app performance budget |
| Waiting registration | DID/staff projection updates near-real-time |
| KDS HOLD creation | Ticket appears without enabling cooking controls |
| Payment to KDS release | KDS changes to COMMITTED quickly enough for kitchen start without staff refresh |
| Realtime updates | No stale state after state-changing events |
| Duplicate webhook handling | No duplicate release or duplicate order creation |

## 12. Test Data

Minimum test data set:

```text
store_id: STORE_TEST_001
waiting_number: W-007
table_number: T-03
party_size: 2
language: ko
pre_order_amount: 18000
order_source: PRE_ORDER
payment_provider: TossPayments sandbox or approved payment mock
kds_initial_state: HOLD
```

## 13. Acceptance Gate

This test plan is passed only when all conditions below are met:

- Normal 7-step customer handoff passes.
- KDS never releases before approved payment.
- Seating alone never releases KDS.
- Calling alone never releases KDS.
- Payment failure never releases KDS.
- Duplicate payment confirmation is idempotent.
- Unauthorized KDS release attempt is blocked.
- Ledger evidence proves the complete handoff chain.
- Realtime projections are consistent across customer app, staff app, DID, and KDS.
- All failures produce recoverable and auditable states.

## 14. Codex Implementation Boundary

Codex must not implement runtime changes unless a matching `ChangeContract` identifies:

- exact files allowed to edit,
- exact screens allowed to modify,
- exact database functions or RPCs allowed,
- exact test files to add or update,
- prohibited files,
- rollback rule,
- verification command.

This test plan is a verification document, not implementation authorization.
