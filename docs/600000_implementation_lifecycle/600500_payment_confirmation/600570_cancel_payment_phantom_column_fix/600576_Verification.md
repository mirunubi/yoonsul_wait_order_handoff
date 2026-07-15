# 600576_Verification.md

Status: Complete
Lifecycle: Verification
Stage: 5 Verification Summary
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Verification Scope

This document records Stage 5 verification for the Stage 4 implementation summarized in `600575_Module.md`.

The verification scope was the full `600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md`:

- §1 pre-checks,
- §2 `cancel_payment()` execution,
- §3 KDS cancellation linkage,
- §4 `partial_cancel_payment()` execution,
- §5 `refund_payment()` execution,
- §6 seven-column regression checks,
- §7 boundary checks.

## 2. Independent Verification Summary

Two independent verification passes were performed with distinct disposable test data.

The two passes used different `order_id` values and non-overlapping correlation-id prefixes. They therefore did not reuse the same test rows or accidentally confirm only one shared fixture.

Both verification passes reached the same result:

- `cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
- `partial_cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
- `refund_payment()` no longer crashes on `payment_ledger.updated_at`.
- KDS ticket cancellation behaves exactly according to the existing `cancel_payment()` predicate.
- The seven intended `payment_ledger` columns still update correctly.
- Boundary checks showed no `0098` or unrelated-file mutation.

## 3. Source and Live Function Verification

The source diff was limited to three `payment_ledger` update blocks in `0037_create_payment_cancel_refund_rpc.sql`.

The live functions were reloaded and checked with `pg_get_functiondef()`.

Confirmed live `payment_ledger` update blocks:

```sql
-- cancel_payment()
ledger_status = 'CANCELLED',
cancelled_amount = approved_amount,
net_amount = 0,
kds_release_authorized = false,
evidence_packet_id = v_evidence_id
```

```sql
-- partial_cancel_payment()
ledger_status = case
  when v_new_net_amount = 0 then 'CANCELLED'
  else 'PARTIAL_CANCELLED'
end,
cancelled_amount = v_new_cancelled_amount,
net_amount = v_new_net_amount,
evidence_packet_id = v_evidence_id
```

```sql
-- refund_payment()
ledger_status = v_new_status,
refunded_amount = v_new_refunded_amount,
net_amount = v_new_net_amount,
evidence_packet_id = v_evidence_id
```

`updated_at = now()` remains only in updates to tables that actually have `updated_at`, such as `kds_tickets`, `orders`, and `order_sessions`. It is no longer present in the three `payment_ledger` update statements.

## 4. Apply and Checksum Verification

`catchmenu_meta.migration_history` was updated to the new LF-normalized checksum:

```text
e2e354985a20c81db02bbc8732edcf73bd18c548e8ff90977676516e11c93f78
```

`tools/apply_migrations.py` reported:

```text
OK    0037_create_payment_cancel_refund_rpc.sql  (already applied, checksum matches)
All sequence-numbered migrations applied or already up to date.
```

## 5. Function Execution Verification

### 5.1 `cancel_payment()`

Observed result:

```text
success: true
ledger_status: CANCELLED
cancelled_amount: 1000
net_amount: 0
kds_release_authorized: false
evidence_packet_id_present: true
```

### 5.2 `partial_cancel_payment()`

Observed result:

```text
success: true
ledger_status: PARTIAL_CANCELLED
cancelled_amount: 300
approved_amount: 1000
refunded_amount: 0
net_amount: 700
kds_release_authorized: true
evidence_packet_id_present: true
```

### 5.3 `refund_payment()`

Observed result:

```text
success: true
ledger_status: PARTIAL_REFUNDED
cancelled_amount: 0
approved_amount: 1000
refunded_amount: 400
net_amount: 600
kds_release_authorized: true
evidence_packet_id_present: true
```

## 6. KDS Five-State Verification

Both independent verification passes checked the five relevant KDS states:

- `HOLD`
- `COMMITTED`
- `COOKING`
- `COMPLETED`
- `SERVED`

Observed result:

| Starting `kds_status` | Result after `cancel_payment()` | Expected? |
|---|---|---|
| `HOLD` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COMMITTED` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COOKING` | `CANCELLED`, `cancelled_at` set, `hold_reason = PAYMENT_CANCELLED` | PASS |
| `COMPLETED` | unchanged, `cancelled_at` remains null | PASS |
| `SERVED` | unchanged, `cancelled_at` remains null | PASS |

The `COOKING` case is especially important because it confirms the high-risk payment-cancel-vs-cooking-start race behavior implied by the current predicate:

```sql
kds_status not in ('COMPLETED', 'SERVED', 'CANCELLED')
```

The implementation did not change this policy; it only made the already-existing behavior executable.

## 7. Seven-Column Regression Verification

The following `payment_ledger` columns were verified after execution:

- `ledger_status`
- `cancelled_amount`
- `net_amount`
- `kds_release_authorized`
- `evidence_packet_id`
- `refunded_amount`
- `approved_amount`

Result: PASS.

The values matched the pre-existing function logic once the invalid `updated_at` assignment was removed.

## 8. Boundary Verification

Boundary result:

```text
git diff --name-only -- sql/migrations
sql/migrations/0037_create_payment_cancel_refund_rpc.sql
```

`0098_create_payment_confirm_pipeline_rpc.sql` had zero diff.

No caller files were changed:

- `0038_create_toss_webhook_processor_rpc.sql`
- `0056_create_van_integration_rpc.sql`

No function signature, DROP, rename, merge, refund-pipeline redesign, or state-machine change was introduced.

## 9. Test Data Cleanup

All disposable verification rows were rolled back or explicitly confirmed absent.

Observed cleanup check:

```text
cancel_ctx_orders   0
cancel_ctx_sessions 0
cancel_ctx_kds      0
cancel_ctx_ledger   0
```

## 10. Verification Result

PASS.

The implementation satisfies the full Stage 5 verification requirements for this workpacket.

