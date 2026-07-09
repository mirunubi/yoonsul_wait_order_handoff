# 604265_ChangeContract_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: Scope D 00A Toss MVP PaymentIntent Binding Precondition Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-02

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after 604266 Human Approval explicitly lists allowed files.

---

## 0. Purpose

Lock in, at the candidate-boundary level, what `604260` may eventually be approved to touch — so that when `604266` Human Approval is written, it has a single, reviewed source to narrow from, rather than re-deriving scope from `604261` alone. This slice exists because `604256`-approved `604250` implementation stalled on a real Toss MVP payment_intent binding gap; it is a precondition for `604250` resuming, not a feature slice in its own right, and not a re-opening of `604250`'s own approved scope.

---

## 1. Contract Status

```text
Draft. Not approved. Not binding on Codex.
This document does not itself authorize any file to be created or modified.
It becomes actionable only when 604266 Human Approval (a separate document, not yet
written) explicitly names a subset of the candidates below as Allowed Files with
Allowed Operations.

604250 implementation resumption is NOT authorized by this document, and remains
paused even after this document is read, until:
  (a) This slice (604260) closes via its own 604266 Human Approval and subsequent
      implementation/verification/audit.
  (b) 604250's own resumption is separately re-authorized (this may reuse 604256's
      existing approval scope if unaffected by this slice's patch, or require an
      explicit update to 604256 if the confirm_payment interface changes as a result
      of this slice's work — 604265 §5 item 10 records this as open).
Closing 604260 removes one blocker; it does not itself restart 604250's Codex work.
```

---

## 2. Allowed Future Change Candidates

Candidate only — restates and narrows `604261` §11:

| Priority | Path | Likely change type (candidate, not approved) |
| --- | --- | --- |
| P0 | **New** `sql/migrations/01NN_patch_toss_payment_intent_binding.sql` (`NN` ≥ 40, re-verified immediately before implementation) | `ALTER TABLE toss_payment_requests ADD payment_intent_id uuid REFERENCES payment_intents(id)`, plus `CREATE OR REPLACE FUNCTION` for `initiate_toss_payment` and/or `confirm_toss_payment` (or new wrapper RPC names), per whichever strategy (`604263` §3) Human Approval selects |
| P1 (reference only) | `sql/migrations/0014_create_payment_ledger.sql` | Read-only reference. In-place edit forbidden by policy. |
| P1 (reference only) | `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | Read-only reference. In-place edit forbidden by policy — this file's own patch belongs to `604250`, not this slice. |
| P1 (reference only) | `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Read-only reference for the exact functions/columns this slice's patch replaces via `CREATE OR REPLACE` — **the committed file itself is never edited in place** |
| P1 (reference only) | `sql/migrations/0027_create_payment_intent_rpc.sql` | Read-only reference for the `create_payment_intent` pattern this slice's patch invokes — **never an edit target, permanently, under this contract or any future one scoped to this schema-drift lineage** |
| P2 (reference only) | `sql/migrations/0052_create_kiosk_session_rpc.sql` | Read-only reference for the existing working `create_payment_intent` caller pattern |

**Nothing in this table is approved.** A future, narrower Human Approval (`604266`) is required to convert any row above into an actual Allowed File.

---

## 3. Forbidden Files

```text
Everything not explicitly named in a future 604266 Human Approval, including but not
limited to:

sql/migrations/0014_create_payment_ledger.sql                (in-place edit)
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql  (in-place edit; also not
                                                               this slice's patch target
                                                               at all — that is 604250's)
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql    (in-place edit)
sql/migrations/0027_create_payment_intent_rpc.sql            (in-place edit — always,
                                                               permanently excluded)
sql/migrations/0052_create_kiosk_session_rpc.sql             (in-place edit)
Any other existing migration file                            (in-place edit)
supabase/**                                                    (Edge Functions, config)
catchmenu_app/**                                                (Flutter/Dart)
**/*.py                                                         (Python tooling)
**/*.json, **/*.yaml, **/*.yml, **/*.toml                       (config/seed)
604250 implementation artifacts (604257 Module, or any resumed 604250 patch work)      —
  separate authorization; this slice does not touch or restart it
604300-604304, 604310-604315 master/sibling-slice documents     (modify without separate
                                                                 governance task)
604266 Human Approval (a separate, human-authored artifact — not written here)
implementation_module.md, verification_result.md, audit_review.md
604267 Module, 604268 Verification, 604269 Audit
604320-604380 sub-workpacket folders
```

---

## 4. Forbidden Operations

```text
- Writing any SQL, migration, Edge Function, Flutter, Dart, Python, or config file.
- Creating any test file.
- Modifying 0027 in this slice, or any future slice inheriting this contract, under any
  circumstance.
- Modifying any existing migration file in place.
- Resuming or instructing 604250's own Codex implementation from this document.
- Implementing 604250's own confirm_payment INSERT/WHERE column-drift fix — this
  slice's patch may only add the interface this slice's own scope requires (e.g. the
  link column and Toss-side call, per whichever option is approved); it must not
  reach into confirm_payment's INSERT/WHERE body, which remains 604250's exclusive
  edit surface.
- Implementing idempotency same-success logic (604310's problem).
- Implementing amount mismatch hard-block business logic (604310's problem).
- Creating a synthetic payment_intent at confirm time (604256 §3 default prohibition).
- Binding intent_id via weak guesswork (order_id-only, most-recent-pending,
  session-id-only) (604256 §3 default prohibition).
- Introducing a new architecture layer, generic helper, or broad refactor.
- Deciding, on behalf of a human, any of the twelve Required Human Decisions in §5.
- Instructing Codex to implement anything from this document.
- Writing 604266 Human Approval (that is a separate, human-authored artifact).
- Resolving Owner: TBD.
```

---

## 5. Required Human Decisions

```text
1. Strategy choice: Option A (patch initiate_toss_payment to call create_payment_intent
   and store the id), Option B (dedicated helper/wrapper), Option C (resolver-only —
   rejected by default if it depends on weak order_id lookup), or Option D (synthetic
   confirm-time intent — rejected by default) (604263 §3-§4).

2. payment_intent creation timing: before Toss request creation, during Toss request
   creation (same transaction as the toss_payment_requests insert), or before confirm
   only (604263 §5).

3. toss_payment_requests schema: add a payment_intent_id FK column, use a
   provider_order_id-based mapping instead, or a helper-only approach with no DDL
   change to this table (604263 §6).

4. Idempotency coordination: share one idempotency_key between payment_intents and
   toss_payment_requests, derive a linked-but-namespaced key, or keep independent keys
   with the FK column as the sole explicit mapping (604263 §9).

5. provider_order_id vs order_id_toss: normalize the naming/format so both align,
   keep both with the FK column as the true link (mismatch accepted), or plan a later
   migration to reconcile (604263 §11).

6. session_id null: block initiate_toss_payment when no session_id is resolvable,
   allow a nullable intent session (column already permits null), or create a fallback
   session before calling create_payment_intent (604263 §10).

7. FAILED intent retry: reuse an existing active/non-terminal intent for a retried
   attempt, always create a new attempt (interacting with create_payment_intent's
   active-intent guard), or require manual reconciliation (604263 §9).

8. confirm_toss_payment patch scope: CREATE OR REPLACE allowed for both
   initiate_toss_payment and confirm_toss_payment, wrapper-only (new RPC names,
   existing functions untouched), or defer confirm_toss_payment's own patch until
   604250's interface (§9 below) is finalized (604263 §7-§8).

9. Webhook DONE path: patch the same underlying confirm_toss_payment path (webhook
   inherits automatically, per 604261 §6.4), defer, or block webhook confirms until
   the direct client-confirm path is proven safe first (604263 §1, §7).

10. 604250 interface dependency: whether 604250's own (already-designed but not yet
    re-verified) patch must add a p_intent_id parameter directly to confirm_payment's
    signature, or instead resolve intent_id itself by reading
    toss_payment_requests.payment_intent_id internally — this decision determines
    whether this slice's confirm_toss_payment patch needs to pass an explicit
    argument at all (604263 §8).

11. Migration number: re-check 0140+ immediately before implementation — the number
    may be claimed by whichever of this slice's or 604250's patch merges first.

12. Owner assignment: this slice currently has Owner: TBD in all four documents
    (604262-604265). Human Approval (604266) cannot be finalized while Owner remains
    TBD.
```

---

## 6. Required Verification

Reference only — restates `604264` §2, not executed here:

```text
grep -n "create_payment_intent\|insert into.*payment_intents" sql/migrations/0103_...
grep -n "confirm_payment(" sql/migrations/0103_...
grep -rn "create_payment_intent(" sql/migrations/
ls sql/migrations/ | sort -t_ -k1 -n | tail -10
git diff --check -- sql/migrations/
```

---

## 7. Rollback Policy

```text
Because this document authorizes nothing, rollback here is trivial: delete or revert
604262-604265.

For the FUTURE binding patch (once approved and implemented under a separate 604266):
  rollback must be a companion DOWN migration or explicit reversal statement, per
  project migration convention, and must not require editing 0014, 0098, 0103, or 0027.
  If toss_payment_requests gained a payment_intent_id column, rollback must account for
  any rows written against it during the time the patch was live — rollback strategy
  itself is a 604266-time decision, not decided here.
```

---

## 8. Boundary With 604250

```text
604260 exists to unblock 604250, not to absorb or redesign 604250's scope. This
slice's own patch (if approved) may:
  - add a link column on toss_payment_requests,
  - patch (via CREATE OR REPLACE, new migration) initiate_toss_payment and/or
    confirm_toss_payment to create/resolve and carry an intent_id.

This slice's patch must NOT:
  - modify confirm_payment's own INSERT/WHERE body (604250's exclusive surface),
  - implement 604310's idempotency or amount-mismatch policy,
  - decide 604250's remaining Required Human Decisions (604255 §5) on its own behalf.

Sequencing: whichever of this slice's patch or 604250's patch is implemented first
must not assume the other's schema/interface changes already exist, unless both are
explicitly combined into a single coordinated migration under one Human Approval —
that combination decision is itself Required Human Decision #8 above, not assumed here.

Closing this slice does not automatically re-open 604250's Codex authorization. 604256
(604250's existing approval) already states 604310 remains blocked until 604250
completes, its Module/Verification/Audit pass, and Human confirms schema drift
alignment is closed (604256 §16) — this slice's closure is a step toward that, not a
substitute for it.
```

---

## 9. Codex Instruction Boundary

```text
No Codex instruction exists in this document or any of 604262-604264.
Codex must not read this ChangeContract as a work order.
Codex may act only after a separate 604266 Human Approval names specific Allowed Files
and Allowed Operations, per 600179 Stage 3 and Stage 4.
This document does not instruct Codex to resume 604250 under any circumstance.
```

---

## 10. Acceptance Criteria

```text
This ChangeContract (604265) is complete when:
  - All candidate files/operations above are traceable to 604261/604263/604264 findings
    (no new, undiscussed candidate introduced here).
  - All 12 Required Human Decisions are recorded, none silently resolved.
  - No Forbidden File or Forbidden Operation is ambiguous.
  - 0027's permanent exclusion is stated explicitly, not just implied by omission.
  - The boundary with 604250 (§8) is explicit: this slice unblocks 604250, it does not
    merge scope with it or re-authorize it.
  - Owner remains explicitly TBD (not filled in by this document).
  - No Human Approval statement appears anywhere in 604262-604265.
```

---

## 11. Final Rule

```text
This document narrows 604261's candidate list and records the twelve decisions a human
must make before 604266 can exist. It does not make those decisions, does not approve
any file, does not instruct Codex, and does not resume 604250. The next document in
this slice's lifecycle is Human Approval (604266) — authored by a human, not by Claude,
and not part of this pass. Only after 604266 closes, and 604250's own resumption is
separately confirmed or re-authorized, does 604250's implementation proceed — and only
after that, per 604256 §16, does 604310's own blocked status become eligible for
reassessment.
```
