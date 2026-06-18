# 014035_Policy_POS_InDoubt_Transaction_Network_Cancel_Receipt_Number_And_Financial_Reconciliation

## 1. Purpose

This policy defines how the POS Gateway must handle in-doubt financial transactions, network cancel failure, payment approval followed by POS submission failure, POS receipt number collision, approval number mapping, receipt sequence mismatch, and post-failure financial reconciliation.

The purpose is to prevent the worst-case financial state where customer payment is approved but the POS order does not exist, the kitchen did not receive the order, the customer sees an ambiguous result, and the store cannot reconcile the transaction.

The POS Gateway must treat in-doubt transactions as a first-class financial risk state that requires immediate containment, durable evidence, retry or reversal policy, customer communication, operator visibility, and reconciliation review.

## 2. Scope

This policy applies to:

* PG payment approval
* PG payment capture
* PG network cancel
* PG void
* PG refund
* POS order submission after payment
* POS receipt creation
* POS receipt number mapping
* VAN approval number mapping
* External order ID mapping
* Payment approved but POS submission failed
* Payment approved but POS ACK unknown
* POS accepted but PG state unknown
* Network cancel timeout
* Network cancel failure
* In-doubt transaction queue
* Nightly reconciliation
* Forced refund review
* Receipt number collision
* POS slip sequence mismatch
* Audit evidence for all financial uncertainty states

This policy applies to all flows where payment approval and POS order acceptance are not part of one atomic transaction.

## 3. Core Principle

Payment approval and POS order acceptance are separate facts unless a provider can prove atomicity.

The Gateway must not assume that a payment-approved order is also POS-accepted.

The Gateway must not assume that a failed POS submission means payment was automatically canceled.

The Gateway must preserve and reconcile every uncertain financial state until it is resolved.

## 4. In-Doubt Boundary

A payment-to-POS flow crosses multiple systems.

```
[Customer Payment Request]
            |
            v
    [Platform Payment Domain]
            |
            v
    [Payment Gateway / PG]
            |
            v
    [POS Gateway Financial Safety Layer]
            |
      -----------------------------
      |                           |
      v                           v
[External POS Provider]     [Reconciliation Engine]
```

The financial safety layer must protect the platform when the PG and POS states diverge.

## 5. Non-Negotiable Rules

### 5.1 In-Doubt Must Be Durable Rule

If payment approval, network cancel, POS submission, POS ACK, receipt creation, or refund result is uncertain, the transaction must be persisted as in-doubt.

It must not remain only in memory, logs, or transient worker state.

### 5.2 Payment Approved But POS Missing Is Critical Rule

If PG payment is approved but POS order is not confirmed, the Gateway must treat the case as a critical financial exception.

It must not mark the customer order as fully confirmed.

### 5.3 Network Cancel Failure Must Not Be Hidden Rule

If network cancel, void, or reversal attempt fails or times out, the system must preserve the failure and route the transaction to reconciliation or forced refund review.

### 5.4 No Duplicate Refund Rule

In-doubt handling must prevent duplicate void, duplicate refund, duplicate partial refund, and duplicate manual compensation.

Every reversal operation requires idempotency.

### 5.5 Receipt Number Must Be Provider-Controlled Or Explicitly Mapped Rule

The Gateway must not invent POS receipt sequence values unless the provider contract explicitly requires and safely supports it.

External payment approval numbers, PG references, VAN references, and POS receipt numbers must be mapped without corrupting provider receipt sequence.

## 6. Financial State Types

The Gateway must distinguish the following financial states.

### 6.1 Payment Intent Created

The customer intended to pay, but no approval exists yet.

### 6.2 Payment Approval Requested

The platform requested approval from PG.

### 6.3 Payment Approved

PG approved the payment.

### 6.4 Payment Approval Unknown

The payment request timed out or response was lost.

The Gateway must query PG before retrying or showing final failure.

### 6.5 POS Submission Pending

Payment may be approved, but POS submission has not completed.

### 6.6 POS Acceptance Confirmed

Provider confirmed POS order acceptance.

### 6.7 POS Acceptance Unknown

The Gateway cannot determine whether POS accepted the order.

### 6.8 Network Cancel Requested

The Gateway requested immediate cancellation or reversal of payment.

### 6.9 Network Cancel Unknown

The network cancel request timed out or returned ambiguous result.

### 6.10 Network Cancel Failed

The network cancel request failed and payment may remain approved or captured.

### 6.11 Refund Required

The transaction requires refund or manual financial review.

### 6.12 Resolved

All relevant payment, POS, receipt, refund, and customer communication states are reconciled.

## 7. In-Doubt State Classification

Allowed in-doubt states include:

```
PAYMENT_APPROVAL_UNKNOWN
PAYMENT_APPROVED_POS_SUBMISSION_PENDING
PAYMENT_APPROVED_POS_SUBMISSION_FAILED
PAYMENT_APPROVED_POS_ACK_UNKNOWN
PAYMENT_APPROVED_POS_RECEIPT_MISSING
POS_ACCEPTED_PAYMENT_STATE_UNKNOWN
NETWORK_CANCEL_REQUESTED
NETWORK_CANCEL_TIMEOUT
NETWORK_CANCEL_FAILED
REFUND_REQUIRED
REFUND_PENDING
REFUND_UNKNOWN
REFUND_FAILED
RECEIPT_NUMBER_COLLISION
APPROVAL_NUMBER_MAPPING_FAILED
MANUAL_FINANCE_REVIEW_REQUIRED
IN_DOUBT_RESOLVED
```

These states must be visible to audit and finance review.

## 8. Payment Approved But POS Submission Fails

If payment is approved but POS submission fails, the Gateway must:

* Mark order as payment-approved but POS-unaccepted
* Block kitchen success state unless kitchen already received independent signal
* Attempt safe network cancel or void according to PG policy
* Notify operator
* Notify customer using controlled message
* Preserve provider failure evidence
* Preserve PG approval evidence
* Create in-doubt record
* Schedule reconciliation if reversal is not confirmed

The order must not be marked as fully accepted unless POS acceptance is later confirmed.

## 9. POS ACK Unknown After Payment

If payment is approved and POS submission outcome is unknown, the Gateway must attempt status reconciliation before resubmission.

Reconciliation may include:

* Provider status query
* External order ID lookup
* POS receipt lookup
* Local agent job status
* Store operator confirmation
* Provider support reference, if needed

Blind resubmission may create duplicate POS orders.

## 10. Network Cancel Policy

Network cancel or immediate reversal must be attempted when:

* Payment was approved but POS submission failed
* Payment was approved but provider path is known unsafe
* Customer cancellation occurs before store acceptance
* Order cannot be fulfilled before POS acceptance
* Payment approval and order acceptance cannot be reconciled safely

Network cancel must be idempotent.

The Gateway must preserve:

```
network_cancel_request_id
payment_id
pg_transaction_id
amount
reason
requested_at
result
response_reference
retry_eligibility
idempotency_key
```

## 11. Network Cancel Failure Handling

If network cancel fails or times out, the Gateway must not assume reversal succeeded.

Allowed outcomes include:

```
QUERY_PG_STATUS
RETRY_NETWORK_CANCEL_IF_SAFE
QUEUE_REFUND
REQUIRE_FINANCE_REVIEW
REQUIRE_OPERATOR_REVIEW
NOTIFY_CUSTOMER_PENDING
MARK_IN_DOUBT_UNRESOLVED
ESCALATE_PG_SUPPORT
```

The customer-facing state must be accurate and conservative.

## 12. PG Status Reconciliation

PG status reconciliation must verify:

* Approval status
* Capture status
* Void status
* Refund status
* Partial refund status
* Settlement status
* Transaction amount
* Transaction timestamp
* Merchant reference
* Idempotency key
* Error or reversal code

The Gateway must not rely solely on the original payment response when later status queries contradict it.

## 13. POS Receipt Reconciliation

POS receipt reconciliation must verify:

* POS order reference
* POS receipt number
* POS business date
* POS amount
* POS payment method
* POS sales channel
* POS cancellation or void state
* External order ID
* External payment reference
* Store ID
* Provider ID

Receipt reconciliation must handle cases where POS accepted the order but response was lost.

## 14. Receipt Number Collision

Receipt number collision may occur when:

* POS generates internal receipt sequence
* External platform supplies receipt-like reference
* Provider maps external order ID into receipt field incorrectly
* Store VAN approval number is confused with POS receipt number
* POS rejects duplicate receipt reference
* Manual POS entry uses similar reference
* Provider reuses sequence after restart or business day close

The Gateway must classify receipt number collision as a financial and settlement integrity risk.

## 15. Receipt Number Ownership

Each provider integration must define receipt number ownership.

Allowed ownership models include:

```
POS_GENERATED_RECEIPT_NUMBER
PROVIDER_GENERATED_RECEIPT_NUMBER
PLATFORM_EXTERNAL_ORDER_ID_ONLY
PLATFORM_SUPPLIED_REFERENCE_ALLOWED
PLATFORM_SUPPLIED_RECEIPT_REQUIRED
VAN_APPROVAL_LINKED_RECEIPT
UNKNOWN_RECEIPT_MODEL
```

If receipt model is unknown, production readiness is incomplete.

## 16. Approval Number Mapping

Payment approval numbers and receipt numbers are not the same.

The Gateway must distinguish:

* PG transaction ID
* PG approval number
* VAN approval number
* POS receipt number
* POS order ID
* External order ID
* Merchant order ID
* Payment component ID
* Settlement reference

Mapping these incorrectly can break POS reconciliation and tax reporting.

## 17. External Order ID Strategy

When possible, the Gateway should send a stable external order ID to the POS provider.

The external order ID must:

* Be stable across retries
* Be unique per business order intent
* Not conflict with POS receipt sequence
* Be searchable for reconciliation
* Be linked to idempotency key
* Be preserved in audit

The external order ID should not be reused for a different customer intent.

## 18. In-Doubt Record Requirements

An in-doubt transaction record should include:

```
in_doubt_id
platform_order_id
payment_id
payment_group_id
store_id
provider_id
pg_transaction_id
pg_approval_reference
pos_order_reference
pos_receipt_reference
external_order_id
amount
payment_state
pos_state
receipt_state
reversal_state
refund_state
in_doubt_category
first_detected_at
last_checked_at
next_check_at
resolution_deadline_at
resolution_status
customer_notification_state
operator_action_required
finance_review_required
trace_id
idempotency_key
```

In-doubt records must be queryable by support, finance, and audit tools.

## 19. In-Doubt Resolution Outcomes

Allowed resolution outcomes include:

```
POS_ACCEPTED_PAYMENT_VALID
PAYMENT_VOIDED_BEFORE_CAPTURE
PAYMENT_REFUNDED
PAYMENT_NOT_APPROVED
POS_ORDER_CANCELED
POS_ORDER_MANUALLY_CONFIRMED
CUSTOMER_COMPENSATED
DUPLICATE_PAYMENT_REVERSED
DUPLICATE_POS_ORDER_CANCELED
FINANCE_MANUAL_RECONCILIATION
PROVIDER_DISPUTE_OPENED
UNRESOLVED_ESCALATED
```

Resolution outcome must include evidence.

## 20. Nightly Reconciliation Engine

The system must support scheduled reconciliation for unresolved financial uncertainty.

Nightly reconciliation should compare:

* Platform in-doubt records
* PG transaction status
* PG settlement records
* PG refund records
* POS receipt records
* POS void records
* POS business day records
* VAN records, where applicable
* Manual operator recovery records
* Customer notification records

The reconciliation engine must not silently close unresolved cases without evidence.

## 21. Reconciliation Timing

In-doubt cases may need multiple reconciliation windows.

Examples:

* Immediate status query within seconds
* Follow-up status query after minutes
* End-of-day reconciliation
* Next-day PG settlement reconciliation
* Finance review after settlement file
* Provider dispute review after support response

The system must preserve each check attempt.

## 22. Customer Notification Policy

Customer-facing messages must be conservative.

Examples:

```
Your payment is being checked.
The store could not confirm this order.
Your payment will be canceled or refunded if the order was not accepted.
A refund is being processed.
This transaction is under review.
```

The system must not say “payment canceled” unless cancellation or refund is confirmed.

The system must not say “order confirmed” unless POS acceptance or approved manual recovery exists.

## 23. Operator And Finance Console Requirements

The console must show:

* In-doubt transactions
* Payment approved but POS missing
* POS accepted but payment unknown
* Network cancel pending
* Network cancel failed
* Refund pending
* Receipt number collision
* Approval number mapping failure
* External order ID lookup result
* PG status query result
* POS receipt query result
* Customer notification state
* Resolution deadline
* Required action owner

Allowed actions may include:

```
QUERY_PG_STATUS
QUERY_POS_RECEIPT
RETRY_NETWORK_CANCEL
REQUEST_REFUND
CONFIRM_POS_ACCEPTANCE
CANCEL_POS_ORDER
MARK_MANUAL_RECOVERY
LINK_RECEIPT
LINK_APPROVAL_NUMBER
ESCALATE_PG_SUPPORT
ESCALATE_POS_PROVIDER_SUPPORT
ESCALATE_FINANCE_REVIEW
CLOSE_WITH_EVIDENCE
```

All actions must be audited.

## 24. Fraud And Abuse Considerations

In-doubt states may be exploited.

Risks include:

* Customer claims payment but no order
* Store claims no POS record
* Provider response is delayed
* Staff manually fulfills without platform evidence
* Duplicate refund attempt
* Manual compensation plus refund duplication
* Receipt reference manipulation

The Gateway must preserve evidence and require authority for manual closure.

## 25. Audit Requirements

Every in-doubt and financial reconciliation transition must preserve:

* In-doubt ID
* Platform order ID
* Payment ID
* Payment group ID
* Store ID
* Provider ID
* PG transaction ID
* PG approval reference
* POS order reference
* POS receipt reference
* VAN approval reference, if applicable
* External order ID
* Amount
* Payment state before
* Payment state after
* POS state before
* POS state after
* Reversal state
* Refund state
* In-doubt category
* Receipt mapping state
* Network cancel request reference
* Network cancel result reference
* PG status query reference
* POS status query reference
* Decision outcome
* Operator action, if any
* Finance action, if any
* Customer notification reference
* Trace ID
* Correlation ID
* Idempotency key
* Gateway version
* Adapter version
* Timestamp

Sensitive payment and customer data must be redacted, tokenized, encrypted, or access-restricted according to the security runtime policy.

## 26. Test Requirements

Each payment and POS integration must test:

* Payment approval then POS submission success
* Payment approval then POS submission failure
* Payment approval then POS ACK unknown
* Payment approval then provider timeout
* Network cancel success
* Network cancel timeout
* Network cancel failure
* PG status query after unknown approval
* POS receipt lookup after unknown POS ACK
* Duplicate POS submission avoided
* Duplicate refund avoided
* Receipt number collision
* Approval number mapping failure
* External order ID lookup
* Nightly reconciliation finds unresolved case
* Forced refund review
* Customer notification for in-doubt
* Operator manual recovery
* Finance closure with evidence
* Audit preservation for all in-doubt states

A payment-connected POS integration cannot be production-ready without in-doubt transaction and network cancel test evidence.

## 27. Anti-Patterns

The following are prohibited:

* Marking order confirmed after PG approval without POS acceptance or approved manual recovery
* Assuming POS submission failure automatically cancels payment
* Assuming network cancel succeeded after timeout
* Retrying POS submission after unknown ACK without reconciliation
* Refunding twice because first refund status was not checked
* Treating PG approval number as POS receipt number
* Inventing receipt sequence values without provider contract
* Closing in-doubt cases without evidence
* Hiding in-doubt transactions from finance review
* Telling customer payment was canceled before confirmed reversal
* Treating financial uncertainty as generic POS error

## 28. Relationship With Other Documents

This policy depends on and supports:

```
05340 POS Payment Tax Discount And Reconciliation Mismatch Policy
05370 POS Circuit Breaker Queue And Rate Limit Protection Policy
05380 POS Idempotency Duplicate Order And Manual Reentry Defense Policy
05390 POS Business Day Close Table Move And Field Operation Sync Policy
05440 POS VAN PG Tax Sales Channel And Unpaid Order Reconciliation Policy
05450 POS External API Isolation NonBlocking IO And Connection Pool Protection Policy
```

In-doubt transaction handling is the financial safety boundary between payment approval, POS execution, customer trust, and settlement evidence.

## 29. Final Rule

The POS Gateway must always be able to explain whether money was approved, canceled, refunded, captured, linked to a POS order, linked to a receipt, or still unresolved.

If customer money can leave the account while the POS order disappears, and the platform cannot durably detect, reverse, reconcile, notify, and prove the outcome, the in-doubt transaction boundary has failed.
