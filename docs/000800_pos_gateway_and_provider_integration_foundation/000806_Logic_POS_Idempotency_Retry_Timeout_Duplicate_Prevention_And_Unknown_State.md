# 000806_Logic_POS_Idempotency_Retry_Timeout_Duplicate_Prevention_And_Unknown_State.md

## 1. Purpose

Idempotency, retry, timeout, duplicate prevention, and unknown state logic for POS Gateway.

## 2. Idempotency Key Rule

- Every mutating operation carries `idempotencyKey` scoped to `storeId` + operation + business intent.
- Same key + same payload → same result (no duplicate side effect).
- Key retention minimum: 24–72 hours per operation class (configure in implementation phase).

## 3. Duplicate Prevention

| Target | Rule |
| --- | --- |
| Duplicate order | Same idempotency on createOrder |
| Duplicate payment | Same idempotency on authorizePayment |
| Duplicate cancel/refund | Verify state before retry |

## 4. Retry

| Parameter | Guidance |
| --- | --- |
| Retry count | Max 3 for idempotent reads; max 1–2 for mutating with same key |
| Retry window | Exponential backoff; provider rate limit aware |
| Safe retry | Same idempotency key, confirmed idempotent operation |
| Unsafe retry | New key on uncertain prior attempt without reconciliation |

## 5. Timeout Classification

| Class | Action |
| --- | --- |
| Read timeout | Retry poll |
| Mutating timeout | → `unknownState`, recovery workflow |
| Sync timeout | Partial result + reconciliation |

## 6. Unknown Response Handling

- Never map unknown to success.
- Transition to `unknown` or `recovery_required`.
- Block customer finality until resolved.

## 7. Delayed Provider Response

- Poll `getOrderStatus` / `getPaymentStatus`.
- If still unknown → manual review trigger.

## 8. Network / Provider Unavailable

- healthCheck failure → degraded mode per `000807`.
- Queue or manual path; no blind retry storm.

## 9. Manual Review Trigger

Manual review when:

- timeout on payment or refund
- conflicting order/payment state
- duplicate suspected
- reconciliation mismatch

## 10. Evidence Before Manual Recovery

Manual recovery requires logged evidence packet (`000808`) before state change.

## 11. Final Rule

When uncertain, stop, evidence, reconcile—never assume success.
