# 604324_Analysis_Cross_Scope_0068_Realtime_Edge_Invalid_Table_Constraint_Replay_Blocker.md

Status: Complete
Lifecycle: Analysis
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Analysis
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This is an analysis document only. It performs no implementation and modifies no
SQL, migration, or other file. It does not close 604260 and does not authorize
604250 resume. It does not create 604325 — that, if pursued, is a separate future
document. Per this lineage's established number decisions, 604310, 604316, and
604322 remain unused/forbidden.

---

## 1. Analysis Scope

```text
In scope:
  - Direct review of sql/migrations/0068_create_realtime_edge_rpc.sql, in full.
  - Identification and precise location of the invalid table-level UNIQUE
    constraint expression reported by 604321/604323.
  - A completeness check for any other occurrence of the same or a related defect
    class anywhere in 0068 -- not limited to the single reported location, per the
    lesson already established in this lineage (0063: 1 reported, 15 actual; 0066:
    5 reported, 15 actual).
  - Analysis of the intended uniqueness semantics behind the broken constraint.
  - Presentation of candidate fixes (analysis only, no implementation), including
    an assessment of the actual PostgreSQL version available in this environment
    where version-dependent options are relevant.
  - A recommended path, subject to Human approval before any implementation.
  - Assessment of MVP-1 relevance, since the user has indicated MVP-1 does not
    require payment to work and prioritizes the core wait-order/handoff flow.

Out of scope (not performed, not authorized here):
  - Any edit to 0068 or any other migration.
  - Any change to 0067, 0066, 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Creating 604325 or any other successor document.
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310, 604316, or 604322.
```

---

## 2. Inputs Reviewed

```text
sql/migrations/0068_create_realtime_edge_rpc.sql (full file, 1187 lines, read in
  full)
604321_Verification_Cross_Scope_0067_Cron_Scheduler_NoOp_Safety_Migration_Replay_Blocker.md
  (§5 verbatim 0068 failure record)
604323_Audit_Cross_Scope_0067_Cron_Scheduler_Duplicate_Migration_Replay_Blocker.md
  (§9 0068 blocker classification and reconfirmation)
git diff --stat for sql/migrations/0068_create_realtime_edge_rpc.sql (independently
  re-run in this analysis — confirmed empty, i.e. 0068 is unmodified)
Prior verification documents in this lineage recording the actual PostgreSQL
  version in use (604292, 604296, 604301, 604305, 604309, 604315, 604321) --
  each independently confirms "Container image: public.ecr.aws/supabase/
  postgres:17.6.1.140" / "PostgreSQL version: 17.6" for the Supabase local Docker
  environment used throughout this entire workpacket lineage.
```

---

## 3. 604323 Audit Reference

```text
This Analysis is triggered by 604323 Audit §9/§17, which independently confirmed
the 0068 blocker (`syntax error at or near "("`, from an expression inside a
table-level UNIQUE constraint) and classified it INVALID_TABLE_CONSTRAINT_
EXPRESSION -- a new defect class in this lineage, distinct from the `:=`-in-
UPDATE-SET, LIMIT-inside-aggregate, and inline-procedure-in-DECLARE classes
already resolved for 0038/0042/0063, 0046/0065/0066, and 0035/0065 respectively.
604323 explicitly deferred selecting a fix to "the next analysis," noting only
that converting the inline constraint expression to an expression-based unique
index "appears" to be the likely remedy -- this Analysis is that next module, and
independently investigates the full candidate space rather than assuming that
single option.
```

---

## 4. 0068 Migration Identification

```text
File: sql/migrations/0068_create_realtime_edge_rpc.sql
Header: "Depends on: 0067_create_cron_scheduler_rpc.sql"
Total length: 1187 lines
Objects declared:
  - table catchmenu_common.realtime_channels (Supabase Realtime channel registry,
    with RLS policy, update trigger, and 9 seeded default channels per tenant)
  - table catchmenu_common.edge_function_registry (Supabase Edge Function routing
    registry -- THE TABLE CONTAINING THE DEFECT -- with RLS policy, update
    trigger, and 10 seeded routes)
  - table catchmenu_common.firebase_migration_boundary (Firebase migration
    boundary tracking, with update trigger and 7 seeded boundary rows)
  - function catchmenu_common.get_realtime_config(...)
  - function catchmenu_common.notify_channel(...)
  - function catchmenu_common.get_edge_function_routes(...)
  - function catchmenu_common.register_firebase_boundary(...)
This is the first migration reached in this lineage that touches Flutter-facing
Realtime channel configuration and Edge Function routing -- both directly relevant
to the wait-order/handoff MVP-1 flow (see §17).
```

---

## 5. Edge Function Registry Table Assessment

```text
catchmenu_common.edge_function_registry (lines 259-311) columns:
  id uuid PK, tenant_id uuid (NULLABLE -- no NOT NULL constraint), function_code
  text not null, function_name text not null, function_path text not null,
  function_method text not null default 'POST', trigger_type text not null,
  trigger_source text, requires_auth/requires_signature booleans,
  allowed_origins jsonb, rate_limit_per_minute/rate_limit_per_day int,
  timeout_seconds int, target_rpc_schema/target_rpc_name text,
  flutter_invoke_name text, is_active boolean, created_at/updated_at timestamptz.

Related objects:
  - RLS policy `edge_function_isolation` (lines 318-326): `using (tenant_id is null
    or tenant_id = catchmenu_common.current_tenant_id())` -- explicitly designed
    around tenant_id being nullable, and explicitly grants visibility to NULL-
    tenant rows for every tenant (i.e. GLOBAL rows are visible to all).
  - Update trigger `trg_edge_function_updated` -- unrelated to the defect.
  - RPC `catchmenu_common.get_edge_function_routes(p_tenant_id uuid default null)`
    (lines 956-1012): its own WHERE clause reads `where is_active = true and
    (tenant_id is null or tenant_id = p_tenant_id)` -- the exact same "NULL means
    global, else tenant-scoped" pattern as the RLS policy.
  - Seed data (lines 356-472): all 10 seeded rows (TOSS_WEBHOOK, BAEMIN_WEBHOOK,
    YOGIYO_WEBHOOK, COUPANG_WEBHOOK, VAN_APPROVAL, KDS_BROADCAST, DID_BROADCAST,
    AI_CHAT_HANDLER, SESSION_CLEANUP_CRON, DAILY_CLOSE_CRON) omit tenant_id from
    their INSERT column list entirely, meaning every currently-seeded row has
    tenant_id = NULL -- i.e. every seed row is intentionally a GLOBAL edge function
    definition, not a tenant-specific override. No tenant-specific row exists yet
    in this migration, but the schema (nullable tenant_id, the RLS policy, and the
    routing RPC) is clearly designed to support one being added later.
```

---

## 6. Invalid Constraint Location

```text
Exact location: lines 296-299, inside catchmenu_common.edge_function_registry's
table definition:

  constraint uq_function_code unique (
    coalesce(tenant_id::text, 'GLOBAL'),
    function_code
  ),

This is the sole cause of the reported "syntax error at or near '('" at psql LINE
39 (in-statement offset from the table's own CREATE TABLE statement start).
```

---

## 7. PostgreSQL Constraint Syntax Assessment

```text
PostgreSQL's table-level UNIQUE constraint grammar accepts only a column list (or
a column list with an opclass/ordering, in the context of certain index-relevant
options) -- it does NOT accept an arbitrary expression such as
`coalesce(tenant_id::text, 'GLOBAL')`. `coalesce(tenant_id::text, 'GLOBAL')` is not
a column name; it is a function call combined with a type cast, syntactically
invalid at the position PostgreSQL's parser expects a column identifier inside a
table CONSTRAINT ... UNIQUE (...) clause. This is precisely why the file fails to
parse: the parser encounters `coalesce(` and cannot interpret the opening
parenthesis as valid syntax in that position.

Expression-based uniqueness in PostgreSQL is instead expressed via CREATE UNIQUE
INDEX ... ON table (expression, ...), which does support arbitrary expressions
(including coalesce, casts, and function calls) as index keys. This distinction --
table CONSTRAINT restricted to columns, versus INDEX supporting expressions -- is
the structural root of every candidate in §10-§14.

Completeness check (per this lineage's own established practice of not trusting a
single reported occurrence): a full-file search for every "unique" keyword in 0068
found exactly three occurrences -- `uq_channel_code unique (tenant_id,
channel_code)` (pure columns, valid), `uq_function_code unique (coalesce(...),
function_code)` (THE defect), and `domain_name text not null unique` (a valid
single-column inline unique constraint). Only one occurrence of this defect exists
in 0068; it is not a repeated pattern like 0063's 15 or 0066's 15.
```

---

## 8. Intended Uniqueness Semantics

```text
Based on the table's RLS policy, its own routing RPC's WHERE clause, and the seed
data (§5), the intended semantics are:
  - tenant_id IS NULL rows are GLOBAL edge function definitions, visible to and
    usable by every tenant (confirmed by the RLS policy's `tenant_id is null or
    tenant_id = current_tenant_id()` and get_edge_function_routes' identical
    pattern).
  - tenant_id IS NOT NULL rows are tenant-specific entries -- not yet used by any
    seed data, but structurally supported (nullable column, RLS policy already
    accounts for it) as a mechanism for a specific tenant to have its own routing
    entry, presumably overriding or supplementing the GLOBAL one for the same
    function_code.
  - Uniqueness intent: function_code must be unique WITHIN the GLOBAL group (i.e.
    only one GLOBAL row may ever exist for a given function_code, e.g. only one
    GLOBAL "TOSS_WEBHOOK" row) and, independently, unique WITHIN each tenant's own
    group (i.e. a given tenant may not have two of its own rows sharing the same
    function_code) -- but a GLOBAL row and a tenant-specific row MAY share the same
    function_code without conflicting, since they represent different scopes
    (this is exactly what coalescing tenant_id to a sentinel and pairing it with
    function_code as a composite key achieves: two rows conflict only if their
    resolved (scope, function_code) pairs are identical).
  - version/environment/status are NOT part of the uniqueness key -- no such
    columns exist on this table at all; only tenant scope and function_code
    participate.
  - Only structural existence is being deduplicated here, not row lifecycle state
    -- is_active is not part of the constraint, meaning even an inactive row would
    still occupy its (scope, function_code) slot; the schema does not appear to
    intend "unique among active rows only" (no partial-index-style qualifier was
    present in the original, broken constraint either).
```

---

## 9. Root Cause Classification

```text
INVALID_TABLE_CONSTRAINT_EXPRESSION
```

```text
Reasoning, restated precisely per the task's own requirement: PostgreSQL
table-level UNIQUE constraints accept only column references, not expressions.
`coalesce(tenant_id::text, 'GLOBAL')` is a function-call expression, not a column
name, so `unique (coalesce(tenant_id::text, 'GLOBAL'), function_code)` is rejected
at parse time. This is not a failure of the 0067 no-op remediation -- 0067 no
longer contains any table/function definitions at all (604323 §6/§7), and 0068 is
a wholly separate, unrelated migration file. This blocker was simply unreached by
replay until 0067's own duplicate-content blocker was cleared; it is a
pre-existing, next-in-sequence baseline defect, consistent with every prior stage
of this lineage (0035/0038 -> 0042 -> 0046 x2 -> 0063 -> 0065 x2 -> 0066 -> 0067 ->
now 0068).
```

---

## 10. Candidate A — Expression-Based Unique Index

```text
Convert the invalid table constraint into a separate CREATE UNIQUE INDEX statement
using the identical expression:

  create unique index uq_edge_function_code
    on catchmenu_common.edge_function_registry (
      coalesce(tenant_id::text, 'GLOBAL'),
      function_code
    );

Pro:
  - Most directly preserves the original author's exact intended expression and
    enforcement semantics -- a pure syntax-position fix (constraint -> index) with
    no change to the coalesce/cast logic itself.
  - Well-understood, minimal-risk PostgreSQL pattern for expression-based
    uniqueness.
  - Resolves the replay blocker.

Con:
  - Relies on a `tenant_id::text` cast and a literal sentinel string ('GLOBAL') --
    functionally safe (a UUID's text form can never literally equal 'GLOBAL'), but
    a design smell some reviewers would flag.
  - Becomes an INDEX rather than a table CONSTRAINT -- `information_schema.
    table_constraints` / `\d` introspection and any tooling that specifically
    expects a named constraint (rather than a named unique index) would see this
    differently, though PostgreSQL itself treats a unique index as fully
    equivalent for conflict-detection and ON CONFLICT purposes.
  - Index naming, dependency tracking, and idempotent-reapply behavior (CREATE
    UNIQUE INDEX does not have an IF NOT EXISTS-per-name idempotent form as clean
    as "IF NOT EXISTS" on tables; `create unique index if not exists` IS valid
    PostgreSQL syntax, so this concern is minor but should be verified in the
    eventual implementation).
```

---

## 11. Candidate B — Partial Unique Indexes

```text
Split the single composite constraint into two partial unique indexes, one per
scope, avoiding any cast or sentinel string:

  create unique index uq_edge_function_code_global
    on catchmenu_common.edge_function_registry (function_code)
    where tenant_id is null;

  create unique index uq_edge_function_code_tenant
    on catchmenu_common.edge_function_registry (tenant_id, function_code)
    where tenant_id is not null;

Pro:
  - Expresses the GLOBAL-vs-tenant-specific semantics (§8) explicitly and
    legibly -- a future reader immediately sees the two scopes as two separate
    rules, without needing to reason about what a coalesce-to-'GLOBAL' sentinel
    means.
  - No `::text` cast, no string sentinel -- pure column references throughout.
  - Verified in this Analysis to be exactly semantically equivalent to the
    original coalesce-based constraint for all three row-pair cases (both GLOBAL,
    both same tenant, one GLOBAL one tenant-specific) -- see §8's case-by-case
    walkthrough, which applies identically here.

Con:
  - Two index objects instead of one -- a slightly larger structural footprint
    than Candidate A or D.
  - Not a literal token-level fix; requires confirming (as this Analysis already
    has, in §8) that the intended semantics really are "GLOBAL uniqueness" plus
    "per-tenant uniqueness," not some other relationship, before committing to two
    separately-named objects.
```

---

## 12. Candidate C — Generated Column

```text
Add a stored generated column reproducing the coalesce expression, and keep a
table-level constraint referencing it:

  alter table catchmenu_common.edge_function_registry
    add column tenant_scope_key text
    generated always as (coalesce(tenant_id::text, 'GLOBAL')) stored;

  constraint uq_function_code unique (tenant_scope_key, function_code)

Pro:
  - Preserves the "table CONSTRAINT" form the original author apparently intended,
    while making the underlying expression an explicit, queryable column.

Con:
  - Materially larger schema change than A, B, or D for equivalent enforced
    behavior -- introduces a new persisted column purely to work around a syntax
    restriction, when simpler alternatives (B, D) achieve the same enforcement
    without one.
  - Expands the surface this replay-blocker-cleanup workpacket touches beyond what
    its own stated purpose (pre-0142 baseline replay blocker remediation, not
    schema redesign) calls for.
  - NOT RECOMMENDED given B and D both achieve identical enforcement with strictly
    less schema footprint.
```

---

## 13. Candidate D — UNIQUE NULLS NOT DISTINCT

```text
Use PostgreSQL 15+'s NULLS NOT DISTINCT modifier directly on the original two real
columns, with no expression, cast, or sentinel of any kind:

  constraint uq_function_code unique nulls not distinct (
    tenant_id, function_code
  )

Verified in this Analysis, case by case, to be EXACTLY behaviorally equivalent to
the original (broken) `unique (coalesce(tenant_id::text, 'GLOBAL'), function_code)`:
  - Two rows both with tenant_id NULL: under NULLS NOT DISTINCT, NULL is treated
    as equal to NULL, so these conflict if function_code matches -- identical to
    the original, where both would coalesce to 'GLOBAL' and conflict on
    function_code.
  - One row tenant_id NULL, another tenant_id = some UUID: NULL is never equal to
    a non-NULL value even under NULLS NOT DISTINCT, so no conflict regardless of
    function_code -- identical to the original, where 'GLOBAL' never equals a
    UUID's text form.
  - Two rows with the same non-NULL tenant_id: conflict if function_code matches --
    identical to the original.

PostgreSQL version dependency: NULLS NOT DISTINCT was introduced in PostgreSQL 15.
Independently confirmed in this Analysis: every prior verification document in
this exact lineage (604292, 604296, 604301, 604305, 604309, 604315, 604321) records
the Supabase local Docker environment's container image as
`public.ecr.aws/supabase/postgres:17.6.1.140` and PostgreSQL version as `17.6` --
well past the 15+ requirement. This is strong, session-established evidence this
feature is available in the exact environment this lineage has used throughout.
The production Supabase Postgres version has not been independently confirmed in
this Analysis (only the local Docker verification environment has); this should be
verified before final implementation, consistent with the task's own caution that
version support must be checked.

Pro:
  - Exactly reproduces original enforcement semantics (proven above).
  - Smallest possible footprint of any candidate: no new column, no separate index
    object, no cast, no sentinel string -- a single-line change to the constraint
    keyword itself (`unique` -> `unique nulls not distinct`) plus removing the
    coalesce/cast wrapper, keeping pure column references.
  - Remains a genuine table-level CONSTRAINT, the closest structural match to what
    the original file's author was evidently trying to write.

Con:
  - Depends on PostgreSQL 15+ -- confirmed available in this lineage's own local
    verification environment (17.6), but production version should still be
    explicitly confirmed before implementation.
```

---

## 14. Candidate E — Remove / Relax Uniqueness

```text
Drop the constraint entirely, or relax it to a non-unique index.

Pro:
  - Trivially resolves the replay syntax error.

Con:
  - Removes a real data-integrity guarantee: nothing would then prevent two GLOBAL
    rows (or two rows for the same tenant) from sharing a function_code, silently
    creating ambiguous/duplicate edge-function routing entries that
    get_edge_function_routes and get_realtime_config-adjacent Flutter/Edge
    Function invocation logic have no defined tie-breaking behavior for.
  - No evidence anywhere in this file (comments, RLS policy, seed data, or RPC
    logic) suggests this uniqueness guarantee is unnecessary or was a mistake --
    on the contrary, the RLS policy and routing RPC are both explicitly written
    around the GLOBAL-vs-tenant-scope distinction this constraint exists to
    enforce.
  - NOT RECOMMENDED, consistent with every prior "remove/relax" candidate already
    rejected in this lineage (0046 Candidate C, 0065/0066/0067's equivalent
    options) for the same reason: no evidence justifies discarding an existing
    integrity guarantee as part of a replay-blocker syntax fix.
```

---

## 15. Recommended Path

```text
RECOMMEND_CANDIDATE_D_UNIQUE_NULLS_NOT_DISTINCT
```

```text
Candidate D achieves exactly the same enforced uniqueness behavior as the
original, broken constraint (proven case-by-case in §13), with the smallest
schema footprint of any candidate that preserves a genuine table-level
CONSTRAINT (no new column, no separate index object, no cast, no sentinel
string), and is confirmed compatible with the PostgreSQL version (17.6) this
entire lineage's own local verification environment has used throughout (604292
through 604321, each independently recording the same version).

This is preferred over Candidate A (also behaviorally faithful, but as an INDEX
rather than a CONSTRAINT, and retains the cast/sentinel-string pattern) and
Candidate B (also behaviorally faithful and column-pure, but requires two
separate index objects instead of one constraint) primarily because it is the
narrowest possible change: one keyword addition and removal of the coalesce/cast
wrapper, nothing structurally new. Candidate C is rejected as unnecessarily large
for equivalent behavior. Candidate E is rejected as an unjustified integrity
regression.

This recommendation is contingent on Human confirming the actual production
Supabase Postgres version supports NULLS NOT DISTINCT (PostgreSQL 15+) before any
implementation proceeds -- this Analysis has confirmed only the local Docker
verification environment's version (17.6, confirmed via 7 independent prior
verification documents in this lineage), not the production environment. If that
confirmation cannot be obtained, Candidate B is the recommended fallback (identical
enforced behavior, no version dependency, at the cost of one additional index
object).
```

---

## 16. Risk Assessment

```text
Technical risk on Candidate D is low: it is a single-clause modification to an
existing constraint, verified case-by-case to be behaviorally identical to the
original intent, touching no other line, column, index, RLS policy, trigger, or
function in 0068.

The version-dependency risk (§13) is the primary risk specific to this candidate
-- mitigated by the strong, repeatedly-confirmed evidence of PostgreSQL 17.6 in
this lineage's own verification environment, but not eliminated until production
parity is explicitly confirmed by Human or the next Verification stage.

No risk is introduced to 0035, 0038, 0042, 0046, 0063, 0065, 0066, 0067, or 0142 --
this Analysis proposes no change to any of them, and none has been touched by any
document in this Analysis's own review chain.

The same repeating structural pattern already observed at every prior stage of
this lineage applies here too: resolving 0068 will very likely expose a further,
currently-undiscovered pre-existing blocker later in the sequence. This is a
property of the 0001-0142 baseline migration history, not a defect introduced by
this Analysis's own work.
```

---

## 17. MVP-1 Impact Assessment

```text
0068 is not purely payment-adjacent, unlike much of the recently-resolved work in
this lineage (0063's payment confirmation functions, 0142's Toss binding). It
creates realtime_channels and edge_function_registry, both of which are directly
relevant to the wait-order/handoff MVP-1 goal:
  - realtime_channels seeds a WAITING_QUEUE_CHANGE channel (subscribing to
    catchmenu_pos.order_sessions) and a DID_DISPLAY_BROADCAST channel -- exactly
    the kind of realtime updates a Flutter customer-facing wait-order/handoff UI
    would need to subscribe to.
  - get_realtime_config's device-type filtering explicitly includes KIOSK, DID,
    and STAFF_APP device profiles tied to WAITING_QUEUE/ORDER_SESSIONS/
    DID_DISPLAY channels -- infrastructure a Flutter wait-order app would consume
    directly once built.
  - edge_function_registry also carries payment-adjacent entries (TOSS_WEBHOOK,
    a PAYMENT_STATUS_CHANGE realtime channel), so the file is not exclusively
    wait-order-scoped, but the wait-order-relevant portions are present alongside
    the payment-adjacent ones, not separable at the migration-file level.

However: the SPECIFIC DEFECT this Analysis addresses is a baseline-replay/clean-
bootstrap syntax error, not a missing feature -- fixing it does not add any new
capability; it only restores the ability to replay the full migration history
from scratch (relevant for new dev environments, CI, or disaster recovery). It
does not, by itself, determine whether an already-migrated/live environment
currently has this table and its seed data correctly in place.

MVP-1 impact rating: MEDIUM. Not directly on the payment-optional critical path
the user described, but the realtime-channel/edge-function-routing infrastructure
this migration establishes is directly relevant to the core wait-order/handoff
flow's eventual Flutter integration -- once Flutter development begins (not yet
started, per the user), this table and its RPCs are among the first things it
would need. The immediate urgency of fixing THIS SPECIFIC SYNTAX DEFECT, however,
is driven by clean-replay/CI needs (this workpacket's own stated purpose), not by
Flutter development being blocked today.
```

---

## 18. Boundary Compliance

```text
- No SQL, migration, or other file was modified in the course of this Analysis;
  only this document was created.
- 0068 confirmed unmodified via independent git diff.
- No document beyond this Analysis was created.
- 604250/604260 status unaffected; no statement made authorizing either.
- 604310, 604316, and 604322 remain unused/forbidden; not used by this Analysis.

Boundary compliance: PASS.
```

---

## 19. Required Next Step

```text
Human approval required — 604325 Approval Gate or implementation decision.

Specifically, Human should:
  1. Select among Candidates A/B/C/D/E (this Analysis recommends D, with B as
     fallback if PostgreSQL version parity cannot be confirmed for production).
  2. Confirm (or request confirmation of) the production Supabase Postgres
     version's support for NULLS NOT DISTINCT if Candidate D is selected.
  3. Direct whether the next document is a 604325 Approval Gate (mirroring this
     lineage's own precedent from 604313/604319) or a more direct implementation
     authorization, given Candidate D's narrow, single-clause scope.

This Analysis does not create 604325, does not select a Candidate on Human's
behalf, and does not itself constitute authorization for any implementation. It
records only that:
  - 0067 remains no-op PASS per 604323 Audit (canonical instance).
  - 0068 is confirmed to contain exactly one occurrence of
    INVALID_TABLE_CONSTRAINT_EXPRESSION, in edge_function_registry's
    uq_function_code constraint, with no other hidden occurrence of this or any
    related defect class found in the file.
  - 0142 remains not reached; 0142 object absence is not a 0142 failure.
  - 604250 resume and 604260 closeout remain not authorized by any document in
    this workpacket, including this Analysis.
  - 604310, 604316, and 604322 remain unused/forbidden per Human number decision.
```
