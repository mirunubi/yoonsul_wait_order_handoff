# 600583_TestPlan_Payment_Confirm_Cancel_State_Machine_Fix

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`payment_confirm_cancel_state_machine_fix`

## 0. Test Scope

This TestPlan verifies the final Revision 2 design from:

- `600581_Overview_Payment_Confirm_Cancel_State_Machine_Fix.md`
- `600582_Logic_Payment_Confirm_Cancel_State_Machine_Fix.md`

The target function is:

- `catchmenu_payment.confirm_payment()` in `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`

The workpacket does not modify:

- `cancel_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- `orders` schema
- `payment_ledger` schema
- `payment_intents` schema
- KDS release or cancellation logic

The purpose is to make `confirm_payment()` respect the order/payment state machine after the PAY-CON-003 race was reproduced.

## 1. Pre-Implementation Verification

### 1.1 Confirm current order status vocabulary

Run:

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_pos.orders'::regclass
  and conname = 'chk_order_status';
```

Expected:

- `PENDING` exists.
- `CONFIRMED` exists.
- `COOKING` exists.
- `READY` exists.
- `SERVED` exists.
- `COMPLETED` exists.
- `CANCELLED` exists.
- `REFUNDED` exists.
- `PARTIAL_REFUNDED` exists.
- `PAYMENT_PENDING` and `PAYMENT_PROCESSING` do not exist.

This confirms the Revision 2 decision to reuse existing `PENDING` rather than introduce new order-state values.

### 1.2 Confirm current reconciliation vocabulary

Run:

```sql
select conname, pg_get_constraintdef(oid)
from pg_constraint
where conrelid = 'catchmenu_payment.payment_ledger'::regclass
  and conname = 'chk_ledger_reconciliation';
```

Expected:

- `MANUAL_REVIEW` exists and can be reused.
- No new reconciliation status is required for this workpacket.

### 1.3 Confirm baseline PAY-CON-003 reproduction is understood

Before implementation, the previously reproduced bad path is:

1. A payment is confirmed for an order.
2. `cancel_payment()` cancels the existing `APPROVED` ledger and sets the order to `CANCELLED`.
3. A later or racing `confirm_payment()` call with a different provider transaction can create a new `APPROVED` ledger for the same order and move the order back to `CONFIRMED`.

After implementation, this path must no longer create a normal released payment for a cancelled order.

## 2. Rule 1 Tests — PENDING-only confirm gate

### 2.1 PENDING order succeeds

Setup:

1. Create a disposable `catchmenu_pos.orders` row with:
   - `order_status = 'PENDING'`
   - `order_type = 'TAKEOUT'`
   - valid `tenant_id`, `store_id`, `order_number`, `business_day`, and amount fields.
2. Use a unique prefix such as:

```text
__test_paycon003_rule1_pending_
```

Execution:

```sql
select catchmenu_payment.confirm_payment(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_order_id := '<pending_order_id>'::uuid,
  p_provider_type := 'OKPOS',
  p_provider_approval_number := '<unique_approval_number>',
  p_provider_tx_id := '<unique_provider_tx_id>',
  p_approved_amount := <final_amount>,
  p_payment_method := 'CARD',
  p_provider_response := jsonb_build_object('test', 'rule1_pending'),
  p_actor_type := 'STAFF',
  p_actor_id := null,
  p_locale := 'ko',
  p_correlation_id := '__test_paycon003_rule1_pending',
  p_intent_id := null
);
```

Expected:

- `success = true`.
- A `payment_ledger` row is created.
- The created ledger has `ledger_status = 'APPROVED'`.
- The order moves from `PENDING` to the normal post-payment state:
  - `CONFIRMED` for `TAKEOUT` and non-table order types,
  - `COOKING` only where the existing function logic intentionally maps table orders that way.
- `release_kds_after_payment()` behavior remains unchanged.

### 2.2 Non-PENDING orders are rejected

Run the same `confirm_payment()` call shape against disposable orders with each of the following initial statuses:

- `CANCELLED`
- `COOKING`
- `READY`
- `SERVED`
- `COMPLETED`

Expected for `COOKING`, `READY`, `SERVED`, and `COMPLETED`:

- `confirm_payment()` returns a failure response.
- The response identifies the order as not confirmable, for example `error_key = 'order_not_confirmable'`.
- No normal `APPROVED` payment release path is executed.
- `orders.order_status` remains unchanged.
- Existing KDS tickets remain unchanged.

Expected for `CANCELLED`:

- See Rule 4/5 tests in §4.

### 2.3 Conditional update row-count check

The implementation must use a conditional order update equivalent to:

```sql
update catchmenu_pos.orders
set ...
where id = p_order_id
  and order_status = 'PENDING';

get diagnostics v_row_count = row_count;
```

Expected:

- If `v_row_count = 0`, `confirm_payment()` returns a failure response such as `order_status_changed_concurrently`.
- The function must not silently continue after a zero-row state transition.

## 3. Rule 3 Tests — provider idempotency and CONFIRMED re-delivery

### 3.1 Existing provider idempotency check remains first

Setup:

1. Create a disposable `PENDING` order.
2. Call `confirm_payment()` once with a unique provider key.
3. Capture the resulting `ledger_id`.

Execution:

Call `confirm_payment()` again with the same:

- `p_provider_type`
- `p_provider_tx_id`
- `p_order_id`

Expected:

- The call does not create a second `APPROVED` ledger.
- The existing provider-key idempotency check still prevents duplicate payment records.

### 3.2 CONFIRMED order with same provider transaction returns idempotent success

Setup:

1. Use an order that is already `CONFIRMED` from the first successful payment.
2. Re-send the same provider transaction.

Expected:

- The function returns a success-shaped idempotent response, not a hard error.
- The response should identify that the payment was already confirmed, for example:
  - `already_confirmed = true`
  - existing `ledger_id`
- No new `payment_ledger` row is created.

### 3.3 CONFIRMED order with a different provider transaction is rejected

Setup:

1. Use an order already `CONFIRMED` from a prior successful payment.
2. Call `confirm_payment()` with a different provider transaction id.

Expected:

- The function returns a failure response such as `payment_already_confirmed`.
- No new `APPROVED` ledger is created.
- `orders.order_status` remains `CONFIRMED`.

### 3.4 Boundary note for later order states

The Revision 2 design intentionally keeps the new idempotent-success branch scoped to `order_status = 'CONFIRMED'`.

For `COOKING`, `READY`, `SERVED`, and `COMPLETED`, even a re-delivered provider transaction may currently be rejected by the Rule 1 gate. This is a known Open Item, not a TestPlan failure for this workpacket.

## 4. Rule 4/5 Tests — approval after cancellation is recorded but does not reopen order/KDS

### 4.1 CANCELLED order receives a provider approval

Setup:

1. Create a disposable order.
2. Confirm the order once to create an `APPROVED` ledger.
3. Cancel the payment using `cancel_payment()`.
4. Confirm the order is now:
   - `orders.order_status = 'CANCELLED'`
   - previous ledger has `ledger_status = 'CANCELLED'`

Execution:

Call `confirm_payment()` again for the same `order_id` with a new provider transaction.

Expected:

- The provider approval fact is recorded in `catchmenu_payment.payment_ledger`.
- The new ledger uses existing reconciliation vocabulary:
  - `reconciliation_status = 'MANUAL_REVIEW'`
- `orders.order_status` remains `CANCELLED`.
- `catchmenu_kds.kds_tickets` are not released or reopened.
- `release_kds_after_payment()` is not executed for this cancelled-order branch.
- The response must not look like a normal successful KDS-releasing payment confirmation.

### 4.2 Manual-review reason is recorded in event payload

After §4.1, inspect payment/event rows associated with the new manual-review ledger.

Expected:

- The reason is recorded in a JSON payload field, for example:

```json
{
  "reason": "payment_approved_after_order_cancelled"
}
```

- No new `reconciliation_status` enum/check value is introduced.

### 4.3 No order/KDS mutation on cancelled-order approval

Capture before/after snapshots:

```sql
select order_status, cancelled_at, confirmed_at
from catchmenu_pos.orders
where id = '<order_id>'::uuid;

select id, kds_status, cancelled_at, hold_reason, payment_ledger_id
from catchmenu_kds.kds_tickets
where order_id = '<order_id>'::uuid
order by ticket_created_at, id;
```

Expected:

- `orders.order_status` remains `CANCELLED`.
- Existing cancelled KDS tickets remain cancelled.
- No KDS ticket is moved back to `COMMITTED` or `COOKING`.
- No ticket receives a new `payment_ledger_id` merely because a late provider approval arrived.

## 5. Re-run the reproduced PAY-CON-003 scenario

### 5.1 cancel complete, then confirm retry

Re-run the concrete scenario reproduced during investigation:

1. Confirm a payment.
2. Cancel the payment.
3. Retry `confirm_payment()` for the same order with a different provider transaction.

Expected after this fix:

- The order is not moved back to `CONFIRMED`.
- A normal new `APPROVED` ledger that releases KDS is not created.
- If a ledger is recorded for the late provider approval, it is manual-review only:
  - `reconciliation_status = 'MANUAL_REVIEW'`
  - reason stored in event payload
  - no order/KDS mutation

### 5.2 concurrent cancel vs confirm

Use two DB sessions:

- Session A: call `cancel_payment()` and hold the transaction open after it has updated the ledger/order.
- Session B: call `confirm_payment()` for the same `order_id`.
- Commit Session A.
- Observe Session B result.

Expected:

- Session B must not restore the order to `CONFIRMED`.
- Session B must not create a normal KDS-releasing `APPROVED` ledger.
- Final state must not contain:

```text
orders.order_status = CONFIRMED
old ledger = CANCELLED
new ledger = APPROVED with kds_release_authorized = true
```

That was the reproduced pre-fix failure mode and must be eliminated.

## 6. KDS COOKING cancellation race regression

This workpacket does not change `cancel_payment()` or KDS status transition logic, but the previously verified COOKING cancellation path must remain intact.

Setup:

1. Create an order.
2. Confirm payment.
3. Create or use a KDS ticket linked to the payment ledger.
4. Move the KDS ticket to `COOKING`.
5. Call `cancel_payment()`.

Expected:

- `cancel_payment()` still succeeds.
- `kds_tickets.kds_status` becomes `CANCELLED`.
- `hold_reason = 'PAYMENT_CANCELLED'`.
- `COMPLETED` and `SERVED` tickets remain protected if included as negative cases.

## 7. Boundary Verification

### 7.1 Source diff boundary

Expected source diff:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
  - `confirm_payment()` body only

Expected no source diff:

- `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`
- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`
- `request_refund()`
- `confirm_refund()`
- `release_kds_after_payment()`
- schema DDL for `catchmenu_pos.orders`
- schema DDL for `catchmenu_payment.payment_ledger`
- schema DDL for `catchmenu_payment.payment_intents`

### 7.2 Live function verification

After implementation:

```sql
select pg_get_functiondef(
  'catchmenu_payment.confirm_payment(uuid,uuid,uuid,text,text,text,integer,text,jsonb,text,uuid,text,text,uuid)'::regprocedure
);
```

Expected:

- The live body contains the new order-status gate.
- The live body contains the conditional `PENDING` update and row-count check.
- The live body contains the `CONFIRMED` idempotent success branch.
- The live body contains the cancelled-order manual-review branch.
- The live body does not contain unrelated edits to refund or cancellation functions.

## 8. Cleanup

All test rows must use a unique prefix such as:

```text
__test_paycon003_
```

Cleanup must remove disposable rows from, as applicable:

- `catchmenu_ledger.events`
- `catchmenu_kds.kds_events`
- `catchmenu_payment.payment_events`
- `catchmenu_agent.evidence_packets`
- `catchmenu_kds.kds_tickets`
- `catchmenu_payment.payment_ledger`
- `catchmenu_payment.payment_intents`
- `catchmenu_gateway.provider_raw_events`
- `catchmenu_pos.orders`

Final verification:

```sql
select count(*)
from catchmenu_pos.orders
where order_number like '__test_paycon003_%';
```

Expected:

- `0`

## 9. Acceptance Criteria

This workpacket is accepted only if all of the following are true:

1. Normal `PENDING` order confirmation still succeeds.
2. `CANCELLED`, `COOKING`, `READY`, `SERVED`, and `COMPLETED` orders are not silently reconfirmed.
3. Re-delivery of the same provider transaction for a `CONFIRMED` order is idempotent success.
4. A different provider transaction for a `CONFIRMED` order is rejected.
5. A late provider approval for a cancelled order is recorded for manual review without reopening order/KDS state.
6. The reproduced PAY-CON-003 race no longer yields `CANCELLED` ledger plus new normal `APPROVED` KDS-releasing ledger on the same order.
7. KDS COOKING cancellation behavior is not regressed.
8. Boundary verification confirms only `confirm_payment()` in `0098` changed.

