# 604267_Module_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Complete
Lifecycle: Module
Gate Classification: Implementation Module
Runtime Implementation Authorization: Already Executed Within Approved Boundary
Owner: Codex
Last Updated: 2026-07-02

## 0. Purpose

Record the controlled 604260 implementation performed under `604266_Approval_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md`.

## 1. Migration Number

`0142` was selected after inspecting `sql/migrations/` immediately before implementation. `0141_hyper_personalization_menu_customization.sql` was the highest numbered migration present, so `0142` was the next available prefix.

## 2. Created Migration

- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`

## 3. Functions Patched

- Preserved the existing `initiate_toss_payment` implementation as `initiate_toss_payment_legacy_604260` and installed a same-signature wrapper.
- Preserved the existing `confirm_toss_payment` implementation as `confirm_toss_payment_legacy_604260` and installed a same-signature wrapper.
- Added `bind_toss_payment_intent()` as a trigger helper.
- Existing `process_toss_webhook` remains unchanged and continues to call the public `confirm_toss_payment`, so webhook DONE and direct confirm converge through the same wrapper.

## 4. Tables, Columns, And Constraints

- Added nullable `catchmenu_integrations.toss_payment_requests.payment_intent_id uuid`.
- Added FK `fk_toss_payment_requests_payment_intent` to `catchmenu_payment.payment_intents(id)`.
- Added partial index `idx_toss_requests_payment_intent`.
- Added a BEFORE INSERT trigger so every new Toss request must bind an intent.

## 5. PaymentIntent Creation And Binding

The trigger serializes Toss binding per tenant/store/order with an advisory transaction lock. It reuses exactly one compatible active intent or calls the existing `catchmenu_payment.create_payment_intent` RPC when none exists. Zero/invalid/conflicting bindings fail closed.

## 6. payment_intent_id Behavior

Historical rows remain compatible because the FK column is nullable. New Toss request inserts populate `payment_intent_id`; an invalid explicitly supplied binding is rejected.

## 7. Idempotency Coordination

Toss request and payment-intent keys remain linked but namespaced. The intent key uses `TOSS-INTENT:<toss-request-idempotency-key>` and is not identical to the Toss request key.

## 8. Retry Behavior

The trigger reuses one compatible active intent for the order payment attempt and rejects multiple active matches. Terminal `FAILED`, `CANCELLED`, and `EXPIRED` intents are excluded, allowing the existing creation RPC to create a later attempt.

## 9. session_id Null Handling

`DINE_IN`, `KIOSK`, and `STAFF_ORDER` require `session_id`; initiation fails closed when it is missing. `TAKEOUT` and `DELIVERY` preserve the schema's legitimate nullable-session behavior. No fallback session is created.

## 10. confirm_toss_payment Binding

The wrapper loads and validates `payment_intent_id` before invoking the preserved confirmation function. It returns `payment_intent_binding_required` or `payment_intent_binding_invalid` without proceeding when the binding is unusable, and exposes the bound ID in successful response data.

The wrapper does not pass `p_intent_id` into `confirm_payment`; that interface belongs to 604250 and remains unimplemented.

## 11. Webhook DONE Path

`process_toss_webhook` was intentionally not modified. Its existing DONE branch calls the public `confirm_toss_payment`, which now resolves to the 604260 wrapper. Direct and webhook confirmation therefore share the same binding guard.

## 12. Files Intentionally Not Modified

- `sql/migrations/0014_create_payment_ledger.sql`
- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0052_create_kiosk_session_rpc.sql`
- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`
- All 604250 implementation documents and runtime files
- All 604310 documents and runtime files

## 13. 604250 Not Resumed

604250 implementation was not resumed. Completion of 604260 does not automatically reauthorize 604250.

## 14. 604310 Not Implemented

No 604310 idempotency, same-success replay, request fingerprint, effective idempotency key, or amount-mismatch implementation was performed.

## 15. 604316 Not Created

`604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md` was not created.

## 16. Verification Commands Run

- `git diff --check` for migrations and this Module
- migration-number inspection
- static searches for function signatures, schema names, historical-file changes, webhook convergence, and forbidden artifacts

SQL compile verification, sequential migration apply, and runtime dry-run were not run because no connected PostgreSQL verification environment was available in this workspace.

## 17. Known Limitations

- Existing historical Toss requests may have null `payment_intent_id`; they fail closed on confirmation until separately reconciled.
- The preserved legacy confirmation path still calls the current 0098 `confirm_payment` interface. Passing `p_intent_id` is deferred to 604250 after explicit reauthorization.
- Runtime database behavior remains subject to 604268 Verification and independent 604269 Audit.

## 18. Rollback Notes

Do not edit historical migrations. If rollback is required, add a separately approved corrective migration that restores the original public function names, removes the wrappers/trigger, and handles the FK column only after confirming no dependent rows or callers require it.

## 19. Next Required Verification

1. Run PostgreSQL parse/compile verification for migration 0142.
2. Apply migrations sequentially through 0142 in a disposable database.
3. Verify new initiate creates or reuses exactly one active intent and stores the FK.
4. Verify direct confirm and webhook DONE both reject missing/invalid bindings.
5. Verify 604250 remains blocked pending 604268, 604269, closure, and explicit Human reauthorization.

## 20. Final Rule

This Module is an implementation self-report.
It does not replace Verification or Audit.
