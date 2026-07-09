# 604327_Verification_Cross_Scope_0068_Realtime_Edge_Invalid_Table_Constraint_Replay_Blocker.md

Status: Complete
Lifecycle: Verification
Gate Classification: Local Verification — 0068 Candidate D (UNIQUE NULLS NOT DISTINCT)
Runtime Implementation Authorization: Not Granted By This Document
Owner: Local Verification Runner (Cursor)
Last Updated: 2026-07-05

---

## 1. Verification Scope

Verify **604326** Candidate D fix on `0068_create_realtime_edge_rpc.sql` via Supabase local clean sequential replay **0001–0142**, including:

- **0068** apply and `uq_function_code` constraint definition
- **UNIQUE NULLS NOT DISTINCT** support and tenant/global uniqueness semantics
- Full regression chain **0067** through **0035**
- **0142** reachability and object checks if reached

Out of scope: fixing **0069+** blockers; **604328** Audit; any SQL/migration edits.

---

## 2. Environment

| Item | Value |
| --- | --- |
| Supabase local | **Yes** |
| DB container | `supabase_db_yoonsul_wait_order_handoff` |
| Container image | PostgreSQL **17.6** (`server_version_num` **170006**) |
| Container status | Up (healthy) |
| Verification DB | **`catchmenu_local_verify_604327`** (new; disposable) |
| Production DB used | **No** |

---

## 3. Migration Copy Procedure

```text
docker exec rm -rf /tmp/catchmenu_migrations
docker exec mkdir -p /tmp/catchmenu_migrations
docker cp sql/migrations/. → supabase_db_yoonsul_wait_order_handoff:/tmp/catchmenu_migrations
```

Source: current working tree (includes 604326 **0068** Candidate D, 604320 **0067** no-op, prior baseline fixes).

---

## 4. Clean DB Replay Procedure

```text
dropdb --if-exists catchmenu_local_verify_604327
createdb catchmenu_local_verify_604327
Sequential psql -v ON_ERROR_STOP=1 -f for all migrations Name <= 0142_patch_toss_mvp_payment_intent_binding.sql
```

---

## 5. Sequential Replay Result

| Field | Result |
| --- | --- |
| Overall | **Failed before 0142** |
| **Last applied** | `0068_create_realtime_edge_rpc.sql` |
| **Failed at** | `0069_create_pgvector_knowledge_rpc.sql` |
| Applied count | **68** of 140 |

**Error (verbatim summary):**

```text
psql:/tmp/catchmenu_migrations/0069_create_pgvector_knowledge_rpc.sql:20: ERROR:  schema "extensions" does not exist
```

**Source context:** line 19–20 — `create extension if not exists vector schema extensions;`

**Blocker classification:** `MISSING_EXTENSIONS_SCHEMA` — pgvector extension target schema absent; outside **604326** boundary.

---

## 6. 0068 Constraint Fix Verification

| Check | Result |
| --- | --- |
| **0068 full file applies** | **Yes** |
| Invalid `coalesce(tenant_id::text, 'GLOBAL')` in table UNIQUE | **Removed** (static: no match in constraint) |
| `catchmenu_common.edge_function_registry` table | **Exists** |
| Constraint name preserved | **Yes** — `uq_function_code` |
| Partial unique indexes (extra) | **None** — only PK + `uq_function_code` |
| Generated columns | **None** (`is_generated` all NEVER) |

**`pg_get_constraintdef` for `uq_function_code`:**

```text
UNIQUE NULLS NOT DISTINCT (tenant_id, function_code)
```

---

## 7. UNIQUE NULLS NOT DISTINCT Verification

| Check | Result |
| --- | --- |
| Feature supported on replay DB (PG 17.6) | **Yes** |
| Index definition includes `NULLS NOT DISTINCT` | **Yes** |
| Duplicate NULL global scope test | **Unique violation as expected** |
| Same `function_code` different tenant UUIDs | **Both inserts succeed** (within rolled-back txn) |

**Duplicate NULL test:**

```text
INSERT (NULL, '604327_SEM_TEST', ...) → OK
INSERT (NULL, '604327_SEM_TEST', ...) → ERROR duplicate key uq_function_code
```

**Tenant-specific override test:**

```text
INSERT (tenant A, '604327_TENANT_TEST', ...) → OK
INSERT (tenant B, '604327_TENANT_TEST', ...) → OK
ROLLBACK
```

---

## 8. Edge Function Registry Semantics Verification

| Semantics | Result |
| --- | --- |
| `tenant_id IS NULL` = GLOBAL scope | **Confirmed** — NULL rows share uniqueness bucket |
| `tenant_id NOT NULL` = tenant-specific | **Confirmed** — same code allowed across tenants |
| `function_code` unique within each scope | **Confirmed** |
| Seed data from 0068 migration | **Applied** (GLOBAL rows with NULL `tenant_id`, e.g. TOSS_WEBHOOK) |

RLS policies, RPC bodies, realtime channel seed, and edge routing logic were not diff-reviewed in this pass; **604326** boundary asserts no intentional change — replay apply success is the runtime evidence that parse/DDL for those sections remains valid.

---

## 9. 0067 Regression Verification

| Check | Result |
| --- | --- |
| **0067** applies | **Yes** (no-op `DO $$ null; $$`) |
| Duplicated 0066 content in 0067 file | **Absent** (17-line no-op file) |
| pg_cron / cron.schedule / new cron objects | **None** (0 catchmenu_* cron functions) |

---

## 10. 0066 Regression Verification

| Check | Result |
| --- | --- |
| **0066** applies | **Yes** |
| Inline aggregate limit in 0066 (static) | **0 matches** |
| `verify_event_ledger_integrity` | **Exists** |
| `verify_audit_chain` | **Exists** |
| `run_state_projection_check` | **Exists** |
| `reconcile_ledger_gaps` | **Exists** |

---

## 11. 0065 Regression Verification

| Check | Result |
| --- | --- |
| **0065** applies | **Yes** |
| `run_isolation_audit` | **Exists** |
| `scan_cross_tenant_risk` | **Exists** |
| `generate_security_report` | **Exists** |
| add_check / aggregate inline limit (static) | **No matches** in 0065 |

---

## 12. 0063 Regression Verification

| Check | Result |
| --- | --- |
| **0063** applies | **Yes** |
| `provider_payment_key :=` (static) | **No matches** |
| `confirm_payment_from_provider` | **Exists** |
| `mark_payment_uncertain` | **Exists** |
| `authorize_kds_release` | **Exists** |

---

## 13. 0046 Regression Verification

| Check | Result |
| --- | --- |
| **0046** applies | **Yes** |
| `build_ai_context` | **Exists** |
| Primary `limit p_max_documents` blocker | **Did not recur** |
| Secondary `limit 5` blocker | **Did not recur** |

---

## 14. 0035 Regression Verification

| Check | Result |
| --- | --- |
| Sequential apply | **Yes** |
| Re-run standalone | **Yes** |
| **PASS** | **85** |
| **FAIL** | **0** |
| **TOTAL** | **85** |

---

## 15. 0038 Regression Verification

| Check | Result |
| --- | --- |
| `verify_toss_signature` | **Exists** |
| `process_toss_webhook` | **Exists** |

---

## 16. 0042 Regression Verification

| Check | Result |
| --- | --- |
| `intake_delivery_order` | **Exists** |
| `sync_delivery_order_status` | **Exists** |
| `reject_delivery_order` | **Exists** |

---

## 17. 0142 Reachability Verification

| Check | Result |
| --- | --- |
| Full replay reached 0142 | **No** |
| Blocker | **0069** — `extensions` schema missing for pgvector |
| 0142 apply | **Not run** |

---

## 18. 0142 Object Verification

Not executed — **0142 not reached due to earlier blocker (0069)**.

| Object | Status |
| --- | --- |
| `payment_intent_id` column | **Not present** |
| `payment_intent_id` FK | **Not present** |
| `initiate_toss_payment` | **Not present** |
| `confirm_toss_payment` | **Not present** |

---

## 19. Boundary Compliance

| Check | Result |
| --- | --- |
| **604327** modified SQL | **No** |
| **0068–0035 / 0142** modified by 604327 | **No** |
| **604250 resumed / 604260 closed** | **No** |
| **604310 / 604316 / 604322 / 604328** | **Not used / not created** |
| Files created | **This Verification document only** |

---

## 20. git diff --check Result

**Passed** — no trailing-whitespace errors reported for verification pass. Worktree shows pre-existing diff on `0068` from **604326** (not introduced by 604327).

---

## 21. Final Verification Result

```text
PASS_0068_BLOCKED_BY_OTHER_PRE_0142_MIGRATION
```

604326 **0068 Candidate D fix verification**: **PASSED**.

Full **replay-through-0142**: **NOT PASSED** — blocked at **0069** (`extensions` schema).

---

## 22. Recommended Next Step

**604328 Audit by Claude** (not created in this pass).

Separate workpacket/approval may be required for **0069** pgvector `extensions` schema blocker before replay can progress toward **0142**.

604327 does not close **604260** or authorize **604250** resume.

---

## Appendix — Report Summary (Cursor output)

```text
604327 Verification: created
H1 match: yes
Environment: Supabase local yes; DB supabase_db_yoonsul_wait_order_handoff; Verification DB catchmenu_local_verify_604327
Sequential replay: failed; last 0068; failed 0069; error schema "extensions" does not exist
0068: passed
0067: passed
0066–0035 regression: passed
0142: not reached / not applied
Boundary: PASS
git diff --check: passed
SQL/runtime changes by 604327: none
Final: PASS_0068_BLOCKED_BY_OTHER_PRE_0142_MIGRATION
Next: 604328 Audit by Claude
```
