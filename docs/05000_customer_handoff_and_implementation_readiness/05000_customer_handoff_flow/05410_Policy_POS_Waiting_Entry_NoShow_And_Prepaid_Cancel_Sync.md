# 05410_Policy_POS_Waiting_Entry_NoShow_And_Prepaid_Cancel_Sync

## 1. Purpose

This policy defines how the POS Gateway must synchronize waiting, entry, no-show, table assignment, prepaid order cancellation, kitchen cancellation, and store-side manual entry handling in waiting-to-order and waiting-to-table flows.

The purpose is to prevent mismatch between customer waiting state, platform seating state, POS table occupancy, prepaid order state, kitchen execution state, and store operator actions.

A waiting customer journey is not complete when the customer clicks a button. It must remain synchronized through entry confirmation, table assignment, POS order submission, kitchen execution, payment state, cancellation, no-show handling, and audit evidence.

## 2. Scope

This policy applies to:

* Waiting registration
* Waiting call
* Entry confirmation
* No-show
* Manual entry
* Table assignment
* Table occupancy sync
* Waiting-to-table handoff
* Waiting-to-order handoff
* Prepaid waiting order
* Waiting cancellation
* Prepaid cancellation
* POS order cancellation
* Kitchen ticket cancellation
* Store-side manual recovery
* Overbooking prevention
* Customer notification
* Operator confirmation
* Audit evidence for waiting and entry transitions

This policy applies to dine-in, waiting, preorder, table assignment, and store handoff flows where the platform and POS must agree on whether a customer has entered, been seated, ordered, paid, canceled, or no-showed.

## 3. Core Principle

Waiting state, entry state, table state, POS state, payment state, and kitchen state must not drift silently.

The POS Gateway must treat the waiting-to-entry journey as a multi-system state machine.

The platform must not assume that:

* Called customer has entered
* Entered customer was confirmed in POS
* POS table occupancy is updated automatically
* No-show was recorded correctly
* Prepaid cancellation means kitchen execution stopped
* POS cancellation means customer payment was voided
* Manual seating by staff is visible to the platform

Every transition must be explicit, correlated, and auditable.

## 4. Journey State Boundary

The waiting-to-order journey crosses multiple state domains.

```
[Customer Waiting Session]
            |
            v
[Platform Entry / Seating State]
            |
            v
[POS Gateway Journey Sync Layer]
            |
  -------------------------------
  |              |              |
  v              v              v
[POS Table]   [Payment]   [Kitchen Execution]
```

The Gateway must preserve cross-domain correlation through the full journey.

## 5. Non-Negotiable Rules

### 5.1 Entry Confirmation Must Be Explicit Rule

A waiting customer must not be treated as seated unless entry confirmation is captured through platform, POS, or operator-confirmed flow.

### 5.2 No-Show Must Not Occupy Table Rule

If a customer is marked no-show, the platform must release waiting and table resources only through controlled state transition.

The POS table state must be checked or reconciled if the provider supports table occupancy sync.

### 5.3 Prepaid Cancel Must Propagate To Kitchen Rule

If a prepaid waiting order is canceled after payment or POS submission, the Gateway must evaluate whether kitchen execution has started and must issue cancel, void, refund, or manual stop signals according to policy.

### 5.4 Table Occupancy Drift Must Be Detected Rule

If the platform believes a table is available but the POS table is occupied, the Gateway must block or review the next seating assignment.

The platform must not blindly call the next waiting team into an already occupied table.

### 5.5 Manual Entry Must Be Audited Rule

If store staff manually seats, admits, cancels, or overrides a waiting customer, the event must be classified as manual field operation and linked to the waiting session.

## 6. Waiting Session Identity

Each waiting journey must have a stable identity.

Required identity fields may include:

```
waiting_session_id
customer_session_id
store_id
party_size
waiting_number
requested_time
called_at
entry_deadline_at
entry_confirmed_at
no_show_marked_at
canceled_at
assigned_table_id
pos_table_id
linked_order_id
linked_payment_id
linked_kitchen_ticket_id
journey_correlation_id
```

The journey correlation ID must link waiting, table, order, payment, kitchen, and audit states.

## 7. Waiting Journey States

The platform must normalize waiting journey states.

Allowed states include:

```
WAITING_REGISTERED
WAITING_CALLED
WAITING_CUSTOMER_RESPONDED
ENTRY_PENDING_CONFIRMATION
ENTRY_CONFIRMED
SEATED
NO_SHOW_PENDING
NO_SHOW_CONFIRMED
WAITING_CANCELED_BY_CUSTOMER
WAITING_CANCELED_BY_STORE
WAITING_EXPIRED
MANUAL_ENTRY_CONFIRMED
MANUAL_ENTRY_CONFLICT
TABLE_ASSIGNMENT_PENDING
TABLE_ASSIGNMENT_FAILED
JOURNEY_SYNC_CONFLICT
JOURNEY_RECOVERY_REQUIRED
```

These states must be distinct from order, payment, and kitchen states.

## 8. Entry Confirmation Sources

Entry confirmation may come from:

* Customer app check-in
* Staff platform console
* POS table occupancy event
* Local agent table state event
* Manual operator confirmation
* QR or NFC table confirmation
* Store manager override
* External reservation or waiting system, if integrated

Each source must be recorded.

If multiple sources conflict, the Gateway must apply conflict policy.

## 9. No-Show Handling

No-show handling must define:

* Call time
* Response window
* Grace period
* Operator confirmation requirement
* Customer notification
* Table release rule
* Queue reorder rule
* Payment impact
* Preorder impact
* Kitchen impact
* Audit evidence

A no-show customer with a prepaid order is higher risk than a no-show customer without payment.

## 10. Manual Entry Handling

Manual entry occurs when staff admits or seats a customer without completing the platform flow.

Examples:

* Staff verbally allows the customer in
* Staff seats no-show customer anyway
* Staff assigns a different table
* Staff skips waiting order
* Staff marks entry only in POS
* Staff does not update POS table state

Manual entry must be classified.

Allowed categories include:

```
MANUAL_ENTRY_WITH_PLATFORM_CONFIRMATION
MANUAL_ENTRY_POS_ONLY
MANUAL_ENTRY_VERBAL_ONLY
MANUAL_ENTRY_AFTER_NO_SHOW
MANUAL_ENTRY_DIFFERENT_TABLE
MANUAL_ENTRY_WAITING_SKIP
UNKNOWN_MANUAL_ENTRY
```

Manual entry may trigger table sync, operator review, or waiting state correction.

## 11. Table Assignment And Occupancy Sync

Before assigning or confirming a waiting customer to a table, the Gateway should verify:

* Platform table availability
* POS table availability, if supported
* Current table occupancy
* Pending table move
* Pending table merge
* Pending payment on the table
* Waiting session party size
* Store operator override
* Table mapping validity

If table state cannot be verified, the system must either require operator confirmation or mark the assignment as degraded.

## 12. Overbooking Prevention

Overbooking may occur when:

* Platform releases a table too early
* POS table remains occupied
* Staff manually seats a team
* No-show is mishandled
* Table move was not synced
* Table merge was not synced
* Entry confirmation was missed
* Waiting queue calls next team too early

The Gateway must block or warn before calling the next waiting team when table occupancy state is uncertain.

Overbooking risk must be visible to the operator.

## 13. Prepaid Waiting Order

A waiting session may include a prepaid order.

The system must link:

* Waiting session
* Preorder cart
* Platform order ID
* Payment ID
* POS order ID
* Kitchen ticket ID
* Table assignment
* Entry state
* Cancellation state

A prepaid waiting order must not be treated like a simple unpaid waiting ticket.

## 14. Customer Cancels Waiting Before POS Submission

If the customer cancels waiting before POS submission and before kitchen execution, the system may:

* Cancel waiting session
* Release table or queue position
* Void or refund payment, if payment exists
* Cancel order intent
* Notify store operator
* Preserve audit evidence

No kitchen cancellation is required if no kitchen execution signal was sent.

## 15. Customer Cancels Waiting After POS Submission

If the customer cancels waiting after POS order submission, the Gateway must check:

* POS order acceptance state
* Kitchen print state
* Kitchen execution state
* Payment approval state
* POS cancellation support
* Provider cancellation eligibility
* Store operator confirmation requirement

Possible outcomes include:

```
CANCEL_POS_ORDER
SEND_KITCHEN_CANCEL_NOTICE
VOID_PAYMENT
REFUND_PAYMENT
REQUIRE_OPERATOR_CONFIRMATION
MARK_KITCHEN_STOP_UNCERTAIN
MANUAL_RECOVERY_REQUIRED
```

The system must not refund blindly if kitchen execution may have started without store awareness.

## 16. Customer Cancels After Kitchen Print

If the kitchen ticket has already printed or may have printed, cancellation must be handled as operational recovery.

The Gateway must:

* Send cancel notice if direct print is supported
* Request POS cancellation if provider supports it
* Notify operator
* Mark kitchen stop state
* Decide refund or partial refund according to policy
* Preserve kitchen evidence
* Preserve customer notification evidence

If kitchen stop cannot be confirmed, the order must enter manual review.

## 17. No-Show With Prepaid Order

No-show with prepaid order requires special handling.

The policy must define whether:

* The store may prepare the order anyway
* The order is held for pickup
* The order is canceled and refunded
* The order is partially refunded
* The order is marked forfeited according to terms
* Operator confirmation is required

The decision must be visible to customer terms, operator console, and audit evidence.

## 18. POS Table Occupancy Conflict

A conflict occurs when platform and POS disagree.

Examples:

* Platform says table available, POS says occupied
* Platform says customer seated, POS table empty
* Platform says no-show, POS table occupied
* Platform assigns table 3, POS uses table 5
* POS merged table after platform assignment
* POS moved table after platform order submission

The Gateway must classify and resolve conflicts through controlled outcomes.

Allowed outcomes include:

```
ACCEPT_POS_TABLE_STATE
ACCEPT_PLATFORM_TABLE_STATE
REQUIRE_OPERATOR_CONFIRMATION
BLOCK_NEXT_WAITING_CALL
UPDATE_TABLE_ASSIGNMENT
MARK_OVERBOOKING_RISK
ESCALATE_FIELD_SYNC_CONFLICT
```

## 19. Kitchen Cancel Signal

Kitchen cancellation must be distinct from payment cancellation.

A kitchen cancel signal may be:

* POS cancellation
* Direct print cancel notice
* Operator screen alert
* Local agent kitchen stop message
* Manual phone or verbal stop, recorded by operator

The system must record which cancellation path was used.

Kitchen cancel uncertainty must remain visible.

## 20. Payment Refund Interaction

Waiting cancellation may require payment action.

Possible payment outcomes include:

```
NO_PAYMENT_ACTION
VOID_BEFORE_CAPTURE
FULL_REFUND
PARTIAL_REFUND
REFUND_PENDING_OPERATOR_CONFIRMATION
REFUND_BLOCKED_KITCHEN_STARTED
REFUND_POLICY_REVIEW_REQUIRED
PAYMENT_FORFEITURE_POLICY_APPLIED
```

The decision must be linked to order, waiting, and kitchen states.

## 21. Customer Notification

Customer notification must be state-specific.

Examples:

```
Your waiting registration has been canceled.
Your table is being confirmed by the store.
The store is confirming whether your prepaid order can be canceled.
Your payment has been canceled.
A refund is being processed.
The store has already started preparing your order.
```

Customer-facing messages must not expose POS internals, printer status details, raw error codes, or internal policy names.

## 22. Operator Console Requirements

The operator console must show:

* Waiting session state
* Entry confirmation state
* Assigned table
* POS table state
* Overbooking risk
* Prepaid order state
* POS submission state
* Kitchen print state
* Cancellation state
* Refund state
* Manual entry state
* Required operator action

Allowed operator actions may include:

```
CONFIRM_ENTRY
MARK_NO_SHOW
CANCEL_WAITING
ASSIGN_TABLE
CHANGE_TABLE
CONFIRM_MANUAL_ENTRY
BLOCK_NEXT_CALL
SEND_KITCHEN_CANCEL
CONFIRM_KITCHEN_STOP
APPROVE_REFUND
REJECT_REFUND
MARK_MANUAL_RECOVERY
ESCALATE_JOURNEY_CONFLICT
```

All operator actions must be audited.

## 23. Audit Requirements

Every waiting, entry, prepaid cancellation, and journey sync transition must preserve:

* Waiting session ID
* Journey correlation ID
* Store ID
* Customer session ID, if available
* Party size
* Waiting state
* Previous waiting state
* Entry state
* Table assignment
* POS table ID
* Platform order ID, if applicable
* Payment ID, if applicable
* Kitchen ticket ID, if applicable
* POS order reference, if applicable
* Cancellation reason
* No-show reason
* Manual entry category
* Conflict category
* Decision outcome
* Customer notification reference
* Operator action, if any
* Trace ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive customer information must be minimized, redacted, tokenized, or encrypted according to the security runtime policy.

## 24. Test Requirements

Each waiting-to-POS integration must test:

* Normal waiting registration
* Waiting call
* Entry confirmation
* No-show
* Manual entry
* Manual entry after no-show
* Table assignment success
* POS table occupied conflict
* Platform table occupied conflict
* Overbooking prevention
* Prepaid waiting order
* Customer cancels before POS submission
* Customer cancels after POS submission
* Customer cancels after kitchen print
* No-show with prepaid order
* Kitchen cancel signal
* Refund after waiting cancel
* Operator manual recovery
* Audit preservation for all journey states

A waiting-to-POS integration cannot be production-ready without journey sync test evidence.

## 25. Anti-Patterns

The following are prohibited:

* Treating waiting call as confirmed entry
* Treating no-show as automatic table release without sync
* Refunding prepaid waiting order without checking POS and kitchen state
* Assuming POS table occupancy follows platform seating state automatically
* Calling next waiting team while table state is uncertain
* Hiding manual entry from the platform
* Treating kitchen cancel and payment refund as the same event
* Dropping prepaid orders without store-side cancellation evidence
* Losing correlation between waiting session, order, payment, table, and kitchen ticket
* Showing customer confirmed cancellation when kitchen stop is uncertain

## 26. Relationship With Other Documents

This policy depends on and supports:

```
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Waiting and entry synchronization is the customer journey layer above POS Gateway resilience.

## 27. Final Rule

The POS Gateway must always be able to explain whether a waiting customer was called, entered, seated, no-showed, manually admitted, prepaid, canceled, submitted to POS, printed to kitchen, refunded, or recovered by staff.

If the system cannot preserve the full waiting-to-entry-to-order journey without table drift, overbooking, unpaid kitchen execution, or refund ambiguity, the waiting journey synchronization boundary has failed.
