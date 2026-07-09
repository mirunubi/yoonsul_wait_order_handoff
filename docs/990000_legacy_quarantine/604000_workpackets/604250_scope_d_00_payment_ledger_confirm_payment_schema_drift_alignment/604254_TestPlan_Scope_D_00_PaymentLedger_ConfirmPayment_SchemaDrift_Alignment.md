# 604254_TestPlan_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: Scope D 00 Schema Drift Alignment Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize writing any test file, SQL, or migration. It defines what must eventually be tested once 604256 Human Approval names allowed files.

---

## 0. Purpose

Enumerate the required tests for 604250 (`payment_ledger`/`confirm_payment` schema drift alignment), scoped from `604253_Logic_...` and cross-checked against the drift findings in `604251` §4–§11.

---

## 1. Required Tests

| # | Test | Source | Expectation |
| --- | --- | --- | --- |
| 1 | `payment_ledger` DDL inspection test | `604251` §4, `604253` §1 | Static assertion of the committed DDL's column list, types, and constraints against a recorded baseline — catches future silent DDL drift, not just today's |
| 2 | `confirm_payment` `INSERT` column compatibility test | `604251` §5, `604253` §2–§3 | Every column named in the (patched) `INSERT` statement exists on `payment_ledger` with a compatible type |
| 3 | `intent_id` `NOT NULL` satisfaction test | `604251` §4.1, §7; `604253` §6 | The patched `confirm_payment` (or its resolved binding mechanism) always supplies a non-null `intent_id` — no code path leaves it null |
| 4 | `ledger_entry_type` `NOT NULL` satisfaction test | `604251` §4.1, §6.1; `604253` §3 | Every `confirm_payment`-driven insert sets `ledger_entry_type = 'APPROVAL'` (or another value satisfying the DDL `CHECK` constraint) |
| 5 | `provider_payment_key`/`provider_tx_id` compatibility test | `604251` §8; `604253` §7 | Whichever naming resolution is approved, the patched code writes to and reads from a column that actually exists — no reference to a name absent from the live DDL |
| 6 | `fee_amount` undefined-column guard | `604251` §9; `604253` §8 | If `fee_amount` handling is approved as "do not add," assert the patched `INSERT` no longer references it; if added, assert the column exists and the `net_amount` constraint still holds |
| 7 | `payment_method` undefined-column guard | `604251` §5.2, §6.1 | Same style of guard as #6, for `payment_method` on `payment_ledger` specifically (it legitimately exists on `payment_intents`, which is not the issue) |
| 8 | `provider_response`/`provider_response_id` compatibility test | `604251` §5.2, §6.1; `604253` §9 | Whichever option is approved (FK-only, jsonb-only, or both), the patched `INSERT` matches the live column set exactly |
| 9 | `confirm_payment` compile test after patch | `604251` §11.1; `604253` §3 | `CREATE OR REPLACE FUNCTION` for the patched `confirm_payment` succeeds without error against the reconciled schema |
| 10 | Sequential migration apply test, `0014` through the new patch | `604251` §11.1 | A fresh sequential apply (`0014` → … → new patch) succeeds end-to-end; this is the test that would have caught today's drift before it reached committed history |
| 11 | Successful resolvable-intent dry-run | `604253` §6 | Given a call site that legitimately has a resolvable `payment_intents` row (e.g. the `0027`-style flow), the patched binding mechanism correctly resolves `intent_id` |
| 12 | No-intent path blocks APPROVED ledger insert | `604251` §7.3–§7.4; `604253` §6 | On the MVP Toss path (`0103` → `confirm_payment`) where no `payment_intents` row exists yet and no upstream creation/linking has occurred, the patched code must NOT insert an APPROVED `payment_ledger` row that violates `intent_id NOT NULL` — it must fail closed (explicit error / reconciliation state), never silently succeed with a null-violating write |
| 13 | Multiple-intent path blocks APPROVED ledger insert | `604251` §7.2-B, §7.4; `604253` §6 | Given more than one `payment_intents` row could match a naive `order_id`-only lookup, the patched binding mechanism must not silently pick one — it must either use a more specific identity (per the approved binding mechanism) or fail closed to a reconciliation state |
| 14 | KDS release does not occur if APPROVED ledger insert is blocked | `604251` §11.2; `604302` §3 (guard is 604320's, but the boundary applies here) | If test #12 or #13 causes the ledger insert to be blocked, `release_kds_after_payment` must not be invoked — the existing single-call-site behavior (`0098` L348–356) must remain contingent on a successful APPROVED insert |
| 15 | `0027` unchanged regression guard | `604253` §10 | `git diff` shows zero changes to `sql/migrations/0027_create_payment_intent_rpc.sql` after this slice's patch is implemented |
| 16 | Historical migration in-place edit guard | `604253` §11, `604301` §9 append-only rule | `git diff` shows zero changes to `0014_create_payment_ledger.sql`, `0098_create_payment_confirm_pipeline_rpc.sql`, and every other existing migration file; only a new patch file is added |
| 17 | Migration number uniqueness check | `604251` §14; `604253` §11 | Re-run `ls sql/migrations/` immediately before implementation; the chosen patch number (`0140` or higher as of 2026-07-01) must not collide with anything present at that time |

---

### 1.1 604260 Consumer-Side Handoff Check

```text
604250 verification must include a consumer-side handoff check after 604260 closes.

The check must prove that a Toss-confirmed payment can supply a strong payment_intent_id / p_intent_id to confirm_payment without order_id-only lookup or synthetic confirm-time intent creation.

This consumer-side check complements 604264 TestPlan items #6 and #17.
```

## 2. Manual Verification Commands (Reference Only — Not Authorized To Run As Implementation)

```bash
grep -n "intent_id\|ledger_entry_type\|provider_payment_key\|provider_response_id" sql/migrations/0014_create_payment_ledger.sql
  # baseline DDL column list for test #1

grep -n "provider_tx_id\|fee_amount\|payment_method\|provider_response" sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
  # baseline drift-column usage for test #2, to diff against after any future patch

ls sql/migrations/ | sort -t_ -k1 -n | tail -10
  # re-verify next free migration number immediately before implementation

git diff --check -- sql/migrations/
  # must show no changes to existing migration files after any future patch is applied
```

These commands are documented here as the **future verification baseline**, not executed as part of implementation in this pass.

---

## 3. Explicitly Not Covered By This TestPlan

```text
Idempotency same-success / TC-102 payload tests           → 604310 (604314)
Amount mismatch hard block / TC-110 enforcement tests      → 604310 (604314), except where
                                                              this slice's schema constraints
                                                              incidentally prevent an
                                                              impossible write (see §1 items
                                                              12-14 above)
effective_idempotency_key / request_fingerprint tests      → 604310 (604314 §1b)
release_kds_after_payment's own idempotency tests          → 604320
RLS/GRANT dry-run tests                                    → 604350
Edge Function / Toss verify tests                          → 604360
0109/0130/refund-path downstream alignment tests            → deferred, per 604255 §5 item 7
                                                              (include-or-defer, not decided here)
```

---

## 4. Final Rule

```text
No test file is created by this document. These 17 requirements are the binding scope for
whatever test file(s) 604256 Human Approval eventually names as allowed for Codex to add,
and for the verification_result.md that must follow implementation per 600179 Stage 5.
604310's own test suite (604314) remains blocked from execution until items #1-#17 here
are satisfied or explicitly closed.
```
