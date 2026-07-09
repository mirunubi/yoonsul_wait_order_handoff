# 604313_Approval_Gate_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_Blocker.md

Status: Complete (retroactively confirming an already-implemented scope)
Lifecycle: Human Approval Gate
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 3 Human Approval Gate
Runtime Implementation Authorization: Confirmed for 604314's already-completed scope only
Owner: Human
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It performs no implementation and
modifies no SQL, migration, or other file, including 0066 and 604314. It does not
execute 604315 Verification. Per explicit Human number decision, 604310 remains
unused in this lineage. It does not create 604316.

---

## 1. Approval Gate Scope

```text
In scope:
  - Recording the Human approval basis for 604314's already-completed correction of
    all 15 aggregate-inline-limit occurrences in 0066_create_ledger_integrity_rpc.sql.
  - Documenting the full occurrence inventory, the authorized fix rule (Candidate B),
    and the rejection rationale for Candidates A/C, so this Gate stands as a
    complete, independently-readable approval record ahead of 604315 Verification.
  - Fixing the traceability gap 604312 Analysis itself created: 604312 recommended
    DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW pending exactly this kind of explicit
    scope confirmation; this document is that confirmation, recorded after Human
    reviewed 604312 and approved 604314's implementation.

Out of scope (not performed, not authorized by this document):
  - Any edit to 0066 or any other migration.
  - Any change to 0065, 0063, 0046, 0042, 0038, 0035, or 0142.
  - Any modification to 604314's own implementation record.
  - Running 604315 Verification -- that is a separate, subsequent step.
  - Reopening 604260 closeout or 604250 resume.
  - Using 604310, which remains reserved/unused per Human number decision.
```

---

## 2. Input Analysis Reference

```text
604312_Analysis_Cross_Scope_0066_Ledger_Integrity_Aggregate_Inline_Limit_Replay_Blocker.md
  is the sole analytical basis for this Approval Gate. Its findings, adopted here
  without alteration:
    - 15 total occurrences of AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR in 0066, not the 5
      originally reported by 604309/604311's replay-driven discovery.
    - Two structural shapes: Type 1 (bare-column aggregate, 7 occurrences) and
      Type 2 (composite-object aggregate, 8 occurrences).
    - One occurrence (correlation_ids / dup_payments, #4) whose row source has no
      pre-existing CTE-level cap, unlike the other 14.
    - No ORDER BY present at any of the 15 sites, and none required to preserve
      original intent.
    - Recommended fix, in principle: Candidate B (nested subquery preserving the
      row source's own cap, with LIMIT 5 applied specifically to the sample) --
      but 604312 itself declined to recommend proceeding without further Human
      confirmation, given the discovered scope discrepancy (15 vs. 5) and the
      structural diversity across the two types.

Independently re-confirmed in this Approval Gate by direct review of the actual
sql/migrations/0066_create_ledger_integrity_rpc.sql content (both the pre-604314
state implied by 604312's line-by-line citations and the current, post-604314
state): 604312's occurrence count, line numbers, row sources, and cap values are
accurate.
```

---

## 3. Reason Approval Gate Was Required

```text
604312 Analysis concluded DO_NOT_IMPLEMENT_REQUIRES_HUMAN_REVIEW rather than
proceeding directly to a 604313-numbered implementation recommendation, because:
  1. The true occurrence count (15) substantially exceeded what any prior document
     in this lineage had reported or approved (5) -- the same category of scope
     discrepancy that required Human review for 0063 in this lineage (604299).
  2. Two structurally different fix shapes were required (Type 1 vs. Type 2), not
     one uniform template.
  3. One occurrence (#4) had no pre-existing row-level cap, making its correct
     nested-subquery LIMIT the sole bound on its sample -- a distinct risk profile
     from the other 14.

Human reviewed 604312 and approved proceeding with Candidate B across all 15
occurrences (§15). 604314 Implementation was then carried out under that approval.
This document is the explicit, durable record of that approval, created before
604315 Verification runs, so that the approval basis is not merely an informal
instruction but a traceable document in this lineage -- consistent with the
Documentation Traceability Requirement (§14) that governs this entire workpacket
series.
```

---

## 4. 0066 Migration Identification

```text
File: sql/migrations/0066_create_ledger_integrity_rpc.sql
Header: "Depends on: 0065_create_security_isolation_rpc.sql"
Functions containing the 15 occurrences:
  - catchmenu_ledger.verify_event_ledger_integrity(...)  -- occurrences 1-5
  - catchmenu_ledger.verify_audit_chain(...)              -- occurrences 6-7
  - catchmenu_ledger.run_state_projection_check(...)      -- occurrences 8-11
  - catchmenu_ledger.reconcile_ledger_gaps(...)           -- occurrences 12-15
This identification is unchanged from 604312 §4 and is restated here for this Gate's
own self-containedness.
```

---

## 5. Full Occurrence Inventory

| # | Source Line | Function | Type | Aggregate Expression | Row Source | Existing Row Cap | ORDER BY Present | Payload Key | Authorized Treatment |
|---|---:|---|---|---|---|---|---|---|---|
| 1 | 185 | verify_event_ledger_integrity | Type 1 | jsonb_agg(id limit 5) | future_events | limit 10 | no | sample_ids | Candidate B nested subquery |
| 2 | 223 | verify_event_ledger_integrity | Type 1 | jsonb_agg(id limit 5) | orphaned_events | limit 10 | no | sample_ids | Candidate B nested subquery |
| 3 | 250 | verify_event_ledger_integrity | Type 1 | jsonb_agg(id limit 5) | bad_replays | limit 10 | no | sample_ids | Candidate B nested subquery |
| 4 | 286 | verify_event_ledger_integrity | Type 1 | jsonb_agg(correlation_id limit 5) | dup_payments | none | no | correlation_ids | Candidate B nested subquery |
| 5 | 327 | verify_event_ledger_integrity | Type 1 | jsonb_agg(order_id limit 5) | payment_no_kds | limit 10 | no | order_ids | Candidate B nested subquery |
| 6 | 556 | verify_audit_chain | Type 1 | jsonb_agg(id limit 5) | anon_financial | limit 10 | no | sample_ids | Candidate B nested subquery |
| 7 | 582 | verify_audit_chain | Type 1 | jsonb_agg(id limit 5) | future_audit | limit 10 | no | sample_ids | Candidate B nested subquery |
| 8 | 743 | run_state_projection_check | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | payment_mismatches | limit 20 | no | sample | Candidate B nested subquery |
| 9 | 797 | run_state_projection_check | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | order_mismatches | limit 20 | no | sample | Candidate B nested subquery |
| 10 | 851 | run_state_projection_check | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | kds_mismatches | limit 20 | no | sample | Candidate B nested subquery |
| 11 | 903 | run_state_projection_check | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | session_mismatches | limit 20 | no | sample | Candidate B nested subquery |
| 12 | 1043 | reconcile_ledger_gaps | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | gap_orders | limit 10 | no | sample | Candidate B nested subquery |
| 13 | 1083 | reconcile_ledger_gaps | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | gap_kds | limit 10 | no | sample | Candidate B nested subquery |
| 14 | 1120 | reconcile_ledger_gaps | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | gap_session | limit 10 | no | sample | Candidate B nested subquery |
| 15 | 1161 | reconcile_ledger_gaps | Type 2 | jsonb_agg(jsonb_build_object(...) limit 5) | pending_recon | limit 10 | no | sample | Candidate B nested subquery |

```text
Totals: 15 occurrences authorized. 7 Type 1. 8 Type 2. 10 occurrences with an
existing row cap of 10; 4 occurrences with an existing row cap of 20; 1 occurrence
(#4) with no existing row cap. 0 occurrences with an ORDER BY.
```

---

## 6. Type 1 Bare Column Aggregate Inline Limit Profile

```text
Shared shape across occurrences 1-7: `jsonb_agg(<column> limit 5)` where <column> is
a single scalar (id, correlation_id, or order_id) selected from a CTE. Authorized
rewrite rule:

  (
    select coalesce(jsonb_agg(sample.<column>), '[]'::jsonb)
    from (
      select <column> from <cte> limit 5
    ) sample
  )

This preserves the outer query's count(*)/sum(...) (unaffected, reading from the
full, uncapped-by-this-fix CTE) while capping only the sample list at 5. No ORDER BY
is introduced, matching the absence of one in every original construct.
```

---

## 7. Type 2 Composite Object Aggregate Inline Limit Profile

```text
Shared shape across occurrences 8-15: `jsonb_agg(jsonb_build_object(<fields>) limit
5)` where the invalid LIMIT is attached to the whole jsonb_build_object(...)
expression rather than a bare column. Authorized rewrite rule:

  (
    select coalesce(jsonb_agg(sample.item), '[]'::jsonb)
    from (
      select jsonb_build_object(<fields, unchanged>) as item
      from <cte>
      limit 5
    ) sample
  )

This relocates the entire jsonb_build_object(...) expression, unchanged in its field
list and field values, into the nested subquery, so the same composite object shape
(e.g. {ledger_id, current, projected} or {order_id, order_number, order_status,
final_amount}) is produced per sampled row, capped at 5 before aggregation.
```

---

## 8. Row Source Cap Assessment

```text
14 of the 15 occurrences read from a CTE that already applies its own row-level cap
(10 for occurrences 1, 2, 3, 5, 6, 7, 12, 13, 14, 15; 20 for occurrences 8, 9, 10,
11) -- this existing cap governs count(*)/mismatch_count/sum(...) and is untouched
by this fix; it is a detection/counting bound, distinct from the 5-item sample cap.

Occurrence 4 (dup_payments, correlation_ids) is the one exception: its CTE is a
GROUP BY aggregation (`group by correlation_id having count(*) > 1`) with no
LIMIT of its own -- it could in principle return an unbounded number of distinct
duplicate-correlation groups. For this occurrence, the nested subquery's own
`limit 5` (per §6's rewrite rule) is the ONLY bound on the sample list; there is no
CTE-level backstop. This was explicitly flagged in 604312 §12 as carrying a
qualitatively different risk profile from the other 14, and is called out here as
the one occurrence requiring the most careful individual verification in 604315.
```

---

## 9. Candidate B Rewrite Rule

```text
Authorized, uniformly across all 15 occurrences (per Type, §6/§7):
  1. Do not alter the CTE's own existing cap (10, 20, or, for occurrence 4, none).
  2. Do not alter count(*)/mismatch_count/sum(...) or any other aggregate reading
     from the full CTE.
  3. Do not add an ORDER BY anywhere -- none existed, and none is authorized to be
     introduced.
  4. Replace the invalid inline-limit aggregate expression with a nested subquery
     that selects the same column (Type 1) or the same jsonb_build_object(...)
     expression (Type 2) from the same CTE, applies `limit 5` as a valid clause of
     that inner SELECT, and aggregates only those rows in the outer expression,
     wrapped in `coalesce(..., '[]'::jsonb)` to preserve the original empty-result
     fallback.
  5. Do not change any field name, field value expression, WHERE/JOIN condition, or
     function signature anywhere in 0066.
  6. Do not create any new schema object.
```

---

## 10. Candidate A / C Rejection Rationale

```text
Candidate A (relocate LIMIT outside the aggregate call, no subquery) and Candidate C
(remove LIMIT entirely) are both rejected for all 15 occurrences, per 604312 §10/§12:
every one of the 15 outer statements collapses to a single row (no GROUP BY), so an
outer-query LIMIT is a no-op -- the sample would silently widen from 5 to the CTE's
own cap (10 or 20) at 14 sites, and would become fully unbounded at occurrence 4
(no CTE-level cap at all). Neither candidate is authorized under this Gate.
```

---

## 11. Behavior Preservation Conditions

```text
This Gate's approval is conditioned on 604315 Verification independently confirming,
for each of the 15 occurrences:
  - count(*)/mismatch_count/sum(...) values are unaffected by the fix (still read
    from the full, uncapped-by-this-fix CTE).
  - The sample/sample_ids/correlation_ids/order_ids payload key contains at most 5
    items, drawn from the same row source as before.
  - No new ORDER BY appears in the applied migration.
  - All existing row caps (10 at 10 sites, 20 at 4 sites) remain unchanged; occurrence
    4 has no row cap other than the new nested subquery's own limit 5.
  - No function signature, field name, or unrelated logic changed anywhere in 0066.
  - Zero remaining occurrences of `jsonb_agg(<anything> limit <n>)` anywhere in the
    file (static grep), confirming full coverage of all 15, not merely the 5
    originally reported.
```

---

## 12. Authorized Implementation Boundary

```text
Approved Files (matching 604314's actual, already-completed scope):
  1. sql/migrations/0066_create_ledger_integrity_rpc.sql -- all 15 occurrences per
     §5, treated per §6/§7/§9, with no other line, function signature, or object
     touched.
  2. A 604314 Implementation self-report (already created; not created by this Gate).

No other file is authorized for modification under this Gate.
```

---

## 13. Forbidden Scope

```text
- 0142_patch_toss_mvp_payment_intent_binding.sql
- 0065_create_security_isolation_rpc.sql (already fully fixed and accepted; not
  reopened here)
- 0063_patch_core_rpc_i18n_diagnostics.sql
- 0046_create_context_builder_rpc.sql
- 0035_verify_schema.sql
- 0038_create_toss_webhook_processor_rpc.sql
- 0042_create_delivery_order_intake_rpc.sql
- Any file under the 604250, 604260, or 604310 (unused) workpacket folders
- 604314's own already-written content (this Gate documents its authorization; it
  does not edit 604314)
- 604315 Verification (a separate, subsequent step; not executed by this Gate)
- 604316 (not created)
```

---

## 14. Documentation Traceability Requirement

```text
In this project, the correction-tracking documentation is treated as at least as
important as the SQL correction itself. Each correction step -- Analysis, Approval,
Implementation, Verification, Audit -- must produce its own independent document
with a substantial section structure (this Gate alone has 17 sections), because:

  - A raw SQL diff shows WHAT changed, but not WHY it was judged safe, what was
    explicitly forbidden, what evidence confirmed it, or what blocker comes next.
    Without that context, a future investigator (human or AI) cannot distinguish an
    intentional, reviewed correction from an accidental or unauthorized one.
  - This entire lineage (0035 through 0066, and every workpacket from 604270 through
    604313) depends on each stage's document existing and being internally
    consistent with the actual repository state, so that a future audit can
    reconstruct exactly which fix was approved, exactly what it covered, and exactly
    what remained open -- this is the basis every Audit document in this lineage has
    used to independently re-verify prior claims rather than merely trusting
    self-reports.
  - Missing or incomplete documentation at any step is treated as a quality failure
    in this project, independent of whether the underlying SQL change itself was
    correct -- because an undocumented correction cannot be reliably traced,
    rolled back, or reasoned about later, even if it happens to work today.
  - This 604313 document exists specifically because 604314 Implementation had
    already been carried out without a preceding, explicit, standalone Approval Gate
    document -- Human required this gap to be closed with a real document (not a
    retroactive note or comment) before 604315 Verification proceeds, so that the
    approval basis for 604314's 15-occurrence scope is durably recorded in this
    lineage going forward.
```

---

## 15. Human Approval Decision

```text
APPROVE_CANDIDATE_B_FOR_604314_IMPLEMENTATION
```

```text
Human reviewed 604312 Analysis's full findings (15 occurrences, not 5; two
structural types; one uncapped row source) and approved proceeding with Candidate B,
applied individually to all 15 occurrences per §5-§9 above, as the authorized basis
for 604314's implementation.
```

---

## 16. Relation To Already Completed 604314 Implementation

```text
604314 Implementation was already completed before this Approval Gate document was
created. This is not a post-hoc rationalization manufactured to justify an
unreviewed change -- 604314 was carried out under the Human approval recorded in
§15, following Human's explicit review of 604312's findings. This document is the
Human-required traceability artifact that makes that approval durable and
independently readable in this lineage, created before 604315 Verification runs so
that the authorized scope (§12) is fixed and citable ahead of the next verification
pass.

604313 performs no SQL or runtime change of any kind. It does not modify 0066. It
does not modify 604314's own content. It does not execute 604315 Verification --
that remains the next, separate step (§17).
```

---

## 17. Required Next Step

```text
604315 Verification — Supabase local clean sequential replay, to independently
confirm:
  - All 15 occurrences from §5 are resolved (zero remaining
    `jsonb_agg(<anything> limit <n>)` matches anywhere in 0066).
  - 0066 applies in full; all four functions (verify_event_ledger_integrity,
    verify_audit_chain, run_state_projection_check, reconcile_ledger_gaps) and the
    integrity_check_results table exist.
  - The behavior-preservation conditions in §11 hold for each of the 15 occurrences,
    with particular attention to occurrence 4 (dup_payments), per §8.
  - Prior 0035/0038/0042/0046/0063/0065 regression checks remain stable.
  - Replay progress toward 0142, and whether a further pre-existing blocker exists
    beyond 0066.

This Approval Gate does not perform that verification itself.
```
