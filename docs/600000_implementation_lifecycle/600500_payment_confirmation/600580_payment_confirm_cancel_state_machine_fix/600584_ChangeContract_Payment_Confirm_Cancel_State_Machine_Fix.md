# 600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix

Status: Draft
Lifecycle: ChangeContract
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 1. Human Decision Summary

This ChangeContract implements the final Revision 2 design from:

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md`
- `600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md`

The human-approved design is:

1. Rule 1: add an `order_status = 'PENDING'` conditional gate to `confirm_payment()`.
   - Use a conditional `UPDATE ... WHERE order_status = 'PENDING'`.
   - Use `GET DIAGNOSTICS ... ROW_COUNT`.
   - If zero rows are updated, reject instead of silently continuing.

2. Rule 3: keep the existing provider-payment-key idempotency check order.
   - Add a new idempotent-success branch for `order_status = 'CONFIRMED'` and the same provider transaction.
   - A different provider transaction for an already confirmed order remains a conflict.

3. Rule 4/5: when a provider approval arrives for a cancelled/refunded order:
   - record the payment fact in `payment_ledger`,
   - do not mutate `orders`,
   - do not mutate or release `kds_tickets`,
   - reuse `reconciliation_status = 'MANUAL_REVIEW'`,
   - record the concrete reason in JSON event payload rather than adding a new check value.

4. Rule 6/7 are out of scope.
   - `reopen_order()` is not implemented here.
   - UI copy for staff-facing recovery is not implemented here.

5. Rule 2 requires no implementation in this workpacket.
   - Existing payment-intent lifecycle handling remains in place.

## 2. Allowed Files

### 2.1 SQL migration source

Allowed:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

Allowed scope inside that file:

- `catchmenu_payment.confirm_payment()` body only

Allowed changes inside `confirm_payment()`:

1. Add order-state gate logic after the existing order row is loaded with `FOR UPDATE`.
2. Add a `CONFIRMED` + same-provider-transaction idempotent success branch.
3. Add rejection for `CONFIRMED` + different provider transaction.
4. Add rejection for non-confirmable active or terminal states outside the cancelled/refunded manual-review branch.
5. Add cancelled/refunded-order late-approval handling:
   - ledger record may be inserted,
   - `reconciliation_status = 'MANUAL_REVIEW'`,
   - reason is stored in JSON event payload,
   - no order or KDS release mutation.
6. Change the normal order status update to be conditional on `order_status = 'PENDING'`.
7. Add `GET DIAGNOSTICS v_row_count = ROW_COUNT` and a zero-row rejection branch.

### 2.2 Already-applied migration procedure

Because `0098_create_payment_confirm_pipeline_rpc.sql` is an already-applied migration source, Stage 4 must follow the established in-place function correction process:

1. Modify the source file.
2. Recalculate the CRLF-normalized checksum.
3. Update `catchmenu_meta.migration_history`.
4. Re-execute the live function body directly.
5. Verify with `pg_get_functiondef()` that the live function body actually changed.

Checksum update alone is not evidence that the live database function was replaced.

## 3. Forbidden Changes

The following are explicitly forbidden in this workpacket:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`
- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- `catchmenu_pos.orders` schema changes
- `catchmenu_payment.payment_ledger` schema changes
- `catchmenu_payment.payment_intents` schema changes
- new `order_status` values such as `PAYMENT_PENDING` or `PAYMENT_PROCESSING`
- new `reconciliation_status` values
- `reopen_order()` implementation
- Flutter/client UI changes
- PG/VAN automatic void/refund redesign
- provider integration caller changes
- KDS state-machine redesign

## 4. Required Implementation Contract

### 4.1 Rule 1 — PENDING-only normal confirmation

The normal successful confirmation path must only update an order if the current status is `PENDING`.

Required shape:

```sql
update catchmenu_pos.orders
set
  order_status = case order_type
    when 'TABLE' then 'COOKING'
    else 'CONFIRMED'
  end,
  confirmed_at = now(),
  updated_at = now()
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;

if v_row_count = 0 then
  return catchmenu_common.build_error_response(
    p_error_key := 'order_status_changed_concurrently',
    p_locale := p_locale,
    p_tenant_id := p_tenant_id,
    p_store_id := p_store_id,
    p_rpc_name := 'confirm_payment'
  );
end if;
```

Exact formatting may differ, but the behavior must not differ.

### 4.2 Rule 3 — CONFIRMED idempotent success for same provider transaction

If `v_order.order_status = 'CONFIRMED'` and an existing `APPROVED` ledger is found for:

- same `order_id`,
- same `provider_payment_key`,
- same `provider_type`,

then the function must return a success-shaped idempotent response instead of creating a new ledger or returning a hard error.

Required behavior:

- no new `payment_ledger` row,
- no order mutation,
- no KDS mutation,
- response data includes enough evidence to identify the existing ledger, such as `ledger_id` and `already_confirmed = true`.

### 4.3 Rule 3 — CONFIRMED conflict for different provider transaction

If `v_order.order_status = 'CONFIRMED'` but the provider transaction does not match an existing approved ledger for that order, `confirm_payment()` must reject the call.

Required behavior:

- no new `payment_ledger` row,
- no order mutation,
- no KDS mutation,
- error response such as `payment_already_confirmed`.

### 4.4 Rule 4/5 — late approval after cancelled/refunded order

If `v_order.order_status` is one of:

- `CANCELLED`
- `REFUNDED`
- `PARTIAL_REFUNDED`

then a late provider approval must not reopen or release the order.

Required behavior:

- The provider approval fact may be recorded in `catchmenu_payment.payment_ledger`.
- The ledger must be marked for manual reconciliation:

```sql
reconciliation_status = 'MANUAL_REVIEW'
```

- The reason must be recorded in JSON event payload, for example:

```json
{
  "reason": "payment_approved_after_order_cancelled"
}
```

- The function must not call `release_kds_after_payment()` for this branch.
- The function must not update `catchmenu_pos.orders` status.
- The function must not update `catchmenu_kds.kds_tickets`.
- The response must not look like a normal successful KDS-releasing payment confirmation.

### 4.5 Rule 1 — reject other non-confirmable statuses

For order statuses such as:

- `COOKING`
- `READY`
- `SERVED`
- `COMPLETED`

the function must reject the call rather than create a normal new payment release.

Required behavior:

- no normal new `APPROVED` KDS-releasing ledger,
- no order mutation,
- no KDS mutation,
- error response such as `order_not_confirmable`,
- include the current order status where practical.

## 5. Required Verification

Stage 4 must execute `600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix.md` in full.

Minimum required evidence:

1. `PENDING` order confirmation succeeds.
2. `CANCELLED`, `COOKING`, `READY`, `SERVED`, and `COMPLETED` order confirmation attempts are handled according to the TestPlan.
3. Same provider transaction re-delivery for a `CONFIRMED` order is idempotent success.
4. Different provider transaction for a `CONFIRMED` order is rejected.
5. Late provider approval after cancellation is recorded for manual review without order/KDS mutation.
6. The reproduced PAY-CON-003 race no longer yields:

```text
old ledger = CANCELLED
new ledger = APPROVED
orders.order_status = CONFIRMED
new ledger kds_release_authorized = true
```

7. KDS COOKING cancellation behavior is not regressed.
8. `pg_get_functiondef()` confirms the live function body contains the approved changes.

## 6. Open Items

The following are explicitly carried forward and must not be solved in this workpacket:

1. Rule 6/7: `reopen_order()` design and implementation.
2. Rule 6/7: staff-facing UI copy for cancelled-order recovery.
3. Rule 3/4 boundary case:
   - re-delivery of the same provider transaction after the order has advanced beyond `CONFIRMED` into `COOKING`, `READY`, `SERVED`, or `COMPLETED`.
   - Revision 2 currently treats those states as non-confirmable/rejected unless a later workpacket expands the idempotent branch.
4. Strict optimistic concurrency/versioning for `orders`.
5. PG/VAN automatic void/refund handling for late approvals after cancellation.

## 7. Human Boundary Approval

☑ I approve Rule 1 implementation in confirm_payment() only.
☑ I approve Rule 3 idempotent-success/conflict behavior for already-confirmed orders.
☑ I approve Rule 4/5 manual-review recording for late approvals after cancelled/refunded orders. (2026 - 07 - 16)

Implementation must not begin until all approval checkboxes above are checked by the human owner.

## 8. Stage 4 Stop Conditions

Stage 4 must stop and report without further edits if any of the following occur:

1. The required approval checkboxes are not checked.
2. The actual live `confirm_payment()` signature differs from the expected 14-parameter signature.
3. The current `orders` or `payment_ledger` check constraints differ from the assumptions in `600582_Logic`.
4. The implementation would require schema changes.
5. The implementation would require edits to `0037`, `cancel_payment()`, `request_refund()`, `confirm_refund()`, or `release_kds_after_payment()`.
6. The cancelled-order manual-review branch cannot record the event reason without a schema change.
7. Any TestPlan case reveals a new unrelated blocker that would require expanding scope.

