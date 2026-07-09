# 604274_TestPlan_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Draft
Lifecycle: TestPlan
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Design
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-04

This TestPlan defines tests to run **after** a fix strategy (Decision Matrix §9 of
`604273`) is selected and authorized by `604276` Human Approval. It does not authorize
running any fix now, and none of these tests may be executed against 0035/0038 content
until that Approval exists. It may be used immediately, read-only, to describe the
*current* blocked state as evidence for 604269/604270 reporting.

---

## 0. Purpose

Define the exact test sequence required to (a) confirm a future 0035/0038 fix actually
restores full valid sequential replay through 0142, and (b) re-verify 604260's own
runtime evidence gap is closed as a result, without expanding scope into 0142 content
changes or 604250 resumption.

---

## 1. Test Environment

```text
Required: Supabase local + Docker, matching the environment already used for the
  604268 Addendum replay attempt.

- DB container: supabase_db_yoonsul_wait_order_handoff
- Verification database name MUST include one of: local / test / dev
  (required by 0034_seed_data.sql's own guard, confirmed at L14-16:
   `if current_database() not like '%dev%' and not like '%test%' and not like '%local%'`
   -> raises exception; the default `postgres` database MUST NOT be used for seed/replay)
- Recommended naming, consistent with 604260's prior run: catchmenu_local_verify_604270
  or a fresh catchmenu_local_verify_<date> database, never the shared/default `postgres`
  database and never a database also used for unrelated manual testing.
- Each full replay attempt should run against a freshly created, disposable database
  (drop and recreate before each run) so partial-failure state from a prior attempt
  cannot mask or hide a new failure.
```

---

## 2. Pre-Test Safety Checks

```text
Before any test in this plan is executed against a real fix:
  1. Confirm 604276 Human Approval exists and explicitly authorizes the specific
     0035/0038 change being tested (Option A/B/C/D per 604273 §9, as selected).
  2. Confirm the test database is disposable (name matches local/test/dev pattern;
     is not any shared, cloud, or production-linked database).
  3. Confirm git status shows no unintended modification outside the files named in
     604276's Allowed Files list.
  4. Confirm no test in this plan writes to or drops any non-disposable database.
```

---

## 3. Full Clean Replay Test

```text
TC-BLK-001: Full sequential replay, 0001 through highest-numbered migration, against a
  fresh disposable database (catchmenu_local_verify_* naming).
Expected (pre-fix, current state): halts at 0035 (first run) / 0038 (continued run);
  0142 not reached. This is the CURRENT documented baseline (604268 Addendum) and
  should be re-confirmed once before any fix is applied, to guard against environment
  drift since the original 604268 run.
Expected (post-fix, after 604276-authorized change): sequential replay proceeds past
  0035 and 0038 without error and reaches and applies 0142 successfully.
```

---

## 4. 0035 Verification Test

```text
TC-BLK-010: Apply 0035 (post-fix form, per whichever option 604276 selects) in
  isolation against a database already at post-0034 state.
Expected: DO block executes without a parse or apply error; all `assert_true`-style
  checks it performs run and report PASS/FAIL via RAISE NOTICE/WARNING as originally
  intended, with no change to persisted schema (0035 remains verification-only by
  design, per 604271 §4.2 and 604273 §2 -- a fix must preserve this property, not add
  side effects).
TC-BLK-011 (if Option C skip policy selected for 0035): confirm the harness-level skip
  is explicit, logged, and does not silently suppress a genuine schema-integrity
  failure that 0035 was designed to catch.
```

---

## 5. 0038 Webhook RPC Compile Test

```text
TC-BLK-020: Apply 0038 (post-fix form) in isolation against a database already at
  post-0037 state.
Expected: `create or replace function catchmenu_integrations.verify_toss_signature`
  and `create or replace function catchmenu_integrations.process_toss_webhook` both
  compile and are created successfully (PostgreSQL's default CREATE-time PL/pgSQL body
  validation passes).
TC-BLK-021: Directly exercise the previously-broken unknown-status branch (line ~397)
  with a webhook payload carrying an unrecognized Toss status value; confirm the
  UPDATE against catchmenu_integrations.toss_webhooks succeeds, processing_status is
  set to 'FAILED', and processing_error is set to the expected
  'unknown_toss_status: <status>' string (this is the exact branch the original `:=`
  defect was in).
TC-BLK-022: Confirm 0039_create_kds_bulk_commit_rpc.sql (declared dependent on 0038)
  applies successfully immediately after the fixed 0038.
```

---

## 6. 0142 Reachability Test

```text
TC-BLK-030: Continue the full sequential replay from TC-BLK-001 past 0038 through the
  intervening migrations (039-141) and confirm 0142_patch_toss_mvp_payment_intent_
  binding.sql is reached and applies without error.
Expected: 0142's own CREATE OR REPLACE FUNCTION, trigger creation, and ALTER TABLE/
  CONSTRAINT statements execute successfully -- this is the exact evidence 604269
  Required Fix #2 and 604268's original Verification gap were waiting on.
```

---

## 7. 0142 Object Verification Test

```text
TC-BLK-040: After TC-BLK-030 succeeds, confirm the specific objects 0142 is expected to
  create/alter exist and match 604267 Module's self-report:
  - toss_payment_requests.payment_intent_id column exists, nullable, FK to
    payment_intents.
  - bind_toss_payment_intent() BEFORE INSERT trigger exists on toss_payment_requests.
  - initiate_toss_payment_legacy_604260 / confirm_toss_payment_legacy_604260 exist with
    the original signatures; the new same-signature wrapper functions exist and are
    reachable in place of the originals.
TC-BLK-041: Runtime dry-run per 604269 §11's original evidence-gap list: intent
  creation on first Toss request, intent reuse on a compatible retry,
  INTENT_BINDING_CONFLICT on a genuinely concurrent/incompatible candidate,
  INTENT_BINDING_REQUIRED/INVALID on confirm without a valid binding, direct-confirm
  and webhook-DONE convergence, and RLS/permission behavior for the renamed legacy
  functions now revoked from public/authenticated.
```

---

## 8. 604260 Re-Verification Test

```text
TC-BLK-050: Once TC-BLK-030/040/041 pass, update 604268 Verification's own record (not
  in this workpacket -- a 604260-owned document update) to reflect that full valid
  sequential replay now reaches and validates 0142, and route the resulting evidence
  back to a future 604260 re-audit. 604270 itself does not perform this update; it only
  defines the test whose PASSING result is the trigger for that separate, later update.
```

---

## 9. Regression Checks

```text
TC-BLK-060: Confirm no migration between 0001 and the highest existing number other
  than 0035 and 0038 (and, if in scope per 604276, 0073) changed behavior as a side
  effect of the fix -- diff the full replay log against the pre-fix partial log for any
  new, unexpected NOTICE/WARNING/ERROR in files 0001-0034 and, once reachable, 0039-0141.
TC-BLK-061: If 0035 is rewritten (not merely skip-policy'd), confirm its assertions
  still catch a deliberately introduced schema defect (e.g., temporarily rename a
  seeded row) in a disposable test run, to prove the rewrite preserves verification
  power and is not merely a no-op replacement.
```

---

## 10. Failure Handling

```text
If any test in §3-§8 fails after a 604276-authorized fix is applied:
  1. Do not mark 604270 or 604260 closed.
  2. Record the new failure with the same rigor as the original 604268 Addendum
     (exact file, line, error text, database state).
  3. Escalate back to Human for a decision on whether the authorized fix needs revision
     (new 604276 revision or a follow-up ChangeContract) before re-attempting replay.
  4. Do not attempt an ad hoc, undocumented correction to unblock the test run.
```

---

## 11. Evidence To Record

```text
For each test run (pass or fail):
  - Database name used (must show local/test/dev pattern) and creation/drop timestamps.
  - Exact migration file and line reached at halt (if any).
  - Full error text, verbatim.
  - Git diff of any file touched, scoped to 604276's Allowed Files list only.
  - psql/Supabase CLI version and Docker container ID
    (supabase_db_yoonsul_wait_order_handoff) used for the run.
```

---

## 12. Final TestPlan

```text
This TestPlan is a design artifact only. No test in it may be executed against
0035/0038 content changes until 604276 Human Approval exists and names the authorized
fix option. It may be used, read-only, today to describe and re-confirm the currently
blocked baseline state (TC-BLK-001, pre-fix expectation) without modifying anything.
```
