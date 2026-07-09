# 604502_Implementation_Wait_Order_POS_KDS_No_Payment_Store_Level_Release_Policy.md

Status: Complete
Lifecycle: Implementation
Gate Classification: Store-Level No-Payment KDS Release Policy
Runtime Implementation Authorization: SQL/RPC Only Under Corrected 604501
Last Updated: 2026-07-05

## 1. Authority And Input

`604500_Analysis_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Blocker.md`
was accepted as the read-only input. Implementation used the corrected
`604501_Approval_Gate_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md`
authority and its final decision:

```text
APPROVED_FOR_STORE_LEVEL_NO_PAYMENT_KDS_RELEASE_POLICY_WITH_MANUAL_FALLBACK_EXCLUDED
```

The withdrawn manual-fallback-as-release direction was not used.

## 2. Implementation Result

```text
IMPLEMENTED — STORE-LEVEL NO-PAYMENT KDS RELEASE POLICY
```

The minimum implementation uses the existing tenant/store settings table and
existing staff authority model. No new settings table or runtime application
code was required.

## 3. Touched Files

```text
sql/migrations/0143_add_no_payment_kds_release_policy.sql
docs/600000_implementation_lifecycle/604000_workpackets/
  604300_scope_d_server_runtime_guard_and_pre_0142_baseline_replay_recovery/
  604502_Implementation_Wait_Order_POS_KDS_No_Payment_Store_Level_Release_Policy.md
```

Migration number 0143 was selected because it is the next unused repository
number after existing 0142 and does not collide with the pending 0136, 0139,
0141, or 0142 residue paths.

## 4. Selected Policy And RPC

Selected store policy column:

```text
catchmenu_store.store_settings.payment_required_for_kds_release boolean
default true
```

`true` preserves payment-required behavior. Only an explicit `false` value
enables the no-payment pilot RPC for that exact tenant/store.

Created RPC:

```text
catchmenu_kds.release_kds_ticket_no_payment(
  p_tenant_id uuid,
  p_store_id uuid,
  p_order_id uuid,
  p_ticket_id uuid,
  p_actor_id uuid,
  p_correlation_id text default null
) returns jsonb
```

## 5. Payment-Required Path Preservation

The existing `commit_kds_ticket`, `authorize_kds_release`,
`release_kds_after_payment`, and payment/POS adapter functions were not
modified. Their `payment_confirmed = true` behavior remains unchanged.

The new RPC is a distinct opt-in path and does not rewrite the existing
condition calculation.

## 6. No-Payment Pilot Conditions

Release is permitted only when all of the following hold:

```text
- authenticated JWT tenant_id equals p_tenant_id
- authenticated JWT store_id equals p_store_id
- authenticated actor id equals p_actor_id
- store_settings row matches tenant_id and store_id
- payment_required_for_kds_release = false
- ticket matches tenant_id, store_id, order_id, and ticket_id
- ticket is in HOLD
- actor is active staff in the same tenant/store
- actor has can_override_kds = true
- all non-payment KDS conditions remain satisfied, including current capacity
```

The single transition is:

```text
HOLD -> READY_TO_COMMIT
```

READY, COMPLETED, and later lifecycle states remain under existing RPCs.

## 7. Authority And Scope Guards

Staff/operator authority reuses `catchmenu_store.staff.can_override_kds` and
requires an active staff record. Tenant, store, order, ticket, and JWT actor
contexts are all matched before the ticket is locked or updated.

Unauthorized calls return explicit errors including:

```text
release_context_mismatch
unauthorized_release
no_payment_policy_not_active
ticket_scope_mismatch
ticket_not_holdable
```

## 8. Idempotency

A repeated call against a ticket already in `READY_TO_COMMIT` with the
`no_payment_policy_released` condition marker returns a successful
`already_released = true` response without another update, event, or audit
record.

The state-changing UPDATE also rechecks the complete scope and HOLD status.

## 9. Audit And Event Evidence

Every successful first release writes:

```text
- catchmenu_kds.kds_events
- catchmenu_ledger.events
- catchmenu_audit.append_audit_record(...)
```

Payloads distinguish this path with:

```text
release_source = STORE_NO_PAYMENT_POLICY
release_reason = NO_PAYMENT_PILOT
payment_required_for_kds_release = false
authorizing actor id
```

The existing `payment_confirmed` value is retained and recorded; it is not
forged to `true`.

## 10. Manual Fallback Exclusion

The new migration and RPC do not read, check, update, or reference:

```text
manual_fallback_activated
catchmenu_agent.activate_manual_fallback
catchmenu_agent.resolve_manual_fallback
paper-ticket fallback
```

Manual fallback remains a separate system-failure/paper-ticket mechanism.

## 11. Explicitly Deferred Work

No work was performed for POS automation, OKpos/Toss POS wiring, nominal
payment workarounds, Flutter KDS, physical device push, or full delivery
protocols.

The `COMMITTED` versus `READY_TO_COMMIT` drift was not touched because the new
RPC uses the already valid `READY_TO_COMMIT` state directly.

## 12. Existing Residue And Mainline Boundary

The 604392-604395 A1 SQL residue files were not modified:

```text
0038, 0042, 0063, 0068
```

No A2-A5 or other pending SQL residue file was modified, reset, renamed,
discarded, or staged. Tools were not modified or staged.

0069 Analysis remains deferred and uncreated. Scope D mainline remains
blocked and was not resumed.

## 13. Git Boundary

```text
SQL staging: not performed
tools staging: not performed
commit: not performed
```

## 14. Validation And Next Step

`git diff --check` was run after implementation. Runtime migration application
and database behavior tests are assigned to 604503 Verification.

```text
NEXT: 604503 Verification
```
