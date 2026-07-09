# 604325_Approval_Gate_Cross_Scope_0068_Realtime_Edge_Invalid_Table_Constraint_Replay_Blocker.md

Status: Complete (conditional approval)
Lifecycle: Human Approval Gate
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Granted for Candidate D, conditional on §12; fallback Candidate B unconditional
Owner: Human
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It performs no implementation and
modifies no SQL, migration, or other file, including 0068. It does not create
604326. Per this lineage's established number decisions, 604310, 604316, and
604322 remain unused/forbidden.

---

## 1. Approval Gate Scope

```text
In scope:
  - Recording the Human decision selecting Candidate D (604324 Analysis §10-§13)
    as the primary approved path for remediating 0068's invalid table-level UNIQUE
    constraint expression, conditional on a PostgreSQL compatibility check.
  - Recording Candidate B as the unconditional fallback path if that compatibility
    check fails.
  - Locking the authorized implementation boundary ahead of a future 604326
    Implementation.
  - Documenting the required PostgreSQL compatibility gate that must be satisfied
    (for Candidate D) before implementation proceeds.

Out of scope (not performed, not authorized by this document):
  - Any edit to 0068 or any other migration.
  - Any change to 0067, 0066, 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Performing the PostgreSQL compatibility check itself -- that is a prerequisite
    for 604326, not something this Gate executes.
  - Implementing Candidate D or B -- that is 604326's job.
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310, 604316, or 604322.
```

---

## 2. Input Analysis Reference

```text
604324_Analysis_Cross_Scope_0068_Realtime_Edge_Invalid_Table_Constraint_Replay_Blocker.md
is the sole analytical basis for this Approval Gate. Its findings, adopted here
without alteration:
  - The defect: catchmenu_common.edge_function_registry's `constraint
    uq_function_code unique (coalesce(tenant_id::text, 'GLOBAL'), function_code)`
    (lines 296-299) -- an expression, not a column list, inside a table-level
    UNIQUE constraint, which PostgreSQL's grammar does not permit.
  - Intended semantics: tenant_id IS NULL = GLOBAL edge function definition;
    tenant_id IS NOT NULL = tenant-specific entry; function_code must be unique
    within each scope independently, with GLOBAL and tenant-specific rows allowed
    to share a function_code without conflicting.
  - Five candidates assessed (A: expression-based unique index; B: partial unique
    indexes; C: generated column; D: UNIQUE NULLS NOT DISTINCT; E: remove/relax
    uniqueness), with Candidate D recommended primary and Candidate B recommended
    fallback.
  - Candidate D was independently verified, case by case, to be exactly
    behaviorally equivalent to the original broken constraint, and confirmed
    compatible with the PostgreSQL 17.6 version recorded across seven independent
    prior verification documents in this lineage's own local Docker environment --
    but production/staging parity was explicitly NOT confirmed by 604324, and was
    flagged as a required check before implementation.
  - Only one occurrence of this defect exists in 0068 (independently confirmed via
    a full-file completeness scan in 604324 §7); this is not a repeated pattern
    like 0063's 15 or 0066's 15.
```

---

## 3. Replay Blocker Summary

```text
Sequential clean replay halts at 0068_create_realtime_edge_rpc.sql with "syntax
error at or near '('" when parsing the invalid uq_function_code constraint. 0067
(no-op safety migration, 604320/604323) is confirmed PASS and unrelated to this
defect. 0068 is a pre-existing baseline blocker, unreached until 0067's own
duplicate-content blocker was cleared -- not a failure of any prior fix in this
lineage. 0142 remains not reached as a result; 0142 object absence is not a 0142
failure.
```

---

## 4. Intended Uniqueness Semantics

```text
Confirmed by 604324 §8 from three independent sources within 0068 itself:
  1. The table's own RLS policy (`edge_function_isolation`): `using (tenant_id is
     null or tenant_id = catchmenu_common.current_tenant_id())`.
  2. The routing RPC `get_edge_function_routes`'s WHERE clause: `where is_active =
     true and (tenant_id is null or tenant_id = p_tenant_id)`.
  3. The seed data: all 10 currently-seeded rows (TOSS_WEBHOOK, BAEMIN_WEBHOOK,
     YOGIYO_WEBHOOK, COUPANG_WEBHOOK, VAN_APPROVAL, KDS_BROADCAST, DID_BROADCAST,
     AI_CHAT_HANDLER, SESSION_CLEANUP_CRON, DAILY_CLOSE_CRON) omit tenant_id
     entirely, i.e. every current row is a GLOBAL definition.

The uniqueness rule to preserve: function_code must be unique among all GLOBAL
(tenant_id IS NULL) rows, and independently unique within each tenant's own
(tenant_id IS NOT NULL) rows -- a GLOBAL row and a tenant-specific row may share a
function_code without conflict. No version/environment/status column participates
in this key. This Gate's approval is scoped to preserving exactly this behavior,
not to redesigning it.
```

---

## 5. Candidate A Assessment

```text
Expression-based unique index (`create unique index ... on ... (coalesce(tenant_id
::text, 'GLOBAL'), function_code)`).

Not selected. Behaviorally faithful to the original intent, but retains the
`::text` cast and 'GLOBAL' sentinel string, and converts the constraint into an
index rather than preserving table-CONSTRAINT form. Candidate D achieves the same
enforced behavior with less footprint and a form closer to the original author's
apparent intent (604324 §10, §15).
```

---

## 6. Candidate B Assessment

```text
Partial unique indexes (one for tenant_id IS NULL scoped by function_code alone,
one for tenant_id IS NOT NULL scoped by (tenant_id, function_code)).

Selected as FALLBACK, not primary. Verified in 604324 §11 to be exactly
semantically equivalent to the original constraint, with no cast, no sentinel
string, and no PostgreSQL-version dependency -- making it the safe path if
Candidate D's version requirement cannot be confirmed. Not selected as primary
only because Candidate D achieves the same guarantee with a single table-level
constraint rather than two separate index objects, when version support permits.
```

---

## 7. Candidate C Assessment

```text
Generated column plus a table-level constraint referencing it.

Not selected, and not approved as a fallback. 604324 §12 already established this
requires a materially larger schema change (a new persisted column) than B or D
for identical enforced behavior, exceeding what this replay-blocker-cleanup
workpacket's own scope calls for. Per this Gate's own Forbidden Scope (§14), a
generated column may not be introduced under this Approval unless Candidate C is
separately approved by Human in a future document -- it is not authorized here.
```

---

## 8. Candidate D Assessment

```text
UNIQUE NULLS NOT DISTINCT on the original two real columns
(`unique nulls not distinct (tenant_id, function_code)`), no expression, cast, or
sentinel of any kind.

SELECTED as primary, conditional on §12. Verified case-by-case in 604324 §13 to be
exactly behaviorally equivalent to the original broken constraint for all three
row-pair scenarios (both GLOBAL, both same tenant, one GLOBAL one tenant-specific).
Smallest footprint of any constraint-preserving option: no new column, no separate
index, no cast, no literal sentinel -- a single-clause modification to the
existing constraint. Requires PostgreSQL 15+; this Gate's approval of Candidate D
is explicitly conditional on confirming that requirement is met in production/
staging (§12), not merely in the local verification environment already confirmed
in 604324.
```

---

## 9. Candidate E Assessment

```text
Remove or relax the uniqueness guarantee entirely.

REJECTED, unconditionally. No evidence anywhere in 0068 (comments, RLS policy,
routing RPC, or seed data) suggests this integrity guarantee is unnecessary. Its
removal would allow ambiguous duplicate edge-function routing entries with no
defined tie-breaking behavior, consistent with every prior rejection of an
equivalent "remove/relax" option in this lineage (604283, 604307, 604318).
```

---

## 10. Approved Primary Path

```text
Candidate D — UNIQUE NULLS NOT DISTINCT

Replace the invalid expression-based table-level UNIQUE constraint with a valid
table-level UNIQUE NULLS NOT DISTINCT constraint on the same two real columns
(tenant_id, function_code), preserving:
  - tenant_id NULL = GLOBAL scope semantics.
  - tenant_id NOT NULL = tenant-specific scope semantics.
  - function_code uniqueness within each scope independently.
  - Table-level constraint style (not converted to an index).
No generated column may be introduced. No uniqueness guarantee may be removed or
relaxed. No unrelated realtime channel or edge function runtime logic may be
touched.
```

---

## 11. Fallback Path

```text
Candidate B — Partial Unique Indexes

To be used ONLY if production/staging PostgreSQL compatibility for Candidate D
cannot be confirmed per §12:
  - One unique index on (function_code) where tenant_id is null.
  - One unique index on (tenant_id, function_code) where tenant_id is not null.
This fallback carries no version dependency and is independently verified (604324
§11) to enforce the exact same semantics as Candidate D and as the original
constraint.
```

---

## 12. PostgreSQL Compatibility Gate

```text
Required compatibility check before any Candidate D implementation:
  1. Determine the production or staging PostgreSQL server version, e.g. via
     `SELECT version();` or `SHOW server_version;` against the actual target
     environment(s) this migration will run against (not merely the local
     Supabase Docker verification environment already confirmed at 17.6 across
     604292-604321).
  2. If the local/staging verification environment permits it, confirm NULLS NOT
     DISTINCT syntax compatibility directly, e.g. by creating a disposable
     temporary table with a `unique nulls not distinct` constraint and confirming
     it is accepted, then dropping it -- this is a lightweight, non-destructive
     confirmation step, not itself an authorization to modify 0068.
  3. PostgreSQL 15 or later is required for Candidate D. If the confirmed version
     is below 15, or if the check in step 1 cannot be performed with confidence
     for the actual production/staging target, Candidate D is NOT approved for
     implementation, and 604326 must instead proceed with the fallback Candidate B
     (§11), or return to Human for further decision.
  4. This compatibility check is a precondition for 604326 Implementation; it is
     not performed by this Approval Gate, and this Gate's approval of Candidate D
     does not take effect until the check is satisfied.
```

---

## 13. Authorized Implementation Boundary

```text
Approved Files:
  1. sql/migrations/0068_create_realtime_edge_rpc.sql -- and ONLY this file.

Within 0068, the following changes are authorized for 604326 (contingent on §12):
  - The uq_function_code constraint (lines 296-299) may be changed FROM the
    invalid `unique (coalesce(tenant_id::text, 'GLOBAL'), function_code)` TO a
    valid `unique nulls not distinct (tenant_id, function_code)` (Candidate D, if
    §12 is satisfied) or to the two partial unique indexes described in §11
    (Candidate B, if §12 is not satisfied).
  - The constraint name `uq_function_code` may be preserved if the resulting
    syntax remains valid under that name; for Candidate B's two-index form, two
    distinct names are required (e.g. uq_edge_function_code_global and
    uq_edge_function_code_tenant, or equivalent).
  - No other line, column, index, RLS policy, trigger, seed data row, or function
    in 0068 may be changed.

No new schema object beyond what §10/§11 explicitly describe may be created. No
generated column may be added (Candidate C is not authorized under this Gate).
```

---

## 14. Forbidden Scope

```text
- No unrelated SQL modification anywhere else in 0068.
- No change to realtime_channels functionality, its RLS policy, its seed data, or
  its trigger.
- No change to edge_function_registry's routing lookup logic
  (get_edge_function_routes), its RLS policy beyond what §13 authorizes, or its
  seed data.
- No change to firebase_migration_boundary or its functions.
- No change to any RLS policy anywhere in 0068.
- No change to any seed data anywhere in 0068.
- No generated column addition, unless Candidate C is separately approved by
  Human in a future document.
- No removal or relaxation of uniqueness (Candidate E remains rejected).
- No payment-related modification of any kind.
- No new yoonsul_os / membership integration implementation of any kind.
- No modification to 0067_create_cron_scheduler_rpc.sql.
- No modification to 0066_create_ledger_integrity_rpc.sql.
- No modification to 0065_create_security_isolation_rpc.sql.
- No modification to 0063_patch_core_rpc_i18n_diagnostics.sql.
- No modification to 0046_create_context_builder_rpc.sql.
- No modification to 0035_verify_schema.sql, 0038_create_toss_webhook_processor_rpc.sql,
  or 0042_create_delivery_order_intake_rpc.sql.
- No modification to 0142_patch_toss_mvp_payment_intent_binding.sql.
- No 604250 resume.
- No 604260 closeout.
- No use of 604310.
- No creation of 604316.
- No creation of 604322.
- No creation of a 604326 Implementation document by this Gate -- that remains a
  separate, later step, contingent on §12.
- No file other than this Approval Gate document may be created by this task.
```

---

## 15. MVP-1 Impact

```text
Per 604324 §17, this migration's impact on MVP-1 is rated MEDIUM: the specific
defect being remediated here is a clean-bootstrap/CI replay concern, not a missing
feature, but the table it affects (edge_function_registry) and its sibling table
in the same file (realtime_channels) establish infrastructure the wait-order/
handoff Flutter UI will need once Flutter development begins (WAITING_QUEUE_CHANGE,
DID_DISPLAY, KDS realtime channels; edge function routing for webhook/broadcast
handling). This remediation does not add or change any of that functionality -- it
only restores the ability to replay the schema and seed data that already define
it. Payment-adjacent entries in the same file (TOSS_WEBHOOK, PAYMENT_STATUS_CHANGE)
are incidental to this fix and are not being modified or prioritized differently
under this Approval.
```

---

## 16. Human Approval Decision

```text
APPROVE_CANDIDATE_D_UNIQUE_NULLS_NOT_DISTINCT_CONDITIONAL_ON_PRODUCTION_COMPATIBILITY
```

```text
FALLBACK_TO_CANDIDATE_B_PARTIAL_UNIQUE_INDEXES_IF_COMPATIBILITY_NOT_CONFIRMED
```

---

## 17. Required Next Step

```text
1. Confirm production or staging PostgreSQL compatibility per §12.
2. If compatibility is confirmed: PROCEED_TO_604326_IMPLEMENTATION_BY_CODEX
   (Candidate D, per §10/§13).
3. If compatibility is not confirmed: return to Human for Candidate B approval
   before any 604326 Implementation proceeds (Candidate B per §11 remains
   pre-approved as the fallback and does not itself require a further Approval
   Gate document, but Human should still confirm the switch before 604326
   begins).

This Gate does not perform the compatibility check itself and does not create
604326.
```
