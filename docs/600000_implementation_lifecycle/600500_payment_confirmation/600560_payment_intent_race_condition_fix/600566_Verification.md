# 600566_Verification.md

Status: Verified
Lifecycle: Verification
Stage: 5
Owner: Cursor + Antigravity
Date: 2026-07-16

## Verification Result

Final result: **PASS — complete dual independent verification.**

Cursor and Antigravity independently verified the `0159` implementation and repeated the race test using different test order IDs and helper names. Both confirmed that concurrent calls now return the same `payment_intents.id` and leave only one row.

## 1. Stage 4 Execution Evidence

### Duplicate Pair Precheck

```text
17f67f52-e80d-47e9-a5ec-7e351a4e6dcf | OBS-33333333-...-POS_SYNTHESIZED-924f18176391 | earlier created_at
283f3973-d547-4ea9-b4ad-b83b1c62b8cc | OBS-33333333-...-POS_SYNTHESIZED-924f18176391 | later created_at
```

### FK Recheck

All five loser-row FK reference checks returned 0:

```text
payment_ledger.intent_id                | 0
payment_events.intent_id                | 0
reconciliation_cases.intent_id          | 0
toss_payments.intent_id                 | 0
toss_payment_requests.payment_intent_id | 0
```

### Negative UNIQUE Test

Before cleanup, the constraint correctly failed:

```text
ERROR:  could not create unique index "uq_payment_intents_idempotency_key"
DETAIL:  Key (idempotency_key)=(OBS-33333333-3333-3333-3333-333333333333-POS_SYNTHESIZED-924f18176391) is duplicated.
```

### Final Constraint

```text
uq_payment_intents_idempotency_key | UNIQUE (idempotency_key)
```

### Function Body

`pg_get_functiondef()` confirmed:

| Check | Result |
|---|---|
| `on conflict (idempotency_key) do update` | PASS |
| `set updated_at = now()` | PASS |
| `returning id into v_intent_id` | PASS |
| `pg_sleep` absent | PASS |
| `__test_` absent from production body | PASS |
| `__pay_con` absent | PASS |
| `slow_resolve` absent | PASS |
| `OBS-RACE` absent | PASS |
| `INTRODUCE RACE` absent | PASS |

## 2. Cursor Verification Summary

Cursor independently reran the post-fix race scenario with its own test order ID and helper naming. Result:

- two overlapping sessions both completed;
- both returned the same `intent_id`;
- final count for the tested `idempotency_key` was 1;
- the `uq_payment_intents_idempotency_key` constraint remained present;
- forbidden payment pipeline files remained out of scope.

Cursor also confirmed that the old known duplicate pair was reduced to the single winner row.

## 3. Antigravity Verification Summary

Antigravity independently reran the post-fix race scenario with a different test order ID and helper naming. Result:

- two overlapping sessions both completed;
- both returned the same `intent_id`;
- final count for the tested `idempotency_key` was 1;
- normal regression still allowed distinct logical events to create distinct intents;
- helper cleanup checks eventually returned 0 rows.

## 4. Codex Stage 4 Baseline Verification

Codex Stage 4 execution produced the baseline post-fix race result:

```text
Session A returned: 8b1c7ddf-ed8c-4ca7-b6f6-5273c66768e6
Session B returned: 8b1c7ddf-ed8c-4ca7-b6f6-5273c66768e6
Final row count: 1
```

Normal regression:

```text
different_order_a | 194143f6-f5a4-4ffb-b27a-d4f64d1169c8
different_order_b | 4fda32e4-524f-4a92-a6cc-e1e383709c9b
same_order_ref_a  | 4ebd3aae-63c9-4287-8952-32e587612261
same_order_ref_b  | 6bb875e9-53fc-41e7-a596-63753d76efde
```

This demonstrates both sides of the contract:

- same deterministic `idempotency_key` -> same row;
- different logical event -> distinct rows.

## 5. Boundary Verification

No Stage 4 change was made to:

- `0098_create_payment_confirm_pipeline_rpc.sql`
- `0103_create_toss_payments_pipeline_rpc.sql`
- `0109_create_network_handoff_fallback_rpc.sql`
- `0130_create_van_handler_extension.sql`
- `0142_patch_toss_mvp_payment_intent_binding.sql`

`0142` remains a reference pattern only.

## 6. Helper Cleanup Verification

Final live query:

```sql
SELECT n.nspname, p.proname, pg_get_function_identity_arguments(p.oid) AS args
FROM pg_proc p
JOIN pg_namespace n ON n.oid=p.pronamespace
WHERE p.proname LIKE '__test_%'
   OR p.proname ILIKE '%pay_con%'
   OR p.proname ILIKE '%slow%'
ORDER BY n.nspname, p.proname;
```

Final result:

```text
nspname | proname | args
--------+---------+-----
(0 rows)
```

## 7. Temporary Helper Confusion: `__pay_con002_slow_resolve`

During dual verification, there was a short-lived confusion that `__pay_con002_slow_resolve` had reappeared. Final recheck showed 0 matching helper functions.

The most likely interpretation is that Cursor and Antigravity were accessing the same live database at nearly the same time and cleaned up each other's temporary helper functions while their verification turns overlapped. The final live state is clean:

- no `__test_` helper;
- no `__pay_con` helper;
- no `slow` / `slow_resolve` helper;
- no production function body containing test-only race-window logic.

This is recorded as a process finding, not an implementation defect.

## 8. `git diff --check`

Stage 4 final whitespace check returned exit 0. Existing LF/CRLF warnings from unrelated dirty files may still appear, but no whitespace error was reported for this workpacket.

## Conclusion

The race condition fix is verified. The database now enforces uniqueness for deterministic observed-intent idempotency keys, the resolver returns the surviving row under conflict, and independent Cursor/Antigravity checks both confirm the same post-fix race behavior.

