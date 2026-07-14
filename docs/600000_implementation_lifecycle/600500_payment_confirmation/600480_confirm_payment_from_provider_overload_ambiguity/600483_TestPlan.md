# 600483_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude review / verification planning)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`confirm_payment_from_provider_overload_ambiguity`

## 0. Authority And Scope

This TestPlan is derived from the finalized design in `600481_Overview.md` §0.5 and `600482_Logic.md` §1 (Human decision, 2026-07-14, no re-litigation):

- `catchmenu_payment.confirm_payment_from_provider()` is reduced to a single canonical overload: the 8-parameter version from `0027_create_payment_intent_rpc.sql`.
- The 9-parameter overload from `0063_patch_core_rpc_i18n_diagnostics.sql` (`p_locale` added) is dropped via a new forward migration.
- `p_locale` and a hypothetical `p_options jsonb` extension field are explicitly **not** introduced (Human decision, YAGNI).

## 1. Verification Environment

All execution tests must run against local Supabase Docker DB only (`supabase_db_yoonsul_wait_order_handoff`).

Requirements:

- Wrap all data-mutating tests in `BEGIN; ... ROLLBACK;`.
- Do not leave test intents, orders, ledger rows, KDS tickets, events, or audit records behind.
- Do not modify `0027`, `0038`, `0056`, or the `confirm_payment_from_provider` definition inside `0063` during verification — verification observes behavior only.
- Reference test identifiers already established in this workpacket's investigation (`600477`/`600480` series):
  - `p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid`
  - `p_store_id := '00000000-0000-0000-0000-000000000002'::uuid`

## 2. Test A — `DROP FUNCTION` Leaves Exactly One Overload

Purpose: confirm the 9-param overload is gone and the 8-param overload survives untouched.

Execution shape:

```sql
begin;

drop function if exists catchmenu_payment.confirm_payment_from_provider(
  uuid, uuid, uuid, text, text, int, uuid, text, text
);

select count(*) as overload_count,
       pg_get_function_identity_arguments(oid) as identity_args
from pg_proc
where proname = 'confirm_payment_from_provider'
  and pronamespace = 'catchmenu_payment'::regnamespace
group by oid;

rollback;
```

Expected result:

- Exactly 1 row returned.
- `identity_args` matches the 8-param signature exactly: `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_provider_payment_key text, p_provider_approval_number text, p_approved_amount integer, p_provider_raw_event_id uuid, p_correlation_id text`.

PASS condition: `count(*) = 1` and the identity arguments match the 8-param signature exactly (no `p_locale`).

FAIL condition: 0 rows (both dropped), 2 rows (drop had no effect), or 1 row with the wrong (9-param) signature.

**Note**: This test is run inside its own `BEGIN`/`ROLLBACK` for verification purposes only — the actual `DROP FUNCTION` that ships is the one in `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql` (see `600484_ChangeContract.md`), applied and committed for real via the normal migration path, not left inside a rolled-back transaction.

## 3. Test B — 8 Named-Argument Call No Longer Ambiguous

Purpose: confirm the exact calling convention used by `0038`/`0056` resolves unambiguously once only one overload exists.

Execution shape (run only after the real `0153` migration is applied — not inside a throwaway transaction that also drops the function, since the drop must persist for this test to be meaningful):

```sql
begin;

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := '<test intent id>'::uuid,
  p_provider_payment_key := 'test_key',
  p_provider_approval_number := 'test_approval',
  p_approved_amount := 3500,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600483-testB'
);

rollback;
```

Expected result: no `"function ... is not unique"` error. The call resolves to the single remaining overload and executes (success or a business-logic-level `error_key`, not an overload-resolution error).

PASS condition: the specific error `function catchmenu_payment.confirm_payment_from_provider(...) is not unique` does not occur.

FAIL condition: the ambiguity error still occurs (would indicate the drop did not take effect or a new overload reappeared).

## 4. Test C — First-Ever Full E2E Success Run

Purpose: `confirm_payment_from_provider()` has never been successfully executed end-to-end in this project — every prior attempt hit either the overload ambiguity (8-arg calls) or the independent crashes inside the 9-param version (`600482_Logic.md` §0). This is the first real attempt to run the *canonical, surviving* 8-param version all the way through with a valid, fully-satisfying `payment_intents` row.

Setup (mirrors the exact test data pattern already used and proven to satisfy all `payment_intents`/`orders` constraints in `600480`'s investigation):

```sql
begin;

insert into catchmenu_pos.orders (
  tenant_id, store_id, order_number, order_type, order_status,
  total_amount, discount_amount, final_amount,
  business_day, business_timezone
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  'TEST-600483', 'TAKEOUT', 'CONFIRMED',
  3500, 0, 3500,
  current_date, 'Asia/Seoul'
) returning id \gset ord_

insert into catchmenu_payment.payment_intents (
  tenant_id, store_id, order_id, intent_status,
  payment_method, payment_channel, requested_amount,
  provider_type, idempotency_key, business_day
) values (
  '00000000-0000-0000-0000-000000000001'::uuid,
  '00000000-0000-0000-0000-000000000002'::uuid,
  :'ord_id'::uuid, 'PENDING',
  'CARD', 'CUSTOMER_APP', 3500,
  'TOSS_PAYMENTS', 'test-idem-600483', current_date
) returning id \gset intent_

select catchmenu_payment.confirm_payment_from_provider(
  p_tenant_id := '00000000-0000-0000-0000-000000000001'::uuid,
  p_store_id := '00000000-0000-0000-0000-000000000002'::uuid,
  p_intent_id := :'intent_id'::uuid,
  p_provider_payment_key := 'test_provider_key_600483',
  p_provider_approval_number := 'test_approval_600483',
  p_approved_amount := 3500,
  p_provider_raw_event_id := null,
  p_correlation_id := 'verify-600483-testC'
) as result;

-- inspect the actual persisted row (§5 below)
select intent_id, ledger_entry_type, ledger_status,
       approved_amount, net_amount, provider_type,
       provider_payment_key, provider_approval_number,
       reconciliation_status, kds_release_authorized
from catchmenu_payment.payment_ledger
where intent_id = :'intent_id'::uuid;

select intent_status, confirmed_at
from catchmenu_payment.payment_intents
where id = :'intent_id'::uuid;

rollback;
```

Expected result: the RPC call returns `'success': true` with a `ledger_id`, and does **not** error at any point (no `chk_session_type`-style hard error, no NOT NULL violation, no CHECK violation — all previously seen failure classes in this workpacket series).

PASS condition: RPC returns `success: true`; the `payment_ledger` SELECT returns exactly 1 row.

FAIL condition: any error during the call, or the `payment_ledger` SELECT returns 0 rows.

## 5. Test D — `payment_ledger` Row Value Correctness (Extends Test C)

Purpose: confirm not just "it ran" but "it ran and wrote the right values" — directly checking the fields the Human decision's confidence in `0027` rests on (`600482_Logic.md` §4).

Using the row retrieved in Test C's second SELECT, verify:

| Field | Expected value |
|---|---|
| `intent_id` | equals the test `payment_intents.id` created in setup |
| `ledger_entry_type` | `'APPROVAL'` |
| `ledger_status` | `'APPROVED'` |
| `approved_amount` | `3500` (matches `p_approved_amount`) |
| `net_amount` | `3500` (equals `approved_amount`, since `cancelled_amount`/`refunded_amount` default to `0`) |
| `provider_type` | `'TOSS_PAYMENTS'` (inherited from the `payment_intents` row, not from the RPC call directly) |
| `provider_payment_key` | `'test_provider_key_600483'` |
| `provider_approval_number` | `'test_approval_600483'` |
| `reconciliation_status` | `'PENDING'` |
| `kds_release_authorized` | `false` (Patent 1 rule — must stay `false` regardless of payment success) |

Also verify the `payment_intents` row: `intent_status = 'CONFIRMED'`, `confirmed_at is not null`.

PASS condition: every field above matches exactly.

FAIL condition: any field mismatch — in particular, `kds_release_authorized` must never be `true` from this function alone (that would be a Patent 1 design violation, not just a data bug).

## 6. Static Boundary Verification

Run read-only source checks after implementation:

```powershell
git status --short -- sql/migrations/
git diff -- sql/migrations/0027_create_payment_intent_rpc.sql
git diff -- sql/migrations/0038_create_toss_webhook_processor_rpc.sql
git diff -- sql/migrations/0056_create_van_integration_rpc.sql
git diff -- sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql
```

Expected diff boundary:

- Exactly one new file: `sql/migrations/0153_drop_confirm_payment_provider_legacy_overload.sql`.
- `0027`/`0038`/`0056`/`0063` — **zero diff, all four**. `0063`'s `confirm_payment_from_provider` definition text remains physically present in that file (it is a historical migration, not edited) but is superseded live by the `DROP FUNCTION` in `0153`.

## 7. Acceptance Criteria

This TestPlan passes if:

1. Exactly one `confirm_payment_from_provider()` overload exists live, matching the 8-param signature (Test A).
2. `0038`/`0056`'s exact calling convention no longer triggers `"is not unique"` (Test B).
3. `confirm_payment_from_provider()` completes a full successful run for the first time in this project's history (Test C).
4. The resulting `payment_ledger` row and `payment_intents` update are field-for-field correct, including `kds_release_authorized = false` (Test D).
5. `0027`/`0038`/`0056`/`0063` show zero diff; only `0153` is new (§6).
6. `mark_payment_uncertain()`/`authorize_kds_release()` are not modified, called, or referenced by any change in this workpacket.
