# 000905_Logic_POS_Order_Payment_State_Machine_Reconciliation_And_Recovery.md

## 1. Purpose

This document defines the POS order/payment state machine, reconciliation rules, and recovery logic for outsourcing alignment.

## 2. Core Principle

Payment success and order success must not be treated as the same event.

## 3. Normalized States

| State | Description |
| --- | --- |
| `request_created` | Customer or staff initiated order request |
| `store_accepted` | Store accepted order into internal flow |
| `payment_pending` | Payment not yet authorized |
| `payment_authorized` | Payment authorized; order may still fail on POS |
| `pos_order_pending` | POS submission in progress |
| `pos_order_confirmed` | POS accepted order |
| `kds_display_pending` | Kitchen ticket not yet displayed |
| `kds_displayed` | Kitchen ticket visible |
| `preparing` | Kitchen preparing |
| `ready` | Order ready for pickup/service |
| `completed` | Order fulfilled and closed |
| `cancel_requested` | Cancel initiated |
| `cancel_confirmed` | Cancel confirmed on all surfaces |
| `refund_requested` | Refund initiated |
| `refund_confirmed` | Refund confirmed with evidence |
| `failed` | Terminal failure with reason |
| `unknown` | Provider or internal state uncertain |
| `recovery_required` | Automated path stopped; recovery workflow required |
| `manual_review_required` | Human must decide before next transition |

## 4. Separate Success Events

| Event | Independent meaning |
| --- | --- |
| Order success | Internal order accepted and tracked |
| Payment success | Payment authorized or captured per policy |
| POS transmission success | Provider acknowledged order |
| KDS display success | Kitchen received ticket |
| DID callout success | Customer notified for pickup |
| Cancellation success | Cancel reflected everywhere required |
| Refund success | Refund confirmed with evidence |

## 5. Reconciliation Rule

Periodic and event-triggered reconciliation must compare:

- internal order ledger
- payment ledger
- POS provider records
- KDS/DID state where applicable

Unmatched items enter `recovery_required` or `manual_review_required`.

## 6. Duplicate Prevention

- Every create/authorize/cancel/refund uses `idempotencyKey`.
- Retry must not create second POS order or second payment.
- Reconciliation flags duplicates for human review.

## 7. Retry Rule

| Operation | Retry policy |
| --- | --- |
| Read (status poll) | Limited retry with backoff |
| createOrder / authorizePayment | Idempotent retry only with same key |
| cancel / refund | Extra caution; verify state before retry |
| syncMenu / syncAvailability | Version-aware retry |

## 8. Timeout Handling

On timeout:

1. Do not assume failure or success.
2. Transition to `unknown` or `recovery_required`.
3. Poll provider status if available.
4. Open recovery workflow per `000559`.
5. Log evidence packet.

## 9. Unknown State Handling

Unknown state **forbids** customer-facing finality claims until resolved.

Staff may use manual operation path with audit log.

## 10. Manual Recovery Path

Manual recovery allowed when:

- provider timeout
- conflicting POS/payment state
- duplicate suspected
- cancel/refund uncertain

Manual actions must be recorded and later reconciled into system of record.

## 11. Evidence Logging

Every state transition and recovery action logs:

- prior state, new state
- actor (system, staff, vendor test)
- provider references
- idempotency key
- timestamp
- evidence packet reference

## 12. Final Rule

State machine authority stays internal.
Vendor adapters report provider facts; they do not own transitions.
