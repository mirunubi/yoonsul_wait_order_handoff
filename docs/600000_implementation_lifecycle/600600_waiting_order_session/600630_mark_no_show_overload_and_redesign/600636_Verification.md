# 600636_Verification.md

Status: Verified
Lifecycle: Verification
Workpacket: 600630_mark_no_show_overload_and_redesign
Implementation: `0161_mark_no_show_overload_and_redesign.sql`
Date: 2026-07-16

## §1 Verification Scope

This document records Stage 5 verification for the `600630` no-show redesign after `0161_mark_no_show_overload_and_redesign.sql`.

The verification is a triple independent verification result, excluding the original implementer Codex under the project’s §37 rule:

- Cursor
- Antigravity / 안티
- Claude Code

Codex performed the Stage 4 implementation and local execution checks, but the final verification judgement recorded here integrates the three independent reviewers above.

## §2 Implementation Presence

The live database shows the expected function inventory:

```text
catchmenu_pos.apply_no_show_transition(...)
catchmenu_pos.mark_no_show(...)
catchmenu_pos.process_expired_no_shows(...)
catchmenu_kds.expire_no_show_kds_hold(...)
catchmenu_kds.recover_no_show_grace_ticket(...)
```

The legacy 0050 overload count is 0:

```text
legacy_0050_count | 0
```

The migration history records:

```text
0161_mark_no_show_overload_and_redesign.sql | success=true
```

## §3 Error Catalog and Schema Verification

The required six error keys are present:

```text
invalid_trigger_source
kds_ticket_not_found
no_show_grace_already_expired
session_not_markable
ticket_not_recoverable
waiting_session_not_found
```

The new KDS column exists:

```text
catchmenu_kds.kds_tickets.hold_expires_at | timestamp with time zone | nullable
```

`hold_reason` pre-existed and remains:

```text
catchmenu_kds.kds_tickets.hold_reason | text | nullable
```

No schema column beyond `hold_expires_at` was introduced by this workpacket.

## §4 Functional Verification Results

The following TestPlan areas passed across independent verification:

| TestPlan area | Result |
|---|---|
| STAFF no-show transition before expiry | PASS |
| SYSTEM no-show transition before expiry | PASS: rejected with `session_not_markable` |
| SYSTEM no-show transition after expiry | PASS |
| Idempotent retry on already `NO_SHOW` | PASS: returns `idempotent:true` without a second audit record |
| Invalid trigger source | PASS: rejected with `invalid_trigger_source` |
| B+ audit record | PASS: before/after state, `business_day`, and `business_timezone` present; full-row snapshot absent |
| `mark_no_show()` wrapper | PASS |
| KDS grace entry | PASS: `HOLD` ticket enters `NO_SHOW_GRACE` and receives `hold_expires_at` |
| `process_expired_no_shows()` | PASS |
| `expire_no_show_kds_hold()` | PASS |
| `recover_no_show_grace_ticket()` success | PASS |
| expired grace recovery rejection | PASS: `no_show_grace_already_expired` |
| missing ticket rejection | PASS: `kds_ticket_not_found` |
| non-grace ticket rejection | PASS: `ticket_not_recoverable` |
| `SKIP LOCKED` behavior | PASS for both waiting-session batch and KDS grace-expiry batch |
| legacy 0050 overload DROP | PASS |
| `WAITING_SESSION_EXPIRE` cron rewrite | PASS |
| forbidden boundary | PASS |

## §5 Codex Stage 4 Execution Findings Preserved for Audit Trail

During Stage 4, Codex found and corrected two implementation-adjacent facts before final verification:

1. `catchmenu_ledger.audit_records.chk_audit_domain` does not permit `waiting`; it permits `session`. The live function was corrected to use `p_audit_domain := 'session'`.
2. `catchmenu_store.store_settings.no_show_kds_grace_minutes` does not currently exist. To avoid an unapproved schema change, `apply_no_show_transition()` uses a dynamic check: if the column exists in a future schema it can be read, otherwise the function falls back to the approved default behavior.

These adjustments preserved the approved scope: only `hold_expires_at` was added as a schema column.

## §6 Triple Verification Notes

### §6.1 Cursor and Antigravity / 안티

Cursor and 안티 independently verified the function inventory, error-key registration, KDS grace state transitions, recovery error paths, cron replacement, and boundary conditions.

Both verified that the old inline `0118` no-show update no longer references the phantom columns:

- `called_at`
- `no_show_at`
- `cancel_reason`

Both also verified the legacy 0050 overload was removed.

### §6.2 Claude Code third independent verification

Claude Code performed a third independent verification run after Cursor and 안티.

Two methodology findings are recorded because they materially improve future verification discipline:

1. **Parallel verifier data intrusion was detected and handled correctly.** Claude Code observed a `processed_count` larger than expected during its own batch verification. Rather than deleting broad data, Claude Code identified the cause as residual test data from other simultaneous reviewers in the same tenant/store scope. Claude Code cleaned only its own test data and did not touch Cursor/안티 data. This is a concrete example of how concurrent verification against the same live database can contaminate aggregate counts.

2. **Claude Code caught its own setup defect in the KDS grace-entry test.** Its first KDS setup omitted the `orders.session_id` reverse link needed by the approved `apply_no_show_transition()` KDS join path. That caused KDS grace entry not to occur. Claude Code recognized the setup error, rebuilt the test with the correct `orders.session_id` relationship, and then confirmed the expected `NO_SHOW_GRACE` transition.

These were verification-methodology corrections, not implementation defects.

## §7 Concurrency Verification

`SKIP LOCKED` was verified with actual row locks:

- A separate interactive transaction locked one `order_sessions` row with `FOR UPDATE`.
- A concurrent `process_expired_no_shows()` call processed only the unlocked row.
- The locked row remained `ARRIVAL_PENDING`; the unlocked row became `NO_SHOW`.

The same pattern was verified for KDS:

- A separate interactive transaction locked one `kds_tickets` row with `FOR UPDATE`.
- A concurrent `expire_no_show_kds_hold()` call processed only the unlocked ticket.
- The locked ticket remained `HOLD/NO_SHOW_GRACE`; the unlocked ticket became `CANCELLED/NO_SHOW_GRACE_EXPIRED`.

## §8 Boundary Verification

Verified unchanged / out of scope:

- `confirm_arrival()`
- unrelated 0115 functions
- Flutter/runtime code
- schemas other than `kds_tickets.hold_expires_at`

The new work is contained in:

- `sql/migrations/0161_mark_no_show_overload_and_redesign.sql`
- Stage 2/6 documentation for the `600630` workpacket

## §9 Open Verification Caveat

The TestPlan-documented limitation remains: the batch functions’ normal `success:false` and per-row failure-accounting paths were covered, but the true `EXCEPTION WHEN OTHERS` branch was not force-triggered with artificial schema breakage or fault injection. This limitation is accepted and documented because forcing that path would require unsafe or test-only mutation outside the normal verification scope.

## §10 New Open Item Candidate

The same class of issue previously observed in `600640` recurred here: when multiple reviewers validate concurrently against the same live DB, their test rows can affect aggregate outputs such as `processed_count`.

Open Item candidate:

> Future §40.3 verification templates should require verifier-specific test-data prefixes, for example `__test_cursor_...`, `__test_ant_...`, `__test_claude_...`, so concurrent live-DB verification does not cross-contaminate aggregate results.

This is a process improvement item only. It is not part of the `0161` implementation scope.
