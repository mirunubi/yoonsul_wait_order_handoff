# 600586_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5 Verification / Stage 6 Evidence
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Verification Summary

The implementation was verified by independent Cursor and Antigravity review results, then reconciled with Codex live execution evidence.

Final result: PASS.

The original PAY-CON-003 failure mode was not reproduced after the fix. A late approval after cancellation now creates a `MANUAL_REVIEW` ledger record and leaves the order cancelled.

## 2. Human Approval Recheck

`600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` was rechecked directly from the UTF-8 file content.

The Human Approval section contains all three checked approvals:

```text
☑ I approve Rule 1 implementation in confirm_payment() only.
☑ I approve Rule 3 idempotent-success/conflict behavior for already-confirmed orders.
☑ I approve Rule 4/5 manual-review recording for late approvals after cancelled/refunded orders. (2026 - 07 - 16)
```

Earlier console output displayed these marks incorrectly because of PowerShell console encoding, not because the file was missing the checks.

## 3. Checksum Reconciliation

The apparent checksum mismatch was resolved as a hashing-method mismatch.

Observed values:

```text
raw_sha256=769fadd67664a3be7a21bfbb81efb52ebcefa5ff7dcbba2c025888bc9d312165
lf_normalized_sha256=357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
migration_history_checksum=357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
normalized_matches_history=True
raw_matches_history=False
```

`tools/apply_migrations.py` uses the LF-normalized checksum path:

```python
path.read_bytes().replace(b"\r\n", b"\n")
```

Therefore the correct §24 checksum is the LF-normalized value:

```text
357f9f568579d1de07a83f3e664b3d5fca0f272a09194e5006b77c30e97ee9b5
```

This note is intentionally recorded to prevent future confusion between raw SHA256 and migration-history SHA256.

## 4. Live Function Reload Verification

The live `confirm_payment()` function was re-executed after the source update.

`tools/apply_migrations.py` subsequently reported:

```text
OK    0098_create_payment_confirm_pipeline_rpc.sql  (already applied, checksum matches)
All sequence-numbered migrations applied or already up to date.
```

`pg_get_functiondef()` token checks confirmed that the live function contains the new branches:

```text
has_row_count_gate       15130
has_idempotent_success    2435
has_cancelled_branch     11914
has_manual_review        11236
```

## 5. Test Results

### 5.1 Rule 1 — PENDING success and non-PENDING rejection

PENDING order confirmation succeeded:

```json
{"ledger_id":"6907f2db-c827-40a6-bb84-29a2c8cde4dc","message_key":"payment_confirmed","order_status":"CONFIRMED","success":true}
```

Non-confirmable states were rejected without ledger insertion:

```text
COOKING   -> order_not_confirmable, ledger_count=0
READY     -> order_not_confirmable, ledger_count=0
SERVED    -> order_not_confirmable, ledger_count=0
COMPLETED -> order_not_confirmable, ledger_count=0
```

### 5.2 Rule 3 — idempotent success / conflict rejection

Same-provider resend on an already confirmed order returned idempotent success:

```json
{
  "same_success": true,
  "same_message_key": "payment_already_confirmed_idempotent",
  "same_data": {
    "already_confirmed": true,
    "ledger_id": "944db09a-9ad7-4fef-97ce-41ba72348888",
    "order_id": "66249984-3c5e-4f1f-9b8c-036c26535296"
  },
  "ledger_counts": [1, 1]
}
```

Different-provider resend was rejected:

```json
{"diff_success":false,"diff_error_key":"payment_already_confirmed"}
```

### 5.3 Rule 4/5 — late approval after cancellation

Late approval after `cancel_payment()` produced a manual-review record:

```text
order_status=CANCELLED
late_success=false
late_error_key=payment_already_confirmed
late ledger_status=APPROVED
late reconciliation_status=MANUAL_REVIEW
late kds_release_authorized=false
event_payload.reason=payment_approved_after_order_cancelled
```

The verified ledger pair was:

```text
CANCELLED / PENDING       for the original cancelled ledger
APPROVED  / MANUAL_REVIEW for the late provider approval
```

The order remained `CANCELLED`.

### 5.4 PAY-CON-003 replay

The original replay scenario was re-executed with fresh test data.

Final state:

```text
order_status=CANCELLED
normal cancelled ledger remains CANCELLED
late approval ledger is APPROVED + MANUAL_REVIEW
kds_release_authorized=false
kds_tickets not reopened/released
```

The old failure mode did not occur.

Specifically, the order did not return to `CONFIRMED`.

### 5.5 KDS COOKING cancellation regression

The KDS cancellation regression check passed:

```json
{"cancel_success":true,"ticket":["CANCELLED","PAYMENT_CANCELLED",true]}
```

This confirms that the previous `600570` cancellation behavior still works after the `confirm_payment()` state-machine fix.

## 6. Boundary Verification

Boundary checks passed:

- `confirm_payment()` in `0098_create_payment_confirm_pipeline_rpc.sql` changed.
- `0037_create_payment_cancel_refund_rpc.sql` had zero diff.
- `cancel_payment()` was not changed.
- `request_refund()` was not changed.
- `confirm_refund()` was not changed.
- `release_kds_after_payment()` was not changed.
- No schema file was changed.
- No Flutter/runtime file was changed.

`git diff --check` passed.

## 7. Cleanup Verification

The test cleanup pass reported:

```json
{"remaining_orders":0,"removed_orders":9}
```

No persistent test orders remained from the verification run.

## 8. Verification Result

PASS.

The implementation satisfies the approved Rule 1/3/4/5 scope and removes the observed PAY-CON-003 failure mode.
