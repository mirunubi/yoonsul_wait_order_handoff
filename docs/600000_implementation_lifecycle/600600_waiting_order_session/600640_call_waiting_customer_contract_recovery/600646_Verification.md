# 600646_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5 Verification / Stage 6 Evidence
Owner: Codex
Last Updated: 2026-07-16

## Change ID

`call_waiting_customer_contract_recovery`

## 1. Verification Summary

The implementation was verified through independent Cursor, Antigravity, and Claude Code review/execution evidence, excluding original Stage 4 author Codex per the project’s independent-verification rule.

Final result: PASS.

All three independent validators reported PASS across the twelve TestPlan areas for `600643_TestPlan.md`, using separate test data and independent execution paths.

Codex additionally confirmed the local live state during Stage 4 handoff:

- `0160_call_waiting_customer_contract_recovery.sql` applied successfully,
- `call_next_waiting()` was dropped,
- `_record_waiting_call()`, `call_waiting_customer()`, and `call_next_waiting_customer()` exist,
- `call_next_waiting_customer()` contains `SKIP LOCKED`,
- no direct `order_sessions.pre_order_amount` reference remains,
- `no_show_auto_expire_minutes` is COMMENT-deprecated but still physically present.

## 2. Application Evidence

`tools/apply_migrations.py` applied the forward migration:

```text
APPLY 0160_call_waiting_customer_contract_recovery.sql ...
OK    0160_call_waiting_customer_contract_recovery.sql  (applied)
All sequence-numbered migrations applied or already up to date.
```

`catchmenu_meta.migration_history` recorded:

```text
filename                                          | success | has_checksum | applied_at
--------------------------------------------------+---------+--------------+-------------------------------
0160_call_waiting_customer_contract_recovery.sql  | t       | t            | 2026-07-16 03:20:38.472951+00
```

## 3. Live Function Inventory

Post-implementation live function inventory:

```text
_record_waiting_call
call_next_waiting_customer
call_waiting_customer
```

Legacy function inventory:

```text
call_next_waiting: zero rows
```

Token checks:

```text
has_skip_locked                 > 0
bad_pre_order_ref               = 0
call_waiting_uses_expire_setting > 0
```

## 4. TestPlan Coverage Result

The twelve TestPlan areas were verified as PASS:

| Area | Result | Evidence summary |
|---|---:|---|
| §1 function/store-setting inventory | PASS | New helper/new public function exist; legacy `call_next_waiting()` absent; settings columns present. |
| §2 designated `call_waiting_customer()` first call / recall / rejection | PASS | `WAITING` and `ARRIVAL_PENDING` succeeded; `SEATED` and `COMPLETED` rejected through existing error keys. |
| §3 table/pre-order handling for designated path | PASS | `table_suggestion` returned in payload only; `pre_order_amount` came from linked `orders.final_amount`. |
| §4 automatic `call_next_waiting_customer()` selection | PASS | Earliest WAITING session selected; no-waiting case returned `no_waiting_session_found`. |
| §4.3 automatic pre-order amount source | PASS | `has_pre_order=true`; `pre_order_amount` matched linked `orders.final_amount`. |
| §5 concurrency / `SKIP LOCKED` | PASS | Two concurrent sessions selected different waiting sessions. |
| §6 call-count derivation | PASS | `call_count` derived from `session_events` count. |
| §6.2 cross-path accumulation | PASS | Auto call followed by designated recall produced two `customer_called` events and `call_count=2`. |
| §7 store-specific `wait_call_expire_minutes` | PASS | Explicit store setting was reflected in `expires_at` snapshot. |
| §7.1 deprecated comment check | PASS | `no_show_auto_expire_minutes` COMMENT contains `DEPRECATED`; column still exists. |
| §8 event and ledger consistency | PASS | `customer_called` event rows carried correct `from_status`/`to_status` and payload. |
| §9-§10 boundary/schema checks | PASS | Legacy function dropped, replacement exists, four phantom columns absent from `order_sessions`. |

## 5. Key Runtime Results

Designated call on `WAITING`:

```text
success=true
session_status=ARRIVAL_PENDING
call_count=1
table_suggestion=T-51
```

Designated recall on `ARRIVAL_PENDING`:

```text
success=true
call_count=1 for the first recall event on that session
```

Rejected states:

```text
SEATED    -> waiting_already_seated
COMPLETED -> waiting_not_callable
```

Automatic pre-order path:

```text
has_pre_order=true
pre_order_amount=12345
source=orders.final_amount
```

Designated pre-order path:

```text
has_pre_order=true
pre_order_amount=7777
source=orders.final_amount
```

Cross-path accumulation:

```text
event 1: WAITING -> ARRIVAL_PENDING
event 2: ARRIVAL_PENDING -> ARRIVAL_PENDING
customer_called_count=2
```

SKIP LOCKED concurrency:

```text
job1 selected session ...661
job2 selected session ...662
```

Schema boundary:

```text
phantom_column_count=0
```

## 6. Methodology Notes from Independent Verification

### 6.1 `now()` fixed within a transaction

Claude Code initially observed an apparent recall `expires_at` issue while testing inside one transaction.

It then identified the PostgreSQL behavior that `now()` is transaction-stable, so multiple calls inside the same transaction can legitimately share the same timestamp. Claude Code reran the expiry re-snapshot check in separate transactions and confirmed the implementation behavior was correct.

This was a verification-methodology correction, not an implementation defect.

### 6.2 `store_settings` had no live row

Claude Code also found that `catchmenu_store.store_settings` had zero live rows for the test store at the start of its independent store-setting verification.

It then inserted an explicit test settings row and verified that a `wait_call_expire_minutes = 42` setting was reflected in the computed `expires_at` snapshot.

This was also a verification-methodology correction, not an implementation defect.

## 7. Boundary Verification

Boundary checks passed:

- `0160_call_waiting_customer_contract_recovery.sql` was added.
- `0115_create_waiting_pipeline_rpc.sql` was not edited in this implementation.
- `0118_create_schema_validation_update.sql` was not edited.
- `confirm_arrival()` was not edited.
- No new schema column was added.
- `no_show_auto_expire_minutes` was not dropped.
- Flutter/runtime files were not edited.

## 8. Cleanup Verification

Stage 4 rollback/cleanup checks confirmed no persistent test rows from Codex’s local verification remained:

```text
remaining_test_sessions=0
remaining_test_orders=0
remaining_store_settings=0
```

Independent validators likewise reported using isolated, separate test data.

## 9. Verification Result

PASS.

The implementation satisfies `600643_TestPlan.md` and the approved `600644_ChangeContract.md` scope.
