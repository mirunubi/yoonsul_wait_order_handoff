# 604284_TestPlan_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-05

This TestPlan defines tests to run **after** a fix strategy (Decision Matrix §9 of
`604283`) is selected and authorized by `604286` Human Approval. It does not authorize
running any fix now, and none of these tests may be executed against 0042 content
until that Approval exists. It may be used immediately, read-only, to describe the
*current* blocked state as evidence for 604279/604280 reporting.

---

## 0. Purpose

Define the exact test sequence required to (a) confirm a future 0042 fix restores full
valid sequential replay progress past it, and (b) re-verify how far that replay then
proceeds toward 0142, without expanding scope into 0142 content changes or 604250
resumption.

---

## 1. Test Environment

```text
Required: Supabase local + Docker, matching the environment already used for the
  604278 clean replay attempt.

- DB container: supabase_db_yoonsul_wait_order_handoff
- Verification database name must include one of: local / test / dev (required by
  0034_seed_data.sql's own guard)
- Use a fresh clean database for this test pass -- do NOT reuse
  catchmenu_local_verify_604278 (the database that recorded the 0042 failure), since
  reusing a DB that already halted mid-replay can mask ordering/state issues. Create a
  new disposable database, e.g. catchmenu_local_verify_604280 or
  catchmenu_local_verify_<date>.
- Copy the latest repo migrations into the container before replay (matching 604278
  §4's own setup step: docker cp sql/migrations/. -> container:/tmp/catchmenu_migrations),
  so the replay runs against the current post-604277 (0035/0038 fixed) file set plus
  whatever future 0042 correction is authorized.
- Each full replay attempt should run against a freshly created, disposable database
  (drop and recreate before each run) so partial-failure state from a prior attempt
  cannot mask or hide a new failure.
```

---

## 2. Pre-Test Safety Checks

```text
Before any test in this plan is executed against a real fix:
  1. Confirm 604286 Human Approval exists and explicitly authorizes the specific 0042
     change being tested (Option A, or an explicit variant, per 604283 §9).
  2. Confirm the test database is disposable (name matches local/test/dev pattern; is
     not any shared, cloud, or production-linked database, and is not the previously
     failed catchmenu_local_verify_604278).
  3. Confirm git status shows no unintended modification outside the files named in
     604286's Allowed Files list.
  4. Confirm no test in this plan writes to or drops any non-disposable database.
```

---

## 3. 0042 Static Verification

```text
TC-042-001: Re-read the corrected 0042 file and confirm the ONLY change from the
  pre-fix version is line 396: `result_payload :=` -> `result_payload =`. No other
  line, function signature, grant, or comment may differ (git diff --stat should show
  exactly 1 insertion / 1 deletion, mirroring the 0038 precedent).
TC-042-002: Re-scan all remaining `:=` occurrences in the corrected file and confirm
  they are still exactly the same valid variable-assignment and named-parameter uses
  identified in 604283 §3 -- i.e. confirm no new `:=` defect was introduced and no
  existing valid `:=` was accidentally altered.
```

---

## 4. 0042 Compile / Apply Test

```text
TC-042-010: Apply the corrected 0042 in isolation against a database already at
  post-0041 state (fresh disposable DB, per §1).
Expected: all three `create or replace function` statements
  (intake_delivery_order, sync_delivery_order_status, reject_delivery_order) compile
  and are created successfully; the EXECUTE grants at the end of the file apply
  without error.
```

---

## 5. Delivery Function Existence Test

```text
TC-042-020: Query information_schema.routines / pg_proc for the three functions
  created by 0042 and confirm their signatures match 604281 §4/§5:
  - catchmenu_integrations.intake_delivery_order(...)
  - catchmenu_integrations.sync_delivery_order_status(...)
  - catchmenu_integrations.reject_delivery_order(...)
TC-042-021: Directly exercise the previously-broken UPDATE branch: run
  intake_delivery_order (or an isolated statement matching its idempotency-completion
  UPDATE) with representative seed data and confirm the
  catchmenu_common.idempotency_keys row is updated with processing_status =
  'COMPLETED' and result_payload set to the expected JSON object -- this is the exact
  statement the original `:=` defect was in.
TC-042-022: Confirm 0043_create_did_display_rpc.sql (declared dependent on 0042 via
  its header) applies successfully immediately after the fixed 0042.
```

---

## 6. Clean Replay Continuation Test

```text
TC-042-030: Continue the full sequential replay from TC-042-010 past 0042 through the
  intervening migrations (0043-0141) and confirm no further baseline blocker halts the
  run before 0142. If a new blocker is found (e.g. the previously-flagged
  0073_final_verification.sql inline-procedure pattern, per 604278/604279/604281), the
  replay must stop, the new blocker must be recorded with the same rigor as 0035/0038/
  0042, and it must NOT be fixed under this TestPlan or this workpacket's Approval --
  it requires its own separate design/approval package, per the same precedent 604280
  itself follows relative to 604270.
```

---

## 7. 0142 Reachability Test

```text
TC-042-040: If TC-042-030 completes without a further blocker, confirm
  0142_patch_toss_mvp_payment_intent_binding.sql is reached and applies without error.
Expected: 0142's own CREATE OR REPLACE FUNCTION, trigger creation, and ALTER TABLE/
  CONSTRAINT statements execute successfully -- this is the exact evidence 604269
  Required Fix #2 and 604260's original Verification gap were waiting on.
```

---

## 8. 0142 Object Verification Test

```text
TC-042-050: After TC-042-040 succeeds, confirm the specific objects 0142 is expected to
  create/alter exist, matching 604267 Module's self-report and 604274 TC-BLK-040:
  - toss_payment_requests.payment_intent_id column, nullable, FK to payment_intents.
  - bind_toss_payment_intent() BEFORE INSERT trigger on toss_payment_requests.
  - initiate_toss_payment_legacy_604260 / confirm_toss_payment_legacy_604260 exist with
    original signatures; same-signature wrapper functions exist in their place.
TC-042-051: Runtime dry-run per 604269 §11's original evidence-gap list (intent
  creation, intent reuse, INTENT_BINDING_CONFLICT, INTENT_BINDING_REQUIRED/INVALID,
  direct-confirm and webhook-DONE convergence, RLS/permission behavior).
```

---

## 9. Boundary Checks

```text
TC-042-060: Confirm no file other than 0042 (and the future 604287 Module) shows a git
  diff after this fix is applied -- specifically 0142, 0035, 0038, 0014, 0027, 0052,
  0098, 0103, and every file under the 604250/604260/604270/604310 folders must show
  zero diff.
TC-042-061: Confirm 0057, 0074, 0078, and 0106 (downstream callers/redefiners of
  0042's functions) are unchanged and apply without modification once 0042 is fixed.
TC-042-062: Confirm no 604257 (604250 Module), 604316 (604310 Approval), or any
  604310 implementation artifact exists as a side effect of this test pass.
```

---

## 10. Failure Handling

```text
If any test in §4-§8 fails after a 604286-authorized fix is applied:
  1. Do not mark 604280 or 604260 closed.
  2. Record the new failure with the same rigor as the 604278/604281 records for 0042
     itself (exact file, line, error text, database state).
  3. Escalate back to Human for a decision on whether the authorized fix needs revision
     (new 604286 revision or a follow-up ChangeContract) before re-attempting replay.
  4. Do not attempt an ad hoc, undocumented correction to unblock the test run.
  5. If a NEW baseline blocker is found beyond 0042 (e.g. 0073), treat it exactly as
     604280 treats 0042 relative to 604270 -- a new, separately-scoped workpacket, not
     an in-place expansion of 604280's own Approval.
```

---

## 11. Evidence To Record

```text
For each test run (pass or fail):
  - Database name used (must show local/test/dev pattern, and must be a fresh DB, not
    a reused previously-failed one) and creation/drop timestamps.
  - Exact migration file and line reached at halt (if any).
  - Full error text, verbatim.
  - Git diff of any file touched, scoped to 604286's Allowed Files list only.
  - psql/Supabase CLI version and Docker container ID
    (supabase_db_yoonsul_wait_order_handoff) used for the run.
```

---

## 12. Final TestPlan

```text
This TestPlan is a design artifact only. No test in it may be executed against 0042
content changes until 604286 Human Approval exists and names the authorized fix
option. It may be used, read-only, today to describe and re-confirm the currently
blocked baseline state (TC-042-001, pre-fix expectation) without modifying anything.
```
