# 600543_TestPlan_Mark_Payment_Uncertain_Overload.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 (Claude chat role)
Owner: TBD
Last Updated: 2026-07-14

## Change ID

`mark_payment_uncertain_overload_ambiguity`

## Authority

- `600541_Overview_Mark_Payment_Uncertain_Overload.md`
- `600542_Logic_Mark_Payment_Uncertain_Overload.md`

## Final Design Under Test

`catchmenu_payment.mark_payment_uncertain()` keeps the `0027` 5-param function as the single canonical function and drops the `0063` 6-param overload.

The implementation should create a new forward migration containing only:

```sql
drop function if exists catchmenu_payment.mark_payment_uncertain(
  uuid, uuid, uuid, text, text, text
);
```

No source mutation to `0027`, `0063`, `0070`, or any runtime caller is part of this workpacket.

## §0 Preflight Checks

### §0.1 Approval / boundary checks

Before implementation:

1. Confirm `600544_ChangeContract_Mark_Payment_Uncertain_Overload.md` Human Approval checkboxes are checked.
2. Confirm the next migration number is available before creating the forward migration.
3. Confirm no `.sql` file other than the new migration is edited.
4. Confirm `0027_create_payment_intent_rpc.sql` is not edited.
5. Confirm `0063_patch_core_rpc_i18n_diagnostics.sql` is not edited.
6. Confirm `0070_create_flutter_bootstrap_rpc.sql` is not edited.

### §0.2 Live pre-state confirmation

Run:

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain'
order by args;
```

Expected pre-state:

| Expected overload | Source |
|---|---|
| `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text` | `0027` canonical |
| `p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_locale text, p_correlation_id text` | `0063` overload to drop |

## §1 Test A — DROP leaves exactly one overload

After applying the migration, run:

```sql
select
  count(*) as overload_count
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain';
```

Expected:

```text
overload_count = 1
```

Then run:

```sql
select
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_payment'
  and p.proname = 'mark_payment_uncertain';
```

Expected surviving signature:

```text
p_tenant_id uuid, p_store_id uuid, p_intent_id uuid, p_uncertain_reason text, p_correlation_id text
```

Failure conditions:

- Count remains `2`.
- Surviving function is the 6-param `p_locale` overload.
- No overload remains.

## §2 Test B — named-argument ambiguity disappears

Run a no-row/invalid-id call using the canonical 5 named arguments only:

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := gen_random_uuid(),
  p_store_id := gen_random_uuid(),
  p_intent_id := gen_random_uuid(),
  p_uncertain_reason := 'test ambiguity removed',
  p_correlation_id := 'test-600543-ambiguity'
);
```

Expected:

- The previous PostgreSQL ambiguity error must not occur:

```text
function catchmenu_payment.mark_payment_uncertain(...) is not unique
```

- The call should resolve to the remaining 5-param function.
- Because the IDs are intentionally nonexistent, the expected business result is the `0027` function's `intent_not_found` JSON response, not an ambiguity error.

Expected response shape:

```json
{
  "success": false,
  "error_key": "intent_not_found"
}
```

Failure conditions:

- `"is not unique"` still occurs.
- The call resolves to a different function signature.
- The function fails before returning `intent_not_found` for nonexistent IDs.

## §3 Test C — 0027 E2E first real execution

This test confirms the surviving 5-param function can execute against a real dummy `payment_intents` row.

Use a transaction and end with `ROLLBACK`.

### §3.1 Pre-check: `intent_status` allowed values

Run:

```sql
select pg_get_constraintdef(oid)
from pg_constraint
where conname = 'chk_intent_status';
```

Expected allowed list currently includes:

```text
CREATED, PENDING, PROCESSING, CONFIRMED, FAILED, CANCELLED, EXPIRED
```

Important interpretation:

- `0027` uses `intent_status = 'PROCESSING'`.
- `0027` does not require `UNCERTAIN` to be allowed.
- Therefore the `0063` `UNCERTAIN` CHECK failure is not expected in the surviving canonical function.

### §3.2 Real execution skeleton

Within `BEGIN; ... ROLLBACK;`, create the minimal valid upstream rows needed by `catchmenu_payment.payment_intents`:

1. Reuse the seeded tenant/store if available:

```text
tenant_id = 00000000-0000-0000-0000-000000000001
store_id  = 00000000-0000-0000-0000-000000000002
```

2. Insert a dummy `catchmenu_pos.orders` row.
3. Insert a dummy `catchmenu_payment.payment_intents` row with:

```text
intent_status = PROCESSING
payment_method = CARD
payment_channel = STAFF_POS
provider_type = TOSS_PAYMENTS
requested_amount > 0
business_day = current_date
business_timezone = Asia/Seoul
```

4. Call:

```sql
select catchmenu_payment.mark_payment_uncertain(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_intent_id := '<intent_id>'::uuid,
  p_uncertain_reason := '600543 E2E test',
  p_correlation_id := 'test-600543-e2e'
);
```

Expected:

- No overload ambiguity.
- No `chk_intent_status` failure.
- The function returns success JSON from `0027`.
- Returned fields include:

```text
success = true
intent_id = <intent_id>
session_status = PAYMENT_UNCERTAIN
kds_blocked = true
exception_id is not null
requires_human_resolution = true
message_code = payment_uncertain_kds_blocked
audit_id is not null
```

### §3.3 Post-call state checks inside the same transaction

Check:

```sql
select intent_status
from catchmenu_payment.payment_intents
where id = '<intent_id>'::uuid;
```

Expected:

```text
PROCESSING
```

This is an accepted carried-forward defect, not a failure of this workpacket. See §7 Open Items in `600542_Logic_Mark_Payment_Uncertain_Overload.md`.

Check:

```sql
select exception_code, exception_domain, exception_type, exception_severity, exception_status
from catchmenu_ledger.exceptions
where subject_type = 'payment_intent'
  and subject_id = '<intent_id>'::uuid;
```

Expected:

- One row exists.
- `exception_code` is not null.
- `exception_domain = 'payment'`.
- `exception_type = 'payment_uncertain'`.
- `exception_severity = 'CRITICAL'`.
- `exception_status = 'OPEN'`.

Check:

```sql
select event_domain, event_type, subject_type, subject_id, caused_by_type
from catchmenu_ledger.events
where subject_type = 'payment_intent'
  and subject_id = '<intent_id>'::uuid
  and event_type = 'payment_uncertain';
```

Expected:

- One row exists.
- `event_domain = 'payment'`.
- `caused_by_type = 'SYSTEM'`.

End with:

```sql
ROLLBACK;
```

## §4 Test D — `exceptions.exception_code` NOT NULL distinction

This test distinguishes the 0063-only defect from the surviving 0027 function.

### §4.1 0063 defect record

Confirmed source fact from `600542_Logic_Mark_Payment_Uncertain_Overload.md`:

- `0063` inserts into `catchmenu_ledger.exceptions` without `exception_code`.
- Live schema has `exception_code text not null` with no default.
- Therefore `0063` would fail at this statement if it reached it.

### §4.2 0027 canonical check

Inspect `0027_create_payment_intent_rpc.sql`:

```sql
insert into catchmenu_ledger.exceptions (
  tenant_id, store_id,
  exception_code, exception_domain, exception_type,
  ...
) values (
  p_tenant_id, p_store_id,
  'PAY-UNCERTAIN-' || extract(epoch from now())::bigint::text,
  'payment', 'payment_uncertain',
  ...
)
```

Expected:

- The surviving 0027 function does not share the `exception_code` omission.
- The §3 E2E query confirms the inserted exception row has a non-null `exception_code`.

Failure condition:

- E2E execution fails with `null value in column "exception_code"`.

## §5 Boundary Verification

Run:

```powershell
git diff --name-only
```

Expected implementation diff:

- New migration file only, plus later Module/Verification/Audit documents if the implementation stage writes them.
- No edits to:
  - `sql/migrations/0027_create_payment_intent_rpc.sql`
  - `sql/migrations/0063_patch_core_rpc_i18n_diagnostics.sql`
  - `sql/migrations/0070_create_flutter_bootstrap_rpc.sql`
  - application runtime files
  - Flutter files

Run:

```powershell
git diff --check
```

Expected:

```text
PASS
```

## §6 Acceptance Criteria

This workpacket can pass Stage 5 only if:

1. `mark_payment_uncertain()` overload count is exactly `1`.
2. The surviving overload is the 0027 5-param function.
3. The prior named-argument ambiguity error is gone.
4. A real dummy E2E call of the surviving 0027 function succeeds inside a rollback transaction.
5. `0027` is confirmed not to have the `exceptions.exception_code` NOT NULL defect.
6. No forbidden file is modified.
7. `git diff --check` passes.

## §7 Known Non-Blocking Open Items

These are not acceptance blockers for this workpacket:

- `0027` keeps `payment_intents.intent_status = 'PROCESSING'`, so `0070` dashboard logic that searches for `UNCERTAIN` still cannot detect this state.
- `0027` does not provide i18n response formatting or CRITICAL diagnostic logging.
- No real application/runtime caller currently triggers `mark_payment_uncertain()`.
- `authorize_kds_release()` overload cleanup remains separate.

