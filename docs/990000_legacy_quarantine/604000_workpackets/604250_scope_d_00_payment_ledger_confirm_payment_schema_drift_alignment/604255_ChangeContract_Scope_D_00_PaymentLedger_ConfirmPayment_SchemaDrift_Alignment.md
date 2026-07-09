# 604255_ChangeContract_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

Status: Draft
Lifecycle: ChangeContract
Gate Classification: Scope D 00 Schema Drift Alignment Change Contract Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This ChangeContract does not authorize implementation.
It defines candidate future boundaries only.
Codex may implement only after 604256 Human Approval explicitly lists allowed files.

---

## 0. Purpose

Lock in, at the candidate-boundary level, what `604250` may eventually be approved to touch — so that when `604256` Human Approval is written, it has a single, reviewed source to narrow from, rather than re-deriving scope from `604251` alone. This slice exists as a **precondition** for `604310`, not a feature slice in its own right.

---

## 1. Contract Status

```text
Draft. Not approved. Not binding on Codex.
This document does not itself authorize any file to be created or modified.
It becomes actionable only when 604256 Human Approval (a separate document, not yet
written) explicitly names a subset of the candidates below as Allowed Files with
Allowed Operations.

604310 implementation (604316 Human Approval) remains blocked until BOTH close:
  (a) This slice (604250) is verified/closed via its own 604256 Human Approval.
  (b) Every Required Human Decision already recorded in 604315 §5 is separately resolved.
Closing 604250 does not automatically unblock 604310 — it removes one precondition
among several.
```

---

## 2. Allowed Future Change Candidates

Candidate only — restates and narrows `604251` §12:

| Priority | Path | Likely change type (candidate, not approved) |
| --- | --- | --- |
| P0 | **New** `sql/migrations/01NN_patch_payment_ledger_schema_alignment.sql` (`NN` ≥ 40, re-verified immediately before implementation) | `ALTER TABLE` DDL extension and/or view/compatibility layer, per whichever strategy (`604253` §4) Human Approval selects — content not decided here |
| P0 | **New patch** replacing or wrapping `confirm_payment`'s `INSERT`/`WHERE` | Reconcile column references per approved strategy (`604253` §4–§9) |
| P1 (reference only) | `sql/migrations/0014_create_payment_ledger.sql` | Read-only reference. In-place edit forbidden by policy. |
| P1 (reference only) | `sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql` | Read-only reference. In-place edit forbidden by policy. |
| P1 (reference only) | `sql/migrations/0027_create_payment_intent_rpc.sql` | Read-only reference for the DDL-conformant pattern only — **never an edit target under this contract or any future one scoped to this slice** |
| P2 (deferred candidate) | `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql`, `0109_create_network_handoff_fallback_rpc.sql`, `0130_create_van_handler_extension.sql` | Downstream column alignment, only if a single-column-contract strategy is chosen and Human Approval explicitly expands scope to include them (`604253` §12, item 7 below) |

**Nothing in this table is approved.** A future, narrower Human Approval (`604256`) is required to convert any row above into an actual Allowed File.

---

## 3. Forbidden Files

```text
Everything not explicitly named in a future 604256 Human Approval, including but not
limited to:

sql/migrations/0014_create_payment_ledger.sql                (in-place edit)
sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql  (in-place edit)
sql/migrations/0027_create_payment_intent_rpc.sql            (in-place edit — always,
                                                               under any future contract
                                                               scoped to this slice)
sql/migrations/0103_create_toss_payments_pipeline_rpc.sql    (in-place edit)
sql/migrations/0109_create_network_handoff_fallback_rpc.sql  (in-place edit)
sql/migrations/0130_create_van_handler_extension.sql         (in-place edit)
Any other existing migration file                            (in-place edit)
supabase/**                                                    (Edge Functions, config)
catchmenu_app/**                                                (Flutter/Dart)
**/*.py                                                         (Python tooling)
**/*.json, **/*.yaml, **/*.yml, **/*.toml                       (config/seed)
604300-604304, 604310-604315 master/sibling-slice documents     (modify without separate
                                                                 governance task)
604256 Human Approval (a separate, human-authored artifact — not written here)
implementation_module.md, verification_result.md, audit_review.md
604320-604380 sub-workpacket folders
```

---

## 4. Forbidden Operations

```text
- Writing any SQL, migration, Edge Function, Flutter, Dart, Python, or config file.
- Creating any test file.
- Modifying 0027 in this slice, or any future slice inheriting this contract, under any
  circumstance — 0027 is reference-only, permanently, for this schema-drift lineage.
- Modifying any existing migration file in place.
- Implementing idempotency same-success logic (604310's problem).
- Implementing amount mismatch hard-block business logic beyond what is strictly
  necessary to prevent an impossible/inconsistent ledger write that this slice's own
  schema reconciliation would otherwise introduce (604253 boundary reminder).
- Introducing a new architecture layer, generic helper, or broad refactor.
- Deciding, on behalf of a human, any of the ten Required Human Decisions in §5.
- Instructing Codex to implement anything from this document.
- Writing 604256 Human Approval (that is a separate, human-authored artifact).
- Resolving Owner: TBD.
```

---

## 5. Required Human Decisions And Recommended Defaults

**Purpose of this section (2026-07-01 update):** each of the ten items below still requires an explicit Human decision — nothing here is self-executing, and nothing here is a `604256` Human Approval. What changed is that each item now carries a **Recommended Default**, reasoned from `604251`/`604253`'s findings, so the Human Owner can accept or override a concrete position instead of choosing among undifferentiated options. This is an **Implementation Decision Register**, not an approval.

### 5.1 Strategy Choice

```text
Recommended default:
  B RPC Alignment first.
  C Hybrid only if actual DDL inspection proves necessary.
  A-only DDL Extension is not recommended.

Meaning:
  - Align 0098 confirm_payment's RPC to the 0014 payment_ledger DDL first.
  - Allow Hybrid (Option C) only when a genuine, confirmed DDL gap is found during
    actual inspection — not preemptively.
  - Do not force-extend the table merely because the RPC is drifted.

Do not add columns only to satisfy a drifted RPC unless the column is approved as part
of the long-term ledger contract.
```

### 5.2 intent_id Binding

```text
Recommended default:
  Lifecycle default: payment_intent must be created before provider confirm whenever
    the flow supports it.
  RPC binding default: confirm_payment should receive p_intent_id when available.
  Fallback: a strong exactly-one resolver lookup is allowed.
  Prohibited by default: synthetic intent creation during confirm.

Principle:
  APPROVED payment_ledger write is prohibited unless intent_id is resolved exactly once.

Zero-match / multiple-match policy:
  0 matching intent            -> INTENT_BINDING_REQUIRED
  More than one matching intent -> INTENT_BINDING_CONFLICT

Do not bind intent_id from weak guesswork such as "same order_id, probably this intent"
or "most recent pending intent".
```

### 5.3 Toss MVP Path

```text
Recommended default:
  Toss MVP must create or bind a payment_intent before APPROVED ledger write.

Policy:
  If the current Toss MVP path does not create payment_intents upstream, implementation
  must stop and open a pre-confirm intent creation/binding patch.

Target lifecycle:
  Order checkout begins
  -> payment_intent created
  -> toss_payment_request created and linked to payment_intent
  -> Toss approval / confirm returns paymentKey
  -> confirm_payment binds to existing payment_intent
  -> payment_ledger APPROVED row inserted
```

### 5.4 Provider Key Naming

```text
Recommended default:
  provider_payment_key is authoritative.
  provider_tx_id is a compatibility alias only.

Policy:
  provider_tx_id may be accepted as a legacy input alias, but it must be normalized
  before ledger insert. payment_ledger should use provider_payment_key as the standard
  PG payment identifier.

Recommended semantic separation:
  provider_payment_key      -- PG payment key, e.g. Toss paymentKey
  provider_approval_no      -- VAN/card approval number
  provider_tid              -- VAN/POS terminal or transaction TID
  provider_transaction_id   -- generic external transaction id only if explicitly needed
```

### 5.5 fee_amount

```text
Recommended default:
  Do not add fee_amount in Scope D.
  Remove the undefined fee_amount insert.
  Defer the fee model to a settlement/reconciliation slice.

Prohibited:
  Do not add fee_amount integer not null default 0.

Reason:
  0 fee and unknown fee are not equivalent.

Future option only (not approved here):
  If fees are needed later, use nullable settlement-oriented fields such as
  provider_fee_amount, fee_source, fee_confirmed_at in a dedicated settlement slice.
```

### 5.6 provider_response

```text
Recommended default:
  Prefer provider_response_id FK or raw event reference.
  Avoid a full provider_response jsonb snapshot in payment_ledger unless explicitly
  approved.

Policy:
  If a provider response/raw event table exists, payment_ledger should reference it by
  provider_response_id. If it does not exist, do not urgently add a full
  provider_response jsonb column to the ledger in this slice. Use raw_payload_hash or
  audit/event evidence where appropriate.
```

### 5.7 Refund / Downstream Paths

```text
Recommended default:
  Include 0109/0130 only if blocking. Otherwise defer.

Policy:
  0109/0130 should be inspected for direct compile/runtime blockers caused by the 604250
  patch. Do not redesign refund, cancel, settlement, provider webhook, or downstream
  reconciliation flows in this slice.
```

### 5.8 0027

```text
Recommended default:
  Keep 0027 excluded.
  Document it as a future split-brain consolidation target.

Policy:
  Do not modify 0027_create_payment_intent_rpc.sql in this slice.
  Do not unify confirm_payment_from_provider with 0098 confirm_payment in this patch.

Future debt (not approved here):
  All payment confirmation paths should eventually pass through a shared
  confirm_payment_core, but that consolidation is future work.
```

### 5.9 Migration Number

```text
Recommended default:
  Recheck the highest migration prefix immediately before implementation.
  Create an append-only patch migration only.

Prohibited:
  Do not modify 0014 in place.
  Do not modify 0098 in place.
  Do not modify 0027 in place.
  Do not reuse or renumber existing migrations.

0140+ is an expected candidate only, not a confirmed number — it must be re-verified
against sql/migrations/ immediately before implementation, since new migrations may
land between this document and that point.
```

### 5.10 Owner

```text
Recommended default:
  Owner: 정영석 / System Owner
  Reviewer: 정영석 / Human Reviewer
  Approval Authority: Human Owner

Owner default is recorded here for decision tracking. 604256 Human Approval must still
explicitly confirm Owner / Reviewer / Approval Authority before implementation.
```

---

## 6. Required Verification

Reference only — restates `604254` §2, not executed here:

```text
grep -n "intent_id\|ledger_entry_type\|provider_payment_key\|provider_response_id" sql/migrations/0014_...
grep -n "provider_tx_id\|fee_amount\|payment_method\|provider_response" sql/migrations/0098_...
ls sql/migrations/ | sort -t_ -k1 -n | tail -10
git diff --check -- sql/migrations/
```

---

## 7. Rollback Policy

```text
Because this document authorizes nothing, rollback here is trivial: delete or revert
604252-604255.

For the FUTURE alignment patch (once approved and implemented under a separate 604256):
  rollback must be a companion DOWN migration or explicit reversal statement, per
  project migration convention, and must not require editing 0014, 0098, or 0027.
  If DDL was extended (Option A/C), rollback must account for any rows written against
  the new columns during the time the patch was live — rollback strategy itself is a
  604256-time decision, not decided here.
```

---

## 8. Boundary With 604310

Reference-direction reauthorization boundary:

```text
604260 closure is a prerequisite closure only.

604260 implementation, verification, and audit do not automatically resume 604250 implementation.

604250 implementation may resume only after explicit Human reauthorization confirms that the 604260 output contract is available for 604250 consumption.
```

```text
604250 is a precondition for 604310, not a merge of scope with it. 604250's own patch
(if approved) may touch confirm_payment's INSERT/WHERE clause to fix the physical
column contract, but must NOT implement:
  - effective_idempotency_key / request_fingerprint resolution (604313 §3-bis)
  - same-success replay behavior (604313 §3-bis, 604302 §2.4)
  - amount mismatch hard-block business policy (604313 §4) beyond what the schema
    reconciliation itself strictly requires to avoid an impossible write

If 604250's patch and 604310's eventual patch would touch overlapping lines of
confirm_payment (likely, since both touch the INSERT/WHERE region), 604250's patch
must land and close first. 604310's own 604316 Human Approval must be written against
whatever confirm_payment looks like AFTER 604250's patch, not against today's 0098 —
604313's design (effective_idempotency_key, request_fingerprint) already anticipates
this by describing target behavior in terms of concepts, not exact current line numbers.
```

---

## 9. Codex Instruction Boundary

```text
No Codex instruction exists in this document or any of 604252-604254.
Codex must not read this ChangeContract as a work order.
Codex may act only after a separate 604256 Human Approval names specific Allowed Files
and Allowed Operations, per 600179 Stage 3 and Stage 4.
```

---

## 10. Acceptance Criteria

```text
This ChangeContract (604255) is complete when:
  - All candidate files/operations above are traceable to 604251/604253/604254 findings
    (no new, undiscussed candidate introduced here).
  - All 10 Required Human Decisions are recorded, each with a Recommended Default,
    none silently resolved as final.
  - No Forbidden File or Forbidden Operation is ambiguous.
  - 0027's permanent exclusion is stated explicitly, not just implied by omission.
  - Owner remains explicitly TBD in this document's own metadata (the §5.10 default is
    a recommendation for 604256 to confirm, not a value this document sets).
  - No Human Approval statement appears anywhere in 604252-604255.

604256 Human Approval may be drafted only after the Decision Register defaults in §5
are reviewed and either accepted or overridden by the Human Owner, item by item.
This ChangeContract still does not authorize implementation.
Codex may implement only after 604256 Human Approval explicitly lists allowed files
and records the selected decision for each of the 10 items in §5.
```

---

## 11. Final Rule

```text
This document narrows 604251's candidate list and records, for each of the ten
decisions a human must make before 604256 can exist, a Recommended Default reasoned
from 604251/604253's findings. It does not make those decisions final, does not
approve any file, and does not instruct Codex — the defaults are a starting position
for Human review, not a substitute for it. The next document in this slice's lifecycle
is Human Approval (604256) — authored by a human, not by Claude, and not part of this
pass. Only after 604256 closes does 604310's own blocked status (604315 §1, §11)
become eligible for reassessment — subject to 604315's remaining Required Human
Decisions.
```
