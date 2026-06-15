# 14017_Policy_POS_Idempotency_Duplicate_Order_And_Manual_Reentry_Defense

## 1. Purpose

This policy defines how the POS Gateway must prevent duplicate orders, duplicate payments, duplicate kitchen tickets, duplicate provider submissions, and duplicate manual reentry during POS-connected order flow.

The purpose is to ensure that retries, delayed provider responses, local agent reconnects, operator manual input, customer repeated actions, webhook duplication, and queue replay do not create multiple operational executions for the same customer intent.

The POS Gateway must treat idempotency and duplicate defense as a core integrity boundary, not as a convenience feature.

## 2. Scope

This policy applies to:

* Order submission idempotency
* Payment idempotency
* POS provider idempotency
* Kitchen ticket idempotency
* Queue replay idempotency
* Webhook duplication
* Local agent replay
* Customer double-click or repeated submission
* Operator manual reentry
* POS-side duplicate receipt
* Duplicate cancellation
* Duplicate refund
* Duplicate print
* Duplicate table order
* Duplicate waiting handoff order
* Audit evidence for all duplicate prevention decisions

This policy applies to all POS provider integration modes, including cloud API, local agent, printer delegation, direct print, manual-assisted, and degraded operation paths.

## 3. Core Principle

A customer’s single order intent must produce at most one accepted operational execution unless an explicit authorized correction, remake, split, or reissue flow exists.

The Gateway must distinguish:

* Same request retried safely
* Same order submitted twice
* Same payment attempted twice
* Same kitchen ticket printed twice
* Same operator manually reentered order
* Same provider webhook delivered twice
* Same local agent job replayed twice
* Legitimate additional order
* Legitimate remake
* Legitimate reprint
* Legitimate split payment

The system must not collapse these into one vague “duplicate” category.

## 4. Idempotency Boundary

Idempotency must exist across the platform, Gateway, provider adapter, local agent, payment gateway, and printer path.

```
[Customer / Operator Action]
            |
            v
    [Core Order Intent]
            |
            v
    [Gateway Idempotency Engine]
            |
   --------------------------------
   |              |               |
   v              v               v
[POS Adapter]  [Payment Gateway]  [Printer / Local Agent]
```

The Gateway idempotency engine must be the central place where duplicate-sensitive operations are classified and controlled.

## 5. Non-Negotiable Rules

### 5.1 Idempotency Key Required Rule

Every duplicate-sensitive operation must carry an idempotency key.

This includes:

* Order submission
* Payment approval
* Payment void
* Refund
* POS order submission
* Kitchen print
* Queue replay
* Webhook processing
* Local agent replay
* Manual recovery confirmation

An operation without idempotency evidence must be treated as unsafe for automatic retry.

### 5.2 Retry Does Not Mean Recreate Rule

A retry must not create a new business action.

Retrying an order submission must attempt to complete or confirm the original intent, not create a second POS order.

### 5.3 Ambiguous Outcome Requires Reconciliation Rule

If the Gateway cannot tell whether the provider processed the original request, it must attempt status reconciliation before replay.

If reconciliation is impossible, the operation must move to manual review or duplicate-risk state.

### 5.4 Manual Reentry Must Be Detectable Rule

If store staff manually enters an order in POS while the platform order is delayed, the Gateway must detect or mitigate the risk of later duplicate automatic submission.

### 5.5 Duplicate Prevention Must Be Auditable Rule

Every duplicate allow, block, replay, reprint, refund, or manual recovery decision must be preserved in immutable audit evidence.

## 6. Idempotency Key Design

An idempotency key should be stable for a single business intent.

The key should include or reference:

```
idempotency_key
tenant_id
store_id
platform_order_id
operation_type
operation_version
customer_intent_id
payment_id
provider_id
provider_operation_id
created_at
expires_at
```

The idempotency key must not depend only on client timestamp or random UI event ID.

The same business intent must resolve to the same idempotency key across retry attempts.

## 7. Operation Types Requiring Idempotency

The following operations require idempotency:

```
CREATE_ORDER
VALIDATE_ORDER
SUBMIT_ORDER_TO_POS
CANCEL_ORDER
MODIFY_ORDER
APPROVE_PAYMENT
VOID_PAYMENT
REFUND_PAYMENT
PARTIAL_REFUND_PAYMENT
ISSUE_KITCHEN_TICKET
REPRINT_KITCHEN_TICKET
SUBMIT_LOCAL_AGENT_JOB
REPLAY_QUEUE_JOB
PROCESS_PROVIDER_WEBHOOK
PROCESS_PAYMENT_WEBHOOK
MARK_MANUAL_RECOVERY
CONFIRM_STORE_ACCEPTANCE
```

Each operation type may have a different key lifespan and duplicate behavior.

## 8. Idempotency Result Classification

The Gateway must normalize idempotency results.

Allowed results include:

```
NEW_OPERATION_ALLOWED
SAME_OPERATION_REPLAYED
PREVIOUS_SUCCESS_RETURNED
PREVIOUS_FAILURE_RETURNED
IN_PROGRESS_RETURNED
DUPLICATE_BLOCKED
DUPLICATE_RISK_DETECTED
AMBIGUOUS_OUTCOME
MANUAL_REVIEW_REQUIRED
SUPERSEDED_BY_CANCEL
SUPERSEDED_BY_REFUND
EXPIRED_KEY_REJECTED
KEY_CONFLICT_DETECTED
```

These results must guide downstream behavior.

## 9. Duplicate Order Categories

Duplicate order risk must be classified.

Categories include:

```
CUSTOMER_REPEAT_SUBMIT
CLIENT_RETRY
GATEWAY_RETRY
QUEUE_REPLAY_DUPLICATE_RISK
PROVIDER_TIMEOUT_AMBIGUOUS
PROVIDER_WEBHOOK_DUPLICATE
LOCAL_AGENT_REPLAY
MANUAL_POS_REENTRY
POS_RECEIPT_DUPLICATE
TABLE_ORDER_DUPLICATE
WAITING_HANDOFF_DUPLICATE
STAFF_RECOVERY_DUPLICATE
UNKNOWN_DUPLICATE_RISK
```

Each category must map to a controlled outcome.

## 10. Customer Repeat Submission

A customer may submit the same order multiple times because of:

* Double-click
* Slow network
* Browser refresh
* App retry
* Payment screen retry
* Unclear pending state
* Customer impatience

The platform must prevent customer repeated action from creating duplicate orders or duplicate payments.

The Gateway must return the existing order state when the same idempotency key is reused.

## 11. Provider Timeout Ambiguity

Timeout after provider submission is high risk.

The provider may have:

* Not received the request
* Received and rejected the request
* Received and accepted the request
* Accepted but failed to return ACK
* Created POS receipt but failed status callback
* Sent ACK but response was lost

Before replaying, the Gateway must attempt:

* Provider status query
* Provider receipt lookup
* Provider idempotency lookup, if supported
* Local agent job status query, if applicable
* Operator review, if automated reconciliation is impossible

Blind replay is prohibited when duplicate execution risk is material.

## 12. Queue Replay Duplicate Defense

Before replaying a queued job, the Gateway must check:

* Queue job status
* Idempotency key
* Current order state
* Current payment state
* Current POS submission state
* Current kitchen print state
* Provider circuit state
* Provider status query result
* Manual recovery state
* Cancellation or refund state
* Queue expiration

Replay must be blocked if the order was already accepted, canceled, refunded, manually recovered, or superseded.

## 13. Provider Idempotency Support

Each provider capability profile must declare whether the provider supports idempotency.

Provider idempotency support may include:

* Idempotency key header
* Client request ID
* External order ID
* Merchant order ID
* Duplicate receipt prevention
* Status lookup by external ID
* Webhook event ID
* Refund request ID

If provider idempotency is weak or absent, the Gateway must compensate with stricter queue, status query, and manual review rules.

## 14. Provider External Order ID

When possible, the Gateway must submit a stable external order ID to the provider.

The external order ID should map to the platform order ID or provider-safe order reference.

The Gateway must avoid generating a new provider order identity for each retry.

If the provider does not support external order identity, duplicate risk classification must be stricter.

## 15. Payment Idempotency

Payment operations require stronger idempotency.

The Gateway must prevent:

* Duplicate payment approval
* Duplicate payment capture
* Duplicate void
* Duplicate refund
* Duplicate partial refund
* Refund after manual cash compensation without evidence
* Payment webhook double-processing

Payment idempotency must preserve:

```
payment_id
payment_attempt_id
payment_group_id
pg_transaction_id
idempotency_key
amount
operation_type
operation_status
provider_response_reference
created_at
```

Payment retry must never create a second approved payment for the same payment intent.

## 16. Kitchen Ticket Idempotency

Kitchen ticket operations require separate idempotency.

The Gateway must distinguish:

* Initial print
* Retry print
* Operator reprint
* Recovery print
* Cancel notice
* Remake notice
* Void notice

A reprint may be legitimate, but it must be labeled and audited.

The system must not blindly create duplicate initial kitchen tickets.

## 17. Webhook Idempotency

Provider and payment webhooks may be duplicated, delayed, reordered, or replayed.

Webhook processing must use:

* Webhook event ID
* Provider ID
* Event type
* Event timestamp
* Payload hash
* Related order ID
* Related payment ID
* Processing status

Duplicate webhook events must not reapply the same state transition twice.

Out-of-order events must be handled according to state transition policy.

## 18. Local Agent Replay Idempotency

Local agents may reconnect and replay jobs.

The Gateway must ensure:

* Replayed job has original job ID
* Replayed job has original idempotency key
* Job is not expired
* Order is still eligible
* Payment state still allows replay
* Manual recovery has not superseded the job
* Provider did not already accept the order
* Printer did not already receive the ticket

A local agent must not invent new job identities for old work.

## 19. Manual POS Reentry Risk

Manual POS reentry occurs when store staff manually enters an order because the automatic flow is delayed or uncertain.

This may create a duplicate if the automatic submission later succeeds.

The Gateway must mitigate manual reentry risk through:

* Clear operator pending state
* Manual recovery confirmation
* Automatic submission pause after manual recovery
* Duplicate suspicion fingerprint
* POS receipt matching, where available
* Operator warning
* Audit reason code

Manual recovery must not remain invisible to the Gateway.

## 20. Duplicate Suspicion Fingerprint

The Gateway may detect potential duplicate manual orders using a fingerprint.

A fingerprint may consider:

```
store_id
table_id
waiting_session_id
order_channel
menu_item_set
option_item_set
total_amount
order_time_window
customer_short_reference
pickup_time
operator_id
pos_receipt_time
pos_receipt_amount
```

This fingerprint is not a substitute for idempotency key, but it helps detect manual reentry risk.

Fingerprint matches must be treated as suspicion, not automatic proof, unless provider evidence is strong.

## 21. Manual Recovery States

Manual recovery must have explicit states.

Allowed states include:

```
NO_MANUAL_RECOVERY
MANUAL_ENTRY_SUSPECTED
MANUAL_ENTRY_CONFIRMED
MANUAL_ENTRY_REJECTED
MANUAL_RECOVERY_IN_PROGRESS
MANUAL_RECOVERY_COMPLETED
AUTO_SUBMISSION_PAUSED
AUTO_SUBMISSION_CANCELLED
MANUAL_RECONCILIATION_REQUIRED
```

These states must affect queue replay and provider submission decisions.

## 22. Legitimate Duplicate-Looking Cases

Some cases may look like duplicates but are legitimate.

Examples:

* Customer places a second identical order
* Group orders the same menu twice
* Table adds another round
* Kitchen remake
* Operator reprint
* Split table order
* Reopened order after cancellation
* Scheduled reorder
* Subscription or recurring order
* Same customer orders again later

The Gateway must avoid over-blocking legitimate orders.

The difference must be based on intent identity, order timing, payment state, table context, and explicit action type.

## 23. Duplicate Decision Outcomes

The Gateway may choose:

```
ALLOW_NEW_ORDER
RETURN_EXISTING_ORDER
BLOCK_DUPLICATE
HOLD_FOR_STATUS_RECONCILIATION
REQUIRE_OPERATOR_CONFIRMATION
PAUSE_AUTO_SUBMISSION
CANCEL_QUEUED_JOB
MARK_MANUAL_RECOVERY
ALLOW_REPRINT_WITH_LABEL
ALLOW_REMAKE_WITH_REASON
ESCALATE_TO_SUPPORT_REVIEW
```

The decision must be auditable and visible to operators when operationally relevant.

## 24. State Transition Protection

Idempotency must protect state transitions.

The system must prevent repeated transitions such as:

* PENDING to ACCEPTED twice
* ACCEPTED to CANCELED twice
* PAYMENT_APPROVED to PAYMENT_APPROVED twice
* REFUND_REQUESTED to REFUNDED twice
* PRINT_PENDING to INITIAL_PRINTED twice
* QUEUED to REPLAYING by multiple workers
* MANUAL_RECOVERY_COMPLETED then AUTO_SUBMITTED

Concurrent workers must use locking, version checks, or transaction-safe state transitions.

## 25. Concurrency Control

The Gateway must handle concurrent operations safely.

Concurrency controls may include:

* Unique constraints
* Idempotency table
* Advisory locks
* Optimistic version checks
* Transaction boundaries
* Queue job leasing
* Worker heartbeat
* Deduplication table
* Webhook processing lock
* Payment operation lock

The selected mechanism must match operation risk.

Payment and order submission require strong concurrency control.

## 26. Audit Requirements

Every idempotency and duplicate decision must preserve:

* Platform order ID
* Customer intent ID
* Idempotency key
* Operation type
* Store ID
* Provider ID
* Payment ID, if applicable
* Kitchen ticket ID, if applicable
* Queue job ID, if applicable
* Request hash
* Duplicate category
* Idempotency result
* Decision outcome
* Previous operation reference
* Current operation reference
* Provider status evidence
* Manual recovery state
* Operator action, if any
* Trace ID
* Gateway version
* Adapter version
* Timestamp

Sensitive values must be redacted, tokenized, or encrypted according to the security runtime policy.

## 27. Operator Console Requirements

The operator console must show:

* Duplicate-risk orders
* Manual reentry suspected orders
* Ambiguous provider timeout orders
* Queue jobs blocked by duplicate risk
* Payment duplicate risk
* Print duplicate risk
* Manual recovery state
* Allowed recovery actions
* Required confirmation level
* Audit history

Allowed operator actions may include:

```
CONFIRM_MANUAL_ENTRY
REJECT_MANUAL_ENTRY
PAUSE_AUTO_SUBMISSION
RESUME_AUTO_SUBMISSION
CANCEL_QUEUE_JOB
RECONCILE_WITH_POS_RECEIPT
MARK_DUPLICATE_BLOCKED
ALLOW_REPLAY_AFTER_CONFIRMATION
ALLOW_REPRINT_WITH_LABEL
ESCALATE_DUPLICATE_REVIEW
```

All operator actions must be audited.

## 28. Customer-Facing Messaging

Customer-facing messages must avoid technical duplication language where possible.

Examples:

```
This order is already being processed.
We are confirming your previous request.
Your payment is already in progress.
This order has already been received by the store.
Please wait while the store confirms this order.
```

Customer messages must not expose internal idempotency keys, provider status, queue details, or duplicate suspicion algorithms.

## 29. Test Requirements

Each provider integration must test:

* Customer double-submit
* Client retry
* Gateway retry
* Provider timeout with ambiguous outcome
* Provider status reconciliation before replay
* Queue replay success
* Queue replay blocked by duplicate risk
* Duplicate webhook
* Out-of-order webhook
* Local agent reconnect replay
* Manual POS reentry suspected
* Manual POS reentry confirmed
* Payment duplicate prevention
* Refund duplicate prevention
* Print duplicate prevention
* Reprint allowed with label
* Legitimate second identical order
* Concurrent worker race
* Audit preservation for all duplicate decisions

A provider cannot be production-ready without idempotency and duplicate defense test evidence.

## 30. Anti-Patterns

The following are prohibited:

* Retrying order submission with a new provider order identity
* Treating timeout as proof of failure
* Treating timeout as proof of success
* Blindly replaying queued jobs
* Processing duplicate webhooks twice
* Approving duplicate payments for one payment intent
* Refunding the same component twice
* Printing duplicate initial kitchen tickets without label
* Ignoring manual POS reentry
* Allowing manual recovery and automatic replay to both execute
* Using only menu and amount fingerprint as proof of duplicate
* Blocking legitimate repeat orders without intent analysis
* Hiding duplicate-risk state from operators

## 31. Relationship With Other Documents

This policy depends on and supports:

```
05310 POS Gateway Interface Abstraction And Adapter Boundary Policy
05330 POS Master Data Sync And Precheck Validation Policy
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05350 POS Kitchen Printer Delegation And Direct Printing Boundary Policy
05360 POS Hardware Heartbeat Local Agent And Network Disappearance Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05400 POS Schema Validation Raw Packet Audit And Spec Drift Defense Policy
```

Idempotency is the integrity bridge between retries, queues, payments, printing, local recovery, and human operation.

## 32. Final Rule

The POS Gateway must always be able to answer whether an operation is new, a safe retry, a previous success, an ambiguous outcome, a duplicate risk, or an authorized manual recovery.

If the system cannot prevent delayed retries, local replays, customer resubmissions, provider webhooks, and staff manual reentry from producing duplicate operational execution, the idempotency boundary has failed.
