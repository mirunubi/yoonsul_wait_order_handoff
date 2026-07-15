# 600573_TestPlan_Cancel_Payment_Phantom_Column_Fix

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: TBD
Last Updated: 2026-07-16

## Change ID

`cancel_payment_phantom_column_fix`

## 0. Test Scope

This TestPlan verifies the narrow correction defined in `600571_Overview_Cancel_Payment_Phantom_Column_Fix.md` and `600572_Logic_Cancel_Payment_Phantom_Column_Fix.md`.

The implementation scope is limited to `sql/migrations/0037_create_payment_cancel_refund_rpc.sql`:

- `cancel_payment()`
- `partial_cancel_payment()`
- `refund_payment()`

Each function receives the same single correction: remove `updated_at = now()` from the `catchmenu_payment.payment_ledger` `UPDATE` statement and clean up the trailing comma on the preceding assignment.

No state-transition logic, amount calculation, evidence insertion, audit insertion, event insertion, function signature, or caller contract is changed.

## 1. Pre-Implementation Verification

### 1.1 Confirm the phantom column is absent

Run:

```sql
select column_name
from information_schema.columns
where table_schema = 'catchmenu_payment'
  and table_name = 'payment_ledger'
  and column_name in (
    'ledger_status',
    'cancelled_amount',
    'net_amount',
    'kds_release_authorized',
    'evidence_packet_id',
    'refunded_amount',
    'approved_amount',
    'updated_at'
  )
order by column_name;
```

Expected:

- All seven intended columns exist:
  - `approved_amount`
  - `cancelled_amount`
  - `evidence_packet_id`
  - `kds_release_authorized`
  - `ledger_status`
  - `net_amount`
  - `refunded_amount`
- `updated_at` is absent.

### 1.2 Confirm the three stale references exist before the fix

Run a source grep against `0037_create_payment_cancel_refund_rpc.sql`.

Expected before implementation:

- `cancel_payment()` payment_ledger update contains `updated_at = now()`.
- `partial_cancel_payment()` payment_ledger update contains `updated_at = now()`.
- `refund_payment()` payment_ledger update contains `updated_at = now()`.

Expected after implementation:

- `updated_at = now()` no longer appears in any `catchmenu_payment.payment_ledger` update in this file.
- Any `updated_at = now()` belonging to other tables, such as `catchmenu_pos.orders`, is not removed merely because it shares the same text.

## 2. Test A — `cancel_payment()` executes successfully

### 2.1 Setup

Create a disposable order/session/payment ledger path using the same practical call shape as the known active callers in `0038_create_toss_webhook_processor_rpc.sql` and `0056_create_van_integration_rpc.sql`.

Recommended setup:

1. Insert a disposable `catchmenu_pos.order_sessions` row.
2. Insert a disposable `catchmenu_pos.orders` row.
3. Call `catchmenu_payment.confirm_payment()` to create an `APPROVED` `payment_ledger` row and associated `payment_intents` row.
4. Capture the returned `ledger_id`.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_cancel_
```

Wrap the observable mutation test in a transaction where practical, and roll back or explicitly delete disposable rows after the test.

### 2.2 Execution

Call:

```sql
select catchmenu_payment.cancel_payment(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_ledger_id := '<approved_ledger_id>'::uuid,
  p_cancel_reason := 'phantom column fix verification',
  p_actor_type := 'STAFF',
  p_actor_id := null,
  p_correlation_id := '__test_cancel_phantom_fix_cancel'
);
```

### 2.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected response:

- `success = true`
- `ledger_status = 'CANCELLED'`

Expected ledger state:

- `ledger_status = 'CANCELLED'`
- `cancelled_amount = approved_amount`
- `net_amount = 0`
- `kds_release_authorized = false`
- `evidence_packet_id is not null`

## 3. Test B — KDS cancellation linkage after `cancel_payment()`

### 3.1 Setup

Before calling `cancel_payment()`, create disposable `catchmenu_kds.kds_tickets` rows for the test order covering the statuses that the function's current predicate actually targets:

- Case 1: `kds_status = 'HOLD'`
- Case 2: `kds_status = 'COMMITTED'`
- Case 3: `kds_status = 'COOKING'`
- Case 4, negative: `kds_status = 'COMPLETED'` or `kds_status = 'SERVED'`

Case 3 is mandatory because it covers the high-risk payment-cancel-vs-cooking-start race: the current `cancel_payment()` predicate excludes only `COMPLETED`, `SERVED`, and `CANCELLED`, so an already-cooking ticket is still in the cancellation target set.

Case 4 is mandatory because completed/served tickets are explicitly excluded by the function and must remain untouched.

The ticket must share:

- `tenant_id`
- `store_id`
- `order_id`

with the payment ledger/order under test.

### 3.2 Expected result

After `cancel_payment()` succeeds, verify:

```sql
select id, kds_status, cancelled_at, hold_reason
from catchmenu_kds.kds_tickets
where order_id = '<test_order_id>'::uuid;
```

Expected by case:

- Case 1, `HOLD`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 2, `COMMITTED`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 3, `COOKING`: `kds_status = 'CANCELLED'`, `cancelled_at is not null`, `hold_reason = 'PAYMENT_CANCELLED'`
- Case 4, `COMPLETED` or `SERVED`: `kds_status` remains unchanged and `cancelled_at` remains null

This is the first required empirical confirmation that the KDS cancellation path actually executes once the `payment_ledger.updated_at` crash is removed.

## 4. Test C — `partial_cancel_payment()` executes successfully

### 4.1 Setup

Create a disposable approved payment ledger using the same setup pattern as Test A.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_partial_
```

### 4.2 Execution

Call `catchmenu_payment.partial_cancel_payment()` with a valid partial amount smaller than the approved amount.

The exact argument list must be taken from the live function signature before execution:

```sql
select pg_get_function_identity_arguments(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'partial_cancel_payment';
```

### 4.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected ledger state for a partial cancellation:

- `ledger_status = 'PARTIAL_CANCELLED'`
- `cancelled_amount` increases by the partial cancellation amount.
- `net_amount = approved_amount - cancelled_amount - refunded_amount`
- `evidence_packet_id is not null`

If the test intentionally cancels the full remaining net amount through this function, then `ledger_status = 'CANCELLED'` is acceptable because that is the pre-existing function logic.

## 5. Test D — `refund_payment()` executes successfully

### 5.1 Setup

Create a disposable ledger state that satisfies `refund_payment()`'s own preconditions. This function currently has no confirmed active callers, but the function itself must still execute after the narrow phantom-column fix.

Use a unique correlation id prefix such as:

```text
__test_cancel_phantom_fix_refund_
```

### 5.2 Execution

Call `catchmenu_payment.refund_payment()` using the live signature:

```sql
select pg_get_function_identity_arguments(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'refund_payment';
```

### 5.3 Expected result

The function must no longer fail with:

```text
column "updated_at" of relation "payment_ledger" does not exist
```

Expected ledger state:

- `refunded_amount` changes according to the existing function logic.
- `net_amount` changes according to the existing function logic.
- `ledger_status` follows the existing function branch:
  - `REFUNDED`, or
  - `PARTIAL_REFUNDED`
- `evidence_packet_id is not null`

No assertion in this test authorizes changing `refund_payment()` semantics or dropping the function.

## 6. Regression Checks

For each of the three functions, verify that the following columns still receive the same intended values as before, except that no nonexistent `updated_at` assignment is attempted:

- `ledger_status`
- `cancelled_amount`
- `net_amount`
- `kds_release_authorized`
- `evidence_packet_id`
- `refunded_amount`
- `approved_amount`

The test should explicitly compare before/after row values for the ledger under test.

## 7. Boundary Verification

### 7.1 Source boundary

Run:

```bash
git diff -- sql/migrations/0037_create_payment_cancel_refund_rpc.sql
git diff -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
```

Expected:

- `0037_create_payment_cancel_refund_rpc.sql` contains exactly the three `updated_at = now()` removals from `payment_ledger` updates, plus trailing comma cleanup.
- `0098_create_payment_confirm_pipeline_rpc.sql` has no diff.

### 7.2 Forbidden-file boundary

Verify no diff in:

- `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql`
- any `confirm_payment()` implementation file
- any refund pipeline redesign file
- any caller file such as `0038_create_toss_webhook_processor_rpc.sql` or `0056_create_van_integration_rpc.sql`

### 7.3 Migration application boundary

If Stage 4 implements this as a new forward migration, verify:

- the next migration number is chosen immediately before creation,
- the new migration only redefines the three approved functions or otherwise applies the approved narrow source correction,
- no unrelated schema or function is changed.

## 8. Approval Criteria

This workpacket passes Stage 5 verification only if all are true:

1. `cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
2. `partial_cancel_payment()` no longer crashes on `payment_ledger.updated_at`.
3. `refund_payment()` no longer crashes on `payment_ledger.updated_at`.
4. `cancel_payment()` empirically cancels eligible KDS tickets after payment cancellation.
5. The seven remaining ledger columns are updated according to existing logic.
6. `0098` and unrelated refund pipeline code remain untouched.
7. No function signature changes are introduced.
8. All disposable test data is rolled back or explicitly cleaned up.

## 9. Open Items Not Resolved Here

- Whether `refund_payment()` and/or `partial_cancel_payment()` should eventually be dropped remains a separate decision.
- The `0098` refund pipeline (`request_refund()` / `confirm_refund()`) remains a separate redesign workpacket.
- The `0102` / `0104` caller issue where refund amount is always passed as `0` remains deferred to the refund pipeline redesign workpacket.
- COOKING 상태(이미 조리 시작)에서 결제 취소 시 실제로 CANCELLED로 정확히 전환됨이 Stage 4 실행에서 경험적으로 확인됨(COMPLETED/SERVED는 정확히 보호됨도 확인). 남은 것은 기술 문제가 아니라 순수 운영 정책 문제: 이미 조리 중이던 음식을 취소 시 재료를 폐기할지, 직원 식사로 처리할지, 계속 조리해서 준비해둘지 등은 매장 운영 정책으로 1~2년 뒤 실제 라이브 운영 경험을 바탕으로 결정. `000056_Register_Concurrency_Risk.md`의 `KDS-CON-002` 항목 참고.
