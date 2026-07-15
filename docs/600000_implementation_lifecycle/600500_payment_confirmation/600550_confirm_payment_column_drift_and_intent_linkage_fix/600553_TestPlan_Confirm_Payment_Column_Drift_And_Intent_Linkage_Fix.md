# 600553_TestPlan_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix

## 0. Purpose And Scope

This TestPlan verifies the confirmed Revision 2 / Option C+ design for `confirm_payment()` payment-intent linkage and `payment_ledger` column-contract reconciliation.

Authoritative design inputs:

- `600551_Overview_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`
- `600552_Logic_Confirm_Payment_Column_Drift_And_Intent_Linkage_Fix.md`

Confirmed implementation scope:

1. Add `catchmenu_payment.payment_intents.intent_origin text not null` with the allowed values:
   - `PREAUTHORIZED`
   - `POS_SYNTHESIZED`
   - `MANUAL_ENTRY`
   - `VAN_SYNTHESIZED`
   - `IMPORTED`
2. Add `catchmenu_payment.payment_intents.origin_reference jsonb`.
3. Add the shared helper RPC:
   - `catchmenu_payment.resolve_or_create_payment_intent()`
4. Update `catchmenu_payment.confirm_payment()` in `0098_create_payment_confirm_pipeline_rpc.sql`:
   - add `p_intent_id default null`
   - resolve or synthesize a valid `payment_intents.id`
   - rewrite the `payment_ledger` insert to use real columns only
   - remove phantom references to `payment_method`, `provider_tx_id`, `fee_amount`, and `provider_response`
   - use `provider_response_id`
   - insert `intent_id`
   - insert `ledger_entry_type`
5. Update the `RECORD_MANUAL_PAYMENT` branch in `0109_create_network_handoff_fallback_rpc.sql` to use `intent_origin = 'MANUAL_ENTRY'`.
6. Update `record_van_transaction()` in `0130_create_van_handler_extension.sql` to use `intent_origin = 'VAN_SYNTHESIZED'`, while keeping `van_transactions.tax_amount` on `catchmenu_payment.van_transactions` and not inserting it into `payment_ledger`.
7. Update only the Toss Payments caller in `0103_create_toss_payments_pipeline_rpc.sql` by adding:
   - `p_intent_id := v_request.payment_intent_id`

Non-scope reminders:

- `0102_create_okpos_integration_pipeline_rpc.sql` remains unchanged.
- `0104_create_toss_pos_pipeline_rpc.sql` remains unchanged.
- `0027_create_payment_intent_rpc.sql`, `0038_create_toss_webhook_processor_rpc.sql`, `0056_create_van_integration_rpc.sql`, and `0142_patch_toss_mvp_payment_intent_binding.sql` remain unchanged.
- Downstream `fee_amount` / `payment_method` readers in `0111`, `0100`, `0120`, and `0084` are not corrected in this workpacket.

## 1. Schema Verification

### 1.1 `payment_intents` New Columns Exist

Run:

```sql
select
  column_name,
  data_type,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'catchmenu_payment'
  and table_name = 'payment_intents'
  and column_name in ('intent_origin', 'origin_reference')
order by ordinal_position;
```

Expected:

- `intent_origin` exists.
- `intent_origin` is `text`.
- `intent_origin` is `not null`.
- `origin_reference` exists.
- `origin_reference` is `jsonb`.

### 1.2 `intent_origin` Check Constraint Allows Exactly The Approved Values

Run:

```sql
select
  conname,
  pg_get_constraintdef(oid) as constraint_def
from pg_constraint
where conrelid = 'catchmenu_payment.payment_intents'::regclass
  and pg_get_constraintdef(oid) like '%intent_origin%';
```

Expected:

- The constraint includes:
  - `PREAUTHORIZED`
  - `POS_SYNTHESIZED`
  - `MANUAL_ENTRY`
  - `VAN_SYNTHESIZED`
  - `IMPORTED`
- No existing `payment_intents` reader breaks because of the added columns.

### 1.3 `provider_raw_events` Required Columns Remain Compatible

Run:

```sql
select
  column_name,
  is_nullable,
  column_default
from information_schema.columns
where table_schema = 'catchmenu_integrations'
  and table_name = 'provider_raw_events'
order by ordinal_position;
```

Expected:

- The function-side inline insert only needs to supply:
  - `tenant_id`
  - `provider_type`
  - `provider_code`
  - `raw_payload`
- Other `not null` columns remain satisfied by defaults.

## 2. Helper Function Unit Tests

Target helper:

```sql
catchmenu_payment.resolve_or_create_payment_intent()
```

The helper generalizes the `0142` `bind_toss_payment_intent()` pattern without modifying the `0142` trigger itself.

### 2.1 PREAUTHORIZED Intent Validation

Setup:

- Create or reuse a test `payment_intents` row for a test `tenant_id`, `store_id`, and `order_id`.
- Set:
  - `intent_origin = 'PREAUTHORIZED'`
  - `origin_reference` to a JSON object that identifies the upstream request.

Run the helper with the known `p_intent_id`.

Expected:

- The helper returns the existing `payment_intents.id`.
- It does not create a duplicate intent.
- It rejects an intent that belongs to a different tenant, store, or order.

### 2.2 Existing Candidate Reuse

Setup:

- Create exactly one eligible payment intent for a test order.
- Do not pass `p_intent_id`.

Expected:

- The helper reuses the existing candidate.
- No duplicate payment intent is created for the same order and origin context.

### 2.3 New Candidate Creation

Setup:

- Use a test order with no existing eligible payment intent.
- Do not pass `p_intent_id`.

Expected:

- The helper creates one new `payment_intents` row.
- The row has the requested `intent_origin`.
- The row has the expected `origin_reference`.
- The returned id matches the newly created row.

### 2.4 Multiple Candidate Error

Setup:

- Create two eligible payment-intent candidates for the same tenant, store, order, and origin context.
- Do not pass `p_intent_id`.

Expected:

- The helper returns or raises the explicit multiple-candidate error defined by `600552_Logic`.
- It does not silently pick one candidate.
- It does not create a third candidate.

## 3. `0098 confirm_payment()` Integration Tests

### 3.1 Static Function Definition Check

Run:

```sql
select pg_get_functiondef(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'confirm_payment';
```

Expected:

- `p_intent_id` exists and defaults to `null`.
- The `payment_ledger` insert includes:
  - `intent_id`
  - `ledger_entry_type`
  - `provider_response_id`
- The function body does not reference phantom `payment_ledger` columns:
  - `payment_method`
  - `provider_tx_id`
  - `fee_amount`
  - `provider_response`

### 3.2 OKPOS Path

Exercise the OKPOS path through the existing `0102` caller or an equivalent direct `confirm_payment()` call matching that caller's parameters.

Expected:

- `confirm_payment()` completes far enough to insert a `payment_ledger` row.
- The resulting `payment_ledger.intent_id` is populated.
- The linked `payment_intents.intent_origin` is `POS_SYNTHESIZED`.
- `provider_response_id` is populated from the inline `provider_raw_events` insert.
- No phantom-column error occurs.

### 3.3 Toss Payments Path

Exercise the Toss Payments path through `0103`.

Required caller change:

```sql
p_intent_id := v_request.payment_intent_id
```

Expected:

- The existing preauthorized Toss Payments intent is reused.
- The linked `payment_intents.intent_origin` is `PREAUTHORIZED`.
- The resulting `payment_ledger.intent_id` equals `v_request.payment_intent_id`.
- `provider_response_id` is populated.
- No phantom-column error occurs.

### 3.4 Toss POS Path

Exercise the Toss POS path through the existing `0104` caller or an equivalent direct `confirm_payment()` call matching that caller's parameters.

Expected:

- `0104` remains source-unchanged.
- `confirm_payment()` synthesizes or reuses a `POS_SYNTHESIZED` intent.
- The resulting `payment_ledger.intent_id` is populated.
- `provider_response_id` is populated.
- No phantom-column error occurs.

## 4. `0109 RECORD_MANUAL_PAYMENT` Verification

Exercise `flush_offline_queue()` with a `RECORD_MANUAL_PAYMENT` payload.

Expected:

- The branch creates or resolves a payment intent with:
  - `intent_origin = 'MANUAL_ENTRY'`
- The resulting `payment_ledger` row uses real ledger columns only.
- The resulting `payment_ledger.intent_id` is populated.
- The resulting `payment_ledger.provider_response_id` is populated when a raw provider event is recorded.
- No `payment_method`, `provider_tx_id`, `fee_amount`, or `provider_response` ledger-column reference remains in this branch.

## 5. `0130 record_van_transaction()` Verification

Exercise `catchmenu_payment.record_van_transaction()`.

Expected:

- The function creates or resolves a payment intent with:
  - `intent_origin = 'VAN_SYNTHESIZED'`
- `catchmenu_payment.van_transactions.tax_amount` remains populated as applicable.
- `payment_ledger` does not receive or reference `tax_amount`.
- The resulting `payment_ledger.intent_id` is populated.
- The resulting `payment_ledger.provider_response_id` is populated when a raw provider event is recorded.
- No phantom `payment_ledger` column reference remains.

## 6. Idempotency And Duplicate-Intent Checks

### 6.1 Same Order Replayed Twice

Run the same order/payment confirmation path twice with the same identifying origin context.

Expected:

- The second execution does not create a duplicate `payment_intents` row.
- The helper reuses the existing intent where the design says reuse is required.
- If the function is expected to reject duplicate ledger insertion separately, the rejection must happen after intent resolution and must not create a duplicate intent.

### 6.2 Origin-Specific Idempotency

Run idempotency checks separately for:

- `PREAUTHORIZED`
- `POS_SYNTHESIZED`
- `MANUAL_ENTRY`
- `VAN_SYNTHESIZED`

Expected:

- Each origin follows the reuse/create/error behavior defined in `600552_Logic`.
- Origin-specific references in `origin_reference` remain stable enough for repeat resolution.

## 7. Boundary And Regression Checks

### 7.1 Files That Must Remain Unchanged

Confirm zero diff for:

- `sql/migrations/0027_create_payment_intent_rpc.sql`
- `sql/migrations/0038_create_toss_webhook_processor_rpc.sql`
- `sql/migrations/0056_create_van_integration_rpc.sql`
- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`
- `sql/migrations/0102_create_okpos_integration_pipeline_rpc.sql`
- `sql/migrations/0104_create_toss_pos_pipeline_rpc.sql`

### 7.2 `0142` Trigger Logic Still Works

Run a sanity check for the Toss binding flow:

- Existing `payment_intent_id` validation still works.
- Candidate reuse still works.
- Multiple candidate conflict behavior still works.
- No `0142` trigger body change is required for this workpacket.

### 7.3 Downstream `fee_amount` / `payment_method` Readers Remain Out Of Scope

Search and report, but do not fix in this workpacket:

- `fee_amount`
- `payment_method`

Known downstream files to keep out of this implementation scope:

- `0111`
- `0100`
- `0120`
- `0084`

Expected:

- Any remaining downstream references are reported as Open Items.
- They are not silently fixed in this workpacket.

## 8. Apply And Live Verification Requirements

If Stage 4 implements this by editing already-applied migration source files in place, the implementation must follow the established §24 Lightweight Track procedure:

1. Modify source files.
2. Recalculate checksums using CRLF-to-LF normalization.
3. Update `catchmenu_meta.migration_history`.
4. Directly re-execute the affected live function definitions.
5. Use `pg_get_functiondef()` to verify the live database body actually changed.

Checksum update alone is not proof of live function replacement.

If Stage 4 instead uses a new forward migration for schema/helper/function replacement, the implementation must still verify live function bodies through `pg_get_functiondef()` after `tools/apply_migrations.py` completes.

## 9. Approval Criteria

This TestPlan passes only if all of the following are true:

- `payment_intents.intent_origin` exists and enforces the five approved values.
- `payment_intents.origin_reference` exists.
- `resolve_or_create_payment_intent()` passes the four unit scenarios.
- `confirm_payment()` no longer references phantom `payment_ledger` columns.
- OKPOS, Toss Payments, and Toss POS paths all produce `payment_ledger.intent_id`.
- Toss Payments uses the preauthorized intent supplied by `0103`.
- OKPOS and Toss POS synthesize or reuse `POS_SYNTHESIZED` intents.
- `0109` creates or reuses `MANUAL_ENTRY` intents.
- `0130` creates or reuses `VAN_SYNTHESIZED` intents.
- `van_transactions.tax_amount` remains on `catchmenu_payment.van_transactions` and is not copied into `payment_ledger`.
- Same-order replay does not create duplicate intents.
- Forbidden files remain unchanged.
- Downstream `fee_amount` / `payment_method` issues are explicitly carried forward rather than silently modified.
