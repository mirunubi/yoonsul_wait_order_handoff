# 906010_ChangeContract_Catch_Menu_Customer_Handoff_Waiting_Preorder_Payment_KDS_Release.md

## 1. Purpose

This change contract defines the safe implementation boundary for the Catch Menu customer handoff flow covering waiting registration, preorder while waiting, seating, payment confirmation, and KDS release.

The goal is to let Codex implement a narrow, auditable slice without accidentally modifying unrelated runtime, payment, POS, KDS, or admin behavior.

## 2. Business Claim Protected By This Change

Catch Menu converts waiting time into order-preparation time while preserving kitchen safety:

```text
Customer waits → customer preorders → KDS ticket appears in HOLD → customer is seated → payment is approved → KDS releases to COMMITTED → kitchen cooks immediately.
```

The protected patent/business-value point is:

```text
KDS visibility before payment is allowed.
KDS execution before payment is forbidden.
```

## 3. Handoff Flow Under Contract

```text
1. QR entry
2. Waiting registration
3. Preorder while waiting
4. Staff call
5. Seating and table assignment
6. Payment confirmation and KDS release
7. Kitchen execution and served completion
```

## 4. Source of Truth Rules

### 4.1 Session Source of Truth

`order_sessions` is the source of truth for the customer's handoff position.

Expected primary states:

```text
WAITING
ARRIVAL_PENDING
SEATED
COMPLETED
```

Expected exception states:

```text
CANCELLED
CALL_EXPIRED
NO_SHOW
PAYMENT_PENDING
PAYMENT_FAILED
```

### 4.2 Order Source of Truth

`orders` is created only when the customer submits a preorder or a normal seated order.

For waiting preorder:

```text
orders.order_source = PRE_ORDER
orders.order_number links to waiting number or session reference
orders.session_id links to order_sessions.id
```

### 4.3 KDS Source of Truth

`kds_tickets` owns kitchen action state.

Allowed main path:

```text
HOLD → COMMITTED → COOKING → READY → SERVED
```

`HOLD` means visible but non-actionable.

`COMMITTED` means payment-confirmed and kitchen-actionable.

### 4.4 Payment Source of Truth

`payment_ledger` or the approved payment ledger table owns payment confirmation state.

Client-side payment result is not sufficient for KDS release.

KDS release requires trusted server-side payment approval.

## 5. Core Non-Negotiable Invariants

### INV-001 — KDS Release Requires Approved Payment

```text
kds_tickets.kds_status may change from HOLD to COMMITTED only after payment_ledger.status = APPROVED.
```

### INV-002 — Seating Is Not Payment

```text
order_sessions.status = SEATED must not release KDS.
```

### INV-003 — Calling Is Not Payment

```text
order_sessions.status = ARRIVAL_PENDING must not release KDS.
```

### INV-004 — Client Is Not Release Authority

```text
Customer app, staff app, DID, and KDS UI must not directly release HOLD tickets.
```

### INV-005 — Release Is Idempotent

```text
Duplicate payment callbacks, duplicate confirms, or retry events must not create duplicate KDS releases.
```

### INV-006 — Ledger Evidence Is Required

```text
Every handoff transition must write an auditable event with before_state, after_state, actor, surface, timestamp, and correlation_id.
```

## 6. Allowed Implementation Slice

Codex may implement only one explicitly approved slice at a time.

Recommended first slice:

```text
Customer App: waiting preorder payment handoff screen state
Server/API: read-only projection and payment-confirmed KDS release guard
Tests: handoff normal path + payment failure + duplicate payment idempotency
```

Do not implement all apps at once.

## 7. Screen Scope Options

Choose one scope before implementation.

### Scope A — Customer App Only

Allowed screens/components:

```text
QR/bootstrap entry surface
waiting registration screen
waiting status screen
preorder cart screen
payment prompt after seating
payment result screen
```

Allowed behavior:

- Show waiting number.
- Show estimated queue position/time.
- Show preorder status.
- Show payment-required state after seating.
- Show payment success/failure result.
- Reflect KDS release status read-only after payment.

Forbidden behavior:

- Directly mutate KDS status.
- Trust client-side payment success as final approval.
- Edit staff call state.
- Edit seating assignment.

### Scope B — Staff App Only

Allowed screens/components:

```text
waiting list screen
call waiting customer action
arrival confirmation action
seat/table assignment action
handoff exception screen
```

Allowed behavior:

- Move `WAITING → ARRIVAL_PENDING`.
- Move `ARRIVAL_PENDING → SEATED`.
- Assign table.
- Mark no-show/call expired if policy exists.
- Show preorder/payment/KDS status read-only.

Forbidden behavior:

- Release KDS manually.
- Override payment approval.
- Start kitchen work from staff app.

### Scope C — KDS Only

Allowed screens/components:

```text
KDS ticket list
HOLD ticket display
COMMITTED actionable ticket display
COOKING/READY/SERVED transition controls
```

Allowed behavior:

- Display HOLD ticket in disabled/blocked state.
- Display COMMITTED ticket in actionable state.
- Allow cooking transitions only after COMMITTED.
- Show blocked reason for HOLD.

Forbidden behavior:

- Start HOLD ticket.
- Manually force COMMITTED.
- Hide HOLD tickets if policy requires preorder visibility.

### Scope D — Server Runtime Guard Only

Allowed surfaces:

```text
payment confirmation handler
KDS release function/RPC
state transition guard
ledger event writer
idempotency key handling
tests
```

Allowed behavior:

- Confirm payment server-side.
- Release KDS after payment approval.
- Reject unauthorized or invalid release attempts.
- Write audit events.
- Prevent duplicate release.

Forbidden behavior:

- Modify unrelated POS settlement logic.
- Modify external payment provider abstraction beyond approved confirmation hook.
- Modify menu pricing logic unless amount-mismatch test requires a read-only check.

## 8. Recommended First Codex Assignment

Use Scope D first.

Reason:

```text
The legal/business core is not the UI.
The core is the server-side invariant: HOLD cannot become COMMITTED without approved payment.
```

After Scope D passes tests, implement Scope C, then Scope A/B projections.

Recommended order:

```text
1. Server Runtime Guard
2. KDS HOLD/COMMITTED UI behavior
3. Customer payment handoff projection
4. Staff waiting/seating projection
5. DID projection
```

## 9. Required Codex Input Before Work

Codex must receive all of the following before editing code:

```text
approved scope option: A / B / C / D
allowed files list
forbidden files list
related database tables
related RPC/functions
related realtime channels
test files to create/update
verification command
rollback instruction
```

If any item is missing, Codex must not modify code.

## 10. File Boundary Template

Fill this section before giving the task to Codex.

```text
Allowed files:
- TBD

Allowed test files:
- TBD

Allowed SQL/migration files:
- TBD

Read-only reference files:
- TBD

Forbidden files/directories:
- payment provider settlement core
- POS reconciliation core
- production menu pricing policy
- unrelated admin dashboard files
- unrelated KDS queue optimization files
- unrelated customer identity/account files
```

## 11. Database Objects Under Review

Expected objects may include:

```text
order_sessions
orders
kds_tickets
payment_ledger
catchmenu_ledger.events
operation_metrics
```

Expected functions/RPC names may include:

```text
qr_scan_action()
bootstrap_customer_app_v2()
register_waiting()
pre_order_while_waiting()
call_waiting_customer()
seat_waiting_customer()
confirm_payment()
release_kds_after_payment()
transition_kds_ticket()
```

Names may differ in the actual codebase. Codex must map actual names before editing.

## 12. Event Contract

Each transition must write or preserve an event equivalent to:

```text
event_type
store_id
session_id
order_id nullable
kds_ticket_id nullable
actor_type
actor_id nullable
device_surface
before_state
after_state
result
failure_reason nullable
idempotency_key nullable
correlation_id
created_at
```

Required event sequence for the normal path:

```text
CUSTOMER_QR_SCANNED
CUSTOMER_APP_BOOTSTRAPPED
WAITING_REGISTERED
PREORDER_CREATED
KDS_HOLD_CREATED
WAITING_CUSTOMER_CALLED
CUSTOMER_SEATED
PAYMENT_APPROVED
KDS_RELEASED_AFTER_PAYMENT
KDS_COOKING_STARTED
KDS_READY
KDS_SERVED
ORDER_COMPLETED
```

## 13. Failure Contract

### 13.1 Payment Failure

```text
payment failed → KDS remains HOLD → event logged → customer shown retry/correction path
```

### 13.2 Duplicate Payment Confirmation

```text
duplicate confirm/webhook → no duplicate release → duplicate recorded as idempotent event
```

### 13.3 No-Show

```text
ARRIVAL_PENDING → NO_SHOW or CALL_EXPIRED → KDS remains HOLD → preorder not cooked
```

### 13.4 Sold-Out Before Payment

```text
sold-out detected before payment → payment blocked or cart recalculated → KDS remains HOLD
```

### 13.5 Unauthorized KDS Release Attempt

```text
release attempt without approved payment → rejected → blocked event logged
```

## 14. Acceptance Criteria

Implementation is accepted only if:

- Waiting registration creates a session without requiring immediate order creation.
- Preorder while waiting creates order and KDS HOLD ticket.
- KDS HOLD is visible but non-actionable.
- Staff call does not release KDS.
- Seating does not release KDS.
- Approved server-side payment releases KDS to COMMITTED.
- Duplicate payment events do not duplicate release.
- Payment failure keeps KDS in HOLD.
- Kitchen can transition only COMMITTED tickets.
- Ledger has a complete handoff evidence chain.
- Tests prove both normal path and failure paths.

## 15. Verification Commands

Fill with actual project commands before Codex runs implementation.

```bash
# Example placeholders only. Replace with project-specific commands.
flutter test
supabase test db
npm test
pnpm test
```

Codex must record the actual commands executed and the result.

## 16. Rollback Rule

If any of the following occurs, rollback is required:

- KDS can be released without approved payment.
- Payment failure releases KDS.
- Duplicate payment creates duplicate release.
- Existing normal seated order flow breaks.
- Existing KDS cooking flow breaks.
- Ledger events are missing for state transitions.
- RLS/security tests fail.
- The diff touches files outside the approved file boundary.

## 17. Human Approval Gate

Before Codex edits code, a human must approve:

```text
selected scope: A / B / C / D
allowed files
forbidden files
test plan
rollback rule
verification command
```

This document is a change boundary. It is not automatic authorization to implement runtime code.
