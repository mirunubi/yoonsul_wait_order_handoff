# 604409_ChangeContract_Scope_D_01_Payment_Confirm_Idempotency.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: Scope D Slice 01 Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after 604316 Human Approval explicitly lists allowed files.

---

## 0. Purpose

Lock in, at the candidate-boundary level, what `604404` may eventually be approved to touch — so that when `604316` Human Approval is written, it has a single, reviewed source to narrow from, rather than re-deriving scope from `604405` alone.

---

## 1. Contract Status

```text
Draft. Not approved. Not binding on Codex.
This document does not itself authorize any file to be created or modified.
It becomes actionable only when 604316 Human Approval (a separate document, not yet written)
explicitly names a subset of the candidates below as Allowed Files with Allowed Operations.

604404 implementation is NOT authorized by this document, and remains blocked even after
  this document is read, until BOTH of the following close:
  (a) Schema Drift Alignment (policy update, 2026-07-01) — payment_ledger/confirm_payment
      physical schema contract alignment, intent_id binding, provider_payment_key vs
      provider_tx_id naming, undefined fee_amount reference risk, confirm_payment
      compile/dry-run verification. No 604305 document exists yet; this is a policy
      requirement, not a created file.
  (b) Every Required Human Decision in §5 below, with Owner assigned.
604316 Human Approval remains deferred until both (a) and (b) close.
Target is 0098 confirm_payment only. 0027 confirm_payment_from_provider, provider webhook
  callback redesign, Edge Function webhook integration, provider-specific callback routing,
  and full provider pipeline consolidation are explicitly excluded from this slice.
```

---

## 2. Allowed Future Change Candidates

Candidate only — restates and narrows `604405` §10:

| Priority | Path | Likely change type (candidate, not approved) |
| --- | --- | --- |
| P0 | **New** `sql/migrations/01NN_patch_confirm_payment_idempotency.sql` (`NN` ≥ 40, re-verified immediately before implementation) | Patch `confirm_payment`'s duplicate-return and amount-mismatch-enforcement logic per `604407` §3–§4 |
| P1 (reference only) | `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | Read-only reference. In-place edit forbidden by policy (`604302` §10, `900102`). |
| P2 (reference only) | `sql/migrations/0014_create_payment_ledger.sql` | Read-only reference for schema-drift reconciliation research (Required Human Decision #5) — not itself a target for edit under this contract |
| P3 (reference only) | `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Read-only reference for Toss caller alignment research only |
| P4 (reference only) | `sql/migrations/0027_create_payment_intent_rpc.sql` | **Explicitly excluded from edit.** Read-only reference for `confirm_payment_from_provider` comparison only; recorded as a future split-brain consolidation concern, not a 604404 target (`604301` §7.7) |
| Test candidate | A new test file under whatever test path Human Approval names (none exists yet for `confirm_payment` — `604405` §7 confirms `tests/` has no matches) | Per `604408` §1 |

**Nothing in this table is approved.** A future, narrower Human Approval (`604316`) is required to convert any row above into an actual Allowed File.

---

## 3. Forbidden Files

```text
Everything not explicitly named in a future 604316 Human Approval, including but not limited to:

sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql   (in-place edit)
sql/migrations/0014_create_payment_ledger.sql                 (in-place edit)
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql     (in-place edit)
sql/migrations/0027_create_payment_intent_rpc.sql             (in-place edit)
Any other existing migration file                             (in-place edit)
supabase/**                                                    (Edge Functions, config)
catchmenu_app/**                                                (Flutter/Dart)
**/*.py                                                         (Python tooling)
**/*.json, **/*.yaml, **/*.yml, **/*.toml                       (config/seed)
604300–604304 master pack documents                            (modify without separate governance task)
604320–604380 sub-workpacket folders                           (except this 604404 folder)
release_kds_after_payment function body (in 0098 or any patch) (604320's boundary)
GRANT/REVOKE statements of any kind                             (604350's boundary)
implementation_module.md, verification_result.md, audit_review.md, 604316 Human Approval
```

---

## 4. Forbidden Operations

```text
- Writing any SQL, migration, Edge Function, Flutter, Dart, Python, or config file.
- Creating any test file.
- Modifying release_kds_after_payment's body or call signature.
- Modifying any existing migration file in place.
- Introducing a new architecture layer, generic helper, or broad refactor.
- Deciding, on behalf of a human, any of the six Required Human Decisions in §5.
- Instructing Codex to implement anything from this document.
- Writing 604316 Human Approval (that is a separate, human-authored artifact).
- Resolving Owner: TBD.
```

---

## 5. Required Human Decisions

**Reframed by policy update (2026-07-01) — see `604407` §3-bis, §4, §5, §6 for the design detail behind each item:**

```text
1. Duplicate confirm / same-success replay: exact implementation shape of "same
   effective_idempotency_key + same request_fingerprint -> same-success payload" —
   rebuild from current state at return time vs. cache/replay the original response
   verbatim (604407 §3-bis). The replay POLICY itself is now set; this decision is about
   mechanics, not whether replay happens.

2. Amount mismatch enforcement mechanics: the hard-block DIRECTION is now policy-set
   (604407 §4: block APPROVED, block payment_confirmed, block KDS release, default MVP
   tolerance = 0 KRW). Remaining decision: exact rejection vs. reconciliation_required
   mechanics, and whether/when any provider-specific tolerance is ever approved (it is
   NOT introduced by default).

3. effective_idempotency_key source mapping: which of the seven priority tiers
   (payment_intent_id, provider payment key, provider request row, VAN TID+approval,
   adapter-derived key, server-derived transitional key, unresolved->reconciliation)
   are actually available at each 604404 call site, and in what order to try them
   (604407 §3-bis, §5). p_correlation_id null is no longer, by itself, a rejection
   ground — this decision is about identity resolution, not correlation_id policy.

4. request_fingerprint field set: exactly which request fields (amount, provider_type,
   payment_method, others) compose request_fingerprint, and how it is stored/compared
   (604407 §3-bis).

5. Schema drift: 0014's payment_ledger.intent_id (NOT NULL) and provider_payment_key column
   vs. 0098's INSERT (no intent_id, provider_tx_id column) — must be reconciled or explicitly
   understood (e.g., confirmed dead column, confirmed default exists elsewhere) BEFORE any
   patch migration touches the INSERT statement. **This is now a required precondition
   (Schema Drift Alignment, §1 above), not merely a decision to record** — 604316 cannot be
   finalized while this is open, independent of the other seven items in this list.

6. confirm_payment_from_provider (0027): keep as a separate legacy/VAN path, align its
   amount-mismatch behavior with confirm_payment's eventual policy, or schedule deprecation.
   Not decided by this slice. 0027 itself remains excluded from any 604404 edit regardless
   of how this question resolves.

7. Migration number: 0140 is the candidate as of 2026-07-01; must be re-confirmed against
   sql/migrations/ immediately before Codex implementation, since new migrations may land
   between this document and that point.

8. Owner assignment: this slice currently has Owner: TBD in all five documents (604405-604409).
   Human Approval (604316) cannot be finalized while Owner remains TBD.
```

---

## 6. Required Verification

Reference only — restates `604408` §2, not executed here:

```text
grep -n "payment_already_confirmed" sql/migrations/0098_...   (pre-patch baseline)
grep -n "payment_amount_mismatch" sql/migrations/0098_...     (pre-patch baseline)
ls sql/migrations/ | sort -t_ -k1 -n | tail -10                (migration number re-check)
git diff --check -- sql/migrations/                            (no existing-file edits)
```

---

## 7. Rollback Policy

```text
Because this document authorizes nothing, rollback here is trivial: delete or revert
604406-604409.

For the FUTURE patch migration (once approved and implemented under a separate 604316):
  rollback must be a companion DOWN migration or explicit reversal statement, per project
  migration convention, and must not require editing 0098 or any other existing file.
  Rollback strategy itself is a 604316-time decision, not decided here.
```

---

## 8. Boundary With 604320 And 604330

```text
604320 (release_kds_after_payment guard): 604404 must never patch that function's body.
  If a future confirm_payment patch changes the shape of what it passes to
  release_kds_after_payment (e.g., a new duplicate-detection outcome), that call-site
  change is visible to 604330, not to 604320's internal guard logic.

604330 (confirm→release transaction boundary / split-brain): 604404 owns "does a duplicate
  confirm avoid a second release call" (604407 §8) as a narrow behavior. 604330 owns the
  broader partial-failure / split-brain handling of the SAME call site. If both slices need
  to touch the same lines around L344-357 of 0098 (or its eventual patch), their respective
  604316 Human Approvals must declare non-overlapping line/function ownership before either
  proceeds, per 604301 §6.1 and 604304 §4's carried-forward overlap warning.
```

---

## 9. Codex Instruction Boundary

```text
No Codex instruction exists in this document or any of 604406-604408.
Codex must not read this ChangeContract as a work order.
Codex may act only after a separate 604316 Human Approval names specific Allowed Files
and Allowed Operations, per 600179 Stage 3 and Stage 4.
```

---

## 10. Acceptance Criteria

```text
This ChangeContract (604409) is complete when:
  - All candidate files/operations above are traceable to 604405/604407/604408 findings
    (no new, undiscussed candidate introduced here).
  - All 8 Required Human Decisions are recorded, none silently resolved.
  - No Forbidden File or Forbidden Operation is ambiguous.
  - Owner remains explicitly TBD (not filled in by this document).
  - No Human Approval statement appears anywhere in 604406-604409.
```

---

## 11. Final Rule

```text
This document narrows 604405's candidate list and records the decisions a human must make
before 604316 can exist. It does not make those decisions, does not approve any file, and
does not instruct Codex. Schema Drift Alignment (§1, §5 item 5) must close in addition to
these decisions before 604316 may be written. The next required work is schema drift
alignment precondition handling, not 604316 directly. When both close, 604316 Human
Approval — authored by a human, not by Claude, and not part of this pass — is the
following document in this slice's lifecycle.
```
