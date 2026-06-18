# 004301_Policy_Toss_Payments_MVP_Integration_Boundary

## 1. Purpose

This document defines the Toss Payments MVP integration boundary policy.

The purpose of this policy is to use Toss Payments or an equivalent payment provider as the first practical payment integration path for validating the automated loop:

```text
order created
payment requested
payment verified
KDS released
customer display updated
audit preserved
```

This document does not assume that Toss Payments owns POS authority, KDS authority, refund authority, settlement authority, or store operation truth.

Toss Payments is treated as a payment provider integrated through the internal Payment Runtime.

---

## 2. Scope

This policy applies to:

* Toss Payments MVP integration
* Payment request creation
* Payment widget or payment link style flow
* Dynamic QR or customer payment display
* Payment webhook or callback handling
* Payment status verification
* Payment state normalization
* KDS release after verified payment
* Customer display payment status update
* Payment failure, timeout, duplicate, and mismatch handling
* Manual fallback when payment verification is degraded
* Audit and reconciliation linkage

This policy does not define final provider contract terms, actual fee structure, guaranteed settlement timing, refund execution authority, tax reporting, accounting settlement, or open banking account-transfer partnership.

---

## 3. Core Principle

Toss integration must prove the payment-to-kitchen automation loop.

The core principle is:

```text
Toss payment event
        ↓
Payment Runtime verification
        ↓
internal payment state
        ↓
KDS release eligibility
        ↓
customer and staff display update
        ↓
audit and reconciliation
```

Toss provider status must not bypass internal runtime authority.

Provider visibility is not internal authority.

Webhook received is not payment verified until validated by internal rules.

---

## 4. MVP Goal

The MVP goal is not to replace every POS.

The MVP goal is to prove that a customer payment event can automatically and safely trigger kitchen release without staff manually checking payment.

MVP success means:

```text
customer sees amount
customer pays through Toss or equivalent provider
system verifies payment
staff sees payment complete
KDS receives release
customer sees kitchen received
audit records the chain
```

This validates the operational loop before multi-POS expansion.

---

## 5. Toss Provider Role

Toss Payments may provide payment processing, payment status, payment callback, or payment confirmation path depending on the contracted and implemented feature set.

The internal system must classify Toss as:

```text
PAYMENT_PROVIDER
```

not as:

```text
POS_PROVIDER
KDS_PROVIDER
ORDER_AUTHORITY
REFUND_AUTHORITY
SETTLEMENT_AUTHORITY
CUSTOMER_RECOVERY_AUTHORITY
```

Toss may confirm payment provider state.

The internal Payment Runtime decides whether that provider state is sufficient to update internal payment status.

---

## 6. Internal Runtime Ownership

The internal system must preserve runtime ownership.

```text
Order Runtime owns order identity and amount.
Payment Runtime owns payment verification.
KDS Runtime owns kitchen execution.
Customer Display Runtime owns customer-facing visibility.
Audit Runtime owns append-only memory.
Reconciliation Runtime owns accepted post-incident conclusion.
```

Toss integration must not collapse these runtime responsibilities.

---

## 7. Standard MVP Flow

The standard MVP flow is:

```text
1. Order is created by internal order flow or POS/order intake.
2. Order amount is locked.
3. Payment request is created for the locked amount.
4. Customer display shows payment QR, link, or payment button.
5. Customer completes payment through Toss or equivalent provider.
6. Provider sends payment result, webhook, callback, or status response.
7. Payment Runtime verifies the event.
8. Internal payment status becomes PAYMENT_DONE.
9. KDS release becomes eligible.
10. KDS receives KITCHEN_TICKET_RELEASED.
11. Customer display shows payment complete and kitchen received.
12. Audit records every state transition.
```

Each step must be independently auditable.

---

## 8. Payment Request Creation Rule

A payment request must be created from a specific internal order.

Required internal references:

```text
internal_order_id
store_id
tenant_id
customer_session_id
order_amount
currency
payment_request_id
provider_name
payment_request_status
created_at
expires_at
```

The provider request must be traceable back to the internal order.

A generic payment link not bound to an order must not trigger automated KDS release.

---

## 9. Amount Lock Rule

Before creating a Toss payment request, the order amount must be locked.

The locked amount should include:

```text
item subtotal
discount amount
tax amount if applicable
service charge if applicable
rounding if applicable
final total amount
```

If the order changes after payment request creation, the previous payment request must become:

```text
PAYMENT_REQUEST_REPLACED
```

or:

```text
PAYMENT_REQUEST_EXPIRED
```

A new payment request must be created.

---

## 10. Customer Payment Surface

The customer payment surface may be:

```text
counter customer display
table tablet
customer mobile web
QR payment screen
payment link screen
payment widget screen
```

The customer should see:

```text
store name
order reference
final amount
payment action
payment status
retry or staff help option
```

The customer should not see:

```text
provider secret
internal payment key
raw webhook status
adapter debug data
KDS release internals
audit event ID
```

---

## 11. Webhook Or Callback Handling Rule

Provider events must be handled through a controlled receiver.

The receiver must verify:

```text
provider identity
merchant or store reference
payment request reference
order reference
amount
payment status
timestamp
duplicate event status
signature, secret, or provider verification rule if available
```

If verification cannot be completed, the event must not update internal payment authority.

The state must become:

```text
PAYMENT_SOURCE_UNCERTAIN
```

or:

```text
PAYMENT_VERIFICATION_REQUIRED
```

---

## 12. Provider Status Mapping

Provider payment statuses must be mapped into internal payment states.

Internal payment states may include:

```text
PAYMENT_PENDING
PAYMENT_AUTHORIZED
PAYMENT_DONE
PAYMENT_FAILED
PAYMENT_CANCELED
PAYMENT_EXPIRED
PAYMENT_STATUS_UNKNOWN
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_SUSPECTED
MANUAL_PAYMENT_CONFIRMATION_REQUIRED
```

Provider status labels must not be used directly by KDS or customer display.

All provider states must pass through Payment Runtime normalization.

---

## 13. KDS Release Rule

KDS release is allowed only after internal payment status becomes:

```text
PAYMENT_DONE
```

or another verified paid state explicitly allowed by store policy.

KDS release must not be triggered by:

```text
QR displayed
customer scanned
customer says paid
staff saw payment screen
webhook received but not verified
provider status unknown
payment pending
manual confirmation without fallback approval
```

If payment is uncertain, KDS must remain:

```text
WAITING_PAYMENT
PAYMENT_HOLD
PAYMENT_UNCERTAIN
```

---

## 14. Customer Display Update Rule

Customer display may show payment complete only after internal Payment Runtime verifies the payment.

Allowed customer-facing messages include:

```text
결제 확인 중입니다.
결제가 완료되었습니다.
주방에 주문이 전달되었습니다.
결제가 완료되지 않았습니다. 다시 시도해 주세요.
직원 확인이 필요합니다.
```

Customer display must not expose provider or webhook technical details.

---

## 15. Staff Display Rule

Store staff should see operationally actionable payment status.

Allowed staff-facing states include:

```text
PAYMENT_PENDING
PAYMENT_COMPLETE
PAYMENT_FAILED
PAYMENT_TIMEOUT
AMOUNT_MISMATCH
WEBHOOK_DELAYED
MANUAL_CONFIRMATION_REQUIRED
KDS_RELEASED
KDS_RELEASE_BLOCKED
```

Staff should not need to open a bank app or payment dashboard during normal operation.

The system should only ask for staff confirmation during exception or fallback.

---

## 16. Payment Failure Rule

If provider payment fails, internal state must become:

```text
PAYMENT_FAILED
```

The system must:

```text
block normal KDS release
show retry or staff help to customer
show actionable failure to staff
create audit event
preserve payment attempt reference
```

Payment failure must not be silently converted into order cancellation unless store policy defines that timeout or cancellation rule.

---

## 17. Payment Timeout Rule

Each Toss payment request must have a timeout or expiration policy.

When timeout occurs, the payment request must become:

```text
PAYMENT_EXPIRED
```

or:

```text
PAYMENT_TIMEOUT
```

The expired payment request must not be reused.

If the customer still wants to proceed, a new payment request must be created from the current locked order amount.

---

## 18. Amount Mismatch Rule

If provider-paid amount does not match internal locked amount, the state must become:

```text
PAYMENT_AMOUNT_MISMATCH
```

The system must:

```text
block normal KDS release
notify staff
create reconciliation case
preserve expected amount
preserve observed amount
preserve provider reference
```

Amount mismatch must never be shown as normal payment success.

---

## 19. Duplicate Event Rule

Provider events may be delivered more than once.

The system must use idempotency checks.

Duplicate detection should compare:

```text
provider_name
provider_event_id
payment_request_id
provider_payment_reference
internal_order_id
amount
event_type
payload_hash
```

Duplicate provider events must not create:

```text
duplicate payment record
duplicate KDS release
duplicate customer completion message
duplicate settlement candidate
```

Duplicate events should be marked and audited.

---

## 20. Manual Payment Confirmation Boundary

Manual payment confirmation is allowed only as fallback.

Manual confirmation may be used when:

```text
provider event is delayed
provider status cannot be queried
store network is degraded
customer claims payment completed
manager approves fallback
```

Manual confirmation must be marked:

```text
MANUAL_PAYMENT_CONFIRMATION_USED
FALLBACK_ORIGINATED
RECONCILIATION_REQUIRED
```

Manual confirmation must not be treated as equal to provider-verified payment until reconciliation accepts it.

---

## 21. Refund Boundary

This MVP does not define automatic refund authority.

Payment failure, duplicate payment, or amount mismatch may create:

```text
REFUND_REVIEW_REQUIRED
```

but refund execution must follow a separate refund policy.

The Toss integration must not automatically promise customer refund unless refund authority and provider flow are explicitly implemented and approved.

---

## 22. Settlement Boundary

This MVP does not define final settlement allocation.

Provider payment completion may create a settlement candidate, but settlement authority remains separate.

Internal settlement logic must preserve flags such as:

```text
PAYMENT_DONE
MANUAL_PAYMENT_CONFIRMATION_USED
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_SUSPECTED
RECONCILIATION_REQUIRED
```

Settlement must not treat uncertain or fallback-originated payment as clean verified payment.

---

## 23. Open Banking And Account Transfer Boundary

This Toss Payments MVP does not assume full open banking account-transfer automation.

If future low-fee account-based payment is added, it must be handled as a separate capability path.

Future account-transfer path may require:

```text
banking API
deposit notification
fintech partner callback
per-order virtual account
merchant contract
regulatory and legal review
settlement review
```

The MVP must not claim guaranteed zero-fee or instant-settlement account transfer unless the provider contract supports it.

---

## 24. Provider Contract Assumption Rule

The system must not assume that every Toss feature is available by default.

Each feature must be confirmed through:

```text
provider documentation
contract scope
merchant approval
test environment
credential scope
production approval
```

If a feature is not confirmed, it must be marked:

```text
REQUIRES_PROVIDER_CONFIRMATION
```

---

## 25. Required MVP Data Objects

The MVP should define or prepare the following conceptual objects:

```text
payment_provider
payment_provider_credential
payment_request
payment_event
payment_status_projection
payment_webhook_event
payment_verification_result
kds_release_request
customer_payment_display_state
payment_error
payment_reconciliation_case
audit_event
```

These are conceptual objects, not final database schemas.

---

## 26. Required MVP Event Types

The MVP should support event types such as:

```text
PAYMENT_REQUEST_CREATED
PAYMENT_QR_DISPLAYED
PAYMENT_ATTEMPT_STARTED
PAYMENT_PROVIDER_EVENT_RECEIVED
PAYMENT_PROVIDER_EVENT_VERIFIED
PAYMENT_DONE
PAYMENT_FAILED
PAYMENT_EXPIRED
PAYMENT_AMOUNT_MISMATCH
PAYMENT_DUPLICATE_EVENT_IGNORED
KDS_RELEASE_REQUESTED
KDS_RELEASED
CUSTOMER_DISPLAY_PAYMENT_COMPLETE_SHOWN
MANUAL_PAYMENT_CONFIRMATION_REQUIRED
RECONCILIATION_REQUIRED
```

All authority-sensitive events must be auditable.

---

## 27. Required MVP Error Codes

The MVP should reuse 04330 diagnostic codes.

Relevant codes may include:

```text
POSADP-PAY-001 payment status missing
POSADP-PAY-002 payment status conflict
POSADP-PAY-003 payment amount mismatch
POSADP-PAY-005 payment webhook delayed
POSADP-PAY-006 payment confirmation required
POSADP-PAY-007 duplicate payment suspected
POSADP-KDS-001 KDS release blocked by payment uncertainty
POSADP-KDS-003 kitchen release requested before payment verification
POSADP-WEBHOOK-001 webhook signature verification failed
POSADP-WEBHOOK-006 duplicate provider event ignored
POSADP-AUTH-001 payment visibility treated as payment authority
```

Provider-specific errors should be mapped into internal diagnostic language.

---

## 28. Audit Requirements

The system must create append-only audit events for:

```text
payment request created
customer payment screen shown
provider payment event received
provider payment event verified
payment status changed
payment failure detected
payment timeout detected
amount mismatch detected
duplicate provider event ignored
manual confirmation requested
manual confirmation used
KDS release requested
KDS release completed
customer display updated
reconciliation required
```

Audit must link:

```text
internal_order_id
payment_request_id
provider_name
provider_event_id
store_id
tenant_id
KDS ticket reference if available
customer session reference if available
```

---

## 29. Security Requirements

The Toss MVP integration must protect provider credentials and payment references.

Security rules:

```text
provider credentials must be scoped
webhook secrets must not be exposed
payment keys must not be shown to customers unnecessarily
raw payloads must be masked where needed
customer personal data must be minimized
test credentials and production credentials must be separated
credential rotation must be possible
```

Any signature or provider verification failure must block payment authority update.

---

## 30. Monitoring Requirements

The MVP should monitor:

```text
payment request count
payment success count
payment failure count
payment timeout count
webhook delay count
webhook verification failure count
duplicate event count
amount mismatch count
KDS release delay after payment
manual confirmation count
reconciliation required count
```

Monitoring should support support-facing diagnosis and store-facing safe messages.

---

## 31. Store-Facing Fallback

If Toss payment verification is degraded, store staff may see:

```text
결제 확인이 지연되고 있습니다.
수동 확인 전까지 주방 전달이 보류됩니다.
```

or:

```text
결제 확인이 필요합니다.
관리자 확인 후 임시 처리할 수 있습니다.
```

Fallback actions must be marked and audited.

---

## 32. MVP Success Criteria

The Toss MVP is successful when:

```text
order amount can be locked
payment request can be created
customer can complete payment
provider event can be received
provider event can be verified
internal payment status can become PAYMENT_DONE
KDS release can be triggered safely
customer display can show payment complete
staff display can show payment complete
failure, timeout, duplicate, and mismatch are handled safely
audit chain links order, payment, and KDS release
```

The MVP does not need to prove every POS integration.

It must prove the core payment-to-kitchen loop.

---

## 33. MVP Exclusions

The Toss MVP excludes:

```text
full POS replacement
full multi-POS integration
full open banking direct transfer
guaranteed zero-fee payment claim
automatic refund execution
automatic settlement allocation
full accounting integration
multi-provider payment orchestration
franchise-wide rollout
certified adapter marketplace
```

These may be later phases.

---

## 34. Relationship To Previous Documents

This document depends on:

```text
04260 POS Payment Webhook And Kitchen Release Boundary Policy
04270 Payment Failure Timeout Duplicate And Manual Confirmation Policy
04280 Customer Display Dynamic QR And Payment Status UX Policy
04290 Store Payment Device And Counter Bottleneck Reduction Policy
04300 POS Provider Abstraction And Multi-POS Adapter Policy
04310 Canonical Order Model And POS Event Normalization Policy
04330 POS Adapter Error Code And Diagnostic Message Policy
04370 POS Integration Monitoring Replay And Incident Runbook Policy
04390 POS Integration Governance Index And Readiness Check
```

The relationship is:

```text
04260 = payment to KDS boundary
04270 = failure and uncertainty handling
04280 = customer display UX
04290 = store device and bottleneck reduction
04300~04390 = multi-POS governance
04400 = first concrete payment provider MVP boundary
```

---

## 35. Patent And SaaS Relevance

This document supports the broader BM and SaaS strategy because it provides the first concrete provider path for proving:

```text
dynamic payment request
verified provider payment event
automatic KDS release
customer display synchronization
store staff workload reduction
audit and reconciliation
```

The strategic value is not Toss itself.

The strategic value is proving that any payment provider can be connected through a controlled Payment Runtime and then safely trigger kitchen operation.

---

## 36. Known Gaps To Track

The following gaps must remain visible:

```text
actual Toss contract scope
actual production feature availability
actual webhook verification method
actual fee and settlement terms
refund API availability
virtual account or transfer flow availability
store merchant approval process
legal review for account-transfer claims
pilot store device setup
provider support escalation path
```

These gaps do not block MVP policy drafting.

They block overclaiming and production launch.

---

## 37. Readiness Check

This policy is ready when:

```text
Toss is treated as payment provider only
Payment Runtime owns verification
order amount lock is required
provider event verification is required
KDS release requires internal PAYMENT_DONE
customer display does not own payment authority
staff display shows actionable states
failure and timeout are handled
amount mismatch blocks normal release
duplicate provider event is idempotent
manual confirmation is fallback-originated
refund and settlement are separate
audit is append-only
MVP exclusions are explicit
known provider gaps are visible
```

---

## 38. Summary

Toss Payments MVP is not the final product.

It is the first proof of the core automation loop.

The MVP should prove:

```text
customer pays
system verifies
kitchen receives release
customer sees confirmation
staff avoids manual checking
audit preserves truth
```

Once this loop works with Toss or an equivalent provider, the system can extend to PAYCO, additional payment providers, major POS providers, table order systems, kiosks, and legacy POS overlays through the same governance structure.
