# 604264_TestPlan_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: Scope D 00A Toss MVP PaymentIntent Binding Precondition Test Plan Draft
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-02

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation may proceed while Owner remains TBD.

This document does not authorize writing any test file, SQL, or migration. It defines what must eventually be tested once 604266 Human Approval names allowed files.

---

## 0. Purpose

Enumerate the required tests for 604260 (Toss MVP `payment_intent` binding precondition), scoped from `604263_Logic_...` and cross-checked against `604261`'s findings and `604256`'s already-approved intent-binding policy.

---

## 1. Required Tests

| # | Test | Source | Expectation |
| --- | --- | --- | --- |
| 1 | `payment_intents` DDL inspection test | `604261` §4, `604263` §2 | Static assertion of the committed DDL baseline (columns, `idempotency_key` NOT NULL, `order_id` FK) — catches future silent drift |
| 2 | `toss_payment_requests` DDL inspection test | `604261` §5, `604263` §1 | Static assertion of the committed DDL baseline, including confirming the (patched) `payment_intent_id` column exists with the expected type/nullability once approved |
| 3 | `initiate_toss_payment` creates or binds `payment_intent` | `604263` §5 | Patched function calls `create_payment_intent` (or equivalent) and obtains a resolved `intent_id` before/alongside the `toss_payment_requests` insert |
| 4 | `toss_payment_requests` stores `payment_intent_id` or equivalent strong binding | `604263` §6 | The request row, once written, carries a non-null reference to the created/bound intent — not a value that must be re-derived later |
| 5 | `confirm_toss_payment` loads bound `intent_id` | `604263` §7 | The patched function reads `payment_intent_id` from the already-loaded request row without a new weak lookup |
| 6 | `confirm_toss_payment` can pass `intent_id` to the 604250 `confirm_payment` interface | `604263` §7–§8 | Whatever interface `604250`'s patch exposes (`p_intent_id` parameter or internal resolution), this slice's patch supplies a valid, resolved value — this test must be written against `604250`'s actual patched interface, not assumed in advance |
| 7 | Duplicate Toss initiate retry does not create duplicate active `payment_intents` | `604263` §5, §9; `0027` active-intent guard | A second `initiate_toss_payment` call for the same order while a non-terminal intent exists either reuses it (per whichever Required Human Decision #7 selects) or fails closed — never silently creates a second concurrent active intent |
| 8 | Toss `idempotency_key` and `payment_intents.idempotency_key` coordination | `604263` §9 | Whichever coordination option (shared / derived-namespaced / independent-with-FK) is approved, the test asserts that exact behavior — not an assumed one |
| 9 | `provider_order_id` / `order_id_toss` mapping validation | `604263` §11 | Confirms whether the `CM-...` / `CATCH-...` mismatch is accepted (FK link is the true tie) or explicitly reconciled — per the approved decision, not assumed |
| 10 | Null `session_id` handling | `604263` §10 | Whichever option (block / nullable intent session / fallback session) is approved, the test asserts that exact behavior for an order with no resolvable `session_id` at Toss-initiate time |
| 11 | `FAILED` intent / re-initiate handling | `604263` §9 | A retried payment attempt after a `FAILED` intent behaves per the approved decision (reuse vs. new attempt vs. manual reconciliation), not by default/accidental behavior |
| 12 | No weak `order_id`-only binding | `604256` §3, `604263` §3 | Static/code-review-style assertion that no code path resolves `intent_id` by `order_id` alone, "most recent pending," or `session_id` alone |
| 13 | No confirm-time synthetic intent creation | `604256` §3, `604263` §3 | Static/code-review-style assertion that `confirm_toss_payment` (and `confirm_payment`) never contains an `INSERT` into `payment_intents` — intent creation only happens upstream, at `initiate_toss_payment` (or its wrapper) |
| 14 | `process_toss_webhook` `DONE` path uses the same safe binding | `604261` §6.4, `604263` §1 | Since `process_toss_webhook` calls `confirm_toss_payment` directly, the webhook path inherits tests #5–#6 automatically — this test confirms there is no second, divergent code path for the webhook case |
| 15 | `0014`/`0098`/`0103`/`0027` historical in-place edit guard | `604263` boundary reminder | `git diff` shows zero changes to all four historical migration files after this slice's patch is implemented |
| 16 | Migration number uniqueness check | `604263` §12 | Re-run `ls sql/migrations/` immediately before implementation; the chosen patch number must not collide with anything present at that time, including whichever of this slice's or `604250`'s patch lands first |
| 17 | `604250` resume gate check | `604262` §2, §11 | After this slice's patch is verified, `604250`'s own resumption is confirmed to require its own separate re-authorization step — this test is a documentation/process check, not a runtime assertion: closing 604260 must not be silently treated as re-approving 604250 |

---

## 2. Manual Verification Commands (Reference Only — Not Authorized To Run As Implementation)

```bash
grep -n "create_payment_intent\|insert into.*payment_intents" sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
  # baseline today: zero matches — must change after the patch (test #3)

grep -n "confirm_payment(" sql/migrations/0103_create_toss_payments_pipeline_rpc.sql
  # baseline call-site for confirm_toss_payment's confirm_payment invocation, to diff
  # against after the patch (test #6)

grep -rn "create_payment_intent(" sql/migrations/
  # baseline: only 0052 (Kiosk) calls it today — must include 0103's patched function
  # after this slice's patch (test #3)

ls sql/migrations/ | sort -t_ -k1 -n | tail -10
  # re-verify next free migration number immediately before implementation

git diff --check -- sql/migrations/
  # must show no changes to existing migration files after any future patch is applied
```

These commands are documented here as the **future verification baseline**, not executed as part of implementation in this pass.

---

## 3. Explicitly Not Covered By This TestPlan

```text
payment_ledger column drift tests (provider_payment_key, fee_amount, provider_response)
  -> 604250 (604254), unaffected by this slice
Idempotency same-success / TC-102 payload tests           -> 604310 (604314)
Amount mismatch hard block / TC-110 enforcement tests      -> 604310 (604314)
effective_idempotency_key / request_fingerprint tests      -> 604310 (604314 §1b)
release_kds_after_payment's own idempotency tests          -> 604320
RLS/GRANT dry-run tests                                    -> 604350
Edge Function / Toss verify tests                          -> 604360
0038 legacy webhook / confirm_payment_from_provider tests  -> future split-brain
                                                              consolidation, not this slice
```

---

## 4. Final Rule

```text
No test file is created by this document. These 17 requirements are the binding scope
for whatever test file(s) 604266 Human Approval eventually names as allowed for Codex
to add, and for the verification_result.md that must follow implementation per 600179
Stage 5. 604250's own resumed test suite (604254) remains separately gated — closing
this slice's tests does not substitute for 604250's own remaining verification.
```
