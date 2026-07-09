# 604408_TestPlan_Scope_D_01_Payment_Confirm_Idempotency.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: Scope D Slice 01 Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-01

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize writing any test file, SQL, or migration. It defines what must eventually be tested once 604316 Human Approval names allowed files.

**Policy update (2026-07-01):** implementation (and therefore test execution) is deferred until Schema Drift Alignment closes (§1a below), in addition to 604316 Human Approval. This TestPlan itself remains complete as a pre-implementation document.

---

## 0. Purpose

Enumerate the required tests for 604404 (`confirm_payment` duplicate/amount/correlation logic), scoped from `604407_Logic_...` and cross-checked against `900103` TC-102/TC-110 and `604303` §2/§8/§9.

---

## 1a. Schema Drift Precondition Tests (Policy Update, 2026-07-01 — Required Before Table Below)

| # | Test | Source | Expectation |
| --- | --- | --- | --- |
| 0.1 | `intent_id` binding check | `604301` §7.6, `604303` §5.1 | Confirm whether `payment_ledger.intent_id` (`NOT NULL`, `0014` L160) has a default, a backfill path, or requires reconciliation before any patch touches the `INSERT` |
| 0.2 | `provider_payment_key` vs `provider_tx_id` alignment check | `604301` §7.6, `604303` §5.1 | Confirm which name is authoritative; the patch must not introduce a second, inconsistent column |
| 0.3 | Undefined `fee_amount` reference guard | `604303` §5.1 | Confirm `fee_amount`/`net_amount` computation (`0098` L292–303) maps cleanly onto the reconciled schema |
| 0.4 | `confirm_payment` compile / dry-run verification | `604303` §5.1 | A dry-run or static check confirms `confirm_payment` executes against the current live schema before any patch design proceeds |

These four tests are a precondition gate, not part of the slice's own duplicate/amount test suite below. They must pass (or be explicitly closed) before Required Tests #1–13 and the effective-identity tests in §1b can be executed against a real patch.

---

## 1. Required Tests

| # | Test | Source | Expectation |
| --- | --- | --- | --- |
| 1 | Duplicate confirm, same `effective_idempotency_key` and same `request_fingerprint` | `900103` TC-102, `604407` §3-bis | Second call returns the **same terminal success payload** as the first — not `payment_already_confirmed` error |
| 2 | Duplicate confirm, `p_correlation_id` present, same identity | `604407` §3-bis, §5 | Second call returns the same terminal success payload; correlation_id alone does not create a second path distinct from `effective_idempotency_key` resolution |
| 3 | Duplicate confirm creates no duplicate `payment_ledger` row | `604407` §3-bis, §7 | Row count for the order remains 1 after N duplicate calls |
| 4 | Duplicate confirm does not trigger duplicate KDS release | `604407` §8 | `release_kds_after_payment` is not called a second time for a call recognized as duplicate; ticket `committed_at` unchanged |
| 5 | `p_correlation_id` null but strong identity resolvable | `604407` §5, §3-bis | Call is **not rejected solely** because `p_correlation_id` is null, provided `effective_idempotency_key` resolves from a stronger source (e.g. `payment_intent_id`) |
| 6 | Amount mismatch (`TC-110`) hard-blocks APPROVED (policy update) | `900103` TC-110, `604407` §4 | Any mismatch beyond the approved tolerance (default MVP = 0 KRW) blocks APPROVED insertion, the `payment_confirmed` event, and KDS release — "log only, continue" is a defect, not acceptable behavior |
| 7 | Amount mismatch produces audit/ledger evidence | `604407` §4, §7 | A diagnostic and/or audit trail (`cancel_required`/`reconciliation_required` where applicable) exists for the mismatch — mismatch must never be silent |
| 8 | Zero-tolerance default is enforced; provider-specific tolerance requires separate approval | `604407` §4 | Test asserts the approved tolerance is exactly what Human Approval recorded (default 0 KRW) — no implicit tolerance widening |
| 9 | `effective_idempotency_key` source mapping is implemented or explicitly deferred with rationale | `604407` §3-bis, §6 | Whichever priority tier(s) Human Approval selects, the test asserts that behavior — not an assumed tier |
| 10 | `correlation_id` preserved in `payment_ledger`, audit, and ledger events | `0098` L380, L393/L413 (existing, must not regress) | All three records for a given confirm carry the same `correlation_id` |
| 11 | Existing `0098`, `0014`, `0027` migrations are not modified in place | `604302` §10, `900102`, `604301` §7.6/§7.7/append-only rule | `git diff` shows zero changes to `0098_create_payment_confirm_pipeline_rpc.sql`, `0014_create_payment_ledger.sql`, `0027_create_payment_intent_rpc.sql`, `0103` |
| 12 | New patch migration number is unique | `604407` §9 | Re-run `ls sql/migrations/` immediately before implementation; number must not collide with anything present at that time (confirmed `0140`+ as of 2026-07-01, subject to recheck) |
| 13 | Release boundary with 604320/604330 is not crossed | `604407` §8, Overview §1 | Diff for this slice does not modify `release_kds_after_payment`'s body, and does not add a second call site to it |

---

## 1b. Effective Identity, Fingerprint, Replay, Conflict, And Reconciliation Tests (Policy Update, 2026-07-01)

| # | Test | Source | Expectation |
| --- | --- | --- | --- |
| 14 | `effective_idempotency_key` resolves deterministically per priority tier | `604407` §3-bis, `604302` §2.7 | For each of the seven priority tiers (payment_intent_id → provider payment key → provider request row → VAN TID+approval → adapter-derived → server-derived → unresolved), the same inputs always resolve to the same key |
| 15 | `request_fingerprint` excludes amount from `effective_idempotency_key` | `604407` §3-bis | The key does not change when amount changes; amount is compared only via `request_fingerprint` |
| 16 | Same key + same fingerprint → same-success replay | `604407` §3-bis, `604302` §2.4 | No duplicate `payment_ledger` row, no duplicate KDS release, no duplicate inventory/point/notification/printer/POS-sync/outbox side effect |
| 17 | Same key + different fingerprint → hard conflict | `604407` §3-bis | Returns a conflict/human-review state, not a silent replay and not a silent overwrite |
| 18 | Same key + different amount → hard reject | `604407` §3-bis, §4 | Rejected distinctly from the general fingerprint-conflict case — amount divergence under the same identity is never treated as a benign retry |
| 19 | Weak/unresolved identity → reconciliation, not blind proceed/reject | `604407` §3-bis, `604302` §2.10 | When `effective_idempotency_key` cannot be resolved with confidence, the call routes to `reconciliation_required` or `pending_confirm` |
| 20 | Idempotency conflict and hard-reject paths produce audit evidence | `604407` §7, `604302` §2.4 | Conflict/reject outcomes are not silent — some ledger/audit trace exists distinguishing them from a normal duplicate replay |

---

## 2. Manual Verification Commands (Reference Only — Not Authorized To Run As Implementation)

```bash
grep -n "payment_already_confirmed" sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
  # expected today: 2 occurrences (L221-227, L258-264) — baseline for comparison after patch

grep -n "payment_amount_mismatch" sql/migrations/0098_create_payment_confirm_pipeline_rpc.sql
  # expected today: log only, no early return — baseline for comparison after patch

ls sql/migrations/ | sort -t_ -k1 -n | tail -10
  # re-verify next free migration number immediately before implementation

git diff --check -- sql/migrations/
  # must show no changes to existing migration files after any future patch is applied
```

These commands are documented here as the **future verification baseline**, not executed as part of implementation in this pass.

---

## 3. Explicitly Not Covered By This TestPlan

```text
release_kds_after_payment's own idempotency tests           → 604320 test_plan
Confirm→release transaction/partial-failure tests            → 604330 test_plan
New ledger event type tests (PAYMENT_DUPLICATE_IGNORED, etc.) → 604340 test_plan
RLS/GRANT dry-run tests                                       → 604350 test_plan
Edge Function / Toss verify tests                             → 604360 test_plan
Full integration/unknown-state pass                           → 604370 test_plan
Scope D closeout checklist execution                          → 604380
```

---

## 4. Final Rule

```text
No test file is created by this document. The Schema Drift Precondition Tests (§1a), the
13 core requirements (§1), and the 7 effective-identity/fingerprint/replay/conflict/
reconciliation requirements (§1b) are the binding scope for whatever test file(s) 604316
Human Approval eventually names as allowed for Codex to add, and for the
verification_result.md that must follow implementation per 600179 Stage 5. §1a must close
before §1/§1b tests can be executed against a real patch.
```
