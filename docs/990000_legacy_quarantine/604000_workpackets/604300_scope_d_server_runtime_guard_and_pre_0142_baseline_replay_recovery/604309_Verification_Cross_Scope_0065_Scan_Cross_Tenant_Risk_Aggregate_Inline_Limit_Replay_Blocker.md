# 604309_Verification_Cross_Scope_0065_Scan_Cross_Tenant_Risk_Aggregate_Inline_Limit_Replay_Blocker.md

Status: Complete
Lifecycle: Verification
Gate Classification: Local Verification — 0065 Aggregate Inline Limit Replay Blocker Fix
Runtime Implementation Authorization: Not Granted By This Document
Owner: Local Verification Runner (Cursor)
Last Updated: 2026-07-05

---

## 0. Purpose

Record Supabase local **clean replay** verification evidence for **604308** implementation of the **0065** `scan_cross_tenant_risk` aggregate inline limit baseline migration replay blocker fix (`jsonb_agg(order_id limit 5)` → nested scalar subquery), per Human Approval for 604308 and prior **604305** / **604304** fixes on the same file.

This Verification does **not** close **604260**. It does **not** authorize **604250** resume. **Next Audit document is required** (number assigned separately by Human; not created in this pass).

---

## 1. Verification Scope

| In scope | Out of scope |
| --- | --- |
| **0065** full file apply + all three audit security functions | Fixing **0066** or other post-0065 blockers |
| Prior **0035** / **0038** / **0042** / **0046** / **0063** / **604304 add_check** regression | **604260** closeout |
| Static 0065: no add_check / no aggregate inline limit | **604250** resume |
| Clean sequential replay **0001–0142** reachability | **604310** / **604316** |
| **0142** object checks **if reached** | Audit document creation |

---

## 2. Approval Source

- **604305** Verification — 604304 add_check fix PASS; 0065 failed on aggregate limit at line 926
- **604308** Implementation (Codex) — nested subquery for `sample_ids` cap 5; `mismatched` CTE `limit 10` preserved
- Prior chain: **604304** (add_check), **604300** (0063), **604291/604295** (0046)

Prior blocked state: `604305` — 0065 partial apply; failed on `jsonb_agg(order_id limit 5)` in `scan_cross_tenant_risk`.

---

## 3. Environment

| Item | Value |
| --- | --- |
| Supabase local | **Yes** — Docker available |
| DB container | `supabase_db_yoonsul_wait_order_handoff` |
| Container image | `public.ecr.aws/supabase/postgres:17.6.1.140` |
| Container status | Up (healthy) at verification time |
| Verification DB | **`catchmenu_local_verify_604309`** (new; not reused from 604305/604301 runs) |
| DB name guard | Contains `local` — satisfies `0034` seed guard |
| Production DB used | **No** |
| Migrations copied to container | **Yes** — `/tmp/catchmenu_migrations` refreshed from current working tree |

---

## 4. Clean Replay Setup

```text
1. docker cp sql/migrations/. → supabase_db_yoonsul_wait_order_handoff:/tmp/catchmenu_migrations
2. dropdb --if-exists catchmenu_local_verify_604309
3. createdb catchmenu_local_verify_604309
4. Sequential apply: all sql/migrations/*.sql where Name <= 0142_patch_toss_mvp_payment_intent_binding.sql
   (140 files in set; sorted by filename)
```

---

## 5. Sequential Replay Result

| Field | Result |
| --- | --- |
| Overall | **Failed before 0142** |
| **Last applied** | `0065_create_security_isolation_rpc.sql` |
| **Failed at** | `0066_create_ledger_integrity_rpc.sql` |
| Migrations applied count | **65** of 140 (0001–0065 inclusive) |

**0066 error (verbatim summary):**

```text
psql:/tmp/catchmenu_migrations/0066_create_ledger_integrity_rpc.sql:429: ERROR: syntax error at or near "limit"
LINE 84:         'sample_ids', jsonb_agg(id limit 5)
                                            ^
```

Source locations in 0066 (same defect class, multiple occurrences): lines **185**, **223**, **250**, **556**, **582**.

**Blocker classification:** `AGGREGATE_INLINE_LIMIT_SYNTAX_ERROR` — same structural class as pre-fix **0065** / **0046** secondary blocker; **outside 604308 approval boundary**.

**604308 scope (0065 aggregate limit): cleared** — **0065** applied in full; replay progressed to **0066** before halting.

---

## 6. 0065 Verification Result

### Runtime (replay)

| Check | Result |
| --- | --- |
| **0065 full file applies** | **Yes** |
| `catchmenu_audit.run_isolation_audit` | **Exists** |
| `catchmenu_audit.scan_cross_tenant_risk` | **Exists** |
| `catchmenu_audit.generate_security_report` | **Exists** |
| add_check inline procedure blocker | **Did not recur** |
| `jsonb_agg(order_id limit 5)` blocker | **Did not recur** |
| aggregate inline limit blocker in 0065 apply | **Did not recur** |

### Static (working tree)

| Check | Result |
| --- | --- |
| `procedure add_check` | **No matches** |
| `add_check(` call sites | **No matches** |
| `jsonb_agg(order_id limit 5)` | **No matches** |
| `jsonb_agg(` with inline `limit` in 0065 | **No matches** |
| `mismatched` CTE `limit 10` | **Present** (line 919) |
| `sample_ids` cap via subquery `limit 5` | **Present** (lines 926–935) |
| New helper function/procedure for sample_ids | **None** (nested scalar subquery only) |

**604308 fix objective: met.**

**Full replay-through-0142: not met** (new blocker **0066**).

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
| Blocker | `0066_create_ledger_integrity_rpc.sql` — `jsonb_agg(id limit 5)` |
| 0142 apply | **Not run** |

0142 not reached due to earlier blocker at **0066** — not due to 0142 apply failure.

---

## 9. 0142 Object Verification

Not executed — **0142 not reached** due to **0066** blocker.

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
| **604309** modified SQL during verification | **No** |
| **0065 / 0063 / 0046 / 0035 / 0038 / 0042 / 0142 newly modified by 604309** | **No** |
| Worktree diff on boundary migrations | **Present** — pre-existing approved artifacts |
| `604257_Module` (604250) | **Does not exist** |
| `604316_Approval` (604310) | **Does not exist** |
| **604250 resumed** | **No** |
| **604260 closed** | **No** |
| **604310 implemented** | **No** |
| **604310 / 604311 / 604312 newly created** | **No** |
| Audit document created | **No** (Human assigns next number) |

---

## 11. Known Gaps

1. **0066** contains five `jsonb_agg(id limit 5)` occurrences — blocks replay 0067–0142; outside 604308 boundary.
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
| 0065 full file applies | **Met** |
| All three 0065 security audit functions exist | **Met** |
| add_check / aggregate inline limit blockers in 0065 | **Met** — did not recur |
| Prior 0035/0038/0042/0046/0063 regression | **Met** |
| Clean sequential replay reached and applied 0142 | **Not met** — failed at **0066** |
| 0142 object verification | **Not met** — 0142 not reached due to earlier blocker |
| 604308 boundary (verification pass) | **Met** |

604308 **0065 aggregate limit fix verification**: **PASSED**.

Full **replay-through-0142** goal: **NOT PASSED** (new blocker **0066**).

---

## 13. Final Rule

```text
604309 confirms the 0065 scan_cross_tenant_risk aggregate inline limit blocker is fixed under 604308.
604309 confirms 0065 applies in full with run_isolation_audit, scan_cross_tenant_risk, and generate_security_report present.
604309 confirms prior 0035/0038/0042/0046/0063 and 604304 add_check fixes remain valid on clean replay.
604309 records a new pre-existing defect in 0066 (jsonb_agg(id limit 5)) blocking replay to 0142.
604309 does not close 604260.
604309 does not authorize 604250 resume.
Next Audit document is required; numbering assigned separately by Human.
No SQL or migration files were modified during this verification pass.
```

---

## Appendix — Commands Run

```text
docker ps (supabase_db_yoonsul_wait_order_handoff)
docker cp sql/migrations/. → container:/tmp/catchmenu_migrations
dropdb / createdb catchmenu_local_verify_604309
Sequential psql -f for 0001–0142 (failed at 0066)
Re-run psql -f 0035_verify_schema.sql (85 PASS evidence)
Function existence: run_isolation_audit, scan_cross_tenant_risk, generate_security_report
Regression: build_ai_context, 0063/0038/0042 functions
0142 column/FK/function queries (not present — 0142 not reached)
Static grep: procedure add_check, add_check(, jsonb_agg(order_id limit, provider_payment_key :=
git diff --check
git diff --name-only (boundary files)
Test-Path 604257, 604316
```
