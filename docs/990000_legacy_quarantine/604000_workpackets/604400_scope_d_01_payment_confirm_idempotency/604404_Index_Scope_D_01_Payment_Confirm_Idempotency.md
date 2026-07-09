# 604404_Index_Scope_D_01_Payment_Confirm_Idempotency.md

## Scope D Slice 01: Payment Confirm Idempotency / Amount Verification

Status:
- 604405~604409 are completed pre-implementation documents.
- 604316 Human Approval is deferred.
- Implementation is blocked until schema drift alignment verification/closure is complete.
- 604250 Schema Drift Alignment must close as a precondition.
- Runtime implementation is not authorized.
- Codex implementation is not authorized until 604316 Human Approval exists, and 604316 itself cannot be written until schema drift alignment closes.
- 604316 must be written and approved by Human.
- 604404 pre-implementation documents are complete.
- 604404 implementation is deferred.
- 604316 Human Approval is not allowed yet.
- 604250 Schema Drift Alignment must close first.

Files:
- 604405_ImpactScope_Scope_D_01_Payment_Confirm_Idempotency.md
- 604406_Overview_Scope_D_01_Payment_Confirm_Idempotency.md
- 604407_Logic_Scope_D_01_Payment_Confirm_Idempotency.md
- 604408_TestPlan_Scope_D_01_Payment_Confirm_Idempotency.md
- 604409_ChangeContract_Scope_D_01_Payment_Confirm_Idempotency.md

Policy update (2026-07-01): a design policy consolidation on `confirm_payment` integrity, idempotency, schema drift, and legacy POS ACL replaces the simple "reject `p_correlation_id` null" framing with an `effective_idempotency_key` + `request_fingerprint` model, and converts amount-mismatch handling from "log only" to a hard block (default MVP tolerance = 0 KRW). See `604406` §7, `604407` §3–§4, `604408` §1, `604409` §5 for how each document absorbs this.

Known unresolved decisions:
1. Duplicate confirm same-success payload policy — now framed as effective_idempotency_key + request_fingerprint replay (604407 §3, §3-bis).
2. Amount mismatch enforcement mechanics — hard block direction is now policy-set (604407 §4); remaining decision is implementation shape, not whether to block.
3. `p_correlation_id` null handling — now framed as trace-only; effective_idempotency_key must be resolved from stronger evidence, not a simple reject (604407 §5).
4. `idempotency_key` direct use or defer — now framed as effective_idempotency_key source-priority resolution (604407 §3-bis).
5. 0014 DDL versus 0098 INSERT schema drift — **now a required precondition (Schema Drift Alignment) before 604404 implementation, not merely a recorded decision.**
6. `confirm_payment_from_provider` relationship in 0027 — recorded as a future split-brain consolidation concern; 0027 remains excluded from 604404.
7. Migration number 0140+ recheck.
8. Owner assignment.
