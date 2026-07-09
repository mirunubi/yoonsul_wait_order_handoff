# 604305_Verification_Cross_Scope_0065_Security_Isolation_Inline_Procedure_Replay_Blocker.md

Status: Complete
Lifecycle: Verification
Gate Classification: Local Verification — 0065 Inline Procedure Replay Blocker Fix
Runtime Implementation Authorization: Not Granted By This Document
Owner: Local Verification Runner (Cursor)
Last Updated: 2026-07-05

---

## 0. Purpose

Record Supabase local **clean replay** verification evidence for **604304** implementation of the **0065** `INLINE_PROCEDURE_IN_FUNCTION_BODY` baseline migration replay blocker fix (inline `add_check` procedure removal + call-site expansion), per Human Approval for 604304 and prior **604303** Analysis.

This Verification does **not** close **604260**. It does **not** authorize **604250** resume. **604306 Audit is required** (not created in this pass).

---

## 1. Verification Scope

| In scope | Out of scope |
| --- | --- |
| **0065** `run_isolation_audit` apply after add_check fix | Fixing remaining **0065** aggregate-limit defect or other post-0065 blockers |
| Static: no `procedure add_check` / `call add_check` | **604260** closeout |
| Prior **0035** / **0038** / **0042** / **0046** / **0063** regression | **604250** resume |
| Clean sequential replay **0001–0142** reachability | **604310** / **604316** |
| **0142** object checks **if reached** | **604306** Audit document creation |

---

## 2. Approval Source

- **604303** Analysis — inline `procedure add_check` inside `run_isolation_audit`; 13 call sites
- **604304** Implementation (Codex) — inline expansion; no new schema objects
- Prior verification: **604301** (failed at 0065 add_check); **604302** Audit (0063 PASS)

Prior blocked state: `604301` last applied **0064**; failed at **0065** with inline procedure parse error at `add_check(...)`.

---

## 3. Environment

| Item | Value |
| --- | --- |
| Supabase local | **Yes** — Docker available |
| DB container | `supabase_db_yoonsul_wait_order_handoff` |
| Container image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Container status | Up (healthy) at verification time |
| Verification DB | **`catchmenu_local_verify_604305`** (new; not reused from 604301/604296 runs) |
| DB name guard | Contains `local` — satisfies `0034` seed guard |
| Production DB used | **No** |
| Migrations copied to container | **Yes** — `/tmp/catchmenu_migrations` refreshed from current working tree |

Working-tree migrations include **604291/604295**-corrected **0046**, **604300**-corrected **0063**, **604304**-corrected **0065**.

---

## 4. Clean Replay Setup

```text
1. docker cp sql/migrations/. → supabase_db_yoonsul_wait_order_handoff:/tmp/catchmenu_migrations
2. dropdb --if-exists catchmenu_local_verify_604305
3. createdb catchmenu_local_verify_604305
4. Sequential apply: all sql/migrations/*.sql where Name <= 0142_patch_toss_mvp_payment_intent_binding.sql
   (140 files in set; sorted by filename)
```

---

## 5. Sequential Replay Result

| Field | Result |
| --- | --- |
| Overall | **Failed before 0142** |
| **Last applied** | `0064_create_menu_i18n_allergen.sql` (0065 started; partial apply before failure) |
| **Failed at** | `0065_create_security_isolation_rpc.sql` |
| Migrations fully applied count | **64** of 140 (0001–0064 inclusive); **0065 incomplete** |

**0065 error (verbatim summary):**

```text
psql:/tmp/catchmenu_migrations/0065_create_security_isolation_rpc.sql:1094: ERROR: syntax error at or near "limit"
LINE 37:       'sample_ids', jsonb_agg(order_id limit 5),
                                                ^
```

Source location: line **926** inside `catchmenu_audit.scan_cross_tenant_risk` — `'sample_ids', jsonb_agg(order_id limit 5)`.

**Blocker classification (new, within same file):** `AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR` — same structural class as **0046** secondary `limit 5` blocker (604295 fix precedent).

**604304 scope (add_check inline procedure): cleared** — `run_isolation_audit` created successfully; add_check syntax error **did not recur**.

**0065 file completion:** **Not met** — `scan_cross_tenant_risk`, `generate_security_report`, and trailing grants/comments in 0065 not applied after failure.

---

## 6. 0065 Verification Result

### Runtime (replay)

| Check | Result |
| --- | --- |
| Inline `procedure add_check` blocker at apply | **Did not recur** |
| `catchmenu_audit.run_isolation_audit` exists | **Yes** |
| Full 0065 migration file applies without error | **No** — failed on `scan_cross_tenant_risk` |
| `scan_cross_tenant_risk` exists | **No** |
| `generate_security_report` exists | **No** |

**`run_isolation_audit` signature (verified):**

```text
catchmenu_audit.run_isolation_audit(p_tenant_id uuid, p_store_id uuid, p_scanned_by_type text, p_scanned_by_id uuid)
```

### Static (working tree, pre-replay)

| Check | Result |
| --- | --- |
| `procedure add_check` in 0065 | **No matches** |
| `call add_check` / `add_check(` call sites | **No matches** |
| New helper function/procedure for add_check | **None observed** (inline expansion only per 604304) |

**604304 add_check fix objective: met.**

**Full 0065 replay-through completion: not met** (secondary aggregate-limit defect remains in same file).

---

## 7. Prior Baseline Regression Recheck

### 0035

| Check | Result |
| --- | --- |
| Sequential replay apply | **Yes** |
| Re-run standalone | **Yes** — **PASS: 85   FAIL: 0   TOTAL: 85** |

### 0038

| Check | Result |
| --- | --- |
| `verify_toss_signature` | **Exists** |
| `process_toss_webhook` | **Exists** |

### 0042

| Check | Result |
| --- | --- |
| All three delivery intake functions | **Exist** |

### 0046

| Check | Result |
| --- | --- |
| Sequential replay apply | **Yes** |
| `build_ai_context` | **Exists** |
| Primary `limit p_max_documents` blocker | **Did not recur** |
| Secondary `limit 5` blocker | **Did not recur** |

### 0063

| Check | Result |
| --- | --- |
| Sequential replay apply | **Yes** |
| `provider_payment_key :=` (static grep) | **No matches** |
| `confirm_payment_from_provider` | **Exists** |
| `mark_payment_uncertain` | **Exists** |
| `authorize_kds_release` | **Exists** |

---

## 8. 0142 Reachability Result

| Check | Result |
| --- | --- |
| Full valid sequential replay reached 0142 | **No** |
| Blocker | `0065_create_security_isolation_rpc.sql` — aggregate `jsonb_agg(... limit 5)` syntax (not add_check) |
| 0142 apply | **Not run** |

0142 not reached due to earlier blocker within **0065** — not due to 0142 apply failure.

---

## 9. 0142 Object Verification

Not executed — **0142 not reached** due to **0065** incomplete apply (secondary blocker).

| Object | Status |
| --- | --- |
| `toss_payment_requests.payment_intent_id` | **Not present** — 0142 not reached due to earlier blocker |
| `payment_intent_id` FK | **Not present** — 0142 not reached due to earlier blocker |
| `initiate_toss_payment` | **Not present** — 0103/0142 not reached |
| `confirm_toss_payment` | **Not present** — 0103/0142 not reached |

---

## 10. Boundary Verification

| Check | Result |
| --- | --- |
| **604305** modified SQL during verification | **No** |
| **0065 / 0063 / 0046 / 0035 / 0038 / 0042 / 0142 newly modified by 604305** | **No** |
| Worktree diff on boundary migrations | **Present** — pre-existing approved artifacts |
| `604257_Module` (604250) | **Does not exist** |
| `604316_Approval` (604310) | **Does not exist** |
| **604250 resumed** | **No** |
| **604260 closed** | **No** |
| **604310 implemented** | **No** |
| **604306 Audit created** | **No** (forbidden this pass) |

---

## 11. Known Gaps

1. **0065** `jsonb_agg(order_id limit 5)` at line 926 blocks completion of 0065 and replay 0066–0142 — outside 604304 approved scope (add_check only).
2. **0073_final_verification.sql** may expose additional blockers when replay progresses — not reached.
3. **0142 runtime object verification** deferred until full replay succeeds.
4. **604260** runtime closeout remains blocked until clean replay reaches and applies 0142.

---

## 12. Final Verification Result

```text
PARTIAL
```

Rationale:

| Criterion | Status |
| --- | --- |
| add_check inline procedure blocker cleared | **Met** — `run_isolation_audit` applies |
| Static: no procedure/call add_check | **Met** |
| Full 0065 migration file applies | **Not met** — aggregate limit syntax at line 926 |
| Prior 0035/0038/0042/0046/0063 regression | **Met** |
| Clean sequential replay reached and applied 0142 | **Not met** |
| 0142 object verification | **Not met** — 0142 not reached due to earlier blocker |
| 604304 boundary (verification pass) | **Met** |

604304 **add_check fix verification**: **PASSED**.

604304 **full 0065 file / replay-through-0142** goal: **NOT PASSED** (secondary blocker in same file).

---

## 13. Final Rule

```text
604305 confirms the 0065 add_check inline procedure baseline replay blocker is fixed under 604304.
604305 confirms prior 0035/0038/0042/0046/0063 fixes remain valid on clean replay.
604305 records a new pre-existing defect in the same 0065 file (aggregate inline limit) blocking full 0065 apply.
604305 does not close 604260.
604305 does not authorize 604250 resume.
604306 Audit is required (not created in this verification pass).
No SQL or migration files were modified during this verification pass.
```

---

## Appendix — Commands Run

```text
docker ps (supabase_db_yoonsul_wait_order_handoff)
docker cp sql/migrations/. → container:/tmp/catchmenu_migrations
dropdb / createdb catchmenu_local_verify_604305
Sequential psql -f for 0001–0142 (failed during 0065)
Re-run psql -f 0035_verify_schema.sql (85 PASS evidence)
Function existence: run_isolation_audit, build_ai_context, 0063/0038/0042 functions
0142 column/FK/function queries (not present — 0142 not reached)
Static grep: procedure add_check, call add_check, add_check(, provider_payment_key :=
git diff --check
git diff --name-only (boundary files)
Test-Path 604257, 604316
```
