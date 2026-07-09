# 604268_Verification_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md

Status: Partial
Lifecycle: Verification
Gate Classification: Local Verification
Runtime Implementation Authorization: Not Granted By This Document
Owner: Local Verification Runner
Last Updated: 2026-07-02

## 0. Purpose

Record static verification evidence for the 604260 implementation without changing SQL, migrations, design documents, or runtime behavior.

## 1. Verification Scope

Verification covers `0142_patch_toss_mvp_payment_intent_binding.sql`, the 604267 Module, the 604266 approval boundary, and the 604306 handoff route. PostgreSQL compilation, migration application, and runtime dry-run are outside the completed evidence because no safe verification database or connection was available.

## 2. Approval Source

The controlling source is `604266_Approval_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md`. It authorizes one append-only migration and the 604267 Module only, and prohibits resuming 604250, implementing 604310, or creating 604316.

## 3. Implemented Files Checked

- `sql/migrations/0142_patch_toss_mvp_payment_intent_binding.sql`: exists.
- `604267_Module_Scope_D_00A_Toss_MVP_PaymentIntent_Binding_Precondition.md`: exists and has the expected H1.
- `0142` follows the present `0141_hyper_personalization_menu_customization.sql` prefix without conflict.
- The scoped implementation artifacts are the approved migration and Module. The repository contains extensive unrelated pre-existing changes, so whole-worktree authorship cannot be reconstructed from the current dirty diff alone.

## 4. Forbidden Files Checked

- No diff was reported for actual historical migrations `0014_create_payment_ledger.sql`, `0027_create_payment_intent_rpc.sql`, `0052_create_kiosk_session_rpc.sql`, `0098_create_payment_confirm_pipeline_rpc.sql`, or `0103_create_toss_payments_pipeline_rpc.sql`.
- `604257_Module_Scope_D_00_PaymentLedger_ConfirmPayment_SchemaDrift_Alignment.md` does not exist.
- `604316_Approval_Scope_D_01_Payment_Confirm_Idempotency.md` does not exist.
- No 604250 implementation resume or 604310 implementation is present in migration 0142.

## 5. Command Evidence

The following checks were run:

```text
Test-Path for migration 0142 and Module 604267
Get-Content 604267 -TotalCount 1
Select-String static inspection of migration 0142
git diff --name-only
git status --porcelain for the scoped paths
git diff --name-only for historical migration paths
git diff --check for migration 0142 and Module 604267
Test-Path for forbidden 604257 and 604316 files
Select-String on 0103 for webhook DONE delegation
psql --version
safe database environment-variable presence checks
```

The working tree is broadly dirty. This verification therefore treats the path-scoped evidence as authoritative and records the dirty-tree attribution limitation as a gap.

## 6. Static SQL Inspection

Migration 0142 statically contains:

- nullable `toss_payment_requests.payment_intent_id uuid` addition;
- FK `fk_toss_payment_requests_payment_intent` referencing `catchmenu_payment.payment_intents(id)`;
- a partial index for non-null bindings;
- a BEFORE INSERT trigger invoking `bind_toss_payment_intent()`;
- advisory serialization and tenant/store/order plus amount, provider, and session compatibility checks;
- active-intent reuse or creation through `create_payment_intent` during Toss request insertion;
- namespaced intent idempotency key `TOSS-INTENT:<request-key>`;
- same-signature wrappers for `initiate_toss_payment` and `confirm_toss_payment`.

This is not an order-id-only resolver: candidate selection is constrained by tenant, store, order, active status, amount, provider, and session. No payment intent is synthesized in the confirm wrapper.

## 7. Migration Verification

Static result: passed.

- File exists and prefix 0142 is sequential after the currently present 0141.
- Historical migrations were not directly modified.
- `git diff --check` passed for 0142 and 604267; only line-ending conversion warnings were emitted.
- SQL parse/compile and sequential application were not run because `psql` is unavailable and no safe disposable database connection was configured.

## 8. Function Contract Verification

- Initiate: the preserved implementation inserts the Toss request, whose BEFORE INSERT trigger must bind or create a compatible intent; the wrapper then reloads and exposes `payment_intent_id`.
- Confirm: the wrapper loads the Toss request by `order_id_toss`, rejects missing or invalid intent bindings, then delegates to the preserved confirmation implementation.
- The confirm wrapper does not pass `p_intent_id` into `confirm_payment`; that remains a 604250 interface dependency.
- Runtime correctness of function rename, trigger execution, permissions, JSON response shape, concurrency, and retry behavior remains unproven without database execution.

## 9. Handoff Contract Verification

The static output prepares the 604250 handoff by exposing a strongly bound `payment_intent_id`. It does not resume or authorize 604250. The 604306 NavigationMap still describes 604260 as not yet implemented, verified, audited, or closed; that state text is stale after 604267 creation and should be reconciled only under a separately authorized documentation sync.

## 10. Forbidden Shortcut Verification

- No confirm-time synthetic intent creation was found.
- No primary order-id-only resolver was found.
- No rename or merge of `provider_order_id` and `order_id_toss` was found.
- The existing webhook DONE branch in migration 0103 calls the public `confirm_toss_payment`, so it resolves through the new guarded wrapper after 0142.
- No fallback session creation was found.
- The binding-time amount equality check protects intent compatibility; no 604310 replay registry, request fingerprint, effective idempotency key registry, or same-success replay implementation was found.

## 11. Runtime / Dry-Run Verification

```text
SQL compile: NOT RUN - psql unavailable; no safe verification DB configured
Migration apply: NOT RUN - no safe disposable verification DB configured
Runtime dry-run: NOT RUN - migration was not applied to a disposable DB
```

No operating or shared database was modified.

## 12. Known Gaps

- PostgreSQL parse/compile evidence is missing.
- Sequential migration application evidence is missing.
- Runtime tests for create, reuse, concurrency, terminal retry, missing binding, invalid binding, direct confirm, and webhook DONE are missing.
- The dirty worktree prevents definitive whole-repository attribution from `git diff --name-only` alone.
- 604267 section 12 names four historical migrations incorrectly: it says `0014_create_payment_tables.sql`, `0027_create_payment_rpc.sql`, `0098_create_toss_payments_adapter.sql`, and `0103_create_toss_payment_functions.sql`; the actual repository files use the names recorded in section 4 above. The Module was not modified because this Verification task permits creation of 604268 only.
- 604306 contains a stale pre-implementation state statement for 604260.

## 13. Final Verification Result

```text
PARTIAL
```

Static boundary and SQL inspection passed. Full verification cannot pass until compile, disposable migration apply, and runtime dry-run evidence is available. The Module filename inconsistency and stale NavigationMap state also remain open documentation gaps.

## 14. Final Rule

This Verification does not authorize 604250 resume, 604310 implementation, 604316 creation, release, merge, or production application. Independent 604269 Audit may proceed with a PARTIAL result, but closure requires the missing runtime evidence and resolution of the recorded documentation gaps.

## Addendum - Post-Verification Documentation Corrections

After the initial PARTIAL verification, documentation-only corrections were made:

- 604267 Module existing migration filename references were corrected to match actual repository paths.
- 604306 NavigationMap 604260 state was updated from pre-implementation to implemented-but-not-audited/closed state.

The actual repository contains `0052_create_kiosk_session_rpc.sql`; the non-existent `0052_create_kiosk_payment_flow.sql` name was not introduced.

No SQL, migration, runtime, 604250, 604310, or 604316 files were changed. The overall Verification Result remains PARTIAL because SQL compile, migration apply, and runtime dry-run remain not performed.

---

## Addendum — Runtime Evidence For 0142

Recorded: 2026-07-02 (Local Verification Runner pass)

### Environment

- psql available: **No** — `psql` not found on PATH (`CommandNotFoundException`)
- Verification DB safety: **Unavailable** — no `$conn`, `DATABASE_URL`, or `PGHOST` configured; disposable verification database could not be identified or confirmed safe
- Production DB used: **No** — no database connection was attempted

### Commands Run

```text
psql --version                          → FAILED (psql not installed / not on PATH)
echo $conn                            → not set (connection string absent)
DATABASE_URL / PGHOST checks          → not set
psql $conn -f .../0142_...sql         → NOT RUN (no psql, no safe conn)
information_schema column/FK queries  → NOT RUN (no psql, no safe conn)
function existence queries            → NOT RUN (no psql, no safe conn)
git diff --name-only (historical migrations) → no output (unchanged)
Test-Path 604257 → False
Test-Path 604316 → False
git diff --check (0142, 604268)       → passed (LF/CRLF warnings only)
```

No connection string was used. No credentials were exposed.

### SQL Compile / Migration Apply Result

- Result: **NOT RUN**
- Summary: Execution stopped per safety rule — without `psql` and without a confirmed disposable verification database, `0142_patch_toss_mvp_payment_intent_binding.sql` was not applied to any database. No operating or shared database was modified.

### Object Verification

Schema note: `toss_payment_requests` lives in **`catchmenu_integrations`**, not `catchmenu_payment` (per `0103` / `0142`). Planned queries were adjusted accordingly but not executed.

- toss_payment_requests.payment_intent_id: **NOT VERIFIED RUNTIME** — query not run; static inspection of `0142` L5–6 confirms `ADD COLUMN payment_intent_id uuid` on `catchmenu_integrations.toss_payment_requests`
- payment_intent_id FK: **NOT VERIFIED RUNTIME** — static inspection of `0142` L17–20 confirms `fk_toss_payment_requests_payment_intent` → `catchmenu_payment.payment_intents(id)`
- initiate_toss_payment function: **NOT VERIFIED RUNTIME** — static inspection of `0142` L212–243 confirms legacy rename + new wrapper `catchmenu_integrations.initiate_toss_payment(...)`
- confirm_toss_payment function: **NOT VERIFIED RUNTIME** — static inspection of `0142` L216–347 confirms legacy rename + new guarded wrapper `catchmenu_integrations.confirm_toss_payment(...)`

### Runtime / Dry-Run Result

- Result: **NOT RUN**
- Summary: No disposable PostgreSQL instance was available. Minimal runtime dry-run (initiate → bind intent → confirm path) was not executed.
- Not run reason: **`psql` unavailable** and **no safe verification DB connection configured**; cannot answer safety checklist items 1–4 affirmatively without a known disposable target.

### Boundary Recheck

- Existing migrations unchanged: **Yes** — `git diff --name-only` for `0014`, `0027`, `0052`, `0098`, `0103` returned empty
- 604250 not resumed: **Yes** — `604257_Module` does not exist
- 604257 not created: **Yes** — `Test-Path` → False
- 604310 not implemented: **Yes** — no 604310 runtime artifacts in this pass
- 604316 not created: **Yes** — `Test-Path` → False

### Updated Verification Result

```text
PARTIAL
```

Rationale: Static boundary checks and `git diff --check` pass, but **0142 compile/apply**, **object existence queries**, and **runtime dry-run** remain unexecuted due to missing `psql` and missing safe verification database. Required Fix from 604269 (`Runtime evidence: missing`) is **not closed** by this pass.

---

## Addendum — Supabase Local Migration Replay Attempt

Recorded: 2026-07-04 (Verification Recorder pass)

### Environment And Replay Setup

- Supabase local + Docker environment was successfully prepared.
- DB container: `supabase_db_yoonsul_wait_order_handoff`
- Clean verification DB was used: `catchmenu_local_verify_604260`
- Initial postgres DB was not used for final replay because `0034` seed guard blocks databases whose name does not include `dev`, `test`, or `local`.
- `0034_seed_data.sql` passed on `catchmenu_local_verify_604260`.

### Sequential Replay Outcome

| Migration | Result | Notes |
| --- | --- | --- |
| Through `0034_seed_data.sql` | **Passed** | On `catchmenu_local_verify_604260` |
| `0035_verify_schema.sql` | **Failed** | Pre-existing PL/pgSQL syntax error |
| `0038_create_toss_webhook_processor_rpc.sql` | **Failed** | Reached after 0035 classification; replay continued to inspect further blockers |
| `0142_patch_toss_mvp_payment_intent_binding.sql` | **Not reached** | Full valid sequential replay did not reach 0142 |

### Blocker Details

**0035_verify_schema.sql**

- Failure source: DO block DECLARE section attempts inline procedure declaration.
- `0035` is not part of 604260 implementation.
- `0035` was identified as a **baseline replay blocker**.

**0038_create_toss_webhook_processor_rpc.sql**

- Failure source: `UPDATE ... SET` uses `processing_error :=` instead of `processing_error =`.
- `0038` is not part of 604260 implementation.
- `0038` is **not safely skippable** for 604260 runtime closeout because Toss webhook processing is related to the webhook DONE convergence contract.

### 0142 And 604260 Runtime Status

- `0142_patch_toss_mvp_payment_intent_binding.sql` was **not reached** in full valid sequential replay.
- Therefore **0142 SQL compile/apply runtime evidence remains unavailable**.
- 604260 remains **statically and boundary-audited** but **runtime closeout is blocked** by pre-existing baseline migration replay blockers.

### Updated Verification Result

```text
PARTIAL — BLOCKED_BY_BASELINE_MIGRATION_REPLAY
```

604260 should not be closed based on this runtime attempt.

604250 must still not resume automatically.

0035/0038 fixes require a separate approval/workpacket because they are outside the 604266 Approval boundary.
