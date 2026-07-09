# 604281_ImpactScope_Cross_Scope_0042_Delivery_Order_Intake_Baseline_Replay_Blocker.md

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

604280 does not authorize 604250 implementation or 604260 closeout.
604250 may resume only after 604260 precondition closes **and** explicit Human reauthorization — not via this workpacket alone.

Historical migration files are read-only for this investigation pass.
Do not modify `0042_create_delivery_order_intake_rpc.sql`, `0142_patch_toss_mvp_payment_intent_binding.sql`, or other baseline files without a future approved ChangeContract.

---

## 0. Purpose

Cross-scope workpacket **604280** investigates the **0042** baseline migration replay blocker exposed after **604277** fixed **0035** / **0038** and **604278** re-ran clean sequential replay.

Goals (investigation only):

1. Confirm the actual defect in `0042_create_delivery_order_intake_rpc.sql`
2. Map functions, grants, and upstream/downstream dependencies
3. Assess delivery order intake runtime impact if 0042 fails to apply
4. Classify whether repair is a one-line syntax fix or broader logic change
5. Propose minimum safe correction scope for future design (no implementation here)

---

## 1. Trigger

| Source | Finding |
| --- | --- |
| `604278` Verification §5 | Clean replay on `catchmenu_local_verify_604278` passed **0001–0041**; failed at **0042** |
| `604279` Audit §8, §14 | `PASS_WITH_NEW_BASELINE_BLOCKER`; 0042 outside 604276 boundary; 0142 still not reached |
| `604268` / `604269` (604260) | Runtime closeout remains blocked by baseline replay chain |

**Reported error (604278, verbatim summary):**

```text
psql:.../0042_create_delivery_order_intake_rpc.sql:493: ERROR: syntax error at or near ":="
LINE 385: result_payload := jsonb_build_object(
```

(psql line numbers count from function-body context; source file line **396** holds the defect.)

---

## 2. Evidence Source

| Type | Path |
| --- | --- |
| Blocker SQL | `sql/migrations/0042_create_delivery_order_intake_rpc.sql` |
| Prior blocker pattern | `sql/migrations/0038_create_toss_webhook_processor_rpc.sql` (fixed: `processing_error =`) |
| Verification record | `604278_Verification_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md` |
| Audit record | `604279_Audit_Cross_Scope_Local_Migration_Replay_Baseline_Blockers.md` |
| Order / POS DDL | `0013_create_pos_orders.sql`, `0026_create_order_rpc.sql` |
| Successor delivery migrations | `0057_create_delivery_platform_rpc.sql`, `0078_create_delivery_sync_rpc.sql`, `0106_create_delivery_platform_pipeline_rpc.sql` |
| Immediate successor | `0043_create_did_display_rpc.sql` (`Depends on: 0042`) |

Repo searches run: `result_payload :=` (migrations), `intake_delivery_order`, `sync_delivery_order_status`, `reject_delivery_order` across `sql/migrations/*.sql` and `docs/**/*.md`.

---

## 3. Confirmed Blocker

| # | Migration | Failure mode | In 604260 scope? |
| --- | --- | --- | --- |
| 1 | `0042_create_delivery_order_intake_rpc.sql` | Parse/compile error inside `intake_delivery_order`: `UPDATE ... SET result_payload := jsonb_build_object(...)` — SQL column assignment requires `=` not `:=` | **No** |

**Single defect location (source file):**

```sql
update catchmenu_common.idempotency_keys
set
  processing_status = 'COMPLETED',
  completed_at = now(),
  result_payload := jsonb_build_object(   -- line 396: invalid
    'order_id', v_order_id,
    'session_id', v_session_id,
    'order_number', v_order_number
  )
where ...
```

**Repo-wide `result_payload :=` search:** exactly **one** match — this line in **0042** only.

Neither blocker is introduced by **0142** or 604260 implementation artifacts.

---

## 4. 0042 Source Review

### File header

| Field | Value |
| --- | --- |
| Depends on | `0041_create_agent_heartbeat_rpc.sql` |
| Declared creates | Three functions in `catchmenu_integrations` |

### Functions defined (all in one file)

| Function | Lines (approx.) | Apply status when file fails |
| --- | --- | --- |
| `catchmenu_integrations.intake_delivery_order(...)` | 12–493 | **Fails** — defect inside this function body |
| `catchmenu_integrations.sync_delivery_order_status(...)` | 496–612 | **Not applied** — same file aborts before this statement executes |
| `catchmenu_integrations.reject_delivery_order(...)` | 615–787 | **Not applied** |
| Grants + comments | 790–834 | **Not applied** |

### Defect analysis

| Question | Answer |
| --- | --- |
| Is `result_payload :=` inside SQL `UPDATE ... SET`? | **Yes** — `catchmenu_common.idempotency_keys` update at lines 392–404 |
| Correct form? | **`result_payload = jsonb_build_object(...)`** |
| Same class as 0038 pre-fix? | **Yes** — PL/pgSQL assignment operator (`:=`) used in plain SQL UPDATE SET list |
| Other `:=` in UPDATE SET in this file? | **No** — other UPDATE blocks use `=` correctly (e.g. lines 223, 376, 385, 545, 671, 690, 698) |
| Function signature change needed? | **No** |
| Delivery business logic change needed? | **No evidence** — defect is syntactic; surrounding intake flow (idempotency, gateway event, order/KDS creation, ledger, audit) is structurally intact |

### Comparison to 0038 fix (604277, approved precedent)

| Item | 0038 (fixed) | 0042 (open) |
| --- | --- | --- |
| Context | `UPDATE ... SET processing_error :=` | `UPDATE ... SET result_payload :=` |
| Approved fix | `processing_error =` | Candidate: `result_payload =` |
| Lines changed (0038 actual) | 1 | Candidate: **1** |

---

## 5. 0042 Runtime / Object Impact

When **0042** fails on clean replay (`604278` evidence):

| Object | Expected if 0042 applied | Actual after failed replay |
| --- | --- | --- |
| `intake_delivery_order` | `catchmenu_integrations` RPC | **Not created** — sole definition in repo is 0042 |
| `sync_delivery_order_status` | `catchmenu_integrations` RPC | **Not created** at 0042; later **0078** redefines same name if replay reaches 0078 |
| `reject_delivery_order` | `catchmenu_integrations` RPC | **Not created** at 0042; later **0106** redefines same name if replay reaches 0106 |
| EXECUTE grants on above | `authenticated` role | **Not applied** |

### `intake_delivery_order` runtime behavior (design intent, not verified)

- Validates provider type (`DELIVERY_BAEMIN`, `DELIVERY_YOGIYO`, `DELIVERY_COUPANG`)
- Idempotency via `catchmenu_common.idempotency_keys`
- Gateway sandbox ingest via `catchmenu_gateway.provider_raw_events`
- Creates delivery `order_sessions`, `orders`, `order_items`, KDS tickets
- Emits `order_events`, ledger events, audit records
- Completes idempotency key with `result_payload` JSON (the failing UPDATE)

### Downstream callers of `intake_delivery_order`

| Migration | Usage |
| --- | --- |
| `0057_create_delivery_platform_rpc.sql` | `process_baemin_order`, `process_yogiyo_order`, `process_coupang_order` route to `intake_delivery_order` |
| `0074_create_pos_provider_registry.sql` | Provider registry paths call `intake_delivery_order` |

These migrations **may apply** after a manual skip of 0042 (PostgreSQL does not require callee existence at CREATE time for plpgsql bodies), but **runtime calls would fail** until `intake_delivery_order` exists.

### Delivery functions redefined later

| Function | First definition | Later redefinition |
| --- | --- | --- |
| `sync_delivery_order_status` | 0042 | **0078** (`create or replace function`) |
| `reject_delivery_order` | 0042 | **0106** (`create or replace function`) |

**0142 (Toss payment intent binding)** has no grep hits referencing 0042 delivery functions — replay unblock for 604260 closeout is structural (sequential apply), not delivery-runtime-coupled.

---

## 6. Dependency Review

### Upstream (0042 requires — from earlier migrations)

| Dependency | Source migrations (representative) |
| --- | --- |
| `catchmenu_hq.stores` | HQ schema migrations |
| `catchmenu_common.idempotency_keys` | Common schema |
| `catchmenu_gateway.provider_raw_events` | Gateway schema |
| `catchmenu_pos.order_sessions`, `orders`, `order_items`, `menus` | `0013`, `0026` |
| `catchmenu_kds.kds_tickets` | KDS migrations |
| `catchmenu_ledger.events` | Ledger migrations |
| `catchmenu_audit.append_audit_record` | Audit RPC migrations |

All upstream objects exist after **0041** (last successful apply in 604278).

### Downstream (depend on 0042 applying)

| Migration | Relationship |
| --- | --- |
| `0043_create_did_display_rpc.sql` | Header: `Depends on: 0042` — sequential replay never reaches this on 604278 DB |
| `0057_create_delivery_platform_rpc.sql` | Calls `intake_delivery_order` in function bodies |
| `0074_create_pos_provider_registry.sql` | Calls `intake_delivery_order` |
| `0078_create_delivery_sync_rpc.sql` | Calls and redefines `sync_delivery_order_status` |
| `0106_create_delivery_platform_pipeline_rpc.sql` | Calls and redefines `reject_delivery_order` |
| `0096_schema_final_validation.sql` | Lists `sync_delivery_order_status` in validation set |
| `0113_create_api_spec_docs.sql` | Documents `reject_delivery_order` |

No migration between **0043** and **0142** was verified in this ImpactScope pass for Toss/payment-intent coupling to 0042.

---

## 7. Replay Impact

| Scenario | Outcome |
| --- | --- |
| Clean sequential replay 0001–0142 (`ON_ERROR_STOP=1`) | **Stops at 0042** — confirmed `604278` |
| Last successful migration | `0041_create_agent_heartbeat_rpc.sql` |
| 0142 reached? | **No** |
| 0103 / Toss pipeline reached? | **No** |
| 0073 final verification reached? | **No** — deferred; may expose additional blockers after 0042 |

Fixing **0042** is **necessary** for clean sequential replay to progress. Further blockers (e.g. **0073** inline-procedure pattern noted in 604278/604279) may appear after 0042 is resolved — out of scope for this ImpactScope's primary finding.

---

## 8. Scope Classification

**Classification: A — one-line syntax blocker, direct historical correction candidate**

| Criterion | Assessment |
| --- | --- |
| Defect type | SQL syntax — wrong assignment operator in UPDATE SET |
| Fix shape | Change `result_payload :=` → `result_payload =` (one line) |
| Logic / signature change | **Not indicated** |
| Broader delivery intake redesign | **Not indicated** by source review |
| Replay-harness-only issue | **No** — PostgreSQL rejects the migration file at apply time |
| Unclear / needs Claude design | **Low** — mirrors approved 0038 pattern; future 604283 Logic should still confirm no additional defects in same file |

**Not B:** No evidence that delivery intake business rules, payload normalization, or KDS logic are wrong — only the idempotency completion UPDATE is syntactically invalid.

**Not C:** Failure occurs during `psql -f` migration apply, not harness configuration.

**Not D:** Source is unambiguous; design docs still required before implementation per lifecycle rules.

---

## 9. Files In Scope For Future Design

| File | Future role |
| --- | --- |
| `sql/migrations/0042_create_delivery_order_intake_rpc.sql` | Primary correction target (pending 604285 Approval) |
| `604282` Overview | Problem statement, 604270 lineage, 604279 trigger |
| `604283` Logic | Exact diff specification, side-effect analysis, skip policy |
| `604284` TestPlan | Clean replay 0042 apply; function existence; optional intake smoke (if authorized) |
| `604285` ChangeContract | Approved file list, forbidden files, boundary with 604260/604250 |
| `604286` Human Approval | Authorize in-place 0042 one-line fix (or alternative strategy) |

Reference precedents: `604271`–`604276` (0035/0038 package).

---

## 10. Files Out Of Scope

| File / area | Reason |
| --- | --- |
| `0142_patch_toss_mvp_payment_intent_binding.sql` | 604260 artifact; not modified by 604280 |
| `0014`, `0027`, `0052`, `0098`, `0103` | Scope D payment paths — separate workpackets |
| `0035`, `0038` | Resolved under 604270; not re-opened here |
| `604250` folder | Resume not authorized |
| `604260` closeout documents | Not updated by this ImpactScope |
| `604310` / `604316` | Not created; not authorized |
| `0057`, `0078`, `0106` delivery migrations | Downstream consumers; no edit without separate approval |

---

## 11. Forbidden Actions

- Do **not** modify `0042_create_delivery_order_intake_rpc.sql` without future Human Approval
- Do **not** modify `0142` or other payment-scope migrations under 604280
- Do **not** close **604260** or authorize **604250** resume from this ImpactScope
- Do **not** implement or authorize Codex implementation from this document
- Do **not** create `604316` or implement **604310**
- Do **not** conclude that 0042 is fixed, 0142 is reached, or implementation is approved

---

## 12. Proposed Next Documents

| # | Document | Purpose |
| --- | --- | --- |
| 604282 | Overview | Workpacket charter, lineage from 604279, success criteria |
| 604283 | Logic | One-line fix specification, full-file scan for similar defects, skip policy |
| 604284 | TestPlan | TC: 0042 apply; three functions + grants; replay 0043+ progress toward 0142 |
| 604285 | ChangeContract | Approved change boundary |
| 604286 | Human Approval | Gate before any SQL edit |
| 604287 | Module | Implementation record (Codex, post-approval) |
| 604288 | Verification | Supabase local clean replay evidence |
| 604289 | Audit | Independent audit |

---

## 13. Open Questions

1. **Human Approval strategy:** In-place one-line edit (6038 precedent) vs forward patch migration — to be decided in 604283/604285, not here.
2. **Post-0042 blockers:** Will **0073_final_verification.sql** fail with the same inline-procedure pattern as pre-fix **0035**? Deferred until replay progresses.
3. **Delivery runtime smoke tests:** Should 604284 require calling `intake_delivery_order` with seed data, or is apply + function-existence sufficient for baseline replay gate?
4. **604270 closeout vs successor:** Does 604270 remain open for replay-to-0142 goal, or does 604280 fully own the 0042→0142 path? Human navigation decision (604306 update TBD).
5. **Owner assignment:** Required before 604286 Human Approval.

---

## 14. Final ImpactScope Result

```text
CONFIRMED_BASELINE_BLOCKER — CLASSIFICATION A (PRELIMINARY)
```

Summary:

| Item | Result |
| --- | --- |
| Confirmed defect | `result_payload :=` in UPDATE SET at line 396 of `0042_create_delivery_order_intake_rpc.sql` |
| Correct form | `result_payload =` |
| One-line correction candidate | **Yes** — same class as 0038 pre-fix |
| Business logic change required | **No evidence** |
| 0042 skip for clean replay | **Not allowed** — replay halts; idempotency completion + sole `intake_delivery_order` definition missing |
| 0142 reachability requires 0042 fix | **Yes** — for clean sequential replay with `ON_ERROR_STOP=1` |
| 604260 closeout | **Still blocked** |
| 604250 resume | **Still not allowed** |
| Implementation approved | **No** |

604280 ImpactScope investigation is complete. **604282 Overview / 604283 Logic / 604284 TestPlan / 604285 ChangeContract** drafting is the next lifecycle step. **604289 Audit** will be required after future implementation and verification.
