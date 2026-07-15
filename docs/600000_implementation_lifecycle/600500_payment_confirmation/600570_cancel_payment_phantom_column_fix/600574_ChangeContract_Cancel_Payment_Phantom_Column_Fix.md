# 600574_ChangeContract_Cancel_Payment_Phantom_Column_Fix

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 1. Human Decision Summary

This ChangeContract implements the final design from:

- `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md`
- `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`

The approved design is narrow:

`cancel_payment()` / `partial_cancel_payment()` / `refund_payment()` each contain one invalid `catchmenu_payment.payment_ledger` assignment:

```sql
updated_at = now()
```

`catchmenu_payment.payment_ledger` has no `updated_at` column. Therefore the three functions crash when they reach their `payment_ledger` update.

The correction is:

- remove `updated_at = now()` from each of the three `payment_ledger` updates,
- clean up the trailing comma on the preceding line,
- leave all other logic unchanged.

## 2. Allowed Files

### 2.1 SQL migration source

Allowed:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`

Allowed scope inside that file:

1. `cancel_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

2. `partial_cancel_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

3. `refund_payment()` body only:
   - remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` update,
   - remove the trailing comma from `evidence_packet_id = v_evidence_id,`.

### 2.2 Optional forward migration

If Stage 4 follows the append-only migration convention rather than in-place source correction, the next available migration file may be created for this narrow function redefinition.

The new migration must only contain the approved correction for these three functions. It must not introduce schema changes or redesign refund/cancellation logic.

## 3. Forbidden Changes

The following are explicitly out of scope:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- `confirm_payment()`
- `request_refund()`
- `confirm_refund()`
- any `0098` refund pipeline redesign
- state transition logic changes
- amount calculation changes
- evidence packet logic changes
- audit/event insertion logic changes
- function signature changes
- function rename or function consolidation
- `refund_payment()` DROP
- `partial_cancel_payment()` DROP
- caller changes in `0038_create_toss_webhook_processor_rpc.sql`
- caller changes in `0056_create_van_integration_rpc.sql`

This workpacket fixes a phantom column reference only. It does not decide whether any of the affected functions should be deprecated or removed.

## 4. Required Implementation Contract

### 4.1 `cancel_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = 'CANCELLED',
  cancelled_amount = approved_amount,
  net_amount = 0,
  kds_release_authorized = false,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 4.2 `partial_cancel_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = case
    when v_new_net_amount = 0 then 'CANCELLED'
    else 'PARTIAL_CANCELLED'
  end,
  cancelled_amount = v_new_cancelled_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

### 4.3 `refund_payment()`

Before:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id,
  updated_at = now()
where id = p_ledger_id;
```

After:

```sql
update catchmenu_payment.payment_ledger
set
  ledger_status = v_new_status,
  refunded_amount = v_new_refunded_amount,
  net_amount = v_new_net_amount,
  evidence_packet_id = v_evidence_id
where id = p_ledger_id;
```

## 5. Verification Requirements

Stage 4/5 must execute `600573_TestPlan_Cancel_Payment_Phantom_Column_Fix.md`.

Required verification:

1. `cancel_payment()` succeeds and updates `ledger_status = 'CANCELLED'`.
2. `cancel_payment()` updates eligible `kds_tickets` to `CANCELLED`.
3. `partial_cancel_payment()` succeeds and updates the ledger according to existing logic.
4. `refund_payment()` succeeds according to its existing preconditions and logic.
5. No `payment_ledger.updated_at` reference remains in the three approved update statements.
6. The seven valid ledger columns continue to be updated as before:
   - `ledger_status`
   - `cancelled_amount`
   - `net_amount`
   - `kds_release_authorized`
   - `evidence_packet_id`
   - `refunded_amount`
   - `approved_amount`
7. `0098` and all unrelated files have zero diff.

## 6. Open Items

These are explicitly not resolved by this ChangeContract:

1. Whether `refund_payment()` should be dropped because it currently has no confirmed active callers.
2. Whether `partial_cancel_payment()` should be dropped or retained.
3. `0098` refund pipeline redesign:
   - `request_refund()`
   - `confirm_refund()`
4. The `0102` / `0104` caller bug where refund amount is always passed as `0`.
5. Any broader refund/cancellation state machine redesign.

## 7. Human Boundary Approval

Stage 4 implementation may proceed only after all three boxes are checked by the Human owner:

☑ I approve editing only the allowed 0037 function bodies or an equivalent narrow forward migration.
☑ I approve removing only the three payment_ledger.updated_at assignments and required trailing comma cleanup.
☑ I acknowledge that refund pipeline redesign, function DROP decisions, and 0098 changes are out of scope for this workpacket. (2026 - 07 -16)
