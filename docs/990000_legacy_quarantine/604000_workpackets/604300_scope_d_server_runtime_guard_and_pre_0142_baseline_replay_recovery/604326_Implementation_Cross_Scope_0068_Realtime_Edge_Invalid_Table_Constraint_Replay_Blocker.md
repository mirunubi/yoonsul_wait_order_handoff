# 604326_Implementation_Cross_Scope_0068_Realtime_Edge_Invalid_Table_Constraint_Replay_Blocker.md

## 1. Implementation Scope

Implement the narrowly authorized Candidate D correction for the invalid `uq_function_code` table constraint in `0068_create_realtime_edge_rpc.sql`. No other 0068 behavior or migration was changed.

## 2. Human Approval Reference

Human approved Candidate D conditionally in 604325 and subsequently authorized `APPROVE_CANDIDATE_D_FOR_604326_IMPLEMENTATION` for the confirmed local replay target.

## 3. Compatibility Confirmation Reference

Local PostgreSQL 17.6 compatibility was confirmed against `supabase_db_yoonsul_wait_order_handoff`. `UNIQUE NULLS NOT DISTINCT` syntax succeeded and duplicate NULL behavior raised the expected unique violation.

Production and staging compatibility were not confirmed in this pass.

## 4. File Modified

Only `sql/migrations/0068_create_realtime_edge_rpc.sql` was modified. This 604326 Implementation document was created as the implementation record.

## 5. Root Cause Summary

The table-level UNIQUE constraint contained the expression `coalesce(tenant_id::text, 'GLOBAL')`. PostgreSQL table constraints require a column list, so the expression caused migration replay parsing to fail.

## 6. Candidate D Implementation Detail

The constraint was changed from the invalid expression form to:

```sql
constraint uq_function_code unique nulls not distinct (
  tenant_id,
  function_code
)
```

The existing constraint name and real-column order were preserved. `coalesce(tenant_id::text, 'GLOBAL')` was removed from the table-level UNIQUE constraint.

## 7. Constraint Semantics Preservation

`tenant_id IS NULL` continues to represent the GLOBAL scope. NULL tenant IDs are treated as not distinct, so duplicate GLOBAL `function_code` values are rejected. Tenant-specific rows remain unique by `(tenant_id, function_code)`, while a GLOBAL and tenant-specific row may share a function code. No uniqueness relaxation was performed.

## 8. Production / Staging Compatibility Gate

Candidate D requires PostgreSQL 15 or later. Local PostgreSQL 17.6 compatibility is confirmed, but production/staging compatibility remains unconfirmed and is a mandatory deployment gate before this migration is promoted to those environments. If a target is below PostgreSQL 15, this implementation must not be deployed there without a separately authorized compatible strategy.

## 9. Forbidden Scope Compliance

- No partial unique indexes were created.
- No generated column was added.
- No RLS, RPC, seed, trigger, or realtime channel behavior was modified.
- No 0067, 0066, 0065, 0063, 0046, 0035, 0038, 0042, or 0142 change was made by 604326.
- No payment or membership implementation was performed.
- 604250 was not resumed; 604260 was not closed; 604310 was not used; 604316 and 604322 were not created.

## 10. Self-Check Results

- `uq_function_code` exists and uses `UNIQUE NULLS NOT DISTINCT`.
- The invalid `coalesce(tenant_id::text, 'GLOBAL')` expression is absent from the constraint.
- Constraint name and column order are preserved.
- Static boundary and `git diff --check` verification were performed.

## 11. Verification Required

SQL/runtime replay was not performed by Codex. 604327 Verification by Cursor / Local Verification Runner is required to run a clean sequential replay and validate the constraint behavior in the replayed schema.

## 12. Next Step

Proceed to 604327 Verification by Cursor / Local Verification Runner. Keep production/staging PostgreSQL version confirmation as a deployment gate.
