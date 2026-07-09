# 604406_Overview_Scope_D_01_Payment_Confirm_Idempotency.md

Status: Draft
Lifecycle: Overview
Gate Classification: Scope D Slice 01 Overview Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize implementation.
Codex must not implement from this Overview.

**Implementation deferred (policy update, 2026-07-01):** `604404` implementation approval (`604316` Human Approval) is deferred until Schema Drift Alignment (§3, §6 below) is verified/closed, in addition to the Required Human Decisions already tracked in `604409` §5. This Overview, and `604407`–`604409`, remain complete as pre-implementation documents; none of them is blocked from existing — only Codex implementation is blocked.

---

## 0. Purpose

This is the slice-specific Overview for **604404 — Payment Confirm Idempotency** (Scope D sub-workpacket 01). It verifies the claims in `604405_ImpactScope_Scope_D_01_Payment_Confirm_Idempotency.md` against the actual repository state and frames the business purpose of the slice: making `catchmenu_payment.confirm_payment` safe against duplicate calls and unverified amounts before any patch is designed in detail (`604407_Logic_...`).

This Overview is Stage 2 output (Claude), built on Stage 1 (Cursor) discovery. It does not replace `604405`; it confirms which of its findings are load-bearing for design.

---

## 1. Slice Boundary

```text
In scope:
  catchmenu_payment.confirm_payment — duplicate-confirm behavior, amount verification
  Inputs to that function: p_correlation_id, p_provider_tx_id, p_approved_amount
  The idempotency_key fields that exist elsewhere (payment_intents, toss_payment_requests)
    only insofar as confirm_payment's own key strategy is decided

Out of scope (owned by other slices):
  release_kds_after_payment function body                → 604320
  confirm_payment → release transaction boundary itself   → 604330
  New ledger event type names (PAYMENT_DUPLICATE_IGNORED) → 604340
  REVOKE authenticated on release_kds_after_payment       → 604350
  Edge Function source (supabase/functions/**)            → 604360
  Integration/unknown-state re-verification               → 604370
  Scope D closeout                                        → 604380
```

604404 may only change **how `confirm_payment` decides whether to proceed**, not what happens once it decides to proceed (that handoff to `release_kds_after_payment` belongs to 604320/604330).

---

## 2. Relation To Scope D Master Pack

```text
604301 (Overview)        — Scope D exists so server owns payment/KDS truth.
604302 (Logic) §2        — confirm_payment idempotency design intent (source of the target
                            "same-result return" behavior this slice must design toward).
604303 (TestPlan) §2, §8 — assigns TC-102, TC-110, and confirm-side idempotency tests to 604404.
604304 (ChangeContract)  — 604404 is name-and-boundary only at the master level; this document
                            and 604407–604409 are what turn that boundary into a reviewable design.
600179                   — Stage 2 (this document) verifies the Stage 1 (604405) draft and,
                            per the updated pipeline, does not re-derive overview/logic from
                            scratch — it confirms 604405's findings and adds the business framing.
```

---

## 3. Current Repo Evidence

Verified directly against `sql/migrations/` on 2026-07-01 (not taken from `604405` on trust alone):

| 604405 claim | Verification | Result |
| --- | --- | --- |
| `confirm_payment` at `0098` L145–460 | Read L140–470 directly | **Confirmed** — signature L145–159, body through L457–458 |
| Duplicate → `payment_already_confirmed` error, L190–228 / L252–264 | Read directly | **Confirmed** — `build_error_response('payment_already_confirmed')` at both sites; no same-result payload |
| Amount check L267–290, no block, flow continues to L305+ | Read directly | **Confirmed** — `log_diagnostic('payment_amount_mismatch')` only; ledger insert proceeds unconditionally at L306 |
| Ledger/audit/event inserts L306–331 / L359–383 / L386–415 | Read directly | **Confirmed**, exact line ranges match |
| `idempotency_key` not used by `confirm_payment`; exists on `payment_intents` (`0014` L40) and `toss_payment_requests` (`0103` L107, generated L419–427) | Grepped both files directly | **Confirmed** |
| `correlation_id` param L158; duplicate guard only runs `if p_correlation_id is not null` (L191) | Read directly | **Confirmed** |
| Migration numbers `0136`–`0139` taken; next candidate `0140`+ | `ls sql/migrations/` re-run this session | **Confirmed as of 2026-07-01** — `0138_patch_integration_functions_4.sql`, which appeared in an earlier check this same session, has since been removed by the project owner directly; only `0138_patch_integration_functions.sql` remains. `604405`'s "not present" claim is accurate for current state. |
| Schema drift: `0014` `payment_ledger.intent_id` is `NOT NULL` (L160) and column is `provider_payment_key` (L174), but `0098`'s `INSERT` (L306–317) omits `intent_id` entirely and uses `provider_tx_id` | Grepped `0014` DDL directly; no reconciling `ALTER TABLE` found anywhere in `sql/migrations/` (only RLS-enabling `ALTER TABLE` statements in `0021`) | **Confirmed, unresolved** — this is a real, currently-unreconciled drift, not something already patched elsewhere |
| `confirm_payment_from_provider` (`0027`) blocks on `amount_mismatch` and sets `kds_release_authorized = false` | Grepped `0027` directly | **Confirmed** — contrasts directly with `confirm_payment`'s continue-on-mismatch behavior |

All eight `604405` claims listed in the task are verified accurate against the current repo state.

---

## 4. Business Risk

```text
Duplicate payment approval risk:
  A retried or raced confirm_payment call currently returns an ERROR, not a safe repeat of the
  original success. A caller (Edge Function, Toss webhook, staff retry) that does not already
  handle this error path may surface a false failure to a customer who was, in fact, charged
  and served — or may prompt an unsafe manual retry.

Amount mismatch risk:
  confirm_payment logs a mismatch but still inserts APPROVED and releases KDS. This means the
  server can record and act on a payment amount that does not match the order's expected total,
  with only a diagnostic log as a trace. This is the single highest-severity finding in this
  slice: it is a silent, unresolved gap between logged intent (INV-001-adjacent expectation)
  and enforced behavior.

Schema drift risk:
  If intent_id truly has no default and the current INSERT statement is what actually runs in
  production, either (a) a NOT NULL violation would occur on every confirm_payment call, which
  contradicts the assumption that this pipeline is live, or (b) some reconciliation exists that
  this ImpactScope/Overview pass did not find. This must be resolved as a Required Human Decision
  before any patch migration is designed in detail (604407 §1, 604409 §5).
```

---

## 5. Confirm Payment Idempotency Problem

```text
Current: duplicate confirm (same provider_tx_id+APPROVED, or same order_id already APPROVED)
         returns payment_already_confirmed as an ERROR response.
Target (604302 §2.3, 900103 TC-102): duplicate confirm should return the SAME terminal success
         payload as the original approval — not an error — so that a caller cannot distinguish
         "first success" from "safe repeat" and does not need special-case retry logic.
Gap: no code path in 0098 currently returns a success payload for the duplicate case.
```

---

## 6. Amount Mismatch Problem

```text
Current: |p_approved_amount - orders.final_amount| > 10 KRW triggers a diagnostic log
         (payment_amount_mismatch) but does not stop APPROVED insertion or KDS release.
Target (900103 TC-110): amount mismatch must not silently proceed to KDS release.
Gap: the enforcement policy (hard block vs. reconciliation-required state vs. adjustable
     tolerance) is not decided — this is Required Human Decision #2 (604409 §5).
```

---

## 7. Correlation / Idempotency Key Problem

```text
correlation_id: propagated to release/audit/ledger correctly when present, but the
  provider_tx_id-based duplicate guard (L191-228) is skipped entirely when
  p_correlation_id is null. Any caller that omits correlation_id bypasses that guard
  (the order_id-based check at L252-264 still applies, but the provider_tx_id-based one does not).

idempotency_key: two different keys already exist in the schema (payment_intents.idempotency_key,
  toss_payment_requests.idempotency_key), but confirm_payment does not consume either.
```

**Policy update (2026-07-01) — supersedes the earlier "reject on null correlation_id" framing:**

```text
p_correlation_id is a trace value, not the final idempotency key.
p_correlation_id null must not, by itself, be grounds for rejecting confirm_payment.
The design target is an effective_idempotency_key resolved from stronger identity
  evidence (604302 §2.7 priority list: internal payment_intent_id, provider payment
  key, provider request row, VAN TID + approval number, adapter-derived key,
  server-derived transitional key), with amount excluded from the key itself and
  instead compared via a separate request_fingerprint (604302 §2.7).
If identity cannot be resolved with confidence, route to reconciliation_required or
  pending_confirm — not a blind proceed and not a blind reject.
```

Idempotency for `604404` therefore depends on two resolved values, not one: `effective_idempotency_key` (identity) and `request_fingerprint` (content, including amount). Required Human Decision #4 (`604409` §5) is reframed from "use idempotency_key directly or defer" to "which key-source priority tier(s) does `confirm_payment` accept, and how is `request_fingerprint` computed" — the decision is not eliminated, only sharpened.

---

## 8. Candidate Future Change Boundary

Reference only — restates `604405` §10, not an authorization:

```text
P0 candidate: a NEW patch migration (next free number, 0140+, re-verified at Human Approval)
              targeting confirm_payment's duplicate/amount logic only.
Existing 0098, 0014, 0103, 0027: read/reference only. No in-place edits.
```

---

## 9. Explicit Non-Goals

```text
604404 does not:
  - Rewrite or patch release_kds_after_payment (604320's function).
  - Solve the confirm-to-release transaction/split-brain boundary (604330's problem).
  - Introduce new ledger event type names such as PAYMENT_DUPLICATE_IGNORED (604340's problem).
  - Touch GRANT/REVOKE on any function (604350's problem).
  - Create or modify any Edge Function source (604360's problem, and the directory does not exist).
  - Modify Flutter/Dart code, Python tooling, or config/seed files.
  - Decide whether confirm_payment_from_provider (0027) is deprecated, aligned, or kept parallel
    — that is Required Human Decision #6, not a design decision this slice can make unilaterally.
```

---

## 10. Required Gates Before Implementation

```text
1. This Overview (604406) — done, Stage 2.
2. Logic (604407) — this pass.
3. TestPlan (604408) — this pass.
4. ChangeContract (604409) — this pass, candidate boundaries only.
5. Schema Drift Alignment (policy update 2026-07-01) — NOT part of this pass. A required
   precondition: payment_ledger/confirm_payment physical schema contract alignment,
   intent_id binding, provider_payment_key vs provider_tx_id naming, undefined
   fee_amount reference risk, confirm_payment compile/dry-run verification. No 604305
   document exists yet; this is a policy requirement, not a created file.
6. Human Approval (604316) — NOT part of this pass. Requires Owner assigned, Schema
   Drift Alignment (step 5) closed, and every Required Human Decision in 604409 §5 resolved.
7. Codex implementation — only after 6, within the file list 604316 explicitly names.
8. Verification (verification_result.md) — per 600179 Stage 5.
9. Claude audit (audit_review.md) — per 600179 Stage 6. Mandatory; a module file alone
   is never sufficient closeout.
```

---

## 11. Final Rule

```text
This Overview exists to confirm that 604405's factual claims hold, and to frame the business
risk of confirm_payment's current duplicate/amount behavior in terms a human approver can act
on. It does not decide the patch's exact SQL, does not create a migration, and does not
instruct Codex. Design proceeds to 604407 Logic under the same restriction.
```
