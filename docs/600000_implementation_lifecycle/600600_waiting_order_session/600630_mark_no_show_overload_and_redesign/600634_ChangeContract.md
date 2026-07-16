# 600634_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 Change Contract
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`mark_no_show_overload_and_redesign`

## §0 Approval Basis

This ChangeContract is based on the finalized `600632_Logic.md` design after `600640_call_waiting_customer_contract_recovery` reached Stage 6 ACCEPT.

This document intentionally uses the `600633` / `600634` numbers for the `600630_mark_no_show_overload_and_redesign` workpacket. The `600643` / `600644` numbers are already occupied by `600640_call_waiting_customer_contract_recovery` and must not be overwritten.

## §1 Allowed Changes

Stage 4 may implement only the following changes.

### §1.1 New canonical core function

Allowed:

- create `catchmenu_pos.apply_no_show_transition(...)`.

Required behavior:

- common core for manual and automatic no-show transition,
- `p_trigger_source = 'STAFF'` allows immediate transition when session is `ARRIVAL_PENDING`,
- `p_trigger_source = 'SYSTEM'` requires `session_status = 'ARRIVAL_PENDING'` and `expires_at <= now()`,
- invalid trigger source is rejected,
- already `NO_SHOW` retry is safe/idempotent,
- applies arrival reliability penalty once,
- moves linked HOLD KDS tickets into `NO_SHOW_GRACE`,
- writes B+ audit record with before/after state and business day/timezone.

### §1.2 Manual wrapper

Allowed:

- create or replace `catchmenu_pos.mark_no_show(...)` using the canonical `0115`-style signature.

Required behavior:

- thin wrapper around `apply_no_show_transition()`,
- passes `p_trigger_source := 'STAFF'`,
- preserves public manual no-show RPC semantics.

### §1.3 Automatic no-show batch

Allowed:

- create `catchmenu_pos.process_expired_no_shows(...)`.

Required behavior:

- selects expired `ARRIVAL_PENDING` sessions,
- uses `FOR UPDATE SKIP LOCKED`,
- processes rows through `apply_no_show_transition()` with `p_trigger_source := 'SYSTEM'`,
- isolates per-row failures,
- returns processed/failed counts and details.

### §1.4 KDS grace expiry batch

Allowed:

- create `catchmenu_kds.expire_no_show_kds_hold(...)`.

Required behavior:

- selects `kds_status = 'HOLD'`,
- requires `hold_reason = 'NO_SHOW_GRACE'`,
- requires `hold_expires_at <= now()`,
- uses `FOR UPDATE SKIP LOCKED`,
- updates to `kds_status = 'CANCELLED'` and `hold_reason = 'NO_SHOW_GRACE_EXPIRED'`,
- isolates per-row failures,
- writes audit record.

### §1.5 KDS grace recovery function

Allowed:

- create `catchmenu_kds.recover_no_show_grace_ticket(...)`.

Required behavior:

- ticket-level recovery only,
- requires `kds_status = 'HOLD'`,
- requires `hold_reason = 'NO_SHOW_GRACE'`,
- requires `hold_expires_at > now()`,
- restores the ticket out of grace state through one symmetric conditional UPDATE,
- rejects expired grace with `no_show_grace_already_expired`,
- rejects missing/non-recoverable tickets without mutation,
- writes audit record.

### §1.6 Legacy `0050` overload DROP

Allowed:

```sql
drop function if exists catchmenu_pos.mark_no_show(
  uuid, uuid, uuid, text, uuid, text
);
```

The exact live signature must be rechecked immediately before Stage 4 execution. If it differs, Stage 4 must STOP and report.

### §1.7 `0118` cron update

Allowed:

- update the `0118` `WAITING_SESSION_EXPIRE` cron path so it calls:
  - `catchmenu_pos.process_expired_no_shows(...)`,
  - `catchmenu_kds.expire_no_show_kds_hold(...)`.

Required behavior:

- preserve store-scoped loop behavior,
- remove inline phantom-column updates from the no-show expiry path,
- call both batch functions per store or through an equivalent store-scoped iteration.

### §1.8 Schema-column boundary

Allowed:

- use existing `order_sessions` and `kds_tickets` columns.
- add the single approved KDS grace expiry column:

```sql
alter table catchmenu_kds.kds_tickets
  add column if not exists hold_expires_at timestamptz;
```

Not allowed:

- adding `hold_reason`,
- adding `no_show_at`,
- adding `called_at`,
- adding `cancel_reason`,
- adding any schema column other than the approved nullable `hold_expires_at`.

This ChangeContract assumes `kds_tickets.hold_reason` already exists. `hold_expires_at` may be absent before Stage 4 and must be created by the approved `ALTER TABLE ... ADD COLUMN IF NOT EXISTS` statement.

## §2 Forbidden Changes

The following are forbidden:

1. Editing `confirm_arrival()`.
2. Editing unrelated functions in `0115_create_waiting_pipeline_rpc.sql`.
3. Editing Flutter/runtime code.
4. Adding schema columns other than the approved nullable `kds_tickets.hold_expires_at`.
5. Extending `kds_status` enum or constraint values.
6. Dropping or renaming `hold_reason` / `hold_expires_at`.
7. Implementing complex late-arrival exception policy for:
   - prepaid refund/re-adjustment,
   - inventory conflict,
   - seat/table reallocation.
8. Implementing no-show blacklist policy.
9. Changing payment/refund/KDS cooking pipelines outside the explicitly allowed KDS grace functions.

## §3 Stop Conditions

Stage 4 must stop and report if any of the following are true:

1. `600634_ChangeContract.md` Human Approval checkboxes are not all checked.
2. The live legacy `0050` `mark_no_show()` signature differs from the DROP signature in §1.6.
3. `catchmenu_kds.kds_tickets.hold_reason` is absent.
4. `catchmenu_pos.order_sessions.expires_at` is absent.
5. `catchmenu_pos.order_sessions.business_day` or `business_timezone` is absent.
6. `catchmenu_audit.append_audit_record()` signature differs from the call shape expected by `600632_Logic.md`.
7. Existing error catalog keys required by the implementation are absent and a new key would be needed.
8. `FOR UPDATE SKIP LOCKED` cannot be used in the automatic batch functions.
9. Implementing the design requires modifying `confirm_arrival()` or unrelated `0115` functions.
10. Implementing the design requires schema changes beyond the approved nullable `kds_tickets.hold_expires_at` addition.
11. `0118` cron representation cannot be updated safely without changing unrelated scheduler semantics.

## §4 Required Verification

Stage 4 must execute `600633_TestPlan.md` in full.

Required highlights:

- all five functions success paths,
- STAFF immediate transition before expiry,
- SYSTEM rejection before expiry,
- SYSTEM success after expiry,
- idempotent retry on already `NO_SHOW`,
- invalid trigger source rejection,
- B+ audit before/after state and business day/timezone,
- `process_expired_no_shows()` `SKIP LOCKED` and per-row failure isolation,
- `expire_no_show_kds_hold()` `SKIP LOCKED` and per-row failure isolation,
- `recover_no_show_grace_ticket()` success/rejection paths,
- expiry vs recovery concurrency,
- legacy `0050` `mark_no_show()` DROP,
- `0118` cron calls both batch functions,
- boundary zero diff for forbidden areas.

## §5 Open Items Carried Forward

The following `600632_Logic.md` Open Items are not resolved by this ChangeContract and remain carried forward:

- (e) exact grace duration setting value / operational tuning.
- (f) seat/queue release side effects beyond `session_status = 'NO_SHOW'`.
- (g) user/staff-facing UI messaging.
- (h) reporting/dashboard interpretation of grace, expiry, and recovery.
- (j) whether STAFF/SYSTEM penalty policy should diverge in future operations.
- (l) whether `mark_no_show()` needs explicit role/permission checks inside the function body.
- (m) audit-log cold-data archiving / partitioning strategy.
- (n) complex recovery exceptions: prepaid adjustment, inventory conflict, seat reallocation.
- (o) `log_diagnostic()` currently has a defensive gap when an unregistered `error_key` / NULL severity path causes `diagnostic_logs.is_recoverable` to be computed as NULL and violate its NOT NULL constraint. This workpacket avoids the issue by pre-registering the required no-show error keys, but the generic `log_diagnostic()` hardening remains a separate follow-up candidate.

The following are explicitly no longer Open Items for this ChangeContract:

- including `expire_no_show_kds_hold()` in scope,
- including `recover_no_show_grace_ticket()` in scope,
- unblocking after `600640`,
- resolving the old `0118` / manual-side-effect inconsistency.

## §6 Boundary Reporting Requirements

Stage 4 output must report:

1. full implementation diff,
2. whether a new forward migration or already-applied source sync path was used,
3. live function inventory before/after,
4. legacy overload DROP confirmation,
5. `0118` cron before/after relevant snippet,
6. all TestPlan results,
7. explicit zero-diff confirmation for forbidden files/functions,
8. `git diff --check` result.

## §7 Human Boundary Approval

Stage 4 may proceed only after all three boxes are checked by Human:

☑ I approve the five-function no-show redesign scope (apply_no_show_transition, mark_no_show, process_expired_no_shows, expire_no_show_kds_hold, recover_no_show_grace_ticket).
☑ I approve dropping the legacy 0050 mark_no_show(uuid, uuid, uuid, text, uuid, text) overload.
☑ I approve updating the 0118 cron path to call process_expired_no_shows() and expire_no_show_kds_hold() while making no schema-column changes other than the approved hold_expires_at addition.(2026-07-16)

## §8 Approval State

Current approval state: APPROVED. (2026-07-16)

No implementation may proceed until §7 is checked by Human.
