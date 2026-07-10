# 000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md

## 1. Purpose

This document defines the idempotency, retry, timeout, duplicate prevention, and unknown-state logic for POS Gateway and provider adapter integration.

The purpose is to prevent duplicate orders, duplicate payments, duplicate refunds, unsafe retries, silent timeout failures, and incorrect success interpretation.

This document is a logic foundation document.

It is not implementation code.

## 2. Upstream Dependencies

This document depends on:

```text
000801_Boundary_POS_Gateway_Order_Payment_Provider_And_Runtime_Authority.md
000802_Spec_POS_Gateway_Core_Interface_And_Provider_Adapter_Contract.md
000803_Logic_POS_Order_Payment_Cancel_Refund_And_Status_State_Machine.md
000804_Matrix_POS_Provider_Capability_Readiness_And_Support_Status.md
000805_Policy_POS_Official_API_No_Scraping_And_Provider_Boundary.md
```

The authority boundary, adapter contract, state machine, provider capability matrix, and official API policy remain upstream standards.

This file must not redefine those standards differently.

## 3. Core Rule

```text
Retry is not automatically safe.
Timeout is not automatically failure.
Unknown is not automatically success.
Duplicate prevention is mandatory for every state-changing POS or payment operation.
```

Financial and operational actions must be protected by idempotency, evidence, reconciliation, and manual review when needed.

## 4. Scope

This document covers:

* idempotency key rule
* duplicate order prevention
* duplicate payment prevention
* duplicate cancellation prevention
* duplicate refund prevention
* retry eligibility
* safe retry
* unsafe retry
* timeout classification
* unknown response handling
* delayed provider response handling
* network interruption handling
* provider unavailable handling
* manual review trigger
* evidence requirement before recovery
* provider limitation handling

## 5. Non-Scope

This document does not define:

* actual adapter source code
* SQL implementation
* Supabase schema
* Flutter UI behavior
* provider-specific API payloads
* production credential handling
* legal refund policy
* final customer support wording
* production deployment authorization

Those belong to separate implementation, security, legal, support, or release documents.

## 6. Idempotency Principle

Idempotency means that the same logical operation can be submitted more than once without creating duplicate financial or operational effects.

State-changing operations must be idempotent wherever possible.

State-changing operations include:

* create order
* update order
* cancel order
* authorize payment
* cancel payment
* refund payment
* write-side menu sync
* write-side availability sync
* recovery action that changes provider or internal state

Read-only operations may not require idempotency, but still require correlation and evidence.

## 7. Idempotency Key Rule

Every state-changing operation must include an idempotency key.

The idempotency key must be stable for the same logical operation.

The idempotency key must not be regenerated merely because a network retry occurs.

Recommended key components:

```text
tenant_id
store_id
operation_type
order_id
payment_id where applicable
refund_id where applicable
provider_id
logical_attempt_id
```

The idempotency key must be recorded in evidence.

The idempotency key must be passed to the provider when the provider supports native idempotency.

If the provider does not support native idempotency, the POS Gateway must still use the key internally for duplicate prevention.

## 8. Idempotency Key Prohibitions

The following are prohibited:

* generating a new idempotency key for the same logical retry
* using timestamp-only idempotency keys
* using random keys without linking to the logical operation
* omitting idempotency for payment authorization
* omitting idempotency for refund
* omitting idempotency for cancellation
* reusing the same idempotency key across unrelated orders
* reusing the same idempotency key across unrelated tenants
* allowing provider adapter to override the gateway idempotency key
* hiding provider lack of idempotency support

## 9. Duplicate Prevention Scope

Duplicate prevention must cover:

* duplicate order request
* duplicate POS order creation
* duplicate payment authorization
* duplicate payment cancellation
* duplicate refund
* duplicate order cancellation
* duplicate KDS display event
* duplicate DID callout
* duplicate menu sync mutation
* duplicate sold-out update
* duplicate recovery action

Duplicate prevention must be enforced before the provider operation is attempted when possible.

Duplicate detection after provider response must still trigger evidence and reconciliation.

## 10. Duplicate Order Prevention

Duplicate order prevention must consider:

* same tenant
* same store
* same customer request
* same basket or line item fingerprint
* same order request ID
* same order ID
* same provider adapter
* same idempotency key
* same payment reference where applicable
* same time window
* same POS provider response where available

If duplicate risk exists before POS submission, the system must not create another POS order automatically.

If duplicate risk is discovered after POS submission, the system must enter reconciliation or manual review depending on evidence.

## 11. Duplicate Payment Prevention

Duplicate payment prevention is mandatory.

Payment authorization must never be retried blindly after timeout.

Duplicate payment prevention must consider:

* payment ID
* payment transaction ID
* idempotency key
* payment provider reference
* POS provider transaction reference where applicable
* amount
* currency
* order ID
* customer or masked customer reference
* time window
* provider status query result

If payment result is unknown, the runtime must query status or reconcile before retrying.

If provider status cannot be determined, the state must become:

```text
payment_unknown
```

and then:

```text
reconciliation_required
```

or:

```text
manual_review_required
```

depending on risk.

## 12. Duplicate Refund Prevention

Refund retry is high-risk.

Refund operations must be idempotent and evidence-backed.

Duplicate refund prevention must consider:

* original payment ID
* original payment transaction ID
* refund request ID
* refund amount
* refund reason
* idempotency key
* provider refund transaction ID
* prior refund status
* partial refund history
* manual approval reference

If refund state is unknown, the runtime must not issue another refund request unless provider status verification or human approval makes it safe.

## 13. Duplicate Cancellation Prevention

Cancellation retry can create state conflict.

Cancellation duplicate prevention must consider:

* order ID
* POS order ID
* cancellation request ID
* idempotency key
* cancellation reason
* current order state
* payment state
* kitchen state
* provider cancellation status

If cancellation state is unknown, the runtime must not mark cancellation as confirmed without evidence.

Cancellation unknown must trigger reconciliation or manual review.

## 14. Retry Classification

Retry decisions must be classified into one of the following categories.

| Retry Category            | Meaning                                                       |
| ------------------------- | ------------------------------------------------------------- |
| `safe_retry`              | Retry may be performed automatically under policy             |
| `conditional_retry`       | Retry requires status check, provider capability, or evidence |
| `unsafe_retry`            | Retry must not be performed automatically                     |
| `manual_review_required`  | Human review is required before retry                         |
| `reconciliation_required` | Reconciliation is required before retry                       |
| `blocked`                 | Retry is prohibited                                           |

The retry category must be recorded in evidence.

## 15. Safe Retry Conditions

Retry may be considered safe when:

* the operation is read-only
* provider supports native idempotency
* gateway idempotency key is stable
* duplicate detection is available
* prior provider response confirms no mutation occurred
* provider status query confirms request was not processed
* operation is explicitly designed to be repeatable
* retry does not create duplicate financial or operational effect

Examples of generally safer retry candidates:

* healthCheck
* getOrderStatus
* getPaymentStatus
* read-only reconciliation
* read-only menu fetch
* read-only provider capability check

Even safe retries must respect rate limit and evidence rules.

## 16. Conditional Retry Conditions

Retry is conditional when:

* provider idempotency support is unknown
* provider response was delayed
* provider supports polling but not webhook
* status query is needed before retry
* previous attempt may have reached provider
* local network failed after request submission
* provider returned partial response
* provider capability differs by contract or store
* retry could create duplicate operational effect if provider processed the first request

Conditional retry must perform status check or reconciliation first.

## 17. Unsafe Retry Conditions

Retry is unsafe when:

* payment authorization result is unknown
* refund result is unknown
* payment cancellation result is unknown
* POS order creation result is unknown after request submission
* provider does not support idempotency
* provider cannot report transaction status
* duplicate order risk exists
* duplicate payment risk exists
* duplicate refund risk exists
* cancellation affects an already-preparing order
* recovery may create another POS order
* provider response is ambiguous and no status query exists

Unsafe retry must not proceed automatically.

Unsafe retry must transition to:

```text
manual_review_required
```

or:

```text
reconciliation_required
```

## 18. Timeout Classification

Timeouts must be classified according to when they happened.

| Timeout Type                  | Meaning                                     | Default Handling                |
| ----------------------------- | ------------------------------------------- | ------------------------------- |
| `pre_submit_timeout`          | Request did not leave gateway or adapter    | Retry may be safe               |
| `submit_unknown_timeout`      | Request may have reached provider           | Treat as unknown                |
| `post_submit_timeout`         | Request was sent but response not received  | Treat as unknown                |
| `provider_processing_timeout` | Provider accepted or may be processing      | Pending or unknown              |
| `callback_timeout`            | Expected webhook or callback did not arrive | Poll or reconcile               |
| `status_query_timeout`        | Status query timed out                      | Preserve unknown                |
| `recovery_timeout`            | Recovery action timed out                   | Manual review or reconciliation |
| `refund_timeout`                | Refund request timed out                    | High-risk unknown               |
| `payment_timeout`             | Payment request timed out                   | High-risk unknown               |

Timeout classification must be recorded in evidence.

## 19. Timeout Is Not Failure

A timeout must not automatically become failure.

A timeout means the system lacks a response within the expected time window.

Depending on evidence, timeout may become:

* pending
* unknown
* provider unavailable
* recovery required
* reconciliation required
* manual review required

Timeout may become failed only when provider evidence or internal evidence proves failure.

## 20. Unknown State Handling

Unknown state means the runtime lacks enough evidence to determine final result.

Unknown must be preserved when:

* provider timeout occurs after submission
* network interruption happens after request dispatch
* provider response is ambiguous
* provider returns incomplete data
* provider sends conflicting callback
* status query fails
* webhook arrives late
* polling result conflicts with previous response
* provider does not expose enough evidence
* manual operation may have occurred outside system

Unknown must not be hidden as success.

Unknown must not be hidden as failure.

Unknown must trigger evidence preservation and decision routing.

## 21. Unknown State Routing

Unknown state must route to one of the following:

```text
reconciliation_required
manual_review_required
recovery_required
pending
blocked
```

Routing depends on:

* money risk
* duplicate risk
* kitchen operation risk
* customer-facing promise risk
* provider capability
* status query availability
* evidence completeness
* human approval requirement

High-risk unknown states must require human review.

## 22. Delayed Provider Response Handling

A provider response may arrive after timeout.

Delayed response must be reconciled against current internal state.

Possible cases:

* delayed success after internal unknown
* delayed failure after internal unknown
* delayed success after manual recovery
* delayed duplicate response after retry
* delayed webhook after polling result
* delayed provider status after customer-facing update

Delayed response must not overwrite newer internal state without reconciliation.

Delayed response must create evidence and may trigger manual review.

## 23. Network Interruption Handling

Network interruption must be classified by stage.

Possible stages:

* before request left gateway
* after request left gateway but before provider received it
* after provider received request but before response returned
* after provider processed request but before callback returned
* during status query
* during recovery

If the stage cannot be proven, the result must be treated as unknown.

Network interruption after state-changing request submission must not trigger blind retry.

## 24. Provider Unavailable Handling

Provider unavailable must be separated from operation failure.

Provider unavailable may mean:

* provider API outage
* provider local connector unavailable
* provider authentication failure
* provider rate limit
* store network failure
* provider maintenance
* adapter failure
* provider dependency failure

Provider unavailable must trigger:

* evidence capture
* retry eligibility decision
* degraded mode evaluation
* manual operation path where applicable
* customer-facing caution where applicable
* provider support escalation where applicable

## 25. Rate Limit Handling

Provider rate limit must not be bypassed.

When rate limit is reached:

* stop automatic aggressive retry
* preserve evidence
* respect provider retry-after rules where available
* enter pending, degraded mode, or manual review as needed
* prevent retry storm
* protect provider relationship
* protect store operation

Rate limit must be reflected in provider capability matrix when known.

## 26. Retry Window Rule

Retry must be limited by a controlled retry window.

Retry window must consider:

* provider SLA
* provider timeout behavior
* payment risk
* duplicate risk
* kitchen operation risk
* customer wait time
* store operation mode
* rate limit
* retry count
* provider status query availability

Retry window must not continue indefinitely.

Exhausted retry window must transition to reconciliation or manual review.

## 27. Retry Count Rule

Every retry must increment retry count.

Retry count must be recorded in evidence.

Retry count must be separated by operation type.

Examples:

* order create retry count
* payment authorization retry count
* cancellation retry count
* refund retry count
* KDS display retry count
* DID callout retry count
* recovery retry count

Retry count must not be reset by adapter restart or worker retry.

## 28. Retry Storm Prevention

The system must prevent retry storms.

Retry storm risks include:

* provider outage
* network outage
* local connector outage
* payment provider slowdown
* KDS unavailable
* webhook delay
* polling loop conflict
* batch retry after recovery

Retry storm prevention may include:

* backoff
* retry cap
* circuit breaker
* provider degraded status
* manual operation switch
* queue pause
* tenant-level rate limiting
* store-level rate limiting
* operation-type rate limiting

Retry storm prevention must not erase original events.

## 29. Circuit Breaker Rule

If repeated provider failures occur, the POS Gateway may classify provider path as degraded or unavailable.

Circuit breaker triggers may include:

* repeated timeout
* repeated provider unavailable
* repeated authentication failure
* repeated rate limit
* repeated unknown result
* repeated duplicate risk
* repeated adapter contract violation

Circuit breaker action may include:

* stop automatic state-changing requests
* allow read-only status checks
* enable manual operation
* route to degraded mode
* require human approval
* notify support
* preserve evidence

Circuit breaker must be reversible only through evidence and approval.

## 30. Idempotency With Provider Limitation

If provider does not support native idempotency, the gateway must still enforce internal duplicate prevention.

The provider capability matrix must record:

```text
Idempotency Support = No
```

or:

```text
Idempotency Support = Unknown
```

The adapter must not claim safe retry if provider idempotency is unsupported and duplicate detection is insufficient.

Provider limitation may force:

* manual review
* reconciliation
* limited support status
* unsupported operation status
* manual operation path

## 31. Payment Split-Brain Handling

Payment split-brain occurs when payment state and POS/order state disagree.

Examples:

* payment authorized but POS order failed
* payment authorized but POS order unknown
* payment failed but POS order confirmed
* payment canceled but POS order active
* refund confirmed but order remains completed
* refund unknown while cancellation is confirmed

Payment split-brain must trigger reconciliation or manual review.

It must not be silently corrected by adapter logic.

## 32. POS/KDS Split-Brain Handling

POS/KDS split-brain occurs when POS and kitchen visibility disagree.

Examples:

* POS order confirmed but KDS display failed
* KDS displayed but POS status unknown
* KDS preparing but POS cancellation confirmed
* KDS ready but refund requested
* KDS completed but POS order failed

POS/KDS split-brain may require:

* kitchen manual recovery
* staff verification
* KDS resend
* manual ticket
* cancellation block
* refund review
* reconciliation

## 33. Evidence Before Recovery Rule

Recovery must not be attempted without evidence.

Required evidence before recovery:

* original operation
* idempotency key
* retry count
* timeout classification
* provider result if any
* internal state
* payment state where applicable
* POS state where applicable
* KDS/DID state where applicable
* duplicate risk assessment
* manual review requirement
* recovery reason

Recovery without original failure evidence is prohibited.

## 34. Manual Review Trigger

Manual review is required when:

* duplicate payment risk exists
* duplicate refund risk exists
* duplicate POS order risk exists
* unknown payment state exists
* unknown refund state exists
* unknown cancellation state exists
* provider state conflicts with internal state
* customer-facing finality would be affected
* kitchen operation already started
* safe retry cannot be proven
* provider limitation prevents reliable automation
* evidence is incomplete
* support compensation may be required

Manual review must create a decision record.

## 35. Customer-Facing Caution Rule

Customer-facing state must not overstate finality during retry, timeout, or unknown state.

Internal states such as:

* payment_unknown
* pos_order_unknown
* refund_unknown
* cancellation_unknown
* reconciliation_required
* manual_review_required
* recovery_required

must be translated into safe customer-facing wording according to support policy.

The customer must not be told that a refund, cancellation, or order completion is final before required evidence exists.

## 36. Anti-Patterns

The following are prohibited:

* retrying payment authorization blindly after timeout
* retrying refund blindly after timeout
* marking timeout as failed without proof
* marking unknown as success
* regenerating idempotency key for retry
* ignoring provider idempotency limitation
* creating duplicate POS order after ambiguous response
* hiding delayed provider response
* retrying aggressively during provider outage
* allowing adapter to decide duplicate payment resolution
* allowing provider timeout to erase evidence
* allowing manual recovery without evidence
* treating polling result as final when webhook conflicts without reconciliation
* treating webhook as final when payment state conflicts without reconciliation

## 37. Relationship To 000807 Runbook

This document defines logic.

The operational response must be handled by:

```text
000807_Runbook_POS_Reconciliation_Recovery_Manual_Operation_And_Degraded_Mode.md
```

The runbook must not allow operational actions that violate this retry, timeout, duplicate prevention, and unknown-state logic.

## 38. Relationship To 000808 Evidence Template

The evidence fields required here must be represented in:

```text
000808_Template_POS_Transaction_Evidence_Event_Log_And_Diagnostic_Record.md
```

Evidence must preserve:

* idempotency key
* retry count
* timeout classification
* duplicate risk
* unknown state reason
* recovery decision
* reconciliation decision
* manual review decision

## 39. Acceptance Criteria

This document is acceptable only if it confirms that:

* idempotency is mandatory for state-changing operations
* duplicate order prevention is required
* duplicate payment prevention is required
* duplicate refund prevention is required
* timeout is not automatically failure
* unknown is not automatically success
* retry eligibility is classified
* unsafe retry is blocked
* delayed provider responses are reconciled
* provider limitation is visible
* evidence is required before recovery
* manual review is required for high-risk unknown states
* no implementation is authorized by this document

## 40. Final Rule

```text
If an operation can create money movement, provider-side order state, kitchen work, customer-facing finality, cancellation, refund, or recovery side effects, it must be protected by idempotency, evidence, retry control, duplicate prevention, reconciliation, and human review when risk remains unresolved.
```
