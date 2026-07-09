# 604271_ImpactScope_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md

Status: Draft
Lifecycle: ImpactScope
Gate Classification: Cross-Scope Baseline Migration Replay Blocker — Stage 1 Investigation
Runtime Implementation Authorization: Not Granted
Owner: TBD
Last Updated: 2026-07-04

**Owner rule:** `Owner` must be assigned before Human Approval. No implementation slice may proceed while Owner remains TBD.

This ImpactScope does not authorize implementation.
It only records discovered files, binding risks, and candidate future change boundaries.
Codex must not implement from this ImpactScope.
A slice-specific Overview, Logic, TestPlan, ChangeContract, and Human Approval are required before implementation.

604270 does not authorize 604250 implementation.
604270 exists because 604250 implementation stopped under 604256 due to unresolved payment_intent binding; subsequent 604260 runtime replay exposed additional baseline blockers in 0035 and 0038.
604250 may resume only after 604260 precondition closes **and** explicit Human reauthorization — not via this workpacket alone.

Historical migration files are read-only for this investigation pass.
Do not modify `0035_verify_schema.sql`, `0038_create_toss_webhook_processor_rpc.sql`, `0142_patch_toss_mvp_payment_intent_binding.sql`, or other baseline files without a future approved ChangeContract.

---

## 0. Purpose

Cross-scope workpacket **604270** investigates **pre-existing baseline migration replay blockers** discovered during **604260** Supabase local verification.

Goals (investigation only):

1. Measure **0035** / **0038** impact on sequential replay and downstream Scope D runtime closeout
2. Confirm whether **0035** is verification-only or mutates persistent state
3. Map **0038** runtime objects, tables, and webhook routing
4. Collect evidence on **in-place edit vs forward patch** repair strategies (no decision here)
5. Propose **minimum safe path** to resume **0142** runtime verification (design input only)

---

## 1. Trigger

| Source | Finding |
| --- | --- |
| `604268` Addendum — Supabase Local Migration Replay Attempt | Replay on `catchmenu_local_verify_604260` passed `0034`; failed at `0035`; continued inspection failed at `0038`; **0142 not reached** |
| `604269` Audit | `PASS_WITH_GAPS`; Required Fix: baseline migration replay blockers; 604260 Not Ready |
| `604306` NavigationMap | 604260 PARTIAL; 604250 must not resume automatically |

Container: `supabase_db_yoonsul_wait_order_handoff` (Supabase local + Docker).

---

## 2. Evidence Source

| Type | Path |
| --- | --- |
| Blocker SQL | `sql/migrations/0035_verify_schema.sql`, `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` |
| Table DDL (0038 deps) | `0020_create_integrations_and_local_ledger.sql` (`toss_webhooks`, `toss_payments`) |
| Successor webhook path | `0103_create_toss_payments_pipeline_rpc.sql` (redefines `process_toss_webhook`, `confirm_toss_payment`, `toss_webhook_log`) |
| Migration dependency | `0039_create_kds_bulk_commit_rpc.sql` — `Depends on: 0038` |
| Verification record | `604268` § Addendum — Supabase Local Migration Replay Attempt |
| Audit record | `604269` Addendum — baseline blocker classification |
| Navigation | `604306` §6, §123–131 |

Repo search: `process_toss_webhook`, `confirm_toss_payment`, `processing_error`, `unknown_toss_status` across `sql/migrations/*.sql`.

---

## 3. Confirmed Blockers

| # | Migration | Failure mode (604268 replay) | In 604260 scope? |
| --- | --- | --- | --- |
| 1 | `0035_verify_schema.sql` | PL/pgSQL parse error: inline `procedure assert_true` inside DO `DECLARE` (L14–28) | **No** |
| 2 | `0038_create_toss_webhook_processor_rpc.sql` | SQL error: `UPDATE ... SET processing_error :=` (L397) — assignment must use `=` | **No** |

Neither blocker is introduced by `0142` or 604260 implementation artifacts.

---

## 4. 0035 Impact Review

**File:** `sql/migrations/0035_verify_schema.sql` (598 lines)

**Header (L1–6):**

```text
Purpose: Full schema verification after 0001~0034 migration.
Creates: (none) — verification only
Depends on: 0034_seed_data.sql
```

### 4.1 Object operations (grep / full read)

| Operation type | Present? | Evidence |
| --- | --- | --- |
| `CREATE TABLE` / `CREATE SCHEMA` | **No** | — |
| `CREATE FUNCTION` / `CREATE OR REPLACE FUNCTION` | **No** | — |
| `ALTER TABLE` | **No** | — |
| `INSERT` / `UPDATE` / `DELETE` | **No** | — |
| `DROP` | **No** | — |
| `DO $$` anonymous block | **Yes** | L8–598 |
| Inline `procedure assert_true` in DECLARE | **Yes** | L14–28 |

### 4.2 Runtime behavior

- Executes read-only checks against `information_schema`, `pg_tables`, and seed rows (L510–576)
- Emits `RAISE NOTICE` / `RAISE WARNING` (L22–25)
- Raises exception `SCHEMA_VERIFICATION_FAILED` if any check fails (L589–592)
- **Does not create or mutate persistent schema objects**

### 4.3 Syntax defect

```sql
declare
  ...
  procedure assert_true(...) as $inner$ ... $inner$;  -- L14-28
begin
  call assert_true(...);
```

PostgreSQL PL/pgSQL in anonymous DO blocks does not support this inline procedure declaration form (604268 / 604269 recorded error).

### 4.4 Classification

**B — verification-only, should be rewritten/fixed for clean sequential replay**

Reason:
- Not **C** — no persistent DDL/DML side effects
- Not **A alone** for 604270 goals — targeted skip may unblock *manual* jumps to later migrations, but **clean sequential replay / CI bootstrap** requires a parse-valid replacement (rewrite DO block using nested `EXECUTE`, extract to standalone function, or replace with `0073`-style pattern review)
- Related future risk: `0073_final_verification.sql` uses the **same inline procedure pattern** (L9–14) — not yet reached in 604260 replay but likely same class of blocker later

### 4.5 Skip vs fix (investigation note)

| Strategy | Effect |
| --- | --- |
| Skip 0035 in targeted replay | May allow manual progression to 0038+ for blocker hunting; **does not** fix clean bootstrap |
| Rewrite 0035 | Required for full sequential replay integrity |
| Forward patch only (new migration) | Cannot substitute 0035 file apply failure unless migration runner skips/replaces 0035 |

---

## 5. 0038 Impact Review

**File:** `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` (454 lines)

**Header (L1–9):**

```text
Creates:
  catchmenu_integrations.process_toss_webhook(...)
  catchmenu_integrations.verify_toss_signature(...)
Depends on: 0037_create_payment_cancel_refund_rpc.sql
```

### 5.1 Functions created

| Function | Lines | Role |
| --- | --- | --- |
| `catchmenu_integrations.verify_toss_signature` | L11–51 | Header-format validation (HMAC noted as app-layer) |
| `catchmenu_integrations.process_toss_webhook` | L54–410 | Webhook dedup, signature, routing, payment actions |

### 5.2 Tables read / written

| Schema.Table | Operations |
| --- | --- |
| `catchmenu_integrations.toss_webhooks` | INSERT (L130, L161); UPDATE (L266, L313, L350, L375, **L395**) |
| `catchmenu_integrations.toss_payments` | UPDATE on DONE (L280–291) |
| `catchmenu_payment.payment_intents` | SELECT (L234–240); UPDATE on ABORTED/EXPIRED (L365–372) |
| `catchmenu_payment.payment_ledger` | SELECT for cancel path (L329–332) |
| `catchmenu_gateway.provider_raw_events` | INSERT (L210); UPDATE (L244, L307, L391) |
| `catchmenu_hq.stores` | SELECT timezone (L89–91) |

Table DDL source: `0020_create_integrations_and_local_ledger.sql` — `toss_webhooks.processing_error text` (L182).

### 5.3 Syntax defect location

```sql
-- L395-398 (else / unknown status branch)
update catchmenu_integrations.toss_webhooks
set processing_status = 'FAILED',
    processing_error := 'unknown_toss_status: ' || v_status,  -- INVALID: := in SET
    processed_at = now()
```

Correct form: `processing_error = 'unknown_toss_status: ' || v_status`.

### 5.4 Webhook status routing (`process_toss_webhook`)

| Toss `status` | Action | Payment path |
| --- | --- | --- |
| `DONE` | `confirm_payment_from_provider` (L294) | **0027** intent-based — not `0103` `confirm_toss_payment` |
| `CANCELLED`, `PARTIAL_CANCELLED` | `cancel_payment` (L338) | Ledger cancel |
| `ABORTED`, `EXPIRED` | Update `payment_intents` failed/expired (L365) | No ledger APPROVED |
| **else** (unknown) | Quarantine + FAILED webhook; **syntax error line** (L389–407) | `unknown_toss_status` response |

### 5.5 Why 0038 cannot be safely skipped for 604260 runtime closeout

1. **Migration chain:** `0039` depends on `0038` (header)
2. **Object existence:** Later migrations and `0073` assert `process_toss_webhook` exists (L626–629)
3. **Webhook semantics:** Establishes early Toss webhook → `payment_intents` → `confirm_payment_from_provider` pipeline; 604260/0142 webhook DONE convergence references guarded `confirm_toss_payment` in **0103**, but baseline replay must **compile through** 0038 to reach 0103/0142
4. **604268/604269 explicit policy:** 0038 not safely skippable for runtime closeout narrative

### 5.6 Later overlap (0103)

`0103` **redefines** `process_toss_webhook` with different signature (L871+) and adds `toss_webhook_log`, `confirm_toss_payment`, `process_toss_webhook` webhook handler calling `confirm_toss_payment` on DONE (L1021). Two generations exist in migration history — 604270 does not resolve consolidation; records as downstream design note.

### 5.7 Classification

**A — one-line syntax blocker, forward patch possible**

Reason:
- Root cause is a single invalid `:=` in UPDATE SET (L397)
- Broader design (**C**) not indicated — routing logic is intact aside from parse failure
- **Caveat:** Standard **sequential file apply** still requires 0038 file to parse unless Human Approval allows **historical in-place edit** or approved migration-runner skip; a later `CREATE OR REPLACE` patch alone does not execute if 0038 never applies

---

## 6. Runtime Replay Impact

### 6.1 Observed replay sequence (604268)

```text
0034_seed_data.sql          → PASS (catchmenu_local_verify_604260)
0035_verify_schema.sql      → FAIL (syntax)
0038 (continued inspection) → FAIL (syntax)
0142_patch_toss_mvp...      → NOT REACHED (full valid sequential replay)
```

### 6.2 Downstream gates

| Gate | Blocked? |
| --- | --- |
| 0142 SQL compile/apply evidence | **Yes** — not reached |
| 604260 runtime closeout | **Yes** |
| 604250 resume | **Yes** (604260 + reauthorization) |
| Clean Supabase local bootstrap | **Yes** — at minimum 0035 and 0038 |

### 6.3 Minimum safe path to resume 0142 verification (proposal — not approved)

```text
1. Close 604270 design: fix strategy for 0035 (rewrite verification DO block)
2. Close 604270 design: fix 0038 syntax (minimal one-line correction path)
3. Re-run full sequential replay through 0142 on disposable DB (catchmenu_local_verify_*)
4. Resume 604268 runtime evidence addendum for 0142 object checks + dry-run
5. Only then re-evaluate 604260 closeout / 604269 audit / 604250 reauthorization
```

---

## 7. Scope Classification

| Workpacket | Relationship to 604270 |
| --- | --- |
| **604260** | Triggered discovery; implementation (0142) not at fault for 0035/0038 |
| **604250** | Blocked downstream; no auto-resume |
| **604310** | Out of scope |
| **604270** | Cross-scope baseline repair investigation |
| **0035 / 0038** | Baseline infrastructure; outside 604266 boundary |

---

## 8. Files In Scope For Future Design

**Candidate only — not authorized.**

| Priority | Path | Likely future action class |
| --- | --- | --- |
| P0 | `sql/migrations/0035_verify_schema.sql` | Rewrite DO block OR approved historical edit OR replacement verification migration |
| P0 | `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` | One-line SET fix OR approved historical edit |
| P1 | `sql/migrations/0073_final_verification.sql` | Same inline-procedure pattern — preemptive review |
| P2 | `sql/migrations/0103_create_toss_payments_pipeline_rpc.sql` | Read-only context for post-0038 webhook/DONE path |
| Reference | `604268`, `604269`, `604306` | Gate and replay evidence |

---

## 9. Files Out Of Scope

```text
0142_patch_toss_mvp_payment_intent_binding.sql (no edit in 604270 investigation)
604250 patch / 604257 Module
604310 / 604316
0014, 0027, 0098, 0103 in-place edits (unless future 604275 expands)
Flutter, Edge, Python, config, tests
```

---

## 10. Forbidden Actions

```text
- Implement or "fix" 0035/0038 in this pass
- Resume 604250 or close 604260 based on this ImpactScope alone
- Skip 0038 without Human Approval and TestPlan coverage
- Claim 0142 passed or 0035/0038 fixed
- Codex implementation from this document
- Create 604272–604279 except as separately authorized
```

---

## 11. Proposed Next Documents

| Order | Document | Owner |
| --- | --- | --- |
| 1 | `604272_Overview_…` | Claude draft |
| 2 | `604273_Logic_…` | Claude draft — fix strategy, replay policy, edit vs patch |
| 3 | `604274_TestPlan_…` | Claude draft — sequential replay through 0142 smoke |
| 4 | `604275_ChangeContract_…` | Claude draft — allowed files, forbidden historical edits policy |
| 5 | `604276_Approval_…` | Human |

---

## 12. Open Questions

1. **Historical edit policy:** May 0035/0038 be edited in-place, or must fixes use append-only forward patches plus migration-runner exceptions?
2. **0035 rewrite shape:** Nested block vs extracted `catchmenu_common.assert_true` helper vs skip in CI with separate verification job?
3. **0038 vs 0103 webhook:** Is 0038 `process_toss_webhook` still required at runtime after 0103 replace, or only for migration chain integrity?
4. **0073 preemptive fix:** Include in same 604270 implementation slice or separate?
5. **Replay DB naming:** Standardize `catchmenu_local_verify_*` convention for all Scope D verification?
6. **0142 re-verification owner:** 604260 Verification addendum update vs new 604278 after 604270 closes?

---

## 13. Final ImpactScope Result

```text
Investigation complete.
0035 classified: B (verification-only; needs rewrite for clean replay)
0038 classified: A (one-line syntax; minimal fix candidate)

604260 runtime closeout: still blocked
604250 resume: still blocked
0142 runtime evidence: still unavailable

604270 does not authorize implementation.
Next: 604272–604275 drafting (Claude), then 604276 Human Approval before any SQL change.
```
