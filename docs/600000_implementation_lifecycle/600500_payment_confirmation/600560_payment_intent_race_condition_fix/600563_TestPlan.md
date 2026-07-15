# 600563_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2
Owner: Codex
Date: 2026-07-16

## 0. Purpose And Scope

This TestPlan verifies the approved option (a) from `600562_Logic_Payment_Intent_Race_Condition_Fix.md`:

1. Clean up the existing live duplicate `payment_intents` pair only after FK re-verification.
2. Add `uq_payment_intents_idempotency_key UNIQUE (idempotency_key)`.
3. Change `catchmenu_payment.resolve_or_create_payment_intent()` so its observed-intent INSERT uses:

```sql
on conflict (idempotency_key) do update
set updated_at = now()
returning id
```

The goal is to make concurrent calls with the same deterministic `idempotency_key` return the same surviving `payment_intents.id` instead of creating duplicate rows.

## 1. Pre-Implementation Safety Checks

### 1.1 Confirm Existing Duplicate Pair Still Exists

Before any DELETE or ALTER, re-run:

```sql
select
  id,
  order_id,
  idempotency_key,
  created_at
from catchmenu_payment.payment_intents
where idempotency_key =
  'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'
order by created_at, id;
```

Expected before cleanup:

- Winner candidate: `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf`
- Loser candidate: `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`
- Both rows still share the same `idempotency_key`.

If the pair no longer exists exactly as documented, STOP and report. Do not guess a new loser row.

### 1.2 Reconfirm FK References Before Deleting The Loser

Immediately before deleting `283f3973-d547-4ea9-b4ad-b83b1c62b8cc`, rerun the five FK reference checks recorded in `600562_Logic.md`:

```sql
select 'payment_ledger.intent_id' as ref, count(*) as cnt
from catchmenu_payment.payment_ledger
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'payment_events.intent_id' as ref, count(*) as cnt
from catchmenu_payment.payment_events
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'reconciliation_cases.intent_id' as ref, count(*) as cnt
from catchmenu_payment.reconciliation_cases
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'toss_payments.intent_id' as ref, count(*) as cnt
from catchmenu_integrations.toss_payments
where intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc'
union all
select 'toss_payment_requests.payment_intent_id' as ref, count(*) as cnt
from catchmenu_integrations.toss_payment_requests
where payment_intent_id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

Expected:

```text
payment_ledger.intent_id                 | 0
payment_events.intent_id                 | 0
reconciliation_cases.intent_id           | 0
toss_payments.intent_id                  | 0
toss_payment_requests.payment_intent_id  | 0
```

If any count is non-zero, STOP. Do not delete the loser row; Stage 4 must return to Human for a new winner/rewire decision.

## 2. Negative Test: Constraint Must Fail While Duplicate Remains

Before cleanup, intentionally attempt the final UNIQUE constraint inside a rollback-only transaction:

```sql
begin;
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
rollback;
```

Expected before cleanup:

- The `ALTER TABLE` fails because the existing duplicate key is still present.
- The error should identify `uq_payment_intents_idempotency_key` and the duplicated `idempotency_key`.

This failure is a positive signal: it proves the proposed constraint would actually catch the known duplicate. If it unexpectedly succeeds before cleanup, STOP and report because the documented live duplicate state has changed.

## 3. Cleanup Verification

After the FK checks pass, Stage 4 may delete the loser row:

```sql
delete from catchmenu_payment.payment_intents
where id = '283f3973-d547-4ea9-b4ad-b83b1c62b8cc';
```

Verify:

```sql
select
  id,
  idempotency_key,
  created_at
from catchmenu_payment.payment_intents
where idempotency_key =
  'OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391'
order by created_at, id;
```

Expected:

- Exactly 1 row remains.
- Remaining id is `17f67f52-e80d-47e9-a5ec-7e351a4e6dcf`.

## 4. UNIQUE Constraint Verification

After cleanup, apply:

```sql
alter table catchmenu_payment.payment_intents
  add constraint uq_payment_intents_idempotency_key unique (idempotency_key);
```

Verify:

```sql
select
  conname,
  contype,
  pg_get_constraintdef(oid) as def
from pg_constraint
where conrelid = 'catchmenu_payment.payment_intents'::regclass
  and conname = 'uq_payment_intents_idempotency_key';
```

Expected:

```text
uq_payment_intents_idempotency_key | u | UNIQUE (idempotency_key)
```

Also confirm the related unique index exists:

```sql
select
  i.relname as index_name,
  ix.indisunique,
  pg_get_indexdef(i.oid) as indexdef
from pg_index ix
join pg_class i on i.oid = ix.indexrelid
join pg_class t on t.oid = ix.indrelid
join pg_namespace n on n.oid = t.relnamespace
where n.nspname = 'catchmenu_payment'
  and t.relname = 'payment_intents'
  and i.relname = 'uq_payment_intents_idempotency_key';
```

Expected:

- `indisunique = true`
- index definition uses `btree (idempotency_key)`

## 5. Function Body Verification

After applying the function change, verify live body:

```sql
select pg_get_functiondef(p.oid)
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'resolve_or_create_payment_intent';
```

Expected:

- INSERT branch contains `on conflict (idempotency_key) do update`.
- INSERT branch contains `set updated_at = now()`.
- INSERT branch still ends with `returning id into v_intent_id`.
- No test-only tokens exist:
  - `pg_sleep`
  - `__test_`
  - `__pay_con`
  - `slow_resolve`
  - `OBS-RACE`
  - `INTRODUCE RACE`

## 6. Concurrency Reproduction Test After Fix

### 6.1 Test Isolation Rules

All intentional race tests must use isolated names:

- Any temporary helper function must be named with a `__test_` prefix.
- Any temporary helper function must be dropped in the same test script or final cleanup block.
- Test order/session identifiers must use clearly reserved UUIDs and test `correlation_id` values.
- Test data must be deleted immediately after verification.

Do not create unprefixed helper functions in production schemas. This rule exists because a previous investigation accidentally left `catchmenu_payment.__pay_con002_slow_resolve()` and a test `pg_sleep` body in the live database.

### 6.2 Two-Session Race Test

Re-run the same class of two-session race used by Codex/Antigravity, but only after the fix is applied.

The race may use a temporary helper only if it is named with `__test_` and dropped immediately:

```sql
create or replace function catchmenu_payment.__test_resolve_or_create_payment_intent_race_probe(
  p_sleep_seconds numeric default 1.5
)
returns uuid
language plpgsql
security definer
as $$
begin
  -- Test helper only. Must be dropped after test.
  perform pg_sleep(p_sleep_seconds);
  return catchmenu_payment.resolve_or_create_payment_intent(
    p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
    p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
    p_order_id := '<test_order_id>'::uuid,
    p_requested_amount := 15000,
    p_payment_method := 'CARD',
    p_payment_channel := 'STAFF_POS',
    p_provider_type := 'OKPOS',
    p_intent_origin := 'POS_SYNTHESIZED',
    p_origin_reference := jsonb_build_object(
      'source', '__test_payment_intent_race',
      'provider_tx_id', '<test_provider_tx_id>'
    ),
    p_intent_id := null,
    p_session_id := '<test_session_id>'::uuid,
    p_locale := 'ko'
  );
end;
$$;
```

Two independent sessions must call the resolver for the same test order/reference while overlapping in time.

Expected after fix:

- Both sessions complete successfully.
- Both sessions return the same `payment_intents.id`.
- Final count for the test `idempotency_key` is exactly 1.
- No duplicate intent row is created.

Verification query:

```sql
select
  count(*) as intent_count,
  array_agg(id order by created_at) as intent_ids,
  array_agg(idempotency_key order by created_at) as keys
from catchmenu_payment.payment_intents
where order_id = '<test_order_id>'::uuid
  and intent_origin = 'POS_SYNTHESIZED'
  and origin_reference = jsonb_build_object(
    'source', '__test_payment_intent_race',
    'provider_tx_id', '<test_provider_tx_id>'
  );
```

Expected:

```text
intent_count = 1
intent_ids contains one UUID
both session return values equal that UUID
```

### 6.3 Test Cleanup

After the race test:

```sql
drop function if exists catchmenu_payment.__test_resolve_or_create_payment_intent_race_probe(numeric);
delete from catchmenu_payment.payment_intents where order_id = '<test_order_id>'::uuid;
delete from catchmenu_pos.orders where id = '<test_order_id>'::uuid;
delete from catchmenu_pos.order_sessions where id = '<test_session_id>'::uuid;
```

Then verify no test helper remains:

```sql
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where p.proname like '__test_%'
   or p.proname ilike '%slow_resolve%'
   or p.proname ilike '%pay_con%';
```

Expected:

```text
(0 rows)
```

## 7. Normal Case Regression

Verify that distinct logical payment events still create distinct intents.

### 7.1 Different `order_id`

Call `resolve_or_create_payment_intent()` for two different `order_id` values with otherwise identical origin/reference structure.

Expected:

- Two different `payment_intents.id` values are created.
- Each has a different `idempotency_key` because `order_id` is part of the key.

### 7.2 Same `order_id`, Different `origin_reference`

Call `resolve_or_create_payment_intent()` twice for the same `order_id` but different `origin_reference` payloads.

Expected:

- Two different `payment_intents.id` values are created.
- Each has a different `idempotency_key` because the md5 of `origin_reference::text` differs.

## 8. Boundary Verification

Confirm zero diff for forbidden files:

```powershell
git diff -- sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
git diff -- sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
git diff -- sql/migrations/0109_create_network_handoff_fallback_rpc.sql
git diff -- sql/migrations/0130_create_van_handler_extension.sql
git diff -- sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql
```

Expected:

- No new diff in those files from this workpacket.
- `0142` trigger logic remains unchanged.

Also verify the new migration file is the only SQL source change for this workpacket, unless Stage 4 explicitly performs a §24-style source update to an already-applied file under Human approval.

## 9. Approval Criteria

This TestPlan passes only if:

- FK references for loser row `283f3973-d547-4ea9-b4ad-b83b1c62b8cc` are rechecked and remain 0 before deletion.
- The pre-cleanup negative UNIQUE test fails as expected.
- The loser row is deleted and the winner row remains.
- `uq_payment_intents_idempotency_key` exists and is unique.
- `resolve_or_create_payment_intent()` uses `ON CONFLICT (idempotency_key) DO UPDATE SET updated_at = now() RETURNING id`.
- The two-session race test returns the same intent id to both sessions and leaves exactly one row.
- Normal distinct event cases still create distinct intents.
- No `__test_` or slow helper remains.
- `0142` and unrelated payment pipeline files remain unchanged.

