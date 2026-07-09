# 604501_Approval_Gate_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

Status: Corrected (superseding original approved direction in place; no
downstream implementation ever occurred against the original text)
Lifecycle: Human Approval Gate
Gate Classification: Wait-Order/POS/KDS No-Payment Store-Level Release Policy — Stage 3 Human Approval Gate (Corrected)
Runtime Implementation Authorization: Not Granted By This Document
Owner: Human (정영석)
Last Updated: 2026-07-05

This is a documentation-only Approval Gate. It approves a minimal implementation
SCOPE for a no-payment KDS release path for MVP-1, gated by an explicit
store/tenant-level no-payment policy flag. It performs no SQL edit, migration
edit, function/trigger edit, runtime code edit, Flutter/UI edit, test-data
insert, DB write, staging, or commit. It does not create or modify 0069
Analysis, does not resume Scope D mainline, and does not mix with the
604392-604395 Group A SQL residue track.

---

## 0. Correction Notice

```text
CORRECTED 2026-07-05 (in place; same document, same file, no supersession
needed because 604502 Implementation was never created and no action was
ever taken against the original approved direction).

Original defect: this document's original §4-§8 approved
manual_fallback_activated as a per-ticket override condition for
payment_confirmed (an effective "payment_confirmed OR manual_fallback_
activated" gate). This directly contradicted 604500 Analysis's own findings,
which this document's own original §3 correctly restated but then
incorrectly acted against:

- manual_fallback is a system-failure-mode declaration (KDS bypassed
  entirely, staff switches to paper tickets) -- it is NOT a per-ticket
  payment override.
- catchmenu_agent.activate_manual_fallback (0030) does not update
  kds_tickets or conditions_met at all. There is no code path today by
  which activating manual fallback changes any ticket's release eligibility.
- Using manual_fallback_activated as a KDS-release condition would have
  conflated "the whole KDS system is down, use paper" with "this specific
  order doesn't require payment," which are different operational concepts
  with different guarantees and different audit meaning.

Correction: this document now approves a STORE/TENANT-LEVEL no-payment KDS
release POLICY (e.g. a `kds_payment_policy` or
`payment_required_for_kds_release` flag scoped to the store/tenant), which
substitutes for payment_confirmed only for stores explicitly configured into
MVP-1 no-payment pilot mode -- never via manual_fallback_activated, and
never as an implicit per-ticket bypass.

Old Final Approval Decision (WITHDRAWN):
  APPROVED_FOR_MINIMAL_NO_PAYMENT_MANUAL_FALLBACK_KDS_RELEASE_PATH_WITH_STRICT_RUNTIME_BOUNDARY

New Final Approval Decision (see §11/§16):
  APPROVED_FOR_STORE_LEVEL_NO_PAYMENT_KDS_RELEASE_POLICY_WITH_MANUAL_FALLBACK_EXCLUDED
```

---

## 1. Approval Gate Summary

```text
This document approves the minimal scope required so that, for MVP-1 pilot
stores explicitly configured with a store/tenant-level no-payment KDS
release policy, an order can be confirmed without payment and its KDS
ticket can still progress from HOLD through COOKING -> READY -> COMPLETED
via an explicit, audited, staff/operator-authorized release path gated on
that store-level policy flag -- while the existing payment_confirmed
release path remains fully intact and unmodified for stores that do use
payment. manual_fallback (activate_manual_fallback, manual_fallback_
activated) is explicitly EXCLUDED from this release path; it remains a
system-failure/paper-ticket mechanism, unrelated to payment status.

Final approval decision:
```

```text
APPROVED_FOR_STORE_LEVEL_NO_PAYMENT_KDS_RELEASE_POLICY_WITH_MANUAL_FALLBACK_EXCLUDED
```

```text
Authorized implementer (604502 only):
```

```text
Codex
```

```text
Human owner:
```

```text
정영석
```

---

## 2. Current State Basis

```text
- 604500 Analysis is complete. Final Analysis Result:
  WAIT_ORDER_POS_KDS_NO_PAYMENT_PATH_REQUIRES_APPROVAL_GATE_BEFORE_IMPLEMENTATION
- Confirmed blockers from 604500, both accepted as this Gate's factual basis:
  FAIL_PAYMENT_COUPLED_KDS_BLOCKER (primary, immediate)
  FAIL_KDS_DELIVERY_PROTOCOL_MISSING (secondary, follow-up, not an immediate
    SQL release blocker for this Gate's minimal scope)
- The 604383-604392 (and onward) SQL/migration residue disposition track,
  including the 604392-604395 A1 micro-fix sub-batch, is a SEPARATE, ongoing
  track. This Gate does not authorize mixing with it.
- 0069 Analysis remains deferred, uncreated. Scope D mainline remains
  blocked, not resumed.
- No file is currently staged. git diff --check passes. This Gate
  independently re-confirmed the working tree immediately before being
  corrected: the same 21 SQL/migration and 4 tools/* residue paths from the
  604383-604392 track remain present and unstaged, unrelated to this track.
- 604502 Implementation was never created against the original (flawed)
  approved direction. No SQL/RPC/runtime work was ever performed based on
  the withdrawn manual_fallback-as-override approach. This correction is
  therefore safe to make in place with no downstream impact to undo.
```

---

## 3. Input Analysis Reference

```text
604500_Analysis_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Blocker.md
is accepted as the basis for this Approval Gate without re-analysis. Its key
findings, adopted here (unchanged from the original version of this Gate --
these citations were always accurate; only the conclusions drawn from them
in §4 onward were corrected):

- confirm_order (0026) creates KDS tickets in HOLD state without requiring
  POS or payment at ticket-creation time.
- catchmenu_kds.commit_kds_ticket (0028) is a 7-condition AND gate; it will
  not release a ticket to READY_TO_COMMIT unless payment_confirmed = true
  among the other six conditions.
- kds_tickets.manual_fallback_activated exists as a column, and
  catchmenu_agent.activate_manual_fallback (0030) exists as a store-level
  fallback-log RPC, but NEITHER is read by commit_kds_ticket, start_cooking,
  or release_kds_after_payment. The manual-fallback machinery is not wired to
  ticket release at all today, and per 0016's own migration comment,
  MANUAL_FALLBACK means "staff handling manually, KDS bypassed" -- a
  system-failure/paper-ticket operating mode, not a payment-condition
  override.
- POS sync-pending does not block KDS ticket creation, but KDS ticket
  RELEASE is indirectly payment-coupled through the release RPCs (0098,
  0102, 0104), which assume provider payment evidence.
- KDS delivery today is a DB pull model (get_kds_realtime_state,
  bootstrap_kds_app) plus a Postgres NOTIFY hook with no consuming client;
  Flutter KDS is unimplemented; transition_kds_ticket does not exist as a
  function; target_device_id is never assigned in any insert path.
- A state-value drift exists: 0098's release path sets kds_status =
  'COMMITTED', which is not a member of 0016's chk_kds_status enum
  (HOLD, CAPACITY_CHECKING, READY_TO_COMMIT, COOKING, READY, SERVED,
  COMPLETED, CANCELLED, MANUAL_FALLBACK). This drift affects any payment
  path, not only the no-payment path, and is not fixed by 604500.
```

---

## 4. Approved Direction (Corrected)

```text
1. A STORE/TENANT-LEVEL no-payment KDS release POLICY is APPROVED in
   principle, scoped narrowly per §5-§6 below.
2. manual_fallback (the manual_fallback_activated column and the
   activate_manual_fallback/resolve_manual_fallback RPCs) is EXCLUDED from
   this release path entirely. It remains, unchanged, a system-failure /
   paper-ticket-fallback mechanism. It must not be read, checked, or
   referenced as a condition by any RPC created under this Gate.
3. A minimal SQL/RPC implementation that allows KDS HOLD release without
   payment_confirmed, gated instead on an explicit store/tenant-scoped
   no-payment policy flag (e.g. kds_payment_policy = 'NO_PAYMENT_PILOT', or
   payment_required_for_kds_release = false) PLUS an explicit staff/operator
   release authority, is APPROVED for the next Implementation stage (604502)
   only -- not performed by this Gate.
4. confirm_order's existing KDS HOLD ticket-creation structure is preserved
   unchanged. This Gate does not touch ticket creation.
5. The existing payment_confirmed release path (commit_kds_ticket,
   release_kds_after_payment, and the OKpos/Toss payment-confirm adapters)
   is NOT removed, NOT weakened, and NOT modified in its payment-mode
   behavior, for any store that remains in payment-required mode.
6. The store-level no-payment policy flag substitutes for payment_confirmed
   ONLY for stores/tenants explicitly configured with that policy. It is
   never a silent default, never store-unscoped, and never triggered by
   manual_fallback_activated.
7. Automatic POS integration (OKpos/Toss order-sync or payment-confirm
   wiring into this new path) is EXCLUDED from this scope.
8. Flutter KDS physical-screen implementation is EXCLUDED from this scope,
   or may be deferred as a read-only follow-up track at Human's later
   discretion -- it is not authorized here.
9. The KDS delivery protocol remains, for Stage 1, the existing DB-pull +
   NOTIFY model. Physical device push / target_device_id routing is
   EXCLUDED and deferred to a separate future track.
10. The COMMITTED vs READY_TO_COMMIT state-value drift is NOT automatically
    in scope. 604502 Implementation must make its own explicit, narrow
    determination (per §7 rule 9 below) of whether touching this drift is
    strictly necessary for the minimal no-payment release path to function,
    and if so, touch it minimally and document that decision; otherwise it
    must defer the drift to its own separate correction track.
11. A nominal/minimal real-money payment workaround (e.g. charging 1 KRW to
    reuse the existing payment-ledger code path instead of building a real
    no-payment policy) is NOT approved as a substitute for this scope. It
    contradicts the stated MVP-1 intent and is explicitly rejected as an
    implementation strategy under this Gate.
```

---

## 5. Approved Implementation Scope — A. SQL/RPC

```text
A minimal store-level no-payment KDS ticket release RPC (new function, or a
narrowly-scoped extension of the existing condition-check flow) is approved
for 604502 Implementation, subject to ALL of the following mandatory
properties:

1. The release condition is: payment_confirmed = false is PERMITTED to
   proceed ONLY IF the order's store/tenant has an explicit no-payment KDS
   release policy flag set to true/'NO_PAYMENT_PILOT' (604502 decides the
   exact column/table location -- e.g. a new column on the stores table, or
   a dedicated store-config table -- but it must be a genuine store/tenant-
   scoped configuration record, never manual_fallback_activated, and never
   an unscoped global flag) AND the caller carries an explicit staff/
   operator release authority (e.g. an actor/role check consistent with the
   existing can_override_kds staff permission field from 0053, or an
   equivalent explicit authority parameter -- 604502 decides the exact
   mechanism, but it must be an explicit, checked authority, never an
   implicit default).
2. Every no-payment-policy release MUST write an audit record and an
   event-log entry (consistent with the existing
   catchmenu_audit.append_audit_record and catchmenu_ledger.events patterns
   already used throughout this RPC family), explicitly recording that the
   release used the store-level no-payment policy (not payment_confirmed,
   not manual_fallback) and the authorizing actor.
3. tenant_id / store_id / order_id / ticket_id scope guards are MANDATORY --
   the release RPC must validate all four before acting, following the
   existing pattern in commit_kds_ticket and related RPCs.
4. Idempotency is MANDATORY -- calling the release RPC twice on an
   already-released ticket must not double-release, double-log, or error in
   a way that corrupts state; it must return a clear already-released result.
5. Unauthorized release MUST be blocked -- if the store's no-payment policy
   flag is not set, or the caller lacks release authority, the RPC must
   reject with a clear error_key, exactly as the existing RPC family does
   (e.g. 'no_payment_policy_not_active', 'unauthorized_release').
6. The state transition is STRICTLY LIMITED to:
     HOLD -> READY_TO_COMMIT, or
     HOLD -> COOKING
   (604502 decides which single target state the new RPC produces; it must
   not introduce a third state, and it must not itself implement the
   subsequent READY / COMPLETED transitions -- those continue to follow the
   existing KDS lifecycle RPCs (start_cooking, complete_cooking,
   serve_ticket, complete_order_kds) unchanged.)
7. manual_fallback_activated MUST NOT be read, checked, or referenced by
   this RPC in any capacity. If 604502 finds it necessary to distinguish a
   ticket released via no-payment policy from one released via manual
   fallback, it must use its own distinct field/flag -- never overload the
   existing manual_fallback_activated column with a new, unrelated meaning.
```

---

## 6. Approved Implementation Scope — B. Condition Structure

```text
1. The existing payment_confirmed = true release path is PRESERVED exactly
   as-is, for every store that remains in payment-required mode. No
   existing RPC's payment-mode behavior may be altered.
2. The new store-level no-payment-policy release path is PERMITTED ONLY for
   stores/tenants explicitly configured with the no-payment policy flag
   (604502 must not make this available unconditionally to every store,
   and must not derive it from manual_fallback_activated).
3. For a store with the no-payment policy active, that policy SUBSTITUTES
   for the payment_confirmed condition slot specifically for that store's
   orders -- it does not function as a generic "OR manual_fallback"
   condition across all stores. An audit reason MUST be recorded for every
   release, distinguishing "payment_confirmed path" from "store no-payment
   policy path."
4. manual_fallback_activated remains entirely outside this condition
   structure. It continues to mean only "system failure, KDS bypassed,
   paper tickets" and must not be read by any RPC created under this Gate.
```

---

## 7. Approved Implementation Scope — C. Required Test/Verification Coverage

```text
604502 Implementation, and the following 604503 Verification, must
demonstrate/confirm all of:

1. Without payment: confirm_order -> KDS ticket created in HOLD (unchanged
   behavior, re-confirmed not broken).
2. For a store with the no-payment policy active: release via the new RPC
   -> ticket reaches the approved target state (READY_TO_COMMIT or COOKING
   per §5 rule 6).
3. With payment_confirmed = false but the store's no-payment policy active
   AND a valid staff/operator authority present, the ticket CAN progress.
4. Without the store's no-payment policy active (and without
   payment_confirmed), the ticket CANNOT progress -- release is blocked,
   REGARDLESS of manual_fallback_activated's value.
5. With the store's no-payment policy active but WITHOUT staff/operator
   authority, the ticket CANNOT progress -- release is blocked.
6. Duplicate/repeated no-payment-policy release calls are idempotent.
7. tenant/store mismatch on the release call is blocked.
8. POS-sync-pending state does not block this KDS progression path (already
   true for ticket creation per 604500; must remain true here).
9. The existing payment_confirmed = true release path shows NO regression --
   it must behave exactly as it did before 604502, for stores that remain
   in payment-required mode.
10. Activating manual_fallback (activate_manual_fallback) on a store does
    NOT, by itself, release any KDS ticket -- confirming manual_fallback
    remains fully excluded from this release path.
```

---

## 8. Explicitly Excluded From This Scope

```text
- Using manual_fallback_activated as a payment_confirmed substitute or
  override condition, in any RPC.
- Mixing paper-ticket manual-fallback operation with the store-level
  no-payment KDS release policy -- they are separate concepts and must
  remain separate mechanisms.
- Any nominal/minimal real-money payment workaround (e.g. a 1 KRW charge)
  used to reuse the existing payment-ledger code path instead of
  implementing the store-level no-payment policy.
- Automatic POS integration implementation of any kind.
- Wiring OKpos/Toss POS RPCs (0102, 0104) into this new path.
- Flutter KDS screen implementation (kds_screen.dart, kds_ticket_card.dart,
  kds_state_notifier.dart, kds_repository.dart, or any equivalent).
- target_device_id physical push/device-routing implementation.
- Full KDS device delivery protocol implementation (HTTP push, websocket,
  local agent, or any transport beyond the existing DB-pull + NOTIFY model).
- Any mixing with, or reference to as precedent, the 604392-604395 Group A
  SQL residue disposition track (0035, 0038, 0042, 0046, 0063, 0065, 0066,
  0067, 0068) -- that track's files must not be touched by 604502, and this
  track's files must not be folded into that track's future commits.
- 0069 Analysis creation or modification.
- Scope D mainline resumption (604260, 604250, 604400/604310, 604316) in any
  form.
- Any unrelated SQL/migration residue disposition (Groups B/C/D/E from the
  604390 track).
- Any tools/* residue processing.
```

---

## 9. Special-File Reference Note

```text
014280_WorkPackage_POS_KDS_Manual_Fallback_And_First_Store_Readiness_Bridge.md
describes an OPERATIONAL SOP bypass (manual kitchen note, staff working
around the system entirely) -- it is a policy/ops document, not a runtime
implementation, and it describes the PAPER-TICKET manual-fallback concept,
which remains excluded from this Gate's release path per §8. 604502 may
reference 014280 for OPERATIONAL CONTEXT ONLY (to understand why a
no-payment mode is needed at all) and must NOT treat its SOP language, or
any mention of "manual fallback" in it, as authorization to wire
manual_fallback_activated into KDS release. The actual RPC contract
(conditions, guards, error keys, audit shape) must follow the existing KDS
RPC family's own code conventions (0028, 0029, 0030), not 014280's prose,
and must implement the STORE-LEVEL POLICY approach described in §5-§6, not
a manual-fallback override.
```

---

## 10. Mandatory Preservation Rules

```text
604502-604504 must preserve:

- confirm_order's existing KDS HOLD ticket-creation behavior, unmodified.
- The existing payment_confirmed = true release path and all its RPCs
  (commit_kds_ticket, release_kds_after_payment, authorize_kds_release),
  unmodified in payment-mode behavior.
- manual_fallback_activated, activate_manual_fallback, and
  resolve_manual_fallback, entirely unmodified and unreferenced by the new
  release path.
- The 21 SQL/migration residue paths and 4 tools/* residue paths from the
  604383-604392 track, exactly as currently present, untouched by this
  track.
- 604300_Index, 604306_NavigationMap, 604001 parent NavigationMap, and every
  previously-closed track document, unmodified.
- 0069 Analysis in its deferred, uncreated state.
- Scope D mainline in its current not-resumed state.
```

---

## 11. Final Approval Decision

```text
APPROVED_FOR_STORE_LEVEL_NO_PAYMENT_KDS_RELEASE_POLICY_WITH_MANUAL_FALLBACK_EXCLUDED
```

---

## 12. Explicitly Forbidden Work (For This Approval Gate Itself)

```text
- SQL modification of any kind.
- Migration modification of any kind.
- Runtime code modification of any kind.
- Flutter modification of any kind.
- tools/* modification of any kind.
- Using manual_fallback_activated as a payment_confirmed override condition
  in any document or design produced under this Gate.
- Creation or modification of 0069 Analysis.
- Resuming Scope D mainline in any form.
- Mixing with, or touching any file from, the 604392-604395 A1 SQL residue
  track.
- Staging of any file under this Gate.
- Any git commit under this Gate.
```

---

## 13. Required 604502 Implementation Output

```text
Codex must create:

604502_Implementation_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

The H1 must exactly match the full filename including .md.

604502 must record:

1. The exact new RPC (or extension) created, its full signature, and its
   condition/guard logic per §5, including the exact store/tenant-scoped
   no-payment policy flag mechanism chosen.
2. Confirmation that the existing payment_confirmed release path was not
   altered.
3. Confirmation that manual_fallback_activated, activate_manual_fallback,
   and resolve_manual_fallback were NOT read, modified, or referenced as a
   release condition.
4. Confirmation of the tenant/store/order/ticket scope guard, idempotency
   guard, and unauthorized-release rejection, per §5.
5. Confirmation of the audit/event logging added per §5 rule 2, including
   that it distinguishes the no-payment-policy path from the
   payment_confirmed path.
6. An explicit statement of whether the COMMITTED vs READY_TO_COMMIT drift
   was touched, and if so, exactly how narrowly, per §4 rule 10.
7. Confirmation that POS integration, Flutter KDS, device-push routing, and
   full delivery-protocol work were NOT performed.
8. Confirmation that no nominal/minimal real-money payment workaround was
   used.
9. Confirmation that the 604392-604395 Group A SQL residue track was not
   touched or mixed in.
10. Confirmation that 0069 Analysis was not created and Scope D mainline was
    not resumed.
11. Whatever actual SQL/migration file(s) were created or modified, listed
    explicitly with exact paths.
```

---

## 14. Required 604503 Verification

```text
The verifier must create:

604503_Verification_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

604503 must independently verify every item in §7 (the required test/
verification coverage), plus:

- 604502 exists with H1 matching its filename.
- No file outside 604502's declared change set was modified.
- manual_fallback_activated, activate_manual_fallback, and
  resolve_manual_fallback remain unread and unmodified by the new release
  path.
- The 604392-604395 Group A SQL residue track and its 9 files remain
  untouched.
- 0069 Analysis was not created; Scope D mainline was not resumed.
- git diff --check passes.
```

---

## 15. Required 604504 Audit

```text
The independent auditor must create:

604504_Audit_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

604504 must decide whether the minimal store-level no-payment KDS release
policy is accepted, rejected, or partially accepted, without expanding scope
into POS integration, Flutter KDS, device-push delivery, the 604392-604395
SQL residue track, 0069 Analysis, or Scope D mainline resumption. 604504
must explicitly re-confirm that manual_fallback was not used as a release
condition anywhere in the implementation.
```

---

## 16. Final Boundary Decision

```text
APPROVED_FOR_STORE_LEVEL_NO_PAYMENT_KDS_RELEASE_POLICY_WITH_MANUAL_FALLBACK_EXCLUDED
```

```text
Approved next artifact:

604502_Implementation_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

followed by:

604503_Verification_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md
604504_Audit_Wait_Order_POS_KDS_No_Payment_Manual_Fallback_Runtime_Path.md

manual_fallback_activated, activate_manual_fallback, and
resolve_manual_fallback are excluded from the release path and must remain
unread/unmodified. POS automatic integration, Flutter KDS, physical
device-push delivery, a nominal-payment workaround, and the COMMITTED vs
READY_TO_COMMIT drift (beyond the minimal, explicitly-justified touch
permitted by §4 rule 10) remain excluded or deferred. The 604392-604395 A1
SQL residue track remains a separate, unmixed track. 0069 Analysis remains
deferred. Scope D mainline remains blocked.

604502 Implementation was BLOCKED under the original flawed approval
direction (manual_fallback-as-override was never a valid basis for
implementation). It is now AUTHORIZED to proceed under the corrected
store-level no-payment policy direction in this document.
```
