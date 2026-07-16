# 600644_ChangeContract.md

Status: Draft
Lifecycle: ChangeContract
Stage: 2 Change Contract
Owner: Codex
Revision: 2 (Claude Code, 2026-07-16) — corrected §1.6's miscited "§24" reference to the actual established in-place-migration precedent, and synced §4 with 600643's added test coverage, per independent verification findings
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## §0 Summary

This ChangeContract approves a narrow recovery of the waiting-call contract.

The approved design keeps two public entrypoints:

- `catchmenu_pos.call_waiting_customer()` — designated session call / recall.
- `catchmenu_pos.call_next_waiting_customer()` — automatic next waiting-session selection.

Both public functions share one internal helper:

- `catchmenu_pos._record_waiting_call()`

The legacy `0050` function `catchmenu_pos.call_next_waiting()` is dropped.

The canonical call-expiry setting is:

- `catchmenu_store.store_settings.wait_call_expire_minutes`

The old setting:

- `catchmenu_store.store_settings.no_show_auto_expire_minutes`

is not dropped. It is marked deprecated by COMMENT only.

## §1 Allowed Changes

### §1.1 `0115_create_waiting_pipeline_rpc.sql`

Allowed:

- Modify only the `catchmenu_pos.call_waiting_customer()` function body.
- Preserve the existing `0115` function name and signature:

```sql
catchmenu_pos.call_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_session_id uuid,
  p_table_number text default null,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

Required behavior:

- allow `WAITING`,
- allow `ARRIVAL_PENDING` as recall,
- reject `SEATED`, `COMPLETED`, and other non-callable states,
- compute `expires_at` from `store_settings.wait_call_expire_minutes`,
- call `_record_waiting_call()`,
- do not write `called_at`,
- do not write `call_count`,
- do not write `table_number`,
- do not read `order_sessions.pre_order_amount`.

### §1.2 New internal helper

Allowed:

```sql
catchmenu_pos._record_waiting_call(...)
```

Required role:

- internal shared implementation for waiting-call state update,
- update `order_sessions.session_status` to `ARRIVAL_PENDING`,
- update `order_sessions.expires_at`,
- insert `session_events.event_type = 'customer_called'`,
- insert the corresponding `catchmenu_ledger.events` row,
- preserve notification behavior from the `0115` call path where applicable,
- return a JSON response used by both public functions.

Direct standalone helper testing is not required; public function tests cover it.

### §1.3 New public automatic-call function

Allowed:

```sql
catchmenu_pos.call_next_waiting_customer(
  p_tenant_id uuid,
  p_store_id uuid,
  p_actor_id uuid default null,
  p_locale text default 'ko',
  p_correlation_id text default null
)
```

Required behavior:

- select only `WAITING` sessions,
- select the earliest session by the confirmed queue ordering,
- use `FOR UPDATE SKIP LOCKED`,
- call `_record_waiting_call()`,
- return `no_waiting_session_found` when no candidate exists.

### §1.4 Legacy function DROP

Allowed:

```sql
drop function if exists catchmenu_pos.call_next_waiting(
  uuid, uuid, text, uuid, uuid, text
);
```

The exact signature must be rechecked before Stage 4 execution. If the live signature differs, Stage 4 must stop and report rather than guessing.

### §1.5 Store settings COMMENT

Allowed:

```sql
comment on column catchmenu_store.store_settings.no_show_auto_expire_minutes
  is 'DEPRECATED (600640): wait_call_expire_minutes로 대체됨. 사용처 없음. 별도 정리 워크패킷에서 DROP 검토.';
```

No DROP is allowed for this column.

### §1.6 Forward migration / already-applied source sync

Allowed implementation shape:

- create a new forward migration for new helper/function/drop/comment; and
- if the repository requires already-applied source files to remain canonical, update `0115_create_waiting_pipeline_rpc.sql` with the corrected `call_waiting_customer()` body using the established in-place function correction procedure (precedent: `600584_ChangeContract_Payment_Confirm_Cancel_State_Machine_Fix.md` §2.2 — modify source, recalculate the CRLF-normalized checksum, update `catchmenu_meta.migration_history`, re-execute the live function body, verify with `pg_get_functiondef()` that the live body actually changed). Note: this procedure is established project precedent (also used in `600550`/`600560`/`600570`/`601020`), not a numbered rule in `000701_Guide_Controlled_AI_Development_Pipeline.md` — §24 there is "Lightweight Verification-Bugfix Track," an unrelated track, and must not be cited for this procedure.

Stage 4 must explicitly report which path was used.

## §2 Forbidden Changes

The following are forbidden in this workpacket:

1. Editing `sql/migrations/0118_create_schema_validation_update.sql`.
   - `0118` cron correction belongs to `600630` / `600632`.

2. Editing `confirm_arrival()` in `0115_create_waiting_pipeline_rpc.sql`.
   - Its phantom columns remain a separate Open Item.

3. Adding schema columns.
   - Do not add `order_sessions.called_at`.
   - Do not add `order_sessions.call_count`.
   - Do not add `order_sessions.table_number`.
   - Do not add `order_sessions.pre_order_amount`.

4. Dropping `store_settings.no_show_auto_expire_minutes`.
   - COMMENT-only deprecation is allowed.
   - physical DROP is deferred.

5. Changing KDS no-show grace policy.
   - That belongs to `600630` / `600632`.

6. Editing payment/refund/KDS unrelated workpackets.

7. Editing Flutter/runtime files.

8. Implementing Staff app UI.

9. Implementing no-show blacklist/customer-level penalty system.

## §3 Required Implementation Rules

### §3.1 Source of truth

The implementation must use:

- `session_events` as source of truth for call occurrence and count,
- `order_sessions.expires_at` as call-expiry snapshot,
- `store_settings.wait_call_expire_minutes` as expiry duration source,
- `orders.final_amount` as optional pre-order amount source when needed,
- `p_table_number` only as transient response/event/notification payload value.

### §3.2 State gate

`call_waiting_customer()`:

- must allow `WAITING`,
- must allow `ARRIVAL_PENDING`,
- must reject non-callable states.

`call_next_waiting_customer()`:

- must select only `WAITING`,
- must not select `ARRIVAL_PENDING`.

### §3.3 Concurrency

`call_next_waiting_customer()` must use row locking with `SKIP LOCKED` so concurrent automatic calls do not select the same waiting session.

### §3.4 Event consistency

Both public paths must create the same canonical `customer_called` session event shape through `_record_waiting_call()`.

Derived call count must be based on:

```sql
count(*)
from catchmenu_pos.session_events
where session_id = ...
  and event_type = 'customer_called'
```

No physical `call_count` column may be introduced.

## §4 Test Requirements

Stage 4 must execute `600643_TestPlan.md` in full.

Required coverage includes:

- `call_waiting_customer()` `WAITING` success,
- `call_waiting_customer()` `ARRIVAL_PENDING` recall success,
- rejection for non-callable states,
- re-snapshot of `expires_at` on recall,
- proof that `table_number` is not stored on `order_sessions`,
- `call_next_waiting_customer()` automatic selection,
- `call_next_waiting_customer()` `pre_order_amount`/`has_pre_order` sourced from `orders.final_amount` (not `order_sessions.pre_order_amount`),
- concurrent automatic selection with `SKIP LOCKED`,
- no-waiting-session behavior,
- `session_events` `customer_called` rows from both paths,
- derived `call_count` correctness within a single path AND across paths (`call_next_waiting_customer()` auto-call followed by a `call_waiting_customer()` recall on the same session),
- store-specific `wait_call_expire_minutes`,
- `no_show_auto_expire_minutes` COMMENT deprecation,
- boundary zero diff for `0118`, `confirm_arrival()`, and unrelated files.

## §5 Stop Conditions

Stage 4 must STOP and report if any of the following occur:

1. The live `call_next_waiting()` signature differs from the DROP signature and cannot be safely identified.
2. `session_events` does not allow `customer_called`.
3. `order_sessions.expires_at` is missing.
4. `store_settings.wait_call_expire_minutes` is missing.
5. Implementing the design appears to require a new schema column not listed in §1.
6. Fixing `0118` or `confirm_arrival()` becomes necessary to make this workpacket pass.
7. A new error catalog key is required but not already available.
8. `SKIP LOCKED` cannot be used in the automatic call path.

## §6 Open Items Carried Forward

The following Open Items remain outside this ChangeContract:

1. `0118` cron correction:
   - remove or redesign `called_at`,
   - remove or redesign `no_show_at`,
   - remove or redesign `cancel_reason`,
   - align cron expiry with `wait_call_expire_minutes`.

2. `600630` / `600632` BLOCKED status:
   - this workpacket must pass Stage 4 before no-show redesign proceeds.

3. `confirm_arrival()` phantom columns:
   - `table_number`,
   - `arrival_confirmed_at`,
   - `pre_order_amount`.

4. Physical cleanup of `no_show_auto_expire_minutes`.

5. Final name review for `call_next_waiting_customer()` if Human wants a different public RPC name.

6. Staff app / Flutter implementation.

7. Non-waiting no-show types:
   - pickup,
   - reservation,
   - group/catering,
   - delivery contact failure.

8. Customer-level no-show blacklist/penalty system.

## §7 Human Boundary Approval

Stage 4 may proceed only after all three boxes are checked:

☑ I approve the call_waiting_customer() recovery scope in 0115. (2026-07-16)
☑ I approve creating _record_waiting_call() and call_next_waiting_customer(), and dropping legacy call_next_waiting().
☑ I approve COMMENT-only deprecation of no_show_auto_expire_minutes with no schema-column additions and no physical DROP.

## §8 Approval State

Current approval state: APPROVED (2026-07-16, 삼중검증 통과 확인 후)

No implementation may proceed until §7 is checked by Human.
