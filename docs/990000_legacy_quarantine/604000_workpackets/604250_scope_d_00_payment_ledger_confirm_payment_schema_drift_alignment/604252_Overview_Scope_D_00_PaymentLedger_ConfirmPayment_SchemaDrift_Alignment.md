# 604252_Overview_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

Status: Draft
Lifecycle: Overview
Gate Classification: Scope D 00 Schema Drift Alignment Overview Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize implementation.
Codex must not implement from this Overview.

**604250 must close before 604310 implementation approval.** `604310` (Payment Confirm Idempotency) remains blocked regardless of its own document completeness until this slice's schema drift alignment is verified and closed (`604310_Index` L8–11, `604315` §1/§11).

---

## 0. Purpose

This is the slice-specific Overview for **604250 — PaymentLedger / ConfirmPayment Schema Drift Alignment** (Scope D sub-workpacket 00). It verifies the claims in `604251_ImpactScope_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md` against the actual repository state and frames why this slice exists as a precondition slice, not a feature slice: `0014`'s `payment_ledger` DDL and `0098`'s `confirm_payment` `INSERT`/`WHERE` clauses do not share the same column contract, and `604310` cannot safely build idempotency logic on top of an unreconciled — possibly non-functional — write path.

This Overview is Stage 2 output (Claude), built on Stage 1 (Cursor) discovery in `604251`. It does not replace `604251`; it confirms which of its findings are load-bearing for design.

---

## 1. Slice Boundary

```text
In scope:
  payment_ledger physical schema (0014) vs confirm_payment INSERT/WHERE contract (0098)
  intent_id binding strategy for the confirm_payment call path
  provider_payment_key vs provider_tx_id naming reconciliation
  fee_amount / payment_method / provider_response column-existence gaps
  Migration numbering for any future append-only alignment patch

Out of scope (owned by other slices, or excluded entirely):
  Idempotency same-success / TC-102 return-payload behavior       → 604310 (blocked on this slice)
  Amount mismatch hard block / TC-110 enforcement mechanics        → 604310
  release_kds_after_payment guard                                  → 604320
  RLS REVOKE on release                                             → 604350
  Edge Function Toss verify                                         → 604360
  0027 confirm_payment_from_provider — modification of any kind     → explicitly excluded, reference only
  0014 / 0098 in-place edit                                         → forbidden under any circumstance
```

604250 may only investigate and propose alignment strategy candidates for the physical schema contract. It does not decide idempotency logic, amount-mismatch enforcement, or any 604310-owned behavior — those remain 604310's problem once this slice's precondition closes.

---

## 2. Relation To 604310

```text
604310_Index (L8-11)   — states implementation is blocked until schema drift alignment
                          closes; this slice IS that alignment work.
604311 §9 item 4        — first recorded the drift as a "Known Gap"; 604300/604304 policy
                          update later escalated it from "Required Human Decision" to a
                          "required precondition."
604312 §3, §6           — Overview-level business risk and required-gates framing that
                          named Schema Drift Alignment as step 5, before Human Approval.
604313 §9               — Logic-level statement that no patch migration may be written
                          until this drift is resolved or explicitly understood.
604315 §1, §5 item 5, §11 — ChangeContract-level statement that 604316 cannot be
                          finalized while this drift is open, independent of the other
                          seven Required Human Decisions.
604300_Index / 604301 §7.6 — master-pack-level policy statement establishing the
                          "604305-style Schema Drift Alignment" precondition by name
                          (no 604305 document exists; this 604250 slice fulfills that role
                          under its own actual number).
```

**Numbering note:** the policy language in `604300_Index`/`604301`/`604310`-family documents refers to this precondition informally as "604305-style." The actual folder and document numbers assigned to this work are `604250`–`604255` (this slice sits earlier in sequence than `604310` because it is a precondition, not sub-workpacket 05). This Overview uses the slice's real numbers throughout and treats "604305-style" as a description of the precondition's *role*, not a claim that a `604305` file exists.

---

## 3. Current Repo Evidence

Verified directly against `sql/migrations/` on 2026-07-01 (not taken from `604251` on trust alone):

| 604251 claim | Verification | Result |
| --- | --- | --- |
| `payment_ledger` DDL `0014` L154–239: `intent_id` `NOT NULL` (L160), `ledger_entry_type` `NOT NULL` (L163), `provider_payment_key` exists (L174, nullable), `provider_response_id uuid` FK exists (L177) | Read `0014` L150–249 directly | **Confirmed**, exact lines match |
| `0014` absent columns: `provider_tx_id`, `fee_amount`, `payment_method` (on ledger), `provider_response` jsonb | Read full column list directly | **Confirmed absent** |
| `0098` `confirm_payment`: no `p_intent_id` param, `INSERT` uses `provider_tx_id`/`fee_amount`, omits `intent_id`/`ledger_entry_type` | Re-verified against prior full read of `0098` L145–457 (this session) | **Confirmed**, consistent with `604311`/`604313` prior verification |
| `0027` `confirm_payment_from_provider`: receives `p_intent_id` (L205), uses `p_provider_payment_key` → `provider_payment_key` column (L206, L267, L281), `ledger_entry_type = 'APPROVAL'` (L279), amount mismatch returns error without inserting (L244–251), never calls `release_kds_after_payment` | Read `0027` L195–294 directly; grepped full file for `release_kds_after_payment` | **Confirmed** — zero matches for `release_kds_after_payment` in `0027` |
| `0109`/`0130` downstream RPCs insert `payment_method`, `provider_tx_id`, `fee_amount` with the same drift pattern as `0098` | Grepped both files directly | **Confirmed** — `0109` L920–922, `0130` L400–401 |
| Migration numbers `0136`–`0139` taken; `0138` exists as a single file; `0140`+ is the next candidate | `ls sql/migrations/` re-run this session | **Confirmed as of 2026-07-01** |

All six `604251` claim groups listed in the task are verified accurate against the current repo state. No factual error was found in `604251`.

---

## 4. Business Risk

```text
Compile/creation risk:
  0098's confirm_payment INSERT statement references provider_tx_id and fee_amount,
  neither of which exists as a column on payment_ledger per the committed 0014 DDL.
  If these migrations were applied in committed sequence against a schema with no
  out-of-band ALTER TABLE, CREATE OR REPLACE FUNCTION for confirm_payment would very
  likely fail at creation time, or the INSERT would fail at first execution — this repo
  has no automated test asserting confirm_payment successfully creates or executes
  (604251 §11.3, §15).

Building on an unverified foundation:
  604310's entire purpose is to make confirm_payment's duplicate/amount logic safe.
  Designing that logic against an INSERT statement that may not even execute today
  means any 604310 patch risks papering over — or silently depending on — an
  unreconciled schema, rather than fixing a working write path.

Systemic scope:
  The drift is not isolated to 0098. 0109 and 0130 show the same non-DDL column usage,
  meaning any DDL-side fix has a wider blast radius than confirm_payment alone
  (604251 §6.3) — this must inform, but not expand, this slice's own edit boundary.

intent_id binding risk:
  payment_ledger.intent_id is NOT NULL with no default. The MVP Toss confirm path
  (0103 -> confirm_payment) does not create or link payment_intents at all. Without a
  binding strategy, the "aligned" INSERT still cannot satisfy this constraint on the
  primary MVP path — alignment is not just a column-naming exercise.
```

---

## 5. Schema Drift Summary

Restates the load-bearing rows of `604251` §6.1 (Drift matrix), verified accurate in §3 above:

| Field / rule | `0014` DDL | `0098` INSERT | Severity |
| --- | --- | --- | --- |
| `intent_id` | NOT NULL required | Omitted | CRITICAL |
| `ledger_entry_type` | NOT NULL required | Omitted | CRITICAL |
| Provider key column | `provider_payment_key` | `provider_tx_id` (not a DDL column) | CRITICAL (name + existence) |
| `fee_amount` | Absent | Inserted | CRITICAL |
| `payment_method` | Absent on ledger | Inserted | CRITICAL |
| Provider payload | `provider_response_id` (uuid FK) | `provider_response` (jsonb) | CRITICAL (type + name) |

---

## 6. Intent Binding Problem

```text
0098 confirm_payment has no p_intent_id parameter and never queries payment_intents.
0103 confirm_toss_payment (the MVP Toss path) calls confirm_payment without creating
  or linking any payment_intents row.
payment_ledger.intent_id is NOT NULL with no default found anywhere in sql/migrations/.

Consequence: even a column-name-aligned INSERT cannot satisfy intent_id NOT NULL on the
  MVP Toss path today, unless one of:
    (a) an upstream step creates/links payment_intents before confirm_payment runs, or
    (b) the DDL is changed (nullable intent_id, synthetic intent row, backfill policy), or
    (c) an explicit, documented binding rule resolves an intent_id from order_id/provider
        key/idempotency_key — noting 604251 §7.2-B/§7.4 found order_id lookup alone is
        NOT guaranteed unique (multiple retried intents per order are possible per the
        0014 comment on payment_intents, L135).
```

This is a design decision, not resolved by this Overview — see `604253` §4–§6 and `604255` §5.

---

## 7. Provider Key Naming Problem

```text
One logical field, two names, in the same codebase:
  0014 DDL authoritative column: provider_payment_key (nullable text, indexed).
  0098 confirm_payment: parameter p_provider_tx_id, INSERT/WHERE column provider_tx_id
    (does not exist in 0014).
  0027 confirm_payment_from_provider: parameter p_provider_payment_key, correctly
    targets the DDL column provider_payment_key.
Both column names do NOT coexist in 0014 — only provider_payment_key exists.
```

`0027`'s usage is the DDL-correct pattern; `0098`'s is the drifted one. This does not by itself decide which name becomes authoritative going forward (renaming the RPC vs. adding a column vs. a compatibility view are all still open — `604253` §7).

---

## 8. Fee / Provider Response Column Problem

```text
fee_amount: 0098 computes and inserts fee_amount; 0014 has no such column. Downstream
  reads (604251 §9: 0111, 0100, 0120, 0084) already assume pl.fee_amount exists, meaning
  this is not an isolated confirm_payment problem — a decision to drop, add, or relocate
  fee_amount affects multiple RPCs beyond this slice's own edit target.

provider_response: 0098 inserts a jsonb payload into a column named provider_response;
  0014 defines provider_response_id (uuid FK to catchmenu_gateway.provider_raw_events),
  not a jsonb column. These are structurally different approaches (inline snapshot vs.
  foreign-key reference to a separate event table), not just a naming difference.
```

Neither problem is resolved here — see `604253` §8–§9 and `604255` §5 items 5–6.

---

## 9. 0027 Comparison And Exclusion

`0027`'s `confirm_payment_from_provider` is the DDL-aligned reference pattern (`604251` §10, verified in §3 above): it takes `p_intent_id` directly, writes `ledger_entry_type = 'APPROVAL'`, uses `provider_payment_key`, hard-blocks on amount mismatch, and never calls `release_kds_after_payment`. It is useful **only as a read-only template** for what a DDL-conformant `INSERT` looks like.

```text
0027 is explicitly excluded from any edit in this slice.
Reasons (604251 §10.1):
  1. 604310_Index already records confirm_payment_from_provider as a future
     split-brain consolidation concern, excluded from 604310.
  2. 604315 scopes 604310's future patch to 0098's confirm path, not 0027.
  3. 0027 is useful as a reference pattern, not an edit target.
  4. Modifying 0027 would expand blast radius (VAN/webhook 0038, intent pipeline)
     without closing the primary MVP drift in 0098.
```

This slice may reference `0027`'s column shape when proposing alignment strategy options (`604253` §4) but must not modify it.

---

## 10. Candidate Future Change Boundary

Reference only — restates `604251` §12, not an authorization:

```text
P0 candidate: a NEW patch migration (next free number, 0140+, re-verified at Human
              Approval) — exact content (DDL extension, RPC rewrite, or hybrid) is
              undecided; see 604253 §4-§5.
P1 candidate: 0103, 0109, 0130 downstream alignment, only if a single-column-contract
              strategy is chosen — not committed to in this slice.
Existing 0014, 0098, 0027: read/reference only. No in-place edits, ever.
```

---

## 11. Required Gates Before Implementation

Reference-direction update:

```text
604256 Human Approval exists, but 604250 implementation stopped correctly because Toss MVP does not yet provide a strong payment_intent binding.

604260 Scope D 00A Toss MVP PaymentIntent Binding Precondition is now a required upstream precondition before 604250 implementation can resume.

604250 must not resume automatically when 604260 closes. Explicit Human reauthorization is required before 604250 implementation may continue.
```

```text
1. This Overview (604252) — done, Stage 2.
2. Logic (604253) — this pass.
3. TestPlan (604254) — this pass.
4. ChangeContract (604255) — this pass, candidate boundaries only.
5. Human Approval (604256) — NOT part of this pass. Requires Owner assigned, strategy
   choice (Option A/B/C) made, and every Required Human Decision in 604255 §5 resolved.
6. Codex implementation — only after 5, within the file list 604256 explicitly names.
7. Verification (verification_result.md) — per 600179 Stage 5.
8. Claude audit (audit_review.md) — per 600179 Stage 6. Mandatory; a module file alone
   is never sufficient closeout.

Only after 604250's own Human Approval (604256) closes does 604310's Human Approval
(604316) become eligible to proceed — subject to 604315's own remaining Required
Human Decisions.
```

---

## 12. Final Rule

```text
This Overview exists to confirm that 604251's factual claims about payment_ledger and
confirm_payment's schema contract hold, and to frame why this slice must close before
604310 can safely proceed. It does not decide the alignment strategy, does not create a
migration, and does not instruct Codex. Design proceeds to 604253 Logic under the same
restriction.
```
