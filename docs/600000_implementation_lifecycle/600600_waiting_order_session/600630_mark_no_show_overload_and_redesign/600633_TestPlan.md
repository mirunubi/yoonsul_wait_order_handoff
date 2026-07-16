# 600633_TestPlan.md

Status: Draft
Lifecycle: TestPlan
Stage: 2 Test Plan
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 Purpose

This TestPlan verifies the finalized `600632_Logic.md` design for replacing the ambiguous/broken no-show pipeline with five canonical functions:

1. `catchmenu_pos.apply_no_show_transition()`
2. `catchmenu_pos.mark_no_show()`
3. `catchmenu_pos.process_expired_no_shows()`
4. `catchmenu_kds.expire_no_show_kds_hold()`
5. `catchmenu_kds.recover_no_show_grace_ticket()`

The implementation under test must also:

- drop the legacy `0050` `catchmenu_pos.mark_no_show(uuid, uuid, uuid, text, uuid, text)` overload,
- update the `0118` `WAITING_SESSION_EXPIRE` cron job to call `process_expired_no_shows()` and `expire_no_show_kds_hold()` in store-scoped loops,
- avoid modifying `confirm_arrival()`,
- avoid adding schema columns except the explicitly approved `catchmenu_kds.kds_tickets.hold_expires_at` column.

## §1 Preconditions / Stop-Condition Checks

Before Stage 4 implementation, record the following facts. Any mismatch is a STOP condition for implementation and must be reported.

### §1.1 Existing function inventory

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname in ('catchmenu_pos', 'catchmenu_kds')
  and p.proname in (
    'apply_no_show_transition',
    'mark_no_show',
    'process_expired_no_shows',
    'expire_no_show_kds_hold',
    'recover_no_show_grace_ticket'
  )
order by n.nspname, p.proname, args;
```

Expected before implementation:

- legacy `mark_no_show(...)` overloads may exist,
- the five canonical functions are not yet all present.

Expected after implementation:

- exactly one canonical `catchmenu_pos.mark_no_show(...)` remains,
- `apply_no_show_transition(...)` exists,
- `process_expired_no_shows(...)` exists,
- `expire_no_show_kds_hold(...)` exists,
- `recover_no_show_grace_ticket(...)` exists,
- legacy `0050` `mark_no_show(uuid, uuid, uuid, text, uuid, text)` is gone.

### §1.2 Required schema columns and approved `hold_expires_at` addition

```sql
select table_schema, table_name, column_name, data_type, is_nullable
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_pos', 'order_sessions', 'expires_at'),
  ('catchmenu_pos', 'order_sessions', 'session_status'),
  ('catchmenu_pos', 'order_sessions', 'arrival_reliability_score'),
  ('catchmenu_pos', 'order_sessions', 'pre_order_created_at'),
  ('catchmenu_pos', 'order_sessions', 'business_day'),
  ('catchmenu_pos', 'order_sessions', 'business_timezone'),
  ('catchmenu_kds', 'kds_tickets', 'hold_reason'),
  ('catchmenu_kds', 'kds_tickets', 'hold_expires_at')
)
order by table_schema, table_name, column_name;
```

Expected:

- before implementation, every listed column except `hold_expires_at` must already exist.
- before implementation, `hold_expires_at` may be absent; this is the expected state confirmed by `600632_Logic.md` §4.1.
- Stage 4 must add `hold_expires_at` with `ALTER TABLE catchmenu_kds.kds_tickets ADD COLUMN IF NOT EXISTS hold_expires_at timestamptz`.
- after implementation, `hold_expires_at` must exist and must be nullable `timestamp with time zone`.

If `hold_reason` is absent before implementation, Stage 4 must STOP. `hold_expires_at` absence before implementation is not a STOP condition.

### §1.3 Audit function signature

```sql
select
  n.nspname,
  p.proname,
  pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_audit'
  and p.proname = 'append_audit_record'
order by args;
```

Expected:

- signature matches the call shape required by `600632_Logic.md` §10 / §8.1.
- if the live signature differs, Stage 4 must STOP and report rather than guessing parameter names.

### §1.4 Error catalog / response keys

Confirm all error keys used by the five functions already exist, or the implementation must STOP before adding any new key.

Minimum expected keys include:

- `waiting_session_not_found`
- `session_not_markable`
- `invalid_trigger_source`
- `no_show_grace_already_expired`
- `kds_ticket_not_found`
- `ticket_not_recoverable`

Use the actual implementation’s final key list for the query:

```sql
select error_key, code, error_domain, error_category
from catchmenu_common.error_codes
where error_key in (
  'waiting_session_not_found',
  'session_not_markable',
  'invalid_trigger_source',
  'no_show_grace_already_expired',
  'kds_ticket_not_found',
  'ticket_not_recoverable'
)
order by error_key;
```

## §2 Test A — `apply_no_show_transition()` core behavior

### §2.1 STAFF immediate transition succeeds before `expires_at`

Setup:

1. Create an `ARRIVAL_PENDING` `order_sessions` row with `expires_at > now()`.
2. Include `arrival_reliability_score` and `business_day` / `business_timezone`.
3. Optionally link an order with HOLD KDS tickets for the KDS grace sub-check.

Call:

```sql
select catchmenu_pos.apply_no_show_transition(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<session_id>'::uuid,
  p_trigger_source := 'STAFF',
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-staff-immediate'
);
```

Expected:

- `success = true`.
- `order_sessions.session_status = 'NO_SHOW'`.
- `arrival_reliability_score` is reduced by 20 with lower bound 0.
- `cancelled_at is not null`.
- `expires_at > now()` did not block STAFF transition.
- linked HOLD KDS tickets enter grace state when pre-order exists:
  - `kds_status = 'HOLD'`
  - `hold_reason = 'NO_SHOW_GRACE'`
  - `hold_expires_at is not null`

### §2.2 SYSTEM before expiry is rejected

Setup:

- same as §2.1, but `expires_at > now()`.

Call with:

```sql
p_trigger_source := 'SYSTEM'
```

Expected:

- `success = false`.
- session remains `ARRIVAL_PENDING`.
- no KDS ticket enters `NO_SHOW_GRACE`.
- audit/event rows do not claim a successful no-show transition.

### §2.3 SYSTEM after expiry succeeds

Setup:

- `ARRIVAL_PENDING` session with `expires_at <= now()`.

Call with:

```sql
p_trigger_source := 'SYSTEM'
```

Expected:

- `success = true`.
- session becomes `NO_SHOW`.
- KDS HOLD tickets enter `NO_SHOW_GRACE` if pre-order exists.

### §2.4 Idempotent retry on already `NO_SHOW`

Setup:

- session already has `session_status = 'NO_SHOW'`.

Call `apply_no_show_transition()` again with the same session.

Expected:

- returns a safe/idempotent result according to the final implementation contract.
- does not double-apply `arrival_reliability_score` penalty.
- does not create duplicate KDS grace transitions.
- `600632_Logic.md` §8.1's idempotent branch returns immediately and does not call `append_audit_record()`.
- retry/no-op is distinguished by the response payload field `idempotent: true`.

### §2.5 Invalid trigger source is rejected

Call:

```sql
p_trigger_source := 'INVALID'
```

Expected:

- `success = false`.
- error key is `invalid_trigger_source` or the final approved equivalent.
- no session/KDS mutation occurs.

## §3 Test B — Audit record B+ pattern

For successful STAFF and SYSTEM transitions, verify `catchmenu_audit` records include:

- `before_state.session_status = 'ARRIVAL_PENDING'`,
- `after_state.session_status = 'NO_SHOW'`,
- previous and new `arrival_reliability_score`,
- KDS grace ticket count / ids / expiry when applicable,
- `trigger_source`,
- `reason_code`,
- `business_day`,
- `business_timezone`,
- correlation id.

Use the actual audit table/function output shape from `append_audit_record()`:

```sql
select *
from catchmenu_audit.<audit_table_or_view>
where correlation_id = '<test-correlation-id>'
order by occurred_at desc;
```

Expected:

- before/after state values are not reversed.
- `business_day` / `business_timezone` are copied from `order_sessions`, not recomputed inconsistently.
- full-row snapshots are not adopted and must not be introduced; the approved B+ pattern records only the selected before/after fields from `600632_Logic.md` §8.1.

## §4 Test C — `mark_no_show()` manual wrapper

Setup:

- `ARRIVAL_PENDING` session with `expires_at > now()`.

Call:

```sql
select catchmenu_pos.mark_no_show(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_session_id := '<session_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-mark-no-show'
);
```

Expected:

- success.
- wrapper passes `trigger_source = 'STAFF'`.
- session becomes `NO_SHOW` despite future `expires_at`.
- audit record reports `trigger_source = 'STAFF'`.
- no direct legacy `0050` logic remains active.

## §5 Test D — `process_expired_no_shows()` automatic batch

### §5.1 Normal batch success

Setup:

- create multiple `ARRIVAL_PENDING` sessions:
  - some with `expires_at <= now()`,
  - some with `expires_at > now()`,
  - some not `ARRIVAL_PENDING`.

Call:

```sql
select catchmenu_pos.process_expired_no_shows(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_batch_size := 100,
  p_correlation_id := 'test-600630-process-expired'
);
```

Expected:

- only expired `ARRIVAL_PENDING` sessions become `NO_SHOW`.
- future `expires_at` sessions remain unchanged.
- non-`ARRIVAL_PENDING` sessions remain unchanged.
- each processed row uses `trigger_source = 'SYSTEM'`.
- response reports processed count and failed count.

### §5.2 `SKIP LOCKED` concurrency

Run two concurrent transactions:

1. Session A starts `process_expired_no_shows()` and holds locks on selected rows.
2. Session B starts `process_expired_no_shows()` for the same tenant/store.

Expected:

- the two sessions do not process the same `order_sessions` row.
- locked rows are skipped rather than blocking indefinitely.
- final processed session ids are disjoint.

### §5.3 Per-row failure isolation

Create a batch where one candidate is expected to fail during transition while at least one other candidate should succeed.

Acceptable ways to force the failure must stay within test isolation and must not require schema changes. For example:

- use a row/data condition that causes the core function to return a failure response for one selected candidate, while another remains valid.

Expected:

- one row failure is captured in the batch result.
- other valid rows are still processed.
- the entire batch does not abort because of one failed row.
- audit/error details preserve the failed session id.

Coverage limitation: this test covers the core `success:false` return path and the batch-level per-row failure accounting. It does not force the true `EXCEPTION WHEN OTHERS` / implicit `SAVEPOINT` branch itself, because doing so without schema mutation or artificial fault injection is difficult. If Stage 4 introduces any test-only fault injection, it must use an isolated `__test_` name and be dropped before completion.

## §6 Test E — `expire_no_show_kds_hold()` KDS grace expiry batch

### §6.1 Normal expiry success

Setup:

- create KDS tickets with:
  - `kds_status = 'HOLD'`,
  - `hold_reason = 'NO_SHOW_GRACE'`,
  - `hold_expires_at <= now()`.

Call:

```sql
select catchmenu_kds.expire_no_show_kds_hold(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_batch_size := 100,
  p_correlation_id := 'test-600630-expire-kds-grace'
);
```

Expected:

- matching tickets become `kds_status = 'CANCELLED'`.
- `hold_reason = 'NO_SHOW_GRACE_EXPIRED'`.
- audit record captures before/after KDS state.
- unexpired or non-grace tickets are unchanged.

### §6.2 `SKIP LOCKED` concurrency

Run two concurrent `expire_no_show_kds_hold()` calls against multiple expired grace tickets.

Expected:

- no ticket is expired twice.
- selected ticket ids are disjoint across sessions.
- locked rows are skipped.

### §6.3 Per-row failure isolation

Create a batch with one ticket expected to fail and another expected to succeed.

Expected:

- failed ticket is reported.
- successful tickets still expire.
- function returns a failure count/details without aborting the entire batch.

Coverage limitation: this test covers the expected `success:false` / failure-accounting path for KDS grace expiry. It does not force the true `EXCEPTION WHEN OTHERS` / implicit `SAVEPOINT` branch itself, because doing so without schema mutation or artificial fault injection is difficult. If Stage 4 introduces any test-only fault injection, it must use an isolated `__test_` name and be dropped before completion.

## §7 Test F — `recover_no_show_grace_ticket()` late-arrival recovery

### §7.1 Recovery before grace expiry succeeds

Setup:

- KDS ticket:
  - `kds_status = 'HOLD'`,
  - `hold_reason = 'NO_SHOW_GRACE'`,
  - `hold_expires_at > now()`.

Call:

```sql
select catchmenu_kds.recover_no_show_grace_ticket(
  p_tenant_id := '<tenant_id>'::uuid,
  p_store_id := '<store_id>'::uuid,
  p_kds_ticket_id := '<ticket_id>'::uuid,
  p_actor_id := '<actor_id>'::uuid,
  p_locale := 'ko',
  p_correlation_id := 'test-600630-recover-grace'
);
```

Expected:

- success.
- ticket remains/returns to `kds_status = 'HOLD'`.
- `hold_reason` is cleared or set to the final approved recovered value.
- `hold_expires_at` is cleared or otherwise no longer active.
- audit record captures recovery before/after state.

### §7.2 Expired grace recovery is rejected

Setup:

- `hold_reason = 'NO_SHOW_GRACE'`,
- `hold_expires_at <= now()`.

Expected:

- `success = false`.
- error key is `no_show_grace_already_expired`.
- ticket remains unchanged.

### §7.3 Missing ticket is rejected

Call with a non-existing `p_kds_ticket_id`.

Expected:

- `success = false`.
- error key is `kds_ticket_not_found` or final approved equivalent.
- no mutation.

### §7.4 Non-grace ticket is rejected

Setup:

- ticket exists but `hold_reason <> 'NO_SHOW_GRACE'` or `kds_status <> 'HOLD'`.

Expected:

- `success = false`.
- ticket remains unchanged.

## §8 Test G — Expiry vs recovery concurrency

Run two concurrent transactions on the same grace ticket:

1. `expire_no_show_kds_hold()` attempts to expire the ticket.
2. `recover_no_show_grace_ticket()` attempts to recover the same ticket.

Use two timing variants:

- ticket still within grace at the beginning of both transactions,
- ticket expires just before or during the race window.

Expected:

- only one operation succeeds.
- row locking serializes the update.
- no final state exists where both recovery and expiry are reported as successful.
- final row state matches the one successful operation.

## §9 Test H — Legacy `0050` `mark_no_show()` DROP

Before implementation, record the legacy signature:

```sql
select n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) as args
from pg_proc p
join pg_namespace n on n.oid = p.pronamespace
where n.nspname = 'catchmenu_pos'
  and p.proname = 'mark_no_show'
order by args;
```

After implementation:

- legacy `mark_no_show(uuid, uuid, uuid, text, uuid, text)` is absent.
- canonical `0115`-style `mark_no_show(uuid, uuid, uuid, uuid, text, text)` remains.

## §10 Test I — `0118` cron update

Verify `0118_create_schema_validation_update.sql` / live cron body no longer performs inline phantom-column no-show updates.

Expected cron shape:

1. Store loop calls `catchmenu_pos.process_expired_no_shows(...)`.
2. Store loop calls `catchmenu_kds.expire_no_show_kds_hold(...)`.

Verification queries depend on how the cron body is represented live. At minimum:

```sql
select pg_get_functiondef('<cron_function_signature>'::regprocedure);
```

or inspect the relevant cron job command text if implemented as `pg_cron` command rows.

Expected:

- references to phantom `called_at`, `no_show_at`, `cancel_reason` are removed from the no-show expiry path.
- both batch functions are invoked.
- store-scoped loop is preserved.

## §11 Boundary Verification

### §11.1 Forbidden source files/functions

Verify zero diff for:

- `confirm_arrival()` body,
- the other six unrelated functions in `0115_create_waiting_pipeline_rpc.sql`,
- Flutter/runtime files,
- payment/KDS unrelated pipelines.

### §11.2 Schema-change boundary

Verify the single approved schema-column addition and no more:

```sql
select table_schema, table_name, column_name
from information_schema.columns
where (table_schema, table_name, column_name) in (
  ('catchmenu_kds', 'kds_tickets', 'hold_reason'),
  ('catchmenu_kds', 'kds_tickets', 'hold_expires_at')
)
order by table_schema, table_name, column_name;
```

Expected:

- `hold_reason` existed before implementation and still exists after.
- `hold_expires_at` may be absent before implementation and must exist after implementation.
- the implementation diff may contain only the approved `ALTER TABLE catchmenu_kds.kds_tickets ADD COLUMN IF NOT EXISTS hold_expires_at timestamptz` schema addition.
- no other `ALTER TABLE ... ADD COLUMN` appears in the implementation diff.

### §11.3 Migration/source boundary

Expected modified scope:

- new forward migration or approved already-applied source synchronization for the five functions,
- `0050` legacy function DROP statement,
- `0118` cron body update.

No unapproved file may be changed.

## §12 Acceptance Criteria

PASS requires all of the following:

1. Five canonical functions exist and execute their success paths.
2. `apply_no_show_transition()` enforces STAFF vs SYSTEM gate differences.
3. KDS HOLD tickets enter `NO_SHOW_GRACE` on no-show transition.
4. KDS grace tickets expire to `CANCELLED` / `NO_SHOW_GRACE_EXPIRED`.
5. Grace tickets can be recovered before expiry and rejected after expiry.
6. Batch functions use `SKIP LOCKED`.
7. Batch functions isolate per-row failures.
8. Audit records include B+ before/after state and business day/timezone.
9. Legacy `0050` `mark_no_show()` overload is dropped.
10. `0118` cron calls both batch functions.
11. Forbidden files/functions remain unchanged.
12. The only schema column added in this workpacket is the approved nullable `catchmenu_kds.kds_tickets.hold_expires_at`; no other schema columns are added.
